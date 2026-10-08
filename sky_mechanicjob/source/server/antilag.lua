if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/antilag.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/antilag.lua
--  Anti-Lag Backfire Network Synchronization
-- =====================================================

local RELAY_DISTANCE = 150.0
local MIN_RELAY_INTERVAL_MS = 100

local lastRelayAtByEvent = {}

local function clampNumber(value, minVal, maxVal, default)
    local num = tonumber(value)
    if not num or num ~= num then return default end
    return math.max(minVal, math.min(maxVal, num))
end

--- Forwards a backfire burst from the vehicle's driver to the other players near the vehicle.
--- Shared with twostep.lua.
---@param src number|string sender
---@param netId number vehicle network id
---@param payload table client payload; only the clamped numeric fields are forwarded
---@param clientEvent string client event to trigger
function RelayVehicleBurst(src, netId, payload, clientEvent)
    src = tonumber(src)
    local vehicleNetId = math.floor(tonumber(netId) or 0)
    if not src or src <= 0 or vehicleNetId <= 0 then return end

    local lastRelayAt = lastRelayAtByEvent[clientEvent]
    if not lastRelayAt then
        lastRelayAt = {}
        lastRelayAtByEvent[clientEvent] = lastRelayAt
    end

    local now = GetGameTimer()
    if now - (lastRelayAt[src] or 0) < MIN_RELAY_INTERVAL_MS then return end

    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if vehicle == 0 or not DoesEntityExist(vehicle) or GetEntityType(vehicle) ~= 2 then return end
    if GetPedInVehicleSeat(vehicle, -1) ~= GetPlayerPed(src) then return end

    lastRelayAt[src] = now

    local data = type(payload) == "table" and payload or {}
    local record = type(data.record) == "table" and data.record or {}
    local burst = {
        source = src,
        intensity = clampNumber(data.intensity, 0.35, 1.0, 1.0),
        record = {
            volumeLevel = math.floor(clampNumber(record.volumeLevel, 0, 10, 5)),
            flameScaleLevel = math.floor(clampNumber(record.flameScaleLevel, 1, 10, 10))
        }
    }

    local origin = GetEntityCoords(vehicle)
    for _, playerId in ipairs(GetPlayers()) do
        local target = tonumber(playerId)
        if target and target ~= src then
            local targetPed = GetPlayerPed(target)
            if targetPed ~= 0 and #(GetEntityCoords(targetPed) - origin) <= RELAY_DISTANCE then
                TriggerClientEvent(clientEvent, target, vehicleNetId, burst)
            end
        end
    end
end

RegisterNetEvent("sky_mechanicjob:antilag:syncBurst", function(netId, payload)
    RelayVehicleBurst(source, netId, payload, "sky_mechanicjob:antilag:burst")
end)

AddEventHandler("playerDropped", function()
    local src = tonumber(source)
    if not src then return end
    for _, lastRelayAt in pairs(lastRelayAtByEvent) do
        lastRelayAt[src] = nil
    end
end)
