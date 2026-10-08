if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/vehicle_care.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/vehicle_care.lua
--  Vehicle Care, Cleaning, Waxing & Admin Full Repair
-- =====================================================

local CARE_VEHICLE_RANGE = 10.0
local DEFAULT_CARE_ITEMS = { wash = "wash_sponge", wax = "vehicle_wax" }

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
    local netId = math.floor(tonumber(data and data.vehicleNetId) or 0)
    local entity = netId > 0 and NetworkGetEntityFromNetworkId(netId) or 0
    if entity ~= 0 and DoesEntityExist(entity) and GetEntityType(entity) == 2 then
        plate = sanitizePlate(GetVehicleNumberPlateText(entity))
    else
        entity = nil
    end

    if plate == "" then
        return { success = false, error = "invalid_plate" }
    end

    -- Goes through the wear cache so a later part repair cannot write stale values back.
    local entry = MechanicWear.Load(plate)
    if not entry then
        return { success = false, error = "invalid_plate" }
    end

    local wearMap = MechanicWear.ApplyRepair(src, entry, entity, MechanicWear.AllParts, {
        part = "admin_full_repair",
        fullRepair = true,
        resetWheels = true,
        historyAction = "admin_repair",
        historyText = "Admin full vehicle repair & component restoration"
    })

    return {
        success = true,
        wear = wearMap
    }
end)

-- ── Wash / Wax Item Consumption ──────────────────────

-- Called by the client after a successful wash or wax minigame, before the result is kept.
Sky.Cb.Register("sky_mechanicjob:vehicleCare:consume", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local action = tostring(data and data.action or "")
    local defaultItem = DEFAULT_CARE_ITEMS[action]
    if not defaultItem then
        return { success = false, error = "invalid_action" }
    end

    local cfg = Config.VehicleCare and Config.VehicleCare[action]
    cfg = type(cfg) == "table" and cfg or {}
    local item = (type(cfg.item) == "string" and cfg.item ~= "") and cfg.item or defaultItem

    local netId = math.floor(tonumber(data and data.vehicleNetId) or 0)
    if netId <= 0 or not Functions.GetVehicleByNetId(src, netId, CARE_VEHICLE_RANGE) then
        return { success = false, error = "vehicle_too_far" }
    end

    if cfg.removeAfterUse ~= false then
        if not Functions.RemoveItem(src, item, 1) then
            return { success = false, error = "missing_item", requiredItem = item }
        end
    elseif not Functions.HasItem(src, item, 1) then
        return { success = false, error = "missing_item", requiredItem = item }
    end

    return {
        success = true,
        cleanKilometers = action == "wax" and math.max(1, tonumber(cfg.cleanKilometers) or 35) or nil
    }
end)
