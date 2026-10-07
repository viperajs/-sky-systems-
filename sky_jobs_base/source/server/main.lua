if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/main.lua") end
-- =====================================================
--  sky_jobs_base · source/server/main.lua
--  Core Server Callbacks & Duty Synchronization
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

-- ── Duty & Job Info Callbacks ─────────────────────────

Sky.Cb.Register("sky_jobs_base:getPlayersWithNames", function(source)
    local players = {}
    for _, srcStr in ipairs(GetPlayers()) do
        local src = tonumber(srcStr)
        if src then
            local name = Functions and Functions.GetName and Functions.GetName(src) or GetPlayerName(src)
            players[#players + 1] = {
                source = src,
                name = name,
                job = Sky_Jobs.PlayerCache.GetJob(src)
            }
        end
    end
    return players
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

Sky.Cb.Register("sky_jobs_base:gallery:getPhotos", function(source, data)
    data = type(data) == "table" and data or {}
    local limit = math.max(1, math.min(200, math.floor(tonumber(data.limit) or 80)))

    local rows = {}
    local ok = pcall(function()
        rows = MySQL.query.await([[
            SELECT id, url, folder, image_id, created_at
            FROM sky_jobs_gallery_photos
            ORDER BY created_at DESC
            LIMIT ]] .. tostring(limit)) or {}
    end)

    if not ok then
        rows = {}
    end

    return {
        success = true,
        data = rows
    }
end)

Sky.Cb.Register("sky_jobs_base:gallery:getPresignedUrl", function(source, data)
    return { success = true, data = {} }
end)

Sky.Cb.Register("sky_jobs_base:gallery:deletePhoto", function(source, data)
    return { success = true, data = {} }
end)

Sky.Cb.Register("sky_jobs_base:gallery:addPhoto", function(source, data)
    return { success = true, data = type(data) == "table" and data or {} }
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
