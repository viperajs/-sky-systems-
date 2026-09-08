if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/vehicle_history.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_mechanicjob · source/server/vehicle_history.lua
--  Vehicle Service & Tuning History Logging
-- =====================================================

VehicleHistory = VehicleHistory or {}

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

--- Add entry to vehicle service history
---@param plate string
---@param action string
---@param description string
---@param mechanicSourceOrName number|string
---@param price? number
---@return boolean
function VehicleHistory.Add(plate, action, description, mechanicSourceOrName, price)
    local cleanPlate = sanitizePlate(plate)
    if cleanPlate == "" or not action then return false end

    local mechIdentifier = "system"
    local mechName = "Mechanic"

    if type(mechanicSourceOrName) == "number" and mechanicSourceOrName > 0 then
        mechIdentifier = Functions.GetIdentifier(mechanicSourceOrName)
        mechName = Functions.GetName(mechanicSourceOrName)
    elseif type(mechanicSourceOrName) == "string" and mechanicSourceOrName ~= "" then
        mechName = mechanicSourceOrName
        mechIdentifier = mechanicSourceOrName
    end

    price = math.max(0, math.floor(tonumber(price) or 0))

    pcall(function()
        MySQL.insert.await([[
            INSERT INTO sky_mechanic_vehicle_history (plate, action, description, mechanic_identifier, mechanic_name, price)
            VALUES (@plate, @action, @description, @mechanic_identifier, @mechanic_name, @price)
        ]], {
            ["@plate"] = cleanPlate,
            ["@action"] = tostring(action),
            ["@description"] = tostring(description or ""),
            ["@mechanic_identifier"] = tostring(mechIdentifier),
            ["@mechanic_name"] = tostring(mechName),
            ["@price"] = price
        })
    end)

    return true
end

registerExport("AddVehicleHistory", function(plate, action, description, mechanic, price)
    return VehicleHistory.Add(plate, action, description, mechanic, price)
end)

-- ── Server Callback: Get Vehicle History ─────────────

Sky.Cb.Register("sky_mechanicjob:vehicles:getHistory", function(source, data)
    local plate = sanitizePlate(data and data.plate)
    if plate == "" then
        return { success = false, error = "invalid_plate", data = { history = {} } }
    end

    local rows = MySQL.query.await([[
        SELECT id, plate, action, description, mechanic_identifier, mechanic_name, price, date
        FROM sky_mechanic_vehicle_history
        WHERE plate = @plate
        ORDER BY date DESC
        LIMIT 100
    ]], { ["@plate"] = plate }) or {}

    local historyList = {}
    for _, row in ipairs(rows) do
        historyList[#historyList + 1] = {
            id = row.id,
            plate = row.plate,
            action = row.action,
            description = row.description,
            mechanic_identifier = row.mechanic_identifier,
            mechanic_name = row.mechanic_name,
            price = row.price,
            date = row.date
        }
    end

    return {
        success = true,
        data = {
            history = historyList
        }
    }
end)
