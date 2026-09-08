if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/modules/Dui.lua") end
-- =====================================================
--  sky_base · source/client/modules/Dui.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Dui = {
    instances = {},
    availableScaleforms = {},
    maxScaleforms = 20,
    maxDistance = 50.0,
    checkIntervalFar = 1000,
    checkIntervalNear = 50
}

CreateThread(function()
    for i = 1, Sky.Dui.maxScaleforms do
        table.insert(Sky.Dui.availableScaleforms, "scaleform_" .. i)
    end
end)

local function getRenderTarget(name, model)
    local renderId = 0
    if not IsNamedRendertargetRegistered(name) then
        RegisterNamedRendertarget(name, 0)
    end
    if not IsNamedRendertargetLinked(model) then
        LinkNamedRendertarget(model)
    end
    if IsNamedRendertargetRegistered(name) then
        renderId = GetNamedRendertargetRenderId(name)
    end
    return renderId
end

local function drawSpriteToRenderTarget(renderId)
    SetTextRenderId(renderId)
    Set_2dLayer(4)
    SetScriptGfxDrawBehindPausemenu(1)
    DrawSprite("skybase_b_dict", "skybase_b_txd", 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
    SetTextRenderId(GetDefaultScriptRendertargetRenderId())
    SetScriptGfxDrawBehindPausemenu(0)
end

--- Creates a 3D DUI screen attached to an entity.
---@param id string
---@param entity number
---@param url string
---@param width number
---@param height number
---@param scale number
---@param offset vector3
---@param target? string
function Sky.Dui.CreateScreen(id, entity, url, width, height, scale, offset, target)
    if not DoesEntityExist(entity) then return end

    if #Sky.Dui.availableScaleforms == 0 then
        print("No available scaleforms!")
        return
    end

    local scaleformName = table.remove(Sky.Dui.availableScaleforms, 1)
    local scaleform = Sky.Load.Scaleform(scaleformName)

    local runtimeTxd = "skybase_b_dict_" .. id
    local textureName = "skybase_b_txd_" .. id

    local txd = CreateRuntimeTxd(runtimeTxd)
    local duiObj = CreateDui(url, width, height)
    local duiHandle = GetDuiHandle(duiObj)
    CreateRuntimeTextureFromDuiHandle(txd, textureName, duiHandle)

    local screenInstance = {
        entity = entity,
        width = width,
        height = height,
        scale = scale,
        offset = offset,
        target = target,
        duiObj = duiObj,
        duiHandle = duiHandle,
        txd = txd,
        textureName = textureName,
        runtimeTxd = runtimeTxd,
        scaleform = scaleform,
        scaleformName = scaleformName,
        isVisible = false,
        url = url
    }

    Sky.Dui.instances[id] = screenInstance

    Wait(10)
    PushScaleformMovieFunction(scaleform, "SET_TEXTURE")
    PushScaleformMovieMethodParameterString(runtimeTxd)
    PushScaleformMovieMethodParameterString(textureName)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(width)
    PushScaleformMovieFunctionParameterInt(height)
    PopScaleformMovieFunctionVoid()

    -- Visibility & Stream Distance Loop
    CreateThread(function()
        while DoesEntityExist(entity) and Sky.Dui.instances[id] do
            local inst = Sky.Dui.instances[id]
            local pedCoords = GetEntityCoords(PlayerPedId())
            local entCoords = GetEntityCoords(entity)
            local dist = #(pedCoords - entCoords)

            local checkInterval = Sky.Dui.checkIntervalFar
            if dist <= Sky.Dui.maxDistance then
                if not inst.isVisible then
                    inst.isVisible = true
                end
                checkInterval = Sky.Dui.checkIntervalNear
            else
                if inst.isVisible then
                    inst.isVisible = false
                end
            end
            Wait(checkInterval)
        end

        local inst = Sky.Dui.instances[id]
        if inst then
            if inst.duiObj then
                DestroyDui(inst.duiObj)
            end
            table.insert(Sky.Dui.availableScaleforms, inst.scaleformName)
            Sky.Dui.instances[id] = nil
        end
    end)

    -- Render Loop
    CreateThread(function()
        while DoesEntityExist(entity) and Sky.Dui.instances[id] do
            local inst = Sky.Dui.instances[id]
            if inst and inst.isVisible and inst.scaleform and HasScaleformMovieLoaded(inst.scaleform) then
                local worldCoords = GetOffsetFromEntityInWorldCoords(entity, offset.x, offset.y, offset.z)
                if target then
                    local model = GetEntityModel(entity)
                    local renderId = getRenderTarget(target, model)
                    if renderId ~= -1 then
                        drawSpriteToRenderTarget(renderId)
                    end
                else
                    local heading = GetEntityHeading(entity)
                    DrawScaleformMovie_3dSolid(
                        inst.scaleform,
                        worldCoords,
                        0.0, 0.0, -heading,
                        2.0, 2.0, 2.0,
                        scale * 1.0, scale * 0.5625,
                        2
                    )
                end
            end
            Wait(0)
        end
    end)
end

--- Removes a DUI screen by ID.
---@param id string
function Sky.Dui.RemoveScreen(id)
    local inst = Sky.Dui.instances[id]
    if not inst then return end

    if inst.duiObj then
        DestroyDui(inst.duiObj)
    end
    table.insert(Sky.Dui.availableScaleforms, inst.scaleformName)
    Sky.Dui.instances[id] = nil
end

RegisterNetEvent("sky_base:updateDui", function(id, newUrl)
    local inst = Sky.Dui.instances[id]
    if inst then
        local copy = inst
        Sky.Dui.RemoveScreen(id)
        Sky.Dui.CreateScreen(
            id,
            copy.entity,
            newUrl,
            copy.width,
            copy.height,
            copy.scale,
            copy.offset,
            copy.target
        )
    end
end)
