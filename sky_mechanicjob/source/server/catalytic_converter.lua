if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/catalytic_converter.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/catalytic_converter.lua
--  Catalytic Converter Theft, Missing State & Smoke Sync
-- =====================================================

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

-- ── Prepare Steal Callback ────────────────────────────

Sky.Cb.Register("sky_mechanicjob:catalytic:prepareSteal", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local plate = sanitizePlate(data and data.plate)
    local netId = tonumber(data and data.vehicleNetId) or 0

    if not Functions.HasItem(src, "lug_wrench", 1) and not Functions.HasItem(src, "mechanic_tools", 1) then
        return { success = false, error = "missing_item" }
    end

    if netId > 0 then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            if Entity(entity).state["sky_mechanic_catalytic_missing"] == true then
                return { success = false, error = "already_missing" }
            end
        end
    end

    if plate ~= "" then
        local row = MySQL.single.await("SELECT plate FROM sky_mechanic_stolen_catalytics WHERE plate = @plate LIMIT 1", {
            ["@plate"] = plate
        })
        if row then
            return { success = false, error = "already_missing" }
        end
    end

    return { success = true }
end)

-- ── Complete Steal Callback ───────────────────────────

Sky.Cb.Register("sky_mechanicjob:catalytic:completeSteal", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local plate = sanitizePlate(data and data.plate)
    local netId = tonumber(data and data.vehicleNetId) or 0

    if not Functions.HasItem(src, "lug_wrench", 1) and not Functions.HasItem(src, "mechanic_tools", 1) then
        return { success = false, error = "missing_item" }
    end

    -- Set entity state bag
    if netId > 0 then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            Entity(entity).state:set("sky_mechanic_catalytic_missing", true, true)
        end
    end

    -- Save stolen state in DB
    if plate ~= "" then
        MySQL.query.await([[
            INSERT INTO sky_mechanic_stolen_catalytics (plate)
            VALUES (@plate)
            ON DUPLICATE KEY UPDATE stolen_at = CURRENT_TIMESTAMP
        ]], { ["@plate"] = plate })

        -- Degrade wear in wear cache/DB
        local currentWear = exports[GetCurrentResourceName()]:GetVehicleWear(plate) or {}
        currentWear.catalytic_converter = 0.0
        exports[GetCurrentResourceName()]:SetVehicleWear(plate, currentWear)
    end

    -- Give stolen catalytic converter item
    Functions.AddItem(src, "catalytic_converter", 1)

    return { success = true }
end)

-- ── Smoke FX Sync Event ──────────────────────────────

RegisterNetEvent("sky_mechanicjob:catalytic:syncSmoke", function(netId, rpmScale)
    local src = source
    local vehicleNetId = tonumber(netId) or 0
    if vehicleNetId <= 0 then return end

    TriggerClientEvent("sky_mechanicjob:catalytic:syncSmoke", -1, vehicleNetId, tonumber(rpmScale) or 1.0)
end)
