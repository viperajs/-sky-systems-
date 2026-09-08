if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/config/phone/roadphone.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

if Sky.Config.phone == "roadphone" then
    local function appendQuery(url, key, value)
        local separator = url:find("?", 1, true) and "&" or "?"
        return ("%s%s%s=%s"):format(url, separator, key, tostring(value))
    end

    local function buildRoadPhoneUrl(app)
        local resource = app.resource or GetCurrentResourceName()
        local url = app.url

        if not url then
            local path = app.uiPath or app.ui or "source/html/index.html"

            if path:find("^nui://") then
                url = path:gsub("^nui://([^/]+)/", "https://cfx-nui-%1/")
            elseif path:find("^https?://") then
                url = path
            else
                path = path:gsub("^" .. resource .. "/", "")
                url = ("https://cfx-nui-%s/%s"):format(resource, path)
            end
        end

        if app.route then
            url = appendQuery(url, "skyPhoneRoute", app.route)
        end

        return appendQuery(url, "skyPhone", "roadphone")
    end

    local function buildRoadPhoneAppConfig(app)
        return {
            name = app.name,
            icon = app.roadphoneIcon or app.icon,
            default = app.defaultApp == true,
            category = app.category or "apps",
            custom_app_id = app.identifier,
            redirect = "custom_app",
            url = buildRoadPhoneUrl(app),
            darkmode = app.darkmode == true,
            allowJobs = app.allowJobs or {},
            disallowJobs = app.disallowJobs or {},
            custom_event = {
                active = false,
                closeWhenOpenApp = false
            }
        }
    end

    local function sendRoadPhoneNotification(data)
        exports["roadphone"]:sendNotification({
            apptitle = data.apptitle or data.appTitle or data.app or data.identifier or "App",
            title = data.title or "",
            message = data.content or data.message or data.text or "",
            img = data.img or data.icon
        })
    end

    function Sky.Functions.ChangeNumber(src, newNumber)
        Sky.Debug("error", "RoadPhone number changes are not supported through sky_base. Use RoadPhone admin tools.")
    end

    function Sky.Functions.IsNumberUsed(phoneNumber)
        Sky.Debug("error", "RoadPhone number uniqueness checks are not supported through sky_base.")
        return false
    end

    function Sky.Functions.RegisterCustomPhoneApp(app)
        local appConfig = buildRoadPhoneAppConfig(app)

        Sky.RoadPhoneCustomApps = Sky.RoadPhoneCustomApps or {}
        Sky.RoadPhoneCustomApps[appConfig.custom_app_id] = appConfig

        return true, appConfig
    end

    function Sky.Functions.SendCustomPhoneAppMessage(identifier, data)
        local payload = {
            app = identifier,
            identifier = identifier,
            customevent = identifier,
            event = data and (data.event or data.type) or identifier,
            data = data or {}
        }

        for key, value in pairs(data or {}) do
            payload[key] = value
        end

        exports["roadphone"]:SendMessageNUI(payload)
    end

    function Sky.Functions.SendPhoneAppNotification(data, source)
        data = data or {}

        if IsDuplicityVersion() then
            local target = tonumber(source or data.source or data.src)
            if not target or target <= 0 then
                return false
            end

            TriggerClientEvent("sky_base:roadphone:sendNotification", target, data)
            return true
        end

        sendRoadPhoneNotification(data)
        return true
    end

    if not IsDuplicityVersion() then
        RegisterNetEvent("sky_base:roadphone:sendNotification", function(data)
            Sky.Functions.SendPhoneAppNotification(data)
        end)
    end

    function Sky.Functions.GetSourceFromNumber(phoneNumber)
        if not phoneNumber then return nil end
        return exports['roadphone']:getPlayerFromPhone(phoneNumber)
    end

    function Sky.Functions.HasAirplaneMode(phoneNumber)
        return exports['roadphone']:isFlightmode()
    end
end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
