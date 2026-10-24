-- Run from the workspace root: lua tests/order_flow_spec.lua
-- Plays tuning orders through sky_mechanicjob's real server and client files with mocked
-- natives and database: a customer buys parts in the self-service tuning menu, the order shows
-- in the mechanic's Orders tablet, the mechanic connects the vehicle, starts the install and
-- works through the radial menu (hood, engine swap minigame, part install) until the order
-- completes.

-- ── vectors, copies, json ────────────────────────────
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

-- A small JSON codec: arrays, objects, strings, numbers, booleans and null, as the game's json.
local json = {}
do
    local function isArray(t)
        local n = 0
        for _ in pairs(t) do n = n + 1 end
        if n == 0 then return true end
        for i = 1, n do if t[i] == nil then return false end end
        return true
    end
    local escapes = { ['"'] = '\\"', ["\\"] = "\\\\", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }
    local function encode(v, out)
        local tv = type(v)
        if tv == "nil" then out[#out + 1] = "null"
        elseif tv == "boolean" then out[#out + 1] = tostring(v)
        elseif tv == "number" then
            if v == math.floor(v) and math.abs(v) < 2 ^ 53 then out[#out + 1] = ("%d"):format(v)
            else out[#out + 1] = ("%.14g"):format(v) end
        elseif tv == "string" then out[#out + 1] = '"' .. v:gsub('[%c"\\]', function(c) return escapes[c] or ("\\u%04x"):format(c:byte()) end) .. '"'
        elseif tv == "table" then
            if getmetatable(v) == vec_mt then
                encode({ x = v.x, y = v.y, z = v.z }, out)
            elseif isArray(v) then
                out[#out + 1] = "["
                for i, item in ipairs(v) do
                    if i > 1 then out[#out + 1] = "," end
                    encode(item, out)
                end
                out[#out + 1] = "]"
            else
                out[#out + 1] = "{"
                local first = true
                local keys = {}
                for k in pairs(v) do keys[#keys + 1] = tostring(k) end
                table.sort(keys)
                for _, k in ipairs(keys) do
                    local val = v[k]
                    if val == nil then val = v[tonumber(k)] end
                    if not first then out[#out + 1] = "," end
                    first = false
                    encode(k, out)
                    out[#out + 1] = ":"
                    encode(val, out)
                end
                out[#out + 1] = "}"
            end
        else
            error("cannot encode " .. tv)
        end
    end
    function json.encode(v)
        local out = {}
        encode(v, out)
        return table.concat(out)
    end

    local function decodeValue(s, pos)
        pos = s:find("%S", pos) or error("unexpected end of json")
        local c = s:sub(pos, pos)
        if c == "{" then
            local obj = {}
            pos = pos + 1
            local p = s:find("%S", pos)
            if s:sub(p, p) == "}" then return obj, p + 1 end
            while true do
                local key
                key, pos = decodeValue(s, pos)
                pos = s:find(":", pos, true) + 1
                obj[key], pos = decodeValue(s, pos)
                pos = s:find("%S", pos)
                local d = s:sub(pos, pos)
                pos = pos + 1
                if d == "}" then return obj, pos end
                assert(d == ",", "bad object at " .. pos)
            end
        elseif c == "[" then
            local arr = {}
            pos = pos + 1
            local p = s:find("%S", pos)
            if s:sub(p, p) == "]" then return arr, p + 1 end
            while true do
                arr[#arr + 1], pos = decodeValue(s, pos)
                pos = s:find("%S", pos)
                local d = s:sub(pos, pos)
                pos = pos + 1
                if d == "]" then return arr, pos end
                assert(d == ",", "bad array at " .. pos)
            end
        elseif c == '"' then
            local out, i = {}, pos + 1
            while true do
                local ch = s:sub(i, i)
                if ch == '"' then return table.concat(out), i + 1 end
                if ch == "\\" then
                    local n = s:sub(i + 1, i + 1)
                    local map = { n = "\n", r = "\r", t = "\t", ['"'] = '"', ["\\"] = "\\", ["/"] = "/" }
                    if n == "u" then
                        out[#out + 1] = string.char(tonumber(s:sub(i + 2, i + 5), 16) % 256)
                        i = i + 6
                    else
                        out[#out + 1] = map[n] or n
                        i = i + 2
                    end
                else
                    out[#out + 1] = ch
                    i = i + 1
                end
            end
        elseif s:sub(pos, pos + 3) == "true" then return true, pos + 4
        elseif s:sub(pos, pos + 4) == "false" then return false, pos + 5
        elseif s:sub(pos, pos + 3) == "null" then return nil, pos + 4
        else
            local num = s:match("^-?%d+%.?%d*[eE]?[-+]?%d*", pos)
            return tonumber(num), pos + #num
        end
    end
    function json.decode(s)
        if type(s) ~= "string" then error("json.decode expects a string") end
        return (decodeValue(s, 1))
    end
end

local stub
stub = setmetatable({}, { __index = function() return stub end, __call = function() return stub end })

local MODULE_GLOBALS = {
    Config = true, Locales = true, Functions = true, Pricing = true, TuningDB = true, MechanicItemSessions = true,
    VehicleHistory = true, VehiclePersistence = true, Sky_Jobs = true, CustomTuning = true, StanceKit = true,
    AntiLag = true, TwoStep = true, OrderInstallState = true, WheelOrderInstallState = true,
    OrderTabletState = true, TuningState = true, tuningLocales = true, nuiLocales = true, locales = true,
    MechanicWorkshopData = true, MechanicTheft = true,
}

local VEH, NET, PED = 9, 109, 1
local CAR_BONES = { bonnet = 1, wheel_lf = 2, wheel_rf = 3, wheel_lr = 4, wheel_rr = 5, spoiler = 6 }
local BONE_POS = {
    bonnet = vec(0, 1.8, 0.8), wheel_lf = vec(-0.9, 1.4, 0.3), wheel_rf = vec(0.9, 1.4, 0.3),
    wheel_lr = vec(-0.9, -1.4, 0.3), wheel_rr = vec(0.9, -1.4, 0.3), spoiler = vec(0, -2.2, 0.9),
}
-- Stages a tuner's SULTAN offers (GetNumVehicleMods).
local NUM_MODS = { [0] = 3, [1] = 2, [11] = 4, [12] = 4, [13] = 3, [15] = 5, [16] = 5, [23] = 10 }

-- ── one world: server, client, database, vehicle ─────
local function newWorld(opts)
    opts = opts or {}
    local W = { clock = 0, timeouts = {}, objects = {}, nextObject = 500 }
    W.player = {
        pos = vec(1.5, 0.0, 0.0), job = opts.job or "unemployed", onDuty = opts.onDuty ~= false,
        cash = 500000, bank = 500000, items = {}, society = 10000,
    }
    W.veh = {
        plate = opts.plate or "TEST 123", model = 1234, pos = vec(0, 0, 0), class = 6,
        mods = {}, toggles = {}, hood = 0.0, wheelType = 0, owned = opts.owned ~= false,
    }
    W.db = { orders = {}, nextOrderId = 1, history = {} }

    -- ── coroutine runner: Wait advances the clock; Citizen.Await yields until resolved ──
    local function wait(ms) if coroutine.isyieldable() then coroutine.yield(ms or 0) end end
    function W.run(fn, label)
        local co = coroutine.create(fn)
        while true do
            local res = table.pack(coroutine.resume(co))
            if not res[1] then error(("%s failed: %s"):format(label or "call", tostring(res[2]))) end
            if coroutine.status(co) == "dead" then return table.unpack(res, 2, res.n) end
            if res[2] == "await" then
                assert(W.onAwait, (label or "call") .. " waits on a promise nobody resolves")
                W.onAwait()
            else
                W.clock = W.clock + math.max(16, tonumber(res[2]) or 0)
            end
        end
    end

    local function newEnv(side)
        local E = { callbacks = {}, events = {}, nui = {}, exports = {}, notifications = {}, messages = {}, serverEvents = {} }
        local env = setmetatable({}, { __index = function(_, key)
            local value = _G[key]
            if value ~= nil or MODULE_GLOBALS[key] then return value end
            return stub
        end })
        env._G = env
        env.json = json
        env.vector3 = vec
        env.vec3 = vec
        env.type = function(value) return getmetatable(value) == vec_mt and "vector3" or type(value) end
        env.print = function() end
        env.GetCurrentResourceName = function() return "sky_mechanicjob" end
        env.IsDuplicityVersion = function() return side == "server" end
        env.GetGameTimer = function() return W.clock end
        env.GetGameBuildNumber = function() return 3258 end
        env.Wait = wait
        env.CreateThread = function() end -- background loops are not under test
        env.SetTimeout = function(ms, fn) W.timeouts[#W.timeouts + 1] = { at = W.clock + ms, fn = fn } end
        env.Citizen = {
            CreateThread = env.CreateThread, SetTimeout = env.SetTimeout, Wait = wait,
            Await = function(p)
                while not p.resolved do coroutine.yield("await") end
                return p.value
            end,
        }
        env.promise = { new = function() return { resolve = function(self, v) self.resolved = true; self.value = v end } end }
        env.AddEventHandler = function(name, fn)
            E.events[name] = E.events[name] or {}
            table.insert(E.events[name], fn)
        end
        env.RegisterNetEvent = function(name, fn) if fn then env.AddEventHandler(name, fn) end end
        env.RegisterServerEvent = env.RegisterNetEvent
        env.RegisterCommand = function() end
        env.RegisterKeyMapping = function() end
        env.TriggerEvent = function(name, ...) E.emit(name, ...) end
        env.GetHashKey = function(s)
            local h = 0
            for i = 1, #tostring(s) do h = (h * 31 + tostring(s):byte(i)) % 4294967296 end
            return h
        end
        env.exports = setmetatable({}, {
            __call = function(_, name, fn) E.exports[name] = fn end,
            __index = function(_, resource) return (W.external[side] or {})[resource] end,
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
    local started = { sky_base = true, sky_jobs_base = true, oxmysql = true, ox_inventory = true }
    senv.GetResourceState = function(name) return started[name] and "started" or "missing" end
    senv.GetPlayers = function() return { "1" } end
    senv.GetPlayerPed = function() return 101 end
    senv.GetAllVehicles = function() return { VEH } end
    senv.DoesEntityExist = function(entity) return entity == VEH or entity == 101 end
    senv.GetEntityCoords = function(entity) return entity == VEH and W.veh.pos or W.player.pos end
    senv.GetEntityModel = function() return W.veh.model end
    senv.GetVehicleNumberPlateText = function() return W.veh.plate end
    senv.IsPlayerAceAllowed = function() return false end
    senv.NetworkGetEntityOwner = function() return W.vehOwner or 1 end
    senv.NetworkGetNetworkIdFromEntity = function() return NET end
    S.clientEvents = {}
    senv.TriggerClientEvent = function(name, target, ...)
        S.clientEvents[#S.clientEvents + 1] = { name = name, target = target, args = copy(table.pack(...)) }
    end
    senv.Sky = {
        Cb = { Register = function(name, fn) S.callbacks[name] = fn end },
        Config = { locale = "en", framework = "qb" },
        VehiclePropertyKeys = { mods = { [11] = "modEngine", [12] = "modBrakes", [13] = "modTransmission", [15] = "modSuspension", [16] = "modArmor" }, toggles = { [18] = "modTurbo", [22] = "modXenon" } },
        FW = {
            GetJob = function() return W.player.job end,
            GetIdentifier = function() return "CID1" end,
            GetName = function() return "Test Customer" end,
            GetJobData = function(_, key) if key == "duty" then return W.player.onDuty end return 0 end,
            GetAccountMoney = function(_, account) return W.player[account] or 0 end,
            AddAccountMoney = function(_, account, amount) W.player[account] = (W.player[account] or 0) + amount return true end,
            RemoveAccountMoney = function(_, account, amount)
                if (W.player[account] or 0) < amount then return false end
                W.player[account] = W.player[account] - amount
                return true
            end,
        },
    }
    senv.VehicleHistory = { Add = function(plate, kind, text) W.db.history[#W.db.history + 1] = { plate = plate, kind = kind, text = text } end }
    senv.VehiclePersistence = {
        IsDriver = function() return false end,
        IsOwner = function() return false end,
        SaveTuningState = function() return true end,
    }
    W.external = {
        server = {
            sky_jobs_base = {
                isOnDuty = function() return W.player.onDuty end,
                HasJobPermission = function() return true end,
                RemoveSocietyMoney = function(_, _, amount) if W.player.society < amount then return false end W.player.society = W.player.society - amount return true end,
                AddSocietyMoney = function(_, _, amount) W.player.society = W.player.society + amount return true end,
                GetJobConfiguratorJobNames = function() return {} end,
            },
            ox_inventory = {
                GetItemCount = function(_, _, item) return W.player.items[item] or 0 end,
                CanCarryItem = function() return true end,
                AddItem = function(_, _, item, count) W.player.items[item] = (W.player.items[item] or 0) + count return true end,
                RemoveItem = function(_, _, item, count)
                    if (W.player.items[item] or 0) < count then return false end
                    W.player.items[item] = W.player.items[item] - count
                    return true
                end,
            },
        },
        client = {},
    }

    -- Only the sky_mechanic_orders statements of server/main.lua, plus the ownership lookups.
    local function normalize(q) return (q:gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")) end
    local function orderById(id) for _, row in ipairs(W.db.orders) do if row.id == tonumber(id) then return row end end end
    local function isOpen(row) return row.status == "pending" or row.status == "in_progress" end
    local function sql(kind, q, params)
        q = normalize(q)
        params = params or {}
        if q:find("^INSERT INTO sky_mechanic_orders") then
            local row = {
                id = W.db.nextOrderId, job = params[1], customer_identifier = params[2], customer_name = params[3],
                plate = params[4], vehicle_model = params[5], vehicle_label = params[6], items = params[7],
                price = params[8], status = "pending", paid = 1, payment_method = params[9], payer_job = params[10],
                society_revenue = 0, created_at = "2026-10-15 12:00:00",
            }
            W.db.nextOrderId = W.db.nextOrderId + 1
            W.db.orders[#W.db.orders + 1] = row
            return row.id
        elseif q:find("^UPDATE sky_mechanic_orders SET society_revenue = %? WHERE id = %?") then
            local row = orderById(params[2])
            if row then row.society_revenue = params[1] end
            return row and 1 or 0
        elseif q:find("^SELECT COUNT%(%*%) AS count FROM sky_mechanic_orders WHERE job = %?") then
            local n = 0
            for _, row in ipairs(W.db.orders) do if row.job == params[1] then n = n + 1 end end
            return { count = n }
        elseif q:find("^SELECT %* FROM sky_mechanic_orders WHERE job = %?") then
            local rows = {}
            for _, row in ipairs(W.db.orders) do if row.job == params[1] then rows[#rows + 1] = copy(row) end end
            table.sort(rows, function(a, b)
                if isOpen(a) ~= isOpen(b) then return isOpen(a) end
                return a.id > b.id
            end)
            local limit, offset = q:match("LIMIT (%d+) OFFSET (%d+)")
            local out = {}
            for i = tonumber(offset) + 1, math.min(#rows, tonumber(offset) + tonumber(limit)) do out[#out + 1] = rows[i] end
            return out
        elseif q:find("^SELECT %* FROM sky_mechanic_orders WHERE id = %? AND job = %? LIMIT 1") then
            local row = orderById(params[1])
            return (row and row.job == params[2]) and copy(row) or nil
        elseif q:find("^SELECT %* FROM sky_mechanic_orders WHERE id = %? LIMIT 1") then
            local row = orderById(params[1])
            return row and copy(row) or nil
        elseif q:find("^SELECT id FROM sky_mechanic_orders WHERE id = %? AND job = %?") then
            local row = orderById(params[1])
            return (row and row.job == params[2]) and { id = row.id } or nil
        elseif q:find("^UPDATE sky_mechanic_orders SET status = 'refunded', paid = 0 WHERE id = %? AND job = %? AND status = 'pending' AND paid = 1") then
            local row = orderById(params[1])
            if row and row.job == params[2] and row.status == "pending" and row.paid == 1 then
                row.status, row.paid = "refunded", 0
                return 1
            end
            return 0
        elseif q:find("^UPDATE sky_mechanic_orders SET status = 'pending', paid = 1 WHERE id = %?") then
            local row = orderById(params[1])
            if row then row.status, row.paid = "pending", 1 return 1 end
            return 0
        elseif q:find("^DELETE FROM sky_mechanic_orders WHERE id = %? AND job = %?") then
            for i, row in ipairs(W.db.orders) do
                if row.id == tonumber(params[1]) and row.job == params[2] then
                    local items = row.items and row.items:match("^%s*(.-)%s*$") or ""
                    if row.status == "completed" or row.status == "refunded" or items == "" or items == "[]" or items == "{}" or items == "null" then
                        table.remove(W.db.orders, i)
                        return 1
                    end
                end
            end
            return 0
        elseif q:find("^UPDATE sky_mechanic_orders SET items = %?, status = %? WHERE id = %? AND items = %? AND status IN") then
            local row = orderById(params[3])
            if row and row.items == params[4] and isOpen(row) then
                row.items, row.status = params[1], params[2]
                return 1
            end
            return 0
        elseif q:find("player_vehicles") or q:find("owned_vehicles") then
            if q:find("^SELECT plate FROM") then
                return W.veh.owned and { { plate = W.veh.plate } } or {}
            end
            return kind == "query" and {} or nil
        elseif q:find("sky_jobs_creator_data") then
            return kind == "query" and {} or nil
        elseif q:find("sky_mechanic_vehicle_tuning") or q:find("sky_mechanic_stance_defaults") then
            return kind == "query" and {} or nil
        end
        error("unexpected query: " .. q)
    end
    senv.MySQL = {
        query = { await = function(q, p) return sql("query", q, p) end },
        single = { await = function(q, p) return sql("single", q, p) end },
        insert = { await = function(q, p) return sql("insert", q, p) end },
        update = { await = function(q, p) return sql("update", q, p) end },
        ready = function(fn) fn() end,
    }

    S.load("sky_mechanicjob/source/config_overrides.lua")
    S.load("sky_mechanicjob/config/init.lua")
    S.load("sky_mechanicjob/config/config.lua")
    S.load("sky_mechanicjob/config/adv_config.lua")
    S.load("sky_mechanicjob/config/sv_functions.lua")
    S.load("sky_mechanicjob/config/locales/en.lua")
    S.load("sky_mechanicjob/source/server/pricing.lua")
    S.load("sky_mechanicjob/source/server/tuning_db.lua")
    S.load("sky_mechanicjob/source/server/main.lua")

    -- ── client ──
    local C = newEnv("client")
    W.client = C
    local cenv = C.env
    cenv.GetResourceState = function(name) return (name == "sky_base" or name == "sky_jobs_base") and "started" or "missing" end
    cenv.PlayerPedId = function() return PED end
    cenv.PlayerId = function() return 0 end
    -- W.other: a second car parked in the workshop ({ entity, netId, plate, pos }).
    local function isOther(entity) return W.other ~= nil and entity == W.other.entity end
    cenv.GetEntityCoords = function(entity)
        if entity == PED then return W.player.pos end
        if entity == VEH then return W.veh.pos end
        if isOther(entity) then return W.other.pos end
        return W.objects[entity] and W.objects[entity].pos or vec(0, 0, 0)
    end
    cenv.DoesEntityExist = function(entity) return entity == PED or entity == VEH or isOther(entity) or W.objects[entity] ~= nil end
    cenv.IsEntityAVehicle = function(entity) return entity == VEH or isOther(entity) end
    cenv.IsEntityDead = function() return false end
    cenv.IsPedInAnyVehicle = function() return false end
    cenv.GetVehiclePedIsIn = function() return 0 end
    cenv.GetClosestVehicle = function(x, y, z, radius) return #(vec(x, y, z) - W.veh.pos) <= radius and VEH or 0 end
    cenv.GetGamePool = function() return W.other and { W.other.entity, VEH } or { VEH } end
    cenv.NetworkDoesNetworkIdExist = function(netId) return netId == NET or (W.other ~= nil and netId == W.other.netId) end
    cenv.NetworkGetEntityFromNetworkId = function(netId)
        if netId == NET then return VEH end
        return (W.other and netId == W.other.netId) and W.other.entity or 0
    end
    cenv.NetworkGetNetworkIdFromEntity = function(entity)
        if entity == VEH then return NET end
        return isOther(entity) and W.other.netId or 0
    end
    cenv.NetworkHasControlOfEntity = function() return W.hasControl ~= false end
    cenv.NetworkGetEntityIsNetworked = function() return true end
    cenv.NetworkRequestControlOfEntity = function() W.controlRequests = (W.controlRequests or 0) + 1 end
    cenv.GetEntityModel = function() return W.veh.model end
    cenv.GetDisplayNameFromVehicleModel = function() return "SULTAN" end
    cenv.GetLabelText = function() return "NULL" end
    cenv.GetModSlotName = function() return "" end
    cenv.GetModTextLabel = function() return "" end
    cenv.GetVehicleClass = function() return W.veh.class end
    cenv.GetVehicleNumberPlateText = function(entity) return isOther(entity) and W.other.plate or W.veh.plate end
    cenv.IsNuiFocused = function() return W.nuiFocused == true end
    cenv.GetModelDimensions = function() return vec(-1.0, -2.4, -0.6), vec(1.0, 2.4, 0.9) end
    cenv.GetOffsetFromEntityInWorldCoords = function(_, x, y, z) return W.veh.pos + vec(x, y, z) end
    cenv.GetEntityBoneIndexByName = function(_, name) return CAR_BONES[name] or -1 end
    cenv.GetWorldPositionOfEntityBone = function(_, index)
        for name, idx in pairs(CAR_BONES) do if idx == index then return W.veh.pos + BONE_POS[name] end end
        return W.veh.pos
    end
    cenv.GetNumVehicleMods = function(_, modType) return NUM_MODS[modType] or 0 end
    cenv.GetVehicleMod = function(_, modType) return W.veh.mods[modType] or -1 end
    cenv.SetVehicleMod = function(_, modType, index) W.veh.mods[modType] = index end
    cenv.GetVehicleModVariation = function() return false end
    cenv.SetVehicleModKit = function() end
    cenv.ToggleVehicleMod = function(_, modType, on) W.veh.toggles[modType] = on == true end
    cenv.IsToggleModOn = function(_, modType) return W.veh.toggles[modType] == true end
    cenv.GetVehicleWheelType = function() return W.veh.wheelType end
    cenv.SetVehicleWheelType = function(_, value) W.veh.wheelType = value end
    cenv.GetVehicleTyreSmokeColor = function() return 254, 254, 254 end
    cenv.GetVehicleXenonLightsColor = function() return -1 end
    cenv.GetVehicleXenonLightsCustomColor = function() return false, 0, 0, 0 end
    cenv.IsVehicleNeonLightEnabled = function() return false end
    cenv.GetVehicleNeonLightsColour = function() return 222, 222, 255 end
    cenv.GetVehicleColours = function() return 0, 0 end
    cenv.GetVehicleExtraColours = function() return 0, 0 end
    cenv.GetVehicleDashboardColour = function() return 0 end
    cenv.GetVehicleInteriorColour = function() return 0 end
    cenv.GetVehicleModColor_1 = function() return 0 end
    cenv.GetVehicleModColor_2 = function() return 0 end
    cenv.GetIsVehiclePrimaryColourCustom = function() return false end
    cenv.GetIsVehicleSecondaryColourCustom = function() return false end
    cenv.GetVehicleWindowTint = function() return 0 end
    cenv.GetVehicleLiveryCount = function() return -1 end
    cenv.GetVehicleLivery = function() return -1 end
    cenv.GetVehicleNumberPlateTextIndex = function() return 0 end
    cenv.DoesExtraExist = function() return false end
    cenv.IsVehicleExtraTurnedOn = function() return false end
    cenv.Entity = function() return { state = {} } end
    cenv.SetVehicleDoorOpen = function(_, index) if index == 4 and not W.hoodStuck then W.veh.hood = 1.0 end end
    cenv.SetVehicleDoorShut = function(_, index) if index == 4 then W.veh.hood = 0.0 end end
    cenv.GetVehicleDoorAngleRatio = function(_, index) return index == 4 and W.veh.hood or 0.0 end
    cenv.IsVehicleDoorDamaged = function() return false end
    cenv.IsModelInCdimage = function() return true end
    cenv.IsModelValid = function() return true end
    cenv.HasModelLoaded = function() return true end
    cenv.HasAnimDictLoaded = function() return true end
    cenv.IsEntityPlayingAnim = function() return false end
    cenv.CreateObjectNoOffset = function(_, x, y, z)
        W.nextObject = W.nextObject + 1
        W.objects[W.nextObject] = { pos = vec(x, y, z) }
        return W.nextObject
    end
    cenv.CreateObject = cenv.CreateObjectNoOffset
    cenv.DeleteEntity = function(entity) W.objects[entity] = nil end
    cenv.DeleteObject = cenv.DeleteEntity
    cenv.GetVehicleBodyHealth = function() return 1000.0 end
    cenv.GetVehicleEngineHealth = function() return 1000.0 end
    cenv.GetVehiclePetrolTankHealth = function() return 1000.0 end
    cenv.GetVehicleDirtLevel = function() return 0.0 end
    cenv.SendNUIMessage = function(message) C.messages[#C.messages + 1] = copy(message) end
    cenv.RegisterNUICallback = function(name, fn) C.nui[name] = fn end
    cenv.TriggerServerEvent = function(name, ...) C.serverEvents[#C.serverEvents + 1] = { name = name, args = copy(table.pack(...)) } end
    cenv.Sky = {
        Config = { locale = "en" },
        Debug = function() end,
        Math = { Trim = function(s) return (tostring(s):gsub("^%s+", ""):gsub("%s+$", "")) end },
        Load = { Model = function() end, AnimDict = function() end },
        Show = {
            Notification = function(_, message, kind) C.notifications[#C.notifications + 1] = { msg = message, kind = kind } end,
            HelpNotification = function(text, key) C.help = { text = text, key = key } end,
        },
        Cooldown = function() return true end,
        IsDebugActive = function() return false end,
        RegisterInput = function() end,
        CreateInteractionPoint = function() end,
        DeleteInteractionPoint = function() end,
        Vehicle = {
            new = function(vehicle)
                return {
                    GetVehicleProperties = function() return { plate = W.veh.plate, model = W.veh.model, mods = copy(W.veh.mods) } end,
                    SetVehicleProperties = function(_, props) W.restoredProps = (W.restoredProps or 0) + 1 end,
                }
            end,
        },
        Cb = {
            Register = function() end,
            Trigger = function(name, ...)
                C.calls = C.calls or {}
                C.calls[#C.calls + 1] = name
                if name == "sky_jobs_base:creator:getData" then
                    return { success = true, data = { entries = {} } }
                elseif name == "sky_jobs_base:getNuiImageBases" then
                    return {}
                end
                local args = copy(table.pack(...))
                return copy((assert(S.callbacks[name], "no server callback " .. name))(1, table.unpack(args, 1, args.n)))
            end,
        },
    }
    setmetatable(cenv.Sky, { __index = function() return stub end })
    cenv.Sky_Jobs = {
        Access = {
            GetJobKey = function() return W.player.job ~= "unemployed" and W.player.job or nil end,
            IsOnDuty = function() return W.player.job ~= "unemployed" and W.player.onDuty end,
            HasSnapshot = function() return true end,
            Refresh = function() end,
        },
        Tablet = { PushNotification = function() end },
    }
    cenv.CustomTuning = {
        GetCategoryByOptionId = function() return nil end,
        GetInstallFlowByOptionId = function() return nil end,
        UseVehicleSelections = function() end,
        EnsureBaseline = function() end,
        AddOptions = function() end,
        CaptureSessionState = function() end,
        RestoreSessionState = function() end,
        ApplyProfiles = function() return true end,
        BuildPersistedState = function() return nil end,
    }
    cenv.StanceKit = {
        IsVehicleMotorbike = function() return W.veh.class == 8 or W.veh.class == 13 end,
        IsVehicleStanceSupported = function() return false end,
        EnsureDefaultForVehicle = function() end,
        BuildPersistedState = function() return {} end,
        RestorePreviewState = function() end,
        EnsureRuntimeForVehicle = function() end,
        AddOptions = function() end,
        ApplyOption = function() return false end,
        ResetToDefault = function() return true end,
        PersistCurrent = function() end,
    }
    local function effectStub()
        return {
            AddOptions = function() end,
            ApplyOption = function() return false end,
            GetPersistedState = function() return nil end,
            ApplyPersistedStateToVehicle = function() end,
            IsInstalledForVehicle = function() return false end,
        }
    end
    cenv.AntiLag = effectStub()
    cenv.TwoStep = effectStub()
    cenv.VehiclePersistence = { SaveTuningState = function() return true end, SaveLights = function() return true end }

    C.load("sky_mechanicjob/source/config_overrides.lua")
    C.load("sky_mechanicjob/config/init.lua")
    C.load("sky_mechanicjob/config/config.lua")
    C.load("sky_mechanicjob/config/adv_config.lua")
    if opts.clientConfig then opts.clientConfig(cenv.Config) end
    C.load("sky_mechanicjob/config/locales/en.lua")
    C.load("sky_mechanicjob/source/client/state.lua")
    C.load("sky_mechanicjob/source/client/main.lua")
    C.load("sky_mechanicjob/source/client/tuning_minigames.lua")
    C.load("sky_mechanicjob/source/client/tuning.lua")
    C.load("sky_mechanicjob/source/client/radial_actions.lua")
    C.load("sky_mechanicjob/source/client/engine_swap.lua")
    C.load("sky_mechanicjob/source/client/orders.lua")
    C.load("sky_mechanicjob/source/client/change_parts.lua")
    C.load("sky_mechanicjob/source/client/wheel_change.lua")

    -- Files not under test (import.lua, spray_paint.lua).
    cenv.saveTuningForVehicle = function() W.saves = (W.saves or 0) + 1 end
    cenv.isRepaintOrderPart = function(part) return tostring(part and part.id or ""):find("^color_") ~= nil end

    function W.nui(name, payload)
        local reply
        assert(C.nui[name], "no NUI callback " .. name)
        W.run(function() C.nui[name](copy(payload or {}), function(res) reply = copy(res) end) end, "nui " .. name)
        return reply
    end

    function W.actions()
        local ids = {}
        for _, action in ipairs(C.exports.getRadialActions()) do ids[action.id] = true end
        return ids
    end

    function W.act(id)
        return W.run(function() return C.exports.triggerRadialMenuAction(id) end, "radial " .. id)
    end

    function W.lastMessage(action)
        for i = #C.messages, 1, -1 do
            local m = C.messages[i]
            if m.action == action or m.type == action then return m end
        end
        return nil
    end

    function W.lastNotification()
        local last = C.notifications[#C.notifications]
        return last and last.msg or nil
    end

    -- Resolves the engine swap minigame the way the NUI does once it has started.
    function W.playEngineSwap(success)
        return function()
            local start = W.lastMessage("engineSwap:minigame:start")
            assert(start, "engine swap minigame never started")
            W.nui("engineSwap:result", { token = start.payload.token, success = success ~= false, cancelled = false })
        end
    end

    function W.openSelfService()
        C.emit("sky_jobs_base:interaction:mechanic:self_service_tuning")
    end

    function W.becomeMechanic()
        W.player.job = "mechanic"
        W.player.onDuty = true
    end

    return W
end

local ORDER_DONE = "sky_mechanicjob:orders:completeInstall"

-- 1. A customer orders an engine and a turbo at the self-service point; the mechanic finds
--    the order in the tablet, connects the car and installs both parts from the radial menu.
do
    local W = newWorld()
    W.openSelfService()
    local C = W.client
    assert(C.env.TuningState.active == true and C.env.TuningState.selfServiceMode == true, "self-service tuning opened")
    local opened = W.lastMessage("open")
    assert(opened and opened.payload.tuning.options.mod_11, "engine option offered")
    assert(opened.payload.tuning.options.mod_11.prices["2"] > 0, "engine stage 3 has a price")

    assert(W.nui("tuning:apply", { id = "mod_11", value = 2 }).success == true, "engine previewed")
    assert(W.nui("tuning:apply", { id = "toggle_18", value = 1 }).success == true, "turbo previewed")
    assert(W.veh.mods[11] == 2 and W.veh.toggles[18] == true, "preview applied on the vehicle")

    local cashBefore = W.player.cash
    local bought = W.nui("tuning:purchase", { method = "cash" })
    assert(bought and bought.success == true, "purchase: " .. tostring(bought and bought.error))
    assert(#W.db.orders == 1, "one order saved")
    local order = W.db.orders[1]
    assert(order.job == "mechanic" and order.status == "pending" and order.price > 0, "pending workshop order with a price")
    assert(W.player.cash == cashBefore - order.price, "customer paid")
    local items = json.decode(order.items)
    assert(#items == 2 and items[1].id == "mod_11" and items[1].requiredItem == "engine" and items[2].id == "toggle_18", "order parts")
    assert(W.lastNotification() == "Order created successfully.", tostring(W.lastNotification()))
    assert(W.veh.mods[11] == -1 and W.veh.toggles[18] == false, "preview taken off again until the parts are installed")
    W.nui("close")
    assert(C.env.TuningState.active == false)

    -- The mechanic.
    W.becomeMechanic()
    local list = W.nui("orders:getAll", { page = 1, pageSize = 20, search = "" })
    assert(list and list.success == true, "orders listed: " .. tostring(list and list.error))
    assert(#list.data.orders == 1 and list.data.orders[1].status == "open" and #list.data.orders[1].parts == 2, "the order shows as open with its parts")

    assert(W.nui("tablet:setConnectedVehicle", { vehicleNetId = NET }).success == true, "vehicle connected")
    W.player.items.engine = 1
    W.player.items.turbo = 1

    local started = W.nui("orders:startInstall", { orderId = 1, partIndex = 1, vehicleNetId = NET })
    assert(started and started.success == true, "engine install started: " .. tostring(started and started.error))
    local state = C.env.OrderInstallState
    assert(state.active and state.requiredItem == "engine" and state.simpleStep == "open_hood", "engine swap starts with the hood")
    assert(C.env.resolveSimpleInstallFlow() == "engine_swap")

    assert(W.actions().open_hood, "radial offers Open Hood")
    assert(W.act("open_hood"), "hood opened")
    assert(W.veh.hood > 0.5 and state.simpleStep == "engine_swap", "next step: swap engine")
    assert(W.actions().engine_swap, "radial offers Swap Engine")

    W.onAwait = W.playEngineSwap(true)
    local ok, err = W.act("engine_swap")
    assert(ok, "engine swap: " .. tostring(err and err.fallback))
    assert(W.veh.mods[11] == 2, "the engine stage is on the vehicle")
    assert(json.decode(W.db.orders[1].items)[1].installed == true and W.db.orders[1].status == "in_progress", "part 1 installed on the order")
    assert((W.player.items.engine or 0) == 0, "engine item used up")
    assert(state.active == false, "install finished")
    assert(W.lastNotification() == "Part installed successfully.", tostring(W.lastNotification()))

    started = W.nui("orders:startInstall", { orderId = 1, partIndex = 2, vehicleNetId = NET })
    assert(started.success == true, "turbo install started: " .. tostring(started.error))
    assert(C.env.resolveSimpleInstallFlow() == "hood_install" and state.simpleStep == "open_hood")
    assert(W.act("open_hood"))
    assert(W.actions().install_order_part, "radial offers Install Part")
    assert(W.act("install_order_part"))
    assert(W.veh.toggles[18] == true, "turbo on the vehicle")
    assert(W.db.orders[1].status == "completed", "order completed")
    assert(W.lastNotification() == "Order completed successfully.", tostring(W.lastNotification()))
end

-- 2. The hood closes again before the swap (the vehicle's network owner syncs it shut): the
--    mechanic can still swap the engine.
do
    local W = newWorld({ job = "mechanic" })
    W.openSelfService()
    W.nui("tuning:apply", { id = "mod_11", value = 1 })
    assert(W.nui("tuning:purchase", { method = "card" }).success == true)
    W.nui("close")
    W.player.items.engine = 1
    assert(W.nui("tablet:setConnectedVehicle", { vehicleNetId = NET }).success == true)
    assert(W.nui("orders:startInstall", { orderId = 1, partIndex = 1, vehicleNetId = NET }).success == true)
    assert(W.act("open_hood"))
    W.veh.hood = 0.0 -- synced shut by the owner

    W.onAwait = W.playEngineSwap(true)
    local ok, err = W.act("engine_swap")
    assert(ok, "engine swap with a re-closed hood: " .. tostring(err and err.fallback))
    assert(W.veh.mods[11] == 1 and W.db.orders[1].status == "completed", "engine installed")
end

-- 3. The hood cannot be opened at all (no control over an occupied car): the swap says so and
--    the radial menu offers Open Hood again instead of a dead end at Swap Engine.
do
    local W = newWorld({ job = "mechanic" })
    W.openSelfService()
    W.nui("tuning:apply", { id = "mod_11", value = 3 })
    assert(W.nui("tuning:purchase", { method = "cash" }).success == true)
    W.nui("close")
    W.player.items.engine = 1
    assert(W.nui("tablet:setConnectedVehicle", { vehicleNetId = NET }).success == true)
    assert(W.nui("orders:startInstall", { orderId = 1, partIndex = 1, vehicleNetId = NET }).success == true)
    assert(W.act("open_hood"))
    W.veh.hood = 0.0
    W.hoodStuck = true

    W.onAwait = W.playEngineSwap(true)
    local ok, err = W.act("engine_swap")
    assert(not ok and err.fallback == "Open the hood from the radial menu before swapping the engine.", tostring(err and err.fallback))
    assert(W.client.env.OrderInstallState.simpleStep == "open_hood", "back at the hood step")
    assert(W.actions().open_hood and not W.actions().engine_swap, "Open Hood offered again")
    assert(W.lastMessage("wheelInstall:checklist:update").payload.steps[1].done == false, "checklist unticks the hood")

    W.hoodStuck = false
    assert(W.act("open_hood"))
    assert(W.act("engine_swap"), "engine swap after the second Open Hood")
    assert(W.veh.mods[11] == 3 and W.db.orders[1].status == "completed")
end

-- 4. Another player owns the vehicle (the customer sits in it): the server hands the installed
--    part to that player's client, which applies it; the installer's client applies it too.
do
    local W = newWorld({ job = "mechanic" })
    W.openSelfService()
    W.nui("tuning:apply", { id = "mod_13", value = 2 })
    assert(W.nui("tuning:purchase", { method = "cash" }).success == true)
    W.nui("close")
    W.player.items.transmission = 1
    W.vehOwner = 2
    assert(W.nui("tablet:setConnectedVehicle", { vehicleNetId = NET }).success == true)
    assert(W.nui("orders:startInstall", { orderId = 1, partIndex = 1, vehicleNetId = NET }).success == true)
    assert(W.act("open_hood"))
    assert(W.act("install_order_part"))
    assert(W.veh.mods[13] == 2, "applied by the installer")

    local relay = W.server.clientEvents[#W.server.clientEvents]
    assert(relay and relay.name == "sky_mechanicjob:orders:applyInstalledPart" and relay.target == 2, "part handed to the owner")
    assert(relay.args[1] == NET and relay.args[2].id == "mod_13" and relay.args[2].value == 2, "with the vehicle and the part")

    -- The owner's client receives it (the same resource files run there).
    W.veh.mods[13] = -1
    W.client.emit(relay.name, table.unpack(relay.args, 1, relay.args.n))
    assert(W.veh.mods[13] == 2, "applied on the owner's client")

    -- The installer's own client is not asked twice.
    W.vehOwner = 1
    W.veh.mods[13] = -1
    W.player.items.transmission = 1
    W.openSelfService()
    W.nui("tuning:apply", { id = "mod_13", value = 1 })
    assert(W.nui("tuning:purchase", { method = "cash" }).success == true)
    W.nui("close")
    local before = #W.server.clientEvents
    assert(W.nui("orders:startInstall", { orderId = 2, partIndex = 1, vehicleNetId = NET }).success == true)
    assert(W.act("open_hood") and W.act("install_order_part"))
    assert(#W.server.clientEvents == before, "no relay to the installer")
end

-- 5. Without network control the hood and the part still get control requests; the part is
--    applied locally either way.
do
    local W = newWorld({ job = "mechanic" })
    W.openSelfService()
    W.nui("tuning:apply", { id = "toggle_18", value = 1 })
    assert(W.nui("tuning:purchase", { method = "cash" }).success == true)
    W.nui("close")
    W.player.items.turbo = 1
    W.hasControl = false
    assert(W.nui("tablet:setConnectedVehicle", { vehicleNetId = NET }).success == true)
    assert(W.nui("orders:startInstall", { orderId = 1, partIndex = 1, vehicleNetId = NET }).success == true)
    assert(W.act("open_hood"))
    assert((W.controlRequests or 0) > 0, "control requested for the hood")
    local requests = W.controlRequests
    assert(W.act("install_order_part"))
    assert(W.controlRequests > requests, "control requested for the part")
    assert(W.veh.toggles[18] == true and W.db.orders[1].status == "completed")
end

-- An engine order for W.veh, bought at the self-service point, with the engine in the
-- mechanic's inventory.
local function engineOrder(W)
    W.openSelfService()
    W.nui("tuning:apply", { id = "mod_11", value = 1 })
    assert(W.nui("tuning:purchase", { method = "cash" }).success == true)
    W.nui("close")
    W.player.items.engine = 1
end

-- 6. Install without connecting a vehicle first: the button stayed grey until one was
--    connected. The order's own car is found by its plate and connected.
do
    local W = newWorld({ job = "mechanic" })
    engineOrder(W)
    assert(W.client.env.OrderTabletState.connectedVehicleNetId == 0, "nothing connected")
    local started = W.nui("orders:startInstall", { orderId = 1, partIndex = 1, vehicleNetId = 0 })
    assert(started and started.success == true, "started without a connected vehicle: " .. tostring(started and started.error))
    assert(W.client.env.OrderInstallState.vehicleNetId == NET and W.client.env.OrderTabletState.connectedVehicleNetId == NET, "the order's car is connected")
    assert(W.act("open_hood"))
    W.onAwait = W.playEngineSwap(true)
    assert(W.act("engine_swap"))
    assert(W.veh.mods[11] == 1 and W.db.orders[1].status == "completed", "installed on the order's car")
end

-- 7. Another car connected (parked next to the customer's): the part went on the connected
--    car while the order counted it as installed. It goes on the order's car now.
do
    local W = newWorld({ job = "mechanic" })
    engineOrder(W)
    W.other = { entity = 19, netId = 119, plate = "OTHER 1", pos = vec(3.0, 0.0, 0.0), mods = {} }
    assert(W.nui("tablet:setConnectedVehicle", { vehicleNetId = 119 }).success == true, "the other car connected")
    local started = W.nui("orders:startInstall", { orderId = 1, partIndex = 1, vehicleNetId = 119 })
    assert(started.success == true, tostring(started.error))
    assert(W.client.env.OrderInstallState.vehicleNetId == NET, "installing on the order's car, not the connected one")
    assert(W.client.env.OrderTabletState.connectedVehicleNetId == NET, "the order's car is connected instead")
end

-- 8. The order's car is not near the mechanic: the tablet is told so (with the plate) and
--    nothing starts.
do
    local W = newWorld({ job = "mechanic" })
    engineOrder(W)
    W.veh.pos = vec(17.0, 0.0, 0.0) -- in the server's 20 m, beyond the 15 m to work on it
    local started = W.nui("orders:startInstall", { orderId = 1, partIndex = 1, vehicleNetId = 0 })
    assert(started.success == false and started.error == "vehicle_not_found" and started.plate == "TEST 123", tostring(started.error))
    assert(W.client.env.OrderInstallState.active == false, "no install started")
end

-- 9. Next to the vehicle of an active install a prompt names the radial menu key and the next
--    step; the tablet used to say "Press E", which did nothing.
do
    local W = newWorld({ job = "mechanic" })
    engineOrder(W)
    assert(W.nui("orders:startInstall", { orderId = 1, partIndex = 1, vehicleNetId = 0 }).success == true)
    local C = W.client
    W.player.pos = vec(0.0, 3.4, 0.0) -- at the front
    assert(C.env.showOrderInstallStepPrompt() == true, "prompt next to the car")
    assert(C.help.text == "Radial menu: Open Hood" and C.help.key == "G", tostring(C.help.text) .. " / " .. tostring(C.help.key))

    assert(W.act("open_hood"))
    W.clock = W.clock + 1000
    assert(C.env.showOrderInstallStepPrompt() == true and C.help.text == "Radial menu: Swap Engine", tostring(C.help.text))

    W.nuiFocused = true -- the radial menu or a minigame is open
    assert(C.env.showOrderInstallStepPrompt() == false)
    W.nuiFocused = false
    W.player.pos = vec(0.0, 12.0, 0.0)
    assert(C.env.showOrderInstallStepPrompt() == false, "no prompt away from the car")

    -- No install: no prompt.
    W.player.pos = vec(0.0, 3.4, 0.0)
    assert(W.act("cancel_order_install"))
    assert(C.env.showOrderInstallStepPrompt() == false)
end

print("PASS: tuning orders from the self-service menu, the Orders tablet, connecting the vehicle, engine swap (hood, minigame) and turbo installs, order completion, a hood synced shut, the Open Hood step offered again, parts handed to the vehicle's owner, control requests, Install without a connected vehicle, the order's car used over a connected other car, the order's car out of reach, the radial menu prompt at the vehicle.")
