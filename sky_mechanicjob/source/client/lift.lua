if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/lift.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/lift.lua
--  Deobfuscated by Claude
--  Original: 4725 lines → Cleaned
-- =====================================================

local State = {
    creatorCache = nil,
    pointsByKey = {},
    pointList = {},
    activeUiPointKey = nil,
    uiOpen = false,
    workerRunning = false
}

local CREATOR_KEY = "workshopcreator"
local LIFT_TYPE = "lift"

-- Forward declarations
local spawnLiftPoint
local closeLiftControlUi

-- ============================================================
--  UTILITY FUNCTIONS
-- ============================================================

local function getTuningLocale(key, default)
    local localized = tuningLocales and tuningLocales[key]
    if type(localized) == "string" and localized ~= "" then
        return localized
    end
    return default
end

local function isDebugActive()
    if Sky and Sky.IsDebugActive then
        return Sky.IsDebugActive() == true
    end
    if Sky and Sky.Config and Sky.Config.debug then
        return Sky.Config.debug == true
    end
    return false
end

local function debugLog(fmt, ...)
    if not isDebugActive() then return end

    local ok, formattedMsg = pcall(string.format, "[sky_mechanicjob][debug][lift] " .. fmt, ...)
    local finalMsg = (ok and formattedMsg) or ("[sky_mechanicjob][debug][lift] " .. tostring(fmt))

    if Sky and Sky.Debug then
        Sky.Debug("debug", finalMsg)
    else
        print(finalMsg)
    end
end

local function boolToString(val)
    return val == true and "true" or "false"
end

local function formatCoords(coords)
    if type(coords) ~= "vector3" and type(coords) ~= "table" then
        return "nil"
    end
    local x = tonumber(coords.x) or 0.0
    local y = tonumber(coords.y) or 0.0
    local z = tonumber(coords.z) or 0.0
    return ("%.3f, %.3f, %.3f"):format(x, y, z)
end

-- ============================================================
--  MODEL SET HELPERS
-- ============================================================

local function getAllowedLiftModelHashes(targetSet)
    local hashes = {}
    local creatorCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.creator or {}

    local candidateModels = {
        targetSet and targetSet.frameModel,
        targetSet and targetSet.platformModel,
        creatorCfg.frameModel,
        creatorCfg.platformModel,
        "sky_carlift_platform",
        "sky_carlift_frame"
    }

    for _, modelName in ipairs(candidateModels) do
        if type(modelName) == "string" and modelName ~= "" then
            hashes[GetHashKey(modelName)] = modelName
        end
    end

    if type(creatorCfg.modelSets) == "table" then
        for _, setInfo in ipairs(creatorCfg.modelSets) do
            if type(setInfo) == "table" then
                if type(setInfo.frameModel) == "string" and setInfo.frameModel ~= "" then
                    hashes[GetHashKey(setInfo.frameModel)] = setInfo.frameModel
                end
                if type(setInfo.platformModel) == "string" and setInfo.platformModel ~= "" then
                    hashes[GetHashKey(setInfo.platformModel)] = setInfo.platformModel
                end
            end
        end
    end

    return hashes
end

local function parseModelSet(rawSet, defaultName)
    if type(rawSet) ~= "table" then
        return nil
    end

    local frameModel = type(rawSet.frameModel) == "string" and rawSet.frameModel or nil
    local platformModel = type(rawSet.platformModel) == "string" and rawSet.platformModel or nil

    if not frameModel or frameModel == "" or not platformModel or platformModel == "" then
        return nil
    end

    local setName = defaultName
    if type(rawSet.name) == "string" and rawSet.name ~= "" then
        setName = rawSet.name
    end

    return {
        name = setName,
        frameModel = frameModel,
        platformModel = platformModel
    }
end

local function getModelSets()
    local creatorCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.creator or {}
    local result = {}
    local seen = {}

    local function addSet(rawSet, defaultName)
        local parsed = parseModelSet(rawSet, defaultName)
        if not parsed then return end

        local setKey = ("%s|%s|%s"):format(parsed.name or "", parsed.frameModel, parsed.platformModel)
        if seen[setKey] then return end

        seen[setKey] = true
        table.insert(result, parsed)
    end

    if type(creatorCfg.modelSets) == "table" and #creatorCfg.modelSets > 0 then
        for idx, setInfo in ipairs(creatorCfg.modelSets) do
            addSet(setInfo, ("set_%s"):format(idx))
        end
    end

    addSet({
        name = "default",
        frameModel = creatorCfg.frameModel or "sky_carlift_platform",
        platformModel = creatorCfg.platformModel or "sky_carlift_frame"
    }, "default")

    if #result == 0 then
        table.insert(result, {
            name = "default",
            frameModel = "sky_carlift_platform",
            platformModel = "sky_carlift_frame"
        })
    end

    return result
end

local function getModelSetByName(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end
    for _, modelSet in ipairs(getModelSets()) do
        if modelSet.name == name then
            return modelSet
        end
    end
    return nil
end

local function getDefaultModelSet()
    return getModelSets()[1]
end

local function resolveModelSet(liftPoint)
    if type(liftPoint) == "table" then
        local foundSet = getModelSetByName(liftPoint.modelSet)
        if foundSet then
            return foundSet
        end
    end
    return getDefaultModelSet()
end

-- ============================================================
--  EXISTING PROPS & DISCOVERY
-- ============================================================

local function isExistingPropsEnabled()
    local existingCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.existingProps or {}
    return existingCfg.enabled == true
end

local function findExistingObject(modelName, centerCoords, floorZ, searchRadius, zTolerance, ignoreEntity)
    if not GetGamePool or type(modelName) ~= "string" or modelName == "" then
        return 0
    end

    local modelHash = GetHashKey(modelName)
    local maxDist = tonumber(searchRadius) or 1.2
    local bestDist = maxDist + 0.001
    local maxZDiff = tonumber(zTolerance) or 1.0
    local foundEntity = 0

    local objects = GetGamePool("CObject") or {}
    for _, entity in ipairs(objects) do
        if entity ~= 0 and entity ~= ignoreEntity and DoesEntityExist(entity) then
            if GetEntityModel(entity) == modelHash then
                local entityCoords = GetEntityCoords(entity)
                local planarDist = #(vector2(entityCoords.x, entityCoords.y) - vector2(centerCoords.x, centerCoords.y))
                local zDiff = math.abs(entityCoords.z - floorZ)

                if planarDist <= maxDist and zDiff <= maxZDiff and planarDist < bestDist then
                    foundEntity = entity
                    bestDist = planarDist
                end
            end
        end
    end

    return foundEntity
end

local function findExistingLiftProps(liftPoint)
    if not isExistingPropsEnabled() or not liftPoint or not GetGamePool then
        return nil
    end

    local existingCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.existingProps or {}
    local searchRadius = tonumber(existingCfg.searchRadius) or 1.2
    local zTolerance = tonumber(existingCfg.zTolerance) or 1.0

    local primarySet = resolveModelSet(liftPoint)
    local setsToTry = { primarySet }

    for _, modelSet in ipairs(getModelSets()) do
        if modelSet.name ~= primarySet.name or modelSet.frameModel ~= primarySet.frameModel or modelSet.platformModel ~= primarySet.platformModel then
            table.insert(setsToTry, modelSet)
        end
    end

    for _, modelSet in ipairs(setsToTry) do
        local frameEnt = findExistingObject(modelSet.frameModel, liftPoint.coords, liftPoint.floorZ, searchRadius, zTolerance)
        local platformEnt = findExistingObject(modelSet.platformModel, liftPoint.coords, liftPoint.floorZ, searchRadius, zTolerance, frameEnt)

        if frameEnt ~= 0 and platformEnt ~= 0 then
            return {
                modelSet = modelSet,
                frameEntity = frameEnt,
                platformEntity = platformEnt
            }
        end
    end

    return nil
end

local function isAutoDiscoverEnabled()
    local existingCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.existingProps or {}
    return existingCfg.enabled == true
end

local function buildAutoLiftKey(setName, coords)
    local gridX = math.floor((tonumber(coords.x) or 0.0) * 10.0 + 0.5)
    local gridY = math.floor((tonumber(coords.y) or 0.0) * 10.0 + 0.5)
    local gridZ = math.floor((tonumber(coords.z) or 0.0) * 10.0 + 0.5)
    local setNameStr = tostring(setName or "default")
    return ("%s:auto:%s:%s:%s:%s"):format(LIFT_TYPE, setNameStr, gridX, gridY, gridZ)
end

local function autoDiscoverLiftPoints()
    if not isAutoDiscoverEnabled() or not GetGamePool then
        return {}
    end

    local existingCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.existingProps or {}
    local autoCfg = existingCfg.autoDiscover or {}

    local pairRadius = tonumber(autoCfg.pairRadius) or tonumber(existingCfg.searchRadius) or 1.4
    local zTolerance = tonumber(autoCfg.zTolerance) or tonumber(existingCfg.zTolerance) or 1.0
    local limitsCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.limits or {}
    local travelHeight = tonumber(limitsCfg.travelHeight) or 2.0

    local allObjects = GetGamePool("CObject") or {}
    local discovered = {}
    local usedFrames = {}
    local usedPlatforms = {}
    local seenKeys = {}

    for _, modelSet in ipairs(getModelSets()) do
        local frameHash = GetHashKey(modelSet.frameModel)
        local platformHash = GetHashKey(modelSet.platformModel)

        local frameEntities = {}
        local platformEntities = {}

        for _, ent in ipairs(allObjects) do
            if ent ~= 0 and DoesEntityExist(ent) then
                local modelHash = GetEntityModel(ent)
                if modelHash == frameHash then
                    table.insert(frameEntities, ent)
                end
                if modelHash == platformHash then
                    table.insert(platformEntities, ent)
                end
            end
        end

        for _, platformEnt in ipairs(platformEntities) do
            if not usedPlatforms[platformEnt] and not IsEntityAttached(platformEnt) then
                local platformCoords = GetEntityCoords(platformEnt)
                local bestFrameEnt = 0
                local bestDist = pairRadius + 0.001

                for _, frameEnt in ipairs(frameEntities) do
                    if frameEnt ~= platformEnt and not usedFrames[frameEnt] then
                        local frameCoords = GetEntityCoords(frameEnt)
                        local planarDist = #(vector2(frameCoords.x, frameCoords.y) - vector2(platformCoords.x, platformCoords.y))
                        local zDiff = math.abs(frameCoords.z - platformCoords.z)

                        if planarDist <= pairRadius and zDiff <= zTolerance and planarDist < bestDist then
                            bestFrameEnt = frameEnt
                            bestDist = planarDist
                        end
                    end
                end

                if bestFrameEnt ~= 0 then
                    local autoKey = buildAutoLiftKey(modelSet.name, platformCoords)
                    if not seenKeys[autoKey] then
                        local heading = GetEntityHeading(platformEnt)
                        local floorZ = platformCoords.z

                        table.insert(discovered, {
                            key = autoKey,
                            coords = vector3(platformCoords.x, platformCoords.y, floorZ),
                            heading = heading,
                            modelSet = modelSet.name,
                            frameModel = modelSet.frameModel,
                            platformModel = modelSet.platformModel,
                            floorZ = floorZ,
                            topZ = floorZ + travelHeight,
                            autoDiscovered = true
                        })

                        seenKeys[autoKey] = true
                        usedPlatforms[platformEnt] = true
                        usedFrames[bestFrameEnt] = true

                        debugLog("auto discovered lift key=%s modelSet=%s frame=%s platform=%s distance=%.3f coords=(%s)",
                            tostring(autoKey), tostring(modelSet.name), tostring(bestFrameEnt), tostring(platformEnt),
                            bestDist, formatCoords(platformCoords))
                    end
                end
            end
        end
    end

    debugLog("auto discovery complete count=%s", tostring(#discovered))
    return discovered
end

local function debugScanNearbyObjects(liftPoint, tag, radius)
    if not isDebugActive() or not liftPoint or not GetGamePool then return end

    local modelMap = getAllowedLiftModelHashes(liftPoint)
    local scanRadius = tonumber(radius) or 8.0
    local allObjects = GetGamePool("CObject") or {}

    local liftObjects = {}
    local nearbyObjects = {}

    for _, ent in ipairs(allObjects) do
        if ent ~= 0 and DoesEntityExist(ent) then
            local modelHash = GetEntityModel(ent)
            local modelName = modelMap[modelHash]
            local coords = GetEntityCoords(ent)
            local dist = #(coords - liftPoint.coords)

            if dist <= scanRadius then
                table.insert(nearbyObjects, {
                    entity = ent,
                    modelHash = modelHash,
                    model = modelName or tostring(modelHash),
                    distance = dist,
                    coords = coords,
                    attached = IsEntityAttached(ent)
                })
            end

            if modelName and dist <= scanRadius then
                table.insert(liftObjects, {
                    entity = ent,
                    model = modelName,
                    distance = dist,
                    coords = coords,
                    attached = IsEntityAttached(ent),
                    collision = not IsEntityWaitingForWorldCollision(ent)
                })
            end
        end
    end

    table.sort(liftObjects, function(a, b) return a.distance < b.distance end)
    table.sort(nearbyObjects, function(a, b) return a.distance < b.distance end)

    debugLog("%s nearby scan key=%s radius=%.1f allObjects=%s liftObjects=%s center=(%s)",
        tostring(tag), tostring(liftPoint.key), scanRadius, tostring(#nearbyObjects), tostring(#liftObjects), formatCoords(liftPoint.coords))

    for idx, item in ipairs(nearbyObjects) do
        if idx > 20 then
            debugLog("%s nearbyObjects truncated remaining=%s", tostring(tag), tostring(#nearbyObjects - 20))
            break
        end
        debugLog("%s object[%s] entity=%s modelHash=%s model=%s distance=%.3f coords=(%s) attached=%s",
            tostring(tag), tostring(idx), tostring(item.entity), tostring(item.modelHash), tostring(item.model),
            item.distance, formatCoords(item.coords), boolToString(item.attached))
    end

    for idx, item in ipairs(liftObjects) do
        debugLog("%s nearby[%s] entity=%s model=%s distance=%.3f coords=(%s) attached=%s worldCollisionReady=%s",
            tostring(tag), tostring(idx), tostring(item.entity), tostring(item.model),
            item.distance, formatCoords(item.coords), boolToString(item.attached), boolToString(item.collision))
    end
end

local function cleanupOrphanProps(liftPoint, reason)
    if not liftPoint or not GetGamePool then return 0 end

    if liftPoint.usesExistingProps then
        debugLog("%s orphan cleanup skipped key=%s reason=existing_props", tostring(reason), tostring(liftPoint.key))
        return 0
    end

    local allowedHashes = getAllowedLiftModelHashes(liftPoint)
    local allObjects = GetGamePool("CObject") or {}
    local orphanCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.orphanCleanup or {}

    local maxRadius = tonumber(orphanCfg.radius) or 0.35
    local maxZDiff = tonumber(orphanCfg.zTolerance) or 0.45
    local removedCount = 0

    for _, ent in ipairs(allObjects) do
        if ent ~= 0 and ent ~= liftPoint.frameEntity and ent ~= liftPoint.platformEntity and DoesEntityExist(ent) then
            local modelHash = GetEntityModel(ent)
            local modelName = allowedHashes[modelHash]

            if modelName then
                local entCoords = GetEntityCoords(ent)
                local planarDist = #(vector2(entCoords.x, entCoords.y) - vector2(liftPoint.coords.x, liftPoint.coords.y))
                local zDiff = math.abs(entCoords.z - liftPoint.floorZ)

                if planarDist <= maxRadius and zDiff <= maxZDiff then
                    debugLog("%s orphan cleanup delete entity=%s model=%s planarDistance=%.3f verticalDistance=%.3f coords=(%s)",
                        tostring(reason), tostring(ent), tostring(modelName), planarDist, zDiff, formatCoords(entCoords))

                    if IsEntityAttached(ent) then
                        DetachEntity(ent, true, true)
                    end
                    SetEntityAsMissionEntity(ent, true, true)
                    DeleteEntity(ent)
                    removedCount = removedCount + 1
                end
            end
        end
    end

    if removedCount > 0 then
        debugLog("%s orphan cleanup complete key=%s removed=%s radius=%.2f zTolerance=%.2f",
            tostring(reason), tostring(liftPoint.key), tostring(removedCount), maxRadius, maxZDiff)
    end

    return removedCount
end

-- ============================================================
--  NETWORK & ATTACHMENT SYNC
-- ============================================================

local function syncAttachment(liftPoint, action, vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        debugLog("syncAttachment skipped key=%s action=%s reason=vehicle_missing vehicle=%s",
            tostring(liftPoint and liftPoint.key), tostring(action), tostring(vehicle))
        return
    end

    local vehNetId = VehToNet(vehicle)
    local vehCoords = GetEntityCoords(vehicle)

    debugLog("syncAttachment send key=%s action=%s vehicle=%s vehicleNetId=%s vehicleCoords=(%s)",
        tostring(liftPoint.key), tostring(action), tostring(vehicle), tostring(vehNetId), formatCoords(vehCoords))

    TriggerServerEvent("sky_mechanicjob:lift:syncAttachment", {
        key = liftPoint.key,
        action = action,
        vehicleNetId = vehNetId
    })
end

local function lowerAndDetachVehicleBeforeDestroy(liftPoint)
    local vehicle = liftPoint.attachedVehicle
    local heightOffset = math.max((tonumber(liftPoint.positionZ) or 0.0) - (tonumber(liftPoint.floorZ) or 0.0), 0.0)

    if vehicle == 0 or not DoesEntityExist(vehicle) or heightOffset <= 0.02 then
        return
    end

    if not requestVehicleControl(vehicle, 500) then
        print(("[sky_mechanicjob][lift] failed: could not lower vehicle before destroying point '%s'"):format(liftPoint.key))
        return
    end

    syncAttachment(liftPoint, "detach", vehicle)

    if liftPoint.platformEntity ~= 0 and DoesEntityExist(liftPoint.platformEntity) and IsEntityAttached(liftPoint.platformEntity) then
        DetachEntity(liftPoint.platformEntity, true, true)
    end

    local origCoords = GetEntityCoords(vehicle)
    FreezeEntityPosition(vehicle, false)
    SetEntityCoordsNoOffset(vehicle, origCoords.x, origCoords.y, origCoords.z - heightOffset, false, false, false)
    SetVehicleOnGroundProperly(vehicle)

    debugLog("destroy lowered vehicle key=%s vehicle=%s travelHeight=%.3f from=(%s) to=(%s)",
        tostring(liftPoint.key), tostring(vehicle), heightOffset, formatCoords(origCoords), formatCoords(GetEntityCoords(vehicle)))
end

local function destroyLiftPoint(liftPoint)
    debugLog("destroy start key=%s live=%s frame=%s frameExists=%s platform=%s platformExists=%s attachedVehicle=%s positionZ=%.3f floorZ=%.3f",
        tostring(liftPoint.key), boolToString(liftPoint.live), tostring(liftPoint.frameEntity),
        boolToString(liftPoint.frameEntity ~= 0 and DoesEntityExist(liftPoint.frameEntity)),
        tostring(liftPoint.platformEntity),
        boolToString(liftPoint.platformEntity ~= 0 and DoesEntityExist(liftPoint.platformEntity)),
        tostring(liftPoint.attachedVehicle), tonumber(liftPoint.positionZ) or 0.0, tonumber(liftPoint.floorZ) or 0.0)

    debugScanNearbyObjects(liftPoint, "destroy:before", 6.0)
    lowerAndDetachVehicleBeforeDestroy(liftPoint)

    if liftPoint.platformEntity ~= 0 and DoesEntityExist(liftPoint.platformEntity) and IsEntityAttached(liftPoint.platformEntity) then
        syncAttachment(liftPoint, "detach", liftPoint.attachedVehicle)
        DetachEntity(liftPoint.platformEntity, true, true)
    end

    if liftPoint.attachedVehicle ~= 0 and DoesEntityExist(liftPoint.attachedVehicle) then
        FreezeEntityPosition(liftPoint.attachedVehicle, false)
    end

    liftPoint.attachedVehicle = 0
    liftPoint.syncedAttachment = false

    local isExisting = liftPoint.usesExistingProps == true
    local ownsPlatform = liftPoint.platformOwned ~= false
    local ownsFrame = liftPoint.frameOwned ~= false

    if isExisting and liftPoint.platformEntity ~= 0 and DoesEntityExist(liftPoint.platformEntity) then
        SetEntityCoordsNoOffset(liftPoint.platformEntity, liftPoint.coords.x, liftPoint.coords.y, liftPoint.floorZ, false, false, false)
        SetEntityHeading(liftPoint.platformEntity, liftPoint.heading)
        FreezeEntityPosition(liftPoint.platformEntity, true)
    end

    if liftPoint.platformEntity ~= 0 and DoesEntityExist(liftPoint.platformEntity) and ownsPlatform then
        DeleteEntity(liftPoint.platformEntity)
    end

    if liftPoint.frameEntity ~= 0 and DoesEntityExist(liftPoint.frameEntity) and ownsFrame then
        DeleteEntity(liftPoint.frameEntity)
    end

    liftPoint.platformEntity = 0
    liftPoint.frameEntity = 0
    liftPoint.platformOwned = true
    liftPoint.frameOwned = true
    liftPoint.usesExistingProps = false
    liftPoint.live = false
    liftPoint.motion = 0
    liftPoint.positionZ = liftPoint.floorZ

    if not isExisting then
        cleanupOrphanProps(liftPoint, "destroy:after-tracked-delete")
    end

    debugScanNearbyObjects(liftPoint, "destroy:after", 6.0)
end

-- ============================================================
--  VEHICLE ATTACHMENT MANAGEMENT
-- ============================================================

local function getVehicleForLift(liftPoint)
    local attachCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.vehicleAttach or {}
    local searchRadius = tonumber(attachCfg.searchRadius) or 2.6

    local veh = getClosestVehicleWithPoliceFallback(
        liftPoint.coords.x, liftPoint.coords.y, liftPoint.coords.z,
        searchRadius + 0.5, 0, 70
    )

    if veh ~= 0 and DoesEntityExist(veh) and not IsEntityDead(veh) then
        local vehCoords = GetEntityCoords(veh)
        local planarDist = #(vector2(vehCoords.x, vehCoords.y) - vector2(liftPoint.coords.x, liftPoint.coords.y))
        if planarDist <= searchRadius then
            return veh
        end
    end

    return 0
end

local function recoverFloatingVehicle(liftPoint)
    if not GetGamePool then return end

    local attachCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.vehicleAttach or {}
    local searchRadius = tonumber(attachCfg.searchRadius) or 2.6
    local maxZ = liftPoint.topZ + 2.0

    local vehicles = GetGamePool("CVehicle") or {}
    local targetVeh = 0
    local targetDist = searchRadius + 0.001

    for _, veh in ipairs(vehicles) do
        if veh ~= 0 and DoesEntityExist(veh) and not IsEntityDead(veh) then
            local vehCoords = GetEntityCoords(veh)
            local planarDist = #(vector2(vehCoords.x, vehCoords.y) - vector2(liftPoint.coords.x, liftPoint.coords.y))

            if planarDist <= searchRadius and planarDist < targetDist then
                if vehCoords.z > (liftPoint.floorZ + 0.75) and vehCoords.z <= maxZ then
                    if GetEntityHeightAboveGround(veh) > 1.0 then
                        targetVeh = veh
                        targetDist = planarDist
                    end
                end
            end
        end
    end

    if targetVeh ~= 0 and requestVehicleControl(targetVeh, 1200) then
        FreezeEntityPosition(targetVeh, false)
        SetVehicleOnGroundProperly(targetVeh)

        debugLog("startup recovered floating vehicle key=%s vehicle=%s planarDistance=%.3f coords=(%s)",
            tostring(liftPoint.key), tostring(targetVeh), targetDist, formatCoords(GetEntityCoords(targetVeh)))
    end
end

local function attachVehicleToLift(liftPoint, vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print(("[sky_mechanicjob][lift] failed: attach target vehicle missing for point '%s'"):format(liftPoint.key))
        return false
    end

    if liftPoint.platformEntity == 0 or not DoesEntityExist(liftPoint.platformEntity) then
        print(("[sky_mechanicjob][lift] failed: moving platform missing for point '%s'"):format(liftPoint.key))
        return false
    end

    if not requestVehicleControl(vehicle, 1200) then
        print(("[sky_mechanicjob][lift] failed: could not get network control for vehicle at point '%s'"):format(liftPoint.key))
        return false
    end

    requestVehicleControl(liftPoint.platformEntity, 500)

    local platformCoords = GetEntityCoords(liftPoint.platformEntity)
    local offsetCoords = GetOffsetFromEntityGivenWorldCoords(vehicle, platformCoords.x, platformCoords.y, platformCoords.z)
    local vehRotation = GetEntityRotation(vehicle, 2)
    local platformRotation = GetEntityRotation(liftPoint.platformEntity, 2)

    FreezeEntityPosition(liftPoint.platformEntity, false)
    FreezeEntityPosition(vehicle, true)

    AttachEntityToEntity(
        liftPoint.platformEntity, vehicle, -1,
        offsetCoords.x, offsetCoords.y, offsetCoords.z,
        platformRotation.x - vehRotation.x,
        platformRotation.y - vehRotation.y,
        platformRotation.z - vehRotation.z,
        false, false, false, false, 2, true
    )

    SetEntityCoordsNoOffset(liftPoint.platformEntity, platformCoords.x, platformCoords.y, platformCoords.z, false, false, false)

    liftPoint.attachedVehicle = vehicle
    liftPoint.syncedAttachment = false

    syncAttachment(liftPoint, "attach", vehicle)
    return true
end

local function detachVehicleFromLift(liftPoint)
    local vehicle = liftPoint.attachedVehicle
    if vehicle == 0 then return end

    syncAttachment(liftPoint, "detach", vehicle)

    if liftPoint.platformEntity ~= 0 and DoesEntityExist(liftPoint.platformEntity) and IsEntityAttached(liftPoint.platformEntity) then
        DetachEntity(liftPoint.platformEntity, true, true)
        SetEntityCoordsNoOffset(liftPoint.platformEntity, liftPoint.coords.x, liftPoint.coords.y, liftPoint.floorZ, false, false, false)
        SetEntityHeading(liftPoint.platformEntity, liftPoint.heading)
        FreezeEntityPosition(liftPoint.platformEntity, true)
    end

    if DoesEntityExist(vehicle) then
        FreezeEntityPosition(vehicle, false)
    end

    liftPoint.attachedVehicle = 0
    liftPoint.syncedAttachment = false
end

local function handleVehicleEnter(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end

    for _, liftPoint in ipairs(State.pointList) do
        debugScanNearbyObjects(liftPoint, "vehicleEnter:scan", 8.0)

        local isPlatformAttachedToVehicle = false
        if liftPoint.platformEntity ~= 0 and DoesEntityExist(liftPoint.platformEntity) then
            isPlatformAttachedToVehicle = IsEntityAttachedToEntity(liftPoint.platformEntity, vehicle)
        end

        if liftPoint.attachedVehicle == vehicle or isPlatformAttachedToVehicle then
            print(("[sky_mechanicjob][lift] cleanup: reset lift point '%s' still attached on vehicle enter"):format(liftPoint.key))
            destroyLiftPoint(liftPoint)
            spawnLiftPoint(liftPoint)
        end
    end

    local vehCoords = GetEntityCoords(vehicle)
    for _, modelSet in ipairs(getModelSets()) do
        local platformModel = modelSet.platformModel or "sky_carlift_frame"
        local nearbyPlatform = GetClosestObjectOfType(vehCoords.x, vehCoords.y, vehCoords.z, 8.0, GetHashKey(platformModel), false, false, false)

        if nearbyPlatform ~= 0 and DoesEntityExist(nearbyPlatform) then
            if IsEntityAttachedToEntity(nearbyPlatform, vehicle) then
                local foundPoint = nil
                for _, pt in ipairs(State.pointList) do
                    if pt.platformEntity == nearbyPlatform then
                        foundPoint = pt
                        break
                    end
                end

                print(("[sky_mechanicjob][lift] cleanup: reset nearby orphaned platform still attached on vehicle enter model '%s'"):format(platformModel))
                requestVehicleControl(nearbyPlatform, 500)
                DetachEntity(nearbyPlatform, true, true)

                if foundPoint and foundPoint.platformOwned == false then
                    SetEntityCoordsNoOffset(nearbyPlatform, foundPoint.coords.x, foundPoint.coords.y, foundPoint.floorZ, false, false, false)
                    SetEntityHeading(nearbyPlatform, foundPoint.heading)
                    FreezeEntityPosition(nearbyPlatform, true)
                else
                    SetEntityAsMissionEntity(nearbyPlatform, true, true)
                    DeleteEntity(nearbyPlatform)
                end
            else
                debugLog("vehicleEnter orphan scan vehicle=%s coords=(%s) platformModel=%s nearbyPlatform=%s exists=%s attachedToVehicle=%s",
                    tostring(vehicle), formatCoords(vehCoords), tostring(platformModel), tostring(nearbyPlatform),
                    boolToString(DoesEntityExist(nearbyPlatform)),
                    boolToString(DoesEntityExist(nearbyPlatform) and IsEntityAttachedToEntity(nearbyPlatform, vehicle)))
            end
        end
    end
end

local function autoAttachVehicleIfNearby(liftPoint)
    if liftPoint.attachedVehicle ~= 0 and DoesEntityExist(liftPoint.attachedVehicle) then
        return
    end

    local vehicle = getVehicleForLift(liftPoint)
    if vehicle == 0 then return end

    attachVehicleToLift(liftPoint, vehicle)
end

local function applySyncedAttachment(liftPoint, vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print(("[sky_mechanicjob][lift] failed: synced attach vehicle missing for point '%s'"):format(liftPoint.key))
        return
    end

    if liftPoint.platformEntity == 0 or not DoesEntityExist(liftPoint.platformEntity) then
        print(("[sky_mechanicjob][lift] failed: synced attach platform missing for point '%s'"):format(liftPoint.key))
        return
    end

    local platformCoords = GetEntityCoords(liftPoint.platformEntity)
    local offsetCoords = GetOffsetFromEntityGivenWorldCoords(vehicle, platformCoords.x, platformCoords.y, platformCoords.z)
    local vehRotation = GetEntityRotation(vehicle, 2)
    local platformRotation = GetEntityRotation(liftPoint.platformEntity, 2)

    requestVehicleControl(liftPoint.platformEntity, 500)
    FreezeEntityPosition(liftPoint.platformEntity, false)

    AttachEntityToEntity(
        liftPoint.platformEntity, vehicle, -1,
        offsetCoords.x, offsetCoords.y, offsetCoords.z,
        platformRotation.x - vehRotation.x,
        platformRotation.y - vehRotation.y,
        platformRotation.z - vehRotation.z,
        false, false, false, false, 2, true
    )

    SetEntityCoordsNoOffset(liftPoint.platformEntity, platformCoords.x, platformCoords.y, platformCoords.z, false, false, false)

    liftPoint.attachedVehicle = vehicle
    liftPoint.syncedAttachment = true
end

local function applySyncedDetach(liftPoint)
    if liftPoint.platformEntity ~= 0 and DoesEntityExist(liftPoint.platformEntity) then
        if IsEntityAttached(liftPoint.platformEntity) then
            DetachEntity(liftPoint.platformEntity, true, true)
        end
        SetEntityCoordsNoOffset(liftPoint.platformEntity, liftPoint.coords.x, liftPoint.coords.y, liftPoint.floorZ, false, false, false)
        SetEntityHeading(liftPoint.platformEntity, liftPoint.heading)
        FreezeEntityPosition(liftPoint.platformEntity, true)
    end

    liftPoint.attachedVehicle = 0
    liftPoint.syncedAttachment = false
    liftPoint.positionZ = liftPoint.floorZ
end

-- ============================================================
--  OBJECT SPAWNING & LIFTCYCLE
-- ============================================================

local function createLiftObject(modelName, centerCoords, heading, targetZ, disableCollision)
    local modelHash = GetHashKey(modelName)
    debugLog("createObject request model=%s hash=%s coords=(%s) z=%.3f heading=%.3f collision=%s valid=%s",
        tostring(modelName), tostring(modelHash), formatCoords(centerCoords), tonumber(targetZ) or 0.0,
        tonumber(heading) or 0.0, boolToString(disableCollision ~= false), boolToString(IsModelValid(modelHash)))

    if not IsModelValid(modelHash) then
        print(("[sky_mechanicjob][lift] failed: invalid model '%s'"):format(tostring(modelName)))
        return 0
    end

    Sky.Load.Model(modelHash)
    local entity = CreateObject(modelHash, centerCoords.x, centerCoords.y, targetZ, false, false, false)

    if entity == 0 or not DoesEntityExist(entity) then
        print(("[sky_mechanicjob][lift] failed: could not create object for model '%s'"):format(tostring(modelName)))
        return 0
    end

    SetEntityAsMissionEntity(entity, true, true)
    SetEntityHeading(entity, heading)
    SetEntityCoordsNoOffset(entity, centerCoords.x, centerCoords.y, targetZ, false, false, false)
    SetEntityCollision(entity, disableCollision ~= false, disableCollision ~= false)
    FreezeEntityPosition(entity, true)

    debugLog("createObject success entity=%s model=%s hash=%s coords=(%s) heading=%.3f attached=%s alpha=%s",
        tostring(entity), tostring(modelName), tostring(modelHash), formatCoords(GetEntityCoords(entity)),
        tonumber(GetEntityHeading(entity)) or 0.0, boolToString(IsEntityAttached(entity)), tostring(GetEntityAlpha(entity)))

    SetModelAsNoLongerNeeded(modelHash)
    return entity
end

spawnLiftPoint = function(liftPoint)
    local resolvedSet = resolveModelSet(liftPoint)
    liftPoint.frameModel = resolvedSet.frameModel
    liftPoint.platformModel = resolvedSet.platformModel

    debugLog("spawn start key=%s modelSet=%s frameModel=%s platformModel=%s coords=(%s) heading=%.3f floorZ=%.3f positionZ=%.3f topZ=%.3f live=%s",
        tostring(liftPoint.key), tostring(resolvedSet.name), tostring(liftPoint.frameModel), tostring(liftPoint.platformModel),
        formatCoords(liftPoint.coords), tonumber(liftPoint.heading) or 0.0, tonumber(liftPoint.floorZ) or 0.0,
        tonumber(liftPoint.positionZ) or 0.0, tonumber(liftPoint.topZ) or 0.0, boolToString(liftPoint.live))

    debugScanNearbyObjects(liftPoint, "spawn:before", 6.0)

    local existingProps = findExistingLiftProps(liftPoint)
    if existingProps then
        local frameCoords = GetEntityCoords(existingProps.frameEntity)
        local platformCoords = GetEntityCoords(existingProps.platformEntity)
        local travelRange = math.max((tonumber(liftPoint.topZ) or 0.0) - (tonumber(liftPoint.floorZ) or 0.0), 0.1)

        liftPoint.frameEntity = existingProps.frameEntity
        liftPoint.platformEntity = existingProps.platformEntity
        liftPoint.frameModel = existingProps.modelSet.frameModel
        liftPoint.platformModel = existingProps.modelSet.platformModel
        liftPoint.modelSet = existingProps.modelSet.name
        liftPoint.frameOwned = false
        liftPoint.platformOwned = false
        liftPoint.usesExistingProps = true
        liftPoint.floorZ = platformCoords.z
        liftPoint.positionZ = platformCoords.z
        liftPoint.topZ = liftPoint.floorZ + travelRange
        liftPoint.live = true
        liftPoint.motion = 0

        if requestVehicleControl(existingProps.platformEntity, 500) then
            FreezeEntityPosition(existingProps.platformEntity, true)
            SetEntityCollision(existingProps.platformEntity, true, true)
        end
        if requestVehicleControl(existingProps.frameEntity, 500) then
            FreezeEntityPosition(existingProps.frameEntity, true)
            SetEntityCollision(existingProps.frameEntity, true, true)
        end

        debugLog("spawn existing props key=%s modelSet=%s frame=%s platform=%s frameCoords=(%s) platformCoords=(%s) floorZ=%.3f topZ=%.3f",
            tostring(liftPoint.key), tostring(existingProps.modelSet.name), tostring(existingProps.frameEntity),
            tostring(existingProps.platformEntity), formatCoords(frameCoords), formatCoords(platformCoords),
            tonumber(liftPoint.floorZ) or 0.0, tonumber(liftPoint.topZ) or 0.0)

        debugScanNearbyObjects(liftPoint, "spawn:existing", 6.0)
        return true
    end

    liftPoint.frameOwned = true
    liftPoint.platformOwned = true
    liftPoint.usesExistingProps = false

    cleanupOrphanProps(liftPoint, "spawn:before")
    debugScanNearbyObjects(liftPoint, "spawn:after-orphan-cleanup", 6.0)

    local frameEnt = createLiftObject(liftPoint.frameModel, liftPoint.coords, liftPoint.heading, liftPoint.floorZ, true)
    if frameEnt == 0 then
        notify(getTuningLocale("LiftMissingProp", "Lift model could not be loaded."), "error")
        return false
    end

    local platformEnt = createLiftObject(liftPoint.platformModel, liftPoint.coords, liftPoint.heading, liftPoint.positionZ, false)
    if platformEnt == 0 then
        if DoesEntityExist(frameEnt) then
            DeleteEntity(frameEnt)
        end
        notify(getTuningLocale("LiftMissingProp", "Lift model could not be loaded."), "error")
        return false
    end

    liftPoint.frameEntity = frameEnt
    liftPoint.platformEntity = platformEnt
    liftPoint.live = true
    liftPoint.motion = 0

    local isAtSameCoords = #(GetEntityCoords(frameEnt) - GetEntityCoords(platformEnt)) <= 0.01

    debugLog("spawn complete key=%s frameEntity=%s platformEntity=%s frameModel=%s platformModel=%s sameCoords=%s",
        tostring(liftPoint.key), tostring(frameEnt), tostring(platformEnt),
        tostring(liftPoint.frameModel), tostring(liftPoint.platformModel), boolToString(isAtSameCoords))

    debugScanNearbyObjects(liftPoint, "spawn:after", 6.0)
    return true
end

local function powerOnLiftPoint(liftPoint)
    if liftPoint.live then
        return true
    end
    if spawnLiftPoint(liftPoint) then
        notify(getTuningLocale("LiftPowerOn", "Lift powered on."), "success")
        return true
    end
    return false
end

local function ensureLiftPointReady(liftPoint, tag)
    if not liftPoint then return false end

    local hasFrame = liftPoint.frameEntity ~= 0 and DoesEntityExist(liftPoint.frameEntity)
    local hasPlatform = liftPoint.platformEntity ~= 0 and DoesEntityExist(liftPoint.platformEntity)

    if liftPoint.live and hasFrame and hasPlatform then
        return true
    end

    debugLog("%s ensure ready repair key=%s live=%s frame=%s frameExists=%s platform=%s platformExists=%s",
        tostring(tag), tostring(liftPoint.key), boolToString(liftPoint.live),
        tostring(liftPoint.frameEntity), boolToString(hasFrame),
        tostring(liftPoint.platformEntity), boolToString(hasPlatform))

    destroyLiftPoint(liftPoint)
    return spawnLiftPoint(liftPoint)
end

-- ============================================================
--  CREATOR & LIFT POINT SYNCHRONIZATION
-- ============================================================

local function buildCreatorPointKey(id, uid, pointType)
    return ("%s:%s:%s"):format(tostring(pointType), tostring(id), tostring(uid))
end

local function isPointNearAny(targetPoint, list, maxRadius)
    if not targetPoint or type(list) ~= "table" then return false end
    local radius = tonumber(maxRadius) or 1.4

    for _, pt in ipairs(list) do
        if pt and pt.coords then
            local dist = #(vector2(targetPoint.coords.x, targetPoint.coords.y) - vector2(pt.coords.x, pt.coords.y))
            if dist <= radius then
                return true
            end
        end
    end
    return false
end

local function getCreatorData()
    if type(State.creatorCache) == "table" then
        return State.creatorCache
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:creator:getData", { creatorKey = CREATOR_KEY })
    if type(res) == "table" and res.success == true and type(res.data) == "table" then
        State.creatorCache = res.data
    end
    return State.creatorCache
end

local function collectCreatorLiftPoints()
    local creatorData = getCreatorData()
    if type(creatorData) ~= "table" or type(creatorData.entries) ~= "table" then
        debugLog("collectCreatorLiftPoints skipped payloadType=%s entriesType=%s",
            type(creatorData), type(creatorData and creatorData.entries))
        return {}
    end

    local defaultSet = getDefaultModelSet()
    local creatorCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.creator or {}

    local defaultFrame = tostring(defaultSet.frameModel or creatorCfg.frameModel or "sky_carlift_platform")
    local defaultPlatform = tostring(defaultSet.platformModel or creatorCfg.platformModel or "sky_carlift_frame")
    local travelHeight = tonumber(Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.limits and Config.WorkshopLiftSystem.limits.travelHeight) or 2.0

    local collected = {}

    debugLog("collectCreatorLiftPoints start entries=%s defaultModelSet=%s frameModel=%s platformModel=%s travelHeight=%.3f",
        tostring(#creatorData.entries), tostring(defaultSet.name), defaultFrame, defaultPlatform, travelHeight)

    for _, entry in ipairs(creatorData.entries) do
        if type(entry) == "table" and type(entry.points) == "table" then
            debugLog("collect entry id=%s name=%s jobKey=%s points=%s",
                tostring(entry.id), tostring(entry.name), tostring(entry.jobKey), tostring(#entry.points))

            for _, pt in ipairs(entry.points) do
                if type(pt) == "table" and pt.type == LIFT_TYPE and pt.x ~= nil and pt.y ~= nil and pt.z ~= nil then
                    local floorZ = tonumber(pt.z) or 0.0

                    local modelSetObj = getModelSetByName(pt.modelSet)
                        or getModelSetByName(pt.liftModelSet)
                        or getModelSetByName(pt.modelSetName)
                        or defaultSet

                    local pointKey = buildCreatorPointKey(entry.id, pt.uid, pt.type)
                    local ptCoords = vector3(tonumber(pt.x) or 0.0, tonumber(pt.y) or 0.0, floorZ)

                    local newPoint = {
                        key = pointKey,
                        coords = ptCoords,
                        heading = tonumber(pt.heading) or 0.0,
                        modelSet = modelSetObj.name,
                        frameModel = modelSetObj.frameModel or defaultFrame,
                        platformModel = modelSetObj.platformModel or defaultPlatform,
                        floorZ = floorZ,
                        topZ = floorZ + travelHeight
                    }

                    table.insert(collected, newPoint)

                    debugLog("collect accepted key=%s uid=%s modelSet=%s coords=(%.3f, %.3f, %.3f) heading=%.3f",
                        tostring(pointKey), tostring(pt.uid), tostring(modelSetObj.name),
                        ptCoords.x, ptCoords.y, ptCoords.z, newPoint.heading)
                elseif type(pt) == "table" and pt.type == LIFT_TYPE then
                    debugLog("collect skipped invalid lift point entry=%s uid=%s x=%s y=%s z=%s",
                        tostring(entry.id), tostring(pt.uid), tostring(pt.x), tostring(pt.y), tostring(pt.z))
                end
            end
        end
    end

    debugLog("collectCreatorLiftPoints complete count=%s", tostring(#collected))
    return collected
end

local function syncLiftPoints()
    local creatorPoints = collectCreatorLiftPoints()
    local autoPoints = autoDiscoverLiftPoints()

    local autoCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.existingProps and Config.WorkshopLiftSystem.existingProps.autoDiscover or {}
    local dedupeRadius = tonumber(autoCfg.creatorDedupeRadius) or tonumber(autoCfg.pairRadius) or 1.4

    for _, autoPt in ipairs(autoPoints) do
        if not isPointNearAny(autoPt, creatorPoints, dedupeRadius) then
            table.insert(creatorPoints, autoPt)
        else
            debugLog("auto discovery skipped duplicate near creator key=%s coords=(%s)",
                tostring(autoPt.key), formatCoords(autoPt.coords))
        end
    end

    local activeKeys = {}
    debugLog("sync points start found=%s existing=%s", tostring(#creatorPoints), tostring(#State.pointList))

    for _, pointData in ipairs(creatorPoints) do
        activeKeys[pointData.key] = true
        local existing = State.pointsByKey[pointData.key]

        if existing == nil then
            local newLift = {
                key = pointData.key,
                coords = pointData.coords,
                heading = pointData.heading,
                modelSet = pointData.modelSet,
                frameModel = pointData.frameModel,
                platformModel = pointData.platformModel,
                floorZ = pointData.floorZ,
                topZ = pointData.topZ,
                positionZ = pointData.floorZ,
                live = false,
                motion = 0,
                platformEntity = 0,
                frameEntity = 0,
                platformOwned = true,
                frameOwned = true,
                usesExistingProps = false,
                autoDiscovered = pointData.autoDiscovered == true,
                attachedVehicle = 0,
                syncedAttachment = false
            }
            State.pointsByKey[pointData.key] = newLift
            table.insert(State.pointList, newLift)

            debugLog("sync add key=%s coords=(%s) heading=%.3f frameModel=%s platformModel=%s",
                tostring(newLift.key), formatCoords(newLift.coords), tonumber(newLift.heading) or 0.0,
                tostring(newLift.frameModel), tostring(newLift.platformModel))
        else
            local isNotExistingProps = existing.usesExistingProps ~= true
            local coordsDiff = #(existing.coords - pointData.coords)
            local headingDiff = math.abs(existing.heading - pointData.heading)

            if isNotExistingProps and (coordsDiff > 0.01 or headingDiff > 0.01) then
                debugLog("sync change key=%s oldCoords=(%s) newCoords=(%s) oldHeading=%.3f newHeading=%.3f oldSet=%s newSet=%s oldModels=%s/%s newModels=%s/%s",
                    tostring(existing.key), formatCoords(existing.coords), formatCoords(pointData.coords),
                    tonumber(existing.heading) or 0.0, tonumber(pointData.heading) or 0.0,
                    tostring(existing.modelSet), tostring(pointData.modelSet),
                    tostring(existing.frameModel), tostring(existing.platformModel),
                    tostring(pointData.frameModel), tostring(pointData.platformModel))

                destroyLiftPoint(existing)

                existing.coords = pointData.coords
                existing.heading = pointData.heading
                existing.modelSet = pointData.modelSet
                existing.frameModel = pointData.frameModel
                existing.platformModel = pointData.platformModel
                existing.autoDiscovered = pointData.autoDiscovered == true
                existing.floorZ = pointData.floorZ
                existing.topZ = pointData.topZ
                existing.positionZ = pointData.floorZ
            end
        end
    end

    for key, liftPoint in pairs(State.pointsByKey) do
        if not activeKeys[key] then
            local isVehicleValid = liftPoint.attachedVehicle ~= 0 and DoesEntityExist(liftPoint.attachedVehicle)

            if isVehicleValid then
                debugLog("sync keep missing auto lift key=%s reason=busy", tostring(key))
            else
                debugLog("sync remove missing key=%s", tostring(key))
                if State.activeUiPointKey == key then
                    State.activeUiPointKey = nil
                end
                destroyLiftPoint(liftPoint)
                State.pointsByKey[key] = nil
            end
        end
    end

    local rebuiltList = {}
    for _, liftPoint in pairs(State.pointsByKey) do
        if not liftPoint.live then
            debugLog("sync spawn inactive key=%s", tostring(liftPoint.key))
            spawnLiftPoint(liftPoint)
        end
        table.insert(rebuiltList, liftPoint)
    end

    State.pointList = rebuiltList
    debugLog("sync points complete rebuilt=%s", tostring(#State.pointList))
end

-- ============================================================
--  QUERY & STATE RETRIEVAL
-- ============================================================

local function getNearestLiftPoint(maxDist)
    local radius = tonumber(maxDist) or 3.0
    local pedCoords = GetEntityCoords(PlayerPedId())

    local closestPoint = nil
    local bestDist = radius + 0.001

    for _, liftPoint in ipairs(State.pointList) do
        local dist = #(pedCoords - liftPoint.coords)
        if dist <= radius and dist < bestDist then
            closestPoint = liftPoint
            bestDist = dist
        end
    end

    return closestPoint, bestDist
end

local function getClosestLiftPoint()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closestPoint = nil
    local bestDist = nil

    for _, liftPoint in ipairs(State.pointList) do
        local dist = #(pedCoords - liftPoint.coords)
        if bestDist == nil or dist < bestDist then
            closestPoint = liftPoint
            bestDist = dist
        end
    end

    return closestPoint, bestDist
end

local function getActiveUiLiftPoint()
    if not State.activeUiPointKey then return nil end
    return State.pointsByKey[State.activeUiPointKey]
end

local function hasAnyActiveMotion()
    for _, liftPoint in ipairs(State.pointList) do
        if liftPoint.live and liftPoint.motion ~= 0 then
            return true
        end
    end
    return false
end

local function shouldWorkerThreadRun()
    local isEnabled = Config and Config.ToggleFeatures and Config.ToggleFeatures.workshopLift
    if isEnabled == false then
        return false
    end
    if State.uiOpen then
        return true
    end
    return hasAnyActiveMotion()
end

-- ============================================================
--  MOTION & WORKER THREAD
-- ============================================================

local function processLiftMotionTick()
    local motionCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.motion or {}
    local tickMs = tonumber(motionCfg.tickMs) or 10
    local unitsPerTick = tonumber(motionCfg.unitsPerTick) or 0.008

    local hasActiveMotion = false

    for _, liftPoint in ipairs(State.pointList) do
        if liftPoint.live then
            local hasPlatform = liftPoint.platformEntity ~= 0 and DoesEntityExist(liftPoint.platformEntity)
            local hasFrame = liftPoint.frameEntity ~= 0 and DoesEntityExist(liftPoint.frameEntity)

            if not hasPlatform or not hasFrame then
                print(("[sky_mechanicjob][lift] failed: missing lift object for point '%s'"):format(liftPoint.key))
                destroyLiftPoint(liftPoint)
                spawnLiftPoint(liftPoint)
            else
                if liftPoint.motion ~= 0 then
                    hasActiveMotion = true
                    local prevMotion = liftPoint.motion
                    local reachedTop = false
                    local reachedFloor = false

                    if liftPoint.attachedVehicle == 0 or not DoesEntityExist(liftPoint.attachedVehicle) then
                        autoAttachVehicleIfNearby(liftPoint)
                    end

                    if liftPoint.attachedVehicle == 0 or not DoesEntityExist(liftPoint.attachedVehicle) then
                        print(("[sky_mechanicjob][lift] failed: moving lift requires a vehicle for point '%s'"):format(liftPoint.key))
                        liftPoint.motion = 0
                    elseif not requestVehicleControl(liftPoint.attachedVehicle, 200) then
                        print(("[sky_mechanicjob][lift] failed: lost network control for vehicle at point '%s'"):format(liftPoint.key))
                        liftPoint.motion = 0
                    else
                        local targetZ = liftPoint.positionZ + (unitsPerTick * liftPoint.motion)

                        if targetZ >= liftPoint.topZ then
                            targetZ = liftPoint.topZ
                            liftPoint.motion = 0
                            reachedTop = true
                        elseif targetZ <= liftPoint.floorZ then
                            targetZ = liftPoint.floorZ
                            liftPoint.motion = 0
                            reachedFloor = true
                        end

                        local deltaZ = targetZ - liftPoint.positionZ
                        liftPoint.positionZ = targetZ

                        local vehCoords = GetEntityCoords(liftPoint.attachedVehicle)
                        SetEntityCoordsNoOffset(liftPoint.attachedVehicle, vehCoords.x, vehCoords.y, vehCoords.z + deltaZ, false, false, false)
                    end

                    if prevMotion ~= 0 and liftPoint.motion == 0 then
                        if type(handleOilChangeLiftMotionComplete) == "function" then
                            local veh = liftPoint.attachedVehicle
                            if veh == 0 or not DoesEntityExist(veh) then
                                if reachedFloor then
                                    veh = getVehicleForLift(liftPoint)
                                end
                            end
                            if veh ~= 0 and DoesEntityExist(veh) then
                                handleOilChangeLiftMotionComplete(veh, reachedTop, reachedFloor)
                            end
                        end
                    end
                end

                if liftPoint.attachedVehicle ~= 0 and not DoesEntityExist(liftPoint.attachedVehicle) then
                    print(("[sky_mechanicjob][lift] failed: attached vehicle missing for point '%s'"):format(liftPoint.key))
                    if liftPoint.platformEntity ~= 0 and DoesEntityExist(liftPoint.platformEntity) then
                        if IsEntityAttached(liftPoint.platformEntity) then
                            DetachEntity(liftPoint.platformEntity, true, true)
                            FreezeEntityPosition(liftPoint.platformEntity, true)
                        end
                    end
                    liftPoint.attachedVehicle = 0
                end

                if liftPoint.attachedVehicle ~= 0 and not liftPoint.syncedAttachment then
                    if liftPoint.positionZ <= (liftPoint.floorZ + 0.02) then
                        detachVehicleFromLift(liftPoint)
                    end
                end

                if liftPoint.motion == 0 and liftPoint.positionZ <= (liftPoint.floorZ + 0.08) then
                    if type(handleOilChangeLiftMotionComplete) == "function" then
                        local veh = liftPoint.attachedVehicle
                        if veh == 0 or not DoesEntityExist(veh) then
                            veh = getVehicleForLift(liftPoint)
                        end
                        if veh ~= 0 and DoesEntityExist(veh) then
                            handleOilChangeLiftMotionComplete(veh, false, true)
                        end
                    end
                end
            end
        end
    end

    if State.uiOpen then
        local activePoint = getActiveUiLiftPoint()
        local maxRadialDist = (tonumber(Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.radialDistance) or 2.5) + 2.5

        if not activePoint then
            closeLiftControlUi()
        else
            local pedCoords = GetEntityCoords(PlayerPedId())
            if #(pedCoords - activePoint.coords) > maxRadialDist then
                closeLiftControlUi()
            end
        end
    end

    if hasActiveMotion then
        Wait(tickMs)
    else
        Wait(250)
    end
end

local function startWorkerThread()
    if State.workerRunning then return end

    State.workerRunning = true
    CreateThread(function()
        while shouldWorkerThreadRun() do
            processLiftMotionTick()
        end
        State.workerRunning = false
    end)
end

-- ============================================================
--  NUI & CONTROL UI
-- ============================================================

closeLiftControlUi = function()
    if not State.uiOpen then return end

    local activePoint = getActiveUiLiftPoint()
    if activePoint then
        activePoint.motion = 0
    end

    State.uiOpen = false
    State.activeUiPointKey = nil

    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "liftControl:close",
        payload = {}
    })
end

local function openLiftControlUi(liftPoint)
    if not liftPoint then
        return false, {
            key = "radial.errors.generic",
            fallback = getTuningLocale("LiftNotNearby", "No lift nearby.")
        }
    end

    if not liftPoint.live then
        if not spawnLiftPoint(liftPoint) then
            return false, {
                key = "radial.errors.generic",
                fallback = getTuningLocale("LiftMissingProp", "Lift model could not be loaded.")
            }
        end
    end

    if liftPoint.live then
        if not ensureLiftPointReady(liftPoint, "openUi") then
            return false, {
                key = "radial.errors.generic",
                fallback = getTuningLocale("LiftMissingProp", "Lift model could not be loaded.")
            }
        end
    end

    State.activeUiPointKey = liftPoint.key
    State.uiOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "state",
        payload = {
            lang = Sky and Sky.Config and Sky.Config.locale,
            locales = nuiLocales
        }
    })

    SendNUIMessage({
        action = "liftControl:open",
        payload = {}
    })

    startWorkerThread()
    return true
end

local function setLiftDirection(direction)
    local liftPoint = getActiveUiLiftPoint()
    if not liftPoint then
        return false, {
            key = "radial.errors.generic",
            fallback = getTuningLocale("LiftNotNearby", "No lift nearby.")
        }
    end

    local dirNum = math.floor(tonumber(direction) or 0)
    if dirNum > 0 then
        dirNum = 1
    elseif dirNum < 0 then
        dirNum = -1
    else
        dirNum = 0
    end

    if dirNum ~= 0 then
        if not ensureLiftPointReady(liftPoint, "setDirection") then
            liftPoint.motion = 0
            return false, {
                key = "radial.errors.generic",
                fallback = getTuningLocale("LiftMissingProp", "Lift model could not be loaded.")
            }
        end
    end

    if dirNum ~= 0 then
        if liftPoint.attachedVehicle == 0 or not DoesEntityExist(liftPoint.attachedVehicle) then
            autoAttachVehicleIfNearby(liftPoint)
        end
    end

    if dirNum ~= 0 and liftPoint.syncedAttachment then
        if not attachVehicleToLift(liftPoint, liftPoint.attachedVehicle) then
            liftPoint.motion = 0
            return false, {
                key = "radial.errors.generic",
                fallback = getTuningLocale("LiftNoVehicle", "No vehicle on lift.")
            }
        end
    end

    if dirNum ~= 0 then
        if liftPoint.attachedVehicle == 0 or not DoesEntityExist(liftPoint.attachedVehicle) then
            print(("[sky_mechanicjob][lift] failed: no vehicle available to move lift point '%s'"):format(liftPoint.key))
            liftPoint.motion = 0
            return false, {
                key = "radial.errors.generic",
                fallback = getTuningLocale("LiftNoVehicle", "No vehicle on lift.")
            }
        end
    end

    liftPoint.motion = dirNum
    if dirNum ~= 0 then
        startWorkerThread()
    end

    return true
end

-- ============================================================
--  EXPORTED FUNCTIONS & PUBLIC API
-- ============================================================

function isLiftRadialActionAvailable()
    if Config and Config.ToggleFeatures and Config.ToggleFeatures.workshopLift == false then
        debugLog("radial unavailable reason=feature_disabled")
        return false
    end

    local maxDist = tonumber(Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.radialDistance) or 2.5
    local nearestPt = getNearestLiftPoint(maxDist)

    if not nearestPt then
        local closestPt, closestDist = getClosestLiftPoint()
        debugLog("radial unavailable reason=no_lift_in_range pointCount=%s maxDistance=%.2f nearestKey=%s nearestDistance=%s pedCoords=(%s)",
            tostring(#State.pointList), maxDist,
            tostring(closestPt and closestPt.key or "nil"),
            tostring(closestDist and ("%.3f"):format(closestDist) or "nil"),
            formatCoords(GetEntityCoords(PlayerPedId())))
        return false
    end

    debugLog("radial available key=%s maxDistance=%.2f coords=(%s)",
        tostring(nearestPt.key), maxDist, formatCoords(nearestPt.coords))
    return true
end

function openNearestLiftControlUi()
    if Config and Config.ToggleFeatures and Config.ToggleFeatures.workshopLift == false then
        debugLog("openNearest unavailable reason=feature_disabled")
        return false, {
            key = "radial.errors.generic",
            fallback = getTuningLocale("LiftNotNearby", "No lift nearby.")
        }
    end

    local maxDist = tonumber(Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.radialDistance) or 2.5
    local nearestPt = getNearestLiftPoint(maxDist)

    if not nearestPt then
        local closestPt, closestDist = getClosestLiftPoint()
        debugLog("openNearest unavailable reason=no_lift_in_range pointCount=%s maxDistance=%.2f nearestKey=%s nearestDistance=%s pedCoords=(%s)",
            tostring(#State.pointList), maxDist,
            tostring(closestPt and closestPt.key or "nil"),
            tostring(closestDist and ("%.3f"):format(closestDist) or "nil"),
            formatCoords(GetEntityCoords(PlayerPedId())))
    end

    return openLiftControlUi(nearestPt)
end

function getWorkshopLiftStateForVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return nil
    end

    local vehCoords = GetEntityCoords(vehicle)
    local attachCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.vehicleAttach or {}
    local searchRadius = (tonumber(attachCfg.searchRadius) or 2.6) + 0.2
    local zTolerance = 1.5

    for _, liftPoint in ipairs(State.pointList) do
        local heightDiff = liftPoint.positionZ - liftPoint.floorZ
        local isAttached = liftPoint.attachedVehicle ~= 0 and DoesEntityExist(liftPoint.attachedVehicle)

        local planarDist = #(vector2(vehCoords.x, vehCoords.y) - vector2(liftPoint.coords.x, liftPoint.coords.y))
        local zDiff = math.abs(vehCoords.z - liftPoint.positionZ)
        local inRange = planarDist <= searchRadius and zDiff <= zTolerance

        if isAttached or inRange then
            return {
                key = liftPoint.key,
                coords = liftPoint.coords,
                floorZ = liftPoint.floorZ,
                platformZ = liftPoint.positionZ,
                travelHeight = heightDiff,
                attached = isAttached,
                raised = heightDiff >= 0.45,
                atFloor = heightDiff <= 0.08
            }
        end
    end

    return nil
end

-- ============================================================
--  NUI CALLBACKS & NET EVENTS
-- ============================================================

RegisterNUICallback("liftControl:setDirection", function(data, cb)
    local dir = data and data.direction
    local ok, err = setLiftDirection(dir)
    if not ok and type(err) == "table" and type(err.fallback) == "string" then
        notify(err.fallback, "error")
    end
    cb({ success = ok })
end)

RegisterNUICallback("liftControl:close", function(data, cb)
    closeLiftControlUi()
    cb({ success = true })
end)

RegisterNetEvent("sky_mechanicjob:lift:attachment", function(data)
    debugLog("attachment event action=%s key=%s vehicleNetId=%s",
        tostring(data and data.action), tostring(data and data.key), tostring(data and data.vehicleNetId))

    if type(data) ~= "table" or type(data.key) ~= "string" then
        print("[sky_mechanicjob][lift] failed: invalid synced attachment payload")
        return
    end

    local liftPoint = State.pointsByKey[data.key]
    if not liftPoint then return end

    if not liftPoint.live and not spawnLiftPoint(liftPoint) then
        return
    end

    if data.action == "attach" then
        local vehNetId = tonumber(data.vehicleNetId) or 0
        if vehNetId <= 0 then
            print(("[sky_mechanicjob][lift] failed: invalid synced vehicle net id for point '%s'"):format(liftPoint.key))
            return
        end
        local vehicle = NetToVeh(vehNetId)
        applySyncedAttachment(liftPoint, vehicle)
    elseif data.action == "detach" then
        applySyncedDetach(liftPoint)
    else
        print(("[sky_mechanicjob][lift] failed: invalid synced attachment action '%s'"):format(tostring(data.action)))
    end
end)

AddEventHandler("gameEventTriggered", function(eventName, data)
    if eventName ~= "CEventNetworkPlayerEnteredVehicle" then return end

    local vehicle = 0
    if data and data[2] then
        vehicle = data[2]
    else
        vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    end

    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle then return end

    handleVehicleEnter(vehicle)
end)

RegisterNetEvent("sky_jobs_base:creatorUpdated", function(creatorKey, payload)
    if creatorKey == CREATOR_KEY then
        local entryCount = (type(payload) == "table" and type(payload.entries) == "table") and #payload.entries or "nil"
        debugLog("creatorUpdated creatorKey=%s entries=%s payloadType=%s", tostring(creatorKey), tostring(entryCount), type(payload))
        State.creatorCache = payload
        syncLiftPoints()
    end
end)

-- ============================================================
--  INITIALIZATION & CLEANUP THREADS
-- ============================================================

CreateThread(function()
    if Config and Config.ToggleFeatures and Config.ToggleFeatures.workshopLift == false then
        return
    end

    syncLiftPoints()
    Wait(1000)

    for _, liftPoint in ipairs(State.pointList) do
        recoverFloatingVehicle(liftPoint)
    end
end)

CreateThread(function()
    local existingCfg = Config and Config.WorkshopLiftSystem and Config.WorkshopLiftSystem.existingProps or {}
    if Config and Config.ToggleFeatures and Config.ToggleFeatures.workshopLift == false or existingCfg.enabled ~= true then
        return
    end

    local autoCfg = existingCfg.autoDiscover or {}
    local interval = tonumber(autoCfg.refreshIntervalMs) or 30000

    if interval <= 0 then return end

    while true do
        Wait(interval)
        syncLiftPoints()
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    closeLiftControlUi()

    for _, liftPoint in ipairs(State.pointList) do
        destroyLiftPoint(liftPoint)
    end
end)
