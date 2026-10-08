if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/vehicle_persistence.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/vehicle_persistence.lua
--  Deobfuscated & Cleaned
-- =====================================================

VehiclePersistence = VehiclePersistence or {}

-- ── Debug Logging ────────────────────────────────────

local function logDebug(msg)
    if Sky and Sky.IsDebugActive and Sky.IsDebugActive() and Sky.Debug then
        Sky.Debug("debug", msg)
    end
end

local function boolToString(val)
    return (val == true) and "true" or "false"
end

local function colorToString(col)
    if type(col) ~= "table" then return "nil" end
    return string.format("%s/%s/%s", tostring(col.r), tostring(col.g), tostring(col.b))
end

local function paintToString(paint)
    if type(paint) ~= "table" then return "paint=missing" end
    return string.format(
        "paint=(primary=%s secondary=%s pearl=%s wheel=%s dash=%s interior=%s tint=%s customP=%s:%s customS=%s:%s)",
        tostring(paint.primary), tostring(paint.secondary), tostring(paint.pearlescent), tostring(paint.wheel),
        tostring(paint.dashboard), tostring(paint.interior), tostring(paint.windowTint),
        boolToString(paint.primaryCustom == true), colorToString(paint.primaryCustomColor),
        boolToString(paint.secondaryCustom == true), colorToString(paint.secondaryCustomColor)
    )
end

local function stanceToString(stance)
    if type(stance) ~= "table" then return "stance=missing" end
    return string.format(
        "stance=(enabled=%s camberF=%s camberR=%s trackF=%s trackR=%s suspension=%s wheelSize=%s wheelWidth=%s)",
        tostring(stance.enabled), tostring(stance.fCamberFront), tostring(stance.fCamberRear),
        tostring(stance.trackFront), tostring(stance.trackRear), tostring(stance.suspensionHeight),
        tostring(stance.wheelSize), tostring(stance.wheelWidth)
    )
end

local function rgbToString(neon, xenon)
    local nColor = (type(neon) == "table" and type(neon.baseColor) == "table") and neon.baseColor or nil
    local xColor = (type(xenon) == "table" and type(xenon.baseColor) == "table") and xenon.baseColor or nil

    local dirs = (type(neon) == "table" and type(neon.enabledDirections) == "table") and neon.enabledDirections or {}

    return string.format(
        "rgb=(neon=%s neonMode=%s neonColor=%s neonDirections=%s/%s/%s/%s xenon=%s xenonEnabled=%s xenonIndex=%s xenonCustom=%s xenonMode=%s xenonColor=%s)",
        boolToString(type(neon) == "table"), tostring(neon and neon.mode), colorToString(nColor),
        tostring(dirs[1]), tostring(dirs[2]), tostring(dirs[3]), tostring(dirs[4]),
        boolToString(type(xenon) == "table"), tostring(xenon and xenon.enabled),
        tostring(xenon and xenon.colorIndex), tostring(xenon and xenon.custom),
        tostring(xenon and xenon.mode), colorToString(xColor)
    )
end

-- ── StanceKit Fallback Stub ──────────────────────────

if type(StanceKit) ~= "table" then
    StanceKit = {
        ApplyPersistedState = function() end,
        EnsureRuntimeForVehicle = function() end,
        ReadVehicleStance = function() return nil end,
        LoadPersistedForVehicle = function() return false end,
        BuildPersistedState = function() return nil end,
        HasPendingPersist = function() return false end,
        StopRuntimeLoop = function() end
    }
    if Sky and Sky.Debug then
        Sky.Debug("error", "[sky_mechanicjob][vehicle_persistence] StanceKit was nil; fallback stub was created to prevent runtime crashes.")
    end
end

-- ── Paint Extract / Apply ────────────────────────────

function extractPaintData(vehicle)
    local primary, secondary = GetVehicleColours(vehicle)
    local pearl, wheel = GetVehicleExtraColours(vehicle)
    local pPaintType = GetVehicleModColor_1(vehicle)
    local sPaintType = GetVehicleModColor_2(vehicle)
    local nativeLivery = GetVehicleLivery(vehicle)
    local modLivery = GetVehicleMod(vehicle, 48)

    local paint = {
        primary = primary,
        secondary = secondary,
        pearlescent = math.floor(tonumber(pearl) or 0),
        wheel = wheel,
        dashboard = GetVehicleDashboardColour(vehicle),
        interior = GetVehicleInteriorColour(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),
        primaryPaintType = pPaintType,
        secondaryPaintType = sPaintType,
        livery = nativeLivery,
        liveryNative = nativeLivery,
        liveryMod = modLivery,
        primaryCustom = GetIsVehiclePrimaryColourCustom(vehicle),
        secondaryCustom = GetIsVehicleSecondaryColourCustom(vehicle)
    }

    if paint.primaryCustom then
        local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
        paint.primaryCustomColor = { r = r, g = g, b = b }
    end

    if paint.secondaryCustom then
        local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
        paint.secondaryCustomColor = { r = r, g = g, b = b }
    end

    return paint
end

function convertPaintToProps(props, paint)
    if type(props) ~= "table" or type(paint) ~= "table" then return end

    props.color1 = math.floor(tonumber(paint.primary) or 0)
    props.color2 = math.floor(tonumber(paint.secondary) or 0)
    props.pearlescentColor = math.floor(tonumber(paint.pearlescent) or 0)
    props.wheelColor = math.floor(tonumber(paint.wheel) or 0)
    props.pearlescent = props.pearlescentColor
    props.wheelColour = props.wheelColor

    props.dashboardColour = math.floor(tonumber(paint.dashboard) or 0)
    props.interiorColour = math.floor(tonumber(paint.interior) or 0)
    props.dashboardColor = props.dashboardColour
    props.interiorColor = props.interiorColour

    props.windowTint = math.floor(tonumber(paint.windowTint) or -1)

    local nativeLiv = math.floor(tonumber(paint.liveryNative ~= nil and paint.liveryNative or paint.livery) or -1)
    local modLiv = math.floor(tonumber(paint.liveryMod ~= nil and paint.liveryMod or paint.livery) or -1)
    props.livery = nativeLiv
    props.modLivery = modLiv

    local pType = math.floor(tonumber(paint.primaryPaintType) or 0)
    local sType = math.floor(tonumber(paint.secondaryPaintType) or 0)

    props.modColor1 = { pType, props.color1, props.pearlescentColor }
    props.modColor2 = { sType, props.color2 }

    if paint.primaryCustom and type(paint.primaryCustomColor) == "table" then
        props.customPrimaryColor = {
            math.floor(tonumber(paint.primaryCustomColor.r) or 0),
            math.floor(tonumber(paint.primaryCustomColor.g) or 0),
            math.floor(tonumber(paint.primaryCustomColor.b) or 0)
        }
    else
        props.customPrimaryColor = nil
    end

    if paint.secondaryCustom and type(paint.secondaryCustomColor) == "table" then
        props.customSecondaryColor = {
            math.floor(tonumber(paint.secondaryCustomColor.r) or 0),
            math.floor(tonumber(paint.secondaryCustomColor.g) or 0),
            math.floor(tonumber(paint.secondaryCustomColor.b) or 0)
        }
    else
        props.customSecondaryColor = nil
    end
end

function extractPaintFromProps(props)
    if type(props) ~= "table" then return nil end

    local modCol1 = type(props.modColor1) == "table" and props.modColor1 or {}
    local modCol2 = type(props.modColor2) == "table" and props.modColor2 or {}
    local customP = type(props.customPrimaryColor) == "table" and props.customPrimaryColor or nil
    local customS = type(props.customSecondaryColor) == "table" and props.customSecondaryColor or nil

    local nativeLiv = math.floor(tonumber(props.livery) or -1)
    local modLiv = math.floor(tonumber(props.modLivery) or -1)
    local bestLiv = (nativeLiv >= 0) and nativeLiv or modLiv

    local paint = {
        primary = math.floor(tonumber(props.color1) or 0),
        secondary = math.floor(tonumber(props.color2) or 0),
        pearlescent = math.floor(tonumber(props.pearlescentColor or modCol1[3]) or 0),
        wheel = math.floor(tonumber(props.wheelColor) or 0),
        dashboard = math.floor(tonumber(props.dashboardColor) or 0),
        interior = math.floor(tonumber(props.interiorColor) or 0),
        windowTint = props.windowTint,
        primaryPaintType = math.floor(tonumber(modCol1[1]) or 0),
        secondaryPaintType = math.floor(tonumber(modCol2[1]) or 0),
        livery = bestLiv,
        liveryNative = nativeLiv,
        liveryMod = modLiv,
        primaryCustom = customP ~= nil,
        secondaryCustom = customS ~= nil
    }

    if customP then
        paint.primaryCustomColor = {
            r = math.floor(tonumber(customP[1]) or 0),
            g = math.floor(tonumber(customP[2]) or 0),
            b = math.floor(tonumber(customP[3]) or 0)
        }
    end

    if customS then
        paint.secondaryCustomColor = {
            r = math.floor(tonumber(customS[1]) or 0),
            g = math.floor(tonumber(customS[2]) or 0),
            b = math.floor(tonumber(customS[3]) or 0)
        }
    end

    return paint
end

function getPaintData(data)
    if type(data) ~= "table" then return nil end
    if type(data._skyMechanicPaint) == "table" then return data._skyMechanicPaint end
    if type(data._skyMechanicTuning) == "table" and type(data._skyMechanicTuning.paint) == "table" then
        return data._skyMechanicTuning.paint
    end
    return extractPaintFromProps(data)
end

-- ── Apply Paint to Vehicle ───────────────────────────

function applyPaintDataToVehicle(vehicle, paint)
    if type(paint) ~= "table" then return end

    local primary = math.floor(tonumber(paint.primary) or 0)
    local secondary = math.floor(tonumber(paint.secondary) or 0)
    local pearl = math.floor(tonumber(paint.pearlescent) or 0)
    local wheel = math.floor(tonumber(paint.wheel) or 0)

    ClearVehicleCustomPrimaryColour(vehicle)
    ClearVehicleCustomSecondaryColour(vehicle)
    SetVehicleColours(vehicle, primary, secondary)

    if paint.primaryCustom and type(paint.primaryCustomColor) == "table" then
        SetVehicleModColor_1(vehicle, math.floor(tonumber(paint.primaryPaintType) or 0), primary, pearl)
    end

    if paint.secondaryCustom and type(paint.secondaryCustomColor) == "table" then
        SetVehicleModColor_2(vehicle, math.floor(tonumber(paint.secondaryPaintType) or 0), secondary)
    end

    SetVehicleExtraColours(vehicle, pearl, wheel)
    SetVehicleDashboardColour(vehicle, math.floor(tonumber(paint.dashboard) or 0))
    SetVehicleInteriorColour(vehicle, math.floor(tonumber(paint.interior) or 0))

    if paint.windowTint ~= nil then
        SetVehicleWindowTint(vehicle, math.floor(tonumber(paint.windowTint) or -1))
    end

    local nativeLiv = math.floor(tonumber(paint.liveryNative ~= nil and paint.liveryNative or paint.livery) or -1)
    local modLiv = math.floor(tonumber(paint.liveryMod ~= nil and paint.liveryMod or paint.livery) or -1)

    SetVehicleLivery(vehicle, nativeLiv)
    SetVehicleModKit(vehicle, 0)
    SetVehicleMod(vehicle, 48, modLiv, false)

    if paint.primaryCustom and type(paint.primaryCustomColor) == "table" then
        SetVehicleCustomPrimaryColour(
            vehicle,
            math.floor(tonumber(paint.primaryCustomColor.r) or 0),
            math.floor(tonumber(paint.primaryCustomColor.g) or 0),
            math.floor(tonumber(paint.primaryCustomColor.b) or 0)
        )
    end

    if paint.secondaryCustom and type(paint.secondaryCustomColor) == "table" then
        SetVehicleCustomSecondaryColour(
            vehicle,
            math.floor(tonumber(paint.secondaryCustomColor.r) or 0),
            math.floor(tonumber(paint.secondaryCustomColor.g) or 0),
            math.floor(tonumber(paint.secondaryCustomColor.b) or 0)
        )
    end
end

-- ── Neon / Xenon Extraction ──────────────────────────

function extractNeonData(vehicle, inputNeon)
    local r, g, b = GetVehicleNeonLightsColour(vehicle)
    local directions = {}
    for i = 0, 3 do
        directions[i + 1] = IsVehicleNeonLightEnabled(vehicle, i) == true
    end

    local neon = (type(inputNeon) == "table" and inputNeon) or {}
    neon.mode = math.floor(tonumber(neon.mode) or RgbController.NEON_EFFECT_MODES.off)
    neon.speed = math.floor(tonumber(neon.speed) or 5)
    neon.baseColor = (type(neon.baseColor) == "table") and neon.baseColor or { r = r, g = g, b = b }
    neon.enabledDirections = directions

    return neon
end

function extractXenonData(vehicle, inputXenon)
    local hasXenon = IsToggleModOn(vehicle, 22)
    if type(inputXenon) ~= "table" and not hasXenon then
        return nil
    end

    local xenon = (type(inputXenon) == "table" and inputXenon) or {}
    local currentColor = math.floor(tonumber(GetVehicleXenonLightsColor(vehicle)) or -1)

    local customColor = Entity(vehicle).state["sky_mechanicjob:xenonCustomColor"]
    local parsedCustomColor = type(customColor) == "table" and customColor or nil

    xenon.enabled = hasXenon
    xenon.mode = math.floor(tonumber(xenon.mode) or RgbController.XENON_EFFECT_MODES.off)
    xenon.speed = math.floor(tonumber(xenon.speed) or 5)

    if parsedCustomColor then
        xenon.colorIndex = 255
        xenon.custom = true
        xenon.baseColor = parsedCustomColor
    else
        xenon.colorIndex = currentColor
        xenon.custom = (currentColor == 255)
        xenon.baseColor = RgbController.CaptureVehicleXenonColor(vehicle)
    end

    return xenon
end

-- ── Serializing Tuning Data ──────────────────────────

function buildTuningJson(vehicle)
    local paint = extractPaintData(vehicle)
    if type(paint) ~= "table" then return nil end

    local stance = StanceKit.ReadVehicleStance(vehicle)
    local neonData, xenonData = RgbController.GetVehicleEffectState(vehicle)
    local neon = extractNeonData(vehicle, neonData)
    local xenon = extractXenonData(vehicle, xenonData)

    local payload = {
        primary = paint.primary,
        secondary = paint.secondary,
        pearlescent = paint.pearlescent,
        wheel = paint.wheel,
        dashboard = paint.dashboard,
        interior = paint.interior,
        windowTint = paint.windowTint,
        primaryPaintType = paint.primaryPaintType,
        secondaryPaintType = paint.secondaryPaintType,
        livery = paint.livery,
        primaryCustom = paint.primaryCustom == true,
        secondaryCustom = paint.secondaryCustom == true,
        primaryCustomColor = paint.primaryCustomColor,
        secondaryCustomColor = paint.secondaryCustomColor,
        rgb = { neon = neon, xenon = xenon },
        stance = stance
    }

    local ok, encoded = pcall(json.encode, payload)
    return ok and encoded or nil
end

-- ── Load & Save Persisted Tuning ─────────────────────

local function getVehiclePlate(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return "" end
    return string.upper(Sky.Math.Trim(GetVehicleNumberPlateText(vehicle)) or "")
end

local function isOpenInTuningMenu(vehicle)
    return type(TuningState) == "table" and TuningState.active == true and TuningState.vehicle == vehicle
end

--- Stance, custom handling, anti-lag and two-step as stored in _skyMechanicTuning.
--- Nitro is saved by its own install/update callbacks.
function VehiclePersistence.BuildTuningState(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end

    return {
        stance = StanceKit.BuildPersistedState(vehicle),
        customHandling = CustomTuning.BuildPersistedState(vehicle),
        antiLag = AntiLag.GetPersistedState(vehicle),
        twoStep = TwoStep.GetPersistedState(vehicle)
    }
end

--- Sends the current extended tuning of a vehicle; the server only accepts it from
--- admins and on-duty mechanics standing next to the vehicle.
function VehiclePersistence.SaveTuningState(vehicle)
    local plate = getVehiclePlate(vehicle)
    local state = VehiclePersistence.BuildTuningState(vehicle)
    if plate == "" or type(state) ~= "table" or next(state) == nil then return false end

    -- The state is captured now; callers (tuning close, order install) go on changing the vehicle.
    CreateThread(function()
        Sky.Cb.Trigger("sky_mechanicjob:tuning:saveProperties", {
            plate = plate,
            properties = { _skyMechanicTuning = state }
        })
    end)
    return true
end

-- saveTuningForVehicle (import.lua) calls StanceKit.PersistCurrent after saving the vehicle properties.
StanceKit.PersistCurrent = VehiclePersistence.SaveTuningState

-- ── RGB Controller Lights ────────────────────────────

local function colorRecord(color)
    if type(color) ~= "table" then return nil end
    local r, g, b = tonumber(color.r or color[1]), tonumber(color.g or color[2]), tonumber(color.b or color[3])
    if not r or not g or not b then return nil end
    return {
        r = math.floor(math.max(0, math.min(255, r))),
        g = math.floor(math.max(0, math.min(255, g))),
        b = math.floor(math.max(0, math.min(255, b)))
    }
end

--- Xenon, neon and the RGB effect modes of a vehicle, in the shape sky_mechanicjob:rgb:saveLights takes.
function VehiclePersistence.BuildLightsState(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end

    local neonData, xenonData = RgbController.GetVehicleEffectState(vehicle)
    local nr, ng, nb = GetVehicleNeonLightsColour(vehicle)
    local neonColor = (neonData and colorRecord(neonData.baseColor)) or colorRecord({ nr, ng, nb })

    local xenonIndex = math.floor(tonumber(GetVehicleXenonLightsColor(vehicle)) or -1)
    local customXenon = colorRecord(Entity(vehicle).state["sky_mechanicjob:xenonCustomColor"])
    if not customXenon and xenonIndex == 255 then
        local _ok, xr, xg, xb = GetVehicleXenonLightsCustomColor(vehicle)
        customXenon = colorRecord({ xr, xg, xb })
    end
    if customXenon then xenonIndex = 255 end
    local xenonColor = (xenonData and colorRecord(xenonData.baseColor)) or customXenon or RgbController.CaptureVehicleXenonColor(vehicle)

    local neonSides = {}
    for i = 0, 3 do
        neonSides[i + 1] = IsVehicleNeonLightEnabled(vehicle, i) == true
    end

    return {
        plate = getVehiclePlate(vehicle),
        xenon = IsToggleModOn(vehicle, 22) == true,
        xenonColor = xenonIndex,
        customXenonColor = customXenon,
        neonEnabled = neonSides,
        neonColor = neonColor,
        neonEffect = {
            mode = neonData and neonData.mode or RgbController.NEON_EFFECT_MODES.off,
            speed = neonData and neonData.speed or 5,
            color = neonColor
        },
        xenonEffect = {
            mode = xenonData and xenonData.mode or RgbController.XENON_EFFECT_MODES.off,
            speed = xenonData and xenonData.speed or 5,
            color = xenonColor,
            custom = customXenon ~= nil
        }
    }
end

--- Saves the lights through the RGB controller endpoint (driver with the item, admins, mechanics on duty).
function VehiclePersistence.SaveLights(vehicle)
    local payload = VehiclePersistence.BuildLightsState(vehicle)
    if type(payload) ~= "table" or payload.plate == "" then return false end

    CreateThread(function()
        local res = Sky.Cb.Trigger("sky_mechanicjob:rgb:saveLights", payload)
        if type(res) == "table" and res.success == true then return end

        local err = type(res) == "table" and res.error or "save_failed"
        logDebug(("[sky_mechanicjob][rgb] lights save refused: plate=%s error=%s"):format(payload.plate, tostring(err)))
        if err == "not_driver" then
            notify(getNuiLocale("tablet.rgb.driver_required", "Sit in the driver seat to save the lights."), "error")
        elseif err == "missing_item" then
            notify(("%s: %s"):format(
                getNuiLocale("tablet.orders.missing_item", "Missing required item"),
                getNuiLocale("tablet.orders.items.rgb_controller", "rgb_controller")
            ), "error")
        end
    end)
    return true
end

local function applyPersistedRgb(vehicle, rgb)
    if type(rgb) ~= "table" then return end

    local neon = type(rgb.neon) == "table" and rgb.neon or nil
    if neon then
        local color = colorRecord(neon.color)
        RgbController.BindNeonEffectVehicle(vehicle)
        if color then RgbController.SetNeonBaseColor(color) end
        RgbController.SetNeonSpeed(vehicle, neon.speed)
        RgbController.SetNeonMode(vehicle, math.floor(math.max(0, math.min(3, tonumber(neon.mode) or 0))))
    end

    local xenon = type(rgb.xenon) == "table" and rgb.xenon or nil
    if xenon then
        local color = colorRecord(xenon.color)
        RgbController.BindXenonEffectVehicle(vehicle)
        if color then
            RgbController.SetXenonBaseColor(color)
            if xenon.custom == true and IsToggleModOn(vehicle, 22)
                and colorRecord(Entity(vehicle).state["sky_mechanicjob:xenonCustomColor"]) == nil then
                XenonSync.SetCustomColor(vehicle, color)
            end
        end
        RgbController.SetXenonSpeed(vehicle, xenon.speed)
        RgbController.SetXenonMode(vehicle, math.floor(math.max(0, math.min(3, tonumber(xenon.mode) or 0))))
    end
end

--- Fills missing local anti-lag/two-step records from server data without touching ones the menu changed.
function VehiclePersistence.SeedEffectRecords(vehicle, state)
    if type(state) ~= "table" then return end

    local plate = getVehiclePlate(vehicle)
    if plate == "" then return end

    if type(state.antiLag) == "table" and AntiLag.GetPersistedState(vehicle) == nil then
        AntiLag.ApplyPersistedStateToVehicle(vehicle, plate, state.antiLag)
    end
    if type(state.twoStep) == "table" and TwoStep.GetPersistedState(vehicle) == nil then
        TwoStep.ApplyPersistedStateToVehicle(vehicle, plate, state.twoStep)
    end
end

--- Applies the server's stance, nitro, custom handling, anti-lag, two-step and RGB effects to a vehicle.
--- Plates without a stored record keep their local state.
function VehiclePersistence.LoadForVehicle(vehicle)
    local plate = getVehiclePlate(vehicle)
    if plate == "" then return false end

    local res = Sky.Cb.Trigger("sky_mechanicjob:tuning:getProperties", { plate = plate })
    if getVehiclePlate(vehicle) ~= plate or isOpenInTuningMenu(vehicle) then return false end

    local state = type(res) == "table" and res.success == true and type(res.properties) == "table"
        and res.properties._skyMechanicTuning or nil
    if type(state) ~= "table" then return false end

    local stance = state.stance
    if type(stance) == "table" and not StanceKit.HasPendingPersist(vehicle)
        and (stance.enabled ~= false or StanceKit.BuildPersistedState(vehicle) ~= nil) then
        StanceKit.ApplyPersistedState(vehicle, stance)
    end

    NitroSystem_ApplyPersistedStateToVehicle(vehicle, plate, state.nitro)
    AntiLag.ApplyPersistedStateToVehicle(vehicle, plate, state.antiLag)
    TwoStep.ApplyPersistedStateToVehicle(vehicle, plate, state.twoStep)

    if type(state.customHandling) == "table" then
        CustomTuning.ApplyPersistedState(vehicle, state.customHandling)
    end

    applyPersistedRgb(vehicle, state.rgb)

    return true
end

-- ── Driver Tracking ──────────────────────────────────

local driverVehicle = 0

local function getDrivenVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 or not DoesEntityExist(vehicle) or GetPedInVehicleSeat(vehicle, -1) ~= ped then
        return 0
    end
    return vehicle
end

local function checkDriverVehicle()
    local vehicle = getDrivenVehicle()
    if vehicle == driverVehicle then return end

    driverVehicle = vehicle
    if vehicle == 0 then return end

    CreateThread(function()
        StanceKit.EnsureRuntimeForVehicle(vehicle)
        VehiclePersistence.LoadForVehicle(vehicle)
        VehicleEffects.SyncRuntimeForCurrentVehicle()
    end)
end

-- GTA has no exit game event; the poll also catches seat changes and resource restarts.
AddEventHandler("gameEventTriggered", function(eventName)
    if eventName == "CEventNetworkPlayerEnteredVehicle" then
        checkDriverVehicle()
    end
end)

CreateThread(function()
    while true do
        checkDriverVehicle()
        Wait(500)
    end
end)

-- For garage scripts: TriggerClientEvent("sky_mechanicjob:tuning:vehicleSpawned", src, netId)
RegisterNetEvent("sky_mechanicjob:tuning:vehicleSpawned", function(netIdRaw)
    local netId = math.floor(tonumber(netIdRaw) or 0)
    if netId <= 0 then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle == 0 or not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then return end

    CreateThread(function()
        VehiclePersistence.LoadForVehicle(vehicle)
    end)
end)
