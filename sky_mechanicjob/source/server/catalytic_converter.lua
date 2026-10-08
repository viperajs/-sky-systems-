if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/catalytic_converter.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/catalytic_converter.lua
--  Catalytic Converter Theft, Missing State & Smoke Sync
-- =====================================================

local STATE_BAG_KEY = "sky_mechanic_catalytic_missing"
local THEFT_VEHICLE_RANGE = 8.0
local PENDING_TTL_MS = 600000
local MIN_THEFT_DURATION_MS = 3000
local SMOKE_MIN_INTERVAL_MS = 200
local SMOKE_SYNC_RANGE = 150.0

local pendingByKind = {}
local lastDispatchAt = {}
local lastSmokeAt = {}

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

local function nonEmptyString(value, fallback)
    return (type(value) == "string" and value ~= "") and value or fallback
end

-- ── Shared Theft Helpers (also used by wheel_theft.lua) ──

MechanicTheft = MechanicTheft or {}

function MechanicTheft.GetConfig()
    local cfg = type(Config.PartsTheft) == "table" and Config.PartsTheft or {}
    return {
        tool = nonEmptyString(cfg.item, "lug_wrench"),
        removeTool = cfg.removeItemAfterUse == true,
        wheelItem = nonEmptyString(cfg.stolenWheelItem, "wheels"),
        catalyticItem = nonEmptyString(cfg.catalyticConverterItem, "catalytic_converter"),
        dispatch = type(cfg.dispatch) == "table" and cfg.dispatch or {}
    }
end

function MechanicTheft.GetVehicle(src, netId)
    if (tonumber(netId) or 0) <= 0 then return nil end
    return Functions.GetVehicleByNetId(src, netId, THEFT_VEHICLE_RANGE)
end

function MechanicTheft.SetPending(kind, src, data)
    pendingByKind[kind] = pendingByKind[kind] or {}
    data.at = GetGameTimer()
    pendingByKind[kind][src] = data
end

--- Takes the theft started with prepareSteal; nil when there is none for this vehicle, it expired
--- or it is completed faster than the jack and bolt minigame allow.
function MechanicTheft.TakePending(kind, src, netId)
    local list = pendingByKind[kind]
    local entry = list and list[src]
    if list then list[src] = nil end
    if not entry or entry.netId ~= netId then return nil end

    local elapsed = GetGameTimer() - entry.at
    if elapsed < MIN_THEFT_DURATION_MS or elapsed > PENDING_TTL_MS then return nil end
    return entry
end

function MechanicTheft.Dispatch(src, entity, plate)
    local cfg = MechanicTheft.GetConfig().dispatch
    if cfg.enabled == false or type(cfg.jobs) ~= "table" or #cfg.jobs == 0 then return end

    local now = os.time()
    local cooldown = math.max(0, tonumber(cfg.cooldownSeconds) or 120)
    if lastDispatchAt[src] and now - lastDispatchAt[src] < cooldown then return end
    if GetResourceState("sky_jobs_base") ~= "started" or not DoesEntityExist(entity) then return end
    lastDispatchAt[src] = now

    local plateText = plate ~= "" and plate or "UNKNOWN"
    local message = tostring(cfg.message or "Suspicious vehicle parts theft reported near {plate}.")
    message = message:gsub("{plate}", function() return plateText end)

    local coords = GetEntityCoords(entity)
    local ok, err = pcall(function()
        return exports.sky_jobs_base:CreateDispatch({
            jobs = cfg.jobs,
            title = tostring(cfg.title or "Vehicle parts theft"),
            message = message,
            coords = { x = coords.x, y = coords.y, z = coords.z }
        })
    end)
    if not ok then
        print(("[sky_mechanicjob][parts_theft] dispatch failed: %s"):format(tostring(err)))
    end
end

AddEventHandler("playerDropped", function()
    local src = tonumber(source) or source
    for _, list in pairs(pendingByKind) do list[src] = nil end
    lastDispatchAt[src] = nil
    lastSmokeAt[src] = nil
end)

-- ── Missing State ────────────────────────────────────

local function isCatalyticMissing(entity, plate)
    if Entity(entity).state[STATE_BAG_KEY] == true then return true end
    if plate == "" then return false end

    local entry = MechanicWear.Load(plate)
    if entry and (tonumber(entry.wear.catalytic_converter) or 100.0) <= 0.0 then return true end

    local row = MySQL.single.await("SELECT plate FROM sky_mechanic_stolen_catalytics WHERE plate = ? LIMIT 1", { plate })
    return row ~= nil
end

-- ── Prepare Steal Callback ────────────────────────────

Sky.Cb.Register("sky_mechanicjob:catalytic:prepareSteal", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local cfg = MechanicTheft.GetConfig()
    if not Functions.HasItem(src, cfg.tool, 1) then
        return { success = false, error = "missing_item" }
    end

    local netId = math.floor(tonumber(data and data.vehicleNetId) or 0)
    local entity = MechanicTheft.GetVehicle(src, netId)
    if not entity then
        return { success = false, error = "vehicle_too_far" }
    end

    local plate = sanitizePlate(GetVehicleNumberPlateText(entity))
    if isCatalyticMissing(entity, plate) then
        return { success = false, error = "already_missing" }
    end

    MechanicTheft.SetPending("catalytic", src, { netId = netId })
    MechanicTheft.Dispatch(src, entity, plate)
    return { success = true }
end)

-- ── Complete Steal Callback ───────────────────────────

Sky.Cb.Register("sky_mechanicjob:catalytic:completeSteal", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local netId = math.floor(tonumber(data and data.vehicleNetId) or 0)
    if not MechanicTheft.TakePending("catalytic", src, netId) then
        return { success = false, error = "invalid_state" }
    end

    local cfg = MechanicTheft.GetConfig()
    if not Functions.HasItem(src, cfg.tool, 1) then
        return { success = false, error = "missing_item" }
    end

    local entity = MechanicTheft.GetVehicle(src, netId)
    if not entity then
        return { success = false, error = "vehicle_too_far" }
    end

    local plate = sanitizePlate(GetVehicleNumberPlateText(entity))
    if isCatalyticMissing(entity, plate) then
        return { success = false, error = "already_missing" }
    end
    if not DoesEntityExist(entity) then
        return { success = false, error = "vehicle_too_far" }
    end
    -- Re-checked without yielding before the claim below; another thief may have finished meanwhile.
    if Entity(entity).state[STATE_BAG_KEY] == true then
        return { success = false, error = "already_missing" }
    end

    if not Functions.CanCarryItem(src, cfg.catalyticItem, 1) then
        return { success = false, error = "inventory_full" }
    end
    if cfg.removeTool and not Functions.RemoveItem(src, cfg.tool, 1) then
        return { success = false, error = "missing_item" }
    end

    Entity(entity).state:set(STATE_BAG_KEY, true, true)

    if not Functions.AddItem(src, cfg.catalyticItem, 1) then
        Entity(entity).state:set(STATE_BAG_KEY, nil, true)
        if cfg.removeTool then Functions.AddItem(src, cfg.tool, 1) end
        return { success = false, error = "inventory_full" }
    end

    if plate ~= "" then
        local entry = MechanicWear.SetPart(plate, "catalytic_converter", 0.0)
        if entry and entry.persist then
            MySQL.query.await([[
                INSERT INTO sky_mechanic_stolen_catalytics (plate)
                VALUES (?)
                ON DUPLICATE KEY UPDATE stolen_at = CURRENT_TIMESTAMP
            ]], { plate })
        end
    end

    return { success = true }
end)

-- ── Smoke FX Sync Event ──────────────────────────────

-- Relayed only for the driver of a vehicle that is really missing its converter, rate limited
-- and only to players close enough to see the smoke.
RegisterNetEvent("sky_mechanicjob:catalytic:syncSmoke", function(netId, rpmScale)
    local src = tonumber(source)
    if not src then return end

    local now = GetGameTimer()
    if (lastSmokeAt[src] or 0) + SMOKE_MIN_INTERVAL_MS > now then return end
    lastSmokeAt[src] = now

    local vehicleNetId = math.floor(tonumber(netId) or 0)
    if vehicleNetId <= 0 then return end

    local entity = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not entity or entity == 0 or not DoesEntityExist(entity) or GetEntityType(entity) ~= 2 then return end
    if GetPedInVehicleSeat(entity, -1) ~= GetPlayerPed(src) then return end
    if Entity(entity).state[STATE_BAG_KEY] ~= true then return end

    local scale = math.max(0.0, math.min(2.5, tonumber(rpmScale) or 1.0))
    local origin = GetEntityCoords(entity)

    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)
        if ped ~= 0 and #(GetEntityCoords(ped) - origin) <= SMOKE_SYNC_RANGE then
            TriggerClientEvent("sky_mechanicjob:catalytic:syncSmoke", tonumber(playerId), vehicleNetId, scale)
        end
    end
end)
