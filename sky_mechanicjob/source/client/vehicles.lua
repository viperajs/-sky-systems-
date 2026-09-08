if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/vehicles.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/vehicles.lua
--  Deobfuscated & Cleaned
-- =====================================================

local function getVehicleModelLabel(modelOrHash)
    if type(modelOrHash) ~= "string" and type(modelOrHash) ~= "number" then
        return nil
    end

    local hash = modelOrHash
    if type(modelOrHash) == "string" then
        hash = joaat(modelOrHash)
    end

    if type(hash) == "number" and hash ~= 0 then
        local displayName = GetDisplayNameFromVehicleModel(hash)
        if displayName and displayName ~= "" then
            local label = GetLabelText(displayName)
            if label and label ~= "NULL" then
                return label
            end
            return displayName
        end
    end

    if type(modelOrHash) == "string" and modelOrHash ~= "" then
        return modelOrHash
    end

    return nil
end

local function enrichVehiclesWithLabels(vehicles)
    for _, v in ipairs(vehicles or {}) do
        v.model_label = getVehicleModelLabel(v.model)
    end
end

-- ── NUI Callbacks ────────────────────────────────────

RegisterNUICallback("vehicles:getRegistry", function(data, cb)
    local res = Sky.Cb.Trigger("sky_mechanicjob:vehicles:getRegistry", {
        page = data and data.page,
        pageSize = data and data.pageSize,
        search = data and data.search
    })

    if not res then res = {} end

    if res.success and res.data and type(res.data.vehicles) == "table" then
        enrichVehiclesWithLabels(res.data.vehicles)
    end

    cb(res)
end)

RegisterNUICallback("vehicles:getHistory", function(data, cb)
    local res = Sky.Cb.Trigger("sky_mechanicjob:vehicles:getHistory", {
        plate = data and data.plate
    })
    cb(res or {})
end)

RegisterNUICallback("vehicles:setImage", function(data, cb)
    local res = Sky.Cb.Trigger("sky_mechanicjob:vehicles:setImage", {
        plate = data.plate,
        url = data.url,
        image_id = data.image_id
    })
    cb(res or { success = false, error = "Failed to update vehicle image." })
end)

RegisterNUICallback("vehicles:setTags", function(data, cb)
    local res = Sky.Cb.Trigger("sky_mechanicjob:vehicles:setTags", {
        plate = data.plate,
        tags = data.tags or {}
    })
    cb(res or { success = false, error = "Failed to update vehicle tags." })
end)

RegisterNUICallback("vehicles:setNotes", function(data, cb)
    local res = Sky.Cb.Trigger("sky_mechanicjob:vehicles:setNotes", {
        plate = data.plate,
        text = data.text or ""
    })
    cb(res or { success = false, error = "Failed to update vehicle notes." })
end)
