if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/map.lua") end
-- =====================================================
--  sky_jobs_base · source/client/map.lua
--  Deobfuscated & Cleaned
-- =====================================================

local isMapUIActive = false
local activeExclusionZones = {}
local exclusionBlipsMap = {}

local DEFAULT_COLOR = 1
local DEFAULT_ALPHA = 90
local SEGMENT_STEP = 40.0
local RADIUS_STEP = 20.0
local DEFAULT_SPRITE = 161

local activePolygonsBBox = {}

local function removeAllExclusionBlips()
    for _, blipData in pairs(exclusionBlipsMap) do
        if blipData.center then
            RemoveBlip(blipData.center)
        end
        if blipData.outline then
            for _, b in ipairs(blipData.outline) do
                RemoveBlip(b)
            end
        end
    end
    exclusionBlipsMap = {}
end

local function createCenterBlip(zoneData)
    if not (zoneData and zoneData.points and #zoneData.points > 0) then return nil end

    local sumX, sumY = 0.0, 0.0
    for _, pt in ipairs(zoneData.points) do
        sumX = sumX + pt.x
        sumY = sumY + pt.y
    end

    local count = #zoneData.points
    local avgX = sumX / count
    local avgY = sumY / count

    local blip = AddBlipForCoord(avgX, avgY, 0.0)
    SetBlipSprite(blip, DEFAULT_SPRITE)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.75)
    SetBlipColour(blip, DEFAULT_COLOR)
    SetBlipAsShortRange(blip, false)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(zoneData.label or "Exclusion Zone")
    EndTextCommandSetBlipName(blip)

    return blip
end

local function createOutlineBlips(zoneData)
    local blipList = {}
    if not (zoneData and zoneData.points and #zoneData.points >= 2) then
        return blipList
    end

    local maxBlips = 160
    local pts = zoneData.points
    local ptCount = #pts

    for i = 1, ptCount do
        local p1 = pts[i]
        local p2 = pts[(i % ptCount) + 1]

        local dx = p2.x - p1.x
        local dy = p2.y - p1.y
        local dist = math.sqrt((dx * dx) + (dy * dy))
        local steps = math.max(1, math.floor(dist / SEGMENT_STEP))

        for stepIdx = 0, steps do
            if #blipList >= maxBlips then break end

            local t = (steps == 0) and 0.0 or (stepIdx / steps)
            local bx = p1.x + (dx * t)
            local by = p1.y + (dy * t)

            local blip = AddBlipForRadius(bx, by, 0.0, RADIUS_STEP)
            SetBlipColour(blip, DEFAULT_COLOR)
            SetBlipAlpha(blip, DEFAULT_ALPHA)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, false)

            table.insert(blipList, blip)
        end

        if #blipList >= maxBlips then break end
    end

    return blipList
end

local function sendNuiMapMessage(typeKey, data)
    if not isMapUIActive then return end
    SendNUIMessage({
        type = typeKey,
        data = data
    })
end

local function updateOfficersNUI(data) sendNuiMapMessage("map:updateOfficers", data) end
local function updateDispatchesNUI(data) sendNuiMapMessage("map:updateDispatches", data) end
local function updatePanicsNUI(data) sendNuiMapMessage("map:updatePanics", data) end
local function updatePingsNUI(data) sendNuiMapMessage("map:updatePings", data) end
local function updateTrackersNUI(data) sendNuiMapMessage("map:updateTrackers", data) end
local function updateExclusionZonesNUI(data) sendNuiMapMessage("map:updateExclusionZones", data) end

local function announceMapMessage(payload)
    if type(payload) ~= "table" then return end
    SendNUIMessage({
        type = "map:announce",
        data = payload
    })
end

local function getZoneLabel(zoneId)
    if not zoneId then return "Exclusion Zone" end
    local z = activeExclusionZones[zoneId]
    if z and type(z.label) == "string" and z.label ~= "" then
        return z.label
    end
    return "Exclusion Zone"
end

local function processExclusionZonesData(payload)
    local rawZones = payload and payload.zones
    if type(rawZones) ~= "table" then return end

    local newZoneMap = {}
    local nuiList = {}

    for _, zone in ipairs(rawZones) do
        local zId = (zone and zone.id) and tostring(zone.id) or nil
        local pts = zone and zone.points

        if zId and type(pts) == "table" then
            local polyPts = {}
            local nuiPts = {}

            for _, pt in ipairs(pts) do
                if pt and pt.x and pt.y then
                    local px = tonumber(pt.x) or 0.0
                    local py = tonumber(pt.y) or 0.0
                    table.insert(polyPts, vector2(px, py))
                    table.insert(nuiPts, { x = px, y = py })
                end
            end

            if #polyPts >= 3 then
                local zoneName = "exclusion:" .. zId
                Sky.Poly.CreateZone(zoneName, polyPts, "sky_jobs_base:exclusion:enter", "sky_jobs_base:exclusion:exit")

                activePolygonsBBox[zId] = {
                    polygon = polyPts,
                    bbox = Sky.Poly.CalculateBoundingBox(polyPts)
                }

                local label = zone.label or "Exclusion Zone"
                newZoneMap[zId] = { label = label }

                table.insert(nuiList, {
                    id = zId,
                    label = label,
                    points = nuiPts
                })
            end
        end
    end

    for zId in pairs(activeExclusionZones) do
        if not newZoneMap[zId] then
            Sky.Poly.RemoveZone("exclusion:" .. zId)
        end
    end

    for zId in pairs(activePolygonsBBox) do
        if not newZoneMap[zId] then
            activePolygonsBBox[zId] = nil
        end
    end

    activeExclusionZones = newZoneMap

    removeAllExclusionBlips()
    for _, zData in ipairs(nuiList) do
        exclusionBlipsMap[zData.id] = {
            center = createCenterBlip(zData),
            outline = createOutlineBlips(zData)
        }
    end
end

local function isPointInsideAnyExclusionZone(pointVec2)
    if not pointVec2 then return false end

    for _, data in pairs(activePolygonsBBox) do
        if data and data.polygon and #data.polygon >= 3 then
            if data.bbox and Sky.Poly.IsPointInBoundingBox(pointVec2, data.bbox) then
                -- inside bbox
            elseif Sky.Poly.IsPointInZone(pointVec2, data.polygon) then
                return true
            end
        end
    end
    return false
end

local function isEntityInsideExclusionZone(entity)
    if not DoesEntityExist(entity) then return false end
    local coords = GetEntityCoords(entity)
    return isPointInsideAnyExclusionZone(vector2(coords.x, coords.y))
end

local function iterateVehicles(callback)
    local handle, veh = FindFirstVehicle()
    if not handle or handle == 0 then return end

    local success = true
    repeat
        if veh and veh ~= 0 then
            callback(veh)
        end
        success, veh = FindNextVehicle(handle)
    until not success

    EndFindVehicle(handle)
end

local function iteratePeds(callback)
    local handle, ped = FindFirstPed()
    if not handle or handle == 0 then return end

    local success = true
    repeat
        if ped and ped ~= 0 then
            callback(ped)
        end
        success, ped = FindNextPed(handle)
    until not success

    EndFindPed(handle)
end

local function isVehicleOccupiedByPlayer(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    local seatCount = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))

    for i = -1, seatCount - 2 do
        local occupant = GetPedInVehicleSeat(vehicle, i)
        if occupant and occupant ~= 0 and IsPedAPlayer(occupant) then
            return true
        end
    end
    return false
end

local function hasVehicleBeenPlayerUsed(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    return isVehicleOccupiedByPlayer(vehicle) or HasVehicleBeenOwnedByPlayer(vehicle)
end

local function deleteUnusedVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return end
    SetVehicleHasBeenOwnedByPlayer(vehicle, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

local function deleteUnusedPed(ped)
    if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
        Sky.Ped.Delete(ped)
    end
end

CreateThread(function()
    while true do
        Wait(1500)
        if next(activePolygonsBBox) ~= nil then
            iterateVehicles(function(veh)
                if isEntityInsideExclusionZone(veh) and not hasVehicleBeenPlayerUsed(veh) then
                    deleteUnusedVehicle(veh)
                end
            end)

            iteratePeds(function(ped)
                if not IsPedAPlayer(ped) and isEntityInsideExclusionZone(ped) then
                    deleteUnusedPed(ped)
                end
            end)
        end
    end
end)

RegisterNetEvent("sky_jobs_base:map:updateOfficers", function(data)
    if type(data) == "table" then updateOfficersNUI(data) end
end)

RegisterNetEvent("sky_jobs_base:map:updateDispatches", function(data)
    if type(data) == "table" then updateDispatchesNUI(data) end
end)

RegisterNetEvent("sky_jobs_base:map:updatePanics", function(data)
    if type(data) == "table" then updatePanicsNUI(data) end
end)

RegisterNetEvent("sky_jobs_base:map:updatePings", function(data)
    if type(data) == "table" then updatePingsNUI(data) end
end)

RegisterNetEvent("sky_jobs_base:map:updateTrackers", function(data)
    if type(data) == "table" then updateTrackersNUI(data) end
end)

RegisterNetEvent("sky_jobs_base:map:updateExclusionZones", function(data)
    if type(data) == "table" then
        processExclusionZonesData(data)
        updateExclusionZonesNUI(data)
    end
end)

CreateThread(function()
    Wait(1000)
    local res = Sky.Cb.Trigger("sky_jobs_base:map:getExclusionZones") or {}
    if res.success and res.data then
        processExclusionZonesData(res.data)
    end
end)

RegisterNUICallback("map:getOfficers", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:map:getOfficers") or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("map:getDispatches", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:map:getDispatches") or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("map:getPanics", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:map:getPanics") or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("map:getPings", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:map:getPings") or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("map:getHydrants", function(data, cb)
    local hydrants = {}
    if GetResourceState("sky_firejob") == "started" then
        local ok, pts = pcall(function()
            return exports.sky_firejob:getHydrantMapPoints()
        end)
        if ok and type(pts) == "table" then
            hydrants = pts
        end
    end
    cb({
        success = true,
        data = { hydrants = hydrants }
    })
end)

RegisterNUICallback("map:getExclusionZones", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:map:getExclusionZones") or {}
    if res.success and res.data then
        processExclusionZonesData(res.data)
    end
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("map:exclusion:create", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:map:createExclusionZone", data or {}) or {}
    if res.success and res.data then
        processExclusionZonesData(res.data)
    end
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("map:exclusion:delete", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:map:deleteExclusionZone", data or {}) or {}
    if res.success and res.data then
        processExclusionZonesData(res.data)
    end
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("map:monitorZone:get", function(data, cb)
    local res = Sky.Cb.Trigger("sky_policejob:map:getMonitorZones", data or {}) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("map:monitorZone:create", function(data, cb)
    local res = Sky.Cb.Trigger("sky_policejob:map:createMonitorZone", data or {}) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("map:monitorZone:delete", function(data, cb)
    local res = Sky.Cb.Trigger("sky_policejob:map:deleteMonitorZone", data or {}) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

AddEventHandler("sky_jobs_base:exclusion:enter", function(zoneName)
    local zId = zoneName and zoneName:match("^exclusion:(.+)$")
    local label = getZoneLabel(zId)

    announceMapMessage({
        key = "map.zones.announce.entering",
        fallback = "Entering exclusion zone: {label}",
        params = { label = label },
        variant = "warning"
    })
end)

AddEventHandler("sky_jobs_base:exclusion:exit", function(zoneName)
    local zId = zoneName and zoneName:match("^exclusion:(.+)$")
    local label = getZoneLabel(zId)

    announceMapMessage({
        key = "map.zones.announce.leaving",
        fallback = "Leaving exclusion zone: {label}",
        params = { label = label },
        variant = "warning"
    })
end)

RegisterNUICallback("map:dispatch:accept", function(data, cb)
    local coords = data and data.coords
    if coords and coords.x and coords.y then
        SetNewWaypoint(tonumber(coords.x) or 0.0, tonumber(coords.y) or 0.0)
    end

    TriggerServerEvent("sky_jobs_base:dispatch:accept", { id = data and data.id })

    local mapCfg = (Config and Config.Tablet and Config.Tablet.map) or {}
    cb({
        success = true,
        closeTablet = mapCfg.closeOnDispatchAccept ~= false
    })
end)

RegisterNUICallback("map:dispatch:done", function(data, cb)
    TriggerServerEvent("sky_jobs_base:dispatch:done", { id = data and data.id })
    cb({ success = true })
end)

RegisterNUICallback("map:dispatch:delete", function(data, cb)
    TriggerServerEvent("sky_jobs_base:dispatch:delete", { id = data and data.id })
    cb({ success = true })
end)

RegisterNUICallback("map:setWaypoint", function(data, cb)
    local coords = data and data.coords
    if coords and coords.x and coords.y then
        SetNewWaypoint(tonumber(coords.x) or 0.0, tonumber(coords.y) or 0.0)
        cb({ success = true })
        return
    end

    print("[sky_jobs_base] map:setWaypoint failed: missing x/y coords")
    cb({ success = false, error = "missing_coords" })
end)

RegisterNUICallback("map:setActive", function(data, cb)
    isMapUIActive = (data and data.active == true)
    TriggerEvent("sky_jobs_base:map:uiActiveChanged", isMapUIActive)
    cb({ success = true })

    if isMapUIActive then
        TriggerServerEvent("sky_jobs_base:map:refresh")
    end
end)

AddEventHandler("sky_jobs:nuiClosed", function()
    if not isMapUIActive then return end
    isMapUIActive = false
    TriggerEvent("sky_jobs_base:map:uiActiveChanged", false)
end)
