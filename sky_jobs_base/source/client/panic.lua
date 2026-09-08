if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/panic.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_jobs_base · source/client/panic.lua
--  Deobfuscated & Cleaned
-- =====================================================

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}

local panicLocales = locales.Panic or {}
local pingLocales = locales.Ping or {}

local alertConfigs = {
    panic = {
        config = (Config and Config.Panic) or {},
        locales = panicLocales,
        alertEvent = "sky_jobs_base:panic:alert",
        acceptedEvent = "sky_jobs_base:panic:accepted",
        rejectedEvent = "sky_jobs_base:panic:rejected",
        triggerEvent = "sky_jobs_base:panic:trigger",
        listKey = "panics",
        playSound = true
    },
    ping = {
        config = (Config and Config.Ping) or {},
        locales = pingLocales,
        alertEvent = "sky_jobs_base:ping:alert",
        acceptedEvent = "sky_jobs_base:ping:accepted",
        rejectedEvent = "sky_jobs_base:ping:rejected",
        triggerEvent = "sky_jobs_base:ping:trigger",
        listKey = "pings",
        playSound = false
    }
}

local activeAlerts = {
    panic = {},
    ping = {}
}

local lastTriggered = {
    panic = 0,
    ping = 0
}

local keyLookup = {
    [182] = "l",
    [311] = "k"
}

local registeredJobMap = nil
local isRefreshingJobCache = false
local registeredKeybinds = {}

local function getKeyName(keyNum, fallback)
    local mapped = keyLookup[tonumber(keyNum)]
    if mapped then return mapped end
    if type(fallback) == "string" and fallback ~= "" then return fallback end
    return "k"
end

local function resolveKeyMapping(overrideKey, configKey, fallback)
    if type(overrideKey) == "string" and overrideKey ~= "" then
        return overrideKey
    end
    return getKeyName(configKey, fallback)
end

local function getAlertDuration(alertType)
    local sec = tonumber(alertConfigs[alertType].config.alertDurationSeconds)
    if not sec or sec <= 0 then
        return 300
    end
    return sec
end

local function getAllowedJobs(alertType)
    local allowed = alertConfigs[alertType].config.allowedJobs
    if type(allowed) == "table" then
        return allowed
    end
    if type(allowed) == "string" and allowed ~= "" then
        return { allowed }
    end
    return nil
end

local function normalizeJobName(name)
    if type(name) == "string" and name ~= "" then
        return name:lower()
    end
    return nil
end

local function updateRegisteredJobCache(jobsList)
    local cache = {}
    if type(jobsList) == "table" then
        for _, j in ipairs(jobsList) do
            local norm = normalizeJobName(j)
            if norm then cache[norm] = true end
        end
    end
    registeredJobMap = cache
end

local function refreshJobCache()
    local res = Sky.Cb.Trigger("sky_jobs_base:getRegisteredJobs")
    if type(res) ~= "table" then
        Sky.Debug("debug", "[sky_jobs_base][panic] getRegisteredJobs returned invalid payload; related job cache not updated")
        return
    end
    updateRegisteredJobCache(res)
end

local function scheduleRefreshJobCache()
    if isRefreshingJobCache then return end
    isRefreshingJobCache = true
    SetTimeout(250, function()
        isRefreshingJobCache = false
        refreshJobCache()
    end)
end

local function isJobAllowed(alertType, jobKey)
    local normJob = normalizeJobName(jobKey)
    if not normJob then return false end

    local allowedList = getAllowedJobs(alertType)
    if not allowedList then
        if not registeredJobMap then
            refreshJobCache()
        end
        return registeredJobMap and registeredJobMap[normJob] == true
    end

    for _, job in ipairs(allowedList) do
        if normalizeJobName(job) == normJob then
            return true
        end
    end
    return false
end

local function isCurrentPlayerAllowed(alertType)
    local jobState = GetJobState and GetJobState()
    if not (jobState and jobState.employed == true) then
        return false
    end
    return isJobAllowed(alertType, jobState.jobKey)
end

local function formatLocation(coords, fallback)
    if not coords then
        return fallback or "Unknown location"
    end

    local street1Hash, street2Hash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local s1 = street1Hash and GetStreetNameFromHashKey(street1Hash) or ""
    local s2 = street2Hash and GetStreetNameFromHashKey(street2Hash) or ""

    if s2 ~= "" then
        return string.format("%s / %s", s1, s2)
    end
    if s1 ~= "" then
        return s1
    end
    return fallback or "Unknown location"
end

local function clearBlips(alert)
    if not alert then return end
    if alert.blip and DoesBlipExist(alert.blip) then
        RemoveBlip(alert.blip)
    end
    if alert.radius and DoesBlipExist(alert.radius) then
        RemoveBlip(alert.radius)
    end
    alert.blip = nil
    alert.radius = nil
end

local function createAlertBlip(alertType, coords, label)
    if not (coords and coords.x and coords.y) then
        return nil, nil
    end

    local bConfig = alertConfigs[alertType].config.blip or {}
    local mainBlip = AddBlipForCoord(coords.x, coords.y, coords.z or 0.0)

    SetBlipSprite(mainBlip, tonumber(bConfig.sprite) or 161)
    SetBlipDisplay(mainBlip, 4)
    SetBlipColour(mainBlip, tonumber(bConfig.color) or 1)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(mainBlip)

    SetBlipScale(mainBlip, tonumber(bConfig.scale) or 1.0)
    SetBlipAsShortRange(mainBlip, bConfig.shortRange == true)

    if bConfig.flashing ~= false then
        SetBlipFlashes(mainBlip, true)
        if bConfig.flashInterval then
            SetBlipFlashInterval(mainBlip, tonumber(bConfig.flashInterval) or 850)
        end
    end

    local radiusBlip = nil
    local radiusVal = tonumber(bConfig.radius)
    if radiusVal and radiusVal > 0 then
        radiusBlip = AddBlipForRadius(coords.x, coords.y, coords.z or 0.0, radiusVal)
        local rColor = tonumber(bConfig.radiusColor) or tonumber(bConfig.color) or 1
        SetBlipColour(radiusBlip, rColor)
        SetBlipAlpha(radiusBlip, tonumber(bConfig.radiusAlpha) or 90)
    end

    return mainBlip, radiusBlip
end

local function addOrUpdateAlert(alertType, data)
    if type(data) ~= "table" then return end
    local id = data.id and tostring(data.id)
    if not id or not (data.coords and data.coords.x and data.coords.y) then return end

    local duration = getAlertDuration(alertType)
    local now = GetCloudTimeAsInt()
    local createdAt = tonumber(data.createdAt) or now
    local expiresAt = tonumber(data.expiresAt) or (createdAt + duration)
    if expiresAt <= 0 then
        expiresAt = now + duration
    end

    local existing = activeAlerts[alertType][id]
    if existing then
        existing.coords = data.coords
        existing.expiresAt = expiresAt
        existing.createdAt = createdAt
        return
    end

    local defaultTitle = (alertType == "ping" and (pingLocales.Title or "Ping")) or (panicLocales.Title or "Panic")
    local label = data.label or data.officerName or defaultTitle

    local b1, b2 = createAlertBlip(alertType, data.coords, label)
    activeAlerts[alertType][id] = {
        blip = b1,
        radius = b2,
        coords = data.coords,
        expiresAt = expiresAt,
        createdAt = createdAt
    }
end

local function removeAllAlerts(alertType)
    for _, alert in pairs(activeAlerts[alertType]) do
        clearBlips(alert)
    end
    activeAlerts[alertType] = {}
end

local function handleRejected(alertType, data)
    if type(data) ~= "table" then return end
    local cfgLocales = alertConfigs[alertType].locales
    local title = cfgLocales.Title or (alertType == "ping" and "Ping" or "Panic")

    if data.reason == "cooldown" then
        local sec = data.seconds or 0
        local template = cfgLocales.Cooldown or "Action is cooling down. Wait {seconds}s."
        local msg = template:gsub("{seconds}", tostring(sec))
        Sky.Show.Notification(title, msg, "error")
        return
    end

    if data.reason == "missing_item" then
        local template = cfgLocales.MissingItem or "You need {item} to use this action."
        local item = tostring(data.item or "the required item")
        local msg = template:gsub("{item}", item)
        Sky.Show.Notification(title, msg, "error")
        return
    end

    local msg = cfgLocales.NotOnDuty or "You must be on duty to use this action."
    Sky.Show.Notification(title, msg, "error")
end

local function syncActiveAlerts()
    local jobState = GetJobState and GetJobState()
    if not (jobState and jobState.employed == true) then
        removeAllAlerts("panic")
        removeAllAlerts("ping")
        return
    end

    local allowedTypes = {}
    for _, aType in ipairs({ "panic", "ping" }) do
        local cfg = alertConfigs[aType]
        if cfg.config.enabled ~= false and isJobAllowed(aType, jobState.jobKey) then
            allowedTypes[#allowedTypes + 1] = aType
        else
            removeAllAlerts(aType)
        end
    end

    if #allowedTypes == 0 then return end

    local res = Sky.Cb.Trigger("sky_jobs_base:alerts:getActive")
    if not (res and res.success and res.data) then return end

    for _, aType in ipairs(allowedTypes) do
        local listKey = alertConfigs[aType].listKey
        local alertList = res.data[listKey] or {}
        for _, alertData in ipairs(alertList) do
            addOrUpdateAlert(aType, alertData)
        end
    end
end

-- Register Event Handlers dynamically for panic and ping
for aType, cfg in pairs(alertConfigs) do
    RegisterNetEvent(cfg.alertEvent, function(data)
        if cfg.config.enabled == false then return end
        if not isCurrentPlayerAllowed(aType) then return end
        if type(data) ~= "table" then return end

        if cfg.playSound then
            PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", true)
        else
            PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        end

        addOrUpdateAlert(aType, data)
    end)

    RegisterNetEvent(cfg.rejectedEvent, function(data)
        handleRejected(aType, data)
    end)

    RegisterNetEvent(cfg.acceptedEvent, function()
        local localesObj = cfg.locales
        local title = localesObj.Title or (aType == "ping" and "Ping" or "Panic")
        local msg = localesObj.Sent or "Alert sent."
        local notifyType = (aType == "panic") and "warning" or "info"
        Sky.Show.Notification(title, msg, notifyType)
    end)
end

AddEventHandler("sky_jobs_base:access:stateChanged", function(stateData)
    if setupKeybinds then setupKeybinds() end
    if stateData and stateData.onDuty then
        syncActiveAlerts()
        return
    end
    removeAllAlerts("panic")
    removeAllAlerts("ping")
end)

RegisterNetEvent("sky_jobs_base:jobs:registered", function()
    scheduleRefreshJobCache()
end)

RegisterNetEvent("sky_jobs_base:jobs:unregistered", function()
    scheduleRefreshJobCache()
end)

CreateThread(function()
    refreshJobCache()
end)

CreateThread(function()
    Wait(1200)
    if setupKeybinds then setupKeybinds() end
    local jobState = GetJobState and GetJobState()
    if jobState and jobState.onDuty then
        syncActiveAlerts()
    end
end)

-- Background thread to prune expired blips
CreateThread(function()
    while true do
        Wait(1200)
        if next(activeAlerts.panic) or next(activeAlerts.ping) then
            local now = GetCloudTimeAsInt()
            for _, aType in ipairs({ "panic", "ping" }) do
                for id, alert in pairs(activeAlerts[aType]) do
                    if alert.expiresAt and now >= alert.expiresAt then
                        clearBlips(alert)
                        activeAlerts[aType][id] = nil
                    end
                end
            end
        end
    end
end)

local function triggerAlert(alertType)
    local cfg = alertConfigs[alertType]
    if cfg.config.enabled == false then return end

    local cdSec = tonumber(cfg.config.cooldownSeconds) or 0
    local cdMs = math.max(0, cdSec * 1000)

    local jobState = GetJobState and GetJobState()
    if not (jobState and jobState.employed == true and isJobAllowed(alertType, jobState.jobKey)) then
        return
    end

    if cfg.config.requireOnDuty ~= false then
        if not (jobState and jobState.onDuty == true) then
            local msg = cfg.locales.NotOnDuty or "You must be on duty to use this action."
            local title = cfg.locales.Title or (alertType == "ping" and "Ping" or "Panic")
            Sky.Show.Notification(title, msg, "error")
            return
        end
    end

    local now = GetGameTimer()
    if cdMs > 0 then
        local elapsed = now - lastTriggered[alertType]
        if cdMs > elapsed then
            local remainSec = math.ceil((cdMs - elapsed) / 1000)
            local template = cfg.locales.Cooldown or "Action is cooling down. Wait {seconds}s."
            local msg = template:gsub("{seconds}", tostring(remainSec))
            local title = cfg.locales.Title or (alertType == "ping" and "Ping" or "Panic")
            Sky.Show.Notification(title, msg, "error")
            return
        end
    end

    lastTriggered[alertType] = now
    local coords = GetEntityCoords(PlayerPedId())
    local locText = formatLocation(coords, cfg.locales.LocationUnknown or "Unknown location")

    TriggerServerEvent(cfg.triggerEvent, {
        location = locText
    })
end

local function registerAlertKeybind(alertType, defaultKey, description)
    local cfg = alertConfigs[alertType]
    if cfg.config.enabled == false then return end
    if registeredKeybinds[alertType] then return end

    local cmd = string.format("sky_jobs_%s", alertType)
    local mappedKey = resolveKeyMapping(cfg.config.keyMapping, cfg.config.key, defaultKey)
    local label = cfg.locales.MappingDescription or description

    RegisterCommand(cmd, function()
        triggerAlert(alertType)
    end, false)

    RegisterKeyMapping(cmd, label, "keyboard", mappedKey)
    registeredKeybinds[alertType] = true
end

function setupKeybinds()
    if alertConfigs.panic.config.useKeybind ~= false then
        if isCurrentPlayerAllowed("panic") then
            registerAlertKeybind("panic", "k", "Trigger panic alert")
        end
    end
end

setupKeybinds()
registerAlertKeybind("ping", "l", "Trigger location ping")

registerExport("triggerPanicAlert", function()
    triggerAlert("panic")
    return true
end)
