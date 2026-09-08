if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/server/creator.lua") end
-- =====================================================
--  sky_jobs_base · source/server/creator.lua
--  Workshop, Station & Jail Creator Server Callbacks
-- =====================================================

Sky_Jobs = Sky_Jobs or {}
Sky_Jobs.Creator = Sky_Jobs.Creator or {}

local creatorCache = {}

local function ensureCreatorTable()
    if MySQL and MySQL.query and MySQL.query.await then
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS `sky_jobs_creator_data` (
                `creator_key` VARCHAR(64) NOT NULL,
                `data` LONGTEXT DEFAULT NULL,
                `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`creator_key`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]])
    end
end

CreateThread(function()
    while not MySQL do
        Wait(500)
    end
    ensureCreatorTable()
end)

local function getDefaultWorkshopData()
    return {
        entries = {
            {
                id = "mechanic_lscustoms",
                name = "Los Santos Customs",
                jobKey = "mechanic",
                job = "mechanic",
                storageCapacity = 1000,
                lockerCapacity = 300,
                nitroAccess = true,
                workshopVehicleClasses = {},
                points = {
                    { uid = "lsc_duty", type = "duty", label = "Duty Station", x = -341.0, y = -145.0, z = 39.0, heading = 70.0 },
                    { uid = "lsc_storage", type = "storage", label = "Parts Storage", x = -347.0, y = -133.0, z = 39.0, heading = 70.0 },
                    { uid = "lsc_locker", type = "locker", label = "Employee Lockers", x = -348.0, y = -131.0, z = 39.0, heading = 70.0 },
                    { uid = "lsc_shop", type = "shop", label = "Wholesale Shop", x = -350.0, y = -136.0, z = 39.0, heading = 70.0 },
                    { uid = "lsc_delivery", type = "parts_drop", label = "Delivery Drop", x = -355.0, y = -140.0, z = 39.0, heading = 70.0 },
                    { uid = "lsc_wardrobe", type = "wardrobe", label = "Wardrobe", x = -343.0, y = -148.0, z = 39.0, heading = 70.0 },
                    { uid = "lsc_boss", type = "management", label = "Management", x = -340.0, y = -143.0, z = 39.0, heading = 70.0 },
                    { uid = "lsc_lift_1", type = "lift", label = "Car Lift 1", x = -338.5, y = -136.5, z = 39.0, heading = 70.0, modelSet = "default" },
                    { uid = "lsc_tuning", type = "self_service_tuning", label = "Tuning Area", x = -338.5, y = -136.5, z = 39.0, heading = 70.0 },
                    { uid = "lsc_dyno", type = "dyno", label = "Dyno Stand", x = -330.0, y = -140.0, z = 39.0, heading = 70.0 }
                }
            },
            {
                id = "mechanic_bennys",
                name = "Benny's Original Motor Works",
                jobKey = "mechanic",
                job = "mechanic",
                storageCapacity = 1000,
                lockerCapacity = 300,
                nitroAccess = true,
                workshopVehicleClasses = {},
                points = {
                    { uid = "bennys_duty", type = "duty", label = "Duty Station", x = -205.5, y = -1310.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_storage", type = "storage", label = "Parts Storage", x = -208.0, y = -1315.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_locker", type = "locker", label = "Employee Lockers", x = -210.0, y = -1315.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_shop", type = "shop", label = "Wholesale Shop", x = -215.0, y = -1318.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_delivery", type = "parts_drop", label = "Delivery Drop", x = -220.0, y = -1320.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_wardrobe", type = "wardrobe", label = "Wardrobe", x = -204.0, y = -1320.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_boss", type = "management", label = "Management", x = -207.0, y = -1308.0, z = 31.3, heading = 0.0 },
                    { uid = "bennys_lift_1", type = "lift", label = "Car Lift 1", x = -212.0, y = -1320.0, z = 30.89, heading = 0.0, modelSet = "default" },
                    { uid = "bennys_tuning", type = "self_service_tuning", label = "Tuning Area", x = -212.0, y = -1320.0, z = 30.89, heading = 0.0 },
                    { uid = "bennys_dyno", type = "dyno", label = "Dyno Stand", x = -218.0, y = -1315.0, z = 31.3, heading = 0.0 }
                }
            }
        }
    }
end

-- ── Creator Callbacks ─────────────────────────────────

Sky.Cb.Register("sky_jobs_base:creator:getData", function(source, data)
    local creatorKey = tostring(data and data.creatorKey or "workshopcreator")

    if creatorCache[creatorKey] then
        return {
            success = true,
            data = creatorCache[creatorKey]
        }
    end

    local row = MySQL.single.await("SELECT data FROM sky_jobs_creator_data WHERE creator_key = @key LIMIT 1", {
        ["@key"] = creatorKey
    })

    local creatorData = {}
    if row and row.data then
        local decoded = json.decode(row.data)
        if type(decoded) == "table" and decoded.entries and #decoded.entries > 0 then
            creatorData = decoded
        end
    end

    if (not creatorData.entries or #creatorData.entries == 0) and creatorKey == "workshopcreator" then
        creatorData = getDefaultWorkshopData()
        pcall(function()
            MySQL.query.await([[
                INSERT INTO sky_jobs_creator_data (creator_key, data)
                VALUES (@key, @data)
                ON DUPLICATE KEY UPDATE data = @data
            ]], {
                ["@key"] = creatorKey,
                ["@data"] = json.encode(creatorData)
            })
        end)
    end

    creatorCache[creatorKey] = creatorData

    return {
        success = true,
        data = creatorData
    }
end)

Sky.Cb.Register("sky_jobs_base:creator:saveData", function(source, data)
    local creatorKey = tostring(data and data.creatorKey or "")
    local payload = type(data and data.data) == "table" and data.data or {}

    if creatorKey == "" then
        return { success = false, error = "invalid_key" }
    end

    creatorCache[creatorKey] = payload

    MySQL.query.await([[
        INSERT INTO sky_jobs_creator_data (creator_key, data)
        VALUES (@key, @data)
        ON DUPLICATE KEY UPDATE data = @data
    ]], {
        ["@key"] = creatorKey,
        ["@data"] = json.encode(payload)
    })

    TriggerClientEvent("sky_jobs_base:creator:syncData", -1, creatorKey, payload)

    return { success = true }
end)

Sky.Cb.Register("sky_jobs_base:creator:getPoints", function(source, data)
    local creatorKey = tostring(data and data.creatorKey or "")
    local current = creatorCache[creatorKey] or {}
    return {
        success = true,
        data = current.points or {}
    }
end)
