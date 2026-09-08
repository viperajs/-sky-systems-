if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/wheel_damage.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/wheel_damage.lua
--  Wheel Damage State Bag & Physical Tyre Sync
-- =====================================================

local STATE_BAG_KEY = "sky_mechanic_wheel_damage"

RegisterNetEvent("sky_mechanicjob:wheelDamage:reset", function(netId)
    local vehicleNetId = tonumber(netId) or 0
    if vehicleNetId <= 0 then return end

    local entity = NetworkGetEntityFromNetworkId(vehicleNetId)
    if entity and entity ~= 0 and DoesEntityExist(entity) then
        Entity(entity).state:set(STATE_BAG_KEY, nil, true)
    end
end)

RegisterNetEvent("sky_mechanicjob:wheelDamage:update", function(netId, updates)
    local vehicleNetId = tonumber(netId) or 0
    if vehicleNetId <= 0 or type(updates) ~= "table" then return end

    local entity = NetworkGetEntityFromNetworkId(vehicleNetId)
    if entity and entity ~= 0 and DoesEntityExist(entity) then
        local current = Entity(entity).state[STATE_BAG_KEY]
        local currentWheels = (type(current) == "table" and type(current.wheels) == "table") and current.wheels or {}

        for k, v in pairs(updates) do
            currentWheels[tostring(k)] = v
        end

        local detachedCount = 0
        for _, entry in pairs(currentWheels) do
            if type(entry) == "table" and entry.detached == true then
                detachedCount = detachedCount + 1
            end
        end

        Entity(entity).state:set(STATE_BAG_KEY, {
            wheels = currentWheels,
            allWheelsMissing = (detachedCount >= 4)
        }, true)
    end
end)
