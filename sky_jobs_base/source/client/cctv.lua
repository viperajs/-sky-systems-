if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/cctv.lua") end
-- =====================================================
--  sky_jobs_base · source/client/cctv.lua
--  Deobfuscated & Cleaned
-- =====================================================

local cctvState = {
    active = false,
    cam = nil,
    target = nil,
    targetCoords = nil,
    targetHeading = nil,
    targetPitch = nil,
    targetType = nil,
    updater = false,
    durability = 100,
    effects = false,
    shakeActive = false,
    viewYawOffset = 0.0,
    viewPitchOffset = 0.0,
    previousRadarHidden = nil
}

local waypointState = {
    active = false,
    expiresAt = 0,
    coords = nil,
    targetType = nil,
    entity = nil,
    threadRunning = false,
    nextEntityRefreshAt = 0
}

local currentBodycamScopeTarget = nil
local lastDamageReportTime = 0
local lastPlayerHealth = nil
local isPlayerDeadState = false

local function clearWaypointOutline()
    if waypointState.entity and waypointState.entity ~= 0 and DoesEntityExist(waypointState.entity) then
        SetEntityDrawOutline(waypointState.entity, false)
    end
    waypointState.entity = nil
end

local function stopWaypointHighlight()
    waypointState.active = false
    waypointState.expiresAt = 0
    waypointState.coords = nil
    waypointState.targetType = nil
    waypointState.nextEntityRefreshAt = 0
    clearWaypointOutline()
end

local function getDistanceSq(a, b)
    if not (a and b and a.x and b.x) then return nil end
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = (a.z or 0.0) - (b.z or 0.0)
    return (dx * dx) + (dy * dy) + (dz * dz)
end

local function findClosestObject(coords)
    if not (coords and coords.x) then return nil end

    local closestEntity = nil
    local minDistSq = 36.0 -- 6 meters max

    local objects = GetGamePool("CObject")
    for _, obj in ipairs(objects) do
        if DoesEntityExist(obj) then
            local objPos = GetEntityCoords(obj)
            local distSq = getDistanceSq(objPos, coords)
            if distSq and distSq <= minDistSq and (not closestEntity or distSq < minDistSq) then
                minDistSq = distSq
                closestEntity = obj
            end
        end
    end

    return closestEntity
end

local function startWaypointThread()
    if waypointState.threadRunning then return end
    waypointState.threadRunning = true

    CreateThread(function()
        while waypointState.active do
            local now = GetGameTimer()
            if now >= waypointState.expiresAt then break end

            if not (waypointState.coords and waypointState.coords.x) then
                print("[sky_jobs_base] waypoint highlight failed: missing coords")
                break
            end

            if now >= waypointState.nextEntityRefreshAt then
                clearWaypointOutline()
                waypointState.entity = findClosestObject(waypointState.coords)
                waypointState.nextEntityRefreshAt = now + 1200
            end

            if waypointState.entity and waypointState.entity ~= 0 and DoesEntityExist(waypointState.entity) then
                SetEntityDrawOutlineColor(255, 210, 80, 220)
                SetEntityDrawOutlineShader(1)
                SetEntityDrawOutline(waypointState.entity, true)
            end

            Wait(0)
        end

        stopWaypointHighlight()
        waypointState.threadRunning = false
    end)
end

local function setWaypointHighlight(coords, targetType)
    if not (coords and coords.x) then
        print("[sky_jobs_base] waypoint highlight failed: invalid coords payload")
        return
    end

    stopWaypointHighlight()
    waypointState.active = true
    waypointState.coords = vector3(tonumber(coords.x) or 0.0, tonumber(coords.y) or 0.0, tonumber(coords.z) or 0.0)
    waypointState.targetType = targetType
    waypointState.expiresAt = GetGameTimer() + 120000 -- 2 minutes duration
    waypointState.nextEntityRefreshAt = 0

    startWaypointThread()
end

local function cleanPlateText(plate)
    if type(plate) ~= "string" then return nil end
    local cleaned = plate:gsub("%s+", "")
    if cleaned == "" then return nil end
    return cleaned:upper()
end

local function findVehicleByPlate(plate)
    local targetPlate = cleanPlateText(plate)
    if not targetPlate then return nil end

    local vehicles = GetGamePool("CVehicle")
    for _, veh in ipairs(vehicles) do
        if DoesEntityExist(veh) then
            local pText = cleanPlateText(GetVehicleNumberPlateText(veh))
            if pText and pText == targetPlate then
                return veh
            end
        end
    end
    return nil
end

local function getStreamDistance()
    local cfg = Config and Config.Cctv
    return tonumber(cfg and cfg.streamDistance) or 120.0
end

local function setCameraWorldFocus(pos, vel)
    if not (pos and pos.x) then return end
    local v = vel or vector3(0.0, 0.0, 0.0)
    local streamDist = getStreamDistance()

    SetFocusPosAndVel(pos.x, pos.y, pos.z, v.x, v.y, v.z)
    SetHdArea(pos.x, pos.y, pos.z, streamDist)
    RequestCollisionAtCoord(pos.x, pos.y, pos.z)
end

local function setCameraFocusEntity(entity)
    if not (entity and entity ~= 0 and DoesEntityExist(entity)) then return end
    local coords = GetEntityCoords(entity)
    local streamDist = getStreamDistance()

    SetFocusEntity(entity)
    SetHdArea(coords.x, coords.y, coords.z, streamDist)
end

local function clearCameraWorldFocus()
    ClearFocus()
    ClearHdArea()
end

local function updateBodycamScope(target, isActive)
    if isActive then
        if currentBodycamScopeTarget == target then return end
        currentBodycamScopeTarget = target
        TriggerServerEvent("sky_jobs_base:cctv:bodycamScope", target, true)
    else
        if currentBodycamScopeTarget then
            TriggerServerEvent("sky_jobs_base:cctv:bodycamScope", currentBodycamScopeTarget, false)
            currentBodycamScopeTarget = nil
        end
    end
end

local function destroyCctvCam()
    if cctvState.cam and DoesCamExist(cctvState.cam) then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cctvState.cam, false)
    end

    cctvState.cam = nil
    cctvState.target = nil
    cctvState.targetCoords = nil
    cctvState.targetHeading = nil
    cctvState.targetPitch = nil
    cctvState.shakeActive = false
    cctvState.viewYawOffset = 0.0
    cctvState.viewPitchOffset = 0.0

    ClearTimecycleModifier()
    if IsScreenFadedOut() then
        DoScreenFadeIn(0)
    end

    if cctvState.previousRadarHidden ~= nil then
        DisplayRadar(not cctvState.previousRadarHidden)
        cctvState.previousRadarHidden = nil
    end

    updateBodycamScope(nil, false)
    clearCameraWorldFocus()
end

local function createCctvCam()
    if cctvState.cam and DoesCamExist(cctvState.cam) then return end

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    cctvState.cam = cam
    SetCamFov(cam, 60.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
end

local function clampVal(val, minVal, maxVal)
    if val < minVal then return minVal end
    if val > maxVal then return maxVal end
    return val
end

local function adjustCctvView()
    if cctvState.targetType == "cctv" and cctvState.target then
        TriggerEvent("sky_policejob:cctvcam:adjustView", {
            id = cctvState.target,
            yaw = cctvState.viewYawOffset or 0.0,
            pitch = cctvState.viewPitchOffset or 0.0
        })
    end
end

local function updateCamPosition()
    local target = cctvState.target
    if not target then return end

    if cctvState.targetType == "dashcam" then
        local veh = findVehicleByPlate(target)
        if not (veh and veh ~= 0 and DoesEntityExist(veh)) then
            if cctvState.targetCoords and cctvState.targetCoords.x then
                local pos = cctvState.targetCoords
                SetCamCoord(cctvState.cam, pos.x, pos.y, pos.z + 2.0)
                PointCamAtCoord(cctvState.cam, pos.x, pos.y + 5.0, pos.z + 1.0)
                setCameraWorldFocus(pos)
            end
            return
        end

        local vehPos = GetEntityCoords(veh)
        cctvState.targetCoords = vehPos

        local windscreenBone = GetEntityBoneIndexByName(veh, "windscreen")
        local camPos = GetWorldPositionOfEntityBone(veh, windscreenBone)
        local forward = GetEntityForwardVector(veh)

        SetCamCoord(cctvState.cam, camPos.x, camPos.y, camPos.z)
        PointCamAtCoord(cctvState.cam, camPos.x + (forward.x * 10.0), camPos.y + (forward.y * 10.0), camPos.z + (forward.z * 10.0))
        setCameraFocusEntity(veh)
        return
    end

    if cctvState.targetType == "speedcam" then
        local pos = cctvState.targetCoords
        if not (pos and pos.x) then return end

        local radHeading = math.rad((cctvState.targetHeading or 0.0) + 180.0)
        local fwdVec = vector3(-math.sin(radHeading), math.cos(radHeading), 0.0)

        local camPos = vector3(pos.x + (fwdVec.x * 1.4), pos.y + (fwdVec.y * 1.4), pos.z + 1.0)
        local targetPos = vector3(pos.x + (fwdVec.x * 6.0), pos.y + (fwdVec.y * 6.0), pos.z + 0.6)

        SetCamCoord(cctvState.cam, camPos.x, camPos.y, camPos.z)
        PointCamAtCoord(cctvState.cam, targetPos.x, targetPos.y, targetPos.z)
        setCameraWorldFocus(pos)
        return
    end

    if cctvState.targetType == "cctv" then
        local pos = cctvState.targetCoords
        if not (pos and pos.x) then return end

        local radHeading = math.rad((cctvState.targetHeading or 0.0) + 180.0 + (cctvState.viewYawOffset or 0.0))
        local radPitch = math.rad((cctvState.targetPitch or 0.0) + (cctvState.viewPitchOffset or 0.0))
        local cosPitch = math.cos(radPitch)

        local dirVec = vector3(
            -math.sin(radHeading) * cosPitch,
            math.cos(radHeading) * cosPitch,
            math.sin(radPitch)
        )

        local camViewOffset = tonumber(Config and Config.Cctv and Config.Cctv.camViewOffset) or 0.1
        local camPos = vector3(pos.x + (dirVec.x * camViewOffset), pos.y + (dirVec.y * camViewOffset), pos.z + (dirVec.z * camViewOffset))
        local targetPos = vector3(pos.x + (dirVec.x * 6.0), pos.y + (dirVec.y * 6.0), pos.z + (dirVec.z * 6.0))

        SetCamCoord(cctvState.cam, camPos.x, camPos.y, camPos.z)
        PointCamAtCoord(cctvState.cam, targetPos.x, targetPos.y, targetPos.z)
        setCameraWorldFocus(pos)
        return
    end

    -- Default: Bodycam tracking target ped
    local playerIdx = GetPlayerFromServerId(target)
    local targetPed = nil
    if playerIdx ~= -1 then
        local ped = GetPlayerPed(playerIdx)
        if ped and DoesEntityExist(ped) then
            targetPed = ped
        end
    end

    if not targetPed then
        if cctvState.targetCoords and cctvState.targetCoords.x then
            local pos = cctvState.targetCoords
            SetCamCoord(cctvState.cam, pos.x, pos.y, pos.z + 2.0)
            PointCamAtCoord(cctvState.cam, pos.x, pos.y + 5.0, pos.z + 1.0)
            setCameraWorldFocus(pos)
        end
        return
    end

    local pedPos = GetEntityCoords(targetPed)
    if pedPos then cctvState.targetCoords = pedPos end

    local forward = GetEntityForwardVector(targetPed)
    local headCoords = GetPedBoneCoords(targetPed, 31086, 0.0, 0.1, 0.0)

    local camPos = vector3(headCoords.x + (forward.x * 0.18), headCoords.y + (forward.y * 0.18), headCoords.z + (forward.z * 0.18))
    local targetPos = vector3(headCoords.x + (forward.x * 2.0), headCoords.y + (forward.y * 2.0), headCoords.z + (forward.z * 0.2))

    SetCamCoord(cctvState.cam, camPos.x, camPos.y, camPos.z)
    PointCamAtCoord(cctvState.cam, targetPos.x, targetPos.y, targetPos.z)
    setCameraFocusEntity(targetPed)
end

local function getDamageRatio()
    local dur = clampVal(tonumber(cctvState.durability) or 100, 0, 100)
    return (100 - dur) / 100
end

local function startCctvEffects()
    if cctvState.effects then return end
    cctvState.effects = true

    CreateThread(function()
        local nextGlitchTime = GetGameTimer() + 1000
        local nextFadeTime = GetGameTimer() + 2000

        while cctvState.active do
            local dmgRatio = getDamageRatio()

            SetTimecycleModifier("CAMERA_secuirity")
            SetTimecycleModifierStrength(0.1 + (0.85 * dmgRatio))

            if cctvState.cam and DoesCamExist(cctvState.cam) then
                if dmgRatio > 0.08 then
                    if not cctvState.shakeActive then
                        ShakeCam(cctvState.cam, "HAND_SHAKE", 0.05)
                        cctvState.shakeActive = true
                    end
                    SetCamShakeAmplitude(cctvState.cam, 0.05 + (0.22 * dmgRatio))
                else
                    if cctvState.shakeActive then
                        StopCamShaking(cctvState.cam, true)
                        cctvState.shakeActive = false
                    end
                end
            end

            local now = GetGameTimer()
            if dmgRatio >= 0.4 and nextGlitchTime <= now then
                if math.random() < (0.15 + (0.55 * dmgRatio)) then
                    local glitchDuration = math.random(140, 320)
                    SetTimecycleModifierStrength(math.min(1.0, 0.55 + (0.45 * dmgRatio)))
                    if cctvState.cam and DoesCamExist(cctvState.cam) then
                        ShakeCam(cctvState.cam, "HAND_SHAKE", 0.15 + (0.25 * dmgRatio))
                    end
                    Wait(glitchDuration)
                end
                nextGlitchTime = now + math.random(700, 1800)
            end

            if dmgRatio >= 0.7 and nextFadeTime <= now then
                if math.random() < (0.08 + (0.22 * dmgRatio)) then
                    DoScreenFadeOut(120)
                    Wait(math.random(220, 520))
                    if not cctvState.active then break end
                    DoScreenFadeIn(200)
                end
                nextFadeTime = now + math.random(2000, 4500)
            end

            Wait(120)
        end

        if cctvState.cam and DoesCamExist(cctvState.cam) then
            StopCamShaking(cctvState.cam, true)
        end
        cctvState.shakeActive = false
        ClearTimecycleModifier()
        cctvState.effects = false
    end)
end

local function setCctvActive(active, target, durability, targetType, targetCoords, targetHeading, targetPitch)
    if cctvState.targetType == "cctv" and cctvState.target then
        TriggerEvent("sky_policejob:cctvcam:adjustView", {
            id = cctvState.target,
            yaw = 0.0,
            pitch = 0.0
        })
    end

    updateBodycamScope(nil, false)

    if active ~= true then
        cctvState.active = false
        destroyCctvCam()
        cctvState.targetType = nil
        cctvState.targetCoords = nil
        cctvState.targetHeading = nil
        cctvState.targetPitch = nil
        cctvState.viewYawOffset = 0.0
        cctvState.viewPitchOffset = 0.0
        return
    end

    cctvState.active = true
    if cctvState.previousRadarHidden == nil then
        cctvState.previousRadarHidden = IsRadarHidden()
    end
    DisplayRadar(false)

    cctvState.target = target
    cctvState.durability = durability or 100
    cctvState.targetType = targetType or "bodycam"
    cctvState.targetCoords = targetCoords
    cctvState.targetHeading = targetHeading
    cctvState.targetPitch = targetPitch or 0.0
    cctvState.viewYawOffset = 0.0
    cctvState.viewPitchOffset = 0.0

    if not (cctvState.targetType == "cctv" or cctvState.targetType == "speedcam" or cctvState.targetType == "dashcam") then
        if cctvState.target then
            updateBodycamScope(cctvState.target, true)
        end
    end

    adjustCctvView()
    createCctvCam()
    startCctvEffects()

    if cctvState.updater then return end
    cctvState.updater = true

    CreateThread(function()
        while cctvState.active do
            updateCamPosition()
            Wait(0)
        end
        cctvState.updater = false
    end)
end

RegisterNUICallback("cctv:getCameras", function(_, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:cctv:getCameras")
    res = res or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("cctv:setView", function(data, cb)
    data = data or {}
    local tType = data.type
    local target = (tType == "dashcam") and data.target or tonumber(data.target)
    local durability = tonumber(data.durability)
    local coords = data.coords
    local heading = tonumber(data.heading)
    local pitch = tonumber(data.pitch)

    setCctvActive(data.active == true, target, durability, tType, coords, heading, pitch)
    cb({ success = true })
end)

RegisterNUICallback("cctv:adjustView", function(data, cb)
    data = data or {}
    if cctvState.targetType ~= "cctv" then
        cb({ success = false })
        return
    end

    local yaw = tonumber(data.yaw)
    local pitch = tonumber(data.pitch)

    if yaw then
        cctvState.viewYawOffset = clampVal(yaw, -90.0, 90.0)
    end
    if pitch then
        cctvState.viewPitchOffset = clampVal(pitch, -45.0, 45.0)
    end

    adjustCctvView()
    cb({ success = true })
end)

RegisterNUICallback("cctv:getVideoConfig", function(_, cb)
    local cfg = Config and Config.Cctv
    if cfg and cfg.bodycamRecorderEnabled == false then
        cb({ success = false, error = "disabled" })
        return
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:cctv:getVideoConfig")
    res = res or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("cctv:setWaypoint", function(data, cb)
    data = data or {}
    local coords = data.coords
    local targetType = tostring(data.type or "")

    local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
    local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}
    local cctvLocales = (locales.Nui and locales.Nui.cctv) or {}
    local wpLocales = cctvLocales.waypoint or {}

    if coords and coords.x and coords.y then
        SetNewWaypoint(tonumber(coords.x) or 0.0, tonumber(coords.y) or 0.0)
        if targetType == "cctv" or targetType == "speedcam" then
            setWaypointHighlight(coords, targetType)
        end

        Sky.Show.Notification(cctvLocales.title or "CCTV", wpLocales.set or "Waypoint set.", "info")
        cb({ success = true })
        return
    end

    print("[sky_jobs_base] cctv:setWaypoint failed: missing x/y coords")
    Sky.Show.Notification(cctvLocales.title or "CCTV", wpLocales.missing or "No location available.", "error")
    cb({ success = false, error = "missing_coords" })
end)

RegisterNUICallback("cctv:requestBodycamSave", function(data, cb)
    data = data or {}
    local cfg = Config and Config.Cctv
    if cfg and cfg.bodycamRecorderEnabled == false then
        cb({ success = false, error = "disabled" })
        return
    end

    TriggerServerEvent("sky_jobs_base:bodycam:requestSave", {
        target = tonumber(data.target),
        requestId = data.requestId,
        label = data.label,
        location = data.location,
        cameraId = data.cameraId
    })

    cb({
        success = true,
        data = { requestId = data.requestId }
    })
end)

RegisterNetEvent("sky_jobs_base:cctv:updateCamera", function(data)
    if type(data) ~= "table" then return end

    if cctvState.active and data.target and cctvState.target == data.target then
        if not data.type or data.type == cctvState.targetType then
            cctvState.durability = data.durability or cctvState.durability
            if data.coords and data.coords.x then
                cctvState.targetCoords = data.coords
            end
        end
    end

    SendNUIMessage({
        type = "cctv:updateCamera",
        data = data
    })
end)

RegisterNetEvent("sky_jobs_base:cctv:saveResult", function(data)
    if type(data) ~= "table" then return end
    SendNUIMessage({
        type = "cctv:saveResult",
        data = data
    })
end)

AddEventHandler("gameEventTriggered", function(eventName, eventData)
    if eventName ~= "CEventNetworkEntityDamage" then return end
    local victim = eventData and eventData[1]
    local ped = PlayerPedId()
    if victim ~= ped then return end

    local now = GetGameTimer()
    if (now - lastDamageReportTime) < 300 then return end
    lastDamageReportTime = now

    TriggerServerEvent("sky_jobs_base:cctv:reportDamage")
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if ped and ped ~= 0 then
            local hp = GetEntityHealth(ped)
            if lastPlayerHealth == nil then
                lastPlayerHealth = hp
            elseif hp ~= lastPlayerHealth then
                local now = GetGameTimer()
                if (now - lastDamageReportTime) >= 500 then
                    lastDamageReportTime = now
                    TriggerServerEvent("sky_jobs_base:cctv:reportDamage")
                end
                lastPlayerHealth = hp
            end

            local isDead = IsEntityDead(ped) == true
            if isDead ~= isPlayerDeadState then
                isPlayerDeadState = isDead
                TriggerServerEvent("sky_jobs_base:cctv:reportDamage")
            end
        end
        Wait(500)
    end
end)

AddEventHandler("onResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    stopWaypointHighlight()
    setCctvActive(false, nil)
end)
