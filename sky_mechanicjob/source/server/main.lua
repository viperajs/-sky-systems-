if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/main.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/main.lua
--  Core Tuning Backend, Order Management & Item Handlers
-- =====================================================

local MAX_ORDER_PARTS = 150
local ORDER_VEHICLE_DISTANCE = 20.0
local REMOVAL_TOOL_ITEM = "mechanic_tools"
local REMOVAL_TIMEOUT_SECONDS = 900
local ITEM_SESSION_SECONDS = 900

local function sanitizePlate(plate)
    local clean = Functions.NormalizePlate(plate)
    if #clean > 12 then return "" end
    return clean
end

local function shortText(value, maxLength)
    if type(value) ~= "string" and type(value) ~= "number" then return nil end
    local text = tostring(value)
    if #text > maxLength then text = text:sub(1, maxLength) end
    return text
end

local function decodeItems(raw)
    if type(raw) ~= "string" or raw == "" then return {} end
    local ok, decoded = pcall(json.decode, raw)
    return ok and type(decoded) == "table" and decoded or {}
end

local function getOwnMechanicJob(src)
    local job = Functions.GetJob(src)
    return Functions.IsMechanicJobName(job) and job or nil
end

-- Workshop of an order: the requested workshop when it is a mechanic job, else the buyer's own
-- mechanic job, else the first Config.Jobs entry.
local function resolveWorkshopJob(src, requested)
    if type(requested) == "string" and Functions.IsMechanicJobName(requested) then
        return requested
    end
    local own = getOwnMechanicJob(src)
    if own then return own end
    local first = Config and Config.Jobs and Config.Jobs[1]
    return type(first) == "table" and first.name or "mechanic"
end

-- ── Item sessions (stance_kit / rgb_controller open the menu in free mode) ─────────

local itemSessions = {}

local ITEM_SESSION_OPTIONS = {
    rgb_controller = {
        toggle_22 = true, xenon_color = true, neon_0 = true, neon_1 = true, neon_2 = true, neon_3 = true,
        neon_color = true, neon_effect = true, neon_effect_speed = true, xenon_effect = true, xenon_effect_speed = true
    },
    stancing = { stancer_bundle = true }
}

local function getItemSessionMode(src, requestedMode)
    local session = itemSessions[src]
    if not session or session.expiresAt < os.time() then
        itemSessions[src] = nil
        return nil
    end
    if requestedMode ~= nil and requestedMode ~= session.mode then return nil end
    return session.mode
end

-- ── Instant tuning ─────────────────────────────────

local function isJobAllowedAtLocation(src, location, root)
    local allowed = location.allowedJobs or location.jobs or root.allowedJobs or root.jobs
    if type(allowed) == "table" and next(allowed) then
        local job = Functions.GetJob(src)
        for _, name in ipairs(allowed) do
            if name == job then return true end
        end
        return false
    end
    if location.mechanicOnly == true or root.mechanicOnly == true then
        return Functions.IsMechanic(src)
    end
    return true
end

local function isAtInstantTuningLocation(src)
    if not Pricing.IsFeatureEnabled("instantTuning") then return false end

    local root = Config and Config.InstantTuning or {}
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end
    local origin = GetEntityCoords(ped)

    for _, location in ipairs(type(root.locations) == "table" and root.locations or {}) do
        if type(location) == "table" then
            local coords = location.coords or location
            local x, y, z = tonumber(coords.x), tonumber(coords.y), tonumber(coords.z)
            if x and y and z then
                -- The player sits in the vehicle on the point; allow for the vehicle's size.
                local maxDist = (tonumber(location.interactionDistance or root.interactionDistance) or 4.0) + 6.0
                if #(origin - vector3(x, y, z)) <= maxDist and isJobAllowedAtLocation(src, location, root) then
                    return true
                end
            end
        end
    end
    return false
end

-- ── Direct apply: only the purchased parts are taken from the client's snapshot ─────

local ENTRY_PROPERTY_KEYS = {
    xenon_color = { "xenonColor", "customXenonColor" },
    neon_color = { "neonColor" },
    tire_smoke_color = { "tyreSmokeColor" },
    color_primary = { "color1", "customPrimaryColor", "paintType1" },
    color_secondary = { "color2", "customSecondaryColor", "paintType2" },
    color_pearlescent = { "pearlescentColor" },
    color_wheel = { "wheelColor" },
    color_dashboard = { "dashboardColor" },
    color_interior = { "interiorColor" },
    window_tint = { "windowTint" },
    plate_index = { "plateIndex" },
    livery = { "livery", "modLivery" },
    wheel_type = { "wheels" },
    wheel_custom_23 = { "modCustomFrontWheels", "modCustomTiresF" },
    wheel_custom_24 = { "modCustomBackWheels", "modCustomTiresR" }
}

local function filterPropertiesForParts(properties, parts)
    local keys = Sky.VehiclePropertyKeys
    local result = { mods = {}, toggleMods = {} }

    for _, part in ipairs(parts) do
        local id = part.id
        local modType = tonumber(id:match("^mod_(%d+)$"))
        local toggleType = tonumber(id:match("^toggle_(%d+)$"))
        local neonIndex = tonumber(id:match("^neon_([0-3])$"))
        local extraId = id:match("^extra_(%d+)$")
        local value = tonumber(part.value)

        if modType and value then
            result.mods[tostring(modType)] = math.floor(value)
            if keys.mods[modType] then result[keys.mods[modType]] = math.floor(value) end
            if modType == 23 or modType == 24 then
                result.wheels = tonumber(part.wheelType) or properties.wheels
            end
        elseif toggleType and value then
            result.toggleMods[tostring(toggleType)] = value == 1
            if keys.toggles[toggleType] then result[keys.toggles[toggleType]] = value == 1 end
        elseif neonIndex and type(properties.neonEnabled) == "table" then
            result.neonEnabled = properties.neonEnabled
        elseif extraId and type(properties.extras) == "table" then
            result.extras = result.extras or {}
            result.extras[extraId] = properties.extras[extraId]
        elseif ENTRY_PROPERTY_KEYS[id] then
            for _, key in ipairs(ENTRY_PROPERTY_KEYS[id]) do
                result[key] = properties[key]
            end
        end
    end

    if next(result.mods) == nil then result.mods = nil end
    if next(result.toggleMods) == nil then result.toggleMods = nil end
    return result
end

-- ── Vehicle Price Callback ───────────────────────────

Sky.Cb.Register("sky_mechanicjob:tuning:getVehiclePrice", function(source, data)
    local modelName = type(data) == "table" and (data.model or data.name) or nil
    local modelHash = type(data) == "table" and tonumber(data.modelHash) or nil
    local price = Pricing.GetVehiclePrice(modelName, modelHash)
        or math.floor(tonumber(Pricing.GetSetting("fallbackVehicleValue")) or 50000)
    return { price = price }
end)

-- ── Tuning Purchase & Order Placement ────────────────

Sky.Cb.Register("sky_mechanicjob:tuning:purchase", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end
    if type(data) ~= "table" then return { success = false, error = "invalid_payload" } end

    local entries = type(data.parts) == "table" and data.parts or (type(data.entries) == "table" and data.entries) or {}
    if #entries == 0 or #entries > MAX_ORDER_PARTS then
        return { success = false, error = "invalid_payload" }
    end

    local plate = sanitizePlate(data.plate)
    local vehicle = plate ~= "" and Functions.GetNearbyVehicleByPlate(src, plate, 15.0) or nil
    if not vehicle then
        return { success = false, error = "vehicle_not_found" }
    end
    local modelHash = GetEntityModel(vehicle)

    local method = tostring(data.method or data.paymentMethod or "cash"):lower()
    local paymentMethod = "cash"
    if method == "society" or method == "company_card" or method == "mechanic_society" then
        paymentMethod = "society"
    elseif method == "card" or method == "bank" or method == "own_card" then
        paymentMethod = "bank"
    end

    local adminRequested = data.adminMode == true or data.directApply == true or data.adminDirect == true
    local isAdmin = adminRequested and Functions.HasPermission(src, "admintuning")
    local itemMode = adminRequested and not isAdmin and getItemSessionMode(src, data.mode) or nil
    if adminRequested and not isAdmin and not itemMode then
        return { success = false, error = "not_authorized" }
    end

    local isInstant = not adminRequested and data.instantTuning == true
    if isInstant and not isAtInstantTuningLocation(src) then
        return { success = false, error = "not_authorized" }
    end

    local directApply = isAdmin or itemMode ~= nil or isInstant
    if directApply and type(data.properties) ~= "table" then
        return { success = false, error = "invalid_payload" }
    end

    local workshopJob = resolveWorkshopJob(src, data.societyJob)
    local ctx = Pricing.NewContext(workshopJob, modelHash, {
        instant = isInstant,
        free = isAdmin or itemMode ~= nil or Pricing.IsFreeVehicle(modelHash)
    })

    local orderItems = {}
    local totalAmount = 0
    for idx, entry in ipairs(entries) do
        if type(entry) ~= "table" then return { success = false, error = "invalid_part" } end
        local optionId = tostring(entry.id or "")
        if itemMode and not ITEM_SESSION_OPTIONS[itemMode][optionId] then
            return { success = false, error = "not_authorized" }
        end

        local priced, err = Pricing.PriceEntry(ctx, optionId, entry.value, entry.wheelType)
        if not priced then
            return { success = false, error = err or "invalid_part", part = optionId }
        end
        totalAmount = totalAmount + priced.price

        local customColor = nil
        if type(entry.customColor) == "table" then
            customColor = {
                r = math.floor(math.max(0, math.min(255, tonumber(entry.customColor.r) or 0))),
                g = math.floor(math.max(0, math.min(255, tonumber(entry.customColor.g) or 0))),
                b = math.floor(math.max(0, math.min(255, tonumber(entry.customColor.b) or 0)))
            }
        end

        local value = entry.value
        if type(value) == "table" then
            local clean = {}
            for key, subValue in pairs(value) do
                if type(key) == "string" and key:find("^[%w_]+$") and tonumber(subValue) then
                    clean[key] = tonumber(subValue)
                end
            end
            value = clean
        else
            value = tonumber(value)
        end

        orderItems[#orderItems + 1] = {
            index = idx,
            id = optionId,
            label = shortText(entry.label, 80) or optionId,
            value = value,
            valueLabel = shortText(entry.valueLabel, 80) or tostring(entry.value),
            wheelType = tonumber(entry.wheelType),
            price = priced.price,
            requiredItem = priced.requiredItem,
            removeAfterUse = priced.removeAfterUse,
            installed = false,
            section = shortText(entry.section, 32),
            paintType = tonumber(entry.paintType),
            customColor = customColor
        }
    end

    -- A stance kit is used up by the stance it installs.
    if itemMode == "stancing" then
        if not Functions.RemoveItem(src, "stance_kit", 1) then
            return { success = false, error = "missing_item", requiredItem = "stance_kit" }
        end
        itemSessions[src] = nil
    end

    -- Take the money first; every later failure refunds it.
    local payerJob = nil
    if totalAmount > 0 then
        local paid = false
        if paymentMethod == "society" then
            paid, payerJob = Functions.ChargeSociety(src, totalAmount, ("Vehicle tuning %s"):format(plate))
        else
            paid = Functions.RemoveMoney(src, paymentMethod, totalAmount)
        end
        if not paid then
            return { success = false, error = "insufficient_funds", requestedAmount = totalAmount }
        end
    end

    local function refundPayment()
        if totalAmount <= 0 then return end
        if paymentMethod == "society" then
            Functions.AddSocietyMoney(payerJob, totalAmount, ("Refund: vehicle tuning %s"):format(plate))
        else
            Functions.AddMoney(src, paymentMethod, totalAmount)
        end
    end

    if directApply then
        -- Stance, handling, anti-lag and two-step go through vehicle_persistence (never nitro).
        local state = data.properties._skyMechanicTuning
        data.properties._skyMechanicTuning = nil
        local properties = isAdmin and data.properties or filterPropertiesForParts(data.properties, orderItems)
        TuningDB.SaveVehicleProperties(plate, properties)
        if type(state) == "table" and not isAdmin then
            -- Only the state that belongs to a purchased part.
            local bought = {}
            for _, part in ipairs(orderItems) do
                bought[part.id] = true
                if part.id:find("^handling_") then bought.handling = true end
            end
            state = {
                stance = bought.stancer_bundle and state.stance or nil,
                antiLag = bought.antilag_enabled and state.antiLag or nil,
                twoStep = bought.twostep_enabled and state.twoStep or nil,
                customHandling = bought.handling and state.customHandling or nil
            }
        end
        if type(state) == "table" and next(state) and VehiclePersistence and VehiclePersistence.SaveTuningState then
            VehiclePersistence.SaveTuningState(plate, state)
        end

        VehicleHistory.Add(plate, "tuning_direct",
            string.format("Direct tuning applied (%d modifications)", #orderItems), src, totalAmount)

        return { success = true, appliedDirect = true, resultAmount = totalAmount, total = totalAmount }
    end

    local orderId = MySQL.insert.await([[
        INSERT INTO sky_mechanic_orders (
            job, customer_identifier, customer_name, plate, vehicle_model, vehicle_label, items, price, status, paid,
            payment_method, payer_job
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending', 1, ?, ?)
    ]], {
        workshopJob,
        Functions.GetIdentifier(src),
        shortText(Functions.GetName(src), 100) or "Customer",
        plate,
        shortText(data.model, 50) or tostring(modelHash),
        shortText(data.modelLabel or data.model, 100) or "",
        json.encode(orderItems),
        totalAmount,
        totalAmount > 0 and paymentMethod or "free",
        payerJob
    })

    if not orderId or orderId <= 0 then
        refundPayment()
        return { success = false, error = "order_creation_failed" }
    end

    -- Revenue goes to the workshop unless the workshop paid for it itself.
    local addRevenue = Pricing.GetSetting("addRevenueToSociety")
    if totalAmount > 0 and addRevenue ~= false and not (paymentMethod == "society" and payerJob == workshopJob) then
        if Functions.AddSocietyMoney(workshopJob, totalAmount, ("Tuning order #%d"):format(orderId)) then
            MySQL.update.await("UPDATE sky_mechanic_orders SET society_revenue = ? WHERE id = ?", { totalAmount, orderId })
        end
    end

    VehicleHistory.Add(plate, "order_created",
        string.format("Order #%d created with %d parts", orderId, #orderItems), src, totalAmount)

    return { success = true, order = orderId, resultAmount = totalAmount, total = totalAmount }
end)

-- ── Tuning Removal System ─────────────────────────────

local pendingRemovals = {}

-- Whether the stored properties show this part, and the stock values that undo it. Only
-- parts that can be checked against the stored vehicle return an item.
local function getStoredPartState(plate, optionId, value)
    if not TuningDB.IsVehicleOwned(plate) then return false end
    local stored = TuningDB.GetVehicleProperties(plate) or {}
    local keys = Sky.VehiclePropertyKeys

    local modType = tonumber(optionId:match("^mod_(%d+)$"))
    if modType then
        local key = keys.mods[modType]
        local current = tonumber(key and stored[key])
        if current == nil and type(stored.mods) == "table" then current = tonumber(stored.mods[tostring(modType)]) end
        if current == nil or current < 0 or current ~= tonumber(value) then return false end
        local patch = { mods = { [tostring(modType)] = -1 } }
        if key then patch[key] = -1 end
        return true, patch
    end

    local toggleType = tonumber(optionId:match("^toggle_(%d+)$"))
    if toggleType then
        local key = keys.toggles[toggleType]
        local on = (key and stored[key] == true) or (type(stored.toggleMods) == "table" and stored.toggleMods[tostring(toggleType)] == true)
        if not on then return false end
        local patch = { toggleMods = { [tostring(toggleType)] = false } }
        if key then patch[key] = false end
        return true, patch
    end

    local neonIndex = tonumber(optionId:match("^neon_([0-3])$"))
    if neonIndex then
        local enabled = type(stored.neonEnabled) == "table" and stored.neonEnabled or nil
        if not enabled or enabled[neonIndex + 1] ~= true then return false end
        local copy = { enabled[1] == true, enabled[2] == true, enabled[3] == true, enabled[4] == true }
        copy[neonIndex + 1] = false
        return true, { neonEnabled = copy }
    end

    local extraId = optionId:match("^extra_(%d+)$")
    if extraId then
        if type(stored.extras) ~= "table" or stored.extras[extraId] ~= true then return false end
        return true, { extras = { [extraId] = false } }
    end

    return false
end

local function getRemovalReturnItem(src, plate, optionId, value, wheelType)
    local installed, patch = getStoredPartState(plate, optionId, value)
    if not installed then return nil, nil end
    local ctx = Pricing.NewContext(getOwnMechanicJob(src), nil, { free = true })
    local priced = Pricing.PriceEntry(ctx, optionId, value, wheelType)
    return priced and priced.requiredItem or nil, patch
end

Sky.Cb.Register("sky_mechanicjob:tuning:getRemovalPreview", function(source, data)
    local src = tonumber(source)
    if not src or not Functions.IsMechanicOnDuty(src) then
        return { success = false, error = "not_authorized" }
    end

    local plate = sanitizePlate(type(data) == "table" and data.plate)
    local list = type(data) == "table" and type(data.entries) == "table" and data.entries or {}
    if plate == "" or not Functions.GetNearbyVehicleByPlate(src, plate, ORDER_VEHICLE_DISTANCE) then
        return { success = false, error = "vehicle_not_found" }
    end

    local entries = {}
    for i, entry in ipairs(list) do
        if i > MAX_ORDER_PARTS then break end
        if type(entry) == "table" and type(entry.id) == "string" then
            local returnItem = getRemovalReturnItem(src, plate, entry.id, entry.value, entry.wheelType)
            entries[#entries + 1] = {
                id = shortText(entry.id, 64),
                value = type(entry.value) == "table" and entry.value or tonumber(entry.value),
                stockValue = tonumber(entry.stockValue),
                wheelType = tonumber(entry.wheelType),
                label = shortText(entry.label, 80),
                valueLabel = shortText(entry.valueLabel, 80),
                section = shortText(entry.section, 32),
                requiredItem = REMOVAL_TOOL_ITEM,
                returnItem = returnItem,
                returnItems = returnItem and { { name = returnItem, amount = 1 } } or {}
            }
        end
    end

    return { success = true, data = { entries = entries } }
end)

Sky.Cb.Register("sky_mechanicjob:tuning:prepareRemoval", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end
    if not Functions.IsMechanicOnDuty(src) then
        return { success = false, error = "not_authorized" }
    end

    local plate = sanitizePlate(type(data) == "table" and data.plate)
    local optionId = type(data) == "table" and shortText(data.id, 64) or nil
    if plate == "" or not optionId then return { success = false, error = "invalid_payload" } end
    if not Functions.GetNearbyVehicleByPlate(src, plate, ORDER_VEHICLE_DISTANCE) then
        return { success = false, error = "vehicle_too_far" }
    end

    if not Functions.HasItem(src, REMOVAL_TOOL_ITEM, 1) then
        return { success = false, error = "missing_item", requiredItem = REMOVAL_TOOL_ITEM }
    end

    local section = tostring(data.section or "")
    local returnItem, patch = getRemovalReturnItem(src, plate, optionId, data.value, data.wheelType)
    pendingRemovals[src] = {
        plate = plate,
        id = optionId,
        label = shortText(data.label, 80) or optionId,
        returnItem = returnItem,
        patch = patch,
        at = os.time()
    }

    local flow = "hood_install"
    if section == "wheels" or section == "brakes" or section == "suspension" then
        flow = "wheel"
    end

    return { success = true, data = { requiredItem = REMOVAL_TOOL_ITEM, returnItem = returnItem, flow = flow } }
end)

Sky.Cb.Register("sky_mechanicjob:tuning:completeRemoval", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local pending = pendingRemovals[src]
    pendingRemovals[src] = nil

    local plate = sanitizePlate(type(data) == "table" and data.plate)
    local optionId = type(data) == "table" and tostring(data.id or "") or ""
    if not pending or pending.plate ~= plate or pending.id ~= optionId
        or os.time() - pending.at > REMOVAL_TIMEOUT_SECONDS then
        return { success = false, error = "invalid_state" }
    end
    if not Functions.IsMechanicOnDuty(src) then
        return { success = false, error = "not_authorized" }
    end
    if not Functions.GetNearbyVehicleByPlate(src, plate, ORDER_VEHICLE_DISTANCE) then
        return { success = false, error = "vehicle_too_far" }
    end

    if pending.returnItem then
        if not Functions.AddItem(src, pending.returnItem, 1) then
            return { success = false, error = "inventory_full" }
        end
        -- Store the part as removed so the same removal cannot return another item.
        TuningDB.SaveVehicleProperties(plate, pending.patch)
    end

    VehicleHistory.Add(plate, "tuning_removed", string.format("Removed: %s", pending.label), src, 0)

    return { success = true, data = { returnItem = pending.returnItem } }
end)

-- ── Order Tablet RPCs ────────────────────────────────

local NUI_ORDER_STATUS = { pending = "open", in_progress = "open", completed = "completed", refunded = "refunded" }

Sky.Cb.Register("sky_mechanicjob:orders:getAll", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end
    local jobName = getOwnMechanicJob(src)
    if not jobName then return { success = false, error = "unauthorized" } end

    local page = math.max(1, math.floor(tonumber(data and data.page) or 1))
    local pageSize = math.max(1, math.min(100, math.floor(tonumber(data and data.pageSize) or 20)))
    local search = tostring(data and data.search or ""):sub(1, 64)
    local offset = (page - 1) * pageSize

    local where = "job = ?"
    local params = { jobName }
    if search ~= "" then
        local like = "%" .. search .. "%"
        where = where .. " AND (plate LIKE ? OR customer_name LIKE ? OR vehicle_model LIKE ? OR id = ?)"
        params[#params + 1] = like
        params[#params + 1] = like
        params[#params + 1] = like
        params[#params + 1] = tonumber((search:gsub("^#", ""))) or -1
    end

    local countRow = MySQL.single.await("SELECT COUNT(*) AS count FROM sky_mechanic_orders WHERE " .. where, params)
    local rows = MySQL.query.await(
        ("SELECT * FROM sky_mechanic_orders WHERE %s ORDER BY (status IN ('pending', 'in_progress')) DESC, id DESC LIMIT %d OFFSET %d")
            :format(where, pageSize, offset),
        params
    ) or {}

    local orders = {}
    for _, row in ipairs(rows) do
        local custName = row.customer_name
        if not custName or custName == "" or custName == "Unknown" then
            local custSrc = Functions.GetSourceByIdentifier(row.customer_identifier)
            custName = custSrc and Functions.GetName(custSrc) or "Customer"
        end

        local items = decodeItems(row.items)
        orders[#orders + 1] = {
            id = row.id,
            job = row.job,
            customerName = custName,
            plate = row.plate,
            vehicleModel = row.vehicle_model,
            vehicleLabel = row.vehicle_label,
            items = items,
            parts = items,
            price = row.price,
            amountPaid = (row.paid == 1 or row.paid == true) and row.price or 0,
            status = NUI_ORDER_STATUS[row.status] or row.status,
            paid = row.paid == 1 or row.paid == true,
            createdAt = row.created_at
        }
    end

    return {
        success = true,
        data = {
            orders = orders,
            total = countRow and countRow.count or #rows,
            pagination = { total = countRow and countRow.count or #rows, page = page, pageSize = pageSize }
        }
    }
end)

Sky.Cb.Register("sky_mechanicjob:orders:refund", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end
    if not Functions.IsMechanicOnDuty(src) then return { success = false, error = "unauthorized" } end
    local jobName = getOwnMechanicJob(src)

    local orderId = math.floor(tonumber(data and (data.orderId or data.id or data.order)) or 0)
    if orderId <= 0 then return { success = false, error = "invalid_id" } end

    local order = MySQL.single.await("SELECT * FROM sky_mechanic_orders WHERE id = ? AND job = ? LIMIT 1", { orderId, jobName })
    if not order then return { success = false, error = "not_found" } end
    if order.status == "refunded" then return { success = false, error = "already_refunded" } end

    local price = math.floor(tonumber(order.price) or 0)
    local paid = order.paid == 1 or order.paid == true
    if order.status ~= "pending" or price <= 0 or not paid then
        return { success = false, error = "order_not_refundable" }
    end
    for _, part in ipairs(decodeItems(order.items)) do
        if type(part) == "table" and part.installed == true then
            return { success = false, error = "order_not_refundable" }
        end
    end

    local bySociety = order.payment_method == "society" and type(order.payer_job) == "string" and order.payer_job ~= ""
    local customerSrc = nil
    if not bySociety then
        customerSrc = Functions.GetSourceByIdentifier(order.customer_identifier)
        if not customerSrc then
            return { success = false, error = "customer_offline" }
        end
    end

    -- Only one caller can move the order out of 'pending'.
    local affected = MySQL.update.await(
        "UPDATE sky_mechanic_orders SET status = 'refunded', paid = 0 WHERE id = ? AND job = ? AND status = 'pending' AND paid = 1",
        { orderId, jobName }
    )
    if affected ~= 1 then
        return { success = false, error = "order_not_refundable" }
    end

    local function restoreOrder()
        MySQL.update.await("UPDATE sky_mechanic_orders SET status = 'pending', paid = 1 WHERE id = ?", { orderId })
    end

    local revenue = math.floor(tonumber(order.society_revenue) or 0)
    if revenue > 0 and not Functions.RemoveSocietyMoney(order.job, revenue, ("Refund of tuning order #%d"):format(orderId)) then
        restoreOrder()
        return { success = false, error = "society_refund_failed" }
    end

    local refunded
    if bySociety then
        refunded = Functions.AddSocietyMoney(order.payer_job, price, ("Refund of tuning order #%d"):format(orderId))
    else
        local account = order.payment_method == "cash" and "cash" or "bank"
        refunded = Functions.AddMoney(customerSrc, account, price)
    end

    if not refunded then
        if revenue > 0 then
            Functions.AddSocietyMoney(order.job, revenue, ("Tuning order #%d"):format(orderId))
        end
        restoreOrder()
        return { success = false, error = "refund_failed" }
    end

    if customerSrc then
        Functions.ShowNotification(customerSrc, "Mechanic", string.format("Order #%d refunded ($%d).", orderId, price), "info")
    end

    VehicleHistory.Add(order.plate, "order_refunded",
        string.format("Order #%d was refunded ($%d)", orderId, price), src, price)

    return { success = true }
end)

Sky.Cb.Register("sky_mechanicjob:orders:delete", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end
    if not Functions.IsMechanicOnDuty(src) then return { success = false, error = "unauthorized" } end
    local jobName = getOwnMechanicJob(src)

    local orderId = math.floor(tonumber(data and (data.orderId or data.id or data.order or data.orderUID or data.uid)) or 0)
    if orderId <= 0 then return { success = false, error = "invalid_id" } end

    local affected = MySQL.update.await(
        "DELETE FROM sky_mechanic_orders WHERE id = ? AND job = ? AND status IN ('completed', 'refunded')",
        { orderId, jobName }
    )
    if affected == 1 then
        return { success = true }
    end

    local exists = MySQL.single.await("SELECT id FROM sky_mechanic_orders WHERE id = ? AND job = ? LIMIT 1", { orderId, jobName })
    return { success = false, error = exists and "order_not_completed" or "not_found" }
end)

-- Loads an order part a mechanic of the order's workshop may install now.
local function getInstallablePart(src, orderId, partIndex)
    if orderId <= 0 or partIndex <= 0 then return nil, "invalid_payload" end
    if not Functions.IsMechanicOnDuty(src) then return nil, "unauthorized" end

    local order = MySQL.single.await("SELECT * FROM sky_mechanic_orders WHERE id = ? LIMIT 1", { orderId })
    if not order then return nil, "order_not_found" end
    if order.job ~= Functions.GetJob(src) then return nil, "unauthorized" end
    if order.status ~= "pending" and order.status ~= "in_progress" then return nil, "order_closed" end

    local items = decodeItems(order.items)
    local part = items[partIndex]
    if type(part) ~= "table" then return nil, "part_not_found" end
    if part.installed == true then return nil, "already_installed" end

    if not Functions.GetNearbyVehicleByPlate(src, order.plate, ORDER_VEHICLE_DISTANCE) then
        return nil, "vehicle_too_far"
    end
    return order, nil, items, part
end

Sky.Cb.Register("sky_mechanicjob:orders:prepareInstall", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local orderId = math.floor(tonumber(data and data.orderId) or 0)
    local partIndex = math.floor(tonumber(data and data.partIndex) or 0)
    local order, err, _, part = getInstallablePart(src, orderId, partIndex)
    if not order then return { success = false, error = err } end

    local reqItem = type(part.requiredItem) == "string" and part.requiredItem or ""
    if reqItem ~= "" and not Functions.HasItem(src, reqItem, 1) then
        return { success = false, error = "missing_item", requiredItem = reqItem }
    end

    return {
        success = true,
        data = {
            part = part,
            requiredItem = reqItem,
            removeRequiredItemAfterUse = reqItem ~= "" and part.removeAfterUse ~= false,
            flow = part.flow or "performance"
        }
    }
end)

Sky.Cb.Register("sky_mechanicjob:orders:completeInstall", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local orderId = math.floor(tonumber(data and data.orderId) or 0)
    local partIndex = math.floor(tonumber(data and data.partIndex) or 0)
    local order, err, items, part = getInstallablePart(src, orderId, partIndex)
    if not order then return { success = false, error = err } end

    local reqItem = type(part.requiredItem) == "string" and part.requiredItem or ""
    local consume = reqItem ~= "" and part.removeAfterUse ~= false
    if consume then
        if not Functions.RemoveItem(src, reqItem, 1) then
            return { success = false, error = "missing_item", requiredItem = reqItem }
        end
    elseif reqItem ~= "" and not Functions.HasItem(src, reqItem, 1) then
        return { success = false, error = "missing_item", requiredItem = reqItem }
    end

    part.installed = true
    items[partIndex] = part

    local allInstalled = true
    for _, it in ipairs(items) do
        if type(it) == "table" and it.installed ~= true then
            allInstalled = false
            break
        end
    end

    -- Conditional on the items read above, so two installs cannot overwrite each other.
    local newStatus = allInstalled and "completed" or "in_progress"
    local affected = MySQL.update.await(
        "UPDATE sky_mechanic_orders SET items = ?, status = ? WHERE id = ? AND items = ? AND status IN ('pending', 'in_progress')",
        { json.encode(items), newStatus, orderId, order.items }
    )
    if affected ~= 1 then
        if consume then Functions.AddItem(src, reqItem, 1) end
        return { success = false, error = "order_changed" }
    end

    VehicleHistory.Add(order.plate, "part_installed",
        string.format("Installed: %s (Order #%d)", part.label or part.id, orderId), src, part.price or 0)

    return { success = true, data = { completed = allInstalled } }
end)

-- ── Usable Items Setup ────────────────────────────────

local function setupUsableItems()
    Functions.RegisterUsableItem("wash_sponge", function(source)
        TriggerClientEvent("sky_mechanicjob:vehicleCare:start", source, "wash")
    end)

    Functions.RegisterUsableItem("vehicle_wax", function(source)
        TriggerClientEvent("sky_mechanicjob:vehicleCare:start", source, "wax")
    end)

    Functions.RegisterUsableItem("fix_kit", function(source)
        TriggerClientEvent("sky_mechanicjob:vehicleCare:start", source, "repair", "fix_kit")
    end)

    Functions.RegisterUsableItem("repair_kit", function(source)
        TriggerClientEvent("sky_mechanicjob:vehicleCare:start", source, "repair", "repair_kit")
    end)

    Functions.RegisterUsableItem("stance_kit", function(source)
        itemSessions[tonumber(source)] = { mode = "stancing", expiresAt = os.time() + ITEM_SESSION_SECONDS }
        TriggerClientEvent("sky_mechanicjob:tuning:openStancing", source)
    end)

    Functions.RegisterUsableItem("rgb_controller", function(source)
        itemSessions[tonumber(source)] = { mode = "rgb_controller", expiresAt = os.time() + ITEM_SESSION_SECONDS }
        TriggerClientEvent("sky_mechanicjob:tuning:openRgbController", source)
    end)

    Functions.RegisterUsableItem("nitro_kit", function(source)
        TriggerClientEvent("sky_mechanicjob:nitro:beginInstall", source)
    end)

    local theftItem = Config and Config.PartsTheft and Config.PartsTheft.item or "lug_wrench"
    Functions.RegisterUsableItem(theftItem, function(source)
        TriggerClientEvent("sky_mechanicjob:lugWrench:chooseTheft", source)
    end)
end

CreateThread(function()
    -- The framework may still be starting when this resource loads.
    for _ = 1, 20 do
        if Functions.GetFramework() then break end
        Wait(500)
    end
    setupUsableItems()
end)

AddEventHandler("playerDropped", function()
    local src = tonumber(source)
    if src then
        pendingRemovals[src] = nil
        itemSessions[src] = nil
    end
end)
