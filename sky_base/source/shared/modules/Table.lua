if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/shared/modules/Table.lua") end
-- =====================================================
--  sky_base · source/shared/modules/Table.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Table = {}

--- Searches a list of tables for an entry matching a key-value pair.
---@param list table[]
---@param key string
---@param value any
---@return table|nil, number|nil
function Sky.Table.SearchTableList(list, key, value)
    for idx, item in ipairs(list) do
        if item[key] == value then
            return item, idx
        end
    end
    return nil, nil
end

--- Returns a randomized copy of a array table.
---@param list any[]
---@return any[]
function Sky.Table.Mix(list)
    local result = {}
    for i = 1, #list do
        result[i] = list[i]
    end

    for i = #result, 2, -1 do
        math.randomseed(os.time() + math.random(1, 1000000))
        local randIdx = math.random(i)
        result[i], result[randIdx] = result[randIdx], result[i]
    end

    return result
end

--- Filters table elements based on a predicate function.
---@param tbl table
---@param predicate function(value, key): boolean
---@return table
function Sky.Table.Filter(tbl, predicate)
    if not tbl or not predicate then return nil end
    local result = {}
    for k, v in pairs(tbl) do
        if predicate(v, k) then
            table.insert(result, v)
        end
    end
    return result
end

--- Maps table elements using a transformer function.
---@param tbl table
---@param fn function(value, key): any
---@return table
function Sky.Table.Map(tbl, fn)
    local result = {}
    for k, v in pairs(tbl) do
        table.insert(result, fn(v, k))
    end
    return result
end

--- Finds the first element in a table matching a predicate.
---@param tbl table
---@param predicate function(value, key): boolean
---@return any, any
function Sky.Table.Find(tbl, predicate)
    for k, v in pairs(tbl) do
        if predicate(v, k) then
            return v, k
        end
    end
    return nil, nil
end

--- Returns the total number of key-value pairs in a table.
---@param tbl table
---@return number
function Sky.Table.Size(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

--- Checks if a list contains a specific value.
---@param list any[]
---@param value any
---@return boolean
function Sky.Table.Includes(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true
        end
    end
    return false
end

--- Removes all occurrences of a value from an array list.
---@param list any[]
---@param value any
function Sky.Table.Remove(list, value)
    for i = #list, 1, -1 do
        if list[i] == value then
            table.remove(list, i)
        end
    end
end
