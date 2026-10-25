-- Run from the workspace root: lua tests/db_migrate_spec.lua
-- Runs sky_mechanicjob's schema migration against a fake MySQL 8 database: tables from an older
-- schema get their missing columns without the MariaDB-only "ADD COLUMN IF NOT EXISTS".

local function run(schema, kvp)
    local db = { queries = {}, kvp = kvp or {}, logs = {} }
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
            -- A column is its name (nullable text) or { name, type, nullable, default, key, extra, charset, collation }.
            if query:find("information_schema") then
                local rows = {}
                for _, column in ipairs(schema[params[1]] or {}) do
                    if type(column) == "string" then column = { name = column } end
                    rows[#rows + 1] = {
                        column_name = column.name, column_type = column.type or "longtext",
                        is_nullable = column.nullable == false and "NO" or "YES", column_default = column.default,
                        column_key = column.key or "", extra = column.extra or "",
                        character_set_name = column.charset, collation_name = column.collation
                    }
                end
                return rows
            end
            local tableName, column = query:match("^ALTER TABLE `([^`]+)` ADD COLUMN `([^`]+)`")
            if tableName then
                for _, existing in ipairs(schema[tableName] or {}) do
                    if (type(existing) == "table" and existing.name or existing) == column then error("Duplicate column name '" .. column .. "'") end
                end
                table.insert(schema[tableName], column)
            end
            local modifiedTable, modifiedColumn = query:match("^ALTER TABLE `([^`]+)` MODIFY COLUMN `([^`]+)` .- NULL$")
            if modifiedTable then
                for _, existing in ipairs(schema[modifiedTable] or {}) do
                    if type(existing) == "table" and existing.name == modifiedColumn then existing.nullable = true end
                end
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

-- A history table without the date column the history tablet sorts by, on a server that
-- already stored schema version 4.
schema = { sky_mechanic_vehicle_history = { "id", "plate", "action", "description", "mechanic_identifier", "mechanic_name", "price" } }
db = run(schema, { sky_mechanicjob_schema_version = "4" })
local history = {}
for _, column in ipairs(schema.sky_mechanic_vehicle_history) do history[column] = true end
assert(history.date, "the date column was added after schema version 4")
for _, log in ipairs(db.logs) do assert(log.level ~= "error", "no errors: " .. log.msg) end

-- A tuning table from an older version with a required column this resource never writes, on a
-- server that already stored schema version 5. Next to it columns that stay as they are: an
-- auto-increment key, a required column with a default and a nullable one.
local properties = { name = "properties", nullable = false, type = "longtext", charset = "utf8mb4", collation = "utf8mb4_general_ci" }
schema = {
    sky_mechanic_vehicle_tuning = {
        { name = "id", nullable = false, type = "int(11)", key = "PRI", extra = "auto_increment" },
        "plate", "tuning", "stance", "rgb", "nitro", "custom_handling", properties,
        { name = "owner", nullable = false, type = "varchar(64)", default = "" },
        { name = "notes", type = "text" },
    }
}
db = run(schema, { sky_mechanicjob_schema_version = "5" })
assert(count(db, "MODIFY COLUMN") == 1, "only the required column without a default is changed")
assert(count(db, "^ALTER TABLE `sky_mechanic_vehicle_tuning` MODIFY COLUMN `properties` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL$") == 1,
    "the properties column accepts NULL and keeps its type and collation")
assert(properties.nullable == true, "the properties column is nullable")
for _, log in ipairs(db.logs) do assert(log.level ~= "error", "no errors: " .. log.msg) end
assert(db.kvp.sky_mechanicjob_schema_version == "6", "schema version 6 stored")

-- The next start finds nothing left to change.
db = run(schema, {})
assert(count(db, "MODIFY COLUMN") == 0, "a nullable column is not changed again")

print("PASS: the schema migration adds missing columns on MySQL (no MariaDB-only statements) and leaves complete tables alone; a history table gets its date column; a required column of an older table that the resource never writes accepts NULL.")
