if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/antilag.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/antilag.lua
--  Anti-Lag Backfire Network Synchronization
-- =====================================================

RegisterNetEvent("sky_mechanicjob:antilag:syncBurst", function(netId, payload)
    local vehicleNetId = tonumber(netId) or 0
    if vehicleNetId <= 0 or type(payload) ~= "table" then return end

    TriggerClientEvent("sky_mechanicjob:antilag:burst", -1, vehicleNetId, payload)
end)
