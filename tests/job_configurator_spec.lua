-- Run from the workspace root: lua tests/job_configurator_spec.lua
-- Builds the "Mechanic Jobs" configurator schema from sky_mechanicjob's real config files and
-- checks what sky_jobs_base's server sends to the NUI and stores when settings are saved.

local function vector3(x, y, z)
    return setmetatable({ x = x, y = y, z = z }, { __name = "vector3" })
end

-- A stand-in for globals a file touches but this spec does not check (natives, frameworks).
local stub
stub = setmetatable({}, {
    __index = function() return stub end,
    __call = function() return stub end,
})

-- Tables the scripts create with `Name = Name or {}`; each environment gets its own.
local MODULE_GLOBALS = {
    Config = true, Locales = true, Functions = true, Pricing = true, MechanicWorkshopData = true, MechanicTheft = true
}

local function newEnv(resource, side)
    local f = { exports = {}, callbacks = {}, events = {}, clientEvents = {}, row = nil, saved = nil }
    local env = setmetatable({}, { __index = function(_, key)
        local value = _G[key]
        if value ~= nil or MODULE_GLOBALS[key] then return value end
        return stub
    end })
    env._G = env
    env.vector3 = vector3
    env.type = function(value)
        local mt = getmetatable(value)
        if mt and mt.__name == "vector3" then return "vector3" end
        return type(value)
    end
    env.SkyDiagnostics = false
    env.GetCurrentResourceName = function() return resource end
    env.IsDuplicityVersion = function() return side == "server" end
    env.GetResourceState = function(name) return (f.stopped and f.stopped[name]) and "stopped" or "started" end
    env.GetGameTimer = function() return 0 end
    env.print = function() end
    env.CreateThread = function() end
    env.SetTimeout = function() end
    env.Wait = function() end
    env.Citizen = { CreateThread = env.CreateThread, SetTimeout = env.SetTimeout, Wait = env.Wait }
    env.AddEventHandler = function(name, fn)
        f.events[name] = f.events[name] or {}
        table.insert(f.events[name], fn)
    end
    env.RegisterNetEvent = function(name, fn) if fn then env.AddEventHandler(name, fn) end end
    env.RegisterServerEvent = env.RegisterNetEvent
    env.RegisterCommand = function() end
    env.TriggerEvent = function() end
    env.TriggerClientEvent = function(name, target, ...)
        f.clientEvents[#f.clientEvents + 1] = { name = name, target = target, args = table.pack(...) }
    end
    env.json = {
        encode = function(value) f.encoded = value; return "<json>" end,
        decode = function(text) return text == "<json>" and f.encoded or nil end,
    }
    env.MySQL = {
        query = { await = function(query, params)
            if query:find("INSERT INTO sky_jobs_creator_data", 1, true) then
                f.saved = f.encoded
                f.row = { data = params["@data"] }
            end
            return {}
        end },
        single = { await = function(query)
            if query:find("creator_key = 'workshopcreator'", 1, true) then return f.row end
            return nil
        end },
        insert = { await = function() return 1 end },
        update = { await = function() return 1 end },
        scalar = { await = function() return nil end },
        prepare = { await = function() return nil end },
        transaction = { await = function() return true end },
    }
    env.Sky = {
        Cb = { Register = function(name, fn) f.callbacks[name] = fn end },
        Config = { locale = "en" },
    }
    env.exports = setmetatable({}, {
        __call = function(_, name, fn) f.exports[name] = fn end,
        __index = function(_, name)
            if f.external and f.external[name] then return f.external[name] end
            return stub
        end,
    })
    function f.load(path) assert(loadfile(path, "t", env))() end
    f.env = env
    return f
end

local function keys(list, field)
    local result = {}
    for _, entry in ipairs(list) do result[#result + 1] = entry[field] end
    return table.concat(result, ",")
end

-- Values that reach the NUI must be plain data (no vectors or functions).
local function assertPlain(value, path)
    local valueType = type(value)
    if valueType == "table" then
        assert(getmetatable(value) == nil, path .. " is not a plain table")
        for k, v in pairs(value) do assertPlain(v, path .. "." .. tostring(k)) end
    else
        assert(valueType == "string" or valueType == "number" or valueType == "boolean", path .. " is a " .. valueType)
    end
end

-- 1. The mechanic resource builds the schema from its own config.lua / adv_config.lua.
local mech = newEnv("sky_mechanicjob", "server")
mech.load("sky_mechanicjob/config/init.lua")
mech.load("sky_mechanicjob/config/config.lua")
mech.load("sky_mechanicjob/config/adv_config.lua")
mech.load("sky_mechanicjob/source/server/job_configurator.lua")
local Config = mech.env.Config
local schema = assert(mech.exports.GetJobConfiguratorSchema(), "schema export missing")
assertPlain(schema, "schema")
assert(schema.titleKey == "workshopConfig.configs.sky_mechanicjob.title")

-- Sidebar sections in the order of the reference screenshot (Instant Tuning is hidden while
-- its feature is off).
local sections, seen = {}, {}
local globalTuning = {}
local delivery = {}
local byKey = {}
for _, def in ipairs(schema.settingDefinitions) do
    assert(type(def.key) == "string" and not byKey[def.key], "duplicate setting " .. tostring(def.key))
    byKey[def.key] = def
    if def.extension then
        delivery[#delivery + 1] = def.key
    elseif not def.section or def.section == "tuning" then
        globalTuning[#globalTuning + 1] = def.key
    elseif not seen[def.section] then
        seen[def.section] = true
        sections[#sections + 1] = def.section
    end
end
assert(table.concat(sections, ",") == "partsTheft,vehicleCare,wear,wheelDamage,mileageHud,instantTuning,carryItems", table.concat(sections, ","))
assert(table.concat(globalTuning, ",") == "addRevenueToSociety,publicUsersSeePrices,fallbackVehicleValue,priceType,freeVehicles", table.concat(globalTuning, ","))
assert(byKey.instantTuningLabel.featureKey == "instantTuning" and byKey.wheelDamageDefaultMultiplier.featureKey == "wheelDamage")
assert(byKey.carryItems.featureKey == nil and byKey.partsTheftItem.featureKey == nil)
-- The pricing box renders a select only for type "string" with options.
assert(byKey.priceType.type == "string" and #byKey.priceType.options == 2)
assert(byKey.freeVehicles.type == "stringList" and byKey.fallbackVehicleValue.type == "number")
for _, key in ipairs(delivery) do assert(byKey[key].extension == "partsDeliveryShop") end
assert(#delivery == 6)

-- Every label, section and option key exists in sky_jobs_base's English locale.
local jobsLocale = newEnv("sky_jobs_base", "client")
jobsLocale.env.Locales = {}
jobsLocale.load("sky_jobs_base/config/locales/en.lua")
local nui = jobsLocale.env.Locales.en.Nui
local function lookup(path)
    local node = nui
    for part in path:gmatch("[^%.]+") do
        if type(node) ~= "table" then return nil end
        node = node[part]
    end
    return node
end
for _, def in ipairs(schema.settingDefinitions) do
    assert(type(lookup(def.labelKey)) == "string", "missing locale " .. def.labelKey)
    if def.section then assert(type(lookup(def.sectionLabelKey)) == "string", "missing locale " .. def.sectionLabelKey) end
    for _, column in ipairs(def.columns or {}) do
        if column.labelKey then assert(type(lookup(column.labelKey)) == "string", "missing locale " .. column.labelKey) end
        for _, option in ipairs(column.options or {}) do
            if option.labelKey then assert(type(lookup(option.labelKey)) == "string", "missing locale " .. option.labelKey) end
        end
    end
    for _, option in ipairs(def.options or {}) do
        assert(type(lookup(option.labelKey)) == "string", "missing locale " .. option.labelKey)
    end
end
for _, feature in ipairs(schema.featureDefinitions) do
    assert(type(lookup(feature.labelKey)) == "string", "missing locale " .. feature.labelKey)
end
for _, extension in ipairs(schema.extensions) do
    assert(type(lookup(extension.labelKey)) == "string", "missing locale " .. extension.labelKey)
end
assert(lookup(schema.titleKey) == "Mechanic Jobs")
-- Entries are named after the script ("Workshops", "Edit workshop") in English.
assert(lookup("workshopConfig.sidebar.entries") == nil and lookup("workshopConfig.editor.editTitle") == nil)

-- Defaults are config.lua's values.
local defaults = schema.defaultSettings
assert(defaults.partsTheftItem == Config.PartsTheft.item and defaults.partsTheftStolenWheelItem == Config.PartsTheft.stolenWheelItem)
assert(defaults.partsTheftDealerSellDistance == Config.PartsTheft.dealer.sellDistance)
assert(#defaults.partsTheftDealerItems == #Config.PartsTheft.dealer.items)
assert(defaults.wheelDamageOffroadWheelsMultiplier == Config.WheelDamage.multipliers.offroadWheels)
assert(#defaults.wheelDamageVehicleClassMultipliers == 23 and defaults.wheelDamageVehicleClassMultipliers[1].classId == 0)
assert(defaults.wheelDamageVehicleClassMultipliers[1].multiplier == Config.WheelDamage.multipliers.vehicleClasses[0])
assert(#defaults.wearParts == 13 and defaults.wearParts[1].key == "tyres" and defaults.wearParts[1].removeAfterUse == true)
assert(defaults.wearParts[5].key == "engine_oil" and defaults.wearParts[5].flow == "oil_change")
assert(#defaults.vehicleCareRepairWearParts == 13 and defaults.vehicleCareRepairWearParts[1].repair == true)
assert(defaults.mileageHudPositionLeft == Config.MileageHud.position.left and defaults.mileageHudPositionRight == "")
assert(defaults.partsDeliveryTimerHudPositionTop == Config.PartsDelivery.timerHud.position.top)
assert(defaults.fallbackVehicleValue == Config.TuningCostProfile.fallbackVehicleValue)
local carryByItem = {}
for _, row in ipairs(defaults.carryItems) do carryByItem[row.item] = row end
assert(carryByItem.engine.transport == "engine_lift" and carryByItem.engine.prop == Config.CarryItems.items.engine.prop)
assert(carryByItem.wheels.transport == "hand" and carryByItem.wheels.ry == 90.0)
assert(schema.defaultFeatures.nitro == Config.ToggleFeatures.nitro)
for _, def in ipairs(schema.settingDefinitions) do
    if def.type ~= "screenPosition" then
        assert(defaults[def.key] ~= nil, "no default for " .. def.key)
    end
end

-- Workshop tabs: Parts Delivery (item list) and Tuning Prices (tuning cost editor).
assert(keys(schema.extensions, "key") == "partsDeliveryShop,tuningCostProfile")
assert(schema.extensions[1].type == "itemList" and #schema.extensions[1].fields == 4)
assert(#schema.extensions[1].defaultValue == #Config.Jobs[1].partsDeliveryShop)
assert(schema.extensions[2].type == "jsonObject" and schema.extensions[2].editor == "tuningCostProfile")
assert(schema.extensions[2].defaultValue.performanceStages.armor.modType == 16)

-- Interactions page: Config.Interactions with plain marker offsets.
assert(keys(schema.interactionDefinitions, "id") == "self_service_tuning,workshop_lift,engine_hoist_location,part_delivery,stolen_parts_dealer")
assert(schema.interactionDefinitions[1].marker.offset.x == 0.0 and schema.interactionDefinitions[1].label == "Self Service Tuning")

-- 2. sky_jobs_base sends the full context and stores typed values.
local jobs = newEnv("sky_jobs_base", "server")
jobs.external = { sky_mechanicjob = { GetJobConfiguratorSchema = function() return mech.exports.GetJobConfiguratorSchema() end } }
jobs.env.Sky_Jobs = { HasPermission = function() return true end, Creator = { SetCachedData = function() end } }
jobs.load("sky_jobs_base/config/init.lua")
jobs.load("sky_jobs_base/config/config.lua")
jobs.load("sky_jobs_base/source/server/jobs.lua")
local list = assert(jobs.callbacks["sky_jobs_base:jobConfigurator:list"], "list callback missing")

local res = list(1, { configKey = "sky_mechanicjob" })
assert(res.success and res.data.titleKey == "workshopConfig.configs.sky_mechanicjob.title")
assert(res.data.entityPluralLabel == "Workshops" and #res.data.creatorSections == 0)
assert(#res.data.settingDefinitions == #schema.settingDefinitions and #res.data.extensions == 2)
assert(#res.data.interactionDefinitions == 5 and res.data.defaultSettings.partsTheftItem == Config.PartsTheft.item)
-- Unsaved settings fall back to config.lua; the default workshops are listed.
assert(res.data.settings.partsTheftItem == Config.PartsTheft.item and res.data.settings.wearParts[1].key == "tyres")
assert(#res.data.configs == 2 and res.data.configs[1].settings == nil)

-- A stored copy of a default must not change when a later load fills it in again.
res.data.settings.wearParts[1].kilometersToZero = 1
assert(list(1, {}).data.settings.wearParts[1].kilometersToZero == Config.Wear.parts.tyres.kilometersToZero)

-- Saving settings stores numbers as numbers (the NUI sends "50000.0").
local saveSettings = jobs.callbacks["sky_jobs_base:jobConfigurator:saveSettings"]
local wear = list(1, {}).data.settings.wearParts
wear[1].kilometersToZero = "900.0"
wear[1].removeAfterUse = false
local saved = saveSettings(1, { configKey = "sky_mechanicjob", settings = {
    fallbackVehicleValue = "75000.0",
    partsTheftDealerSellDistance = "7.5",
    vehicleCareRepairDurationMs = "12000.9",
    partsTheftDispatchJobs = { " police ", "", "police", "sheriff" },
    partsTheftRemoveItemAfterUse = true,
    wearParts = wear,
    carryItems = { { item = "engine", transport = "engine_lift", prop = "prop_car_engine_01", bone = "28422", x = "0.1" } },
    mileageHudPositionLeft = "3vh",
} })
assert(saved.success)
local stored = jobs.saved.settings
assert(stored.fallbackVehicleValue == 75000 and math.type(stored.fallbackVehicleValue) ~= nil)
assert(stored.partsTheftDealerSellDistance == 7.5 and stored.vehicleCareRepairDurationMs == 12000)
assert(table.concat(stored.partsTheftDispatchJobs, ",") == "police,sheriff")
assert(stored.wearParts[1].kilometersToZero == 900 and stored.wearParts[1].removeAfterUse == false)
assert(stored.carryItems[1].bone == 28422 and stored.carryItems[1].x == 0.1)
assert(stored.mileageHudPositionLeft == "3vh" and stored.partsTheftRemoveItemAfterUse == true)
-- Settings that were not sent keep their value.
assert(stored.partsTheftItem == Config.PartsTheft.item)

-- The sync to the clients carries the interactions for the Interactions page.
local sync = jobs.clientEvents[#jobs.clientEvents]
assert(sync.name == "sky_jobs_base:jobConfigurator:updated" and sync.args[1] == "sky_mechanicjob")
assert(type(sync.args[5]) == "table")
assert(jobs.saved.settingsVersion == 2)

-- Older saves stored sky_jobs_base's former built-in defaults; the ones that contradict
-- config.lua are dropped once (settings version 2), other saved values stay.
local loadData = jobs.env.Sky_Jobs.Configurator.LoadWorkshopData
jobs.encoded = { entries = {}, settings = {
    partsTheftItem = "lockpick", partsTheftDispatchJobs = { "police" }, partsTheftDealerAccount = "bank",
    wheelDamageOffroadWheelsMultiplier = 0.5,
} }
jobs.row = { data = "<json>" }
local cleaned, dropped = loadData()
assert(dropped == true and cleaned.settingsVersion == 2)
assert(cleaned.settings.partsTheftItem == Config.PartsTheft.item and cleaned.settings.partsTheftDealerAccount == "bank")
assert(table.concat(cleaned.settings.partsTheftDispatchJobs, ",") == table.concat(defaults.partsTheftDispatchJobs, ","))
assert(cleaned.settings.wheelDamageOffroadWheelsMultiplier == defaults.wheelDamageOffroadWheelsMultiplier)
-- From version 2 on the same value was chosen in the configurator and stays.
jobs.encoded = { entries = {}, settingsVersion = 2, settings = { partsTheftItem = "lockpick" } }
cleaned, dropped = loadData()
assert(dropped == false and cleaned.settings.partsTheftItem == "lockpick")

-- Without the mechanic resource the configurator still opens (workshops and features only).
jobs.external = nil
jobs.stopped = { sky_mechanicjob = true }
for _, handler in ipairs(jobs.events.onResourceStop or {}) do handler("sky_mechanicjob") end
res = list(1, {})
assert(res.success and #res.data.settingDefinitions == 0 and #res.data.featureDefinitions == 10)

-- 3. The mechanic server uses the saved workshops like its clients do: Tuning Prices for the
-- prices it charges, Parts Delivery for the parts shop, Shop/Props/Vehicles for the job registry.
local server = newEnv("sky_mechanicjob", "server")
server.load("sky_mechanicjob/config/init.lua")
server.load("sky_mechanicjob/config/config.lua")
server.load("sky_mechanicjob/config/adv_config.lua")
server.load("sky_mechanicjob/source/config_overrides.lua")
server.load("sky_mechanicjob/source/server/job_configurator.lua")
local LuaJob = server.env.Config.Jobs[1]
local luaTheftItem = server.env.Config.PartsTheft.item
local pending, fired, registered = {}, {}, {}
server.env.CreateThread = function(fn) pending[#pending + 1] = fn end
server.env.TriggerEvent = function(name, ...)
    fired[#fired + 1] = name
    for _, handler in ipairs(server.events[name] or {}) do handler(...) end
end
server.env.Functions = setmetatable({
    GetConfiguratorJobNames = function() return { "mechanic", "Los Santos Customs", "tuners" } end,
    GetJob = function(src) return src == 1 and "tuners" or "mechanic" end,
    IsMechanic = function() return true end,
}, { __index = function() return stub end })
server.env.Sky.FW = { DoesJobExist = function(name) return name == "mechanic" or name == "tuners" end }
server.external = { sky_jobs_base = {
    RegisterTabletApps = function() return true end,
    RegisterJobs = function(_, _, defs)
        registered = {}
        for _, def in ipairs(defs) do registered[def.name] = def end
        return true
    end,
    HasJobPermission = function() return false end,
} }
local tunersProfile = { performanceStages = { engine = { modType = 11, cost = { 1, 2, 3, 4 } } } }
server.encoded = {
    entries = {
        -- Saved by the editor without items: the config.lua lists stay.
        { id = "lsc", name = "Los Santos Customs", jobKey = "mechanic", job = "mechanic", shop = {}, props = {}, vehicles = {} },
        { id = "tuners", name = "tuners", jobKey = "tuners", job = "tuners", color = "#ff0000",
          tuningCostProfile = tunersProfile,
          partsDeliveryShop = { { name = "turbo", label = "Turbo", price = "999", category = "Engine" } },
          shop = { { name = "engine_oil", label = "Oil", price = 5 } } },
    },
    settings = {
        partsTheftItem = "lockpick",
        wearParts = { { key = "tyres", kilometersToZero = 900, item = "tyre_kit", removeAfterUse = false, flow = "wheel" } },
        instantTuningLocations = { { x = 1.0, y = 2.0, z = 3.0, heading = 90.0 } },
    },
    features = {},
}
server.row = { data = "<json>" }
server.load("sky_mechanicjob/source/server/pricing.lua")
local loadWorkshops = pending[1]
server.load("sky_mechanicjob/source/server/tablet_apps.lua")
server.load("sky_mechanicjob/source/server/parts_delivery.lua")
local Pricing = server.env.Pricing

-- Before the saved workshops are read, config.lua decides.
assert(Pricing.GetJobConfig("tuners") == LuaJob and Pricing.FindJobConfig("tuners") == nil)
loadWorkshops()
assert(fired[#fired] == "sky_mechanicjob:server:jobConfiguratorLoaded")
assert(Pricing.GetJobCostProfile("tuners") == tunersProfile)
-- A workshop without its own prices keeps the profile of its config.lua job.
assert(Pricing.GetJobCostProfile("mechanic") == LuaJob.tuningCostProfile)
assert(Pricing.GetJobConfig("Los Santos Customs").id == "lsc" and Pricing.GetJobConfig("unknown").id == "lsc")
assert(Pricing.NewContext("tuners", nil, { free = true }).profile == tunersProfile)

-- The tablet's parts shop lists the workshop's Parts Delivery tab.
local getCatalog = server.callbacks["sky_mechanicjob:partsDelivery:getCatalog"]
local catalog = getCatalog(1, {}).data.items
assert(#catalog == 1 and catalog[1].name == "turbo" and catalog[1].price == 999)
assert(#getCatalog(2, {}).data.items == #LuaJob.partsDeliveryShop)

-- The job registry (wholesale shop, props, garage) gets the workshops' tabs; display names
-- that are no job are skipped.
assert(registered.tuners and registered.mechanic and not registered["Los Santos Customs"])
assert(registered.tuners.shop[1].name == "engine_oil" and registered.tuners.color == "#ff0000")
assert(registered.mechanic.shop == LuaJob.shop and registered.mechanic.vehicles == LuaJob.vehicles)

-- The saved settings replace config.lua on the server as on the clients (theft tool, wear
-- part items, instant tuning locations), while the configurator's defaults stay config.lua's.
local ServerConfig = server.env.Config
assert(ServerConfig.PartsTheft.item == "lockpick" and ServerConfig.Wear.parts.tyres.item == "tyre_kit")
assert(ServerConfig.Wear.parts.tyres.removeAfterUse == false and ServerConfig.Wear.parts.tyres.kilometersToZero == 900)
assert(#ServerConfig.InstantTuning.locations == 1 and ServerConfig.InstantTuning.locations[1].coords.y == 2.0)
assert(server.exports.GetJobConfiguratorSchema().defaultSettings.partsTheftItem == luaTheftItem)

-- 4. Applying the defaults leaves config.lua as it is; only defaults the scripts already
-- assume get spelled out (carry transport "hand", an empty instant tuning job list).
local plain = newEnv("sky_mechanicjob", "server")
plain.load("sky_mechanicjob/config/init.lua")
plain.load("sky_mechanicjob/config/config.lua")
plain.load("sky_mechanicjob/config/adv_config.lua")
plain.load("sky_mechanicjob/source/config_overrides.lua")
plain.load("sky_mechanicjob/source/server/job_configurator.lua")
local function copy(value)
    if type(value) ~= "table" or rawequal(value, stub) then return value end
    local result = setmetatable({}, getmetatable(value))
    for k, v in pairs(value) do result[k] = copy(v) end
    return result
end
local pristine = copy(plain.env.Config)
plain.env.ApplyJobConfiguratorSettings(copy(plain.exports.GetJobConfiguratorSchema().defaultSettings))
local changed = {}
local function compare(a, b, path)
    if type(a) == "table" and type(b) == "table" then
        local seen = {}
        for k in pairs(a) do seen[k] = true end
        for k in pairs(b) do seen[k] = true end
        for k in pairs(seen) do compare(a[k], b[k], path .. "." .. tostring(k)) end
    elseif a ~= b then
        changed[#changed + 1] = path
    end
end
for _, section in ipairs({ "PartsTheft", "VehicleCare", "Wear", "WheelDamage", "MileageHud", "PartsDelivery",
    "CarryItems", "InstantTuning", "TuningCostProfile", "OrderInstall", "TuningWorkshopRequirement" }) do
    compare(pristine[section], plain.env.Config[section], section)
end
for _, path in ipairs(changed) do
    assert(path:match("^CarryItems%.items%.[%w_]+%.transport$") or path == "InstantTuning.allowedJobs",
        "applying the configurator defaults changed " .. path)
end

print("PASS: mechanic configurator schema, sections, locale keys, config defaults, workshop tabs, interactions, list context, typed saves, server use of saved workshops and settings.")
