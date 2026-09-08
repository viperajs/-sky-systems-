if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/modules/Load.lua") end
-- =====================================================
--  sky_base · source/client/modules/Load.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Load = {}

--- Requests and waits for a model to load into memory.
---@param model string|number
---@param cb? function
function Sky.Load.Model(model, cb)
    local hash = type(model) == "number" and model or joaat(model)
    local elapsed = 0

    if not HasModelLoaded(hash) then
        if IsModelInCdimage(hash) then
            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Wait(1000)
                elapsed = elapsed + 1
                if Sky.Debug then
                    Sky.Debug("debug", "Waiting for model " .. hash .. " to load... (" .. elapsed .. " seconds)")
                end
            end
        end
    end

    if cb then cb() end
end

--- Requests and waits for a streamed texture dictionary to load.
---@param dict string
---@param cb? function
function Sky.Load.StreamedTextureDict(dict, cb)
    if not HasStreamedTextureDictLoaded(dict) then
        RequestStreamedTextureDict(dict)
        while not HasStreamedTextureDictLoaded(dict) do
            Wait(0)
        end
    end
    if cb then cb() end
end

--- Requests and waits for a PTFX asset to load.
---@param asset string
---@param cb? function
function Sky.Load.NamedPtfxAsset(asset, cb)
    if not HasNamedPtfxAssetLoaded(asset) then
        RequestNamedPtfxAsset(asset)
        while not HasNamedPtfxAssetLoaded(asset) do
            Wait(0)
        end
    end
    if cb then cb() end
end

--- Requests and waits for an anim set to load.
---@param animSet string
---@param cb? function
function Sky.Load.AnimSet(animSet, cb)
    if not HasAnimSetLoaded(animSet) then
        RequestAnimSet(animSet)
        while not HasAnimSetLoaded(animSet) do
            Wait(0)
        end
    end
    if cb then cb() end
end

--- Requests and waits for an anim dictionary to load.
---@param animDict string
---@param cb? function
function Sky.Load.AnimDict(animDict, cb)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end
    end
    if cb then cb() end
end

--- Requests and waits for a weapon asset to load.
---@param asset string|number
---@param cb? function
function Sky.Load.WeaponAsset(asset, cb)
    if not HasWeaponAssetLoaded(asset) then
        RequestWeaponAsset(asset)
        while not HasWeaponAssetLoaded(asset) do
            Wait(0)
        end
    end
    if cb then cb() end
end

--- Requests and returns a scaleform movie handle.
---@param scaleformName string
---@return number
function Sky.Load.Scaleform(scaleformName)
    local handle = RequestScaleformMovie(scaleformName)
    while not HasScaleformMovieLoaded(handle) do
        handle = RequestScaleformMovie(scaleformName)
        Wait(0)
    end
    return handle
end
