if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/config_overrides.lua") end
-- =====================================================
--  sky_mechanicjob · source/config_overrides.lua
--  /jobconfig settings applied over config.lua
-- =====================================================

-- The settings saved in the shared /jobconfig UI (Parts Theft, Vehicle Care, Wear, Wheel
-- Damage, Mileage HUD, Instant Tuning, Carry Items, Parts Delivery and the global pricing
-- settings) replace the matching config.lua / adv_config.lua values. The clients apply them
-- on every sync (client/main.lua) and the server after reading them (server/pricing.lua), so
-- both sides check the same items, prices and locations.

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
                -- The configurator saves a toggle (true/false); older data used 1/0.
                local removeAfterUse = item.removeAfterUse ~= false and item.removeAfterUse ~= 0 and item.removeAfterUse ~= "0"
                Config.Wear.parts[key] = {
                    kilometersToZero = tonumber(item.kilometersToZero) or 0,
                    item = trimString(item.item),
                    removeAfterUse = removeAfterUse,
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
            local c = (type(loc.coords) == "table" or type(loc.coords) == "vector3") and loc.coords or loc
            local x = tonumber(c.x)
            local y = tonumber(c.y)
            local z = tonumber(c.z)

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

function ApplyJobConfiguratorSettings(data)
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

    -- Only when /jobconfig sends instant tuning settings; otherwise adv_config.lua stays.
    for key in pairs(data) do
        if type(key) == "string" and key:find("^instantTuning") then
            parseInstantTuningConfig(data)
            break
        end
    end

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
