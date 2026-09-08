if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/incident_notification.lua") end
-- =====================================================
--  sky_jobs_base · source/client/incident_notification.lua
--  Deobfuscated & Cleaned
-- =====================================================

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}

local panicLocales = locales.Panic or {}
local pingLocales = locales.Ping or {}
local config = (Config and Config.IncidentNotification) or {}

local activeIncidentData = nil
local isIncidentActive = false
local incidentExpiresAt = 0

local KEY_MAP = {
    [47] = "g",
    [177] = "BACK",
    [244] = "m"
}

local function resolveConfigKey(val, fallback)
    if type(val) == "string" and val ~= "" then
        return val
    end
    return fallback
end

local function getIncidentHotkeys()
    local hotkeys = config.hotkeys or {}
    local keyMappings = config.keyMappings or {}

    local mapKey = resolveConfigKey(keyMappings.openMap, KEY_MAP[tonumber(hotkeys.openMap)] or "m")
    local wpKey = resolveConfigKey(keyMappings.setWaypoint, KEY_MAP[tonumber(hotkeys.setWaypoint)] or "g")
    local dismissKey = resolveConfigKey(keyMappings.dismiss, KEY_MAP[tonumber(hotkeys.dismiss)] or "BACK")

    return {
        openMap = mapKey,
        setWaypoint = wpKey,
        dismiss = dismissKey
    }
end

local function formatKeyLabel(key)
    local upperKey = (type(key) == "string" and key:upper()) or ""
    if upperKey == "BACK" then
        return "Backspace"
    end
    if #upperKey == 1 then
        return upperKey
    end
    return key
end

local function formatNuiKeyList(key)
    local upperKey = (type(key) == "string" and key:upper()) or ""
    if upperKey == "BACK" then
        return { "backspace" }
    end
    if upperKey ~= "" then
        local lowerKey = tostring(key):lower()
        return { lowerKey, lowerKey, lowerKey }
    end
    return {}
end

local function getNuiHotkeyConfig()
    local keys = getIncidentHotkeys()
    return {
        openMap = {
            label = formatKeyLabel(keys.openMap) or "M",
            keys = formatNuiKeyList(keys.openMap)
        },
        setWaypoint = {
            label = formatKeyLabel(keys.setWaypoint) or "G",
            keys = formatNuiKeyList(keys.setWaypoint)
        },
        dismiss = {
            label = formatKeyLabel(keys.dismiss) or "Backspace",
            keys = formatNuiKeyList(keys.dismiss)
        }
    }
end

local function getIncidentTitle(incType)
    if incType == "ping" then
        return pingLocales.Title or "Ping"
    end

    if incType == "dispatch" then
        local nuiMap = locales.Nui and locales.Nui.map
        local dispatchPanel = nuiMap and nuiMap.dispatch
        return (dispatchPanel and dispatchPanel.panelTitle) or "Dispatch"
    end

    return panicLocales.Title or "Panic"
end

local function dismissIncident()
    activeIncidentData = nil
    isIncidentActive = false
    incidentExpiresAt = 0

    SendNUIMessage({
        type = "incident:dismiss"
    })
end

local function setIncidentWaypoint(data)
    local coords = data and data.coords
    local title = getIncidentTitle(data and data.incidentType)

    if coords and coords.x and coords.y then
        SetNewWaypoint(tonumber(coords.x) or 0.0, tonumber(coords.y) or 0.0)
        Sky.Show.Notification(title, panicLocales.WaypointSet or "Waypoint set.", "info")
        return true
    end

    Sky.Show.Notification(title, panicLocales.WaypointMissing or "No location available.", "error")
    return false
end

local function openIncidentMap(data)
    local targetType = tostring(data and data.mapTargetType or "")
    local targetId = tostring(data and data.mapTargetId or "")

    local route = "/tablet/map"
    if targetType ~= "" and targetId ~= "" then
        route = string.format("%s?focusType=%s&focusId=%s", route, targetType, targetId)
    end

    local jobColor = Sky.Cb.Trigger("sky_jobs_base:getJobColor")
    local success = Sky_Jobs.Tablet.Open("map", route, {
        jobColor = jobColor,
        navigate = {
            route = "/tablet/map",
            query = {
                focusType = targetType,
                focusId = targetId
            }
        }
    })

    return success == true
end

RegisterNetEvent("sky_jobs_base:incident:notify", function(data)
    if type(data) ~= "table" then return end

    local duration = tonumber(config.durationMs) or 30000
    local alertData = {
        incidentType = data.incidentType,
        id = data.id,
        officerName = data.officerName,
        callsign = data.callsign,
        coords = data.coords,
        location = data.location,
        title = data.title,
        message = data.message,
        createdAt = data.createdAt,
        mapTargetType = data.mapTargetType,
        mapTargetId = data.mapTargetId,
        durationMs = duration,
        hotkeys = getNuiHotkeyConfig()
    }

    SendNUIMessage({
        type = "incident:alert",
        data = alertData
    })

    activeIncidentData = alertData
    isIncidentActive = true
    incidentExpiresAt = GetGameTimer() + duration
end)

RegisterNUICallback("incident:setWaypoint", function(data, cb)
    local success = setIncidentWaypoint(data)
    cb({
        success = success,
        error = not success and "missing_coords" or nil
    })
end)

RegisterNUICallback("incident:openMap", function(data, cb)
    openIncidentMap(data)
    dismissIncident()
    cb({ success = true })
end)

local function triggerDismissHotkey()
    if isIncidentActive and activeIncidentData then
        dismissIncident()
    end
end

local function triggerWaypointHotkey()
    if isIncidentActive and activeIncidentData then
        setIncidentWaypoint(activeIncidentData)
    end
end

local function triggerOpenMapHotkey()
    if isIncidentActive and activeIncidentData then
        openIncidentMap(activeIncidentData)
        dismissIncident()
    end
end

local function setupIncidentKeybinds()
    local keys = getIncidentHotkeys()

    RegisterCommand("sky_jobs_incident_dismiss", function()
        triggerDismissHotkey()
    end, false)
    RegisterKeyMapping("sky_jobs_incident_dismiss", "Dismiss incident notification", "keyboard", keys.dismiss)

    RegisterCommand("sky_jobs_incident_waypoint", function()
        triggerWaypointHotkey()
    end, false)
    RegisterKeyMapping("sky_jobs_incident_waypoint", "Set incident waypoint", "keyboard", keys.setWaypoint)

    RegisterCommand("sky_jobs_incident_open_map", function()
        triggerOpenMapHotkey()
    end, false)
    RegisterKeyMapping("sky_jobs_incident_open_map", "Open incident in map", "keyboard", keys.openMap)
end

setupIncidentKeybinds()

CreateThread(function()
    while true do
        Wait(1000)
        if isIncidentActive and activeIncidentData then
            local now = GetGameTimer()
            if incidentExpiresAt > 0 and now >= incidentExpiresAt then
                dismissIncident()
            end
        end
    end
end)
