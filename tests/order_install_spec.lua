-- Run from the workspace root: lua tests/order_install_spec.lua
-- Loads sky_mechanicjob's order install client files with mocked natives and checks which
-- install steps the radial menu (and the ox_target options built from it) offers.

local stub
stub = setmetatable({}, {
    __index = function() return stub end,
    __call = function() return stub end,
})

local vec_mt = {}
local function vec(x, y, z) return setmetatable({ x = x, y = y, z = z }, vec_mt) end
vec_mt.__sub = function(a, b) return vec(a.x - b.x, a.y - b.y, a.z - b.z) end
vec_mt.__len = function(a) return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z) end

local MODULE_GLOBALS = { Config = true, Locales = true, Functions = true, Sky_Jobs = true, CustomTuning = true }

-- A 4.8 m long car at the origin facing +y (front bumper at y = 2.4, rear at y = -2.4).
local VEHICLE, VEHICLE_NET_ID, PED = 9, 109, 1
local f = { coords = { [VEHICLE] = vec(0, 0, 0), [PED] = vec(0, 0, 0) }, bones = {}, exports = {} }

local env = setmetatable({}, { __index = function(_, key)
    local value = _G[key]
    if value ~= nil or MODULE_GLOBALS[key] then return value end
    return stub
end })
env._G = env
env.SkyDiagnostics = false
env.print = function() end
env.CreateThread = function() end
env.GetGameBuildNumber = function() return 3258 end
env.vector3 = vec
env.vec3 = vec
env.Sky = { Config = { locale = "en" }, Cb = { Trigger = function() return nil end } }
env.exports = setmetatable({}, {
    __call = function(_, name, fn) f.exports[name] = fn end,
    __index = function() return stub end,
})
env.PlayerPedId = function() return PED end
env.GetEntityCoords = function(entity) return f.coords[entity] or vec(0, 0, 0) end
env.DoesEntityExist = function(entity) return f.coords[entity] ~= nil end
env.NetworkGetEntityFromNetworkId = function(netId) return netId == VEHICLE_NET_ID and VEHICLE or 0 end
env.GetEntityModel = function() return 1234 end
env.GetModelDimensions = function() return vec(-1.0, -2.4, -0.6), vec(1.0, 2.4, 0.9) end
env.GetOffsetFromEntityInWorldCoords = function(_, x, y, z) return vec(x, y, z) end
env.GetEntityBoneIndexByName = function(_, name) return f.bones[name] and 1 or -1 end
env.GetWorldPositionOfEntityBone = function() return f.bones.position end
env.HasVehicleHood = function() return true end

local function load(path) assert(loadfile(path, "t", env))() end
load("sky_mechanicjob/config/init.lua")
load("sky_mechanicjob/config/config.lua")
load("sky_mechanicjob/config/adv_config.lua")
load("sky_mechanicjob/source/client/state.lua")
load("sky_mechanicjob/source/client/main.lua")
load("sky_mechanicjob/source/client/orders.lua")
load("sky_mechanicjob/source/client/radial_actions.lua")

local getRadialActions = assert(f.exports.getRadialActions, "getRadialActions export missing")

-- The radial actions while installing an order part, standing at x, y.
local function actionsAt(partId, requiredItem, step, x, y)
    local state = env.OrderInstallState
    state.active = true
    state.vehicleNetId = VEHICLE_NET_ID
    state.part = { id = partId, label = partId }
    state.requiredItem = requiredItem
    state.installFlow = ""
    state.simpleStep = step
    f.coords[PED] = vec(x, y, 0.0)

    local ids = {}
    for _, action in ipairs(getRadialActions()) do ids[action.id] = true end
    return ids
end

local FRONT, REAR, SIDE = { 0.0, 3.4 }, { 0.0, -3.4 }, { 2.0, 0.5 }

-- Turbo: open the hood at the front, then install it right there.
local turbo = actionsAt("toggle_18", "turbo", "open_hood", FRONT[1], FRONT[2])
assert(turbo.open_hood and env.resolveSimpleInstallFlow() == "hood_install")
turbo = actionsAt("toggle_18", "turbo", "install", FRONT[1], FRONT[2])
assert(turbo.install_order_part, "the turbo could only be installed from behind the car")

-- Front bumper and headlights are installed next to the car, not only at the rear.
assert(actionsAt("mod_1", "body_kit", "install", FRONT[1], FRONT[2]).install_order_part)
assert(actionsAt("toggle_22", "vehicle_lights", "install", SIDE[1], SIDE[2]).install_order_part)

-- The spoiler keeps its spot above the rear end.
assert(not actionsAt("mod_0", "body_kit", "install", FRONT[1], FRONT[2]).install_order_part)
assert(actionsAt("mod_0", "body_kit", "install", REAR[1], REAR[2]).install_order_part)
f.bones = { spoiler = true, position = vec(0.0, -2.2, 0.9) }
assert(actionsAt("mod_0", "body_kit", "install", REAR[1], REAR[2]).install_order_part)
f.bones = {}

-- Too far from the car: only Cancel Install.
local far = actionsAt("mod_1", "body_kit", "install", 0.0, 8.0)
assert(not far.install_order_part and far.cancel_order_install)

-- Engine swap: open hood, take the hoist, attach it, swap.
assert(actionsAt("mod_11", "engine", "open_hood", FRONT[1], FRONT[2]).open_hood)
assert(env.resolveSimpleInstallFlow() == "engine_swap")
assert(actionsAt("mod_11", "engine", "take_hoist", FRONT[1], FRONT[2]).take_engine_hoist)
assert(actionsAt("mod_11", "engine", "attach_hoist", FRONT[1], FRONT[2]).attach_engine_hoist)
assert(actionsAt("mod_11", "engine", "engine_swap", FRONT[1], FRONT[2]).engine_swap)

print("PASS: order install steps in the radial menu (turbo and bodywork next to the car, spoiler at the rear, engine swap steps).")
