-- Run from the workspace root: lua tests/wear_spec.lua
-- Loads sky_mechanicjob's vehicle wear client with mocked natives: worn parts weaken the car the
-- player drives, and a repair gives the force back, on that car only.

local stub
stub = setmetatable({}, {
    __index = function() return stub end,
    __call = function() return stub end,
})

local VEHICLE, PLATE = 9, "WEAR 1"
local OTHER, OTHER_PLATE = 10, "OTHER 1"

local function newClient()
    local function handling() return { fBrakeForce = 1.0, fSuspensionForce = 2.0, fSuspensionReboundDamp = 1.5, fSuspensionCompDamp = 1.2 } end
    local f = { handling = { [VEHICLE] = handling(), [OTHER] = handling() }, maxSpeed = {}, highGear = {}, events = {} }
    local plates = { [VEHICLE] = PLATE, [OTHER] = OTHER_PLATE }
    local env = setmetatable({}, { __index = function(_, key)
        local value = _G[key]
        if value ~= nil then return value end
        return stub
    end })
    env._G = env
    env.print = function() end
    env.CreateThread = function() end
    env.Wait = function() end
    env.GetGameTimer = function() return 0 end
    env.Sky = setmetatable({
        Debug = function() end,
        Math = { Trim = function(s) return (tostring(s):gsub("^%s+", ""):gsub("%s+$", "")) end },
    }, { __index = function() return stub end })
    env.AddEventHandler = function(name, fn) f.events[name] = fn end
    env.DoesEntityExist = function(entity) return plates[entity] ~= nil end
    env.GetVehicleNumberPlateText = function(entity) return plates[entity] end
    env.getClosestVehicleWithPoliceFallback = function() return OTHER end
    env.GetEntityCoords = function() return { x = 0.0, y = 0.0, z = 0.0 } end
    env.GetVehicleHandlingFloat = function(veh, _, field) return f.handling[veh][field] end
    env.SetVehicleHandlingFloat = function(veh, _, field, value) f.handling[veh][field] = value end
    env.SetEntityMaxSpeed = function(veh, speed) f.maxSpeed[veh] = speed end
    env.SetVehicleHighGear = function(veh, gear) f.highGear[veh] = gear end
    env.GetVehicleHighGear = function() return 6 end
    env.GetVehicleEstimatedMaxSpeed = function() return 40.0 end
    env.GetVehicleEngineHealth = function() return 1000.0 end
    env.GetVehicleNumberOfWheels = function() return 4 end
    assert(loadfile("sky_mechanicjob/source/client/wear.lua", "t", env))()
    f.env = env

    -- The player drives VEHICLE: worn brake pads and no transmission fluid (limp mode).
    function f.driveWorn()
        local state = env.WearState
        state.active, state.vehicle, state.plate = true, VEHICLE, PLATE
        state.wear = { brake_pads = 0.0, brake_fluid = 100.0, suspension = 100.0, tyres = 100.0, transmission_fluid = 0.0 }
        env.WearSystem_OnVehicleReady(VEHICLE, PLATE)
        state.transmissionLimpActive, state.transmissionBaseHighGear = true, 6
    end

    function f.repaired(plate, part, fullRepair)
        f.events["sky_mechanicjob:wear:partRepaired"]({
            plate = plate, part = part, fullRepair = fullRepair,
            wear = { brake_pads = 100.0, brake_fluid = 100.0, suspension = 100.0, tyres = 100.0, transmission_fluid = 100.0 },
        })
    end
    return f
end

-- 1. Worn brake pads: the brakes have a fifth of their force. New pads while the player sits in
--    the car give the full force back; it stayed at a fifth (and the next drive took that as
--    the car's own force).
do
    local f = newClient()
    f.driveWorn()
    assert(math.abs(f.handling[VEHICLE].fBrakeForce - 0.2) < 1e-9, "worn pads: a fifth of the force")
    f.repaired(PLATE, "brake_pads")
    assert(math.abs(f.handling[VEHICLE].fBrakeForce - 1.0) < 1e-9, "new pads: full force, not " .. f.handling[VEHICLE].fBrakeForce)
end

-- 2. New transmission fluid ends the limp mode: the gears come back and the speed cap is lifted.
--    It was set to the estimated top speed, which leaves out the mods: a tuned car stayed slower.
do
    local f = newClient()
    f.driveWorn()
    f.repaired(PLATE, "transmission_fluid")
    assert(f.highGear[VEHICLE] == 6, "gears back")
    assert(f.maxSpeed[VEHICLE] and f.maxSpeed[VEHICLE] > 100.0, "speed cap lifted, not " .. tostring(f.maxSpeed[VEHICLE]))
    assert(f.env.WearState.transmissionLimpActive == false)
end

-- 3. Every client hears a full repair. Next to the repaired car, a player driving their own worn
--    car keeps its limp mode and weak brakes, and the repaired car does not get that car's
--    brakes and gears (the repair reset the player's own car).
do
    local f = newClient()
    f.driveWorn()
    f.repaired(OTHER_PLATE, "admin_full_repair", true)
    local state = f.env.WearState
    assert(state.transmissionLimpActive == true, "own car still in limp mode")
    assert(state.appliedBands.brake_pads == 0 and math.abs(f.handling[VEHICLE].fBrakeForce - 0.2) < 1e-9, "own car's brakes still weak")
    assert(f.handling[OTHER].fBrakeForce == 1.0 and f.highGear[OTHER] == nil and f.maxSpeed[OTHER] == nil, "the repaired car got nothing of the own car")
end

print("PASS: worn brake pads weaken the brakes and new pads give their full force back, the limp mode's speed cap lifted after a repair, a full repair of another car leaves the own car alone.")
