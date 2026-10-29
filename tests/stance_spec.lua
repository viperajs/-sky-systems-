-- Run from the workspace root: lua tests/stance_spec.lua
-- Loads sky_mechanicjob's stance kit with mocked natives: the stance sliders of the tuning menu
-- start at the vehicle's current values, and a step moves the wheels by that step.

local stub
stub = setmetatable({}, {
    __index = function() return stub end,
    __call = function() return stub end,
})

local VEHICLE = 9

local function newClient(savedDefault)
    if savedDefault == nil then savedDefault = { trackFront = 0.8, trackRear = 0.82, wheelSize = 1.0, wheelWidth = 1.0 } end
    local f = { offsets = { [0] = -0.8, [1] = 0.8, [2] = -0.82, [3] = 0.82 }, bag = {}, timeouts = {} }
    -- Constants the stance kit falls back on when they are not set (STANCER_OPTION_BOUNDS, ...).
    local env = setmetatable({}, { __index = function(_, key)
        local value = _G[key]
        if value ~= nil or key:match("^[A-Z_]+$") then return value end
        return stub
    end })
    env._G = env
    env.print = function() end
    env.CreateThread = function() end
    env.Wait = function() end
    env.GetGameTimer = function() return 0 end
    env.Sky = setmetatable({
        Debug = function() end,
        IsDebugActive = function() return false end,
        Math = { Trim = function(s) return (tostring(s):gsub("^%s+", ""):gsub("%s+$", "")) end },
        Cb = { Trigger = function(name)
            if name == "sky_mechanicjob:stance:loadDefault" then
                if savedDefault == false then return { success = false, error = "no_default_saved" } end
                return { success = true, stance = savedDefault }
            end
            return { success = true }
        end },
    }, { __index = function() return stub end })
    env.getNuiLocale = function(_, fallback) return fallback end
    env.sanitizePlate = function(plate) return plate end
    env.Entity = function() return { state = setmetatable({ set = function(_, key, value) f.bag[key] = value end }, { __index = function(_, key) return f.bag[key] end }) } end
    env.DoesEntityExist = function(entity) return entity == VEHICLE end
    env.GetVehicleClass = function() return 0 end
    env.GetVehicleNumberPlateText = function() return "STANCE1" end
    env.GetVehicleWheelXOffset = function(_, idx) return f.offsets[idx] end
    env.SetVehicleWheelXOffset = function(_, idx, value) f.offsets[idx] = value end
    env.GetVehicleWheelSize = function() return 1.0 end
    env.GetVehicleWheelWidth = function() return 1.0 end
    env.GetVehicleSuspensionHeight = function() return 0.0 end
    env.GetVehicleHandlingFloat = function() return 0.0 end
    env.GetVehicleNumberOfWheels = function() return 4 end
    env.NetworkGetEntityIsNetworked = function() return false end
    env.GetNumModKits = function() return 1 end
    env.SetTimeout = function(_, fn) f.timeouts[#f.timeouts + 1] = fn end
    env.AddStateBagChangeHandler = function(key, _, fn) if key == "sky_mechanicjob:stance" then f.onBag = fn end end
    env.GetEntityFromStateBagName = function() return VEHICLE end
    env.STANCER_SCALE = 100
    env.WHEEL_SIZE_SCALE = 100
    assert(loadfile("sky_mechanicjob/source/client/stance_kit.lua", "t", env))()
    f.env = env

    function f.options()
        local opts = {}
        env.StanceKit.AddOptions(VEHICLE, function(_, id, _, value, min, max, _, _, extra)
            opts[id] = { value = value, min = min, max = max, unchangedValue = extra and extra.unchangedValue }
        end)
        return opts
    end
    return f
end

-- 1. A car without a stance of its own: the track width sliders start at its wheels' distance
--    from the centre line (80 and 82 cm), not at 0.
do
    local f = newClient()
    local opts = f.options()
    assert(opts.stancer_track_width_front.value == 80, "front track width starts at " .. tostring(opts.stancer_track_width_front.value))
    assert(opts.stancer_track_width_rear.value == 82, "rear track width starts at " .. tostring(opts.stancer_track_width_rear.value))
    assert(opts.stancer_track_width_front.unchangedValue == 80, "the car's own width is no stance")

    -- One step wider moves the front wheels out by 1 cm (it pulled them into the middle).
    assert(f.env.StanceKit.ApplyOption(VEHICLE, { id = "stancer_track_width_front", scale = 100 }, 81))
    assert(math.abs(f.offsets[0] + 0.81) < 1e-9 and math.abs(f.offsets[1] - 0.81) < 1e-9, "front wheels at 81 cm")
    assert(f.offsets[2] == -0.82 and f.offsets[3] == 0.82, "rear wheels unchanged")
end

-- 2. A stance with its own track width keeps it on the slider.
do
    local f = newClient()
    f.bag["sky_mechanicjob:stance"] = { trackFront = 0.95, enabled = true }
    local opts = f.options()
    assert(opts.stancer_track_width_front.value == 95, "the stance's own front track width")
    assert(opts.stancer_track_width_front.unchangedValue == nil, "a stance's track width is a change")
    assert(opts.stancer_track_width_rear.value == 82, "the current rear track width")
end

-- The wheels' distance from the centre line after a stance reset or a stored stance: never 0,
-- which put the wheels inside the body (the rims vanished when someone got in).
local function assertWheelsAt(f, front, rear, label)
    for _, fn in ipairs(f.timeouts) do fn() end
    f.timeouts = {}
    assert(math.abs(f.offsets[0] + front) < 1e-6 and math.abs(f.offsets[1] - front) < 1e-6, label .. ": front wheels at " .. tostring(f.offsets[1]))
    assert(math.abs(f.offsets[2] + rear) < 1e-6 and math.abs(f.offsets[3] - rear) < 1e-6, label .. ": rear wheels at " .. tostring(f.offsets[3]))
end

-- 3. A stance reset (another player's client raises it) puts the car's own wheels back.
do
    local f = newClient()
    f.env.StanceKit.ApplyPersistedState(VEHICLE, { enabled = true, trackFront = 1.0, trackRear = 1.1 })
    assertWheelsAt(f, 1.0, 1.1, "a wide stance")
    f.onBag("entity:9", "sky_mechanicjob:stance", { enabled = false })
    assertWheelsAt(f, 0.8, 0.82, "reset to the car's own track")
end

-- 4. Without a saved default the reset puts them back as well.
do
    local f = newClient(false)
    f.env.StanceKit.ApplyPersistedState(VEHICLE, { enabled = true, trackFront = 0.9, trackRear = 0.91 })
    assertWheelsAt(f, 0.9, 0.91, "a wide stance")
    f.onBag("entity:9", "sky_mechanicjob:stance", { enabled = false })
    assertWheelsAt(f, 0.8, 0.82, "reset without a default")
end

-- 4b. A saved default that is wrong (a stock copy read too early) does not move the wheels in.
do
    local f = newClient({ trackFrontLeft = -0.3, trackFrontRight = 0.3, trackRearLeft = 0.82, trackRearRight = 0.82 })
    f.env.StanceKit.ApplyPersistedState(VEHICLE, { enabled = true, trackFront = 0.9 })
    f.onBag("entity:9", "sky_mechanicjob:stance", { enabled = false })
    assertWheelsAt(f, 0.8, 0.82, "reset with a wrong saved default")
end

-- 5. A stored stance whose track width is 0 (the old slider started at 0) does not pull the wheels in.
do
    local f = newClient()
    f.env.StanceKit.ApplyPersistedState(VEHICLE, { enabled = true, trackFront = 0.0, trackRear = 0.05, fCamberFront = 0.2 })
    assertWheelsAt(f, 0.8, 0.82, "stance with a zero track width")
    local opts = f.options()
    assert(opts.stancer_track_width_front.min >= 20, "the track width slider still goes down to " .. tostring(opts.stancer_track_width_front.min))
end

-- 6. The rims vanished when someone got in: the stored stance (0.35 / 0.4 m, over the old 0.2 m
--    floor) put the wheels inside the body, leaving only the brake discs in the arches. The
--    wheels stay at the car's own track; the camber still goes on.
do
    local f = newClient()
    local camber
    f.env.SetVehicleHandlingFloat = function(_, _, field, value) if field == "fCamberFront" then camber = value end end
    f.env.StanceKit.ApplyPersistedState(VEHICLE, { enabled = true, trackFront = 0.35, trackRear = 0.4, fCamberFront = 0.3 })
    assertWheelsAt(f, 0.8, 0.82, "a stance narrower than the body")
    assert(camber == 0.3, "the rest of the stance was dropped")
    -- A little narrower than the car is still allowed (up to 15 %).
    f.env.StanceKit.ApplyPersistedState(VEHICLE, { enabled = true, trackFront = 0.7, trackRear = 0.72 })
    assertWheelsAt(f, 0.7, 0.72, "a slightly narrower stance")
end

-- 7. A stance on the wrong side (a negative track width) does not swap the wheels across the car.
do
    local f = newClient()
    f.env.StanceKit.ApplyPersistedState(VEHICLE, { enabled = true, trackFront = -0.9, trackRear = 0.9 })
    assertWheelsAt(f, 0.8, 0.9, "a negative track width")
end

-- 8. The track width sliders stop where the wheels would go into the body (85 % of the car's own).
do
    local f = newClient()
    local opts = f.options()
    assert(opts.stancer_track_width_front.min == 68 and opts.stancer_track_width_rear.min == 70,
        ("the sliders go down to %s / %s"):format(tostring(opts.stancer_track_width_front.min), tostring(opts.stancer_track_width_rear.min)))
end

print("PASS: stance sliders start at the vehicle's current track width (never below 85 % of it), and a step moves the wheels by that step; a stance reset puts the car's own track back; a stored stance never pulls the wheels into the body or across the car (the rims vanished on entry).")
