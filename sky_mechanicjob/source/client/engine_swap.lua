if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/engine_swap.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/engine_swap.lua
--  Deobfuscated & Cleaned
-- =====================================================

local ENGINE_PROP_MODEL = "prop_car_engine_01"
local HOIST_PROP_MODEL = "xs_prop_x18_engine_hoist_02a"
local ANIM_BOX_CARRY_DICT = "anim@heists@box_carry@"
local ANIM_BOX_CARRY_CLIP = "idle"
local MAX_SEARCH_DIST = 20.0
local CREATOR_KEY = "workshopcreator"
local POINT_TYPE_HOIST = "engine_swap"

local EngineHoistState = {
    creatorCache = nil,
    pointsByKey = {},
    pointList = {}
}

EngineHoistActiveState = {
    active = false,
    hoistProp = 0,
    engineProp = 0,
    baseZ = 0.0,
    originCoords = nil,
    originHeading = 0.0,
    originFrozen = false,
    attachedToVehicle = false
}

-- ── Animation Helpers ────────────────────────────────

local function playBoxCarryAnim(ped)
    if IsPedInAnyVehicle(ped, false) then return end
    if IsEntityPlayingAnim(ped, ANIM_BOX_CARRY_DICT, ANIM_BOX_CARRY_CLIP, 3) then return end

    Sky.Load.AnimDict(ANIM_BOX_CARRY_DICT)
    TaskPlayAnim(ped, ANIM_BOX_CARRY_DICT, ANIM_BOX_CARRY_CLIP, 8.0, -8.0, -1, 49, 0.0, false, false, false)
end

-- ── Point Key Formatter ──────────────────────────────

local function makePointKey(entryUid, pointUid, pointType)
    return string.format("%s:%s:%s", tostring(pointType), tostring(entryUid), tostring(pointUid))
end

-- ── Workshop Creator Data Sync ───────────────────────

local function fetchCreatorData()
    if type(EngineHoistState.creatorCache) == "table" then
        return EngineHoistState.creatorCache
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:creator:getData", { creatorKey = CREATOR_KEY })
    if type(res) == "table" and res.success == true and type(res.data) == "table" then
        EngineHoistState.creatorCache = res.data
    end

    return EngineHoistState.creatorCache
end

local function extractHoistPoints()
    local data = fetchCreatorData()
    if type(data) ~= "table" or type(data.entries) ~= "table" then
        return {}
    end

    local result = {}
    for _, entry in ipairs(data.entries) do
        local points = type(entry) == "table" and entry.points or nil
        if type(points) == "table" then
            for _, pt in ipairs(points) do
                if type(pt) == "table" and pt.type == POINT_TYPE_HOIST then
                    if pt.x ~= nil and pt.y ~= nil and pt.z ~= nil then
                        result[#result + 1] = {
                            key = makePointKey(entry.id, pt.uid, pt.type),
                            coords = vector3(tonumber(pt.x) or 0.0, tonumber(pt.y) or 0.0, tonumber(pt.z) or 0.0),
                            heading = tonumber(pt.heading) or 0.0
                        }
                    end
                end
            end
        end
    end
    return result
end

-- ── Prop Spawning & Cleanup ───────────────────────────

local function spawnPointHoistProp(pointEntry)
    local modelHash = GetHashKey(HOIST_PROP_MODEL)
    if not IsModelValid(modelHash) then
        print(string.format("[sky_mechanicjob][engine_hoist] failed: invalid model '%s'", HOIST_PROP_MODEL))
        return false
    end

    Sky.Load.Model(modelHash)
    local coords = pointEntry.coords
    local obj = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)

    if obj == 0 or not DoesEntityExist(obj) then
        print("[sky_mechanicjob][engine_hoist] failed: could not create hoist object")
        return false
    end

    SetEntityAsMissionEntity(obj, true, true)
    SetEntityHeading(obj, pointEntry.heading)
    SetEntityCoordsNoOffset(obj, coords.x, coords.y, coords.z, false, false, false)
    SetEntityCollision(obj, true, true)
    SetEntityCompletelyDisableCollision(obj, false, false)
    FreezeEntityPosition(obj, true)

    local netId = ObjToNet(obj)
    if netId ~= 0 then
        SetNetworkIdExistsOnAllMachines(netId, true)
        NetworkSetNetworkIdDynamic(netId, true)
        SetNetworkIdCanMigrate(netId, false)
    end

    SetModelAsNoLongerNeeded(modelHash)
    pointEntry.hoistProp = obj
    pointEntry.live = true
    return true
end

local function deletePointHoistProp(pointEntry)
    if pointEntry.hoistProp ~= 0 and DoesEntityExist(pointEntry.hoistProp) then
        DeleteEntity(pointEntry.hoistProp)
    end
    pointEntry.hoistProp = 0
    pointEntry.live = false
end

function clearEngineHoistState()
    local hoist = EngineHoistActiveState.hoistProp
    local engine = EngineHoistActiveState.engineProp

    if engine ~= 0 and DoesEntityExist(engine) then
        DeleteEntity(engine)
    end

    if hoist ~= 0 and DoesEntityExist(hoist) then
        if EngineHoistActiveState.attachedToVehicle then
            DetachEntity(hoist, true, true)
        end

        local origin = EngineHoistActiveState.originCoords
        if origin ~= nil then
            SetEntityCoordsNoOffset(hoist, origin.x, origin.y, origin.z, false, false, false)
            SetEntityHeading(hoist, EngineHoistActiveState.originHeading)
            FreezeEntityPosition(hoist, EngineHoistActiveState.originFrozen)
            SetEntityCollision(hoist, true, true)
            SetEntityCompletelyDisableCollision(hoist, false, false)
        end
    end

    if OrderInstallState.heldProp == hoist then
        OrderInstallState.heldProp = 0
    end

    EngineHoistActiveState.active = false
    EngineHoistActiveState.hoistProp = 0
    EngineHoistActiveState.engineProp = 0
    EngineHoistActiveState.baseZ = 0.0
    EngineHoistActiveState.originCoords = nil
    EngineHoistActiveState.originHeading = 0.0
    EngineHoistActiveState.originFrozen = false
    EngineHoistActiveState.attachedToVehicle = false
end

local function cleanupOrphanedAttachedHoists(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local activeHoist = EngineHoistActiveState.hoistProp
    if activeHoist ~= 0 and DoesEntityExist(activeHoist) and IsEntityAttachedToEntity(activeHoist, vehicle) then
        print("[sky_mechanicjob][engine_hoist] cleanup: removed active hoist still attached on vehicle enter")
        clearEngineHoistState()
    end

    local coords = GetEntityCoords(vehicle)
    local hoistHash = GetHashKey(HOIST_PROP_MODEL)
    local nearbyHoist = GetClosestObjectOfType(coords.x, coords.y, coords.z, 8.0, hoistHash, false, false, false)

    if nearbyHoist ~= 0 and DoesEntityExist(nearbyHoist) and IsEntityAttachedToEntity(nearbyHoist, vehicle) then
        print("[sky_mechanicjob][engine_hoist] cleanup: removed nearby orphaned hoist still attached on vehicle enter")
        local hoistPos = GetEntityCoords(nearbyHoist)
        local engineHash = GetHashKey(ENGINE_PROP_MODEL)
        local attachedEngine = GetClosestObjectOfType(hoistPos.x, hoistPos.y, hoistPos.z, 4.0, engineHash, false, false, false)

        if attachedEngine ~= 0 and DoesEntityExist(attachedEngine) and IsEntityAttachedToEntity(attachedEngine, nearbyHoist) then
            requestVehicleControl(attachedEngine, 500)
            DetachEntity(attachedEngine, true, true)
            SetEntityAsMissionEntity(attachedEngine, true, true)
            DeleteEntity(attachedEngine)
        end

        requestVehicleControl(nearbyHoist, 500)
        DetachEntity(nearbyHoist, true, true)
        SetEntityAsMissionEntity(nearbyHoist, true, true)
        DeleteEntity(nearbyHoist)
    end
end

-- ── Sync Live Points Loop ────────────────────────────

local function syncHoistPoints()
    local extracted = extractHoistPoints()
    local activeKeys = {}

    for _, pt in ipairs(extracted) do
        activeKeys[pt.key] = true
        local existing = EngineHoistState.pointsByKey[pt.key]

        if existing == nil then
            local newEntry = {
                key = pt.key,
                coords = pt.coords,
                heading = pt.heading,
                hoistProp = 0,
                live = false
            }
            EngineHoistState.pointsByKey[pt.key] = newEntry
        else
            if #(existing.coords - pt.coords) > 0.01 then
                if existing.hoistProp ~= 0 and EngineHoistActiveState.hoistProp == existing.hoistProp then
                    clearEngineHoistState()
                end
                deletePointHoistProp(existing)
                existing.coords = pt.coords
                existing.heading = pt.heading
            end
        end
    end

    for key, entry in pairs(EngineHoistState.pointsByKey) do
        if activeKeys[key] ~= true then
            if entry.hoistProp ~= 0 and EngineHoistActiveState.hoistProp == entry.hoistProp then
                clearEngineHoistState()
            end
            deletePointHoistProp(entry)
            EngineHoistState.pointsByKey[key] = nil
        end
    end

    local list = {}
    for _, entry in pairs(EngineHoistState.pointsByKey) do
        if not (entry.live and entry.hoistProp ~= 0 and DoesEntityExist(entry.hoistProp)) then
            spawnPointHoistProp(entry)
        end
        list[#list + 1] = entry
    end
    EngineHoistState.pointList = list
end

local function findNearestHoistPoint(maxRadius)
    local radius = tonumber(maxRadius) or MAX_SEARCH_DIST
    local pedCoords = GetEntityCoords(PlayerPedId())
    local bestPoint = nil
    local bestDist = radius + 0.001

    for _, pt in ipairs(EngineHoistState.pointList) do
        local dist = #(pedCoords - pt.coords)
        if dist <= radius and dist < bestDist then
            bestPoint = pt
            bestDist = dist
        end
    end

    return bestPoint, bestDist
end

-- ── Following Loop ───────────────────────────────────

local function startHoistFollowLoop()
    CreateThread(function()
        while EngineHoistActiveState.active do
            Wait(0)

            local hoist = EngineHoistActiveState.hoistProp
            if hoist == 0 or not DoesEntityExist(hoist) then
                print("[sky_mechanicjob][engine_hoist] follow loop aborted: hoist prop missing")
                clearEngineHoistState()
                break
            end

            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local fwd = GetEntityForwardVector(ped)
            local targetPos = vector3(pedCoords.x + fwd.x * 1.75, pedCoords.y + fwd.y * 1.75, EngineHoistActiveState.baseZ)

            playBoxCarryAnim(ped)

            SetEntityCoordsNoOffset(hoist, targetPos.x, targetPos.y, targetPos.z, false, false, false)
            SetEntityHeading(hoist, GetEntityHeading(ped) + 180.0)
            SetEntityNoCollisionEntity(hoist, ped, true)

            local engine = EngineHoistActiveState.engineProp
            if engine ~= 0 and DoesEntityExist(engine) then
                SetEntityNoCollisionEntity(engine, ped, true)
            end
        end
    end)
end

-- ── Engine Prop Spawning ─────────────────────────────

local function attachEnginePropToHoist(hoistObj)
    local modelHash = GetHashKey(ENGINE_PROP_MODEL)
    Sky.Load.Model(modelHash)

    local coords = GetEntityCoords(hoistObj)
    local engineObj = CreateObject(modelHash, coords.x, coords.y, coords.z + 1.35, true, true, false)

    SetEntityCollision(engineObj, false, false)
    SetEntityCompletelyDisableCollision(engineObj, true, false)
    AttachEntityToEntity(engineObj, hoistObj, 0, 0.0, -1.0, 1.25, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

    SetModelAsNoLongerNeeded(modelHash)
    EngineHoistActiveState.engineProp = engineObj
end

-- ── Take / Attach Actions ───────────────────────────

function takeNearestEngineHoistForOrderInstall()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        print("[sky_mechanicjob][engine_hoist] take failed: player is inside a vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.EngineSwapTakeHoistFailed or "Leave the vehicle before taking an engine hoist."
        }
    end

    clearEngineHoistState()

    local point, dist = findNearestHoistPoint(MAX_SEARCH_DIST)
    if point == nil then
        print("[sky_mechanicjob][engine_hoist] take failed: no workshopcreator hoist location nearby")
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.EngineSwapNoHoistNearby or "No engine hoist location nearby. Add one in workshopcreator and move closer."
        }
    end

    if not (point.live and point.hoistProp ~= 0 and DoesEntityExist(point.hoistProp)) then
        spawnPointHoistProp(point)
    end

    local hoistObj = point.hoistProp
    if hoistObj == 0 or not DoesEntityExist(hoistObj) then
        print("[sky_mechanicjob][engine_hoist] take failed: unable to create hoist prop at workshop location")
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.EngineSwapNoActiveHoist or "Unable to prepare engine hoist."
        }
    end

    local coords = GetEntityCoords(hoistObj)
    EngineHoistActiveState.active = true
    EngineHoistActiveState.hoistProp = hoistObj
    EngineHoistActiveState.baseZ = coords.z
    EngineHoistActiveState.originCoords = vector3(coords.x, coords.y, coords.z)
    EngineHoistActiveState.originHeading = GetEntityHeading(hoistObj)
    EngineHoistActiveState.originFrozen = true
    EngineHoistActiveState.attachedToVehicle = false

    OrderInstallState.heldProp = hoistObj

    FreezeEntityPosition(hoistObj, false)
    SetEntityCollision(hoistObj, false, false)
    SetEntityCompletelyDisableCollision(hoistObj, true, false)

    playBoxCarryAnim(ped)
    attachEnginePropToHoist(hoistObj)
    startHoistFollowLoop()

    if type(dist) == "number" then
        print(string.format("[sky_mechanicjob][engine_hoist] workshop hoist acquired at %.2f meters", dist))
    end

    return true
end

function isNearAnyEngineHoistForOrderInstall(maxDist)
    local point = select(1, findNearestHoistPoint(tonumber(maxDist) or MAX_SEARCH_DIST))
    return point ~= nil
end

function attachEngineHoistToVehicleFront(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][engine_hoist] attach failed: vehicle missing")
        return false, {
            key = "radial.errors.generic",
            fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.")
        }
    end

    local hoistObj = EngineHoistActiveState.hoistProp
    if hoistObj == 0 or not DoesEntityExist(hoistObj) then
        print("[sky_mechanicjob][engine_hoist] attach failed: hoist not active")
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.EngineSwapNoActiveHoist or "Take an engine hoist first."
        }
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    local vehCoords = GetEntityCoords(vehicle)
    if #(pedCoords - vehCoords) > 4.0 then
        print("[sky_mechanicjob][engine_hoist] attach failed: player is too far from vehicle")
        return false, {
            key = "radial.errors.generic",
            fallback = tuningLocales.WheelInstallTooFar or "Move closer to the connected order vehicle."
        }
    end

    EngineHoistActiveState.active = false
    DetachEntity(hoistObj, true, true)
    SetEntityCompletelyDisableCollision(hoistObj, false, false)
    SetEntityCollision(hoistObj, true, true)

    local minDim, maxDim = GetModelDimensions(GetEntityModel(vehicle))
    local offsetY = maxDim.y + 0.95
    local offsetZ = minDim.z

    AttachEntityToEntity(hoistObj, vehicle, 0, 0.0, offsetY, offsetZ, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    EngineHoistActiveState.attachedToVehicle = true
    return true
end

-- ── Event Handlers ───────────────────────────────────

RegisterNetEvent("sky_jobs_base:creatorUpdated", function(key, data)
    if key == CREATOR_KEY then
        EngineHoistState.creatorCache = data
        syncHoistPoints()
    end
end)

AddEventHandler("gameEventTriggered", function(eventName, args)
    if eventName ~= "CEventNetworkPlayerEnteredVehicle" then return end
    local veh = (args and args[2]) or GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 and DoesEntityExist(veh) then
        if GetVehiclePedIsIn(PlayerPedId(), false) == veh then
            cleanupOrphanedAttachedHoists(veh)
        end
    end
end)

CreateThread(function()
    syncHoistPoints()
end)

AddEventHandler("onResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end
    clearEngineHoistState()
    for _, pt in ipairs(EngineHoistState.pointList) do
        deletePointHoistProp(pt)
    end
end)

RegisterCommand("sky_debug_engine_hoist", function()
    if EngineHoistActiveState.active then
        releaseOrderHeldProp()
        notify("Engine hoist debug removed.", "info")
        return
    end

    local ok, err = takeNearestEngineHoistForOrderInstall()
    if ok then
        notify("Engine hoist debug acquired.", "success")
        return
    end

    notify((err and err.fallback) or "No nearby engine hoist found.", "error")
end, false)
