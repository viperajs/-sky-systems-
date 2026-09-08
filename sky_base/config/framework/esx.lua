if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/config/framework/esx.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

if Sky.Config.framework == "esx" then
    Sky.FW = {}
    local function _sky_dbg(name, ...)
        if Sky.Config.debug then
            local count = select("#", ...)
            local parts = {}
            for i = 1, count do
                parts[i] = tostring(select(i, ...))
            end
            print(("[sky_base][debug] %s(%s)"):format(name, table.concat(parts, ", ")))
        end
    end

    local function resolveESX()
        if ESX then
            return ESX
        end

        local ok, sharedObject = pcall(function()
            return exports["es_extended"]:getSharedObject()
        end)
        if ok and sharedObject then
            return sharedObject
        end

        TriggerEvent("esx:getSharedObject", function(obj)
            _sky_dbg("esx:getSharedObject callback", obj)
            ESX = obj
        end)

        return ESX
    end

    local function waitForESX(timeoutMs)
        local waited = 0
        local timeout = timeoutMs or 5000

        while not ESX and waited <= timeout do
            ESX = resolveESX()
            if ESX then
                break
            end

            Wait(100)
            waited = waited + 100
        end

        return ESX
    end

    -- Get ESX for new & old versions without hard-failing on legacy ESX builds
    ESX = waitForESX(10000)
    if not ESX then
        print("^1[sky_base] ESX shared object could not be loaded. Make sure es_extended is started before sky_base.^0")
        return
    end

    -- Some ESX forks print every job grade from ESX.GetJobs() unconditionally.
    -- Keep those diagnostics tied to sky_base's debug setting without hiding
    -- unrelated warnings or errors emitted by the framework.
    local function getESXJobs()
        if Sky.Config.debug then
            return ESX.GetJobs()
        end

        local originalPrint = print
        print = function(...)
            local parts = {}
            for index = 1, select("#", ...) do
                parts[index] = tostring(select(index, ...))
            end

            local message = table.concat(parts, "\t")
            local isJobGradeDebug = message:find("Job:", 1, true)
                and message:find("Grade:", 1, true)
                and message:find("Name:", 1, true)

            if not isJobGradeDebug then
                originalPrint(...)
            end
        end

        local result
        local ok, err = xpcall(function()
            result = ESX.GetJobs()
        end, debug.traceback)
        print = originalPrint

        if not ok then
            error(err, 0)
        end

        return result
    end

    if IsDuplicityVersion() then goto server end
    -- Client Side from here

    --Update Hunger and Thirst
    AddEventHandler("esx_status:onTick", function(data)
        local newHunger, newThirst
        for i, v in pairs(data) do
            if v.name == "hunger" then
                newHunger = v.percent
            elseif v.name == "thirst" then
                newThirst = v.percent
            end
        end
        TriggerEvent("sky_base:updateHungerAndThirst", newHunger, newThirst)
    end)

    -- Is Player Loaded
    RegisterNetEvent('esx:playerLoaded', function()
        _sky_dbg("esx:playerLoaded (client)")
        TriggerEvent("sky_base:playerLoaded")
    end)

    --Update Money
    RegisterNetEvent('esx:setAccountMoney', function(account)
        _sky_dbg("esx:setAccountMoney", account)
        TriggerEvent("sky_base:updateAccountMoney", account.name, account.money)
    end)

    --Entered Car
    AddEventHandler('esx:enteredVehicle', function(vehicle, plate, seat, displayName, netId)
        _sky_dbg("esx:enteredVehicle", vehicle, plate, seat, displayName, netId)
        TriggerEvent("sky_base:enteredVehicle", vehicle, plate, seat)
    end)

    --Exited Car
    AddEventHandler('esx:exitedVehicle', function(vehicle, plate, seat, displayName, netId)
        _sky_dbg("esx:exitedVehicle", vehicle, plate, seat, displayName, netId)
        TriggerEvent("sky_base:exitedVehicle", vehicle, plate, seat)
    end)

    --Added Item
    RegisterNetEvent('esx:addInventoryItem', function(item, count)
        _sky_dbg("esx:addInventoryItem", item, count)
        TriggerEvent("sky_base:inventoryUpdated")
    end)

    --Removed Inventory
    RegisterNetEvent('esx:removeInventoryItem', function(item, count)
        _sky_dbg("esx:removeInventoryItem", item, count)
        TriggerEvent("sky_base:inventoryUpdated")
    end)

    --Update Job
    RegisterNetEvent('esx:setJob', function(job, lastJob)
        _sky_dbg("esx:setJob", job, lastJob)
        TriggerEvent("sky_base:updateJob", job)
        TriggerServerEvent("sky_base:updateJob", job)
    end)

    ::server::
    if not IsDuplicityVersion() then return end
    -- Server Side from here

    local jobUsersCache = {}
    local jobUsersCacheDuration = 60000

    -- ESX fires this server-locally from its login flow; AddEventHandler keeps it off the
    -- net surface so clients cannot inject playerLoaded for arbitrary sources
    AddEventHandler("esx:playerLoaded", function(playerId, xPlayer, isNew)
        _sky_dbg("esx:playerLoaded (server)", playerId, xPlayer, isNew)
        TriggerEvent("sky_base:playerLoaded", playerId)
    end)

    local function updateSkyJobsPlayerCache(src)
        if not src or not Sky_Jobs or not Sky_Jobs.PlayerCache or not Sky_Jobs.PlayerCache.UpdateJob then
            return
        end
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            Sky_Jobs.PlayerCache.UpdateJob(src, xPlayer.getJob())
        end
    end

    RegisterNetEvent("jobs_creator:toggleDuty", function(playerId, jobName, isOnDuty)
        _sky_dbg("jobs_creator:toggleDuty", playerId, jobName, isOnDuty)
        if not playerId then return end
        updateSkyJobsPlayerCache(playerId)
    end)

    RegisterNetEvent("jobs_creator:boss:playerHired", function(playerId, jobName)
        _sky_dbg("jobs_creator:boss:playerHired", playerId, jobName)
        if not playerId then return end
        updateSkyJobsPlayerCache(playerId)
    end)

    RegisterNetEvent("jobs_creator:boss:employeeFired", function(employeeIdentifier, jobName)
        _sky_dbg("jobs_creator:boss:employeeFired", employeeIdentifier, jobName)
        if not employeeIdentifier then return end
        local xPlayer = ESX.GetPlayerFromIdentifier(employeeIdentifier)
        if xPlayer then
            updateSkyJobsPlayerCache(xPlayer.source)
        end
    end)

    function Sky.FW.IsPlayerOnline(sourceOrIdentifier)
        _sky_dbg("Sky.FW.IsPlayerOnline", sourceOrIdentifier)

        if type(sourceOrIdentifier) == "number" then
            local xPlayer = ESX.GetPlayerFromId(sourceOrIdentifier)
            if xPlayer == nil then
                return false
            else
                return true
            end
        else
            local xPlayer = ESX.GetPlayerFromIdentifier(sourceOrIdentifier)
            if xPlayer == nil then
                return false
            else
                return true
            end
        end
    end

    function Sky.FW.GetIdentifier(source)
        _sky_dbg("Sky.FW.GetIdentifier", source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return nil end
        return xPlayer.identifier
    end

    function Sky.FW.GetName(sourceOrIdentifier)
        _sky_dbg("Sky.FW.GetName", sourceOrIdentifier)
        
        if type(sourceOrIdentifier) == "number" then
            local xPlayer = ESX.GetPlayerFromId(sourceOrIdentifier)
            if xPlayer then
                return xPlayer.getName()
            end
        else
           local user = Sky.DB.GetSingleRow("users", "identifier", sourceOrIdentifier)
            if user ~= nil then
                if user.firstname ~= nil and user.lastname ~= nil then
                    return Sky.String.SanitizeForSQL(user.firstname .. " " .. user.lastname)
                else
                    return "Unknown"
                end
            end
        end

        return nil
    end

    function Sky.FW.GetFirstname(sourceOrIdentifier)
        _sky_dbg("Sky.FW.GetFirstname", sourceOrIdentifier)

        if type(sourceOrIdentifier) == "number" then
            local xPlayer = ESX.GetPlayerFromId(sourceOrIdentifier)
            if xPlayer then
                return xPlayer.get("firstName")
            end
        else
            local user = Sky.DB.GetSingleRow("users", "identifier", sourceOrIdentifier)
            if user then
                return Sky.String.SanitizeForSQL(user.firstname)
            end
        end

        return nil
    end

    function Sky.FW.GetLastname(sourceOrIdentifier)
        _sky_dbg("Sky.FW.GetLastname", sourceOrIdentifier)
        if type(sourceOrIdentifier) == "number" then
            local xPlayer = ESX.GetPlayerFromId(sourceOrIdentifier)
            if xPlayer then
                return xPlayer.get("lastName")
            end
        else
            local user = Sky.DB.GetSingleRow("users", "identifier", sourceOrIdentifier)
            if user then
                return Sky.String.SanitizeForSQL(user.lastname)
            end
        end

        return nil
    end

    function Sky.FW.GetGender(sourceOrIdentifier)
        _sky_dbg("Sky.FW.GetGender", sourceOrIdentifier)
        if type(sourceOrIdentifier) == "number" then
            local xPlayer = ESX.GetPlayerFromId(sourceOrIdentifier)
            if xPlayer then
               return xPlayer.get("sex")
            end
        else
            local user = Sky.DB.GetSingleRow("users", "identifier", sourceOrIdentifier)
            if user then
                return user.sex
            end
        end

        return nil
    end

    function Sky.FW.GetBirthdate(sourceOrIdentifier)
        _sky_dbg("Sky.FW.GetBirthdate", sourceOrIdentifier)
        if type(sourceOrIdentifier) == "number" then
            local xPlayer = ESX.GetPlayerFromId(sourceOrIdentifier)
            if xPlayer then
               return xPlayer.get("dateofbirth") or xPlayer.get("dob")
            end
        else
            local user = Sky.DB.GetSingleRow("users", "identifier", sourceOrIdentifier)
            if user then
                return user.dateofbirth
            end
        end

        return nil
    end

    function Sky.FW.GetPlayerDirectoryQueryConfig()
        return {
            from = "users u",
            joins = {
                "LEFT JOIN jobs j ON j.name = u.job"
            },
            identifier = "u.identifier",
            firstname = "u.firstname",
            lastname = "u.lastname",
            gender = [[CASE
                WHEN u.sex IN ('0', 'm', 'M', 'male', 'Male') THEN 'male'
                WHEN u.sex IN ('1', 'f', 'F', 'female', 'Female') THEN 'female'
                ELSE 'unknown'
            END]],
            dob = "u.dateofbirth",
            jobName = "u.job",
            jobLabel = "COALESCE(NULLIF(j.label, ''), u.job)",
            orderBy = "LOWER(u.firstname), LOWER(u.lastname), u.identifier"
        }
    end

    function Sky.FW.GetAccountMoney(source, account)
        _sky_dbg("Sky.FW.GetAccountMoney", source, account)
        if account == "cash" then
            account = "money"
        end
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getAccount(account).money
    end

    function Sky.FW.AddAccountMoney(source, account, amount)
        _sky_dbg("Sky.FW.AddAccountMoney", source, account, amount)
        if account == "cash" then
            account = "money"
        end
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addAccountMoney(account, amount)
    end

    function Sky.FW.RemoveAccountMoney(source, account, amount)
        _sky_dbg("Sky.FW.RemoveAccountMoney", source, account, amount)
        if account == "cash" then
            account = "money"
        end
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getAccount(account).money >= amount then
            xPlayer.removeAccountMoney(account, amount)
            return true
        end
        return false
    end

    ---@return {{identifier = string, job_grade = number, name = string|nil }, {...}}
    function Sky.FW.GetJobUsers(jobName)
        _sky_dbg("Sky.FW.GetJobUsers", jobName)
        local now = GetGameTimer()
        local cached = jobUsersCache[jobName]
        if cached and now - cached.createdAt < jobUsersCacheDuration then
            return cached.users
        end

        local users = {}
        local offset = 0
        local pageSize = 500

        while true do
            local page = MySQL.query.await([[
                SELECT identifier, job_grade, firstname, lastname
                FROM users
                WHERE job IN (@job, @offJob, @offUnderscoreJob)
                ORDER BY identifier
                LIMIT @limit OFFSET @offset
            ]], {
                ["@job"] = jobName,
                ["@offJob"] = "off" .. jobName,
                ["@offUnderscoreJob"] = "off_" .. jobName,
                ["@limit"] = pageSize,
                ["@offset"] = offset
            }) or {}

            for i = 1, #page do
                local row = page[i]
                if row.firstname or row.lastname then
                    -- Provide the display name here so consumers don't fall back to a per-user
                    -- Sky.FW.GetName() DB lookup (matches the QB/Qbox GetJobUsers return shape).
                    row.name = Sky.String.SanitizeForSQL((row.firstname or "") .. " " .. (row.lastname or ""))
                end
                users[#users + 1] = row
            end

            if #page < pageSize then
                break
            end
            offset = offset + pageSize
        end

        jobUsersCache[jobName] = {
            users = users,
            createdAt = now
        }
        return users
    end

    ---Get Job from online or offline Player
    ---@param source string|number Can be identifier or player id
    ---@return string
    function Sky.FW.GetJob(sourceOrIdentifier)
        _sky_dbg("Sky.FW.GetJob", sourceOrIdentifier)

        if type(sourceOrIdentifier) == "number" then
            local xPlayer = ESX.GetPlayerFromId(sourceOrIdentifier)
            if xPlayer ~= nil then
                return xPlayer.job.name
            else
                return ""
            end
        else
            return Sky.DB.GetValue("users", "identifier", sourceOrIdentifier, "job") or ""
        end
    end

    ---Set Job for online or offline Player
    ---@param source string|number Can be identifier or player id
    ---@param jobName string
    ---@param jobGrade number
    function Sky.FW.SetJob(sourceOrIdentifier, jobName, jobGrade)
        _sky_dbg("Sky.FW.SetJob", sourceOrIdentifier, jobName, jobGrade)
        
        if type(sourceOrIdentifier) == "number" then
            local xPlayer = ESX.GetPlayerFromId(sourceOrIdentifier)
            if xPlayer then
                xPlayer.setJob(jobName, jobGrade)
            end
        else
            Sky.DB.SetValue("users", "job", jobName, "identifier", sourceOrIdentifier)
            Sky.DB.SetValue("users", "job_grade", jobGrade, "identifier", sourceOrIdentifier)
        end            
    end

    function Sky.FW.RefreshJobs()
        _sky_dbg("Sky.FW.RefreshJobs")
        if ESX.RefreshJobs then
            ESX.RefreshJobs()
        end
    end

    local function syncEsxJobGrades(jobName, grades)
        local ok, rows = pcall(Sky.Query, "SELECT id, name FROM job_grades WHERE job_name = ?", { jobName })
        if not ok or type(rows) ~= "table" then
            return false
        end

        local existingByName = {}
        for _, row in ipairs(rows) do
            if row.name then
                existingByName[tostring(row.name)] = row
            end
        end

        local desiredIds = {}
        local tempOffset = 10000
        pcall(Sky.Query, "UPDATE job_grades SET grade = grade + ? WHERE job_name = ?", { tempOffset, jobName })

        for grade, gradeData in pairs(grades or {}) do
            local gradeNumber = math.floor(tonumber(grade) or tonumber(type(gradeData) == "table" and gradeData.grade or 0) or 0)
            local gradeInfo = gradeData or {}
            local name = tostring(gradeInfo.name or ("grade_" .. tostring(gradeNumber)))
            local label = tostring(gradeInfo.label or gradeInfo.name or ("Grade " .. tostring(gradeNumber)))
            local salary = math.max(0, math.floor(tonumber(gradeInfo.payment or gradeInfo.salary) or 0))
            local existing = existingByName[name]

            if existing and existing.id then
                desiredIds[tonumber(existing.id)] = true
                -- Never touch salary on edits; job_grades.salary is write-once at creation (INSERT below).
                pcall(Sky.Query, "UPDATE job_grades SET grade = ?, label = ? WHERE id = ?",
                    { gradeNumber, label, existing.id })
            else
                pcall(Sky.Query,
                    "INSERT INTO job_grades (job_name, grade, name, label, salary, skin_male, skin_female) VALUES (?, ?, ?, ?, ?, ?, ?)",
                    { jobName, gradeNumber, name, label, salary, "{}", "{}" })
            end
        end

        for _, row in ipairs(rows) do
            local id = tonumber(row.id)
            if id and not desiredIds[id] then
                pcall(Sky.Query, "DELETE FROM job_grades WHERE id = ?", { id })
            end
        end

        return true
    end

    ---Update Job Data
    ---@param jobName string
    ---@param data { label: string, grades: {[string]: {name: string, isboss?: boolean, payment: number}} }
    function Sky.FW.UpdateJob(jobName, data, skipCheck)
        _sky_dbg("Sky.FW.UpdateJob", jobName, data, skipCheck)
        local job = nil
        if skipCheck ~= true then
            local jobs = getESXJobs()
            job = jobs[jobName]
            if not job then
                Sky.Debug("error", "[Sky.FW.UpdateJob] Job [" .. jobName .. "] not found")
                return
            end
        end

        if data.label ~= nil and (skipCheck == true or not job or job.label ~= data.label) then
            Sky.DB.SetValue("jobs", "label", data.label, "name", jobName)
        end

        if skipCheck == true and type(data.grades) == "table" then
            if not syncEsxJobGrades(jobName, data.grades) then
                Sky.Debug("error", "[Sky.FW.UpdateJob] Failed to sync job grades for " .. jobName)
                return
            end
        elseif data.grades then
            for grade, gradeData in pairs(data.grades) do
                -- Never touch salary on edits; job_grades.salary is write-once at creation.
                local success = pcall(Sky.Query, "UPDATE job_grades SET grade = ? WHERE name = ? AND job_name = ?;",
                    { grade, gradeData.name, jobName })
                if not success then
                    Sky.Debug("error", "[Sky.FW.UpdateJob] Could not update 'grade' for " .. gradeData.name)
                    return
                else
                    Sky.Debug("debug", "Value updated for 'grade' updated")
                end
            end
        end
        Sky.FW.RefreshJobs()
    end

    ---Add grade to job
    ---@param jobName string
    ---@param gradeData {grade: number, name: string, label: string, payment: number}
    ---@return boolean -> success
    function Sky.FW.AddJobGrade(jobName, gradeData, skipCheck)
        _sky_dbg("Sky.FW.AddJobGrade", jobName, gradeData, skipCheck)
        if skipCheck ~= true and Sky.FW.DoesJobExist(jobName, gradeData.grade) then
            Sky.Debug("debug", "Grade does already exist")
            return false
        end

        Sky.DB.AddRow("job_grades", {
            job_name = jobName,
            grade = gradeData.grade,
            name = gradeData.name,
            label = gradeData.label,
            salary = gradeData.payment,
            skin_male = "{}",
            skin_female = "{}"
        })

        Sky.FW.RefreshJobs()
        return true
    end

    ---Remove grade from job
    ---@param jobName string
    ---@param grade number
    ---@return boolean -> success
    function Sky.FW.RemoveJobGrade(jobName, grade, skipCheck)
        _sky_dbg("Sky.FW.RemoveJobGrade", jobName, grade, skipCheck)
        if skipCheck ~= true and not Sky.FW.DoesJobExist(jobName, grade) then
            Sky.Debug("debug", "Grade does not exist")
            return false
        end

        local success = pcall(Sky.Query, "DELETE FROM job_grades WHERE job_name = ? AND grade = ?;",
            { jobName, grade })
        if not success then
            Sky.Debug('error', 'Failed to remove record from table "%s".', "job_grades")
        else
            Sky.Debug('debug', 'Record removed from table "%s" where "%s AND %s" equals "%s AND %s".', "job_grades",
                "grade", "job_name",
                grade, jobName)
        end

        Sky.FW.RefreshJobs()
        return true
    end

    function Sky.FW.DoesJobExist(jobName, grade)
        _sky_dbg("Sky.FW.DoesJobExist", jobName, grade)
        return ESX.DoesJobExist(jobName, tonumber(grade))
    end

    ---Get Jobs
    ---@return {name: string, label: string, grades: {[string]: {grade: number, name: string, label: string, payment: string}}}
    function Sky.FW.GetJobs()
        _sky_dbg("Sky.FW.GetJobs")
        local jobs = getESXJobs()
        for _, job in ipairs(jobs) do
            for _, grade in ipairs(job.grades) do
                grade.payment = grade.salary
            end
        end

        return jobs
    end

    function Sky.FW.GetPlayers()
        _sky_dbg("Sky.FW.GetPlayers")
        return ESX.GetPlayers()
    end

    function Sky.FW.IsVehicleOwnedByPlayer(source, plate)
        _sky_dbg("Sky.FW.IsVehicleOwnedByPlayer", source, plate)
        local xPlayer = ESX.GetPlayerFromId(source)
        local isVehicleOwned = Sky.Query("SELECT * FROM owned_vehicles WHERE plate = @plate AND owner = @owner", {
            ["@plate"] = plate,
            ["@owner"] = xPlayer.identifier,
        })
        if not isVehicleOwned[1] or isVehicleOwned[1].owner ~= xPlayer.identifier then
            return false
        else
            return true
        end
    end

    ---Get Job Data from online or offline Player (offline only: "name"|"grade")
    ---@param source string|number Can be identifier or player id
    ---@param action "name"|"label"|"grade"|"grade_name"|"grade_label"|"duty"
    ---@return string|boolean
    function Sky.FW.GetJobData(sourceOrIdentifier, action)
        _sky_dbg("Sky.FW.GetJobData", sourceOrIdentifier, action)
        
        if type(sourceOrIdentifier) == "number" then
            local xPlayer = ESX.GetPlayerFromId(sourceOrIdentifier)
            if xPlayer ~= nil then
                if action == "name" then
                    return xPlayer.getJob().name
                elseif action == "label" then
                    return xPlayer.getJob().label
                elseif action == "grade" then
                    return xPlayer.getJob().grade
                elseif action == "grade_name" then
                    return xPlayer.getJob().grade_name
                elseif action == "grade_label" then
                    return xPlayer.getJob().grade_label
                elseif action == "duty" then
                    local onDuty = xPlayer.getJob().onDuty
                    if onDuty == nil then
                        return false
                    end
                    return onDuty == true
                end
            else
                return ""
            end
        else
            local jobName = Sky.DB.GetValue("users", "identifier", sourceOrIdentifier, "job")
            local jobGrade = Sky.DB.GetValue("users", "identifier", sourceOrIdentifier, "job_grade")
            if action == "name" then
                return jobName
            elseif action == "label" then
                return "N/A"
            elseif action == "grade" then
                return jobGrade
            elseif action == "grade_name" then
                return "N/A"
            elseif action == "grade_label" then
                return "N/A"
            end
        end
    end

    function Sky.FW.GetStatus(source, name)
        _sky_dbg("Sky.FW.GetStatus", source, name)
        local status = 0

        TriggerEvent('esx_status:getStatus', source, name, function(pStatus)
            _sky_dbg("esx_status:getStatus callback", pStatus)
            if pStatus then
                status = (pStatus.val / 10000)
            end
        end)

        return status
    end

    function Sky.FW.ChangePlayerName(sourceOrIdentifier, firstname, lastname)
        _sky_dbg("Sky.FW.ChangePlayerName", sourceOrIdentifier, firstname, lastname)

        if type(sourceOrIdentifier) == "number" then
            local xPlayer = ESX.GetPlayerFromId(sourceOrIdentifier)
            if xPlayer then
                xPlayer.setName(firstname .. " " .. lastname)
                xPlayer.set("firstName", firstname)
                xPlayer.set("lastName", lastname)
                Sky.DB.SetValue("users", "firstname", firstname, "identifier", xPlayer.identifier)
                Sky.DB.SetValue("users", "lastname", lastname, "identifier", xPlayer.identifier)
            end
        else
            Sky.DB.SetValue("users", "firstname", firstname, "identifier", sourceOrIdentifier)
            Sky.DB.SetValue("users", "lastname", lastname, "identifier", sourceOrIdentifier)
        end
    end

    RegisterServerEvent('esx:onPlayerDeath')
    AddEventHandler('esx:onPlayerDeath', function(data)
        _sky_dbg("esx:onPlayerDeath", data)
        TriggerClientEvent("sky_base:onPlayerDeath", source)
    end)

    function Sky.FW.SetStatus(source, name, val)
        _sky_dbg("Sky.FW.SetStatus", source, name, val)
        local statusValue = tonumber(val) or 0
        if math.abs(statusValue) > 100 then
            statusValue = statusValue / 10000
        end

        TriggerClientEvent('esx_status:set', source, name, statusValue * 10000)
    end

    function Sky.FW.IsDead(source)
        _sky_dbg("Sky.FW.IsDead", source)
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.dead
    end

    function Sky.FW.GetPlaytime(source)
        _sky_dbg("Sky.FW.GetPlaytime", source)
        local src = tonumber(source)
        if not src then
            Sky.Debug("warn", "GetPlaytime: Invalid 'source' provided. Must be a number.")
            return 0
        end

        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then
            return 0
        end

        local playtimeMinutes
        if xPlayer.getMetaData then
            playtimeMinutes = xPlayer.getMetaData('totalplaytime')
        elseif xPlayer.getMeta then
            playtimeMinutes = xPlayer.getMeta('totalplaytime')
        else
            local metadata = xPlayer.get and xPlayer.get('metadata')
            if metadata then
                playtimeMinutes = metadata.totalplaytime
            end
        end
        playtimeMinutes = playtimeMinutes or 0

        if playtimeMinutes == 0 and xPlayer.get('time') then
            playtimeMinutes = xPlayer.get('time') / 60000
        end

        return playtimeMinutes
    end

    function Sky.FW.SendBill(target, account, reason, amount)
        _sky_dbg("Sky.FW.SendBill", target, account, reason, amount)
        TriggerEvent('esx_billing:sendBill', target, account, reason, amount)
    end

    function Sky.FW.HasCommandPermission(source, acePerm)
        if source == 0 then return true end
        return IsPlayerAceAllowed(source, acePerm)
    end

    ---Check if a player should be visible on CCTV/Bodycam/Dashcam
    ---@param source string|number
    ---@return boolean
    function Sky.FW.IsPlayerVisibleOnCamera(source)
        local ped = GetPlayerPed(source)
        if not ped or ped == 0 or not DoesEntityExist(ped) then
            return false
        end
        return IsEntityVisible(ped)
    end

    ---Set Duty status for a player (no-op: ESX has no native duty system)
    ---@param source string|number
    ---@param onDuty boolean
    function Sky.FW.SetDuty(source, onDuty)
    end

    ---Toggle Duty status for a player (no-op: ESX has no native duty system)
    ---@param source string|number
    function Sky.FW.ToggleDuty(source)
    end

    ---Get count of on-duty players for a specific job (ESX: always 0)
    ---@param jobName string
    ---@return number count
    ---@return table sources
    function Sky.FW.GetOnDutyCount(jobName)
        return 0, {}
    end
end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
