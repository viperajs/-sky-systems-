if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/config/framework/qbox.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

if Sky.Config.framework == "qbox" then
    Sky.FW = {}


    if IsDuplicityVersion() then goto server end
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
        local newMoney = exports.qbx_core:GetPlayerData().money[account]
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
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
        TriggerEvent("sky_base:updateJob", JobInfo)
    end)

    -- catch direct duty toggle from QBCore/QBox native system
    RegisterNetEvent('QBCore:Client:SetDuty', function(onDuty)
        TriggerEvent("sky_base:updateDuty", onDuty == true)
    end)

    --Added Item
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        TriggerEvent("sky_base:inventoryUpdated")
    end)

    ::server::
    if not IsDuplicityVersion() then return end
    -- Server Side from here


    -- qbx_core fires this server-locally with the player object on login; AddEventHandler
    -- keeps it off the net surface so clients cannot inject playerLoaded for arbitrary
    -- sources. (QBCore:Server:OnPlayerLoaded is the client-fired variant without payload.)
    AddEventHandler("QBCore:Server:PlayerLoaded", function(player)
        TriggerEvent("sky_base:playerLoaded", player.PlayerData.source)
    end)

    -- qbx_core fires this server-locally on logout/character switch (multichar)
    AddEventHandler("QBCore:Server:OnPlayerUnload", function(src)
        TriggerEvent("sky_base:playerUnloaded", src)
    end)

    -- Job and duty changes are read by the job resources themselves (sky_jobs_base listens
    -- to QBCore:Server:SetDuty / OnJobUpdate); Sky_Jobs does not exist in this resource.

    function Sky.FW.IsPlayerOnline(sourceOrIdentifier)
        local xPlayer = exports.qbx_core:GetPlayer(sourceOrIdentifier)
        if xPlayer == nil then
            xPlayer = exports.qbx_core:GetPlayerByCitizenId(tostring(sourceOrIdentifier))
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
        local xPlayer = exports.qbx_core:GetPlayer(tonumber(source))
        if not xPlayer then
            Sky.Debug("debug", "[Sky.FW.GetIdentifier] Player not found for source: " .. tostring(source))
            return
        end
        return tostring(xPlayer.PlayerData.citizenid)
    end

    local function getOfflinePlayerSafe(sourceOrIdentifier, context)
        local success, xPlayer = pcall(function()
            return exports.qbx_core:GetOfflinePlayer(sourceOrIdentifier)
        end)

        if not success then
            Sky.Debug("warn",
                "[qbox] GetOfflinePlayer failed for %s '%s'. This usually means qbx_core has a stale group/job member or the matching players row is missing. Error: %s",
                context or "identifier",
                tostring(sourceOrIdentifier),
                tostring(xPlayer)
            )
            return nil
        end

        return xPlayer
    end

    -- Player by server id (online only), FiveM identifier (online) or citizenid (online,
    -- then offline). Sky.FW.GetIdentifier hands out citizenids, which qbx_core:GetPlayer
    -- does not resolve, and the old offline lookup searched the license column with them.
    local function resolvePlayer(identifier, allowOffline)
        local src = tonumber(identifier)
        if src then
            return exports.qbx_core:GetPlayer(src)
        end
        if type(identifier) ~= "string" or identifier == "" then
            return nil
        end
        if identifier:find(":", 1, true) then
            return exports.qbx_core:GetPlayer(identifier)
        end

        local xPlayer = exports.qbx_core:GetPlayerByCitizenId(identifier)
        if not xPlayer and allowOffline ~= false then
            xPlayer = getOfflinePlayerSafe(identifier, "citizenid")
        end
        return xPlayer
    end

    local function getCharinfo(identifier)
        local xPlayer = resolvePlayer(identifier)
        local charinfo = xPlayer and xPlayer.PlayerData and xPlayer.PlayerData.charinfo
        return type(charinfo) == "table" and charinfo or nil
    end

    -- nil when unknown, so callers can fall back (e.g. to GetPlayerName).
    function Sky.FW.GetName(sourceOrIdentifier)
        local charinfo = getCharinfo(sourceOrIdentifier)
        if not charinfo then return nil end

        local name = string.format("%s %s", charinfo.firstname or "", charinfo.lastname or ""):match("^%s*(.-)%s*$")
        if name == "" then return nil end
        return Sky.String.SanitizeForSQL(name)
    end

    function Sky.FW.GetFirstname(sourceOrIdentifier)
        local charinfo = getCharinfo(sourceOrIdentifier)
        if not charinfo then return end
        return Sky.String.SanitizeForSQL(charinfo.firstname or "")
    end

    function Sky.FW.GetLastname(sourceOrIdentifier)
        local charinfo = getCharinfo(sourceOrIdentifier)
        if not charinfo then return end
        return Sky.String.SanitizeForSQL(charinfo.lastname or "")
    end

    function Sky.FW.GetGender(source)
        local xPlayer = exports.qbx_core:GetPlayer(source)
        if not xPlayer then return end
        return xPlayer.PlayerData.charinfo.gender
    end

    function Sky.FW.GetBirthdate(source)
        local xPlayer = exports.qbx_core:GetPlayer(source)
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

    local function normalizeAccount(account)
        if account == "money" then return "cash" end
        if account == "black_money" then return "black" end
        return account
    end

    local function isValidAmount(amount)
        return type(amount) == "number" and amount == amount and amount > 0 and amount ~= math.huge
    end

    function Sky.FW.GetAccountMoney(source, account)
        local xPlayer = exports.qbx_core:GetPlayer(source)
        if not xPlayer then return 0 end
        return tonumber(xPlayer.PlayerData.money[normalizeAccount(account)]) or 0
    end

    -- Returns whether the money was added; callers refund or abort on false.
    function Sky.FW.AddAccountMoney(source, account, amount)
        local xPlayer = exports.qbx_core:GetPlayer(source)
        amount = tonumber(amount)
        if not xPlayer or not isValidAmount(amount) then return false end
        return xPlayer.Functions.AddMoney(normalizeAccount(account), amount) ~= false
    end

    -- Only true when qbx_core actually removed the money (negative amounts, unknown
    -- accounts and vetoed removals used to count as paid).
    function Sky.FW.RemoveAccountMoney(source, account, amount)
        local xPlayer = exports.qbx_core:GetPlayer(source)
        amount = tonumber(amount)
        if not xPlayer or not isValidAmount(amount) then return false end

        account = normalizeAccount(account)
        local balance = tonumber(xPlayer.PlayerData.money[account])
        if not balance or balance < amount then return false end
        return xPlayer.Functions.RemoveMoney(account, amount) ~= false
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

        local groupMembers = exports.qbx_core:GetGroupMembers(jobName, "job")
        local users = {}
        for _, user in ipairs(groupMembers) do
            if user ~= nil then
                table.insert(users, {
                    identifier = user.citizenid,
                    job_grade = user.grade
                })
            end
        end

        if #users > 0 then
            local placeholders = {}
            local params = {}
            for index, user in ipairs(users) do
                placeholders[index] = "?"
                params[index] = user.identifier
            end
            local rows = MySQL.query.await(
                ("SELECT citizenid, TRIM(CONCAT(COALESCE(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')), ''), ' ', COALESCE(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')), ''))) AS name FROM players WHERE citizenid IN (%s)")
                    :format(table.concat(placeholders, ", ")),
                params
            )
            local namesByCitizenId = {}
            for _, row in ipairs(rows or {}) do
                if row.name and row.name ~= "" then
                    namesByCitizenId[row.citizenid] = row.name
                end
            end
            for _, user in ipairs(users) do
                user.name = namesByCitizenId[user.identifier]
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
        local xPlayer = resolvePlayer(source)
        local job = xPlayer and xPlayer.PlayerData and xPlayer.PlayerData.job
        return type(job) == "table" and job.name or ""
    end

    ---Set Job for online or offline Player
    ---@param source string|number Can be license or player id
    ---@param jobName string
    ---@param jobGrade number
    -- Returns qbx_core's result: false (and the error) for an unknown job or grade.
    function Sky.FW.SetJob(source, jobName, jobGrade)
        local ok, err = exports.qbx_core:SetJob(source, jobName, tonumber(jobGrade) or 0)
        jobUsersCache = {}
        if ok == false then
            Sky.Debug("warn", "[qbox] SetJob %s -> %s (grade %s) failed: %s", tostring(source), tostring(jobName), tostring(jobGrade), type(err) == "table" and tostring(err.message or err.code) or tostring(err))
        end
        return ok ~= false, err
    end

    ---Set Duty status for a player
    ---@param source string|number Can be license or player id
    ---@param onDuty boolean
    function Sky.FW.SetDuty(source, onDuty)
        exports.qbx_core:SetJobDuty(source, onDuty)
    end

    ---Toggle Duty status for a player
    ---@param source string|number Can be license or player id
    function Sky.FW.ToggleDuty(source)
        local xPlayer = exports.qbx_core:GetPlayer(source)
        if not xPlayer then return end
        local currentDuty = xPlayer.PlayerData.job.onduty
        exports.qbx_core:SetJobDuty(source, not currentDuty)
    end

    ---Get count of on-duty players for a specific job
    ---@param jobName string
    ---@return number count
    ---@return table sources Array of player sources
    function Sky.FW.GetOnDutyCount(jobName)
        return exports.qbx_core:GetDutyCountJob(jobName)
    end

    function Sky.FW.DoesJobExist(jobName, grade)
        if type(jobName) ~= "string" or jobName == "" then return false end
        local job = exports.qbx_core:GetJob(jobName)
        if not job then return false end
        if grade == nil then return true end
        return type(job.grades) == "table" and job.grades[tonumber(grade)] ~= nil
    end

    ---Get Jobs
    ---@return {name: string, label: string, grades: {[string]: {grade: number, name: string, label?: string, payment: string}}}
    function Sky.FW.GetJobs()
        local jobs = exports.qbx_core:GetJobs() or {}
        local result = {}
        for name, job in pairs(jobs) do
            local normalizedGrades = {}
            -- qbx grades start at [0], so ipairs skipped the first grade (and any after a gap).
            for id, grade in pairs(type(job.grades) == "table" and job.grades or {}) do
                local key = tostring(id)
                normalizedGrades[key] = {
                    grade = tonumber(id),
                    payment = grade.payment or 0,
                    name = string.lower(grade.name or key),
                    label = grade.name or key,
                    isboss = grade.isboss == true
                }
            end
            result[name] = {
                name = name,
                label = job.label,
                grades = normalizedGrades
            }
        end
        return result
    end

    -- GetPlayersInBucket(0) is empty on Qbox unless a script set routing buckets.
    function Sky.FW.GetPlayers()
        local players = {}
        for _, id in ipairs(GetPlayers()) do
            local src = tonumber(id)
            if src and exports.qbx_core:GetPlayer(src) then
                players[#players + 1] = src
            end
        end
        return players
    end

    -- Vehicles belong to a character (citizenid); the license is shared by all
    -- characters of an account.
    function Sky.FW.IsVehicleOwnedByPlayer(source, plate)
        local xPlayer = exports.qbx_core:GetPlayer(source)
        if not xPlayer or type(plate) ~= "string" or plate == "" then
            return false
        end

        local trimmed = plate:match("^%s*(.-)%s*$")
        local rows = Sky.Query("SELECT 1 FROM player_vehicles WHERE (plate = @plate OR plate = @rawPlate) AND citizenid = @citizenid LIMIT 1", {
            ["@plate"] = trimmed,
            ["@rawPlate"] = plate,
            ["@citizenid"] = xPlayer.PlayerData.citizenid,
        })
        return type(rows) == "table" and rows[1] ~= nil
    end

    ---Get Job Data from online or offline Player
    ---@param source string|number Can be license or player id
    ---@param what "name"|"label"|"grade"|"grade_name"|"grade_label"|"duty"
    ---@return string?
    function Sky.FW.GetJobData(source, what)
        local xPlayer = resolvePlayer(source)
        local job = xPlayer and xPlayer.PlayerData and xPlayer.PlayerData.job
        if type(job) ~= "table" then return nil end

        if what == "name" then
            return job.name
        elseif what == "label" then
            return job.label
        elseif what == "grade" then
            return job.grade and job.grade.level
        elseif what == "grade_name" or what == "grade_label" then
            return job.grade and job.grade.name
        elseif what == "duty" then
            return job.onduty == true
        elseif what == "isboss" then
            return job.isboss == true
        end
        return nil
    end

    -- Qbox marks boss grades with isboss; callers otherwise guessed "grade >= 4".
    function Sky.FW.IsPlayerBoss(source)
        return Sky.FW.GetJobData(source, "isboss") == true
    end

    function Sky.FW.GetStatus(source, name)
        local xPlayer = exports.qbx_core:GetPlayer(source)
        if not xPlayer then return nil end
        return xPlayer.PlayerData.metadata[name]
    end

    function Sky.FW.SetStatus(source, name, value)
        local xPlayer = exports.qbx_core:GetPlayer(source)
        if not xPlayer then return end

        xPlayer.Functions.SetMetaData(name, value)
        xPlayer.Functions.UpdatePlayerData(false)
    end

    function Sky.FW.ChangePlayerName(source, firstname, lastname)
        local xPlayer = exports.qbx_core:GetPlayer(source)
        if not xPlayer then return end
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

    function Sky.FW.IsDead(source)
        local xPlayer = exports.qbx_core:GetPlayer(source)
        if not xPlayer then return false end
        return xPlayer.PlayerData.metadata.isdead == true
    end

    function Sky.FW.GetPlaytime(source)
        local src = tonumber(source)
        if not src then
            Sky.Debug("warn", "GetPlaytime: Invalid 'source' provided. Must be a number.")
            return 0
        end

        local Player = exports.qbx_core:GetPlayer(src)
        if not Player or not Player.PlayerData or not Player.PlayerData.metadata then
            return 0
        end

        local playtimeMinutes = Player.PlayerData.metadata["playtime"]
        if type(playtimeMinutes) ~= "number" then
            return 0
        end

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
