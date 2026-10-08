if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/shop.lua") end
-- =====================================================
--  sky_jobs_base · source/server/shop.lua
--  Wholesale Shop, Public Forms, Multijob & CCTV Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

-- schema.sql used to define sky_jobs_public_forms with other columns (form_type, sender_*);
-- CREATE TABLE IF NOT EXISTS then kept that table and every forms query failed.
local function moveLegacyFormsTable()
    local ok, columns = pcall(MySQL.query.await, "SHOW COLUMNS FROM `sky_jobs_public_forms`")
    if not ok or type(columns) ~= "table" then return true end
    local has = {}
    for _, column in ipairs(columns) do has[column.Field] = true end
    if has.form_type and not has.type then
        return (pcall(MySQL.query.await, "RENAME TABLE `sky_jobs_public_forms` TO `sky_jobs_public_forms_legacy`"))
    end
    return true
end

local function ensureShopTables()
    if not (MySQL and MySQL.query and MySQL.query.await) then return end
    if Config and Config.AutoExecuteQuery == false then return end

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

    if not moveLegacyFormsTable() then
        print("[sky_jobs_base] sky_jobs_public_forms has the old column layout and could not be renamed; public forms will fail until it is migrated.")
    end
    -- Runs on every start (the statements are idempotent); a failed first start used to
    -- mark the tables as created for good.
    for _, q in ipairs(shopTables) do
        local ok, err = pcall(MySQL.query.await, q)
        if not ok then print(("[sky_jobs_base] creating a shop table failed: %s"):format(tostring(err))) end
    end
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

local function getEmployment(src, requireDuty)
    if not Sky_Jobs.GetEmployment then return nil, "unavailable" end
    local job, grade = Sky_Jobs.GetEmployment(src)
    if not job then return nil, "no_job" end
    if requireDuty and not Sky_Jobs.PlayerCache.IsOnDuty(src) then return nil, "not_on_duty" end
    return job, grade
end

local FORM_FIELDS = {
    complaint = { "fullName", "phone", "incidentDate", "incidentTime", "location", "officerName", "badgeNumber", "description", "witnesses", "desiredOutcome" },
    application = { "fullName", "dateOfBirth", "phone", "experience", "availability", "whyJoin" }
}
local FORM_FIELD_MAX = 2000
local FORM_SUBMIT_COOLDOWN = 30

local function buildFormPayload(formType, data)
    local fields = FORM_FIELDS[formType]
    if not fields then return {} end
    local payload = {}
    for _, key in ipairs(fields) do
        local val = data[key]
        if type(val) == "string" then
            payload[key] = val:sub(1, FORM_FIELD_MAX)
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

local MAX_BASKET_LINES = 50
local MAX_LINE_AMOUNT = 500

local function getShopCatalog(job)
    local definition = Sky_Jobs.GetJobDefinition and Sky_Jobs.GetJobDefinition(job)
    local items, byName = {}, {}
    for _, item in ipairs(type(definition) == "table" and type(definition.shop) == "table" and definition.shop or {}) do
        local price = type(item) == "table" and math.floor(tonumber(item.price) or -1) or -1
        if type(item.name) == "string" and item.name ~= "" and price >= 0 and not byName[item.name] then
            local entry = { name = item.name, label = item.label or item.name, price = price, image = type(item.image) == "string" and item.image or nil }
            items[#items + 1] = entry
            byName[item.name] = entry
        end
    end
    return items, byName, definition
end

-- Job, catalogue and definition when the player may use the wholesale point at stationId.
local function openWholesale(src, stationId)
    local job, err = getEmployment(src, false)
    if not job then return nil, err end
    local point, pointErr = Sky_Jobs.FindStationPoint(src, job, stationId, { "wholesale_shop" })
    if not point then return nil, pointErr end
    if point.requiresDuty and not Sky_Jobs.PlayerCache.IsOnDuty(src) then return nil, "not_on_duty" end
    return job
end

Sky.Cb.Register("sky_jobs_base:getWholesaleShopData", function(source, stationId)
    local src = tonumber(source)
    local job, err = openWholesale(src, stationId)
    if not job then return { success = false, error = err } end

    local items, _, definition = getShopCatalog(job)
    local canPurchase = Sky_Jobs.HasJobPermission(src, "PURCHASE_SUPPLIES")
    return {
        success = true,
        data = {
            items = items,
            balance = canPurchase and Sky_Jobs.GetSocietyBalance(job) or 0,
            canPurchase = canPurchase,
            jobColor = type(definition) == "table" and definition.color or nil
        }
    }
end)

local function oxCall(method, ...)
    if GetResourceState("ox_inventory") ~= "started" then return nil end
    local args = table.pack(...)
    local ok, result = pcall(function()
        return exports.ox_inventory[method](exports.ox_inventory, table.unpack(args, 1, args.n))
    end)
    return ok and result or nil
end

Sky.Cb.Register("sky_jobs_base:buyWholesaleItems", function(source, stationId, basket)
    local src = tonumber(source)
    if GetResourceState("ox_inventory") ~= "started" then return { success = false, error = "inventory_unavailable" } end
    local job, err = openWholesale(src, stationId)
    if not job then return { success = false, error = err } end
    if not Sky_Jobs.HasJobPermission(src, "PURCHASE_SUPPLIES") then return { success = false, error = "no_permission" } end
    if type(basket) ~= "table" then return { success = false, error = "empty_basket" } end

    local _, catalog = getShopCatalog(job)
    local lines, byName, total, weight = {}, {}, 0, 0
    for _, wanted in ipairs(basket) do
        local item = type(wanted) == "table" and catalog[wanted.name] or nil
        local amount = type(wanted) == "table" and math.tointeger(tonumber(wanted.amount)) or nil
        if not item or not amount or amount < 1 then return { success = false, error = "invalid_item" } end
        local line = byName[item.name]
        if not line then
            if #lines >= MAX_BASKET_LINES then return { success = false, error = "basket_too_large" } end
            line = { item = item, amount = 0 }
            byName[item.name] = line
            lines[#lines + 1] = line
        end
        line.amount = line.amount + amount
        if line.amount > MAX_LINE_AMOUNT then return { success = false, error = "invalid_amount" } end
    end
    if #lines == 0 then return { success = false, error = "empty_basket" } end

    for _, line in ipairs(lines) do
        local itemData = oxCall("Items", line.item.name)
        if type(itemData) ~= "table" then return { success = false, error = "invalid_item" } end
        if not oxCall("CanCarryItem", src, line.item.name, line.amount) then return { success = false, error = "inventoryFull" } end
        weight = weight + (tonumber(itemData.weight) or 0) * line.amount
        total = total + line.item.price * line.amount
    end
    if not oxCall("CanCarryWeight", src, weight) then return { success = false, error = "inventoryFull" } end

    local actor = Sky_Jobs.GetPlayerFullName and Sky_Jobs.GetPlayerFullName(src) or GetPlayerName(src)
    if total > 0 and not Sky_Jobs.DebitSociety(job, total, "Wholesale purchase", actor) then
        return { success = false, error = "Insufficient society funds." }
    end

    -- Paid first; whatever cannot be delivered is refunded.
    local refund = 0
    for _, line in ipairs(lines) do
        if not oxCall("AddItem", src, line.item.name, line.amount) then
            refund = refund + line.item.price * line.amount
        end
    end
    if refund > 0 then
        Sky_Jobs.CreditSociety(job, refund, "Wholesale refund", actor)
        return { success = false, error = "inventoryFull", data = { balance = Sky_Jobs.GetSocietyBalance(job) } }
    end

    return { success = true, data = { balance = Sky_Jobs.GetSocietyBalance(job) } }
end)

-- ── Public Forms Callbacks ────────────────────────────

local lastFormSubmit = {}

-- The staff member's job must own the form.
local function canManageForm(src, formId)
    local job = getEmployment(src, false)
    if not job or not formId then return false end
    local row = MySQL.single.await("SELECT job_key FROM sky_jobs_public_forms WHERE id = ?", { formId })
    return row ~= nil and row.job_key == job
end

Sky.Cb.Register("sky_jobs_base:publicForms:submit", function(source, data)
    local src = tonumber(source)
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

    -- The job and station come from the kiosk the player stands at, not from the client.
    local stationId = (type(data.stationId) == "string" or type(data.stationId) == "number") and tostring(data.stationId) or nil
    local point, pointErr = Sky_Jobs.FindStationPoint(src, nil, stationId, { "public_forms" }, { anyJob = true })
    if not point then return { success = false, error = pointErr } end
    local jobKey = point.jobKey
    if not jobKey and type(data.jobKey) == "string" and #data.jobKey <= 50 and Sky.FW and Sky.FW.DoesJobExist and Sky.FW.DoesJobExist(data.jobKey) then
        jobKey = data.jobKey
    end
    if not jobKey then return { success = false, error = "unknown_job" } end

    local identifier = GetFormsIdentifier(src)
    local now = os.time()
    if lastFormSubmit[identifier] and now - lastFormSubmit[identifier] < FORM_SUBMIT_COOLDOWN then
        return { success = false, error = "cooldown" }
    end
    lastFormSubmit[identifier] = now

    local formId = MySQL.insert.await([[
        INSERT INTO sky_jobs_public_forms
            (type, job_key, station_id, station_name, citizen_identifier, citizen_name, contact_phone, status, payload)
        VALUES (@type, @job_key, @station_id, @station_name, @citizen_identifier, @citizen_name, @contact_phone, 'new', @payload)
    ]], {
        ["@type"] = formType,
        ["@job_key"] = jobKey,
        ["@station_id"] = stationId,
        ["@station_name"] = type(point.entry.name) == "string" and point.entry.name:sub(1, 150) or nil,
        ["@citizen_identifier"] = identifier,
        ["@citizen_name"] = GetFormsPlayerName(src),
        ["@contact_phone"] = payload.phone and payload.phone:sub(1, 50) or nil,
        ["@payload"] = json.encode(payload)
    })

    if not formId then
        return { success = false, error = "insert_failed" }
    end

    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:publicForms:getAll", function(source)
    local jobKey, err = getEmployment(tonumber(source), false)
    if not jobKey then return { success = false, error = err } end
    if not (MySQL and MySQL.query and MySQL.query.await) then
        return { success = true, data = { forms = {} } }
    end

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
    if not canManageForm(tonumber(source), formId) then
        return { success = false, error = "no_permission" }
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

local function getFormNotes(formId)
    local rows = MySQL.query.await([[
        SELECT id, author_name, content, visible_to_citizen, created_at
        FROM sky_jobs_public_form_notes WHERE form_id = @form_id ORDER BY created_at ASC
    ]], { ["@form_id"] = formId }) or {}

    local notes = {}
    for _, row in ipairs(rows) do
        notes[#notes + 1] = mapNoteRow(row)
    end
    return notes
end

Sky.Cb.Register("sky_jobs_base:publicForms:getNotes", function(source, data)
    data = type(data) == "table" and data or {}
    local formId = tonumber(data.formId)
    if not formId or not (MySQL and MySQL.query and MySQL.query.await) then
        return { success = true, data = { notes = {} } }
    end
    if not canManageForm(tonumber(source), formId) then
        return { success = false, error = "no_permission" }
    end

    return { success = true, data = { notes = getFormNotes(formId) } }
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
    if not canManageForm(tonumber(source), formId) then
        return { success = false, error = "no_permission" }
    end

    MySQL.insert.await([[
        INSERT INTO sky_jobs_public_form_notes (form_id, author_name, content, visible_to_citizen)
        VALUES (@form_id, @author_name, @content, @visible_to_citizen)
    ]], {
        ["@form_id"] = formId,
        ["@author_name"] = GetFormsPlayerName(source),
        ["@content"] = content:sub(1, FORM_FIELD_MAX),
        ["@visible_to_citizen"] = data.visibleToCitizen == true and 1 or 0
    })

    return { success = true, data = { notes = getFormNotes(formId) } }
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

-- ── CCTV & Bodycam Callbacks ──────────────────────────

-- Same rule as cctv:bodycamScope (alerts.lua): wearer on duty, wearer's job visible to the
-- viewer's job (Config.Cctv.bodycamViewJobs, otherwise the own job), bodycam item if required.
local function canViewBodycam(viewerJob, target)
    local targetJob = getEmployment(target, true)
    if not targetJob then return false end

    local cctvCfg = Config and Config.Cctv or {}
    local viewJobs = type(cctvCfg.bodycamViewJobs) == "table" and cctvCfg.bodycamViewJobs[viewerJob] or nil
    local visible = false
    if type(viewJobs) == "table" then
        for _, name in pairs(viewJobs) do
            if type(name) == "string" and name:lower() == targetJob:lower() then visible = true end
        end
    elseif type(viewJobs) == "string" then
        visible = viewJobs:lower() == targetJob:lower()
    else
        visible = viewerJob:lower() == targetJob:lower()
    end
    if not visible then return false end

    if cctvCfg.requireBodycamItem == true then
        local item = type(cctvCfg.bodycamItem) == "string" and cctvCfg.bodycamItem or "bodycam"
        if not Sky_Jobs.GetInventoryItemCount or Sky_Jobs.GetInventoryItemCount(target, item) < 1 then return false end
    end
    return true, targetJob
end

Sky.Cb.Register("sky_jobs_base:cctv:getCameras", function(source)
    local src = tonumber(source)
    local jobKey, err = getEmployment(src, true)
    if not jobKey then return { success = false, error = err } end
    if not (MySQL and MySQL.query and MySQL.query.await) then
        return { success = true, data = { cameras = {} } }
    end

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

    for _, s in ipairs(GetPlayers()) do
        local target = tonumber(s)
        if target and target ~= src and canViewBodycam(jobKey, target) then
            local ped = GetPlayerPed(target)
            local c = ped ~= 0 and GetEntityCoords(ped) or nil
            local name = Sky_Jobs.GetPlayerFullName and Sky_Jobs.GetPlayerFullName(target) or GetPlayerName(target)
            cameras[#cameras + 1] = {
                id = "BC-" .. target,
                target = target,
                type = "bodycam",
                name = name,
                label = name,
                location = name,
                coords = c and { x = c.x, y = c.y, z = c.z } or nil,
                durability = 100,
                status = "online"
            }
        end
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
    if not Sky_Jobs.HasPermission(src, "addcctvcam") then
        TriggerClientEvent("sky_base:notification", src, "CCTV", "You do not have permission to use this command.", "error", 5000)
        return
    end
    if not (MySQL and MySQL.insert and MySQL.insert.await) then return end

    local camType = args[1]
    if camType ~= "cctv" and camType ~= "speedcam" then
        camType = "cctv"
    end

    local name = table.concat(args, " ", 2):sub(1, 100)
    if name == "" then name = camType .. " camera" end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local id = MySQL.insert.await([[
        INSERT INTO sky_jobs_cctv_cameras (type, name, job_key, x, y, z, heading, pitch, durability)
        VALUES (@type, @name, @job_key, @x, @y, @z, @heading, 0, 100)
    ]], {
        ["@type"] = camType,
        ["@name"] = name,
        -- An unemployed admin adds a camera every job sees.
        ["@job_key"] = (Sky_Jobs.GetEmployment and Sky_Jobs.GetEmployment(src)) or nil,
        ["@x"] = coords.x,
        ["@y"] = coords.y,
        ["@z"] = coords.z,
        ["@heading"] = heading
    })

    TriggerClientEvent("sky_base:notification", src, "CCTV", id and ("Camera '%s' added."):format(name) or "Adding the camera failed.", id and "success" or "error", 5000)
end, false)

Sky.Cb.Register("sky_jobs_base:bodycam:getRecordings", function(source)
    local jobKey, err = getEmployment(tonumber(source), true)
    if not jobKey then return { success = false, error = err } end
    if not (MySQL and MySQL.query and MySQL.query.await) then
        return { success = true, data = { recordings = {} } }
    end

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

-- Bodycam clips: the viewer asks (requestSave), the wearer's client records and uploads its
-- buffer (bodycam:saveBuffer), and its result (saveResult) is stored and sent to the viewer.
local BODYCAM_REQUEST_SECONDS = 60
local BODYCAM_COOLDOWN_SECONDS = 10
local pendingBodycamSaves = {}
local lastBodycamRequest = {}

local function cleanText(value, maxChars)
    return type(value) == "string" and value:sub(1, maxChars) or nil
end

RegisterServerEvent("sky_jobs_base:bodycam:requestSave", function(data)
    local src = source
    data = type(data) == "table" and data or {}
    local reqId = cleanText(data.requestId, 64)
    local function reply(err)
        if reqId then
            TriggerClientEvent("sky_jobs_base:cctv:saveResult", src, { requestId = reqId, success = false, error = err })
        end
    end

    local cctvCfg = Config and Config.Cctv or {}
    if cctvCfg.bodycamRecorderEnabled == false then return reply("disabled") end
    if not Sky_Jobs.Uploads.IsConfigured() then return reply("missing_config") end
    local viewerJob = getEmployment(src, true)
    if not viewerJob or not reqId then return reply("not_authorized") end

    local now = os.time()
    if lastBodycamRequest[src] and now - lastBodycamRequest[src] < BODYCAM_COOLDOWN_SECONDS then return reply("busy") end

    local target = tonumber(data.target)
    if not target or not GetPlayerName(target) then return reply("target_not_on_duty") end
    if not getEmployment(target, true) then return reply("target_not_on_duty") end
    if not canViewBodycam(viewerJob, target) then return reply("target_missing_bodycam") end
    lastBodycamRequest[src] = now

    for key, pending in pairs(pendingBodycamSaves) do
        if pending.expires < now then pendingBodycamSaves[key] = nil end
    end

    local key = ("%d:%s"):format(src, reqId)
    pendingBodycamSaves[key] = {
        requester = src,
        requestId = reqId,
        target = target,
        job = viewerJob,
        label = cleanText(data.label, 150),
        location = cleanText(data.location, 150),
        expires = now + BODYCAM_REQUEST_SECONDS
    }

    TriggerClientEvent("sky_jobs_base:bodycam:saveBuffer", target, {
        requestId = key,
        label = pendingBodycamSaves[key].label,
        location = pendingBodycamSaves[key].location,
        cameraId = cleanText(data.cameraId, 64)
    })
end)

RegisterNetEvent("sky_jobs_base:bodycam:saveResult", function(data)
    local src = source
    data = type(data) == "table" and data or {}
    local key = cleanText(data.requestId, 160)
    local pending = key and pendingBodycamSaves[key]
    if not pending or pending.target ~= src or pending.expires < os.time() then return end
    pendingBodycamSaves[key] = nil

    local url = Sky_Jobs.Uploads.IsAllowedUrl(data.url) and data.url or nil
    local err = cleanText(data.error, 64)
    local recordingId
    if data.success == true and url then
        recordingId = MySQL.insert.await([[
            INSERT INTO sky_jobs_bodycam_recordings (job_key, officer_identifier, officer_name, label, location, url)
            VALUES (@job_key, @officer_identifier, @officer_name, @label, @location, @url)
        ]], {
            ["@job_key"] = pending.job,
            ["@officer_identifier"] = GetFormsIdentifier(src),
            ["@officer_name"] = GetFormsPlayerName(src),
            ["@label"] = pending.label,
            ["@location"] = pending.location,
            ["@url"] = url
        })
        if not recordingId then
            err = "insert_failed"
        else
            -- The CCTV app reports "Video saved to gallery."; a full gallery keeps the recording only.
            Sky_Jobs.Gallery.Add(src, pending.job, {
                url = url,
                image_id = data.image_id,
                folder = "cctv",
                media_type = "video",
                metadata = { name = pending.label, description = pending.location }
            })
        end
    elseif data.success == true then
        err = "upload_failed"
    end

    TriggerClientEvent("sky_jobs_base:cctv:saveResult", pending.requester, {
        requestId = pending.requestId,
        success = recordingId ~= nil,
        error = recordingId == nil and (err or "save_failed") or nil,
        id = recordingId,
        url = recordingId and url or nil
    })
end)

AddEventHandler("playerDropped", function()
    local src = source
    lastBodycamRequest[src] = nil
end)
