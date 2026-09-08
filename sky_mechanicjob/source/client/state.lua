if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/state.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/state.lua
--  Deobfuscated & Cleaned
-- =====================================================

-- ── Global Defaults ──────────────────────────────────

DEFAULT_PART_ITEM = DEFAULT_PART_ITEM or "body_kit"
locales = locales or {}
tuningLocales = tuningLocales or {}
nuiLocales = nuiLocales or {}

-- ── Electric Vehicle Detection ───────────────────────

local ELECTRIC_BUILD_THRESHOLD = 3258
local cachedElectricModels = nil

local function getElectricModelMap()
    if cachedElectricModels ~= nil then
        return cachedElectricModels
    end

    cachedElectricModels = {}
    local models = ((Config.ElectricVehicleFallback or {}).models) or {}

    for _, modelName in ipairs(models) do
        cachedElectricModels[GetHashKey(modelName)] = true
    end

    return cachedElectricModels
end

function IsMechanicElectricVehicle(vehicle)
    local modelHash = GetEntityModel(vehicle)
    local buildNumber = GetGameBuildNumber()

    if buildNumber >= ELECTRIC_BUILD_THRESHOLD then
        local isElectric = GetIsVehicleElectric(modelHash)
        return isElectric and isElectric ~= 0
    end

    return getElectricModelMap()[modelHash] == true
end

-- ── Vehicle Hood Check ───────────────────────────────

function HasVehicleHood(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print(string.format("[sky_mechanicjob][vehicle] hood check failed: invalid vehicle (%s)", tostring(vehicle)))
        return false
    end

    return GetEntityBoneIndexByName(vehicle, "bonnet") ~= -1
end

-- ── getNuiLocale fallback ────────────────────────────

if getNuiLocale == nil then
    function getNuiLocale(_key, fallback)
        return fallback
    end
end

-- ── Label Tables ─────────────────────────────────────

MOD_LABELS = MOD_LABELS or {
    [0] = "Spoiler", [1] = "Front Bumper", [2] = "Rear Bumper", [3] = "Side Skirt",
    [4] = "Exhaust", [5] = "Roll Cage", [6] = "Grille", [7] = "Hood",
    [8] = "Left Fender", [9] = "Right Fender", [10] = "Roof",
    [11] = "Engine", [12] = "Brakes", [13] = "Transmission", [14] = "Horn",
    [15] = "Suspension", [16] = "Armor", [18] = "Turbo", [22] = "Xenon Lights",
    [23] = "Front Wheels", [24] = "Rear Wheels", [25] = "Plate Holder",
    [26] = "Vanity Plate", [27] = "Trim Design", [28] = "Ornaments",
    [29] = "Dashboard", [30] = "Dial", [31] = "Door Speaker", [32] = "Seats",
    [33] = "Steering Wheel", [34] = "Shifter Lever", [35] = "Plaques",
    [36] = "Speaker", [37] = "Trunk", [38] = "Hydraulics", [39] = "Engine Block",
    [40] = "Air Filter", [41] = "Struts", [42] = "Arch Cover", [43] = "Aerial",
    [44] = "Trim", [45] = "Tank", [46] = "Windows", [48] = "Livery", [49] = "Lightbar"
}

WHEEL_TYPE_LABELS = WHEEL_TYPE_LABELS or {
    [0] = "Sport", [1] = "Muscle", [2] = "Lowrider", [3] = "SUV",
    [4] = "Offroad", [5] = "Tuner", [6] = "Bike", [7] = "High End",
    [8] = "Benny Original", [9] = "Benny Bespoke", [10] = "Open Wheel",
    [11] = "Street", [12] = "Track"
}

WINDOW_TINT_LABELS = WINDOW_TINT_LABELS or {
    [-1] = "None", [0] = "Stock", [1] = "Pure Black", [2] = "Dark Smoke",
    [3] = "Light Smoke", [4] = "Limo", [5] = "Green", [6] = "Unknown"
}

PLATE_LABELS = PLATE_LABELS or {
    [0] = "Blue on White #1", [1] = "Yellow on Black", [2] = "Yellow on Blue",
    [3] = "Blue on White #2", [4] = "Blue on White #3", [5] = "North Yankton"
}

XENON_LABELS = XENON_LABELS or {
    [-1] = "Stock", [0] = "White", [1] = "Blue", [2] = "Electric Blue",
    [3] = "Mint Green", [4] = "Lime Green", [5] = "Yellow", [6] = "Golden Shower",
    [7] = "Orange", [8] = "Red", [9] = "Pony Pink", [10] = "Hot Pink",
    [11] = "Purple", [12] = "Blacklight"
}

-- ── Color Preset Tables ──────────────────────────────

XENON_COLOR_PRESETS = XENON_COLOR_PRESETS or {
    { index = -1, name = "Stock",          rgb = { 244, 247, 255 } },
    { index = 0,  name = "White",          rgb = { 244, 247, 255 } },
    { index = 1,  name = "Blue",           rgb = { 79,  123, 255 } },
    { index = 2,  name = "Electric Blue",  rgb = { 0,   182, 255 } },
    { index = 3,  name = "Mint Green",     rgb = { 87,  255, 212 } },
    { index = 4,  name = "Lime Green",     rgb = { 133, 255, 57  } },
    { index = 5,  name = "Yellow",         rgb = { 255, 226, 102 } },
    { index = 6,  name = "Golden Shower",  rgb = { 255, 201, 56  } },
    { index = 7,  name = "Orange",         rgb = { 255, 141, 64  } },
    { index = 8,  name = "Red",            rgb = { 255, 72,  91  } },
    { index = 9,  name = "Pony Pink",      rgb = { 255, 140, 215 } },
    { index = 10, name = "Hot Pink",       rgb = { 255, 77,  188 } },
    { index = 11, name = "Purple",         rgb = { 164, 107, 255 } },
    { index = 12, name = "Blacklight",     rgb = { 95,  92,  255 } }
}

NEON_COLOR_PRESETS = NEON_COLOR_PRESETS or {
    { name = "White",         rgb = { 222, 222, 255 } },
    { name = "Blue",          rgb = { 2,   21,  255 } },
    { name = "Electric Blue", rgb = { 3,   83,  255 } },
    { name = "Mint Green",    rgb = { 0,   255, 140 } },
    { name = "Lime Green",    rgb = { 94,  255, 1   } },
    { name = "Yellow",        rgb = { 255, 255, 0   } },
    { name = "Golden Shower", rgb = { 255, 150, 0   } },
    { name = "Orange",        rgb = { 255, 62,  0   } },
    { name = "Red",           rgb = { 255, 1,   1   } },
    { name = "Pony Pink",     rgb = { 255, 50,  100 } },
    { name = "Hot Pink",      rgb = { 255, 5,   190 } },
    { name = "Purple",        rgb = { 35,  1,   255 } },
    { name = "Blacklight",    rgb = { 15,  3,   255 } }
}

TIRE_SMOKE_PRESETS = TIRE_SMOKE_PRESETS or {
    { name = "White",  rgb = { 254, 254, 254 } },
    { name = "Black",  rgb = { 20,  20,  20  } },
    { name = "Red",    rgb = { 255, 0,   0   } },
    { name = "Blue",   rgb = { 0,   0,   255 } },
    { name = "Yellow", rgb = { 255, 255, 0   } },
    { name = "Orange", rgb = { 255, 132, 0   } },
    { name = "Green",  rgb = { 0,   255, 0   } },
    { name = "Purple", rgb = { 180, 0,   255 } },
    { name = "Pink",   rgb = { 255, 60,  180 } },
    { name = "Ice",    rgb = { 120, 200, 255 } }
}

-- ── Section / Tuning Constants ───────────────────────

SECTION_ORDER = SECTION_ORDER or {
    "performance", "handling", "bodywork", "wheels", "lights", "paint", "stancer"
}

STANCER_SCALE = STANCER_SCALE or 100

STANCER_OPTION_BOUNDS = STANCER_OPTION_BOUNDS or {
    camber_front       = { min = -45, max = 45 },
    camber_rear        = { min = -45, max = 45 },
    track_width_front  = { min = 0,   max = 150 },
    track_width_rear   = { min = 0,   max = 150 },
    suspension_height  = { min = -30, max = 30 }
}

WHEEL_TYPE_KEY_BY_INDEX = WHEEL_TYPE_KEY_BY_INDEX or {
    [0] = "sport", [1] = "muscle", [2] = "lowrider", [3] = "suv",
    [4] = "offroad", [5] = "tuner", [6] = "bike", [7] = "highend",
    [8] = "benny_original", [9] = "benny_bespoke", [10] = "open_wheel",
    [11] = "street", [12] = "track"
}

-- ── Tuning Cost Profile ──────────────────────────────

tuningCostProfile = tuningCostProfile or (function()
    local jobCfg = ((Config or {}).Jobs or {})[1] or {}
    local profile = jobCfg.tuningCostProfile

    if not profile and Config and Config.TuningCostProfile then
        return Config.TuningCostProfile
    end

    return profile or {
        fallbackVehicleValue = 0,
        wheelTypeCost = { sport = 0 },
        optionCostByOptionId = {},
        performanceStages = {},
        appearanceMods = {}
    }
end)()

customHandlingConfig = customHandlingConfig or (function()
    if Config and Config.CustomHandlingOptions then
        return Config.CustomHandlingOptions
    end
    return { enabled = false, profiles = {} }
end)()

stagedCostByModType = stagedCostByModType or {}
flatCostByModType = flatCostByModType or {}

-- Populate stagedCostByModType from performance stages if empty
if next(stagedCostByModType) == nil then
    for _, stage in pairs(tuningCostProfile.performanceStages or {}) do
        stagedCostByModType[stage.modType] = stage.cost
    end
end

-- Populate flatCostByModType from appearance mods if empty
if next(flatCostByModType) == nil then
    for _, mod in pairs(tuningCostProfile.appearanceMods or {}) do
        flatCostByModType[mod.modType] = mod.cost
    end
end

-- ── Order Item Props ─────────────────────────────────

ORDER_ITEM_PROPS = ORDER_ITEM_PROPS or {
    wheels       = "prop_wheel_01",
    spray_can    = "prop_cs_spray_can",
    body_kit     = "prop_car_door_01",
    engine_oil   = "v_ind_cs_oilbot05",
    nitro_kit    = "v_ind_cs_gascanister",
    wash_sponge  = "prop_sponge_01",
    vehicle_wax  = "prop_blox_spray",
    engine       = "prop_car_engine_01",
    brakes       = "prop_cs_wrench",
    transmission = "prop_cs_wrench",
    turbo        = "prop_cs_wrench",
    stance_kit   = "prop_cs_wrench"
}

-- ── Global State Objects ─────────────────────────────

TuningState = TuningState or {
    active = false,
    adminMode = false,
    instantMode = false,
    selfServiceMode = false,
    vehicle = 0,
    skipRestoreOnClose = false,
    nuiFocused = false,
    focusToggleReadyAt = 0,
    camera = nil,
    options = {},
    optionMap = {},
    sections = {},
    snapshotProps = nil,
    xenonCustomStateSnapshot = nil,
    stanceSnapshot = nil,
    stanceSnapshotPlate = nil,
    stanceDirty = false,
    antiLagSnapshot = nil,
    twoStepSnapshot = nil,
    optionBaselines = {},
    customHandlingBase = nil,
    customHandlingSelections = {},
    customHandlingSelectionsByNetId = {},
    customHandlingSelectionsByPlate = {},
    customHandlingAppliedByNetId = {},
    suppressPreviews = false,
    vehiclePrices = {},
    rgbNeonEffectVehicleNetId = 0,
    rgbNeonEffectMode = 0,
    rgbNeonEffectSpeed = 5,
    rgbXenonEffectVehicleNetId = 0,
    rgbXenonEffectMode = 0,
    rgbXenonEffectSpeed = 5
}

OrderInstallState = OrderInstallState or {
    active = false,
    finalizing = false,
    orderId = 0,
    partIndex = 0,
    part = nil,
    requiredItem = DEFAULT_PART_ITEM,
    removeRequiredItemAfterUse = false,
    installFlow = "",
    repairMode = false,
    directStanceInstall = false,
    repairPart = "",
    repairPlate = "",
    tuningRemovalMode = false,
    tuningRemovalPlate = "",
    tuningRemovalValue = nil,
    tuningRemovalWheelType = nil,
    tuningRemovalValueLabel = "",
    tuningRemovalSection = "",
    vehicleNetId = 0,
    vehicle = 0,
    heldProp = 0,
    heldCarryItem = nil,
    heldCarryTransportVehicle = 0,
    heldCarryTransportMode = "hand",
    simpleChecklistVisible = false,
    simpleStep = "idle",
    stanceCompletedWheels = {}
}

WheelOrderInstallState = WheelOrderInstallState or {
    active = false,
    step = "idle",
    detachedWheelIndexes = nil,
    skipDetach = false,
    requiresBrakeInstall = false,
    requiresSuspensionInstall = false,
    checklistVisible = false
}

RepaintOrderInstallState = RepaintOrderInstallState or {
    active = false,
    step = "idle",
    checklistVisible = false
}

CatalyticInstallState = CatalyticInstallState or {
    active = false,
    mode = "steal",
    step = "idle",
    vehicle = 0,
    vehicleNetId = 0,
    plate = "",
    checklistVisible = false
}

WheelTheftState = WheelTheftState or {
    active = false,
    choiceActive = false,
    step = "idle",
    vehicle = 0,
    vehicleNetId = 0,
    plate = "",
    wheelIndexes = nil,
    checklistVisible = false,
    inputLoopRunning = false
}

OrderTabletState = OrderTabletState or {
    connectedVehicleNetId = 0
}

CarJackState = CarJackState or {
    active = false,
    lifted = false,
    prop = 0,
    vehicle = 0,
    baseCoords = nil,
    baseRotation = nil,
    targetRoll = 0.0
}

WheelDetachMinigameState = WheelDetachMinigameState or {
    active = false,
    token = 0,
    resolved = false,
    success = false,
    cancelled = false
}

RepaintMinigameState = RepaintMinigameState or {
    active = false,
    token = 0,
    resolved = false,
    success = false,
    cancelled = false
}

EngineSwapMinigameState = EngineSwapMinigameState or {
    active = false,
    token = 0,
    resolved = false,
    success = false,
    cancelled = false
}

RepaintPointingActive = RepaintPointingActive or false

-- ── Function Stubs ───────────────────────────────────
-- These globals are forward-declared as nil or fallback stubs.
-- They're implemented in their respective module files.

clearWheelInstallState = clearWheelInstallState or nil
clearRepaintInstallState = clearRepaintInstallState or nil
ensureWheelOrderStep = ensureWheelOrderStep or nil
ensureRepaintOrderStep = ensureRepaintOrderStep or nil
sendWheelChecklistUpdate = sendWheelChecklistUpdate or nil
sendRepaintChecklistUpdate = sendRepaintChecklistUpdate or nil
sendUi = sendUi or nil
releaseOrderHeldProp = releaseOrderHeldProp or nil
holdOrderRequiredItem = holdOrderRequiredItem or nil
applyOrderPartToVehicle = applyOrderPartToVehicle or nil

stopRepaintPointing = stopRepaintPointing or function() end
stopWheelWorkAnim = stopWheelWorkAnim or function() end

clearCarJackState = clearCarJackState or function(_flag)
    print("[sky_mechanicjob][bootstrap] clearCarJackState fallback executed")
end

clearCatalyticState = clearCatalyticState or nil
