if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/shared/modules/Math.lua") end
-- =====================================================
--  sky_base · source/shared/modules/Math.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Math = {}

local NumberChars = {}
for i = 48, 57 do
    table.insert(NumberChars, string.char(i))
end

local LetterChars = {}
for i = 65, 90 do
    table.insert(LetterChars, string.char(i))
end

--- Generates a random sequence of numeric digits of specified length.
---@param len number
---@return string
function Sky.Math.GetRandomNumbers(len)
    Wait(0)
    if len > 0 then
        local char = NumberChars[math.random(1, #NumberChars)]
        return Sky.Math.GetRandomNumbers(len - 1) .. char
    end
    return ""
end

--- Generates a random sequence of uppercase letters of specified length.
---@param len number
---@return string
function Sky.Math.GetRandomLetters(len)
    Wait(0)
    if len > 0 then
        local char = LetterChars[math.random(1, #LetterChars)]
        return Sky.Math.GetRandomLetters(len - 1) .. char
    end
    return ""
end

--- Rounds a number to specified decimal places (or integer if omitted).
---@param value number
---@param numDecimalPlaces? number
---@return number
function Sky.Math.Round(value, numDecimalPlaces)
    if numDecimalPlaces then
        local mult = 10 ^ numDecimalPlaces
        return math.floor(value * mult + 0.5) / mult
    else
        return math.floor(value + 0.5)
    end
end

--- Formats numbers with digit grouping separators (e.g. 1,000,000).
---@param value any
---@return string
function Sky.Math.GroupDigits(value)
    local left, num, right = string.match(tostring(value), "^([^%d]*%d)(%d*)(.-)$")
    if not left then return tostring(value) end
    local groupSymbol = (TranslateCap and TranslateCap("locale_digit_grouping_symbol")) or ","
    local formattedNum = num:reverse():gsub("(%d%d%d)", "%1" .. groupSymbol):reverse()
    return left .. formattedNum .. right
end

--- Trims whitespace from both ends of a string.
---@param str? string
---@return string|nil
function Sky.Math.Trim(str)
    if not str then return nil end
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end
