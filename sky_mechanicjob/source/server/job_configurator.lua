if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/job_configurator.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/job_configurator.lua
--  Settings schema of the shared /jobconfig UI
-- =====================================================

-- sky_jobs_base builds the "Mechanic Jobs" configurator from this schema: the settings
-- sections of its sidebar (Parts Theft, Vehicle Care, Wear, ...), the global pricing
-- settings and the Parts Delivery / Tuning Prices tabs of a workshop, and the Interactions
-- page. Every default is read from config.lua / adv_config.lua, so a value that was never
-- saved in the configurator behaves like the Lua config (source/config_overrides.lua applies
-- the saved values over it on the clients and the server).

local WEAR_PART_ORDER = {
    "tyres", "brake_pads", "suspension", "spark_plugs", "engine_oil", "coolant", "brake_fluid",
    "transmission_fluid", "clutch", "air_filter", "catalytic_converter", "traction_battery", "inverter"
}

local WEAR_PART_LABELS = {
    tyres = "Tyres", brake_pads = "Brake Pads", suspension = "Suspension", spark_plugs = "Spark Plugs",
    engine_oil = "Engine Oil", coolant = "Coolant", brake_fluid = "Brake Fluid",
    transmission_fluid = "Transmission Fluid", clutch = "Clutch", air_filter = "Air Filter",
    catalytic_converter = "Catalytic Converter", traction_battery = "Traction Battery", inverter = "Power Inverter"
}

local VEHICLE_CLASS_LABELS = {
    [0] = "Compacts", "Sedans", "SUVs", "Coupes", "Muscle", "Sports Classics", "Sports", "Super",
    "Motorcycles", "Off-road", "Industrial", "Utility", "Vans", "Cycles", "Boats", "Helicopters",
    "Planes", "Service", "Emergency", "Military", "Commercial", "Trains", "Open Wheel"
}

local WEAR_FLOWS = { "wheel", "performance", "underbody_neon", "oil_change", "fluid_refill", "catalytic_converter", "hood_install" }
local WEAR_FLOW_LABELS = {
    wheel = "Wheel", performance = "Performance", underbody_neon = "Underbody / lift", oil_change = "Oil change",
    fluid_refill = "Fluid refill", catalytic_converter = "Catalytic converter", hood_install = "Hood install"
}

local CARRY_TRANSPORTS = { { value = "hand", label = "Hand" }, { value = "forklift", label = "Forklift" }, { value = "engine_lift", label = "Engine Hoist" } }

local CARRY_BONES = {
    { value = 28422, label = "Right hand (28422)" },
    { value = 60309, label = "Left hand (60309)" },
    { value = 57005, label = "Right hand IK (57005)" },
    { value = 18905, label = "Left hand IK (18905)" },
    { value = 24818, label = "Spine (24818)" }
}

-- Interactions placed in workshops (client/main.lua CREATOR_POINT_INTERACTIONS).
local INTERACTION_LABELS = {
    self_service_tuning = "Self Service Tuning",
    engine_hoist_location = "Engine Hoist",
    workshop_lift = "Workshop Lift",
    part_delivery = "Parts Delivery",
    stolen_parts_dealer = "Stolen Parts Dealer"
}
local INTERACTION_ORDER = { "self_service_tuning", "workshop_lift", "engine_hoist_location", "part_delivery", "stolen_parts_dealer" }

-- Copy of a config value the NUI and other resources can receive: vectors become
-- { x, y, z } and functions are dropped.
local function plain(value)
    local valueType = type(value)
    if valueType == "vector3" or valueType == "vector4" or valueType == "vector2" then
        return { x = value.x, y = value.y, z = value.z, w = value.w }
    elseif valueType == "table" then
        local copy = {}
        for k, v in pairs(value) do
            local c = plain(v)
            if c ~= nil then copy[k] = c end
        end
        return copy
    elseif valueType == "string" or valueType == "number" or valueType == "boolean" then
        return value
    end
    return nil
end

local function stringOr(value, fallback)
    if type(value) == "string" then return value end
    if value == nil then return fallback or "" end
    return tostring(value)
end

local function numberOr(value, fallback)
    return tonumber(value) or fallback or 0
end

local function stringList(value)
    local list = {}
    for _, entry in ipairs(type(value) == "table" and value or {}) do
        if type(entry) == "string" and entry ~= "" then
            list[#list + 1] = entry
        end
    end
    return list
end

-- Screen position of a HUD as the four settings the position picker writes.
local function positionSettings(defaults, prefix, position)
    position = type(position) == "table" and position or {}
    defaults[prefix .. "Left"] = stringOr(position.left)
    defaults[prefix .. "Right"] = stringOr(position.right)
    defaults[prefix .. "Top"] = stringOr(position.top)
    defaults[prefix .. "Bottom"] = stringOr(position.bottom)
end

local function sortedKeys(map, order)
    local keys, seen = {}, {}
    for _, key in ipairs(order or {}) do
        if map[key] ~= nil then
            keys[#keys + 1] = key
            seen[key] = true
        end
    end
    local rest = {}
    for key in pairs(map) do
        if type(key) == "string" and not seen[key] then
            rest[#rest + 1] = key
        end
    end
    table.sort(rest)
    for _, key in ipairs(rest) do
        keys[#keys + 1] = key
    end
    return keys
end

local function buildDefaultSettings()
    local profile = Config.TuningCostProfile or {}
    local theft = Config.PartsTheft or {}
    local dealer = theft.dealer or {}
    local dispatch = theft.dispatch or {}
    local care = Config.VehicleCare or {}
    local wash, wax, repair = care.wash or {}, care.wax or {}, care.repair or {}
    local wheelMultipliers = (Config.WheelDamage or {}).multipliers or {}
    local mileage = Config.MileageHud or {}
    local delivery = Config.PartsDelivery or {}
    local timerHud = delivery.timerHud or {}
    local payments = delivery.paymentMethods or {}
    local instant = Config.InstantTuning or {}
    local instantMarker, instantBlip = instant.marker or {}, instant.blip or {}

    local defaults = {
        addRevenueToSociety = profile.addRevenueToSociety ~= false,
        publicUsersSeePrices = profile.publicUsersSeePrices ~= false,
        fallbackVehicleValue = numberOr(profile.fallbackVehicleValue, 50000),
        priceType = stringOr(profile.priceType, "percentage"),
        freeVehicles = stringList(profile.freeVehicles),

        partsTheftItem = stringOr(theft.item),
        partsTheftRemoveItemAfterUse = theft.removeItemAfterUse == true,
        partsTheftStolenWheelItem = stringOr(theft.stolenWheelItem),
        partsTheftCatalyticConverterItem = stringOr(theft.catalyticConverterItem),
        partsTheftDealerAccount = stringOr(dealer.account, "money"),
        partsTheftDealerSellDistance = numberOr(dealer.sellDistance, 5.0),
        partsTheftDealerItems = {},
        partsTheftDispatchEnabled = dispatch.enabled ~= false,
        partsTheftDispatchJobs = stringList(dispatch.jobs),
        partsTheftDispatchTitle = stringOr(dispatch.title),
        partsTheftDispatchMessage = stringOr(dispatch.message),
        partsTheftDispatchCooldownSeconds = numberOr(dispatch.cooldownSeconds, 120),

        vehicleCareWashItem = stringOr(wash.item),
        vehicleCareWashRemoveAfterUse = wash.removeAfterUse ~= false,
        vehicleCareWaxItem = stringOr(wax.item),
        vehicleCareWaxRemoveAfterUse = wax.removeAfterUse ~= false,
        vehicleCareWaxCleanKilometers = numberOr(wax.cleanKilometers, 35),
        vehicleCareRepairItem = stringOr(repair.item),
        vehicleCareRepairRemoveAfterUse = repair.removeAfterUse ~= false,
        vehicleCareRepairDurationMs = math.floor(numberOr(repair.durationMs, 10000)),
        vehicleCareRepairMaxDistance = numberOr(repair.maxDistance, 6.0),
        vehicleCareRepairVehicleDamage = repair.repairVehicleDamage ~= false,
        vehicleCareRepairFixRealisticWheelDamage = repair.fixRealisticWheelDamage ~= false,
        vehicleCareRepairWearParts = {},

        wearParts = {},

        wheelDamageDefaultMultiplier = numberOr(wheelMultipliers.default, 1.0),
        wheelDamageOffroadWheelsMultiplier = numberOr(wheelMultipliers.offroadWheels, 1.0),
        wheelDamageVehicleClassMultipliers = {},

        mileageHudDigits = math.floor(numberOr(mileage.digits, 6)),

        partsDeliveryTimeSeconds = numberOr(delivery.deliveryTimeSeconds, 60),
        partsDeliveryTimerHudEnabled = timerHud.enabled ~= false,
        partsDeliveryOwnCard = payments.own_card ~= false,
        partsDeliveryCompanyCard = payments.company_card ~= false,
        partsDeliveryOpenDurationMs = math.floor(numberOr(delivery.openDurationMs, 5500)),

        instantTuningInteractionDistance = numberOr(instant.interactionDistance, 4.0),
        instantTuningForceMarkerInteraction = instant.forceMarkerInteraction == true,
        instantTuningMechanicOnly = instant.mechanicOnly == true,
        instantTuningAllowedJobs = stringList(instant.allowedJobs),
        instantTuningPriceMultiplier = numberOr(instant.priceMultiplier, 1.0),
        instantTuningLabel = stringOr(instant.label, "Instant Tuning"),
        instantTuningMarkerEnabled = instantMarker.enabled ~= false,
        instantTuningMarkerType = math.floor(numberOr(instantMarker.type, 1)),
        instantTuningBlipEnabled = instantBlip.enabled == true,
        instantTuningBlipName = stringOr(instantBlip.name, stringOr(instant.label, "Instant Tuning")),
        instantTuningBlipSprite = math.floor(numberOr(instantBlip.sprite, 72)),
        instantTuningBlipColor = math.floor(numberOr(instantBlip.color, 5)),
        instantTuningLocations = {},

        carryItems = {}
    }

    positionSettings(defaults, "mileageHudPosition", mileage.position)
    positionSettings(defaults, "partsDeliveryTimerHudPosition", timerHud.position)

    for _, item in ipairs(type(dealer.items) == "table" and dealer.items or {}) do
        if type(item) == "table" then
            defaults.partsTheftDealerItems[#defaults.partsTheftDealerItems + 1] = {
                name = stringOr(item.name),
                label = stringOr(item.label, stringOr(item.name)),
                amount = math.floor(numberOr(item.amount, 1)),
                price = numberOr(item.price, 0)
            }
        end
    end

    local wearParts = (Config.Wear or {}).parts or {}
    local repairWearParts = type(repair.repairWearParts) == "table" and repair.repairWearParts or {}
    for _, key in ipairs(sortedKeys(wearParts, WEAR_PART_ORDER)) do
        local part = type(wearParts[key]) == "table" and wearParts[key] or {}
        defaults.wearParts[#defaults.wearParts + 1] = {
            key = key,
            label = WEAR_PART_LABELS[key] or key,
            kilometersToZero = numberOr(part.kilometersToZero, 0),
            item = stringOr(part.item),
            removeAfterUse = part.removeAfterUse ~= false,
            flow = stringOr(part.flow)
        }
        defaults.vehicleCareRepairWearParts[#defaults.vehicleCareRepairWearParts + 1] = {
            key = key,
            label = WEAR_PART_LABELS[key] or key,
            repair = repairWearParts[key] ~= false
        }
    end

    local classMultipliers = type(wheelMultipliers.vehicleClasses) == "table" and wheelMultipliers.vehicleClasses or {}
    for classId = 0, #VEHICLE_CLASS_LABELS do
        defaults.wheelDamageVehicleClassMultipliers[#defaults.wheelDamageVehicleClassMultipliers + 1] = {
            classId = classId,
            label = VEHICLE_CLASS_LABELS[classId],
            multiplier = numberOr(classMultipliers[classId], 1.0)
        }
    end

    for _, location in ipairs(type(instant.locations) == "table" and instant.locations or {}) do
        if type(location) == "table" then
            local coords = location.coords or location
            local x, y, z = tonumber(coords.x), tonumber(coords.y), tonumber(coords.z)
            if x and y and z then
                defaults.instantTuningLocations[#defaults.instantTuningLocations + 1] = {
                    label = stringOr(location.label, defaults.instantTuningLabel),
                    x = x, y = y, z = z,
                    heading = numberOr(location.heading, 0.0),
                    interactionDistance = numberOr(location.interactionDistance, 0),
                    forceMarkerInteraction = location.forceMarkerInteraction == true,
                    mechanicOnly = location.mechanicOnly == true,
                    allowedJobs = stringList(location.allowedJobs)
                }
            end
        end
    end

    local carryItems = (Config.CarryItems or {}).items or {}
    for _, itemName in ipairs(sortedKeys(carryItems)) do
        local item = carryItems[itemName]
        if type(item) == "table" and item.enabled ~= false and type(item.prop) == "string" then
            local attach = type(item.attach) == "table" and item.attach or {}
            defaults.carryItems[#defaults.carryItems + 1] = {
                item = itemName,
                transport = stringOr(item.transport, itemName == "engine" and "engine_lift" or "hand"),
                prop = item.prop,
                bone = math.floor(numberOr(attach.bone, 28422)),
                x = numberOr(attach.x, 0.0), y = numberOr(attach.y, 0.0), z = numberOr(attach.z, 0.0),
                rx = numberOr(attach.rx, 0.0), ry = numberOr(attach.ry, 0.0), rz = numberOr(attach.rz, 0.0)
            }
        end
    end

    return defaults
end

local function selectOptions(values, labels, settingKey, fieldKey)
    local options = {}
    for _, value in ipairs(values) do
        options[#options + 1] = {
            value = value,
            label = labels[value] or value,
            labelKey = ("workshopConfig.settings.%s.fields.%s.options.%s"):format(settingKey, fieldKey, value)
        }
    end
    return options
end

local function buildSettingDefinitions()
    local definitions = {}

    -- One definition; section, label and description keys follow the sky_jobs_base locales
    -- (workshopConfig.settingSections / workshopConfig.settings).
    local function add(section, key, definition)
        definition.key = key
        definition.labelKey = ("workshopConfig.settings.%s.label"):format(key)
        definition.descriptionKey = ("workshopConfig.settings.%s.description"):format(key)
        if section then
            definition.section = section.key
            definition.sectionLabel = section.label
            definition.sectionLabelKey = ("workshopConfig.settingSections.%s"):format(section.key)
            definition.sectionIcon = section.icon
            definition.featureKey = section.featureKey
        end
        definitions[#definitions + 1] = definition
    end

    -- No section: the "Global pricing settings" of the Tuning Prices tab.
    add(nil, "addRevenueToSociety", { type = "boolean", label = "Deposit revenue to society", description = "Deposit paid tuning order money into the tuning job society account." })
    add(nil, "publicUsersSeePrices", { type = "boolean", label = "Public users see prices", description = "Show regular tuning prices to non-mechanic public users." })
    add(nil, "fallbackVehicleValue", { type = "number", min = 0, label = "Fallback vehicle value", description = "Value used when no vehicle price can be resolved." })
    add(nil, "priceType", {
        type = "string",
        label = "Price type",
        description = "Percentage calculates each tuning cost from the vehicle price. Fixed uses the entered money amount.",
        options = {
            { value = "percentage", label = "Percentage", labelKey = "workshopConfig.settings.priceType.options.percentage" },
            { value = "fixed", label = "Fixed", labelKey = "workshopConfig.settings.priceType.options.fixed" }
        }
    })
    add(nil, "freeVehicles", { type = "stringList", label = "Free tuning vehicles", description = "Vehicle spawn models that receive free tuning orders." })

    local partsTheft = { key = "partsTheft", label = "Parts Theft", icon = "Wrench" }
    add(partsTheft, "partsTheftItem", { type = "string", label = "Theft tool item" })
    add(partsTheft, "partsTheftRemoveItemAfterUse", { type = "boolean", label = "Consume theft tool" })
    add(partsTheft, "partsTheftStolenWheelItem", { type = "string", label = "Stolen wheel item" })
    add(partsTheft, "partsTheftCatalyticConverterItem", { type = "string", label = "Catalytic converter item" })
    add(partsTheft, "partsTheftDealerAccount", { type = "string", label = "Dealer payout account" })
    add(partsTheft, "partsTheftDealerSellDistance", { type = "number", min = 0, label = "Dealer sell distance" })
    add(partsTheft, "partsTheftDealerItems", {
        type = "table",
        label = "Dealer items",
        itemLabel = "Dealer item",
        itemLabelKey = "workshopConfig.settings.partsTheftDealerItems.itemLabel",
        columns = {
            { key = "name", type = "string", label = "Item name", labelKey = "workshopConfig.settingFields.name" },
            { key = "label", type = "string", label = "Label", labelKey = "workshopConfig.settingFields.label" },
            { key = "amount", type = "integer", min = 1, default = 1, label = "Amount", labelKey = "workshopConfig.settingFields.amount" },
            { key = "price", type = "number", min = 0, default = 0, label = "Price", labelKey = "workshopConfig.settingFields.price" }
        }
    })
    add(partsTheft, "partsTheftDispatchEnabled", { type = "boolean", label = "Send police dispatch" })
    add(partsTheft, "partsTheftDispatchJobs", { type = "stringList", label = "Dispatch jobs" })
    add(partsTheft, "partsTheftDispatchTitle", { type = "string", label = "Dispatch title" })
    add(partsTheft, "partsTheftDispatchMessage", { type = "string", label = "Dispatch message" })
    add(partsTheft, "partsTheftDispatchCooldownSeconds", { type = "integer", min = 0, label = "Dispatch cooldown" })

    local vehicleCare = { key = "vehicleCare", label = "Vehicle Care", icon = "Sparkles" }
    add(vehicleCare, "vehicleCareWashItem", { type = "string", label = "Wash item" })
    add(vehicleCare, "vehicleCareWashRemoveAfterUse", { type = "boolean", label = "Consume wash item" })
    add(vehicleCare, "vehicleCareWaxItem", { type = "string", label = "Wax item" })
    add(vehicleCare, "vehicleCareWaxRemoveAfterUse", { type = "boolean", label = "Consume wax item" })
    add(vehicleCare, "vehicleCareWaxCleanKilometers", { type = "number", min = 0, label = "Wax clean kilometers" })
    add(vehicleCare, "vehicleCareRepairItem", { type = "string", label = "Repair item" })
    add(vehicleCare, "vehicleCareRepairRemoveAfterUse", { type = "boolean", label = "Consume repair item" })
    add(vehicleCare, "vehicleCareRepairDurationMs", { type = "integer", min = 0, label = "Repair duration" })
    add(vehicleCare, "vehicleCareRepairMaxDistance", { type = "number", min = 0, label = "Repair max distance" })
    add(vehicleCare, "vehicleCareRepairVehicleDamage", { type = "boolean", label = "Fix vehicle damage" })
    add(vehicleCare, "vehicleCareRepairFixRealisticWheelDamage", { type = "boolean", label = "Fix realistic wheel damage" })
    add(vehicleCare, "vehicleCareRepairWearParts", {
        type = "table",
        label = "Repair kit restored parts",
        allowAdd = false,
        allowDelete = false,
        columns = {
            { key = "label", type = "string", readonly = true, label = "Label", labelKey = "workshopConfig.settingFields.label" },
            { key = "repair", type = "boolean", label = "Repair with kit", labelKey = "workshopConfig.settingFields.repair" }
        }
    })

    local wear = { key = "wear", label = "Wear", icon = "Activity" }
    add(wear, "wearParts", {
        type = "table",
        label = "Wear parts",
        allowAdd = false,
        allowDelete = false,
        columns = {
            { key = "label", type = "string", readonly = true, label = "Label", labelKey = "workshopConfig.settingFields.label" },
            { key = "kilometersToZero", type = "number", min = 0, label = "Kilometers to zero", labelKey = "workshopConfig.settingFields.kilometersToZero" },
            { key = "item", type = "string", label = "Item", labelKey = "workshopConfig.settingFields.item" },
            { key = "removeAfterUse", type = "boolean", default = true, label = "Consume item", labelKey = "workshopConfig.settingFields.removeAfterUse" },
            { key = "flow", type = "select", label = "Install flow", labelKey = "workshopConfig.settingFields.flow", options = selectOptions(WEAR_FLOWS, WEAR_FLOW_LABELS, "wearParts", "flow") }
        }
    })

    local wheelDamage = { key = "wheelDamage", label = "Wheel Damage", icon = "Gauge", featureKey = "wheelDamage" }
    add(wheelDamage, "wheelDamageDefaultMultiplier", { type = "number", min = 0, label = "Default multiplier" })
    add(wheelDamage, "wheelDamageOffroadWheelsMultiplier", { type = "number", min = 0, label = "Off-road wheel multiplier" })
    add(wheelDamage, "wheelDamageVehicleClassMultipliers", {
        type = "table",
        label = "Vehicle class multipliers",
        allowAdd = false,
        allowDelete = false,
        columns = {
            { key = "label", type = "string", readonly = true, label = "Label", labelKey = "workshopConfig.settingFields.label" },
            { key = "multiplier", type = "number", min = 0, step = 0.01, label = "Multiplier", labelKey = "workshopConfig.settingFields.multiplier" }
        }
    })

    local mileageHud = { key = "mileageHud", label = "Mileage HUD", icon = "Hash", featureKey = "mileageHud" }
    local mileagePosition = (Config.MileageHud or {}).position or {}
    add(mileageHud, "mileageHudDigits", { type = "integer", min = 4, label = "Digits" })
    add(mileageHud, "mileageHudPosition", {
        type = "screenPosition",
        label = "Position",
        digitKey = "mileageHudDigits",
        defaultPosition = plain(mileagePosition),
        positionKeys = {
            left = "mileageHudPositionLeft",
            right = "mileageHudPositionRight",
            top = "mileageHudPositionTop",
            bottom = "mileageHudPositionBottom"
        }
    })

    -- The NUI renders this section with its own instant tuning editor.
    local instantTuning = { key = "instantTuning", label = "Instant Tuning", icon = "Zap", featureKey = "instantTuning" }
    add(instantTuning, "instantTuningLabel", { type = "string", label = "Default label" })
    add(instantTuning, "instantTuningInteractionDistance", { type = "number", min = 0, label = "Interaction distance" })
    add(instantTuning, "instantTuningPriceMultiplier", { type = "number", min = 0, label = "Price multiplier" })
    add(instantTuning, "instantTuningForceMarkerInteraction", { type = "boolean", label = "Force marker interaction" })
    add(instantTuning, "instantTuningMechanicOnly", { type = "boolean", label = "Mechanic only" })
    add(instantTuning, "instantTuningAllowedJobs", { type = "stringList", label = "Allowed jobs" })
    add(instantTuning, "instantTuningMarkerEnabled", { type = "boolean", label = "Marker enabled" })
    add(instantTuning, "instantTuningMarkerType", { type = "integer", min = 0, label = "Marker type" })
    add(instantTuning, "instantTuningBlipEnabled", { type = "boolean", label = "Blip enabled" })
    add(instantTuning, "instantTuningBlipName", { type = "string", label = "Blip name" })
    add(instantTuning, "instantTuningBlipSprite", { type = "integer", min = 0, label = "Blip sprite" })
    add(instantTuning, "instantTuningBlipColor", { type = "integer", min = 0, label = "Blip color" })
    add(instantTuning, "instantTuningLocations", { type = "locationList", label = "Locations" })

    local carryItems = { key = "carryItems", label = "Carry Items", icon = "Package" }
    add(carryItems, "carryItems", {
        type = "table",
        editor = "carryItems",
        label = "Carry items",
        itemLabel = "Carry item",
        itemLabelKey = "workshopConfig.settings.carryItems.itemLabel",
        columns = {
            { key = "item", type = "select", label = "Item", labelKey = "workshopConfig.settingFields.item", options = { { value = "engine", label = "Engine" } } },
            { key = "transport", type = "select", default = "hand", label = "Transport", labelKey = "workshopConfig.settingFields.transport", options = (function()
                local options = {}
                for _, option in ipairs(CARRY_TRANSPORTS) do
                    options[#options + 1] = {
                        value = option.value,
                        label = option.label,
                        labelKey = ("workshopConfig.settings.carryItems.fields.transport.options.%s"):format(option.value)
                    }
                end
                return options
            end)() },
            { key = "prop", type = "string", label = "Prop", labelKey = "workshopConfig.settingFields.prop" },
            { key = "bone", type = "select", default = 28422, label = "Bone", labelKey = "workshopConfig.settingFields.bone", options = plain(CARRY_BONES) },
            { key = "x", type = "number", label = "X" }, { key = "y", type = "number", label = "Y" }, { key = "z", type = "number", label = "Z" },
            { key = "rx", type = "number", label = "Rot X" }, { key = "ry", type = "number", label = "Rot Y" }, { key = "rz", type = "number", label = "Rot Z" }
        }
    })

    -- Global settings shown on the Parts Delivery tab of a workshop.
    local function addDelivery(key, definition)
        definition.extension = "partsDeliveryShop"
        add(nil, key, definition)
    end
    local timerPosition = ((Config.PartsDelivery or {}).timerHud or {}).position or {}
    addDelivery("partsDeliveryTimeSeconds", { type = "number", min = 0, label = "Delivery time" })
    addDelivery("partsDeliveryOpenDurationMs", { type = "number", min = 0, label = "Open duration" })
    addDelivery("partsDeliveryOwnCard", { type = "boolean", label = "Own card payment" })
    addDelivery("partsDeliveryCompanyCard", { type = "boolean", label = "Company card payment" })
    addDelivery("partsDeliveryTimerHudEnabled", { type = "boolean", label = "Show delivery timer" })
    addDelivery("partsDeliveryTimerHudPosition", {
        type = "screenPosition",
        label = "Timer position",
        defaultPosition = plain(timerPosition),
        positionKeys = {
            left = "partsDeliveryTimerHudPositionLeft",
            right = "partsDeliveryTimerHudPositionRight",
            top = "partsDeliveryTimerHudPositionTop",
            bottom = "partsDeliveryTimerHudPositionBottom"
        }
    })

    return definitions
end

local function buildFeatureDefinitions()
    local features = Config.ToggleFeatures or {}
    local list = {
        { key = "instantTuning", label = "Instant Tuning", description = "Allow direct tuning at configured public tuning locations." },
        { key = "partsDelivery", label = "Parts Delivery", description = "Enable workshop parts delivery orders and delivery bays." },
        { key = "carryItems", label = "Physical Parts Handling", description = "Require delivered parts to be transported through the workshop." },
        { key = "nitro", label = "Nitro", description = "Enable nitro installation and vehicle boost use." },
        { key = "antiLag", label = "Anti-Lag", description = "Enable anti-lag installation and exhaust effects." },
        { key = "twoStep", label = "Two-Step", description = "Enable two-step launch control and exhaust effects." },
        { key = "wheelDamage", label = "Wheel Damage", description = "Enable realistic wheel damage and repairs." },
        { key = "customHandling", label = "Custom Handling", description = "Enable custom drivetrain and handling tuning." },
        { key = "mileageHud", label = "Mileage HUD", description = "Show vehicle mileage information while driving." },
        { key = "workshopLift", label = "Workshop Lift", description = "Enable usable lift points configured in workshops." }
    }

    local defaults = {}
    for _, feature in ipairs(list) do
        feature.labelKey = ("workshopConfig.features.%s.label"):format(feature.key)
        feature.descriptionKey = ("workshopConfig.features.%s.description"):format(feature.key)
        feature.default = features[feature.key] == true
        defaults[feature.key] = feature.default
    end
    return list, defaults
end

local function buildInteractionDefinitions()
    local interactions = Config.Interactions or {}
    local definitions = {}
    for _, id in ipairs(sortedKeys(interactions, INTERACTION_ORDER)) do
        if type(interactions[id]) == "table" then
            local definition = plain(interactions[id])
            definition.id = id
            definition.key = id
            definition.label = definition.label or INTERACTION_LABELS[id] or id
            definitions[#definitions + 1] = definition
        end
    end
    return definitions
end

local function buildExtensions()
    local baseJob = type(Config.Jobs) == "table" and type(Config.Jobs[1]) == "table" and Config.Jobs[1] or {}
    return {
        {
            key = "partsDeliveryShop",
            field = "partsDeliveryShop",
            type = "itemList",
            icon = "Truck",
            label = "Parts Delivery",
            labelKey = "workshopConfig.features.partsDelivery.label",
            itemLabel = "part",
            itemLabelKey = "workshopConfig.actions.addPart",
            fields = {
                { key = "name", type = "string", label = "Item name", labelKey = "workshopConfig.placeholders.itemName" },
                { key = "label", type = "string", label = "Label", labelKey = "workshopConfig.placeholders.label" },
                { key = "price", type = "number", min = 0, default = 0, label = "Price", labelKey = "workshopConfig.fields.price" },
                { key = "category", type = "string", default = "General", label = "Category", labelKey = "workshopConfig.fields.category" }
            },
            defaultValue = plain(baseJob.partsDeliveryShop or baseJob.shop or {})
        },
        {
            key = "tuningCostProfile",
            field = "tuningCostProfile",
            type = "jsonObject",
            editor = "tuningCostProfile",
            icon = "BadgePercent",
            label = "Tuning Prices",
            labelKey = "workshopConfig.extensions.tuningCostProfile.label",
            description = "Configure this job's performance, appearance, wheel, and special option costs. Costs support required item arrays and staged upgrade objects.",
            descriptionKey = "workshopConfig.extensions.tuningCostProfile.description",
            defaultValue = plain(baseJob.tuningCostProfile or {})
        }
    }
end

local function buildSchema()
    local featureDefinitions, defaultFeatures = buildFeatureDefinitions()
    return {
        title = "Mechanic Jobs",
        titleKey = "workshopConfig.configs.sky_mechanicjob.title",
        subtitle = "Configure mechanic jobs, shops, vehicles, and workshop locations.",
        subtitleKey = "workshopConfig.configs.sky_mechanicjob.subtitle",
        entityLabel = "Workshop",
        entityPluralLabel = "Workshops",
        featureDefinitions = featureDefinitions,
        defaultFeatures = defaultFeatures,
        settingDefinitions = buildSettingDefinitions(),
        defaultSettings = buildDefaultSettings(),
        interactionDefinitions = buildInteractionDefinitions(),
        extensions = buildExtensions()
    }
end

local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports

-- Built while Config still holds the config.lua values: server/pricing.lua applies the saved
-- settings over Config later, and those must not become the defaults.
local schemaBuilt, schema = pcall(buildSchema)
if not schemaBuilt then
    print(("[sky_mechanicjob][job_configurator] building the configurator schema failed: %s"):format(tostring(schema)))
    schema = nil
end

registerExport("GetJobConfiguratorSchema", function()
    return schema
end)
