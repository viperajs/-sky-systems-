if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/public_forms.lua") end
-- =====================================================
--  sky_jobs_base · source/client/public_forms.lua
--  Deobfuscated & Cleaned
-- =====================================================

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}

local titleText = locales.PublicFormsTitle or "Public Forms"
local unavailableText = locales.PublicFormsUnavailable or "Public forms kiosk unavailable."

local function getStationName(stationId, data)
    if type(data) == "table" then
        local name = data.stationName or data.label or data.entryName or data.name
        if type(name) == "string" and name ~= "" then
            return name
        end
    end

    local stations = Config and Config.Stations or {}
    local station = stations[stationId]
    if station and station.name and station.name ~= "" then
        return station.name
    end

    return (Config and Config.JobLabel) or "Station"
end

local function getJobKeyFromData(data)
    if type(data) ~= "table" then return nil end
    local jKey = data.jobKey or data.job or data.jobName

    if type(jKey) == "number" then
        return tostring(jKey)
    end
    if type(jKey) == "string" and jKey ~= "" then
        return jKey
    end
    return nil
end

local function getJobColorFromData(data)
    if type(data) ~= "table" then return nil end
    local color = data.jobColor or data.color
    if type(color) == "string" and color ~= "" then
        return color
    end

    local jKey = getJobKeyFromData(data)
    if not jKey then return nil end

    local res = Sky.Cb.Trigger("sky_jobs_base:getJobColorFor", { jobKey = jKey })
    if type(res) == "table" then
        res = res.color
    end
    if type(res) == "string" and res ~= "" then
        return res
    end
    return nil
end

local function openPublicFormsKiosk(stationId, data)
    if not stationId or stationId == "" then
        Sky.Show.Notification(titleText, unavailableText, "error")
        return
    end

    local jKey = getJobKeyFromData(data)
    SendNUIMessage({
        type = "publicForms:open",
        stationId = stationId,
        stationName = getStationName(stationId, data),
        jobKey = jKey,
        jobColor = getJobColorFromData(data)
    })
    SetNuiFocus(true, true)
end

RegisterNetEvent("sky_jobs_base:publicFormsInteraction", function(data)
    local stationId = nil
    local stationData = data

    if type(data) == "table" then
        stationId = data.stationId or data.id or data.entryId or data.entry
    else
        stationId = data
    end

    if not stationId then
        Sky.Show.Notification(titleText, unavailableText, "error")
        return
    end

    openPublicFormsKiosk(tostring(stationId), stationData)
end)

RegisterNUICallback("publicForms:submit", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:publicForms:submit", data or {}) or {}
    cb(res)
end)

RegisterNUICallback("publicForms:getAll", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:publicForms:getAll") or {}
    cb(res)
end)

RegisterNUICallback("publicForms:updateStatus", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:publicForms:updateStatus", data) or {}
    cb(res)
end)

RegisterNUICallback("publicForms:getNotes", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:publicForms:getNotes", data) or {}
    cb(res)
end)

RegisterNUICallback("publicForms:addNote", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:publicForms:addNote", data) or {}
    cb(res)
end)

RegisterNUICallback("publicForms:getMyForms", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:publicForms:getMyForms", data) or {}
    cb(res)
end)

RegisterNUICallback("publicForms:getMyNotes", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:publicForms:getMyNotes", data) or {}
    cb(res)
end)

RegisterNUICallback("publicForms:close", function(data, cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    cb({ success = true })
end)
