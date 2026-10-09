-- Run from the workspace root: lua tests/radial_target_spec.lua
-- Loads sky_jobs_base's radial menu with sky_base's target bridge (as its fxmanifest.lua does)
-- and checks that the mechanic's job actions (workshop lift, engine hoist) reach ox_target.

local stub
stub = setmetatable({}, {
    __index = function() return stub end,
    __call = function() return stub end,
})

local MODULE_GLOBALS = { Config = true, Locales = true, Sky_Jobs = true }

local function newClient(skyBase)
    local f = { threads = {}, exports = {}, added = {}, removed = {}, triggered = {} }
    local env = setmetatable({}, { __index = function(_, key)
        local value = _G[key]
        if value ~= nil or MODULE_GLOBALS[key] then return value end
        return stub
    end })
    env._G = env
    env.SkyDiagnostics = false
    env.print = function() end
    env.IsDuplicityVersion = function() return false end
    env.GetCurrentResourceName = function() return "sky_jobs_base" end
    env.GetResourceState = function() return "started" end
    env.IsPauseMenuActive = function() return false end
    env.CreateThread = function(fn) f.threads[#f.threads + 1] = coroutine.create(fn) end
    env.Wait = function(ms) coroutine.yield(ms) end
    env.Citizen = { CreateThread = env.CreateThread, Wait = env.Wait }
    env.Sky = {
        Config = {},
        Functions = { IsPlayerDead = function() return false end },
        Cb = { Trigger = function(name)
            if name == "sky_jobs_base:getRegisteredJobs" then return { "mechanic" } end
            if name == "sky_jobs_base:getJobInfo" then return { group = "mechanic" } end
            return nil
        end },
    }
    env.Sky_Jobs = { TabletApps = { GetProviderResources = function() return { "sky_mechanicjob" } end } }
    env.GetJobState = function() return { employed = true, onDuty = true, jobKey = "mechanic" } end

    local external = {
        sky_base = skyBase,
        ox_target = {
            addGlobalOption = function(_, options)
                for _, option in ipairs(options) do f.added[option.name] = option end
            end,
            removeGlobalOption = function(_, names)
                for _, name in ipairs(names) do
                    f.removed[#f.removed + 1] = name
                    f.added[name] = nil
                end
            end,
        },
        sky_mechanicjob = {
            getRadialActions = function()
                return {
                    { id = "access_lift", label = "Access Lift" },
                    { id = "take_engine_hoist", label = "Take Engine Hoist" },
                    { id = "attach_engine_hoist", label = "Attach Engine Hoist", disabled = true },
                }
            end,
            triggerRadialMenuAction = function(_, actionId)
                f.triggered[#f.triggered + 1] = actionId
                return true
            end,
        },
        sky_jobs_base = { getNearbyTrunkPropTarget = function() return nil end },
    }
    env.exports = setmetatable({}, {
        __call = function(_, name, fn) f.exports[name] = fn end,
        __index = function(_, name) return external[name] or stub end,
    })

    function f.load(path) assert(loadfile(path, "t", env))() end
    f.env = env
    return f
end

-- sky_jobs_base's fxmanifest.lua loads the bridge after target.lua and before radial_menu.lua.
do
    local manifest = assert(io.open("sky_jobs_base/fxmanifest.lua")):read("a")
    local clientScripts = manifest:match("client_scripts%s*(%b{})")
    local last = 0
    for _, file in ipairs({ "source/client/target.lua", "@sky_base/config/target/_init.lua",
        "@sky_base/config/target/ox.lua", "@sky_base/config/target/qb.lua", "source/client/radial_menu.lua" }) do
        local at = clientScripts:find("'" .. file .. "'", 1, true)
        assert(at and at > last, "sky_jobs_base/fxmanifest.lua must load " .. file .. " in this order")
        last = at
    end
end

-- The files in the order of sky_jobs_base's fxmanifest.lua.
local function loadRadialMenu(f)
    f.load("sky_jobs_base/config/init.lua")
    f.load("sky_jobs_base/config/config.lua")
    f.load("sky_jobs_base/source/client/target.lua")
    f.load("sky_base/config/target/_init.lua")
    f.load("sky_base/config/target/ox.lua")
    f.load("sky_base/config/target/qb.lua")
    f.load("sky_jobs_base/source/client/radial_menu.lua")
end

-- Runs the start threads (registered jobs after 1 s, the first target sync after 1.5 s) up to
-- their next wait.
local function runStartThreads(f)
    for _, thread in ipairs(f.threads) do
        assert(coroutine.resume(thread))
        if coroutine.status(thread) == "suspended" then
            local ok, err = coroutine.resume(thread)
            assert(ok, err)
        end
    end
end

-- 1. With ox_target in sky_base, the lift and engine hoist actions are ox_target options.
local ox = newClient({ GetTargetSystem = function() return "ox" end })
loadRadialMenu(ox)
local Sky = ox.env.Sky
assert(Sky.Config.target == "ox" and Sky.Target.IsEnabled() == true)
assert(ox.env.Config.JobRadial.oxTarget.enabled == true)
runStartThreads(ox)

local lift = ox.added["sky_jobs_base:radial:access_lift"]
local hoist = ox.added["sky_jobs_base:radial:take_engine_hoist"]
assert(lift and hoist, "the mechanic actions were not added to ox_target")
assert(lift.label == "Access Lift" and not ox.added["sky_jobs_base:radial:tablet"])
-- Shown whatever the player aims at (global options), hidden while unavailable.
assert(lift.canInteract(0) == true and hoist.canInteract(1234) == true)
local attach = ox.added["sky_jobs_base:radial:attach_engine_hoist"]
assert(attach and attach.canInteract(0) == false)

-- Selecting the option runs the action in sky_mechanicjob.
lift.onSelect({ entity = 0 })
assert(ox.triggered[1] == "access_lift")

-- 2. sky_base versions without GetTargetSystem: read from its Sky object.
local old = newClient({
    GetTargetSystem = function() error("No such export GetTargetSystem in resource sky_base") end,
    Get = function() return { Config = { target = "ox" } } end,
})
loadRadialMenu(old)
assert(old.env.Sky.Config.target == "ox")

-- 3. Without a target system in sky_base nothing is added (the radial menu stays the way in).
local none = newClient({ GetTargetSystem = function() return "none" end })
loadRadialMenu(none)
runStartThreads(none)
assert(none.env.Sky.Target.IsEnabled() == false and next(none.added) == nil)

print("PASS: job radial actions (workshop lift, engine hoist) reach ox_target through sky_base's target bridge; unavailable ones are hidden.")
