-- Run from the workspace root: lua tests/tuning_camera_spec.lua
-- The tuning menu's free camera: one press of the key (Config.TuningCamera, default H; Shift+H
-- too) frees the game camera while the menu stays open, so the player can look around and
-- change the view (V, first person included); the next press gives the mouse back to the menu.
-- Plays it through the real tuning_camera.lua, orders.lua (focus) and wheel_change.lua (the
-- free camera's controls) with mocked natives.

local stub
stub = setmetatable({}, {
    __index = function() return stub end,
    __call = function() return stub end,
})

local MODULE_GLOBALS = {
    Config = true, Locales = true, Functions = true, Sky_Jobs = true, CustomTuning = true,
    OrderInstallState = true, WheelOrderInstallState = true, OrderTabletState = true,
    TuningCamera = true,
}

local now = 1000
local threads, commands, keyMappings, nuiCallbacks, sent = {}, {}, {}, {}, {}
local nuiFocus = { focus = false, cursor = false }
local enabledControls, disabledGroups = {}, {}

local env = setmetatable({}, { __index = function(_, key)
    local value = _G[key]
    if value ~= nil or MODULE_GLOBALS[key] then return value end
    return stub
end })
env._G = env
env.print = function() end
env.CreateThread = function(fn) threads[#threads + 1] = coroutine.create(fn) end
env.Wait = function(ms) if coroutine.isyieldable() then coroutine.yield(ms) end end
env.Citizen = { CreateThread = env.CreateThread, Wait = env.Wait }
env.GetGameTimer = function() return now end
env.GetGameBuildNumber = function() return 3258 end
env.json = { encode = function() return "[]" end, decode = function() return {} end }
env.Sky = setmetatable({ Config = { locale = "en" }, Debug = function() end }, { __index = function() return stub end })
env.exports = setmetatable({}, { __call = function() end, __index = function() return stub end })
env.RegisterCommand = function(name, fn) commands[name] = fn end
env.RegisterKeyMapping = function(command, description, mapper, key)
    keyMappings[#keyMappings + 1] = { command = command, description = description, mapper = mapper, key = key }
end
env.RegisterNUICallback = function(name, fn) nuiCallbacks[name] = fn end
env.SendNUIMessage = function(message) sent[#sent + 1] = message end
env.SetNuiFocus = function(focus, cursor) nuiFocus.focus, nuiFocus.cursor = focus, cursor end
env.SetNuiFocusKeepInput = function() end
env.DisableAllControlActions = function(group) disabledGroups[group] = true end
env.EnableControlAction = function(group, control) enabledControls[group .. ":" .. control] = true end
env.IsDisabledControlJustPressed = function() return false end

local function load(path) assert(loadfile(path, "t", env))() end
load("sky_mechanicjob/config/init.lua")
load("sky_mechanicjob/config/config.lua")
load("sky_mechanicjob/config/adv_config.lua")
load("sky_mechanicjob/config/locales/en.lua")
load("sky_mechanicjob/source/client/state.lua")
load("sky_mechanicjob/source/client/main.lua")
load("sky_mechanicjob/source/client/tuning_camera.lua")
load("sky_mechanicjob/source/client/orders.lua")
load("sky_mechanicjob/source/client/wheel_change.lua")

local TuningCamera, TuningState = env.TuningCamera, env.TuningState

-- Runs every thread for a frame (ms of game time each).
local function step(frames, ms)
    for _ = 1, frames do
        now = now + (ms or 16)
        enabledControls, disabledGroups = {}, {}
        for i = #threads, 1, -1 do
            local co = threads[i]
            if coroutine.status(co) == "dead" then
                table.remove(threads, i)
            else
                local ok, err = coroutine.resume(co)
                if not ok then table.remove(threads, i) end
            end
        end
    end
end

local function pressInMenu()
    local answer
    nuiCallbacks["tuning:toggleCamera"]({}, function(res) answer = res end)
    return answer
end

-- 1. The key is mapped (rebindable in FiveM's key bindings) and does nothing outside the menu.
assert(#keyMappings == 1 and keyMappings[1].command == "+sky_tuning_camera" and keyMappings[1].key == "H" and keyMappings[1].mapper == "keyboard",
    "the free camera key is not mapped to H")
assert(commands["-sky_tuning_camera"], "the key's release command is missing")
assert(TuningCamera.Toggle() == false, "the free camera toggled outside the tuning menu")
assert(pressInMenu().success == false, "the NUI key did something outside the tuning menu")

-- 2. The menu opens with the mouse; the NUI page learns the key.
TuningState.active, TuningState.vehicle = true, 77
env.setNuiFocusState(true)
TuningCamera.SendConfig()
local config = sent[#sent]
assert(config.action == "tuningCamera:config" and config.payload.key == "H" and config.payload.enabled == true)
now = now + 1000

-- 3. One press of H in the menu (the page has the keyboard) frees the camera; nothing has to be held.
assert(pressInMenu().success == true, "H in the menu did not free the camera")
assert(TuningState.nuiFocused == false and nuiFocus.focus == false, "the menu kept the mouse")
assert(TuningState.active == true, "freeing the camera closed the menu")
step(1)
assert(enabledControls["0:1"] and enabledControls["0:2"], "the mouse cannot look around in free camera")
assert(enabledControls["0:0"], "V (next view / first person) is off in free camera")
assert(enabledControls["0:26"] and enabledControls["0:79"], "looking behind is off in free camera")
assert(disabledGroups[0] and not enabledControls["0:71"] and not enabledControls["0:24"], "driving or shooting allowed in free camera")

-- 4. The same press reaching the game right after (the page let go of the keyboard) is ignored.
commands["+sky_tuning_camera"]()
commands["-sky_tuning_camera"]()
assert(TuningState.nuiFocused == false, "one press toggled twice")

-- 5. Later, H in free camera (the key mapping) gives the mouse back to the menu.
step(30)
commands["+sky_tuning_camera"]()
commands["-sky_tuning_camera"]()
assert(TuningState.nuiFocused == true and nuiFocus.focus == true and nuiFocus.cursor == true, "H in free camera did not go back to the menu")
step(1)
assert(not enabledControls["0:0"], "free camera controls stayed on in the menu")

-- 6. Shift+H does the same (the page reports the key with or without Shift).
now = now + 1000
assert(pressInMenu().success == true and TuningState.nuiFocused == false, "Shift+H did not free the camera")
now = now + 1000
commands["+sky_tuning_camera"]()
assert(TuningState.nuiFocused == true, "Shift+H did not go back to the menu")

-- 7. Turned off in the config: no key mapping, the page is told, presses do nothing.
env.Config.TuningCamera.enabled = false
TuningCamera.SendConfig()
assert(sent[#sent].payload.enabled == false)
now = now + 1000
assert(pressInMenu().success == false and TuningState.nuiFocused == true, "a turned-off free camera still toggled")
env.Config.TuningCamera.enabled = true

-- 8. Closing the menu in free camera leaves no free camera behind.
now = now + 1000
assert(pressInMenu().success == true and TuningState.nuiFocused == false)
TuningState.active = false
step(1)
assert(not enabledControls["0:0"] and not disabledGroups[0], "free camera controls after the menu closed")
now = now + 1000
commands["+sky_tuning_camera"]()
assert(nuiFocus.focus == false, "the key took the mouse after the menu closed")

print("PASS: tuning free camera on one press of H (Shift+H too) with the menu open, look around and V / first person, no driving or shooting, the same press never toggles twice, H again goes back to the menu, off in the config, nothing after the menu closed.")
