if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/gallery.lua") end
-- =====================================================
--  sky_jobs_base · source/client/gallery.lua
--  Deobfuscated & Cleaned
-- =====================================================

RegisterNUICallback("gallery:getPhotos", function(data, cb)
    data = data or {}
    local res = Sky.Cb.Trigger("sky_jobs_base:gallery:getPhotos", {
        limit = tonumber(data.limit),
        offset = tonumber(data.offset)
    }) or {}

    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("gallery:getPresignedUrl", function(data, cb)
    data = data or {}
    local res = Sky.Cb.Trigger("sky_jobs_base:gallery:getPresignedUrl", {
        fileType = data.fileType
    }) or {}

    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("gallery:deletePhoto", function(data, cb)
    data = data or {}
    local res = Sky.Cb.Trigger("sky_jobs_base:gallery:deletePhoto", {
        id = tonumber(data.id)
    }) or {}

    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("gallery:addPhoto", function(data, cb)
    data = data or {}
    local res = Sky.Cb.Trigger("sky_jobs_base:gallery:addPhoto", {
        url = data.url,
        folder = data.folder,
        image_id = data.image_id
    }) or {}

    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)
