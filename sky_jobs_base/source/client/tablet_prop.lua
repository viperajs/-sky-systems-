if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/tablet_prop.lua") end
-- =====================================================
--  sky_jobs_base · source/client/tablet_prop.lua
--  Deobfuscated & Cleaned
-- =====================================================

local tabletConfig = (Config and Config.Tablet and Config.Tablet.prop) or {}
local animConfig = (Config and Config.Tablet and Config.Tablet.anim) or {}

local function toVector3(val, default)
    if type(val) == "vector3" then
        return val
    end
    if type(val) == "table" then
        local x = tonumber(val.x or val[1])
        local y = tonumber(val.y or val[2])
        local z = tonumber(val.z or val[3])
        if x and y and z then
            return vector3(x, y, z)
        end
    end
    return default
end

local propModel = type(tabletConfig.model) == "string" and tabletConfig.model or "prop_cs_tablet"
local propHash = joaat(propModel)
local propBone = tonumber(tabletConfig.bone) or 60309
local propOffset = toVector3(tabletConfig.offset, vector3(0.03, 0.002, 0.0))
local propRotation = toVector3(tabletConfig.rotation, vector3(10.0, 160.0, 0.0))

local animDict = type(animConfig.dict) == "string" and animConfig.dict or "amb@code_human_in_bus_passenger_idles@female@tablet@base"
local animName = type(animConfig.name) == "string" and animConfig.name or "base"
local animFlag = tonumber(animConfig.flag) or 49

local tabletEntity = nil
local isTabletActive = false

local function destroyEntity(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return true
    end

    DetachEntity(entity, true, true)
    SetEntityAsMissionEntity(entity, true, true)
    DeleteObject(entity)
    DeleteEntity(entity)

    for _ = 1, 10 do
        if not DoesEntityExist(entity) then
            return true
        end
        Wait(0)
        SetEntityAsMissionEntity(entity, true, true)
        DeleteObject(entity)
        DeleteEntity(entity)
    end

    return not DoesEntityExist(entity)
end

local function removeTabletProp()
    if tabletEntity and DoesEntityExist(tabletEntity) then
        destroyEntity(tabletEntity)
    end
    tabletEntity = nil
end

local function stopTabletAnim()
    local ped = PlayerPedId()
    if ped and ped ~= 0 and HasAnimDictLoaded(animDict) then
        StopAnimTask(ped, animDict, animName, 1.0)
    end
end

local function attachTabletProp()
    if isTabletActive then return end
    isTabletActive = true

    local ped = PlayerPedId()
    if not ped or ped == 0 or IsEntityDead(ped) then
        isTabletActive = false
        return
    end

    removeTabletProp()
    Sky.Load.Model(propHash)

    if not isTabletActive then
        SetModelAsNoLongerNeeded(propHash)
        return
    end

    ped = PlayerPedId()
    if not ped or ped == 0 or IsEntityDead(ped) then
        SetModelAsNoLongerNeeded(propHash)
        isTabletActive = false
        return
    end

    local coords = GetEntityCoords(ped)
    local obj = CreateObject(propHash, coords.x, coords.y, coords.z, true, true, false)
    if not obj or obj == 0 then
        SetModelAsNoLongerNeeded(propHash)
        isTabletActive = false
        return
    end

    local boneIdx = GetPedBoneIndex(ped, propBone)
    AttachEntityToEntity(
        obj, ped, boneIdx,
        propOffset.x, propOffset.y, propOffset.z,
        propRotation.x, propRotation.y, propRotation.z,
        true, true, false, true, 1, true
    )
    SetEntityCompletelyDisableCollision(obj, false, true)
    tabletEntity = obj

    SetModelAsNoLongerNeeded(propHash)
    Sky.Load.AnimDict(animDict)

    if isTabletActive then
        ped = PlayerPedId()
        if ped and ped ~= 0 and not IsEntityDead(ped) then
            TaskPlayAnim(ped, animDict, animName, 3.0, 3.0, -1, animFlag, 0, false, false, false)
        end
    end
end

local function detachTabletProp()
    isTabletActive = false
    stopTabletAnim()
    removeTabletProp()
end

AddEventHandler("sky_jobs_base:tablet:stateChanged", function(data)
    if type(data) ~= "table" then return end
    if data.open then
        attachTabletProp()
    else
        detachTabletProp()
    end
end)

AddEventHandler("sky_jobs:nuiClosed", function()
    detachTabletProp()
end)

CreateThread(function()
    while true do
        if isTabletActive then
            local ped = PlayerPedId()
            if not ped or ped == 0 or IsEntityDead(ped) then
                detachTabletProp()
            end
        end
        Wait(1000)
    end
end)

AddEventHandler("onResourceStop", function(resName)
    if resName == GetCurrentResourceName() then
        detachTabletProp()
    end
end)
