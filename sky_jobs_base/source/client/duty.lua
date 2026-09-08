if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/duty.lua") end
-- =====================================================
--  sky_jobs_base · source/client/duty.lua
--  Deobfuscated & Cleaned
-- =====================================================

local state = {
    active = false
}

local function openDutyMenu(title)
    if Config and Config.DutySystem == false then
        return
    end

    local titleText = title or "Duty Terminal"
    local res = Sky.Cb.Trigger("sky_jobs_base:duty:getSnapshot", titleText)

    if not (res and res.success and res.data) then
        return
    end

    state.active = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        type = "duty:open",
        data = res.data
    })
end

local function closeDutyMenu()
    if not state.active then
        return
    end

    state.active = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        type = "duty:close"
    })
end

RegisterNetEvent("sky_jobs_base:duty:open", function(title)
    openDutyMenu(title)
end)

RegisterNetEvent("sky_jobs_base:duty:close", function()
    closeDutyMenu()
end)
