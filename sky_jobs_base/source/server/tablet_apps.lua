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
    if type(resourceName) ~= "string" or resourceName == "" or type(apps) ~= "table" then return end
    Sky_Jobs.RegisteredTabletApps[resourceName] = apps
end

registerExport("RegisterTabletApps", function(resourceName, apps)
    Sky_Jobs.RegisterTabletApps(resourceName, apps)
end)

-- Apps of a stopped resource would otherwise stay on every tablet.
AddEventHandler("onResourceStop", function(resourceName)
    Sky_Jobs.RegisteredTabletApps[resourceName] = nil
end)

--- Server-side item count (ox_inventory on Qbox, qb-inventory otherwise); 0 when it cannot be read.
---@param source number
---@param itemName string
---@return number
function Sky_Jobs.GetInventoryItemCount(source, itemName)
    local src = tonumber(source)
    if not src or type(itemName) ~= "string" or itemName == "" then return 0 end

    local inventory = (GetResourceState("ox_inventory") == "started" and "ox_inventory")
        or (GetResourceState("qb-inventory") == "started" and "qb-inventory")
    if not inventory then return 0 end

    local ok, count = pcall(function()
        return exports[inventory]:GetItemCount(src, itemName)
    end)
    return ok and tonumber(count) or 0
end

-- ── Callbacks for Tablet & NUI ────────────────────────

Sky.Cb.Register("sky_jobs_base:getTabletApps", function(source)
    local src = tonumber(source)
    local playerJob = Sky_Jobs.PlayerCache.GetJob(src)
    local combinedApps = {}

    for resName, appsList in pairs(Sky_Jobs.RegisteredTabletApps) do
        if type(appsList) == "table" then
            for _, app in ipairs(appsList) do
                if type(app) == "table" and (not app.job or app.job == playerJob or app.job == "all") then
                    -- The radial menu asks the owning resource for its job actions.
                    local entry = { resource = resName }
                    for k, v in pairs(app) do entry[k] = v end
                    combinedApps[#combinedApps + 1] = entry
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

    local itemName = (type(tabletCfg.item) == "string" and tabletCfg.item ~= "") and tabletCfg.item or "tablet"
    return Sky_Jobs.GetInventoryItemCount(source, itemName) > 0
end)
