if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/catalytic_converter.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/catalytic_converter.lua
--  Deobfuscated & Cleaned
-- =====================================================

local FEATURE_KEY              = "catalytic_converter"
local STATE_BAG_KEY            = "sky_mechanic_catalytic_missing"
local SEARCH_RADIUS            = 4.0
local CONTROL_INTERACT         = 38   -- E
local CONTROL_CANCEL           = 73   -- X
local PTFX_ASSET_NAME          = "core"
local PTFX_EFFECT_NAME         = "ent_amb_generator_smoke"
local SMOKE_INTERVAL_MS        = 300
local SMOKE_FX_DURATION_MS     = 650
local RPM_MULTIPLIER           = 3.0
local MAX_EXHAUST_BONES        = 2

local EXHAUST_BONE_NAMES = {
    "exhaust", "exhaust_2", "exhaust_3", "exhaust_4",
    "exhaust_5", "exhaust_6", "exhaust_7", "exhaust_8",
    "exhaust_9", "exhaust_10", "exhaust_11", "exhaust_12"
}

local smokeState = {
    vehicle = 0,
    audioVehicle = 0,
    nextSmokeAt = 0,
    exhaustBonesByKey = {},
    smokeFxPool = {},
    smokeFxLoopRunning = false,
    driverLoopRunning = false,
    driverLoopVehicle = 0,
    driverLoopToken = 0,
    stealInputLoopRunning = false
}

-- ── Helpers ──────────────────────────────────────────

local function normalizeplate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

local function isCatalyticMissing(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return false
    end

    local stateBagVal = Entity(vehicle).state[STATE_BAG_KEY]
    if stateBagVal == true then
        return true
    end

    local plate = normalizeplate(GetVehicleNumberPlateText(vehicle))
    if WearState and WearState.active then
        local wearPlate = normalizeplate(WearState.plate)
        if wearPlate == plate then
            return tonumber(WearState.wear and WearState.wear[FEATURE_KEY]) ~= nil
        end
    end

    return false
end

local function findNearbyVehicle()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = getClosestVehicleWithPoliceFallback(coords.x, coords.y, coords.z, SEARCH_RADIUS, 0, 70)

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 0
    end
    return vehicle
end

local function showNotify(message, notifyType)
    notify(message, notifyType or "info")
end

-- ── Checklist UI ─────────────────────────────────────

local function updateChecklist()
    if not CatalyticInstallState.active then return end

    local step = CatalyticInstallState.step
    local isInstall = CatalyticInstallState.mode == "install"

    local workLabel
    if isInstall then
        workLabel = getNuiLocale("tablet.orders.catalytic_checklist.install", "Install the catalytic converter")
    else
        workLabel = getNuiLocale("tablet.orders.catalytic_checklist.remove", "Remove the catalytic converter")
    end

    local note
    if isInstall then
        note = getNuiLocale("tablet.orders.wheel_checklist.note", "Only the next valid action is available in radial menu.")
    else
        note = getNuiLocale("tablet.orders.catalytic_checklist.note", "Press E for the next step. Press X to cancel.")
    end

    sendUi("wheelInstall:checklist:update", {
        title = getNuiLocale("tablet.orders.catalytic_checklist.title", "Catalytic Converter"),
        note = note,
        steps = {
            {
                id = "lift",
                label = getNuiLocale("tablet.orders.catalytic_checklist.lift", "Lift the vehicle with the car jack"),
                done = step ~= "lift"
            },
            {
                id = "work",
                label = workLabel,
                done = step == "lower" or step == "complete"
            },
            {
                id = "lower",
                label = getNuiLocale("tablet.orders.catalytic_checklist.lower", "Remove the car jack"),
                done = step == "complete"
            }
        }
    })

    CatalyticInstallState.checklistVisible = true
end

-- ── State Management ─────────────────────────────────

local function clearCatalyticStateImpl(alsoRemoveJack)
    if CatalyticInstallState.checklistVisible then
        sendUi("wheelInstall:checklist:close", {})
    end

    CatalyticInstallState.active = false
    CatalyticInstallState.mode = "steal"
    CatalyticInstallState.step = "idle"
    CatalyticInstallState.vehicle = 0
    CatalyticInstallState.vehicleNetId = 0
    CatalyticInstallState.plate = ""
    CatalyticInstallState.checklistVisible = false

    if alsoRemoveJack and CarJackState.lifted then
        clearCarJackState(true)
    end
end
clearCatalyticState = clearCatalyticStateImpl

function startCatalyticInstallState(vehicle, vehicleNetId, plate)
    CatalyticInstallState.active = true
    CatalyticInstallState.mode = "install"
    CatalyticInstallState.step = "lift"
    CatalyticInstallState.vehicle = vehicle
    CatalyticInstallState.vehicleNetId = vehicleNetId
    CatalyticInstallState.plate = plate
    updateChecklist()
end

local function resolveInstallVehicle()
    local vehicle = CatalyticInstallState.vehicle
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        vehicle = NetworkGetEntityFromNetworkId(CatalyticInstallState.vehicleNetId)
        CatalyticInstallState.vehicle = vehicle
    end

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        clearCatalyticState(true)
        return 0, {
            fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.")
        }
    end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local vehicleCoords = GetEntityCoords(vehicle)
    local dist = #(playerCoords - vehicleCoords)

    if dist > SEARCH_RADIUS + 2.0 then
        return 0, {
            fallback = tuningLocales.CatalyticTooFar or "Move closer to the vehicle."
        }
    end

    return vehicle
end

-- ── Minigame & Completion ────────────────────────────

local function runCatalyticMinigame(vehicle, mode)
    local minigameType = (mode == "install") and "attach" or "detach"
    return runTuningMinigame("wheel_change", minigameType, vehicle, {
        target = "catalytic_converter",
        boltCount = 4,
        requiredRotation = 300
    })
end

local function completeSteal(vehicle)
    local res = Sky.Cb.Trigger("sky_mechanicjob:catalytic:completeSteal", {
        vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle),
        plate = normalizeplate(GetVehicleNumberPlateText(vehicle))
    })

    if not res then res = {} end

    if type(res) == "table" and res.success == true then
        showNotify(tuningLocales.CatalyticRemoved or "Catalytic converter removed.", "success")
        clearCatalyticState(false)
        return true
    end

    showNotify(tuningLocales.CatalyticMissingItem or "You need a lug wrench.", "error")
    return false
end

local function completeInstall(vehicle)
    local res = Sky.Cb.Trigger("sky_mechanicjob:wear:completeRepairInstall", {
        plate = CatalyticInstallState.plate,
        part = FEATURE_KEY,
        requiredItem = OrderInstallState.requiredItem,
        removeRequiredItemAfterUse = OrderInstallState.removeRequiredItemAfterUse == true,
        vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    })

    if not res then res = {} end

    if type(res) == "table" and res.success == true then
        showNotify(tuningLocales.CatalyticInstallSuccess or "Catalytic converter installed.", "success")
        clearOrderInstallState()
        return true
    end

    showNotify(getNuiLocale("tablet.diagnostics.repairFailed", "Repair failed. Try again."), "error")
    return false
end

-- ── Main Action Performer ────────────────────────────

local function performCatalyticActionImpl()
    if not CatalyticInstallState.active then
        return false
    end

    local vehicle, errInfo = resolveInstallVehicle()
    if vehicle == 0 then
        showNotify(errInfo.fallback, "error")
        return false
    end

    local step = CatalyticInstallState.step

    if step == "lift" then
        local nearestTarget = select(1, getNearestCarJackTarget())
        if nearestTarget ~= vehicle then
            showNotify(tuningLocales.CarJackNotNear or "Move closer to the vehicle side to use the car jack.", "error")
            return false
        end

        local jackOk, jackErr = tryUseVehicleCarJack()
        if not jackOk then
            local errMsg = (jackErr and jackErr.fallback) or tuningLocales.CarJackControlFailed or "Unable to use car jack right now."
            showNotify(errMsg, "error")
            return false
        end

        CatalyticInstallState.step = "work"
        updateChecklist()
        return true
    end

    if step == "work" then
        local isInstall = CatalyticInstallState.mode == "install"

        if not isInstall and isCatalyticMissing(vehicle) then
            showNotify(tuningLocales.CatalyticAlreadyMissing or "This vehicle is already missing its catalytic converter.", "error")
            return false
        end

        local mgOk, mgErr = runCatalyticMinigame(vehicle, CatalyticInstallState.mode)
        if not mgOk then
            local errMsg = (mgErr and mgErr.fallback) or tuningLocales.CatalyticMinigameFailed or "You failed to remove all bolts."
            showNotify(errMsg, "error")
            return false
        end

        CatalyticInstallState.step = "lower"
        updateChecklist()
        return true
    end

    if step == "lower" then
        local lowerOk, lowerErr = tryRemoveVehicleCarJack()
        if not lowerOk then
            local errMsg = (lowerErr and lowerErr.fallback) or tuningLocales.CarJackControlFailed or "Unable to use car jack right now."
            showNotify(errMsg, "error")
            return false
        end

        CatalyticInstallState.step = "complete"
        updateChecklist()

        if CatalyticInstallState.mode == "install" then
            return completeInstall(vehicle)
        end
        return completeSteal(vehicle)
    end

    return false
end
performCatalyticAction = performCatalyticActionImpl

-- ── Steal Input Loop ─────────────────────────────────

local function startStealInputLoop()
    if smokeState.stealInputLoopRunning then return end
    smokeState.stealInputLoopRunning = true

    CreateThread(function()
        while CatalyticInstallState.active and CatalyticInstallState.mode == "steal" do
            if IsControlJustPressed(0, CONTROL_INTERACT) then
                performCatalyticAction()
            elseif IsControlJustPressed(0, CONTROL_CANCEL) then
                clearCatalyticState(true)
                showNotify(tuningLocales.CatalyticCanceled or "Catalytic converter removal canceled.", "info")
            end
            Wait(0)
        end
        smokeState.stealInputLoopRunning = false
    end)
end

-- ── Start Steal Event ────────────────────────────────

RegisterNetEvent("sky_mechanicjob:catalytic:startSteal", function()
    if OrderInstallState.active or CatalyticInstallState.active then
        showNotify(tuningLocales.Busy or "Tuning menu is already open.", "error")
        return
    end

    local vehicle = findNearbyVehicle()
    if vehicle == 0 then
        showNotify(tuningLocales.CatalyticNoVehicle or "No nearby vehicle found.", "error")
        return
    end

    if isCatalyticMissing(vehicle) then
        showNotify(tuningLocales.CatalyticAlreadyMissing or "This vehicle is already missing its catalytic converter.", "error")
        return
    end

    local plate = normalizeplate(GetVehicleNumberPlateText(vehicle))
    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    local res = Sky.Cb.Trigger("sky_mechanicjob:catalytic:prepareSteal", {
        vehicleNetId = netId,
        plate = plate
    })
    if not res then res = {} end

    if not (type(res) == "table" and res.success == true) then
        local errMsg = tuningLocales.CatalyticMissingItem or "You need a lug wrench."

        if type(res) == "table" and res.error == "already_missing" then
            errMsg = tuningLocales.CatalyticAlreadyMissing or "This vehicle is already missing its catalytic converter."
        elseif type(res) == "table" and res.error == "vehicle_too_far" then
            errMsg = tuningLocales.CatalyticTooFar or "Move closer to the vehicle."
        end

        showNotify(errMsg, "error")
        return
    end

    CatalyticInstallState.active = true
    CatalyticInstallState.mode = "steal"
    CatalyticInstallState.step = "lift"
    CatalyticInstallState.vehicle = vehicle
    CatalyticInstallState.vehicleNetId = netId
    CatalyticInstallState.plate = plate
    updateChecklist()
    startStealInputLoop()
    showNotify(tuningLocales.CatalyticStarted or "Catalytic converter removal started.", "info")
end)

-- ── Smoke FX / Audio System ──────────────────────────

local function clearSmokeState()
    smokeState.vehicle = 0
    smokeState.nextSmokeAt = 0
end

local function resetAudioForVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local audioName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    if type(audioName) ~= "string" or audioName == "" or audioName == "CARNOTFOUND" then
        print(string.format("[sky_mechanicjob][catalytic] audio reset failed: invalid model audio name %s", tostring(audioName)))
        return
    end

    ForceVehicleEngineAudio(vehicle, audioName)
    if smokeState.audioVehicle == vehicle then
        smokeState.audioVehicle = 0
    end
end

local function cleanupDriverLoop()
    smokeState.driverLoopToken = smokeState.driverLoopToken + 1
    smokeState.driverLoopRunning = false
    smokeState.driverLoopVehicle = 0

    if smokeState.vehicle ~= 0 then
        clearSmokeState()
    end
    if smokeState.audioVehicle ~= 0 then
        resetAudioForVehicle(smokeState.audioVehicle)
    end
end

local function getVehicleFxKey(vehicle)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId > 0 then
        return string.format("n:%s", netId)
    end
    return string.format("e:%s", vehicle)
end

-- ── Smoke FX Pool Loop ──────────────────────────────

local function startSmokeFxPoolLoop()
    if smokeState.smokeFxLoopRunning then return end
    smokeState.smokeFxLoopRunning = true

    CreateThread(function()
        while next(smokeState.smokeFxPool) do
            local now = GetGameTimer()

            for poolKey, fxEntry in pairs(smokeState.smokeFxPool) do
                local fxVehicle = fxEntry.vehicle
                local expiresAt = fxEntry.expiresAt or 0
                local expired = now >= expiresAt
                local gone = fxVehicle == 0 or DoesEntityExist(fxVehicle)

                if gone or expired then
                    if fxEntry.handle and fxEntry.handle ~= 0 then
                        StopParticleFxLooped(fxEntry.handle, false)
                    end
                    smokeState.smokeFxPool[poolKey] = nil
                end
            end

            Wait(50)
        end
        smokeState.smokeFxLoopRunning = false
    end)
end

local function stopAllSmokeFx()
    for poolKey, fxEntry in pairs(smokeState.smokeFxPool) do
        if fxEntry.handle and fxEntry.handle ~= 0 then
            StopParticleFxLooped(fxEntry.handle, false)
        end
        smokeState.smokeFxPool[poolKey] = nil
    end
end

-- ── Exhaust Bone Resolution ─────────────────────────

local function getExhaustBones(vehicle)
    local vehKey = getVehicleFxKey(vehicle)
    local cached = smokeState.exhaustBonesByKey[vehKey]

    if type(cached) == "table" and cached.vehicle == vehicle and type(cached.bones) == "table" then
        return cached.bones
    end

    local bones = {}
    for _, boneName in ipairs(EXHAUST_BONE_NAMES) do
        local boneIdx = GetEntityBoneIndexByName(vehicle, boneName)
        if boneIdx ~= -1 then
            bones[#bones + 1] = boneIdx
            if #bones >= MAX_EXHAUST_BONES then break end
        end
    end

    smokeState.exhaustBonesByKey[vehKey] = { vehicle = vehicle, bones = bones }
    return bones
end

-- ── PTFX Asset Loading ──────────────────────────────

local function ensurePtfxLoaded()
    if HasNamedPtfxAssetLoaded(PTFX_ASSET_NAME) then
        return true
    end
    RequestNamedPtfxAsset(PTFX_ASSET_NAME)
    return HasNamedPtfxAssetLoaded(PTFX_ASSET_NAME)
end

-- ── Spawn Single Smoke FX ───────────────────────────

local function spawnSmokeFxOnBone(vehicle, boneIdx, rpmScale)
    if vehicle == 0 or not DoesEntityExist(vehicle) or boneIdx == -1 then return end
    if not ensurePtfxLoaded() then return end

    local scale = math.max(0.12, math.min(2.5, tonumber(rpmScale) or 0.0))
    local now = GetGameTimer()
    local poolKey = string.format("%s:%s", getVehicleFxKey(vehicle), tostring(boneIdx))

    local existing = smokeState.smokeFxPool[poolKey]
    if existing and existing.vehicle == vehicle and existing.handle and existing.handle ~= 0 then
        existing.expiresAt = math.max(existing.expiresAt or 0, now + SMOKE_FX_DURATION_MS)
        SetParticleFxLoopedScale(existing.handle, scale)
        SetParticleFxLoopedAlpha(existing.handle, 0.75)
        return
    end

    UseParticleFxAssetNextCall(PTFX_ASSET_NAME)
    local handle = StartParticleFxLoopedOnEntityBone(
        PTFX_EFFECT_NAME, vehicle,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        boneIdx, scale,
        false, false, false
    )

    if not handle or handle == 0 then
        print(string.format("[sky_mechanicjob][catalytic] smoke effect failed: vehicle=%s bone=%s", tostring(vehicle), tostring(boneIdx)))
        return
    end

    SetParticleFxLoopedScale(handle, scale)
    SetParticleFxLoopedAlpha(handle, 0.75)

    smokeState.smokeFxPool[poolKey] = {
        vehicle = vehicle,
        handle = handle,
        expiresAt = now + SMOKE_FX_DURATION_MS
    }
    startSmokeFxPoolLoop()
end

local function applySmokeFxToVehicle(vehicle, rpmScale)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local bones = getExhaustBones(vehicle)
    if #bones == 0 then return end

    for _, boneIdx in ipairs(bones) do
        spawnSmokeFxOnBone(vehicle, boneIdx, rpmScale)
    end
end

-- ── Driver Smoke Emitter ─────────────────────────────

local function emitDriverSmoke(vehicle)
    local now = GetGameTimer()
    if smokeState.vehicle ~= vehicle then
        smokeState.vehicle = vehicle
        smokeState.nextSmokeAt = 0
    end

    if now < smokeState.nextSmokeAt then return end
    smokeState.nextSmokeAt = now + SMOKE_INTERVAL_MS

    local rpmScale = GetVehicleCurrentRpm(vehicle) * RPM_MULTIPLIER
    if not IsControlPressed(0, 71) then
        rpmScale = rpmScale / RPM_MULTIPLIER
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent("sky_mechanicjob:catalytic:syncSmoke", netId, rpmScale)
end

-- ── Smoke Sync Net Event ─────────────────────────────

RegisterNetEvent("sky_mechanicjob:catalytic:syncSmoke", function(netId, rpmScale)
    local vehicle = NetworkGetEntityFromNetworkId(math.floor(tonumber(netId) or 0))
    applySmokeFxToVehicle(vehicle, tonumber(rpmScale) or 0.0)
end)

-- ── Driver Loop Starter ──────────────────────────────

local function startDriverLoop(vehicle)
    local ped = PlayerPedId()
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then return end
    if not isCatalyticMissing(vehicle) then return end

    if smokeState.driverLoopRunning and smokeState.driverLoopVehicle == vehicle then
        return
    end

    smokeState.driverLoopToken = smokeState.driverLoopToken + 1
    smokeState.driverLoopRunning = true
    smokeState.driverLoopVehicle = vehicle

    local myToken = smokeState.driverLoopToken

    CreateThread(function()
        while myToken == smokeState.driverLoopToken do
            local loopPed = PlayerPedId()
            if not DoesEntityExist(vehicle) then break end
            if GetVehiclePedIsIn(loopPed, false) ~= vehicle then break end
            if GetPedInVehicleSeat(vehicle, -1) ~= loopPed then break end
            if not isCatalyticMissing(vehicle) then break end

            if smokeState.audioVehicle ~= vehicle then
                ForceVehicleEngineAudio(vehicle, "RATBIKE")
                smokeState.audioVehicle = vehicle
            end

            emitDriverSmoke(vehicle)
            Wait(100)
        end

        if myToken == smokeState.driverLoopToken then
            cleanupDriverLoop()
        end
    end)
end

-- ── Vehicle Entry Check ──────────────────────────────

local function checkCurrentVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 or not DoesEntityExist(vehicle) or GetPedInVehicleSeat(vehicle, -1) ~= ped then
        cleanupDriverLoop()
        return
    end

    if isCatalyticMissing(vehicle) then
        startDriverLoop(vehicle)
    else
        cleanupDriverLoop()
    end
end

-- ── State Bag Handler ────────────────────────────────

AddStateBagChangeHandler(STATE_BAG_KEY, nil, function(bagName, _key, value)
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 or not DoesEntityExist(entity) or not IsEntityAVehicle(entity) then
        return
    end

    if value == true then
        local ped = PlayerPedId()
        local pedVeh = GetVehiclePedIsIn(ped, false)
        if pedVeh == entity and GetPedInVehicleSeat(entity, -1) == ped then
            startDriverLoop(entity)
        end
        return
    end

    if smokeState.audioVehicle == entity or smokeState.vehicle == entity then
        cleanupDriverLoop()
    else
        resetAudioForVehicle(entity)
    end
end)

-- ── Init Threads ─────────────────────────────────────

CreateThread(function()
    Wait(500)
    checkCurrentVehicle()
end)

AddEventHandler("gameEventTriggered", function(eventName, eventData)
    if eventName ~= "CEventNetworkPlayerEnteredVehicle" then return end

    local vehicle = (eventData and eventData[2]) or GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then return end

    startDriverLoop(vehicle)
end)

AddEventHandler("onResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    cleanupDriverLoop()
    clearSmokeState()
    stopAllSmokeFx()
    smokeState.exhaustBonesByKey = {}
end)
