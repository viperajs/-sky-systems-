if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/stolen_parts_dealer.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/stolen_parts_dealer.lua
--  Stolen Vehicle Parts Fence / Dealer Trading
-- =====================================================

local DEALER_POINT_TYPES = { stolen_parts_dealer = true }

local function getSetting(key, fallback)
    if MechanicWorkshopData and MechanicWorkshopData.GetSetting then
        return MechanicWorkshopData.GetSetting(key, fallback)
    end
    return fallback
end

-- Config.PartsTheft.dealer with the /jobconfig overrides the clients also apply.
local function getDealerConfig()
    local cfg = (Config.PartsTheft or {}).dealer or {}
    local items = getSetting("partsTheftDealerItems", cfg.items)
    local account = getSetting("partsTheftDealerAccount", cfg.account)
    return {
        items = type(items) == "table" and items or {},
        account = (type(account) == "string" and account ~= "") and account or "money",
        sellDistance = tonumber(getSetting("partsTheftDealerSellDistance", cfg.sellDistance)) or 5.0
    }
end

local function getAmount(item)
    return math.max(1, math.floor(tonumber(item.amount) or 1))
end

-- The dealer NPCs stand at the stolen_parts_dealer points placed in /jobconfig.
local function isNearDealer(src, maxDistance)
    local points = MechanicWorkshopData and MechanicWorkshopData.GetPoints and MechanicWorkshopData.GetPoints(DEALER_POINT_TYPES)
    local ped = GetPlayerPed(src)
    if not points or not ped or ped == 0 then return false end

    local coords = GetEntityCoords(ped)
    for _, point in ipairs(points) do
        if #(coords - point.coords) <= maxDistance then
            return true
        end
    end
    return false
end

Sky.Cb.Register("sky_mechanicjob:stolenPartsDealer:sell", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local cfg = getDealerConfig()
    local itemName = tostring(type(data) == "table" and data.item or "")

    local entry = nil
    for _, item in ipairs(cfg.items) do
        if type(item) == "table" and type(item.name) == "string" and item.name ~= "" then
            if itemName ~= "" then
                if item.name == itemName then
                    entry = item
                    break
                end
            elseif Functions.GetItemCount(src, item.name) >= getAmount(item) then
                entry = item
                break
            end
        end
    end

    if not entry then
        return { success = false, error = "missing_item" }
    end

    if not isNearDealer(src, cfg.sellDistance) then
        return { success = false, error = "not_near_dealer" }
    end

    local amount = getAmount(entry)
    local price = math.max(0, math.floor(tonumber(entry.price) or 0))
    local label = tostring(entry.label or entry.name)

    if not Functions.RemoveItem(src, entry.name, amount) then
        return { success = false, error = "missing_item" }
    end

    if price > 0 and Functions.AddMoney(src, cfg.account, price) == false then
        Functions.AddItem(src, entry.name, amount)
        return { success = false, error = "payout_failed" }
    end

    return {
        success = true,
        data = {
            amount = amount,
            item = entry.name,
            itemLabel = label,
            price = price,
            priceLabel = string.format("$%d", price)
        }
    }
end)
