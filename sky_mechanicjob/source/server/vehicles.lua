if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/vehicles.lua") end
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

-- ── Registry Paginated Search Callback ────────────────

Sky.Cb.Register("sky_mechanicjob:vehicles:getRegistry", function(source, data)
    local page = math.max(1, math.floor(tonumber(data and data.page) or 1))
    local pageSize = math.max(1, math.min(100, math.floor(tonumber(data and data.pageSize) or 20)))
    local search = tostring(data and data.search or "")
    local offset = (page - 1) * pageSize

    local framework = Sky and Sky.Config and Sky.Config.framework or "qb"

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
        local countQuery = "SELECT COUNT(*) as count FROM player_vehicles pv"
        local params = {}

        if search ~= "" then
            query = query .. " WHERE (pv.plate LIKE @search OR pv.vehicle LIKE @search OR pv.citizenid LIKE @search)"
            countQuery = countQuery .. " WHERE (pv.plate LIKE @search OR pv.vehicle LIKE @search OR pv.citizenid LIKE @search)"
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
                tags = row.tags and json.decode(row.tags) or {},
                notes = row.notes or "",
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
        local countQuery = "SELECT COUNT(*) as count FROM owned_vehicles ov"
        local params = {}

        if search ~= "" then
            query = query .. " WHERE (ov.plate LIKE @search OR ov.owner LIKE @search)"
            countQuery = countQuery .. " WHERE (ov.plate LIKE @search OR ov.owner LIKE @search)"
            params["@search"] = "%" .. search .. "%"
        end

        query = query .. " ORDER BY ov.plate ASC LIMIT " .. pageSize .. " OFFSET " .. offset

        local rows = MySQL.query.await(query, params) or {}
        local countRow = MySQL.single.await(countQuery, params)
        totalCount = countRow and countRow.count or #rows

        for _, row in ipairs(rows) do
            local modelName = "vehicle"
            if row.vehicle then
                local decoded = json.decode(row.vehicle)
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
                tags = row.tags and json.decode(row.tags) or {},
                notes = row.notes or "",
                mileage = math.floor(tonumber(row.mileage) or 0)
            }
        end
    end

    return {
        success = true,
        data = {
            vehicles = vehicles,
            total = totalCount
        }
    }
end)

-- ── Registry Metadata Updates ─────────────────────────

Sky.Cb.Register("sky_mechanicjob:vehicles:setImage", function(source, data)
    local plate = sanitizePlate(data and data.plate)
    local url = tostring(data and data.url or "")

    if plate == "" then return { success = false, error = "invalid_plate" } end

    MySQL.query.await([[
        INSERT INTO sky_mechanic_vehicle_registry (plate, image_url)
        VALUES (@plate, @image_url)
        ON DUPLICATE KEY UPDATE image_url = @image_url
    ]], {
        ["@plate"] = plate,
        ["@image_url"] = url
    })

    return { success = true }
end)

Sky.Cb.Register("sky_mechanicjob:vehicles:setTags", function(source, data)
    local plate = sanitizePlate(data and data.plate)
    local tags = type(data and data.tags) == "table" and data.tags or {}

    if plate == "" then return { success = false, error = "invalid_plate" } end

    MySQL.query.await([[
        INSERT INTO sky_mechanic_vehicle_registry (plate, tags)
        VALUES (@plate, @tags)
        ON DUPLICATE KEY UPDATE tags = @tags
    ]], {
        ["@plate"] = plate,
        ["@tags"] = json.encode(tags)
    })

    return { success = true }
end)

Sky.Cb.Register("sky_mechanicjob:vehicles:setNotes", function(source, data)
    local plate = sanitizePlate(data and data.plate)
    local text = tostring(data and data.text or "")

    if plate == "" then return { success = false, error = "invalid_plate" } end

    MySQL.query.await([[
        INSERT INTO sky_mechanic_vehicle_registry (plate, notes)
        VALUES (@plate, @notes)
        ON DUPLICATE KEY UPDATE notes = @notes
    ]], {
        ["@plate"] = plate,
        ["@notes"] = text
    })

    return { success = true }
end)
