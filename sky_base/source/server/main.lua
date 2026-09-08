if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/server/main.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_base · source/server/main.lua
--  Server-Side Main Core, Exports & Framework Bridge
-- =====================================================

Sky = Sky or {}

-- -----------------------------------------------------
--  EXPORTS
-- -----------------------------------------------------
registerExport("Get", function()
    return Sky
end)

registerExport("FormatCurrency", function(amount, currency)
    if Sky.Currency and Sky.Currency.Format then
        return Sky.Currency.Format(amount, currency)
    end
    return string.format("$%s", tostring(amount or 0))
end)

registerExport("GetCurrencyFormatter", function(currency)
    if Sky.Currency and Sky.Currency.GetFormatter then
        return Sky.Currency.GetFormatter(currency)
    end
    return nil
end)

registerExport("GetDefaultCurrency", function()
    if Sky.Currency and Sky.Currency.GetDefaultCurrency then
        return Sky.Currency.GetDefaultCurrency()
    end
    return "USD"
end)

-- -----------------------------------------------------
--  SERVER EVENTS & LIFECYCLE
-- -----------------------------------------------------
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Sky.Debug("info", "sky_base server-side initialized.")
    end
end)
