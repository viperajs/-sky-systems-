if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/modules/Callbacks.lua") end
-- =====================================================
--  sky_base · source/client/modules/Callbacks.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Cb = {}

local callbacks = {}
local callbackResponses = {}
local currentRequestId = 0

--- Registers a client-side callback for the server to call.
---@param name string
---@param callbackFunction function
function Sky.Cb.Register(name, callbackFunction)
    if SkyDiagnostics then callbackFunction = SkyDiagnostics.Wrap("callback", name, callbackFunction) end
    assert(name ~= nil, 'Parameter "name" must be a string!')
    callbacks[name] = callbackFunction
end

--- Triggers a server callback synchronously with default timeout.
---@param name string
---@param ... any
---@return any ...
function Sky.Cb.Trigger(name, ...)
    assert(name ~= nil, 'Parameter "name" must be a string!')
    local timeout = (Sky.Config and Sky.Config.defaultCallbackTimeout) or 5000
    return Sky.Cb.TriggerWithTimeout(name, timeout, ...)
end

--- Triggers a server callback synchronously with a specified timeout.
---@param name string
---@param timeout number
---@param ... any
---@return any ...
function Sky.Cb.TriggerWithTimeout(name, timeout, ...)
    assert(name ~= nil, 'Parameter "name" must be a string!')
    assert(timeout ~= nil, 'Parameter "timeout" must be a number!')

    local requestId = currentRequestId
    currentRequestId = (currentRequestId + 1) % 65536
    local requestKey = name .. tostring(requestId)

    TriggerServerEvent("sky_base:sc", name, requestId, { ... })
    callbackResponses[requestKey] = true

    local startTime = GetGameTimer()
    while callbackResponses[requestKey] == true do
        Citizen.Wait(50)
        if GetGameTimer() > (startTime + timeout) then
            callbackResponses[requestKey] = "ERROR"
            print(("ServerCallback %s timed out after %sms! Args: %s"):format(name, timeout, json.encode({...})))
            break
        end
    end

    if callbackResponses[requestKey] == "ERROR" then
        return
    end

    local resultData = callbackResponses[requestKey]
    callbackResponses[requestKey] = nil

    return table.unpack(resultData)
end

--- Triggers a server callback asynchronously.
---@param name string
---@param callbackFunction function
---@param ... any
function Sky.Cb.TriggerAsync(name, callbackFunction, ...)
    assert(name ~= nil, 'Parameter "name" must be a string!')
    assert(callbackFunction ~= nil, 'Parameter "callbackFunction" must be a function!')

    local args = { ... }
    Citizen.CreateThread(function()
        local result = { Sky.Cb.Trigger(name, table.unpack(args)) }
        callbackFunction(table.unpack(result))
    end)
end

--- Triggers a server callback asynchronously with timeout.
---@param name string
---@param timeout number
---@param callbackFunction function
---@param ... any
function Sky.Cb.TriggerWithTimeoutAsync(name, timeout, callbackFunction, ...)
    assert(name ~= nil, 'Parameter "name" must be a string!')
    assert(timeout ~= nil, 'Parameter "timeout" must be a number!')
    assert(callbackFunction ~= nil, 'Parameter "callbackFunction" must be a function!')

    local args = { ... }
    Citizen.CreateThread(function()
        local result = { Sky.Cb.TriggerWithTimeout(name, timeout, table.unpack(args)) }
        callbackFunction(table.unpack(result))
    end)
end

RegisterNetEvent("sky_base:cc", function(name, requestId, args)
    local requestKey = name .. tostring(requestId)
    local cb = callbacks[name]

    if not cb then
        print("ClientCallback " .. name .. " does not exist!")
        TriggerServerEvent("sky_base:ccDoesNotExist", requestKey, name)
        return
    end

    if true then
        print(('[DEBUG] ClientCallback "%s" executing with args: %s'):format(tostring(name), json.encode(args)))
    end

    local packed = table.pack(pcall(cb, table.unpack(args or {})))
    local success = packed[1]

    if not success then
        local err = packed[2]
        if err == nil then
            print('ClientCallback "' .. name .. '" ran into an error!')
        else
            print('ClientCallback "' .. name .. '" ran into the following error:\n' .. tostring(err))
        end
        TriggerServerEvent("sky_base:ccError", requestKey, name, err)
        return
    end

    local resultArgs = {}
    for i = 2, packed.n do
        resultArgs[i - 1] = packed[i]
    end
    
    if true then
        print(('[DEBUG] ClientCallback "%s" finished. Result: %s'):format(tostring(name), json.encode(resultArgs)))
    end

    TriggerServerEvent("sky_base:ccResponse", requestKey, resultArgs)
end)

RegisterNetEvent("sky_base:scResponse", function(requestKey, data)
    if callbackResponses[requestKey] == nil then return end
    callbackResponses[requestKey] = data
end)

RegisterNetEvent("sky_base:scDoesNotExist", function(requestKey, name)
    if callbackResponses[requestKey] == nil then return end
    callbackResponses[requestKey] = "ERROR"
    print('ServerCallback "' .. name .. '" does not exist!')
end)

RegisterNetEvent("sky_base:scError", function(requestKey, name, err)
    if callbackResponses[requestKey] == nil then return end
    callbackResponses[requestKey] = "ERROR"
    if err == nil then
        print('ServerCallback "' .. name .. '" ran into an error! Check the server console for errors!')
    else
        print('ServerCallback "' .. name .. '" ran into the following error:\n' .. tostring(err))
    end
end)
