if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/modules/Poly.lua") end
-- =====================================================
--  sky_base · source/client/modules/Poly.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Poly = {}

local zones = {}

-- Polygon zone monitoring loop
CreateThread(function()
    local interval = 2000
    while true do
        Wait(interval)
        local pedCoords = GetEntityCoords(PlayerPedId())
        local playerPos = vector2(pedCoords.x, pedCoords.y)
        local anyInside = false

        for name, zone in pairs(zones) do
            local inBox = Sky.Poly.IsPointInBoundingBox(playerPos, zone.bbox)
            local inPoly = false

            if inBox then
                inPoly = Sky.Poly.IsPointInZone(playerPos, zone.polygon)
            end

            if inPoly then
                if not zone.isInside then
                    zone.isInside = true
                    TriggerEvent(zone.onEnterEvent, name, zone)
                end
                anyInside = true
            else
                if zone.isInside then
                    zone.isInside = false
                    TriggerEvent(zone.onExitEvent, name, zone)
                end
            end
        end

        interval = anyInside and 500 or 3000
    end
end)

--- Creates a new polygon zone.
---@param name string
---@param polygon table
---@param onEnterEvent string
---@param onExitEvent string
function Sky.Poly.CreateZone(name, polygon, onEnterEvent, onExitEvent)
    zones[name] = {
        name = name,
        polygon = polygon,
        onEnterEvent = onEnterEvent,
        onExitEvent = onExitEvent,
        isInside = false,
        bbox = Sky.Poly.CalculateBoundingBox(polygon)
    }
end

--- Removes a polygon zone by name.
---@param name string
function Sky.Poly.RemoveZone(name)
    zones[name] = nil
end

--- Checks if a 2D point lies within an axis-aligned bounding box.
---@param point vector2
---@param bbox table
---@return boolean
function Sky.Poly.IsPointInBoundingBox(point, bbox)
    return point.x >= bbox.minX and point.x <= bbox.maxX and point.y >= bbox.minY and point.y <= bbox.maxY
end

--- Calculates min/max X and Y bounding box for a polygon.
---@param polygon table
---@return table
function Sky.Poly.CalculateBoundingBox(polygon)
    local minX = polygon[1].x
    local maxX = polygon[1].x
    local minY = polygon[1].y
    local maxY = polygon[1].y

    for _, pt in ipairs(polygon) do
        minX = math.min(minX, pt.x)
        maxX = math.max(maxX, pt.x)
        minY = math.min(minY, pt.y)
        maxY = math.max(maxY, pt.y)
    end

    return {
        minX = minX,
        maxX = maxX,
        minY = minY,
        maxY = maxY
    }
end

--- Ray-casting algorithm to test if a 2D point is inside a polygon.
---@param point vector2
---@param polygon table
---@return boolean
function Sky.Poly.IsPointInZone(point, polygon)
    local count = 0
    local n = #polygon

    for i = 1, n do
        local p1 = polygon[i]
        local p2 = polygon[(i % n) + 1]

        if (p1.y > point.y) ~= (p2.y > point.y) then
            local intersectX = (p2.x - p1.x) * (point.y - p1.y) / (p2.y - p1.y + 1e-5) + p1.x
            if intersectX > point.x then
                count = count + 1
            end
        end
    end

    return (count % 2) == 1
end

--- Generates a random ground coordinate within a 2D polygon.
---@param polygon table
---@return vector3|nil
function Sky.Poly.GetRandomPoint(polygon)
    local minX = polygon[1].x
    local maxX = polygon[1].x
    local minY = polygon[1].y
    local maxY = polygon[1].y

    for _, pt in ipairs(polygon) do
        minX = math.min(minX, pt.x)
        maxX = math.max(maxX, pt.x)
        minY = math.min(minY, pt.y)
        maxY = math.max(maxY, pt.y)
    end

    for _ = 1, 20 do
        local rx = math.random() * (maxX - minX) + minX
        local ry = math.random() * (maxY - minY) + minY
        local pt2d = vector2(rx, ry)

        if Sky.Poly.IsPointInZone(pt2d, polygon) then
            local found, groundZ = GetGroundZFor_3dCoord(pt2d.x, pt2d.y, 1000.0, 0)
            if found then
                return vector3(pt2d.x, pt2d.y, groundZ + 1.0)
            end
        end
    end

    if Sky.Debug then
        Sky.Debug("error", "Could not find a valid spawn point in polygon after 20 attempts.")
    end

    return nil
end

--- Renders debug lines for a polygon in 3D world space.
---@param polygon table
function Sky.Poly.DrawDebug(polygon)
    local n = #polygon
    for i = 1, n do
        local p1 = polygon[i]
        local p2 = polygon[(i % n) + 1]

        for z = 0.0, 95.0, 1.0 do
            DrawLine(p1.x, p1.y, z, p2.x, p2.y, z, 255, 0, 0, 100)
        end
    end
end
