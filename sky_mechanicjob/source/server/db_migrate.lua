if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/db_migrate.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/db_migrate.lua
--  Automatic Database Schema Migrations & Table Init
-- =====================================================

-- 3: parts deliveries tables from older versions get every column parts_delivery.lua uses.
local SCHEMA_VERSION = "3"
local SCHEMA_VERSION_KVP = "sky_mechanicjob_schema_version"

local function executeSchemaMigrations()
    if Config.AutoExecuteQuery == false then
        Functions.Log("info", "[db_migrate] AutoExecuteQuery is disabled. Skipping database schema migrations.")
        return
    end

    if GetResourceKvpString(SCHEMA_VERSION_KVP) == SCHEMA_VERSION then
        Functions.Log("info", "[db_migrate] Database schema already up to date (v" .. SCHEMA_VERSION .. "). Skipping migrations.")
        return
    end

    Functions.Log("info", "[db_migrate] Checking and initializing database tables...")

    local tables = {
        [[
            CREATE TABLE IF NOT EXISTS `sky_mechanic_vehicle_tuning` (
                `plate` VARCHAR(16) NOT NULL,
                `tuning` LONGTEXT DEFAULT NULL,
                `stance` LONGTEXT DEFAULT NULL,
                `rgb` LONGTEXT DEFAULT NULL,
                `nitro` LONGTEXT DEFAULT NULL,
                `custom_handling` LONGTEXT DEFAULT NULL,
                `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`plate`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_mechanic_stance_defaults` (
                `plate` VARCHAR(16) NOT NULL,
                `stance` LONGTEXT DEFAULT NULL,
                `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`plate`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_mechanic_vehicle_wear` (
                `plate` VARCHAR(16) NOT NULL,
                `mileage` DOUBLE DEFAULT 0,
                `wear` LONGTEXT DEFAULT NULL,
                `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`plate`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_mechanic_orders` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `job` VARCHAR(50) DEFAULT 'mechanic',
                `customer_identifier` VARCHAR(64) DEFAULT NULL,
                `customer_name` VARCHAR(100) DEFAULT NULL,
                `plate` VARCHAR(16) NOT NULL,
                `vehicle_model` VARCHAR(50) DEFAULT NULL,
                `vehicle_label` VARCHAR(100) DEFAULT NULL,
                `items` LONGTEXT DEFAULT NULL,
                `price` INT DEFAULT 0,
                `status` VARCHAR(20) DEFAULT 'pending',
                `paid` TINYINT(1) DEFAULT 1,
                `payment_method` VARCHAR(16) DEFAULT NULL,
                `payer_job` VARCHAR(50) DEFAULT NULL,
                `society_revenue` INT DEFAULT 0,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX `idx_plate` (`plate`),
                INDEX `idx_status` (`status`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_mechanic_parts_deliveries` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `job` VARCHAR(50) DEFAULT 'mechanic',
                `identifier` VARCHAR(64) DEFAULT NULL,
                `delivery_point` LONGTEXT DEFAULT NULL,
                `items` LONGTEXT DEFAULT NULL,
                `total_price` INT DEFAULT 0,
                `status` VARCHAR(20) DEFAULT 'ready',
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_status` (`status`),
                INDEX `idx_job` (`job`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_mechanic_vehicle_registry` (
                `plate` VARCHAR(16) NOT NULL,
                `image_url` TEXT DEFAULT NULL,
                `tags` LONGTEXT DEFAULT NULL,
                `notes` TEXT DEFAULT NULL,
                `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`plate`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_mechanic_vehicle_history` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `plate` VARCHAR(16) NOT NULL,
                `action` VARCHAR(50) NOT NULL,
                `description` TEXT DEFAULT NULL,
                `mechanic_identifier` VARCHAR(64) DEFAULT NULL,
                `mechanic_name` VARCHAR(100) DEFAULT NULL,
                `price` INT DEFAULT 0,
                `date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_plate` (`plate`),
                INDEX `idx_date` (`date`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `sky_mechanic_stolen_catalytics` (
                `plate` VARCHAR(16) NOT NULL,
                `stolen_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (`plate`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]]
    }

    -- The version is only stored when every statement ran, so a failed first boot retries.
    local allOk = true
    local function run(query)
        if not (MySQL and MySQL.query and MySQL.query.await) then
            allOk = false
            return
        end
        local ok, err = pcall(function() MySQL.query.await(query) end)
        if not ok then
            allOk = false
            Functions.Log("error", "[db_migrate] %s", tostring(err))
        end
    end

    for _, query in ipairs(tables) do
        run(query)
    end

    -- Run column migrations in case tables existed from older schemas
    local alterQueries = {
        "ALTER TABLE `sky_mechanic_vehicle_tuning` ADD COLUMN IF NOT EXISTS `tuning` LONGTEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_vehicle_tuning` ADD COLUMN IF NOT EXISTS `stance` LONGTEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_vehicle_tuning` ADD COLUMN IF NOT EXISTS `rgb` LONGTEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_vehicle_tuning` ADD COLUMN IF NOT EXISTS `nitro` LONGTEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_vehicle_tuning` ADD COLUMN IF NOT EXISTS `custom_handling` LONGTEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_vehicle_wear` ADD COLUMN IF NOT EXISTS `mileage` DOUBLE DEFAULT 0",
        "ALTER TABLE `sky_mechanic_vehicle_wear` ADD COLUMN IF NOT EXISTS `wear` LONGTEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_stance_defaults` ADD COLUMN IF NOT EXISTS `stance` LONGTEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_orders` ADD COLUMN IF NOT EXISTS `items` LONGTEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_orders` ADD COLUMN IF NOT EXISTS `paid` TINYINT(1) DEFAULT 1",
        "ALTER TABLE `sky_mechanic_orders` ADD COLUMN IF NOT EXISTS `payment_method` VARCHAR(16) DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_orders` ADD COLUMN IF NOT EXISTS `payer_job` VARCHAR(50) DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_orders` ADD COLUMN IF NOT EXISTS `society_revenue` INT DEFAULT 0",
        "ALTER TABLE `sky_mechanic_parts_deliveries` ADD COLUMN IF NOT EXISTS `items` LONGTEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_parts_deliveries` ADD COLUMN IF NOT EXISTS `job` VARCHAR(50) DEFAULT 'mechanic'",
        "ALTER TABLE `sky_mechanic_parts_deliveries` ADD COLUMN IF NOT EXISTS `identifier` VARCHAR(64) DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_parts_deliveries` ADD COLUMN IF NOT EXISTS `delivery_point` LONGTEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_parts_deliveries` ADD COLUMN IF NOT EXISTS `total_price` INT DEFAULT 0",
        "ALTER TABLE `sky_mechanic_parts_deliveries` ADD COLUMN IF NOT EXISTS `status` VARCHAR(20) DEFAULT 'ready'",
        "ALTER TABLE `sky_mechanic_parts_deliveries` ADD COLUMN IF NOT EXISTS `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP",
        "ALTER TABLE `sky_mechanic_vehicle_history` ADD COLUMN IF NOT EXISTS `action` VARCHAR(50) NOT NULL",
        "ALTER TABLE `sky_mechanic_vehicle_history` ADD COLUMN IF NOT EXISTS `description` TEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_vehicle_history` ADD COLUMN IF NOT EXISTS `mechanic_identifier` VARCHAR(64) DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_vehicle_history` ADD COLUMN IF NOT EXISTS `mechanic_name` VARCHAR(100) DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_vehicle_history` ADD COLUMN IF NOT EXISTS `price` INT DEFAULT 0",
        "ALTER TABLE `sky_mechanic_vehicle_registry` ADD COLUMN IF NOT EXISTS `image_url` TEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_vehicle_registry` ADD COLUMN IF NOT EXISTS `tags` LONGTEXT DEFAULT NULL",
        "ALTER TABLE `sky_mechanic_vehicle_registry` ADD COLUMN IF NOT EXISTS `notes` TEXT DEFAULT NULL"
    }

    for _, alterQuery in ipairs(alterQueries) do
        run(alterQuery)
    end

    if not allOk then
        Functions.Log("warn", "[db_migrate] Some schema statements failed; they are retried on the next start.")
        return
    end
    SetResourceKvp(SCHEMA_VERSION_KVP, SCHEMA_VERSION)

    if Functions and Functions.Log then
        Functions.Log("info", "[db_migrate] Database tables verified successfully.")
    else
        print("[INFO] [db_migrate] Database tables verified successfully.")
    end
end

CreateThread(function()
    while not MySQL do
        Wait(500)
    end
    if MySQL.ready then
        MySQL.ready(function()
            CreateThread(function()
                executeSchemaMigrations()
            end)
        end)
    else
        Wait(1000)
        executeSchemaMigrations()
    end
end)
