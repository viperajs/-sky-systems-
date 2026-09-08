if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/config/housing/_init.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

if Sky.Housing and Sky.Housing._initialized then
    return
end

Sky.Housing = Sky.Housing or {}
Sky.Housing.Adapters = Sky.Housing.Adapters or {}
Sky.Housing.AdapterOrder = Sky.Housing.AdapterOrder or {}
Sky.Housing._initialized = true

function Sky.Housing.NormalizeCoords(coords)
    if not coords or not coords.x or not coords.y or not coords.z then
        return nil
    end

    local x = tonumber(coords.x)
    local y = tonumber(coords.y)
    local z = tonumber(coords.z)
    if not x or not y or not z then
        return nil
    end
    if x == 0.0 and y == 0.0 and z == 0.0 then
        return nil
    end

    return vector3(x, y, z)
end

function Sky.Housing.CoordsChanged(coords, fallbackCoords)
    local normalized = Sky.Housing.NormalizeCoords(coords)
    local fallback = Sky.Housing.NormalizeCoords(fallbackCoords)
    if not normalized then
        return nil
    end
    if not fallback then
        return normalized
    end

    return #(normalized - fallback) > 1.0 and normalized or nil
end

function Sky.Housing.FirstCoords(...)
    for i = 1, select("#", ...) do
        local coords = Sky.Housing.NormalizeCoords(select(i, ...))
        if coords then
            return coords
        end
    end
    return nil
end

function Sky.Housing.FirstDoorCoords(doors)
    if type(doors) ~= "table" then
        return nil
    end

    for _, door in pairs(doors) do
        local coords = Sky.Housing.FirstCoords(
            door and door.coords,
            door and door.door1 and door.door1.coords,
            door and door.door2 and door.door2.coords
        )
        if coords then
            return coords
        end
    end

    return nil
end

function Sky.Housing.ResolvePropertyEntrance(property)
    if type(property) ~= "table" then
        return nil
    end

    local metadata = type(property.metadata) == "table" and property.metadata or {}
    local coords = type(property.coords) == "table" and property.coords or {}
    local enter = type(property.enter) == "table" and property.enter or {}
    local entry = type(property.entry) == "table" and property.entry or {}
    local entrance = type(property.entrance) == "table" and property.entrance or {}

    return Sky.Housing.FirstCoords(
        metadata.exit,
        metadata.entrance,
        metadata.enter,
        entrance.coords,
        entrance,
        entry.coords,
        entry,
        enter.coords,
        enter,
        coords.entrance,
        coords.entry,
        coords.enter,
        coords,
        property.position,
        property.location,
        property.blip,
        property.sellsign and property.sellsign.coords,
        Sky.Housing.FirstDoorCoords(property.doors)
    )
end

function Sky.Housing.RegisterAdapter(name, handler)
    if type(name) ~= "string" or name == "" or type(handler) ~= "function" then
        return false
    end

    Sky.Housing.Adapters[name] = handler
    Sky.Housing.AdapterOrder[#Sky.Housing.AdapterOrder + 1] = name
    return true
end

function Sky.Housing.GetPlayerEntranceCoords(source, fallbackCoords)
    for _, name in ipairs(Sky.Housing.AdapterOrder) do
        local handler = Sky.Housing.Adapters[name]
        local ok, result = pcall(handler, source, fallbackCoords)
        local coords = ok and Sky.Housing.NormalizeCoords(result) or nil
        if coords then
            return coords, name
        elseif not ok then
            Sky.Debug("warn", "[housing/%s] entrance lookup failed: %s", tostring(name), tostring(result))
        end
    end

    return Sky.Housing.NormalizeCoords(fallbackCoords), nil
end

function Sky.Housing.GetCurrentEntranceCoords(fallbackCoords)
    if IsDuplicityVersion() then
        return Sky.Housing.NormalizeCoords(fallbackCoords), nil
    end

    local coords, adapter = Sky.Housing.GetPlayerEntranceCoords(GetPlayerServerId(PlayerId()), fallbackCoords)
    if adapter then
        return coords, adapter
    end

    if Sky.Cb and type(Sky.Cb.TriggerWithTimeout) == "function" then
        local serverCoords, serverAdapter = Sky.Cb.TriggerWithTimeout("sky_base:housing:getEntranceCoords", 1000, fallbackCoords)
        serverCoords = Sky.Housing.NormalizeCoords(serverCoords)
        if serverCoords and serverAdapter then
            return serverCoords, serverAdapter
        end
    end

    return coords, nil
end

if IsDuplicityVersion() then
    CreateThread(function()
        while not Sky.Cb or type(Sky.Cb.Register) ~= "function" do
            Wait(0)
        end

        Sky.Cb.Register("sky_base:housing:getEntranceCoords", function(source, fallbackCoords)
            return Sky.Housing.GetPlayerEntranceCoords(source, fallbackCoords)
        end)
    end)
end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
