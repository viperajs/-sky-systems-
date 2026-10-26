-- Run from the workspace root: lua tests/chat_spec.lua
-- Drives sky_jobs_base's tablet chat callbacks against an in-memory chat table: a colleague
-- outside the caller's job roster who wrote first can be answered and shows up by name in the
-- chat directory, strangers still cannot be messaged, and profile photos are stored and listed.

local stub
stub = setmetatable({}, { __index = function() return stub end, __call = function() return stub end })

local db = { messages = {}, profiles = {}, nextId = 1 }
local callbacks, clientEvents = {}, {}

-- Server id -> character: the caller is a mechanic; John Smith is police (the mechanic
-- job only on his side, e.g. as a secondary job, so the caller's roster does not list him).
local players = {
    [1] = { citizenid = "AAA", name = "Rezan Petrov", job = "mechanic", grade = 1 },
    [2] = { citizenid = "BBB", name = "John Smith", job = "police", grade = 2 },
}
local jobUsers = {
    mechanic = { { identifier = "AAA", job_grade = 1, name = "Rezan Petrov" } },
    police = { { identifier = "BBB", job_grade = 2, name = "John Smith" }, { identifier = "AAA", job_grade = 0, name = "Rezan Petrov" } },
}

local function byCitizen(id)
    for src, p in pairs(players) do if p.citizenid == id then return src, p end end
end

local env = setmetatable({}, { __index = function(_, key)
    local value = _G[key]
    if value ~= nil or key == "Config" or key == "Locales" then return value end
    return stub
end })
env._G = env
env.print = function() end
env.CreateThread = function() end
env.SetTimeout = function() end
env.Wait = function() end
env.GetGameTimer = function() return os.time() * 1000 + db.nextId * 1000 end
env.GetResourceState = function(name) return name == "oxmysql" and "started" or "missing" end
env.AddEventHandler = function() end
env.RegisterNetEvent = function() end
env.RegisterCommand = function() end
env.TriggerEvent = function() end
env.TriggerClientEvent = function(name, target, payload) clientEvents[#clientEvents + 1] = { name = name, target = target, payload = payload } end
env.GetPlayers = function()
    local list = {}
    for src in pairs(players) do list[#list + 1] = tostring(src) end
    return list
end
env.GetPlayerName = function(src) return players[tonumber(src)] and "steam" or nil end
env.IsPlayerAceAllowed = function() return false end
env.GetConvar = function(_, default) return default end
env.exports = setmetatable({}, { __call = function() end, __index = function() return stub end })
env.json = { encode = function() return "{}" end, decode = function() return {} end }
env.Sky = {
    Cb = { Register = function(name, fn) callbacks[name] = fn end },
    FW = {
        GetIdentifier = function(src) return players[src] and players[src].citizenid end,
        GetName = function(src) return players[tonumber(src)] and players[tonumber(src)].name end,
        GetJob = function(srcOrId)
            local p = players[tonumber(srcOrId)] or select(2, byCitizen(srcOrId))
            -- Offline characters come from the framework's database.
            return p and p.job or (srcOrId == "BBB" and "police") or ""
        end,
        GetJobData = function(src, key)
            local p = players[src]
            if key == "grade" then return p and p.grade end
            if key == "duty" then return true end
        end,
        GetJobUsers = function(job) return jobUsers[job] or {} end,
        GetJobs = function()
            return {
                mechanic = { label = "Mechanic", grades = { ["0"] = { name = "Trainee" }, ["1"] = { name = "Mechanic" } } },
                police = { label = "LSPD", grades = { ["2"] = { name = "Sergeant" } } },
            }
        end,
    },
}

local function insertMessage(params)
    db.messages[#db.messages + 1] = {
        id = db.nextId, chat_id = params[1], sender_identifier = params[2], recipient_identifier = params[3],
        sender_name = params[4], message = params[5], timestamp = params[6], is_read = 0, image_url = params[7],
    }
    db.nextId = db.nextId + 1
    return db.nextId - 1
end

env.MySQL = {
    query = { await = function(query, params)
        if query:find("FROM sky_jobs_chat_profiles WHERE identifier IN", 1, true) then
            local rows = {}
            for _, id in ipairs(params) do
                if db.profiles[id] then rows[#rows + 1] = { identifier = id, image_url = db.profiles[id] } end
            end
            return rows
        end
        if query:find("INSERT INTO sky_jobs_chat_profiles", 1, true) then
            db.profiles[params[1]] = params[2]
            return {}
        end
        if query:find("WHERE recipient_identifier IS NOT NULL AND (sender_identifier = ? OR recipient_identifier = ?)", 1, true) then
            local rows = {}
            for i = #db.messages, 1, -1 do
                local m = db.messages[i]
                if m.recipient_identifier and (m.sender_identifier == params[1] or m.recipient_identifier == params[2]) then
                    rows[#rows + 1] = m
                end
            end
            return rows
        end
        if query:find("FROM sky_jobs_chat_messages WHERE chat_id = ? ORDER BY id DESC", 1, true) then
            local rows = {}
            for i = #db.messages, 1, -1 do
                if db.messages[i].chat_id == params[1] then rows[#rows + 1] = db.messages[i] end
            end
            return rows
        end
        return {}
    end },
    single = { await = function(query, params)
        if query:find("FROM sky_jobs_chat_messages WHERE chat_id = ? AND sender_identifier = ?", 1, true) then
            for _, m in ipairs(db.messages) do
                if m.chat_id == params[1] and m.sender_identifier == params[2] then return { present = 1 } end
            end
            return nil
        end
        return nil
    end },
    insert = { await = function(query, params)
        if query:find("INSERT INTO sky_jobs_chat_messages", 1, true) then return insertMessage(params) end
        return 1
    end },
    update = { await = function(query, params)
        if query:find("DELETE FROM sky_jobs_chat_profiles", 1, true) then db.profiles[params[1]] = nil end
        return 1
    end },
}

local function load(path) assert(loadfile(path, "t", env))() end
env.Sky_Jobs = {}
load("sky_jobs_base/config/init.lua")
load("sky_jobs_base/config/config.lua")
load("sky_jobs_base/source/server/jobs.lua")

local send = assert(callbacks["sky_jobs_base:chat:sendMessage"])
local directory = assert(callbacks["sky_jobs_base:getAllJobMembers"])
local management = assert(callbacks["sky_jobs_base:getJobMembers"])
local setPhoto = assert(callbacks["sky_jobs_base:chat:setProfilePhoto"])

-- 1. John (police) writes to the mechanic, who is on the police roster on his side.
local res = send(2, { scope = "private", target = "AAA", message = "rezan" })
assert(res.success, "John could not write: " .. tostring(res.error))

-- 2. The mechanic answers him although John is not on the mechanic roster.
res = send(1, { scope = "private", target = "BBB", message = "she ti eba guza" })
assert(res.success, "the reply was refused: " .. tostring(res.error))
assert(db.messages[2].chat_id == db.messages[1].chat_id and db.messages[2].recipient_identifier == "BBB")

-- 3. Someone who never wrote and is not a colleague still cannot be messaged.
res = send(1, { scope = "private", target = "ZZZ", message = "hi" })
assert(not res.success and res.error == "not_a_member", "a stranger could be messaged")

-- 4. The chat directory names John (with his own job), so the chat list stops saying
--    "Unknown staff member"; the management roster stays the job's own members.
res = directory(1)
assert(res.success)
local john
for _, row in ipairs(res.data) do if row.identifier == "BBB" then john = row end end
assert(john and john.name == "John Smith" and john.job == "police" and john.job_label == "LSPD", "John missing from the chat directory")
assert(john.grade_label == "Sergeant" and john.isOnline and not john.is_self)
for _, row in ipairs(management(1).data) do assert(row.identifier ~= "BBB", "John listed in the management roster") end

-- An offline partner keeps the name he signed his messages with.
players[2] = nil
res = directory(1)
john = nil
for _, row in ipairs(res.data) do if row.identifier == "BBB" then john = row end end
assert(john and john.name == "John Smith" and not john.isOnline and john.job == "police")
-- ...and can still be answered.
assert(send(1, { scope = "private", target = "BBB", message = "later" }).success)

-- 5. Profile photos: stored per character, listed with the members, only from upload hosts.
res = setPhoto(1, { image_url = "https://r2.fivemanage.com/abc/photo.jpg" })
assert(res.success and res.data.image_url == "https://r2.fivemanage.com/abc/photo.jpg", tostring(res.error))
local me
for _, row in ipairs(directory(1).data) do if row.is_self then me = row end end
assert(me and me.image_url == "https://r2.fivemanage.com/abc/photo.jpg", "the profile photo is not listed")
res = setPhoto(1, { image_url = "https://evil.example.com/x.jpg" })
assert(not res.success and res.error == "invalid_url")
assert(setPhoto(1, { image_url = "" }).success and db.profiles.AAA == nil, "the profile photo was not removed")

print("PASS: private chat replies to a colleague outside the roster who wrote first, strangers refused, chat partners named in the chat directory (online and offline), profile photos stored, listed and checked.")
