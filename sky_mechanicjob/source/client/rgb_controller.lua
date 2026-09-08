if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/rgb_controller.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/rgb_controller.lua
--  Deobfuscated & Cleaned
-- =====================================================

RgbController = RgbController or {}

RgbController.NEON_EFFECT_MODES = {
    off = 0,
    rainbow = 1,
    flash = 2,
    pulse = 3
}

RgbController.XENON_EFFECT_MODES = {
    off = 0,
    rainbow = 1,
    flash = 2,
    pulse = 3
}

local neonState = {
    vehicleNetId = 0,
    mode = RgbController.NEON_EFFECT_MODES.off,
    speed = 5,
    hue = 0.0,
    pulsePhase = 0.0,
    flashOn = true,
    flashAccumulator = 0.0,
    lastTickAt = 0,
    lastAppliedR = -1,
    lastAppliedG = -1,
    lastAppliedB = -1,
    enabledCached = false,
    enabledCachedAt = 0,
    baseColor = { r = 255, g = 255, b = 255 }
}

local xenonState = {
    vehicleNetId = 0,
    mode = RgbController.XENON_EFFECT_MODES.off,
    speed = 5,
    hue = 0.0,
    pulsePhase = 0.0,
    flashOn = true,
    flashAccumulator = 0.0,
    lastTickAt = 0,
    lastAppliedR = -1,
    lastAppliedG = -1,
    lastAppliedB = -1,
    enabledCached = false,
    enabledCachedAt = 0,
    customModeApplied = false,
    baseColor = { r = 244, g = 247, b = 255 }
}

local DEFAULT_IDLE_WAIT_MS = 250
local FAST_TICK_WAIT_MS = 50
local CACHE_TTL_MS = 1000
local COLOR_CHANGE_THRESHOLD = 2

-- ── Helpers ──────────────────────────────────────────

local function clampByte(val)
    return math.floor(math.max(0, math.min(255, tonumber(val) or 0)))
end

local function sanitizeColor(colorData)
    if type(colorData) ~= "table" then return nil end
    return {
        r = clampByte(colorData.r),
        g = clampByte(colorData.g),
        b = clampByte(colorData.b)
    }
end

-- ── Color Capture ────────────────────────────────────

function RgbController.CaptureVehicleNeonColor(vehicle)
    local r, g, b = GetVehicleNeonLightsColour(vehicle)
    return {
        r = clampByte(r),
        g = clampByte(g),
        b = clampByte(b)
    }
end

function RgbController.CaptureVehicleXenonColor(vehicle)
    local colorIndex = math.floor(tonumber(GetVehicleXenonLightsColor(vehicle)) or -1)
    local _ok, r, g, b = GetVehicleXenonLightsCustomColor(vehicle)

    if colorIndex == 255 then
        return {
            r = clampByte(r),
            g = clampByte(g),
            b = clampByte(b)
        }
    end

    for _, preset in ipairs(XENON_COLOR_PRESETS or {}) do
        if math.floor(tonumber(preset.index) or 0) == colorIndex then
            if type(preset.rgb) == "table" then
                return {
                    r = clampByte(preset.rgb[1]),
                    g = clampByte(preset.rgb[2]),
                    b = clampByte(preset.rgb[3])
                }
            end
        end
    end

    return { r = 244, g = 247, b = 255 }
end

-- ── Animation State Reset ───────────────────────────

function RgbController.ResetNeonAnimationState()
    neonState.hue = 0.0
    neonState.pulsePhase = 0.0
    neonState.flashOn = true
    neonState.flashAccumulator = 0.0
    neonState.lastTickAt = GetGameTimer()
    neonState.lastAppliedR = -1
    neonState.lastAppliedG = -1
    neonState.lastAppliedB = -1
    neonState.enabledCachedAt = 0
end

function RgbController.ResetXenonAnimationState()
    xenonState.hue = 0.0
    xenonState.pulsePhase = 0.0
    xenonState.flashOn = true
    xenonState.flashAccumulator = 0.0
    xenonState.lastTickAt = GetGameTimer()
    xenonState.lastAppliedR = -1
    xenonState.lastAppliedG = -1
    xenonState.lastAppliedB = -1
    xenonState.enabledCachedAt = 0
    xenonState.customModeApplied = false
end

-- ── Vehicle Binding ──────────────────────────────────

function RgbController.BindNeonEffectVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId <= 0 then return end

    if neonState.vehicleNetId ~= netId then
        neonState.vehicleNetId = netId
        neonState.mode = RgbController.NEON_EFFECT_MODES.off
        neonState.speed = 5
        neonState.baseColor = RgbController.CaptureVehicleNeonColor(vehicle)
        RgbController.ResetNeonAnimationState()
    end

    TuningState.rgbNeonEffectVehicleNetId = neonState.vehicleNetId
    TuningState.rgbNeonEffectMode = neonState.mode
    TuningState.rgbNeonEffectSpeed = neonState.speed
end

function RgbController.BindXenonEffectVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId <= 0 then return end

    if xenonState.vehicleNetId ~= netId then
        xenonState.vehicleNetId = netId
        xenonState.mode = RgbController.XENON_EFFECT_MODES.off
        xenonState.speed = 5
        xenonState.baseColor = RgbController.CaptureVehicleXenonColor(vehicle)
        RgbController.ResetXenonAnimationState()
    end

    TuningState.rgbXenonEffectVehicleNetId = xenonState.vehicleNetId
    TuningState.rgbXenonEffectMode = xenonState.mode
    TuningState.rgbXenonEffectSpeed = xenonState.speed
end

-- ── Base Color & Mode Mutators ───────────────────────

function RgbController.SetNeonBaseColor(color)
    local sanitized = sanitizeColor(color)
    if not sanitized then return end
    neonState.baseColor = sanitized
end

function RgbController.SetXenonBaseColor(color)
    local sanitized = sanitizeColor(color)
    if not sanitized then return end
    xenonState.baseColor = sanitized
end

function RgbController.SetNeonLastAppliedColor(r, g, b)
    neonState.lastAppliedR = clampByte(r)
    neonState.lastAppliedG = clampByte(g)
    neonState.lastAppliedB = clampByte(b)
end

function RgbController.SetXenonLastAppliedColor(r, g, b)
    xenonState.lastAppliedR = clampByte(r)
    xenonState.lastAppliedG = clampByte(g)
    xenonState.lastAppliedB = clampByte(b)
end

function RgbController.SetNeonMode(vehicle, mode)
    RgbController.BindNeonEffectVehicle(vehicle)
    local m = math.floor(tonumber(mode) or RgbController.NEON_EFFECT_MODES.off)
    neonState.mode = m

    RgbController.ResetNeonAnimationState()
    TuningState.rgbNeonEffectMode = m

    if m == RgbController.NEON_EFFECT_MODES.off then
        SetVehicleNeonLightsColour(vehicle, neonState.baseColor.r, neonState.baseColor.g, neonState.baseColor.b)
        RgbController.SetNeonLastAppliedColor(neonState.baseColor.r, neonState.baseColor.g, neonState.baseColor.b)
    end

    VehicleEffects.SyncRuntimeForCurrentVehicle()
end

function RgbController.SetXenonMode(vehicle, mode)
    RgbController.BindXenonEffectVehicle(vehicle)
    local m = math.floor(tonumber(mode) or RgbController.XENON_EFFECT_MODES.off)
    xenonState.mode = m

    RgbController.ResetXenonAnimationState()
    TuningState.rgbXenonEffectMode = m

    if m == RgbController.XENON_EFFECT_MODES.off then
        xenonState.customModeApplied = false
    end

    VehicleEffects.SyncRuntimeForCurrentVehicle()
end

function RgbController.SetNeonSpeed(vehicle, speed)
    RgbController.BindNeonEffectVehicle(vehicle)
    local spd = math.max(1, math.min(10, math.floor(tonumber(speed) or 5)))
    neonState.speed = spd
    TuningState.rgbNeonEffectSpeed = spd
end

function RgbController.SetXenonSpeed(vehicle, speed)
    RgbController.BindXenonEffectVehicle(vehicle)
    local spd = math.max(1, math.min(10, math.floor(tonumber(speed) or 5)))
    xenonState.speed = spd
    TuningState.rgbXenonEffectSpeed = spd
end

function RgbController.StopEffectsForVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId <= 0 then return end

    if netId == neonState.vehicleNetId then
        neonState.mode = RgbController.NEON_EFFECT_MODES.off
        RgbController.ResetNeonAnimationState()
        TuningState.rgbNeonEffectMode = RgbController.NEON_EFFECT_MODES.off
    end

    if netId == xenonState.vehicleNetId then
        xenonState.mode = RgbController.XENON_EFFECT_MODES.off
        RgbController.ResetXenonAnimationState()
        TuningState.rgbXenonEffectMode = RgbController.XENON_EFFECT_MODES.off
    end

    VehicleEffects.SyncRuntimeForCurrentVehicle()
end

-- ── State Query Methods ──────────────────────────────

function RgbController.GetVehicleEffectState(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        return nil, nil
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId <= 0 then return nil, nil end

    local neonData = nil
    if neonState.vehicleNetId == netId then
        local directions = {}
        for idx = 0, 3 do
            directions[idx + 1] = IsVehicleNeonLightEnabled(vehicle, idx)
        end

        neonData = {
            mode = neonState.mode,
            speed = neonState.speed,
            baseColor = { r = neonState.baseColor.r, g = neonState.baseColor.g, b = neonState.baseColor.b },
            enabledDirections = directions
        }
    end

    local xenonData = nil
    if xenonState.vehicleNetId == netId then
        xenonData = {
            mode = xenonState.mode,
            speed = xenonState.speed,
            baseColor = { r = xenonState.baseColor.r, g = xenonState.baseColor.g, b = xenonState.baseColor.b }
        }
    end

    return neonData, xenonData
end

function RgbController.HasInstalledEffectsForVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId <= 0 then return false end

    local hasNeon = neonState.mode ~= RgbController.NEON_EFFECT_MODES.off
    local hasXenon = xenonState.mode ~= RgbController.XENON_EFFECT_MODES.off

    return hasNeon or hasXenon
end

-- ── Color Math Helpers ───────────────────────────────

local function isNeonLightEnabledOnVehicle(vehicle)
    return IsVehicleNeonLightEnabled(vehicle, 0)
        or IsVehicleNeonLightEnabled(vehicle, 1)
        or IsVehicleNeonLightEnabled(vehicle, 2)
        or IsVehicleNeonLightEnabled(vehicle, 3)
end

local function isXenonLightEnabledOnVehicle(vehicle)
    return IsToggleModOn(vehicle, 22)
end

local function isNeonEnabledCached(vehicle, now, forceRefresh)
    if not forceRefresh and (now - neonState.enabledCachedAt < CACHE_TTL_MS) then
        return neonState.enabledCached
    end

    neonState.enabledCached = isNeonLightEnabledOnVehicle(vehicle)
    neonState.enabledCachedAt = now
    return neonState.enabledCached
end

local function isXenonEnabledCached(vehicle, now, forceRefresh)
    if not forceRefresh and (now - xenonState.enabledCachedAt < CACHE_TTL_MS) then
        return xenonState.enabledCached
    end

    xenonState.enabledCached = isXenonLightEnabledOnVehicle(vehicle)
    xenonState.enabledCachedAt = now
    return xenonState.enabledCached
end

local function isColorSignificantlyDifferent(r1, g1, b1, r2, g2, b2)
    if r2 < 0 or g2 < 0 or b2 < 0 then return true end
    return math.abs(r1 - r2) >= COLOR_CHANGE_THRESHOLD
end

local function hslToRgb(hue)
    local h = (tonumber(hue) or 0.0) % 360.0
    local c = 1.0
    local x = c * (1.0 - math.abs((h / 60.0) % 2.0 - 1.0))

    local r, g, b = 0.0, 0.0, 0.0
    if h < 60.0 then
        r, g, b = c, x, 0.0
    elseif h < 120.0 then
        r, g, b = x, c, 0.0
    elseif h < 180.0 then
        r, g, b = 0.0, c, x
    elseif h < 240.0 then
        r, g, b = 0.0, x, c
    elseif h < 300.0 then
        r, g, b = x, 0.0, c
    else
        r, g, b = c, 0.0, x
    end

    return math.floor(r * 255.0 + 0.5), math.floor(g * 255.0 + 0.5), math.floor(b * 255.0 + 0.5)
end

-- ── Animation Tick Logic ─────────────────────────────

local function tickNeonAnimation(vehicle, now)
    if neonState.mode == RgbController.NEON_EFFECT_MODES.off or neonState.vehicleNetId <= 0 then
        return DEFAULT_IDLE_WAIT_MS
    end

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return DEFAULT_IDLE_WAIT_MS
    end

    if NetworkGetNetworkIdFromEntity(vehicle) ~= neonState.vehicleNetId then
        return DEFAULT_IDLE_WAIT_MS
    end

    if not isNeonEnabledCached(vehicle, now, false) then
        return DEFAULT_IDLE_WAIT_MS
    end

    if neonState.lastTickAt <= 0 then
        neonState.lastTickAt = now
    end

    local dt = math.max(0.0, math.min(200.0, now - neonState.lastTickAt))
    neonState.lastTickAt = now

    local speedLevel = math.max(1, math.min(10, math.floor(tonumber(neonState.speed) or 5)))
    local r, g, b = neonState.baseColor.r, neonState.baseColor.g, neonState.baseColor.b

    if neonState.mode == RgbController.NEON_EFFECT_MODES.rainbow then
        neonState.hue = (neonState.hue + dt * 0.03 * speedLevel) % 360.0
        r, g, b = hslToRgb(neonState.hue)
    elseif neonState.mode == RgbController.NEON_EFFECT_MODES.flash then
        local interval = 920.0 - speedLevel * 72.0
        neonState.flashAccumulator = neonState.flashAccumulator + dt

        while neonState.flashAccumulator >= interval do
            neonState.flashAccumulator = neonState.flashAccumulator - interval
            neonState.flashOn = not neonState.flashOn
        end

        if not neonState.flashOn then
            r, g, b = 0, 0, 0
        end
    elseif neonState.mode == RgbController.NEON_EFFECT_MODES.pulse then
        neonState.pulsePhase = neonState.pulsePhase + dt * 0.0036 * speedLevel
        local factor = 0.18 + 0.82 * ((math.sin(neonState.pulsePhase) + 1.0) / 2.0)
        r = math.floor(neonState.baseColor.r * factor + 0.5)
        g = math.floor(neonState.baseColor.g * factor + 0.5)
        b = math.floor(neonState.baseColor.b * factor + 0.5)
    end

    if isColorSignificantlyDifferent(r, g, b, neonState.lastAppliedR, neonState.lastAppliedG, neonState.lastAppliedB) then
        SetVehicleNeonLightsColour(vehicle, r, g, b)
        neonState.lastAppliedR = r
        neonState.lastAppliedG = g
        neonState.lastAppliedB = b
    end

    if neonState.mode == RgbController.NEON_EFFECT_MODES.flash then
        local interval = 920.0 - speedLevel * 72.0
        return math.max(FAST_TICK_WAIT_MS, math.floor(interval - neonState.flashAccumulator))
    elseif neonState.mode == RgbController.NEON_EFFECT_MODES.rainbow then
        return FAST_TICK_WAIT_MS
    elseif neonState.mode == RgbController.NEON_EFFECT_MODES.pulse then
        return FAST_TICK_WAIT_MS
    end

    return DEFAULT_IDLE_WAIT_MS
end

local function tickXenonAnimation(vehicle, now)
    if xenonState.mode == RgbController.XENON_EFFECT_MODES.off or xenonState.vehicleNetId <= 0 then
        return DEFAULT_IDLE_WAIT_MS
    end

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return DEFAULT_IDLE_WAIT_MS
    end

    if NetworkGetNetworkIdFromEntity(vehicle) ~= xenonState.vehicleNetId then
        return DEFAULT_IDLE_WAIT_MS
    end

    if not isXenonEnabledCached(vehicle, now, false) then
        return DEFAULT_IDLE_WAIT_MS
    end

    if xenonState.lastTickAt <= 0 then
        xenonState.lastTickAt = now
    end

    local dt = math.max(0.0, math.min(200.0, now - xenonState.lastTickAt))
    xenonState.lastTickAt = now

    local speedLevel = math.max(1, math.min(10, math.floor(tonumber(xenonState.speed) or 5)))
    local r, g, b = xenonState.baseColor.r, xenonState.baseColor.g, xenonState.baseColor.b

    if xenonState.mode == RgbController.XENON_EFFECT_MODES.rainbow then
        xenonState.hue = (xenonState.hue + dt * 0.03 * speedLevel) % 360.0
        r, g, b = hslToRgb(xenonState.hue)
    elseif xenonState.mode == RgbController.XENON_EFFECT_MODES.flash then
        local interval = 920.0 - speedLevel * 72.0
        xenonState.flashAccumulator = xenonState.flashAccumulator + dt

        while xenonState.flashAccumulator >= interval do
            xenonState.flashAccumulator = xenonState.flashAccumulator - interval
            xenonState.flashOn = not xenonState.flashOn
        end

        if not xenonState.flashOn then
            r, g, b = 0, 0, 0
        end
    elseif xenonState.mode == RgbController.XENON_EFFECT_MODES.pulse then
        xenonState.pulsePhase = xenonState.pulsePhase + dt * 0.0036 * speedLevel
        local factor = 0.18 + 0.82 * ((math.sin(xenonState.pulsePhase) + 1.0) / 2.0)
        r = math.floor(xenonState.baseColor.r * factor + 0.5)
        g = math.floor(xenonState.baseColor.g * factor + 0.5)
        b = math.floor(xenonState.baseColor.b * factor + 0.5)
    end

    if isColorSignificantlyDifferent(r, g, b, xenonState.lastAppliedR, xenonState.lastAppliedG, xenonState.lastAppliedB) then
        if not xenonState.customModeApplied then
            SetVehicleXenonLightsColor(vehicle, 255)
            xenonState.customModeApplied = true
        end

        SetVehicleXenonLightsCustomColor(vehicle, r, g, b)
        xenonState.lastAppliedR = r
        xenonState.lastAppliedG = g
        xenonState.lastAppliedB = b
    end

    if xenonState.mode == RgbController.XENON_EFFECT_MODES.flash then
        local interval = 920.0 - speedLevel * 72.0
        return math.max(FAST_TICK_WAIT_MS, math.floor(interval - xenonState.flashAccumulator))
    elseif xenonState.mode == RgbController.XENON_EFFECT_MODES.rainbow then
        return FAST_TICK_WAIT_MS
    elseif xenonState.mode == RgbController.XENON_EFFECT_MODES.pulse then
        return FAST_TICK_WAIT_MS
    end

    return DEFAULT_IDLE_WAIT_MS
end

-- ── Main Public Tick & Lifecycle ─────────────────────

function RgbController.GetSuggestedWaitMs(vehicle, _now)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return DEFAULT_IDLE_WAIT_MS
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local hasNeon = neonState.mode ~= RgbController.NEON_EFFECT_MODES.off
    local hasXenon = xenonState.mode ~= RgbController.XENON_EFFECT_MODES.off

    if hasNeon or hasXenon then
        return FAST_TICK_WAIT_MS
    end

    return DEFAULT_IDLE_WAIT_MS
end

function RgbController.TickVehicle(vehicle, now, _state)
    local nowTime = now or GetGameTimer()

    local waitNeon = tickNeonAnimation(vehicle, nowTime)
    local waitXenon = tickXenonAnimation(vehicle, nowTime)

    return math.min(waitNeon, waitXenon)
end

function RgbController.OnDriverLeftVehicle()
    neonState.lastTickAt = 0
    xenonState.lastTickAt = 0
    neonState.enabledCachedAt = 0
    xenonState.enabledCachedAt = 0
    xenonState.customModeApplied = false
end
