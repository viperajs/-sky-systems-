if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/main.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/main.lua
--  Deobfuscated by Claude
--  Original: 6561 lines → Cleaned
-- =====================================================

-- Build check warning
if GetGameBuildNumber() < 3258 then
    print("[sky_mechanicjob] game build is lower than 3258; electric vehicle detection uses Config.ElectricVehicleFallback.models")
end

-- Locale Setup
Locales = Locales or {}
local activeLocale = "en"

if type(Sky) == "table" and type(Sky.Config) == "table" and type(Sky.Config.locale) == "string" and Sky.Config.locale ~= "" then
    activeLocale = Sky.Config.locale
elseif type(Config) == "table" and type(Config.locale) == "string" and Config.locale ~= "" then
    activeLocale = Config.locale
end

locales = Locales[activeLocale] or Locales.en or {}
tuningLocales = locales.Tuning or {}
nuiLocales = locales.Nui or {}

function getNuiLocale(key, fallback)
    if type(key) ~= "string" or key == "" then
        return fallback
    end

    local current = nuiLocales
    for part in string.gmatch(key, "[^%.]+") do
        if type(current) ~= "table" then
            return fallback
        end
        local val = current[part]
        if val == nil then
            local num = tonumber(part)
            if num ~= nil then
                val = current[num]
            end
        end
        current = val
    end

    if type(current) == "string" and current ~= "" then
        return current
    end
    return fallback
end

-- Global States
TuningState = {
    active = false,
    adminMode = false,
    instantMode = false,
    mode = "full",
    persistChangesOnClose = false,
    skipRestoreOnClose = false,
    vehicle = 0,
    societyJob = nil,
    nuiFocused = false,
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
    hidePricesForPublicSelfService = false,
    pricingProfileJob = nil,
    optionBaselines = {},
    customHandlingBase = nil,
    customHandlingSelections = {},
    customHandlingSelectionsByNetId = {},
    customHandlingSelectionsByPlate = {},
    customHandlingAppliedByNetId = {},
    vehiclePrices = {}
}

DEFAULT_PART_ITEM = "body_kit"

ORDER_ITEM_PROPS = {
    wheels = "prop_wheel_01",
    spray_can = "prop_cs_spray_can",
    body_kit = "prop_car_door_01",
    engine_oil = "v_ind_cs_oilbot05",
    nitro_kit = "v_ind_cs_gascanister",
    wash_sponge = "prop_sponge_01",
    vehicle_wax = "prop_blox_spray",
    engine = "prop_car_engine_01",
    brakes = "prop_cs_wrench",
    transmission = "prop_cs_wrench",
    turbo = "prop_cs_wrench",
    stance_kit = "prop_cs_wrench"
}

OrderInstallState = {
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

WheelOrderInstallState = {
    active = false,
    step = "idle",
    detachedWheelIndexes = nil,
    requiresBrakeInstall = false,
    requiresSuspensionInstall = false,
    checklistVisible = false
}

RepaintOrderInstallState = {
    active = false,
    step = "idle",
    checklistVisible = false
}

CatalyticInstallState = {
    active = false,
    mode = "steal",
    step = "idle",
    vehicle = 0,
    vehicleNetId = 0,
    plate = "",
    checklistVisible = false
}

WheelTheftState = {
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

OrderTabletState = {
    connectedVehicleNetId = 0
}

-- Forward declared helpers
clearWheelInstallState = nil
clearRepaintInstallState = nil
ensureWheelOrderStep = nil
ensureRepaintOrderStep = nil
sendWheelChecklistUpdate = nil
sendRepaintChecklistUpdate = nil
sendUi = nil
releaseOrderHeldProp = nil
holdOrderRequiredItem = nil
holdCarryItemProp = nil
applyOrderPartToVehicle = nil
clearCatalyticState = nil

-- Labels and Enums
MOD_LABELS = {
    [0] = "Spoiler", [1] = "Front Bumper", [2] = "Rear Bumper", [3] = "Side Skirt",
    [4] = "Exhaust", [5] = "Roll Cage", [6] = "Grille", [7] = "Hood",
    [8] = "Left Fender", [9] = "Right Fender", [10] = "Roof", [11] = "Engine",
    [12] = "Brakes", [13] = "Transmission", [14] = "Horn", [15] = "Suspension",
    [16] = "Armor", [18] = "Turbo", [22] = "Xenon Lights", [23] = "Front Wheels",
    [24] = "Rear Wheels", [25] = "Plate Holder", [26] = "Vanity Plate", [27] = "Trim Design",
    [28] = "Ornaments", [29] = "Dashboard", [30] = "Dial", [31] = "Door Speaker",
    [32] = "Seats", [33] = "Steering Wheel", [34] = "Shifter Lever", [35] = "Plaques",
    [36] = "Speaker", [37] = "Trunk", [38] = "Hydraulics", [39] = "Engine Block",
    [40] = "Air Filter", [41] = "Struts", [42] = "Arch Cover", [43] = "Aerial",
    [44] = "Trim", [45] = "Tank", [46] = "Windows", [48] = "Livery", [49] = "Lightbar"
}

WHEEL_TYPE_LABELS = {
    [0] = "Sport", [1] = "Muscle", [2] = "Lowrider", [3] = "SUV",
    [4] = "Offroad", [5] = "Tuner", [6] = "Bike", [7] = "High End",
    [8] = "Benny Original", [9] = "Benny Bespoke", [10] = "Open Wheel",
    [11] = "Street", [12] = "Track"
}

WINDOW_TINT_LABELS = {
    [-1] = "None", [0] = "Stock", [1] = "Pure Black", [2] = "Dark Smoke",
    [3] = "Light Smoke", [4] = "Limo", [5] = "Green", [6] = "Unknown"
}

PLATE_LABELS = {
    [0] = "Blue on White #1", [1] = "Yellow on Black", [2] = "Yellow on Blue",
    [3] = "Blue on White #2", [4] = "Blue on White #3", [5] = "North Yankton"
}

XENON_LABELS = {
    [-1] = "Stock", [0] = "White", [1] = "Blue", [2] = "Electric Blue",
    [3] = "Mint Green", [4] = "Lime Green", [5] = "Yellow", [6] = "Golden Shower",
    [7] = "Orange", [8] = "Red", [9] = "Pony Pink", [10] = "Hot Pink",
    [11] = "Purple", [12] = "Blacklight"
}

XENON_COLOR_PRESETS = {
    { index = -1, name = "Stock", rgb = { 244, 247, 255 } },
    { index = 0, name = "White", rgb = { 244, 247, 255 } },
    { index = 1, name = "Blue", rgb = { 79, 123, 255 } },
    { index = 2, name = "Electric Blue", rgb = { 0, 182, 255 } },
    { index = 3, name = "Mint Green", rgb = { 87, 255, 212 } },
    { index = 4, name = "Lime Green", rgb = { 133, 255, 57 } },
    { index = 5, name = "Yellow", rgb = { 255, 226, 102 } },
    { index = 6, name = "Golden Shower", rgb = { 255, 201, 56 } },
    { index = 7, name = "Orange", rgb = { 255, 141, 64 } },
    { index = 8, name = "Red", rgb = { 255, 72, 91 } },
    { index = 9, name = "Pony Pink", rgb = { 255, 140, 215 } },
    { index = 10, name = "Hot Pink", rgb = { 255, 77, 188 } },
    { index = 11, name = "Purple", rgb = { 164, 107, 255 } },
    { index = 12, name = "Blacklight", rgb = { 95, 92, 255 } }
}

NEON_COLOR_PRESETS = {
    { name = "White", rgb = { 222, 222, 255 } },
    { name = "Blue", rgb = { 2, 21, 255 } },
    { name = "Electric Blue", rgb = { 3, 83, 255 } },
    { name = "Mint Green", rgb = { 0, 255, 140 } },
    { name = "Lime Green", rgb = { 94, 255, 1 } },
    { name = "Yellow", rgb = { 255, 255, 0 } },
    { name = "Golden Shower", rgb = { 255, 150, 0 } },
    { name = "Orange", rgb = { 255, 62, 0 } },
    { name = "Red", rgb = { 255, 1, 1 } },
    { name = "Pony Pink", rgb = { 255, 50, 100 } },
    { name = "Hot Pink", rgb = { 255, 5, 190 } },
    { name = "Purple", rgb = { 35, 1, 255 } },
    { name = "Blacklight", rgb = { 15, 3, 255 } }
}

TIRE_SMOKE_PRESETS = {
    { name = "White", rgb = { 254, 254, 254 } },
    { name = "Black", rgb = { 20, 20, 20 } },
    { name = "Red", rgb = { 255, 0, 0 } },
    { name = "Blue", rgb = { 0, 0, 255 } },
    { name = "Yellow", rgb = { 255, 255, 0 } },
    { name = "Orange", rgb = { 255, 132, 0 } },
    { name = "Green", rgb = { 0, 255, 0 } },
    { name = "Purple", rgb = { 180, 0, 255 } },
    { name = "Pink", rgb = { 255, 60, 180 } },
    { name = "Ice", rgb = { 120, 200, 255 } }
}

SECTION_ORDER = { "performance", "handling", "bodywork", "wheels", "lights", "paint", "stancer" }

STANCER_SCALE = 100
STANCER_OPTION_BOUNDS = {
    camber_front = { min = -45, max = 45 },
    camber_rear = { min = -45, max = 45 },
    track_width_front = { min = 0, max = 150 },
    track_width_rear = { min = 0, max = 150 },
    suspension_height = { min = -30, max = 30 }
}

local wheelSizeCfg = Config and Config.WheelSizeOptions or {}
local wheelSizeBoundsCfg = wheelSizeCfg.bounds or {}

WHEEL_SIZE_SCALE = math.floor(tonumber(wheelSizeCfg.scale) or 100)
if WHEEL_SIZE_SCALE <= 0 then
    WHEEL_SIZE_SCALE = 100
end

WHEEL_SIZE_OPTION_BOUNDS = {
    size = {
        min = math.floor(tonumber(wheelSizeBoundsCfg.size and wheelSizeBoundsCfg.size.min) or 50),
        max = math.floor(tonumber(wheelSizeBoundsCfg.size and wheelSizeBoundsCfg.size.max) or 150)
    },
    width = {
        min = math.floor(tonumber(wheelSizeBoundsCfg.width and wheelSizeBoundsCfg.width.min) or 50),
        max = math.floor(tonumber(wheelSizeBoundsCfg.width and wheelSizeBoundsCfg.width.max) or 150)
    }
}

if WHEEL_SIZE_OPTION_BOUNDS.size.min > WHEEL_SIZE_OPTION_BOUNDS.size.max then
    local tmp = WHEEL_SIZE_OPTION_BOUNDS.size.min
    WHEEL_SIZE_OPTION_BOUNDS.size.min = WHEEL_SIZE_OPTION_BOUNDS.size.max
    WHEEL_SIZE_OPTION_BOUNDS.size.max = tmp
end

if WHEEL_SIZE_OPTION_BOUNDS.width.min > WHEEL_SIZE_OPTION_BOUNDS.width.max then
    local tmp = WHEEL_SIZE_OPTION_BOUNDS.width.min
    WHEEL_SIZE_OPTION_BOUNDS.width.min = WHEEL_SIZE_OPTION_BOUNDS.width.max
    WHEEL_SIZE_OPTION_BOUNDS.width.max = tmp
end

local defaultCostProfile = Config and Config.TuningCostProfile or {}

function GetJobConfigByName(jobName)
    if type(jobName) ~= "string" or jobName == "" then
        return Config and Config.Jobs and Config.Jobs[1] or nil
    end

    if Config and Config.Jobs then
        for _, job in ipairs(Config.Jobs) do
            if type(job) == "table" and job.name == jobName then
                return job
            end
        end
    end

    return nil
end

function IsJobConfigured(jobName)
    return GetJobConfigByName(jobName) ~= nil
end

function GetActiveJobKey()
    if type(Sky_Jobs) == "table" and type(Sky_Jobs.Access) == "table" then
        if Sky_Jobs.Access.HasSnapshot() ~= true then
            Sky_Jobs.Access.Refresh()
        end
        return Sky_Jobs.Access.GetJobKey()
    end
    return nil
end

function GetSelfServicePricingConfig()
    local profileCfg = Config and Config.TuningCostProfile or {}
    return {
        publicUsersSeePrices = profileCfg.publicUsersSeePrices ~= false
    }
end

function ResolveTuningCostProfile(jobKey)
    local jobConfig = GetJobConfigByName(jobKey) or {}
    local profile = jobConfig.tuningCostProfile or {}

    local result = {
        fallbackVehicleValue = defaultCostProfile.fallbackVehicleValue or 0,
        freeVehicles = defaultCostProfile.freeVehicles or {},
        priceType = defaultCostProfile.priceType or "percentage",
        wheelTypeCost = profile.wheelTypeCost or defaultCostProfile.wheelTypeCost or { sport = 0 },
        optionCostByOptionId = profile.optionCostByOptionId or defaultCostProfile.optionCostByOptionId or {},
        performanceStages = profile.performanceStages or defaultCostProfile.performanceStages or {},
        appearanceMods = profile.appearanceMods or defaultCostProfile.appearanceMods or {}
    }

    return result
end

function ResolveSelfServicePricingContext(profileJob, isSelfService)
    if isSelfService ~= true then
        return { hidePrices = false, profileJob = profileJob }
    end

    local activeJobKey = GetActiveJobKey()
    local isConfigured = IsJobConfigured(activeJobKey)
    local selfServiceCfg = GetSelfServicePricingConfig()

    if selfServiceCfg.publicUsersSeePrices then
        if isConfigured then
            return { hidePrices = false, profileJob = activeJobKey }
        end
        local fallbackJob = profileJob
        if not fallbackJob and Config and Config.Jobs and Config.Jobs[1] then
            fallbackJob = Config.Jobs[1].name
        end
        return { hidePrices = false, profileJob = fallbackJob }
    end

    if isConfigured then
        return { hidePrices = false, profileJob = activeJobKey }
    end

    return { hidePrices = true, profileJob = nil }
end

function RefreshTuningCostProfile(jobKey)
    local targetKey = jobKey or GetActiveJobKey()
    tuningCostProfile = ResolveTuningCostProfile(targetKey)

    stagedCostByModType = {}
    if type(tuningCostProfile.performanceStages) == "table" then
        for _, stage in pairs(tuningCostProfile.performanceStages) do
            stagedCostByModType[stage.modType] = stage.cost
        end
    end

    flatCostByModType = {}
    if type(tuningCostProfile.appearanceMods) == "table" then
        for _, mod in pairs(tuningCostProfile.appearanceMods) do
            flatCostByModType[mod.modType] = mod.cost
        end
    end
end

tuningCostProfile = ResolveTuningCostProfile(GetActiveJobKey())
customHandlingConfig = Config and Config.CustomHandlingOptions or { profiles = {} }
stagedCostByModType = {}
flatCostByModType = {}

RefreshTuningCostProfile(GetActiveJobKey())

AddEventHandler("sky_jobs_base:access:stateChanged", function(data)
    local jobKey = type(data) == "table" and data.jobKey or nil
    RefreshTuningCostProfile(jobKey)
end)

AddEventHandler("sky_mechanicjob:jobConfigurator:updated", function()
    RefreshTuningCostProfile()
end)

local function trimString(str)
    if str == nil then return nil end
    local trimmed = tostring(str):match("^%s*(.-)%s*$") or ""
    return trimmed ~= "" and trimmed or nil
end

local function parseWheelDamageMultipliers(list)
    Config.WheelDamage.multipliers.vehicleClasses = Config.WheelDamage.multipliers.vehicleClasses or {}
    if type(list) ~= "table" then return end

    for _, item in ipairs(list) do
        if type(item) == "table" then
            local classId = math.floor(tonumber(item.classId) or -1)
            if classId >= 0 then
                Config.WheelDamage.multipliers.vehicleClasses[classId] = tonumber(item.multiplier) or 1.0
            end
        end
    end
end

local function parseWearParts(list)
    Config.Wear.parts = Config.Wear.parts or {}
    for key in pairs(Config.Wear.parts) do
        Config.Wear.parts[key] = nil
    end

    if type(list) ~= "table" then return end

    for _, item in ipairs(list) do
        if type(item) == "table" then
            local key = trimString(item.key)
            if key then
                Config.Wear.parts[key] = {
                    kilometersToZero = tonumber(item.kilometersToZero) or 0,
                    item = trimString(item.item),
                    removeAfterUse = tonumber(item.removeAfterUse) ~= 0,
                    flow = trimString(item.flow)
                }
            end
        end
    end
end

local function parseRepairWearParts(list)
    Config.VehicleCare.repair.repairWearParts = Config.VehicleCare.repair.repairWearParts or {}
    if type(list) ~= "table" then return end

    for _, item in ipairs(list) do
        if type(item) == "table" then
            local key = trimString(item.key)
            if key then
                Config.VehicleCare.repair.repairWearParts[key] = item.repair == true
            end
        end
    end
end

local function parseCarryItems(list)
    Config.CarryItems = Config.CarryItems or {}
    Config.CarryItems.items = {}

    if type(list) ~= "table" then return end

    for _, item in ipairs(list) do
        if type(item) == "table" then
            local itemKey = trimString(item.item or item.name or item.key)
            local propModel = trimString(item.prop)

            if itemKey and propModel then
                local transportMode = trimString(item.transport)
                if not transportMode then
                    transportMode = (itemKey == "engine") and "engine_lift" or "hand"
                end

                Config.CarryItems.items[itemKey] = {
                    enabled = true,
                    transport = transportMode,
                    prop = propModel,
                    attach = {
                        bone = math.floor(tonumber(item.bone) or 28422),
                        x = tonumber(item.x) or 0.0,
                        y = tonumber(item.y) or 0.0,
                        z = tonumber(item.z) or 0.0,
                        rx = tonumber(item.rx) or 0.0,
                        ry = tonumber(item.ry) or 0.0,
                        rz = tonumber(item.rz) or 0.0
                    }
                }
            end
        end
    end
end

local function parseInstantTuningConfig(data)
    data = data or {}
    Config.InstantTuning = Config.InstantTuning or {}
    Config.InstantTuning.marker = Config.InstantTuning.marker or {}
    Config.InstantTuning.blip = Config.InstantTuning.blip or {}

    Config.InstantTuning.interactionDistance = tonumber(data.instantTuningInteractionDistance) or Config.InstantTuning.interactionDistance or 4.0
    Config.InstantTuning.forceMarkerInteraction = data.instantTuningForceMarkerInteraction == true
    Config.InstantTuning.mechanicOnly = data.instantTuningMechanicOnly == true
    Config.InstantTuning.allowedJobs = type(data.instantTuningAllowedJobs) == "table" and data.instantTuningAllowedJobs or nil
    Config.InstantTuning.priceMultiplier = tonumber(data.instantTuningPriceMultiplier) or Config.InstantTuning.priceMultiplier or 1.0
    Config.InstantTuning.label = trimString(data.instantTuningLabel) or Config.InstantTuning.label or "Instant Tuning"

    Config.InstantTuning.marker.enabled = data.instantTuningMarkerEnabled == true
    Config.InstantTuning.marker.type = math.floor(tonumber(data.instantTuningMarkerType) or Config.InstantTuning.marker.type or 1)

    Config.InstantTuning.blip.enabled = data.instantTuningBlipEnabled == true
    Config.InstantTuning.blip.name = trimString(data.instantTuningBlipName) or Config.InstantTuning.label
    Config.InstantTuning.blip.sprite = math.floor(tonumber(data.instantTuningBlipSprite) or Config.InstantTuning.blip.sprite or 72)
    Config.InstantTuning.blip.color = math.floor(tonumber(data.instantTuningBlipColor) or Config.InstantTuning.blip.color or 5)

    local locations = {}
    local rawLocs = type(data.instantTuningLocations) == "table" and data.instantTuningLocations or {}

    for _, loc in ipairs(rawLocs) do
        if type(loc) == "table" then
            local x = tonumber(loc.x)
            local y = tonumber(loc.y)
            local z = tonumber(loc.z)

            if x and y and z then
                local locObj = {
                    coords = vector3(x, y, z),
                    heading = tonumber(loc.heading) or 0.0,
                    label = trimString(loc.label) or Config.InstantTuning.label,
                    allowedJobs = type(loc.allowedJobs) == "table" and loc.allowedJobs or nil
                }
                local customDist = tonumber(loc.interactionDistance)
                if customDist and customDist > 0 then
                    locObj.interactionDistance = customDist
                end
                if loc.forceMarkerInteraction == true then
                    locObj.forceMarkerInteraction = true
                end
                if loc.mechanicOnly == true then
                    locObj.mechanicOnly = true
                end
                table.insert(locations, locObj)
            end
        end
    end

    Config.InstantTuning.locations = locations
end

local function applyConfigOverrides(data)
    data = data or {}

    Config.PartsTheft = Config.PartsTheft or {}
    Config.PartsTheft.dealer = Config.PartsTheft.dealer or {}
    Config.PartsTheft.dispatch = Config.PartsTheft.dispatch or {}

    Config.VehicleCare = Config.VehicleCare or {}
    Config.VehicleCare.wash = Config.VehicleCare.wash or {}
    Config.VehicleCare.wax = Config.VehicleCare.wax or {}
    Config.VehicleCare.repair = Config.VehicleCare.repair or {}

    Config.Wear = Config.Wear or {}
    Config.Wear.parts = Config.Wear.parts or {}

    Config.WheelDamage = Config.WheelDamage or {}
    Config.WheelDamage.multipliers = Config.WheelDamage.multipliers or {}

    Config.MileageHud = Config.MileageHud or {}
    Config.MileageHud.position = Config.MileageHud.position or {}

    Config.PartsDelivery = Config.PartsDelivery or {}
    Config.PartsDelivery.timerHud = Config.PartsDelivery.timerHud or {}
    Config.PartsDelivery.timerHud.position = Config.PartsDelivery.timerHud.position or {}
    Config.PartsDelivery.paymentMethods = Config.PartsDelivery.paymentMethods or {}

    Config.OrderInstall = Config.OrderInstall or {}
    Config.TuningWorkshopRequirement = Config.TuningWorkshopRequirement or {}

    parseInstantTuningConfig(data)

    for key, value in pairs(data) do
        if key == "primaryColor" then
            Config.PrimaryColor = value
        elseif key == "orderInstallNonMinigameDurationMs" then
            Config.OrderInstall.nonMinigameDurationMs = value
        elseif key == "tuningWorkshopRequireForInstall" then
            Config.TuningWorkshopRequirement.requireForInstall = value == true
        elseif key == "tuningWorkshopRequireForRemoval" then
            Config.TuningWorkshopRequirement.requireForRemoval = value == true
        elseif key == "tuningWorkshopDistance" then
            Config.TuningWorkshopRequirement.distance = value
        elseif key == "partsTheftItem" then
            Config.PartsTheft.item = value
        elseif key == "partsTheftRemoveItemAfterUse" then
            Config.PartsTheft.removeItemAfterUse = value == true
        elseif key == "partsTheftStolenWheelItem" then
            Config.PartsTheft.stolenWheelItem = value
        elseif key == "partsTheftCatalyticConverterItem" then
            Config.PartsTheft.catalyticConverterItem = value
        elseif key == "partsTheftDealerAccount" then
            Config.PartsTheft.dealer.account = value
        elseif key == "partsTheftDealerSellDistance" then
            Config.PartsTheft.dealer.sellDistance = value
        elseif key == "partsTheftDealerItems" then
            Config.PartsTheft.dealer.items = value
        elseif key == "partsTheftDispatchEnabled" then
            Config.PartsTheft.dispatch.enabled = value == true
        elseif key == "partsTheftDispatchJobs" then
            Config.PartsTheft.dispatch.jobs = value
        elseif key == "partsTheftDispatchTitle" then
            Config.PartsTheft.dispatch.title = value
        elseif key == "partsTheftDispatchMessage" then
            Config.PartsTheft.dispatch.message = value
        elseif key == "partsTheftDispatchCooldownSeconds" then
            Config.PartsTheft.dispatch.cooldownSeconds = value
        elseif key == "vehicleCareWashItem" then
            Config.VehicleCare.wash.item = value
        elseif key == "vehicleCareWashRemoveAfterUse" then
            Config.VehicleCare.wash.removeAfterUse = value == true
        elseif key == "vehicleCareWaxItem" then
            Config.VehicleCare.wax.item = value
        elseif key == "vehicleCareWaxRemoveAfterUse" then
            Config.VehicleCare.wax.removeAfterUse = value == true
        elseif key == "vehicleCareWaxCleanKilometers" then
            Config.VehicleCare.wax.cleanKilometers = value
        elseif key == "vehicleCareRepairItem" then
            Config.VehicleCare.repair.item = value
        elseif key == "vehicleCareRepairRemoveAfterUse" then
            Config.VehicleCare.repair.removeAfterUse = value == true
        elseif key == "vehicleCareRepairDurationMs" then
            Config.VehicleCare.repair.durationMs = value
        elseif key == "vehicleCareRepairMaxDistance" then
            Config.VehicleCare.repair.maxDistance = value
        elseif key == "vehicleCareRepairVehicleDamage" then
            Config.VehicleCare.repair.repairVehicleDamage = value == true
        elseif key == "vehicleCareRepairFixRealisticWheelDamage" then
            Config.VehicleCare.repair.fixRealisticWheelDamage = value == true
        elseif key == "vehicleCareRepairWearParts" then
            parseRepairWearParts(value)
        elseif key == "wearParts" then
            parseWearParts(value)
        elseif key == "wheelDamageDefaultMultiplier" then
            Config.WheelDamage.multipliers.default = value
        elseif key == "wheelDamageOffroadWheelsMultiplier" then
            Config.WheelDamage.multipliers.offroadWheels = value
        elseif key == "wheelDamageVehicleClassMultipliers" then
            parseWheelDamageMultipliers(value)
        elseif key == "mileageHudDigits" then
            Config.MileageHud.digits = value
        elseif key == "mileageHudPositionLeft" then
            Config.MileageHud.position.left = trimString(value)
        elseif key == "mileageHudPositionRight" then
            Config.MileageHud.position.right = trimString(value)
        elseif key == "mileageHudPositionTop" then
            Config.MileageHud.position.top = trimString(value)
        elseif key == "mileageHudPositionBottom" then
            Config.MileageHud.position.bottom = trimString(value)
        elseif key == "partsDeliveryTimeSeconds" then
            Config.PartsDelivery.deliveryTimeSeconds = value
        elseif key == "partsDeliveryTimerHudEnabled" then
            Config.PartsDelivery.timerHud.enabled = value == true
        elseif key == "partsDeliveryTimerHudPositionLeft" then
            Config.PartsDelivery.timerHud.position.left = trimString(value)
        elseif key == "partsDeliveryTimerHudPositionRight" then
            Config.PartsDelivery.timerHud.position.right = trimString(value)
        elseif key == "partsDeliveryTimerHudPositionTop" then
            Config.PartsDelivery.timerHud.position.top = trimString(value)
        elseif key == "partsDeliveryTimerHudPositionBottom" then
            Config.PartsDelivery.timerHud.position.bottom = trimString(value)
        elseif key == "partsDeliveryOwnCard" then
            Config.PartsDelivery.paymentMethods.own_card = value == true
        elseif key == "partsDeliveryCompanyCard" then
            Config.PartsDelivery.paymentMethods.company_card = value == true
        elseif key == "partsDeliveryOpenDurationMs" then
            Config.PartsDelivery.openDurationMs = value
        elseif key == "carryItems" then
            parseCarryItems(value)
        elseif not key:find("^instantTuning") then
            Config.TuningCostProfile[key] = value
        end
    end
end

if Config and Config.UseJobConfigurator then
    RegisterNetEvent("sky_jobs_base:jobConfigurator:updated", function(resName, jobs, features, overrides)
        if resName ~= "sky_mechanicjob" then return end
        Config.Jobs = jobs
        Config.ToggleFeatures = features
        applyConfigOverrides(overrides)
        TriggerEvent("sky_mechanicjob:jobConfigurator:updated")
    end)
    TriggerServerEvent("sky_jobs_base:jobConfigurator:requestSync", "sky_mechanicjob")
end

WHEEL_TYPE_KEY_BY_INDEX = {
    [0] = "sport", [1] = "muscle", [2] = "lowrider", [3] = "suv",
    [4] = "offroad", [5] = "tuner", [6] = "bike", [7] = "high_end",
    [8] = "benny_original", [9] = "benny_bespoke", [10] = "open_wheel",
    [11] = "street", [12] = "track"
}

DETACH_WHEEL_MAX_VEHICLE_DISTANCE = 6.0
DETACH_WHEEL_MAX_BONE_DISTANCE = 2.0
DETACH_WHEEL_MINIGAME_BOLT_COUNT = 5
DETACH_WHEEL_MINIGAME_ROTATION_DEGREES = 330
REPAINT_MINIGAME_SECTOR_COUNT = 16
REPAINT_MINIGAME_REQUIRED_SECTORS = 12
REPAINT_MINIGAME_MAX_DISTANCE = 5.5
REPAINT_MINIGAME_MIN_DISTANCE = 1.2
REPAINT_MINIGAME_GRAY_COLOR = 156
REPAINT_SANDING_PROP_MODEL = "sf_prop_grinder_01a"
REPAINT_SPRAY_PROP_MODEL = "prop_cs_spray_can"
REPAINT_SPRAY_PROP_MODEL_FALLBACK = "prop_cs_spray_can"
REPAINT_SANDING_ANIM_DICT = "amb@world_human_welding@male@base"
REPAINT_SANDING_ANIM_CLIP = "base"
REPAINT_SANDING_ATTACH = { bone = 57005, x = 0.16, y = 0.03, z = -0.02, rx = -110.0, ry = 5.0, rz = 18.0 }
REPAINT_SPRAY_ATTACH = { bone = 26611, x = 0.075, y = -0.14, z = 0.01, rx = -90.0, ry = 0.0, rz = 0.0 }
REPAINT_PTFX_ASSET = "scr_playerlamgraff"
REPAINT_PTFX_NAME = "scr_lamgraff_paint_spray"
REPAINT_SANDING_PTFX_ASSET = "core"
REPAINT_SANDING_PTFX_NAME = "exp_grd_bzgas_smoke"
REPAINT_SANDING_PTFX_SCALE = 0.72
REPAINT_SPRAY_PTFX_BONE = 26611
REPAINT_SPRAY_PTFX_OFFSET = { x = 0.03, y = 0.02, z = -0.1 }
REPAINT_SPRAY_PTFX_ROT = { x = 0.0, y = 0.0, z = 90.0 }
REPAINT_SANDING_SOUND_NAME = "Drill_2"
REPAINT_SANDING_SOUND_SET = "DLC_HEIST_FLEECA_SOUNDSET"
REPAINT_SANDING_SOUND_INTERVAL_MS = 600
REPAINT_SPRAY_PTFX_SCALE = 1.0
REPAINT_GRAY_RGB = { 128, 128, 128 }

REPAINT_COLOR_RGB_BY_INDEX = {
    [0] = {13, 17, 22}, [1] = {28, 29, 33}, [2] = {50, 56, 61}, [3] = {69, 75, 79},
    [4] = {153, 157, 160}, [5] = {194, 196, 198}, [6] = {151, 154, 151}, [7] = {99, 115, 128},
    [8] = {99, 98, 92}, [9] = {60, 63, 71}, [10] = {68, 78, 84}, [11] = {29, 33, 41},
    [12] = {19, 24, 31}, [13] = {38, 40, 42}, [14] = {81, 85, 84}, [15] = {21, 25, 33},
    [16] = {30, 36, 41}, [17] = {51, 58, 60}, [18] = {140, 144, 149}, [19] = {57, 67, 77},
    [20] = {80, 98, 114}, [21] = {30, 35, 47}, [22] = {54, 58, 63}, [23] = {160, 161, 153},
    [24] = {211, 211, 211}, [25] = {183, 191, 202}, [26] = {119, 135, 148}, [27] = {192, 14, 26},
    [28] = {218, 25, 24}, [29] = {182, 17, 27}, [30] = {165, 30, 35}, [31] = {123, 26, 34},
    [32] = {142, 27, 31}, [33] = {111, 24, 24}, [34] = {73, 17, 29}, [35] = {182, 15, 37},
    [36] = {212, 74, 23}, [37] = {194, 148, 79}, [38] = {247, 134, 22}, [39] = {207, 31, 33},
    [40] = {115, 32, 33}, [41] = {242, 125, 32}, [42] = {255, 201, 31}, [43] = {156, 16, 22},
    [44] = {222, 15, 24}, [45] = {143, 30, 23}, [46] = {169, 71, 68}, [47] = {177, 108, 81},
    [48] = {55, 28, 37}, [49] = {19, 36, 40}, [50] = {18, 46, 43}, [51] = {18, 56, 60},
    [52] = {49, 66, 63}, [53] = {21, 92, 45}, [54] = {27, 103, 112}, [55] = {102, 184, 31},
    [56] = {34, 56, 62}, [57] = {29, 90, 63}, [58] = {45, 66, 63}, [59] = {69, 89, 75},
    [60] = {101, 134, 127}, [61] = {34, 46, 70}, [62] = {35, 49, 85}, [63] = {48, 76, 126},
    [64] = {71, 87, 143}, [65] = {99, 123, 167}, [66] = {57, 71, 98}, [67] = {214, 231, 241},
    [68] = {118, 175, 190}, [69] = {52, 94, 114}, [70] = {11, 156, 241}, [71] = {47, 45, 82},
    [72] = {40, 44, 77}, [73] = {35, 84, 161}, [74] = {110, 163, 198}, [75] = {17, 37, 82},
    [76] = {27, 32, 62}, [77] = {39, 81, 144}, [78] = {96, 133, 146}, [79] = {36, 70, 168},
    [80] = {66, 113, 225}, [81] = {59, 57, 224}, [82] = {31, 40, 82}, [83] = {37, 58, 167},
    [84] = {28, 53, 81}, [85] = {76, 95, 129}, [86] = {88, 104, 142}, [87] = {116, 181, 216},
    [88] = {255, 207, 32}, [89] = {251, 226, 18}, [90] = {145, 101, 50}, [91] = {224, 225, 61},
    [92] = {152, 210, 35}, [93] = {155, 140, 120}, [94] = {80, 50, 24}, [95] = {71, 63, 43},
    [96] = {34, 27, 25}, [97] = {101, 63, 35}, [98] = {119, 92, 62}, [99] = {172, 153, 117},
    [100] = {108, 107, 75}, [101] = {64, 46, 43}, [102] = {164, 150, 95}, [103] = {70, 35, 26},
    [104] = {117, 43, 25}, [105] = {191, 174, 123}, [106] = {223, 213, 178}, [107] = {247, 237, 213},
    [108] = {58, 42, 27}, [109] = {120, 95, 51}, [110] = {181, 160, 121}, [111] = {255, 255, 246},
    [112] = {234, 234, 234}, [113] = {176, 171, 148}, [114] = {69, 56, 49}, [115] = {42, 40, 43},
    [116] = {114, 108, 87}, [117] = {106, 116, 124}, [118] = {53, 65, 88}, [119] = {155, 160, 168},
    [120] = {88, 112, 161}, [121] = {234, 230, 222}, [122] = {223, 221, 208}, [123] = {242, 173, 46},
    [124] = {249, 164, 88}, [125] = {131, 197, 102}, [126] = {241, 204, 64}, [127] = {76, 195, 218},
    [128] = {78, 100, 67}, [129] = {188, 172, 143}, [130] = {248, 182, 88}, [131] = {252, 249, 241},
    [132] = {255, 255, 251}, [133] = {129, 132, 76}, [134] = {255, 255, 255}, [135] = {242, 31, 153},
    [136] = {253, 214, 205}, [137] = {223, 88, 145}, [138] = {246, 174, 32}, [139] = {176, 238, 110},
    [140] = {8, 233, 250}, [141] = {10, 12, 23}, [142] = {12, 13, 24}, [143] = {14, 13, 20},
    [144] = {159, 158, 138}, [145] = {98, 18, 118}, [146] = {11, 20, 33}, [147] = {17, 20, 26},
    [148] = {107, 31, 123}, [149] = {30, 29, 34}, [150] = {188, 25, 23}, [151] = {45, 54, 42},
    [152] = {105, 103, 72}, [153] = {122, 108, 85}, [154] = {195, 180, 146}, [155] = {90, 99, 82},
    [156] = {129, 130, 127}, [157] = {175, 214, 228}, [158] = {122, 100, 64}, [159] = {127, 106, 72},
    [160] = {141, 150, 160}, [161] = {214, 66, 79}, [162] = {142, 46, 86}, [163] = {121, 67, 200},
    [164] = {58, 125, 255}, [165] = {38, 183, 101}, [166] = {123, 207, 43}, [167] = {179, 107, 61},
    [168] = {138, 100, 62}, [169] = {203, 166, 110}, [170] = {216, 180, 74}, [171] = {31, 157, 142},
    [172] = {47, 138, 91}, [173] = {85, 115, 61}, [174] = {28, 159, 165}, [175] = {65, 136, 108},
    [176] = {46, 134, 168}, [177] = {44, 160, 168}, [178] = {47, 146, 183}, [179] = {65, 168, 214},
    [180] = {78, 132, 232}, [181] = {61, 143, 214}, [182] = {125, 89, 203}, [183] = {114, 103, 183},
    [184] = {185, 92, 183}, [185] = {197, 86, 154}, [186] = {123, 58, 87}, [187] = {196, 95, 184},
    [188] = {169, 109, 74}, [189] = {201, 89, 136}, [190] = {198, 75, 56}, [191] = {213, 122, 67},
    [192] = {212, 132, 71}, [193] = {216, 215, 239}, [194] = {198, 72, 84}, [195] = {63, 127, 215},
    [196] = {28, 79, 58}, [197] = {31, 84, 99}, [198] = {33, 61, 116}, [199] = {80, 50, 113},
    [200] = {47, 50, 67}, [201] = {147, 206, 124}, [202] = {133, 191, 232}, [203] = {177, 154, 219},
    [204] = {217, 167, 200}, [205] = {229, 226, 219}, [206] = {224, 142, 181}, [207] = {235, 212, 109},
    [208] = {123, 192, 124}, [209] = {124, 174, 216}, [210] = {217, 200, 178}, [211] = {244, 242, 238},
    [212] = {122, 126, 134}, [213] = {62, 84, 124}, [214] = {89, 74, 116}, [215] = {216, 107, 175},
    [216] = {201, 81, 90}, [217] = {88, 165, 106}, [218] = {42, 45, 53}, [219] = {52, 57, 68},
    [220] = {107, 126, 216}, [221] = {68, 73, 90}, [222] = {221, 229, 245}, [223] = {154, 160, 170},
    [224] = {79, 93, 139}, [225] = {160, 86, 122}, [226] = {89, 197, 123}, [227] = {232, 121, 185},
    [228] = {124, 93, 215}, [229] = {156, 190, 103}, [230] = {110, 166, 194}, [231] = {244, 154, 206},
    [232] = {103, 161, 222}, [233] = {241, 144, 98}, [234] = {177, 134, 224}, [235] = {81, 175, 111},
    [236] = {94, 149, 216}, [237] = {101, 179, 114}, [238] = {103, 168, 228}, [239] = {74, 170, 194},
    [240] = {95, 152, 232}, [241] = {77, 175, 123}, [242] = {244, 233, 211}
}

WHEEL_WORK_KNEEL_ANIM_DICT = "mp_car_bomb"
WHEEL_WORK_KNEEL_ANIM_CLIP = "car_bomb_mechanic"
WHEEL_WORK_OVERLAY_ANIM_DICT = "mp_car_bomb"
WHEEL_WORK_OVERLAY_ANIM_CLIP = "car_bomb_mechanic"
WHEEL_WORK_FALLBACK_SCENARIO = "WORLD_HUMAN_VEHICLE_MECHANIC"
CAR_JACK_MAX_VEHICLE_DISTANCE = 6.0
CAR_JACK_MAX_BONE_DISTANCE = 2.2
CAR_JACK_PROP_MODEL = "imp_prop_car_jack_01a"
CAR_JACK_ANIM_DICT = "mini@repair"
CAR_JACK_ANIM_CLIP = "fixing_a_ped"
CAR_JACK_LIFT_ANGLE = 5.0
CAR_JACK_LIFT_HEIGHT = 0.08
CAR_JACK_LIFT_TIME_MS = 1400
CAR_JACK_STEP_MS = 70
CAR_JACK_SIDE_PADDING = 0.05
VEHICLE_LOOKUP_FLAGS = 70
VEHICLE_LOOKUP_POLICE_FALLBACK_FLAGS = 127
CAR_JACK_VEHICLE_FLAGS = VEHICLE_LOOKUP_FLAGS
CAR_JACK_FALLBACK_VEHICLE_FLAGS = VEHICLE_LOOKUP_POLICE_FALLBACK_FLAGS

DETACH_WHEEL_CANDIDATES = {
    { index = 0, label = "front_left", bones = { "wheel_lf", "wheel_lf_dummy" } },
    { index = 1, label = "front_right", bones = { "wheel_rf", "wheel_rf_dummy" } },
    { index = 2, label = "middle_left", bones = { "wheel_lm", "wheel_lm_dummy" } },
    { index = 3, label = "middle_right", bones = { "wheel_rm", "wheel_rm_dummy" } },
    { index = 4, label = "rear_left", bones = { "wheel_lr", "wheel_lr_dummy", "wheel_r", "wheel_r_dummy" } },
    { index = 5, label = "rear_right", bones = { "wheel_rr", "wheel_rr_dummy" } }
}

CarJackState = {
    active = false,
    lifted = false,
    prop = 0,
    vehicle = 0,
    baseCoords = nil,
    baseRotation = nil,
    targetRoll = 0.0
}

WheelDetachMinigameState = { active = false, token = 0, resolved = false, success = false, cancelled = false }
RepaintMinigameState = { active = false, token = 0, resolved = false, success = false, cancelled = false }
EngineSwapMinigameState = { active = false, token = 0, resolved = false, success = false, cancelled = false }
OilDrainMinigameState = { active = false, token = 0, resolved = false, success = false, cancelled = false }
OilPourMinigameState = { active = false, token = 0, resolved = false, success = false, cancelled = false }
RepaintPointingActive = false

-- Utility Helpers
function requestVehicleControl(entity, timeoutMs)
    local maxTime = GetGameTimer() + (timeoutMs or 500)
    if NetworkHasControlOfEntity(entity) then
        return true
    end

    while GetGameTimer() < maxTime do
        NetworkRequestControlOfEntity(entity)
        if NetworkHasControlOfEntity(entity) then
            return true
        end
        Wait(0)
    end

    return NetworkHasControlOfEntity(entity)
end

function getClosestVehicleWithPoliceFallback(x, y, z, radius, modelHash, flags)
    local lookupFlags = tonumber(flags) or VEHICLE_LOOKUP_FLAGS
    local veh = GetClosestVehicle(x, y, z, radius, modelHash or 0, lookupFlags)

    if veh ~= 0 and DoesEntityExist(veh) then
        return veh, lookupFlags
    end

    if lookupFlags ~= VEHICLE_LOOKUP_FLAGS then
        return veh, lookupFlags
    end

    veh = GetClosestVehicle(x, y, z, radius, modelHash or 0, VEHICLE_LOOKUP_POLICE_FALLBACK_FLAGS)
    if veh ~= 0 and DoesEntityExist(veh) then
        return veh, VEHICLE_LOOKUP_POLICE_FALLBACK_FLAGS
    end

    return 0, VEHICLE_LOOKUP_POLICE_FALLBACK_FLAGS
end

function getClosestCarJackVehicle(coords)
    local veh, flags = getClosestVehicleWithPoliceFallback(coords.x, coords.y, coords.z, CAR_JACK_MAX_VEHICLE_DISTANCE, 0, CAR_JACK_VEHICLE_FLAGS)
    if veh ~= 0 and (flags == CAR_JACK_VEHICLE_FLAGS or flags == CAR_JACK_FALLBACK_VEHICLE_FLAGS) then
        return veh, flags
    end
    return 0, CAR_JACK_FALLBACK_VEHICLE_FLAGS
end

function requestModelLoaded(modelHash, timeoutMs)
    if type(modelHash) ~= "number" then
        print(("[sky_mechanicjob][car_jack] failed: invalid model hash type (%s)"):format(type(modelHash)))
        return false
    end

    if not IsModelInCdimage(modelHash) then
        print(("[sky_mechanicjob][car_jack] failed: model missing in cdimage for hash %s"):format(modelHash))
        return false
    end

    local maxTime = GetGameTimer() + (timeoutMs or 2500)
    RequestModel(modelHash)

    while not HasModelLoaded(modelHash) and GetGameTimer() < maxTime do
        Wait(0)
        RequestModel(modelHash)
    end

    if HasModelLoaded(modelHash) then
        return true
    end

    print(("[sky_mechanicjob][car_jack] failed: model not loaded for hash %s"):format(modelHash))
    return false
end

function requestAnimDictLoaded(animDict, timeoutMs)
    if type(animDict) ~= "string" or animDict == "" then
        print(("[sky_mechanicjob][car_jack] failed: invalid anim dict (%s)"):format(tostring(animDict)))
        return false
    end

    local maxTime = GetGameTimer() + (timeoutMs or 2500)
    RequestAnimDict(animDict)

    while not HasAnimDictLoaded(animDict) and GetGameTimer() < maxTime do
        Wait(0)
        RequestAnimDict(animDict)
    end

    if HasAnimDictLoaded(animDict) then
        return true
    end

    print(("[sky_mechanicjob][car_jack] failed: anim dict not loaded (%s)"):format(animDict))
    return false
end

OPTION_ID_CATEGORY_RULES = {
    exact = {
        wheel_size = "stancing",
        wheel_width = "stancing",
        toggle_18 = "turbo",
        wheel_type = "wheels",
        wheel_custom_23 = "wheels",
        wheel_custom_24 = "wheels",
        xenon_color = "lights",
        window_tint = "colors",
        neon_0 = "lights",
        neon_1 = "lights",
        neon_2 = "lights",
        neon_3 = "lights",
        neon_color = "lights",
        tire_smoke_color = "colors",
        toggle_22 = "lights",
        mod_headlights = "lights",
        neon_effect = "lights",
        neon_effect_speed = "lights",
        xenon_effect = "lights",
        xenon_effect_speed = "lights"
    },
    prefixes = {
        { pattern = "^stancer_", category = "stancing" },
        { pattern = "^color_", category = "colors" }
    },
    modTypes = {
        [11] = "engine",
        [12] = "brakes",
        [13] = "transmission",
        [15] = "suspension",
        [16] = "armor",
        [23] = "wheels",
        [24] = "wheels"
    }
}

local bodyworkBoneMap = {
    mod_0 = { "spoiler", "boot", "boot_dummy" }
}

function getBodyworkInstallTargetCoords(vehicle, option)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return nil
    end

    local optionId = tostring(option and option.id or "")
    local bones = bodyworkBoneMap[optionId]

    if type(bones) == "table" then
        for _, boneName in ipairs(bones) do
            local boneIdx = GetEntityBoneIndexByName(vehicle, boneName)
            if boneIdx ~= -1 then
                return GetWorldPositionOfEntityBone(vehicle, boneIdx), 2.8
            end
        end
    end

    local minDim, maxDim = GetModelDimensions(GetEntityModel(vehicle))
    local yOffset = minDim.y - 0.25
    local zOffset = math.max(minDim.z + 0.75, maxDim.z - 0.45)

    return GetOffsetFromEntityInWorldCoords(vehicle, 0.0, yOffset, zOffset), 2.8
end

function isNearBodyworkInstallTarget(vehicle, option, pedCoords)
    local targetCoords, maxDist = getBodyworkInstallTargetCoords(vehicle, option)
    if not targetCoords then return false end

    local currentCoords = pedCoords or GetEntityCoords(PlayerPedId())
    local dist = #(currentCoords - targetCoords)
    return dist <= (tonumber(maxDist) or 2.8)
end

function releaseNuiFocus()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
end

sendUi = function(action, payload)
    SendNUIMessage({
        action = action,
        payload = payload or {}
    })
end

function getNonMinigameInstallDurationMs()
    local cfgVal = Config and Config.OrderInstall and Config.OrderInstall.nonMinigameDurationMs
    local duration = math.floor(tonumber(cfgVal) or 5000)
    return math.max(duration, 1000)
end

function startNonMinigameInstallProgress(label, durationMs)
    local duration = math.max(1000, math.floor(tonumber(durationMs) or getNonMinigameInstallDurationMs()))
    local displayLabel = tostring(label or getNuiLocale("tablet.orders.installing", "Installing part"))

    sendUi("installProgress:show", {
        label = displayLabel,
        durationMs = duration
    })

    return duration
end

function stopNonMinigameInstallProgress()
    sendUi("installProgress:hide", {})
end

function clampByte(val)
    return math.floor(math.max(0, math.min(255, tonumber(val) or 0)))
end

function closeWheelDetachMinigameUi()
    sendUi("wheelDetach:minigame:close", {})
end

function closeRepaintMinigameUi()
    sendUi("repaint:minigame:close", {})
end

function closeEngineSwapMinigameUi()
    sendUi("engineSwap:minigame:close", {})
end

function closeOilDrainMinigameUi()
    sendUi("oilDrain:minigame:close", {})
end

function closeOilPourMinigameUi()
    sendUi("oilPour:minigame:close", {})
end

function requestPtfxAssetLoaded(assetName)
    Sky.Load.NamedPtfxAsset(assetName)
    if HasNamedPtfxAssetLoaded(assetName) then
        return true
    end

    print(("[sky_mechanicjob][repaint_minigame] failed: ptfx asset not loaded (%s)"):format(tostring(assetName)))
    return false
end

function startRepaintPointing()
    if RepaintPointingActive then
        return true
    end

    local ped = PlayerPedId()
    if not requestAnimDictLoaded("anim@mp_point", 2500) then
        print("[sky_mechanicjob][repaint_minigame] failed: point anim dict not loaded (anim@mp_point)")
        return false
    end

    SetPedCurrentWeaponVisible(ped, false, true, true, true)
    SetPedConfigFlag(ped, 36, true)
    Citizen.InvokeNative(0x2D72267B29F4B20A, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")

    RepaintPointingActive = true
    return true
end

function stopRepaintPointing()
    if not RepaintPointingActive then return end

    local ped = PlayerPedId()
    Citizen.InvokeNative(0xD01015B7316E1746, ped, "Stop")

    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end

    if not IsPedInAnyVehicle(ped, true) then
        SetPedCurrentWeaponVisible(ped, true, true, true, true)
    end

    SetPedConfigFlag(ped, 36, false)
    ClearPedSecondaryTask(ped)
    RepaintPointingActive = false
end

function updateRepaintPointing()
    if not RepaintPointingActive then return end

    local ped = PlayerPedId()
    local pitch = GetGameplayCamRelativePitch()

    if pitch < -70.0 then pitch = -70.0
    elseif pitch > 42.0 then pitch = 42.0 end

    local relPitch = (pitch + 70.0) / 112.0
    local heading = GetGameplayCamRelativeHeading()

    local cosH = Cos(heading)
    local sinH = Sin(heading)

    if heading < -180.0 then heading = -180.0
    elseif heading > 180.0 then heading = 180.0 end

    local relHeading = ((heading + 180.0) / 360.0)
    local rayStart = GetOffsetFromEntityInWorldCoords(ped, (cosH * -0.2) - (sinH * (0.4 * relHeading + 0.3)), (sinH * -0.2) + (cosH * (0.4 * relHeading + 0.3)), 0.6)

    local rayHandle = Cast_3dRayPointToPoint(rayStart.x, rayStart.y, rayStart.z - 0.2, rayStart.x, rayStart.y, rayStart.z + 0.2, 0.4, 95, ped, 7)
    local _, hit = GetRaycastResult(rayHandle)

    Citizen.InvokeNative(0xD5B3512262B9B06A, ped, "Pitch", pitch)
    Citizen.InvokeNative(0xD5B3512262B9B06A, ped, "Heading", (relHeading * -1.0) + 1.0)
    Citizen.InvokeNative(0xB0A6D637CD8F6942, ped, "isBlocked", hit)
    Citizen.InvokeNative(0xB0A6D637CD8F6942, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)
end

function clearCarJackState(resetVehicle)
    if resetVehicle and CarJackState.lifted and CarJackState.vehicle ~= 0 and DoesEntityExist(CarJackState.vehicle) then
        if CarJackState.baseCoords and CarJackState.baseRotation then
            SetEntityCoordsNoOffset(CarJackState.vehicle, CarJackState.baseCoords.x, CarJackState.baseCoords.y, CarJackState.baseCoords.z, false, false, false)
            SetEntityRotation(CarJackState.vehicle, CarJackState.baseRotation.x, CarJackState.baseRotation.y, CarJackState.baseRotation.z, 2, true)
        end
        FreezeEntityPosition(CarJackState.vehicle, false)
        SetVehicleOnGroundProperly(CarJackState.vehicle)
    end

    if CarJackState.prop ~= 0 and DoesEntityExist(CarJackState.prop) then
        DeleteEntity(CarJackState.prop)
    end

    CarJackState.prop = 0
    CarJackState.active = false
    CarJackState.lifted = false
    CarJackState.vehicle = 0
    CarJackState.baseCoords = nil
    CarJackState.baseRotation = nil
    CarJackState.targetRoll = 0.0
end

function getEntityRightVector(entity)
    local coords = GetEntityCoords(entity)
    local rightCoords = GetOffsetFromEntityInWorldCoords(entity, 1.0, 0.0, 0.0)

    local dx = rightCoords.x - coords.x
    local dy = rightCoords.y - coords.y
    local len = math.sqrt(dx * dx + dy * dy)

    if len <= 0.0001 then
        return { x = 1.0, y = 0.0, z = 0.0 }
    end

    return { x = dx / len, y = dy / len, z = 0.0 }
end

function getClosestWheelData(vehicle, searchCoords, maxDistance)
    local bestCandidate = nil
    local bestDist = tonumber(maxDistance) or DETACH_WHEEL_MAX_BONE_DISTANCE

    for _, candidate in ipairs(DETACH_WHEEL_CANDIDATES) do
        for _, boneName in ipairs(candidate.bones) do
            local boneIdx = GetEntityBoneIndexByName(vehicle, boneName)
            if boneIdx ~= -1 then
                local bonePos = GetWorldPositionOfEntityBone(vehicle, boneIdx)
                local dist = #(searchCoords - bonePos)
                if dist < bestDist then
                    bestDist = dist
                    bestCandidate = candidate
                end
                break
            end
        end
    end

    return bestCandidate
end

function getCarJackSideData(vehicle, searchCoords)
    local wheelCandidate = getClosestWheelData(vehicle, searchCoords, CAR_JACK_MAX_BONE_DISTANCE)
    if wheelCandidate then
        return wheelCandidate
    end

    local localCoords = GetOffsetFromEntityGivenWorldCoords(vehicle, searchCoords.x, searchCoords.y, searchCoords.z)
    local minDim, maxDim = GetModelDimensions(GetEntityModel(vehicle))

    local maxWidth = math.max(math.abs(minDim.x), math.abs(maxDim.x))
    local distToEdge = math.min(math.abs(localCoords.x - minDim.x), math.abs(localCoords.x - maxDim.x))

    if localCoords.y < (minDim.y - 1.0) or localCoords.y > (maxDim.y + 1.0) then
        return nil
    end

    if math.abs(localCoords.x) < (maxWidth * 0.55) or distToEdge > CAR_JACK_MAX_BONE_DISTANCE then
        return nil
    end

    if math.abs(localCoords.x - minDim.x) <= math.abs(localCoords.x - maxDim.x) then
        return { index = 4, label = "side_left", synthetic = true }
    else
        return { index = 5, label = "side_right", synthetic = true }
    end
end

function expandWheelIndexes(wheelIndex)
    local result = { wheelIndex }
    if wheelIndex == 2 then
        table.insert(result, 4)
    elseif wheelIndex == 3 then
        table.insert(result, 5)
    elseif wheelIndex == 4 then
        table.insert(result, 2)
    elseif wheelIndex == 5 then
        table.insert(result, 3)
    end
    return result
end

function resolveAttachWheelIndexes(vehicle, wheelIndexes)
    local indexes = type(wheelIndexes) == "table" and wheelIndexes or {}
    if #indexes > 0 then
        return indexes
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    local wheelData = getClosestWheelData(vehicle, pedCoords, DETACH_WHEEL_MAX_BONE_DISTANCE)

    if not wheelData then
        return {}
    end

    return expandWheelIndexes(wheelData.index)
end

function getNearestDetachWheelTarget()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)

    local veh = getClosestVehicleWithPoliceFallback(pedCoords.x, pedCoords.y, pedCoords.z, DETACH_WHEEL_MAX_VEHICLE_DISTANCE, 0, 70)
    if veh == 0 or not DoesEntityExist(veh) then
        return nil, nil
    end

    local wheelData = getClosestWheelData(veh, pedCoords, DETACH_WHEEL_MAX_BONE_DISTANCE)
    return veh, wheelData
end

function getNearestCarJackTarget()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)

    local veh = getClosestCarJackVehicle(pedCoords)
    if veh == 0 or not DoesEntityExist(veh) then
        return nil, nil
    end

    local sideData = getCarJackSideData(veh, pedCoords)
    return veh, sideData
end

function playCarJackPedAnim(ped, durationMs, startCoords, targetCoords)
    if not requestAnimDictLoaded(CAR_JACK_ANIM_DICT, 2500) then
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.CarJackAnimFailed or "Unable to start car jack animation."
        }
    end

    local heading = GetHeadingFromVector_2d(startCoords.x - targetCoords.x, startCoords.y - targetCoords.y)
    SetEntityHeading(ped, heading)
    TaskPlayAnim(ped, CAR_JACK_ANIM_DICT, CAR_JACK_ANIM_CLIP, 4.0, -4.0, durationMs, 1, 0.0, false, false, false)

    return true, nil, wheelIndexes
end
