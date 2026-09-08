if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/vehicle_rollover.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/vehicle_rollover.lua
--  Deobfuscated & Cleaned
-- =====================================================

local RECOVERY_DISABLED_CONTROLS = { 59, 60, 61, 62, 63, 64, 71, 72 }

local function getRecoveryConfig()
    local cfg = Config.VehicleRolloverRecovery
    if type(cfg) ~= "table" then cfg = {} end

    return {
        enabled = cfg.disableGtaRecovery ~= false,
        rollThresholdDegrees = tonumber(cfg.rollThresholdDegrees) or 65.0,
        maxSpeedKmh = tonumber(cfg.maxSpeedKmh) or 25.0,
        checkIntervalMs = math.max(50, math.floor(tonumber(cfg.checkIntervalMs) or 100))
    }
end

local function isVehicleRolledOver(vehicle, config)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return false
    end

    if IsEntityInAir(vehicle) then
        return false
    end

    local roll = math.abs(GetEntityRoll(vehicle))
    if roll < config.rollThresholdDegrees then
        return false
    end

    local speedKmh = GetEntitySpeed(vehicle) * 3.6
    return speedKmh <= config.maxSpeedKmh
end

local function disableRecoveryControls()
    for _, control in ipairs(RECOVERY_DISABLED_CONTROLS) do
        DisableControlAction(0, control, true)
        DisableControlAction(2, control, true)
    end
end

CreateThread(function()
    local isBlocking = false
    local nextCheckAt = 0

    while true do
        local waitMs = 250
        local config = getRecoveryConfig()

        if config.enabled then
            local now = GetGameTimer()

            if isBlocking then
                waitMs = 0
                disableRecoveryControls()
            elseif nextCheckAt > now then
                waitMs = math.max(0, nextCheckAt - now)
            end

            if nextCheckAt <= now then
                nextCheckAt = now + config.checkIntervalMs

                local ped = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(ped, false)
                local _driver = GetPedInVehicleSeat(vehicle, -1)
                local rolledOver = isVehicleRolledOver(vehicle, config)

                isBlocking = vehicle ~= 0 and isBlocking
                if isBlocking then
                    waitMs = 0
                    disableRecoveryControls()
                end
            end
        else
            isBlocking = false
            nextCheckAt = 0
        end

        Wait(waitMs)
    end
end)
