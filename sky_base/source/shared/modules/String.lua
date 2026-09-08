if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/shared/modules/String.lua") end
-- =====================================================
--  sky_base · source/shared/modules/String.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.String = {}

--- Splits a string by a delimiter separator.
---@param str string
---@param sep string
---@return string[]
function Sky.String.Split(str, sep)
    local result = {}
    local startIndex = 1
    local matchStart, matchEnd = string.find(str, sep, startIndex)

    while matchStart do
        table.insert(result, string.sub(str, startIndex, matchStart - 1))
        startIndex = matchEnd + 1
        matchStart, matchEnd = string.find(str, sep, startIndex)
    end

    table.insert(result, string.sub(str, startIndex))
    return result
end

--- Converts a string into a table of single characters.
---@param str string
---@return string[]
function Sky.String.ToTable(str)
    local result = {}
    for i = 1, #str do
        result[i] = str:sub(i, i)
    end
    return result
end

--- Sanitizes a string for SQL queries.
---@param str string
---@return string
function Sky.String.SanitizeForSQL(str)
    local sanitized = str:gsub("[';\\`\"%c]", ""):match("^%s*(.-)%s*$")
    if sanitized == "" then
        return "Unknown"
    end
    return sanitized
end
