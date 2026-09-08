if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/server/modules/Callbacks.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_base · source/server/modules/Callbacks.lua
--  Server-Side Callback Dispatcher & Handler
-- =====================================================

Sky = Sky or {}
Sky.Cb = {}

local serverCallbacks = {}
local clientCallbackResponses = {}
local currentClientRequestId = 0

--- Register a server callback that clients can invoke.
---@param name string
---@param callbackFunction function
function Sky.Cb.Register(name, callbackFunction)
    if SkyDiagnostics then callbackFunction = SkyDiagnostics.Wrap("callback", name, callbackFunction) end
    assert(name ~= nil, 'Parameter "name" must be a string!')
    assert(callbackFunction ~= nil, 'Parameter "callbackFunction" must be a function!')
    serverCallbacks[name] = callbackFunction
end

registerExport("RegisterServerCallback", function(name, callbackFunction)
    Sky.Cb.Register(name, callbackFunction)
end)

registerExport("TriggerClientCallback", function(source, name, ...)
    return Sky.Cb.TriggerClient(source, name, ...)
end)

AddEventHandler("sky_base:registerServerCallback", function(name, callbackFunction)
    Sky.Cb.Register(name, callbackFunction)
end)

--- Trigger a client-side callback synchronously.
---@param source number
---@param name string
---@param ... any
---@return any ...
function Sky.Cb.TriggerClient(source, name, ...)
    assert(source ~= nil, 'Parameter "source" must be a number!')
    assert(name ~= nil, 'Parameter "name" must be a string!')

    local timeout = (Sky.Config and Sky.Config.defaultCallbackTimeout) or 5000
    local requestId = currentClientRequestId
    currentClientRequestId = (currentClientRequestId + 1) % 65536
    local requestKey = name .. tostring(requestId)

    TriggerClientEvent("sky_base:cc", source, name, requestId, { ... })
    clientCallbackResponses[requestKey] = true

    local startTime = GetGameTimer()
    while clientCallbackResponses[requestKey] == true do
        Citizen.Wait(50)
        if GetGameTimer() > (startTime + timeout) then
            clientCallbackResponses[requestKey] = "ERROR"
            Sky.Debug("error", "ClientCallback " .. name .. " timed out after " .. timeout .. "ms!")
            break
        end
    end

    if clientCallbackResponses[requestKey] == "ERROR" then
        return nil
    end

    local resultData = clientCallbackResponses[requestKey]
    clientCallbackResponses[requestKey] = nil

    return table.unpack(resultData or {})
end

--- Handle incoming client requests to execute a server callback.
RegisterNetEvent("sky_base:sc", function(name, requestId, args)
    local src = source
    local requestKey = name .. tostring(requestId)
    local cb = serverCallbacks[name]

    if not cb then
        Sky.Debug("warn", ('ServerCallback "%s" does not exist! (Source: %s)'):format(tostring(name), tostring(src)))
        TriggerClientEvent("sky_base:scDoesNotExist", src, requestKey, name)
        return
    end

    if true then
        Sky.Debug("info", ('ServerCallback "%s" executing with args: %s (Source: %s)'):format(tostring(name), json.encode(args), tostring(src)))
    end

    local packed = table.pack(pcall(cb, src, table.unpack(args or {})))
    local success = packed[1]

    if not success then
        local err = packed[2]
        Sky.Debug("error", ('ServerCallback "%s" threw an error:\n%s'):format(tostring(name), tostring(err)))
        TriggerClientEvent("sky_base:scError", src, requestKey, name, tostring(err))
        return
    end

    local resultArgs = {}
    for i = 2, packed.n do
        resultArgs[i - 1] = packed[i]
    end
    
    if true then
        Sky.Debug("info", ('ServerCallback "%s" finished. Result: %s'):format(tostring(name), json.encode(resultArgs)))
    end

    TriggerClientEvent("sky_base:scResponse", src, requestKey, resultArgs)
end)

--- Handle incoming client responses to a server-initiated client callback.
RegisterNetEvent("sky_base:ccResponse", function(requestKey, data)
    if clientCallbackResponses[requestKey] == nil then return end
    clientCallbackResponses[requestKey] = data
end)

RegisterNetEvent("sky_base:ccDoesNotExist", function(requestKey, name)
    if clientCallbackResponses[requestKey] == nil then return end
    clientCallbackResponses[requestKey] = "ERROR"
    Sky.Debug("error", ('ClientCallback "%s" does not exist on client!'):format(tostring(name)))
end)

RegisterNetEvent("sky_base:ccError", function(requestKey, name, err)
    if clientCallbackResponses[requestKey] == nil then return end
    clientCallbackResponses[requestKey] = "ERROR"
    Sky.Debug("error", ('ClientCallback "%s" ran into an error on client:\n%s'):format(tostring(name), tostring(err)))
end)
