if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/custom_tuning.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/custom_tuning.lua
--  Deobfuscated & Cleaned
-- =====================================================

CustomTuning = {}

local HANDLING_FIELDS = {
    "fInitialDragCoeff",
    "fDriveBiasFront",
    "fInitialDriveForce",
    "fInitialDriveMaxFlatVel",
    "fDriveInertia",
    "nInitialDriveGears",
    "fTractionCurveMax",
    "fTractionCurveMin",
    "fTractionLossMult",
    "fLowSpeedTractionLossMult",
    "fBrakeForce",
    "fHandBrakeForce",
    "fBrakeBiasFront",
    "fSteeringLock"
}

local FIELD_TYPES = {
    nInitialDriveGears = "int"
}

TuningState.customHandlingSelections = TuningState.customHandlingSelections or {}
TuningState.customHandlingSelectionsByNetId = TuningState.customHandlingSelectionsByNetId or {}
TuningState.customHandlingSelectionsByPlate = TuningState.customHandlingSelectionsByPlate or {}
TuningState.customHandlingAppliedByNetId = TuningState.customHandlingAppliedByNetId or {}
TuningState.customHandlingSessionState = TuningState.customHandlingSessionState or nil

-- ── Helpers ──────────────────────────────────────────

local function filterValidHandlingFields(rawTable)
    local result = {}
    if type(rawTable) ~= "table" then return result end
    for _, field in ipairs(HANDLING_FIELDS) do
        local num = tonumber(rawTable[field])
        if num ~= nil then
            result[field] = num
        end
    end
    return result
end

local function readCurrentHandlingValues(vehicle)
    local result = {}
    for _, field in ipairs(HANDLING_FIELDS) do
        if FIELD_TYPES[field] == "int" then
            result[field] = GetVehicleHandlingInt(vehicle, "CHandlingData", field)
        else
            result[field] = GetVehicleHandlingFloat(vehicle, "CHandlingData", field)
        end
    end
    return result
end

local function getNormalizedPlate(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end
    local plate = Sky.Math.Trim(GetVehicleNumberPlateText(vehicle))
    return (plate ~= "" and plate) or nil
end

local function sanitizeSelections(rawSelections)
    local result = {}
    if type(rawSelections) ~= "table" then return result end
    for key, val in pairs(rawSelections) do
        local strKey = tostring(key or "")
        local numVal = tonumber(val)
        if strKey ~= "" and numVal ~= nil then
            result[strKey] = math.floor(numVal)
        end
    end
    return result
end

local function computeSelectionsSignature(selections)
    local keys = {}
    for k in pairs(selections or {}) do
        keys[#keys + 1] = tostring(k)
    end
    table.sort(keys)

    local parts = {}
    for _, k in ipairs(keys) do
        local idx = math.floor(tonumber(selections[k]) or 0)
        parts[#parts + 1] = string.format("%s:%d", k, idx)
    end
    return table.concat(parts, "|")
end

local function getProfileConfig(profileKey)
    local profiles = (customHandlingConfig and customHandlingConfig.profiles) or {}
    local prof = profiles[profileKey]
    if type(prof) == "table" and prof.enabled ~= false then
        return prof
    end
    return nil
end

local function getSortedProfileKeys()
    local cfg = customHandlingConfig or {}
    local profiles = cfg.profiles or {}
    local result = {}
    local seen = {}

    for _, k in ipairs(type(cfg.profileOrder) == "table" and cfg.profileOrder or {}) do
        local keyStr = tostring(k or "")
        if keyStr ~= "" and not seen[keyStr] and type(profiles[keyStr]) == "table" then
            result[#result + 1] = keyStr
            seen[keyStr] = true
        end
    end

    local remaining = {}
    for k, v in pairs(profiles) do
        if not seen[k] and type(v) == "table" then
            remaining[#remaining + 1] = { key = k, order = tonumber(v.order) or 999999 }
        end
    end

    table.sort(remaining, function(a, b)
        if a.order == b.order then return a.key < b.key end
        return a.order < b.order
    end)

    for _, item in ipairs(remaining) do
        result[#result + 1] = item.key
    end

    return result
end

local function getProfilePreset(profileKey, index)
    local prof = getProfileConfig(profileKey)
    if not prof then return nil end
    local presets = prof.presets or {}
    if #presets <= 0 then return nil end

    local idx = math.floor(tonumber(index) or 0)
    if idx < 0 then idx = 0 end
    if idx > #presets - 1 then idx = #presets - 1 end

    return presets[idx + 1], idx
end

local function cleanModelName(modelName)
    local str = tostring(modelName or ""):match("^%s*(.-)%s*$")
    return (str ~= "" and str:lower()) or nil
end

local function isDrivetrainWhitelisted(vehicle)
    local cfg = (customHandlingConfig and customHandlingConfig.drivetrainWhitelist) or {}
    if cfg.enabled ~= true then return true end

    local models = type(cfg.models) == "table" and cfg.models or {}
    local vehModel = (vehicle ~= 0 and DoesEntityExist(vehicle)) and GetEntityModel(vehicle) or 0
    if vehModel == 0 then return false end

    local modelName = cleanModelName(GetDisplayNameFromVehicleModel(vehModel))
    if not modelName then return false end

    for _, name in ipairs(models) do
        if cleanModelName(name) == modelName then return true end
    end
    return false
end

local function getAllowedPresetsForProfile(profileKey, profileCfg, vehicle)
    if profileKey ~= "drivetrain" then return nil end
    if isDrivetrainWhitelisted(vehicle) then return nil end
    return {}
end

local function isPresetAllowedForProfile(profileKey, presetIndex, vehicle)
    local prof = getProfileConfig(profileKey)
    if not prof then return false end

    local allowed = getAllowedPresetsForProfile(profileKey, prof, vehicle)
    if allowed == nil then return true end

    local idx = math.floor(tonumber(presetIndex) or 0)
    for _, allowedIdx in ipairs(allowed) do
        if idx == allowedIdx then return true end
    end
    return false
end

local function applyPresetToHandlingData(baseValues, presetObj)
    if type(presetObj) ~= "table" then return end
    local handling = type(presetObj.handling) == "table" and presetObj.handling or {}

    for field, val in pairs(handling) do
        if baseValues[field] ~= nil then
            local num = tonumber(val)
            if num ~= nil then baseValues[field] = num end
        end
    end

    local handlingMul = type(presetObj.handlingMul) == "table" and presetObj.handlingMul or {}
    for field, mul in pairs(handlingMul) do
        local base = baseValues[field]
        local factor = tonumber(mul)
        if base ~= nil and factor ~= nil then
            baseValues[field] = base * factor
        end
    end
end

local function computeTargetHandlingValues(vehicle, selections)
    local values = readCurrentHandlingValues(vehicle)
    local profileKeys = getSortedProfileKeys()

    for i = #profileKeys, 1, -1 do
        local pKey = profileKeys[i]
        local presetIdx = (selections or {})[pKey]
        local preset = getProfilePreset(pKey, presetIdx)

        if type(preset) == "table" and type(preset.handlingMul) == "table" then
            for field, mul in pairs(preset.handlingMul) do
                local base = values[field]
                local factor = tonumber(mul)
                if base ~= nil and factor ~= nil and factor ~= 0 then
                    values[field] = base / factor
                end
            end
        end
    end
    return values
end

local function updateStateSelections(vehicle, rawSelections)
    local selections = sanitizeSelections(rawSelections)
    TuningState.customHandlingSelections = selections

    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId and netId > 0 then
        TuningState.customHandlingSelectionsByNetId[netId] = sanitizeSelections(selections)
    end

    local plate = getNormalizedPlate(vehicle)
    if plate then
        TuningState.customHandlingSelectionsByPlate[plate] = sanitizeSelections(selections)
    end
end

local function getSelectionsForVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return {} end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId and netId > 0 then
        local sel = sanitizeSelections(TuningState.customHandlingSelectionsByNetId[netId])
        if next(sel) then return sel end
    end

    local plate = getNormalizedPlate(vehicle)
    if plate then
        local sel = sanitizeSelections(TuningState.customHandlingSelectionsByPlate[plate])
        if next(sel) then return sel end
    end

    return {}
end

local function fetchServerTuningProperties(vehicle)
    local plate = getNormalizedPlate(vehicle)
    if not plate then return {}, false end

    local res = Sky.Cb.Trigger("sky_mechanicjob:tuning:getProperties", { plate = plate })
    if not (type(res) == "table" and res.success == true) then
        return {}, false
    end

    local props = (type(res.properties) == "table" and res.properties._skyMechanicTuning) or nil
    local customHandling = (type(props) == "table" and type(props.customHandling) == "table" and props.customHandling.profiles) or nil

    return sanitizeSelections(customHandling), true
end

local function getCurrentSelectionsFromState()
    local selections = {}
    local options = TuningState.options or {}

    for _, opt in ipairs(options) do
        local profileKey = opt.customHandlingProfileKey
        local presetIdx = nil

        if not profileKey and type(opt.customHandlingExtension) == "table" then
            profileKey = tostring(opt.customHandlingExtension.profileKey or "")
            local map = opt.customHandlingExtension.valueToPresetIndex or {}
            local valStr = tostring(math.floor(tonumber(opt.value) or -9999))
            presetIdx = tonumber(map[valStr])
        elseif profileKey then
            presetIdx = tonumber(opt.value)
        end

        if profileKey and presetIdx ~= nil then
            selections[tostring(profileKey)] = math.floor(presetIdx)
        end
    end
    return selections
end

-- ── Custom Tuning Core Methods ───────────────────────

function CustomTuning.ApplyHandling(vehicle, selections, baseValues)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    if Config.ToggleFeatures and Config.ToggleFeatures.customHandling == false then return true end

    local handlingData = filterValidHandlingFields(baseValues)
    if not next(handlingData) then
        handlingData = CustomTuning.EnsureBaseline(vehicle)
    end

    for _, pKey in ipairs(getSortedProfileKeys()) do
        local selectedIdx = selections[pKey]
        if isPresetAllowedForProfile(pKey, selectedIdx, vehicle) then
            local preset = getProfilePreset(pKey, selectedIdx)
            applyPresetToHandlingData(handlingData, preset)
        else
            print(string.format("[sky_mechanicjob][custom_tuning] preset skipped: vehicle=%s profile=%s preset=%s is not whitelisted",
                tostring(vehicle), tostring(pKey), tostring(selections[pKey])))
        end
    end

    for _, field in ipairs(HANDLING_FIELDS) do
        local targetVal = tonumber(handlingData[field])
        if targetVal ~= nil then
            local isInt = (FIELD_TYPES[field] == "int")
            local beforeVal = isInt
                and GetVehicleHandlingInt(vehicle, "CHandlingData", field)
                or GetVehicleHandlingFloat(vehicle, "CHandlingData", field)

            if isInt then
                SetVehicleHandlingInt(vehicle, "CHandlingData", field, math.floor(targetVal))
            else
                SetVehicleHandlingFloat(vehicle, "CHandlingData", field, targetVal)
            end

            local afterVal = isInt
                and GetVehicleHandlingInt(vehicle, "CHandlingData", field)
                or GetVehicleHandlingFloat(vehicle, "CHandlingData", field)

            print(string.format("[sky_mechanicjob][custom_tuning] handling changed: vehicle=%s field=%s before=%s target=%s after=%s",
                tostring(vehicle), tostring(field), tostring(beforeVal), tostring(targetVal), tostring(afterVal)))
        end
    end

    ModifyVehicleTopSpeed(vehicle, 1.0)
    updateStateSelections(vehicle, selections)

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId and netId > 0 then
        TuningState.customHandlingAppliedByNetId[netId] = computeSelectionsSignature(selections)
    end

    return true
end

function CustomTuning.ApplyPersistedState(vehicle, serverProperties, force)
    local selections = sanitizeSelections((type(serverProperties) == "table" and serverProperties.profiles) or nil)
    updateStateSelections(vehicle, selections)

    if not next(selections) then
        print("[sky_mechanicjob][custom_tuning] apply skipped: no persisted custom handling selections")
        return true
    end

    local netId = (vehicle ~= 0 and DoesEntityExist(vehicle)) and NetworkGetNetworkIdFromEntity(vehicle) or 0
    local sig = computeSelectionsSignature(selections)

    if not force and netId and netId > 0 then
        if TuningState.customHandlingAppliedByNetId[netId] == sig then
            print(string.format("[sky_mechanicjob][custom_tuning] apply skipped: already applied netId=%s signature=%s", tostring(netId), tostring(sig)))
            return true
        end
    end

    print(string.format("[sky_mechanicjob][custom_tuning] applying persisted custom handling: vehicle=%s netId=%s force=%s signature=%s",
        tostring(vehicle), tostring(netId), tostring(force == true), tostring(sig)))

    return CustomTuning.ApplyHandling(vehicle, selections, CustomTuning.EnsureBaseline(vehicle))
end

function CustomTuning.BuildPersistedState(vehicle)
    local selections = getSelectionsForVehicle(vehicle)

    if TuningState.vehicle == vehicle then
        local current = getCurrentSelectionsFromState()
        if next(current) then
            selections = current
        else
            selections = sanitizeSelections(TuningState.customHandlingSelections)
        end
    end

    return next(selections) and { profiles = selections } or nil
end

function CustomTuning.GetSelectedProfileIndex(profileKey, vehicle)
    local key = tostring(profileKey or "")
    if key == "" then return nil end

    local localVal = tonumber((TuningState.customHandlingSelections or {})[key])
    if localVal ~= nil then return math.floor(localVal) end

    local serverSelections, ok = fetchServerTuningProperties(vehicle)
    if not ok then return nil end

    local serverVal = tonumber(serverSelections[key])
    if serverVal ~= nil then return math.floor(serverVal) end

    return nil
end

function CustomTuning.UseVehicleSelections(vehicle)
    local selections, ok = fetchServerTuningProperties(vehicle)
    if not ok then
        selections = getSelectionsForVehicle(vehicle)
    end
    TuningState.customHandlingSelections = selections
end

function CustomTuning.EnsureBaseline(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][custom_tuning] baseline capture failed: vehicle is missing")
        return {}
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local base = TuningState.customHandlingBase

    if type(base) == "table" and base.vehicleNetId == netId and type(base.values) == "table" then
        return filterValidHandlingFields(base.values)
    end

    local currentValues = readCurrentHandlingValues(vehicle)
    local selections = sanitizeSelections(TuningState.customHandlingSelections)

    local rawBase = currentValues
    if netId and netId > 0 then
        rawBase = computeTargetHandlingValues(vehicle, selections)
    end

    TuningState.customHandlingBase = {
        vehicleNetId = netId,
        values = filterValidHandlingFields(rawBase)
    }

    return filterValidHandlingFields(rawBase)
end

function CustomTuning.CaptureSessionState(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][custom_tuning] session capture failed: vehicle is missing")
        TuningState.customHandlingSessionState = nil
        return
    end

    TuningState.customHandlingSessionState = {
        vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle),
        plate = getNormalizedPlate(vehicle),
        values = readCurrentHandlingValues(vehicle),
        selections = sanitizeSelections(TuningState.customHandlingSelections)
    }
end

function CustomTuning.RestoreSessionState(vehicle)
    local session = TuningState.customHandlingSessionState
    if type(session) ~= "table" then return true end

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][custom_tuning] session restore failed: vehicle is missing")
        return false
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local sessionNetId = tonumber(session.vehicleNetId)

    if sessionNetId and sessionNetId > 0 and netId and netId > 0 and sessionNetId ~= netId then
        print(string.format("[sky_mechanicjob][custom_tuning] session restore failed: vehicle netId changed from %s to %s", tostring(sessionNetId), tostring(netId)))
        return false
    end

    local values = filterValidHandlingFields(session.values)
    if not next(values) then
        print("[sky_mechanicjob][custom_tuning] session restore failed: baseline values are missing")
        return false
    end

    for _, field in ipairs(HANDLING_FIELDS) do
        local val = tonumber(values[field])
        if val ~= nil then
            if FIELD_TYPES[field] == "int" then
                SetVehicleHandlingInt(vehicle, "CHandlingData", field, math.floor(val))
            else
                SetVehicleHandlingFloat(vehicle, "CHandlingData", field, val)
            end
        end
    end

    ModifyVehicleTopSpeed(vehicle, 1.0)
    updateStateSelections(vehicle, session.selections)

    if netId and netId > 0 then
        TuningState.customHandlingAppliedByNetId[netId] = computeSelectionsSignature(session.selections)
    end

    return true
end

function CustomTuning.ApplyProfiles(vehicle)
    return CustomTuning.ApplyHandling(
        vehicle,
        getCurrentSelectionsFromState(),
        CustomTuning.EnsureBaseline(vehicle)
    )
end

function CustomTuning.GetCategoryByOptionId(optionId)
    local profiles = (customHandlingConfig and customHandlingConfig.profiles) or {}
    for _, prof in pairs(profiles) do
        if type(prof) == "table" and tostring(prof.optionId or "") == optionId then
            local cat = tostring(prof.requiredCategory or "")
            if cat ~= "" then return cat end
        end
    end
    return nil
end

function CustomTuning.GetInstallFlowByOptionId(optionId)
    local profiles = (customHandlingConfig and customHandlingConfig.profiles) or {}
    for _, prof in pairs(profiles) do
        if type(prof) == "table" and tostring(prof.optionId or "") == optionId then
            local flow = tostring(prof.installFlow or "")
            if flow ~= "" then return flow end
        end
    end
    return nil
end

function CustomTuning.AddOptionForProfile(profileKey, categoryAdderFn, vehicle)
    if Config.ToggleFeatures and Config.ToggleFeatures.customHandling == false then return false end

    local prof = getProfileConfig(profileKey)
    local optionId = tostring((type(prof) == "table" and prof.optionId) or "")
    local label = tostring((type(prof) == "table" and prof.label) or "")
    local presets = (type(prof) == "table" and type(prof.presets) == "table") and prof.presets or nil

    if optionId == "" or label == "" or not presets or #presets <= 0 then
        return false
    end

    if TuningState.optionMap and TuningState.optionMap[optionId] then
        return false
    end

    local maxIndex = #presets - 1
    local allowedPresets = getAllowedPresetsForProfile(profileKey, prof, vehicle)

    if type(allowedPresets) == "table" then
        local hasPositive = false
        for _, idx in ipairs(allowedPresets) do
            if idx > 0 then hasPositive = true; break end
        end
        if not hasPositive then return false end
    end

    local defaultIdx = math.floor(tonumber(CustomTuning.GetSelectedProfileIndex(profileKey, TuningState.vehicle) or prof.defaultIndex) or 0)
    if defaultIdx < 0 then defaultIdx = 0 end
    if defaultIdx > maxIndex then defaultIdx = maxIndex end

    if type(allowedPresets) == "table" then
        local isAllowed = isPresetAllowedForProfile(profileKey, defaultIdx, vehicle)
        if not isAllowed then
            defaultIdx = allowedPresets[1] or 0
        end
    end

    local presetLabels = {}
    if type(allowedPresets) == "table" then
        for _, idx in ipairs(allowedPresets) do
            local pObj = presets[idx + 1]
            local pLabel = (type(pObj) == "table" and pObj.label) or ("Preset " .. tostring(idx + 1))
            presetLabels[tostring(idx)] = pLabel
        end
    else
        for i, pObj in ipairs(presets) do
            local pLabel = (type(pObj) == "table" and pObj.label) or ("Preset " .. tostring(i))
            presetLabels[tostring(i - 1)] = pLabel
        end
    end

    local extension = { customHandlingProfileKey = profileKey }
    if type(allowedPresets) == "table" then
        extension.allowedValues = allowedPresets
    end

    local sectionName = tostring(prof.section or "handling")
    local nuiTitle = getNuiLocale(string.format("option.label.%s", optionId), label)
    local minVal = (type(allowedPresets) == "table") and allowedPresets[1] or 0
    local maxVal = (type(allowedPresets) == "table") and allowedPresets[#allowedPresets] or maxIndex
    local cameraPart = tostring(prof.cameraPart or "center")

    categoryAdderFn(sectionName, optionId, nuiTitle, defaultIdx, minVal, maxVal, presetLabels, cameraPart, extension)
    return true
end

function CustomTuning.AddOptions(categoryAdderFn, vehicle)
    if Config.ToggleFeatures and Config.ToggleFeatures.customHandling == false then return end

    for _, pKey in ipairs(getSortedProfileKeys()) do
        CustomTuning.AddOptionForProfile(pKey, categoryAdderFn, vehicle)
    end
end
