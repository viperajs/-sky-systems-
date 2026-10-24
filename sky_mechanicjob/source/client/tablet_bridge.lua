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

local function resolveMechanicRoute(appKey, route)
    if type(route) == "string" and MECHANIC_TABLET_ROUTES[route] then
        return MECHANIC_TABLET_ROUTES[route]
    end
    if type(appKey) == "string" and MECHANIC_TABLET_ROUTES[appKey] then
        return MECHANIC_TABLET_ROUTES[appKey]
    end
    if type(route) == "string" and route:find("^/tablet/mechanic%-") then
        return route
    end
    return nil
end

local function getNuiLanguagePayload()
    local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
    local locales = type(nuiLocales) == "table" and nuiLocales or {}
    return {
        lang = localeKey,
        locales = locales
    }
end

-- Opening an app used to connect the closest vehicle within 6 m, replacing the one the
-- mechanic had picked, so the diagnostics and the dyno showed cars nobody had connected.
-- The mechanic connects a vehicle with "Connect Vehicle"; opening only drops a connection
-- to a vehicle that is gone or out of range (GetTabletConnectedVehicle).
local function checkConnectedVehicle()
    if OrderTabletState and type(GetTabletConnectedVehicle) == "function" then
        GetTabletConnectedVehicle()
    end
end

local function openMechanicTabletRoute(route, extra)
    extra = type(extra) == "table" and extra or {}
    local resolved = resolveMechanicRoute(extra.appKey, route)
    if not resolved then
        return false
    end
    route = resolved
    if TuningState then
        -- Closing properly restores the previewed parts that were not bought.
        if TuningState.active and type(setTuningClosed) == "function" then
            setTuningClosed(true)
        end
        TuningState.active = false
    end
    checkConnectedVehicle()

    TriggerEvent("sky_jobs_base:tablet:setOpenState", true, {
        appKey = extra.appKey,
        route = route
    })

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    local langPayload = getNuiLanguagePayload()
    SendNUIMessage({
        type = "tablet:open",
        route = route,
        noAnimation = extra.noAnimation == true,
        jobColor = extra.jobColor,
        openDelayMs = extra.openDelayMs,
        lang = langPayload.lang,
        locales = langPayload.locales
    })

    SendNUIMessage({
        type = "tablet:navigate",
        data = {
            route = route,
            appKey = extra.appKey
        }
    })
    SendNUIMessage({
        type = "navigate",
        route = route
    })
    return true
end

RegisterNetEvent("sky_mechanicjob:tablet:openApp", function(data)
    local route = nil
    local noAnimation = false
    local openDelayMs = 0
    local appKey = nil
    local jobColor = nil

    if type(data) == "string" then
        route = data
    elseif type(data) == "table" then
        route = data.route or data.launchRoute
        appKey = data.key or data.appKey
        noAnimation = data.noAnimation == true
        openDelayMs = math.max(0, tonumber(data.openDelayMs) or 0)
        jobColor = data.jobColor
    else
        return
    end

    local mechanicRoute = resolveMechanicRoute(appKey, route)
    if not mechanicRoute then
        if GetResourceState("sky_jobs_base") ~= "started" then
            return
        end
        -- Resource Lua globals are isolated. Use the export owned by sky_jobs_base.
        pcall(function()
            return exports.sky_jobs_base:OpenOnJobsBase(appKey, route or "/tablet", { jobColor = jobColor, noAnimation = noAnimation })
        end)
        return
    end

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

exports("ResolveMechanicTabletRoute", function(appKey, route)
    return resolveMechanicRoute(appKey, route)
end)

exports("OpenMechanicTabletRoute", function(route, extra)
    return openMechanicTabletRoute(route, extra or {})
end)

RegisterNUICallback("tablet:releaseFocus", function(data, cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    cb({ success = true })
end)
