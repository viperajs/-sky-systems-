if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/config/framework/qb.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

if Sky.Config.framework == "qb" then
    Sky.FW = {}

    -- Get Qb
    QBCore = exports['qb-core']:GetCoreObject()

    if IsDuplicityVersion() then goto server end

    -- Jobs Creator (https://documentation.jaksam-scripts.com/jobs-creator/client)
    RegisterNetEvent("jobs_creator:injectJobs", function(jobs)
        QBCore.Shared.Jobs = jobs
    end)

    -- Client Side from here

    --Update Hunger and Thirst
    RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
        TriggerEvent("sky_base:updateHungerAndThirst", newHunger, newThirst)
    end)

    -- Is Player Loaded
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        TriggerEvent("sky_base:playerLoaded")
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        TriggerEvent("sky_base:playerUnloaded")
    end)

    --Update Money
    RegisterNetEvent('QBCore:Client:OnMoneyChange', function(account, amount, isMinus)
        local newMoney = QBCore.Functions.GetPlayerData().money[account]
        TriggerEvent("sky_base:updateAccountMoney", account, newMoney)
    end)

    --Entered Car and Left
    RegisterNetEvent('QBCore:Client:VehicleInfo', function(data)
        if data.event == "Entered" then
            TriggerEvent("sky_base:enteredVehicle", data.vehicle, data.plate, data.seat)
        elseif data.event == "Left" then
            TriggerEvent("sky_base:exitedVehicle", data.vehicle, data.plate, data.seat)
        end
    end)

    -- server-bound sync runs via the server-side QBCore:Server:OnJobUpdate handler
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
        jobInfo.grade_label = jobInfo.grade.name
        TriggerEvent("sky_base:updateJob", jobInfo)
        TriggerServerEvent("sky_base:updateJob", jobInfo)
    end)

    -- catch direct duty toggle from QBCore/QBox native system
    RegisterNetEvent('QBCore:Client:SetDuty', function(onDuty)
        TriggerServerEvent("sky_base:syncDuty", onDuty == true)
    end)

    --Added Item
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        TriggerEvent("sky_base:inventoryUpdated")
    end)

    ::server::
    if not IsDuplicityVersion() then return end
    -- Server Side from here


    -- QBCore fires this server-locally with the player object on login; AddEventHandler
    -- keeps it off the net surface so clients cannot inject playerLoaded for arbitrary
    -- sources. (QBCore:Server:OnPlayerLoaded is the client-fired variant without payload.)
    AddEventHandler("QBCore:Server:PlayerLoaded", function(player)
        TriggerEvent("sky_base:playerLoaded", player.PlayerData.source)
    end)

    -- QBCore fires this server-locally on logout/character switch (multichar)
    AddEventHandler("QBCore:Server:OnPlayerUnload", function(src)
        TriggerEvent("sky_base:playerUnloaded", src)
    end)

    -- catch server-side job/duty changes from QBCore (e.g. admin, other scripts)
    AddEventHandler("QBCore:Server:OnJobUpdate", function(src, job)
        if src and job and type(job) == "table" then
            if Sky_Jobs and Sky_Jobs.PlayerCache and Sky_Jobs.PlayerCache.UpdateJob then
                Sky_Jobs.PlayerCache.UpdateJob(src, job)
            end
        end
    end)

    local function updateSkyJobsPlayerCache(src)
        if not src or not Sky_Jobs or not Sky_Jobs.PlayerCache or not Sky_Jobs.PlayerCache.UpdateJob then
            return
        end
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if xPlayer and xPlayer.PlayerData and xPlayer.PlayerData.job then
            Sky_Jobs.PlayerCache.UpdateJob(src, xPlayer.PlayerData.job)
        end
    end

    -- authoritative duty sync: QBCore fires this server-locally from SetJobDuty;
    -- re-reads PlayerData.job (incl. onduty) instead of trusting any forwarded flag
    AddEventHandler("QBCore:Server:SetDuty", function(src)
        updateSkyJobsPlayerCache(src)
    end)

    -- Jobs Creator (https://documentation.jaksam-scripts.com/jobs-creator/server)
    RegisterNetEvent("jobs_creator:injectJobs", function(jobs)
        if type(source) == "number" and source > 0 then return end
        QBCore.Shared.Jobs = jobs
    end)

    RegisterNetEvent("jobs_creator:toggleDuty", function(playerId, jobName, isOnDuty)
        if not playerId then return end
        updateSkyJobsPlayerCache(playerId)
    end)

    RegisterNetEvent("jobs_creator:boss:playerHired", function(playerId, jobName)
        if not playerId then return end
        updateSkyJobsPlayerCache(playerId)
    end)

    RegisterNetEvent("jobs_creator:boss:employeeFired", function(employeeIdentifier, jobName)
        if not employeeIdentifier then return end
        local xPlayer = QBCore.Functions.GetPlayerByCitizenId(employeeIdentifier)
        if xPlayer then
            updateSkyJobsPlayerCache(xPlayer.PlayerData.source)
        end
    end)

    function Sky.FW.IsPlayerOnline(sourceOrIdentifier)
        local xPlayer = QBCore.Functions.GetPlayer(sourceOrIdentifier)
        if xPlayer == nil then
            xPlayer = QBCore.Functions.GetPlayerByCitizenId(tostring(sourceOrIdentifier))
            if xPlayer == nil then
                return false
            else
                return xPlayer.PlayerData.source
            end
        else
            return xPlayer.PlayerData.citizenid
        end
    end

    function Sky.FW.GetIdentifier(source)
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(source))
        if not xPlayer then
            Sky.Debug("debug", "[Sky.FW.GetIdentifier] Player not found for source: " .. tostring(source))
            return
        end
        return tostring(xPlayer.PlayerData.citizenid)
    end

    function Sky.FW.GetName(source)
        local xPlayer = tonumber(source) and QBCore.Functions.GetPlayer(tonumber(source))
        local identifier = source
        if xPlayer then
            identifier = xPlayer.PlayerData.citizenid
        end

        local result = Sky.DB.GetValue("players", "citizenid", identifier, "charinfo")

        if result then
            local charinfo = json.decode(result)
            return Sky.String.SanitizeForSQL(charinfo.firstname .. " " .. charinfo.lastname)
        end
    end

    function Sky.FW.GetFirstname(source)
        local xPlayer = tonumber(source) and QBCore.Functions.GetPlayer(tonumber(source))
        local identifier = source
        if xPlayer then
            return Sky.String.SanitizeForSQL(xPlayer.PlayerData.charinfo.firstname)
        end

        local result = Sky.DB.GetValue("players", "citizenid", identifier, "charinfo")
        if result then
            local charinfo = json.decode(result)
            if charinfo then
                return Sky.String.SanitizeForSQL(charinfo.firstname)
            end
        end
    end

    function Sky.FW.GetLastname(source)
        local xPlayer = tonumber(source) and QBCore.Functions.GetPlayer(tonumber(source))
        local identifier = source
        if xPlayer then
            return Sky.String.SanitizeForSQL(xPlayer.PlayerData.charinfo.lastname)
        end

        local result = Sky.DB.GetValue("players", "citizenid", identifier, "charinfo")
        if result then
            local charinfo = json.decode(result)
            if charinfo then
                return Sky.String.SanitizeForSQL(charinfo.lastname)
            end
        end
    end

    function Sky.FW.GetGender(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if not xPlayer then return end
        return xPlayer.PlayerData.charinfo.gender
    end

    function Sky.FW.GetBirthdate(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if not xPlayer then return end
        local charInfo = xPlayer.PlayerData and xPlayer.PlayerData.charinfo
        if type(charInfo) ~= "table" then return end
        return charInfo.birthdate
    end

    function Sky.FW.GetPlayerDirectoryQueryConfig()
        return {
            from = "players p",
            joins = {},
            identifier = "p.citizenid",
            firstname = "JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.firstname'))",
            lastname = "JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.lastname'))",
            gender = [[CASE
                WHEN JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.gender')) IN ('0', 'm', 'M', 'male', 'Male') THEN 'male'
                WHEN JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.gender')) IN ('1', 'f', 'F', 'female', 'Female') THEN 'female'
                ELSE 'unknown'
            END]],
            dob = "JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.birthdate'))",
            jobName = "JSON_UNQUOTE(JSON_EXTRACT(p.job, '$.name'))",
            jobLabel = "COALESCE(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p.job, '$.label')), ''), JSON_UNQUOTE(JSON_EXTRACT(p.job, '$.name')))",
            orderBy = "LOWER(JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.firstname'))), LOWER(JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.lastname'))), p.citizenid"
        }
    end

    function Sky.FW.GetAccountMoney(source, account)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if account == "money" then
            account = "cash"
        elseif account == "black_money" then
            account = "black"
        end
        return xPlayer.PlayerData.money[account]
    end

    function Sky.FW.AddAccountMoney(source, account, amount)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if account == "money" then
            account = "cash"
        elseif account == "black_money" then
            account = "black"
        end
        xPlayer.Functions.AddMoney(account, amount)
    end

    function Sky.FW.RemoveAccountMoney(source, account, amount)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if account == "money" then
            account = "cash"
        elseif account == "black_money" then
            account = "black"
        end
        if xPlayer.PlayerData.money[account] >= amount then
            xPlayer.Functions.RemoveMoney(account, amount)
            return true
        end
        return false
    end

    local jobUsersCache = {}
    local jobUsersCacheDuration = 60000

    ---@return {{identifier = string, job_grade = number, name = string|nil }, {...}}
    function Sky.FW.GetJobUsers(jobName)
        local now = GetGameTimer()
        local cached = jobUsersCache[jobName]
        if cached and now - cached.createdAt < jobUsersCacheDuration then
            return cached.users
        end

        local users = {}
        local result = MySQL.query.await(
            "SELECT citizenid, job, name, charinfo FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(job, '$.name')) = @job",
            {
                ["@job"] = jobName
            })
        for _, user in ipairs(result) do
            if user ~= nil then
                local charinfo = user.charinfo and json.decode(user.charinfo) or nil
                local name = user.name
                if not name and charinfo and charinfo.firstname then
                    name = string.format("%s %s", charinfo.firstname, charinfo.lastname or "")
                end
                table.insert(users, {
                    identifier = user.citizenid,
                    job_grade = json.decode(user.job).grade.level,
                    name = name
                })
            end
        end

        jobUsersCache[jobName] = {
            users = users,
            createdAt = now
        }
        return users
    end

    ---Get Job from online or offline Player
    ---@param source string|number Can be license or player id
    ---@return string
    function Sky.FW.GetJob(source)
        if Sky.FW.IsPlayerOnline(source) then
            local xPlayer = QBCore.Functions.GetPlayer(source)
            if xPlayer ~= nil then
                return xPlayer.PlayerData.job.name
            else
                return ""
            end
        else
            if type(source) == "string" then
                local jobData = Sky.DB.GetValue("players", "license", source, "job")
                if not jobData then
                    Sky.Debug("warn",
                        "[Sky.FW.GetJob] No job data found for offline player with license: " .. tostring(source))
                    return ""
                end
                return jobData.name
            end
        end
    end

    ---Set Job for online or offline Player
    ---@param source string|number Can be license or player id
    ---@param jobName string
    ---@param jobGrade number
    function Sky.FW.SetJob(source, jobName, jobGrade)
        if Sky.FW.IsPlayerOnline(source) then
            local xPlayer = QBCore.Functions.GetPlayer(source)
            if not xPlayer then return end
            xPlayer.Functions.SetJob(jobName, jobGrade)
        else
            local jobData = Sky.DB.GetValue("players", "license", source, "job")
            jobData.name = jobName
            jobData.grade.level = jobGrade
            Sky.DB.SetValue("players", "job", jobData, "license", source)
        end
    end

    ---Set Duty status for a player
    ---@param source string|number Can be license or player id
    ---@param onDuty boolean
    function Sky.FW.SetDuty(source, onDuty)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if not xPlayer then return end
        xPlayer.Functions.SetJobDuty(onDuty)
    end

    ---Toggle Duty status for a player
    ---@param source string|number Can be license or player id
    function Sky.FW.ToggleDuty(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if not xPlayer then return end
        local currentDuty = xPlayer.PlayerData.job.onduty
        QBCore.Functions.SetJobDuty(source, not currentDuty)
    end

    ---Get count of on-duty players for a specific job
    ---@param jobName string
    ---@return number count
    ---@return table sources Array of player sources
    function Sky.FW.GetOnDutyCount(jobName)
        -- Use Sky_Jobs cache when available (O(k) where k = on-duty count for that job)
        if Sky_Jobs and Sky_Jobs.GetOnDutyCount then
            return Sky_Jobs.GetOnDutyCount(jobName)
        end

        -- Fallback: iterate all players (only if Sky_Jobs is not loaded)
        local sources = {}
        local players = QBCore.Functions.GetPlayers()
        local jobsCreatorStarted = GetResourceState("jobs_creator") == "started"
        for _, playerId in pairs(players) do
            local xPlayer = QBCore.Functions.GetPlayer(playerId)
            if xPlayer and xPlayer.PlayerData and xPlayer.PlayerData.job then
                local job = xPlayer.PlayerData.job
                local isOnDuty
                if jobsCreatorStarted then
                    isOnDuty = exports["jobs_creator"]:isPlayerOnDuty(playerId)
                else
                    isOnDuty = job.onduty
                end
                if job.name == jobName and isOnDuty then
                    sources[#sources + 1] = playerId
                end
            end
        end

        return #sources, sources
    end

    function Sky.FW.DoesJobExist(jobName, grade)
        local jobs = QBCore.Shared.Jobs
        local job = jobs[jobName]
        if job then
            local grade = job.grades[tostring(grade)]
            if grade then
                return true
            end
        end
        return false
    end

    ---Get Jobs
    ---@return {name: string, label: string, grades: {[string]: {grade: number, name: string, label: string, payment: string}}}
    function Sky.FW.GetJobs()
        local jobs = QBCore.Shared.Jobs
        for name, job in pairs(jobs) do
            for gradeIndex, grade in pairs(job.grades) do
                job.grades[gradeIndex].grade = tonumber(gradeIndex)
                job.grades[gradeIndex].name = string.lower(grade.name)
                job.grades[gradeIndex].label = grade.name
            end
            jobs[name] = {
                name = name,
                label = job.label,
                grades = job.grades
            }
        end
        return jobs
    end

    function Sky.FW.GetPlayers()
        return QBCore.Functions.GetPlayers()
    end

    function Sky.FW.IsVehicleOwnedByPlayer(source, plate)
        if GetResourceState("jobs_creator") == "started" then
            if exports["jobs_creator"]:isPlayerOwnerOfVehiclePlate(source, plate) then
                return true
            end
        end

        local xPlayer = QBCore.Functions.GetPlayer(source)
        local isVehicleOwned = Sky.Query("SELECT * FROM player_vehicles WHERE plate = @plate AND license = @license", {
            ["@plate"] = plate,
            ["@license"] = xPlayer.PlayerData.license,
        })
        if not isVehicleOwned[1] or isVehicleOwned[1].license ~= xPlayer.PlayerData.license then
            return false
        else
            return true
        end
    end

    ---Get Job Data from online or offline Player
    ---@param source string|number Can be license or player id
    ---@param what "name"|"label"|"grade"|"grade_name"|"grade_label"|"duty"
    ---@return string?
    function Sky.FW.GetJobData(source, what)
        if Sky.FW.IsPlayerOnline(source) then
            local xPlayer = QBCore.Functions.GetPlayer(source)
            if not xPlayer then return nil end
            if what == "name" then
                return xPlayer.PlayerData.job.name
            elseif what == "label" then
                return xPlayer.PlayerData.job.label
            elseif what == "grade" then
                return xPlayer.PlayerData.job.grade.level
            elseif what == "grade_name" then
                return xPlayer.PlayerData.job.grade.name
            elseif what == "grade_label" then
                return xPlayer.PlayerData.job.grade.name
            elseif what == "duty" then
                if GetResourceState("jobs_creator") == "started" then
                    return exports["jobs_creator"]:isPlayerOnDuty(source)
                end
                return xPlayer.PlayerData.job.onduty
            end
        else
            if type(source) == "number" then
                Sky.Debug("warn",
                    "[Sky.FW.GetJobData] Offline player job data requested with player ID. License expected. Source: "
                    .. tostring(source))
                return ""
            end
            local jobData = Sky.DB.GetValue("players", "license", source, "job")
            if what == "name" then
                return jobData.name
            elseif what == "label" then
                return jobData.label
            elseif what == "grade" then
                return jobData.grade.level
            elseif what == "grade_name" then
                return jobData.grade.name
            elseif what == "grade_label" then
                return jobData.grade.name
            end
        end
    end

    function Sky.FW.GetStatus(source, name)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        return xPlayer.PlayerData.metadata[name]
    end

    function Sky.FW.ChangePlayerName(source, firstname, lastname)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local charInfo = xPlayer.PlayerData.charinfo
        charInfo.firstname = firstname
        charInfo.lastname = lastname
        xPlayer.Functions.SetPlayerData("charinfo", charInfo)
        xPlayer.Functions.Save()
        xPlayer.Functions.UpdatePlayerData(false)
        TriggerClientEvent('QBCore:Player:UpdatePlayerData', source)
    end

    RegisterServerEvent('hospital:server:SetDeathStatus', function(isDead)
        if isDead then
            TriggerClientEvent("sky_base:onPlayerDeath", source)
        end
    end)

    function Sky.FW.SetStatus(source, name, value)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        xPlayer.Functions.SetMetaData(name, value)
        xPlayer.Functions.UpdatePlayerData(false)
    end

    function Sky.FW.IsDead(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        return xPlayer.PlayerData.metadata.isdead
    end

    function Sky.FW.GetPlaytime(source)
        local src = tonumber(source)
        if not src then
            Sky.Debug("warn", "GetPlaytime: Invalid 'source' provided. Must be a number.")
            return 0
        end

        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then
            return 0
        end

        local playtimeMinutes = Player.PlayerData.metadata["playtime"] or 0

        return playtimeMinutes
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
end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
