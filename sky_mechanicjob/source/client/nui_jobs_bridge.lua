if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/nui_jobs_bridge.lua") end
local function logDiagnostics(level, event, details)
    if SkyDiagnostics and SkyDiagnostics.Log then
        SkyDiagnostics.Log(level, event, details)
    elseif level == "warn" or level == "error" then
        local ok, message = pcall(json.encode, details or {})
        print(("[sky_mechanicjob][%s][%s] %s"):format(level:upper(), event, ok and message or "Diagnostics unavailable"))
    end
end
-- =====================================================
--  sky_mechanicjob · source/client/nui_jobs_bridge.lua
--  Proxies sky_jobs_base NUI callbacks into mechanic NUI
-- =====================================================

local mechanicOwnedCallbacks = {
    uiReady = true,
    close = true,
    ["tablet:setOpenState"] = true,
    ["tablet:returnHome"] = true,
    ["tablet:releaseFocus"] = true,
    ["tablet:getNearbyVehicles"] = true,
    ["tablet:setConnectedVehicle"] = true,
    ["tablet:getConnectedVehicle"] = true,
    ["orders:getAll"] = true,
    ["orders:refund"] = true,
    ["orders:delete"] = true,
    ["orders:startInstall"] = true,
    ["tuning:focus"] = true,
    ["tuning:section"] = true,
    ["tuning:toggleFocus"] = true,
    ["tuning:apply"] = true,
    ["tuning:applyCustomColor"] = true,
    ["tuning:reset"] = true,
    ["tuning:syncOptions"] = true,
    ["tuning:resetStance"] = true,
    ["tuning:purchase"] = true,
    ["tuningRemoval:listApplied"] = true,
    ["tuningRemoval:remove"] = true,
    ["wear:getDiagnostics"] = true,
    ["wear:repairPart"] = true,
    ["vehicles:getRegistry"] = true,
    ["vehicles:getHistory"] = true,
    ["vehicles:setImage"] = true,
    ["vehicles:setTags"] = true,
    ["vehicles:setNotes"] = true,
    ["dyno:run"] = true,
    ["partsShop:getConfig"] = true,
    ["partsShop:placeOrder"] = true,
    ["partsShop:getOrderHistory"] = true,
    ["gallery:getPhotos"] = true,
    ["liftControl:setDirection"] = true,
    ["liftControl:close"] = true,
    ["wheelDetach:result"] = true,
    ["engineSwap:result"] = true,
    ["oilDrain:result"] = true,
    ["oilPour:result"] = true,
    ["stolenPartsDealer:trade"] = true,
    ["stolenPartsDealer:close"] = true,
    ["lugWrench:choice"] = true,
}

local function getFallbackCallbackResponse(name, data)
    if name == "lang:get" then
        return {
            success = true,
            data = {
                lang = (Sky and Sky.Config and Sky.Config.locale) or "en",
                locales = nuiLocales or {}
            }
        }
    elseif name == "job:getInfo" then
        return {
            success = true,
            data = {
                jobKey = "mechanic",
                name = "Mechanic",
                primaryColor = "#EDC001"
            }
        }
    elseif name == "config:getImageBases" then
        return {
            success = true,
            data = {
                itemImageBase = "https://cdn.sky-systems.net/items"
            }
        }
    elseif name == "tablet:getApps" then
        return {
            success = true,
            data = {
                apps = {}
            }
        }
    elseif name == "tablet:launchApp" then
        return {
            success = true
        }
    end
    return nil
end

local function proxyJobsBaseCallback(name)
    RegisterNUICallback(name, function(data, cb)
        local replied = false
        local originalCb = cb
        cb = function(result)
            if replied then
                logDiagnostics("warn", "nui.proxy_duplicate_reply", { name = name, file = "sky_mechanicjob/source/client/nui_jobs_bridge.lua" })
                return
            end
            replied = true
            return originalCb(result)
        end
        logDiagnostics("debug", "nui.proxy_started", { name = name, jobsBaseState = GetResourceState("sky_jobs_base") })
        if GetResourceState("sky_jobs_base") ~= "started" then
            logDiagnostics("warn", "nui.proxy_not_ready", { name = name, message = "sky_jobs_base is not started; trying fallback." })
            local fallback = getFallbackCallbackResponse(name, data)
            if fallback then
                cb(fallback)
                return
            end
            cb({ success = false, error = "jobs_base_not_ready" })
            return
        end

        local ok, handled = pcall(function()
            return exports.sky_jobs_base:RunNuiCallback(name, data, function(res)
                if res == nil then
                    logDiagnostics("warn", "nui.proxy_empty", { name = name, message = "Jobs base returned nil; trying fallback." })
                    local fallback = getFallbackCallbackResponse(name, data)
                    if fallback then
                        cb(fallback)
                        return
                    end
                end
                cb(res or { success = false, error = "empty_response" })
            end)
        end)

        if not ok or handled == false then
            logDiagnostics("error", "nui.proxy_failed", { name = name, message = not ok and tostring(handled) or "Callback was not handled." })
            if replied then return end
            local fallback = getFallbackCallbackResponse(name, data)
            if fallback then
                cb(fallback)
                return
            end
            cb({ success = false, error = "proxy_failed" })
        end
    end)
end

local function registerJobsBaseProxies()
    if GetResourceState("sky_jobs_base") ~= "started" then
        return false
    end

    local ok, names = pcall(function()
        return exports.sky_jobs_base:GetRegisteredNuiCallbacks()
    end)

    if not ok or type(names) ~= "table" then
        logDiagnostics("warn", "nui.proxy_registry_unavailable", { message = not ok and tostring(names) or "Registry response is not a table." })
        return false
    end

    local registered = 0
    for _, name in ipairs(names) do
        if not mechanicOwnedCallbacks[name] and name:sub(1, 16) ~= "sky:diagnostics:" then
            proxyJobsBaseCallback(name)
            registered = registered + 1
        end
    end

    logDiagnostics("info", "nui.proxy_registered", { count = registered, jobsCallbacks = #names })
    return registered > 0
end

CreateThread(function()
    local attempts = 0
    while attempts < 60 do
        if registerJobsBaseProxies() then
            return
        end
        attempts = attempts + 1
        if attempts == 1 or attempts % 10 == 0 then
            logDiagnostics("warn", "nui.proxy_retry", { attempt = attempts, maxAttempts = 60, jobsBaseState = GetResourceState("sky_jobs_base") })
        end
        Wait(500)
    end
    logDiagnostics("error", "nui.proxy_exhausted", { attempts = attempts, message = "Jobs NUI callbacks could not be registered after 30 seconds." })
end)

AddEventHandler("onClientResourceStart", function(resourceName)
    if resourceName == "sky_jobs_base" then
        CreateThread(function()
            Wait(250)
            registerJobsBaseProxies()
        end)
    end
end)
