if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/radial_menu.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_jobs_base · source/client/radial_menu.lua
--  Deobfuscated & Cleaned
-- =====================================================

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}
local nuiLocales = locales.Nui or {}
local radialLocales = nuiLocales.radial or {}
local panicLocales = locales.Panic or {}

local radialCfg = Config and Config.JobRadial or {}
local oxTargetCfg = radialCfg.oxTarget or {}
local tabletCfg = Config and Config.Tablet or {}
local panicCfg = Config and Config.Panic or {}

local IS_TABLET_ENABLED = tabletCfg.enabled ~= false
local IS_PANIC_ENABLED = panicCfg.enabled ~= false
local IS_RADIAL_ENABLED = radialCfg.enabled ~= false
local PROP_REMOVE_DISTANCE = tonumber(Config and Config.JobGarage and Config.JobGarage.trunk and Config.JobGarage.trunk.propRemoveDistance) or 2.2

local registeredJobNames = {}
local registeredJobMap = {}
local oxTargetRegisteredKeys = {}
local currentOxTargetSignature = nil
local actionRegistry = {}
local actionProviderMap = {}

local radialState = {
    open = false,
    hotkey = "g",
    hotkeyLabel = "G",
    mode = "hold",
    selectedId = nil,
    sequence = 0,
    actions = {}
}

local genericErrorMsg = (nuiLocales.errors and nuiLocales.errors.generic) or "Action unavailable."

local lastActionTriggerTime = 0
local isMouseSelectionThreadRunning = false
local isDisableInputThreadRunning = false

local isRadialHoldPressed = false
local radialHoldReleaseTime = 0

local function normalizeString(str)
    if type(str) == "string" and str ~= "" then
        return str:lower()
    end
    return nil
end

local function addUniqueName(list, map, name)
    if type(name) ~= "string" or name == "" then return end
    if map[name] then return end
    map[name] = true
    table.insert(list, name)
end

local function setRegisteredJobs(jobsList)
    registeredJobMap = {}
    if type(jobsList) ~= "table" then return end
    for _, j in ipairs(jobsList) do
        local norm = normalizeString(j)
        if norm then
            registeredJobMap[norm] = true
        end
    end
end

local function fetchRegisteredJobs()
    local res = Sky.Cb.Trigger("sky_jobs_base:getRegisteredJobs") or {}
    setRegisteredJobs(res)
end

local function matchesJobFilter(filter, jobKey)
    if filter == nil then return true end
    if not jobKey then return false end

    if type(filter) == "string" then
        return normalizeString(filter) == jobKey
    end

    if type(filter) == "table" then
        for _, item in ipairs(filter) do
            if normalizeString(item) == jobKey then
                return true
            end
        end
    end
    return false
end

local function processProviderEntry(list, map, provider, currentJobKey, currentJobGroup)
    if type(provider) == "string" then
        addUniqueName(list, map, provider)
        return
    end

    if type(provider) ~= "table" then return end

    local name = provider.resource or provider.provider or provider.name or provider[1]
    if name then
        local jobFilter = provider.jobKeys or provider.jobs or provider.job or provider.jobKey
        local groupFilter = provider.jobGroups or provider.groups or provider.group or provider.jobGroup

        if matchesJobFilter(jobFilter, currentJobKey) and matchesJobFilter(groupFilter, currentJobGroup) then
            addUniqueName(list, map, name)
        end
        return
    end

    for _, sub in ipairs(provider) do
        processProviderEntry(list, map, sub, currentJobKey, currentJobGroup)
    end
end

local function getJobGroup(jobKey)
    if not jobKey then return nil end
    local info = Sky.Cb.Trigger("sky_jobs_base:getJobInfo") or {}
    local grp = normalizeString(info.group or info.jobGroup)
    return grp or jobKey
end

local function resolveExternalProviders()
    local providersList = {}
    local providerMap = {}

    local jobState = GetJobState and GetJobState()
    local jobKey = normalizeString(jobState and jobState.jobKey)
    local jobGroup = getJobGroup(jobKey)

    if not jobGroup then return providersList end

    addUniqueName(providersList, providerMap, string.format("sky_%sjob", jobGroup))

    local cfgProviders = radialCfg.providers or radialCfg.externalProviders
    if type(cfgProviders) == "table" then
        for _, entry in ipairs(cfgProviders) do
            processProviderEntry(providersList, providerMap, entry, jobKey, jobGroup)
        end
    end

    return providersList
end

local function isPlayerEmployed()
    local jobState = GetJobState and GetJobState()
    return jobState and jobState.employed == true
end

local function isPlayerOnDuty()
    local jobState = GetJobState and GetJobState()
    return jobState and jobState.employed == true and jobState.onDuty == true
end

local function getConfiguredAllowedJobs()
    local allowed = panicCfg.allowedJobs
    if type(allowed) == "table" then return allowed end
    if type(allowed) == "string" and allowed ~= "" then return { allowed } end
    return nil
end

local function isPlayerAuthorizedForPanic()
    local jobState = GetJobState and GetJobState()
    if not (jobState and jobState.employed) then return false end

    local jobKey = normalizeString(jobState.jobKey)
    if not jobKey then return false end

    local cfgAllowed = getConfiguredAllowedJobs()
    if not cfgAllowed then
        return registeredJobMap[jobKey] == true
    end

    for _, a in ipairs(cfgAllowed) do
        if normalizeString(a) == jobKey then
            return true
        end
    end
    return false
end

local function isPlayerAuthorizedForRadial()
    local jobState = GetJobState and GetJobState()
    if not (jobState and jobState.employed and jobState.onDuty) then return false end

    local jobKey = normalizeString(jobState.jobKey)
    if not jobKey then return false end

    return registeredJobMap[jobKey] == true
end

local function isHoldMode()
    local mode = radialCfg.mode
    if type(mode) ~= "string" or mode == "" then return true end
    return mode:lower() ~= "toggle"
end

local function getDeadzoneThreshold()
    local dz = tonumber(radialCfg.deadzone)
    if not dz or dz < 0 then return 0.25 end
    if dz > 0.95 then return 0.95 end
    return dz
end

local function getSelectionTimeoutMs()
    local t = tonumber(radialCfg.selectionTimeoutMs)
    if not t or t < 50 then return 450 end
    if t > 1000 then return 1000 end
    return t
end

local radialActionsLocale = radialLocales.actions or {}
local panicActionsLocale = (radialActionsLocale.panic and radialActionsLocale.panic.states) or {}
local tabletActionsLocale = (radialActionsLocale.tablet and radialActionsLocale.tablet.states) or {}
local removePropActionsLocale = (radialActionsLocale.removeProp and radialActionsLocale.removeProp.states) or {}

local panicErrorStates = {
    disabled = { key = "radial.actions.panic.states.disabled", fallback = panicActionsLocale.disabled or "Panic button is unavailable." },
    not_on_duty = { key = "radial.actions.panic.states.notOnDuty", fallback = panicActionsLocale.notOnDuty or panicLocales.NotOnDuty or "Go on duty to use the panic button." },
    not_authorized = { key = "radial.actions.panic.states.notAuthorized", fallback = panicActionsLocale.notAuthorized or "You are not authorised to use the panic button." },
    failed = { key = "radial.errors.generic", fallback = genericErrorMsg }
}

local tabletErrorStates = {
    not_on_duty = { key = "radial.actions.tablet.states.notOnDuty", fallback = tabletActionsLocale.notOnDuty or "Go on duty to use the tablet." },
    not_authorized = { key = "radial.actions.tablet.states.notAuthorized", fallback = tabletActionsLocale.notAuthorized or "You are not authorised to use the tablet." },
    missing_item = { key = "radial.actions.tablet.states.missingItem", fallback = tabletActionsLocale.missingItem or "You need a tablet to do this." },
    failed = { key = "radial.errors.generic", fallback = genericErrorMsg }
}

local function buildPanicAction()
    local action = {
        id = "panic",
        icon = panicCfg.icon or "Siren",
        labelKey = "radial.actions.panic.label",
        label = panicCfg.label or panicLocales.Title or "Panic button",
        descriptionKey = "radial.actions.panic.description",
        description = panicCfg.description or "Trigger a panic alert for your current location."
    }

    if not IS_PANIC_ENABLED then
        local err = panicErrorStates.disabled
        action.disabled = true
        action.disabledReasonKey = err.key
        action.disabledReason = err.fallback
        return action
    end

    if not isPlayerAuthorizedForPanic() then
        local err = panicErrorStates.not_authorized
        action.disabled = true
        action.disabledReasonKey = err.key
        action.disabledReason = err.fallback
        return action
    end

    if panicCfg.requireOnDuty ~= false and not isPlayerOnDuty() then
        local err = panicErrorStates.not_on_duty
        action.disabled = true
        action.disabledReasonKey = err.key
        action.disabledReason = err.fallback
        return action
    end

    return action
end

local function buildTabletAction()
    local action = {
        id = "tablet",
        icon = tabletCfg.icon or "Tablet",
        labelKey = "radial.actions.tablet.label",
        label = tabletCfg.label or "Open tablet",
        descriptionKey = "radial.actions.tablet.description",
        description = tabletCfg.description or "Open the tablet interface."
    }

    if not isPlayerEmployed() then
        local err = tabletErrorStates.not_authorized
        action.disabled = true
        action.disabledReasonKey = err.key
        action.disabledReason = err.fallback
        return action
    end

    if not isPlayerOnDuty() then
        local err = tabletErrorStates.not_on_duty
        action.disabled = true
        action.disabledReasonKey = err.key
        action.disabledReason = err.fallback
        return action
    end

    if Sky_Jobs and Sky_Jobs.Tablet and Sky_Jobs.Tablet.HasRequiredItem and Sky_Jobs.Tablet.HasRequiredItem() ~= true then
        local err = tabletErrorStates.missing_item
        action.disabled = true
        action.disabledReasonKey = err.key
        action.disabledReason = err.fallback
        return action
    end

    return action
end

local function buildRemovePropAction()
    local action = {
        id = "remove_trunk_prop",
        icon = (Config and Config.JobGarage and Config.JobGarage.trunk and Config.JobGarage.trunk.icon) or "Trash2",
        labelKey = "radial.actions.removeProp.label",
        label = "Remove Prop",
        descriptionKey = "radial.actions.removeProp.description",
        description = "Remove a nearby placed prop."
    }

    local target = exports[GetCurrentResourceName()]:getNearbyTrunkPropTarget(PROP_REMOVE_DISTANCE)
    if not target then
        action.disabled = true
        action.disabledReasonKey = "radial.actions.removeProp.states.noNearby"
        action.disabledReason = removePropActionsLocale.noNearby or "No placed prop nearby."
        return action
    end

    return action
end

local function buildAllRadialActions()
    local actions = {}

    if IS_TABLET_ENABLED then
        table.insert(actions, buildTabletAction())
    end

    if IS_PANIC_ENABLED and isPlayerAuthorizedForPanic() then
        table.insert(actions, buildPanicAction())
    end

    table.insert(actions, buildRemovePropAction())

    actionProviderMap = {}
    for _, resourceName in ipairs(resolveExternalProviders()) do
        if type(resourceName) == "string" and resourceName ~= "" then
            local state = GetResourceState(resourceName)
            if state == "started" or state == "starting" then
                local ok, extActions = pcall(function()
                    return exports[resourceName]:getRadialActions()
                end)

                if ok and type(extActions) == "table" then
                    for _, act in ipairs(extActions) do
                        if act and type(act.id) == "string" and act.id ~= "" then
                            if not (internalActionsMap and internalActionsMap[act.id]) and not actionProviderMap[act.id] then
                                actionProviderMap[act.id] = resourceName
                                table.insert(actions, act)
                            end
                        end
                    end
                end
            end
        end
    end

    return actions
end

local function filterEnabledActions(actions)
    if type(actions) ~= "table" then return {} end
    local filtered = {}
    for _, act in ipairs(actions) do
        if act and act.disabled ~= true then
            table.insert(filtered, act)
        end
    end
    return filtered
end

local function getRadialActionById(actionId)
    if type(actionId) ~= "string" or actionId == "" then return nil end
    for _, act in ipairs(buildAllRadialActions()) do
        if act and act.id == actionId then
            return act
        end
    end
    return nil
end

local function parseErrorPayload(err)
    if type(err) == "table" then
        return err.key, err.fallback or genericErrorMsg
    end
    if type(err) == "string" and err ~= "" then
        return err, err
    end
    return "radial.errors.generic", genericErrorMsg
end

local function handleActionExecutionResult(actionId, closeOnSuccess, context)
    if type(actionId) ~= "string" or actionId == "" then
        return false, { key = "radial.errors.generic", fallback = genericErrorMsg }
    end

    local handler = internalActionsMap and internalActionsMap[actionId]
    if handler then
        return handler(context)
    end

    local providerRes = actionProviderMap[actionId]
    if not providerRes then
        getRadialActionById(actionId)
        providerRes = actionProviderMap[actionId]
    end

    if not providerRes then
        return false, { key = "radial.errors.generic", fallback = genericErrorMsg }
    end

    if closeOnSuccess then
        closeRadialMenu()
    end

    local ok, success, err = pcall(function()
        return exports[providerRes]:triggerRadialMenuAction(actionId, context)
    end)

    if not ok then
        return false, { key = "radial.errors.generic", fallback = genericErrorMsg }
    end

    if success then return true end
    return false, err
end

local function triggerRadialActionDirectly(actionId, context)
    local act = actionRegistry[actionId]
    if not act or act.disabled == true then
        return false, { key = "radial.errors.generic", fallback = genericErrorMsg }
    end

    return handleActionExecutionResult(actionId, false, context)
end

local function parseTargetTypes(oxTarget)
    if oxTarget == false then return false end
    local val = oxTarget
    if type(val) == "table" then
        val = val.types or val.type or val.targetTypes
    end
    if val == nil then return nil end

    if type(val) == "string" then
        return { [val] = true }
    end

    if type(val) ~= "table" then return nil end

    local res = {}
    for k, v in pairs(val) do
        if type(v) == "string" then
            res[v] = true
        elseif v == true and type(k) == "string" then
            res[k] = true
        end
    end

    return next(res) and res or nil
end

local function validateTargetEntityType(entity, targetTypes)
    if not targetTypes then return true end
    if not (entity and entity ~= 0 and DoesEntityExist(entity)) then return false end

    if targetTypes.any then return true end
    local eType = GetEntityType(entity)

    if targetTypes.ped and eType == 1 then return true end

    if targetTypes.player and eType == 1 then
        if IsPedAPlayer(entity) then
            local pIdx = NetworkGetPlayerIndexFromPed(entity)
            if pIdx and pIdx ~= -1 then
                local sId = GetPlayerServerId(pIdx)
                return sId ~= nil and sId > 0
            end
        end
    end

    if targetTypes.npc and eType == 1 then
        return not IsPedAPlayer(entity)
    end

    if targetTypes.vehicle and eType == 2 then return true end
    if targetTypes.object and eType == 3 then return true end

    return false
end

local function formatTargetTypesSignature(typesMap)
    if not typesMap then return "" end
    local keys = {}
    for k in pairs(typesMap) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return table.concat(keys, ",")
end

local function buildOxTargetOption(act)
    local optionName = string.format("sky_jobs_base:radial:%s", act.id)
    local label = act.label or act.description or act.id
    local targetTypes = parseTargetTypes(act.oxTarget)

    local option = {
        name = optionName,
        icon = "fa-solid fa-circle",
        label = label,
        canInteract = function(entity)
            if not (oxTargetCfg.enabled == true and Sky.Target and Sky.Target.IsEnabled and Sky.Target.IsEnabled()) then
                return false
            end
            if IsPauseMenuActive() or radialState.open or (Sky.Functions and Sky.Functions.IsPlayerDead and Sky.Functions.IsPlayerDead()) then
                return false
            end
            if not isPlayerAuthorizedForRadial() then
                return false
            end
            if not validateTargetEntityType(entity, targetTypes) then
                return false
            end
            return actionRegistry[act.id] ~= nil
        end,
        onSelect = function(data)
            local ok, err = triggerRadialActionDirectly(act.id, data)
            if ok then return end

            local errKey, errFallback = parseErrorPayload(err)
            showNotification(errFallback)
        end
    }

    return optionName, option
end

local function clearOxTargetGlobalOptions()
    if next(oxTargetRegisteredKeys) and Sky.Target and Sky.Target.IsEnabled and Sky.Target.IsEnabled() then
        local nameList = {}
        for name in pairs(oxTargetRegisteredKeys) do
            table.insert(nameList, name)
        end
        if #nameList > 0 then
            pcall(function()
                Sky.Target.RemoveGlobalOption(nameList)
            end)
        end
    end

    oxTargetRegisteredKeys = {}
    currentOxTargetSignature = nil
    actionRegistry = {}
    actionProviderMap = {}
end

local function syncOxTargetGlobalOptions()
    if not (oxTargetCfg.enabled == true and Sky.Target and Sky.Target.IsEnabled and Sky.Target.IsEnabled()) then
        clearOxTargetGlobalOptions()
        return
    end

    if not isPlayerAuthorizedForRadial() then
        clearOxTargetGlobalOptions()
        return
    end

    local actions = buildAllRadialActions()
    local oxOptions = {}
    local sigParts = {}
    local regMap = {}
    local provMap = {}

    for _, act in ipairs(actions) do
        if act and type(act.id) == "string" and act.id ~= "" and act.id ~= "tablet" and act.oxTarget ~= false then
            local optName, optData = buildOxTargetOption(act)
            table.insert(oxOptions, optData)
            regMap[act.id] = act
            provMap[act.id] = actionProviderMap[act.id]

            local targetSig = formatTargetTypesSignature(parseTargetTypes(act.oxTarget))
            table.insert(sigParts, table.concat({ optName, tostring(act.label or ""), tostring(act.description or ""), targetSig }, "|"))
        end
    end

    local newSignature = table.concat(sigParts, ";")
    if currentOxTargetSignature == newSignature then
        actionRegistry = regMap
        actionProviderMap = provMap
        return
    end

    clearOxTargetGlobalOptions()
    if #oxOptions == 0 then
        actionRegistry = regMap
        actionProviderMap = provMap
        currentOxTargetSignature = newSignature
        return
    end

    Sky.Target.AddGlobalOption(oxOptions)
    for _, opt in ipairs(oxOptions) do
        oxTargetRegisteredKeys[opt.name] = true
    end

    actionRegistry = regMap
    actionProviderMap = provMap
    currentOxTargetSignature = newSignature
end

local function triggerPanicAlert()
    closeRadialMenu()
    if not IS_PANIC_ENABLED then
        return false, panicErrorStates.disabled
    end
    if not isPlayerAuthorizedForPanic() then
        return false, panicErrorStates.not_authorized
    end
    if panicCfg.requireOnDuty ~= false and not isPlayerOnDuty() then
        return false, panicErrorStates.not_on_duty
    end

    exports[GetCurrentResourceName()]:triggerPanicAlert()
    return true
end

local function openTabletFromRadial()
    closeRadialMenu()
    if not IS_TABLET_ENABLED then
        return false, { key = "radial.errors.generic", fallback = genericErrorMsg }
    end
    if not isPlayerEmployed() then
        return false, tabletErrorStates.not_authorized
    end
    if not isPlayerOnDuty() then
        return false, tabletErrorStates.not_on_duty
    end

    local ok, err = Sky_Jobs.Tablet.OpenLast({ jobColor = getJobColor() })
    if not ok then
        return false, err or tabletErrorStates.failed
    end
    return true
end

local function removeTrunkPropFromRadial()
    closeRadialMenu()
    local ok, errKey = exports[GetCurrentResourceName()]:removeNearbyTrunkProp(PROP_REMOVE_DISTANCE)
    if ok then return true end

    if errKey == "radial.actions.removeProp.states.noNearby" then
        return false, { key = errKey, fallback = removePropActionsLocale.noNearby or "No placed prop nearby." }
    end

    return false, { key = "radial.actions.removeProp.states.failed", fallback = removePropActionsLocale.failed or "Failed to remove prop." }
end

internalActionsMap = {
    tablet = openTabletFromRadial,
    remove_trunk_prop = removeTrunkPropFromRadial,
    panic = triggerPanicAlert
}

local function calculateAnalogSelection(actions)
    if type(actions) ~= "table" or #actions == 0 then return nil end

    local dx = GetDisabledControlNormal(0, 1)
    local dy = GetDisabledControlNormal(0, 2)

    local mag = math.sqrt((dx * dx) + (dy * dy))
    if mag < getDeadzoneThreshold() then return nil end

    local nx = dx / mag
    local ny = dy / mag

    local count = #actions
    local stepDeg = 360.0 / count

    local bestIdx = nil
    local maxDot = -2.0

    for i = 1, count do
        local angleDeg = ((i - 1) * stepDeg) - 90.0
        local rad = math.rad(angleDeg)
        local ax = math.cos(rad)
        local ay = math.sin(rad)

        local dot = (ax * nx) + (ay * ny)
        if dot > maxDot then
            maxDot = dot
            bestIdx = i
        end
    end

    return (bestIdx and actions[bestIdx]) and actions[bestIdx].id or nil
end

local function startMouseSelectionThread()
    if isMouseSelectionThreadRunning then return end
    isMouseSelectionThreadRunning = true

    CreateThread(function()
        while radialState.open and isHoldMode() do
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)

            local selected = calculateAnalogSelection(radialState.actions)
            if selected ~= nil then
                lastActionTriggerTime = GetGameTimer()
                setSelectedAction(selected)
            elseif radialState.selectedId ~= nil then
                if (GetGameTimer() - lastActionTriggerTime) > getSelectionTimeoutMs() then
                    setSelectedAction(nil)
                end
            end
            Wait(0)
        end
        isMouseSelectionThreadRunning = false
    end)
end

local function startDisableInputsThread()
    if isDisableInputThreadRunning then return end
    isDisableInputThreadRunning = true

    CreateThread(function()
        local disabledControls = { 1, 2, 24, 25, 37, 44, 68, 69, 70, 91, 92, 140, 141, 142, 257, 263, 264 }
        while radialState.open do
            for _, ctrl in ipairs(disabledControls) do
                DisableControlAction(0, ctrl, true)
            end
            Wait(0)
        end
        isDisableInputThreadRunning = false
    end)
end

function sendNuiRadialMessage(data)
    SendNUIMessage(data or {})
end

function generateNextSequence()
    radialState.sequence = radialState.sequence + 1
    return radialState.sequence
end

function sendCloseRadialNui(seq)
    sendNuiRadialMessage({
        type = "radial:close",
        sequence = seq or radialState.sequence
    })
end

function safeCloseRadialNui(seq)
    local currentSeq = seq or generateNextSequence()
    CreateThread(function()
        Wait(0)
        sendCloseRadialNui(currentSeq)
        Wait(75)
        if not radialState.open then
            sendCloseRadialNui(currentSeq)
        end
    end)
end

function showNotification(msg)
    local title = radialLocales.title or "Duty actions"
    Sky.Show.Notification(title, msg or genericErrorMsg, "info")
end

function setSelectedAction(actionId)
    if radialState.selectedId == actionId then return end
    radialState.selectedId = actionId

    sendNuiRadialMessage({
        type = "radial:highlight",
        actionId = actionId or false
    })
end

function playSoundPreset(soundName)
    PlaySoundFrontend(-1, soundName, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end

function closeRadialMenu()
    if not radialState.open then return end

    local seq = generateNextSequence()
    radialState.open = false
    radialState.actions = {}

    setSelectedAction(nil)

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    playSoundPreset("BACK")
    sendCloseRadialNui(seq)
end

function openRadialMenu()
    if not IS_RADIAL_ENABLED then return end
    if radialState.open or IsPauseMenuActive() or IsNuiFocused() then return end
    if Sky.Functions and Sky.Functions.IsPlayerDead and Sky.Functions.IsPlayerDead() then return end
    if not isPlayerAuthorizedForRadial() then return end

    local actions = filterEnabledActions(buildAllRadialActions())
    local hasAny = false
    for _, act in ipairs(actions) do
        if act then
            hasAny = true
            break
        end
    end

    if not hasAny then
        showNotification(radialLocales.empty or "No actions available right now.")
        return
    end

    radialState.open = true
    radialState.actions = actions
    radialState.mode = isHoldMode() and "hold" or "toggle"
    radialState.selectedId = nil

    local seq = generateNextSequence()
    lastActionTriggerTime = 0

    SetNuiFocus(true, radialState.mode ~= "hold")
    SetNuiFocusKeepInput(true)

    playSoundPreset("SELECT")
    startDisableInputsThread()

    if isHoldMode() then
        startMouseSelectionThread()
    end

    sendNuiRadialMessage({
        type = "radial:open",
        titleKey = "radial.title",
        title = radialLocales.title or "Duty actions",
        hintKey = "radial.hint",
        hint = radialLocales.hint or "Select an action to perform.",
        hotkey = radialState.hotkey,
        hotkeyLabel = radialState.hotkeyLabel,
        mode = radialState.mode,
        sequence = seq,
        actions = actions,
        jobColor = getJobColor()
    })
end

function confirmSelectedAction()
    if not radialState.open then
        safeCloseRadialNui()
        return
    end

    local actionId = radialState.selectedId
    closeRadialMenu()

    if type(actionId) ~= "string" or actionId == "" then
        safeCloseRadialNui(radialState.sequence)
        return
    end

    local ok, err = handleActionExecutionResult(actionId, false, nil)
    if not ok then
        local errKey, errFallback = parseErrorPayload(err)
        showNotification(errFallback)
    end
end

if IS_RADIAL_ENABLED then
    if isHoldMode() then
        RegisterCommand("+sky_jobs_radial", function()
            local now = GetGameTimer()
            if isRadialHoldPressed or now < radialHoldReleaseTime then return end
            isRadialHoldPressed = true
            openRadialMenu()
        end, false)

        RegisterCommand("-sky_jobs_radial", function()
            if not isRadialHoldPressed then return end
            isRadialHoldPressed = false
            radialHoldReleaseTime = GetGameTimer() + 150
            confirmSelectedAction()
        end, false)

        RegisterKeyMapping("+sky_jobs_radial", radialLocales.title or "Duty radial menu", "keyboard", radialState.hotkey)
    else
        RegisterCommand("sky_jobs_radial", function()
            if radialState.open then
                closeRadialMenu()
            else
                openRadialMenu()
            end
        end, false)

        RegisterKeyMapping("sky_jobs_radial", radialLocales.title or "Duty radial menu", "keyboard", radialState.hotkey)
    end
end

RegisterNUICallback("radial:close", function(data, cb)
    closeRadialMenu()
    cb({ success = true })
end)

RegisterNUICallback("radial:select", function(data, cb)
    if type(data) ~= "table" or type(data.actionId) ~= "string" then
        cb({ success = false, errorKey = "radial.errors.generic" })
        return
    end

    local ok, err = handleActionExecutionResult(data.actionId, true, nil)
    if ok then
        cb({ success = true })
        return
    end

    local errKey, errFallback = parseErrorPayload(err)
    showNotification(errFallback)
    cb({ success = false, errorKey = errKey, error = errFallback })
end)

RegisterNetEvent("sky_jobs_base:jobs:registered", function(jobName)
    local norm = normalizeString(jobName)
    if norm then
        registeredJobMap[norm] = true
    end
end)

RegisterNetEvent("sky_base:playerLoaded", fetchRegisteredJobs)
AddEventHandler("playerSpawned", fetchRegisteredJobs)

CreateThread(function()
    Wait(1000)
    fetchRegisteredJobs()
end)

CreateThread(function()
    Wait(1500)
    while true do
        syncOxTargetGlobalOptions()
        Wait(2000)
    end
end)

AddEventHandler("onResourceStop", function(resName)
    if resName == GetCurrentResourceName() then
        clearOxTargetGlobalOptions()
        closeRadialMenu()
    end
end)

registerExport("openRadialMenu", openRadialMenu)
registerExport("getRadialActions", buildAllRadialActions)

registerExport("getRadialAction", function(actionId)
    return getRadialActionById(actionId)
end)

registerExport("isRadialMenuActionAvailable", function(actionId)
    if type(actionId) ~= "string" then return false end
    local act = exports[GetCurrentResourceName()]:getRadialAction(actionId)
    return act ~= nil
end)

registerExport("triggerRadialMenuAction", function(actionId, context)
    return handleActionExecutionResult(actionId, false, context)
end)
