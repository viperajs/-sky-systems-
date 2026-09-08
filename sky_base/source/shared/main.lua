if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/shared/main.lua") end
-- =====================================================
--  sky_base · source/shared/main.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}

--- Validates and logs a value if debug is active.
---@param val any
---@param label? string
---@return any
function Sky.V(val, label)
    if Config.debug then
        local prefix = (label or "")
        if val == nil then
            Sky.Debug("error", prefix .. ": nil")
        elseif type(val) == "table" then
            Sky.Debug("debug", prefix .. ": " .. json.encode(val))
        else
            Sky.Debug("debug", prefix .. ": " .. tostring(val))
        end
    end
    return val
end

--- Formatted debug logging helper.
---@param level string
---@param formatStr string
---@param ... any
function Sky.Debug(level, formatStr, ...)
    local argCount = select("#", ...)
    local unpackFn = table.unpack or unpack
    local overrideCfg = nil

    if level == "debug" and argCount > 0 then
        local lastArg = select(argCount, ...)
        if type(lastArg) == "table" and (lastArg.always ~= nil or lastArg.force ~= nil) then
            overrideCfg = lastArg
            argCount = argCount - 1
        end
    end

    local args = {}
    for i = 1, argCount do
        args[i] = select(i, ...)
    end

    local formattedMsg
    local ok, result = pcall(string.format, tostring(formatStr), unpackFn(args, 1, argCount))
    formattedMsg = ok and result or tostring(formatStr)

    if SkyDiagnostics then SkyDiagnostics.Message(level, formattedMsg); return end

    if level == "info" then
        print("^0[^2INFO^0] ^2" .. formattedMsg .. "^0")
    elseif level == "error" then
        print("^0[^1ERROR^0] ^1" .. formattedMsg .. "^0")
    elseif level == "warn" then
        print("^0[^3WARNING^0] ^3" .. formattedMsg .. "^0")
    elseif level == "debug" then
        local isDebug = Config.debug or (overrideCfg and (overrideCfg.always or overrideCfg.force))
        if isDebug then
            print("^0[^5DEBUG^0] ^5" .. formattedMsg .. "^0")
        end
    end
end

--- Checks if debug mode is active.
---@return boolean
function Sky.IsDebugActive()
    return Config.debug
end

--- Safe pairs iterator wrapper.
---@param tbl any
---@param label? string
---@return function, table, any
function Sky.Pairs(tbl, label)
    Sky.V(tbl, label)
    if type(tbl) == "table" then
        return pairs(tbl)
    else
        Sky.Debug("error", "Expected a table for %s, got %s", label, type(tbl))
        return pairs({})
    end
end

--- Safe ipairs iterator wrapper.
---@param tbl any
---@param label? string
---@return function, table, number
function Sky.Ipairs(tbl, label)
    Sky.V(tbl, label)
    if type(tbl) == "table" then
        return ipairs(tbl)
    else
        Sky.Debug("error", "Expected a table for %s, got %s", label, type(tbl))
        return ipairs({})
    end
end

--- Safely traverse nested table keys.
---@param tbl table
---@param ... any
---@return any
function Sky.GetVal(tbl, ...)
    local keys = { ... }
    local lastKey = tostring(keys[#keys])
    local pathStr = ""

    for i, key in ipairs(keys) do
        if i > 2 then
            pathStr = pathStr .. "."
        end
        if i > 1 then
            pathStr = pathStr .. tostring(keys[i - 1])
        end

        if type(tbl) ~= "table" then
            Sky.Debug("error", "Expected a table for '%s' to index '%s' but got %s", pathStr, lastKey, type(tbl))
            return nil
        end

        tbl = tbl[key]
    end

    return tbl
end

