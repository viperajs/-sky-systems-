if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/config/phone/codem.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

if Sky.Config.phone == "codem" then
    function Sky.Functions.ChangeNumber(src, newNumber) 
        Sky.DB.SetValue("codem_mphone_data", "phone_number", newNumber, "owner", Sky.FW.GetIdentifier(src))
        TriggerClientEvent("sky_base:notification", src, "Phone", "Your phone number has been changed", "success")
    end

    function Sky.Functions.IsNumberUsed(phoneNumber)
        local result = Sky.Query('SELECT COUNT(*) as count FROM codem_mphone_data WHERE phone_number = ?', { phoneNumber })
        if result[1] and result[1].count > 0 then
            return true
        else
            return false
        end
    end

    function Sky.Functions.RegisterCustomPhoneApp(app)

        local resource = app.resource or GetCurrentResourceName()
        local html = app.html

        if not html and app.uiPath then
            html = LoadResourceFile(resource, app.uiPath)
        end

        if html and app.uiPath then
            local basePath = ("nui://%s/%s"):format(resource, app.uiPath:gsub("[^/]+$", ""))
            html = html:gsub('src="%./', 'src="' .. basePath)
            html = html:gsub("src='%./", "src='" .. basePath)
            html = html:gsub('href="%./', 'href="' .. basePath)
            html = html:gsub("href='%./", "href='" .. basePath)
        end

        if app.route and html then
            html = html:gsub("</head>", ('<script>window.SKY_PHONE_APP_ROUTE="%s";</script></head>'):format(app.route))
        end

        local exportName = app.addAppExport or "AddCustomApp"
        local appData = {
            identifier = app.identifier,
            name = app.name,
            ui = html or app.ui,
            icon = app.icon,
            description = app.description,
            defaultApp = app.defaultApp == true,
            notification = app.notification ~= false,
            fixBlur = app.fixBlur == true,
            job = app.job,
            addAppStore = app.addAppStore == true,
            developer = app.developer,
            headerImage = app.headerImage,
            swiperItems = app.swiperItems,
            games = app.games == true,
            price = app.price,
            size = app.size
        }

        return exports["codem-phone"][exportName](appData)
    end

    function Sky.Functions.SendCustomPhoneAppMessage(identifier, data)
        SendNUIMessage(data or {})
    end

    function Sky.Functions.SendPhoneAppNotification(data, source)
        data = data or {}

        if not IsDuplicityVersion() then
            TriggerServerEvent("sky_base:phone:sendAppNotification", data)
            return true
        end

        local target = tonumber(source or data.source or data.src)
        if not target or target <= 0 then
            return false
        end

        local exportName = data.notificationExport or "SendNotify"
        return exports["codem-phone"][exportName](target, {
            app = data.app or data.identifier,
            title = data.title,
            message = data.content or data.message or data.text
        })
    end

    function Sky.Functions.GetSourceFromNumber(phoneNumber)
        print("[sky_base] get source from number is not supported for codem phone")
    end

    function Sky.Functions.HasAirplaneMode(phoneNumber)
        exports['codem-phone']:HasAirplaneMode(phoneNumber)
    end
end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
