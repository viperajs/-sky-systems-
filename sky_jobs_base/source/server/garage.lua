if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/garage.lua") end
-- =====================================================
--  sky_jobs_base · source/server/garage.lua
--  Job Garage Vehicles & Catalog Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

Sky.Cb.Register("sky_jobs_base:getJobGarageCatalog", function(source, data)
    local job = Sky_Jobs.PlayerCache.GetJob(source)
    local catalog = {}

    if Config and Config.Jobs and Config.Jobs[job] and Config.Jobs[job].garage then
        catalog = Config.Jobs[job].garage
    elseif Config and Config.Garages and Config.Garages[job] then
        catalog = Config.Garages[job]
    end

    return {
        success = true,
        data = catalog
    }
end)

Sky.Cb.Register("sky_jobs_base:getGarageVehicles", function(source, data)
    return {
        success = true,
        data = {}
    }
end)

Sky.Cb.Register("sky_jobs_base:storeGarageVehicle", function(source, data)
    return { success = true }
end)
