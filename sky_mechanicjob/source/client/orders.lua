if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/orders.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/orders.lua
--  Deobfuscated by Claude
--  Original: 7214 lines → Cleaned
-- =====================================================

local function logDebug(msg)
    if Sky and Sky.IsDebugActive and Sky.IsDebugActive() and Sky.Debug then
        Sky.Debug("debug", msg)
    end
end

local function formatColorRgb(col)
    if type(col) ~= "table" then return "nil" end
    return ("(%s,%s,%s)"):format(tostring(col.r), tostring(col.g), tostring(col.b))
end

function loadVehiclePrice(vehicle)
    local modelHash = GetEntityModel(vehicle)
    local priceData = Sky.Cb.Trigger("sky_mechanicjob:tuning:getVehiclePrice", {
        model = GetDisplayNameFromVehicleModel(modelHash),
        modelHash = modelHash
    }) or {}

    local price = math.floor(tonumber(priceData.price) or 0)
    if price > 0 then
        TuningState.vehiclePrices[modelHash] = price
    end
    return price
end

local BIKE_CLASSES = { [8] = true, [13] = true }

local function isBikeClass(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print(("[sky_mechanicjob][tuning] bike class check failed: invalid vehicle (%s)"):format(tostring(vehicle)))
        return false
    end
    return BIKE_CLASSES[GetVehicleClass(vehicle)] == true
end

local function isFixedPriceType()
    local priceType = tostring(tuningCostProfile and tuningCostProfile.priceType or "percentage"):lower()
    return priceType == "fixed" or priceType == "price"
end

function getVehicleBasePrice(vehicle)
    if isFixedPriceType() then
        return 0
    end

    local modelHash = GetEntityModel(vehicle)
    local cachedPrice = TuningState.vehiclePrices[modelHash]
    if cachedPrice and cachedPrice > 0 then
        return cachedPrice
    end

    local loadedPrice = loadVehiclePrice(vehicle)
    if loadedPrice > 0 then
        return loadedPrice
    end

    return (tuningCostProfile and tuningCostProfile.fallbackVehicleValue) or 0
end

local function isFreeTuningVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print(("[sky_mechanicjob][tuning] free tuning check failed: invalid vehicle (%s)"):format(tostring(vehicle)))
        return false
    end

    local modelHash = GetEntityModel(vehicle)
    local freeList = (tuningCostProfile and tuningCostProfile.freeVehicles) or {}

    for _, entry in ipairs(freeList) do
        if type(entry) == "number" then
            if entry == modelHash then return true end
        else
            local name = tostring(entry or ""):match("^%s*(.-)%s*$") or ""
            if name ~= "" and GetHashKey(name) == modelHash then
                return true
            end
        end
    end
    return false
end

function isCurrentVehicleFreeTuningModel()
    if TuningState.vehicle ~= 0 and DoesEntityExist(TuningState.vehicle) then
        return isFreeTuningVehicle(TuningState.vehicle)
    end
    return false
end

local function toPriceFromPercentage(basePrice, percentage)
    if type(percentage) ~= "number" or percentage <= 0 then
        return 0
    end
    return math.floor((basePrice * percentage) / 100)
end

local function resolveCostByStageOrOption(basePrice, optionCost, value)
    local rawVal = optionCost
    if type(rawVal) == "table" then
        rawVal = rawVal.cost or rawVal.price
    end

    local costNum = tonumber(rawVal) or 0
    if costNum <= 0 then return 0 end

    if isFixedPriceType() then
        local fixedPrice = math.floor(costNum)
        if TuningState.instantMode then
            local multiplier = tonumber(Config and Config.InstantTuning and Config.InstantTuning.priceMultiplier) or 1.0
            fixedPrice = math.floor(fixedPrice * multiplier)
        end
        return fixedPrice
    end

    local pctPrice = toPriceFromPercentage(basePrice, costNum)
    if TuningState.instantMode then
        local multiplier = tonumber(Config and Config.InstantTuning and Config.InstantTuning.priceMultiplier) or 1.0
        pctPrice = math.floor(pctPrice * multiplier)
    end
    return pctPrice
end

local function resolveOptionCostValue(costData, valIndex)
    if type(costData) ~= "table" then return costData end

    local index = tonumber(valIndex)
    local valuesList = costData.values or costData.costs

    if type(valuesList) == "table" and index ~= nil then
        local idxInt = math.floor(index)
        local val = valuesList[idxInt] or valuesList[tostring(idxInt)] or valuesList[idxInt + 1] or costData
        return val
    end

    if type(costData.cost) == "table" and index ~= nil then
        local idxInt = math.floor(index)
        local val = costData.cost[idxInt] or costData.cost[tostring(idxInt)] or costData.cost[idxInt + 1] or costData
        return val
    end

    return costData
end

local function resolveOptionCost(basePrice, optionId, valIndex)
    local optionIdStr = tostring(optionId or "")
    local costCfg = (tuningCostProfile and tuningCostProfile.optionCostByOptionId and tuningCostProfile.optionCostByOptionId[optionIdStr]) or {}
    local costVal = resolveOptionCostValue(costCfg, valIndex)
    return resolveCostByStageOrOption(basePrice, costVal)
end

STANCER_BUNDLE_OPTION_ID = "stancer_bundle"

local function isInvalidTable(tbl)
    return type(tbl) ~= "table"
end

local function findPerformanceStage(modType)
    local targetType = tonumber(modType)
    if not targetType then return nil end

    for _, stage in pairs(tuningCostProfile and tuningCostProfile.performanceStages or {}) do
        if tonumber(stage.modType) == targetType then
            return stage
        end
    end
    return nil
end

local function getMaxStageIndex(stageCfg)
    if type(stageCfg) ~= "table" or type(stageCfg.cost) ~= "table" then return nil end

    local isZeroBased = stageCfg.cost[0] ~= nil
    local maxIdx = nil

    for k, v in pairs(stageCfg.cost) do
        local num = tonumber(k)
        if num and isInvalidTable(v) then
            local adjusted = isZeroBased and num or (num - 1)
            adjusted = math.floor(adjusted)
            if adjusted >= 0 and (maxIdx == nil or adjusted > maxIdx) then
                maxIdx = adjusted
            end
        end
    end
    return maxIdx
end

local function addValueIndex(targetList, seenMap, val)
    local valInt = math.floor(tonumber(val) or 0)
    if seenMap[valInt] then return end
    seenMap[valInt] = true
    table.insert(targetList, valInt)
end

local function calculateAllowedModValues(modType, currentVal, maxVal)
    local stageCfg = findPerformanceStage(modType)
    local maxStage = getMaxStageIndex(stageCfg)
    if not maxStage then return nil end

    local allowed = {}
    local seen = {}

    addValueIndex(allowed, seen, -1)
    local maxAllowed = math.min(math.floor(maxVal), maxStage)

    for i = 0, maxAllowed do
        addValueIndex(allowed, seen, i)
    end

    local currentInt = math.floor(tonumber(currentVal) or -1)
    if currentInt >= 0 and maxVal >= currentInt then
        addValueIndex(allowed, seen, currentInt)
    end

    table.sort(allowed)
    return allowed
end

local function findAppearanceMod(modType)
    local targetType = tonumber(modType)
    if not targetType then return nil end

    for _, mod in pairs(tuningCostProfile and tuningCostProfile.appearanceMods or {}) do
        if tonumber(mod.modType) == targetType then
            return mod
        end
    end
    return nil
end

local function hasCustomWheelTypeCosts()
    for _, cost in pairs(tuningCostProfile and tuningCostProfile.wheelTypeCost or {}) do
        if isInvalidTable(cost) then
            return true
        end
    end
    return false
end

local function isOptionEnabled(option)
    local optionId = tostring(option and option.id or "")
    if optionId == "" then return true end

    local costCfg = (tuningCostProfile and tuningCostProfile.optionCostByOptionId and tuningCostProfile.optionCostByOptionId[optionId]) or nil
    if type(costCfg) == "table" and costCfg.enabled == false then
        return false
    end

    if optionId == STANCER_BUNDLE_OPTION_ID or optionId:find("^stancer_") then
        local bundleCfg = (tuningCostProfile and tuningCostProfile.optionCostByOptionId and tuningCostProfile.optionCostByOptionId[STANCER_BUNDLE_OPTION_ID]) or nil
        if type(bundleCfg) == "table" and bundleCfg.enabled == false then
            return false
        end
    end

    if optionId == "wheel_type" and not hasCustomWheelTypeCosts() then
        return false
    end

    local modType = tonumber(option and option.modType)
    if modType then
        local stageCfg = findPerformanceStage(modType)
        if type(stageCfg) == "table" and stageCfg.enabled == false then
            return false
        end

        local appCfg = findAppearanceMod(modType)
        if type(appCfg) == "table" and appCfg.enabled == false then
            return false
        end
    end

    return true
end

function getWheelModPrice(basePrice, wheelTypeIndex)
    local wheelKey = (WHEEL_TYPE_KEY_BY_INDEX and WHEEL_TYPE_KEY_BY_INDEX[wheelTypeIndex]) or "sport"
    local wheelCosts = (tuningCostProfile and tuningCostProfile.wheelTypeCost) or {}
    local costVal = wheelCosts[wheelKey] or wheelCosts.sport
    return resolveCostByStageOrOption(basePrice, costVal)
end

function getOptionValuePrice(option, val, vehicle, basePrice)
    local valNum = tonumber(val)
    if not valNum then return 0 end

    if option.kind == "stancer" then
        return resolveOptionCost(basePrice, vehicle)
    end

    if option.kind == "mod" then
        if valNum < 0 then return 0 end

        if type(option.customHandlingExtension) == "table" then
            local baseMax = tonumber(option.customHandlingExtension.baseMax) or -1
            if valNum > baseMax then
                return resolveOptionCost(basePrice, option.customHandlingExtension.priceOptionId, valNum)
            end
        end

        if option.modType == 23 or option.modType == 24 then
            local wheelType = nil
            if TuningState.optionMap and TuningState.optionMap.wheel_type then
                wheelType = tonumber(TuningState.optionMap.wheel_type.value)
            end
            if wheelType == nil then
                wheelType = GetVehicleWheelType(vehicle)
            end
            return getWheelModPrice(basePrice, wheelType)
        end

        local stageCfg = stagedCostByModType and stagedCostByModType[option.modType]
        if type(stageCfg) == "table" then
            return resolveCostByStageOrOption(basePrice, stageCfg[valNum + 1])
        end

        return resolveCostByStageOrOption(basePrice, flatCostByModType and flatCostByModType[option.modType])
    end

    if option.kind == "toggle" then
        if valNum ~= 1 then return 0 end
        return resolveOptionCost(basePrice, option.id, valNum)
    end

    if option.id == "wheel_type" or valNum < 0 then
        return 0
    end

    return resolveOptionCost(basePrice, option.id, valNum)
end

function buildOptionPriceMap(option, vehicle, basePrice)
    local priceMap = {}
    local allowedValues = type(option.allowedValues) == "table" and option.allowedValues or nil

    local minVal = math.floor(tonumber(option.min) or 0)
    local maxVal = math.floor(tonumber(option.max) or 0)

    if TuningState.hidePricesForPublicSelfService or TuningState.adminMode or isCurrentVehicleFreeTuningModel(vehicle) then
        if allowedValues then
            for _, val in ipairs(allowedValues) do
                priceMap[tostring(val)] = 0
            end
            return priceMap
        end

        for i = minVal, maxVal do
            priceMap[tostring(i)] = 0
        end
        return priceMap
    end

    if option.kind == "stancer" then
        local price = resolveOptionCost(vehicle, basePrice)
        if allowedValues then
            for _, val in ipairs(allowedValues) do
                priceMap[tostring(val)] = price
            end
            return priceMap
        end

        for i = minVal, maxVal do
            priceMap[tostring(i)] = price
        end
        return priceMap
    end

    if allowedValues then
        for _, val in ipairs(allowedValues) do
            priceMap[tostring(val)] = getOptionValuePrice(option, val, vehicle, basePrice)
        end
        return priceMap
    end

    for i = minVal, maxVal do
        priceMap[tostring(i)] = getOptionValuePrice(option, i, vehicle, basePrice)
    end
    return priceMap
end

function cloneRgb(col)
    if type(col) ~= "table" then return nil end
    local r = tonumber(col.r)
    local g = tonumber(col.g)
    local b = tonumber(col.b)
    if not r or not g or not b then return nil end

    return {
        r = math.floor(math.max(0, math.min(255, r))),
        g = math.floor(math.max(0, math.min(255, g))),
        b = math.floor(math.max(0, math.min(255, b)))
    }
end

function colorsEqual(c1, c2)
    if c1 == nil and c2 == nil then return true end
    if c1 == nil or c2 == nil then return false end
    return tonumber(c1.r) == tonumber(c2.r) and tonumber(c1.g) == tonumber(c2.g) and tonumber(c1.b) == tonumber(c2.b)
end

function captureOptionBaselines()
    local baselines = {}
    for _, opt in ipairs(TuningState.options) do
        baselines[opt.id] = {
            value = opt.value,
            paintType = opt.paintType,
            customColor = cloneRgb(opt.customColor)
        }
    end
    TuningState.optionBaselines = baselines
end

function restoreVehicleToOptionBaselines()
    local veh = TuningState.vehicle
    if veh == 0 or not DoesEntityExist(veh) then
        print("[sky_mechanicjob][tuning] restoreVehicleToOptionBaselines failed: vehicle missing")
        return false
    end

    local prevSuppress = TuningState.suppressPreviews
    TuningState.suppressPreviews = true

    for _, opt in ipairs(TuningState.options) do
        local base = TuningState.optionBaselines[opt.id]
        if base then
            local valNum = tonumber(base.value)
            if valNum ~= nil then
                if opt.kind ~= "stancer" then
                    valNum = math.floor(valNum)
                end
                if valNum < opt.min then valNum = opt.min end
                if valNum > opt.max then valNum = opt.max end
                applyOption(opt, valNum)
            end

            if opt.supportsCustom == true then
                applyCustomColorOption(opt, base.paintType, cloneRgb(base.customColor))
            end
        end
    end

    TuningState.suppressPreviews = prevSuppress
    return true
end

function hasOptionChangedFromBaseline(option)
    local base = TuningState.optionBaselines[option.id]
    if not base then return false end

    if tonumber(option.value) ~= tonumber(base.value) then
        return true
    end

    if option.supportsCustom == true then
        if tonumber(option.paintType) ~= tonumber(base.paintType) then
            return true
        end
        if not colorsEqual(option.customColor, base.customColor) then
            return true
        end
    end

    return false
end

function getCurrentOptionPrice(option)
    if TuningState.hidePricesForPublicSelfService or TuningState.adminMode or isCurrentVehicleFreeTuningModel() then
        return 0
    end

    if option then
        if option.id == "xenon_color" and option.supportsCustom == true and option.customColor then
            if hasOptionChangedFromBaseline(option) and TuningState.vehicle ~= 0 and DoesEntityExist(TuningState.vehicle) then
                return resolveOptionCost(getVehicleBasePrice(TuningState.vehicle), "xenon_color")
            end
        end

        if option.kind == "mod" and (option.id == "mod_23" or option.id == "mod_24") then
            if TuningState.vehicle ~= 0 and DoesEntityExist(TuningState.vehicle) then
                return getOptionValuePrice(option, option.value, TuningState.vehicle, getVehicleBasePrice(TuningState.vehicle))
            end
        end
    end

    local prices = option.prices
    if type(prices) ~= "table" then return 0 end

    local price = tonumber(prices[tostring(option.value)]) or 0
    if price < 0 then return 0 end
    return math.floor(price)
end

function buildPendingBasket()
    local basketEntries = {}
    local totalPrice = 0

    local wheelTypeOpt = TuningState.optionMap and TuningState.optionMap.wheel_type
    local currentWheelType = wheelTypeOpt and tonumber(wheelTypeOpt.value)

    local stancerChanged = false
    local stancerMaxPrice = 0
    local stancerValues = {}

    local function getOptionValueLabel(opt)
        if opt.kind == "stancer" or opt.kind == "wheel_size" then
            local scale = tonumber(opt.scale) or STANCER_SCALE or 100
            local valNum = (tonumber(opt.value) or 0) / scale
            return ("%.2f"):format(valNum)
        end

        local customLabel = opt.labels and opt.labels[tostring(opt.value)]
        if type(customLabel) == "string" and customLabel ~= "" then
            return customLabel
        end

        return tostring(opt.value)
    end

    local function getOptionTitle(opt)
        local locKey = ("option.label.%s"):format(opt.id)
        local locVal = getNuiLocale(locKey, nil)
        if locVal then return locVal end
        return opt.label or opt.id
    end

    for _, opt in ipairs(TuningState.options) do
        if hasOptionChangedFromBaseline(opt) then
            local base = TuningState.optionBaselines[opt.id] or {}

            logDebug(("[sky_mechanicjob][tuning:basket][changed] id=%s kind=%s value=%s baseValue=%s paintType=%s basePaintType=%s custom=%s baseCustom=%s"):format(
                tostring(opt.id), tostring(opt.kind), tostring(opt.value), tostring(base.value),
                tostring(opt.paintType), tostring(base.paintType),
                formatColorRgb(opt.customColor), formatColorRgb(base.customColor)
            ))

            if opt.kind == "stancer" then
                stancerChanged = true
                stancerValues[opt.id] = opt.value

                local optPrice = getCurrentOptionPrice(opt)
                if optPrice > stancerMaxPrice then
                    stancerMaxPrice = optPrice
                end
            else
                local optPrice = getCurrentOptionPrice(opt)
                totalPrice = totalPrice + optPrice

                logDebug(("[sky_mechanicjob][tuning:basket][price] id=%s value=%s price=%s runningTotal=%s"):format(
                    tostring(opt.id), tostring(opt.value), tostring(optPrice), tostring(totalPrice)
                ))

                if opt.id ~= "wheel_type" then
                    local valLabel = getOptionValueLabel(opt)

                    if opt.supportsCustom == true and opt.customColor then
                        local col = opt.customColor
                        if opt.id == "color_primary" then
                            valLabel = ("%s(%d, %d, %d) - %s %d"):format(
                                getNuiLocale("basket.value.rgb_prefix", "RGB"),
                                math.floor(tonumber(col.r) or 0), math.floor(tonumber(col.g) or 0), math.floor(tonumber(col.b) or 0),
                                getNuiLocale("basket.value.paint_type_prefix", "Type"),
                                math.floor(tonumber(opt.paintType) or 0)
                            )
                        else
                            valLabel = ("%s(%d, %d, %d)"):format(
                                getNuiLocale("basket.value.rgb_prefix", "RGB"),
                                math.floor(tonumber(col.r) or 0), math.floor(tonumber(col.g) or 0), math.floor(tonumber(col.b) or 0)
                            )
                        end
                    end

                    local entry = {
                        id = opt.id,
                        value = opt.value,
                        price = optPrice,
                        label = getOptionTitle(opt),
                        valueLabel = valLabel
                    }

                    if opt.supportsCustom == true and opt.customColor then
                        entry.paintType = math.floor(tonumber(opt.paintType) or 0)
                        entry.customColor = cloneRgb(opt.customColor)
                    end

                    if (opt.id == "mod_23" or opt.id == "mod_24") and currentWheelType ~= nil then
                        entry.wheelType = math.floor(currentWheelType)
                    end

                    table.insert(basketEntries, entry)
                end
            end
        end
    end

    if stancerChanged then
        totalPrice = totalPrice + stancerMaxPrice
        table.insert(basketEntries, {
            id = STANCER_BUNDLE_OPTION_ID,
            value = stancerValues,
            price = stancerMaxPrice,
            label = getNuiLocale("section.stancer", "Stancer"),
            valueLabel = getNuiLocale("basket.value.stancer_bundle", "Custom stance setup")
        })
    end

    logDebug(("[sky_mechanicjob][tuning:basket][complete] entries=%s total=%s data=%s"):format(
        tostring(#basketEntries), tostring(totalPrice), tostring(json.encode(basketEntries) or "encode_failed")
    ))

    return basketEntries, totalPrice
end

function resolveCategoryByOptionId(optionId)
    local defaultCat = "bodywork"
    if type(optionId) ~= "string" or optionId == "" then
        return defaultCat
    end

    if CustomTuning and CustomTuning.GetCategoryByOptionId then
        local cat = CustomTuning.GetCategoryByOptionId(optionId)
        if cat then return cat end
    end

    local exactCat = OPTION_ID_CATEGORY_RULES and OPTION_ID_CATEGORY_RULES.exact and OPTION_ID_CATEGORY_RULES.exact[optionId]
    if exactCat then return exactCat end

    for _, rule in ipairs(OPTION_ID_CATEGORY_RULES and OPTION_ID_CATEGORY_RULES.prefixes or {}) do
        if optionId:match(rule.pattern) then
            return rule.category
        end
    end

    local modType = tonumber(optionId:match("^mod_(%-?%d+)$"))
    if modType then
        return (OPTION_ID_CATEGORY_RULES and OPTION_ID_CATEGORY_RULES.modTypes and OPTION_ID_CATEGORY_RULES.modTypes[modType]) or defaultCat
    end

    return defaultCat
end

function requiredItemByOptionId(optionId)
    local costCfg = (tuningCostProfile and tuningCostProfile.optionCostByOptionId and tuningCostProfile.optionCostByOptionId[tostring(optionId or "")]) or nil
    local items = (type(costCfg) == "table") and costCfg.items or nil

    if type(items) == "table" and type(items[1]) == "string" then
        return items[1]
    end
    return ""
end

local isCleaningPropsBusy = false

function ensureNetworkControl(entity, timeoutMs)
    if entity == 0 or not DoesEntityExist(entity) or not NetworkGetEntityIsNetworked(entity) or NetworkHasControlOfEntity(entity) then
        return true
    end

    local maxTime = GetGameTimer() + (tonumber(timeoutMs) or 1500)
    NetworkRequestControlOfEntity(entity)

    while DoesEntityExist(entity) and not NetworkHasControlOfEntity(entity) and GetGameTimer() < maxTime do
        Wait(0)
        NetworkRequestControlOfEntity(entity)
    end

    return DoesEntityExist(entity) and NetworkHasControlOfEntity(entity)
end

function deletePropEntity(entity)
    if entity == 0 or not DoesEntityExist(entity) then return true end

    ensureNetworkControl(entity, 1500)
    if DoesEntityExist(entity) then
        DetachEntity(entity, true, true)
        SetEntityAsMissionEntity(entity, true, true)
        DeleteObject(entity)
        DeleteEntity(entity)
    end

    for _ = 1, 12 do
        if not DoesEntityExist(entity) then return true end
        Wait(0)
        ensureNetworkControl(entity, 250)
        DetachEntity(entity, true, true)
        SetEntityAsMissionEntity(entity, true, true)
        DeleteObject(entity)
        DeleteEntity(entity)
    end

    return not DoesEntityExist(entity)
end

function releaseOrderHeldProp()
    if OrderInstallState.heldProp ~= 0 and DoesEntityExist(OrderInstallState.heldProp) then
        if not deletePropEntity(OrderInstallState.heldProp) then
            return false
        end
    end
    OrderInstallState.heldProp = 0
    OrderInstallState.heldCarryTransportVehicle = 0
    return true
end

function clearOrderHeldPropFull()
    stopRepaintPointing()
    clearEngineHoistState()
    releaseOrderHeldProp()
    OrderInstallState.heldCarryItem = nil
    OrderInstallState.heldCarryTransportMode = "hand"
    ClearPedTasks(PlayerPedId())
end

function getCarryItemConfig(itemName)
    local items = (Config and Config.CarryItems and Config.CarryItems.items) or {}
    local cfg = items[tostring(itemName or "")]
    if Config and Config.ToggleFeatures and Config.ToggleFeatures.carryItems == true and type(cfg) == "table" and cfg.enabled ~= false then
        return cfg
    end
    return nil
end

function getCarryItemTransportMode(itemName)
    local cfg = getCarryItemConfig(itemName)
    local transportMode = tostring(cfg and cfg.transport or "hand"):lower()

    if transportMode == "forklift" or transportMode == "engine_lift" then
        return transportMode
    end
    return "hand"
end

function isForkliftModel(vehicle, itemName)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    local cfg = getCarryItemConfig(itemName) or {}
    local models = cfg.forkliftModels or (Config and Config.CarryItems and Config.CarryItems.forkliftModels) or { "forklift" }
    local vehModel = GetEntityModel(vehicle)

    for _, modelName in ipairs(models) do
        if GetHashKey(tostring(modelName or "")) == vehModel then
            return true
        end
    end
    return false
end

function playBoxCarryAnim(ped)
    local animDict = "anim@heists@box_carry@"
    if not requestAnimDictLoaded(animDict, 2500) then
        return false
    end

    TaskPlayAnim(ped, animDict, "idle", 4.0, -4.0, -1, 49, 0.0, false, false, false)
    RemoveAnimDict(animDict)
    return true
end

function attachForkliftCarryProp(vehicle, itemName, itemConfig)
    if OrderInstallState.heldProp ~= 0 and DoesEntityExist(OrderInstallState.heldProp) then
        if OrderInstallState.heldCarryTransportVehicle == vehicle then
            return true
        end
    end

    releaseOrderHeldProp()

    local propModelName = tostring(itemConfig.prop or ORDER_ITEM_PROPS[tostring(itemName or "")] or "prop_cs_cardbox_01")
    local modelHash = GetHashKey(propModelName)

    if not requestModelLoaded(modelHash, 2500) then
        return false
    end

    local coords = GetEntityCoords(vehicle)
    local propObj = CreateObjectNoOffset(modelHash, coords.x, coords.y, coords.z, true, true, false)

    if propObj == 0 or not DoesEntityExist(propObj) then
        print(("[sky_mechanicjob][carry_item] failed: could not create forklift carry prop '%s'"):format(propModelName))
        SetModelAsNoLongerNeeded(modelHash)
        return false
    end

    local attachCfg = (type(itemConfig.forkliftAttach) == "table") and itemConfig.forkliftAttach or {}
    AttachEntityToEntity(
        propObj, vehicle,
        tonumber(attachCfg.bone) or 0,
        tonumber(attachCfg.x) or 0.0,
        tonumber(attachCfg.y) or 1.55,
        tonumber(attachCfg.z) or -0.18,
        tonumber(attachCfg.rx) or 0.0,
        tonumber(attachCfg.ry) or 0.0,
        tonumber(attachCfg.rz) or 0.0,
        false, false, false, false, 2, true
    )

    SetModelAsNoLongerNeeded(modelHash)
    OrderInstallState.heldProp = propObj
    OrderInstallState.heldCarryTransportVehicle = vehicle
    return true
end

function runForkliftAttachLoop()
    if isCleaningPropsBusy then return end
    isCleaningPropsBusy = true

    CreateThread(function()
        while OrderInstallState.heldCarryItem and OrderInstallState.heldCarryTransportMode == "forklift" do
            local itemName = tostring(OrderInstallState.heldCarryItem.name or "")
            local itemCfg = getCarryItemConfig(itemName)
            local ped = PlayerPedId()

            local currentVeh = GetVehiclePedIsIn(ped, false)
            if currentVeh ~= 0 and GetPedInVehicleSeat(currentVeh, -1) == ped then
                if isForkliftModel(currentVeh, itemName) then
                    attachForkliftCarryProp(currentVeh, itemName, itemCfg or {})
                end
            else
                if OrderInstallState.heldProp ~= 0 and DoesEntityExist(OrderInstallState.heldProp) then
                    releaseOrderHeldProp()
                end
            end

            Wait(300)
        end
        isCleaningPropsBusy = false
    end)
end

function isCarryItemTransportNearCoords(itemName, searchCoords)
    local transportMode = getCarryItemTransportMode(itemName)

    if transportMode == "hand" then
        return OrderInstallState.heldProp ~= 0 and DoesEntityExist(OrderInstallState.heldProp)
    end
    if transportMode == "engine_lift" then
        return true
    end

    local veh = OrderInstallState.heldCarryTransportVehicle
    if veh == 0 or not DoesEntityExist(veh) then return false end

    local maxDist = tonumber(getCarryItemConfig(itemName) and getCarryItemConfig(itemName).forkliftDistance) or 6.0
    return #(GetEntityCoords(veh) - searchCoords) <= maxDist
end

function holdCarryItemProp(itemName, metadata)
    local itemCfg = getCarryItemConfig(itemName)
    if not itemCfg then return false end

    releaseOrderHeldProp()

    local transportMode = getCarryItemTransportMode(itemName)
    OrderInstallState.heldCarryItem = { name = tostring(itemName or ""), metadata = metadata }
    OrderInstallState.heldCarryTransportMode = transportMode

    if transportMode == "forklift" then
        runForkliftAttachLoop()
        return true
    end
    if transportMode == "engine_lift" then
        return true
    end

    local propModelName = tostring(itemCfg.prop or ORDER_ITEM_PROPS[tostring(itemName or "")] or "prop_cs_cardbox_01")
    local modelHash = GetHashKey(propModelName)

    if not requestModelLoaded(modelHash, 2500) then
        return false
    end

    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)

    local propObj = CreateObjectNoOffset(modelHash, pedCoords.x, pedCoords.y, pedCoords.z, true, true, false)
    if propObj == 0 or not DoesEntityExist(propObj) then
        print(("[sky_mechanicjob][carry_item] failed: could not create carry prop '%s'"):format(propModelName))
        SetModelAsNoLongerNeeded(modelHash)
        return false
    end

    local attachCfg = (type(itemCfg.attach) == "table") and itemCfg.attach or {}
    AttachEntityToEntity(
        propObj, ped,
        GetPedBoneIndex(ped, tonumber(attachCfg.bone) or 28422),
        tonumber(attachCfg.x) or 0.0,
        tonumber(attachCfg.y) or -0.12,
        tonumber(attachCfg.z) or -0.12,
        tonumber(attachCfg.rx) or 0.0,
        tonumber(attachCfg.ry) or 0.0,
        tonumber(attachCfg.rz) or 0.0,
        true, true, false, true, 1, true
    )

    SetModelAsNoLongerNeeded(modelHash)
    playBoxCarryAnim(ped)

    OrderInstallState.heldProp = propObj
    return true
end

function holdOrderRequiredItem(itemName)
    local itemCfg = getCarryItemConfig(itemName)
    if itemCfg then
        return holdCarryItemProp(itemName)
    end
    releaseOrderHeldProp()
    return true
end

function clearOrderInstallState()
    releaseOrderHeldProp()
    stopNonMinigameInstallProgress()

    if RepaintMinigameState.active then
        RepaintMinigameState.active = false
        RepaintMinigameState.resolved = true
        RepaintMinigameState.success = false
        RepaintMinigameState.cancelled = true
        closeRepaintMinigameUi()
    end

    if EngineSwapMinigameState.active then
        EngineSwapMinigameState.active = false
        EngineSwapMinigameState.resolved = true
        EngineSwapMinigameState.success = false
        EngineSwapMinigameState.cancelled = true
        closeEngineSwapMinigameUi()
    end

    if OilDrainMinigameState.active then
        OilDrainMinigameState.active = false
        OilDrainMinigameState.resolved = true
        OilDrainMinigameState.success = false
        OilDrainMinigameState.cancelled = true
        closeOilDrainMinigameUi()
    end

    if OilPourMinigameState.active then
        OilPourMinigameState.active = false
        OilPourMinigameState.resolved = true
        OilPourMinigameState.success = false
        OilPourMinigameState.cancelled = true
        closeOilPourMinigameUi()
    end

    clearWheelInstallState(true)
    clearRepaintInstallState()

    if clearCatalyticState and CatalyticInstallState and CatalyticInstallState.active then
        clearCatalyticState(true)
    end

    if OrderInstallState.simpleChecklistVisible then
        sendUi("wheelInstall:checklist:close", {})
    end

    OrderInstallState.active = false
    OrderInstallState.finalizing = false
    OrderInstallState.orderId = 0
    OrderInstallState.partIndex = 0
    OrderInstallState.part = nil
    OrderInstallState.requiredItem = DEFAULT_PART_ITEM
    OrderInstallState.removeRequiredItemAfterUse = false
    OrderInstallState.installFlow = ""
    OrderInstallState.repairMode = false
    OrderInstallState.directStanceInstall = false
    OrderInstallState.repairPart = ""
    OrderInstallState.repairPlate = ""
    OrderInstallState.tuningRemovalMode = false
    OrderInstallState.tuningRemovalPlate = ""
    OrderInstallState.tuningRemovalValue = nil
    OrderInstallState.tuningRemovalWheelType = nil
    OrderInstallState.tuningRemovalValueLabel = ""
    OrderInstallState.tuningRemovalSection = ""
    OrderInstallState.vehicleNetId = 0
    OrderInstallState.vehicle = 0
    OrderInstallState.heldCarryItem = nil
    OrderInstallState.heldCarryTransportVehicle = 0
    OrderInstallState.heldCarryTransportMode = "hand"
    OrderInstallState.simpleChecklistVisible = false
    OrderInstallState.simpleChecklistSignature = ""
    OrderInstallState.simpleStep = "idle"
    OrderInstallState.stanceCompletedWheels = {}
end

function notify(msg, ntype)
    if type(msg) ~= "string" or msg == "" then return end
    local title = tuningLocales and tuningLocales.Title or "Tuning"
    Sky.Show.Notification(title, msg, ntype or "info")
end

local function getMechanicPropHashes()
    local propMap = {}
    local function registerHash(propName)
        if type(propName) == "string" and propName ~= "" then
            propMap[GetHashKey(propName)] = true
        end
    end

    for _, propName in pairs(ORDER_ITEM_PROPS or {}) do
        registerHash(propName)
    end

    for _, item in pairs(Config and Config.CarryItems and Config.CarryItems.items or {}) do
        if type(item) == "table" then
            registerHash(item.prop)
        end
    end

    registerHash(REPAINT_SANDING_PROP_MODEL)
    registerHash(REPAINT_SPRAY_PROP_MODEL)
    registerHash(REPAINT_SPRAY_PROP_MODEL_FALLBACK)
    registerHash("prop_sponge_01")
    registerHash("prop_blox_spray")

    return propMap
end

function cleanMechanicPropsNearPlayer()
    local ped = PlayerPedId()
    local vehIn = GetVehiclePedIsIn(ped, false)
    local propHashes = getMechanicPropHashes()

    local targets = {}
    local seen = {}

    local function addTarget(entity)
        if entity ~= 0 and DoesEntityExist(entity) and not seen[entity] then
            seen[entity] = true
            table.insert(targets, entity)
        end
    end

    addTarget(OrderInstallState.heldProp)

    for _, obj in ipairs(GetGamePool("CObject") or {}) do
        if DoesEntityExist(obj) and propHashes[GetEntityModel(obj)] then
            if not IsEntityAttachedToEntity(obj, ped) then
                if vehIn == 0 or not DoesEntityExist(vehIn) or not IsEntityAttachedToEntity(obj, vehIn) then
                    addTarget(obj)
                end
            end
        end
    end

    local deletedCount = 0
    local failedCount = 0

    for _, entity in ipairs(targets) do
        if deletePropEntity(entity) then
            deletedCount = deletedCount + 1
        else
            failedCount = failedCount + 1
        end
    end

    if OrderInstallState.heldProp ~= 0 and not DoesEntityExist(OrderInstallState.heldProp) then
        OrderInstallState.heldProp = 0
    end

    OrderInstallState.heldCarryTransportVehicle = 0
    OrderInstallState.heldCarryTransportMode = "hand"

    if OrderInstallState.heldCarryItem ~= nil then
        Sky.Cb.Trigger("sky_mechanicjob:carryItem:drop", {})
        OrderInstallState.heldCarryItem = nil
    end

    stopRepaintPointing()
    ClearPedTasks(PlayerPedId())

    return deletedCount, failedCount
end

RegisterCommand("mechanicprop", function()
    local deleted, failed = cleanMechanicPropsNearPlayer()
    if failed > 0 then
        notify(("Prop cleanup removed %d prop(s), %d failed. Try again or move closer."):format(deleted, failed), "error")
        return
    end
    if deleted > 0 then
        notify(("Removed %d mechanic prop(s)."):format(deleted), "success")
        return
    end
    notify("No mechanic prop found on you.", "info")
end)

function isWheelOrderPart(option, item)
    local itemStr = tostring(item or (option and option.requiredItem) or "")
    if itemStr == "wheels" then return true end

    local optionId = tostring(option and option.id or "")
    if optionId == "mod_23" or optionId == "mod_24" then return true end

    return requiredItemByOptionId(optionId) == "wheels"
end

function isBrakeWheelWorkflowPart(option, item)
    local itemStr = tostring(item or (option and option.requiredItem) or "")
    if itemStr == "brakes" then return true end

    local optionId = tostring(option and option.id or "")
    if optionId == "mod_12" then return true end

    return resolveCategoryByOptionId(optionId) == "brakes"
end

function isSuspensionWheelWorkflowPart(option, item)
    local itemStr = tostring(item or (option and option.requiredItem) or "")
    if itemStr == "suspension" then return true end

    local optionId = tostring(option and option.id or "")
    if optionId == "mod_15" then return true end

    return resolveCategoryByOptionId(optionId) == "suspension"
end

function isArmorOrderPart(option)
    local optionId = tostring(option and option.id or "")
    return optionId == "mod_16"
end

function isStanceOrderPart(option)
    local optionId = tostring(option and option.id or "")
    return optionId == STANCER_BUNDLE_OPTION_ID
end

function isSimpleHoodInstallOrderPart(option, item)
    local itemStr = tostring(item or (option and option.requiredItem) or "")
    if itemStr == "engine" then return false end

    local optionId = tostring(option and option.id or "")
    local cat = resolveCategoryByOptionId(optionId)

    return cat == "brakes" or cat == "transmission" or cat == "suspension" or cat == "turbo" or cat == "custom_tuning"
end

function isUnderbodyNeonOrderPart(option)
    local optionId = tostring(option and option.id or "")
    return optionId == "neon_0" or optionId == "neon_1" or optionId == "neon_2" or optionId == "neon_3" or optionId == "neon_color"
end

function getUnderbodyInstallCopy(option)
    local optionId = tostring(option and option.id or "")
    local repairPart = tostring(OrderInstallState and OrderInstallState.repairPart or "")

    if repairPart == "traction_battery" then
        return {
            icon = "Wrench",
            label = getNuiLocale("tablet.orders.simple_checklist.install_traction_battery_label", "Install Traction Battery"),
            description = getNuiLocale("tablet.orders.simple_checklist.install_traction_battery_description", "Stand below the lifted vehicle and install the traction battery."),
            checklist = getNuiLocale("tablet.orders.simple_checklist.install_traction_battery", "Stand below the lifted vehicle and install the traction battery"),
            leaveVehicle = getNuiLocale("tablet.orders.simple_checklist.traction_battery_leave_vehicle", "Leave the vehicle before installing the traction battery."),
            needBelowVehicle = getNuiLocale("tablet.orders.simple_checklist.traction_battery_need_below_vehicle", "Stand below the lifted vehicle before installing the traction battery."),
            liftReady = getNuiLocale("tablet.orders.simple_checklist.traction_battery_lift_ready", "Vehicle is raised. Stand below it and install the traction battery."),
            liftVehicleFirst = getNuiLocale("tablet.orders.simple_checklist.traction_battery_lift_first", "Raise the vehicle with the workshop lift first.")
        }
    end

    if optionId == "handling_drivetrain" then
        return {
            icon = "Wrench",
            label = tuningLocales and tuningLocales.DrivetrainInstallRadialLabel or "Install Drivetrain",
            description = tuningLocales and tuningLocales.DrivetrainInstallRadialDescription or "Stand below the lifted vehicle and install the drivetrain.",
            checklist = tuningLocales and tuningLocales.DrivetrainInstallChecklist or "Stand below the lifted vehicle and install the drivetrain",
            leaveVehicle = tuningLocales and tuningLocales.DrivetrainLeaveVehicle or "Leave the vehicle before installing the drivetrain.",
            needBelowVehicle = tuningLocales and tuningLocales.DrivetrainNeedBelowVehicle or "Stand below the lifted vehicle before installing the drivetrain.",
            liftReady = tuningLocales and tuningLocales.DrivetrainLiftReady or "Vehicle is raised. Stand below it and install the drivetrain."
        }
    end

    if optionId == "mod_15" then
        return {
            icon = "Wrench",
            label = tuningLocales and tuningLocales.SuspensionInstallRadialLabel or "Install Suspension",
            description = tuningLocales and tuningLocales.SuspensionInstallRadialDescription or "Stand below the lifted vehicle and install the suspension.",
            checklist = tuningLocales and tuningLocales.SuspensionInstallChecklist or "Stand below the lifted vehicle and install the suspension",
            leaveVehicle = tuningLocales and tuningLocales.SuspensionLeaveVehicle or "Leave the vehicle before installing the suspension.",
            needBelowVehicle = tuningLocales and tuningLocales.SuspensionNeedBelowVehicle or "Stand below the lifted vehicle before installing the suspension.",
            liftReady = tuningLocales and tuningLocales.SuspensionLiftReady or "Vehicle is raised. Stand below it and install the suspension."
        }
    end

    return {
        icon = "Lamp",
        label = tuningLocales and tuningLocales.UnderbodyNeonInstallRadialLabel or "Install Neon Kit",
        description = tuningLocales and tuningLocales.UnderbodyNeonInstallRadialDescription or "Stand below the lifted vehicle and install the neon kit.",
        checklist = getNuiLocale("tablet.orders.simple_checklist.install_underbody_neon", "Stand below the lifted vehicle and install the neon kit"),
        leaveVehicle = tuningLocales and tuningLocales.UnderbodyNeonLeaveVehicle or "Leave the vehicle before installing the neon kit.",
        needBelowVehicle = tuningLocales and tuningLocales.UnderbodyNeonNeedBelowVehicle or "Stand below the lifted vehicle before installing the neon kit.",
        liftReady = tuningLocales and tuningLocales.UnderbodyNeonLiftReady or "Vehicle is raised. Stand below it and install the neon kit.",
        liftVehicleFirst = tuningLocales and tuningLocales.UnderbodyNeonLiftVehicleFirst or "Raise the vehicle with the workshop lift first."
    }
end

WHEEL_INSTALL_STEPS = {
    lift = "car_jack",
    detach = "detach_wheel",
    install_brakes = "install_brakes",
    install_suspension = "install_suspension",
    attach = "attach_wheel",
    remove = "remove_car_jack"
}
ARMOR_INSTALL_STEPS = { cut = "cut_armor_panel", weld = "weld_armor_panel" }
ENGINE_SWAP_STEPS = { open_hood = "open_hood", take_hoist = "take_engine_hoist", attach_hoist = "attach_engine_hoist", engine_swap = "engine_swap" }
HOOD_INSTALL_STEPS = { open_hood = "open_hood", install = "install_order_part" }
OIL_CHANGE_STEPS = { drain_oil = "drain_old_oil", open_hood = "open_hood", pour_oil = "pour_new_oil" }
UNDERBODY_NEON_STEPS = { install_neon = "install_underbody_neon" }
STANCE_STEPS = { stance_wheels = "install_stance_wheel" }
FLUID_REFILL_STEPS = { open_hood = "open_hood", pour_oil = "pour_new_oil" }
REPAINT_STEPS = { sanding = "sand_vehicle", painting = "paint_vehicle" }

function resolveSimpleInstallFlow()
    local flowStr = tostring(OrderInstallState and OrderInstallState.installFlow or "")

    if flowStr == "basic" or flowStr == "engine_swap" or flowStr == "hood_install" or flowStr == "oil_change" or flowStr == "underbody_neon" or flowStr == "fluid_refill" or flowStr == "stance" then
        return flowStr
    end

    if isArmorOrderPart(OrderInstallState.part, OrderInstallState.requiredItem) then
        return "armor"
    end

    local optionId = tostring(OrderInstallState.part and OrderInstallState.part.id or "")
    local customFlow = CustomTuning and CustomTuning.GetInstallFlowByOptionId and CustomTuning.GetInstallFlowByOptionId(optionId)

    if customFlow == "engine_swap" or customFlow == "hood_install" or customFlow == "oil_change" or customFlow == "underbody_neon" or customFlow == "fluid_refill" then
        return customFlow
    end

    local reqItem = tostring(OrderInstallState.requiredItem or "")
    if reqItem == "engine" or resolveCategoryByOptionId(optionId) == "engine" then
        return "engine_swap"
    end

    if isUnderbodyNeonOrderPart(OrderInstallState.part) then
        return "underbody_neon"
    end

    if isStanceOrderPart(OrderInstallState.part) then
        return "stance"
    end

    if resolveCategoryByOptionId(optionId) == "suspension" then
        return "underbody_neon"
    end

    if isSimpleHoodInstallOrderPart(OrderInstallState.part, OrderInstallState.requiredItem) then
        return "hood_install"
    end

    return "basic"
end

function doesActiveEngineInstallUseHoist()
    return getCarryItemTransportMode(OrderInstallState.requiredItem) == "engine_lift"
end

function nextWheelInstallActionId()
    if not WheelOrderInstallState.active then return nil end

    local step = tostring(WheelOrderInstallState.step or "idle")
    if step == "detach" and WheelOrderInstallState.skipDetach then
        step = "attach"
    end
    if step == "install_brakes" and not WheelOrderInstallState.requiresBrakeInstall then
        step = "attach"
    end
    if step == "install_suspension" and not WheelOrderInstallState.requiresSuspensionInstall then
        step = "attach"
    end

    return WHEEL_INSTALL_STEPS[step]
end

function nextSimpleInstallActionId()
    if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
        return nil
    end

    local flow = resolveSimpleInstallFlow()
    local step = OrderInstallState.simpleStep

    if flow == "armor" then return ARMOR_INSTALL_STEPS[step] end
    if flow == "engine_swap" then return ENGINE_SWAP_STEPS[step] end
    if flow == "hood_install" then return HOOD_INSTALL_STEPS[step] end
    if flow == "oil_change" then return OIL_CHANGE_STEPS[step] end
    if flow == "underbody_neon" then return UNDERBODY_NEON_STEPS[step] end
    if flow == "stance" then return STANCE_STEPS[step] end
    if flow == "fluid_refill" then return FLUID_REFILL_STEPS[step] end

    return "install_order_part"
end

local function getVehicleFromOrderNetId()
    local veh = NetworkGetEntityFromNetworkId(OrderInstallState and OrderInstallState.vehicleNetId or 0)
    if veh ~= 0 and DoesEntityExist(veh) then
        return veh
    end
    return 0
end

local function doesVehicleHaveHood()
    local veh = getVehicleFromOrderNetId()
    if veh == 0 then return true end
    return HasVehicleHood(veh)
end

STANCE_WHEELS = {
    { id = "front_left", bones = { "wheel_lf", "wheel_lf_dummy" } },
    { id = "front_right", bones = { "wheel_rf", "wheel_rf_dummy" } },
    { id = "rear_left", bones = { "wheel_lr", "wheel_lr_dummy", "wheel_r", "wheel_r_dummy" } },
    { id = "rear_right", bones = { "wheel_rr", "wheel_rr_dummy" } }
}

local function getWheelBonePosition(vehicle, wheelConfig)
    for _, boneName in ipairs(wheelConfig.bones) do
        local boneIdx = GetEntityBoneIndexByName(vehicle, boneName)
        if boneIdx ~= -1 then
            return GetWorldPositionOfEntityBone(vehicle, boneIdx)
        end
    end
    return nil
end

function getClosestPendingStanceWheel(vehicle, pedCoords, maxDistance)
    local completed = OrderInstallState.stanceCompletedWheels or {}
    local bestWheel = nil
    local bestDist = tonumber(maxDistance) or CAR_JACK_MAX_BONE_DISTANCE

    for _, wheel in ipairs(STANCE_WHEELS) do
        if not completed[wheel.id] then
            local pos = getWheelBonePosition(vehicle, wheel)
            if pos then
                local dist = #(pedCoords - pos)
                if dist < bestDist then
                    bestDist = dist
                    bestWheel = wheel
                end
            end
        end
    end

    return bestWheel, bestDist
end

function areAllStanceWheelsCompleted()
    local completed = OrderInstallState.stanceCompletedWheels or {}
    for _, wheel in ipairs(STANCE_WHEELS) do
        if not completed[wheel.id] then
            return false
        end
    end
    return true
end

function sendWheelChecklistUpdate()
    if not WheelOrderInstallState.active then return end

    local currentStep = WheelOrderInstallState.step
    local steps = {
        { id = "lift", label = getNuiLocale("tablet.orders.wheel_checklist.lift", "Lift up the car with car jack"), done = currentStep ~= "lift" },
        { id = "detach", label = getNuiLocale("tablet.orders.wheel_checklist.detach", "Detach one wheel"), done = WheelOrderInstallState.skipDetach == true or currentStep == "install_brakes" or currentStep == "install_suspension" or currentStep == "attach" or currentStep == "remove" or currentStep == "complete" }
    }

    if WheelOrderInstallState.requiresBrakeInstall then
        table.insert(steps, {
            id = "install_brakes",
            label = getNuiLocale("tablet.orders.wheel_checklist.install_brakes", "Install brake components"),
            done = currentStep == "attach" or currentStep == "remove" or currentStep == "complete"
        })
    end

    if WheelOrderInstallState.requiresSuspensionInstall then
        table.insert(steps, {
            id = "install_suspension",
            label = getNuiLocale("tablet.orders.wheel_checklist.install_suspension", "Install suspension components"),
            done = currentStep == "attach" or currentStep == "remove" or currentStep == "complete"
        })
    end

    table.insert(steps, {
        id = "attach",
        label = getNuiLocale("tablet.orders.wheel_checklist.attach", "Attach the new wheel"),
        done = currentStep == "remove" or currentStep == "complete"
    })

    table.insert(steps, {
        id = "remove",
        label = getNuiLocale("tablet.orders.wheel_checklist.remove", "Remove the car jack"),
        done = currentStep == "complete"
    })

    sendUi("wheelInstall:checklist:update", {
        title = getNuiLocale("tablet.orders.wheel_checklist.title", "Wheel Change Checklist"),
        note = getNuiLocale("tablet.orders.wheel_checklist.note", "Only the required next action is available in radial menu."),
        steps = steps
    })

    WheelOrderInstallState.checklistVisible = true
end

function startWheelInstallState(requiresBrakes, requiresSuspension, extraData)
    local extra = (type(extraData) == "table") and extraData or {}

    WheelOrderInstallState.active = true
    WheelOrderInstallState.step = "lift"
    WheelOrderInstallState.detachedWheelIndexes = extra.detachedWheelIndexes
    WheelOrderInstallState.skipDetach = extra.skipDetach == true
    WheelOrderInstallState.requiresBrakeInstall = requiresBrakes == true
    WheelOrderInstallState.requiresSuspensionInstall = requiresSuspension == true

    sendWheelChecklistUpdate()
end

function clearWheelInstallState(resetCarJack)
    if WheelOrderInstallState.checklistVisible then
        sendUi("wheelInstall:checklist:close", {})
    end

    WheelOrderInstallState.active = false
    WheelOrderInstallState.step = "idle"
    WheelOrderInstallState.detachedWheelIndexes = nil
    WheelOrderInstallState.skipDetach = false
    WheelOrderInstallState.requiresBrakeInstall = false
    WheelOrderInstallState.requiresSuspensionInstall = false
    WheelOrderInstallState.checklistVisible = false

    if resetCarJack and CarJackState.lifted then
        clearCarJackState(true)
    end
end

function nextRepaintInstallActionId()
    if not RepaintOrderInstallState.active then return nil end
    return REPAINT_STEPS[RepaintOrderInstallState.step]
end

function sendRepaintChecklistUpdate()
    if not RepaintOrderInstallState.active then return end

    local currentStep = RepaintOrderInstallState.step
    local steps = {
        { id = "sanding", label = getNuiLocale("tablet.orders.repaint_checklist.sanding", "Sand the vehicle"), done = currentStep == "painting" or currentStep == "complete" },
        { id = "painting", label = getNuiLocale("tablet.orders.repaint_checklist.painting", "Repaint the vehicle"), done = currentStep == "complete" }
    }

    sendUi("wheelInstall:checklist:update", {
        title = getNuiLocale("tablet.orders.repaint_checklist.title", "Repaint Checklist"),
        note = getNuiLocale("tablet.orders.repaint_checklist.note", "Only the required next action is available in radial menu."),
        steps = steps
    })

    RepaintOrderInstallState.checklistVisible = true
end

function startRepaintInstallState()
    RepaintOrderInstallState.active = true
    RepaintOrderInstallState.step = "sanding"
    sendRepaintChecklistUpdate()
end

function clearRepaintInstallState()
    if RepaintOrderInstallState.checklistVisible then
        sendUi("wheelInstall:checklist:close", {})
    end

    RepaintOrderInstallState.active = false
    RepaintOrderInstallState.step = "idle"
    RepaintOrderInstallState.checklistVisible = false
end

function sendSimpleInstallChecklistUpdate()
    if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
        return
    end

    local flow = resolveSimpleInstallFlow()
    local hasHood = doesVehicleHaveHood()
    local currentStep = tostring(OrderInstallState.simpleStep or "idle")
    local steps = nil

    if flow == "armor" then
        steps = {
            { id = "cut_armor_panel", label = tuningLocales and tuningLocales.ArmorInstallCutChecklist or "Cut and remove a nearby door, hood, or trunk", done = currentStep == "weld" or currentStep == "complete" },
            { id = "weld_armor_panel", label = tuningLocales and tuningLocales.ArmorInstallWeldChecklist or "Weld and install the armored replacement", done = currentStep == "complete" }
        }
    elseif flow == "engine_swap" then
        steps = {}
        if hasHood then
            table.insert(steps, { id = "open_hood", label = getNuiLocale("tablet.orders.simple_checklist.open_hood", "Open the hood from the radial menu"), done = currentStep == "take_hoist" or currentStep == "attach_hoist" or currentStep == "engine_swap" or currentStep == "complete" })
        end
        if doesActiveEngineInstallUseHoist() then
            table.insert(steps, { id = "take_engine_hoist", label = getNuiLocale("tablet.orders.simple_checklist.take_engine_hoist", "Take the nearest engine hoist"), done = currentStep == "attach_hoist" or currentStep == "engine_swap" or currentStep == "complete" })
            table.insert(steps, { id = "attach_engine_hoist", label = getNuiLocale("tablet.orders.simple_checklist.attach_engine_hoist", "Attach the engine hoist to the front of the vehicle"), done = currentStep == "engine_swap" or currentStep == "complete" })
        end
        table.insert(steps, { id = "engine_swap", label = getNuiLocale("tablet.orders.simple_checklist.engine_swap", "Connect all engine tubes in the swap minigame"), done = currentStep == "complete" })
    elseif flow == "hood_install" then
        steps = {}
        if hasHood then
            table.insert(steps, { id = "open_hood", label = getNuiLocale("tablet.orders.simple_checklist.open_hood", "Open the hood from the radial menu"), done = currentStep == "install" or currentStep == "complete" })
        end
        table.insert(steps, { id = "install", label = getNuiLocale("tablet.orders.simple_checklist.install", "Install the selected part"), done = currentStep == "complete" })
    elseif flow == "oil_change" then
        steps = {
            { id = "lift_vehicle", label = getNuiLocale("tablet.orders.simple_checklist.lift_vehicle", "Lift the vehicle on the workshop lift"), done = currentStep == "drain_oil" or currentStep == "lower_vehicle" or currentStep == "open_hood" or currentStep == "pour_oil" or currentStep == "complete" },
            { id = "drain_old_oil", label = getNuiLocale("tablet.orders.simple_checklist.drain_old_oil", "Stand below the lifted vehicle and drain the old oil"), done = currentStep == "lower_vehicle" or currentStep == "open_hood" or currentStep == "pour_oil" or currentStep == "complete" },
            { id = "lower_vehicle", label = getNuiLocale("tablet.orders.simple_checklist.lower_vehicle", "Lower the vehicle back down with the workshop lift"), done = currentStep == "open_hood" or currentStep == "pour_oil" or currentStep == "complete" }
        }
        if hasHood then
            table.insert(steps, { id = "open_hood", label = getNuiLocale("tablet.orders.simple_checklist.open_hood", "Open the hood from the radial menu"), done = currentStep == "pour_oil" or currentStep == "complete" })
        end
        table.insert(steps, { id = "pour_new_oil", label = getNuiLocale("tablet.orders.simple_checklist.pour_new_oil", "Pour fresh oil into the engine using the minigame"), done = currentStep == "complete" })
    elseif flow == "underbody_neon" then
        steps = {
            { id = "lift_vehicle", label = getNuiLocale("tablet.orders.simple_checklist.lift_vehicle", "Lift the vehicle on the workshop lift"), done = currentStep == "install_neon" or currentStep == "complete" },
            { id = "install_underbody_neon", label = getUnderbodyInstallCopy(OrderInstallState.part).checklist, done = currentStep == "complete" }
        }
    elseif flow == "stance" then
        local completed = OrderInstallState.stanceCompletedWheels or {}
        steps = {
            { id = "lift_vehicle", label = getNuiLocale("tablet.orders.stance_checklist.lift_vehicle", "Lift the vehicle on the workshop lift"), done = currentStep == "stance_wheels" or currentStep == "complete" },
            { id = "front_left", label = getNuiLocale("tablet.orders.stance_checklist.front_left", "Adjust the front-left wheel joint"), done = completed.front_left == true },
            { id = "front_right", label = getNuiLocale("tablet.orders.stance_checklist.front_right", "Adjust the front-right wheel joint"), done = completed.front_right == true },
            { id = "rear_left", label = getNuiLocale("tablet.orders.stance_checklist.rear_left", "Adjust the rear-left wheel joint"), done = completed.rear_left == true },
            { id = "rear_right", label = getNuiLocale("tablet.orders.stance_checklist.rear_right", "Adjust the rear-right wheel joint"), done = completed.rear_right == true }
        }
    elseif flow == "fluid_refill" then
        local partKey = tostring(OrderInstallState.repairPart or "")
        local partLabel = getNuiLocale(("tablet.diagnostics.parts.%s"):format(partKey), partKey ~= "" and partKey or "fluid")
        local pourLabel = (getNuiLocale("tablet.orders.simple_checklist.pour_new_fluid", "Pour fresh %s using the minigame")):format(partLabel)

        steps = {}
        if hasHood then
            table.insert(steps, { id = "open_hood", label = getNuiLocale("tablet.orders.simple_checklist.open_hood", "Open the hood from the radial menu"), done = currentStep == "pour_oil" or currentStep == "complete" })
        end
        table.insert(steps, { id = "pour_new_oil", label = pourLabel, done = currentStep == "complete" })
    else
        steps = {
            { id = "install", label = getNuiLocale("tablet.orders.simple_checklist.install", "Install the selected part"), done = false }
        }
    end

    local title = (flow == "stance") and getNuiLocale("tablet.orders.stance_checklist.title", "Stance Installation") or getNuiLocale("tablet.orders.simple_checklist.title", "Install Checklist")
    local note = (flow == "stance") and getNuiLocale("tablet.orders.stance_checklist.note", "Raise the vehicle, then work on each wheel joint from the radial menu.") or getNuiLocale("tablet.orders.simple_checklist.note", "Use radial menu to complete the install.")

    local signature = ("%s:%s:%s"):format(tostring(resolveSimpleInstallFlow()), currentStep, tostring(json.encode(steps) or ""))

    if OrderInstallState.simpleChecklistVisible and OrderInstallState.simpleChecklistSignature == signature then
        return
    end

    sendUi("wheelInstall:checklist:update", {
        title = title,
        note = note,
        steps = steps
    })

    OrderInstallState.simpleChecklistVisible = true
    OrderInstallState.simpleChecklistSignature = signature
end

function startSimpleInstallState()
    local flow = resolveSimpleInstallFlow()
    local hasHood = doesVehicleHaveHood()

    if flow == "armor" then
        OrderInstallState.simpleStep = "cut"
    elseif flow == "engine_swap" then
        OrderInstallState.simpleStep = hasHood and "open_hood" or (doesActiveEngineInstallUseHoist() and "take_hoist" or "engine_swap")
    elseif flow == "hood_install" then
        OrderInstallState.simpleStep = hasHood and "open_hood" or "install"
    elseif flow == "oil_change" then
        OrderInstallState.simpleStep = "lift_vehicle"
    elseif flow == "underbody_neon" then
        local veh = getVehicleFromOrderNetId()
        local liftState = (veh ~= 0 and type(getWorkshopLiftStateForVehicle) == "function") and getWorkshopLiftStateForVehicle(veh) or nil
        OrderInstallState.simpleStep = (liftState and liftState.raised) and "install_neon" or "lift_vehicle"
    elseif flow == "stance" then
        local veh = getVehicleFromOrderNetId()
        local liftState = (veh ~= 0 and type(getWorkshopLiftStateForVehicle) == "function") and getWorkshopLiftStateForVehicle(veh) or nil
        OrderInstallState.stanceCompletedWheels = {}
        OrderInstallState.simpleStep = (liftState and liftState.raised) and "stance_wheels" or "lift_vehicle"
    elseif flow == "fluid_refill" then
        OrderInstallState.simpleStep = hasHood and "open_hood" or "pour_oil"
    else
        OrderInstallState.simpleStep = "install"
    end

    sendSimpleInstallChecklistUpdate()
end

function handleOilChangeLiftMotionComplete(vehicle, isRaised, isLowered)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then return end

    local flow = resolveSimpleInstallFlow()
    if flow ~= "oil_change" and flow ~= "underbody_neon" and flow ~= "stance" then return end

    local targetVeh = getVehicleFromOrderNetId()
    if targetVeh == 0 or not DoesEntityExist(targetVeh) or targetVeh ~= vehicle then return end

    local currentStep = tostring(OrderInstallState.simpleStep or "")

    if currentStep == "lift_vehicle" and isRaised then
        if flow == "underbody_neon" then
            OrderInstallState.simpleStep = "install_neon"
            sendSimpleInstallChecklistUpdate()
            notify(getUnderbodyInstallCopy(OrderInstallState.part).liftReady, "success")
            return
        end

        if flow == "stance" then
            OrderInstallState.simpleStep = "stance_wheels"
            sendSimpleInstallChecklistUpdate()
            notify(getNuiLocale("tablet.orders.stance_checklist.lift_ready", "Vehicle is raised. Adjust all four wheel joints."), "success")
            return
        end

        OrderInstallState.simpleStep = "drain_oil"
        sendSimpleInstallChecklistUpdate()
        notify(tuningLocales and tuningLocales.OilChangeLiftReady or "Vehicle is raised. Stand below it and drain the old oil.", "success")
        return
    end

    if currentStep == "lower_vehicle" and isLowered then
        local hasHood = HasVehicleHood(vehicle)
        OrderInstallState.simpleStep = hasHood and "open_hood" or "pour_oil"
        sendSimpleInstallChecklistUpdate()

        if hasHood then
            notify(tuningLocales and tuningLocales.OilChangeLoweredSuccess or "Vehicle lowered. Open the hood to fill fresh oil.", "success")
        else
            notify(tuningLocales and tuningLocales.OilChangeLoweredSuccessNoHood or "Vehicle lowered. Pour fresh oil to finish the service.", "success")
        end
    end
end

function canToggleTuningFocus()
    local now = GetGameTimer()
    local readyAt = tonumber(TuningState and TuningState.focusToggleReadyAt) or 0
    return now >= readyAt
end

function setNuiFocusState(enabled)
    local isFocused = enabled == true
    local changed = (TuningState.nuiFocused ~= isFocused)

    TuningState.nuiFocused = isFocused
    if changed then
        TuningState.focusToggleReadyAt = GetGameTimer() + 250
    end

    SetNuiFocus(isFocused, isFocused)
    SetNuiFocusKeepInput(false)

    if changed and TuningState.active then
        sendUi("tuning:focus", { enabled = isFocused })
    end
end

HORN_LABELS = {
    [0] = "Truck Horn", [1] = "Cop Horn", [2] = "Clown Horn", [3] = "Musical Horn 1",
    [4] = "Musical Horn 2", [5] = "Musical Horn 3", [6] = "Musical Horn 4", [7] = "Musical Horn 5",
    [8] = "Sad Trombone", [9] = "Classical Horn 1", [10] = "Classical Horn 2", [11] = "Classical Horn 3",
    [12] = "Classical Horn 4", [13] = "Classical Horn 5", [14] = "Classical Horn 6", [15] = "Classical Horn 7",
    [16] = "Scale - Do", [17] = "Scale - Re", [18] = "Scale - Mi", [19] = "Scale - Fa",
    [20] = "Scale - Sol", [21] = "Scale - La", [22] = "Scale - Ti", [23] = "Scale - Do",
    [24] = "Jazz Horn 1", [25] = "Jazz Horn 2", [26] = "Jazz Horn 3", [27] = "Jazz Horn Loop",
    [28] = "Star Spangled Banner 1", [29] = "Star Spangled Banner 2", [30] = "Star Spangled Banner 3", [31] = "Star Spangled Banner 4",
    [32] = "Classical Horn 8 Loop", [33] = "Classical Horn 9 Loop", [34] = "Classical Horn 10 Loop", [35] = "Classical Horn 8",
    [36] = "Classical Horn 9", [37] = "Classical Horn 10", [38] = "Funeral Loop", [39] = "Funeral",
    [40] = "Spooky Loop", [41] = "Spooky", [42] = "San Andreas Loop", [43] = "San Andreas",
    [44] = "Liberty City Loop", [45] = "Liberty City", [46] = "Festive 1 Loop", [47] = "Festive 1",
    [48] = "Festive 2 Loop", [49] = "Festive 2", [50] = "Festive 3 Loop", [51] = "Festive 3"
}

function parseModLabel(vehicle, modType, modIndex)
    local locVal = getNuiLocale(("mods.%d.%d"):format(modType, modIndex), nil)
    if locVal then return locVal end

    if modIndex == -1 then
        return getNuiLocale("common.stock", "Stock")
    end

    local modText = GetModTextLabel(vehicle, modType, modIndex)
    if modText and modText ~= "" then
        local labelText = GetLabelText(modText)
        if labelText and labelText ~= "NULL" and labelText ~= "" then
            return labelText
        end
        return modText
    end

    if modType == 14 and modIndex >= 0 then
        local hornLabel = GetLabelText(("CMOD_HRN_%d"):format(modIndex))
        if hornLabel and hornLabel ~= "NULL" and hornLabel ~= "" then
            return hornLabel
        end
        if HORN_LABELS[modIndex] then
            return HORN_LABELS[modIndex]
        end
    end

    return ("%s %d"):format(resolveModTypeLabel(vehicle, modType), modIndex + 1)
end

function addOption(sectionKey, option)
    if not isOptionEnabled(option) then return end

    TuningState.optionMap[option.id] = option
    table.insert(TuningState.options, option)

    TuningState.sections[sectionKey] = TuningState.sections[sectionKey] or {}
    table.insert(TuningState.sections[sectionKey], option.id)
end

function resolveModTypeLabel(vehicle, modType)
    local locVal = getNuiLocale(("option.label.mod_%s"):format(modType), nil)
    if locVal then return locVal end

    local slotName = GetModSlotName(vehicle, modType)
    if slotName and slotName ~= "" then
        local labelText = GetLabelText(slotName)
        if labelText and labelText ~= "NULL" and labelText ~= "" then
            return labelText
        end
        return slotName
    end

    return MOD_LABELS[modType] or ("%s %s"):format(getNuiLocale("option.label.mod_prefix", "Mod"), modType)
end

local function addModOption(vehicle, modType, sectionKey, cameraPart)
    local totalMods = GetNumVehicleMods(vehicle, modType)
    if totalMods <= 0 then return end

    local currentVal = GetVehicleMod(vehicle, modType)
    local maxIndex = totalMods - 1
    local allowedValues = calculateAllowedModValues(modType, currentVal, maxIndex)

    local labels = {}
    if allowedValues then
        for _, idx in ipairs(allowedValues) do
            labels[tostring(idx)] = parseModLabel(vehicle, modType, idx)
        end
    else
        for i = -1, maxIndex do
            labels[tostring(i)] = parseModLabel(vehicle, modType, i)
        end
    end

    local option = {
        id = ("mod_%s"):format(modType),
        kind = "mod",
        section = sectionKey,
        label = resolveModTypeLabel(vehicle, modType),
        min = allowedValues and allowedValues[1] or -1,
        max = allowedValues and allowedValues[#allowedValues] or maxIndex,
        value = currentVal,
        labels = labels,
        cameraPart = cameraPart,
        modType = modType,
        allowedValues = allowedValues
    }

    addOption(sectionKey, option)
end

function isAllowedOptionValue(option, val)
    if type(option.allowedValues) ~= "table" then return true end

    local targetVal = math.floor(tonumber(val) or 0)
    for _, allowed in ipairs(option.allowedValues) do
        if targetVal == allowed then return true end
    end
    return false
end

function addToggleOption(sectionKey, optionId, label, isTurnedOn, cameraPart, extraData)
    local labels = {
        ["0"] = getNuiLocale("common.off", "Off"),
        ["1"] = getNuiLocale("common.on", "On")
    }

    local option = {
        id = optionId,
        kind = "toggle",
        section = sectionKey,
        label = label,
        min = 0,
        max = 1,
        value = isTurnedOn and 1 or 0,
        labels = labels,
        cameraPart = cameraPart
    }

    if type(extraData) == "table" then
        for k, v in pairs(extraData) do option[k] = v end
    end

    addOption(sectionKey, option)
end

function addPaletteOption(sectionKey, optionId, label, currentIndex, presetList, cameraPart, extraData)
    local labels = {}
    for idx, item in ipairs(presetList) do
        labels[tostring(idx - 1)] = item.name
    end

    local option = {
        id = optionId,
        kind = "palette",
        section = sectionKey,
        label = label,
        min = 0,
        max = #presetList - 1,
        value = currentIndex,
        labels = labels,
        cameraPart = cameraPart
    }

    if type(extraData) == "table" then
        for k, v in pairs(extraData) do option[k] = v end
    end

    addOption(sectionKey, option)
end

function closestPaletteIndex(presetList, r, g, b)
    local bestIdx = 0
    local minDiff = math.huge

    for idx, preset in ipairs(presetList) do
        local pr, pg, pb = preset.rgb[1], preset.rgb[2], preset.rgb[3]
        local diff = (pr - r)^2 + (pg - g)^2 + (pb - b)^2
        if diff < minDiff then
            minDiff = diff
            bestIdx = idx - 1
        end
    end
    return bestIdx
end

function indexedPresetRgbByIndex(presetList, targetIndex)
    local targetInt = math.floor(tonumber(targetIndex) or 0)
    for _, preset in ipairs(presetList or {}) do
        if math.floor(tonumber(preset.index) or 0) == targetInt then
            if type(preset.rgb) == "table" then
                return {
                    r = math.floor(math.max(0, math.min(255, tonumber(preset.rgb[1]) or 0))),
                    g = math.floor(math.max(0, math.min(255, tonumber(preset.rgb[2]) or 0))),
                    b = math.floor(math.max(0, math.min(255, tonumber(preset.rgb[3]) or 0)))
                }
            end
        end
    end
    return nil
end

function closestPresetIndexFromRgb(presetList, r, g, b, defaultIndex)
    local defaultInt = math.max(0, math.floor(tonumber(defaultIndex) or 0))
    local minDiff = math.huge
    local bestIdx = defaultInt

    for _, preset in ipairs(presetList or {}) do
        local presetIdx = math.floor(tonumber(preset.index) or defaultInt)
        if presetIdx >= 0 and type(preset.rgb) == "table" then
            local pr = math.floor(math.max(0, math.min(255, tonumber(preset.rgb[1]) or 0)))
            local pg = math.floor(math.max(0, math.min(255, tonumber(preset.rgb[2]) or 0)))
            local pb = math.floor(math.max(0, math.min(255, tonumber(preset.rgb[3]) or 0)))

            local diff = (pr - r)^2 + (pg - g)^2 + (pb - b)^2
            if diff < minDiff then
                minDiff = diff
                bestIdx = presetIdx
            end
        end
    end

    return bestIdx
end

function addIndexOption(sectionKey, optionId, label, value, minVal, maxVal, labelsMap, cameraPart, extraData)
    local option = {
        id = optionId,
        kind = "index",
        section = sectionKey,
        label = label,
        value = value,
        min = minVal,
        max = maxVal,
        labels = labelsMap or {},
        cameraPart = cameraPart
    }

    if type(extraData) == "table" then
        for k, v in pairs(extraData) do option[k] = v end
    end

    addOption(sectionKey, option)
end

local BODYWORK_MOD_TYPES = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 14, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 49
}

local function getCameraPartForModType(modType)
    if modType <= 2 or modType == 6 or modType == 7 then return "front" end
    if modType == 3 or modType == 8 then return "side_left" end
    if modType == 9 then return "side_right" end
    if modType == 10 or modType == 49 then return "roof" end
    if modType == 4 then return "rear" end
    if modType >= 27 and modType <= 38 then return "interior" end
    return "center"
end

local function addPerformanceCategoryOptions(vehicle)
    addModOption(vehicle, 11, "performance", "front")
    addModOption(vehicle, 12, "performance", "wheels_front")
    addModOption(vehicle, 13, "performance", "front")
    addModOption(vehicle, 15, "performance", "wheels_rear")

    if not isBikeClass(vehicle) then
        addModOption(vehicle, 16, "performance", "front")
    end

    addToggleOption(
        "performance", "toggle_18",
        (MOD_LABELS and MOD_LABELS[18]) or "Turbo",
        IsToggleModOn(vehicle, 18),
        "rear",
        { modType = 18 }
    )

    if type(AntiLag) == "table" and type(AntiLag.AddOptions) == "function" then
        AntiLag.AddOptions(vehicle, addToggleOption)
    end

    if type(TwoStep) == "table" and type(TwoStep.AddOptions) == "function" then
        TwoStep.AddOptions(vehicle, addToggleOption)
    end
end

local function addBodyworkCategoryOptions(vehicle)
    local extraPrefix = getNuiLocale("option.value.extra.prefix", "Extra")

    for _, modType in ipairs(BODYWORK_MOD_TYPES) do
        addModOption(vehicle, modType, "bodywork", getCameraPartForModType(modType))
    end

    for extraId = 1, 20 do
        if DoesExtraExist(vehicle, extraId) then
            addToggleOption(
                "bodywork",
                ("extra_%d"):format(extraId),
                ("%s %d"):format(extraPrefix, extraId),
                IsVehicleExtraTurnedOn(vehicle, extraId),
                "center",
                { extraId = extraId }
            )
        end
    end

    local plateLabels = {}
    local stylePrefix = getNuiLocale("option.value.plate_index.prefix", "Style")

    for i = 0, 5 do
        plateLabels[tostring(i)] = PLATE_LABELS[i] or ("%s %d"):format(stylePrefix, i)
    end

    addIndexOption(
        "bodywork", "plate_index",
        getNuiLocale("option.label.plate_index", "Plate Style"),
        GetVehicleNumberPlateTextIndex(vehicle),
        0, 5, plateLabels, "front"
    )
end

local function addWheelsCategoryOptions(vehicle)
    if GetNumVehicleMods(vehicle, 23) > 0 then
        addModOption(vehicle, 23, "wheels", "wheels_front")
        addToggleOption(
            "wheels", "wheel_custom_23",
            getNuiLocale("option.label.wheel_custom_23", "Front Custom Tires"),
            GetVehicleModVariation(vehicle, 23),
            "wheels_front",
            { modType = 23, wheelVariation = true }
        )
    end

    if GetNumVehicleMods(vehicle, 24) > 0 then
        addModOption(vehicle, 24, "wheels", "wheels_rear")
        addToggleOption(
            "wheels", "wheel_custom_24",
            getNuiLocale("option.label.wheel_custom_24", "Rear Custom Tires"),
            GetVehicleModVariation(vehicle, 24),
            "wheels_rear",
            { modType = 24, wheelVariation = true }
        )
    end

    local wheelTypeLabels = {}
    local typePrefix = getNuiLocale("option.value.wheel_type.prefix", "Type")

    for i = 0, 12 do
        wheelTypeLabels[tostring(i)] = WHEEL_TYPE_LABELS[i] or ("%s %d"):format(typePrefix, i)
    end

    addIndexOption(
        "wheels", "wheel_type",
        getNuiLocale("option.label.wheel_type", "Wheel Type"),
        GetVehicleWheelType(vehicle),
        0, 12, wheelTypeLabels, "wheels_front"
    )

    addToggleOption(
        "wheels", "toggle_20",
        getNuiLocale("option.label.toggle_20", "Tire Smoke"),
        IsToggleModOn(vehicle, 20),
        "wheels_rear",
        { modType = 20 }
    )

    local sr, sg, sb = GetVehicleTyreSmokeColor(vehicle)
    local smokeIdx = closestPaletteIndex(TIRE_SMOKE_PRESETS or {}, sr, sg, sb)

    local presetItem = TIRE_SMOKE_PRESETS and TIRE_SMOKE_PRESETS[smokeIdx + 1]
    local customCol = nil

    if presetItem then
        if presetItem.rgb[1] ~= sr or presetItem.rgb[2] ~= sg or presetItem.rgb[3] ~= sb then
            customCol = { r = sr, g = sg, b = sb }
        end
    else
        customCol = { r = sr, g = sg, b = sb }
    end

    addPaletteOption(
        "wheels", "tire_smoke_color",
        getNuiLocale("option.label.tire_smoke_color", "Tire Smoke Color"),
        smokeIdx, TIRE_SMOKE_PRESETS or {}, "wheels_rear",
        { supportsCustom = true, customColor = customCol, paintType = 0 }
    )
end

local function addLightsCategoryOptions(vehicle)
    addToggleOption(
        "lights", "toggle_22",
        (MOD_LABELS and MOD_LABELS[22]) or "Xenon Lights",
        IsToggleModOn(vehicle, 22),
        "front",
        { modType = 22 }
    )

    local currentXenonColor = GetVehicleXenonLightsColor(vehicle)
    local customXenonColor = nil

    local xenonValuesMap = {}
    local xenonNativeToVal = {}
    local xenonLabels = {}
    local counter = 0

    for _, preset in ipairs(XENON_COLOR_PRESETS or {}) do
        local idx = math.floor(tonumber(preset.index) or 0)
        if idx >= 0 then
            local valIdx = counter
            counter = counter + 1

            xenonValuesMap[tostring(valIdx)] = idx
            xenonNativeToVal[tostring(idx)] = valIdx

            local pName = tostring(preset.name or XENON_LABELS[idx] or ("Xenon " .. tostring(idx)))
            xenonLabels[tostring(valIdx)] = pName
        end
    end

    local stateBagCustom = Entity(vehicle).state["sky_mechanicjob:xenonCustomColor"]
    if type(stateBagCustom) == "table" then
        local r = math.floor(math.max(0, math.min(255, tonumber(stateBagCustom.r) or 0)))
        local g = math.floor(math.max(0, math.min(255, tonumber(stateBagCustom.g) or 0)))
        local b = math.floor(math.max(0, math.min(255, tonumber(stateBagCustom.b) or 0)))
        customXenonColor = { r = r, g = g, b = b }
        currentXenonColor = closestPresetIndexFromRgb(XENON_COLOR_PRESETS or {}, r, g, b, 0)
    elseif currentXenonColor == 255 then
        local _, xr, xg, xb = GetVehicleXenonLightsCustomColor(vehicle)
        local r = math.floor(math.max(0, math.min(255, tonumber(xr) or 0)))
        local g = math.floor(math.max(0, math.min(255, tonumber(xg) or 0)))
        local b = math.floor(math.max(0, math.min(255, tonumber(xb) or 0)))
        customXenonColor = { r = r, g = g, b = b }
        currentXenonColor = closestPresetIndexFromRgb(XENON_COLOR_PRESETS or {}, r, g, b, 0)
    else
        customXenonColor = indexedPresetRgbByIndex(XENON_COLOR_PRESETS or {}, currentXenonColor)
    end

    local selectedVal = tonumber(xenonNativeToVal[tostring(math.floor(tonumber(currentXenonColor) or -1))])
    if selectedVal == nil then
        selectedVal = tonumber(xenonNativeToVal["0"]) or 0
    end

    addIndexOption(
        "lights", "xenon_color",
        getNuiLocale("option.label.xenon_color", "Xenon Color"),
        selectedVal, 0, math.max(0, counter - 1),
        xenonLabels, "front",
        {
            supportsCustom = true,
            customColor = customXenonColor,
            paintType = 0,
            xenonValueToNativeIndex = xenonValuesMap,
            xenonNativeToValue = xenonNativeToVal
        }
    )

    addToggleOption("lights", "neon_0", getNuiLocale("option.label.neon_0", "Neon Left"), IsVehicleNeonLightEnabled(vehicle, 0), "side_left", { neonIndex = 0 })
    addToggleOption("lights", "neon_1", getNuiLocale("option.label.neon_1", "Neon Right"), IsVehicleNeonLightEnabled(vehicle, 1), "side_right", { neonIndex = 1 })
    addToggleOption("lights", "neon_2", getNuiLocale("option.label.neon_2", "Neon Front"), IsVehicleNeonLightEnabled(vehicle, 2), "front", { neonIndex = 2 })
    addToggleOption("lights", "neon_3", getNuiLocale("option.label.neon_3", "Neon Rear"), IsVehicleNeonLightEnabled(vehicle, 3), "rear", { neonIndex = 3 })

    local nr, ng, nb = GetVehicleNeonLightsColour(vehicle)
    addPaletteOption(
        "lights", "neon_color",
        getNuiLocale("option.label.neon_color", "Neon Color"),
        closestPaletteIndex(NEON_COLOR_PRESETS or {}, nr, ng, nb),
        NEON_COLOR_PRESETS or {}, "side_left",
        { supportsCustom = true, customColor = { r = nr, g = ng, b = nb }, paintType = 0 }
    )

    if TuningState.mode == "rgb_controller" then
        local effectLabels = {
            ["0"] = getNuiLocale("option.value.neon_effect.0", "Static"),
            ["1"] = getNuiLocale("option.value.neon_effect.1", "Rainbow"),
            ["2"] = getNuiLocale("option.value.neon_effect.2", "Flash"),
            ["3"] = getNuiLocale("option.value.neon_effect.3", "Pulse")
        }

        local neonEffect = math.floor(math.max(0, math.min(3, tonumber(TuningState.rgbNeonEffectMode) or 0)))
        local neonSpeed = math.floor(math.max(1, math.min(10, tonumber(TuningState.rgbNeonEffectSpeed) or 5)))

        addIndexOption("lights", "neon_effect", getNuiLocale("option.label.neon_effect", "Neon Effect"), neonEffect, 0, 3, effectLabels, "side_left")
        addIndexOption("lights", "neon_effect_speed", getNuiLocale("option.label.neon_effect_speed", "Effect Speed"), neonSpeed, 1, 10, nil, "side_left")

        local xenonEffect = math.floor(math.max(0, math.min(3, tonumber(TuningState.rgbXenonEffectMode) or 0)))
        local xenonSpeed = math.floor(math.max(1, math.min(10, tonumber(TuningState.rgbXenonEffectSpeed) or 5)))

        local xenonEffectLabels = {
            ["0"] = getNuiLocale("option.value.xenon_effect.0", "Static"),
            ["1"] = getNuiLocale("option.value.xenon_effect.1", "Rainbow"),
            ["2"] = getNuiLocale("option.value.xenon_effect.2", "Flash"),
            ["3"] = getNuiLocale("option.value.xenon_effect.3", "Pulse")
        }

        addIndexOption("lights", "xenon_effect", getNuiLocale("option.label.xenon_effect", "Xenon Effect"), xenonEffect, 0, 3, xenonEffectLabels, "front")
        addIndexOption("lights", "xenon_effect_speed", getNuiLocale("option.label.xenon_effect_speed", "Xenon Effect Speed"), xenonSpeed, 1, 10, nil, "front")
    end
end

local function addPaintCategoryOptions(vehicle)
    local primaryColor, secondaryColor = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

    pearlescentColor = math.floor(tonumber(pearlescentColor) or 0)
    local dashboardColor = GetVehicleDashboardColour(vehicle)
    local interiorColor = GetVehicleInteriorColour(vehicle)

    local modColor1 = GetVehicleModColor_1(vehicle)
    local modColor2 = GetVehicleModColor_2(vehicle)

    local customPrimary = nil
    if GetIsVehiclePrimaryColourCustom(vehicle) then
        local pr, pg, pb = GetVehicleCustomPrimaryColour(vehicle)
        customPrimary = { r = pr, g = pg, b = pb }
    end

    local customSecondary = nil
    if GetIsVehicleSecondaryColourCustom(vehicle) then
        local sr, sg, sb = GetVehicleCustomSecondaryColour(vehicle)
        customSecondary = { r = sr, g = sg, b = sb }
    end

    addIndexOption(
        "paint", "color_primary",
        getNuiLocale("option.label.color_primary", "Primary Color"),
        primaryColor, 0, 242, nil, "front",
        { supportsCustom = true, customColor = customPrimary, paintType = modColor1 }
    )

    addIndexOption(
        "paint", "color_secondary",
        getNuiLocale("option.label.color_secondary", "Secondary Color"),
        secondaryColor, 0, 242, nil, "side_left",
        { supportsCustom = true, customColor = customSecondary, paintType = modColor2 }
    )

    addIndexOption("paint", "color_pearlescent", getNuiLocale("option.label.color_pearlescent", "Pearlescent"), pearlescentColor, 0, 242, nil, "roof")
    addIndexOption("paint", "color_wheel", getNuiLocale("option.label.color_wheel", "Wheel Color"), wheelColor, 0, 242, nil, "wheels_front")
    addIndexOption("paint", "color_dashboard", getNuiLocale("option.label.color_dashboard", "Dashboard Color"), dashboardColor, 0, 159, nil, "interior")
    addIndexOption("paint", "color_interior", getNuiLocale("option.label.color_interior", "Interior Color"), interiorColor, 0, 159, nil, "interior")

    local tintLabels = {}
    local tintPrefix = getNuiLocale("option.value.window_tint.prefix", "Tint")

    for i = -1, 6 do
        tintLabels[tostring(i)] = WINDOW_TINT_LABELS[i] or ("%s %d"):format(tintPrefix, i)
    end

    addIndexOption(
        "paint", "window_tint",
        getNuiLocale("option.label.window_tint", "Window Tint"),
        GetVehicleWindowTint(vehicle), -1, 6, tintLabels, "side_left"
    )

    if GetNumVehicleMods(vehicle, 48) > 0 then
        addModOption(vehicle, 48, "paint", "roof")
    else
        local liveryCount = GetVehicleLiveryCount(vehicle)
        if liveryCount and liveryCount > 0 then
            local liveryLabels = {}
            local livPrefix = getNuiLocale("option.value.livery.prefix", "Livery")

            for i = 0, liveryCount - 1 do
                liveryLabels[tostring(i)] = ("%s %d"):format(livPrefix, i + 1)
            end

            addIndexOption(
                "paint", "livery",
                getNuiLocale("option.label.livery", "Livery"),
                math.floor(tonumber(GetVehicleLivery(vehicle)) or 0), 0, liveryCount - 1,
                liveryLabels, "roof"
            )
        end
    end
end

local function addStanceCategoryOptions(vehicle)
    if type(StanceKit) == "table" and type(StanceKit.AddOptions) == "function" then
        StanceKit.AddOptions(addIndexOption, vehicle)
    end
end

local function calculateOptionPrices(vehicle)
    local basePrice = getVehicleBasePrice(vehicle)

    for _, opt in ipairs(TuningState.options) do
        opt.prices = buildOptionPriceMap(opt, vehicle, basePrice)
    end
end

function buildOptionsForVehicle(vehicle)
    TuningState.options = {}
    TuningState.optionMap = {}
    TuningState.sections = {}

    SetVehicleModKit(vehicle, 0)
    TuningState.customHandlingBase = nil

    if CustomTuning and CustomTuning.UseVehicleSelections then
        CustomTuning.UseVehicleSelections(vehicle)
    end
    if CustomTuning and CustomTuning.EnsureBaseline then
        CustomTuning.EnsureBaseline(vehicle)
    end

    addPerformanceCategoryOptions(vehicle)

    if CustomTuning and CustomTuning.AddOptions then
        CustomTuning.AddOptions(addIndexOption, vehicle)
    end

    addBodyworkCategoryOptions(vehicle)
    addWheelsCategoryOptions(vehicle)
    addLightsCategoryOptions(vehicle)
    addPaintCategoryOptions(vehicle)
    addStanceCategoryOptions(vehicle)

    calculateOptionPrices(vehicle)
end

RGB_CONTROLLER_LIGHTS = {
    toggle_22 = true, xenon_color = true, neon_0 = true, neon_1 = true,
    neon_2 = true, neon_3 = true, neon_color = true, neon_effect = true,
    neon_effect_speed = true, xenon_effect = true, xenon_effect_speed = true
}

function buildUiPayload()
    local isRgbMode = TuningState.mode == "rgb_controller"
    local isStanceMode = TuningState.mode == "stancing"

    local sectionList = {}
    local defaultSections = SECTION_ORDER or { "performance", "handling", "bodywork", "wheels", "lights", "paint", "stancer" }

    local orderedNames = {}
    local seenSections = {}

    for _, sName in ipairs(defaultSections) do
        local nameStr = tostring(sName or "")
        if nameStr ~= "" and not seenSections[nameStr] then
            table.insert(orderedNames, nameStr)
            seenSections[nameStr] = true
        end
    end

    for sName in pairs(TuningState.sections or {}) do
        local nameStr = tostring(sName or "")
        if nameStr ~= "" and not seenSections[nameStr] then
            table.insert(orderedNames, nameStr)
            seenSections[nameStr] = true
        end
    end

    for _, sName in ipairs(orderedNames) do
        if (not isRgbMode or sName == "lights") and (not isStanceMode or sName == "stancer") then
            local optIds = TuningState.sections[sName] or {}
            if isRgbMode then
                local filtered = {}
                for _, optId in ipairs(optIds) do
                    if RGB_CONTROLLER_LIGHTS[optId] then
                        table.insert(filtered, optId)
                    end
                end
                optIds = filtered
            end

            if #optIds > 0 then
                table.insert(sectionList, { key = sName, options = optIds })
            end
        end
    end

    local optionsMap = {}
    for _, opt in ipairs(TuningState.options) do
        if (not isRgbMode or RGB_CONTROLLER_LIGHTS[opt.id]) and (not isStanceMode or opt.kind == "stancer") then
            local base = TuningState.optionBaselines[opt.id] or {}

            optionsMap[opt.id] = {
                id = opt.id,
                kind = opt.kind,
                label = opt.label,
                min = opt.min,
                max = opt.max,
                value = opt.value,
                labels = opt.labels or {},
                values = opt.allowedValues,
                section = opt.section,
                supportsCustom = opt.supportsCustom == true,
                customColor = opt.customColor,
                paintType = opt.paintType,
                baseValue = base.value,
                basePaintType = base.paintType,
                baseCustomColor = base.customColor,
                scale = opt.scale,
                step = opt.step,
                prices = isStanceMode and {} or (opt.prices or {})
            }
        end
    end

    return {
        adminMode = TuningState.adminMode == true,
        mode = TuningState.mode or "full",
        sections = sectionList,
        options = optionsMap
    }
end
