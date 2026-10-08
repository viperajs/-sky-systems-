if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/creator.lua") end
-- =====================================================
--  sky_jobs_base · source/server/creator.lua
--  Workshop, Station & Jail Creator Server Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}
Sky_Jobs.Creator = Sky_Jobs.Creator or {}

local creatorCache = {}

-- Job resource that owns each creator's locations. Locations of a resource that is not
-- running are not sent to clients.
local OWNER_RESOURCES = {
    jailcreator = "sky_policejob",
    stationcreator = "sky_policejob",
    hospitalcreator = "sky_ambulancejob",
    firecreator = "sky_firejob",
    workshopcreator = "sky_mechanicjob"
}

local WORKSHOP_CREATOR_KEY = "workshopcreator"
local SYNC_COOLDOWN_MS = 2000

-- Lets writers outside this file (the job configurator in jobs.lua) keep getData current.
function Sky_Jobs.Creator.SetCachedData(creatorKey, data)
    if type(creatorKey) == "string" and type(data) == "table" then
        creatorCache[creatorKey] = data
    end
end

local function ensureCreatorTable()
    if MySQL and MySQL.query and MySQL.query.await then
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS `sky_jobs_creator_data` (
                `creator_key` VARCHAR(64) NOT NULL,
                `data` LONGTEXT DEFAULT NULL,
                `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`creator_key`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]])
    end
end

CreateThread(function()
    while not MySQL do
        Wait(500)
    end
    ensureCreatorTable()
end)

-- Creator data as clients use it. The workshop data comes from the job configurator's
-- loader (jobs.lua), which applies the defaults and keeps an emptied workshop list
-- empty; this file used to re-insert the default workshops whenever the list was empty.
local function getCreatorData(creatorKey)
    if creatorCache[creatorKey] then
        return creatorCache[creatorKey]
    end

    local creatorData
    if creatorKey == WORKSHOP_CREATOR_KEY and Sky_Jobs.Configurator and Sky_Jobs.Configurator.LoadWorkshopData then
        creatorData = Sky_Jobs.Configurator.LoadWorkshopData()
    else
        local row = MySQL.single.await("SELECT data FROM sky_jobs_creator_data WHERE creator_key = @key LIMIT 1", {
            ["@key"] = creatorKey
        })
        local decoded = row and row.data and json.decode(row.data) or nil
        creatorData = type(decoded) == "table" and decoded or {}
    end

    if type(creatorData) ~= "table" then
        creatorData = {}
    end
    if type(creatorData.entries) ~= "table" then
        creatorData.entries = {}
    end

    creatorCache[creatorKey] = creatorData
    return creatorData
end

local function isOwnerRunning(creatorKey)
    local owner = OWNER_RESOURCES[creatorKey]
    return owner == nil or GetResourceState(owner) == "started"
end

-- ── Creator Callbacks ─────────────────────────────────

Sky.Cb.Register("sky_jobs_base:creator:getData", function(source, data)
    local creatorKey = tostring(type(data) == "table" and data.creatorKey or WORKSHOP_CREATOR_KEY)

    return {
        success = true,
        data = getCreatorData(creatorKey)
    }
end)

Sky.Cb.Register("sky_jobs_base:creator:saveData", function(source, data)
    if not Sky_Jobs.HasPermission(source, "jobconfig") then
        return { success = false, error = "no_permission" }
    end

    local creatorKey = tostring(type(data) == "table" and data.creatorKey or "")
    local payload = type(data) == "table" and type(data.data) == "table" and data.data or nil

    if creatorKey == "" or not payload then
        return { success = false, error = "invalid_key" }
    end

    -- The workshop data goes through the configurator so its job names and the
    -- mechanic resource are updated as well.
    if creatorKey == WORKSHOP_CREATOR_KEY and Sky_Jobs.Configurator and Sky_Jobs.Configurator.SaveWorkshopData then
        Sky_Jobs.Configurator.SaveWorkshopData(payload)
        return { success = true }
    end

    creatorCache[creatorKey] = payload

    MySQL.query.await([[
        INSERT INTO sky_jobs_creator_data (creator_key, data)
        VALUES (@key, @data)
        ON DUPLICATE KEY UPDATE data = @data
    ]], {
        ["@key"] = creatorKey,
        ["@data"] = json.encode(payload)
    })

    TriggerClientEvent("sky_jobs_base:creatorUpdated", -1, creatorKey, payload)

    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:creator:getPoints", function(source, data)
    local creatorKey = tostring(type(data) == "table" and data.creatorKey or "")
    local current = creatorCache[creatorKey] or {}
    return {
        success = true,
        data = current.points or {}
    }
end)

-- Clients request the creator data when they join and when a job resource starts.
-- Without this handler the locations only reached players who were online while an
-- admin saved them, so after a reconnect or restart none of them appeared.
local lastSyncAt = {}

RegisterNetEvent("sky_jobs_base:creator:requestSync", function(creatorKey)
    local src = source
    local now = GetGameTimer()
    local requestKey = ("%s:%s"):format(tostring(src), tostring(creatorKey or "*"))
    if lastSyncAt[requestKey] and now - lastSyncAt[requestKey] < SYNC_COOLDOWN_MS then
        return
    end
    lastSyncAt[requestKey] = now

    local keys = {}
    if type(creatorKey) == "string" and creatorKey ~= "" then
        keys[1] = creatorKey
    else
        local seen = { [WORKSHOP_CREATOR_KEY] = true }
        keys[1] = WORKSHOP_CREATOR_KEY

        local ok, rows = pcall(function()
            return MySQL.query.await("SELECT creator_key FROM sky_jobs_creator_data")
        end)
        for _, row in ipairs(ok and type(rows) == "table" and rows or {}) do
            local key = row and row.creator_key
            if type(key) == "string" and not seen[key] then
                seen[key] = true
                keys[#keys + 1] = key
            end
        end
    end

    for _, key in ipairs(keys) do
        if isOwnerRunning(key) then
            local ok, creatorData = pcall(getCreatorData, key)
            if ok and type(creatorData) == "table" then
                TriggerClientEvent("sky_jobs_base:creatorUpdated", src, key, creatorData)
            elseif not ok then
                print(("[sky_jobs_base][creator] sync of %s failed: %s"):format(key, tostring(creatorData)))
            end
        end
    end
end)

AddEventHandler("playerDropped", function()
    local prefix = tostring(source) .. ":"
    for key in pairs(lastSyncAt) do
        if key:sub(1, #prefix) == prefix then
            lastSyncAt[key] = nil
        end
    end
end)
