if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/storage.lua") end
-- =====================================================
--  sky_jobs_base · source/server/storage.lua
--  Storage Stashes, Trunk Props & Lockers Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

-- ── Station points (configurator / creator locations) ─

local STATION_CACHE_SECONDS = 30
local POINT_DISTANCE = 10.0
local POINT_TYPE_ALIASES = {
    bossmenu = "boss_menu",
    management = "boss_menu",
    tuning = "self_service_tuning",
    duty = "duty_terminal",
    duty_station = "duty_terminal",
    shop = "wholesale_shop"
}

local stationCache = { entries = nil, loadedAt = 0 }

local function normalizePointType(pointType)
    if type(pointType) ~= "string" then return nil end
    local norm = pointType:lower():gsub("%s+", "_"):gsub("-", "_"):gsub("_+", "_")
    return POINT_TYPE_ALIASES[norm] or norm
end

local function loadStationEntries()
    if stationCache.entries and os.time() - stationCache.loadedAt < STATION_CACHE_SECONDS then
        return stationCache.entries
    end

    local entries = {}
    local function addCreator(creatorKey, data)
        if type(data) ~= "table" or type(data.entries) ~= "table" then return end
        local creatorJob = type(data.creator) == "table" and data.creator.jobKey or nil
        for _, entry in ipairs(data.entries) do
            if type(entry) == "table" and entry.id ~= nil then
                entries[#entries + 1] = { creatorKey = creatorKey, entry = entry, creatorJob = creatorJob }
            end
        end
    end

    local ok, rows = pcall(MySQL.query.await, "SELECT creator_key, data FROM sky_jobs_creator_data")
    for _, row in ipairs(ok and type(rows) == "table" and rows or {}) do
        if row.creator_key ~= "workshopcreator" and type(row.data) == "string" then
            local decodedOk, decoded = pcall(json.decode, row.data)
            if decodedOk then addCreator(row.creator_key, decoded) end
        end
    end

    -- The workshops come from the configurator loader, which applies the defaults.
    if Sky_Jobs.Configurator and Sky_Jobs.Configurator.LoadWorkshopData then
        local workshopOk, data = pcall(Sky_Jobs.Configurator.LoadWorkshopData)
        if workshopOk then addCreator("workshopcreator", data) end
    end

    stationCache = { entries = entries, loadedAt = os.time() }
    return entries
end

local function entryJob(item)
    local key = item.entry.jobKey or item.entry.job or item.creatorJob
    return (type(key) == "string" and key ~= "") and key or nil
end

local function pointRequiresDuty(entry, point, pointType)
    if Config and Config.DutySystem == false then return false end
    local settings = type(entry.locationSettings) == "table" and point.uid ~= nil and entry.locationSettings[tostring(point.uid)] or nil
    if type(settings) == "table" and type(settings.requiresOnDuty) == "boolean" then
        return settings.requiresOnDuty
    end
    local definition = Config and Config.Interactions and Config.Interactions[pointType]
    if type(definition) == "table" and (definition.duty == false or definition.public == true) then
        return false
    end
    return true
end

-- Closest point of one of `types` at station `stationId` that `job` may use, within reach of
-- the player. opts: creatorKey, anyJob (public points), maxDistance.
-- Returns { creatorKey, entry, point, pointType, coords, distance, requiresDuty, jobKey } or nil, error.
function Sky_Jobs.FindStationPoint(src, job, stationId, types, opts)
    opts = opts or {}
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return nil, "no_player" end
    if stationId == nil then return nil, "unknown_station" end
    stationId = tostring(stationId)

    local wanted = {}
    for _, t in ipairs(types) do wanted[t] = true end

    local pos = GetEntityCoords(ped)
    local best
    for _, item in ipairs(loadStationEntries()) do
        local entry = item.entry
        local itemJob = entryJob(item)
        if tostring(entry.id) == stationId
            and (not opts.creatorKey or item.creatorKey == opts.creatorKey)
            and (opts.anyJob or itemJob == nil or itemJob == job)
            and type(entry.points) == "table" then
            for _, point in ipairs(entry.points) do
                local pointType = type(point) == "table" and normalizePointType(point.type) or nil
                local x, y, z = tonumber(point and point.x), tonumber(point and point.y), tonumber(point and point.z)
                if pointType and wanted[pointType] and x and y and z then
                    local coords = vector3(x, y, z)
                    local distance = #(pos - coords)
                    if not best or distance < best.distance then
                        best = {
                            creatorKey = item.creatorKey,
                            entry = entry,
                            point = point,
                            pointType = pointType,
                            coords = coords,
                            heading = tonumber(point.heading) or 0.0,
                            distance = distance,
                            requiresDuty = pointRequiresDuty(entry, point, pointType),
                            jobKey = itemJob
                        }
                    end
                end
            end
        end
    end

    if not best then return nil, "unknown_station" end
    if best.distance > (opts.maxDistance or POINT_DISTANCE) then return nil, "too_far" end
    return best
end

-- All points of `types` at one creator entry (spawn points of a garage).
function Sky_Jobs.GetStationPoints(creatorKey, stationId, types)
    local wanted, list = {}, {}
    for _, t in ipairs(types) do wanted[t] = true end
    for _, item in ipairs(loadStationEntries()) do
        if item.creatorKey == creatorKey and tostring(item.entry.id) == tostring(stationId) and type(item.entry.points) == "table" then
            for _, point in ipairs(item.entry.points) do
                local x, y, z = tonumber(point.x), tonumber(point.y), tonumber(point.z)
                if wanted[normalizePointType(point.type)] and x and y and z then
                    list[#list + 1] = { x = x, y = y, z = z, heading = tonumber(point.heading) or 0.0 }
                end
            end
        end
    end
    return list
end

-- Job, grade of an employed player; nil plus a reason otherwise.
local function requireEmployee(src, requireDuty)
    if not Sky_Jobs.GetEmployment then return nil, "unavailable" end
    local job, grade = Sky_Jobs.GetEmployment(src)
    if not job then return nil, "no_job" end
    if requireDuty and not Sky_Jobs.PlayerCache.IsOnDuty(src) then return nil, "not_on_duty" end
    return job, grade
end
Sky_Jobs.RequireEmployeeReason = requireEmployee

-- Is `name` in one of the player's restriction lists (roles editor, Sky_Jobs.GetPlayerRestrictions)?
function Sky_Jobs.IsRestrictedFor(src, listKeys, name)
    if type(name) ~= "string" or not Sky_Jobs.GetPlayerRestrictions then return false end
    local restrictions = Sky_Jobs.GetPlayerRestrictions(src) or {}
    local lower = name:lower()
    for _, key in ipairs(listKeys) do
        for k, v in pairs(type(restrictions[key]) == "table" and restrictions[key] or {}) do
            local entry = (type(v) == "table" and (v.name or v.model or v.value)) or (v == true and k) or v
            if type(entry) == "string" and entry:lower() == lower then return true end
        end
    end
    return false
end

-- ── ox_inventory helpers ──────────────────────────────

local STASH_GROUPS = { ["sky_jobs_base:no_direct_access"] = 0 }
local registeredStashes = {}

local function oxStarted()
    return GetResourceState("ox_inventory") == "started"
end

local function ox(method, ...)
    if not oxStarted() then return nil end
    local args = table.pack(...)
    local ok, a, b = pcall(function()
        return exports.ox_inventory[method](exports.ox_inventory, table.unpack(args, 1, args.n))
    end)
    if not ok then return nil end
    return a, b
end

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == "ox_inventory" then registeredStashes = {} end
end)

-- Stashes are only reachable through these callbacks: no player has STASH_GROUPS, so
-- ox_inventory's own UI cannot open them around the job, duty and distance checks.
local function ensureStash(name, label, slots, maxWeight, owner)
    if registeredStashes[name] then return true end
    if not oxStarted() then return false end
    local ok = pcall(function()
        exports.ox_inventory:RegisterStash(name, label, slots, maxWeight, owner, STASH_GROUPS)
    end)
    if ok then registeredStashes[name] = true end
    return ok
end

local function stashName(prefix, job, key)
    return (("skyjobs_%s_%s_%s"):format(prefix, job, key):gsub("[^%w_%-]", "_"):sub(1, 90))
end

local function serializeMetadata(value, depth)
    local t = type(value)
    if t == "table" then
        if depth > 8 then return "{}" end
        local keys = {}
        for k in pairs(value) do keys[#keys + 1] = k end
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        local parts = {}
        for _, k in ipairs(keys) do
            parts[#parts + 1] = tostring(k) .. "=" .. serializeMetadata(value[k], depth + 1)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    elseif t == "number" then
        if value == value and math.abs(value) < 2 ^ 53 and value == math.floor(value) then
            return string.format("%d", math.floor(value))
        end
        return string.format("%.4f", value)
    end
    return tostring(value)
end

-- Identifies items by content so the UI can name the exact item it moves (metadata_key).
local function metadataKey(metadata)
    if type(metadata) ~= "table" or next(metadata) == nil then return "" end
    return serializeMetadata(metadata, 0)
end

local function isWeapon(name)
    return type(name) == "string" and name:upper():sub(1, 7) == "WEAPON_"
end

local function listItems(inv)
    local list, byKey = {}, {}
    for _, it in pairs(ox("GetInventoryItems", inv) or {}) do
        local count = type(it) == "table" and tonumber(it.count) or 0
        if count > 0 and type(it.name) == "string" then
            local key = metadataKey(it.metadata)
            local index = it.name .. "\0" .. key
            local entry = byKey[index]
            if entry then
                entry.amount = entry.amount + count
            else
                entry = {
                    name = it.name,
                    label = it.label or it.name,
                    amount = count,
                    metadata = key ~= "" and it.metadata or nil,
                    metadata_key = key ~= "" and key or nil,
                    category = isWeapon(it.name) and "weapon" or "item",
                    type = "item"
                }
                byKey[index] = entry
                list[#list + 1] = entry
            end
        end
    end
    table.sort(list, function(a, b) return tostring(a.label) < tostring(b.label) end)
    return list
end

local function countItems(inv)
    local total = 0
    for _, it in pairs(ox("GetInventoryItems", inv) or {}) do
        total = total + (type(it) == "table" and tonumber(it.count) or 0)
    end
    return total
end

-- Moves items between inventories: take first, then give; puts items back when the give fails.
local function moveItems(from, to, name, amount, key, fullKey)
    local slots, total = {}, 0
    for _, it in pairs(ox("GetInventoryItems", from) or {}) do
        if type(it) == "table" and it.name == name and metadataKey(it.metadata) == key then
            slots[#slots + 1] = it
            total = total + (tonumber(it.count) or 0)
        end
    end
    if total < amount then return { success = false, errorKey = "notEnoughItems" } end
    if not ox("CanCarryItem", to, name, amount, slots[1].metadata) then
        return { success = false, errorKey = fullKey }
    end

    local moved = 0
    for _, it in ipairs(slots) do
        if moved >= amount then break end
        local count = math.min(amount - moved, tonumber(it.count) or 0)
        if not ox("RemoveItem", from, name, count, it.metadata, it.slot) then
            return { success = false, errorKey = "invalidTransfer" }
        end
        if not ox("AddItem", to, name, count, it.metadata) then
            if not ox("AddItem", from, name, count, it.metadata, it.slot) then
                ox("AddItem", from, name, count, it.metadata)
            end
            return { success = false, errorKey = fullKey }
        end
        moved = moved + count
    end
    return { success = true }
end

local function parseTransfer(name, amount, key)
    if type(name) ~= "string" or name == "" or #name > 64 then return nil end
    amount = math.tointeger(tonumber(amount))
    if not amount or amount < 1 or amount > 100000 then return nil end
    if key ~= nil and (type(key) ~= "string" or #key > 8192) then return nil end
    return name, amount, key or ""
end

local function playerDistanceTo(src, coords)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return math.huge end
    return #(GetEntityCoords(ped) - coords)
end

local function fail(errorKey)
    return { success = false, errorKey = errorKey }
end

Sky.Cb.Register("sky_jobs_base:getPlayerInventoryItems", function(source)
    if not oxStarted() then return {} end
    return listItems(tonumber(source))
end)

-- ── Storage & lockers ─────────────────────────────────

local openStorages = {}

local function capacityFor(job, entry, slot)
    local key = slot == "locker" and "lockerCapacity" or "storageCapacity"
    local definition = Sky_Jobs.GetJobDefinition and Sky_Jobs.GetJobDefinition(job)
    local jobStorage = type(definition) == "table" and type(definition.storage) == "table" and definition.storage or {}
    return math.floor(tonumber(entry[key]) or tonumber(jobStorage[key]) or tonumber(Config and Config.Storage and Config.Storage[key]) or 0)
end

Sky.Cb.Register("sky_jobs_base:openStorage", function(source, data)
    local src = tonumber(source)
    if not oxStarted() then return { success = false, error = "inventory_unavailable" } end
    data = type(data) == "table" and data or {}
    local slot = data.slot == "locker" and "locker" or "storage"
    local stationId = (type(data.stationId) == "string" or type(data.stationId) == "number") and tostring(data.stationId) or ""
    if stationId == "" or #stationId > 64 then return fail("invalidTransfer") end

    local job, err = requireEmployee(src, false)
    if not job then return { success = false, error = err } end
    local point, pointErr = Sky_Jobs.FindStationPoint(src, job, stationId, { slot })
    if not point then return { success = false, error = pointErr } end
    if point.requiresDuty and not Sky_Jobs.PlayerCache.IsOnDuty(src) then
        return { success = false, error = "not_on_duty" }
    end

    local capacity = capacityFor(job, point.entry, slot)
    local slots = math.max(50, math.min(capacity > 0 and capacity or 500, 500))
    local inv
    if slot == "locker" then
        local identifier = Sky_Jobs.GetPlayerIdentifier and Sky_Jobs.GetPlayerIdentifier(src)
        if not identifier then return { success = false, error = "no_identifier" } end
        local name = stashName("lk", job, stationId)
        if not ensureStash(name, "Locker", slots, 1000000, true) then return { success = false, error = "inventory_unavailable" } end
        inv = { id = name, owner = identifier }
    else
        local name = stashName("st", job, stationId)
        if not ensureStash(name, "Storage", slots, 5000000) then return { success = false, error = "inventory_unavailable" } end
        inv = name
    end

    local session = {
        slot = slot,
        stationId = stationId,
        job = job,
        inv = inv,
        coords = point.coords,
        requiresDuty = point.requiresDuty,
        capacity = capacity,
        containsWeapons = point.entry.storageContainsWeapons == true
    }
    openStorages[src] = session

    local items = listItems(inv)
    local used = 0
    for _, it in ipairs(items) do used = used + it.amount end

    return {
        success = true,
        data = {
            items = items,
            inventoryItems = listItems(src),
            capacity = math.max(0, capacity),
            used = used,
            storageContainsWeapons = session.containsWeapons
        }
    }
end)

local function stationTransfer(source, slot, stationId, direction, name, amount, metadataKey)
    local src = tonumber(source)
    local session = openStorages[src]
    if not session or session.slot ~= slot or session.stationId ~= tostring(stationId) then
        return fail("invalidTransfer")
    end
    if not oxStarted() then return { success = false, error = "inventory_unavailable" } end
    if requireEmployee(src, session.requiresDuty) ~= session.job then
        openStorages[src] = nil
        return fail("invalidTransfer")
    end
    if playerDistanceTo(src, session.coords) > POINT_DISTANCE then return fail("invalidTransfer") end

    local itemName, count, key = parseTransfer(name, amount, metadataKey)
    if not itemName then return fail("invalidAmount") end

    local fullKey = slot == "locker" and "lockerFull" or "storageFull"
    if direction == "inventory" then
        if isWeapon(itemName) and not session.containsWeapons then return fail("restrictedItem") end
        if session.capacity > 0 and countItems(session.inv) + count > session.capacity then return fail(fullKey) end
        return moveItems(src, session.inv, itemName, count, key, fullKey)
    elseif direction == "storage" then
        if slot == "storage" and Sky_Jobs.IsRestrictedFor(src, { "items", "weapons" }, itemName) then return fail("restrictedItem") end
        return moveItems(session.inv, src, itemName, count, key, "inventoryFull")
    end
    return fail("invalidTransfer")
end

Sky.Cb.Register("sky_jobs_base:storageTransfer", function(source, stationId, direction, name, amount, category, metadata, metadataKey)
    return stationTransfer(source, "storage", stationId, direction, name, amount, metadataKey)
end)

Sky.Cb.Register("sky_jobs_base:lockerTransfer", function(source, stationId, direction, name, amount, category, metadata, metadataKey)
    return stationTransfer(source, "locker", stationId, direction, name, amount, metadataKey)
end)

-- ── Vehicle trunks ────────────────────────────────────

local TRUNK_DISTANCE = 10.0
local PROP_VEHICLE_DISTANCE = 40.0
local openTrunks = {}
local trunkPropStock = {}

local function copyProp(p)
    return {
        name = p.name,
        model = p.model,
        label = p.label,
        amount = p.amount,
        unlimited = p.unlimited == true,
        zOffset = p.zOffset,
        image = p.image,
        streamDistance = p.streamDistance
    }
end

local function getJobProps(job)
    local definition = Sky_Jobs.GetJobDefinition and Sky_Jobs.GetJobDefinition(job)
    local list = {}
    for _, p in ipairs(type(definition) == "table" and type(definition.props) == "table" and definition.props or {}) do
        local model = type(p) == "table" and (p.model or p.name) or nil
        if type(model) == "string" and model ~= "" then
            list[#list + 1] = {
                name = type(p.name) == "string" and p.name or model,
                model = model,
                label = type(p.label) == "string" and p.label or model,
                item = type(p.item) == "string" and p.item or nil,
                zOffset = tonumber(p.zOffset),
                image = type(p.image) == "string" and p.image or nil,
                streamDistance = tonumber(p.streamDistance)
            }
        end
    end
    return list
end

-- Limited stock only when the vehicle entry sets props / propCounts; otherwise the job's
-- props are unlimited (the per-player cap still applies).
local function buildPropStock(job, vehicleEntry)
    if type(vehicleEntry) == "table" and (vehicleEntry.trunkPropsEnabled == false or vehicleEntry.trunkEnabled == false) then
        return {}
    end

    local jobProps = getJobProps(job)
    local byModel = {}
    for _, p in ipairs(jobProps) do byModel[p.model:lower()] = p end

    local stock = {}
    local function add(base, model, amount, unlimited)
        local p = copyProp(base or { name = model, model = model, label = model })
        p.amount = unlimited and 1 or math.max(0, math.floor(tonumber(amount) or 0))
        p.max = p.amount
        p.unlimited = unlimited == true
        stock[#stock + 1] = p
    end

    local vehicleProps = type(vehicleEntry) == "table" and vehicleEntry.props or nil
    local counts = type(vehicleEntry) == "table" and vehicleEntry.propCounts or nil
    if type(vehicleProps) == "table" and next(vehicleProps) then
        for k, v in pairs(vehicleProps) do
            if type(k) == "string" then
                add(byModel[k:lower()], k, v)
            elseif type(v) == "table" and type(v.model or v.name) == "string" then
                local model = v.model or v.name
                local base = copyProp(byModel[model:lower()] or { name = v.name or model, model = model, label = v.label or model })
                base.label = v.label or base.label
                add(base, model, v.amount or 1)
            end
        end
    elseif type(counts) == "table" and next(counts) then
        for _, p in ipairs(jobProps) do
            local n = tonumber(counts[p.model] or counts[p.name])
            if n and n > 0 then add(p, p.model, n) end
        end
    else
        for _, p in ipairs(jobProps) do add(p, p.model, 1, true) end
    end
    return stock
end

local function getTrunkStock(session)
    local stock = trunkPropStock[session.stash]
    if not stock then
        stock = buildPropStock(session.job, session.vehicleEntry)
        trunkPropStock[session.stash] = stock
    end
    return stock
end

local function stockForClient(stock)
    local list = {}
    for _, p in ipairs(stock) do list[#list + 1] = copyProp(p) end
    return list
end

local function trunkSessionNear(src, session, maxDistance)
    if session.context == "world" then
        local entity = NetworkGetEntityFromNetworkId(session.netId)
        if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
        if Sky_Jobs.Garage.NormalizePlate(GetVehicleNumberPlateText(entity)) ~= session.plate then return false end
        return playerDistanceTo(src, GetEntityCoords(entity)) <= maxDistance
    end
    return playerDistanceTo(src, session.coords) <= maxDistance
end

Sky.Cb.Register("sky_jobs_base:openVehicleTrunk", function(source, data)
    local src = tonumber(source)
    if not oxStarted() then return { success = false, error = "inventory_unavailable" } end
    data = type(data) == "table" and data or {}
    local job, err = requireEmployee(src, true)
    if not job then return { success = false, error = err } end

    local Garage = Sky_Jobs.Garage
    local plate = Garage.NormalizePlate(data.plate)
    if not plate then return { success = false, error = "invalid_plate" } end

    local row = Garage.GetVehicle(job, plate)
    local session = { job = job, plate = plate, context = data.context == "garage" and "garage" or "world" }
    local model

    if session.context == "world" then
        local netId = tonumber(data.netId)
        local entity = netId and NetworkGetEntityFromNetworkId(netId) or 0
        if not entity or entity == 0 or not DoesEntityExist(entity) or GetEntityType(entity) ~= 2 then
            return { success = false, error = "vehicle_unavailable" }
        end
        if Garage.NormalizePlate(GetVehicleNumberPlateText(entity)) ~= plate then
            return { success = false, error = "vehicle_unavailable" }
        end
        if playerDistanceTo(src, GetEntityCoords(entity)) > TRUNK_DISTANCE then
            return { success = false, error = "too_far" }
        end
        session.netId = netId
        model = GetEntityModel(entity)
    else
        if not row then return { success = false, error = "vehicle_unavailable" } end
        local garage, garageErr = Garage.ResolveGarage(src, job, data.garageId)
        if not garage then return { success = false, error = garageErr } end
        if row.garage_type ~= garage.garageType then return { success = false, error = "vehicle_unavailable" } end
        session.coords = garage.coords
        model = row.model
    end

    local entry = Garage.FindCatalogEntry(job, row and row.model or model)
    if not row and not entry then return { success = false, error = "not_a_job_vehicle" } end
    if entry and entry.trunkEnabled == false then return { success = false, error = "trunk_disabled" } end

    local capacity = math.floor(tonumber(entry and entry.trunkCapacity) or tonumber(Config and Config.JobGarage and Config.JobGarage.defaultTrunkCapacity) or 0)
    session.vehicleEntry = entry
    session.capacity = capacity
    session.stash = row and stashName("tr", job, "v" .. row.id) or stashName("tr", job, plate)
    if not ensureStash(session.stash, "Trunk " .. plate, math.max(50, math.min(capacity > 0 and capacity or 200, 200)), 1000000) then
        return { success = false, error = "inventory_unavailable" }
    end
    openTrunks[src] = session

    local items = listItems(session.stash)
    local used = 0
    for _, it in ipairs(items) do used = used + it.amount end

    return {
        success = true,
        data = {
            plate = plate,
            vehicleName = (row and row.name) or (entry and entry.name) or nil,
            trunkItems = items,
            inventoryItems = listItems(src),
            capacity = math.max(0, capacity),
            used = used,
            storageContainsWeapons = false,
            trunkProps = stockForClient(getTrunkStock(session))
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:trunkTransfer", function(source, plate, direction, name, amount, metadata, metadataKey)
    local src = tonumber(source)
    local session = openTrunks[src]
    if not session or session.plate ~= Sky_Jobs.Garage.NormalizePlate(plate) then return fail("invalidTransfer") end
    if not oxStarted() then return { success = false, error = "inventory_unavailable" } end
    if requireEmployee(src, true) ~= session.job then
        openTrunks[src] = nil
        return fail("invalidTransfer")
    end
    if not trunkSessionNear(src, session, TRUNK_DISTANCE) then return fail("invalidTransfer") end

    local itemName, count, key = parseTransfer(name, amount, metadataKey)
    if not itemName then return fail("invalidAmount") end

    if direction == "inventory" then
        if isWeapon(itemName) then return fail("restrictedItem") end
        if session.capacity > 0 and countItems(session.stash) + count > session.capacity then return fail("trunkFull") end
        return moveItems(src, session.stash, itemName, count, key, "trunkFull")
    elseif direction == "storage" then
        if Sky_Jobs.IsRestrictedFor(src, { "items", "weapons" }, itemName) then return fail("restrictedItem") end
        return moveItems(session.stash, src, itemName, count, key, "inventoryFull")
    end
    return fail("invalidTransfer")
end)

Sky.Cb.Register("sky_jobs_base:getVehicleTrunkProps", function(source, data)
    local src = tonumber(source)
    local session = openTrunks[src]
    local plate = Sky_Jobs.Garage.NormalizePlate(type(data) == "table" and data.plate or nil)
    if not session or session.plate ~= plate or requireEmployee(src, true) ~= session.job then
        return { success = false, error = "trunk_not_open" }
    end
    return { success = true, props = stockForClient(getTrunkStock(session)) }
end)

-- ── Trunk props (placed world props) ──────────────────

local PROP_PLACE_DISTANCE = 8.0
local PROP_REMOVE_DISTANCE = 6.0
local MAX_PROPS_TOTAL = 1000
local placedProps = {}
local nextPropId = 1

local function maxPropsPerPlayer()
    local trunk = Config and Config.JobGarage and Config.JobGarage.trunk
    return math.floor(tonumber(trunk and trunk.maxPropsPerPlayer) or 25)
end

local function findProp(list, name, model)
    name = type(name) == "string" and name:lower() or nil
    model = type(model) == "string" and model:lower() or nil
    for _, p in ipairs(list) do
        if (name and p.name:lower() == name) or (not name and model and p.model:lower() == model) then
            return p
        end
    end
    return nil
end

local function findPropItem(job, item)
    for _, p in ipairs(getJobProps(job)) do
        if p.item == item then return p end
    end
    local configured = Config and Config.PropItems and Config.PropItems[item]
    if type(configured) == "table" and type(configured.model) == "string" then
        return { name = configured.model, model = configured.model, label = configured.label or configured.model, zOffset = tonumber(configured.zOffset) }
    end
    return nil
end

local function removePlacedProp(id)
    local placed = placedProps[id]
    if not placed then return end
    placedProps[id] = nil
    local stock = placed.stockKey and trunkPropStock[placed.stockKey]
    local stockItem = stock and findProp(stock, placed.stockName)
    if stockItem and not stockItem.unlimited then
        stockItem.amount = math.min(stockItem.amount + 1, stockItem.max or stockItem.amount + 1)
    end
    TriggerClientEvent("sky_jobs_base:trunkProps:remove", -1, id)
end

Sky.Cb.Register("sky_jobs_base:trunkProps:getAll", function(source)
    local list = {}
    for _, placed in pairs(placedProps) do list[#list + 1] = placed.prop end
    return { success = true, props = list }
end)

Sky.Cb.Register("sky_jobs_base:trunkProps:place", function(source, data)
    local src = tonumber(source)
    data = type(data) == "table" and data or {}
    local job, err = requireEmployee(src, true)
    if not job then return { success = false, error = err } end
    if not Sky.Cooldown(400, "trunkProps:" .. tostring(src)) then return { success = false, error = "cooldown" } end

    local c = type(data.coords) == "table" and data.coords or {}
    local x, y, z = tonumber(c.x), tonumber(c.y), tonumber(c.z)
    if not (x and y and z) then return { success = false, error = "invalid_coords" } end
    local coords = vector3(x, y, z)
    if playerDistanceTo(src, coords) > PROP_PLACE_DISTANCE then return { success = false, error = "too_far" } end

    local own, total = 0, 0
    for _, placed in pairs(placedProps) do
        total = total + 1
        if placed.owner == src then own = own + 1 end
    end
    if own >= maxPropsPerPlayer() or total >= MAX_PROPS_TOTAL then return { success = false, error = "limit_reached" } end

    local definition, stockItem, session, consumeItem
    if data.plate ~= nil then
        session = openTrunks[src]
        if not session or session.plate ~= Sky_Jobs.Garage.NormalizePlate(data.plate) or session.job ~= job then
            return { success = false, error = "invalid_prop" }
        end
        if not trunkSessionNear(src, session, PROP_VEHICLE_DISTANCE) then return { success = false, error = "too_far" } end
        stockItem = findProp(getTrunkStock(session), data.name, data.model)
        if not stockItem then return { success = false, error = "invalid_prop" } end
        if not stockItem.unlimited and stockItem.amount <= 0 then return { success = false, error = "out_of_stock" } end
        definition = stockItem
    elseif data.item ~= nil then
        if type(data.item) ~= "string" then return { success = false, error = "invalid_prop" } end
        definition = findPropItem(job, data.item)
        if not definition then return { success = false, error = "invalid_prop" } end
        consumeItem = data.item
    else
        definition = findProp(getJobProps(job), nil, data.model)
        if not definition then return { success = false, error = "invalid_prop" } end
    end

    if consumeItem then
        if not oxStarted() then return { success = false, error = "inventory_unavailable" } end
        if not ox("RemoveItem", src, consumeItem, 1) then return { success = false, error = "missing_item" } end
    end
    if stockItem and not stockItem.unlimited then
        stockItem.amount = stockItem.amount - 1
    end

    local id = nextPropId
    nextPropId = nextPropId + 1
    local record = {
        id = id,
        model = definition.model,
        label = definition.label or definition.model,
        coords = { x = x, y = y, z = z },
        heading = (tonumber(data.heading) or 0.0) % 360.0,
        streamDistance = math.max(25.0, math.min(tonumber(data.streamDistance) or 150.0, 300.0))
    }
    placedProps[id] = {
        prop = record,
        owner = src,
        job = job,
        stockKey = stockItem and session.stash or nil,
        stockName = stockItem and stockItem.name or nil
    }
    TriggerClientEvent("sky_jobs_base:trunkProps:add", -1, record)

    return {
        success = true,
        prop = record,
        props = session and stockForClient(getTrunkStock(session)) or nil
    }
end)

Sky.Cb.Register("sky_jobs_base:trunkProps:remove", function(source, data)
    local src = tonumber(source)
    local id = tonumber(type(data) == "table" and data.id or data)
    local placed = id and placedProps[id]
    if not placed then return { success = false, error = "not_found" } end

    if placed.owner ~= src and requireEmployee(src, true) ~= placed.job then
        return { success = false, error = "no_permission" }
    end
    local c = placed.prop.coords
    if playerDistanceTo(src, vector3(c.x, c.y, c.z)) > PROP_REMOVE_DISTANCE then
        return { success = false, error = "too_far" }
    end

    removePlacedProp(id)
    return { success = true }
end)

AddEventHandler("playerDropped", function()
    local src = source
    openStorages[src] = nil
    openTrunks[src] = nil
    for id, placed in pairs(placedProps) do
        if placed.owner == src then removePlacedProp(id) end
    end
end)

-- Shared with garage.lua (trunk contents follow the vehicle id, not its plate).
Sky_Jobs.JobStorage = {
    OxStarted = oxStarted,
    TrunkStash = function(job, vehicleId) return stashName("tr", job, "v" .. tostring(vehicleId)) end,
    ClearStash = function(name)
        if ensureStash(name, "Trunk", 50, 1000000) then ox("ClearInventory", name) end
    end
}
