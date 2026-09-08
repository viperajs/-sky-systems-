if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/vehicle_care.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/vehicle_care.lua
--  Vehicle Care, Cleaning, Waxing & Admin Full Repair
-- =====================================================

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

-- ── Admin Vehicle Repair Callback ─────────────────────

Sky.Cb.Register("sky_mechanicjob:wear:adminRepairVehicle", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    if not Functions.HasPermission(src, "adminrepair") then
        return { success = false, error = "not_authorized" }
    end

    local plate = sanitizePlate(data and data.plate)
    local netId = tonumber(data and data.vehicleNetId) or 0

    if plate == "" then
        return { success = false, error = "invalid_plate" }
    end

    local fullWear = {
        tyres = 100.0,
        brake_pads = 100.0,
        suspension = 100.0,
        spark_plugs = 100.0,
        engine_oil = 100.0,
        coolant = 100.0,
        brake_fluid = 100.0,
        transmission_fluid = 100.0,
        clutch = 100.0,
        air_filter = 100.0,
        catalytic_converter = 100.0,
        traction_battery = 100.0,
        inverter = 100.0
    }

    -- Reset wear in DB
    MySQL.query.await([[
        INSERT INTO sky_mechanic_vehicle_wear (plate, mileage, wear)
        VALUES (@plate, 0, @wear)
        ON DUPLICATE KEY UPDATE wear = @wear
    ]], {
        ["@plate"] = plate,
        ["@wear"] = json.encode(fullWear)
    })

    -- Remove stolen catalytic flag if present
    MySQL.query.await("DELETE FROM sky_mechanic_stolen_catalytics WHERE plate = @plate", { ["@plate"] = plate })

    -- Reset entity state bags if entity exists
    if netId > 0 then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            Entity(entity).state:set("sky_mechanic_catalytic_missing", nil, true)
            Entity(entity).state:set("sky_mechanic_wheel_damage", nil, true)
        end
    end

    -- Broadcast part repaired to sync clients
    TriggerClientEvent("sky_mechanicjob:wear:partRepaired", -1, {
        plate = plate,
        fullRepair = true,
        part = "admin_full_repair",
        wear = fullWear
    })

    VehicleHistory.Add(
        plate,
        "admin_repair",
        "Admin full vehicle repair & component restoration",
        src,
        0
    )

    return {
        success = true,
        wear = fullWear
    }
end)
