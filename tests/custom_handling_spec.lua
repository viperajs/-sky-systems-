-- Run from the workspace root: lua tests/custom_handling_spec.lua
-- Loads sky_mechanicjob's custom handling (drivetrain swap, engine upgrade presets) with the real
-- config and mocked natives: the presets go on a vehicle once, and again when it streams back in.

local stub
stub = setmetatable({}, {
    __index = function() return stub end,
    __call = function() return stub end,
})

local NET_ID = 109

local function newClient()
    local f = { handling = {}, netIds = {} }
    local env = setmetatable({}, { __index = function(_, key)
        local value = _G[key]
        if value ~= nil then return value end
        return stub
    end })
    env._G = env
    env.print = function() end
    env.Sky = setmetatable({ Debug = function() end, IsDebugActive = function() return false end }, { __index = function() return stub end })
    for _, file in ipairs({ "config/init.lua", "config/config.lua", "config/adv_config.lua" }) do
        assert(loadfile("sky_mechanicjob/" .. file, "t", env))()
    end
    env.customHandlingConfig = env.Config.CustomHandlingOptions
    env.TuningState = {}
    env.DoesEntityExist = function(entity) return f.handling[entity] ~= nil end
    env.NetworkGetNetworkIdFromEntity = function(entity) return f.netIds[entity] or 0 end
    env.GetEntityModel = function() return 1234 end
    env.GetVehicleNumberPlateText = function() return "CUSTOM 1" end
    env.GetVehicleHandlingFloat = function(entity, _, field) return f.handling[entity][field] or 0.0 end
    env.GetVehicleHandlingInt = function(entity, _, field) return f.handling[entity][field] or 0 end
    env.SetVehicleHandlingFloat = function(entity, _, field, value) f.handling[entity][field] = value end
    env.SetVehicleHandlingInt = function(entity, _, field, value) f.handling[entity][field] = value end
    env.ModifyVehicleTopSpeed = function() end
    assert(loadfile("sky_mechanicjob/source/client/custom_tuning.lua", "t", env))()
    f.env = env

    -- The vehicle as this client spawns it: the model's own handling, rear-wheel drive.
    function f.spawn(entity)
        f.handling[entity] = { fDriveBiasFront = 0.0, fInitialDriveForce = 0.3 }
        f.netIds[entity] = NET_ID
    end
    return f
end

-- AWD and the ECU remap (drive force x1.08).
local PROFILES = { profiles = { drivetrain = 3, engine_upgrade = 1 } }

-- 1. The presets go on once: entering again does not stack the engine upgrade.
do
    local f = newClient()
    f.spawn(9)
    assert(f.env.CustomTuning.ApplyPersistedState(9, PROFILES, false))
    assert(f.handling[9].fDriveBiasFront == 0.5, "all-wheel drive")
    assert(math.abs(f.handling[9].fInitialDriveForce - 0.324) < 1e-9, "engine upgrade on")
    assert(f.env.CustomTuning.ApplyPersistedState(9, PROFILES, false))
    assert(math.abs(f.handling[9].fInitialDriveForce - 0.324) < 1e-9, "not stacked")
end

-- 2. The vehicle streams out and back in: a new entity with the model's handling and the same
--    network id. Its presets go on again; they were skipped as applied.
do
    local f = newClient()
    f.spawn(9)
    assert(f.env.CustomTuning.ApplyPersistedState(9, PROFILES, false))
    f.handling[9], f.netIds[9] = nil, nil
    f.spawn(19)
    assert(f.env.CustomTuning.ApplyPersistedState(19, PROFILES, false))
    assert(f.handling[19].fDriveBiasFront == 0.5, "all-wheel drive again")
    assert(math.abs(f.handling[19].fInitialDriveForce - 0.324) < 1e-9, "engine upgrade again, from the model's force")
end

print("PASS: custom handling presets go on once per vehicle, and again when it streams back in.")
