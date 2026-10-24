-- =====================================================
--  sky_base · source/server/main.lua
--  Server-Side Main Core, Exports & Framework Bridge
-- =====================================================

Sky = Sky or {}

-- -----------------------------------------------------
--  EXPORTS
-- -----------------------------------------------------
exports("Get", function()
    return Sky
end)

exports("FormatCurrency", function(amount, currency)
    if Sky.Currency and Sky.Currency.Format then
        return Sky.Currency.Format(amount, currency)
    end
    return string.format("$%s", tostring(amount or 0))
end)

exports("GetCurrencyFormatter", function(currency)
    if Sky.Currency and Sky.Currency.GetFormatter then
        return Sky.Currency.GetFormatter(currency)
    end
    return nil
end)

exports("GetDefaultCurrency", function()
    if Sky.Currency and Sky.Currency.GetDefaultCurrency then
        return Sky.Currency.GetDefaultCurrency()
    end
    return "USD"
end)

-- Framework bridge: resources that do not load config/framework (sky_jobs_base) call
-- Sky.FW.<method> through these exports instead of having no framework at all.
local function getFrameworkFunction(method)
    if type(method) ~= "string" or type(Sky.FW) ~= "table" then
        return nil
    end
    local fn = Sky.FW[method]
    return type(fn) == "function" and fn or nil
end

exports("HasFrameworkFunction", function(method)
    return getFrameworkFunction(method) ~= nil
end)

exports("CallFramework", function(method, ...)
    local fn = getFrameworkFunction(method)
    if not fn then
        return nil
    end

    local results = table.pack(pcall(fn, ...))
    if not results[1] then
        Sky.Debug("error", ("Sky.FW.%s failed: %s"):format(tostring(method), tostring(results[2])))
        return nil
    end
    return table.unpack(results, 2, results.n)
end)

-- -----------------------------------------------------
--  SERVER EVENTS & LIFECYCLE
-- -----------------------------------------------------
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Sky.Debug("info", "sky_base server-side initialized.")
    end
end)
