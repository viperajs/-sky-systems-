if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/main.lua") end
-- =====================================================
--  sky_jobs_base · source/server/main.lua
--  Core Server Callbacks & Duty Synchronization
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

-- ── Duty & Job Info Callbacks ─────────────────────────

-- Invite picker: online players with a loaded character outside the caller's job.
Sky.Cb.Register("sky_jobs_base:getPlayersWithNames", function(source)
    local src = tonumber(source)
    local job = Sky_Jobs.GetEmployment(src)
    if not job or not Sky_Jobs.HasJobPermission(src, "MANAGE_MEMBERS") then
        return { success = false, error = "no_permission" }
    end

    local players = {}
    for _, srcStr in ipairs(GetPlayers()) do
        local p = tonumber(srcStr)
        if p and p ~= src and Sky_Jobs.GetPlayerIdentifier(p) and Sky_Jobs.PlayerCache.GetJob(p) ~= job then
            players[#players + 1] = {
                id = p,
                source = p,
                name = ("%s (%d)"):format(Sky_Jobs.GetPlayerFullName(p), p)
            }
        end
    end
    table.sort(players, function(a, b) return a.name < b.name end)
    return { success = true, data = players }
end)

Sky.Cb.Register("sky_jobs_base:getJobInfo", function(source)
    local jobName = Sky_Jobs.PlayerCache.GetJob(source)
    return {
        job = jobName,
        onDuty = Sky_Jobs.PlayerCache.IsOnDuty(source)
    }
end)

Sky.Cb.Register("sky_jobs_base:duty:getSnapshot", function(source, stationName)
    local jobName = Sky_Jobs.PlayerCache.GetJob(source)
    stationName = type(stationName) == "string" and stationName or nil
    return {
        success = true,
        data = {
            onDuty = Sky_Jobs.PlayerCache.IsOnDuty(source),
            job = jobName,
            jobKey = jobName,
            station = stationName,
            -- The duty card shows data.stationName.
            stationName = stationName
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:duty:set", function(source, data)
    local jobName = Sky_Jobs.PlayerCache.GetJob(source)
    if Config and Config.DutySystem == false then
        return { success = false, error = "duty_disabled" }
    end
    if Sky_Jobs.IsUnemployedJob and Sky_Jobs.IsUnemployedJob(jobName) then
        return { success = false, error = "no_job" }
    end

    local onDuty = type(data) == "table" and data.onDuty == true
    -- Also sets the framework's duty (Sky.FW.SetDuty), so other scripts agree.
    Sky_Jobs.PlayerCache.SetDuty(source, onDuty)

    return {
        success = true,
        data = {
            onDuty = Sky_Jobs.PlayerCache.IsOnDuty(source),
            jobKey = jobName
        }
    }
end)

-- ── Gallery & Creator Callbacks ───────────────────────

-- Each job has one gallery (sky_jobs_gallery_photos); uploads go to presigned URLs from the
-- provider in Config.Uploads (helpers in jobs.lua).
Sky.Cb.Register("sky_jobs_base:gallery:getPhotos", function(source, data)
    local job, err = Sky_Jobs.Uploads.Authorize(source)
    if not job then return { success = false, error = err } end
    data = type(data) == "table" and data or {}
    local photos, loadErr = Sky_Jobs.Gallery.List(job, data.limit, data.offset)
    if not photos then return { success = false, error = loadErr } end
    return { success = true, data = photos }
end)

Sky.Cb.Register("sky_jobs_base:gallery:getPresignedUrl", function(source, data)
    local fileType = type(data) == "table" and data.fileType == "video" and "video" or "image"
    local job, err = Sky_Jobs.Uploads.Authorize(source, fileType == "video")
    if not job then return { success = false, error = err } end
    if Sky_Jobs.Gallery.IsFull(job) then return { success = false, error = "gallery_full" } end
    local presignedUrl, presignErr = Sky_Jobs.Uploads.PresignFor(source, fileType)
    if not presignedUrl then return { success = false, error = presignErr } end
    return { success = true, data = { presignedUrl = presignedUrl } }
end)

Sky.Cb.Register("sky_jobs_base:gallery:addPhoto", function(source, data)
    local job, err = Sky_Jobs.Uploads.Authorize(source)
    if not job then return { success = false, error = err } end
    data = type(data) == "table" and data or {}
    if not Sky_Jobs.Uploads.IsAllowedUrl(data.url) then return { success = false, error = "invalid_url" } end
    if not Sky_Jobs.Uploads.ConsumeCredit(source) then return { success = false, error = "not_authorized" } end
    local photo, addErr = Sky_Jobs.Gallery.Add(source, job, {
        url = data.url,
        image_id = data.image_id,
        folder = data.folder
    })
    if not photo then return { success = false, error = addErr } end
    return { success = true, data = photo }
end)

Sky.Cb.Register("sky_jobs_base:gallery:deletePhoto", function(source, data)
    local job, err = Sky_Jobs.Uploads.Authorize(source)
    if not job then return { success = false, error = err } end
    local ok, deleteErr = Sky_Jobs.Gallery.Delete(job, type(data) == "table" and data.id or nil)
    if not ok then return { success = false, error = deleteErr } end
    return { success = true }
end)

CreateThread(function()
    Wait(500)
    TriggerEvent("sky_jobs_base:server:ready")
end)

-- Both commands open the job configurator, which edits every workshop. They were open to
-- every player; the jobconfig permission (Config.CommandPermissions) is required now.
local function openJobConfigurator(source, args)
    local src = tonumber(source)
    if not src or src <= 0 then
        print("[sky_jobs_base] /jobconfig can only be used in game.")
        return
    end

    if not Sky_Jobs.HasPermission(src, "jobconfig") then
        TriggerClientEvent("sky_base:notification", src, "Job Configurator", "You do not have permission to use this command.", "error", 5000)
        return
    end

    local configKey = (type(args) == "table" and args[1]) or "sky_mechanicjob"
    TriggerClientEvent("sky_jobs_base:jobConfigurator:openCmd", src, configKey)
end

RegisterCommand("jobconfig", openJobConfigurator, false)
RegisterCommand("jobcreator", openJobConfigurator, false)
