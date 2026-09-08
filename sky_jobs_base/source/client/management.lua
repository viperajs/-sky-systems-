if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/management.lua") end
-- =====================================================
--  sky_jobs_base · source/client/management.lua
--  Deobfuscated & Cleaned
-- =====================================================

Job = Job or {}

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}
local nuiLocales = locales.Nui or {}
local mgmtLocales = (nuiLocales.management and nuiLocales.management.roles and nuiLocales.management.roles.permissionEntries) or {}
local fallbackMgmtLocales = (locales.Nui and locales.Nui.management and locales.Nui.management.roles and locales.Nui.management.roles.permissionEntries) or {}

local noAccessMsg = (nuiLocales.management and nuiLocales.management.noAccess) or "You do not have access to management."
local bossMenuNotify = locales.BossMenuHelpNotify or "Management"

local function getPermText(permKey, field, fallbackText)
    local loc = mgmtLocales[permKey] or fallbackMgmtLocales[permKey]
    if loc and loc[field] and loc[field] ~= "" then
        return loc[field]
    end
    return fallbackText
end

local permissionDefinitions = {
    {
        id = Permission.ALL,
        label = getPermText("all", "label", "Full access"),
        description = getPermText("all", "description", "Grants every permission regardless of other toggles.")
    },
    {
        id = Permission.VIEW_LOGS,
        label = getPermText("viewLogs", "label", "View logs"),
        description = getPermText("viewLogs", "description", "Allows reading the job transaction and activity logs.")
    },
    {
        id = Permission.MANAGE_ROLES,
        label = getPermText("manageRoles", "label", "Manage roles"),
        description = getPermText("manageRoles", "description", "Allows creating, editing, moving, and deleting grades.")
    },
    {
        id = Permission.MANAGE_MEMBERS,
        label = getPermText("manageMembers", "label", "Manage members"),
        description = getPermText("manageMembers", "description", "Allows promoting, demoting, firing, or paying bonuses.")
    },
    {
        id = Permission.MANAGE_WAREHOUSE,
        label = getPermText("manageWarehouse", "label", "Access storage"),
        options = true,
        optionType = "item",
        allowWeaponOptions = false,
        description = getPermText("manageWarehouse", "description", "Allows interacting with the shared storage inventory.")
    },
    {
        id = Permission.MANAGE_MONEY,
        label = getPermText("manageMoney", "label", "Manage funds"),
        description = getPermText("manageMoney", "description", "Allows depositing or withdrawing society money.")
    },
    {
        id = Permission.PURCHASE_SUPPLIES,
        label = getPermText("purchaseSupplies", "label", "Order supplies"),
        description = getPermText("purchaseSupplies", "description", "Allows purchasing equipment from the wholesale supplier with faction funds.")
    },
    {
        id = Permission.PURCHASE_VEHICLES,
        label = getPermText("purchaseVehicles", "label", "Purchase vehicles"),
        description = getPermText("purchaseVehicles", "description", "Allows buying new fleet vehicles with faction funds.")
    },
    {
        id = Permission.SELL_VEHICLES,
        label = getPermText("sellVehicles", "label", "Sell vehicles"),
        description = getPermText("sellVehicles", "description", "Allows selling fleet vehicles back for faction funds.")
    },
    {
        id = Permission.GARAGE_VEHICLES,
        label = getPermText("garageVehicles", "label", "Garage vehicle restrictions"),
        options = true,
        optionType = "vehicle",
        description = getPermText("garageVehicles", "description", "Select which fleet vehicles this role cannot access in the garage.")
    },
    {
        id = Permission.TABLET_APPS,
        label = getPermText("tabletApps", "label", "Tablet app restrictions"),
        options = true,
        optionType = "tablet_app",
        description = getPermText("tabletApps", "description", "Select which tablet apps this role cannot access.")
    },
    {
        id = Permission.DOCUMENT_CLASSIFICATIONS,
        label = getPermText("documentClassifications", "label", "Document classification restrictions"),
        options = true,
        optionType = "document_classification",
        description = getPermText("documentClassifications", "description", "Select which document classifications this role cannot view.")
    },
    {
        id = Permission.EDIT_OUTFITS,
        label = getPermText("editOutfits", "label", "Edit outfits"),
        description = getPermText("editOutfits", "description", "Allows updating saved wardrobe entries.")
    },
    {
        id = Permission.CREATE_OUTFITS,
        label = getPermText("createOutfits", "label", "Create outfits"),
        description = getPermText("createOutfits", "description", "Allows creating new wardrobe entries.")
    },
    {
        id = Permission.DELETE_OUTFITS,
        label = getPermText("deleteOutfits", "label", "Delete outfits"),
        description = getPermText("deleteOutfits", "description", "Allows removing saved wardrobe entries.")
    }
}

local activeInviteId = nil
local isInviteUIOpen = false

local isUiReady = false
local pendingJobData = nil
local isDataSyncThreadRunning = false

local function updateNuiImageConfig()
    local nuiCfg = Config and Config.Nui or {}
    local itemBase = (type(nuiCfg.itemImageBase) == "string" and nuiCfg.itemImageBase ~= "") and nuiCfg.itemImageBase or "https://cdn.sky-systems.net/items"
    local vehicleBase = (type(nuiCfg.vehicleImageBase) == "string" and nuiCfg.vehicleImageBase ~= "") and nuiCfg.vehicleImageBase or "https://cdn.sky-systems.net/vehicles"
    local weaponBase = (type(nuiCfg.weaponImageBase) == "string" and nuiCfg.weaponImageBase ~= "") and nuiCfg.weaponImageBase or "https://cdn.sky-systems.net/weapons"
    local propBase = (type(nuiCfg.propImageBase) == "string" and nuiCfg.propImageBase ~= "") and nuiCfg.propImageBase or "https://cdn.sky-systems.net/props"
    local pedBase = (type(nuiCfg.pedImageBase) == "string" and nuiCfg.pedImageBase ~= "") and nuiCfg.pedImageBase or "https://cdn.sky-systems.net/peds"

    SendNUIMessage({
        type = "config:update",
        data = {
            itemImageBase = itemBase,
            weaponImageBase = weaponBase,
            propImageBase = propBase,
            pedImageBase = pedBase,
            vehicleImageBase = vehicleBase
        }
    })
end

local function hasNonEmptySections(sections)
    if type(sections) ~= "table" then return true end
    for _, sec in pairs(sections) do
        if sec then return true end
    end
    return false
end

local function sendJobDataToNUI(data)
    SendNUIMessage({
        type = "management",
        data = Sky.V(data, "NUI JobData")
    })
end

local function processPendingJobData()
    if not pendingJobData then return end

    if isUiReady then
        sendJobDataToNUI(pendingJobData)
        pendingJobData = nil
        return
    end

    if isDataSyncThreadRunning then return end
    isDataSyncThreadRunning = true

    CreateThread(function()
        while pendingJobData and not isUiReady do
            Wait(50)
        end

        if pendingJobData and isUiReady then
            sendJobDataToNUI(pendingJobData)
            pendingJobData = nil
        end
        isDataSyncThreadRunning = false
    end)
end

local function closeJobInviteUI()
    if isInviteUIOpen then
        SetNuiFocus(false, false)
        isInviteUIOpen = false
    end
    activeInviteId = nil
    SendNUIMessage({ type = "jobInvite:close" })
end

RegisterNetEvent("sky_jobs_base:inviteReceived", function(data)
    activeInviteId = data and data.id
    isInviteUIOpen = not IsNuiFocused()

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "jobInvite:open",
        data = data
    })
end)

RegisterNetEvent("sky_jobs_base:inviteClosed", function(data)
    if data and data.id and activeInviteId and data.id ~= activeInviteId then return end
    closeJobInviteUI()
end)

RegisterNetEvent("sky_jobs_base:membersUpdated", function()
    SendNUIMessage({ type = "management:refreshMembers" })
end)

RegisterNetEvent("sky_jobs_base:financeUpdated", function()
    SendNUIMessage({ type = "management:refreshFinance" })
end)

RegisterNetEvent("sky_jobs_base:inviteResult", function()
    SendNUIMessage({ type = "management:refreshMembers" })
end)

function Job.OpenMenu()
    local jobData = Sky.Cb.Trigger("sky_jobs_base:getJobData")
    if type(jobData) ~= "table" or not hasNonEmptySections(jobData.sections) then
        Sky.Show.Notification(bossMenuNotify, noAccessMsg, "error")
        return
    end

    SetNuiFocus(true, true)
    pendingJobData = jobData
    processPendingJobData()
end

AddEventHandler("sky_jobs_base:bossMenuInteraction", function()
    Job.OpenMenu()
end)

RegisterNetEvent("sky_jobs_base:gradeChanged", function(oldGrade, newGrade)
    PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
    SendNUIMessage({
        type = "grade:change",
        data = {
            oldGrade = oldGrade,
            newGrade = newGrade
        }
    })
end)

RegisterNetEvent("sky_jobs_base:bonusReceived", function(data)
    SendNUIMessage({
        type = "bonus:received",
        data = data
    })
end)

RegisterNetEvent("sky_jobs_base:management:close", function()
    pendingJobData = nil
    isInviteUIOpen = false
    SendNUIMessage({ type = "management:close" })
end)

RegisterNUICallback("getLogs", function(data, cb)
    local logs = Sky.Cb.Trigger("sky_jobs_base:getJobLogs", data.from, data.to)
    if type(logs) ~= "table" then
        cb({ success = false, error = "Failed to load logs." })
        return
    end
    cb({ success = true, data = logs })
end)

RegisterNUICallback("performTransaction", function(data, cb)
    local transType = data.type
    local amount = tonumber(data.amount)

    if not (transType and amount) or amount <= 0 then
        cb({ success = false, error = "Invalid parameters." })
        return
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:transactionJobMoney", transType, amount) or {}
    cb({
        success = res.success == true,
        error = res.error or nil,
        data = res.log,
        balance = res.balance,
        currency = res.currency
    })
end)

RegisterNUICallback("getLastTransactions", function(data, cb)
    local limit = tonumber(data and data.limit) or 100
    local offset = tonumber(data and data.offset) or 0

    local logs = Sky.Cb.Trigger("sky_jobs_base:transactionLogs", limit, offset)
    if type(logs) ~= "table" then logs = {} end

    cb({
        success = true,
        data = logs,
        hasMore = #logs >= limit
    })
end)

RegisterNUICallback("getFinanceSnapshot", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:getFinanceSnapshot") or {}
    if type(res) ~= "table" or res.success ~= true then
        cb({
            success = false,
            error = (type(res) == "table" and res.error) or "Failed to load finance data."
        })
        return
    end

    cb({
        success = true,
        data = res.data
    })
end)

RegisterNUICallback("getMembers", function(data, cb)
    local members = Sky.Cb.Trigger("sky_jobs_base:getJobMembers")
    cb({
        success = true,
        data = members
    })
end)

RegisterNUICallback("billingSpecs:list", function(data, cb)
    local specs = Sky.Cb.Trigger("sky_jobs_base:getBillingSpecs") or {}
    cb({
        success = true,
        data = { specs = specs }
    })
end)

RegisterNUICallback("billingSpecs:save", function(data, cb)
    local specs = (type(data) == "table" and type(data.specs) == "table") and data.specs or {}
    local res = Sky.Cb.Trigger("sky_jobs_base:saveBillingSpecs", specs) or { success = false, error = "Unknown Error" }
    cb(res)
end)

RegisterNUICallback("sendInvite", function(data, cb)
    local playerId = tonumber(data.playerId)
    local grade = tonumber(data.grade)

    if not playerId or grade == nil then
        cb({ success = false, error = "Invalid parameters." })
        return
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:sendInvite", playerId, grade)
    if type(res) ~= "table" then
        res = { success = false, error = "Unknown Error" }
    end
    cb(res)
end)

RegisterNUICallback("respondInvite", function(data, cb)
    local inviteId = data.inviteId or activeInviteId
    if not inviteId then
        cb({ success = false, error = "Invite expired" })
        return
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:respondInvite", inviteId, data.accepted == true)
    if type(res) ~= "table" then
        res = { success = false, error = "Unknown Error" }
    end
    cb(res)
end)

RegisterNUICallback("promoteMember", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:setMember", "promote", data.identifier)
    cb(res)
end)

RegisterNUICallback("demoteMember", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:setMember", "demote", data.identifier)
    cb(res)
end)

RegisterNUICallback("fireMember", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:setMember", "fire", data.identifier)
    cb(res)
end)

RegisterNUICallback("giveBonus", function(data, cb)
    local amount = tonumber(data.amount)
    if not amount or amount <= 0 then
        cb({ success = false, error = "Invalid amount." })
        return
    end

    if type(data.identifier) ~= "string" or data.identifier == "" then
        cb({ success = false, error = "Invalid identifier." })
        return
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:giveBonus", data.identifier, amount)
    cb(res or { success = false, error = "Unknown Error" })
end)

RegisterNUICallback("uiReady", function(data, cb)
    isUiReady = true
    processPendingJobData()
    updateNuiImageConfig()
    TriggerEvent("sky_jobs_base:uiReady", data or {})
    cb({ success = true })
end)

RegisterNUICallback("management:getData", function(data, cb)
    local jobData = Sky.Cb.Trigger("sky_jobs_base:getJobData")
    if type(jobData) ~= "table" or not hasNonEmptySections(jobData.sections) then
        cb({ success = false, error = noAccessMsg })
        return
    end

    cb({ success = true, data = jobData })
end)

RegisterNUICallback("getPermissions", function(data, cb)
    local grade = tonumber(data.grade)
    if grade == nil then
        cb({ success = false, error = "Invalid job grade." })
        return
    end

    local permsMap = Sky.Cb.Trigger("sky_jobs_base:getJobPlayerPermissions", grade) or {}
    local containsWeapons = Sky.Cb.Trigger("sky_jobs_base:getJobStorageContainsWeapons") == true

    local resultList = {}
    for _, def in ipairs(permissionDefinitions) do
        local entry = {
            id = def.id,
            label = def.label,
            description = def.description,
            enabled = permsMap[tostring(def.id)] == true,
            options = def.options == true,
            optionType = def.optionType,
            allowWeaponOptions = def.allowWeaponOptions == true,
            selectedOptions = {},
            selectedWeaponOptions = {}
        }

        if def.id == Permission.MANAGE_WAREHOUSE then
            local resItems = Sky.Cb.Trigger("sky_jobs_base:getGradeRestrictedItems", grade) or {}
            entry.selectedOptions = resItems.data or {}
            entry.allowWeaponOptions = containsWeapons

            if containsWeapons then
                local resWeaps = Sky.Cb.Trigger("sky_jobs_base:getGradeRestrictedWeapons", grade) or {}
                entry.selectedWeaponOptions = resWeaps.data or {}
            end
        elseif def.id == Permission.GARAGE_VEHICLES then
            local resVehs = Sky.Cb.Trigger("sky_jobs_base:getGradeRestrictedVehicles", grade) or {}
            entry.selectedOptions = resVehs.data or {}
        elseif def.id == Permission.TABLET_APPS then
            local resApps = Sky.Cb.Trigger("sky_jobs_base:getGradeRestrictedTabletApps", grade) or {}
            entry.selectedOptions = resApps.data or {}
        elseif def.id == Permission.DOCUMENT_CLASSIFICATIONS then
            local resDocs = Sky.Cb.Trigger("sky_jobs_base:getGradeRestrictedDocumentClassifications", grade) or {}
            entry.selectedOptions = resDocs.data or {}
        end

        table.insert(resultList, entry)
    end

    cb({ success = true, data = resultList })
end)

RegisterNUICallback("moveRoleUp", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:editGrade", "moveRoleUp", data.grade)
    cb(res)
end)

RegisterNUICallback("moveRoleDown", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:editGrade", "moveRoleDown", data.grade)
    cb(res)
end)

RegisterNUICallback("deleteRole", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:editGrade", "delete", data.grade)
    cb(res)
end)

RegisterNUICallback("saveRole", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:saveGrade", data)
    cb(type(res) == "table" and res or { success = false, error = "Unknown Error" })
end)

RegisterNUICallback("getItemOptions", function(data, cb)
    local opts = Sky.Cb.Trigger("sky_jobs_base:getItemOptions")
    if type(opts) == "table" then
        cb(opts)
        return
    end
    cb({ success = false, data = {} })
end)

RegisterNUICallback("itemExists", function(data, cb)
    if not data.item then
        cb({ success = false, error = "Invalid item." })
        return
    end

    local exists = Sky.Cb.Trigger("sky_jobs_base:itemExists", data.item)
    cb({ success = exists == true })
end)

RegisterNUICallback("weaponExists", function(data, cb)
    if not data.weapon then
        cb({ success = false, error = "Invalid weapon." })
        return
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:weaponExists", data.weapon)
    if type(res) == "table" then
        cb(res)
        return
    end
    cb({ success = res == true })
end)

RegisterNUICallback("getGarageVehicleOptions", function(data, cb)
    local res = Sky.Cb.TriggerWithTimeout("sky_jobs_base:getJobGarageCatalog", 10000)
    local catalog = nil

    if type(res) == "table" and res.success == true and type(res.data) == "table" then
        catalog = res.data
    else
        catalog = (Config and Config.JobGarage and Config.JobGarage.vehicles) or {}
    end

    local optionsList = {}
    local seenModels = {}

    for _, v in ipairs(catalog) do
        local model = type(v.model) == "string" and v.model or nil
        local name = type(v.name) == "string" and v.name or nil

        if model and model ~= "" and name and name ~= "" then
            local lowerModel = model:lower()
            if not seenModels[lowerModel] then
                seenModels[lowerModel] = true
                table.insert(optionsList, { label = name, value = model })
            end
        end
    end

    table.sort(optionsList, function(a, b)
        return tostring(a.label or "") < tostring(b.label or "")
    end)

    cb({ success = true, data = optionsList })
end)

RegisterNUICallback("tablet:getRestrictedApps", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:getPlayerRestrictedTabletApps") or {}
    if type(res) == "table" and res.success ~= nil then
        cb(res)
        return
    end
    cb({ success = true, data = res })
end)

RegisterNUICallback("documents:getRestrictedClassifications", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:getPlayerRestrictedDocumentClassifications") or {}
    if type(res) == "table" and res.success ~= nil then
        cb(res)
        return
    end
    cb({ success = true, data = res })
end)

RegisterNUICallback("management:getDocumentClassificationOptions", function(data, cb)
    cb({
        success = true,
        data = {
            { label = "Unclassified", value = "unclassified" },
            { label = "Restricted", value = "restricted" },
            { label = "Confidential", value = "confidential" },
            { label = "Secret", value = "secret" },
            { label = "Top Secret", value = "top_secret" }
        }
    })
end)

AddEventHandler("sky_jobs:nuiClosed", function()
    pendingJobData = nil
    isInviteUIOpen = false
end)
