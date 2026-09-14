-- Run from the workspace root: lua tests/diagnostics_spec.lua
local function fixture(resource, server, skipDiagnostics)
    local f = { time = 100, level = 2, logs = {}, events = {}, nui = {}, threads = {}, timers = {}, exports = {}, external = {}, messages = {}, sent = {}, focus = {} }
    local env = setmetatable({}, { __index = _G })
    env._G, f.env = env, env
    env.GetCurrentResourceName = function() return resource end
    env.IsDuplicityVersion = function() return server == true end
    env.GetGameTimer = function() return f.time end
    env.GetConvarInt = function() return f.level end
    env.GetResourceState = function(name) return f.resourceState or "started" end
    env.print = function(text) f.logs[#f.logs + 1] = text end
    env.json = { encode = function(data)
        local entries = {}
        for k, v in pairs(data) do entries[#entries + 1] = tostring(k) .. "=" .. tostring(v) end
        table.sort(entries)
        return table.concat(entries, " ")
    end }
    env.AddEventHandler = function(name, fn)
        f.events[name] = f.events[name] or {}
        table.insert(f.events[name], fn)
        return { key = #f.events[name], name = name }
    end
    -- Match the real Cfx implementation: net registration delegates to AddEventHandler.
    env.RegisterNetEvent = function(name, fn) if fn then return env.AddEventHandler(name, fn) end end
    env.RegisterServerEvent = env.RegisterNetEvent
    env.RegisterNUICallback = function(name, fn) f.nui[name] = fn end
    env.RegisterCommand = function(name, fn, restricted) f.command = { name, fn, restricted }; return 42 end
    env.AddStateBagChangeHandler = function(key, bag, fn) f.statebag = fn; return 43 end
    env.Citizen = {
        CreateThread = function(fn) f.threads[#f.threads + 1] = fn; return #f.threads end,
        SetTimeout = function(delay, fn) f.timers[#f.timers + 1] = { delay, fn }; return #f.timers end,
        Wait = function(delay) return coroutine.yield(delay) end,
    }
    env.Wait = env.Citizen.Wait
    env.CreateThread, env.SetTimeout = env.Citizen.CreateThread, env.Citizen.SetTimeout
    for _, api in ipairs({ "TriggerEvent", "TriggerClientEvent", "TriggerServerEvent" }) do
        env[api] = function(name, ...)
            f.sent[#f.sent + 1] = { api = api, name = name, args = table.pack(...) }
        end
    end
    env.SendNUIMessage = function(data) f.messages[#f.messages + 1] = data end
    env.SetNuiFocus = function(...) f.focus[#f.focus + 1] = table.pack(...) end
    env.SetNuiFocusKeepInput = function(enabled) f.keepInput = enabled end
    env.PerformHttpRequest = function(url, cb, method, data, headers, options)
        f.http = { url = url, cb = cb, method = method, data = data, headers = headers, options = options }
        return 44
    end
    env.exports = setmetatable({}, {
        __call = function(_, name, fn) f.exports[name] = fn end,
        __index = function(_, name) return assert(f.external[name], name) end,
    })
    function f.load(path) assert(loadfile(path, "t", env))() end
    function f.has(text)
        for _, line in ipairs(f.logs) do if line:find(text, 1, true) then return true end end
        return false
    end
    function f.count(text)
        local count = 0
        for _, line in ipairs(f.logs) do if line:find(text, 1, true) then count = count + 1 end end
        return count
    end
    function f.run(fn, ...)
        local thread = coroutine.create(fn)
        local result = table.pack(coroutine.resume(thread, ...))
        while result[1] and coroutine.status(thread) ~= "dead" do
            f.time = f.time + (tonumber(result[2]) or 0)
            result = table.pack(coroutine.resume(thread))
        end
        assert(result[1], tostring(result[2]))
        return table.unpack(result, 2, result.n)
    end
    if not skipDiagnostics then f.load(resource .. "/source/diagnostics.lua") end
    return f
end

-- Runtime wrappers preserve returns, source, yields, errors and native registration values.
do
    local f = fixture("sky_base", true)
    local e, D = f.env, f.env.SkyDiagnostics
    e.source = 27
    local wrapped = D.Wrap("callback", "values", function(a, b, c)
        assert(e.source == 27 and a == 1 and b == nil and c == 3)
        e.Wait(50)
        return nil, false, "done", nil
    end)
    local result = table.pack(f.run(wrapped, 1, nil, 3))
    assert(result.n == 4 and result[1] == nil and result[2] == false and result[3] == "done")
    local originalError = { reason = "sentinel" }
    local ok, err = pcall(D.Wrap("callback", "throws", function() error(originalError) end))
    assert(not ok and err == originalError and f.has("handler.exception"))
    local opaqueRef = setmetatable({}, { __index = function() error("Cannot index a Cfx funcref") end })
    assert(D.Wrap("export", "opaque", function() return opaqueRef end)() == opaqueRef)
    local unprintable = setmetatable({}, { __tostring = function() error("Cannot stringify") end })
    local printableOk, preserved = pcall(D.Wrap("callback", "unprintable", function() error(unprintable) end))
    assert(not printableOk and preserved == unprintable)
    assert(f.has("trace=") and f.has("tests/diagnostics_spec.lua"))
    assert(e.RegisterCommand("test", function() return 12 end, true) == 42)
    assert(f.command[2]() == 12 and f.command[3] == true)
    assert(e.AddStateBagChangeHandler("key", nil, function() return 13 end) == 43)
    assert(f.statebag() == 13)
    D.Export("sample", function() return 14 end)
    assert(f.exports.sample() == 14)
    assert(type(e.exports) == "table", "Native exports table must remain unchanged")
    e.RegisterNetEvent("network:test", function() return 15 end)
    assert(#f.events["network:test"] == 1 and f.events["network:test"][1]() == 15)
    e.CreateThread(function() e.Wait(5); return 16 end)
    assert(f.run(f.threads[#f.threads]) == 16)
    e.SetTimeout(250, function() return 17 end)
    assert(f.timers[1][1] == 250 and f.timers[1][2]() == 17)
    e.TriggerServerEvent("sky_base:sc", "diagnostics:get", 5, { private = "DO_NOT_LOG" })
    assert(f.sent[#f.sent].args[3].private == "DO_NOT_LOG" and not f.has("DO_NOT_LOG"))
    assert(f.has("diagnostics:get") and f.has("requestId=5"))
    e.MySQL = { query = { await = function(query, params) e.Wait(10); return params.result end } }
    D.InstrumentDatabase()
    assert(f.run(e.MySQL.query.await, "SELECT private", { result = 18 }) == 18)
    assert(f.has("MySQL.query.await") and not f.has("SELECT private"))
    local body = "DO_NOT_LOG"
    assert(e.PerformHttpRequest("https://api.example.test/private-key?token=DO_NOT_LOG", function(status, response)
        assert(status == 500 and response == body)
    end, "POST", body, { Authorization = body }, { followLocation = false }) == 44)
    f.http.cb(500, body, {}, "Unavailable")
    assert(f.has("http.response") and f.has("api.example.test") and not f.has("private-key") and not f.has(body))
    D.FileStarted("example.lua"); D.FileStarted("example.lua")
    assert(f.has("loadCount=2"))
    D.Log("error", "test.repeated", { message = "same" }); D.Log("error", "test.repeated", { message = "same" })
    assert(f.count("test.repeated") == 1)
    f.time = f.time + 2001
    D.Log("error", "test.repeated", { message = "same" })
    assert(f.count("test.repeated") == 2 and f.has("repeatsSinceLastLog=1"))
    f.level = 0
    D.Log("debug", "test.hidden"); D.Log("error", "test.visible")
    assert(not f.has("test.hidden") and f.has("test.visible"))
end

-- Native NUI callbacks can reply asynchronously; watchdogs do not invent replies.
do
    local f = fixture("sky_jobs_base")
    local e, D = f.env, f.env.SkyDiagnostics
    local saved, responses = nil, 0
    e.RegisterNUICallback("async", function(data, cb) saved = cb; return "registered" end)
    assert(f.nui.async({}, function(res) responses = responses + 1; assert(res.success == false) end) == "registered")
    saved({ success = false, error = "bad_vehicle" })
    assert(responses == 1 and f.has("nui.failed") and f.has("bad_vehicle"))
    e.RegisterNUICallback("never", function() end)
    f.nui.never({}, function() error("No response should be invented") end)
    D.TrackUi("no-browser", "/tablet/mechanic-dyno")
    local watchdog = coroutine.create(f.threads[1])
    assert(coroutine.resume(watchdog))
    f.time = f.time + 10001
    assert(coroutine.resume(watchdog))
    assert(f.has("nui.no_reply") and f.has("nui.browser_no_ack"))
    f.nui["sky:diagnostics:ui"]({ stage = "ready" }, function() end)
    assert(D.UiReady and f.messages[#f.messages].type == "sky:diagnostics:settings")
    D.TrackUi("acked", "/tablet/mechanic-orders")
    f.nui["sky:diagnostics:ui"]({ stage = "received", diagnosticId = "acked" }, function() end)
    assert(f.has("nui.browser_received"))
    e.RegisterNUICallback("throws", function() error("nui crash") end)
    local ok = pcall(f.nui.throws, {}, function() end)
    assert(not ok and f.has("nui.exception"))
    -- Cross-resource registry uses the instrumented handler as well as the native NUI path.
    f.load("sky_jobs_base/source/client/nui_registry.lua")
    e.RegisterNUICallback("proxied", function(_, cb) cb({ success = true }) end)
    local calls = 0
    assert(f.exports.RunNuiCallback("proxied", {}, function(res) assert(res.success); calls = calls + 1 end))
    assert(calls == 1 and f.has("nui.proxy_dispatch"))
end

local function mechanicFixture(skipDiagnostics)
    local f = fixture("sky_mechanicjob", false, skipDiagnostics)
    local e = f.env
    e.Sky = { Config = { locale = "en" } }
    e.nuiLocales = { title = "Mechanic" }
    e.TuningState, e.OrderTabletState = { active = true }, { connectedVehicleNetId = 0 }
    e.PlayerPedId = function() return 1 end
    e.DoesEntityExist = function(id) return id ~= 0 end
    e.GetVehiclePedIsIn = function() return f.vehicle or 2 end
    e.GetEntityCoords = function() return { x = 1, y = 2, z = 3 } end
    e.GetClosestVehicle = function() return f.nearby or 0 end
    e.NetworkGetNetworkIdFromEntity = function(vehicle) return vehicle + 100 end
    f.external.sky_jobs_base = { OpenOnJobsBase = function(_, key, route, options)
        f.fallback = { key = key, route = route, options = options }
        return true
    end }
    f.load("sky_mechanicjob/source/client/tablet_bridge.lua")
    return f
end

-- Exercise the real bridge: all aliases, nearby vehicle, delayed open, fallback and failure paths.
do
    local f = mechanicFixture()
    local e = f.env
    for _, key in ipairs({ "orders", "diagnostics", "dyno", "parts_shop", "vehicles" }) do
        assert(f.exports.ResolveMechanicTabletRoute(key, nil):find("/tablet/mechanic-", 1, true) == 1)
        assert(f.exports.ResolveMechanicTabletRoute(nil, "/" .. key) == f.exports.ResolveMechanicTabletRoute(key, nil))
    end
    assert(f.exports.ResolveMechanicTabletRoute(nil, "/tablet") == nil)
    f.run(f.events["sky_mechanicjob:tablet:openApp"][1], { key = "orders", openDelayMs = 350, jobColor = "#123456", noAnimation = true })
    assert(e.OrderTabletState.connectedVehicleNetId == 102 and e.TuningState.active == false)
    assert(f.messages[1].route == "/tablet/mechanic-orders" and f.messages[1].jobColor == "#123456")
    assert(f.messages[1].noAnimation and #f.messages == 3)
    assert(f.messages[1].diagnosticId == f.messages[3].diagnosticId)
    assert(f.focus[1][1] and f.focus[1][2] and f.keepInput == false)
    assert(f.has("open_delay") and f.has("delayMs=350") and f.has("messages_sent"))
    f.run(f.events["sky_mechanicjob:tablet:openApp"][1], { route = "/tablet", key = "home" })
    assert(f.fallback.route == "/tablet" and f.has("fallback_result"))
    f.resourceState = "stopped"
    f.fallback = nil
    f.run(f.events["sky_mechanicjob:tablet:openApp"][1], "/tablet")
    assert(not f.fallback and f.has("fallback_unavailable"))
    assert(f.exports.OpenMechanicTabletRoute("/tablet") == false)
    f.run(f.events["sky_mechanicjob:tablet:openApp"][1], false)
    assert(f.has("invalid_open_payload"))
    f.resourceState = "started"
    f.external.sky_jobs_base.OpenOnJobsBase = function() error("export unavailable") end
    f.run(f.events["sky_mechanicjob:tablet:openApp"][1], "/tablet")
    assert(f.has("export unavailable"))
    f.vehicle = 0; f.nearby = 9
    assert(f.exports.OpenMechanicTabletRoute("/diagnostics"))
    assert(e.OrderTabletState.connectedVehicleNetId == 109)
    f.nearby = 0
    assert(f.exports.OpenMechanicTabletRoute("/dyno") and f.has("no_nearby_vehicle"))
    e.OrderTabletState = nil
    assert(f.exports.OpenMechanicTabletRoute("/vehicles") and f.has("vehicle_state_missing"))
    f.nui["tablet:releaseFocus"]({}, function(res) assert(res.success) end)
    assert(f.focus[#f.focus][1] == false and f.has("focus_released"))
end

-- Mechanic event prefixes must release the jobs UI; general apps stay on it.
for _, transport in ipairs({ "clientEvent", "serverEvent" }) do
    local f = fixture("sky_jobs_base")
    f.time = 6000
    local e = f.env
    local apps = {
        { key = "orders", route = "/tablet/mechanic-orders", [transport] = "sky_mechanicjob:tablet:openApp" },
        { key = "calendar", route = "/tablet/calendar", clientEvent = "sky_jobs_base:calendar" },
    }
    e.Config = {}
    e.Sky = { Cb = { Trigger = function() return { success = true, data = apps } end } }
    e.Sky_Jobs = { TabletState = { IsOpen = function() return false end } }
    f.load("sky_jobs_base/source/client/tablet_apps.lua")
    f.nui["tablet:launchApp"]({ key = "orders" }, function(res) assert(res.success) end)
    assert(f.messages[1].type == "tablet:close" and f.messages[2].type == "tablet:releaseFocus")
    assert(f.focus[#f.focus][1] == false)
    f.messages = {}
    f.nui["tablet:launchApp"]({ key = "calendar" }, function(res) assert(res.success) end)
    assert(f.messages[1].type == "tablet:navigate")
end

-- Failed proxy dispatch must not reply twice after jobs base already supplied a response.
do
    local f = fixture("sky_mechanicjob")
    local diagnosticCallback = f.nui["sky:diagnostics:ui"]
    f.env.Sky = { Config = {} }
    f.external.sky_jobs_base = {
        GetRegisteredNuiCallbacks = function() return { "job:getInfo", "callback:missing", "sky:diagnostics:ui" } end,
        RunNuiCallback = function(_, name, data, cb)
            cb({ success = false, error = "callback_not_registered" })
            return false
        end,
    }
    f.load("sky_mechanicjob/source/client/nui_jobs_bridge.lua")
    f.run(f.threads[2])
    assert(f.nui["sky:diagnostics:ui"] == diagnosticCallback)
    local replies = 0
    f.nui["callback:missing"]({}, function(result) replies = replies + 1; assert(result.success == false) end)
    assert(replies == 1 and f.has("nui.proxy_failed"))
    f.external.sky_jobs_base.RunNuiCallback = function() error("Missing export") end
    f.nui["job:getInfo"]({}, function(result) assert(result.success and result.data.jobKey == "mechanic") end)
    assert(f.has("Missing export"))
end

-- A missing diagnostics script must not prevent tablet exports, focus or proxy setup.
do
    local f = mechanicFixture(true)
    assert(f.env.SkyDiagnostics == nil)
    assert(f.exports.ResolveMechanicTabletRoute("orders") == "/tablet/mechanic-orders")
    assert(f.exports.OpenMechanicTabletRoute("/orders") == true)
    assert(#f.messages == 3 and f.focus[1][1] == true)
    f.run(f.events["sky_mechanicjob:tablet:openApp"][1], "/tablet")
    assert(f.fallback.route == "/tablet")
    f.nui["tablet:releaseFocus"]({}, function(res) assert(res.success) end)
    assert(f.focus[#f.focus][1] == false)
    f.external.sky_jobs_base.GetRegisteredNuiCallbacks = function() error("Missing registry") end
    f.load("sky_mechanicjob/source/client/nui_jobs_bridge.lua")
    f.run(f.threads[1])
    -- When the live registry export is unavailable the bridge must fall back to the
    -- static callback set and register proxies instead of failing outright.
    assert(f.has("nui.proxy_registry_unavailable") and f.has("nui.proxy_registry_fallback"))
    assert(not f.has("nui.proxy_exhausted"))
    assert(f.nui["job:getInfo"] ~= nil)

    local jobs = fixture("sky_jobs_base", false, true)
    jobs.load("sky_jobs_base/source/client/nui_registry.lua")
    jobs.env.RegisterNUICallback("native:reply", function(_, cb) cb({ success = true }) end)
    local replies = 0
    assert(jobs.exports.RunNuiCallback("native:reply", {}, function(result) assert(result.success); replies = replies + 1 end))
    assert(replies == 1)
end

-- Server RPC setup and the two reported callbacks still work without a logger.
do
    local f = fixture("sky_base", true, true)
    f.env.Sky = { Debug = function() end }
    f.env.Config = {}
    f.env.MySQL = { query = { await = function() return {} end }, single = { await = function() return nil end } }
    f.env.source = 31
    f.load("sky_base/source/server/modules/Callbacks.lua")
    assert(f.exports.RegisterServerCallback and f.events["sky_base:sc"])
    f.load("sky_jobs_base/source/server/jobs.lua")
    f.load("sky_jobs_base/source/server/creator.lua")
    f.events["sky_base:sc"][1]("sky_jobs_base:creator:getPlayerJob", 1, {})
    local sent = f.sent[#f.sent]
    assert(sent.name == "sky_base:scResponse" and sent.args[1] == 31)
    assert(sent.args[3][1].success == true and sent.args[3][1].data.ready == true)
    f.events["sky_base:sc"][1]("sky_jobs_base:creator:getData", 2, { { creatorKey = "empty" } })
    sent = f.sent[#f.sent]
    assert(sent.name == "sky_base:scResponse" and sent.args[3][1].success == true)
end

print("PASS: Lua instrumentation, return/error/yield preservation, callback watchdogs, browser ACK, registry proxies, tablet bridge routes/vehicle/fallback/focus, mechanic client/server event ownership.")
