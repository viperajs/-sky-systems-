if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/lift.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/lift.lua
--  Lift Platform Network Attachment Synchronization
-- =====================================================

RegisterNetEvent("sky_mechanicjob:lift:syncAttachment", function(data)
    local src = source
    if type(data) ~= "table" or type(data.key) ~= "string" then return end

    local action = tostring(data.action or "")
    local vehNetId = tonumber(data.vehicleNetId) or 0

    if action ~= "attach" and action ~= "detach" then return end

    TriggerClientEvent("sky_mechanicjob:lift:attachment", -1, {
        key = data.key,
        action = action,
        vehicleNetId = vehNetId,
        source = src
    })
end)
