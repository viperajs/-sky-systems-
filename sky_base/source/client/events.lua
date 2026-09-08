if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/events.lua") end
-- =====================================================
--  sky_base · source/client/events.lua
--  Deobfuscated & Cleaned
-- =====================================================

RegisterNetEvent("sky_base:notification", function(title, message, notifyType, duration)
    Sky.Show.Notification(title, message, notifyType, duration)
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

RegisterNetEvent("sky_base:client:giveVehicleKeys", function(vehicle, plate)
    if Sky.Functions.GiveVehicleKeys then
        Sky.Functions.GiveVehicleKeys(nil, vehicle, plate)
    end
end)
