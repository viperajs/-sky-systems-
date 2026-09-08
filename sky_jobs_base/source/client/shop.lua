if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/shop.lua") end
-- =====================================================
--  sky_jobs_base · source/client/shop.lua
--  Deobfuscated & Cleaned
-- =====================================================

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}
local shopErrors = (locales.Nui and locales.Nui.shop and locales.Nui.shop.errors) or {}
local shopLookup = shopStationLookup or {}

local function isEmployedAndOnDuty()
    local jobState = GetJobState and GetJobState()
    return jobState and jobState.employed and jobState.onDuty
end

local function getJobColor(data)
    if type(data) == "table" and type(data.jobColor) == "string" and data.jobColor ~= "" then
        return data.jobColor
    end

    local color = Sky.Cb.Trigger("sky_jobs_base:getJobColor")
    if type(color) == "string" and color ~= "" then
        return color
    end

    return nil
end

RegisterNetEvent("sky_jobs_base:wholesaleInteraction", function(data)
    if not isEmployedAndOnDuty() then return end

    local stationId = nil
    if type(data) == "table" then
        stationId = data.stationId or data.id or data.entryId or data.entry
    else
        stationId = shopLookup[data]
    end

    if not stationId then return end
    stationId = tostring(stationId)

    local res = Sky.Cb.Trigger("sky_jobs_base:getWholesaleShopData", stationId)
    if not res or res.success ~= true then
        local errorMsg = (res and res.error) or locales.WholesaleShopUnavailable or "Wholesale shop unavailable."
        Sky.Show.Notification(locales.WholesaleShopTitle or "Wholesale", errorMsg, "error")
        return
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "shop",
        stationId = stationId,
        items = res.items or {},
        balance = res.balance or 0,
        jobColor = getJobColor(res)
    })
end)

RegisterNUICallback("buyBasket", function(data, cb)
    local stationId = (data and data.stationId and tostring(data.stationId)) or nil
    local items = (data and data.items) or nil

    if not stationId or stationId == "" then
        cb({
            success = false,
            error = shopErrors.invalidStation or "Invalid station."
        })
        return
    end

    if type(items) ~= "table" or #items == 0 then
        cb({
            success = false,
            error = shopErrors.emptyBasket or "Basket empty."
        })
        return
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:buyWholesaleItems", stationId, items)
    if not res then
        res = {
            success = false,
            error = shopErrors.unknown or "Unknown error."
        }
    end

    cb({
        success = res.success == true,
        error = res.error,
        data = res.data
    })
end)
