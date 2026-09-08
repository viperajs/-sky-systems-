if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/multijob.lua") end
-- =====================================================
--  sky_jobs_base · source/client/multijob.lua
--  Deobfuscated & Cleaned
-- =====================================================

local config = (Config and Config.MultiJob) or {}
if config.enabled == false then return end

local commandName = config.command or "jobs"
local state = {
    active = false
}

local function openMultiJob(data)
    if config.enabled == false then return end

    local snapshot = data
    if not snapshot then
        local res = Sky.Cb.Trigger("sky_jobs_base:multijob:getSnapshot", {})
        if res and res.success and res.data then
            snapshot = res.data
        else
            return
        end
    end

    state.active = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        type = "multijob:open",
        data = snapshot
    })
end

local function closeMultiJob()
    if not state.active then return end

    state.active = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        type = "multijob:close"
    })
end

local function refreshMultiJob()
    if not state.active then return end

    local res = Sky.Cb.Trigger("sky_jobs_base:multijob:getSnapshot", {})
    if res and res.success and res.data then
        SendNUIMessage({
            type = "multijob:update",
            data = res.data
        })
    end
end

RegisterNetEvent("sky_jobs_base:multijob:open", function(data)
    openMultiJob(data)
end)

RegisterNetEvent("sky_jobs_base:multijob:close", function()
    closeMultiJob()
end)

RegisterNetEvent("sky_jobs_base:multijob:refresh", function()
    refreshMultiJob()
end)

RegisterNUICallback("multijob:getSnapshot", function(_, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:multijob:getSnapshot", {})
    cb(res or { success = false })
end)

RegisterNUICallback("multijob:switch", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:multijob:switch", data or {})
    if res and res.success and res.data then
        TriggerEvent("sky_jobs_base:creator:updatePlayerJob", res.data.activeJob)
        TriggerEvent("sky_jobs_base:creator:updatePlayerDuty", res.data.onDuty == true, res.data.activeJob)
    end
    cb(res or { success = false })
end)

RegisterNUICallback("multijob:setDuty", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:multijob:setDuty", data or {})
    if res and res.success and res.data then
        TriggerEvent("sky_jobs_base:creator:updatePlayerJob", res.data.activeJob)
        TriggerEvent("sky_jobs_base:creator:updatePlayerDuty", res.data.onDuty == true, res.data.activeJob)
    end
    cb(res or { success = false })
end)

RegisterNUICallback("multijob:removeSelf", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:multijob:removeSelf", data or {})
    cb(res or { success = false })
end)

RegisterNUICallback("multijob:close", function(_, cb)
    closeMultiJob()
    cb({ success = true })
end)

AddEventHandler("sky_jobs:nuiClosed", function()
    closeMultiJob()
end)

RegisterCommand(commandName, function()
    openMultiJob()
end, false)

if type(config.openKey) == "string" and config.openKey ~= "" then
    RegisterKeyMapping(commandName, "Open jobs menu", "keyboard", config.openKey)
end
