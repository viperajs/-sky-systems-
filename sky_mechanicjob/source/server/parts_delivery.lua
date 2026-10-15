if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/parts_delivery.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/parts_delivery.lua
--  Parts Delivery Shop, Warehouse Logistics & Pallet Claims
-- =====================================================

local MAX_LINE_QUANTITY = 99 -- the tablet basket caps every line at 99
local CLAIM_DISTANCE = 10.0
local STORAGE_DISTANCE = 10.0
local WORKSHOP_DATA_TTL_MS = 60000
local DELIVERY_POINT_TYPES = { parts_drop = true, part_delivery = true, parts_delivery = true, delivery = true, delivery_bay = true }
local STORAGE_POINT_TYPES = { storage = true }

-- Delivery each player carries out of a delivery bay (carry items mode).
local heldCarry = {}

-- ── Workshop Locations ───────────────────────────────
-- The /jobconfig workshops as sky_jobs_base stores them, or nil when they cannot be read.
-- Also used by stolen_parts_dealer.lua.

MechanicWorkshopData = MechanicWorkshopData or {}

local workshopData, workshopDataAt = nil, nil

function MechanicWorkshopData.Get()
    local now = GetGameTimer()
    if workshopDataAt and now - workshopDataAt < WORKSHOP_DATA_TTL_MS then
        return workshopData
    end

    local data = nil
    local ok, row = pcall(MySQL.single.await, "SELECT data FROM sky_jobs_creator_data WHERE creator_key = 'workshopcreator' LIMIT 1")
    if ok and type(row) == "table" and type(row.data) == "string" then
        local decoded, parsed = pcall(json.decode, row.data)
        if decoded and type(parsed) == "table" and type(parsed.entries) == "table" then
            data = parsed
        end
    end

    workshopData, workshopDataAt = data, now
    return data
end

--- Points of the given types as { key, job, label, coords, heading }, or nil without workshop data.
function MechanicWorkshopData.GetPoints(types)
    local data = MechanicWorkshopData.Get()
    if not data then return nil end

    local points = {}
    for _, entry in ipairs(data.entries) do
        if type(entry) == "table" and type(entry.points) == "table" then
            local job = entry.jobKey or entry.job
            for _, point in ipairs(entry.points) do
                if type(point) == "table" and types[point.type] then
                    local x, y, z = tonumber(point.x), tonumber(point.y), tonumber(point.z)
                    if x and y and z then
                        points[#points + 1] = {
                            key = ("%s:%s:%s"):format(tostring(point.type), tostring(entry.id), tostring(point.uid)),
                            job = (type(job) == "string" and job ~= "") and job or nil,
                            label = tostring(point.label or entry.label or entry.name or "Delivery Bay"),
                            coords = vector3(x, y, z),
                            heading = tonumber(point.heading) or 0.0
                        }
                    end
                end
            end
        end
    end
    return points
end

-- The clients apply the /jobconfig settings and features over config.lua (client/main.lua).
function MechanicWorkshopData.GetSetting(key, fallback)
    if Config.UseJobConfigurator then
        local data = MechanicWorkshopData.Get()
        local settings = data and data.settings
        if type(settings) == "table" and settings[key] ~= nil then
            return settings[key]
        end
    end
    return fallback
end

function MechanicWorkshopData.IsFeatureEnabled(key, default)
    if Config.UseJobConfigurator then
        local data = MechanicWorkshopData.Get()
        local features = data and data.features
        if type(features) == "table" and features[key] ~= nil then
            return features[key] == true
        end
    end
    local value = (Config.ToggleFeatures or {})[key]
    if value == nil then return default == true end
    return value == true
end

AddEventHandler("sky_jobs_base:jobConfigurator:jobNamesUpdated", function()
    workshopDataAt = nil
end)

-- ── Helpers ──────────────────────────────────────────

local function isMechanicOnDuty(src)
    return Functions.IsMechanicOnDuty ~= nil and Functions.IsMechanicOnDuty(src) == true
end

local function decodeJson(value)
    if type(value) ~= "string" or value == "" then return {} end
    local ok, decoded = pcall(json.decode, value)
    return (ok and type(decoded) == "table") and decoded or {}
end

local function formatOrderUid(deliveryId)
    return ("PD-%05d"):format(tonumber(deliveryId) or 0)
end

local function isPlayerNear(src, coords, maxDistance)
    local x, y, z
    if type(coords) == "table" or type(coords) == "vector3" then
        x, y, z = tonumber(coords.x), tonumber(coords.y), tonumber(coords.z)
    end
    local ped = GetPlayerPed(src)
    if not (x and y and z) or not ped or ped == 0 then return false end
    return #(GetEntityCoords(ped) - vector3(x, y, z)) <= maxDistance
end

-- True without workshop data, since the layout is then unknown on the server.
local function isNearJobPoint(src, job, types, maxDistance)
    local points = MechanicWorkshopData.GetPoints(types)
    if not points then return true end
    for _, point in ipairs(points) do
        if (point.job == nil or point.job == job) and isPlayerNear(src, point.coords, maxDistance) then
            return true
        end
    end
    return false
end

local function notifyJob(job)
    if type(job) ~= "string" or job == "" then return end
    for _, playerId in ipairs(GetPlayers()) do
        local target = tonumber(playerId)
        if target and Functions.GetJob(target) == job then
            TriggerClientEvent("sky_mechanicjob:partsDelivery:readyDeliveriesChanged", target)
        end
    end
end

-- ── Catalogue ────────────────────────────────────────

-- /jobconfig names are typed in; "turbo " is no inventory item.
local function trimName(value)
    return type(value) == "string" and value:match("^%s*(.-)%s*$") or ""
end

local function buildCatalog(jobCfg)
    local catalog = {}
    for _, item in ipairs(jobCfg.partsDeliveryShop or jobCfg.shop or {}) do
        local name = type(item) == "table" and trimName(item.name) or ""
        if name ~= "" then
            catalog[#catalog + 1] = {
                name = name,
                label = item.label or name,
                price = math.max(0, math.floor(tonumber(item.price) or 100)),
                category = item.category or "General"
            }
        end
    end
    return catalog
end

-- The workshop's Parts Delivery tab in /jobconfig, else its config.lua job (server/pricing.lua).
local function getShopCatalog(job)
    return buildCatalog(Pricing.GetJobConfig(job))
end

local function getCatalogMap(job)
    local map = {}
    for _, item in ipairs(getShopCatalog(job)) do
        map[item.name] = item
    end
    return map
end

-- Every item any workshop's parts shop (or config.lua job) sells.
local function getAnyCatalogMap()
    local map = {}
    for _, jobCfg in ipairs(Pricing.GetAllJobConfigs()) do
        if type(jobCfg) == "table" then
            for _, item in ipairs(buildCatalog(jobCfg)) do
                map[item.name] = map[item.name] or item
            end
        end
    end
    return map
end

local function readQuantity(line)
    return math.floor(tonumber(type(line) == "table" and (line.quantity or line.count or line.amount) or nil) or 0)
end

-- Catalogue prices only; the tablet sends { name, quantity } per basket line.
local function buildOrderLines(job, items)
    if type(items) ~= "table" then return nil end

    local catalog = getCatalogMap(job)
    local byName, lines, total = {}, {}, 0
    for _, it in ipairs(items) do
        local item = type(it) == "table" and catalog[it.name] or nil
        local quantity = readQuantity(it)
        if not item or not (quantity >= 1 and quantity <= MAX_LINE_QUANTITY) then
            return nil
        end

        local line = byName[item.name]
        if not line then
            line = { name = item.name, label = item.label, quantity = 0 }
            byName[item.name] = line
            lines[#lines + 1] = line
        end
        line.quantity = line.quantity + quantity
        if line.quantity > MAX_LINE_QUANTITY then
            return nil
        end
        total = total + item.price * quantity
    end

    if #lines == 0 then return nil end
    return lines, total
end

-- Only items a parts shop sells are handed out, so rows stored before these checks cannot pay
-- out arbitrary items or quantities. A part taken out of the workshop's own Parts Delivery tab
-- after it was ordered and paid is still delivered while any shop sells it; before, opening
-- such a delivery said "Delivery unpacked." and gave nothing.
local function decodeLines(itemsJson, job)
    local catalog = getCatalogMap(job)
    local anyCatalog = nil
    local lines = {}
    for _, it in ipairs(decodeJson(itemsJson)) do
        local name = type(it) == "table" and trimName(it.name) or ""
        local item = catalog[name]
        if not item and name ~= "" then
            anyCatalog = anyCatalog or getAnyCatalogMap()
            item = anyCatalog[name]
        end
        local quantity = readQuantity(it)
        if item and quantity >= 1 and quantity <= MAX_LINE_QUANTITY then
            lines[#lines + 1] = { name = item.name, label = item.label, quantity = quantity }
        end
    end
    return lines
end

-- ── Settings ─────────────────────────────────────────

local function getDeliveryTimeSeconds()
    local seconds = tonumber(MechanicWorkshopData.GetSetting("partsDeliveryTimeSeconds", (Config.PartsDelivery or {}).deliveryTimeSeconds)) or 0
    return math.max(0, math.min(3600, math.floor(seconds)))
end

local function getOpenDurationMs()
    return tonumber(MechanicWorkshopData.GetSetting("partsDeliveryOpenDurationMs", (Config.PartsDelivery or {}).openDurationMs)) or 5500
end

local function getTimerHud()
    local cfg = (Config.PartsDelivery or {}).timerHud or {}
    return {
        enabled = MechanicWorkshopData.GetSetting("partsDeliveryTimerHudEnabled", cfg.enabled) == true,
        position = type(cfg.position) == "table" and cfg.position or {}
    }
end

local function isPaymentMethodEnabled(method)
    local methods = (Config.PartsDelivery or {}).paymentMethods or {}
    local key = method == "company_card" and "partsDeliveryCompanyCard" or "partsDeliveryOwnCard"
    return MechanicWorkshopData.GetSetting(key, methods[method]) ~= false
end

-- ── Company Funds (sky_jobs_base) ────────────────────

local function hasSupplyPermission(src)
    if GetResourceState("sky_jobs_base") ~= "started" then return false end
    local ok, allowed = pcall(function()
        return exports.sky_jobs_base:HasJobPermission(src, "PURCHASE_SUPPLIES")
    end)
    return ok and allowed == true
end

local function removeSocietyMoney(job, amount, reason)
    if GetResourceState("sky_jobs_base") ~= "started" then return false end
    local ok, removed = pcall(function()
        return exports.sky_jobs_base:RemoveSocietyMoney(job, amount, reason)
    end)
    return ok and removed == true
end

local function addSocietyMoney(job, amount, reason)
    if GetResourceState("sky_jobs_base") ~= "started" then return false end
    local ok, added = pcall(function()
        return exports.sky_jobs_base:AddSocietyMoney(job, amount, reason)
    end)
    return ok and added == true
end

-- ── Delivery Points ──────────────────────────────────

local function toPointPayload(point)
    return {
        key = point.key,
        label = point.label,
        coords = { x = point.coords.x, y = point.coords.y, z = point.coords.z },
        heading = point.heading
    }
end

-- The requested point when it belongs to the job, else the job's point nearest to the player.
local function pickJobPoint(src, job, points, requestedKey)
    local ped = GetPlayerPed(src)
    local origin = ped and ped ~= 0 and GetEntityCoords(ped) or nil
    local nearest, nearestDist = nil, nil
    for _, point in ipairs(points) do
        if point.job == nil or point.job == job then
            if point.key == requestedKey then
                return point
            end
            local dist = origin and #(origin - point.coords) or 0.0
            if not nearestDist or dist < nearestDist then
                nearest, nearestDist = point, dist
            end
        end
    end
    return nearest
end

-- The workshop's own delivery bays when the server can read them; otherwise the bay the
-- client picked from the same data.
local function resolveDeliveryPoint(src, job, requested)
    requested = type(requested) == "table" and requested or {}

    local points = MechanicWorkshopData.GetPoints(DELIVERY_POINT_TYPES)
    if points then
        local point = pickJobPoint(src, job, points, requested.key)
        return point and toPointPayload(point) or nil
    end

    local coords = type(requested.coords) == "table" and requested.coords or {}
    local x, y, z = tonumber(coords.x), tonumber(coords.y), tonumber(coords.z)
    if not (x and y and z) then return nil end
    return {
        key = tostring(requested.key or "default"):sub(1, 128),
        label = tostring(requested.label or "Delivery Bay"):sub(1, 64),
        coords = { x = x, y = y, z = z },
        heading = tonumber(requested.heading) or 0.0
    }
end

-- ── Delivery State ───────────────────────────────────

local function markReady(deliveryId, job)
    local affected = MySQL.update.await("UPDATE sky_mechanic_parts_deliveries SET status = 'ready' WHERE id = ? AND status = 'pending'", { deliveryId })
    if (tonumber(affected) or 0) > 0 then
        notifyJob(job)
    end
end

local function scheduleReady(deliveryId, job, seconds)
    SetTimeout(math.max(0, math.floor(tonumber(seconds) or 0)) * 1000, function()
        markReady(deliveryId, job)
    end)
end

-- A carried delivery that is dropped goes back to its delivery bay.
local function releaseHeldCarry(src)
    local held = heldCarry[src]
    if not held then return end
    heldCarry[src] = nil

    local affected = MySQL.update.await("UPDATE sky_mechanic_parts_deliveries SET status = 'ready' WHERE id = ? AND status = 'claiming'", { held.id })
    if (tonumber(affected) or 0) > 0 then
        notifyJob(held.job)
    end
end

local function giveLines(src, lines)
    for index, line in ipairs(lines) do
        if not Functions.AddItem(src, line.name, line.quantity) then
            for undo = 1, index - 1 do
                Functions.RemoveItem(src, lines[undo].name, lines[undo].quantity)
            end
            return false
        end
    end
    return true
end

-- Moves the row from fromStatus to 'claimed' before handing out its items, so two
-- requests for the same delivery cannot both receive them. The third value is true when
-- none of its parts is sold anymore (the row is still closed, nothing is given).
local function completeDelivery(src, row, fromStatus)
    local lines = decodeLines(row.items, row.job)
    for _, line in ipairs(lines) do
        if not Functions.CanCarryItem(src, line.name, line.quantity) then
            return false, "inventory_full"
        end
    end

    local point = decodeJson(row.delivery_point)
    point.claimedByName = Functions.GetName(src)
    point.claimedAt = os.time()

    local affected = MySQL.update.await("UPDATE sky_mechanic_parts_deliveries SET status = 'claimed', delivery_point = ? WHERE id = ? AND status = ?", {
        json.encode(point), row.id, fromStatus
    })
    if (tonumber(affected) or 0) ~= 1 then
        return false, "delivery_not_found"
    end

    if not giveLines(src, lines) then
        MySQL.update.await("UPDATE sky_mechanic_parts_deliveries SET status = ?, delivery_point = ? WHERE id = ? AND status = 'claimed'", {
            fromStatus, row.delivery_point, row.id
        })
        return false, "inventory_full"
    end

    local empty = #lines == 0
    if empty then
        print(("[sky_mechanicjob][parts_delivery] delivery %s held no part any parts shop still sells; it was closed without items"):format(formatOrderUid(row.id)))
    end
    notifyJob(row.job)
    return true, nil, empty
end

-- The box stands at its bay's current place (the client resolves the bay key), so a bay
-- moved in /jobconfig after the order is accepted there too; its box could never be opened.
local function isNearDelivery(src, point)
    if isPlayerNear(src, point.coords, CLAIM_DISTANCE) then return true end
    if type(point.key) ~= "string" then return false end
    for _, current in ipairs(MechanicWorkshopData.GetPoints(DELIVERY_POINT_TYPES) or {}) do
        if current.key == point.key then
            return isPlayerNear(src, current.coords, CLAIM_DISTANCE)
        end
    end
    return false
end

local function findCarryItemName(lines)
    local items = (Config.CarryItems or {}).items or {}
    for _, line in ipairs(lines) do
        local cfg = items[line.name]
        if type(cfg) == "table" and cfg.enabled ~= false then
            return line.name
        end
    end
    return nil
end

local function isPalletMode()
    local pallet = (Config.CarryItems or {}).deliveryPallet
    return MechanicWorkshopData.IsFeatureEnabled("carryItems", false) and type(pallet) == "table" and pallet.enabled ~= false
end

-- ── Get Catalog Callback ─────────────────────────────

Sky.Cb.Register("sky_mechanicjob:partsDelivery:getCatalog", function(source, data)
    local src = tonumber(source)
    if not src or not Functions.IsMechanic(src) then
        return { success = false, error = "not_authorized" }
    end
    if not MechanicWorkshopData.IsFeatureEnabled("partsDelivery", true) then
        return { success = false, error = "feature_disabled" }
    end

    return {
        success = true,
        data = {
            items = getShopCatalog(Functions.GetJob(src)),
            deliveryTimeSeconds = getDeliveryTimeSeconds(),
            canUseCompanyFunds = isPaymentMethodEnabled("company_card") and hasSupplyPermission(src)
        }
    }
end)

-- ── Create Delivery Order Callback ───────────────────

Sky.Cb.Register("sky_mechanicjob:partsDelivery:createOrder", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end
    if not MechanicWorkshopData.IsFeatureEnabled("partsDelivery", true) then
        return { success = false, error = "feature_disabled" }
    end
    if not isMechanicOnDuty(src) then
        return { success = false, error = "not_on_duty" }
    end

    data = type(data) == "table" and data or {}
    local job = Functions.GetJob(src)

    local lines, totalPrice = buildOrderLines(job, data.items)
    if not lines then
        return { success = false, error = "invalid_items" }
    end

    local deliveryPoint = resolveDeliveryPoint(src, job, data.deliveryPoint)
    if not deliveryPoint then
        return { success = false, error = "missing_delivery_location" }
    end

    local paymentMethod = data.paymentMethod == "company_card" and "company_card" or "own_card"
    if not isPaymentMethodEnabled(paymentMethod) then
        return { success = false, error = "payment_method_disabled" }
    end

    local refund = nil
    if totalPrice > 0 then
        if paymentMethod == "company_card" then
            if not hasSupplyPermission(src) then
                return { success = false, error = "insufficient_permissions" }
            end
            if not removeSocietyMoney(job, totalPrice, "Parts delivery order") then
                return { success = false, error = "insufficient_company_funds" }
            end
            refund = function() addSocietyMoney(job, totalPrice, "Parts delivery order refund") end
        else
            local account = nil
            if Functions.RemoveMoney(src, "bank", totalPrice) then
                account = "bank"
            elseif Functions.RemoveMoney(src, "cash", totalPrice) then
                account = "cash"
            end
            if not account then
                return { success = false, error = "insufficient_funds" }
            end
            refund = function() Functions.AddMoney(src, account, totalPrice) end
        end
    end

    local deliveryTimeSeconds = getDeliveryTimeSeconds()
    deliveryPoint.orderedByName = Functions.GetName(src)
    deliveryPoint.paymentMethod = paymentMethod
    deliveryPoint.arrivesAt = os.time() + deliveryTimeSeconds

    local inserted, deliveryId = pcall(MySQL.insert.await, [[
        INSERT INTO sky_mechanic_parts_deliveries (
            job, identifier, delivery_point, items, total_price, status
        ) VALUES (
            @job, @identifier, @delivery_point, @items, @total_price, @status
        )
    ]], {
        ["@job"] = job,
        ["@identifier"] = Functions.GetIdentifier(src),
        ["@delivery_point"] = json.encode(deliveryPoint),
        ["@items"] = json.encode(lines),
        ["@total_price"] = totalPrice,
        ["@status"] = deliveryTimeSeconds > 0 and "pending" or "ready"
    })
    if not inserted then
        -- Usually a sky_mechanic_parts_deliveries table from an older version (db_migrate.lua).
        print(("[sky_mechanicjob][parts_delivery] saving the order failed, the payment was refunded: %s"):format(tostring(deliveryId)))
    end
    deliveryId = inserted and tonumber(deliveryId) or nil
    if not deliveryId or deliveryId <= 0 then
        if refund then refund() end
        return { success = false, error = "order_failed" }
    end

    if deliveryTimeSeconds > 0 then
        scheduleReady(deliveryId, job, deliveryTimeSeconds)
    else
        notifyJob(job)
    end

    return {
        success = true,
        orderId = deliveryId,
        totalPrice = totalPrice,
        data = {
            orderId = deliveryId,
            orderUid = formatOrderUid(deliveryId),
            totalPrice = totalPrice,
            deliveryTimeSeconds = deliveryTimeSeconds,
            timerHud = getTimerHud()
        }
    }
end)

-- ── Get Ready Deliveries Callback ─────────────────────

Sky.Cb.Register("sky_mechanicjob:partsDelivery:getReadyDeliveries", function(source, data)
    local src = tonumber(source)
    if not src or not Functions.IsMechanic(src) then
        return { success = false, error = "not_authorized" }
    end

    local job = Functions.GetJob(src)
    -- The newest 100: with the oldest first, 100 unopened old rows hid every new delivery.
    -- The client still shows the oldest of these first at each bay.
    local rows = MySQL.query.await([[
        SELECT id, delivery_point, items, created_at
        FROM sky_mechanic_parts_deliveries
        WHERE job = ? AND status = 'ready'
        ORDER BY id DESC
        LIMIT 100
    ]], { job }) or {}

    local deliveries = {}
    for _, row in ipairs(rows) do
        local point = decodeJson(row.delivery_point)
        deliveries[#deliveries + 1] = {
            id = row.id,
            orderUid = formatOrderUid(row.id),
            deliveryPointKey = point.key or "default",
            deliveryLabel = point.label,
            coords = point.coords,
            heading = point.heading,
            items = decodeLines(row.items, job),
            createdAt = row.created_at
        }
    end

    return {
        success = true,
        data = {
            deliveries = deliveries,
            openDurationMs = getOpenDurationMs()
        }
    }
end)

-- ── Claim Delivery Callback ───────────────────────────

Sky.Cb.Register("sky_mechanicjob:partsDelivery:claim", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end
    if not isMechanicOnDuty(src) then
        return { success = false, error = "not_on_duty" }
    end

    local deliveryId = math.floor(tonumber(type(data) == "table" and data.deliveryId or nil) or 0)
    if not (deliveryId > 0) then return { success = false, error = "invalid_id" } end

    local job = Functions.GetJob(src)
    local row = MySQL.single.await([[
        SELECT id, job, delivery_point, items FROM sky_mechanic_parts_deliveries
        WHERE id = ? AND job = ? AND status = 'ready' LIMIT 1
    ]], { deliveryId, job })
    if not row then
        return { success = false, error = "delivery_not_found" }
    end

    if not isNearDelivery(src, decodeJson(row.delivery_point)) then
        return { success = false, error = "too_far" }
    end

    releaseHeldCarry(src)

    local carryName = MechanicWorkshopData.IsFeatureEnabled("carryItems", false) and findCarryItemName(decodeLines(row.items, job)) or nil
    if carryName then
        local affected = MySQL.update.await("UPDATE sky_mechanic_parts_deliveries SET status = 'claiming' WHERE id = ? AND job = ? AND status = 'ready'", { deliveryId, job })
        if (tonumber(affected) or 0) ~= 1 then
            return { success = false, error = "delivery_not_found" }
        end
        heldCarry[src] = { id = deliveryId, job = job }
        notifyJob(job)
        return {
            success = true,
            data = {
                deliveryClaimed = true,
                carryItem = { name = carryName, metadata = { deliveryId = deliveryId } }
            }
        }
    end

    local ok, err, empty = completeDelivery(src, row, "ready")
    if not ok then
        return { success = false, error = err }
    end
    return { success = true, data = { deliveryClaimed = true, emptyDelivery = empty == true or nil } }
end)

-- ── Carry Item Actions ────────────────────────────────

Sky.Cb.Register("sky_mechanicjob:carryItem:drop", function(source, data)
    local src = tonumber(source)
    if src then releaseHeldCarry(src) end
    return { success = true }
end)

-- The items come from the delivery the server handed out, never from the client.
Sky.Cb.Register("sky_mechanicjob:carryItem:depositToStorage", function(source, data)
    local src = tonumber(source)
    local held = src and heldCarry[src]
    if not held then
        return { success = false, error = "nothing_held" }
    end

    if not isNearJobPoint(src, held.job, STORAGE_POINT_TYPES, STORAGE_DISTANCE) then
        return { success = false, error = "too_far" }
    end

    local row = MySQL.single.await("SELECT id, job, delivery_point, items FROM sky_mechanic_parts_deliveries WHERE id = ? AND status = 'claiming' LIMIT 1", { held.id })
    if not row then
        heldCarry[src] = nil
        return { success = false, error = "delivery_not_found" }
    end

    local ok, err = completeDelivery(src, row, "claiming")
    if not ok then
        if err == "delivery_not_found" then heldCarry[src] = nil end
        return { success = false, error = err }
    end

    if heldCarry[src] == held then heldCarry[src] = nil end
    return { success = true }
end)

-- A whole delivery pallet brought to storage by forklift (carry items mode).
Sky.Cb.Register("sky_mechanicjob:partsDelivery:depositToStorage", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end
    if not isPalletMode() then
        return { success = false, error = "feature_disabled" }
    end
    if not isMechanicOnDuty(src) then
        return { success = false, error = "not_on_duty" }
    end

    local deliveryId = math.floor(tonumber(type(data) == "table" and data.deliveryId or nil) or 0)
    if not (deliveryId > 0) then return { success = false, error = "invalid_id" } end

    local job = Functions.GetJob(src)
    if not isNearJobPoint(src, job, STORAGE_POINT_TYPES, STORAGE_DISTANCE) then
        return { success = false, error = "too_far" }
    end

    local row = MySQL.single.await([[
        SELECT id, job, delivery_point, items FROM sky_mechanic_parts_deliveries
        WHERE id = ? AND job = ? AND status = 'ready' LIMIT 1
    ]], { deliveryId, job })
    if not row then
        return { success = false, error = "not_found" }
    end

    local ok, err = completeDelivery(src, row, "ready")
    if not ok then
        return { success = false, error = err }
    end
    return { success = true }
end)

-- ── Order History Callback ────────────────────────────

Sky.Cb.Register("sky_mechanicjob:partsDelivery:getOrderHistory", function(source, data)
    local src = tonumber(source)
    if not src or not Functions.IsMechanic(src) then
        return { success = false, error = "not_authorized" }
    end

    local job = Functions.GetJob(src)
    local pageSize = math.max(1, math.min(100, math.floor(tonumber(type(data) == "table" and data.pageSize or nil) or 50)))

    local rows = MySQL.query.await([[
        SELECT id, delivery_point, items, total_price, status, created_at
        FROM sky_mechanic_parts_deliveries
        WHERE job = ?
        ORDER BY id DESC
        LIMIT ?
    ]], { job, pageSize }) or {}

    local orders = {}
    for _, row in ipairs(rows) do
        local point = decodeJson(row.delivery_point)
        orders[#orders + 1] = {
            id = row.id,
            orderUid = formatOrderUid(row.id),
            status = row.status,
            orderedByName = point.orderedByName,
            paymentMethod = point.paymentMethod or "own_card",
            totalPrice = row.total_price,
            createdAt = row.created_at,
            arrivesAt = point.arrivesAt or row.created_at,
            deliveryLabel = point.label,
            claimedByName = point.claimedByName,
            claimedAt = point.claimedAt,
            items = decodeLines(row.items, job)
        }
    end

    return {
        success = true,
        data = {
            orders = orders
        }
    }
end)

-- ── Lifecycle ─────────────────────────────────────────

AddEventHandler("playerDropped", function()
    local src = tonumber(source)
    if src and heldCarry[src] then
        CreateThread(function()
            releaseHeldCarry(src)
        end)
    end
end)

local function isHeld(deliveryId)
    for _, held in pairs(heldCarry) do
        if held.id == deliveryId then return true end
    end
    return false
end

-- Delivery timers and carried deliveries do not survive a restart.
local function recoverDeliveries()
    local rows = MySQL.query.await("SELECT id, job, status, delivery_point FROM sky_mechanic_parts_deliveries WHERE status IN ('pending', 'claiming')") or {}
    local returned = {}
    for _, row in ipairs(rows) do
        if row.status == "pending" then
            local arrivesAt = tonumber(decodeJson(row.delivery_point).arrivesAt) or 0
            scheduleReady(row.id, row.job, arrivesAt - os.time())
        elseif not isHeld(row.id) then
            local affected = MySQL.update.await("UPDATE sky_mechanic_parts_deliveries SET status = 'ready' WHERE id = ? AND status = 'claiming'", { row.id })
            if (tonumber(affected) or 0) > 0 then returned[row.job] = true end
        end
    end
    -- The clients fetched their deliveries at their own start, before these were back.
    for job in pairs(returned) do
        notifyJob(job)
    end
end

CreateThread(function()
    local function run()
        CreateThread(function()
            Wait(5000) -- db_migrate.lua creates the table on a first start
            pcall(recoverDeliveries)
        end)
    end
    if MySQL.ready then
        MySQL.ready(run)
    else
        run()
    end
end)
