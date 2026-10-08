if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/wardrobe.lua") end
-- =====================================================
--  sky_jobs_base · source/server/wardrobe.lua
--  Wardrobe & Outfits Database & Server Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

local MAX_OUTFIT_JSON = 16384
local civilianOutfitsCache = {}
local civilianKeyBySource = {}

local function ensureWardrobeTable()
    if MySQL and MySQL.query and MySQL.query.await then
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS `sky_jobs_wardrobe` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `job` VARCHAR(50) NOT NULL,
                `name` VARCHAR(100) NOT NULL,
                `components` LONGTEXT DEFAULT NULL,
                `allowed_grades` LONGTEXT DEFAULT NULL,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]])
    end
end

CreateThread(function()
    while not MySQL do
        Wait(500)
    end
    ensureWardrobeTable()
end)

local function getEmployment(src)
    if not Sky_Jobs.GetEmployment then return nil end
    return Sky_Jobs.GetEmployment(src)
end

local function decodeTable(text)
    if type(text) ~= "string" or text == "" then return nil end
    local ok, value = pcall(json.decode, text)
    return ok and type(value) == "table" and value or nil
end

local function gradeAllowed(allowedGrades, grade)
    if type(allowedGrades) ~= "table" or next(allowedGrades) == nil then return true end
    for _, g in pairs(allowedGrades) do
        if tonumber(g) == grade then return true end
    end
    return false
end

local function getJobGrades(job)
    local jobs = Sky.FW and Sky.FW.GetJobs and Sky.FW.GetJobs() or nil
    local grades = type(jobs) == "table" and type(jobs[job]) == "table" and jobs[job].grades or nil
    local list = {}
    for key, g in pairs(type(grades) == "table" and grades or {}) do
        local level = tonumber(type(g) == "table" and g.grade or nil) or tonumber(key)
        if level then
            list[#list + 1] = { grade = level, label = type(g) == "table" and (g.label or g.name) or tostring(level) }
        end
    end
    table.sort(list, function(a, b) return a.grade < b.grade end)
    return list
end

local function civilianKey(src)
    return Sky_Jobs.GetPlayerIdentifier and Sky_Jobs.GetPlayerIdentifier(src) or nil
end

Sky.Cb.Register("sky_jobs_base:wardrobe:getJobMeta", function(source)
    local job = getEmployment(tonumber(source))
    if not job then return { success = false, error = "no_job" } end
    local definition = Sky_Jobs.GetJobDefinition and Sky_Jobs.GetJobDefinition(job)
    return {
        success = true,
        data = {
            jobKey = job,
            jobLabel = type(definition) == "table" and definition.label or job,
            jobColor = type(definition) == "table" and definition.color or nil
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:getCivilianOutfit", function(source)
    local key = civilianKey(tonumber(source))
    return {
        success = true,
        data = key and civilianOutfitsCache[key] or nil
    }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:setCivilianOutfit", function(source, outfitData)
    local key = civilianKey(tonumber(source))
    if not key then return { success = false, error = "no_identifier" } end
    local outfit = outfitData
    if type(outfitData) == "string" then
        if #outfitData > MAX_OUTFIT_JSON then return { success = false, error = "too_large" } end
        outfit = decodeTable(outfitData)
    elseif type(outfitData) == "table" then
        local ok, text = pcall(json.encode, outfitData)
        if not ok or #text > MAX_OUTFIT_JSON then return { success = false, error = "too_large" } end
    end
    if type(outfit) ~= "table" then return { success = false, error = "invalid_outfit" } end
    civilianOutfitsCache[key] = outfit
    civilianKeyBySource[tonumber(source)] = key
    return { success = true, stored = true }
end)

AddEventHandler("playerDropped", function()
    local key = civilianKeyBySource[source]
    civilianKeyBySource[source] = nil
    if key then civilianOutfitsCache[key] = nil end
end)

-- Permission keys the cloakroom UI checks with permissions.includes(...).
Sky.Cb.Register("sky_jobs_base:wardrobe:getPermissions", function(source)
    local src = tonumber(source)
    local list = {}
    if getEmployment(src) then
        if Sky_Jobs.HasJobPermission(src, "CREATE_OUTFITS") then list[#list + 1] = "create_outfits" end
        if Sky_Jobs.HasJobPermission(src, "EDIT_OUTFITS") then list[#list + 1] = "edit_outfits" end
        if Sky_Jobs.HasJobPermission(src, "DELETE_OUTFITS") then list[#list + 1] = "delete_outfits" end
    end
    return { success = true, data = list }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:getOutfits", function(source)
    local job, grade = getEmployment(tonumber(source))
    if not job then return { success = false, error = "no_job" } end
    local rows = MySQL.query.await("SELECT id, name, allowed_grades FROM sky_jobs_wardrobe WHERE job = @job", { ["@job"] = job }) or {}

    local list = {}
    for _, row in ipairs(rows) do
        local allowedGrades = decodeTable(row.allowed_grades) or {}
        list[#list + 1] = {
            id = row.id,
            name = row.name,
            allowedGrades = allowedGrades,
            selectable = gradeAllowed(allowedGrades, grade)
        }
    end

    return {
        success = true,
        data = list,
        jobGrades = getJobGrades(job),
        playerGrade = grade
    }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:getOutfit", function(source, outfitId)
    local src = tonumber(source)
    local job, grade = getEmployment(src)
    if not job then return { success = false, error = "no_job" } end
    local row = MySQL.single.await("SELECT * FROM sky_jobs_wardrobe WHERE id = @id AND job = @job LIMIT 1", { ["@id"] = tonumber(outfitId), ["@job"] = job })
    if not row then return { success = false, error = "not_found" } end
    if not gradeAllowed(decodeTable(row.allowed_grades), grade) and not Sky_Jobs.HasJobPermission(src, "EDIT_OUTFITS") then
        return { success = false, error = "no_permission" }
    end

    return { success = true, data = decodeTable(row.components) or {} }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:saveOutfit", function(source, outfitId, name, componentsJson, allowedGrades)
    local src = tonumber(source)
    local job = getEmployment(src)
    if not job then return { success = false, error = "no_job" } end
    local id = math.tointeger(tonumber(outfitId)) or 0
    if not Sky_Jobs.HasJobPermission(src, id > 0 and "EDIT_OUTFITS" or "CREATE_OUTFITS") then
        return { success = false, error = "no_permission" }
    end

    name = type(name) == "string" and name:gsub("^%s+", ""):gsub("%s+$", "") or ""
    if name == "" or #name > 100 then return { success = false, error = "invalid_name" } end
    if type(componentsJson) ~= "string" or #componentsJson > MAX_OUTFIT_JSON then return { success = false, error = "invalid_outfit" } end
    local components = decodeTable(componentsJson)
    if not components then return { success = false, error = "invalid_outfit" } end

    local grades = {}
    for _, g in ipairs(type(allowedGrades) == "table" and allowedGrades or {}) do
        local level = math.tointeger(tonumber(g))
        if level and level >= 0 and level <= 100 and #grades < 50 then grades[#grades + 1] = level end
    end

    if id > 0 then
        local changed = MySQL.update.await("UPDATE sky_jobs_wardrobe SET name = ?, components = ?, allowed_grades = ? WHERE id = ? AND job = ?", {
            name, json.encode(components), json.encode(grades), id, job
        })
        if (changed or 0) < 1 then return { success = false, error = "not_found" } end
    else
        MySQL.insert.await("INSERT INTO sky_jobs_wardrobe (job, name, components, allowed_grades) VALUES (?, ?, ?, ?)", {
            job, name, json.encode(components), json.encode(grades)
        })
    end

    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:deleteOutfit", function(source, outfitId)
    local src = tonumber(source)
    local job = getEmployment(src)
    if not job then return { success = false, error = "no_job" } end
    if not Sky_Jobs.HasJobPermission(src, "DELETE_OUTFITS") then return { success = false, error = "no_permission" } end
    local removed = MySQL.update.await("DELETE FROM sky_jobs_wardrobe WHERE id = ? AND job = ?", { tonumber(outfitId), job })
    if (removed or 0) < 1 then return { success = false, error = "not_found" } end
    return { success = true }
end)
