if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/main.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_jobs_base · source/client/main.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky_Jobs = Sky_Jobs or {}
Sky_Jobs.Tablet = Sky_Jobs.Tablet or {}

registerExport("Get", function()
    return Sky_Jobs
end)

local tabletTheme = "dark"
local tabletCfg = (Config and Config.Tablet) or {}
local REQUIRE_TABLET_ITEM = tabletCfg.requireItem == true
local TABLET_ITEM_NAME = (type(tabletCfg.item) == "string" and tabletCfg.item ~= "") and tabletCfg.item or "tablet"

local function getNuiLanguageData()
    local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
    local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}

    local langData = {}
    if type(locales.Nui) == "table" then
        for k, v in pairs(locales.Nui) do
            langData[k] = v
        end
    end

    local currencyConfig = (Sky and Sky.Currency and Sky.Currency.GetNuiConfig and Sky.Currency.GetNuiConfig()) or {}
    langData.currencyFormatters = currencyConfig.formatters or {}
    langData.defaultCurrencyFormatter = currencyConfig.defaultFormatter or "money"
    langData.currencies = currencyConfig.currencies or {}
    langData.defaultCurrency = currencyConfig.defaultCurrency or "money"

    local defaultFmt = langData.currencyFormatters[langData.defaultCurrencyFormatter] or langData.currencyFormatters.money
    if type(defaultFmt) == "table" and type(defaultFmt.symbol) == "string" then
        langData.currency = defaultFmt.symbol
    end

    return langData
end

local function sendLanguageUpdateToNUI()
    SendNUIMessage({
        type = "lang:update",
        data = getNuiLanguageData()
    })
end

CreateThread(function()
    Wait(250)
    sendLanguageUpdateToNUI()
end)

RegisterNetEvent("playerSpawned", function()
    sendLanguageUpdateToNUI()
end)

RegisterNUICallback("getAllPlayerNames", function(data, cb)
    local players = Sky.Cb.Trigger("sky_jobs_base:getPlayersWithNames")
    cb({
        success = true,
        data = players
    })
end)

RegisterNUICallback("job:getInfo", function(data, cb)
    local info = Sky.Cb.Trigger("sky_jobs_base:getJobInfo") or {}
    cb({
        success = true,
        data = info
    })
end)

RegisterNUICallback("lang:get", function(data, cb)
    cb({
        success = true,
        data = getNuiLanguageData()
    })
end)

RegisterNUICallback("config:getImageBases", function(data, cb)
    local bases = Sky.Cb.Trigger("sky_jobs_base:getNuiImageBases") or {}
    cb({
        success = true,
        data = bases
    })
end)

local function extractStationName(data)
    if data and data.stationName and type(data.stationName) == "string" then
        return data.stationName
    end
    return nil
end

RegisterNUICallback("duty:getSnapshot", function(data, cb)
    local stName = extractStationName(data)
    local snapshot = Sky.Cb.Trigger("sky_jobs_base:duty:getSnapshot", stName)
    cb(snapshot or { success = false })
end)

RegisterNUICallback("duty:set", function(data, cb)
    local onDuty = data and data.onDuty == true
    local res = Sky.Cb.Trigger("sky_jobs_base:duty:set", { onDuty = onDuty })

    if res and res.success and res.data then
        TriggerEvent("sky_jobs_base:creator:updatePlayerDuty", res.data.onDuty == true, res.data.jobKey)
    end

    cb(res or { success = false })
end)

local function sanitizeTheme(theme)
    if theme == "light" or theme == "dark" then
        return theme
    end
    return nil
end

local function getMissingTabletError()
    local langData = getNuiLanguageData()
    local radial = langData.radial or {}
    local actions = radial.actions or {}
    local tablet = actions.tablet or {}
    local states = tablet.states or {}
    return states.missingItem or "You need a tablet to do this."
end

function Sky_Jobs.Tablet.HasRequiredItem()
    if not REQUIRE_TABLET_ITEM then return true end
    if not TABLET_ITEM_NAME or TABLET_ITEM_NAME == "" then return false end

    local res = Sky.Cb.Trigger("sky_jobs_base:tablet:hasRequiredItem")
    return res == true
end

function Sky_Jobs.Tablet.Open(appKey, route, options)
    if not Sky_Jobs.Tablet.HasRequiredItem() then
        local langData = getNuiLanguageData()
        local radialTitle = (langData.radial and langData.radial.title) or "Duty actions"
        local missingErr = getMissingTabletError()

        Sky.Show.Notification(radialTitle, missingErr, "info")
        return false, {
            key = "radial.actions.tablet.states.missingItem",
            fallback = missingErr
        }
    end

    options = type(options) == "table" and options or {}

    local mechanicRoute = nil
    if GetResourceState("sky_mechanicjob") == "started" then
        local ok, resolved = pcall(function()
            return exports.sky_mechanicjob:ResolveMechanicTabletRoute(appKey, route)
        end)
        if ok then
            mechanicRoute = resolved
        end
    end

    if mechanicRoute then
        TriggerEvent("sky_mechanicjob:tablet:openApp", {
            key = appKey,
            route = mechanicRoute,
            noAnimation = options.noAnimation,
            openDelayMs = options.openDelayMs,
            jobColor = options.jobColor
        })
        return true
    end

    return Sky_Jobs.Tablet.OpenOnJobsBase(appKey, route, options)
end

function Sky_Jobs.Tablet.OpenOnJobsBase(appKey, route, options)
    options = type(options) == "table" and options or {}

    TriggerEvent("sky_jobs_base:tablet:setOpenState", true, {
        appKey = appKey,
        route = route
    })

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    local nuiPayload = { type = "tablet:open" }
    if type(route) == "string" and route ~= "" then
        nuiPayload.route = route
    end
    if options.jobColor ~= nil then
        nuiPayload.jobColor = options.jobColor
    end

    SendNUIMessage(nuiPayload)

    if type(options.navigate) == "table" then
        SendNUIMessage({
            type = "tablet:navigate",
            data = options.navigate
        })
    end

    return true
end

registerExport("OpenTablet", function(appKey, route, options)
    return Sky_Jobs.Tablet.Open(appKey, route, options)
end)

registerExport("OpenOnJobsBase", function(appKey, route, options)
    return Sky_Jobs.Tablet.OpenOnJobsBase(appKey, route, options)
end)

RegisterNetEvent("sky_jobs_base:tablet:openDirect", function(route, appKey, options)
    Sky_Jobs.Tablet.OpenOnJobsBase(appKey or "home", route or "/tablet", options)
end)

RegisterNUICallback("tablet:themeChanged", function(data, cb)
    local theme = sanitizeTheme(data and data.theme)
    if theme then
        tabletTheme = theme
        TriggerEvent("sky_ambulancejob:tabletThemeSync", theme)
    end
    cb({ success = true })
end)

RegisterNUICallback("tablet:setOpenState", function(data, cb)
    local openState = data and data.open == true
    local appKey = data and (data.appKey or data.key)
    local route = data and data.route

    TriggerEvent("sky_jobs_base:tablet:setOpenState", openState, {
        appKey = appKey,
        route = route
    })
    cb({ success = true })
end)

RegisterNUICallback("tablet:releaseFocus", function(data, cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    cb({ success = true })
end)

RegisterNetEvent("sky_jobs_base:tablet:openHome", function()
    Sky_Jobs.Tablet.Open("home", "/tablet")
end)

RegisterCommand("jobtablet", function()
    if Sky_Jobs and Sky_Jobs.Tablet and Sky_Jobs.Tablet.OpenLast then
        Sky_Jobs.Tablet.OpenLast()
    else
        Sky_Jobs.Tablet.Open("home", "/tablet")
    end
end, false)

RegisterCommand("tablet", function()
    if Sky_Jobs and Sky_Jobs.Tablet and Sky_Jobs.Tablet.OpenLast then
        Sky_Jobs.Tablet.OpenLast()
    else
        Sky_Jobs.Tablet.Open("home", "/tablet")
    end
end, false)

RegisterCommand("bossmenu", function()
    if Sky_Jobs and Sky_Jobs.Tablet and Sky_Jobs.Tablet.Open then
        Sky_Jobs.Tablet.Open("management", "/management")
    else
        TriggerEvent("sky_jobs_base:openBossMenu")
    end
end, false)

RegisterNetEvent("sky_jobs_base:tabletThemeSyncRequest", function()
    TriggerEvent("sky_ambulancejob:tabletThemeSync", tabletTheme)
end)
