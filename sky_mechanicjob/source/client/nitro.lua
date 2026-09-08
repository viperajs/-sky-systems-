if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/nitro.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/nitro.lua
--  Deobfuscated by Claude
--  Original: 3385 lines → Cleaned
-- =====================================================

local State = {
    installBusy = false,
    recordsByPlate = {},
    activeVehicle = 0,
    activePlate = "",
    active = false,
    boostBlend = 0.0,
    activeEffectAt = 0,
    activePurgeAt = 0,
    lastSaveAtByPlate = {},
    lastHintPlate = "",
    remoteEffects = {},
    hudVisible = false,
    lastHudLevel = -1,
    lastHudSignature = "",
    hudHideToken = 0,
    priming = false,
    primingVehicle = 0,
    primingPlate = "",
    primingUntil = 0,
    controlHeld = false,
    runtimeActive = false,
    runtimeToken = 0,
    runtimeVehicle = 0,
    lastTickAt = 0,
    remoteLoopRunning = false,
    lastHudUpdateAt = 0,
    lastNoNitroNotifyAt = 0,
    lastShakeAt = 0,
    runtimeConfig = nil,
    boostCheckCache = {
        vehicle = 0,
        plate = "",
        nextCheckAt = 0,
        result = false
    }
}

local STATE_BAG_NITRO_ACTIVE = "sky_mechanic_nitro_active"
local DEFAULT_EXHAUST_BONES = {
    "exhaust", "exhaust_2", "exhaust_3", "exhaust_4",
    "exhaust_5", "exhaust_6", "exhaust_7", "exhaust_8",
    "exhaust_9", "exhaust_10", "exhaust_11", "exhaust_12",
    "exhaust_13", "exhaust_14", "exhaust_15", "exhaust_16"
}
local DEFAULT_PURGE_NOZZLES = {
    { bone = "wheel_lf", offset = { x = 0.03, y = 0.1, z = 0.2 }, rotation = { x = 20.0, y = 0.0, z = 0.5 } },
    { bone = "wheel_rf", offset = { x = -0.03, y = 0.1, z = 0.2 }, rotation = { x = 20.0, y = 0.0, z = 0.5 } }
}

local DEFAULT_CDN_IMAGE_BASE = "https://cdn.sky-systems.net/items"
local cachedCdnImageBase = nil

-- Forward declarations
local stopNitroBoost
local resetPrimingState
local resetBoostCache
local hideHud

-- ============================================================
--  NOTIFICATIONS & CONFIG
-- ============================================================

local function showNotify(msg, ntype)
    if type(msg) ~= "string" or msg == "" then return end
    local title = tuningLocales and tuningLocales.Title or "Tuning"
    Sky.Show.Notification(title, msg, ntype or "info")
end

local function getNitroConfig()
    return (Config and Config.Nitro) or {}
end

local function getRuntimeConfig()
    local cfg = getNitroConfig()

    local rampIn = tonumber(cfg.boostRampInPerSecond) or 4.0
    local rampOut = tonumber(cfg.boostRampOutPerSecond) or 2.2
    local throttleThresh = math.max(0.0, math.min(1.0, tonumber(cfg.throttleThreshold) or 0.85))
    local activeTick = math.max(10, math.floor(tonumber(cfg.activeTickMs) or 25))
    local inputCheckInterval = math.max(20, math.floor(tonumber(cfg.inputCheckIntervalMs) or 120))
    local emptyHudHideDelay = math.max(0, math.floor(tonumber(cfg.emptyHudHideDelayMs) or 1200))
    local saveInterval = math.max(250, math.floor(tonumber(cfg.saveIntervalMs) or 4000))
    local hudIdleInterval = math.max(50, math.floor(tonumber(cfg.hudUpdateIntervalIdleMs) or 300))
    local hudActiveInterval = math.max(16, math.floor(tonumber(cfg.hudUpdateIntervalActiveMs) or 80))
    local maxLevel = math.max(1, math.floor(tonumber(cfg.maxLevel) or 100))
    local installDuration = math.max(250, math.floor(tonumber(cfg.installDurationMs) or 6000))
    local installDist = math.max(0.1, tonumber(cfg.installDistance) or 3.8)
    local installFrontDist = math.max(0.1, tonumber(cfg.installFrontDistance) or 2.4)
    local effectInterval = math.max(16, math.floor(tonumber(cfg.effectIntervalMs) or 180))
    local remoteEffectInterval = math.max(16, math.floor(tonumber(cfg.remoteEffectIntervalMs) or 320))
    local flameScale = math.max(0.1, tonumber(cfg.flameScale) or 0.72)
    local flameDuration = math.max(16, math.floor(tonumber(cfg.flameDurationMs) or 110))
    local purgeScale = math.max(0.1, tonumber(cfg.purgeScale) or 0.9)
    local purgeDuration = math.max(16, math.floor(tonumber(cfg.purgeDurationMs) or 2000))
    local purgeTickInterval = math.max(16, math.floor(tonumber(cfg.purgeTickIntervalMs) or 220))
    local purgeHoldDuration = math.max(16, math.floor(tonumber(cfg.purgeHoldDurationMs) or 260))
    local screenShake = math.max(0.0, tonumber(cfg.screenShake) or 0.14)
    local shakeInterval = math.max(16, math.floor(tonumber(cfg.shakeIntervalMs) or 100))

    if rampIn <= 0 then rampIn = 4.0 end
    if rampOut <= 0 then rampOut = 2.2 end

    State.runtimeConfig = {
        boostRampInPerSecond = rampIn,
        boostRampOutPerSecond = rampOut,
        powerMultiplier = tonumber(cfg.powerMultiplier) or 32.0,
        torqueMultiplier = tonumber(cfg.torqueMultiplier) or 1.32,
        minSpeedKmh = tonumber(cfg.minSpeedKmh) or 25.0,
        throttleThreshold = throttleThresh,
        drainPerSecond = tonumber(cfg.drainPerSecond) or 8.5,
        effectIntervalMs = effectInterval,
        flameScale = flameScale,
        flameDurationMs = flameDuration,
        purgeScale = purgeScale,
        purgeDurationMs = purgeDuration,
        purgeTickIntervalMs = purgeTickInterval,
        purgeHoldDurationMs = purgeHoldDuration,
        purgeEnabled = cfg.purgeEnabled ~= false,
        screenShake = screenShake,
        shakeIntervalMs = shakeInterval,
        activeTickMs = activeTick,
        remoteEffectIntervalMs = remoteEffectInterval,
        inputCheckIntervalMs = inputCheckInterval,
        emptyHudHideDelayMs = emptyHudHideDelay,
        saveIntervalMs = saveInterval,
        hudUpdateIntervalIdleMs = hudIdleInterval,
        hudUpdateIntervalActiveMs = hudActiveInterval,
        maxLevel = maxLevel,
        installDurationMs = installDuration,
        installDistance = installDist,
        installFrontDistance = installFrontDist,
        exhaustBoneNames = type(cfg.exhaustBoneNames) == "table" and cfg.exhaustBoneNames or DEFAULT_EXHAUST_BONES,
        purgeNozzles = type(cfg.purgeNozzles) == "table" and cfg.purgeNozzles or DEFAULT_PURGE_NOZZLES
    }
    return State.runtimeConfig
end

local function getValidRuntimeConfig()
    if type(State.runtimeConfig) ~= "table" then
        getRuntimeConfig()
    end
    return State.runtimeConfig
end

local function getNitroItemName()
    return tostring(getNitroConfig().item or "nitro_kit")
end

local function getNitroKey()
    local key = tostring(getNitroConfig().activationKey or "")
    return key ~= "" and key or "LSHIFT"
end

local function getMaxBottles()
    return math.max(1, math.floor(tonumber(getNitroConfig().maxBottles) or 1))
end

-- ============================================================
--  RECORD & LEVEL HELPERS
-- ============================================================

local function normalizeBottleLevels(record, targetBottles, maxLevelVal)
    local maxLevel = maxLevelVal or getValidRuntimeConfig().maxLevel
    local result = {}
    local inputLevels = (record and type(record.bottleLevels) == "table") and record.bottleLevels or nil

    if inputLevels then
        for _, lvl in ipairs(inputLevels) do
            if #result >= targetBottles then break end
            local parsedLvl = math.max(0, math.min(maxLevel, tonumber(lvl) or 0))
            table.insert(result, parsedLvl)
        end
    end

    local currentTotal = math.max(0, tonumber(record and record.level) or 0)

    if #result == 0 and targetBottles > 0 then
        local rem = currentTotal
        for _ = 1, targetBottles do
            local lvl = math.min(maxLevel, rem)
            table.insert(result, lvl)
            rem = math.max(0, rem - lvl)
        end
    end

    while targetBottles > #result do
        table.insert(result, maxLevel)
    end

    for i = #result, 1, -1 do
        if result[i] <= 0 then
            table.remove(result, i)
        end
    end

    return result
end

local function recalculateNitroRecord(record)
    if type(record) ~= "table" then return nil end

    local maxLevel = getValidRuntimeConfig().maxLevel
    local levels = {}

    if type(record.bottleLevels) == "table" then
        for _, lvl in ipairs(record.bottleLevels) do
            local parsed = math.max(0, math.min(maxLevel, tonumber(lvl) or 0))
            if parsed > 0 then
                table.insert(levels, parsed)
            end
        end
    end

    local bottleCount = math.min(getMaxBottles(), #levels)
    while #levels > bottleCount do
        table.remove(levels)
    end

    local totalLevel = 0
    for _, lvl in ipairs(levels) do
        totalLevel = totalLevel + lvl
    end

    record.bottleLevels = levels
    record.bottles = bottleCount
    record.capacity = bottleCount * maxLevel
    record.level = totalLevel
    record.installed = (bottleCount > 0 and record.installed ~= false)

    return record
end

-- ============================================================
--  HUD & DISPLAY HELPERS
-- ============================================================

local function getHudConfig()
    return getNitroConfig().hud or {}
end

local function isHudEnabled()
    return getHudConfig().enabled ~= false
end

local function getHudPosition()
    local pos = getHudConfig().position or {}
    local left = type(pos.left) == "string" and pos.left ~= "" and pos.left or nil
    local right = type(pos.right) == "string" and pos.right ~= "" and pos.right or nil
    local top = type(pos.top) == "string" and pos.top ~= "" and pos.top or nil
    local bottom = type(pos.bottom) == "string" and pos.bottom ~= "" and pos.bottom or nil
    return { left = left, right = right, top = top, bottom = bottom }
end

local function cleanPlateText(plate)
    local str = Sky.Math.Trim(tostring(plate or ""))
    return str == "" and "" or string.upper(str)
end

local function getPlateText(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return "" end
    return cleanPlateText(GetVehicleNumberPlateText(vehicle))
end

local function sanitizeNitroRecord(rawRecord)
    if type(rawRecord) ~= "table" then return nil end

    local maxLevel = getValidRuntimeConfig().maxLevel
    local maxBot = getMaxBottles()

    local rawCap = math.floor(math.max(0, tonumber(rawRecord.capacity) or 0))
    local rawBottles = math.floor(math.max(0, tonumber(rawRecord.bottles) or 0))
    local isInstalled = rawRecord.installed ~= false

    if rawBottles <= 0 and rawCap > 0 then
        rawBottles = math.max(1, math.ceil(rawCap / maxLevel))
    end
    if rawBottles <= 0 and isInstalled then
        rawBottles = 1
    end

    local finalBottles = math.max(0, math.min(maxBot, rawBottles))
    local finalCap = math.max(0, finalBottles * maxLevel)
    local rawLevel = tonumber(rawRecord.level) or finalCap
    local finalLevel = math.max(0, math.min(finalCap, rawLevel))

    local newRecord = {
        installed = isInstalled,
        bottleLevels = normalizeBottleLevels(rawRecord, finalBottles, finalLevel),
        installedAt = tostring(rawRecord.installedAt or "")
    }

    return recalculateNitroRecord(newRecord)
end

local function setNitroRecordForPlate(plate, rawRecord)
    local cleanP = cleanPlateText(plate)
    if cleanP == "" then return nil end

    local sanitized = sanitizeNitroRecord(rawRecord)
    if not sanitized then
        State.recordsByPlate[cleanP] = nil
        return nil
    end

    State.recordsByPlate[cleanP] = sanitized
    return sanitized
end

function NitroSystem_IsInstalledForVehicle(vehicle)
    local record = State.recordsByPlate[getPlateText(vehicle)]
    return type(record) == "table"
end

local function getExhaustLocalOffset(vehicle, boneName)
    local boneIdx = GetEntityBoneIndexByName(vehicle, tostring(boneName or ""))
    if boneIdx == -1 then return nil end

    local worldPos = GetWorldPositionOfEntityBone(vehicle, boneIdx)
    return GetOffsetFromEntityGivenWorldCoords(vehicle, worldPos.x, worldPos.y, worldPos.z)
end

local function sendNuiMsg(action, payload)
    if not isHudEnabled() then return end
    SendNUIMessage({
        action = action,
        payload = payload or {}
    })
end

local function getNuiImageBase()
    if cachedCdnImageBase ~= nil then
        return cachedCdnImageBase
    end

    local imgBases = Sky.Cb.Trigger("sky_jobs_base:getNuiImageBases") or {}
    local baseStr = tostring(imgBases.itemImageBase or DEFAULT_CDN_IMAGE_BASE)
    if baseStr == "" then baseStr = DEFAULT_CDN_IMAGE_BASE end

    cachedCdnImageBase = string.gsub(baseStr, "/+$", "")
    return cachedCdnImageBase
end

hideHud = function()
    if State.hudVisible ~= true then return end

    State.hudVisible = false
    State.lastHudLevel = -1
    State.lastHudSignature = ""
    State.lastHudUpdateAt = 0

    sendNuiMsg("nitroHud:hide", {})
end

local function scheduleHideHud(delayMs)
    local delay = math.max(0, math.floor(tonumber(delayMs) or 0))
    State.hudHideToken = (State.hudHideToken or 0) + 1
    local currentToken = State.hudHideToken

    if delay <= 0 then
        hideHud()
        return
    end

    CreateThread(function()
        Wait(delay)
        if currentToken ~= State.hudHideToken then return end
        if State.active or State.priming then return end
        hideHud()
    end)
end

local function getNitroHudSignature(record)
    if type(record) ~= "table" then return "" end

    local parts = {}
    local levels = record.bottleLevels or {}

    for idx, lvl in ipairs(levels) do
        table.insert(parts, ("%s:%0.2f"):format(idx, tonumber(lvl) or 0.0))
    end
    table.insert(parts, ("level:%0.2f"):format(tonumber(record.level) or 0.0))
    table.insert(parts, ("bottles:%s"):format(tostring(record.bottles or 0)))

    return table.concat(parts, "|")
end

local function showHud(record)
    if type(record) ~= "table" then
        hideHud()
        return
    end

    local levels = record.bottleLevels or {}
    State.hudHideToken = (State.hudHideToken or 0) + 1

    local roundedLvl = math.floor(tonumber(record.level) or 0)
    local signature = getNitroHudSignature(record)

    State.hudVisible = true
    State.lastHudLevel = roundedLvl
    State.lastHudSignature = signature
    State.lastHudUpdateAt = GetGameTimer()

    sendNuiMsg("nitroHud:show", {
        bottleLevels = levels,
        bottles = tonumber(record.bottles) or #levels,
        maxBottles = getMaxBottles(),
        bottleCapacity = getValidRuntimeConfig().maxLevel,
        itemImageBase = getNuiImageBase(),
        position = getHudPosition()
    })
end

local function updateHud(record, force)
    if type(record) ~= "table" then
        hideHud()
        return
    end

    local roundedLvl = math.floor(tonumber(record.level) or 0)
    local signature = getNitroHudSignature(record)
    local now = GetGameTimer()
    local cfg = getValidRuntimeConfig()

    local minInterval = State.active and cfg.hudUpdateIntervalActiveMs or cfg.hudUpdateIntervalIdleMs

    if not force and State.lastHudSignature == signature then return end
    if not force and (now - State.lastHudUpdateAt) < minInterval then return end

    State.hudVisible = true
    State.lastHudLevel = roundedLvl
    State.lastHudSignature = signature
    State.lastHudUpdateAt = now

    local cap = tonumber(record.capacity) or 0
    local pct = (cap > 0) and ((tonumber(record.level) or 0.0) / cap * 100.0) or 0.0

    sendNuiMsg("nitroHud:update", {
        bottleLevels = record.bottleLevels or {},
        bottles = tonumber(record.bottles) or #(record.bottleLevels or {}),
        maxBottles = getMaxBottles(),
        bottleCapacity = cfg.maxLevel,
        totalLevel = tonumber(record.level) or 0.0,
        totalPercent = pct,
        itemImageBase = getNuiImageBase()
    })
end

-- ============================================================
--  PARTICLE & VISUAL EFFECTS
-- ============================================================

local function playLoopedParticleEffect(assetName, effectName, entity, offset, rotation, scale, durationMs)
    UseParticleFxAssetNextCall("core")
    local ptfxHandle = StartParticleFxLoopedOnEntity(
        effectName, entity,
        offset.x, offset.y, offset.z,
        rotation.x, rotation.y, rotation.z,
        scale, false, false, false
    )

    if not ptfxHandle or ptfxHandle == 0 then
        print(("[sky_mechanicjob][nitro] particle effect start failed: effect=%s vehicle=%s offset=(%.2f,%.2f,%.2f)")
            :format(tostring(effectName), tostring(entity), offset.x, offset.y, offset.z))
        return
    end

    SetParticleFxLoopedAlpha(ptfxHandle, 0.8)
    SetParticleFxLoopedScale(ptfxHandle, scale)

    CreateThread(function()
        Wait(durationMs)
        StopParticleFxLooped(ptfxHandle, false)
    end)
end

local function triggerExhaustFlames(vehicle, intensity)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        return
    end

    local cfg = getValidRuntimeConfig()
    local scaleFactor = math.max(0.35, math.min(1.0, tonumber(intensity) or 1.0))

    VehicleEffects.PlayBackfire(vehicle, {
        source = "nitro",
        scale = cfg.flameScale * scaleFactor,
        durationMs = cfg.flameDurationMs,
        exhaustBoneNames = cfg.exhaustBoneNames
    })
end

local function triggerPurgeSteam(vehicle, intensity)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local cfg = getValidRuntimeConfig()
    if not cfg.purgeEnabled then return end

    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        return
    end

    local scaleFactor = math.max(0.35, math.min(1.0, tonumber(intensity) or 1.0))
    local purgeScale = cfg.purgeScale * scaleFactor
    local purgeDuration = cfg.purgeHoldDurationMs or cfg.purgeDurationMs
    local spawnedAny = false

    for _, nozzle in ipairs(getValidRuntimeConfig().purgeNozzles or {}) do
        local bonePos = getExhaustLocalOffset(vehicle, nozzle.bone)
        if bonePos then
            local offset = nozzle.offset or {}
            local rot = nozzle.rotation or {}

            local finalOffset = {
                x = bonePos.x + (tonumber(offset.x) or 0.0),
                y = bonePos.y + (tonumber(offset.y) or 0.0),
                z = bonePos.z + (tonumber(offset.z) or 0.0)
            }
            local finalRot = {
                x = tonumber(rot.x) or 20.0,
                y = tonumber(rot.y) or 0.0,
                z = tonumber(rot.z) or 0.5
            }

            playLoopedParticleEffect("core", "ent_sht_steam", vehicle, finalOffset, finalRot, purgeScale, purgeDuration)
            spawnedAny = true
        end
    end

    if spawnedAny then return end

    local bonnetPos = getExhaustLocalOffset(vehicle, "bonnet")
    if bonnetPos then
        local purgeOffsets = {
            { x = bonnetPos.x - 0.45, y = bonnetPos.y + 0.08, z = bonnetPos.z + 0.02 },
            { x = bonnetPos.x + 0.45, y = bonnetPos.y + 0.08, z = bonnetPos.z + 0.02 }
        }
        local defaultRot = { x = 28.0, y = 0.0, z = 0.0 }

        for _, pos in ipairs(purgeOffsets) do
            playLoopedParticleEffect("core", "ent_sht_steam", vehicle, pos, defaultRot, purgeScale, purgeDuration)
        end
    end
end

-- ============================================================
--  NITRO SYSTEM STATE SAVING & NETWORK SYNC
-- ============================================================

local function saveNitroStateServer(plate, record, force)
    local cleanP = cleanPlateText(plate)
    if cleanP == "" then return end

    local sanitized = sanitizeNitroRecord(record)
    if not sanitized then return end

    local now = GetGameTimer()
    local lastSave = State.lastSaveAtByPlate[cleanP] or 0

    if not force and (now - lastSave) < getValidRuntimeConfig().saveIntervalMs then
        return
    end

    State.lastSaveAtByPlate[cleanP] = now
    Sky.Cb.Trigger("sky_mechanicjob:nitro:updateState", {
        plate = cleanP,
        nitro = sanitized
    })
end

local function setNitroStateBag(vehicle, active)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    Entity(vehicle).state:set(STATE_BAG_NITRO_ACTIVE, active == true, true)
end

local function resetVehicleEnginePower(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    SetVehicleEnginePowerMultiplier(vehicle, 0.0)
    SetVehicleEngineTorqueMultiplier(vehicle, 1.0)
end

resetPrimingState = function()
    State.priming = false
    State.primingVehicle = 0
    State.primingPlate = ""
    State.primingUntil = 0
    State.activePurgeAt = 0
    State.lastShakeAt = 0
end

resetBoostCache = function()
    State.boostCheckCache.vehicle = 0
    State.boostCheckCache.plate = ""
    State.boostCheckCache.nextCheckAt = 0
    State.boostCheckCache.result = false
end

local function primeNitroPurge(vehicle, plate, record)
    if vehicle == 0 or not DoesEntityExist(vehicle) or type(record) ~= "table" then return end

    local cfg = getValidRuntimeConfig()
    State.priming = true
    State.primingVehicle = vehicle
    State.primingPlate = plate
    State.primingUntil = GetGameTimer() + cfg.purgeDurationMs
    State.activePurgeAt = GetGameTimer()

    showHud(record)
    updateHud(record, true)
    triggerPurgeSteam(vehicle, 1.0)
end

stopNitroBoost = function(vehicle, record, save, hideDelayMs)
    local plate = State.activePlate

    if State.active and vehicle ~= 0 and DoesEntityExist(vehicle) then
        resetVehicleEnginePower(vehicle)
        setNitroStateBag(vehicle, false)
    end

    StopGameplayCamShaking(true)

    State.active = false
    State.activeVehicle = 0
    State.activePlate = ""
    State.boostBlend = 0.0
    State.activeEffectAt = 0
    State.lastShakeAt = 0

    resetPrimingState()
    resetBoostCache()
    scheduleHideHud(hideDelayMs)

    if save and vehicle ~= 0 and DoesEntityExist(vehicle) then
        local targetPlate = (plate ~= "") and plate or getPlateText(vehicle)
        saveNitroStateServer(targetPlate, record, save == true)
    end
end

local function updateBoostBlend(boosting, deltaTimeMs)
    local cfg = getValidRuntimeConfig()
    local rate = boosting and cfg.boostRampInPerSecond or -cfg.boostRampOutPerSecond
    local deltaSec = deltaTimeMs / 1000.0

    State.boostBlend = math.max(0.0, math.min(1.0, State.boostBlend + (rate * deltaSec)))
    return State.boostBlend
end

local function applyEngineBoost(vehicle, blendFactor)
    local cfg = getValidRuntimeConfig()
    local blend = math.max(0.0, math.min(1.0, tonumber(blendFactor) or 0.0))

    local pMult = cfg.powerMultiplier * blend
    local tMult = 1.0 + ((cfg.torqueMultiplier - 1.0) * blend)

    SetVehicleEnginePowerMultiplier(vehicle, pMult)
    SetVehicleEngineTorqueMultiplier(vehicle, tMult)
end

local function canVehicleNitroBoost(vehicle, record)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    if type(record) ~= "table" or record.installed ~= true or (tonumber(record.level) or 0) <= 0 or (tonumber(record.bottles) or 0) <= 0 then
        return false
    end

    if State.controlHeld ~= true then return false end

    local activePlate = State.activePlate
    local now = GetGameTimer()
    local cache = State.boostCheckCache

    if cache.vehicle == vehicle and cache.plate == activePlate and now < (cache.nextCheckAt or 0) then
        return cache.result == true
    end

    if GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then
        cache.vehicle = vehicle
        cache.plate = activePlate
        cache.nextCheckAt = now + getValidRuntimeConfig().inputCheckIntervalMs
        cache.result = false
        return false
    end

    if not GetIsVehicleEngineRunning(vehicle) or not IsVehicleOnAllWheels(vehicle) then
        cache.vehicle = vehicle
        cache.plate = activePlate
        cache.nextCheckAt = now + getValidRuntimeConfig().inputCheckIntervalMs
        cache.result = false
        return false
    end

    local cfg = getValidRuntimeConfig()
    local throttle = GetControlNormal(0, 71)
    local speedKmh = GetEntitySpeed(vehicle) * 3.6

    if throttle < cfg.throttleThreshold or speedKmh < cfg.minSpeedKmh then
        cache.vehicle = vehicle
        cache.plate = activePlate
        cache.nextCheckAt = now + cfg.inputCheckIntervalMs
        cache.result = false
        return false
    end

    cache.vehicle = vehicle
    cache.plate = activePlate
    cache.nextCheckAt = now + cfg.inputCheckIntervalMs
    cache.result = true
    return true
end

local function applyNitroTick(vehicle, record, deltaTimeMs)
    local cfg = getValidRuntimeConfig()
    local drainRate = cfg.drainPerSecond
    local effectInterval = cfg.effectIntervalMs

    local blend = updateBoostBlend(true, deltaTimeMs)
    applyEngineBoost(vehicle, blend)

    local drainAmount = drainRate * blend * (deltaTimeMs / 1000.0)
    local levels = record.bottleLevels or {}

    while drainAmount > 0 and #levels > 0 do
        local lastIdx = #levels
        local currentLvl = math.max(0, tonumber(levels[lastIdx]) or 0)

        if drainAmount >= currentLvl then
            drainAmount = drainAmount - currentLvl
            table.remove(levels, lastIdx)
        else
            levels[lastIdx] = currentLvl - drainAmount
            drainAmount = 0
        end
    end

    record.bottleLevels = levels
    recalculateNitroRecord(record)

    local now = GetGameTimer()

    if blend > 0 and (now - State.lastShakeAt) >= cfg.shakeIntervalMs then
        State.lastShakeAt = now
        ShakeGameplayCam("SKY_DIVING_SHAKE", cfg.screenShake * blend)
    end

    if (now - State.activeEffectAt) >= effectInterval then
        State.activeEffectAt = now
        triggerExhaustFlames(vehicle, blend)
    end

    if cfg.purgeEnabled and (now - State.activePurgeAt) >= cfg.purgeTickIntervalMs then
        State.activePurgeAt = now
        triggerPurgeSteam(vehicle, blend)
    end

    if (tonumber(record.level) or 0) <= 0 or (tonumber(record.bottles) or 0) <= 0 then
        record.bottleLevels = {}
        record.level = 0
        record.bottles = 0
        record.capacity = 0
        record.installed = false
        recalculateNitroRecord(record)

        showNotify(tuningLocales and tuningLocales.NitroEmpty or "Nitro bottle is empty.", "error")
        stopNitroBoost(vehicle, record, true, cfg.emptyHudHideDelayMs)
    end
end

function NitroSystem_GetSuggestedWaitMs(vehicle)
    if Config and Config.ToggleFeatures and Config.ToggleFeatures.nitro == false then
        return 250
    end
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 250
    end

    local cfg = getValidRuntimeConfig()

    if State.active and State.activeVehicle == vehicle then
        return cfg.activeTickMs
    end
    if State.priming and State.primingVehicle == vehicle then
        return cfg.activeTickMs
    end
    if State.controlHeld ~= true then
        return 250
    end

    local record = State.recordsByPlate[getPlateText(vehicle)]
    if record and record.installed == true then
        return cfg.activeTickMs
    end

    return 250
end

function NitroSystem_TickVehicle(vehicle, gameTime)
    local lastTick = State.lastTickAt > 0 and State.lastTickAt or gameTime
    local deltaMs = math.max(1, gameTime - lastTick)
    State.lastTickAt = gameTime

    local plate = (State.activeVehicle == vehicle and State.activePlate ~= "") and State.activePlate or getPlateText(vehicle)
    if plate == "" then return end

    local record = State.recordsByPlate[plate]
    if not record or record.installed ~= true then
        if State.activeVehicle ~= 0 then
            stopNitroBoost(State.activeVehicle, State.recordsByPlate[State.activePlate], true)
        else
            hideHud()
        end
        return
    end

    State.activeVehicle = vehicle
    State.activePlate = plate

    if canVehicleNitroBoost(vehicle, record) then
        if not State.active then
            State.active = true
            State.activeEffectAt = 0
            setNitroStateBag(vehicle, true)
            showHud(record)
            triggerPurgeSteam(vehicle, 1.0)
        end

        applyNitroTick(vehicle, record, deltaMs)
        updateHud(record, false)
        saveNitroStateServer(plate, record, false)
        return
    end

    local blend = updateBoostBlend(false, deltaMs)
    if State.active then
        if blend > 0.02 then
            applyEngineBoost(vehicle, blend)
        else
            resetVehicleEnginePower(vehicle)
            showHud(record)
            updateHud(record, false)
        end
    end
end

function NitroSystem_OnDriverLeftVehicle()
    State.lastTickAt = 0
    resetBoostCache()

    if State.activeVehicle ~= 0 then
        local record = State.recordsByPlate[State.activePlate]
        stopNitroBoost(State.activeVehicle, record, true)
    end

    if State.lastHintPlate ~= "" then
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            State.lastHintPlate = ""
        end
    end

    State.hudHideToken = (State.hudHideToken or 0) + 1
    hideHud()
end

function NitroSystem_ShouldRunForVehicle(vehicle)
    if Config and Config.ToggleFeatures and Config.ToggleFeatures.nitro == false then
        return false
    end
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return false
    end

    if State.active and State.activeVehicle == vehicle then return true end
    if State.priming and State.primingVehicle == vehicle then return true end
    if State.controlHeld ~= true then return false end

    local record = State.recordsByPlate[getPlateText(vehicle)]
    if not record or record.installed ~= true then return false end

    return GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
end

local function stopRuntimeLoop()
    State.runtimeToken = State.runtimeToken + 1
    State.runtimeVehicle = 0
    State.runtimeConfig = nil
    resetBoostCache()

    if State.runtimeActive then
        NitroSystem_OnDriverLeftVehicle()
        State.runtimeActive = false
    end
end

local function startRuntimeLoopForVehicle(vehicle)
    if not NitroSystem_ShouldRunForVehicle(vehicle) then
        stopRuntimeLoop()
        return
    end

    if State.runtimeActive and State.runtimeVehicle == vehicle then
        return
    end

    stopRuntimeLoop()
    State.runtimeToken = State.runtimeToken + 1
    State.runtimeVehicle = vehicle
    State.runtimeActive = true

    getRuntimeConfig()
    local currentToken = State.runtimeToken

    CreateThread(function()
        while currentToken == State.runtimeToken and NitroSystem_ShouldRunForVehicle(vehicle) do
            local now = GetGameTimer()
            NitroSystem_TickVehicle(vehicle, now)
            local waitMs = math.max(0, math.floor(tonumber(NitroSystem_GetSuggestedWaitMs(vehicle)) or 250))
            Wait(waitMs)
        end

        if currentToken == State.runtimeToken then
            stopRuntimeLoop()
        end
    end)
end

function NitroSystem_SyncRuntimeForCurrentVehicle()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not NitroSystem_ShouldRunForVehicle(vehicle) then
        stopRuntimeLoop()
        return
    end
    startRuntimeLoopForVehicle(vehicle)
end

-- ============================================================
--  INSTALLATION & ITEM HANDLING
-- ============================================================

local function getVehicleInFrontForNitroInstall()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local cfg = getValidRuntimeConfig()

    local searchDist = math.max(cfg.installDistance, cfg.installFrontDistance) + 0.5
    local forwardCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, math.min(cfg.installFrontDistance, cfg.installDistance), 0.0)

    local veh1 = getClosestVehicleWithPoliceFallback(pedCoords.x, pedCoords.y, pedCoords.z, searchDist, 0, 70)
    local veh2 = getClosestVehicleWithPoliceFallback(forwardCoords.x, forwardCoords.y, forwardCoords.z, searchDist, 0, 70)

    local candidates = { veh1, veh2 }
    local checked = {}
    local bestVeh = 0
    local bestDist = cfg.installFrontDistance + 0.01

    for _, veh in ipairs(candidates) do
        if veh ~= 0 and not checked[veh] and DoesEntityExist(veh) and not IsEntityDead(veh) then
            checked[veh] = true
            local vehCoords = GetEntityCoords(veh)
            local dist = #(pedCoords - vehCoords)

            if dist <= cfg.installDistance then
                local bonnetBone = GetEntityBoneIndexByName(veh, "bonnet")
                local targetPos = (bonnetBone ~= -1) and GetWorldPositionOfEntityBone(veh, bonnetBone) or GetOffsetFromEntityInWorldCoords(veh, 0.0, 2.0, 0.3)

                local distToTarget = #(pedCoords - targetPos)
                if distToTarget <= cfg.installFrontDistance and distToTarget < bestDist then
                    bestDist = distToTarget
                    bestVeh = veh
                end
            end
        end
    end

    return bestVeh
end

local function playNitroInstallAnimation(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then return false end

    TaskTurnPedToFaceEntity(ped, vehicle, 700)

    if not IsVehicleDoorDamaged(vehicle, 4) then
        SetVehicleDoorOpen(vehicle, 4, false, false)
    end

    showNotify(tuningLocales and tuningLocales.NitroInstallStarted or "Hood opened. Installing nitro system...", "info")
    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)

    Wait(getValidRuntimeConfig().installDurationMs)

    ClearPedTasksImmediately(ped)
    ClearPedSecondaryTask(ped)

    if DoesEntityExist(vehicle) and not IsVehicleDoorDamaged(vehicle, 4) then
        SetVehicleDoorShut(vehicle, 4, false)
    end

    return true
end

local function startNitroInstallation()
    if Config and Config.ToggleFeatures and Config.ToggleFeatures.nitro == false then return end

    if State.installBusy then
        showNotify(tuningLocales and tuningLocales.NitroInstallBusy or "Nitro installation is already in progress.", "error")
        return
    end

    local vehicle = getVehicleInFrontForNitroInstall()
    if vehicle == 0 then
        showNotify(tuningLocales and tuningLocales.NitroInstallNoVehicle or "Stand in front of a nearby vehicle to install the nitro kit.", "error")
        return
    end

    if GetVehicleNumberOfPassengers(vehicle) > 0 or GetPedInVehicleSeat(vehicle, -1) ~= 0 then
        showNotify(tuningLocales and tuningLocales.NitroInstallVehicleOccupied or "The vehicle must be empty before installing nitro.", "error")
        return
    end

    State.installBusy = true

    if not playNitroInstallAnimation(vehicle) or vehicle == 0 or not DoesEntityExist(vehicle) then
        State.installBusy = false
        showNotify(tuningLocales and tuningLocales.NitroInstallFailed or "Nitro installation failed.", "error")
        return
    end

    local plate = getPlateText(vehicle)
    local vehObj = Sky.Vehicle:new(vehicle)
    local props = vehObj:GetVehicleProperties()

    local response = Sky.Cb.Trigger("sky_mechanicjob:nitro:install", {
        plate = plate,
        properties = props
    }) or {}

    State.installBusy = false

    if type(response) == "table" and response.success == true and type(response.nitro) == "table" then
        local newRecord = setNitroRecordForPlate(plate, response.nitro)
        if newRecord then
            saveTuningForVehicle(vehicle)
        end

        if tostring(response.action or "") == "add_bottle" then
            showNotify(
                (tuningLocales and tuningLocales.NitroBottleAdded or "Nitro bottle installed successfully (%s/%s).")
                    :format(tostring(newRecord and newRecord.bottles or 1), tostring(getMaxBottles())),
                "success"
            )
        else
            showNotify(tuningLocales and tuningLocales.NitroInstallSuccess or "Nitro system installed successfully.", "success")
        end
        return
    end

    if type(response) == "table" and response.error == "missing_item" then
        showNotify(("%s: %s"):format(getNuiLocale("tablet.orders.missing_item", "Missing required item"), getNitroItemName()), "error")
        return
    end

    if type(response) == "table" and response.error == "max_bottles" then
        showNotify(
            (tuningLocales and tuningLocales.NitroBottleLimitReached or "This vehicle already has the maximum number of nitro bottles installed (%s).")
                :format(tostring(getMaxBottles())),
            "error"
        )
        return
    end

    showNotify(tuningLocales and tuningLocales.NitroInstallFailed or "Nitro installation failed.", "error")
end

-- ============================================================
--  EVENTS & COMMANDS
-- ============================================================

RegisterNetEvent("sky_mechanicjob:nitro:beginInstall", function()
    startNitroInstallation()
end)

RegisterNetEvent("sky_mechanicjob:nitro:showError", function(errType)
    if errType == "not_authorized" then
        showNotify(tuningLocales and tuningLocales.NitroInstallNoPermission or "Only mechanics can install nitro kits.", "error")
        return
    end
    showNotify(tuningLocales and tuningLocales.NitroInstallFailed or "Nitro installation failed.", "error")
end)

function NitroSystem_GetPersistedState(vehicle)
    return sanitizeNitroRecord(State.recordsByPlate[getPlateText(vehicle)])
end

function NitroSystem_ApplyPersistedStateToVehicle(vehicle, plate, nitroData)
    local cleanP = cleanPlateText(plate)
    if cleanP == "" then cleanP = getPlateText(vehicle) end

    if cleanP == "" then return end

    setNitroRecordForPlate(cleanP, nitroData)
    local record = State.recordsByPlate[cleanP]

    if not record or record.installed ~= true then return end
    if getNitroConfig().notifyOnVehicleEnter == false then return end
    if State.lastHintPlate == cleanP then return end

    State.lastHintPlate = cleanP
    showNotify(tuningLocales and tuningLocales.NitroVehicleReady or "Nitro installed. Hold SHIFT while accelerating to use it.", "info")
end

AddStateBagChangeHandler(STATE_BAG_NITRO_ACTIVE, nil, function(bagName, key, value)
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 or not DoesEntityExist(entity) then return end

    local netId = NetworkGetNetworkIdFromEntity(entity)

    if value then
        State.remoteEffects[netId] = { vehicle = entity, nextEffectAt = 0 }
        if not State.remoteLoopRunning then
            State.remoteLoopRunning = true
            CreateThread(function()
                while next(State.remoteEffects) ~= nil do
                    local now = GetGameTimer()
                    for id, data in pairs(State.remoteEffects) do
                        if data.vehicle == 0 or not DoesEntityExist(data.vehicle) then
                            State.remoteEffects[id] = nil
                        elseif State.activeVehicle ~= data.vehicle or not State.active then
                            if now >= (data.nextEffectAt or 0) then
                                triggerExhaustFlames(data.vehicle, 1.0)
                                data.nextEffectAt = now + getValidRuntimeConfig().remoteEffectIntervalMs
                            end
                        end
                    end
                    Wait(50)
                end
                State.remoteLoopRunning = false
            end)
        end
    else
        State.remoteEffects[netId] = nil
    end
end)

local function setControlState(isPressed)
    local pressed = isPressed == true
    if State.controlHeld == pressed then return end

    State.controlHeld = pressed

    if pressed then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if NitroSystem_ShouldRunForVehicle(veh) then
            local record = State.recordsByPlate[getPlateText(veh)]
            if not record or record.installed ~= true then
                local now = GetGameTimer()
                if (now - State.lastNoNitroNotifyAt) >= 1500 then
                    State.lastNoNitroNotifyAt = now
                    showNotify(tuningLocales and tuningLocales.NitroNotInstalled or "No nitro system installed on this vehicle.", "error")
                end
            end
        end
        NitroSystem_SyncRuntimeForCurrentVehicle()
        return
    end

    stopRuntimeLoop()
end

RegisterCommand("+sky_mechanicjob_nitro", function() setControlState(true) end, false)
RegisterCommand("-sky_mechanicjob_nitro", function() setControlState(false) end, false)
RegisterKeyMapping("+sky_mechanicjob_nitro", "Nitro Control", "keyboard", getNitroKey())

CreateThread(function()
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
        Wait(0)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    stopRuntimeLoop()
    hideHud()
end)
