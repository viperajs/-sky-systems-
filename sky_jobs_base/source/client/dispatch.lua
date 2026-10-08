if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/dispatch.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_jobs_base · source/client/dispatch.lua
--  Deobfuscated & Cleaned
-- =====================================================

--- Triggers server event to create a job dispatch notification.
---@param title string
---@param message string
---@param jobKey? string
---@param coords? table|vector3
---@param extraData? table
---@return boolean
registerExport("createDispatch", function(title, message, jobKey, coords, extraData)
    TriggerServerEvent("sky_jobs_base:dispatch:create", title, message, jobKey, coords, extraData)
    return true
end)

local DEFAULT_BLIP_SPRITE = 161
local DEFAULT_BLIP_COLOR = 5

local dispatchBlips = {}

-- Open dispatches the player can see get a map blip; done, deleted and expired ones lose it.
local function syncDispatchBlips(list)
    local open = {}
    for _, dispatch in ipairs(type(list) == "table" and list or {}) do
        local id = type(dispatch) == "table" and dispatch.id and tostring(dispatch.id)
        local coords = id and dispatch.coords
        local x, y = coords and tonumber(coords.x), coords and tonumber(coords.y)
        if id and x and y and dispatch.status ~= "done" then
            open[id] = true
            if not dispatchBlips[id] then
                local blipCfg = type(dispatch.blip) == "table" and dispatch.blip or {}
                local blip = AddBlipForCoord(x, y, tonumber(coords.z) or 0.0)
                SetBlipSprite(blip, tonumber(blipCfg.sprite) or DEFAULT_BLIP_SPRITE)
                SetBlipColour(blip, tonumber(blipCfg.color) or DEFAULT_BLIP_COLOR)
                SetBlipScale(blip, 0.9)
                SetBlipAsShortRange(blip, false)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentSubstringPlayerName(tostring(dispatch.title or "Dispatch"))
                EndTextCommandSetBlipName(blip)
                dispatchBlips[id] = blip
            end
        end
    end

    for id, blip in pairs(dispatchBlips) do
        if not open[id] then
            if DoesBlipExist(blip) then RemoveBlip(blip) end
            dispatchBlips[id] = nil
        end
    end
end

RegisterNetEvent("sky_jobs_base:map:updateDispatches", function(data)
    if type(data) == "table" then
        syncDispatchBlips(data.dispatches)
    end
end)

AddEventHandler("sky_jobs_base:access:stateChanged", function(state)
    if type(state) == "table" and state.onDuty then
        local res = Sky.Cb.Trigger("sky_jobs_base:map:getDispatches")
        if type(res) == "table" and res.success and type(res.data) == "table" then
            syncDispatchBlips(res.data.dispatches)
        end
        return
    end
    syncDispatchBlips({})
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        syncDispatchBlips({})
    end
end)
