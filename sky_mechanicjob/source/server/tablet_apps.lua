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

-- Jobs from config.lua plus the workshops created in /jobconfig, which the server's
-- Config.Jobs does not contain.
local function getMechanicJobNames()
    local names, seen = {}, {}
    local function add(name)
        if type(name) == "string" and name ~= "" and not seen[name] then
            seen[name] = true
            names[#names + 1] = name
        end
    end

    for _, j in ipairs(Config.Jobs or {}) do
        add(type(j) == "table" and j.name or j)
    end
    if #names == 0 then
        add("mechanic")
    end
    for _, name in ipairs(Functions.GetConfiguratorJobNames()) do
        add(name)
    end
    return names
end

-- One job definition per mechanic job for sky_jobs_base's job registry (shop, props,
-- garage vehicles). /jobconfig workshops use their Config.Jobs entry or the first one.
local function buildJobDefinitions(jobNames)
    local doesJobExist = Sky and Sky.FW and Sky.FW.DoesJobExist
    local firstJob = type(Config.Jobs) == "table" and Config.Jobs[1] or {}
    local definitions = {}

    for _, jobName in ipairs(jobNames) do
        local template = nil
        for _, job in ipairs(Config.Jobs or {}) do
            if type(job) == "table" and job.name == jobName then
                template = job
                break
            end
        end
        -- Workshop display names are published next to the job keys; skip the ones that are no job.
        if template or not doesJobExist or doesJobExist(jobName) == true then
            template = template or firstJob
            definitions[#definitions + 1] = {
                name = jobName,
                label = template.label or jobName,
                color = template.color,
                shop = template.shop,
                props = template.props,
                vehicles = template.vehicles,
                offDutyJob = template.offDutyJob
            }
        end
    end
    return definitions
end

local function registerMechanicAppsWithJobsBase()
    local state = GetResourceState("sky_jobs_base")
    if state ~= "started" and state ~= "starting" then return end

    local finalApps = {}
    local jobNames = getMechanicJobNames()

    for _, app in ipairs(MECHANIC_TABLET_APPS) do
        for _, jobName in ipairs(jobNames) do
            local appCopy = {}
            for k, v in pairs(app) do appCopy[k] = v end
            appCopy.job = jobName
            table.insert(finalApps, appCopy)
        end
    end

    local ok, err = pcall(function()
        exports['sky_jobs_base']:RegisterTabletApps("sky_mechanicjob", finalApps)
    end)
    if not ok then
        Functions.Log("warn", "[tablet_apps] RegisterTabletApps failed: %s", tostring(err))
    end

    ok, err = pcall(function()
        exports['sky_jobs_base']:RegisterJobs(GetCurrentResourceName(), buildJobDefinitions(jobNames))
    end)
    if not ok then
        Functions.Log("warn", "[tablet_apps] RegisterJobs failed: %s", tostring(err))
    end
end

CreateThread(registerMechanicAppsWithJobsBase)

AddEventHandler("sky_jobs_base:server:ready", function()
    registerMechanicAppsWithJobsBase()
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == "sky_jobs_base" then
        registerMechanicAppsWithJobsBase()
    end
end)

-- Server-local event from sky_jobs_base when a workshop job is added or renamed.
AddEventHandler("sky_jobs_base:jobConfigurator:jobNamesUpdated", function(configKey)
    if configKey == "sky_mechanicjob" then
        registerMechanicAppsWithJobsBase()
    end
end)

registerExport("GetMechanicTabletApps", function()
    return MECHANIC_TABLET_APPS
end)
