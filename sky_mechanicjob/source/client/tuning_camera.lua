-- =====================================================
--  sky_mechanicjob · source/client/tuning_camera.lua
--  Orbit camera for the tuning menu (Config.TuningCamera)
-- =====================================================

-- The key (default H) swings a camera around the tuned vehicle: one press turns it by
-- `step` degrees, holding it keeps turning, Shift turns the other way. While the menu has
-- the mouse the NUI page reports the key (assets/sky-tuning-camera.js); in free camera mode
-- (SPACE) a key mapping does, the mouse orbits and the mouse wheel zooms.

TuningCamera = TuningCamera or {}

local HOLD_DELAY_MS = 300
local MIN_HEIGHT, MAX_HEIGHT = -0.3, 4.0

local orbit = nil -- { cam, vehicle, angle, targetAngle, height, distance, minDistance, maxDistance }
local held = nil  -- { direction, since }

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

local function wrap(angle)
    return (angle + 180.0) % 360.0 - 180.0
end

-- Where the camera sits for an angle around the vehicle (0 = in front of it, 90 = its right).
local function orbitPosition(o)
    local rad = math.rad(o.angle)
    return GetOffsetFromEntityInWorldCoords(o.vehicle, math.sin(rad) * o.distance, math.cos(rad) * o.distance, o.height)
end

local function aim(o)
    local pos = orbitPosition(o)
    SetCamCoord(o.cam.cam, pos.x, pos.y, pos.z)
    local center = GetOffsetFromEntityInWorldCoords(o.vehicle, 0.0, 0.0, 0.2)
    PointCamAtCoord(o.cam.cam, center.x, center.y, center.z)
end

local function stop()
    if orbit and TuningState.camera == orbit.cam then
        orbit.cam:Remove()
        TuningState.camera = nil
    end
    orbit, held = nil, nil
end

-- Starts at the angle the player looks from, so the first press turns from the current view.
local function start(vehicle)
    local minDim, maxDim = GetModelDimensions(GetEntityModel(vehicle))
    local size = #(maxDim - minDim)
    local distance = tonumber(settings().distance) or math.max(4.0, size * 0.8 + 1.5)

    local camPos = GetFinalRenderedCamCoord()
    local rel = GetOffsetFromEntityGivenWorldCoords(vehicle, camPos.x, camPos.y, camPos.z)
    local angle = math.deg(math.atan(rel.x, rel.y))

    if TuningState.camera then
        pcall(function() TuningState.camera:Remove() end)
    end
    local cam = Sky.Cam.new(camPos, nil, true)
    orbit = {
        cam = cam,
        vehicle = vehicle,
        angle = angle,
        targetAngle = angle,
        height = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, tonumber(settings().height) or 1.0)),
        distance = distance,
        minDistance = math.max(2.0, size * 0.5),
        maxDistance = distance * 2.0
    }
    TuningState.camera = cam
    aim(orbit)

    CreateThread(function()
        local last = GetGameTimer()
        while orbit and orbit.cam == cam do
            local veh = TuningState.vehicle
            if not TuningState.active or TuningState.camera ~= cam or veh ~= orbit.vehicle or not DoesEntityExist(veh) then
                stop()
                break
            end

            local now = GetGameTimer()
            local dt = math.min(0.1, (now - last) / 1000.0)
            last = now

            if held and now - held.since >= HOLD_DELAY_MS then
                orbit.targetAngle = orbit.targetAngle + held.direction * (tonumber(settings().holdSpeed) or 90.0) * dt
            end

            -- Free camera mode: the mouse orbits and tilts, the wheel zooms.
            if not TuningState.nuiFocused then
                orbit.targetAngle = orbit.targetAngle + GetControlNormal(0, 1) * 6.0
                orbit.height = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, orbit.height + GetControlNormal(0, 2) * 0.12))
                if IsDisabledControlJustPressed(0, 241) or IsDisabledControlJustPressed(0, 15) then
                    orbit.distance = math.max(orbit.minDistance, orbit.distance - 0.5)
                elseif IsDisabledControlJustPressed(0, 242) or IsDisabledControlJustPressed(0, 14) then
                    orbit.distance = math.min(orbit.maxDistance, orbit.distance + 0.5)
                end
            end

            orbit.angle = orbit.angle + wrap(orbit.targetAngle - orbit.angle) * math.min(1.0, dt * 8.0)
            aim(orbit)
            Wait(0)
        end
    end)
end

-- direction: 1 (clockwise seen from above) or -1. pressed = false ends a hold.
function TuningCamera.Press(direction, pressed)
    if not TuningCamera.IsEnabled() then return false end
    if pressed == false then
        held = nil
        return true
    end
    local vehicle = TuningState.vehicle
    if not TuningState.active or not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    direction = (tonumber(direction) or 1) < 0 and -1 or 1
    if not orbit or orbit.vehicle ~= vehicle or TuningState.camera ~= orbit.cam then start(vehicle) end
    orbit.targetAngle = orbit.targetAngle + direction * (tonumber(settings().step) or 45.0)
    held = { direction = direction, since = GetGameTimer() }
    return true
end

-- Free camera mode (SPACE): the NUI page does not have the keyboard.
RegisterCommand("+sky_tuning_camera", function()
    if TuningState.active and not TuningState.nuiFocused then
        TuningCamera.Press(IsDisabledControlPressed(0, 21) and -1 or 1, true)
    end
end, false)

RegisterCommand("-sky_tuning_camera", function()
    TuningCamera.Press(1, false)
end, false)

if TuningCamera.IsEnabled() then
    RegisterKeyMapping("+sky_tuning_camera", "Tuning menu: rotate the camera around the vehicle", "keyboard", TuningCamera.Key())
end

-- The tuning menu has the keyboard: the NUI page reports the key (down and up).
RegisterNUICallback("tuning:rotateCamera", function(data, cb)
    data = type(data) == "table" and data or {}
    local ok = TuningCamera.Press(data.direction, data.pressed ~= false)
    cb({ success = ok })
end)

-- The NUI page learns the key when the tuning menu opens.
function TuningCamera.SendConfig()
    sendUi("tuningCamera:config", { enabled = TuningCamera.IsEnabled(), key = TuningCamera.Key() })
end

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then stop() end
end)
