if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/modules/Load.lua") end
-- =====================================================
--  sky_base · source/client/modules/Load.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Load = {}

-- Waits until isLoaded() or the timeout. A bad asset name used to block the calling
-- thread forever (and models were polled only once per second).
local LOAD_TIMEOUT_MS = 10000

local function waitUntilLoaded(isLoaded, request)
    local expire = GetGameTimer() + LOAD_TIMEOUT_MS
    while not isLoaded() do
        if GetGameTimer() > expire then
            return false
        end
        if request then request() end
        Wait(0)
    end
    return true
end

--- Requests and waits for a model to load into memory.
---@param model string|number
---@param cb? function
---@return boolean loaded
function Sky.Load.Model(model, cb)
    local hash = type(model) == "number" and model or joaat(model)
    local loaded = HasModelLoaded(hash)

    if not loaded and IsModelInCdimage(hash) then
        RequestModel(hash)
        loaded = waitUntilLoaded(function() return HasModelLoaded(hash) end)
        if not loaded and Sky.Debug then
            Sky.Debug("warn", "Model " .. tostring(model) .. " did not load in time")
        end
    end

    if cb then cb() end
    return loaded
end

--- Requests and waits for a streamed texture dictionary to load.
---@param dict string
---@param cb? function
---@return boolean loaded
function Sky.Load.StreamedTextureDict(dict, cb)
    local loaded = HasStreamedTextureDictLoaded(dict)
    if not loaded then
        RequestStreamedTextureDict(dict)
        loaded = waitUntilLoaded(function() return HasStreamedTextureDictLoaded(dict) end)
    end
    if cb then cb() end
    return loaded
end

--- Requests and waits for a PTFX asset to load.
---@param asset string
---@param cb? function
---@return boolean loaded
function Sky.Load.NamedPtfxAsset(asset, cb)
    local loaded = HasNamedPtfxAssetLoaded(asset)
    if not loaded then
        RequestNamedPtfxAsset(asset)
        loaded = waitUntilLoaded(function() return HasNamedPtfxAssetLoaded(asset) end)
    end
    if cb then cb() end
    return loaded
end

--- Requests and waits for an anim set to load.
---@param animSet string
---@param cb? function
---@return boolean loaded
function Sky.Load.AnimSet(animSet, cb)
    local loaded = HasAnimSetLoaded(animSet)
    if not loaded then
        RequestAnimSet(animSet)
        loaded = waitUntilLoaded(function() return HasAnimSetLoaded(animSet) end)
    end
    if cb then cb() end
    return loaded
end

--- Requests and waits for an anim dictionary to load.
---@param animDict string
---@param cb? function
---@return boolean loaded
function Sky.Load.AnimDict(animDict, cb)
    local loaded = HasAnimDictLoaded(animDict)
    if not loaded then
        RequestAnimDict(animDict)
        loaded = waitUntilLoaded(function() return HasAnimDictLoaded(animDict) end)
    end
    if cb then cb() end
    return loaded
end

--- Requests and waits for a weapon asset to load.
---@param asset string|number
---@param cb? function
---@return boolean loaded
function Sky.Load.WeaponAsset(asset, cb)
    local loaded = HasWeaponAssetLoaded(asset)
    if not loaded then
        RequestWeaponAsset(asset)
        loaded = waitUntilLoaded(function() return HasWeaponAssetLoaded(asset) end)
    end
    if cb then cb() end
    return loaded
end

--- Requests and returns a scaleform movie handle.
---@param scaleformName string
---@return number
function Sky.Load.Scaleform(scaleformName)
    local handle = RequestScaleformMovie(scaleformName)
    waitUntilLoaded(function() return HasScaleformMovieLoaded(handle) end)
    return handle
end
