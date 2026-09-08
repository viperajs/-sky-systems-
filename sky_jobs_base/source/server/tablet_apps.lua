if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/tablet_apps.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_jobs_base · source/server/tablet_apps.lua
--  Server-Side Tablet Apps Registry & Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}
Sky_Jobs.RegisteredTabletApps = Sky_Jobs.RegisteredTabletApps or {}

--- Register tablet apps from a job resource (e.g. sky_mechanicjob, sky_policejob)
---@param resourceName string
---@param apps table
function Sky_Jobs.RegisterTabletApps(resourceName, apps)
    if type(apps) ~= "table" then return end
    Sky_Jobs.RegisteredTabletApps[resourceName] = apps
end

registerExport("RegisterTabletApps", function(resourceName, apps)
    Sky_Jobs.RegisterTabletApps(resourceName, apps)
end)

-- ── Callbacks for Tablet & NUI ────────────────────────

Sky.Cb.Register("sky_jobs_base:getTabletApps", function(source)
    local src = tonumber(source)
    local playerJob = Sky_Jobs.PlayerCache.GetJob(src)
    local combinedApps = {}
    

    for resName, appsList in pairs(Sky_Jobs.RegisteredTabletApps) do
        if type(appsList) == "table" then
            for _, app in ipairs(appsList) do
                if not app.job or app.job == playerJob or app.job == "all" then
                    combinedApps[#combinedApps + 1] = app
                end
            end
        end
    end

    return {
        success = true,
        data = combinedApps
    }
end)

Sky.Cb.Register("sky_jobs_base:getNuiImageBases", function(source)
    return {
        vehicleImages = "nui://sky_mechanicjob/config/img/",
        appIcons = "nui://sky_jobs_base/source/html/assets/icons/"
    }
end)

Sky.Cb.Register("sky_jobs_base:tablet:hasRequiredItem", function(source)
    local tabletCfg = Config and Config.Tablet or {}
    if tabletCfg.requireItem ~= true then return true end

    local itemName = tabletCfg.item or "tablet"
    if Functions and Functions.HasItem then
        return Functions.HasItem(source, itemName, 1)
    end
    return true
end)
