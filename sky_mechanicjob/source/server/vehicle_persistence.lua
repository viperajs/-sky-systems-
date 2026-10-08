if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/vehicle_persistence.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/vehicle_persistence.lua
--  Tuning, Stance, RGB & Handling Persistence Callbacks
-- =====================================================

VehiclePersistence = VehiclePersistence or {}

local EDIT_DISTANCE = 15.0

local STANCE_LIMITS = {
    fCamberFront = 9.0,
    fCamberRear = 9.0,
    trackFront = 3.0,
    trackRear = 3.0,
    trackFrontLeft = 3.0,
    trackFrontRight = 3.0,
    trackRearLeft = 3.0,
    trackRearRight = 3.0,
    suspensionHeight = 2.0
}

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

local function clampNumber(value, minVal, maxVal)
    local num = tonumber(value)
    if not num or num ~= num then return nil end
    return math.max(minVal, math.min(maxVal, num))
end

local function sanitizeStance(stance)
    if type(stance) ~= "table" then return nil end

    local cleaned = {}
    for key, limit in pairs(STANCE_LIMITS) do
        cleaned[key] = clampNumber(stance[key], -limit, limit)
    end
    cleaned.wheelSize = clampNumber(stance.wheelSize, 0.05, 5.0)
    cleaned.wheelWidth = clampNumber(stance.wheelWidth, 0.05, 5.0)
    if stance.enabled ~= nil then
        cleaned.enabled = stance.enabled == true
    end

    return cleaned
end

local function sanitizeHandlingSelections(selections)
    if type(selections) ~= "table" then return nil end

    local cleaned, count = {}, 0
    for key, value in pairs(selections) do
        local index = clampNumber(value, 0, 99)
        if index and type(key) == "string" and key ~= "" and #key <= 64 and count < 32 then
            cleaned[key] = math.floor(index)
            count = count + 1
        end
    end

    return cleaned
end

local function sanitizeEffectRecord(record)
    if type(record) ~= "table" then return nil end

    return {
        installed = record.installed == true,
        enabled = record.enabled == true,
        flameScaleLevel = math.floor(clampNumber(record.flameScaleLevel, 1, 10) or 10),
        volumeLevel = math.floor(clampNumber(record.volumeLevel, 0, 10) or 5),
        installedAt = tostring(record.installedAt or ""):sub(1, 32)
    }
end

--- Contract P: only admins and on-duty mechanics standing next to the vehicle may write its tuning.
---@param src number
---@param plate string sanitized plate
---@param adminPermission? string extra admin permission accepted besides admintuning
---@return boolean, string|nil
local function canEditVehicle(src, plate, adminPermission)
    if not src or src <= 0 then return false, "invalid_source" end

    local isAdmin = Functions.HasPermission(src, "admintuning")
        or (adminPermission ~= nil and Functions.HasPermission(src, adminPermission))
    if not isAdmin and not Functions.IsMechanicOnDuty(src) then
        return false, "not_authorized"
    end

    if not Functions.GetNearbyVehicleByPlate(src, plate, EDIT_DISTANCE) then
        return false, "vehicle_not_found"
    end

    return true
end

--- Saves the client-built extended tuning state (stance, custom handling, anti-lag, two-step).
--- Missing parts keep their stored value. Nitro is only written by the nitro callbacks.
---@param plate string
---@param state table
---@return boolean
function VehiclePersistence.SaveTuningState(plate, state)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" or type(state) ~= "table" then return false end

    local update = {
        stance = sanitizeStance(state.stance),
        custom_handling = type(state.customHandling) == "table" and sanitizeHandlingSelections(state.customHandling.profiles) or nil
    }

    local antiLag = sanitizeEffectRecord(state.antiLag)
    local twoStep = sanitizeEffectRecord(state.twoStep)
    if antiLag or twoStep then
        -- Anti-lag and two-step live in the tuning JSON next to the paint data.
        local current = TuningDB.GetVehicleTuning(cleanPlate)
        local tuning = {}
        if type(current) == "table" and type(current.tuning) == "table" then
            for key, value in pairs(current.tuning) do
                tuning[key] = value
            end
        end
        tuning.antiLag = antiLag or tuning.antiLag
        tuning.twoStep = twoStep or tuning.twoStep
        update.tuning = tuning
    end

    if next(update) == nil then return true end
    return TuningDB.SaveVehicleTuning(cleanPlate, update) == true
end

local function saveProperties(src, data)
    local plate = sanitizePlate(type(data) == "table" and data.plate)
    local properties = type(data) == "table" and type(data.properties) == "table" and data.properties or nil
    if plate == "" or not properties then
        return false, "invalid_payload"
    end

    local allowed, err = canEditVehicle(src, plate)
    if not allowed then return false, err end

    -- The plate key could re-plate the stored garage vehicle; the extended state has its own table.
    local vehicleProps = {}
    for key, value in pairs(properties) do
        if key ~= "_skyMechanicTuning" and key ~= "plate" then
            vehicleProps[key] = value
        end
    end

    local ok = true
    if next(vehicleProps) ~= nil then
        ok = TuningDB.SaveVehicleProperties(plate, vehicleProps) == true
    end
    if type(properties._skyMechanicTuning) == "table" then
        ok = VehiclePersistence.SaveTuningState(plate, properties._skyMechanicTuning) and ok
    end

    if not ok then return false, "save_failed" end
    return true
end

-- ── Stance & Tuning Server Callbacks ─────────────────

Sky.Cb.Register("sky_mechanicjob:tuning:getProperties", function(source, data)
    local plate = sanitizePlate(data and data.plate)
    if plate == "" then
        return { success = false, error = "invalid_plate" }
    end

    local props = TuningDB.GetVehicleProperties(plate)
    if not props then
        return { success = false, error = "not_found" }
    end

    local record = TuningDB.GetVehicleTuning(plate)
    if type(record) == "table" and type(record.tuning) == "table" then
        local tuningState = type(props._skyMechanicTuning) == "table" and props._skyMechanicTuning or {}
        tuningState.antiLag = record.tuning.antiLag
        tuningState.twoStep = record.tuning.twoStep
        props._skyMechanicTuning = tuningState
    end

    return {
        success = true,
        properties = props
    }
end)

Sky.Cb.Register("sky_mechanicjob:stance:loadDefault", function(source, data)
    local plate = sanitizePlate(data and data.plate)
    if plate == "" then
        return { success = false, error = "invalid_plate" }
    end

    local defaultStance = TuningDB.GetStanceDefault(plate)
    if not defaultStance then
        return { success = false, error = "no_default_saved" }
    end

    return {
        success = true,
        stance = defaultStance
    }
end)

Sky.Cb.Register("sky_mechanicjob:stance:saveDefault", function(source, data)
    local src = tonumber(source)
    local plate = sanitizePlate(type(data) == "table" and data.plate)
    local stance = sanitizeStance(type(data) == "table" and data.stance)
    if plate == "" or not stance then
        return { success = false, error = "invalid_payload" }
    end

    local allowed, err = canEditVehicle(src, plate, "debugstancerdefault")
    if not allowed then
        return { success = false, error = err }
    end

    if not TuningDB.SaveStanceDefault(plate, stance, data.autoCapture == true) then
        return { success = false, error = "save_failed" }
    end

    return {
        success = true,
        stance = TuningDB.GetStanceDefault(plate) or stance
    }
end)

Sky.Cb.Register("sky_mechanicjob:stance:save", function(source, data)
    local src = tonumber(source)
    local plate = sanitizePlate(type(data) == "table" and data.plate)
    local stance = sanitizeStance(type(data) == "table" and data.stance)
    if plate == "" or not stance then
        return { success = false, error = "invalid_payload" }
    end

    local allowed, err = canEditVehicle(src, plate)
    if not allowed then
        return { success = false, error = err }
    end

    if not TuningDB.SaveVehicleTuning(plate, { stance = stance }) then
        return { success = false, error = "save_failed" }
    end

    return { success = true }
end)

Sky.Cb.Register("sky_mechanicjob:tuning:saveProperties", function(source, data)
    local ok, err = saveProperties(tonumber(source), data)
    return { success = ok, error = err }
end)

RegisterNetEvent("sky_mechanicjob:tuning:saveProperties", function(data)
    saveProperties(tonumber(source), data)
end)
