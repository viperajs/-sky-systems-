if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/nitro.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/nitro.lua
--  Nitro Kit Installation, Bottle Management & State Sync
-- =====================================================

local INSTALL_DISTANCE = 10.0

-- Install and level updates read, change and write the same row; DB awaits yield between them.
local busyPlates = {}

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

local function getMaxBottles()
    return math.max(1, math.floor(tonumber(Config and Config.Nitro and Config.Nitro.maxBottles) or 3))
end

local function getMaxLevel()
    return math.max(1, math.floor(tonumber(Config and Config.Nitro and Config.Nitro.maxLevel) or 100))
end

local function getNitroItemName()
    return tostring((Config and Config.Nitro and Config.Nitro.item) or "nitro_kit")
end

--- Normalizes a stored or client-sent record to the client format (bottleLevels plus derived totals).
local function normalizeNitro(raw)
    if type(raw) ~= "table" then return nil end

    local maxLevel, maxBottles = getMaxLevel(), getMaxBottles()
    local levels = {}

    if type(raw.bottleLevels) == "table" then
        for _, value in ipairs(raw.bottleLevels) do
            local level = tonumber(value)
            if level and level > 0 and #levels < maxBottles then
                levels[#levels + 1] = math.min(maxLevel, level)
            end
        end
    elseif raw.installed == true then
        -- Older rows only store a bottle count and a total level.
        local remaining = math.max(0, tonumber(raw.level) or maxLevel)
        for _ = 1, math.min(maxBottles, math.max(1, math.floor(tonumber(raw.bottles) or 1))) do
            if remaining <= 0 then break end
            levels[#levels + 1] = math.min(maxLevel, remaining)
            remaining = remaining - levels[#levels]
        end
    end

    local total = 0
    for _, level in ipairs(levels) do
        total = total + level
    end

    return {
        installed = #levels > 0,
        bottleLevels = levels,
        bottles = #levels,
        level = total,
        capacity = #levels * maxLevel,
        installedAt = tostring(raw.installedAt or ""):sub(1, 32)
    }
end

local function withPlateLock(plate, fn, ...)
    if busyPlates[plate] then
        return { success = false, error = "busy" }
    end

    busyPlates[plate] = true
    local ok, result = pcall(fn, ...)
    busyPlates[plate] = nil

    if not ok then error(result, 0) end
    return result
end

--- The driver, or the player who just left the driver seat, of the vehicle with this plate.
local function isVehicleDriver(src, plate)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 or sanitizePlate(GetVehicleNumberPlateText(vehicle)) ~= plate then
        vehicle = Functions.GetNearbyVehicleByPlate(src, plate, INSTALL_DISTANCE) or 0
    end
    if vehicle == 0 then return false end

    if GetPedInVehicleSeat(vehicle, -1) == ped then return true end
    return GetLastPedInVehicleSeat ~= nil and GetLastPedInVehicleSeat(vehicle, -1) == ped
end

-- ── Install / Add Bottle Callback ─────────────────────

local function installNitro(src, plate, itemName)
    local existing = TuningDB.GetVehicleTuning(plate)
    local current = normalizeNitro(type(existing) == "table" and existing.nitro or nil)
    local maxBottles = getMaxBottles()
    local action = "install"
    local nitro

    if current and current.installed then
        if current.bottles >= maxBottles then
            return { success = false, error = "max_bottles" }
        end

        local levels = {}
        for i, level in ipairs(current.bottleLevels) do
            levels[i] = level
        end
        levels[#levels + 1] = getMaxLevel()

        nitro = normalizeNitro({ bottleLevels = levels, installedAt = current.installedAt })
        action = "add_bottle"
    else
        nitro = normalizeNitro({ bottleLevels = { getMaxLevel() }, installedAt = os.date("%Y-%m-%d %H:%M:%S") })
    end

    if not Functions.RemoveItem(src, itemName, 1) then
        return { success = false, error = "missing_item" }
    end

    -- Fails for plates without an ownership row while requireOwnedVehicle is on.
    if not TuningDB.SaveVehicleTuning(plate, { nitro = nitro }) then
        Functions.AddItem(src, itemName, 1)
        return { success = false, error = "save_failed" }
    end

    VehicleHistory.Add(
        plate,
        "nitro_installed",
        string.format("Nitro bottle installed (%d/%d)", nitro.bottles, maxBottles),
        src,
        0
    )

    return {
        success = true,
        action = action,
        nitro = nitro
    }
end

Sky.Cb.Register("sky_mechanicjob:nitro:install", function(source, data)
    local src = tonumber(source)
    if not src or src <= 0 then return { success = false, error = "invalid_source" } end

    local isMechanicOnly = not (Config and Config.Nitro and Config.Nitro.mechanicOnly == false)
    if isMechanicOnly and not Functions.IsMechanicOnDuty(src) then
        TriggerClientEvent("sky_mechanicjob:nitro:showError", src, "not_authorized")
        return { success = false, error = "not_authorized" }
    end

    local plate = sanitizePlate(type(data) == "table" and data.plate)
    if plate == "" then
        return { success = false, error = "invalid_plate" }
    end

    if not Functions.GetNearbyVehicleByPlate(src, plate, INSTALL_DISTANCE) then
        return { success = false, error = "vehicle_not_found" }
    end

    local itemName = getNitroItemName()
    if not Functions.HasItem(src, itemName, 1) then
        return { success = false, error = "missing_item" }
    end

    return withPlateLock(plate, installNitro, src, plate, itemName)
end)

-- ── Update State Callback ─────────────────────────────

local function lowerNitroLevel(plate, reportedRaw)
    local existing = TuningDB.GetVehicleTuning(plate)
    local stored = normalizeNitro(type(existing) == "table" and existing.nitro or nil)
    if not stored or not stored.installed then
        return { success = false, error = "not_installed" }
    end

    local reported = normalizeNitro(reportedRaw)
    local target = math.min(stored.level, reported and reported.level or 0)
    if target >= stored.level then
        return { success = true }
    end

    -- Drain from the last bottle like the client does; the result can only be lower than what is stored.
    local levels, drain = {}, stored.level - target
    for i, level in ipairs(stored.bottleLevels) do
        levels[i] = level
    end
    for i = #levels, 1, -1 do
        if drain <= 0 then break end
        local used = math.min(levels[i], drain)
        levels[i] = levels[i] - used
        drain = drain - used
        if levels[i] <= 0 then
            table.remove(levels, i)
        end
    end

    local nitro = normalizeNitro({ bottleLevels = levels, installedAt = stored.installedAt })
    if not TuningDB.SaveVehicleTuning(plate, { nitro = nitro }) then
        return { success = false, error = "save_failed" }
    end

    return { success = true }
end

Sky.Cb.Register("sky_mechanicjob:nitro:updateState", function(source, data)
    local src = tonumber(source)
    local plate = sanitizePlate(type(data) == "table" and data.plate)
    if not src or src <= 0 or plate == "" or type(data.nitro) ~= "table" then
        return { success = false, error = "invalid_payload" }
    end

    if not isVehicleDriver(src, plate) then
        return { success = false, error = "not_driver" }
    end

    return withPlateLock(plate, lowerNitroLevel, plate, data.nitro)
end)
