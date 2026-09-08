if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/creator.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_jobs_base · source/client/creator.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky_Jobs = Sky_Jobs or {}
Sky_Jobs.Creator = Sky_Jobs.Creator or {}

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}
local fallbackLocales = Locales and Locales.en or {}

local cachedCreatorsData = {}
local activeInteractionPoints = {}
local activeSpawnedPedsMap = {}
local activeBlipsMap = {}
local registeredInteractionHooks = {}
local spawnedPedsEntityMap = {}

local DEFAULT_OWNER_RESOURCES = {
    jailcreator = "sky_policejob",
    stationcreator = "sky_policejob",
    hospitalcreator = "sky_ambulancejob",
    firecreator = "sky_firejob",
    workshopcreator = "sky_mechanicjob"
}

local IS_DUTY_SYSTEM_ENABLED = (Config and Config.DutySystem ~= false)

function Sky_Jobs.Creator.RegisterInteractionHook(creatorKey, pointType, hookData)
    registeredInteractionHooks[creatorKey] = registeredInteractionHooks[creatorKey] or {}
    registeredInteractionHooks[creatorKey][pointType] = hookData
end

function Sky_Jobs.Creator.UnregisterInteractionHook(creatorKey, pointType)
    if registeredInteractionHooks[creatorKey] then
        registeredInteractionHooks[creatorKey][pointType] = nil
    end
end

local function triggerPedSpawnedHook(creatorKey, pointType, pointIdKey, pedEntity)
    if spawnedPedsEntityMap[pointIdKey] == pedEntity then return end
    spawnedPedsEntityMap[pointIdKey] = pedEntity

    TriggerEvent("sky_jobs_base:creator:pedSpawned", creatorKey, pointType, pedEntity)

    local hooks = registeredInteractionHooks[creatorKey]
    local hook = hooks and hooks[pointType]
    if hook and hook.onSpawn then
        local ok, err = pcall(hook.onSpawn, pedEntity)
        if not ok then
            print(string.format("[sky_jobs_base] onSpawn hook for %s/%s failed: %s", tostring(creatorKey), tostring(pointType), tostring(err)))
        end
    end
end

local creatorUiState = {
    active = false,
    inputFocused = false,
    currentView = nil,
    key = nil,
    entryId = nil,
    selectedJobKey = nil
}

local playerJobKey = nil
local playerDutyActive = false
local playerDutyLoaded = false
local isPlayerOnDuty = false
local dutyJobKey = nil
local isDutyRebuildPending = false
local isDutyRebuildRunning = false
local isDutyRebuildQueued = false
local DEBOUNCE_WAIT_MS = 1000

local function deepCopyTable(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = (type(v) == "table") and deepCopyTable(v) or v
    end
    return copy
end

local function getTableKeys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

local function resolveCreatorOwnerResource(creatorKey, creatorData)
    local creatorCfg = (type(creatorData) == "table" and type(creatorData.creator) == "table") and creatorData.creator or nil
    local resName = creatorCfg and (creatorCfg.resourceName or creatorCfg.resource or creatorCfg.ownerResource)

    if type(resName) == "string" and resName ~= "" then
        return resName
    end

    return DEFAULT_OWNER_RESOURCES[creatorKey] or GetCurrentResourceName()
end

local function getNestedProperty(tbl, propPath)
    if type(tbl) ~= "table" or type(propPath) ~= "string" or propPath == "" then
        return nil
    end

    local current = tbl
    for key in propPath:gmatch("[^%.]+") do
        if type(current) ~= "table" then return nil end
        current = current[key]
    end

    if type(current) == "string" and current ~= "" then
        return current
    end
    return nil
end

local rebuildAllInteractions -- forward declaration

local function triggerDebouncedRebuild()
    if isDutyRebuildRunning then
        isDutyRebuildQueued = true
        return
    end

    if isDutyRebuildPending then
        isDutyRebuildQueued = true
        return
    end

    isDutyRebuildPending = true
    SetTimeout(DEBOUNCE_WAIT_MS, function()
        isDutyRebuildPending = false
        if isDutyRebuildRunning then
            isDutyRebuildQueued = true
            return
        end

        isDutyRebuildRunning = true
        rebuildAllInteractions()
        isDutyRebuildRunning = false

        if isDutyRebuildQueued then
            isDutyRebuildQueued = false
            triggerDebouncedRebuild()
        end
    end)
end

local function sanitizeStringKey(val)
    if type(val) == "string" then
        local trimmed = val:match("^%s*(.-)%s*$")
        if trimmed ~= "" then return trimmed end
    elseif type(val) == "number" then
        return tostring(val)
    end
    return nil
end

local function updatePlayerJob(jobKey)
    local sanitized = sanitizeStringKey(jobKey)
    local wasDutyLoaded = playerDutyLoaded
    local oldJob = dutyJobKey or playerJobKey

    playerJobKey = sanitized
    playerDutyLoaded = true
    dutyJobKey = nil

    if sanitized then
        local res = Sky.Cb.Trigger("sky_jobs_base:getOnDutyJobFor", { jobKey = sanitized })
        if res and res.success and res.data and res.data.jobKey then
            dutyJobKey = sanitizeStringKey(res.data.jobKey)
        end
    end

    local currentActiveJob = dutyJobKey or playerJobKey
    if not wasDutyLoaded or oldJob ~= currentActiveJob then
        triggerDebouncedRebuild()
    end
end

local function setSelectedJobKey(jobKey)
    local sanitized = sanitizeStringKey(jobKey)
    if creatorUiState.selectedJobKey == sanitized then return end
    creatorUiState.selectedJobKey = sanitized
    triggerDebouncedRebuild()
end

local function updatePlayerDuty(onDutyState)
    local isDuty = onDutyState == true
    local changed = (isPlayerOnDuty ~= isDuty)

    isPlayerOnDuty = isDuty
    if not playerDutyActive then
        playerDutyActive = true
    end

    if changed or not playerDutyActive then
        triggerDebouncedRebuild()
    end
end

local function isJobActiveForCreator(jobKey)
    if creatorUiState.active and creatorUiState.selectedJobKey then
        return creatorUiState.selectedJobKey == jobKey
    end

    if not playerDutyLoaded or not playerJobKey then
        return true
    end

    if playerJobKey == jobKey then
        return true
    end

    if dutyJobKey and dutyJobKey == jobKey then
        return true
    end

    return false
end

local function checkJobMatches(data)
    if type(data) ~= "table" then return false end
    local key = sanitizeStringKey(data.jobKey)
    if not key then return true end
    return isJobActiveForCreator(key)
end

local function isDutySystemDisabled(data)
    if not IS_DUTY_SYSTEM_ENABLED then return false end
    return type(data) ~= "table"
end

local function isDutyInteractionAllowed(pointData, pointType)
    if pointType == "duty_terminal" then return true end
    if not isDutySystemDisabled(pointData) then return true end
    if not playerDutyActive then return true end
    return isPlayerOnDuty == true
end

local function hasInteractionToggleEnabled(cfg)
    if type(cfg) ~= "table" then return false end
    if cfg.enabled ~= nil then return cfg.enabled end
    if cfg.use ~= nil then return cfg.use end
    if cfg.useMarker ~= nil then return cfg.useMarker end
    return true
end

local function checkInteractionNPCConfig(interactionKey, configData)
    local cfg = configData or (Config and Config.Interactions and Config.Interactions[interactionKey])
    if cfg then
        return (type(cfg.npc) == "table") and hasInteractionToggleEnabled(cfg.npc)
    end
    return nil
end

local function isTable(val) return type(val) == "table" end

local function isJobDutyStateActive(pointData)
    if not playerDutyLoaded then return false end
    local jobKey = sanitizeStringKey(pointData and pointData.jobKey)
    if not jobKey then return false end

    if dutyJobKey and dutyJobKey == jobKey then return true end
    return playerJobKey == jobKey
end

local function canShowInteractionPoint(pointData, pointConfig, typeDef, pointType)
    if pointType == "duty_terminal" then
        if not IS_DUTY_SYSTEM_ENABLED then return false end
    end

    if isTable(typeDef) then return true end
    if checkJobMatches(pointData) then
        if not isDutyInteractionAllowed(pointConfig, pointType) then
            return false
        end
    end

    if checkInteractionNPCConfig(pointType, typeDef) then
        return true
    end

    if checkJobMatches(pointData) then return true end

    if pointType == "duty_terminal" then
        return isJobDutyStateActive(pointData)
    end

    return false
end

local function dummyAlwaysTrue(val) return true end

local function setCreatorInputFocused(focused)
    if not creatorUiState.active then return end
    if creatorUiState.inputFocused == focused then return end

    creatorUiState.inputFocused = focused
    if focused then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
    else
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(true)
    end
end

local function cleanupCreatorPoints(creatorKey, keepPeds)
    local preservedPeds = {}

    local points = activeInteractionPoints[creatorKey]
    if points then
        for pointIdKey in pairs(points) do
            if keepPeds then
                local res = Sky.DeleteInteractionPoint(pointIdKey, true)
                if res then preservedPeds[pointIdKey] = res end
                spawnedPedsEntityMap[pointIdKey] = nil
            else
                Sky.DeleteInteractionPoint(pointIdKey)
                spawnedPedsEntityMap[pointIdKey] = nil
            end
        end
        activeInteractionPoints[creatorKey] = nil
    end

    local peds = activeSpawnedPedsMap[creatorKey]
    if peds then
        for pointIdKey, pedObj in pairs(peds) do
            if pedObj and pedObj.entity and DoesEntityExist(pedObj.entity) then
                if keepPeds then
                    preservedPeds[pointIdKey] = pedObj.entity
                    spawnedPedsEntityMap[pointIdKey] = nil
                else
                    Sky.Ped.Delete(pedObj.entity)
                    spawnedPedsEntityMap[pointIdKey] = nil
                end
            end
        end
        activeSpawnedPedsMap[creatorKey] = nil
    end

    local blips = activeBlipsMap[creatorKey]
    if blips then
        for _, b in pairs(blips) do
            if b and DoesBlipExist(b) then
                RemoveBlip(b)
            end
        end
        activeBlipsMap[creatorKey] = nil
    end

    return preservedPeds
end

local function getPointIdKey(creatorKey, entryId, pointUid)
    return string.format("sky_jobs_base:creator:%s:%s:%s", creatorKey, entryId, tostring(pointUid or ""))
end

local function createStationBlip(creatorKey, entryData, pointCoords, creatorConfig)
    local blipCfg = {}
    for k, v in pairs(Config.StationBlip or {}) do blipCfg[k] = v end

    local customStationBlip = creatorConfig and creatorConfig.stationBlip
    if type(customStationBlip) == "table" then
        for k, v in pairs(customStationBlip) do blipCfg[k] = v end
    end

    local jobKey = sanitizeStringKey(entryData and entryData.jobKey)
    local jobStationBlips = creatorConfig and creatorConfig.jobStationBlips
    local specJobBlip = (jobKey and type(jobStationBlips) == "table") and jobStationBlips[jobKey] or nil

    if type(specJobBlip) == "table" then
        for k, v in pairs(specJobBlip) do blipCfg[k] = v end
    end

    local entryBlip = entryData and entryData.stationBlip
    if type(entryBlip) == "table" then
        for k, v in pairs(entryBlip) do blipCfg[k] = v end
    end

    if blipCfg.enabled == false then return end

    local blip = AddBlipForCoord(pointCoords.x, pointCoords.y, pointCoords.z)
    SetBlipSprite(blip, tonumber(blipCfg.sprite) or 1)
    SetBlipDisplay(blip, tonumber(blipCfg.display) or 4)
    SetBlipScale(blip, tonumber(blipCfg.scale) or 0.9)
    SetBlipColour(blip, tonumber(blipCfg.color) or 3)
    SetBlipAsShortRange(blip, blipCfg.shortRange ~= false)

    local entryName = entryData and entryData.name
    local categoryLabel = creatorConfig and creatorConfig.stationBlipCategoryLabel
    if type(specJobBlip) == "table" and type(specJobBlip.name) == "string" and specJobBlip.name ~= "" then
        categoryLabel = specJobBlip.name
    end

    local labelText = blipCfg.name or "Station"
    if categoryLabel and categoryLabel ~= "" then
        if blipCfg.useStationName ~= false and entryName and entryName ~= "" then
            labelText = string.format("%s - %s", categoryLabel, entryName)
        else
            labelText = categoryLabel
        end
    else
        if blipCfg.useStationName ~= false and entryName and entryName ~= "" then
            labelText = entryName
        end
    end

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(labelText)
    EndTextCommandSetBlipName(blip)

    activeBlipsMap[creatorKey] = activeBlipsMap[creatorKey] or {}
    local pointKey = getPointIdKey(creatorKey, entryData.id, pointCoords.uid)
    activeBlipsMap[creatorKey][pointKey] = blip
end

local function findStationPositionPoint(entryData, targetType)
    if not (entryData and type(entryData.points) == "table") then return nil end

    local posPoint = nil
    local firstPoint = nil

    for _, pt in ipairs(entryData.points) do
        if pt and pt.x and pt.y and pt.z then
            if pt.type == targetType then return pt end
            if not posPoint then
                if pt.type == "position" or pt.type == "station" or pt.type == "station_position" then
                    posPoint = pt
                end
            end
            if not firstPoint then firstPoint = pt end
        end
    end
    return posPoint or firstPoint
end

local function parsePointIdKey(pointIdKey)
    if type(pointIdKey) ~= "string" or pointIdKey == "" then return nil, nil, nil end
    return pointIdKey:match("^sky_jobs_base:creator:([^:]+):([^:]+):(.+)$")
end

local function findEntryById(creatorData, entryId)
    if not (creatorData and type(creatorData.entries) == "table" and entryId ~= nil) then return nil end
    local strId = tostring(entryId)
    for _, e in ipairs(creatorData.entries) do
        if e and e.id ~= nil and tostring(e.id) == strId then
            return e
        end
    end
    return nil
end

local function findPointByUid(entryData, pointUid)
    if not (entryData and type(entryData.points) == "table" and pointUid) then return nil end
    local strUid = tostring(pointUid)
    for _, pt in ipairs(entryData.points) do
        if pt and pt.uid ~= nil and tostring(pt.uid) == strUid then
            return pt
        end
    end
    return nil
end

local function ensureTableOrEmpty(tbl)
    if not hasInteractionToggleEnabled(tbl) then return {} end
    return tbl
end

local function calculateDrawDistance(typeDef, interactionDist)
    local drawDist = tonumber(typeDef and typeDef.drawDistance)
    if not drawDist or drawDist <= 0.0 then return nil end

    local baseDist = tonumber(interactionDist) or tonumber(Sky.Config.interactionDistance) or 2.0
    local buffer = tonumber(Sky.Config.interactionDrawBuffer) or 5.0

    if drawDist < (baseDist + buffer) then return nil end
    return drawDist
end

local function normalizePointTypeName(typeName)
    if type(typeName) ~= "string" then return typeName end
    local lower = typeName:lower():gsub("%s+", "_"):gsub("-", "_"):gsub("_+", "_")
    return lower
end

local function getTypeDefinition(creatorData, pointType)
    if not (creatorData and creatorData.typeDefinitions and pointType) then return nil end
    return creatorData.typeDefinitions[pointType] or creatorData.typeDefinitions[normalizePointTypeName(pointType)]
end

local function spawnSingleInteraction(creatorKey, entryData, pointData, typeDef, isNpcOnly, preservedPedsMap, creatorConfig)
    if not (pointData and pointData.x and pointData.y and pointData.z) then return nil end

    if typeDef and typeDef.interaction == false and not isNpcOnly then
        return nil
    end

    local coordsVec = vector3(pointData.x, pointData.y, pointData.z)
    local pointIdKey = getPointIdKey(creatorKey, entryData.id, pointData.uid)

    if isNpcOnly then
        local npcCfg = typeDef and typeDef.npc
        if not (npcCfg and hasInteractionToggleEnabled(npcCfg) and npcCfg.pedHash) then return nil end

        local existingPed = preservedPedsMap and preservedPedsMap[pointIdKey]
        if existingPed and DoesEntityExist(existingPed) then
            local heading = tonumber(pointData.heading) or npcCfg.heading or 0.0
            local pedObj = Sky.Ped:new()
            pedObj.entity = existingPed
            pedObj:SetCoords(coordsVec, heading)
            pedObj:Freeze()

            activeSpawnedPedsMap[creatorKey] = activeSpawnedPedsMap[creatorKey] or {}
            activeSpawnedPedsMap[creatorKey][pointIdKey] = pedObj
            preservedPedsMap[pointIdKey] = nil

            if npcCfg.scenario then
                TaskStartScenarioInPlace(existingPed, npcCfg.scenario, 0, true)
            end

            if type(npcCfg.onSpawn) == "function" then
                npcCfg.onSpawn(existingPed)
            end

            triggerPedSpawnedHook(creatorKey, pointData.type, pointIdKey, existingPed)
            return pointIdKey
        end

        local heading = tonumber(pointData.heading) or npcCfg.heading or 0.0
        local pedObj = Sky.Ped:new()
        pedObj:Spawn(npcCfg.pedHash, coordsVec, heading, {
            scenario = npcCfg.scenario,
            onSpawn = npcCfg.onSpawn,
            spawnProfile = "interaction"
        })
        pedObj:Freeze()

        activeSpawnedPedsMap[creatorKey] = activeSpawnedPedsMap[creatorKey] or {}
        activeSpawnedPedsMap[creatorKey][pointIdKey] = pedObj

        triggerPedSpawnedHook(creatorKey, pointData.type, pointIdKey, pedObj.entity)
        return pointIdKey
    end

    local normalizedType = normalizePointTypeName(pointData.type)
    local label = typeDef and typeDef.label or pointData.label
    local labelKey = typeDef and typeDef.labelKey or pointData.labelKey
    local labelFallback = typeDef and typeDef.labelFallback

    local systemLabels = Locales and Locales[localeKey] and Locales[localeKey].InteractionLabels or {}
    local fallbackLabels = Locales and Locales.en and Locales.en.InteractionLabels or {}

    local resolvedLabel = label or getNestedProperty(Locales[localeKey], labelKey) or getNestedProperty(Locales.en, labelKey)
        or systemLabels[pointData.type] or systemLabels[normalizedType]
        or fallbackLabels[pointData.type] or fallbackLabels[normalizedType]
        or labelFallback or pointData.type

    local stationName = entryData.name or ""
    local interactionName = stationName
    if resolvedLabel and resolvedLabel ~= "" then
        interactionName = string.format("%s - %s", stationName, resolvedLabel)
    end

    local markerCfg = ensureTableOrEmpty(typeDef and typeDef.marker)
    local npcCfg = ensureTableOrEmpty(typeDef and typeDef.npc)

    if next(npcCfg) ~= nil and not npcCfg.pedHash then
        print(string.format("[sky_jobs_base][creator] %s/%s: npc enabled but pedHash missing, skipping ped", tostring(creatorKey), tostring(pointData.type)))
        npcCfg = {}
    end

    if next(npcCfg) ~= nil and pointData then
        if pointData.heading ~= nil then
            npcCfg.heading = tonumber(pointData.heading)
        end
    end

    local blipCfg = ensureTableOrEmpty(typeDef and typeDef.blip)
    if type(pointData.blip) == "table" then
        if next(pointData.blip) == nil then
            blipCfg = {}
        else
            blipCfg = deepCopyTable(blipCfg)
            for k, v in pairs(pointData.blip) do blipCfg[k] = v end
            blipCfg = ensureTableOrEmpty(blipCfg)
        end
    end

    if activeInteractionPoints[creatorKey] and activeInteractionPoints[creatorKey][pointIdKey] then
        Sky.DeleteInteractionPoint(pointIdKey)
    end

    if markerCfg and next(markerCfg) ~= nil then
        if typeDef and typeDef.markerSize ~= nil then
            markerCfg.markerSize = tonumber(typeDef.markerSize)
        end
    elseif pointData.type ~= "lift" and pointData.type ~= "engine_swap" then
        markerCfg = { type = 1, scaleX = 1.0, scaleY = 1.0, scaleZ = 0.5, alpha = 100 }
    end

    if markerCfg and next(markerCfg) ~= nil then
        markerCfg.type = tonumber(markerCfg.type) or 1
        markerCfg.scaleX = tonumber(markerCfg.scaleX) or tonumber(markerCfg.markerSize) or tonumber(markerCfg.size) or tonumber(markerCfg.scale) or (Config and Config.defaultMarkerSize) or 1.0
        markerCfg.scaleY = tonumber(markerCfg.scaleY) or tonumber(markerCfg.markerSize) or tonumber(markerCfg.size) or tonumber(markerCfg.scale) or (Config and Config.defaultMarkerSize) or 1.0
        markerCfg.scaleZ = tonumber(markerCfg.scaleZ) or 0.5
        markerCfg.alpha = tonumber(markerCfg.alpha) or 100

        if markerCfg.scaleX <= 0.0 then markerCfg.scaleX = (Config and Config.defaultMarkerSize) or 1.0 end
        if markerCfg.scaleY <= 0.0 then markerCfg.scaleY = (Config and Config.defaultMarkerSize) or 1.0 end
        if markerCfg.scaleZ <= 0.0 then markerCfg.scaleZ = 0.5 end
        if markerCfg.alpha <= 0 then markerCfg.alpha = 100 end
    end

    local parkRadius = (Config and Config.JobGarage and Config.JobGarage.parkRadius) or 4.0
    local isParkZone = pointData.type == "garage_vehicle_park"

    if isParkZone then
        markerCfg.scaleX = tonumber(markerCfg.scaleX) or parkRadius
        markerCfg.scaleY = tonumber(markerCfg.scaleY) or parkRadius
    end

    local interactionDist = typeDef and typeDef.interactionDistance
    if isParkZone then interactionDist = parkRadius end

    local drawDist = calculateDrawDistance(typeDef, interactionDist)
    local targetCoords = coordsVec

    if isParkZone then
        targetCoords = {
            x = coordsVec.x,
            y = coordsVec.y,
            z = coordsVec.z,
            requireVehicle = true
        }
    end

    local existingPed = preservedPedsMap and preservedPedsMap[pointIdKey]
    if existingPed and DoesEntityExist(existingPed) then
        SetEntityCoords(existingPed, coordsVec.x, coordsVec.y, coordsVec.z, false, false, false, true)
        local h = npcCfg and npcCfg.heading or tonumber(pointData.heading)
        if h then SetEntityHeading(existingPed, h) end
        preservedPedsMap[pointIdKey] = nil
    else
        existingPed = nil
    end

    local ownerResource = creatorConfig or GetCurrentResourceName()

    Sky.CreateInteractionPoint(
        targetCoords,
        interactionName,
        "sky_jobs_base:creator:point",
        pointIdKey,
        markerCfg,
        npcCfg,
        blipCfg,
        ownerResource,
        interactionDist,
        existingPed,
        function(triggeredPed)
            triggerPedSpawnedHook(creatorKey, pointData.type, pointIdKey, triggeredPed)
        end,
        {
            forceMarkerInteraction = (typeDef and typeDef.forceMarkerInteraction == true),
            drawDistance = drawDist
        }
    )

    activeInteractionPoints[creatorKey] = activeInteractionPoints[creatorKey] or {}
    activeInteractionPoints[creatorKey][pointIdKey] = true
    return pointIdKey
end

local function rebuildCreatorInteractions(creatorKey)
    local preservedPeds = cleanupCreatorPoints(creatorKey, true)

    local creatorData = cachedCreatorsData[creatorKey]
    if not (creatorData and type(creatorData.entries) == "table") then
        for _, pedEntity in pairs(preservedPeds) do
            if DoesEntityExist(pedEntity) then
                Sky.Ped.Delete(pedEntity)
            end
        end
        return
    end

    local posPointType = (creatorData.creator and creatorData.creator.positionPointType) or "position"
    cacheLocationDefinitions(creatorData)

    for _, entry in ipairs(creatorData.entries) do
        local posPt = findStationPositionPoint(entry, posPointType)
        if posPt then
            createStationBlip(creatorKey, entry, posPt, creatorData.creator)
        end

        if type(entry.points) == "table" then
            for _, pt in ipairs(entry.points) do
                if pt and pt.x and pt.y and pt.z then
                    local typeDef = getTypeDefinition(creatorData, pt.type)
                    if pt.stationBlipOnly ~= true then
                        if canShowInteractionPoint(entry, pt, typeDef, pt.type) then
                            local ok, err = pcall(spawnSingleInteraction, creatorKey, entry, pt, typeDef, false, preservedPeds, creatorData)
                            if not ok then
                                print(string.format("[sky_jobs_base][creator] spawnInteraction failed for %s/%s/%s: %s", tostring(creatorKey), tostring(entry.id), tostring(pt.type), tostring(err)))
                            end
                        elseif checkInteractionNPCConfig(pt.type, typeDef) then
                            pcall(spawnSingleInteraction, creatorKey, entry, pt, typeDef, true, preservedPeds, creatorData)
                        end
                    end
                end
            end
        end
    end

    for pointIdKey, pedEntity in pairs(preservedPeds) do
        if DoesEntityExist(pedEntity) then
            Sky.Ped.Delete(pedEntity)
        end
        spawnedPedsEntityMap[pointIdKey] = nil
    end
end

function rebuildAllInteractions()
    for creatorKey in pairs(cachedCreatorsData) do
        rebuildCreatorInteractions(creatorKey)
    end
end

local function openCreatorUI(creatorKey, entryId, creatorData)
    if not creatorData then
        creatorData = cachedCreatorsData[creatorKey]
    end

    if not creatorData then
        local res = Sky.Cb.Trigger("sky_jobs_base:creator:getData", { creatorKey = creatorKey })
        if res and res.success and res.data then
            creatorData = res.data
            cachedCreatorsData[creatorKey] = creatorData
            rebuildCreatorInteractions(creatorKey)
        end
    end

    if not creatorData then return end

    creatorUiState.active = true
    creatorUiState.key = creatorKey
    creatorUiState.entryId = entryId
    creatorUiState.currentView = nil

    setSelectedJobKey(nil)
    SetNuiFocusKeepInput(true)

    SendNUIMessage({
        type = "creator:open",
        data = creatorData,
        creatorKey = creatorKey,
        entryId = entryId
    })
end

local function closeCreatorUI()
    if not creatorUiState.active then return end

    creatorUiState.active = false
    creatorUiState.inputFocused = false
    creatorUiState.currentView = nil
    creatorUiState.key = nil
    creatorUiState.entryId = nil

    setSelectedJobKey(nil)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({ type = "creator:close" })
end

local function extractFirstNonNilParam(...)
    local args = { ... }
    for _, arg in ipairs(args) do
        if type(arg) == "table" then return arg end
    end
    for _, arg in ipairs(args) do
        if type(arg) == "string" then return arg end
    end
    return nil
end

local function resolvePointContext(param)
    local creatorKey, entryId, pointUid, pointType, pointIdKey

    if type(param) == "table" then
        pointIdKey = param.pointId or param.id or param.point
        creatorKey = param.creatorKey
        entryId = param.entryId
        pointUid = param.pointUid or param.uid
        pointType = param.type or param.pointType
    elseif type(param) == "string" then
        pointIdKey = param
    end

    if pointIdKey and ((not creatorKey or not entryId) or not pointUid) then
        local cKey, eId, pUid = parsePointIdKey(pointIdKey)
        creatorKey = creatorKey or cKey
        entryId = entryId or eId
        pointUid = pointUid or pUid
    end

    if not creatorKey then return nil end

    local creatorData = cachedCreatorsData[creatorKey]
    local entryData = creatorData and findEntryById(creatorData, entryId)
    local pointData = entryData and findPointByUid(entryData, pointUid)

    if not pointType and pointData then
        pointType = pointData.type
    end

    local typeDef = getTypeDefinition(creatorData, pointType)
    return {
        creatorKey = creatorKey,
        entryId = entryId,
        pointUid = pointUid,
        pointType = pointType,
        entry = entryData,
        point = pointData,
        definition = typeDef
    }
end

local function getNormalizedTypeKey(pointType)
    local norm = normalizePointTypeName(pointType)
    if norm == "bossmenu" or norm == "management" then return "boss_menu" end
    if norm == "tuning" then return "self_service_tuning" end
    return norm
end

local function getInteractionJobKey(ctx)
    if not ctx then return nil end

    if ctx.entry and ctx.entry.jobKey then
        return sanitizeStringKey(ctx.entry.jobKey)
    end

    local creatorData = cachedCreatorsData[ctx.creatorKey]
    local creatorCfg = creatorData and creatorData.creator
    if creatorCfg and creatorCfg.jobKey then
        return sanitizeStringKey(creatorCfg.jobKey)
    end

    return nil
end

local function triggerGenericInteractionEvent(ctx)
    local jobKey = getInteractionJobKey(ctx) or ctx.creatorKey
    if not (jobKey and ctx and ctx.pointType) then return end

    local eventName = string.format("sky_jobs_base:interaction:%s:%s", jobKey, ctx.pointType)
    TriggerEvent(eventName, {
        interactionId = ctx.pointUid,
        id = ctx.pointUid,
        uid = ctx.pointUid,
        key = ctx.pointUid,
        creatorKey = ctx.creatorKey,
        entryId = ctx.entryId,
        pointUid = ctx.pointUid,
        pointType = ctx.pointType,
        entry = ctx.entry,
        point = ctx.point,
        definition = ctx.definition
    })
end

local function handleInteractionPointTrigger(...)
    local rawArg = extractFirstNonNilParam(...)
    local ctx = resolvePointContext(rawArg)

    if not (ctx and ctx.pointType) then return end

    local jobKey = ctx.entry and sanitizeStringKey(ctx.entry.jobKey)
    if jobKey then
        if not isTable(ctx.definition) then
            if not isJobActiveForCreator(jobKey) then return end
        end
    end

    local normalizedPointType = getNormalizedTypeKey(ctx.pointType)
    if normalizedPointType ~= ctx.pointType then
        ctx.pointType = normalizedPointType
        local cData = cachedCreatorsData[ctx.creatorKey]
        if cData and cData.typeDefinitions then
            ctx.definition = cData.typeDefinitions[normalizedPointType] or ctx.definition
        end
    end

    if jobKey then
        if not isTable(ctx.definition) then
            if not isDutyInteractionAllowed(ctx.point, ctx.pointType) then return end
        end
    end

    if ctx.pointType == "duty_terminal" then
        if not IS_DUTY_SYSTEM_ENABLED then return end

        local terminalLabel = (ctx.entry and ctx.entry.name)
            or (ctx.definition and (ctx.definition.label or ctx.definition.labelFallback))
            or "Duty Terminal"

        TriggerEvent("sky_jobs_base:duty:open", terminalLabel)

    elseif ctx.pointType == "wardrobe" then
        TriggerEvent("sky_jobs_base:wardrobe:interaction",
            ctx.pointUid or ctx.entryId,
            ctx.point,
            {
                jobName = getInteractionJobKey(ctx),
                creatorKey = ctx.creatorKey,
                entryId = ctx.entryId,
                pointUid = ctx.pointUid
            }
        )

    elseif ctx.pointType == "storage" or ctx.pointType == "locker" then
        TriggerEvent("sky_jobs_base:storageInteraction", {
            stationId = (ctx.entry and ctx.entry.id) or ctx.entryId,
            slot = ctx.pointType,
            label = ctx.entry and ctx.entry.name
        })

    elseif ctx.pointType == "job_garage" or ctx.pointType == "garage_vehicle_menu" or ctx.pointType == "garage_helicopter_menu" or ctx.pointType == "garage_boat_menu" then
        local gType = "vehicle"
        if ctx.pointType == "garage_helicopter_menu" then
            gType = "helicopter"
        elseif ctx.pointType == "garage_boat_menu" then
            gType = "boat"
        end

        local garageId = string.format("creator:%s:%s:%s", ctx.creatorKey, ctx.entryId, gType)
        TriggerEvent("sky_jobs_base:garageInteraction", {
            garageId = garageId,
            garageType = gType
        })

    elseif ctx.pointType == "boss_menu" then
        TriggerEvent("sky_jobs_base:bossMenuInteraction", ctx.pointUid or ctx.entryId, ctx.point)

    elseif ctx.pointType == "garage_vehicle_park" or ctx.pointType == "garage_helicopter_park" or ctx.pointType == "garage_boat_park" then
        local gType = "vehicle"
        if ctx.pointType == "garage_helicopter_park" then
            gType = "helicopter"
        elseif ctx.pointType == "garage_boat_park" then
            gType = "boat"
        end

        local garageId = string.format("creator:%s:%s:%s", ctx.creatorKey, ctx.entryId, gType)
        TriggerEvent("sky_jobs_base:garageParkInteraction", {
            garageId = garageId,
            garageType = gType
        })

    elseif ctx.pointType == "wholesale_shop" then
        TriggerEvent("sky_jobs_base:wholesaleInteraction", {
            stationId = (ctx.entry and ctx.entry.id) or ctx.entryId,
            label = ctx.entry and ctx.entry.name
        })

    elseif ctx.pointType == "public_forms" then
        TriggerEvent("sky_jobs_base:publicFormsInteraction", {
            stationId = (ctx.entry and ctx.entry.id) or ctx.entryId,
            label = ctx.entry and ctx.entry.name,
            jobKey = ctx.entry and ctx.entry.jobKey
        })
    end

    triggerGenericInteractionEvent(ctx)
end

local function sendKeyboardActionToNUI(action, force)
    if not creatorUiState.active then return end
    if creatorUiState.inputFocused and not force then return end
    if not creatorUiState.currentView then return end

    SendNUIMessage({
        type = "creator/keyboard",
        action = action,
        view = creatorUiState.currentView
    })
end

local repeatStateMap = {
    moveUp = { active = false, nextFire = 0 },
    moveDown = { active = false, nextFire = 0 }
}

local function processRepeatableKey(controlKey, actionName, repeatKey)
    local now = GetGameTimer()
    if IsControlPressed(0, controlKey) then
        local rData = repeatStateMap[repeatKey]
        if not rData.active then
            sendKeyboardActionToNUI(actionName)
            rData.active = true
            rData.nextFire = now + 250
        elseif now >= rData.nextFire then
            sendKeyboardActionToNUI(actionName)
            rData.nextFire = now + 80
        end
    else
        local rData = repeatStateMap[repeatKey]
        rData.active = false
        rData.nextFire = 0
    end
end

RegisterNetEvent("sky_jobs_base:creatorUpdated", function(creatorKey, creatorData)
    if type(creatorKey) ~= "string" or not creatorData then return end
    cachedCreatorsData[creatorKey] = creatorData
    triggerDebouncedRebuild()
end)

RegisterNetEvent("sky_jobs_base:creator:open", function(creatorKey, entryId)
    openCreatorUI(creatorKey, entryId)
end)

RegisterNetEvent("sky_jobs_base:creator:point", function(...)
    handleInteractionPointTrigger(...)
end)

RegisterNetEvent("sky_jobs_base:managementAccessChanged", function()
    triggerDebouncedRebuild()
end)

RegisterNetEvent("sky_jobs_base:creator:updatePlayerJob", function(jobKey)
    updatePlayerJob(jobKey)
end)

RegisterNetEvent("sky_jobs_base:creator:updatePlayerDuty", function(onDutyState)
    updatePlayerDuty(onDutyState)
end)

RegisterNetEvent("sky_jobs_base:jobs:registered", function()
    if playerDutyLoaded then
        updatePlayerJob(playerJobKey)
    end
end)

local function handleCreatorKeyboardInputs()
    if not creatorUiState.active then return end
    if isPlacementActive then return end

    if creatorUiState.inputFocused then
        if IsControlJustReleased(0, 201) then -- Enter
            sendKeyboardActionToNUI("confirm", true)
        end
        if IsControlJustReleased(0, 177) or IsControlJustReleased(0, 202) then -- Backspace / ESC
            sendKeyboardActionToNUI("back", true)
        end
        return
    end

    processRepeatableKey(172, "moveUp", "moveUp")
    processRepeatableKey(173, "moveDown", "moveDown")

    if IsControlJustReleased(0, 174) then sendKeyboardActionToNUI("moveLeft", false) end
    if IsControlJustReleased(0, 175) then sendKeyboardActionToNUI("moveRight", false) end
    if IsControlJustReleased(0, 201) then sendKeyboardActionToNUI("confirm", false) end

    if IsControlJustReleased(0, 177) or IsControlJustReleased(0, 202) then
        sendKeyboardActionToNUI("back", false)
    end

    if IsControlJustReleased(0, 37) then sendKeyboardActionToNUI("focusHeader", false) end
end

local function getPlayerCoordsAndHeading()
    local ped = PlayerPedId()
    if not (ped and ped ~= 0) then return nil end

    local coords = GetEntityCoords(ped)
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z - 1.0,
        heading = GetEntityHeading(ped)
    }
end

local registeredSetPointHandlers = {}

local function triggerCustomSetPointHandlers(data)
    for hName, handler in pairs(registeredSetPointHandlers) do
        local ok, res = pcall(handler, data)
        if not ok then
            print(string.format("[sky_jobs_base][creator] custom setPoint handler failed (%s): %s", tostring(hName), tostring(res)))
        elseif type(res) == "table" and res.handled == true then
            return res
        end
    end
    return nil
end

registerExport("registerSetPointHandler", function(name, fn)
    if type(name) ~= "string" or name == "" or type(fn) ~= "function" then return false end
    registeredSetPointHandlers[name] = fn
    return true
end)

registerExport("unregisterSetPointHandler", function(name)
    if type(name) ~= "string" or name == "" then return false end
    registeredSetPointHandlers[name] = nil
    return true
end)

local function playFrontendUiSound(soundType)
    if soundType == "select" then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    else
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
end

local function getWardrobeUnsupportedMsg(frameworkName)
    local msg = locales.WardrobeUnsupportedFramework or fallbackLocales.WardrobeUnsupportedFramework or "Wardrobe does not work with the selected framework ({framework})."
    return msg:gsub("{framework}", tostring(frameworkName or "unknown"))
end

local function isResourceActive(resName)
    return type(resName) == "string" and GetResourceState(resName) == "started"
end

local function getActiveFrameworkName()
    local fw = (Sky and Sky.Config and Sky.Config.framework) or "unknown"
    return tostring(fw):lower()
end

local function getCloakroomConfig()
    return (Config and type(Config.Cloakroom) == "table") and Config.Cloakroom or {}
end

local function getCloakroomBackendName()
    local cfg = getCloakroomConfig()
    local backend = cfg.backend or cfg.Backend or "auto"
    return tostring(backend):lower()
end

local function getCustomCloakroomHandler()
    local cfg = getCloakroomConfig()
    if type(cfg.custom) == "table" then return cfg.custom end
    if type(cfg.Custom) == "table" then return cfg.Custom end
    return nil
end

local function isCustomCloakroomAvailable()
    local custom = getCustomCloakroomHandler()
    if not (custom and type(custom.open) == "function") then return false end

    if type(custom.resource) == "string" and custom.resource ~= "" then
        if not isResourceActive(custom.resource) then return false end
    end

    if type(custom.isAvailable) == "function" then
        local ok, res = pcall(custom.isAvailable, {
            framework = getActiveFrameworkName(),
            backend = getCloakroomBackendName()
        })
        return ok and res == true
    end
    return true
end

local function validateWardrobeIntegration()
    local backend = getCloakroomBackendName()

    if backend == "disabled" then
        local msg = locales.WardrobeDisabled or fallbackLocales.WardrobeDisabled or "Wardrobe is disabled in the config."
        return false, msg
    end

    if backend == "auto" or backend == "rcore" then
        if isResourceActive("rcore_clothing") then return true end
    end

    if backend == "rcore" then
        local msg = locales.WardrobeMissingRcoreClothing or fallbackLocales.WardrobeMissingRcoreClothing or "Wardrobe requires rcore_clothing to be started."
        return false, msg
    end

    local fw = getActiveFrameworkName()

    if backend == "custom" then
        if isCustomCloakroomAvailable() then return true end
        local msg = locales.WardrobeCustomUnavailable or fallbackLocales.WardrobeCustomUnavailable or "The configured custom wardrobe integration is not available."
        return false, msg
    end

    if backend == "auto" and isCustomCloakroomAvailable() then return true end

    if backend == "auto" or backend == "17movement" then
        if isResourceActive("17mov_CharacterSystem") and (fw == "esx" or fw == "qb" or fw == "qbox") then return true end
    end

    if backend == "17movement" then
        local msg = locales.WardrobeMissing17Movement or fallbackLocales.WardrobeMissing17Movement or "Wardrobe requires 17mov_CharacterSystem to be started."
        return false, msg
    end

    if backend == "qs-appearance" or backend == "qs" then
        if isResourceActive("qs-appearance") then return true end
        local msg = locales.WardrobeMissingQsAppearance or fallbackLocales.WardrobeMissingQsAppearance or "Wardrobe requires qs-appearance to be started."
        return false, msg
    end

    if backend == "auto" and isResourceActive("qs-appearance") then return true end

    if backend == "ak47-clothing" or backend == "ak47" then
        if isResourceActive("ak47_clothing") then return true end
        local msg = locales.WardrobeMissingAk47Clothing or fallbackLocales.WardrobeMissingAk47Clothing or "Wardrobe requires ak47_clothing to be started."
        return false, msg
    end

    if backend == "auto" and isResourceActive("ak47_clothing") then return true end

    if backend == "ak47-qb-clothing" or backend == "ak47-qb" then
        if isResourceActive("ak47_qb_clothing") then return true end
        local msg = locales.WardrobeMissingAk47QbClothing or fallbackLocales.WardrobeMissingAk47QbClothing or "Wardrobe requires ak47_qb_clothing to be started."
        return false, msg
    end

    if backend == "auto" and isResourceActive("ak47_qb_clothing") then return true end

    if backend == "tgiann-clothing" or backend == "tgiann" then
        if isResourceActive("tgiann-clothing") then return true end
        local msg = locales.WardrobeMissingTgiannClothing or fallbackLocales.WardrobeMissingTgiannClothing or "Wardrobe requires tgiann-clothing to be started."
        return false, msg
    end

    if backend == "auto" and isResourceActive("tgiann-clothing") then return true end

    if backend == "nf-skin" or backend == "nf" then
        if isResourceActive("nf-skin") then return true end
        local msg = locales.WardrobeMissingNfSkin or fallbackLocales.WardrobeMissingNfSkin or "Wardrobe requires nf-skin to be started."
        return false, msg
    end

    if backend == "auto" and isResourceActive("nf-skin") then return true end

    if backend == "bl-appearance" or backend == "bl_appearance" or backend == "bl" then
        if isResourceActive("bl_appearance") then return true end
        local msg = locales.WardrobeMissingBlAppearance or fallbackLocales.WardrobeMissingBlAppearance or "Wardrobe requires bl_appearance to be started."
        return false, msg
    end

    if backend == "auto" and isResourceActive("bl_appearance") then return true end

    if backend == "izzy-appearance" or backend == "izzy" then
        if isResourceActive("izzy-appearance") then return true end
        local msg = locales.WardrobeMissingIzzyAppearance or fallbackLocales.WardrobeMissingIzzyAppearance or "Wardrobe requires izzy-appearance to be started."
        return false, msg
    end

    if backend == "auto" and isResourceActive("izzy-appearance") then return true end

    if backend == "codem-appearance" or backend == "codem" then
        if isResourceActive("codem-appearance") then return true end
        local msg = locales.WardrobeMissingCodemAppearance or fallbackLocales.WardrobeMissingCodemAppearance or "Wardrobe requires codem-appearance to be started."
        return false, msg
    end

    if backend == "auto" and isResourceActive("codem-appearance") then return true end

    if backend == "hex-clothing" or backend == "hex_clothing" or backend == "hex" then
        if isResourceActive("hex_clothing") then return true end
        local msg = locales.WardrobeMissingHexClothing or fallbackLocales.WardrobeMissingHexClothing or "Wardrobe requires hex_clothing to be started."
        return false, msg
    end

    if backend == "auto" and isResourceActive("hex_clothing") then return true end

    if backend == "illenium" then
        if isResourceActive("illenium-appearance") then return true end
        local msg = locales.WardrobeMissingIllenium or fallbackLocales.WardrobeMissingIllenium or "Wardrobe requires illenium-appearance to be started."
        return false, msg
    end

    if backend == "auto" and isResourceActive("illenium-appearance") then return true end

    if backend == "qb-clothing" then
        if isResourceActive("qb-clothing") then return true end
        local template = locales.WardrobeMissingQbClothing or fallbackLocales.WardrobeMissingQbClothing or "Wardrobe requires qb-clothing to be started on {framework}."
        return false, template:gsub("{framework}", fw)
    end

    if backend == "sky" and fw ~= "esx" then
        return false, getWardrobeUnsupportedMsg(fw)
    end

    if fw == "esx" then
        if isResourceActive("skinchanger") and isResourceActive("esx_skin") then return true end
        if not isResourceActive("esx_skin") then
            local msg = locales.WardrobeMissingEsxSkin or fallbackLocales.WardrobeMissingEsxSkin or "Wardrobe requires esx_skin to be started on ESX."
            return false, msg
        end
        local msg = locales.WardrobeMissingSkinchanger or fallbackLocales.WardrobeMissingSkinchanger or "Wardrobe requires skinchanger to be started on ESX."
        return false, msg
    end

    if backend == "auto" and (fw == "qb" or fw == "qbox") then
        if isResourceActive("qb-clothing") then return true end
        local template = locales.WardrobeMissingQbClothing or fallbackLocales.WardrobeMissingQbClothing or "Wardrobe requires qb-clothing to be started on {framework}."
        return false, template:gsub("{framework}", fw)
    end

    return false, getWardrobeUnsupportedMsg(fw)
end

local function showWardrobeErrorNotification(errText)
    local title = locales.WardrobeTitle or fallbackLocales.WardrobeTitle or "Wardrobe"
    local msg = errText or getWardrobeUnsupportedMsg(Sky and Sky.Config and Sky.Config.framework)
    Sky.Show.Notification(title, msg, "error")
end

local function isWardrobePointType(pointData, ctx)
    local pType = (ctx and ctx.pointType) or (pointData and (pointData.type or pointData.pointType))
    return getNormalizedTypeKey(pType) == "wardrobe"
end

RegisterNUICallback("creator/getData", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:creator:getData", data or {})
    cb(res or { success = false })
end)

RegisterNUICallback("creator/createEntry", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:creator:createEntry", data or {})
    cb(res or { success = false })
end)

RegisterNUICallback("creator/renameEntry", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:creator:renameEntry", data or {})
    cb(res or { success = false })
end)

RegisterNUICallback("creator/deleteEntry", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:creator:deleteEntry", data or {})
    cb(res or { success = false })
end)

RegisterNUICallback("creator/setPoint", function(data, cb)
    data = data or {}
    local ctx = resolvePointContext(data)

    if not (ctx and ctx.definition) and type(data.creatorKey) == "string" and data.creatorKey ~= "" then
        local res = Sky.Cb.Trigger("sky_jobs_base:creator:getData", { creatorKey = data.creatorKey })
        if res and res.success and type(res.data) == "table" then
            cachedCreatorsData[data.creatorKey] = res.data
            triggerDebouncedRebuild()
            ctx = resolvePointContext(data)
        end
    end

    if isWardrobePointType(data, ctx) then
        local ok, errText = validateWardrobeIntegration()
        if not ok then
            showWardrobeErrorNotification(errText)
            cb({ success = false, error = "wardrobe_unsupported_framework" })
            return
        end
    end

    local typeDef = ctx and ctx.definition
    local propModel = typeDef and typeDef.placementModel

    if type(propModel) == "string" and propModel ~= "" then
        startPropPlacement(propModel, function(pRes)
            if not (pRes and pRes.success and type(pRes.coords) == "table") then
                cb({ success = false, error = (pRes and pRes.error) or "set_point_failed" })
                return
            end

            data.coords = pRes.coords
            local rpcRes = Sky.Cb.Trigger("sky_jobs_base:creator:setPoint", data)
            cb(rpcRes or { success = false })
        end)
        return
    end

    local customRes = triggerCustomSetPointHandlers(data)
    if customRes and customRes.handled then
        if customRes.success and type(customRes.coords) == "table" then
            data.coords = customRes.coords
        else
            cb({ success = false, error = customRes.error or "set_point_failed" })
            return
        end
    else
        local pCoords = getPlayerCoordsAndHeading()
        if not pCoords then
            cb({ success = false })
            return
        end
        data.coords = pCoords
    end

    local rpcRes = Sky.Cb.Trigger("sky_jobs_base:creator:setPoint", data)
    cb(rpcRes or { success = false })
end)

RegisterNUICallback("creator/setJobStationBlip", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:creator:setJobStationBlip", data or {})
    cb(res or { success = false })
end)

RegisterNUICallback("creator/clearPoint", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:creator:clearPoint", data or {})
    cb(res or { success = false })
end)

RegisterNUICallback("creator/removePoint", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:creator:removePoint", data or {})
    cb(res or { success = false })
end)

RegisterNUICallback("creator/addPoint", function(data, cb)
    data = data or {}
    if isWardrobePointType(data) then
        local ok, errText = validateWardrobeIntegration()
        if not ok then
            showWardrobeErrorNotification(errText)
            cb({ success = false, error = "wardrobe_unsupported_framework" })
            return
        end
    end

    local pCoords = getPlayerCoordsAndHeading()
    if not pCoords then
        cb({ success = false })
        return
    end

    data.coords = pCoords
    local res = Sky.Cb.Trigger("sky_jobs_base:creator:addPoint", data)
    cb(res or { success = false })
end)

RegisterNUICallback("creator/setView", function(data, cb)
    creatorUiState.currentView = data and data.view
    cb({ success = true })
end)

RegisterNUICallback("creator/playSound", function(data, cb)
    playFrontendUiSound(data and data.sound)
    cb({ success = true })
end)

RegisterNUICallback("creator/setInputFocus", function(data, cb)
    setCreatorInputFocused(data and data.focused == true)
    cb({ success = true })
end)

RegisterNUICallback("creator/setActiveJob", function(data, cb)
    setSelectedJobKey(data and data.jobKey)
    cb({ success = true })
end)

RegisterNUICallback("close", function(data, cb)
    closeCreatorUI()
    TriggerEvent("sky_jobs_base:multijob:close")
    TriggerEvent("sky_jobs_base:duty:close")
    TriggerEvent("sky_jobs_base:wardrobe:close")
    TriggerEvent("sky_jobs_base:garage:close")
    TriggerEvent("sky_jobs_base:management:close")
    TriggerEvent("sky_jobs_base:storage:close")
    TriggerEvent("sky_jobs_base:tablet:setOpenState", false)
    SetNuiFocus(false, false)
    cb({ success = true })
end)

RegisterNUICallback("creator/keyboard", function(data, cb)
    cb({ success = true })
end)

AddEventHandler("sky_jobs:nuiClosed", function()
    closeCreatorUI()
    TriggerEvent("sky_jobs_base:multijob:close")
    TriggerEvent("sky_jobs_base:duty:close")
    TriggerEvent("sky_jobs_base:wardrobe:close")
    TriggerEvent("sky_jobs_base:garage:close")
    TriggerEvent("sky_jobs_base:management:close")
    TriggerEvent("sky_jobs_base:storage:close")
end)

CreateThread(function()
    while true do
        if creatorUiState.active then
            handleCreatorKeyboardInputs()
            Wait(0)
        else
            Wait(250)
        end
    end
end)

CreateThread(function()
    while true do
        local ok, res = pcall(function()
            return Sky.Cb.TriggerWithTimeout("sky_jobs_base:creator:getPlayerJob", 10000, {})
        end)

        if ok and res and res.success and res.data and res.data.ready == true then
            updatePlayerJob(res.data.jobKey)
            break
        end
        Wait(2000)
    end
end)

CreateThread(function()
    while true do
        local ok, res = pcall(function()
            return Sky.Cb.TriggerWithTimeout("sky_jobs_base:creator:getPlayerDuty", 10000, {})
        end)

        if ok and res and res.success and res.data and res.data.ready == true then
            updatePlayerDuty(res.data.onDuty == true)
            break
        end
        Wait(2000)
    end
end)

CreateThread(function()
    Wait(1500)
    TriggerServerEvent("sky_jobs_base:creator:requestSync")
end)

AddEventHandler("onClientResourceStart", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    SetTimeout(500, function()
        TriggerServerEvent("sky_jobs_base:creator:requestSync")
    end)
end)

AddEventHandler("onClientResourceStop", function(resName)
    local curRes = GetCurrentResourceName()

    if resName == curRes then
        for _, cKey in ipairs(getTableKeys(activeInteractionPoints)) do
            cleanupCreatorPoints(cKey)
        end
        for _, cKey in ipairs(getTableKeys(activeSpawnedPedsMap)) do
            cleanupCreatorPoints(cKey)
        end
    else
        for _, cKey in ipairs(getTableKeys(cachedCreatorsData)) do
            local cData = cachedCreatorsData[cKey]
            if resolveCreatorOwnerResource(cKey, cData) == resName then
                cleanupCreatorPoints(cKey)
                cachedCreatorsData[cKey] = nil
            end
        end
    end

    TriggerEvent("sky_base:cleanupInteractionResource", resName)
end)
