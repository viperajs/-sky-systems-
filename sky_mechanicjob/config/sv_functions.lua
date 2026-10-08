if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/config/sv_functions.lua") end
-- =====================================================
--  sky_mechanicjob · config/sv_functions.lua
--  Server-Side Framework & Utility Functions
-- =====================================================

Functions = Functions or {}

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

local QBCore = nil
local ESX = nil

local function isStarted(resourceName)
    return GetResourceState(resourceName) == "started"
end

--- Active framework: "qbox", "qb", "esx" or nil.
---@return string|nil
function Functions.GetFramework()
    if isStarted("qbx_core") then return "qbox" end
    if isStarted("qb-core") then return "qb" end
    if isStarted("es_extended") then return "esx" end
    local configured = Sky and Sky.Config and Sky.Config.framework
    return type(configured) == "string" and configured or nil
end

-- QBCore / ESX objects for the fallbacks below; Qbox is always reached through its exports.
local function loadCoreObjects()
    local framework = Functions.GetFramework()
    if framework == "qb" and not QBCore then
        local ok, obj = pcall(function() return exports["qb-core"]:GetCoreObject() end)
        if ok and type(obj) == "table" then QBCore = obj end
    elseif framework == "esx" and not ESX then
        local ok, obj = pcall(function() return exports["es_extended"]:getSharedObject() end)
        if ok and type(obj) == "table" then ESX = obj end
    end
end

CreateThread(loadCoreObjects)

local function getFrameworkFunction(method)
    if Sky and Sky.FW then
        local fn = Sky.FW[method]
        if fn then return fn end
    end
    return nil
end

--- Get framework player object by source
---@param source number|string
---@return table|nil
function Functions.GetPlayer(source)
    local src = tonumber(source)
    if not src or src <= 0 then return nil end

    if Functions.GetFramework() == "qbox" then
        local ok, player = pcall(function() return exports.qbx_core:GetPlayer(src) end)
        return ok and type(player) == "table" and player or nil
    end

    loadCoreObjects()
    if QBCore then
        return QBCore.Functions.GetPlayer(src)
    elseif ESX then
        return ESX.GetPlayerFromId(src)
    end
    return nil
end

--- Resolve the numeric source of an ONLINE player from their unique identifier.
--- Returns nil if the identifier is empty or the player is offline.
---@param identifier string
---@return number|nil
function Functions.GetSourceByIdentifier(identifier)
    if not identifier or identifier == "" then return nil end
    identifier = tostring(identifier)
    for _, srcStr in ipairs(GetPlayers()) do
        local src = tonumber(srcStr)
        if src and Functions.GetIdentifier(src) == identifier then
            return src
        end
    end
    return nil
end

--- Get player unique identifier (citizenid / license / identifier)
---@param source number|string
---@return string
function Functions.GetIdentifier(source)
    local getIdentifier = getFrameworkFunction("GetIdentifier")
    if getIdentifier then
        local id = getIdentifier(source)
        if id and id ~= "" then return tostring(id) end
    end

    local src = tonumber(source)
    if not src then return tostring(source or "") end

    local player = Functions.GetPlayer(src)
    if not player then
        return GetPlayerIdentifierByType(tostring(src), 'license') or tostring(src)
    end

    if player.PlayerData and player.PlayerData.citizenid then
        return tostring(player.PlayerData.citizenid)
    elseif player.identifier then
        return tostring(player.identifier)
    end

    return tostring(src)
end

--- Get character full name
---@param source number|string
---@return string
function Functions.GetName(source)
    local srcNum = tonumber(source)
    local getName = getFrameworkFunction("GetName")
    if getName then
        local name = getName(source)
        if name and name ~= "" then return name end
    end

    local player = Functions.GetPlayer(source)
    if player then
        if player.PlayerData and player.PlayerData.charinfo then
            local charinfo = player.PlayerData.charinfo
            local fname = charinfo.firstname or ""
            local lname = charinfo.lastname or ""
            local full = (fname .. " " .. lname):gsub("^%s+", ""):gsub("%s+$", "")
            if full ~= "" then return full end
        elseif player.getName then
            local pName = player.getName()
            if pName and pName ~= "" then return pName end
        elseif player.get and (player.get("firstName") or player.get("lastName")) then
            local fname = player.get("firstName") or ""
            local lname = player.get("lastName") or ""
            local full = (fname .. " " .. lname):gsub("^%s+", ""):gsub("%s+$", "")
            if full ~= "" then return full end
        end
    end

    if srcNum then
        local pName = GetPlayerName(srcNum)
        if pName and pName ~= "" then return pName end
    end

    return "Customer"
end

--- Get player job name
---@param source number|string
---@return string
function Functions.GetJob(source)
    local getJob = getFrameworkFunction("GetJob")
    if getJob then
        local job = getJob(source)
        return type(job) == "string" and job or ""
    end

    local player = Functions.GetPlayer(source)
    if not player then return "" end

    if player.PlayerData and player.PlayerData.job then
        return tostring(player.PlayerData.job.name or "")
    elseif player.job and player.job.name then
        return tostring(player.job.name or "")
    end
    return ""
end

--- Get player job grade level
---@param source number|string
---@return number
function Functions.GetJobGrade(source)
    local getJobData = getFrameworkFunction("GetJobData")
    if getJobData then
        local grade = getJobData(source, "grade")
        if grade ~= nil then return tonumber(grade) or 0 end
    end

    local player = Functions.GetPlayer(source)
    if not player then return 0 end

    if player.PlayerData and player.PlayerData.job and player.PlayerData.job.grade then
        return tonumber(player.PlayerData.job.grade.level) or 0
    elseif player.job and player.job.grade then
        return tonumber(player.job.grade) or 0
    end
    return 0
end

--- Job names of the workshops created in the shared /jobconfig UI (sky_jobs_base).
--- The server keeps the Config.Jobs from config.lua, so these are checked in addition.
---@return string[]
function Functions.GetConfiguratorJobNames()
    if not (Config and Config.UseJobConfigurator) or not isStarted("sky_jobs_base") then
        return {}
    end

    local ok, names = pcall(function()
        return exports.sky_jobs_base:GetJobConfiguratorJobNames()
    end)
    return (ok and type(names) == "table") and names or {}
end

--- Every mechanic job name: Config.Jobs plus the /jobconfig workshops.
---@return string[]
function Functions.GetMechanicJobNames()
    local names, seen = {}, {}
    local function add(name)
        if type(name) == "string" and name ~= "" and not seen[name] then
            seen[name] = true
            names[#names + 1] = name
        end
    end

    for _, job in ipairs(Config and Config.Jobs or {}) do
        add(type(job) == "table" and job.name or job)
    end
    if #names == 0 then
        add("mechanic")
    end
    for _, name in ipairs(Functions.GetConfiguratorJobNames()) do
        add(name)
    end
    return names
end

--- Whether a job name is one of the mechanic jobs
---@param jobName string
---@return boolean
function Functions.IsMechanicJobName(jobName)
    if type(jobName) ~= "string" or jobName == "" then return false end
    for _, name in ipairs(Functions.GetMechanicJobNames()) do
        if name == jobName then
            return true
        end
    end
    return false
end

--- Check if player is a mechanic or belongs to configured mechanic jobs
---@param source number|string
---@return boolean
function Functions.IsMechanic(source)
    return Functions.IsMechanicJobName(Functions.GetJob(source))
end

--- Check if player is currently on duty. Unknown duty counts as off duty; sky_jobs_base
--- reports true for everyone when its duty system is disabled.
---@param source number|string
---@return boolean
function Functions.IsOnDuty(source)
    local src = tonumber(source)
    if not src or src <= 0 then return false end

    if isStarted("sky_jobs_base") then
        local ok, duty = pcall(function()
            return exports.sky_jobs_base:isOnDuty(src)
        end)
        if ok and type(duty) == "boolean" then return duty end
    end

    local getJobData = getFrameworkFunction("GetJobData")
    if getJobData then
        local duty = getJobData(src, "duty")
        if type(duty) == "boolean" then return duty end
    end

    local player = Functions.GetPlayer(src)
    if player and player.PlayerData and player.PlayerData.job and type(player.PlayerData.job.onduty) == "boolean" then
        return player.PlayerData.job.onduty
    end

    return false
end

--- Mechanic job and on duty
---@param source number|string
---@return boolean
function Functions.IsMechanicOnDuty(source)
    return Functions.IsMechanic(source) and Functions.IsOnDuty(source)
end

-- -----------------------------------------------------
--  Money
-- -----------------------------------------------------

-- "card" is the bank account; "money" is cash. sky_base maps the names per framework.
local function normalizeAccount(account)
    account = type(account) == "string" and account:lower() or "cash"
    if account == "card" or account == "own_card" then return "bank" end
    if account == "money" then return "cash" end
    return account
end
Functions.NormalizeAccount = normalizeAccount

local function validAmount(amount)
    amount = tonumber(amount)
    if not amount or amount ~= amount or amount == math.huge or amount == -math.huge then return nil end
    return math.floor(amount)
end

--- Get account money (cash, bank, or crypto)
---@param source number|string
---@param account? string
---@return number
function Functions.GetMoney(source, account)
    account = normalizeAccount(account)
    local getAccountMoney = getFrameworkFunction("GetAccountMoney")
    if getAccountMoney then
        return tonumber(getAccountMoney(source, account)) or 0
    end

    local player = Functions.GetPlayer(source)
    if not player then return 0 end

    if player.PlayerData and player.PlayerData.money then
        return tonumber(player.PlayerData.money[account]) or 0
    elseif player.getAccount then
        local acc = player.getAccount(account == "cash" and "money" or account)
        return acc and tonumber(acc.money) or 0
    end
    return 0
end

--- Add account money. True only when the money was added (0 adds nothing and succeeds).
---@param source number|string
---@param account string
---@param amount number
---@return boolean
function Functions.AddMoney(source, account, amount)
    local src = tonumber(source)
    amount = validAmount(amount)
    if not src or src <= 0 or not amount or amount < 0 then return false end
    if amount == 0 then return true end

    account = normalizeAccount(account)
    local addAccountMoney = getFrameworkFunction("AddAccountMoney")
    if addAccountMoney then
        return addAccountMoney(src, account, amount) == true
    end

    if Functions.GetFramework() == "qbox" then
        local ok, res = pcall(function()
            return exports.qbx_core:AddMoney(src, account, amount, "sky_mechanicjob")
        end)
        return ok and res == true
    end

    local player = Functions.GetPlayer(src)
    if not player then return false end

    if player.Functions and player.Functions.AddMoney then
        return player.Functions.AddMoney(account, amount, "sky_mechanicjob") == true
    elseif player.addAccountMoney then
        player.addAccountMoney(account == "cash" and "money" or account, amount)
        return true
    end
    return false
end

--- Remove account money. True only when the money was removed (0 removes nothing and succeeds).
---@param source number|string
---@param account string
---@param amount number
---@return boolean
function Functions.RemoveMoney(source, account, amount)
    local src = tonumber(source)
    amount = validAmount(amount)
    if not src or src <= 0 or not amount or amount < 0 then return false end
    if amount == 0 then return true end

    account = normalizeAccount(account or "bank")

    -- sky_base checks the balance and only reports true when the framework removed it.
    local removeAccountMoney = getFrameworkFunction("RemoveAccountMoney")
    if removeAccountMoney then
        return removeAccountMoney(src, account, amount) == true
    end

    if Functions.GetMoney(src, account) < amount then
        return false
    end

    if Functions.GetFramework() == "qbox" then
        local ok, res = pcall(function()
            return exports.qbx_core:RemoveMoney(src, account, amount, "sky_mechanicjob")
        end)
        return ok and res == true
    end

    if account == "bank" and isStarted("tgg-banking") then
        local ok, res = pcall(function()
            local tgg = exports["tgg-banking"]
            if tgg.RemoveMoney then
                return tgg:RemoveMoney(src, amount, "sky_mechanicjob")
            elseif tgg.removeMoney then
                return tgg:removeMoney(src, amount, "sky_mechanicjob")
            elseif tgg.RemoveAccountMoney then
                return tgg:RemoveAccountMoney(src, amount)
            end
        end)
        if ok and res == true then return true end
    end

    local player = Functions.GetPlayer(src)
    if not player then return false end

    if player.Functions and player.Functions.RemoveMoney then
        return player.Functions.RemoveMoney(account, amount, "sky_mechanicjob") == true
    elseif player.removeAccountMoney then
        player.removeAccountMoney(account == "cash" and "money" or account, amount)
        return true
    end
    return false
end

-- -----------------------------------------------------
--  Society (sky_jobs_base finances)
-- -----------------------------------------------------

--- Add money to a job's society account
---@param job string
---@param amount number
---@param reason? string
---@return boolean
function Functions.AddSocietyMoney(job, amount, reason)
    amount = validAmount(amount)
    if type(job) ~= "string" or job == "" or not amount or amount <= 0 or not isStarted("sky_jobs_base") then return false end
    local ok, res = pcall(function()
        return exports.sky_jobs_base:AddSocietyMoney(job, amount, reason)
    end)
    return ok and res == true
end

--- Remove money from a job's society account (atomic in sky_jobs_base)
---@param job string
---@param amount number
---@param reason? string
---@return boolean
function Functions.RemoveSocietyMoney(job, amount, reason)
    amount = validAmount(amount)
    if type(job) ~= "string" or job == "" or not amount or amount <= 0 or not isStarted("sky_jobs_base") then return false end
    local ok, res = pcall(function()
        return exports.sky_jobs_base:RemoveSocietyMoney(job, amount, reason)
    end)
    return ok and res == true
end

--- Pay from the society of the player's own mechanic job. Requires the PURCHASE_SUPPLIES
--- job permission. Returns success and the charged job.
---@param source number|string
---@param amount number
---@param reason? string
---@return boolean, string|nil
function Functions.ChargeSociety(source, amount, reason)
    local src = tonumber(source)
    amount = validAmount(amount)
    if not src or src <= 0 or not amount or amount <= 0 or not isStarted("sky_jobs_base") then return false, nil end

    local job = Functions.GetJob(src)
    if not Functions.IsMechanicJobName(job) then return false, nil end

    local ok, allowed = pcall(function()
        return exports.sky_jobs_base:HasJobPermission(src, "PURCHASE_SUPPLIES")
    end)
    if not ok or allowed ~= true then return false, job end

    return Functions.RemoveSocietyMoney(job, amount, reason), job
end

-- -----------------------------------------------------
--  Items
-- -----------------------------------------------------

local function validItemCall(source, item)
    local src = tonumber(source)
    if not src or src <= 0 or type(item) ~= "string" or item == "" then return nil end
    return src
end

--- Get item count in player inventory
---@param source number|string
---@param item string
---@return number
function Functions.GetItemCount(source, item)
    local src = validItemCall(source, item)
    if not src then return 0 end

    if isStarted("ox_inventory") then
        local ok, count = pcall(function() return exports.ox_inventory:GetItemCount(src, item) end)
        if ok and tonumber(count) then return math.floor(tonumber(count)) end
        ok, count = pcall(function() return exports.ox_inventory:GetItem(src, item, nil, true) end)
        return ok and math.floor(tonumber(count) or 0) or 0
    end

    local player = Functions.GetPlayer(src)
    if not player then return 0 end

    if player.Functions and player.Functions.GetItemByName then
        local it = player.Functions.GetItemByName(item)
        return it and math.floor(tonumber(it.amount or it.count) or 0) or 0
    elseif player.getInventoryItem then
        local it = player.getInventoryItem(item)
        return it and math.floor(tonumber(it.count or it.amount) or 0) or 0
    end

    return 0
end

--- Check if player has item
---@param source number|string
---@param item string
---@param count? number
---@return boolean
function Functions.HasItem(source, item, count)
    count = math.max(1, math.floor(tonumber(count) or 1))
    return Functions.GetItemCount(source, item) >= count
end

--- Add item to player inventory. True only when every item was added.
---@param source number|string
---@param item string
---@param count? number
---@param metadata? table
---@return boolean
function Functions.AddItem(source, item, count, metadata)
    local src = validItemCall(source, item)
    count = validAmount(count or 1)
    if not src or not count or count < 1 then return false end

    if isStarted("ox_inventory") then
        local ok, success = pcall(function()
            return exports.ox_inventory:AddItem(src, item, count, metadata)
        end)
        return ok and success == true
    end

    local player = Functions.GetPlayer(src)
    if not player then return false end

    if player.Functions and player.Functions.AddItem then
        return player.Functions.AddItem(item, count, nil, metadata) == true
    elseif player.addInventoryItem then
        if player.canCarryItem and not player.canCarryItem(item, count) then return false end
        player.addInventoryItem(item, count)
        return true
    end

    return false
end

--- Remove item from player inventory. True only when the full count was removed.
---@param source number|string
---@param item string
---@param count? number
---@param metadata? table
---@return boolean
function Functions.RemoveItem(source, item, count, metadata)
    local src = validItemCall(source, item)
    count = validAmount(count or 1)
    if not src or not count or count < 1 then return false end

    if isStarted("ox_inventory") then
        local ok, success = pcall(function()
            return exports.ox_inventory:RemoveItem(src, item, count, metadata)
        end)
        return ok and success == true
    end

    if Functions.GetItemCount(src, item) < count then return false end

    local player = Functions.GetPlayer(src)
    if not player then return false end

    if player.Functions and player.Functions.RemoveItem then
        return player.Functions.RemoveItem(item, count) == true
    elseif player.removeInventoryItem then
        player.removeInventoryItem(item, count)
        return true
    end

    return false
end

--- Check if player can carry item
---@param source number|string
---@param item string
---@param count? number
---@return boolean
function Functions.CanCarryItem(source, item, count)
    local src = validItemCall(source, item)
    count = validAmount(count or 1)
    if not src or not count or count < 1 then return false end

    if isStarted("ox_inventory") then
        local ok, canCarry = pcall(function()
            return exports.ox_inventory:CanCarryItem(src, item, count)
        end)
        return ok and canCarry == true
    end

    if isStarted("qb-inventory") then
        local ok, canAdd = pcall(function()
            return exports["qb-inventory"]:CanAddItem(src, item, count)
        end)
        if ok and type(canAdd) == "boolean" then return canAdd end
    end

    local player = Functions.GetPlayer(src)
    if player and player.canCarryItem then
        return player.canCarryItem(item, count) == true
    end

    -- No inventory check available; AddItem still reports failure.
    return true
end

-- -----------------------------------------------------
--  Usable items
-- -----------------------------------------------------

local usableItems = {}

local function registerUsableItemNow(itemName, cb)
    if Functions.GetFramework() == "qbox" then
        local ok = pcall(function()
            exports.qbx_core:CreateUseableItem(itemName, function(source, item)
                cb(source, item)
            end)
        end)
        return ok
    end

    loadCoreObjects()
    if QBCore and QBCore.Functions and QBCore.Functions.CreateUseableItem then
        QBCore.Functions.CreateUseableItem(itemName, function(source, item)
            cb(source, item)
        end)
        return true
    elseif ESX and ESX.RegisterUsableItem then
        ESX.RegisterUsableItem(itemName, function(source)
            cb(source, { name = itemName })
        end)
        return true
    end
    return false
end

--- Register usable item across frameworks (ox_inventory uses the framework's usable items)
---@param itemName string
---@param cb function
---@return boolean
function Functions.RegisterUsableItem(itemName, cb)
    if type(itemName) ~= "string" or itemName == "" or cb == nil then return false end
    usableItems[itemName] = cb
    return registerUsableItemNow(itemName, cb)
end

-- A restarted framework forgets the registrations.
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= "qbx_core" and resourceName ~= "qb-core" and resourceName ~= "es_extended" then return end
    QBCore, ESX = nil, nil
    CreateThread(function()
        Wait(1000)
        for itemName, cb in pairs(usableItems) do
            registerUsableItemNow(itemName, cb)
        end
    end)
end)

-- -----------------------------------------------------
--  Vehicles
-- -----------------------------------------------------

local function normalizePlate(plate)
    if type(plate) ~= "string" and type(plate) ~= "number" then return "" end
    local trimmed = tostring(plate):gsub("^%s+", ""):gsub("%s+$", "")
    return trimmed:upper()
end
Functions.NormalizePlate = normalizePlate

local function getPlayerCoords(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return nil end
    return GetEntityCoords(ped)
end

--- Closest vehicle with this plate near the player
---@param source number|string
---@param plate string
---@param maxDistance? number
---@return number|nil
function Functions.GetNearbyVehicleByPlate(source, plate, maxDistance)
    local src = tonumber(source)
    local target = normalizePlate(plate)
    if not src or src <= 0 or target == "" then return nil end

    local origin = getPlayerCoords(src)
    if not origin then return nil end

    local maxDist = tonumber(maxDistance) or 10.0
    local best, bestDist = nil, maxDist
    for _, vehicle in ipairs(GetAllVehicles()) do
        if DoesEntityExist(vehicle) and normalizePlate(GetVehicleNumberPlateText(vehicle)) == target then
            local dist = #(GetEntityCoords(vehicle) - origin)
            if dist <= bestDist then
                best, bestDist = vehicle, dist
            end
        end
    end
    return best
end

--- Vehicle entity for a network id, if it exists and is near the player
---@param source number|string
---@param netId number
---@param maxDistance? number
---@return number|nil
function Functions.GetVehicleByNetId(source, netId, maxDistance)
    local src = tonumber(source)
    local id = tonumber(netId)
    if not src or src <= 0 or not id or id <= 0 then return nil end

    local vehicle = NetworkGetEntityFromNetworkId(math.floor(id))
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) or GetEntityType(vehicle) ~= 2 then return nil end

    local origin = getPlayerCoords(src)
    if not origin or #(GetEntityCoords(vehicle) - origin) > (tonumber(maxDistance) or 10.0) then return nil end
    return vehicle
end

-- -----------------------------------------------------
--  Notifications, permissions, logging
-- -----------------------------------------------------

--- Show notification to player
---@param source number|string
---@param title string
---@param message string
---@param msgType? string
function Functions.ShowNotification(source, title, message, msgType)
    local src = tonumber(source)
    if not src or src <= 0 then return end

    -- sky_base's client only handles sky_base:notification (title, message, type);
    -- the former sky_base:showNotification event had no handler.
    TriggerClientEvent("sky_base:notification", src, title or "", message or "", msgType or "info")
end

--- Check if player has permission for command / admin action: the server console, ACE
--- `sky_mechanicjob.<commandName>`, ACE `command`, or a group listed for the command in
--- Config.CommandPermissions. (`command.<name>` is not used: every player has it for
--- commands registered without restriction.)
---@param source number|string
---@param commandName string
---@return boolean
function Functions.HasPermission(source, commandName)
    local src = tonumber(source)
    if src == 0 then return true end
    if not src or src < 0 then return false end

    local srcStr = tostring(src)
    local name = type(commandName) == "string" and commandName or ""
    if (name ~= "" and IsPlayerAceAllowed(srcStr, ("sky_mechanicjob.%s"):format(name)))
        or IsPlayerAceAllowed(srcStr, "command") then
        return true
    end

    local groups = name ~= "" and Config and Config.CommandPermissions and Config.CommandPermissions[name]
    if type(groups) ~= "table" then return false end

    local esxGroup = nil
    if Functions.GetFramework() == "esx" then
        local player = Functions.GetPlayer(src)
        if player and player.getGroup then
            esxGroup = tostring(player.getGroup()):lower()
        end
    end

    for _, group in ipairs(groups) do
        if type(group) == "string" and group ~= "" then
            -- Qbox / QBCore grant their admin ACEs ("admin", "god") to group.<name>.
            if IsPlayerAceAllowed(srcStr, ("group.%s"):format(group)) or IsPlayerAceAllowed(srcStr, group) then
                return true
            end
            if esxGroup and esxGroup == group:lower() then
                return true
            end
        end
    end

    return false
end

--- Formatted debug logging
---@param level string
---@param formatStr string
---@param ... any
function Functions.Log(level, formatStr, ...)
    if Sky and Sky.Debug then
        Sky.Debug(level, formatStr, ...)
    else
        print(string.format("[%s] %s", string.upper(level), string.format(formatStr, ...)))
    end
end
