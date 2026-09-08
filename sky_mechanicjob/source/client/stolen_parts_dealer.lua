if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/stolen_parts_dealer.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/stolen_parts_dealer.lua
--  Deobfuscated & Cleaned
-- =====================================================

local DEALER_TYPE = "stolen_parts_dealer"

local dealerState = {
    active = false,
    dialogCam = nil
}

local dealerLocales = tuningLocales.StolenPartsDealer or {}
local DEFAULT_ITEM_IMAGE_BASE = "https://cdn.sky-systems.net/items"
local cachedItemImageBase = nil

-- ── Helpers ──────────────────────────────────────────

local function getItemImageBase()
    if cachedItemImageBase ~= nil then
        return cachedItemImageBase
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:getNuiImageBases")
    if not res then res = {} end

    local base = tostring(res.itemImageBase or DEFAULT_ITEM_IMAGE_BASE)
    if base == "" then base = DEFAULT_ITEM_IMAGE_BASE end
    base = string.gsub(base, "/+$", "")

    cachedItemImageBase = base
    return cachedItemImageBase
end

local function getDealerPedHash()
    local cfg = (Config.Interactions and Config.Interactions.stolen_parts_dealer) or {}
    local npc = cfg.npc or {}
    local pedHash = npc.pedHash or npc.model or npc.hash

    if type(pedHash) == "number" then return pedHash end
    if type(pedHash) == "string" and pedHash ~= "" then return joaat(pedHash) end
    return nil
end

local function extractCoords(data)
    if type(data) ~= "table" then return nil end

    local coords = data.coords
    if type(coords) == "vector3" then return coords end

    if type(coords) == "table" and coords.x and coords.y and coords.z then
        return vector3(tonumber(coords.x) or 0.0, tonumber(coords.y) or 0.0, tonumber(coords.z) or 0.0)
    end

    local point = data.point
    if type(point) == "table" and point.x and point.y and point.z then
        return vector3(tonumber(point.x) or 0.0, tonumber(point.y) or 0.0, tonumber(point.z) or 0.0)
    end

    return nil
end

local function findNearbyDealerNPC(targetCoords)
    if not targetCoords then return 0 end

    local dealerHash = getDealerPedHash()
    local closestPed = 0
    local closestDist = 3.0

    for _, ped in ipairs(GetGamePool("CPed")) do
        if ped ~= PlayerPedId() and DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            if dealerHash and GetEntityModel(ped) ~= dealerHash then
                goto continue
            end

            local dist = #(GetEntityCoords(ped) - targetCoords)
            if dist <= closestDist then
                closestPed = ped
                closestDist = dist
            end
        end
        ::continue::
    end

    return closestPed
end

-- ── Camera ───────────────────────────────────────────

local function removeDialogCam()
    if dealerState.dialogCam then
        dealerState.dialogCam:Remove()
        dealerState.dialogCam = nil
    end
end

local function setupDialogCam(interactionData)
    removeDialogCam()

    local npcEntity = (interactionData and interactionData.npcEntity) or 0

    if not npcEntity or npcEntity == 0 or not DoesEntityExist(npcEntity) then
        npcEntity = findNearbyDealerNPC(extractCoords(interactionData))
    end

    if npcEntity == 0 or not DoesEntityExist(npcEntity) then
        print("[sky_mechanicjob][stolen_parts_dealer] camera failed: no dealer NPC entity found near interaction point")
        return
    end

    local coords = GetEntityCoords(npcEntity)
    local heading = GetEntityHeading(npcEntity)

    dealerState.dialogCam = Sky.Cam:new(coords, { 0.0, 0.0, heading }, true)
    dealerState.dialogCam:PointCamAtEntity(npcEntity)
end

-- ── Dealer Items Config ──────────────────────────────

local function buildDealerItemsList()
    local dealerCfg = (Config.PartsTheft or {}).dealer or {}
    local items = {}

    for _, item in ipairs(dealerCfg.items or {}) do
        local name = tostring(item.name or "")
        if name ~= "" then
            items[#items + 1] = {
                name = name,
                label = tostring(item.label or name),
                amount = math.max(1, math.floor(tonumber(item.amount) or 1)),
                price = math.max(0, math.floor(tonumber(item.price) or 0))
            }
        end
    end

    return items
end

-- ── Open / Close ─────────────────────────────────────

local function closeDealerUI()
    dealerState.active = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = "stolenPartsDealer:close" })
    removeDialogCam()
end

local function openDealerUI(interactionData)
    local items = buildDealerItemsList()

    if #items == 0 then
        print("[sky_mechanicjob][stolen_parts_dealer] open failed: no dealer items configured")
        Sky.Show.Notification(
            dealerLocales.Title or "Parts dealer",
            dealerLocales.Failed or "Unable to sell parts right now.",
            "error"
        )
        return
    end

    dealerState.active = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    local dealerCfg = ((Config.PartsTheft or {}).dealer or {})

    SendNUIMessage({
        action = "stolenPartsDealer:open",
        payload = {
            npcType = DEALER_TYPE,
            acceptedItems = items,
            itemImageBase = getItemImageBase(),
            rewardItem = dealerCfg.account or "money",
            rewardLabel = dealerLocales.CashLabel or "Cash"
        }
    })

    setupDialogCam(interactionData)
end

-- ── Job Interaction Registrations ────────────────────

local registeredJobEvents = {}

local function registerDealerInteraction(jobName)
    if type(jobName) ~= "string" or jobName == "" then return end
    if registeredJobEvents[jobName] then return end

    registeredJobEvents[jobName] = true

    RegisterNetEvent(string.format("sky_jobs_base:interaction:%s:stolen_parts_dealer", jobName), function(data, extra)
        openDealerUI(extra or data)
    end)
end

registerDealerInteraction("mechanic")

for _, job in ipairs(Config.Jobs or {}) do
    registerDealerInteraction(job and job.name)
end

AddEventHandler("sky_mechanicjob:jobConfigurator:updated", function()
    for _, job in ipairs(Config.Jobs or {}) do
        registerDealerInteraction(job and job.name)
    end
end)

-- ── NUI Callbacks ────────────────────────────────────

RegisterNUICallback("stolenPartsDealer:trade", function(data, cb)
    local itemName = (type(data) == "table" and data.item) or nil

    local res = Sky.Cb.Trigger("sky_mechanicjob:stolenPartsDealer:sell", {
        item = itemName
    })

    closeDealerUI()

    if res and res.success then
        local resData = res.data or {}
        local msg = (dealerLocales.TradeSuccess or "You sell {amount}x {item} for {price}.")
            :gsub("{amount}", tostring(resData.amount or 1))
            :gsub("{item}", tostring(resData.itemLabel or resData.item or "part"))
            :gsub("{price}", tostring(resData.priceLabel or resData.price or "$0"))

        Sky.Show.Notification(dealerLocales.Title or "Parts dealer", msg, "success")
    else
        local errorCode = (res and res.error) or "failed"
        local errMsg = dealerLocales.Failed or "Unable to sell parts right now."

        if errorCode == "missing_item" then
            errMsg = dealerLocales.MissingItem or "You have no stolen parts to sell."
        elseif errorCode == "not_near_dealer" then
            errMsg = dealerLocales.NotNearDealer or "Move closer to the parts dealer."
        end

        Sky.Show.Notification(dealerLocales.Title or "Parts dealer", errMsg, "error")
    end

    cb(res or { success = false })
end)

RegisterNUICallback("stolenPartsDealer:close", function(_data, cb)
    closeDealerUI()
    cb({ success = true })
end)

AddEventHandler("sky_jobs:nuiClosed", function()
    if dealerState.active then
        closeDealerUI()
    end
end)
