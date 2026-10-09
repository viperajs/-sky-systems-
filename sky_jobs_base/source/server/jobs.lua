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

    if not MySQL.update then
        MySQL.update = {
            await = function(query, params)
                if exports.oxmysql and exports.oxmysql.update_async then
                    return exports.oxmysql:update_async(query, params)
                elseif MySQL.Async and MySQL.Async.execute then
                    local p = promise.new()
                    MySQL.Async.execute(query, params or {}, function(rows) p:resolve(rows) end)
                    return Citizen.Await(p)
                end
                return 0
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

-- sky_mechanicjob's server asks this first for a player's duty state.
registerExport("isOnDuty", function(source)
    return Sky_Jobs.PlayerCache.IsOnDuty(source)
end)

function Sky_Jobs.PlayerCache.IsOnDuty(source)
    local src = tonumber(source)
    if not src or src <= 0 then return true end
    if Config and Config.DutySystem == false then return true end

    -- Set by the duty terminal and kept in sync with the framework's duty events below
    -- (ESX has no duty of its own, so the framework value cannot be the only source).
    if playerDutyState[src] ~= nil then
        return playerDutyState[src] == true
    end

    if Sky and Sky.FW and Sky.FW.GetJobData then
        local duty = Sky.FW.GetJobData(src, "duty")
        if type(duty) == "boolean" then return duty end
    end

    return true
end

-- Qbox / QBCore duty changes made outside the duty terminal (/duty, other scripts) and
-- the duty a new job starts with. Raised server-side only by the framework.
AddEventHandler("QBCore:Server:SetDuty", function(src, onDuty)
    src = tonumber(src)
    if src and type(onDuty) == "boolean" then
        playerDutyState[src] = onDuty
    end
end)

AddEventHandler("QBCore:Server:OnJobUpdate", function(src, job)
    src = tonumber(src)
    if src and type(job) == "table" then
        playerDutyState[src] = type(job.onduty) == "boolean" and job.onduty or nil
    end
end)

function Sky_Jobs.PlayerCache.SetDuty(source, onDuty)
    local src = tonumber(source)
    if not src or src <= 0 then return end
    playerDutyState[src] = (onDuty == true)
    if Sky and Sky.FW and Sky.FW.SetDuty then
        Sky.FW.SetDuty(src, onDuty == true)
    end
end

-- Permission check for admin commands and admin-only callbacks. Groups come from
-- Config.CommandPermissions; ACE `sky_jobs_base.<permission>` or `command.<permission>`
-- also grants it. The server console (source 0) is always allowed.
function Sky_Jobs.HasPermission(source, permission)
    local src = tonumber(source)
    if src == 0 then return true end
    if not src or src < 0 or type(permission) ~= "string" then return false end

    local srcStr = tostring(src)
    if IsPlayerAceAllowed(srcStr, ("sky_jobs_base.%s"):format(permission))
        or IsPlayerAceAllowed(srcStr, ("command.%s"):format(permission)) then
        return true
    end

    local groups = Config and Config.CommandPermissions and Config.CommandPermissions[permission]
    if type(groups) ~= "table" then
        return false
    end

    for _, group in ipairs(groups) do
        if type(group) == "string" and IsPlayerAceAllowed(srcStr, ("group.%s"):format(group)) then
            return true
        end
    end

    if GetResourceState("qbx_core") == "started" then
        for _, group in ipairs(groups) do
            local ok, allowed = pcall(function()
                return exports.qbx_core:HasPermission(src, group)
            end)
            if ok and allowed == true then
                return true
            end
        end
    end

    if Sky and Sky.FW and Sky.FW.HasCommandPermission then
        for _, group in ipairs(groups) do
            if Sky.FW.HasCommandPermission(src, group) == true then
                return true
            end
        end
    end

    return false
end

-- Job name a player has when they have no job (multijob default job).
local function isUnemployedJob(jobName)
    if type(jobName) ~= "string" or jobName == "" then return true end
    local defaultJob = Config and Config.MultiJob and Config.MultiJob.defaultJob or "unemployed"
    return jobName == defaultJob or jobName == "unemployed"
end
Sky_Jobs.IsUnemployedJob = isUnemployedJob

function Sky_Jobs.PlayerCache.GetJob(source)
    local src = tonumber(source)
    if not src or src <= 0 then return "" end

    -- The framework's answer is authoritative ("" = no character loaded); the local cache
    -- is only a fallback for when the framework cannot be reached.
    if Sky and Sky.FW and Sky.FW.GetJob then
        local job = Sky.FW.GetJob(src)
        if type(job) == "string" then
            return job ~= "" and job or "unemployed"
        end
    end

    return playerJobCache[src] or "unemployed"
end

function Sky_Jobs.PlayerCache.GetJobGrade(source)
    local src = tonumber(source)
    if not src or src <= 0 then return 0 end

    if Sky and Sky.FW and Sky.FW.GetJobData then
        local grade = Sky.FW.GetJobData(src, "grade")
        if grade ~= nil then return math.floor(tonumber(grade) or 0) end
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
--  FRAMEWORK & DATA HELPERS (Contract J)
-- -----------------------------------------------------

local function notify(src, title, message, kind)
    TriggerClientEvent("sky_base:notification", src, title, message, kind or "info", 5000)
end

-- UTF-8 safe trim + length cap; nil for empty or invalid UTF-8 text.
local function cleanText(value, maxChars)
    if type(value) ~= "string" then return nil end
    local text = value:match("^%s*(.-)%s*$")
    if text == "" or not utf8.len(text) then return nil end
    local cut = utf8.offset(text, maxChars + 1)
    if cut then text = text:sub(1, cut - 1) end
    return text
end

function Sky_Jobs.GetPlayerIdentifier(source)
    local src = tonumber(source)
    if not src or src <= 0 or not (Sky and Sky.FW and Sky.FW.GetIdentifier) then return nil end
    local id = Sky.FW.GetIdentifier(src)
    if id == nil or id == "" then return nil end
    return tostring(id)
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
Sky_Jobs.GetPlayerFullName = GetPlayerFullName

local function validAmount(amount)
    amount = tonumber(amount)
    if not amount or amount ~= amount or amount <= 0 or amount == math.huge then return nil end
    amount = math.floor(amount)
    return amount > 0 and amount or nil
end

-- Fail closed: true only when the framework confirmed that the money moved.
function Sky_Jobs.AddPlayerMoney(source, account, amount)
    local src, value = tonumber(source), validAmount(amount)
    if not src or not value or not (Sky and Sky.FW and Sky.FW.AddAccountMoney) then return false end
    return Sky.FW.AddAccountMoney(src, account or "money", value) == true
end

function Sky_Jobs.RemovePlayerMoney(source, account, amount)
    local src, value = tonumber(source), validAmount(amount)
    if not src or not value or not (Sky and Sky.FW and Sky.FW.RemoveAccountMoney) then return false end
    return Sky.FW.RemoveAccountMoney(src, account or "money", value) == true
end

local function SetPlayerJob(source, job, grade)
    local src = tonumber(source)
    if not src then return false end
    local ok = false
    if Sky and Sky.FW and Sky.FW.SetJob then
        ok = Sky.FW.SetJob(src, job, grade or 0) == true
    end
    if ok then
        Sky_Jobs.PlayerCache.UpdateJob(src, job)
    end
    return ok
end

local function detectFramework()
    if GetResourceState("qbx_core") == "started" then return "qbox" end
    if GetResourceState("qb-core") == "started" then return "qb" end
    if GetResourceState("es_extended") == "started" then return "esx" end
    return nil
end

-- Job label and sorted grades from the framework (Sky.FW.GetJobs), cached briefly.
local frameworkJobs = { at = -math.huge, data = nil, info = {} }

local function getJobInfo(jobName)
    if type(jobName) ~= "string" or jobName == "" then return nil end
    local now = os.time()
    if not frameworkJobs.data or now - frameworkJobs.at >= 60 then
        local jobs = Sky and Sky.FW and Sky.FW.GetJobs and Sky.FW.GetJobs()
        if type(jobs) == "table" then
            frameworkJobs.data, frameworkJobs.at, frameworkJobs.info = jobs, now, {}
        end
    end
    if not frameworkJobs.data then return nil end
    if frameworkJobs.info[jobName] ~= nil then return frameworkJobs.info[jobName] or nil end

    local job = nil
    for key, entry in pairs(frameworkJobs.data) do
        if type(entry) == "table" and (key == jobName or entry.name == jobName) then
            job = entry
            break
        end
    end
    if not job then
        frameworkJobs.info[jobName] = false
        return nil
    end

    local grades, byLevel, top = {}, {}, nil
    for key, g in pairs(type(job.grades) == "table" and job.grades or {}) do
        if type(g) == "table" then
            local level = math.tointeger(tonumber(g.grade) or tonumber(key))
            if level and not byLevel[level] then
                local entry = {
                    grade = level,
                    label = tostring(g.label or g.name or ("Grade " .. level)),
                    salary = tonumber(g.payment or g.salary) or 0,
                    isboss = g.isboss == true
                }
                byLevel[level] = entry
                grades[#grades + 1] = entry
                if not top or level > top then top = level end
            end
        end
    end
    table.sort(grades, function(a, b) return a.grade < b.grade end)

    local info = { name = jobName, label = tostring(job.label or jobName), grades = grades, byLevel = byLevel, top = top }
    frameworkJobs.info[jobName] = info
    return info
end

local function gradeLabel(info, level)
    local g = info and info.byLevel[level]
    return g and g.label or ("Grade " .. tostring(level))
end

-- jobName, grade (integer) or nil when offline, jobless or unemployed.
function Sky_Jobs.GetEmployment(source)
    local src = tonumber(source)
    if not src or src <= 0 then return nil end
    local job = Sky_Jobs.PlayerCache.GetJob(src)
    if isUnemployedJob(job) then return nil end
    return job, Sky_Jobs.PlayerCache.GetJobGrade(src)
end

function Sky_Jobs.RequireEmployee(source, requireOnDuty)
    local job, grade = Sky_Jobs.GetEmployment(source)
    if not job then return nil end
    if requireOnDuty and not Sky_Jobs.PlayerCache.IsOnDuty(source) then return nil end
    return job, grade
end

-- Framework isboss; the job's highest grade only when the framework cannot say.
local function isBossFor(src, job, grade)
    local fwBoss = Sky and Sky.FW and Sky.FW.IsPlayerBoss and Sky.FW.IsPlayerBoss(src)
    if type(fwBoss) == "boolean" then return fwBoss end
    local info = getJobInfo(job)
    return info ~= nil and info.top ~= nil and grade >= info.top
end

function Sky_Jobs.IsPlayerBoss(source)
    local job, grade = Sky_Jobs.GetEmployment(source)
    if not job then return false end
    return isBossFor(tonumber(source), job, grade) == true
end

-- -----------------------------------------------------
--  GRADE PERMISSIONS & RESTRICTIONS
-- -----------------------------------------------------

local PERMISSION_ALL = 57495345
local RESTRICTION_KEYS = { "items", "weapons", "vehicles", "tablet_apps", "document_classifications" }

local function permissionEnum()
    return Permission or {}
end

local function resolvePermission(permission)
    local enum = permissionEnum()
    if type(permission) == "string" then
        permission = enum[permission:upper()]
    end
    local id = math.tointeger(tonumber(permission))
    if not id then return nil end
    if id == PERMISSION_ALL then return id end
    for _, value in pairs(enum) do
        if value == id then return id end
    end
    return nil
end

-- [job][grade] = { perms = { [id] = true }, restrictions = { items = {...}, ... } }
local gradeStore = {}
local gradeStoreLoaded = false

local function decodeJson(text)
    if type(text) ~= "string" or text == "" then return nil end
    local ok, value = pcall(json.decode, text)
    return (ok and type(value) == "table") and value or nil
end

local function normalizeEntry(perms, restrictions)
    local entry = { perms = {}, restrictions = {} }
    for _, id in ipairs(type(perms) == "table" and perms or {}) do
        local resolved = resolvePermission(id)
        if resolved then entry.perms[resolved] = true end
    end
    for _, key in ipairs(RESTRICTION_KEYS) do
        local list = {}
        local source = type(restrictions) == "table" and restrictions[key]
        for _, value in ipairs(type(source) == "table" and source or {}) do
            if type(value) == "string" and value ~= "" and #value <= 64 and #list < 200 then
                list[#list + 1] = value
            end
        end
        entry.restrictions[key] = list
    end
    return entry
end

local function loadGradeStore()
    local ok, rows = pcall(MySQL.query.await, "SELECT job, grade, permissions, restrictions FROM sky_jobs_grade_permissions")
    if not ok or type(rows) ~= "table" then return false end
    local store = {}
    for _, row in ipairs(rows) do
        local grade = math.tointeger(tonumber(row.grade))
        if type(row.job) == "string" and grade then
            store[row.job] = store[row.job] or {}
            store[row.job][grade] = normalizeEntry(decodeJson(row.permissions), decodeJson(row.restrictions))
        end
    end
    gradeStore = store
    gradeStoreLoaded = true
    return true
end

local function getGradeEntry(job, grade)
    if not gradeStoreLoaded then loadGradeStore() end
    return gradeStore[job] and gradeStore[job][grade] or nil
end

local function saveGradeEntry(job, grade, entry)
    local perms = {}
    for id in pairs(entry.perms) do perms[#perms + 1] = id end
    table.sort(perms)
    local ok = pcall(MySQL.query.await, [[
        INSERT INTO sky_jobs_grade_permissions (job, grade, permissions, restrictions)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE permissions = VALUES(permissions), restrictions = VALUES(restrictions)
    ]], { job, grade, json.encode(perms), json.encode(entry.restrictions) })
    if not ok then return false end
    gradeStore[job] = gradeStore[job] or {}
    gradeStore[job][grade] = entry
    return true
end

-- The acting player: job, grade, boss flag and a permission test computed once.
local function getActor(source)
    local src = tonumber(source)
    local job, grade = Sky_Jobs.GetEmployment(src)
    if not job then return nil end
    local actor = { src = src, job = job, grade = grade }
    actor.boss = isBossFor(src, job, grade) == true
    function actor.can(permission)
        if actor.boss then return true end
        local id = resolvePermission(permission)
        if not id then return false end
        local entry = getGradeEntry(job, grade)
        return entry ~= nil and (entry.perms[id] == true or entry.perms[PERMISSION_ALL] == true)
    end
    return actor
end

function Sky_Jobs.HasJobPermission(source, permission)
    if not resolvePermission(permission) then return false end
    local actor = getActor(source)
    return actor ~= nil and actor.can(permission)
end

-- Stored restriction lists of a grade (what the roles editor saved).
function Sky_Jobs.GetGradeRestrictions(job, grade)
    local entry = getGradeEntry(job, math.tointeger(tonumber(grade)) or -1)
    local out = {}
    for _, key in ipairs(RESTRICTION_KEYS) do
        out[key] = entry and entry.restrictions[key] or {}
    end
    return out
end

-- Restrictions that apply to a player: only while the matching permission is enabled for
-- the grade, and never for bosses or grades with full access.
function Sky_Jobs.GetPlayerRestrictions(source)
    local out = {}
    for _, key in ipairs(RESTRICTION_KEYS) do out[key] = {} end
    local actor = getActor(source)
    if not actor or actor.boss then return out end
    local entry = getGradeEntry(actor.job, actor.grade)
    if not entry or entry.perms[PERMISSION_ALL] then return out end
    local enum = permissionEnum()
    local function apply(permissionName, ...)
        if entry.perms[enum[permissionName]] then
            for _, key in ipairs({ ... }) do out[key] = entry.restrictions[key] end
        end
    end
    apply("MANAGE_WAREHOUSE", "items", "weapons")
    apply("GARAGE_VEHICLES", "vehicles")
    apply("TABLET_APPS", "tablet_apps")
    apply("DOCUMENT_CLASSIFICATIONS", "document_classifications")
    return out
end

-- -----------------------------------------------------
--  SOCIETY MONEY
-- -----------------------------------------------------

local MAX_BALANCE = 2147483647

local MONEY_CREDIT = { deposited = true, deposit = true, vehicle_sold = true, income = true }
local MONEY_DEBIT = { withdrawn = true, withdraw = true, bonus_paid = true, bonus = true, supplies_purchased = true, vehicle_purchased = true, salary_paid = true, expense = true }
local LEGACY_ACTIONS = { deposit = "deposited", withdraw = "withdrawn", bonus = "bonus_paid" }
local FINANCE_CATEGORY = {
    deposited = "deposits", withdrawn = "withdrawals", bonus_paid = "bonuses", supplies_purchased = "supplies",
    vehicle_purchased = "vehicles", vehicle_sold = "vehicles", salary_paid = "salaries", income = "income", expense = "expenses"
}
local MONEY_TYPE_LIST = { "deposited", "deposit", "withdrawn", "withdraw", "bonus_paid", "bonus", "supplies_purchased",
    "vehicle_purchased", "vehicle_sold", "salary_paid", "income", "expense" }

local function validJob(job)
    return type(job) == "string" and job ~= "" and #job <= 50
end

local function logJobTransaction(job, txType, amount, actorName, reason)
    pcall(MySQL.insert.await, "INSERT INTO sky_jobs_transactions (job, type, amount, sender, reason) VALUES (?, ?, ?, ?, ?)", {
        job, txType, math.floor(tonumber(amount) or 0), cleanText(actorName, 100) or "System", cleanText(reason, 500)
    })
end

function Sky_Jobs.GetSocietyBalance(job)
    if not validJob(job) then return 0 end
    local ok, row = pcall(MySQL.single.await, "SELECT balance FROM sky_jobs_finances WHERE job = ? LIMIT 1", { job })
    return ok and row and tonumber(row.balance) or 0
end

local function debitSociety(job, amount)
    local ok, changed = pcall(MySQL.update.await, "UPDATE sky_jobs_finances SET balance = balance - ? WHERE job = ? AND balance >= ?", { amount, job, amount })
    return ok and (tonumber(changed) or 0) > 0
end

local function creditSociety(job, amount)
    if amount > MAX_BALANCE then return false end
    local function bump()
        local ok, changed = pcall(MySQL.update.await, "UPDATE sky_jobs_finances SET balance = balance + ? WHERE job = ? AND balance <= ?", { amount, job, MAX_BALANCE - amount })
        return ok and (tonumber(changed) or 0) > 0
    end
    if bump() then return true end
    pcall(MySQL.insert.await, "INSERT IGNORE INTO sky_jobs_finances (job, balance) VALUES (?, 0)", { job })
    return bump()
end

-- A reason that is a known transaction type (e.g. "supplies_purchased") is logged as that type.
local function transactionType(reason, credit)
    if type(reason) == "string" and FINANCE_CATEGORY[reason] and (credit and MONEY_CREDIT[reason] or (not credit and MONEY_DEBIT[reason])) then
        return reason, nil
    end
    return credit and "income" or "expense", reason
end

function Sky_Jobs.DebitSociety(job, amount, reason, actorName)
    amount = validAmount(amount)
    if not validJob(job) or not amount or not debitSociety(job, amount) then return false end
    local txType, text = transactionType(reason, false)
    logJobTransaction(job, txType, amount, actorName, text)
    return true
end

function Sky_Jobs.CreditSociety(job, amount, reason, actorName)
    amount = validAmount(amount)
    if not validJob(job) or not amount or not creditSociety(job, amount) then return false end
    local txType, text = transactionType(reason, true)
    logJobTransaction(job, txType, amount, actorName, text)
    return true
end

local function invokingResource()
    return type(GetInvokingResource) == "function" and GetInvokingResource() or nil
end

registerExport("GetSocietyMoney", function(job)
    return Sky_Jobs.GetSocietyBalance(job)
end)

registerExport("AddSocietyMoney", function(job, amount, reason)
    return Sky_Jobs.CreditSociety(job, amount, reason, invokingResource())
end)

registerExport("RemoveSocietyMoney", function(job, amount, reason)
    return Sky_Jobs.DebitSociety(job, amount, reason, invokingResource())
end)

registerExport("HasJobPermission", function(source, permission)
    return Sky_Jobs.HasJobPermission(source, permission)
end)

-- -----------------------------------------------------
--  JOB REGISTRY (definitions sent by job resources)
-- -----------------------------------------------------

local jobRegistry = { byResource = {}, defs = {} }

local function copyEntries(list, fields, required)
    local out = {}
    for _, item in ipairs(type(list) == "table" and list or {}) do
        if type(item) == "table" and type(item[required]) == "string" and item[required] ~= "" then
            local entry, valid = {}, true
            for field, kind in pairs(fields) do
                local value = item[field]
                -- /jobconfig text inputs left empty (e.g. a vehicle's livery) mean unset.
                if kind == "number" and value == "" then value = nil end
                if kind == "number" and value ~= nil then
                    value = tonumber(value)
                    if not value or value ~= value or value < 0 or value == math.huge then valid = false end
                end
                if type(value) == kind or (kind == "any" and value ~= nil) then entry[field] = value end
            end
            if valid then out[#out + 1] = entry end
        end
    end
    return out
end

local function sanitizeJobDefinition(def)
    if type(def) ~= "table" or not validJob(def.name) then return nil end
    return {
        name = def.name,
        label = type(def.label) == "string" and def.label or def.name,
        color = type(def.color) == "string" and def.color ~= "" and def.color or nil,
        shop = copyEntries(def.shop, { name = "string", label = "string", price = "number" }, "name"),
        props = copyEntries(def.props, { model = "string", label = "string", item = "string", zOffset = "number" }, "model"),
        vehicles = copyEntries(def.vehicles, {
            name = "string", model = "string", price = "number", trunkCapacity = "number", garageType = "string",
            trunkEnabled = "boolean", trunkPropsEnabled = "boolean", fuelType = "string", hasStretcher = "boolean",
            livery = "number", props = "any", propCounts = "any", altModels = "any", extras = "any", properties = "any",
            primaryColor = "any", secondaryColor = "any", pearlescentColor = "any", wheelColor = "any"
        }, "model"),
        jobGroup = type(def.jobGroup) == "string" and def.jobGroup or nil,
        storage = type(def.storage) == "table" and def.storage or nil,
        offDutyJob = type(def.offDutyJob) == "string" and def.offDutyJob ~= "" and def.offDutyJob or nil
    }
end

local function rebuildJobRegistry()
    local defs = {}
    for _, jobs in pairs(jobRegistry.byResource) do
        for name, def in pairs(jobs) do defs[name] = def end
    end
    jobRegistry.defs = defs
end

function Sky_Jobs.GetJobDefinition(jobName)
    return type(jobName) == "string" and jobRegistry.defs[jobName] or nil
end

function Sky_Jobs.GetRegisteredJobNames()
    local names = {}
    for name in pairs(jobRegistry.defs) do names[#names + 1] = name end
    table.sort(names)
    return names
end

registerExport("RegisterJobs", function(resourceName, jobs)
    resourceName = type(resourceName) == "string" and resourceName ~= "" and resourceName or invokingResource()
    if not resourceName then return false end
    local previous = jobRegistry.byResource[resourceName] or {}
    local defs = {}
    for _, def in ipairs(type(jobs) == "table" and jobs or {}) do
        local clean = sanitizeJobDefinition(def)
        if clean then defs[clean.name] = clean end
    end
    jobRegistry.byResource[resourceName] = defs
    rebuildJobRegistry()
    for name in pairs(defs) do
        TriggerClientEvent("sky_jobs_base:jobs:registered", -1, name)
    end
    for name in pairs(previous) do
        if not jobRegistry.defs[name] then TriggerClientEvent("sky_jobs_base:jobs:unregistered", -1, name) end
    end
    return true
end)

AddEventHandler("onResourceStop", function(resourceName)
    local removed = jobRegistry.byResource[resourceName]
    if not removed then return end
    jobRegistry.byResource[resourceName] = nil
    rebuildJobRegistry()
    for name in pairs(removed) do
        if not jobRegistry.defs[name] then TriggerClientEvent("sky_jobs_base:jobs:unregistered", -1, name) end
    end
end)

-- -----------------------------------------------------
--  CORE JOB & ACCESS SERVER CALLBACKS
-- -----------------------------------------------------

Sky.Cb.Register("sky_jobs_base:creator:getPlayerJob", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, data = { ready = false } } end

    -- Before the character is loaded the framework has no job for the player yet; the
    -- client keeps asking until it is ready.
    if Sky and Sky.FW and Sky.FW.IsPlayerOnline and Sky.FW.IsPlayerOnline(src) == false then
        return { success = true, data = { ready = false } }
    end

    local jobName = Sky_Jobs.PlayerCache.GetJob(src)
    local gradeLevel = Sky_Jobs.PlayerCache.GetJobGrade(src)

    -- No jobKey for the default job: clients treat any jobKey as employed.
    local jobKey = (not isUnemployedJob(jobName)) and jobName or nil

    return {
        success = true,
        data = {
            ready = true,
            jobKey = jobKey,
            job = jobKey,
            grade = gradeLevel,
            isBoss = jobKey ~= nil and isBossFor(src, jobKey, gradeLevel) == true
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
            jobKey = (not isUnemployedJob(jobName)) and jobName or nil
        }
    }
end)

-- Array of job names: jobs registered with RegisterJobs plus jobs that own tablet apps.
Sky.Cb.Register("sky_jobs_base:getRegisteredJobs", function(source)
    local names, seen = {}, {}
    local function add(name)
        if type(name) == "string" and name ~= "" and name ~= "all" and not seen[name] then
            seen[name] = true
            names[#names + 1] = name
        end
    end
    for _, name in ipairs(Sky_Jobs.GetRegisteredJobNames()) do add(name) end
    for _, apps in pairs(Sky_Jobs.RegisteredTabletApps or {}) do
        for _, app in ipairs(type(apps) == "table" and apps or {}) do
            if type(app) == "table" then add(app.job) end
        end
    end
    return names
end)

Sky.Cb.Register("sky_jobs_base:getJobColor", function(source)
    local def = Sky_Jobs.GetJobDefinition(Sky_Jobs.PlayerCache.GetJob(source))
    return def and def.color or nil
end)

Sky.Cb.Register("sky_jobs_base:getJobColorFor", function(source, data)
    local jobKey = type(data) == "table" and data.jobKey or Sky_Jobs.PlayerCache.GetJob(source)
    local def = Sky_Jobs.GetJobDefinition(jobKey)
    return def and def.color or nil
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
    if isOnDuty and not isUnemployedJob(currentJob) then
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
--  DATABASE SCHEMA ENSURANCE FOR JOBS BASE
-- -----------------------------------------------------

local function runSchemaStatement(query, params)
    local ok, err = pcall(MySQL.query.await, query, params)
    if not ok then
        print(("[sky_jobs_base] database setup failed: %s"):format(tostring(err)))
    end
    return ok
end

local function columnLength(tableName, column)
    local ok, row = pcall(MySQL.single.await, "SELECT COALESCE(CHARACTER_MAXIMUM_LENGTH, 0) AS len FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?", { tableName, column })
    if not ok then return nil end
    return row and (tonumber(row.len) or 0) or false
end

local function ensureColumn(tableName, column, definition)
    if columnLength(tableName, column) == false then
        runSchemaStatement(("ALTER TABLE `%s` ADD COLUMN `%s` %s"):format(tableName, column, definition))
    end
end

local function ensureIndex(tableName, indexName, columns)
    local ok, row = pcall(MySQL.single.await, "SELECT 1 AS present FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND INDEX_NAME = ? LIMIT 1", { tableName, indexName })
    if ok and not row then
        runSchemaStatement(("ALTER TABLE `%s` ADD INDEX `%s` (%s)"):format(tableName, indexName, columns))
    end
end

local chatSupportsImages = false

local function ensureJobsBaseTables()
    if not (MySQL and MySQL.query and MySQL.query.await) then return end
    if Config and Config.AutoExecuteQuery == false then return end

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
                `chat_id` VARCHAR(160) NOT NULL,
                `sender_identifier` VARCHAR(64) DEFAULT NULL,
                `recipient_identifier` VARCHAR(64) DEFAULT NULL,
                `sender_name` VARCHAR(100) NOT NULL,
                `message` TEXT NOT NULL,
                `timestamp` BIGINT NOT NULL,
                `is_read` TINYINT(1) NOT NULL DEFAULT 0,
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
            CREATE TABLE IF NOT EXISTS `sky_jobs_chat_group_members` (
                `group_id` VARCHAR(64) NOT NULL,
                `identifier` VARCHAR(64) NOT NULL,
                PRIMARY KEY (`group_id`, `identifier`),
                INDEX `idx_identifier` (`identifier`)
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
                `color` VARCHAR(16) DEFAULT NULL,
                `created_by` VARCHAR(64) DEFAULT NULL,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_job` (`job`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_jobs_grade_permissions` (
                `job` VARCHAR(50) NOT NULL,
                `grade` INT NOT NULL,
                `permissions` LONGTEXT DEFAULT NULL,
                `restrictions` LONGTEXT DEFAULT NULL,
                `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`job`, `grade`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_jobs_gallery_photos` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `job` VARCHAR(50) NOT NULL,
                `url` VARCHAR(1024) NOT NULL,
                `image_id` VARCHAR(128) DEFAULT NULL,
                `folder` VARCHAR(20) NOT NULL DEFAULT 'camera',
                `media_type` VARCHAR(10) NOT NULL DEFAULT 'image',
                `metadata` TEXT DEFAULT NULL,
                `taken_by` VARCHAR(100) DEFAULT NULL,
                `taken_by_identifier` VARCHAR(64) DEFAULT NULL,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_job` (`job`, `id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]]
    }

    for _, q in ipairs(jobTables) do
        runSchemaStatement(q)
    end

    -- Tables created by older versions (or schema.sql) lack these columns.
    ensureColumn("sky_jobs_chat_messages", "recipient_identifier", "VARCHAR(64) DEFAULT NULL")
    ensureColumn("sky_jobs_chat_messages", "is_read", "TINYINT(1) NOT NULL DEFAULT 0")
    ensureColumn("sky_jobs_calendar_events", "color", "VARCHAR(16) DEFAULT NULL")
    ensureColumn("sky_jobs_chat_messages", "image_url", "VARCHAR(1024) DEFAULT NULL")
    local chatIdLength = columnLength("sky_jobs_chat_messages", "chat_id")
    if chatIdLength and chatIdLength < 160 then
        runSchemaStatement("ALTER TABLE `sky_jobs_chat_messages` MODIFY `chat_id` VARCHAR(160) NOT NULL")
    end
    ensureIndex("sky_jobs_chat_messages", "idx_recipient", "`recipient_identifier`, `is_read`")
    ensureIndex("sky_jobs_chat_messages", "idx_sender", "`sender_identifier`")
end

CreateThread(function()
    while not MySQL do
        Wait(500)
    end
    ensureJobsBaseTables()
    -- Chat images need the image_url column (added above, or by schema.sql when AutoExecuteQuery is off).
    local imageColumn = columnLength("sky_jobs_chat_messages", "image_url")
    chatSupportsImages = imageColumn ~= nil and imageColumn ~= false
    loadGradeStore()
end)

-- -----------------------------------------------------
--  UPLOADS (presigned URLs) & JOB GALLERY
-- -----------------------------------------------------

Sky_Jobs.Uploads = Sky_Jobs.Uploads or {}
Sky_Jobs.Gallery = Sky_Jobs.Gallery or {}

local GALLERY_FOLDERS = { camera = true, cctv = true, speedcam = true, mugshot = true, chat = true }
local lastPresignAt = {}
local UPLOAD_CREDIT_SECONDS = 600
local uploadCredits = {}
local loggedRejectedHosts = {}

local function uploadConfig()
    return Config and type(Config.Uploads) == "table" and Config.Uploads or {}
end

local function uploadTokenConvar()
    local name = uploadConfig().tokenConvar
    return type(name) == "string" and name ~= "" and name or "sky_jobs_upload_token"
end

-- Read on every request so `set sky_jobs_upload_token ...` takes effect without a restart.
local function uploadToken()
    return GetConvar(uploadTokenConvar(), "")
end

local function uploadEndpoint()
    local cfg = uploadConfig()
    local endpoint = cfg.presignedUrlEndpoint
    if type(endpoint) == "string" and endpoint:match("^https?://") then return endpoint end
    if (cfg.provider or "fivemanage") == "fivemanage" then return "https://api.fivemanage.com/api/presigned-url" end
    return nil
end

function Sky_Jobs.Uploads.IsConfigured()
    return uploadToken() ~= "" and uploadEndpoint() ~= nil
end

--- Presigned upload URL from the configured provider (yields).
---@param fileType string "image" or "video"
---@return string|nil presignedUrl, string|nil error
function Sky_Jobs.Uploads.RequestPresignedUrl(fileType)
    fileType = fileType == "video" and "video" or "image"
    local token, endpoint = uploadToken(), uploadEndpoint()
    if token == "" or not endpoint then return nil, "upload_not_configured" end

    local cfg = uploadConfig()
    local url = endpoint .. (endpoint:find("?", 1, true) and "&" or "?") .. "fileType=" .. fileType
    local prefix = type(cfg.authorizationPrefix) == "string" and cfg.authorizationPrefix or ""
    local timeout = math.max(1000, tonumber(cfg.requestTimeoutMs) or 5000)

    local p, settled = promise.new(), false
    local function settle(presigned, err)
        if settled then return end
        settled = true
        p:resolve({ presigned, err })
    end

    SetTimeout(timeout, function() settle(nil, "upload_timeout") end)
    PerformHttpRequest(url, function(status, body)
        status = tonumber(status) or 0
        if status < 200 or status >= 300 then
            print(("[sky_jobs_base] Presigned upload URL request failed (HTTP %d)%s."):format(status,
                (status == 401 or status == 403) and "; check the token in the " .. uploadTokenConvar() .. " convar" or ""))
            return settle(nil, "upload_failed")
        end
        local ok, decoded = pcall(json.decode, body or "")
        decoded = ok and type(decoded) == "table" and decoded or {}
        local inner = type(decoded.data) == "table" and decoded.data or {}
        local presigned = inner.presignedUrl or decoded.presignedUrl
        if type(presigned) ~= "string" or not presigned:match("^https?://[^%s\"'<>]+$") then
            print("[sky_jobs_base] The upload provider answered without a presignedUrl.")
            return settle(nil, "upload_failed")
        end
        settle(presigned)
    end, "GET", "", { ["Authorization"] = prefix .. token, ["Accept"] = "application/json" })

    local result = Citizen.Await(p)
    return result[1], result[2]
end

local function isRegisteredJob(job)
    if Sky_Jobs.GetJobDefinition(job) then return true end
    for _, apps in pairs(Sky_Jobs.RegisteredTabletApps or {}) do
        for _, app in ipairs(type(apps) == "table" and apps or {}) do
            if type(app) == "table" and app.job == job then return true end
        end
    end
    return false
end

--- Job of an employee of a registered job who may upload, or nil and an error key.
function Sky_Jobs.Uploads.Authorize(source, requireOnDuty)
    local src = tonumber(source)
    local onDuty = requireOnDuty == true or uploadConfig().requireOnDuty == true
    local job = src and Sky_Jobs.GetEmployment(src)
    if not job then return nil, "no_job" end
    if onDuty and not Sky_Jobs.RequireEmployee(src, true) then return nil, "not_on_duty" end
    if not isRegisteredJob(job) then return nil, "not_authorized" end
    return job
end

--- Presigned URL for an authorized player, rate limited per player and file type.
function Sky_Jobs.Uploads.PresignFor(source, fileType)
    if not Sky_Jobs.Uploads.IsConfigured() then return nil, "upload_not_configured" end
    local src = tonumber(source)
    fileType = fileType == "video" and "video" or "image"
    local now = GetGameTimer()
    local entry = lastPresignAt[src] or {}
    lastPresignAt[src] = entry
    if entry[fileType] and now - entry[fileType] < math.max(0, tonumber(uploadConfig().rateLimitMs) or 1500) then
        return nil, "rate_limited"
    end
    entry[fileType] = now
    local presignedUrl, err = Sky_Jobs.Uploads.RequestPresignedUrl(fileType)
    if presignedUrl then
        local credits = uploadCredits[src] or {}
        uploadCredits[src] = credits
        credits[#credits + 1] = os.time() + UPLOAD_CREDIT_SECONDS
        if #credits > 5 then table.remove(credits, 1) end
    end
    return presignedUrl, err
end

--- Uses up one presigned URL handed to this player, so files reported back by the client
--- (gallery:addPhoto) match an upload the server allowed.
function Sky_Jobs.Uploads.ConsumeCredit(source)
    local credits = uploadCredits[tonumber(source)]
    local now = os.time()
    while credits and credits[1] do
        local expires = table.remove(credits, 1)
        if expires >= now then return true end
    end
    return false
end

--- True for an https URL on a host in Config.Uploads.allowedHosts (or a subdomain of one).
function Sky_Jobs.Uploads.IsAllowedUrl(url)
    if type(url) ~= "string" or #url > 1024 then return false end
    local host = url:match("^https://([^/?#%s\"'<>\\]+)[^%s\"'<>\\]*$")
    if not host or host:find("@", 1, true) then return false end
    host = host:gsub(":%d+$", ""):lower()

    for _, allowed in ipairs(type(uploadConfig().allowedHosts) == "table" and uploadConfig().allowedHosts or {}) do
        if type(allowed) == "string" and allowed ~= "" then
            allowed = allowed:lower():gsub("^%*?%.", "")
            if host == allowed or host:sub(-(#allowed + 1)) == "." .. allowed then return true end
        end
    end
    if not loggedRejectedHosts[host] then
        loggedRejectedHosts[host] = true
        print(("[sky_jobs_base] Rejected an uploaded file URL on %s; add the host to Config.Uploads.allowedHosts if it is your upload provider."):format(host))
    end
    return false
end

function Sky_Jobs.Gallery.Folder(value)
    value = type(value) == "string" and value:lower() or nil
    return value and GALLERY_FOLDERS[value] and value or "camera"
end

function Sky_Jobs.Gallery.IsFull(job)
    local max = math.floor(tonumber(uploadConfig().maxPhotosPerJob) or 0)
    if max <= 0 then return false end
    local ok, row = pcall(MySQL.single.await, "SELECT COUNT(*) AS total FROM sky_jobs_gallery_photos WHERE job = ?", { job })
    return ok and (row and tonumber(row.total) or 0) >= max
end

local function galleryPhoto(row)
    local ok, metadata = pcall(json.decode, row.metadata or "")
    return {
        id = row.id,
        url = row.url,
        image_id = row.image_id,
        folder = row.folder,
        media_type = row.media_type,
        metadata = ok and type(metadata) == "table" and metadata or nil,
        taken_by = row.taken_by,
        created_at = os.date("!%Y-%m-%dT%H:%M:%SZ", math.floor(tonumber(row.created_ts) or os.time()))
    }
end

local function galleryMetadata(value)
    if type(value) ~= "table" then return nil end
    local name, description = cleanText(value.name, 150), cleanText(value.description, 300)
    if not name and not description then return nil end
    return json.encode({ name = name, description = description })
end

--- Stores an uploaded file in a job's gallery. entry: url, image_id, folder, media_type, metadata.
---@return table|nil photo, string|nil error
function Sky_Jobs.Gallery.Add(source, job, entry)
    entry = type(entry) == "table" and entry or {}
    if type(job) ~= "string" or job == "" then return nil, "no_job" end
    if not Sky_Jobs.Uploads.IsAllowedUrl(entry.url) then return nil, "invalid_url" end
    if Sky_Jobs.Gallery.IsFull(job) then return nil, "gallery_full" end

    local imageId = entry.image_id ~= nil and cleanText(tostring(entry.image_id), 128) or nil
    local mediaType = entry.media_type == "video" and "video" or "image"
    local folder = Sky_Jobs.Gallery.Folder(entry.folder)
    local takenBy = cleanText(GetPlayerFullName(source), 100) or "Unknown"
    local ok, id = pcall(MySQL.insert.await, [[
        INSERT INTO sky_jobs_gallery_photos (job, url, image_id, folder, media_type, metadata, taken_by_identifier, taken_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ]], { job, entry.url, imageId, folder, mediaType, galleryMetadata(entry.metadata), Sky_Jobs.GetPlayerIdentifier(source), takenBy })
    if not ok or not id then return nil, "save_failed" end

    return galleryPhoto({
        id = id, url = entry.url, image_id = imageId, folder = folder, media_type = mediaType,
        metadata = galleryMetadata(entry.metadata), taken_by = takenBy, created_ts = os.time()
    })
end

function Sky_Jobs.Gallery.List(job, limit, offset)
    limit = math.max(1, math.min(100, math.floor(tonumber(limit) or 36)))
    offset = math.max(0, math.floor(tonumber(offset) or 0))
    local ok, rows = pcall(MySQL.query.await, [[
        SELECT id, url, image_id, folder, media_type, metadata, taken_by, UNIX_TIMESTAMP(created_at) AS created_ts
        FROM sky_jobs_gallery_photos WHERE job = ? ORDER BY id DESC LIMIT ? OFFSET ?
    ]], { job, limit, offset })
    if not ok then return nil, "load_failed" end
    local photos = {}
    for _, row in ipairs(type(rows) == "table" and rows or {}) do photos[#photos + 1] = galleryPhoto(row) end
    return photos
end

function Sky_Jobs.Gallery.Delete(job, id)
    id = math.floor(tonumber(id) or 0)
    if id <= 0 then return false, "invalid_photo" end
    local ok, affected = pcall(MySQL.update.await, "DELETE FROM sky_jobs_gallery_photos WHERE id = ? AND job = ?", { id, job })
    if not ok then return false, "delete_failed" end
    if (tonumber(affected) or 0) < 1 then return false, "not_found" end
    return true
end

AddEventHandler("playerDropped", function()
    lastPresignAt[source] = nil
    uploadCredits[source] = nil
end)

CreateThread(function()
    Wait(1000)
    if uploadToken() == "" then
        print(("[sky_jobs_base] Uploads are off: camera photos, the gallery, chat images and bodycam clips need an upload token. Add `set %s \"YOUR_FIVEMANAGE_API_TOKEN\"` to server.cfg (see Config.Uploads)."):format(uploadTokenConvar()))
    elseif not uploadEndpoint() then
        print("[sky_jobs_base] Uploads are off: Config.Uploads.presignedUrlEndpoint is not a valid URL.")
    end
end)

-- -----------------------------------------------------
--  TABLET APPS & RESTRICTIONS
-- -----------------------------------------------------

-- Keys of the apps / classifications this player's grade may not use.
Sky.Cb.Register("sky_jobs_base:getPlayerRestrictedTabletApps", function(source)
    return { success = true, data = Sky_Jobs.GetPlayerRestrictions(source).tablet_apps }
end)

Sky.Cb.Register("sky_jobs_base:getPlayerRestrictedDocumentClassifications", function(source)
    return { success = true, data = Sky_Jobs.GetPlayerRestrictions(source).document_classifications }
end)

-- -----------------------------------------------------
--  JOB ROSTER (online + offline members)
-- -----------------------------------------------------

local function onlineJobMembers(job)
    local online = {}
    for _, s in ipairs(GetPlayers()) do
        local p = tonumber(s)
        if p and Sky_Jobs.PlayerCache.GetJob(p) == job then
            local identifier = Sky_Jobs.GetPlayerIdentifier(p)
            if identifier then
                online[identifier] = {
                    identifier = identifier,
                    source = p,
                    grade = Sky_Jobs.PlayerCache.GetJobGrade(p),
                    name = GetPlayerFullName(p),
                    onduty = Sky_Jobs.PlayerCache.IsOnDuty(p)
                }
            end
        end
    end
    return online
end

-- Every holder of the job (qbx player_groups read fresh; other frameworks via Sky.FW).
local function frameworkJobUsers(job)
    local users = {}
    local fwUsers = Sky and Sky.FW and Sky.FW.GetJobUsers and Sky.FW.GetJobUsers(job)
    fwUsers = type(fwUsers) == "table" and fwUsers or {}

    if GetResourceState("qbx_core") == "started" then
        local ok, members = pcall(function()
            return exports.qbx_core:GetGroupMembers(job, "job")
        end)
        if ok and type(members) == "table" then
            local names = {}
            for _, u in ipairs(fwUsers) do
                if type(u) == "table" and u.identifier then names[tostring(u.identifier)] = u.name end
            end
            for _, m in ipairs(members) do
                if type(m) == "table" and m.citizenid then
                    local id = tostring(m.citizenid)
                    users[#users + 1] = { identifier = id, grade = math.floor(tonumber(m.grade) or 0), name = names[id] }
                end
            end
            return users
        end
    end

    for _, u in ipairs(fwUsers) do
        if type(u) == "table" and u.identifier then
            users[#users + 1] = { identifier = tostring(u.identifier), grade = math.floor(tonumber(u.job_grade or u.grade) or 0), name = u.name }
        end
    end
    return users
end

-- identifier -> { identifier, grade, name, source?, onduty }
local function getJobRoster(job)
    local roster = onlineJobMembers(job)
    for _, u in ipairs(frameworkJobUsers(job)) do
        if not roster[u.identifier] then
            roster[u.identifier] = { identifier = u.identifier, grade = u.grade, name = u.name or u.identifier, onduty = false }
        end
    end
    return roster
end

-- A member of `job` by server id (online, primary job) or by identifier.
local function findJobMember(job, identifier)
    local asSource = tonumber(identifier)
    if asSource and GetPlayerName(asSource) then
        if Sky_Jobs.PlayerCache.GetJob(asSource) ~= job then return nil end
        local id = Sky_Jobs.GetPlayerIdentifier(asSource)
        if not id then return nil end
        return { identifier = id, source = asSource, grade = Sky_Jobs.PlayerCache.GetJobGrade(asSource), name = GetPlayerFullName(asSource) }
    end
    if type(identifier) ~= "string" or identifier == "" then return nil end
    return getJobRoster(job)[identifier]
end

local function memberRow(member, job, info, me)
    return {
        id = member.identifier,
        identifier = member.identifier,
        online_source = member.source,
        source = member.source,
        name = member.name or member.identifier,
        grade = member.grade,
        grade_label = gradeLabel(info, member.grade),
        job = job,
        job_label = info and info.label or job,
        onduty = member.onduty == true,
        isOnline = member.source ~= nil,
        is_self = member.identifier == me,
        last_online_timestamp = member.source and os.time() or nil
    }
end

local function memberRows(src)
    local job = Sky_Jobs.GetEmployment(src)
    if not job then return { success = false, error = "no_job" } end
    local info, me = getJobInfo(job), Sky_Jobs.GetPlayerIdentifier(src)
    local rows = {}
    for _, member in pairs(getJobRoster(job)) do
        rows[#rows + 1] = memberRow(member, job, info, me)
    end
    table.sort(rows, function(a, b)
        if a.grade ~= b.grade then return a.grade > b.grade end
        return tostring(a.name) < tostring(b.name)
    end)
    return { success = true, data = rows }
end

-- -----------------------------------------------------
--  CHAT
-- -----------------------------------------------------

local CHAT_TEXT_LIMIT = 1000
local lastChatSend = {}

AddEventHandler("playerDropped", function()
    lastChatSend[source] = nil
end)

local function chatContext(source)
    local src = tonumber(source)
    local job = Sky_Jobs.GetEmployment(src)
    local me = Sky_Jobs.GetPlayerIdentifier(src)
    if not job or not me then return nil end
    return { src = src, job = job, me = me, name = GetPlayerFullName(src) }
end

local function dmChatId(a, b)
    if a > b then a, b = b, a end
    return ("dm:%s:%s"):format(a, b)
end

local function getChatGroup(groupId)
    if type(groupId) ~= "string" and type(groupId) ~= "number" then return nil end
    local ok, row = pcall(MySQL.single.await, "SELECT id, job, name, created_by FROM sky_jobs_chat_groups WHERE id = ? LIMIT 1", { tostring(groupId) })
    return ok and row or nil
end

local function groupMemberIds(group)
    local ids, seen = {}, {}
    local function add(id)
        if type(id) == "string" and id ~= "" and not seen[id] then
            seen[id] = true
            ids[#ids + 1] = id
        end
    end
    add(group.created_by)
    local ok, rows = pcall(MySQL.query.await, "SELECT identifier FROM sky_jobs_chat_group_members WHERE group_id = ?", { group.id })
    for _, row in ipairs(ok and type(rows) == "table" and rows or {}) do add(row.identifier) end
    return ids, seen
end

-- Which chat a payload addresses, checked against the caller: own job room, a group of the
-- caller's job they belong to, or a private chat that always includes the caller.
local function resolveChat(ctx, payload)
    payload = type(payload) == "table" and payload or {}
    local groupId = payload.group_id or payload.groupId or payload.group
    if payload.scope == "group" or (groupId ~= nil and payload.scope ~= "private") then
        local group = getChatGroup(groupId)
        if not group or group.job ~= ctx.job then return nil, "group_not_found" end
        local ids, members = groupMemberIds(group)
        if not members[ctx.me] then return nil, "not_a_member" end
        return { scope = "group", chatId = tostring(group.id), group = group, participants = ids }
    end
    if payload.scope == "private" or payload.target ~= nil then
        local target = payload.target
        if type(target) ~= "string" or target == "" or #target > 64 or target == ctx.me then
            return nil, "invalid_target"
        end
        return { scope = "private", chatId = dmChatId(ctx.me, target), target = target, participants = { ctx.me, target } }
    end
    return { scope = "room", chatId = "room:" .. ctx.job }
end

local function isoTime(ts)
    return os.date("!%Y-%m-%dT%H:%M:%SZ", math.floor(tonumber(ts) or os.time()))
end

local function toChatMessage(row, me, groupId)
    return {
        id = row.id,
        message = row.message ~= "" and row.message or nil,
        image_url = row.image_url,
        author = row.sender_name,
        sender_identifier = row.sender_identifier,
        recipient_identifier = row.recipient_identifier,
        group_id = groupId,
        created_at = isoTime(row.timestamp),
        is_self = row.sender_identifier == me,
        is_read = row.is_read == true or tonumber(row.is_read) == 1
    }
end

-- identifier -> server id for the given identifiers that are online.
local function onlineSourcesFor(identifiers)
    local wanted, out = {}, {}
    for _, id in ipairs(identifiers) do wanted[id] = true end
    for _, s in ipairs(GetPlayers()) do
        local p = tonumber(s)
        local id = p and Sky_Jobs.GetPlayerIdentifier(p)
        if id and wanted[id] then out[#out + 1] = p end
    end
    return out
end

local function chatRecipients(ctx, chat)
    if chat.scope == "room" then
        local list = {}
        for _, member in pairs(onlineJobMembers(ctx.job)) do list[#list + 1] = member.source end
        return list
    end
    return onlineSourcesFor(chat.participants)
end

Sky.Cb.Register("sky_jobs_base:chat:getMessages", function(source, payload)
    local ctx = chatContext(source)
    if not ctx then return { success = false, error = "no_job" } end
    local chat, err = resolveChat(ctx, payload)
    if not chat then return { success = false, error = err } end

    local limit = math.max(1, math.min(200, math.floor(tonumber(type(payload) == "table" and payload.limit) or 100)))
    local ok, rows = pcall(MySQL.query.await, ([[
        SELECT id, sender_identifier, recipient_identifier, sender_name, message, timestamp, is_read%s
        FROM sky_jobs_chat_messages WHERE chat_id = ? ORDER BY id DESC LIMIT ?
    ]]):format(chatSupportsImages and ", image_url" or ""), { chat.chatId, limit })
    if not ok then return { success = false, error = "load_failed" } end

    local messages, unreadIds = {}, {}
    for i = #rows, 1, -1 do
        local row = rows[i]
        local message = toChatMessage(row, ctx.me, chat.scope == "group" and chat.chatId or nil)
        if chat.scope == "private" and row.recipient_identifier == ctx.me and not message.is_read then
            unreadIds[#unreadIds + 1] = row.id
            message.is_read = true
        end
        messages[#messages + 1] = message
    end

    if chat.scope == "private" then
        pcall(MySQL.update.await, "UPDATE sky_jobs_chat_messages SET is_read = 1 WHERE chat_id = ? AND recipient_identifier = ? AND is_read = 0", { chat.chatId, ctx.me })
        if #unreadIds > 0 then
            for _, p in ipairs(onlineSourcesFor({ chat.target })) do
                TriggerClientEvent("sky_jobs_base:chat:messageUpdate", p, {
                    type = "read_receipt", scope = "private", message_ids = unreadIds,
                    sender_identifier = ctx.me, recipient_identifier = chat.target
                })
            end
        end
    end

    return { success = true, data = messages }
end)

Sky.Cb.Register("sky_jobs_base:chat:sendMessage", function(source, data)
    local ctx = chatContext(source)
    if not ctx then return { success = false, error = "no_job" } end
    local now = GetGameTimer()
    if lastChatSend[ctx.src] and now - lastChatSend[ctx.src] < 400 then
        return { success = false, error = "too_fast" }
    end

    data = type(data) == "table" and data or {}
    local text = cleanText(data.message or data.text, CHAT_TEXT_LIMIT)
    local imageUrl = data.image_url or data.imageUrl
    if imageUrl ~= nil and imageUrl ~= "" then
        if not chatSupportsImages then return { success = false, error = "upload_not_configured" } end
        if not Sky_Jobs.Uploads.IsAllowedUrl(imageUrl) then return { success = false, error = "invalid_url" } end
    else
        imageUrl = nil
    end
    if not text and not imageUrl then return { success = false, error = "empty_message" } end

    local chat, err = resolveChat(ctx, data)
    if not chat then return { success = false, error = err } end
    if chat.scope == "private" and not getJobRoster(ctx.job)[chat.target] then
        return { success = false, error = "not_a_member" }
    end
    lastChatSend[ctx.src] = now

    local ts = os.time()
    local ok, msgId
    if imageUrl then
        ok, msgId = pcall(MySQL.insert.await, [[
            INSERT INTO sky_jobs_chat_messages (chat_id, sender_identifier, recipient_identifier, sender_name, message, timestamp, image_url)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ]], { chat.chatId, ctx.me, chat.target, cleanText(ctx.name, 100) or "Unknown", text or "", ts, imageUrl })
    else
        ok, msgId = pcall(MySQL.insert.await, [[
            INSERT INTO sky_jobs_chat_messages (chat_id, sender_identifier, recipient_identifier, sender_name, message, timestamp)
            VALUES (?, ?, ?, ?, ?, ?)
        ]], { chat.chatId, ctx.me, chat.target, cleanText(ctx.name, 100) or "Unknown", text, ts })
    end
    if not ok or not msgId then return { success = false, error = "send_failed" } end

    local groupId = chat.scope == "group" and chat.chatId or nil
    local message = toChatMessage({
        id = msgId, sender_identifier = ctx.me, recipient_identifier = chat.target,
        sender_name = ctx.name, message = text or "", image_url = imageUrl, timestamp = ts, is_read = 0
    }, ctx.me, groupId)

    local update = {
        scope = chat.scope, group_id = groupId, sender_identifier = ctx.me,
        recipient_identifier = chat.target, message = message
    }
    for _, p in ipairs(chatRecipients(ctx, chat)) do
        TriggerClientEvent("sky_jobs_base:chat:messageUpdate", p, update)
    end

    return { success = true, data = message }
end)

Sky.Cb.Register("sky_jobs_base:chat:getUnreadMessages", function(source, payload)
    local ctx = chatContext(source)
    if not ctx then return { success = true, data = { count = 0, messages = {} } } end
    local limit = math.max(1, math.min(200, math.floor(tonumber(type(payload) == "table" and payload.limit) or 60)))
    local ok, rows = pcall(MySQL.query.await, ([[
        SELECT id, sender_identifier, recipient_identifier, sender_name, message, timestamp, is_read%s
        FROM sky_jobs_chat_messages WHERE recipient_identifier = ? AND is_read = 0 ORDER BY id DESC LIMIT ?
    ]]):format(chatSupportsImages and ", image_url" or ""), { ctx.me, limit })
    local countOk, countRow = pcall(MySQL.single.await, "SELECT COUNT(*) AS total FROM sky_jobs_chat_messages WHERE recipient_identifier = ? AND is_read = 0", { ctx.me })
    local messages = {}
    for _, row in ipairs(ok and type(rows) == "table" and rows or {}) do
        messages[#messages + 1] = toChatMessage(row, ctx.me)
    end
    return { success = true, data = { count = countOk and countRow and tonumber(countRow.total) or #messages, messages = messages } }
end)

local function myGroups(ctx)
    local ok, rows = pcall(MySQL.query.await, [[
        SELECT g.id, g.name, g.created_by FROM sky_jobs_chat_groups g
        WHERE g.job = ? AND (g.created_by = ? OR EXISTS (
            SELECT 1 FROM sky_jobs_chat_group_members m WHERE m.group_id = g.id AND m.identifier = ?))
        ORDER BY g.created_at DESC
    ]], { ctx.job, ctx.me, ctx.me })
    return ok and type(rows) == "table" and rows or {}
end

Sky.Cb.Register("sky_jobs_base:chat:getOpenChats", function(source, payload)
    local ctx = chatContext(source)
    if not ctx then return { success = false, error = "no_job" } end
    local limit = math.max(1, math.min(200, math.floor(tonumber(type(payload) == "table" and payload.limit) or 120)))

    local chats, lastIds, byChat = {}, {}, {}
    for _, g in ipairs(myGroups(ctx)) do
        local entry = { id = tostring(g.id), scope = "group", label = g.name, created_by = g.created_by }
        chats[#chats + 1] = entry
        byChat[entry.id] = entry
    end

    local okDm, dms = pcall(MySQL.query.await, [[
        SELECT chat_id, MAX(id) AS last_id FROM sky_jobs_chat_messages
        WHERE recipient_identifier = ? OR (sender_identifier = ? AND recipient_identifier IS NOT NULL)
        GROUP BY chat_id ORDER BY last_id DESC LIMIT ?
    ]], { ctx.me, ctx.me, limit })
    for _, row in ipairs(okDm and type(dms) == "table" and dms or {}) do
        lastIds[#lastIds + 1] = row.last_id
    end

    if #chats > 0 then
        local placeholders, params = {}, {}
        for _, c in ipairs(chats) do placeholders[#placeholders + 1] = "?"; params[#params + 1] = c.id end
        local okLast, rows = pcall(MySQL.query.await, ("SELECT chat_id, MAX(id) AS last_id FROM sky_jobs_chat_messages WHERE chat_id IN (%s) GROUP BY chat_id"):format(table.concat(placeholders, ",")), params)
        for _, row in ipairs(okLast and type(rows) == "table" and rows or {}) do lastIds[#lastIds + 1] = row.last_id end
    end

    if #lastIds > 0 then
        local placeholders = {}
        for i = 1, #lastIds do placeholders[i] = "?" end
        local okRows, rows = pcall(MySQL.query.await, ("SELECT id, chat_id, sender_identifier, recipient_identifier, sender_name, message, timestamp FROM sky_jobs_chat_messages WHERE id IN (%s)"):format(table.concat(placeholders, ",")), lastIds)
        for _, row in ipairs(okRows and type(rows) == "table" and rows or {}) do
            local entry = byChat[row.chat_id]
            if not entry and row.recipient_identifier then
                local other = row.sender_identifier == ctx.me and row.recipient_identifier or row.sender_identifier
                entry = { id = other, scope = "private" }
                chats[#chats + 1] = entry
            end
            if entry then
                entry.last_message_at = isoTime(row.timestamp)
                entry.last_message = row.message ~= "" and row.message or nil
                entry.last_author = row.sender_name
            end
        end
    end

    return { success = true, data = chats }
end)

Sky.Cb.Register("sky_jobs_base:chat:getGroups", function(source)
    local ctx = chatContext(source)
    if not ctx then return { success = false, error = "no_job" } end
    return { success = true, data = myGroups(ctx) }
end)

-- Only identifiers of current members of the caller's job, plus the creator.
local function sanitizeGroupMembers(ctx, members)
    local roster = getJobRoster(ctx.job)
    local out, seen = {}, { [ctx.me] = true }
    for _, id in ipairs(type(members) == "table" and members or {}) do
        id = tostring(id)
        if not seen[id] and roster[id] and #out < 50 then
            seen[id] = true
            out[#out + 1] = id
        end
    end
    return out
end

local function replaceGroupMembers(groupId, creator, members)
    pcall(MySQL.query.await, "DELETE FROM sky_jobs_chat_group_members WHERE group_id = ?", { groupId })
    for _, id in ipairs(members) do
        pcall(MySQL.insert.await, "INSERT IGNORE INTO sky_jobs_chat_group_members (group_id, identifier) VALUES (?, ?)", { groupId, id })
    end
    pcall(MySQL.insert.await, "INSERT IGNORE INTO sky_jobs_chat_group_members (group_id, identifier) VALUES (?, ?)", { groupId, creator })
end

local function groupPayload(group)
    local ids = groupMemberIds(group)
    return { id = tostring(group.id), name = group.name, created_by = group.created_by, members = ids, admins = { group.created_by } }
end

-- The caller's group, editable only by its creator.
local function ownedGroup(ctx, data)
    data = type(data) == "table" and data or {}
    local group = getChatGroup(data.group_id or data.groupId or data.group)
    if not group or group.job ~= ctx.job then return nil, "group_not_found" end
    if group.created_by ~= ctx.me then return nil, "not_group_owner" end
    return group
end

Sky.Cb.Register("sky_jobs_base:chat:createGroup", function(source, data)
    local ctx = chatContext(source)
    if not ctx then return { success = false, error = "no_job" } end
    data = type(data) == "table" and data or {}
    local name = cleanText(data.name, 100)
    if not name then return { success = false, error = "invalid_name" } end

    local groupId
    for _ = 1, 3 do
        local candidate = ("grp_%d_%06d"):format(os.time(), math.random(0, 999999))
        local ok = pcall(MySQL.insert.await, "INSERT INTO sky_jobs_chat_groups (id, job, name, created_by) VALUES (?, ?, ?, ?)", { candidate, ctx.job, name, ctx.me })
        if ok and getChatGroup(candidate) then
            groupId = candidate
            break
        end
    end
    if not groupId then return { success = false, error = "create_failed" } end

    replaceGroupMembers(groupId, ctx.me, sanitizeGroupMembers(ctx, data.members))
    return { success = true, data = groupPayload({ id = groupId, name = name, created_by = ctx.me }) }
end)

Sky.Cb.Register("sky_jobs_base:chat:getGroup", function(source, groupId)
    local ctx = chatContext(source)
    if not ctx then return { success = false, error = "no_job" } end
    local chat, err = resolveChat(ctx, { scope = "group", group_id = type(groupId) == "table" and (groupId.group_id or groupId.groupId) or groupId })
    if not chat then return { success = false, error = err } end
    return { success = true, data = groupPayload(chat.group) }
end)

Sky.Cb.Register("sky_jobs_base:chat:updateGroup", function(source, data)
    local ctx = chatContext(source)
    if not ctx then return { success = false, error = "no_job" } end
    local group, err = ownedGroup(ctx, data)
    if not group then return { success = false, error = err } end
    local name = cleanText(data.name, 100)
    if not name then return { success = false, error = "invalid_name" } end
    local ok = pcall(MySQL.update.await, "UPDATE sky_jobs_chat_groups SET name = ? WHERE id = ?", { name, group.id })
    if not ok then return { success = false, error = "save_failed" } end
    group.name = name
    return { success = true, data = groupPayload(group) }
end)

Sky.Cb.Register("sky_jobs_base:chat:setGroupMembers", function(source, data)
    local ctx = chatContext(source)
    if not ctx then return { success = false, error = "no_job" } end
    local group, err = ownedGroup(ctx, data)
    if not group then return { success = false, error = err } end
    replaceGroupMembers(group.id, group.created_by, sanitizeGroupMembers(ctx, data.members))
    return { success = true, data = groupPayload(group) }
end)

-- Only the creator manages a group; there is no separate admin role.
local function groupAdminsUnsupported()
    return { success = false, error = "Only the group creator can manage this group." }
end
Sky.Cb.Register("sky_jobs_base:chat:setGroupOwner", groupAdminsUnsupported)
Sky.Cb.Register("sky_jobs_base:chat:removeGroupAdmin", groupAdminsUnsupported)

Sky.Cb.Register("sky_jobs_base:chat:deleteGroup", function(source, data)
    local ctx = chatContext(source)
    if not ctx then return { success = false, error = "no_job" } end
    local group, err = ownedGroup(ctx, data)
    if not group then return { success = false, error = err } end
    pcall(MySQL.query.await, "DELETE FROM sky_jobs_chat_group_members WHERE group_id = ?", { group.id })
    pcall(MySQL.query.await, "DELETE FROM sky_jobs_chat_messages WHERE chat_id = ?", { tostring(group.id) })
    pcall(MySQL.query.await, "DELETE FROM sky_jobs_chat_groups WHERE id = ?", { group.id })
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:chat:leaveGroup", function(source, data)
    local ctx = chatContext(source)
    if not ctx then return { success = false, error = "no_job" } end
    data = type(data) == "table" and data or {}
    local group = getChatGroup(data.group_id or data.groupId or data.group)
    if not group or group.job ~= ctx.job then return { success = false, error = "group_not_found" } end
    if group.created_by == ctx.me then
        return { success = false, error = "The group creator cannot leave; delete the group instead." }
    end
    pcall(MySQL.query.await, "DELETE FROM sky_jobs_chat_group_members WHERE group_id = ? AND identifier = ?", { group.id, ctx.me })
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:chat:setProfilePhoto", function(source, data)
    return { success = false, error = "upload_not_configured" }
end)

-- -----------------------------------------------------
--  CALENDAR
-- -----------------------------------------------------

local function validDate(value)
    if type(value) ~= "string" then return nil end
    local y, m, d = value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
    y, m, d = tonumber(y), tonumber(m), tonumber(d)
    if not y or m < 1 or m > 12 or d < 1 or d > 31 then return nil end
    return value
end

Sky.Cb.Register("sky_jobs_base:calendar:addEvent", function(source, data)
    local job = Sky_Jobs.GetEmployment(source)
    if not job then return { success = false, error = "no_job" } end
    data = type(data) == "table" and data or {}

    local title = cleanText(data.title, 150)
    local date = validDate(data.date)
    if not title or not date then return { success = false, error = "invalid_event" } end
    local time = type(data.time) == "string" and data.time:match("^%d%d:%d%d$") or nil
    local color = type(data.color) == "string" and (data.color:match("^#%x%x%x%x%x%x$") or data.color:match("^#%x%x%x$")) or "#4f79ff"

    local ok, id = pcall(MySQL.insert.await, [[
        INSERT INTO sky_jobs_calendar_events (job, title, description, date, time, color, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ]], { job, title, cleanText(data.description, 2000), date, time, color, cleanText(GetPlayerFullName(source), 64) })
    if not ok or not id then return { success = false, error = "save_failed" } end

    return { success = true, data = { id = id, title = title, date = date, time = time, color = color } }
end)

Sky.Cb.Register("sky_jobs_base:calendar:getEvents", function(source, payload)
    local job = Sky_Jobs.GetEmployment(source)
    if not job then return { success = false, error = "no_job" } end
    payload = type(payload) == "table" and payload or {}
    local startDate = validDate(payload.start) or os.date("%Y-%m-01")
    local endDate = validDate(payload["end"]) or os.date("%Y-%m-31")

    local ok, rows = pcall(MySQL.query.await, [[
        SELECT id, title, description, date, time, color, created_by
        FROM sky_jobs_calendar_events WHERE job = ? AND date BETWEEN ? AND ?
        ORDER BY date ASC, time ASC LIMIT 500
    ]], { job, startDate, endDate })
    if not ok then return { success = false, error = "load_failed" } end
    return { success = true, data = rows or {} }
end)

-- -----------------------------------------------------
--  MANAGEMENT & MEMBERS CALLBACKS
-- -----------------------------------------------------

local function perm(name)
    return permissionEnum()[name]
end

-- Highest grade an actor may hand out: below their own, or up to the top grade for a
-- boss who holds the top grade.
local function maxAssignableGrade(actor)
    local info = getJobInfo(actor.job)
    if actor.boss and info and info.top and actor.grade >= info.top then return info.top end
    return actor.grade - 1
end

local function buildManagementData(source)
    local actor = getActor(source)
    if not actor then return nil end
    local canMoney = actor.can(perm("MANAGE_MONEY"))
    local canLogs = canMoney or actor.can(perm("VIEW_LOGS"))
    local canMembers = actor.can(perm("MANAGE_MEMBERS"))
    local canRoles = actor.can(perm("MANAGE_ROLES"))
    local sections = {
        dashboard = canLogs or canMembers or canRoles,
        finance = canLogs,
        transactions = canMoney,
        members = canMembers,
        roles = canRoles,
        logs = canLogs
    }

    local info = getJobInfo(actor.job)
    local jobGrades = {}
    for _, g in ipairs(info and info.grades or {}) do
        jobGrades[#jobGrades + 1] = { grade = g.grade, label = g.label, salary = g.salary }
    end

    local dutyMembers = {}
    if sections.dashboard then
        for _, member in pairs(onlineJobMembers(actor.job)) do
            dutyMembers[#dutyMembers + 1] = { name = member.name, onduty = member.onduty == true, gradeLabel = gradeLabel(info, member.grade) }
        end
    end

    local def = Sky_Jobs.GetJobDefinition(actor.job)
    return {
        job = actor.job,
        jobLabel = info and info.label or actor.job,
        jobColor = def and def.color or nil,
        balance = canLogs and Sky_Jobs.GetSocietyBalance(actor.job) or 0,
        currency = "money",
        playerGrade = actor.grade,
        jobGrades = jobGrades,
        sections = sections,
        -- Grade names, salaries and the grade list belong to the framework (qbx_core
        -- shared/jobs.lua); the menu only edits permissions.
        editing = { roleName = false, salary = false, salaryInterval = false, roleStructure = false },
        salaryEnabled = false,
        dutyMembers = dutyMembers,
        mostActiveMembers = {},
        storageContainsWeapons = false,
        framework = detectFramework()
    }
end

Sky.Cb.Register("sky_jobs_base:getJobData", function(source)
    local data = buildManagementData(source)
    if not data then return { success = false, error = "no_job" } end
    return { success = true, data = data }
end)

Sky.Cb.Register("sky_jobs_base:getJobMembers", function(source)
    return memberRows(tonumber(source))
end)

Sky.Cb.Register("sky_jobs_base:getAllJobMembers", function(source)
    return memberRows(tonumber(source))
end)

-- qbx_core: change the grade of the job itself (works offline and for secondary jobs).
local function setMemberGrade(job, member, grade)
    if GetResourceState("qbx_core") == "started" then
        local ok, result = pcall(function()
            return exports.qbx_core:AddPlayerToJob(member.identifier, job, grade)
        end)
        return ok and result == true
    end
    if not (Sky and Sky.FW and Sky.FW.SetJob) then return false end
    return Sky.FW.SetJob(member.source or member.identifier, job, grade) == true
end

local function removeMemberFromJob(job, member)
    local defaultJob = Config and Config.MultiJob and Config.MultiJob.defaultJob or "unemployed"
    local defaultGrade = Config and Config.MultiJob and tonumber(Config.MultiJob.defaultGrade) or 0
    if GetResourceState("qbx_core") == "started" then
        local ok, result = pcall(function()
            return exports.qbx_core:RemovePlayerFromJob(member.identifier, job)
        end)
        if not (ok and result == true) then return false end
        -- RemovePlayerFromJob raises no job update event; this one tells the player's client.
        if member.source and Sky_Jobs.PlayerCache.GetJob(member.source) == "unemployed" then
            SetPlayerJob(member.source, "unemployed", 0)
        end
        return true
    end
    if not (Sky and Sky.FW and Sky.FW.SetJob) then return false end
    return Sky.FW.SetJob(member.source or member.identifier, defaultJob, defaultGrade) == true
end

local function nextGrade(info, current, step)
    local best = nil
    for _, g in ipairs(info and info.grades or {}) do
        if step > 0 and g.grade > current and (not best or g.grade < best) then best = g.grade end
        if step < 0 and g.grade < current and (not best or g.grade > best) then best = g.grade end
    end
    return best
end

Sky.Cb.Register("sky_jobs_base:setMember", function(source, action, identifier)
    local actor = getActor(source)
    if not actor or not actor.can(perm("MANAGE_MEMBERS")) then return { success = false, error = "no_permission" } end

    local member = findJobMember(actor.job, identifier)
    if not member then return { success = false, error = "not_a_member" } end
    if member.identifier == Sky_Jobs.GetPlayerIdentifier(actor.src) then return { success = false, error = "cannot_target_self" } end
    if member.grade >= actor.grade then return { success = false, error = "insufficient_rank" } end

    local info = getJobInfo(actor.job)
    local actorName = GetPlayerFullName(actor.src)
    local memberName = member.name or member.identifier

    if action == "promote" or action == "demote" then
        local newGrade = nextGrade(info, member.grade, action == "promote" and 1 or -1)
        if not newGrade then return { success = false, error = action == "promote" and "max_grade" or "min_grade" } end
        if action == "promote" and newGrade > maxAssignableGrade(actor) then return { success = false, error = "insufficient_rank" } end
        if not setMemberGrade(actor.job, member, newGrade) then return { success = false, error = "update_failed" } end

        logJobTransaction(actor.job, action == "promote" and "member_promoted" or "member_demoted", 0, actorName,
            ("%s: %s -> %s"):format(memberName, gradeLabel(info, member.grade), gradeLabel(info, newGrade)))
        if member.source then
            TriggerClientEvent("sky_jobs_base:gradeChanged", member.source,
                { level = member.grade, label = gradeLabel(info, member.grade) }, { level = newGrade, label = gradeLabel(info, newGrade) })
        end
        return { success = true, newGrade = newGrade }
    elseif action == "fire" then
        if not removeMemberFromJob(actor.job, member) then return { success = false, error = "update_failed" } end
        logJobTransaction(actor.job, "member_fired", 0, actorName, memberName)
        if member.source then
            notify(member.source, info and info.label or actor.job, "You have been dismissed from the job.", "error")
        end
        return { success = true }
    end

    return { success = false, error = "invalid_action" }
end)

-- Pending job offers by target server id.
local pendingInvites = {}
local lastInviteSent = {}

AddEventHandler("playerDropped", function()
    pendingInvites[source] = nil
    lastInviteSent[source] = nil
end)

local function closeInvite(target, invite)
    if pendingInvites[target] == invite then pendingInvites[target] = nil end
    TriggerClientEvent("sky_jobs_base:inviteClosed", target, { id = invite.id })
end

Sky.Cb.Register("sky_jobs_base:sendInvite", function(source, playerId, grade)
    local actor = getActor(source)
    if not actor or not actor.can(perm("MANAGE_MEMBERS")) then return { success = false, error = "no_permission" } end

    local now = GetGameTimer()
    if lastInviteSent[actor.src] and now - lastInviteSent[actor.src] < 3000 then return { success = false, error = "too_fast" } end

    local target = math.tointeger(tonumber(playerId))
    if not target or target == actor.src or not GetPlayerName(target) or not Sky_Jobs.GetPlayerIdentifier(target) then
        return { success = false, error = "Player not found or offline" }
    end
    if Sky_Jobs.PlayerCache.GetJob(target) == actor.job then return { success = false, error = "already_member" } end

    local info = getJobInfo(actor.job)
    local newGrade = math.tointeger(tonumber(grade))
    if not newGrade or not (info and info.byLevel[newGrade]) or newGrade < 0 or newGrade > maxAssignableGrade(actor) then
        return { success = false, error = "invalid_grade" }
    end
    if pendingInvites[target] and os.time() < pendingInvites[target].expires then
        return { success = false, error = "invite_pending" }
    end

    lastInviteSent[actor.src] = now
    local ttl = math.max(10, math.floor(tonumber(Config and Config.Invites and Config.Invites.expireSeconds) or 60))
    local invite = {
        id = ("%d-%d-%d"):format(target, now, math.random(1000, 9999)),
        job = actor.job,
        grade = newGrade,
        inviter = actor.src,
        inviterName = GetPlayerFullName(actor.src),
        expires = os.time() + ttl
    }
    pendingInvites[target] = invite

    TriggerClientEvent("sky_jobs_base:inviteReceived", target, {
        id = invite.id,
        jobLabel = info.label,
        gradeLabel = gradeLabel(info, newGrade),
        inviterName = invite.inviterName,
        duration = ttl
    })
    SetTimeout(ttl * 1000, function()
        if pendingInvites[target] == invite then closeInvite(target, invite) end
    end)

    logJobTransaction(actor.job, "invite_sent", 0, invite.inviterName, ("%s (%s)"):format(GetPlayerFullName(target), gradeLabel(info, newGrade)))
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:respondInvite", function(source, inviteId, accepted)
    local src = tonumber(source)
    local invite = src and pendingInvites[src]
    if not invite or invite.id ~= inviteId or os.time() > invite.expires then
        return { success = false, error = "Invite expired" }
    end
    closeInvite(src, invite)

    local info = getJobInfo(invite.job)
    local name = GetPlayerFullName(src)
    if accepted ~= true then
        logJobTransaction(invite.job, "invite_declined", 0, name, info and info.label or invite.job)
        if GetPlayerName(invite.inviter) then
            notify(invite.inviter, "Management", ("%s declined the job offer."):format(name), "info")
            TriggerClientEvent("sky_jobs_base:inviteResult", invite.inviter, { accepted = false })
        end
        return { success = true }
    end

    if not SetPlayerJob(src, invite.job, invite.grade) then
        return { success = false, error = "hire_failed" }
    end
    logJobTransaction(invite.job, "invite_accepted", 0, name, gradeLabel(info, invite.grade))
    notify(src, info and info.label or invite.job, ("You joined as %s."):format(gradeLabel(info, invite.grade)), "success")
    if GetPlayerName(invite.inviter) then
        notify(invite.inviter, "Management", ("%s accepted the job offer."):format(name), "success")
        TriggerClientEvent("sky_jobs_base:inviteResult", invite.inviter, { accepted = true })
    end
    return { success = true }
end)

-- -----------------------------------------------------
--  FINANCES, TRANSACTIONS & BONUSES
-- -----------------------------------------------------

local function toLogRow(row, transactionsView)
    local action = LEGACY_ACTIONS[row.type] or row.type or "unknown"
    local amount = tonumber(row.amount) or 0
    local isMoney = MONEY_CREDIT[action] or MONEY_DEBIT[action]
    local content
    if isMoney then
        content = Sky.Currency.Format(amount)
        if not transactionsView and type(row.reason) == "string" and row.reason ~= "" then
            content = content .. " - " .. row.reason
        end
    else
        content = row.reason or ""
    end
    return { id = row.id, timestamp = tonumber(row.ts) or os.time(), name = row.sender or "System", action = action, content = content, amount = amount }
end

local function moneyTypePlaceholders()
    local marks = {}
    for i = 1, #MONEY_TYPE_LIST do marks[i] = "?" end
    return table.concat(marks, ",")
end

Sky.Cb.Register("sky_jobs_base:getFinanceSnapshot", function(source)
    local actor = getActor(source)
    if not actor or not (actor.can(perm("VIEW_LOGS")) or actor.can(perm("MANAGE_MONEY"))) then
        return { success = false, error = "no_permission" }
    end

    local days = math.max(1, math.min(90, math.floor(tonumber(Config and Config.ManagementFinance and Config.ManagementFinance.historyDays) or 14)))
    local now = os.time()
    local since = now - (days - 1) * 86400
    local params = { actor.job, os.time({ year = tonumber(os.date("%Y", since)), month = tonumber(os.date("%m", since)), day = tonumber(os.date("%d", since)), hour = 0 }) }
    for _, t in ipairs(MONEY_TYPE_LIST) do params[#params + 1] = t end
    local ok, rows = pcall(MySQL.query.await, ([[
        SELECT type, amount, UNIX_TIMESTAMP(`date`) AS ts FROM sky_jobs_transactions
        WHERE job = ? AND `date` >= FROM_UNIXTIME(?) AND type IN (%s)
    ]]):format(moneyTypePlaceholders()), params)
    if not ok then return { success = false, error = "load_failed" } end

    local timeline, byDate = {}, {}
    for i = days - 1, 0, -1 do
        local key = os.date("%Y-%m-%d", now - i * 86400)
        local point = { date = key, revenue = 0, expenses = 0 }
        timeline[#timeline + 1] = point
        byDate[key] = point
    end

    local totals = { revenue = 0, expenses = 0, profit = 0 }
    local revenue, expenses = {}, {}
    for _, row in ipairs(rows or {}) do
        local action = LEGACY_ACTIONS[row.type] or row.type
        local amount = tonumber(row.amount) or 0
        local point = byDate[os.date("%Y-%m-%d", tonumber(row.ts) or now)]
        local category = FINANCE_CATEGORY[action] or "other"
        if MONEY_CREDIT[action] then
            totals.revenue = totals.revenue + amount
            revenue[category] = (revenue[category] or 0) + amount
            if point then point.revenue = point.revenue + amount end
        else
            totals.expenses = totals.expenses + amount
            expenses[category] = (expenses[category] or 0) + amount
            if point then point.expenses = point.expenses + amount end
        end
    end
    totals.profit = totals.revenue - totals.expenses

    local function toList(map)
        local list = {}
        for key, amount in pairs(map) do list[#list + 1] = { key = key, amount = amount } end
        table.sort(list, function(a, b) return a.amount > b.amount end)
        return list
    end

    return {
        success = true,
        data = {
            totals = totals,
            timeline = timeline,
            revenueCategories = toList(revenue),
            expenseCategories = toList(expenses),
            currency = "money",
            updatedAt = now
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:transactionJobMoney", function(source, transType, amount)
    local actor = getActor(source)
    if not actor or not actor.can(perm("MANAGE_MONEY")) then return { success = false, error = "no_permission" } end
    amount = validAmount(amount)
    if not amount or amount > MAX_BALANCE then return { success = false, error = "Invalid amount" } end

    local job, src = actor.job, actor.src
    local playerName = GetPlayerFullName(src)
    local txType

    if transType == "deposit" then
        local account = "bank"
        if not Sky_Jobs.RemovePlayerMoney(src, account, amount) then
            account = "money"
            if not Sky_Jobs.RemovePlayerMoney(src, account, amount) then
                return { success = false, error = "Insufficient personal funds." }
            end
        end
        if not creditSociety(job, amount) then
            Sky_Jobs.AddPlayerMoney(src, account, amount)
            return { success = false, error = "deposit_failed" }
        end
        txType = "deposited"
    elseif transType == "withdraw" then
        if not debitSociety(job, amount) then
            return { success = false, error = "Insufficient society funds." }
        end
        if not Sky_Jobs.AddPlayerMoney(src, "bank", amount) then
            creditSociety(job, amount)
            return { success = false, error = "payout_failed" }
        end
        txType = "withdrawn"
    else
        return { success = false, error = "Invalid transaction type" }
    end

    logJobTransaction(job, txType, amount, playerName, nil)
    return {
        success = true,
        balance = Sky_Jobs.GetSocietyBalance(job),
        currency = "money",
        data = toLogRow({ id = ("new-%d"):format(GetGameTimer()), type = txType, amount = amount, sender = playerName, ts = os.time() }, true)
    }
end)

Sky.Cb.Register("sky_jobs_base:transactionLogs", function(source, limit, offset)
    local actor = getActor(source)
    if not actor or not (actor.can(perm("VIEW_LOGS")) or actor.can(perm("MANAGE_MONEY"))) then
        return { success = false, error = "no_permission" }
    end
    limit = math.max(1, math.min(200, math.floor(tonumber(limit) or 50)))
    offset = math.max(0, math.floor(tonumber(offset) or 0))

    local params = { actor.job }
    for _, t in ipairs(MONEY_TYPE_LIST) do params[#params + 1] = t end
    params[#params + 1] = limit
    params[#params + 1] = offset
    local ok, rows = pcall(MySQL.query.await, ([[
        SELECT id, type, amount, sender, reason, UNIX_TIMESTAMP(`date`) AS ts FROM sky_jobs_transactions
        WHERE job = ? AND type IN (%s) ORDER BY id DESC LIMIT ? OFFSET ?
    ]]):format(moneyTypePlaceholders()), params)
    if not ok then return { success = false, error = "load_failed" } end

    local list = {}
    for _, row in ipairs(rows or {}) do list[#list + 1] = toLogRow(row, true) end
    return { success = true, data = list, hasMore = #list >= limit }
end)

Sky.Cb.Register("sky_jobs_base:getJobLogs", function(source, from, to)
    local actor = getActor(source)
    if not actor or not (actor.can(perm("VIEW_LOGS")) or actor.can(perm("MANAGE_MONEY"))) then
        return { success = false, error = "no_permission" }
    end
    local now = os.time()
    to = math.floor(tonumber(to) or now) + 86399
    from = math.floor(tonumber(from) or (now - 7 * 86400))
    if from > to then from, to = to, from end
    from = math.max(from, to - 366 * 86400)

    local ok, rows = pcall(MySQL.query.await, [[
        SELECT id, type, amount, sender, reason, UNIX_TIMESTAMP(`date`) AS ts FROM sky_jobs_transactions
        WHERE job = ? AND `date` BETWEEN FROM_UNIXTIME(?) AND FROM_UNIXTIME(?) ORDER BY id DESC LIMIT 500
    ]], { actor.job, from, to })
    if not ok then return { success = false, error = "load_failed" } end

    local list = {}
    for _, row in ipairs(rows or {}) do list[#list + 1] = toLogRow(row, false) end
    return { success = true, data = list }
end)

Sky.Cb.Register("sky_jobs_base:giveBonus", function(source, targetId, amount, reason)
    local actor = getActor(source)
    if not actor or not actor.can(perm("MANAGE_MONEY")) then return { success = false, error = "no_permission" } end
    amount = validAmount(amount)
    if not amount or amount > MAX_BALANCE then return { success = false, error = "Invalid amount" } end

    local member = findJobMember(actor.job, targetId)
    if not member then return { success = false, error = "not_a_member" } end
    if not member.source then return { success = false, error = "member_offline" } end

    if not debitSociety(actor.job, amount) then
        return { success = false, error = "Insufficient society funds for bonus" }
    end
    if not Sky_Jobs.AddPlayerMoney(member.source, "bank", amount) then
        creditSociety(actor.job, amount)
        return { success = false, error = "payout_failed" }
    end

    local senderName = GetPlayerFullName(actor.src)
    local note = cleanText(reason, 200)
    logJobTransaction(actor.job, "bonus_paid", amount, senderName, ("%s%s"):format(member.name or member.identifier, note and (": " .. note) or ""))
    TriggerClientEvent("sky_jobs_base:bonusReceived", member.source, { amount = amount, managerName = senderName, currency = "money" })
    return { success = true }
end)

-- Not used by the jobs UI and nothing reads saved specs, so saving is refused honestly.
Sky.Cb.Register("sky_jobs_base:getBillingSpecs", function(source)
    return { success = true, data = {} }
end)

Sky.Cb.Register("sky_jobs_base:saveBillingSpecs", function(source, specs)
    return { success = false, error = "not_implemented" }
end)

-- -----------------------------------------------------
--  ROLES & PERMISSIONS EDITOR
-- -----------------------------------------------------

local OPTION_PERMISSIONS = {
    MANAGE_WAREHOUSE = { options = "items", weapons = "weapons" },
    GARAGE_VEHICLES = { options = "vehicles" },
    TABLET_APPS = { options = "tablet_apps" },
    DOCUMENT_CLASSIFICATIONS = { options = "document_classifications" }
}

-- The roles editor of `actor` may edit `grade`: a grade below their own, or their own
-- when they hold the job's top grade (as the UI allows).
local function roleEditor(source, grade)
    local actor = getActor(source)
    if not actor or not actor.can(perm("MANAGE_ROLES")) then return nil, "no_permission" end
    local info = getJobInfo(actor.job)
    grade = math.tointeger(tonumber(grade))
    if not grade or not (info and info.byLevel[grade]) then return nil, "invalid_grade" end
    if not (grade < actor.grade or (grade == actor.grade and info.top and grade >= info.top)) then
        return nil, "Low Job Grade"
    end
    return actor, grade, info
end

Sky.Cb.Register("sky_jobs_base:getJobPlayerPermissions", function(source, grade)
    local actor, level = roleEditor(source, grade)
    if not actor then return {} end
    local entry = getGradeEntry(actor.job, level)
    local map = {}
    for id in pairs(entry and entry.perms or {}) do map[tostring(id)] = true end
    return map
end)

local function restrictedList(key)
    return function(source, grade)
        local actor, level = roleEditor(source, grade)
        if not actor then return { success = false, error = level, data = {} } end
        local entry = getGradeEntry(actor.job, level)
        return { success = true, data = entry and entry.restrictions[key] or {} }
    end
end

Sky.Cb.Register("sky_jobs_base:getGradeRestrictedItems", restrictedList("items"))
Sky.Cb.Register("sky_jobs_base:getGradeRestrictedWeapons", restrictedList("weapons"))
Sky.Cb.Register("sky_jobs_base:getGradeRestrictedVehicles", restrictedList("vehicles"))
Sky.Cb.Register("sky_jobs_base:getGradeRestrictedTabletApps", restrictedList("tablet_apps"))
Sky.Cb.Register("sky_jobs_base:getGradeRestrictedDocumentClassifications", restrictedList("document_classifications"))

Sky.Cb.Register("sky_jobs_base:saveGrade", function(source, data)
    data = type(data) == "table" and data or {}
    local actor, level, info = roleEditor(source, data.grade)
    if not actor then return { success = false, error = level } end

    local current = info.byLevel[level]
    local roleName = cleanText(data.roleName, 100)
    if roleName and roleName ~= current.label then
        return { success = false, error = "Grade names come from the framework job config and cannot be changed here." }
    end
    if data.salary ~= nil and tonumber(data.salary) ~= current.salary then
        return { success = false, error = "Salaries come from the framework job config and cannot be changed here." }
    end

    local enum = permissionEnum()
    local optionKeyById = {}
    for name, keys in pairs(OPTION_PERMISSIONS) do
        if enum[name] then optionKeyById[enum[name]] = keys end
    end

    local old = getGradeEntry(actor.job, level) or normalizeEntry({}, {})
    local perms, restrictions = {}, {}
    for _, key in ipairs(RESTRICTION_KEYS) do restrictions[key] = old.restrictions[key] end

    for _, p in ipairs(type(data.permissions) == "table" and data.permissions or {}) do
        local id = type(p) == "table" and resolvePermission(p.id)
        if id then
            if p.enabled == true then perms[#perms + 1] = id end
            local keys = optionKeyById[id]
            if keys then
                restrictions[keys.options] = p.selectedOptions
                if keys.weapons then restrictions[keys.weapons] = p.selectedWeaponOptions end
            end
        end
    end
    local entry = normalizeEntry(perms, restrictions)

    -- A non-boss may only grant or revoke permissions they hold themselves.
    if not actor.boss then
        for _, value in pairs(enum) do
            if (entry.perms[value] == true) ~= (old.perms[value] == true) and not actor.can(value) then
                return { success = false, error = "cannot_grant_permission" }
            end
        end
    end

    if not saveGradeEntry(actor.job, level, entry) then return { success = false, error = "save_failed" } end
    logJobTransaction(actor.job, "permissions_updated", 0, GetPlayerFullName(actor.src), current.label)
    return { success = true, grade = level, data = buildManagementData(actor.src) }
end)

Sky.Cb.Register("sky_jobs_base:editGrade", function(source, action, grade)
    return { success = false, error = "Grades come from the framework job config and cannot be moved, created or deleted here." }
end)

local itemOptionsCache = nil

local function oxItems(name)
    if GetResourceState("ox_inventory") ~= "started" then return nil end
    local ok, items = pcall(function() return exports.ox_inventory:Items(name) end)
    return ok and items or nil
end

local function qbItems()
    if GetResourceState("qb-core") ~= "started" then return nil end
    local ok, core = pcall(function() return exports["qb-core"]:GetCoreObject() end)
    return ok and type(core) == "table" and core.Shared and core.Shared.Items or nil
end

Sky.Cb.Register("sky_jobs_base:getItemOptions", function(source)
    local actor = getActor(source)
    if not actor or not actor.can(perm("MANAGE_ROLES")) then return { success = false, error = "no_permission", data = {} } end
    if not itemOptionsCache then
        local list = {}
        for name, item in pairs(oxItems() or qbItems() or {}) do
            if type(name) == "string" and not name:upper():find("^WEAPON_") then
                list[#list + 1] = { value = name, label = type(item) == "table" and item.label or name }
            end
        end
        table.sort(list, function(a, b) return tostring(a.label) < tostring(b.label) end)
        itemOptionsCache = list
    end
    return { success = true, data = itemOptionsCache }
end)

local function itemDefined(name)
    if type(name) ~= "string" or name == "" or #name > 64 then return false end
    if oxItems(name) then return true end
    local items = qbItems()
    return items ~= nil and items[name:lower()] ~= nil
end

Sky.Cb.Register("sky_jobs_base:itemExists", function(source, item)
    local actor = getActor(source)
    return actor ~= nil and actor.can(perm("MANAGE_ROLES")) and itemDefined(item)
end)

Sky.Cb.Register("sky_jobs_base:weaponExists", function(source, weapon)
    local actor = getActor(source)
    if not actor or not actor.can(perm("MANAGE_ROLES")) then return { success = false, error = "no_permission" } end
    if type(weapon) ~= "string" then return { success = false } end
    local name = weapon:match("^%s*(.-)%s*$"):upper():gsub("%s+", "_")
    if not name:find("^WEAPON_") then name = "WEAPON_" .. name end
    if itemDefined(name) or itemDefined(name:lower()) then
        return { success = true, data = { name = name } }
    end
    return { success = false, error = "weapon_not_found" }
end)

-- -----------------------------------------------------
--  JOB CONFIGURATOR SERVER CALLBACKS
-- -----------------------------------------------------

Sky_Jobs.Configurator = Sky_Jobs.Configurator or {}

-- Every configurator callback reads or rewrites all workshops, so only players with the
-- /jobconfig permission may call them (any client can trigger any callback).
local function registerConfiguratorCallback(name, handler)
    Sky.Cb.Register(name, function(source, ...)
        if not Sky_Jobs.HasPermission(source, "jobconfig") then
            return { success = false, error = "no_permission" }
        end
        return handler(source, ...)
    end)
end

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:configs", function(source)
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

-- The settings, interactions and workshop tabs come from the mechanic resource
-- (sky_mechanicjob/source/server/job_configurator.lua), which takes every default from its
-- config.lua. Without it only the workshops and features can be edited.
local CONFIGURATOR_OWNER = "sky_mechanicjob"
local cachedSchema = nil

local function getConfiguratorSchema()
    if cachedSchema then
        return cachedSchema
    end
    if GetResourceState(CONFIGURATOR_OWNER) ~= "started" then
        return nil
    end

    local ok, schema = pcall(function()
        return exports[CONFIGURATOR_OWNER]:GetJobConfiguratorSchema()
    end)
    if ok and type(schema) == "table" and type(schema.settingDefinitions) == "table" then
        cachedSchema = schema
        return schema
    end
    return nil
end

-- A restart of the mechanic resource can change its config.lua defaults.
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == CONFIGURATOR_OWNER then cachedSchema = nil end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == CONFIGURATOR_OWNER then cachedSchema = nil end
end)

local function copyConfigValue(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = copyConfigValue(v)
    end
    return copy
end

-- The NUI keeps number fields as text ("50000.0") and sends them back like that; the
-- game compares and multiplies these values, so each one is stored with its type.
local function toSettingNumber(value, definition, integer)
    local number = tonumber(value)
    if number == nil or number ~= number or number == math.huge or number == -math.huge then
        return nil
    end
    local min = tonumber(definition.min)
    if min and number < min then
        number = min
    end
    if integer then
        number = math.floor(number)
    end
    return number
end

local function toSettingString(value)
    if value == nil then return nil end
    if type(value) == "string" then return value end
    if type(value) == "number" or type(value) == "boolean" then return tostring(value) end
    return nil
end

local function toStringList(value)
    local list, seen = {}, {}
    for _, entry in ipairs(type(value) == "table" and value or {}) do
        local text = toSettingString(entry)
        text = text and text:match("^%s*(.-)%s*$") or ""
        if text ~= "" and not seen[text] then
            seen[text] = true
            list[#list + 1] = text
        end
    end
    return list
end

local normalizeSettingValue

local function normalizeRows(rows, columns)
    local result = {}
    for _, row in ipairs(type(rows) == "table" and rows or {}) do
        if type(row) == "table" then
            for _, column in ipairs(type(columns) == "table" and columns or {}) do
                if type(column) == "table" and column.key ~= nil and column.readonly ~= true and row[column.key] ~= nil then
                    row[column.key] = normalizeSettingValue(column, row[column.key])
                end
            end
            result[#result + 1] = row
        end
    end
    return result
end

local LOCATION_ROW_COLUMNS = {
    { key = "label", type = "string" },
    { key = "x", type = "number" }, { key = "y", type = "number" }, { key = "z", type = "number" },
    { key = "heading", type = "number" },
    { key = "interactionDistance", type = "number", min = 0 },
    { key = "forceMarkerInteraction", type = "boolean" },
    { key = "mechanicOnly", type = "boolean" },
    { key = "allowedJobs", type = "stringList" }
}

function normalizeSettingValue(definition, value)
    local valueType = definition.type
    if valueType == "boolean" then
        return value == true or value == 1 or value == "true" or value == "1"
    elseif valueType == "number" or valueType == "integer" then
        return toSettingNumber(value, definition, valueType == "integer")
    elseif valueType == "stringList" then
        return toStringList(value)
    elseif valueType == "table" or valueType == "itemList" then
        return normalizeRows(value, definition.columns or definition.fields)
    elseif valueType == "locationList" then
        return normalizeRows(value, LOCATION_ROW_COLUMNS)
    elseif valueType == "select" then
        -- Option values keep their type (bone ids are numbers, install flows are strings).
        local options = type(definition.options) == "table" and definition.options or {}
        local first = type(options[1]) == "table" and options[1].value or nil
        if type(first) == "number" then
            return tonumber(value)
        end
        return toSettingString(value)
    elseif valueType == "string" or valueType == "color" then
        return toSettingString(value)
    end
    return value
end

-- Settings without a definition (the HUD position keys, values of older versions) are
-- stored as sent.
local function normalizeSettings(settings)
    if type(settings) ~= "table" then
        return {}
    end

    local schema = getConfiguratorSchema()
    local definitions = {}
    for _, definition in ipairs(schema and schema.settingDefinitions or {}) do
        if type(definition) == "table" and type(definition.key) == "string" then
            definitions[definition.key] = definition
        end
    end

    local result = {}
    for key, value in pairs(settings) do
        if key ~= "configKey" and key ~= "_resource" then
            local definition = definitions[key]
            if definition then
                result[key] = normalizeSettingValue(definition, value)
            else
                result[key] = value
            end
        end
    end
    return result
end

local function normalizeFeatures(features)
    local result = {}
    for key, value in pairs(type(features) == "table" and features or {}) do
        if type(key) == "string" and key ~= "configKey" and key ~= "_resource" then
            result[key] = value == true
        end
    end
    return result
end

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

-- Workshops used until the configurator is saved for the first time. creator.lua used
-- to write its own copy of these into the database; both now share this one.
local function getDefaultWorkshopData()
    return {
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
                    { uid = "lsc_tuning", type = "self_service_tuning", label = "Tuning Area", x = -338.5, y = -136.5, z = 39.0, heading = 70.0 },
                    { uid = "lsc_dyno", type = "dyno", label = "Dyno Stand", x = -330.0, y = -140.0, z = 39.0, heading = 70.0 }
                }
            },
            {
                id = "mechanic_bennys",
                name = "Benny's Original Motor Works",
                jobKey = "mechanic",
                job = "mechanic",
                storageCapacity = 1000,
                lockerCapacity = 300,
                nitroAccess = true,
                workshopVehicleClasses = {},
                points = {
                    { uid = "bennys_duty", type = "duty", label = "Duty Station", x = -205.5, y = -1310.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_storage", type = "storage", label = "Parts Storage", x = -208.0, y = -1315.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_locker", type = "locker", label = "Employee Lockers", x = -210.0, y = -1315.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_shop", type = "shop", label = "Wholesale Shop", x = -215.0, y = -1318.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_delivery", type = "parts_drop", label = "Delivery Drop", x = -220.0, y = -1320.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_wardrobe", type = "wardrobe", label = "Wardrobe", x = -204.0, y = -1320.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_boss", type = "management", label = "Management", x = -207.0, y = -1308.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_lift_1", type = "lift", label = "Car Lift 1", x = -212.0, y = -1320.0, z = 30.89, heading = 0.0, modelSet = "default" },
                    { uid = "bennys_tuning", type = "self_service_tuning", label = "Tuning Area", x = -212.0, y = -1320.0, z = 30.89, heading = 0.0 },
                    { uid = "bennys_dyno", type = "dyno", label = "Dyno Stand", x = -218.0, y = -1315.0, z = 31.3, heading = 0.0 }
                }
            }
        },
        features = {},
        settings = {},
        interactions = {}
    }
end

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
        data = getDefaultWorkshopData()
    end

    data.entries = type(data.entries) == "table" and data.entries or {}
    data.features = type(data.features) == "table" and data.features or {}
    data.settings = type(data.settings) == "table" and data.settings or {}
    data.interactions = type(data.interactions) == "table" and data.interactions or {}

    -- Unsaved values come from the mechanic's config.lua (its schema), so the game behaves
    -- like the Lua config until something is changed in the configurator.
    local schema = getConfiguratorSchema()
    local featureDefaults = schema and type(schema.defaultFeatures) == "table" and schema.defaultFeatures or defaultFeatures
    local settingDefaults = schema and type(schema.defaultSettings) == "table" and schema.defaultSettings or {}

    for k, v in pairs(featureDefaults) do
        if data.features[k] == nil then
            data.features[k] = v
        end
    end

    for k, v in pairs(settingDefaults) do
        if data.settings[k] == nil then
            data.settings[k] = copyConfigValue(v)
        end
    end

    for _, entry in ipairs(data.entries) do
        -- Older saves copied every global setting and feature into each workshop; nothing
        -- reads those copies and they made every sync carry the settings once per workshop.
        entry.settings = nil
        entry.features = nil

        if type(entry.interactions) ~= "table" then
            entry.interactions = {}
        end
        if type(entry.points) ~= "table" then
            entry.points = {}
        end
    end

    return data
end

-- Job names used by the workshop entries (jobKey and name), for sky_mechanicjob's server
-- side, which otherwise only knows the jobs in its own config.lua.
local workshopJobNames = {}

local function publishWorkshopJobNames(entries)
    local names, seen = {}, {}
    for _, entry in ipairs(type(entries) == "table" and entries or {}) do
        if type(entry) == "table" then
            for _, value in ipairs({ entry.jobKey, entry.name }) do
                if type(value) == "string" and value ~= "" and not seen[value] then
                    seen[value] = true
                    names[#names + 1] = value
                end
            end
        end
    end

    workshopJobNames = names
    TriggerEvent("sky_jobs_base:jobConfigurator:jobNamesUpdated", "sky_mechanicjob", names)
end

registerExport("GetJobConfiguratorJobNames", function()
    return workshopJobNames
end)

local function saveWorkshopCreatorData(data)
    if type(data) ~= "table" then return false end
    local saved, err = pcall(function()
        MySQL.query.await([[
            INSERT INTO sky_jobs_creator_data (creator_key, data)
            VALUES ('workshopcreator', @data)
            ON DUPLICATE KEY UPDATE data = @data
        ]], {
            ["@data"] = json.encode(data)
        })
    end)
    -- Reporting success here made the admin see "saved" while the change was lost on
    -- the next restart.
    if not saved then
        print(("[sky_jobs_base][job_configurator] saving the workshops failed: %s"):format(tostring(err)))
        return false
    end
    -- sky_jobs_base:creator:getData (creator.lua) serves players who join later and the
    -- mechanic resource from a cache; without this it kept returning the data from
    -- before the save until the resource restarted.
    if Sky_Jobs.Creator and Sky_Jobs.Creator.SetCachedData then
        Sky_Jobs.Creator.SetCachedData("workshopcreator", data)
    end
    TriggerClientEvent("sky_jobs_base:creatorUpdated", -1, "workshopcreator", data)

    local features = type(data.features) == "table" and data.features or defaultFeatures
    local settings = type(data.settings) == "table" and data.settings or {}
    local entries = type(data.entries) == "table" and data.entries or {}
    local interactions = type(data.interactions) == "table" and data.interactions or {}

    TriggerClientEvent("sky_jobs_base:jobConfigurator:updated", -1, "sky_mechanicjob", entries, features, settings, interactions)
    publishWorkshopJobNames(entries)
    return true
end

-- Shared with creator.lua (sky_jobs_base:creator:getData / requestSync / saveData).
Sky_Jobs.Configurator.LoadWorkshopData = loadWorkshopCreatorData
Sky_Jobs.Configurator.SaveWorkshopData = saveWorkshopCreatorData

local SAVE_FAILED = { success = false, error = "save_failed" }

-- Publish once at start so sky_mechanicjob knows the workshop jobs before the first save.
-- Retried because the database or the creator table (creator.lua) may not be ready yet.
CreateThread(function()
    for _ = 1, 20 do
        local ok, data = pcall(loadWorkshopCreatorData)
        if ok and type(data) == "table" then
            publishWorkshopJobNames(data.entries)
            return
        end
        Wait(3000)
    end
    print("[sky_jobs_base][job_configurator] could not load the workshop jobs at start; they are published again on the next save.")
end)

-- The complete configurator context: the NUI resets every section that is missing.
registerConfiguratorCallback("sky_jobs_base:jobConfigurator:list", function(source, data)
    local configKey = tostring(data and data.configKey or "sky_mechanicjob")
    local creatorData = loadWorkshopCreatorData()
    local schema = getConfiguratorSchema() or {}

    if not schema.settingDefinitions then
        print("[sky_jobs_base][job_configurator] sky_mechanicjob is not running; only workshops and features can be edited.")
    end

    return {
        success = true,
        data = {
            configKey = configKey,
            title = schema.title or "Mechanic Jobs",
            titleKey = schema.titleKey or "workshopConfig.configs.sky_mechanicjob.title",
            subtitle = schema.subtitle or "Configure mechanic jobs, shops, vehicles, and workshop locations.",
            subtitleKey = schema.subtitleKey or "workshopConfig.configs.sky_mechanicjob.subtitle",
            entityLabel = schema.entityLabel or "Workshop",
            entityPluralLabel = schema.entityPluralLabel or "Workshops",
            locationDefinitions = defaultLocationDefinitions,
            featureDefinitions = schema.featureDefinitions or defaultFeatureDefinitions,
            settingDefinitions = schema.settingDefinitions or {},
            defaultSettings = schema.defaultSettings or {},
            interactionDefinitions = schema.interactionDefinitions or {},
            extensions = schema.extensions or {},
            creatorSections = {},
            features = creatorData.features,
            settings = creatorData.settings,
            interactions = creatorData.interactions,
            configs = creatorData.entries
        }
    }
end)

-- Point uids must be unique across all workshops: a uid that matched another point
-- (the old 4-digit random suffix) overwrote that point.
local function createPointUid(entries, locType)
    local taken = {}
    for _, entry in ipairs(entries) do
        for _, pt in ipairs(type(entry) == "table" and type(entry.points) == "table" and entry.points or {}) do
            if type(pt) == "table" and pt.uid ~= nil then
                taken[tostring(pt.uid)] = true
            end
        end
    end

    local base = tostring(locType):lower():gsub("[^%w_]+", "_")
    local uid
    repeat
        uid = ("%s_%d%03d"):format(base, os.time(), math.random(0, 999))
    until not taken[uid]
    return uid
end

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:setLocation", function(source, data)
    data = type(data) == "table" and data or {}
    local rawEntryId = data.entryId or data.id or data.creatorEntryId or data.configId or (type(data.entry) == "table" and data.entry.id) or nil
    local entryId = tostring(rawEntryId or "mechanic_lscustoms")
    local locType = tostring(data.locationType or data.type or "location")
    local coords = type(data.coords) == "table" and data.coords or {}
    if not (tonumber(coords.x) and tonumber(coords.y) and tonumber(coords.z)) then
        return { success = false, error = "invalid_coords" }
    end

    local creatorData = loadWorkshopCreatorData()
    local entryName = tostring(data.entryName or data.name or ""):lower()
    local targetEntry = nil
    for _, entry in ipairs(creatorData.entries) do
        if (rawEntryId ~= nil and tostring(entry.id) == entryId) or (entryName ~= "" and tostring(entry.name):lower() == entryName) then
            targetEntry = entry
            break
        end
    end

    -- A job that is not saved yet has no entry; falling back to the first entry put its
    -- locations on another workshop.
    if not targetEntry and (rawEntryId ~= nil or entryName ~= "") then
        return { success = false, error = "entry_not_found" }
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
            interactions = {}
        }
        table.insert(creatorData.entries, targetEntry)
    end

    targetEntry.points = targetEntry.points or {}
    entryId = tostring(targetEntry.id)
    local pointUid = data.uid ~= nil and data.uid ~= "" and tostring(data.uid) or createPointUid(creatorData.entries, locType)

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

    -- The NUI sends the location's "requires on duty" toggle with the placement.
    if type(data.requiresOnDuty) == "boolean" then
        targetEntry.locationSettings = type(targetEntry.locationSettings) == "table" and targetEntry.locationSettings or {}
        targetEntry.locationSettings[tostring(pointUid)] = { requiresOnDuty = data.requiresOnDuty }
    end

    if not saveWorkshopCreatorData(creatorData) then
        return SAVE_FAILED
    end

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

local function findCreatorEntryIndex(entries, id)
    for i, entry in ipairs(entries) do
        if tostring(entry.id) == tostring(id) then
            return i
        end
    end
    return nil
end

local function isCreatorEntryNameTaken(entries, name, exceptId)
    local wanted = name:lower()
    for _, entry in ipairs(entries) do
        if type(entry.name) == "string" and entry.name:lower() == wanted
            and (exceptId == nil or tostring(entry.id) ~= tostring(exceptId)) then
            return true
        end
    end
    return false
end

-- Qbox job names are the case-sensitive keys of qbx_core's shared/jobs.lua, and a workshop
-- only works for players whose job name matches exactly. Returns the name with Qbox's
-- casing and whether that job exists (nil when qbx_core is not running).
local function resolveQboxJobName(name)
    if GetResourceState("qbx_core") ~= "started" then
        return name, nil
    end

    local ok, jobs = pcall(function()
        return exports.qbx_core:GetJobs()
    end)
    if not ok or type(jobs) ~= "table" then
        return name, nil
    end

    if jobs[name] then
        return name, true
    end

    local wanted = name:lower()
    for jobName in pairs(jobs) do
        if type(jobName) == "string" and jobName:lower() == wanted then
            return jobName, true
        end
    end
    return name, false
end

local function warnMissingQboxJob(source, name)
    local message = ("Saved, but Qbox has no job named '%s'. Add it to qbx_core/shared/jobs.lua or rename this job; until then no player can use it."):format(name)
    print(("[sky_jobs_base][job_configurator] %s"):format(message))

    local src = tonumber(source)
    if src and src > 0 then
        TriggerClientEvent("sky_base:notification", src, "Job Configurator", message, "warn", 10000)
    end
end

local function createCreatorEntryId(entries, name)
    local base = name:lower():gsub("[^%w_]+", "_"):gsub("^_+", ""):gsub("_+$", "")
    if base == "" then
        base = "entry"
    end

    local id, suffix = base, 2
    while findCreatorEntryIndex(entries, id) do
        id = base .. "_" .. suffix
        suffix = suffix + 1
    end
    return id
end

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:save", function(source, data)
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
    elseif type(data.job) == "table" then
        local job = data.job
        local name = type(job.name) == "string" and job.name:match("^%s*(.-)%s*$") or ""
        if name == "" then
            return { success = false, error = "invalid_name" }
        end

        local index = job.id ~= nil and findCreatorEntryIndex(creatorData.entries, job.id) or nil
        local existing = index and creatorData.entries[index] or nil

        -- The editor's name field is the framework job name. "New" and "Duplicate" send a
        -- copy of another entry without an id that still carries that entry's jobKey/job,
        -- so new entries (and entries whose jobKey already follows their name) take their
        -- jobKey/job from the name. Older entries with a separate jobKey, like
        -- "Los Santos Customs" -> "mechanic", keep it.
        local nameIsJob = existing == nil or existing.jobKey == nil or existing.jobKey == existing.name
        local qboxJobFound = nil
        if nameIsJob then
            name, qboxJobFound = resolveQboxJobName(name)
        end
        job.name = name

        if isCreatorEntryNameTaken(creatorData.entries, name, existing and existing.id) then
            return { success = false, error = "job_name_exists" }
        end

        if nameIsJob then
            job.jobKey = name
            job.job = name
        elseif job.jobKey == nil then
            job.jobKey = existing.jobKey
            job.job = job.job or existing.job
        end

        if existing then
            if job.points == nil then
                job.points = existing.points
            end
            creatorData.entries[index] = job
        else
            if job.id == nil then
                -- A generated id, so a new entry can never replace an existing one.
                job.id = createCreatorEntryId(creatorData.entries, name)
            end
            table.insert(creatorData.entries, job)
        end

        if qboxJobFound == false then
            warnMissingQboxJob(source, name)
        end
    elseif type(data.data) == "table" then
        if type(data.data.entries) == "table" then
            creatorData.entries = data.data.entries
        elseif type(data.data.configs) == "table" then
            creatorData.entries = data.data.configs
        end
    end

    if type(data.features) == "table" then
        creatorData.features = creatorData.features or {}
        for k, v in pairs(normalizeFeatures(data.features)) do creatorData.features[k] = v end
    end
    -- The workshop editor sends the global settings of its Parts Delivery and Tuning
    -- Prices tabs with the workshop.
    if type(data.settings) == "table" then
        creatorData.settings = creatorData.settings or {}
        for k, v in pairs(normalizeSettings(data.settings)) do creatorData.settings[k] = v end
    end
    if type(data.interactions) == "table" then
        creatorData.interactions = data.interactions
    end

    if not saveWorkshopCreatorData(creatorData) then
        return SAVE_FAILED
    end
    return { success = true, data = creatorData.entries }
end)

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:saveCreatorEntry", function(source, data)
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

    if not saveWorkshopCreatorData(creatorData) then
        return SAVE_FAILED
    end
    return { success = true }
end)

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:createCreatorEntry", function(source, data)
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
        interactions = {}
    }

    table.insert(creatorData.entries, newEntry)
    if not saveWorkshopCreatorData(creatorData) then
        return SAVE_FAILED
    end

    return { success = true, entryId = newId, entry = newEntry }
end)

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:deleteCreatorEntry", function(source, data)
    data = type(data) == "table" and data or {}
    local entryId = tostring(data.entryId or data.id or "")
    if entryId == "" then return { success = false, error = "invalid_entry_id" } end

    local creatorData = loadWorkshopCreatorData()
    for i = #creatorData.entries, 1, -1 do
        if creatorData.entries[i].id == entryId then
            table.remove(creatorData.entries, i)
        end
    end

    if not saveWorkshopCreatorData(creatorData) then
        return SAVE_FAILED
    end
    return { success = true }
end)

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:deleteLocations", function(source, data)
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

    if not saveWorkshopCreatorData(creatorData) then
        return SAVE_FAILED
    end
    return { success = true }
end)

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:addCreatorZonePoint", function(source, data)
    return { success = true }
end)

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:setCreatorZonePoint", function(source, data)
    return { success = true }
end)

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:removeCreatorZonePoint", function(source, data)
    return { success = true }
end)

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:clearCreatorZonePoints", function(source, data)
    return { success = true }
end)

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:saveFeatures", function(source, data)
    data = type(data) == "table" and data or {}
    local featuresPayload = data.features or data
    if type(featuresPayload) ~= "table" then
        return { success = false, error = "invalid_payload" }
    end

    local creatorData = loadWorkshopCreatorData()
    creatorData.features = creatorData.features or {}
    for k, v in pairs(normalizeFeatures(featuresPayload)) do
        creatorData.features[k] = v
    end

    if not saveWorkshopCreatorData(creatorData) then
        return SAVE_FAILED
    end
    return { success = true, data = creatorData.features }
end)

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:saveSettings", function(source, data)
    data = type(data) == "table" and data or {}
    local settingsPayload = data.settings or data
    if type(settingsPayload) ~= "table" then
        return { success = false, error = "invalid_payload" }
    end

    local creatorData = loadWorkshopCreatorData()
    creatorData.settings = creatorData.settings or {}
    for k, v in pairs(normalizeSettings(settingsPayload)) do
        creatorData.settings[k] = v
    end

    if not saveWorkshopCreatorData(creatorData) then
        return SAVE_FAILED
    end
    return { success = true, data = creatorData.settings }
end)

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:saveInteractions", function(source, data)
    data = type(data) == "table" and data or {}
    local interactionsPayload = data.interactions or data
    if type(interactionsPayload) ~= "table" then
        return { success = false, error = "invalid_payload" }
    end

    local creatorData = loadWorkshopCreatorData()
    creatorData.interactions = interactionsPayload

    if not saveWorkshopCreatorData(creatorData) then
        return SAVE_FAILED
    end
    return { success = true, data = creatorData.interactions }
end)

registerConfiguratorCallback("sky_jobs_base:jobConfigurator:delete", function(source, data)
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

    if not saveWorkshopCreatorData(creatorData) then
        return SAVE_FAILED
    end
    return { success = true }
end)

-- Every client's sky_mechanicjob asks for the workshop config when it starts, so this is
-- open to all players; it only ever sends the (read-only) workshop data.
local lastConfiguratorSyncAt = {}

RegisterServerEvent("sky_jobs_base:jobConfigurator:requestSync", function()
    local src = source
    local now = GetGameTimer()
    if lastConfiguratorSyncAt[src] and now - lastConfiguratorSyncAt[src] < 2000 then
        return
    end
    lastConfiguratorSyncAt[src] = now

    local ok, creatorData = pcall(loadWorkshopCreatorData)
    if not ok or type(creatorData) ~= "table" then
        print(("[sky_jobs_base][job_configurator] sync for %s failed: %s"):format(tostring(src), tostring(creatorData)))
        return
    end
    TriggerClientEvent("sky_jobs_base:jobConfigurator:updated", src, "sky_mechanicjob", creatorData.entries, creatorData.features, creatorData.settings, creatorData.interactions)
end)

AddEventHandler("playerDropped", function()
    lastConfiguratorSyncAt[source] = nil
end)

-- -----------------------------------------------------
--  MAP OFFICERS & CAMERA
-- -----------------------------------------------------

local function vehicleTypeOf(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if not vehicle or vehicle == 0 then return "foot", false end
    local kind = type(GetVehicleType) == "function" and GetVehicleType(vehicle) or "automobile"
    local lightsOn = type(IsVehicleSirenOn) == "function" and IsVehicleSirenOn(vehicle) == true
    if kind == "heli" or kind == "plane" then return "heli", lightsOn end
    if kind == "boat" or kind == "submarine" then return "boat", lightsOn end
    return "car", lightsOn
end

-- On-duty colleagues of an on-duty employee (Config.ColleagueMapBlips.groups widens the
-- visible jobs per viewer job).
Sky.Cb.Register("sky_jobs_base:map:getOfficers", function(source)
    local src = tonumber(source)
    local myJob = src and Sky_Jobs.RequireEmployee(src, true)
    if not myJob then return { success = false, error = "no_access" } end

    local cfg = Config and Config.ColleagueMapBlips or {}
    local visible = { [myJob] = true }
    local groups = type(cfg.groups) == "table" and cfg.groups[myJob]
    for _, job in ipairs(type(groups) == "table" and groups or {}) do visible[job] = true end
    local requiredItem = cfg.requireItem == true and type(cfg.item) == "string" and cfg.item or nil

    local officers = {}
    for _, srcStr in ipairs(GetPlayers()) do
        local pSrc = tonumber(srcStr)
        local job, grade = pSrc and Sky_Jobs.RequireEmployee(pSrc, true)
        if job and visible[job]
            and not (Sky_Jobs.IsGpsJammed and Sky_Jobs.IsGpsJammed(pSrc))
            and (not requiredItem or (Sky_Jobs.GetInventoryItemCount and Sky_Jobs.GetInventoryItemCount(pSrc, requiredItem) > 0)) then
            local ped = GetPlayerPed(pSrc)
            if ped and ped ~= 0 then
                local coords = GetEntityCoords(ped)
                local vehicleType, lightsOn = vehicleTypeOf(ped)
                local health = GetEntityHealth(ped) or 0
                officers[#officers + 1] = {
                    id = pSrc,
                    name = GetPlayerFullName(pSrc),
                    callsign = tostring(pSrc),
                    rank = gradeLabel(getJobInfo(job), grade),
                    job = job,
                    status = "available",
                    durability = math.max(0, math.min(100, health - 100)),
                    coords = { x = coords.x, y = coords.y, z = coords.z },
                    heading = GetEntityHeading(ped),
                    vehicleType = vehicleType,
                    lightsOn = lightsOn
                }
            end
        end
    end

    return { success = true, data = { officers = officers, speedcams = {}, vehicles = {}, trackers = {} } }
end)

-- The server gets a presigned URL, the client's NUI captures and uploads the frame
-- (camera:captureAndUpload) and answers with camera:uploadResult; the photo then joins the gallery.
-- The client waits 15 s for this callback, so the capture gets what is left of 14 s.
local CAPTURE_DEADLINE_MS = 14000
local pendingCaptures = {}
local captureSerial = 0

Sky.Cb.Register("sky_jobs_base:camera:takePhoto", function(source, data)
    local src = tonumber(source)
    local started = GetGameTimer()
    data = type(data) == "table" and data or {}
    local folder = Sky_Jobs.Gallery.Folder(data.folder)
    local job, err = Sky_Jobs.Uploads.Authorize(src, folder == "cctv" or folder == "speedcam")
    if not job then return { success = false, error = err } end
    for _, pending in pairs(pendingCaptures) do
        if pending.src == src then return { success = false, error = "busy" } end
    end
    if Sky_Jobs.Gallery.IsFull(job) then return { success = false, error = "gallery_full" } end

    local presignedUrl, presignErr = Sky_Jobs.Uploads.PresignFor(src, "image")
    if not presignedUrl then return { success = false, error = presignErr } end

    captureSerial = captureSerial + 1
    local requestId = ("%d-%d-%d"):format(src, captureSerial, math.random(100000, 999999))
    local p = promise.new()
    pendingCaptures[requestId] = { src = src, promise = p }
    TriggerClientEvent("sky_jobs_base:camera:captureAndUpload", src, { requestId = requestId, presignedUrl = presignedUrl })
    SetTimeout(math.max(1000, CAPTURE_DEADLINE_MS - (GetGameTimer() - started)), function()
        if pendingCaptures[requestId] then
            pendingCaptures[requestId] = nil
            p:resolve({ success = false, error = "upload_timeout" })
        end
    end)

    local result = Citizen.Await(p)
    if not result.success then return { success = false, error = result.error or "upload_failed" } end

    local photo, addErr = Sky_Jobs.Gallery.Add(src, job, {
        url = result.url,
        image_id = result.image_id,
        folder = folder,
        metadata = data.metadata
    })
    if not photo then return { success = false, error = addErr } end
    return { success = true, data = { id = photo.id, url = photo.url, image_id = photo.image_id } }
end)

RegisterNetEvent("sky_jobs_base:camera:uploadResult", function(data)
    local src = source
    data = type(data) == "table" and data or {}
    local requestId = type(data.requestId) == "string" and data.requestId or nil
    local pending = requestId and pendingCaptures[requestId]
    if not pending or pending.src ~= src then return end
    pendingCaptures[requestId] = nil

    local result = type(data.data) == "table" and data.data or {}
    if data.success == true and type(result.url) == "string" then
        pending.promise:resolve({ success = true, url = result.url, image_id = result.image_id or result.id })
    else
        pending.promise:resolve({ success = false, error = cleanText(data.error, 64) or "upload_failed" })
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
    for requestId, pending in pairs(pendingCaptures) do
        if pending.src == src then
            pendingCaptures[requestId] = nil
            pending.promise:resolve({ success = false, error = "upload_failed" })
        end
    end
end)

-- -----------------------------------------------------
--  ADMINISTRATIVE COMMANDS
-- -----------------------------------------------------

local function commandReply(source, message, kind)
    local src = tonumber(source)
    if src and src > 0 then
        TriggerClientEvent("sky_base:notification", src, "Jobs", message, kind or "info", 5000)
    else
        print(("[sky_jobs_base] %s"):format(message))
    end
end

-- These commands were registered unrestricted (RegisterCommand(..., false)) without a
-- permission check, so every player could make themselves boss or take any job.
local function registerAdminCommand(name, permission, handler)
    RegisterCommand(name, function(source, args, raw)
        if not Sky_Jobs.HasPermission(source, permission) then
            commandReply(source, "You do not have permission to use this command.", "error")
            return
        end
        handler(source, type(args) == "table" and args or {}, raw)
    end, false)
end

local function resolveCommandTarget(source, arg)
    local target = tonumber(arg) or tonumber(source)
    if not target or target <= 0 or not GetPlayerName(target) then
        return nil
    end
    return target
end

local function doesJobExist(jobName)
    if Sky and Sky.FW and Sky.FW.DoesJobExist then
        return Sky.FW.DoesJobExist(jobName) == true
    end
    return true
end

registerAdminCommand("setboss", "setboss", function(source, args)
    local targetSrc = resolveCommandTarget(source, args[1])
    if not targetSrc then
        commandReply(source, "Usage: /setboss [playerId] [job] [grade] - player not found.", "error")
        return
    end

    local jobName = args[2] or Sky_Jobs.PlayerCache.GetJob(targetSrc)
    local grade = tonumber(args[3]) or 4
    if isUnemployedJob(jobName) or not doesJobExist(jobName) then
        commandReply(source, ("Job '%s' does not exist."):format(tostring(jobName)), "error")
        return
    end

    SetPlayerJob(targetSrc, jobName, grade)
    commandReply(source, ("Set %s to %s (grade %s)."):format(GetPlayerFullName(targetSrc), jobName, grade), "success")
end)

registerAdminCommand(Config.MultiJob and Config.MultiJob.giveJobCommand or "givejob", "givejob", function(source, args)
    local targetSrc = resolveCommandTarget(source, args[1])
    local jobName = args[2]
    local grade = tonumber(args[3]) or 0
    if not targetSrc or type(jobName) ~= "string" or jobName == "" then
        commandReply(source, "Usage: /givejob <playerId> <job> [grade]", "error")
        return
    end
    if not doesJobExist(jobName) then
        commandReply(source, ("Job '%s' does not exist."):format(jobName), "error")
        return
    end

    SetPlayerJob(targetSrc, jobName, grade)
    commandReply(source, ("Gave %s the job %s (grade %s)."):format(GetPlayerFullName(targetSrc), jobName, grade), "success")
end)

registerAdminCommand(Config.MultiJob and Config.MultiJob.removeJobCommand or "removejob", "removejob", function(source, args)
    local targetSrc = resolveCommandTarget(source, args[1])
    if not targetSrc then
        commandReply(source, "Usage: /removejob <playerId> [job]", "error")
        return
    end

    local defaultJob = Config.MultiJob and Config.MultiJob.defaultJob or "unemployed"
    local defaultGrade = Config.MultiJob and tonumber(Config.MultiJob.defaultGrade) or 0
    SetPlayerJob(targetSrc, defaultJob, defaultGrade)
    commandReply(source, ("Removed the job of %s."):format(GetPlayerFullName(targetSrc)), "success")
end)

registerAdminCommand(Config.MultiJob and Config.MultiJob.adminCommand or "multijobadmin", "multijobadmin", function(source, args)
    commandReply(source, "multijobadmin is not available; use /givejob and /removejob.", "info")
end)

registerAdminCommand("dutytest", "dutytest", function(source, args)
    local targetSrc = resolveCommandTarget(source, args[1])
    if not targetSrc then
        commandReply(source, "Usage: /dutytest [playerId] [on|off]", "error")
        return
    end

    local state = args[2]
    if state == "on" or state == "1" or state == "true" then
        Sky_Jobs.PlayerCache.SetDuty(targetSrc, true)
    elseif state == "off" or state == "0" or state == "false" then
        Sky_Jobs.PlayerCache.SetDuty(targetSrc, false)
    else
        local current = Sky_Jobs.PlayerCache.IsOnDuty(targetSrc)
        Sky_Jobs.PlayerCache.SetDuty(targetSrc, not current)
    end

    local onDuty = Sky_Jobs.PlayerCache.IsOnDuty(targetSrc)
    local jobName = Sky_Jobs.PlayerCache.GetJob(targetSrc)
    TriggerClientEvent("sky_jobs_base:creator:updatePlayerDuty", targetSrc, onDuty, (not isUnemployedJob(jobName)) and jobName or nil)
    commandReply(source, ("%s is now %s duty."):format(GetPlayerFullName(targetSrc), onDuty and "ON" or "OFF"), "success")
end)
