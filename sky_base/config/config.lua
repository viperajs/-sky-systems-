if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/config/config.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

Config = {
    -- Global settings for all scripts
    -- Dont forget to uncomment the imports in fxmanifest.lua if you are using vrp!
    framework = "qbox", -- auto, esx, qb, qbox, vrp, custom - can be customized in config/framework
    garage = "quasar", -- auto, esx, qb, qbox, quasar, okok, jg, cd, bp, my, vms, op, ds-servercreator - can be customized in config/garage
    progressbar = "ox", -- auto, esx, ox, qb, mythic, hex, jaksam, wasabi - can be customized in config/progress
    sql = "oxmysql", -- auto, oxmysql or mysql-async
    locale = "en", -- locale file to use from config/locales/
    phone = "auto", -- auto, esx, qb, qs, d, gks, lb, lb-unique, yseries, codem, okok, roadphone
    license = "auto", -- auto, esx (esx_license), qb (metadata), cs (cs_license), ak47 (ak47_idcardv2), codem (codem-wallet), papa (papa_licensecreator), bit (bit-licenses) - can be customized in config/license
    billing = "okok", -- auto, esx, codem, codemv2, okok, jacksam, quasar, vms, rxbilling, wasabi, corem, fd, groot
    vehiclekeys = "quasar", -- auto, qb, vehicles_keys, mrnewb, mk, quasar, wasabi, msk, brutal, kiminaze, ak47, jota - can be customized in config/vehiclekeys
    fuel = "rcore", -- auto, lc, ox, legacy, rcore, hex, okokGasStation, okokfuel, native - can be customized in config/fuel
    inventory = "ox", -- auto, esx, qb, qbox, vrp, ox, qs, ps, codem, tgiann, jaksam, ak47, one, core, origen, jpr, hex - can be customized in config/inventory
    banking = "okok", -- auto, sky, crm, codem, qs, okok, bablo, fd, rx, tgg, kartik, esx, qb, renewed, wasabi, groot, ak47, jaksam - can be customized in config/banking
    useSkyBankingFallback = false, -- Uses sky_base's own DB-backed job accounts when the selected banking resource fails. Set banking = "sky" to force it.
    useMph = true, -- use mph or kmh for speed
    debug = false,

    defaultCallbackTimeout = 5000, -- default timeout for client-triggered callbacks in ms
    interactionDistance = 2.0, -- default distance from where you can interact with a marker / npc / target zone
    interactionDrawBuffer = 20.0, -- extra range beyond interactionDistance where markers are drawn and tracked
    streamNpcEnabled = true, -- only spawn interaction-point NPC peds while the player is within streamNpcDistance (set false for legacy: peds exist everywhere at once)
    streamNpcDistance = 100.0, -- default range (in game units) a player must be within for an interaction NPC ped to exist; despawns past streamNpcDistance + 20%
    streamNpcRefreshMs = 1000, -- how often (ms) the streaming pass re-evaluates ped distances when no point is in interaction range
    streamNpcMaxSpawnsPerPass = 4, -- max number of streamed interaction NPCs to spawn in one streaming pass; higher values reduce visible spawn delay for groups
    defaultMarkerSize = 1.2, -- default marker scale when marker.scaleX / marker.scaleY / markerSize is not set
    defaultBlipSize = 0.8,
    defaultMarkerColor = {
        red = 0,
        green = 255,
        blue = 255,
    },
    target = "none", -- none (default: marker + help notification), ox, qb, auto - can be customized in config/target. "auto" picks a started target resource and replaces the normal marker interaction, only opt-in.
    showMarkersWithTarget = true, -- keep drawing configured interaction markers when target is enabled
    useStreamerMode = false, -- enable streamer mode
    maxPing = 200, -- max ping allowed for events
}

Config.Licenses = {
    -- Fallback license catalog used when the active license provider cannot
    -- list available license types itself (papa_licensecreator, bit-licenses,
    -- cs_license, ESX without esx_license, ...). QB/Qbox merge these entries
    -- into their metadata-based catalog. Use the provider's license ids as
    -- type (e.g. papa: papa_id / papa_driver_license, bit: driving / weapon).
    catalog = {
        { type = "driver", label = "Driver License" },
        { type = "weapon", label = "Weapon License" },
        { type = "business", label = "Business License" },
    },
    papaGiveItem = false, -- papa_licensecreator: also give the physical license item when granting access.
}

-- Blacklist for words you dont want to be used on your server
Config.Blacklist = {
    "<",
    ">",
    "script",
    "iframe",
    "&#8203;",
    "&#x27;",
    "null",
    "undefined",
    "nega",
    "hurensohn",
    "nigga",
    "adolf",
    "hitler",
    "neger",
}
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
