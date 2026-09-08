if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/change_parts.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/change_parts.lua
--  Deobfuscated & Cleaned
-- =====================================================

local SIMPLE_BODYWORK_MODS = {
    [0] = true, [1] = true, [2] = true, [3] = true, [4] = true,
    [5] = true, [6] = true, [7] = true, [8] = true, [9] = true,
    [10] = true, [14] = true, [16] = true, [25] = true, [26] = true,
    [27] = true, [28] = true, [29] = true, [30] = true, [31] = true,
    [32] = true, [33] = true, [34] = true, [35] = true, [36] = true,
    [37] = true, [38] = true, [39] = true, [40] = true, [41] = true,
    [42] = true, [43] = true, [44] = true, [45] = true, [46] = true,
    [49] = true
}

local ARMOR_MOD_KEY = "mod_16"
local ARMOR_CUT_RADIUS = 2.8
local MINIGAME_TIMEOUT_MS = 45000
local HOOD_ANGLE_THRESHOLD = 0.08

local ANIM_REPAIR_DICT = "mini@repair"
local ANIM_REPAIR_CLIP = "fixing_a_ped"

local REMOVABLE_PANELS = {
    { key = "door_lf", bone = "door_dside_f", doorIndex = 0 },
    { key = "door_rf", bone = "door_pside_f", doorIndex = 1 },
    { key = "door_lr", bone = "door_dside_r", doorIndex = 2 },
    { key = "door_rr", bone = "door_pside_r", doorIndex = 3 },
    { key = "hood",    bone = "bonnet",       doorIndex = 4 },
    { key = "trunk",   bone = "boot",         doorIndex = 5 }
}

-- ── Order Part Type Verification ─────────────────────

function isSimpleBodyworkOrderPart(partData)
    local partId = tostring((partData and partData.id) or "")
    if partId == "plate_index" then return true end
    if partId:match("^extra_%d+$") then return true end

    local modType = tonumber(partId:match("^mod_(%-?%d+)$"))
    if not modType then return false end

    return SIMPLE_BODYWORK_MODS[modType] == true
end

-- ── Panel Removal & Armor Cut Helpers ────────────────

local function detachVehiclePanel(vehicle, panelInfo)
    local doorIdx = panelInfo.doorIndex
    SetVehicleDoorCanBreak(vehicle, doorIdx, true)

    if doorIdx == 4 or doorIdx == 5 then
        SetVehicleDoorOpen(vehicle, doorIdx, false, true)
        Wait(200)
    end

    SetVehicleDoorBroken(vehicle, doorIdx, true)
end

local function findNearestRemovablePanel(vehicle, pedCoords)
    local bestPanel = nil
    local shortestDist = math.huge

    for _, panel in ipairs(REMOVABLE_PANELS) do
        local boneIdx = GetEntityBoneIndexByName(vehicle, panel.bone)
        if boneIdx ~= -1 and not IsVehicleDoorDamaged(vehicle, panel.doorIndex) then
            local bonePos = GetWorldPositionOfEntityBone(vehicle, boneIdx)
            local dist = #(pedCoords - bonePos)
            if dist < shortestDist then
                shortestDist = dist
                bestPanel = {
                    key = panel.key,
                    doorIndex = panel.doorIndex,
                    coords = bonePos
                }
            end
        end
    end

    if not bestPanel then
        print("[sky_mechanicjob][orders][armor] grinder failed: no removable target found")
        return nil, {
            key = "radial.errors.generic",
            fallback = tuningLocales.ArmorInstallNoTarget or "No removable door, hood, or trunk found nearby.",
            messageType = "error"
        }
    end

    if shortestDist > ARMOR_CUT_RADIUS then
        print(string.format("[sky_mechanicjob][orders][armor] grinder failed: nearest panel too far (distance=%.2f max=%.2f)", shortestDist, ARMOR_CUT_RADIUS))
        return nil, {
            key = "radial.errors.generic",
            fallback = tuningLocales.ArmorInstallTooFar or "Move closer to the door, hood, or trunk you want to cut.",
            messageType = "error"
        }
    end

    return bestPanel
end

-- ── Armor Cut & Install Actions ──────────────────────

function runArmorPanelCutStep(vehicle, partData)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][orders][armor] grinder failed: vehicle is missing")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.")
        }
    end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        print("[sky_mechanicjob][orders][armor] grinder failed: player is inside a vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle.")
        }
    end

    local partId = tostring((partData and partData.id) or "")
    if partId ~= ARMOR_MOD_KEY then
        print("[sky_mechanicjob][orders][armor] grinder failed: order part is not armor")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle.")
        }
    end

    local panel, err = findNearestRemovablePanel(vehicle, GetEntityCoords(ped))
    if not panel then return false, err end

    local animOk, animErr = runSimpleBodyworkWeldingInstallAnim(vehicle, partData)
    if not animOk then return false, animErr end

    detachVehiclePanel(vehicle, panel)
    return true
end

function runSimpleBodyworkWeldingInstallAnim(vehicle, partData)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][orders] welding install failed: vehicle is missing")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.")
        }
    end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        print("[sky_mechanicjob][orders] welding install failed: player is inside a vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle.")
        }
    end

    local function cleanupWeldingAnim()
        stopNonMinigameInstallProgress()
        ClearPedTasksImmediately(ped)
        ClearPedTasks(ped)
    end

    local targetCoords, maxDist = nil, nil
    if type(getBodyworkInstallTargetCoords) == "function" then
        targetCoords, maxDist = getBodyworkInstallTargetCoords(vehicle, partData)
    end

    if targetCoords then
        local pedCoords = GetEntityCoords(ped)
        local limit = tonumber(maxDist) or ARMOR_CUT_RADIUS
        local dist = #(pedCoords - targetCoords)

        if dist > limit then
            print(string.format("[sky_mechanicjob][orders] welding install failed: install target too far (distance=%.2f max=%.2f)", dist, limit))
            return false, {
                key = "radial.errors.generic",
                fallback = tuningLocales.BodyworkInstallTooFar or "Move closer to the part's install position.",
                messageType = "error"
            }
        end
    end

    if targetCoords then
        TaskTurnPedToFaceCoord(ped, targetCoords.x, targetCoords.y, targetCoords.z, 700)
    else
        TaskTurnPedToFaceEntity(ped, vehicle, 700)
    end

    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_WELDING", 0, true)

    local duration = startNonMinigameInstallProgress(
        getNuiLocale("tablet.orders.installing", "Installing part"),
        getNonMinigameInstallDurationMs()
    )

    Wait(duration)
    cleanupWeldingAnim()
    return true
end

function runSimpleHoodInstallAnim(vehicle, partData)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][orders] hood install failed: vehicle is missing")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.")
        }
    end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        print("[sky_mechanicjob][orders] hood install failed: player is inside a vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle.")
        }
    end

    TaskTurnPedToFaceEntity(ped, vehicle, 700)
    Sky.Load.AnimDict(ANIM_REPAIR_DICT)
    TaskPlayAnim(ped, ANIM_REPAIR_DICT, ANIM_REPAIR_CLIP, 8.0, -8.0, -1, 1, 0.0, false, false, false)

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

function runWheelBrakeInstallAnim(vehicle, partData)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][orders] brake install failed: vehicle is missing")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.")
        }
    end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        print("[sky_mechanicjob][orders] brake install failed: player is inside a vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle.")
        }
    end

    TaskTurnPedToFaceEntity(ped, vehicle, 700)

    local pedCoords = GetEntityCoords(ped)
    local vehCoords = GetEntityCoords(vehicle)
    local heading = GetHeadingFromVector_2d(vehCoords.x - pedCoords.x, vehCoords.y - pedCoords.y)
    SetEntityHeading(ped, (heading + 180.0) % 360.0)

    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_VEHICLE_MECHANIC", 0, true)

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

function restoreArmorPanelAfterInstall(vehicle, partData)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][orders][armor] restore failed: vehicle is missing")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.")
        }
    end

    local partId = tostring((partData and partData.id) or "")
    if partId ~= ARMOR_MOD_KEY then
        print("[sky_mechanicjob][orders][armor] restore failed: order part is not armor")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle.")
        }
    end

    local bodyH = GetVehicleBodyHealth(vehicle)
    local engineH = GetVehicleEngineHealth(vehicle)
    local tankH = GetVehiclePetrolTankHealth(vehicle)
    local dirt = GetVehicleDirtLevel(vehicle)

    SetVehicleFixed(vehicle)
    SetVehicleBodyHealth(vehicle, bodyH)
    SetVehicleEngineHealth(vehicle, engineH)
    SetVehiclePetrolTankHealth(vehicle, tankH)
    SetVehicleDirtLevel(vehicle, dirt)

    return true
end

local function isEngineHoodOpen(vehicle)
    if not HasVehicleHood(vehicle) then return true end
    if IsVehicleDoorDamaged(vehicle, 4) then return true end
    return GetVehicleDoorAngleRatio(vehicle, 4) > HOOD_ANGLE_THRESHOLD
end

-- ── Animation Control During Minigames ───────────────

local function startEngineSwapAnim()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
    if IsPedInAnyVehicle(ped, false) then return end

    if IsEntityPlayingAnim(ped, "anim@heists@box_carry@", "idle", 3) then
        StopAnimTask(ped, "anim@heists@box_carry@", "idle", 2.0)
    end

    ClearPedSecondaryTask(ped)
    Sky.Load.AnimDict(ANIM_REPAIR_DICT)
    TaskPlayAnim(ped, ANIM_REPAIR_DICT, ANIM_REPAIR_CLIP, 8.0, -8.0, -1, 1, 0.0, false, false, false)
end

local function stopEngineSwapAnim()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
    if IsPedInAnyVehicle(ped, false) then return end

    if IsEntityPlayingAnim(ped, ANIM_REPAIR_DICT, ANIM_REPAIR_CLIP, 3) then
        StopAnimTask(ped, ANIM_REPAIR_DICT, ANIM_REPAIR_CLIP, 1.0)
    end

    ClearPedTasksImmediately(ped)
    ClearPedSecondaryTask(ped)
end

-- ── Engine Swap Minigame ─────────────────────────────

function runEngineSwapInstallMinigame(vehicle, partData)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][engine_swap] failed: vehicle is missing")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available."),
            messageType = "error"
        }
    end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        print("[sky_mechanicjob][engine_swap] failed: player is inside a vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.EngineSwapMinigameFailed or "Engine swap minigame failed.",
            messageType = "error"
        }
    end

    if not isEngineHoodOpen(vehicle) then
        print("[sky_mechanicjob][engine_swap] failed: hood is not open")
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.EngineSwapHoodClosed or "Open the hood from the radial menu before swapping the engine.",
            messageType = "error"
        }
    end

    TaskTurnPedToFaceEntity(ped, vehicle, 700)
    startEngineSwapAnim()

    local sessionOk, session = TuningMinigames.StartSession("engine_swap", {
        state = EngineSwapMinigameState,
        timeoutMs = MINIGAME_TIMEOUT_MS,
        busyError = {
            key = "radial.errors.generic",
            fallback = tuningLocales.EngineSwapMinigameBusy or "Engine swap minigame is already running.",
            messageType = "error"
        }
    })

    if not sessionOk then
        stopEngineSwapAnim()
        return false, session
    end

    local token = session.token
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = "engineSwap:minigame:start",
        payload = {
            token = token,
            tubeCount = 6
        }
    })

    local result = Citizen.Await(session.promise)

    stopEngineSwapAnim()
    releaseNuiFocus()
    closeEngineSwapMinigameUi()

    local wasSuccess = result and result.success == true
    local wasCancelled = result and result.cancelled == true

    if wasSuccess then
        if not IsVehicleDoorDamaged(vehicle, 4) then
            SetVehicleDoorShut(vehicle, 4, false)
        end
        return true
    end

    if wasCancelled then
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.EngineSwapMinigameCanceled or "Engine swap canceled.",
            messageType = "info"
        }
    end

    return false, {
        key = "radial.errors.generic",
        fallback = tuningLocales.EngineSwapMinigameFailed or "Engine swap minigame failed.",
        messageType = "error"
    }
end

TuningMinigames.Register("engine_swap", runEngineSwapInstallMinigame)
