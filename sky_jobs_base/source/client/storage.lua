if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/storage.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_jobs_base · source/client/storage.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}
local fallbackLocales = (Locales and Locales.en) or {}

local nuiLocales = (locales.Nui and locales.Nui.storage) or {}
local nuiFallbackLocales = (fallbackLocales.Nui and fallbackLocales.Nui.storage) or {}
local errorLocales = nuiLocales.errors or {}
local errorFallbackLocales = nuiFallbackLocales.errors or {}

local isStorageOpen = false
local activeCustomStorageState = nil

local trunkCfg = (Config and Config.JobGarage and Config.JobGarage.trunk) or {}
local PROMPT_DISTANCE = trunkCfg.promptDistance or 2.5
local REQUIRE_BEHIND = trunkCfg.requireBehind ~= false
local STREAM_DISTANCE = math.max(150.0, tonumber(trunkCfg.propStreamDistance) or 150.0)
local DESPAWN_BUFFER = math.max(0.0, tonumber(trunkCfg.propStreamDespawnBuffer) or 25.0)
local PROP_REMOVE_ENABLED = trunkCfg.propRemoveEnabled ~= false
local PROP_REMOVE_KEY = tonumber(trunkCfg.propRemoveKey) or 38
local PROP_REMOVE_LABEL = type(trunkCfg.propRemoveKeyLabel) == "string" and trunkCfg.propRemoveKeyLabel or "E"
local PROP_REMOVE_DISTANCE = tonumber(trunkCfg.propRemoveDistance) or 2.2

local allowedTrunkVehicles = {}
local isTrunkAllowedAll = true
local trunkOpenVehicleNetId = { netId = nil }

local pendingVehicleRegistrations = {}
local isRegistrationThreadRunning = false

local cachedJobProps = { job = "__init__", props = nil }
local cachedTrunkProps = { plate = nil, props = {} }

local placementState = {
    active = false,
    model = nil,
    name = nil,
    label = nil,
    imageUrl = nil,
    previewEntity = nil,
    placeCallback = nil,
    placeContext = nil,
    remainingPlaces = 0,
    stopAfterPlace = false,
    zOffset = 0.0,
    streamDistance = nil
}

local registeredWorldProps = {}
local spawnedPropHandles = {}
local lastCancelTime = 0

local function getPropImageBaseUrl()
    local nuiCfg = Config and Config.Nui
    if nuiCfg and type(nuiCfg.propImageBase) == "string" and nuiCfg.propImageBase ~= "" then
        return nuiCfg.propImageBase
    end
    return "https://cdn.sky-systems.net/props"
end

local function normalizePropItem(item)
    if type(item) ~= "table" then return nil end
    local model = item.model or item.name
    if type(model) ~= "string" or model == "" then return nil end

    local name = item.name or model
    local label = item.label or name
    local amount = math.max(0, math.floor(tonumber(item.amount or item.count or item.quantity) or 1))

    return {
        name = name,
        model = model,
        label = label,
        image = type(item.image) == "string" and item.image or (model .. ".png"),
        amount = amount,
        unlimited = item.unlimited == true,
        zOffset = tonumber(item.zOffset) or 0.0,
        streamDistance = tonumber(item.streamDistance)
    }
end

local function getJobTrunkPropsList()
    local jobState = GetJobState and GetJobState()
    local currentJobKey = jobState and jobState.jobKey

    if cachedJobProps.props and cachedJobProps.job == currentJobKey then
        return cachedJobProps.props
    end

    local propList = nil
    local jobInfo = Sky.Cb.Trigger("sky_jobs_base:getJobInfo")
    if type(jobInfo) == "table" and type(jobInfo.trunkProps) == "table" then
        propList = jobInfo.trunkProps
    end

    if type(propList) ~= "table" and type(currentJobKey) == "string" and type(Config and Config.Jobs) == "table" then
        for _, j in ipairs(Config.Jobs) do
            if type(j) == "table" and j.name == currentJobKey and type(j.props) == "table" then
                propList = j.props
                break
            end
        end
    end

    if type(propList) ~= "table" then
        propList = (Config and Config.JobGarage and Config.JobGarage.trunk and Config.JobGarage.trunk.props) or {}
    end

    local normalizedList = {}
    for _, rawItem in ipairs(propList) do
        local norm = normalizePropItem(rawItem)
        if norm then
            table.insert(normalizedList, norm)
        end
    end

    cachedJobProps.job = currentJobKey
    cachedJobProps.props = normalizedList
    return normalizedList
end

local function setCachedVehicleProps(plate, props)
    cachedTrunkProps.plate = (type(plate) == "string" and plate ~= "") and plate or nil
    local filtered = {}
    if type(props) == "table" then
        for _, raw in ipairs(props) do
            local norm = normalizePropItem(raw)
            if norm and (norm.unlimited or norm.amount > 0) then
                table.insert(filtered, norm)
            end
        end
    end
    cachedTrunkProps.props = filtered
end

local function getVehicleTrunkProps(plate)
    if cachedTrunkProps.plate == plate and type(cachedTrunkProps.props) == "table" then
        return cachedTrunkProps.props
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:getVehicleTrunkProps", { plate = plate })
    if type(res) == "table" and res.success == true and type(res.props) == "table" then
        setCachedVehicleProps(plate, res.props)
        return cachedTrunkProps.props
    end

    return {}
end

local function formatPropImageUrl(item)
    local img = item and item.image
    if type(img) ~= "string" or img == "" then
        img = (item and item.name or "") .. ".png"
    end

    if img:find("^https?://") or img:find("^nui://") then
        return img
    end

    local base = getPropImageBaseUrl():gsub("/+$", "")
    local rel = img:gsub("^/+", "")
    return string.format("%s/%s", base, rel)
end

local function parseWorldPropData(data)
    if type(data) ~= "table" then return nil end
    local propId = tonumber(data.id)
    local model = type(data.model) == "string" and data.model or nil
    local coords = type(data.coords) == "table" and data.coords or nil

    if not (propId and model and model ~= "" and coords) then return nil end
    local cx, cy, cz = tonumber(coords.x), tonumber(coords.y), tonumber(coords.z)
    if not (cx and cy and cz) then return nil end

    return {
        id = propId,
        model = model,
        label = type(data.label) == "string" and data.label or model,
        coords = vector3(cx, cy, cz),
        heading = tonumber(data.heading) or 0.0,
        streamDistance = tonumber(data.streamDistance) or STREAM_DISTANCE
    }
end

local function despawnWorldProp(propId)
    local handle = spawnedPropHandles[propId]
    if handle and DoesEntityExist(handle) then
        SetEntityAsMissionEntity(handle, true, true)
        DeleteEntity(handle)
        DeleteObject(handle)
    end
    spawnedPropHandles[propId] = nil
    if handle then
        TriggerEvent("sky_jobs_base:trunkProps:unstreamed", propId, handle)
    end
end

local function clearAllWorldProps()
    for propId in pairs(spawnedPropHandles) do
        despawnWorldProp(propId)
    end
end

local function registerWorldProp(data)
    local prop = parseWorldPropData(data)
    if not prop then return end
    registeredWorldProps[prop.id] = prop
end

local function unregisterWorldProp(propId)
    local numId = tonumber(propId)
    if not numId then return end
    registeredWorldProps[numId] = nil
    despawnWorldProp(numId)
end

local function spawnWorldProp(prop)
    if not prop or not prop.id then return end
    if spawnedPropHandles[prop.id] and DoesEntityExist(spawnedPropHandles[prop.id]) then return end

    spawnedPropHandles[prop.id] = nil
    local hash = joaat(prop.model)
    if not IsModelInCdimage(hash) then
        print(string.format("[sky_jobs_base][trunk_props] unable to stream prop '%s': model is not in cdimage", prop.model))
        return
    end

    Sky.Load.Model(hash)
    local obj = CreateObjectNoOffset(hash, prop.coords.x, prop.coords.y, prop.coords.z, false, false, false)
    if not obj or obj == 0 or not DoesEntityExist(obj) then return end

    SetEntityAsMissionEntity(obj, true, true)
    SetEntityHeading(obj, prop.heading)
    FreezeEntityPosition(obj, true)
    SetEntityCollision(obj, true, true)
    SetEntityAlpha(obj, 255, false)

    spawnedPropHandles[prop.id] = obj
    TriggerEvent("sky_jobs_base:trunkProps:streamed", prop.id, obj, prop.model, prop.label)
end

local function updateWorldPropStreaming()
    local ped = PlayerPedId()
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end

    local pCoords = GetEntityCoords(ped)
    for propId, prop in pairs(registeredWorldProps) do
        local maxDist = tonumber(prop.streamDistance) or STREAM_DISTANCE
        local dist = #(pCoords - prop.coords)

        if dist <= maxDist then
            spawnWorldProp(prop)
        elseif dist > (maxDist + DESPAWN_BUFFER) then
            despawnWorldProp(propId)
        end
    end

    for propId, handle in pairs(spawnedPropHandles) do
        if not (registeredWorldProps[propId] and handle and DoesEntityExist(handle)) then
            despawnWorldProp(propId)
        end
    end
end

local function loadAllWorldProps()
    local res = Sky.Cb.Trigger("sky_jobs_base:trunkProps:getAll")
    if type(res) ~= "table" or res.success ~= true or type(res.props) ~= "table" then return end

    clearAllWorldProps()
    registeredWorldProps = {}
    for _, raw in ipairs(res.props) do
        registerWorldProp(raw)
    end
end

local function findPropConfigByName(name)
    if type(name) ~= "string" or name == "" then return nil end
    local lowerName = name:lower()

    for _, prop in ipairs(getJobTrunkPropsList()) do
        if prop.name:lower() == lowerName then
            return prop
        end
    end
    return nil
end

local function destroyPlacementPreview()
    if placementState.previewEntity and DoesEntityExist(placementState.previewEntity) then
        DeleteEntity(placementState.previewEntity)
    end
    placementState.previewEntity = nil
end

local function stopPropPlacement()
    destroyPlacementPreview()
    if not placementState.active then return end

    lastCancelTime = GetGameTimer()
    placementState.active = false
    placementState.model = nil
    placementState.name = nil
    placementState.label = nil
    placementState.imageUrl = nil
    placementState.placeCallback = nil
    placementState.placeContext = nil
    placementState.remainingPlaces = 0
    placementState.stopAfterPlace = false
    placementState.zOffset = 0.0
    placementState.streamDistance = nil

    SendNUIMessage({ type = "trunkProps:hideHud" })
end

local function ensurePlacementPreviewEntity()
    local modelName = placementState.model
    if type(modelName) ~= "string" or modelName == "" then return false end

    local hash = joaat(modelName)
    if not IsModelInCdimage(hash) then return false end

    if not HasModelLoaded(hash) then
        RequestModel(hash)
        local timeout = GetGameTimer() + 2500
        while not HasModelLoaded(hash) and GetGameTimer() < timeout do
            Wait(0)
        end
        if not HasModelLoaded(hash) then return false end
    end

    if placementState.previewEntity and DoesEntityExist(placementState.previewEntity) then
        return true
    end

    local pCoords = GetEntityCoords(PlayerPedId())
    local obj = CreateObjectNoOffset(hash, pCoords.x, pCoords.y, pCoords.z, false, false, false)
    if obj == 0 then return false end

    SetEntityAlpha(obj, 170, false)
    SetEntityCollision(obj, false, false)
    SetEntityInvincible(obj, true)
    FreezeEntityPosition(obj, true)

    placementState.previewEntity = obj
    return true
end

local function updatePlacingHud()
    if not placementState.active then return end
    local remaining = tonumber(placementState.remainingPlaces) or 0

    SendNUIMessage({
        type = "trunkProps:placingHud",
        data = {
            name = placementState.name,
            label = placementState.label,
            imageUrl = placementState.imageUrl,
            placeKey = "E",
            cancelKey = "X",
            remaining = (remaining > 0) and remaining or nil
        }
    })
end

local function getPlacementRaycastTarget()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return nil, nil end

    local pCoords = GetEntityCoords(ped)
    local fVec = GetEntityForwardVector(ped)
    local targetCoords = vector3(pCoords.x + (fVec.x * 1.6), pCoords.y + (fVec.y * 1.6), pCoords.z)
    local heading = GetEntityHeading(ped)

    return targetCoords, heading
end

local function updatePlacementPreviewPosition()
    if not placementState.active then return end
    if not ensurePlacementPreviewEntity() then
        stopPropPlacement()
        return
    end

    local coords, heading = getPlacementRaycastTarget()
    local previewObj = placementState.previewEntity

    if not (coords and previewObj and DoesEntityExist(previewObj)) then return end

    local zOff = tonumber(placementState.zOffset) or 0.0
    SetEntityCoordsNoOffset(previewObj, coords.x, coords.y, coords.z + zOff, false, false, false)
    SetEntityHeading(previewObj, heading)
    PlaceObjectOnGroundProperly(previewObj)
end

local function confirmPropPlacement()
    if not placementState.active then return end

    local modelName = placementState.model
    if type(modelName) ~= "string" or modelName == "" then return end
    local hash = joaat(modelName)
    if not HasModelLoaded(hash) then return end

    local coords, heading = getPlacementRaycastTarget()
    if not coords then return end

    local previewObj = placementState.previewEntity
    local spawnCoords = nil

    if previewObj and DoesEntityExist(previewObj) then
        spawnCoords = GetEntityCoords(previewObj)
        heading = GetEntityHeading(previewObj)
    else
        local zOff = tonumber(placementState.zOffset) or 0.0
        spawnCoords = vector3(coords.x, coords.y, coords.z + zOff)
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:trunkProps:place", {
        model = modelName,
        label = placementState.label or placementState.name,
        coords = { x = spawnCoords.x, y = spawnCoords.y, z = spawnCoords.z },
        heading = heading,
        streamDistance = placementState.streamDistance
    })

    if type(res) ~= "table" or res.success ~= true then
        print(string.format("[sky_jobs_base][trunk_props] placement failed: server rejected prop '%s'", modelName))
        stopPropPlacement()
        return
    end

    if type(res.prop) == "table" then
        registerWorldProp(res.prop)
        updateWorldPropStreaming()
    end

    if type(placementState.placeCallback) == "string" and placementState.placeCallback ~= "" then
        local ctx = placementState.placeContext or {}
        ctx.propId = type(res.prop) == "table" and res.prop.id or nil

        local cbRes = Sky.Cb.Trigger(placementState.placeCallback, ctx)
        if cbRes ~= true then
            if ctx.propId then
                Sky.Cb.Trigger("sky_jobs_base:trunkProps:remove", { id = ctx.propId })
            end
            stopPropPlacement()
            return
        end

        if type(cbRes) == "table" and type(cbRes.props) == "table" then
            setCachedVehicleProps(ctx.plate, cbRes.props)
        end
    end

    if placementState.remainingPlaces > 0 then
        local rem = math.max(0, (tonumber(placementState.remainingPlaces) or 1) - 1)
        placementState.remainingPlaces = rem
    end

    if placementState.stopAfterPlace or placementState.remainingPlaces == 0 then
        stopPropPlacement()
    else
        updatePlacingHud()
    end
end

local function startTrunkPropPlacement(itemRaw, options)
    local item = normalizePropItem(itemRaw)
    if not item then return false end

    stopPropPlacement()
    placementState.active = true
    placementState.model = item.model
    placementState.name = item.name
    placementState.label = item.label
    placementState.imageUrl = formatPropImageUrl(item)

    local optsTable = type(options) == "table" and options or nil
    placementState.placeCallback = optsTable and optsTable.placeCallback
    placementState.placeContext = optsTable and optsTable.placeContext

    if optsTable and optsTable.unlimited == true then
        placementState.remainingPlaces = -1
    else
        local count = tonumber(type(options) == "table" and options or nil) or 1
        placementState.remainingPlaces = math.max(math.floor(count), 1)
    end

    placementState.stopAfterPlace = type(options) == "table"
    placementState.zOffset = item.zOffset
    placementState.streamDistance = item.streamDistance

    if not ensurePlacementPreviewEntity() then
        stopPropPlacement()
        return false
    end

    updatePlacingHud()
    return true
end

local function getClosestWorldProp(maxDist)
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return nil end

    local maxD = math.max(0.001, tonumber(maxDist) or 2.2)
    local pCoords = GetEntityCoords(ped)

    local closestDist = maxD + 0.001
    local closestEntity, closestId, closestLabel = nil, nil, nil

    for propId, entity in pairs(spawnedPropHandles) do
        if entity and DoesEntityExist(entity) and registeredWorldProps[propId] then
            local eCoords = GetEntityCoords(entity)
            local dist = #(pCoords - eCoords)

            if dist <= maxD and dist < closestDist then
                closestDist = dist
                closestEntity = entity
                closestId = propId
                local reg = registeredWorldProps[propId]
                closestLabel = reg and reg.label or nil
            end
        end
    end

    if not closestEntity then return nil end

    return {
        id = closestId,
        entity = closestEntity,
        distance = closestDist,
        label = type(closestLabel) == "string" and closestLabel or "Placed Prop"
    }
end

local function removeWorldPropByTarget(target)
    local propId = tonumber(target and target.id)
    if not propId then return false end

    local res = Sky.Cb.Trigger("sky_jobs_base:trunkProps:remove", { id = propId })
    return type(res) == "table"
end

local function isPlayerOnDuty()
    local jobState = GetJobState and GetJobState()
    return jobState and jobState.employed and jobState.onDuty
end

local function isPlayerAuthorizedForJob(jobKey)
    local jobState = GetJobState and GetJobState()
    if not (jobState and jobState.employed and jobState.onDuty) then return false end

    if type(jobKey) ~= "string" or jobKey == "" then return true end
    return jobState.jobKey == jobKey
end

local function getJobColor()
    local col = Sky.Cb.Trigger("sky_jobs_base:getJobColor")
    if type(col) == "string" and col ~= "" then return col end
    return nil
end

local function getJobBackgroundPath()
    local bg = Sky.Cb.Trigger("sky_jobs_base:getJobBackgroundPath")
    if type(bg) == "string" and bg ~= "" then return bg end
    return nil
end

local function getErrorMessage(errKey)
    local defaultErr = errorLocales.invalidTransfer or errorFallbackLocales.invalidTransfer or "Transfer failed."
    if type(errKey) ~= "string" or errKey == "" then return defaultErr end

    local cleanKey = errKey:match("^storage%.errors%.(.+)$") or errKey
    local msg = errorLocales[cleanKey] or errorFallbackLocales[cleanKey]
    if type(msg) == "string" and msg ~= "" then return msg end

    return defaultErr
end

local function playStorageSound()
    PlaySoundFrontend(-1, "PUSH", "GTAO_APT_DOOR_DOWNSTAIRS_WOOD_SOUNDS", true)
end

local function playBummBinScenario()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) or IsEntityDead(ped) or IsPedInAnyVehicle(ped, false) then return end

    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
    SetTimeout(1000, function()
        if DoesEntityExist(ped) and not IsEntityDead(ped) and IsPedUsingScenario(ped, "PROP_HUMAN_BUM_BIN") then
            ClearPedTasks(ped)
        end
    end)
end

local function stopBummBinScenario()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) or IsEntityDead(ped) or IsPedInAnyVehicle(ped, false) then return end

    if IsPedUsingScenario(ped, "PROP_HUMAN_BUM_BIN") then
        ClearPedTasksImmediately(ped)
        ClearPedSecondaryTask(ped)
    end
end

local function setVehicleDoorState(vehicle, open)
    if not (vehicle and vehicle ~= 0 and DoesEntityExist(vehicle)) then return end

    if DoesVehicleHaveDoor(vehicle, 5) then
        if open then
            SetVehicleDoorOpen(vehicle, 5, false, false)
        else
            SetVehicleDoorShut(vehicle, 5, false)
        end
        return
    end

    local hasAnyRear = false
    if DoesVehicleHaveDoor(vehicle, 2) then
        if open then SetVehicleDoorOpen(vehicle, 2, false, false) else SetVehicleDoorShut(vehicle, 2, false) end
        hasAnyRear = true
    end
    if DoesVehicleHaveDoor(vehicle, 3) then
        if open then SetVehicleDoorOpen(vehicle, 3, false, false) else SetVehicleDoorShut(vehicle, 3, false) end
        hasAnyRear = true
    end

    if not hasAnyRear then
        if open then SetVehicleDoorOpen(vehicle, 5, false, false) else SetVehicleDoorShut(vehicle, 5, false) end
    end
end

local function openVehicleTrunkDoors(data)
    if not (data and data.context == "world" and data.netId) then return end

    local veh = NetworkGetEntityFromNetworkId(data.netId)
    if veh == 0 or not DoesEntityExist(veh) then return end

    trunkOpenVehicleNetId.netId = data.netId
    setVehicleDoorState(veh, true)
end

local function closeVehicleTrunkDoors()
    if not trunkOpenVehicleNetId.netId then return end

    local veh = NetworkGetEntityFromNetworkId(trunkOpenVehicleNetId.netId)
    trunkOpenVehicleNetId.netId = nil

    if veh ~= 0 and DoesEntityExist(veh) then
        setVehicleDoorState(veh, false)
    end
end

local function setupGarageCatalogVehicles(catalog)
    allowedTrunkVehicles = {}
    isTrunkAllowedAll = false

    if type(catalog) ~= "table" then return end

    for _, v in ipairs(catalog) do
        if v.trunkEnabled ~= false and v.model then
            local hash = joaat(v.model)
            allowedTrunkVehicles[hash] = true
            isTrunkAllowedAll = true

            if type(v.altModels) == "table" then
                for _, alt in ipairs(v.altModels) do
                    allowedTrunkVehicles[joaat(alt)] = true
                end
            end
        end
    end
end

local function fetchGarageCatalog()
    local res = Sky.Cb.Trigger("sky_jobs_base:getJobGarageCatalog")
    local vehs = (Config and Config.JobGarage and Config.JobGarage.vehicles) or {}

    if type(res) == "table" and res.success == true and type(res.data) == "table" then
        setupGarageCatalogVehicles(res.data)
    else
        setupGarageCatalogVehicles(vehs)
    end
end

local function getTrunkPosition(vehicle)
    if not (vehicle and vehicle ~= 0 and DoesEntityExist(vehicle)) then return nil end

    local boneIdx = GetEntityBoneIndexByName(vehicle, "boot")
    if boneIdx and boneIdx ~= -1 then
        local pos = GetWorldPositionOfEntityBone(vehicle, boneIdx)
        if pos and pos.x then return pos end
    end

    return GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.0, 0.0)
end

local function isPlayerBehindVehicle(vehicle, playerCoords)
    if not REQUIRE_BEHIND then return true end
    if not (vehicle and vehicle ~= 0 and playerCoords and playerCoords.x) then return false end

    local vehCoords = GetEntityCoords(vehicle)
    if not (vehCoords and vehCoords.x) then return false end

    local forward = GetEntityForwardVector(vehicle)
    if not forward then return true end

    local relVec = vector3(playerCoords.x - vehCoords.x, playerCoords.y - vehCoords.y, 0.0)
    local dot = (forward.x * relVec.x) + (forward.y * relVec.y)
    return dot <= 0.0
end

local function getTrunkInteractionId(netId)
    return string.format("sky_jobs_base:trunk:%s", tostring(netId))
end

local function removeTrunkInteractionPoint(pointId)
    if pointId and pendingVehicleRegistrations[pointId] then
        Sky.DeleteInteractionPoint(pointId)
        pendingVehicleRegistrations[pointId] = nil
    end
end

local function createTrunkInteractionPoint(vehicle, bypassCheck)
    if not isTrunkAllowedAll then return end
    if not (vehicle and vehicle ~= 0 and DoesEntityExist(vehicle)) then return end

    local modelHash = GetEntityModel(vehicle)
    if not bypassCheck and next(allowedTrunkVehicles) and not allowedTrunkVehicles[modelHash] then
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if not netId or netId == 0 then return end

    local pointId = getTrunkInteractionId(netId)
    if pendingVehicleRegistrations[pointId] then return end

    local canInteract = function(point, pedCoords)
        local sourceVeh = point and point.sourceEntity
        if not (sourceVeh and sourceVeh ~= 0 and DoesEntityExist(sourceVeh)) then return false end

        if REQUIRE_BEHIND and pedCoords then
            if not isPlayerBehindVehicle(sourceVeh, pedCoords) then
                return false
            end
        end
        return true
    end

    local helpText = locales.TrunkHelpNotify or "Access the trunk"
    Sky.CreateInteractionPoint(
        { entity = vehicle, offset = vector3(0.0, -2.5, 0.0), canInteract = canInteract },
        helpText,
        "sky_jobs_base:trunkInteraction",
        pointId,
        {}, {}, {},
        GetCurrentResourceName(),
        2.0
    )

    pendingVehicleRegistrations[pointId] = true
end

local function tryRegisterNetIdVehicle(netId, bypassCheck)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh and veh ~= 0 and DoesEntityExist(veh) then
        createTrunkInteractionPoint(veh, bypassCheck)
        return true
    end
    return false
end

local function startPendingRegistrationsThread()
    if isRegistrationThreadRunning then return end
    isRegistrationThreadRunning = true

    CreateThread(function()
        while next(pendingVehicleRegistrations) do
            for netId, data in pairs(pendingVehicleRegistrations) do
                if not isPlayerAuthorizedForJob(data.jobName) then
                    pendingVehicleRegistrations[netId] = nil
                else
                    if tryRegisterNetIdVehicle(netId, data.bypassModelLookup) then
                        pendingVehicleRegistrations[netId] = nil
                    end
                end
            end
            Wait(1000)
        end
        isRegistrationThreadRunning = false
    end)
end

local function registerTrunkVehicleNetId(netId, jobName, bypassCheck)
    local numId = tonumber(netId)
    if not numId or numId == 0 then return end

    if tryRegisterNetIdVehicle(numId, bypassCheck) then return end

    pendingVehicleRegistrations[numId] = {
        jobName = jobName,
        bypassModelLookup = bypassCheck == true
    }
    startPendingRegistrationsThread()
end

local function openVehicleTrunkUI(data, forceOpen)
    if isStorageOpen then return false end
    isStorageOpen = true

    playBummBinScenario()
    playStorageSound()

    local res = Sky.Cb.Trigger("sky_jobs_base:openVehicleTrunk", data)
    SetTimeout(350, function()
        if res and res.success and res.data then
            local trunkData = res.data
            local label = trunkData.vehicleName and string.format("%s (%s)", trunkData.vehicleName, trunkData.plate) or trunkData.plate

            setCachedVehicleProps(trunkData.plate, trunkData.trunkProps)
            openVehicleTrunkDoors(data)
            SetNuiFocus(true, true)

            SendNUIMessage({
                type = "trunk",
                stationId = trunkData.plate,
                trunkItems = trunkData.trunkItems,
                inventoryItems = trunkData.inventoryItems,
                capacity = trunkData.capacity,
                used = trunkData.used,
                storageContainsWeapons = trunkData.storageContainsWeapons == true,
                label = label,
                jobColor = trunkData.jobColor or getJobColor(),
                jobBackgroundPath = trunkData.jobBackgroundPath or trunkData.jobBackgroundImage or getJobBackgroundPath()
            })
        elseif forceOpen and res then
            local errMsg = (res and res.error) or locales.TrunkUnavailable or "Unable to access trunk."
            Sky.Show.Notification(locales.TrunkTitle or "Trunk", errMsg, "error")
        end
        isStorageOpen = false
    end)

    return (res and res.success == true)
end

local function openVehicleTrunkByEntity(entity)
    if not (entity and entity ~= 0) then return end

    local vehicleObj = Sky.Vehicle:new(entity)
    local plate = vehicleObj:GetPlate() or ""
    local cleanPlate = (type(plate) == "string" and plate:gsub("%s+", ""):upper()) or ""
    if cleanPlate == "" then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicleObj.entity)
    if not netId or netId == 0 then return end

    openVehicleTrunkUI({
        plate = cleanPlate,
        context = "world",
        netId = netId
    }, true)
end

CreateThread(function()
    Wait(500)
    fetchGarageCatalog()
end)

RegisterNetEvent("sky_base:updateJob", function()
    cachedJobProps.job = "__dirty__"
    cachedJobProps.props = nil
    fetchGarageCatalog()
end)

RegisterNetEvent("sky_jobs_base:creator:updatePlayerJob", function()
    cachedJobProps.job = "__dirty__"
    cachedJobProps.props = nil
    fetchGarageCatalog()
end)

RegisterNetEvent("sky_jobs_base:trunkProps:add", function(data)
    registerWorldProp(data)
    updateWorldPropStreaming()
end)

RegisterNetEvent("sky_jobs_base:trunkProps:remove", function(data)
    unregisterWorldProp(data)
end)

RegisterNetEvent("sky_jobs_base:propItems:useItem", function(data)
    if type(data) ~= "table" then
        print("[sky_jobs_base][prop_items] item placement failed: invalid prop item payload")
        return
    end

    local model = type(data.model) == "string" and data.model or nil
    local item = type(data.item) == "string" and data.item or nil
    if not (model and model ~= "" and item and item ~= "") then
        print("[sky_jobs_base][prop_items] item placement failed: invalid prop item payload")
        return
    end

    local ok = startTrunkPropPlacement({
        model = model,
        label = type(data.label) == "string" and data.label or model,
        zOffset = tonumber(data.zOffset) or 0.0
    }, {
        placeCallback = "sky_jobs_base:propItems:consume",
        placeContext = { item = item, model = model },
        stopAfterPlace = true
    })

    if not ok then
        print(string.format("[sky_jobs_base][prop_items] item placement failed: unable to start placement for '%s'", model))
    end
end)

RegisterNetEvent("sky_jobs_base:trunkInteraction", function(pointId)
    if not isTrunkAllowedAll or isStorageOpen or not isPlayerOnDuty() then return end

    local netIdStr = type(pointId) == "string" and pointId:match("^sky_jobs_base:trunk:(.+)$") or nil
    local netId = tonumber(netIdStr)
    if not netId then return end

    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh == 0 or not DoesEntityExist(veh) then return end

    local ped = PlayerPedId()
    if not DoesEntityExist(ped) or IsPedInAnyVehicle(ped, false) then return end

    local pCoords = GetEntityCoords(ped)
    if REQUIRE_BEHIND and not isPlayerBehindVehicle(veh, pCoords) then return end

    local tPos = getTrunkPosition(veh)
    if tPos and tPos.x then
        local dist = #(pCoords - tPos)
        if dist > PROMPT_DISTANCE then return end
    end

    openVehicleTrunkByEntity(veh)
end)

RegisterNetEvent("sky_jobs_base:trunk:register", function(vehicle)
    if not isPlayerOnDuty() then return end
    createTrunkInteractionPoint(vehicle)
end)

RegisterNetEvent("sky_jobs_base:trunk:registerNetId", function(netId, jobName, bypassCheck)
    if not isPlayerAuthorizedForJob(jobName) then return end
    registerTrunkVehicleNetId(netId, jobName, bypassCheck)
end)

RegisterNetEvent("sky_jobs_base:trunk:unregister", function(vehicle)
    if not (vehicle and vehicle ~= 0) then return end
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if not netId or netId == 0 then return end
    removeTrunkInteractionPoint(getTrunkInteractionId(netId))
end)

RegisterNetEvent("sky_jobs_base:trunk:unregisterNetId", function(netId)
    local numId = tonumber(netId)
    if not numId or numId == 0 then return end

    pendingVehicleRegistrations[numId] = nil
    removeTrunkInteractionPoint(getTrunkInteractionId(numId))
end)

local function openStorageUI(stType, stId, stLabel)
    if type(stId) ~= "string" or stId == "" then return end

    local invItems = Sky.Cb.Trigger("sky_jobs_base:getPlayerInventoryItems") or {}
    local containsWeapons = Sky.Cb.Trigger("sky_jobs_base:getJobStorageContainsWeapons") == true

    if stType == "storage" then
        local items = Sky.Cb.Trigger("sky_jobs_base:getStorageItems", stId) or {}
        local capacityData = Sky.Cb.Trigger("sky_jobs_base:getStorageCapacity", { stationId = stId, slot = "storage" })
        local cap = tonumber(type(capacityData) == "table" and capacityData.capacity or capacityData) or 0

        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "storage",
            stationId = stId,
            storageItems = items,
            inventoryItems = invItems,
            capacity = math.max(0, cap),
            used = Sky_Jobs.CalculateItemsTotalQuantity and Sky_Jobs.CalculateItemsTotalQuantity(items) or 0,
            storageContainsWeapons = containsWeapons,
            label = stLabel,
            jobColor = getJobColor(),
            jobBackgroundPath = getJobBackgroundPath()
        })
        return
    end

    if stType == "locker" then
        local items = Sky.Cb.Trigger("sky_jobs_base:getLockerItems", stId) or {}
        local capacityData = Sky.Cb.Trigger("sky_jobs_base:getStorageCapacity", { stationId = stId, slot = "locker" })
        local cap = tonumber(type(capacityData) == "table" and capacityData.capacity or capacityData) or 0

        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "locker",
            stationId = stId,
            lockerItems = items,
            inventoryItems = invItems,
            capacity = math.max(0, cap),
            used = Sky_Jobs.CalculateItemsTotalQuantity and Sky_Jobs.CalculateItemsTotalQuantity(items) or 0,
            storageContainsWeapons = containsWeapons,
            label = stLabel,
            jobColor = getJobColor(),
            jobBackgroundPath = getJobBackgroundPath()
        })
    end
end

function Sky_Jobs.OpenCustomStorage(payload)
    if type(payload) ~= "table" then return false, "Invalid payload." end
    if isStorageOpen then return false, "Storage interface is already open." end

    local stId = payload.storageId or payload.stationId or payload.id
    stId = stId and tostring(stId) or nil
    if not stId or stId == "" then return false, "Missing storageId." end

    local cType = tostring(payload.type or stId):lower():gsub("%s+", "_"):gsub("[^%w_]", "_"):gsub("_+", "_"):gsub("^_+", ""):gsub("_+$", "")
    if cType == "" then return false, "Missing type." end

    local title = type(payload.title) == "string" and payload.title or nil
    if not title or title == "" then return false, "Missing title." end

    local storageItems = type(payload.storageItems) == "table" and payload.storageItems or {}
    local invItems = type(payload.inventoryItems) == "table" and payload.inventoryItems or (Sky.Cb.Trigger("sky_jobs_base:getPlayerInventoryItems") or {})
    local cap = math.max(0, tonumber(payload.capacity) or 0)
    local used = tonumber(payload.used) or (Sky_Jobs.CalculateItemsTotalQuantity and Sky_Jobs.CalculateItemsTotalQuantity(storageItems) or 0)
    local containsWeapons = payload.storageContainsWeapons == true
    local showBack = payload.showBackButton ~= false

    activeCustomStorageState = {
        stationId = stId,
        customType = cType,
        showBackButton = showBack
    }

    isStorageOpen = true
    playBummBinScenario()
    playStorageSound()
    SetNuiFocus(true, true)

    SendNUIMessage({
        type = "storage",
        stationId = stId,
        storageItems = storageItems,
        inventoryItems = invItems,
        capacity = cap,
        used = used,
        storageContainsWeapons = containsWeapons,
        label = payload.label,
        title = title,
        showBackButton = showBack,
        transferEndpoint = "customStorageTransfer",
        customBackgroundImage = string.format("%s_background.png", cType),
        jobColor = getJobColor(),
        jobBackgroundPath = getJobBackgroundPath()
    })
    return true
end

RegisterNetEvent("sky_jobs_base:storageInteraction", function(data)
    if not isPlayerOnDuty() or isStorageOpen then return end

    local stId = nil
    if type(data) == "table" then
        stId = data.stationId or data.id or data.entryId or data.entry
    elseif storageStationLookup and storageStationLookup[data] then
        local entry = storageStationLookup[data]
        stId = type(entry) == "table" and entry.stationId or entry
    end

    if stId and GetResourceState("sky_mechanicjob") == "started" then
        local ok, deposited = pcall(function()
            return exports.sky_mechanicjob:TryDepositCarryItemToStorage(tostring(stId))
        end)
        if ok and deposited == true then return end
    end

    isStorageOpen = true
    playBummBinScenario()
    playStorageSound()

    SetTimeout(1000, function()
        if type(data) == "table" then
            local rawId = data.stationId or data.id or data.entryId or data.entry
            local slotKey = (data.slot or data.type or data.pointType or "storage"):lower():gsub("%s+", "_"):gsub("-", "_")
            if slotKey == "stash" then slotKey = "storage" end
            openStorageUI(slotKey, tostring(rawId or ""), data.label)
        elseif storageStationLookup and storageStationLookup[data] then
            local entry = storageStationLookup[data]
            local rawId = type(entry) == "table" and entry.stationId or entry
            local label = type(entry) == "table" and entry.label or nil
            openStorageUI("storage", tostring(rawId or ""), label)
        elseif lockerStationLookup and lockerStationLookup[data] then
            local entry = lockerStationLookup[data]
            local rawId = type(entry) == "table" and entry.stationId or entry
            local label = type(entry) == "table" and entry.label or nil
            openStorageUI("locker", tostring(rawId or ""), label)
        end
        isStorageOpen = false
    end)
end)

RegisterNUICallback("storageTransfer", function(data, cb)
    local stId = data and data.stationId and tostring(data.stationId)
    if not stId or stId == "" then
        cb({ success = false, error = getErrorMessage() })
        return
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:storageTransfer", stId, data.type, data.name, data.amount, data.category, data.metadata, data.metadataKey)
    if type(res) == "table" then
        local err = (type(res.error) == "string" and res.error ~= "") and res.error or getErrorMessage(res.errorKey)
        cb({ success = res.success == true, error = err, errorKey = res.errorKey })
    else
        cb({ success = res == true })
    end
end)

RegisterNUICallback("customStorageTransfer", function(data, cb)
    local stId = data and data.stationId and tostring(data.stationId)
    if not stId or stId == "" or not activeCustomStorageState or activeCustomStorageState.stationId ~= stId then
        cb({ success = false, error = getErrorMessage("storage.errors.invalidTransfer") })
        return
    end

    local eventName = string.format("sky_jobs_base:customStorage:%s:transfer", activeCustomStorageState.customType)
    local res = Sky.Cb.Trigger(eventName, {
        stationId = stId,
        type = data.type,
        name = data.name,
        amount = data.amount,
        metadata = data.metadata,
        metadataKey = data.metadataKey
    })

    if type(res) == "table" then
        local err = (type(res.error) == "string" and res.error ~= "") and res.error or getErrorMessage(res.errorKey)
        cb({ success = res.success == true, error = err, errorKey = res.errorKey })
    else
        cb({ success = res == true })
    end
end)

RegisterNUICallback("customStorageBack", function(data, cb)
    local stId = data and data.stationId and tostring(data.stationId)
    if not stId or stId == "" or not activeCustomStorageState or activeCustomStorageState.stationId ~= stId or activeCustomStorageState.showBackButton ~= true then
        cb({ success = false, error = getErrorMessage("storage.errors.invalidTransfer") })
        return
    end

    local cType = activeCustomStorageState.customType
    local payload = { stationId = stId, type = cType }

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    isStorageOpen = false
    stopBummBinScenario()
    closeVehicleTrunkDoors()
    stopPropPlacement()
    activeCustomStorageState = nil

    TriggerEvent("sky_jobs_base:customStorage:back", payload)
    TriggerEvent(string.format("sky_jobs_base:customStorage:%s:back", cType), payload)
    cb({ success = true })
end)

RegisterNUICallback("lockerTransfer", function(data, cb)
    local stId = data and data.stationId and tostring(data.stationId)
    if not stId or stId == "" then
        cb({ success = false, error = getErrorMessage() })
        return
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:lockerTransfer", stId, data.type, data.name, data.amount, data.category, data.metadata, data.metadataKey)
    if type(res) == "table" then
        local err = (type(res.error) == "string" and res.error ~= "") and res.error or getErrorMessage(res.errorKey)
        cb({ success = res.success == true, error = err, errorKey = res.errorKey })
    else
        cb({ success = res == true })
    end
end)

RegisterNUICallback("trunkTransfer", function(data, cb)
    local stId = data and data.stationId and tostring(data.stationId)
    if not stId or stId == "" then
        cb({ success = false, error = "Vehicle unavailable." })
        return
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:trunkTransfer", stId, data.type, data.name, data.amount, data.metadata)
    if type(res) == "table" then
        cb({ success = res.success == true, error = res.error })
    else
        cb({ success = res == true })
    end
end)

RegisterNUICallback("openTrunk", function(data, cb)
    local plate = data and data.plate and data.plate:gsub("%s+", ""):upper()
    if not plate or plate == "" then
        cb({ success = false, error = "Vehicle unavailable." })
        return
    end

    local ok = openVehicleTrunkUI({
        plate = plate,
        context = "garage",
        garageId = data and data.garageId
    }, true)

    cb({ success = ok })
end)

RegisterNUICallback("openTrunkProps", function(data, cb)
    local stId = data and data.stationId and tostring(data.stationId)
    if not stId or stId == "" then
        cb({ success = false, error = "Vehicle unavailable." })
        return
    end

    local props = getVehicleTrunkProps(stId)
    SendNUIMessage({
        type = "trunkProps",
        stationId = stId,
        props = props,
        label = data and data.label,
        jobColor = getJobColor(),
        jobBackgroundPath = getJobBackgroundPath()
    })
    cb({ success = true })
end)

RegisterNUICallback("trunkPropSelect", function(data, cb)
    local plate = (data and data.plate and tostring(data.plate)) or cachedTrunkProps.plate
    local propName = data and data.name and tostring(data.name):lower()
    local matchedProp = nil

    if propName then
        for _, p in ipairs(getVehicleTrunkProps(plate)) do
            if p.name:lower() == propName then
                matchedProp = p
                break
            end
        end
    end

    if not matchedProp then
        cb({ success = false, error = "Invalid prop." })
        return
    end

    local reqAmount = math.max(1, math.floor(tonumber(data and data.amount) or 1))
    if not matchedProp.unlimited then
        reqAmount = math.min(reqAmount, tonumber(matchedProp.amount) or 1)
    end

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    isStorageOpen = false
    stopBummBinScenario()
    closeVehicleTrunkDoors()
    stopPropPlacement()
    activeCustomStorageState = nil

    local ok = startTrunkPropPlacement(matchedProp, {
        placeCallback = "sky_jobs_base:takeVehicleTrunkProp",
        placeContext = { plate = plate, name = matchedProp.name },
        amount = reqAmount,
        unlimited = matchedProp.unlimited == true,
        stopAfterPlace = false
    })

    cb({ success = ok })
end)

local function closeStorage()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    isStorageOpen = false
    stopBummBinScenario()
    closeVehicleTrunkDoors()
    stopPropPlacement()
    activeCustomStorageState = nil
end

AddEventHandler("sky_jobs_base:storage:close", closeStorage)
AddEventHandler("sky_jobs:nuiClosed", closeStorage)

CreateThread(function()
    while true do
        if placementState.active then
            updatePlacementPreviewPosition()
            if IsControlJustReleased(0, 38) then
                confirmPropPlacement()
            elseif IsControlJustReleased(0, 73) then
                stopPropPlacement()
            end
            Wait(0)
        else
            Wait(300)
        end
    end
end)

CreateThread(function()
    if not PROP_REMOVE_ENABLED then return end
    local helpLabel = locales.TrunkPropRemoveHelp or fallbackLocales.TrunkPropRemoveHelp or "Remove placed prop"

    while true do
        local waitMs = 250
        if not placementState.active and (GetGameTimer() - lastCancelTime) > 750 and not isStorageOpen and isPlayerOnDuty() and not IsNuiFocused() then
            local ped = PlayerPedId()
            if ped and DoesEntityExist(ped) and not IsPedInAnyVehicle(ped, false) then
                local closestProp = getClosestWorldProp(PROP_REMOVE_DISTANCE)
                if closestProp then
                    waitMs = 0
                    Sky.Show.HelpNotification(helpLabel, PROP_REMOVE_LABEL)
                    if IsControlJustReleased(0, PROP_REMOVE_KEY) then
                        removeWorldPropByTarget(closestProp)
                    end
                end
            end
        end
        Wait(waitMs)
    end
end)

CreateThread(function()
    Wait(1000)
    loadAllWorldProps()

    while true do
        updateWorldPropStreaming()
        Wait(1000)
    end
end)

AddEventHandler("onResourceStop", function(resName)
    if resName == GetCurrentResourceName() then
        stopPropPlacement()
        clearAllWorldProps()
        closeVehicleTrunkDoors()
    end
end)

registerExport("getNearbyTrunkPropTarget", function(maxDist)
    local target = getClosestWorldProp(maxDist)
    if not target then return nil end
    return {
        distance = target.distance,
        label = target.label
    }
end)

registerExport("removeNearbyTrunkProp", function(maxDist)
    local target = getClosestWorldProp(maxDist)
    if not target then
        return false, "radial.actions.removeProp.states.noNearby"
    end

    if not removeWorldPropByTarget(target) then
        return false, "radial.actions.removeProp.states.failed"
    end
    return true
end)

registerExport("startTrunkPropPlacement", function(item, options)
    return startTrunkPropPlacement(item, options)
end)

registerExport("getStreamedTrunkProps", function()
    local list = {}
    for propId, handle in pairs(spawnedPropHandles) do
        if handle and DoesEntityExist(handle) then
            local reg = registeredWorldProps[propId]
            table.insert(list, {
                id = propId,
                entity = handle,
                model = reg and reg.model,
                label = reg and reg.label
            })
        end
    end
    return list
end)

registerExport("registerExternalTrunkVehicle", function(vehicle)
    if not (vehicle and vehicle ~= 0 and DoesEntityExist(vehicle)) then return false end
    local modelHash = GetEntityModel(vehicle)
    if modelHash then
        allowedTrunkVehicles[modelHash] = true
    end
    createTrunkInteractionPoint(vehicle)
    return true
end)

registerExport("unregisterExternalTrunkVehicle", function(vehicle)
    if not (vehicle and vehicle ~= 0 and DoesEntityExist(vehicle)) then return false end
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if not netId or netId == 0 then return false end

    removeTrunkInteractionPoint(getTrunkInteractionId(netId))
    return true
end)
