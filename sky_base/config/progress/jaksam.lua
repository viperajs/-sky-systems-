if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/config/progress/jaksam.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

if Sky.Config.progressbar == "jaksam" then
    local jaksamProgressbarEvents = {
        ["robberies_creator"] = "robberies_creator:startProgressBar",
        ["jobs_creator"] = "jobs_creator:startProgressBar",
        ["drugs_creator"] = "drugs_creator:startProgressBar",
    }

    local function getJaksamProgressbarEvent()
        for resource, event in pairs(jaksamProgressbarEvents) do
            if GetResourceState(resource) == "started" then
                return event
            end
        end
    end

    local function normalizeProgressData(labelOrData, duration, options, cb)
        if type(labelOrData) == "table" then
            local data = labelOrData
            return data.duration or data.length or 5000,
                data.label or data.text or data.name or "Progress",
                data.hexColor or data.color,
                type(duration) == "function" and duration or nil
        end

        if type(options) == "function" then
            cb = options
            options = {}
        end

        options = options or {}

        return duration or 5000, labelOrData or "Progress", options.hexColor or options.color, cb
    end

    function Sky.Functions.Progress(labelOrData, duration, options, cb)
        local ms, text, hexColor, callback = normalizeProgressData(labelOrData, duration, options, cb)
        local event = getJaksamProgressbarEvent()

        if not event then
            Sky.Debug("error", "Sky.Config.progressbar is set to jaksam but no supported Jaksam Creator resource is started.")
            if callback then callback(true) end
            return false
        end

        TriggerEvent(event, ms, text, hexColor)

        if callback then
            CreateThread(function()
                Wait(ms)
                callback(false)
            end)
        end

        return true
    end

    function Sky.Functions.Bar(...)
        return Sky.Functions.Progress(...)
    end

    Sky.Functions.ProgressBar = Sky.Functions.Progress

    function Sky.Functions.CancelProgress()
        Sky.Debug("warn", "Jaksam Creator progressbar does not provide a documented cancel event.")
    end

    Sky.Functions.CancelBar = Sky.Functions.CancelProgress
    Sky.Functions.CancelProgressBar = Sky.Functions.CancelProgress
    Sky.Functions.CancelProgressbar = Sky.Functions.CancelProgress
end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
