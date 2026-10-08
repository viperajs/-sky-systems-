if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/alerts.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_jobs_base · source/server/alerts.lua
--  Panic, ping & dispatch alerts, map feeds, heli spotlights,
--  bodycam scope and the employee GPS jammer
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

local DISPATCH_TTL_SECONDS = 1800
local DISPATCH_DONE_TTL_SECONDS = 300
local MAX_DISPATCHES = 100
local MAX_DISPATCH_JOBS = 10
-- Client-created dispatches may point near the sender, not anywhere on the map.
local CLIENT_DISPATCH_RADIUS = 150.0
local SPOTLIGHT_RANGE = 1000.0

local ALERT_TYPES = {
    panic = {
        configKey = "Panic",
        alertEvent = "sky_jobs_base:panic:alert",
        acceptedEvent = "sky_jobs_base:panic:accepted",
        rejectedEvent = "sky_jobs_base:panic:rejected"
    },
    ping = {
        configKey = "Ping",
        alertEvent = "sky_jobs_base:ping:alert",
        acceptedEvent = "sky_jobs_base:ping:accepted",
        rejectedEvent = "sky_jobs_base:ping:rejected"
    }
}

local MAP_FEEDS = {
    panic = { event = "sky_jobs_base:map:updatePanics", key = "panics" },
    ping = { event = "sky_jobs_base:map:updatePings", key = "pings" },
    dispatch = { event = "sky_jobs_base:map:updateDispatches", key = "dispatches" }
}

local alerts = { panic = {}, ping = {}, dispatch = {} }
local alertSerial = 0
local lastActions = {}
local alertCooldowns = {}
local bodycamViewers = {}
local isScopeLoopRunning = false
local forwardSpotlights = {}
local jammedUntil = {}

-- -----------------------------------------------------
--  HELPERS
-- -----------------------------------------------------

local function isThrottled(src, key, intervalMs)
    local now = GetGameTimer()
    local entry = lastActions[src]
    if not entry then
        entry = {}
        lastActions[src] = entry
    end
    if entry[key] and now - entry[key] < intervalMs then
        return true
    end
    entry[key] = now
    return false
end

local function toInteger(value)
    local n = tonumber(value)
    if not n or n ~= n or n % 1 ~= 0 then return nil end
    return math.floor(n)
end

local function cleanText(value, maxChars, fallback)
    if type(value) ~= "string" then return fallback end
    local text = value:gsub("%c", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return fallback end
    local ok, cut = pcall(utf8.offset, text, maxChars + 1)
    if ok and cut then return text:sub(1, cut - 1) end
    return ok and text or text:sub(1, maxChars)
end

local function toCoords(value)
    local kind = type(value)
    if kind ~= "table" and kind ~= "vector3" and kind ~= "vector4" then return nil end
    local x = tonumber(value.x or value[1])
    local y = tonumber(value.y or value[2])
    local z = tonumber(value.z or value[3]) or 0.0
    if not x or not y or x ~= x or y ~= y or z ~= z then return nil end
    if math.abs(x) > 10000.0 or math.abs(y) > 10000.0 or math.abs(z) > 5000.0 then return nil end
    return { x = x, y = y, z = z }
end

local function getPlayerPosition(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return nil end
    local c = GetEntityCoords(ped)
    return { x = c.x, y = c.y, z = c.z }
end

local function getDistance(a, b)
    local dx, dy, dz = a.x - b.x, a.y - b.y, (a.z or 0.0) - (b.z or 0.0)
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-- Accepts { "police" }, "police" and { police = true }; keys are lower-case.
local function toJobSet(value, limit)
    local set, count = {}, 0
    limit = limit or math.huge
    local function add(name)
        if type(name) == "string" and name ~= "" and #name <= 64 and not set[name:lower()] then
            set[name:lower()] = true
            count = count + 1
        end
    end

    if type(value) == "string" then
        add(value)
    elseif type(value) == "table" then
        for k, v in pairs(value) do
            if count >= limit then break end
            if v == true then add(k) else add(v) end
        end
    end
    return set
end

local function getPlayersNear(coords, radius)
    local list = {}
    for _, id in ipairs(GetPlayers()) do
        local p = tonumber(id)
        local ped = p and GetPlayerPed(p)
        if ped and ped ~= 0 and #(GetEntityCoords(ped) - coords) <= radius then
            list[#list + 1] = p
        end
    end
    return list
end

-- Calls fn(src, job, onDuty) for every employed player.
local function forEachEmployee(fn)
    for _, id in ipairs(GetPlayers()) do
        local src = tonumber(id)
        local job = src and Sky_Jobs.GetEmployment(src)
        if job then
            fn(src, job, Sky_Jobs.PlayerCache.IsOnDuty(src))
        end
    end
end

-- -----------------------------------------------------
--  ALERT STORE (panic, ping, dispatch)
-- -----------------------------------------------------

local function canSeeAlert(record, src, job, onDuty)
    if not job or not record.audience[job:lower()] then return false end
    if not onDuty and not record.notifyOffDuty then return false end
    if src == record.source and not record.showSelf then return false end
    return true
end

local function toPublicAlert(record)
    return {
        id = record.id,
        type = record.type,
        title = record.title,
        message = record.message,
        code = record.code,
        officerName = record.officerName,
        label = record.officerName or record.title,
        location = record.location,
        coords = record.coords,
        status = record.status,
        acceptedBy = record.acceptedBy,
        doneBy = record.doneBy,
        blip = record.blip,
        createdAt = record.createdAt,
        expiresAt = record.expiresAt
    }
end

local function getVisibleAlerts(alertType, src, job, onDuty)
    local list = {}
    local now = os.time()
    for _, record in pairs(alerts[alertType]) do
        if record.expiresAt > now and canSeeAlert(record, src, job, onDuty) then
            list[#list + 1] = toPublicAlert(record)
        end
    end
    table.sort(list, function(a, b) return a.createdAt > b.createdAt end)
    return list
end

local function sendMapFeed(alertType, src, job, onDuty)
    local feed = MAP_FEEDS[alertType]
    TriggerClientEvent(feed.event, src, { [feed.key] = getVisibleAlerts(alertType, src, job, onDuty) })
end

local function pushMapFeed(alertType, audience)
    forEachEmployee(function(src, job, onDuty)
        if audience[job:lower()] then
            sendMapFeed(alertType, src, job, onDuty)
        end
    end)
end

local function nextAlertId(alertType)
    alertSerial = alertSerial + 1
    return ("%s-%d"):format(alertType, alertSerial)
end

local function getAlertConfig(alertType)
    local cfg = Config and Config[ALERT_TYPES[alertType].configKey]
    return type(cfg) == "table" and cfg or {}
end

-- Same rule as the client: allowedJobs when configured, otherwise the registered job list.
local function isAlertJobAllowed(cfg, job)
    if cfg.allowedJobs ~= nil then
        return toJobSet(cfg.allowedJobs)[job:lower()] == true
    end
    return toJobSet(Sky_Jobs.GetRegisteredJobNames())[job:lower()] == true
end

local function getAlertAudience(cfg, senderJob)
    local groups = type(cfg.groups) == "table" and cfg.groups[senderJob] or nil
    if groups ~= nil then
        return toJobSet(groups)
    end
    local audience = toJobSet(cfg.notifyJobs)
    audience[senderJob:lower()] = true
    return audience
end

local function rejectAlert(alertType, src, reason, extra)
    local payload = { reason = reason }
    for k, v in pairs(extra or {}) do payload[k] = v end
    TriggerClientEvent(ALERT_TYPES[alertType].rejectedEvent, src, payload)
end

local function triggerAlert(alertType, src, payload)
    local cfg = getAlertConfig(alertType)
    if cfg.enabled == false or isThrottled(src, alertType .. ":trigger", 1000) then return end

    local job = Sky_Jobs.RequireEmployee(src, false)
    if not job or not isAlertJobAllowed(cfg, job) then
        return rejectAlert(alertType, src, "not_allowed")
    end
    if cfg.requireOnDuty ~= false and not Sky_Jobs.PlayerCache.IsOnDuty(src) then
        return rejectAlert(alertType, src, "not_on_duty")
    end

    local nowMs = GetGameTimer()
    local readyAt = alertCooldowns[src] and alertCooldowns[src][alertType]
    if readyAt and readyAt > nowMs then
        return rejectAlert(alertType, src, "cooldown", { seconds = math.ceil((readyAt - nowMs) / 1000) })
    end

    if cfg.requireItem == true then
        local item = type(cfg.item) == "string" and cfg.item or ""
        if item == "" or Sky_Jobs.GetInventoryItemCount(src, item) < 1 then
            return rejectAlert(alertType, src, "missing_item", { item = item })
        end
    end

    local coords = getPlayerPosition(src)
    if not coords then
        return rejectAlert(alertType, src, "failed")
    end

    alertCooldowns[src] = alertCooldowns[src] or {}
    alertCooldowns[src][alertType] = nowMs + math.max(0, tonumber(cfg.cooldownSeconds) or 0) * 1000

    local duration = tonumber(cfg.alertDurationSeconds)
    if not duration or duration <= 0 then duration = 300 end

    local createdAt = os.time()
    local record = {
        id = nextAlertId(alertType),
        type = alertType,
        source = src,
        officerName = Sky_Jobs.GetPlayerFullName(src),
        -- Street names only exist on the client; this is display text.
        location = cleanText(type(payload) == "table" and payload.location or nil, 80, nil),
        coords = coords,
        createdAt = createdAt,
        expiresAt = createdAt + duration,
        audience = getAlertAudience(cfg, job),
        notifyOffDuty = cfg.notifyOffDuty == true,
        showSelf = cfg.showSelf ~= false
    }
    alerts[alertType][record.id] = record

    local public = toPublicAlert(record)
    local notification = {
        incidentType = alertType,
        id = record.id,
        officerName = record.officerName,
        coords = coords,
        location = record.location,
        createdAt = createdAt,
        mapTargetType = alertType,
        mapTargetId = record.id
    }

    forEachEmployee(function(viewer, viewerJob, onDuty)
        if canSeeAlert(record, viewer, viewerJob, onDuty) then
            TriggerClientEvent(ALERT_TYPES[alertType].alertEvent, viewer, public)
            if viewer ~= src then
                TriggerClientEvent("sky_jobs_base:incident:notify", viewer, notification)
            end
            sendMapFeed(alertType, viewer, viewerJob, onDuty)
        end
    end)

    TriggerClientEvent(ALERT_TYPES[alertType].acceptedEvent, src)
end

RegisterNetEvent("sky_jobs_base:panic:trigger", function(payload)
    triggerAlert("panic", source, payload)
end)

RegisterNetEvent("sky_jobs_base:ping:trigger", function(payload)
    triggerAlert("ping", source, payload)
end)

local function sanitizeBlip(blip)
    if type(blip) ~= "table" then return nil end
    local sprite = toInteger(blip.sprite)
    local color = toInteger(blip.color or blip.colour)
    local out = {}
    if sprite and sprite >= 0 and sprite <= 1000 then out.sprite = sprite end
    if color and color >= 0 and color <= 85 then out.color = color end
    return next(out) and out or nil
end

local function removeOldestDispatch()
    local oldest
    for _, record in pairs(alerts.dispatch) do
        if not oldest or record.createdAt < oldest.createdAt then oldest = record end
    end
    if oldest then alerts.dispatch[oldest.id] = nil end
end

local function storeDispatch(jobs, title, message, coords, options, senderSrc)
    local audience = toJobSet(jobs, MAX_DISPATCH_JOBS)
    for job in pairs(audience) do
        if Sky_Jobs.IsUnemployedJob(job) then audience[job] = nil end
    end
    if not next(audience) then return nil end

    local count = 0
    for _ in pairs(alerts.dispatch) do count = count + 1 end
    if count >= MAX_DISPATCHES then removeOldestDispatch() end

    local createdAt = os.time()
    local record = {
        id = nextAlertId("dispatch"),
        type = "dispatch",
        source = senderSrc,
        title = options.code and ("%s - %s"):format(options.code, title) or title,
        message = message,
        code = options.code,
        blip = options.blip,
        officerName = options.officerName,
        location = options.location,
        coords = coords,
        status = "active",
        createdAt = createdAt,
        expiresAt = createdAt + DISPATCH_TTL_SECONDS,
        audience = audience,
        notifyOffDuty = false,
        showSelf = true
    }
    alerts.dispatch[record.id] = record

    local notification = {
        incidentType = "dispatch",
        id = record.id,
        title = record.title,
        message = message ~= "" and message or nil,
        officerName = record.officerName,
        coords = coords,
        location = record.location,
        createdAt = createdAt,
        mapTargetType = "dispatch",
        mapTargetId = record.id
    }

    forEachEmployee(function(viewer, viewerJob, onDuty)
        if canSeeAlert(record, viewer, viewerJob, onDuty) then
            sendMapFeed("dispatch", viewer, viewerJob, onDuty)
            if viewer ~= senderSrc then
                TriggerClientEvent("sky_jobs_base:incident:notify", viewer, notification)
            end
        end
    end)

    return record
end

--- Creates a dispatch for on-duty members of data.jobs (tablet map, map blip and incident notification).
--- data = { jobs = { "police" }, title, message, coords, code?, blip = { sprite?, color? }?, location? }
registerExport("CreateDispatch", function(data)
    if type(data) ~= "table" then return false end
    local coords = toCoords(data.coords)
    local title = cleanText(data.title, 80, nil)
    if not coords or not title then return false end

    return storeDispatch(data.jobs or data.job, title, cleanText(data.message, 400, ""), coords, {
        code = cleanText(data.code, 16, nil),
        blip = sanitizeBlip(data.blip),
        location = cleanText(data.location, 80, nil)
    }, nil) ~= nil
end)

-- Client export createDispatch(title, message, jobKey, coords, extraData) from any player (alarms, robberies).
RegisterNetEvent("sky_jobs_base:dispatch:create", function(title, message, jobKey, coords, extraData)
    local src = source
    if isThrottled(src, "dispatch:create", 10000) then return end

    local position = getPlayerPosition(src)
    if not position then return end

    local target = toCoords(coords)
    if not target or getDistance(target, position) > CLIENT_DISPATCH_RADIUS then
        target = position
    end

    local senderJob = Sky_Jobs.GetEmployment(src)
    local jobs = jobKey
    if jobs == nil then jobs = senderJob end

    extraData = type(extraData) == "table" and extraData or {}
    local audience = toJobSet(jobs, MAX_DISPATCH_JOBS)
    storeDispatch(audience, cleanText(title, 80, "Dispatch"), cleanText(message, 400, ""), target, {
        code = cleanText(extraData.code, 16, nil),
        blip = sanitizeBlip(extraData.blip),
        -- Only colleagues are named; an alarm raised by a civilian stays anonymous.
        officerName = (senderJob and audience[senderJob:lower()]) and Sky_Jobs.GetPlayerFullName(src) or nil,
        location = cleanText(extraData.location or extraData.street, 80, nil)
    }, src)
end)

local function getDispatchForActor(src, payload)
    local id = type(payload) == "table" and payload.id or nil
    if type(id) ~= "string" and type(id) ~= "number" then return nil end

    local record = alerts.dispatch[tostring(id)]
    if not record or record.expiresAt <= os.time() then return nil end

    local job = Sky_Jobs.RequireEmployee(src, true)
    if not job or not record.audience[job:lower()] then return nil end
    return record
end

RegisterNetEvent("sky_jobs_base:dispatch:accept", function(payload)
    local src = source
    if isThrottled(src, "dispatch:update", 500) then return end
    local record = getDispatchForActor(src, payload)
    if not record or record.status ~= "active" then return end

    record.status = "accepted"
    record.acceptedBy = { name = Sky_Jobs.GetPlayerFullName(src) }
    pushMapFeed("dispatch", record.audience)
end)

RegisterNetEvent("sky_jobs_base:dispatch:done", function(payload)
    local src = source
    if isThrottled(src, "dispatch:update", 500) then return end
    local record = getDispatchForActor(src, payload)
    if not record or record.status == "done" then return end

    record.status = "done"
    record.doneBy = { name = Sky_Jobs.GetPlayerFullName(src) }
    record.expiresAt = math.min(record.expiresAt, os.time() + DISPATCH_DONE_TTL_SECONDS)
    pushMapFeed("dispatch", record.audience)
end)

RegisterNetEvent("sky_jobs_base:dispatch:delete", function(payload)
    local src = source
    if isThrottled(src, "dispatch:update", 500) then return end
    local record = getDispatchForActor(src, payload)
    if not record then return end

    alerts.dispatch[record.id] = nil
    pushMapFeed("dispatch", record.audience)
end)

-- -----------------------------------------------------
--  MAP FEEDS
-- -----------------------------------------------------

local function registerFeedCallback(name, alertTypes)
    Sky.Cb.Register(name, function(source)
        local src = tonumber(source)
        local job = src and Sky_Jobs.GetEmployment(src)
        if not job then
            return { success = false, error = "no_job" }
        end

        local onDuty = Sky_Jobs.PlayerCache.IsOnDuty(src)
        local data = {}
        for _, alertType in ipairs(alertTypes) do
            data[MAP_FEEDS[alertType].key] = getVisibleAlerts(alertType, src, job, onDuty)
        end
        return { success = true, data = data }
    end)
end

registerFeedCallback("sky_jobs_base:map:getDispatches", { "dispatch" })
registerFeedCallback("sky_jobs_base:map:getPanics", { "panic" })
registerFeedCallback("sky_jobs_base:map:getPings", { "ping" })
registerFeedCallback("sky_jobs_base:alerts:getActive", { "panic", "ping", "dispatch" })

RegisterNetEvent("sky_jobs_base:map:refresh", function()
    local src = source
    if isThrottled(src, "map:refresh", 1000) then return end
    local job = Sky_Jobs.GetEmployment(src)
    if not job then return end

    local onDuty = Sky_Jobs.PlayerCache.IsOnDuty(src)
    for alertType in pairs(MAP_FEEDS) do
        sendMapFeed(alertType, src, job, onDuty)
    end
end)

CreateThread(function()
    while true do
        Wait(5000)
        local now = os.time()
        for alertType, records in pairs(alerts) do
            local audience
            for id, record in pairs(records) do
                if record.expiresAt <= now then
                    records[id] = nil
                    audience = audience or {}
                    for job in pairs(record.audience) do audience[job] = true end
                end
            end
            if audience then
                pushMapFeed(alertType, audience)
            end
        end
    end
end)

-- -----------------------------------------------------
--  HELI SPOTLIGHTS
-- -----------------------------------------------------

local allowedHeliModels

-- Model hashes can arrive signed or unsigned depending on the native.
local function toUnsignedHash(hash)
    hash = tonumber(hash) or 0
    if hash < 0 then hash = hash + 4294967296 end
    return hash
end

local function getPilotHeli(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return nil end
    local veh = GetVehiclePedIsIn(ped, false)
    if not veh or veh == 0 or GetPedInVehicleSeat(veh, -1) ~= ped then return nil end

    if not allowedHeliModels then
        allowedHeliModels = {}
        local models = Config and Config.HeliCam and Config.HeliCam.models or { "polmav" }
        for _, model in ipairs(models) do
            allowedHeliModels[toUnsignedHash(type(model) == "number" and model or GetHashKey(model))] = true
        end
    end
    if not allowedHeliModels[toUnsignedHash(GetEntityModel(veh))] then return nil end
    return veh
end

-- Mirrors the client check (allowed jobs, optional duty) and requires the pilot seat of a listed heli.
local function getAuthorizedHeli(src)
    local cfg = Config and Config.HeliCam or {}
    if cfg.enabled == false then return nil end

    local allowed = toJobSet(cfg.allowedJobs or cfg.jobs)
    local requireDuty = cfg.requireOnDuty ~= false
    if next(allowed) or requireDuty then
        local job = Sky_Jobs.RequireEmployee(src, requireDuty)
        if not job or (next(allowed) and not allowed[job:lower()]) then return nil end
    end
    return getPilotHeli(src)
end

local function clampSpotlight(brightness, radius)
    local spot = Config and Config.HeliCam and Config.HeliCam.spotlight or {}
    local b = tonumber(brightness) or tonumber(spot.brightness) or 1.0
    local r = tonumber(radius) or tonumber(spot.radius) or 4.0
    b = math.max(tonumber(spot.minBrightness) or 1.0, math.min(tonumber(spot.maxBrightness) or 10.0, b))
    r = math.max(tonumber(spot.minRadius) or 4.0, math.min(tonumber(spot.maxRadius) or 10.0, r))
    return b, r
end

local function sendToPlayersNear(coords, eventName, ...)
    for _, p in ipairs(getPlayersNear(coords, SPOTLIGHT_RANGE)) do
        TriggerClientEvent(eventName, p, ...)
    end
end

-- Switching a light off needs no authorization; it only reaches players near the sender.
local function sendNearSender(src, eventName, ...)
    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then
        sendToPlayersNear(GetEntityCoords(ped), eventName, src, ...)
    end
end

RegisterNetEvent("sky_jobs_base:heli:spotlight:forward", function(enabled)
    local src = source
    if isThrottled(src, "heli:forward", 250) then return end

    if enabled == true then
        local veh = getAuthorizedHeli(src)
        if not veh then return end
        local netId = NetworkGetNetworkIdFromEntity(veh)
        forwardSpotlights[src] = netId
        sendToPlayersNear(GetEntityCoords(veh), "sky_jobs_base:heli:spotlight:forward", src, true, netId)
        return
    end

    -- The pilot may already have left the heli, so the light is switched off on the heli it was turned on for.
    local netId = forwardSpotlights[src]
    forwardSpotlights[src] = nil
    local veh = netId and NetworkGetEntityFromNetworkId(netId) or 0
    if veh ~= 0 and DoesEntityExist(veh) then
        sendToPlayersNear(GetEntityCoords(veh), "sky_jobs_base:heli:spotlight:forward", src, false, netId)
    end
end)

RegisterNetEvent("sky_jobs_base:heli:spotlight:tracking", function(netId, _, _, _, _, brightness, radius)
    local src = source
    if isThrottled(src, "heli:tracking", 250) then return end

    local veh = getAuthorizedHeli(src)
    netId = toInteger(netId)
    if not veh or not netId then return end

    local target = NetworkGetEntityFromNetworkId(netId)
    if not target or target == 0 or not DoesEntityExist(target) or GetEntityType(target) ~= 2 then return end

    local heliPos = GetEntityCoords(veh)
    local targetPos = GetEntityCoords(target)
    local maxDistance = (tonumber(Config and Config.HeliCam and Config.HeliCam.maxLockDistance) or 700.0) + 50.0
    if #(heliPos - targetPos) > maxDistance then return end

    local b, r = clampSpotlight(brightness, radius)
    sendToPlayersNear(heliPos, "sky_jobs_base:heli:spotlight:tracking", src, netId,
        GetVehicleNumberPlateText(target), targetPos.x, targetPos.y, targetPos.z, b, r)
end)

RegisterNetEvent("sky_jobs_base:heli:spotlight:tracking:stop", function()
    local src = source
    if isThrottled(src, "heli:trackingStop", 250) then return end
    sendNearSender(src, "sky_jobs_base:heli:spotlight:tracking:stop")
end)

RegisterNetEvent("sky_jobs_base:heli:spotlight:manual", function(enabled, brightness, radius)
    local src = source
    if isThrottled(src, "heli:manual", 250) then return end

    local b, r = clampSpotlight(brightness, radius)
    if enabled ~= true then
        sendNearSender(src, "sky_jobs_base:heli:spotlight:manual", false, b, r)
        return
    end

    local veh = getAuthorizedHeli(src)
    if veh then
        sendToPlayersNear(GetEntityCoords(veh), "sky_jobs_base:heli:spotlight:manual", src, true, b, r)
    end
end)

RegisterNetEvent("sky_jobs_base:heli:spotlight:settings", function(brightness, radius)
    local src = source
    if isThrottled(src, "heli:settings", 100) then return end

    local veh = getAuthorizedHeli(src)
    if not veh then return end
    local b, r = clampSpotlight(brightness, radius)
    sendToPlayersNear(GetEntityCoords(veh), "sky_jobs_base:heli:spotlight:settings", src, b, r)
end)

-- -----------------------------------------------------
--  CCTV: BODYCAM SCOPE & VIDEO CONFIG
-- -----------------------------------------------------

-- Viewer and wearer on duty; wearer's job visible to the viewer's job (Config.Cctv.bodycamViewJobs,
-- otherwise the own job); wearer carries the bodycam item when Config.Cctv.requireBodycamItem is set.
local function canViewBodycam(viewer, target)
    local viewerJob = Sky_Jobs.RequireEmployee(viewer, true)
    local targetJob = viewerJob and Sky_Jobs.RequireEmployee(target, true)
    if not targetJob then return false end

    local cctvCfg = Config and Config.Cctv or {}
    local viewJobs = type(cctvCfg.bodycamViewJobs) == "table" and cctvCfg.bodycamViewJobs[viewerJob] or nil
    local visible = viewJobs and toJobSet(viewJobs) or { [viewerJob:lower()] = true }
    if not visible[targetJob:lower()] then return false end

    if cctvCfg.requireBodycamItem == true then
        local item = type(cctvCfg.bodycamItem) == "string" and cctvCfg.bodycamItem or "bodycam"
        if Sky_Jobs.GetInventoryItemCount(target, item) < 1 then return false end
    end
    return true
end

-- Position and condition of the wearer; durability follows the wearer's health.
local function getBodycamUpdate(target)
    local ped = GetPlayerPed(target)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return nil end

    local c = GetEntityCoords(ped)
    local maxHealth = GetEntityMaxHealth and GetEntityMaxHealth(ped) or 200
    if not maxHealth or maxHealth <= 100 then maxHealth = 200 end
    local ratio = (GetEntityHealth(ped) - 100) / (maxHealth - 100)

    return {
        target = target,
        type = "bodycam",
        status = "online",
        coords = { x = c.x, y = c.y, z = c.z },
        durability = math.floor(math.max(0.0, math.min(1.0, ratio)) * 100 + 0.5)
    }
end

local function sendBodycamOffline(viewer, target)
    TriggerClientEvent("sky_jobs_base:cctv:updateCamera", viewer, { target = target, type = "bodycam", status = "offline" })
end

local function runBodycamScopes()
    if isScopeLoopRunning then return end
    isScopeLoopRunning = true

    CreateThread(function()
        while next(bodycamViewers) do
            for viewer, target in pairs(bodycamViewers) do
                local update = canViewBodycam(viewer, target) and getBodycamUpdate(target)
                if update then
                    TriggerClientEvent("sky_jobs_base:cctv:updateCamera", viewer, update)
                else
                    bodycamViewers[viewer] = nil
                    sendBodycamOffline(viewer, target)
                end
            end
            Wait(1000)
        end
        isScopeLoopRunning = false
    end)
end

-- The viewer may not have the wearer streamed in, so the server feeds the position while watching.
RegisterNetEvent("sky_jobs_base:cctv:bodycamScope", function(target, active)
    local src = source
    target = toInteger(target)
    if active ~= true or not target then
        bodycamViewers[src] = nil
        return
    end
    if isThrottled(src, "cctv:bodycamScope", 100) then return end

    local update = GetPlayerName(target) and canViewBodycam(src, target) and getBodycamUpdate(target)
    if not update then
        bodycamViewers[src] = nil
        sendBodycamOffline(src, target)
        return
    end

    bodycamViewers[src] = target
    TriggerClientEvent("sky_jobs_base:cctv:updateCamera", src, update)
    runBodycamScopes()
end)

-- Asked by the recorder right before a clip upload (bodycam saves and tablet camera clips);
-- without a presignedUrl the CCTV app reports "missing_config".
Sky.Cb.Register("sky_jobs_base:cctv:getVideoConfig", function(source)
    local src = tonumber(source)
    local cctvCfg = Config and Config.Cctv or {}
    if cctvCfg.bodycamRecorderEnabled == false then
        return { success = false, error = "disabled" }
    end
    if not (src and Sky_Jobs.RequireEmployee(src, true)) then
        return { success = false, error = "not_authorized" }
    end

    local bitrate = tonumber(cctvCfg.recordBitrateKbps)
    local data = {
        bufferMinutes = math.max(0, tonumber(cctvCfg.recordBufferMinutes) or 5),
        bitrateKbps = (bitrate and bitrate > 0) and bitrate or 1500
    }
    local job, err = Sky_Jobs.Uploads.Authorize(src, true)
    local presignedUrl
    if job then presignedUrl, err = Sky_Jobs.Uploads.PresignFor(src, "video") end
    if not presignedUrl then return { success = false, error = err, data = data } end
    data.presignedUrl = presignedUrl
    return { success = true, data = data }
end)

-- -----------------------------------------------------
--  EMPLOYEE GPS JAMMER
-- -----------------------------------------------------

--- True while a GPS jammer hides this employee from colleague maps.
---@param source number
---@return boolean
function Sky_Jobs.IsGpsJammed(source)
    local src = tonumber(source)
    return src ~= nil and (jammedUntil[src] or 0) > os.time()
end

RegisterNetEvent("sky_jobs_base:employeeGpsJammer:use", function(data)
    local src = source
    local cfg = Config and Config.EmployeeGpsJammer or {}
    local function reply(reason)
        TriggerClientEvent("sky_jobs_base:employeeGpsJammer:result", src, { success = reason == nil, reason = reason })
    end

    if cfg.enabled == false then return reply("disabled") end
    if isThrottled(src, "gpsJammer", math.max(500, tonumber(cfg.cooldownMs) or 1500)) then return reply("cooldown") end

    local item = type(cfg.item) == "string" and cfg.item or "gps_jammer"
    if item ~= "" and Sky_Jobs.GetInventoryItemCount(src, item) < 1 then return reply("missing_item") end

    local target = toInteger(type(data) == "table" and data.targetId or nil)
    if not target or target == src or not GetPlayerName(target) then return reply("invalid_target") end

    local ownPos, targetPos = getPlayerPosition(src), getPlayerPosition(target)
    if not ownPos or not targetPos then return reply("invalid_target") end
    if getDistance(ownPos, targetPos) > (tonumber(cfg.maxDistance) or 3.0) + 2.0 then return reply("too_far") end

    local targetJob = Sky_Jobs.RequireEmployee(target, true)
    if not targetJob then return reply("not_on_duty") end
    local jammable = toJobSet(cfg.jobs)
    if next(jammable) and not jammable[targetJob:lower()] then return reply("protected_job") end

    if item ~= "" and cfg.consumeOnUse ~= false then
        local removed = false
        if GetResourceState("ox_inventory") == "started" then
            local ok, result = pcall(function()
                return exports.ox_inventory:RemoveItem(src, item, 1)
            end)
            removed = ok and result == true
        elseif GetResourceState("qb-inventory") == "started" then
            local ok, result = pcall(function()
                return exports["qb-inventory"]:RemoveItem(src, item, 1, false, "sky_jobs_base:gps_jammer")
            end)
            removed = ok and result == true
        end
        if not removed then return reply("missing_item") end
    end

    local duration = math.max(1, tonumber(cfg.durationSeconds) or 300)
    jammedUntil[target] = os.time() + duration
    reply(nil)
    TriggerClientEvent("sky_jobs_base:employeeGpsJammer:jammed", target, { durationSeconds = duration })
end)

AddEventHandler("playerDropped", function()
    local src = source
    lastActions[src] = nil
    alertCooldowns[src] = nil
    bodycamViewers[src] = nil
    forwardSpotlights[src] = nil
    jammedUntil[src] = nil
end)
