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
--  3. JOBS BASE: CREATOR DATA & WARDROBE
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
    `chat_id` VARCHAR(64) NOT NULL,
    `sender_identifier` VARCHAR(64) DEFAULT NULL,
    `sender_name` VARCHAR(100) NOT NULL,
    `message` TEXT NOT NULL,
    `timestamp` BIGINT NOT NULL,
    INDEX `idx_chat` (`chat_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_jobs_chat_groups` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `job` VARCHAR(50) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `created_by` VARCHAR(64) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_jobs_calendar_events` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `job` VARCHAR(50) NOT NULL,
    `title` VARCHAR(150) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `date` VARCHAR(50) NOT NULL,
    `time` VARCHAR(20) DEFAULT NULL,
    `created_by` VARCHAR(64) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_jobs_public_forms` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `job` VARCHAR(50) NOT NULL,
    `form_type` VARCHAR(50) NOT NULL,
    `sender_identifier` VARCHAR(64) DEFAULT NULL,
    `sender_name` VARCHAR(100) NOT NULL,
    `data` LONGTEXT DEFAULT NULL,
    `status` VARCHAR(20) DEFAULT 'pending',
    `notes` LONGTEXT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_job` (`job`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sky_jobs_trunk_props` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `plate` VARCHAR(16) NOT NULL,
    `prop` VARCHAR(100) NOT NULL,
    `coords` LONGTEXT DEFAULT NULL,
    `rotation` LONGTEXT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
