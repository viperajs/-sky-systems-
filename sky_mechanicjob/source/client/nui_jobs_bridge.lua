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

-- Fallback set of sky_jobs_base NUI callbacks. Used only when the live
-- GetRegisteredNuiCallbacks export is unavailable (e.g. an older sky_jobs_base
-- build that predates the registry export), so the mechanic UI keeps working
-- instead of losing every proxied callback. The dynamic registry is always
-- preferred; keep this list in sync with sky_jobs_base RegisterNUICallback calls.
-- Names owned by mechanic are filtered at registration time, so it is safe to
-- list the full jobs_base set here.
local jobsBaseFallbackCallbacks = {
    "billingSpecs:list",
    "billingSpecs:save",
    "buyBasket",
    "buyGarageVehicle",
    "calendar:addEvent",
    "calendar:getEvents",
    "camera:getFocus",
    "camera:photoResult",
    "camera:setActive",
    "camera:setFacing",
    "camera:setFlash",
    "camera:setFocus",
    "camera:takePhoto",
    "cctv:adjustView",
    "cctv:bodycamSaveResult",
    "cctv:getCameras",
    "cctv:getVideoConfig",
    "cctv:requestBodycamSave",
    "cctv:setView",
    "cctv:setWaypoint",
    "change",
    "changeClothing",
    "changePlate",
    "chat:createGroup",
    "chat:deleteGroup",
    "chat:getAllMembers",
    "chat:getGroup",
    "chat:getGroups",
    "chat:getMessages",
    "chat:getOpenChats",
    "chat:getUnreadMessages",
    "chat:leaveGroup",
    "chat:removeGroupAdmin",
    "chat:sendMessage",
    "chat:setActive",
    "chat:setGroupMembers",
    "chat:setGroupOwner",
    "chat:setProfilePhoto",
    "chat:updateGroup",
    "config:getImageBases",
    "creator/addPoint",
    "creator/clearPoint",
    "creator/createEntry",
    "creator/deleteEntry",
    "creator/getData",
    "creator/keyboard",
    "creator/playSound",
    "creator/removePoint",
    "creator/renameEntry",
    "creator/setActiveJob",
    "creator/setInputFocus",
    "creator/setJobStationBlip",
    "creator/setPoint",
    "creator/setView",
    "customStorageBack",
    "customStorageTransfer",
    "deleteOutfit",
    "deleteRole",
    "demoteMember",
    "documents:getRestrictedClassifications",
    "duty:getSnapshot",
    "duty:set",
    "fireMember",
    "gallery:addPhoto",
    "gallery:deletePhoto",
    "gallery:getPresignedUrl",
    "getAllPlayerNames",
    "getFinanceSnapshot",
    "getGarageVehicleOptions",
    "getGarageVehicles",
    "getItemOptions",
    "getLastTransactions",
    "getLogs",
    "getMembers",
    "getPermissions",
    "getSkin",
    "getVehicleStats",
    "giveBonus",
    "incident:openMap",
    "incident:setWaypoint",
    "itemExists",
    "job:getInfo",
    "jobConfigurator:addCreatorZonePoint",
    "jobConfigurator:clearCreatorZonePoints",
    "jobConfigurator:close",
    "jobConfigurator:configs",
    "jobConfigurator:createCreatorEntry",
    "jobConfigurator:delete",
    "jobConfigurator:deleteCreatorEntry",
    "jobConfigurator:deleteLocations",
    "jobConfigurator:editCarryItemAttach",
    "jobConfigurator:editVehicleAttach",
    "jobConfigurator:getCurrentLocation",
    "jobConfigurator:list",
    "jobConfigurator:placeLocation",
    "jobConfigurator:removeCreatorZonePoint",
    "jobConfigurator:save",
    "jobConfigurator:saveCreatorEntry",
    "jobConfigurator:saveFeatures",
    "jobConfigurator:saveInteractions",
    "jobConfigurator:saveSettings",
    "jobConfigurator:setCreatorZonePoint",
    "jobConfigurator:setCreatorZonePreview",
    "jobConfigurator:teleportLocation",
    "lang:get",
    "lockerTransfer",
    "management:getData",
    "management:getDocumentClassificationOptions",
    "map:dispatch:accept",
    "map:dispatch:delete",
    "map:dispatch:done",
    "map:exclusion:create",
    "map:exclusion:delete",
    "map:getDispatches",
    "map:getExclusionZones",
    "map:getHydrants",
    "map:getOfficers",
    "map:getPanics",
    "map:getPings",
    "map:monitorZone:create",
    "map:monitorZone:delete",
    "map:monitorZone:get",
    "map:setActive",
    "map:setWaypoint",
    "moveRoleDown",
    "moveRoleUp",
    "multijob:close",
    "multijob:getSnapshot",
    "multijob:removeSelf",
    "multijob:setDuty",
    "multijob:switch",
    "openStretcherEditor",
    "openTrunk",
    "openTrunkProps",
    "parkOut",
    "performTransaction",
    "promoteMember",
    "publicForms:addNote",
    "publicForms:close",
    "publicForms:getAll",
    "publicForms:getMyForms",
    "publicForms:getMyNotes",
    "publicForms:getNotes",
    "publicForms:submit",
    "publicForms:updateStatus",
    "radial:close",
    "radial:select",
    "respondInvite",
    "rotate",
    "saveOutfit",
    "saveRole",
    "sellGarageVehicle",
    "sendInvite",
    "storageTransfer",
    "tablet:getApps",
    "tablet:getRestrictedApps",
    "tablet:launchApp",
    "tablet:notificationAction",
    "tablet:themeChanged",
    "trunkPropSelect",
    "trunkTransfer",
    "updateGarageVehiclePlate",
    "weaponExists",
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
                return
            end
            replied = true
            return originalCb(result)
        end
        if GetResourceState("sky_jobs_base") ~= "started" then
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

local function proxyCallbackNames(names)
    local registered = 0
    for _, name in ipairs(names) do
        if not mechanicOwnedCallbacks[name] then
            proxyJobsBaseCallback(name)
            registered = registered + 1
        end
    end

    return registered > 0
end

-- allowFallback: when the live registry export is unavailable, register the
-- static jobsBaseFallbackCallbacks set instead of giving up.
local function registerJobsBaseProxies(allowFallback)
    if GetResourceState("sky_jobs_base") ~= "started" then
        return false
    end

    local ok, names = pcall(function()
        return exports.sky_jobs_base:GetRegisteredNuiCallbacks()
    end)

    if ok and type(names) == "table" then
        return proxyCallbackNames(names)
    end

    if not allowFallback then
        return false
    end

    return proxyCallbackNames(jobsBaseFallbackCallbacks)
end

CreateThread(function()
    local attempts = 0
    local maxAttempts = 20
    while attempts < maxAttempts do
        if registerJobsBaseProxies(false) then
            return
        end
        attempts = attempts + 1
        Wait(500)
    end

    -- Live registry never became available: fall back to the known callback set
    -- so the mechanic UI keeps working (calls degrade gracefully per-callback if
    -- sky_jobs_base is truly outdated and also lacks RunNuiCallback).
    registerJobsBaseProxies(true)
end)

AddEventHandler("onClientResourceStart", function(resourceName)
    if resourceName == "sky_jobs_base" then
        CreateThread(function()
            Wait(250)
            registerJobsBaseProxies()
        end)
    end
end)
