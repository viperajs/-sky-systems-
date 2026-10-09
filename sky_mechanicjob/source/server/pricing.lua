if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/pricing.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/pricing.lua
--  Server-Side Pricing Validation (Security Rewrite)
-- =====================================================

Pricing = Pricing or {}

local WHEEL_TYPE_KEYS = {
    [0] = "sport", [1] = "muscle", [2] = "lowrider", [3] = "suv", [4] = "offroad", [5] = "tuner",
    [6] = "bike", [7] = "high_end", [8] = "benny_original", [9] = "benny_bespoke", [10] = "open_wheel",
    [11] = "street", [12] = "track"
}

local TOGGLE_OPTION_PATTERNS = { "^toggle_%d+$", "^neon_[0-3]$", "^extra_%d+$", "^wheel_custom_2[34]$" }
local TOGGLE_OPTION_IDS = { antilag_enabled = true, twostep_enabled = true }

-- -----------------------------------------------------
--  /jobconfig settings (the client applies them over Config.TuningCostProfile)
-- -----------------------------------------------------

local configuratorData = nil

-- /jobconfig workshops over the config.lua job of their job key (else the first one),
-- the way the clients merge them into Config.Jobs (client/main.lua). Their Tuning Prices
-- and Parts Delivery tabs are saved on the workshop.
local function mergeWorkshopEntries(entries)
    local luaJobs = Config and Config.Jobs or {}
    local merged = {}
    for _, entry in ipairs(type(entries) == "table" and entries or {}) do
        if type(entry) == "table" then
            local key = entry.jobKey or entry.job or entry.name
            local base = type(luaJobs[1]) == "table" and luaJobs[1] or {}
            for _, job in ipairs(luaJobs) do
                if type(job) == "table" and job.name == key then
                    base = job
                    break
                end
            end
            local job = {}
            for k, v in pairs(base) do job[k] = v end
            for k, v in pairs(entry) do job[k] = v end
            merged[#merged + 1] = job
        end
    end
    return merged
end

local function loadConfiguratorData()
    if not (Config and Config.UseJobConfigurator) then
        configuratorData = nil
        return
    end

    local ok, row = pcall(function()
        return MySQL.single.await("SELECT data FROM sky_jobs_creator_data WHERE creator_key = 'workshopcreator' LIMIT 1")
    end)
    if not ok then return end

    local decoded = nil
    if row and type(row.data) == "string" then
        local decodeOk, value = pcall(json.decode, row.data)
        decoded = decodeOk and type(value) == "table" and value or nil
    end

    configuratorData = {
        settings = decoded and type(decoded.settings) == "table" and decoded.settings or {},
        features = decoded and type(decoded.features) == "table" and decoded.features or {},
        jobs = mergeWorkshopEntries(decoded and decoded.entries)
    }

    -- The settings the clients apply over config.lua, so the server checks the same items,
    -- locations and prices (parts theft, vehicle care, wear, carry items, instant tuning).
    local applied, err = pcall(ApplyJobConfiguratorSettings, configuratorData.settings)
    if not applied then
        print(("[sky_mechanicjob] applying the /jobconfig settings failed: %s"):format(tostring(err)))
    end

    -- tablet_apps.lua registers the workshops' shop, props and vehicles from these.
    TriggerEvent("sky_mechanicjob:server:jobConfiguratorLoaded")
end

CreateThread(function()
    while not (MySQL and MySQL.single) do
        Wait(500)
    end
    Wait(1000)
    loadConfiguratorData()
end)

-- Raised by sky_jobs_base at its start and after every /jobconfig save.
AddEventHandler("sky_jobs_base:jobConfigurator:jobNamesUpdated", function(configKey)
    if configKey ~= "sky_mechanicjob" then return end
    CreateThread(loadConfiguratorData)
end)

--- Tuning cost setting (priceType, fallbackVehicleValue, freeVehicles, addRevenueToSociety, ...)
---@param key string
---@return any
function Pricing.GetSetting(key)
    local settings = configuratorData and configuratorData.settings
    if settings and settings[key] ~= nil then
        return settings[key]
    end
    local profile = Config and Config.TuningCostProfile or {}
    return profile[key]
end

--- Feature toggle as the clients see it (/jobconfig features replace Config.ToggleFeatures)
---@param key string
---@return boolean
function Pricing.IsFeatureEnabled(key)
    if configuratorData and Config and Config.UseJobConfigurator then
        return configuratorData.features[key] == true
    end
    return Config and Config.ToggleFeatures and Config.ToggleFeatures[key] == true or false
end

-- -----------------------------------------------------
--  Profiles and vehicle prices
-- -----------------------------------------------------

-- The /jobconfig workshops when there are any (as the clients' Config.Jobs), else config.lua.
local function getWorkshopJobs()
    local workshops = configuratorData and configuratorData.jobs
    if type(workshops) == "table" and #workshops > 0 then
        return workshops
    end
    return Config and Config.Jobs or {}
end

--- Workshop of a job (jobKey, job or name, like GetJobConfigByName on the client), or nil
---@param jobName string|nil
---@return table|nil
function Pricing.FindJobConfig(jobName)
    if type(jobName) ~= "string" or jobName == "" then return nil end
    for _, job in ipairs(getWorkshopJobs()) do
        if type(job) == "table" and (job.jobKey == jobName or job.job == jobName or job.name == jobName) then
            return job
        end
    end
    return nil
end

--- Workshop of a job, else the first one
---@param jobName string|nil
---@return table
function Pricing.GetJobConfig(jobName)
    local job = Pricing.FindJobConfig(jobName)
    if job then return job end
    local jobs = getWorkshopJobs()
    return type(jobs[1]) == "table" and jobs[1] or {}
end

function Pricing.GetJobCostProfile(jobName)
    return Pricing.GetJobConfig(jobName).tuningCostProfile or {}
end

local function isFixedPriceType()
    local priceType = tostring(Pricing.GetSetting("priceType") or "percentage"):lower()
    return priceType == "fixed" or priceType == "price"
end

local function findSharedVehicle(list, modelName, modelHash)
    if type(list) ~= "table" then return nil end
    local name = type(modelName) == "string" and modelName:lower() or nil
    if name and type(list[name]) == "table" then return list[name] end
    for key, vehicle in pairs(list) do
        if type(vehicle) == "table" then
            local model = vehicle.model or key
            if (modelHash and (tonumber(vehicle.hash) == modelHash or (type(model) == "string" and GetHashKey(model) == modelHash)))
                or (name and type(model) == "string" and model:lower() == name) then
                return vehicle
            end
        end
    end
    return nil
end

--- Shop price of a vehicle model, or nil when unknown
---@param modelName string|nil spawn or display name
---@param modelHash number|nil
---@return number|nil
function Pricing.GetVehiclePrice(modelName, modelHash)
    modelHash = tonumber(modelHash)
    local framework = Functions.GetFramework()
    local vehicle = nil

    if framework == "qbox" then
        local ok, result = pcall(function()
            if modelHash then
                local byHash = exports.qbx_core:GetVehiclesByHash(modelHash)
                if type(byHash) == "table" and byHash.price ~= nil then return byHash end
            end
            if type(modelName) == "string" then
                local byName = exports.qbx_core:GetVehiclesByName(modelName:lower())
                if type(byName) == "table" and byName.price ~= nil then return byName end
            end
            return nil
        end)
        vehicle = ok and result or nil
    elseif framework == "qb" then
        local ok, core = pcall(function() return exports["qb-core"]:GetCoreObject() end)
        if ok and type(core) == "table" and type(core.Shared) == "table" then
            vehicle = findSharedVehicle(core.Shared.Vehicles, modelName, modelHash)
        end
    elseif framework == "esx" and type(modelName) == "string" and MySQL and MySQL.single then
        local ok, row = pcall(function()
            return MySQL.single.await("SELECT price FROM vehicles WHERE model = ? LIMIT 1", { modelName:lower() })
        end)
        vehicle = ok and row or nil
    end

    local price = vehicle and tonumber(vehicle.price)
    if price and price > 0 then
        return math.floor(price)
    end
    return nil
end

--- Base price for percentage pricing (0 for fixed pricing)
function Pricing.GetVehicleBasePrice(modelName, modelHash)
    if isFixedPriceType() then
        return 0
    end
    return Pricing.GetVehiclePrice(modelName, modelHash) or math.floor(tonumber(Pricing.GetSetting("fallbackVehicleValue")) or 50000)
end

--- Whether a model is listed in freeVehicles
function Pricing.IsFreeVehicle(modelHash)
    modelHash = tonumber(modelHash)
    if not modelHash then return false end
    local list = Pricing.GetSetting("freeVehicles")
    for _, entry in ipairs(type(list) == "table" and list or {}) do
        if type(entry) == "number" then
            if entry == modelHash then return true end
        elseif type(entry) == "string" then
            local name = entry:match("^%s*(.-)%s*$")
            if name ~= "" and GetHashKey(name) == modelHash then return true end
        end
    end
    return false
end

-- -----------------------------------------------------
--  Option prices (mirrors the client's tuning menu pricing in client/orders.lua)
-- -----------------------------------------------------

local function resolveOptionCostValue(costData, valIndex)
    if type(costData) ~= "table" then return costData end

    local index = tonumber(valIndex)
    local valuesList = costData.values or costData.costs

    if type(valuesList) == "table" and index ~= nil then
        local idxInt = math.floor(index)
        return valuesList[idxInt] or valuesList[tostring(idxInt)] or valuesList[idxInt + 1] or costData
    end

    if type(costData.cost) == "table" and index ~= nil then
        local idxInt = math.floor(index)
        return costData.cost[idxInt] or costData.cost[tostring(idxInt)] or costData.cost[idxInt + 1] or costData
    end

    return costData
end

local function priceOf(ctx, costEntry)
    local raw = costEntry
    if type(raw) == "table" then
        raw = raw.cost or raw.price
    end

    local costNum = tonumber(raw) or 0
    if costNum <= 0 then return 0 end

    local price
    if ctx.fixed then
        price = math.floor(costNum)
    else
        price = math.floor((ctx.basePrice * costNum) / 100)
    end
    if ctx.multiplier then
        price = math.floor(price * ctx.multiplier)
    end
    return price
end

local function itemsOf(...)
    for i = 1, select("#", ...) do
        local entry = select(i, ...)
        if type(entry) == "table" and type(entry.items) == "table" then
            local first = entry.items[1]
            return (type(first) == "string" and first ~= "") and first or nil, entry.removeAfterUse ~= false
        end
    end
    return nil, true
end

local function findByModType(list, modType)
    for _, entry in pairs(type(list) == "table" and list or {}) do
        if type(entry) == "table" and tonumber(entry.modType) == modType then
            return entry
        end
    end
    return nil
end

local function isToggleOption(optionId)
    if TOGGLE_OPTION_IDS[optionId] then return true end
    for _, pattern in ipairs(TOGGLE_OPTION_PATTERNS) do
        if optionId:match(pattern) then return true end
    end
    return false
end

--- Pricing context for one purchase
---@param jobName string|nil workshop job (its tuning cost profile, else the first workshop's)
---@param modelHash number|nil
---@param options table|nil { instant = bool, free = bool }
function Pricing.NewContext(jobName, modelHash, options)
    options = options or {}
    local fixed = isFixedPriceType()
    local multiplier = nil
    if options.instant then
        multiplier = tonumber(Config and Config.InstantTuning and Config.InstantTuning.priceMultiplier) or 1.0
    end
    return {
        profile = Pricing.GetJobCostProfile(jobName),
        fixed = fixed,
        basePrice = fixed and 0 or Pricing.GetVehicleBasePrice(nil, modelHash),
        multiplier = multiplier,
        free = options.free == true
    }
end

--- Price, required item and removeAfterUse of one basket entry; nil and an error code
--- when the option is disabled or the value has no configured price.
---@param ctx table from Pricing.NewContext
---@param optionId string
---@param value any
---@param wheelType number|nil
---@return table|nil, string|nil
function Pricing.PriceEntry(ctx, optionId, value, wheelType)
    optionId = tostring(optionId or "")
    if optionId == "" or #optionId > 64 then return nil, "invalid_part" end

    local profile = ctx.profile or {}
    local options = type(profile.optionCostByOptionId) == "table" and profile.optionCostByOptionId or {}
    local cost, itemEntry, valueEntry = 0, nil, nil

    local modType = tonumber(optionId:match("^mod_(%d+)$"))
    if modType then
        local v = tonumber(value)
        if not v or modType > 49 or (modType >= 17 and modType <= 22) then return nil, "invalid_part" end
        v = math.floor(v)
        if v < -1 or v > 512 then return nil, "invalid_value" end

        local stage = findByModType(profile.performanceStages, modType)
        local appearance = findByModType(profile.appearanceMods, modType)
        if (stage and stage.enabled == false) or (appearance and appearance.enabled == false) then
            return nil, "option_disabled"
        end

        if v >= 0 then
            if modType == 23 or modType == 24 then
                local wheelCosts = type(profile.wheelTypeCost) == "table" and profile.wheelTypeCost or {}
                local key = WHEEL_TYPE_KEYS[math.floor(tonumber(wheelType) or -1)] or "sport"
                valueEntry = wheelCosts[key] or wheelCosts.sport
                cost = priceOf(ctx, valueEntry)
            elseif stage and type(stage.cost) == "table" then
                valueEntry = stage.cost[v + 1]
                if valueEntry == nil then return nil, "invalid_value" end
                cost = priceOf(ctx, valueEntry)
            elseif appearance then
                valueEntry = appearance
                cost = priceOf(ctx, appearance.cost)
            end
        end
        itemEntry = valueEntry
    elseif optionId == "wheel_type" then
        return { price = 0 }
    else
        local costCfg = options[optionId]
        if type(costCfg) == "table" and costCfg.enabled == false then
            return nil, "option_disabled"
        end

        if optionId == "stancer_bundle" or optionId:find("^stancer_") then
            local bundle = options.stancer_bundle
            if type(bundle) == "table" and bundle.enabled == false then return nil, "option_disabled" end
            if type(value) ~= "table" then return nil, "invalid_value" end
            cost = priceOf(ctx, resolveOptionCostValue(bundle or {}, nil))
            itemEntry = bundle
        else
            local v = tonumber(value)
            if not v then return nil, "invalid_value" end
            v = math.floor(v)
            local toggle = isToggleOption(optionId)
            if toggle and v ~= 0 and v ~= 1 then return nil, "invalid_value" end

            if (toggle and v == 1) or (not toggle and v >= 0) then
                valueEntry = resolveOptionCostValue(costCfg or {}, v)
                -- A per-value price list without this value would price it at 0.
                if type(costCfg) == "table" and valueEntry == costCfg
                    and (type(costCfg.cost) == "table" or type(costCfg.values) == "table" or type(costCfg.costs) == "table") then
                    return nil, "invalid_value"
                end
                cost = priceOf(ctx, valueEntry)
            end
            itemEntry = valueEntry ~= costCfg and valueEntry or nil
        end

        local requiredItem, removeAfterUse = itemsOf(itemEntry, costCfg)
        return { price = ctx.free and 0 or cost, requiredItem = requiredItem, removeAfterUse = removeAfterUse }
    end

    local requiredItem, removeAfterUse = itemsOf(itemEntry)
    return { price = ctx.free and 0 or cost, requiredItem = requiredItem, removeAfterUse = removeAfterUse }
end

--- Kept for other callers: price of one option value for a job and vehicle model.
function Pricing.CalculateOptionCost(jobName, modelName, optionId, valIndex, instantMode)
    local ctx = Pricing.NewContext(jobName, modelName and GetHashKey(tostring(modelName)) or nil, { instant = instantMode == true })
    local result = Pricing.PriceEntry(ctx, optionId, valIndex)
    return result and result.price or 0
end
