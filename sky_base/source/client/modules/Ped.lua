if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/modules/Ped.lua") end
-- =====================================================
--  sky_base · source/client/modules/Ped.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Ped = {}
Sky.Ped.__index = Sky.Ped

--- Creates a new Ped wrapper instance.
---@param entity? number
---@return table
function Sky.Ped.new(entity)
    local self = setmetatable({}, Sky.Ped)
    self.entity = entity
    return self
end

--- Spawns a ped with options (scenario, interior handling, onSpawn callback).
---@param model string|number
---@param coords vector3
---@param heading? number
---@param options? table
function Sky.Ped:Spawn(model, coords, heading, options)
    local pos = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
    local hash = type(model) == "number" and model or joaat(model)
    local head = heading or 0.0

    local isInteraction = options and options.spawnProfile == "interaction"

    Sky.Load.Model(hash)

    if not isInteraction then
        local interior = GetInteriorAtCoords(pos.x, pos.y, pos.z)
        if interior and interior ~= 0 then
            PinInteriorInMemory(interior)
            if not IsInteriorReady(interior) then
                LoadInterior(interior)
                local timeout = GetGameTimer() + 3000
                while not IsInteriorReady(interior) and GetGameTimer() < timeout do
                    Wait(50)
                end
            end
        end
    end

    local pedHandle = CreatePed(4, hash, pos, head, false, true)
    self.entity = pedHandle

    SetEntityAsMissionEntity(pedHandle, true, true)
    SetModelAsNoLongerNeeded(hash)

    if not isInteraction then
        Wait(100)
        SetEntityVisible(pedHandle, true, false)
        ResetEntityAlpha(pedHandle)
        SetEntityCollision(pedHandle, true, true)
        SetPedDefaultComponentVariation(pedHandle)
        SetPedComponentVariation(pedHandle, 0, 0, 0, 0)
    end

    if options then
        if options.scenario then
            TaskStartScenarioInPlace(pedHandle, options.scenario, 0, true)
        end
        if type(options.onSpawn) == "function" then
            options.onSpawn(pedHandle)
        end
    end
end

--- Plays an animation on the ped.
---@param dict string
---@param anim string
---@param duration? number
function Sky.Ped:PlayAnim(dict, anim, duration)
    if not self.entity or not DoesEntityExist(self.entity) then return end
    Sky.Load.AnimDict(dict)
    TaskPlayAnim(self.entity, dict, anim, 8.0, -8.0, duration or -1, 1, 0, false, false, false)
end

--- Clears ped tasks / stops animations.
function Sky.Ped:StopAnim()
    if not self.entity or not DoesEntityExist(self.entity) then return end
    ClearPedTasks(self.entity)
end

--- Gets ped coords.
---@return vector3
function Sky.Ped:GetCoords()
    if not self.entity or not DoesEntityExist(self.entity) then return end
    return GetEntityCoords(self.entity)
end

--- Sets ped coords and optional heading.
---@param coords vector3
---@param heading? number
function Sky.Ped:SetCoords(coords, heading)
    if not self.entity or not DoesEntityExist(self.entity) then return end
    local pos = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
    SetEntityCoords(self.entity, pos, false, false, false, true)
    if heading ~= nil then
        SetEntityHeading(self.entity, heading)
    end
end

--- Freezes position and makes invincible/un-eventable.
function Sky.Ped:Freeze()
    if not self.entity or not DoesEntityExist(self.entity) then return end
    FreezeEntityPosition(self.entity, true)
    SetEntityInvincible(self.entity, true)
    SetBlockingOfNonTemporaryEvents(self.entity, true)
    SetCanAttackFriendly(self.entity, true, true)
end

--- Deletes a ped entity safely with network control handling.
---@param ped number
---@return boolean
function Sky.Ped.Delete(ped)
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        return true
    end

    if GetEntityType(ped) ~= 1 or IsPedAPlayer(ped) then
        return false
    end

    local timeout = GetGameTimer() + 1000
    while DoesEntityExist(ped) and GetGameTimer() < timeout do
        if NetworkGetEntityIsNetworked(ped) and not NetworkHasControlOfEntity(ped) then
            NetworkRequestControlOfEntity(ped)
        end
        SetEntityAsMissionEntity(ped, true, true)
        DetachEntity(ped, true, true)
        ClearPedTasksImmediately(ped)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        DeletePed(ped)
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
        if DoesEntityExist(ped) then
            Wait(0)
        end
    end

    return not DoesEntityExist(ped)
end
