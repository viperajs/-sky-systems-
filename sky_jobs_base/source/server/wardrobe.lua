if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/wardrobe.lua") end
-- =====================================================
--  sky_jobs_base · source/server/wardrobe.lua
--  Wardrobe & Outfits Database & Server Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}

local civilianOutfitsCache = {}

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

Sky.Cb.Register("sky_jobs_base:wardrobe:getJobMeta", function(source)
    local job = Sky_Jobs.PlayerCache.GetJob(source)
    return {
        success = true,
        data = {
            jobKey = job,
            jobLabel = job
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:getCivilianOutfit", function(source)
    local id = Functions and Functions.GetIdentifier and Functions.GetIdentifier(source) or tostring(source)
    return {
        success = true,
        data = civilianOutfitsCache[id] or nil
    }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:setCivilianOutfit", function(source, outfitData)
    local id = Functions and Functions.GetIdentifier and Functions.GetIdentifier(source) or tostring(source)
    if outfitData then
        civilianOutfitsCache[id] = (type(outfitData) == "string") and json.decode(outfitData) or outfitData
    end
    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:getPermissions", function(source)
    return {
        success = true,
        data = {
            canSave = true,
            canDelete = true
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:getOutfits", function(source)
    local job = Sky_Jobs.PlayerCache.GetJob(source)
    local rows = MySQL.query.await("SELECT * FROM sky_jobs_wardrobe WHERE job = @job", { ["@job"] = job }) or {}

    local list = {}
    for _, row in ipairs(rows) do
        list[#list + 1] = {
            id = row.id,
            name = row.name,
            components = row.components and json.decode(row.components) or {},
            allowedGrades = row.allowed_grades and json.decode(row.allowed_grades) or {}
        }
    end

    return {
        success = true,
        data = {
            outfits = list
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:getOutfit", function(source, outfitId)
    local row = MySQL.single.await("SELECT * FROM sky_jobs_wardrobe WHERE id = @id LIMIT 1", { ["@id"] = outfitId })
    if not row then return { success = false, error = "not_found" } end

    return {
        success = true,
        data = {
            id = row.id,
            name = row.name,
            components = row.components and json.decode(row.components) or {}
        }
    }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:saveOutfit", function(source, outfitId, name, componentsJson, allowedGrades)
    local job = Sky_Jobs.PlayerCache.GetJob(source)

    if outfitId and tonumber(outfitId) and tonumber(outfitId) > 0 then
        MySQL.query.await([[
            UPDATE sky_jobs_wardrobe
            SET name = @name, components = @components, allowed_grades = @allowedGrades
            WHERE id = @id
        ]], {
            ["@name"] = name,
            ["@components"] = componentsJson,
            ["@allowedGrades"] = json.encode(allowedGrades or {}),
            ["@id"] = tonumber(outfitId)
        })
    else
        MySQL.insert.await([[
            INSERT INTO sky_jobs_wardrobe (job, name, components, allowed_grades)
            VALUES (@job, @name, @components, @allowedGrades)
        ]], {
            ["@job"] = job,
            ["@name"] = name,
            ["@components"] = componentsJson,
            ["@allowedGrades"] = json.encode(allowedGrades or {})
        })
    end

    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:wardrobe:deleteOutfit", function(source, outfitId)
    MySQL.query.await("DELETE FROM sky_jobs_wardrobe WHERE id = @id", { ["@id"] = outfitId })
    return { success = true }
end)
