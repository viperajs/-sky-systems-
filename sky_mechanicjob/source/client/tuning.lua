if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/tuning.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/tuning.lua
--  Deobfuscated by Claude
--  Original: 3399 lines → Cleaned
-- =====================================================

local function logDebug(msg)
    if Sky and Sky.IsDebugActive and Sky.IsDebugActive() and Sky.Debug then
        Sky.Debug("debug", msg)
    end
end

function tryDetachNearestVehicleWheel()
    local veh, wheelTarget = getNearestDetachWheelTarget()
    if veh == nil then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.DetachWheelNoVehicle) or "No nearby vehicle found."
        }
    end

    if not wheelTarget then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.DetachWheelNotNear) or "Move closer to a wheel to detach it."
        }
    end

    local mgOk, mgErr = runTuningMinigame("wheel_change", "detach", veh)
    if not mgOk then
        return false, mgErr
    end

    if not requestVehicleControl(veh, 700) then
        print("[sky_mechanicjob][wheel_detach] failed: no entity control for target vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.DetachWheelControlFailed) or "Unable to detach wheel right now."
        }
    end

    local expandedIndexes = expandWheelIndexes(wheelTarget.index)
    for _, idx in ipairs(expandedIndexes) do
        BreakOffVehicleWheel(veh, idx, true, true, false, false)
        Wait(0)
        if IsVehicleTyreBurst(veh, idx, false) then
            break
        end
    end

    return true, nil, expandedIndexes
end

function tryAttachNearestVehicleWheel(vehicle, detachedIndexes, options)
    if vehicle == nil or vehicle == 0 or not DoesEntityExist(vehicle) then
        logDebug(("[sky_mechanicjob][wheel_attach][check] vehicle invalid (vehicle=%s exists=%s)"):format(
            tostring(vehicle), tostring(vehicle ~= nil and vehicle ~= 0 and DoesEntityExist(vehicle))
        ))
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.AttachWheelNoVehicle) or "No nearby vehicle found."
        }
    end

    local mgOk, mgErr = runTuningMinigame("wheel_change", "attach", vehicle, options)
    if not mgOk then
        local errStr = type(mgErr) == "table" and (mgErr.fallback or mgErr.key or "unknown") or tostring(mgErr)
        logDebug(("[sky_mechanicjob][wheel_attach][check] minigame rejected (%s)"):format(errStr))
        return false, mgErr
    end

    if not requestVehicleControl(vehicle, 700) then
        print("[sky_mechanicjob][wheel_attach] failed: no entity control for target vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.AttachWheelControlFailed) or "Unable to attach wheel right now."
        }
    end

    local targetIndexes = resolveAttachWheelIndexes(vehicle, detachedIndexes)
    if type(detachedIndexes) == "table" and #detachedIndexes == 0 then
        if #targetIndexes > 0 then
            WheelOrderInstallState.detachedWheelIndexes = targetIndexes
            logDebug(("[sky_mechanicjob][wheel_attach][check] recovered detachedWheelIndexes=%s"):format(
                json.encode(targetIndexes)
            ))
        end
    end

    if #targetIndexes == 0 then
        logDebug(("[sky_mechanicjob][wheel_attach][check] detachedWheelIndexes invalid (type=%s count=%s)"):format(
            type(detachedIndexes), tostring(#targetIndexes)
        ))
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.WheelInstallWrongStep) or "Complete the current wheel-change step first."
        }
    end

    for _, idx in ipairs(targetIndexes) do
        SetVehicleTyreFixed(vehicle, idx)
        Wait(0)
    end

    local bodyHealth = GetVehicleBodyHealth(vehicle)
    local engineHealth = GetVehicleEngineHealth(vehicle)
    local tankHealth = GetVehiclePetrolTankHealth(vehicle)
    local dirtLevel = GetVehicleDirtLevel(vehicle)

    SetVehicleFixed(vehicle)
    SetVehicleBodyHealth(vehicle, bodyHealth)
    SetVehicleEngineHealth(vehicle, engineHealth)
    SetVehiclePetrolTankHealth(vehicle, tankHealth)
    SetVehicleDirtLevel(vehicle, dirtLevel)

    logDebug(("[sky_mechanicjob][wheel_attach][check] tyres fixed for indexes=%s"):format(json.encode(targetIndexes)))
    return true
end

function detachNearestVehicleWheel()
    local ok, errData = ensureWheelOrderStep("detach_wheel")
    if not ok then
        local msg = (tuningLocales and tuningLocales.WheelInstallWrongStep) or "Complete the current wheel-change step first."
        if type(errData) == "table" and type(errData.fallback) == "string" and errData.fallback ~= "" then
            msg = errData.fallback
        end
        notify(msg, "error")
        return false
    end

    local nearestVeh = select(1, getNearestDetachWheelTarget())
    if nearestVeh ~= OrderInstallState.vehicle then
        notify((tuningLocales and tuningLocales.WheelInstallWrongVehicle) or "Use the radial action on the connected order vehicle.", "error")
        return false
    end

    local detachOk, detachErr, detachedIdxs = tryDetachNearestVehicleWheel()
    if not detachOk then
        local msg = (tuningLocales and tuningLocales.DetachWheelControlFailed) or "Unable to detach wheel right now."
        if type(detachErr) == "table" and type(detachErr.fallback) == "string" and detachErr.fallback ~= "" then
            msg = detachErr.fallback
        end
        notify(msg, "error")
        return false
    end

    WheelOrderInstallState.detachedWheelIndexes = detachedIdxs
    WheelOrderInstallState.step = "attach"
    sendWheelChecklistUpdate()
    notify((tuningLocales and tuningLocales.DetachWheelSuccess) or "Wheel detached.", "success")
    return true
end

function attachNearestVehicleWheel()
    local ok, errData = ensureWheelOrderStep("attach_wheel")
    if not ok then
        local msg = (tuningLocales and tuningLocales.WheelInstallWrongStep) or "Complete the current wheel-change step first."
        if type(errData) == "table" and type(errData.fallback) == "string" and errData.fallback ~= "" then
            msg = errData.fallback
        end
        notify(msg, "error")
        return false
    end

    local nearestVeh = select(1, getNearestDetachWheelTarget())
    if nearestVeh ~= OrderInstallState.vehicle then
        notify((tuningLocales and tuningLocales.WheelInstallWrongVehicle) or "Use the radial action on the connected order vehicle.", "error")
        return false
    end

    local attachOk, attachErr = tryAttachNearestVehicleWheel(OrderInstallState.vehicle, WheelOrderInstallState.detachedWheelIndexes)
    if not attachOk then
        local msg = (tuningLocales and tuningLocales.AttachWheelControlFailed) or "Unable to attach wheel right now."
        if type(attachErr) == "table" and type(attachErr.fallback) == "string" and attachErr.fallback ~= "" then
            msg = attachErr.fallback
        end
        notify(msg, "error")
        return false
    end

    if not applyOrderPartToVehicle(OrderInstallState.vehicle, OrderInstallState.part) then
        notify(getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle."), "error")
        return false
    end

    WheelOrderInstallState.step = "remove"
    sendWheelChecklistUpdate()
    notify((tuningLocales and tuningLocales.AttachWheelSuccess) or "New wheel attached.", "success")
    return true
end

function tryUseVehicleCarJack()
    if CarJackState.active then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.CarJackBusy) or "Car jack is already in use."
        }
    end

    if CarJackState.lifted then
        if CarJackState.vehicle == 0 or not DoesEntityExist(CarJackState.vehicle) then
            clearCarJackState()
        end
    end

    if CarJackState.lifted then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.CarJackAlreadyPlaced) or "A car jack is already placed. Remove it first."
        }
    end

    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)

    local targetVeh = getClosestCarJackVehicle(pedCoords)
    if targetVeh == 0 or not DoesEntityExist(targetVeh) then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.CarJackNoVehicle) or "No nearby vehicle found."
        }
    end

    local sideData = getCarJackSideData(targetVeh, pedCoords)
    if not sideData then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.CarJackNotNear) or "Move closer to a vehicle side to place the jack."
        }
    end

    if not requestVehicleControl(targetVeh, 900) then
        print("[sky_mechanicjob][car_jack] failed: no entity control for target vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.CarJackControlFailed) or "Unable to use car jack right now."
        }
    end

    local sideDir = 1
    if sideData.label and sideData.label:find("_left", 1, true) then
        sideDir = -1
    end

    local rightVec = getEntityRightVector(targetVeh)
    local minDim, maxDim = GetModelDimensions(GetEntityModel(targetVeh))
    local halfWidth = math.max(math.abs(minDim.x), math.abs(maxDim.x))

    local spawnCoords = GetOffsetFromEntityInWorldCoords(targetVeh, sideDir * (halfWidth + CAR_JACK_SIDE_PADDING), 0.0, 0.0)
    local propHash = GetHashKey(CAR_JACK_PROP_MODEL)

    if not requestModelLoaded(propHash, 2500) then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.CarJackPropFailed) or "Unable to prepare car jack."
        }
    end

    local propPosX = spawnCoords.x - (rightVec.x * sideDir * 0.25)
    local propPosY = spawnCoords.y - (rightVec.y * sideDir * 0.25)
    local propPosZ = spawnCoords.z - 0.45

    local jackObj = CreateObjectNoOffset(propHash, propPosX, propPosY, propPosZ, true, true, false)
    if jackObj == 0 or not DoesEntityExist(jackObj) then
        print(("[sky_mechanicjob][car_jack] failed: could not create jack object (%s)"):format(CAR_JACK_PROP_MODEL))
        SetModelAsNoLongerNeeded(propHash)
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.CarJackPropFailed) or "Unable to prepare car jack."
        }
    end

    SetEntityHeading(jackObj, GetEntityHeading(targetVeh) + (sideDir > 0 and 90.0 or -90.0) + 180.0)
    PlaceObjectOnGroundProperly(jackObj)
    FreezeEntityPosition(jackObj, true)
    SetModelAsNoLongerNeeded(propHash)

    CarJackState.prop = jackObj

    local animOk, animErr = playCarJackPedAnim(ped, CAR_JACK_LIFT_TIME_MS + 800, GetEntityCoords(targetVeh), sideData)
    if not animOk then
        clearCarJackState()
        return false, animErr
    end

    CarJackState.active = true
    FreezeEntityPosition(targetVeh, true)

    local vehCoords = GetEntityCoords(targetVeh)
    local vehRot = GetEntityRotation(targetVeh, 2)
    local targetRoll = vehRot.y + (sideDir * -CAR_JACK_LIFT_ANGLE)

    local steps = math.max(1, math.floor(CAR_JACK_LIFT_TIME_MS / CAR_JACK_STEP_MS))
    for i = 1, steps do
        local pct = i / steps
        SetEntityCoordsNoOffset(targetVeh, vehCoords.x, vehCoords.y, vehCoords.z + (CAR_JACK_LIFT_HEIGHT * pct), false, false, false)
        SetEntityRotation(targetVeh, vehRot.x, vehRot.y + ((targetRoll - vehRot.y) * pct), vehRot.z, 2, true)
        Wait(CAR_JACK_STEP_MS)
    end

    ClearPedTasks(ped)
    CarJackState.active = false
    CarJackState.lifted = true
    CarJackState.vehicle = targetVeh
    CarJackState.baseCoords = vehCoords
    CarJackState.baseRotation = vehRot
    CarJackState.targetRoll = targetRoll

    return true
end

function tryRemoveVehicleCarJack()
    if CarJackState.active then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.CarJackBusy) or "Car jack is already in use."
        }
    end

    if not CarJackState.lifted then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.CarJackNotPlaced) or "No car jack is currently placed."
        }
    end

    local veh = CarJackState.vehicle
    if veh == 0 or not DoesEntityExist(veh) then
        clearCarJackState()
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.CarJackVehicleMissing) or "Lifted vehicle is no longer available."
        }
    end

    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local vehCoords = GetEntityCoords(veh)

    if #(pedCoords - vehCoords) > CAR_JACK_MAX_VEHICLE_DISTANCE then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.CarJackTooFar) or "Move closer to the lifted vehicle to remove the jack."
        }
    end

    if not requestVehicleControl(veh, 900) then
        print("[sky_mechanicjob][car_jack] failed: no entity control for jack removal")
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.CarJackControlFailed) or "Unable to use car jack right now."
        }
    end

    local animOk, animErr = playCarJackPedAnim(ped, CAR_JACK_LIFT_TIME_MS + 800, vehCoords, pedCoords)
    if not animOk then
        return false, animErr
    end

    CarJackState.active = true
    FreezeEntityPosition(CarJackState.vehicle, true)

    local baseCoords = CarJackState.baseCoords
    local baseRot = CarJackState.baseRotation
    local targetRoll = CarJackState.targetRoll

    local steps = math.max(1, math.floor(CAR_JACK_LIFT_TIME_MS / CAR_JACK_STEP_MS))
    for i = steps, 1, -1 do
        local pct = i / steps
        SetEntityCoordsNoOffset(CarJackState.vehicle, baseCoords.x, baseCoords.y, baseCoords.z + (CAR_JACK_LIFT_HEIGHT * pct), false, false, false)
        SetEntityRotation(CarJackState.vehicle, baseRot.x, baseRot.y + ((targetRoll - baseRot.y) * pct), baseRot.z, 2, true)
        Wait(CAR_JACK_STEP_MS)
    end

    SetEntityCoordsNoOffset(CarJackState.vehicle, baseCoords.x, baseCoords.y, baseCoords.z, false, false, false)
    SetEntityRotation(CarJackState.vehicle, baseRot.x, baseRot.y, baseRot.z, 2, true)
    FreezeEntityPosition(CarJackState.vehicle, false)
    SetVehicleOnGroundProperly(CarJackState.vehicle)

    ClearPedTasks(ped)
    clearCarJackState()
    return true
end

RegisterNUICallback("tuning:apply", function(data, cb)
    if not TuningState.active then
        cb({ success = false, error = "inactive" })
        return
    end

    local optionId = data and data.id
    local valueVal = data and data.value
    local context = tostring((data and data.context) or "selection")

    local opt = optionId and TuningState.optionMap[optionId]
    if not opt then
        cb({ success = false, error = "invalid_option" })
        return
    end

    local valNum = tonumber(valueVal)
    if not valNum then
        cb({ success = false, error = "invalid_value" })
        return
    end

    if opt.kind ~= "stancer" then
        valNum = math.floor(valNum)
    end

    if valNum < opt.min then valNum = opt.min end
    if valNum > opt.max then valNum = opt.max end

    if not isAllowedOptionValue(opt, valNum) then
        print(("[sky_mechanicjob][tuning] apply rejected: value %s is not allowed for option %s"):format(tostring(valNum), tostring(opt.id)))
        cb({ success = false, error = "invalid_value" })
        return
    end

    local baseOpt = TuningState.optionBaselines[opt.id] or {}
    logDebug(("[sky_mechanicjob][tuning:basket][apply:before] context=%s id=%s value=%s target=%s baseValue=%s paintType=%s basePaintType=%s custom=%s baseCustom=%s"):format(
        context, tostring(opt.id), tostring(opt.value), tostring(valNum), tostring(baseOpt.value),
        tostring(opt.paintType), tostring(baseOpt.paintType),
        formatColorRgb(opt.customColor), formatColorRgb(baseOpt.customColor)
    ))

    if not applyOption(opt, valNum) then
        notify((tuningLocales and tuningLocales.ApplyFailed) or "Failed to apply this tuning option.", "error")
        cb({ success = false, error = "apply_failed" })
        return
    end

    logDebug(("[sky_mechanicjob][tuning:basket][apply:after] context=%s id=%s value=%s changed=%s price=%s paintType=%s custom=%s"):format(
        context, tostring(opt.id), tostring(opt.value),
        tostring(hasOptionChangedFromBaseline(opt)),
        tostring(getCurrentOptionPrice(opt)),
        tostring(opt.paintType),
        formatColorRgb(opt.customColor)
    ))

    local updateData = { id = opt.id, value = opt.value }
    local resPayload = { success = true, value = opt.value }

    if opt.supportsCustom == true then
        updateData.customColor = opt.customColor or false
        updateData.paintType = opt.paintType
        resPayload.customColor = opt.customColor or false
        resPayload.paintType = opt.paintType
    end

    sendUi("tuning:update", updateData)
    cb(resPayload)
end)

RegisterNUICallback("tuning:applyCustomColor", function(data, cb)
    if not TuningState.active then
        cb({ success = false, error = "inactive" })
        return
    end

    local optionId = data and data.id
    local context = tostring((data and data.context) or "selection")
    local opt = optionId and TuningState.optionMap[optionId]

    if not opt or opt.supportsCustom ~= true then
        cb({ success = false, error = "invalid_option" })
        return
    end

    local customCol = data and data.customColor
    if customCol ~= nil and type(customCol) ~= "table" then
        print("[sky_mechanicjob][tuning] applyCustomColor rejected: invalid_color (customColor is not nil or table)")
        cb({ success = false, error = "invalid_color" })
        return
    end

    local baseOpt = TuningState.optionBaselines[optionId] or {}
    logDebug(("[sky_mechanicjob][tuning:basket][custom:before] context=%s id=%s value=%s baseValue=%s paintType=%s targetPaintType=%s basePaintType=%s currentCustom=%s targetCustom=%s baseCustom=%s"):format(
        context, tostring(optionId), tostring(opt.value), tostring(baseOpt.value),
        tostring(opt.paintType), tostring(data.paintType), tostring(baseOpt.paintType),
        formatColorRgb(opt.customColor), formatColorRgb(customCol), formatColorRgb(baseOpt.customColor)
    ))

    if not applyCustomColorOption(opt, data.paintType, customCol) then
        print(("[sky_mechanicjob][tuning] applyCustomColor failed id=%s"):format(tostring(optionId)))
        cb({ success = false, error = "apply_failed" })
        return
    end

    logDebug(("[sky_mechanicjob][tuning:basket][custom:after] context=%s id=%s value=%s changed=%s price=%s paintType=%s custom=%s"):format(
        context, tostring(opt.id), tostring(opt.value),
        tostring(hasOptionChangedFromBaseline(opt)),
        tostring(getCurrentOptionPrice(opt)),
        tostring(opt.paintType),
        formatColorRgb(opt.customColor)
    ))

    sendUi("tuning:update", { id = opt.id, customColor = opt.customColor, paintType = opt.paintType })
    cb({ success = true, customColor = opt.customColor, paintType = opt.paintType })
end)

RegisterNUICallback("tuning:reset", function(data, cb)
    if not TuningState.active then
        cb({ success = false, error = "inactive" })
        return
    end

    if TuningState.snapshotProps then
        Sky.Vehicle.new(TuningState.vehicle):SetVehicleProperties(TuningState.snapshotProps)
        CustomTuning.RestoreSessionState(TuningState.vehicle)

        buildOptionsForVehicle(TuningState.vehicle)
        CustomTuning.CaptureSessionState(TuningState.vehicle)

        sendUi("tuning:fullSync", buildUiPayload())
        cb({ success = true })
        return
    end

    cb({ success = false, error = "missing_snapshot" })
end)

RegisterNUICallback("tuning:syncOptions", function(data, cb)
    if not TuningState.active then
        cb({ success = false, error = "inactive" })
        return
    end

    local veh = TuningState.vehicle
    if veh == 0 or not DoesEntityExist(veh) then
        cb({ success = false, error = "vehicle_missing" })
        return
    end

    local context = tostring((data and data.context) or "manual_sync")
    local oldBasket, oldTotal = buildPendingBasket()

    logDebug(("[sky_mechanicjob][tuning:basket][sync:before] context=%s entries=%s total=%s"):format(
        context, tostring(#oldBasket), tostring(oldTotal)
    ))

    buildOptionsForVehicle(veh)

    local newBasket, newTotal = buildPendingBasket()
    logDebug(("[sky_mechanicjob][tuning:basket][sync:after] context=%s entries=%s total=%s"):format(
        context, tostring(#newBasket), tostring(newTotal)
    ))

    cb({ success = true, tuning = buildUiPayload() })
end)

local function deleteVehicleForRespawn(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    if GetResourceState("AdvancedParking") == "started" then
        exports["AdvancedParking"]:DeleteVehicle(vehicle)
    else
        DeleteVehicle(vehicle)
    end
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
end

local function respawnVehicleWithProps(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 0
    end

    local ped = PlayerPedId()
    local modelHash = GetEntityModel(vehicle)
    local coords = GetEntityCoords(vehicle)
    local heading = GetEntityHeading(vehicle)
    local isEngineOn = GetIsVehicleEngineRunning(vehicle)

    local vehProps = Sky.Vehicle.new(vehicle):GetVehicleProperties()
    if not vehProps then return 0 end

    RequestModel(modelHash)
    local maxWait = GetGameTimer() + 2000
    while not HasModelLoaded(modelHash) and GetGameTimer() < maxWait do
        Wait(0)
    end

    if not HasModelLoaded(modelHash) then return 0 end

    deleteVehicleForRespawn(vehicle)

    local newVeh = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)
    if newVeh == 0 or not DoesEntityExist(newVeh) then
        return 0
    end

    SetEntityAsMissionEntity(newVeh, true, true)
    SetVehicleOnGroundProperly(newVeh)
    Sky.Vehicle.new(newVeh):SetVehicleProperties(vehProps)

    if isEngineOn then
        SetVehicleEngineOn(newVeh, true, true, false)
    end

    TaskWarpPedIntoVehicle(ped, newVeh, -1)
    SetModelAsNoLongerNeeded(modelHash)

    return newVeh
end

RegisterNUICallback("tuning:resetStance", function(data, cb)
    if not TuningState.active then
        cb({ success = false, error = "inactive" })
        return
    end

    local veh = TuningState.vehicle
    if veh == 0 or not DoesEntityExist(veh) then
        cb({ success = false, error = "vehicle_missing" })
        return
    end

    local saveToServer = (TuningState.persistChangesOnClose == true)
    if not StanceKit.ResetToDefault(veh, saveToServer) then
        cb({ success = false, error = "reset_failed" })
        return
    end

    local currentVeh = veh
    if saveToServer then
        saveTuningForVehicle(veh)
        local newVeh = respawnVehicleWithProps(veh)
        if newVeh == 0 then
            cb({ success = false, error = "respawn_failed" })
            return
        end
        TuningState.vehicle = newVeh
        TuningState.vehicleNetId = NetworkGetNetworkIdFromEntity(newVeh)
        TuningState.snapshotProps = Sky.Vehicle.new(newVeh):GetVehicleProperties()
        currentVeh = newVeh
    end

    buildOptionsForVehicle(currentVeh)
    local uiPayload = buildUiPayload()

    sendUi("tuning:fullSync", uiPayload)
    cb({ success = true, tuning = uiPayload })
end)

CreateThread(function()
    local lastChecklistTime = 0
    while true do
        if not OrderInstallState.active then
            lastChecklistTime = 0
            Wait(500)
        else
            local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
            if veh == 0 or not DoesEntityExist(veh) then
                clearOrderInstallState()
                lastChecklistTime = 0
                Wait(250)
            else
                local pedCoords = GetEntityCoords(PlayerPedId())
                local vehCoords = GetEntityCoords(veh)
                local dist = #(pedCoords - vehCoords)

                local waitMs = (dist <= 4.0) and 200 or ((dist <= 8.0) and 250 or 400)

                if dist <= 4.0 and not WheelOrderInstallState.active and not RepaintOrderInstallState.active and not OrderInstallState.simpleChecklistVisible then
                    local now = GetGameTimer()
                    if lastChecklistTime <= now then
                        sendSimpleInstallChecklistUpdate()
                        lastChecklistTime = now + 250
                    end
                end
                Wait(waitMs)
            end
        end
    end
end)

function isSelfServiceTuningPointRequiredForAction(actionType)
    local req = Config and Config.TuningWorkshopRequirement or {}
    if actionType == "remove" then
        return req.requireForRemoval == true
    end
    return req.requireForInstall == true
end

local selfServiceCache = { data = nil, fetchedAt = 0, lastMissingPrint = 0 }

local function fetchCreatorSelfServiceTuningPoints()
    local now = GetGameTimer()
    if type(selfServiceCache.data) == "table" and (now - selfServiceCache.fetchedAt) < 5000 then
        return selfServiceCache.data
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:creator:getData", { creatorKey = "workshopcreator" })
    if type(res) == "table" and res.success == true and type(res.data) == "table" then
        selfServiceCache.data = res.data
        selfServiceCache.fetchedAt = now
    end

    return selfServiceCache.data
end

local function getSelfServiceTuningPoints()
    local creatorData = fetchCreatorSelfServiceTuningPoints()
    if type(creatorData) ~= "table" or type(creatorData.entries) ~= "table" then
        return {}
    end

    local points = {}
    for _, entry in ipairs(creatorData.entries) do
        if type(entry) == "table" and type(entry.points) == "table" then
            for _, pt in ipairs(entry.points) do
                if type(pt) == "table" and pt.type == "self_service_tuning" then
                    if pt.x ~= nil and pt.y ~= nil and pt.z ~= nil then
                        table.insert(points, vector3(
                            tonumber(pt.x) or 0.0,
                            tonumber(pt.y) or 0.0,
                            tonumber(pt.z) or 0.0
                        ))
                    end
                end
            end
        end
    end
    return points
end

function isNearSelfServiceTuningPoint()
    local reqCfg = Config and Config.TuningWorkshopRequirement or {}
    local maxDist = tonumber(reqCfg.distance) or 8.0
    local pedCoords = GetEntityCoords(PlayerPedId())

    local points = getSelfServiceTuningPoints()
    if #points == 0 then
        local now = GetGameTimer()
        if (now - selfServiceCache.lastMissingPrint) > 10000 then
            print("[sky_mechanicjob][tuning] workshop requirement failed: no self_service_tuning points are configured")
            selfServiceCache.lastMissingPrint = now
        end
        return false
    end

    for _, ptCoords in ipairs(points) do
        if #(pedCoords - ptCoords) <= maxDist then
            return true
        end
    end

    return false
end

function notifySelfServiceTuningPointRequired()
    local msg = (tuningLocales and tuningLocales.SelfServiceTuningPointRequired) or "Move closer to a self-service tuning point to install or remove tuning."
    notify(msg, "error")
end

local registeredJobInteractions = {}

local function registerJobInteractionEvents(jobName)
    if type(jobName) ~= "string" or jobName == "" or registeredJobInteractions[jobName] then
        return
    end
    registeredJobInteractions[jobName] = true

    RegisterNetEvent(("sky_jobs_base:interaction:%s:self_service_tuning"):format(jobName), function()
        openFromCurrentVehicle(false, nil, true, jobName, false, true)
    end)

    RegisterNetEvent(("sky_jobs_base:interaction:%s:detach_wheel"):format(jobName), function()
        detachNearestVehicleWheel()
    end)

    RegisterNetEvent(("sky_jobs_base:interaction:%s:attach_wheel"):format(jobName), function()
        attachNearestVehicleWheel()
    end)
end

registerJobInteractionEvents("mechanic")
for _, job in ipairs(Config and Config.Jobs or {}) do
    local jName = type(job) == "table" and job.name or job
    registerJobInteractionEvents(jName)
end

AddEventHandler("sky_mechanicjob:jobConfigurator:updated", function()
    for _, job in ipairs(Config and Config.Jobs or {}) do
        local jName = type(job) == "table" and job.name or job
        registerJobInteractionEvents(jName)
    end
end)

Sky.RegisterInput("MechanicTuningToggleFocus", "SPACE", function()
    if not TuningState.active or TuningState.nuiFocused or not canToggleTuningFocus() then
        return
    end
    setNuiFocusState(true)
end)

local function parseLocationCoords(coords)
    if type(coords) ~= "table" and type(coords) ~= "vector3" then
        return nil
    end

    local x, y, z = tonumber(coords.x), tonumber(coords.y), tonumber(coords.z)
    if not x or not y or not z then
        print("[sky_mechanicjob][instant_tuning] location skipped: coords must include numeric x, y, and z")
        return nil
    end

    return vector3(x, y, z)
end

local function getJobKey()
    if Sky_Jobs and Sky_Jobs.Access and Sky_Jobs.Access.HasSnapshot and not Sky_Jobs.Access.HasSnapshot() then
        Sky_Jobs.Access.Refresh()
    end
    return Sky_Jobs and Sky_Jobs.Access and Sky_Jobs.Access.GetJobKey and Sky_Jobs.Access.GetJobKey()
end

local function parseAllowedJobs(jobsList)
    local jobMap = {}
    local count = 0
    if type(jobsList) ~= "table" then
        return jobMap, count
    end

    for _, entry in ipairs(jobsList) do
        local nameStr = (type(entry) == "string") and entry:match("^%s*(.-)%s*$") or nil
        if nameStr and nameStr ~= "" then
            if not jobMap[nameStr] then
                jobMap[nameStr] = true
                count = count + 1
            end
        end
    end

    return jobMap, count
end

local function canJobUseInstantLocation(location, rootConfig)
    local playerJob = getJobKey()
    local locJobMap, locJobCount = parseAllowedJobs(location.allowedJobs or location.jobs)
    local rootJobMap, rootJobCount = parseAllowedJobs(rootConfig.allowedJobs or rootConfig.jobs)

    if locJobCount > 0 then
        return locJobMap[playerJob] == true
    end

    if rootJobCount > 0 then
        return rootJobMap[playerJob] == true
    end

    local locMechOnly = location.mechanicOnly == true
    local rootMechOnly = rootConfig.mechanicOnly == true

    if locMechOnly or rootMechOnly then
        return isConfiguredMechanicJob(playerJob)
    end

    return true
end

local function parsePointSubConfig(cfg)
    if type(cfg) ~= "table" or cfg.enabled == false then
        return {}
    end
    return cfg
end

local activeInstantPoints = {}
local registeredInstantEvents = {}

local function removeInstantTuningPoints()
    for pointId in pairs(activeInstantPoints) do
        Sky.DeleteInteractionPoint(pointId)
    end
    activeInstantPoints = {}
end

local function createInstantTuningPoints()
    local rootCfg = Config and Config.InstantTuning or {}
    removeInstantTuningPoints()

    if Config and Config.ToggleFeatures and Config.ToggleFeatures.instantTuning ~= true then
        return
    end

    if type(rootCfg.locations) ~= "table" then
        print("[sky_mechanicjob][instant_tuning] config check failed: Config.InstantTuning.locations must be a table")
        return
    end

    for idx, loc in ipairs(rootCfg.locations) do
        if type(loc) ~= "table" then
            print(("[sky_mechanicjob][instant_tuning] location skipped: entry %s is not a table"):format(tostring(idx)))
        else
            local parsedCoords = parseLocationCoords(loc.coords or loc)
            if parsedCoords then
                local npcCfg = parsePointSubConfig(loc.npc or rootCfg.npc)
                if type(npcCfg) == "table" and npcCfg.enabled == true and npcCfg.heading == nil then
                    npcCfg.heading = tonumber(loc.heading) or 0.0
                end

                local forceMarker = (rootCfg.forceMarkerInteraction == true)
                if loc.forceMarkerInteraction ~= nil then
                    forceMarker = (loc.forceMarkerInteraction == true)
                end

                local pointData = {
                    coords = parsedCoords,
                    label = tostring(loc.label or rootCfg.label or "Instant Tuning"),
                    marker = parsePointSubConfig(loc.marker or rootCfg.marker),
                    npc = npcCfg,
                    blip = parsePointSubConfig(loc.blip or rootCfg.blip),
                    interactionDistance = tonumber(loc.interactionDistance or rootCfg.interactionDistance) or 4.0,
                    options = { forceMarkerInteraction = forceMarker },
                    id = loc.id or ("instant_tuning:%s"):format(idx),
                    locationIndex = idx
                }

                local eventName = ("sky_mechanicjob:tuning:openInstantLocation:%s"):format(idx)
                if not registeredInstantEvents[eventName] then
                    registeredInstantEvents[eventName] = true

                    RegisterNetEvent(eventName, function()
                        local curLoc = (Config and Config.InstantTuning and Config.InstantTuning.locations and Config.InstantTuning.locations[idx]) or loc
                        local curRoot = Config and Config.InstantTuning or {}

                        if not canJobUseInstantLocation(curLoc, curRoot) then
                            notify((tuningLocales and tuningLocales.NoPermission) or "You do not have permission to use this command.", "error")
                            return
                        end

                        openFromCurrentVehicle(false, nil, true, nil, true)
                    end)
                end

                Sky.CreateInteractionPoint(
                    { x = pointData.coords.x, y = pointData.coords.y, z = pointData.coords.z, canInteract = function()
                        return canJobUseInstantLocation(loc, rootCfg)
                    end },
                    pointData.label, eventName, pointData.id, pointData.marker, pointData.npc, pointData.blip,
                    GetCurrentResourceName(), pointData.interactionDistance, nil, nil, pointData.options
                )

                activeInstantPoints[pointData.id] = true
            end
        end
    end
end

CreateThread(createInstantTuningPoints)
AddEventHandler("sky_mechanicjob:jobConfigurator:updated", function()
    createInstantTuningPoints()
end)

RegisterNUICallback("tuning:purchase", function(data, cb)
    if not TuningState.active then
        cb({ success = false, error = "inactive" })
        return
    end

    if not Sky.Cooldown(250) then
        cb({ success = false, error = "cooldown" })
        return
    end

    local method = tostring((data and data.method) or "cash")
    if method ~= "cash" and method ~= "card" then
        print(("[sky_mechanicjob][tuning] purchase rejected: invalid method %s"):format(method))
        cb({ success = false, error = "invalid_method" })
        return
    end

    local pendingParts, pendingTotal = buildPendingBasket()
    logDebug(("[sky_mechanicjob][tuning:basket][checkout] method=%s entries=%s total=%s"):format(
        method, tostring(#pendingParts), tostring(pendingTotal)
    ))

    local hasParts = (#pendingParts > 0)
    local hasCustomProfile = false

    for _, part in ipairs(pendingParts) do
        local opt = TuningState.optionMap and TuningState.optionMap[part.id]
        if opt then
            if opt.customHandlingProfileKey or type(opt.customHandlingExtension) == "table" then
                hasCustomProfile = true
                break
            end
        end
    end

    local isAdmin = (TuningState.adminMode == true)
    local isInstant = (TuningState.instantMode == true)
    local isFreeTuning = (isAdmin or isInstant) and true or isCurrentVehicleFreeTuningModel()

    if isAdmin and TuningState.mode == "stancing" and hasParts then
        local stancePart = nil
        for _, part in ipairs(pendingParts) do
            if part.id == "stancer_bundle" then
                stancePart = part
                break
            end
        end

        if stancePart then
            local veh = TuningState.vehicle
            setTuningClosed(false)
            local started = startDirectStanceInstall(veh, stancePart)
            cb({
                success = started,
                error = not started and "stance_install_start_failed" or nil,
                amount = 0,
                method = method
            })
            return
        end
    end

    if pendingTotal <= 0 and (not isFreeTuning or not hasParts) then
        captureOptionBaselines()
        TuningState.snapshotProps = Sky.Vehicle.new(TuningState.vehicle):GetVehicleProperties()
        TuningState.antiLagSnapshot = AntiLag.GetPersistedState(TuningState.vehicle)
        TuningState.twoStepSnapshot = TwoStep.GetPersistedState(TuningState.vehicle)

        if isFreeTuning then
            TuningState.persistChangesOnClose = true
            TuningState.skipRestoreOnClose = true
            TuningState.stanceSnapshot = StanceKit.BuildPersistedState(TuningState.vehicle)
            TuningState.stanceSnapshotPlate = Sky.Math.Trim(GetVehicleNumberPlateText(TuningState.vehicle))

            saveTuningForVehicle(TuningState.vehicle)
            StanceKit.EnsureRuntimeForVehicle(TuningState.vehicle)
        end

        buildOptionsForVehicle(TuningState.vehicle)
        cb({
            success = true,
            amount = 0,
            method = method,
            tuning = buildUiPayload()
        })
        return
    end

    local chargeAmount = isAdmin and 0 or pendingTotal
    local modelHash = GetEntityModel(TuningState.vehicle)

    local res = Sky.Cb.Trigger("sky_mechanicjob:tuning:purchase", {
        method = method,
        amount = chargeAmount,
        plate = GetVehicleNumberPlateText(TuningState.vehicle),
        model = GetDisplayNameFromVehicleModel(modelHash),
        modelHash = modelHash,
        vehicleClass = GetVehicleClass(TuningState.vehicle),
        parts = pendingParts,
        societyJob = TuningState.societyJob,
        adminMode = isAdmin,
        instantTuning = isInstant,
        selfServiceTuning = (TuningState.selfServiceMode == true),
        freeTuningVehicle = isFreeTuning
    })

    logDebug(("[sky_mechanicjob][tuning:basket][checkout:result] requestedAmount=%s success=%s resultAmount=%s error=%s appliedDirect=%s order=%s"):format(
        tostring(chargeAmount),
        tostring(type(res) == "table" and res.success),
        tostring(type(res) == "table" and res.amount),
        tostring(type(res) == "table" and res.error),
        tostring(type(res) == "table" and res.appliedDirect),
        type(res) == "table" and (json.encode(res.order) or "nil") or "nil"
    ))

    if type(res) ~= "table" or res.success ~= true then
        if type(res) == "table" and res.error == "not_authorized" then
            notify((tuningLocales and tuningLocales.NoPermission) or "You do not have permission to use this command.", "error")
        elseif type(res) == "table" and res.error == "insufficient_funds" then
            if method == "card" then
                notify((tuningLocales and tuningLocales.PurchaseNotEnoughCard) or "Not enough money on your card.", "error")
            else
                notify((tuningLocales and tuningLocales.PurchaseNotEnoughCash) or "Not enough cash.", "error")
            end
        else
            notify((tuningLocales and tuningLocales.PurchaseFailed) or "Payment failed. Please try again.", "error")
        end

        cb({
            success = false,
            error = (type(res) == "table" and res.error) or "payment_failed",
            amount = chargeAmount,
            method = method
        })
        return
    end

    local isDirectApplied = isFreeTuning or (type(res) == "table" and res.appliedDirect == true)

    if isDirectApplied then
        if hasCustomProfile then
            CustomTuning.ApplyProfiles(TuningState.vehicle)
        end

        TuningState.persistChangesOnClose = true
        TuningState.skipRestoreOnClose = true
        TuningState.snapshotProps = Sky.Vehicle.new(TuningState.vehicle):GetVehicleProperties()
        TuningState.antiLagSnapshot = AntiLag.GetPersistedState(TuningState.vehicle)
        TuningState.twoStepSnapshot = TwoStep.GetPersistedState(TuningState.vehicle)

        TuningState.stanceSnapshot = StanceKit.BuildPersistedState(TuningState.vehicle)
        TuningState.stanceSnapshotPlate = Sky.Math.Trim(GetVehicleNumberPlateText(TuningState.vehicle))

        saveTuningForVehicle(TuningState.vehicle)
        StanceKit.EnsureRuntimeForVehicle(TuningState.vehicle)
    else
        if not restoreVehicleToOptionBaselines() then
            if TuningState.snapshotProps then
                Sky.Vehicle.new(TuningState.vehicle):SetVehicleProperties(TuningState.snapshotProps)
            end
        end

        StanceKit.RestorePreviewState(TuningState.vehicle, TuningState.stanceSnapshot, TuningState.stanceSnapshotPlate)
        AntiLag.ApplyPersistedStateToVehicle(TuningState.vehicle, GetVehicleNumberPlateText(TuningState.vehicle), TuningState.antiLagSnapshot)
        TwoStep.ApplyPersistedStateToVehicle(TuningState.vehicle, GetVehicleNumberPlateText(TuningState.vehicle), TuningState.twoStepSnapshot)
    end

    buildOptionsForVehicle(TuningState.vehicle)
    captureOptionBaselines()

    if isAdmin then
        notify((tuningLocales and tuningLocales.AdminApplySuccess) or "Changes applied successfully.", "success")
    elseif isInstant or (type(res) == "table" and res.appliedDirect == true) then
        notify((tuningLocales and tuningLocales.InstantApplySuccess) or "Tuning applied successfully.", "success")
    else
        notify((tuningLocales and tuningLocales.PurchaseSuccess) or "Order created successfully.", "success")
    end

    cb({
        success = true,
        amount = chargeAmount,
        method = method,
        tuning = buildUiPayload()
    })
end)
