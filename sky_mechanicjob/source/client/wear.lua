if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/wear.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_mechanicjob · source/client/wear.lua
--  Deobfuscated by Claude
--  Original: 3057 lines → Cleaned
-- =====================================================

local HANDLING_DATA_CLASS = "CHandlingData"
local DEFAULT_VEHICLE_CDN_BASE = "https://cdn.sky-systems.net/vehicles"
local DEFAULT_PART_ITEM = "mechanic_tools"

local ICE_WEAR_PARTS = {
    "tyres", "brake_pads", "suspension", "spark_plugs",
    "engine_oil", "coolant", "brake_fluid", "transmission_fluid",
    "clutch", "air_filter", "catalytic_converter"
}

local EV_WEAR_PARTS = {
    "tyres", "brake_pads", "suspension", "brake_fluid",
    "traction_battery", "inverter"
}

local ALL_WEAR_PARTS = {
    "tyres", "brake_pads", "suspension", "spark_plugs",
    "engine_oil", "coolant", "brake_fluid", "transmission_fluid",
    "clutch", "air_filter", "traction_battery", "inverter"
}

local WEAR_HANDLING_FIELDS = {
    "fBrakeForce", "fSuspensionForce", "fSuspensionReboundDamp", "fSuspensionCompDamp"
}

local partWearPerKmMap = {}

WearState = {
    active = false,
    isFetching = false,
    vehicle = 0,
    plate = "",
    wear = {},
    mileage = 0,
    lastCoords = nil,
    mileageSinceLastSave = 0.0,
    baseHandling = {},
    appliedBands = {},
    tyresPopped = false,
    engineSmokeFx = nil,
    engineDamageActive = false,
    engineDamageElapsedMs = 0,
    transmissionLimpActive = false,
    transmissionBaseHighGear = nil,
    transmissionBaseMaxSpeed = nil,
    electricLimpActive = false,
    electricBaseHighGear = nil,
    electricBaseMaxSpeed = nil,
    isElectric = false,
    activeWearParts = ICE_WEAR_PARTS,
    hasCriticalWear = false,
    lastMileageHudSent = nil,
    lastMileageHudSyncMs = 0,
    lastVehicleExitCheckMs = 0,
    enteredAtMs = 0
}

local cachedCdnBase = nil
local cachedCdnFallback = nil

local function getNuiImageBases()
    if cachedCdnBase ~= nil and cachedCdnFallback ~= nil then
        return cachedCdnBase, cachedCdnFallback
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:getNuiImageBases") or {}
    local base = tostring(res.vehicleImageBase or DEFAULT_VEHICLE_CDN_BASE)
    if base == "" then base = DEFAULT_VEHICLE_CDN_BASE end

    base = string.gsub(base, "/+$", "")
    cachedCdnBase = base
    cachedCdnFallback = ("%s/placeholder.png"):format(base)

    return cachedCdnBase, cachedCdnFallback
end

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

local function getVehicleModelName(vehicle)
    return string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
end

local function isElectricVehicle(vehicle)
    return IsMechanicElectricVehicle(vehicle)
end

local function getActiveWearParts(vehicle)
    if isElectricVehicle(vehicle) then
        return EV_WEAR_PARTS
    end
    return ICE_WEAR_PARTS
end

local function containsPart(partName, list)
    for _, item in ipairs(list) do
        if partName == item then return true end
    end
    return false
end

local function buildWearMap(wearData, activeParts)
    local result = {}
    for _, partKey in ipairs(activeParts) do
        local val = tonumber(wearData and wearData[partKey])
        if not val then val = 100.0 end
        result[partKey] = val
    end
    return result
end

local function getBrakeBand(wearPct)
    if wearPct <= 0 then return 0 end
    return 3
end

local function getBrakePadMultiplier(band)
    local mults = { [0] = 0.2, [3] = 1.0 }
    return mults[band] or 1.0
end

local function getSuspensionBand(wearPct)
    if wearPct <= 0 then return 0
    elseif wearPct <= 30 then return 1
    elseif wearPct <= 60 then return 2
    else return 3 end
end

local function getSuspensionMultipliers(band)
    local forceMults = { [0] = 0.4, [1] = 0.65, [2] = 0.85, [3] = 1.0 }
    local dampMults  = { [0] = 0.3, [1] = 0.55, [2] = 0.8,  [3] = 1.0 }
    return forceMults[band] or 1.0, dampMults[band] or 1.0
end

local function calculatePartWearPerKm()
    local partsCfg = Config and Config.Wear and Config.Wear.parts or {}
    for _, partKey in ipairs(ALL_WEAR_PARTS) do
        local kmToZero = tonumber(partsCfg[partKey] and partsCfg[partKey].kilometersToZero) or 0
        if kmToZero > 0 then
            partWearPerKmMap[partKey] = 100.0 / kmToZero
        else
            partWearPerKmMap[partKey] = 0.0
        end
    end
end
calculatePartWearPerKm()

local function updateCriticalWearState()
    local wear = WearState.wear
    if WearState.isElectric then
        local batteryVal = wear.traction_battery or 100.0
        WearState.hasCriticalWear = (batteryVal <= 0.5)
        return
    end

    local plugsVal = wear.spark_plugs or 100.0
    WearState.hasCriticalWear = (plugsVal <= 0.5)
end

local function checkBrakeAndSuspensionBandsChanged()
    local wear = WearState.wear
    local applied = WearState.appliedBands

    local tyresVal = wear.tyres or 100.0
    if tyresVal <= 0.5 and not WearState.tyresPopped then
        return true
    end

    local brakeBand = getBrakeBand(wear.brake_pads or 100.0)
    if (wear.brake_fluid or 100.0) <= 0.5 then
        brakeBand = 0
    end

    if applied.brake_pads ~= brakeBand then
        if brakeBand == 0 or applied.brake_pads == 0 then
            return true
        end
    end

    local suspBand = getSuspensionBand(wear.suspension or 100.0)
    return applied.suspension ~= suspBand
end

local function captureBaseHandlingFloats(vehicle)
    WearState.baseHandling = {}
    for _, fieldName in ipairs(WEAR_HANDLING_FIELDS) do
        WearState.baseHandling[fieldName] = GetVehicleHandlingFloat(vehicle, HANDLING_DATA_CLASS, fieldName)
    end
end

local function applyBrakeDegradation(vehicle, band)
    local baseForce = WearState.baseHandling.fBrakeForce
    if not baseForce or baseForce <= 0 then return end

    local mult = getBrakePadMultiplier(band)
    SetVehicleHandlingFloat(vehicle, HANDLING_DATA_CLASS, "fBrakeForce", baseForce * mult)
end

local function applySuspensionDegradation(vehicle, band)
    local forceMult, dampMult = getSuspensionMultipliers(band)
    local baseForce = WearState.baseHandling.fSuspensionForce
    local baseRebound = WearState.baseHandling.fSuspensionReboundDamp
    local baseComp = WearState.baseHandling.fSuspensionCompDamp

    if baseForce and baseForce > 0 then
        SetVehicleHandlingFloat(vehicle, HANDLING_DATA_CLASS, "fSuspensionForce", baseForce * forceMult)
    end
    if baseRebound and baseRebound > 0 then
        SetVehicleHandlingFloat(vehicle, HANDLING_DATA_CLASS, "fSuspensionReboundDamp", baseRebound * dampMult)
    end
    if baseComp and baseComp > 0 then
        SetVehicleHandlingFloat(vehicle, HANDLING_DATA_CLASS, "fSuspensionCompDamp", baseComp * dampMult)
    end
end

local function popVehicleTyres(vehicle)
    for i = 0, 3 do
        SetVehicleTyreBurst(vehicle, i, true, 1000.0)
    end
    WearState.tyresPopped = true
end

local function fixVehicleTyres(vehicle)
    local wheelCount = math.max(0, math.floor(tonumber(GetVehicleNumberOfWheels(vehicle)) or 0))
    for i = 0, wheelCount - 1 do
        SetVehicleTyreFixed(vehicle, i)
    end
    WearState.tyresPopped = false
end

local function findVehicleByPlate(plate)
    if plate == "" then return 0 end

    if WearState.vehicle ~= 0 and DoesEntityExist(WearState.vehicle) then
        if sanitizePlate(GetVehicleNumberPlateText(WearState.vehicle)) == plate then
            return WearState.vehicle
        end
    end

    local tabletNetId = math.floor(tonumber(OrderTabletState and OrderTabletState.connectedVehicleNetId) or 0)
    if tabletNetId > 0 then
        local veh = NetworkGetEntityFromNetworkId(tabletNetId)
        if veh ~= 0 and DoesEntityExist(veh) then
            if sanitizePlate(GetVehicleNumberPlateText(veh)) == plate then
                return veh
            end
        end
    end

    local orderVeh = math.floor(tonumber(OrderInstallState and OrderInstallState.vehicle) or 0)
    if orderVeh ~= 0 and DoesEntityExist(orderVeh) then
        if sanitizePlate(GetVehicleNumberPlateText(orderVeh)) == plate then
            return orderVeh
        end
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    local nearbyVeh = getClosestVehicleWithPoliceFallback(pedCoords.x, pedCoords.y, pedCoords.z, 20.0, 0, 70)
    if nearbyVeh ~= 0 and DoesEntityExist(nearbyVeh) then
        if sanitizePlate(GetVehicleNumberPlateText(nearbyVeh)) == plate then
            return nearbyVeh
        end
    end

    return 0
end

local function startEngineSmokeFx(vehicle)
    if WearState.engineSmokeFx and WearState.engineSmokeFx ~= 0 then return end

    local maxWait = GetGameTimer() + 3000
    while not HasNamedPtfxAssetLoaded("core") do
        RequestNamedPtfxAsset("core")
        if GetGameTimer() > maxWait then return end
        Wait(100)
    end

    local boneIdx = GetEntityBoneIndexByName(vehicle, "engine")
    if boneIdx < 0 then boneIdx = 0 end

    UseParticleFxAssetNextCall("core")
    local fx = StartParticleFxLoopedOnEntityBone("ent_amb_steam_car_engine_02", vehicle, 0.0, 0.0, 0.2, 0.0, 0.0, 0.0, boneIdx, 1.0, false, false, false)
    WearState.engineSmokeFx = fx
end

local function stopEngineSmokeFx()
    if WearState.engineSmokeFx and WearState.engineSmokeFx ~= 0 then
        StopParticleFxLooped(WearState.engineSmokeFx, false)
        WearState.engineSmokeFx = nil
    end
end

local function resetEngineDamage()
    stopEngineSmokeFx()
    WearState.engineDamageActive = false
    WearState.engineDamageElapsedMs = 0
end

local function applyTransmissionLimp(vehicle)
    if not WearState.transmissionLimpActive then
        WearState.transmissionBaseHighGear = math.max(1, math.floor(tonumber(GetVehicleHighGear(vehicle)) or 1))
        WearState.transmissionBaseMaxSpeed = math.max(1.0, tonumber(GetVehicleEstimatedMaxSpeed(vehicle)) or 1.0)
        WearState.transmissionLimpActive = true
    end
    SetVehicleHighGear(vehicle, 1)
    SetEntityMaxSpeed(vehicle, 30.0 / 3.6)
end

local function resetTransmissionLimp(vehicle)
    if not WearState.transmissionLimpActive then return end
    if vehicle ~= 0 and DoesEntityExist(vehicle) then
        SetVehicleHighGear(vehicle, math.max(1, math.floor(tonumber(WearState.transmissionBaseHighGear) or 1)))
        SetEntityMaxSpeed(vehicle, math.max(1.0, tonumber(WearState.transmissionBaseMaxSpeed) or 1.0))
    end
    WearState.transmissionLimpActive = false
    WearState.transmissionBaseHighGear = nil
    WearState.transmissionBaseMaxSpeed = nil
end

local function applyElectricLimp(vehicle)
    if not WearState.electricLimpActive then
        WearState.electricBaseHighGear = math.max(1, math.floor(tonumber(GetVehicleHighGear(vehicle)) or 1))
        WearState.electricBaseMaxSpeed = math.max(1.0, tonumber(GetVehicleEstimatedMaxSpeed(vehicle)) or 1.0)
        WearState.electricLimpActive = true
    end
    SetVehicleHighGear(vehicle, 1)
    SetEntityMaxSpeed(vehicle, 30.0 / 3.6)
end

local function resetElectricLimp(vehicle)
    if not WearState.electricLimpActive then return end
    if vehicle ~= 0 and DoesEntityExist(vehicle) then
        SetVehicleHighGear(vehicle, math.max(1, math.floor(tonumber(WearState.electricBaseHighGear) or 1)))
        SetEntityMaxSpeed(vehicle, math.max(1.0, tonumber(WearState.electricBaseMaxSpeed) or 1.0))
    end
    WearState.electricLimpActive = false
    WearState.electricBaseHighGear = nil
    WearState.electricBaseMaxSpeed = nil
end

local function evaluateWearEffects(vehicle, deltaMs)
    if not WearState.isElectric then
        if (WearState.wear.spark_plugs or 100.0) <= 0.5 then
            SetVehicleEngineOn(vehicle, false, true, false)
        end

        local transFluid = WearState.wear.transmission_fluid or 100.0
        local clutchVal  = WearState.wear.clutch or 100.0

        if transFluid <= 0.5 or clutchVal <= 0.5 then
            applyTransmissionLimp(vehicle)
        else
            resetTransmissionLimp(vehicle)
        end

        local oilVal = WearState.wear.engine_oil or 100.0
        if oilVal <= 0.5 then
            if not WearState.engineDamageActive then
                WearState.engineDamageActive = true
                WearState.engineDamageElapsedMs = 0
                startEngineSmokeFx(vehicle)
            end

            WearState.engineDamageElapsedMs = (WearState.engineDamageElapsedMs or 0) + math.max(0, deltaMs or 0)
            if WearState.engineDamageElapsedMs >= 30000 then
                SetVehicleEngineOn(vehicle, false, true, false)
                SetVehicleEngineHealth(vehicle, 0.0)
            end
        else
            if WearState.engineDamageActive then
                resetEngineDamage()
            end
        end
        return
    end

    local batteryVal = WearState.wear.traction_battery or 100.0
    if batteryVal <= 0.5 then
        SetVehicleEngineOn(vehicle, false, true, false)
        SetVehicleEngineHealth(vehicle, 0.0)
    end

    local inverterVal = WearState.wear.inverter or 100.0
    if inverterVal <= 0.5 then
        applyElectricLimp(vehicle)
    else
        resetElectricLimp(vehicle)
    end
end

local function fullRepairVehicleState(vehicle)
    fixVehicleTyres(vehicle)
    resetEngineDamage()
    resetTransmissionLimp(vehicle)
    resetElectricLimp(vehicle)

    SetVehicleUndriveable(vehicle, false)
    SetVehicleReduceGrip(vehicle, false)
    SetVehicleHandbrake(vehicle, false)

    SetVehicleEngineTorqueMultiplier(vehicle, 1.0)
    SetVehicleEnginePowerMultiplier(vehicle, 0.0)
    SetEntityMaxSpeed(vehicle, 999.0)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleEngineOn(vehicle, true, true, false)

    applyBrakeDegradation(vehicle, 3)
    applySuspensionDegradation(vehicle, 3)

    WearState.appliedBands = { brake_pads = 3, suspension = 3 }
    WearState.tyresPopped = false
    updateCriticalWearState()
end

local function applyWearEffectsToVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return end

    local wear = WearState.wear
    local applied = WearState.appliedBands

    if (wear.tyres or 100.0) <= 0.5 and not WearState.tyresPopped then
        popVehicleTyres(vehicle)
    end

    local brakeBand = getBrakeBand(wear.brake_pads or 100.0)
    if (wear.brake_fluid or 100.0) <= 0.5 then
        brakeBand = 0
    end

    if applied.brake_pads ~= brakeBand then
        local prevBand = applied.brake_pads
        applied.brake_pads = brakeBand
        if brakeBand == 0 or prevBand == 0 then
            applyBrakeDegradation(vehicle, brakeBand)
        end
    end

    local suspBand = getSuspensionBand(wear.suspension or 100.0)
    if applied.suspension ~= suspBand then
        applied.suspension = suspBand
        applySuspensionDegradation(vehicle, suspBand)
    end
end

function WearSystem_OnVehicleReady(vehicle, plateStr)
    if sanitizePlate(WearState.plate) ~= sanitizePlate(plateStr) then return end

    captureBaseHandlingFloats(vehicle)
    WearState.appliedBands = {}
    WearState.tyresPopped = false
    applyWearEffectsToVehicle(vehicle)
end

local function saveWearToServer()
    if not WearState.plate or WearState.plate == "" then return end

    local res = Sky.Cb.Trigger("sky_mechanicjob:wear:save", {
        plate = WearState.plate,
        wear = WearState.wear,
        mileage = WearState.mileage
    })

    if type(res) ~= "table" or res.success ~= true then
        local errReason = (type(res) == "table" and res.error) or "unknown_error"
        print(("[sky_mechanicjob][wear] Save failed for plate %s: %s"):format(tostring(WearState.plate), tostring(errReason)))
    end
end

local function isMileageHudEnabled()
    return Config and Config.ToggleFeatures and Config.ToggleFeatures.mileageHud ~= false
end

local function isTuningActive()
    return TuningState and TuningState.active == true
end

local function getMileageHudPosition()
    local pos = Config and Config.MileageHud and Config.MileageHud.position or {}
    local left = (type(pos.left) == "string" and pos.left ~= "") and pos.left or nil
    local right = (type(pos.right) == "string" and pos.right ~= "") and pos.right or nil
    local top = (type(pos.top) == "string" and pos.top ~= "") and pos.top or nil
    local bottom = (type(pos.bottom) == "string" and pos.bottom ~= "") and pos.bottom or nil

    return { left = left, right = right, top = top, bottom = bottom }
end

local function sendMileageHudMessage(actionName, payload)
    if not isMileageHudEnabled() then return end
    SendNUIMessage({ action = actionName, payload = payload or {} })
end

local function showMileageHud()
    if isTuningActive() then return end

    local digitsCfg = math.floor(tonumber(Config and Config.MileageHud and Config.MileageHud.digits) or 6)
    if digitsCfg < 4 then digitsCfg = 4 end
    if digitsCfg > 8 then digitsCfg = 8 end

    local mileageVal = math.max(0, math.floor(tonumber(WearState.mileage) or 0))
    WearState.lastMileageHudSent = mileageVal

    sendMileageHudMessage("mileageHud:show", {
        mileage = mileageVal,
        digits = digitsCfg,
        position = getMileageHudPosition()
    })
end

local function updateMileageHud(force)
    if not isMileageHudEnabled() or isTuningActive() then return end

    local mileageVal = math.max(0, math.floor(tonumber(WearState.mileage) or 0))
    if not force and WearState.lastMileageHudSent == mileageVal then
        return
    end

    WearState.lastMileageHudSent = mileageVal
    sendMileageHudMessage("mileageHud:update", { mileage = mileageVal })
end

function refreshMileageHudVisibility()
    if isMileageHudEnabled() and WearState.active and not isTuningActive() then
        showMileageHud()
        updateMileageHud(true)
        return
    end

    WearState.lastMileageHudSent = nil
    SendNUIMessage({ action = "mileageHud:hide", payload = {} })
end

local function startVehicleTrackingLoop(ped, vehicle)
    CreateThread(function()
        local lastTime = GetGameTimer()
        while WearState.active do
            if not DoesEntityExist(vehicle) then break end

            local currentSpeed = GetEntitySpeed(vehicle) or 0.0
            local pollInterval = 1000

            if WearState.hasCriticalWear then
                pollInterval = 100
            elseif not WearState.baseHandling.fBrakeForce then
                pollInterval = 100
            elseif not WearState.hasCriticalWear and currentSpeed > 0.5 then
                pollInterval = 500
            end

            Wait(pollInterval)
            if not WearState.active then break end

            local now = GetGameTimer()
            local deltaMs = math.max(0, now - lastTime)
            lastTime = now

            if (now - (WearState.lastVehicleExitCheckMs or 0)) >= 1000 then
                WearState.lastVehicleExitCheckMs = now
                if not DoesEntityExist(vehicle) or not IsPedInAnyVehicle(ped, false) or GetVehiclePedIsIn(ped, false) ~= vehicle or GetPedInVehicleSeat(vehicle, -1) ~= ped then
                    break
                end
            end

            if (now - (WearState.lastMileageHudSyncMs or 0)) >= 2000 then
                WearState.lastMileageHudSyncMs = now
                updateMileageHud(true)
            end

            if not WearState.baseHandling.fBrakeForce then
                if (now - (WearState.enteredAtMs or now)) >= 500 then
                    captureBaseHandlingFloats(vehicle)
                    WearState.appliedBands = {}
                    WearState.tyresPopped = false
                    applyWearEffectsToVehicle(vehicle)
                end
            end

            local speedVal = DoesEntityExist(vehicle) and GetEntitySpeed(vehicle) or 0.0
            if speedVal > 0.5 then
                local currentCoords = GetEntityCoords(vehicle)
                local distKm = 0.0

                if WearState.lastCoords then
                    distKm = #(currentCoords - WearState.lastCoords) / 1000.0
                end
                WearState.lastCoords = currentCoords

                if distKm > 0.0001 then
                    WearState.mileage = WearState.mileage + distKm
                    WearState.mileageSinceLastSave = WearState.mileageSinceLastSave + distKm

                    local activeParts = WearState.activeWearParts or ICE_WEAR_PARTS
                    for _, partKey in ipairs(activeParts) do
                        local wearPerKm = partWearPerKmMap[partKey] or 0.0
                        local wearLoss = distKm * wearPerKm
                        if wearLoss > 0.0 then
                            WearState.wear[partKey] = math.max(0.0, (WearState.wear[partKey] or 100.0) - wearLoss)
                        end
                    end

                    updateCriticalWearState()
                    if checkBrakeAndSuspensionBandsChanged() then
                        applyWearEffectsToVehicle(vehicle)
                    end
                    updateMileageHud(false)
                end
            end

            if WearState.hasCriticalWear then
                evaluateWearEffects(vehicle, deltaMs)
            end
        end

        refreshMileageHudVisibility()
    end)
end

local function onVehicleEnter(vehicle)
    local ped = PlayerPedId()
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then return end

    local plateStr = sanitizePlate(GetVehicleNumberPlateText(vehicle))
    if plateStr == "" then return end

    WearState.active = false
    WearState.isFetching = true
    WearState.vehicle = vehicle
    WearState.plate = plateStr
    WearState.lastCoords = GetEntityCoords(vehicle)
    WearState.mileageSinceLastSave = 0.0
    WearState.appliedBands = {}
    WearState.tyresPopped = false
    WearState.engineDamageActive = false
    WearState.engineDamageElapsedMs = 0
    WearState.transmissionLimpActive = false
    WearState.transmissionBaseHighGear = nil
    WearState.transmissionBaseMaxSpeed = nil
    WearState.engineSmokeFx = nil
    WearState.electricLimpActive = false
    WearState.electricBaseHighGear = nil
    WearState.electricBaseMaxSpeed = nil

    WearState.isElectric = isElectricVehicle(vehicle)
    WearState.activeWearParts = getActiveWearParts(vehicle)
    WearState.lastMileageHudSent = nil
    WearState.lastMileageHudSyncMs = 0
    WearState.lastVehicleExitCheckMs = 0
    WearState.enteredAtMs = GetGameTimer()

    WearState.wear = {}
    WearState.mileage = 0
    for _, partKey in ipairs(ICE_WEAR_PARTS) do
        WearState.wear[partKey] = 100.0
    end

    local res = Sky.Cb.Trigger("sky_mechanicjob:wear:get", { plate = plateStr })
    if type(res) == "table" and res.success then
        WearState.wear = res.wear or WearState.wear
        WearState.mileage = res.mileage or 0
    end

    updateCriticalWearState()
    WearState.active = true
    WearState.isFetching = false

    refreshMileageHudVisibility()
    startVehicleTrackingLoop(ped, vehicle)
end

AddEventHandler("sky_mechanicjob:jobConfigurator:updated", function()
    calculatePartWearPerKm()
    if isMileageHudEnabled() then
        if not WearState.active and not WearState.isFetching then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 and DoesEntityExist(veh) and GetPedInVehicleSeat(veh, -1) == ped then
                onVehicleEnter(veh)
                return
            end
        end
    end
    refreshMileageHudVisibility()
end)

local function onVehicleExit()
    if not WearState.active then return end

    saveWearToServer()
    local oldVeh = WearState.vehicle

    WearState.active = false
    WearState.isFetching = false
    WearState.vehicle = 0
    WearState.plate = ""
    WearState.hasCriticalWear = false
    WearState.lastMileageHudSent = nil
    WearState.lastVehicleExitCheckMs = 0
    WearState.engineDamageElapsedMs = 0

    resetEngineDamage()
    resetTransmissionLimp(oldVeh)
    resetElectricLimp(oldVeh)

    WearState.isElectric = false
    WearState.activeWearParts = ICE_WEAR_PARTS

    SendNUIMessage({ action = "mileageHud:hide", payload = {} })
end

AddEventHandler("gameEventTriggered", function(eventName, eventArgs)
    if eventName == "CEventNetworkPlayerEnteredVehicle" then
        if not WearState.active then
            local veh = eventArgs and eventArgs[2]
            if not veh then
                veh = GetVehiclePedIsIn(PlayerPedId(), false)
            end
            if veh == 0 or not DoesEntityExist(veh) then return end
            if GetPedInVehicleSeat(veh, -1) ~= PlayerPedId() then return end
            onVehicleEnter(veh)
        end
    end

    if eventName == "CEventNetworkPlayerExitedVehicle" then
        if WearState.active then
            onVehicleExit()
        end
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    SendNUIMessage({ action = "mileageHud:hide", payload = {} })
end)

local function isPartAffectedByRepair(payload, partName)
    if type(payload) ~= "table" then return false end

    local targetPart = tostring(payload.part or "")
    if targetPart == partName then return true end

    if type(payload.repairedParts) ~= "table" then return false end
    for _, item in ipairs(payload.repairedParts) do
        if tostring(item or "") == partName then return true end
    end

    return false
end

RegisterNetEvent("sky_mechanicjob:wear:partRepaired")
AddEventHandler("sky_mechanicjob:wear:partRepaired", function(payload)
    if type(payload) ~= "table" or type(payload.wear) ~= "table" then
        print("[sky_mechanicjob][wear:partRepaired] payload check failed: payload is not a table or wear is missing")
        return
    end

    local plateStr = sanitizePlate(payload.plate)
    if plateStr == "" then
        print("[sky_mechanicjob][wear:partRepaired] payload check failed: payload plate is empty")
        return
    end

    local targetVeh = 0
    if sanitizePlate(WearState.plate) == plateStr then
        if WearState.vehicle ~= 0 and DoesEntityExist(WearState.vehicle) then
            WearState.wear = payload.wear
            targetVeh = WearState.vehicle
        end
    else
        targetVeh = findVehicleByPlate(plateStr)
    end

    if targetVeh == 0 or not DoesEntityExist(targetVeh) then
        print(("[sky_mechanicjob][wear:partRepaired] vehicle check failed: no vehicle entity found for plate %s"):format(tostring(plateStr)))
        return
    end

    if sanitizePlate(WearState.plate) == plateStr then
        WearState.appliedBands = {}
        WearState.tyresPopped = false
        updateCriticalWearState()
    end

    local partStr = tostring(payload.part or "")
    local isFullRepair = (payload.fullRepair == true or partStr == "admin_full_repair")

    if isFullRepair then
        fullRepairVehicleState(targetVeh)
    else
        if partStr == "tyres" or isPartAffectedByRepair(payload, "tyres") then
            fixVehicleTyres(targetVeh)
        end
    end

    if not isFullRepair then
        if isPartAffectedByRepair(payload, "spark_plugs") or isPartAffectedByRepair(payload, "engine_oil") or isPartAffectedByRepair(payload, "coolant") or isPartAffectedByRepair(payload, "transmission_fluid") or isPartAffectedByRepair(payload, "clutch") or isPartAffectedByRepair(payload, "air_filter") then
            resetEngineDamage()
            if GetVehicleEngineHealth(targetVeh) <= 0.0 then
                SetVehicleEngineHealth(targetVeh, 1000.0)
            end
        end
    end

    if not isFullRepair then
        if isPartAffectedByRepair(payload, "transmission_fluid") or isPartAffectedByRepair(payload, "clutch") then
            resetTransmissionLimp(targetVeh)
        end
    end

    if not isFullRepair then
        if isPartAffectedByRepair(payload, "traction_battery") then
            if GetVehicleEngineHealth(targetVeh) <= 0.0 then
                SetVehicleEngineHealth(targetVeh, 1000.0)
            end
        end
    end

    if not isFullRepair then
        if isPartAffectedByRepair(payload, "inverter") then
            resetElectricLimp(targetVeh)
        end
    end

    if sanitizePlate(WearState.plate) == plateStr and not isFullRepair then
        applyWearEffectsToVehicle(targetVeh)
    end
end)

registerExport("GetVehicleMileage", function(vehicleOrPlate)
    local resolvedPlate = ""
    if vehicleOrPlate == nil then
        if WearState.active then
            return math.floor(tonumber(WearState.mileage) or 0)
        end
        print("[sky_mechanicjob][GetVehicleMileage] argument check failed: no vehicle or plate provided and no active vehicle is tracked")
        return nil
    elseif type(vehicleOrPlate) == "number" then
        if vehicleOrPlate == 0 or not DoesEntityExist(vehicleOrPlate) then
            print(("[sky_mechanicjob][GetVehicleMileage] vehicle check failed: invalid vehicle entity %s"):format(tostring(vehicleOrPlate)))
            return nil
        end
        resolvedPlate = sanitizePlate(GetVehicleNumberPlateText(vehicleOrPlate))
    elseif type(vehicleOrPlate) == "string" then
        resolvedPlate = sanitizePlate(vehicleOrPlate)
    else
        print(("[sky_mechanicjob][GetVehicleMileage] argument check failed: expected vehicle entity or plate, got %s"):format(type(vehicleOrPlate)))
        return nil
    end

    if resolvedPlate == "" then
        print("[sky_mechanicjob][GetVehicleMileage] plate check failed: resolved plate is empty")
        return nil
    end

    if WearState.active and sanitizePlate(WearState.plate) == resolvedPlate then
        return math.floor(tonumber(WearState.mileage) or 0)
    end

    local res = Sky.Cb.Trigger("sky_mechanicjob:wear:get", { plate = resolvedPlate })
    if type(res) == "table" and res.success then
        return math.floor(tonumber(res.mileage) or 0)
    end

    print(("[sky_mechanicjob][GetVehicleMileage] server lookup failed for plate %s"):format(tostring(resolvedPlate)))
    return nil
end)

RegisterNUICallback("wear:getDiagnostics", function(data, cb)
    local cdnBase, cdnFallback = getNuiImageBases()
    local tabletNetId = math.floor(tonumber(OrderTabletState and OrderTabletState.connectedVehicleNetId) or 0)

    if tabletNetId <= 0 then
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh == 0 or not DoesEntityExist(veh) then
            local pCoords = GetEntityCoords(ped)
            veh = GetClosestVehicle(pCoords.x, pCoords.y, pCoords.z, 12.0, 0, 71)
        end
        if veh ~= 0 and DoesEntityExist(veh) then
            tabletNetId = NetworkGetNetworkIdFromEntity(veh)
            if OrderTabletState then
                OrderTabletState.connectedVehicleNetId = tabletNetId
            end
        end
    end

    if tabletNetId <= 0 then
        cb({
            success = true,
            data = {
                plate = "N/A",
                mileage = 0,
                wear = {},
                wearParts = {},
                noVehicle = true,
                cdnBase = cdnBase,
                cdnFallback = cdnFallback
            }
        })
        return
    end

    local veh = NetworkGetEntityFromNetworkId(tabletNetId)
    if veh == 0 or not DoesEntityExist(veh) then
        if OrderTabletState then OrderTabletState.connectedVehicleNetId = 0 end
        cb({
            success = true,
            data = {
                plate = "N/A",
                mileage = 0,
                wear = {},
                wearParts = {},
                noVehicle = true,
                cdnBase = cdnBase,
                cdnFallback = cdnFallback
            }
        })
        return
    end

    local plateStr = sanitizePlate(GetVehicleNumberPlateText(veh))
    if plateStr == "" then
        cb({ success = false, error = "no_vehicle" })
        return
    end

    if WearState.active and sanitizePlate(WearState.plate) == plateStr then
        local activeParts = WearState.activeWearParts or getActiveWearParts(veh)
        cb({
            success = true,
            data = {
                plate = plateStr,
                mileage = math.floor(WearState.mileage),
                wear = buildWearMap(WearState.wear, activeParts),
                wearParts = activeParts,
                isElectric = WearState.isElectric,
                wheelDamage = getWheelDamageRepairSummary(veh),
                modelName = getVehicleModelName(veh),
                cdnBase = cdnBase,
                cdnFallback = cdnFallback
            }
        })
        return
    end

    local res = Sky.Cb.Trigger("sky_mechanicjob:wear:get", { plate = plateStr })
    local wearData = nil
    local mileageVal = 0

    if type(res) == "table" and res.success then
        wearData = res.wear
        mileageVal = res.mileage or 0
    else
        wearData = {}
        for _, partKey in ipairs(ICE_WEAR_PARTS) do
            wearData[partKey] = 100.0
        end
    end

    local activeParts = getActiveWearParts(veh)
    cb({
        success = true,
        data = {
            plate = plateStr,
            mileage = math.floor(mileageVal),
            wear = buildWearMap(wearData, activeParts),
            wearParts = activeParts,
            isElectric = isElectricVehicle(veh),
            wheelDamage = getWheelDamageRepairSummary(veh),
            modelName = getVehicleModelName(veh),
            cdnBase = cdnBase,
            cdnFallback = cdnFallback
        }
    })
end)

RegisterNUICallback("wear:repairPart", function(data, cb)
    if OrderInstallState.active then
        cb({ success = false, error = "install_busy" })
        return
    end

    local targetPlate = sanitizePlate(tostring(data and data.plate or ""))
    local targetPart = tostring(data and data.part or "")

    local tabletNetId = math.floor(tonumber(OrderTabletState and OrderTabletState.connectedVehicleNetId) or 0)
    if tabletNetId <= 0 then
        cb({ success = false, error = "no_vehicle" })
        return
    end

    local veh = NetworkGetEntityFromNetworkId(tabletNetId)
    if veh == 0 or not DoesEntityExist(veh) then
        OrderTabletState.connectedVehicleNetId = 0
        cb({ success = false, error = "no_vehicle" })
        return
    end

    if not containsPart(targetPart, getActiveWearParts(veh)) then
        cb({ success = false, error = "invalid_payload" })
        return
    end

    local vehPlate = sanitizePlate(GetVehicleNumberPlateText(veh))
    if vehPlate == "" or (targetPlate ~= "" and targetPlate ~= vehPlate) then
        cb({ success = false, error = "vehicle_mismatch" })
        return
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    local vehCoords = GetEntityCoords(veh)
    if #(pedCoords - vehCoords) > 15.0 then
        cb({ success = false, error = "vehicle_too_far" })
        return
    end

    local prepRes = Sky.Cb.Trigger("sky_mechanicjob:wear:prepareRepairInstall", {
        plate = vehPlate,
        part = targetPart
    }) or {}

    if type(prepRes) ~= "table" or prepRes.success ~= true then
        cb({
            success = false,
            error = (type(prepRes) == "table" and prepRes.error) or "prepare_failed",
            requiredItem = type(prepRes) == "table" and prepRes.requiredItem or nil
        })
        return
    end

    local prepData = prepRes.data or {}
    local reqItem = tostring(prepData.requiredItem or DEFAULT_PART_ITEM)
    local flowType = tostring(prepData.flow or "performance")

    local partLabel = getNuiLocale(("tablet.diagnostics.parts.%s"):format(targetPart), targetPart)

    local modMapping = {
        tyres = "mod_23", brake_pads = "mod_12", suspension = "mod_15",
        spark_plugs = "toggle_18", engine_oil = "toggle_18", coolant = "toggle_18",
        brake_fluid = "mod_12", transmission_fluid = "mod_13", clutch = "mod_13",
        air_filter = "toggle_18", catalytic_converter = "mod_4",
        traction_battery = "toggle_18", inverter = "toggle_18"
    }

    local optionModId = modMapping[targetPart] or "toggle_18"

    clearOrderInstallState()
    OrderInstallState.active = true
    OrderInstallState.finalizing = false
    OrderInstallState.orderId = 0
    OrderInstallState.partIndex = 0
    OrderInstallState.part = {
        id = optionModId,
        label = partLabel,
        valueLabel = partLabel,
        value = 0
    }
    OrderInstallState.requiredItem = reqItem
    OrderInstallState.removeRequiredItemAfterUse = (prepData.removeRequiredItemAfterUse == true)

    if flowType == "wheel" then
        OrderInstallState.installFlow = "wheel_change"
    elseif flowType == "oil_change" then
        OrderInstallState.installFlow = "oil_change"
    elseif flowType == "fluid_refill" then
        OrderInstallState.installFlow = "fluid_refill"
    elseif flowType == "underbody_neon" then
        OrderInstallState.installFlow = "underbody_neon"
    elseif flowType == "catalytic_converter" then
        OrderInstallState.installFlow = "catalytic_converter"
    else
        OrderInstallState.installFlow = "hood_install"
    end

    OrderInstallState.repairMode = true
    OrderInstallState.repairPart = targetPart
    OrderInstallState.repairPlate = vehPlate
    OrderInstallState.vehicleNetId = tabletNetId
    OrderInstallState.vehicle = veh
    OrderInstallState.simpleChecklistVisible = false
    OrderInstallState.simpleStep = "idle"

    if flowType == "wheel" then
        local detachedIndexes = (targetPart == "tyres") and getDetachedWheelDamageIndexes(veh) or nil
        startWheelInstallState(targetPart == "brake_pads", targetPart == "suspension", {
            skipDetach = (targetPart == "tyres"),
            detachedWheelIndexes = (detachedIndexes and #detachedIndexes > 0) and detachedIndexes or nil
        })
        notify(("%s: %s. %s"):format(
            getNuiLocale("tablet.orders.installing", "Installing part"),
            partLabel,
            getNuiLocale("tablet.orders.wheel_checklist.hint", "Use radial menu and follow the wheel checklist.")
        ), "info")
    elseif flowType == "catalytic_converter" then
        startCatalyticInstallState(veh, tabletNetId, vehPlate)
        notify(("%s: %s. %s"):format(
            getNuiLocale("tablet.orders.installing", "Installing part"),
            partLabel,
            getNuiLocale("tablet.orders.wheel_checklist.hint", "Use radial menu and follow the wheel checklist.")
        ), "info")
    else
        startSimpleInstallState()
        releaseOrderHeldProp()
        notify(("%s: %s. %s"):format(
            getNuiLocale("tablet.orders.installing", "Installing part"),
            partLabel,
            getNuiLocale("tablet.orders.simple_checklist.hint", "Use radial menu and complete the install checklist.")
        ), "info")
    end

    releaseNuiFocus()
    cb({
        success = true,
        started = true,
        flow = flowType,
        requiredItem = reqItem
    })
end)
