if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/tuning_db.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/tuning_db.lua
--  Tuning Database Operations & Vehicle Properties Store
-- =====================================================

TuningDB = TuningDB or {}

-- Plates come from clients (any NPC or made-up plate), so both caches expire and are capped.
local CACHE_TTL_SECONDS = 600
local CACHE_MAX_ENTRIES = 2000
local tuningCache = { entries = {}, size = 0 }
local stanceDefaultsCache = { entries = {}, size = 0 }

local function cacheGet(cache, key)
    local entry = cache.entries[key]
    if not entry then return nil end
    if os.time() - entry.at > CACHE_TTL_SECONDS then
        cache.entries[key] = nil
        cache.size = cache.size - 1
        return nil
    end
    return entry.value
end

local function cacheSet(cache, key, value)
    if not cache.entries[key] then
        if cache.size >= CACHE_MAX_ENTRIES then
            cache.entries, cache.size = {}, 0
        end
        cache.size = cache.size + 1
    end
    cache.entries[key] = { value = value, at = os.time() }
end

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" or #trimmed > 12 then return "" end
    return string.upper(trimmed)
end

local function isEsx()
    return Functions.GetFramework() == "esx"
end

--- Get vehicle persistence requireOwned setting
---@return boolean
local function requireOwnedVehicle()
    if Config and Config.VehiclePersistence and Config.VehiclePersistence.requireOwnedVehicle ~= nil then
        return Config.VehiclePersistence.requireOwnedVehicle == true
    end
    return true
end

--- Check if vehicle plate exists in framework ownership table
---@param plate string
---@return boolean
function TuningDB.IsVehicleOwned(plate)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" then return false end

    local query = "SELECT plate FROM player_vehicles WHERE plate = @plate LIMIT 1"
    if isEsx() then
        query = "SELECT plate FROM owned_vehicles WHERE plate = @plate LIMIT 1"
    end

    local result = MySQL.query.await(query, { ["@plate"] = cleanPlate })
    return result and result[1] ~= nil
end

--- Identifier of the owning character (citizenid / ESX owner), or nil for unowned plates
---@param plate string
---@return string|nil
function TuningDB.GetVehicleOwner(plate)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" then return nil end

    local query = "SELECT citizenid AS owner FROM player_vehicles WHERE plate = ? LIMIT 1"
    if isEsx() then
        query = "SELECT owner FROM owned_vehicles WHERE plate = ? LIMIT 1"
    end

    local row = MySQL.single.await(query, { cleanPlate })
    return row and row.owner and tostring(row.owner) or nil
end

--- Whether tuning for this plate is stored at all (Config.VehiclePersistence.requireOwnedVehicle)
---@param plate string
---@return boolean
function TuningDB.CanPersistPlate(plate)
    if not requireOwnedVehicle() then return sanitizePlate(plate) ~= "" end
    return TuningDB.IsVehicleOwned(plate)
end

--- Get saved tuning record for vehicle plate
---@param plate string
---@return table|nil
function TuningDB.GetVehicleTuning(plate)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" then return nil end

    local cached = cacheGet(tuningCache, cleanPlate)
    if cached ~= nil then
        return cached or nil
    end

    local row = MySQL.single.await([[
        SELECT plate, tuning, stance, rgb, nitro, custom_handling
        FROM sky_mechanic_vehicle_tuning
        WHERE plate = @plate LIMIT 1
    ]], { ["@plate"] = cleanPlate })

    if not row then
        cacheSet(tuningCache, cleanPlate, false)
        return nil
    end

    local record = {
        plate = row.plate,
        tuning = row.tuning and json.decode(row.tuning) or nil,
        stance = row.stance and json.decode(row.stance) or nil,
        rgb = row.rgb and json.decode(row.rgb) or nil,
        nitro = row.nitro and json.decode(row.nitro) or nil,
        custom_handling = row.custom_handling and json.decode(row.custom_handling) or nil
    }

    cacheSet(tuningCache, cleanPlate, record)
    return record
end

--- Save tuning data for vehicle plate
---@param plate string
---@param data table
---@return boolean
function TuningDB.SaveVehicleTuning(plate, data)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" or type(data) ~= "table" then return false end

    if requireOwnedVehicle() and not TuningDB.IsVehicleOwned(cleanPlate) then
        return false
    end

    local current = TuningDB.GetVehicleTuning(cleanPlate) or {}

    local tuningJson = data.tuning ~= nil and json.encode(data.tuning) or (current.tuning and json.encode(current.tuning) or nil)
    local stanceJson = data.stance ~= nil and json.encode(data.stance) or (current.stance and json.encode(current.stance) or nil)
    local rgbJson = data.rgb ~= nil and json.encode(data.rgb) or (current.rgb and json.encode(current.rgb) or nil)
    local nitroJson = data.nitro ~= nil and json.encode(data.nitro) or (current.nitro and json.encode(current.nitro) or nil)
    local customHandlingJson = data.custom_handling ~= nil and json.encode(data.custom_handling) or (current.custom_handling and json.encode(current.custom_handling) or nil)

    MySQL.query.await([[
        INSERT INTO sky_mechanic_vehicle_tuning (plate, tuning, stance, rgb, nitro, custom_handling)
        VALUES (@plate, @tuning, @stance, @rgb, @nitro, @custom_handling)
        ON DUPLICATE KEY UPDATE
            tuning = COALESCE(@tuning, tuning),
            stance = COALESCE(@stance, stance),
            rgb = COALESCE(@rgb, rgb),
            nitro = COALESCE(@nitro, nitro),
            custom_handling = COALESCE(@custom_handling, custom_handling)
    ]], {
        ["@plate"] = cleanPlate,
        ["@tuning"] = tuningJson,
        ["@stance"] = stanceJson,
        ["@rgb"] = rgbJson,
        ["@nitro"] = nitroJson,
        ["@custom_handling"] = customHandlingJson
    })

    cacheSet(tuningCache, cleanPlate, {
        plate = cleanPlate,
        tuning = data.tuning or current.tuning,
        stance = data.stance or current.stance,
        rgb = data.rgb or current.rgb,
        nitro = data.nitro or current.nitro,
        custom_handling = data.custom_handling or current.custom_handling
    })

    return true
end

--- Get factory default stance for vehicle plate
---@param plate string
---@return table|nil
function TuningDB.GetStanceDefault(plate)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" then return nil end

    local cached = cacheGet(stanceDefaultsCache, cleanPlate)
    if cached ~= nil then
        return cached or nil
    end

    local row = MySQL.single.await([[
        SELECT stance FROM sky_mechanic_stance_defaults
        WHERE plate = @plate LIMIT 1
    ]], { ["@plate"] = cleanPlate })

    if not row or not row.stance then
        cacheSet(stanceDefaultsCache, cleanPlate, false)
        return nil
    end

    local ok, stance = pcall(json.decode, row.stance)
    stance = ok and type(stance) == "table" and stance or nil
    cacheSet(stanceDefaultsCache, cleanPlate, stance or false)
    return stance
end

--- Save factory default stance for vehicle plate
---@param plate string
---@param stance table
---@param autoCapture? boolean
---@return boolean
function TuningDB.SaveStanceDefault(plate, stance, autoCapture)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" or type(stance) ~= "table" then return false end

    if autoCapture then
        local existing = TuningDB.GetStanceDefault(cleanPlate)
        if existing then return true end
    end

    local stanceJson = json.encode(stance)
    MySQL.query.await([[
        INSERT INTO sky_mechanic_stance_defaults (plate, stance)
        VALUES (@plate, @stance)
        ON DUPLICATE KEY UPDATE stance = @stance
    ]], {
        ["@plate"] = cleanPlate,
        ["@stance"] = stanceJson
    })

    cacheSet(stanceDefaultsCache, cleanPlate, stance)
    return true
end

--- Get vehicle properties merged with sky tuning metadata
---@param plate string
---@return table|nil
function TuningDB.GetVehicleProperties(plate)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" then return nil end

    local query = "SELECT mods, vehicle FROM player_vehicles WHERE plate = @plate LIMIT 1"
    if isEsx() then
        query = "SELECT vehicle FROM owned_vehicles WHERE plate = @plate LIMIT 1"
    end

    local row = MySQL.single.await(query, { ["@plate"] = cleanPlate })
    local properties = {}

    if row then
        if row.mods then
            local decoded = json.decode(row.mods)
            if type(decoded) == "table" then properties = decoded end
        elseif row.vehicle then
            local decoded = json.decode(row.vehicle)
            if type(decoded) == "table" then properties = decoded end
        end
    end

    local tuningRecord = TuningDB.GetVehicleTuning(cleanPlate)
    if tuningRecord then
        properties._skyMechanicTuning = {
            paint = tuningRecord.tuning and tuningRecord.tuning.paint or nil,
            stance = tuningRecord.stance,
            rgb = tuningRecord.rgb,
            nitro = tuningRecord.nitro,
            customHandling = {
                profiles = tuningRecord.custom_handling
            }
        }
    end

    return properties
end

-- Keys that belong to the stored row, not to a mechanic's snapshot.
local SKIPPED_PROPERTY_KEYS = { mods = true, toggleMods = true, _skyMechanicTuning = true, plate = true, model = true }

local function decodeTable(value)
    if type(value) ~= "string" or value == "" then return {} end
    local ok, decoded = pcall(json.decode, value)
    return ok and type(decoded) == "table" and decoded or {}
end

-- Merges a snapshot into the stored properties and adds the standard qb/ox keys
-- (modEngine, modTurbo, ...) that garages restore from.
local function mergeProperties(stored, properties)
    for key, value in pairs(properties) do
        if not SKIPPED_PROPERTY_KEYS[key] then
            stored[key] = value
        end
    end

    local keys = Sky.VehiclePropertyKeys or { mods = {}, toggles = {} }
    if type(properties.mods) == "table" then
        stored.mods = type(stored.mods) == "table" and stored.mods or {}
        for modId, modValue in pairs(properties.mods) do
            local modType, val = tonumber(modId), tonumber(modValue)
            if modType and val then
                stored.mods[tostring(modType)] = val
                local key = keys.mods[modType]
                if key and properties[key] == nil and not (modType == 48 and properties.modLivery ~= nil) then
                    stored[key] = val
                end
            end
        end
    end
    if type(properties.toggleMods) == "table" then
        stored.toggleMods = type(stored.toggleMods) == "table" and stored.toggleMods or {}
        for modId, state in pairs(properties.toggleMods) do
            local modType = tonumber(modId)
            if modType then
                stored.toggleMods[tostring(modType)] = state == true
                local key = keys.toggles[modType]
                if key and properties[key] == nil then
                    stored[key] = state == true
                end
            end
        end
    end

    -- qb-core / ox_lib keep a custom paint in color1/color2 as { r, g, b }.
    if type(properties.customPrimaryColor) == "table" then
        stored.color1 = properties.customPrimaryColor
    end
    if type(properties.customSecondaryColor) == "table" then
        stored.color2 = properties.customSecondaryColor
    end
    return stored
end

--- Save vehicle properties into framework table and sky tuning table. Merges into the
--- stored properties; keys missing from the snapshot are kept.
---@param plate string
---@param properties table
---@return boolean
function TuningDB.SaveVehicleProperties(plate, properties)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" or type(properties) ~= "table" then return false end

    if isEsx() then
        local row = MySQL.single.await("SELECT vehicle FROM owned_vehicles WHERE plate = ? LIMIT 1", { cleanPlate })
        if row then
            MySQL.update.await("UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?", {
                json.encode(mergeProperties(decodeTable(row.vehicle), properties)), cleanPlate
            })
        end
    else
        local row = MySQL.single.await("SELECT mods FROM player_vehicles WHERE plate = ? LIMIT 1", { cleanPlate })
        if row then
            MySQL.update.await("UPDATE player_vehicles SET mods = ? WHERE plate = ?", {
                json.encode(mergeProperties(decodeTable(row.mods), properties)), cleanPlate
            })
        end
    end

    if type(properties._skyMechanicTuning) == "table" then
        local st = properties._skyMechanicTuning
        -- The tuning JSON also holds anti-lag / two-step state; only the paint is replaced.
        local tuning = nil
        if st.paint ~= nil then
            local current = TuningDB.GetVehicleTuning(cleanPlate)
            tuning = {}
            if current and type(current.tuning) == "table" then
                for key, value in pairs(current.tuning) do tuning[key] = value end
            end
            tuning.paint = st.paint
        end
        TuningDB.SaveVehicleTuning(cleanPlate, {
            tuning = tuning,
            stance = st.stance,
            rgb = st.rgb,
            nitro = st.nitro,
            custom_handling = st.customHandling and st.customHandling.profiles or nil
        })
    end

    return true
end
