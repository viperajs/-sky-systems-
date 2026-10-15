-- Run from the workspace root: lua tests/parts_delivery_spec.lua
-- Plays parts orders through sky_mechanicjob's real server and client files with mocked natives,
-- database and sky_jobs_base: the tablet's Parts Shop, the delivery timer, the box at the
-- delivery bay, unpacking, carry items mode, and what the player is told when it cannot work.

-- ── vectors, json ────────────────────────────────────
local vec_mt = { __name = "vector3" }
local function vec(x, y, z) return setmetatable({ x = x + 0.0, y = y + 0.0, z = z + 0.0 }, vec_mt) end
vec_mt.__sub = function(a, b) return vec(a.x - b.x, a.y - b.y, a.z - b.z) end
vec_mt.__add = function(a, b) return vec(a.x + b.x, a.y + b.y, a.z + b.z) end
vec_mt.__len = function(a) return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z) end

-- Network, export and database boundaries copy their values.
local function copy(v)
    if type(v) ~= "table" then return v end
    if getmetatable(v) == vec_mt then return vec(v.x, v.y, v.z) end
    local out = {}
    for k, val in pairs(v) do
        if type(val) ~= "function" then out[copy(k)] = copy(val) end
    end
    return out
end

-- Every value is encoded and decoded inside this spec, so a stored copy stands in for JSON text.
local jsonStore, jsonCount = {}, 0
local json = {
    encode = function(value)
        jsonCount = jsonCount + 1
        local key = "json#" .. jsonCount
        jsonStore[key] = copy(value)
        return key
    end,
    decode = function(text) return copy(jsonStore[text]) end,
}

local stub
stub = setmetatable({}, { __index = function() return stub end, __call = function() return stub end })

local MODULE_GLOBALS = {
    Config = true, Locales = true, Functions = true, Pricing = true, MechanicWorkshopData = true,
    MechanicTheft = true, Sky_Jobs = true, OrderInstallState = true, tuningLocales = true,
}

-- sky_jobs_base's built-in workshops (jobs.lua getDefaultWorkshopData), reduced to their points.
local function defaultWorkshops()
    return {
        entries = {
            {
                id = "mechanic_lscustoms", name = "Los Santos Customs", jobKey = "mechanic", job = "mechanic",
                points = {
                    { uid = "lsc_storage", type = "storage", label = "Parts Storage", x = -347.0, y = -133.0, z = 39.0, heading = 70.0 },
                    { uid = "lsc_delivery", type = "parts_drop", label = "Delivery Drop", x = -355.0, y = -140.0, z = 39.0, heading = 70.0 },
                }
            },
            {
                id = "mechanic_bennys", name = "Benny's Original Motor Works", jobKey = "mechanic", job = "mechanic",
                points = {
                    { uid = "bennys_delivery", type = "parts_drop", label = "Delivery Drop", x = -220.0, y = -1320.0, z = 31.3, heading = 0.0 },
                }
            }
        },
        features = {}, settings = {}, interactions = {}
    }
end

local LSC = vec(-350.0, -138.0, 39.0)
local LSC_STORAGE = vec(-347.0, -133.0, 39.0)
local FAR_AWAY = vec(1500.0, 3500.0, 35.0)

-- ── one world: server, client, database, clock ───────
local function newWorld(opts)
    opts = opts or {}
    local W = { clock = 0, threads = {}, timeouts = {}, objects = {}, nextEntity = 1000, pendingClient = {} }
    W.player = {
        pos = LSC, job = opts.serverJob or "mechanic",
        clientJobKey = opts.clientJobKey == nil and "mechanic" or opts.clientJobKey,
        clientOnDuty = opts.clientOnDuty ~= false, serverOnDuty = opts.serverOnDuty ~= false,
        bank = 100000, cash = 0, items = {},
    }
    W.db = { rows = {}, nextId = 1, creatorRow = nil, failInsert = opts.failInsert }
    W.workshops = opts.workshops or defaultWorkshops()
    if opts.savedRow ~= false then W.db.creatorRow = json.encode(W.workshops) end
    for _, row in ipairs(opts.rows or {}) do
        row.id = W.db.nextId
        W.db.nextId = W.db.nextId + 1
        W.db.rows[#W.db.rows + 1] = row
    end

    -- Threads are coroutines; Wait yields at least one 16 ms frame.
    local function spawn(fn, label, paused)
        local t = { co = coroutine.create(fn), wake = W.clock, label = label, paused = paused }
        W.threads[#W.threads + 1] = t
        return t
    end
    local function step(t)
        local ok, ms = coroutine.resume(t.co)
        if not ok then error(("%s failed: %s"):format(t.label, tostring(ms))) end
        if coroutine.status(t.co) ~= "dead" then t.wake = W.clock + math.max(16, tonumber(ms) or 0) end
    end
    local function wait(ms) if coroutine.isyieldable() then coroutine.yield(ms or 0) end end

    function W.run(fn, label)
        local t = spawn(fn, label or "call")
        while coroutine.status(t.co) ~= "dead" do
            if t.wake > W.clock then W.clock = t.wake end
            step(t)
        end
        for i, other in ipairs(W.threads) do if other == t then table.remove(W.threads, i) break end end
    end

    function W.advance(ms)
        local target = W.clock + ms
        while true do
            local at, kind, item = target + 1, nil, nil
            for _, to in ipairs(W.timeouts) do
                if not to.done and to.at <= at then at, kind, item = to.at, "timeout", to end
            end
            for _, t in ipairs(W.threads) do
                if coroutine.status(t.co) ~= "dead" and not t.paused and t.wake <= at then at, kind, item = t.wake, "thread", t end
            end
            if not kind then break end
            W.clock = math.max(W.clock, at)
            if kind == "timeout" then
                item.done = true
                step(spawn(item.fn, "timeout"))
            else
                step(item)
            end
            W.flush()
        end
        W.clock = target
    end

    -- ── database (only the queries parts_delivery.lua makes) ──
    local function literal(v) return v:sub(1, 1) == "'" and v:sub(2, -2) or (tonumber(v) or v) end
    local function conditions(where, params, pi)
        local conds = {}
        for clause in (where .. " AND "):gmatch("(.-)%s+AND%s+") do
            local col, val = clause:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
            if col then
                if val == "?" then pi = pi + 1; conds[#conds + 1] = { col, params[pi] }
                else conds[#conds + 1] = { col, literal(val) } end
            else
                local inCol, list = assert(clause:match("^%s*([%w_]+)%s+IN%s*%((.-)%)%s*$"))
                local set = {}
                for item in list:gmatch("'([^']*)'") do set[item] = true end
                conds[#conds + 1] = { inCol, set }
            end
        end
        return conds, pi
    end
    local function matches(row, conds)
        for _, c in ipairs(conds) do
            if type(c[2]) == "table" then
                if not c[2][row[c[1]]] then return false end
            elseif tostring(row[c[1]]) ~= tostring(c[2]) then
                return false
            end
        end
        return true
    end
    local function normalize(q) return (q:gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")) end
    local function select(q, params)
        local cols, where = assert(q:match("^SELECT (.-) FROM sky_mechanic_parts_deliveries WHERE (.-)$"))
        local order = where:match(" ORDER BY id (%u+)")
        where = where:gsub(" ORDER BY.*$", ""):gsub(" LIMIT %S+$", "")
        local conds, pi = conditions(where, params, 0)
        local limit = q:match("LIMIT (%S+)$")
        if limit == "?" then limit = params[pi + 1] end
        local rows = {}
        for _, row in ipairs(W.db.rows) do if matches(row, conds) then rows[#rows + 1] = row end end
        if order == "DESC" then table.sort(rows, function(a, b) return a.id > b.id end) end
        local out = {}
        for i, row in ipairs(rows) do
            if tonumber(limit) and i > tonumber(limit) then break end
            local picked = {}
            if cols == "*" then for k, v in pairs(row) do picked[k] = v end
            else for col in cols:gmatch("[%w_]+") do picked[col] = row[col] end end
            out[#out + 1] = picked
        end
        return out
    end
    local function update(q, params)
        local sets, where = assert(q:match("^UPDATE sky_mechanic_parts_deliveries SET (.-) WHERE (.-)$"))
        local assigns, pi = {}, 0
        for part in (sets .. ","):gmatch("(.-),") do
            local col, val = part:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
            if val == "?" then pi = pi + 1; assigns[#assigns + 1] = { col, params[pi] }
            else assigns[#assigns + 1] = { col, literal(val) } end
        end
        local conds = conditions(where, params, pi)
        local n = 0
        for _, row in ipairs(W.db.rows) do
            if matches(row, conds) then
                for _, a in ipairs(assigns) do row[a[1]] = a[2] end
                n = n + 1
            end
        end
        return n
    end
    W.MySQL = {
        query = { await = function(q, params)
            q = normalize(q)
            if q:find("^SELECT .- FROM sky_mechanic_parts_deliveries") then return select(q, params or {}) end
            if q:find("^UPDATE sky_mechanic_parts_deliveries") then return update(q, params or {}) end
            return {}
        end },
        single = { await = function(q, params)
            q = normalize(q)
            if q:find("creator_key = 'workshopcreator'", 1, true) then
                return W.db.creatorRow and { data = W.db.creatorRow } or nil
            end
            if q:find("FROM sky_mechanic_parts_deliveries", 1, true) then return select(q, params or {})[1] end
            return nil
        end },
        insert = { await = function(q, params)
            assert(normalize(q):find("^INSERT INTO sky_mechanic_parts_deliveries"))
            if W.db.failInsert then error(W.db.failInsert) end
            local row = {
                id = W.db.nextId, job = params["@job"], identifier = params["@identifier"],
                delivery_point = params["@delivery_point"], items = params["@items"],
                total_price = params["@total_price"], status = params["@status"], created_at = 0,
            }
            W.db.nextId = W.db.nextId + 1
            W.db.rows[#W.db.rows + 1] = row
            return row.id
        end },
        update = { await = function(q, params) return update(normalize(q), params or {}) end },
    }
    W.MySQL.ready = function(fn) fn() end

    local function newEnv(side)
        local E = { callbacks = {}, events = {}, nui = {}, exports = {}, notifications = {}, pushes = {}, help = 0 }
        local env = setmetatable({}, { __index = function(_, key)
            local value = _G[key]
            if value ~= nil or MODULE_GLOBALS[key] then return value end
            return stub
        end })
        env._G = env
        env.json = json
        env.vector3 = vec
        env.type = function(value) return getmetatable(value) == vec_mt and "vector3" or type(value) end
        env.SkyDiagnostics = false
        env.print = function() end
        env.GetCurrentResourceName = function() return "sky_mechanicjob" end
        env.IsDuplicityVersion = function() return side == "server" end
        env.GetGameTimer = function() return W.clock end
        env.GetGameBuildNumber = function() return 3258 end
        env.Wait = wait
        env.CreateThread = function(fn)
            local info = debug.getinfo(2, "S")
            local src = tostring(info and info.short_src)
            -- Only parts_delivery.lua's client threads run; the other client loops are not under test.
            spawn(fn, side .. " " .. src, side == "client" and not src:find("parts_delivery", 1, true))
        end
        env.SetTimeout = function(ms, fn) W.timeouts[#W.timeouts + 1] = { at = W.clock + ms, fn = fn } end
        env.Citizen = { CreateThread = env.CreateThread, SetTimeout = env.SetTimeout, Wait = wait }
        env.AddEventHandler = function(name, fn)
            E.events[name] = E.events[name] or {}
            table.insert(E.events[name], fn)
        end
        env.RegisterNetEvent = function(name, fn) if fn then env.AddEventHandler(name, fn) end end
        env.RegisterCommand = function() end
        env.RegisterKeyMapping = function() end
        env.GetHashKey = function(s)
            local h = 0
            for i = 1, #tostring(s) do h = (h * 31 + tostring(s):byte(i)) % 4294967296 end
            return h
        end
        env.exports = setmetatable({}, {
            __call = function(_, name, fn) E.exports[name] = fn end,
            __index = function(_, resource) return (W.external[side] or {})[resource] or stub end,
        })
        E.env = env
        function E.load(path) assert(loadfile(path, "t", env))() end
        function E.emit(name, ...)
            local args = table.pack(...)
            for _, fn in ipairs(E.events[name] or {}) do
                W.run(function() fn(table.unpack(args, 1, args.n)) end, side .. " event " .. name)
            end
        end
        return E
    end

    -- ── server ──
    local S = newEnv("server")
    W.server = S
    local senv = S.env
    senv.MySQL = W.MySQL
    local started = { sky_base = true, sky_jobs_base = true, oxmysql = true, ox_inventory = true }
    senv.GetResourceState = function(name) return started[name] and "started" or "missing" end
    senv.GetPlayers = function() return { "1" } end
    senv.GetPlayerPed = function() return 101 end
    senv.GetEntityCoords = function() return W.player.pos end
    senv.TriggerClientEvent = function(name, target, ...)
        if target == 1 or target == -1 then W.pendingClient[#W.pendingClient + 1] = { name = name, args = copy(table.pack(...)) } end
    end
    senv.TriggerEvent = function(name, ...) S.emit(name, ...) end
    senv.Sky = {
        Cb = { Register = function(name, fn) S.callbacks[name] = fn end },
        Config = { locale = "en", framework = "qb" },
        FW = {
            GetJob = function() return W.player.job end,
            GetIdentifier = function() return "CID1" end,
            GetName = function() return "Test Mechanic" end,
            GetJobData = function(_, key) if key == "duty" then return W.player.serverOnDuty end return 0 end,
            GetAccountMoney = function(_, account) return W.player[account] or 0 end,
            AddAccountMoney = function(_, account, amount) W.player[account] = (W.player[account] or 0) + amount return true end,
            RemoveAccountMoney = function(_, account, amount)
                if (W.player[account] or 0) < amount then return false end
                W.player[account] = W.player[account] - amount
                return true
            end,
        },
    }
    W.external = {
        server = {
            sky_jobs_base = {
                isOnDuty = function() return W.player.serverOnDuty end,
                HasJobPermission = function() return true end,
                RemoveSocietyMoney = function() return true end,
                AddSocietyMoney = function() return true end,
                GetJobConfiguratorJobNames = function() return { "mechanic" } end,
            },
            ox_inventory = {
                CanCarryItem = function() return true end,
                AddItem = function(_, _, item, count) W.player.items[item] = (W.player.items[item] or 0) + count return true end,
                RemoveItem = function(_, _, item, count) W.player.items[item] = (W.player.items[item] or 0) - count return true end,
            },
        },
        client = {},
    }
    S.load("sky_mechanicjob/source/config_overrides.lua")
    S.load("sky_mechanicjob/config/init.lua")
    S.load("sky_mechanicjob/config/config.lua")
    S.load("sky_mechanicjob/config/adv_config.lua")
    S.load("sky_mechanicjob/config/sv_functions.lua")
    S.load("sky_mechanicjob/config/locales/en.lua")
    S.load("sky_mechanicjob/source/server/pricing.lua")
    S.load("sky_mechanicjob/source/server/parts_delivery.lua")

    -- ── client ──
    local C = newEnv("client")
    W.client = C
    local cenv = C.env
    local snapshot = W.player.clientJobKey ~= false
    if W.player.clientJobKey == false then W.player.clientJobKey = nil end
    cenv.GetResourceState = function(name) return (name == "sky_base" or name == "sky_jobs_base") and "started" or "missing" end
    cenv.PlayerPedId = function() return 101 end
    cenv.GetEntityCoords = function(entity)
        if entity == 101 then return W.player.pos end
        return W.objects[entity] and W.objects[entity].pos or vec(0, 0, 0)
    end
    cenv.GetEntityHeading = function() return 0.0 end
    cenv.IsPedInAnyVehicle = function() return false end
    cenv.GetVehiclePedIsIn = function() return 0 end
    cenv.IsModelValid = function() return true end
    cenv.IsModelInCdimage = function() return not W.brokenProps end
    cenv.HasModelLoaded = function() return true end
    local function createObject(model, x, y, z)
        local id = W.nextEntity
        W.nextEntity = W.nextEntity + 1
        W.objects[id] = { model = model, pos = vec(x, y, z) }
        return id
    end
    cenv.CreateObject = createObject
    cenv.CreateObjectNoOffset = function(model, x, y, z) local id = createObject(model, x, y, z); W.objects[id].carried = true; return id end
    cenv.DoesEntityExist = function(entity) return entity == 101 or W.objects[entity] ~= nil end
    cenv.DeleteEntity = function(entity) W.objects[entity] = nil end
    cenv.DeleteObject = cenv.DeleteEntity
    cenv.SetEntityCoordsNoOffset = function(entity, x, y, z) if W.objects[entity] then W.objects[entity].pos = vec(x, y, z) end end
    -- The ground only loads around the player.
    local function groundLoaded(entity) return W.objects[entity] ~= nil and #(W.objects[entity].pos - W.player.pos) < 100.0 end
    cenv.HasCollisionLoadedAroundEntity = groundLoaded
    cenv.PlaceObjectOnGroundProperly = function(entity) if groundLoaded(entity) then W.objects[entity].grounded = true end end
    cenv.FreezeEntityPosition = function(entity, frozen) if W.objects[entity] then W.objects[entity].frozen = frozen end end
    cenv.RequestCollisionAtCoord = function() end
    cenv.GetInteriorAtCoords = function() return 0 end
    cenv.IsControlJustPressed = function(_, key) return key == 38 and W.pressingE == true end
    cenv.SendNUIMessage = function() end
    cenv.RegisterNUICallback = function(name, fn) C.nui[name] = fn end
    cenv.TriggerServerEvent = function() end
    cenv.Sky = {
        Config = { locale = "en" },
        Load = { Model = function() end },
        Show = {
            Notification = function(_, message, kind) C.notifications[#C.notifications + 1] = { msg = message, kind = kind } end,
            HelpNotification = function() C.help = C.help + 1 end,
        },
        Cb = {
            Register = function() end,
            Trigger = function(name, ...)
                if name == "sky_jobs_base:creator:getData" then
                    return { success = true, data = W.db.creatorRow and json.decode(W.db.creatorRow) or defaultWorkshops() }
                elseif name == "sky_jobs_base:getNuiImageBases" then
                    return {}
                end
                local args = copy(table.pack(...))
                return copy((assert(S.callbacks[name], name))(1, table.unpack(args, 1, args.n)))
            end,
        },
    }
    cenv.Sky_Jobs = {
        Access = {
            GetJobKey = function() return W.player.clientJobKey end,
            IsOnDuty = function() return W.player.clientOnDuty end,
            HasSnapshot = function() return snapshot end,
            -- sky_jobs_base answers with the framework job.
            Refresh = function() snapshot = true; W.player.clientJobKey = W.player.job end,
        },
        Tablet = { PushNotification = function(data) C.pushes[#C.pushes + 1] = data end },
    }
    C.load("sky_mechanicjob/source/config_overrides.lua")
    C.load("sky_mechanicjob/config/init.lua")
    C.load("sky_mechanicjob/config/config.lua")
    C.load("sky_mechanicjob/config/adv_config.lua")
    if opts.clientConfig then opts.clientConfig(cenv.Config) end
    C.load("sky_mechanicjob/config/locales/en.lua")
    C.load("sky_mechanicjob/source/client/state.lua")
    C.load("sky_mechanicjob/source/client/main.lua")
    C.load("sky_mechanicjob/source/client/orders.lua")
    C.load("sky_mechanicjob/source/client/parts_delivery.lua")

    function W.flush()
        while #W.pendingClient > 0 do
            local ev = table.remove(W.pendingClient, 1)
            C.emit(ev.name, table.unpack(ev.args, 1, ev.args.n))
        end
    end

    function W.nui(name, payload)
        local reply
        W.run(function() C.nui[name](copy(payload or {}), function(res) reply = copy(res) end) end, "nui " .. name)
        return reply
    end

    -- Places an order from the tablet the way the NUI does: only with a delivery bay.
    function W.order(items, method)
        local config = W.nui("partsShop:getConfig")
        W.lastConfig = config
        local point = config and config.data and config.data.deliveryPoint
        if not point then return nil, config end
        return W.nui("partsShop:placeOrder", { paymentMethod = method or "own_card", deliveryPointKey = point.key, items = items }), config
    end

    function W.boxes()
        local list = {}
        for _, object in pairs(W.objects) do if not object.carried then list[#list + 1] = object end end
        return list
    end

    -- The prompt loop checks every 500 ms until the player stands at a box.
    function W.pressE()
        W.advance(600)
        W.pressingE = true
        W.advance(100)
        W.pressingE = false
        W.advance(8000)
    end

    function W.lastNotification()
        local last = C.notifications[#C.notifications]
        return last and last.msg or nil
    end

    -- Saves the /jobconfig row and lets the server reload it, as a configurator save does.
    function W.saveWorkshops(mutate)
        local data = json.decode(W.db.creatorRow)
        mutate(data)
        W.db.creatorRow = json.encode(data)
        S.emit("sky_jobs_base:jobConfigurator:jobNamesUpdated", "sky_mechanicjob")
        W.advance(100)
    end

    W.advance(10000) -- resource start: configurator data, recovery, first fetch
    return W
end

local function withoutPoints(pointType)
    local data = defaultWorkshops()
    for _, entry in ipairs(data.entries) do
        for i = #entry.points, 1, -1 do
            if entry.points[i].type == pointType then table.remove(entry.points, i) end
        end
    end
    return data
end

-- 1. An order from the tablet arrives at the bay after the delivery time and unpacks.
do
    local W = newWorld()
    local placed = assert(W.order({ { name = "brakes", quantity = 2 } }))
    assert(placed.success == true and placed.data.orderUid == "PD-00001", "order placed")
    local history = W.nui("partsShop:getOrderHistory", { pageSize = 50 })
    assert(#history.data.orders == 1 and history.data.orders[1].status == "pending", "order in the history")
    assert(#W.boxes() == 0, "no box before the delivery time")

    W.advance(65000)
    assert(W.db.rows[1].status == "ready", "ready after the delivery time")
    assert(#W.client.pushes == 1, "tablet push for the ready delivery")
    local boxes = W.boxes()
    assert(#boxes == 1 and boxes[1].grounded and boxes[1].frozen, "one box on the ground at the bay")
    assert(#(boxes[1].pos - vec(-355.0, -140.0, 39.0)) < 0.01, "box at the Delivery Drop")

    W.player.pos = boxes[1].pos + vec(1.0, 0.0, 0.0)
    W.advance(600)
    assert(W.client.help > 0, "E prompt next to the box")
    W.pressE()
    assert(W.player.items.brakes == 2, "parts in the inventory")
    assert(W.db.rows[1].status == "claimed" and #W.boxes() == 0, "delivery closed and box removed")
    assert(W.lastNotification() == "Delivery unpacked.")
end

-- 2. Without a Parts Delivery Drop, or a workshop of the player's job, the tablet cannot
-- deliver; the player is told why instead of checkout silently staying grey.
do
    local W = newWorld({ workshops = withoutPoints("parts_drop") })
    local placed, config = W.order({ { name = "brakes", quantity = 1 } })
    assert(placed == nil and config.success == true and config.data.deliveryPoint == nil, "no bay offered")
    assert(W.lastNotification():find("no Parts Delivery Drop", 1, true), tostring(W.lastNotification()))
    assert(#W.db.rows == 0)

    -- Workshops saved under another job name than the mechanics' framework job.
    local data = defaultWorkshops()
    for _, entry in ipairs(data.entries) do entry.jobKey, entry.job = "Mechanic Shop", "Mechanic Shop" end
    W = newWorld({ workshops = data })
    W.order({ { name = "brakes", quantity = 1 } })
    assert(W.lastNotification() == "No workshop in /jobconfig belongs to your job (mechanic).", tostring(W.lastNotification()))
end

-- 3. A tablet opened before the job reached this resource asks sky_jobs_base for it.
do
    local W = newWorld({ clientJobKey = false })
    local placed = assert(W.order({ { name = "brakes", quantity = 1 } }), "bay found after asking for the job")
    assert(placed.success == true)
end

-- 4. Rejected orders say why (the tablet only shows "Failed to place parts order.").
do
    local W = newWorld({ serverOnDuty = false })
    local placed = W.order({ { name = "brakes", quantity = 1 } })
    assert(placed.success == false and placed.error == "not_on_duty")
    assert(W.lastNotification() == "You must be on duty to order parts.")

    W = newWorld({ failInsert = "Unknown column 'total_price'" })
    placed = W.order({ { name = "brakes", quantity = 1 } })
    assert(placed.error == "order_failed" and W.player.bank == 100000, "refunded")
    assert(W.lastNotification():find("could not be saved", 1, true))
end

-- 5. A delivery that becomes ready while the player is across the map gets its box when the
-- player comes back, on loaded ground (a pallet only gets physics then).
do
    local W = newWorld()
    W.order({ { name = "brakes", quantity = 1 } })
    W.player.pos = FAR_AWAY
    W.advance(65000)
    assert(#W.boxes() == 0, "no box created far from the player")
    W.player.pos = LSC
    W.advance(2000)
    local boxes = W.boxes()
    assert(#boxes == 1 and boxes[1].grounded and boxes[1].frozen, "box placed once the player is near")

    W = newWorld({
        clientConfig = function(Config) Config.ToggleFeatures.carryItems = true end,
        workshops = (function() local d = defaultWorkshops(); d.features = { partsDelivery = true, carryItems = true }; return d end)(),
    })
    W.order({ { name = "spark_plugs", quantity = 2 } })
    W.player.pos = FAR_AWAY
    W.advance(65000)
    assert(#W.boxes() == 0, "no pallet created far from the player")
    W.player.pos = LSC
    W.advance(2000)
    boxes = W.boxes()
    assert(#boxes == 1 and boxes[1].grounded and boxes[1].frozen == false, "pallet on the ground with physics")
end

-- 6. A box whose bay was moved after the order stands at the new place and opens there.
do
    local W = newWorld({ rows = {
        { job = "mechanic", identifier = "X", status = "ready", total_price = 0, created_at = 0,
          items = json.encode({ { name = "turbo", quantity = 1 } }),
          delivery_point = json.encode({ key = "parts_drop:mechanic_lscustoms:lsc_delivery", label = "Delivery Drop",
              coords = { x = -325.0, y = -140.0, z = 39.0 }, heading = 0 }) },
    } })
    local boxes = W.boxes()
    assert(#boxes == 1 and #(boxes[1].pos - vec(-355.0, -140.0, 39.0)) < 0.01, "box at the bay's current place")
    W.player.pos = boxes[1].pos + vec(1.0, 0.0, 0.0)
    W.pressE()
    assert(W.player.items.turbo == 1 and W.db.rows[1].status == "claimed", "opened at the moved bay")
end

-- 7. The workshop's Parts Delivery tab: empty keeps config.lua's list; a part taken out of it
-- after paying is still delivered; a part no shop sells anymore is reported, not "unpacked".
do
    local data = defaultWorkshops()
    for _, entry in ipairs(data.entries) do entry.partsDeliveryShop = {} end
    local W = newWorld({ workshops = data })
    local placed = W.order({ { name = "brakes", quantity = 1 } })
    assert(#W.lastConfig.data.items > 0 and placed.success == true, "empty tab sells config.lua's parts")

    W = newWorld()
    W.order({ { name = "brakes", quantity = 1 } })
    W.advance(65000)
    W.saveWorkshops(function(d)
        for _, entry in ipairs(d.entries) do entry.partsDeliveryShop = { { name = "spark_plugs", label = "Spark Plugs", price = 120 } } end
    end)
    W.player.pos = W.boxes()[1].pos + vec(1.0, 0.0, 0.0)
    W.pressE()
    assert(W.player.items.brakes == 1, "paid part delivered after it left the workshop's tab")

    W = newWorld()
    W.order({ { name = "brakes", quantity = 1 } })
    W.advance(65000)
    for _, job in ipairs(W.server.env.Config.Jobs) do
        for _, key in ipairs({ "partsDeliveryShop", "shop" }) do
            for i = #(job[key] or {}), 1, -1 do if job[key][i].name == "brakes" then table.remove(job[key], i) end end
        end
    end
    W.saveWorkshops(function(d)
        for _, entry in ipairs(d.entries) do entry.partsDeliveryShop = { { name = "spark_plugs", label = "Spark Plugs", price = 120 } } end
    end)
    W.player.pos = W.boxes()[1].pos + vec(1.0, 0.0, 0.0)
    W.pressE()
    assert(next(W.player.items) == nil and W.db.rows[1].status == "claimed")
    assert(W.lastNotification():find("no parts the shop still sells", 1, true), tostring(W.lastNotification()))
end

-- 8. Carry items mode: a carry prop that fails to load leaves nothing "held", so the delivery
-- can be opened again; carried to the storage it lands in the inventory.
do
    local W = newWorld({
        clientConfig = function(Config) Config.ToggleFeatures.carryItems = true end,
        workshops = (function() local d = defaultWorkshops(); d.features = { partsDelivery = true, carryItems = true }; return d end)(),
    })
    W.order({ { name = "brakes", quantity = 1 } })
    W.advance(65000)
    W.player.pos = W.boxes()[1].pos + vec(1.0, 0.0, 0.0)

    W.brokenProps = true
    W.pressE()
    assert(W.lastNotification() == "Failed to unpack this delivery.")
    assert(W.client.env.OrderInstallState.heldCarryItem == nil, "nothing left held")
    assert(W.db.rows[1].status == "ready", "delivery back at the bay")

    W.brokenProps = false
    W.client.help = 0
    W.advance(600)
    assert(W.client.help > 0, "E prompt again")
    W.pressE()
    assert(W.client.env.OrderInstallState.heldCarryItem ~= nil and W.db.rows[1].status == "claiming", "carrying the part")

    W.player.pos = LSC_STORAGE
    local handled
    W.run(function() handled = W.client.exports.TryDepositCarryItemToStorage("mechanic_lscustoms") end)
    assert(handled == true and W.player.items.brakes == 1 and W.db.rows[1].status == "claimed", "stored")
    assert(W.client.env.OrderInstallState.heldCarryItem == nil)
end

-- 9. sky_jobs_base access: without the duty system every member is on duty (as on the
-- server); ESX job updates carry onDuty; a job name alone keeps the duty state.
do
    local events, env = {}, nil
    local function load(dutySystem)
        events = {}
        env = setmetatable({}, { __index = function(_, key)
            local value = _G[key]
            if value ~= nil then return value end
            return stub
        end })
        env._G = env
        env.SkyDiagnostics = false
        env.Config = { DutySystem = dutySystem, MultiJob = { defaultJob = "unemployed" } }
        env.Sky_Jobs = nil
        env.exports = setmetatable({}, { __call = function() end })
        env.CreateThread = function() end
        env.TriggerEvent = function() end
        env.RegisterNetEvent = function(name, fn) events[name] = fn end
        env.AddEventHandler = env.RegisterNetEvent
        assert(loadfile("sky_jobs_base/source/client/access.lua", "t", env))()
        return env.Sky_Jobs.Access
    end

    local access = load(false)
    events["sky_base:updateJob"]({ name = "mechanic", onduty = false })
    assert(access.GetJobKey() == "mechanic" and access.IsOnDuty() == true, "duty system off: on duty")

    access = load(true)
    events["sky_base:updateJob"]({ name = "mechanic", onduty = false })
    assert(access.IsOnDuty() == false)
    events["sky_base:updateJob"]({ name = "mechanic", onDuty = true })
    assert(access.IsOnDuty() == true, "ESX onDuty")
    events["sky_base:updateJob"]("mechanic")
    assert(access.IsOnDuty() == true, "job name alone keeps the duty state")
end

print("PASS: parts orders from the tablet, delivery timer, box placement near the player, unpacking, moved bays, catalogue changes, carry items, no-bay/order error messages, client duty without the duty system.")
