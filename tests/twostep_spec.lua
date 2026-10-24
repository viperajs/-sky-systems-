-- Run from the workspace root: lua tests/twostep_spec.lua
-- Loads sky_mechanicjob's two-step launch control with its real config and mocked natives: the
-- driver holding the car on the rev limiter sees the flames and hears the pops.

local stub
stub = setmetatable({}, {
    __index = function() return stub end,
    __call = function() return stub end,
})

local VEHICLE, PED = 9, 1

local f = { explosions = 0, flames = 0 }
local env = setmetatable({}, { __index = function(_, key)
    local value = _G[key]
    if value ~= nil then return value end
    return stub
end })
env._G = env
env.print = function() end
env.CreateThread = function() end
env.Wait = function() end
env.Sky = setmetatable({ Debug = function() end }, { __index = function() return stub end })
for _, file in ipairs({ "config/init.lua", "config/config.lua", "config/adv_config.lua" }) do
    assert(loadfile("sky_mechanicjob/" .. file, "t", env))()
end
env.DoesEntityExist = function(entity) return entity == VEHICLE end
env.PlayerPedId = function() return PED end
env.GetPedInVehicleSeat = function() return PED end
env.HasNamedPtfxAssetLoaded = function() return true end
env.GetEntityCoords = function() return { x = 0.0, y = 0.0, z = 0.0 } end
env.AddExplosion = function() f.explosions = f.explosions + 1 end
env.VehicleEffects = { PlayBackfire = function() f.flames = f.flames + 1 return true end }
assert(loadfile("sky_mechanicjob/source/client/twostep.lua", "t", env))()

local state = {
    engineRunning = true, throttlePressed = true, brakePressed = true, handbrakePressed = true,
    gear = 1, speedKmh = 0.0, rpm = 1.0,
}
env.IsControlPressed = function() return true end
env.TwoStep.TickVehicle(VEHICLE, 100000, state, "TWOSTEP", { installed = true, enabled = true, volumeLevel = 5, flameScaleLevel = 5 })
assert(f.flames >= 1, "flames on the limiter")
assert(f.explosions >= 1, "the driver hears the pop")

print("PASS: the two-step driver sees the flames and hears the pops on the rev limiter.")
