if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/server/modules/Database.lua") end
-- =====================================================
--  sky_base · source/server/modules/Database.lua
--  Server-Side Database Query Helpers (Sky.DB)
-- =====================================================

Sky = Sky or {}
Sky.DB = {}

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

--- Execute a raw SQL query synchronously
---@param query string
---@param params? table
---@return any
function Sky.Query(query, params)
    if MySQL and MySQL.query and MySQL.query.await then
        return MySQL.query.await(query, params or {})
    end
    return {}
end
Sky.DB.Query = Sky.Query

--- Get a single column value from a table where whereCol = whereVal
---@param tableName string
---@param whereCol string
---@param whereVal any
---@param targetCol string
---@return any
function Sky.DB.GetValue(tableName, whereCol, whereVal, targetCol)
    local query = string.format("SELECT `%s` FROM `%s` WHERE `%s` = @whereVal LIMIT 1", targetCol, tableName, whereCol)
    local row = MySQL.single.await(query, { ["@whereVal"] = whereVal })
    if row then
        local val = row[targetCol]
        if type(val) == "string" and (val:sub(1, 1) == "{" or val:sub(1, 1) == "[") then
            local ok, decoded = pcall(json.decode, val)
            if ok and type(decoded) == "table" then
                return decoded
            end
        end
        return val
    end
    return nil
end

--- Set a single column value in a table where whereCol = whereVal
---@param tableName string
---@param targetCol string
---@param targetVal any
---@param whereCol string
---@param whereVal any
---@return boolean
function Sky.DB.SetValue(tableName, targetCol, targetVal, whereCol, whereVal)
    local val = targetVal
    if type(val) == "table" then
        val = json.encode(val)
    end
    local query = string.format("UPDATE `%s` SET `%s` = @targetVal WHERE `%s` = @whereVal", tableName, targetCol, whereCol)
    MySQL.query.await(query, {
        ["@targetVal"] = val,
        ["@whereVal"] = whereVal
    })
    return true
end

--- Get a single row from a table where whereCol = whereVal
---@param tableName string
---@param whereCol string
---@param whereVal any
---@return table|nil
function Sky.DB.GetSingleRow(tableName, whereCol, whereVal)
    local query = string.format("SELECT * FROM `%s` WHERE `%s` = @whereVal LIMIT 1", tableName, whereCol)
    return MySQL.single.await(query, { ["@whereVal"] = whereVal })
end

--- Insert a row into a table
---@param tableName string
---@param data table
---@return number|boolean
function Sky.DB.AddRow(tableName, data)
    if type(data) ~= "table" then return false end

    local cols = {}
    local placeholders = {}
    local params = {}

    for k, v in pairs(data) do
        cols[#cols + 1] = string.format("`%s`", k)
        placeholders[#placeholders + 1] = string.format("@%s", k)
        local val = v
        if type(val) == "table" then
            val = json.encode(val)
        end
        params["@" .. k] = val
    end

    local query = string.format("INSERT INTO `%s` (%s) VALUES (%s)", tableName, table.concat(cols, ", "), table.concat(placeholders, ", "))
    return MySQL.insert.await(query, params)
end
