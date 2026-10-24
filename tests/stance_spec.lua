-- Run from the workspace root: lua tests/stance_spec.lua
-- Loads sky_mechanicjob's stance kit with mocked natives: the stance sliders of the tuning menu
-- start at the vehicle's current values, and a step moves the wheels by that step.

local stub
stub = setmetatable({}, {
    __index = function() return stub end,
    __call = function() return stub end,
})

local VEHICLE = 9

local function newClient()
    local f = { offsets = { [0] = -0.8, [1] = 0.8, [2] = -0.82, [3] = 0.82 }, bag = {} }
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
                return { success = true, stance = { trackFront = 0.8, trackRear = 0.82, wheelSize = 1.0, wheelWidth = 1.0 } }
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

print("PASS: stance sliders start at the vehicle's current track width, and a step moves the wheels by that step.")
