if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/config/config.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

Config.AutoExecuteQuery = true -- Automatically creates/updates database tables on start. Set to false to disable.
Config.DutySystem = true -- Set to false to make job members always count as on duty

-- ============================================================================
-- Per-command permissions
-- Define which groups are allowed to use each command.
-- Group names match FiveM ACE principals (e.g. "admin" resolves to "group.admin").
-- If a command is NOT listed here, only the server console can use it.
-- The framework wires `add_ace group.<g> sky_jobs_base.<command> allow`
-- for each listed group at server start.
-- ============================================================================
Config.CommandPermissions = {
    -- /jobconfig - Open the unified job configurator selector
    jobconfig = { "god", "superadmin", "admin" },
    -- /setboss <job> <grade> - Set the boss grade for a job
    setboss  = { "god", "superadmin", "admin" },
    -- /givejob <playerId> <job> [grade] - Add a job to the player's multi-job list
    givejob = { "god", "superadmin", "admin" },
    -- /removejob <playerId> <job> - Remove a job from the player's multi-job list
    removejob = { "god", "superadmin", "admin" },
    -- /multijobadmin <playerId> [list|add|set|remove] [job] [grade] - Inspect and edit a player's multi-job list
    multijobadmin = { "god", "superadmin", "admin" },
    -- /dutytest [playerId] [on|off] - Debug command to force a duty state on a player
    dutytest = { "god", "superadmin", "admin" },
}

Config.MultiJob = {
    enabled = false,
    command = "jobs",
    giveJobCommand = "givejob",
    removeJobCommand = "removejob",
    adminCommand = "multijobadmin",
    -- Standard job used when a player has no active multi-job anymore.
    -- Example: unemployed rank 0
    defaultJob = "unemployed",
    defaultGrade = 0,
    -- Backwards compatible aliases. Leave nil to use defaultJob/defaultGrade.
    fallbackJob = nil,
    fallbackGrade = nil,
    maxJobs = 8,
    includeCurrentJob = true,
    switchOffDuty = true,
    allowUnregisteredFrameworkJobs = true,
    -- Jobs listed here cannot be removed by the player from the self-service menu.
    -- Admin commands and exports can still remove them.
    selfRemoveBlacklist = {
        -- "police",
        -- "ambulance"
    },
    autoDetectOffDutyJobs = true, -- Automatically links framework pairs such as ballas and off_ballas.
    offDutyPrefix = "off_",
    policeColor = "#173B73",
    medicalColor = "#C73535",
    openKey = nil -- Optional keybind, e.g. "F6". Leave nil to use /jobs only.
}

-- ============================================================================
-- Colleague map blips
-- Live world-map blips for on-duty colleagues of the player's own job.
-- Works for every Sky job (police, ambulance, mechanic, ...) - the server
-- pushes a per-job snapshot every ~1s and the client only renders while the
-- player is on-duty and has the pause/tablet map open.
-- ============================================================================
Config.ColleagueMapBlips = {
    enabled = false,
    showSelf = false,            -- Show your own blip too
    -- Optional per-job map visibility. The key is the viewer job, the values
    -- are the jobs whose colleague blips it can see. If a viewer job is not
    -- listed here, only its own job is shown.
    -- groups = {
    --     police = { "police", "sheriff", "fib" },
    --     sheriff = { "police", "sheriff", "fib" },
    --     fib = { "police", "sheriff", "fib" }
    -- },
    groups = nil,
    requireItem = false,         -- If true, a player is only shown while carrying item
    item = "gps",
    showOnMinimap = false,      -- true = render colleague blips outside the pause-menu map as normal map/minimap blips
    updateIntervalMs = 500,     -- Legacy fallback for pauseMenuRenderIntervalMs
    pauseMenuSnapshotIntervalMs = 500, -- Server snapshot interval while the pause-menu map is open
    pauseMenuRenderIntervalMs = 200,   -- Local blip refresh interval while the pause-menu map is open
    display = 4,                -- Legacy option; pause-menu colleague blips always use display flag 2.
    shortRange = false,
    scale = 0.85,
    color = 3,
    colorLights = 3,            -- Color while vehicle siren is on
    colorLightsAlt = nil,       -- Optional second color for siren flashing
    colorLightsIntervalMs = 450,
    sprites = {
        foot = 1,
        car = 225,
        boat = 427,
        heli = 64,
        car_lights = 56,
        boat_lights = 427,
        heli_lights = 43,
    }
}

Config.EmployeeGpsJammer = {
    enabled = true,
    item = "gps_jammer",
    consumeOnUse = true,
    maxDistance = 3.0,
    durationSeconds = 300,
    cooldownMs = 1500,
    animScenario = "WORLD_HUMAN_STAND_MOBILE",
    animDurationMs = 2500,
    jobs = {
        police = true
    }
}

Config.Nui = {
    itemImageBase = "nui://ox_inventory/web/images",      -- Override to any base path, e.g. "nui://ox_inventory/web/images"
    weaponImageBase = "nui://ox_inventory/web/images",   -- Used when item name starts with "weapon_"; image file uses stripped name (e.g. machinepistol.png)
    propImageBase = "https://cdn.sky-systems.net/props",       -- Override to any base path for trunk prop images
    pedImageBase = "https://cdn.sky-systems.net/peds",         -- Override to any base path for ped images (e.g. fire scenario creator assets)
    vehicleImageBase =
    "https://cdn.sky-systems.net/vehicles"                    -- Override to any base path, e.g. "nui://sky_ambulancejob/config/img/vehicles"
}

Config.Tablet = {
    enabled = true, -- Set to false to remove tablet from radial + disable all apps
    requireItem = false, -- If true, opening the tablet (radial menu, exports) requires carrying the configured item.
    item = "tablet", -- Usable inventory item that opens the tablet (set to "" to disable the usable item).
    prop = {
        model = "prop_cs_tablet",
        bone = 60309,
        offset = vector3(0.03, 0.002, -0.0),
        rotation = vector3(10.0, 160.0, 0.0),
        anim = {
            dict = "amb@code_human_in_bus_passenger_idles@female@tablet@base",
            name = "base",
            flag = 49 -- upper body + loop
        }
    },
    map = {
        closeOnDispatchAccept = true -- Close the tablet automatically after accepting a dispatch on the map
    },
    apps = {
        -- Set an app to false to hide it, or use a table for options:
        -- cctv = { enabled = true, isNew = true }
        forms = true,
        management = true,
        cctv = true,
        camera = true,
        gallery = true,
        map = true,
        chat = true,
        calendar = true,
        calculator = true,
        settings = true
    }
}

Config.Cctv = {
    -- Optional camera-app allowlist. Use job keys for specific jobs (e.g. "fib"),
    -- or group keys for whole job groups (e.g. "police"). Leave nil to keep the
    -- default police/ambulance CCTV app access.
    -- allowedJobs = { "fib" },
    requireBodycamItem = true,
    bodycamItem = "bodycam",
    -- Enabling it records the last Config.Cctv.recordBufferMinutes minutes and can noticeably increase client CPU usage.
    bodycamRecorderEnabled = false,
    -- Bodycam video bitrate in kbps. Lower = smaller upload (avoids the storage provider's HTTP 413 on
    -- long clips), slightly lower quality. Approx clip size in MB = recordBitrateKbps / 8000 * recordBufferMinutes * 60.
    recordBitrateKbps = 1500,

    -- Optional per-job bodycam visibility. The key is the viewer job, the values
    -- are the jobs whose bodycams it can see. If a viewer job is not listed here,
    -- the default camera network applies: own job and jobs in the same job group.
    -- Example (replace lspd with your actual LSPD job key, e.g. police):
    -- bodycamViewJobs = {
    --     fbi = { "fbi", "lspd" }, -- FBI sees FBI + LSPD bodycams
    --     lspd = { "lspd" }        -- LSPD only sees its own bodycams
    -- }
    bodycamViewJobs = nil
}

Config.HeliCam = {
    enabled = true,
    requireOnDuty = false,
    allowedJobs = { "police", "bcso", "ambulance" },
    models = { "polmav", "riothuey" },
    minHeight = 1.5,
    maxLockDistance = 700.0,
    speedUnit = "MPH",
    keys = {
        toggle_cam = 51,
        toggle_vision = 25,
        toggle_spotlight = 183,
        toggle_lock = 22,
        toggle_display = 44,
        rappel = 154,
        take_photo = 74,
        light_up = 246,
        light_down = 173,
        radius_up = 137,
        radius_down = 21
    },
    cam = {
        fovMin = 6.0,
        fovMax = 80.0,
        zoomSpeed = 3.0,
        zoomSmooth = 0.05,
        rotateSpeedX = 4.0,
        rotateSpeedZ = 4.0,
        minPitch = -89.5,
        maxPitch = 20.0
    },
    spotlight = {
        brightness = 1.0,
        radius = 4.0,
        minBrightness = 1.0,
        maxBrightness = 10.0,
        minRadius = 4.0,
        maxRadius = 10.0,
        distance = 800.0
    },
    capture = {
        cooldownMs = 1500,
        folder = "camera"
    }
}

Config.ManagementFinance = {
    historyDays = 14
}

-- enabled = false disables payroll globally. Override per job via Sky_Jobs.SetJobSalaryEnabled(jobKey, false).
Config.Salary = {
    enabled = true,
    accountType = "bank", -- Currency/account used for payouts. Use "money" or "bank", or set `currency` for a custom sky_base currency.
    currency = nil, -- Optional custom currency key from sky_base/config/currency.lua. When set, this overrides accountType.
    payIntervalsWhileOnDuty = true,
    defaultIntervalMinutes = 30,
    minIntervalMinutes = 10,
    maxIntervalMinutes = 180
}

-- Set a flag to false to lock the value in the management menu (read-only; edit via database only).
-- Override per job via Sky_Jobs.SetJobManagementEditing(jobKey, { salary = false, ... }).
Config.ManagementEditing = {
    roleName = true,       -- grade/role display name
    salary = true,         -- salary amount per payout
    salaryInterval = true, -- payout interval minutes
    roleStructure = true   -- create / delete / reorder roles
}

Config.Invites = {
    expireSeconds = 60
}

-- Interaction NPC options (all optional):
--   pedHash  = "s_m_m_doctor_01"          -- model name or joaat hash
--   heading  = 0.0                        -- facing direction
--   scenario = "WORLD_HUMAN_CLIPBOARD"    -- GTA scenario to play on spawn (e.g. CODE_HUMAN_MEDIC_KNEEL, WORLD_HUMAN_AA_COFFEE)
--   onSpawn  = function(ped)              -- runs once after ped is created (outfits, weapons, props, extra tasks)
--       SetPedArmour(ped, 100)
--       GiveWeaponToPed(ped, `WEAPON_NIGHTSTICK`, 1, false, true)
--   end
Config.Interactions = {
    job_garage = {
        duty = true,
        unique = false,
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "JobGarage",
            sprite = 1,
            color = 5
        },
        npc = {
            enabled = false,
            pedHash = "a_f_y_business_01",
            heading = 0.0
        }
    },
    garage_vehicle_spawn = {
        duty = true,
        unique = false,
        requiresHeading = true,
        interaction = false,
        marker = {
            enabled = false
        },
        blip = {
            enabled = false
        },
        npc = {
            enabled = false
        }
    },
    garage_vehicle_park = {
        duty = true,
        unique = false,
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false
        },
        npc = {
            enabled = false
        }
    },
    garage_helicopter_menu = {
        duty = true,
        unique = false,
        labelKey = "locationCreator.markers.garage_helicopter_menu",
        addLabelKey = "locationCreator.actions.add.garage_helicopter_menu",
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Helipad",
            sprite = 1,
            color = 5
        },
        npc = {
            enabled = false,
            pedHash = "a_f_y_business_01",
            heading = 0.0
        }
    },
    garage_helicopter_spawn = {
        duty = true,
        unique = false,
        requiresHeading = true,
        labelKey = "locationCreator.markers.garage_helicopter_spawn",
        addLabelKey = "locationCreator.actions.add.garage_helicopter_spawn",
        marker = {
            enabled = false
        },
        blip = {
            enabled = false
        },
        npc = {
            enabled = false
        }
    },
    garage_helicopter_park = {
        duty = true,
        unique = false,
        labelKey = "locationCreator.markers.garage_helicopter_park",
        addLabelKey = "locationCreator.actions.add.garage_helicopter_park",
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false
        },
        npc = {
            enabled = false
        }
    },
    garage_boat_menu = {
        duty = true,
        unique = false,
        labelKey = "locationCreator.markers.garage_boat_menu",
        addLabelKey = "locationCreator.actions.add.garage_boat_menu",
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Dock",
            sprite = 1,
            color = 5
        },
        npc = {
            enabled = false,
            pedHash = "a_f_y_business_01",
            heading = 0.0
        }
    },
    garage_boat_spawn = {
        duty = true,
        unique = false,
        requiresHeading = true,
        labelKey = "locationCreator.markers.garage_boat_spawn",
        addLabelKey = "locationCreator.actions.add.garage_boat_spawn",
        marker = {
            enabled = false
        },
        blip = {
            enabled = false
        },
        npc = {
            enabled = false
        }
    },
    garage_boat_park = {
        duty = true,
        unique = false,
        labelKey = "locationCreator.markers.garage_boat_park",
        addLabelKey = "locationCreator.actions.add.garage_boat_park",
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false
        },
        npc = {
            enabled = false
        }
    },
    boss_menu = {
        duty = true,
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Boss Menu",
            sprite = 487,
            color = 46
        },
        npc = {
            enabled = false,
            pedHash = "s_m_m_doctor_01",
            heading = 0.0
        }
    },
    duty_terminal = {
        duty = false,
        -- interactionDistance = 2.0, -- optional: target / interaction range
        -- drawDistance = 25.0, -- optional: visual marker draw range; lower values keep the default buffer
        -- markerSize = 1.2, -- optional: visual marker size only
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Duty Terminal",
            sprite = 351,
            color = 3
        },
        npc = {
            enabled = false,
            pedHash = "s_m_m_paramedic_01",
            heading = 0.0
        }
    },
    wardrobe = {
        duty = true,
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Wardrobe",
            sprite = 73,
            color = 5
        },
        npc = {
            enabled = false,
            pedHash = "a_m_m_business_01",
            heading = 0.0
        }
    },
    storage = {
        duty = true,
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Storage",
            sprite = 52,
            color = 2
        },
        npc = {
            enabled = false,
            pedHash = "a_m_y_business_03",
            heading = 0.0
        }
    },
    locker = {
        duty = true,
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Locker",
            sprite = 354,
            color = 5
        },
        npc = {
            enabled = false,
            pedHash = "a_f_y_business_01",
            heading = 0.0
        }
    },
    wholesale_shop = {
        duty = true,
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Wholesale Supplier",
            sprite = 614,
            color = 46
        },
        npc = {
            enabled = false,
            pedHash = "s_m_m_paramedic_01",
            heading = 0.0
        }
    },
    public_forms = {
        duty = false,
        public = true,
        marker = {
            enabled = true,
            type = 1,
            offset = vector3(0.0, 0.0, 0.0)
        },
        blip = {
            enabled = false,
            name = "Public Forms",
            sprite = 58,
            color = 3
        },
        npc = {
            enabled = false
        }
    }
}

Config.StationBlip = {
    enabled = true,
    name = "Station",
    useStationName = true,
    sprite = 280,
    color = 3,
    scale = 0.9,
    display = 4,
    shortRange = true
}

Config.Cloakroom = {
    -- auto: use built-in detection (rcore, custom hook, 17movement, qs-appearance, ak47-clothing, ak47-qb-clothing, tgiann-clothing, nf-skin, bl-appearance, izzy-appearance, codem-appearance, hex-clothing, illenium, qb-clothing, ESX skinchanger/esx_skin)
    -- sky: force the Sky ESX wardrobe editor (requires esx_skin + skinchanger)
    -- rcore: force rcore_clothing job changing room
    -- qb-clothing: force qb-clothing outfit menu
    -- 17movement: force 17mov_CharacterSystem outfit menu
    -- qs-appearance: force qs-appearance outfit menu
    -- ak47-clothing: force ak47_clothing outfit menu
    -- ak47-qb-clothing: force ak47_qb_clothing outfit menu
    -- tgiann-clothing: force tgiann-clothing wardrobe menu
    -- nf-skin: force nf-skin outfit menu
    -- bl-appearance: force bl_appearance outfit menu
    -- izzy-appearance: force izzy-appearance clothing menu
    -- codem-appearance: force codem-appearance wardrobe menu
    -- hex-clothing: force hex_clothing outfit menu
    -- illenium: force illenium-appearance outfit menu
    -- custom: force the custom hook below
    -- disabled: disable wardrobe interactions
    backend = "rcore",

    custom = {
        -- Optional resource name. If set, the wardrobe is only available when this resource is started.
        resource = nil,

        -- Optional availability hook. Return true when your clothing system can handle the wardrobe.
        -- isAvailable = function(context)
        --     return GetResourceState("my_clothing") == "started"
        -- end,

        -- Optional open hook. Return false to tell sky_jobs_base the open call failed.
        -- open = function(context)
        --     TriggerEvent("my_clothing:client:openOutfits", context)
        --     return true
        -- end,
    },

    editableComponents = {
        "mask_1",
        "mask_2",
        "arms",
        "arms_2",
        "torso_1",
        "torso_2",
        "tshirt_1",
        "tshirt_2",
        "pants_1",
        "pants_2",
        "shoes_1",
        "shoes_2",
        "bags_1",
        "bags_2",
        "decals_1",
        "decals_2",
        "chain_1",
        "chain_2",
        "helmet_1",
        "helmet_2",
        "glasses_1",
        "glasses_2",
        "bracelets_1",
        "bracelets_2",
        "watches_1",
        "watches_2",
        "bproof_1",
        "bproof_2",
        "ears_1",
        "ears_2"
    }
}

-- ============================================================================
-- Job vehicle entries
-- Each job defines its purchasable vehicles in its own Config.Jobs[*].vehicles
-- list (e.g. sky_ambulancejob/config/config.lua), not here. Every entry supports:
--   name              (string)  Display name in the garage menu. Required.
--   model             (string)  Spawn model name. Required.
--   price             (number)  Purchase price, >= 0. Required.
--   garageType        (string)  "vehicle" | "helicopter" | "boat". Default "vehicle".
--   trunkCapacity     (number)  Trunk weight capacity. Falls back to defaultTrunkCapacity.
--   trunkEnabled      (boolean) false disables the trunk entirely. Default true.
--   trunkPropsEnabled (boolean) false disables placeable trunk props only. Default true.
--   props / propCounts          Per-vehicle trunk props / prop limits (see below).
--   hasStretcher      (boolean) Ambulance only: false hides the stretcher action.
--   livery            (number)  Livery index applied on spawn.
--   extras            (table)   Vehicle extras, e.g. { [1] = true, [3] = false }.
--   fuelType          (string)  lc_fuel fuel type: "regular" | "plus" | "premium" | "diesel".
--   primaryColor      (number)  Primary paint index (0-160).
--   secondaryColor    (number)  Secondary paint index (0-160).
--   pearlescentColor  (number)  Pearlescent paint index.
--   wheelColor        (number)  Wheel paint index.
--   properties        (table)   Raw vehicle-properties passthrough for anything else
--                               (customPrimaryColor = { r, g, b }, windowTint, neonColor,
--                               modEngine, plateIndex, ...). The named color fields above
--                               override matching keys set here.
-- Colors and `properties` apply only to freshly bought vehicles; once a player
-- repaints a vehicle and parks it, its stored customization is kept.
-- ============================================================================
Config.JobGarage = {
    parkRadius = 4.0,
    parkKey = 38,
    sellPercentage = 50,
    allowPlateChange = true, -- Set to false to disable license plate changes in the garage menu.
    warpIntoVehicle = false, -- Set to true to put the player directly into the spawned garage vehicle.
    spawnBlockRadius = 3.0,
    maxSpawnFallbackDistance = 100.0,
    defaultTrunkCapacity = 40,
    -- Per vehicle, configure limited trunk props directly in the job vehicle entry:
    -- props = {
    --     { model = "prop_roadcone02a", label = "Traffic Cone", amount = 4 },
    --     { model = "prop_barrier_work05", label = "Barrier", amount = 2 }
    -- }
    -- Short form also works: props = { prop_roadcone02a = 4, prop_barrier_work05 = 2 }
    -- Or reuse the job's shared props list and only define counts:
    -- propCounts = {
    --     prop_roadcone02a = 4,
    --     prop_barrier_work05 = 2
    -- }
    trunk = {
        promptDistance = 3.0,
        interactDistance = 3.0,
        requireBehind = true,
        openKey = 38,
        distanceTolerance = 1.5,
        propStreamDistance = 150.0, -- Placed vehicle/job props are spawned locally only within this range.
        propStreamDespawnBuffer = 25.0, -- Extra distance before an already streamed prop is despawned.
        propRemoveEnabled = true, -- Show a keypress prompt next to placed props to remove them (the radial action stays available).
        propRemoveKey = 38, -- Control id for the prop removal keypress.
        propRemoveKeyLabel = "E", -- Key label shown in the removal prompt.
        propRemoveDistance = 2.2, -- Max distance for keypress/radial prop removal.
    }
}

Config.Storage = {
    storageCapacity = 1000, -- Default shared storage capacity for jobs without Config.Jobs[*].storage (<= 0 for unlimited)
    lockerCapacity = 10     -- Default personal locker capacity for jobs without Config.Jobs[*].storage (<= 0 for unlimited)
}

Config.JobRadial = {
    enabled = true, -- Set to false only if you use a target system (ox_target / qb-target) for job actions and have sky_base Config.target set to "ox" / "qb" / "auto" with the matching resource running, otherwise these actions cannot be triggered at all. Tablet access is not available through the target system and must be handled through the tablet item's usable-item flow.
    key = "g",
    mode = "toggle", -- "hold" (hold key, release to select) or "toggle" (press to open/close)
    deadzone = 0.25, -- only used in "hold" mode (stick/mouse deadzone for directional selection)
    oxTarget = {
        enabled = true -- Registers non-tablet job radial actions as target actions so they can be used without opening the radial menu. Requires sky_base Config.target = "ox" or "qb" (or "auto" with the matching resource started). Tablet access stays on the tablet item's usable-item flow.
    }
}

Config.Panic = {
    enabled = true,
    -- Only these jobs can use/see the panic feature. Set to nil to fall back to all registered job-related jobs.
    allowedJobs = {
        "police",
        "bcso",
        "ambulance"
    },
    -- Optional per-sender visibility groups. The key is the job that triggers
    -- the panic, the values are the jobs that receive it. If a sender job is
    -- not listed here, the default own-job + notifyJobs behavior applies.
    -- groups = {
    --     police = { "police", "sheriff", "fib" }
    -- },
    groups = nil,
    requireItem = false, -- If true, the player must carry item to trigger panic.
    item = "gps",
    useKeybind = true, -- Set to false to stop registering the panic keybind.
    useRadial = false, -- Set to true to show the panic button in the job radial menu.
    requireOnDuty = true,
    cooldownSeconds = 45,
    alertDurationSeconds = 120,
    notifyOffDuty = false,
    showSelf = true,
    notifyJobs = {
        -- "ambulance"
    },
    blip = {
        sprite = 161,
        color = 1,
        scale = 1.05,
        flashing = true,
        flashInterval = 850,
        shortRange = false,
        radius = 80.0,
        radiusColor = 1,
        radiusAlpha = 95
    }
}

Config.Ping = {
    enabled = true,
    -- Optional per-sender visibility groups. The key is the job that sends the
    -- ping, the values are the jobs that receive it. If a sender job is not
    -- listed here, the default own-job + notifyJobs behavior applies.
    -- groups = {
    --     police = { "police", "sheriff", "fib" }
    -- },
    groups = nil,
    requireItem = false, -- If true, the player must carry item to send a ping.
    item = "gps",
    requireOnDuty = true,
    cooldownSeconds = 8,
    alertDurationSeconds = 30,
    notifyOffDuty = false,
    showSelf = true,
    notifyJobs = {
        -- "ambulance"
    },
    blip = {
        sprite = 280,
        color = 3,
        scale = 0.95,
        flashing = false,
        shortRange = false,
        radius = 60.0,
        radiusColor = 3,
        radiusAlpha = 80
    }
}

Config.IncidentNotification = {
    durationMs = 30000,
}
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
