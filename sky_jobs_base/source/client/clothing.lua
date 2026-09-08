if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/clothing.lua") end
-- =====================================================
--  sky_jobs_base · source/client/clothing.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky_Jobs = Sky_Jobs or {}
Sky_Jobs.Clothing = Sky_Jobs.Clothing or {}

local COMPONENT_IDS = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 }
local PROP_IDS = { 0, 1, 2, 3, 4, 5, 6, 7 }

local function setComponent(ped, componentId, drawable, texture, palette)
    drawable = tonumber(drawable)
    texture = tonumber(texture) or 0
    palette = tonumber(palette) or 0

    if not drawable then return false end

    local maxDrawables = GetNumberOfPedDrawableVariations(ped, componentId)
    if maxDrawables <= 0 or drawable < 0 or drawable >= maxDrawables then
        return false
    end

    local maxTextures = GetNumberOfPedTextureVariations(ped, componentId, drawable)
    if maxTextures <= 0 or texture < 0 or texture >= maxTextures then
        texture = 0
    end

    SetPedComponentVariation(ped, componentId, drawable, texture, palette)
    return true
end

local function setProp(ped, propId, drawable, texture)
    drawable = tonumber(drawable)
    texture = tonumber(texture) or 0

    if not drawable then return false end

    if drawable == -1 then
        ClearPedProp(ped, propId)
        return true
    end

    local maxDrawables = GetNumberOfPedPropDrawableVariations(ped, propId)
    if maxDrawables <= 0 or drawable < 0 or drawable >= maxDrawables then
        return false
    end

    local maxTextures = GetNumberOfPedPropTextureVariations(ped, propId, drawable)
    if maxTextures <= 0 or texture < 0 or texture >= maxTextures then
        texture = 0
    end

    SetPedPropIndex(ped, propId, drawable, texture, true)
    return true
end

local function getComponent(ped, componentId)
    return {
        drawable = GetPedDrawableVariation(ped, componentId),
        texture = GetPedTextureVariation(ped, componentId),
        palette = GetPedPaletteVariation(ped, componentId)
    }
end

local function getProp(ped, propId)
    local idx = GetPedPropIndex(ped, propId)
    local tex = 0
    if idx ~= -1 then
        tex = GetPedPropTextureIndex(ped, propId) or 0
    end
    return {
        drawable = idx,
        texture = tex
    }
end

--- Saves current ped clothing and props to structured table.
---@param ped? number
---@return table|nil
function Sky_Jobs.Clothing.Save(ped)
    ped = ped or PlayerPedId()
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        return nil
    end

    local componentsData = {}
    for _, cId in ipairs(COMPONENT_IDS) do
        componentsData[cId] = getComponent(ped, cId)
    end

    local propsData = {}
    for _, pId in ipairs(PROP_IDS) do
        propsData[pId] = getProp(ped, pId)
    end

    return {
        kind = "native",
        components = componentsData,
        props = propsData
    }
end

--- Applies saved clothing data table to ped.
---@param data table
---@param ped? number
function Sky_Jobs.Clothing.Apply(data, ped)
    if type(data) ~= "table" then return end
    ped = ped or PlayerPedId()
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end

    if data.components then
        for _, cId in ipairs(COMPONENT_IDS) do
            local comp = data.components[cId]
            if comp then
                setComponent(ped, cId, comp.drawable, comp.texture, comp.palette)
            end
        end
    end

    if data.props then
        for _, pId in ipairs(PROP_IDS) do
            local prop = data.props[pId]
            if prop then
                setProp(ped, pId, prop.drawable, prop.texture)
            end
        end
    end
end

--- Reads component from clothing table.
---@param data table
---@param componentId number
---@return table|nil
function Sky_Jobs.Clothing.ReadComponent(data, componentId)
    if type(data) ~= "table" then return nil end
    return data.components and data.components[componentId]
end

--- Applies component variation directly to ped.
---@param ped number
---@param componentId number
---@param drawable number
---@param texture? number
---@param palette? number
function Sky_Jobs.Clothing.ApplyComponent(ped, componentId, drawable, texture, palette)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end
    setComponent(ped, componentId, drawable, texture, palette)
end

--- Applies a list of component variations to ped.
---@param ped number
---@param list table
function Sky_Jobs.Clothing.ApplyComponentList(ped, list)
    if type(list) ~= "table" then return end
    for _, item in ipairs(list) do
        Sky_Jobs.Clothing.ApplyComponent(
            ped,
            item.component,
            item.drawable or 0,
            item.texture or 0,
            item.palette or 0
        )
    end
end

--- Applies prop variation directly to ped.
---@param ped number
---@param propId number
---@param drawable number
---@param texture? number
function Sky_Jobs.Clothing.ApplyProp(ped, propId, drawable, texture)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end
    setProp(ped, propId, drawable, texture)
end

--- Applies a list of prop variations to ped.
---@param ped number
---@param list table
function Sky_Jobs.Clothing.ApplyPropList(ped, list)
    if type(list) ~= "table" then return end
    for _, item in ipairs(list) do
        Sky_Jobs.Clothing.ApplyProp(
            ped,
            item.prop,
            item.drawable,
            item.texture or 0
        )
    end
end

function Sky_Jobs.Clothing.Sync()
    -- Reserved for framework sync
end
