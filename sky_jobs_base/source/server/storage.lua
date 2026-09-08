if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/storage.lua") end
-- =====================================================
--  sky_jobs_base · source/server/storage.lua
--  Storage Stashes, Trunk Props & Lockers Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

local placedTrunkProps = {}
local currentPropId = 1

-- ── Trunk Props Callbacks ────────────────────────────

Sky.Cb.Register("sky_jobs_base:trunkProps:getAll", function(source)
    local list = {}
    for _, prop in pairs(placedTrunkProps) do
        list[#list + 1] = prop
    end
    return {
        success = true,
        data = {
            props = list
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:getVehicleTrunkProps", function(source, data)
    local plate = data and data.plate
    return {
        success = true,
        data = {}
    }
end)

Sky.Cb.Register("sky_jobs_base:trunkProps:place", function(source, data)
    local propId = tostring(currentPropId)
    currentPropId = currentPropId + 1

    local record = {
        id = propId,
        model = data and data.model or "prop_barrier_work05",
        label = data and data.label or "Barrier",
        coords = data and data.coords,
        heading = data and data.heading or 0.0,
        placedBy = source
    }

    placedTrunkProps[propId] = record

    TriggerClientEvent("sky_jobs_base:trunkProps:add", -1, record)

    return {
        success = true,
        data = {
            propId = propId
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:trunkProps:remove", function(source, data)
    local propId = tostring(data and data.id or "")
    if placedTrunkProps[propId] then
        placedTrunkProps[propId] = nil
        TriggerClientEvent("sky_jobs_base:trunkProps:remove", -1, { id = propId })
    end
    return { success = true }
end)

-- ── Storage & Lockers Callbacks ──────────────────────

Sky.Cb.Register("sky_jobs_base:getPlayerInventoryItems", function(source)
    local items = {}
    if Functions and Functions.GetPlayer then
        local player = Functions.GetPlayer(source)
        if player and player.PlayerData and player.PlayerData.items then
            for _, it in pairs(player.PlayerData.items) do
                if it and (it.amount or it.count) and (it.amount or it.count) > 0 then
                    items[#items + 1] = {
                        name = it.name,
                        label = it.label or it.name,
                        amount = it.amount or it.count,
                        type = it.type or "item",
                        slot = it.slot
                    }
                end
            end
        end
    end
    return items
end)

Sky.Cb.Register("sky_jobs_base:getJobStorageContainsWeapons", function(source)
    return false
end)

Sky.Cb.Register("sky_jobs_base:getStorageItems", function(source, stationId)
    return {}
end)

Sky.Cb.Register("sky_jobs_base:getStorageCapacity", function(source, data)
    return {
        maxWeight = 1000000,
        slots = 50
    }
end)

Sky.Cb.Register("sky_jobs_base:getLockerItems", function(source, stationId)
    return {}
end)

Sky.Cb.Register("sky_jobs_base:storageTransfer", function(source, stationId, itemType, itemName, amount, category, metadata, metadataKey)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:lockerTransfer", function(source, stationId, itemType, itemName, amount, category, metadata, metadataKey)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:trunkTransfer", function(source, stationId, itemType, itemName, amount, metadata)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:openVehicleTrunk", function(source, data)
    return { success = true }
end)
