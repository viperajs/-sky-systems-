-- ============================================================================
--  SKY SYSTEMS · COMPLETE DATABASE SCHEMA
--  Database tables for sky_base, sky_jobs_base, and sky_mechanicjob
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------------------
--  1. MECHANIC JOB: VEHICLE TUNING & PERSISTENCE
-- ----------------------------------------------------------------------------

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

CREATE TABLE IF NOT EXISTS `sky_mechanic_stance_defaults` (
    `plate` VARCHAR(16) NOT NULL,
    `stance` LONGTEXT DEFAULT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_mechanic_vehicle_wear` (
    `plate` VARCHAR(16) NOT NULL,
    `mileage` DOUBLE DEFAULT 0,
    `wear` LONGTEXT DEFAULT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
--  2. MECHANIC JOB: ORDERS, DELIVERIES, REGISTRY & HISTORY
-- ----------------------------------------------------------------------------

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

CREATE TABLE IF NOT EXISTS `sky_mechanic_vehicle_registry` (
    `plate` VARCHAR(16) NOT NULL,
    `image_url` TEXT DEFAULT NULL,
    `tags` LONGTEXT DEFAULT NULL,
    `notes` TEXT DEFAULT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

CREATE TABLE IF NOT EXISTS `sky_mechanic_stolen_catalytics` (
    `plate` VARCHAR(16) NOT NULL,
    `stolen_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
--  3. JOBS BASE: CREATOR DATA, WARDROBE & GARAGE
--  sky_jobs_base also creates these tables on start; keep both definitions equal.
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `sky_jobs_creator_data` (
    `creator_key` VARCHAR(64) NOT NULL,
    `data` LONGTEXT DEFAULT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`creator_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_jobs_wardrobe` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `job` VARCHAR(50) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `components` LONGTEXT DEFAULT NULL,
    `allowed_grades` LONGTEXT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_jobs_garage_vehicles` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `job` VARCHAR(50) NOT NULL,
    `plate` VARCHAR(16) NOT NULL,
    `model` VARCHAR(64) NOT NULL,
    `name` VARCHAR(100) DEFAULT NULL,
    `garage_type` VARCHAR(20) NOT NULL DEFAULT 'vehicle',
    `state` VARCHAR(16) NOT NULL DEFAULT 'stored',
    `props` LONGTEXT DEFAULT NULL,
    `fuel` FLOAT DEFAULT 100,
    `purchase_price` INT NOT NULL DEFAULT 0,
    `last_driver` VARCHAR(100) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_plate` (`plate`),
    INDEX `idx_job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Storage, locker and job-vehicle trunk contents are ox_inventory stashes
-- (skyjobs_st_*, skyjobs_lk_*, skyjobs_tr_*) in ox_inventory's own table.

-- ----------------------------------------------------------------------------
--  4. JOBS BASE: FINANCES, TRANSACTIONS, CHAT & CALENDAR
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `sky_jobs_finances` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `job` VARCHAR(50) NOT NULL,
    `balance` INT DEFAULT 0,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_jobs_transactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `job` VARCHAR(50) NOT NULL,
    `type` VARCHAR(20) NOT NULL,
    `amount` INT NOT NULL,
    `sender` VARCHAR(100) DEFAULT NULL,
    `reason` TEXT DEFAULT NULL,
    `date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_job` (`job`),
    INDEX `idx_date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_jobs_chat_messages` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `chat_id` VARCHAR(160) NOT NULL,
    `sender_identifier` VARCHAR(64) DEFAULT NULL,
    `recipient_identifier` VARCHAR(64) DEFAULT NULL,
    `sender_name` VARCHAR(100) NOT NULL,
    `message` TEXT NOT NULL,
    `timestamp` BIGINT NOT NULL,
    `is_read` TINYINT(1) NOT NULL DEFAULT 0,
    INDEX `idx_chat` (`chat_id`),
    INDEX `idx_recipient` (`recipient_identifier`, `is_read`),
    INDEX `idx_sender` (`sender_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_jobs_chat_groups` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `job` VARCHAR(50) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `created_by` VARCHAR(64) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_jobs_chat_group_members` (
    `group_id` VARCHAR(64) NOT NULL,
    `identifier` VARCHAR(64) NOT NULL,
    PRIMARY KEY (`group_id`, `identifier`),
    INDEX `idx_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_jobs_calendar_events` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `job` VARCHAR(50) NOT NULL,
    `title` VARCHAR(150) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `date` VARCHAR(50) NOT NULL,
    `time` VARCHAR(20) DEFAULT NULL,
    `color` VARCHAR(16) DEFAULT NULL,
    `created_by` VARCHAR(64) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_jobs_grade_permissions` (
    `job` VARCHAR(50) NOT NULL,
    `grade` INT NOT NULL,
    `permissions` LONGTEXT DEFAULT NULL,
    `restrictions` LONGTEXT DEFAULT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`job`, `grade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
--  5. JOBS BASE: PUBLIC FORMS, CCTV & BODYCAM
-- ----------------------------------------------------------------------------

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

CREATE TABLE IF NOT EXISTS `sky_jobs_public_form_notes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `form_id` INT NOT NULL,
    `author_name` VARCHAR(100) DEFAULT NULL,
    `content` TEXT NOT NULL,
    `visible_to_citizen` TINYINT(1) DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_form` (`form_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

SET FOREIGN_KEY_CHECKS = 1;
