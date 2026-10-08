if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/map.lua") end
-- =====================================================
--  sky_jobs_base · source/server/map.lua
--  Map Exclusion Zones & Blip Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

local ZONES_KVP = "sky_jobs_base:exclusionZones"
local MAX_ZONES = 25
local MAX_POINTS = 48
-- Zones remove ambient vehicles and peds on every client, so a single zone may not cover the city.
local MAX_ZONE_SPAN = 1500.0
local MAX_LABEL_LENGTH = 48

local exclusionZones = {}
local lastZoneChange = {}

local function cleanLabel(value)
    if type(value) ~= "string" then return "Exclusion Zone" end
    local label = value:gsub("%c", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if label == "" then return "Exclusion Zone" end
    local ok, cut = pcall(utf8.offset, label, MAX_LABEL_LENGTH + 1)
    if ok and cut then return label:sub(1, cut - 1) end
    return ok and label or label:sub(1, MAX_LABEL_LENGTH)
end

local function toPoint(value)
    if type(value) ~= "table" and type(value) ~= "vector2" and type(value) ~= "vector3" then return nil end
    local x, y = tonumber(value.x), tonumber(value.y)
    if not x or not y or x ~= x or y ~= y or math.abs(x) > 10000.0 or math.abs(y) > 10000.0 then return nil end
    return { x = math.floor(x * 100 + 0.5) / 100, y = math.floor(y * 100 + 0.5) / 100 }
end

local function toPolygon(points)
    if type(points) ~= "table" or #points < 3 or #points > MAX_POINTS then return nil end

    local polygon = {}
    local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
    for i = 1, #points do
        local pt = toPoint(points[i])
        if not pt then return nil end
        polygon[i] = pt
        minX, maxX = math.min(minX, pt.x), math.max(maxX, pt.x)
        minY, maxY = math.min(minY, pt.y), math.max(maxY, pt.y)
    end

    if maxX - minX > MAX_ZONE_SPAN or maxY - minY > MAX_ZONE_SPAN then return nil end
    return polygon
end

local function sanitizeZone(zone)
    if type(zone) ~= "table" or (type(zone.id) ~= "string" and type(zone.id) ~= "number") then return nil end
    local points = toPolygon(zone.points)
    if not points then return nil end
    return {
        id = tostring(zone.id),
        label = cleanLabel(zone.label),
        points = points,
        createdBy = type(zone.createdBy) == "string" and zone.createdBy:sub(1, 64) or nil,
        createdAt = tonumber(zone.createdAt)
    }
end

local function loadExclusionZones()
    exclusionZones = {}
    local ok, stored = pcall(json.decode, GetResourceKvpString(ZONES_KVP) or "[]")
    if not ok or type(stored) ~= "table" then return end

    for _, zone in ipairs(stored) do
        local clean = sanitizeZone(zone)
        if clean and #exclusionZones < MAX_ZONES then
            exclusionZones[#exclusionZones + 1] = clean
        end
    end
end

local function saveAndBroadcastZones()
    SetResourceKvp(ZONES_KVP, json.encode(exclusionZones))
    -- Zones change every client's world (ambient cleanup and warnings), not only employees'.
    TriggerClientEvent("sky_jobs_base:map:updateExclusionZones", -1, { zones = exclusionZones })
end

-- Admins (ACE sky_jobs_base.exclusionzones or Config.CommandPermissions.exclusionzones) and on-duty
-- emergency services (Config.Panic.allowedJobs; bosses only when that list is not configured).
local function canManageExclusionZones(src)
    if Sky_Jobs.HasPermission(src, "exclusionzones") then return true end

    local job = Sky_Jobs.RequireEmployee(src, true)
    if not job then return false end

    local allowed = Config and Config.Panic and Config.Panic.allowedJobs
    if type(allowed) == "string" then allowed = { allowed } end
    if type(allowed) ~= "table" then
        return Sky_Jobs.IsPlayerBoss(src) == true
    end

    for _, name in ipairs(allowed) do
        if type(name) == "string" and name:lower() == job:lower() then return true end
    end
    return false
end

local function isZoneChangeThrottled(src)
    local now = GetGameTimer()
    if lastZoneChange[src] and now - lastZoneChange[src] < 1000 then return true end
    lastZoneChange[src] = now
    return false
end

AddEventHandler("playerDropped", function()
    lastZoneChange[source] = nil
end)

loadExclusionZones()

Sky.Cb.Register("sky_jobs_base:map:getExclusionZones", function(source, data)
    return {
        success = true,
        data = { zones = exclusionZones }
    }
end)

Sky.Cb.Register("sky_jobs_base:map:getBlips", function(source, data)
    return {
        success = true,
        data = {}
    }
end)

Sky.Cb.Register("sky_jobs_base:map:createExclusionZone", function(source, data)
    local src = tonumber(source)
    if not src or not canManageExclusionZones(src) then
        return { success = false, error = "not_authorized" }
    end
    if isZoneChangeThrottled(src) then
        return { success = false, error = "rate_limited" }
    end
    if #exclusionZones >= MAX_ZONES then
        return { success = false, error = "limit_reached" }
    end

    data = type(data) == "table" and data or {}
    local points = toPolygon(data.points)
    if not points then
        return { success = false, error = "invalid_points" }
    end

    local id
    repeat
        id = ("zone_%d_%d"):format(os.time(), math.random(1000, 9999))
    until not Sky.Table.SearchTableList(exclusionZones, "id", id)

    exclusionZones[#exclusionZones + 1] = {
        id = id,
        label = cleanLabel(data.label or data.name),
        points = points,
        createdBy = Sky_Jobs.GetPlayerFullName(src),
        createdAt = os.time()
    }
    saveAndBroadcastZones()

    return {
        success = true,
        data = { zones = exclusionZones }
    }
end)

Sky.Cb.Register("sky_jobs_base:map:deleteExclusionZone", function(source, data)
    local src = tonumber(source)
    if not src or not canManageExclusionZones(src) then
        return { success = false, error = "not_authorized" }
    end
    if isZoneChangeThrottled(src) then
        return { success = false, error = "rate_limited" }
    end

    data = type(data) == "table" and data or {}
    local zoneId = data.id or data.zoneId
    if zoneId == nil then
        return { success = false, error = "missing_id" }
    end

    for i = #exclusionZones, 1, -1 do
        if exclusionZones[i].id == tostring(zoneId) then
            table.remove(exclusionZones, i)
            saveAndBroadcastZones()
            return {
                success = true,
                data = { zones = exclusionZones }
            }
        end
    end

    return { success = false, error = "not_found" }
end)
