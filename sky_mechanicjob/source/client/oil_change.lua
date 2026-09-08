if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/oil_change.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/oil_change.lua
--  Deobfuscated & Cleaned
-- =====================================================

local ANIM_MISS_MECHANIC = "missmechanic"
local ANIM_MISS_MECHANIC_BASE = "work_base"
local ANIM_MISS_MECHANIC_IN = "work_in"
local ANIM_MISS_MECHANIC_OUT = "work_out"

local ANIM_MECHANIC_BASE_DICT = "amb@world_human_vehicle_mechanic@male@base"
local ANIM_MECHANIC_BASE_CLIP = "base"
local ANIM_MECHANIC_IDLE_DICT = "amb@world_human_vehicle_mechanic@male@idle_a"
local ANIM_MECHANIC_IDLE_CLIP = "idle_b"
local ANIM_MECHANIC_EXIT_DICT = "amb@world_human_vehicle_mechanic@male@exit"
local ANIM_MECHANIC_EXIT_FLEE = "exit_flee"
local ANIM_MECHANIC_EXIT_CLIP = "exit"

local ANIM_REPAIR_DICT = "mini@repair"
local ANIM_REPAIR_CLIP = "fixing_a_ped"

local OIL_BARREL_PROP = "sky_waste_oil_drainer"
local OIL_DRAIN_TIMEOUT_MS = 45000
local OIL_POUR_TIMEOUT_MS = 45000

local FLUID_DRAIN_MAP = {
    engine_oil = "engine_oil",
    coolant = "engine_coolant",
    brake_fluid = "brake_fluid",
    transmission_fluid = "transmission_fluid"
}

local FLUID_ITEM_MAP = {
    engine_oil = "engine_oil",
    engine_coolant = "engine_coolant",
    coolant = "engine_coolant",
    brake_fluid = "brake_fluid",
    transmission_fluid = "transmission_fluid"
}

-- ── Position Checks ──────────────────────────────────

function isPedBelowVehicleForOilDrain(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][oil_change] below check failed: vehicle is missing")
        return false
    end

    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local minDim, _ = GetModelDimensions(GetEntityModel(vehicle))
    local underPoint = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 0.0, minDim.z + 0.15)

    local dist2d = #(vector2(pedCoords.x, pedCoords.y) - vector2(underPoint.x, underPoint.y))
    local vehCoords = GetEntityCoords(vehicle)

    if dist2d > 2.2 then
        print(string.format("[sky_mechanicjob][oil_change] below check failed: too far under vehicle (distance=%.2f max=2.20)", dist2d))
        return false
    end

    if pedCoords.z > vehCoords.z - 0.25 then
        print(string.format("[sky_mechanicjob][oil_change] below check failed: ped is not below vehicle (pedZ=%.2f vehicleZ=%.2f)", pedCoords.z, vehCoords.z))
        return false
    end

    return true
end

-- ── Pre-Drain Validation ─────────────────────────────

local function validateOilDrainPreconditions(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][oil_change] drain failed: vehicle is missing")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.")
        }
    end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        print("[sky_mechanicjob][oil_change] drain failed: player is inside a vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.OilChangeLeaveVehicle or "Leave the vehicle before draining the oil."
        }
    end

    if not isPedBelowVehicleForOilDrain(vehicle) then
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.OilChangeNeedBelowVehicle or "Stand below the lifted vehicle before draining the oil."
        }
    end

    return true
end

-- ── Drain Setup Animation & Barrel Prop ──────────────

local function setupDrainAnimAndBarrel(vehicle)
    local ped = PlayerPedId()
    local barrelHash = GetHashKey(OIL_BARREL_PROP)
    Sky.Load.Model(barrelHash)

    local pedCoords = GetEntityCoords(ped)
    local fwd = GetEntityForwardVector(ped)
    local spawnPos = vector3(pedCoords.x + fwd.x * 0.8, pedCoords.y + fwd.y * 0.8, pedCoords.z - 1.0)

    local barrelObj = CreateObjectNoOffset(barrelHash, spawnPos.x, spawnPos.y, spawnPos.z, true, true, false)
    if barrelObj == 0 or not DoesEntityExist(barrelObj) then
        print("[sky_mechanicjob][oil_change] minigame setup failed: unable to spawn oil barrel prop")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle.")
        }
    end

    SetEntityAsMissionEntity(barrelObj, true, true)
    PlaceObjectOnGroundProperly(barrelObj)
    SetEntityHeading(barrelObj, GetEntityHeading(ped))
    TaskTurnPedToFaceEntity(ped, vehicle, 700)

    Sky.Load.AnimDict(ANIM_MISS_MECHANIC)
    Sky.Load.AnimDict(ANIM_MECHANIC_BASE_DICT)
    Sky.Load.AnimDict(ANIM_MECHANIC_IDLE_DICT)

    if requestAnimDictLoaded(ANIM_MISS_MECHANIC, 2500) then
        TaskPlayAnim(ped, ANIM_MISS_MECHANIC, ANIM_MISS_MECHANIC_IN, 8.0, -8.0, 700, 1, 0.0, false, false, false)
        Wait(650)
        TaskPlayAnim(ped, ANIM_MISS_MECHANIC, ANIM_MISS_MECHANIC_BASE, 8.0, -8.0, -1, 1, 0.0, false, false, false)
        return true, barrelObj
    end

    if requestAnimDictLoaded(ANIM_MECHANIC_BASE_DICT, 2500) then
        TaskPlayAnim(ped, ANIM_MECHANIC_BASE_DICT, ANIM_MECHANIC_BASE_CLIP, 8.0, -8.0, -1, 1, 0.0, false, false, false)
    end

    if requestAnimDictLoaded(ANIM_MECHANIC_IDLE_DICT, 2500) then
        TaskPlayAnim(ped, ANIM_MECHANIC_IDLE_DICT, ANIM_MECHANIC_IDLE_CLIP, 8.0, -8.0, -1, 49, 0.0, false, false, false)
    end

    return true, barrelObj
end

-- ── Drain Cleanup ────────────────────────────────────

local function cleanupDrainAnim(barrelObj)
    local ped = PlayerPedId()

    Sky.Load.AnimDict(ANIM_MISS_MECHANIC)
    if requestAnimDictLoaded(ANIM_MISS_MECHANIC, 2500) then
        TaskPlayAnim(ped, ANIM_MISS_MECHANIC, ANIM_MISS_MECHANIC_OUT, 8.0, -8.0, 600, 1, 0.0, false, false, false)
        Wait(520)
    else
        Sky.Load.AnimDict(ANIM_MECHANIC_EXIT_DICT)
        if requestAnimDictLoaded(ANIM_MECHANIC_EXIT_DICT, 2500) then
            TaskPlayAnim(ped, ANIM_MECHANIC_EXIT_DICT, ANIM_MECHANIC_EXIT_FLEE, 8.0, -8.0, 350, 1, 0.0, false, false, false)
            Wait(300)
            TaskPlayAnim(ped, ANIM_MECHANIC_EXIT_DICT, ANIM_MECHANIC_EXIT_CLIP, 8.0, -8.0, 450, 1, 0.0, false, false, false)
            Wait(420)
        end
    end

    ClearPedTasksImmediately(ped)
    ClearPedSecondaryTask(ped)

    if DoesEntityExist(barrelObj) then
        DeleteEntity(barrelObj)
    end
end

-- ── Lift Overhead Work Anim ──────────────────────────

function runLiftOverheadWorkAnim(vehicle, label)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.")
        }
    end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle.")
        }
    end

    TaskTurnPedToFaceEntity(ped, vehicle, 700)

    Sky.Load.AnimDict(ANIM_MISS_MECHANIC)
    if not requestAnimDictLoaded(ANIM_MISS_MECHANIC, 2500) then
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle.")
        }
    end

    TaskPlayAnim(ped, ANIM_MISS_MECHANIC, ANIM_MISS_MECHANIC_IN, 8.0, -8.0, 700, 1, 0.0, false, false, false)
    Wait(650)
    TaskPlayAnim(ped, ANIM_MISS_MECHANIC, ANIM_MISS_MECHANIC_BASE, 8.0, -8.0, -1, 1, 0.0, false, false, false)

    local duration = startNonMinigameInstallProgress(
        label or getNuiLocale("tablet.orders.installing", "Installing part"),
        getNonMinigameInstallDurationMs()
    )

    Wait(duration)
    stopNonMinigameInstallProgress()

    TaskPlayAnim(ped, ANIM_MISS_MECHANIC, ANIM_MISS_MECHANIC_OUT, 8.0, -8.0, 600, 1, 0.0, false, false, false)
    Wait(520)

    ClearPedTasksImmediately(ped)
    ClearPedSecondaryTask(ped)

    return true
end

-- ── Underbody Neon Install Anim ──────────────────────

function runUnderbodyNeonInstallAnim(vehicle, partId)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][neon_install] install failed: vehicle is missing")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.")
        }
    end

    local copy = getUnderbodyInstallCopy(partId)
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then
        print("[sky_mechanicjob][neon_install] install failed: player is inside a vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = copy.leaveVehicle
        }
    end

    if not isPedBelowVehicleForOilDrain(vehicle) then
        return false, {
            key = "radial.errors.generic",
            fallback = copy.needBelowVehicle
        }
    end

    TaskTurnPedToFaceEntity(ped, vehicle, 700)
    Sky.Load.AnimDict(ANIM_MISS_MECHANIC)

    if requestAnimDictLoaded(ANIM_MISS_MECHANIC, 2500) then
        TaskPlayAnim(ped, ANIM_MISS_MECHANIC, ANIM_MISS_MECHANIC_IN, 8.0, -8.0, 700, 1, 0.0, false, false, false)
        Wait(650)
    end

    TaskPlayAnim(ped, ANIM_MISS_MECHANIC, ANIM_MISS_MECHANIC_BASE, 8.0, -8.0, -1, 1, 0.0, false, false, false)

    local duration = startNonMinigameInstallProgress(
        getNuiLocale("tablet.orders.installing", "Installing part"),
        getNonMinigameInstallDurationMs()
    )

    Wait(duration)
    stopNonMinigameInstallProgress()

    ClearPedTasksImmediately(ped)
    ClearPedSecondaryTask(ped)

    return true
end

-- ── Oil Pour Validation ──────────────────────────────

local function validateOilPourPreconditions(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][oil_change] pour failed: vehicle is missing")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.")
        }
    end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        print("[sky_mechanicjob][oil_change] pour failed: player is inside a vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.OilChangeLeaveVehicle or "Leave the vehicle before draining the oil."
        }
    end

    if not HasVehicleHood(vehicle) then return true end

    if not IsVehicleDoorDamaged(vehicle, 4) then
        local angleRatio = GetVehicleDoorAngleRatio(vehicle, 4)
        if angleRatio <= 0.01 then
            print("[sky_mechanicjob][oil_change] pour failed: hood is closed")
            return false, {
                key = "radial.errors.generic",
                fallback = tuningLocales.OilChangeNeedOpenHood or "Open the hood from the radial menu before pouring fresh oil."
            }
        end
    end

    return true
end

-- ── Pour Setup Animation ─────────────────────────────

local function startPourAnimation(vehicle)
    local ped = PlayerPedId()
    TaskTurnPedToFaceEntity(ped, vehicle, 700)
    Sky.Load.AnimDict(ANIM_REPAIR_DICT)
    TaskPlayAnim(ped, ANIM_REPAIR_DICT, ANIM_REPAIR_CLIP, 8.0, -8.0, -1, 1, 0.0, false, false, false)
end

local function stopPourAnimation()
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    ClearPedSecondaryTask(ped)
end

-- ── Oil Drain Minigame ───────────────────────────────

function runOilDrainMinigame(vehicle)
    local ok, err = validateOilDrainPreconditions(vehicle)
    if not ok then return false, err end

    local sessionOk, session = TuningMinigames.StartSession("oil_drain", {
        state = OilDrainMinigameState,
        timeoutMs = OIL_DRAIN_TIMEOUT_MS,
        busyError = {
            key = "radial.errors.generic",
            fallback = tuningLocales.OilDrainMinigameBusy or "Oil drain minigame is already running.",
            messageType = "error"
        }
    })

    if not sessionOk then return false, session end

    local token = session.token
    local setupOk, barrelObj = setupDrainAnimAndBarrel(vehicle)
    if not setupOk then
        TuningMinigames.CancelSession("oil_drain", { success = false, cancelled = false, reason = "setup_failed" })
        return false, barrelObj
    end

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = "oilDrain:minigame:start",
        payload = {
            token = token,
            requiredRotation = 320,
            flowDurationMs = 6000
        }
    })

    local result = Citizen.Await(session.promise)

    releaseNuiFocus()
    closeOilDrainMinigameUi()
    cleanupDrainAnim(barrelObj)

    local wasSuccess = result and result.success == true
    local wasCancelled = result and result.cancelled == true

    if wasSuccess then return true end

    if wasCancelled then
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.OilDrainMinigameCanceled or "Oil drain canceled.",
            messageType = "info"
        }
    end

    return false, {
        key = "radial.errors.generic",
        fallback = tuningLocales.OilDrainMinigameFailed or "Oil drain minigame failed.",
        messageType = "error"
    }
end

-- ── Oil Pour Minigame ────────────────────────────────

function runOilPourMinigame(vehicle, partData)
    local partId = tostring((partData and partData.id) or "")
    local repairPart = tostring((OrderInstallState and OrderInstallState.repairPart) or "")
    local requiredItem = tostring((OrderInstallState and OrderInstallState.requiredItem) or "")

    local fluidKey = FLUID_DRAIN_MAP[partId] or partId or repairPart
    if not FLUID_DRAIN_MAP[fluidKey] then
        local mapped = FLUID_ITEM_MAP[requiredItem]
        fluidKey = mapped or fluidKey
    end

    local pourOk, pourErr = validateOilPourPreconditions(vehicle)
    if not pourOk then return false, pourErr end

    local sessionOk, session = TuningMinigames.StartSession("oil_pour", {
        state = OilPourMinigameState,
        timeoutMs = OIL_POUR_TIMEOUT_MS,
        busyError = {
            key = "radial.errors.generic",
            fallback = tuningLocales.OilPourMinigameBusy or "Oil pour minigame is already running.",
            messageType = "error"
        }
    })

    if not sessionOk then return false, session end

    local token = session.token
    startPourAnimation(vehicle)

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = "oilPour:minigame:start",
        payload = {
            token = token,
            requiredRotation = 720,
            pourDurationMs = 6000,
            tiltThresholdDeg = 42,
            fluidType = FLUID_DRAIN_MAP[fluidKey] or "engine_oil"
        }
    })

    local result = Citizen.Await(session.promise)

    releaseNuiFocus()
    closeOilPourMinigameUi()
    stopPourAnimation()

    local wasSuccess = result and result.success == true
    local wasCancelled = result and result.cancelled == true

    if wasSuccess then return true end

    if wasCancelled then
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.OilPourMinigameCanceled or "Oil pour canceled.",
            messageType = "info"
        }
    end

    return false, {
        key = "radial.errors.generic",
        fallback = tuningLocales.OilPourMinigameFailed or "Oil pour minigame failed.",
        messageType = "error"
    }
end

-- ── Register Minigames ───────────────────────────────

TuningMinigames.Register("oil_drain", runOilDrainMinigame)
TuningMinigames.Register("oil_pour", runOilPourMinigame)
