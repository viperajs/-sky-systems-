if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/jobs.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_jobs_base · source/server/jobs.lua
--  Player Duty Tracking, Job Cache & Core Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}
Sky_Jobs.PlayerCache = Sky_Jobs.PlayerCache or {}
Sky_Jobs.Access = Sky_Jobs.Access or {}

-- -----------------------------------------------------
--  Universal MySQL Bridge & Polyfill
-- -----------------------------------------------------
if not MySQL or type(MySQL) ~= "table" or not MySQL.query then
    MySQL = MySQL or {}
    local ox = GetResourceState("oxmysql") == "started" and exports.oxmysql or nil
    local ma = GetResourceState("mysql-async") == "started" and exports['mysql-async'] or nil

    if not MySQL.query then
        MySQL.query = {
            await = function(query, params)
                if exports.oxmysql and exports.oxmysql.query_async then
                    return exports.oxmysql:query_async(query, params)
                elseif exports.oxmysql and exports.oxmysql.query then
                    return exports.oxmysql:query(query, params)
                elseif MySQL.Async and MySQL.Async.fetchAll then
                    local p = promise.new()
                    MySQL.Async.fetchAll(query, params or {}, function(res) p:resolve(res) end)
                    return Citizen.Await(p)
                end
                return {}
            end
        }
    end

    if not MySQL.single then
        MySQL.single = {
            await = function(query, params)
                if exports.oxmysql and exports.oxmysql.single_async then
                    return exports.oxmysql:single_async(query, params)
                elseif exports.oxmysql and exports.oxmysql.single then
                    return exports.oxmysql:single(query, params)
                end
                local res = MySQL.query.await(query, params)
                return res and res[1] or nil
            end
        }
    end

    if not MySQL.insert then
        MySQL.insert = {
            await = function(query, params)
                if exports.oxmysql and exports.oxmysql.insert_async then
                    return exports.oxmysql:insert_async(query, params)
                elseif exports.oxmysql and exports.oxmysql.insert then
                    return exports.oxmysql:insert(query, params)
                elseif MySQL.Async and MySQL.Async.insert then
                    local p = promise.new()
                    MySQL.Async.insert(query, params or {}, function(id) p:resolve(id) end)
                    return Citizen.Await(p)
                end
                return 1
            end
        }
    end
end

local playerDutyState = {}
local playerJobCache = {}

-- -----------------------------------------------------
--  EXPORTS & PUBLIC INTERFACE
-- -----------------------------------------------------
registerExport("Get", function()
    return Sky_Jobs
end)

function Sky_Jobs.PlayerCache.IsOnDuty(source)
    local src = tonumber(source)
    if not src or src <= 0 then return true end

    if playerDutyState[src] ~= nil then
        return playerDutyState[src] == true
    end

    if Sky and Sky.FW and Sky.FW.GetJobData then
        local duty = Sky.FW.GetJobData(src, "duty")
        if duty ~= nil then return duty == true end
    end

    return true
end

function Sky_Jobs.PlayerCache.SetDuty(source, onDuty)
    local src = tonumber(source)
    if not src or src <= 0 then return end
    playerDutyState[src] = (onDuty == true)
end

function Sky_Jobs.PlayerCache.GetJob(source)
    local src = tonumber(source)
    if not src or src <= 0 then return "" end

    if Sky and Sky.FW and Sky.FW.GetJob then
        local job = Sky.FW.GetJob(src)
        if job and job ~= "" then return job end
    end

    return playerJobCache[src] or "unemployed"
end

function Sky_Jobs.PlayerCache.GetJobGrade(source)
    local src = tonumber(source)
    if not src or src <= 0 then return 0 end

    if Sky and Sky.FW and Sky.FW.GetJobData then
        local grade = Sky.FW.GetJobData(src, "grade")
        if grade ~= nil then return tonumber(grade) or 0 end
    end

    return 0
end

function Sky_Jobs.PlayerCache.UpdateJob(source, jobName)
    local src = tonumber(source)
    if not src or src <= 0 then return end
    playerJobCache[src] = tostring(jobName or "")
end

function Sky_Jobs.GetOnDutyCount(jobName)
    if not jobName or jobName == "" then return 0 end
    local count = 0
    for _, srcStr in ipairs(GetPlayers()) do
        local src = tonumber(srcStr)
        if src and Sky_Jobs.PlayerCache.GetJob(src) == jobName and Sky_Jobs.PlayerCache.IsOnDuty(src) then
            count = count + 1
        end
    end
    return count
end

Sky_Jobs.Access.IsOnDuty = function(source)
    return Sky_Jobs.PlayerCache.IsOnDuty(source)
end

AddEventHandler("playerDropped", function()
    local src = source
    playerDutyState[src] = nil
    playerJobCache[src] = nil
end)

-- -----------------------------------------------------
--  CORE JOB & ACCESS SERVER CALLBACKS
-- -----------------------------------------------------

Sky.Cb.Register("sky_jobs_base:creator:getPlayerJob", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, data = { ready = false } } end

    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    local gradeLevel = Sky_Jobs.PlayerCache.GetJobGrade(src)

    local isBoss = false
    if Sky and Sky.FW and Sky.FW.IsPlayerBoss then
        isBoss = Sky.FW.IsPlayerBoss(src) == true
    else
        isBoss = (gradeLevel >= 4)
    end

    return {
        success = true,
        data = {
            ready = true,
            jobKey = jobName,
            job = jobName,
            grade = gradeLevel,
            isBoss = isBoss
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:creator:getPlayerDuty", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, data = { ready = false } } end

    local isOnDuty = Sky_Jobs.PlayerCache.IsOnDuty(src)
    local jobName = Sky_Jobs.PlayerCache.GetJob(src)

    return {
        success = true,
        data = {
            ready = true,
            onDuty = isOnDuty,
            jobKey = jobName
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:getRegisteredJobs", function(source)
    local jobs = {}

    if Config and Config.Jobs then
        for k, v in pairs(Config.Jobs) do
            local jobKey = type(k) == "string" and k or (v.name or tostring(k))
            jobs[jobKey] = {
                name = v.name or jobKey,
                label = v.label or jobKey,
                color = v.color or "#ff9800",
                icon = v.icon or "briefcase"
            }
        end
    end

    -- Default fallback if empty
    if not next(jobs) then
        jobs = {
            mechanic = { name = "mechanic", label = "Mechanic", color = "#ff9800", icon = "wrench" },
            police = { name = "police", label = "Police", color = "#2196f3", icon = "shield" },
            ambulance = { name = "ambulance", label = "EMS", color = "#f44336", icon = "heart-pulse" },
            fire = { name = "fire", label = "Fire", color = "#e91e63", icon = "fire-extinguisher" }
        }
    end

    return jobs
end)

Sky.Cb.Register("sky_jobs_base:getJobColor", function(source)
    local job = Sky_Jobs.PlayerCache.GetJob(source)
    if Config and Config.Jobs and Config.Jobs[job] and Config.Jobs[job].color then
        return Config.Jobs[job].color
    end
    return "#ff9800"
end)

Sky.Cb.Register("sky_jobs_base:getJobColorFor", function(source, data)
    local jobKey = data and data.jobKey or Sky_Jobs.PlayerCache.GetJob(source)
    if Config and Config.Jobs and Config.Jobs[jobKey] and Config.Jobs[jobKey].color then
        return Config.Jobs[jobKey].color
    end
    return "#ff9800"
end)

Sky.Cb.Register("sky_jobs_base:getJobBackgroundPath", function(source)
    return "assets/img/backgrounds/default.png"
end)

Sky.Cb.Register("sky_jobs_base:getOnDutyJobFor", function(source, data)
    local src = tonumber(source)
    if not src then
        return { success = false, data = { ready = false } }
    end

    local requestedJob = (type(data) == "table" and data.jobKey) or nil
    local currentJob = Sky_Jobs.PlayerCache.GetJob(src)
    local isOnDuty = Sky_Jobs.PlayerCache.IsOnDuty(src)

    local activeDutyJob = nil
    if isOnDuty and currentJob and currentJob ~= "" and currentJob ~= "unemployed" then
        if not requestedJob or requestedJob == currentJob then
            activeDutyJob = currentJob
        end
    end

    return {
        success = true,
        data = {
            ready = true,
            jobKey = activeDutyJob,
            onDuty = (activeDutyJob ~= nil)
        }
    }
end)

-- -----------------------------------------------------
--  TABLET, CHAT & CALENDAR CALLBACKS
-- -----------------------------------------------------

-- -----------------------------------------------------
--  DATABASE SCHEMA ENSURANCE FOR JOBS BASE
-- -----------------------------------------------------

local function ensureJobsBaseTables()
    if not (MySQL and MySQL.query and MySQL.query.await) then return end

    local jobTables = {
        [[
            CREATE TABLE IF NOT EXISTS `sky_jobs_finances` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `job` VARCHAR(50) NOT NULL,
                `balance` INT DEFAULT 0,
                `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY `uk_job` (`job`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_jobs_transactions` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `job` VARCHAR(50) NOT NULL,
                `type` VARCHAR(20) NOT NULL,
                `amount` INT NOT NULL,
                `sender` VARCHAR(100) DEFAULT NULL,
                `reason` TEXT DEFAULT NULL,
                `date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_job` (`job`),
                INDEX `idx_date` (`date`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_jobs_chat_messages` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `chat_id` VARCHAR(64) NOT NULL,
                `sender_identifier` VARCHAR(64) DEFAULT NULL,
                `sender_name` VARCHAR(100) NOT NULL,
                `message` TEXT NOT NULL,
                `timestamp` BIGINT NOT NULL,
                INDEX `idx_chat` (`chat_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_jobs_chat_groups` (
                `id` VARCHAR(64) NOT NULL PRIMARY KEY,
                `job` VARCHAR(50) NOT NULL,
                `name` VARCHAR(100) NOT NULL,
                `created_by` VARCHAR(64) DEFAULT NULL,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_job` (`job`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_jobs_calendar_events` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `job` VARCHAR(50) NOT NULL,
                `title` VARCHAR(150) NOT NULL,
                `description` TEXT DEFAULT NULL,
                `date` VARCHAR(50) NOT NULL,
                `time` VARCHAR(20) DEFAULT NULL,
                `created_by` VARCHAR(64) DEFAULT NULL,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_job` (`job`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]]
    }

    for _, q in ipairs(jobTables) do
        pcall(function() MySQL.query.await(q) end)
    end
end

CreateThread(function()
    while not MySQL do
        Wait(500)
    end
    ensureJobsBaseTables()
end)

-- -----------------------------------------------------
--  FRAMEWORK & DATA HELPERS
-- -----------------------------------------------------

local function GetPlayerIdentifierStr(source)
    local src = tonumber(source)
    if not src then return "" end
    if Sky and Sky.FW and Sky.FW.GetIdentifier then
        local id = Sky.FW.GetIdentifier(src)
        if id and id ~= "" then return tostring(id) end
    end
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(id, "license:") or string.find(id, "steam:") then
            return id
        end
    end
    return "player:" .. tostring(src)
end

local function GetPlayerFullName(source)
    local src = tonumber(source)
    if not src then return "Unknown" end
    if Sky and Sky.FW and Sky.FW.GetName then
        local name = Sky.FW.GetName(src)
        if name and name ~= "" then return tostring(name) end
    end
    return GetPlayerName(src) or ("Player " .. tostring(src))
end

local function AddPlayerMoney(source, account, amount)
    local src = tonumber(source)
    if not src or amount <= 0 then return false end
    if Sky and Sky.FW and Sky.FW.AddAccountMoney then
        return Sky.FW.AddAccountMoney(src, account or "money", amount) ~= false
    end
    return true
end

local function RemovePlayerMoney(source, account, amount)
    local src = tonumber(source)
    if not src or amount <= 0 then return false end
    if Sky and Sky.FW and Sky.FW.RemoveAccountMoney then
        return Sky.FW.RemoveAccountMoney(src, account or "money", amount) == true
    end
    return true
end

local function SetPlayerJob(source, job, grade)
    local src = tonumber(source)
    if not src then return false end
    if Sky and Sky.FW and Sky.FW.SetJob then
        Sky.FW.SetJob(src, job, grade or 0)
    end
    Sky_Jobs.PlayerCache.UpdateJob(src, job)
    return true
end

local function getSocietyBalance(jobName)
    if not jobName or jobName == "" then jobName = "mechanic" end
    local row = MySQL.single.await("SELECT balance FROM sky_jobs_finances WHERE job = @job LIMIT 1", {
        ["@job"] = jobName
    })
    if row and row.balance ~= nil then
        return tonumber(row.balance) or 0
    end
    pcall(function()
        MySQL.insert.await("INSERT INTO sky_jobs_finances (job, balance) VALUES (@job, @balance) ON DUPLICATE KEY UPDATE balance = balance", {
            ["@job"] = jobName,
            ["@balance"] = 10000
        })
    end)
    return 10000
end

local function updateSocietyBalance(jobName, newBalance)
    if not jobName or jobName == "" then jobName = "mechanic" end
    pcall(function()
        MySQL.query.await([[
            INSERT INTO sky_jobs_finances (job, balance) VALUES (@job, @balance)
            ON DUPLICATE KEY UPDATE balance = @balance
        ]], {
            ["@job"] = jobName,
            ["@balance"] = math.max(0, math.floor(newBalance))
        })
    end)
end

local function addJobTransaction(jobName, transType, amount, senderName, reason)
    if not jobName or jobName == "" then jobName = "mechanic" end
    pcall(function()
        MySQL.insert.await([[
            INSERT INTO sky_jobs_transactions (job, type, amount, sender, reason)
            VALUES (@job, @type, @amount, @sender, @reason)
        ]], {
            ["@job"] = jobName,
            ["@type"] = transType,
            ["@amount"] = amount,
            ["@sender"] = senderName or "Unknown",
            ["@reason"] = reason or transType
        })
    end)
end

-- -----------------------------------------------------
--  TABLET APPS & RESTRICTIONS
-- -----------------------------------------------------

Sky.Cb.Register("sky_jobs_base:getPlayerRestrictedTabletApps", function(source)
    local src = tonumber(source)
    local playerJob = Sky_Jobs.PlayerCache.GetJob(src)
    local combinedApps = {}

    for _, appsList in pairs(Sky_Jobs.RegisteredTabletApps) do
        if type(appsList) == "table" then
            for _, app in ipairs(appsList) do
                if not app.job or app.job == playerJob or app.job == "all" then
                    combinedApps[#combinedApps + 1] = app
                end
            end
        end
    end

    return { success = true, data = combinedApps }
end)

Sky.Cb.Register("sky_jobs_base:getPlayerRestrictedDocumentClassifications", function(source)
    return { success = true, data = { "unclassified", "restricted", "confidential", "secret", "top_secret" } }
end)

Sky.Cb.Register("sky_jobs_base:chat:getUnreadMessages", function(source)
    local src = tonumber(source)
    local identifier = tostring(src)
    if Sky and Sky.FW and Sky.FW.GetIdentifier then
        identifier = Sky.FW.GetIdentifier(src)
    elseif Functions and Functions.GetIdentifier then
        identifier = Functions.GetIdentifier(src)
    end
    return { success = true, data = { count = 0, messages = {} } }
end)

local function resolveChatId(payload)
    if type(payload) == "string" and payload ~= "" then
        return payload
    end
    if type(payload) ~= "table" then
        return "general"
    end
    if payload.chatId and tostring(payload.chatId) ~= "" then
        return tostring(payload.chatId)
    end
    if payload.group_id or payload.groupId or payload.group then
        return tostring(payload.group_id or payload.groupId or payload.group)
    end
    if payload.target and tostring(payload.target) ~= "" then
        return tostring(payload.target)
    end
    if payload.scope and tostring(payload.scope) ~= "" then
        return tostring(payload.scope)
    end
    return "general"
end

Sky.Cb.Register("sky_jobs_base:chat:getOpenChats", function(source)
    local src = tonumber(source)
    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    if not jobName or jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    local groups = MySQL.query.await("SELECT id, name, created_by, created_at FROM sky_jobs_chat_groups WHERE job = @job", {
        ["@job"] = jobName
    }) or {}

    local defaultChats = {
        { id = "general", name = "Job Team Chat", members = {} }
    }
    for _, g in ipairs(groups) do
        table.insert(defaultChats, {
            id = g.id,
            name = g.name,
            members = {}
        })
    end

    return {
        success = true,
        data = defaultChats
    }
end)

Sky.Cb.Register("sky_jobs_base:chat:getMessages", function(source, payload)
    local chatId = resolveChatId(payload)
    local limit = 100
    if type(payload) == "table" and tonumber(payload.limit) then
        limit = math.max(1, math.min(500, math.floor(tonumber(payload.limit))))
    end

    local rows = MySQL.query.await([[
        SELECT id, chat_id, sender_name AS sender, message, timestamp
        FROM sky_jobs_chat_messages
        WHERE chat_id = @chat_id
        ORDER BY timestamp ASC LIMIT ]] .. tostring(limit), {
        ["@chat_id"] = chatId
    }) or {}

    return {
        success = true,
        data = rows
    }
end)

Sky.Cb.Register("sky_jobs_base:chat:sendMessage", function(source, data)
    local src = tonumber(source)
    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    if not jobName or jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    local chatId = resolveChatId(data)
    local messageText = (type(data) == "table" and (data.message or data.text)) or tostring(data or "")
    local senderName = GetPlayerFullName(src)
    local senderId = GetPlayerIdentifierStr(src)
    local nowTime = os.time()

    local msgId = MySQL.insert.await([[
        INSERT INTO sky_jobs_chat_messages (chat_id, sender_identifier, sender_name, message, timestamp)
        VALUES (@chat_id, @sender_identifier, @sender_name, @message, @timestamp)
    ]], {
        ["@chat_id"] = chatId,
        ["@sender_identifier"] = senderId,
        ["@sender_name"] = senderName,
        ["@message"] = messageText,
        ["@timestamp"] = nowTime
    })

    local msgObj = {
        id = tostring(msgId or GetGameTimer()),
        chatId = chatId,
        sender = senderName,
        sender_name = senderName,
        message = messageText,
        timestamp = nowTime
    }

    for _, s in ipairs(GetPlayers()) do
        local p = tonumber(s)
        if p and Sky_Jobs.PlayerCache.GetJob(p) == jobName then
            TriggerClientEvent("sky_jobs_base:chat:messageReceived", p, msgObj)
        end
    end

    return {
        success = true,
        data = msgObj
    }
end)

Sky.Cb.Register("sky_jobs_base:chat:createGroup", function(source, data)
    local src = tonumber(source)
    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    if not jobName or jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    local groupName = (type(data) == "table" and data.name) or "New Group"
    local groupId = "group_" .. tostring(GetGameTimer())
    local senderId = GetPlayerIdentifierStr(src)

    MySQL.insert.await([[
        INSERT INTO sky_jobs_chat_groups (id, job, name, created_by)
        VALUES (@id, @job, @name, @created_by)
    ]], {
        ["@id"] = groupId,
        ["@job"] = jobName,
        ["@name"] = groupName,
        ["@created_by"] = senderId
    })

    return {
        success = true,
        data = {
            id = groupId,
            name = groupName,
            members = {}
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:chat:getGroups", function(source)
    local src = tonumber(source)
    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    if not jobName or jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    local groups = MySQL.query.await("SELECT id, name, created_by, created_at FROM sky_jobs_chat_groups WHERE job = @job", {
        ["@job"] = jobName
    }) or {}

    return { success = true, data = groups }
end)

Sky.Cb.Register("sky_jobs_base:chat:getGroup", function(source, groupId)
    groupId = resolveChatId(groupId)
    local row = MySQL.single.await("SELECT id, name, created_by, created_at FROM sky_jobs_chat_groups WHERE id = @id LIMIT 1", {
        ["@id"] = groupId
    })
    return { success = row ~= nil, data = row or {} }
end)

Sky.Cb.Register("sky_jobs_base:chat:updateGroup", function(source, data)
    if type(data) ~= "table" then return { success = false } end
    local groupId = resolveChatId(data)
    if groupId == "general" then return { success = false, error = "invalid_group" } end
    MySQL.update.await("UPDATE sky_jobs_chat_groups SET name = @name WHERE id = @id", {
        ["@id"] = groupId,
        ["@name"] = tostring(data.name or "Group")
    })
    return { success = true, data = { id = groupId, name = data.name } }
end)

Sky.Cb.Register("sky_jobs_base:chat:setGroupMembers", function(source, data)
    return { success = true, data = type(data) == "table" and data or {} }
end)

Sky.Cb.Register("sky_jobs_base:chat:setGroupOwner", function(source, data)
    return { success = true, data = type(data) == "table" and data or {} }
end)

Sky.Cb.Register("sky_jobs_base:chat:removeGroupAdmin", function(source, data)
    return { success = true, data = type(data) == "table" and data or {} }
end)

Sky.Cb.Register("sky_jobs_base:chat:deleteGroup", function(source, data)
    local groupId = resolveChatId(data)
    if groupId == "general" then return { success = false, error = "invalid_group" } end
    MySQL.query.await("DELETE FROM sky_jobs_chat_groups WHERE id = @id", { ["@id"] = groupId })
    MySQL.query.await("DELETE FROM sky_jobs_chat_messages WHERE chat_id = @id", { ["@id"] = groupId })
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:chat:leaveGroup", function(source, data)
    return { success = true, data = type(data) == "table" and data or {} }
end)

Sky.Cb.Register("sky_jobs_base:chat:setProfilePhoto", function(source, data)
    return { success = true, data = type(data) == "table" and data or {} }
end)

-- -----------------------------------------------------
--  CALENDAR
-- -----------------------------------------------------

Sky.Cb.Register("sky_jobs_base:calendar:addEvent", function(source, data)
    local src = tonumber(source)
    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    if not jobName or jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    if type(data) == "table" then
        MySQL.insert.await([[
            INSERT INTO sky_jobs_calendar_events (job, title, description, date, time, created_by)
            VALUES (@job, @title, @description, @date, @time, @created_by)
        ]], {
            ["@job"] = jobName,
            ["@title"] = tostring(data.title or "Event"),
            ["@description"] = tostring(data.description or ""),
            ["@date"] = tostring(data.date or os.date("%Y-%m-%d")),
            ["@time"] = tostring(data.time or "12:00"),
            ["@created_by"] = GetPlayerFullName(src)
        })
    end

    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:calendar:getEvents", function(source)
    local src = tonumber(source)
    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    if not jobName or jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    local rows = MySQL.query.await("SELECT * FROM sky_jobs_calendar_events WHERE job = @job ORDER BY id DESC LIMIT 50", {
        ["@job"] = jobName
    }) or {}

    return {
        success = true,
        data = rows
    }
end)

-- -----------------------------------------------------
--  MANAGEMENT & MEMBERS CALLBACKS
-- -----------------------------------------------------

Sky.Cb.Register("sky_jobs_base:getJobData", function(source)
    local src = tonumber(source)
    local job = Sky_Jobs.PlayerCache.GetJob(src)
    local grade = Sky_Jobs.PlayerCache.GetJobGrade(src)
    return {
        success = true,
        data = {
            name = job,
            label = job ~= "" and (job:gsub("^%l", string.upper)) or "Unemployed",
            grade = grade,
            grade_name = tostring(grade),
            grade_label = "Grade " .. tostring(grade),
            grades = {
                { grade = 0, name = "Trainee", label = "Trainee" },
                { grade = 1, name = "Junior", label = "Junior" },
                { grade = 2, name = "Technician", label = "Technician" },
                { grade = 3, name = "Specialist", label = "Specialist" },
                { grade = 4, name = "Manager", label = "Manager" },
                { grade = 5, name = "Boss", label = "Boss" }
            }
        }
    }
end)

local function fetchOnlineJobMembers(source)
    local src = tonumber(source)
    local myJob = Sky_Jobs.PlayerCache.GetJob(src)
    if not myJob or myJob == "" or myJob == "unemployed" then myJob = "mechanic" end

    local members = {}
    for _, srcStr in ipairs(GetPlayers()) do
        local pSrc = tonumber(srcStr)
        if pSrc then
            local pJob = Sky_Jobs.PlayerCache.GetJob(pSrc)
            if pJob == myJob or (myJob == "mechanic" and pJob == "unemployed") or pSrc == src then
                local pName = GetPlayerFullName(pSrc)
                table.insert(members, {
                    source = pSrc,
                    identifier = GetPlayerIdentifierStr(pSrc),
                    name = pName,
                    job = myJob,
                    grade = Sky_Jobs.PlayerCache.GetJobGrade(pSrc),
                    grade_label = "Grade " .. tostring(Sky_Jobs.PlayerCache.GetJobGrade(pSrc)),
                    onDuty = Sky_Jobs.PlayerCache.IsOnDuty(pSrc),
                    isOnline = true
                })
            end
        end
    end
    return members
end

Sky.Cb.Register("sky_jobs_base:getJobMembers", function(source)
    return fetchOnlineJobMembers(source)
end)

Sky.Cb.Register("sky_jobs_base:getAllJobMembers", function(source)
    return fetchOnlineJobMembers(source)
end)

Sky.Cb.Register("sky_jobs_base:setMember", function(source, action, identifier)
    local src = tonumber(source)
    local myJob = Sky_Jobs.PlayerCache.GetJob(src)
    if not myJob or myJob == "" or myJob == "unemployed" then myJob = "mechanic" end

    local targetSrc = tonumber(identifier)
    if not targetSrc then
        for _, s in ipairs(GetPlayers()) do
            local p = tonumber(s)
            if p and GetPlayerIdentifierStr(p) == tostring(identifier) then
                targetSrc = p
                break
            end
        end
    end

    if action == "promote" then
        if targetSrc then
            local currentGrade = Sky_Jobs.PlayerCache.GetJobGrade(targetSrc)
            local newGrade = currentGrade + 1
            SetPlayerJob(targetSrc, myJob, newGrade)
            return { success = true, newGrade = newGrade }
        end
    elseif action == "demote" then
        if targetSrc then
            local currentGrade = Sky_Jobs.PlayerCache.GetJobGrade(targetSrc)
            local newGrade = math.max(0, currentGrade - 1)
            SetPlayerJob(targetSrc, myJob, newGrade)
            return { success = true, newGrade = newGrade }
        end
    elseif action == "fire" then
        if targetSrc then
            SetPlayerJob(targetSrc, "unemployed", 0)
            return { success = true }
        end
    end

    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:sendInvite", function(source, playerId, grade)
    local src = tonumber(source)
    local target = tonumber(playerId)
    local gradeNum = tonumber(grade) or 0

    if not target or target <= 0 or not GetPlayerName(target) then
        return { success = false, error = "Player not found or offline" }
    end

    local myJob = Sky_Jobs.PlayerCache.GetJob(src)
    if not myJob or myJob == "" or myJob == "unemployed" then myJob = "mechanic" end

    SetPlayerJob(target, myJob, gradeNum)

    TriggerClientEvent("sky_base:client:showNotification", target, "Job Offer", ("You have been hired as %s (Grade %d)!"):format(myJob, gradeNum), "success")
    TriggerClientEvent("sky_base:client:showNotification", src, "Management", ("Hired player %s as %s."):format(GetPlayerFullName(target), myJob), "success")

    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:respondInvite", function(source, inviteId, accepted)
    return { success = true }
end)

-- -----------------------------------------------------
--  FINANCES, TRANSACTIONS & BONUSES
-- -----------------------------------------------------

Sky.Cb.Register("sky_jobs_base:getFinances", function(source)
    local src = tonumber(source)
    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    if not jobName or jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    local balance = getSocietyBalance(jobName)
    local rows = MySQL.query.await("SELECT * FROM sky_jobs_transactions WHERE job = @job ORDER BY date DESC LIMIT 20", {
        ["@job"] = jobName
    }) or {}

    return {
        success = true,
        data = {
            balance = balance,
            transactions = rows
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:getFinanceSnapshot", function(source)
    local src = tonumber(source)
    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    if not jobName or jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    local balance = getSocietyBalance(jobName)
    local rows = MySQL.query.await("SELECT * FROM sky_jobs_transactions WHERE job = @job ORDER BY date DESC LIMIT 30", {
        ["@job"] = jobName
    }) or {}

    local income = 0
    local expenses = 0
    local txList = {}

    for _, r in ipairs(rows) do
        local amt = tonumber(r.amount) or 0
        if r.type == "deposit" or r.type == "income" then
            income = income + amt
        else
            expenses = expenses + amt
        end
        table.insert(txList, {
            id = r.id,
            type = r.type,
            amount = amt,
            sender = r.sender or "System",
            reason = r.reason or r.type,
            date = r.date or os.date("%Y-%m-%d %H:%M")
        })
    end

    return {
        success = true,
        data = {
            balance = balance,
            currency = "$",
            income = income,
            expenses = expenses,
            transactions = txList,
            logs = txList
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:transactionJobMoney", function(source, transType, amount)
    local src = tonumber(source)
    if not src then return { success = false, error = "Invalid player" } end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return { success = false, error = "Invalid amount" } end

    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    if not jobName or jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    local currentBalance = getSocietyBalance(jobName)
    local playerName = GetPlayerFullName(src)

    if transType == "deposit" then
        local removed = RemovePlayerMoney(src, "bank", amount)
        if not removed then
            removed = RemovePlayerMoney(src, "money", amount)
        end
        if not removed then
            return { success = false, error = "Insufficient personal funds." }
        end

        local newBalance = currentBalance + amount
        updateSocietyBalance(jobName, newBalance)
        addJobTransaction(jobName, "deposit", amount, playerName, "Deposit to society fund")

        return {
            success = true,
            balance = newBalance,
            currency = "$",
            data = {
                type = "deposit",
                amount = amount,
                sender = playerName,
                date = os.date("%Y-%m-%d %H:%M")
            }
        }
    elseif transType == "withdraw" then
        if currentBalance < amount then
            return { success = false, error = "Insufficient society funds." }
        end

        local newBalance = currentBalance - amount
        updateSocietyBalance(jobName, newBalance)
        AddPlayerMoney(src, "bank", amount)
        addJobTransaction(jobName, "withdraw", amount, playerName, "Withdrawal from society fund")

        return {
            success = true,
            balance = newBalance,
            currency = "$",
            data = {
                type = "withdraw",
                amount = amount,
                sender = playerName,
                date = os.date("%Y-%m-%d %H:%M")
            }
        }
    end

    return { success = false, error = "Invalid transaction type" }
end)

Sky.Cb.Register("sky_jobs_base:transactionLogs", function(source, limit, offset)
    local src = tonumber(source)
    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    if not jobName or jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    limit = tonumber(limit) or 50
    offset = tonumber(offset) or 0

    local rows = MySQL.query.await("SELECT * FROM sky_jobs_transactions WHERE job = @job ORDER BY date DESC LIMIT @limit OFFSET @offset", {
        ["@job"] = jobName,
        ["@limit"] = limit,
        ["@offset"] = offset
    }) or {}

    return rows
end)

Sky.Cb.Register("sky_jobs_base:getJobLogs", function(source, from, to)
    local src = tonumber(source)
    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    if not jobName or jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    local rows = MySQL.query.await("SELECT * FROM sky_jobs_transactions WHERE job = @job ORDER BY date DESC LIMIT 50", {
        ["@job"] = jobName
    }) or {}

    return rows
end)

Sky.Cb.Register("sky_jobs_base:giveBonus", function(source, targetId, amount, reason)
    local src = tonumber(source)
    local target = tonumber(targetId)
    amount = math.floor(tonumber(amount) or 0)
    if not target or amount <= 0 then
        return { success = false, error = "Invalid target or amount" }
    end

    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    if not jobName or jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    local currentBalance = getSocietyBalance(jobName)
    if currentBalance < amount then
        return { success = false, error = "Insufficient society funds for bonus" }
    end

    updateSocietyBalance(jobName, currentBalance - amount)
    AddPlayerMoney(target, "bank", amount)

    local targetName = GetPlayerFullName(target)
    local senderName = GetPlayerFullName(src)
    addJobTransaction(jobName, "bonus", amount, senderName, ("Bonus to %s: %s"):format(targetName, tostring(reason or "")))

    TriggerClientEvent("sky_jobs_base:bonusReceived", target, {
        amount = amount,
        reason = reason or "Employee performance bonus",
        sender = senderName
    })

    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:getBillingSpecs", function(source)
    return {}
end)

Sky.Cb.Register("sky_jobs_base:saveBillingSpecs", function(source, specs)
    return { success = true }
end)

-- -----------------------------------------------------
--  JOB CONFIGURATOR SERVER CALLBACKS
-- -----------------------------------------------------

Sky.Cb.Register("sky_jobs_base:jobConfigurator:configs", function(source)
    return {
        success = true,
        data = {
            {
                key = "sky_mechanicjob",
                title = "Mechanic",
                subtitle = "Vehicle System & Tuning",
                primaryColor = "#EDC001",
                icon = "wrench"
            }
        }
    }
end)

local defaultFeatures = {
    instantTuning = false,
    partsDelivery = true,
    carryItems = false,
    nitro = true,
    antiLag = true,
    twoStep = true,
    wheelDamage = true,
    customHandling = true,
    mileageHud = true,
    workshopLift = true
}

local defaultSettings = {
    primaryColor = "#EDC001",
    addRevenueToSociety = true,
    publicUsersSeePrices = true,
    fallbackVehicleValue = 50000,
    priceType = "percentage",
    freeVehicles = {},
    partsTheftItem = "lockpick",
    partsTheftRemoveItemAfterUse = false,
    partsTheftStolenWheelItem = "stolen_wheel",
    partsTheftCatalyticConverterItem = "stolen_catalytic_converter",
    partsTheftDealerAccount = "money",
    partsTheftDealerSellDistance = 3.0,
    partsTheftDispatchEnabled = true,
    partsTheftDispatchJobs = { "police" },
    vehicleCareWashItem = "wash_sponge",
    vehicleCareWaxItem = "vehicle_wax",
    vehicleCareRepairItem = "fix_kit",
    wheelDamageDefaultMultiplier = 1.0,
    wheelDamageOffroadWheelsMultiplier = 0.5,
    mileageHudDigits = 6,
    partsDeliveryTimeSeconds = 60,
    partsDeliveryTimerHudEnabled = true,
    partsDeliveryOwnCard = true,
    partsDeliveryCompanyCard = true
}

local defaultFeatureDefinitions = {
    { key = "instantTuning", label = "Instant Tuning", description = "Allow direct tuning at configured public tuning locations.", default = false },
    { key = "partsDelivery", label = "Parts Delivery", description = "Enable workshop parts delivery orders and delivery bays.", default = true },
    { key = "carryItems", label = "Physical Parts Handling", description = "Require delivered parts to be transported through the workshop.", default = false },
    { key = "nitro", label = "Nitro", description = "Enable nitro installation and vehicle boost use.", default = true },
    { key = "antiLag", label = "Anti-Lag", description = "Enable anti-lag installation and exhaust effects.", default = true },
    { key = "twoStep", label = "Two-Step", description = "Enable two-step launch control and exhaust effects.", default = true },
    { key = "wheelDamage", label = "Wheel Damage", description = "Enable realistic wheel damage and repairs.", default = true },
    { key = "customHandling", label = "Custom Handling", description = "Enable custom drivetrain and handling tuning.", default = true },
    { key = "mileageHud", label = "Mileage HUD", description = "Show vehicle mileage information while driving.", default = true },
    { key = "workshopLift", label = "Workshop Lift", description = "Enable usable lift points configured in workshops.", default = true }
}

local defaultSettingDefinitions = {
    { key = "primaryColor", label = "Primary Color", type = "color", default = "#EDC001" },
    { key = "addRevenueToSociety", label = "Add Revenue To Society", type = "boolean", default = true },
    { key = "publicUsersSeePrices", label = "Public Users See Prices", type = "boolean", default = true },
    { key = "fallbackVehicleValue", label = "Fallback Vehicle Value", type = "number", default = 50000 },
    { key = "priceType", label = "Price Type", type = "select", options = { { value = "percentage", label = "Percentage" }, { value = "fixed", label = "Fixed" } }, default = "percentage" },
    { key = "partsTheftItem", label = "Parts Theft Tool Item", type = "string", default = "lockpick" },
    { key = "partsTheftRemoveItemAfterUse", label = "Remove Theft Item After Use", type = "boolean", default = false },
    { key = "partsTheftStolenWheelItem", label = "Stolen Wheel Item Name", type = "string", default = "stolen_wheel" },
    { key = "partsTheftCatalyticConverterItem", label = "Stolen Converter Item Name", type = "string", default = "stolen_catalytic_converter" },
    { key = "partsTheftDealerAccount", label = "Parts Dealer Account", type = "string", default = "money" },
    { key = "partsTheftDealerSellDistance", label = "Dealer Sell Distance", type = "number", default = 3.0 },
    { key = "partsTheftDispatchEnabled", label = "Dispatch Alert On Theft", type = "boolean", default = true },
    { key = "vehicleCareWashItem", label = "Wash Sponge Item", type = "string", default = "wash_sponge" },
    { key = "vehicleCareWaxItem", label = "Vehicle Wax Item", type = "string", default = "vehicle_wax" },
    { key = "vehicleCareRepairItem", label = "Fix Kit Item", type = "string", default = "fix_kit" },
    { key = "wheelDamageDefaultMultiplier", label = "Wheel Damage Multiplier", type = "number", default = 1.0 },
    { key = "wheelDamageOffroadWheelsMultiplier", label = "Offroad Wheel Damage Multiplier", type = "number", default = 0.5 },
    { key = "mileageHudDigits", label = "Mileage HUD Digits", type = "number", default = 6 },
    { key = "partsDeliveryTimeSeconds", label = "Parts Delivery Time (Seconds)", type = "number", default = 60 },
    { key = "partsDeliveryTimerHudEnabled", label = "Show Delivery Timer HUD", type = "boolean", default = true },
    { key = "partsDeliveryOwnCard", label = "Allow Own Card Checkout", type = "boolean", default = true },
    { key = "partsDeliveryCompanyCard", label = "Allow Company Card Checkout", type = "boolean", default = true }
}

local defaultLocationDefinitions = {
    { key = "duty", label = "Duty Station", icon = "briefcase", placementType = "marker", allowMultiple = true, canPlace = true, enabled = true },
    { key = "storage", label = "Parts Storage", icon = "box", placementType = "marker", allowMultiple = true, canPlace = true, enabled = true },
    { key = "locker", label = "Employee Locker", icon = "archive", placementType = "marker", allowMultiple = true, canPlace = true, enabled = true },
    { key = "shop", label = "Wholesale Shop", icon = "shopping-cart", placementType = "marker", allowMultiple = true, canPlace = true, enabled = true },
    { key = "parts_drop", label = "Parts Delivery Drop", icon = "truck", placementType = "marker", allowMultiple = true, canPlace = true, enabled = true },
    { key = "wardrobe", label = "Wardrobe", icon = "shirt", placementType = "marker", allowMultiple = true, canPlace = true, enabled = true },
    { key = "management", label = "Boss Menu / Management", icon = "user-tie", placementType = "marker", allowMultiple = true, canPlace = true, enabled = true },
    { key = "lift", label = "Workshop Lift", icon = "arrow-up-down", placementType = "object", placementModel = "sky_carlift_platform", allowMultiple = true, canPlace = true, enabled = true },
    { key = "dyno", label = "Dyno Stand", icon = "gauge-high", placementType = "marker", allowMultiple = true, canPlace = true, enabled = true },
    { key = "engine_swap", label = "Engine Hoist", icon = "wrench", placementType = "marker", allowMultiple = true, canPlace = true, enabled = true },
    { key = "self_service_tuning", label = "Self Service Tuning", icon = "wrench", placementType = "marker", allowMultiple = true, canPlace = true, enabled = true },
    { key = "stolen_parts_dealer", label = "Stolen Parts Dealer", icon = "user-secret", placementType = "marker", allowMultiple = true, canPlace = true, enabled = true }
}

local function loadWorkshopCreatorData()
    local row = MySQL.single.await("SELECT data FROM sky_jobs_creator_data WHERE creator_key = 'workshopcreator' LIMIT 1")
    local data = nil
    if row and row.data then
        local decoded = json.decode(row.data)
        if type(decoded) == "table" then
            data = decoded
        end
    end

    if not data then
        data = {
            entries = {
                {
                    id = "mechanic_lscustoms",
                    name = "Los Santos Customs",
                    jobKey = "mechanic",
                    job = "mechanic",
                    storageCapacity = 1000,
                    lockerCapacity = 300,
                    nitroAccess = true,
                    workshopVehicleClasses = {},
                    points = {
                        { uid = "lsc_duty", type = "duty", label = "Duty Station", x = -341.0, y = -145.0, z = 39.0, heading = 70.0 },
                        { uid = "lsc_storage", type = "storage", label = "Parts Storage", x = -347.0, y = -133.0, z = 39.0, heading = 70.0 },
                        { uid = "lsc_locker", type = "locker", label = "Employee Lockers", x = -348.0, y = -131.0, z = 39.0, heading = 70.0 },
                        { uid = "lsc_shop", type = "shop", label = "Wholesale Shop", x = -350.0, y = -136.0, z = 39.0, heading = 70.0 },
                        { uid = "lsc_delivery", type = "parts_drop", label = "Delivery Drop", x = -355.0, y = -140.0, z = 39.0, heading = 70.0 },
                        { uid = "lsc_wardrobe", type = "wardrobe", label = "Wardrobe", x = -343.0, y = -148.0, z = 39.0, heading = 70.0 },
                        { uid = "lsc_boss", type = "management", label = "Management", x = -340.0, y = -143.0, z = 39.0, heading = 70.0 },
                        { uid = "lsc_lift_1", type = "lift", label = "Car Lift 1", x = -338.5, y = -136.5, z = 39.0, heading = 70.0, modelSet = "default" },
                        { uid = "lsc_dyno", type = "dyno", label = "Dyno Stand", x = -330.0, y = -140.0, z = 39.0, heading = 70.0 }
                    }
                }
            },
            features = {},
            settings = {},
            interactions = {}
        }
    end

    data.entries = type(data.entries) == "table" and data.entries or {}
    data.features = type(data.features) == "table" and data.features or {}
    data.settings = type(data.settings) == "table" and data.settings or {}
    data.interactions = type(data.interactions) == "table" and data.interactions or {}

    for k, v in pairs(defaultFeatures) do
        if data.features[k] == nil then
            data.features[k] = v
        end
    end

    for k, v in pairs(defaultSettings) do
        if data.settings[k] == nil then
            data.settings[k] = v
        end
    end

    for _, entry in ipairs(data.entries) do
        if type(entry.settings) ~= "table" then
            entry.settings = {}
        end
        for k, v in pairs(data.settings) do
            if entry.settings[k] == nil then
                entry.settings[k] = v
            end
        end

        if type(entry.features) ~= "table" then
            entry.features = {}
        end
        for k, v in pairs(data.features) do
            if entry.features[k] == nil then
                entry.features[k] = v
            end
        end

        if type(entry.interactions) ~= "table" then
            entry.interactions = {}
        end
        if type(entry.points) ~= "table" then
            entry.points = {}
        end
    end

    return data
end

local function saveWorkshopCreatorData(data)
    if type(data) ~= "table" then return false end
    pcall(function()
        MySQL.query.await([[
            INSERT INTO sky_jobs_creator_data (creator_key, data)
            VALUES ('workshopcreator', @data)
            ON DUPLICATE KEY UPDATE data = @data
        ]], {
            ["@data"] = json.encode(data)
        })
    end)
    TriggerClientEvent("sky_jobs_base:creatorUpdated", -1, "workshopcreator", data)

    local features = type(data.features) == "table" and data.features or defaultFeatures
    local settings = type(data.settings) == "table" and data.settings or defaultSettings
    local entries = type(data.entries) == "table" and data.entries or {}

    TriggerClientEvent("sky_jobs_base:jobConfigurator:updated", -1, "sky_mechanicjob", entries, features, settings)
    return true
end

Sky.Cb.Register("sky_jobs_base:jobConfigurator:list", function(source, data)
    local configKey = tostring(data and data.configKey or "sky_mechanicjob")
    local creatorData = loadWorkshopCreatorData()

    return {
        success = true,
        data = {
            configKey = configKey,
            title = "Mechanic Jobs",
            subtitle = "Configure mechanic jobs, shops, vehicles, and workshop locations.",
            locationDefinitions = defaultLocationDefinitions,
            featureDefinitions = defaultFeatureDefinitions,
            settingDefinitions = defaultSettingDefinitions,
            interactionDefinitions = {},
            features = creatorData.features or defaultFeatures,
            settings = creatorData.settings or defaultSettings,
            interactions = creatorData.interactions or {},
            configs = creatorData.entries or {}
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:setLocation", function(source, data)
    data = type(data) == "table" and data or {}
    local entryId = tostring(data.entryId or data.id or data.creatorEntryId or data.configId or (data.entry and data.entry.id) or "mechanic_lscustoms")
    local locType = tostring(data.locationType or data.type or "location")
    local coords = type(data.coords) == "table" and data.coords or {}

    local creatorData = loadWorkshopCreatorData()
    local targetEntry = nil
    for _, entry in ipairs(creatorData.entries) do
        if tostring(entry.id) == entryId or tostring(entry.name):lower() == tostring(data.entryName or data.name or ""):lower() then
            targetEntry = entry
            break
        end
    end

    if not targetEntry and #creatorData.entries > 0 then
        targetEntry = creatorData.entries[1]
    end

    if not targetEntry then
        targetEntry = {
            id = entryId,
            name = data.entryName or "Workshop",
            jobKey = data.jobKey or "mechanic",
            job = data.job or "mechanic",
            storageCapacity = 1000,
            lockerCapacity = 300,
            nitroAccess = true,
            workshopVehicleClasses = {},
            points = {},
            settings = {},
            features = {},
            interactions = {}
        }
        for k, v in pairs(creatorData.settings or defaultSettings) do targetEntry.settings[k] = v end
        for k, v in pairs(creatorData.features or defaultFeatures) do targetEntry.features[k] = v end
        table.insert(creatorData.entries, targetEntry)
    end

    targetEntry.points = targetEntry.points or {}
    local pointUid = data.uid or (locType .. "_" .. tostring(math.random(1000, 9999)))

    local foundPoint = false
    for _, pt in ipairs(targetEntry.points) do
        if tostring(pt.uid) == tostring(pointUid) or (tostring(pt.type) == locType and not data.allowMultiple) then
            pt.x = tonumber(coords.x) or pt.x
            pt.y = tonumber(coords.y) or pt.y
            pt.z = tonumber(coords.z) or pt.z
            pt.heading = tonumber(coords.heading) or pt.heading or 0.0
            pt.label = data.label or pt.label or locType
            if data.modelSet then pt.modelSet = data.modelSet end
            foundPoint = true
            pointUid = pt.uid
            break
        end
    end

    if not foundPoint then
        table.insert(targetEntry.points, {
            uid = pointUid,
            type = locType,
            label = data.label or locType,
            x = tonumber(coords.x) or 0.0,
            y = tonumber(coords.y) or 0.0,
            z = tonumber(coords.z) or 0.0,
            heading = tonumber(coords.heading) or 0.0,
            modelSet = data.modelSet or "default"
        })
    end

    saveWorkshopCreatorData(creatorData)

    return {
        success = true,
        pointUid = pointUid,
        uid = pointUid,
        entryId = entryId,
        coords = coords,
        locationType = locType,
        type = locType,
        isSet = true,
        status = "set",
        data = {
            uid = pointUid,
            entryId = entryId,
            coords = coords,
            x = coords.x,
            y = coords.y,
            z = coords.z,
            heading = coords.heading,
            locationType = locType,
            type = locType,
            isSet = true,
            status = "set"
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:save", function(source, data)
    data = type(data) == "table" and data or {}
    local creatorData = loadWorkshopCreatorData()

    if #data > 0 and type(data[1]) == "table" and data[1].id then
        creatorData.entries = data
    elseif type(data.configs) == "table" and #data.configs > 0 then
        creatorData.entries = data.configs
    elseif type(data.entries) == "table" and #data.entries > 0 then
        creatorData.entries = data.entries
    elseif type(data.entry) == "table" and data.entry.id then
        local found = false
        for i, e in ipairs(creatorData.entries) do
            if e.id == data.entry.id then
                creatorData.entries[i] = data.entry
                found = true
                break
            end
        end
        if not found then table.insert(creatorData.entries, data.entry) end
    elseif type(data.job) == "table" and (data.job.id or data.job.jobKey or data.job.name) then
        local found = false
        if not data.job.id then
            data.job.id = data.job.jobKey or (string.lower(data.job.name):gsub("%s+", "_"))
        end
        for i, e in ipairs(creatorData.entries) do
            if e.id == data.job.id then
                creatorData.entries[i] = data.job
                found = true
                break
            end
        end
        if not found then table.insert(creatorData.entries, data.job) end
    elseif type(data.data) == "table" then
        if type(data.data.entries) == "table" then
            creatorData.entries = data.data.entries
        elseif type(data.data.configs) == "table" then
            creatorData.entries = data.data.configs
        end
    end

    if type(data.features) == "table" then
        creatorData.features = creatorData.features or {}
        for k, v in pairs(data.features) do creatorData.features[k] = v end
    end
    if type(data.settings) == "table" then
        creatorData.settings = creatorData.settings or {}
        for k, v in pairs(data.settings) do creatorData.settings[k] = v end
    end
    if type(data.interactions) == "table" then
        creatorData.interactions = data.interactions
    end

    saveWorkshopCreatorData(creatorData)
    return { success = true, data = creatorData.entries }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:saveCreatorEntry", function(source, data)
    data = type(data) == "table" and data or {}
    local entry = data.entry or data
    if type(entry) ~= "table" or not entry.id then
        return { success = false, error = "invalid_entry" }
    end

    local creatorData = loadWorkshopCreatorData()
    local updated = false
    for i, e in ipairs(creatorData.entries) do
        if e.id == entry.id then
            creatorData.entries[i] = entry
            updated = true
            break
        end
    end

    if not updated then
        table.insert(creatorData.entries, entry)
    end

    saveWorkshopCreatorData(creatorData)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:createCreatorEntry", function(source, data)
    data = type(data) == "table" and data or {}
    local newId = "entry_" .. tostring(GetGameTimer()) .. "_" .. tostring(math.random(100, 999))
    local creatorData = loadWorkshopCreatorData()

    local newEntry = {
        id = newId,
        name = data.name or "New Workshop",
        jobKey = data.jobKey or "mechanic",
        job = data.job or "mechanic",
        storageCapacity = 1000,
        lockerCapacity = 300,
        nitroAccess = true,
        workshopVehicleClasses = {},
        points = {},
        settings = {},
        features = {},
        interactions = {}
    }
    
    for k, v in pairs(creatorData.settings or defaultSettings) do newEntry.settings[k] = v end
    for k, v in pairs(creatorData.features or defaultFeatures) do newEntry.features[k] = v end

    table.insert(creatorData.entries, newEntry)
    saveWorkshopCreatorData(creatorData)

    return { success = true, entryId = newId, entry = newEntry }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:deleteCreatorEntry", function(source, data)
    data = type(data) == "table" and data or {}
    local entryId = tostring(data.entryId or data.id or "")
    if entryId == "" then return { success = false, error = "invalid_entry_id" } end

    local creatorData = loadWorkshopCreatorData()
    for i = #creatorData.entries, 1, -1 do
        if creatorData.entries[i].id == entryId then
            table.remove(creatorData.entries, i)
        end
    end

    saveWorkshopCreatorData(creatorData)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:deleteLocations", function(source, data)
    data = type(data) == "table" and data or {}
    local entryId = tostring(data.entryId or "")
    local locType = tostring(data.locationType or "")
    local uid = tostring(data.uid or "")

    local creatorData = loadWorkshopCreatorData()
    for _, entry in ipairs(creatorData.entries) do
        if entryId == "" or entry.id == entryId then
            if entry.points then
                for i = #entry.points, 1, -1 do
                    local pt = entry.points[i]
                    if (uid ~= "" and pt.uid == uid) or (locType ~= "" and pt.type == locType) then
                        table.remove(entry.points, i)
                    end
                end
            end
        end
    end

    saveWorkshopCreatorData(creatorData)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:addCreatorZonePoint", function(source, data)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:setCreatorZonePoint", function(source, data)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:removeCreatorZonePoint", function(source, data)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:clearCreatorZonePoints", function(source, data)
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:saveFeatures", function(source, data)
    data = type(data) == "table" and data or {}
    local featuresPayload = data.features or data
    if type(featuresPayload) ~= "table" then
        return { success = false, error = "invalid_payload" }
    end

    local creatorData = loadWorkshopCreatorData()
    creatorData.features = creatorData.features or {}
    for k, v in pairs(featuresPayload) do
        if k ~= "configKey" and k ~= "_resource" then
            creatorData.features[k] = v
        end
    end

    saveWorkshopCreatorData(creatorData)
    return { success = true, data = creatorData.features }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:saveSettings", function(source, data)
    data = type(data) == "table" and data or {}
    local settingsPayload = data.settings or data
    if type(settingsPayload) ~= "table" then
        return { success = false, error = "invalid_payload" }
    end

    local creatorData = loadWorkshopCreatorData()
    creatorData.settings = creatorData.settings or {}
    for k, v in pairs(settingsPayload) do
        if k ~= "configKey" and k ~= "_resource" then
            creatorData.settings[k] = v
        end
    end

    saveWorkshopCreatorData(creatorData)
    return { success = true, data = creatorData.settings }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:saveInteractions", function(source, data)
    data = type(data) == "table" and data or {}
    local interactionsPayload = data.interactions or data
    if type(interactionsPayload) ~= "table" then
        return { success = false, error = "invalid_payload" }
    end

    local creatorData = loadWorkshopCreatorData()
    creatorData.interactions = interactionsPayload

    saveWorkshopCreatorData(creatorData)
    return { success = true, data = creatorData.interactions }
end)

Sky.Cb.Register("sky_jobs_base:jobConfigurator:delete", function(source, data)
    data = type(data) == "table" and data or {}
    local entryId = tostring(data.id or data.entryId or data.key or "")
    if entryId == "" then
        return { success = false, error = "missing_id" }
    end

    local creatorData = loadWorkshopCreatorData()
    for i = #creatorData.entries, 1, -1 do
        if tostring(creatorData.entries[i].id) == entryId then
            table.remove(creatorData.entries, i)
        end
    end

    saveWorkshopCreatorData(creatorData)
    return { success = true }
end)

RegisterServerEvent("sky_jobs_base:jobConfigurator:requestSync", function(configKey)
    local src = source
    local creatorData = loadWorkshopCreatorData()
    TriggerClientEvent("sky_jobs_base:jobConfigurator:updated", src, configKey or "sky_mechanicjob", creatorData.entries, creatorData.features, creatorData.settings)
end)

-- -----------------------------------------------------
--  MAP, DISPATCHES & CAMERA
-- -----------------------------------------------------

Sky.Cb.Register("sky_jobs_base:map:getOfficers", function(source)
    local officers = {}
    for _, srcStr in ipairs(GetPlayers()) do
        local pSrc = tonumber(srcStr)
        if pSrc then
            local ped = GetPlayerPed(pSrc)
            local coords = GetEntityCoords(ped)
            table.insert(officers, {
                source = pSrc,
                name = GetPlayerFullName(pSrc),
                coords = { x = coords.x, y = coords.y, z = coords.z },
                heading = GetEntityHeading(ped),
                job = Sky_Jobs.PlayerCache.GetJob(pSrc),
                onDuty = Sky_Jobs.PlayerCache.IsOnDuty(pSrc)
            })
        end
    end
    return {
        success = true,
        data = officers
    }
end)

Sky.Cb.Register("sky_jobs_base:map:getDispatches", function(source)
    return {
        success = true,
        data = {}
    }
end)

Sky.Cb.Register("sky_jobs_base:map:getPanics", function(source)
    return {
        success = true,
        data = {}
    }
end)

Sky.Cb.Register("sky_jobs_base:map:getPings", function(source)
    return {
        success = true,
        data = {}
    }
end)

Sky.Cb.Register("sky_jobs_base:camera:takePhoto", function(source, data)
    return {
        success = true,
        url = ""
    }
end)

-- -----------------------------------------------------
--  ADMINISTRATIVE COMMANDS
-- -----------------------------------------------------

RegisterCommand("setboss", function(source, args)
    local targetSrc = tonumber(args[1]) or source
    local jobName = args[2] or Sky_Jobs.PlayerCache.GetJob(targetSrc)
    local grade = tonumber(args[3]) or 4
    if Sky and Sky.FW and Sky.FW.SetJob then
        Sky.FW.SetJob(targetSrc, jobName, grade)
        print(("[sky_jobs_base] setboss executed: %s -> %s (grade %s)"):format(targetSrc, jobName, grade))
    end
end, false)

RegisterCommand(Config.MultiJob and Config.MultiJob.giveJobCommand or "givejob", function(source, args)
    local targetSrc = tonumber(args[1]) or source
    local jobName = args[2]
    local grade = tonumber(args[3]) or 0
    if not jobName then return end
    if Sky and Sky.FW and Sky.FW.SetJob then
        Sky.FW.SetJob(targetSrc, jobName, grade)
        print(("[sky_jobs_base] givejob executed: %s -> %s (grade %s)"):format(targetSrc, jobName, grade))
    end
end, false)

RegisterCommand(Config.MultiJob and Config.MultiJob.removeJobCommand or "removejob", function(source, args)
    local targetSrc = tonumber(args[1]) or source
    local jobName = args[2]
    if Sky and Sky.FW and Sky.FW.SetJob then
        Sky.FW.SetJob(targetSrc, Config.MultiJob and Config.MultiJob.defaultJob or "unemployed", 0)
        print(("[sky_jobs_base] removejob executed: %s removed job %s"):format(targetSrc, tostring(jobName)))
    end
end, false)

RegisterCommand(Config.MultiJob and Config.MultiJob.adminCommand or "multijobadmin", function(source, args)
    print("[sky_jobs_base] multijobadmin command placeholder. Use FW commands for multijob.")
end, false)

RegisterCommand("dutytest", function(source, args)
    local targetSrc = tonumber(args[1]) or source
    local state = args[2]
    if state == "on" or state == "1" or state == "true" then
        Sky_Jobs.PlayerCache.SetDuty(targetSrc, true)
    elseif state == "off" or state == "0" or state == "false" then
        Sky_Jobs.PlayerCache.SetDuty(targetSrc, false)
    else
        local current = Sky_Jobs.PlayerCache.IsOnDuty(targetSrc)
        Sky_Jobs.PlayerCache.SetDuty(targetSrc, not current)
    end
    print(("[sky_jobs_base] dutytest executed: %s is now %s duty"):format(targetSrc, Sky_Jobs.PlayerCache.IsOnDuty(targetSrc) and "ON" or "OFF"))
end, false)
