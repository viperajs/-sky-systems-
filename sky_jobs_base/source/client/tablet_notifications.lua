if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/tablet_notifications.lua") end
-- =====================================================
--  sky_jobs_base · source/client/tablet_notifications.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky_Jobs = Sky_Jobs or {}
Sky_Jobs.Tablet = Sky_Jobs.Tablet or {}

--- Pushes a tablet notification to NUI.
---@param data table
function Sky_Jobs.Tablet.PushNotification(data)
    SendNUIMessage({
        type = "tablet:pushNotification",
        data = data or {}
    })
end

RegisterNetEvent("sky_jobs_base:tablet:pushNotification", function(data)
    Sky_Jobs.Tablet.PushNotification(data)
end)

RegisterNUICallback("tablet:notificationAction", function(data, cb)
    local action = type(data) == "table" and data.action or nil
    local actionData = (type(data) == "table" and data.data) or {}

    if action == "mechanic_parts_delivery_waypoint" then
        local responded = false
        local function responseCallback(res)
            if responded then return end
            responded = true
            cb(res or { success = false })
        end

        TriggerEvent("sky_mechanicjob:partsDelivery:notificationWaypoint", actionData, responseCallback)

        CreateThread(function()
            Wait(1000)
            if not responded then
                responded = true
                cb({ success = false, error = "Notification action unavailable." })
            end
        end)
        return
    end

    cb({ success = false, error = "Unknown notification action." })
end)
