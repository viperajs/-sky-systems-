if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/wheel_theft.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/wheel_theft.lua
--  Wheel Theft RPCs & State Bag Synchronization
-- =====================================================

local STATE_BAG_KEY = "sky_mechanic_wheel_damage"

-- ── Prepare Wheel Steal Callback ─────────────────────

Sky.Cb.Register("sky_mechanicjob:wheelTheft:prepareSteal", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local netId = tonumber(data and data.vehicleNetId) or 0
    local wheelIndexes = type(data and data.wheelIndexes) == "table" and data.wheelIndexes or {}

    if not Functions.HasItem(src, "lug_wrench", 1) and not Functions.HasItem(src, "mechanic_tools", 1) then
        return { success = false, error = "missing_item" }
    end

    if netId > 0 then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            local currentBag = Entity(entity).state[STATE_BAG_KEY]
            local wheels = type(currentBag) == "table" and type(currentBag.wheels) == "table" and currentBag.wheels or {}

            for _, idx in ipairs(wheelIndexes) do
                local entry = wheels[tostring(idx)]
                if type(entry) == "table" and entry.detached == true then
                    return { success = false, error = "already_missing" }
                end
            end
        end
    end

    return { success = true }
end)

-- ── Complete Wheel Steal Callback ────────────────────

Sky.Cb.Register("sky_mechanicjob:wheelTheft:completeSteal", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local netId = tonumber(data and data.vehicleNetId) or 0
    local wheelIndexes = type(data and data.wheelIndexes) == "table" and data.wheelIndexes or {}

    if not Functions.HasItem(src, "lug_wrench", 1) and not Functions.HasItem(src, "mechanic_tools", 1) then
        return { success = false, error = "missing_item" }
    end

    local detachedCount = 0
    local totalCount = 4
    local allWheelsMissing = false

    if netId > 0 then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            local currentBag = Entity(entity).state[STATE_BAG_KEY]
            local wheels = (type(currentBag) == "table" and type(currentBag.wheels) == "table") and currentBag.wheels or {}

            for _, idx in ipairs(wheelIndexes) do
                wheels[tostring(idx)] = {
                    detached = true,
                    damage = 100.0,
                    popped = true
                }
            end

            for _, entry in pairs(wheels) do
                if type(entry) == "table" and entry.detached == true then
                    detachedCount = detachedCount + 1
                end
            end

            allWheelsMissing = (detachedCount >= 4)

            Entity(entity).state:set(STATE_BAG_KEY, {
                wheels = wheels,
                allWheelsMissing = allWheelsMissing
            }, true)
        end
    end

    -- Reward wheels item to player
    Functions.AddItem(src, "wheels", 1)

    return {
        success = true,
        detachedCount = detachedCount,
        totalCount = totalCount,
        allWheelsMissing = allWheelsMissing
    }
end)
