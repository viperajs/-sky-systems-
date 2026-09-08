if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/spray_paint.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/spray_paint.lua
--  Deobfuscated & Cleaned
-- =====================================================

REPAINT_GRAY_RGB = REPAINT_GRAY_RGB or { 128, 128, 128 }
REPAINT_MINIGAME_GRAY_COLOR = REPAINT_MINIGAME_GRAY_COLOR or 0

REPAINT_SPRAY_PROP_MODEL = REPAINT_SPRAY_PROP_MODEL or "prop_cs_spray_can"
REPAINT_SPRAY_PROP_MODEL_FALLBACK = REPAINT_SPRAY_PROP_MODEL_FALLBACK or "prop_cs_spray_can"
REPAINT_SPRAY_ATTACH = REPAINT_SPRAY_ATTACH or { bone = 28422, x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 }

REPAINT_SANDING_PROP_MODEL = REPAINT_SANDING_PROP_MODEL or "prop_cs_wrench"
REPAINT_SANDING_ATTACH = REPAINT_SANDING_ATTACH or { bone = 28422, x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 0.0, rz = 0.0 }
REPAINT_SANDING_ANIM_DICT = REPAINT_SANDING_ANIM_DICT or "amb@world_human_maid_clean@"
REPAINT_SANDING_ANIM_CLIP = REPAINT_SANDING_ANIM_CLIP or "base"

REPAINT_PTFX_ASSET = REPAINT_PTFX_ASSET or "scr_playerlamgraff"
REPAINT_PTFX_NAME = REPAINT_PTFX_NAME or "scr_lamgraff_paint_spray"
REPAINT_SPRAY_PTFX_BONE = REPAINT_SPRAY_PTFX_BONE or 28422
REPAINT_SPRAY_PTFX_OFFSET = REPAINT_SPRAY_PTFX_OFFSET or { x = 0.0, y = 0.15, z = 0.0 }
REPAINT_SPRAY_PTFX_ROT = REPAINT_SPRAY_PTFX_ROT or { x = 0.0, y = 0.0, z = 0.0 }
REPAINT_SPRAY_PTFX_SCALE = REPAINT_SPRAY_PTFX_SCALE or 0.8

REPAINT_SANDING_PTFX_ASSET = REPAINT_SANDING_PTFX_ASSET or "core"
REPAINT_SANDING_PTFX_NAME = REPAINT_SANDING_PTFX_NAME or "ent_dst_wood_splinter"
REPAINT_SANDING_PTFX_SCALE = REPAINT_SANDING_PTFX_SCALE or 0.5

REPAINT_SANDING_SOUND_NAME = REPAINT_SANDING_SOUND_NAME or "CAR_WASH_LOOP"
REPAINT_SANDING_SOUND_SET = REPAINT_SANDING_SOUND_SET or "CAR_WASH_SOUNDS"
REPAINT_SANDING_SOUND_INTERVAL_MS = REPAINT_SANDING_SOUND_INTERVAL_MS or 1000

REPAINT_COLOR_RGB_BY_INDEX = REPAINT_COLOR_RGB_BY_INDEX or {}

-- ── Color Field Resolution ───────────────────────────

function resolveRepaintColorField(partId)
    if partId == "color_primary" then return "primary" end
    if partId == "color_secondary" then return "secondary" end
    if partId == "color_pearlescent" then return "pearlescent" end
    if partId == "color_wheel" then return "wheel" end
    if partId == "color_dashboard" then return "dashboard" end
    if partId == "color_interior" then return "interior" end
    return nil
end

function isRepaintOrderPart(partData)
    local partId = tostring((partData and partData.id) or "")
    return resolveRepaintColorField(partId) ~= nil
end

-- ── Vehicle Color Extraction & Application ────────────

function captureVehicleColorIndexes(vehicle)
    local primary, secondary = GetVehicleColours(vehicle)
    local pearl, wheel = GetVehicleExtraColours(vehicle)
    local isCustomP = GetIsVehiclePrimaryColourCustom(vehicle)
    local isCustomS = GetIsVehicleSecondaryColourCustom(vehicle)

    local pr, pg, pb = GetVehicleCustomPrimaryColour(vehicle)
    local sr, sg, sb = GetVehicleCustomSecondaryColour(vehicle)

    local primaryRgb = REPAINT_COLOR_RGB_BY_INDEX[math.floor(tonumber(primary) or 0)] or REPAINT_GRAY_RGB
    local secondaryRgb = REPAINT_COLOR_RGB_BY_INDEX[math.floor(tonumber(secondary) or 0)] or REPAINT_GRAY_RGB

    if isCustomP then
        primaryRgb = { math.floor(tonumber(pr) or 0), math.floor(tonumber(pg) or 0), math.floor(tonumber(pb) or 0) }
    end

    if isCustomS then
        secondaryRgb = { math.floor(tonumber(sr) or 0), math.floor(tonumber(sg) or 0), math.floor(tonumber(sb) or 0) }
    end

    return {
        primary = primary,
        secondary = secondary,
        pearlescent = pearl,
        wheel = wheel,
        dashboard = GetVehicleDashboardColour(vehicle),
        interior = GetVehicleInteriorColour(vehicle),
        primaryCustom = isCustomP,
        secondaryCustom = isCustomS,
        primaryRgb = primaryRgb,
        secondaryRgb = secondaryRgb
    }
end

function applyVehicleColorIndexes(vehicle, colorState)
    if type(colorState) ~= "table" then
        print("[sky_mechanicjob][repaint_minigame] failed: invalid colorState in applyVehicleColorIndexes")
        return
    end

    SetVehicleColours(
        vehicle,
        math.floor(tonumber(colorState.primary) or 0),
        math.floor(tonumber(colorState.secondary) or 0)
    )
    SetVehicleExtraColours(
        vehicle,
        math.floor(tonumber(colorState.pearlescent) or 0),
        math.floor(tonumber(colorState.wheel) or 0)
    )
    SetVehicleDashboardColour(vehicle, math.floor(tonumber(colorState.dashboard) or 0))
    SetVehicleInteriorColour(vehicle, math.floor(tonumber(colorState.interior) or 0))

    if colorState.primaryCustom and type(colorState.primaryRgb) == "table" then
        SetVehicleCustomPrimaryColour(
            vehicle,
            math.floor(tonumber(colorState.primaryRgb[1]) or 0),
            math.floor(tonumber(colorState.primaryRgb[2]) or 0),
            math.floor(tonumber(colorState.primaryRgb[3]) or 0)
        )
    else
        ClearVehicleCustomPrimaryColour(vehicle)
    end

    if colorState.secondaryCustom and type(colorState.secondaryRgb) == "table" then
        SetVehicleCustomSecondaryColour(
            vehicle,
            math.floor(tonumber(colorState.secondaryRgb[1]) or 0),
            math.floor(tonumber(colorState.secondaryRgb[2]) or 0),
            math.floor(tonumber(colorState.secondaryRgb[3]) or 0)
        )
    else
        ClearVehicleCustomSecondaryColour(vehicle)
    end
end

-- ── Target RGB Resolution & Lerp ─────────────────────

function getRepaintTargetRgbForField(field, colorState)
    if type(colorState) ~= "table" then return REPAINT_GRAY_RGB end

    if field == "primary" and type(colorState.primaryRgb) == "table" then return colorState.primaryRgb end
    if field == "secondary" and type(colorState.secondaryRgb) == "table" then return colorState.secondaryRgb end

    local val = nil
    if field == "pearlescent" then val = colorState.pearlescent
    elseif field == "wheel" then val = colorState.wheel
    elseif field == "dashboard" then val = colorState.dashboard
    elseif field == "interior" then val = colorState.interior end

    if val ~= nil then
        return REPAINT_COLOR_RGB_BY_INDEX[math.floor(tonumber(val) or 0)] or REPAINT_GRAY_RGB
    end

    return REPAINT_GRAY_RGB
end

function roundLerp(from, to, pct)
    local startVal = tonumber(from) or 0
    local diff = (tonumber(to) or 0) - startVal
    return math.floor(startVal + diff * pct + 0.5)
end

function lerpRgb(fromRgb, toRgb, pct)
    local t = math.max(0.0, math.min(1.0, tonumber(pct) or 0.0))
    local r1 = math.floor(tonumber(fromRgb and fromRgb[1]) or REPAINT_GRAY_RGB[1])
    local g1 = math.floor(tonumber(fromRgb and fromRgb[2]) or REPAINT_GRAY_RGB[2])
    local b1 = math.floor(tonumber(fromRgb and fromRgb[3]) or REPAINT_GRAY_RGB[3])

    local r2 = math.floor(tonumber(toRgb and toRgb[1]) or REPAINT_GRAY_RGB[1])
    local g2 = math.floor(tonumber(toRgb and toRgb[2]) or REPAINT_GRAY_RGB[2])
    local b2 = math.floor(tonumber(toRgb and toRgb[3]) or REPAINT_GRAY_RGB[3])

    return {
        roundLerp(r1, r2, t),
        roundLerp(g1, g2, t),
        roundLerp(b1, b2, t)
    }
end

function applyRepaintPreviewProgress(vehicle, field, initialColors, targetColors, stage, progress)
    local pct = math.max(0.0, math.min(1.0, tonumber(progress) or 0.0))
    local currentColorState = captureVehicleColorIndexes(vehicle)

    if field == "primary" then
        local startRgb = (stage == "sanding") and (initialColors.primaryRgb or REPAINT_GRAY_RGB) or REPAINT_GRAY_RGB
        local endRgb = (stage == "sanding") and REPAINT_GRAY_RGB or targetColors.primaryRgb
        currentColorState.primaryCustom = true
        currentColorState.primaryRgb = lerpRgb(startRgb, endRgb, pct)
    elseif field == "secondary" then
        local startRgb = (stage == "sanding") and (initialColors.secondaryRgb or REPAINT_GRAY_RGB) or REPAINT_GRAY_RGB
        local endRgb = (stage == "sanding") and REPAINT_GRAY_RGB or targetColors.secondaryRgb
        currentColorState.secondaryCustom = true
        currentColorState.secondaryRgb = lerpRgb(startRgb, endRgb, pct)
    elseif field == "pearlescent" then
        local startVal = (stage == "sanding") and (initialColors[field] or REPAINT_MINIGAME_GRAY_COLOR) or REPAINT_MINIGAME_GRAY_COLOR
        local endVal = (stage == "sanding") and REPAINT_MINIGAME_GRAY_COLOR or targetColors[field]
        currentColorState.pearlescent = roundLerp(startVal, endVal, pct)
    elseif field == "wheel" then
        local startVal = (stage == "sanding") and (initialColors[field] or REPAINT_MINIGAME_GRAY_COLOR) or REPAINT_MINIGAME_GRAY_COLOR
        local endVal = (stage == "sanding") and REPAINT_MINIGAME_GRAY_COLOR or targetColors[field]
        currentColorState.wheel = roundLerp(startVal, endVal, pct)
    elseif field == "dashboard" then
        local startVal = (stage == "sanding") and (initialColors[field] or REPAINT_MINIGAME_GRAY_COLOR) or REPAINT_MINIGAME_GRAY_COLOR
        local endVal = (stage == "sanding") and REPAINT_MINIGAME_GRAY_COLOR or targetColors[field]
        currentColorState.dashboard = roundLerp(startVal, endVal, pct)
    elseif field == "interior" then
        local startVal = (stage == "sanding") and (initialColors[field] or REPAINT_MINIGAME_GRAY_COLOR) or REPAINT_MINIGAME_GRAY_COLOR
        local endVal = (stage == "sanding") and REPAINT_MINIGAME_GRAY_COLOR or targetColors[field]
        currentColorState.interior = roundLerp(startVal, endVal, pct)
    end

    applyVehicleColorIndexes(vehicle, currentColorState)
end

-- ── Tool Equipping ────────────────────────────────────

function equipRepaintTool(stage)
    local ped = PlayerPedId()
    releaseOrderHeldProp()

    local modelName = (stage == "painting") and REPAINT_SPRAY_PROP_MODEL or REPAINT_SANDING_PROP_MODEL
    local modelHash = GetHashKey(modelName)

    if not requestModelLoaded(modelHash, 2500) then
        if stage == "painting" then
            modelName = REPAINT_SPRAY_PROP_MODEL_FALLBACK
            modelHash = GetHashKey(modelName)
            if not requestModelLoaded(modelHash, 2500) then
                print(string.format("[sky_mechanicjob][repaint_minigame] failed: spray model could not be loaded (%s, fallback=%s)", REPAINT_SPRAY_PROP_MODEL, REPAINT_SPRAY_PROP_MODEL_FALLBACK))
                return
            end
        else
            modelName = REPAINT_SPRAY_PROP_MODEL
            modelHash = GetHashKey(modelName)
            if not requestModelLoaded(modelHash, 2500) then
                print(string.format("[sky_mechanicjob][repaint_minigame] failed: tool model could not be loaded (%s)", modelName))
                return
            end
        end
    end

    local attachCfg = (stage == "painting") and REPAINT_SPRAY_ATTACH or REPAINT_SANDING_ATTACH
    local coords = GetEntityCoords(ped)
    local propObj = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)

    AttachEntityToEntity(
        propObj, ped,
        GetPedBoneIndex(ped, attachCfg.bone),
        attachCfg.x, attachCfg.y, attachCfg.z,
        attachCfg.rx, attachCfg.ry, attachCfg.rz,
        true, true, false, true, 1, true
    )

    SetModelAsNoLongerNeeded(modelHash)
    OrderInstallState.heldProp = propObj

    if stage == "painting" then
        startRepaintPointing()
        return
    end

    stopRepaintPointing()
    if requestAnimDictLoaded(REPAINT_SANDING_ANIM_DICT, 2500) then
        TaskPlayAnim(ped, REPAINT_SANDING_ANIM_DICT, REPAINT_SANDING_ANIM_CLIP, 4.0, -4.0, -1, 49, 0.0, false, false, false)
    end
end

-- ── Minigame Runner ──────────────────────────────────

function runRepaintInstallMinigame(vehicle, partData, mode, skipSanding)
    if RepaintMinigameState.active then
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.RepaintMinigameBusy or "Repaint minigame is already running.",
            messageType = "error"
        }
    end

    local field = resolveRepaintColorField(tostring((partData and partData.id) or ""))
    if not field then return true end

    local initialColorState = captureVehicleColorIndexes(vehicle)

    if not applyOrderPartToVehicle(vehicle, partData) then
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.RepaintMinigameFailed or "Repaint minigame failed.",
            messageType = "error"
        }
    end

    local targetColorState = captureVehicleColorIndexes(vehicle)
    applyVehicleColorIndexes(vehicle, initialColorState)

    RepaintMinigameState.active = true
    RepaintMinigameState.token = RepaintMinigameState.token + 1
    RepaintMinigameState.resolved = false
    RepaintMinigameState.success = false
    RepaintMinigameState.cancelled = false

    releaseNuiFocus()

    local currentStage = (mode == "painting") and "painting" or "sanding"
    local token = RepaintMinigameState.token
    local visitedSectors = {}
    local visitedCount = 0
    local targetSectors = math.min(REPAINT_MINIGAME_SECTOR_COUNT, REPAINT_MINIGAME_REQUIRED_SECTORS)
    local targetRgb = getRepaintTargetRgbForField(field, targetColorState)

    local sprayPtfxHandle = 0
    local sandingPtfxHandle = 0
    local lastSandingSoundAt = 0
    local lastProgressUpdateAt = 0

    local function stopSprayPtfx()
        if sprayPtfxHandle ~= 0 then
            StopParticleFxLooped(sprayPtfxHandle, false)
            sprayPtfxHandle = 0
        end
    end

    local function stopSandingPtfx()
        if sandingPtfxHandle ~= 0 then
            StopParticleFxLooped(sandingPtfxHandle, false)
            sandingPtfxHandle = 0
        end
    end

    local function startSprayPtfx()
        stopSprayPtfx()
        if not requestPtfxAssetLoaded(REPAINT_PTFX_ASSET, 2500) then return end

        local ped = PlayerPedId()
        local boneIdx = GetPedBoneIndex(ped, REPAINT_SPRAY_PTFX_BONE)

        UseParticleFxAssetNextCall(REPAINT_PTFX_ASSET)
        sprayPtfxHandle = StartParticleFxLoopedOnEntityBone(
            REPAINT_PTFX_NAME, ped,
            REPAINT_SPRAY_PTFX_OFFSET.x, REPAINT_SPRAY_PTFX_OFFSET.y, REPAINT_SPRAY_PTFX_OFFSET.z,
            REPAINT_SPRAY_PTFX_ROT.x, REPAINT_SPRAY_PTFX_ROT.y, REPAINT_SPRAY_PTFX_ROT.z,
            boneIdx, REPAINT_SPRAY_PTFX_SCALE, false, false, false
        )

        if sprayPtfxHandle ~= 0 then
            local r = math.max(0.0, math.min(1.0, (tonumber(targetRgb[1]) or 128) / 255.0))
            local g = math.max(0.0, math.min(1.0, (tonumber(targetRgb[2]) or 128) / 255.0))
            local b = math.max(0.0, math.min(1.0, (tonumber(targetRgb[3]) or 128) / 255.0))
            SetParticleFxLoopedColour(sprayPtfxHandle, r, g, b, 0)
            SetParticleFxLoopedAlpha(sprayPtfxHandle, 0.25)
        end
    end

    local function startSandingPtfx()
        stopSandingPtfx()
        if not requestPtfxAssetLoaded(REPAINT_SANDING_PTFX_ASSET, 2500) then return end

        local targetEnt = OrderInstallState.heldProp
        if targetEnt == 0 or not DoesEntityExist(targetEnt) then
            targetEnt = PlayerPedId()
        end

        UseParticleFxAssetNextCall(REPAINT_SANDING_PTFX_ASSET)
        sandingPtfxHandle = StartParticleFxLoopedOnEntity(
            REPAINT_SANDING_PTFX_NAME, targetEnt,
            0.14, 0.01, -0.02, 0.0, 0.0, 0.0,
            REPAINT_SANDING_PTFX_SCALE, false, false, false
        )
    end

    local function switchStage(newStage)
        currentStage = newStage
        visitedSectors = {}
        visitedCount = 0

        equipRepaintTool(currentStage)

        if currentStage == "painting" then
            stopSandingPtfx()
            startSprayPtfx()
        else
            stopSprayPtfx()
            startSandingPtfx()
            lastSandingSoundAt = 0
        end

        SendNUIMessage({
            action = "repaint:minigame:update",
            payload = {
                token = token,
                stage = currentStage,
                progress = 0,
                visited = 0,
                total = targetSectors
            }
        })
    end

    equipRepaintTool(currentStage)
    if currentStage == "painting" then startSprayPtfx() else startSandingPtfx() end

    SendNUIMessage({
        action = "repaint:minigame:start",
        payload = {
            token = token,
            stage = currentStage,
            progress = 0,
            visited = 0,
            total = targetSectors
        }
    })

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

        if currentStage == "painting" then
            updateRepaintPointing()
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
            if currentStage == "sanding" then
                local now = GetGameTimer()
                if now - lastSandingSoundAt >= REPAINT_SANDING_SOUND_INTERVAL_MS then
                    local sndEnt = OrderInstallState.heldProp
                    if sndEnt == 0 or not DoesEntityExist(sndEnt) then sndEnt = ped end
                    PlaySoundFromEntity(-1, REPAINT_SANDING_SOUND_NAME, sndEnt, REPAINT_SANDING_SOUND_SET, false, 0)
                    lastSandingSoundAt = now
                end
            end

            local dx = pedCoords.x - vehCoords.x
            local dy = pedCoords.y - vehCoords.y
            local angle = (math.atan(dy, dx) + math.pi * 2.0) % (math.pi * 2.0)
            local sector = math.floor((angle / (math.pi * 2.0)) * REPAINT_MINIGAME_SECTOR_COUNT) + 1
            if sector > REPAINT_MINIGAME_SECTOR_COUNT then sector = REPAINT_MINIGAME_SECTOR_COUNT end

            if not visitedSectors[sector] then
                visitedSectors[sector] = true
                visitedCount = visitedCount + 1

                local pct = math.max(0.0, math.min(1.0, visitedCount / targetSectors))
                applyRepaintPreviewProgress(vehicle, field, initialColorState, targetColorState, currentStage, pct)

                SendNUIMessage({
                    action = "repaint:minigame:update",
                    payload = {
                        token = token,
                        stage = currentStage,
                        progress = math.floor(pct * 100),
                        visited = math.min(visitedCount, targetSectors),
                        total = targetSectors
                    }
                })

                lastProgressUpdateAt = GetGameTimer()

                if pct >= 1.0 then
                    if currentStage == "sanding" and skipSanding ~= true then
                        switchStage("painting")
                    else
                        RepaintMinigameState.resolved = true
                        RepaintMinigameState.success = true
                    end
                end
            end
        else
            local now = GetGameTimer()
            if now - lastProgressUpdateAt >= 1200 then
                SendNUIMessage({
                    action = "repaint:minigame:update",
                    payload = {
                        token = token,
                        stage = currentStage,
                        progress = math.floor((math.min(visitedCount, targetSectors) / targetSectors) * 100),
                        visited = math.min(visitedCount, targetSectors),
                        total = targetSectors
                    }
                })
                lastProgressUpdateAt = now
            end
        end
    end

    stopSprayPtfx()
    stopSandingPtfx()
    stopRepaintPointing()
    releaseOrderHeldProp()

    local wasSuccess = RepaintMinigameState.resolved and RepaintMinigameState.success
    local wasCancelled = RepaintMinigameState.cancelled

    RepaintMinigameState.active = false
    RepaintMinigameState.resolved = true
    RepaintMinigameState.success = false
    RepaintMinigameState.cancelled = false

    closeRepaintMinigameUi()

    if wasSuccess then return true end

    applyVehicleColorIndexes(vehicle, initialColorState)

    if wasCancelled then
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.RepaintMinigameCanceled or "Repaint canceled.",
            messageType = "info"
        }
    end

    return false, {
        key = "radial.errors.generic",
        fallback = tuningLocales.RepaintMinigameFailed or "Repaint minigame failed.",
        messageType = "error"
    }
end

TuningMinigames.Register("spray_paint", runRepaintInstallMinigame)

AddEventHandler("onResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    TuningMinigames.CancelAllActive()
    clearCarJackState(true)
    clearOrderInstallState()
    setTuningClosed(true)
end)
