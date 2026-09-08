if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/modules/Security.lua") end
-- =====================================================
--  sky_base · source/client/modules/Security.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Security = {}

local isCooldownActive = false
local queues = {}
local DEFAULT_QUEUE_LIMIT = 1

local function resolveResource(resName)
    if resName and resName ~= "" then
        return resName
    end
    return GetInvokingResource() or GetCurrentResourceName()
end

--- Action cooldown helper.
---@param ms number
---@param silent? boolean
---@return boolean
function Sky.Security.Cooldown(ms, silent)
    if not isCooldownActive then
        CreateThread(function()
            isCooldownActive = true
            Wait(ms)
            isCooldownActive = false
        end)
        return true
    else
        if not silent then
            local locales = Locales or {}
            local title = locales.cooldown or "Cooldown"
            local msg = locales.waitSomeSeconds or "Please wait a few seconds before trying again."
            Sky.Show.Notification(title, msg, "warning", 3000)
        end
        return false
    end
end

--- Enqueues a job into a resource job queue.
---@param id string
---@param options? table
---@return boolean, string, table|nil
function Sky.Security.Queue(id, options)
    if not id then
        return false, "missing_id"
    end

    options = options or {}
    local resource = resolveResource(options.resource)
    if not resource then
        return false, "unknown_resource"
    end

    local resQueue = queues[resource]
    local limit = tonumber(options.limit) or (resQueue and resQueue.limit) or DEFAULT_QUEUE_LIMIT

    if not resQueue then
        resQueue = {
            items = {},
            lookup = {},
            limit = limit
        }
        queues[resource] = resQueue
    else
        resQueue.limit = limit
    end

    if resQueue.lookup[id] then
        return true, "already_queued", resQueue.lookup[id]
    end

    if #resQueue.items >= resQueue.limit then
        return false, "full"
    end

    local item = {
        id = id,
        payload = options.payload,
        handler = options.handler
    }

    resQueue.lookup[id] = item
    table.insert(resQueue.items, item)

    local status = (#resQueue.items == 1) and "active" or "queued"
    return true, status, item
end

local processNextJob

--- Dequeues a job from the resource queue.
---@param id? string
---@param options? table
---@return table|nil, table|nil
function Sky.Security.Dequeue(id, options)
    options = options or {}
    local resource = resolveResource(options.resource)
    if not resource then return nil end

    local resQueue = queues[resource]
    if not resQueue then return nil end

    local index = 1
    if id ~= nil then
        local item = resQueue.lookup[id]
        if not item then return nil end
        for idx, itemRef in ipairs(resQueue.items) do
            if itemRef == item then
                index = idx
                break
            end
        end
    end

    local removedItem = table.remove(resQueue.items, index)
    if not removedItem then return nil end

    resQueue.lookup[removedItem.id] = nil
    local nextJob = resQueue.items[1]

    if #resQueue.items == 0 then
        queues[resource] = nil
    end

    return removedItem, nextJob
end

processNextJob = function(resource, job)
    if not job or type(job.handler) ~= "function" then return end

    local done = false
    local function doneCallback()
        if done then return end
        done = true
        local _, nextJob = Sky.Security.Dequeue(job.id, { resource = resource })
        if nextJob then
            processNextJob(resource, nextJob)
        end
    end

    local success, err = pcall(job.handler, doneCallback, job.payload, job.id, resource)
    if not success then
        local logMsg = string.format("Queue job '%s' failed: %s", job.id, err)
        if Sky.Debug then
            Sky.Debug("error", logMsg)
        else
            print(logMsg)
        end
        doneCallback()
    end
end

--- Queues and executes an asynchronous action handler.
---@param id string
---@param handler function
---@param options? table
---@return boolean, string
function Sky.Security.QueueAction(id, handler, options)
    if type(handler) ~= "function" then
        return false, "missing_handler"
    end

    options = options or {}
    options.handler = handler

    local ok, status, item = Sky.Security.Queue(id, options)
    if not ok then
        return false, status
    end

    local resource = resolveResource(options.resource)
    if status == "active" then
        processNextJob(resource, item)
    end

    return true, status
end

--- Checks if streamer mode is enabled via KVP.
---@return boolean
function Sky.Security.GetStreamerMode()
    if Config and not Config.useStreamerMode then
        return false
    end
    return GetResourceKvpInt("skyBaseStreamerMode") == 1
end

--- Toggles streamer mode state and stores to KVP.
function Sky.Security.ToggleStreamerMode()
    local isEnabled = GetResourceKvpInt("skyBaseStreamerMode") == 1
    SetResourceKvpInt("skyBaseStreamerMode", isEnabled and 0 or 1)

    local newState = GetResourceKvpInt("skyBaseStreamerMode") == 1
    local stateText = newState and "Enabled" or "Disabled"

    Sky.Show.Notification("Streamer Mode", stateText, "info", 3000)
end

RegisterCommand("skyStreamerMode", function()
    Sky.Security.ToggleStreamerMode()
end, false)

-- Global Top-level Alias Exports
Sky.Cooldown = Sky.Security.Cooldown
Sky.GetStreamerMode = Sky.Security.GetStreamerMode
Sky.ToggleStreamerMode = Sky.Security.ToggleStreamerMode
