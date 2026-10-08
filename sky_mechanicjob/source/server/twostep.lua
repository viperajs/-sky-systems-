if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/twostep.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/twostep.lua
--  Two-Step Launch Control & Flame Burst Synchronization
-- =====================================================

-- RelayVehicleBurst (antilag.lua) rate-limits, checks the driver and only reaches nearby players.
RegisterNetEvent("sky_mechanicjob:twostep:syncBurst", function(netId, payload)
    RelayVehicleBurst(source, netId, payload, "sky_mechanicjob:twostep:burst")
end)
