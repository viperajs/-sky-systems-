if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/wear.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_mechanicjob · source/server/wear.lua
--  Vehicle Wear Tracking, Mileage Sync & Part Repairs
-- =====================================================

local wearCacheByPlate = {}
local lastDbSaveByPlate = {}

local ALL_WEAR_PARTS = {
    "tyres", "brake_pads", "suspension", "spark_plugs",
    "engine_oil", "coolant", "brake_fluid", "transmission_fluid",
    "clutch", "air_filter", "catalytic_converter", "traction_battery", "inverter"
}

local PART_ITEM_MAP = {
    tyres = { item = "wheels", flow = "wheel" },
    brake_pads = { item = "brakes", flow = "wheel" },
    suspension = { item = "suspension", flow = "wheel" },
    spark_plugs = { item = "spark_plugs", flow = "hood_install" },
    engine_oil = { item = "engine_oil", flow = "oil_change" },
    coolant = { item = "engine_coolant", flow = "fluid_refill" },
    brake_fluid = { item = "brake_fluid", flow = "fluid_refill" },
    transmission_fluid = { item = "transmission_fluid", flow = "fluid_refill" },
    clutch = { item = "transmission", flow = "hood_install" },
    air_filter = { item = "air_filter", flow = "hood_install" },
    catalytic_converter = { item = "catalytic_converter", flow = "catalytic_converter" },
    traction_battery = { item = "traction_battery", flow = "hood_install" },
    inverter = { item = "inverter", flow = "hood_install" },
    repair_kit = { item = "fix_kit", flow = "hood_install" }
}

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

local function getDefaultWearMap()
    local map = {}
    for _, part in ipairs(ALL_WEAR_PARTS) do
        map[part] = 100.0
    end
    return map
end

--- Load wear and mileage for plate from cache or database
---@param plate string
---@return table wearMap, number mileage
local function loadVehicleWear(plate)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" then return getDefaultWearMap(), 0.0 end

    if wearCacheByPlate[cleanPlate] then
        return wearCacheByPlate[cleanPlate].wear, wearCacheByPlate[cleanPlate].mileage
    end

    local row = MySQL.single.await([[
        SELECT mileage, wear FROM sky_mechanic_vehicle_wear
        WHERE plate = @plate LIMIT 1
    ]], { ["@plate"] = cleanPlate })

    local wearMap = getDefaultWearMap()
    local mileage = 0.0

    if row then
        mileage = tonumber(row.mileage) or 0.0
        if row.wear then
            local decoded = json.decode(row.wear)
            if type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    wearMap[k] = tonumber(v) or 100.0
                end
            end
        end
    else
        -- Initialize row in DB safely
        pcall(function()
            MySQL.query.await([[
                INSERT INTO sky_mechanic_vehicle_wear (plate, mileage, wear)
                VALUES (@plate, 0, @wear)
                ON DUPLICATE KEY UPDATE plate = VALUES(plate)
            ]], {
                ["@plate"] = cleanPlate,
                ["@wear"] = json.encode(wearMap)
            })
        end)
    end

    wearCacheByPlate[cleanPlate] = {
        wear = wearMap,
        mileage = mileage
    }

    return wearMap, mileage
end

--- Save vehicle wear and mileage to database
---@param plate string
---@param wearMap table
---@param mileage number
local function saveVehicleWear(plate, wearMap, mileage)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" or type(wearMap) ~= "table" then return end

    wearCacheByPlate[cleanPlate] = {
        wear = wearMap,
        mileage = tonumber(mileage) or 0.0
    }

    MySQL.query.await([[
        INSERT INTO sky_mechanic_vehicle_wear (plate, mileage, wear)
        VALUES (@plate, @mileage, @wear)
        ON DUPLICATE KEY UPDATE mileage = @mileage, wear = @wear
    ]], {
        ["@plate"] = cleanPlate,
        ["@mileage"] = tonumber(mileage) or 0.0,
        ["@wear"] = json.encode(wearMap)
    })
end

-- ── Server Callbacks ─────────────────────────────────

Sky.Cb.Register("sky_mechanicjob:wear:get", function(source, data)
    local plate = sanitizePlate(data and data.plate)
    if plate == "" then
        return { success = false, error = "invalid_plate", wear = getDefaultWearMap(), mileage = 0 }
    end

    local wearMap, mileage = loadVehicleWear(plate)
    return {
        success = true,
        wear = wearMap,
        mileage = mileage
    }
end)

Sky.Cb.Register("sky_mechanicjob:wear:save", function(source, data)
    local plate = sanitizePlate(data and data.plate)
    local wearMap = type(data and data.wear) == "table" and data.wear or nil
    local mileage = tonumber(data and data.mileage) or 0.0

    if plate == "" or not wearMap then
        return { success = false, error = "invalid_payload" }
    end

    saveVehicleWear(plate, wearMap, mileage)
    return { success = true }
end)

Sky.Cb.Register("sky_mechanicjob:wear:prepareRepairInstall", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    if not Functions.IsOnDuty(src) then
        return { success = false, error = "not_on_duty" }
    end

    local partKey = tostring(data and data.part or "")
    local mapping = PART_ITEM_MAP[partKey] or { item = "mechanic_tools", flow = "hood_install" }
    local reqItem = mapping.item

    if not Functions.HasItem(src, reqItem, 1) then
        return {
            success = false,
            error = "missing_item",
            requiredItem = reqItem
        }
    end

    return {
        success = true,
        data = {
            part = partKey,
            requiredItem = reqItem,
            removeRequiredItemAfterUse = true,
            flow = mapping.flow
        }
    }
end)

Sky.Cb.Register("sky_mechanicjob:wear:completeRepairInstall", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local plate = sanitizePlate(data and data.plate)
    local partKey = tostring(data and data.part or "")
    local netId = tonumber(data and data.vehicleNetId) or 0
    local removeReqItem = data and data.removeRequiredItemAfterUse == true
    local mapping = PART_ITEM_MAP[partKey] or { item = "mechanic_tools", flow = "hood_install" }
    local reqItem = tostring(data and data.requiredItem or mapping.item)

    if plate == "" then
        return { success = false, error = "invalid_plate" }
    end

    if removeReqItem and reqItem ~= "" then
        if not Functions.RemoveItem(src, reqItem, 1) then
            return { success = false, error = "missing_item", requiredItem = reqItem }
        end
    end

    local currentWear, currentMileage = loadVehicleWear(plate)

    local isFullRepair = (partKey == "repair_kit" or partKey == "fix_kit" or partKey == "admin_full_repair")
    if isFullRepair then
        for k, _ in pairs(currentWear) do
            currentWear[k] = 100.0
        end
    else
        currentWear[partKey] = 100.0
    end

    -- If catalytic converter was repaired, remove stolen record and clear missing state
    if partKey == "catalytic_converter" or isFullRepair then
        MySQL.query.await("DELETE FROM sky_mechanic_stolen_catalytics WHERE plate = @plate", { ["@plate"] = plate })
        if netId > 0 then
            local entity = NetworkGetEntityFromNetworkId(netId)
            if entity and entity ~= 0 and DoesEntityExist(entity) then
                Entity(entity).state:set("sky_mechanic_catalytic_missing", nil, true)
            end
        end
    end

    saveVehicleWear(plate, currentWear, currentMileage)

    TriggerClientEvent("sky_mechanicjob:wear:partRepaired", -1, {
        plate = plate,
        part = partKey,
        fullRepair = isFullRepair,
        wear = currentWear
    })

    VehicleHistory.Add(
        plate,
        "part_repaired",
        string.format("Repaired component: %s", partKey),
        src,
        0
    )

    return {
        success = true,
        wear = currentWear
    }
end)

-- ── Server Exports ───────────────────────────────────

registerExport("GetVehicleMileage", function(plate)
    local _, mileage = loadVehicleWear(plate)
    return mileage
end)

registerExport("SetVehicleMileage", function(plate, mileage)
    local wearMap, _ = loadVehicleWear(plate)
    saveVehicleWear(plate, wearMap, mileage)
    return true
end)

registerExport("GetVehicleWear", function(plate)
    local wearMap, _ = loadVehicleWear(plate)
    return wearMap
end)

registerExport("SetVehicleWear", function(plate, wearMap)
    local _, mileage = loadVehicleWear(plate)
    saveVehicleWear(plate, wearMap, mileage)
    return true
end)
