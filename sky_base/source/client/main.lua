if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/main.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_base · source/client/main.lua
--  Deobfuscated & Cleaned
-- =====================================================

-- -----------------------------------------------------
--  EXPORTS
-- -----------------------------------------------------
registerExport("Get", function()
    return Sky
end)

registerExport("FormatCurrency", function(amount, currency)
    return Sky.Currency.Format(amount, currency)
end)

registerExport("GetCurrencyFormatter", function(currency)
    return Sky.Currency.GetFormatter(currency)
end)

registerExport("GetCurrencyNuiConfig", function()
    return Sky.Currency.GetNuiConfig()
end)

registerExport("GetDefaultCurrency", function()
    return Sky.Currency.GetDefaultCurrency()
end)

registerExport("FormatCurrencyAmount", function(amount, currency)
    return Sky.Currency.FormatCurrencyAmount(amount, currency)
end)

registerExport("RegisterCustomPhoneApp", function(data)
    return Sky.Functions.RegisterCustomPhoneApp(data)
end)

registerExport("SendCustomPhoneAppMessage", function(appName, messageData)
    return Sky.Functions.SendCustomPhoneAppMessage(appName, messageData)
end)

registerExport("SendPhoneAppNotification", function(data)
    return Sky.Functions.SendPhoneAppNotification(data)
end)

-- -----------------------------------------------------
--  INTERACTION & TARGET SYSTEM STATE
-- -----------------------------------------------------
InteractionPoints = {}
TargetPoints = {}

local activeIndex = 1
local activeInteractionPoints = {}
local activeTargetPoints = {}
local activeInteractionsCount = 0

local DRAW_BUFFER = tonumber(Config.interactionDrawBuffer) or 5.0
local STREAM_NPC_ENABLED = Config.streamNpcEnabled ~= false
local STREAM_NPC_DIST = tonumber(Config.streamNpcDistance) or 100.0
local STREAM_NPC_REFRESH_MS = tonumber(Config.streamNpcRefreshMs) or 1000
local STREAM_NPC_MAX_SPAWNS = math.max(1, math.floor(tonumber(Config.streamNpcMaxSpawnsPerPass) or 4))
local STREAM_NPC_HYSTERESIS = math.max(20.0, STREAM_NPC_DIST * 0.2)

local currentActiveCount = 0
local trackedPeds = {}

local CreatorPrefixes = {
    sky_policejob = { "sky_jobs_base:creator:jailcreator:", "sky_jobs_base:creator:stationcreator:" },
    sky_ambulancejob = { "sky_jobs_base:creator:hospitalcreator:" },
    sky_firejob = { "sky_jobs_base:creator:firecreator:" },
    sky_mechanicjob = { "sky_jobs_base:creator:workshopcreator:" }
}

-- -----------------------------------------------------
--  INTERNAL UTILITIES
-- -----------------------------------------------------
local function getTableKeys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        keys[#keys + 1] = k
    end
    return keys
end

local function removeInteractionPointIndex(idx)
    if activeInteractionPoints[idx] then
        activeInteractionPoints[idx] = nil
        activeInteractionsCount = math.max(0, activeInteractionsCount - 1)
    end
    activeTargetPoints[idx] = nil
    local point = InteractionPoints[idx]
    if point then
        point.distance = nil
        point.inInteractionRange = false
        point.nextRenderRefreshAt = nil
    end
end

local function trackPed(point, entity)
    local resName = point and point.resourceName
    if not (resName and entity) or entity == 0 then return end
    trackedPeds[resName] = trackedPeds[resName] or {}
    trackedPeds[resName][entity] = true
end

local function untrackPed(point, entity)
    local resName = point and point.resourceName
    if not (resName and entity) or entity == 0 then return end
    local resPeds = trackedPeds[resName]
    if not resPeds then return end
    resPeds[entity] = nil
    if not next(resPeds) then
        trackedPeds[resName] = nil
    end
end

local function deleteInteractionPed(point)
    local entity = point and point.npcEntity
    if not entity then return end
    if Sky.Ped.Delete(entity) then
        untrackPed(point, entity)
        point.npcEntity = nil
        point.npcSpawned = false
    else
        Sky.Debug("error", ("Failed to delete interaction ped for id=%s entity=%s"):format(tostring(point.id), tostring(entity)))
    end
end

local function deleteAllTrackedPeds(targetResource)
    local resources = {}
    if targetResource then
        resources[1] = targetResource
    else
        for res in pairs(trackedPeds) do
            resources[#resources + 1] = res
        end
    end

    for _, res in ipairs(resources) do
        local resPeds = trackedPeds[res]
        if resPeds then
            for entity in pairs(resPeds) do
                if Sky.Ped.Delete(entity) then
                    resPeds[entity] = nil
                else
                    Sky.Debug("error", ("Failed to delete tracked interaction ped for resource=%s entity=%s"):format(tostring(res), tostring(entity)))
                end
            end
            if not next(resPeds) then
                trackedPeds[res] = nil
            end
        end
    end
end

local function isResourceMatch(point, targetRes, isSelf)
    if isSelf then return true end
    if point.resourceName == targetRes then return true end
    local prefixes = CreatorPrefixes[targetRes]
    if prefixes then
        local pointId = tostring(point.id or "")
        for _, prefix in ipairs(prefixes) do
            if pointId:sub(1, #prefix) == prefix then
                return true
            end
        end
    end
    return false
end

local function removeTargetOptionOrZone(point)
    if point.targetType == "entity" then
        if point.targetEntity then
            local ok, err = pcall(function()
                Sky.Target.RemoveLocalEntity(point.targetEntity, point.optionName)
            end)
            if not ok then
                Sky.Debug("error", ("RemoveLocalEntity failed for interaction id=%s: %s"):format(tostring(point.id), tostring(err)))
            end
            point.targetEntity = nil
            point.targetType = nil
        end
    elseif point.zone then
        local ok, err = pcall(function()
            Sky.Target.RemoveZone(point.zone)
        end)
        if not ok then
            Sky.Debug("error", ("RemoveZone failed for interaction id=%s: %s"):format(tostring(point.id), tostring(err)))
        end
        point.zone = nil
    end
end

local function getPointCoords(point)
    if point.getCoords then
        local coords = point.getCoords(point.sourceEntity)
        if coords and coords.x then
            point.coords = vector3(coords.x, coords.y, coords.z)
        end
        return point.coords and point.coords.x
    end

    if point.sourceEntity then
        if not DoesEntityExist(point.sourceEntity) then
            InteractionPoints[point.index] = nil
            removeInteractionPointIndex(point.index)
            return false
        end

        local coords
        if point.offset then
            coords = GetOffsetFromEntityInWorldCoords(
                point.sourceEntity,
                point.offset.x or 0.0,
                point.offset.y or 0.0,
                point.offset.z or 0.0
            )
        else
            coords = GetEntityCoords(point.sourceEntity)
        end

        if coords and coords.x then
            point.coords = vector3(coords.x, coords.y, coords.z)
        end
    end

    return point.coords and point.coords.x
end

local function canInteract(point, playerPed, inVehicle)
    if point.requireVehicle and not inVehicle then
        return false
    end
    if type(point.canInteract) == "function" then
        return not not point.canInteract(point, playerPed)
    end
    return true
end

local function updateInteractionPoint(idx, point, playerCoords, inVehicle)
    if not getPointCoords(point) then
        removeInteractionPointIndex(idx)
        return false
    end

    local dist = #(playerCoords - point.coords)
    local drawDist = tonumber(point.activeDistance) or tonumber(point.drawDistance) or (point.interactionDistance + DRAW_BUFFER)
    local isWithinDraw = dist < drawDist

    if isWithinDraw and canInteract(point, playerCoords, inVehicle) then
        activeInteractionPoints[idx] = point
        activeTargetPoints[idx] = true
        point.distance = dist
        point.inInteractionRange = dist < point.interactionDistance
        point.nextRenderRefreshAt = GetGameTimer() + 150
        return true
    end

    removeInteractionPointIndex(idx)
    return false
end

local function triggerInteraction(idx, point, playerPed)
    if not getPointCoords(point) then
        removeInteractionPointIndex(idx)
        return false
    end

    local pCoords = GetEntityCoords(playerPed)
    local inVehicle = IsPedInAnyVehicle(playerPed, false)
    local dist = #(pCoords - point.coords)

    point.distance = dist
    point.inInteractionRange = dist < point.interactionDistance
    if not point.inInteractionRange then return false end
    if not canInteract(point, pCoords, inVehicle) then return false end

    TriggerEvent(point.event, point.id, point)
    point.nextRenderRefreshAt = 0
    return true
end

local function spawnNpc(point)
    local spec = point.npcSpec
    if not (spec and spec.pedHash) then return end

    local pedObj = Sky.Ped:new()
    pedObj:Spawn(spec.pedHash, point.coords, spec.heading, {
        scenario = spec.scenario,
        onSpawn = spec.onSpawn,
        spawnProfile = "interaction"
    })

    if TargetPoints[point.index] ~= point and InteractionPoints[point.index] ~= point then
        if pedObj.entity and DoesEntityExist(pedObj.entity) then
            Sky.Ped.Delete(pedObj.entity)
        end
        return
    end

    pedObj:Freeze()
    point.npcEntity = pedObj.entity
    point.npcSpawned = true
    trackPed(point, point.npcEntity)

    if point.onPedSpawned and point.npcEntity then
        pcall(point.onPedSpawned, point.npcEntity)
    end

    if point.targetOption and point.npcEntity then
        Sky.Target.AddLocalEntity(point.npcEntity, { point.targetOption })
        point.targetType = "entity"
        point.targetEntity = point.npcEntity
    end
end

local function despawnNpc(point)
    if point.targetOption then
        removeTargetOptionOrZone(point)
    end
    deleteInteractionPed(point)
end

local function streamNpc(point, playerCoords, atSpawnLimit)
    if not point.coords then return false end
    local dist = #(playerCoords - point.coords)

    if point.npcSpawned then
        if dist > (point.streamDistance + STREAM_NPC_HYSTERESIS) then
            despawnNpc(point)
        end
        return false
    end

    if atSpawnLimit and dist <= point.streamDistance then
        spawnNpc(point)
        return true
    end

    return false
end

-- -----------------------------------------------------
--  BACKGROUND STREAMING & DRAW THREADS
-- -----------------------------------------------------
CreateThread(function()
    local sleep = 2000
    while true do
        Wait(sleep)
        if not next(InteractionPoints) then
            if activeInteractionsCount <= 0 then
                activeTargetPoints = {}
                activeInteractionPoints = {}
                currentActiveCount = 0
                sleep = 2000
            end
        else
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)
            local inVehicle = IsPedInAnyVehicle(ped, false)
            local activeCount = 0
            local spawnedThisPass = 0

            for _, idx in ipairs(getTableKeys(InteractionPoints)) do
                local pt = InteractionPoints[idx]
                if pt then
                    if updateInteractionPoint(idx, pt, pCoords, inVehicle) then
                        activeCount = activeCount + 1
                    end
                    if pt.npcSpec and InteractionPoints[idx] then
                        if streamNpc(pt, pCoords, spawnedThisPass < STREAM_NPC_MAX_SPAWNS) then
                            spawnedThisPass = spawnedThisPass + 1
                        end
                    end
                end
            end

            for _, idx in ipairs(getTableKeys(TargetPoints)) do
                local pt = TargetPoints[idx]
                if pt and pt.npcSpec then
                    if streamNpc(pt, pCoords, spawnedThisPass < STREAM_NPC_MAX_SPAWNS) then
                        spawnedThisPass = spawnedThisPass + 1
                    end
                end
            end

            currentActiveCount = activeCount
            if currentActiveCount > 0 then
                sleep = 250
            elseif activeInteractionsCount > 0 then
                sleep = STREAM_NPC_REFRESH_MS
            else
                sleep = 2000
            end
        end
    end
end)

CreateThread(function()
    while true do
        if currentActiveCount <= 0 then
            Wait(100)
        else
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)
            local inVehicle = IsPedInAnyVehicle(ped, false)
            local now = GetGameTimer()
            local sleep = 25

            for _, idx in ipairs(getTableKeys(activeInteractionPoints)) do
                local pt = activeInteractionPoints[idx]
                if not pt then
                    removeInteractionPointIndex(idx)
                else
                    local point = InteractionPoints[idx]
                    if not point then
                        removeInteractionPointIndex(idx)
                    else
                        local isValid = true
                        if not pt.nextRenderRefreshAt or now >= pt.nextRenderRefreshAt then
                            isValid = updateInteractionPoint(idx, pt, pCoords, inVehicle)
                        end

                        if isValid then
                            local dist = pt.coords and #(pCoords - pt.coords) or (pt.distance or 9999.0)
                            if next(pt.marker or {}) then
                                sleep = 0
                                Sky.Show.Marker(pt.coords, pt.marker)
                            end

                            if not pt.markerOnly and dist < pt.interactionDistance then
                                Sky.Show.HelpNotification(pt.message, "E")
                                if IsControlJustPressed(0, 38) then
                                    triggerInteraction(idx, pt, ped)
                                end
                            end
                        end
                    end
                end
            end
            Wait(sleep)
        end
    end
end)

-- -----------------------------------------------------
--  PUBLIC SYSTEM INTERFACE
-- -----------------------------------------------------
--- Creates an interactive point (supports help notification, marker, target, and NPC spawn).
function Sky.CreateInteractionPoint(coords, message, event, id, marker, npc, blip, resourceName, interactDist, existingEntity, onPedSpawned, extraOpts)
    local getCoordsFn = nil
    local srcEntity = nil

    if type(coords) == "function" then
        getCoordsFn = coords
        coords = getCoordsFn()
    elseif type(coords) == "table" and coords.entity then
        srcEntity = coords.entity
        if type(coords.getCoords) == "function" then
            getCoordsFn = coords.getCoords
            coords = getCoordsFn(srcEntity)
        elseif type(coords.offset) == "table" then
            coords = GetOffsetFromEntityInWorldCoords(srcEntity, coords.offset.x or 0.0, coords.offset.y or 0.0, coords.offset.z or 0.0)
        else
            coords = GetEntityCoords(srcEntity)
        end
    elseif type(coords) == "table" and type(coords.getCoords) == "function" then
        getCoordsFn = coords.getCoords
        coords = getCoordsFn()
    end

    local canInteractFn = nil
    if type(coords) == "table" and type(coords.canInteract) == "function" then
        canInteractFn = coords.canInteract
    end

    local reqVehicle = type(coords) == "table" and (coords.requireVehicle == true)
    local forceMarker = (type(extraOpts) == "table" and extraOpts.forceMarkerInteraction == true) or (type(coords) == "table" and coords.forceMarkerInteraction == true)

    if not (coords and coords.x) then return end
    local pos = vector3(coords.x, coords.y, coords.z)

    marker = marker or {}
    npc = npc or {}
    blip = blip or {}

    local npcSpecData = nil
    if next(npc) then
        if not npc.pedHash then
            Sky.Debug("error", ("CreateInteractionPoint: npc table for id=%s has no pedHash, skipping ped spawn"):format(tostring(id)))
        else
            npcSpecData = {
                pedHash = npc.pedHash,
                heading = npc.heading,
                scenario = npc.scenario,
                onSpawn = npc.onSpawn
            }
        end
    end

    local npcEnt = nil
    if existingEntity and DoesEntityExist(existingEntity) then
        npcEnt = existingEntity
        if next(npc) then
            if npc.scenario then
                TaskStartScenarioInPlace(npcEnt, npc.scenario, 0, true)
            end
            if type(npc.onSpawn) == "function" then
                npc.onSpawn(npcEnt)
            end
        end
        if onPedSpawned then
            pcall(onPedSpawned, npcEnt)
        end
    elseif npcSpecData and not STREAM_NPC_ENABLED then
        local pedObj = Sky.Ped:new()
        pedObj:Spawn(npcSpecData.pedHash, pos, npcSpecData.heading, {
            scenario = npcSpecData.scenario,
            onSpawn = npcSpecData.onSpawn,
            spawnProfile = "interaction"
        })
        pedObj:Freeze()
        npcEnt = pedObj.entity
        if onPedSpawned and npcEnt then
            pcall(onPedSpawned, npcEnt)
        end
    end

    local blipId = nil
    if next(blip) then
        blipId = Sky.Show.Blip(pos, blip.sprite, blip.color, blip.name)
    end

    local interactionDist = tonumber((type(extraOpts) == "table" and extraOpts.interactionDistance) or (type(coords) == "table" and coords.interactionDistance) or interactDist)
    if not interactionDist then
        interactionDist = tonumber(Config.interactionDistance) or 2.0
    end

    local drawDist = tonumber((type(extraOpts) == "table" and extraOpts.drawDistance) or (type(coords) == "table" and coords.drawDistance)) or (interactionDist + DRAW_BUFFER)
    local activeDist = math.max(interactionDist, drawDist)

    if next(marker) then
        local mSize = tonumber(marker.markerSize or marker.size or marker.scale) or Config.defaultMarkerSize or 1.0
        marker.scaleX = tonumber(marker.scaleX) or mSize
        marker.scaleY = tonumber(marker.scaleY) or mSize
    end

    local streamDist = STREAM_NPC_DIST
    if STREAM_NPC_ENABLED then
        local configuredStreamDist = tonumber((type(extraOpts) == "table" and extraOpts.streamNpcDistance) or (type(coords) == "table" and coords.streamNpcDistance))
        if configuredStreamDist then
            streamDist = configuredStreamDist
        end
        local minStreamDist = interactionDist + DRAW_BUFFER + 5.0
        if streamDist < minStreamDist then
            Sky.Debug("warn", ("CreateInteractionPoint: streamNpcDistance %.1f for id=%s is below interaction range %.1f, clamping"):format(streamDist, tostring(id), minStreamDist))
            streamDist = minStreamDist
        end
    end

    local strIdx = tostring(activeIndex)
    activeIndex = activeIndex + 1

    if Sky.Target.IsEnabled() and not forceMarker then
        local pointData = {
            id = id,
            npcEntity = npcEnt,
            blipId = blipId,
            resourceName = resourceName,
            index = strIdx,
            optionName = strIdx,
            canInteract = canInteractFn,
            requireVehicle = reqVehicle
        }

        local targetCanInteract = nil
        if type(canInteractFn) == "function" or reqVehicle then
            targetCanInteract = function()
                if reqVehicle then
                    local ped = PlayerPedId()
                    if not (ped and ped ~= 0 and DoesEntityExist(ped) and IsPedInAnyVehicle(ped, false)) then
                        return false
                    end
                end
                if type(canInteractFn) == "function" then
                    local ped = PlayerPedId()
                    return not not canInteractFn(pointData, GetEntityCoords(ped))
                end
                return true
            end
        end

        local targetOpt = {
            name = strIdx,
            icon = "fa-solid fa-circle",
            label = message,
            distance = interactionDist,
            canInteract = targetCanInteract,
            onSelect = function()
                TriggerEvent(event, id, pointData)
            end
        }

        if npcEnt then
            Sky.Target.AddLocalEntity(npcEnt, { targetOpt })
            pointData.targetType = "entity"
            pointData.targetEntity = npcEnt
            trackPed(pointData, npcEnt)
        elseif not STREAM_NPC_ENABLED then
            if srcEntity and DoesEntityExist(srcEntity) then
                Sky.Target.AddLocalEntity(srcEntity, { targetOpt })
                pointData.targetType = "entity"
                pointData.targetEntity = srcEntity
            else
                pointData.zone = Sky.Target.AddSphereZone({
                    coords = pos,
                    radius = interactionDist,
                    debug = false,
                    drawSprite = false,
                    options = { targetOpt }
                })
                pointData.targetType = "zone"
            end
        end

        if STREAM_NPC_ENABLED then
            pointData.coords = pos
            pointData.getCoords = getCoordsFn
            pointData.sourceEntity = srcEntity
            pointData.offset = (type(coords) == "table" and coords.offset) or nil
            pointData.npcSpec = npcSpecData
            pointData.streamDistance = streamDist
            pointData.npcSpawned = (npcEnt ~= nil)
            pointData.onPedSpawned = onPedSpawned
            pointData.targetOption = targetOpt
            activeInteractionsCount = activeInteractionsCount + 1
        end

        if Config.showMarkersWithTarget and next(marker) then
            local markerPoint = {
                coords = pos,
                message = message,
                event = event,
                id = id,
                marker = marker,
                interactionDistance = interactionDist,
                drawDistance = drawDist,
                activeDistance = activeDist,
                resourceName = resourceName,
                index = tostring(activeIndex),
                getCoords = getCoordsFn,
                sourceEntity = srcEntity,
                offset = (type(coords) == "table" and coords.offset) or nil,
                canInteract = canInteractFn,
                requireVehicle = reqVehicle,
                markerOnly = true
            }
            InteractionPoints[markerPoint.index] = markerPoint
            activeIndex = activeIndex + 1
        end

        TargetPoints[strIdx] = pointData
    else
        local pointData = {
            coords = pos,
            message = message,
            event = event,
            id = id,
            marker = marker,
            npcEntity = npcEnt,
            blipId = blipId,
            interactionDistance = interactionDist,
            drawDistance = drawDist,
            activeDistance = activeDist,
            resourceName = resourceName,
            index = strIdx,
            getCoords = getCoordsFn,
            sourceEntity = srcEntity,
            offset = (type(coords) == "table" and coords.offset) or nil,
            canInteract = canInteractFn,
            requireVehicle = reqVehicle
        }

        if STREAM_NPC_ENABLED then
            pointData.npcSpec = npcSpecData
            pointData.streamDistance = streamDist
            pointData.npcSpawned = (npcEnt ~= nil)
            pointData.onPedSpawned = onPedSpawned
            activeInteractionsCount = activeInteractionsCount + 1
        end

        if npcEnt then
            trackPed(pointData, npcEnt)
        end

        InteractionPoints[strIdx] = pointData
    end
end

--- Deletes an interaction point by ID.
function Sky.DeleteInteractionPoint(targetId, keepEntity)
    local deletedNpc = nil

    for _, idx in ipairs(getTableKeys(TargetPoints)) do
        local pt = TargetPoints[idx]
        if pt and pt.id == targetId then
            if pt.blipId then
                RemoveBlip(pt.blipId)
            end
            removeTargetOptionOrZone(pt)
            if pt.npcEntity then
                if keepEntity and DoesEntityExist(pt.npcEntity) then
                    deletedNpc = pt.npcEntity
                else
                    deleteInteractionPed(pt)
                end
            end
            if pt.npcSpec then
                activeInteractionsCount = math.max(0, activeInteractionsCount - 1)
            end
            TargetPoints[idx] = nil
        end
    end

    for _, idx in ipairs(getTableKeys(InteractionPoints)) do
        local pt = InteractionPoints[idx]
        if pt and pt.id == targetId then
            if pt.blipId then
                RemoveBlip(pt.blipId)
            end
            if pt.npcEntity then
                if keepEntity and DoesEntityExist(pt.npcEntity) then
                    deletedNpc = pt.npcEntity
                else
                    deleteInteractionPed(pt)
                end
            end
            if pt.npcSpec then
                activeInteractionsCount = math.max(0, activeInteractionsCount - 1)
            end
            activeInteractionPoints[idx] = nil
            InteractionPoints[idx] = nil
        end
    end

    return deletedNpc
end

local function cleanupResourceInteractions(targetRes, isSelf)
    for _, idx in ipairs(getTableKeys(TargetPoints)) do
        local pt = TargetPoints[idx]
        if pt and isResourceMatch(pt, targetRes, isSelf) then
            if pt.blipId then
                RemoveBlip(pt.blipId)
            end
            removeTargetOptionOrZone(pt)
            deleteInteractionPed(pt)
            if pt.npcSpec then
                activeInteractionsCount = math.max(0, activeInteractionsCount - 1)
            end
            TargetPoints[idx] = nil
        end
    end

    for _, idx in ipairs(getTableKeys(InteractionPoints)) do
        local pt = InteractionPoints[idx]
        if pt and isResourceMatch(pt, targetRes, isSelf) then
            if pt.blipId then
                RemoveBlip(pt.blipId)
            end
            deleteInteractionPed(pt)
            if pt.npcSpec then
                activeInteractionsCount = math.max(0, activeInteractionsCount - 1)
            end
            activeInteractionPoints[idx] = nil
            InteractionPoints[idx] = nil
        end
    end

    deleteAllTrackedPeds(targetRes)
end

AddEventHandler("onClientResourceStop", function(resName)
    cleanupResourceInteractions(resName, resName == GetCurrentResourceName())
end)

AddEventHandler("onResourceStop", function(resName)
    cleanupResourceInteractions(resName, resName == GetCurrentResourceName())
end)

RegisterNetEvent("sky_base:cleanupInteractionResource", function(resName)
    cleanupResourceInteractions(resName, false)
end)

function Sky.RegisterInput(description, key, callback)
    local commandName = ("keys-%s"):format(key)
    RegisterKeyMapping(commandName, description, "keyboard", key)
    RegisterCommand(commandName, function()
        callback()
    end, false)
end
