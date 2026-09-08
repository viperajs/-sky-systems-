if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/chat.lua") end
-- =====================================================
--  sky_jobs_base · source/client/chat.lua
--  Deobfuscated & Cleaned
-- =====================================================

local isChatActive = false

RegisterNUICallback("chat:setActive", function(data, cb)
    if data then
        isChatActive = data.active == true
    end
    cb({ success = true })
end)

RegisterNetEvent("sky_jobs_base:chat:messageUpdate", function(data)
    if not isChatActive or type(data) ~= "table" then return end
    SendNUIMessage({
        type = "chat:messageUpdate",
        data = data
    })
end)

RegisterNUICallback("chat:getMessages", function(data, cb)
    data = data or {}
    local payload = {
        limit = tonumber(data.limit),
        scope = data.scope,
        target = data.target,
        group_id = data.group_id or data.groupId or data.group
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:chat:getMessages", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:sendMessage", function(data, cb)
    data = data or {}
    local payload = {
        message = data.message or data.text,
        image_url = data.image_url or data.imageUrl,
        scope = data.scope,
        target = data.target,
        group_id = data.group_id or data.groupId or data.group
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:chat:sendMessage", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:setProfilePhoto", function(data, cb)
    data = data or {}
    local payload = {
        image_url = data.image_url or data.imageUrl
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:chat:setProfilePhoto", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:getGroups", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:chat:getGroups") or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:getGroup", function(data, cb)
    data = data or {}
    local groupId = data.groupId or data.group_id or data.group
    local res = Sky.Cb.Trigger("sky_jobs_base:chat:getGroup", groupId) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:createGroup", function(data, cb)
    data = data or {}
    local payload = {
        name = data.name,
        image_url = data.image_url or data.imageUrl,
        members = data.members
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:chat:createGroup", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:updateGroup", function(data, cb)
    data = data or {}
    local payload = {
        group_id = data.group_id or data.groupId or data.group,
        name = data.name,
        image_url = data.image_url or data.imageUrl
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:chat:updateGroup", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:setGroupMembers", function(data, cb)
    data = data or {}
    local payload = {
        group_id = data.group_id or data.groupId or data.group,
        members = data.members
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:chat:setGroupMembers", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:setGroupOwner", function(data, cb)
    data = data or {}
    local payload = {
        group_id = data.group_id or data.groupId or data.group,
        owner = data.owner or data.new_owner or data.admin
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:chat:setGroupOwner", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:removeGroupAdmin", function(data, cb)
    data = data or {}
    local payload = {
        group_id = data.group_id or data.groupId or data.group,
        admin = data.admin or data.owner or data.new_owner
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:chat:removeGroupAdmin", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:deleteGroup", function(data, cb)
    data = data or {}
    local payload = {
        group_id = data.group_id or data.groupId or data.group
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:chat:deleteGroup", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:leaveGroup", function(data, cb)
    data = data or {}
    local payload = {
        group_id = data.group_id or data.groupId or data.group
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:chat:leaveGroup", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:getOpenChats", function(data, cb)
    data = data or {}
    local payload = {
        limit = tonumber(data.limit)
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:chat:getOpenChats", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:getUnreadMessages", function(data, cb)
    data = data or {}
    local payload = {
        limit = tonumber(data.limit)
    }

    local res = Sky.Cb.Trigger("sky_jobs_base:chat:getUnreadMessages", payload) or {}
    cb({
        success = res.success == true,
        data = res.data or {},
        error = res.error
    })
end)

RegisterNUICallback("chat:getAllMembers", function(data, cb)
    local res = Sky.Cb.Trigger("sky_jobs_base:getAllJobMembers") or {}
    cb({
        success = true,
        data = res
    })
end)
