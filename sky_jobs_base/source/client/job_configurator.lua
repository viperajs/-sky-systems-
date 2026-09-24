if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/job_configurator.lua") end
-- =====================================================
--  sky_jobs_base · source/client/job_configurator.lua
--  Deobfuscated & Cleaned
-- =====================================================

local DEFAULT_CONFIG_KEY = "sky_mechanicjob"
local DEFAULT_PRIMARY_COLOR = "#EDC001"
local MODEL_LOAD_TIMEOUT = 5000
local COLLISION_LOAD_TIMEOUT = 5000
local CARRY_ANIM_DICT = "anim@heists@box_carry@"
local CARRY_ANIM_NAME = "idle"
local ZONE_PREVIEW_HEIGHT = 100.0
local ZONE_PREVIEW_STEP = 5.0

local currentConfigKey = nil
local isPlacementActive = false
local locationDefinitionsMap = {}
local openOptions = {}
local cachedEntries = {}

-- Preview entity and ped of the running placement editor, released on resource stop.
local activePlacement = {
    entity = nil,
    ped = nil
}

local zonePreviewState = {
    active = false,
    points = {}
}

local placementConfig = {
    moveStep = 0.08,
    rotateStep = 3.0,
    heightStep = 0.05,
    previewAlpha = 200
}

local zoneMarkerOptions = {
    offset = vector3(0.0, 0.0, 0.2),
    type = 1,
    scaleX = 0.35, scaleY = 0.35, scaleZ = 0.35,
    r = 255, g = 140, b = 0, a = 160
}

local defaultCreatorSections = {
    { key = "general", label = "General", icon = "sliders" },
    { key = "shop", label = "Shop", icon = "shopping-cart" },
    { key = "props", label = "Props", icon = "box" },
    { key = "vehicles", label = "Vehicles", icon = "car" },
    { key = "locations", label = "Locations", icon = "map-pin" },
    { key = "partsDelivery", label = "Parts Delivery", icon = "truck" },
    { key = "tuningPrices", label = "Tuning Prices", icon = "wrench" }
}

local defaultExtensions = {
    { key = "workshops", label = "Workshops", icon = "map-pin" },
    { key = "partsTheft", label = "Parts Theft", icon = "wrench" },
    { key = "vehicleCare", label = "Vehicle Care", icon = "sparkles" },
    { key = "wear", label = "Wear", icon = "activity" },
    { key = "wheelDamage", label = "Wheel Damage", icon = "gauge" },
    { key = "mileageHud", label = "Mileage HUD", icon = "hash" },
    { key = "carryItems", label = "Carry Items", icon = "box" },
    { key = "features", label = "Features", icon = "sliders" },
    { key = "interactions", label = "Interactions", icon = "mouse-pointer" }
}

local function getLocales()
    local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
    local current = Locales and Locales[localeKey]
    if type(current) == "table" and type(current.Nui) == "table" then
        return current.Nui
    end

    local fallback = Locales and Locales.en
    if type(fallback) == "table" and type(fallback.Nui) == "table" then
        return fallback.Nui
    end
    return {}
end

-- Global because source/client/creator.lua calls it with its own creator data.
-- Only an array of location definitions replaces the configurator cache.
function cacheLocationDefinitions(defs)
    if type(defs) ~= "table" or type(defs[1]) ~= "table" then return end

    locationDefinitionsMap = {}
    for _, def in ipairs(defs) do
        if type(def) == "table" and type(def.key) == "string" then
            locationDefinitionsMap[def.key] = def
        end
    end
end

local function requestFailed()
    return { success = false, error = "request_failed" }
end

local function triggerServer(name, data)
    local res = Sky.Cb.Trigger(name, data)
    if type(res) ~= "table" then
        return requestFailed()
    end
    return res
end

local function withConfigKey(data)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey
    return data
end

local function firstTable(...)
    for i = 1, select("#", ...) do
        local value = select(i, ...)
        if type(value) == "table" then
            return value
        end
    end
    return nil
end

-- The NUI identifies an entry by jobId/jobName, the server by entryId/entryName.
local function resolveEntryId(data)
    local entryId = data.entryId or data.jobId
    if entryId ~= nil and entryId ~= "" then
        return entryId
    end

    local name = data.entryName or data.jobName
    if type(name) == "string" and name ~= "" then
        for _, entry in ipairs(cachedEntries) do
            if type(entry) == "table" and entry.name == name then
                return entry.id
            end
        end
    end
    return nil
end

-- Builds the object the NUI configurator store loads with applyContext().
-- The store reads the entry list from `entries` only and resets every field that
-- is missing, so each response must carry the complete context.
local function buildContext(serverData, options, optionsFirst)
    serverData = type(serverData) == "table" and serverData or {}
    options = type(options) == "table" and options or {}

    local first, second = serverData, options
    local entries
    if optionsFirst then
        first, second = options, serverData
        entries = firstTable(options.entries, options.configs, serverData.entries, serverData.jobs, serverData.workshops, serverData.configs)
    else
        entries = firstTable(serverData.entries, serverData.jobs, serverData.workshops, serverData.configs)
    end
    entries = entries or {}
    cachedEntries = entries

    local function pick(key)
        local value = first[key]
        if value == nil then
            value = second[key]
        end
        return value
    end

    local locationDefinitions = pick("locationDefinitions") or {}
    cacheLocationDefinitions(locationDefinitions)

    return {
        configKey = serverData.configKey or currentConfigKey,
        title = options.title or serverData.title or "Mechanic Jobs",
        subtitle = options.subtitle or serverData.subtitle or "Configure mechanic jobs, shops, vehicles, and workshop locations.",
        primaryColor = options.primaryColor or DEFAULT_PRIMARY_COLOR,
        lang = options.lang or (Sky and Sky.Config and Sky.Config.locale) or "en",
        entries = entries,
        locationDefinitions = locationDefinitions,
        creatorSections = options.creatorSections or serverData.creatorSections or defaultCreatorSections,
        extensions = options.extensions or serverData.extensions or defaultExtensions,
        featureDefinitions = pick("featureDefinitions") or {},
        features = pick("features") or {},
        settingDefinitions = pick("settingDefinitions") or {},
        settings = pick("settings") or {},
        interactionDefinitions = pick("interactionDefinitions") or {},
        interactions = pick("interactions") or {},
        -- UI hints only; the server callbacks must enforce who may edit.
        canEdit = true,
        isAdmin = true,
        hasPermission = true,
        permissions = {
            canEdit = true,
            canDelete = true,
            canCreate = true,
            canSave = true,
            canPlace = true
        }
    }
end

local function fetchContext(configKey)
    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:list", { configKey = configKey or currentConfigKey })
    if type(res) ~= "table" or not res.success or type(res.data) ~= "table" then
        return nil
    end
    return buildContext(res.data, openOptions, false)
end

-- Answers a successful write with the refreshed context so the NUI shows the change.
-- Named fields of the original response (uid, entryId, coords, ...) are kept.
local function withContext(res, configKey)
    if type(res) ~= "table" then
        return requestFailed()
    end
    if not res.success then
        return res
    end

    local context = fetchContext(configKey)
    if not context then
        return res
    end

    for _, source in ipairs({ res.data, res }) do
        if type(source) == "table" then
            for key, value in pairs(source) do
                if type(key) == "string" and context[key] == nil and key ~= "success" and key ~= "error" and key ~= "data" then
                    context[key] = value
                end
            end
        end
    end

    res.data = context
    return res
end

local function getPlacementModel(locationData)
    if type(locationData.placementModel) == "string" and locationData.placementModel ~= "" then
        return locationData.placementModel
    end

    local locType = locationData.locationType
    local def = locationDefinitionsMap[locType]
    if def and type(def.placementModel) == "string" and def.placementModel ~= "" then
        return def.placementModel
    end
    return nil
end

local function getPlacementEditor(locationData)
    if type(locationData.placementEditor) == "string" and locationData.placementEditor ~= "" then
        return locationData.placementEditor
    end

    local locType = locationData.locationType
    local def = locationDefinitionsMap[locType]
    if def and type(def.placementEditor) == "string" and def.placementEditor ~= "" then
        return def.placementEditor
    end
    return nil
end

local function runCustomPlacementEditor(editorName, locationData)
    if editorName == "hospitalBed" and locationData.configKey == "sky_ambulancejob" and GetResourceState("sky_ambulancejob") == "started" then
        local ok, res = pcall(function()
            return exports.sky_ambulancejob:OpenJobConfiguratorHospitalBedPlacement({
                entryId = locationData.entryId,
                entryName = locationData.entryName,
                coords = locationData.coords
            })
        end)
        if ok and type(res) == "table" then
            return res
        end
        print(("[sky_jobs_base][job_configurator] placement editor %s failed: %s"):format(editorName, tostring(res)))
        return { success = false, error = "placement_editor_failed" }
    end

    return {
        success = false,
        error = "unsupported_placement_editor"
    }
end

local function parseZonePoints(pointsData)
    local result = {}
    local rawList = (type(pointsData) == "table" and pointsData) or {}

    for _, pt in ipairs(rawList) do
        local coords = (type(pt) == "table" and (pt.coords or pt)) or nil
        if type(coords) == "table" and coords.x and coords.y and coords.z then
            table.insert(result, {
                x = tonumber(coords.x) or 0.0,
                y = tonumber(coords.y) or 0.0,
                z = tonumber(coords.z) or 0.0
            })
        end
    end
    return result
end

local function drawZonePreview(points)
    local count = #points
    for i = 1, count do
        local p1 = points[i]
        DrawLine(p1.x, p1.y, p1.z, p1.x, p1.y, p1.z + ZONE_PREVIEW_HEIGHT, 255, 140, 0, 200)

        if count >= 2 then
            local p2 = points[(i % count) + 1]
            for h = 0.0, ZONE_PREVIEW_HEIGHT, ZONE_PREVIEW_STEP do
                DrawLine(p1.x, p1.y, p1.z + h, p2.x, p2.y, p2.z + h, 255, 140, 0, 180)
            end
        end

        Sky.Show.Marker(p1, zoneMarkerOptions)
    end
end

CreateThread(function()
    while true do
        if zonePreviewState.active and #zonePreviewState.points > 0 then
            drawZonePreview(zonePreviewState.points)
            Wait(0)
        else
            Wait(500)
        end
    end
end)

local function getCameraRotationVector(rot)
    local radZ = math.rad(rot.z)
    local radX = math.rad(rot.x)
    local num = math.abs(math.cos(radX))

    return vector3(-math.sin(radZ) * num, math.cos(radZ) * num, 0.0)
end

local function getCameraDirectionVectors()
    local rot = GetGameplayCamRot(2)
    local forward = getCameraRotationVector(rot)
    local right = vector3(-forward.y, forward.x, 0.0)
    return forward, right
end

local function getModelBottomOffset(modelHash)
    local min = GetModelDimensions(modelHash)
    if min and min.z then
        return min.z
    end
    return 0.0
end

local function adjustCoordsToGround(coords, bottomOffset)
    local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 1.0, false)
    if found then
        return vector3(coords.x, coords.y, groundZ - bottomOffset)
    end
    return coords
end

local function requestModel(modelHash)
    if not IsModelInCdimage(modelHash) then
        return false
    end

    RequestModel(modelHash)
    local expire = GetGameTimer() + MODEL_LOAD_TIMEOUT
    while not HasModelLoaded(modelHash) do
        if GetGameTimer() > expire then
            return false
        end
        Wait(0)
    end
    return true
end

local function getPlacementHelpText()
    local locKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
    local currentLoc = (Locales and Locales[locKey]) or (Locales and Locales.en) or {}
    local fallbackLoc = (Locales and Locales.en) or {}

    local helpMsg = (currentLoc.Nui and currentLoc.Nui.creator and currentLoc.Nui.creator.placementHelp)
        or (fallbackLoc.Nui and fallbackLoc.Nui.creator and fallbackLoc.Nui.creator.placementHelp)
        or "Arrows move, PageUp/PageDown height, Q/E rotate, Enter place, Backspace cancel."

    return helpMsg
end

-- A single text component holds at most 99 bytes; longer text is split without
-- cutting a multi-byte UTF-8 character.
local function addTextComponents(text)
    local maxBytes = 99
    local len = #text
    local i = 1
    while i <= len do
        local j = math.min(i + maxBytes - 1, len)
        while j < len and j > i do
            local nextByte = text:byte(j + 1)
            if nextByte < 0x80 or nextByte >= 0xC0 then break end
            j = j - 1
        end
        AddTextComponentSubstringPlayerName(text:sub(i, j))
        i = j + 1
    end
end

local function setOverlayTextStyle()
    SetTextFont(4)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 230)
    SetTextCentre(true)
    SetTextOutline()
end

local function drawTextOverlay(text)
    if type(text) ~= "string" or text == "" then return end

    -- Each text command consumes the pending style, so it is set for the width
    -- measurement and again for the draw.
    setOverlayTextStyle()
    BeginTextCommandGetWidth("STRING")
    addTextComponents(text)
    local width = EndTextCommandGetWidth(true)

    local padding = 0.008
    local baseHeight = 0.03
    local rectW = width + (padding * 2)
    local rectH = baseHeight + (padding * 2)

    DrawRect(0.5, 0.9, rectW, rectH, 0, 0, 0, 160)

    setOverlayTextStyle()
    BeginTextCommandDisplayText("STRING")
    addTextComponents(text)
    EndTextCommandDisplayText(0.5, 0.9 - (baseHeight * 0.5))
end

local function drawPlacementPrompt()
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName("Press ~INPUT_FRONTEND_RDOWN~ to place location at your position, or ~INPUT_FRONTEND_RRIGHT~ to cancel.")
    EndTextCommandDisplayHelp(0, false, false, -1)
end

local function drawCarryAttachOverlay(attachData)
    local fmt = "Arrows X/Y, PageUp/PageDown Z, Q/E rotate Z, Shift+Q/E rotate Y, Ctrl+Q/E rotate X, Enter save, Backspace cancel | %.2f %.2f %.2f / %.1f %.1f %.1f"
    local text = string.format(fmt,
        tonumber(attachData.x) or 0.0,
        tonumber(attachData.y) or 0.0,
        tonumber(attachData.z) or 0.0,
        tonumber(attachData.rx) or 0.0,
        tonumber(attachData.ry) or 0.0,
        tonumber(attachData.rz) or 0.0
    )
    drawTextOverlay(text)
end

local function loadAnimDictTimeout(dict, timeout)
    RequestAnimDict(dict)
    local expire = GetGameTimer() + (timeout or 2500)
    while not HasAnimDictLoaded(dict) and GetGameTimer() < expire do
        Wait(0)
    end
    return HasAnimDictLoaded(dict)
end

local function playCarryAnimation(ped)
    if not HasAnimDictLoaded(CARRY_ANIM_DICT) then return false end

    TaskPlayAnim(ped, CARRY_ANIM_DICT, CARRY_ANIM_NAME, 4.0, -4.0, -1, 49, 0.0, false, false, false)
    return true
end

local function attachEntityToPedBone(entity, ped, attachData)
    local boneIdx = GetPedBoneIndex(ped, tonumber(attachData.bone) or 28422)
    local x = tonumber(attachData.x) or 0.0
    local y = tonumber(attachData.y) or 0.0
    local z = tonumber(attachData.z) or 0.0
    local rx = tonumber(attachData.rx) or 0.0
    local ry = tonumber(attachData.ry) or 0.0
    local rz = tonumber(attachData.rz) or 0.0

    AttachEntityToEntity(entity, ped, boneIdx, x, y, z, rx, ry, rz, true, true, false, true, 1, true)
end

local function releasePlacementEntity()
    local entity = activePlacement.entity
    if entity and DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
    activePlacement.entity = nil

    local ped = activePlacement.ped
    if ped then
        if DoesEntityExist(ped) then
            ClearPedTasks(ped)
        end
        RemoveAnimDict(CARRY_ANIM_DICT)
    end
    activePlacement.ped = nil
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    releasePlacementEntity()
end)

local function disablePlacementControls()
    DisableControlAction(0, 30, true)  -- Move left/right
    DisableControlAction(0, 31, true)  -- Move forward/back
    DisableControlAction(0, 21, true)  -- Shift (sprint)
    DisableControlAction(0, 22, true)  -- Space (jump)
    DisableControlAction(0, 36, true)  -- Ctrl (stealth)
    DisableControlAction(0, 44, true)  -- Q (cover)
    DisableControlAction(0, 38, true)  -- E
    DisableControlAction(0, 140, true)
    DisableControlAction(0, 141, true)
    DisableControlAction(0, 142, true)
    DisableControlAction(0, 24, true)  -- Attack
    DisableControlAction(0, 25, true)  -- Aim
    DisableControlAction(0, 200, true) -- Esc pause menu, Esc cancels instead
end

local function startCarryItemAttachEditor(data, cb)
    if isPlacementActive then
        cb({ success = false, error = "placement_active" })
        return
    end

    local propName = (type(data.prop) == "string" and data.prop ~= "") and data.prop or ""
    if propName == "" then
        cb({ success = false, error = "missing_prop" })
        return
    end

    isPlacementActive = true

    local modelHash = joaat(propName)
    if not requestModel(modelHash) then
        isPlacementActive = false
        cb({ success = false, error = "model_missing" })
        return
    end

    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)

    local objectEntity = CreateObjectNoOffset(modelHash, pCoords.x, pCoords.y, pCoords.z + 0.2, false, false, false)
    SetModelAsNoLongerNeeded(modelHash)
    if not objectEntity or objectEntity == 0 then
        isPlacementActive = false
        cb({ success = false, error = "spawn_failed" })
        return
    end

    activePlacement.entity = objectEntity
    activePlacement.ped = ped

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        type = "jobConfigurator:placement",
        active = true,
        label = data.label or data.item or propName
    })

    local attachData = type(data.attach) == "table" and data.attach or {}
    local currentAttach = {
        bone = tonumber(attachData.bone) or 28422,
        x = tonumber(attachData.x) or 0.0,
        y = tonumber(attachData.y) or -0.12,
        z = tonumber(attachData.z) or -0.12,
        rx = tonumber(attachData.rx) or 0.0,
        ry = tonumber(attachData.ry) or 0.0,
        rz = tonumber(attachData.rz) or 0.0
    }

    local moveStep = tonumber(data.moveStep) or 0.01
    local rotateStep = tonumber(data.rotateStep) or 1.0

    SetEntityCollision(objectEntity, false, false)
    SetEntityAlpha(objectEntity, 220, false)

    attachEntityToPedBone(objectEntity, ped, currentAttach)
    loadAnimDictTimeout(CARRY_ANIM_DICT, 2500)
    playCarryAnimation(ped)

    local function finish(result)
        releasePlacementEntity()
        isPlacementActive = false
        SendNUIMessage({ type = "jobConfigurator:placement", active = false })
        SetNuiFocus(true, true)
        cb(result)
    end

    CreateThread(function()
        while true do
            disablePlacementControls()
            drawCarryAttachOverlay(currentAttach)

            if not DoesEntityExist(objectEntity) then
                finish({ success = false, error = "cancelled" })
                return
            end

            if not IsEntityPlayingAnim(ped, CARRY_ANIM_DICT, CARRY_ANIM_NAME, 3) then
                playCarryAnimation(ped)
            end

            local changed = false
            if IsControlPressed(0, 172) then -- Arrow Up
                currentAttach.y = currentAttach.y + moveStep
                changed = true
            end
            if IsControlPressed(0, 173) then -- Arrow Down
                currentAttach.y = currentAttach.y - moveStep
                changed = true
            end
            if IsControlPressed(0, 174) then -- Arrow Left
                currentAttach.x = currentAttach.x - moveStep
                changed = true
            end
            if IsControlPressed(0, 175) then -- Arrow Right
                currentAttach.x = currentAttach.x + moveStep
                changed = true
            end
            if IsControlPressed(0, 10) then -- Page Up
                currentAttach.z = currentAttach.z + moveStep
                changed = true
            end
            if IsControlPressed(0, 11) then -- Page Down
                currentAttach.z = currentAttach.z - moveStep
                changed = true
            end

            local shiftHeld = IsDisabledControlPressed(0, 21)
            local ctrlHeld = IsDisabledControlPressed(0, 36)

            if IsDisabledControlPressed(0, 44) then -- Q
                if shiftHeld then
                    currentAttach.ry = currentAttach.ry - rotateStep
                elseif ctrlHeld then
                    currentAttach.rx = currentAttach.rx - rotateStep
                else
                    currentAttach.rz = currentAttach.rz - rotateStep
                end
                changed = true
            end

            if IsDisabledControlPressed(0, 38) then -- E
                if shiftHeld then
                    currentAttach.ry = currentAttach.ry + rotateStep
                elseif ctrlHeld then
                    currentAttach.rx = currentAttach.rx + rotateStep
                else
                    currentAttach.rz = currentAttach.rz + rotateStep
                end
                changed = true
            end

            if changed then
                attachEntityToPedBone(objectEntity, ped, currentAttach)
            end

            if IsControlJustPressed(0, 191) then -- Enter
                finish({ success = true, data = { attach = currentAttach } })
                return
            end

            if IsControlJustPressed(0, 177) then -- Backspace / Esc
                finish({ success = false, error = "cancelled" })
                return
            end

            Wait(0)
        end
    end)
end

-- Runs inside an existing placement session; cb receives the chosen coords.
local function startPropPlacement(modelName, cb)
    local modelHash = joaat(modelName)
    if not requestModel(modelHash) then
        cb({ success = false, error = "model_missing" })
        return
    end

    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)
    local pForward = GetEntityForwardVector(ped)

    local spawnPos = vector3(
        pCoords.x + (pForward.x * 1.5),
        pCoords.y + (pForward.y * 1.5),
        pCoords.z
    )

    local bottomOffset = getModelBottomOffset(modelHash)
    -- Ground-snapped position without the user's height offset.
    local basePos = adjustCoordsToGround(spawnPos, bottomOffset)

    local propObj = CreateObjectNoOffset(modelHash, basePos.x, basePos.y, basePos.z, false, false, false)
    SetModelAsNoLongerNeeded(modelHash)
    if not propObj or propObj == 0 then
        cb({ success = false, error = "spawn_failed" })
        return
    end

    activePlacement.entity = propObj

    local moveStep = tonumber(placementConfig.moveStep) or 0.08
    local rotateStep = tonumber(placementConfig.rotateStep) or 3.0
    local heightStep = tonumber(placementConfig.heightStep) or 0.05
    local alphaVal = math.floor(math.max(100, math.min(255, tonumber(placementConfig.previewAlpha) or 200)))

    local helpText = getPlacementHelpText()
    local heightOffset = 0.0

    SetEntityHeading(propObj, GetEntityHeading(ped))
    SetEntityCollision(propObj, false, false)
    FreezeEntityPosition(propObj, true)
    SetEntityAlpha(propObj, alphaVal, false)

    local function finish(result)
        releasePlacementEntity()
        cb(result)
    end

    CreateThread(function()
        while true do
            disablePlacementControls()
            drawTextOverlay(helpText)

            if not DoesEntityExist(propObj) then
                finish({ success = false, error = "cancelled" })
                return
            end

            local camForward, camRight = getCameraDirectionVectors()
            local moveVec = vector3(0.0, 0.0, 0.0)

            if IsControlPressed(0, 172) then moveVec = moveVec + (camForward * moveStep) end
            if IsControlPressed(0, 173) then moveVec = moveVec - (camForward * moveStep) end
            if IsControlPressed(0, 174) then moveVec = moveVec - (camRight * moveStep) end
            if IsControlPressed(0, 175) then moveVec = moveVec + (camRight * moveStep) end

            local changed = false
            if IsControlPressed(0, 10) then
                heightOffset = heightOffset + heightStep
                changed = true
            end
            if IsControlPressed(0, 11) then
                heightOffset = heightOffset - heightStep
                changed = true
            end

            if moveVec.x ~= 0.0 or moveVec.y ~= 0.0 then
                local nextBase = vector3(basePos.x + moveVec.x, basePos.y + moveVec.y, basePos.z)
                basePos = adjustCoordsToGround(nextBase, bottomOffset)
                changed = true
            end

            if changed then
                SetEntityCoordsNoOffset(propObj, basePos.x, basePos.y, basePos.z + heightOffset, false, false, false)
            end

            if IsDisabledControlPressed(0, 44) then
                SetEntityHeading(propObj, GetEntityHeading(propObj) - rotateStep)
            end
            if IsDisabledControlPressed(0, 38) then
                SetEntityHeading(propObj, GetEntityHeading(propObj) + rotateStep)
            end

            if IsControlJustPressed(0, 191) then -- Enter
                local finalCoords = GetEntityCoords(propObj)
                local finalHeading = GetEntityHeading(propObj)
                finish({
                    success = true,
                    coords = {
                        x = finalCoords.x,
                        y = finalCoords.y,
                        z = finalCoords.z,
                        heading = finalHeading
                    }
                })
                return
            end

            if IsControlJustPressed(0, 177) then -- Backspace / Esc
                finish({ success = false, error = "cancelled" })
                return
            end

            Wait(0)
        end
    end)
end

RegisterNetEvent("sky_jobs_base:jobConfigurator:sync", function(configKey, data, extra1, extra2, extra3)
    if type(configKey) ~= "string" or type(data) ~= "table" then
        print("[sky_jobs_base][job_configurator] sync failed: invalid payload")
        return
    end

    TriggerEvent("sky_jobs_base:jobConfigurator:updated", configKey, data,
        type(extra1) == "table" and extra1 or {},
        type(extra2) == "table" and extra2 or {},
        type(extra3) == "table" and extra3 or {}
    )
end)

RegisterNetEvent("sky_jobs_base:jobConfigurator:open", function(configKey, options)
    if isPlacementActive then return end

    currentConfigKey = (type(configKey) == "string" and configKey ~= "") and configKey or DEFAULT_CONFIG_KEY
    options = type(options) == "table" and options or {}
    openOptions = options

    local listRes = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:list", { configKey = currentConfigKey })
    local serverData = {}
    if type(listRes) == "table" and listRes.success and type(listRes.data) == "table" then
        serverData = listRes.data
    else
        print(("[sky_jobs_base][job_configurator] list failed for %s: %s"):format(currentConfigKey, tostring(type(listRes) == "table" and listRes.error or "no_response")))
    end

    local context = buildContext(serverData, options, true)
    context.locales = getLocales()

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    Wait(0)
    SetNuiFocus(true, true)

    SendNUIMessage({
        type = "jobConfigurator:open",
        data = context
    })
end)

RegisterNUICallback("jobConfigurator:configs", function(data, cb)
    local res = triggerServer("sky_jobs_base:jobConfigurator:configs", {})

    -- The selector reads data.configs; the server answers with a bare array.
    if res.success and type(res.data) == "table" and res.data.configs == nil then
        local configs = {}
        for _, config in ipairs(res.data) do
            if type(config) == "table" then
                config.configKey = config.configKey or config.key
                configs[#configs + 1] = config
            end
        end
        res.data = { configs = configs }
    end
    cb(res)
end)

RegisterNUICallback("jobConfigurator:list", function(data, cb)
    data = withConfigKey(data)

    local res = triggerServer("sky_jobs_base:jobConfigurator:list", data)
    if res.success and type(res.data) == "table" then
        res.data = buildContext(res.data, openOptions, false)
    end
    cb(res)
end)

RegisterNUICallback("jobConfigurator:save", function(data, cb)
    data = withConfigKey(data)
    cb(withContext(triggerServer("sky_jobs_base:jobConfigurator:save", data), data.configKey))
end)

RegisterNUICallback("jobConfigurator:saveFeatures", function(data, cb)
    data = withConfigKey(data)
    cb(triggerServer("sky_jobs_base:jobConfigurator:saveFeatures", data))
end)

RegisterNUICallback("jobConfigurator:saveSettings", function(data, cb)
    data = withConfigKey(data)
    cb(triggerServer("sky_jobs_base:jobConfigurator:saveSettings", data))
end)

RegisterNUICallback("jobConfigurator:saveInteractions", function(data, cb)
    data = withConfigKey(data)
    cb(triggerServer("sky_jobs_base:jobConfigurator:saveInteractions", data))
end)

RegisterNUICallback("jobConfigurator:delete", function(data, cb)
    data = withConfigKey(data)
    -- The NUI sends the whole entry as `job`; the server looks up `id`.
    if data.id == nil and type(data.job) == "table" then
        data.id = data.job.id
    end
    cb(withContext(triggerServer("sky_jobs_base:jobConfigurator:delete", data), data.configKey))
end)

RegisterNUICallback("jobConfigurator:createCreatorEntry", function(data, cb)
    data = withConfigKey(data)

    local res = triggerServer("sky_jobs_base:jobConfigurator:createCreatorEntry", data)
    -- The NUI reads the new id from data.entryId.
    if res.success and type(res.data) ~= "table" then
        res.data = { entryId = res.entryId, entry = res.entry }
    end
    cb(res)
end)

RegisterNUICallback("jobConfigurator:saveCreatorEntry", function(data, cb)
    data = withConfigKey(data)
    cb(triggerServer("sky_jobs_base:jobConfigurator:saveCreatorEntry", data))
end)

RegisterNUICallback("jobConfigurator:deleteCreatorEntry", function(data, cb)
    data = withConfigKey(data)
    cb(triggerServer("sky_jobs_base:jobConfigurator:deleteCreatorEntry", data))
end)

RegisterNUICallback("jobConfigurator:placeLocation", function(data, cb)
    if isPlacementActive then
        cb({ success = false, error = "placement_active" })
        return
    end

    data = withConfigKey(data)
    data.entryId = resolveEntryId(data)
    data.entryName = data.entryName or data.jobName
    data.uid = data.uid or data.pointUid
    -- Without allowMultiple the server overwrites the first point of the same type,
    -- so re-placing a known point or adding another one must set it.
    if data.createNewPoint == true or data.uid ~= nil then
        data.allowMultiple = true
    end

    local configKey = data.configKey
    local function saveLocation()
        return withContext(triggerServer("sky_jobs_base:jobConfigurator:setLocation", data), configKey)
    end

    local customEditor = getPlacementEditor(data)
    if customEditor then
        isPlacementActive = true
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)

        CreateThread(function()
            local res = runCustomPlacementEditor(customEditor, data)
            local finalRes

            if type(res) == "table" and res.success and type(res.coords) == "table" then
                data.coords = res.coords
                finalRes = saveLocation()
            else
                finalRes = { success = false, error = (type(res) == "table" and res.error) or "request_failed" }
            end

            isPlacementActive = false
            SetNuiFocus(true, true)
            cb(finalRes)
        end)
        return
    end

    isPlacementActive = true
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        type = "jobConfigurator:placement",
        active = true,
        label = data.label or data.locationType or "Location"
    })

    local function finishPlacement(resData)
        isPlacementActive = false
        SendNUIMessage({ type = "jobConfigurator:placement", active = false })
        SetNuiFocus(true, true)
        cb(resData)
    end

    local propModel = getPlacementModel(data)

    CreateThread(function()
        -- Wait until the key that submitted the NUI action is released.
        while IsControlPressed(0, 191) or IsControlPressed(0, 201) do
            Wait(0)
        end

        local resultPayload = nil
        while not resultPayload do
            Wait(0)
            DisableControlAction(0, 200, true)
            drawPlacementPrompt()

            if IsControlJustReleased(0, 191) or IsControlJustReleased(0, 201) or IsControlJustReleased(0, 38) then -- ENTER or E
                if propModel then
                    local placement = nil
                    startPropPlacement(propModel, function(pRes)
                        placement = pRes or { success = false, error = "request_failed" }
                    end)

                    while not placement do Wait(0) end

                    if placement.success and type(placement.coords) == "table" then
                        data.coords = placement.coords
                        resultPayload = saveLocation()
                    else
                        resultPayload = { success = false, error = placement.error or "request_failed" }
                    end
                else
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)
                    data.coords = {
                        x = coords.x,
                        y = coords.y,
                        z = coords.z - 1.0,
                        heading = GetEntityHeading(ped)
                    }

                    resultPayload = saveLocation()
                end
            elseif IsControlJustReleased(0, 177) or IsControlJustReleased(0, 202) then
                resultPayload = { success = false, error = "cancelled" }
            end
        end

        finishPlacement(resultPayload)
    end)
end)

RegisterNUICallback("jobConfigurator:teleportLocation", function(data, cb)
    data = type(data) == "table" and data or {}
    local coords = type(data.coords) == "table" and data.coords or {}

    local x = tonumber(coords.x)
    local y = tonumber(coords.y)
    local z = tonumber(coords.z)

    if not (x and y and z) then
        print(string.format("[sky_jobs_base][job_configurator] teleport failed: invalid coords x=%s y=%s z=%s", tostring(coords.x), tostring(coords.y), tostring(coords.z)))
        cb({ success = false, error = "invalid_coords" })
        return
    end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local entityToTeleport = (veh ~= 0 and veh) or ped

    -- Hold the entity until collision streams in so it does not fall through the map.
    RequestCollisionAtCoord(x, y, z)
    FreezeEntityPosition(entityToTeleport, true)
    SetEntityCoords(entityToTeleport, x, y, z, false, false, false, false)

    local heading = tonumber(coords.heading or data.heading)
    if heading then
        SetEntityHeading(entityToTeleport, heading)
    end

    local expire = GetGameTimer() + COLLISION_LOAD_TIMEOUT
    while not HasCollisionLoadedAroundEntity(entityToTeleport) and GetGameTimer() < expire do
        RequestCollisionAtCoord(x, y, z)
        Wait(0)
    end
    FreezeEntityPosition(entityToTeleport, false)

    cb({ success = true })
end)

RegisterNUICallback("jobConfigurator:getCurrentLocation", function(data, cb)
    local ped = PlayerPedId()
    if not (ped and ped ~= 0 and DoesEntityExist(ped)) then
        cb({ success = false, error = "player_missing" })
        return
    end

    local coords = GetEntityCoords(ped)
    cb({
        success = true,
        data = {
            coords = {
                x = coords.x,
                y = coords.y,
                z = coords.z - 1.0,
                heading = GetEntityHeading(ped)
            }
        }
    })
end)

RegisterNUICallback("jobConfigurator:deleteLocations", function(data, cb)
    data = withConfigKey(data)
    local configKey = data.configKey
    local entryId = resolveEntryId(data)

    if type(data.points) ~= "table" then
        data.entryId = entryId
        cb(withContext(triggerServer("sky_jobs_base:jobConfigurator:deleteLocations", data), configKey))
        return
    end

    -- The NUI sends a `points` list the server does not read. Delete each point by
    -- uid; the point type is left out because it would remove every point of that type.
    local res = { success = true }
    for _, point in ipairs(data.points) do
        local uid = type(point) == "table" and (point.pointUid or point.uid) or nil
        if uid ~= nil and uid ~= "" then
            res = triggerServer("sky_jobs_base:jobConfigurator:deleteLocations", {
                configKey = configKey,
                entryId = point.entryId or entryId,
                uid = uid
            })
            if not res.success then break end
        end
    end

    cb(withContext(res, configKey))
end)

local function startZonePointPlacement(data, rpcEvent, cb)
    if isPlacementActive then
        cb({ success = false, error = "placement_active" })
        return
    end

    isPlacementActive = true
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        type = "jobConfigurator:placement",
        active = true,
        label = data.label or "Zone point"
    })

    local function finishPlacement(resData)
        isPlacementActive = false
        SendNUIMessage({ type = "jobConfigurator:placement", active = false })
        SetNuiFocus(true, true)
        cb(resData)
    end

    CreateThread(function()
        while IsControlPressed(0, 191) or IsControlPressed(0, 201) do
            Wait(0)
        end

        local resultPayload = nil
        while not resultPayload do
            Wait(0)
            DisableControlAction(0, 200, true)
            drawPlacementPrompt()

            if IsControlJustReleased(0, 191) or IsControlJustReleased(0, 201) then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                data.coords = {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z - 1.0
                }

                resultPayload = triggerServer(rpcEvent, data)
            elseif IsControlJustReleased(0, 177) or IsControlJustReleased(0, 202) then
                resultPayload = { success = false, error = "cancelled" }
            end
        end

        finishPlacement(resultPayload)
    end)
end

RegisterNUICallback("jobConfigurator:addCreatorZonePoint", function(data, cb)
    data = withConfigKey(data)
    startZonePointPlacement(data, "sky_jobs_base:jobConfigurator:addCreatorZonePoint", cb)
end)

RegisterNUICallback("jobConfigurator:setCreatorZonePoint", function(data, cb)
    data = withConfigKey(data)
    startZonePointPlacement(data, "sky_jobs_base:jobConfigurator:setCreatorZonePoint", cb)
end)

RegisterNUICallback("jobConfigurator:removeCreatorZonePoint", function(data, cb)
    data = withConfigKey(data)
    cb(triggerServer("sky_jobs_base:jobConfigurator:removeCreatorZonePoint", data))
end)

RegisterNUICallback("jobConfigurator:clearCreatorZonePoints", function(data, cb)
    data = withConfigKey(data)
    cb(triggerServer("sky_jobs_base:jobConfigurator:clearCreatorZonePoints", data))
end)

RegisterNUICallback("jobConfigurator:setCreatorZonePreview", function(data, cb)
    data = type(data) == "table" and data or {}
    zonePreviewState.active = data.active == true
    zonePreviewState.points = parseZonePoints(data.points)
    cb({ success = true })
end)

RegisterNUICallback("jobConfigurator:editCarryItemAttach", function(data, cb)
    startCarryItemAttachEditor(type(data) == "table" and data or {}, cb)
end)

RegisterNUICallback("jobConfigurator:close", function(data, cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    currentConfigKey = nil
    openOptions = {}
    cachedEntries = {}
    locationDefinitionsMap = {}
    zonePreviewState.active = false
    zonePreviewState.points = {}
    cb({ success = true })
end)

-- /jobconfig and /jobcreator are registered on the server (source/server/main.lua),
-- which is where the command permission belongs. A client command with the same
-- name would run locally and the server command would never be reached.
RegisterNetEvent("sky_jobs_base:jobConfigurator:openCmd", function(configKey)
    TriggerEvent("sky_jobs_base:jobConfigurator:open", configKey or DEFAULT_CONFIG_KEY, {
        primaryColor = DEFAULT_PRIMARY_COLOR
    })
end)
