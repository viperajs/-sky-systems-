if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/nui_registry.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
local function logDiagnostics(level, event, details)
    if SkyDiagnostics and SkyDiagnostics.Log then
        SkyDiagnostics.Log(level, event, details)
    elseif level == "warn" or level == "error" then
        local ok, message = pcall(json.encode, details or {})
        print(("[sky_jobs_base][%s][%s] %s"):format(level:upper(), event, ok and message or "Diagnostics unavailable"))
    end
end
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
        if SkyDiagnostics and SkyDiagnostics.WrapNui then handler = SkyDiagnostics.WrapNui(name, handler) end
        registeredHandlers[name] = handler
    end
    return nativeRegisterNUICallback(name, handler)
end

registerExport("RunNuiCallback", function(name, data, cb)
    if type(name) ~= "string" or type(cb) ~= "function" then
        return false
    end

    local handler = registeredHandlers[name]
    if not handler then
        logDiagnostics("error", "nui.proxy_unregistered", { name = name })
        cb({ success = false, error = "callback_not_registered" })
        return false
    end

    logDiagnostics("debug", "nui.proxy_dispatch", { name = name })
    handler(type(data) == "table" and data or {}, cb)
    return true
end)

registerExport("GetRegisteredNuiCallbacks", function()
    local names = {}
    for name in pairs(registeredHandlers) do
        names[#names + 1] = name
    end
    table.sort(names)
    return names
end)
