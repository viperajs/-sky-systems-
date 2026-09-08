if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/vehicle_persistence.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/vehicle_persistence.lua
--  Tuning, Stance, RGB & Handling Persistence Callbacks
-- =====================================================

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
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
    if not Functions.IsOnDuty(src) then return { success = false, error = "not_on_duty" } end

    local plate = sanitizePlate(data and data.plate)
    local stance = type(data and data.stance) == "table" and data.stance or nil
    local autoCapture = data and data.autoCapture == true

    if plate == "" or not stance then
        return { success = false, error = "invalid_payload" }
    end

    local ok = TuningDB.SaveStanceDefault(plate, stance, autoCapture)
    if not ok then
        return { success = false, error = "save_failed" }
    end

    return {
        success = true,
        stance = stance
    }
end)

Sky.Cb.Register("sky_mechanicjob:stance:save", function(source, data)
    local src = tonumber(source)
    if not Functions.IsOnDuty(src) then return { success = false, error = "not_on_duty" } end

    local plate = sanitizePlate(data and data.plate)
    local stance = type(data and data.stance) == "table" and data.stance or nil

    if plate == "" or not stance then
        return { success = false, error = "invalid_payload" }
    end

    local ok = TuningDB.SaveVehicleTuning(plate, { stance = stance })
    if not ok then
        return { success = false, error = "save_failed" }
    end

    return { success = true }
end)

Sky.Cb.Register("sky_mechanicjob:tuning:saveProperties", function(source, data)
    local src = tonumber(source)
    if not Functions.IsOnDuty(src) then return { success = false, error = "not_on_duty" } end

    local plate = sanitizePlate(data and data.plate)
    local properties = type(data and data.properties) == "table" and data.properties or nil

    if plate == "" or not properties then
        return { success = false, error = "invalid_payload" }
    end

    local ok = TuningDB.SaveVehicleProperties(plate, properties)
    return { success = (ok == true) }
end)

RegisterNetEvent("sky_mechanicjob:tuning:saveProperties", function(data)
    local src = tonumber(source)
    if not Functions.IsOnDuty(src) then return end

    local plate = sanitizePlate(data and data.plate)
    local properties = type(data and data.properties) == "table" and data.properties or nil
    if plate ~= "" and properties then
        TuningDB.SaveVehicleProperties(plate, properties)
    end
end)
