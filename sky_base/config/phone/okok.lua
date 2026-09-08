if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/config/phone/okok.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

if Sky.Config.phone == "okok" then
    local function appendQuery(url, key, value)
        local separator = url:find("?", 1, true) and "&" or "?"
        return ("%s%s%s=%s"):format(url, separator, key, tostring(value))
    end

    local function buildCfxNuiUrl(resource, path)
        if type(path) ~= "string" or path == "" then
            return nil
        end

        if path:find("^https?://") then
            return path
        end

        if path:find("^nui://") then
            return path:gsub("^nui://([^/]+)/", "https://cfx-nui-%1/")
        end

        path = path:gsub("^" .. resource .. "/", "")
        return ("https://cfx-nui-%s/%s"):format(resource, path)
    end

    local function buildOkokPhoneUrl(app)
        local resource = app.resource or GetCurrentResourceName()
        local url = app.url or buildCfxNuiUrl(resource, app.uiPath or app.ui or "source/html/index.html")

        if app.route then
            url = appendQuery(url, "skyPhoneRoute", app.route)
        end

        return appendQuery(url, "skyPhone", "okok")
    end

    local function buildOkokPhoneIcon(app)
        local resource = app.resource or GetCurrentResourceName()
        return buildCfxNuiUrl(resource, app.okokIcon or app.icon or "icon.png")
    end

    function Sky.Functions.ChangeNumber(src, newNumber) 
        Sky.DB.SetValue("okokphone_phones", "phone_number", newNumber, "owner", Sky.FW.GetIdentifier(src))
        TriggerClientEvent("sky_base:notification", src, "Phone", "Your phone number has been changed. Please relog.", "warn", 10000)
    end

    function Sky.Functions.IsNumberUsed(phoneNumber)
        local result = Sky.Query('SELECT COUNT(*) as count FROM okokphone_phones WHERE phone_number = ?', { phoneNumber })
        if result[1] and result[1].count > 0 then
            return true
        else
            return false
        end
    end

    function Sky.Functions.RegisterCustomPhoneApp(app)
        if GetResourceState("okokPhone") ~= "started" then
            return false, "okokPhone not started"
        end

        local appData = {
            id = app.identifier,
            label = app.name,
            description = app.description,
            custom = true,
            icon = buildOkokPhoneIcon(app),
            previewImagesCount = math.max(0, math.floor(tonumber(app.previewImagesCount) or 0)),
            notifications = app.notification ~= false and true or false,
            resourceName = GetCurrentResourceName(),
            webUrl = buildOkokPhoneUrl(app)
        }

        local ok, result = pcall(function()
            return exports["okokPhone"]:loadApp(appData)
        end)
        if not ok then
            return false, result
        end

        if type(result) == "boolean" then
            return result
        end

        return true, result
    end

    function Sky.Functions.SendCustomPhoneAppMessage(identifier, data)
        SendNUIMessage(data or {})
    end

    function Sky.Functions.SendPhoneAppNotification(data, source)
        data = data or {}

        local notification = {
            title = data.title or data.appTitle or data.app or data.identifier or "App",
            text = data.content or data.message or data.text or "",
            app = data.app or data.identifier,
            icon = data.icon,
            duration = math.max(1000, math.floor(tonumber(data.duration) or 3000))
        }

        if IsDuplicityVersion() then
            local target = tonumber(source or data.source or data.src)
            if not target or target <= 0 then
                return false
            end

            TriggerClientEvent("okokPhone:client:NotifyDI", target, notification)
            return true
        end

        TriggerEvent("okokPhone:client:NotifyDI", notification)
        return true
    end

    function Sky.Functions.GetSourceFromNumber(phoneNumber)
        if not phoneNumber then return nil end
        return exports['okokPhone']:getSourceFromPhoneNumber(phoneNumber)
    end

    function Sky.Functions.HasAirplaneMode(phoneNumber)
        return LocalPlayer.state['okokPhone:airplaneMode']
    end
end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
