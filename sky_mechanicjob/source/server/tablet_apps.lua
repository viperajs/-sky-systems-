if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/tablet_apps.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_mechanicjob · source/server/tablet_apps.lua
--  Mechanic Tablet App Registrations & Integration
-- =====================================================

local MECHANIC_TABLET_APPS = {
    {
        key = "orders",
        label = "Orders",
        icon = "clipboard",
        route = "/tablet/mechanic-orders",
        launchRoute = "/tablet/mechanic-orders",
        category = "work",
        job = "mechanic",
        permission = nil,
        clientEvent = "sky_mechanicjob:tablet:openApp"
    },
    {
        key = "diagnostics",
        label = "Diagnostics",
        icon = "wrench",
        route = "/tablet/mechanic-diagnostics",
        launchRoute = "/tablet/mechanic-diagnostics",
        category = "work",
        job = "mechanic",
        permission = nil,
        clientEvent = "sky_mechanicjob:tablet:openApp"
    },
    {
        key = "vehicles",
        label = "Vehicle Registry",
        icon = "car",
        route = "/tablet/mechanic-vehicles",
        launchRoute = "/tablet/mechanic-vehicles",
        category = "management",
        job = "mechanic",
        permission = nil,
        clientEvent = "sky_mechanicjob:tablet:openApp"
    },
    {
        key = "parts_shop",
        label = "Parts Shop",
        icon = "shopping-cart",
        route = "/tablet/mechanic-parts-shop",
        launchRoute = "/tablet/mechanic-parts-shop",
        category = "supply",
        job = "mechanic",
        permission = nil,
        clientEvent = "sky_mechanicjob:tablet:openApp"
    },
    {
        key = "dyno",
        label = "Dyno Stand",
        icon = "gauge",
        route = "/tablet/mechanic-dyno",
        launchRoute = "/tablet/mechanic-dyno",
        category = "performance",
        job = "mechanic",
        permission = nil,
        clientEvent = "sky_mechanicjob:tablet:openApp"
    }
}

local function registerMechanicAppsWithJobsBase()
    local state = GetResourceState("sky_jobs_base")
    if state == "started" or state == "starting" then
        local finalApps = {}
        local jobsToRegister = (Config.Jobs and #Config.Jobs > 0) and Config.Jobs or { { name = "mechanic" } }
        
        for _, app in ipairs(MECHANIC_TABLET_APPS) do
            for _, j in ipairs(jobsToRegister) do
                local appCopy = {}
                for k, v in pairs(app) do appCopy[k] = v end
                appCopy.job = j.name
                table.insert(finalApps, appCopy)
            end
        end
        exports['sky_jobs_base']:RegisterTabletApps("sky_mechanicjob", finalApps)
    end
end

registerMechanicAppsWithJobsBase()

AddEventHandler("sky_jobs_base:server:ready", function()
    registerMechanicAppsWithJobsBase()
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == "sky_jobs_base" then
        registerMechanicAppsWithJobsBase()
    end
end)

registerExport("GetMechanicTabletApps", function()
    return MECHANIC_TABLET_APPS
end)
