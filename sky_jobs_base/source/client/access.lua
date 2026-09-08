if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/access.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_jobs_base · source/client/access.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky_Jobs = Sky_Jobs or {}
Sky_Jobs.Access = Sky_Jobs.Access or {}

local accessState = {
    employed = false,
    onDuty = false,
    jobKey = nil
}

local hasSnapshot = false
local jobFilter = nil

local function getStateSnapshot()
    return {
        employed = accessState.employed,
        onDuty = accessState.onDuty,
        jobKey = accessState.jobKey
    }
end

local function sanitizeJobKey(key)
    if type(key) == "string" and key ~= "" then
        return key
    end
    return nil
end

local function extractJobName(data)
    if type(data) == "string" then
        return sanitizeJobKey(data)
    end
    if type(data) == "table" then
        local name = data.name or data.job or data.id or data.jobKey
        return sanitizeJobKey(name)
    end
    return nil
end

local function isJobInFilter(jobName)
    if not jobFilter then
        return true
    end
    if jobName then
        return jobFilter[jobName] == true
    end
    return false
end

local function setAccessState(isEmployed, isOnDuty, jobKey)
    local sanitizedKey = sanitizeJobKey(jobKey)
    local empFlag = (isEmployed == true) and (sanitizedKey ~= nil)
    local dutyFlag = empFlag and (isOnDuty == true)

    local isChanged = (accessState.employed ~= empFlag)
    accessState.employed = empFlag
    accessState.onDuty = dutyFlag
    accessState.jobKey = sanitizedKey
    hasSnapshot = true

    if isChanged then
        TriggerEvent("sky_jobs_base:access:stateChanged", getStateSnapshot())
    end
end

local function updateJob(data)
    local jobName = extractJobName(data)
    if not jobName then
        setAccessState(false, false, nil)
        return
    end

    if accessState.jobKey and accessState.jobKey ~= jobName then
        setAccessState(true, false, jobName)
        return
    end

    setAccessState(true, accessState.onDuty, jobName)
end

--- Sets a filter map for allowed jobs.
---@param filterList table|nil
function Sky_Jobs.Access.SetJobFilter(filterList)
    if type(filterList) ~= "table" then
        jobFilter = nil
        return
    end

    local map = {}
    for _, item in ipairs(filterList) do
        local name = extractJobName(item)
        if name then
            map[name] = true
        end
    end

    if next(map) then
        jobFilter = map
    else
        jobFilter = nil
    end
end

--- Returns true if job state snapshot has loaded.
---@return boolean
function Sky_Jobs.Access.HasSnapshot()
    return hasSnapshot
end

--- Gets copy of access state.
---@return table
function Sky_Jobs.Access.GetState()
    return getStateSnapshot()
end

--- Gets current job key.
---@return string|nil
function Sky_Jobs.Access.GetJobKey()
    return accessState.jobKey
end

--- Returns true if player is an employee of job (and matches filter if set).
---@return boolean
function Sky_Jobs.Access.IsEmployee()
    if accessState.employed then
        return isJobInFilter(accessState.jobKey)
    end
    return false
end

--- Returns true if player is on duty (and matches filter if set).
---@return boolean
function Sky_Jobs.Access.IsOnDuty()
    if accessState.employed and accessState.onDuty then
        return isJobInFilter(accessState.jobKey)
    end
    return false
end

--- Alias for IsOnDuty
---@return boolean
function Sky_Jobs.Access.HasJob()
    return Sky_Jobs.Access.IsOnDuty()
end

--- Refreshes player job and duty state from server callbacks.
---@return boolean, boolean -- hasJob, isReady
function Sky_Jobs.Access.Refresh()
    local jobRes = Sky.Cb.Trigger("sky_jobs_base:creator:getPlayerJob", {})
    local isJobReady = jobRes and jobRes.success and jobRes.data and (jobRes.data.ready == true)

    if not isJobReady then
        return Sky_Jobs.Access.HasJob(), false
    end

    local jobKey = (jobRes.data and jobRes.data.jobKey) or nil
    local hasJobKey = (jobKey ~= nil)
    local isOnDuty = false

    if hasJobKey then
        local dutyRes = Sky.Cb.Trigger("sky_jobs_base:creator:getPlayerDuty", {})
        local isDutyReady = dutyRes and dutyRes.success and dutyRes.data and (dutyRes.data.ready == true)

        if not isDutyReady then
            return Sky_Jobs.Access.HasJob(), false
        end

        if dutyRes and dutyRes.data then
            isOnDuty = (dutyRes.data.onDuty == true)
        end
    end

    setAccessState(hasJobKey, isOnDuty, jobKey)
    return Sky_Jobs.Access.HasJob(), true
end

registerExport("isOnDuty", function()
    return Sky_Jobs.Access.IsOnDuty()
end)

RegisterNetEvent("sky_base:updateJob", function(data)
    updateJob(data)
end)

RegisterNetEvent("sky_jobs_base:creator:updatePlayerJob", function(data)
    updateJob(data)
end)

RegisterNetEvent("sky_jobs_base:creator:updatePlayerDuty", function(onDuty, jobData)
    local key = jobData or accessState.jobKey
    if key then
        setAccessState(true, onDuty == true, key)
    else
        setAccessState(false, false, nil)
    end
end)

CreateThread(function()
    Wait(500)
    while true do
        local _, isReady = Sky_Jobs.Access.Refresh()
        if isReady then break end
        Wait(2000)
    end
end)
