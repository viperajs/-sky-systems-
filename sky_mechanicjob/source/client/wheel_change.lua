if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/wheel_change.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/wheel_change.lua
--  Deobfuscated by Claude
--  Original: 6594 lines → Cleaned
-- =====================================================

local function logDebug(msg)
    if Sky and Sky.IsDebugActive and Sky.IsDebugActive() and Sky.Debug then
        Sky.Debug("debug", msg)
    end
end

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

function stopWheelWorkAnim()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    StopAnimTask(ped, WHEEL_WORK_KNEEL_ANIM_DICT, WHEEL_WORK_KNEEL_ANIM_CLIP, 1.0)
    StopAnimTask(ped, WHEEL_WORK_OVERLAY_ANIM_DICT, WHEEL_WORK_OVERLAY_ANIM_CLIP, 1.0)
end

function startWheelWorkAnim(targetEntity)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then return end

    local kneelLoaded = requestAnimDictLoaded(WHEEL_WORK_KNEEL_ANIM_DICT, 2500)
    local overlayLoaded = requestAnimDictLoaded(WHEEL_WORK_OVERLAY_ANIM_DICT, 2500)

    if targetEntity ~= nil and targetEntity ~= 0 and DoesEntityExist(targetEntity) then
        local pedCoords = GetEntityCoords(ped)
        local targetCoords = GetEntityCoords(targetEntity)
        local heading = GetHeadingFromVector_2d(targetCoords.x - pedCoords.x, targetCoords.y - pedCoords.y)
        SetEntityHeading(ped, heading)
    end

    if kneelLoaded then
        TaskPlayAnim(ped, WHEEL_WORK_KNEEL_ANIM_DICT, WHEEL_WORK_KNEEL_ANIM_CLIP, 8.0, -8.0, -1, 1, 0.0, false, false, false)
    else
        print(("[sky_mechanicjob][wheel_minigame] failed: kneel anim dict not loaded (%s)"):format(WHEEL_WORK_KNEEL_ANIM_DICT))
    end

    if overlayLoaded then
        TaskPlayAnim(ped, WHEEL_WORK_OVERLAY_ANIM_DICT, WHEEL_WORK_OVERLAY_ANIM_CLIP, 8.0, -8.0, -1, 49, 0.0, false, false, false)
    else
        print(("[sky_mechanicjob][wheel_minigame] failed: overlay anim dict not loaded (%s)"):format(WHEEL_WORK_OVERLAY_ANIM_DICT))
    end

    if not kneelLoaded and not overlayLoaded then
        TaskStartScenarioInPlace(ped, WHEEL_WORK_FALLBACK_SCENARIO, 0, true)
    end
end

function startBelowVehicleWorkAnim(targetEntity)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then return end

    if targetEntity ~= nil and targetEntity ~= 0 and DoesEntityExist(targetEntity) then
        TaskTurnPedToFaceEntity(ped, targetEntity, 700)
        local pedCoords = GetEntityCoords(ped)
        local targetCoords = GetEntityCoords(targetEntity)
        local heading = (GetHeadingFromVector_2d(targetCoords.x - pedCoords.x, targetCoords.y - pedCoords.y) + 180.0) % 360.0
        SetEntityHeading(ped, heading)
    end

    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_VEHICLE_MECHANIC", 0, true)
end

function runWheelDetachMinigame(mode, targetEntity, extraData)
    local modeType = (mode == "attach") and "attach" or "detach"
    local isAttach = (modeType == "attach")
    local isTableExtra = (type(extraData) == "table")

    local busyErrStr, cancelErrStr, failErrStr

    if isAttach then
        busyErrStr = (tuningLocales and tuningLocales.AttachWheelMinigameBusy) or "Wheel attach minigame is already running."
        cancelErrStr = (tuningLocales and tuningLocales.AttachWheelMinigameCanceled) or "Wheel attach canceled."
        failErrStr = (tuningLocales and tuningLocales.AttachWheelMinigameFailed) or "You failed to tighten all bolts."
    else
        busyErrStr = (tuningLocales and tuningLocales.DetachWheelMinigameBusy) or "Wheel detach minigame is already running."
        cancelErrStr = (tuningLocales and tuningLocales.DetachWheelMinigameCanceled) or "Wheel detach canceled."
        failErrStr = (tuningLocales and tuningLocales.DetachWheelMinigameFailed) or "You failed to loosen all bolts."
    end

    if isTableExtra then
        busyErrStr = (tuningLocales and tuningLocales.CatalyticMinigameBusy) or busyErrStr
        cancelErrStr = (tuningLocales and tuningLocales.CatalyticMinigameCanceled) or cancelErrStr
        failErrStr = (tuningLocales and tuningLocales.CatalyticMinigameFailed) or failErrStr
    end

    local sessOk, sessData = TuningMinigames.StartSession("wheel_change", {
        state = WheelDetachMinigameState,
        timeoutMs = 45000,
        busyError = { key = "radial.errors.generic", fallback = busyErrStr }
    })

    if not sessOk then
        if isAttach then
            logDebug("[sky_mechanicjob][wheel_attach][check] minigame already active")
        end
        return false, sessData
    end

    local token = sessData.token
    if isTableExtra then
        startBelowVehicleWorkAnim(targetEntity)
    else
        startWheelWorkAnim(targetEntity)
    end

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    local boltCount = math.floor(tonumber(isTableExtra and extraData.boltCount) or DETACH_WHEEL_MINIGAME_BOLT_COUNT)
    local reqRotation = math.floor(tonumber(isTableExtra and extraData.requiredRotation) or DETACH_WHEEL_MINIGAME_ROTATION_DEGREES)

    SendNUIMessage({
        action = "wheelDetach:minigame:start",
        payload = {
            token = token,
            mode = modeType,
            boltCount = boltCount,
            requiredRotation = reqRotation,
            attachUsesDirtyWheel = isTableExtra and extraData.attachUsesDirtyWheel or false,
            target = isTableExtra and extraData.target or nil
        }
    })

    if isAttach then
        logDebug(("[sky_mechanicjob][wheel_attach][check] minigame start sent (token=%s mode=%s)"):format(
            tostring(token), tostring(modeType)
        ))
    end

    local res = Citizen.Await(sessData.promise)

    stopWheelWorkAnim()
    closeWheelDetachMinigameUi()
    releaseNuiFocus()

    local isSuccess = res and res.success == true
    local isCancelled = res and res.cancelled == true

    if isSuccess then
        if isAttach then
            logDebug(("[sky_mechanicjob][wheel_attach][check] minigame success (token=%s)"):format(tostring(token)))
        end
        return true
    end

    if isCancelled then
        if isAttach then
            logDebug(("[sky_mechanicjob][wheel_attach][check] minigame cancelled (token=%s)"):format(tostring(token)))
        end
        return false, { key = "radial.errors.generic", fallback = cancelErrStr }
    end

    if isAttach then
        logDebug(("[sky_mechanicjob][wheel_attach][check] minigame failed (token=%s)"):format(tostring(token)))
    end

    return false, { key = "radial.errors.generic", fallback = failErrStr }
end

TuningMinigames.Register("wheel_change", runWheelDetachMinigame)

local XENON_CUSTOM_STATE_BAG_KEY = "sky_mechanicjob:xenonCustomColor"

local function sanitizeRgb(rgb)
    if type(rgb) ~= "table" then return nil end
    return {
        r = math.floor(math.max(0, math.min(255, tonumber(rgb.r) or 0))),
        g = math.floor(math.max(0, math.min(255, tonumber(rgb.g) or 0))),
        b = math.floor(math.max(0, math.min(255, tonumber(rgb.b) or 0)))
    }
end

local function getXenonCustomState(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end
    return sanitizeRgb(Entity(vehicle).state[XENON_CUSTOM_STATE_BAG_KEY])
end

function setTuningClosed(skipUiMessage)
    local shouldSave = TuningState.persistChangesOnClose or (TuningState.mode == "rgb_controller")

    if shouldSave then
        if TuningState.vehicle ~= 0 and DoesEntityExist(TuningState.vehicle) then
            saveTuningForVehicle(TuningState.vehicle)
            StanceKit.EnsureRuntimeForVehicle(TuningState.vehicle)
        end
    end

    if not shouldSave and not TuningState.skipRestoreOnClose then
        if TuningState.vehicle ~= 0 and DoesEntityExist(TuningState.vehicle) then
            RgbController.StopEffectsForVehicle(TuningState.vehicle)
        end
    end

    if TuningState.vehicle ~= 0 and DoesEntityExist(TuningState.vehicle) then
        if TuningState.snapshotProps and not shouldSave and not TuningState.skipRestoreOnClose then
            Sky.Vehicle.new(TuningState.vehicle):SetVehicleProperties(TuningState.snapshotProps)
            XenonSync.SetCustomColor(TuningState.vehicle, TuningState.xenonCustomStateSnapshot)
            StanceKit.RestorePreviewState(TuningState.vehicle, TuningState.stanceSnapshot, TuningState.stanceSnapshotPlate)
            CustomTuning.RestoreSessionState(TuningState.vehicle)
        end
    end

    if not shouldSave and not TuningState.skipRestoreOnClose then
        if TuningState.vehicle ~= 0 and DoesEntityExist(TuningState.vehicle) then
            AntiLag.ApplyPersistedStateToVehicle(TuningState.vehicle, GetVehicleNumberPlateText(TuningState.vehicle), TuningState.antiLagSnapshot)
            TwoStep.ApplyPersistedStateToVehicle(TuningState.vehicle, GetVehicleNumberPlateText(TuningState.vehicle), TuningState.twoStepSnapshot)
        end
    end

    if TuningState.vehicle ~= 0 and DoesEntityExist(TuningState.vehicle) then
        SetVehicleLights(TuningState.vehicle, 0)
    end

    if TuningState.camera then
        TuningState.camera:Remove()
        TuningState.camera = nil
    end

    TuningState.active = false
    TuningState.adminMode = false
    TuningState.instantMode = false
    TuningState.selfServiceMode = false
    TuningState.mode = "full"
    TuningState.persistChangesOnClose = false
    TuningState.skipRestoreOnClose = false
    TuningState.hidePricesForPublicSelfService = false
    TuningState.pricingProfileJob = nil
    TuningState.vehicle = 0
    TuningState.societyJob = nil
    TuningState.nuiFocused = false
    TuningState.focusToggleReadyAt = 0
    TuningState.snapshotProps = nil
    TuningState.xenonCustomStateSnapshot = nil
    TuningState.stanceSnapshot = nil
    TuningState.stanceSnapshotPlate = nil
    TuningState.stanceDirty = false
    TuningState.antiLagSnapshot = nil
    TuningState.twoStepSnapshot = nil
    TuningState.optionBaselines = {}
    TuningState.customHandlingBase = nil
    TuningState.customHandlingSessionState = nil
    TuningState.options = {}
    TuningState.optionMap = {}
    TuningState.sections = {}

    RefreshTuningCostProfile()
    setNuiFocusState(false)
    if refreshMileageHudVisibility then
        refreshMileageHudVisibility()
    end

    if not skipUiMessage then
        sendUi("close")
    end
end

local hornState = { vehicle = 0, value = -2, untilAt = 0, token = 0 }
local lockSpeedState = { vehicle = 0, untilAt = 0, token = 0 }
local nearbyVehicleCache = { radius = 0.0, expiresAt = 0, origin = nil, vehicles = {} }

local function updateTuningHeadlights(sectionName)
    local veh = TuningState.vehicle
    if veh == 0 or not DoesEntityExist(veh) then return end

    if tostring(sectionName or "") == "lights" then
        SetVehicleLights(veh, 2)
    else
        SetVehicleLights(veh, 0)
    end
end

local function triggerVehicleHornPreview(vehicle)
    hornState.token = hornState.token + 1
    local currentToken = hornState.token

    CreateThread(function()
        if vehicle ~= 0 and DoesEntityExist(vehicle) then
            SetHornEnabled(vehicle, false)
            Wait(50)
            SetHornEnabled(vehicle, true)
        end
    end)

    CreateThread(function()
        local maxWait = GetGameTimer() + 400
        while GetGameTimer() < maxWait do
            if hornState.token ~= currentToken then return end
            if vehicle == 0 or not DoesEntityExist(vehicle) then return end
            SetControlNormal(0, 86, 1.0)
            Wait(25)
        end

        if hornState.token ~= currentToken then return end
        StartVehicleHorn(vehicle, 4000, "HELDDOWN", true)
    end)
end

local function keepVehicleTyresFixedPreview(vehicle)
    local now = GetGameTimer()
    local isNew = (lockSpeedState.vehicle ~= vehicle)
    lockSpeedState.vehicle = vehicle
    lockSpeedState.untilAt = now + 3000

    if not isNew then return end

    lockSpeedState.token = lockSpeedState.token + 1
    local currentToken = lockSpeedState.token

    CreateThread(function()
        while lockSpeedState.token == currentToken do
            if not TuningState.active or vehicle == 0 or not DoesEntityExist(vehicle) then break end
            if GetGameTimer() >= lockSpeedState.untilAt then break end

            SetVehicleForwardSpeed(vehicle, 0.0)
            SetControlNormal(0, 71, 1.0)
            SetControlNormal(0, 72, 1.0)
            Wait(75)
        end

        if vehicle ~= 0 and DoesEntityExist(vehicle) then
            for i = 0, 7 do
                SetVehicleTyreFixed(vehicle, i)
            end
        end
    end)
end

local function findPresetColorIndex(presets, targetIdx)
    local idxNum = math.floor(tonumber(targetIdx) or 0)
    for _, preset in ipairs(presets or {}) do
        if math.floor(tonumber(preset.index) or 0) == idxNum then
            if type(preset.rgb) == "table" then
                return {
                    preset.rgb[1] or 0,
                    preset.rgb[2] or 0,
                    preset.rgb[3] or 0,
                    preset.rgb[4] or 0,
                    preset.rgb[5] or 0
                }
            end
        end
    end
    return nil
end

local function findClosestPresetIndex(presets, targetR, targetG, targetB, fallbackIdx)
    local targetIdx = math.max(0, math.floor(tonumber(fallbackIdx) or 0))
    local minDiff = math.huge

    for _, preset in ipairs(presets or {}) do
        local pIdx = math.floor(tonumber(preset.index) or targetIdx)
        if pIdx >= 0 and type(preset.rgb) == "table" then
            local r = math.floor(tonumber(preset.rgb[1]) or 0)
            local g = math.floor(tonumber(preset.rgb[2]) or 0)
            local b = math.floor(tonumber(preset.rgb[3]) or 0)
            local diff = ((r - targetR) ^ 2) + ((g - targetG) ^ 2) + ((b - targetB) ^ 2)
            if diff < minDiff then
                minDiff = diff
                targetIdx = pIdx
            end
        end
    end

    return targetIdx
end

function applyOption(opt, rawVal)
    local veh = TuningState.vehicle
    if veh == 0 or not DoesEntityExist(veh) then return false end

    local vehClass = GetVehicleClass(veh)
    if opt.kind == "mod" and opt.modType == 16 and (vehClass == 8 or vehClass == 13) then
        print("[sky_mechanicjob][tuning] apply blocked: armor tuning is disabled for bikes")
        return false
    end

    SetVehicleModKit(veh, 0)

    if opt.kind == "mod" then
        local val = rawVal
        if type(opt.customHandlingExtension) == "table" then
            local baseMax = math.floor(tonumber(opt.customHandlingExtension.baseMax) or -1)
            if val > baseMax then val = baseMax end
        end

        local isVar = GetVehicleModVariation(veh, opt.modType)
        SetVehicleMod(veh, opt.modType, val, isVar)

        if not TuningState.suppressPreviews and opt.modType == 14 and rawVal >= 0 then
            local now = GetGameTimer()
            if hornState.vehicle ~= veh then
                triggerVehicleHornPreview(veh)
                hornState.vehicle = veh
                hornState.value = rawVal
                hornState.untilAt = now + 4000
            end
        end

        opt.value = rawVal
        return true
    end

    if opt.wheelVariation then
        local currentMod = GetVehicleMod(veh, opt.modType)
        SetVehicleMod(veh, opt.modType, currentMod, rawVal == 1)
        opt.value = rawVal
        return true
    end

    if opt.modType and opt.kind == "toggle" then
        local enabled = (rawVal == 1)
        ToggleVehicleMod(veh, opt.modType, enabled)
        if opt.modType == 22 and not enabled then
            ClearVehicleXenonLightsCustomColor(veh)
            SetVehicleXenonLightsColor(veh, 0)
            XenonSync.SetCustomColor(veh, nil)
            RgbController.SetXenonBaseColor({ r = 244, g = 247, b = 255 })
            RgbController.SetXenonLastAppliedColor(244, 247, 255)
        end
        opt.value = rawVal
        return true
    end

    if opt.id == "wheel_type" then
        SetVehicleWheelType(veh, rawVal)
        opt.value = rawVal
        return true
    end

    if opt.id == "xenon_color" then
        local targetVal = math.floor(tonumber(rawVal) or 0)
        if type(opt.xenonValueToNativeIndex) == "table" then
            targetVal = math.floor(tonumber(opt.xenonValueToNativeIndex[tostring(targetVal)]) or targetVal)
        end

        RgbController.BindXenonEffectVehicle(veh)
        ToggleVehicleMod(veh, 22, true)
        SetVehicleXenonLightsColor(veh, targetVal)
        ClearVehicleXenonLightsCustomColor(veh)

        local presetRgb = findPresetColorIndex(XENON_COLOR_PRESETS or {}, targetVal)
        if presetRgb then
            RgbController.SetXenonBaseColor({ r = presetRgb[1], g = presetRgb[2], b = presetRgb[3] })
            RgbController.SetXenonLastAppliedColor(presetRgb[1], presetRgb[2], presetRgb[3])
        end

        opt.paintType = 0
        opt.customColor = presetRgb and { r = presetRgb[1], g = presetRgb[2], b = presetRgb[3] } or nil
        XenonSync.SetCustomColor(veh, nil)
        opt.value = rawVal
        return true
    end

    if opt.neonIndex ~= nil then
        SetVehicleNeonLightEnabled(veh, opt.neonIndex, rawVal == 1)
        opt.value = rawVal
        return true
    end

    if opt.id == "neon_color" then
        local preset = NEON_COLOR_PRESETS[rawVal + 1]
        if preset then
            RgbController.BindNeonEffectVehicle(veh)
            RgbController.SetNeonBaseColor({ r = preset.rgb[1], g = preset.rgb[2], b = preset.rgb[3] })
            SetVehicleNeonLightsColour(veh, preset.rgb[1], preset.rgb[2], preset.rgb[3])
            RgbController.SetNeonLastAppliedColor(preset.rgb[1], preset.rgb[2], preset.rgb[3])
            opt.paintType = 0
            opt.customColor = { r = preset.rgb[1], g = preset.rgb[2], b = preset.rgb[3] }
            opt.value = rawVal
            return true
        end
        return false
    end

    if opt.id == "neon_effect" then
        local modeVal = math.floor(tonumber(rawVal) or RgbController.NEON_EFFECT_MODES.off)
        if modeVal < opt.min then modeVal = opt.min end
        if modeVal > opt.max then modeVal = opt.max end
        RgbController.SetNeonMode(veh, modeVal)
        opt.value = modeVal
        return true
    end

    if opt.id == "neon_effect_speed" then
        local speedVal = math.floor(tonumber(rawVal) or 5)
        if speedVal < opt.min then speedVal = opt.min end
        if speedVal > opt.max then speedVal = opt.max end
        RgbController.SetNeonSpeed(veh, speedVal)
        opt.value = speedVal
        return true
    end

    if opt.id == "xenon_effect" then
        local modeVal = math.floor(tonumber(rawVal) or RgbController.XENON_EFFECT_MODES.off)
        if modeVal < opt.min then modeVal = opt.min end
        if modeVal > opt.max then modeVal = opt.max end
        RgbController.SetXenonMode(veh, modeVal)
        opt.value = modeVal
        return true
    end

    if opt.id == "xenon_effect_speed" then
        local speedVal = math.floor(tonumber(rawVal) or 5)
        if speedVal < opt.min then speedVal = opt.min end
        if speedVal > opt.max then speedVal = opt.max end
        RgbController.SetXenonSpeed(veh, speedVal)
        opt.value = speedVal
        return true
    end

    if opt.id == "tire_smoke_color" then
        if not IsToggleModOn(veh, 20) then return false end
        local preset = TIRE_SMOKE_PRESETS[rawVal + 1]
        if preset then
            SetVehicleTyreSmokeColor(veh, preset.rgb[1], preset.rgb[2], preset.rgb[3])
            if not TuningState.suppressPreviews then
                keepVehicleTyresFixedPreview(veh)
            end
            opt.paintType = 0
            opt.customColor = nil
            opt.value = rawVal
            return true
        end
        return false
    end

    if opt.id == "color_primary" then
        ClearVehicleCustomPrimaryColour(veh)
        local _, secCol = GetVehicleColours(veh)
        SetVehicleColours(veh, rawVal, secCol)
        opt.customColor = nil
        opt.paintType = GetVehicleModColor_1(veh)
        opt.value = rawVal
        return true
    end

    if opt.id == "color_secondary" then
        ClearVehicleCustomSecondaryColour(veh)
        local primCol = GetVehicleColours(veh)
        SetVehicleColours(veh, primCol, rawVal)
        opt.customColor = nil
        opt.paintType = GetVehicleModColor_2(veh)
        opt.value = rawVal
        return true
    end

    if opt.id == "color_pearlescent" then
        local _, wheelCol = GetVehicleExtraColours(veh)
        SetVehicleExtraColours(veh, rawVal, wheelCol)
        opt.value = rawVal
        return true
    end

    if opt.id == "color_wheel" then
        local pearlCol = GetVehicleExtraColours(veh)
        SetVehicleExtraColours(veh, pearlCol, rawVal)
        opt.value = rawVal
        return true
    end

    if opt.id == "color_dashboard" then
        SetVehicleDashboardColour(veh, rawVal)
        opt.value = rawVal
        return true
    end

    if opt.id == "color_interior" then
        SetVehicleInteriorColour(veh, rawVal)
        opt.value = rawVal
        return true
    end

    if opt.id == "window_tint" then
        SetVehicleWindowTint(veh, rawVal)
        opt.value = rawVal
        return true
    end

    if opt.id == "livery" then
        SetVehicleLivery(veh, rawVal)
        SetVehicleModKit(veh, 0)
        SetVehicleMod(veh, 48, rawVal, false)
        opt.value = rawVal
        return true
    end

    if opt.extraId then
        SetVehicleExtra(veh, opt.extraId, rawVal == 1 and 0 or 1)
        opt.value = rawVal
        return true
    end

    if opt.id == "plate_index" then
        SetVehicleNumberPlateTextIndex(veh, rawVal)
        opt.value = rawVal
        return true
    end

    if StanceKit.ApplyOption(veh, opt, rawVal) then
        return true
    end

    if opt.customHandlingProfileKey then
        opt.value = rawVal
        return true
    end

    if type(AntiLag) == "table" and type(AntiLag.ApplyOption) == "function" then
        if AntiLag.ApplyOption(veh, opt, rawVal) then
            return true
        end
    end

    if type(TwoStep) == "table" and type(TwoStep.ApplyOption) == "function" then
        if TwoStep.ApplyOption(veh, opt, rawVal) then
            return true
        end
    end

    return false
end

function applyCustomColorOption(opt, paintType, customColor)
    local veh = TuningState.vehicle
    if veh == 0 or not DoesEntityExist(veh) then return false end

    if opt.id ~= "color_primary" and opt.id ~= "color_secondary" and opt.id ~= "tire_smoke_color" and opt.id ~= "neon_color" and opt.id ~= "xenon_color" then
        return false
    end

    local pType = math.floor(math.max(0, math.min(5, tonumber(paintType) or 0)))
    local hasCustom = (type(customColor) == "table")

    local r = math.floor(math.max(0, math.min(255, tonumber(hasCustom and customColor.r) or 0)))
    local g = math.floor(math.max(0, math.min(255, tonumber(hasCustom and customColor.g) or 0)))
    local b = math.floor(math.max(0, math.min(255, tonumber(hasCustom and customColor.b) or 0)))

    logDebug(("[sky_mechanicjob][tuning] applyCustomColorOption request id=%s paintType=%s rgb=(%s,%s,%s)"):format(
        tostring(opt.id), tostring(pType), tostring(r), tostring(g), tostring(b)
    ))

    if opt.id == "neon_color" then
        if hasCustom then
            RgbController.BindNeonEffectVehicle(veh)
            RgbController.SetNeonBaseColor({ r = r, g = g, b = b })
            SetVehicleNeonLightsColour(veh, r, g, b)
            RgbController.SetNeonLastAppliedColor(r, g, b)
            opt.value = findClosestPresetIndex(NEON_COLOR_PRESETS or {}, r, g, b, opt.value)
            opt.customColor = { r = r, g = g, b = b }
        else
            local preset = NEON_COLOR_PRESETS[math.floor(tonumber(opt.value) or 0) + 1]
            if preset then
                RgbController.BindNeonEffectVehicle(veh)
                RgbController.SetNeonBaseColor({ r = preset.rgb[1], g = preset.rgb[2], b = preset.rgb[3] })
                SetVehicleNeonLightsColour(veh, preset.rgb[1], preset.rgb[2], preset.rgb[3])
                RgbController.SetNeonLastAppliedColor(preset.rgb[1], preset.rgb[2], preset.rgb[3])
                opt.customColor = { r = preset.rgb[1], g = preset.rgb[2], b = preset.rgb[3] }
            end
        end
        opt.paintType = 0
        logDebug(("[sky_mechanicjob][tuning] applyCustomColorOption applied id=%s paintType=%s custom=%s rgb=(%s,%s,%s)"):format(
            tostring(opt.id), tostring(opt.paintType), tostring(hasCustom),
            tostring(opt.customColor and opt.customColor.r),
            tostring(opt.customColor and opt.customColor.g),
            tostring(opt.customColor and opt.customColor.b)
        ))
        return true
    end

    if opt.id == "xenon_color" then
        RgbController.BindXenonEffectVehicle(veh)
        ToggleVehicleMod(veh, 22, true)
        if hasCustom then
            SetVehicleXenonLightsColor(veh, 255)
            SetVehicleXenonLightsCustomColor(veh, r, g, b)
            RgbController.SetXenonBaseColor({ r = r, g = g, b = b })
            RgbController.SetXenonLastAppliedColor(r, g, b)
            opt.customColor = { r = r, g = g, b = b }
            XenonSync.SetCustomColor(veh, opt.customColor)
        else
            local targetVal = math.floor(tonumber(opt.value) or 0)
            if type(opt.xenonValueToNativeIndex) == "table" then
                targetVal = math.floor(tonumber(opt.xenonValueToNativeIndex[tostring(targetVal)]) or targetVal)
            end

            local nativeIdx = findClosestPresetIndex(XENON_COLOR_PRESETS or {}, r, g, b, targetVal)
            ClearVehicleXenonLightsCustomColor(veh)
            SetVehicleXenonLightsColor(veh, nativeIdx)

            local presetRgb = findPresetColorIndex(XENON_COLOR_PRESETS or {}, nativeIdx)
            if presetRgb then
                RgbController.SetXenonBaseColor({ r = presetRgb[1], g = presetRgb[2], b = presetRgb[3] })
                RgbController.SetXenonLastAppliedColor(presetRgb[1], presetRgb[2], presetRgb[3])
                opt.customColor = { r = presetRgb[1], g = presetRgb[2], b = presetRgb[3] }
            else
                opt.customColor = nil
            end

            if type(opt.xenonNativeToValue) == "table" then
                opt.value = math.floor(tonumber(opt.xenonNativeToValue[tostring(nativeIdx)]) or targetVal)
            else
                opt.value = nativeIdx
            end
            XenonSync.SetCustomColor(veh, nil)
        end
        opt.paintType = 0
        logDebug(("[sky_mechanicjob][tuning] applyCustomColorOption applied id=%s paintType=%s custom=%s rgb=(%s,%s,%s)"):format(
            tostring(opt.id), tostring(opt.paintType), tostring(hasCustom),
            tostring(opt.customColor and opt.customColor.r),
            tostring(opt.customColor and opt.customColor.g),
            tostring(opt.customColor and opt.customColor.b)
        ))
        return true
    end

    if opt.id == "tire_smoke_color" then
        if not IsToggleModOn(veh, 20) then
            ToggleVehicleMod(veh, 20, true)
        end
        if hasCustom then
            SetVehicleTyreSmokeColor(veh, r, g, b)
        else
            local preset = TIRE_SMOKE_PRESETS[math.floor(tonumber(opt.value) or 0) + 1]
            if preset then
                SetVehicleTyreSmokeColor(veh, preset.rgb[1], preset.rgb[2], preset.rgb[3])
            end
        end
        if not TuningState.suppressPreviews then
            keepVehicleTyresFixedPreview(veh)
        end
        opt.paintType = 0
        opt.customColor = hasCustom and { r = r, g = g, b = b } or nil
        logDebug(("[sky_mechanicjob][tuning] applyCustomColorOption applied id=%s paintType=%s custom=%s rgb=(%s,%s,%s)"):format(
            tostring(opt.id), tostring(opt.paintType), tostring(hasCustom),
            tostring(opt.customColor and opt.customColor.r),
            tostring(opt.customColor and opt.customColor.g),
            tostring(opt.customColor and opt.customColor.b)
        ))
        return true
    end

    if opt.id == "color_primary" then
        local curType = GetVehicleModColor_1(veh)
        if hasCustom then
            curType = 0
        elseif curType < 0 then
            curType = math.floor(tonumber(opt.value) or 0)
        end

        ClearVehicleCustomPrimaryColour(veh)
        if hasCustom then
            local pearlCol = select(1, GetVehicleExtraColours(veh))
            SetVehicleModColor_1(veh, pType, curType, math.floor(tonumber(pearlCol) or 0))
            SetVehicleCustomPrimaryColour(veh, r, g, b)
        else
            local primCol, secCol = GetVehicleColours(veh)
            SetVehicleColours(veh, curType, secCol)
        end
    else
        local curType = GetVehicleModColor_2(veh)
        if hasCustom then
            curType = 0
        elseif curType < 0 then
            curType = math.floor(tonumber(opt.value) or 0)
        end

        ClearVehicleCustomSecondaryColour(veh)
        if hasCustom then
            SetVehicleModColor_2(veh, pType, curType)
            SetVehicleCustomSecondaryColour(veh, r, g, b)
        else
            local primCol = GetVehicleColours(veh)
            SetVehicleColours(veh, primCol, curType)
        end
    end

    opt.paintType = (opt.id == "color_primary") and GetVehicleModColor_1(veh) or GetVehicleModColor_2(veh)
    opt.customColor = hasCustom and { r = r, g = g, b = b } or nil

    logDebug(("[sky_mechanicjob][tuning] applyCustomColorOption applied id=%s paintType=%s custom=%s rgb=(%s,%s,%s)"):format(
        tostring(opt.id), tostring(opt.paintType), tostring(hasCustom),
        tostring(opt.customColor and opt.customColor.r),
        tostring(opt.customColor and opt.customColor.g),
        tostring(opt.customColor and opt.customColor.b)
    ))

    return true
end

function getNearbyVehicles(radius)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local rVal = tonumber(radius) or 8.0

    local now = GetGameTimer()
    if nearbyVehicleCache.origin and now < nearbyVehicleCache.expiresAt then
        if math.abs(nearbyVehicleCache.radius - rVal) < 0.01 and #(pedCoords - nearbyVehicleCache.origin) <= 1.5 then
            return nearbyVehicleCache.vehicles
        end
    end

    local list = {}
    local seen = {}

    for _, veh in ipairs(GetGamePool("CVehicle")) do
        if DoesEntityExist(veh) and not IsEntityDead(veh) then
            local dist = #(pedCoords - GetEntityCoords(veh))
            if dist <= rVal then
                local netId = NetworkGetNetworkIdFromEntity(veh)
                local plate = GetVehicleNumberPlateText(veh) or "UNKNOWN"
                plate = plate:gsub("^%s*(.-)%s*$", "%1")
                if plate == "" then plate = "UNKNOWN" end

                local model = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
                local keyKey = ("%s-%s"):format(plate, tostring(netId))

                if not seen[keyKey] then
                    seen[keyKey] = true
                    table.insert(list, {
                        netId = netId,
                        plate = plate,
                        model = model,
                        distance = math.floor(dist * 10 + 0.5) / 10
                    })
                end
            end
        end
    end

    table.sort(list, function(a, b)
        return (a.distance or 0) < (b.distance or 0)
    end)

    nearbyVehicleCache.radius = rVal
    nearbyVehicleCache.expiresAt = now + 400
    nearbyVehicleCache.origin = pedCoords
    nearbyVehicleCache.vehicles = list

    return list
end

function getConnectedVehiclePayload()
    local netId = math.floor(tonumber(OrderTabletState and OrderTabletState.connectedVehicleNetId) or 0)
    if netId <= 0 then
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh == 0 or not DoesEntityExist(veh) then
            local pCoords = GetEntityCoords(ped)
            veh = GetClosestVehicle(pCoords.x, pCoords.y, pCoords.z, 6.0, 0, 71)
        end
        if veh ~= 0 and DoesEntityExist(veh) then
            netId = NetworkGetNetworkIdFromEntity(veh)
            if OrderTabletState then OrderTabletState.connectedVehicleNetId = netId end
        end
    end
    if netId <= 0 then return nil end

    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh == 0 or not DoesEntityExist(veh) then
        if OrderTabletState then OrderTabletState.connectedVehicleNetId = 0 end
        return nil
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    local dist = #(pedCoords - GetEntityCoords(veh))

    local plate = GetVehicleNumberPlateText(veh) or "UNKNOWN"
    plate = plate:gsub("^%s*(.-)%s*$", "%1")
    if plate == "" then plate = "UNKNOWN" end

    return {
        netId = netId,
        plate = plate,
        model = GetDisplayNameFromVehicleModel(GetEntityModel(veh)),
        distance = math.floor(dist * 10 + 0.5) / 10
    }
end

local cachedItemCdnBase = nil

local function getItemImageBaseUrl()
    if cachedItemCdnBase ~= nil then return cachedItemCdnBase end
    local res = Sky.Cb.Trigger("sky_jobs_base:getNuiImageBases") or {}
    local base = tostring(res.itemImageBase or "https://cdn.sky-systems.net/items")
    if base == "" then base = "https://cdn.sky-systems.net/items" end

    cachedItemCdnBase = string.gsub(base, "/+$", "")
    return cachedItemCdnBase
end

local function getOptionStockValue(opt)
    if opt.kind == "mod" then return -1 end
    if opt.kind == "toggle" or opt.wheelVariation then return 0 end
    if opt.customHandlingProfileKey then return math.floor(tonumber(opt.min) or 0) end
    return nil
end

local function formatOptionValueLabel(opt)
    if opt and opt.kind == "stancer" then
        local scale = tonumber(opt.scale) or STANCER_SCALE or 100
        return ("%.2f"):format((tonumber(opt.value) or 0) / scale)
    end

    local lbl = opt and opt.labels and opt.labels[tostring(opt.value)]
    if type(lbl) == "string" and lbl ~= "" then return lbl end
    return tostring(opt.value)
end

local function isOptionStancerChanged(opt)
    if not (type(opt) == "table" and opt.kind == "stancer") then return false end
    local scale = tonumber(opt.scale) or STANCER_SCALE or 100
    local val = (tonumber(opt.value) or 0) / scale

    if opt.id == "wheel_size" or opt.id == "wheel_width" then
        return math.abs(val - 1.0) > 0.001
    end
    return math.abs(val) > 0.001
end

local function captureAppliedVehicleTuningEntries(vehicle)
    local curVeh = TuningState.vehicle
    local curOpts = TuningState.options
    local curMap = TuningState.optionMap
    local curSecs = TuningState.sections
    local curSupp = TuningState.suppressPreviews

    TuningState.vehicle = vehicle
    TuningState.suppressPreviews = true
    buildOptionsForVehicle(vehicle)

    local entries = {}
    local wheelTypeVal = tonumber(TuningState.optionMap.wheel_type and TuningState.optionMap.wheel_type.value)
    local stanceValues = {}
    local stanceLabels = {}

    for _, opt in ipairs(TuningState.options or {}) do
        if isOptionStancerChanged(opt) then
            stanceValues[opt.id] = opt.value
            table.insert(stanceLabels, opt.label or opt.id)
        end

        local stockVal = getOptionStockValue(opt)
        local curVal = tonumber(opt.value)

        if stockVal ~= nil and curVal ~= nil and curVal ~= stockVal then
            local wType = nil
            if (opt.id == "mod_23" or opt.id == "mod_24") and wheelTypeVal then
                wType = wheelTypeVal
            end

            table.insert(entries, {
                id = opt.id,
                value = opt.value,
                stockValue = stockVal,
                wheelType = wType,
                label = opt.label or opt.id,
                valueLabel = formatOptionValueLabel(opt),
                section = opt.section or "bodywork"
            })
        end
    end

    if next(stanceValues) then
        local labelStr = #stanceLabels > 0 and table.concat(stanceLabels, ", ") or getNuiLocale("basket.value.stancer_bundle", "Custom stance setup")
        table.insert(entries, {
            id = "stancer_bundle",
            value = stanceValues,
            label = getNuiLocale("section.stancer", "Stancer"),
            valueLabel = labelStr,
            section = "stancer"
        })
    end

    TuningState.vehicle = curVeh
    TuningState.options = curOpts
    TuningState.optionMap = curMap
    TuningState.sections = curSecs
    TuningState.suppressPreviews = curSupp

    return entries
end

function getAppliedTuningRemovalPayload(vehicle, plateStr)
    local res = Sky.Cb.Trigger("sky_mechanicjob:tuning:getRemovalPreview", {
        plate = plateStr,
        entries = captureAppliedVehicleTuningEntries(vehicle)
    }) or {}

    if type(res) ~= "table" or res.success ~= true then
        return { entries = {}, itemImageBase = getItemImageBaseUrl() }
    end

    return {
        entries = (type(res.data) == "table" and res.data.entries) or {},
        itemImageBase = getItemImageBaseUrl()
    }
end

RegisterNUICallback("tuningRemoval:listApplied", function(data, cb)
    local veh = NetworkGetEntityFromNetworkId(math.floor(tonumber(OrderTabletState and OrderTabletState.connectedVehicleNetId) or 0))
    if veh == 0 or not DoesEntityExist(veh) then
        cb({ success = false, error = "no_vehicle" })
        return
    end

    local plateStr = sanitizePlate(GetVehicleNumberPlateText(veh))
    if plateStr == "" then
        cb({ success = false, error = "no_vehicle" })
        return
    end

    cb({ success = true, data = getAppliedTuningRemovalPayload(veh, plateStr) })
end)

RegisterNUICallback("tuningRemoval:remove", function(data, cb)
    if OrderInstallState.active then
        cb({ success = false, error = "install_busy" })
        return
    end

    local veh = NetworkGetEntityFromNetworkId(math.floor(tonumber(OrderTabletState and OrderTabletState.connectedVehicleNetId) or 0))
    if veh == 0 or not DoesEntityExist(veh) then
        cb({ success = false, error = "no_vehicle" })
        return
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    if #(pedCoords - GetEntityCoords(veh)) > 15.0 then
        cb({ success = false, error = "vehicle_too_far" })
        return
    end

    if isSelfServiceTuningPointRequiredForAction("remove") and not isNearSelfServiceTuningPoint() then
        notifySelfServiceTuningPointRequired()
        cb({ success = false, error = "not_near_self_service_tuning" })
        return
    end

    local targetId = tostring((data and data.id) or "")
    if targetId == "" then
        cb({ success = false, error = "invalid_payload" })
        return
    end

    local curVeh = TuningState.vehicle
    local curOpts = TuningState.options
    local curMap = TuningState.optionMap
    local curSecs = TuningState.sections
    local curSupp = TuningState.suppressPreviews

    TuningState.vehicle = veh
    TuningState.suppressPreviews = true
    if type(StanceKit.EnsureDefaultForVehicle) == "function" then
        StanceKit.EnsureDefaultForVehicle(veh)
    end
    buildOptionsForVehicle(veh)

    if targetId == "stancer_bundle" then
        local stanceVal = type(data and data.value) == "table" and data.value or StanceKit.BuildPersistedState(veh)
        if type(stanceVal) ~= "table" or not next(stanceVal) then
            TuningState.vehicle = curVeh
            TuningState.options = curOpts
            TuningState.optionMap = curMap
            TuningState.sections = curSecs
            TuningState.suppressPreviews = curSupp
            cb({ success = false, error = "not_removable" })
            return
        end

        local plateStr = sanitizePlate(GetVehicleNumberPlateText(veh))
        local sectionLbl = getNuiLocale("section.stancer", "Stancer")
        local valueLbl = getNuiLocale("basket.value.stancer_bundle", "Custom stance setup")

        local prepRes = Sky.Cb.Trigger("sky_mechanicjob:tuning:prepareRemoval", {
            plate = plateStr,
            id = targetId,
            value = stanceVal,
            label = sectionLbl,
            valueLabel = valueLbl,
            section = "stancer"
        }) or {}

        if type(prepRes) ~= "table" or prepRes.success ~= true then
            TuningState.vehicle = curVeh
            TuningState.options = curOpts
            TuningState.optionMap = curMap
            TuningState.sections = curSecs
            TuningState.suppressPreviews = curSupp
            if type(prepRes) == "table" and prepRes.error == "not_near_self_service_tuning" then
                notifySelfServiceTuningPointRequired()
            end
            cb({ success = false, error = (type(prepRes) == "table" and prepRes.error) or "prepare_failed" })
            return
        end

        local prepData = prepRes.data or {}
        local reqItem = tostring(prepData.requiredItem or requiredItemByOptionId(targetId))

        local partPayload = {
            id = targetId,
            value = "__stock__",
            label = sectionLbl,
            requiredItem = reqItem,
            section = "stancer"
        }

        TuningState.vehicle = curVeh
        TuningState.options = curOpts
        TuningState.optionMap = curMap
        TuningState.sections = curSecs
        TuningState.suppressPreviews = curSupp

        clearOrderInstallState()
        OrderInstallState.active = true
        OrderInstallState.finalizing = false
        OrderInstallState.orderId = 0
        OrderInstallState.partIndex = 0
        OrderInstallState.part = partPayload
        OrderInstallState.requiredItem = reqItem
        OrderInstallState.removeRequiredItemAfterUse = false
        OrderInstallState.installFlow = ""
        OrderInstallState.repairMode = false
        OrderInstallState.repairPart = ""
        OrderInstallState.repairPlate = ""
        OrderInstallState.tuningRemovalMode = true
        OrderInstallState.tuningRemovalPlate = plateStr
        OrderInstallState.tuningRemovalValue = stanceVal
        OrderInstallState.tuningRemovalWheelType = nil
        OrderInstallState.tuningRemovalValueLabel = valueLbl
        OrderInstallState.tuningRemovalSection = "stancer"
        OrderInstallState.vehicleNetId = NetworkGetNetworkIdFromEntity(veh)
        OrderInstallState.vehicle = veh
        OrderInstallState.simpleChecklistVisible = false
        OrderInstallState.simpleStep = "idle"
        OrderTabletState.connectedVehicleNetId = NetworkGetNetworkIdFromEntity(veh)

        startSimpleInstallState()
        releaseOrderHeldProp()
        notify(("%s: %s. %s"):format(
            getNuiLocale("tablet.tuningRemoval.removing", "Removing..."),
            sectionLbl,
            getNuiLocale("tablet.orders.simple_checklist.hint", "Use radial menu and complete the install checklist.")
        ), "info")

        releaseNuiFocus()
        cb({ success = true, data = { requiredItem = OrderInstallState.requiredItem } })
        return
    end

    local opt = TuningState.optionMap[targetId]
    if not opt then
        TuningState.vehicle = curVeh
        TuningState.options = curOpts
        TuningState.optionMap = curMap
        TuningState.sections = curSecs
        TuningState.suppressPreviews = curSupp
        cb({ success = false, error = "invalid_option" })
        return
    end

    local stockVal = getOptionStockValue(opt)
    if stockVal == nil then
        TuningState.vehicle = curVeh
        TuningState.options = curOpts
        TuningState.optionMap = curMap
        TuningState.sections = curSecs
        TuningState.suppressPreviews = curSupp
        cb({ success = false, error = "not_removable" })
        return
    end

    local curVal = opt.value
    local wType = tonumber(data and data.wheelType) or tonumber(TuningState.optionMap.wheel_type and TuningState.optionMap.wheel_type.value)
    local plateStr = sanitizePlate(GetVehicleNumberPlateText(veh))

    local prepRes = Sky.Cb.Trigger("sky_mechanicjob:tuning:prepareRemoval", {
        plate = plateStr,
        id = opt.id,
        value = curVal,
        wheelType = wType,
        label = opt.label or opt.id,
        valueLabel = formatOptionValueLabel(opt),
        section = opt.section or "bodywork"
    }) or {}

    if type(prepRes) ~= "table" or prepRes.success ~= true then
        TuningState.vehicle = curVeh
        TuningState.options = curOpts
        TuningState.optionMap = curMap
        TuningState.sections = curSecs
        TuningState.suppressPreviews = curSupp
        if type(prepRes) == "table" and prepRes.error == "not_near_self_service_tuning" then
            notifySelfServiceTuningPointRequired()
        end
        cb({ success = false, error = (type(prepRes) == "table" and prepRes.error) or "prepare_failed" })
        return
    end

    local prepData = prepRes.data or {}
    local reqItem = tostring(prepData.requiredItem or requiredItemByOptionId(opt.id))

    local partPayload = {
        id = opt.id,
        value = stockVal,
        wheelType = wType,
        label = opt.label or opt.id,
        requiredItem = reqItem,
        section = opt.section or "bodywork"
    }

    TuningState.vehicle = curVeh
    TuningState.options = curOpts
    TuningState.optionMap = curMap
    TuningState.sections = curSecs
    TuningState.suppressPreviews = curSupp

    clearOrderInstallState()
    OrderInstallState.active = true
    OrderInstallState.finalizing = false
    OrderInstallState.orderId = 0
    OrderInstallState.partIndex = 0
    OrderInstallState.part = partPayload
    OrderInstallState.requiredItem = reqItem
    OrderInstallState.removeRequiredItemAfterUse = false
    OrderInstallState.installFlow = ""
    OrderInstallState.repairMode = false
    OrderInstallState.repairPart = ""
    OrderInstallState.repairPlate = ""
    OrderInstallState.tuningRemovalMode = true
    OrderInstallState.tuningRemovalPlate = plateStr
    OrderInstallState.tuningRemovalValue = curVal
    OrderInstallState.tuningRemovalWheelType = wType
    OrderInstallState.tuningRemovalValueLabel = formatOptionValueLabel(opt)
    OrderInstallState.tuningRemovalSection = opt.section or "bodywork"
    OrderInstallState.vehicleNetId = NetworkGetNetworkIdFromEntity(veh)
    OrderInstallState.vehicle = veh
    OrderInstallState.simpleChecklistVisible = false
    OrderInstallState.simpleStep = "idle"
    OrderTabletState.connectedVehicleNetId = NetworkGetNetworkIdFromEntity(veh)

    if isWheelOrderPart(partPayload, OrderInstallState.requiredItem) or isBrakeWheelWorkflowPart(partPayload, OrderInstallState.requiredItem) or isSuspensionWheelWorkflowPart(partPayload, OrderInstallState.requiredItem) then
        startWheelInstallState(isBrakeWheelWorkflowPart(partPayload, OrderInstallState.requiredItem), isSuspensionWheelWorkflowPart(partPayload, OrderInstallState.requiredItem))
        notify(("%s: %s. %s"):format(
            getNuiLocale("tablet.tuningRemoval.removing", "Removing..."),
            tostring(partPayload.label or opt.id),
            getNuiLocale("tablet.orders.wheel_checklist.hint", "Use radial menu and follow the wheel checklist.")
        ), "info")
    else
        startSimpleInstallState()
        releaseOrderHeldProp()
        notify(("%s: %s. %s"):format(
            getNuiLocale("tablet.tuningRemoval.removing", "Removing..."),
            tostring(partPayload.label or opt.id),
            getNuiLocale("tablet.orders.simple_checklist.hint", "Use radial menu and complete the install checklist.")
        ), "info")
    end

    releaseNuiFocus()
    cb({ success = true, data = { requiredItem = OrderInstallState.requiredItem } })
end)

function applyOrderPartToVehicle(vehicle, partPayload)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][orders] apply failed: vehicle is missing")
        return false
    end

    if type(partPayload) ~= "table" then
        print("[sky_mechanicjob][orders] apply failed: part payload is invalid")
        return false
    end

    local optionId = tostring(partPayload.id or "")
    if optionId == "" then
        print("[sky_mechanicjob][orders] apply failed: part id is missing")
        return false
    end

    if StanceKit.IsVehicleMotorbike(vehicle) then
        if optionId == "stancer_bundle" or optionId == "wheel_size" or optionId == "wheel_width" or optionId:match("^stancer_") then
            print(("[sky_mechanicjob][orders] apply skipped: stance option '%s' is disabled for motorbikes"):format(optionId))
            return false
        end
    end

    if optionId == "stancer_bundle" and partPayload.value == "__stock__" then
        return (StanceKit.ResetToDefault(vehicle, true) == true)
    end

    local curVeh = TuningState.vehicle
    local curOpts = TuningState.options
    local curMap = TuningState.optionMap
    local curSecs = TuningState.sections
    local curSupp = TuningState.suppressPreviews

    TuningState.vehicle = vehicle
    buildOptionsForVehicle(vehicle)
    TuningState.suppressPreviews = true

    if optionId == "stancer_bundle" then
        local bundleVals = type(partPayload.value) == "table" and partPayload.value or nil
        if not bundleVals or not next(bundleVals) then
            print("[sky_mechanicjob][orders] apply failed: stancer_bundle has no values")
            TuningState.vehicle = curVeh
            TuningState.options = curOpts
            TuningState.optionMap = curMap
            TuningState.sections = curSecs
            TuningState.suppressPreviews = curSupp
            return false
        end

        local countApplied = 0
        local allApplied = true

        for subId, rawSubVal in pairs(bundleVals) do
            local opt = TuningState.optionMap[subId]
            if not opt or opt.kind ~= "stancer" then
                print(("[sky_mechanicjob][orders] apply failed: stancer option '%s' not available"):format(tostring(subId)))
                allApplied = false
                break
            end

            local valNum = tonumber(rawSubVal) or tonumber(opt.value) or tonumber(opt.min) or 0
            if valNum < opt.min then valNum = opt.min end
            if valNum > opt.max then valNum = opt.max end

            if not applyOption(opt, valNum) then
                print(("[sky_mechanicjob][orders] apply failed: stancer option '%s' value could not be applied"):format(tostring(subId)))
                allApplied = false
                break
            end
            countApplied = countApplied + 1
        end

        TuningState.vehicle = curVeh
        TuningState.options = curOpts
        TuningState.optionMap = curMap
        TuningState.sections = curSecs
        TuningState.suppressPreviews = curSupp

        return allApplied and (countApplied > 0)
    end

    local opt = TuningState.optionMap[optionId]
    if not opt then
        print(("[sky_mechanicjob][orders] apply failed: option '%s' not available for this vehicle"):format(optionId))
        TuningState.vehicle = curVeh
        TuningState.options = curOpts
        TuningState.optionMap = curMap
        TuningState.sections = curSecs
        TuningState.suppressPreviews = curSupp
        return false
    end

    if optionId == "mod_23" or optionId == "mod_24" then
        local wType = tonumber(partPayload.wheelType)
        if wType ~= nil then
            local wheelTypeOpt = TuningState.optionMap.wheel_type
            if wheelTypeOpt then
                local wtVal = math.floor(wType)
                if wtVal < wheelTypeOpt.min then wtVal = wheelTypeOpt.min end
                if wtVal > wheelTypeOpt.max then wtVal = wheelTypeOpt.max end

                if not applyOption(wheelTypeOpt, wtVal) then
                    print(("[sky_mechanicjob][orders] apply failed: wheel_type could not be applied (value=%s)"):format(tostring(wtVal)))
                    TuningState.vehicle = curVeh
                    TuningState.options = curOpts
                    TuningState.optionMap = curMap
                    TuningState.sections = curSecs
                    TuningState.suppressPreviews = curSupp
                    return false
                end
            else
                print(("[sky_mechanicjob][orders] apply warning: wheel_type option missing for %s (requested=%s)"):format(optionId, tostring(wType)))
            end
        end
    end

    local targetVal = tonumber(partPayload.value) or tonumber(opt.value) or tonumber(opt.min) or 0
    if opt.kind ~= "stancer" then
        targetVal = math.floor(targetVal)
    end

    if targetVal < opt.min then targetVal = opt.min end
    if targetVal > opt.max then targetVal = opt.max end

    local ok = applyOption(opt, targetVal)
    if ok then
        if opt.customHandlingProfileKey or type(opt.customHandlingExtension) == "table" then
            ok = CustomTuning.ApplyProfiles(vehicle)
        end
    end

    if ok and (type(partPayload.customColor) == "table") and opt.supportsCustom == true then
        ok = applyCustomColorOption(opt, partPayload.paintType, partPayload.customColor)
    end

    if ok and (optionId == "antilag_enabled" or optionId == "twostep_enabled") then
        saveTuningForVehicle(vehicle)
    end

    TuningState.vehicle = curVeh
    TuningState.options = curOpts
    TuningState.optionMap = curMap
    TuningState.sections = curSecs
    TuningState.suppressPreviews = curSupp

    return ok
end

function runStanceWheelInstallAnim(vehicle)
    return runLiftOverheadWorkAnim(vehicle, getNuiLocale("tablet.orders.stance_checklist.adjusting", "Adjusting wheel joint"))
end

function startDirectStanceInstall(vehicle, stancePart)
    if vehicle == 0 or not DoesEntityExist(vehicle) or type(stancePart) ~= "table" then
        return false
    end

    clearOrderInstallState()
    OrderInstallState.active = true
    OrderInstallState.part = stancePart
    OrderInstallState.requiredItem = "stance_kit"
    OrderInstallState.installFlow = "stance"
    OrderInstallState.directStanceInstall = true
    OrderInstallState.vehicle = vehicle
    OrderInstallState.vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    OrderInstallState.simpleStep = "idle"
    OrderInstallState.stanceCompletedWheels = {}
    OrderTabletState.connectedVehicleNetId = OrderInstallState.vehicleNetId

    startSimpleInstallState()
    notify(getNuiLocale("tablet.orders.stance_checklist.started", "Stance setup ready. Move the vehicle onto a workshop lift and follow the checklist."), "info")

    return true
end

function completeActiveOrderInstall(vehicle, force)
    local isRepair = (OrderInstallState.repairMode == true)
    local flowType = resolveSimpleInstallFlow()

    local isOil = (flowType == "oil_change")
    local isFluid = (flowType == "fluid_refill")
    local isHood = (flowType == "hood_install")

    local actionType = OrderInstallState.tuningRemovalMode and "remove" or "install"

    if not OrderInstallState.repairMode and not OrderInstallState.directStanceInstall then
        if isSelfServiceTuningPointRequiredForAction(actionType) and not isNearSelfServiceTuningPoint() then
            notifySelfServiceTuningPointRequired()
            return false, {
                key = "radial.errors.generic",
                fallback = (tuningLocales and tuningLocales.SelfServiceTuningPointRequired) or "Move closer to a self-service tuning point to install or remove tuning."
            }
        end
    end

    if not force then
        if isRepaintOrderPart(OrderInstallState.part, OrderInstallState.requiredItem) then
            local mgOk, mgErr = runTuningMinigame("spray_paint", vehicle, OrderInstallState.part)
            if not mgOk then
                local msg = type(mgErr) == "table" and (mgErr.fallback or mgErr.key or "Repaint minigame failed.") or tostring(mgErr)
                local msgType = type(mgErr) == "table" and mgErr.messageType or "error"
                notify(msg, msgType)
                return false, mgErr
            end
        end

        if isSimpleBodyworkOrderPart(OrderInstallState.part, OrderInstallState.requiredItem) and not isHood then
            if isArmorOrderPart(OrderInstallState.part, OrderInstallState.requiredItem) then
                if OrderInstallState.simpleStep ~= "weld" and OrderInstallState.simpleStep ~= "complete" then
                    print(("[sky_mechanicjob][orders][armor] install blocked: invalid simple step '%s'"):format(tostring(OrderInstallState.simpleStep)))
                    return false, {
                        key = "radial.errors.generic",
                        fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first."
                    }
                end
            end

            local weldOk, weldErr = runSimpleBodyworkWeldingInstallAnim(vehicle, OrderInstallState.part)
            if not weldOk then
                local msg = type(weldErr) == "table" and (weldErr.fallback or weldErr.key or "Failed to apply this part on the vehicle.") or tostring(weldErr)
                local msgType = type(weldErr) == "table" and weldErr.messageType or "error"
                notify(msg, msgType)
                return false, weldErr
            end
        elseif isHood then
            local hoodOk, hoodErr = runSimpleHoodInstallAnim(vehicle, OrderInstallState.part)
            if not hoodOk then
                local msg = type(hoodErr) == "table" and (hoodErr.fallback or hoodErr.key or "Failed to apply this part on the vehicle.") or tostring(hoodErr)
                local msgType = type(hoodErr) == "table" and hoodErr.messageType or "error"
                notify(msg, msgType)
                return false, hoodErr
            end
        end

        if not isRepair then
            if not applyOrderPartToVehicle(vehicle, OrderInstallState.part) then
                local failMsg = getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle.")
                notify(failMsg, "error")
                clearOrderInstallState()
                return false, { key = "radial.errors.generic", fallback = failMsg }
            end
        end

        if not isRepair and isArmorOrderPart(OrderInstallState.part, OrderInstallState.requiredItem) then
            local armorOk, armorErr = restoreArmorPanelAfterInstall(vehicle, OrderInstallState.part)
            if not armorOk then
                local msg = type(armorErr) == "table" and (armorErr.fallback or armorErr.key or "Failed to apply this part on the vehicle.") or tostring(armorErr)
                local msgType = type(armorErr) == "table" and armorErr.messageType or "error"
                notify(msg, msgType)
                return false, armorErr
            end
        end

        if isHood or isOil or isFluid then
            if not IsVehicleDoorDamaged(vehicle, 4) then
                SetVehicleDoorShut(vehicle, 4, false)
            end
        end
    end

    if OrderInstallState.directStanceInstall then
        saveTuningForVehicle(vehicle)
        notify(getNuiLocale("tablet.orders.stance_checklist.complete", "Stance installation completed."), "success")
        clearOrderInstallState()
        return true
    end

    OrderInstallState.finalizing = true
    local eventName = "sky_mechanicjob:orders:completeInstall"
    local payload = { orderId = OrderInstallState.orderId, partIndex = OrderInstallState.partIndex }

    local connVeh = getConnectedVehiclePayload()
    if connVeh and connVeh.plate then
        payload.plate = connVeh.plate
    end

    if OrderInstallState.tuningRemovalMode then
        eventName = "sky_mechanicjob:tuning:completeRemoval"
        payload = {
            plate = OrderInstallState.tuningRemovalPlate,
            id = OrderInstallState.part and OrderInstallState.part.id or "",
            value = OrderInstallState.tuningRemovalValue,
            wheelType = OrderInstallState.tuningRemovalWheelType,
            label = OrderInstallState.part and OrderInstallState.part.label or "Tuning Removal",
            valueLabel = OrderInstallState.tuningRemovalValueLabel,
            section = OrderInstallState.tuningRemovalSection,
            vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
        }
    elseif OrderInstallState.repairMode then
        eventName = "sky_mechanicjob:wear:completeRepairInstall"
        payload = {
            plate = OrderInstallState.repairPlate,
            part = OrderInstallState.repairPart,
            requiredItem = OrderInstallState.requiredItem,
            removeRequiredItemAfterUse = (OrderInstallState.removeRequiredItemAfterUse == true),
            vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
        }
    end

    local res = Sky.Cb.Trigger(eventName, payload) or {}
    if type(res) == "table" and res.success == true then
        if OrderInstallState.tuningRemovalMode then
            notify(getNuiLocale("tablet.tuningRemoval.removeSuccess", "Tuning removed and item returned."), "success")
        elseif OrderInstallState.repairMode then
            notify(getNuiLocale("tablet.diagnostics.repairSuccess", "Part repaired successfully."), "success")
        else
            if res.data and res.data.completed then
                notify(getNuiLocale("tablet.orders.order_completed", "Order completed successfully."), "success")
            else
                notify(getNuiLocale("tablet.orders.part_installed", "Part installed successfully."), "success")
            end
        end
    else
        if type(res) == "table" and res.error == "missing_item" then
            local reqItem = tostring(res.requiredItem or OrderInstallState.requiredItem or DEFAULT_PART_ITEM)
            notify(("%s: %s"):format(
                getNuiLocale("tablet.orders.missing_item", "Missing required item"),
                getNuiLocale(("tablet.orders.items.%s"):format(reqItem), reqItem)
            ), "error")
        else
            notify(getNuiLocale("tablet.orders.install_finalize_failed", "Part was applied but order update failed."), "error")
        end
    end

    saveTuningForVehicle(vehicle)
    if TuningState.active and TuningState.vehicle == vehicle and DoesEntityExist(vehicle) then
        TuningState.snapshotProps = Sky.Vehicle.new(vehicle):GetVehicleProperties()
        TuningState.antiLagSnapshot = AntiLag.GetPersistedState(vehicle)
        TuningState.twoStepSnapshot = TwoStep.GetPersistedState(vehicle)
    end

    clearOrderInstallState()
    return true
end

function getActiveOrderInstallVehicle()
    local netId = OrderInstallState.vehicleNetId or 0
    if netId == 0 then return nil end

    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh == 0 or not DoesEntityExist(veh) then
        local errFallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.")
        return nil, { key = "radial.errors.generic", fallback = errFallback }
    end

    return veh
end

function ensureWheelOrderStep(actionId)
    if not WheelOrderInstallState.active then
        if actionId == "attach_wheel" then
            logDebug("[sky_mechanicjob][wheel_attach][check] WheelOrderInstallState.active is false")
        end
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.WheelInstallNotActive) or "Wheel actions are only available during a wheel order install."
        }
    end

    local expectedId = nextWheelInstallActionId()
    if actionId ~= expectedId then
        if actionId == "attach_wheel" then
            logDebug(("[sky_mechanicjob][wheel_attach][check] wrong step (expected=%s got=%s currentStep=%s)"):format(
                tostring(expectedId), tostring(actionId), tostring(WheelOrderInstallState.step)
            ))
        end
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.WheelInstallWrongStep) or "Complete the current wheel-change step first."
        }
    end

    local veh, vehErr = getActiveOrderInstallVehicle()
    if not veh then
        if actionId == "attach_wheel" then
            logDebug("[sky_mechanicjob][wheel_attach][check] active order vehicle missing")
        end
        clearOrderInstallState()
        return false, vehErr
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    local vehCoords = GetEntityCoords(veh)

    if #(pedCoords - vehCoords) > DETACH_WHEEL_MAX_VEHICLE_DISTANCE then
        if actionId == "attach_wheel" then
            logDebug(("[sky_mechanicjob][wheel_attach][check] too far from vehicle (distance=%.2f max=%.2f)"):format(
                #(pedCoords - vehCoords), DETACH_WHEEL_MAX_VEHICLE_DISTANCE
            ))
        end
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.WheelInstallTooFar) or "Move closer to the connected order vehicle."
        }
    end

    return true, nil, veh
end

function ensureRepaintOrderStep(actionId)
    if not RepaintOrderInstallState.active then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.RepaintInstallNotActive) or "Repaint actions are only available during a repaint install."
        }
    end

    local expectedId = nextRepaintInstallActionId()
    if actionId ~= expectedId then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.RepaintInstallWrongStep) or "Complete the current repaint step first."
        }
    end

    local veh, vehErr = getActiveOrderInstallVehicle()
    if not veh then
        clearOrderInstallState()
        return false, vehErr
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    if #(pedCoords - GetEntityCoords(veh)) > DETACH_WHEEL_MAX_VEHICLE_DISTANCE then
        return false, {
            key = "radial.errors.generic",
            fallback = (tuningLocales and tuningLocales.RepaintInstallTooFar) or "Move closer to the connected order vehicle."
        }
    end

    return true, nil, veh
end

function openTuning(vehicle, isAdmin, mode, societyJob, isInstant, isSelfService)
    if TuningState.active then
        notify((tuningLocales and tuningLocales.Busy) or "Tuning menu is already open.", "error")
        return
    end

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        notify((tuningLocales and tuningLocales.VehicleInvalid) or "Unable to tune this vehicle.", "error")
        return
    end

    local modeType = tostring(mode or "full")
    if modeType ~= "full" and modeType ~= "rgb_controller" and modeType ~= "stancing" then
        modeType = "full"
    end

    if type(StanceKit.EnsureDefaultForVehicle) == "function" then
        StanceKit.EnsureDefaultForVehicle(vehicle)
    end

    TuningState.active = true
    TuningState.adminMode = (isAdmin == true)
    TuningState.instantMode = (isInstant == true)
    TuningState.selfServiceMode = (isSelfService == true)
    TuningState.mode = modeType
    TuningState.persistChangesOnClose = false
    TuningState.skipRestoreOnClose = false
    TuningState.vehicle = vehicle
    TuningState.societyJob = (type(societyJob) == "string") and societyJob or nil

    local priceCtx = ResolveSelfServicePricingContext(TuningState.societyJob, TuningState.selfServiceMode)
    TuningState.hidePricesForPublicSelfService = (priceCtx.hidePrices == true)
    TuningState.pricingProfileJob = priceCtx.profileJob
    RefreshTuningCostProfile(TuningState.pricingProfileJob)

    TuningState.snapshotProps = Sky.Vehicle.new(vehicle):GetVehicleProperties()
    TuningState.xenonCustomStateSnapshot = getXenonCustomState(vehicle)
    TuningState.stanceSnapshot = StanceKit.BuildPersistedState(vehicle)
    TuningState.stanceSnapshotPlate = Sky.Math.Trim(GetVehicleNumberPlateText(vehicle))
    TuningState.stanceDirty = false

    TuningState.antiLagSnapshot = AntiLag.GetPersistedState(vehicle)
    TuningState.twoStepSnapshot = TwoStep.GetPersistedState(vehicle)

    if modeType == "rgb_controller" then
        RgbController.BindNeonEffectVehicle(vehicle)
        RgbController.SetNeonBaseColor(RgbController.CaptureVehicleNeonColor(vehicle))
        RgbController.BindXenonEffectVehicle(vehicle)
        RgbController.SetXenonBaseColor(RgbController.CaptureVehicleXenonColor(vehicle))
    end

    buildOptionsForVehicle(vehicle)
    CustomTuning.CaptureSessionState(vehicle)
    captureOptionBaselines()

    setNuiFocusState(true)
    if refreshMileageHudVisibility then
        refreshMileageHudVisibility()
    end

    sendUi("open", {
        screen = "tuning",
        lang = Sky.Config and Sky.Config.locale or "en",
        locales = nuiLocales,
        tuning = buildUiPayload()
    })
end

function openFromCurrentVehicle(isAdmin, mode, isSelfService, societyJob, isInstant, isDriverCheck)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or not DoesEntityExist(veh) then
        local pCoords = GetEntityCoords(ped)
        veh = GetClosestVehicle(pCoords.x, pCoords.y, pCoords.z, 6.0, 0, 71)
    end

    if veh == 0 or not DoesEntityExist(veh) then
        notify((tuningLocales and tuningLocales.NotInVehicle) or "You need to be in or near a vehicle to use this.", "error")
        return
    end

    openTuning(veh, isAdmin == true, mode, societyJob, isInstant == true, isSelfService == true)
end

RegisterNetEvent("sky_mechanicjob:tuning:openAdmin", function()
    openFromCurrentVehicle(true)
end)

RegisterNetEvent("sky_mechanicjob:tuning:openRgbController", function()
    openFromCurrentVehicle(true, "rgb_controller")
end)

RegisterNetEvent("sky_mechanicjob:tuning:openStancing", function()
    openFromCurrentVehicle(true, "stancing")
end)

RegisterCommand("tuning", function()
    openFromCurrentVehicle(true)
end, false)

RegisterCommand("admintuning", function()
    openFromCurrentVehicle(true)
end, false)

RegisterCommand("stancing", function()
    openFromCurrentVehicle(true, "stancing")
end, false)

RegisterCommand("rgb", function()
    openFromCurrentVehicle(true, "rgb_controller")
end, false)

RegisterCommand("diagnostics", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or not DoesEntityExist(veh) then
        local pCoords = GetEntityCoords(ped)
        veh = GetClosestVehicle(pCoords.x, pCoords.y, pCoords.z, 6.0, 0, 71)
    end
    if veh ~= 0 and DoesEntityExist(veh) then
        if OrderTabletState then
            OrderTabletState.connectedVehicleNetId = NetworkGetNetworkIdFromEntity(veh)
        end
    end
    TriggerEvent("sky_mechanicjob:tablet:openApp", { key = "diagnostics", route = "/tablet/mechanic-diagnostics" })
end, false)

RegisterCommand("orders", function()
    TriggerEvent("sky_mechanicjob:tablet:openApp", { key = "orders", route = "/tablet/mechanic-orders" })
end, false)

RegisterCommand("partsshop", function()
    TriggerEvent("sky_mechanicjob:tablet:openApp", { key = "parts_shop", route = "/tablet/mechanic-parts-shop" })
end, false)

RegisterCommand("dyno", function()
    TriggerEvent("sky_mechanicjob:tablet:openApp", { key = "dyno", route = "/tablet/mechanic-dyno" })
end, false)

RegisterCommand("vehicleregistry", function()
    TriggerEvent("sky_mechanicjob:tablet:openApp", { key = "vehicles", route = "/tablet/mechanic-vehicles" })
end, false)

RegisterNUICallback("uiReady", function(data, cb)
    if TuningState.active and TuningState.vehicle and DoesEntityExist(TuningState.vehicle) then
        sendUi("open", {
            screen = "tuning",
            lang = Sky.Config and Sky.Config.locale or "en",
            locales = nuiLocales,
            tuning = buildUiPayload()
        })
    else
        TuningState.active = false
    end
    cb({ success = true })
end)

RegisterNUICallback("close", function(data, cb)
    if TuningState.active then
        setTuningClosed(false)
    else
        releaseNuiFocus()
        TriggerEvent("sky_jobs_base:tablet:setOpenState", false)
        TriggerEvent("sky_jobs:nuiClosed")
    end
    cb({ success = true })
end)

RegisterNUICallback("tablet:setOpenState", function(data, cb)
    local openState = data and data.open == true
    local appKey = data and (data.appKey or data.key)
    local route = data and data.route

    TriggerEvent("sky_jobs_base:tablet:setOpenState", openState, { appKey = appKey, route = route })
    cb({ success = true })
end)

RegisterNUICallback("tablet:returnHome", function(data, cb)
    TuningState.active = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    sendUi("close")
    TriggerEvent("sky_jobs_base:tablet:setOpenState", false)
    cb({ success = true })
end)

RegisterNUICallback("orders:getAll", function(data, cb)
    local pageNum = math.floor(tonumber(data and data.page) or 1)
    local pageSizeNum = math.floor(tonumber(data and data.pageSize) or 20)
    local searchStr = tostring((data and data.search) or "")

    local res = Sky.Cb.Trigger("sky_mechanicjob:orders:getAll", {
        page = pageNum,
        pageSize = pageSizeNum,
        search = searchStr
    }) or {}

    if type(res) == "table" and res.success == true then
        local dataTable = res.data or {}
        dataTable.itemImageBase = getItemImageBaseUrl()
        res.data = dataTable
        cb(res)
        return
    end

    cb({ success = false, error = (type(res) == "table" and res.error) or "load_failed" })
end)

RegisterNUICallback("orders:refund", function(data, cb)
    local orderId = math.floor(tonumber(data and (data.orderId or data.id or data.order)) or 0)
    if orderId <= 0 then
        cb({ success = false, error = "invalid_payload" })
        return
    end

    local res = Sky.Cb.Trigger("sky_mechanicjob:orders:refund", { orderId = orderId }) or {}
    if type(res) == "table" and res.success == true then
        cb(res)
        return
    end

    cb({ success = false, error = (type(res) == "table" and res.error) or "refund_failed" })
end)

local function handleOrderDelete(data, cb)
    local orderId = math.floor(tonumber(data and (data.orderId or data.id or data.order or data.orderUID or data.uid)) or 0)
    local plateStr = sanitizePlate(data and (data.plate or (data.order and data.order.plate)))

    local payload = {}
    if orderId > 0 then
        payload.orderId = orderId
    elseif plateStr ~= "" then
        payload.plate = plateStr
    else
        OrderTabletState.connectedVehicleNetId = 0
        cb({ success = true, data = { vehicle = nil } })
        return
    end

    local res = Sky.Cb.Trigger("sky_mechanicjob:orders:delete", payload) or {}
    if type(res) == "table" and res.success == true then
        cb(res)
        return
    end

    cb({ success = false, error = (type(res) == "table" and res.error) or "delete_failed" })
end

RegisterNUICallback("orders:delete", handleOrderDelete)
RegisterNUICallback("order:delete", handleOrderDelete)
RegisterNUICallback("orders:cancel", handleOrderDelete)
RegisterNUICallback("order:cancel", handleOrderDelete)
RegisterNUICallback("orders:remove", handleOrderDelete)
RegisterNUICallback("order:remove", handleOrderDelete)

RegisterNUICallback("tablet:getNearbyVehicles", function(data, cb)
    cb({ success = true, data = { vehicles = getNearbyVehicles(12.0) } })
end)

RegisterNUICallback("tablet:setConnectedVehicle", function(data, cb)
    local netId = math.floor(tonumber(data and (data.vehicleNetId or data.netId)) or 0)
    if netId <= 0 then
        OrderTabletState.connectedVehicleNetId = 0
        cb({ success = true, data = { vehicle = nil } })
        return
    end

    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh == 0 or not DoesEntityExist(veh) then
        OrderTabletState.connectedVehicleNetId = 0
        cb({ success = false, error = "vehicle_not_found" })
        return
    end

    OrderTabletState.connectedVehicleNetId = netId
    cb({ success = true, data = { vehicle = getConnectedVehiclePayload() } })
end)

RegisterNUICallback("tablet:disconnectVehicle", function(data, cb)
    OrderTabletState.connectedVehicleNetId = 0
    cb({ success = true, data = { vehicle = nil } })
end)

RegisterNUICallback("tablet:getConnectedVehicle", function(data, cb)
    cb({ success = true, data = { vehicle = getConnectedVehiclePayload() } })
end)

RegisterNUICallback("orders:startInstall", function(data, cb)
    local orderId = math.floor(tonumber(data and data.orderId) or 0)
    local partIndex = math.floor(tonumber(data and data.partIndex) or 0)
    local netId = math.floor(tonumber(data and data.vehicleNetId) or 0)

    if orderId <= 0 or partIndex <= 0 or netId <= 0 then
        cb({ success = false, error = "invalid_payload" })
        return
    end

    local veh = NetworkGetEntityFromNetworkId(netId)
    if veh == 0 or not DoesEntityExist(veh) then
        cb({ success = false, error = "vehicle_not_found" })
        return
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    if #(pedCoords - GetEntityCoords(veh)) > 15.0 then
        cb({ success = false, error = "vehicle_too_far" })
        return
    end

    if isSelfServiceTuningPointRequiredForAction("install") and not isNearSelfServiceTuningPoint() then
        notifySelfServiceTuningPointRequired()
        cb({ success = false, error = "not_near_self_service_tuning" })
        return
    end

    local prepRes = Sky.Cb.Trigger("sky_mechanicjob:orders:prepareInstall", {
        orderId = orderId,
        partIndex = partIndex
    }) or {}

    if type(prepRes) ~= "table" or prepRes.success ~= true then
        if type(prepRes) == "table" and prepRes.error == "not_near_self_service_tuning" then
            notifySelfServiceTuningPointRequired()
        end
        cb({
            success = false,
            error = (type(prepRes) == "table" and prepRes.error) or "prepare_failed",
            requiredItem = type(prepRes) == "table" and prepRes.requiredItem or nil
        })
        return
    end

    local prepData = prepRes.data or {}
    local partPayload = prepData.part
    if type(partPayload) ~= "table" then
        cb({ success = false, error = "part_not_found" })
        return
    end

    clearOrderInstallState()
    OrderInstallState.active = true
    OrderInstallState.finalizing = false
    OrderInstallState.orderId = orderId
    OrderInstallState.partIndex = partIndex
    OrderInstallState.part = partPayload

    local reqItem = tostring(prepData.requiredItem or partPayload.requiredItem or requiredItemByOptionId(partPayload.id))
    OrderInstallState.requiredItem = reqItem
    OrderInstallState.removeRequiredItemAfterUse = (prepData.removeRequiredItemAfterUse == true)

    OrderInstallState.installFlow = ""
    OrderInstallState.repairMode = false
    OrderInstallState.directStanceInstall = false
    OrderInstallState.repairPart = ""
    OrderInstallState.repairPlate = ""

    OrderInstallState.vehicleNetId = netId
    OrderInstallState.vehicle = veh
    OrderInstallState.simpleChecklistVisible = false
    OrderInstallState.simpleStep = "idle"
    OrderInstallState.stanceCompletedWheels = {}

    OrderTabletState.connectedVehicleNetId = netId

    if prepData.carryItem == true then
        holdCarryItemProp(OrderInstallState.requiredItem)
    end

    local isWheel = isWheelOrderPart(partPayload, OrderInstallState.requiredItem) or isBrakeWheelWorkflowPart(partPayload, OrderInstallState.requiredItem) or isSuspensionWheelWorkflowPart(partPayload, OrderInstallState.requiredItem)

    if isWheel then
        startWheelInstallState(isBrakeWheelWorkflowPart(partPayload, OrderInstallState.requiredItem), isSuspensionWheelWorkflowPart(partPayload, OrderInstallState.requiredItem))
        local partLbl = tostring(partPayload.label or ("Part " .. tostring(partIndex)))
        notify(("%s: %s. %s"):format(
            getNuiLocale("tablet.orders.installing", "Installing part"),
            partLbl,
            getNuiLocale("tablet.orders.wheel_checklist.hint", "Use radial menu and follow the wheel checklist.")
        ), "info")
    elseif isRepaintOrderPart(partPayload, OrderInstallState.requiredItem) then
        startRepaintInstallState()
        local partLbl = tostring(partPayload.label or ("Part " .. tostring(partIndex)))
        notify(("%s: %s. %s"):format(
            getNuiLocale("tablet.orders.installing", "Installing part"),
            partLbl,
            getNuiLocale("tablet.orders.repaint_checklist.hint", "Use radial menu and follow the repaint checklist.")
        ), "info")
    else
        startSimpleInstallState()
        releaseOrderHeldProp()
        local partLbl = tostring(partPayload.label or ("Part " .. tostring(partIndex)))
        notify(("%s: %s. %s"):format(
            getNuiLocale("tablet.orders.installing", "Installing part"),
            partLbl,
            getNuiLocale("tablet.orders.simple_checklist.hint", "Use radial menu and complete the install checklist.")
        ), "info")
    end

    releaseNuiFocus()
    cb({
        success = true,
        data = {
            orderId = orderId,
            partIndex = partIndex,
            requiredItem = OrderInstallState.requiredItem,
            carryItem = prepData.carryItem == true
        }
    })
end)

RegisterNUICallback("tuning:focus", function(data, cb)
    if not TuningState.active then
        cb({ success = false, error = "inactive" })
        return
    end

    local optId = data and data.id
    if optId and TuningState.optionMap[optId] then
        cb({ success = true })
        return
    end

    cb({ success = false, error = "invalid_option" })
end)

RegisterNUICallback("tuning:section", function(data, cb)
    if not TuningState.active then
        cb({ success = false, error = "inactive" })
        return
    end

    updateTuningHeadlights(data and data.section)
    cb({ success = true })
end)

RegisterNUICallback("tuning:toggleFocus", function(data, cb)
    if not TuningState.active then
        cb({ success = false, error = "inactive" })
        return
    end

    if not TuningState.nuiFocused then
        cb({ success = false, error = "already_unfocused" })
        return
    end

    if not canToggleTuningFocus() then
        cb({ success = false, error = "cooldown" })
        return
    end

    setNuiFocusState(false)
    cb({ success = true, enabled = false })
end)

-- Thread: Camera & Control restriction when Tuning UI active (unfocused mode)
CreateThread(function()
    while true do
        if TuningState.active then
            if not TuningState.nuiFocused then
                DisablePlayerFiring(PlayerId(), true)
                DisableAllControlActions(0)
                DisableAllControlActions(1)
                DisableAllControlActions(2)

                EnableControlAction(0, 1, true)
                EnableControlAction(0, 2, true)
                EnableControlAction(1, 1, true)
                EnableControlAction(1, 2, true)
                EnableControlAction(2, 1, true)
                EnableControlAction(2, 2, true)

                if canToggleTuningFocus() then
                    if IsDisabledControlJustPressed(0, 22) then -- SPACE
                        setNuiFocusState(true)
                    end
                else
                    if IsDisabledControlJustPressed(0, 200) or IsDisabledControlJustPressed(0, 202) then -- ESC / BACKSPACE
                        setTuningClosed(false)
                    end
                end
                Wait(0)
            else
                Wait(100)
            end
        else
            Wait(250)
        end
    end
end)
