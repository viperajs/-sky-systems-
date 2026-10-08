-- Run from the workspace root: lua tests/creator_points_spec.lua
-- Loads sky_jobs_base's client import, config and creator.lua with mocked natives and
-- checks which interaction points the workshop locations from /jobconfig create in-game.

local function vector3(x, y, z)
    return setmetatable({ x = x, y = y, z = z }, { __name = "vector3" })
end

local function newEnv()
    local f = { events = {}, timers = {}, threads = {}, created = {}, deleted = {}, triggered = {}, serverEvents = {}, blips = 0 }
    local env = setmetatable({}, { __index = _G })
    env._G = env
    env.vector3 = vector3
    env.vec = vector3
    env.json = { encode = function() return "{}" end, decode = function() return {} end }
    env.IsDuplicityVersion = function() return false end
    env.GetCurrentResourceName = function() return "sky_jobs_base" end
    env.GetResourceState = function(name) return (f.stopped and f.stopped[name]) and "stopped" or "started" end
    env.GetGameTimer = function() return 0 end
    env.AddEventHandler = function(name, fn)
        f.events[name] = f.events[name] or {}
        table.insert(f.events[name], fn)
    end
    env.RegisterNetEvent = function(name, fn) if fn then env.AddEventHandler(name, fn) end end
    env.RegisterNUICallback = function() end
    env.RegisterCommand = function() end
    env.RegisterKeyMapping = function() end
    env.CreateThread = function(fn) f.threads[#f.threads + 1] = fn end
    env.SetTimeout = function(_, fn) f.timers[#f.timers + 1] = fn end
    env.Citizen = { CreateThread = env.CreateThread, SetTimeout = env.SetTimeout, Wait = function() end }
    env.Wait = function() end
    env.TriggerEvent = function(name, ...)
        f.triggered[#f.triggered + 1] = { name = name, args = table.pack(...) }
        for _, fn in ipairs(f.events[name] or {}) do fn(...) end
    end
    env.TriggerServerEvent = function(name, ...)
        f.serverEvents[#f.serverEvents + 1] = { name = name, args = table.pack(...) }
    end
    env.SendNUIMessage = function() end
    env.SetNuiFocus = function() end
    env.SetNuiFocusKeepInput = function() end
    env.DoesEntityExist = function() return false end
    env.DoesBlipExist = function() return true end
    env.RemoveBlip = function() f.blips = f.blips - 1 end
    env.AddBlipForCoord = function() f.blips = f.blips + 1; return f.blips end
    for _, native in ipairs({ "SetBlipSprite", "SetBlipDisplay", "SetBlipScale", "SetBlipColour", "SetBlipAsShortRange",
        "BeginTextCommandSetBlipName", "AddTextComponentSubstringPlayerName", "EndTextCommandSetBlipName" }) do
        env[native] = function() end
    end

    local mechanicDefinitions = {
        self_service_tuning = { public = true, forceMarkerInteraction = true, interactionDistance = 2.5, marker = { enabled = true, type = 1 }, npc = { enabled = false } },
        stolen_parts_dealer = { public = true, interaction = true, marker = { enabled = false }, npc = { enabled = true, pedHash = "s_m_m_autoshop_01" } },
        parts_drop = { public = false, interaction = true, interactionDistance = 2.5, marker = { enabled = false }, npc = { enabled = false } },
        lift = { public = false, interaction = false, marker = { enabled = false } },
        engine_swap = { public = true, interaction = false, marker = { enabled = false } }
    }

    env.exports = setmetatable({}, {
        __call = function() end,
        __index = function(_, resource)
            if resource == "sky_base" then
                return {
                    CreateInteractionPoint = function(_, coords, message, event, id, marker, npc, blip, owner, dist, ped, onSpawn, extra)
                        f.created[id] = { coords = coords, message = message, event = event, marker = marker, npc = npc, owner = owner, dist = dist, extra = extra }
                    end,
                    DeleteInteractionPoint = function(_, id)
                        f.deleted[#f.deleted + 1] = id
                        f.created[id] = nil
                    end
                }
            elseif resource == "sky_mechanicjob" then
                return { GetCreatorTypeDefinitions = function() return mechanicDefinitions end }
            end
            error("No such export resource " .. tostring(resource))
        end
    })

    env.Locales = {}
    function f.load(path) assert(loadfile(path, "t", env))() end
    function f.fire(name, ...) for _, fn in ipairs(f.events[name] or {}) do fn(...) end end
    function f.flushTimers()
        for _ = 1, 10 do
            local pending = f.timers
            if #pending == 0 then return end
            f.timers = {}
            for _, fn in ipairs(pending) do fn() end
        end
    end
    function f.createdTypes()
        local types = {}
        for id in pairs(f.created) do
            types[#types + 1] = id:match(":([^:]+)$")
        end
        table.sort(types)
        return table.concat(types, ",")
    end
    f.env = env
    return f
end

local workshopData = {
    entries = {
        {
            id = "mechanic_lscustoms",
            name = "Los Santos Customs",
            jobKey = "mechanic",
            locationSettings = { lsc_shop = { requiresOnDuty = false } },
            points = {
                { uid = "lsc_duty", type = "duty", label = "Duty Station", x = 1.0, y = 1.0, z = 1.0 },
                { uid = "lsc_storage", type = "storage", label = "Parts Storage", x = 2.0, y = 1.0, z = 1.0 },
                { uid = "lsc_shop", type = "shop", label = "Wholesale Shop", x = 3.0, y = 1.0, z = 1.0 },
                { uid = "lsc_boss", type = "management", label = "Management", x = 4.0, y = 1.0, z = 1.0 },
                { uid = "lsc_delivery", type = "parts_drop", label = "Delivery Drop", x = 5.0, y = 1.0, z = 1.0 },
                { uid = "lsc_lift_1", type = "lift", label = "Car Lift 1", x = 6.0, y = 1.0, z = 1.0 },
                { uid = "lsc_tuning", type = "self_service_tuning", label = "Tuning Area", x = 7.0, y = 1.0, z = 1.0 },
                { uid = "lsc_dyno", type = "dyno", label = "Dyno Stand", x = 8.0, y = 1.0, z = 1.0 },
                { uid = "lsc_dealer", type = "stolen_parts_dealer", label = "Dealer", x = 9.0, y = 1.0, z = 1.0 }
            }
        }
    }
}

local f = newEnv()
f.load("sky_jobs_base/source/import.lua")
f.load("sky_jobs_base/config/init.lua")
f.load("sky_jobs_base/config/config.lua")
f.load("sky_jobs_base/source/client/creator.lua")

-- The client asks the server for the saved locations when it starts.
f.threads[#f.threads]()
assert(f.serverEvents[#f.serverEvents].name == "sky_jobs_base:creator:requestSync", "creator data must be requested at start")

-- Before the job is known only public points are created.
f.fire("sky_jobs_base:creatorUpdated", "workshopcreator", workshopData)
f.flushTimers()
assert(f.createdTypes() == "lsc_dealer,lsc_tuning", "public points before job load: " .. f.createdTypes())
assert(f.created["sky_jobs_base:creator:workshopcreator:mechanic_lscustoms:lsc_dealer"].npc.pedHash == "s_m_m_autoshop_01", "dealer NPC comes from the mechanic definitions")
assert(next(f.created["sky_jobs_base:creator:workshopcreator:mechanic_lscustoms:lsc_dealer"].marker) == nil, "dealer has its marker disabled")

-- An on-duty mechanic sees every workshop point except the lift (handled by sky_mechanicjob).
f.fire("sky_base:updateJob", { name = "mechanic", onduty = true })
f.flushTimers()
assert(f.createdTypes() == "lsc_boss,lsc_dealer,lsc_delivery,lsc_duty,lsc_dyno,lsc_shop,lsc_storage,lsc_tuning", "on duty: " .. f.createdTypes())
local duty = f.created["sky_jobs_base:creator:workshopcreator:mechanic_lscustoms:lsc_duty"]
assert(duty.owner == "sky_jobs_base", "points are owned by this resource, not the creator data table")
assert(duty.message == "Los Santos Customs - Duty Station")
assert(duty.marker.type == 1 and duty.marker.enabled == nil, "duty marker from Config.Interactions.duty_terminal")
assert(next(f.created["sky_jobs_base:creator:workshopcreator:mechanic_lscustoms:lsc_delivery"].marker) == nil, "parts drop keeps the mechanic's disabled marker")
assert(f.created["sky_jobs_base:creator:workshopcreator:mechanic_lscustoms:lsc_dyno"].marker.type == 1, "dyno gets the default marker")

-- Off duty: duty-bound points disappear; the duty station, public points and the shop
-- (requiresOnDuty = false in the configurator) stay.
f.fire("sky_base:updateDuty", false)
f.flushTimers()
assert(f.createdTypes() == "lsc_dealer,lsc_duty,lsc_shop,lsc_tuning", "off duty: " .. f.createdTypes())

-- Pressing E at the duty station opens the duty terminal of that workshop.
f.triggered = {}
local function press(pointId) f.env.TriggerEvent("sky_jobs_base:creator:point", pointId, { id = pointId }) end
press("sky_jobs_base:creator:workshopcreator:mechanic_lscustoms:lsc_duty")
local opened = false
for _, ev in ipairs(f.triggered) do
    if ev.name == "sky_jobs_base:duty:open" and ev.args[1] == "Los Santos Customs" then opened = true end
end
assert(opened, "duty point must open the duty terminal")

-- A storage point cannot be used off duty even if a stale prompt is pressed.
f.triggered = {}
press("sky_jobs_base:creator:workshopcreator:mechanic_lscustoms:lsc_storage")
for _, ev in ipairs(f.triggered) do
    assert(ev.name ~= "sky_jobs_base:storageInteraction", "storage must not open off duty")
end

-- The self-service tuning point raises the job's interaction event for sky_mechanicjob.
f.triggered = {}
press("sky_jobs_base:creator:workshopcreator:mechanic_lscustoms:lsc_tuning")
local tuning = false
for _, ev in ipairs(f.triggered) do
    if ev.name == "sky_jobs_base:interaction:mechanic:self_service_tuning" then tuning = true end
end
assert(tuning, "self-service tuning must raise the mechanic interaction event")

-- Losing the job leaves only the public points.
f.fire("sky_base:updateJob", { name = "unemployed", onduty = false })
f.flushTimers()
assert(f.createdTypes() == "lsc_dealer,lsc_tuning", "unemployed: " .. f.createdTypes())

-- Starting sky_mechanicjob again requests the workshop locations.
f.fire("onClientResourceStart", "sky_mechanicjob")
f.flushTimers()
local last = f.serverEvents[#f.serverEvents]
assert(last.name == "sky_jobs_base:creator:requestSync" and last.args[1] == "workshopcreator", "owner restart must resync its creator")

print("PASS: workshop locations create in-game points by job, duty and public visibility; duty, storage and tuning interactions; resyncs.")
