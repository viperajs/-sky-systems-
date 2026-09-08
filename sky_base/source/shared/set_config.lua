if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/shared/set_config.lua") end
-- =====================================================
--  sky_base · source/shared/set_config.lua
--  Deobfuscated & Cleaned
-- =====================================================

local RESOURCE_NAME = "sky_base"
if GetCurrentResourceName() ~= RESOURCE_NAME then
    Sky.Debug("error", "You are not allowed to rename this resource. Please name it " .. RESOURCE_NAME)
end

local function autoDetect(configKey, options, fallbackMsg)
    for _, opt in ipairs(options) do
        if GetResourceState(opt.resource) == "started" then
            Sky.Config[configKey] = opt.value
            Sky.Debug("info", opt.value .. " was automatically recognized for " .. configKey .. " and will be used")
            return
        end
    end
    Sky.Debug("error", fallbackMsg .. " Please specify in " .. RESOURCE_NAME .. "/config/config.lua")
end

-- Framework auto-detection
if Sky.Config.framework == "auto" then
    autoDetect("framework", {
        { resource = "es_extended", value = "esx" },
        { resource = "qbx_core", value = "qbox" },
        { resource = "qb-core", value = "qb" },
        { resource = "vrp", value = "vrp" }
    }, "Could not detect the framework automatically.")
end

-- SQL auto-detection
if Sky.Config.sql == "auto" then
    autoDetect("sql", {
        { resource = "oxmysql", value = "oxmysql" },
        { resource = "mysql-async", value = "mysql-async" }
    }, "Could not detect the database connection automatically.")
end

-- Garage auto-detection
if Sky.Config.garage == "auto" then
    autoDetect("garage", {
        { resource = "op-garages", value = "op" },
        { resource = "hex_garage", value = "hex" },
        { resource = "hex_2_garage", value = "hex" },
        { resource = "ws_garage-v2", value = "ws" },
        { resource = "ak47_qb_garage", value = "ak47" },
        { resource = "vms_garagesv2", value = "vms" },
        { resource = "myGarage", value = "my" },
        { resource = "bp_garage", value = "bp" },
        { resource = "cd_garage", value = "cd" },
        { resource = "jg-advancedgarages", value = "jg" },
        { resource = "okokGarage", value = "okok" },
        { resource = "qs-advancedgarages", value = "quasar" },
        { resource = "DS-ServerCreator", value = "ds-servercreator" },
        { resource = "es_extended", value = "esx" },
        { resource = "qb-core", value = "qb" },
        { resource = "qbx_core", value = "qbox" }
    }, "Could not detect the garage automatically.")

    if Sky.Config.inventory == "ds-servercreator" then
        Sky.Config.inventory = Sky.Config.framework
        Sky.Debug("info", "DS ServerCreator detected, using framework garage functions (" .. tostring(Sky.Config.framework) .. ").")
    end
end

-- Progressbar auto-detection
if Sky.Config.progressbar == "auto" then
    autoDetect("progressbar", {
        { resource = "esx_progressbar", value = "esx" },
        { resource = "ox_lib", value = "ox" },
        { resource = "progressbar", value = "qb" },
        { resource = "mythic_progbar", value = "mythic" },
        { resource = "robberies_creator", value = "jaksam" },
        { resource = "jobs_creator", value = "jaksam" },
        { resource = "drugs_creator", value = "jaksam" },
        { resource = "wasabi_uikit", value = "wasabi" },
        { resource = "hex_4_hud", value = "hex" },
        { resource = "hex_2_hud", value = "hex" },
        { resource = "hex_final_hud", value = "hex" },
        { resource = "hex_finalhud_v2", value = "hex" },
        { resource = "hex_future_hud", value = "hex" },
        { resource = "hex_genesis_hud", value = "hex" },
        { resource = "hex_hud_prem", value = "hex" }
    }, "Could not detect the progressbar automatically.")
end

-- Phone auto-detection
if Sky.Config.phone == "auto" then
    autoDetect("phone", {
        { resource = "lb-phone", value = "lb" },
        { resource = "codem-phone", value = "codem" },
        { resource = "okokPhone", value = "okok" },
        { resource = "roadphone", value = "roadphone" },
        { resource = "yseries", value = "yseries" },
        { resource = "17mov_Phone", value = "17mov" },
        { resource = "d-phone", value = "d" },
        { resource = "qb-phone", value = "qb" },
        { resource = "gksphone", value = "gks" },
        { resource = "qs-smartphone-pro", value = "qs" },
        { resource = "qs-smartphone", value = "qs" },
        { resource = "gcphone", value = "esx" },
        { resource = "smarthone", value = "esx" }
    }, "Could not detect the phone automatically.")
end

-- Billing auto-detection
if Sky.Config.billing == "auto" then
    autoDetect("billing", {
        { resource = "codem-billingv2", value = "codemv2" },
        { resource = "codem-billing", value = "codem" },
        { resource = "esx_billing", value = "esx" },
        { resource = "es_extended", value = "esx" },
        { resource = "okokBilling", value = "okok" },
        { resource = "qs-billing", value = "quasar" },
        { resource = "billing_ui", value = "jacksam" },
        { resource = "RxBilling", value = "rxbilling" },
        { resource = "wasabi_billing", value = "wasabi" },
        { resource = "crm-billing", value = "corem" },
        { resource = "fd_banking", value = "fd" },
        { resource = "g-billing", value = "groot" },
        { resource = "vms_cityhall", value = "vms" },
        { resource = "bcs_companymanager", value = "companymanager" }
    }, "Could not detect the billing system automatically.")
end

-- Vehicle Keys auto-detection
if Sky.Config.vehiclekeys == "auto" then
    autoDetect("vehiclekeys", {
        { resource = "qb-vehiclekeys", value = "qb" },
        { resource = "qbx_vehiclekeys", value = "qb" },
        { resource = "qs-vehiclekeys", value = "quasar" },
        { resource = "MrNewbVehicleKeys", value = "mrnewb" },
        { resource = "mk_vehiclekeys", value = "mk" },
        { resource = "wasabi_carlock", value = "wasabi" },
        { resource = "msk_vehiclekeys", value = "msk" },
        { resource = "brutal_keys", value = "brutal" },
        { resource = "vehicles_keys", value = "vehicles_keys" },
        { resource = "ak47_qb_vehiclekeys", value = "ak47" },
        { resource = "ak47_vehiclekeys", value = "ak47" },
        { resource = "jc_vehiclekeys", value = "jota" },
        { resource = "VehicleKeyChain", value = "kiminaze" }
    }, "Could not detect the vehicle key system automatically.")
end

-- Fuel auto-detection
if Sky.Config.fuel == "auto" then
    autoDetect("fuel", {
        { resource = "lc_fuel", value = "lc" },
        { resource = "ox_fuel", value = "ox" },
        { resource = "LegacyFuel", value = "legacy" },
        { resource = "rcore_fuel", value = "rcore" },
        { resource = "hex_3_fuel", value = "hex" },
        { resource = "myFuel", value = "myFuel" },
        { resource = "okokGasStation", value = "okokGasStation" }
    }, "Could not detect the fuel system automatically. Falling back to native.")

    if Sky.Config.fuel == "auto" then
        Sky.Config.fuel = "native"
        Sky.Debug("info", "No fuel script detected, using native fuel functions.")
    end
end

-- Inventory auto-detection
if Sky.Config.inventory == "auto" then
    autoDetect("inventory", {
        { resource = "jaksam_inventory", value = "jaksam" },
        { resource = "qs-inventory", value = "qs" },
        { resource = "ps-inventory", value = "ps" },
        { resource = "codem-inventory", value = "codem" },
        { resource = "tgiann-inventory", value = "tgiann" },
        { resource = "core_inventory", value = "core" },
        { resource = "jpr-inventory", value = "jpr" },
        { resource = "origen_inventory", value = "origen" },
        { resource = "ak47_inventory", value = "ak47" },
        { resource = "one_inventory", value = "one" },
        { resource = "ox_inventory", value = "ox" },
        { resource = "hex_4_inventory", value = "hex" },
        { resource = "qb-inventory", value = "qb-inv" }
    }, "Could not detect the inventory system automatically. Falling back to framework inventory.")

    if Sky.Config.inventory == "auto" then
        Sky.Config.inventory = Sky.Config.framework
        Sky.Debug("info", "No inventory script detected, using framework inventory functions (" .. tostring(Sky.Config.framework) .. ").")
    elseif Sky.Config.inventory == "hex" then
        Sky.Config.inventory = Sky.Config.framework
        Sky.Debug("info", "Hex inventory detected, using framework inventory functions (" .. tostring(Sky.Config.framework) .. ").")
    end
end

-- Target auto-detection
if Sky.Config.target == "auto" then
    autoDetect("target", {
        { resource = "ox_target", value = "ox" },
        { resource = "qb-target", value = "qb" }
    }, "Could not detect the target system automatically. Falling back to 'none' (help notification + marker).")

    if Sky.Config.target == "auto" then
        Sky.Config.target = "none"
    end
end

-- Banking auto-detection
if Sky.Config.banking == "auto" then
    if GetResourceState("codem-bank") == "started" then
        Sky.Config.banking = "codem"
        Sky.Debug("info", "codem was automatically recognized for banking and will be used")
    end

    if Sky.Config.banking == "auto" then
        autoDetect("banking", {
            { resource = "crm-banking", value = "crm" },
            { resource = "codem-bank", value = "codem" },
            { resource = "qs-banking", value = "qs" },
            { resource = "qs_banking", value = "qs" },
            { resource = "okokBanking", value = "okok" },
            { resource = "bablo-banking", value = "bablo" },
            { resource = "fd_banking", value = "fd" },
            { resource = "RxBanking", value = "rx" },
            { resource = "tgg-banking", value = "tgg" },
            { resource = "kartik-banking", value = "kartik" },
            { resource = "Renewed-Banking", value = "renewed" },
            { resource = "qb-banking", value = "qb" },
            { resource = "wasabi_banking", value = "wasabi" },
            { resource = "g-banking", value = "groot" },
            { resource = "ak47_banking", value = "ak47" },
            { resource = "jobs_creator", value = "jaksam" },
            { resource = "bcs_companymanager", value = "companymanager" }
        }, "Could not detect the banking system automatically. Falling back to framework default.")
    end

    if Sky.Config.banking == "auto" then
        if Sky.Config.framework == "qb" then
            Sky.Config.banking = "qb"
        elseif Sky.Config.framework == "qbox" then
            Sky.Config.banking = "renewed"
        else
            Sky.Config.banking = "esx"
        end
    elseif Sky.Config.banking == "codem" then
        if Sky.Config.framework == "qb" then
            Sky.Config.banking = "qb"
        elseif Sky.Config.framework == "qbox" then
            Sky.Config.banking = "renewed"
        else
            Sky.Config.banking = "esx"
        end
        Sky.Debug("info", "codem banking detected, using framework banking functions (" .. tostring(Sky.Config.framework) .. ").")
    end
end
