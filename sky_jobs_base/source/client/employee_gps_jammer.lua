if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/employee_gps_jammer.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_jobs_base · source/client/employee_gps_jammer.lua
--  Deobfuscated & Cleaned
-- =====================================================

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}
local jammerLocales = locales.employeeGpsJammer or {}
local errorLocales = jammerLocales.errors or {}

local config = (Config and Config.EmployeeGpsJammer) or {}
local jammerItem = config.item or "gps_jammer"
local maxDistance = tonumber(config.maxDistance) or 3.0

local isBusy = false

local function showNotification(message, notifyType)
    if type(message) ~= "string" or message == "" then return end
    local title = jammerLocales.title or "GPS Jammer"
    Sky.Show.Notification(title, message, notifyType or "info")
end

local function getErrorMessage(reason)
    if type(reason) == "string" and errorLocales[reason] then
        return errorLocales[reason]
    end
    return jammerLocales.failed or "Unable to disrupt the GPS signal."
end

local function getClosestTarget()
    local targetPed, dist = Sky.Players.GetClosestPlayer()
    if not targetPed or targetPed == -1 then
        return nil, "no_players"
    end

    if dist and dist > maxDistance then
        return nil, "too_far"
    end

    local serverId = GetPlayerServerId(targetPed)
    if not serverId or serverId == 0 then
        return nil, "invalid_target"
    end

    return serverId
end

local function playJammerAnim()
    local ped = PlayerPedId()
    local duration = tonumber(config.animDurationMs) or 2500

    if ped and ped ~= 0 and DoesEntityExist(ped) and IsPedInAnyVehicle(ped, false) then
        Wait(duration)
        return
    end

    local scenario = config.animScenario or "WORLD_HUMAN_STAND_MOBILE"
    TaskStartScenarioInPlace(ped, scenario, 0, true)
    Wait(duration)

    if IsPedUsingScenario(ped, scenario) then
        ClearPedTasks(ped)
    end
end

local function useJammer()
    if isBusy then return false end

    if config.enabled == false then
        showNotification(jammerLocales.disabled or "GPS jamming is unavailable.", "error")
        return false
    end

    local targetId, err = getClosestTarget()
    if not targetId then
        showNotification(getErrorMessage(err), "error")
        return false
    end

    isBusy = true
    playJammerAnim()

    TriggerServerEvent("sky_jobs_base:employeeGpsJammer:use", {
        targetId = targetId
    })

    isBusy = false
    return true
end

RegisterNetEvent("sky_jobs_base:employeeGpsJammer:useItem", function()
    useJammer()
end)

RegisterNetEvent("sky_jobs_base:employeeGpsJammer:result", function(data)
    if type(data) ~= "table" then return end
    if data.success == true then
        showNotification(jammerLocales.success or "Employee GPS signal disrupted.", "success")
        return
    end
    showNotification(getErrorMessage(data.reason), "error")
end)

RegisterNetEvent("sky_jobs_base:employeeGpsJammer:jammed", function(data)
    local sec = tonumber(data and data.durationSeconds) or tonumber(config.durationSeconds) or 300
    local template = jammerLocales.targetJammed or "Your duty GPS signal is being disrupted."
    local msg = template:gsub("{seconds}", tostring(sec))
    showNotification(msg, "error")
end)

if jammerItem and jammerItem ~= "" then
    registerExport(jammerItem, function()
        TriggerEvent("sky_jobs_base:employeeGpsJammer:useItem")
        return true
    end)
end
