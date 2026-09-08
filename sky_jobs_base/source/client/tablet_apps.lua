if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/tablet_apps.lua") end
local function logDiagnostics(level, event, details)
    if SkyDiagnostics and SkyDiagnostics.Log then
        SkyDiagnostics.Log(level, event, details)
    elseif level == "warn" or level == "error" then
        local ok, message = pcall(json.encode, details or {})
        print(("[sky_jobs_base][%s][%s] %s"):format(level:upper(), event, ok and message or "Diagnostics unavailable"))
    end
end
-- =====================================================
--  sky_jobs_base · source/client/tablet_apps.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky_Jobs = Sky_Jobs or {}
Sky_Jobs.TabletApps = Sky_Jobs.TabletApps or {}

local cachedApps = {}
local lastCacheTime = 0
local CACHE_TTL_MS = 5000
local DEFAULT_OPEN_DELAY_MS = 800

local tabletConfig = (Config and Config.Tablet) or {}
local isTabletSystemEnabled = tabletConfig.enabled ~= false
local appConfigMap = tabletConfig.apps or {}

local function normalizeAppKey(val)
    if type(val) ~= "string" then return nil end
    local match = val:match("^%s*(.-)%s*$")
    if not match or match == "" then return nil end
    return match:lower()
end

local function isAppEnabled(key)
    if not isTabletSystemEnabled then return false end
    if type(appConfigMap) ~= "table" then return true end

    local normKey = normalizeAppKey(key)
    if not normKey then return true end

    local setting = appConfigMap[normKey]
    if setting == nil and normKey ~= key then
        setting = appConfigMap[key]
    end

    if setting == false then return false end
    if type(setting) == "table" and setting.enabled == false then return false end

    return true
end

local function filterEnabledApps(appList)
    if not isTabletSystemEnabled or type(appList) ~= "table" then
        return {}
    end

    local filtered = {}
    for _, app in ipairs(appList) do
        if app and isAppEnabled(app.key) then
            filtered[#filtered + 1] = app
        end
    end
    return filtered
end

local function shouldRefreshCache()
    return (GetGameTimer() - lastCacheTime) > CACHE_TTL_MS
end

local function fetchTabletApps()
    local res = Sky.Cb.Trigger("sky_jobs_base:getTabletApps")
    if type(res) == "table" and res.success == true and type(res.data) == "table" then
        cachedApps = filterEnabledApps(res.data)
        lastCacheTime = GetGameTimer()
        return cachedApps
    elseif type(res) == "table" and #res > 0 then
        cachedApps = filterEnabledApps(res)
        lastCacheTime = GetGameTimer()
        return cachedApps
    end
    return cachedApps or {}
end

local function getTabletApps()
    if shouldRefreshCache() then
        return fetchTabletApps()
    end
    return cachedApps or {}
end

local function getAppByKey(key)
    local normKey = normalizeAppKey(key)
    if not normKey then return nil end

    for _, app in ipairs(getTabletApps()) do
        if app and normalizeAppKey(app.key) == normKey then
            return app
        end
    end
    return nil
end

local function getAppByRoute(route)
    if type(route) ~= "string" or route == "" then return nil end

    for _, app in ipairs(getTabletApps()) do
        if app then
            local targetRoute = app.launchRoute or app.route
            if targetRoute == route then
                return app
            end
        end
    end
    return nil
end

local function launchAppDirect(app, key, route, extraOpts)
    local targetRoute = route or app.launchRoute or app.route
    local targetKey = normalizeAppKey(app.key) or key
    extraOpts = type(extraOpts) == "table" and extraOpts or {}

    local isOpen = Sky_Jobs.TabletState and Sky_Jobs.TabletState.IsOpen and Sky_Jobs.TabletState.IsOpen()
    if Sky_Jobs.Tablet and Sky_Jobs.Tablet.HasRequiredItem and Sky_Jobs.Tablet.HasRequiredItem() == false then
        return false, {
            key = "radial.actions.tablet.states.missingItem",
            fallback = "You need a tablet to do this."
        }
    end

    TriggerEvent("sky_jobs_base:tablet:setOpenState", true, {
        appKey = targetKey,
        route = targetRoute
    })

    local isMechanicApp = (type(app.clientEvent) == "string" and app.clientEvent:find("^sky_mechanicjob:") ~= nil)
        or (type(app.serverEvent) == "string" and app.serverEvent:find("^sky_mechanicjob:") ~= nil)
    logDiagnostics("info", "tablet.app_owner", { name = targetKey, route = targetRoute, owner = isMechanicApp and "sky_mechanicjob" or "sky_jobs_base" })

    if not isMechanicApp then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
    end

    local payloadData = {
        key = targetKey,
        route = targetRoute,
        app = app,
        reopen = true,
        openDelayMs = not isOpen and DEFAULT_OPEN_DELAY_MS or nil
    }

    if type(app.clientEvent) == "string" and app.clientEvent ~= "" then
        if not isMechanicApp then
            SendNUIMessage({
                type = "tablet:open",
                jobColor = extraOpts.jobColor
            })
        end
        TriggerEvent(app.clientEvent, payloadData)
        return true
    end

    if type(app.serverEvent) == "string" and app.serverEvent ~= "" then
        if not app.serverEvent:find("^sky_mechanicjob:") then
            SendNUIMessage({
                type = "tablet:open",
                jobColor = extraOpts.jobColor
            })
        end
        TriggerServerEvent(app.serverEvent, payloadData)
        return true
    end

    if Sky_Jobs.Tablet and Sky_Jobs.Tablet.Open then
        return Sky_Jobs.Tablet.Open(targetKey, targetRoute, extraOpts)
    end
end

Sky_Jobs.Tablet = Sky_Jobs.Tablet or {}

--- Opens the last active app or home tab.
---@param extraOpts? table
function Sky_Jobs.Tablet.OpenLast(extraOpts)
    local lastState = Sky_Jobs.TabletState and Sky_Jobs.TabletState.GetLastState and Sky_Jobs.TabletState.GetLastState() or {}
    local appKey = normalizeAppKey(lastState.appKey)
    local route = lastState.route

    if appKey == "home" or route == "/tablet" then
        if Sky_Jobs.Tablet.Open then
            return Sky_Jobs.Tablet.Open("home", "/tablet", extraOpts)
        end
    end

    local app = (appKey and getAppByKey(appKey)) or (route and getAppByRoute(route))
    if app and app.closeOnLaunch ~= true then
        return launchAppDirect(app, appKey, route, extraOpts)
    end

    if Sky_Jobs.Tablet.Open then
        return Sky_Jobs.Tablet.Open("home", "/tablet", extraOpts)
    end
end

RegisterNUICallback("tablet:getApps", function(_, cb)
    cb({
        success = true,
        data = getTabletApps()
    })
end)

RegisterNUICallback("tablet:launchApp", function(data, cb)
    local rawKey = data and data.key
    local normKey = normalizeAppKey(rawKey)
    if not normKey then
        cb({ success = false, error = "Invalid app." })
        return
    end

    if not isAppEnabled(normKey) then
        cb({ success = false, error = "App disabled." })
        return
    end

    local app = getAppByKey(normKey)
    if not app then
        cb({ success = false, error = "Unknown app." })
        return
    end

    local defaultRoute = app.launchRoute or app.route
    local requestedRoute = type(data) == "table" and type(data.route) == "string" and data.route or nil

    if requestedRoute and defaultRoute then
        if requestedRoute ~= defaultRoute then
            local prefix = requestedRoute:sub(1, #defaultRoute + 1)
            if prefix == (defaultRoute .. "/") then
                defaultRoute = requestedRoute
            end
        end
    end

    TriggerEvent("sky_jobs_base:tablet:setOpenState", app.closeOnLaunch ~= true, {
        appKey = normKey,
        route = defaultRoute
    })

    if app.closeOnLaunch == true then
        SetNuiFocus(false, false)
    end

    local isMechanicApp = (type(app.clientEvent) == "string" and app.clientEvent:find("^sky_mechanicjob:") ~= nil)
        or (type(app.serverEvent) == "string" and app.serverEvent:find("^sky_mechanicjob:") ~= nil)
    logDiagnostics("info", "tablet.app_owner", { name = normKey, route = defaultRoute, owner = isMechanicApp and "sky_mechanicjob" or "sky_jobs_base" })

    if isMechanicApp then
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        SendNUIMessage({
            type = "tablet:close"
        })
        SendNUIMessage({
            type = "tablet:releaseFocus"
        })
    elseif app.closeOnLaunch ~= true then
        SendNUIMessage({
            type = "tablet:navigate",
            data = {
                route = defaultRoute,
                appKey = normKey
            }
        })
        SendNUIMessage({
            type = "navigate",
            route = defaultRoute
        })
    end

    if type(app.clientEvent) == "string" and app.clientEvent ~= "" then
        TriggerEvent(app.clientEvent, {
            key = normKey,
            route = defaultRoute,
            payload = data and data.payload or nil,
            app = app
        })
    end

    if type(app.serverEvent) == "string" and app.serverEvent ~= "" then
        TriggerServerEvent(app.serverEvent, {
            key = normKey,
            route = defaultRoute,
            payload = data and data.payload or nil
        })
    end

    cb({ success = true, route = defaultRoute })
end)

RegisterNetEvent("sky_jobs_base:tablet:openLastApp", function(extraOpts)
    if Sky_Jobs.Tablet and Sky_Jobs.Tablet.OpenLast then
        Sky_Jobs.Tablet.OpenLast(extraOpts)
    end
end)
