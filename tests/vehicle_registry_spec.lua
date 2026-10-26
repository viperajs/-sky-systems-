-- Run from the workspace root: lua tests/vehicle_registry_spec.lua
-- The mechanic tablet's Vehicle Registry: the Service History carries the fields the tablet
-- shows (what was done, when, by whom), each vehicle lists its workshop orders, and the search
-- also looks at tags and orders.

local stub
stub = setmetatable({}, { __index = function() return stub end, __call = function() return stub end })

local callbacks, queries = {}, {}
local history = {
    { id = 7, plate = "ABC123", action = "part_installed", description = "Installed: Turbo (Order #12)", mechanic_identifier = "CID1", mechanic_name = "Rezan Petrov", price = 0, date = 1793059200000 },
    { id = 6, plate = "ABC123", action = "tuning_direct", description = "Direct tuning applied (3 modifications)", mechanic_identifier = "CID1", mechanic_name = "Rezan Petrov", price = 4500, date = 1793055600000 },
}
local orders = {
    { id = 12, plate = "ABC123 ", status = "completed", price = 5000, paid = 1, created_ts = 1793059200 },
    { id = 13, plate = "abc123", status = "pending", price = 900, paid = 1, created_ts = 1793062800 },
    { id = 14, plate = "XYZ999", status = "refunded", price = 300, paid = 0, created_ts = 1793066400 },
}

local env = setmetatable({}, { __index = function(_, key)
    local value = _G[key]
    if value ~= nil or key == "VehicleHistory" then return value end
    return stub
end })
env._G = env
env.exports = function() end
env.json = {
    encode = function() return "[]" end,
    decode = function(text) return text == "[\"vip\"]" and { "vip" } or {} end,
}
env.Sky = {
    Cb = { Register = function(name, fn) callbacks[name] = fn end },
    Math = { Trim = function(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end },
    Currency = { Format = function(amount) return ("$%d"):format(amount) end },
}
env.Functions = {
    IsMechanicOnDuty = function() return true end,
    GetFramework = function() return "qbox" end,
    GetName = function(id) return id == "CID9" and "Customer Nine" or nil end,
    GetJob = function() return "mechanic" end,
}
env.MySQL = {
    query = { await = function(query, params)
        queries[#queries + 1] = { query = query, params = params }
        if query:find("FROM sky_mechanic_vehicle_history", 1, true) then return history end
        if query:find("FROM player_vehicles pv", 1, true) then
            return {
                { plate = "ABC123", model = "sultan", owner = "CID9", tags = "[\"vip\"]", notes = nil, mileage = 12.4 },
                { plate = "XYZ999", model = "futo", owner = "CID9" },
            }
        end
        if query:find("FROM sky_mechanic_orders", 1, true) then
            assert(params[#params] == "mechanic", "orders of another workshop")
            local wanted, rows = {}, {}
            for i = 1, #params - 1 do wanted[params[i]] = true end
            for _, order in ipairs(orders) do
                if wanted[(order.plate:gsub("%s+$", "")):upper()] then rows[#rows + 1] = order end
            end
            table.sort(rows, function(a, b) return a.id > b.id end)
            return rows
        end
        return {}
    end },
    single = { await = function(query, params)
        queries[#queries + 1] = { query = query, params = params }
        return { count = 2 }
    end },
}

assert(loadfile("sky_mechanicjob/source/server/vehicle_history.lua", "t", env))()
assert(loadfile("sky_mechanicjob/source/server/vehicles.lua", "t", env))()

-- 1. Service History entries name the work, the date and the mechanic.
local res = callbacks["sky_mechanicjob:vehicles:getHistory"](1, { plate = "abc123" })
assert(res.success and #res.data.history == 2)
local installed, direct = res.data.history[1], res.data.history[2]
assert(installed.actionLabel == "Installed: Turbo (Order #12)" and installed.actionType == "part_installed")
assert(installed.createdAt == 1793059200000 and installed.performedByName == "Rezan Petrov")
assert(direct.actionLabel == "Direct tuning applied (3 modifications) · $4500", "the price is shown with the work")

-- 2. Each vehicle lists its own workshop orders (plates compared trimmed and upper case).
res = callbacks["sky_mechanicjob:vehicles:getRegistry"](1, { page = 1, pageSize = 20, search = "" })
assert(res.success and #res.data.vehicles == 2)
local abc, xyz = res.data.vehicles[1], res.data.vehicles[2]
assert(#abc.orders == 2 and abc.orders[1].orderUid == "#13" and abc.orders[1].status == "open" and abc.orders[1].amountPaid == 900)
assert(abc.orders[2].orderUid == "#12" and abc.orders[2].status == "completed" and abc.orders[2].amountPaid == 5000)
assert(type(abc.orders[1].createdAt) == "string" and abc.orders[1].createdAt:match("^%d%d%d%d%-%d%d%-%d%d %d%d:%d%d$"))
assert(#xyz.orders == 1 and xyz.orders[1].status == "refunded" and xyz.orders[1].amountPaid == 0)
assert(abc.tags[1] == "vip" and abc.owner_name == "Customer Nine")

-- 3. The search looks at tags and the workshop's orders too, and the count matches the list.
queries = {}
callbacks["sky_mechanicjob:vehicles:getRegistry"](1, { page = 1, pageSize = 20, search = "#12" })
local listQuery, countQuery
for _, q in ipairs(queries) do
    if q.query:find("FROM player_vehicles pv", 1, true) then
        if q.query:find("COUNT%(%*%)") then countQuery = q.query else listQuery = q.query end
    end
end
for _, q in ipairs({ listQuery, countQuery }) do
    assert(q and q:find("r.tags LIKE @search", 1, true), "search ignores tags")
    assert(q:find("o.customer_name LIKE @search", 1, true) and q:find("CONCAT('#', o.id) LIKE @search", 1, true), "search ignores orders")
end
assert(countQuery:find("LEFT JOIN sky_mechanic_vehicle_registry r", 1, true), "the count cannot see the tags")

print("PASS: vehicle registry Service History shows the work, date, price and mechanic; linked workshop orders per vehicle; search by tags, customer and order number.")
