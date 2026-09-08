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

CreateThread(function()
    if Sky and Sky.Config then
        if Sky.Config.framework == "qb" or Sky.Config.framework == "qbox" then
            local success, obj = pcall(function() return exports['qb-core']:GetCoreObject() end)
            if success and obj then QBCore = obj end
        elseif Sky.Config.framework == "esx" then
            local success, obj = pcall(function() return exports['es_extended']:getSharedObject() end)
            if success and obj then ESX = obj end
        end
    else
        if GetResourceState("qb-core") == "started" then
            QBCore = exports['qb-core']:GetCoreObject()
        elseif GetResourceState("es_extended") == "started" then
            ESX = exports['es_extended']:getSharedObject()
        end
    end
end)

--- Get framework player object by source
---@param source number|string
---@return table|nil
function Functions.GetPlayer(source)
    local src = tonumber(source)
    if not src or src <= 0 then return nil end

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
    if Sky and Sky.FW and Sky.FW.GetIdentifier then
        local id = Sky.FW.GetIdentifier(source)
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
    if Sky and Sky.FW and Sky.FW.GetName then
        local name = Sky.FW.GetName(source)
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
    if Sky and Sky.FW and Sky.FW.GetJob then
        return Sky.FW.GetJob(source) or ""
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
    if Sky and Sky.FW and Sky.FW.GetJobData then
        local grade = Sky.FW.GetJobData(source, "grade")
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

--- Check if player is a mechanic or belongs to configured mechanic jobs
---@param source number|string
---@return boolean
function Functions.IsMechanic(source)
    local jobName = Functions.GetJob(source)
    if jobName == "" then return false end

    for _, j in ipairs(Config.Jobs or {}) do
        if j.name == jobName then
            return true
        end
    end
    return jobName == "mechanic"
end

--- Check if player is currently on duty
---@param source number|string
---@return boolean
function Functions.IsOnDuty(source)
    local src = tonumber(source)
    if not src then return true end

    if Sky_Jobs and Sky_Jobs.PlayerCache and Sky_Jobs.PlayerCache.IsOnDuty then
        local duty = Sky_Jobs.PlayerCache.IsOnDuty(src)
        if duty ~= nil then return duty == true end
    end

    if Sky and Sky.FW and Sky.FW.GetJobData then
        local duty = Sky.FW.GetJobData(src, "duty")
        if duty ~= nil then return duty == true end
    end

    local player = Functions.GetPlayer(src)
    if not player then return true end

    if player.PlayerData and player.PlayerData.job then
        return player.PlayerData.job.onduty == true
    end

    return true
end

--- Get account money (cash, bank, or crypto)
---@param source number|string
---@param account? string
---@return number
function Functions.GetMoney(source, account)
    account = account or "cash"
    if Sky and Sky.FW and Sky.FW.GetAccountMoney then
        return Sky.FW.GetAccountMoney(source, account) or 0
    end

    local player = Functions.GetPlayer(source)
    if not player then return 0 end

    if player.PlayerData and player.PlayerData.money then
        local accKey = account == "money" and "cash" or account
        return player.PlayerData.money[accKey] or 0
    elseif player.getAccount then
        local accKey = account == "cash" and "money" or account
        local acc = player.getAccount(accKey)
        return acc and acc.money or 0
    end
    return 0
end

--- Add account money
---@param source number|string
---@param account string
---@param amount number
function Functions.AddMoney(source, account, amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return end

    account = account or "cash"
    if Sky and Sky.FW and Sky.FW.AddAccountMoney then
        Sky.FW.AddAccountMoney(source, account, amount)
        return
    end

    local player = Functions.GetPlayer(source)
    if not player then return end

    if player.Functions and player.Functions.AddMoney then
        local accKey = account == "money" and "cash" or account
        player.Functions.AddMoney(accKey, amount)
    elseif player.addAccountMoney then
        local accKey = account == "cash" and "money" or account
        player.addAccountMoney(accKey, amount)
    end
end

function Functions.RemoveMoney(source, account, amount)
    local src = tonumber(source)
    if not src then return false end
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return true end

    account = account or "bank"
    local accKey = (account == "money" and "cash") or account

    -- 1. Try sky_base FW wrapper if available.
    -- Count success only when the wrapper returns boolean true or a NON-NEGATIVE
    -- number: some wrappers return the new balance (>= 0) rather than a boolean.
    -- A negative number is treated as a failure/error code, and false/nil or a
    -- truthy failure object are also "not removed", so we fall through to the
    -- other payment paths instead of granting a free charge.
    if Sky and Sky.FW and Sky.FW.RemoveAccountMoney then
        local ok = Sky.FW.RemoveAccountMoney(src, account, amount)
        if ok == true or (type(ok) == "number" and ok >= 0) then return true end
    end

    -- 2. Try tgg-banking exports if running
    if GetResourceState("tgg-banking") == "started" then
        local ok, res = pcall(function()
            local tgg = exports["tgg-banking"]
            if tgg.RemoveMoney then
                return tgg:RemoveMoney(src, amount, "Parts Purchase")
            elseif tgg.removeMoney then
                return tgg:removeMoney(src, amount, "Parts Purchase")
            elseif tgg.RemoveAccountMoney then
                return tgg:RemoveAccountMoney(src, amount)
            end
        end)
        if ok and res == true then return true end
    end

    -- 3. Try qbx_core
    if GetResourceState("qbx_core") == "started" then
        local ok, res = pcall(function()
            return exports.qbx_core:RemoveMoney(src, accKey, amount, "Parts Purchase")
        end)
        if ok and res == true then return true end
    end

    local player = Functions.GetPlayer(src)
    if player then
        -- QBCore
        if player.Functions and player.Functions.RemoveMoney then
            local res = player.Functions.RemoveMoney(accKey, amount, "Parts Purchase")
            if res == true then return true end

            -- Fallback to cash if bank deduction returned false
            if accKey == "bank" then
                local cashRes = player.Functions.RemoveMoney("cash", amount, "Parts Purchase")
                if cashRes == true then return true end
            end
            return false
        -- ESX
        elseif player.removeAccountMoney then
            local esxAcc = accKey == "cash" and "money" or accKey
            if player.getAccount then
                local acc = player.getAccount(esxAcc)
                if not acc or (acc.money or 0) < amount then return false end
            end
            player.removeAccountMoney(esxAcc, amount)
            return true
        end
    end

    return false
end

--- Get item count in player inventory
---@param source number|string
---@param item string
---@return number
function Functions.GetItemCount(source, item)
    local src = tonumber(source)
    if not src then return 0 end

    if GetResourceState("ox_inventory") == "started" then
        local count = exports.ox_inventory:GetItem(src, item, nil, true)
        return tonumber(count) or 0
    end

    local player = Functions.GetPlayer(src)
    if not player then return 0 end

    if player.Functions and player.Functions.GetItemByName then
        local it = player.Functions.GetItemByName(item)
        return it and (it.amount or it.count) or 0
    elseif player.getInventoryItem then
        local it = player.getInventoryItem(item)
        return it and (it.count or it.amount) or 0
    end

    return 0
end

--- Check if player has item
---@param source number|string
---@param item string
---@param count? number
---@return boolean
function Functions.HasItem(source, item, count)
    count = count or 1
    return Functions.GetItemCount(source, item) >= count
end

--- Add item to player inventory
---@param source number|string
---@param item string
---@param count? number
---@param metadata? table
---@return boolean
function Functions.AddItem(source, item, count, metadata)
    local src = tonumber(source)
    if not src then return false end
    count = math.max(1, math.floor(tonumber(count) or 1))

    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:AddItem(src, item, count, metadata) == true
    end

    local player = Functions.GetPlayer(src)
    if not player then return false end

    if player.Functions and player.Functions.AddItem then
        return player.Functions.AddItem(item, count, nil, metadata) == true
    elseif player.addInventoryItem then
        player.addInventoryItem(item, count)
        return true
    end

    return false
end

--- Remove item from player inventory
---@param source number|string
---@param item string
---@param count? number
---@param metadata? table
---@return boolean
function Functions.RemoveItem(source, item, count, metadata)
    local src = tonumber(source)
    if not src then return false end
    count = math.max(1, math.floor(tonumber(count) or 1))

    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:RemoveItem(src, item, count, metadata) == true
    end

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
    local src = tonumber(source)
    if not src then return false end
    count = count or 1

    if GetResourceState("ox_inventory") == "started" then
        return exports.ox_inventory:CanCarryItem(src, item, count) == true
    end

    return true
end

--- Register usable item across frameworks
---@param itemName string
---@param cb function
function Functions.RegisterUsableItem(itemName, cb)
    if not itemName or itemName == "" then return end

    if GetResourceState("ox_inventory") == "started" then
        -- ox_inventory uses standard exports or item defs, fallback to ESX/QBCore
    end

    if QBCore and QBCore.Functions and QBCore.Functions.CreateUseableItem then
        QBCore.Functions.CreateUseableItem(itemName, function(source, item)
            cb(source, item)
        end)
    elseif ESX and ESX.RegisterUsableItem then
        ESX.RegisterUsableItem(itemName, function(source)
            cb(source, { name = itemName })
        end)
    end
end

--- Show notification to player
---@param source number|string
---@param title string
---@param message string
---@param msgType? string
function Functions.ShowNotification(source, title, message, msgType)
    local src = tonumber(source)
    if not src or src <= 0 then return end

    TriggerClientEvent("sky_base:showNotification", src, {
        title = title or "",
        msg = message or "",
        type = msgType or "info"
    })
end

--- Check if player has permission for command / admin action
---@param source number|string
---@param commandName string
---@return boolean
function Functions.HasPermission(source, commandName)
    local src = tonumber(source)
    if not src or src == 0 then return true end -- console has all permissions

    local acePerm = string.format("sky_mechanicjob.%s", commandName or "")
    if IsPlayerAceAllowed(tostring(src), acePerm)
       or (commandName and IsPlayerAceAllowed(tostring(src), "command." .. commandName))
       or IsPlayerAceAllowed(tostring(src), "command") then
        return true
    end

    if Sky and Sky.FW and Sky.FW.HasCommandPermission then
        if Sky.FW.HasCommandPermission(src, acePerm) or (commandName and Sky.FW.HasCommandPermission(src, commandName)) then
            return true
        end
    end

    local player = Functions.GetPlayer(src)
    if player then
        if QBCore and QBCore.Functions and QBCore.Functions.HasPermission then
            if QBCore.Functions.HasPermission(src, "god") or QBCore.Functions.HasPermission(src, "admin") then
                return true
            end
        end
        if player.PlayerData and player.PlayerData.group then
            local g = tostring(player.PlayerData.group):lower()
            if g == "admin" or g == "god" or g == "superadmin" then return true end
        end
        if player.getGroup then
            local g = tostring(player.getGroup()):lower()
            if g == "admin" or g == "god" or g == "superadmin" or g == "_dev" then return true end
        end
    end

    if GetResourceState("qbx_core") == "started" then
        local ok, has = pcall(function()
            return exports.qbx_core:HasPermission(src, "admin") or exports.qbx_core:HasPermission(src, "god")
        end)
        if ok and has then return true end
    end

    local permsConfig = Config and Config.CommandPermissions and commandName and Config.CommandPermissions[commandName]
    if type(permsConfig) == "table" then
        for _, group in ipairs(permsConfig) do
            if IsPlayerAceAllowed(tostring(src), string.format("group.%s", group)) then
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
