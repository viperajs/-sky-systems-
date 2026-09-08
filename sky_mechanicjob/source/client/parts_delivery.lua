if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/parts_delivery.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_mechanicjob · source/client/parts_delivery.lua
--  Deobfuscated & Cleaned
-- =====================================================

local CREATOR_KEY = "workshopcreator"
local POINT_TYPE = "part_delivery"
local DEFAULT_BOX_MODEL = "prop_cs_cardbox_01"

local State = {}
State.creatorCache = nil
State.deliveries = {}
State.entities = {}
State.entityModels = {}
State.entityServerOwned = {}
State.notifiedDeliveries = {}
State.readyNotificationInitialized = false
State.boxModel = DEFAULT_BOX_MODEL
State.interactionDistance = 2.0
State.openDurationMs = 5500
State.opening = false

local ForkliftMonitor = {}
ForkliftMonitor.monitorActive = false
ForkliftMonitor.deliveryId = 0

local onCreatorUpdated = nil

-- ─── Creator Data Update ───────────────────────────
RegisterNetEvent("sky_jobs_base:creatorUpdated", function(creatorKey, data)
    if creatorKey == CREATOR_KEY then
        State.creatorCache = data
        if onCreatorUpdated then
            onCreatorUpdated()
        end
    end
end)

-- ─── Locale Helper ─────────────────────────────────
local function getLocale(key, fallback)
    local val = tuningLocales[key]
    if type(val) == "string" and val ~= "" then
        return val
    end
    return fallback
end

-- ─── Get Creator Data ──────────────────────────────
local function getCreatorData()
    if type(State.creatorCache) == "table" then
        return State.creatorCache
    end
    local result = Sky.Cb.Trigger("sky_jobs_base:creator:getData", { creatorKey = CREATOR_KEY })
    if type(result) == "table" and result.success == true then
        if type(result.data) == "table" then
            State.creatorCache = result.data
        end
    end
    return State.creatorCache
end

-- ─── Get Item Image Base URL ───────────────────────
local function getItemImageBase()
    local result = Sky.Cb.Trigger("sky_jobs_base:getNuiImageBases")
    if not result then
        result = {}
    end
    local base = result.itemImageBase
    if not base then
        base = "https://cdn.sky-systems.net/items"
    end
    return tostring(base)
end

-- ─── Build Delivery Point Key ──────────────────────
local function buildPointKey(entryId, pointUid, pointType)
    return string.format("%s:%s:%s", tostring(pointType), tostring(entryId), tostring(pointUid))
end

local function isDeliveryPointType(pType)
    if type(pType) ~= "string" then return false end
    local lower = pType:lower()
    return lower == "parts_drop" or lower == "part_delivery" or lower == "parts_delivery"
        or lower == "delivery" or lower == "delivery_bay" or lower == "storage" or lower == "shop"
end

-- ─── Get All Delivery Points From Creator ──────────
local function getAllDeliveryPoints()
    local creatorData = getCreatorData()
    local points = {}

    if type(creatorData) == "table" and type(creatorData.entries) == "table" then
        for _, entry in ipairs(creatorData.entries) do
            if type(entry) == "table" and type(entry.points) == "table" then
                for _, point in ipairs(entry.points) do
                    if type(point) == "table" and isDeliveryPointType(point.type) then
                        if point.x and point.y and point.z then
                            local key = buildPointKey(entry.id, point.uid, point.type)
                            local label = tostring(point.label or entry.label or entry.name or getLocale("PartsDeliveryPointLabel", "Parts Delivery"))
                            local coords = vector3(
                                tonumber(point.x) or 0.0,
                                tonumber(point.y) or 0.0,
                                tonumber(point.z) or 0.0
                            )
                            local heading = tonumber(point.heading) or 0.0
                            points[#points + 1] = {
                                key = key,
                                label = label,
                                coords = coords,
                                heading = heading,
                            }
                        end
                    end
                end
            end
        end
    end

    if #points == 0 and type(creatorData) == "table" and type(creatorData.entries) == "table" then
        for _, entry in ipairs(creatorData.entries) do
            if type(entry) == "table" and type(entry.points) == "table" then
                for _, point in ipairs(entry.points) do
                    if point.x and point.y and point.z then
                        local key = buildPointKey(entry.id, point.uid or "fallback", "parts_drop")
                        local label = tostring(point.label or entry.name or "Workshop Delivery")
                        points[#points + 1] = {
                            key = key,
                            label = label,
                            coords = vector3(tonumber(point.x) or 0.0, tonumber(point.y) or 0.0, tonumber(point.z) or 0.0),
                            heading = tonumber(point.heading) or 0.0
                        }
                        break
                    end
                end
            end
        end
    end

    if #points == 0 then
        local pCoords = GetEntityCoords(PlayerPedId())
        points[#points + 1] = {
            key = "default:fallback:parts_drop",
            label = "Workshop Delivery Bay",
            coords = pCoords,
            heading = GetEntityHeading(PlayerPedId())
        }
    end

    return points
end

-- ─── Find Nearest Delivery Point ───────────────────
local function findNearestDeliveryPoint()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local allPoints = getAllDeliveryPoints()
    local nearest = allPoints[1] or nil
    local nearestDist = nearest and #(playerCoords - nearest.coords) or 0.0

    for _, point in ipairs(allPoints) do
        local dist = #(playerCoords - point.coords)
        if dist < nearestDist then
            nearest = point
            nearestDist = dist
        end
    end
    return nearest, nearestDist
end

-- ─── Get Delivery Points As Lookup ─────────────────
local function getDeliveryPointLookup()
    local lookup = {}
    for _, point in ipairs(getAllDeliveryPoints()) do
        lookup[point.key] = point
    end
    return lookup
end

-- ─── Delete Entity By Delivery ID ──────────────────
local function deleteDeliveryEntity(deliveryId)
    local entity = State.entities[deliveryId]
    if entity and entity ~= 0 then
        if DoesEntityExist(entity) then
            if State.entityServerOwned[deliveryId] ~= true then
                DeleteEntity(entity)
            end
        end
    end
    State.entities[deliveryId] = nil
    State.entityModels[deliveryId] = nil
    State.entityServerOwned[deliveryId] = nil
end

-- ─── Cleanup Orphaned Entities ─────────────────────
local function cleanupOrphanedEntities(activeIds)
    for deliveryId in pairs(State.entities) do
        if activeIds[deliveryId] ~= true then
            deleteDeliveryEntity(deliveryId)
        end
    end
end

-- ─── Get Box Model Name ────────────────────────────
local function getBoxModel()
    return tostring(State.boxModel or DEFAULT_BOX_MODEL)
end

-- ─── Get Delivery Pallet Config ────────────────────
local function getDeliveryPalletConfig()
    local carryItems = Config.CarryItems or {}
    local palletCfg = carryItems.deliveryPallet or {}
    local features = Config.ToggleFeatures.carryItems

    if features == true then
        if type(palletCfg) == "table" and palletCfg.enabled ~= false then
            return palletCfg
        end
    end
    return nil
end

-- ─── Is Entity a Forklift ──────────────────────────
local function isForklift(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return false
    end

    local forkliftModels = (Config.CarryItems or {}).forkliftModels
    if not forkliftModels then
        forkliftModels = { "forklift" }
    end

    local vehicleModel = GetEntityModel(vehicle)
    for _, modelName in ipairs(forkliftModels) do
        local hash = GetHashKey(tostring(modelName or ""))
        if hash == vehicleModel then
            return true
        end
    end
    return false
end

-- ─── Check If Entity Is On Fork ────────────────────
local function isOnFork(entity, vehicle)
    if entity == 0 or vehicle == 0 or not DoesEntityExist(entity) or not DoesEntityExist(vehicle) then
        return false
    end

    local palletCfg = getDeliveryPalletConfig()
    if not palletCfg then
        return false
    end

    local forkCheck = palletCfg.forkCheck
    if type(forkCheck) ~= "table" then
        forkCheck = {}
    end

    local entityCoords = GetEntityCoords(entity)
    local refY = tonumber(forkCheck.referenceY) or 1.25
    local refZ = tonumber(forkCheck.referenceZ) or -0.25
    local forkRefPoint = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, refY, refZ)

    local dist = #(entityCoords - forkRefPoint)
    local maxDist = tonumber(forkCheck.distance) or 1.45
    if dist > maxDist then
        return false
    end

    local localOffset = GetOffsetFromEntityGivenWorldCoords(vehicle, entityCoords.x, entityCoords.y, entityCoords.z)
    local minY = tonumber(forkCheck.minY) or 0.35
    return localOffset.y >= minY
end

-- ─── Hide Delivery Note NUI ────────────────────────
local function hideDeliveryNote()
    if ForkliftMonitor.deliveryId == 0 then
        return
    end
    ForkliftMonitor.deliveryId = 0
    SendNUIMessage({ action = "deliveryNote:hide", payload = {} })
end

-- ─── Build Delivery Note Payload ───────────────────
local function buildDeliveryNotePayload(delivery)
    local items = {}
    local totalCount = 0

    for _, item in ipairs(delivery.items or {}) do
        local qty = math.floor(math.max(0, tonumber(item.quantity) or tonumber(item.amount) or 0))
        local name = tostring(item.name or "")
        if name ~= "" and qty > 0 then
            items[#items + 1] = {
                name = name,
                label = tostring(item.label or name),
                quantity = qty,
            }
            totalCount = totalCount + qty
        end
    end

    return {
        deliveryId = tonumber(delivery.id) or 0,
        orderUid = tostring(delivery.orderUid or ""),
        deliveryLabel = tostring(delivery.deliveryLabel or getLocale("PartsDeliveryPointLabel", "Parts Delivery")),
        totalItems = totalCount,
        items = items,
    }
end

-- ─── Show Delivery Note NUI ────────────────────────
local function showDeliveryNote(delivery)
    local deliveryId = tonumber(delivery and delivery.id) or 0
    if deliveryId <= 0 then
        hideDeliveryNote()
        return
    end
    if ForkliftMonitor.deliveryId == deliveryId then
        return
    end
    ForkliftMonitor.deliveryId = deliveryId
    SendNUIMessage({
        action = "deliveryNote:show",
        payload = buildDeliveryNotePayload(delivery),
    })
end

-- ─── Find Nearest Delivery On Fork ─────────────────
local function findNearestDeliveryOnFork(vehicle)
    local nearest = nil
    local nearestDist = math.huge
    local vehicleCoords = GetEntityCoords(vehicle)

    for _, delivery in ipairs(State.deliveries) do
        local deliveryId = tonumber(delivery.id) or 0
        local entity = State.entities[deliveryId]
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            if isOnFork(entity, vehicle) then
                local dist = #(GetEntityCoords(entity) - vehicleCoords)
                if dist < nearestDist then
                    nearest = delivery
                    nearestDist = dist
                end
            end
        end
    end
    return nearest
end

-- ─── Forklift Monitor Thread ───────────────────────
local function startForkliftMonitor(vehicle)
    if ForkliftMonitor.monitorActive then
        return
    end
    ForkliftMonitor.monitorActive = true

    CreateThread(function()
        while true do
            local palletCfg = getDeliveryPalletConfig()
            local ped = PlayerPedId()

            if not palletCfg then break end
            if vehicle == 0 or not DoesEntityExist(vehicle) then break end
            if GetVehiclePedIsIn(ped, false) ~= vehicle then break end
            if GetPedInVehicleSeat(vehicle, -1) ~= ped then break end
            if not isForklift(vehicle) then break end
            if not (Sky_Jobs and Sky_Jobs.Access and Sky_Jobs.Access.IsOnDuty and Sky_Jobs.Access.IsOnDuty()) then break end

            local delivery = findNearestDeliveryOnFork(vehicle)
            if delivery then
                showDeliveryNote(delivery)
            else
                hideDeliveryNote()
            end

            local interval = math.max(250, math.floor(tonumber(palletCfg.checkIntervalMs) or 450))
            Wait(interval)
        end

        hideDeliveryNote()
        ForkliftMonitor.monitorActive = false
    end)
end

-- ─── Resolve Delivery Coords From Point Map ────────
local function resolveDeliveryCoords(delivery, pointLookup)
    if pointLookup then
        local pointKey = tostring(delivery.deliveryPointKey or "")
        local point = pointLookup[pointKey]
        if point then
            return point.coords, point.heading
        end
    end

    local rawCoords = delivery.coords or {}
    local coords = vector3(
        tonumber(rawCoords.x) or 0.0,
        tonumber(rawCoords.y) or 0.0,
        tonumber(rawCoords.z) or 0.0
    )
    local heading = tonumber(delivery.heading) or 0.0
    return coords, heading
end

-- ─── Place Entity At Position ──────────────────────
local function placeEntityAt(entity, coords, heading)
    SetEntityHeading(entity, heading)
    SetEntityCoordsNoOffset(entity, coords.x, coords.y, coords.z, false, false, false)
    PlaceObjectOnGroundProperly(entity)

    if getDeliveryPalletConfig() then
        SetEntityDynamic(entity, true)
        ActivatePhysics(entity)
        FreezeEntityPosition(entity, false)
    else
        FreezeEntityPosition(entity, true)
    end
end

-- ─── Clean Duplicate Objects Near Location ─────────
local function cleanDuplicatesNearLocation(modelName, coords, excludeEntity)
    local palletCfg = getDeliveryPalletConfig()
    if not palletCfg then return end

    local modelHash = GetHashKey(modelName)
    local cleanupDist = tonumber(palletCfg.duplicateCleanupDistance) or 2.25

    for _, obj in ipairs(GetGamePool("CObject")) do
        if obj ~= excludeEntity and DoesEntityExist(obj) then
            if GetEntityModel(obj) == modelHash then
                local dist = #(GetEntityCoords(obj) - coords)
                if dist <= cleanupDist then
                    DeleteEntity(obj)
                end
            end
        end
    end
end

-- ─── Spawn / Update Delivery Entity ────────────────
local function spawnOrUpdateDeliveryEntity(delivery, amount, pointLookup)
    local deliveryId = tonumber(delivery.id) or 0
    if deliveryId <= 0 then return end

    local existingEntity = State.entities[deliveryId]
    local modelName = getBoxModel()
    local coords, heading = resolveDeliveryCoords(delivery, pointLookup)

    -- Handle existing entity
    if existingEntity and existingEntity ~= 0 and DoesEntityExist(existingEntity) then
        if getDeliveryPalletConfig() then
            if State.entityServerOwned[deliveryId] ~= true then
                deleteDeliveryEntity(deliveryId)
                existingEntity = 0
            end
        else
            if State.entityModels[deliveryId] ~= modelName then
                deleteDeliveryEntity(deliveryId)
            else
                return -- Same model, no update needed
            end
        end
    end

    -- Re-check after potential delete
    if existingEntity and existingEntity ~= 0 and DoesEntityExist(existingEntity) then
        return
    end

    -- Handle server-owned entity (pallet mode)
    local netId = 0
    if getDeliveryPalletConfig() then
        netId = tonumber(delivery.entityNetId) or 0
    end

    if getDeliveryPalletConfig() then
        if netId <= 0 or not NetworkDoesNetworkIdExist(netId) then
            cleanDuplicatesNearLocation(modelName, coords, 0)
            return
        end

        local serverEntity = NetToObj(netId)
        if serverEntity ~= 0 and DoesEntityExist(serverEntity) then
            cleanDuplicatesNearLocation(modelName, coords, serverEntity)
            SetEntityAsMissionEntity(serverEntity, true, false)
            SetEntityCanBeDamaged(serverEntity, false)
            placeEntityAt(serverEntity, coords, heading)
            NetworkUseHighPrecisionBlending(netId, true)
            NetworkSetObjectForceStaticBlend(serverEntity, false)
            State.entities[deliveryId] = serverEntity
            State.entityModels[deliveryId] = modelName
            State.entityServerOwned[deliveryId] = true
        end
        return
    end

    -- Non-pallet: check if model changed
    existingEntity = State.entities[deliveryId]
    if existingEntity and existingEntity ~= 0 and DoesEntityExist(existingEntity) then
        if State.entityModels[deliveryId] ~= modelName then
            deleteDeliveryEntity(deliveryId)
        else
            return
        end
    end

    -- Double-check after cleanup
    existingEntity = State.entities[deliveryId]
    if existingEntity and existingEntity ~= 0 and DoesEntityExist(existingEntity) then
        return
    end

    -- Spawn new object
    local modelHash = GetHashKey(modelName)
    if not IsModelValid(modelHash) then
        print(string.format("[sky_mechanicjob][parts_delivery] spawn failed: invalid model '%s'", modelName))
        return
    end

    Sky.Load.Model(modelHash)
    local obj = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)

    if obj == 0 or not DoesEntityExist(obj) then
        print(string.format("[sky_mechanicjob][parts_delivery] spawn failed: object creation failed for delivery %s", deliveryId))
        return
    end

    SetEntityAsMissionEntity(obj, true, true)
    SetEntityCanBeDamaged(obj, false)
    placeEntityAt(obj, coords, heading)

    local objNetId = ObjToNet(obj)
    if objNetId ~= 0 then
        SetNetworkIdExistsOnAllMachines(objNetId, true)
        NetworkSetNetworkIdDynamic(objNetId, getDeliveryPalletConfig() ~= nil)
        SetNetworkIdCanMigrate(objNetId, false)
        if getDeliveryPalletConfig() then
            NetworkUseHighPrecisionBlending(objNetId, true)
            NetworkSetObjectForceStaticBlend(obj, false)
        end
    end

    SetModelAsNoLongerNeeded(modelHash)
    State.entities[deliveryId] = obj
    State.entityModels[deliveryId] = modelName
    State.entityServerOwned[deliveryId] = false
end

-- ─── Refresh All Delivery Entities ─────────────────
local function refreshDeliveryEntities()
    local groupedByPoint = {}
    local activeIds = {}
    local spawnQueue = {}
    local pointLookup = getDeliveryPointLookup()

    -- Group deliveries by delivery point key
    for _, delivery in ipairs(State.deliveries) do
        local pointKey = tostring(delivery.deliveryPointKey or "default")
        if not groupedByPoint[pointKey] then
            groupedByPoint[pointKey] = {}
        end
        groupedByPoint[pointKey][#groupedByPoint[pointKey] + 1] = delivery
    end

    -- Sort each group and pick the first (oldest) delivery
    for _, group in pairs(groupedByPoint) do
        table.sort(group, function(a, b)
            return (tonumber(a.id) or 0) < (tonumber(b.id) or 0)
        end)
        local first = group[1]
        if first then
            local id = tonumber(first.id) or 0
            activeIds[id] = true
            spawnQueue[#spawnQueue + 1] = { delivery = first, amount = #group }
        end
    end

    cleanupOrphanedEntities(activeIds)

    for _, entry in ipairs(spawnQueue) do
        spawnOrUpdateDeliveryEntity(entry.delivery, entry.amount, pointLookup)
    end
end

-- Set the creator update callback
onCreatorUpdated = refreshDeliveryEntities

-- ─── Notify New Deliveries ─────────────────────────
local function notifyNewDeliveries(deliveries)
    local newDeliveries = {}
    for _, delivery in ipairs(deliveries or {}) do
        local id = tonumber(delivery.id) or 0
        if id > 0 and State.notifiedDeliveries[id] ~= true then
            State.notifiedDeliveries[id] = true
            newDeliveries[#newDeliveries + 1] = delivery
        end
    end

    if State.readyNotificationInitialized ~= true then
        State.readyNotificationInitialized = true
        return
    end

    if #newDeliveries == 0 then return end

    local first = newDeliveries[1] or {}
    local count = #newDeliveries
    local orderUid = tostring(first.orderUid or "")

    local body
    if count > 1 then
        body = getNuiLocale("tablet.partsShop.deliveryReadyBodyMultiple", "{count} parts deliveries are ready at the delivery bay.")
        body = body:gsub("{count}", tostring(count))
    else
        body = getNuiLocale("tablet.partsShop.deliveryReadyBody", "Order {orderUid} is ready at the delivery bay.")
        body = body:gsub("{orderUid}", (orderUid ~= "" and orderUid) or "-")
    end

    local pushId
    if count > 1 then
        pushId = string.format("push-parts-delivery-%s", tostring(GetGameTimer()))
    else
        pushId = string.format("push-parts-delivery-%s", tostring(first.id or GetGameTimer()))
    end

    if Sky_Jobs and Sky_Jobs.Tablet and Sky_Jobs.Tablet.PushNotification then
        Sky_Jobs.Tablet.PushNotification({
            id = pushId,
            appKey = "mechanic_parts_shop",
            app = getNuiLocale("tablet.partsShop.title", "Dynasty Auto Supply"),
            icon = "PackageCheck",
            title = getNuiLocale("tablet.partsShop.deliveryReadyTitle", "Parts delivered"),
            body = body,
            time = getNuiLocale("common.time.now", "Now"),
            tone = "tone-amber",
            route = "/tablet/mechanic-parts-shop/basket",
        })
    end
end

-- ─── Fetch Ready Deliveries From Server ────────────
local function fetchReadyDeliveries()
    local result = Sky.Cb.Trigger("sky_mechanicjob:partsDelivery:getReadyDeliveries", { pageSize = 100 })
    if type(result) ~= "table" or result.success ~= true then
        return
    end

    local data = result.data or {}
    local deliveries = (type(data.deliveries) == "table" and data.deliveries) or {}

    State.deliveries = deliveries
    notifyNewDeliveries(State.deliveries)
    State.boxModel = tostring(data.boxModel or DEFAULT_BOX_MODEL)
    State.interactionDistance = tonumber(data.interactionDistance) or 2.0
    State.openDurationMs = math.max(1000, math.floor(tonumber(data.openDurationMs) or 5500))
    refreshDeliveryEntities()
end

-- ─── Find Nearest Delivery Entity (Walk-up) ────────
local function findNearestDeliveryEntity()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearest = nil
    local maxDist = (State.interactionDistance or 2.0) + 0.001

    for _, delivery in ipairs(State.deliveries) do
        local deliveryId = tonumber(delivery.id) or 0
        local entity = State.entities[deliveryId]
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            local dist = #(playerCoords - GetEntityCoords(entity))
            if dist <= maxDist then
                nearest = delivery
                maxDist = dist
            end
        end
    end
    return nearest, maxDist
end

-- ─── Find Displaced Delivery (Pallet Mode) ────────
local function findDisplacedDelivery()
    local palletCfg = getDeliveryPalletConfig()
    if not palletCfg then return nil end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local interactionDist = State.interactionDistance or 2.0
    local nearest = nil
    local nearestDist = interactionDist + 0.001

    for _, delivery in ipairs(State.deliveries) do
        local deliveryId = tonumber(delivery.id) or 0
        local entity = State.entities[deliveryId]
        local rawCoords = delivery.coords or {}

        if entity and entity ~= 0 and DoesEntityExist(entity) then
            if rawCoords.x and rawCoords.y and rawCoords.z then
                local entityCoords = GetEntityCoords(entity)
                local originalPos = vector3(
                    tonumber(rawCoords.x) or 0.0,
                    tonumber(rawCoords.y) or 0.0,
                    tonumber(rawCoords.z) or 0.0
                )
                local playerDist = #(playerCoords - entityCoords)
                local displaceDist = #(entityCoords - originalPos)

                if displaceDist > interactionDist and playerDist <= nearestDist then
                    nearest = delivery
                    nearestDist = playerDist
                end
            end
        end
    end
    return nearest, nearestDist
end

-- ─── Extract Coords From Interaction Data ──────────
local function extractCoordsFromInteraction(interactionData)
    if type(interactionData) ~= "table" then return nil end

    local coords = interactionData.coords
    if type(coords) == "table" and coords.x and coords.y and coords.z then
        return vector3(
            tonumber(coords.x) or 0.0,
            tonumber(coords.y) or 0.0,
            tonumber(coords.z) or 0.0
        )
    end

    local point = interactionData.point
    if type(point) == "table" and point.x and point.y and point.z then
        return vector3(
            tonumber(point.x) or 0.0,
            tonumber(point.y) or 0.0,
            tonumber(point.z) or 0.0
        )
    end
    return nil
end

-- ─── Extract Point Key From Interaction Data ───────
local function extractPointKey(interactionData)
    if type(interactionData) ~= "table" then return nil end

    local entryId = interactionData.entryId
    local pointUid = interactionData.pointUid or interactionData.uid or interactionData.interactionId or interactionData.id
    local pointType = interactionData.pointType or POINT_TYPE

    if entryId and pointUid then
        return buildPointKey(entryId, pointUid, pointType)
    end
    return nil
end

-- ─── Find Delivery Near Interaction Point ──────────
local function findDeliveryNearInteraction(interactionData)
    local pointKey = extractPointKey(interactionData)
    if pointKey then
        for _, delivery in ipairs(State.deliveries) do
            local deliveryPointKey = tostring(delivery.deliveryPointKey or "")
            if deliveryPointKey == pointKey then
                local deliveryId = tonumber(delivery.id) or 0
                local entity = State.entities[deliveryId]
                if entity and entity ~= 0 and DoesEntityExist(entity) then
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local entityCoords = GetEntityCoords(entity)
                    local dist = #(playerCoords - entityCoords)
                    local maxDist = (State.interactionDistance or 2.0) + 0.001
                    if dist <= maxDist then
                        return delivery, dist
                    end
                end
            end
        end
    end

    -- Fallback: find by coordinates
    local interactionCoords = extractCoordsFromInteraction(interactionData)
    if not interactionCoords then
        return findNearestDeliveryEntity()
    end

    local nearest = nil
    local maxDist = (State.interactionDistance or 2.0) + 0.001

    for _, delivery in ipairs(State.deliveries) do
        local deliveryId = tonumber(delivery.id) or 0
        local entity = State.entities[deliveryId]
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            local dist = #(interactionCoords - GetEntityCoords(entity))
            if dist <= maxDist then
                nearest = delivery
                maxDist = dist
            end
        end
    end
    return nearest, maxDist
end

-- ─── Find Nearest Delivery For Storage (Pallet) ───
local function findNearestDeliveryForStorage()
    local palletCfg = getDeliveryPalletConfig()
    if not palletCfg then return nil end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local storeDist = tonumber(palletCfg.storeDistance)
    if not storeDist then
        storeDist = tonumber((Config.CarryItems or {}).storageDistance) or 3.5
    end

    local nearest = nil
    local nearestDist = storeDist + 0.001

    for _, delivery in ipairs(State.deliveries) do
        local deliveryId = tonumber(delivery.id) or 0
        local entity = State.entities[deliveryId]
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            local dist = #(playerCoords - GetEntityCoords(entity))
            if dist <= nearestDist then
                nearest = delivery
                nearestDist = dist
            end
        end
    end
    return nearest, nearestDist
end

-- ─── Can Player Interact With Delivery ─────────────
local function canInteractWithDelivery()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        return false
    end

    -- Check if player is holding a carry item
    local heldItem = OrderInstallState and OrderInstallState.heldCarryItem or nil
    return type(heldItem) ~= "table"
end

-- ─── Open / Claim Delivery ─────────────────────────
local function openDelivery(delivery)
    if State.opening or not canInteractWithDelivery() then
        return
    end

    State.opening = true
    local ped = PlayerPedId()

    -- Play opening animation
    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
    Wait(State.openDurationMs)
    ClearPedTasks(ped)

    if not canInteractWithDelivery() then
        State.opening = false
        return
    end

    -- Claim from server
    local result = Sky.Cb.Trigger("sky_mechanicjob:partsDelivery:claim", {
        deliveryId = tonumber(delivery.id) or 0,
    })

    if type(result) == "table" and result.success == true then
        local data = result.data or {}

        -- Try to hold carry item if available
        if type(data.carryItem) == "table" then
            local held = holdCarryItemProp(data.carryItem.name, data.carryItem.metadata)
            if held ~= true then
                Sky.Cb.Trigger("sky_mechanicjob:carryItem:drop", {})
            end
        end

        Sky.Show.Notification(
            getLocale("PartsDeliveryTitle", "Parts Delivery"),
            getLocale("PartsDeliveryClaimed", "Delivery unpacked."),
            "success"
        )

        if data.deliveryClaimed == true then
            deleteDeliveryEntity(tonumber(delivery.id) or 0)
        end
        fetchReadyDeliveries()
    else
        local errorCode = (type(result) == "table" and result.error) or "failed"
        local errorMsg = getLocale("PartsDeliveryClaimFailed", "Failed to unpack this delivery.")

        if errorCode == "not_on_duty" then
            errorMsg = getLocale("PartsDeliveryNotOnDuty", "You must be on duty to open deliveries.")
        elseif errorCode == "inventory_full" then
            errorMsg = getLocale("PartsDeliveryInventoryFull", "You cannot carry all items from this delivery.")
        end

        Sky.Show.Notification(
            getLocale("PartsDeliveryTitle", "Parts Delivery"),
            errorMsg,
            "error"
        )
    end

    State.opening = false
end

-- ─── Export: Deposit Carry Item To Storage ──────────
registerExport("TryDepositCarryItemToStorage", function(stationId)
    -- Check if player is holding a carry item
    local heldItem = OrderInstallState and OrderInstallState.heldCarryItem or nil

    if type(heldItem) == "table" then
        local itemName = tostring(heldItem.name or "")
        if itemName ~= "" then
            -- Check if transport vehicle is required
            if type(isCarryItemTransportNearCoords) == "function" then
                local nearTransport = isCarryItemTransportNearCoords(heldItem.name, GetEntityCoords(PlayerPedId()))
                if not nearTransport then
                    local transportMode = "hand"
                    if type(getCarryItemTransportMode) == "function" then
                        transportMode = getCarryItemTransportMode(heldItem.name) or "hand"
                    end

                    local msg = getLocale("CarryItemTransportRequired", "Bring the part transport closer to storage.")
                    if transportMode == "forklift" then
                        msg = getLocale("CarryItemForkliftRequired", "Bring the loaded forklift closer to storage.")
                    end

                    Sky.Show.Notification(
                        getLocale("PartsDeliveryTitle", "Parts Delivery"),
                        msg,
                        "error"
                    )
                    return true
                end
            end

            -- Deposit carry item
            local depositResult = Sky.Cb.Trigger("sky_mechanicjob:carryItem:depositToStorage", {
                stationId = tostring(stationId or ""),
                name = heldItem.name,
                metadata = heldItem.metadata,
            }) or {}

            if type(depositResult) == "table" and depositResult.success == true then
                releaseOrderHeldProp()
                Sky.Show.Notification(
                    getLocale("PartsDeliveryTitle", "Parts Delivery"),
                    getLocale("CarryItemStored", "Part placed in workshop storage."),
                    "success"
                )
                return true
            end

            Sky.Show.Notification(
                getLocale("PartsDeliveryTitle", "Parts Delivery"),
                getLocale("CarryItemStoreFailed", "Unable to place this part in storage."),
                "error"
            )
            return true
        end
    end

    -- Fallback: deposit whole delivery pallet
    local nearestDelivery = findNearestDeliveryForStorage()
    if not nearestDelivery then
        return false
    end

    local result = Sky.Cb.Trigger("sky_mechanicjob:partsDelivery:depositToStorage", {
        stationId = tostring(stationId or ""),
        deliveryId = tonumber(nearestDelivery.id) or 0,
    }) or {}

    if type(result) == "table" and result.success == true then
        deleteDeliveryEntity(tonumber(nearestDelivery.id) or 0)
        fetchReadyDeliveries()
        Sky.Show.Notification(
            getLocale("PartsDeliveryTitle", "Parts Delivery"),
            getLocale("CarryDeliveryStored", "Delivery placed in workshop storage."),
            "success"
        )
        return true
    end

    Sky.Show.Notification(
        getLocale("PartsDeliveryTitle", "Parts Delivery"),
        getLocale("CarryDeliveryStoreFailed", "Unable to place this delivery in storage."),
        "error"
    )
    return true
end)

-- ─── Net Event: Hold Carry Item ────────────────────
RegisterNetEvent("sky_mechanicjob:carryItem:hold", function(data)
    if type(data) ~= "table" then return end
    local held = holdCarryItemProp(data.name, data.metadata)
    if held ~= true then
        Sky.Cb.Trigger("sky_mechanicjob:carryItem:drop", {})
    end
end)

-- ─── NUI Callback: Get Parts Shop Config ───────────
RegisterNUICallback("partsShop:getConfig", function(payload, cb)
    local result = Sky.Cb.Trigger("sky_mechanicjob:partsDelivery:getCatalog", {}) or {}

    local nearestPoint, nearestDist = findNearestDeliveryPoint()

    if type(result) == "table" and result.success == true then
        local data = result.data or {}
        result.data = data
        data.itemImageBase = getItemImageBase()

        if nearestPoint then
            data.deliveryPoint = {
                key = nearestPoint.key,
                label = nearestPoint.label,
                coords = {
                    x = nearestPoint.coords.x,
                    y = nearestPoint.coords.y,
                    z = nearestPoint.coords.z,
                },
                heading = nearestPoint.heading,
                distance = nearestDist,
            }
        else
            data.deliveryPoint = nil
        end
    end

    cb(result)
end)

-- ─── NUI Callback: Place Order ─────────────────────
RegisterNUICallback("partsShop:placeOrder", function(payload, cb)
    local deliveryPointKey = tostring(payload and payload.deliveryPointKey or "")
    local allPoints = getAllDeliveryPoints()
    local matchedPoint = nil

    for _, point in ipairs(allPoints) do
        if point.key == deliveryPointKey then
            matchedPoint = point
            break
        end
    end

    if not matchedPoint then
        matchedPoint = allPoints[1]
    end

    if not matchedPoint then
        cb({ success = false, error = "missing_delivery_location" })
        return
    end

    local result = Sky.Cb.Trigger("sky_mechanicjob:partsDelivery:createOrder", {
        items = (payload and payload.items) or {},
        paymentMethod = (payload and payload.paymentMethod) or "own_card",
        deliveryPoint = {
            key = matchedPoint.key,
            label = matchedPoint.label,
            coords = {
                x = matchedPoint.coords.x,
                y = matchedPoint.coords.y,
                z = matchedPoint.coords.z,
            },
            heading = matchedPoint.heading,
        },
    }) or {}

    if type(result) == "table" and result.success == true then
        fetchReadyDeliveries()
    end

    cb(result)
end)

-- ─── NUI Callback: Get Order History ───────────────
RegisterNUICallback("partsShop:getOrderHistory", function(payload, cb)
    local pageSize = math.max(1, math.min(100, math.floor(tonumber(payload and payload.pageSize) or 50)))
    local result = Sky.Cb.Trigger("sky_mechanicjob:partsDelivery:getOrderHistory", {
        pageSize = pageSize,
    }) or {}
    cb(result)
end)

-- ─── Net Event: Deliveries Changed ─────────────────
RegisterNetEvent("sky_mechanicjob:partsDelivery:readyDeliveriesChanged", function()
    fetchReadyDeliveries()
end)

-- ─── Initial Fetch ─────────────────────────────────
CreateThread(function()
    fetchReadyDeliveries()
end)

local function findNearestReadyDelivery()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearest = nil
    local nearestDist = 3.5

    for _, delivery in ipairs(State.deliveries) do
        local deliveryId = tonumber(delivery.id) or 0
        local entity = State.entities[deliveryId]
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            local dist = #(playerCoords - GetEntityCoords(entity))
            if dist <= nearestDist then
                nearest = delivery
                nearestDist = dist
            end
        else
            local rawCoords = delivery.coords or (delivery.point and delivery.point.coords)
            if rawCoords and rawCoords.x then
                local coords = vector3(tonumber(rawCoords.x) or 0.0, tonumber(rawCoords.y) or 0.0, tonumber(rawCoords.z) or 0.0)
                local dist = #(playerCoords - coords)
                if dist <= nearestDist then
                    nearest = delivery
                    nearestDist = dist
                end
            end
        end
    end

    return nearest
end

-- ─── Main Interaction Loop ─────────────────────────
CreateThread(function()
    while true do
        local sleepMs = 500

        if not State.opening and canInteractWithDelivery() then
            local delivery = findNearestReadyDelivery()
            if delivery then
                sleepMs = 0
                Sky.Show.HelpNotification(
                    getLocale("PartsDeliveryOpenHelp", "Open parts delivery"),
                    "E"
                )
                if IsControlJustPressed(0, 38) then
                    openDelivery(delivery)
                end
            end
        end

        Wait(sleepMs)
    end
end)

RegisterCommand("claimdelivery", function()
    fetchReadyDeliveries()
    local delivery = findNearestReadyDelivery()
    if not delivery and #State.deliveries > 0 then
        delivery = State.deliveries[1]
    end
    if delivery then
        openDelivery(delivery)
    else
        Sky.Show.Notification("Parts Delivery", "No ready deliveries found to claim.", "error")
    end
end, false)

-- ─── Register Interaction Events Per Job ───────────
local registeredJobs = {}

local function registerJobInteraction(jobName)
    if type(jobName) ~= "string" or jobName == "" then return end
    if registeredJobs[jobName] then return end
    registeredJobs[jobName] = true

    local eventName = string.format("sky_jobs_base:interaction:%s:parts_drop", jobName)
    RegisterNetEvent(eventName, function(interactionData)
        if State.opening or not canInteractWithDelivery() then
            return
        end

        fetchReadyDeliveries()

        local delivery = findDeliveryNearInteraction(interactionData)
        if delivery then
            openDelivery(delivery)
            return
        end

        Sky.Show.Notification(
            getLocale("PartsDeliveryTitle", "Parts Delivery"),
            getLocale("PartsDeliveryNoneReady", "No parts delivery is ready here."),
            "error"
        )
    end)
end

-- Register for default "mechanic" job
registerJobInteraction("mechanic")

-- Register for all configured jobs
for _, job in ipairs(Config.Jobs or {}) do
    registerJobInteraction(job and job.name)
end

-- Re-register when job config updates
AddEventHandler("sky_mechanicjob:jobConfigurator:updated", function()
    for _, job in ipairs(Config.Jobs or {}) do
        registerJobInteraction(job and job.name)
    end
end)

-- ─── Game Event: Vehicle Enter/Exit ────────────────
AddEventHandler("gameEventTriggered", function(eventName, eventData)
    if eventName == "CEventNetworkPlayerEnteredVehicle" then
        local vehicle = (eventData and eventData[2]) or GetVehiclePedIsIn(PlayerPedId(), false)
        local ped = PlayerPedId()

        if vehicle == 0 or not DoesEntityExist(vehicle) then return end
        if GetPedInVehicleSeat(vehicle, -1) ~= ped then return end

        if getDeliveryPalletConfig() and isForklift(vehicle) and (Sky_Jobs and Sky_Jobs.Access and Sky_Jobs.Access.IsOnDuty and Sky_Jobs.Access.IsOnDuty()) then
            startForkliftMonitor(vehicle)
        end
        return
    end

    if eventName == "CEventNetworkPlayerExitedVehicle" then
        hideDeliveryNote()
    end
end)

-- ─── Resource Stop Cleanup ─────────────────────────
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    hideDeliveryNote()
    for deliveryId in pairs(State.entities) do
        deleteDeliveryEntity(deliveryId)
    end
end)
