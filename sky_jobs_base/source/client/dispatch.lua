if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/dispatch.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_jobs_base · source/client/dispatch.lua
--  Deobfuscated & Cleaned
-- =====================================================

--- Triggers server event to create a job dispatch notification.
---@param title string
---@param message string
---@param jobKey? string
---@param coords? table|vector3
---@param extraData? table
---@return boolean
registerExport("createDispatch", function(title, message, jobKey, coords, extraData)
    TriggerServerEvent("sky_jobs_base:dispatch:create", title, message, jobKey, coords, extraData)
    return true
end)
