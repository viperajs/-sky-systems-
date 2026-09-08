if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/config/config.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

Config.PrimaryColor = "#EDC001"

-- Use the shared /jobconfig UI for Config.Jobs. Set to false to use only the Lua job definitions below.
Config.UseJobConfigurator = true

Config.ToggleFeatures = {
    instantTuning = false,
    partsDelivery = true,
    carryItems = false,
    nitro = false,
    antiLag = true,
    twoStep = true,
    wheelDamage = true,
    customHandling = true,
    mileageHud = true,
    workshopLift = true
}

Config.Jobs = {
    {
        name = "mechanic",
        color = Config.PrimaryColor,
        offDutyJob = {
            enabled = false,
            job = "off_mechanic"
        },
        shop = {
            { name = "body_kit",           label = "Body Kit",            price = 250 },
            { name = "wheels",             label = "Wheels",              price = 300 },
            { name = "spray_can",          label = "Spray Can",           price = 75 },
            { name = "wash_sponge",        label = "Wash Sponge",         price = 45 },
            { name = "vehicle_wax",        label = "Vehicle Wax",         price = 120 },
            { name = "fix_kit",            label = "Fix Kit",             price = 650 },
            { name = "engine",             label = "Engine",              price = 3500 },
            { name = "brakes",             label = "Brakes",              price = 450 },
            { name = "transmission",       label = "Transmission",        price = 2200 },
            { name = "turbo",              label = "Turbo",               price = 1800 },
            { name = "antilag_kit",        label = "Anti-Lag Kit",        price = 950 },
            { name = "suspension",         label = "Suspension",          price = 700 },
            --{ name = "armor_plating",      label = "Armor Plating",       price = 1600 },
            { name = "stance_kit",         label = "Stance Kit",          price = 850 },
            --{ name = "nitro_kit",          label = "Nitro Kit",           price = 1400 },
            { name = "vehicle_lights",     label = "Vehicle Lights",      price = 550 },
            { name = "spark_plugs",        label = "Spark Plugs",         price = 120 },
            { name = "engine_oil",         label = "Engine Oil",          price = 90 },
            { name = "engine_coolant",     label = "Engine Coolant",      price = 110 },
            { name = "brake_fluid",        label = "Brake Fluid",         price = 85 },
            { name = "transmission_fluid", label = "Transmission Fluid",  price = 95 },
            { name = "air_filter",         label = "Air Filter",          price = 140 },
            { name = "traction_battery",   label = "Traction Battery",    price = 4200 },
            { name = "inverter",           label = "Power Inverter",      price = 1850 },
            { name = "rgb_controller",     label = "RGB Controller",      price = 650 }
        },
        partsDeliveryShop = {
            { name = "body_kit",           label = "Body Kit",            price = 250,  category = "Exterior" },
            { name = "wheels",             label = "Wheels",              price = 300,  category = "Wheels" },
            { name = "spray_can",          label = "Spray Can",           price = 75,   category = "Paint" },
            { name = "wash_sponge",        label = "Wash Sponge",         price = 45,   category = "Service" },
            { name = "vehicle_wax",        label = "Vehicle Wax",         price = 120,  category = "Service" },
            { name = "fix_kit",            label = "Fix Kit",             price = 650,  category = "Service" },
            { name = "engine",             label = "Engine",              price = 3500, category = "Performance" },
            { name = "brakes",             label = "Brakes",              price = 450,  category = "Performance" },
            { name = "transmission",       label = "Transmission",        price = 2200, category = "Performance" },
            { name = "turbo",              label = "Turbo",               price = 1800, category = "Performance" },
            { name = "antilag_kit",        label = "Anti-Lag Kit",        price = 950,  category = "Electronics" },
            { name = "suspension",         label = "Suspension",          price = 700,  category = "Handling" },
            { name = "armor_plating",      label = "Armor Plating",       price = 1600, category = "Exterior" },
            { name = "stance_kit",         label = "Stance Kit",          price = 850,  category = "Handling" },
            { name = "nitro_kit",          label = "Nitro Kit",           price = 1400, category = "Performance" },
            { name = "vehicle_lights",     label = "Vehicle Lights",      price = 550,  category = "Electronics" },
            { name = "spark_plugs",        label = "Spark Plugs",         price = 120,  category = "Service" },
            { name = "engine_oil",         label = "Engine Oil",          price = 90,   category = "Service" },
            { name = "engine_coolant",     label = "Engine Coolant",      price = 110,  category = "Service" },
            { name = "brake_fluid",        label = "Brake Fluid",         price = 85,   category = "Service" },
            { name = "transmission_fluid", label = "Transmission Fluid",  price = 95,   category = "Service" },
            { name = "air_filter",         label = "Air Filter",          price = 140,  category = "Service" },
            { name = "catalytic_converter", label = "Catalytic Converter", price = 1500, category = "Exhaust" },
            { name = "traction_battery",   label = "Traction Battery",    price = 4200, category = "Electronics" },
            { name = "inverter",           label = "Power Inverter",      price = 1850, category = "Electronics" },
            { name = "rgb_controller",     label = "RGB Controller",      price = 650,  category = "Electronics" }
        },
        tuningCostProfile = {
            performanceStages = {
                engine = {
                    enabled = true,
                    modType = 11,
                    cost = {
                        { cost = 13.95, items = { "engine" } },
                        { cost = 32.56, items = { "engine" } },
                        { cost = 65.12, items = { "engine" } },
                        { cost = 139.53, items = { "engine" } }
                    }
                },
                brakes = {
                    enabled = true,
                    modType = 12,
                    cost = {
                        { cost = 4.65, items = { "brakes" } },
                        { cost = 9.3, items = { "brakes" } },
                        { cost = 18.6, items = { "brakes" } },
                        { cost = 37.2, items = { "brakes" } }
                    }
                },
                transmission = {
                    enabled = true,
                    modType = 13,
                    cost = {
                        { cost = 13.95, items = { "transmission" } },
                        { cost = 20.93, items = { "transmission" } },
                        { cost = 46.51, items = { "transmission" } }
                    }
                },
                suspension = {
                    enabled = true,
                    modType = 15,
                    cost = {
                        { cost = 3.72, items = { "suspension" } },
                        { cost = 7.44, items = { "suspension" } },
                        { cost = 14.88, items = { "suspension" } },
                        { cost = 29.77, items = { "suspension" } },
                        { cost = 40.2, items = { "suspension" } }
                    }
                },
                armor = {
                    enabled = true,
                    modType = 16,
                    cost = {
                        { cost = 69.77, items = { "armor_plating" } },
                        { cost = 116.28, items = { "armor_plating" } },
                        { cost = 130.0, items = { "armor_plating" } },
                        { cost = 150.0, items = { "armor_plating" } },
                        { cost = 180.0, items = { "armor_plating" } },
                        { cost = 190.0, items = { "armor_plating" } }
                    }
                }
            },
            appearanceMods = {
                spoiler = { enabled = true, modType = 0, cost = 4.65, items = { "body_kit" } },
                front_bumper = { enabled = true, modType = 1, cost = 5.12, items = { "body_kit" } },
                rear_bumper = { enabled = true, modType = 2, cost = 5.12, items = { "body_kit" } },
                side_skirt = { enabled = true, modType = 3, cost = 4.65, items = { "body_kit" } },
                exhaust = { enabled = true, modType = 4, cost = 5.12, items = { "body_kit" } },
                roll_cage = { enabled = true, modType = 5, cost = 5.12, items = { "body_kit" } },
                grille = { enabled = true, modType = 6, cost = 3.72, items = { "body_kit" } },
                hood = { enabled = true, modType = 7, cost = 4.88, items = { "body_kit" } },
                left_fender = { enabled = true, modType = 8, cost = 5.12, items = { "body_kit" } },
                right_fender = { enabled = true, modType = 9, cost = 5.12, items = { "body_kit" } },
                roof = { enabled = true, modType = 10, cost = 5.58, items = { "body_kit" } },
                horns = { enabled = true, modType = 14, cost = 1.12, items = { "body_kit" } },
                plate_holder = { enabled = true, modType = 25, cost = 3.49, items = { "body_kit" } },
                vanity_plate = { enabled = true, modType = 26, cost = 1.1, items = { "body_kit" } },
                trim_design = { enabled = true, modType = 27, cost = 6.98, items = { "body_kit" } },
                ornaments = { enabled = true, modType = 28, cost = 0.9, items = { "body_kit" } },
                dashboard = { enabled = true, modType = 29, cost = 4.65, items = { "body_kit" } },
                dial = { enabled = true, modType = 30, cost = 4.19, items = { "body_kit" } },
                door_speaker = { enabled = true, modType = 31, cost = 5.58, items = { "body_kit" } },
                seats = { enabled = true, modType = 32, cost = 4.65, items = { "body_kit" } },
                steering_wheel = { enabled = true, modType = 33, cost = 4.19, items = { "body_kit" } },
                shifter_lever = { enabled = true, modType = 34, cost = 3.26, items = { "body_kit" } },
                plaques = { enabled = true, modType = 35, cost = 4.19, items = { "body_kit" } },
                speaker = { enabled = true, modType = 36, cost = 6.98, items = { "body_kit" } },
                trunk = { enabled = true, modType = 37, cost = 5.58, items = { "body_kit" } },
                hydraulics = { enabled = true, modType = 38, cost = 5.12, items = { "body_kit" } },
                engine_block = { enabled = true, modType = 39, cost = 5.12, items = { "body_kit" } },
                air_filter = { enabled = true, modType = 40, cost = 3.72, items = { "body_kit" } },
                struts = { enabled = true, modType = 41, cost = 6.51, items = { "body_kit" } },
                arch_cover = { enabled = true, modType = 42, cost = 4.19, items = { "body_kit" } },
                aerial = { enabled = true, modType = 43, cost = 1.12, items = { "body_kit" } },
                trim = { enabled = true, modType = 44, cost = 6.05, items = { "body_kit" } },
                tank = { enabled = true, modType = 45, cost = 4.19, items = { "body_kit" } },
                windows = { enabled = true, modType = 46, cost = 4.19, items = { "body_kit" } },
                livery_mod = { enabled = true, modType = 48, cost = 9.3, items = { "body_kit" } },
                lightbar = { enabled = true, modType = 49, cost = 5.58, items = { "body_kit" } }
            },
            wheelTypeCost = {
                sport = { enabled = true, cost = 4.65, items = { "wheels" } },
                muscle = { enabled = true, cost = 4.19, items = { "wheels" } },
                lowrider = { enabled = true, cost = 4.65, items = { "wheels" } },
                suv = { enabled = true, cost = 4.19, items = { "wheels" } },
                offroad = { enabled = true, cost = 4.19, items = { "wheels" } },
                tuner = { enabled = true, cost = 5.12, items = { "wheels" } },
                bike = { enabled = true, cost = 3.26, items = { "wheels" } },
                high_end = { enabled = true, cost = 5.12, items = { "wheels" } },
                benny_original = { enabled = true, cost = 5.12, items = { "wheels" } },
                benny_bespoke = { enabled = true, cost = 5.12, items = { "wheels" } },
                open_wheel = { enabled = true, cost = 5.12, items = { "wheels" } },
                street = { enabled = true, cost = 5.12, items = { "wheels" } },
                track = { enabled = true, cost = 5.12, items = { "wheels" } }
            },
            optionCostByOptionId = {
                stancer_bundle = { enabled = true, cost = 10.25, items = { "stance_kit" } },
                toggle_18 = { enabled = true, cost = 55.81, items = { "turbo" } },
                toggle_22 = { enabled = true, cost = 3.72, items = { "vehicle_lights" } },
                xenon_color = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_0 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_1 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_2 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_3 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_effect = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                neon_effect_speed = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                xenon_effect = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                xenon_effect_speed = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                toggle_20 = { enabled = true, cost = 1.12, items = { "spray_can" } },
                wheel_custom_23 = { enabled = true, cost = 2.12, items = { "wheels" } },
                wheel_custom_24 = { enabled = true, cost = 4.12, items = { "wheels" } },
                wheel_size = { enabled = true, cost = 2.12, items = { "stance_kit" } },
                wheel_width = { enabled = true, cost = 2.12, items = { "stance_kit" } },
                tire_smoke_color = { enabled = true, cost = 1.12, items = { "spray_can" } },
                neon_color = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                color_primary = { enabled = true, cost = 1.12, items = { "spray_can" } },
                color_secondary = { enabled = true, cost = 0.66, items = { "spray_can" } },
                color_pearlescent = { enabled = true, cost = 0.88, items = { "spray_can" } },
                color_wheel = { enabled = true, cost = 0.66, items = { "spray_can" } },
                color_dashboard = { enabled = true, cost = 0.0, items = { "spray_can" } },
                color_interior = { enabled = true, cost = 0.0, items = { "spray_can" } },
                window_tint = { enabled = true, cost = 1.12, items = { "spray_can" } },
                plate_index = { enabled = true, cost = 1.1, items = { "body_kit" } },
                livery = { enabled = true, cost = 9.3, items = { "body_kit" } },
                extra_1 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_2 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_3 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_4 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_5 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_6 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_7 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_8 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_9 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_10 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_11 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_12 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_13 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_14 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_15 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_16 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_17 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_18 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_19 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_20 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                handling_drivetrain = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 13.95, items = { "stance_kit" } },
                        [2] = { cost = 13.95, items = { "stance_kit" } },
                        [3] = { cost = 13.95, items = { "stance_kit" } }
                    }
                },
                antilag_enabled = { enabled = true, cost = 18.6, items = { "antilag_kit" } },
                twostep_enabled = { enabled = true, cost = 16.28, items = { "antilag_kit" } },
                handling_drift_tuning = { enabled = true, cost = 23.26, items = { "stance_kit" } },
                handling_engine_upgrade = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 18.6, items = { "engine" } },
                        [2] = { cost = 34.88, items = { "engine" } },
                        [3] = { cost = 65.12, items = { "engine" } }
                    }
                },
                handling_tyre_compound = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 18.6, items = { "wheels" } },
                        [2] = { cost = 23.26, items = { "wheels" } },
                        [3] = { cost = 16.28, items = { "wheels" } }
                    }
                },
                handling_ceramic_brakes = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 16.28, items = { "brakes" } }
                    }
                }
            }
        },
        props = {
            { model = "prop_roadcone02a", label = "Traffic Cone" },
            { model = "prop_barrier_work05", label = "Barrier" },
            { model = "prop_cs_cardbox_01", label = "Parts Box" },
            { model = "v_31a_worklight_03b", label = "Worklight Stand" },
            { model = "prop_worklight_02a", label = "Worklight" },
            { model = "xs_prop_x18_engine_hoist_02a", label = "Engine Hoist" }
        },
        vehicles = {
            {
                name = "Burrito",
                model = "burrito",
                price = 75000,
                trunkCapacity = 80,
                garageType = "vehicle",
            },
            {
                name = "Tow Truck",
                model = "towtruck4",
                price = 75000,
                trunkCapacity = 80,
                garageType = "vehicle",
            },
            {
                name = "Flatbed",
                model = "flatbed",
                price = 60000,
                trunkCapacity = 55,
                garageType = "vehicle"
            },
            {
                name = "Forklift",
                model = "forklift",
                price = 35000,
                trunkCapacity = 0,
                garageType = "vehicle"
            },
            -- {
            --     name = "Helicopter",
            --     model = "polmav",
            --     price = 250000,
            --     trunkCapacity = 25,
            --     garageType = "helicopter"
            -- }
        }
    },
    {
        name = "lsc",
        color = Config.PrimaryColor,
        offDutyJob = {
            enabled = false,
            job = "off_mechanic"
        },
        shop = {
            { name = "body_kit",           label = "Body Kit",            price = 250 },
            { name = "wheels",             label = "Wheels",              price = 300 },
            { name = "spray_can",          label = "Spray Can",           price = 75 },
            { name = "wash_sponge",        label = "Wash Sponge",         price = 45 },
            { name = "vehicle_wax",        label = "Vehicle Wax",         price = 120 },
            { name = "fix_kit",            label = "Fix Kit",             price = 650 },
            { name = "engine",             label = "Engine",              price = 3500 },
            { name = "brakes",             label = "Brakes",              price = 450 },
            { name = "transmission",       label = "Transmission",        price = 2200 },
            { name = "turbo",              label = "Turbo",               price = 1800 },
            { name = "antilag_kit",        label = "Anti-Lag Kit",        price = 950 },
            { name = "suspension",         label = "Suspension",          price = 700 },
            --{ name = "armor_plating",      label = "Armor Plating",       price = 1600 },
            { name = "stance_kit",         label = "Stance Kit",          price = 850 },
            --{ name = "nitro_kit",          label = "Nitro Kit",           price = 1400 },
            { name = "vehicle_lights",     label = "Vehicle Lights",      price = 550 },
            { name = "spark_plugs",        label = "Spark Plugs",         price = 120 },
            { name = "engine_oil",         label = "Engine Oil",          price = 90 },
            { name = "engine_coolant",     label = "Engine Coolant",      price = 110 },
            { name = "brake_fluid",        label = "Brake Fluid",         price = 85 },
            { name = "transmission_fluid", label = "Transmission Fluid",  price = 95 },
            { name = "air_filter",         label = "Air Filter",          price = 140 },
            { name = "traction_battery",   label = "Traction Battery",    price = 4200 },
            { name = "inverter",           label = "Power Inverter",      price = 1850 },
            { name = "rgb_controller",     label = "RGB Controller",      price = 650 }
        },
        partsDeliveryShop = {
            { name = "body_kit",           label = "Body Kit",            price = 250,  category = "Exterior" },
            { name = "wheels",             label = "Wheels",              price = 300,  category = "Wheels" },
            { name = "spray_can",          label = "Spray Can",           price = 75,   category = "Paint" },
            { name = "wash_sponge",        label = "Wash Sponge",         price = 45,   category = "Service" },
            { name = "vehicle_wax",        label = "Vehicle Wax",         price = 120,  category = "Service" },
            { name = "fix_kit",            label = "Fix Kit",             price = 650,  category = "Service" },
            { name = "engine",             label = "Engine",              price = 3500, category = "Performance" },
            { name = "brakes",             label = "Brakes",              price = 450,  category = "Performance" },
            { name = "transmission",       label = "Transmission",        price = 2200, category = "Performance" },
            { name = "turbo",              label = "Turbo",               price = 1800, category = "Performance" },
            { name = "antilag_kit",        label = "Anti-Lag Kit",        price = 950,  category = "Electronics" },
            { name = "suspension",         label = "Suspension",          price = 700,  category = "Handling" },
            --{ name = "armor_plating",      label = "Armor Plating",       price = 1600, category = "Exterior" },
            { name = "stance_kit",         label = "Stance Kit",          price = 850,  category = "Handling" },
            --{ name = "nitro_kit",          label = "Nitro Kit",           price = 1400, category = "Performance" },
            { name = "vehicle_lights",     label = "Vehicle Lights",      price = 550,  category = "Electronics" },
            { name = "spark_plugs",        label = "Spark Plugs",         price = 120,  category = "Service" },
            { name = "engine_oil",         label = "Engine Oil",          price = 90,   category = "Service" },
            { name = "engine_coolant",     label = "Engine Coolant",      price = 110,  category = "Service" },
            { name = "brake_fluid",        label = "Brake Fluid",         price = 85,   category = "Service" },
            { name = "transmission_fluid", label = "Transmission Fluid",  price = 95,   category = "Service" },
            { name = "air_filter",         label = "Air Filter",          price = 140,  category = "Service" },
            { name = "catalytic_converter", label = "Catalytic Converter", price = 1500, category = "Exhaust" },
            { name = "traction_battery",   label = "Traction Battery",    price = 4200, category = "Electronics" },
            { name = "inverter",           label = "Power Inverter",      price = 1850, category = "Electronics" },
            { name = "rgb_controller",     label = "RGB Controller",      price = 650,  category = "Electronics" }
        },
        tuningCostProfile = {
            performanceStages = {
                engine = {
                    enabled = true,
                    modType = 11,
                    cost = {
                        { cost = 13.95, items = { "engine" } },
                        { cost = 32.56, items = { "engine" } },
                        { cost = 65.12, items = { "engine" } },
                        { cost = 139.53, items = { "engine" } }
                    }
                },
                brakes = {
                    enabled = true,
                    modType = 12,
                    cost = {
                        { cost = 4.65, items = { "brakes" } },
                        { cost = 9.3, items = { "brakes" } },
                        { cost = 18.6, items = { "brakes" } },
                        { cost = 37.2, items = { "brakes" } }
                    }
                },
                transmission = {
                    enabled = true,
                    modType = 13,
                    cost = {
                        { cost = 13.95, items = { "transmission" } },
                        { cost = 20.93, items = { "transmission" } },
                        { cost = 46.51, items = { "transmission" } }
                    }
                },
                suspension = {
                    enabled = true,
                    modType = 15,
                    cost = {
                        { cost = 3.72, items = { "suspension" } },
                        { cost = 7.44, items = { "suspension" } },
                        { cost = 14.88, items = { "suspension" } },
                        { cost = 29.77, items = { "suspension" } },
                        { cost = 40.2, items = { "suspension" } }
                    }
                },
                armor = {
                    enabled = true,
                    modType = 16,
                    cost = {
                        { cost = 69.77, items = { "armor_plating" } },
                        { cost = 116.28, items = { "armor_plating" } },
                        { cost = 130.0, items = { "armor_plating" } },
                        { cost = 150.0, items = { "armor_plating" } },
                        { cost = 180.0, items = { "armor_plating" } },
                        { cost = 190.0, items = { "armor_plating" } }
                    }
                }
            },
            appearanceMods = {
                spoiler = { enabled = true, modType = 0, cost = 4.65, items = { "body_kit" } },
                front_bumper = { enabled = true, modType = 1, cost = 5.12, items = { "body_kit" } },
                rear_bumper = { enabled = true, modType = 2, cost = 5.12, items = { "body_kit" } },
                side_skirt = { enabled = true, modType = 3, cost = 4.65, items = { "body_kit" } },
                exhaust = { enabled = true, modType = 4, cost = 5.12, items = { "body_kit" } },
                roll_cage = { enabled = true, modType = 5, cost = 5.12, items = { "body_kit" } },
                grille = { enabled = true, modType = 6, cost = 3.72, items = { "body_kit" } },
                hood = { enabled = true, modType = 7, cost = 4.88, items = { "body_kit" } },
                left_fender = { enabled = true, modType = 8, cost = 5.12, items = { "body_kit" } },
                right_fender = { enabled = true, modType = 9, cost = 5.12, items = { "body_kit" } },
                roof = { enabled = true, modType = 10, cost = 5.58, items = { "body_kit" } },
                horns = { enabled = true, modType = 14, cost = 1.12, items = { "body_kit" } },
                plate_holder = { enabled = true, modType = 25, cost = 3.49, items = { "body_kit" } },
                vanity_plate = { enabled = true, modType = 26, cost = 1.1, items = { "body_kit" } },
                trim_design = { enabled = true, modType = 27, cost = 6.98, items = { "body_kit" } },
                ornaments = { enabled = true, modType = 28, cost = 0.9, items = { "body_kit" } },
                dashboard = { enabled = true, modType = 29, cost = 4.65, items = { "body_kit" } },
                dial = { enabled = true, modType = 30, cost = 4.19, items = { "body_kit" } },
                door_speaker = { enabled = true, modType = 31, cost = 5.58, items = { "body_kit" } },
                seats = { enabled = true, modType = 32, cost = 4.65, items = { "body_kit" } },
                steering_wheel = { enabled = true, modType = 33, cost = 4.19, items = { "body_kit" } },
                shifter_lever = { enabled = true, modType = 34, cost = 3.26, items = { "body_kit" } },
                plaques = { enabled = true, modType = 35, cost = 4.19, items = { "body_kit" } },
                speaker = { enabled = true, modType = 36, cost = 6.98, items = { "body_kit" } },
                trunk = { enabled = true, modType = 37, cost = 5.58, items = { "body_kit" } },
                hydraulics = { enabled = true, modType = 38, cost = 5.12, items = { "body_kit" } },
                engine_block = { enabled = true, modType = 39, cost = 5.12, items = { "body_kit" } },
                air_filter = { enabled = true, modType = 40, cost = 3.72, items = { "body_kit" } },
                struts = { enabled = true, modType = 41, cost = 6.51, items = { "body_kit" } },
                arch_cover = { enabled = true, modType = 42, cost = 4.19, items = { "body_kit" } },
                aerial = { enabled = true, modType = 43, cost = 1.12, items = { "body_kit" } },
                trim = { enabled = true, modType = 44, cost = 6.05, items = { "body_kit" } },
                tank = { enabled = true, modType = 45, cost = 4.19, items = { "body_kit" } },
                windows = { enabled = true, modType = 46, cost = 4.19, items = { "body_kit" } },
                livery_mod = { enabled = true, modType = 48, cost = 9.3, items = { "body_kit" } }
            },
            wheelTypeCost = {
                sport = { enabled = true, cost = 4.65, items = { "wheels" } },
                muscle = { enabled = true, cost = 4.19, items = { "wheels" } },
                lowrider = { enabled = true, cost = 4.65, items = { "wheels" } },
                suv = { enabled = true, cost = 4.19, items = { "wheels" } },
                offroad = { enabled = true, cost = 4.19, items = { "wheels" } },
                tuner = { enabled = true, cost = 5.12, items = { "wheels" } },
                bike = { enabled = true, cost = 3.26, items = { "wheels" } },
                high_end = { enabled = true, cost = 5.12, items = { "wheels" } },
                benny_original = { enabled = true, cost = 5.12, items = { "wheels" } },
                benny_bespoke = { enabled = true, cost = 5.12, items = { "wheels" } },
                open_wheel = { enabled = true, cost = 5.12, items = { "wheels" } },
                street = { enabled = true, cost = 5.12, items = { "wheels" } },
                track = { enabled = true, cost = 5.12, items = { "wheels" } }
            },
            optionCostByOptionId = {
                stancer_bundle = { enabled = true, cost = 10.25, items = { "stance_kit" } },
                toggle_18 = { enabled = true, cost = 55.81, items = { "turbo" } },
                toggle_22 = { enabled = true, cost = 3.72, items = { "vehicle_lights" } },
                xenon_color = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_0 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_1 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_2 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_3 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_effect = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                neon_effect_speed = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                xenon_effect = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                xenon_effect_speed = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                toggle_20 = { enabled = true, cost = 1.12, items = { "spray_can" } },
                wheel_custom_23 = { enabled = true, cost = 2.12, items = { "wheels" } },
                wheel_custom_24 = { enabled = true, cost = 4.12, items = { "wheels" } },
                wheel_size = { enabled = true, cost = 2.12, items = { "stance_kit" } },
                wheel_width = { enabled = true, cost = 2.12, items = { "stance_kit" } },
                tire_smoke_color = { enabled = true, cost = 1.12, items = { "spray_can" } },
                neon_color = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                color_primary = { enabled = true, cost = 1.12, items = { "spray_can" } },
                color_secondary = { enabled = true, cost = 0.66, items = { "spray_can" } },
                color_pearlescent = { enabled = true, cost = 0.88, items = { "spray_can" } },
                color_wheel = { enabled = true, cost = 0.66, items = { "spray_can" } },
                color_dashboard = { enabled = true, cost = 0.0, items = { "spray_can" } },
                color_interior = { enabled = true, cost = 0.0, items = { "spray_can" } },
                window_tint = { enabled = true, cost = 1.12, items = { "spray_can" } },
                plate_index = { enabled = true, cost = 1.1, items = { "body_kit" } },
                livery = { enabled = true, cost = 9.3, items = { "body_kit" } },
                extra_1 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_2 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_3 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_4 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_5 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_6 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_7 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_8 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_9 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_10 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_11 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_12 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_13 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_14 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_15 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_16 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_17 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_18 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_19 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_20 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                handling_drivetrain = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 13.95, items = { "stance_kit" } },
                        [2] = { cost = 13.95, items = { "stance_kit" } },
                        [3] = { cost = 13.95, items = { "stance_kit" } }
                    }
                },
                antilag_enabled = { enabled = true, cost = 18.6, items = { "antilag_kit" } },
                twostep_enabled = { enabled = true, cost = 16.28, items = { "antilag_kit" } },
                handling_drift_tuning = { enabled = true, cost = 23.26, items = { "stance_kit" } },
                handling_engine_upgrade = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 18.6, items = { "engine" } },
                        [2] = { cost = 34.88, items = { "engine" } },
                        [3] = { cost = 65.12, items = { "engine" } }
                    }
                },
                handling_tyre_compound = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 18.6, items = { "wheels" } },
                        [2] = { cost = 23.26, items = { "wheels" } },
                        [3] = { cost = 16.28, items = { "wheels" } }
                    }
                },
                handling_ceramic_brakes = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 16.28, items = { "brakes" } }
                    }
                }
            }
        },
        props = {
            { model = "prop_roadcone02a", label = "Traffic Cone" },
            { model = "prop_barrier_work05", label = "Barrier" },
            { model = "prop_cs_cardbox_01", label = "Parts Box" },
            { model = "v_31a_worklight_03b", label = "Worklight Stand" },
            { model = "prop_worklight_02a", label = "Worklight" },
            { model = "xs_prop_x18_engine_hoist_02a", label = "Engine Hoist" }
        },
        vehicles = {
            {
                name = "Burrito",
                model = "burrito",
                price = 75000,
                trunkCapacity = 80,
                garageType = "vehicle",
            },
            {
                name = "Tow Truck",
                model = "towtruck4",
                price = 75000,
                trunkCapacity = 80,
                garageType = "vehicle",
            },
            {
                name = "Flatbed",
                model = "flatbed",
                price = 60000,
                trunkCapacity = 55,
                garageType = "vehicle"
            },
            {
                name = "Forklift",
                model = "forklift",
                price = 35000,
                trunkCapacity = 0,
                garageType = "vehicle"
            }
            -- {
            --     name = "Helicopter",
            --     model = "polmav",
            --     price = 250000,
            --     trunkCapacity = 25,
            --     garageType = "helicopter"
            -- }
        }
    },
    {
        name = "youtruck",
        color = Config.PrimaryColor,
        offDutyJob = {
            enabled = false,
            job = "off_mechanic"
        },
        shop = {
            { name = "body_kit",           label = "Body Kit",            price = 250 },
            { name = "wheels",             label = "Wheels",              price = 300 },
            { name = "spray_can",          label = "Spray Can",           price = 75 },
            { name = "wash_sponge",        label = "Wash Sponge",         price = 45 },
            { name = "vehicle_wax",        label = "Vehicle Wax",         price = 120 },
            { name = "fix_kit",            label = "Fix Kit",             price = 650 },
            { name = "engine",             label = "Engine",              price = 3500 },
            { name = "brakes",             label = "Brakes",              price = 450 },
            { name = "transmission",       label = "Transmission",        price = 2200 },
            { name = "turbo",              label = "Turbo",               price = 1800 },
            { name = "antilag_kit",        label = "Anti-Lag Kit",        price = 950 },
            { name = "suspension",         label = "Suspension",          price = 700 },
            --{ name = "armor_plating",      label = "Armor Plating",       price = 1600 },
            { name = "stance_kit",         label = "Stance Kit",          price = 850 },
            --{ name = "nitro_kit",          label = "Nitro Kit",           price = 1400 },
            { name = "vehicle_lights",     label = "Vehicle Lights",      price = 550 },
            { name = "spark_plugs",        label = "Spark Plugs",         price = 120 },
            { name = "engine_oil",         label = "Engine Oil",          price = 90 },
            { name = "engine_coolant",     label = "Engine Coolant",      price = 110 },
            { name = "brake_fluid",        label = "Brake Fluid",         price = 85 },
            { name = "transmission_fluid", label = "Transmission Fluid",  price = 95 },
            { name = "air_filter",         label = "Air Filter",          price = 140 },
            { name = "traction_battery",   label = "Traction Battery",    price = 4200 },
            { name = "inverter",           label = "Power Inverter",      price = 1850 },
            { name = "rgb_controller",     label = "RGB Controller",      price = 650 }
        },
        partsDeliveryShop = {
            { name = "body_kit",           label = "Body Kit",            price = 250,  category = "Exterior" },
            { name = "wheels",             label = "Wheels",              price = 300,  category = "Wheels" },
            { name = "spray_can",          label = "Spray Can",           price = 75,   category = "Paint" },
            { name = "wash_sponge",        label = "Wash Sponge",         price = 45,   category = "Service" },
            { name = "vehicle_wax",        label = "Vehicle Wax",         price = 120,  category = "Service" },
            { name = "fix_kit",            label = "Fix Kit",             price = 650,  category = "Service" },
            { name = "engine",             label = "Engine",              price = 3500, category = "Performance" },
            { name = "brakes",             label = "Brakes",              price = 450,  category = "Performance" },
            { name = "transmission",       label = "Transmission",        price = 2200, category = "Performance" },
            { name = "turbo",              label = "Turbo",               price = 1800, category = "Performance" },
            { name = "antilag_kit",        label = "Anti-Lag Kit",        price = 950,  category = "Electronics" },
            { name = "suspension",         label = "Suspension",          price = 700,  category = "Handling" },
            --{ name = "armor_plating",      label = "Armor Plating",       price = 1600, category = "Exterior" },
            { name = "stance_kit",         label = "Stance Kit",          price = 850,  category = "Handling" },
            --{ name = "nitro_kit",          label = "Nitro Kit",           price = 1400, category = "Performance" },
            { name = "vehicle_lights",     label = "Vehicle Lights",      price = 550,  category = "Electronics" },
            { name = "spark_plugs",        label = "Spark Plugs",         price = 120,  category = "Service" },
            { name = "engine_oil",         label = "Engine Oil",          price = 90,   category = "Service" },
            { name = "engine_coolant",     label = "Engine Coolant",      price = 110,  category = "Service" },
            { name = "brake_fluid",        label = "Brake Fluid",         price = 85,   category = "Service" },
            { name = "transmission_fluid", label = "Transmission Fluid",  price = 95,   category = "Service" },
            { name = "air_filter",         label = "Air Filter",          price = 140,  category = "Service" },
            { name = "catalytic_converter", label = "Catalytic Converter", price = 1500, category = "Exhaust" },
            { name = "traction_battery",   label = "Traction Battery",    price = 4200, category = "Electronics" },
            { name = "inverter",           label = "Power Inverter",      price = 1850, category = "Electronics" },
            { name = "rgb_controller",     label = "RGB Controller",      price = 650,  category = "Electronics" }
        },
        tuningCostProfile = {
            performanceStages = {
                engine = {
                    enabled = true,
                    modType = 11,
                    cost = {
                        { cost = 13.95, items = { "engine" } },
                        { cost = 32.56, items = { "engine" } },
                        { cost = 65.12, items = { "engine" } },
                        { cost = 139.53, items = { "engine" } }
                    }
                },
                brakes = {
                    enabled = true,
                    modType = 12,
                    cost = {
                        { cost = 4.65, items = { "brakes" } },
                        { cost = 9.3, items = { "brakes" } },
                        { cost = 18.6, items = { "brakes" } },
                        { cost = 37.2, items = { "brakes" } }
                    }
                },
                transmission = {
                    enabled = true,
                    modType = 13,
                    cost = {
                        { cost = 13.95, items = { "transmission" } },
                        { cost = 20.93, items = { "transmission" } },
                        { cost = 46.51, items = { "transmission" } }
                    }
                },
                suspension = {
                    enabled = true,
                    modType = 15,
                    cost = {
                        { cost = 3.72, items = { "suspension" } },
                        { cost = 7.44, items = { "suspension" } },
                        { cost = 14.88, items = { "suspension" } },
                        { cost = 29.77, items = { "suspension" } },
                        { cost = 40.2, items = { "suspension" } }
                    }
                },
                armor = {
                    enabled = true,
                    modType = 16,
                    cost = {
                        { cost = 69.77, items = { "armor_plating" } },
                        { cost = 116.28, items = { "armor_plating" } },
                        { cost = 130.0, items = { "armor_plating" } },
                        { cost = 150.0, items = { "armor_plating" } },
                        { cost = 180.0, items = { "armor_plating" } },
                        { cost = 190.0, items = { "armor_plating" } }
                    }
                }
            },
            appearanceMods = {
                spoiler = { enabled = true, modType = 0, cost = 4.65, items = { "body_kit" } },
                front_bumper = { enabled = true, modType = 1, cost = 5.12, items = { "body_kit" } },
                rear_bumper = { enabled = true, modType = 2, cost = 5.12, items = { "body_kit" } },
                side_skirt = { enabled = true, modType = 3, cost = 4.65, items = { "body_kit" } },
                exhaust = { enabled = true, modType = 4, cost = 5.12, items = { "body_kit" } },
                roll_cage = { enabled = true, modType = 5, cost = 5.12, items = { "body_kit" } },
                grille = { enabled = true, modType = 6, cost = 3.72, items = { "body_kit" } },
                hood = { enabled = true, modType = 7, cost = 4.88, items = { "body_kit" } },
                left_fender = { enabled = true, modType = 8, cost = 5.12, items = { "body_kit" } },
                right_fender = { enabled = true, modType = 9, cost = 5.12, items = { "body_kit" } },
                roof = { enabled = true, modType = 10, cost = 5.58, items = { "body_kit" } },
                horns = { enabled = true, modType = 14, cost = 1.12, items = { "body_kit" } },
                plate_holder = { enabled = true, modType = 25, cost = 3.49, items = { "body_kit" } },
                vanity_plate = { enabled = true, modType = 26, cost = 1.1, items = { "body_kit" } },
                trim_design = { enabled = true, modType = 27, cost = 6.98, items = { "body_kit" } },
                ornaments = { enabled = true, modType = 28, cost = 0.9, items = { "body_kit" } },
                dashboard = { enabled = true, modType = 29, cost = 4.65, items = { "body_kit" } },
                dial = { enabled = true, modType = 30, cost = 4.19, items = { "body_kit" } },
                door_speaker = { enabled = true, modType = 31, cost = 5.58, items = { "body_kit" } },
                seats = { enabled = true, modType = 32, cost = 4.65, items = { "body_kit" } },
                steering_wheel = { enabled = true, modType = 33, cost = 4.19, items = { "body_kit" } },
                shifter_lever = { enabled = true, modType = 34, cost = 3.26, items = { "body_kit" } },
                plaques = { enabled = true, modType = 35, cost = 4.19, items = { "body_kit" } },
                speaker = { enabled = true, modType = 36, cost = 6.98, items = { "body_kit" } },
                trunk = { enabled = true, modType = 37, cost = 5.58, items = { "body_kit" } },
                hydraulics = { enabled = true, modType = 38, cost = 5.12, items = { "body_kit" } },
                engine_block = { enabled = true, modType = 39, cost = 5.12, items = { "body_kit" } },
                air_filter = { enabled = true, modType = 40, cost = 3.72, items = { "body_kit" } },
                struts = { enabled = true, modType = 41, cost = 6.51, items = { "body_kit" } },
                arch_cover = { enabled = true, modType = 42, cost = 4.19, items = { "body_kit" } },
                aerial = { enabled = true, modType = 43, cost = 1.12, items = { "body_kit" } },
                trim = { enabled = true, modType = 44, cost = 6.05, items = { "body_kit" } },
                tank = { enabled = true, modType = 45, cost = 4.19, items = { "body_kit" } },
                windows = { enabled = true, modType = 46, cost = 4.19, items = { "body_kit" } },
                livery_mod = { enabled = true, modType = 48, cost = 9.3, items = { "body_kit" } }
            },
            wheelTypeCost = {
                sport = { enabled = true, cost = 4.65, items = { "wheels" } },
                muscle = { enabled = true, cost = 4.19, items = { "wheels" } },
                lowrider = { enabled = true, cost = 4.65, items = { "wheels" } },
                suv = { enabled = true, cost = 4.19, items = { "wheels" } },
                offroad = { enabled = true, cost = 4.19, items = { "wheels" } },
                tuner = { enabled = true, cost = 5.12, items = { "wheels" } },
                bike = { enabled = true, cost = 3.26, items = { "wheels" } },
                high_end = { enabled = true, cost = 5.12, items = { "wheels" } },
                benny_original = { enabled = true, cost = 5.12, items = { "wheels" } },
                benny_bespoke = { enabled = true, cost = 5.12, items = { "wheels" } },
                open_wheel = { enabled = true, cost = 5.12, items = { "wheels" } },
                street = { enabled = true, cost = 5.12, items = { "wheels" } },
                track = { enabled = true, cost = 5.12, items = { "wheels" } }
            },
            optionCostByOptionId = {
                stancer_bundle = { enabled = true, cost = 10.25, items = { "stance_kit" } },
                toggle_18 = { enabled = true, cost = 55.81, items = { "turbo" } },
                toggle_22 = { enabled = true, cost = 3.72, items = { "vehicle_lights" } },
                xenon_color = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_0 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_1 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_2 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_3 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_effect = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                neon_effect_speed = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                xenon_effect = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                xenon_effect_speed = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                toggle_20 = { enabled = true, cost = 1.12, items = { "spray_can" } },
                wheel_custom_23 = { enabled = true, cost = 2.12, items = { "wheels" } },
                wheel_custom_24 = { enabled = true, cost = 4.12, items = { "wheels" } },
                wheel_size = { enabled = true, cost = 2.12, items = { "stance_kit" } },
                wheel_width = { enabled = true, cost = 2.12, items = { "stance_kit" } },
                tire_smoke_color = { enabled = true, cost = 1.12, items = { "spray_can" } },
                neon_color = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                color_primary = { enabled = true, cost = 1.12, items = { "spray_can" } },
                color_secondary = { enabled = true, cost = 0.66, items = { "spray_can" } },
                color_pearlescent = { enabled = true, cost = 0.88, items = { "spray_can" } },
                color_wheel = { enabled = true, cost = 0.66, items = { "spray_can" } },
                color_dashboard = { enabled = true, cost = 0.0, items = { "spray_can" } },
                color_interior = { enabled = true, cost = 0.0, items = { "spray_can" } },
                window_tint = { enabled = true, cost = 1.12, items = { "spray_can" } },
                plate_index = { enabled = true, cost = 1.1, items = { "body_kit" } },
                livery = { enabled = true, cost = 9.3, items = { "body_kit" } },
                extra_1 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_2 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_3 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_4 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_5 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_6 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_7 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_8 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_9 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_10 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_11 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_12 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_13 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_14 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_15 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_16 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_17 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_18 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_19 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_20 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                handling_drivetrain = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 13.95, items = { "stance_kit" } },
                        [2] = { cost = 13.95, items = { "stance_kit" } },
                        [3] = { cost = 13.95, items = { "stance_kit" } }
                    }
                },
                antilag_enabled = { enabled = true, cost = 18.6, items = { "antilag_kit" } },
                twostep_enabled = { enabled = true, cost = 16.28, items = { "antilag_kit" } },
                handling_drift_tuning = { enabled = true, cost = 23.26, items = { "stance_kit" } },
                handling_engine_upgrade = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 18.6, items = { "engine" } },
                        [2] = { cost = 34.88, items = { "engine" } },
                        [3] = { cost = 65.12, items = { "engine" } }
                    }
                },
                handling_tyre_compound = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 18.6, items = { "wheels" } },
                        [2] = { cost = 23.26, items = { "wheels" } },
                        [3] = { cost = 16.28, items = { "wheels" } }
                    }
                },
                handling_ceramic_brakes = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 16.28, items = { "brakes" } }
                    }
                }
            }
        },
        props = {
            { model = "prop_roadcone02a", label = "Traffic Cone" },
            { model = "prop_barrier_work05", label = "Barrier" },
            { model = "prop_cs_cardbox_01", label = "Parts Box" },
            { model = "v_31a_worklight_03b", label = "Worklight Stand" },
            { model = "prop_worklight_02a", label = "Worklight" },
            { model = "xs_prop_x18_engine_hoist_02a", label = "Engine Hoist" }
        },
        vehicles = {
            {
                name = "Burrito",
                model = "burrito",
                price = 75000,
                trunkCapacity = 80,
                garageType = "vehicle",
            },
            {
                name = "Tow Truck",
                model = "towtruck4",
                price = 75000,
                trunkCapacity = 80,
                garageType = "vehicle",
            },
            {
                name = "Flatbed",
                model = "flatbed",
                price = 60000,
                trunkCapacity = 55,
                garageType = "vehicle"
            },
            {
                name = "Forklift",
                model = "forklift",
                price = 35000,
                trunkCapacity = 0,
                garageType = "vehicle"
            }
            -- {
            --     name = "Helicopter",
            --     model = "polmav",
            --     price = 250000,
            --     trunkCapacity = 25,
            --     garageType = "helicopter"
            -- }
        }
    },
    {
        name = "dealer204",
        color = Config.PrimaryColor,
        offDutyJob = {
            enabled = false,
            job = "off_mechanic"
        },
        shop = {
            { name = "body_kit",           label = "Body Kit",            price = 250 },
            { name = "wheels",             label = "Wheels",              price = 300 },
            { name = "spray_can",          label = "Spray Can",           price = 75 },
            { name = "wash_sponge",        label = "Wash Sponge",         price = 45 },
            { name = "vehicle_wax",        label = "Vehicle Wax",         price = 120 },
            { name = "fix_kit",            label = "Fix Kit",             price = 650 },
            { name = "engine",             label = "Engine",              price = 3500 },
            { name = "brakes",             label = "Brakes",              price = 450 },
            { name = "transmission",       label = "Transmission",        price = 2200 },
            { name = "turbo",              label = "Turbo",               price = 1800 },
            { name = "antilag_kit",        label = "Anti-Lag Kit",        price = 950 },
            { name = "suspension",         label = "Suspension",          price = 700 },
            --{ name = "armor_plating",      label = "Armor Plating",       price = 1600 },
            { name = "stance_kit",         label = "Stance Kit",          price = 850 },
            --{ name = "nitro_kit",          label = "Nitro Kit",           price = 1400 },
            { name = "vehicle_lights",     label = "Vehicle Lights",      price = 550 },
            { name = "spark_plugs",        label = "Spark Plugs",         price = 120 },
            { name = "engine_oil",         label = "Engine Oil",          price = 90 },
            { name = "engine_coolant",     label = "Engine Coolant",      price = 110 },
            { name = "brake_fluid",        label = "Brake Fluid",         price = 85 },
            { name = "transmission_fluid", label = "Transmission Fluid",  price = 95 },
            { name = "air_filter",         label = "Air Filter",          price = 140 },
            { name = "traction_battery",   label = "Traction Battery",    price = 4200 },
            { name = "inverter",           label = "Power Inverter",      price = 1850 },
            { name = "rgb_controller",     label = "RGB Controller",      price = 650 }
        },
        partsDeliveryShop = {
            { name = "body_kit",           label = "Body Kit",            price = 250,  category = "Exterior" },
            { name = "wheels",             label = "Wheels",              price = 300,  category = "Wheels" },
            { name = "spray_can",          label = "Spray Can",           price = 75,   category = "Paint" },
            { name = "wash_sponge",        label = "Wash Sponge",         price = 45,   category = "Service" },
            { name = "vehicle_wax",        label = "Vehicle Wax",         price = 120,  category = "Service" },
            { name = "fix_kit",            label = "Fix Kit",             price = 650,  category = "Service" },
            { name = "engine",             label = "Engine",              price = 3500, category = "Performance" },
            { name = "brakes",             label = "Brakes",              price = 450,  category = "Performance" },
            { name = "transmission",       label = "Transmission",        price = 2200, category = "Performance" },
            { name = "turbo",              label = "Turbo",               price = 1800, category = "Performance" },
            { name = "antilag_kit",        label = "Anti-Lag Kit",        price = 950,  category = "Electronics" },
            { name = "suspension",         label = "Suspension",          price = 700,  category = "Handling" },
            --{ name = "armor_plating",      label = "Armor Plating",       price = 1600, category = "Exterior" },
            { name = "stance_kit",         label = "Stance Kit",          price = 850,  category = "Handling" },
            --{ name = "nitro_kit",          label = "Nitro Kit",           price = 1400, category = "Performance" },
            { name = "vehicle_lights",     label = "Vehicle Lights",      price = 550,  category = "Electronics" },
            { name = "spark_plugs",        label = "Spark Plugs",         price = 120,  category = "Service" },
            { name = "engine_oil",         label = "Engine Oil",          price = 90,   category = "Service" },
            { name = "engine_coolant",     label = "Engine Coolant",      price = 110,  category = "Service" },
            { name = "brake_fluid",        label = "Brake Fluid",         price = 85,   category = "Service" },
            { name = "transmission_fluid", label = "Transmission Fluid",  price = 95,   category = "Service" },
            { name = "air_filter",         label = "Air Filter",          price = 140,  category = "Service" },
            { name = "catalytic_converter", label = "Catalytic Converter", price = 1500, category = "Exhaust" },
            { name = "traction_battery",   label = "Traction Battery",    price = 4200, category = "Electronics" },
            { name = "inverter",           label = "Power Inverter",      price = 1850, category = "Electronics" },
            { name = "rgb_controller",     label = "RGB Controller",      price = 650,  category = "Electronics" }
        },
        tuningCostProfile = {
            performanceStages = {
                engine = {
                    enabled = true,
                    modType = 11,
                    cost = {
                        { cost = 13.95, items = { "engine" } },
                        { cost = 32.56, items = { "engine" } },
                        { cost = 65.12, items = { "engine" } },
                        { cost = 139.53, items = { "engine" } }
                    }
                },
                brakes = {
                    enabled = true,
                    modType = 12,
                    cost = {
                        { cost = 4.65, items = { "brakes" } },
                        { cost = 9.3, items = { "brakes" } },
                        { cost = 18.6, items = { "brakes" } },
                        { cost = 37.2, items = { "brakes" } }
                    }
                },
                transmission = {
                    enabled = true,
                    modType = 13,
                    cost = {
                        { cost = 13.95, items = { "transmission" } },
                        { cost = 20.93, items = { "transmission" } },
                        { cost = 46.51, items = { "transmission" } }
                    }
                },
                suspension = {
                    enabled = true,
                    modType = 15,
                    cost = {
                        { cost = 3.72, items = { "suspension" } },
                        { cost = 7.44, items = { "suspension" } },
                        { cost = 14.88, items = { "suspension" } },
                        { cost = 29.77, items = { "suspension" } },
                        { cost = 40.2, items = { "suspension" } }
                    }
                },
                armor = {
                    enabled = true,
                    modType = 16,
                    cost = {
                        { cost = 69.77, items = { "armor_plating" } },
                        { cost = 116.28, items = { "armor_plating" } },
                        { cost = 130.0, items = { "armor_plating" } },
                        { cost = 150.0, items = { "armor_plating" } },
                        { cost = 180.0, items = { "armor_plating" } },
                        { cost = 190.0, items = { "armor_plating" } }
                    }
                }
            },
            appearanceMods = {
                spoiler = { enabled = true, modType = 0, cost = 4.65, items = { "body_kit" } },
                front_bumper = { enabled = true, modType = 1, cost = 5.12, items = { "body_kit" } },
                rear_bumper = { enabled = true, modType = 2, cost = 5.12, items = { "body_kit" } },
                side_skirt = { enabled = true, modType = 3, cost = 4.65, items = { "body_kit" } },
                exhaust = { enabled = true, modType = 4, cost = 5.12, items = { "body_kit" } },
                roll_cage = { enabled = true, modType = 5, cost = 5.12, items = { "body_kit" } },
                grille = { enabled = true, modType = 6, cost = 3.72, items = { "body_kit" } },
                hood = { enabled = true, modType = 7, cost = 4.88, items = { "body_kit" } },
                left_fender = { enabled = true, modType = 8, cost = 5.12, items = { "body_kit" } },
                right_fender = { enabled = true, modType = 9, cost = 5.12, items = { "body_kit" } },
                roof = { enabled = true, modType = 10, cost = 5.58, items = { "body_kit" } },
                horns = { enabled = true, modType = 14, cost = 1.12, items = { "body_kit" } },
                plate_holder = { enabled = true, modType = 25, cost = 3.49, items = { "body_kit" } },
                vanity_plate = { enabled = true, modType = 26, cost = 1.1, items = { "body_kit" } },
                trim_design = { enabled = true, modType = 27, cost = 6.98, items = { "body_kit" } },
                ornaments = { enabled = true, modType = 28, cost = 0.9, items = { "body_kit" } },
                dashboard = { enabled = true, modType = 29, cost = 4.65, items = { "body_kit" } },
                dial = { enabled = true, modType = 30, cost = 4.19, items = { "body_kit" } },
                door_speaker = { enabled = true, modType = 31, cost = 5.58, items = { "body_kit" } },
                seats = { enabled = true, modType = 32, cost = 4.65, items = { "body_kit" } },
                steering_wheel = { enabled = true, modType = 33, cost = 4.19, items = { "body_kit" } },
                shifter_lever = { enabled = true, modType = 34, cost = 3.26, items = { "body_kit" } },
                plaques = { enabled = true, modType = 35, cost = 4.19, items = { "body_kit" } },
                speaker = { enabled = true, modType = 36, cost = 6.98, items = { "body_kit" } },
                trunk = { enabled = true, modType = 37, cost = 5.58, items = { "body_kit" } },
                hydraulics = { enabled = true, modType = 38, cost = 5.12, items = { "body_kit" } },
                engine_block = { enabled = true, modType = 39, cost = 5.12, items = { "body_kit" } },
                air_filter = { enabled = true, modType = 40, cost = 3.72, items = { "body_kit" } },
                struts = { enabled = true, modType = 41, cost = 6.51, items = { "body_kit" } },
                arch_cover = { enabled = true, modType = 42, cost = 4.19, items = { "body_kit" } },
                aerial = { enabled = true, modType = 43, cost = 1.12, items = { "body_kit" } },
                trim = { enabled = true, modType = 44, cost = 6.05, items = { "body_kit" } },
                tank = { enabled = true, modType = 45, cost = 4.19, items = { "body_kit" } },
                windows = { enabled = true, modType = 46, cost = 4.19, items = { "body_kit" } },
                livery_mod = { enabled = true, modType = 48, cost = 9.3, items = { "body_kit" } }
            },
            wheelTypeCost = {
                sport = { enabled = true, cost = 4.65, items = { "wheels" } },
                muscle = { enabled = true, cost = 4.19, items = { "wheels" } },
                lowrider = { enabled = true, cost = 4.65, items = { "wheels" } },
                suv = { enabled = true, cost = 4.19, items = { "wheels" } },
                offroad = { enabled = true, cost = 4.19, items = { "wheels" } },
                tuner = { enabled = true, cost = 5.12, items = { "wheels" } },
                bike = { enabled = true, cost = 3.26, items = { "wheels" } },
                high_end = { enabled = true, cost = 5.12, items = { "wheels" } },
                benny_original = { enabled = true, cost = 5.12, items = { "wheels" } },
                benny_bespoke = { enabled = true, cost = 5.12, items = { "wheels" } },
                open_wheel = { enabled = true, cost = 5.12, items = { "wheels" } },
                street = { enabled = true, cost = 5.12, items = { "wheels" } },
                track = { enabled = true, cost = 5.12, items = { "wheels" } }
            },
            optionCostByOptionId = {
                stancer_bundle = { enabled = true, cost = 10.25, items = { "stance_kit" } },
                toggle_18 = { enabled = true, cost = 55.81, items = { "turbo" } },
                toggle_22 = { enabled = true, cost = 3.72, items = { "vehicle_lights" } },
                xenon_color = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_0 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_1 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_2 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_3 = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                neon_effect = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                neon_effect_speed = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                xenon_effect = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                xenon_effect_speed = { enabled = true, cost = 0.0, items = { "vehicle_lights" } },
                toggle_20 = { enabled = true, cost = 1.12, items = { "spray_can" } },
                wheel_custom_23 = { enabled = true, cost = 2.12, items = { "wheels" } },
                wheel_custom_24 = { enabled = true, cost = 4.12, items = { "wheels" } },
                wheel_size = { enabled = true, cost = 2.12, items = { "stance_kit" } },
                wheel_width = { enabled = true, cost = 2.12, items = { "stance_kit" } },
                tire_smoke_color = { enabled = true, cost = 1.12, items = { "spray_can" } },
                neon_color = { enabled = true, cost = 1.12, items = { "vehicle_lights" } },
                color_primary = { enabled = true, cost = 1.12, items = { "spray_can" } },
                color_secondary = { enabled = true, cost = 0.66, items = { "spray_can" } },
                color_pearlescent = { enabled = true, cost = 0.88, items = { "spray_can" } },
                color_wheel = { enabled = true, cost = 0.66, items = { "spray_can" } },
                color_dashboard = { enabled = true, cost = 0.0, items = { "spray_can" } },
                color_interior = { enabled = true, cost = 0.0, items = { "spray_can" } },
                window_tint = { enabled = true, cost = 1.12, items = { "spray_can" } },
                plate_index = { enabled = true, cost = 1.1, items = { "body_kit" } },
                livery = { enabled = true, cost = 9.3, items = { "body_kit" } },
                extra_1 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_2 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_3 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_4 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_5 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_6 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_7 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_8 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_9 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_10 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_11 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_12 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_13 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_14 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_15 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_16 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_17 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_18 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_19 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                extra_20 = { enabled = true, cost = 0.0, items = { "body_kit" } },
                handling_drivetrain = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 13.95, items = { "stance_kit" } },
                        [2] = { cost = 13.95, items = { "stance_kit" } },
                        [3] = { cost = 13.95, items = { "stance_kit" } }
                    }
                },
                antilag_enabled = { enabled = true, cost = 18.6, items = { "antilag_kit" } },
                twostep_enabled = { enabled = true, cost = 16.28, items = { "antilag_kit" } },
                handling_drift_tuning = { enabled = true, cost = 23.26, items = { "stance_kit" } },
                handling_engine_upgrade = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 18.6, items = { "engine" } },
                        [2] = { cost = 34.88, items = { "engine" } },
                        [3] = { cost = 65.12, items = { "engine" } }
                    }
                },
                handling_tyre_compound = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 18.6, items = { "wheels" } },
                        [2] = { cost = 23.26, items = { "wheels" } },
                        [3] = { cost = 16.28, items = { "wheels" } }
                    }
                },
                handling_ceramic_brakes = {
                    enabled = true,
                    cost = {
                        [0] = { cost = 0.0, items = {} },
                        [1] = { cost = 16.28, items = { "brakes" } }
                    }
                }
            }
        },
        props = {
            { model = "prop_roadcone02a", label = "Traffic Cone" },
            { model = "prop_barrier_work05", label = "Barrier" },
            { model = "prop_cs_cardbox_01", label = "Parts Box" },
            { model = "v_31a_worklight_03b", label = "Worklight Stand" },
            { model = "prop_worklight_02a", label = "Worklight" },
            { model = "xs_prop_x18_engine_hoist_02a", label = "Engine Hoist" }
        },
        vehicles = {
            {
                name = "Burrito",
                model = "burrito",
                price = 75000,
                trunkCapacity = 80,
                garageType = "vehicle",
            },
            {
                name = "Tow Truck",
                model = "towtruck4",
                price = 75000,
                trunkCapacity = 80,
                garageType = "vehicle",
            },
            {
                name = "Flatbed",
                model = "flatbed",
                price = 60000,
                trunkCapacity = 55,
                garageType = "vehicle"
            },
            {
                name = "Forklift",
                model = "forklift",
                price = 35000,
                trunkCapacity = 0,
                garageType = "vehicle"
            }
            -- {
            --     name = "Helicopter",
            --     model = "polmav",
            --     price = 250000,
            --     trunkCapacity = 25,
            --     garageType = "helicopter"
            -- }
        }
    },
}

Config.Interactions = {
    self_service_tuning = {
        public = true,
        unique = false,
        forceMarkerInteraction = true,
        interactionDistance = 2.5,
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Self Service Tuning",
            sprite = 72,
            color = 5
        },
        npc = {
            enabled = false
        }
    },
    engine_hoist_location = {
        public = true,
        interaction = false,
        unique = false,
        placementModel = "xs_prop_x18_engine_hoist_02a",
        marker = {
            enabled = false,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Engine Hoist",
            sprite = 402,
            color = 5
        },
        npc = {
            enabled = false
        }
    },
    workshop_lift = {
        public = false,
        interaction = false,
        unique = false,
        placementModel = "sky_carlift_platform",
        marker = {
            enabled = false,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Workshop Lift",
            sprite = 446,
            color = 5
        },
        npc = {
            enabled = false
        }
    },
    part_delivery = {
        public = false,
        interaction = true,
        interactionDistance = 2.5,
        unique = false,
        marker = {
            enabled = false,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Parts Delivery",
            sprite = 478,
            color = 5
        },
        npc = {
            enabled = false
        }
    },
    stolen_parts_dealer = {
        public = true,
        interaction = true,
        unique = false,
        marker = {
            enabled = false,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Parts Dealer",
            sprite = 500,
            color = 1
        },
        npc = {
            enabled = true,
            name = "Parts Dealer",
            pedHash = "s_m_m_autoshop_01",
            animation = {
                dict = "amb@world_human_leaning@male@wall@back@mobile@idle_a",
                name = "idle_a"
            }
        }
    }
}

Config.PartsTheft = {
    item = "lug_wrench",
    removeItemAfterUse = false,
    stolenWheelItem = "wheels",
    catalyticConverterItem = "catalytic_converter",
    dealer = {
        account = "money",
        sellDistance = 5.0,
        items = {
            { name = "wheels", label = "Wheel", amount = 1, price = 120 },
            { name = "catalytic_converter", label = "Catalytic Converter", amount = 1, price = 600 }
        }
    },
    dispatch = {
        enabled = true,
        jobs = { "police", "bcso" },
        title = "Vehicle parts theft",
        message = "Suspicious vehicle parts theft reported near {plate}.",
        cooldownSeconds = 120
    }
}

Config.PartsDelivery = {
    deliveryTimeSeconds = 60,
    timerHud = {
        enabled = true,
        position = {
            left = "50%",
            top = "3vh"
        }
    },
    paymentMethods = {
        own_card = true,
        company_card = true
    },
    openDurationMs = 5500
}

Config.CarryItems = {
    storageDistance = 2.5,
    forkliftModels = { "forklift" },
    items = {
        engine = {
            enabled = true,
            transport = "engine_lift",
            prop = "prop_car_engine_01",
            attach = { bone = 28422, x = 0.0, y = -0.18, z = -0.18, rx = 0.0, ry = 90.0, rz = 0.0 }
        },
        wheels = {
            enabled = true,
            prop = "prop_wheel_01",
            attach = { bone = 28422, x = 0.0, y = -0.10, z = -0.16, rx = 0.0, ry = 90.0, rz = 0.0 }
        },
        body_kit = {
            enabled = true,
            prop = "prop_cs_cardbox_01",
            attach = { bone = 28422, x = 0.0, y = -0.12, z = -0.12, rx = 0.0, ry = 0.0, rz = 0.0 }
        },
        transmission = {
            enabled = true,
            prop = "prop_cs_cardbox_01",
            attach = { bone = 28422, x = 0.0, y = -0.12, z = -0.12, rx = 0.0, ry = 0.0, rz = 0.0 }
        },
        turbo = {
            enabled = true,
            prop = "prop_cs_cardbox_01",
            attach = { bone = 28422, x = 0.0, y = -0.12, z = -0.12, rx = 0.0, ry = 0.0, rz = 0.0 }
        },
        brakes = {
            enabled = true,
            prop = "prop_cs_cardbox_01",
            attach = { bone = 28422, x = 0.0, y = -0.12, z = -0.12, rx = 0.0, ry = 0.0, rz = 0.0 }
        },
        suspension = {
            enabled = true,
            prop = "prop_cs_cardbox_01",
            attach = { bone = 28422, x = 0.0, y = -0.12, z = -0.12, rx = 0.0, ry = 0.0, rz = 0.0 }
        },
        armor_plating = {
            enabled = true,
            prop = "prop_cs_cardbox_01",
            attach = { bone = 28422, x = 0.0, y = -0.12, z = -0.12, rx = 0.0, ry = 0.0, rz = 0.0 }
        },
        traction_battery = {
            enabled = true,
            prop = "prop_car_battery_01",
            attach = { bone = 28422, x = 0.0, y = -0.14, z = -0.14, rx = 0.0, ry = 90.0, rz = 0.0 }
        }
    }
}

Config.OrderInstall = {
    nonMinigameDurationMs = 10000
}

Config.TuningWorkshopRequirement = {
    -- When enabled, tuning order installs must be started and completed near a self_service_tuning workshop point.
    requireForInstall = false,
    -- When enabled, tuning removals must be started and completed near a self_service_tuning workshop point.
    requireForRemoval = false,
    -- Distance from the player to a self_service_tuning point.
    distance = 50.0
}

Config.VehicleCare = {
    wash = {
        item = "wash_sponge",
        removeAfterUse = true
    },
    wax = {
        item = "vehicle_wax",
        removeAfterUse = true,
        cleanKilometers = 35
    },
    repair = {
        item = "fix_kit",
        removeAfterUse = true,
        durationMs = 10000,
        maxDistance = 6.0,
        repairVehicleDamage = true,
        fixRealisticWheelDamage = true,
        -- Controls which mechanic wear parts are restored by the fix kit.
        -- Set a part to false if it should still require the dedicated diagnostics repair flow/item.
        repairWearParts = {
            tyres = true,
            brake_pads = true,
            suspension = true,
            spark_plugs = true,
            engine_oil = true,
            coolant = true,
            brake_fluid = true,
            transmission_fluid = true,
            clutch = true,
            air_filter = true,
            traction_battery = true,
            inverter = true,
            catalytic_converter = true
        }
    }
}

-- ============================================================================
-- Vehicle Wear System
-- Keep all wear configuration for each part in one place:
-- - kilometersToZero: driven kilometres until the part reaches 0%
-- - item: inventory item required to repair the part
-- - removeAfterUse: consume one item on successful repair
-- - flow: install flow used by the repair process
-- ============================================================================
Config.Wear = {
    parts = {
        tyres = {
            kilometersToZero = 1250, -- 0% -> all 4 tyres burst
            item = "wheels",
            removeAfterUse = true,
            flow = "wheel"
        },
        brake_pads = {
            kilometersToZero = 1667, -- 0% -> braking force scales to 20% of original
            item = "brakes",
            removeAfterUse = true,
            flow = "performance"
        },
        suspension = {
            kilometersToZero = 2500, -- 0% -> suspension force and damping degrade
            item = "suspension",
            removeAfterUse = true,
            flow = "underbody_neon"
        },
        spark_plugs = {
            kilometersToZero = 3333, -- 0% -> engine won't start
            item = "spark_plugs",
            removeAfterUse = true,
            flow = "performance"
        },
        engine_oil = {
            kilometersToZero = 4000, -- 0% -> engine smokes then breaks after ~30s
            item = "engine_oil",
            removeAfterUse = true,
            flow = "oil_change"
        },
        coolant = {
            kilometersToZero = 5000,
            item = "engine_coolant",
            removeAfterUse = true,
            flow = "fluid_refill"
        },
        brake_fluid = {
            kilometersToZero = 3333,
            item = "brake_fluid",
            removeAfterUse = true,
            flow = "fluid_refill"
        },
        transmission_fluid = {
            kilometersToZero = 5000,
            item = "transmission_fluid",
            removeAfterUse = true,
            flow = "fluid_refill"
        },
        clutch = {
            kilometersToZero = 4000, -- 0% -> engine smokes then breaks after ~30s
            item = "transmission",
            removeAfterUse = true,
            flow = "performance"
        },
        air_filter = {
            kilometersToZero = 5000, -- 0% -> engine smokes then breaks after ~30s
            item = "air_filter",
            removeAfterUse = true,
            flow = "performance"
        },
        catalytic_converter = {
            kilometersToZero = 0,
            item = "catalytic_converter",
            removeAfterUse = true,
            flow = "catalytic_converter"
        },
        traction_battery = {
            kilometersToZero = 6000, -- 0% -> vehicle won't drive
            item = "traction_battery",
            removeAfterUse = true,
            flow = "underbody_neon"
        },
        inverter = {
            kilometersToZero = 4500, -- 0% -> vehicle enters limp mode
            item = "inverter",
            removeAfterUse = true,
            flow = "performance"
        },
    }
}
Config.WheelDamage = {
    multipliers = {
        default = 1.0,
        offroadWheels = 0.65,
        vehicleClasses = {
            [0] = 0.05,  -- Compacts
            [1] = 0.20,  -- Sedans
            [2] = 0.20,  -- SUVs
            [3] = 0.20, -- Coupes
            [4] = 0.20, -- Muscle
            [5] = 0.20,  -- Sports Classics
            [6] = 0.20,  -- Sports
            [7] = 0.20,  -- Super
            [8] = 0.0,  -- Motorcycles
            [9] = 0.20,  -- Off-road
            [10] = 0.20, -- Industrial
            [11] = 0.20, -- Utility
            [12] = 0.20, -- Vans
            [13] = 0.0,  -- Cycles
            [14] = 0.0,  -- Boats
            [15] = 0.0,  -- Helicopters
            [16] = 0.0,  -- Planes
            [17] = 0.20, -- Service
            [18] = 0.20,  -- Emergency
            [19] = 0.20, -- Military
            [20] = 0.20, -- Commercial
            [21] = 0.0,  -- Trains
            [22] = 0.20   -- Open Wheel
        }
    }
}

Config.TuningCostProfile = {
    addRevenueToSociety = true, -- Deposit paid tuning order money into the society account of the tuning job.
    -- Self-service pricing visibility for public users:
    -- true  = non-mechanic/public users see normal prices
    -- false = non-mechanic/public users see 0 prices
    publicUsersSeePrices = true,
    fallbackVehicleValue = 50000,
    freeVehicles = {
        -- Add vehicle spawn names here to make all tuning options free for that model.
        -- Examples:
        -- "sultan",
        -- "burrito"
    },
    priceType = "percentage", -- "percentage" treats cost as a vehicle price percent, "fixed" treats cost as a money value.
    -- With priceType = "percentage", cost = 5.0 means 5% of the vehicle price.
    -- With priceType = "fixed", cost = 5000 means $5,000.
    -- Use cost = { ... } for staged upgrades and cost = number for flat-cost mods.
    -- Set enabled = false on a tuning option to hide it from the tuning menu.
    -- Optional item requirements can be configured next to any cost without changing the price:
    -- Staged upgrades: cost = { { cost = 13.95, items = { "inline4_engine" } }, { cost = 32.56, items = { "v6_engine" } } }
    -- Flat mods: spoiler = { enabled = true, modType = 0, cost = 4.65, items = { "spoiler_kit" } }
    -- Wheel types / option IDs: sport = { enabled = true, cost = 4.65, items = { "sport_wheels" } }, toggle_18 = { enabled = true, cost = 55.81, items = { "turbo" } }
    -- Direct option presets: handling_engine_upgrade = { enabled = true, cost = { [0] = { cost = 0.0, items = {} }, [1] = { cost = 18.6, items = { "engine" } } } }
    -- Configured items are removed on successful install unless removeAfterUse = false is set on that cost entry.
    -- Leave items empty when an option should not require inventory items.
}

Config.MileageHud = {
    digits = 6,
    position = {
        --right = "2.8vh",
        bottom = "25vh",
        left = "2.5vh",
        -- top = "3.2vh",
    }
}
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
