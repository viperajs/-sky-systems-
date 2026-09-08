if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/config/framework/vrp.lua") end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577

if Sky.Config.framework == "vrp" then
    Sky.FW = {}
    local Tunnel = module("vrp", "lib/Tunnel")
    local Proxy = module("vrp", "lib/Proxy")
    local vRPclient = Tunnel.getInterface("vRP", GetCurrentResourceName())
    local itemsConfig = module("vrp", "cfg/items")

    vRP = Proxy.getInterface("vRP")

    if IsDuplicityVersion() then goto server end 
    -- Client Side from here

    -- Entered / Exited Vehicle
    Citizen.CreateThread(function()
        local currentVehicle = {}
        local isInVehicle = false
        while true do
            local playerPed = PlayerPedId()

            if not isInVehicle and not IsPlayerDead(PlayerId()) then
                if IsPedInAnyVehicle(playerPed, false) then
                    isInVehicle = true
                    currentVehicle.vehicle = GetVehiclePedIsUsing(playerPed)
                    currentVehicle.seat = GetPedVehicleSeat(playerPed, currentVehicle.vehicle)
                    currentVehicle.plate = GetVehicleNumberPlateText(currentVehicle.vehicle)
                    TriggerEvent("sky_base:enteredVehicle", currentVehicle.vehicle, currentVehicle.plate, currentVehicle.seat)
                end
            elseif isInVehicle then
                if not IsPedInAnyVehicle(playerPed, false) or IsPlayerDead(PlayerId()) then
                    TriggerEvent("sky_base:exitedVehicle", currentVehicle.vehicle, currentVehicle.plate, currentVehicle.seat)
                    currentVehicle = {}
                    isInVehicle = false
                end
            end
            Citizen.Wait(200)
        end
    end)

    ::server::
    if not IsDuplicityVersion() then return end
    -- Server Side from here

    function Sky.FW.IsPlayerOnline(sourceOrIdentifier)
        local user_id = vRP.getUserId({sourceOrIdentifier})
        if user_id ~= nil then
            return user_id
        else
            return false
        end
    end

    function Sky.FW.GetIdentifier(source)
        if source ~= nil then
            return vRP.getUserId({source})
        else
            return false
        end
    end

    function Sky.FW.GetName(source)
        return Sky.String.SanitizeForSQL(GetPlayerName(source))
    end

    function Sky.FW.GetFirstname(source)
        if source ~= nil then
            local user_id = vRP.getUserId({source})
            if not user_id or not vRP.getUserIdentity then return nil end
            local identity = vRP.getUserIdentity({user_id})
            if identity then
                return Sky.String.SanitizeForSQL(identity.firstname or identity.first_name)
            end
        end
        return nil
    end

    function Sky.FW.GetLastname(source)
        if source ~= nil then
            local user_id = vRP.getUserId({source})
            if not user_id or not vRP.getUserIdentity then return nil end
            local identity = vRP.getUserIdentity({user_id})
            if identity then
                return Sky.String.SanitizeForSQL(identity.lastname or identity.last_name or identity.name)
            end
        end
        return nil
    end

    function Sky.FW.GetBirthdate(source)
        return nil
    end

    function Sky.FW.GetPlayerDirectoryQueryConfig()
        return {
            from = "vrp_users u",
            joins = {
                "LEFT JOIN vrp_user_identities ui ON ui.user_id = u.id"
            },
            identifier = "u.id",
            firstname = "COALESCE(ui.firstname, ui.first_name, '')",
            lastname = "COALESCE(ui.lastname, ui.last_name, ui.name, '')",
            gender = "'unknown'",
            dob = "NULL",
            jobName = "NULL",
            jobLabel = "NULL",
            orderBy = "LOWER(COALESCE(ui.firstname, ui.first_name, '')), LOWER(COALESCE(ui.lastname, ui.last_name, ui.name, '')), u.id"
        }
    end

    function Sky.FW.GetAccountMoney(source, account)
        if source ~= nil then
            local user_id = vRP.getUserId({source})
            if account == "bank" then
                return vRP.getBankMoney({user_id})
            else
                return vRP.getMoney({user_id})
            end
            return 0
        end
        return 0
    end

    function Sky.FW.AddAccountMoney(source, account, amount)
        local user_id = vRP.getUserId({source})
        vRP.giveBankMoney({user_id, amount})
    end

    function Sky.FW.RemoveAccountMoney(source, account, amount)
        local user_id = vRP.getUserId({source})
        if vRP.tryBankPayment({user_id, amount}) then
            return true
        end
        return false
    end

    function Sky.FW.GetJob(source)
        if source ~= nil then
            local user_id = vRP.getUserId({source})
            return vRP.getUserFaction({user_id})
        else
            return false
        end
    end

    function Sky.FW.GetPlayers()
        return vRP.getUsers({})
    end

    function Sky.FW.IsVehicleOwnedByPlayer(source, plate)
        -- Here u need to make a custom logic
    end

    function Sky.FW.ChangePlayerName(source, firstname, lastname)
        -- Here u need to make a custom logic
    end

    function Sky.FW.HasCommandPermission(source, acePerm)
        if source == 0 then return true end
        return IsPlayerAceAllowed(source, acePerm)
    end

    ---Check if a player should be visible on CCTV/Bodycam/Dashcam
    ---@param source string|number
    ---@return boolean
    function Sky.FW.IsPlayerVisibleOnCamera(source)
        local ped = GetPlayerPed(source)
        if not ped or ped == 0 or not DoesEntityExist(ped) then
            return false
        end
        return IsEntityVisible(ped)
    end
end
--   ____  _____ ____ ______   ______ _____ _____ ____     ___     _____ _____  _______ ____    ______   __  _______  __    _    ____    _____ ____  ___ _  _____ _____ ___  _   _    _        _     _   _                  ____  _ _                       _                 _______ _____ _  __     _   _ ____      _ ____ _____ _____
--  |  _ \| ____/ ___|  _ \ \ / /  _ \_   _| ____|  _ \   ( _ )   |  ___|_ _\ \/ / ____|  _ \  | __ ) \ / / |  ___\ \/ /   / \  |  _ \  |  ___|  _ \|_ _| |/ /_ _|_   _/ _ \| \ | |  / \      | |__ | |_| |_ _ __  ___ _   / / /_| (_)___  ___ ___  _ __ __| |  __ _  __ _   / / ____|_   _| |/ /__ _| | | | ___|  __| | ___|___  |___  |
--  | | | |  _|| |   | |_) \ V /| |_) || | |  _| | | | |  / _ \/\ | |_   | | \  /|  _| | | | | |  _ \\ V /  | |_   \  /   / _ \ | |_) | | |_  | |_) || || ' / | |  | || | | |  \| | / _ \     | '_ \| __| __| '_ \/ __(_) / / / _` | / __|/ __/ _ \| '__/ _` | / _` |/ _` | / /|  _|   | | | ' // _` | |_| |___ \ / _` |___ \  / /   / /
--  | |_| | |__| |___|  _ < | | |  __/ | | | |___| |_| | | (_>  < |  _|  | | /  \| |___| |_| | | |_) || |   |  _|  /  \  / ___ \|  __/  |  _| |  _ < | || . \ | |  | || |_| | |\  |/ ___ \ _  | | | | |_| |_| |_) \__ \_ / / / (_| | \__ \ (_| (_) | | | (_| || (_| | (_| |/ / | |___  | | | . \ (_| |  _  |___) | (_| |___) |/ /   / /
--  |____/|_____\____|_| \_\|_| |_|    |_| |_____|____/   \___/\/ |_|   |___/_/\_\_____|____/  |____/ |_|   |_|   /_/\_\/_/   \_\_|     |_|   |_| \_\___|_|\_\___| |_| \___/|_| \_/_/   \_(_) |_| |_|\__|\__| .__/|___(_)_/_/ \__,_|_|___/\___\___/|_|  \__,_(_)__, |\__, /_/  |_____| |_| |_|\_\__, |_| |_|____/ \__,_|____//_/   /_/
--                                                                                                                                                                                                          |_|                                                |___/ |___/                         |_|
-- https://discord.gg/ETKqH5d577
