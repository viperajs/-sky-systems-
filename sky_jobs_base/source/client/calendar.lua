if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/calendar.lua") end
-- =====================================================
--  sky_jobs_base · source/client/calendar.lua
--  Deobfuscated & Cleaned
-- =====================================================

local function isCalendarEnabled()
    local tabletCfg = Config and Config.Tablet
    if not tabletCfg or tabletCfg.enabled == false then
        return false
    end
    local apps = tabletCfg.apps or {}
    return apps.calendar ~= false
end

RegisterNUICallback("calendar:getEvents", function(data, cb)
    if not isCalendarEnabled() then
        cb({ success = false, data = {}, error = "disabled" })
        return
    end

    data = data or {}
    local payload = {
        start = data.start,
        ["end"] = data["end"] or data.finish or data.to
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:calendar:getEvents", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("calendar:addEvent", function(data, cb)
    if not isCalendarEnabled() then
        cb({ success = false, data = {}, error = "disabled" })
        return
    end

    data = data or {}
    local payload = {
        title = data.title,
        date = data.date,
        time = data.time,
        color = data.color
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:calendar:addEvent", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)
