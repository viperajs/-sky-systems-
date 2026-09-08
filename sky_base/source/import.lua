if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/import.lua") end
if not SkyDiagnostics and not _SKY_LOGGING_UNAVAILABLE_WARNED then
    _SKY_LOGGING_UNAVAILABLE_WARNED = true
    print("^3[sky_base][WARN][logging.unavailable] source/diagnostics.lua did not load. Update this resource including fxmanifest.lua and source/diagnostics.lua, then restart it. Native gameplay registration remains enabled.^0")
end
-- =====================================================
--  sky_base · source/import.lua
--  Universal Framework Bridge & Core API Importer
-- =====================================================

Sky = Sky or {}
Sky.Config = Sky.Config or Config or {}
Sky.Functions = Sky.Functions or Functions or {}

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
    local ok, result = pcall(string.format, tostring(formatStr), unpackFn(args, 1, argCount))
    formattedMsg = ok and result or tostring(formatStr)

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
end
