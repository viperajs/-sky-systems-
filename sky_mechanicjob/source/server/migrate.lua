if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/migrate.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/migrate.lua
--  Data Migration Tool from Legacy Systems
-- =====================================================

RegisterCommand("migrate", function(source, args, rawCommand)
    local src = source
    if src > 0 and not Functions.HasPermission(src, "migrate") then
        Functions.ShowNotification(src, "Tuning", "You do not have permission to use this command.", "error")
        return
    end

    Functions.Log("info", "[migrate] Starting migration from mechanic_vehicledata...")

    -- Check if table exists
    local tableExists = MySQL.single.await([[
        SELECT COUNT(*) as count
        FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_name = 'mechanic_vehicledata'
    ]])

    if not tableExists or tableExists.count == 0 then
        local msg = "Legacy table 'mechanic_vehicledata' was not found in the database."
        if src > 0 then
            Functions.ShowNotification(src, "Tuning Migration", msg, "error")
        end
        Functions.Log("warn", "[migrate] " .. msg)
        return
    end

    local rows = MySQL.query.await("SELECT * FROM mechanic_vehicledata") or {}
    local migratedCount = 0

    for _, row in ipairs(rows) do
        local plate = row.plate or row.vehicle_plate
        if plate and plate ~= "" then
            local cleanPlate = string.upper(Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate) or plate)
            local tuningData = row.data and json.decode(row.data) or row

            if tuningData then
                TuningDB.SaveVehicleTuning(cleanPlate, {
                    tuning = tuningData.paint and { paint = tuningData.paint } or nil,
                    stance = tuningData.stance,
                    rgb = tuningData.rgb,
                    nitro = tuningData.nitro,
                    custom_handling = tuningData.custom_handling or (tuningData.customHandling and tuningData.customHandling.profiles) or nil
                })
                migratedCount = migratedCount + 1
            end
        end
    end

    local resultMsg = string.format("Successfully migrated %d vehicle records into sky_mechanic_vehicle_tuning.", migratedCount)
    if src > 0 then
        Functions.ShowNotification(src, "Tuning Migration", resultMsg, "success")
    end
    Functions.Log("info", "[migrate] " .. resultMsg)
end, false)
