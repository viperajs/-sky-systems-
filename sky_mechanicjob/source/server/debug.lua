if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/debug.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/debug.lua
--  Admin & Debug Commands for Tuning, Wear and Repair
-- =====================================================

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

-- ── /admintuning [playerId] ───────────────────────────

RegisterCommand("admintuning", function(source, args, rawCommand)
    local src = source
    if src > 0 and not Functions.HasPermission(src, "admintuning") then
        Functions.ShowNotification(src, "Tuning", "You do not have permission to use /admintuning.", "error")
        return
    end

    local targetSrc = tonumber(args[1]) or src
    if targetSrc <= 0 then targetSrc = src end

    TriggerClientEvent("sky_mechanicjob:tuning:openAdmin", targetSrc)
    if src > 0 and targetSrc ~= src then
        Functions.ShowNotification(src, "Tuning", string.format("Opened admin tuning menu for player %d.", targetSrc), "success")
    end
end, false)

-- ── /adminrepair [playerId] ───────────────────────────

RegisterCommand("adminrepair", function(source, args, rawCommand)
    local src = source
    if src > 0 and not Functions.HasPermission(src, "adminrepair") then
        Functions.ShowNotification(src, "Tuning", "You do not have permission to use /adminrepair.", "error")
        return
    end

    local targetSrc = tonumber(args[1]) or src
    if targetSrc <= 0 then targetSrc = src end

    TriggerClientEvent("sky_mechanicjob:admin:repairVehicle", targetSrc)
end, false)

-- ── /debugadminrepair ─────────────────────────────────

RegisterCommand("debugadminrepair", function(source, args, rawCommand)
    local src = source
    if src > 0 and not Functions.HasPermission(src, "debugadminrepair") then
        Functions.ShowNotification(src, "Tuning", "You do not have permission to use /debugadminrepair.", "error")
        return
    end

    TriggerClientEvent("sky_mechanicjob:debug:testAdminRepairVehicle", src)
end, false)

-- ── /debugstancerdefault ──────────────────────────────

RegisterCommand("debugstancerdefault", function(source, args, rawCommand)
    local src = source
    if src > 0 and not Functions.HasPermission(src, "debugstancerdefault") then
        Functions.ShowNotification(src, "Tuning", "You do not have permission to use /debugstancerdefault.", "error")
        return
    end

    TriggerClientEvent("sky_mechanicjob:debug:saveCurrentStanceAsDefault", src)
end, false)

-- ── /debugwearzero [part] [plate] ─────────────────────

RegisterCommand("debugwearzero", function(source, args, rawCommand)
    local src = source
    if src > 0 and not Functions.HasPermission(src, "debugwearzero") then
        Functions.ShowNotification(src, "Tuning", "You do not have permission to use /debugwearzero.", "error")
        return
    end

    local part = args[1]
    local plate = args[2]

    if not part or part == "" then
        part = "tyres"
    end

    if plate and plate ~= "" then
        plate = sanitizePlate(plate)
        local currentWear = exports[GetCurrentResourceName()]:GetVehicleWear(plate) or {}
        currentWear[part] = 0.0
        exports[GetCurrentResourceName()]:SetVehicleWear(plate, currentWear)

        TriggerClientEvent("sky_mechanicjob:wear:partRepaired", -1, {
            plate = plate,
            part = part,
            wear = currentWear
        })

        if src > 0 then
            Functions.ShowNotification(src, "Tuning", string.format("Set component %s to 0%% for plate %s.", part, plate), "info")
        end
    else
        if src > 0 then
            Functions.ShowNotification(src, "Tuning", "Usage: /debugwearzero [part] [plate]", "info")
        end
    end
end, false)

-- ── /debugwearzeroall [plate] ─────────────────────────

RegisterCommand("debugwearzeroall", function(source, args, rawCommand)
    local src = source
    if src > 0 and not Functions.HasPermission(src, "debugwearzeroall") then
        Functions.ShowNotification(src, "Tuning", "You do not have permission to use /debugwearzeroall.", "error")
        return
    end

    local plate = sanitizePlate(args[1])
    if plate == "" then
        if src > 0 then
            Functions.ShowNotification(src, "Tuning", "Usage: /debugwearzeroall [plate]", "info")
        end
        return
    end

    local zeroWear = {
        tyres = 0.0,
        brake_pads = 0.0,
        suspension = 0.0,
        spark_plugs = 0.0,
        engine_oil = 0.0,
        coolant = 0.0,
        brake_fluid = 0.0,
        transmission_fluid = 0.0,
        clutch = 0.0,
        air_filter = 0.0,
        catalytic_converter = 0.0,
        traction_battery = 0.0,
        inverter = 0.0
    }

    exports[GetCurrentResourceName()]:SetVehicleWear(plate, zeroWear)

    TriggerClientEvent("sky_mechanicjob:wear:partRepaired", -1, {
        plate = plate,
        part = "debug_wear_zero_all",
        wear = zeroWear
    })

    if src > 0 then
        Functions.ShowNotification(src, "Tuning", string.format("Set all wear components to 0%% for plate %s.", plate), "info")
    end
end, false)
