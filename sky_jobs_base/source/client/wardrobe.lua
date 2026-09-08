if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/wardrobe.lua") end
-- =====================================================
--  sky_jobs_base · source/client/wardrobe.lua
--  Deobfuscated & Cleaned
-- =====================================================

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}

local activeOutfitId = nil
local initialCamCoords = nil
local savedCivilianOutfit = nil
local cachedCivilianOutfit = nil
local activeWardrobeCam = nil

local function isResourceStarted(res)
    return type(res) == "string" and GetResourceState(res) == "started"
end

local function getFramework()
    local fw = Sky and Sky.Config and Sky.Config.framework or "unknown"
    return tostring(fw):lower()
end

local function getCloakroomConfig()
    local cfg = Config and Config.Cloakroom
    if type(cfg) == "table" then return cfg end
    return {}
end

local function getBackendConfig()
    local cfg = getCloakroomConfig()
    local backend = cfg.backend or cfg.Backend or "auto"
    return tostring(backend):lower()
end

local function trimString(str)
    if type(str) ~= "string" then return nil end
    local s = str:match("^%s*(.-)%s*$")
    if s == "" then return nil end
    return s
end

local function buildInteractionContext(id, point, extra)
    extra = type(extra) == "table" and extra or {}
    local jobName = trimString(extra.jobName or extra.jobKey)
    return {
        id = id,
        point = point,
        jobName = jobName,
        framework = getFramework(),
        backend = getBackendConfig()
    }
end

local function getCustomIntegration()
    local cfg = getCloakroomConfig()
    if type(cfg.custom) == "table" then return cfg.custom end
    if type(cfg.Custom) == "table" then return cfg.Custom end
    return nil
end

local function isCustomAvailable(ctx)
    local custom = getCustomIntegration()
    if not (custom and type(custom.open) == "function") then return false end

    if type(custom.resource) == "string" and custom.resource ~= "" then
        if not isResourceStarted(custom.resource) then return false end
    end

    if type(custom.isAvailable) == "function" then
        local ok, res = pcall(custom.isAvailable, ctx or buildInteractionContext())
        return ok and res == true
    end

    return true
end

local function openCustomWardrobe(ctx)
    local custom = getCustomIntegration()
    if not (custom and type(custom.open) == "function") then return false end

    local ok, res = pcall(custom.open, ctx or buildInteractionContext())
    if not ok then
        print(string.format("[sky_jobs_base][Wardrobe] custom open failed: %s", tostring(res)))
        return false
    end
    return res ~= false
end

local function openAk47Clothing()
    local ok, res = pcall(function()
        return exports.ak47_clothing:openOutfit()
    end)
    if ok and res ~= false then return true end

    TriggerEvent("ak47_clothing:openOutfit")
    return true
end

local function openAk47QbClothing()
    local ok, res = pcall(function()
        return exports.ak47_qb_clothing:openOutfit()
    end)
    if ok and res ~= false then return true end

    TriggerEvent("ak47_qb_clothing:openOutfit")
    return true
end

local function openTgiannClothing()
    local ok, res = pcall(function()
        return exports["tgiann-clothing"]:OpenWardobeMenu("clothing")
    end)
    if not ok then
        print(string.format("[sky_jobs_base][Wardrobe] tgiann-clothing OpenWardobeMenu failed: %s", tostring(res)))
        return false
    end
    return res ~= false
end

local showWardrobeNotification = nil

local function openRcoreClothing(ctx)
    local jobName = trimString(ctx and ctx.jobName)
    if not jobName then
        local res = Sky.Cb.Trigger("sky_jobs_base:wardrobe:getJobMeta")
        jobName = trimString(res and res.success and res.data and res.data.jobKey)
    end

    if not jobName then
        if showWardrobeNotification then
            showWardrobeNotification(locales.WardrobeUnknownJob or "Wardrobe job is not available.", "error")
        end
        return false
    end

    TriggerEvent("rcore_clothing:openJobChangingRoom", jobName)
    return true
end

local function formatTemplate(key, fallback, params)
    local template = locales[key] or fallback
    params = params or {}
    for k, v in pairs(params) do
        template = template:gsub("{" .. k .. "}", tostring(v))
    end
    return template
end

local function detectClothingBackend()
    local backend = getBackendConfig()
    if backend == "disabled" then return "disabled" end

    if backend == "auto" or backend == "rcore" then
        if isResourceStarted("rcore_clothing") then return "rcore" end
    end
    if backend == "rcore" then return "missing_rcore_clothing" end

    local fw = getFramework()
    local ctx = buildInteractionContext()

    if backend == "custom" then
        return isCustomAvailable(ctx) and "custom" or "missing_custom"
    end
    if backend == "auto" and isCustomAvailable(ctx) then
        return "custom"
    end

    if backend == "auto" or backend == "17movement" then
        if isResourceStarted("17mov_CharacterSystem") then
            if fw == "esx" then return "17mov_esx" end
            if fw == "qb" or fw == "qbox" then return "17mov_qb" end
        end
    end
    if backend == "17movement" then return "missing_17movement" end

    if backend == "auto" or backend == "qs-appearance" or backend == "qs" then
        if isResourceStarted("qs-appearance") then return "qs-appearance" end
    end
    if backend == "qs-appearance" or backend == "qs" then return "missing_qs_appearance" end

    if backend == "auto" or backend == "ak47-clothing" or backend == "ak47" then
        if isResourceStarted("ak47_clothing") then return "ak47-clothing" end
    end
    if backend == "ak47-clothing" or backend == "ak47" then return "missing_ak47_clothing" end

    if backend == "auto" or backend == "ak47-qb-clothing" or backend == "ak47-qb" then
        if isResourceStarted("ak47_qb_clothing") then return "ak47-qb-clothing" end
    end
    if backend == "ak47-qb-clothing" or backend == "ak47-qb" then return "missing_ak47_qb_clothing" end

    if backend == "auto" or backend == "tgiann-clothing" or backend == "tgiann" then
        if isResourceStarted("tgiann-clothing") then return "tgiann-clothing" end
    end
    if backend == "tgiann-clothing" or backend == "tgiann" then return "missing_tgiann_clothing" end

    if backend == "auto" or backend == "nf-skin" or backend == "nf" then
        if isResourceStarted("nf-skin") then return "nf-skin" end
    end
    if backend == "nf-skin" or backend == "nf" then return "missing_nf_skin" end

    if backend == "auto" or backend == "bl-appearance" or backend == "bl_appearance" or backend == "bl" then
        if isResourceStarted("bl_appearance") then return "bl_appearance" end
    end
    if backend == "bl-appearance" or backend == "bl_appearance" or backend == "bl" then return "missing_bl_appearance" end

    if backend == "auto" or backend == "izzy-appearance" or backend == "izzy" then
        if isResourceStarted("izzy-appearance") then return "izzy-appearance" end
    end
    if backend == "izzy-appearance" or backend == "izzy" then return "missing_izzy_appearance" end

    if backend == "auto" or backend == "codem-appearance" or backend == "codem" then
        if isResourceStarted("codem-appearance") then return "codem-appearance" end
    end
    if backend == "codem-appearance" or backend == "codem" then return "missing_codem_appearance" end

    if backend == "auto" or backend == "hex-clothing" or backend == "hex_clothing" or backend == "hex" then
        if isResourceStarted("hex_clothing") then return "hex_clothing" end
    end
    if backend == "hex-clothing" or backend == "hex_clothing" or backend == "hex" then return "missing_hex_clothing" end

    if backend == "auto" or backend == "illenium" then
        if isResourceStarted("illenium-appearance") then return "illenium" end
    end
    if backend == "illenium" then return "missing_illenium" end

    if backend == "qb-clothing" then
        return isResourceStarted("qb-clothing") and "qb-clothing" or "missing_qb_clothing"
    end

    if backend == "sky" and fw ~= "esx" then
        return "unsupported"
    end

    if backend == "auto" and (fw == "qb" or fw == "qbox") then
        return isResourceStarted("qb-clothing") and "qb-clothing" or "missing_qb_clothing"
    end

    if (backend == "auto" and fw == "esx") or (backend == "sky" and fw == "esx") then
        if isResourceStarted("skinchanger") and isResourceStarted("esx_skin") then
            return "skinchanger"
        end
        if not isResourceStarted("esx_skin") then return "missing_esx_skin" end
        return "missing_skinchanger"
    end

    return "unsupported"
end

local function cloneTable(tbl)
    if type(tbl) ~= "table" then return {} end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = v
    end
    return copy
end

local function updateCachedCivilianOutfit(tbl)
    if type(tbl) ~= "table" then return end
    cachedCivilianOutfit = cloneTable(tbl)
end

local function persistCivilianOutfit(tbl)
    if type(tbl) ~= "table" then return end
    local res = Sky.Cb.Trigger("sky_jobs_base:wardrobe:setCivilianOutfit", json.encode(tbl), false)
    if res and res.success then
        if res.stored then
            updateCachedCivilianOutfit(tbl)
        elseif cachedCivilianOutfit == nil and res.data then
            local decoded = type(res.data) == "string" and json.decode(res.data) or res.data
            if type(decoded) == "table" then
                updateCachedCivilianOutfit(decoded)
            end
        end
    end
end

local function fetchCivilianOutfit()
    if cachedCivilianOutfit then
        return cloneTable(cachedCivilianOutfit)
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:wardrobe:getCivilianOutfit")
    if res and res.success and res.data then
        local decoded = type(res.data) == "string" and json.decode(res.data) or res.data
        if type(decoded) == "table" then
            updateCachedCivilianOutfit(decoded)
            return cloneTable(decoded)
        end
    end
    return nil
end

local function fetchEsxSkin()
    if not isResourceStarted("esx_skin") then return nil end
    if type(ESX) ~= "table" or type(ESX.TriggerServerCallback) ~= "function" then return nil end

    local p = promise.new()
    ESX.TriggerServerCallback("esx_skin:getPlayerSkin", function(skin)
        p:resolve(skin)
    end)

    local skin = Citizen.Await(p)
    if type(skin) ~= "table" then return nil end
    return skin
end

local function applySkinchangerOutfit(skin)
    if type(skin) ~= "table" then return false end
    if detectClothingBackend() ~= "skinchanger" then return false end

    TriggerEvent("skinchanger:loadSkin", skin)
    updateCachedCivilianOutfit(skin)
    savedCivilianOutfit = nil
    return true
end

showWardrobeNotification = function(msg, notifyType)
    if not msg then return end
    local title = locales.WardrobeTitle or "Wardrobe"
    Sky.Show.Notification(title, msg, notifyType or "info")
end

local function notifyBackendError(err)
    local fw = getFramework()
    local errorMessages = {
        disabled = formatTemplate("WardrobeDisabled", "Wardrobe is disabled in the config.", {}),
        missing_custom = formatTemplate("WardrobeCustomUnavailable", "The configured custom wardrobe integration is not available.", {}),
        missing_17movement = formatTemplate("WardrobeMissing17Movement", "Wardrobe requires 17mov_CharacterSystem to be started.", {}),
        missing_rcore_clothing = formatTemplate("WardrobeMissingRcoreClothing", "Wardrobe requires rcore_clothing to be started.", {}),
        missing_illenium = formatTemplate("WardrobeMissingIllenium", "Wardrobe requires illenium-appearance to be started.", {}),
        missing_qs_appearance = formatTemplate("WardrobeMissingQsAppearance", "Wardrobe requires qs-appearance to be started.", {}),
        missing_ak47_clothing = formatTemplate("WardrobeMissingAk47Clothing", "Wardrobe requires ak47_clothing to be started.", {}),
        missing_ak47_qb_clothing = formatTemplate("WardrobeMissingAk47QbClothing", "Wardrobe requires ak47_qb_clothing to be started.", {}),
        missing_tgiann_clothing = formatTemplate("WardrobeMissingTgiannClothing", "Wardrobe requires tgiann-clothing to be started.", {}),
        missing_nf_skin = formatTemplate("WardrobeMissingNfSkin", "Wardrobe requires nf-skin to be started.", {}),
        missing_bl_appearance = formatTemplate("WardrobeMissingBlAppearance", "Wardrobe requires bl_appearance to be started.", {}),
        missing_izzy_appearance = formatTemplate("WardrobeMissingIzzyAppearance", "Wardrobe requires izzy-appearance to be started.", {}),
        missing_codem_appearance = formatTemplate("WardrobeMissingCodemAppearance", "Wardrobe requires codem-appearance to be started.", {}),
        missing_hex_clothing = formatTemplate("WardrobeMissingHexClothing", "Wardrobe requires hex_clothing to be started.", {}),
        missing_skinchanger = formatTemplate("WardrobeMissingSkinchanger", "Wardrobe requires skinchanger to be started on ESX.", {}),
        missing_esx_skin = formatTemplate("WardrobeMissingEsxSkin", "Wardrobe requires esx_skin to be started on ESX.", {}),
        missing_qb_clothing = formatTemplate("WardrobeMissingQbClothing", "Wardrobe requires qb-clothing to be started on {framework}.", { framework = fw })
    }

    local msg = errorMessages[err] or formatTemplate("WardrobeUnsupportedFramework", "Wardrobe does not work with the selected framework ({framework}).", { framework = fw })
    showWardrobeNotification(msg, "error")
end

local function getEditableComponentsConfig()
    local cloakCfg = Config and Config.Cloakroom
    if type(cloakCfg) ~= "table" or type(cloakCfg.editableComponents) ~= "table" then return nil end

    local list = {}
    for _, comp in ipairs(cloakCfg.editableComponents) do
        if type(comp) == "string" then
            table.insert(list, comp)
        end
    end
    return #list > 0 and list or nil
end

local function filterEditableSkinComponents(skin)
    if type(skin) ~= "table" then return {} end
    local allowed = getEditableComponentsConfig()
    if not allowed then return cloneTable(skin) end

    local filtered = {}
    for _, compKey in ipairs(allowed) do
        if skin[compKey] ~= nil then
            filtered[compKey] = skin[compKey]
        end
    end
    return filtered
end

local function fetchWardrobePermissions()
    local res = Sky.Cb.Trigger("sky_jobs_base:wardrobe:getPermissions")
    if res and res.success and type(res.data) == "table" then
        return res.data
    end
    return {}
end

local function fetchJobColor()
    local res = Sky.Cb.Trigger("sky_jobs_base:wardrobe:getJobMeta")
    if res and res.success and res.data then
        return res.data.jobColor
    end
    return nil
end

AddEventHandler("sky_jobs_base:wardrobe:interaction", function(id, point, extra)
    local backend = detectClothingBackend()
    local ctx = buildInteractionContext(id, point, extra)

    if backend == "rcore" then openRcoreClothing(ctx) return end
    if backend == "custom" then
        if not openCustomWardrobe(ctx) then notifyBackendError("missing_custom") end
        return
    end
    if backend == "17mov_esx" then TriggerEvent("17mov_CharacterSystem:OpenOutfitsMenu") return end
    if backend == "17mov_qb" then TriggerEvent("qb-clothing:client:openOutfitMenu") return end
    if backend == "illenium" then TriggerEvent("illenium-appearance:client:openOutfitMenu") return end
    if backend == "qs-appearance" then TriggerEvent("clothing:openOutfitMenu") return end
    if backend == "ak47-clothing" then openAk47Clothing() return end
    if backend == "ak47-qb-clothing" then openAk47QbClothing() return end
    if backend == "tgiann-clothing" then
        if not openTgiannClothing() then notifyBackendError("missing_tgiann_clothing") end
        return
    end
    if backend == "nf-skin" then TriggerEvent("nf-skin:client:openOutfitMenu") return end
    if backend == "bl_appearance" then exports.bl_appearance:OpenMenu("outfits") return end
    if backend == "izzy-appearance" then TriggerEvent("izzy-appearance:client:openClothingMenu") return end
    if backend == "codem-appearance" then TriggerEvent("codem-apperance:OpenWardrobe") return end
    if backend == "hex_clothing" then TriggerEvent("hex_clothing:openOutfitMenu") return end
    if backend == "qb-clothing" then TriggerEvent("qb-clothing:client:openOutfitMenu") return end

    if backend ~= "skinchanger" then
        notifyBackendError(backend)
        return
    end

    SetNuiFocus(true, true)
    activeOutfitId = nil
    savedCivilianOutfit = nil

    local res = Sky.Cb.Trigger("sky_jobs_base:wardrobe:getOutfits")
    local outfitsRaw = (res and res.success and res.data) or {}
    local outfitsList = {}

    for _, outfit in pairs(outfitsRaw) do
        table.insert(outfitsList, {
            id = outfit.id,
            name = outfit.name,
            allowedGrades = outfit.allowedGrades,
            selectable = outfit.selectable ~= false
        })
    end

    SendNUIMessage({
        type = "cloakroom",
        permissions = fetchWardrobePermissions(),
        outfits = outfitsList,
        jobGrades = (res and res.jobGrades) or {},
        playerGrade = res and res.playerGrade,
        editableComponents = getEditableComponentsConfig(),
        jobColor = fetchJobColor()
    })

    fetchCivilianOutfit()

    local ped = PlayerPedId()
    activeWardrobeCam = Sky.Cam.new(GetEntityCoords(ped), { 0.0, 0.0, GetEntityHeading(ped) }, true)
    activeWardrobeCam:PointCamAtEntity(ped)
    initialCamCoords = GetCamCoord(activeWardrobeCam.cam)
end)

RegisterNUICallback("getSkin", function(data, cb)
    if detectClothingBackend() ~= "skinchanger" then
        cb({ success = false, error = "wardrobe_backend_unavailable" })
        return
    end

    activeOutfitId = data.outfitId
    local p = promise.new()

    TriggerEvent("skinchanger:getData", function(skinData, maxValues)
        p:resolve({ skinData = skinData, maxValues = maxValues })
    end)

    local res = Citizen.Await(p)
    cb({ success = true, data = res })
end)

RegisterNUICallback("changeClothing", function(data, cb)
    if detectClothingBackend() ~= "skinchanger" then
        cb({ success = false, error = "wardrobe_backend_unavailable" })
        return
    end

    local outfitIdx = tonumber(data.outfit) or 0
    if outfitIdx == 0 then
        local restored = false
        if savedCivilianOutfit then
            restored = applySkinchangerOutfit(savedCivilianOutfit)
        else
            local civSkin = fetchEsxSkin() or fetchCivilianOutfit()
            if civSkin then
                restored = applySkinchangerOutfit(civSkin)
            end
        end

        if restored then
            showWardrobeNotification(locales.WardrobeCivilianRestored or "Civilian outfit restored.", "success")
        else
            showWardrobeNotification(locales.WardrobeCivilianMissing or "Civilian outfit missing.", "error")
        end

        cb({ success = restored, error = not restored and "NO_CIVILIAN_OUTFIT" or nil })
        return
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:wardrobe:getOutfit", outfitIdx, data.allowEditPreview == true)
    if not (res and res.success) then
        cb({ success = false, error = (res and res.error) or "Outfit not available" })
        return
    end

    local clothes = (res.data and type(res.data) == "string" and json.decode(res.data)) or res.data or {}

    TriggerEvent("skinchanger:getSkin", function(currentSkin)
        if savedCivilianOutfit == nil then
            savedCivilianOutfit = cloneTable(currentSkin)
            if cachedCivilianOutfit == nil then
                updateCachedCivilianOutfit(currentSkin)
                persistCivilianOutfit(savedCivilianOutfit)
            end
        end
        TriggerEvent("skinchanger:loadClothes", currentSkin, clothes)
    end)

    cb({ success = res and res.success == true, error = res and res.error })
end)

RegisterNUICallback("saveOutfit", function(data, cb)
    if detectClothingBackend() ~= "skinchanger" then
        cb({ success = false, error = "wardrobe_backend_unavailable" })
        return
    end

    local outfitId = tonumber(data.id) or 0
    local name = data.name
    local allowedGrades = data.allowedGrades

    TriggerEvent("skinchanger:getSkin", function(currentSkin)
        local filtered = filterEditableSkinComponents(currentSkin)
        local res = Sky.Cb.Trigger("sky_jobs_base:wardrobe:saveOutfit", outfitId, name, json.encode(filtered), allowedGrades)

        if savedCivilianOutfit then
            TriggerEvent("skinchanger:loadSkin", savedCivilianOutfit)
            savedCivilianOutfit = nil
        end

        cb({
            success = res and res.success == true,
            error = res and res.error
        })
    end)
end)

RegisterNUICallback("deleteOutfit", function(data, cb)
    if detectClothingBackend() ~= "skinchanger" then
        cb({ success = false, error = "wardrobe_backend_unavailable" })
        return
    end

    local outfitId = data.outfit or 0
    local res = Sky.Cb.Trigger("sky_jobs_base:wardrobe:deleteOutfit", outfitId)

    if res and res.success and savedCivilianOutfit then
        TriggerEvent("skinchanger:loadSkin", savedCivilianOutfit)
        savedCivilianOutfit = nil
    end

    cb({
        success = res and res.success == true,
        error = res and res.error
    })
end)

RegisterNUICallback("rotate", function(data, cb)
    local ped = PlayerPedId()
    SetEntityHeading(ped, GetEntityHeading(ped) + 45.0)
    cb({ success = true })
end)

RegisterNUICallback("change", function(data, cb)
    if detectClothingBackend() ~= "skinchanger" then
        cb({ success = false, error = "wardrobe_backend_unavailable" })
        return
    end

    if savedCivilianOutfit == nil then
        TriggerEvent("skinchanger:getSkin", function(skin)
            savedCivilianOutfit = cloneTable(skin)
        end)
    end

    TriggerEvent("skinchanger:change", data.name, data.value)

    local p = promise.new()
    TriggerEvent("skinchanger:getData", function(skinData, maxValues)
        p:resolve(maxValues)
    end)

    local maxVals = Citizen.Await(p)

    if data.name ~= "sex" and initialCamCoords and activeWardrobeCam and activeWardrobeCam.cam then
        local camZOffset = data.camOffset - 0.65
        SetCamCoord(activeWardrobeCam.cam, initialCamCoords.x, initialCamCoords.y, initialCamCoords.z + camZOffset)
        PointCamAtCoord(activeWardrobeCam.cam, initialCamCoords.x, initialCamCoords.y, initialCamCoords.z + camZOffset)
    end

    cb({ success = true, maxValues = maxVals })
end)

local function closeWardrobe()
    if activeOutfitId ~= nil and savedCivilianOutfit then
        applySkinchangerOutfit(savedCivilianOutfit)
    end

    savedCivilianOutfit = nil
    activeOutfitId = nil

    if activeWardrobeCam then
        local camObj = activeWardrobeCam.cam
        if activeWardrobeCam.Remove then
            activeWardrobeCam:Remove()
        end
        if camObj and DoesCamExist(camObj) then
            DestroyCam(camObj, false)
        end
    end

    initialCamCoords = nil
    activeWardrobeCam = nil

    SetNuiFocus(false, false)
    SendNUIMessage({ type = "cloakroom:close" })
end

AddEventHandler("sky_jobs_base:wardrobe:close", function()
    closeWardrobe()
end)

AddEventHandler("sky_jobs:nuiClosed", function()
    closeWardrobe()
end)
