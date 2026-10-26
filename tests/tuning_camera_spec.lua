-- Run from the workspace root: lua tests/tuning_camera_spec.lua
-- The tuning menu's orbit camera: the key (Config.TuningCamera, default H) swings a camera
-- around the tuned vehicle by `step` degrees per press (Shift the other way), keeps turning
-- while held, and the camera goes away with the menu.

local function vector3(x, y, z)
    return setmetatable({ x = x, y = y, z = z }, {
        __sub = function(a, b) return vector3(a.x - b.x, a.y - b.y, a.z - b.z) end,
        __len = function(v) return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z) end,
    })
end

local now = 1000
local threads, commands, keyMappings, nuiCallbacks, sent = {}, {}, {}, {}, {}
local camCoord, camTarget, camsCreated, camsRemoved = nil, nil, 0, 0
local nuiFocused, mouse, justPressed = true, { [1] = 0.0, [2] = 0.0 }, {}

-- The tuned car sits at the origin facing north (+Y); entity offsets are world offsets.
local VEHICLE = 77

local env = setmetatable({}, { __index = _G })
env._G = env
env.Config = { TuningCamera = { enabled = true, key = "H", step = 45.0, holdSpeed = 90.0, height = 1.0 } }
env.TuningState = { active = false, vehicle = 0, camera = nil, nuiFocused = true }
env.CreateThread = function(fn) threads[#threads + 1] = coroutine.create(fn) end
env.Wait = function() coroutine.yield() end
env.GetGameTimer = function() return now end
env.DoesEntityExist = function(entity) return entity == VEHICLE end
env.GetEntityModel = function() return 1 end
env.GetModelDimensions = function() return vector3(-1.0, -2.5, -0.6), vector3(1.0, 2.5, 0.8) end
env.GetFinalRenderedCamCoord = function() return vector3(0.0, -6.0, 1.5) end -- behind the car
env.GetOffsetFromEntityGivenWorldCoords = function(_, x, y, z) return vector3(x, y, z) end
env.GetOffsetFromEntityInWorldCoords = function(_, x, y, z) return vector3(x, y, z) end
env.SetCamCoord = function(_, x, y, z) camCoord = vector3(x, y, z) end
env.PointCamAtCoord = function(_, x, y, z) camTarget = vector3(x, y, z) end
env.GetControlNormal = function(_, control) return nuiFocused and 0.0 or mouse[control] or 0.0 end
env.IsDisabledControlJustPressed = function(_, control) return justPressed[control] == true end
env.IsDisabledControlPressed = function(_, control) return control == 21 and env.shiftHeld == true end
env.RegisterCommand = function(name, fn) commands[name] = fn end
env.RegisterKeyMapping = function(command, description, mapper, key) keyMappings[#keyMappings + 1] = { command = command, mapper = mapper, key = key } end
env.RegisterNUICallback = function(name, fn) nuiCallbacks[name] = fn end
env.AddEventHandler = function() end
env.GetCurrentResourceName = function() return "sky_mechanicjob" end
env.sendUi = function(action, payload) sent[#sent + 1] = { action = action, payload = payload } end
env.Sky = { Cam = {} }
env.Sky.Cam.new = function()
    camsCreated = camsCreated + 1
    return { cam = 900 + camsCreated, Remove = function() camsRemoved = camsRemoved + 1 end }
end

assert(loadfile("sky_mechanicjob/source/client/tuning_camera.lua", "t", env))()
local TuningCamera = env.TuningCamera

local function step(frames, ms)
    for _ = 1, frames do
        now = now + (ms or 16)
        for i = #threads, 1, -1 do
            if coroutine.status(threads[i]) == "dead" then
                table.remove(threads, i)
            else
                assert(coroutine.resume(threads[i]))
            end
        end
    end
end

-- Angle of the camera around the car: 0 in front, 90 on its right, +-180 behind.
local function camAngle() return math.deg(math.atan(camCoord.x, camCoord.y)) end
-- Turn from one angle to another, in -180..180.
local function turn(from, to) return (to - from + 540.0) % 360.0 - 180.0 end

-- 1. The key is mapped (rebindable in FiveM's key bindings) and nothing happens outside the menu.
assert(#keyMappings == 1 and keyMappings[1].command == "+sky_tuning_camera" and keyMappings[1].key == "H" and keyMappings[1].mapper == "keyboard")
assert(TuningCamera.Press(1, true) == false and camsCreated == 0, "a camera outside the tuning menu")

-- 2. In the menu, the NUI page reports H: the camera starts at the current view (behind the
--    car) and swings 45 degrees.
env.TuningState.active, env.TuningState.vehicle = true, VEHICLE
TuningCamera.SendConfig()
assert(sent[1].action == "tuningCamera:config" and sent[1].payload.key == "H" and sent[1].payload.enabled == true)
local answer
nuiCallbacks["tuning:rotateCamera"]({ pressed = true, direction = 1 }, function(res) answer = res end)
assert(answer.success == true and camsCreated == 1 and env.TuningState.camera ~= nil)
nuiCallbacks["tuning:rotateCamera"]({ pressed = false }, function() end)
step(60)
assert(math.abs(math.abs(camAngle()) - 135.0) < 1.0, "first press did not turn 45 degrees from behind: " .. camAngle())
assert(math.abs(#camCoord - math.sqrt(36.0 + 1.0)) > 0, "camera not placed")
assert(camTarget.x == 0.0 and camTarget.y == 0.0, "camera does not look at the car")
local distance = math.sqrt(camCoord.x ^ 2 + camCoord.y ^ 2)

-- 3. Shift+H turns back the other way; the same camera is reused.
nuiCallbacks["tuning:rotateCamera"]({ pressed = true, direction = -1 }, function() end)
nuiCallbacks["tuning:rotateCamera"]({ pressed = false }, function() end)
step(60)
assert(math.abs(math.abs(camAngle()) - 180.0) < 1.0 and camsCreated == 1, "Shift+H did not turn back")

-- 4. Holding the key keeps turning (90 degrees a second after a short delay).
nuiCallbacks["tuning:rotateCamera"]({ pressed = true, direction = 1 }, function() end)
step(100, 10) -- one second held
nuiCallbacks["tuning:rotateCamera"]({ pressed = false }, function() end)
step(80)
local turned = (camAngle() + 180.0) % 360.0
assert(turned > 45.0 + 50.0 and turned < 45.0 + 80.0, "holding did not keep turning: " .. turned)

-- 5. Free camera mode (SPACE): the key mapping turns it, the mouse orbits, the wheel zooms.
nuiFocused, env.TuningState.nuiFocused = false, false
local before = camAngle()
commands["+sky_tuning_camera"]()
commands["-sky_tuning_camera"]()
step(60)
assert(math.abs(turn(before, camAngle()) - 45.0) < 1.5, "the key mapping did not turn the camera")
before = camAngle()
mouse[1] = 1.0
step(10)
mouse[1] = 0.0
step(60)
assert(turn(before, camAngle()) > 30.0, "the mouse does not orbit in free camera mode")
justPressed[241] = true
step(1)
justPressed[241] = nil
step(5)
assert(math.sqrt(camCoord.x ^ 2 + camCoord.y ^ 2) < distance - 0.4, "the mouse wheel does not zoom")

-- 6. Closing the menu removes the camera.
env.TuningState.active = false
step(2)
assert(camsRemoved == 1 and env.TuningState.camera == nil and #threads == 0, "camera left after the menu closed")

print("PASS: tuning camera key mapped to H, turns 45 degrees per press from the current view, Shift turns back, holding keeps turning, free camera mouse orbit and wheel zoom, removed with the menu.")
