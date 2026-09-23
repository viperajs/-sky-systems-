if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/shop.lua") end
-- =====================================================
--  sky_jobs_base · source/server/shop.lua
--  Wholesale Shop, Public Forms, Multijob & CCTV Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

local SHOP_SCHEMA_VERSION = "1"
local SHOP_SCHEMA_VERSION_KVP = "sky_jobs_base_shop_schema_version"

local function ensureShopTables()
    if not (MySQL and MySQL.query and MySQL.query.await) then return end
    if GetResourceKvpString(SHOP_SCHEMA_VERSION_KVP) == SHOP_SCHEMA_VERSION then return end

    local shopTables = {
        [[
            CREATE TABLE IF NOT EXISTS `sky_jobs_public_forms` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `type` VARCHAR(20) NOT NULL,
                `job_key` VARCHAR(50) NOT NULL,
                `station_id` VARCHAR(64) DEFAULT NULL,
                `station_name` VARCHAR(150) DEFAULT NULL,
                `citizen_identifier` VARCHAR(64) DEFAULT NULL,
                `citizen_name` VARCHAR(100) DEFAULT NULL,
                `contact_phone` VARCHAR(50) DEFAULT NULL,
                `status` VARCHAR(20) NOT NULL DEFAULT 'new',
                `payload` LONGTEXT DEFAULT NULL,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_job` (`job_key`),
                INDEX `idx_citizen` (`citizen_identifier`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_jobs_public_form_notes` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `form_id` INT NOT NULL,
                `author_name` VARCHAR(100) DEFAULT NULL,
                `content` TEXT NOT NULL,
                `visible_to_citizen` TINYINT(1) DEFAULT 0,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_form` (`form_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_jobs_cctv_cameras` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `type` VARCHAR(20) NOT NULL DEFAULT 'cctv',
                `name` VARCHAR(100) NOT NULL,
                `job_key` VARCHAR(50) DEFAULT NULL,
                `x` FLOAT NOT NULL,
                `y` FLOAT NOT NULL,
                `z` FLOAT NOT NULL,
                `heading` FLOAT DEFAULT 0,
                `pitch` FLOAT DEFAULT 0,
                `durability` INT DEFAULT 100,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_job` (`job_key`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_jobs_bodycam_recordings` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `job_key` VARCHAR(50) DEFAULT NULL,
                `officer_identifier` VARCHAR(64) DEFAULT NULL,
                `officer_name` VARCHAR(100) DEFAULT NULL,
                `label` VARCHAR(150) DEFAULT NULL,
                `location` VARCHAR(150) DEFAULT NULL,
                `url` TEXT DEFAULT NULL,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_job` (`job_key`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]]
    }

    for _, q in ipairs(shopTables) do
        pcall(function() MySQL.query.await(q) end)
    end

    SetResourceKvp(SHOP_SCHEMA_VERSION_KVP, SHOP_SCHEMA_VERSION)
end

CreateThread(function()
    while not MySQL do
        Wait(500)
    end
    ensureShopTables()
end)

local function GetFormsIdentifier(source)
    local src = tonumber(source)
    if not src then return "" end
    if Sky and Sky.FW and Sky.FW.GetIdentifier then
        local id = Sky.FW.GetIdentifier(src)
        if id and id ~= "" then return tostring(id) end
    end
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if string.find(id, "license:") or string.find(id, "steam:") then
            return id
        end
    end
    return "player:" .. tostring(src)
end

local function GetFormsPlayerName(source)
    local src = tonumber(source)
    if not src then return "Unknown" end
    if Sky and Sky.FW and Sky.FW.GetName then
        local name = Sky.FW.GetName(src)
        if name and name ~= "" then return tostring(name) end
    end
    return GetPlayerName(src) or ("Player " .. tostring(src))
end

local FORM_FIELDS = {
    complaint = { "fullName", "phone", "incidentDate", "incidentTime", "location", "officerName", "badgeNumber", "description", "witnesses", "desiredOutcome" },
    application = { "fullName", "dateOfBirth", "phone", "experience", "availability", "whyJoin" }
}

local function buildFormPayload(formType, data)
    local fields = FORM_FIELDS[formType]
    if not fields then return {} end
    local payload = {}
    for _, key in ipairs(fields) do
        local val = data[key]
        if type(val) == "string" then
            payload[key] = val
        end
    end
    return payload
end

local function mapFormRow(row)
    if not row then return nil end
    local payload = {}
    if type(row.payload) == "string" and row.payload ~= "" then
        local ok, decoded = pcall(json.decode, row.payload)
        if ok and type(decoded) == "table" then payload = decoded end
    end
    return {
        id = row.id,
        type = row.type,
        status = row.status,
        jobKey = row.job_key,
        stationId = row.station_id,
        stationName = row.station_name,
        citizenName = row.citizen_name,
        contactPhone = row.contact_phone,
        payload = payload,
        created_at = row.created_at
    }
end

local function mapNoteRow(row)
    if not row then return nil end
    return {
        id = row.id,
        authorName = row.author_name,
        content = row.content,
        visibleToCitizen = row.visible_to_citizen == 1,
        created_at = row.created_at
    }
end

-- ── Wholesale Shop ────────────────────────────────────

Sky.Cb.Register("sky_jobs_base:getWholesaleShopData", function(source, stationId)
    local job = Sky_Jobs.PlayerCache.GetJob(source)
    local items = (Config and Config.Jobs and Config.Jobs[job] and Config.Jobs[job].shop) or {}

    return {
        success = true,
        data = {
            items = items
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:buyWholesaleItems", function(source, stationId, items)
    return { success = true }
end)

-- ── Public Forms Callbacks ────────────────────────────

Sky.Cb.Register("sky_jobs_base:publicForms:submit", function(source, data)
    data = type(data) == "table" and data or {}
    local formType = data.type
    if formType ~= "complaint" and formType ~= "application" then
        return { success = false, error = "invalid_form_type" }
    end
    if not (MySQL and MySQL.insert and MySQL.insert.await) then
        return { success = false, error = "database_unavailable" }
    end

    local payload = buildFormPayload(formType, data)
    local fullName = payload.fullName
    if type(fullName) ~= "string" or fullName:gsub("%s+", "") == "" then
        return { success = false, error = "missing_full_name" }
    end
    if formType == "complaint" and (type(payload.description) ~= "string" or payload.description:gsub("%s+", "") == "") then
        return { success = false, error = "missing_description" }
    end
    if formType == "application" and (type(payload.whyJoin) ~= "string" or payload.whyJoin:gsub("%s+", "") == "") then
        return { success = false, error = "missing_why_join" }
    end

    local jobKey = (type(data.jobKey) == "string" and data.jobKey ~= "") and data.jobKey or Sky_Jobs.PlayerCache.GetJob(source)
    local stationId = data.stationId ~= nil and tostring(data.stationId) or nil

    local formId = MySQL.insert.await([[
        INSERT INTO sky_jobs_public_forms
            (type, job_key, station_id, citizen_identifier, citizen_name, contact_phone, status, payload)
        VALUES (@type, @job_key, @station_id, @citizen_identifier, @citizen_name, @contact_phone, 'new', @payload)
    ]], {
        ["@type"] = formType,
        ["@job_key"] = jobKey or "",
        ["@station_id"] = stationId,
        ["@citizen_identifier"] = GetFormsIdentifier(source),
        ["@citizen_name"] = GetFormsPlayerName(source),
        ["@contact_phone"] = payload.phone,
        ["@payload"] = json.encode(payload)
    })

    if not formId then
        return { success = false, error = "insert_failed" }
    end

    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:getAll", function(source)
    if not (MySQL and MySQL.query and MySQL.query.await) then
        return { success = true, data = { forms = {} } }
    end

    local jobKey = Sky_Jobs.PlayerCache.GetJob(source)
    local rows = MySQL.query.await([[
        SELECT id, type, job_key, station_id, station_name, citizen_name, contact_phone, status, payload, created_at
        FROM sky_jobs_public_forms
        WHERE job_key = @job_key
        ORDER BY created_at DESC
    ]], { ["@job_key"] = jobKey }) or {}

    local forms = {}
    for _, row in ipairs(rows) do
        forms[#forms + 1] = mapFormRow(row)
    end

    return { success = true, data = { forms = forms } }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:updateStatus", function(source, data)
    data = type(data) == "table" and data or {}
    local formId = tonumber(data.formId)
    local status = data.status
    if not formId or (status ~= "new" and status ~= "reviewed" and status ~= "archived") then
        return { success = false, error = "invalid_request" }
    end
    if not (MySQL and MySQL.update and MySQL.update.await and MySQL.single and MySQL.single.await) then
        return { success = false, error = "database_unavailable" }
    end

    MySQL.update.await("UPDATE sky_jobs_public_forms SET status = @status WHERE id = @id", {
        ["@status"] = status,
        ["@id"] = formId
    })

    local row = MySQL.single.await([[
        SELECT id, type, job_key, station_id, station_name, citizen_name, contact_phone, status, payload, created_at
        FROM sky_jobs_public_forms WHERE id = @id
    ]], { ["@id"] = formId })

    if not row then
        return { success = false, error = "not_found" }
    end

    return { success = true, data = { form = mapFormRow(row) } }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:getNotes", function(source, data)
    data = type(data) == "table" and data or {}
    local formId = tonumber(data.formId)
    if not formId or not (MySQL and MySQL.query and MySQL.query.await) then
        return { success = true, data = { notes = {} } }
    end

    local rows = MySQL.query.await([[
        SELECT id, author_name, content, visible_to_citizen, created_at
        FROM sky_jobs_public_form_notes WHERE form_id = @form_id ORDER BY created_at ASC
    ]], { ["@form_id"] = formId }) or {}

    local notes = {}
    for _, row in ipairs(rows) do
        notes[#notes + 1] = mapNoteRow(row)
    end

    return { success = true, data = { notes = notes } }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:addNote", function(source, data)
    data = type(data) == "table" and data or {}
    local formId = tonumber(data.formId)
    local content = type(data.content) == "string" and data.content:gsub("^%s+", ""):gsub("%s+$", "") or ""
    if not formId or content == "" then
        return { success = false, error = "invalid_request" }
    end
    if not (MySQL and MySQL.insert and MySQL.insert.await and MySQL.query and MySQL.query.await) then
        return { success = false, error = "database_unavailable" }
    end

    MySQL.insert.await([[
        INSERT INTO sky_jobs_public_form_notes (form_id, author_name, content, visible_to_citizen)
        VALUES (@form_id, @author_name, @content, @visible_to_citizen)
    ]], {
        ["@form_id"] = formId,
        ["@author_name"] = GetFormsPlayerName(source),
        ["@content"] = content,
        ["@visible_to_citizen"] = data.visibleToCitizen == true and 1 or 0
    })

    local rows = MySQL.query.await([[
        SELECT id, author_name, content, visible_to_citizen, created_at
        FROM sky_jobs_public_form_notes WHERE form_id = @form_id ORDER BY created_at ASC
    ]], { ["@form_id"] = formId }) or {}

    local notes = {}
    for _, row in ipairs(rows) do
        notes[#notes + 1] = mapNoteRow(row)
    end

    return { success = true, data = { notes = notes } }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:getMyForms", function(source, data)
    if not (MySQL and MySQL.query and MySQL.query.await) then
        return { success = true, data = { forms = {} } }
    end

    local rows = MySQL.query.await([[
        SELECT id, type, job_key, station_id, station_name, citizen_name, contact_phone, status, payload, created_at
        FROM sky_jobs_public_forms
        WHERE citizen_identifier = @citizen_identifier
        ORDER BY created_at DESC
    ]], { ["@citizen_identifier"] = GetFormsIdentifier(source) }) or {}

    local forms = {}
    for _, row in ipairs(rows) do
        forms[#forms + 1] = mapFormRow(row)
    end

    return { success = true, data = { forms = forms } }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:getMyNotes", function(source, data)
    data = type(data) == "table" and data or {}
    local formId = tonumber(data.formId)
    if not formId or not (MySQL and MySQL.single and MySQL.single.await and MySQL.query and MySQL.query.await) then
        return { success = true, data = { notes = {} } }
    end

    -- Only expose notes for forms the requesting citizen actually submitted.
    local owned = MySQL.single.await("SELECT id FROM sky_jobs_public_forms WHERE id = @id AND citizen_identifier = @citizen_identifier", {
        ["@id"] = formId,
        ["@citizen_identifier"] = GetFormsIdentifier(source)
    })
    if not owned then
        return { success = false, error = "not_found" }
    end

    local rows = MySQL.query.await([[
        SELECT id, author_name, content, visible_to_citizen, created_at
        FROM sky_jobs_public_form_notes
        WHERE form_id = @form_id AND visible_to_citizen = 1
        ORDER BY created_at ASC
    ]], { ["@form_id"] = formId }) or {}

    local notes = {}
    for _, row in ipairs(rows) do
        notes[#notes + 1] = mapNoteRow(row)
    end

    return { success = true, data = { notes = notes } }
end)

-- ── Multijob Callbacks ────────────────────────────────

Sky.Cb.Register("sky_jobs_base:multijob:getSnapshot", function(source, data)
    local job = Sky_Jobs.PlayerCache.GetJob(source)
    return {
        success = true,
        data = {
            currentJob = job,
            jobs = {
                { name = job, label = job, grade = Sky_Jobs.PlayerCache.GetJobGrade(source), onDuty = Sky_Jobs.PlayerCache.IsOnDuty(source) }
            }
        }
    }
end)

-- ── Alerts, CCTV & Bodycam Callbacks ─────────────────

Sky.Cb.Register("sky_jobs_base:alerts:getActive", function(source)
    return {
        success = true,
        data = {}
    }
end)

Sky.Cb.Register("sky_jobs_base:cctv:getCameras", function(source)
    if not (MySQL and MySQL.query and MySQL.query.await) then
        return { success = true, data = { cameras = {} } }
    end

    local jobKey = Sky_Jobs.PlayerCache.GetJob(source)
    local rows = MySQL.query.await([[
        SELECT id, type, name, job_key, x, y, z, heading, pitch, durability
        FROM sky_jobs_cctv_cameras
        WHERE job_key IS NULL OR job_key = '' OR job_key = @job_key
        ORDER BY name ASC
    ]], { ["@job_key"] = jobKey }) or {}

    local cameras = {}
    for _, row in ipairs(rows) do
        cameras[#cameras + 1] = {
            id = row.id,
            target = row.id,
            type = row.type,
            name = row.name,
            location = row.name,
            coords = { x = row.x, y = row.y, z = row.z },
            heading = row.heading,
            pitch = row.pitch,
            durability = row.durability,
            status = "online"
        }
    end

    return { success = true, data = { cameras = cameras } }
end)

-- Registers a fixed surveillance/speed camera at the calling player's current
-- position. `sky_policejob:cctvcam:adjustView` (a separate resource, not part
-- of this repo) still owns live swivel/view-adjust for `cctv`-type cameras;
-- if that resource isn't installed the swivel controls simply no-op.
RegisterCommand("addcctvcam", function(source, args)
    local src = tonumber(source)
    if not src or src == 0 then
        print("[sky_jobs_base] addcctvcam must be run in-game, standing at the camera location.")
        return
    end
    if not (MySQL and MySQL.insert and MySQL.insert.await) then return end

    local camType = args[1]
    if camType ~= "cctv" and camType ~= "speedcam" then
        camType = "cctv"
    end

    local name = table.concat(args, " ", 2)
    if name == "" then name = camType .. " camera" end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    MySQL.insert.await([[
        INSERT INTO sky_jobs_cctv_cameras (type, name, job_key, x, y, z, heading, pitch, durability)
        VALUES (@type, @name, @job_key, @x, @y, @z, @heading, 0, 100)
    ]], {
        ["@type"] = camType,
        ["@name"] = name,
        ["@job_key"] = Sky_Jobs.PlayerCache.GetJob(src),
        ["@x"] = coords.x,
        ["@y"] = coords.y,
        ["@z"] = coords.z,
        ["@heading"] = heading
    })

    print(("[sky_jobs_base] addcctvcam registered a %s camera '%s' for %s"):format(camType, name, src))
end, false)

Sky.Cb.Register("sky_jobs_base:bodycam:getRecordings", function(source)
    if not (MySQL and MySQL.query and MySQL.query.await) then
        return { success = true, data = { recordings = {} } }
    end

    local jobKey = Sky_Jobs.PlayerCache.GetJob(source)
    local rows = MySQL.query.await([[
        SELECT id, officer_name, label, location, url, created_at
        FROM sky_jobs_bodycam_recordings
        WHERE job_key = @job_key
        ORDER BY created_at DESC
        LIMIT 200
    ]], { ["@job_key"] = jobKey }) or {}

    local recordings = {}
    for _, row in ipairs(rows) do
        recordings[#recordings + 1] = {
            id = row.id,
            officerName = row.officer_name,
            label = row.label,
            location = row.location,
            url = row.url,
            created_at = row.created_at
        }
    end

    return { success = true, data = { recordings = recordings } }
end)

-- No server handler previously existed for this request at all, so a save
-- request from the CCTV app silently went nowhere. This persists the
-- recording's metadata; `url` stays NULL until a real video storage
-- provider (S3/R2/webhook) is wired in, since no such provider exists
-- anywhere in this codebase to fabricate a working upload against.
RegisterServerEvent("sky_jobs_base:bodycam:requestSave", function(data)
    local src = source
    data = type(data) == "table" and data or {}
    local reqId = data.requestId

    if not (MySQL and MySQL.insert and MySQL.insert.await) then
        if reqId then
            TriggerClientEvent("sky_jobs_base:cctv:saveResult", src, { requestId = reqId, success = false, error = "database_unavailable" })
        end
        return
    end

    local recordingId = MySQL.insert.await([[
        INSERT INTO sky_jobs_bodycam_recordings (job_key, officer_identifier, officer_name, label, location)
        VALUES (@job_key, @officer_identifier, @officer_name, @label, @location)
    ]], {
        ["@job_key"] = Sky_Jobs.PlayerCache.GetJob(src),
        ["@officer_identifier"] = GetFormsIdentifier(src),
        ["@officer_name"] = GetFormsPlayerName(src),
        ["@label"] = data.label,
        ["@location"] = data.location
    })

    if reqId then
        TriggerClientEvent("sky_jobs_base:cctv:saveResult", src, {
            requestId = reqId,
            success = recordingId ~= nil,
            error = recordingId == nil and "insert_failed" or nil,
            id = recordingId
        })
    end
end)
