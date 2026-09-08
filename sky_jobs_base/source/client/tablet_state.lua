if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/tablet_state.lua") end
-- =====================================================
--  sky_jobs_base · source/client/tablet_state.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky_Jobs = Sky_Jobs or {}
Sky_Jobs.TabletState = Sky_Jobs.TabletState or {}

local currentState = {
    open = false,
    appKey = nil,
    route = nil
}

local lastState = {
    appKey = nil,
    route = nil
}

local function normalizeAppKey(val)
    if type(val) ~= "string" then return nil end
    local match = val:match("^%s*(.-)%s*$")
    if not match or match == "" then return nil end
    return match:lower()
end

local function normalizeRoute(val)
    if type(val) ~= "string" then return nil end
    local match = val:match("^%s*(.-)%s*$")
    if not match or match == "" then return nil end
    return match
end

local function getStateSnapshot()
    return {
        open = currentState.open == true,
        appKey = currentState.appKey,
        route = currentState.route
    }
end

local function setOpenState(isOpen, opts, isServerSync)
    opts = opts or {}
    local openFlag = isOpen == true
    local appKey = openFlag and normalizeAppKey(opts.appKey or opts.key) or nil
    local route = openFlag and normalizeRoute(opts.route) or nil

    if currentState.open == openFlag and currentState.appKey == appKey and currentState.route == route then
        return
    end

    currentState.open = openFlag
    currentState.appKey = appKey
    currentState.route = route

    if openFlag and route and route:sub(1, 7) == "/tablet" then
        lastState.appKey = appKey
        lastState.route = route
    end

    local snapshot = getStateSnapshot()
    TriggerEvent("sky_jobs_base:tablet:stateChanged", snapshot)

    if not isServerSync then
        TriggerServerEvent("sky_jobs_base:tablet:setState", snapshot)
    end
end

--- Gets snapshot of current tablet open state.
---@return table
function Sky_Jobs.TabletState.GetState()
    return getStateSnapshot()
end

--- Checks if tablet is currently open.
---@return boolean
function Sky_Jobs.TabletState.IsOpen()
    return currentState.open == true
end

--- Gets currently active tablet app key.
---@return string|nil
function Sky_Jobs.TabletState.GetAppKey()
    return currentState.appKey
end

--- Gets last saved tablet route/app state.
---@return table
function Sky_Jobs.TabletState.GetLastState()
    return {
        appKey = lastState.appKey,
        route = lastState.route
    }
end

AddEventHandler("sky_jobs_base:tablet:setOpenState", function(isOpen, opts)
    setOpenState(isOpen, opts, false)
end)

AddEventHandler("sky_jobs:nuiClosed", function()
    setOpenState(false, nil, false)
end)
