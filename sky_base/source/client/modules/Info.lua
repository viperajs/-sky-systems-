if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/modules/Info.lua") end
-- =====================================================
--  sky_base · source/client/modules/Info.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Info = Sky.Info or {}

--- Gets weapon spawn name from its hash.
---@param hash number
---@return string|nil
function Sky.Info.GetWeaponFromHash(hash)
    if not hash then return nil end
    for _, weaponName in ipairs(Sky.Info.weapons or {}) do
        if GetHashKey(weaponName) == hash then
            return weaponName
        end
    end
    return nil
end

--- Gets weapon category type string from model/hash.
---@param weapon string|number
---@return string|nil
function Sky.Info.GetWeaponType(weapon)
    local hash = type(weapon) == "number" and weapon or joaat(weapon)
    local group = GetWeapontypeGroup(hash)
    return Sky.Info.weaponTypes and Sky.Info.weaponTypes[group]
end

--- Gets vehicle class name from model/hash.
---@param vehicle string|number
---@return string|nil
function Sky.Info.GetVehicleClass(vehicle)
    local hash = type(vehicle) == "number" and vehicle or joaat(vehicle)
    local classIdx = GetVehicleClassFromName(hash)
    return Sky.Info.vehicleClasses and Sky.Info.vehicleClasses[classIdx]
end

--- Calculates detailed vehicle handling/performance stats.
---@param vehicle string|number
---@return table
function Sky.Info.GetVehicleStats(vehicle)
    local hash = type(vehicle) == "number" and vehicle or joaat(vehicle)

    local maxSpeed = math.floor(GetVehicleModelEstimatedMaxSpeed(hash) * 3.6)
    if Sky.Config and Sky.Config.useMph then
        maxSpeed = math.floor(GetVehicleModelEstimatedMaxSpeed(hash) * 2.23694)
    end

    local seats = GetVehicleModelNumberOfSeats(hash)
    local classIdx = GetVehicleClassFromName(hash)
    local accel = GetVehicleModelAcceleration(hash)
    local braking = GetVehicleModelMaxBraking(hash)
    local traction = GetVehicleModelMaxTraction(hash)

    local function getAccelTime(a)
        if a < 0.2 then return 12 end
        if a < 0.3 then return 8 end
        if a < 0.32 then return 4 end
        if a < 0.35 then return 3 end
        return 2
    end

    local topSpeedNorm = math.min(1.0, GetVehicleModelEstimatedMaxSpeed(hash) / 62.3)
    local accelNorm = math.min(1.0, accel / 0.4)
    local brakingNorm = math.min(1.0, braking / 3.0)

    return {
        maxSpeed = maxSpeed,
        accelerationTime = getAccelTime(accel),
        seats = seats,
        vehicleType = Sky.Info.vehicleClasses and Sky.Info.vehicleClasses[classIdx],
        topSpeed = topSpeedNorm,
        acceleration = accelNorm,
        braking = brakingNorm,
        traction = traction / 3.3
    }
end

--- Unpacks a little-endian integer from a binary string blob.
local function getIntFromBlob(blobData, size, offset)
    local val = 0
    for i = 1, size do
        local byteVal = string.byte(blobData, offset + i)
        val = val | (byteVal << ((i - 1) * 8))
    end
    return val
end

--- Gets weapon HUD stats (damage, speed, capacity, accuracy, range).
---@param weapon string|number
---@return table
function Sky.Info.GetWeaponStats(weapon)
    local hash = type(weapon) == "number" and weapon or joaat(weapon)

    local blob = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"
    Citizen.InvokeNative(0x247F0F3A96C2B4E0, hash, blob, Citizen.ReturnResultAnyway())

    local hudDamage = getIntFromBlob(blob, 8, 0)
    local hudSpeed = getIntFromBlob(blob, 8, 8)
    local hudCapacity = getIntFromBlob(blob, 8, 16)
    local hudAccuracy = getIntFromBlob(blob, 8, 24)
    local hudRange = getIntFromBlob(blob, 8, 32)

    return {
        clipSize = GetWeaponClipSize(hash),
        weaponType = Sky.Info.weaponTypes and Sky.Info.weaponTypes[GetWeapontypeGroup(hash)],
        damage = hudDamage / 100,
        speed = hudSpeed * 0.01,
        capacity = hudCapacity,
        accuracy = hudAccuracy * 0.011,
        range = hudRange * 0.015
    }
end
