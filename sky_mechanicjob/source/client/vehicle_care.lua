if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/vehicle_care.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_mechanicjob · source/client/vehicle_care.lua
--  Deobfuscated & Cleaned
-- =====================================================

local REPAINT_MINIGAME_MAX_DISTANCE = REPAINT_MINIGAME_MAX_DISTANCE or 5.5
local REPAINT_MINIGAME_MIN_DISTANCE = REPAINT_MINIGAME_MIN_DISTANCE or 1.2
local REPAINT_MINIGAME_SECTOR_COUNT = REPAINT_MINIGAME_SECTOR_COUNT or 16
local REPAINT_MINIGAME_REQUIRED_SECTORS = REPAINT_MINIGAME_REQUIRED_SECTORS or 12
local SEARCH_RADIUS = 6.0

local ANIM_WASH_DICT = "amb@world_human_maid_clean@"
local ANIM_WASH_NAME = "base"
local PROP_SPONGE_MODEL = "prop_sponge_01"
local PROP_SPONGE_ATTACH = { bone = 28422, x = 0.0, y = 0.0, z = -0.01, rx = 90.0, ry = 0.0, rz = 0.0 }

local PTFX_SOAP_ASSET = "scr_carwash"
local PTFX_SOAP_EFFECT = "ent_amb_car_wash_jet_soap"
local PTFX_SOAP_SCALE = 0.55

local PROP_WAX_MODEL = "prop_blox_spray"
local PROP_WAX_ATTACH = { bone = 26611, x = 0.075, y = -0.14, z = 0.01, rx = -90.0, ry = 180.0, rz = 0.0 }
local PTFX_SPRAY_ASSET = "scr_playerlamgraff"
local PTFX_SPRAY_EFFECT = "scr_lamgraff_paint_spray"
local PTFX_SPRAY_BONE = 26611
local PTFX_SPRAY_OFFSET = { x = 0.1, y = 0.02, z = -0.1 }
local PTFX_SPRAY_ROT = { x = 0.0, y = 0.0, z = 90.0 }
local PTFX_SPRAY_SCALE = 0.8

VehicleCareWaxState = VehicleCareWaxState or { activeByPlate = {} }

-- ── Helpers ──────────────────────────────────────────

local function normalizePlate(plate)
    local trimmed = Sky.Math.Trim(tostring(plate or ""))
    return (trimmed ~= "") and string.upper(trimmed) or ""
end

local function findNearbyVehicle()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = getClosestVehicleWithPoliceFallback(coords.x, coords.y, coords.z, SEARCH_RADIUS, 0, 70)

    if vehicle == 0 or not DoesEntityExist(vehicle) then return 0 end
    return vehicle
end

local function stopCareAnimations()
    stopRepaintPointing()
    ClearPedSecondaryTask(PlayerPedId())
    releaseOrderHeldProp()
end

local function attachCareProp(modelName, attachConfig)
    releaseOrderHeldProp()
    local modelHash = GetHashKey(modelName)

    if not requestModelLoaded(modelHash, 2500) then
        print(string.format("[sky_mechanicjob][vehicle_care] failed: model could not be loaded (%s)", modelName))
        return false
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local propObj = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)

    AttachEntityToEntity(
        propObj, ped,
        GetPedBoneIndex(ped, attachConfig.bone),
        attachConfig.x, attachConfig.y, attachConfig.z,
        attachConfig.rx, attachConfig.ry, attachConfig.rz,
        true, true, false, true, 1, true
    )

    SetModelAsNoLongerNeeded(modelHash)
    OrderInstallState.heldProp = propObj
    return true
end

local function startCareAnimation(mode)
    if mode == "wash" then
        if not attachCareProp(PROP_SPONGE_MODEL, PROP_SPONGE_ATTACH) then return false end
        stopRepaintPointing()

        if not requestAnimDictLoaded(ANIM_WASH_DICT, 2500) then
            print(string.format("[sky_mechanicjob][vehicle_care] failed: wash anim dict not loaded (%s)", ANIM_WASH_DICT))
            return false
        end

        TaskPlayAnim(PlayerPedId(), ANIM_WASH_DICT, ANIM_WASH_NAME, 4.0, -4.0, -1, 49, 0.0, false, false, false)
        return true
    end

    if not attachCareProp(PROP_WAX_MODEL, PROP_WAX_ATTACH) then return false end
    return startRepaintPointing()
end

local function startCareParticleEffect(mode)
    local asset = (mode == "wash") and PTFX_SOAP_ASSET or PTFX_SPRAY_ASSET
    local effect = (mode == "wash") and PTFX_SOAP_EFFECT or PTFX_SPRAY_EFFECT
    local scale = (mode == "wash") and PTFX_SOAP_SCALE or PTFX_SPRAY_SCALE

    if not requestPtfxAssetLoaded(asset, 2500) then return 0 end
    if mode == "wax" then return 0 end

    local targetEnt = OrderInstallState.heldProp
    if targetEnt == 0 or not DoesEntityExist(targetEnt) then
        targetEnt = PlayerPedId()
    end

    UseParticleFxAssetNextCall(asset)
    return StartParticleFxLoopedOnEntity(effect, targetEnt, 0.08, 0.0, 0.0, 0.0, 0.0, 0.0, scale, false, false, false)
end

local function spawnWaxBurstPtfx()
    if not HasNamedPtfxAssetLoaded(PTFX_SPRAY_ASSET) then return end

    local ped = PlayerPedId()
    local boneIdx = GetPedBoneIndex(ped, PTFX_SPRAY_BONE)

    UseParticleFxAssetNextCall(PTFX_SPRAY_ASSET)
    local handle = StartParticleFxLoopedOnEntityBone(
        PTFX_SPRAY_EFFECT, ped,
        PTFX_SPRAY_OFFSET.x, PTFX_SPRAY_OFFSET.y, PTFX_SPRAY_OFFSET.z,
        PTFX_SPRAY_ROT.x, PTFX_SPRAY_ROT.y, PTFX_SPRAY_ROT.z,
        boneIdx, PTFX_SPRAY_SCALE, false, false, false
    )

    if handle and handle ~= 0 then
        SetParticleFxLoopedColour(handle, 1.0, 1.0, 1.0, 0)
        SetParticleFxLoopedAlpha(handle, 0.35)
        SetTimeout(240, function()
            StopParticleFxLooped(handle, false)
        end)
    end
end

-- ── Minigame Update / Runner ─────────────────────────

local function sendMinigameUpdate(mode, progress, visited, total)
    SendNUIMessage({
        action = "repaint:minigame:update",
        payload = {
            mode = mode,
            stage = mode,
            progress = progress,
            visited = visited,
            total = total
        }
    })
end

local function runCareMinigame(mode, vehicle)
    if RepaintMinigameState.active then
        return false, tuningLocales.VehicleCareBusy or "A vehicle care action is already running."
    end

    local dirtLevel = GetVehicleDirtLevel(vehicle)
    if mode == "wash" and dirtLevel <= 0.05 then
        return false, tuningLocales.VehicleCareAlreadyClean or "This vehicle is already clean."
    end

    if mode == "wax" and dirtLevel > 0.05 then
        return false, tuningLocales.VehicleCareWaxNeedsClean or "Wash the vehicle before applying wax."
    end

    if not requestVehicleControl(vehicle, 700) then
        print("[sky_mechanicjob][vehicle_care] failed: no entity control for target vehicle")
        return false, tuningLocales.VehicleCareControlFailed or "Unable to work on this vehicle right now."
    end

    RepaintMinigameState.active = true
    RepaintMinigameState.token = RepaintMinigameState.token + 1
    RepaintMinigameState.resolved = false
    RepaintMinigameState.success = false
    RepaintMinigameState.cancelled = false

    releaseNuiFocus()

    local token = RepaintMinigameState.token
    local visitedSectors = {}
    local visitedCount = 0
    local targetSectors = math.min(REPAINT_MINIGAME_SECTOR_COUNT, REPAINT_MINIGAME_REQUIRED_SECTORS)
    local lastBurstAt = 0

    local ptfxHandle = 0
    if startCareAnimation(mode) then
        ptfxHandle = startCareParticleEffect(mode)
        SendNUIMessage({
            action = "repaint:minigame:start",
            payload = {
                token = token,
                mode = mode,
                stage = mode,
                progress = 0,
                visited = 0,
                total = targetSectors
            }
        })
    else
        RepaintMinigameState.resolved = true
    end

    while RepaintMinigameState.active and not RepaintMinigameState.resolved do
        Wait(0)

        if vehicle == 0 or not DoesEntityExist(vehicle) then
            RepaintMinigameState.resolved = true
            RepaintMinigameState.success = false
            break
        end

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            RepaintMinigameState.resolved = true
            RepaintMinigameState.success = false
            break
        end

        if mode == "wax" then
            updateRepaintPointing()
            local now = GetGameTimer()
            if now - lastBurstAt >= 180 then
                spawnWaxBurstPtfx()
                lastBurstAt = now
            end
        end

        if IsControlJustPressed(0, 202) or IsControlJustPressed(0, 200) then
            RepaintMinigameState.resolved = true
            RepaintMinigameState.success = false
            RepaintMinigameState.cancelled = true
            break
        end

        local pedCoords = GetEntityCoords(ped)
        local vehCoords = GetEntityCoords(vehicle)
        local dist = #(pedCoords - vehCoords)

        if dist > REPAINT_MINIGAME_MAX_DISTANCE + 2.0 then
            RepaintMinigameState.resolved = true
            RepaintMinigameState.success = false
            break
        end

        if dist >= REPAINT_MINIGAME_MIN_DISTANCE and dist <= REPAINT_MINIGAME_MAX_DISTANCE then
            local dx = pedCoords.x - vehCoords.x
            local dy = pedCoords.y - vehCoords.y
            local angle = (math.atan(dy, dx) + math.pi * 2.0) % (math.pi * 2.0)
            local sector = math.floor((angle / (math.pi * 2.0)) * REPAINT_MINIGAME_SECTOR_COUNT) + 1
            if sector > REPAINT_MINIGAME_SECTOR_COUNT then sector = REPAINT_MINIGAME_SECTOR_COUNT end

            if not visitedSectors[sector] then
                visitedSectors[sector] = true
                visitedCount = visitedCount + 1
                local pct = math.max(0.0, math.min(1.0, visitedCount / targetSectors))

                if mode == "wash" then
                    SetVehicleDirtLevel(vehicle, dirtLevel * (1.0 - pct))
                else
                    SetVehicleDirtLevel(vehicle, 0.0)
                end

                sendMinigameUpdate(mode, math.floor(pct * 100), math.min(visitedCount, targetSectors), targetSectors)

                if pct >= 1.0 then
                    RepaintMinigameState.resolved = true
                    RepaintMinigameState.success = true
                end
            end
        end
    end

    if ptfxHandle ~= 0 then
        StopParticleFxLooped(ptfxHandle, false)
    end

    stopCareAnimations()

    local wasSuccess = RepaintMinigameState.resolved and RepaintMinigameState.success
    local wasCancelled = RepaintMinigameState.cancelled

    RepaintMinigameState.active = false
    RepaintMinigameState.resolved = true
    RepaintMinigameState.success = false
    RepaintMinigameState.cancelled = false

    closeRepaintMinigameUi()

    if wasSuccess then
        return true, nil, dirtLevel
    end

    if mode == "wash" then
        SetVehicleDirtLevel(vehicle, dirtLevel)
    end

    if wasCancelled then
        return false, tuningLocales.VehicleCareCanceled or "Vehicle care canceled.", dirtLevel
    end

    return false, tuningLocales.VehicleCareFailed or "Vehicle care failed.", dirtLevel
end

-- ── Wax Application Persistence ──────────────────────

local function applyWaxToVehicle(vehicle, addedKm)
    local plate = normalizePlate(GetVehicleNumberPlateText(vehicle))
    if plate == "" then
        print("[sky_mechanicjob][vehicle_care] failed: wax target plate is empty")
        return
    end

    local mileage = exports[GetCurrentResourceName()]:GetVehicleMileage(vehicle) or 0
    local kmAdd = math.max(1, tonumber(addedKm) or 35)

    VehicleCareWaxState.activeByPlate[plate] = mileage + kmAdd
    SetVehicleDirtLevel(vehicle, 0.0)
end

-- ── Non-Minigame Repair Action ───────────────────────

local function getRepairDuration()
    local cfg = (Config.VehicleCare and Config.VehicleCare.repair) or {}
    return math.max(1000, math.floor(tonumber(cfg.durationMs) or 10000))
end

local function runRepairCareAction(vehicle)
    if not requestVehicleControl(vehicle, 700) then
        print("[sky_mechanicjob][vehicle_care] repair failed: no entity control for target vehicle")
        return false, tuningLocales.VehicleCareControlFailed or "Unable to work on this vehicle right now."
    end

    local ped = PlayerPedId()
    local vehCoords = GetEntityCoords(vehicle)
    local pedCoords = GetEntityCoords(ped)

    local heading = GetHeadingFromVector_2d(vehCoords.x - pedCoords.x, vehCoords.y - pedCoords.y)
    SetEntityHeading(ped, heading)

    if requestAnimDictLoaded(ANIM_WASH_DICT, 2500) then
        TaskPlayAnim(ped, ANIM_WASH_DICT, "fixing_a_ped", 4.0, -4.0, -1, 1, 0.0, false, false, false)
    else
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_VEHICLE_MECHANIC", 0, true)
    end

    local duration = startNonMinigameInstallProgress(
        tuningLocales.VehicleRepairProgress or "Repairing vehicle",
        getRepairDuration()
    )

    local expiresAt = GetGameTimer() + duration

    while GetGameTimer() < expiresAt do
        Wait(0)

        if vehicle == 0 or not DoesEntityExist(vehicle) then
            stopNonMinigameInstallProgress()
            ClearPedTasks(ped)
            return false, tuningLocales.VehicleCareFailed or "Vehicle care failed."
        end

        if IsPedInAnyVehicle(ped, false) then
            stopNonMinigameInstallProgress()
            ClearPedTasks(ped)
            return false, tuningLocales.VehicleCareLeaveVehicle or "Leave the vehicle before using this item."
        end

        local dist = #(GetEntityCoords(ped) - GetEntityCoords(vehicle))
        if dist > SEARCH_RADIUS + 2.0 then
            stopNonMinigameInstallProgress()
            ClearPedTasks(ped)
            return false, tuningLocales.VehicleCareFailed or "Vehicle care failed."
        end

        if IsControlJustPressed(0, 202) or IsControlJustPressed(0, 200) then
            stopNonMinigameInstallProgress()
            ClearPedTasks(ped)
            return false, tuningLocales.VehicleCareCanceled or "Vehicle care canceled."
        end
    end

    stopNonMinigameInstallProgress()
    ClearPedTasks(ped)
    return true
end

-- ── Admin Repair Action ──────────────────────────────

local function applyFullVehicleFix(vehicle)
    local cfg = (Config.VehicleCare and Config.VehicleCare.repair) or {}

    if cfg.repairVehicleDamage ~= false then
        SetVehicleFixed(vehicle)
    end

    if cfg.fixRealisticWheelDamage == true then
        local ok = exports[GetCurrentResourceName()]:FixWheelDamage(vehicle)
        if not ok then
            print("[sky_mechanicjob][vehicle_care] repair failed: realistic wheel damage reset failed")
        end
    end
end

local function resolveTargetVehicle(target)
    local veh = math.floor(tonumber(target) or 0)
    if veh ~= 0 and DoesEntityExist(veh) then return veh end

    veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 and DoesEntityExist(veh) then return veh end

    return 0
end

local function resetVehicleHandlingProperties(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    SetVehicleUndriveable(vehicle, false)
    SetVehicleReduceGrip(vehicle, false)
    SetVehicleHandbrake(vehicle, false)
    SetVehicleEngineTorqueMultiplier(vehicle, 1.0)
    SetVehicleEnginePowerMultiplier(vehicle, 0.0)
    SetEntityMaxSpeed(vehicle, 999.0)
end

local function fullAdminVehicleRepair(vehicle)
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehiclePetrolTankHealth(vehicle, 1000.0)
    resetVehicleHandlingProperties(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleDirtLevel(vehicle, 0.0)

    local numWheels = math.max(0, math.floor(tonumber(GetVehicleNumberOfWheels(vehicle)) or 0))
    for i = 0, numWheels - 1 do
        SetVehicleTyreFixed(vehicle, i)
    end

    for i = 0, 7 do
        FixVehicleWindow(vehicle, i)
        SetVehicleDoorShut(vehicle, i, false)
    end

    exports[GetCurrentResourceName()]:FixWheelDamage(vehicle)

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    SetTimeout(500, function()
        local v = vehicle
        if v == 0 or not DoesEntityExist(v) then
            if netId and netId > 0 then
                v = NetworkGetEntityFromNetworkId(netId)
            end
        end
        if v ~= 0 and DoesEntityExist(v) then
            resetVehicleHandlingProperties(v)
            SetVehicleEngineHealth(v, 1000.0)
            SetVehicleEngineOn(v, true, true, false)
        end
    end)
end

registerExport("AdminRepairVehicle", function(targetVehicle)
    local vehicle = resolveTargetVehicle(targetVehicle)
    if vehicle == 0 then return false, "no_vehicle" end

    if not requestVehicleControl(vehicle, 700) then
        print("[sky_mechanicjob][vehicle_care] admin repair failed: no entity control for target vehicle")
        return false, "control_failed"
    end

    local plate = normalizePlate(GetVehicleNumberPlateText(vehicle))
    if plate == "" then return false, "invalid_plate" end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local res = Sky.Cb.Trigger("sky_mechanicjob:wear:adminRepairVehicle", { plate = plate, vehicleNetId = netId })

    if not (type(res) == "table" and res.success) then
        local errCode = (type(res) == "table" and tostring(res.error or "repair_failed")) or "repair_failed"
        return false, errCode
    end

    fullAdminVehicleRepair(vehicle)
    return true, { vehicle = vehicle, plate = plate }
end)

-- ── Network Events ───────────────────────────────────

RegisterNetEvent("sky_mechanicjob:debug:testAdminRepairVehicle", function()
    local ok, res = exports[GetCurrentResourceName()]:AdminRepairVehicle()
    if not ok then
        Sky.Show.Notification(
            tuningLocales.Title or "Tuning",
            string.format("Admin repair test failed: %s", tostring(res or "unknown")),
            "error"
        )
        return
    end
    Sky.Show.Notification(
        tuningLocales.Title or "Tuning",
        string.format("Admin repair test completed for plate %s.", tostring(res.plate or "UNKNOWN")),
        "success"
    )
end)

RegisterNetEvent("sky_mechanicjob:admin:repairVehicle", function()
    local ok, res = exports[GetCurrentResourceName()]:AdminRepairVehicle()
    if not ok then
        local errCode = tostring(res or "unknown")
        local errMsg = tuningLocales.VehicleRepairFailed or "Vehicle repair failed."

        if errCode == "no_vehicle" then
            errMsg = tuningLocales.VehicleCareNoVehicle or "No nearby vehicle found."
        elseif errCode == "control_failed" then
            errMsg = tuningLocales.VehicleCareControlFailed or "Unable to work on this vehicle right now."
        elseif errCode == "not_authorized" then
            errMsg = tuningLocales.NoPermission or "You do not have permission to use this command."
        end

        Sky.Show.Notification(tuningLocales.Title or "Tuning", errMsg, "error")
        return
    end

    Sky.Show.Notification(
        tuningLocales.Title or "Tuning",
        string.format(tuningLocales.VehicleRepairSuccess or "Vehicle repaired: %s.", tostring(res.plate or "UNKNOWN")),
        "success"
    )
end)

RegisterNetEvent("sky_mechanicjob:vehicleCare:start", function(actionType)
    local action = tostring(actionType or "")
    if action ~= "wash" and action ~= "wax" and action ~= "repair" then
        print(string.format("[sky_mechanicjob][vehicle_care] failed: invalid action %s", action))
        return
    end

    local vehicle = findNearbyVehicle()
    if vehicle == 0 then
        Sky.Show.Notification(
            tuningLocales.Title or "Tuning",
            tuningLocales.VehicleCareNoVehicle or "No nearby vehicle found.",
            "error"
        )
        return
    end

    if IsPedInAnyVehicle(PlayerPedId(), false) then
        Sky.Show.Notification(
            tuningLocales.Title or "Tuning",
            tuningLocales.VehicleCareLeaveVehicle or "Leave the vehicle before using this item.",
            "error"
        )
        return
    end

    if action == "repair" then
        local ok, err = runRepairCareAction(vehicle)
        if not ok then
            Sky.Show.Notification(tuningLocales.Title or "Tuning", err, "error")
            return
        end

        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        if netId <= 0 then
            print("[sky_mechanicjob][vehicle_care] repair failed: vehicle has no network id")
            Sky.Show.Notification(
                tuningLocales.Title or "Tuning",
                tuningLocales.VehicleCareFailed or "Vehicle care failed.",
                "error"
            )
            return
        end

        local plate = normalizePlate(GetVehicleNumberPlateText(vehicle))
        local res = Sky.Cb.Trigger("sky_mechanicjob:wear:completeRepairInstall", {
            plate = plate,
            part = "repair_kit",
            vehicleNetId = netId
        })

        if type(res) == "table" and res.success then
            applyFullVehicleFix(vehicle)
            Sky.Show.Notification(
                tuningLocales.Title or "Tuning",
                tuningLocales.VehicleRepairSuccess or "Vehicle repaired.",
                "success"
            )
        else
            Sky.Show.Notification(
                tuningLocales.Title or "Tuning",
                tuningLocales.VehicleCareFailed or "Vehicle care failed.",
                "error"
            )
        end
        return
    end

    local ok, err = runCareMinigame(action, vehicle)
    if not ok then
        Sky.Show.Notification(tuningLocales.Title or "Tuning", err, "error")
        return
    end

    if action == "wax" then
        applyWaxToVehicle(vehicle, 35)
        Sky.Show.Notification(
            tuningLocales.Title or "Tuning",
            tuningLocales.VehicleCareWaxSuccess or "Vehicle waxed.",
            "success"
        )
    else
        SetVehicleDirtLevel(vehicle, 0.0)
        Sky.Show.Notification(
            tuningLocales.Title or "Tuning",
            tuningLocales.VehicleCareWashSuccess or "Vehicle washed.",
            "success"
        )
    end
end)
