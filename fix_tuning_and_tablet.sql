-- ============================================================================
--  SKY SYSTEMS · ONE-TIME FIX FOR TUNING AND TABLET DATA
--  Run once after updating the scripts, with sky_mechanicjob and sky_jobs_base
--  STOPPED (they cache tuning rows for 10 minutes and would write old values back).
--  Park the affected cars in their garage first.
--  Works on MySQL 8 and MariaDB 10.4+.
--
--  Do not DROP the sky_mechanic_* tables: sky_mechanicjob only creates them once
--  (it remembers the schema version), so a dropped table is not created again.
-- ============================================================================


-- ----------------------------------------------------------------------------
--  1. LOOK FIRST (optional): what one car has stored. Replace ABC123 with the plate.
-- ----------------------------------------------------------------------------

-- Qbox / QBCore (ESX: owned_vehicles.vehicle instead of player_vehicles.mods)
SELECT plate,
       JSON_EXTRACT(mods, '$.modTurbo')         AS turbo,
       JSON_EXTRACT(mods, '$.modXenon')         AS xenon,
       JSON_EXTRACT(mods, '$.xenonColor')       AS xenon_color,
       JSON_EXTRACT(mods, '$.customXenonColor') AS xenon_custom,
       JSON_EXTRACT(mods, '$.neonEnabled')      AS neon,
       JSON_EXTRACT(mods, '$.neonColor')        AS neon_color,
       JSON_EXTRACT(mods, '$.wheels')           AS wheel_type,
       JSON_EXTRACT(mods, '$.modFrontWheels')   AS rims
FROM player_vehicles WHERE plate = 'ABC123';

SELECT plate, tuning, stance, rgb FROM sky_mechanic_vehicle_tuning WHERE plate = 'ABC123';


-- ----------------------------------------------------------------------------
--  2. FIX: invisible rims
--  A stance with a track width under 0.2 (the old slider went down to 0) put the
--  wheels inside the car's body. The scripts no longer apply such values; these
--  remove the ones already stored.
-- ----------------------------------------------------------------------------

UPDATE sky_mechanic_vehicle_tuning
SET stance = NULL
WHERE stance IS NOT NULL AND JSON_VALID(stance) AND (
       ABS(JSON_EXTRACT(stance, '$.trackFront')) < 0.2
    OR ABS(JSON_EXTRACT(stance, '$.trackRear')) < 0.2
);

DELETE FROM sky_mechanic_stance_defaults
WHERE stance IS NOT NULL AND JSON_VALID(stance) AND (
       ABS(JSON_EXTRACT(stance, '$.trackFront')) < 0.2
    OR ABS(JSON_EXTRACT(stance, '$.trackRear')) < 0.2
    OR ABS(JSON_EXTRACT(stance, '$.trackFrontLeft')) < 0.2
    OR ABS(JSON_EXTRACT(stance, '$.trackRearLeft')) < 0.2
);


-- ----------------------------------------------------------------------------
--  3. FIX: neon / xenon colours that changed back
--  An RGB controller record with no effect running repainted the neon and xenon
--  colours it was saved with every time someone got in. Records with both effects
--  off are not needed and are removed.
-- ----------------------------------------------------------------------------

UPDATE sky_mechanic_vehicle_tuning
SET rgb = NULL
WHERE rgb IS NOT NULL AND JSON_VALID(rgb)
  AND COALESCE(JSON_EXTRACT(rgb, '$.neon.mode'), 0) = 0
  AND COALESCE(JSON_EXTRACT(rgb, '$.xenon.mode'), 0) = 0;


-- ----------------------------------------------------------------------------
--  4. NEW TABLE: chat profile photos (sky_jobs_base also creates it on start)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `sky_jobs_chat_profiles` (
    `identifier` VARCHAR(64) NOT NULL PRIMARY KEY,
    `image_url` VARCHAR(1024) DEFAULT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ----------------------------------------------------------------------------
--  5. OPTIONAL: CCTV cameras added with the old /addcctvcam looked the wrong way
--  (behind the admin who placed them). Turn them around, or delete and add them
--  again with the new /addcctvcam (it saves where you look).
-- ----------------------------------------------------------------------------

-- UPDATE sky_jobs_cctv_cameras SET heading = MOD(heading + 180, 360);


-- ----------------------------------------------------------------------------
--  6. OPTIONAL FULL RESET of what Sky stores for tuning (stance, RGB effects,
--  nitro, custom handling, anti-lag/two-step, stance defaults). The cars' own
--  mods (turbo, rims, colours) stay in player_vehicles / owned_vehicles.
--  Remove the leading "-- " to run a line.
-- ----------------------------------------------------------------------------

-- One car:
-- DELETE FROM sky_mechanic_vehicle_tuning  WHERE plate = 'ABC123';
-- DELETE FROM sky_mechanic_stance_defaults WHERE plate = 'ABC123';

-- Every car:
-- TRUNCATE TABLE sky_mechanic_vehicle_tuning;
-- TRUNCATE TABLE sky_mechanic_stance_defaults;

-- Sky-only keys inside the framework properties (Qbox / QBCore). Garages ignore them.
-- UPDATE player_vehicles
-- SET mods = JSON_REMOVE(mods, '$.mods', '$.toggleMods', '$.customXenonColor',
--                        '$.modCustomFrontWheels', '$.modCustomBackWheels', '$.liveryRoof')
-- WHERE JSON_VALID(mods);
