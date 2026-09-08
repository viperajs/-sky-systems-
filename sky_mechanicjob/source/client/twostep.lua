if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/twostep.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/twostep.lua
--  Deobfuscated & Cleaned
-- =====================================================

TwoStep = TwoStep or {}

local twostepState = {
    recordsByPlate = {},
    activeVehicle = 0,
    activePlate = "",
    activeRecord = nil,
    nextBurstAt = 0,
    nextSyncAt = 0,
    nextTurboPressureAt = 0,
    launchHoldApplied = false,
    launchReleaseStartAt = 0,
    launchReleaseEndAt = 0,
    launchReleaseStartMultiplier = 1.0,
    runtimeVehicle = 0,
    runtimePlate = "",
    runtimeRecord = nil
}

local DEFAULT_CONFIG = {
    enabled = true,
    defaultEnabled = false,
    defaultFlameScaleLevel = 7,
    defaultVolumeLevel = 4,
    burstIntervalMinMs = 90,
    burstIntervalMaxMs = 170,
    syncIntervalMs = 300,
    flameDurationMs = 75,
    flameScaleMin = 0.45,
    flameScaleMax = 1.25,
    maxSpeedKmh = 12.0,
    minGear = 1,
    maxGear = 1,
    rpmWindowMin = 0.32,
    rpmWindowMax = 0.58,
    rpmWindowSize = 0.26,
    turboPressureSpikeEnabled = true,
    turboPressureSpike = 12.0,
    useFootBrake = true,
    useHandbrake = false,
    launchControlEnabled = true,
    launchHoldHandbrake = true,
    launchRpmTarget = 0.46,
    launchHoldTorqueMultiplier = 0.28,
    launchReleaseRampMs = 420,
    launchReleaseStartMultiplier = 0.45
}

local config = {}

local function clampNumber(val, minVal, maxVal)
    local num = tonumber(val)
    if not num then return minVal end
    if minVal > num then return minVal end
    if maxVal < num then return maxVal end
    return num
end

local function loadConfig()
    local cfg = Config and Config.TwoStep
    if type(cfg) ~= "table" then cfg = {} end

    local launchCfg = type(cfg.launchControl) == "table" and cfg.launchControl or {}
    local toggleCfg = Config and Config.ToggleFeatures

    config.enabled = (toggleCfg and toggleCfg.twoStep) ~= false
    config.defaultEnabled = (cfg.defaultEnabled == true)

    config.defaultFlameScaleLevel = math.floor(clampNumber(cfg.defaultFlameScaleLevel or DEFAULT_CONFIG.defaultFlameScaleLevel, 1, 10))
    config.defaultVolumeLevel = math.floor(clampNumber(cfg.defaultVolumeLevel or DEFAULT_CONFIG.defaultVolumeLevel, 0, 10))

    config.burstIntervalMinMs = math.floor(clampNumber(cfg.burstIntervalMinMs or DEFAULT_CONFIG.burstIntervalMinMs, 20, 3000))
    config.burstIntervalMaxMs = math.floor(clampNumber(cfg.burstIntervalMaxMs or DEFAULT_CONFIG.burstIntervalMaxMs, 20, 3000))
    if config.burstIntervalMaxMs < config.burstIntervalMinMs then
        config.burstIntervalMaxMs = config.burstIntervalMinMs
    end

    config.syncIntervalMs = math.max(config.burstIntervalMinMs, 300)
    config.flameDurationMs = math.floor(clampNumber(cfg.flameDurationMs or DEFAULT_CONFIG.flameDurationMs, 25, 3000))
    config.flameScaleMin = clampNumber(cfg.flameScaleMin or DEFAULT_CONFIG.flameScaleMin, 0.05, 5.0)
    config.flameScaleMax = clampNumber(cfg.flameScaleMax or DEFAULT_CONFIG.flameScaleMax, config.flameScaleMin, 8.0)
    config.maxSpeedKmh = clampNumber(cfg.maxSpeedKmh or DEFAULT_CONFIG.maxSpeedKmh, 1.0, 120.0)

    config.minGear = math.floor(clampNumber(cfg.minGear or DEFAULT_CONFIG.minGear, 1, 10))
    config.maxGear = math.floor(clampNumber(cfg.maxGear or DEFAULT_CONFIG.maxGear, config.minGear, 10))

    config.rpmWindowMin = clampNumber(cfg.rpmWindowMin or DEFAULT_CONFIG.rpmWindowMin, 0.05, 0.99)
    config.rpmWindowMax = clampNumber(cfg.rpmWindowMax or DEFAULT_CONFIG.rpmWindowMax, config.rpmWindowMin + 0.01, 1.0)
    config.rpmWindowSize = math.max(0.01, config.rpmWindowMax - config.rpmWindowMin)

    config.turboPressureSpikeEnabled = (cfg.turboPressureSpikeEnabled == true)
    config.turboPressureSpike = clampNumber(cfg.turboPressureSpike or DEFAULT_CONFIG.turboPressureSpike, 0.0, 50.0)

    config.useFootBrake = (cfg.useFootBrake == true)
    config.useHandbrake = (cfg.useHandbrake == nil) or (cfg.useHandbrake == true)

    config.launchControlEnabled = (launchCfg.enabled == nil) or (launchCfg.enabled == true)
    config.launchHoldHandbrake = (launchCfg.holdHandbrake == nil) or (launchCfg.holdHandbrake == true)
    config.launchRpmTarget = clampNumber(launchCfg.rpmTarget or DEFAULT_CONFIG.launchRpmTarget, 0.05, 0.99)
    config.launchHoldTorqueMultiplier = clampNumber(launchCfg.holdTorqueMultiplier or DEFAULT_CONFIG.launchHoldTorqueMultiplier, 0.0, 1.0)
    config.launchReleaseRampMs = math.floor(clampNumber(launchCfg.releaseRampMs or DEFAULT_CONFIG.launchReleaseRampMs, 0, 5000))
    config.launchReleaseStartMultiplier = clampNumber(launchCfg.releaseTorqueStartMultiplier or DEFAULT_CONFIG.launchReleaseStartMultiplier, 0.0, 1.0)
end

loadConfig()
AddEventHandler("sky_mechanicjob:jobConfigurator:updated", loadConfig)

-- ── Helpers ──────────────────────────────────────────

local function normalizePlate(plate)
    local trimmed = Sky.Math.Trim(tostring(plate or ""))
    return (trimmed ~= "") and string.upper(trimmed) or ""
end

local function getVehiclePlate(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return "" end
    return normalizePlate(GetVehicleNumberPlateText(vehicle))
end

local function isDefaultEnabled()
    return config.defaultEnabled == true
end

local function getDefaultFlameScaleLevel()
    return config.defaultFlameScaleLevel
end

local function getDefaultVolumeLevel()
    return config.defaultVolumeLevel
end

local function getRandomBurstInterval()
    local minMs = config.burstIntervalMinMs
    local maxMs = config.burstIntervalMaxMs
    if minMs < maxMs then
        return math.random(minMs, maxMs)
    end
    return minMs
end

local function getFormattedTimestamp()
    return string.format(
        "%04d-%02d-%02d %02d:%02d:%02d",
        GetClockYear(),
        GetClockMonth() + 1,
        GetClockDayOfMonth(),
        GetClockHours(),
        GetClockMinutes(),
        GetClockSeconds()
    )
end

-- ── Record Management ────────────────────────────────

local function sanitizeRecord(rec)
    if type(rec) ~= "table" then return nil end

    local flameLevel = math.floor(clampNumber(rec.flameScaleLevel or getDefaultFlameScaleLevel(), 1, 10))
    local volLevel = math.floor(clampNumber(rec.volumeLevel or getDefaultVolumeLevel(), 0, 10))

    return {
        installed = rec.installed == true,
        enabled = (rec.enabled ~= nil) and (rec.enabled == true) or isDefaultEnabled(),
        flameScaleLevel = flameLevel,
        volumeLevel = volLevel,
        installedAt = tostring(rec.installedAt or "")
    }
end

local function filterRecord(rec)
    if type(rec) ~= "table" then return nil end
    local sanitized = sanitizeRecord(rec)
    if not sanitized then return nil end
    sanitized.installed = rec.installed == true
    return sanitized
end

local function createDefaultRecord(enabled)
    return {
        installed = true,
        enabled = enabled == true,
        flameScaleLevel = getDefaultFlameScaleLevel(),
        volumeLevel = getDefaultVolumeLevel(),
        installedAt = getFormattedTimestamp()
    }
end

local function setRecordByPlate(plate, record)
    local cleanPlate = normalizePlate(plate)
    if cleanPlate == "" then return nil end

    local cleanRecord = filterRecord(record)
    if not cleanRecord then
        twostepState.recordsByPlate[cleanPlate] = nil
        if twostepState.runtimePlate == cleanPlate then
            twostepState.runtimeRecord = nil
        end
        return nil
    end

    twostepState.recordsByPlate[cleanPlate] = cleanRecord
    if twostepState.runtimePlate == cleanPlate then
        twostepState.runtimeRecord = cleanRecord
    end
    return cleanRecord
end

local function getRecordByPlate(plate)
    return twostepState.recordsByPlate[normalizePlate(plate)]
end

local function resolveVehicleRecord(vehicle)
    if vehicle == twostepState.runtimeVehicle and twostepState.runtimeRecord ~= nil then
        return twostepState.runtimePlate, twostepState.runtimeRecord
    end

    local plate = getVehiclePlate(vehicle)
    local rec = (plate ~= "") and twostepState.recordsByPlate[plate] or nil

    twostepState.runtimeVehicle = vehicle
    twostepState.runtimePlate = plate
    twostepState.runtimeRecord = rec

    return plate, rec
end

local function calculateFlameScale(record)
    local level = math.floor(clampNumber(record and record.flameScaleLevel or getDefaultFlameScaleLevel(), 1, 10))
    level = math.max(getDefaultFlameScaleLevel(), level)

    local pct = (level - 1) / 9.0
    return config.flameScaleMin + (config.flameScaleMax - config.flameScaleMin) * pct
end

-- ── Fire Backfire Effect ─────────────────────────────

local function triggerBackfireEffect(vehicle, record, intensityScale)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        return false
    end

    local flameScale = calculateFlameScale(record)
    local scaleMult = math.max(0.35, math.min(1.0, tonumber(intensityScale) or 1.0))
    local finalScale = flameScale * scaleMult

    return VehicleEffects.PlayBackfire(vehicle, {
        source = "twostep",
        scale = finalScale,
        durationMs = config.flameDurationMs
    })
end

local function playTwostepBurst(vehicle, record, intensity)
    if not triggerBackfireEffect(vehicle, record, intensity) then
        return false
    end

    local volLevel = math.floor(clampNumber(record and record.volumeLevel or getDefaultVolumeLevel(), 0, 10))
    volLevel = math.max(getDefaultVolumeLevel(), volLevel)

    if volLevel <= 0 then
        return true
    end

    local coords = GetEntityCoords(vehicle)
    AddExplosion(coords.x, coords.y, coords.z, 61, 0.0, true, true, 0.0, true)
    return true
end

-- ── Active State Reset ───────────────────────────────

local function resetActiveState()
    if twostepState.activeVehicle ~= 0 and DoesEntityExist(twostepState.activeVehicle) then
        if twostepState.launchHoldApplied then
            SetVehicleHandbrake(twostepState.activeVehicle, false)
        end
        SetVehicleEngineTorqueMultiplier(twostepState.activeVehicle, 1.0)
    end

    twostepState.activeVehicle = 0
    twostepState.activePlate = ""
    twostepState.activeRecord = nil
    twostepState.nextBurstAt = 0
    twostepState.nextSyncAt = 0
    twostepState.nextTurboPressureAt = 0
    twostepState.launchHoldApplied = false
    twostepState.launchReleaseStartAt = 0
    twostepState.launchReleaseEndAt = 0
    twostepState.launchReleaseStartMultiplier = 1.0
end

local function checkBrakeInputs(state)
    local footBrake = state and state.brakePressed == true
    local handBrake = IsControlPressed(1, 76)
    local activeBrake = false

    if config.useFootBrake and footBrake then activeBrake = true end
    if config.useHandbrake and handBrake then activeBrake = true end

    return activeBrake, footBrake, handBrake
end

local function shouldTriggerTwostep(vehicle, record, state)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    if type(record) ~= "table" or not record.installed or record.enabled == false then return false end
    if GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then return false end
    if not state.engineRunning then return false end

    local activeBrake = checkBrakeInputs(state)
    if not state.throttlePressed or not activeBrake then return false end

    if state.gear < config.minGear or state.gear > config.maxGear then return false end
    if state.speedKmh > config.maxSpeedKmh then return false end

    return state.rpm >= config.rpmWindowMin
end

-- ── Launch Control ───────────────────────────────────

local function applyLaunchControl(vehicle, _state)
    if config.launchControlEnabled ~= true then return end

    if config.launchHoldHandbrake then
        SetVehicleHandbrake(vehicle, true)
        twostepState.launchHoldApplied = true
    end

    SetVehicleCurrentRpm(vehicle, config.launchRpmTarget)
    SetVehicleEngineTorqueMultiplier(vehicle, config.launchHoldTorqueMultiplier)
end

local function startLaunchRelease(now)
    local rampMs = math.max(0, math.floor(tonumber(config.launchReleaseRampMs) or 0))
    if rampMs <= 0 then
        twostepState.launchReleaseStartAt = 0
        twostepState.launchReleaseEndAt = 0
        twostepState.launchReleaseStartMultiplier = 1.0
        return
    end

    twostepState.launchReleaseStartAt = now
    twostepState.launchReleaseEndAt = now + rampMs

    local startMult = math.max(tonumber(config.launchReleaseStartMultiplier) or 1.0, tonumber(config.launchHoldTorqueMultiplier) or 0.0)
    twostepState.launchReleaseStartMultiplier = clampNumber(startMult, 0.0, 1.0)
end

local function updateLaunchReleaseRamp(vehicle, now)
    if twostepState.launchReleaseEndAt <= 0 then return false end

    if now >= twostepState.launchReleaseEndAt then
        SetVehicleEngineTorqueMultiplier(vehicle, 1.0)
        twostepState.launchReleaseStartAt = 0
        twostepState.launchReleaseEndAt = 0
        twostepState.launchReleaseStartMultiplier = 1.0
        return false
    end

    local totalMs = math.max(1, twostepState.launchReleaseEndAt - twostepState.launchReleaseStartAt)
    local elapsedMs = math.max(0, now - twostepState.launchReleaseStartAt)
    local pct = clampNumber(elapsedMs / totalMs, 0.0, 1.0)

    local startMult = twostepState.launchReleaseStartMultiplier
    local currentMult = startMult + (1.0 - startMult) * pct

    SetVehicleEngineTorqueMultiplier(vehicle, currentMult)
    return true
end

-- ── Tuning UI Integration ────────────────────────────

function TwoStep.AddOptions(vehicle, addOptionCb)
    if type(addOptionCb) ~= "function" or not config.enabled then return end

    local record = getRecordByPlate(getVehiclePlate(vehicle))
    local isInstalled = type(record) == "table"

    addOptionCb(
        "performance",
        "twostep_enabled",
        getNuiLocale("option.label.twostep_enabled", "2-Step"),
        isInstalled,
        "rear",
        { sortOrder = 251 }
    )
end

function TwoStep.ApplyOption(vehicle, option, rawValue)
    if vehicle == 0 or not DoesEntityExist(vehicle) or type(option) ~= "table" then
        return false
    end

    if option.id ~= "twostep_enabled" then return false end

    local valNum = math.floor(tonumber(rawValue) or 0)
    valNum = math.max(option.min or 0, math.min(option.max or 1, valNum))

    local plate = getVehiclePlate(vehicle)
    if plate == "" then
        print("[sky_mechanicjob][twostep] apply failed: vehicle plate missing")
        return false
    end

    local record = getRecordByPlate(plate)
    if type(record) ~= "table" then
        if valNum == 0 then
            option.value = 0
            return true
        end

        record = setRecordByPlate(plate, createDefaultRecord(valNum == 1))
        if not record then
            print(string.format("[sky_mechanicjob][twostep] apply failed: unable to create record for plate %s", tostring(plate)))
            return false
        end
    end

    record.installed = true
    record.enabled = (valNum == 1)
    option.value = valNum

    VehicleEffects.SyncRuntimeForCurrentVehicle()
    return true
end

-- ── Public Interface ─────────────────────────────────

function TwoStep.GetPersistedState(vehicle)
    return sanitizeRecord(getRecordByPlate(getVehiclePlate(vehicle)))
end

function TwoStep.IsInstalledForVehicle(vehicle)
    local plate, record = resolveVehicleRecord(vehicle)
    return type(record) == "table", plate, record
end

function TwoStep.GetSuggestedWaitMs(vehicle, state, record)
    if not record then
        record = select(2, resolveVehicleRecord(vehicle))
    end

    if type(record) ~= "table" or not record.installed or record.enabled == false then
        return 250
    end

    if twostepState.launchReleaseEndAt > GetGameTimer() then
        return 25
    end

    if not state.engineRunning then return 500 end

    if state.speedKmh > config.maxSpeedKmh or state.gear < config.minGear or state.gear > config.maxGear then
        return 250
    end

    local activeBrake = checkBrakeInputs(state)
    if not state.throttlePressed or not activeBrake then
        return 125
    end

    if state.rpm < math.max(0.1, config.rpmWindowMin - 0.1) or state.rpm > (config.rpmWindowMax + 0.1) then
        return 75
    end

    return 25
end

function TwoStep.TickVehicle(vehicle, now, state, plate, record)
    if not record then
        plate, record = resolveVehicleRecord(vehicle)
    end

    if not record or not record.installed then
        if twostepState.activeVehicle ~= 0 then
            resetActiveState()
        end
        return
    end

    twostepState.activeVehicle = vehicle
    twostepState.activePlate = plate
    twostepState.activeRecord = record

    local activeBrake = checkBrakeInputs(state)
    local isTwostepActive = shouldTriggerTwostep(vehicle, record, state)

    if isTwostepActive then
        applyLaunchControl(vehicle, state)

        if config.turboPressureSpikeEnabled then
            if now >= (twostepState.nextTurboPressureAt or 0) then
                SetVehicleTurboPressure(vehicle, config.turboPressureSpike)
                twostepState.nextTurboPressureAt = now + 75
            end
        end

        if now >= (twostepState.nextBurstAt or 0) then
            local intensity = math.max(0.35, math.min(1.0, (state.rpm - config.rpmWindowMin) / config.rpmWindowSize))
            triggerBackfireEffect(vehicle, record, intensity)

            if now >= (twostepState.nextSyncAt or 0) then
                TriggerServerEvent("sky_mechanicjob:twostep:syncBurst", VehToNet(vehicle), {
                    source = GetPlayerServerId(PlayerId()),
                    intensity = intensity,
                    record = {
                        volumeLevel = math.max(0, math.min(10, math.floor(tonumber(record.volumeLevel) or getDefaultVolumeLevel()))),
                        flameScaleLevel = math.max(1, math.min(10, math.floor(tonumber(record.flameScaleLevel) or getDefaultFlameScaleLevel())))
                    }
                })
                twostepState.nextSyncAt = now + config.syncIntervalMs
            end

            twostepState.nextBurstAt = now + getRandomBurstInterval()
        end
    else
        if twostepState.launchHoldApplied then
            SetVehicleHandbrake(vehicle, false)
            twostepState.launchHoldApplied = false

            if state.throttlePressed and not activeBrake then
                startLaunchRelease(now)
            end
        end

        if updateLaunchReleaseRamp(vehicle, now) then
            twostepState.activeVehicle = vehicle
            twostepState.activePlate = plate
            twostepState.activeRecord = record
            return
        else
            SetVehicleEngineTorqueMultiplier(vehicle, 1.0)
        end

        resetActiveState()
    end
end

function TwoStep.OnDriverLeftVehicle()
    resetActiveState()
    twostepState.runtimeVehicle = 0
    twostepState.runtimePlate = ""
    twostepState.runtimeRecord = nil
end

function TwoStep.ApplyPersistedStateToVehicle(vehicle, plate, recordData)
    local cleanPlate = normalizePlate(plate)
    if cleanPlate == "" then
        cleanPlate = getVehiclePlate(vehicle)
    end

    if cleanPlate == "" then return end

    setRecordByPlate(cleanPlate, recordData)

    local rec = twostepState.recordsByPlate[cleanPlate]
    if rec and rec.installed then
        VehicleEffects.SyncRuntimeForCurrentVehicle()
    end
end

-- ── Net Events & Resource Lifecycle ─────────────────

RegisterNetEvent("sky_mechanicjob:twostep:burst", function(netId, payload)
    if type(payload) == "table" and payload.source == GetPlayerServerId(PlayerId()) then
        return
    end

    local vehicle = NetToVeh(netId)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local record = (type(payload) == "table" and payload.record) or nil
    local intensity = (type(payload) == "table" and payload.intensity) or 1.0

    playTwostepBurst(vehicle, record, intensity)
end)

AddEventHandler("onResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    TwoStep.OnDriverLeftVehicle()
end)
