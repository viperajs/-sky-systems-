if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/tablet_bridge.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
local function logDiagnostics(level, event, details)
    if SkyDiagnostics and SkyDiagnostics.Log then
        SkyDiagnostics.Log(level, event, details)
    elseif level == "warn" or level == "error" then
        local ok, message = pcall(json.encode, details or {})
        print(("[sky_mechanicjob][%s][%s] %s"):format(level:upper(), event, ok and message or "Diagnostics unavailable"))
    end
end
-- =====================================================
--  sky_mechanicjob · source/client/tablet_bridge.lua
--  Mechanic tablet apps use mechanic NUI routes only.
--  General tablet + jobconfig stay on sky_jobs_base NUI.
-- =====================================================

local MECHANIC_TABLET_ROUTES = {
    orders = "/tablet/mechanic-orders",
    diagnostics = "/tablet/mechanic-diagnostics",
    dyno = "/tablet/mechanic-dyno",
    parts_shop = "/tablet/mechanic-parts-shop",
    vehicles = "/tablet/mechanic-vehicles",
    ["/orders"] = "/tablet/mechanic-orders",
    ["/diagnostics"] = "/tablet/mechanic-diagnostics",
    ["/dyno"] = "/tablet/mechanic-dyno",
    ["/parts_shop"] = "/tablet/mechanic-parts-shop",
    ["/vehicles"] = "/tablet/mechanic-vehicles",
}

local tabletOpenId = 0
local function tabletLog(level, event, details)
    details = details or {}
    details.file = "sky_mechanicjob/source/client/tablet_bridge.lua"
    logDiagnostics(level, "tablet_bridge." .. event, details)
end

local function resolveMechanicRoute(appKey, route)
    tabletLog("debug", "resolve_requested", { appKey = appKey, route = route })
    if type(route) == "string" and MECHANIC_TABLET_ROUTES[route] then
        tabletLog("debug", "route_resolved", { route = MECHANIC_TABLET_ROUTES[route], matchedBy = "route alias" })
        return MECHANIC_TABLET_ROUTES[route]
    end
    if type(appKey) == "string" and MECHANIC_TABLET_ROUTES[appKey] then
        tabletLog("debug", "route_resolved", { route = MECHANIC_TABLET_ROUTES[appKey], matchedBy = "app key" })
        return MECHANIC_TABLET_ROUTES[appKey]
    end
    if type(route) == "string" and route:find("^/tablet/mechanic%-") then
        tabletLog("debug", "route_resolved", { route = route, matchedBy = "mechanic route prefix" })
        return route
    end
    tabletLog("debug", "general_route", { appKey = appKey, route = route, message = "Route belongs to the general jobs tablet." })
    return nil
end

local function getNuiLanguagePayload()
    local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
    local locales = type(nuiLocales) == "table" and nuiLocales or {}
    tabletLog(next(locales) and "debug" or "warn", "language", {
        locale = localeKey, hasLocales = next(locales) ~= nil,
    })
    return {
        lang = localeKey,
        locales = locales
    }
end

local function connectNearbyVehicle()
    local ped = PlayerPedId()
    if ped == 0 or not DoesEntityExist(ped) then
        tabletLog("warn", "player_missing", { ped = ped })
        return
    end
    local veh = GetVehiclePedIsIn(ped, false)
    local detection = "current vehicle"
    if veh == 0 or not DoesEntityExist(veh) then
        detection = "nearby search"
        local pCoords = GetEntityCoords(ped)
        veh = GetClosestVehicle(pCoords.x, pCoords.y, pCoords.z, 6.0, 0, 71)
    end
    if not OrderTabletState then
        tabletLog("error", "vehicle_state_missing", { message = "OrderTabletState is unavailable. Check state.lua/main.lua startup errors." })
        return
    end
    if veh == 0 or not DoesEntityExist(veh) then
        tabletLog("warn", "no_nearby_vehicle", { radius = 6.0, previousNetId = OrderTabletState.connectedVehicleNetId,
            message = "No vehicle found. Tablet will open; diagnostics may have no vehicle connected." })
        return
    end
    local netId = NetworkGetNetworkIdFromEntity(veh)
    OrderTabletState.connectedVehicleNetId = netId
    tabletLog(netId ~= 0 and "info" or "warn", "vehicle_connected", { vehicle = veh, netId = netId, detection = detection })
end

local function openMechanicTabletRoute(route, extra)
    extra = type(extra) == "table" and extra or {}
    local resolved = resolveMechanicRoute(extra.appKey, route)
    if not resolved then
        tabletLog("error", "invalid_mechanic_route", { route = route, appKey = extra.appKey })
        return false
    end
    route = resolved
    tabletOpenId = tabletOpenId + 1
    local diagnosticId = "mechanic-tablet-" .. tabletOpenId
    tabletLog("info", "open_started", { diagnosticId = diagnosticId, route = route, appKey = extra.appKey,
        jobsBaseState = GetResourceState("sky_jobs_base"), browserReady = SkyDiagnostics and SkyDiagnostics.UiReady == true or false })
    if TuningState then
        tabletLog("debug", "tuning_deactivated", { wasActive = TuningState.active == true })
        TuningState.active = false
    else
        tabletLog("warn", "tuning_state_missing", { message = "TuningState is unavailable. Check state.lua/main.lua startup errors." })
    end
    connectNearbyVehicle()

    TriggerEvent("sky_jobs_base:tablet:setOpenState", true, {
        appKey = extra.appKey,
        route = route
    })

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    local langPayload = getNuiLanguagePayload()
    if SkyDiagnostics and SkyDiagnostics.TrackUi then SkyDiagnostics.TrackUi(diagnosticId, route) end
    SendNUIMessage({
        type = "tablet:open",
        diagnosticId = diagnosticId,
        route = route,
        noAnimation = extra.noAnimation == true,
        jobColor = extra.jobColor,
        openDelayMs = extra.openDelayMs,
        lang = langPayload.lang,
        locales = langPayload.locales
    })

    SendNUIMessage({
        type = "tablet:navigate",
        diagnosticId = diagnosticId,
        data = {
            route = route,
            appKey = extra.appKey
        }
    })
    SendNUIMessage({
        type = "navigate",
        diagnosticId = diagnosticId,
        route = route
    })
    tabletLog("info", "messages_sent", { diagnosticId = diagnosticId, route = route, message = "Waiting for browser acknowledgment and router logs." })
    return true
end

RegisterNetEvent("sky_mechanicjob:tablet:openApp", function(data)
    local route = nil
    local noAnimation = false
    local openDelayMs = 0
    local appKey = nil
    local jobColor = nil

    tabletLog("info", "open_event_received", { dataType = type(data) })

    if type(data) == "string" then
        route = data
    elseif type(data) == "table" then
        route = data.route or data.launchRoute
        appKey = data.key or data.appKey
        noAnimation = data.noAnimation == true
        openDelayMs = math.max(0, tonumber(data.openDelayMs) or 0)
        jobColor = data.jobColor
    else
        tabletLog("error", "invalid_open_payload", { dataType = type(data), message = "Expected a route string or app options table." })
        return
    end

    local mechanicRoute = resolveMechanicRoute(appKey, route)
    if not mechanicRoute then
        local jobsState = GetResourceState("sky_jobs_base")
        tabletLog("info", "fallback_requested", { appKey = appKey, route = route, jobsBaseState = jobsState })
        if jobsState ~= "started" then
            tabletLog("error", "fallback_unavailable", { message = "sky_jobs_base is not started; cannot open the general tablet." })
            return
        end
        -- Resource Lua globals are isolated. Use the export owned by sky_jobs_base.
        local ok, opened = pcall(function()
            return exports.sky_jobs_base:OpenOnJobsBase(appKey, route or "/tablet", { jobColor = jobColor, noAnimation = noAnimation })
        end)
        tabletLog(ok and opened == true and "info" or "error", "fallback_result", {
            appKey = appKey, route = route or "/tablet", opened = ok and opened == true,
            message = not ok and tostring(opened) or (opened ~= true and "Jobs tablet did not report a successful open." or "Jobs tablet open request completed."),
        })
        return
    end

    tabletLog("debug", "open_delay", { delayMs = openDelayMs > 0 and openDelayMs or 50 })
    if openDelayMs > 0 then
        Wait(openDelayMs)
    else
        Wait(50)
    end

    openMechanicTabletRoute(mechanicRoute, {
        appKey = appKey,
        noAnimation = noAnimation,
        jobColor = jobColor
    })
end)

registerExport("ResolveMechanicTabletRoute", function(appKey, route)
    return resolveMechanicRoute(appKey, route)
end)

registerExport("OpenMechanicTabletRoute", function(route, extra)
    return openMechanicTabletRoute(route, extra or {})
end)

RegisterNUICallback("tablet:releaseFocus", function(data, cb)
    tabletLog("info", "release_focus", { message = "Mechanic tablet requested focus release." })
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    cb({ success = true })
    tabletLog("debug", "focus_released", { success = true })
end)
