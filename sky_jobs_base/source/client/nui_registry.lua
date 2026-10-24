-- =====================================================
--  sky_jobs_base · source/client/nui_registry.lua
--  Captures NUI callback handlers for cross-resource proxy
--  MUST load before other client scripts.
-- =====================================================

if _SKY_NUI_REGISTRY_INITIALIZED then
    return
end
_SKY_NUI_REGISTRY_INITIALIZED = true

local nativeRegisterNUICallback = RegisterNUICallback
local registeredHandlers = {}

RegisterNUICallback = function(name, handler)
    if type(name) == "string" and type(handler) == "function" then
        registeredHandlers[name] = handler
    end
    return nativeRegisterNUICallback(name, handler)
end

exports("RunNuiCallback", function(name, data, cb)
    -- cb comes from another resource (sky_mechanicjob's bridge) as a callable table.
    local cbMeta = type(cb) == "table" and getmetatable(cb) or nil
    local isCallable = type(cb) == "function" or (type(cbMeta) == "table" and cbMeta.__call ~= nil)
    if type(name) ~= "string" or not isCallable then
        return false
    end

    local handler = registeredHandlers[name]
    if not handler then
        cb({ success = false, error = "callback_not_registered" })
        return false
    end

    handler(type(data) == "table" and data or {}, cb)
    return true
end)

exports("GetRegisteredNuiCallbacks", function()
    local names = {}
    for name in pairs(registeredHandlers) do
        names[#names + 1] = name
    end
    table.sort(names)
    return names
end)
