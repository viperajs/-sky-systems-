-- =====================================================
--  sky_mechanicjob · source/server/vehicles.lua
--  Vehicle Registry Database Search, Photos & Notes
-- =====================================================

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

local MAX_TAGS = 20
local MAX_TAG_LENGTH = 32
local MAX_NOTES_LENGTH = 2000

local function decodeJson(value)
    if type(value) ~= "string" or value == "" then return nil end
    local ok, decoded = pcall(json.decode, value)
    return ok and decoded or nil
end

local function decodeTags(value)
    local decoded = decodeJson(value)
    return type(decoded) == "table" and decoded or {}
end

-- Notes are stored as a JSON array of { text }; older rows hold plain text.
local function decodeNotes(value)
    if type(value) ~= "string" or value == "" then return {} end
    local decoded = decodeJson(value)
    if type(decoded) == "table" then return decoded end
    return { { text = value } }
end

local function denied()
    return { success = false, error = "not_authorized" }
end

-- Order statuses as the registry's Linked Orders (and the Orders tablet) name them.
local ORDER_STATUS = { pending = "open", in_progress = "open", completed = "completed", refunded = "refunded" }

-- Linked Orders: the caller's workshop orders for each listed vehicle, newest first.
local function attachOrders(vehicles, job)
    local placeholders, params, byPlate = {}, {}, {}
    for _, vehicle in ipairs(vehicles) do
        vehicle.orders = {}
        local plate = sanitizePlate(vehicle.plate)
        if plate ~= "" and not byPlate[plate] then
            byPlate[plate] = {}
            placeholders[#placeholders + 1] = "?"
            params[#params + 1] = plate
        end
    end
    if #params == 0 or type(job) ~= "string" then return end
    params[#params + 1] = job

    local ok, rows = pcall(MySQL.query.await, ([[
        SELECT id, plate, status, price, paid, UNIX_TIMESTAMP(created_at) AS created_ts FROM sky_mechanic_orders
        WHERE UPPER(TRIM(plate)) IN (%s) AND job = ? ORDER BY id DESC LIMIT 500
    ]]):format(table.concat(placeholders, ",")), params)
    for _, row in ipairs(ok and type(rows) == "table" and rows or {}) do
        local list = byPlate[sanitizePlate(row.plate)]
        if list and #list < 20 then
            local paid = row.paid == 1 or row.paid == true
            local createdAt = tonumber(row.created_ts)
            list[#list + 1] = {
                id = row.id,
                orderUid = "#" .. tostring(row.id),
                status = ORDER_STATUS[row.status] or row.status,
                amountPaid = paid and (tonumber(row.price) or 0) or 0,
                createdAt = createdAt and os.date("%Y-%m-%d %H:%M", math.floor(createdAt)) or nil
            }
        end
    end
    for _, vehicle in ipairs(vehicles) do
        vehicle.orders = byPlate[sanitizePlate(vehicle.plate)] or {}
    end
end

-- Search text also matches registry tags and the workshop's orders (customer name, #id).
local function searchClause(plateColumn, ownColumns)
    return ("(%s OR r.tags LIKE @search OR EXISTS (SELECT 1 FROM sky_mechanic_orders o"
        .. " WHERE o.plate COLLATE utf8mb4_unicode_ci = %s COLLATE utf8mb4_unicode_ci"
        .. " AND (o.customer_name LIKE @search OR CONCAT('#', o.id) LIKE @search)))"):format(ownColumns, plateColumn)
end

-- ── Registry Paginated Search Callback ────────────────

Sky.Cb.Register("sky_mechanicjob:vehicles:getRegistry", function(source, data)
    if not Functions.IsMechanicOnDuty(source) then return denied() end

    local page = math.max(1, math.floor(tonumber(data and data.page) or 1))
    local pageSize = math.max(1, math.min(100, math.floor(tonumber(data and data.pageSize) or 20)))
    local search = tostring(data and data.search or ""):sub(1, 64)
    local offset = (page - 1) * pageSize

    local framework = Functions.GetFramework() or "qbox"

    local vehicles = {}
    local totalCount = 0

    if framework == "qb" or framework == "qbox" then
        local query = [[
            SELECT pv.plate, pv.vehicle as model, pv.citizenid as owner,
                   r.image_url, r.tags, r.notes,
                   w.mileage
            FROM player_vehicles pv
            LEFT JOIN sky_mechanic_vehicle_registry r ON r.plate COLLATE utf8mb4_unicode_ci = pv.plate COLLATE utf8mb4_unicode_ci
            LEFT JOIN sky_mechanic_vehicle_wear w ON w.plate COLLATE utf8mb4_unicode_ci = pv.plate COLLATE utf8mb4_unicode_ci
        ]]
        local countQuery = [[
            SELECT COUNT(*) as count FROM player_vehicles pv
            LEFT JOIN sky_mechanic_vehicle_registry r ON r.plate COLLATE utf8mb4_unicode_ci = pv.plate COLLATE utf8mb4_unicode_ci
        ]]
        local params = {}

        if search ~= "" then
            local where = " WHERE " .. searchClause("pv.plate", "pv.plate LIKE @search OR pv.vehicle LIKE @search OR pv.citizenid LIKE @search")
            query = query .. where
            countQuery = countQuery .. where
            params["@search"] = "%" .. search .. "%"
        end

        query = query .. " ORDER BY pv.plate ASC LIMIT " .. pageSize .. " OFFSET " .. offset

        local rows = MySQL.query.await(query, params) or {}
        local countRow = MySQL.single.await(countQuery, params)
        totalCount = countRow and countRow.count or #rows

        for _, row in ipairs(rows) do
            local ownerName = Functions.GetName(row.owner) or row.owner
            vehicles[#vehicles + 1] = {
                plate = row.plate,
                model = row.model,
                owner = row.owner,
                owner_name = ownerName,
                image_url = row.image_url,
                tags = decodeTags(row.tags),
                notes = decodeNotes(row.notes),
                mileage = math.floor(tonumber(row.mileage) or 0)
            }
        end
    else
        -- ESX
        local query = [[
            SELECT ov.plate, ov.vehicle as model, ov.owner as owner,
                   r.image_url, r.tags, r.notes,
                   w.mileage
            FROM owned_vehicles ov
            LEFT JOIN sky_mechanic_vehicle_registry r ON r.plate COLLATE utf8mb4_unicode_ci = ov.plate COLLATE utf8mb4_unicode_ci
            LEFT JOIN sky_mechanic_vehicle_wear w ON w.plate COLLATE utf8mb4_unicode_ci = ov.plate COLLATE utf8mb4_unicode_ci
        ]]
        local countQuery = [[
            SELECT COUNT(*) as count FROM owned_vehicles ov
            LEFT JOIN sky_mechanic_vehicle_registry r ON r.plate COLLATE utf8mb4_unicode_ci = ov.plate COLLATE utf8mb4_unicode_ci
        ]]
        local params = {}

        if search ~= "" then
            local where = " WHERE " .. searchClause("ov.plate", "ov.plate LIKE @search OR ov.owner LIKE @search")
            query = query .. where
            countQuery = countQuery .. where
            params["@search"] = "%" .. search .. "%"
        end

        query = query .. " ORDER BY ov.plate ASC LIMIT " .. pageSize .. " OFFSET " .. offset

        local rows = MySQL.query.await(query, params) or {}
        local countRow = MySQL.single.await(countQuery, params)
        totalCount = countRow and countRow.count or #rows

        for _, row in ipairs(rows) do
            local modelName = "vehicle"
            if row.model then
                local decoded = decodeJson(row.model)
                if type(decoded) == "table" and decoded.model then
                    modelName = tostring(decoded.model)
                end
            end

            local ownerName = Functions.GetName(row.owner) or row.owner
            vehicles[#vehicles + 1] = {
                plate = row.plate,
                model = modelName,
                owner = row.owner,
                owner_name = ownerName,
                image_url = row.image_url,
                tags = decodeTags(row.tags),
                notes = decodeNotes(row.notes),
                mileage = math.floor(tonumber(row.mileage) or 0)
            }
        end
    end

    attachOrders(vehicles, Functions.GetJob(source))

    return {
        success = true,
        data = {
            vehicles = vehicles,
            total = totalCount,
            pagination = { page = page, pageSize = pageSize, totalItems = totalCount }
        }
    }
end)

-- ── Registry Metadata Updates ─────────────────────────

Sky.Cb.Register("sky_mechanicjob:vehicles:setImage", function(source, data)
    if not Functions.IsMechanicOnDuty(source) then return denied() end

    local plate = sanitizePlate(data and data.plate)
    local url = type(data) == "table" and type(data.url) == "string" and data.url or ""

    if plate == "" then return { success = false, error = "invalid_plate" } end
    if url ~= "" and (#url > 512 or not url:match("^https?://[%w%-%._~:/%?#%[%]@!%$&'%(%)%*%+,;=%%]+$")) then
        return { success = false, error = "invalid_url" }
    end

    MySQL.query.await([[
        INSERT INTO sky_mechanic_vehicle_registry (plate, image_url)
        VALUES (@plate, @image_url)
        ON DUPLICATE KEY UPDATE image_url = @image_url
    ]], {
        ["@plate"] = plate,
        ["@image_url"] = url ~= "" and url or nil
    })

    return { success = true }
end)

Sky.Cb.Register("sky_mechanicjob:vehicles:setTags", function(source, data)
    if not Functions.IsMechanicOnDuty(source) then return denied() end

    local plate = sanitizePlate(data and data.plate)
    local tags = {}
    for _, tag in ipairs(type(data) == "table" and type(data.tags) == "table" and data.tags or {}) do
        if type(tag) == "string" and tag ~= "" and #tags < MAX_TAGS then
            tags[#tags + 1] = tag:sub(1, MAX_TAG_LENGTH)
        end
    end

    if plate == "" then return { success = false, error = "invalid_plate" } end

    MySQL.query.await([[
        INSERT INTO sky_mechanic_vehicle_registry (plate, tags)
        VALUES (@plate, @tags)
        ON DUPLICATE KEY UPDATE tags = @tags
    ]], {
        ["@plate"] = plate,
        ["@tags"] = json.encode(tags)
    })

    return { success = true, data = { tags = tags } }
end)

Sky.Cb.Register("sky_mechanicjob:vehicles:setNotes", function(source, data)
    if not Functions.IsMechanicOnDuty(source) then return denied() end

    local plate = sanitizePlate(data and data.plate)
    local text = type(data) == "table" and type(data.text) == "string" and data.text:sub(1, MAX_NOTES_LENGTH) or ""
    local notes = text ~= "" and { { text = text, author = Functions.GetName(source), updatedAt = os.time() } } or {}

    if plate == "" then return { success = false, error = "invalid_plate" } end

    MySQL.query.await([[
        INSERT INTO sky_mechanic_vehicle_registry (plate, notes)
        VALUES (@plate, @notes)
        ON DUPLICATE KEY UPDATE notes = @notes
    ]], {
        ["@plate"] = plate,
        ["@notes"] = json.encode(notes)
    })

    return { success = true, data = { notes = notes } }
end)
