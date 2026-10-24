-- Run from the workspace root: lua tests/lift_spec.lua
-- Two mechanics' clients and the server run sky_mechanicjob's real client/lift.lua and
-- server/lift.lua against a small physics world: a car on a workshop lift is raised and
-- lowered by one mechanic, taken over by another, and deleted while raised.

local SRC = "sky_mechanicjob"

local V = {}
V.__index = V
local function vec(x, y, z) return setmetatable({ x = x or 0.0, y = y or 0.0, z = z or 0.0 }, V) end
V.__sub = function(a, b) return vec(a.x - b.x, a.y - b.y, (a.z or 0) - (b.z or 0)) end
V.__add = function(a, b) return vec(a.x + b.x, a.y + b.y, (a.z or 0) + (b.z or 0)) end
V.__len = function(a) return math.sqrt(a.x * a.x + a.y * a.y + (a.z or 0) * (a.z or 0)) end
local function vec2(x, y) return vec(x, y, 0) end

local FLOOR = 30.0
local LIFT = vec(100.0, 200.0, FLOOR)
local REST = 0.5 -- the car's centre above the floor when it stands on it

-- One world: the car, both clients, the server relay with 30 ms latency, 16 ms frames.
-- opts.mapLift: lift props of the map (an MLO) at these coordinates; opts.configure(Config) runs
-- on each client's config before the lift starts; opts.pedPos1: where client 1 stands.
local function newWorld(opts)
    opts = opts or {}
    local W = { now = 0, entities = {}, clients = {}, relayed = {}, pendingServer = {}, serverTimers = {} }
    local entities = W.entities

    function W.addVehicle(handle, x, y, z)
        entities[handle] = { kind = "veh", model = 777, x = x, y = y, z = z, vz = 0.0, frozen = false, exists = true }
        W.vehicle = handle
    end
    W.addVehicle(100, LIFT.x + 0.2, LIFT.y, FLOOR + REST)

    local function posOf(h)
        local e = entities[h]
        if not e then return vec(0, 0, 0) end
        if e.attachedTo and entities[e.attachedTo] and entities[e.attachedTo].exists then
            local p = posOf(e.attachedTo)
            return vec(p.x + e.off.x, p.y + e.off.y, p.z + e.off.z)
        end
        return vec(e.x, e.y, e.z)
    end
    W.posOf = posOf

    -- An unfrozen car falls to the floor; below the floor there is nothing to stop it.
    local function physicsStep(dt)
        for _, e in pairs(entities) do
            if e.kind == "veh" and e.exists and not e.frozen then
                local ground = FLOOR + REST
                if e.z > ground + 0.001 then
                    e.vz = e.vz - 9.81 * dt
                    e.z = math.max(ground, e.z + e.vz * dt)
                    if e.z <= ground then e.vz = 0.0 end
                elseif e.z < ground - 0.3 then
                    e.vz = e.vz - 9.81 * dt
                    e.z = e.z + e.vz * dt
                end
            end
        end
    end

    -- ── server ──
    local serverHandler
    local senv = setmetatable({}, { __index = _G })
    senv.GetGameTimer = function() return W.now end
    senv.SetTimeout = function(ms, fn) W.serverTimers[#W.serverTimers + 1] = { at = W.now + ms, fn = fn } end
    senv.GetPlayerName = function() return "player" end
    senv.Functions = { IsMechanic = function() return true end, GetVehicleByNetId = function() return W.vehicle end }
    senv.TriggerClientEvent = function(name, _, data)
        W.relayed[#W.relayed + 1] = data.action
        for _, c in ipairs(W.clients) do c.deliver(name, data) end
    end
    senv.RegisterNetEvent = function(name, fn) if name == "sky_mechanicjob:lift:syncAttachment" then serverHandler = fn end end
    senv.AddEventHandler = function() end
    assert(loadfile(SRC .. "/source/server/lift.lua", "t", senv))()

    -- ── clients ──
    local function newClient(id, objBase, pedPos)
        local c = { id = id, threads = {}, nui = {}, events = {}, objects = {}, reports = {} }
        local env = setmetatable({}, { __index = _G })
        local nextObj = objBase
        env.vector2 = vec2
        env.vector3 = vec
        env.GetGameTimer = function() return W.now end
        env.CreateThread = function(fn) c.threads[#c.threads + 1] = { co = coroutine.create(fn), wake = W.now } end
        env.Wait = function(ms) coroutine.yield(ms or 0) end
        env.print = function() end
        env.Sky = {
            Debug = function() end,
            IsDebugActive = function() return false end,
            Load = { Model = function() end },
            Config = { locale = "en" },
            Cb = { Trigger = function(name)
                if name == "sky_jobs_base:creator:getData" then
                    return { success = true, data = { entries = { { id = 1, jobKey = "mechanic", points = {
                        { type = "lift", uid = "a", x = LIFT.x, y = LIFT.y, z = LIFT.z, heading = 0.0 } },
                        locationSettings = { a = { requiresOnDuty = false } } } } } }
                end
            end },
        }
        env.Sky_Jobs = { Access = { GetJobKey = function() return "mechanic" end, IsOnDuty = function() return true end } }
        env.GetActiveJobKey = function() return "mechanic" end
        env.GetMechanicJobNames = function() return { "mechanic" } end
        env.notify = function() end
        env.tuningLocales = {}
        env.nuiLocales = {}
        env.OrderInstallState = { active = false }
        env.requestVehicleControl = function() return true end
        env.getClosestVehicleWithPoliceFallback = function() return W.vehicle end
        env.handleOilChangeLiftMotionComplete = function(_, raised, lowered)
            c.reports[#c.reports + 1] = { raised = raised, lowered = lowered }
        end
        env.GetHashKey = function(s) return #tostring(s) * 7919 + tostring(s):byte(-1) end
        env.IsModelValid = function() return true end
        env.CreateObject = function(model, x, y, z)
            nextObj = nextObj + 1
            entities[nextObj] = { kind = "obj", owner = id, model = model, x = x, y = y, z = z, exists = true, frozen = false }
            c.objects[nextObj] = true
            return nextObj
        end
        env.DoesEntityExist = function(h) return h ~= nil and h ~= 0 and entities[h] ~= nil and entities[h].exists end
        env.DeleteEntity = function(h) if entities[h] then entities[h].exists = false end end
        env.SetEntityAsMissionEntity = function() end
        env.SetModelAsNoLongerNeeded = function() end
        env.SetEntityHeading = function() end
        env.GetEntityHeading = function() return 0.0 end
        env.GetEntityAlpha = function() return 255 end
        env.SetEntityCollision = function() end
        env.FreezeEntityPosition = function(h, f) if entities[h] then entities[h].frozen = f end end
        env.SetEntityCoordsNoOffset = function(h, x, y, z)
            local e = entities[h]
            if not e or e.attachedTo then return end -- attached entities ignore it
            e.x, e.y, e.z = x, y, z
            if e.kind == "veh" then e.vz = 0.0 end
        end
        env.GetEntityRotation = function() return vec(0, 0, 0) end
        env.GetOffsetFromEntityGivenWorldCoords = function(veh, x, y, z)
            local p = posOf(veh)
            return vec(x - p.x, y - p.y, z - p.z)
        end
        env.AttachEntityToEntity = function(child, parent, _, ox, oy, oz)
            entities[child].attachedTo, entities[child].off = parent, vec(ox, oy, oz)
        end
        -- GTA leaves a detached child where it is.
        env.DetachEntity = function(h)
            local e = entities[h]
            if e and e.attachedTo then
                local p = posOf(h)
                e.attachedTo, e.off = nil, nil
                e.x, e.y, e.z = p.x, p.y, p.z
            end
        end
        env.IsEntityAttached = function(h) local e = entities[h]; return e ~= nil and e.attachedTo ~= nil and entities[e.attachedTo].exists end
        env.IsEntityAttachedToEntity = function(a, b) local e = entities[a]; return e ~= nil and e.attachedTo == b end
        env.IsEntityDead = function() return false end
        env.GetEntityModel = function(h) return entities[h] and entities[h].model or 0 end
        env.GetGamePool = function(pool)
            local out = {}
            for h, e in pairs(entities) do
                if e.exists then
                    if pool == "CVehicle" and e.kind == "veh" then out[#out + 1] = h end
                    if pool == "CObject" and e.kind == "obj" and (e.owner == id or e.owner == "map") then out[#out + 1] = h end
                end
            end
            table.sort(out)
            return out
        end
        env.GetClosestObjectOfType = function() return 0 end
        env.SetVehicleOnGroundProperly = function(h) local e = entities[h]; if e then e.z = FLOOR + REST; e.vz = 0 end end
        env.GetEntityHeightAboveGround = function(h) return posOf(h).z - FLOOR end
        env.IsEntityWaitingForWorldCollision = function() return false end
        env.VehToNet = function(h) return h end
        env.NetToVeh = function(n) return n end
        env.PlayerPedId = function() return 1 end
        env.PlayerId = function() return 0 end
        env.GetPlayerServerId = function() return id end
        env.GetVehiclePedIsIn = function() return 0 end
        env.GetEntityCoords = function(h) if h == 1 then return pedPos end return posOf(h) end
        env.SetNuiFocus = function() end
        env.SendNUIMessage = function() end
        env.GetCurrentResourceName = function() return "sky_mechanicjob" end
        env.RegisterNUICallback = function(name, fn) c.nui[name] = fn end
        env.RegisterNetEvent = function(name, fn) if fn then c.events[name] = fn end end
        env.AddEventHandler = function(name, fn) c.events[name] = c.events[name] or fn end
        env.TriggerServerEvent = function(_, data)
            W.pendingServer[#W.pendingServer + 1] = { at = W.now + 30, src = id, data = data }
        end
        env.TriggerEvent = function() end
        c.env = env
        for _, f in ipairs({ "config/init.lua", "config/config.lua", "config/adv_config.lua", "source/client/lift.lua" }) do
            assert(loadfile(SRC .. "/" .. f, "t", env))()
            if f == "config/adv_config.lua" and opts.configure then opts.configure(env.Config) end
        end
        c.deliver = function(name, data)
            local fn = c.events[name]
            if fn then c.threads[#c.threads + 1] = { co = coroutine.create(function() fn(data) end), wake = W.now } end
        end
        c.nuiCall = function(name, data)
            c.threads[#c.threads + 1] = { co = coroutine.create(function() c.nui[name](data, function() end) end), wake = W.now }
        end
        c.call = function(fn) c.threads[#c.threads + 1] = { co = coroutine.create(fn), wake = W.now } end
        return c
    end

    local function step()
        for _, c in ipairs(W.clients) do
            local i = 1
            while i <= #c.threads do
                local t = c.threads[i]
                if coroutine.status(t.co) == "dead" then
                    table.remove(c.threads, i)
                else
                    if t.wake <= W.now then
                        local ok, ms = coroutine.resume(t.co)
                        if not ok then error(("client %s thread error: %s"):format(c.id, tostring(ms))) end
                        t.wake = W.now + (tonumber(ms) or 0)
                    end
                    i = i + 1
                end
            end
        end
        local keep = {}
        for _, m in ipairs(W.pendingServer) do
            if m.at <= W.now then
                senv.source = m.src
                serverHandler(m.data)
            else
                keep[#keep + 1] = m
            end
        end
        W.pendingServer = keep
        local timers = {}
        for _, tm in ipairs(W.serverTimers) do
            if tm.at <= W.now then tm.fn() else timers[#timers + 1] = tm end
        end
        W.serverTimers = timers
        physicsStep(0.016)
        W.now = W.now + 16
    end
    function W.run(ms) local target = W.now + ms; while W.now < target do step() end end

    if opts.mapLift then
        local hash = function(s) return #tostring(s) * 7919 + tostring(s):byte(-1) end
        local m = opts.mapLift
        entities[900] = { kind = "obj", owner = "map", model = hash("sky_carlift_platform"), x = m.x, y = m.y, z = m.z, exists = true, frozen = true }
        entities[901] = { kind = "obj", owner = "map", model = hash("sky_carlift_frame"), x = m.x + 0.1, y = m.y, z = m.z, exists = true, frozen = true }
    end
    W.clients[1] = newClient(1, 1000, opts.pedPos1 or vec(LIFT.x + 2.0, LIFT.y, FLOOR + 1.0))
    W.clients[2] = newClient(2, 2000, vec(LIFT.x - 2.0, LIFT.y, FLOOR + 1.0))
    W.run(1500) -- workshop data, lift props

    function W.carHeight() return posOf(W.vehicle).z - (FLOOR + REST) end
    function W.carFrozen() return entities[W.vehicle].frozen end
    -- The moving platform (the carriage) as one client sees it: its height and whether it rides on the car.
    function W.platform(c)
        for h in pairs(c.objects) do
            local e = entities[h]
            if e.exists and e.model == c.env.GetHashKey("sky_carlift_frame") then return posOf(h).z - FLOOR, e.attachedTo ~= nil end
        end
    end
    function W.openUi(c) c.call(function() c.env.openNearestLiftControlUi() end); W.run(100) end
    function W.closeUi(c) c.nuiCall("liftControl:close", {}); W.run(300) end
    function W.hold(c, dir, ms)
        c.nuiCall("liftControl:setDirection", { direction = dir })
        W.run(ms)
        c.nuiCall("liftControl:setDirection", { direction = 0 })
        W.run(400)
    end
    -- Both clients see the platform at the car's height, riding on it.
    function W.assertPlatformsOnCar(label)
        for _, c in ipairs(W.clients) do
            local height, attached = W.platform(c)
            assert(attached and math.abs(height - W.carHeight()) < 0.05,
                ("%s: client %d platform at %.3f (attached=%s), car at %.3f"):format(label, c.id, height or -1, tostring(attached), W.carHeight()))
        end
    end
    function W.assertAtFloor(label)
        assert(math.abs(W.carHeight()) < 0.01 and not W.carFrozen(), ("%s: car at %.3f frozen=%s"):format(label, W.carHeight(), tostring(W.carFrozen())))
        for _, c in ipairs(W.clients) do
            local height, attached = W.platform(c)
            assert(not attached and math.abs(height) < 0.01, ("%s: client %d platform at %.3f"):format(label, c.id, height))
        end
    end
    return W
end

-- 1. One mechanic raises the car to the top and lowers it again; the other player sees the
--    platform under the car the whole time, and the install steps hear both stops.
do
    local W = newWorld()
    local A = W.clients[1]
    W.openUi(A)
    W.hold(A, 1, 6000)
    assert(math.abs(W.carHeight() - 2.0) < 0.01 and W.carFrozen(), "raised to the top")
    W.assertPlatformsOnCar("raised")
    W.hold(A, -1, 6000)
    W.assertAtFloor("lowered")
    local first, last = A.reports[1], A.reports[#A.reports]
    assert(first.raised and last.lowered, "the install steps heard the raised and the lowered stop")
end

-- 2. A second mechanic takes over a raised car: Down used to drop it 2 m at once (their lift
--    height was still the floor), Up lifted it twice as high, and the first mechanic later
--    lowered it through the floor.
do
    local W = newWorld()
    local A, B = W.clients[1], W.clients[2]
    W.openUi(A)
    W.hold(A, 1, 6000)
    W.closeUi(A)

    W.openUi(B)
    W.hold(B, -1, 1500)
    assert(W.carFrozen() and W.carHeight() > 1.0 and W.carHeight() < 1.9, ("B lowers it on the lift, it does not drop: %.3f"):format(W.carHeight()))
    W.assertPlatformsOnCar("B lowering")
    W.closeUi(B)

    W.openUi(A)
    W.hold(A, 1, 1500)
    assert(math.abs(W.carHeight() - 2.0) < 0.01, ("A raises it to the top, not past it: %.3f"):format(W.carHeight()))
    W.hold(A, -1, 6000)
    W.run(2000)
    W.assertAtFloor("A lowered it")
end

-- 3. Up from the second mechanic on a car already at the top stays at the top.
do
    local W = newWorld()
    local A, B = W.clients[1], W.clients[2]
    W.openUi(A)
    W.hold(A, 1, 6000)
    W.closeUi(A)
    W.openUi(B)
    W.hold(B, 1, 6000)
    assert(math.abs(W.carHeight() - 2.0) < 0.01, ("B's Up went past the top: %.3f"):format(W.carHeight()))
    W.hold(B, -1, 6000)
    W.assertAtFloor("B lowered it")
end

-- 4. The raised car is deleted (impound, garage, /dv): the platform stayed in the air for
--    everyone and the next car sank through the floor on Down.
do
    local W = newWorld()
    local A = W.clients[1]
    W.openUi(A)
    W.hold(A, 1, 6000)
    W.closeUi(A)
    for _, e in pairs(W.entities) do
        if e.attachedTo == W.vehicle then
            local p = W.posOf(_)
            e.attachedTo, e.off, e.x, e.y, e.z = nil, nil, p.x, p.y, p.z
        end
    end
    W.entities[W.vehicle].exists = false
    W.addVehicle(101, LIFT.x + 0.1, LIFT.y, FLOOR + REST)
    W.run(2500)
    for _, c in ipairs(W.clients) do
        local height, attached = W.platform(c)
        assert(not attached and math.abs(height) < 0.01, ("client %d platform left at %.3f"):format(c.id, height))
    end
    W.openUi(A)
    W.hold(A, -1, 3000)
    W.run(2000)
    assert(math.abs(W.carHeight()) < 0.01, ("the next car sank: %.3f"):format(W.carHeight()))
end

-- 5. Up pressed at any moment of the idle worker's wait: the car was released and attached
--    again in the first ticks, and with the server dropping messages inside 200 ms the other
--    player could be left with the platform on the floor while the car went up.
for phase = 0, 240, 20 do
    local W = newWorld()
    local A = W.clients[1]
    W.openUi(A)
    W.run(phase)
    W.hold(A, 1, 6000)
    W.assertPlatformsOnCar(("Up pressed %d ms into the wait"):format(phase))
    local sent = table.concat(W.relayed, ",")
    assert(not sent:find("detach"), "the car was released while going up: " .. sent)
end

-- 6. A quick tap of Up and back Down: the car is attached and released within 200 ms. The
--    server dropped the release, so the other player kept the platform riding on the car.
do
    local W = newWorld()
    local A, B = W.clients[1], W.clients[2]
    W.openUi(A)
    A.nuiCall("liftControl:setDirection", { direction = 1 })
    W.run(40)
    A.nuiCall("liftControl:setDirection", { direction = -1 })
    W.run(150)
    A.nuiCall("liftControl:setDirection", { direction = 0 })
    W.run(600)
    assert(W.relayed[#W.relayed] == "detach", "the release reached the other player: " .. table.concat(W.relayed, ","))
    local _, attachedForB = W.platform(B)
    assert(not attachedForB and math.abs(W.carHeight()) < 0.01, "the other player still has the platform on the car")
end

-- 7. A lift of the map (MLO props) is found without a workshop_lift point, unless
--    existingProps.autoDiscover.enabled is false: switching it off changed nothing.
do
    local MAP_LIFT = vec(LIFT.x + 30.0, LIFT.y, FLOOR)
    local function mapLiftOffered(autoDiscover)
        local W = newWorld({
            mapLift = MAP_LIFT,
            pedPos1 = vec(MAP_LIFT.x + 2.0, MAP_LIFT.y, FLOOR + 1.0),
            configure = function(Config) Config.WorkshopLiftSystem.existingProps.autoDiscover.enabled = autoDiscover end,
        })
        W.run(2000)
        local offered
        W.clients[1].call(function() offered = W.clients[1].env.isLiftRadialActionAvailable() end)
        W.run(100)
        return offered
    end
    assert(mapLiftOffered(true) == true, "the map lift is found")
    assert(mapLiftOffered(false) == false, "auto discovery switched off")
end

print("PASS: workshop lift raised and lowered by one mechanic, taken over by a second one (no drop, no double height, not through the floor), a raised car deleted (platform back down for everyone, the next car not sunk), and Up pressed at any moment keeps the platform under the car for other players, a quick tap releases the car for them too, map lifts found unless auto discovery is switched off.")
