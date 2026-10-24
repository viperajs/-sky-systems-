-- Run from the workspace root: lua tests/db_migrate_spec.lua
-- Runs sky_mechanicjob's schema migration against a fake MySQL 8 database: tables from an older
-- schema get their missing columns without the MariaDB-only "ADD COLUMN IF NOT EXISTS".

local function run(schema)
    local db = { queries = {}, kvp = {}, logs = {} }
    local env = setmetatable({}, { __index = _G })
    env.Config = {}
    env.Functions = { Log = function(level, msg, ...) db.logs[#db.logs + 1] = { level = level, msg = msg:format(...) } end }
    env.GetResourceKvpString = function(key) return db.kvp[key] end
    env.SetResourceKvp = function(key, value) db.kvp[key] = value end
    env.Wait = function() end
    env.CreateThread = function(fn) fn() end
    env.MySQL = {
        ready = function(fn) fn() end,
        query = { await = function(query, params)
            db.queries[#db.queries + 1] = query
            if query:find("IF NOT EXISTS`?%s") and query:find("^%s*ALTER") then
                error("You have an error in your SQL syntax (MySQL 8)")
            end
            -- A table created now has every column of its CREATE statement.
            local created = query:match("CREATE TABLE IF NOT EXISTS `([^`]+)`")
            if created and not schema[created] then
                schema[created] = {}
                for line in query:gmatch("[^\n]+") do
                    local column = line:match("^%s*`([^`]+)`")
                    if column then table.insert(schema[created], column) end
                end
            end
            if query:find("information_schema") then
                local rows = {}
                for _, column in ipairs(schema[params[1]] or {}) do rows[#rows + 1] = { COLUMN_NAME = column } end
                return rows
            end
            local tableName, column = query:match("^ALTER TABLE `([^`]+)` ADD COLUMN `([^`]+)`")
            if tableName then
                for _, existing in ipairs(schema[tableName] or {}) do
                    if existing == column then error("Duplicate column name '" .. column .. "'") end
                end
                table.insert(schema[tableName], column)
            end
            return {}
        end },
    }
    assert(loadfile("sky_mechanicjob/source/server/db_migrate.lua", "t", env))()
    return db
end

local function count(db, pattern)
    local n = 0
    for _, query in ipairs(db.queries) do if query:find(pattern) then n = n + 1 end end
    return n
end

-- An orders table from an older version: everything but the payment columns.
local schema = {
    sky_mechanic_orders = { "id", "job", "plate", "items", "status" },
    sky_mechanic_vehicle_tuning = { "plate", "tuning", "stance", "rgb", "nitro", "custom_handling" },
}
local db = run(schema)
assert(count(db, "IF NOT EXISTS`") == 0 and count(db, "ADD COLUMN IF NOT EXISTS") == 0, "no MariaDB-only statements")
local orders = {}
for _, column in ipairs(schema.sky_mechanic_orders) do orders[column] = true end
assert(orders.paid and orders.payment_method and orders.payer_job and orders.society_revenue, "the payment columns were added")
assert(count(db, "ALTER TABLE `sky_mechanic_vehicle_tuning`") == 0, "a complete table is left alone")
for _, log in ipairs(db.logs) do assert(log.level ~= "error", "no errors: " .. log.msg) end
assert(db.kvp.sky_mechanicjob_schema_version ~= nil, "schema version stored")

print("PASS: the schema migration adds missing columns on MySQL (no MariaDB-only statements) and leaves complete tables alone.")
