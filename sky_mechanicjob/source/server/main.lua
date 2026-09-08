if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/main.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/main.lua
--  Core Tuning Backend, Order Management & Item Handlers
-- =====================================================

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

-- ── Vehicle Price Callback ───────────────────────────

Sky.Cb.Register("sky_mechanicjob:tuning:getVehiclePrice", function(source, data)
    local modelName = data and (data.model or data.name)
    local defaultPrice = 50000

    if modelName and MySQL and MySQL.single and MySQL.single.await then
        local ok, row = pcall(function()
            return MySQL.single.await("SELECT price FROM vehicles WHERE model = @model LIMIT 1", {
                ["@model"] = string.lower(tostring(modelName))
            })
        end)
        if ok and row and row.price and tonumber(row.price) > 0 then
            return { price = tonumber(row.price) }
        end
    end

    return { price = defaultPrice }
end)

-- ── Tuning Purchase & Order Placement ────────────────

Sky.Cb.Register("sky_mechanicjob:tuning:purchase", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    if type(data) ~= "table" then
        return { success = false, error = "invalid_payload" }
    end

    local paymentMethod = tostring(data.paymentMethod or "cash")
    local directApply = data.directApply == true or data.adminDirect == true
    local plate = sanitizePlate(data.plate)
    local model = tostring(data.model or "vehicle")
    local modelLabel = tostring(data.modelLabel or model)
    local entries = type(data.entries) == "table" and data.entries or {}
    local properties = type(data.properties) == "table" and data.properties or nil

    local mechanicJob = Functions.GetJob(src)
    if mechanicJob == "" then mechanicJob = "mechanic" end

    -- Server-Side Pricing Validation (Rewrite)
    local calculatedTotal = 0
    for idx, entry in ipairs(entries) do
        local expectedPrice = Pricing.CalculateOptionCost(mechanicJob, model, entry.id, entry.value, directApply)
        entry.price = expectedPrice
        calculatedTotal = calculatedTotal + expectedPrice
    end
    
    local totalAmount = calculatedTotal

    -- Handle money deduction
    if totalAmount > 0 then
        local hasMoney = false
        if paymentMethod == "society" or paymentMethod == "mechanic_society" then
            -- Society account charge
            local job = Functions.GetJob(src)
            if exports['sky_jobs_base'] and exports['sky_jobs_base'].RemoveSocietyMoney then
                hasMoney = exports['sky_jobs_base']:RemoveSocietyMoney(job, totalAmount)
            else
                hasMoney = Functions.RemoveMoney(src, "bank", totalAmount)
            end
        elseif paymentMethod == "bank" then
            hasMoney = Functions.RemoveMoney(src, "bank", totalAmount)
        else
            hasMoney = Functions.RemoveMoney(src, "cash", totalAmount)
        end

        if not hasMoney then
            return {
                success = false,
                error = "insufficient_funds",
                requestedAmount = totalAmount
            }
        end
    end

    local customerIdentifier = Functions.GetIdentifier(src)
    local customerName = Functions.GetName(src)
    local mechanicJob = Functions.GetJob(src)
    if mechanicJob == "" then mechanicJob = "mechanic" end

    -- Direct application (instant tuning or admin tuning)
    if directApply then
        if properties and plate ~= "" then
            TuningDB.SaveVehicleProperties(plate, properties)
        end

        VehicleHistory.Add(
            plate,
            "tuning_direct",
            string.format("Direct tuning applied (%d modifications)", #entries),
            src,
            totalAmount
        )

        return {
            success = true,
            appliedDirect = true,
            resultAmount = totalAmount,
            total = totalAmount
        }
    end

    -- Create order for mechanic installation
    local orderItems = {}
    for idx, entry in ipairs(entries) do
        orderItems[#orderItems + 1] = {
            index = idx,
            id = entry.id,
            label = entry.label or entry.id,
            value = entry.value,
            valueLabel = entry.valueLabel or tostring(entry.value),
            price = entry.price or 0,
            requiredItem = entry.requiredItem or "body_kit",
            installed = false,
            section = entry.section or "appearance",
            flow = entry.flow or "performance",
            paintType = entry.paintType,
            customColor = entry.customColor,
            customHandling = entry.customHandling
        }
    end

    local orderId = MySQL.insert.await([[
        INSERT INTO sky_mechanic_orders (
            job, customer_identifier, customer_name, plate, vehicle_model, vehicle_label, items, price, status, paid
        ) VALUES (
            @job, @customer_identifier, @customer_name, @plate, @vehicle_model, @vehicle_label, @items, @price, 'pending', 1
        )
    ]], {
        ["@job"] = mechanicJob,
        ["@customer_identifier"] = customerIdentifier,
        ["@customer_name"] = customerName,
        ["@plate"] = plate,
        ["@vehicle_model"] = model,
        ["@vehicle_label"] = modelLabel,
        ["@items"] = json.encode(orderItems),
        ["@price"] = totalAmount
    })

    if not orderId or orderId <= 0 then
        return { success = false, error = "order_creation_failed" }
    end

    VehicleHistory.Add(
        plate,
        "order_created",
        string.format("Order #%d created with %d parts", orderId, #orderItems),
        src,
        totalAmount
    )

    return {
        success = true,
        order = orderId,
        resultAmount = totalAmount,
        total = totalAmount
    }
end)

-- ── Tuning Removal System ─────────────────────────────

Sky.Cb.Register("sky_mechanicjob:tuning:getRemovalPreview", function(source, data)
    local section = tostring(data and data.section or "")
    local requiredItem = "mechanic_tools"
    local returnItem = "body_kit"
    local flow = "hood_install"

    if section == "wheels" then
        returnItem = "wheels"
        flow = "wheel"
    elseif section == "engine" or section == "performance" then
        returnItem = "engine"
        flow = "hood_install"
    elseif section == "brakes" then
        returnItem = "brakes"
        flow = "wheel"
    elseif section == "suspension" then
        returnItem = "suspension"
        flow = "wheel"
    elseif section == "transmission" then
        returnItem = "transmission"
        flow = "hood_install"
    end

    return {
        success = true,
        data = {
            requiredItem = requiredItem,
            returnItem = returnItem,
            flow = flow
        }
    }
end)

Sky.Cb.Register("sky_mechanicjob:tuning:prepareRemoval", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    if not Functions.IsOnDuty(src) then
        return { success = false, error = "not_on_duty" }
    end

    local section = tostring(data and data.section or "")
    local requiredItem = "mechanic_tools"

    if not Functions.HasItem(src, requiredItem, 1) then
        return {
            success = false,
            error = "missing_item",
            requiredItem = requiredItem
        }
    end

    local flow = "hood_install"
    if section == "wheels" or section == "brakes" or section == "suspension" then
        flow = "wheel"
    end

    return {
        success = true,
        data = {
            requiredItem = requiredItem,
            flow = flow
        }
    }
end)

Sky.Cb.Register("sky_mechanicjob:tuning:completeRemoval", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local plate = sanitizePlate(data and data.plate)
    local label = tostring(data and data.label or "Tuning part")
    local section = tostring(data and data.section or "")

    local returnItem = "body_kit"
    if section == "wheels" then returnItem = "wheels"
    elseif section == "engine" or section == "performance" then returnItem = "engine"
    elseif section == "brakes" then returnItem = "brakes"
    elseif section == "suspension" then returnItem = "suspension"
    elseif section == "transmission" then returnItem = "transmission"
    end

    -- Reward disassembled part back to mechanic
    Functions.AddItem(src, returnItem, 1)

    if plate ~= "" then
        VehicleHistory.Add(
            plate,
            "tuning_removed",
            string.format("Removed: %s", label),
            src,
            0
        )
    end

    return {
        success = true,
        data = {
            returnItem = returnItem
        }
    }
end)

-- ── Order Tablet RPCs ────────────────────────────────

Sky.Cb.Register("sky_mechanicjob:orders:getAll", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end
    local jobName = Functions.GetJob(src)
    if jobName == "" or jobName == "unemployed" then
        jobName = (data and data.job) or "mechanic"
    end

    local page = math.max(1, math.floor(tonumber(data and data.page) or 1))
    local pageSize = math.max(1, math.min(100, math.floor(tonumber(data and data.pageSize) or 20)))
    local search = tostring(data and data.search or "")
    local offset = (page - 1) * pageSize

    local query = "SELECT * FROM sky_mechanic_orders WHERE status IN ('pending', 'in_progress') AND job = @job"
    local countQuery = "SELECT COUNT(*) as count FROM sky_mechanic_orders WHERE status IN ('pending', 'in_progress') AND job = @job"
    local params = { ["@job"] = jobName }

    if search ~= "" then
        query = query .. " AND (plate LIKE @search OR customer_name LIKE @search OR vehicle_model LIKE @search)"
        countQuery = countQuery .. " AND (plate LIKE @search OR customer_name LIKE @search OR vehicle_model LIKE @search)"
        params["@search"] = "%" .. search .. "%"
    end

    query = query .. " ORDER BY id DESC LIMIT " .. pageSize .. " OFFSET " .. offset

    local rows = MySQL.query.await(query, params) or {}
    local countRow = MySQL.single.await(countQuery, params)
    local totalCount = countRow and countRow.count or #rows

    local orders = {}
    for _, row in ipairs(rows) do
        local custName = row.customer_name
        if not custName or custName == "" or custName == "Unknown" then
            if row.customer_identifier and row.customer_identifier ~= "" then
                local custSrc = Functions.GetPlayer(row.customer_identifier)
                if custSrc then
                    custName = Functions.GetName(custSrc)
                end
            end
        end
        if not custName or custName == "" or custName == "Unknown" then
            custName = GetPlayerName(src) or "Customer"
        end

        orders[#orders + 1] = {
            id = row.id,
            job = row.job,
            customerIdentifier = row.customer_identifier,
            customerName = custName,
            plate = row.plate,
            vehicleModel = row.vehicle_model,
            vehicleLabel = row.vehicle_label,
            items = (row.items and type(row.items) == "string" and row.items ~= "") and (pcall(json.decode, row.items) and json.decode(row.items) or {}) or {},
            price = row.price,
            status = row.status,
            paid = row.paid == 1 or row.paid == true,
            createdAt = row.created_at
        }
    end

    return {
        success = true,
        data = {
            orders = orders,
            total = totalCount
        }
    }
end)

Sky.Cb.Register("sky_mechanicjob:orders:refund", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end
    if not Functions.IsOnDuty(src) then return { success = false, error = "not_on_duty" } end
    if not Functions.IsMechanic(src) then return { success = false, error = "unauthorized" } end
    local jobName = Functions.GetJob(src)
    if jobName == "" or jobName == "unemployed" then jobName = "mechanic" end

    local orderId = math.floor(tonumber(data and (data.orderId or data.id or data.order)) or 0)
    if orderId <= 0 then return { success = false, error = "invalid_id" } end

    local order = MySQL.single.await("SELECT * FROM sky_mechanic_orders WHERE id = @id LIMIT 1", { ["@id"] = orderId })
    if not order then return { success = false, error = "not_found" } end
    if order.status == "refunded" then return { success = false, error = "already_refunded" } end

    -- Resolve the recipient up-front: only online players can be paid back.
    -- For a paid order, bail out WITHOUT touching the row when the customer is
    -- offline so the mechanic can retry once they are online.
    local mustPay = order.price > 0 and (order.paid == 1 or order.paid == true)
    local customerSrc = nil
    if mustPay then
        customerSrc = Functions.GetSourceByIdentifier(order.customer_identifier)
        if not customerSrc then
            return { success = false, error = "customer_offline" }
        end
    end

    -- Atomically claim the refund. The conditional UPDATE + affected-row check
    -- closes the read-then-write race: only one concurrent caller can flip the
    -- status, so the customer can never be paid twice.
    local affected = MySQL.update.await(
        "UPDATE sky_mechanic_orders SET status = 'refunded', paid = 0 WHERE id = @id AND status <> 'refunded'",
        { ["@id"] = orderId }
    )
    if not affected or affected == 0 then
        return { success = false, error = "already_refunded" }
    end

    if mustPay and customerSrc then
        Functions.AddMoney(customerSrc, "bank", order.price)
        Functions.ShowNotification(customerSrc, "Mechanic", string.format("Order #%d refunded ($%d).", orderId, order.price), "info")
    end

    VehicleHistory.Add(
        order.plate,
        "order_refunded",
        string.format("Order #%d was refunded ($%d)", orderId, order.price),
        source,
        order.price
    )

    return { success = true }
end)

Sky.Cb.Register("sky_mechanicjob:orders:delete", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end
    if not Functions.IsOnDuty(src) then return { success = false, error = "not_on_duty" } end
    if not Functions.IsMechanic(src) then return { success = false, error = "unauthorized" } end

    local orderId = math.floor(tonumber(data and (data.orderId or data.id or data.order or data.orderUID or data.uid)) or 0)
    if orderId > 0 then
        MySQL.query.await("DELETE FROM sky_mechanic_orders WHERE id = @id", { ["@id"] = orderId })
        return { success = true }
    end

    local plate = sanitizePlate(data and data.plate)
    if plate ~= "" then
        MySQL.query.await("DELETE FROM sky_mechanic_orders WHERE plate = @plate AND status IN ('pending', 'in_progress') ORDER BY id DESC LIMIT 1", { ["@plate"] = plate })
        return { success = true }
    end

    return { success = false, error = "invalid_id" }
end)

Sky.Cb.Register("sky_mechanicjob:orders:prepareInstall", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local orderId = math.floor(tonumber(data and data.orderId) or 0)
    local partIndex = math.floor(tonumber(data and data.partIndex) or 0)

    if orderId <= 0 or partIndex <= 0 then
        return { success = false, error = "invalid_payload" }
    end

    local order = MySQL.single.await("SELECT * FROM sky_mechanic_orders WHERE id = @id LIMIT 1", { ["@id"] = orderId })
    if not order then
        return { success = false, error = "order_not_found" }
    end
    local jobName = Functions.GetJob(src)
    if jobName == "" or jobName == "unemployed" then jobName = "mechanic" end
    if order.job ~= jobName and not Functions.IsMechanic(src) then
        return { success = false, error = "unauthorized" }
    end

    local items = order.items and json.decode(order.items) or {}
    local part = items[partIndex]

    if not part then
        return { success = false, error = "part_not_found" }
    end

    if part.installed == true then
        return { success = false, error = "already_installed" }
    end

    local reqItem = tostring(part.requiredItem or "body_kit")
    if not Functions.HasItem(src, reqItem, 1) then
        return {
            success = false,
            error = "missing_item",
            requiredItem = reqItem
        }
    end

    return {
        success = true,
        data = {
            part = part,
            requiredItem = reqItem,
            removeRequiredItemAfterUse = true,
            flow = part.flow or "performance"
        }
    }
end)

Sky.Cb.Register("sky_mechanicjob:orders:completeInstall", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local orderId = math.floor(tonumber(data and data.orderId) or 0)
    local partIndex = math.floor(tonumber(data and data.partIndex) or 0)
    local plate = sanitizePlate(data and data.plate)

    local order = MySQL.single.await("SELECT * FROM sky_mechanic_orders WHERE id = @id LIMIT 1", { ["@id"] = orderId })
    if not order then return { success = false, error = "order_not_found" } end

    local jobName = Functions.GetJob(src)
    if jobName == "" or jobName == "unemployed" then jobName = "mechanic" end
    if order.job ~= jobName and not Functions.IsMechanic(src) then return { success = false, error = "unauthorized" } end

    local items = order.items and json.decode(order.items) or {}
    local part = items[partIndex]

    if not part then return { success = false, error = "part_not_found" } end

    local reqItem = tostring(part.requiredItem or "body_kit")
    if not Functions.RemoveItem(src, reqItem, 1) then
        return { success = false, error = "missing_item", requiredItem = reqItem }
    end

    part.installed = true
    items[partIndex] = part

    local allInstalled = true
    for _, it in ipairs(items) do
        if it.installed ~= true then
            allInstalled = false
            break
        end
    end

    local newStatus = allInstalled and "completed" or "in_progress"
    MySQL.query.await([[
        UPDATE sky_mechanic_orders
        SET items = @items, status = @status
        WHERE id = @id
    ]], {
        ["@items"] = json.encode(items),
        ["@status"] = newStatus,
        ["@id"] = orderId
    })

    VehicleHistory.Add(
        order.plate,
        "part_installed",
        string.format("Installed: %s (Order #%d)", part.label or part.id, orderId),
        src,
        part.price or 0
    )

    return {
        success = true,
        data = {
            completed = allInstalled
        }
    }
end)

-- ── Usable Items Setup ────────────────────────────────

local function setupUsableItems()
    Functions.RegisterUsableItem("spray_can", function(source)
        TriggerClientEvent("sky_mechanicjob:vehicleCare:start", source, "spray_paint")
    end)

    Functions.RegisterUsableItem("wash_sponge", function(source)
        TriggerClientEvent("sky_mechanicjob:vehicleCare:start", source, "wash")
    end)

    Functions.RegisterUsableItem("vehicle_wax", function(source)
        TriggerClientEvent("sky_mechanicjob:vehicleCare:start", source, "wax")
    end)

    Functions.RegisterUsableItem("fix_kit", function(source)
        TriggerClientEvent("sky_mechanicjob:vehicleCare:start", source, "repair")
    end)

    Functions.RegisterUsableItem("repair_kit", function(source)
        TriggerClientEvent("sky_mechanicjob:vehicleCare:start", source, "repair")
    end)

    Functions.RegisterUsableItem("stance_kit", function(source)
        TriggerClientEvent("sky_mechanicjob:tuning:openStancing", source)
    end)

    Functions.RegisterUsableItem("rgb_controller", function(source)
        TriggerClientEvent("sky_mechanicjob:tuning:openRgbController", source)
    end)

    Functions.RegisterUsableItem("nitro_kit", function(source)
        TriggerClientEvent("sky_mechanicjob:nitro:beginInstall", source)
    end)

    Functions.RegisterUsableItem("lug_wrench", function(source)
        TriggerClientEvent("sky_mechanicjob:lugWrench:chooseTheft", source)
    end)

    Functions.RegisterUsableItem("mechanic_tools", function(source)
        TriggerClientEvent("sky_mechanicjob:lugWrench:chooseTheft", source)
    end)
end

CreateThread(function()
    setupUsableItems()
end)
