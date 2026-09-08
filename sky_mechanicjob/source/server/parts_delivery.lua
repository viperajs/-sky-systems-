if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/parts_delivery.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/parts_delivery.lua
--  Parts Delivery Shop, Warehouse Logistics & Pallet Claims
-- =====================================================

local function getShopCatalog()
    local catalog = {}
    for _, job in ipairs(Config.Jobs or {}) do
        local shop = job.partsDeliveryShop or job.shop or {}
        for _, item in ipairs(shop) do
            catalog[#catalog + 1] = {
                name = item.name,
                label = item.label or item.name,
                price = item.price or 100,
                category = item.category or "General"
            }
        end
        break
    end
    return catalog
end

-- ── Get Catalog Callback ─────────────────────────────

Sky.Cb.Register("sky_mechanicjob:partsDelivery:getCatalog", function(source, data)
    return {
        success = true,
        data = {
            items = getShopCatalog()
        }
    }
end)

-- ── Create Delivery Order Callback ───────────────────

Sky.Cb.Register("sky_mechanicjob:partsDelivery:createOrder", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local items = type(data and data.items) == "table" and data.items or {}
    local paymentMethod = tostring(data and data.paymentMethod or "own_card")
    local deliveryPoint = type(data and data.deliveryPoint) == "table" and data.deliveryPoint or nil

    if #items == 0 or not deliveryPoint then
        return { success = false, error = "invalid_payload" }
    end

    -- Calculate total price
    local totalPrice = 0
    local catalog = getShopCatalog()
    local catalogPriceMap = {}
    for _, it in ipairs(catalog) do
        catalogPriceMap[it.name] = it.price
    end

    for _, it in ipairs(items) do
        local unitPrice = catalogPriceMap[it.name] or tonumber(it.price) or 100
        local count = math.max(1, math.floor(tonumber(it.count or it.amount) or 1))
        totalPrice = totalPrice + (unitPrice * count)
    end

    -- Deduct payment
    if totalPrice > 0 then
        local paid = false
        if paymentMethod == "society" or paymentMethod == "mechanic_society" then
            local job = Functions.GetJob(src)
            if exports['sky_jobs_base'] and exports['sky_jobs_base'].RemoveSocietyMoney then
                paid = exports['sky_jobs_base']:RemoveSocietyMoney(job, totalPrice)
            else
                paid = Functions.RemoveMoney(src, "bank", totalPrice)
            end
        else
            paid = Functions.RemoveMoney(src, "bank", totalPrice)
            if not paid then
                paid = Functions.RemoveMoney(src, "cash", totalPrice)
            end
        end

        if not paid then
            return { success = false, error = "insufficient_funds" }
        end
    end

    local identifier = Functions.GetIdentifier(src)
    local jobName = Functions.GetJob(src)
    if jobName == "" then jobName = "mechanic" end

    local deliveryId = MySQL.insert.await([[
        INSERT INTO sky_mechanic_parts_deliveries (
            job, identifier, delivery_point, items, total_price, status
        ) VALUES (
            @job, @identifier, @delivery_point, @items, @total_price, 'ready'
        )
    ]], {
        ["@job"] = jobName,
        ["@identifier"] = identifier,
        ["@delivery_point"] = json.encode(deliveryPoint),
        ["@items"] = json.encode(items),
        ["@total_price"] = totalPrice
    })

    TriggerClientEvent("sky_mechanicjob:partsDelivery:readyDeliveriesChanged", -1)

    return {
        success = true,
        orderId = deliveryId,
        totalPrice = totalPrice
    }
end)

-- ── Get Ready Deliveries Callback ─────────────────────

Sky.Cb.Register("sky_mechanicjob:partsDelivery:getReadyDeliveries", function(source, data)
    local rows = MySQL.query.await([[
        SELECT id, job, identifier, delivery_point, items, total_price, status, created_at
        FROM sky_mechanic_parts_deliveries
        WHERE status = 'ready'
        ORDER BY id ASC
        LIMIT 100
    ]]) or {}

    local deliveries = {}
    for _, row in ipairs(rows) do
        local point = row.delivery_point and json.decode(row.delivery_point) or {}
        local items = row.items and json.decode(row.items) or {}

        deliveries[#deliveries + 1] = {
            id = row.id,
            job = row.job,
            identifier = row.identifier,
            point = point,
            deliveryPointKey = point.key or "default",
            coords = point.coords,
            heading = point.heading,
            items = items,
            totalPrice = row.total_price,
            status = row.status,
            createdAt = row.created_at
        }
    end

    return {
        success = true,
        data = {
            deliveries = deliveries
        }
    }
end)

-- ── Claim Delivery Callback ───────────────────────────

Sky.Cb.Register("sky_mechanicjob:partsDelivery:claim", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local deliveryId = math.floor(tonumber(data and data.deliveryId) or 0)
    if deliveryId <= 0 then return { success = false, error = "invalid_id" } end

    local delivery = MySQL.single.await([[
        SELECT * FROM sky_mechanic_parts_deliveries
        WHERE id = @id AND status = 'ready' LIMIT 1
    ]], { ["@id"] = deliveryId })

    if not delivery then
        return { success = false, error = "delivery_not_found" }
    end

    local items = delivery.items and json.decode(delivery.items) or {}

    -- Direct inventory reward
    for _, it in ipairs(items) do
        local count = math.max(1, math.floor(tonumber(it.count or it.amount or it.quantity) or 1))
        local itName = tostring(it.name or "")
        if itName ~= "" then
            Functions.AddItem(src, itName, count)
        end
    end

    MySQL.query.await("UPDATE sky_mechanic_parts_deliveries SET status = 'claimed' WHERE id = @id", { ["@id"] = deliveryId })
    TriggerClientEvent("sky_mechanicjob:partsDelivery:readyDeliveriesChanged", -1)

    return {
        success = true,
        data = {
            deliveryClaimed = true
        }
    }
end)

-- ── Carry Item Actions ────────────────────────────────

Sky.Cb.Register("sky_mechanicjob:carryItem:drop", function(source, data)
    return { success = true }
end)

Sky.Cb.Register("sky_mechanicjob:carryItem:depositToStorage", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local metadata = type(data and data.metadata) == "table" and data.metadata or nil
    if metadata and type(metadata.items) == "table" then
        for _, it in ipairs(metadata.items) do
            local count = math.max(1, math.floor(tonumber(it.count or it.amount or it.quantity) or 1))
            local itName = tostring(it.name or "")
            if itName ~= "" then
                Functions.AddItem(src, itName, count)
            end
        end
    end

    return { success = true }
end)

Sky.Cb.Register("sky_mechanicjob:partsDelivery:depositToStorage", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local deliveryId = math.floor(tonumber(data and data.deliveryId) or 0)
    if deliveryId <= 0 then return { success = false, error = "invalid_id" } end

    local delivery = MySQL.single.await([[
        SELECT * FROM sky_mechanic_parts_deliveries
        WHERE id = @id LIMIT 1
    ]], { ["@id"] = deliveryId })

    if not delivery then return { success = false, error = "not_found" } end

    local items = delivery.items and json.decode(delivery.items) or {}
    for _, it in ipairs(items) do
        local count = math.max(1, math.floor(tonumber(it.count or it.amount or it.quantity) or 1))
        local itName = tostring(it.name or "")
        if itName ~= "" then
            Functions.AddItem(src, itName, count)
        end
    end

    MySQL.query.await("UPDATE sky_mechanic_parts_deliveries SET status = 'deposited' WHERE id = @id", { ["@id"] = deliveryId })
    TriggerClientEvent("sky_mechanicjob:partsDelivery:readyDeliveriesChanged", -1)

    return { success = true }
end)

Sky.Cb.Register("sky_mechanicjob:partsDelivery:getOrderHistory", function(source, data)
    local src = tonumber(source)
    local pageSize = math.max(1, math.min(100, math.floor(tonumber(data and data.pageSize) or 50)))

    local rows = MySQL.query.await([[
        SELECT id, job, identifier, delivery_point, total_price, status, created_at, items
        FROM sky_mechanic_parts_deliveries
        ORDER BY id DESC
        LIMIT @limit
    ]], { ["@limit"] = pageSize }) or {}

    local history = {}
    for _, row in ipairs(rows) do
        local buyerName = nil
        if row.identifier and row.identifier ~= "" then
            local custSrc = Functions.GetPlayer(row.identifier)
            if custSrc then
                buyerName = Functions.GetName(custSrc)
            end
        end
        if not buyerName or buyerName == "" or buyerName == "Unknown" then
            buyerName = (src and GetPlayerName(src)) or "Customer"
        end

        history[#history + 1] = {
            id = row.id,
            job = row.job,
            identifier = row.identifier,
            customerName = buyerName,
            buyer = buyerName,
            buyerName = buyerName,
            purchasedBy = buyerName,
            totalPrice = row.total_price,
            price = row.total_price,
            status = row.status,
            createdAt = row.created_at,
            readyAt = row.created_at,
            deliveryPoint = row.delivery_point and (pcall(json.decode, row.delivery_point) and json.decode(row.delivery_point) or {}) or {},
            items = (row.items and type(row.items) == "string" and row.items ~= "") and (pcall(json.decode, row.items) and json.decode(row.items) or {}) or {}
        }
    end

    return {
        success = true,
        data = {
            orders = history
        }
    }
end)
