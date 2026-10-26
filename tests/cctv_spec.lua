-- Run from the workspace root: lua tests/cctv_spec.lua
-- The tablet CCTV app and the map's Vehicle Board on sky_jobs_base's server: fixed cameras
-- carry the string id and label the app needs, config cameras look where configured,
-- /addcctvcam stores the caller's view, and job vehicles that are out (or driven by an
-- on-duty colleague) show up as dashcams and on the Vehicle Board.

local stub
stub = setmetatable({}, { __index = function() return stub end, __call = function() return stub end })

local function vector3(x, y, z)
    return setmetatable({ x = x, y = y, z = z }, {
        __sub = function(a, b) return vector3(a.x - b.x, a.y - b.y, a.z - b.z) end,
        __len = function(v) return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z) end,
    })
end

local callbacks, commands, netEvents, clientEvents = {}, {}, {}, {}
local db = { cameras = {}, garage = {} }

-- Server id -> player. 1 and 2 are on-duty mechanics, 3 is a police officer.
local players = {
    [1] = { name = "Rezan Petrov", job = "mechanic", ped = 101, coords = vector3(0, 0, 0) },
    [2] = { name = "John Smith", job = "mechanic", ped = 102, coords = vector3(50, 0, 0) },
    [3] = { name = "Officer Doe", job = "police", ped = 103, coords = vector3(90, 0, 0) },
}
-- Entity -> vehicle in the world.
local vehicles = {
    [201] = { plate = "MECH 01 ", coords = vector3(10, 20, 30), driver = 102, engine = 850.0 }, -- driven by John
    [202] = { plate = "TOW 2", coords = vector3(5, 5, 5), driver = 0, engine = 1000.0 },        -- garage vehicle, parked
    [203] = { plate = "POL 1", coords = vector3(1, 1, 1), driver = 103, engine = 1000.0 },       -- police cruiser
    [204] = { plate = "CIVIL 9", coords = vector3(2, 2, 2), driver = 0, engine = 1000.0 },       -- someone's car
}
db.garage = { { job = "mechanic", plate = "TOW2", model = "flatbed", name = "Flatbed", state = "out" } }

local env = setmetatable({}, { __index = function(_, key)
    local value = _G[key]
    if value ~= nil or key == "Config" or key == "Locales" or key == "Sky_Jobs" then return value end
    return stub
end })
env._G = env
env.vector3 = vector3
env.print = function() end
env.CreateThread = function() end
env.SetTimeout = function() end
env.Wait = function() end
env.GetGameTimer = function() return 0 end
env.GetResourceState = function(name) return name == "oxmysql" and "started" or "missing" end
env.AddEventHandler = function() end
env.RegisterNetEvent = function(name, fn) if fn then netEvents[name] = fn end end
env.RegisterServerEvent = env.RegisterNetEvent
env.RegisterCommand = function(name, fn) commands[name] = fn end
env.TriggerEvent = function() end
env.TriggerClientEvent = function(name, target, payload) clientEvents[#clientEvents + 1] = { name = name, target = target, payload = payload } end
env.GetPlayers = function()
    local list = {}
    for src in pairs(players) do list[#list + 1] = tostring(src) end
    table.sort(list)
    return list
end
env.GetPlayerName = function(src) return players[tonumber(src)] and "steam" or nil end
env.GetPlayerPed = function(src) return players[tonumber(src)] and players[tonumber(src)].ped or 0 end
env.GetEntityCoords = function(entity)
    if vehicles[entity] then return vehicles[entity].coords end
    for _, p in pairs(players) do if p.ped == entity then return p.coords end end
    return vector3(0, 0, 0)
end
env.GetEntityHealth = function() return 200 end
env.GetVehiclePedIsIn = function() return 0 end
env.GetAllVehicles = function()
    local list = {}
    for entity in pairs(vehicles) do list[#list + 1] = entity end
    table.sort(list)
    return list
end
env.GetVehicleNumberPlateText = function(v) return vehicles[v].plate end
env.GetPedInVehicleSeat = function(v) return vehicles[v].driver end
env.GetVehicleEngineHealth = function(v) return vehicles[v].engine end
env.NetworkGetNetworkIdFromEntity = function(v) return v + 1000 end
env.IsPlayerAceAllowed = function() return false end
env.GetConvar = function(_, default) return default end
env.exports = setmetatable({}, { __call = function() end, __index = function() return stub end })
env.json = { encode = function() return "{}" end, decode = function() return {} end }
env.Sky = {
    Cb = { Register = function(name, fn) callbacks[name] = fn end },
    FW = {
        GetIdentifier = function(src) return players[src] and ("CID" .. src) end,
        GetName = function(src) return players[tonumber(src)] and players[tonumber(src)].name end,
        GetJob = function(src) return players[tonumber(src)] and players[tonumber(src)].job or "" end,
        GetJobData = function(src, key)
            if key == "grade" then return 0 end
            if key == "duty" then return true end
        end,
        GetJobUsers = function() return {} end,
        GetJobs = function() return {} end,
    },
}
env.MySQL = {
    query = { await = function(query, params)
        if query:find("FROM sky_jobs_cctv_cameras", 1, true) then
            local rows = {}
            for _, cam in ipairs(db.cameras) do
                if cam.job_key == nil or cam.job_key == params["@job_key"] then rows[#rows + 1] = cam end
            end
            return rows
        end
        if query:find("FROM sky_jobs_garage_vehicles WHERE state = 'out'", 1, true) then return db.garage end
        return {}
    end },
    single = { await = function() return nil end },
    insert = { await = function(query, params)
        if query:find("INSERT INTO sky_jobs_cctv_cameras", 1, true) then
            local cam = { id = #db.cameras + 1 }
            for key, value in pairs(params) do cam[key:sub(2)] = value end
            db.cameras[#db.cameras + 1] = cam
            return cam.id
        end
        return 1
    end },
    update = { await = function() return 1 end },
}

local function load(path) assert(loadfile(path, "t", env))() end
env.Sky_Jobs = {}
load("sky_jobs_base/config/init.lua")
load("sky_jobs_base/config/config.lua")
load("sky_jobs_base/source/server/jobs.lua")
load("sky_jobs_base/source/server/garage.lua")
load("sky_jobs_base/source/server/shop.lua")
env.Sky_Jobs.HasPermission = function(src) return src == 1 end

local function byId(list)
    local map = {}
    for _, entry in ipairs(list) do map[entry.id] = entry end
    return map
end

-- 1. /addcctvcam stores the caller's current view (the client answers with its camera pose).
commands.addcctvcam(1, { "cctv", "@all", "Workshop", "Gate" })
assert(clientEvents[#clientEvents].name == "sky_jobs_base:cctv:capturePose" and clientEvents[#clientEvents].target == 1)
env.source = 1
netEvents["sky_jobs_base:cctv:addCamera"]({ coords = { x = 1.0, y = 2.0, z = 3.5 }, heading = 270.0, pitch = -15.0 })
env.source = nil
local stored = db.cameras[1]
assert(stored and stored.name == "Workshop Gate" and stored.type == "cctv" and stored.job_key == nil, "camera not stored")
assert(stored.x == 1.0 and stored.z == 3.5 and stored.heading == 270.0 and stored.pitch == -15.0)
-- Without a pending command (or permission) the event stores nothing.
env.source = 2
netEvents["sky_jobs_base:cctv:addCamera"]({ coords = { x = 50.0, y = 0.0, z = 0.0 }, heading = 0.0 })
env.source = nil
assert(#db.cameras == 1, "a camera was added without the command")
-- A pose far from the caller is refused.
commands.addcctvcam(1, { "Far" })
env.source = 1
netEvents["sky_jobs_base:cctv:addCamera"]({ coords = { x = 500.0, y = 0.0, z = 0.0 }, heading = 0.0 })
env.source = nil
assert(#db.cameras == 1, "a camera far away from the caller was added")
-- Defaults: the caller's job and the type's name.
commands.addcctvcam(1, { "speedcam" })
env.source = 1
netEvents["sky_jobs_base:cctv:addCamera"]({ coords = { x = 1.0, y = 0.0, z = 0.0 }, heading = 10.0, pitch = 0.0 })
env.source = nil
assert(db.cameras[2].type == "speedcam" and db.cameras[2].name == "speedcam camera" and db.cameras[2].job_key == "mechanic")

-- 2. The CCTV list: fixed cameras with a string id and a label, config cameras, bodycams, dashcams.
env.Config.Cctv.requireBodycamItem = false
env.Config.Cctv.cameras = {
    { name = "Lot", type = "cctv", coords = vector3(7.0, 8.0, 9.0), heading = 90.0, pitch = -20.0 },
    { name = "Station", job = "police", coords = vector3(0.0, 0.0, 0.0) },
}
local res = callbacks["sky_jobs_base:cctv:getCameras"](1)
assert(res.success, tostring(res.error))
local cams = byId(res.data.cameras)
assert(cams["1"] and cams["1"].label == "Workshop Gate" and cams["1"].target == 1 and cams["1"].type == "cctv", "database camera")
assert(cams["2"] and cams["2"].type == "speedcam")
assert(cams["CFG-1"] and cams["CFG-1"].label == "Lot" and cams["CFG-1"].target == -1, "config camera")
assert(cams["CFG-1"].heading == 270.0 and cams["CFG-1"].pitch == -20.0, "config cameras look where configured")
assert(not cams["CFG-2"], "another job's config camera listed")
for _, cam in ipairs(res.data.cameras) do
    assert(type(cam.id) == "string" and type(cam.label) == "string", "the app searches id and label as text")
end
assert(cams["BC-2"] and not cams["BC-1"] and not cams["BC-3"], "bodycams: on-duty colleagues only")
-- Dashcams: John's van and the parked garage flatbed, not the police car or a civilian car.
assert(cams["DC-MECH01"] and cams["DC-MECH01"].target == "MECH01" and cams["DC-MECH01"].location == "John Smith")
assert(cams["DC-MECH01"].durability == 85 and cams["DC-MECH01"].type == "dashcam")
assert(cams["DC-TOW2"] and cams["DC-TOW2"].label == "Flatbed (TOW2)", "garage vehicle dashcam")
assert(not cams["DC-POL1"] and not cams["DC-CIVIL9"], "other jobs' or civilian vehicles listed")

-- 3. The map's Vehicle Board lists the same vehicles; Open CCTV asks for DC-<plate>.
res = callbacks["sky_jobs_base:map:getOfficers"](1)
assert(res.success)
local board = byId(res.data.vehicles)
assert(board.MECH01 and board.MECH01.plate == "MECH01" and board.MECH01.status == "active" and board.MECH01.driver == "John Smith")
assert(board.MECH01.netId == 1201 and board.MECH01.coords.x == 10 and board.MECH01.isPoliceVehicle == true)
assert(board.TOW2 and board.TOW2.status == "offline" and board.TOW2.label == "Flatbed")
assert(not board.POL1 and not board.CIVIL9)

print("PASS: /addcctvcam stores the caller's view (with job scope, never without the command or far away), CCTV cameras with string ids and labels, config cameras, bodycams of on-duty colleagues, dashcams and the map's Vehicle Board of the job's vehicles.")
