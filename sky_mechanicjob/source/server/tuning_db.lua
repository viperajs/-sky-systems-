if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/tuning_db.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/tuning_db.lua
--  Tuning Database Operations & Vehicle Properties Store
-- =====================================================

TuningDB = TuningDB or {}

local tuningCache = {}
local stanceDefaultsCache = {}

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
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

    local framework = Sky and Sky.Config and Sky.Config.framework or "qb"

    local query = "SELECT plate FROM player_vehicles WHERE plate = @plate LIMIT 1"
    if framework == "esx" then
        query = "SELECT plate FROM owned_vehicles WHERE plate = @plate LIMIT 1"
    end

    local result = MySQL.query.await(query, { ["@plate"] = cleanPlate })
    return result and result[1] ~= nil
end

--- Get saved tuning record for vehicle plate
---@param plate string
---@return table|nil
function TuningDB.GetVehicleTuning(plate)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" then return nil end

    if tuningCache[cleanPlate] ~= nil then
        return tuningCache[cleanPlate]
    end

    local row = MySQL.single.await([[
        SELECT plate, tuning, stance, rgb, nitro, custom_handling
        FROM sky_mechanic_vehicle_tuning
        WHERE plate = @plate LIMIT 1
    ]], { ["@plate"] = cleanPlate })

    if not row then
        tuningCache[cleanPlate] = false
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

    tuningCache[cleanPlate] = record
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

    tuningCache[cleanPlate] = {
        plate = cleanPlate,
        tuning = data.tuning or current.tuning,
        stance = data.stance or current.stance,
        rgb = data.rgb or current.rgb,
        nitro = data.nitro or current.nitro,
        custom_handling = data.custom_handling or current.custom_handling
    }

    return true
end

--- Get factory default stance for vehicle plate
---@param plate string
---@return table|nil
function TuningDB.GetStanceDefault(plate)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" then return nil end

    if stanceDefaultsCache[cleanPlate] ~= nil then
        return stanceDefaultsCache[cleanPlate]
    end

    local row = MySQL.single.await([[
        SELECT stance FROM sky_mechanic_stance_defaults
        WHERE plate = @plate LIMIT 1
    ]], { ["@plate"] = cleanPlate })

    if not row or not row.stance then
        stanceDefaultsCache[cleanPlate] = false
        return nil
    end

    local stance = json.decode(row.stance)
    stanceDefaultsCache[cleanPlate] = stance
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

    stanceDefaultsCache[cleanPlate] = stance
    return true
end

--- Get vehicle properties merged with sky tuning metadata
---@param plate string
---@return table|nil
function TuningDB.GetVehicleProperties(plate)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" then return nil end

    local framework = Sky and Sky.Config and Sky.Config.framework or "qb"
    local query = "SELECT mods, vehicle FROM player_vehicles WHERE plate = @plate LIMIT 1"
    if framework == "esx" then
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

--- Save vehicle properties into framework table and sky tuning table
---@param plate string
---@param properties table
---@return boolean
function TuningDB.SaveVehicleProperties(plate, properties)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" or type(properties) ~= "table" then return false end

    local framework = Sky and Sky.Config and Sky.Config.framework or "qb"
    local propsJson = json.encode(properties)

    if framework == "qb" or framework == "qbox" then
        MySQL.query.await([[
            UPDATE player_vehicles
            SET mods = @mods
            WHERE plate = @plate
        ]], {
            ["@plate"] = cleanPlate,
            ["@mods"] = propsJson
        })
    elseif framework == "esx" then
        MySQL.query.await([[
            UPDATE owned_vehicles
            SET vehicle = @vehicle
            WHERE plate = @plate
        ]], {
            ["@plate"] = cleanPlate,
            ["@vehicle"] = propsJson
        })
    end

    if type(properties._skyMechanicTuning) == "table" then
        local st = properties._skyMechanicTuning
        TuningDB.SaveVehicleTuning(cleanPlate, {
            tuning = { paint = st.paint },
            stance = st.stance,
            rgb = st.rgb,
            nitro = st.nitro,
            custom_handling = st.customHandling and st.customHandling.profiles or nil
        })
    end

    return true
end
