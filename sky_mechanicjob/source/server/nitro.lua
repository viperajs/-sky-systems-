if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/nitro.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/nitro.lua
--  Nitro Kit Installation, Bottle Management & State Sync
-- =====================================================

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

local function getMaxBottles()
    return math.max(1, math.floor(tonumber(Config and Config.Nitro and Config.Nitro.maxBottles) or 3))
end

local function getNitroItemName()
    return tostring((Config and Config.Nitro and Config.Nitro.item) or "nitro_kit")
end

-- ── Install / Add Bottle Callback ─────────────────────

Sky.Cb.Register("sky_mechanicjob:nitro:install", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local isMechanicOnly = Config and Config.Nitro and Config.Nitro.mechanicOnly ~= false
    if isMechanicOnly and not Functions.IsOnDuty(src) then
        TriggerClientEvent("sky_mechanicjob:nitro:showError", src, "not_authorized")
        return { success = false, error = "not_authorized" }
    end

    local itemName = getNitroItemName()
    if not Functions.HasItem(src, itemName, 1) then
        return { success = false, error = "missing_item" }
    end

    local plate = sanitizePlate(data and data.plate)
    if plate == "" then
        return { success = false, error = "invalid_plate" }
    end

    local existingTuning = TuningDB.GetVehicleTuning(plate) or {}
    local nitro = existingTuning.nitro or { installed = false, bottles = 0, level = 0 }

    local maxBottles = getMaxBottles()
    local action = "install"

    if nitro.installed == true then
        local currentBottles = math.floor(tonumber(nitro.bottles) or 1)
        if currentBottles >= maxBottles then
            return { success = false, error = "max_bottles" }
        end
        nitro.bottles = currentBottles + 1
        nitro.level = 100
        action = "add_bottle"
    else
        nitro = {
            installed = true,
            bottles = 1,
            level = 100
        }
        action = "install"
    end

    if not Functions.RemoveItem(src, itemName, 1) then
        return { success = false, error = "missing_item" }
    end

    TuningDB.SaveVehicleTuning(plate, { nitro = nitro })

    VehicleHistory.Add(
        plate,
        "nitro_installed",
        string.format("Nitro bottle installed (%d/%d)", nitro.bottles, maxBottles),
        src,
        0
    )

    return {
        success = true,
        action = action,
        nitro = nitro
    }
end)

-- ── Update State Callback ─────────────────────────────

Sky.Cb.Register("sky_mechanicjob:nitro:updateState", function(source, data)
    local plate = sanitizePlate(data and data.plate)
    local nitro = type(data and data.nitro) == "table" and data.nitro or nil

    if plate == "" or not nitro then
        return { success = false, error = "invalid_payload" }
    end

    TuningDB.SaveVehicleTuning(plate, { nitro = nitro })
    return { success = true }
end)
