if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/map.lua") end
-- =====================================================
--  sky_jobs_base · source/server/map.lua
--  Map Exclusion Zones & Blip Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

Sky.Cb.Register("sky_jobs_base:map:getExclusionZones", function(source, data)
    return {
        success = true,
        data = (Config and Config.ExclusionZones) or {}
    }
end)

Sky.Cb.Register("sky_jobs_base:map:getBlips", function(source, data)
    return {
        success = true,
        data = {}
    }
end)

Sky.Cb.Register("sky_jobs_base:map:createExclusionZone", function(source, data)
    data = type(data) == "table" and data or {}
    Config = Config or {}
    Config.ExclusionZones = Config.ExclusionZones or {}

    local zone = {
        id = data.id or ("zone_" .. tostring(GetGameTimer())),
        label = data.label or data.name or "Exclusion Zone",
        x = tonumber(data.x) or (type(data.coords) == "table" and tonumber(data.coords.x)) or 0.0,
        y = tonumber(data.y) or (type(data.coords) == "table" and tonumber(data.coords.y)) or 0.0,
        z = tonumber(data.z) or (type(data.coords) == "table" and tonumber(data.coords.z)) or 0.0,
        radius = tonumber(data.radius) or 50.0
    }

    Config.ExclusionZones[#Config.ExclusionZones + 1] = zone

    return {
        success = true,
        data = zone
    }
end)

Sky.Cb.Register("sky_jobs_base:map:deleteExclusionZone", function(source, data)
    data = type(data) == "table" and data or {}
    local zoneId = data.id or data.zoneId
    Config = Config or {}
    Config.ExclusionZones = Config.ExclusionZones or {}

    if not zoneId then
        return { success = false, error = "missing_id" }
    end

    for i = #Config.ExclusionZones, 1, -1 do
        local zone = Config.ExclusionZones[i]
        if zone and tostring(zone.id) == tostring(zoneId) then
            table.remove(Config.ExclusionZones, i)
            return { success = true, data = { id = zoneId } }
        end
    end

    return { success = false, error = "not_found" }
end)
