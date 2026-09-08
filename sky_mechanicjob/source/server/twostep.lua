if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/twostep.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/twostep.lua
--  Two-Step Launch Control & Flame Burst Synchronization
-- =====================================================

RegisterNetEvent("sky_mechanicjob:twostep:syncBurst", function(netId, payload)
    local vehicleNetId = tonumber(netId) or 0
    if vehicleNetId <= 0 or type(payload) ~= "table" then return end

    TriggerClientEvent("sky_mechanicjob:twostep:burst", -1, vehicleNetId, payload)
end)
