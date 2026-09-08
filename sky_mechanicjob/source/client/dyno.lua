if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/dyno.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/dyno.lua
--  Deobfuscated & Cleaned
-- =====================================================

local DynoState = { running = false }
local wheelRotationSupported = nil

-- ── Helpers ──────────────────────────────────────────

local function normalizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

local function clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

-- ── Power Health Factor ──────────────────────────────

local function computePowerHealthFactor(vehicle, wearData)
    local iceComponents = {
        { key = "spark_plugs",        weight = 0.24 },
        { key = "engine_oil",         weight = 0.22 },
        { key = "coolant",            weight = 0.18 },
        { key = "air_filter",         weight = 0.14 },
        { key = "transmission_fluid", weight = 0.12 },
        { key = "clutch",             weight = 0.10 }
    }

    local evComponents = {
        { key = "traction_battery", weight = 0.62 },
        { key = "inverter",         weight = 0.38 }
    }

    local components = IsMechanicElectricVehicle(vehicle) and evComponents or iceComponents

    local totalWeighted = 0.0
    local totalWeight = 0.0

    for _, comp in ipairs(components) do
        local level = clamp(tonumber((wearData or {})[comp.key]) or 100.0, 0.0, 100.0)
        totalWeighted = totalWeighted + (level / 100.0) * comp.weight
        totalWeight = totalWeight + comp.weight
    end

    if totalWeight <= 0.0 then return 1.0 end
    return clamp(totalWeighted / totalWeight, 0.35, 1.0)
end

-- ── Dyno Curve Generation ────────────────────────────

local function generateDynoCurves(vehicle, healthFactor)
    local driveForce = clamp(GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce"), 0.10, 2.5)
    local maxFlatVel = clamp(GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel"), 20.0, 150.0)
    local mass = clamp(GetVehicleHandlingFloat(vehicle, "CHandlingData", "fMass"), 800.0, 4000.0)

    local engineMod = GetVehicleMod(vehicle, 11) + 1
    local turboOn = IsToggleModOn(vehicle, 18)
    local turboMult = turboOn and 1.25 or 1.0
    local engineMult = 1.0 + (math.max(0, engineMod) * 0.08)
    local health = clamp(healthFactor, 0.40, 1.0)

    local baseHp = (driveForce * 1100.0) + (maxFlatVel * 2.2) + (mass * 0.04)
    local peakHP = math.floor(baseHp * engineMult * turboMult * health + 0.5)
    peakHP = clamp(peakHP, 120, 1500)

    local peakTQ = math.floor(peakHP * 1.35 * (turboOn and 1.15 or 1.0) + 0.5)
    peakTQ = clamp(peakTQ, 150, 1800)

    local rpmMin = 1200.0
    local rpmMax = 7800.0
    local steps = 72

    local hpCurve = {}
    local tqCurve = {}

    for i = 0, steps do
        local t = i / steps
        local rpm = rpmMin + (rpmMax - rpmMin) * t

        local tqFactor
        if rpm < 2800.0 then
            local p = (rpm - rpmMin) / (2800.0 - rpmMin)
            tqFactor = 0.55 + 0.45 * math.sin(p * math.pi * 0.5)
        elseif rpm <= 5500.0 then
            tqFactor = 0.96 + 0.04 * math.sin(((rpm - 2800.0) / 2700.0) * math.pi)
        else
            local p = (rpm - 5500.0) / (rpmMax - 5500.0)
            tqFactor = 1.0 - (0.35 * (p ^ 1.4))
        end

        local tq = math.floor(peakTQ * tqFactor * health + 0.5)
        local hp = math.floor(((tq * 0.73756) * rpm) / 5252.0 + 0.5)
        if hp > peakHP then hp = peakHP end

        hpCurve[#hpCurve + 1] = { x = math.floor(rpm + 0.5), y = math.max(0, hp) }
        tqCurve[#tqCurve + 1] = { x = math.floor(rpm + 0.5), y = math.max(0, tq) }
    end

    return {
        horsepower = hpCurve,
        torque = tqCurve,
        peakHorsepower = peakHP,
        peakTorque = peakTQ
    }
end

-- ── RPM Sweep Animation ─────────────────────────────

local function runDynoSweep(vehicle, animMs)
    local function tryRequestControl(veh, timeoutMs)
        if requestVehicleControl then
            return requestVehicleControl(veh, timeoutMs or 1200)
        end

        local deadline = GetGameTimer() + (timeoutMs or 1200)
        if NetworkHasControlOfEntity(veh) then return true end

        while GetGameTimer() < deadline do
            NetworkRequestControlOfEntity(veh)
            if NetworkHasControlOfEntity(veh) then return true end
            Wait(0)
        end
        return NetworkHasControlOfEntity(veh)
    end

    local function getDrivenWheels()
        local driveBias = clamp(GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront"), 0.0, 1.0)
        local numWheels = math.max(0, math.floor(tonumber(GetVehicleNumberOfWheels(vehicle)) or 0))
        local wheels = {}

        if numWheels <= 0 then return wheels end

        for i = 0, numWheels - 1 do
            if driveBias <= 0.01 then
                if i >= 2 then wheels[#wheels + 1] = i end
            elseif driveBias >= 0.99 then
                if i <= 1 then wheels[#wheels + 1] = i end
            else
                wheels[#wheels + 1] = i
            end
        end

        if #wheels == 0 then
            for i = 0, numWheels - 1 do
                wheels[#wheels + 1] = i
            end
        end

        return wheels
    end

    local function setWheelSpin(speed)
        if wheelRotationSupported == false then return false end
        local wheels = getDrivenWheels()
        if #wheels <= 0 then return false end

        for _, w in ipairs(wheels) do
            local ok = pcall(SetVehicleWheelRotationSpeed, vehicle, w, speed)
            if not ok then
                if wheelRotationSupported == nil then
                    print("[sky_mechanicjob][dyno] SetVehicleWheelRotationSpeed unavailable, using forward-speed fallback")
                end
                wheelRotationSupported = false
                return false
            end
        end

        wheelRotationSupported = true
        return true
    end

    local function probeWheelSupport()
        if wheelRotationSupported ~= nil then return wheelRotationSupported end
        local numWheels = math.max(0, math.floor(tonumber(GetVehicleNumberOfWheels(vehicle)) or 0))
        if numWheels <= 0 then
            wheelRotationSupported = false
            return false
        end
        local ok = pcall(SetVehicleWheelRotationSpeed, vehicle, 0, 0.0)
        wheelRotationSupported = (ok == true)
        if not wheelRotationSupported then
            print("[sky_mechanicjob][dyno] direct wheel rotation not supported, using roller fallback")
        end
        return wheelRotationSupported
    end

    if not tryRequestControl(vehicle, 1500) then
        print("[sky_mechanicjob][dyno] vehicle control failed: unable to control entity")
        return
    end

    local engineWasOff = false
    if not GetIsVehicleEngineRunning(vehicle) then
        SetVehicleEngineOn(vehicle, true, true, false)
        engineWasOff = true
    end

    local savedRpm = GetVehicleCurrentRpm(vehicle)
    local driver = GetPedInVehicleSeat(vehicle, -1)
    local myPed = PlayerPedId()
    local canControlRpm = (driver == 0 or driver == myPed)
    local canControlVehicle = canControlRpm
    local useDirectWheelSpin = canControlVehicle and probeWheelSupport()

    print(string.format("[sky_mechanicjob][dyno] spin_mode=%s driver=%s canControl=%s",
        useDirectWheelSpin and "direct_native" or "fallback",
        tostring(driver),
        tostring(canControlVehicle)))

    local savedCoords = GetEntityCoords(vehicle)
    local savedHeading = GetEntityHeading(vehicle)
    local savedRotation = GetEntityRotation(vehicle, 2)
    local savedGravity = true

    if canControlVehicle then
        SetVehicleOnGroundProperly(vehicle)
        SetEntityHasGravity(vehicle, false)
        SetVehicleGravity(vehicle, false)
        SetVehicleHandbrake(vehicle, useDirectWheelSpin)
    end

    local sweepDuration = clamp(math.floor(tonumber(animMs) or 5200), 2000, 15000)
    local startTime = GetGameTimer()

    while true do
        local elapsed = GetGameTimer() - startTime
        if elapsed > sweepDuration then break end
        if not DoesEntityExist(vehicle) then break end

        local progress = clamp(elapsed / math.max(1, sweepDuration), 0.0, 1.0)

        if canControlRpm then
            SetVehicleCurrentRpm(vehicle, 0.22 + 0.72 * progress)
        end

        if canControlVehicle then
            local currentRpm = clamp(GetVehicleCurrentRpm(vehicle), 0.0, 1.2)
            local wheelSpeed = -44.1 * currentRpm
            local usedDirect = false

            if useDirectWheelSpin then
                usedDirect = setWheelSpin(wheelSpeed)
            end

            if not usedDirect then
                SetVehicleHandbrake(vehicle, false)
                SetVehicleForwardSpeed(vehicle, 8.0 + progress * 22.0)
                if elapsed % 60 < 16 then
                    SetEntityCoordsNoOffset(vehicle, savedCoords.x, savedCoords.y, savedCoords.z, false, false, false)
                    SetEntityHeading(vehicle, savedHeading)
                    SetEntityRotation(vehicle, savedRotation.x, savedRotation.y, savedRotation.z, 2, true)
                end
            else
                SetVehicleHandbrake(vehicle, true)
                SetEntityRotation(vehicle, savedRotation.x, savedRotation.y, savedRotation.z, 2, true)
            end
        end

        Wait(0)
    end

    if canControlRpm then
        SetVehicleCurrentRpm(vehicle, savedRpm)
    end

    if canControlVehicle then
        if useDirectWheelSpin then setWheelSpin(0.0) end
        SetVehicleHandbrake(vehicle, false)
        SetVehicleForwardSpeed(vehicle, 0.0)
        SetEntityCoordsNoOffset(vehicle, savedCoords.x, savedCoords.y, savedCoords.z, false, false, false)
        SetEntityHeading(vehicle, savedHeading)
        SetEntityRotation(vehicle, savedRotation.x, savedRotation.y, savedRotation.z, 2, true)
        SetEntityHasGravity(vehicle, savedGravity)
        SetVehicleGravity(vehicle, savedGravity)
        SetVehicleOnGroundProperly(vehicle)
    end

    if engineWasOff and driver == 0 then
        SetVehicleEngineOn(vehicle, false, true, true)
    end
end

-- ── NUI Callback ─────────────────────────────────────

RegisterNUICallback("dyno:run", function(data, cb)
    if DynoState.running then
        cb({ success = false, error = "busy" })
        return
    end

    local netId = math.floor(tonumber(OrderTabletState and OrderTabletState.connectedVehicleNetId) or 0)
    if netId <= 0 then
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh == 0 or not DoesEntityExist(veh) then
            local pCoords = GetEntityCoords(ped)
            veh = GetClosestVehicle(pCoords.x, pCoords.y, pCoords.z, 10.0, 0, 71)
        end
        if veh ~= 0 and DoesEntityExist(veh) then
            netId = NetworkGetNetworkIdFromEntity(veh)
            if OrderTabletState then OrderTabletState.connectedVehicleNetId = netId end
        end
    end

    if netId <= 0 then
        cb({ success = false, error = "no_vehicle" })
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        if OrderTabletState then OrderTabletState.connectedVehicleNetId = 0 end
        cb({ success = false, error = "no_vehicle" })
        return
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    local vehCoords = GetEntityCoords(vehicle)
    if #(pedCoords - vehCoords) > 25.0 then
        cb({ success = false, error = "vehicle_too_far" })
        return
    end

    local animMs = clamp(math.floor(tonumber((data or {}).animationMs) or 5200), 2000, 15000)

    DynoState.running = true

    local ok, result = xpcall(function()
        local plate = normalizePlate(GetVehicleNumberPlateText(vehicle))
        local serverData = Sky.Cb.Trigger("sky_mechanicjob:wear:get", { plate = plate }) or {}
        local wearData = (type(serverData) == "table" and type(serverData.wear) == "table") and serverData.wear or {}
        local healthFactor = computePowerHealthFactor(vehicle, wearData)
        local curves = generateDynoCurves(vehicle, healthFactor)

        local modelName = string.upper(GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))))
        if modelName == "NULL" or modelName == "" then
            modelName = string.upper(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
        end

        return {
            success = true,
            data = {
                plate = plate,
                model = modelName,
                peakHorsepower = curves.peakHorsepower,
                peakTorque = curves.peakTorque,
                powerHealthPercent = math.floor(healthFactor * 100.0 + 0.5),
                animationMs = animMs,
                curves = {
                    horsepower = curves.horsepower,
                    torque = curves.torque
                }
            }
        }
    end, function(err)
        print(string.format("[sky_mechanicjob][dyno] test failed: %s", tostring(err)))
        return { success = false, error = "run_failed" }
    end)

    if not (ok and result and result.success == true) then
        DynoState.running = false
        cb({ success = false, error = "run_failed" })
        return
    end

    CreateThread(function()
        xpcall(function()
            runDynoSweep(vehicle, animMs)
        end, function(err)
            print(string.format("[sky_mechanicjob][dyno] sweep failed: %s", tostring(err)))
        end)
        DynoState.running = false
    end)

    cb(result)
end)
