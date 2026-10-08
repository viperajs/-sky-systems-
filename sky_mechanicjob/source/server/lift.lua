if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/lift.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/lift.lua
--  Lift Platform Network Attachment Synchronization
-- =====================================================

local RELAY_INTERVAL_MS = 200
-- The operator stands next to the lift, not in the car.
local RELAY_VEHICLE_DISTANCE = 15.0

local lastRelayAt = {}

RegisterNetEvent("sky_mechanicjob:lift:syncAttachment", function(data)
    local src = tonumber(source)
    if not src then return end
    if type(data) ~= "table" or type(data.key) ~= "string" or #data.key > 128 or data.key:sub(1, 5) ~= "lift:" then return end

    local action = data.action
    if action ~= "attach" and action ~= "detach" then return end

    local now = GetGameTimer()
    if lastRelayAt[src] and now - lastRelayAt[src] < RELAY_INTERVAL_MS then return end
    lastRelayAt[src] = now

    local vehNetId = math.floor(tonumber(data.vehicleNetId) or 0)
    if not (vehNetId > 0 and vehNetId <= 65535) then return end
    if not Functions.IsMechanic(src) then return end
    if not (Functions.GetVehicleByNetId and Functions.GetVehicleByNetId(src, vehNetId, RELAY_VEHICLE_DISTANCE)) then return end

    TriggerClientEvent("sky_mechanicjob:lift:attachment", -1, {
        key = data.key,
        action = action,
        vehicleNetId = vehNetId,
        source = src
    })
end)

AddEventHandler("playerDropped", function()
    local src = tonumber(source)
    if src then lastRelayAt[src] = nil end
end)
