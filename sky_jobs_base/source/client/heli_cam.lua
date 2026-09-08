if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/heli_cam.lua") end
-- =====================================================
--  sky_jobs_base · source/client/heli_cam.lua
--  Deobfuscated & Cleaned
-- =====================================================

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}

local heliLocales = locales.HeliCam or {}
local spotLocales = heliLocales.Spotlight or {}

local function formatString(template, params)
    if type(template) ~= "string" then return "" end
    if type(params) ~= "table" then return template end

    return (template:gsub("{(.-)}", function(key)
        local val = params[key]
        if val == nil then
            return "{" .. key .. "}"
        end
        return tostring(val)
    end))
end

local config = (Config and Config.HeliCam) or {}
if config.enabled == false then return end

local DEFAULT_KEYS = {
    toggle_cam = 51,
    toggle_vision = 25,
    toggle_spotlight = 183,
    toggle_lock = 22,
    toggle_display = 44,
    rappel = 154,
    take_photo = 74,
    light_up = 246,
    light_down = 173,
    radius_up = 137,
    radius_down = 21
}

local function getKey(action)
    local cfgKeys = config.keys
    if cfgKeys and cfgKeys[action] then
        return cfgKeys[action]
    end
    return DEFAULT_KEYS[action]
end

local camConfig = config.cam or {}
local spotlightConfig = config.spotlight or {}
local captureConfig = config.capture or {}

local FOV_MIN = camConfig.fovMin or 6.0
local FOV_MAX = camConfig.fovMax or 80.0
local ZOOM_SPEED = camConfig.zoomSpeed or 3.0
local ZOOM_SMOOTH = camConfig.zoomSmooth or 0.05
local ROTATE_SPEED_X = camConfig.rotateSpeedX or 4.0
local ROTATE_SPEED_Z = camConfig.rotateSpeedZ or 4.0
local MAX_PITCH = camConfig.maxPitch or 20.0
local MIN_PITCH = camConfig.minPitch or -89.5
local MIN_HEIGHT = config.minHeight or 1.5
local MAX_LOCK_DISTANCE = config.maxLockDistance or 700.0
local REQUIRE_ON_DUTY = config.requireOnDuty ~= false

local allowedJobsMap = {}

local function buildAllowedJobsMap()
    allowedJobsMap = {}
    local jobList = config.allowedJobs or config.jobs
    if type(jobList) == "table" then
        for _, j in ipairs(jobList) do
            if type(j) == "string" and j ~= "" then
                allowedJobsMap[j] = true
            end
        end
    end
end

buildAllowedJobsMap()

local function getCurrentJobKey()
    if Sky_Jobs and Sky_Jobs.Access and type(Sky_Jobs.Access.GetJobKey) == "function" then
        return Sky_Jobs.Access.GetJobKey()
    end
    local jobState = GetJobState and GetJobState()
    return jobState and jobState.jobKey
end

local function isJobAllowed()
    if not next(allowedJobsMap) then
        return true
    end
    local jobKey = getCurrentJobKey()
    if jobKey then
        return allowedJobsMap[jobKey] == true
    end
    return false
end

local SPOT_BRIGHTNESS = spotlightConfig.brightness or 1.0
local SPOT_RADIUS = spotlightConfig.radius or 4.0
local MIN_BRIGHTNESS = spotlightConfig.minBrightness or 1.0
local MAX_BRIGHTNESS = spotlightConfig.maxBrightness or 10.0
local MIN_RADIUS = spotlightConfig.minRadius or 4.0
local MAX_RADIUS = spotlightConfig.maxRadius or 10.0
local SPOT_DISTANCE = spotlightConfig.distance or 800.0

local CAPTURE_COOLDOWN_MS = captureConfig.cooldownMs or 1500
local CAPTURE_FOLDER = captureConfig.folder or "camera"

local lastPhotoTime = 0
local isTakingPhoto = false

local SPEED_UNIT = config.speedUnit == "MPH" and "MPH" or "Km/h"
local SPEED_MULT = config.speedUnit == "MPH" and 2.236936 or 3.6

local allowedHeliModels = {}

local function buildHeliModelsMap()
    allowedHeliModels = {}
    local models = config.models or { "polmav" }
    for _, m in ipairs(models) do
        local hash = (type(m) == "number") and m or joaat(m)
        allowedHeliModels[hash] = true
    end
end

buildHeliModelsMap()

local function isAllowedHeli(vehicle)
    if not vehicle or vehicle == 0 then return false end
    return allowedHeliModels[GetEntityModel(vehicle)] == true
end

local function isPilot(ped, vehicle)
    return GetPedInVehicleSeat(vehicle, -1) == ped
end

local function isHeliHighEnough(vehicle)
    return GetEntityHeightAboveGround(vehicle) > MIN_HEIGHT
end

local function getForwardVector(rot)
    local radZ = math.rad(rot.z)
    local radX = math.rad(rot.x)
    local absCosX = math.abs(math.cos(radX))
    return vector3(
        -math.sin(radZ) * absCosX,
        math.cos(radZ) * absCosX,
        math.sin(radX)
    )
end

local function renderVehicleText(vehicle, displayMode)
    if not DoesEntityExist(vehicle) then return end

    local modelHash = GetEntityModel(vehicle)
    local modelName = GetLabelText(GetDisplayNameFromVehicleModel(modelHash))
    if modelName == "NULL" or modelName == "CARNOTFOUND" then
        modelName = "Unknown"
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local speed = math.ceil(GetEntitySpeed(vehicle) * SPEED_MULT)

    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, displayMode == 0 and 0.49 or 0.55)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")

    if displayMode == 0 then
        AddTextComponentString(string.format("Speed: %s %s\nModel: %s\nPlate: %s", speed, SPEED_UNIT, modelName, plate))
    else
        AddTextComponentString(string.format("Model: %s\nPlate: %s", modelName, plate))
    end

    DrawText(0.45, 0.9)
end

local function getTargetVehicleFromRaycast(cam)
    local camCoords = cam and GetCamCoord(cam) or GetGameplayCamCoord()
    local camRot = cam and GetCamRot(cam, 2) or GetGameplayCamRot(2)
    local forward = getForwardVector(camRot)
    local targetCoords = camCoords + (forward * 200.0)

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local ray = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, targetCoords.x, targetCoords.y, targetCoords.z, 10, vehicle, 0)
    local _, hit, _, _, entity = GetShapeTestResult(ray)

    if hit == 1 and entity ~= 0 and IsEntityAVehicle(entity) then
        return entity
    end
    return nil
end

local function rotateCam(cam, zoomRatio)
    local rx = GetDisabledControlNormal(0, 220)
    local ry = GetDisabledControlNormal(0, 221)
    if rx == 0.0 and ry == 0.0 then return end

    local rot = GetCamRot(cam, 2)
    local newZ = rot.z + (rx * -1.0 * ROTATE_SPEED_Z * (zoomRatio + 0.1))
    local newX = rot.x + (ry * -1.0 * ROTATE_SPEED_X * (zoomRatio + 0.1))

    newX = math.max(MIN_PITCH, math.min(MAX_PITCH, newX))
    SetCamRot(cam, newX, 0.0, newZ, 2)
end

local function zoomCam(cam, currentFov)
    local targetFov = currentFov
    if IsControlJustPressed(0, 241) then
        targetFov = math.max(currentFov - ZOOM_SPEED, FOV_MIN)
    elseif IsControlJustPressed(0, 242) then
        targetFov = math.min(currentFov + ZOOM_SPEED, FOV_MAX)
    end

    local actualFov = GetCamFov(cam)
    if math.abs(targetFov - actualFov) < 0.1 then
        targetFov = actualFov
    end

    local nextFov = actualFov + ((targetFov - actualFov) * ZOOM_SMOOTH)
    SetCamFov(cam, nextFov)
    return targetFov
end

local function hideHeliHudComponents()
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
    local components = { 19, 1, 2, 3, 4, 13, 11, 12, 15, 18 }
    for _, comp in ipairs(components) do
        HideHudComponentThisFrame(comp)
    end
end

local function showHeliNotification(title, message, notifyType)
    if message and message ~= "" then
        Sky.Show.Notification(title, message, notifyType or "info")
    end
end

local function getKeyLabel(actionKey)
    local cfgLabels = config.keyLabels or {}
    local label = cfgLabels[actionKey] or cfgLabels[tostring(actionKey)]
    if label then return label end

    local defaults = {
        [51] = "E", [25] = "RMB", [183] = "G", [22] = "Space",
        [44] = "Q", [154] = "X", [74] = "H", [246] = "Y",
        [173] = "Down", [137] = "Caps", [21] = "Shift"
    }
    return defaults[actionKey] or tostring(actionKey)
end

local hudState = { visible = false, signature = "" }
local isHeliSeatActive = false
local currentHeliVehicle = 0
local isResourceStopping = false

local function buildHudEntries(isCamActive)
    local entries = {
        { id = "toggleCam", key = getKeyLabel(getKey("toggle_cam")) },
        { id = "spotlight", key = getKeyLabel(getKey("toggle_spotlight")) },
        { id = "rappel", key = getKeyLabel(getKey("rappel")) }
    }

    if isCamActive then
        table.insert(entries, { id = "lockTarget", key = getKeyLabel(getKey("toggle_lock")) })
        table.insert(entries, { id = "display", key = getKeyLabel(getKey("toggle_display")) })
        table.insert(entries, { id = "takePhoto", key = getKeyLabel(getKey("take_photo")) })
        table.insert(entries, { id = "vision", key = getKeyLabel(getKey("toggle_vision")) })
        table.insert(entries, { id = "brightness", key = string.format("%s/%s", getKeyLabel(getKey("light_up")), getKeyLabel(getKey("light_down"))) })
        table.insert(entries, { id = "radius", key = string.format("%s/%s", getKeyLabel(getKey("radius_up")), getKeyLabel(getKey("radius_down"))) })
    end
    return entries
end

local function updateNuiHud(visible, isCamActive)
    local entries = buildHudEntries(isCamActive)
    local sigParts = { tostring(visible), tostring(isCamActive == true) }
    for _, e in ipairs(entries) do
        table.insert(sigParts, e.id .. ":" .. e.key)
    end
    local signature = table.concat(sigParts, "|")

    if hudState.visible == visible and hudState.signature == signature then
        return
    end

    hudState.visible = visible
    hudState.signature = signature

    SendNUIMessage({
        type = "heliCam:hud",
        data = { visible = visible, entries = entries }
    })
end

local camState = {
    active = false,
    cam = nil,
    fov = (FOV_MIN + FOV_MAX) * 0.5,
    vision = 0,
    display_mode = 0,
    locked_vehicle = nil,
    target_vehicle = nil,
    manual_spotlight = false,
    tracking_spotlight = false,
    forward_spotlight = false,
    brightness = SPOT_BRIGHTNESS,
    radius = SPOT_RADIUS
}

local function toggleVisionMode()
    if camState.vision == 0 then
        SetNightvision(true)
        camState.vision = 1
    elseif camState.vision == 1 then
        SetNightvision(false)
        SetSeethrough(true)
        camState.vision = 2
    else
        SetSeethrough(false)
        camState.vision = 0
    end
end

local function toggleDisplayMode()
    camState.display_mode = (camState.display_mode + 1) % 3
end

local function syncSpotlightSettings()
    TriggerServerEvent("sky_jobs_base:heli:spotlight:settings", camState.brightness, camState.radius)
end

local function setForwardSpotlight(enabled)
    camState.forward_spotlight = enabled == true
    TriggerServerEvent("sky_jobs_base:heli:spotlight:forward", camState.forward_spotlight)
    local title = heliLocales.Title or "Heli Cam"
    if camState.forward_spotlight then
        showHeliNotification(title, spotLocales.ForwardOn or "Searchlight on.", "success")
    else
        showHeliNotification(title, spotLocales.ForwardOff or "Searchlight off.", "info")
    end
end

local function stopTrackingSpotlight()
    if not camState.tracking_spotlight then return end
    camState.tracking_spotlight = false
    TriggerServerEvent("sky_jobs_base:heli:spotlight:tracking:stop")
    showHeliNotification(heliLocales.Title or "Heli Cam", spotLocales.TrackingOff or "Tracking spotlight off.", "info")
end

local function engageTrackingSpotlight(vehicle)
    if not (vehicle and DoesEntityExist(vehicle)) then return end
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId == 0 then return end

    local coords = GetEntityCoords(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    camState.tracking_spotlight = true

    TriggerServerEvent("sky_jobs_base:heli:spotlight:tracking", netId, plate, coords.x, coords.y, coords.z, camState.brightness, camState.radius)
    showHeliNotification(heliLocales.Title or "Heli Cam", spotLocales.TrackingOn or "Tracking spotlight engaged.", "success")
end

local function setManualSpotlight(enabled)
    camState.manual_spotlight = enabled == true
    TriggerServerEvent("sky_jobs_base:heli:spotlight:manual", camState.manual_spotlight, camState.brightness, camState.radius)
    local title = heliLocales.Title or "Heli Cam"
    if camState.manual_spotlight then
        showHeliNotification(title, spotLocales.ManualOn or "Manual spotlight engaged.", "success")
    else
        showHeliNotification(title, spotLocales.ManualOff or "Manual spotlight off.", "info")
    end
end

local function releaseTargetLock(isTargetLost)
    local hadLock = camState.locked_vehicle ~= nil
    camState.locked_vehicle = nil
    camState.target_vehicle = nil

    if camState.cam then
        StopCamPointing(camState.cam)
    end
    stopTrackingSpotlight()

    local title = heliLocales.Title or "Heli Cam"
    if isTargetLost then
        showHeliNotification(title, heliLocales.TargetLost or "Target lost.", "warning")
    elseif hadLock then
        showHeliNotification(title, heliLocales.TargetReleased or "Target lock released.", "info")
    end
end

local function checkAuthorization()
    if not isJobAllowed() then
        showHeliNotification(heliLocales.Title or "Heli Cam", heliLocales.NotAuthorized or "You are not authorized to use the heli cam.", "error")
        return false
    end

    if not REQUIRE_ON_DUTY then return true end

    local isOnDuty = Sky_Jobs and Sky_Jobs.Access and Sky_Jobs.Access.IsOnDuty and Sky_Jobs.Access.IsOnDuty()
    if isOnDuty then return true end

    showHeliNotification(heliLocales.Title or "Heli Cam", heliLocales.NotOnDuty or "You must be on duty to use the heli cam.", "error")
    return false
end

local function toggleSpotlightAction(ped, vehicle)
    if not isPilot(ped, vehicle) then return end
    if not checkAuthorization() then return end

    if camState.manual_spotlight then
        setManualSpotlight(false)
        return
    end
    if camState.tracking_spotlight then
        stopTrackingSpotlight()
        return
    end
    if camState.forward_spotlight then
        setForwardSpotlight(false)
        return
    end
    if camState.locked_vehicle then
        engageTrackingSpotlight(camState.locked_vehicle)
        return
    end
    setForwardSpotlight(true)
end

local function adjustBrightness(delta)
    local newVal = math.min(MAX_BRIGHTNESS, math.max(MIN_BRIGHTNESS, camState.brightness + delta))
    if math.abs(newVal - camState.brightness) < 0.01 then return end

    camState.brightness = newVal
    syncSpotlightSettings()
    local text = formatString(spotLocales.Brightness or "Spotlight brightness: {value}", { value = string.format("%.1f", camState.brightness) })
    showHeliNotification(heliLocales.Title or "Heli Cam", text, "info")
end

local function adjustRadius(delta)
    local newVal = math.min(MAX_RADIUS, math.max(MIN_RADIUS, camState.radius + delta))
    if math.abs(newVal - camState.radius) < 0.01 then return end

    camState.radius = newVal
    syncSpotlightSettings()
    local text = formatString(spotLocales.Radius or "Spotlight radius: {value}", { value = string.format("%.1f", camState.radius) })
    showHeliNotification(heliLocales.Title or "Heli Cam", text, "info")
end

local function buildCaptureMetadata(targetVehicle)
    local meta = {
        name = "Heli Cam Capture",
        description = "Helicopter surveillance capture."
    }

    local target = targetVehicle or (camState.locked_vehicle and DoesEntityExist(camState.locked_vehicle) and camState.locked_vehicle)
    if target and DoesEntityExist(target) then
        local plate = GetVehicleNumberPlateText(target)
        local modelHash = GetEntityModel(target)
        local modelName = GetLabelText(GetDisplayNameFromVehicleModel(modelHash))
        if modelName == "NULL" or modelName == "CARNOTFOUND" then
            modelName = "Unknown"
        end
        local speed = math.ceil(GetEntitySpeed(target) * SPEED_MULT)
        meta.description = string.format("%s | %s | %s | %s %s", meta.description, modelName, plate, speed, SPEED_UNIT)
    end

    return meta
end

local function takeHeliPhoto()
    local now = GetGameTimer()
    if isTakingPhoto or (now - lastPhotoTime) < CAPTURE_COOLDOWN_MS then return end

    lastPhotoTime = now
    isTakingPhoto = true

    local target = camState.active and camState.cam and getTargetVehicleFromRaycast(camState.cam)
    local metadata = buildCaptureMetadata(target)

    CreateThread(function()
        local res = Sky.Cb.Trigger("sky_jobs_base:camera:takePhoto", {
            metadata = metadata,
            folder = CAPTURE_FOLDER
        })

        local title = heliLocales.Title or "Heli Cam"
        if not (res and res.success) then
            showHeliNotification(title, heliLocales.PhotoFailed or "Unable to save heli photo.", "error")
        elseif heliLocales.PhotoSaved then
            showHeliNotification(title, heliLocales.PhotoSaved, "success")
        end
        isTakingPhoto = false
    end)
end

local function rappelFromHeli(ped, vehicle)
    if not isHeliHighEnough(vehicle) then return end

    local seat1Ped = GetPedInVehicleSeat(vehicle, 1)
    local seat2Ped = GetPedInVehicleSeat(vehicle, 2)
    local isSeat1 = (seat1Ped == ped)
    local isSeat2 = (seat2Ped == ped)

    local title = heliLocales.Title or "Heli Cam"
    if isSeat1 or isSeat2 then
        TaskRappelFromHeli(ped, 1)
        showHeliNotification(title, heliLocales.RappelStarted or "Rappel initiated.", "info")
    else
        showHeliNotification(title, heliLocales.RappelDenied or "You can't rappel from this seat.", "error")
    end
end

local function disableHeliCam()
    camState.active = false
    TriggerEvent("sky_jobs_base:helicam", false)

    if camState.manual_spotlight then
        setManualSpotlight(false)
    end

    ClearTimecycleModifier()
    RenderScriptCams(false, false, 0, true, true)

    if camState.cam and DoesCamExist(camState.cam) then
        DestroyCam(camState.cam, false)
    end
    camState.cam = nil

    camState.fov = (FOV_MIN + FOV_MAX) * 0.5
    SetNightvision(false)
    SetSeethrough(false)

    showHeliNotification(heliLocales.Title or "Heli Cam", heliLocales.CamDisabled or "Heli cam disabled.", "info")

    if isHeliSeatActive then
        updateNuiHud(true, false)
    end
end

local function enableHeliCam()
    if camState.active then return end

    if camState.forward_spotlight then setForwardSpotlight(false) end
    if camState.tracking_spotlight then stopTrackingSpotlight() end
    if camState.manual_spotlight then setManualSpotlight(false) end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if not isAllowedHeli(veh) then return end

    if not isHeliHighEnough(veh) then
        showHeliNotification(heliLocales.Title or "Heli Cam", heliLocales.TooLow or "Helicopter is too low to activate the camera.", "error")
        return
    end

    if not checkAuthorization() then return end

    camState.active = true
    TriggerEvent("sky_jobs_base:helicam", true)
    camState.vision = 0
    camState.fov = (FOV_MIN + FOV_MAX) * 0.5

    SetTimecycleModifier("heliGunCam")
    SetTimecycleModifierStrength(0.3)

    local scaleform = RequestScaleformMovie("HELI_CAM")
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end

    local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
    camState.cam = cam
    AttachCamToEntity(cam, veh, 0.0, 0.0, -1.5, true)
    SetCamRot(cam, 0.0, 0.0, GetEntityHeading(veh), 2)
    SetCamFov(cam, camState.fov)
    RenderScriptCams(true, false, 0, true, true)

    PushScaleformMovieFunction(scaleform, "SET_CAM_LOGO")
    PushScaleformMovieFunctionParameterInt(0)
    PopScaleformMovieFunctionVoid()

    showHeliNotification(heliLocales.Title or "Heli Cam", heliLocales.CamEnabled or "Heli cam enabled.", "success")

    if isHeliSeatActive then
        updateNuiHud(true, true)
    end

    CreateThread(function()
        local nextLockCheck = 0
        while camState.active do
            if isResourceStopping then break end

            local playerPed = PlayerPedId()
            local currentVeh = GetVehiclePedIsIn(playerPed, false)
            if currentVeh == 0 or currentVeh ~= veh or IsEntityDead(playerPed) or not isHeliHighEnough(veh) then
                break
            end

            if IsControlJustPressed(0, getKey("toggle_cam")) then break end
            if IsControlJustPressed(0, getKey("toggle_vision")) then toggleVisionMode() end
            if IsControlJustPressed(0, getKey("toggle_spotlight")) then toggleSpotlightAction(playerPed, veh) end
            if IsControlJustPressed(0, getKey("toggle_display")) then toggleDisplayMode() end
            if IsControlJustPressed(0, getKey("take_photo")) then takeHeliPhoto() end
            if IsControlJustPressed(0, getKey("light_up")) then adjustBrightness(1.0) end
            if IsControlJustPressed(0, getKey("light_down")) then adjustBrightness(-1.0) end
            if IsControlJustPressed(0, getKey("radius_up")) then adjustRadius(1.0) end
            if IsControlJustPressed(0, getKey("radius_down")) then adjustRadius(-1.0) end

            local zoomRatio = (camState.fov - FOV_MIN) / (FOV_MAX - FOV_MIN)
            local vehPos = GetEntityCoords(veh)

            if camState.locked_vehicle then
                if DoesEntityExist(camState.locked_vehicle) then
                    PointCamAtEntity(camState.cam, camState.locked_vehicle, 0.0, 0.0, 0.0, true)
                    renderVehicleText(camState.locked_vehicle, camState.display_mode)
                    local targetPos = GetEntityCoords(camState.locked_vehicle)
                    local dist = #(vehPos - targetPos)

                    if IsControlJustPressed(0, getKey("toggle_lock")) or dist > MAX_LOCK_DISTANCE then
                        releaseTargetLock(dist > MAX_LOCK_DISTANCE)
                    end
                end
            else
                rotateCam(camState.cam, zoomRatio)
                local rayTarget = getTargetVehicleFromRaycast(camState.cam)
                if rayTarget and DoesEntityExist(rayTarget) then
                    renderVehicleText(rayTarget, camState.display_mode)
                    if IsControlJustPressed(0, getKey("toggle_lock")) then
                        camState.locked_vehicle = rayTarget
                        camState.target_vehicle = rayTarget
                        showHeliNotification(heliLocales.Title or "Heli Cam", heliLocales.TargetLocked or "Target locked.", "success")
                        if camState.tracking_spotlight then
                            stopTrackingSpotlight()
                            engageTrackingSpotlight(rayTarget)
                        end
                    end
                end
            end

            camState.fov = zoomCam(camState.cam, camState.fov)
            hideHeliHudComponents()

            PushScaleformMovieFunction(scaleform, "SET_ALT_FOV_HEADING")
            PushScaleformMovieFunctionParameterFloat(vehPos.z)
            PushScaleformMovieFunctionParameterFloat(zoomRatio)
            PushScaleformMovieFunctionParameterFloat(GetCamRot(camState.cam, 2).z)
            PopScaleformMovieFunctionVoid()

            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)

            if camState.manual_spotlight then
                local camRot = GetCamRot(camState.cam, 2)
                local forward = getForwardVector(camRot)
                local camCoords = GetCamCoord(camState.cam)
                DrawSpotLight(camCoords.x, camCoords.y, camCoords.z, forward.x, forward.y, forward.z, 255, 255, 255, SPOT_DISTANCE, 10.0, camState.brightness, camState.radius, 1.0, 1.0)
                DecorSetFloat(veh, "sky_heli_spot_x", forward.x)
                DecorSetFloat(veh, "sky_heli_spot_y", forward.y)
                DecorSetFloat(veh, "sky_heli_spot_z", forward.z)
            else
                DecorSetFloat(veh, "sky_heli_spot_x", 0.0)
                DecorSetFloat(veh, "sky_heli_spot_y", 0.0)
                DecorSetFloat(veh, "sky_heli_spot_z", 0.0)
            end

            Wait(0)
        end

        SetScaleformMovieAsNoLongerNeeded(scaleform)
        if not isResourceStopping then
            disableHeliCam()
        end
    end)
end

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(0) end
    DecorRegister("sky_heli_spot_x", 1)
    DecorRegister("sky_heli_spot_y", 1)
    DecorRegister("sky_heli_spot_z", 1)
end)

local trackingSpotlightsServer = {}
local manualSpotlightsServer = {}

local function findVehicleByNetIdOrPlate(netId, plate, coords)
    if netId and netId ~= 0 then
        local veh = NetToVeh(netId)
        if veh and veh ~= 0 and DoesEntityExist(veh) then
            return veh
        end
    end
    if coords and plate then
        local veh = GetClosestVehicle(coords.x, coords.y, coords.z, 30.0, 0, 70)
        if veh ~= 0 and GetVehicleNumberPlateText(veh) == plate then
            return veh
        end
    end
    return nil
end

local function getTargetPlayerPedAndVehicle(serverId)
    local idx = GetPlayerFromServerId(serverId)
    if idx == -1 then return nil, nil end
    local ped = GetPlayerPed(idx)
    if not ped or ped == 0 then return nil, nil end
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or not isAllowedHeli(veh) then return nil, nil end
    return ped, veh
end

RegisterNetEvent("sky_jobs_base:heli:spotlight:forward", function(serverId, enabled)
    local _, veh = getTargetPlayerPedAndVehicle(serverId)
    if veh then
        SetVehicleSearchlight(veh, enabled == true, false)
    end
end)

RegisterNetEvent("sky_jobs_base:heli:spotlight:tracking", function(serverId, netId, plate, x, y, z, brightness, radius)
    if trackingSpotlightsServer[serverId] then
        trackingSpotlightsServer[serverId].active = false
    end

    local data = {
        active = true,
        net_id = netId,
        plate = plate,
        coords = vector3(x, y, z),
        brightness = brightness or SPOT_BRIGHTNESS,
        radius = radius or SPOT_RADIUS
    }
    trackingSpotlightsServer[serverId] = data

    CreateThread(function()
        while trackingSpotlightsServer[serverId] and trackingSpotlightsServer[serverId].active and not isResourceStopping do
            local heliPed, heliVeh = getTargetPlayerPedAndVehicle(serverId)
            if not (heliPed and heliVeh) then break end

            local targetVeh = findVehicleByNetIdOrPlate(data.net_id, data.plate, data.coords)
            if not targetVeh then break end

            local hPos = GetEntityCoords(heliPed)
            local tPos = GetEntityCoords(targetVeh)
            local dist = #(hPos - tPos)
            if dist > MAX_LOCK_DISTANCE then break end

            local dir = tPos - hPos
            DrawSpotLight(hPos.x, hPos.y, hPos.z, dir.x, dir.y, dir.z, 255, 255, 255, dist + 20.0, 10.0, data.brightness, data.radius, 1.0, 0.0)
            Wait(0)
        end
        trackingSpotlightsServer[serverId] = nil
    end)
end)

RegisterNetEvent("sky_jobs_base:heli:spotlight:tracking:stop", function(serverId)
    if trackingSpotlightsServer[serverId] then
        trackingSpotlightsServer[serverId].active = false
    end
end)

RegisterNetEvent("sky_jobs_base:heli:spotlight:manual", function(serverId, enabled, brightness, radius)
    local myServerId = GetPlayerServerId(PlayerId())
    if serverId == myServerId then return end

    if enabled then
        if manualSpotlightsServer[serverId] then
            manualSpotlightsServer[serverId].active = false
        end

        local data = {
            active = true,
            brightness = brightness or SPOT_BRIGHTNESS,
            radius = radius or SPOT_RADIUS
        }
        manualSpotlightsServer[serverId] = data

        CreateThread(function()
            while manualSpotlightsServer[serverId] and manualSpotlightsServer[serverId].active and not isResourceStopping do
                local _, heliVeh = getTargetPlayerPedAndVehicle(serverId)
                if not heliVeh then break end

                local hPos = GetEntityCoords(heliVeh)
                local dir = vector3(
                    DecorGetFloat(heliVeh, "sky_heli_spot_x"),
                    DecorGetFloat(heliVeh, "sky_heli_spot_y"),
                    DecorGetFloat(heliVeh, "sky_heli_spot_z")
                )

                if dir.x ~= 0.0 or dir.y ~= 0.0 or dir.z ~= 0.0 then
                    DrawSpotLight(hPos.x, hPos.y, hPos.z, dir.x, dir.y, dir.z, 255, 255, 255, SPOT_DISTANCE, 10.0, data.brightness, data.radius, 1.0, 1.0)
                end
                Wait(0)
            end
            manualSpotlightsServer[serverId] = nil
        end)
    else
        if manualSpotlightsServer[serverId] then
            manualSpotlightsServer[serverId].active = false
        end
    end
end)

RegisterNetEvent("sky_jobs_base:heli:spotlight:settings", function(serverId, brightness, radius)
    if manualSpotlightsServer[serverId] then
        manualSpotlightsServer[serverId].brightness = brightness or manualSpotlightsServer[serverId].brightness
        manualSpotlightsServer[serverId].radius = radius or manualSpotlightsServer[serverId].radius
    end
    if trackingSpotlightsServer[serverId] then
        trackingSpotlightsServer[serverId].brightness = brightness or trackingSpotlightsServer[serverId].brightness
        trackingSpotlightsServer[serverId].radius = radius or trackingSpotlightsServer[serverId].radius
    end
end)

AddEventHandler("gameEventTriggered", function(eventName, eventData)
    if eventName ~= "CEventNetworkPlayerEnteredVehicle" then return end
    if isHeliSeatActive then return end

    local pedIdx = eventData[1]
    local vehicle = eventData[2]
    if pedIdx == PlayerId() and vehicle and vehicle ~= 0 and isAllowedHeli(vehicle) then
        if isJobAllowed() then
            isHeliSeatActive = true
            currentHeliVehicle = vehicle
            updateNuiHud(true, false)

            CreateThread(function()
                local ped = PlayerPedId()
                while not isResourceStopping do
                    if not IsPedInAnyVehicle(ped, false) or not DoesEntityExist(vehicle) then break end
                    Wait(250)
                end

                if isHeliSeatActive and currentHeliVehicle == vehicle then
                    isHeliSeatActive = false
                    currentHeliVehicle = 0
                    updateNuiHud(false, false)

                    if camState.manual_spotlight then setManualSpotlight(false) end
                    stopTrackingSpotlight()
                    if camState.forward_spotlight then setForwardSpotlight(false) end
                    releaseTargetLock(false)
                end
            end)

            CreateThread(function()
                while isHeliSeatActive and not isResourceStopping do
                    Wait(0)
                    local pPed = PlayerPedId()
                    if currentHeliVehicle == 0 or not DoesEntityExist(currentHeliVehicle) then break end
                    if GetVehiclePedIsIn(pPed, false) ~= currentHeliVehicle then break end

                    if IsControlJustPressed(0, getKey("toggle_cam")) then
                        enableHeliCam()
                    end
                    if IsControlJustPressed(0, getKey("rappel")) then
                        rappelFromHeli(pPed, currentHeliVehicle)
                    end
                    if IsControlJustPressed(0, getKey("toggle_spotlight")) and not camState.active then
                        toggleSpotlightAction(pPed, currentHeliVehicle)
                    end
                    if IsControlJustPressed(0, getKey("toggle_display")) and not camState.active then
                        toggleDisplayMode()
                    end
                    if IsControlJustPressed(0, getKey("toggle_lock")) and not camState.active then
                        if camState.locked_vehicle then
                            releaseTargetLock(false)
                        else
                            local target = getTargetVehicleFromRaycast(nil)
                            if target and DoesEntityExist(target) then
                                camState.locked_vehicle = target
                                camState.target_vehicle = target
                                showHeliNotification(heliLocales.Title or "Heli Cam", heliLocales.TargetLocked or "Target locked.", "success")
                            end
                        end
                    end

                    if camState.locked_vehicle and DoesEntityExist(camState.locked_vehicle) and not camState.active and camState.display_mode ~= 2 then
                        renderVehicleText(camState.locked_vehicle, camState.display_mode)
                    end
                end

                if hudState.visible then
                    updateNuiHud(false, false)
                end
                isHeliSeatActive = false
            end)
        end
    end
end)

AddEventHandler("onResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    isResourceStopping = true

    for sId, tData in pairs(trackingSpotlightsServer) do
        tData.active = false
        trackingSpotlightsServer[sId] = nil
    end
    for sId, mData in pairs(manualSpotlightsServer) do
        mData.active = false
        manualSpotlightsServer[sId] = nil
    end

    updateNuiHud(false, false)
    if camState.active then
        disableHeliCam()
    end
end)
