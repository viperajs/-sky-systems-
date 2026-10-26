-- Run from the workspace root: lua tests/job_storage_spec.lua
-- sky_jobs_base's DepositToJobStorage: parts deliveries unpacked into a workshop storage land in
-- that station's ox_inventory stash, all or nothing, within the storage's capacity.

local stub
stub = setmetatable({}, { __index = function() return stub end, __call = function() return stub end })

local stashes, registered = {}, {}
local refuse = {}
local ox = {
    RegisterStash = function(_, name) registered[name] = true end,
    GetInventoryItems = function(_, inv)
        local list = {}
        for name, count in pairs(stashes[inv] or {}) do list[#list + 1] = { name = name, count = count } end
        return list
    end,
    AddItem = function(_, inv, name, count)
        if refuse[name] then return false end
        stashes[inv] = stashes[inv] or {}
        stashes[inv][name] = (stashes[inv][name] or 0) + count
        return true
    end,
    RemoveItem = function(_, inv, name, count)
        stashes[inv][name] = stashes[inv][name] - count
        if stashes[inv][name] == 0 then stashes[inv][name] = nil end
        return true
    end,
}

local exported = {}
local env = setmetatable({}, { __index = function(_, key)
    local value = _G[key]
    if value ~= nil or key == "Config" or key == "Sky_Jobs" then return value end
    return stub
end })
env._G = env
env.Config = { Storage = { storageCapacity = 0 } }
env.Sky_Jobs = {
    GetJobDefinition = function() return nil end,
    Configurator = { LoadWorkshopData = function()
        return { entries = { { id = "mechanic_lscustoms", jobKey = "mechanic", storageCapacity = 10 }, { id = "police_mrpd", jobKey = "police" } } }
    end },
}
env.GetResourceState = function(name) return name == "ox_inventory" and "started" or "missing" end
env.exports = setmetatable({}, {
    __call = function(_, name, fn) exported[name] = fn end,
    __index = function(_, resource) return resource == "ox_inventory" and ox or stub end,
})
env.Sky = { Cb = { Register = function() end } }
env.MySQL = { query = { await = function() return {} end } }
env.AddEventHandler = function() end
assert(loadfile("sky_jobs_base/source/server/storage.lua", "t", env))()
local deposit = assert(exported.DepositToJobStorage, "DepositToJobStorage export missing")
local stash = "skyjobs_st_mechanic_mechanic_lscustoms"

-- 1. The parts land in the station's stash.
local ok, err = deposit("mechanic", "mechanic_lscustoms", { { name = "brakes", count = 2 }, { name = "turbo", count = 1 } })
assert(ok == true and registered[stash], tostring(err))
assert(stashes[stash].brakes == 2 and stashes[stash].turbo == 1)

-- 2. Over the storage's capacity (10 items) nothing goes in.
ok, err = deposit("mechanic", "mechanic_lscustoms", { { name = "brakes", count = 8 } })
assert(ok == false and err == "storageFull" and stashes[stash].brakes == 2, "over capacity")

-- 3. A part the stash refuses takes back the ones already added.
refuse.engine = true
ok, err = deposit("mechanic", "mechanic_lscustoms", { { name = "brakes", count = 1 }, { name = "engine", count = 1 } })
assert(ok == false and err == "storageFull" and stashes[stash].brakes == 2 and stashes[stash].engine == nil, "not rolled back")

-- 4. Another job's station, an unknown station and bad counts are refused.
assert(select(2, deposit("mechanic", "police_mrpd", { { name = "brakes", count = 1 } })) == "unknown_station")
assert(select(2, deposit("mechanic", "nowhere", { { name = "brakes", count = 1 } })) == "unknown_station")
assert(select(2, deposit("mechanic", "mechanic_lscustoms", { { name = "brakes", count = 0 } })) == "invalid")

print("PASS: job storage deposits land in the station's stash, all or nothing, within its capacity, only for the job's own stations.")
