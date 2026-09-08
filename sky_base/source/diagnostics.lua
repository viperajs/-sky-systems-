-- Resource-local runtime instrumentation; keep the three copies identical.
-- setr sky_logs 2 = detailed (default), 1 = info, 0 = warnings/errors.
if SkyDiagnostics then return end

local resource = GetCurrentResourceName()
local side = IsDuplicityVersion() and "server" or "client"
local nativePrint, nativeExports = print, exports
local nativeAddEventHandler = AddEventHandler
local nativeCreateThread = Citizen.CreateThread
local nativeSetTimeout = Citizen.SetTimeout
local wrapped = setmetatable({}, { __mode = "k" })
local registered, files, recent, pending, pendingUi = {}, {}, {}, {}, {}
local serial, recentCount = 0, 0
local levels = { error = 0, warn = 0, info = 1, debug = 2 }
local colors = { error = "^1", warn = "^3", info = "^2", debug = "^5" }

SkyDiagnostics = {}
local D = SkyDiagnostics

local function now() return GetGameTimer() end
local function failureMessage(value)
    if type(value) == "table" then
        value = rawget(value, "message") or rawget(value, "fallback") or rawget(value, "key") or rawget(value, "code") or value
    end
    local ok, text = pcall(tostring, value)
    return ok and text or "<error could not be converted to text>"
end
local function location(fn)
    local info = debug.getinfo(fn, "S") or {}
    return (info.source or "unknown"):gsub("^@", ""), info.linedefined or 0
end

-- Only log supplied diagnostic fields, never event arguments, SQL parameters or NUI bodies.
local function encode(details)
    local safe = {}
    for key, value in pairs(details or {}) do
        if type(value) == "string" then
            safe[key] = value:sub(1, key == "trace" and 3500 or 800)
        elseif type(value) == "number" or type(value) == "boolean" then
            safe[key] = value
        elseif value ~= nil then
            safe[key] = "<" .. type(value) .. ">"
        end
    end
    local ok, result = pcall(json.encode, safe)
    return ok and result or '{"message":"Diagnostic details could not be encoded"}'
end

function D.Log(level, event, details)
    if (levels[level] or 1) > GetConvarInt("sky_logs", 2) then return end
    -- Logging is best-effort and cannot throw into gameplay.
    pcall(function()
        details = details or {}
        local stamp = now()
        local key = table.concat({ event, tostring(details.file), tostring(details.name), tostring(details.message) }, "|")
        local previous = recent[key]
        local interval = level == "debug" and 1000 or ((level == "warn" or level == "error") and 2000 or 0)
        if interval > 0 and previous and stamp - previous.at < interval then
            previous.repeats = previous.repeats + 1
            return
        end
        local output = {}
        for k, v in pairs(details) do output[k] = v end
        if previous and previous.repeats > 0 then output.repeatsSinceLastLog = previous.repeats end
        if recentCount > 1000 then recent, recentCount = {}, 0 end
        if not recent[key] then recentCount = recentCount + 1 end
        recent[key] = { at = stamp, repeats = 0 }
        nativePrint(("%s[%s][%s][%s][%s][%dms] %s^0"):format(
            colors[level] or "^0", resource, side, level:upper(), event, stamp, encode(output)))
    end)
end

function D.FileStarted(file)
    if D.InstrumentDatabase then D.InstrumentDatabase() end
    files[file] = (files[file] or 0) + 1
    D.Log(files[file] > 1 and "warn" or "info", "file.started", {
        file = file, loadCount = files[file],
        message = files[file] > 1 and "File executed more than once; check explicit entries plus manifest wildcards." or "Lua chunk started.",
    })
end

function D.Message(level, message)
    local caller = debug.getinfo(3, "Sl") or {}
    D.Log(level, "message", { message = tostring(message), file = caller.short_src, line = caller.currentline })
end

function D.TrackUi(id, route)
    pendingUi[id] = { started = now(), route = route }
end

local function registration(kind, name, fn)
    local file, line = location(fn)
    local key = kind .. ":" .. tostring(name)
    -- Multiple event listeners are valid; duplicate NUI names/commands/exports are usually not.
    if registered[key] and kind ~= "event" and kind ~= "thread" and kind ~= "timer" and kind ~= "statebag" then
        D.Log("warn", "handler.duplicate", { kind = kind, name = tostring(name), file = file, line = line, previous = registered[key] })
    end
    registered[key] = file .. ":" .. line
    D.Log("debug", "handler.registered", { kind = kind, name = tostring(name), file = file, line = line })
    return file, line
end

function D.Wrap(kind, name, fn)
    if type(fn) ~= "function" or wrapped[fn] then return fn end
    local file, line = registration(kind, name, fn)
    local function handler(...)
        serial = serial + 1
        local id, started = serial, now()
        local details = { kind = kind, name = tostring(name), file = file, line = line, callId = id }
        local caller = debug.getinfo(2, "Sl") or {}
        details.caller, details.callerLine = caller.short_src, caller.currentline
        D.Log("debug", "handler.started", details)
        local packed = table.pack(xpcall(fn, function(err)
            details.message = failureMessage(err)
            details.trace = debug.traceback(details.message, 2)
            details.elapsedMs = now() - started
            D.Log("error", "handler.exception", details)
            return err
        end, ...))
        if not packed[1] then error(packed[2], 0) end
        details.elapsedMs = now() - started
        local result = packed[2]
        if type(result) == "table" and rawget(result, "success") == false then
            details.message = failureMessage(rawget(result, "error") or "Returned success=false")
            D.Log("warn", "handler.rejected", details)
        else
            D.Log("debug", "handler.completed", details)
        end
        return table.unpack(packed, 2, packed.n)
    end
    wrapped[handler] = true
    return handler
end

function D.InstrumentDatabase()
    if not IsDuplicityVersion() or type(MySQL) ~= "table" then return end
    for _, method in ipairs({ "query", "single", "scalar", "insert", "update", "prepare", "transaction", "rawExecute" }) do
        local api = MySQL[method]
        if type(api) == "table" and type(api.await) == "function" and not wrapped[api.await] then
            api.await = D.Wrap("database", "MySQL." .. method .. ".await", api.await)
        end
    end
end

function D.Export(name, fn)
    return nativeExports(name, D.Wrap("export", name, fn))
end

-- RegisterNetEvent/RegisterServerEvent call AddEventHandler in the Cfx runtime.
AddEventHandler = function(name, fn)
    if type(fn) == "function" and tostring(name):sub(1, 6) ~= "__cfx_" then
        fn = D.Wrap("event", name, fn)
    end
    return nativeAddEventHandler(name, fn)
end

local function createThread(fn, ...)
    local name = type(fn) == "function" and select(1, location(fn)) or "thread"
    return nativeCreateThread(D.Wrap("thread", name, fn), ...)
end
CreateThread, Citizen.CreateThread = createThread, createThread

local function setTimeout(delay, fn, ...)
    local name = type(fn) == "function" and select(1, location(fn)) or "timer"
    return nativeSetTimeout(delay, D.Wrap("timer", name, fn), ...)
end
SetTimeout, Citizen.SetTimeout = setTimeout, setTimeout

local nativeRegisterCommand = RegisterCommand
RegisterCommand = function(name, fn, restricted)
    return nativeRegisterCommand(name, D.Wrap("command", name, fn), restricted)
end

if AddStateBagChangeHandler then
    local native = AddStateBagChangeHandler
    AddStateBagChangeHandler = function(key, bag, fn)
        return native(key, bag, D.Wrap("statebag", key or "*", fn))
    end
end

if PerformHttpRequest then
    local native = PerformHttpRequest
    PerformHttpRequest = function(url, cb, method, data, headers, options)
        local started = now()
        local host = tostring(url):match("^https?://([^/?#]+)") or "unknown"
        host = host:gsub("^.*@", "")
        D.Log("debug", "http.started", { name = host, method = method or "GET" })
        local reply = D.Wrap("http", host, function(status, body, responseHeaders, errorData)
            D.Log(status >= 200 and status < 400 and "debug" or "error", "http.response", {
                name = host, status = status, elapsedMs = now() - started, message = errorData,
            })
            return cb(status, body, responseHeaders, errorData)
        end)
        return native(url, reply, method, data, headers, options)
    end
end

-- Outgoing event names show which side of a cross-resource handoff was reached.
for _, api in ipairs({ "TriggerEvent", "TriggerServerEvent", "TriggerClientEvent" }) do
    local native = _G[api]
    if native then
        _G[api] = function(name, ...)
            if tostring(name):sub(1, 6) ~= "__cfx_" then
                D.Log("debug", "event.sent", { name = tostring(name), transport = api })
                if name == "sky_base:sc" then
                    D.Log("debug", "rpc.sent", { name = select(1, ...), requestId = select(2, ...), transport = api })
                elseif name == "sky_base:cc" then
                    D.Log("debug", "rpc.sent", { name = select(2, ...), requestId = select(3, ...), transport = api })
                end
            end
            return native(name, ...)
        end
    end
end

if not IsDuplicityVersion() then
    local nativeRegisterNUICallback = RegisterNUICallback
    -- This reports receipt by the browser, not successful application rendering.
    nativeRegisterNUICallback("sky:diagnostics:ui", function(data, cb)
        if type(data) == "table" then
            if data.stage == "ready" then
                D.UiReady = true
                D.Log("info", "nui.browser_ready", { message = "Browser diagnostic script loaded." })
                SendNUIMessage({ type = "sky:diagnostics:settings", verbose = GetConvarInt("sky_logs", 2) >= 2 })
            elseif data.stage == "received" and type(data.diagnosticId) == "string" and pendingUi[data.diagnosticId] then
                local entry = pendingUi[data.diagnosticId]
                D.Log("info", "nui.browser_received", {
                    diagnosticId = data.diagnosticId, route = entry.route, elapsedMs = now() - entry.started,
                    message = "Browser received the tablet message. Check router.navigation for the resolved page.",
                })
                pendingUi[data.diagnosticId] = nil
            end
        end
        cb({ success = true })
    end)
    function D.WrapNui(name, fn)
        if type(fn) ~= "function" or wrapped[fn] then return fn end
        local file, line = registration("nui", name, fn)
        local function handler(data, cb)
            serial = serial + 1
            local id, started, responded = serial, now(), false
            local details = { name = name, file = file, line = line, callId = id }
            pending[id] = { started = started, details = details }
            D.Log("debug", "nui.request", details)
            local function reply(result, ...)
                if responded then
                    D.Log("warn", "nui.duplicate_reply", details)
                end
                responded = true
                pending[id] = nil
                details.elapsedMs = now() - started
                if type(result) == "table" and rawget(result, "success") == false then
                    details.message = failureMessage(rawget(result, "error") or "Returned success=false")
                    D.Log("error", "nui.failed", details)
                else
                    D.Log("debug", "nui.responded", details)
                end
                return cb(result, ...)
            end
            local result = table.pack(xpcall(fn, function(err)
                details.message = failureMessage(err)
                details.trace = debug.traceback(details.message, 2)
                D.Log("error", "nui.exception", details)
                return err
            end, data, reply))
            if not result[1] then
                -- Preserve native error behavior; the pending-response warning remains useful.
                error(result[2], 0)
            end
            return table.unpack(result, 2, result.n)
        end
        wrapped[handler] = true
        return handler
    end
    RegisterNUICallback = function(name, fn)
        return nativeRegisterNUICallback(name, D.WrapNui(name, fn))
    end

    local nativeSendNUIMessage = SendNUIMessage
    SendNUIMessage = function(message)
        local data = type(message) == "table" and message or {}
        local nested = type(data.data) == "table" and data.data or {}
        D.Log("debug", "nui.message_sent", {
            name = tostring(data.type or data.action or "unknown"),
            route = data.route or nested.route, appKey = data.appKey or nested.appKey,
        })
        return nativeSendNUIMessage(message)
    end
    for _, api in ipairs({ "SetNuiFocus", "SetNuiFocusKeepInput" }) do
        local native = _G[api]
        _G[api] = function(enabled, cursor)
            local caller = debug.getinfo(2, "Sl") or {}
            D.Log("info", "nui.focus", {
                name = api, enabled = enabled, cursor = cursor,
                file = caller.short_src, line = caller.currentline,
            })
            if api == "SetNuiFocus" then return native(enabled, cursor) end
            return native(enabled)
        end
    end
    -- One watchdog handles all pending callbacks; no timer allocation per request.
    nativeCreateThread(function()
        while true do
            Citizen.Wait(1000)
            for id, entry in pairs(pending) do
                if now() - entry.started >= 10000 then
                    entry.details.elapsedMs = now() - entry.started
                    entry.details.message = "NUI callback has not replied after 10 seconds. Check cb(...) and any server callback it awaits."
                    D.Log("warn", "nui.no_reply", entry.details)
                    pending[id] = nil
                end
            end
            for id, entry in pairs(pendingUi) do
                if now() - entry.started >= 10000 then
                    D.Log("error", "nui.browser_no_ack", { diagnosticId = id, route = entry.route,
                        elapsedMs = now() - entry.started, message = "Tablet message was sent but the browser did not acknowledge it. Check NUI startup, script loads and focus logs." })
                    pendingUi[id] = nil
                end
            end
        end
    end)
end

nativeAddEventHandler(IsDuplicityVersion() and "onResourceStart" or "onClientResourceStart", function(name)
    if name ~= resource then return end
    local fileCount, handlerCount = 0, 0
    for _ in pairs(files) do fileCount = fileCount + 1 end
    for _ in pairs(registered) do handlerCount = handlerCount + 1 end
    D.Log("info", "resource.started", { filesStarted = fileCount, registeredHandlers = handlerCount, logLevel = GetConvarInt("sky_logs", 2) })
end)

D.Log("info", "logging.ready", { resource = resource, side = side, version = 2, message = "Resource-local diagnostics loaded. setr sky_logs 0/1/2 controls verbosity." })
