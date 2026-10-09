if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/target.lua") end
-- =====================================================
--  sky_jobs_base · source/client/target.lua
--  Target system for the job radial actions
-- =====================================================

-- radial_menu.lua offers the job actions (workshop lift, engine hoist, ...) as target options
-- through Sky.Target. That is sky_base's config/target bridge, loaded into this resource right
-- after this file (fxmanifest.lua). It only sets itself up when Sky.Config.target names the
-- target system, which sky_base resolves (including "auto"); without it no job action reached
-- ox_target or qb-target.

local function getSkyBaseTargetSystem()
    local ok, target = pcall(function()
        return exports.sky_base:GetTargetSystem()
    end)
    if ok and target ~= nil then return target end

    -- sky_base versions without GetTargetSystem
    ok, target = pcall(function()
        local sky = exports.sky_base:Get()
        return type(sky) == "table" and type(sky.Config) == "table" and sky.Config.target or nil
    end)
    return ok and target or nil
end

local target = getSkyBaseTargetSystem()
Sky.Config.target = (target == "ox" or target == "qb") and target or "none"
