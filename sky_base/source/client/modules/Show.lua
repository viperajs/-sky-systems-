if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/modules/Show.lua") end
-- =====================================================
--  sky_base · source/client/modules/Show.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Show = {}

local sounds = {
    beep = { name = "MP_IDLE_KICK", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
    addCart = { name = "SELECT", set = "HUD_FRONTEND_CLOTHESSHOP_SOUNDSET" },
    remove = { name = "BACK", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
    purchase = { name = "NAV_LEFT_RIGHT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
    error = { name = "ERROR", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
    success = { name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
    warning = { name = "NAV_LEFT_RIGHT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
    info = { name = "NAV_LEFT_RIGHT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
    notification = { name = "NAV_LEFT_RIGHT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
    money = { name = "LOCAL_PLYR_CASH_COUNTER_COMPLETE", set = "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS" }
}

local enableHelpNotifications = true
local toggleStates = {}

--- Triggers a HUD or notification.
---@param title string
---@param text string
---@param notifyType string
---@param duration number
function Sky.Show.Notification(title, text, notifyType, duration)
    if GetResourceState("sky_hud") == "started" then
        exports.sky_hud:notify(title, text, notifyType, duration)
    elseif GetResourceState("zenit_hud") == "started" then
        exports.zenit_hud:showNotify(title, text, notifyType, duration)
    elseif GetResourceState("sky_notify") == "started" then
        exports.sky_notify:show(title, text, notifyType, duration)
    elseif Functions and Functions.ShowNotification then
        Functions.ShowNotification(title, text, notifyType, duration)
    end
end

--- Enables or disables help notifications.
---@param enabled boolean
function Sky.Show.showHelpNotification(enabled)
    enableHelpNotifications = enabled
end

--- Triggers a help/interaction notification.
---@param text string
---@param b? any
function Sky.Show.HelpNotification(text, b)
    if not enableHelpNotifications then return end

    if GetResourceState("sky_hud") == "started" then
        exports.sky_hud:pressE(text, b)
    elseif GetResourceState("zenit_hud") == "started" then
        exports.zenit_hud:showInteractionThisFrame(b, text)
    elseif Functions and Functions.ShowHelpNotification then
        Functions.ShowHelpNotification(text, b)
    end
end

--- Creates a map blip.
---@param coords vector3
---@param sprite number
---@param color number
---@param title string
---@param display? number
---@param scale? number
---@return number
function Sky.Show.Blip(coords, sprite, color, title, display, scale)
    local pos = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
    local blip = AddBlipForCoord(pos)

    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, display or 4)
    SetBlipScale(blip, scale or (Sky.Config and Sky.Config.defaultBlipSize) or 0.8)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(title)
    EndTextCommandSetBlipName(blip)

    return blip
end

--- Draws a marker in 3D world space for one frame.
---@param coords vector3
---@param options? table
function Sky.Show.Marker(coords, options)
    options = options or {}
    local pos = vector3(coords.x, coords.y, coords.z)

    if type(options.offset) == "number" then
        pos = vector3(pos.x, pos.y, pos.z + options.offset)
    elseif type(options.offset) == "table" or type(options.offset) == "vector3" then
        pos = pos + vector3(options.offset.x or 0, options.offset.y or 0, options.offset.z or 0)
    end

    local markerType = tonumber(options.type) or 1
    local scaleX = tonumber(options.scaleX or options.markerSize or options.size or options.scale) or 1.0
    local scaleY = tonumber(options.scaleY or options.markerSize or options.size or options.scale) or 1.0
    local scaleZ = tonumber(options.scaleZ) or 0.5
    local alpha = tonumber(options.alpha) or 100

    if scaleX <= 0.0 then scaleX = 1.0 end
    if scaleY <= 0.0 then scaleY = 1.0 end
    if scaleZ <= 0.0 then scaleZ = 0.5 end
    if alpha <= 0 then alpha = 100 end

    local defaultRed = (Sky.Config and Sky.Config.defaultMarkerColor and Sky.Config.defaultMarkerColor.red) or 255
    local defaultGreen = (Sky.Config and Sky.Config.defaultMarkerColor and Sky.Config.defaultMarkerColor.green) or 255
    local defaultBlue = (Sky.Config and Sky.Config.defaultMarkerColor and Sky.Config.defaultMarkerColor.blue) or 255

    DrawMarker(
        markerType,
        pos.x, pos.y, pos.z,
        options.dirX or 0.0, options.dirY or 0.0, options.dirZ or 0.0,
        options.rotX or 0.0, options.rotY or 0.0, options.rotZ or 0.0,
        scaleX, scaleY, scaleZ,
        options.red or defaultRed,
        options.green or defaultGreen,
        options.blue or defaultBlue,
        alpha,
        options.bobUpAndDown or false,
        options.faceCamera or false,
        options.p19 or 2,
        options.rotate or false,
        options.textureDict or false,
        options.textureName or false,
        options.drawOnEnts or false
    )
end

--- Shows mission text at the bottom of the screen.
---@param text string
---@param duration number
function Sky.Show.MissionText(text, duration)
    ClearPrints()
    BeginTextCommandPrint("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandPrint(duration, true)
end

--- Plays a frontend sound effect by preset key.
---@param soundKey string
function Sky.Show.PlaySound(soundKey)
    local snd = sounds[soundKey]
    if snd then
        PlaySoundFrontend(-1, snd.name, snd.set, true)
    end
end

--- Draws 3D text at world coordinates.
---@param coords vector3
---@param text string
function Sky.Show.Draw3DText(coords, text)
    local onScreen, screenX, screenY = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(screenX, screenY)
    end
end

--- Registers a frame-refreshed toggle component.
---@param key string
---@param data table
function Sky.Show.RegisterToggle(key, data)
    if not toggleStates[key] then
        toggleStates[key] = { lastCallFrame = 0 }
    end

    local state = toggleStates[key]
    state.data = data
    local now = GetGameTimer()
    state.data:show()
    state.lastCallFrame = now

    CreateThread(function()
        Wait(100)
        if GetGameTimer() - state.lastCallFrame > 100 then
            state.data:hide()
        end
    end)
end
