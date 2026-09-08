if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/xenon_sync.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/xenon_sync.lua
--  Deobfuscated & Cleaned
-- =====================================================

XenonSync = XenonSync or {}

local STATE_BAG_KEY = "sky_mechanicjob:xenonCustomColor"

local function clampColorByte(value)
    return math.floor(math.max(0, math.min(255, tonumber(value) or 0)))
end

local function parseColorTable(colorData)
    if type(colorData) ~= "table" then return nil end
    return {
        r = clampColorByte(colorData.r),
        g = clampColorByte(colorData.g),
        b = clampColorByte(colorData.b)
    }
end

local function applyCustomXenonColor(vehicle, color)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if type(color) ~= "table" then return end

    ToggleVehicleMod(vehicle, 22, true)
    SetVehicleXenonLightsColor(vehicle, 255)
    SetVehicleXenonLightsCustomColor(vehicle, color.r, color.g, color.b)
end

local function isCustomXenonColorApplied(vehicle, color)
    if vehicle == 0 or not DoesEntityExist(vehicle) or type(color) ~= "table" then
        return false
    end

    local currentColor = math.floor(tonumber(GetVehicleXenonLightsColor(vehicle)) or -1)
    if currentColor ~= 255 then
        return false
    end

    local _ok, curR = GetVehicleXenonLightsCustomColor(vehicle)
    return clampColorByte(curR) == color.r
end

local function applyXenonFromStateBag(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then return end
    if not IsToggleModOn(vehicle, 22) then return end

    local stateBagData = Entity(vehicle).state[STATE_BAG_KEY]
    local color = parseColorTable(stateBagData)
    if not color then return end

    applyCustomXenonColor(vehicle, color)
end

function XenonSync.SetCustomColor(vehicle, colorData)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local color = parseColorTable(colorData)
    if not color then
        Entity(vehicle).state:set(STATE_BAG_KEY, false, true)
        return
    end

    Entity(vehicle).state:set(STATE_BAG_KEY, color, true)
end

local function handleStateBagXenonChange(bagName, value, retryCount)
    local entity = GetEntityFromStateBagName(bagName)

    if entity ~= 0 and DoesEntityExist(entity) and IsEntityAVehicle(entity) then
        if not IsToggleModOn(entity, 22) then return end
        local color = parseColorTable(value)
        if color then
            applyCustomXenonColor(entity, color)
        end
        return
    end

    retryCount = (retryCount or 0) + 1
    if retryCount > 8 then return end

    SetTimeout(120, function()
        handleStateBagXenonChange(bagName, value, retryCount)
    end)
end

AddStateBagChangeHandler(STATE_BAG_KEY, nil, function(bagName, _key, value)
    handleStateBagXenonChange(bagName, value, 0)
end)

AddEventHandler("entityCreated", function(entity)
    if entity == 0 or not DoesEntityExist(entity) or not IsEntityAVehicle(entity) then return end

    SetTimeout(0, function()
        applyXenonFromStateBag(entity)
    end)

    SetTimeout(250, function()
        applyXenonFromStateBag(entity)
    end)
end)
