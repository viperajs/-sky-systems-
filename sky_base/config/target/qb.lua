if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/config/target/qb.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

---@diagnostic disable: duplicate-set-field
if IsDuplicityVersion() then return end
if Sky.Config.target ~= "qb" then return end

Sky.Target = Sky.Target or {}

local zoneCounter = 0
local localEntityLabels = {}
local globalPlayerLabels = {}
local globalOptionLabels = {}

local function maxDistance(options, fallback)
    local m = 0
    for _, opt in ipairs(options) do
        local d = tonumber(opt.distance) or 0
        if d > m then m = d end
    end
    if m <= 0 then return fallback or 2.5 end
    return m
end

local function mapOptions(options)
    local mapped = {}
    for i, opt in ipairs(options) do
        local onSelect = opt.onSelect
        local canInteract = opt.canInteract
        mapped[i] = {
            type = "client",
            icon = opt.icon,
            label = opt.label,
            action = onSelect and function(entity)
                onSelect({ entity = entity, name = opt.name })
            end or nil,
            canInteract = canInteract and function(entity, distance)
                return canInteract(entity, distance) and true or false
            end or nil,
            job = opt.job,
            gang = opt.gang,
            item = opt.item,
        }
    end
    return mapped
end

local function rememberLabels(store, options)
    for _, opt in ipairs(options) do
        if opt.name and opt.label then
            store[opt.name] = opt.label
        end
    end
end

local function resolveLabels(store, names)
    local labels = {}
    if type(names) == "string" then
        local label = store[names]
        if label then labels[#labels + 1] = label end
        store[names] = nil
    elseif type(names) == "table" then
        for _, name in ipairs(names) do
            local label = store[name]
            if label then labels[#labels + 1] = label end
            store[name] = nil
        end
    end
    return labels
end

function Sky.Target.AddLocalEntity(entity, options)
    if not entity or not options or #options == 0 then return end
    localEntityLabels[entity] = localEntityLabels[entity] or {}
    rememberLabels(localEntityLabels[entity], options)
    exports['qb-target']:AddTargetEntity(entity, {
        options = mapOptions(options),
        distance = maxDistance(options),
    })
end

function Sky.Target.RemoveLocalEntity(entity, optionNames)
    if not entity then return end
    local store = localEntityLabels[entity]
    if not store then return end
    local labels = resolveLabels(store, optionNames)
    if #labels == 0 then return end
    exports['qb-target']:RemoveTargetEntity(entity, labels)
    if not next(store) then
        localEntityLabels[entity] = nil
    end
end

function Sky.Target.AddSphereZone(params)
    if not params or not params.coords or not params.options then return nil end
    zoneCounter = zoneCounter + 1
    local name = ("sky_zone_%d"):format(zoneCounter)
    exports['qb-target']:AddCircleZone(
        name,
        params.coords,
        params.radius or 1.5,
        { name = name, useZ = true, debugPoly = params.debug == true },
        { options = mapOptions(params.options), distance = maxDistance(params.options, params.radius or 1.5) }
    )
    return name
end

function Sky.Target.RemoveZone(handle)
    if not handle then return end
    exports['qb-target']:RemoveZone(handle)
end

function Sky.Target.AddGlobalPlayer(options)
    if not options or #options == 0 then return end
    rememberLabels(globalPlayerLabels, options)
    exports['qb-target']:AddGlobalPlayer({
        options = mapOptions(options),
        distance = maxDistance(options),
    })
end

function Sky.Target.RemoveGlobalPlayer(optionNames)
    local labels = resolveLabels(globalPlayerLabels, optionNames)
    if #labels == 0 then return end
    exports['qb-target']:RemoveGlobalPlayer(labels)
end

function Sky.Target.AddGlobalOption(options)
    if not options or #options == 0 then return end
    rememberLabels(globalOptionLabels, options)
    local payload = { options = mapOptions(options), distance = maxDistance(options) }
    exports['qb-target']:AddGlobalPed(payload)
    exports['qb-target']:AddGlobalVehicle(payload)
    exports['qb-target']:AddGlobalObject(payload)
    exports['qb-target']:AddGlobalPlayer(payload)
end

function Sky.Target.RemoveGlobalOption(optionNames)
    local labels = resolveLabels(globalOptionLabels, optionNames)
    if #labels == 0 then return end
    exports['qb-target']:RemoveGlobalPed(labels)
    exports['qb-target']:RemoveGlobalVehicle(labels)
    exports['qb-target']:RemoveGlobalObject(labels)
    exports['qb-target']:RemoveGlobalPlayer(labels)
end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
