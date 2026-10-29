-- =====================================================
--  sky_mechanicjob · source/client/tuning_camera.lua
--  Free camera toggle for the tuning menu (Config.TuningCamera)
-- =====================================================

-- One press of the key (default H; Shift+H does the same) hands the game camera back to the
-- player while the tuning menu stays open: the mouse looks around and V changes the view,
-- first person included (wheel_change.lua keeps driving and shooting off meanwhile). The next
-- press gives the mouse back to the menu. While the menu has the keyboard the NUI page reports
-- the key (assets/sky-tuning-camera.js); in free camera a key mapping does.

TuningCamera = TuningCamera or {}

local function settings()
    return type(Config.TuningCamera) == "table" and Config.TuningCamera or {}
end

function TuningCamera.IsEnabled()
    return settings().enabled ~= false
end

function TuningCamera.Key()
    local key = settings().key
    return type(key) == "string" and key ~= "" and key:upper() or "H"
end

-- Switches between the menu and the free camera. Refused right after a switch: the press that
-- released the menu's keyboard reaches the game as well.
function TuningCamera.Toggle()
    if not TuningCamera.IsEnabled() or not TuningState.active or not canToggleTuningFocus() then
        return false
    end
    setNuiFocusState(not TuningState.nuiFocused)
    return true
end

-- Free camera: the NUI page does not have the keyboard. The release does nothing (the +/- pair
-- keeps the binding players already made for this key).
RegisterCommand("+sky_tuning_camera", function()
    if TuningState.active and not TuningState.nuiFocused then
        TuningCamera.Toggle()
    end
end, false)

RegisterCommand("-sky_tuning_camera", function() end, false)

if TuningCamera.IsEnabled() then
    RegisterKeyMapping("+sky_tuning_camera", "Tuning menu: free camera on/off", "keyboard", TuningCamera.Key())
end

-- The tuning menu has the keyboard: the NUI page reports the key.
RegisterNUICallback("tuning:toggleCamera", function(data, cb)
    cb({ success = TuningState.nuiFocused == true and TuningCamera.Toggle() })
end)

-- The NUI page learns the key when the tuning menu opens.
function TuningCamera.SendConfig()
    sendUi("tuningCamera:config", { enabled = TuningCamera.IsEnabled(), key = TuningCamera.Key() })
end
