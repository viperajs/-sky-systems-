if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/gallery.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/gallery.lua
--  Deobfuscated & Cleaned
-- =====================================================

RegisterNUICallback("gallery:getPhotos", function(data, cb)
    data = data or {}

    local res = Sky.Cb.Trigger("sky_jobs_base:gallery:getPhotos", {
        limit = tonumber(data.limit),
        offset = tonumber(data.offset)
    })

    if not res then res = {} end

    local payload = res.data
    if type(payload) == "table" and payload.photos and type(payload.photos) == "table" then
        payload = payload.photos
    end
    if type(payload) ~= "table" then
        payload = {}
    end

    cb({
        success = res.success == true,
        data = payload,
        error = res.error
    })
end)
