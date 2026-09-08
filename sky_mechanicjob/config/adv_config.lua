if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/config/adv_config.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

Config = Config or {}

Config.AutoExecuteQuery = true -- Automatically creates/updates database tables on start. Set to false to disable.

Config.VehiclePersistence = Config.VehiclePersistence or {}
-- When enabled, mechanic tuning and Stancer persistence is only loaded/saved for
-- plates that exist in the framework ownership table (`owned_vehicles` or
-- `player_vehicles`). This prevents spawned NPC/admin/job/world vehicles with a
-- matching plate from receiving saved custom stance values.
Config.VehiclePersistence.requireOwnedVehicle = true

Config.VehicleRolloverRecovery = {
    -- When enabled, players cannot use GTA's default steering/throttle inputs to
    -- roll a vehicle back onto its wheels while it is lying on the side or roof.
    disableGtaRecovery = true,
    rollThresholdDegrees = 65.0,
    maxSpeedKmh = 25.0,
    checkIntervalMs = 100
}

-- ============================================================================
-- Per-command permissions
-- Define which groups are allowed to use each command or feature.
-- Group names must match the groups in your framework
-- (e.g. "god", "superadmin", "admin", "supporter", "moderator", etc.).
--
-- If a command is NOT listed here, only the server console can use it.
-- The framework wires `add_ace group.<g> sky_mechanicjob.<command> allow`
-- for each listed group at server start.
-- ============================================================================
Config.CommandPermissions = {
    -- /admintuning [playerId] - Open the tuning menu via admin command
    admintuning = { "god", "superadmin", "admin" },
    -- Admin menu export permission for instant full vehicle repair
    adminrepair = { "god", "superadmin", "admin" },
    -- /debugadminrepair - Test the admin full repair export while debug mode is active
    debugadminrepair = { "god", "superadmin", "admin" },
    -- /debugstancerdefault - Save the current vehicle stance as its reset/default stance while debug mode is active
    debugstancerdefault = { "god", "superadmin", "admin" },
    -- /migrate - Import tuning data from mechanic_vehicledata into sky_mechanic_vehicle_tuning
    migrate = { "god", "superadmin", "admin" },
    -- /workshopcreator - Open the Workshop Creator tool
    workshopcreator = { "god", "superadmin", "admin" },
    -- /debugwearzero [part] or /debugwearzero [plate] [part] - Set a single wear component to 0%
    debugwearzero = { "god", "superadmin", "admin" },
    -- /debugwearzeroall or /debugwearzeroall [plate] - Set all wear components to 0%
    debugwearzeroall = { "god", "superadmin", "admin" },
}

Config.InstantTuning = {
    interactionDistance = 4.0,
    forceMarkerInteraction = true,
    -- When true, instant tuning is restricted to configured mechanic jobs.
    mechanicOnly = false,
    -- Optional global allow-list. When set, only these jobs can use instant tuning.
    -- Example: { "mechanic", "tuner" }
    allowedJobs = nil,
    priceMultiplier = 1.25,
    label = "Instant Tuning",
    marker = {
        enabled = true,
        type = 1,
        offset = vector3(0.0, 0.0, 0.0)
    },
    blip = {
        enabled = false,
        name = "Instant Tuning",
        sprite = 72,
        color = 5
    },
    npc = {
        enabled = false
    },
    locations = {
        -- {
        --     coords = vector3(-337.02, -136.32, 39.01),
        --     heading = 0.0,
        --     label = "Instant Tuning",
        --     mechanicOnly = true,
        --     allowedJobs = { "mechanic" }
        -- }
    }
}

Config.CarryItems = Config.CarryItems or {}
Config.CarryItems.deliveryPallet = {
    enabled = true,
    prop = "prop_boxpile_06a",
    storeDistance = 3.5,
    checkIntervalMs = 450,
    duplicateCleanupDistance = 2.25,
    forkCheck = {
        distance = 6.0,
        minY = 0.35,
        maxY = 4.25,
        minZ = -1.85,
        maxZ = 2.6,
        referenceY = 1.25,
        referenceZ = -0.25
    }
}

Config.Nitro = {
    item = "nitro_kit",
    mechanicOnly = true,
    maxBottles = 3,
    maxLevel = 100,
    activationKey = "LSHIFT",
    minSpeedKmh = 25.0,
    throttleThreshold = 0.85,
    boostRampInPerSecond = 4.8,
    boostRampOutPerSecond = 2.6,
    activeTickMs = 20,
    inputCheckIntervalMs = 80,
    emptyHudHideDelayMs = 1200,
    saveIntervalMs = 4000,
    hudUpdateIntervalIdleMs = 300,
    hudUpdateIntervalActiveMs = 80,
    installDurationMs = 6000,
    installDistance = 4.0,
    installFrontDistance = 2.2,
    drainPerSecond = 8.5,
    powerMultiplier = 38.0,
    torqueMultiplier = 1.38,
    effectIntervalMs = 180,
    remoteEffectIntervalMs = 320,
    flameScale = 0.72,
    flameDurationMs = 110,
    purgeScale = 0.9,
    purgeDurationMs = 2000,
    purgeTickIntervalMs = 220,
    purgeHoldDurationMs = 260,
    purgeEnabled = true,
    screenShake = 0.14,
    shakeIntervalMs = 100,
    notifyOnVehicleEnter = true,
    exhaustBoneNames = {
        "exhaust",
        "exhaust_2",
        "exhaust_3",
        "exhaust_4",
        "exhaust_5",
        "exhaust_6",
        "exhaust_7",
        "exhaust_8",
        "exhaust_9",
        "exhaust_10",
        "exhaust_11",
        "exhaust_12",
        "exhaust_13",
        "exhaust_14",
        "exhaust_15",
        "exhaust_16"
    },
    purgeNozzles = {
        {
            bone = "wheel_lf",
            offset = { x = 0.03, y = 0.10, z = 0.20 },
            rotation = { x = 20.0, y = 0.0, z = 0.5 }
        },
        {
            bone = "wheel_rf",
            offset = { x = -0.03, y = 0.10, z = 0.20 },
            rotation = { x = 20.0, y = 0.0, z = 0.5 }
        }
    },
    hud = {
        enabled = true,
        position = {
            left = "50%",
            top = "3vh"
        }
    }
}

Config.AntiLag = {
    -- Enable Anti-Lag by default right after install.
    defaultEnabled = false,
    -- RPM threshold before Anti-Lag can trigger (0.0 - 1.0).
    activationRpm = 0.7,
    -- Minimum gear required before Anti-Lag can trigger.
    minGear = 2,
    -- Random burst interval window in milliseconds.
    burstIntervalMinMs = 25,
    burstIntervalMaxMs = 200,
    -- Backfire flame behavior.
    flameDurationMs = 90,
    flameScaleMin = 0.45,
    flameScaleMax = 1.25,
    defaultFlameScaleLevel = 10,
    -- Backfire volume level for stored records (0-10).
    defaultVolumeLevel = 5,
    -- Turbo pressure kick on burst (can feel like a small acceleration push).
    turboPressureSpikeEnabled = false,
    turboPressureSpike = 25.0
}

Config.TwoStep = {
    -- Core behavior
    enabled = true,
    useFootBrake = true,   -- normal brake key (S)
    useHandbrake = false,  -- handbrake key (SPACE)

    -- Activation window
    maxSpeedKmh = 25.0,
    minGear = 0,
    maxGear = 2,
    rpmWindowMin = 0.08,
    rpmWindowMax = 0.95,

    -- Backfire cadence / visuals
    burstIntervalMinMs = 55,
    burstIntervalMaxMs = 115,
    flameDurationMs = 130,
    flameScaleMin = 0.7,
    flameScaleMax = 1.8,
    defaultFlameScaleLevel = 10,
    defaultVolumeLevel = 8,

    -- Optional pressure spike during active 2-step
    turboPressureSpikeEnabled = true,
    turboPressureSpike = 28.0,

    -- Launch control / transbrake-like hold
    launchControl = {
        enabled = true,
        -- Holds vehicle on the spot while 2-step is active.
        holdHandbrake = true,
        -- Attempts to keep engine near this RPM (0.0 - 1.0 native RPM range).
        rpmTarget = 0.72,
        -- Torque multiplier while launch is held (0.0 - 1.0).
        holdTorqueMultiplier = 0.12,
        -- Torque ramp after brake release for smoother launch (ms).
        releaseRampMs = 90,
        -- Starting torque multiplier for the release ramp.
        releaseTorqueStartMultiplier = 0.9
    }
}

Config.WheelSizeOptions = {
    scale = 100,
    bounds = {
        size = { min = 50, max = 150 },
        width = { min = 50, max = 150 }
    }
}

Config.RgbControllerItem = "rgb_controller"

Config.WorkshopLiftSystem = {
    creator = {
        frameModel = "sky_carlift_platform",
        platformModel = "sky_carlift_frame",
        -- Optional: define multiple lift model sets. The first entry is used as
        -- the default spawn set. Existing MLO props are auto-detected from all
        -- sets below when existingProps.enabled is true.
        modelSets = {
            {
                name = "default",
                frameModel = "sky_carlift_platform",
                platformModel = "sky_carlift_frame"
            },
            -- Example:
            -- {
            --     name = "custom_mlo_lift",
            --     frameModel = "my_lift_base_prop",
            --     platformModel = "my_lift_platform_prop"
            -- }
        }
    },
    existingProps = {
        -- When enabled, the lift system searches near each workshop_lift point
        -- for configured lift props already placed by an MLO/YMAP and uses them
        -- instead of spawning duplicate objects.
        enabled = true,
        searchRadius = 1.2,
        zTolerance = 1.0,
        autoDiscover = {
            -- When enabled, configured MLO/YMAP lift props are detected without
            -- placing a workshop_lift point in the creator.
            enabled = true,
            pairRadius = 1.4,
            zTolerance = 1.0,
            refreshIntervalMs = 30000
        }
    },
    -- Distance from the placed lift point where the radial lift controls are available.
    -- Lift points are usually placed at the center of the platform, so this should be
    -- large enough to use the controls while standing at the side of the lift.
    radialDistance = 4.5,
    motion = {
        tickMs = 10,
        unitsPerTick = 0.008
    },
    limits = {
        travelHeight = 2.0
    }
}

-- Note:
-- GetIsVehicleElectric works automatically on game build 3258 and higher.
-- If your server uses a lower game build, this fallback table is used instead.
-- Add electric vehicle spawn names here for lower game builds, for example:
-- models = { "voltic", "neon", "raiden" }
Config.ElectricVehicleFallback = {
    models = {
        "airtug",
        "caddy",
        "caddy2",
        "caddy3",
        "cyclone",
        "cyclone2",
        "dilettante",
        "imorgon",
        "iwagen",
        "khamelion",
        "neon",
        "omnisegt",
        "powersurge",
        "raiden",
        "surge",
        "tezeract",
        "virtue",
        "voltic",
        "voltic2"
    }
}

Config.CustomHandlingOptions = {
    -- Set this to true only when another handling editor/resource overwrites handling on every vehicle enter.
    -- WARNING: If no other handling script resets the vehicle handling first, this can multiply tuning again on each vehicle enter.
    -- When false, custom handling is applied only once per spawned vehicle to avoid stacking multiplier-based upgrades.
    overwriteHandling = false,
    -- Optional per-vehicle whitelist for drivetrain swaps only.
    -- GTA/FiveM does not expose a native that tells us whether a model can safely switch drivetrain.
    -- Some vehicle handling/model setups break when forced to FWD/AWD through fDriveBiasFront.
    -- Enable this after testing vehicles, then list only models that are known to work.
    drivetrainWhitelist = {
        enabled = false,
        models = {
            -- "sultan",
            -- "elegy"
        }
    },
    profileOrder = {
        "drivetrain",
        "drift_tuning",
        "engine_upgrade",
        "tyre_compound",
        "ceramic_brakes"
    },
    profiles = {
        drivetrain = {
            enabled = true,
            optionId = "handling_drivetrain",
            label = "Drivetrain",
            section = "performance",
            requiredCategory = "custom_tuning",
            installFlow = "underbody_neon",
            cameraPart = "center",
            defaultIndex = 0,
            presets = {
                { label = "Stock" },
                { label = "RWD", handling = { fDriveBiasFront = 0.0 } },
                { label = "FWD", handling = { fDriveBiasFront = 1.0 } },
                { label = "AWD", handling = { fDriveBiasFront = 0.5 } }
            }
        },
        engine_upgrade = {
            enabled = true,
            optionId = "handling_engine_upgrade",
            label = "Custom Engine Upgrade",
            section = "performance",
            requiredCategory = "engine",
            installFlow = "hood_install",
            cameraPart = "front",
            defaultIndex = 0,
            presets = {
                { label = "Stock" },
                {
                    label = "ECU Remap + Intake",
                    handlingMul = {
                        fInitialDriveForce = 1.08,
                        fInitialDriveMaxFlatVel = 1.03,
                        fDriveInertia = 1.04,
                        fInitialDragCoeff = 0.98
                    }
                },
                {
                    label = "Street Turbo Kit",
                    handlingMul = {
                        fInitialDriveForce = 1.15,
                        fInitialDriveMaxFlatVel = 1.06,
                        fDriveInertia = 1.08,
                        fInitialDragCoeff = 0.95
                    }
                },
                {
                    label = "Forged Race Build",
                    handlingMul = {
                        fInitialDriveForce = 1.24,
                        fInitialDriveMaxFlatVel = 1.1,
                        fDriveInertia = 1.12,
                        fInitialDragCoeff = 0.92
                    }
                }
            }
        },
        tyre_compound = {
            enabled = true,
            optionId = "handling_tyre_compound",
            label = "Tyre Compound",
            section = "performance",
            requiredCategory = "wheels",
            cameraPart = "wheels_front",
            defaultIndex = 0,
            presets = {
                { label = "Stock" },
                {
                    label = "Slicks",
                    handlingMul = {
                        fTractionCurveMax = 1.16,
                        fTractionCurveMin = 1.11,
                        fTractionLossMult = 0.9,
                        fLowSpeedTractionLossMult = 0.88
                    }
                },
                {
                    label = "Drift Tyres",
                    handlingMul = {
                        fSteeringLock = 1.17,
                        fTractionCurveMax = 0.88,
                        fTractionCurveMin = 0.84,
                        fTractionLossMult = 1.35,
                        fLowSpeedTractionLossMult = 1.4,
                        fDriveInertia = 1.12
                    }
                },
                {
                    label = "Offroad",
                    handlingMul = {
                        fTractionCurveMax = 0.94,
                        fTractionCurveMin = 0.99,
                        fTractionLossMult = 1.13,
                        fLowSpeedTractionLossMult = 1.08
                    }
                }
            }
        },
        ceramic_brakes = {
            enabled = true,
            optionId = "handling_ceramic_brakes",
            label = "Ceramic Brakes",
            section = "performance",
            requiredCategory = "brakes",
            cameraPart = "wheels_front",
            defaultIndex = 0,
            presets = {
                { label = "Stock" },
                {
                    label = "Ceramic Brakes",
                    handlingMul = {
                        fBrakeForce = 1.2,
                        fHandBrakeForce = 1.12
                    }
                }
            }
        }
    }
}
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
