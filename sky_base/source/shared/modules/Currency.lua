if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/shared/modules/Currency.lua") end
-- =====================================================
--  sky_base · source/shared/modules/Currency.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Currency = Sky.Currency or {}

local function getConfig()
    local cfg = Sky.Config and Sky.Config.Currency
    if not cfg and Config then
        cfg = Config.Currency
    end
    return cfg or {}
end

local function getHelper(name, fallback)
    local cfg = getConfig()
    local helpers = cfg.helpers
    if type(helpers) == "table" and type(helpers[name]) == "function" then
        return helpers[name]
    end
    return fallback
end

local function deepCopyTable(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = deepCopyTable(v)
    end
    return copy
end

local function filterNonFunctions(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) ~= "function" then
            copy[k] = filterNonFunctions(v)
        end
    end
    return copy
end

local function getNuiFormatters(formatters)
    local result = {}
    for k, v in pairs(formatters or {}) do
        if type(v) == "table" then
            result[k] = filterNonFunctions(v.nui or v)
        end
    end
    return result
end

local function getFormatterConfig(name)
    local cfg = getConfig()
    local formatters = cfg.formatters or {}
    if type(name) == "table" then return name end
    local formatterName = name or cfg.defaultFormatter or "money"
    local fmt = formatters[formatterName]
    if not fmt then
        fmt = formatters.money or {
            type = "money",
            symbol = "$",
            symbolPosition = "before",
            spaceBetween = false,
            thousandsSeparator = ",",
            decimalSeparator = ".",
            precision = 0
        }
    end
    return fmt
end

local function getCurrencyConfig(name)
    local cfg = getConfig()
    local currencies = cfg.currencies or {}
    if type(name) == "table" then return name end
    local currencyName = name or cfg.defaultCurrency or "money"
    return currencies[currencyName] or currencies.money
end

local function roundNumber(value, numDecimalPlaces)
    local mult = 10 ^ numDecimalPlaces
    return math.floor(value * mult + 0.5) / mult
end

local function splitNumber(value, precision)
    local fmtStr = "%." .. tostring(precision) .. "f"
    local formatted = string.format(fmtStr, math.abs(value))
    local intPart, decPart = formatted:match("^(%d+)%.?(%d*)$")
    return intPart or "0", decPart or ""
end

local function groupDigits(value, sep)
    local str = tostring(value or "0")
    while true do
        local newStr, count = str:gsub("^(-?%d+)(%d%d%d)", "%1" .. sep .. "%2")
        str = newStr
        if count == 0 then break end
    end
    return str
end

local function toSeconds(amount, unit)
    local val = math.max(0, math.floor(tonumber(amount) or 0))
    if unit == "minutes" then
        return val * 60
    elseif unit == "hours" then
        return val * 3600
    end
    return val
end

local function formatClock(seconds, format)
    local val = math.max(0, math.floor(tonumber(seconds) or 0))
    local hours = math.floor(val / 3600)
    local mins = math.floor((val % 3600) / 60)
    local secs = val % 60

    if format == "mm:ss" then
        return string.format("%02d:%02d", math.floor(val / 60), secs)
    end
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

local function formatMoney(amount, config)
    local num = tonumber(amount) or 0
    local precision = tonumber(config.precision) or 0

    local roundFn = getHelper("round", roundNumber)
    local groupFn = getHelper("groupDigits", groupDigits)

    local rounded = roundFn(num, precision)
    local prefixSign = rounded < 0 and "-" or ""

    local intPart, decPart = splitNumber(rounded, precision)
    local thousandSep = config.thousandsSeparator or ","
    local decimalSep = config.decimalSeparator or "."

    local result = prefixSign .. groupFn(intPart, thousandSep)
    if precision > 0 then
        result = result .. decimalSep .. decPart
    end

    local symbol = config.symbol or ""
    if symbol == "" then return result end

    local space = config.spaceBetween == true and " " or ""
    if config.symbolPosition == "after" then
        return result .. space .. symbol
    end
    return symbol .. space .. result
end

local function formatTime(amount, config)
    local toSecFn = getHelper("toSeconds", toSeconds)
    local clockFn = getHelper("formatClock", formatClock)
    local secs = toSecFn(amount, config.input)
    return clockFn(secs, config.output)
end

local defaultHelpers = {
    round = roundNumber,
    groupDigits = groupDigits,
    toSeconds = toSeconds,
    formatClock = formatClock,
    formatMoney = formatMoney,
    formatTime = formatTime
}

local function getCustomHelpers()
    local helpers = deepCopyTable(defaultHelpers)
    local cfg = getConfig()
    if type(cfg.helpers) == "table" then
        for k, v in pairs(cfg.helpers) do
            if type(v) == "function" then
                helpers[k] = v
            end
        end
    end
    if type(helpers.formatMoney) ~= "function" then helpers.formatMoney = formatMoney end
    if type(helpers.formatTime) ~= "function" then helpers.formatTime = formatTime end
    return helpers
end

local function resolveCurrencyConfig(name)
    if type(name) ~= "table" then return nil end
    local copy = deepCopyTable(name)
    copy.formatterConfig = getFormatterConfig(name.formatter or name.formatterName)
    return copy
end

local function callCurrencyMethod(currencyData, method, target, amount)
    local resolved = resolveCurrencyConfig(currencyData)
    if not resolved or type(resolved[method]) ~= "function" then return nil end

    local success, result
    if method == "get" then
        success, result = pcall(resolved[method], target, getCustomHelpers(), resolved)
    else
        success, result = pcall(resolved[method], target, amount, getCustomHelpers(), resolved)
    end

    if success then return result end

    if Sky.Debug then
        Sky.Debug("warn", "[currency] %s failed: %s", tostring(method), tostring(result))
    end
    return nil
end

--- Returns copy of formatter configuration.
---@param name? string|table
---@return table
function Sky.Currency.GetFormatter(name)
    return deepCopyTable(getFormatterConfig(name))
end

--- Returns copy of currency configuration.
---@param name? string|table
---@return table|nil
function Sky.Currency.GetCurrency(name)
    local cfg = getCurrencyConfig(name)
    return cfg and deepCopyTable(cfg) or nil
end

--- Returns default currency key.
---@return string
function Sky.Currency.GetDefaultCurrency()
    return getConfig().defaultCurrency or "money"
end

--- Returns NUI currency configuration object.
---@return table
function Sky.Currency.GetNuiConfig()
    local cfg = getConfig()
    local currencies = {}
    for k, v in pairs(cfg.currencies or {}) do
        if type(v) == "table" then
            currencies[k] = {
                formatter = v.formatter or v.formatterName or cfg.defaultFormatter or "money"
            }
        end
    end
    return {
        defaultFormatter = cfg.defaultFormatter or "money",
        defaultCurrency = cfg.defaultCurrency or "money",
        formatters = getNuiFormatters(cfg.formatters or {}),
        currencies = currencies
    }
end

--- Formats a numeric amount based on formatter configuration or type.
---@param amount number
---@param formatter? string|table
---@return string
function Sky.Currency.Format(amount, formatter)
    local config = getFormatterConfig(formatter)
    if type(config.format) == "function" then
        local success, res = pcall(config.format, amount, getCustomHelpers(), config)
        if success and res ~= nil then
            return tostring(res)
        end
        if Sky.Debug then
            Sky.Debug("warn", "[currency] formatter failed: %s", tostring(res))
        end
    end

    local fmtType = config.type or "money"
    if fmtType == "time" then
        return formatTime(amount, config)
    end
    return formatMoney(amount, config)
end

--- Formats an amount using currency name's designated formatter.
---@param amount number
---@param currencyName? string|table
---@return string
function Sky.Currency.FormatCurrencyAmount(amount, currencyName)
    local currency = getCurrencyConfig(currencyName)
    local fmt = currency and (currency.formatter or currency.formatterName) or nil
    return Sky.Currency.Format(amount, fmt)
end

--- Gets player's currency balance.
---@param target any
---@param currencyName? string|table
---@return number
function Sky.Currency.GetBalance(target, currencyName)
    local currency = getCurrencyConfig(currencyName)
    local val = callCurrencyMethod(currency, "get", target)
    return tonumber(val) or 0
end

--- Checks if player has sufficient amount of currency.
---@param target any
---@param currencyName string|table
---@param amount number
---@return boolean
function Sky.Currency.Has(target, currencyName, amount)
    local reqAmount = math.max(0, tonumber(amount) or 0)
    local currency = getCurrencyConfig(currencyName)
    if type(currency) == "table" and type(currency.has) == "function" then
        local res = callCurrencyMethod(currency, "has", target, reqAmount)
        return res == true
    end
    return Sky.Currency.GetBalance(target, currency) >= reqAmount
end

--- Adds currency to target player.
---@param target any
---@param currencyName string|table
---@param amount number
---@return boolean
function Sky.Currency.Add(target, currencyName, amount)
    local addAmount = math.max(0, tonumber(amount) or 0)
    if addAmount <= 0 then return true end
    local currency = getCurrencyConfig(currencyName)
    local res = callCurrencyMethod(currency, "add", target, addAmount)
    return res == true
end

--- Removes currency from target player.
---@param target any
---@param currencyName string|table
---@param amount number
---@return boolean
function Sky.Currency.Remove(target, currencyName, amount)
    local remAmount = math.max(0, tonumber(amount) or 0)
    if remAmount <= 0 then return true end
    local currency = getCurrencyConfig(currencyName)
    local res = callCurrencyMethod(currency, "remove", target, remAmount)
    return res == true
end
