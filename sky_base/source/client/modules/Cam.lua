if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/modules/Cam.lua") end
-- =====================================================
--  sky_base · source/client/modules/Cam.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Cam = {}
Sky.Cam.__index = Sky.Cam

--- Creates a new scripted camera.
---@param coords? vector3
---@param rotation? table|vector3
---@param transition? boolean
---@return table
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

--- Removes and destroys the camera.
function Sky.Cam:Remove()
    if not self.cam then return end
    SetCamActive(self.cam, false)
    RenderScriptCams(false, self.transition, 500, true, true)
    DestroyCam(self.cam, false)
    self.cam = nil
end

--- Points camera at an entity with optional offset distance.
---@param entity number
---@param distance? number
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
