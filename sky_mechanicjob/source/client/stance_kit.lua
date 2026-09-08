if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/stance_kit.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/stance_kit.lua
--  Deobfuscated by Claude
--  Original: 3890 lines → Cleaned
-- =====================================================

StanceKit = {}

local STANCE_STATE_BAG_KEY = "sky_mechanicjob:stance"
local VEHICLE_STANCE_DEFAULTS_KEY = "vehicle_stance"

local EPSILON = 0.001
local MOTORBIKE_CLASS = 8
local PERSIST_THROTTLE_MS = 1200

local MAX_SUSPENSION_HEIGHT = 2.0
local MAX_CAMBER = 9.0
local MAX_TRACK_WIDTH = 3.0

local UNSUPPORTED_CLASSES = {
    [8] = true,   -- Motorcycles
    [13] = true,  -- Cycles
    [14] = true,  -- Boats
    [15] = true,  -- Helicopters
    [16] = true,  -- Planes
    [21] = true   -- Trains
}

local activeRuntimeVehicles = {}
local stagedPersistVehicles = {}
local cachedDefaultsByPlate = {}
local hasCachedDefaultByPlate = {}
local autoCapturingPlates = {}
local resetTokenByVehicle = {}
local localResetUntilTimer = {}
local pendingResetByVehicle = {}

local RESET_COOLDOWN_MS = 5000

local function round(val, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.ceil((tonumber(val) or 0) * mult) / mult
end

local function logDebug(msg)
    if Sky and Sky.IsDebugActive and Sky.IsDebugActive() and Sky.Debug then
        Sky.Debug("debug", msg)
    end
end

local function formatStanceDebug(st)
    if type(st) ~= "table" then return "stance=missing" end
    return ("stance=(enabled=%s camberF=%s camberR=%s trackF=%s trackR=%s suspension=%s wheelSize=%s wheelWidth=%s)"):format(
        tostring(st.enabled), tostring(st.fCamberFront), tostring(st.fCamberRear),
        tostring(st.trackFront), tostring(st.trackRear), tostring(st.suspensionHeight),
        tostring(st.wheelSize), tostring(st.wheelWidth)
    )
end

local function markLocalResetActive(vehicle)
    if vehicle ~= 0 and DoesEntityExist(vehicle) then
        localResetUntilTimer[vehicle] = GetGameTimer() + RESET_COOLDOWN_MS
        resetTokenByVehicle[vehicle] = (resetTokenByVehicle[vehicle] or 0) + 1
    end
end

local function isLocalResetActive(vehicle)
    local untilTime = tonumber(localResetUntilTimer[vehicle])
    if not untilTime then return false end
    if untilTime < GetGameTimer() then
        localResetUntilTimer[vehicle] = nil
        return false
    end
    return true
end

local function sanitizePlate(plate)
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate or "") or ""
    if trimmed == "" then return nil end
    return string.upper(trimmed)
end

local function roundScaled(val, scale)
    local num = (tonumber(val) or 0) * scale
    if num >= 0 then
        return math.floor(num + 0.5)
    end
    return math.ceil(num - 0.5)
end

local function setHandlingFloat(vehicle, fieldName, value)
    if value == nil then return end
    SetVehicleHandlingFloat(vehicle, "CCarHandlingData", fieldName, value)
end

local function isNumber(val)
    local num = tonumber(val)
    return num ~= nil and num == num
end

local function clamp(val, minVal, maxVal)
    local num = tonumber(val)
    if not isNumber(num) then return nil end
    if num < minVal then return minVal end
    if num > maxVal then return maxVal end
    return num
end

local function clampScale(val, defaultVal)
    local num = tonumber(val)
    if isNumber(num) and (num <= 0.05 or num > 5.0) then
        return defaultVal
    end
    return num
end

local function sanitizeScale(val)
    return clampScale(val, 1.0)
end

local function applyWheelSizeAndWidth(vehicle, size, width, updateColliders)
    if GetNumModKits(vehicle) > 0 then
        SetVehicleModKit(vehicle, 0)
    end

    if updateColliders == nil then
        updateColliders = true
    end

    size = clampScale(size, nil)
    width = clampScale(width, nil)

    if size ~= nil then
        SetVehicleWheelSize(vehicle, size)
        if updateColliders then
            local colliderSize = round(size / 2, 2)
            for i = 0, 3 do
                pcall(SetVehicleWheelRimColliderSize, vehicle, i, colliderSize)
                if type(SetVehicleWheelTireColliderSize) == "function" then
                    pcall(SetVehicleWheelTireColliderSize, vehicle, i, colliderSize)
                end
            end
        end
    end

    if width ~= nil then
        SetVehicleWheelWidth(vehicle, width)
        if updateColliders then
            local colliderWidth = round(width, 2)
            if type(SetVehicleWheelTireColliderWidth) == "function" then
                for i = 0, 3 do
                    pcall(SetVehicleWheelTireColliderWidth, vehicle, i, colliderWidth)
                end
            end
        end
    end
end

local function logWheelScaleDebug(vehicle, optionId, targetVal)
    if not (Sky and Sky.IsDebugActive and Sky.IsDebugActive() and Sky.Debug) then
        return
    end

    SetTimeout(0, function()
        if vehicle == 0 or not DoesEntityExist(vehicle) then return end

        local tireSize = nil
        if type(GetVehicleWheelTireColliderSize) == "function" then
            local ok, val = pcall(GetVehicleWheelTireColliderSize, vehicle, 0)
            if ok then tireSize = val end
        end

        local tireWidth = nil
        if type(GetVehicleWheelTireColliderWidth) == "function" then
            local ok, val = pcall(GetVehicleWheelTireColliderWidth, vehicle, 0)
            if ok then tireWidth = val end
        end

        logDebug(("[sky_mechanicjob][stance][wheel_scale] id=%s target=%.3f readSize=%.3f readWidth=%.3f tireColliderSize=%s tireColliderWidth=%s wheelMod=%s wheelType=%s"):format(
            tostring(optionId), tonumber(targetVal) or 0.0,
            tonumber(GetVehicleWheelSize(vehicle)) or 0.0,
            tonumber(GetVehicleWheelWidth(vehicle)) or 0.0,
            tostring(tireSize), tostring(tireWidth),
            tostring(GetVehicleMod(vehicle, 23)),
            tostring(GetVehicleWheelType(vehicle))
        ))
    end)
end

local function clampStanceState(st)
    if type(st) ~= "table" then return nil end

    local cleaned = {}
    local camberFront = clamp(st.fCamberFront, -MAX_CAMBER, MAX_CAMBER)
    local camberRear = clamp(st.fCamberRear, -MAX_CAMBER, MAX_CAMBER)

    local trackFront = clamp(st.trackFront, -MAX_TRACK_WIDTH, MAX_TRACK_WIDTH)
    local trackRear = clamp(st.trackRear, -MAX_TRACK_WIDTH, MAX_TRACK_WIDTH)
    local trackFL = clamp(st.trackFrontLeft, -MAX_TRACK_WIDTH, MAX_TRACK_WIDTH)
    local trackFR = clamp(st.trackFrontRight, -MAX_TRACK_WIDTH, MAX_TRACK_WIDTH)
    local trackRL = clamp(st.trackRearLeft, -MAX_TRACK_WIDTH, MAX_TRACK_WIDTH)
    local trackRR = clamp(st.trackRearRight, -MAX_TRACK_WIDTH, MAX_TRACK_WIDTH)

    local susp = clamp(st.suspensionHeight, -MAX_SUSPENSION_HEIGHT, MAX_SUSPENSION_HEIGHT)
    local size = clampScale(st.wheelSize, nil)
    local width = clampScale(st.wheelWidth, nil)

    if camberFront ~= nil then cleaned.fCamberFront = camberFront end
    if camberRear ~= nil then cleaned.fCamberRear = camberRear end
    if trackFront ~= nil then cleaned.trackFront = trackFront end
    if trackRear ~= nil then cleaned.trackRear = trackRear end
    if trackFL ~= nil then cleaned.trackFrontLeft = trackFL end
    if trackFR ~= nil then cleaned.trackFrontRight = trackFR end
    if trackRL ~= nil then cleaned.trackRearLeft = trackRL end
    if trackRR ~= nil then cleaned.trackRearRight = trackRR end
    if susp ~= nil then cleaned.suspensionHeight = susp end
    if size ~= nil then cleaned.wheelSize = size end
    if width ~= nil then cleaned.wheelWidth = width end

    if next(cleaned) then return cleaned end
    return nil
end

local function sanitizeStanceDefault(st)
    local cleaned = clampStanceState(st)
    if type(cleaned) ~= "table" then cleaned = {} end

    cleaned.fCamberFront = tonumber(cleaned.fCamberFront) or 0.0
    cleaned.fCamberRear = tonumber(cleaned.fCamberRear) or 0.0
    cleaned.trackFront = tonumber(cleaned.trackFront) or 0.0
    cleaned.trackRear = tonumber(cleaned.trackRear) or 0.0
    cleaned.trackFrontLeft = tonumber(cleaned.trackFrontLeft)
    cleaned.trackFrontRight = tonumber(cleaned.trackFrontRight)
    cleaned.trackRearLeft = tonumber(cleaned.trackRearLeft)
    cleaned.trackRearRight = tonumber(cleaned.trackRearRight)
    cleaned.suspensionHeight = tonumber(cleaned.suspensionHeight) or 0.0
    cleaned.wheelSize = sanitizeScale(st and st.wheelSize)
    cleaned.wheelWidth = sanitizeScale(st and st.wheelWidth)
    cleaned.enabled = st and st.enabled

    return cleaned
end

local function getDefaultStanceState()
    return {
        fCamberFront = 0.0,
        fCamberRear = 0.0,
        trackFront = 0.0,
        trackRear = 0.0,
        trackFrontLeft = 0.0,
        trackFrontRight = 0.0,
        trackRearLeft = 0.0,
        trackRearRight = 0.0,
        suspensionHeight = 0.0,
        wheelSize = 1.0,
        wheelWidth = 1.0,
        enabled = false
    }
end

local function resolveVehicleDefaultStance(vehicle)
    local cached = StanceKit.GetCachedDefaultForVehicle(vehicle)
    if type(cached) == "table" then return cached end

    local loaded = StanceKit.LoadPersistedForVehicle(vehicle)
    if type(loaded) == "table" then
        local sanitized = sanitizeStanceDefault(loaded)
        sanitized.fCamberFront = 0.0
        sanitized.fCamberRear = 0.0
        sanitized.trackFront = 0.0
        sanitized.trackRear = 0.0
        sanitized.trackFrontLeft = 0.0
        sanitized.trackFrontRight = 0.0
        sanitized.trackRearLeft = 0.0
        sanitized.trackRearRight = 0.0
        return sanitized
    end

    return getDefaultStanceState()
end

local function hasNonZeroStance(st)
    if type(st) ~= "table" then return false end

    if math.abs(tonumber(st.fCamberFront) or 0.0) > EPSILON then return true end
    if math.abs(tonumber(st.fCamberRear) or 0.0) > EPSILON then return true end
    if math.abs(tonumber(st.trackFront) or 0.0) > EPSILON then return true end
    if math.abs(tonumber(st.trackRear) or 0.0) > EPSILON then return true end
    if math.abs(tonumber(st.suspensionHeight) or 0.0) > EPSILON then return true end
    if math.abs((tonumber(st.wheelSize) or 1.0) - 1.0) > EPSILON then return true end
    if math.abs((tonumber(st.wheelWidth) or 1.0) - 1.0) > EPSILON then return true end

    return false
end

local function applyHandlingCamber(vehicle, st)
    if st.fCamberFront ~= nil then
        setHandlingFloat(vehicle, "fCamberFront", st.fCamberFront)
    end
    if st.fCamberRear ~= nil then
        setHandlingFloat(vehicle, "fCamberRear", st.fCamberRear)
    end
end

local function applyWheelOffsets(vehicle, st)
    if st.trackFrontLeft ~= nil or st.trackFrontRight ~= nil then
        SetVehicleWheelXOffset(vehicle, 0, tonumber(st.trackFrontLeft) or 0.0)
        SetVehicleWheelXOffset(vehicle, 1, tonumber(st.trackFrontRight) or 0.0)
    elseif st.trackFront ~= nil then
        SetVehicleWheelXOffset(vehicle, 0, -st.trackFront)
        SetVehicleWheelXOffset(vehicle, 1, st.trackFront)
    end

    if st.trackRearLeft ~= nil or st.trackRearRight ~= nil then
        SetVehicleWheelXOffset(vehicle, 2, tonumber(st.trackRearLeft) or 0.0)
        SetVehicleWheelXOffset(vehicle, 3, tonumber(st.trackRearRight) or 0.0)
    elseif st.trackRear ~= nil then
        SetVehicleWheelXOffset(vehicle, 2, -st.trackRear)
        SetVehicleWheelXOffset(vehicle, 3, st.trackRear)
    end
end

local function applyTrackWidthOffsets(vehicle, st)
    if st.trackFront ~= nil then
        SetVehicleWheelXOffset(vehicle, 0, -st.trackFront)
        SetVehicleWheelXOffset(vehicle, 1, st.trackFront)
    end
    if st.trackRear ~= nil then
        SetVehicleWheelXOffset(vehicle, 2, -st.trackRear)
        SetVehicleWheelXOffset(vehicle, 3, st.trackRear)
    end
end

local function applySuspensionHeight(vehicle, st)
    if st.suspensionHeight ~= nil then
        SetVehicleSuspensionHeight(vehicle, st.suspensionHeight)
    end
end

local function applyStanceDirect(vehicle, st, updateColliders, flag)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end
    if not StanceKit.IsVehicleStanceSupported(vehicle) then return nil end

    local cleaned = clampStanceState(st)
    if not hasNonZeroStance(cleaned) then return nil end

    applyTrackWidthOffsets(vehicle, cleaned)
    applyHandlingCamber(vehicle, cleaned)
    applySuspensionHeight(vehicle, cleaned)

    if updateColliders == true then
        applyWheelSizeAndWidth(vehicle, cleaned.wheelSize, cleaned.wheelWidth, flag)
    end

    return cleaned
end

local function applyStanceNoColliders(vehicle, st)
    local cleaned = clampStanceState(st)
    if not hasNonZeroStance(cleaned) then return nil end

    applyTrackWidthOffsets(vehicle, cleaned)
    applyHandlingCamber(vehicle, cleaned)
    return cleaned
end

local function restoreVehicleStanceToDefault(vehicle)
    local defaultSt = resolveVehicleDefaultStance(vehicle)
    applyWheelOffsets(vehicle, defaultSt)
    applyHandlingCamber(vehicle, defaultSt)
    applySuspensionHeight(vehicle, defaultSt)
    applyWheelSizeAndWidth(vehicle, defaultSt.wheelSize, defaultSt.wheelWidth, false)
    return defaultSt
end

local function staggeredApplyStance(vehicle, st)
    st = sanitizeStanceDefault(st)
    local delays = { 0, 50, 150, 350, 750 }

    for _, delayMs in ipairs(delays) do
        SetTimeout(delayMs, function()
            if vehicle == 0 or not DoesEntityExist(vehicle) or isLocalResetActive(vehicle) then
                return
            end
            applyWheelOffsets(vehicle, st)
            applyHandlingCamber(vehicle, st)
            applySuspensionHeight(vehicle, st)
            applyWheelSizeAndWidth(vehicle, st.wheelSize, st.wheelWidth, false)
        end)
    end
end

local function createGhostVehicleForDefaultStance(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end

    local modelHash = GetEntityModel(vehicle)
    if not modelHash or modelHash == 0 then return nil end

    local wheelType = GetVehicleWheelType(vehicle)
    local mod23 = GetVehicleMod(vehicle, 23)
    local mod24 = GetVehicleMod(vehicle, 24)
    local var23 = GetVehicleModVariation(vehicle, 23)
    local var24 = GetVehicleModVariation(vehicle, 24)

    RequestModel(modelHash)
    local maxWait = GetGameTimer() + 2000
    while not HasModelLoaded(modelHash) and GetGameTimer() < maxWait do
        Wait(0)
    end

    if not HasModelLoaded(modelHash) then return nil end

    local ghostVeh = CreateVehicle(modelHash, 0.0, 0.0, 0.0, 0.0, false, false)
    if ghostVeh == 0 or not DoesEntityExist(ghostVeh) then
        SetModelAsNoLongerNeeded(modelHash)
        return nil
    end

    SetEntityVisible(ghostVeh, false, false)
    SetEntityCollision(ghostVeh, false, false)
    SetEntityInvincible(ghostVeh, true)

    SetVehicleModKit(ghostVeh, 0)
    SetVehicleWheelType(ghostVeh, wheelType)

    if mod23 and mod23 >= 0 then
        SetVehicleMod(ghostVeh, 23, mod23, var23 == true)
    end
    if mod24 and mod24 >= 0 then
        SetVehicleMod(ghostVeh, 24, mod24, var24 == true)
    end

    Wait(0)

    local captured = sanitizeStanceDefault({
        fCamberFront = GetVehicleHandlingFloat(ghostVeh, "CCarHandlingData", "fCamberFront"),
        fCamberRear = GetVehicleHandlingFloat(ghostVeh, "CCarHandlingData", "fCamberRear"),
        trackFront = math.abs(GetVehicleWheelXOffset(ghostVeh, 1)),
        trackRear = math.abs(GetVehicleWheelXOffset(ghostVeh, 3)),
        trackFrontLeft = GetVehicleWheelXOffset(ghostVeh, 0),
        trackFrontRight = GetVehicleWheelXOffset(ghostVeh, 1),
        trackRearLeft = GetVehicleWheelXOffset(ghostVeh, 2),
        trackRearRight = GetVehicleWheelXOffset(ghostVeh, 3),
        suspensionHeight = GetVehicleSuspensionHeight(ghostVeh),
        wheelSize = GetVehicleWheelSize(ghostVeh),
        wheelWidth = GetVehicleWheelWidth(ghostVeh),
        enabled = false
    })

    DeleteVehicle(ghostVeh)
    SetModelAsNoLongerNeeded(modelHash)
    return captured
end

local function captureVehicleDefaultStance(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end

    local ghostSt = createGhostVehicleForDefaultStance(vehicle)
    if type(ghostSt) == "table" then return ghostSt end

    return sanitizeStanceDefault({
        fCamberFront = GetVehicleHandlingFloat(vehicle, "CCarHandlingData", "fCamberFront"),
        fCamberRear = GetVehicleHandlingFloat(vehicle, "CCarHandlingData", "fCamberRear"),
        trackFront = math.abs(GetVehicleWheelXOffset(vehicle, 1)),
        trackRear = math.abs(GetVehicleWheelXOffset(vehicle, 3)),
        trackFrontLeft = GetVehicleWheelXOffset(vehicle, 0),
        trackFrontRight = GetVehicleWheelXOffset(vehicle, 1),
        trackRearLeft = GetVehicleWheelXOffset(vehicle, 2),
        trackRearRight = GetVehicleWheelXOffset(vehicle, 3),
        suspensionHeight = GetVehicleSuspensionHeight(vehicle),
        wheelSize = GetVehicleWheelSize(vehicle),
        wheelWidth = GetVehicleWheelWidth(vehicle)
    })
end

local function sanitizePersistedStance(st)
    local cleaned = clampStanceState(st)
    if type(cleaned) ~= "table" then return nil end
    cleaned.enabled = st.enabled
    return cleaned
end

function StanceKit.LoadPersistedForVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end

    local plate = sanitizePlate(GetVehicleNumberPlateText(vehicle))
    if not plate then return nil end

    if type(cachedDefaultsByPlate[plate]) == "table" then
        return sanitizeStanceDefault(cachedDefaultsByPlate[plate])
    end

    if hasCachedDefaultByPlate[plate] == true then
        return nil
    end

    hasCachedDefaultByPlate[plate] = true
    local res = Sky.Cb.Trigger("sky_mechanicjob:stance:loadDefault", { plate = plate })

    if type(res) == "table" and res.success == true and type(res.stance) == "table" then
        local sanitized = sanitizeStanceDefault(res.stance)
        cachedDefaultsByPlate[plate] = sanitized
        return sanitizeStanceDefault(sanitized)
    end

    return nil
end

local function saveDefaultStanceToServer(vehicle, st, autoCapture)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return false, "vehicle_missing"
    end

    local plate = sanitizePlate(GetVehicleNumberPlateText(vehicle))
    if not plate then
        return false, "plate_missing"
    end

    st = sanitizeStanceDefault(st)
    if type(st) ~= "table" then
        return false, "stance_read_failed"
    end

    st.enabled = true

    local res = Sky.Cb.Trigger("sky_mechanicjob:stance:saveDefault", {
        plate = plate,
        stance = st,
        autoCapture = autoCapture == true
    })

    if type(res) == "table" and res.success == true then
        local savedSt = sanitizePersistedStance(res.stance) or sanitizePersistedStance(st)
        cachedDefaultsByPlate[plate] = savedSt
        hasCachedDefaultByPlate[plate] = true
        return true, plate
    end

    local errReason = (type(res) == "table" and res.error) or "save_failed"
    return false, errReason
end

local function sanitizeStancePayload(st)
    local cleaned = clampStanceState(st)
    if not hasNonZeroStance(cleaned) then return nil end

    local payload = { enabled = true }
    if cleaned.fCamberFront ~= nil then payload.fCamberFront = tonumber(cleaned.fCamberFront) end
    if cleaned.fCamberRear ~= nil then payload.fCamberRear = tonumber(cleaned.fCamberRear) end
    if cleaned.trackFront ~= nil then payload.trackFront = tonumber(cleaned.trackFront) end
    if cleaned.trackRear ~= nil then payload.trackRear = tonumber(cleaned.trackRear) end
    if cleaned.suspensionHeight ~= nil then payload.suspensionHeight = tonumber(cleaned.suspensionHeight) end
    if cleaned.wheelSize ~= nil then payload.wheelSize = clampScale(cleaned.wheelSize, nil) end
    if cleaned.wheelWidth ~= nil then payload.wheelWidth = clampScale(cleaned.wheelWidth, nil) end

    return payload
end

local function setStanceStateBag(vehicle, payload)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    local ok, err = pcall(function()
        Entity(vehicle).state:set(STANCE_STATE_BAG_KEY, payload, true)
    end)

    if not ok then
        logDebug(("[sky_mechanicjob][stance] statebag set failed: vehicle=%s valueType=%s error=%s"):format(
            tostring(vehicle), type(payload), tostring(err)
        ))
        return false
    end
    return true
end

local function clearStanceStateBag(vehicle)
    if not setStanceStateBag(vehicle, nil) then
        setStanceStateBag(vehicle, false)
    end
end

local function resetStanceStateBag(vehicle)
    setStanceStateBag(vehicle, { enabled = false })
end

local function removeStanceStateBag(vehicle)
    pcall(function()
        Entity(vehicle).state:set(VEHICLE_STANCE_DEFAULTS_KEY, nil, true)
    end)
end

local function syncStanceState(vehicle, st)
    local payload = sanitizeStancePayload(st)
    if type(payload) ~= "table" then
        clearStanceStateBag(vehicle)
        return
    end
    setStanceStateBag(vehicle, payload)
end

local function isTuningUiActive()
    return type(TuningState) == "table" and TuningState.active == true
end

local function stageVehicleStanceForPersist(vehicle, st)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local plate = sanitizePlate(GetVehicleNumberPlateText(vehicle))
    if not plate then return end

    local cleaned = clampStanceState(st)
    if not hasNonZeroStance(cleaned) then return end

    stagedPersistVehicles[vehicle] = {
        plate = plate,
        stance = cleaned,
        dirty = true,
        lastPersistAt = tonumber(stagedPersistVehicles[vehicle] and stagedPersistVehicles[vehicle].lastPersistAt) or 0
    }
end

local function persistStagedVehicleStance(vehicle, force)
    local entry = stagedPersistVehicles[vehicle]
    if type(entry) ~= "table" or entry.dirty ~= true then
        return false
    end

    local now = GetGameTimer()
    if not force then
        local lastTime = tonumber(entry.lastPersistAt) or 0
        if (now - lastTime) < PERSIST_THROTTLE_MS then
            return false
        end
    end

    local res = Sky.Cb.Trigger("sky_mechanicjob:stance:save", {
        plate = entry.plate,
        stance = entry.stance
    })

    if type(res) == "table" and res.success == true then
        logDebug(("[sky_mechanicjob][stance] managed persist success: plate=%s force=%s %s"):format(
            tostring(entry.plate), tostring(force == true), formatStanceDebug(entry.stance)
        ))
        entry.dirty = false
        entry.lastPersistAt = now
        stagedPersistVehicles[vehicle] = entry
        return true
    end

    local errText = (type(res) == "table" and res.error) or "save_failed"
    logDebug(("[sky_mechanicjob][stance] managed persist failed: plate=%s force=%s result=%s %s"):format(
        tostring(entry.plate), tostring(force == true), tostring(errText), formatStanceDebug(entry.stance)
    ))
    return false
end

-- Thread 1: Managed persistence background thread
CreateThread(function()
    while true do
        for vehicle, entry in pairs(stagedPersistVehicles) do
            if vehicle == 0 or not DoesEntityExist(vehicle) then
                if type(entry) == "table" and entry.dirty == true then
                    persistStagedVehicleStance(vehicle, true)
                end
                stagedPersistVehicles[vehicle] = nil
            else
                persistStagedVehicleStance(vehicle, false)
            end
        end

        for veh in pairs(pendingResetByVehicle) do
            if veh == 0 or not DoesEntityExist(veh) then
                pendingResetByVehicle[veh] = nil
            end
        end

        Wait(1000)
    end
end)

-- Thread 2: StateBag change handler for network syncing
AddStateBagChangeHandler(STANCE_STATE_BAG_KEY, nil, function(bagName, key, value)
    local vehicle = GetEntityFromStateBagName(bagName)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    if type(value) == "table" and value.enabled == false then
        logDebug(("[sky_mechanicjob][stance] statebag reset received: vehicle=%s rawType=%s"):format(
            tostring(vehicle), type(value)
        ))
        markLocalResetActive(vehicle)
        activeRuntimeVehicles[vehicle] = nil
        stagedPersistVehicles[vehicle] = nil
        resetTokenByVehicle[vehicle] = nil

        local defaultSt = restoreVehicleStanceToDefault(vehicle)
        staggeredApplyStance(vehicle, defaultSt)
        return
    end

    if isLocalResetActive(vehicle) then
        local rawSt = clampStanceState(clampStanceState(value))
        if hasNonZeroStance(rawSt) then
            logDebug(("[sky_mechanicjob][stance] statebag ignored after local reset: vehicle=%s rawType=%s"):format(
                tostring(vehicle), type(value)
            ))
            return
        end
    end

    local token = (resetTokenByVehicle[vehicle] or 0) + 1
    resetTokenByVehicle[vehicle] = token

    local stanceData = clampStanceState(value)
    if not hasNonZeroStance(stanceData) then
        logDebug(("[sky_mechanicjob][stance] statebag cleared: vehicle=%s rawType=%s"):format(
            tostring(vehicle), type(value)
        ))
        activeRuntimeVehicles[vehicle] = nil
        stagedPersistVehicles[vehicle] = nil
        resetTokenByVehicle[vehicle] = nil
        return
    end

    logDebug(("[sky_mechanicjob][stance] statebag received: vehicle=%s token=%s %s"):format(
        tostring(vehicle), tostring(token), formatStanceDebug(stanceData)
    ))
    activeRuntimeVehicles[vehicle] = stanceData

    SetTimeout(500, function()
        if resetTokenByVehicle[vehicle] ~= token then return end
        resetTokenByVehicle[vehicle] = nil

        if vehicle == 0 or not DoesEntityExist(vehicle) or not HasCollisionLoadedAroundEntity(vehicle) then
            return
        end

        logDebug(("[sky_mechanicjob][stance] statebag apply: vehicle=%s token=%s %s"):format(
            tostring(vehicle), tostring(token), formatStanceDebug(stanceData)
        ))
        applyStanceDirect(vehicle, stanceData, true, false)
    end)

    local pedVeh = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == pedVeh then
        local plate = sanitizePlate(GetVehicleNumberPlateText(vehicle))
        if plate then
            local prevPersist = tonumber(stagedPersistVehicles[vehicle] and stagedPersistVehicles[vehicle].lastPersistAt) or 0
            stagedPersistVehicles[vehicle] = {
                plate = plate,
                stance = stanceData,
                dirty = false,
                lastPersistAt = prevPersist
            }
        end
    end
end)

-- Thread 3: Runtime vehicle update loop (every tick)
CreateThread(function()
    while true do
        for vehicle, stanceData in pairs(activeRuntimeVehicles) do
            if vehicle == 0 or not DoesEntityExist(vehicle) then
                activeRuntimeVehicles[vehicle] = nil
                stagedPersistVehicles[vehicle] = nil
                resetTokenByVehicle[vehicle] = nil
                localResetUntilTimer[vehicle] = nil
            else
                applyStanceNoColliders(vehicle, stanceData)
            end
        end
        Wait(0)
    end
end)

function StanceKit.IsVehicleMotorbike(vehicle)
    return GetVehicleClass(vehicle) == MOTORBIKE_CLASS
end

function StanceKit.IsVehicleStanceSupported(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    local vehClass = GetVehicleClass(vehicle)
    return UNSUPPORTED_CLASSES[vehClass] ~= true
end

function StanceKit.ReadVehicleStance(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) or not StanceKit.IsVehicleStanceSupported(vehicle) then
        return nil
    end

    if isLocalResetActive(vehicle) then
        return getDefaultStanceState()
    end

    local rawData = activeRuntimeVehicles[vehicle] or Entity(vehicle).state[STANCE_STATE_BAG_KEY]
    local stanceData = clampStanceState(rawData)
    if hasNonZeroStance(stanceData) then
        return stanceData
    end

    return {
        fCamberFront = 0.0,
        fCamberRear = 0.0,
        trackFront = 0.0,
        trackRear = 0.0,
        suspensionHeight = GetVehicleSuspensionHeight(vehicle),
        wheelSize = sanitizeScale(GetVehicleWheelSize(vehicle)),
        wheelWidth = sanitizeScale(GetVehicleWheelWidth(vehicle))
    }
end

function StanceKit.BuildPersistedState(vehicle)
    if type(pendingResetByVehicle[vehicle]) == "table" then
        return { enabled = false }
    end

    if isLocalResetActive(vehicle) then
        return { enabled = false }
    end

    local rawData = activeRuntimeVehicles[vehicle] or Entity(vehicle).state[STANCE_STATE_BAG_KEY]
    local stanceData = clampStanceState(rawData)
    if not hasNonZeroStance(stanceData) then return nil end

    return {
        enabled = true,
        fCamberFront = stanceData.fCamberFront,
        fCamberRear = stanceData.fCamberRear,
        trackFront = stanceData.trackFront,
        trackRear = stanceData.trackRear,
        suspensionHeight = stanceData.suspensionHeight,
        wheelSize = clampScale(stanceData.wheelSize, nil),
        wheelWidth = clampScale(stanceData.wheelWidth, nil)
    }
end

function StanceKit.ClearPendingReset(vehicle)
    pendingResetByVehicle[vehicle] = nil
end

function StanceKit.RestorePreviewState(vehicle, st, origPlate)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    pendingResetByVehicle[vehicle] = nil

    local currentPlate = sanitizePlate(GetVehicleNumberPlateText(vehicle))
    local expectedPlate = sanitizePlate(origPlate)

    if expectedPlate and currentPlate and expectedPlate ~= currentPlate then
        return false
    end

    if type(st) == "table" then
        StanceKit.ApplyPersistedState(vehicle, st)
        StanceKit.EnsureRuntimeForVehicle(vehicle)
        return true
    end

    if StanceKit.LoadPersistedForVehicle(vehicle) then
        StanceKit.EnsureRuntimeForVehicle(vehicle)
        return true
    end

    markLocalResetActive(vehicle)
    activeRuntimeVehicles[vehicle] = nil
    stagedPersistVehicles[vehicle] = nil
    clearStanceStateBag(vehicle)
    restoreVehicleStanceToDefault(vehicle)
    return true
end

function StanceKit.SanitizePersistedState(st)
    return sanitizePersistedStance(st)
end

function StanceKit.SanitizeDefaultState(st)
    return sanitizeStanceDefault(st)
end

function StanceKit.SaveCurrentAsDefault(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return false, "vehicle_missing"
    end

    if not StanceKit.IsVehicleStanceSupported(vehicle) then
        return false, "vehicle_class_disabled"
    end

    return saveDefaultStanceToServer(vehicle, captureVehicleDefaultStance(vehicle))
end

function StanceKit.CacheDefaultForVehicle(vehicle, st)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    local plate = sanitizePlate(GetVehicleNumberPlateText(vehicle))
    local sanitized = sanitizeStanceDefault(st)

    if not plate or type(sanitized) ~= "table" then return false end

    cachedDefaultsByPlate[plate] = sanitized
    hasCachedDefaultByPlate[plate] = true
    return true
end

function StanceKit.GetCachedDefaultForVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end

    local plate = sanitizePlate(GetVehicleNumberPlateText(vehicle))
    if plate and type(cachedDefaultsByPlate[plate]) == "table" then
        return sanitizeStanceDefault(cachedDefaultsByPlate[plate])
    end

    return nil
end

function StanceKit.EnsureDefaultForVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return false, "vehicle_missing"
    end

    if not StanceKit.IsVehicleStanceSupported(vehicle) then
        return false, "vehicle_class_disabled"
    end

    local plate = sanitizePlate(GetVehicleNumberPlateText(vehicle))
    if not plate then
        return false, "plate_missing"
    end

    if type(cachedDefaultsByPlate[plate]) == "table" or autoCapturingPlates[plate] == true then
        return true, "cached"
    end

    local loaded = StanceKit.LoadPersistedForVehicle(vehicle)
    if type(loaded) == "table" then
        return true, "loaded"
    end

    local activeSt = clampStanceState(activeRuntimeVehicles[vehicle] or Entity(vehicle).state[STANCE_STATE_BAG_KEY])
    if hasNonZeroStance(activeSt) then
        logDebug(("[sky_mechanicjob][stance] default auto-capture skipped: plate=%s reason=active_stance %s"):format(
            tostring(plate), formatStanceDebug(activeSt)
        ))
        return false, "active_stance"
    end

    local captured = captureVehicleDefaultStance(vehicle)
    if type(captured) ~= "table" then
        return false, "capture_failed"
    end

    cachedDefaultsByPlate[plate] = sanitizePersistedStance(captured)
    autoCapturingPlates[plate] = true
    hasCachedDefaultByPlate[plate] = true

    CreateThread(function()
        if vehicle ~= 0 and DoesEntityExist(vehicle) then
            saveDefaultStanceToServer(vehicle, captured, true)
        end
        autoCapturingPlates[plate] = nil
    end)

    logDebug(("[sky_mechanicjob][stance] default auto-captured: plate=%s %s"):format(
        tostring(plate), formatStanceDebug(captured)
    ))
    return true, "captured"
end

function StanceKit.ApplyStanceToVehicle(vehicle, st)
    if vehicle == 0 or not DoesEntityExist(vehicle) or not StanceKit.IsVehicleStanceSupported(vehicle) then
        return nil
    end

    local stanceData = clampStanceState(st)
    if not hasNonZeroStance(stanceData) then return nil end

    localResetUntilTimer[vehicle] = nil
    pendingResetByVehicle[vehicle] = nil

    applyStanceDirect(vehicle, stanceData, true, false)
    activeRuntimeVehicles[vehicle] = stanceData

    syncStanceState(vehicle, stanceData)

    if not isTuningUiActive() then
        stageVehicleStanceForPersist(vehicle, stanceData)
    end

    return stanceData
end

function StanceKit.StopRuntimeLoop()
end

function StanceKit.EnsureRuntimeForVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local plate = sanitizePlate(GetVehicleNumberPlateText(vehicle))
    if plate and stagedPersistVehicles[vehicle] then
        local entry = stagedPersistVehicles[vehicle]
        if type(entry.stance) == "table" then
            activeRuntimeVehicles[vehicle] = entry.stance
            return
        end
    end

    local stanceData = clampStanceState(Entity(vehicle).state[STANCE_STATE_BAG_KEY])
    if hasNonZeroStance(stanceData) then
        activeRuntimeVehicles[vehicle] = stanceData
    end
end

function StanceKit.CacheFromVehicle(vehicle)
    local stanceData = clampStanceState(Entity(vehicle).state[STANCE_STATE_BAG_KEY])
    if not hasNonZeroStance(stanceData) then return end

    activeRuntimeVehicles[vehicle] = stanceData
    if not isTuningUiActive() then
        stageVehicleStanceForPersist(vehicle, stanceData)
    end
end

function StanceKit.ApplyPersistedState(vehicle, rawStance)
    pendingResetByVehicle[vehicle] = nil

    if vehicle ~= 0 and DoesEntityExist(vehicle) and not StanceKit.IsVehicleStanceSupported(vehicle) then
        activeRuntimeVehicles[vehicle] = nil
        stagedPersistVehicles[vehicle] = nil
        clearStanceStateBag(vehicle)
        return
    end

    if type(rawStance) ~= "table" then
        if vehicle ~= 0 and DoesEntityExist(vehicle) then
            logDebug(("[sky_mechanicjob][stance] apply persisted clear: vehicle=%s reason=raw_missing"):format(tostring(vehicle)))
            activeRuntimeVehicles[vehicle] = nil
            stagedPersistVehicles[vehicle] = nil
            clearStanceStateBag(vehicle)
        end
        return
    end

    if rawStance.enabled == false then
        logDebug(("[sky_mechanicjob][stance] apply persisted reset: vehicle=%s %s"):format(
            tostring(vehicle), formatStanceDebug(rawStance)
        ))
        markLocalResetActive(vehicle)
        activeRuntimeVehicles[vehicle] = nil
        stagedPersistVehicles[vehicle] = nil

        resetStanceStateBag(vehicle)
        removeStanceStateBag(vehicle)

        local defaultSt = restoreVehicleStanceToDefault(vehicle)
        staggeredApplyStance(vehicle, defaultSt)
        return
    end

    local stanceData = clampStanceState(rawStance)
    if not hasNonZeroStance(stanceData) then
        logDebug(("[sky_mechanicjob][stance] apply persisted skipped: vehicle=%s reason=no_actual_tuning %s"):format(
            tostring(vehicle), formatStanceDebug(rawStance)
        ))
        return
    end

    logDebug(("[sky_mechanicjob][stance] apply persisted: vehicle=%s %s"):format(
        tostring(vehicle), formatStanceDebug(stanceData)
    ))

    localResetUntilTimer[vehicle] = nil
    applyStanceDirect(vehicle, stanceData, true, false)

    activeRuntimeVehicles[vehicle] = stanceData
    syncStanceState(vehicle, stanceData)

    local plate = sanitizePlate(GetVehicleNumberPlateText(vehicle))
    if plate then
        local prevPersist = tonumber(stagedPersistVehicles[vehicle] and stagedPersistVehicles[vehicle].lastPersistAt) or 0
        stagedPersistVehicles[vehicle] = {
            plate = plate,
            stance = stanceData,
            dirty = false,
            lastPersistAt = prevPersist
        }
    end
end

function StanceKit.AddOptions(arg1, arg2)
    local addOptionFunc = (type(arg1) == "function" and arg1) or (type(arg2) == "function" and arg2)
    local vehicle = (type(arg1) == "number" and arg1) or (type(arg2) == "number" and arg2)

    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if not addOptionFunc then return end
    if not StanceKit.IsVehicleStanceSupported(vehicle) then return end

    StanceKit.EnsureDefaultForVehicle(vehicle)

    local function addStancerSubOption(optionId, labelText, currentVal, boundsCfg, cameraPart, scaleFactor)
        local scaledVal = roundScaled(currentVal, scaleFactor)
        if scaledVal < boundsCfg.min then scaledVal = boundsCfg.min end
        if scaledVal > boundsCfg.max then scaledVal = boundsCfg.max end

        addOptionFunc("stancer", optionId, labelText, scaledVal, boundsCfg.min, boundsCfg.max, nil, cameraPart, {
            kind = "stancer",
            scale = scaleFactor,
            step = 1
        })
    end

    local stancerBounds = STANCER_OPTION_BOUNDS or {
        camber_front = { min = -45, max = 45 },
        camber_rear = { min = -45, max = 45 },
        track_width_front = { min = 0, max = 150 },
        track_width_rear = { min = 0, max = 150 },
        suspension_height = { min = -30, max = 30 }
    }

    local wheelSizeBounds = WHEEL_SIZE_OPTION_BOUNDS or {
        size = { min = 50, max = 150 },
        width = { min = 50, max = 150 }
    }

    local currentStance = {}
    if not isLocalResetActive(vehicle) then
        local rawData = activeRuntimeVehicles[vehicle] or Entity(vehicle).state[STANCE_STATE_BAG_KEY]
        currentStance = clampStanceState(rawData) or currentStance
    end

    addStancerSubOption("stancer_camber_front", getNuiLocale("option.label.stancer_camber_front", "Front Camber"), tonumber(currentStance.fCamberFront) or 0.0, stancerBounds.camber_front, "wheels_front", STANCER_SCALE)
    addStancerSubOption("stancer_camber_rear", getNuiLocale("option.label.stancer_camber_rear", "Rear Camber"), tonumber(currentStance.fCamberRear) or 0.0, stancerBounds.camber_rear, "wheels_rear", STANCER_SCALE)
    addStancerSubOption("stancer_track_width_front", getNuiLocale("option.label.stancer_track_width_front", "Front Track Width"), tonumber(currentStance.trackFront) or 0.0, stancerBounds.track_width_front, "wheels_front", STANCER_SCALE)
    addStancerSubOption("stancer_track_width_rear", getNuiLocale("option.label.stancer_track_width_rear", "Rear Track Width"), tonumber(currentStance.trackRear) or 0.0, stancerBounds.track_width_rear, "wheels_rear", STANCER_SCALE)

    local sizeVal = tonumber(currentStance.wheelSize) or clampScale(GetVehicleWheelSize(vehicle), 1.0)
    addStancerSubOption("wheel_size", getNuiLocale("option.label.wheel_size", "Wheel Size"), sizeVal, wheelSizeBounds.size, "wheels_front", WHEEL_SIZE_SCALE)

    local widthVal = tonumber(currentStance.wheelWidth) or clampScale(GetVehicleWheelWidth(vehicle), 1.0)
    addStancerSubOption("wheel_width", getNuiLocale("option.label.wheel_width", "Wheel Width"), widthVal, wheelSizeBounds.width, "wheels_front", WHEEL_SIZE_SCALE)

    local suspVal = tonumber(currentStance.suspensionHeight) or GetVehicleSuspensionHeight(vehicle)
    addStancerSubOption("stancer_suspension_height", getNuiLocale("option.label.stancer_suspension_height", "Suspension Height"), suspVal, stancerBounds.suspension_height, "wheels_rear", STANCER_SCALE)
end

function StanceKit.ApplyOption(vehicle, option, rawVal)
    if not StanceKit.IsVehicleStanceSupported(vehicle) then return false end

    local scaleFactor = option.scale or STANCER_SCALE
    local sizeVal, widthVal = nil, nil

    if option.id == "wheel_size" then
        local scale = option.scale or WHEEL_SIZE_SCALE or 100
        sizeVal = rawVal / scale
    elseif option.id == "wheel_width" then
        local scale = option.scale or WHEEL_SIZE_SCALE or 100
        widthVal = rawVal / scale
    elseif option.id ~= "stancer_camber_front" and option.id ~= "stancer_camber_rear" and option.id ~= "stancer_track_width_front" and option.id ~= "stancer_track_width_rear" and option.id ~= "stancer_suspension_height" then
        return false
    end

    option.value = rawVal
    pendingResetByVehicle[vehicle] = nil

    local currentStance = {}
    if not isLocalResetActive(vehicle) then
        local rawData = activeRuntimeVehicles[vehicle] or Entity(vehicle).state[STANCE_STATE_BAG_KEY]
        currentStance = clampStanceState(rawData) or currentStance
    end

    if option.id == "stancer_camber_front" then
        currentStance.fCamberFront = rawVal / scaleFactor
    elseif option.id == "stancer_camber_rear" then
        currentStance.fCamberRear = rawVal / scaleFactor
    elseif option.id == "stancer_track_width_front" then
        currentStance.trackFront = rawVal / scaleFactor
    elseif option.id == "stancer_track_width_rear" then
        currentStance.trackRear = rawVal / scaleFactor
    elseif option.id == "stancer_suspension_height" then
        currentStance.suspensionHeight = rawVal / scaleFactor
    end

    if sizeVal ~= nil then currentStance.wheelSize = sizeVal end
    if widthVal ~= nil then currentStance.wheelWidth = widthVal end

    local cleaned = clampStanceState(currentStance)
    if hasNonZeroStance(cleaned) then
        localResetUntilTimer[vehicle] = nil
        applyStanceDirect(vehicle, cleaned, sizeVal ~= nil or widthVal ~= nil, false)
        activeRuntimeVehicles[vehicle] = cleaned
        syncStanceState(vehicle, cleaned)

        if not isTuningUiActive() then
            stageVehicleStanceForPersist(vehicle, cleaned)
        end
    else
        applyTrackWidthOffsets(vehicle, cleaned)
        applyHandlingCamber(vehicle, cleaned)
        applySuspensionHeight(vehicle, cleaned)
        applyWheelSizeAndWidth(vehicle, cleaned.wheelSize, cleaned.wheelWidth, false)

        activeRuntimeVehicles[vehicle] = nil
        stagedPersistVehicles[vehicle] = nil
        clearStanceStateBag(vehicle)
    end

    if type(TuningState) == "table" and TuningState.active == true then
        TuningState.stanceDirty = true
    end

    if sizeVal ~= nil then
        logWheelScaleDebug(vehicle, option.id, sizeVal)
    elseif widthVal ~= nil then
        logWheelScaleDebug(vehicle, option.id, widthVal)
    end

    return true
end

function StanceKit.ResetToDefault(vehicle, saveToServer)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    if not StanceKit.IsVehicleStanceSupported(vehicle) then
        activeRuntimeVehicles[vehicle] = nil
        stagedPersistVehicles[vehicle] = nil
        clearStanceStateBag(vehicle)
        removeStanceStateBag(vehicle)
        return true
    end

    markLocalResetActive(vehicle)
    activeRuntimeVehicles[vehicle] = nil
    stagedPersistVehicles[vehicle] = nil
    pendingResetByVehicle[vehicle] = { enabled = false }

    resetStanceStateBag(vehicle)
    removeStanceStateBag(vehicle)

    local defaultSt = restoreVehicleStanceToDefault(vehicle)
    staggeredApplyStance(vehicle, defaultSt)

    if type(TuningState) == "table" and TuningState.active == true and TuningState.vehicle == vehicle then
        TuningState.stanceDirty = true
    end

    if saveToServer == true then
        local plate = sanitizePlate(GetVehicleNumberPlateText(vehicle))
        if plate then
            logDebug(("[sky_mechanicjob][stance] reset persisted: plate=%s %s"):format(
                tostring(plate), formatStanceDebug({ enabled = false })
            ))
            Sky.Cb.Trigger("sky_mechanicjob:stance:save", {
                plate = plate,
                stance = { enabled = false }
            })
        end
    end

    return true
end

RegisterNetEvent("sky_mechanicjob:debug:saveCurrentStanceAsDefault", function()
    if not (Sky and Sky.IsDebugActive and Sky.IsDebugActive()) then
        if Sky and Sky.Show and Sky.Show.Notification then
            local title = tuningLocales and tuningLocales.Title or "Tuning"
            Sky.Show.Notification(title, "Debug mode must be enabled to use this command.", "error")
        end
        return
    end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        if Sky and Sky.Show and Sky.Show.Notification then
            local title = tuningLocales and tuningLocales.Title or "Tuning"
            Sky.Show.Notification(title, "You must be sitting in a vehicle.", "error")
        end
        return
    end

    local ok, res = StanceKit.SaveCurrentAsDefault(vehicle)
    local title = tuningLocales and tuningLocales.Title or "Tuning"

    if ok then
        if Sky and Sky.Show and Sky.Show.Notification then
            Sky.Show.Notification(title, ("Saved current stance as default for plate %s."):format(tostring(res)), "success")
        end
        return
    end

    if Sky and Sky.Show and Sky.Show.Notification then
        Sky.Show.Notification(title, ("Failed to save stance default: %s"):format(tostring(res)), "error")
    end
end)
