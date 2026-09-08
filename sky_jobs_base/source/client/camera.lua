if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/camera.lua") end
-- =====================================================
--  sky_jobs_base · source/client/camera.lua
--  Deobfuscated & Cleaned
-- =====================================================

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}
local uploadFailedMsg = locales.CameraUploadFailed or "Camera upload failed."

local PED_FIRST_PERSON = 4
local PED_THIRD_PERSON = 1
local VEH_FIRST_PERSON = 4
local FRONT_CAM_FOV = 25.0
local FRONT_CAM_FORWARD_OFFSET = 0.75
local FRONT_CAM_HEIGHT_OFFSET = 0.05
local FRONT_CAM_TARGET_HEIGHT_OFFSET = 0.03

local state = {
    active = false,
    enforcing = false,
    frontCamera = false,
    previousPedView = nil,
    previousVehicleView = nil,
    previousRadarHidden = nil,
    frontCamHandle = nil,
    nuiFocus = true,
    focusWatcher = false,
    flashEnabled = false,
    flashThread = false
}

local captureSettings = {
    encoding = "jpg",
    quality = 0.95
}

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

local function drawFlashLight()
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local forward = getForwardVector(camRot)
    local lightPos = camCoords + (forward * 0.8)
    DrawLightWithRange(lightPos.x, lightPos.y, lightPos.z, 255, 255, 255, 12.0, 8.0)
end

local function setFlashEnabled(enabled)
    state.flashEnabled = (enabled == true)
    if state.flashEnabled and state.active then
        if not state.flashThread then
            state.flashThread = true
            CreateThread(function()
                while state.active and state.flashEnabled do
                    drawFlashLight()
                    Wait(0)
                end
                state.flashThread = false
            end)
        end
    end
end

local function updateCamViewMode()
    local ped = PlayerPedId()
    local targetMode = state.frontCamera and VEH_FIRST_PERSON or PED_THIRD_PERSON
    if IsPedInAnyVehicle(ped, false) then
        SetFollowVehicleCamViewMode(targetMode)
    else
        SetFollowPedCamViewMode(targetMode)
    end
end

local function calculateSelfieCamCoords(ped)
    local headCoords = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)
    local forward = GetEntityForwardVector(ped)
    local fwdVec = vector3(forward.x, forward.y, forward.z)
    local offsetFwd = fwdVec * FRONT_CAM_FORWARD_OFFSET
    local camPos = headCoords + offsetFwd + vector3(0.0, 0.0, FRONT_CAM_HEIGHT_OFFSET)

    local diff = camPos - headCoords
    local dot = (diff.x * fwdVec.x) + (diff.y * fwdVec.y) + (diff.z * fwdVec.z)
    if dot < 0.0 then
        camPos = (headCoords - offsetFwd) + vector3(0.0, 0.0, FRONT_CAM_HEIGHT_OFFSET)
    end

    local targetPos = headCoords + vector3(0.0, 0.0, FRONT_CAM_TARGET_HEIGHT_OFFSET)
    return camPos, targetPos
end

local function createSelfieCam()
    if state.frontCamHandle and DoesCamExist(state.frontCamHandle) then return end

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    state.frontCamHandle = cam
    SetCamFov(cam, FRONT_CAM_FOV)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
end

local function destroySelfieCam()
    if state.frontCamHandle and DoesCamExist(state.frontCamHandle) then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(state.frontCamHandle, false)
    end
    state.frontCamHandle = nil
end

local function restorePreviousViewModes()
    if state.previousPedView then
        SetFollowPedCamViewMode(state.previousPedView)
    end
    if state.previousVehicleView then
        SetFollowVehicleCamViewMode(state.previousVehicleView)
    end
    if state.previousRadarHidden ~= nil then
        DisplayRadar(not state.previousRadarHidden)
    end
end

local function setCameraNuiFocus(focused)
    if state.nuiFocus == focused then return end
    state.nuiFocus = focused

    if focused then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
        SendNUIMessage({ type = "camera:focus", focused = true })
        return
    end

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(true)
    SendNUIMessage({ type = "camera:focus", focused = false })

    if not state.focusWatcher then
        state.focusWatcher = true
        CreateThread(function()
            while state.active and state.nuiFocus == false do
                if IsControlJustReleased(0, 22) then -- Space control
                    setCameraNuiFocus(true)
                    break
                end
                Wait(0)
            end
            state.focusWatcher = false
        end)
    end
end

local function setCameraActive(active)
    if state.active == active then return end
    state.active = active

    if active then
        state.frontCamera = false
        destroySelfieCam()

        state.previousPedView = GetFollowPedCamViewMode()
        state.previousVehicleView = GetFollowVehicleCamViewMode()
        state.previousRadarHidden = IsRadarHidden()

        DisplayRadar(false)
        setCameraNuiFocus(true)
        updateCamViewMode()

        if not state.enforcing then
            state.enforcing = true
            CreateThread(function()
                local nextRefresh = 0
                while state.active do
                    HideHudAndRadarThisFrame()
                    if state.frontCamera then
                        local ped = PlayerPedId()
                        createSelfieCam()
                        if state.frontCamHandle and DoesCamExist(state.frontCamHandle) then
                            local camPos, targetPos = calculateSelfieCamCoords(ped)
                            SetCamCoord(state.frontCamHandle, camPos.x, camPos.y, camPos.z)
                            PointCamAtCoord(state.frontCamHandle, targetPos.x, targetPos.y, targetPos.z)
                        end
                    end

                    local now = GetGameTimer()
                    if nextRefresh <= now then
                        updateCamViewMode()
                        nextRefresh = now + 250
                    end
                    Wait(0)
                end
                state.enforcing = false
            end)
        end
    else
        state.flashEnabled = false
        state.frontCamera = false
        destroySelfieCam()
        restorePreviousViewModes()
    end
end

local function setFrontFacing(isFront)
    local flag = (isFront == true)
    if state.frontCamera == flag then return end
    state.frontCamera = flag

    if state.active then
        if flag then
            createSelfieCam()
        else
            destroySelfieCam()
        end
        updateCamViewMode()
    end
end

RegisterNUICallback("camera:setActive", function(data, cb)
    local activeFlag = (data and data.active == true)
    setCameraActive(activeFlag)
    cb({ success = true })
end)

RegisterNUICallback("camera:setFocus", function(data, cb)
    if state.active then
        local focusFlag = (data and data.focused == true)
        setCameraNuiFocus(focusFlag)
    end
    cb({ success = true })
end)

RegisterNUICallback("camera:setFlash", function(data, cb)
    local flashFlag = (data and data.enabled == true)
    setFlashEnabled(flashFlag)
    cb({ success = true })
end)

RegisterNUICallback("camera:setFacing", function(data, cb)
    local frontFlag = (data and data.front == true)
    setFrontFacing(frontFlag)
    cb({ success = true })
end)

RegisterNUICallback("camera:getFocus", function(_, cb)
    cb({
        success = true,
        data = {
            focused = IsNuiFocused()
        }
    })
end)

AddEventHandler("sky_jobs:nuiClosed", function()
    setCameraActive(false)
end)

RegisterNetEvent("sky_jobs_base:camera:captureAndUpload", function(data)
    data = data or {}
    local reqId = data.requestId
    if type(reqId) ~= "string" or reqId == "" then return end

    local url = data.presignedUrl
    if type(url) ~= "string" or url == "" then
        TriggerServerEvent("sky_jobs_base:camera:uploadResult", {
            requestId = reqId,
            success = false,
            error = "missing_presigned_url"
        })
        return
    end

    SendNUIMessage({
        type = "camera:capturePhoto",
        data = {
            requestId = reqId,
            presignedUrl = url,
            encoding = captureSettings.encoding,
            quality = captureSettings.quality
        }
    })
end)

RegisterNUICallback("camera:photoResult", function(data, cb)
    cb({ success = true })
    local reqId = data and data.requestId
    if type(reqId) ~= "string" or reqId == "" then return end

    if data.success and type(data.url) == "string" and data.url ~= "" then
        local imgId = data.image_id and tostring(data.image_id) or nil
        TriggerServerEvent("sky_jobs_base:camera:uploadResult", {
            requestId = reqId,
            success = true,
            data = {
                url = data.url,
                image_id = imgId,
                id = imgId
            }
        })
        return
    end

    TriggerServerEvent("sky_jobs_base:camera:uploadResult", {
        requestId = reqId,
        success = false,
        error = type(data.error) == "string" and data.error or "upload_failed"
    })
end)

RegisterNUICallback("camera:takePhoto", function(data, cb)
    data = data or {}
    local payload = {
        zoom = data.zoom,
        folder = data.folder,
        metadata = data.metadata,
        timeout = data.timeout
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:camera:takePhoto", payload)
    if res and res.success then
        cb(res)
        return
    end

    cb({
        success = false,
        error = (res and res.error) or uploadFailedMsg
    })
end)
