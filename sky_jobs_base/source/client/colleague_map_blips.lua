if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/colleague_map_blips.lua") end
-- =====================================================
--  sky_jobs_base · source/client/colleague_map_blips.lua
--  Deobfuscated & Cleaned
-- =====================================================

local config = (Config and Config.ColleagueMapBlips) or {}
if config.enabled ~= true then return end

local activeBlips = {}
local officersData = {}
local blipHandles = {}
local isTracking = false
local lastSnapshotTime = 0

local function getBlipDisplayMode()
    if config.showOnMinimap == true then
        return tonumber(config.display) or 4
    end
    return 2
end

local function isTrackingAllowed()
    local isOnDuty = Sky_Jobs.Access and Sky_Jobs.Access.IsOnDuty and Sky_Jobs.Access.IsOnDuty()
    if not isOnDuty then return false end

    if config.showOnMinimap == true then
        return true
    end
    return IsPauseMenuActive()
end

local function getSnapshotInterval()
    return tonumber(config.pauseMenuSnapshotIntervalMs) or 750
end

local function getRenderInterval()
    return tonumber(config.pauseMenuRenderIntervalMs) or tonumber(config.updateIntervalMs) or 250
end

local function removeBlipObj(data)
    if data and data.blip and DoesBlipExist(data.blip) then
        RemoveBlip(data.blip)
    end
    if data then
        data.blip = nil
    end
end

local function removeAllBlipHandles()
    for _, bHandle in ipairs(blipHandles) do
        if bHandle and DoesBlipExist(bHandle) then
            RemoveBlip(bHandle)
        end
    end
    blipHandles = {}
end

local function clearAllColleagueBlips()
    for _, data in pairs(activeBlips) do
        removeBlipObj(data)
    end
    removeAllBlipHandles()
    activeBlips = {}
    officersData = {}
end

local function removeOfficerBlip(id)
    local key = tostring(id)
    officersData[key] = nil

    local data = activeBlips[key]
    if data then
        removeBlipObj(data)
        activeBlips[key] = nil
    end
end

local function getSpriteForVehicle(vehType, lightsOn)
    local spritesMap = config.sprites or {}
    if lightsOn then
        local lightsSpriteKey = tostring(vehType) .. "_lights"
        if spritesMap[lightsSpriteKey] then
            return spritesMap[lightsSpriteKey]
        end
    end
    return spritesMap[vehType] or spritesMap.foot or 1
end

local function getColorForLights(lightsOn)
    if lightsOn and config.colorLights then
        return config.colorLights
    end
    return config.color or 3
end

local function updateBlipDisplay(data, coords)
    if data.blip and not DoesBlipExist(data.blip) then
        data.blip = nil
    end

    if not data.blip then
        if not (coords and coords.x and coords.y) then return end

        local b = AddBlipForCoord(coords.x, coords.y, coords.z or 0.0)
        data.blip = b
        blipHandles[#blipHandles + 1] = b

        local defaultSprite = (config.sprites and config.sprites.foot) or 1
        SetBlipSprite(b, defaultSprite)
        SetBlipColour(b, config.color or 3)
        SetBlipDisplay(b, getBlipDisplayMode())
        SetBlipScale(b, config.scale or 0.85)
        SetBlipAsShortRange(b, config.shortRange == true)
    end

    if coords and coords.x and coords.y then
        SetBlipCoords(data.blip, coords.x, coords.y, coords.z or 0.0)
    end
end

local function updateBlipAppearance(data, name, vehType, lightsOn, heading)
    local sprite = getSpriteForVehicle(vehType, lightsOn)
    local color = getColorForLights(lightsOn)

    if lightsOn and config.colorLightsAlt then
        local interval = tonumber(config.colorLightsIntervalMs) or 450
        local phase = math.floor(GetGameTimer() / interval) % 2
        if phase == 1 then
            color = config.colorLightsAlt
        end
    end

    SetBlipSprite(data.blip, sprite)
    SetBlipColour(data.blip, color)
    SetBlipFlashes(data.blip, lightsOn == true)

    if heading then
        SetBlipRotation(data.blip, math.floor(heading + 0.5))
    end

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(name)
    EndTextCommandSetBlipName(data.blip)
end

local function processOfficerData(id, officerInfo)
    if not officerInfo then return end

    local strId = tostring(id)
    local vType = type(officerInfo.vehicleType) == "string" and officerInfo.vehicleType ~= "" and officerInfo.vehicleType or "foot"
    local lightsOn = officerInfo.lightsOn == true
    local heading = officerInfo.heading
    local name = officerInfo.name or officerInfo.callsign or ("Colleague " .. strId)

    local blipData = activeBlips[strId]
    if not blipData then
        blipData = {}
        activeBlips[strId] = blipData
    end

    updateBlipDisplay(blipData, officerInfo.coords)
    if blipData.blip then
        updateBlipAppearance(blipData, name, vType, lightsOn, heading)
    end
end

local function updateOfficerSnapshot(list)
    local presentMap = {}
    if type(list) == "table" then
        for _, item in ipairs(list) do
            local numId = tonumber(item.id)
            if numId then
                local strId = tostring(numId)
                presentMap[strId] = true
                officersData[strId] = item
            end
        end
    end

    for strId in pairs(officersData) do
        if not presentMap[strId] then
            removeOfficerBlip(strId)
        end
    end
end

local function shouldShowOfficer(id)
    if config.showSelf == true then
        return true
    end
    local myServerId = tostring(GetPlayerServerId(PlayerId()))
    return tostring(id) ~= myServerId
end

local function handleOfficerUpdate(list)
    if isTracking and isTrackingAllowed() then
        if type(list) == "table" then
            updateOfficerSnapshot(list)
        end
    end
end

local function pollOfficerSnapshot()
    local now = GetGameTimer()
    if (now - lastSnapshotTime) < getSnapshotInterval() then
        return
    end

    lastSnapshotTime = now
    local res = Sky.Cb.Trigger("sky_jobs_base:map:getOfficers")
    if res and res.success and res.data and res.data.officers then
        handleOfficerUpdate(res.data.officers)
    end
end

local function renderAllBlips()
    for strId, info in pairs(officersData) do
        if shouldShowOfficer(strId) then
            processOfficerData(tonumber(strId), info)
        else
            removeOfficerBlip(strId)
        end
    end
end

RegisterNetEvent("sky_jobs_base:map:updateOfficers", function(data)
    if type(data) == "table" then
        handleOfficerUpdate(data.officers)
    end
end)

CreateThread(function()
    while true do
        if isTrackingAllowed() then
            if not isTracking then
                clearAllColleagueBlips()
                isTracking = true
                lastSnapshotTime = 0
            end

            pollOfficerSnapshot()
            renderAllBlips()
            Wait(getRenderInterval())
        else
            if isTracking or next(activeBlips) or next(officersData) then
                isTracking = false
                clearAllColleagueBlips()
            end
            Wait(500)
        end
    end
end)

RegisterNetEvent("sky_jobs_base:creator:updatePlayerDuty", function(onDuty)
    if not onDuty then
        isTracking = false
        clearAllColleagueBlips()
    end
end)

RegisterNetEvent("sky_jobs_base:colleagueMapBlips:remove", function(id)
    removeOfficerBlip(id)
end)

AddEventHandler("onResourceStop", function(resName)
    if resName == GetCurrentResourceName() then
        clearAllColleagueBlips()
    end
end)
