if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/utils.lua") end
-- =====================================================
--  sky_jobs_base · source/client/utils.lua
--  Deobfuscated & Cleaned
-- =====================================================

function GetJobState()
    local state = Sky_Jobs.Access.GetState()
    return {
        employed = state.employed,
        onDuty = state.onDuty,
        jobKey = state.jobKey
    }
end
