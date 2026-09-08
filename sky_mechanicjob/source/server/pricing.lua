if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/pricing.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/pricing.lua
--  Server-Side Pricing Validation (Security Rewrite)
-- =====================================================

Pricing = Pricing or {}

local function toPriceFromPercentage(basePrice, percentage)
    if type(percentage) ~= "number" or percentage <= 0 then
        return 0
    end
    return math.floor((basePrice * percentage) / 100)
end

function Pricing.GetJobCostProfile(jobName)
    if Config and Config.Jobs then
        for _, j in ipairs(Config.Jobs) do
            if j.name == jobName and j.tuningCostProfile then
                return j.tuningCostProfile
            end
        end
    end
    return Config and Config.TuningCostProfile or {}
end

function Pricing.GetVehicleBasePrice(modelName, costProfile)
    if costProfile and tostring(costProfile.priceType or "percentage"):lower() == "fixed" then
        return 0
    end

    local defaultPrice = costProfile and costProfile.fallbackVehicleValue or 50000

    if modelName and MySQL and MySQL.single and MySQL.single.await then
        local ok, row = pcall(function()
            return MySQL.single.await("SELECT price FROM vehicles WHERE model = @model LIMIT 1", {
                ["@model"] = string.lower(tostring(modelName))
            })
        end)
        if ok and row and row.price and tonumber(row.price) > 0 then
            return tonumber(row.price)
        end
    end
    return defaultPrice
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

function Pricing.CalculateOptionCost(jobName, modelName, optionId, valIndex, instantMode)
    local costProfile = Pricing.GetJobCostProfile(jobName)
    local optionIdStr = tostring(optionId or "")
    if optionIdStr == "" then return 0 end

    local costData = costProfile[optionIdStr]
    if not costData then return 0 end

    local costValue = resolveOptionCostValue(costData, valIndex)
    local rawVal = costValue
    if type(rawVal) == "table" then
        rawVal = rawVal.cost or rawVal.price
    end

    local costNum = tonumber(rawVal) or 0
    if costNum <= 0 then return 0 end

    local isFixed = tostring(costProfile.priceType or "percentage"):lower() == "fixed"
    local finalPrice = 0

    if isFixed then
        finalPrice = math.floor(costNum)
    else
        local basePrice = Pricing.GetVehicleBasePrice(modelName, costProfile)
        finalPrice = toPriceFromPercentage(basePrice, costNum)
    end

    if instantMode then
        local multiplier = tonumber(Config and Config.InstantTuning and Config.InstantTuning.priceMultiplier) or 1.0
        finalPrice = math.floor(finalPrice * multiplier)
    end

    return finalPrice
end
