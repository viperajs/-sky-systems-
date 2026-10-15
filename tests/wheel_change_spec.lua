-- Run from the workspace root: lua tests/wheel_change_spec.lua
-- Drives the wheel change through sky_mechanicjob's real client files (radial actions, car jack,
-- detach/attach, diagnostics repair, order install) with mocked natives: new tyres or rims go
-- on every wheel of the vehicle before the job counts.

local stub
stub = setmetatable({}, {
    __index = function() return stub end,
    __call = function() return stub end,
})

local vec_mt = {}
local function vec(x, y, z) return setmetatable({ x = x, y = y, z = z }, vec_mt) end
vec_mt.__sub = function(a, b) return vec(a.x - b.x, a.y - b.y, a.z - b.z) end
vec_mt.__add = function(a, b) return vec(a.x + b.x, a.y + b.y, a.z + b.z) end
vec_mt.__len = function(a) return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z) end

local MODULE_GLOBALS = {
    Config = true, Locales = true, Functions = true, Sky_Jobs = true, CustomTuning = true,
    OrderInstallState = true, WheelOrderInstallState = true, OrderTabletState = true,
}

local CAR_BONES = {
    wheel_lf = vec(-0.9, 1.4, 0.3), wheel_rf = vec(0.9, 1.4, 0.3),
    wheel_lr = vec(-0.9, -1.4, 0.3), wheel_rr = vec(0.9, -1.4, 0.3),
}
local BIKE_BONES = { wheel_lf = vec(0.0, 1.0, 0.3), wheel_lr = vec(0.0, -1.0, 0.3) }

local VEHICLE, VEHICLE_NET_ID, PED = 9, 109, 1
local STATE_BAG_KEY = "sky_mechanic_wheel_damage"

-- One client with a vehicle at the origin facing +y.
local function newClient(bones, wheelCount)
    local f = {
        bones = bones, boneNames = {}, coords = { [VEHICLE] = vec(0, 0, 0), [PED] = vec(-1.6, 0, 0) },
        exports = {}, nuiCallbacks = {}, off = {}, burst = {}, stateBag = {}, notes = {}, checklists = {},
        calls = {}, applied = 0, applyFailures = 0, nextObject = 500,
        orderPart = { id = "mod_23", label = "Rims", value = 7, requiredItem = "wheels" },
    }
    local i = 0
    for name in pairs(bones) do i = i + 1; f.boneNames[i] = name; f.boneNames[name] = i end

    local env = setmetatable({}, { __index = function(_, key)
        local value = _G[key]
        if value ~= nil or MODULE_GLOBALS[key] then return value end
        return stub
    end })
    env._G = env
    env.SkyDiagnostics = false
    env.print = function() end
    env.CreateThread = function() end
    env.Wait = function() end
    env.Citizen = { CreateThread = env.CreateThread, Wait = env.Wait }
    env.GetGameTimer = function() return 0 end
    env.GetGameBuildNumber = function() return 3258 end
    env.vector3 = vec
    env.vec3 = vec
    env.json = { encode = function() return "[]" end, decode = function() return {} end }
    env.Sky = { Config = { locale = "en" }, Math = { Trim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end }, Cb = { Trigger = function(name, payload)
        f.calls[#f.calls + 1] = { name = name, payload = payload }
        if name == "sky_mechanicjob:wear:prepareRepairInstall" then
            return { success = true, data = { part = payload.part, requiredItem = "wheels", removeRequiredItemAfterUse = true, flow = "wheel" } }
        elseif name == "sky_mechanicjob:orders:prepareInstall" then
            return { success = true, data = { part = f.orderPart, requiredItem = "wheels", removeRequiredItemAfterUse = true } }
        end
        return { success = true, data = {} }
    end } }
    setmetatable(env.Sky, { __index = function() return stub end })
    env.exports = setmetatable({}, {
        __call = function(_, name, fn) f.exports[name] = fn end,
        __index = function() return stub end,
    })
    env.RegisterNUICallback = function(name, fn) f.nuiCallbacks[name] = fn end
    env.Entity = function() return { state = f.stateBag } end

    -- Natives
    env.PlayerPedId = function() return PED end
    env.GetEntityCoords = function(entity) return f.coords[entity] or vec(0, 0, 0) end
    env.DoesEntityExist = function(entity) return entity == PED or entity == VEHICLE or (entity or 0) >= 500 end
    env.IsEntityAVehicle = function(entity) return entity == VEHICLE end
    env.NetworkDoesNetworkIdExist = function(netId) return netId == VEHICLE_NET_ID end
    env.NetworkGetEntityFromNetworkId = function(netId) return netId == VEHICLE_NET_ID and VEHICLE or 0 end
    env.NetworkGetNetworkIdFromEntity = function(entity) return entity == VEHICLE and VEHICLE_NET_ID or 0 end
    env.NetworkHasControlOfEntity = function() return true end
    env.GetClosestVehicle = function() return VEHICLE end
    env.GetVehicleNumberPlateText = function() return "TESTCAR" end
    env.GetVehicleNumberOfWheels = function() return wheelCount end
    env.GetIsVehicleElectric = function() return false end
    env.GetEntityModel = function() return 1234 end
    env.GetModelDimensions = function() return vec(-1.0, -2.4, -0.6), vec(1.0, 2.4, 0.9) end
    env.GetOffsetFromEntityInWorldCoords = function(_, x, y, z) return vec(x, y, z) end
    env.GetOffsetFromEntityGivenWorldCoords = function(_, x, y, z) return vec(x, y, z) end
    env.GetEntityRotation = function() return vec(0, 0, 0) end
    env.GetEntityHeading = function() return 0.0 end
    env.GetEntityBoneIndexByName = function(_, name) return f.boneNames[name] or -1 end
    env.GetWorldPositionOfEntityBone = function(_, index) return f.bones[f.boneNames[index]] end
    env.GetHashKey = function(s) local h = 7 for c in tostring(s):gmatch(".") do h = (h * 31 + c:byte()) % 2147483647 end return h end
    env.IsModelInCdimage = function() return true end
    env.HasModelLoaded = function() return true end
    env.HasAnimDictLoaded = function() return true end
    env.CreateObjectNoOffset = function() f.nextObject = f.nextObject + 1 return f.nextObject end
    env.GetVehicleBodyHealth = function() return 1000.0 end
    env.GetVehicleEngineHealth = function() return 1000.0 end
    env.GetVehiclePetrolTankHealth = function() return 1000.0 end
    env.GetVehicleDirtLevel = function() return 0.0 end
    -- Wheels: SetVehicleFixed puts every wheel back and fixes every tyre, as in game.
    env.BreakOffVehicleWheel = function(_, idx) f.off[idx] = true end
    env.SetVehicleFixed = function() f.off, f.burst = {}, {} end
    env.SetVehicleTyreFixed = function(_, idx) f.burst[idx] = nil end
    env.SetVehicleTyreBurst = function(_, idx) f.burst[idx] = true end
    env.IsVehicleTyreBurst = function(_, idx) return f.burst[idx] == true end

    local function load(path) assert(loadfile(path, "t", env))() end
    load("sky_mechanicjob/config/init.lua")
    load("sky_mechanicjob/config/config.lua")
    load("sky_mechanicjob/config/adv_config.lua")
    load("sky_mechanicjob/config/locales/en.lua")
    load("sky_mechanicjob/source/client/state.lua")
    load("sky_mechanicjob/source/client/main.lua")
    load("sky_mechanicjob/source/client/tuning_minigames.lua")
    load("sky_mechanicjob/source/client/tuning.lua")
    load("sky_mechanicjob/source/client/radial_actions.lua")
    load("sky_mechanicjob/source/client/orders.lua")
    load("sky_mechanicjob/source/client/wear.lua")
    load("sky_mechanicjob/source/client/wheel_damage.lua")
    load("sky_mechanicjob/source/client/wheel_change.lua")

    -- The bolt minigames, the part's mods and saving are not under test.
    env.runTuningMinigame = function() return true end
    env.applyOrderPartToVehicle = function()
        if f.applyFailures > 0 then f.applyFailures = f.applyFailures - 1 return false end
        f.applied = f.applied + 1
        return true
    end
    env.saveTuningForVehicle = function() end
    env.notify = function(message) f.notes[#f.notes + 1] = tostring(message) end
    env.sendUi = function(action, payload)
        if action == "wheelInstall:checklist:update" then f.checklists[#f.checklists + 1] = payload end
    end

    f.env = env
    env.OrderTabletState.connectedVehicleNetId = VEHICLE_NET_ID

    function f.standAt(boneName)
        local bone = f.bones[boneName]
        local side = bone.x < 0 and -0.6 or (bone.x > 0 and 0.6 or -0.6)
        f.coords[PED] = vec(bone.x + side, bone.y, 0.0)
    end

    function f.actions()
        local ids = {}
        for _, action in ipairs(f.exports.getRadialActions()) do ids[action.id] = true end
        return ids
    end

    function f.act(id)
        assert(f.actions()[id], ("radial menu offers no %s"):format(id))
        local ok, err = f.exports.triggerRadialMenuAction(id)
        assert(ok, ("%s failed: %s"):format(id, type(err) == "table" and tostring(err.fallback) or tostring(err)))
    end

    function f.completions(name)
        local n = 0
        for _, call in ipairs(f.calls) do if call.name == name then n = n + 1 end end
        return n
    end

    function f.nui(name, payload)
        local reply
        assert(f.nuiCallbacks[name], "no NUI callback " .. name)
        f.nuiCallbacks[name](payload, function(res) reply = res end)
        return reply
    end
    return f
end

local REPAIR_DONE = "sky_mechanicjob:wear:completeRepairInstall"
local ORDER_DONE = "sky_mechanicjob:orders:completeInstall"

-- 1. New tyres from the diagnostics tablet: every wheel is taken off and gets a new one; one
-- wheel no longer counts for all four.
do
    local f = newClient(CAR_BONES, 4)
    local started = f.nui("wear:repairPart", { plate = "TESTCAR", part = "tyres" })
    assert(started and started.success, "tyre repair started")
    local state = f.env.WheelOrderInstallState
    assert(state.allWheels == true and #state.wheels == 4, "every wheel of the car is part of the job")

    local list = f.checklists[#f.checklists]
    assert(#list.steps == 6 and list.steps[2].label == "Front left wheel", "checklist lists each wheel")

    f.standAt("wheel_lf")
    f.act("car_jack")

    f.act("detach_wheel")
    assert(f.off[0], "front left wheel taken off")
    f.act("attach_wheel")
    assert(not f.off[0], "new front left wheel on")
    assert(f.notes[#f.notes] == "New wheel attached. (1/4)", f.notes[#f.notes])

    -- The job is not done after one wheel.
    assert(not f.actions().remove_car_jack and f.completions(REPAIR_DONE) == 0, "one wheel finished the tyre job")
    local ok, err = f.exports.triggerRadialMenuAction("remove_car_jack")
    assert(not ok and err, "the jack could be removed after one wheel")

    -- A replaced wheel cannot be done twice.
    assert(not f.actions().detach_wheel, "replaced wheel offered again")
    ok, err = f.exports.triggerRadialMenuAction("detach_wheel")
    assert(not ok and err.fallback:find("already new", 1, true), tostring(err and err.fallback))

    for _, bone in ipairs({ "wheel_rf", "wheel_lr", "wheel_rr" }) do
        f.standAt(bone)
        f.act("detach_wheel")
        f.act("attach_wheel")
    end
    assert(f.notes[#f.notes] == "New wheel attached. (4/4)")
    list = f.checklists[#f.checklists]
    for i = 2, 5 do assert(list.steps[i].done, "wheel " .. i .. " ticked") end

    f.act("remove_car_jack")
    assert(f.completions(REPAIR_DONE) == 1, "tyres repaired once, after every wheel")
    assert(f.env.WheelOrderInstallState.active == false)
end

-- 2. A wheel already missing (wheel damage) only needs the new one; a burst tyre still to do
-- stays burst while the others are changed (attaching repairs the whole vehicle).
do
    local f = newClient(CAR_BONES, 4)
    f.stateBag[STATE_BAG_KEY] = { wheels = { ["1"] = { damage = 100, detached = true } } }
    f.off[1] = true
    f.burst[5] = true
    assert(f.nui("wear:repairPart", { plate = "TESTCAR", part = "tyres" }).success)

    f.standAt("wheel_lf")
    f.act("car_jack")
    f.act("detach_wheel")
    f.act("attach_wheel")
    assert(f.off[1] and f.burst[5], "other wheels got repaired with the first one")

    f.standAt("wheel_rf")
    assert(not f.actions().detach_wheel and f.actions().attach_wheel, "missing wheel: put the new one on")
    f.act("attach_wheel")
    assert(not f.off[1] and f.burst[5])

    f.standAt("wheel_rr")
    f.act("detach_wheel")
    f.act("attach_wheel")
    assert(not f.burst[5])
    f.standAt("wheel_lr")
    f.act("detach_wheel")
    -- The new wheel goes where the old one came off.
    f.standAt("wheel_lf")
    assert(not f.actions().attach_wheel, "attach offered at another wheel")
    f.standAt("wheel_lr")
    f.act("attach_wheel")
    f.act("remove_car_jack")
    assert(f.completions(REPAIR_DONE) == 1)
end

-- 3. New rims from an order: every wheel, and the rims show after the last one. When putting
-- them on fails, the last wheel can be attached again.
do
    local f = newClient(CAR_BONES, 4)
    local started = f.nui("orders:startInstall", { orderId = 5, partIndex = 1, vehicleNetId = VEHICLE_NET_ID })
    assert(started and started.success, "order install started")
    assert(f.env.WheelOrderInstallState.allWheels and #f.env.WheelOrderInstallState.wheels == 4)

    f.standAt("wheel_lf")
    f.act("car_jack")
    for _, bone in ipairs({ "wheel_lf", "wheel_rf", "wheel_lr" }) do
        f.standAt(bone)
        f.act("detach_wheel")
        f.act("attach_wheel")
        assert(f.applied == 0, "new rims showed before every wheel was on")
    end
    f.standAt("wheel_rr")
    f.act("detach_wheel")
    f.applyFailures = 1
    local ok = f.exports.triggerRadialMenuAction("attach_wheel")
    assert(not ok and not f.actions().remove_car_jack, "rims failed to go on but the job moved on")
    f.act("attach_wheel")
    assert(f.applied == 1, "new rims shown once every wheel is on")
    f.act("remove_car_jack")
    assert(f.completions(ORDER_DONE) == 1)
end

-- 4. New tyres on a motorcycle: its front and its rear wheel.
do
    local f = newClient(BIKE_BONES, 2)
    assert(f.nui("wear:repairPart", { plate = "TESTCAR", part = "tyres" }).success)
    local state = f.env.WheelOrderInstallState
    assert(state.allWheels and #state.wheels == 2, "a motorcycle has two wheels")
    local steps = f.checklists[#f.checklists].steps
    assert(steps[2].label == "Front wheel" and steps[3].label == "Rear wheel")

    f.standAt("wheel_lf")
    f.act("car_jack")
    f.act("detach_wheel")
    f.act("attach_wheel")
    assert(not f.actions().remove_car_jack)
    f.standAt("wheel_lr")
    f.act("detach_wheel")
    f.act("attach_wheel")
    f.act("remove_car_jack")
    assert(f.completions(REPAIR_DONE) == 1)
end

-- 5. A motorcycle's rear rim is its own part: only the rear wheel is changed.
do
    local f = newClient(BIKE_BONES, 2)
    f.orderPart = { id = "mod_24", label = "Rear Rim", value = 3, requiredItem = "wheels" }
    assert(f.nui("orders:startInstall", { orderId = 6, partIndex = 1, vehicleNetId = VEHICLE_NET_ID }).success)
    local state = f.env.WheelOrderInstallState
    assert(state.allWheels and #state.wheels == 1 and state.wheels[1].label == "rear", "rear rim: rear wheel only")

    f.standAt("wheel_lf")
    f.act("car_jack")
    assert(not f.actions().detach_wheel, "front wheel offered for a rear rim")
    local ok, err = f.exports.triggerRadialMenuAction("detach_wheel")
    assert(not ok and err.fallback == "This wheel is not part of this job.", tostring(err and err.fallback))
    f.standAt("wheel_lr")
    f.act("detach_wheel")
    f.act("attach_wheel")
    assert(f.applied == 1)
    f.act("remove_car_jack")
    assert(f.completions(ORDER_DONE) == 1)
end

-- 6. Brake parts still open one wheel.
do
    local f = newClient(CAR_BONES, 4)
    assert(f.nui("wear:repairPart", { plate = "TESTCAR", part = "brake_pads" }).success)
    assert(not f.env.WheelOrderInstallState.allWheels)
    f.standAt("wheel_lf")
    f.act("car_jack")
    f.act("detach_wheel")
    f.act("install_brakes")
    f.act("attach_wheel")
    f.act("remove_car_jack")
    assert(f.completions(REPAIR_DONE) == 1)
end

print("PASS: tyre and wheel jobs replace every wheel (car, motorcycle, missing wheel, burst tyre kept until its turn), rims after the last wheel (retry when they fail), a motorcycle rim on its own wheel, brakes still one wheel.")
