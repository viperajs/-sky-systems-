if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/antilag.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/antilag.lua
--  Deobfuscated & Cleaned
-- =====================================================

AntiLag = AntiLag or {}

local antilagState = {
    recordsByPlate = {},
    activeVehicle = 0,
    activePlate = "",
    active = false,
    activeEffectAt = 0,
    runtimeVehicle = 0,
    runtimePlate = "",
    runtimeRecord = nil
}

local DEFAULT_CONFIG = {
    enabled = true,
    defaultEnabled = false,
    activationRpm = 0.7,
    minGear = 2,
    burstIntervalMinMs = 25,
    burstIntervalMaxMs = 200,
    flameDurationMs = 90,
    flameScaleMin = 0.45,
    flameScaleMax = 1.25,
    defaultFlameScaleLevel = 10,
    defaultVolumeLevel = 5,
    turboPressureSpikeEnabled = false,
    turboPressureSpike = 25.0
}

local config = {}

local function loadConfig()
    local cfg = Config and Config.AntiLag
    if type(cfg) ~= "table" then cfg = {} end

    local toggleCfg = Config and Config.ToggleFeatures
    config.enabled = (toggleCfg and toggleCfg.antiLag) ~= false

    config.defaultEnabled = (cfg.defaultEnabled ~= nil) and (cfg.defaultEnabled == true) or DEFAULT_CONFIG.defaultEnabled
    config.activationRpm = tonumber(cfg.activationRpm) or DEFAULT_CONFIG.activationRpm
    config.minGear = math.max(1, math.floor(tonumber(cfg.minGear) or DEFAULT_CONFIG.minGear))
    config.burstIntervalMinMs = math.max(1, math.floor(tonumber(cfg.burstIntervalMinMs) or DEFAULT_CONFIG.burstIntervalMinMs))

    local burstMax = math.floor(tonumber(cfg.burstIntervalMaxMs) or DEFAULT_CONFIG.burstIntervalMaxMs)
    config.burstIntervalMaxMs = math.max(config.burstIntervalMinMs, burstMax)

    config.flameDurationMs = math.max(1, math.floor(tonumber(cfg.flameDurationMs) or DEFAULT_CONFIG.flameDurationMs))
    config.flameScaleMin = math.max(0.01, tonumber(cfg.flameScaleMin) or DEFAULT_CONFIG.flameScaleMin)

    local flameMax = tonumber(cfg.flameScaleMax) or DEFAULT_CONFIG.flameScaleMax
    config.flameScaleMax = math.max(config.flameScaleMin, flameMax)

    local scaleLevel = math.floor(tonumber(cfg.defaultFlameScaleLevel) or DEFAULT_CONFIG.defaultFlameScaleLevel)
    config.defaultFlameScaleLevel = math.max(1, math.min(10, scaleLevel))

    local volLevel = math.floor(tonumber(cfg.defaultVolumeLevel) or DEFAULT_CONFIG.defaultVolumeLevel)
    config.defaultVolumeLevel = math.max(0, math.min(10, volLevel))

    config.turboPressureSpikeEnabled = (cfg.turboPressureSpikeEnabled == true)
    config.turboPressureSpike = tonumber(cfg.turboPressureSpike) or DEFAULT_CONFIG.turboPressureSpike
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

local function getDefaultFlameScaleLevel()
    return config.defaultFlameScaleLevel
end

local function isDefaultEnabled()
    return config.defaultEnabled == true
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

    local flameLevel = math.max(1, math.min(10, math.floor(tonumber(rec.flameScaleLevel) or getDefaultFlameScaleLevel())))
    local volLevel = math.max(0, math.min(10, math.floor(tonumber(rec.volumeLevel) or getDefaultVolumeLevel())))

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
        antilagState.recordsByPlate[cleanPlate] = nil
        if antilagState.runtimePlate == cleanPlate then
            antilagState.runtimeRecord = nil
        end
        return nil
    end

    antilagState.recordsByPlate[cleanPlate] = cleanRecord
    if antilagState.runtimePlate == cleanPlate then
        antilagState.runtimeRecord = cleanRecord
    end
    return cleanRecord
end

local function getRecordByPlate(plate)
    return antilagState.recordsByPlate[normalizePlate(plate)]
end

local function resolveVehicleRecord(vehicle)
    if vehicle == antilagState.runtimeVehicle and antilagState.runtimeRecord ~= nil then
        return antilagState.runtimePlate, antilagState.runtimeRecord
    end

    local plate = getVehiclePlate(vehicle)
    local rec = (plate ~= "") and antilagState.recordsByPlate[plate] or nil

    antilagState.runtimeVehicle = vehicle
    antilagState.runtimePlate = plate
    antilagState.runtimeRecord = rec

    return plate, rec
end

local function calculateFlameScale(record)
    local minScale = config.flameScaleMin
    local maxScale = config.flameScaleMax
    local level = math.max(1, math.min(10, math.floor(tonumber(record and record.flameScaleLevel) or getDefaultFlameScaleLevel())))

    local pct = (level - 1) / 9.0
    return minScale + (maxScale - minScale) * pct
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
        source = "antilag",
        scale = finalScale,
        durationMs = config.flameDurationMs
    })
end

local function playAntilagBurst(vehicle, record, intensity)
    if not triggerBackfireEffect(vehicle, record, intensity) then
        return false
    end

    if config.turboPressureSpikeEnabled then
        if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
            SetVehicleTurboPressure(vehicle, config.turboPressureSpike)
        end
    end

    local volLevel = math.max(0, math.min(10, math.floor(tonumber(record and record.volumeLevel) or getDefaultVolumeLevel())))
    if volLevel <= 0 then
        return true
    end

    local coords = GetEntityCoords(vehicle)
    AddExplosion(coords.x, coords.y, coords.z, 61, 0.0, true, true, 0.0, true)
    return true
end

-- ── Active State ─────────────────────────────────────

local function resetActiveState()
    antilagState.active = false
    antilagState.activeVehicle = 0
    antilagState.activePlate = ""
    antilagState.activeEffectAt = 0
end

local function shouldTriggerAntilag(vehicle, record, state)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    if type(record) ~= "table" or not record.installed or record.enabled == false then return false end
    if GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then return false end

    if not state.engineRunning then return false end
    if state.rpm <= config.activationRpm then return false end
    if state.gear < config.minGear then return false end

    return not (state.throttlePressed or state.brakePressed)
end

-- ── Tuning UI Integration ────────────────────────────

function AntiLag.AddOptions(vehicle, addOptionCb)
    if type(addOptionCb) ~= "function" or not config.enabled then return end

    local record = getRecordByPlate(getVehiclePlate(vehicle))
    local isInstalled = type(record) == "table"

    addOptionCb(
        "performance",
        "antilag_enabled",
        getNuiLocale("option.label.antilag_enabled", "Anti-Lag"),
        isInstalled,
        "rear"
    )
end

function AntiLag.ApplyOption(vehicle, option, rawValue)
    if vehicle == 0 or not DoesEntityExist(vehicle) or type(option) ~= "table" then
        return false
    end

    if option.id ~= "antilag_enabled" then return false end

    local valNum = math.floor(tonumber(rawValue) or 0)
    valNum = math.max(option.min or 0, math.min(option.max or 1, valNum))

    local plate = getVehiclePlate(vehicle)
    if plate == "" then
        print("[sky_mechanicjob][antilag] apply failed: vehicle plate missing")
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
            print(string.format("[sky_mechanicjob][antilag] apply failed: unable to create record for plate %s", tostring(plate)))
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

function AntiLag.GetPersistedState(vehicle)
    return sanitizeRecord(getRecordByPlate(getVehiclePlate(vehicle)))
end

function AntiLag.IsInstalledForVehicle(vehicle)
    local plate, record = resolveVehicleRecord(vehicle)
    return type(record) == "table", plate, record
end

function AntiLag.GetSuggestedWaitMs(vehicle, state, record)
    if not record then
        record = select(2, resolveVehicleRecord(vehicle))
    end

    if type(record) ~= "table" or not record.installed or record.enabled == false then
        return 250
    end

    if not state.engineRunning then return 500 end
    if state.gear < config.minGear then return 250 end
    if state.rpm < math.max(0.1, config.activationRpm - 0.12) then return 150 end

    if state.throttlePressed or state.brakePressed then return 75 end
    return 50
end

function AntiLag.TickVehicle(vehicle, now, state, plate, record)
    if not record then
        plate, record = resolveVehicleRecord(vehicle)
    end

    if not record or not record.installed then
        if antilagState.activeVehicle ~= 0 then
            resetActiveState()
        end
        return
    end

    antilagState.activeVehicle = vehicle
    antilagState.activePlate = plate

    if shouldTriggerAntilag(vehicle, record, state) then
        if not antilagState.active then
            antilagState.active = true
            antilagState.activeEffectAt = 0
        end

        if now >= antilagState.activeEffectAt then
            local intensity = math.max(0.35, math.min(1.0, state.rpm))

            TriggerServerEvent("sky_mechanicjob:antilag:syncBurst", VehToNet(vehicle), {
                intensity = intensity,
                record = {
                    volumeLevel = math.max(0, math.min(10, math.floor(tonumber(record.volumeLevel) or getDefaultVolumeLevel()))),
                    flameScaleLevel = math.max(1, math.min(10, math.floor(tonumber(record.flameScaleLevel) or getDefaultFlameScaleLevel())))
                }
            })

            antilagState.activeEffectAt = now + getRandomBurstInterval()
        end
    else
        if antilagState.active then
            resetActiveState()
        end
    end
end

function AntiLag.OnDriverLeftVehicle()
    resetActiveState()
    antilagState.runtimeVehicle = 0
    antilagState.runtimePlate = ""
    antilagState.runtimeRecord = nil
end

function AntiLag.ApplyPersistedStateToVehicle(vehicle, plate, recordData)
    local cleanPlate = normalizePlate(plate)
    if cleanPlate == "" then
        cleanPlate = getVehiclePlate(vehicle)
    end

    if cleanPlate == "" then return end

    setRecordByPlate(cleanPlate, recordData)

    local rec = antilagState.recordsByPlate[cleanPlate]
    if rec and rec.installed then
        VehicleEffects.SyncRuntimeForCurrentVehicle()
    end
end

-- ── Net Events & Resource Lifecycle ─────────────────

RegisterNetEvent("sky_mechanicjob:antilag:burst", function(netId, payload)
    local vehicle = NetToVeh(netId)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local record = (type(payload) == "table" and payload.record) or nil
    local intensity = (type(payload) == "table" and payload.intensity) or 1.0

    playAntilagBurst(vehicle, record, intensity)
end)

AddEventHandler("onResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    AntiLag.OnDriverLeftVehicle()
end)
