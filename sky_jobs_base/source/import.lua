if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/import.lua") end
if not SkyDiagnostics and not _SKY_LOGGING_UNAVAILABLE_WARNED then
    _SKY_LOGGING_UNAVAILABLE_WARNED = true
    print("^3[sky_jobs_base][WARN][logging.unavailable] source/diagnostics.lua did not load. Update this resource including fxmanifest.lua and source/diagnostics.lua, then restart it. Native gameplay registration remains enabled.^0")
end
-- =====================================================
--  sky_jobs_base · source/import.lua
--  Jobs Base Universal Bridge & Access System Importer
-- =====================================================

Sky = Sky or {}
Sky.Config = Sky.Config or Config or {}
Sky.Functions = Sky.Functions or Functions or {}
Sky_Jobs = Sky_Jobs or {}

-- -----------------------------------------------------
--  PERMISSIONS ENUM
-- -----------------------------------------------------
Permission = Permission or {
    VIEW_LOGS = 1,
    MANAGE_ROLES = 2,
    MANAGE_MEMBERS = 3,
    MANAGE_WAREHOUSE = 4,
    MANAGE_MONEY = 5,
    EDIT_OUTFITS = 6,
    CREATE_OUTFITS = 7,
    DELETE_OUTFITS = 8,
    PURCHASE_SUPPLIES = 9,
    PURCHASE_VEHICLES = 10,
    GARAGE_VEHICLES = 11,
    SELL_VEHICLES = 12,
    TABLET_APPS = 13,
    DOCUMENT_CLASSIFICATIONS = 14,
    ALL = 57495345
}

-- -----------------------------------------------------
--  SHARED LOGGING & DEBUGGING HELPERS
-- -----------------------------------------------------
function Sky.V(val, label)
    if Sky.Config and Sky.Config.debug then
        local prefix = (label or "")
        if val == nil then
            Sky.Debug("error", prefix .. ": nil")
        elseif type(val) == "table" then
            Sky.Debug("debug", prefix .. ": " .. json.encode(val))
        else
            Sky.Debug("debug", prefix .. ": " .. tostring(val))
        end
    end
    return val
end

function Sky.Debug(level, formatStr, ...)
    local argCount = select("#", ...)
    local unpackFn = table.unpack or unpack
    local overrideCfg = nil

    if level == "debug" and argCount > 0 then
        local lastArg = select(argCount, ...)
        if type(lastArg) == "table" and (lastArg.always ~= nil or lastArg.force ~= nil) then
            overrideCfg = lastArg
            argCount = argCount - 1
        end
    end

    local args = {}
    for i = 1, argCount do
        args[i] = select(i, ...)
    end

    local formattedMsg
    if formatStr:find("%%[^s]") then
        formattedMsg = formatStr
    else
        formattedMsg = formatStr:format(unpackFn(args, 1, argCount))
    end

    if SkyDiagnostics then SkyDiagnostics.Message(level, formattedMsg); return end

    if level == "info" then
        print("^0[^2INFO^0] ^2" .. formattedMsg .. "^0")
    elseif level == "error" then
        print("^0[^1ERROR^0] ^1" .. formattedMsg .. "^0")
    elseif level == "warn" then
        print("^0[^3WARNING^0] ^3" .. formattedMsg .. "^0")
    elseif level == "debug" then
        local isDebug = (Sky.Config and Sky.Config.debug) or (overrideCfg and (overrideCfg.always or overrideCfg.force))
        if isDebug then
            print("^0[^5DEBUG^0] ^5" .. formattedMsg .. "^0")
        end
    end
end

function Sky.IsDebugActive()
    return (Sky.Config and Sky.Config.debug) == true
end

local lastCooldownTimers = {}
function Sky.Cooldown(durationMs, key)
    local now = GetGameTimer()
    key = key or "global"
    if lastCooldownTimers[key] and (now - lastCooldownTimers[key]) < (durationMs or 250) then
        return false
    end
    lastCooldownTimers[key] = now
    return true
end

function Sky.Pairs(tbl, label)
    Sky.V(tbl, label)
    if type(tbl) == "table" then
        return pairs(tbl)
    else
        Sky.Debug("error", "Expected a table for %s, got %s", label, type(tbl))
        return pairs({})
    end
end

function Sky.Ipairs(tbl, label)
    Sky.V(tbl, label)
    if type(tbl) == "table" then
        return ipairs(tbl)
    else
        Sky.Debug("error", "Expected a table for %s, got %s", label, type(tbl))
        return ipairs({})
    end
end

function Sky.GetVal(tbl, ...)
    local keys = { ... }
    local lastKey = tostring(keys[#keys])
    local pathStr = ""

    for i, key in ipairs(keys) do
        if i > 2 then
            pathStr = pathStr .. "."
        end
        if i > 1 then
            pathStr = pathStr .. tostring(keys[i - 1])
        end

        if type(tbl) ~= "table" then
            Sky.Debug("error", "Expected a table for '%s' to index '%s' but got %s", pathStr, lastKey, type(tbl))
            return nil
        end

        tbl = tbl[key]
    end

    return tbl
end

-- -----------------------------------------------------
--  SHARED MATH HELPERS
-- -----------------------------------------------------
Sky.Math = Sky.Math or {}

function Sky.Math.Round(value, numDecimalPlaces)
    if not value then return 0 end
    if numDecimalPlaces then
        local mult = 10 ^ numDecimalPlaces
        return math.floor(value * mult + 0.5) / mult
    else
        return math.floor(value + 0.5)
    end
end

function Sky.Math.Trim(str)
    if not str then return nil end
    return (tostring(str):gsub("^%s*(.-)%s*$", "%1"))
end

function Sky.Math.GroupDigits(value)
    local left, num, right = string.match(tostring(value or 0), "^([^%d]*%d)(%d*)(.-)$")
    if not left then return tostring(value) end
    local groupSymbol = ","
    local formattedNum = num:reverse():gsub("(%d%d%d)", "%1" .. groupSymbol):reverse()
    return left .. formattedNum .. right
end

function Sky.Math.GetRandomNumbers(len)
    local chars = {}
    for i = 1, (len or 1) do
        chars[#chars + 1] = tostring(math.random(0, 9))
    end
    return table.concat(chars)
end

function Sky.Math.GetRandomLetters(len)
    local chars = {}
    for i = 1, (len or 1) do
        chars[#chars + 1] = string.char(math.random(65, 90))
    end
    return table.concat(chars)
end

-- -----------------------------------------------------
--  SHARED STRING HELPERS
-- -----------------------------------------------------
Sky.String = Sky.String or {}

function Sky.String.Split(str, sep)
    local result = {}
    local startIndex = 1
    local matchStart, matchEnd = string.find(str, sep, startIndex)

    while matchStart do
        table.insert(result, string.sub(str, startIndex, matchStart - 1))
        startIndex = matchEnd + 1
        matchStart, matchEnd = string.find(str, sep, startIndex)
    end

    table.insert(result, string.sub(str, startIndex))
    return result
end

function Sky.String.ToTable(str)
    local result = {}
    for i = 1, #str do
        result[i] = str:sub(i, i)
    end
    return result
end

function Sky.String.SanitizeForSQL(str)
    local sanitized = str:gsub("[';\\`\"%c]", ""):match("^%s*(.-)%s*$")
    if not sanitized or sanitized == "" then
        return "Unknown"
    end
    return sanitized
end

-- -----------------------------------------------------
--  SHARED TABLE HELPERS
-- -----------------------------------------------------
Sky.Table = Sky.Table or {}

function Sky.Table.SearchTableList(list, key, value)
    if type(list) ~= "table" then return nil, nil end
    for idx, item in ipairs(list) do
        if type(item) == "table" and item[key] == value then
            return item, idx
        end
    end
    return nil, nil
end

function Sky.Table.Mix(list)
    if type(list) ~= "table" then return {} end
    local result = {}
    for i = 1, #list do
        result[i] = list[i]
    end
    for i = #result, 2, -1 do
        local randIdx = math.random(i)
        result[i], result[randIdx] = result[randIdx], result[i]
    end
    return result
end

function Sky.Table.Filter(tbl, predicate)
    if type(tbl) ~= "table" or type(predicate) ~= "function" then return nil end
    local result = {}
    for k, v in pairs(tbl) do
        if predicate(v, k) then
            table.insert(result, v)
        end
    end
    return result
end

function Sky.Table.Map(tbl, fn)
    if type(tbl) ~= "table" or type(fn) ~= "function" then return {} end
    local result = {}
    for k, v in pairs(tbl) do
        table.insert(result, fn(v, k))
    end
    return result
end

function Sky.Table.Find(tbl, predicate)
    if type(tbl) ~= "table" or type(predicate) ~= "function" then return nil, nil end
    for k, v in pairs(tbl) do
        if predicate(v, k) then
            return v, k
        end
    end
    return nil, nil
end

function Sky.Table.Size(tbl)
    if type(tbl) ~= "table" then return 0 end
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function Sky.Table.Includes(list, value)
    if type(list) ~= "table" then return false end
    for _, v in ipairs(list) do
        if v == value then return true end
    end
    return false
end

function Sky.Table.Remove(list, value)
    if type(list) ~= "table" then return end
    for i = #list, 1, -1 do
        if list[i] == value then
            table.remove(list, i)
        end
    end
end

-- -----------------------------------------------------
--  SHARED CURRENCY HELPERS
-- -----------------------------------------------------
Sky.Currency = Sky.Currency or {}

function Sky.Currency.Format(amount, currency)
    local num = tonumber(amount) or 0
    return "$" .. Sky.Math.GroupDigits(num)
end

function Sky.Currency.GetDefaultCurrency()
    return "USD"
end

function Sky.Currency.GetNuiConfig()
    return {
        defaultFormatter = "money",
        defaultCurrency = "USD",
        currencies = {
            USD = { symbol = "$", name = "US Dollar" }
        },
        formatters = {
            money = {
                symbol = "$",
                decimals = 0,
                thousandsSeparator = ",",
                decimalSeparator = "."
            }
        }
    }
end

function Sky.Currency.FormatCurrencyAmount(amount, currency)
    return Sky.Currency.Format(amount, currency)
end

-- -----------------------------------------------------
--  SERVER-SIDE ENVIRONMENT
-- -----------------------------------------------------
if IsDuplicityVersion() then
    Sky.Cb = Sky.Cb or {}
    local localServerCallbacks = {}

    function Sky.Cb.Register(name, callbackFunction)
    if SkyDiagnostics then callbackFunction = SkyDiagnostics.Wrap("callback", name, callbackFunction) end
        assert(name ~= nil, 'Parameter "name" must be a string!')
        assert(callbackFunction ~= nil, 'Parameter "callbackFunction" must be a function!')
        localServerCallbacks[name] = callbackFunction

        if GetCurrentResourceName() ~= "sky_base" then
            if GetResourceState("sky_base") == "started" then
                pcall(function()
                    exports.sky_base:RegisterServerCallback(name, callbackFunction)
                end)
            end
            TriggerEvent("sky_base:registerServerCallback", name, callbackFunction)
        end
    end

    function Sky.Cb.TriggerClient(source, name, ...)
        if GetResourceState("sky_base") == "started" then
            local success, res = pcall(function(...)
                return exports.sky_base:TriggerClientCallback(source, name, ...)
            end, ...)
            if success then
                return res
            end
        end
        return nil
    end

    -- Sky_Jobs Server Bridge
    Sky_Jobs.PlayerCache = Sky_Jobs.PlayerCache or {}
    Sky_Jobs.Access = Sky_Jobs.Access or {}
    Sky_Jobs.RegisteredTabletApps = Sky_Jobs.RegisteredTabletApps or {}

    local localPlayerDutyState = {}
    local localPlayerJobCache = {}

    function Sky_Jobs.PlayerCache.IsOnDuty(source)
        local src = tonumber(source)
        if not src or src <= 0 then return true end

        if localPlayerDutyState[src] ~= nil then
            return localPlayerDutyState[src] == true
        end

        if GetResourceState("sky_jobs_base") == "started" and GetCurrentResourceName() ~= "sky_jobs_base" then
            local ok, duty = pcall(function()
                return exports.sky_jobs_base:isOnDuty(src)
            end)
            if ok and duty ~= nil then
                return duty == true
            end
        end

        if Sky and Sky.FW and Sky.FW.GetJobData then
            local duty = Sky.FW.GetJobData(src, "duty")
            if duty ~= nil then return duty == true end
        end

        return true
    end

    function Sky_Jobs.PlayerCache.SetDuty(source, onDuty)
        local src = tonumber(source)
        if not src or src <= 0 then return end
        localPlayerDutyState[src] = (onDuty == true)
    end

    function Sky_Jobs.PlayerCache.GetJob(source)
        local src = tonumber(source)
        if not src or src <= 0 then return "" end

        if localPlayerJobCache[src] and localPlayerJobCache[src] ~= "" then
            return localPlayerJobCache[src]
        end

        if Sky and Sky.FW and Sky.FW.GetJob then
            local job = Sky.FW.GetJob(src)
            if job and job ~= "" then return job end
        end

        return "unemployed"
    end

    function Sky_Jobs.PlayerCache.GetJobGrade(source)
        local src = tonumber(source)
        if not src or src <= 0 then return 0 end

        if Sky and Sky.FW and Sky.FW.GetJobData then
            local grade = Sky.FW.GetJobData(src, "grade")
            if grade ~= nil then return tonumber(grade) or 0 end
        end

        return 0
    end

    function Sky_Jobs.PlayerCache.UpdateJob(source, jobName)
        local src = tonumber(source)
        if not src or src <= 0 then return end
        localPlayerJobCache[src] = tostring(jobName or "")
    end

    function Sky_Jobs.GetOnDutyCount(jobName)
        if not jobName or jobName == "" then return 0 end
        local count = 0
        for _, srcStr in ipairs(GetPlayers()) do
            local src = tonumber(srcStr)
            if src and Sky_Jobs.PlayerCache.GetJob(src) == jobName and Sky_Jobs.PlayerCache.IsOnDuty(src) then
                count = count + 1
            end
        end
        return count
    end

    Sky_Jobs.Access.IsOnDuty = function(source)
        return Sky_Jobs.PlayerCache.IsOnDuty(source)
    end

    function Sky_Jobs.RegisterTabletApps(resourceName, apps)
        Sky_Jobs.RegisteredTabletApps[resourceName] = apps
        if GetResourceState("sky_jobs_base") == "started" and GetCurrentResourceName() ~= "sky_jobs_base" then
            pcall(function()
                exports.sky_jobs_base:RegisterTabletApps(resourceName, apps)
            end)
        end
    end

-- -----------------------------------------------------
--  CLIENT-SIDE ENVIRONMENT
-- -----------------------------------------------------
else
    Sky.Cb = Sky.Cb or {}

    local clientCallbacks = {}
    local clientCallbackResponses = {}
    local currentRequestId = 0

    function Sky.Cb.Register(name, callbackFunction)
    if SkyDiagnostics then callbackFunction = SkyDiagnostics.Wrap("callback", name, callbackFunction) end
        assert(name ~= nil, 'Parameter "name" must be a string!')
        assert(callbackFunction ~= nil, 'Parameter "callbackFunction" must be a function!')
        clientCallbacks[name] = callbackFunction
    end

    function Sky.Cb.Trigger(name, ...)
        assert(name ~= nil, 'Parameter "name" must be a string!')
        local timeout = (Sky.Config and Sky.Config.defaultCallbackTimeout) or 5000
        return Sky.Cb.TriggerWithTimeout(name, timeout, ...)
    end

    function Sky.Cb.TriggerWithTimeout(name, timeout, ...)
        assert(name ~= nil, 'Parameter "name" must be a string!')
        assert(timeout ~= nil, 'Parameter "timeout" must be a number!')

        local requestId = currentRequestId
        currentRequestId = (currentRequestId + 1) % 65536
        local requestKey = name .. tostring(requestId)

        TriggerServerEvent("sky_base:sc", name, requestId, { ... })
        clientCallbackResponses[requestKey] = true

        local startTime = GetGameTimer()
        while clientCallbackResponses[requestKey] == true do
            Citizen.Wait(50)
            if GetGameTimer() > (startTime + timeout) then
                clientCallbackResponses[requestKey] = "ERROR"
                print(("^1[sky_base] ServerCallback %s timed out after %dms!^0"):format(name, timeout))
                break
            end
        end

        if clientCallbackResponses[requestKey] == "ERROR" then
            return nil
        end

        local resultData = clientCallbackResponses[requestKey]
        clientCallbackResponses[requestKey] = nil

        if type(resultData) == "table" then
            return table.unpack(resultData)
        end
        return resultData
    end

    function Sky.Cb.TriggerAsync(name, callbackFunction, ...)
        assert(name ~= nil, 'Parameter "name" must be a string!')
        assert(callbackFunction ~= nil, 'Parameter "callbackFunction" must be a function!')

        local args = { ... }
        Citizen.CreateThread(function()
            local result = { Sky.Cb.Trigger(name, table.unpack(args)) }
            callbackFunction(table.unpack(result))
        end)
    end

    function Sky.Cb.TriggerWithTimeoutAsync(name, timeout, callbackFunction, ...)
        assert(name ~= nil, 'Parameter "name" must be a string!')
        assert(timeout ~= nil, 'Parameter "timeout" must be a number!')
        assert(callbackFunction ~= nil, 'Parameter "callbackFunction" must be a function!')

        local args = { ... }
        Citizen.CreateThread(function()
            local result = { Sky.Cb.TriggerWithTimeout(name, timeout, table.unpack(args)) }
            callbackFunction(table.unpack(result))
        end)
    end

    if not _SKY_CB_CLIENT_NET_INITIALIZED then
        _SKY_CB_CLIENT_NET_INITIALIZED = true

        RegisterNetEvent("sky_base:scResponse", function(requestKey, data)
            if clientCallbackResponses[requestKey] == nil then return end
            clientCallbackResponses[requestKey] = data
        end)

        RegisterNetEvent("sky_base:scDoesNotExist", function(requestKey, name)
            if clientCallbackResponses[requestKey] == nil then return end
            clientCallbackResponses[requestKey] = "ERROR"
            print(("^3[sky_base] ServerCallback \"%s\" does not exist!^0"):format(tostring(name)))
        end)

        RegisterNetEvent("sky_base:scError", function(requestKey, name, err)
            if clientCallbackResponses[requestKey] == nil then return end
            clientCallbackResponses[requestKey] = "ERROR"
            print(("^1[sky_base] ServerCallback \"%s\" threw error: %s^0"):format(tostring(name), tostring(err or "unknown")))
        end)

        RegisterNetEvent("sky_base:cc", function(name, requestId, args)
            local requestKey = name .. tostring(requestId)
            local cb = clientCallbacks[name]

            if not cb then
                TriggerServerEvent("sky_base:ccDoesNotExist", requestKey, name)
                return
            end

            local packed = table.pack(pcall(cb, table.unpack(args or {})))
            local success = packed[1]

            if not success then
                local err = packed[2]
                TriggerServerEvent("sky_base:ccError", requestKey, name, tostring(err))
                return
            end

            table.remove(packed, 1)
            TriggerServerEvent("sky_base:ccResponse", requestKey, packed)
        end)
    end

    -- -----------------------------------------------------
    --  KEYBINDING / INPUT REGISTRATION
    -- -----------------------------------------------------
    function Sky.RegisterInput(description, key, callback)
        local commandName = ("sky-keys-%s-%s"):format(GetCurrentResourceName(), key)
        RegisterKeyMapping(commandName, description, "keyboard", key)
        RegisterCommand(commandName, function()
            if type(callback) == "function" then
                callback()
            end
        end, false)
    end

    -- -----------------------------------------------------
    --  INTERACTION POINT WRAPPERS
    -- -----------------------------------------------------
    function Sky.CreateInteractionPoint(...)
        if GetResourceState("sky_base") == "started" then
            local ok, sky = pcall(function() return exports.sky_base:Get() end)
            if ok and type(sky) == "table" and type(sky.CreateInteractionPoint) == "function" then
                return sky.CreateInteractionPoint(...)
            end
        end
    end

    function Sky.DeleteInteractionPoint(...)
        if GetResourceState("sky_base") == "started" then
            local ok, sky = pcall(function() return exports.sky_base:Get() end)
            if ok and type(sky) == "table" and type(sky.DeleteInteractionPoint) == "function" then
                return sky.DeleteInteractionPoint(...)
            end
        end
    end

    -- -----------------------------------------------------
    --  SHOW HELPERS
    -- -----------------------------------------------------
    Sky.Show = Sky.Show or {}

    function Sky.Show.Notification(title, text, notifyType, duration)
        if GetResourceState("sky_hud") == "started" then
            exports.sky_hud:notify(title, text, notifyType, duration)
        elseif GetResourceState("zenit_hud") == "started" then
            exports.zenit_hud:showNotify(title, text, notifyType, duration)
        elseif GetResourceState("sky_notify") == "started" then
            exports.sky_notify:show(title, text, notifyType, duration)
        elseif Functions and Functions.ShowNotification then
            Functions.ShowNotification(title, text, notifyType, duration)
        else
            BeginTextCommandThefeedPost("STRING")
            AddTextComponentSubstringPlayerName(tostring(text or title or ""))
            EndTextCommandThefeedPostTicker(false, true)
        end
    end

    function Sky.Show.HelpNotification(text, b)
        if GetResourceState("sky_hud") == "started" then
            exports.sky_hud:pressE(text, b)
        elseif GetResourceState("zenit_hud") == "started" then
            exports.zenit_hud:showInteractionThisFrame(b, text)
        elseif Functions and Functions.ShowHelpNotification then
            Functions.ShowHelpNotification(text, b)
        else
            BeginTextCommandDisplayHelp("STRING")
            AddTextComponentSubstringPlayerName(tostring(text or ""))
            EndTextCommandDisplayHelp(0, false, true, -1)
        end
    end

    function Sky.Show.showHelpNotification(enabled)
    end

    function Sky.Show.Blip(coords, sprite, color, title, display, scale)
        local pos = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
        local blip = AddBlipForCoord(pos)
        SetBlipSprite(blip, sprite or 1)
        SetBlipDisplay(blip, display or 4)
        SetBlipScale(blip, scale or (Sky.Config and Sky.Config.defaultBlipSize) or 0.8)
        SetBlipColour(blip, color or 0)
        SetBlipAsShortRange(blip, true)
        if title then
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(title)
            EndTextCommandSetBlipName(blip)
        end
        return blip
    end

    function Sky.Show.Marker(coords, options)
        options = options or {}
        local pos = vector3(coords.x, coords.y, coords.z)
        if type(options.offset) == "number" then
            pos = vector3(pos.x, pos.y, pos.z + options.offset)
        elseif type(options.offset) == "table" or type(options.offset) == "vector3" then
            pos = pos + vector3(options.offset.x or 0, options.offset.y or 0, options.offset.z or 0)
        end
        local mType = tonumber(options.type) or (Sky.Config and Sky.Config.defaultMarkerType) or 2
        local scaleX = tonumber(options.scaleX) or tonumber(options.scale) or (Sky.Config and Sky.Config.defaultMarkerSize) or 1.0
        local scaleY = tonumber(options.scaleY) or tonumber(options.scale) or (Sky.Config and Sky.Config.defaultMarkerSize) or 1.0
        local scaleZ = tonumber(options.scaleZ) or tonumber(options.scale) or 0.5
        local r = tonumber(options.r) or (Sky.Config and Sky.Config.defaultMarkerColor and Sky.Config.defaultMarkerColor.r) or 0
        local g = tonumber(options.g) or (Sky.Config and Sky.Config.defaultMarkerColor and Sky.Config.defaultMarkerColor.g) or 150
        local b = tonumber(options.b) or (Sky.Config and Sky.Config.defaultMarkerColor and Sky.Config.defaultMarkerColor.b) or 255
        local a = tonumber(options.a) or (Sky.Config and Sky.Config.defaultMarkerColor and Sky.Config.defaultMarkerColor.a) or 100
        DrawMarker(mType, pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scaleX, scaleY, scaleZ, r, g, b, a, false, false, 2, options.rotate or false, nil, nil, false)
    end

    -- -----------------------------------------------------
    --  LOAD HELPERS
    -- -----------------------------------------------------
    Sky.Load = Sky.Load or {}

    function Sky.Load.Model(model, cb)
        local hash = type(model) == "number" and model or joaat(model)
        if not HasModelLoaded(hash) then
            if IsModelInCdimage(hash) then
                RequestModel(hash)
                while not HasModelLoaded(hash) do
                    Wait(0)
                end
            end
        end
        if cb then cb() end
    end

    function Sky.Load.AnimDict(dict, cb)
        if not HasAnimDictLoaded(dict) then
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                Wait(0)
            end
        end
        if cb then cb() end
    end

    function Sky.Load.AnimSet(animSet, cb)
        if not HasAnimSetLoaded(animSet) then
            RequestAnimSet(animSet)
            while not HasAnimSetLoaded(animSet) do
                Wait(0)
            end
        end
        if cb then cb() end
    end

    function Sky.Load.StreamedTextureDict(dict, cb)
        if not HasStreamedTextureDictLoaded(dict) then
            RequestStreamedTextureDict(dict)
            while not HasStreamedTextureDictLoaded(dict) do
                Wait(0)
            end
        end
        if cb then cb() end
    end

    function Sky.Load.NamedPtfxAsset(asset, cb)
        if not HasNamedPtfxAssetLoaded(asset) then
            RequestNamedPtfxAsset(asset)
            while not HasNamedPtfxAssetLoaded(asset) do
                Wait(0)
            end
        end
        if cb then cb() end
    end

    function Sky.Load.WeaponAsset(asset, cb)
        if not HasWeaponAssetLoaded(asset) then
            RequestWeaponAsset(asset)
            while not HasWeaponAssetLoaded(asset) do
                Wait(0)
            end
        end
        if cb then cb() end
    end

    function Sky.Load.Scaleform(scaleformName)
        local handle = RequestScaleformMovie(scaleformName)
        while not HasScaleformMovieLoaded(handle) do
            handle = RequestScaleformMovie(scaleformName)
            Wait(0)
        end
        return handle
    end

    -- -----------------------------------------------------
    --  PED MODULE
    -- -----------------------------------------------------
    Sky.Ped = Sky.Ped or {}
    Sky.Ped.__index = Sky.Ped

    function Sky.Ped.new(entity)
        local self = setmetatable({}, Sky.Ped)
        self.entity = entity
        return self
    end

    function Sky.Ped:Spawn(model, coords, heading, options)
        local pos = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
        local hash = type(model) == "number" and model or joaat(model)
        local head = heading or 0.0
        local isInteraction = options and options.spawnProfile == "interaction"

        Sky.Load.Model(hash)
        local pedHandle = CreatePed(4, hash, pos, head, false, true)
        self.entity = pedHandle

        SetEntityAsMissionEntity(pedHandle, true, true)
        SetModelAsNoLongerNeeded(hash)

        if not isInteraction then
            Wait(100)
            SetEntityVisible(pedHandle, true, false)
            ResetEntityAlpha(pedHandle)
            SetEntityCollision(pedHandle, true, true)
            SetPedDefaultComponentVariation(pedHandle)
            SetPedComponentVariation(pedHandle, 0, 0, 0, 0)
        end

        if options then
            if options.scenario then
                TaskStartScenarioInPlace(pedHandle, options.scenario, 0, true)
            end
            if type(options.onSpawn) == "function" then
                options.onSpawn(pedHandle)
            end
        end
    end

    function Sky.Ped:PlayAnim(dict, anim, duration)
        if not self.entity or not DoesEntityExist(self.entity) then return end
        Sky.Load.AnimDict(dict)
        TaskPlayAnim(self.entity, dict, anim, 8.0, -8.0, duration or -1, 1, 0, false, false, false)
    end

    function Sky.Ped:StopAnim()
        if not self.entity or not DoesEntityExist(self.entity) then return end
        ClearPedTasks(self.entity)
    end

    function Sky.Ped:GetCoords()
        if not self.entity or not DoesEntityExist(self.entity) then return end
        return GetEntityCoords(self.entity)
    end

    function Sky.Ped:SetCoords(coords, heading)
        if not self.entity or not DoesEntityExist(self.entity) then return end
        local pos = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
        SetEntityCoords(self.entity, pos, false, false, false, true)
        if heading ~= nil then
            SetEntityHeading(self.entity, heading)
        end
    end

    function Sky.Ped:Freeze()
        if not self.entity or not DoesEntityExist(self.entity) then return end
        FreezeEntityPosition(self.entity, true)
        SetEntityInvincible(self.entity, true)
        SetBlockingOfNonTemporaryEvents(self.entity, true)
        SetCanAttackFriendly(self.entity, true, true)
    end

    function Sky.Ped.Delete(ped)
        if not ped or ped == 0 or not DoesEntityExist(ped) then return true end
        if GetEntityType(ped) ~= 1 or IsPedAPlayer(ped) then return false end

        local timeout = GetGameTimer() + 1000
        while DoesEntityExist(ped) and GetGameTimer() < timeout do
            if NetworkGetEntityIsNetworked(ped) and not NetworkHasControlOfEntity(ped) then
                NetworkRequestControlOfEntity(ped)
            end
            SetEntityAsMissionEntity(ped, true, true)
            DetachEntity(ped, true, true)
            ClearPedTasksImmediately(ped)
            SetBlockingOfNonTemporaryEvents(ped, true)
            FreezeEntityPosition(ped, true)
            DeletePed(ped)
            if DoesEntityExist(ped) then DeleteEntity(ped) end
            if DoesEntityExist(ped) then Wait(0) end
        end
        return not DoesEntityExist(ped)
    end

    -- -----------------------------------------------------
    --  CAMERA MODULE
    -- -----------------------------------------------------
    Sky.Cam = Sky.Cam or {}
    Sky.Cam.__index = Sky.Cam

    function Sky.Cam.new(coords, rotation, transition)
        local self = setmetatable({}, Sky.Cam)
        local ped = PlayerPedId()
        local pos = coords or GetEntityCoords(ped)
        if type(pos) ~= "vector3" then
            pos = vec(pos.x, pos.y, pos.z)
        end

        local rot = rotation or { 0.0, 0.0, 270.0 }
        local rx, ry, rz = rot[1] or rot.x, rot[2] or rot.y, rot[3] or rot.z

        local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(cam, true)
        RenderScriptCams(true, transition, 500, true, true)
        SetCamCoord(cam, pos)
        SetCamRot(cam, rx, ry, rz, 2)

        self.cam = cam
        self.transition = transition
        return self
    end

    function Sky.Cam:Remove()
        if not self.cam then return end
        SetCamActive(self.cam, false)
        RenderScriptCams(false, self.transition, 500, true, true)
        DestroyCam(self.cam, false)
        self.cam = nil
    end

    function Sky.Cam:PointCamAtEntity(entity, distance)
        if not self.cam or not DoesEntityExist(entity) then return end
        local coords = GetEntityCoords(entity)
        local heading = GetEntityHeading(entity)
        local dist = distance or 1.5

        local offsetX = dist * math.cos(math.rad(heading - 90.0))
        local offsetY = dist * math.sin(math.rad(heading - 90.0))
        local camPos = vector3(coords.x - offsetX, coords.y - offsetY, coords.z + 0.5)
        local camRot = vector3(0.0, 0.0, heading + 180.0)

        SetCamCoord(self.cam, camPos)
        SetCamRot(self.cam, camRot.x, camRot.y, camRot.z, 2)
        local targetOffset = GetOffsetFromEntityInWorldCoords(entity, -0.6, 0.0, 0.25)
        PointCamAtCoord(self.cam, targetOffset.x, targetOffset.y, targetOffset.z)
    end

    -- -----------------------------------------------------
    --  VEHICLE MODULE
    -- -----------------------------------------------------
    Sky.Vehicle = Sky.Vehicle or {}
    Sky.Vehicle.__index = Sky.Vehicle

    function Sky.Vehicle.new(entity)
        local self = setmetatable({}, Sky.Vehicle)
        self.entity = entity
        return self
    end

    function Sky.Vehicle.GetClosest(coords, modelFilter)
        local filterHash = nil
        if modelFilter then
            filterHash = type(modelFilter) == "number" and modelFilter or GetHashKey(modelFilter)
        end
        local targetPos = coords and vector3(coords.x, coords.y, coords.z) or GetEntityCoords(PlayerPedId())
        local pool = GetGamePool("CVehicle")
        local closestVeh, closestDist = -1, -1

        for _, veh in pairs(pool) do
            if not filterHash or GetEntityModel(veh) == filterHash then
                local dist = #(targetPos - GetEntityCoords(veh))
                if closestDist == -1 or dist < closestDist then
                    closestVeh = veh
                    closestDist = dist
                end
            end
        end
        return closestVeh, closestDist
    end

    function Sky.Vehicle:Spawn(model, coords, heading)
        local hash = type(model) == "number" and model or joaat(model)
        local pos = vector3(coords.x, coords.y, coords.z)
        local head = heading or 0.0

        Sky.Load.Model(hash)
        local veh = CreateVehicle(hash, pos, head, true, true)
        local netId = NetworkGetNetworkIdFromEntity(veh)
        SetNetworkIdCanMigrate(netId, true)
        SetEntityAsMissionEntity(veh, true, true)
        SetVehicleHasBeenOwnedByPlayer(veh, true)
        SetVehicleNeedsToBeHotwired(veh, false)
        SetModelAsNoLongerNeeded(hash)
        SetVehRadioStation(veh, "OFF")

        RequestCollisionAtCoord(pos)
        while not HasCollisionLoadedAroundEntity(veh) do
            Wait(0)
        end

        self.entity = veh
        return veh
    end

    function Sky.Vehicle:GetProperties()
        return self:GetVehicleProperties()
    end

    function Sky.Vehicle:GetVehicleProperties()
        local veh = self.entity
        if not veh or not DoesEntityExist(veh) then return nil end

        local colorPrimary, colorSecondary = GetVehicleColours(veh)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
        local isPrimaryCustom = GetIsVehiclePrimaryColourCustom(veh)
        local isSecondaryCustom = GetIsVehicleSecondaryColourCustom(veh)

        local customPrimary = isPrimaryCustom and { GetVehicleCustomPrimaryColour(veh) } or nil
        local customSecondary = isSecondaryCustom and { GetVehicleCustomSecondaryColour(veh) } or nil
        local hasCustomXenon, xr, xg, xb = GetVehicleXenonLightsCustomColor(veh)
        local customXenon = hasCustomXenon and { xr, xg, xb } or nil

        local extras = {}
        for extraId = 0, 20 do
            if DoesExtraExist(veh, extraId) then
                extras[tostring(extraId)] = IsVehicleExtraTurnedOn(veh, extraId)
            end
        end

        local fuel = (Sky.Functions and Sky.Functions.GetVehicleFuel and Sky.Functions.GetVehicleFuel(veh)) or GetVehicleFuelLevel(veh)

        local modLivery = GetVehicleMod(veh, 48)
        if modLivery == -1 then
            modLivery = GetVehicleLivery(veh)
        end

        local mods = {}
        for i = 0, 49 do
            mods[tostring(i)] = GetVehicleMod(veh, i)
        end

        local toggleMods = {}
        for i = 17, 22 do
            toggleMods[tostring(i)] = IsToggleModOn(veh, i)
        end

        return {
            model = GetEntityModel(veh),
            plate = Sky.Math.Trim(GetVehicleNumberPlateText(veh)),
            plateIndex = GetVehicleNumberPlateTextIndex(veh),
            bodyHealth = Sky.Math.Round(GetVehicleBodyHealth(veh), 1),
            engineHealth = Sky.Math.Round(GetVehicleEngineHealth(veh), 1),
            tankHealth = Sky.Math.Round(GetVehiclePetrolTankHealth(veh), 1),
            fuelLevel = Sky.Math.Round(fuel, 1),
            dirtLevel = Sky.Math.Round(GetVehicleDirtLevel(veh), 1),
            color1 = colorPrimary,
            color2 = colorSecondary,
            pearlescentColor = pearlescentColor,
            wheelColor = wheelColor,
            customPrimaryColor = customPrimary,
            customSecondaryColor = customSecondary,
            xenonColor = GetVehicleXenonLightsColor(veh),
            customXenonColor = customXenon,
            wheels = GetVehicleWheelType(veh),
            windowTint = GetVehicleWindowTint(veh),
            extras = extras,
            mods = mods,
            toggleMods = toggleMods,
            modLivery = modLivery
        }
    end

    function Sky.Vehicle:SetProperties(props)
        return self:SetVehicleProperties(props)
    end

    function Sky.Vehicle:SetVehicleProperties(props)
        local veh = self.entity
        if not veh or not DoesEntityExist(veh) or type(props) ~= "table" then return false end

        SetVehicleModKit(veh, 0)

        if props.plate then
            SetVehicleNumberPlateText(veh, props.plate)
        end
        if props.plateIndex then
            SetVehicleNumberPlateTextIndex(veh, props.plateIndex)
        end
        if props.bodyHealth then
            SetVehicleBodyHealth(veh, props.bodyHealth + 0.0)
        end
        if props.engineHealth then
            SetVehicleEngineHealth(veh, props.engineHealth + 0.0)
        end
        if props.tankHealth then
            SetVehiclePetrolTankHealth(veh, props.tankHealth + 0.0)
        end
        if props.fuelLevel then
            if Sky.Functions and Sky.Functions.SetVehicleFuel then
                Sky.Functions.SetVehicleFuel(veh, props.fuelLevel + 0.0)
            else
                SetVehicleFuelLevel(veh, props.fuelLevel + 0.0)
            end
        end
        if props.dirtLevel then
            SetVehicleDirtLevel(veh, props.dirtLevel + 0.0)
        end
        if props.color1 and props.color2 then
            SetVehicleColours(veh, props.color1, props.color2)
        end
        if props.pearlescentColor and props.wheelColor then
            SetVehicleExtraColours(veh, props.pearlescentColor, props.wheelColor)
        end
        if props.customPrimaryColor then
            SetVehicleCustomPrimaryColour(veh, props.customPrimaryColor[1], props.customPrimaryColor[2], props.customPrimaryColor[3])
        end
        if props.customSecondaryColor then
            SetVehicleCustomSecondaryColour(veh, props.customSecondaryColor[1], props.customSecondaryColor[2], props.customSecondaryColor[3])
        end
        if props.xenonColor then
            SetVehicleXenonLightsColor(veh, props.xenonColor)
        end
        if props.customXenonColor then
            SetVehicleXenonLightsCustomColor(veh, props.customXenonColor[1], props.customXenonColor[2], props.customXenonColor[3])
        end
        if props.windowTint then
            SetVehicleWindowTint(veh, props.windowTint)
        end
        if props.wheels then
            SetVehicleWheelType(veh, props.wheels)
        end
        if props.extras then
            for extraId, state in pairs(props.extras) do
                local id = tonumber(extraId)
                if id then
                    SetVehicleExtra(veh, id, state and 0 or 1)
                end
            end
        end
        if props.mods then
            for modId, modVal in pairs(props.mods) do
                local id, val = tonumber(modId), tonumber(modVal)
                if id and val then
                    SetVehicleMod(veh, id, val, false)
                end
            end
        end
        if props.toggleMods then
            for modId, state in pairs(props.toggleMods) do
                local id = tonumber(modId)
                if id then
                    ToggleVehicleMod(veh, id, state == true)
                end
            end
        end
        if props.modLivery and props.modLivery ~= -1 then
            SetVehicleMod(veh, 48, props.modLivery, false)
            SetVehicleLivery(veh, props.modLivery)
        end
        return true
    end

    function Sky.Vehicle:Remove()
        if self.entity and DoesEntityExist(self.entity) then
            SetEntityAsMissionEntity(self.entity, false, true)
            DeleteVehicle(self.entity)
            self.entity = nil
        end
    end

    function Sky.Vehicle.Delete(veh)
        if not veh or veh == 0 or not DoesEntityExist(veh) then return true end
        SetEntityAsMissionEntity(veh, true, true)
        DeleteVehicle(veh)
        if DoesEntityExist(veh) then DeleteEntity(veh) end
        return not DoesEntityExist(veh)
    end

    -- -----------------------------------------------------
    --  SKY_JOBS CLIENT ACCESS & TABLET
    -- -----------------------------------------------------
    Sky_Jobs.Access = Sky_Jobs.Access or {}
    Sky_Jobs.Tablet = Sky_Jobs.Tablet or {}

    local accessState = {
        employed = false,
        onDuty = false,
        jobKey = nil
    }

    local hasSnapshot = false
    local jobFilter = nil

    local function getStateSnapshot()
        return {
            employed = accessState.employed,
            onDuty = accessState.onDuty,
            jobKey = accessState.jobKey
        }
    end

    local function sanitizeJobKey(key)
        if type(key) == "string" and key ~= "" then
            return key
        end
        return nil
    end

    local function extractJobName(data)
        if type(data) == "string" then
            return sanitizeJobKey(data)
        end
        if type(data) == "table" then
            local name = data.name or data.job or data.id or data.jobKey
            return sanitizeJobKey(name)
        end
        return nil
    end

    local function isJobInFilter(jobName)
        if not jobFilter then
            return true
        end
        if jobName then
            return jobFilter[jobName] == true
        end
        return false
    end

    local function setAccessState(isEmployed, isOnDuty, jobKey)
        local sanitizedKey = sanitizeJobKey(jobKey)
        local empFlag = (isEmployed == true) and (sanitizedKey ~= nil)
        local dutyFlag = empFlag and (isOnDuty == true)

        local isChanged = (accessState.employed ~= empFlag or accessState.onDuty ~= dutyFlag or accessState.jobKey ~= sanitizedKey)
        accessState.employed = empFlag
        accessState.onDuty = dutyFlag
        accessState.jobKey = sanitizedKey
        hasSnapshot = true

        if isChanged then
            TriggerEvent("sky_jobs_base:access:stateChanged", getStateSnapshot())
        end
    end

    local function updateJob(data)
        local jobName = extractJobName(data)
        if not jobName then
            setAccessState(false, false, nil)
            return
        end

        if accessState.jobKey and accessState.jobKey ~= jobName then
            setAccessState(true, false, jobName)
            return
        end

        setAccessState(true, accessState.onDuty, jobName)
    end

    function Sky_Jobs.Access.SetJobFilter(filterList)
        if type(filterList) ~= "table" then
            jobFilter = nil
            return
        end

        local map = {}
        for _, item in ipairs(filterList) do
            local name = extractJobName(item)
            if name then
                map[name] = true
            end
        end

        if next(map) then
            jobFilter = map
        else
            jobFilter = nil
        end
    end

    function Sky_Jobs.Access.HasSnapshot()
        return hasSnapshot
    end

    function Sky_Jobs.Access.GetState()
        return getStateSnapshot()
    end

    function Sky_Jobs.Access.GetJobKey()
        return accessState.jobKey
    end

    function Sky_Jobs.Access.IsEmployee()
        if accessState.employed then
            return isJobInFilter(accessState.jobKey)
        end
        return false
    end

    function Sky_Jobs.Access.IsOnDuty()
        if accessState.employed and accessState.onDuty then
            return isJobInFilter(accessState.jobKey)
        end
        return false
    end

    function Sky_Jobs.Access.HasJob()
        return Sky_Jobs.Access.IsOnDuty()
    end

    function Sky_Jobs.Access.Refresh()
        if not Sky or not Sky.Cb or not Sky.Cb.Trigger then
            return false, false
        end

        local jobRes = Sky.Cb.Trigger("sky_jobs_base:creator:getPlayerJob", {})
        local isJobReady = jobRes and jobRes.success and jobRes.data and (jobRes.data.ready == true)

        if not isJobReady then
            return Sky_Jobs.Access.HasJob(), false
        end

        local jobKey = (jobRes.data and jobRes.data.jobKey) or nil
        local hasJobKey = (jobKey ~= nil)
        local isOnDuty = false

        if hasJobKey then
            local dutyRes = Sky.Cb.Trigger("sky_jobs_base:creator:getPlayerDuty", {})
            local isDutyReady = dutyRes and dutyRes.success and dutyRes.data and (dutyRes.data.ready == true)

            if not isDutyReady then
                return Sky_Jobs.Access.HasJob(), false
            end

            if dutyRes and dutyRes.data then
                isOnDuty = (dutyRes.data.onDuty == true)
            end
        end

        setAccessState(hasJobKey, isOnDuty, jobKey)
        return Sky_Jobs.Access.HasJob(), true
    end

    function Sky_Jobs.Tablet.PushNotification(data)
        SendNUIMessage({
            type = "tablet:pushNotification",
            data = data
        })
    end

    if not _SKY_JOBS_ACCESS_CLIENT_INITIALIZED then
        _SKY_JOBS_ACCESS_CLIENT_INITIALIZED = true

        RegisterNetEvent("sky_base:updateJob", function(data)
            updateJob(data)
        end)

        RegisterNetEvent("sky_jobs_base:creator:updatePlayerJob", function(data)
            updateJob(data)
        end)

        RegisterNetEvent("sky_jobs_base:creator:updatePlayerDuty", function(onDuty, jobData)
            local key = jobData or accessState.jobKey
            if key then
                setAccessState(true, onDuty == true, key)
            else
                setAccessState(false, false, nil)
            end
        end)

        RegisterNetEvent("sky_jobs_base:access:stateChanged", function(state)
            if state and type(state) == "table" then
                accessState.employed = state.employed == true
                accessState.onDuty = state.onDuty == true
                accessState.jobKey = sanitizeJobKey(state.jobKey)
                hasSnapshot = true
            end
        end)
    end
end
