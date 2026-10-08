if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/wear.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_mechanicjob · source/server/wear.lua
--  Vehicle Wear Tracking, Mileage Sync & Part Repairs
-- =====================================================

local CATALYTIC_STATE_KEY = "sky_mechanic_catalytic_missing"
local CACHE_IDLE_SECONDS = 1800
local CACHE_MAX_ENTRIES = 5000
local OWNERSHIP_RECHECK_SECONDS = 300
local SAVE_VEHICLE_RANGE = 10.0
local SAVE_GRACE_SECONDS = 120
local MAX_KM_PER_SECOND = 0.125
local MIN_MILEAGE_ALLOWANCE_KM = 0.5
local REPAIR_VEHICLE_RANGE = 15.0

local wearCacheByPlate = {}
local wearCacheCount = 0
local wearRevision = 0
local driverSessions = {}

local ALL_WEAR_PARTS = {
    "tyres", "brake_pads", "suspension", "spark_plugs",
    "engine_oil", "coolant", "brake_fluid", "transmission_fluid",
    "clutch", "air_filter", "catalytic_converter", "traction_battery", "inverter"
}

-- Used when Config.Wear.parts has no entry (or no item/flow) for a part.
local DEFAULT_PART_REPAIR = {
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
    inverter = { item = "inverter", flow = "hood_install" }
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

local function copyWearMap(wearMap)
    local copy = {}
    for k, v in pairs(wearMap or {}) do copy[k] = v end
    return copy
end

local function nonEmptyString(value, fallback)
    return (type(value) == "string" and value ~= "") and value or fallback
end

local function isVehicleOwned(plate)
    if not (TuningDB and TuningDB.IsVehicleOwned) then return false end
    local ok, owned = pcall(TuningDB.IsVehicleOwned, plate)
    return ok and owned == true
end

local function nextRevision()
    wearRevision = wearRevision + 1
    return wearRevision
end

-- ── Wear Cache ───────────────────────────────────────

local function evictIdleEntries(maxIdleSeconds)
    local now = os.time()
    for plate, entry in pairs(wearCacheByPlate) do
        if now - (entry.touchedAt or 0) > maxIdleSeconds then
            wearCacheByPlate[plate] = nil
            wearCacheCount = wearCacheCount - 1
        end
    end
end

local function cacheEntry(entry)
    if wearCacheByPlate[entry.plate] then return end
    if wearCacheCount >= CACHE_MAX_ENTRIES then
        evictIdleEntries(60)
        if wearCacheCount >= CACHE_MAX_ENTRIES then return end
    end
    wearCacheByPlate[entry.plate] = entry
    wearCacheCount = wearCacheCount + 1
end

--- Load the wear entry for a plate from cache or database. Unknown plates are not written to the
--- database; they only persist once the plate has a wear row or is an owned vehicle.
---@param plate string
---@return table|nil entry { plate, wear, mileage, rev, persist }
local function loadVehicleWear(plate)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" then return nil end

    local entry = wearCacheByPlate[cleanPlate]
    if entry then
        entry.touchedAt = os.time()
        return entry
    end

    local row = MySQL.single.await("SELECT mileage, wear FROM sky_mechanic_vehicle_wear WHERE plate = ? LIMIT 1", { cleanPlate })
    local persist = row ~= nil or isVehicleOwned(cleanPlate)

    -- Another request may have loaded the plate while this one waited for the database.
    entry = wearCacheByPlate[cleanPlate]
    if entry then
        entry.touchedAt = os.time()
        return entry
    end

    local wearMap = getDefaultWearMap()
    local mileage = 0.0
    if row then
        mileage = math.max(0.0, tonumber(row.mileage) or 0.0)
        local decoded = type(row.wear) == "string" and json.decode(row.wear) or nil
        if type(decoded) == "table" then
            for _, part in ipairs(ALL_WEAR_PARTS) do
                local value = tonumber(decoded[part])
                if value then wearMap[part] = math.max(0.0, math.min(100.0, value)) end
            end
        end
    end

    local now = os.time()
    entry = {
        plate = cleanPlate,
        wear = wearMap,
        mileage = mileage,
        rev = nextRevision(),
        persist = persist,
        ownerCheckedAt = now,
        touchedAt = now,
        mileageAt = now
    }
    cacheEntry(entry)
    return entry
end

--- Write an entry to the database (owned / known plates only). Concurrent calls collapse into
--- one writer that always stores the latest values.
local function persistEntry(entry)
    if not entry.persist then
        local now = os.time()
        if now - (entry.ownerCheckedAt or 0) < OWNERSHIP_RECHECK_SECONDS then return end
        entry.ownerCheckedAt = now
        if not isVehicleOwned(entry.plate) then return end
        entry.persist = true
    end

    if entry.writing then
        entry.dirty = true
        return
    end

    entry.writing = true
    repeat
        entry.dirty = false
        local ok, err = pcall(MySQL.query.await, [[
            INSERT INTO sky_mechanic_vehicle_wear (plate, mileage, wear)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE mileage = VALUES(mileage), wear = VALUES(wear)
        ]], { entry.plate, entry.mileage, json.encode(entry.wear) })
        if not ok then
            print(("[sky_mechanicjob][wear] save failed for plate %s: %s"):format(entry.plate, tostring(err)))
        end
    until not entry.dirty
    entry.writing = false
end

CreateThread(function()
    while true do
        Wait(300000)
        evictIdleEntries(CACHE_IDLE_SECONDS)
    end
end)

-- ── Repair Rules ─────────────────────────────────────

local function getPartRepairConfig(partKey)
    local defaults = DEFAULT_PART_REPAIR[partKey]
    if not defaults then return nil end

    local cfg = Config.Wear and Config.Wear.parts and Config.Wear.parts[partKey]
    cfg = type(cfg) == "table" and cfg or {}
    local item = nonEmptyString(cfg.item, defaults.item)

    return {
        items = { item },
        allowed = { [item] = true },
        flow = nonEmptyString(cfg.flow, defaults.flow),
        removeAfterUse = cfg.removeAfterUse ~= false,
        parts = { partKey },
        maxDistance = REPAIR_VEHICLE_RANGE,
        resetWheels = partKey == "tyres"
    }
end

-- fix_kit and repair_kit both start the vehicle care repair action.
local function getRepairKitConfig()
    local cfg = Config.VehicleCare and Config.VehicleCare.repair
    cfg = type(cfg) == "table" and cfg or {}

    local primary = nonEmptyString(cfg.item, "fix_kit")
    local items = { primary }
    if primary ~= "repair_kit" then items[2] = "repair_kit" end

    local allowed = {}
    for _, name in ipairs(items) do allowed[name] = true end

    local toggles = type(cfg.repairWearParts) == "table" and cfg.repairWearParts or {}
    local parts = {}
    for _, part in ipairs(ALL_WEAR_PARTS) do
        if toggles[part] ~= false then parts[#parts + 1] = part end
    end

    return {
        items = items,
        allowed = allowed,
        removeAfterUse = cfg.removeAfterUse ~= false,
        parts = parts,
        maxDistance = math.max(2.0, tonumber(cfg.maxDistance) or 6.0) + 2.0,
        resetWheels = cfg.fixRealisticWheelDamage == true
    }
end

local function pickRepairItem(src, repair, claimedItem)
    local claimed = tostring(claimedItem or "")
    if repair.allowed[claimed] and Functions.HasItem(src, claimed, 1) then
        return claimed
    end
    for _, name in ipairs(repair.items) do
        if Functions.HasItem(src, name, 1) then return name end
    end
    return nil
end

local function resolveRepairVehicle(src, data, maxDistance)
    local claimedPlate = sanitizePlate(data.plate)
    local netId = math.floor(tonumber(data.vehicleNetId) or 0)

    local entity = netId > 0 and Functions.GetVehicleByNetId(src, netId, maxDistance) or nil
    if not entity and claimedPlate ~= "" then
        entity = Functions.GetNearbyVehicleByPlate(src, claimedPlate, maxDistance)
    end
    if not entity then return nil end

    local plate = sanitizePlate(GetVehicleNumberPlateText(entity))
    if plate == "" or (claimedPlate ~= "" and claimedPlate ~= plate) then return nil end
    return entity, plate
end

--- Restore parts to 100%, clear stolen catalytic / wheel damage state and notify clients.
---@return table wearMap
local function applyRepair(src, entry, entity, parts, opts)
    local repaired = {}
    local catalyticRepaired = false
    for _, part in ipairs(parts) do
        if entry.wear[part] ~= nil then
            entry.wear[part] = 100.0
            repaired[#repaired + 1] = part
            if part == "catalytic_converter" then catalyticRepaired = true end
        end
    end
    entry.rev = nextRevision()
    entry.touchedAt = os.time()

    if opts.resetWheels and entity and DoesEntityExist(entity) and MechanicWheelDamage then
        MechanicWheelDamage.Reset(entity)
    end

    if catalyticRepaired then
        if entity and DoesEntityExist(entity) then
            Entity(entity).state:set(CATALYTIC_STATE_KEY, nil, true)
        end
        MySQL.query.await("DELETE FROM sky_mechanic_stolen_catalytics WHERE plate = ?", { entry.plate })
    end

    persistEntry(entry)

    TriggerClientEvent("sky_mechanicjob:wear:partRepaired", -1, {
        plate = entry.plate,
        part = opts.part,
        fullRepair = opts.fullRepair == true or #repaired == #ALL_WEAR_PARTS,
        repairedParts = repaired,
        wheelsReset = opts.resetWheels == true,
        wear = entry.wear,
        rev = entry.rev
    })

    VehicleHistory.Add(
        entry.plate,
        opts.historyAction or "part_repaired",
        opts.historyText or string.format("Repaired component: %s", tostring(opts.part)),
        src,
        0
    )

    return entry.wear
end

local function setWearPart(plate, part, value)
    local entry = loadVehicleWear(plate)
    if not entry or entry.wear[part] == nil then return nil end
    entry.wear[part] = math.max(0.0, math.min(100.0, tonumber(value) or 0.0))
    entry.rev = nextRevision()
    persistEntry(entry)
    return entry
end

-- Server-side API for the other mechanic server files (call inside handlers only).
MechanicWear = {
    AllParts = ALL_WEAR_PARTS,
    Load = loadVehicleWear,
    SetPart = setWearPart,
    ApplyRepair = applyRepair
}

-- ── Driver Sessions ──────────────────────────────────

local function isDriverOfVehicle(ped, vehicle)
    if GetPedInVehicleSeat(vehicle, -1) == ped then return true end
    return GetLastPedInVehicleSeat ~= nil and GetLastPedInVehicleSeat(vehicle, -1) == ped
end

--- A save is accepted from the vehicle's (last) driver standing at the vehicle, or shortly after
--- the server last saw that player drive it (the vehicle may be stored right after leaving).
local function canSaveWear(src, plate)
    local ped = GetPlayerPed(src)
    local vehicle = ped ~= 0 and Functions.GetNearbyVehicleByPlate(src, plate, SAVE_VEHICLE_RANGE) or nil
    if vehicle and isDriverOfVehicle(ped, vehicle) then
        driverSessions[src] = { plate = plate, at = os.time() }
        return true
    end

    local session = driverSessions[src]
    return session ~= nil and session.plate == plate and os.time() - session.at <= SAVE_GRACE_SECONDS
end

AddEventHandler("playerDropped", function()
    driverSessions[tonumber(source) or source] = nil
end)

-- ── Server Callbacks ─────────────────────────────────

Sky.Cb.Register("sky_mechanicjob:wear:get", function(source, data)
    local src = tonumber(source)
    local plate = sanitizePlate(data and data.plate)
    if plate == "" then
        return { success = false, error = "invalid_plate", wear = getDefaultWearMap(), mileage = 0 }
    end

    local entry = loadVehicleWear(plate)
    if not entry then
        return { success = false, error = "invalid_plate", wear = getDefaultWearMap(), mileage = 0 }
    end

    local ped = src and GetPlayerPed(src) or 0
    local vehicle = ped ~= 0 and GetVehiclePedIsIn(ped, false) or 0
    if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped and sanitizePlate(GetVehicleNumberPlateText(vehicle)) == plate then
        driverSessions[src] = { plate = plate, at = os.time() }
        -- Restores the missing-converter state after a restart or garage respawn.
        if (tonumber(entry.wear.catalytic_converter) or 100.0) <= 0.0 and Entity(vehicle).state[CATALYTIC_STATE_KEY] ~= true then
            Entity(vehicle).state:set(CATALYTIC_STATE_KEY, true, true)
        end
    end

    return {
        success = true,
        wear = entry.wear,
        mileage = entry.mileage,
        rev = entry.rev
    }
end)

Sky.Cb.Register("sky_mechanicjob:wear:save", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local plate = sanitizePlate(data and data.plate)
    local wearMap = type(data) == "table" and type(data.wear) == "table" and data.wear or nil
    if plate == "" or not wearMap then
        return { success = false, error = "invalid_payload" }
    end

    if not canSaveWear(src, plate) then
        return { success = false, error = "vehicle_too_far" }
    end

    local entry = loadVehicleWear(plate)
    if not entry then return { success = false, error = "invalid_plate" } end

    -- Mileage only grows, and no faster than a vehicle can drive since the last accepted value.
    local now = os.time()
    local incomingKm = tonumber(data.mileage)
    if incomingKm and incomingKm == incomingKm and incomingKm > entry.mileage then
        local allowance = math.max(MIN_MILEAGE_ALLOWANCE_KM, (now - (entry.mileageAt or now)) * MAX_KM_PER_SECOND)
        entry.mileage = math.min(incomingKm, entry.mileage + allowance)
    end
    entry.mileageAt = now
    entry.touchedAt = now

    -- Wear only goes down, and only when the client's copy is based on the current server state
    -- (a repair or theft since then bumps the revision and the client resyncs instead).
    local upToDate = tonumber(data.rev) == entry.rev
    if upToDate then
        for _, part in ipairs(ALL_WEAR_PARTS) do
            local incoming = tonumber(wearMap[part])
            local current = entry.wear[part]
            if incoming and current and incoming < current then
                entry.wear[part] = math.max(0.0, incoming)
            end
        end
    end

    persistEntry(entry)

    return {
        success = true,
        rev = entry.rev,
        mileage = entry.mileage,
        wear = (not upToDate) and entry.wear or nil
    }
end)

Sky.Cb.Register("sky_mechanicjob:wear:prepareRepairInstall", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    if not Functions.IsMechanicOnDuty(src) then
        return { success = false, error = "not_authorized" }
    end

    local partKey = tostring(data and data.part or "")
    local repair = getPartRepairConfig(partKey)
    if not repair then
        return { success = false, error = "invalid_part" }
    end

    local plate = sanitizePlate(data and data.plate)
    if plate ~= "" and not Functions.GetNearbyVehicleByPlate(src, plate, REPAIR_VEHICLE_RANGE) then
        return { success = false, error = "vehicle_too_far" }
    end

    local reqItem = repair.items[1]
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
            removeRequiredItemAfterUse = repair.removeAfterUse,
            flow = repair.flow
        }
    }
end)

-- The server decides which item is consumed; requiredItem from the client is only accepted
-- when it belongs to the part's allowed set, removeRequiredItemAfterUse is ignored.
Sky.Cb.Register("sky_mechanicjob:wear:completeRepairInstall", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end
    data = type(data) == "table" and data or {}

    local partKey = tostring(data.part or "")
    local isRepairKit = partKey == "repair_kit" or partKey == "fix_kit"
    local repair = isRepairKit and getRepairKitConfig() or getPartRepairConfig(partKey)
    if not repair then
        return { success = false, error = "invalid_part" }
    end

    if not isRepairKit and not Functions.IsMechanicOnDuty(src) then
        return { success = false, error = "not_authorized" }
    end

    local entity, plate = resolveRepairVehicle(src, data, repair.maxDistance)
    if not entity then
        return { success = false, error = "vehicle_too_far" }
    end

    local entry = loadVehicleWear(plate)
    if not entry then
        return { success = false, error = "invalid_plate" }
    end

    local item = pickRepairItem(src, repair, data.requiredItem)
    if not item then
        return { success = false, error = "missing_item", requiredItem = repair.items[1] }
    end
    if repair.removeAfterUse and not Functions.RemoveItem(src, item, 1) then
        return { success = false, error = "missing_item", requiredItem = item }
    end

    local wearMap = applyRepair(src, entry, entity, repair.parts, {
        part = partKey,
        resetWheels = repair.resetWheels
    })

    return {
        success = true,
        wear = wearMap
    }
end)

-- ── Server Exports ───────────────────────────────────

registerExport("GetVehicleMileage", function(plate)
    local entry = loadVehicleWear(plate)
    return entry and entry.mileage or 0.0
end)

registerExport("SetVehicleMileage", function(plate, mileage)
    local entry = loadVehicleWear(plate)
    if not entry then return false end
    entry.mileage = math.max(0.0, tonumber(mileage) or 0.0)
    entry.mileageAt = os.time()
    persistEntry(entry)
    return true
end)

registerExport("GetVehicleWear", function(plate)
    local entry = loadVehicleWear(plate)
    return entry and copyWearMap(entry.wear) or getDefaultWearMap()
end)

registerExport("SetVehicleWear", function(plate, wearMap)
    local entry = loadVehicleWear(plate)
    if not entry or type(wearMap) ~= "table" then return false end
    for _, part in ipairs(ALL_WEAR_PARTS) do
        local value = tonumber(wearMap[part])
        if value then entry.wear[part] = math.max(0.0, math.min(100.0, value)) end
    end
    entry.rev = nextRevision()
    persistEntry(entry)
    return true
end)
