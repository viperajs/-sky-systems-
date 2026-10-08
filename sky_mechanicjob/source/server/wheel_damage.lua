if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/wheel_damage.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/wheel_damage.lua
--  Wheel Damage State Bag & Physical Tyre Sync
-- =====================================================

local STATE_BAG_KEY = "sky_mechanic_wheel_damage"
local RESET_VEHICLE_RANGE = 10.0
local MAX_WHEEL_DAMAGE = 250.0
local UPDATE_WINDOW_MS = 1000
local MAX_UPDATES_PER_WINDOW = 10

-- Rear wheels of six-wheelers are stolen/repaired as one position (2+4, 3+5).
local POSITION_BY_KEY = { ["0"] = "fl", ["1"] = "fr", ["2"] = "rl", ["4"] = "rl", ["3"] = "rr", ["5"] = "rr" }

local updateWindows = {}

local function toWheelKey(value)
    local idx = tonumber(value)
    if not idx or idx % 1 ~= 0 or idx < 0 or idx > 7 then return nil end
    return tostring(math.floor(idx))
end

local function normalizeEntry(entry)
    if type(entry) ~= "table" then return nil end
    local damage = tonumber(entry.damage) or 0.0
    if damage ~= damage then damage = 0.0 end
    return {
        damage = math.max(0.0, math.min(MAX_WHEEL_DAMAGE, damage)),
        popped = entry.popped == true,
        detached = entry.detached == true,
        source = entry.source == "theft" and "theft" or "damage"
    }
end

-- Shared with wheel_theft.lua and the repair code (call inside handlers only).
MechanicWheelDamage = MechanicWheelDamage or {}

--- Current wheel state of a vehicle, keyed by wheel index string "0".."7".
function MechanicWheelDamage.Read(entity)
    local bag = Entity(entity).state[STATE_BAG_KEY]
    local wheels = {}
    if type(bag) == "table" and type(bag.wheels) == "table" then
        for key, entry in pairs(bag.wheels) do
            local wheelKey = toWheelKey(key)
            local normalized = normalizeEntry(entry)
            if wheelKey and normalized then wheels[wheelKey] = normalized end
        end
    end
    return wheels
end

---@return number missingPositions, boolean allWheelsMissing
function MechanicWheelDamage.CountMissing(wheels)
    local missing, count = {}, 0
    for key, entry in pairs(wheels) do
        if entry.detached then
            local position = POSITION_BY_KEY[key] or key
            if not missing[position] then
                missing[position] = true
                count = count + 1
            end
        end
    end
    return count, (missing.fl and missing.fr and missing.rl and missing.rr) == true
end

function MechanicWheelDamage.Write(entity, wheels)
    if next(wheels) == nil then
        Entity(entity).state:set(STATE_BAG_KEY, nil, true)
        return
    end
    local _, allMissing = MechanicWheelDamage.CountMissing(wheels)
    Entity(entity).state:set(STATE_BAG_KEY, { wheels = wheels, allWheelsMissing = allMissing }, true)
end

function MechanicWheelDamage.Reset(entity)
    Entity(entity).state:set(STATE_BAG_KEY, nil, true)
end

function MechanicWheelDamage.AnyDetached(entity, indexes)
    local wheels = MechanicWheelDamage.Read(entity)
    for _, idx in ipairs(indexes) do
        local entry = wheels[tostring(idx)]
        if entry and entry.detached then return true end
    end
    return false
end

local function isRateLimited(src)
    local now = GetGameTimer()
    local window = updateWindows[src]
    if not window or now - window.startedAt >= UPDATE_WINDOW_MS then
        updateWindows[src] = { startedAt = now, count = 1 }
        return false
    end
    window.count = window.count + 1
    return window.count > MAX_UPDATES_PER_WINDOW
end

-- ── Net Events ───────────────────────────────────────

-- Only a mechanic on duty (or an admin) next to the vehicle may clear its wheel state; repairs
-- completed on the server reset it themselves.
RegisterNetEvent("sky_mechanicjob:wheelDamage:reset", function(netId)
    local src = tonumber(source)
    if not src then return end
    if not (Functions.IsMechanicOnDuty(src) or Functions.HasPermission(src, "adminrepair")) then return end

    local entity = Functions.GetVehicleByNetId(src, math.floor(tonumber(netId) or 0), RESET_VEHICLE_RANGE)
    if entity then
        MechanicWheelDamage.Reset(entity)
    end
end)

-- Damage reported by the vehicle's network owner or driver. Updates are a map keyed by wheel
-- index or an array of { index = n, ... }; damage only grows and popped/detached never clear here.
RegisterNetEvent("sky_mechanicjob:wheelDamage:update", function(netId, updates)
    local src = tonumber(source)
    if not src or type(updates) ~= "table" or isRateLimited(src) then return end

    local vehicleNetId = math.floor(tonumber(netId) or 0)
    if vehicleNetId <= 0 then return end

    local entity = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not entity or entity == 0 or not DoesEntityExist(entity) or GetEntityType(entity) ~= 2 then return end
    if NetworkGetEntityOwner(entity) ~= src and GetPedInVehicleSeat(entity, -1) ~= GetPlayerPed(src) then return end

    local wheels = MechanicWheelDamage.Read(entity)
    local changed = false

    for key, value in pairs(updates) do
        local wheelKey = toWheelKey(type(value) == "table" and value.index or key)
        local incoming = normalizeEntry(value)
        if wheelKey and incoming then
            local current = wheels[wheelKey]
            local base = current or { damage = 0.0, popped = false, detached = false, source = "damage" }
            local merged = {
                damage = math.max(base.damage, incoming.damage),
                popped = base.popped or incoming.popped,
                detached = base.detached or incoming.detached,
                source = base.source
            }
            if not current or merged.damage ~= base.damage or merged.popped ~= base.popped or merged.detached ~= base.detached then
                wheels[wheelKey] = merged
                changed = true
            end
        end
    end

    if changed then
        MechanicWheelDamage.Write(entity, wheels)
    end
end)

AddEventHandler("playerDropped", function()
    updateWindows[tonumber(source) or source] = nil
end)
