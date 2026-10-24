-- =====================================================
--  sky_mechanicjob · source/server/lift.lua
--  Lift Platform Network Attachment Synchronization
-- =====================================================

local RELAY_INTERVAL_MS = 200
-- The operator stands next to the lift, not in the car.
local RELAY_VEHICLE_DISTANCE = 15.0

local lastRelayAt = {}
local pendingRelay = {}

local function relay(src, payload)
    lastRelayAt[src] = GetGameTimer()
    TriggerClientEvent("sky_mechanicjob:lift:attachment", -1, payload)
end

-- Within the interval the latest state of each lift goes out when it ends. Dropped messages
-- left other players with a state the operator had already left: the platform resting on
-- the floor while the car went up.
local function queueRelay(src, payload, delayMs)
    local queued = pendingRelay[src]
    if queued then
        queued[payload.key] = payload
        return
    end

    pendingRelay[src] = { [payload.key] = payload }
    SetTimeout(math.max(0, delayMs), function()
        local batch = pendingRelay[src]
        pendingRelay[src] = nil
        if not batch or not GetPlayerName(src) then return end
        for _, queuedPayload in pairs(batch) do
            relay(src, queuedPayload)
        end
    end)
end

RegisterNetEvent("sky_mechanicjob:lift:syncAttachment", function(data)
    local src = tonumber(source)
    if not src then return end
    if type(data) ~= "table" or type(data.key) ~= "string" or #data.key > 128 or data.key:sub(1, 5) ~= "lift:" then return end

    local action = data.action
    if action ~= "attach" and action ~= "detach" then return end

    local vehNetId = math.floor(tonumber(data.vehicleNetId) or 0)
    if not (vehNetId > 0 and vehNetId <= 65535) then return end
    if not Functions.IsMechanic(src) then return end
    if not (Functions.GetVehicleByNetId and Functions.GetVehicleByNetId(src, vehNetId, RELAY_VEHICLE_DISTANCE)) then return end

    local payload = {
        key = data.key,
        action = action,
        vehicleNetId = vehNetId,
        source = src
    }

    -- Queued while one is waiting too, so an older state never goes out after a newer one.
    local sinceLast = lastRelayAt[src] and (GetGameTimer() - lastRelayAt[src]) or nil
    if pendingRelay[src] or (sinceLast and sinceLast < RELAY_INTERVAL_MS) then
        queueRelay(src, payload, RELAY_INTERVAL_MS - (sinceLast or 0))
        return
    end

    relay(src, payload)
end)

AddEventHandler("playerDropped", function()
    local src = tonumber(source)
    if src then
        lastRelayAt[src] = nil
        pendingRelay[src] = nil
    end
end)
