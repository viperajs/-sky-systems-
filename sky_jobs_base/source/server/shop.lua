if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/shop.lua") end
-- =====================================================
--  sky_jobs_base · source/server/shop.lua
--  Wholesale Shop, Public Forms, Multijob & CCTV Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

-- ── Wholesale Shop ────────────────────────────────────

Sky.Cb.Register("sky_jobs_base:getWholesaleShopData", function(source, stationId)
    local job = Sky_Jobs.PlayerCache.GetJob(source)
    local items = (Config and Config.Jobs and Config.Jobs[job] and Config.Jobs[job].shop) or {}

    return {
        success = true,
        data = {
            items = items
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:buyWholesaleItems", function(source, stationId, items)
    return { success = true }
end)

-- ── Public Forms Callbacks ────────────────────────────

Sky.Cb.Register("sky_jobs_base:publicForms:submit", function(source, data)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:getAll", function(source)
    return { success = true, data = {} }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:updateStatus", function(source, data)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:getNotes", function(source, data)
    return { success = true, data = {} }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:addNote", function(source, data)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:getMyForms", function(source, data)
    return { success = true, data = {} }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:getMyNotes", function(source, data)
    return { success = true, data = {} }
end)

-- ── Multijob Callbacks ────────────────────────────────

Sky.Cb.Register("sky_jobs_base:multijob:getSnapshot", function(source, data)
    local job = Sky_Jobs.PlayerCache.GetJob(source)
    return {
        success = true,
        data = {
            currentJob = job,
            jobs = {
                { name = job, label = job, grade = Sky_Jobs.PlayerCache.GetJobGrade(source), onDuty = Sky_Jobs.PlayerCache.IsOnDuty(source) }
            }
        }
    }
end)

-- ── Alerts, CCTV & Bodycam Callbacks ─────────────────

Sky.Cb.Register("sky_jobs_base:alerts:getActive", function(source)
    return {
        success = true,
        data = {}
    }
end)

Sky.Cb.Register("sky_jobs_base:cctv:getCameras", function(source)
    return {
        success = true,
        data = {}
    }
end)

Sky.Cb.Register("sky_jobs_base:bodycam:getRecordings", function(source)
    return {
        success = true,
        data = {}
    }
end)
