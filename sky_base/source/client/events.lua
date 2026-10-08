if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/events.lua") end
-- =====================================================
--  sky_base · source/client/events.lua
--  Deobfuscated & Cleaned
-- =====================================================

RegisterNetEvent("sky_base:notification", function(title, message, notifyType, duration)
    Sky.Show.Notification(title, message, notifyType, duration)
end)

-- Older names the job resources sent; they had no handler, so those notices never showed.
RegisterNetEvent("sky_base:client:showNotification", function(title, message, notifyType, duration)
    Sky.Show.Notification(title, message, notifyType, duration)
end)

RegisterNetEvent("sky_base:showNotification", function(data, message, notifyType, duration)
    if type(data) == "table" then
        Sky.Show.Notification(data.title, data.msg or data.message, data.type, data.duration or data.time)
    else
        Sky.Show.Notification(data, message, notifyType, duration)
    end
end)

Sky.Cb.Register("sky_base:getVehicleMods", function(model)
    local vehicleObj = Sky.Vehicle:new()
    local playerCoords = GetEntityCoords(PlayerPedId()) + vector3(0.0, 0.0, 10.0)

    vehicleObj:Spawn(model, playerCoords)
    FreezeEntityPosition(vehicleObj.entity, true)

    local props = vehicleObj:GetVehicleProperties()
    vehicleObj:Remove()

    return props
end)

Sky.Cb.Register("sky_base:giveVehicleClient", function(model)
    if GetResourceState("bp_garage") == "started" then
        local vehicleObj = Sky.Vehicle:new()
        local playerCoords = GetEntityCoords(PlayerPedId())

        vehicleObj:Spawn(model, playerCoords)
        FreezeEntityPosition(vehicleObj.entity, true)
        SetPedIntoVehicle(PlayerPedId(), vehicleObj.entity, -1)

        TriggerEvent("bp_garage:addownervehicle", false)
        Wait(2000)
        vehicleObj:Remove()
    else
        Sky.Debug("error", "sky_base:giveVehicleClient was used but bp_garage is not started")
    end
end)

RegisterNetEvent("sky_base:client:changeConfig", function(key, value)
    Sky.Config[key] = value
end)

-- The adapters take (vehicle, plate, model); the server can only send a network id.
RegisterNetEvent("sky_base:client:giveVehicleKeys", function(vehicle, plate)
    if not Sky.Functions.GiveVehicleKeys then return end

    if vehicle and not DoesEntityExist(vehicle) and NetworkDoesNetworkIdExist(vehicle) then
        vehicle = NetToVeh(vehicle)
    end
    local exists = vehicle and vehicle ~= 0 and DoesEntityExist(vehicle)
    plate = plate or (exists and GetVehicleNumberPlateText(vehicle)) or nil
    local model = exists and GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)) or nil
    Sky.Functions.GiveVehicleKeys(exists and vehicle or nil, plate, model)
end)
