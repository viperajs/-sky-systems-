if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/vehicle_attach_editor.lua") end
-- =====================================================
--  sky_jobs_base · source/client/vehicle_attach_editor.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.JobVehicleAttachEditor = Sky.JobVehicleAttachEditor or {}

local function showNotification(message, notifyType)
    Sky.Show.Notification("Vehicle Attach Editor", message or "", notifyType or "info")
end

local function loadModel(modelHash)
    if not modelHash then
        return false, "Invalid model"
    end

    RequestModel(modelHash)
    local timeout = GetGameTimer() + 5000

    while not HasModelLoaded(modelHash) do
        Wait(0)
        if GetGameTimer() > timeout then
            return false, "Model load timeout"
        end
    end
    return true
end

local function clamp(val, minVal, maxVal)
    if val < minVal then return minVal end
    if val > maxVal then return maxVal end
    return val
end

local function calculateModelDimensions(modelHash)
    local minDim, maxDim = GetModelDimensions(modelHash)
    local width = math.abs((maxDim.x or 0.0) - (minDim.x or 0.0))
    local length = math.abs((maxDim.y or 0.0) - (minDim.y or 0.0))
    local height = math.abs((maxDim.z or 0.0) - (minDim.z or 0.0))

    local groundLift = math.max(0.0, -(minDim.z or 0.0)) + 0.05

    return {
        min = minDim,
        max = maxDim,
        width = width,
        length = length,
        height = height,
        groundLift = groundLift
    }
end

local function calculateCameraConfig(dims, cameraCfg, isHoseBend)
    local maxDim = math.max(dims.length, dims.width * 1.2, dims.height * 1.35, 3.0)
    local radiusCfg = cameraCfg and cameraCfg.radius
    local radius = math.max(tonumber(radiusCfg) or 5.5, (maxDim * 0.95) + 1.0)

    local minRadCfg = cameraCfg and cameraCfg.minRadius
    local minRadius = math.max(tonumber(minRadCfg) or 3.0, radius - 1.8)

    local maxRadCfg = cameraCfg and cameraCfg.maxRadius
    local maxRadius = math.max(tonumber(maxRadCfg) or 9.5, radius + 3.0)

    local focusMultiplier = isHoseBend and 0.42 or 0.3
    local focusHeight = clamp(dims.height * focusMultiplier, 0.75, 4.5)

    local baseElevation = isHoseBend and 0.28 or 0.2
    local elevation = clamp(baseElevation + (dims.height * 0.01), 0.15, 0.45)

    local fovCfg = cameraCfg and cameraCfg.fov
    local defaultFov = isHoseBend and 32.0 or 38.0
    local fov = clamp(tonumber(fovCfg) or defaultFov, 20.0, 60.0)

    local scrollCfg = cameraCfg and cameraCfg.scrollStep
    local scrollStep = clamp(tonumber(scrollCfg) or 0.45, 0.1, 2.0)

    return {
        radius = radius,
        minRadius = minRadius,
        maxRadius = maxRadius,
        focusHeight = focusHeight,
        elevation = elevation,
        fov = fov,
        scrollStep = scrollStep
    }
end

local function pinWorldArea(coords)
    if not (coords and coords.x) then return 0 end
    SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
    SetHdArea(coords.x, coords.y, coords.z, 140.0)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    local interiorId = GetInteriorAtCoords(coords.x, coords.y, coords.z)
    if interiorId ~= 0 then
        PinInteriorInMemory(interiorId)
    end
    return interiorId
end

local function unpinWorldArea(interiorId)
    ClearFocus()
    ClearHdArea()
    if interiorId and interiorId ~= 0 then
        UnpinInterior(interiorId)
    end
end

local function loadWorldSphere(coords, durationMs)
    if not (coords and coords.x) then return end
    local timeout = GetGameTimer() + (durationMs or 3000)
    NewLoadSceneStartSphere(coords.x, coords.y, coords.z, 110.0, 0)

    while GetGameTimer() < timeout do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        if IsNewLoadSceneLoaded() then break end
        Wait(0)
    end

    NewLoadSceneStop()
end

local editorState = {
    active = false,
    vehicle = 0,
    previewProp = 0,
    hoseSegments = {},
    offset = { x = 0.0, y = 0.0, z = 0.0 },
    rotation = { x = 0.0, y = 0.0, z = 0.0 },
    heading = 0.0,
    camera = nil,
    cameraAngles = { azimuth = 0.0, elevation = 0.2 },
    cameraRadius = 5.5,
    cameraMin = 3.0,
    cameraMax = 9.5,
    cameraFov = 38.0,
    cameraScrollStep = 0.45,
    cameraFocusHeight = 0.5,
    cameraTarget = nil,
    playerRestore = nil,
    previewInterior = 0,
    overlayActive = false,
    result = nil,
    preview = {}
}

local function backupPlayerState()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    return {
        coords = vector3(coords.x, coords.y, coords.z),
        heading = GetEntityHeading(ped),
        visible = IsEntityVisible(ped),
        alpha = GetEntityAlpha(ped)
    }
end

local function hidePlayerPed(spawnCoords, heading)
    local ped = PlayerPedId()
    editorState.playerRestore = backupPlayerState()

    SetEntityVisible(ped, false, false)
    SetEntityAlpha(ped, 0, false)
    SetEntityCollision(ped, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityCoordsNoOffset(ped, spawnCoords.x, spawnCoords.y, spawnCoords.z + 1.5, false, false, false)
    SetEntityHeading(ped, heading or 0.0)
end

local function restorePlayerPed()
    local ped = PlayerPedId()
    local restore = editorState.playerRestore
    editorState.playerRestore = nil

    if restore and restore.coords then
        SetEntityCoordsNoOffset(ped, restore.coords.x, restore.coords.y, restore.coords.z, false, false, false)
        SetEntityHeading(ped, restore.heading or 0.0)
        SetEntityCollision(ped, true, true)
        SetEntityAlpha(ped, restore.alpha or 255, false)
        SetEntityVisible(ped, restore.visible ~= false, false)
    else
        SetEntityCollision(ped, true, true)
        SetEntityAlpha(ped, 255, false)
        SetEntityVisible(ped, true, false)
    end
    FreezeEntityPosition(ped, false)
end

local function sendNuiMsg(typeKey, data)
    SendNUIMessage({
        type = typeKey,
        data = data or {}
    })
end

local function showEditorOverlay()
    if editorState.overlayActive then return end
    editorState.overlayActive = true

    sendNuiMsg("vehicleAttachEditor:set", {
        title = editorState.preview.title or "Hose Connection Editor",
        offset = editorState.offset,
        rotation = editorState.rotation
    })
end

local function updateEditorOverlay()
    if not editorState.overlayActive then return end
    sendNuiMsg("vehicleAttachEditor:update", {
        offset = editorState.offset,
        rotation = editorState.rotation
    })
end

local function closeEditorOverlay()
    if not editorState.overlayActive then return end
    editorState.overlayActive = false
    sendNuiMsg("vehicleAttachEditor:close")
end

local function clearHoseSegments()
    for _, seg in pairs(editorState.hoseSegments) do
        if seg.object and DoesEntityExist(seg.object) then
            DeleteEntity(seg.object)
        end
    end
    editorState.hoseSegments = {}
end

local function cleanupEditorState()
    if editorState.previewProp and editorState.previewProp ~= 0 and DoesEntityExist(editorState.previewProp) then
        DeleteEntity(editorState.previewProp)
    end

    clearHoseSegments()

    if editorState.vehicle and editorState.vehicle ~= 0 and DoesEntityExist(editorState.vehicle) then
        DeleteEntity(editorState.vehicle)
    end

    if editorState.camera and DoesCamExist(editorState.camera) then
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(editorState.camera)
    end

    restorePlayerPed()

    editorState.active = false
    editorState.vehicle = 0
    editorState.previewProp = 0
    editorState.camera = nil
    editorState.cameraTarget = nil
    editorState.cameraFov = 38.0
    editorState.cameraScrollStep = 0.45
    editorState.cameraFocusHeight = 0.5

    unpinWorldArea(editorState.previewInterior)
    editorState.previewInterior = 0
    editorState.cameraAngles = { azimuth = 0.0, elevation = 0.2 }

    closeEditorOverlay()
end

local function getHorizontalForwardVector(vec, fallback)
    local horiz = vector3(vec.x, vec.y, 0.0)
    local len = #horiz
    if len <= 0.001 then
        return fallback
    end
    return horiz / len
end

local function adjustZToGround(coords)
    local groundOffset = tonumber(editorState.preview.groundOffset) or 0.055
    local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 2.0, false)
    if found then
        return vector3(coords.x, coords.y, groundZ + groundOffset)
    end
    return coords
end

local function calculateHoseBendControlPoints(startCoords, forward, exitLength, bendDistance)
    local exitPoint = startCoords + (forward * exitLength)
    local targetPoint = adjustZToGround(exitPoint + (forward * bendDistance))

    local midX = (targetPoint.x + exitPoint.x) * 0.5
    local midY = (targetPoint.y + exitPoint.y) * 0.5
    local midZ = targetPoint.z + ((exitPoint.z - targetPoint.z) * 0.35)
    local midPoint = vector3(midX, midY, midZ)

    return targetPoint, midPoint, exitPoint
end

local function calculateHosePathPoints()
    local off = editorState.offset
    local attachCoords = GetOffsetFromEntityInWorldCoords(
        editorState.vehicle,
        tonumber(off.x) or -1.05,
        tonumber(off.y) or -3.25,
        tonumber(off.z) or 0.35
    )

    local dirVec = nil
    local exitDir = editorState.preview.vehicleExitDirection
    if type(exitDir) == "table" then
        local rawExit = GetOffsetFromEntityInWorldCoords(
            editorState.vehicle,
            (tonumber(off.x) or -1.05) + (tonumber(exitDir.x) or 0.0),
            (tonumber(off.y) or -3.25) + (tonumber(exitDir.y) or 0.0),
            (tonumber(off.z) or 0.35) + (tonumber(exitDir.z) or 0.0)
        )
        dirVec = rawExit - attachCoords
    else
        local vehCoords = GetEntityCoords(editorState.vehicle)
        dirVec = attachCoords - vehCoords
    end

    local forward = getHorizontalForwardVector(dirVec, vector3(0.0, -1.0, 0.0))

    local exitLen = tonumber(editorState.preview.vehicleExitLength) or 0.1
    local bendDist = tonumber(editorState.preview.vehicleBendDistance) or 0.55

    local p1, p2, p3 = calculateHoseBendControlPoints(attachCoords, forward, exitLen, bendDist)
    return { attachCoords, p3, p2, p1 }
end

local function getVectorAndLength(pStart, pEnd)
    local vec = pEnd - pStart
    local len = #vec
    if len <= 0.001 then
        return vector3(0.0, 0.0, 0.0), 0.0
    end
    return vec / len, len
end

local function crossProduct(v1, v2)
    return vector3(
        (v1.y * v2.z) - (v1.z * v2.y),
        (v1.z * v2.x) - (v1.x * v2.z),
        (v1.x * v2.y) - (v1.y * v2.x)
    )
end

local function normalizeVector(v)
    local len = #v
    if len <= 0.001 then
        return vector3(0.0, 0.0, 0.0)
    end
    return v / len
end

local function rotateVectorAroundAxis(vec, axis, angleRad)
    if angleRad == 0.0 then return vec end
    local cosA = math.cos(angleRad)
    local sinA = math.sin(angleRad)
    return (vec * cosA) + (crossProduct(axis, vec) * sinA)
end

local function createHoseSegment(startCoords, endCoords)
    local dir, len = getVectorAndLength(startCoords, endCoords)
    if len <= 0.001 then return nil end

    local modelName = editorState.preview.segmentProp or "sky_hose_segment"
    local modelHash = joaat(modelName)

    if not loadModel(modelHash) then return nil end

    local obj = CreateObjectNoOffset(modelHash, startCoords.x, startCoords.y, startCoords.z, false, false, false)
    SetEntityAsMissionEntity(obj, true, true)
    SetEntityCollision(obj, false, false)
    FreezeEntityPosition(obj, true)
    SetModelAsNoLongerNeeded(modelHash)

    return {
        object = obj,
        length = len,
        startCoords = startCoords,
        endCoords = endCoords
    }
end

local function updateHoseSegmentMatrix(seg)
    local dir, len = getVectorAndLength(seg.startCoords, seg.endCoords)
    if len <= 0.001 then return false end

    local overlap = math.min(tonumber(editorState.preview.segmentOverlap) or 0.02, len * 0.45)
    local extStart = seg.startCoords - (dir * overlap)
    local extEnd = seg.endCoords + (dir * overlap)
    local extLen = len + (overlap * 2.0)

    local midPos = extStart + ((extEnd - extStart) * 0.5)
    local up = vector3(0.0, 0.0, 1.0)

    if math.abs(dir.z) > 0.96 then
        up = vector3(1.0, 0.0, 0.0)
    end

    local right = normalizeVector(crossProduct(up, dir))
    local trueUp = normalizeVector(crossProduct(dir, right))

    local rollRad = math.rad(tonumber(editorState.preview.propRoll) or 0.0)
    right = rotateVectorAroundAxis(right, dir, rollRad)
    trueUp = rotateVectorAroundAxis(trueUp, dir, rollRad)

    local lenScale = (extLen * (tonumber(editorState.preview.propLengthRatio) or 0.5)) / (tonumber(editorState.preview.propBaseLength) or 4.0)
    local radScale = (tonumber(editorState.preview.radius) or 0.045) / (tonumber(editorState.preview.propBaseRadius) or 0.5)

    local fVec = dir * lenScale
    local rVec = right * radScale
    local uVec = trueUp * radScale

    SetEntityMatrix(seg.object, fVec.x, fVec.y, fVec.z, rVec.x, rVec.y, rVec.z, uVec.x, uVec.y, uVec.z, midPos.x, midPos.y, midPos.z)
    seg.length = extLen
    return true
end

local function updateHoseVehicleBend()
    if editorState.preview.type ~= "hoseVehicleBend" then return end
    if editorState.vehicle == 0 or not DoesEntityExist(editorState.vehicle) then return end

    local points = calculateHosePathPoints()
    local maxSegs = #points - 1

    for idx, seg in pairs(editorState.hoseSegments) do
        if idx > maxSegs then
            DeleteEntity(seg.object)
            editorState.hoseSegments[idx] = nil
        end
    end

    for i = 1, maxSegs do
        local seg = editorState.hoseSegments[i]
        if not seg then
            seg = createHoseSegment(points[i], points[i + 1])
            editorState.hoseSegments[i] = seg
        end

        if seg then
            seg.startCoords = points[i]
            seg.endCoords = points[i + 1]
            if not updateHoseSegmentMatrix(seg) then
                DeleteEntity(seg.object)
                editorState.hoseSegments[i] = nil
            end
        end
    end
end

local function updateAttachedPropPlacement()
    if editorState.preview.type == "hoseVehicleBend" then
        updateHoseVehicleBend()
        return
    end

    if editorState.vehicle == 0 or not DoesEntityExist(editorState.vehicle) then return end
    if editorState.previewProp == 0 or not DoesEntityExist(editorState.previewProp) then return end

    AttachEntityToEntity(
        editorState.previewProp,
        editorState.vehicle,
        0,
        editorState.offset.x, editorState.offset.y, editorState.offset.z,
        editorState.rotation.x, editorState.rotation.y, editorState.rotation.z,
        false, false, false, false, 2, true
    )
end

local function updateEditorCamera()
    if not (editorState.camera and DoesCamExist(editorState.camera)) then return end

    local target = editorState.cameraTarget
    if editorState.vehicle ~= 0 and DoesEntityExist(editorState.vehicle) then
        SetFocusEntity(editorState.vehicle)
        target = GetOffsetFromEntityInWorldCoords(editorState.vehicle, 0.0, 0.0, editorState.cameraFocusHeight or 0.5)
    end

    if not target then return end

    local radius = clamp(editorState.cameraRadius, editorState.cameraMin, editorState.cameraMax)
    local azimuth = editorState.cameraAngles.azimuth
    local elevation = clamp(editorState.cameraAngles.elevation, -0.2, 0.8)

    local camX = target.x + (radius * math.cos(azimuth) * math.cos(elevation))
    local camY = target.y + (radius * math.sin(azimuth) * math.cos(elevation))
    local camZ = target.z + (radius * math.sin(elevation)) + 0.35

    SetCamCoord(editorState.camera, camX, camY, camZ)
    PointCamAtCoord(editorState.camera, target.x, target.y, target.z)
end

local function processCameraInputs()
    if not editorState.active then return end

    if IsControlPressed(0, 25) then
        DisableControlAction(0, 1, true)
        DisableControlAction(0, 2, true)

        local dx = GetDisabledControlNormal(0, 1)
        local dy = GetDisabledControlNormal(0, 2)

        editorState.cameraAngles.azimuth = editorState.cameraAngles.azimuth - (dx * 4.0)
        editorState.cameraAngles.elevation = editorState.cameraAngles.elevation + (dy * 2.0)
    end

    if IsControlJustPressed(0, 241) then
        editorState.cameraRadius = editorState.cameraRadius - editorState.cameraScrollStep
    end
    if IsControlJustPressed(0, 242) then
        editorState.cameraRadius = editorState.cameraRadius + editorState.cameraScrollStep
    end
end

local function clampEditorTransformValues()
    editorState.offset.x = clamp(editorState.offset.x, -5.0, 5.0)
    editorState.offset.y = clamp(editorState.offset.y, -8.0, 3.0)
    editorState.offset.z = clamp(editorState.offset.z, -2.5, 2.0)

    editorState.rotation.x = clamp(editorState.rotation.x, -180.0, 180.0)
    editorState.rotation.y = clamp(editorState.rotation.y, -180.0, 180.0)
    editorState.rotation.z = clamp(editorState.rotation.z, -360.0, 360.0)

    updateAttachedPropPlacement()
    updateEditorOverlay()
end

local function processAttachmentControls()
    if not editorState.active then return end

    local disabledKeys = { 24, 25, 37, 36, 44, 38, 140, 141, 142 }
    for _, k in ipairs(disabledKeys) do
        DisableControlAction(0, k, true)
    end

    local dt = GetFrameTime()
    local moveSpeed = 1.8 * dt
    local rotSpeed = 90.0 * dt

    local isShiftPressed = IsDisabledControlPressed(0, 21)
    local isCtrlPressed = IsDisabledControlPressed(0, 36)
    local updated = false

    if isShiftPressed then
        if IsControlPressed(0, 32) then editorState.rotation.x = editorState.rotation.x + rotSpeed updated = true end
        if IsControlPressed(0, 33) then editorState.rotation.x = editorState.rotation.x - rotSpeed updated = true end
        if IsControlPressed(0, 34) then editorState.rotation.z = editorState.rotation.z + rotSpeed updated = true end
        if IsControlPressed(0, 35) then editorState.rotation.z = editorState.rotation.z - rotSpeed updated = true end
        if IsDisabledControlPressed(0, 44) then editorState.rotation.y = editorState.rotation.y + rotSpeed updated = true end
        if IsDisabledControlPressed(0, 38) then editorState.rotation.y = editorState.rotation.y - rotSpeed updated = true end
    else
        if IsDisabledControlPressed(0, 32) then editorState.offset.y = editorState.offset.y + moveSpeed updated = true end
        if IsDisabledControlPressed(0, 33) then editorState.offset.y = editorState.offset.y - moveSpeed updated = true end

        if isCtrlPressed then
            local rotVeh = false
            if IsDisabledControlPressed(0, 34) then
                editorState.heading = (editorState.heading + (rotSpeed * 1.5)) % 360.0
                rotVeh = true
            end
            if IsDisabledControlPressed(0, 35) then
                editorState.heading = (editorState.heading - (rotSpeed * 1.5)) % 360.0
                rotVeh = true
            end

            if rotVeh and editorState.vehicle ~= 0 and DoesEntityExist(editorState.vehicle) then
                SetEntityHeading(editorState.vehicle, editorState.heading)
                updateAttachedPropPlacement()
            end
        else
            if IsDisabledControlPressed(0, 34) then editorState.offset.x = editorState.offset.x - moveSpeed updated = true end
            if IsDisabledControlPressed(0, 35) then editorState.offset.x = editorState.offset.x + moveSpeed updated = true end
        end

        if IsDisabledControlPressed(0, 44) then editorState.offset.z = editorState.offset.z + moveSpeed updated = true end
        if IsDisabledControlPressed(0, 38) then editorState.offset.z = editorState.offset.z - moveSpeed updated = true end
    end

    if updated then
        clampEditorTransformValues()
    end

    if IsControlJustReleased(0, 201) then
        editorState.result = {
            success = true,
            data = {
                offset = editorState.offset,
                rotation = editorState.rotation
            }
        }
        cleanupEditorState()
    end

    if IsControlJustReleased(0, 177) or IsControlJustReleased(0, 202) then
        editorState.result = {
            success = false,
            error = "cancelled"
        }
        cleanupEditorState()
        showNotification("Editor cancelled.", "error")
    end
end

function Sky.JobVehicleAttachEditor.Begin(params)
    if editorState.active then
        return false, "Editor already active."
    end
    if type(params) ~= "table" then
        return false, "Unable to open the editor."
    end

    local modelRaw = params.model
    local spawnCfg = params.spawn or {}

    local spawnCoords = vector3(
        tonumber(spawnCfg.x) or 0.0,
        tonumber(spawnCfg.y) or 0.0,
        tonumber(spawnCfg.z) or 0.0
    )
    local spawnHeading = tonumber(spawnCfg.heading) or 0.0

    if type(modelRaw) ~= "number" and type(modelRaw) ~= "string" then
        return false, "Unable to open the editor."
    end

    local vehHash = (type(modelRaw) == "number") and modelRaw or joaat(modelRaw)
    local okVeh, errVeh = loadModel(vehHash)
    if not okVeh then
        return false, errVeh or "Failed to load vehicle."
    end

    editorState.preview = type(params.preview) == "table" and params.preview or {}

    if editorState.preview.type ~= "hoseVehicleBend" then
        local propModelRaw = editorState.preview.propModel or params.previewModel
        if type(propModelRaw) ~= "number" and type(propModelRaw) ~= "string" then
            return false, "Missing preview model."
        end

        local propHash = (type(propModelRaw) == "number") and propModelRaw or joaat(propModelRaw)
        local okProp, errProp = loadModel(propHash)
        if not okProp then
            return false, errProp or "Failed to load preview prop."
        end
        editorState.preview.propHash = propHash
    end

    local dims = calculateModelDimensions(vehHash)
    local targetZ = spawnCoords.z + dims.groundLift
    local adjustedSpawn = vector3(spawnCoords.x, spawnCoords.y, targetZ)

    editorState.previewInterior = pinWorldArea(adjustedSpawn)
    loadWorldSphere(adjustedSpawn, 2000)
    hidePlayerPed(adjustedSpawn, spawnHeading)

    local veh = CreateVehicle(vehHash, spawnCoords.x, spawnCoords.y, targetZ, spawnHeading, false, false)
    if not veh or veh == 0 then
        restorePlayerPed()
        unpinWorldArea(editorState.previewInterior)
        editorState.previewInterior = 0
        return false, "Failed to create preview vehicle."
    end

    SetEntityInvincible(veh, true)
    SetEntityAsMissionEntity(veh, true, true)
    SetEntityCoordsNoOffset(veh, spawnCoords.x, spawnCoords.y, targetZ, false, false, false)
    SetEntityVisible(veh, true, false)
    SetEntityAlpha(veh, 255, false)
    FreezeEntityPosition(veh, true)
    SetEntityCollision(veh, false, false)
    SetModelAsNoLongerNeeded(vehHash)

    editorState.vehicle = veh

    if editorState.preview.type ~= "hoseVehicleBend" then
        local prop = CreateObject(editorState.preview.propHash, spawnCoords.x, spawnCoords.y, targetZ, false, false, false)
        if not prop or prop == 0 then
            DeleteEntity(veh)
            restorePlayerPed()
            unpinWorldArea(editorState.previewInterior)
            editorState.previewInterior = 0
            return false, "Failed to spawn preview prop."
        end

        SetEntityAsMissionEntity(prop, true, true)
        SetEntityVisible(prop, true, false)
        SetEntityAlpha(prop, 255, false)
        SetEntityCollision(prop, false, false)
        SetModelAsNoLongerNeeded(editorState.preview.propHash)
        editorState.previewProp = prop
    end

    editorState.heading = spawnHeading
    editorState.cameraTarget = GetOffsetFromEntityInWorldCoords(veh, 0.0, 0.0, 0.0)

    local offCfg = params.offset or {}
    editorState.offset = {
        x = tonumber(offCfg.x) or 0.0,
        y = tonumber(offCfg.y) or 0.0,
        z = tonumber(offCfg.z) or 0.0
    }

    local rotCfg = params.rotation or {}
    editorState.rotation = {
        x = tonumber(rotCfg.x) or 0.0,
        y = tonumber(rotCfg.y) or 0.0,
        z = tonumber(rotCfg.z) or 0.0
    }

    local camCfg = calculateCameraConfig(dims, params.camera, false)
    editorState.cameraRadius = camCfg.radius
    editorState.cameraMin = camCfg.minRadius
    editorState.cameraMax = camCfg.maxRadius
    editorState.cameraFov = camCfg.fov
    editorState.cameraScrollStep = camCfg.scrollStep
    editorState.cameraFocusHeight = camCfg.focusHeight

    editorState.cameraAngles = {
        azimuth = math.rad((spawnHeading or 0.0) + 180.0),
        elevation = camCfg.elevation
    }

    updateAttachedPropPlacement()

    SetVehicleDoorsLocked(veh, 1)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehicleDoorsLockedForPlayer(veh, PlayerPedId(), false)

    local doorCount = GetNumberOfVehicleDoors(veh) or 0
    for i = 0, doorCount do
        SetVehicleDoorShut(veh, i, false)
    end

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    editorState.camera = cam
    SetCamFov(cam, editorState.cameraFov or 38.0)
    RenderScriptCams(true, true, 500, true, true)
    updateEditorCamera()

    editorState.active = true
    editorState.result = nil

    showEditorOverlay()
    updateEditorOverlay()

    return true
end

function Sky.JobVehicleAttachEditor.IsActive()
    return editorState.active == true
end

CreateThread(function()
    while true do
        if editorState.active then
            processCameraInputs()
            processAttachmentControls()
            updateEditorCamera()
            Wait(0)
        else
            Wait(200)
        end
    end
end)

AddEventHandler("onResourceStop", function(resName)
    if resName == GetCurrentResourceName() and editorState.active then
        cleanupEditorState()
    end
end)

RegisterNUICallback("jobConfigurator:editVehicleAttach", function(data, cb)
    if editorState.active then
        cb({ success = false, error = "placement_active" })
        return
    end

    data = type(data) == "table" and data or {}
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)

    local spawn = data.spawn or {
        x = coords.x + (forward.x * 3.5),
        y = coords.y + (forward.y * 3.5),
        z = coords.z,
        heading = GetEntityHeading(ped)
    }

    local ok, err = Sky.JobVehicleAttachEditor.Begin({
        model = data.model,
        offset = data.offset,
        rotation = data.rotation,
        spawn = spawn,
        camera = data.camera,
        preview = data.preview
    })

    if not ok then
        SetNuiFocus(true, true)
        cb({ success = false, error = err or "request_failed" })
        return
    end

    CreateThread(function()
        while editorState.active do
            Wait(0)
        end

        local res = editorState.result or { success = false, error = "cancelled" }
        editorState.result = nil

        SetNuiFocus(true, true)
        cb(res)
    end)
end)
