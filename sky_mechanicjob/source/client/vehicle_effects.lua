if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/vehicle_effects.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/vehicle_effects.lua
--  Deobfuscated & Cleaned
-- =====================================================

VehicleEffects = VehicleEffects or {}

local effectsState = {
    stopQueue = {},
    stopThreadRunning = false,
    backfireOffsetsByKey = {},
    driverActive = false,
    runtimeToken = 0,
    runtimeVehicle = 0,
    rgbRuntimeActive = false,
    rgbRuntimeToken = 0,
    rgbRuntimeVehicle = 0,
    installedSystems = {
        antiLag = false,
        twoStep = false
    },
    activeState = {
        engineRunning = false,
        rpm = 0.0,
        gear = 0,
        speedKmh = 0.0,
        throttlePressed = false,
        brakePressed = false
    }
}

local EXHAUST_BONE_NAMES = {
    "exhaust", "exhaust_2", "exhaust_3", "exhaust_4",
    "exhaust_5", "exhaust_6", "exhaust_7", "exhaust_8",
    "exhaust_9", "exhaust_10", "exhaust_11", "exhaust_12",
    "exhaust_13", "exhaust_14", "exhaust_15", "exhaust_16"
}

-- ── PTFX Loading ─────────────────────────────────────

local function ensureCorePtfxLoaded()
    if HasNamedPtfxAssetLoaded("core") then return true end
    RequestNamedPtfxAsset("core")
    return HasNamedPtfxAssetLoaded("core")
end

-- ── Stop Queue Thread ────────────────────────────────

local function startStopQueueThread()
    if effectsState.stopThreadRunning then return end
    effectsState.stopThreadRunning = true

    CreateThread(function()
        while #effectsState.stopQueue > 0 do
            local now = GetGameTimer()

            for i = #effectsState.stopQueue, 1, -1 do
                local entry = effectsState.stopQueue[i]
                if now >= entry.stopAt then
                    StopParticleFxLooped(entry.handle, false)
                    table.remove(effectsState.stopQueue, i)
                end
            end

            Wait(#effectsState.stopQueue > 0 and 10 or 50)
        end

        effectsState.stopThreadRunning = false
    end)
end

-- ── Schedule Looped Effect Stop ──────────────────────

function VehicleEffects.ScheduleLoopedEffectStop(handle, delayMs)
    if not handle or handle == 0 then return end

    effectsState.stopQueue[#effectsState.stopQueue + 1] = {
        handle = handle,
        stopAt = GetGameTimer() + math.max(0, math.floor(tonumber(delayMs) or 0))
    }
    startStopQueueThread()
end

-- ── Backfire Offset Calculation ──────────────────────

local function getVehicleFxCacheKey(vehicle, boneNames)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local vehKey = netId > 0 and string.format("n:%s", netId) or string.format("e:%s", vehicle)

    return string.format(
        "%s:m:%s:ex:%s:b:%s",
        vehKey,
        tostring(GetEntityModel(vehicle)),
        tostring(GetVehicleMod(vehicle, 4)),
        table.concat(boneNames, ",")
    )
end

local function buildBoneNameList(extraBones)
    local result = {}
    local seen = {}

    if type(extraBones) == "table" then
        for _, bone in ipairs(extraBones) do
            local name = tostring(bone or "")
            if name ~= "" and not seen[name] then
                result[#result + 1] = name
                seen[name] = true
            end
        end
    end

    for _, bone in ipairs(EXHAUST_BONE_NAMES) do
        if not seen[bone] then
            result[#result + 1] = bone
            seen[bone] = true
        end
    end

    return result
end

local function formatOffset(offset)
    return string.format("%0.2f:%0.2f:%0.2f", offset.x, offset.y, offset.z)
end

local function addBoneOffset(vehicle, boneName, offsets, seen)
    local boneIdx = GetEntityBoneIndexByName(vehicle, boneName)
    if boneIdx == -1 then return end

    local worldPos = GetWorldPositionOfEntityBone(vehicle, boneIdx)
    local localOffset = GetOffsetFromEntityGivenWorldCoords(vehicle, worldPos.x, worldPos.y, worldPos.z)
    local key = formatOffset(localOffset)

    if seen[key] then return end

    offsets[#offsets + 1] = { x = localOffset.x, y = localOffset.y, z = localOffset.z }
    seen[key] = true
end

local function getFallbackBackfireOffsets(vehicle)
    local minDim, maxDim = GetModelDimensions(GetEntityModel(vehicle))
    local halfWidth = math.max(math.abs(minDim.x), math.abs(maxDim.x))
    local rearY = minDim.y - 0.08
    local height = math.max(0.1, maxDim.z - minDim.z)
    local offsetZ = minDim.z + math.max(0.28, height * 0.24)

    if halfWidth >= 0.9 then
        local sideOffset = math.min(0.55, halfWidth * 0.34)
        return {
            { x = -sideOffset, y = rearY, z = offsetZ },
            { x = sideOffset,  y = rearY, z = offsetZ }
        }
    end

    return {
        { x = 0.0, y = rearY, z = offsetZ }
    }
end

local function getBackfireOffsets(vehicle, extraBoneNames)
    local boneNames = buildBoneNameList(extraBoneNames)
    local cacheKey = getVehicleFxCacheKey(vehicle, boneNames)

    local cached = effectsState.backfireOffsetsByKey[cacheKey]
    if type(cached) == "table" and cached.vehicle == vehicle and type(cached.offsets) == "table" then
        return cached.offsets
    end

    local offsets = {}
    local seen = {}

    for _, boneName in ipairs(boneNames) do
        addBoneOffset(vehicle, boneName, offsets, seen)
    end

    if #offsets == 0 then
        offsets = getFallbackBackfireOffsets(vehicle)
    end

    effectsState.backfireOffsetsByKey[cacheKey] = { vehicle = vehicle, offsets = offsets }
    return offsets
end

-- ── Spawn Single Effect ──────────────────────────────

local function spawnBackfireEffect(source, effectName, vehicle, offset, scale, durationMs, alpha)
    UseParticleFxAssetNextCall("core")
    local handle = StartParticleFxLoopedOnEntity(
        effectName, vehicle,
        offset.x, offset.y, offset.z,
        0.0, 0.0, 0.0,
        scale, false, false, false
    )

    if not handle or handle == 0 then
        print(string.format(
            "[sky_mechanicjob][%s] backfire particle effect start failed: effect=%s vehicle=%s offset=(%.2f,%.2f,%.2f)",
            tostring(source), tostring(effectName), tostring(vehicle),
            offset.x, offset.y, offset.z
        ))
        return false
    end

    SetParticleFxLoopedAlpha(handle, alpha)
    SetParticleFxLoopedScale(handle, scale)
    VehicleEffects.ScheduleLoopedEffectStop(handle, durationMs)
    return true
end

-- ── Public: PlayBackfire ─────────────────────────────

function VehicleEffects.PlayBackfire(vehicle, params)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        return false
    end

    params = (type(params) == "table" and params) or {}

    local effectName = tostring(params.effectName or "veh_backfire")
    local scale = math.max(0.01, tonumber(params.scale) or 1.0)
    local durationMs = math.max(1, math.floor(tonumber(params.durationMs) or 100))
    local alpha = math.max(0.0, math.min(1.0, tonumber(params.alpha) or 0.9))
    local offsets = getBackfireOffsets(vehicle, params.exhaustBoneNames)

    local anyStarted = false
    for _, offset in ipairs(offsets) do
        if spawnBackfireEffect(params.source or "vehicle_effects", effectName, vehicle, offset, scale, durationMs, alpha) then
            anyStarted = true
        end
    end

    return anyStarted
end

function VehicleEffects.ClearBackfireCache()
    effectsState.backfireOffsetsByKey = {}
end

-- ── System State Management ──────────────────────────

local function updateInstalledSystems(hasAntiLag, hasTwoStep)
    local systems = effectsState.installedSystems

    if not hasAntiLag and systems.antiLag then
        AntiLag.OnDriverLeftVehicle()
    end

    if not hasTwoStep and systems.twoStep then
        TwoStep.OnDriverLeftVehicle()
    end

    systems.antiLag = hasAntiLag
    systems.twoStep = hasTwoStep
end

local function clearAllInstalledSystems()
    updateInstalledSystems(false, false)
end

local function isDriverOfVehicle(vehicle)
    local _ped = PlayerPedId()
    return vehicle ~= 0
end

local function stopEffectsRuntime()
    effectsState.runtimeToken = effectsState.runtimeToken + 1
    effectsState.runtimeVehicle = 0

    if effectsState.driverActive then
        clearAllInstalledSystems()
        effectsState.driverActive = false
    end
end

local function stopRgbRuntime()
    effectsState.rgbRuntimeToken = effectsState.rgbRuntimeToken + 1
    effectsState.rgbRuntimeVehicle = 0

    if effectsState.rgbRuntimeActive then
        RgbController.OnDriverLeftVehicle()
        effectsState.rgbRuntimeActive = false
    end
end

local function checkInstalledEffectsForVehicle(vehicle)
    local hasAntiLag, antiLagRes, antiLagCfg = AntiLag.IsInstalledForVehicle(vehicle)
    local hasTwoStep, twoStepRes, twoStepCfg = TwoStep.IsInstalledForVehicle(vehicle)
    return hasAntiLag, hasTwoStep, antiLagRes, antiLagCfg, twoStepRes, twoStepCfg
end

-- ── Effects Driver Loop ──────────────────────────────

local function startEffectsDriverLoop(vehicle)
    if not isDriverOfVehicle(vehicle) then
        stopEffectsRuntime()
        return
    end

    local hasAntiLag, hasTwoStep, antiLagRes, antiLagCfg, twoStepRes, twoStepCfg = checkInstalledEffectsForVehicle(vehicle)

    if not hasAntiLag and not hasTwoStep then
        stopEffectsRuntime()
        return
    end

    stopEffectsRuntime()
    effectsState.runtimeToken = effectsState.runtimeToken + 1
    effectsState.runtimeVehicle = vehicle
    effectsState.driverActive = true

    updateInstalledSystems(hasAntiLag, hasTwoStep)

    local myToken = effectsState.runtimeToken
    local state = effectsState.activeState

    CreateThread(function()
        while myToken == effectsState.runtimeToken do
            if not isDriverOfVehicle(vehicle) then break end

            local waitMs = 250
            local now = GetGameTimer()

            state.engineRunning = GetIsVehicleEngineRunning(vehicle)
            state.rpm = GetVehicleCurrentRpm(vehicle)
            state.gear = GetVehicleCurrentGear(vehicle)
            state.speedKmh = GetEntitySpeed(vehicle) * 3.6
            state.throttlePressed = IsControlPressed(1, 71)
            state.brakePressed = IsControlPressed(1, 72)

            if hasAntiLag then
                AntiLag.TickVehicle(vehicle, now, state, antiLagRes, antiLagCfg)
                local suggestedWait = math.floor(tonumber(AntiLag.GetSuggestedWaitMs(vehicle, state, antiLagCfg)) or 250)
                waitMs = math.min(waitMs, math.max(0, suggestedWait))
            end

            if hasTwoStep then
                TwoStep.TickVehicle(vehicle, now, state, twoStepRes, twoStepCfg)
                local suggestedWait = math.floor(tonumber(TwoStep.GetSuggestedWaitMs(vehicle, state, twoStepCfg)) or 250)
                waitMs = math.min(waitMs, math.max(0, suggestedWait))
            end

            Wait(waitMs)
        end

        if myToken == effectsState.runtimeToken then
            stopEffectsRuntime()
        end
    end)
end

-- ── RGB Driver Loop ──────────────────────────────────

local function startRgbDriverLoop(vehicle)
    if not isDriverOfVehicle(vehicle) then
        stopRgbRuntime()
        return
    end

    if not RgbController.HasInstalledEffectsForVehicle(vehicle) then
        stopRgbRuntime()
        return
    end

    stopRgbRuntime()
    effectsState.rgbRuntimeToken = effectsState.rgbRuntimeToken + 1
    effectsState.rgbRuntimeVehicle = vehicle
    effectsState.rgbRuntimeActive = true

    local myToken = effectsState.rgbRuntimeToken

    CreateThread(function()
        while myToken == effectsState.rgbRuntimeToken do
            if not isDriverOfVehicle(vehicle) then break end

            local now = GetGameTimer()
            local suggestedWait = math.floor(tonumber(RgbController.TickVehicle(vehicle, now, nil)) or 250)
            Wait(math.max(0, suggestedWait))
        end

        if myToken == effectsState.rgbRuntimeToken then
            stopRgbRuntime()
        end
    end)
end

-- ── Public: Sync Runtime ─────────────────────────────

function VehicleEffects.SyncRuntimeForCurrentVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 or not DoesEntityExist(vehicle) or GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then
        stopEffectsRuntime()
        stopRgbRuntime()
        return
    end

    local hasAntiLag, hasTwoStep = checkInstalledEffectsForVehicle(vehicle)
    local hasRgb = RgbController.HasInstalledEffectsForVehicle(vehicle)
    local hasAnyEffect = hasAntiLag or hasTwoStep or hasRgb

    if not hasAnyEffect then
        stopEffectsRuntime()
        stopRgbRuntime()
        return
    end

    if hasAntiLag or hasTwoStep then
        startEffectsDriverLoop(vehicle)
    else
        stopEffectsRuntime()
    end

    if hasRgb then
        startRgbDriverLoop(vehicle)
    else
        stopRgbRuntime()
    end
end

-- ── Init ─────────────────────────────────────────────

CreateThread(function()
    while not ensureCorePtfxLoaded() do
        Wait(0)
    end
end)

CreateThread(function()
    ensureCorePtfxLoaded()
    Wait(500)
    VehicleEffects.SyncRuntimeForCurrentVehicle()
end)

AddEventHandler("gameEventTriggered", function(eventName, eventData)
    if eventName == "CEventNetworkPlayerEnteredVehicle" then
        local vehicle = (eventData and eventData[2]) or GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle == 0 or not DoesEntityExist(vehicle) then return end
        if GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then return end

        VehicleEffects.SyncRuntimeForCurrentVehicle()
    elseif eventName == "CEventNetworkPlayerExitedVehicle" then
        if IsPedInAnyVehicle(PlayerPedId(), false) then return end
        stopEffectsRuntime()
        stopRgbRuntime()
    end
end)

AddEventHandler("onResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    stopEffectsRuntime()
    stopRgbRuntime()
end)
