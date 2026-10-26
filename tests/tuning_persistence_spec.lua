-- Run from the workspace root: lua tests/tuning_persistence_spec.lua
-- Tuning that did not stick: a xenon or tyre smoke colour whose switch was never bought, order
-- installs that were only saved by the installer's later full save, custom xenon colours lost by
-- garages, a stale RGB controller colour repainting the neons on every driver entry, and the
-- preview restore after a purchase that became an order.

local stub
stub = setmetatable({}, { __index = function() return stub end, __call = function() return stub end })

local function newEnv(globals)
    local env = setmetatable({}, { __index = function(_, key)
        local value = _G[key]
        if value ~= nil then return value end
        if globals and globals[key] ~= nil then return globals[key] end
        return stub
    end })
    env._G = env
    return env
end

-- ── Server: purchases and order installs ────────────────────────────────────

local saved = {}
local callbacks = {}
local function serverEnv()
    local env = newEnv()
    env.Config = { Jobs = {} }
    env.print = function() end
    env.exports = function() end
    env.json = { encode = function(v) return v end, decode = function(v) return v end }
    env.Sky = {
        Cb = { Register = function(name, fn) callbacks[name] = fn end },
        Math = { Trim = function(s) return (tostring(s):gsub("^%s+", ""):gsub("%s+$", "")) end },
        VehiclePropertyKeys = {
            mods = { [23] = "modFrontWheels", [24] = "modBackWheels" },
            toggles = { [18] = "modTurbo", [20] = "modSmokeEnabled", [22] = "modXenon" }
        },
    }
    env.TuningDB = { SaveVehicleProperties = function(plate, props) saved[#saved + 1] = { plate = plate, props = props }; return true end }
    env.VehicleHistory = { Add = function() end }
    return env
end

local server = serverEnv()
assert(loadfile("sky_mechanicjob/source/server/main.lua", "t", server))()

-- The client's snapshot after the purchase: xenon and tyre smoke switched on by their colours.
local snapshot = {
    xenonColor = 255, customXenonColor = { 10, 200, 255 }, tyreSmokeColor = { 255, 0, 0 },
    toggleMods = { ["18"] = false, ["20"] = true, ["22"] = true },
    neonEnabled = { true, true, false, false }, neonColor = { 0, 255, 0 }
}

-- 1. An instant purchase saves the parts in the basket (the xenon switch is its own part) and only those.
server.Functions = setmetatable({
    GetNearbyVehicleByPlate = function() return 5 end,
    NormalizePlate = function(plate) return (tostring(plate):gsub("^%s+", ""):gsub("%s+$", "")):upper() end,
    RemoveMoney = function() return true end,
}, { __index = function() return function() return nil end end })
server.GetEntityModel = function() return 1 end
server.GetPlayerPed = function() return 7 end
server.GetEntityCoords = function() return setmetatable({}, { __sub = function() return setmetatable({}, { __len = function() return 0 end }) end }) end
server.Pricing = {
    IsFeatureEnabled = function() return true end,
    NewContext = function() return {} end,
    IsFreeVehicle = function() return false end,
    PriceEntry = function() return { price = 0 } end,
    GetSetting = function() return nil end,
}
server.Config.InstantTuning = { locations = { { coords = { x = 0, y = 0, z = 0 } } } }
local res = callbacks["sky_mechanicjob:tuning:purchase"](1, {
    plate = "ABC123", instantTuning = true, method = "cash",
    parts = { { id = "xenon_color", value = 255 }, { id = "toggle_22", value = 1 }, { id = "tire_smoke_color", value = 1 } },
    properties = snapshot
})
assert(res.success and res.appliedDirect, "instant purchase failed: " .. tostring(res.error))
local props = saved[#saved].props
assert(props.xenonColor == 255 and props.customXenonColor[2] == 200, "xenon colour not saved")
assert(props.modXenon == true and props.toggleMods["22"] == true, "the xenon lights are saved off")
assert(props.tyreSmokeColor[1] == 255 and props.modSmokeEnabled == nil, "a switch that was not bought was saved")
assert(props.modTurbo == nil and props.toggleMods["18"] == nil, "a part that was not bought was saved")

-- 1b. With publicUsersSeePrices off, public users see 0 prices: their order is not charged.
local charged = 0
server.Functions.RemoveMoney = function(_, _, amount) charged = charged + amount; return true end
server.Functions.IsMechanic = function() return false end
server.Functions.GetIdentifier = function() return "CID1" end
server.Functions.GetName = function() return "Customer" end
server.Functions.IsMechanicJobName = function() return false end
server.Pricing.PriceEntry = function() return { price = 900 } end
server.Pricing.GetSetting = function(key) if key == "publicUsersSeePrices" then return false end end
local inserted
server.MySQL = { insert = { await = function(_, params) inserted = params; return 77 end }, update = { await = function() return 1 end } }
res = callbacks["sky_mechanicjob:tuning:purchase"](1, { plate = "ABC123", method = "cash", parts = { { id = "toggle_18", value = 1 } } })
assert(res.success and res.order == 77, "the order was not created: " .. tostring(res.error))
assert(charged == 0 and inserted[8] == 0 and inserted[9] == "free", "a public user was charged a price they never saw")
-- Mechanics (and servers that show the prices) pay as before.
server.Functions.IsMechanic = function() return true end
res = callbacks["sky_mechanicjob:tuning:purchase"](1, { plate = "ABC123", method = "cash", parts = { { id = "toggle_18", value = 1 } } })
assert(res.success and charged == 900, "a mechanic's order was not charged")
server.Functions.IsMechanic = function() return false end
server.Pricing.GetSetting = function() return nil end
res = callbacks["sky_mechanicjob:tuning:purchase"](1, { plate = "ABC123", method = "cash", parts = { { id = "toggle_18", value = 1 } } })
assert(res.success and charged == 1800, "visible prices were not charged")

-- 2. An order install saves the installed part on the server (only that part).
saved = {}
local order = { id = 12, job = "mechanic", plate = "ABC123", items = "<items>", status = "pending" }
local part = { id = "toggle_18", value = 1, installed = false }
server.getInstallablePart = nil
do
    -- getInstallablePart is local to main.lua; drive completeInstall through the real one with fakes.
    server.Functions.IsMechanicOnDuty = function() return true end
    server.Functions.GetJob = function() return "mechanic" end
    server.Functions.IsMechanicJobName = function() return true end
    server.Functions.HasItem = function() return true end
    server.Functions.RemoveItem = function() return true end
    server.MySQL = {
        single = { await = function() return order end },
        update = { await = function() return 1 end },
        query = { await = function() return {} end },
        insert = { await = function() return 1 end },
    }
    server.json.decode = function(v) if v == "<items>" then return { part } end return v end
    server.json.encode = function() return "<items2>" end
    server.NetworkGetEntityOwner = function() return 1 end
    server.NetworkGetNetworkIdFromEntity = function() return 55 end
end
local installSnapshot = { toggleMods = { ["18"] = true, ["22"] = false }, xenonColor = 0, neonColor = { 1, 2, 3 } }
res = callbacks["sky_mechanicjob:orders:completeInstall"](1, { orderId = 12, partIndex = 1, properties = installSnapshot })
assert(res.success, "install refused: " .. tostring(res.error))
assert(#saved == 1 and saved[1].plate == "ABC123", "the installed part was not saved by the server")
assert(saved[1].props.modTurbo == true and saved[1].props.toggleMods["18"] == true, "the turbo is not saved")
assert(saved[1].props.modXenon == nil and saved[1].props.xenonColor == nil and saved[1].props.neonColor == nil, "parts of the snapshot that were not installed were saved")

-- ── Server: custom xenon colour kept in the tuning record ───────────────────

local tuningWrites, tuningRecord = {}, nil
local db = setmetatable({}, { __index = _G })
db.Config = {}
db.Functions = { GetFramework = function() return "qbox" end }
db.Sky = { Math = { Trim = function(s) return (tostring(s):gsub("^%s+", ""):gsub("%s+$", "")) end }, VehiclePropertyKeys = { mods = {}, toggles = {} } }
db.json = { encode = function(v) return v end, decode = function(v) return v end }
db.os = os
db.MySQL = {
    single = { await = function(query)
        if query:find("FROM player_vehicles", 1, true) then return { mods = {} } end
        if query:find("FROM sky_mechanic_vehicle_tuning", 1, true) then return tuningRecord end
        return nil
    end },
    update = { await = function() return 1 end },
    query = { await = function(query, params)
        if query:find("SELECT plate FROM player_vehicles", 1, true) then return { { plate = params["@plate"] } } end
        if query:find("INSERT INTO sky_mechanic_vehicle_tuning", 1, true) then
            tuningWrites[#tuningWrites + 1] = params
            tuningRecord = { plate = params["@plate"], tuning = params["@tuning"] }
        end
        return {}
    end },
}
assert(loadfile("sky_mechanicjob/source/server/tuning_db.lua", "t", db))()
db.TuningDB.SaveVehicleProperties("ABC123", { xenonColor = 255, customXenonColor = { 10, 200, 255 } })
assert(#tuningWrites == 1 and tuningWrites[1]["@tuning"].xenonCustom[3] == 255, "the custom xenon colour is not kept")
local loaded = db.TuningDB.GetVehicleProperties("ABC123")
assert(loaded._skyMechanicTuning.xenonCustom[2] == 200, "the custom xenon colour is not sent back on load")
-- A standard xenon colour clears it; snapshots without xenon data leave it alone.
db.TuningDB.SaveVehicleProperties("ABC123", { neonColor = { 1, 2, 3 } })
assert(#tuningWrites == 1, "a save without xenon data touched the record")
db.TuningDB.SaveVehicleProperties("ABC123", { xenonColor = 3 })
assert(#tuningWrites == 2 and tuningWrites[2]["@tuning"].xenonCustom == nil, "a standard xenon colour kept the custom one")
db.TuningDB.SaveVehicleProperties("ABC123", { xenonColor = 3 })
assert(#tuningWrites == 2, "nothing to clear, yet the record was written again")

-- ── Client: driver entry ────────────────────────────────────────────────────

local function clientEnv(record, xenonOn, xenonIndex)
    local calls = { neonColour = 0, customXenon = nil }
    local env = newEnv()
    env.Sky = { Cb = { Trigger = function() return { success = true, properties = { _skyMechanicTuning = record } } end }, Math = { Trim = function(s) return s end } }
    env.GetVehicleNumberPlateText = function() return "ABC123" end
    env.Entity = function() return { state = {} } end
    env.IsToggleModOn = function(_, mod) return mod == 22 and xenonOn end
    env.GetVehicleXenonLightsColor = function() return xenonIndex end
    env.XenonSync = { SetCustomColor = function(_, color) calls.customXenon = color end }
    env.StanceKit = { HasPendingPersist = function() return false end, BuildPersistedState = function() return nil end, ApplyPersistedState = function() end }
    env.NitroSystem_ApplyPersistedStateToVehicle = function() end
    env.AntiLag = { ApplyPersistedStateToVehicle = function() end }
    env.TwoStep = { ApplyPersistedStateToVehicle = function() end }
    env.CustomTuning = { ApplyPersistedState = function() end }
    env.RgbController = {
        NEON_EFFECT_MODES = { off = 0 }, XENON_EFFECT_MODES = { off = 0 },
        BindNeonEffectVehicle = function() end, BindXenonEffectVehicle = function() end,
        SetNeonBaseColor = function() end, SetXenonBaseColor = function() end,
        SetNeonSpeed = function() end, SetXenonSpeed = function() end,
        SetNeonMode = function(_, mode) if mode == 0 then calls.neonColour = calls.neonColour + 1 end end,
        SetXenonMode = function() end,
    }
    env.CreateThread = function() end
    env.AddEventHandler = function() end
    env.RegisterNetEvent = function() end
    assert(loadfile("sky_mechanicjob/source/client/vehicle_persistence.lua", "t", env))()
    env.isOpenInTuningMenu = function() return false end
    return env, calls
end

-- 3. A stale RGB controller record with its effect off leaves the car's neon colour alone.
local env, calls = clientEnv({ rgb = { neon = { mode = 0, color = { r = 255, g = 0, b = 0 } } } }, false, 255)
env.VehiclePersistence.LoadForVehicle(9)
assert(calls.neonColour == 0, "the RGB controller's old neon colour was painted over the car's")

-- 4. The kept custom xenon colour goes back on when the garage restored the lights.
env, calls = clientEnv({ xenonCustom = { 10, 200, 255 } }, true, 255)
env.VehiclePersistence.LoadForVehicle(9)
assert(calls.customXenon and calls.customXenon.g == 200, "the custom xenon colour was not put back")
-- ...but not over a standard colour or with the lights off.
env, calls = clientEnv({ xenonCustom = { 10, 200, 255 } }, true, 3)
env.VehiclePersistence.LoadForVehicle(9)
assert(calls.customXenon == nil, "a custom xenon colour replaced a standard one")
env, calls = clientEnv({ xenonCustom = { 10, 200, 255 } }, false, 255)
env.VehiclePersistence.LoadForVehicle(9)
assert(calls.customXenon == nil, "a custom xenon colour with the lights off")

-- ── Client: a colour that turns its lights / smoke on puts the switch in the basket ──

do
    local sent = {}
    local wc = newEnv()
    wc.Sky = { Debug = function() end }
    wc.DoesEntityExist = function() return true end
    wc.IsToggleModOn = function() return false end
    wc.GetGameTimer = function() return 0 end
    wc.GetVehicleClass = function() return 0 end
    wc.sendUi = function(action, payload) sent[#sent + 1] = { action = action, payload = payload } end
    assert(loadfile("sky_mechanicjob/source/client/wheel_change.lua", "t", wc))()
    local xenonSwitch = { id = "toggle_22", kind = "toggle", modType = 22, value = 0 }
    local smokeSwitch = { id = "toggle_20", kind = "toggle", modType = 20, value = 0 }
    wc.TuningState = { vehicle = 9, optionMap = { toggle_22 = xenonSwitch, toggle_20 = smokeSwitch }, suppressPreviews = false }
    wc.XENON_COLOR_PRESETS = {}
    wc.TIRE_SMOKE_PRESETS = {}
    assert(wc.applyOption({ id = "xenon_color", kind = "color", value = 3 }, 3))
    assert(xenonSwitch.value == 1, "the xenon switch did not follow its colour")
    assert(sent[1] and sent[1].action == "tuning:update" and sent[1].payload.id == "toggle_22" and sent[1].payload.value == 1)
    assert(wc.applyCustomColorOption({ id = "tire_smoke_color", kind = "color", value = 1, supportsCustom = true }, 0, { r = 255, g = 0, b = 0 }))
    assert(smokeSwitch.value == 1, "the tyre smoke switch did not follow its colour")
    -- Putting a car back (previews suppressed) changes the switch without telling the menu.
    xenonSwitch.value, wc.TuningState.suppressPreviews, sent = 0, true, {}
    wc.applyOption({ id = "xenon_color", kind = "color", value = 3 }, 3)
    assert(xenonSwitch.value == 1 and #sent == 0)
end

-- ── Client: putting the car back after a purchase that became an order ──────

local applied = {}
local orders = newEnv()
orders.Sky = { Debug = function() end }
orders.DoesEntityExist = function() return true end
assert(loadfile("sky_mechanicjob/source/client/orders.lua", "t", orders))()
orders.applyOption = function(opt, value) applied[#applied + 1] = opt.id .. "=" .. tostring(value) end
orders.applyCustomColorOption = function(opt) applied[#applied + 1] = opt.id .. "=custom" end
local function option(id, value, extra)
    local opt = { id = id, value = value, min = -1, max = 300, kind = "mod" }
    for k, v in pairs(extra or {}) do opt[k] = v end
    return opt
end
local opts = {
    option("toggle_18", 1, { kind = "toggle" }),
    option("toggle_22", 0, { kind = "toggle" }),
    option("xenon_color", 5),
    option("mod_23", 4),
    option("wheel_type", 2),
    option("mod_1", 0),
    option("stancer_track_width_front", 95, { kind = "stancer" }),
}
orders.TuningState = { vehicle = 9, options = opts, optionMap = {}, optionBaselines = {} }
for _, opt in ipairs(opts) do orders.TuningState.optionMap[opt.id] = opt end
-- Baselines: turbo off, xenon off (colour 255), rim 4 on wheel type 0, no stance change.
local base = { toggle_18 = 0, toggle_22 = 0, xenon_color = 255, mod_23 = 4, wheel_type = 0, mod_1 = 0, stancer_track_width_front = 80 }
for id, value in pairs(base) do orders.TuningState.optionBaselines[id] = { value = value } end
assert(orders.restoreVehicleToOptionBaselines())
local order = table.concat(applied, ",")
assert(order:find("^wheel_type=0,"), "the wheel type is not put back first: " .. order)
assert(order:find("toggle_18=0", 1, true) and order:find("xenon_color=255", 1, true), order)
assert(order:find("mod_23=4", 1, true), "the rim is not put back after the wheel type: " .. order)
assert(order:find("xenon_color=255.*toggle_22=0"), "the xenon switch is not put back after its colour: " .. order)
assert(not order:find("mod_1=", 1, true), "an unchanged option was re-applied: " .. order)
assert(not order:find("stancer", 1, true), "the stance is re-applied here: " .. order)

print("PASS: a xenon / tyre smoke colour puts its switch in the basket (charged and saved like any part), hidden public prices are not charged, order installs saved by the server (that part only), custom xenon colours kept and put back, no stale RGB neon colour on driver entry, the post-purchase restore puts back only what changed (wheel type before rims, switches after colours).")
