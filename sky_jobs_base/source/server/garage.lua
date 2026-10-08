if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/garage.lua") end
-- =====================================================
--  sky_jobs_base · source/server/garage.lua
--  Job Garage Vehicles & Catalog Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}
Sky_Jobs.Garage = Sky_Jobs.Garage or {}
local Garage = Sky_Jobs.Garage

local PARK_TOLERANCE = 4.0
local SPAWN_CONFIRM_SECONDS = 30
local MENU_TYPES = {
    vehicle = { "job_garage", "garage_vehicle_menu" },
    helicopter = { "garage_helicopter_menu" },
    boat = { "garage_boat_menu" }
}
local PARK_TYPES = { vehicle = "garage_vehicle_park", helicopter = "garage_helicopter_park", boat = "garage_boat_park" }
local SPAWN_TYPES = { vehicle = "garage_vehicle_spawn", helicopter = "garage_helicopter_spawn", boat = "garage_boat_spawn" }

local pendingSpawns = {}

CreateThread(function()
    while not MySQL do Wait(500) end
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `sky_jobs_garage_vehicles` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `job` VARCHAR(50) NOT NULL,
            `plate` VARCHAR(16) NOT NULL,
            `model` VARCHAR(64) NOT NULL,
            `name` VARCHAR(100) DEFAULT NULL,
            `garage_type` VARCHAR(20) NOT NULL DEFAULT 'vehicle',
            `state` VARCHAR(16) NOT NULL DEFAULT 'stored',
            `props` LONGTEXT DEFAULT NULL,
            `fuel` FLOAT DEFAULT 100,
            `purchase_price` INT NOT NULL DEFAULT 0,
            `last_driver` VARCHAR(100) DEFAULT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY `uk_plate` (`plate`),
            INDEX `idx_job` (`job`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
end)

local function normalizeGarageType(value)
    local lower = type(value) == "string" and value:lower() or ""
    if lower == "helicopter" or lower == "heli" or lower == "air" then return "helicopter" end
    if lower == "boat" or lower == "sea" or lower == "water" then return "boat" end
    return "vehicle"
end

-- Plates are compared without spaces, upper case (as the client sends them).
function Garage.NormalizePlate(plate)
    if type(plate) ~= "string" and type(plate) ~= "number" then return nil end
    local normalized = tostring(plate):gsub("%s+", ""):upper()
    if not normalized:match("^[A-Z0-9]+$") or #normalized > 8 then return nil end
    return normalized
end

local function hashOf(model)
    if type(model) == "number" then return model % 4294967296 end
    if type(model) ~= "string" or model == "" then return nil end
    return GetHashKey(model) % 4294967296
end

local function getCatalog(job)
    local definition = Sky_Jobs.GetJobDefinition and Sky_Jobs.GetJobDefinition(job)
    return type(definition) == "table" and type(definition.vehicles) == "table" and definition.vehicles or {}, definition
end

function Garage.FindCatalogEntry(job, model)
    local hash = hashOf(model)
    if not hash then return nil end
    for _, entry in ipairs((getCatalog(job))) do
        if type(entry) == "table" and hashOf(entry.model) == hash then return entry end
        if type(entry) == "table" and type(entry.altModels) == "table" then
            for _, alt in ipairs(entry.altModels) do
                if hashOf(alt) == hash then return entry end
            end
        end
    end
    return nil
end

function Garage.GetVehicle(job, plate)
    if not job or not plate then return nil end
    return MySQL.single.await("SELECT * FROM sky_jobs_garage_vehicles WHERE job = ? AND plate = ? LIMIT 1", { job, plate })
end

-- garageId: "creator:<creatorKey>:<entryId>:<garageType>" (client creator.lua).
function Garage.ResolveGarage(src, job, garageId)
    if type(garageId) ~= "string" or #garageId > 200 then return nil, "unavailable" end
    local creatorKey, entryId, garageType = garageId:match("^creator:([^:]+):(.+):(%a+)$")
    if not creatorKey then return nil, "unavailable" end
    garageType = normalizeGarageType(garageType)

    local point, err = Sky_Jobs.FindStationPoint(src, job, entryId, MENU_TYPES[garageType], { creatorKey = creatorKey })
    if not point then return nil, err end
    if point.requiresDuty and not Sky_Jobs.PlayerCache.IsOnDuty(src) then return nil, "not_on_duty" end

    return {
        creatorKey = creatorKey,
        entryId = entryId,
        garageType = garageType,
        coords = point.coords,
        entry = point.entry
    }
end

local function requireEmployee(src)
    if not Sky_Jobs.GetEmployment then return nil, "unavailable" end
    local job = Sky_Jobs.GetEmployment(src)
    if not job then return nil, "no_job" end
    return job
end

local function worldPlates()
    local plates = {}
    for _, vehicle in ipairs(GetAllVehicles()) do
        local plate = Garage.NormalizePlate(GetVehicleNumberPlateText(vehicle))
        if plate then plates[plate] = vehicle end
    end
    return plates
end

-- A vehicle marked "out" whose entity is gone (destroyed, cleaned up, server restart) can be
-- taken out again.
local function isOut(row, world)
    if row.state ~= "out" then return false end
    local pending = pendingSpawns[row.plate]
    if pending and os.time() - pending.at < SPAWN_CONFIRM_SECONDS then return true end
    return world[row.plate] ~= nil
end

local function sellPrice(row)
    local pct = tonumber(Config and Config.JobGarage and Config.JobGarage.sellPercentage) or 50
    return math.max(0, math.floor((tonumber(row.purchase_price) or 0) * pct / 100))
end

local function canChangePlate(src)
    return not (Config and Config.JobGarage and Config.JobGarage.allowPlateChange == false)
        and Sky_Jobs.HasJobPermission(src, "PURCHASE_VEHICLES")
end

local function buildGarageData(src, job, garage)
    local catalogSource, definition = getCatalog(job)
    local canPurchase = Sky_Jobs.HasJobPermission(src, "PURCHASE_VEHICLES")
    local jobGroup = type(definition) == "table" and (definition.jobGroup or definition.group) or nil

    local world = worldPlates()
    local owned = {}
    local rows = MySQL.query.await("SELECT * FROM sky_jobs_garage_vehicles WHERE job = ? AND garage_type = ? ORDER BY id", { job, garage.garageType }) or {}
    for _, row in ipairs(rows) do
        local entry = Garage.FindCatalogEntry(job, row.model)
        owned[#owned + 1] = {
            id = row.id,
            plate = row.plate,
            model = row.model,
            name = row.name or (entry and entry.name) or row.model,
            state = isOut(row, world) and "parked" or "stored",
            sellPrice = sellPrice(row),
            trunkCapacity = entry and tonumber(entry.trunkCapacity) or nil,
            hasStretcher = entry ~= nil and entry.hasStretcher ~= false,
            last_driver = row.last_driver,
            noAccess = Sky_Jobs.IsRestrictedFor(src, { "vehicles" }, row.model)
        }
    end

    local catalog = {}
    for _, entry in ipairs(catalogSource) do
        if type(entry) == "table" and type(entry.model) == "string" and normalizeGarageType(entry.garageType) == garage.garageType then
            catalog[#catalog + 1] = {
                name = entry.name or entry.model,
                model = entry.model,
                price = math.max(0, math.floor(tonumber(entry.price) or 0)),
                trunkCapacity = tonumber(entry.trunkCapacity),
                garageType = garage.garageType
            }
        end
    end

    local plateChange = canChangePlate(src)
    return {
        garageType = garage.garageType,
        jobColor = type(definition) == "table" and definition.color or nil,
        jobGroup = jobGroup,
        canPurchase = canPurchase,
        canSell = Sky_Jobs.HasJobPermission(src, "SELL_VEHICLES"),
        canChangePlate = plateChange,
        plateChangeEnabled = plateChange,
        owned = owned,
        catalog = catalog,
        balance = canPurchase and Sky_Jobs.GetSocietyBalance(job) or 0
    }
end

-- Shared start of every garage menu action.
local function openGarage(src, garageId, permission)
    local job, err = requireEmployee(src)
    if not job then return nil, nil, err end
    local garage, garageErr = Garage.ResolveGarage(src, job, garageId)
    if not garage then return nil, nil, garageErr end
    if permission and not Sky_Jobs.HasJobPermission(src, permission) then return nil, nil, "no_permission" end
    return job, garage
end

local function isPlateTaken(plate)
    if MySQL.single.await("SELECT id FROM sky_jobs_garage_vehicles WHERE plate = ? LIMIT 1", { plate }) then return true end
    local ok, row = pcall(MySQL.single.await, "SELECT plate FROM player_vehicles WHERE plate = ? LIMIT 1", { plate })
    return ok and row ~= nil
end

local function generatePlate(job)
    local prefix = (job:upper():gsub("[^A-Z]", "") .. "JOB"):sub(1, 3)
    for _ = 1, 20 do
        local plate = prefix .. tostring(math.random(10000, 99999))
        if not isPlateTaken(plate) then return plate end
    end
    return nil
end

local function initialProps(entry)
    local props = {}
    if type(entry.properties) == "table" then
        for k, v in pairs(entry.properties) do props[k] = v end
    end
    props.color1 = tonumber(entry.primaryColor) or props.color1
    props.color2 = tonumber(entry.secondaryColor) or props.color2
    props.pearlescentColor = tonumber(entry.pearlescentColor) or props.pearlescentColor
    props.wheelColor = tonumber(entry.wheelColor) or props.wheelColor
    props.plate, props.model = nil, nil
    return props
end

local function decodeProps(text)
    if type(text) ~= "string" or text == "" then return nil end
    local ok, props = pcall(json.decode, text)
    return ok and type(props) == "table" and props or nil
end

local function onDutyMembers(job)
    local list = {}
    for _, s in ipairs(GetPlayers()) do
        local member = tonumber(s)
        if member and Sky_Jobs.GetEmployment(member) == job and Sky_Jobs.PlayerCache.IsOnDuty(member) then
            list[#list + 1] = member
        end
    end
    return list
end

local function failure(err)
    return { success = false, error = err }
end

-- ── Callbacks ─────────────────────────────────────────

Sky.Cb.Register("sky_jobs_base:getJobGarageCatalog", function(source)
    local job = requireEmployee(tonumber(source))
    if not job then return { success = true, data = {} } end
    return { success = true, data = (getCatalog(job)) }
end)

Sky.Cb.Register("sky_jobs_base:getGarageVehicles", function(source, garageId)
    local src = tonumber(source)
    if type(garageId) == "table" then garageId = garageId.garageId end
    local job, garage, err = openGarage(src, garageId)
    if not job then return failure(err) end
    return { success = true, data = buildGarageData(src, job, garage) }
end)

Sky.Cb.Register("sky_jobs_base:parkOutVehicle", function(source, data)
    local src = tonumber(source)
    data = type(data) == "table" and data or {}
    local job, garage, err = openGarage(src, data.garageId)
    if not job then return failure(err) end

    local plate = Garage.NormalizePlate(data.plate)
    local row = Garage.GetVehicle(job, plate)
    if not row or row.garage_type ~= garage.garageType then return failure("vehicle_unavailable") end
    if Sky_Jobs.IsRestrictedFor(src, { "vehicles" }, row.model) then return failure("no_permission") end
    if isOut(row, worldPlates()) then return failure("vehicle_out") end

    local spawns = Sky_Jobs.GetStationPoints(garage.creatorKey, garage.entryId, { SPAWN_TYPES[garage.garageType] })
    if #spawns == 0 then return failure("no_spawn_point") end

    -- Claimed before the first await so two requests cannot both take the vehicle out.
    pendingSpawns[plate] = { src = src, id = row.id, at = os.time() }
    local driver = Sky_Jobs.GetPlayerFullName and Sky_Jobs.GetPlayerFullName(src) or GetPlayerName(src)
    local changed = MySQL.update.await("UPDATE sky_jobs_garage_vehicles SET state = 'out', last_driver = ? WHERE id = ? AND state = ?", { driver, row.id, row.state })
    if (changed or 0) < 1 then
        pendingSpawns[plate] = nil
        return failure("vehicle_out")
    end

    local entry = Garage.FindCatalogEntry(job, row.model) or {}
    local first = table.remove(spawns, 1)
    TriggerClientEvent("sky_jobs_base:spawnGarageVehicle", src, {
        model = row.model,
        plate = plate,
        coords = { x = first.x, y = first.y, z = first.z },
        heading = first.heading,
        spawnPoints = spawns,
        vehicleMods = decodeProps(row.props),
        livery = entry.livery,
        extras = entry.extras,
        fuel = tonumber(row.fuel) or 100.0,
        fuelType = entry.fuelType
    })
    return { success = true }
end)

RegisterNetEvent("sky_jobs_base:garageVehicleSpawned", function(data)
    local src = source
    local plate = Garage.NormalizePlate(type(data) == "table" and data.plate or nil)
    local pending = plate and pendingSpawns[plate]
    if not pending or pending.src ~= src then return end
    pendingSpawns[plate] = nil

    local netId = tonumber(data.netId)
    local entity = netId and NetworkGetEntityFromNetworkId(netId) or 0
    if entity == 0 or not DoesEntityExist(entity) or Garage.NormalizePlate(GetVehicleNumberPlateText(entity)) ~= plate then return end
    local job = Sky_Jobs.GetEmployment(src)
    if not job then return end
    for _, member in ipairs(onDutyMembers(job)) do
        if member ~= src then
            TriggerClientEvent("sky_jobs_base:trunk:registerNetId", member, netId, job)
        end
    end
end)

RegisterNetEvent("sky_jobs_base:garageVehicleSpawnFailed", function(data)
    local src = source
    local plate = Garage.NormalizePlate(type(data) == "table" and data.plate or nil)
    local pending = plate and pendingSpawns[plate]
    if not pending or pending.src ~= src then return end
    pendingSpawns[plate] = nil
    if worldPlates()[plate] then return end
    MySQL.update.await("UPDATE sky_jobs_garage_vehicles SET state = 'stored' WHERE id = ? AND state = 'out'", { pending.id })
end)

Sky.Cb.Register("sky_jobs_base:parkVehicle", function(source, garageId, netId, props)
    local src = tonumber(source)
    local job, err = requireEmployee(src)
    if not job then return failure(err) end
    if type(garageId) ~= "string" then return failure("unavailable") end
    local creatorKey, entryId, garageType = garageId:match("^creator:([^:]+):(.+):(%a+)$")
    if not creatorKey then return failure("unavailable") end
    garageType = normalizeGarageType(garageType)

    local entity = tonumber(netId) and NetworkGetEntityFromNetworkId(tonumber(netId)) or 0
    if entity == 0 or not DoesEntityExist(entity) or GetEntityType(entity) ~= 2 then return failure("vehicle_unavailable") end
    if GetPedInVehicleSeat(entity, -1) ~= GetPlayerPed(src) then return failure("not_driver") end

    local parkRadius = tonumber(Config and Config.JobGarage and Config.JobGarage.parkRadius) or 4.0
    local point, pointErr = Sky_Jobs.FindStationPoint(src, job, entryId, { PARK_TYPES[garageType] }, { creatorKey = creatorKey, maxDistance = parkRadius + PARK_TOLERANCE })
    if not point then return failure(pointErr) end
    if point.requiresDuty and not Sky_Jobs.PlayerCache.IsOnDuty(src) then return failure("not_on_duty") end

    local plate = Garage.NormalizePlate(GetVehicleNumberPlateText(entity))
    local row = Garage.GetVehicle(job, plate)
    if not row or row.garage_type ~= garageType or Garage.FindCatalogEntry(job, GetEntityModel(entity)) == nil then
        return failure("not_a_job_vehicle")
    end

    local fuel = 100.0
    local encoded = row.props
    if type(props) == "table" then
        fuel = math.max(0.0, math.min(100.0, tonumber(props.fuelLevel) or 100.0))
        props.plate, props.model = nil, nil
        local ok, text = pcall(json.encode, props)
        if ok and type(text) == "string" and #text <= 65536 then encoded = text end
    end

    MySQL.update.await("UPDATE sky_jobs_garage_vehicles SET state = 'stored', props = ?, fuel = ? WHERE id = ?", { encoded, fuel, row.id })
    pendingSpawns[plate] = nil

    local vehicleNetId = tonumber(netId)
    for _, member in ipairs(onDutyMembers(job)) do
        TriggerClientEvent("sky_jobs_base:trunk:unregisterNetId", member, vehicleNetId)
    end
    -- The client deletes it after the driver got out; this catches a client that does not.
    SetTimeout(3000, function()
        if DoesEntityExist(entity) and Garage.NormalizePlate(GetVehicleNumberPlateText(entity)) == plate then
            DeleteEntity(entity)
        end
    end)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:buyGarageVehicle", function(source, data)
    local src = tonumber(source)
    data = type(data) == "table" and data or {}
    local job, garage, err = openGarage(src, data.garageId, "PURCHASE_VEHICLES")
    if not job then return failure(err) end

    local entry
    for _, candidate in ipairs((getCatalog(job))) do
        if type(candidate) == "table" and candidate.model == data.model and normalizeGarageType(candidate.garageType) == garage.garageType then
            entry = candidate
            break
        end
    end
    if not entry then return failure("invalid_vehicle") end

    local price = math.max(0, math.floor(tonumber(entry.price) or 0))
    local actor = Sky_Jobs.GetPlayerFullName and Sky_Jobs.GetPlayerFullName(src) or GetPlayerName(src)
    local plate = generatePlate(job)
    if not plate then return failure("plate_unavailable") end
    if price > 0 and not Sky_Jobs.DebitSociety(job, price, ("Vehicle purchase: %s"):format(entry.name or entry.model), actor) then
        return failure("Insufficient society funds.")
    end

    local ok, id = pcall(MySQL.insert.await, [[
        INSERT INTO sky_jobs_garage_vehicles (job, plate, model, name, garage_type, state, props, fuel, purchase_price)
        VALUES (?, ?, ?, ?, ?, 'stored', ?, 100, ?)
    ]], { job, plate, entry.model, entry.name or entry.model, garage.garageType, json.encode(initialProps(entry)), price })
    if not ok or not id then
        if price > 0 then Sky_Jobs.CreditSociety(job, price, "Vehicle purchase refund", actor) end
        return failure("purchase_failed")
    end

    return { success = true, data = buildGarageData(src, job, garage) }
end)

Sky.Cb.Register("sky_jobs_base:sellGarageVehicle", function(source, data)
    local src = tonumber(source)
    data = type(data) == "table" and data or {}
    local job, garage, err = openGarage(src, data.garageId, "SELL_VEHICLES")
    if not job then return failure(err) end

    local row = Garage.GetVehicle(job, Garage.NormalizePlate(data.plate))
    if not row or row.garage_type ~= garage.garageType then return failure("vehicle_unavailable") end
    if isOut(row, worldPlates()) then return failure("vehicle_out") end

    local removed = MySQL.update.await("DELETE FROM sky_jobs_garage_vehicles WHERE id = ? AND state = ?", { row.id, row.state })
    if (removed or 0) < 1 then return failure("vehicle_unavailable") end

    local price = sellPrice(row)
    if price > 0 then
        Sky_Jobs.CreditSociety(job, price, ("Vehicle sale: %s"):format(row.name or row.model), Sky_Jobs.GetPlayerFullName and Sky_Jobs.GetPlayerFullName(src) or GetPlayerName(src))
    end
    if Sky_Jobs.JobStorage and Sky_Jobs.JobStorage.OxStarted() then
        Sky_Jobs.JobStorage.ClearStash(Sky_Jobs.JobStorage.TrunkStash(job, row.id))
    end

    return { success = true, data = buildGarageData(src, job, garage) }
end)

local function changePlate(source, data)
    local src = tonumber(source)
    data = type(data) == "table" and data or {}
    if Config and Config.JobGarage and Config.JobGarage.allowPlateChange == false then return failure("plate_change_disabled") end
    local job, garage, err = openGarage(src, data.garageId, "PURCHASE_VEHICLES")
    if not job then return failure(err) end

    local newPlate = Garage.NormalizePlate(data.newPlate)
    if not newPlate or #newPlate < 2 then return failure("invalid_plate") end
    local row = Garage.GetVehicle(job, Garage.NormalizePlate(data.plate))
    if not row or row.garage_type ~= garage.garageType then return failure("vehicle_unavailable") end
    if isOut(row, worldPlates()) then return failure("vehicle_out") end
    if newPlate ~= row.plate and isPlateTaken(newPlate) then return failure("plate_taken") end

    local ok, changed = pcall(MySQL.update.await, "UPDATE sky_jobs_garage_vehicles SET plate = ? WHERE id = ? AND state = ?", { newPlate, row.id, row.state })
    if not ok or (changed or 0) < 1 then return failure("plate_taken") end

    local result = buildGarageData(src, job, garage)
    return { success = true, plate = newPlate, data = result }
end

Sky.Cb.Register("sky_jobs_base:changePlate", changePlate)
Sky.Cb.Register("sky_jobs_base:updateGarageVehiclePlate", changePlate)

AddEventHandler("playerDropped", function()
    local src = source
    for plate, pending in pairs(pendingSpawns) do
        if pending.src == src then pendingSpawns[plate] = nil end
    end
end)
