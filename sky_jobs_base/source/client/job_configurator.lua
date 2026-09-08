if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/job_configurator.lua") end
-- =====================================================
--  sky_jobs_base · source/client/job_configurator.lua
--  Deobfuscated & Cleaned
-- =====================================================

local currentConfigKey = nil
local isPlacementActive = false
local locationDefinitionsMap = {}

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

local function getLocales()
    local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
    local loc = Locales and Locales[localeKey] or (Locales and Locales.en) or {}
    if type(loc.Nui) == "table" then
        return loc.Nui
    end
    return {}
end

function cacheLocationDefinitions(defs)
    locationDefinitionsMap = {}
    if type(defs) ~= "table" then return end

    for _, def in ipairs(defs) do
        if type(def) == "table" and type(def.key) == "string" then
            locationDefinitionsMap[def.key] = def
        end
    end
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
    if editorName == "hospitalBed" and locationData.configKey == "sky_ambulancejob" then
        if exports and exports.sky_ambulancejob and exports.sky_ambulancejob.OpenJobConfiguratorHospitalBedPlacement then
            return exports.sky_ambulancejob:OpenJobConfiguratorHospitalBedPlacement({
                entryId = locationData.entryId,
                entryName = locationData.entryName,
                coords = locationData.coords
            })
        end
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
        if coords and coords.x and coords.y and coords.z then
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
    if count < 2 then
        for i = 1, count do
            local pt = points[i]
            for h = 0, 99 do
                local zStart = pt.z + h
                DrawLine(pt.x, pt.y, zStart, pt.x, pt.y, zStart + 1.0, 255, 140, 0, 200)
            end
            Sky.Show.Marker({ x = pt.x, y = pt.y, z = pt.z }, {
                offset = vector3(0.0, 0.0, 0.2),
                type = 1,
                scaleX = 0.35, scaleY = 0.35, scaleZ = 0.35,
                red = 255, green = 140, blue = 0, alpha = 160,
                faceCamera = true, p19 = 2
            })
        end
        return
    end

    for i = 1, count do
        local p1 = points[i]
        local p2 = points[(i % count) + 1]

        for h = 0, 99 do
            local zStart = p1.z + h
            DrawLine(p1.x, p1.y, zStart, p1.x, p1.y, zStart + 1.0, 255, 140, 0, 200)
            DrawLine(p1.x, p1.y, zStart + 1.0, p2.x, p2.y, p2.z + h + 1.0, 255, 140, 0, 180)
        end

        DrawLine(p1.x, p1.y, p1.z + 100.0, p2.x, p2.y, p2.z + 100.0, 255, 140, 0, 200)

        Sky.Show.Marker({ x = p1.x, y = p1.y, z = p1.z }, {
            offset = vector3(0.0, 0.0, 0.2),
            type = 1,
            scaleX = 0.35, scaleY = 0.35, scaleZ = 0.35,
            red = 255, green = 140, blue = 0, alpha = 160,
            faceCamera = true, p19 = 2
        })
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
    local min, max = GetModelDimensions(modelHash)
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

local function getPlacementHelpText()
    local locKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
    local currentLoc = (Locales and Locales[locKey]) or (Locales and Locales.en) or {}
    local fallbackLoc = (Locales and Locales.en) or {}

    local helpMsg = (currentLoc.Nui and currentLoc.Nui.creator and currentLoc.Nui.creator.placementHelp)
        or (fallbackLoc.Nui and fallbackLoc.Nui.creator and fallbackLoc.Nui.creator.placementHelp)
        or "Arrows move, PageUp/PageDown height, Q/E rotate, Enter place, Backspace cancel."

    return helpMsg
end

local function drawTextOverlay(text)
    if type(text) ~= "string" or text == "" then return end

    SetTextFont(4)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 230)
    SetTextCentre(true)
    SetTextOutline()

    BeginTextCommandGetWidth("STRING")
    AddTextComponentString(text)
    local width = EndTextCommandGetWidth(true)

    local padding = 0.008
    local baseHeight = 0.03
    local rectW = width + (padding * 2)
    local rectH = baseHeight + (padding * 2)

    DrawRect(0.5, 0.9, rectW, rectH, 0, 0, 0, 160)

    BeginTextCommandDisplayText("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(0.5, 0.9 - (baseHeight * 0.5))
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
    local animDict = "anim@heists@box_carry@"
    if not loadAnimDictTimeout(animDict, 2500) then return false end

    TaskPlayAnim(ped, animDict, "idle", 4.0, -4.0, -1, 49, 0.0, false, false, false)
    RemoveAnimDict(animDict)
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

    local modelHash = joaat(propName)
    if not IsModelValid(modelHash) then
        cb({ success = false, error = "model_missing" })
        return
    end

    isPlacementActive = true
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        type = "jobConfigurator:placement",
        active = true,
        label = data.label or data.item or propName
    })

    Sky.Load.Model(modelHash)
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)

    local objectEntity = CreateObjectNoOffset(modelHash, pCoords.x, pCoords.y, pCoords.z + 0.2, false, false, false)
    if not objectEntity or objectEntity == 0 then
        SetModelAsNoLongerNeeded(modelHash)
        isPlacementActive = false
        SetNuiFocus(true, true)
        SendNUIMessage({ type = "jobConfigurator:placement", active = false })
        cb({ success = false, error = "spawn_failed" })
        return
    end

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
    SetModelAsNoLongerNeeded(modelHash)

    attachEntityToPedBone(objectEntity, ped, currentAttach)
    playCarryAnimation(ped)

    CreateThread(function()
        local editing = true
        while editing do
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 38, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)

            drawCarryAttachOverlay(currentAttach)

            if not IsEntityPlayingAnim(ped, "anim@heists@box_carry@", "idle", 3) then
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

            if IsDisabledControlPressed(0, 44) then -- Q
                if IsControlPressed(0, 21) then -- Shift
                    currentAttach.ry = currentAttach.ry - rotateStep
                elseif IsControlPressed(0, 36) then -- Ctrl
                    currentAttach.rx = currentAttach.rx - rotateStep
                else
                    currentAttach.rz = currentAttach.rz - rotateStep
                end
                changed = true
            end

            if IsDisabledControlPressed(0, 38) then -- E
                if IsControlPressed(0, 21) then -- Shift
                    currentAttach.ry = currentAttach.ry + rotateStep
                elseif IsControlPressed(0, 36) then -- Ctrl
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
                editing = false
                DeleteEntity(objectEntity)
                ClearPedTasks(ped)
                isPlacementActive = false
                SendNUIMessage({ type = "jobConfigurator:placement", active = false })
                SetNuiFocus(true, true)
                cb({ success = true, data = { attach = currentAttach } })
                break
            end

            if IsControlJustPressed(0, 177) then -- Backspace
                editing = false
                DeleteEntity(objectEntity)
                ClearPedTasks(ped)
                isPlacementActive = false
                SendNUIMessage({ type = "jobConfigurator:placement", active = false })
                SetNuiFocus(true, true)
                cb({ success = false, error = "cancelled" })
                break
            end

            Wait(0)
        end
    end)
end

local function startPropPlacement(modelName, cb)
    local modelHash = joaat(modelName)
    if not IsModelValid(modelHash) then
        cb({ success = false, error = "model_missing" })
        return
    end

    Sky.Load.Model(modelHash)
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)
    local pForward = GetEntityForwardVector(ped)

    local spawnPos = vector3(
        pCoords.x + (pForward.x * 1.5),
        pCoords.y + (pForward.y * 1.5),
        pCoords.z
    )

    local bottomOffset = getModelBottomOffset(modelHash)
    local targetPos = adjustCoordsToGround(spawnPos, bottomOffset)

    local propObj = CreateObjectNoOffset(modelHash, targetPos.x, targetPos.y, targetPos.z, false, false, false)
    if not propObj or propObj == 0 then
        SetModelAsNoLongerNeeded(modelHash)
        cb({ success = false, error = "spawn_failed" })
        return
    end

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
    SetModelAsNoLongerNeeded(modelHash)

    CreateThread(function()
        local placing = true
        while placing do
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 38, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)

            drawTextOverlay(helpText)

            local currentCoords = GetEntityCoords(propObj)
            local camForward, camRight = getCameraDirectionVectors()
            local moveVec = vector3(0.0, 0.0, 0.0)

            if IsControlPressed(0, 172) then moveVec = moveVec + (camForward * moveStep) end
            if IsControlPressed(0, 173) then moveVec = moveVec - (camForward * moveStep) end
            if IsControlPressed(0, 174) then moveVec = moveVec - (camRight * moveStep) end
            if IsControlPressed(0, 175) then moveVec = moveVec + (camRight * moveStep) end

            if IsControlPressed(0, 10) then heightOffset = heightOffset + heightStep end
            if IsControlPressed(0, 11) then heightOffset = heightOffset - heightStep end

            if moveVec.x ~= 0.0 or moveVec.y ~= 0.0 then
                local nextBase = vector3(currentCoords.x + moveVec.x, currentCoords.y + moveVec.y, currentCoords.z)
                local groundPoint = adjustCoordsToGround(nextBase, bottomOffset)
                local finalPos = vector3(groundPoint.x, groundPoint.y, groundPoint.z + heightOffset)
                SetEntityCoordsNoOffset(propObj, finalPos.x, finalPos.y, finalPos.z, false, false, false)
            end

            currentCoords = GetEntityCoords(propObj)
            local groundBase = adjustCoordsToGround(currentCoords, bottomOffset)
            local targetZ = groundBase.z + heightOffset

            if math.abs(targetZ - currentCoords.z) > 0.01 then
                SetEntityCoordsNoOffset(propObj, groundBase.x, groundBase.y, targetZ, false, false, false)
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
                DeleteEntity(propObj)
                placing = false

                cb({
                    success = true,
                    coords = {
                        x = finalCoords.x,
                        y = finalCoords.y,
                        z = finalCoords.z,
                        heading = finalHeading
                    }
                })
                break
            end

            if IsControlJustPressed(0, 177) then -- Backspace
                DeleteEntity(propObj)
                placing = false
                cb({ success = false, error = "cancelled" })
                break
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
    currentConfigKey = configKey or "sky_mechanicjob"
    options = type(options) == "table" and options or {}

    local listRes = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:list", { configKey = currentConfigKey }) or {}
    local serverData = listRes.data or {}

    local locationDefs = options.locationDefinitions or serverData.locationDefinitions or {}
    local configs = options.configs or serverData.configs or {}

    cacheLocationDefinitions(locationDefs)

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    Wait(0)
    SetNuiFocus(true, true)

    SendNUIMessage({
        type = "jobConfigurator:open",
        data = {
            configKey = currentConfigKey,
            title = options.title or "Mechanic Jobs",
            subtitle = options.subtitle or "Configure mechanic jobs, shops, vehicles, and workshop locations.",
            primaryColor = options.primaryColor or "#EDC001",
            lang = options.lang or (Sky and Sky.Config and Sky.Config.locale) or "en",
            locales = getLocales(),
            configs = configs,
            locationDefinitions = locationDefs,
            creatorSections = options.creatorSections or {
                { key = "general", label = "General", icon = "sliders" },
                { key = "shop", label = "Shop", icon = "shopping-cart" },
                { key = "props", label = "Props", icon = "box" },
                { key = "vehicles", label = "Vehicles", icon = "car" },
                { key = "locations", label = "Locations", icon = "map-pin" },
                { key = "partsDelivery", label = "Parts Delivery", icon = "truck" },
                { key = "tuningPrices", label = "Tuning Prices", icon = "wrench" }
            },
            extensions = options.extensions or {
                { key = "workshops", label = "Workshops", icon = "map-pin" },
                { key = "partsTheft", label = "Parts Theft", icon = "wrench" },
                { key = "vehicleCare", label = "Vehicle Care", icon = "sparkles" },
                { key = "wear", label = "Wear", icon = "activity" },
                { key = "wheelDamage", label = "Wheel Damage", icon = "gauge" },
                { key = "mileageHud", label = "Mileage HUD", icon = "hash" },
                { key = "carryItems", label = "Carry Items", icon = "box" },
                { key = "features", label = "Features", icon = "sliders" },
                { key = "interactions", label = "Interactions", icon = "mouse-pointer" }
            },
            featureDefinitions = options.featureDefinitions or serverData.featureDefinitions or {},
            features = options.features or serverData.features or {},
            settingDefinitions = options.settingDefinitions or serverData.settingDefinitions or {},
            settings = options.settings or serverData.settings or {},
            interactionDefinitions = options.interactionDefinitions or serverData.interactionDefinitions or {},
            interactions = options.interactions or serverData.interactions or {},
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
    })
end)

RegisterNUICallback("jobConfigurator:configs", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:configs", {}) or { success = false, error = "request_failed" }
    cb(res)
end)

RegisterNUICallback("jobConfigurator:list", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey

    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:list", data) or { success = false, error = "request_failed" }
    if res.success and type(res.data) == "table" then
        cacheLocationDefinitions(res.data.locationDefinitions)
    end
    cb(res)
end)

RegisterNUICallback("jobConfigurator:save", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey

    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:save", data) or { success = false, error = "request_failed" }
    cb(res)
end)

RegisterNUICallback("jobConfigurator:saveFeatures", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey

    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:saveFeatures", data) or { success = false, error = "request_failed" }
    cb(res)
end)

RegisterNUICallback("jobConfigurator:saveSettings", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey

    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:saveSettings", data) or { success = false, error = "request_failed" }
    cb(res)
end)

RegisterNUICallback("jobConfigurator:saveInteractions", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey

    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:saveInteractions", data) or { success = false, error = "request_failed" }
    cb(res)
end)

RegisterNUICallback("jobConfigurator:delete", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey

    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:delete", data) or { success = false, error = "request_failed" }
    cb(res)
end)

RegisterNUICallback("jobConfigurator:createCreatorEntry", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey

    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:createCreatorEntry", data) or { success = false, error = "request_failed" }
    cb(res)
end)

RegisterNUICallback("jobConfigurator:saveCreatorEntry", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey

    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:saveCreatorEntry", data) or { success = false, error = "request_failed" }
    cb(res)
end)

RegisterNUICallback("jobConfigurator:deleteCreatorEntry", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey

    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:deleteCreatorEntry", data) or { success = false, error = "request_failed" }
    cb(res)
end)

RegisterNUICallback("jobConfigurator:placeLocation", function(data, cb)
    if isPlacementActive then
        cb({ success = false, error = "placement_active" })
        return
    end

    data = type(data) == "table" and data or {}
    local customEditor = getPlacementEditor(data)

    if customEditor and customEditor ~= "" then
        isPlacementActive = true
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)

        CreateThread(function()
            local res = runCustomPlacementEditor(customEditor, data)
            local finalRes = nil

            if res and res.success and type(res.coords) == "table" then
                data.coords = res.coords
                local rpcRes = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:setLocation", data)
                finalRes = rpcRes or { success = false, error = "request_failed" }
            else
                finalRes = { success = false, error = (res and res.error) or "request_failed" }
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
        if resData and resData.success then
            SendNUIMessage({
                type = "jobConfigurator:updateLocation",
                data = resData
            })
            SendNUIMessage({
                type = "jobConfigurator:setPoint",
                data = resData
            })
        end
        SetNuiFocus(true, true)
        cb(resData)
    end

    local propModel = getPlacementModel(data)

    CreateThread(function()
        while IsControlPressed(0, 191) or IsControlPressed(0, 201) do
            Wait(0)
        end

        local resultPayload = nil
        while not resultPayload do
            Wait(0)
            BeginTextCommandDisplayHelp("STRING")
            AddTextComponentSubstringPlayerName("Press ~INPUT_FRONTEND_RDOWN~ to place location at your position, or ~INPUT_FRONTEND_RRIGHT~ to cancel.")
            EndTextCommandDisplayHelp(0, false, false, -1)

            if IsControlJustReleased(0, 191) or IsControlJustReleased(0, 201) or IsControlJustReleased(0, 38) then -- ENTER or E
                if propModel and propModel ~= "" then
                    local placementDone = false
                    startPropPlacement(propModel, function(pRes)
                        if pRes and pRes.success and type(pRes.coords) == "table" then
                            data.coords = pRes.coords
                            local rpcRes = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:setLocation", data)
                            resultPayload = rpcRes or { success = false, error = "request_failed" }
                        else
                            resultPayload = { success = false, error = (pRes and pRes.error) or "request_failed" }
                        end
                        placementDone = true
                    end)

                    while not placementDone do Wait(0) end
                    break
                end

                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                data.coords = {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z - 1.0,
                    heading = GetEntityHeading(ped)
                }

                local rpcRes = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:setLocation", data)
                resultPayload = rpcRes or { success = false, error = "request_failed" }
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

    SetEntityCoords(entityToTeleport, x, y, z, false, false, false, false)

    local heading = tonumber(coords.heading or data.heading)
    if heading then
        SetEntityHeading(entityToTeleport, heading)
    end

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
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey

    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:deleteLocations", data) or { success = false, error = "request_failed" }
    cb(res)
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
            if IsControlJustReleased(0, 191) or IsControlJustReleased(0, 201) then
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                data.coords = {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z - 1.0
                }

                local rpcRes = Sky.Cb.Trigger(rpcEvent, data)
                resultPayload = rpcRes or { success = false, error = "request_failed" }
            elseif IsControlJustReleased(0, 177) or IsControlJustReleased(0, 202) then
                resultPayload = { success = false, error = "cancelled" }
            end
        end

        finishPlacement(resultPayload)
    end)
end

RegisterNUICallback("jobConfigurator:addCreatorZonePoint", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey
    startZonePointPlacement(data, "sky_jobs_base:jobConfigurator:addCreatorZonePoint", cb)
end)

RegisterNUICallback("jobConfigurator:setCreatorZonePoint", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey
    startZonePointPlacement(data, "sky_jobs_base:jobConfigurator:setCreatorZonePoint", cb)
end)

RegisterNUICallback("jobConfigurator:removeCreatorZonePoint", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey

    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:removeCreatorZonePoint", data) or { success = false, error = "request_failed" }
    cb(res)
end)

RegisterNUICallback("jobConfigurator:clearCreatorZonePoints", function(data, cb)
    data = type(data) == "table" and data or {}
    data.configKey = data.configKey or currentConfigKey

    local res = Sky.Cb.Trigger("sky_jobs_base:jobConfigurator:clearCreatorZonePoints", data) or { success = false, error = "request_failed" }
    cb(res)
end)

RegisterNUICallback("jobConfigurator:setCreatorZonePreview", function(data, cb)
    zonePreviewState.active = (data and data.active == true)
    zonePreviewState.points = parseZonePoints(data and data.points)
    cb({ success = true })
end)

RegisterNUICallback("jobConfigurator:editCarryItemAttach", function(data, cb)
    startCarryItemAttachEditor(type(data) == "table" and data or {}, cb)
end)

RegisterNUICallback("jobConfigurator:close", function(data, cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    currentConfigKey = nil
    locationDefinitionsMap = {}
    zonePreviewState.active = false
    zonePreviewState.points = {}
    cb({ success = true })
end)

RegisterNetEvent("sky_jobs_base:jobConfigurator:openCmd", function(configKey)
    TriggerEvent("sky_jobs_base:jobConfigurator:open", configKey or "sky_mechanicjob", {
        primaryColor = "#EDC001"
    })
end)

RegisterCommand("jobconfig", function(source, args)
    local configKey = (args and args[1]) or "sky_mechanicjob"
    TriggerEvent("sky_jobs_base:jobConfigurator:open", configKey, {
        primaryColor = "#EDC001"
    })
end, false)

RegisterCommand("jobcreator", function(source, args)
    local configKey = (args and args[1]) or "sky_mechanicjob"
    TriggerEvent("sky_jobs_base:jobConfigurator:open", configKey, {
        primaryColor = "#EDC001"
    })
end, false)
