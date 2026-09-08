if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/modules/Players.lua") end
-- =====================================================
--  sky_base · source/client/modules/Players.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Players = {}

--- Returns a list of active player server IDs where ped entity exists.
---@return table
function Sky.Players.GetPlayers()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            table.insert(players, player)
        end
    end
    return players
end

--- Gets the closest active player to given coordinates or self.
---@param coords? vector3
---@return number, number -- closestPlayer, closestDistance
function Sky.Players.GetClosestPlayer(coords)
    local players = Sky.Players.GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local selfPed = PlayerPedId()
    local selfPlayer = PlayerId()

    local targetPos = coords
    local isSelfQuery = false

    if not targetPos then
        isSelfQuery = true
        targetPos = GetEntityCoords(selfPed)
    end

    for _, player in ipairs(players) do
        local ped = GetPlayerPed(player)
        if not isSelfQuery or player ~= selfPlayer then
            local pedCoords = GetEntityCoords(ped)
            local dist = #(pedCoords - targetPos)
            if closestDistance == -1 or dist < closestDistance then
                closestPlayer = player
                closestDistance = dist
            end
        end
    end

    return closestPlayer, closestDistance
end

--- Gets all players (excluding local player) within a given radius.
---@param coords vector3
---@param radius number
---@return table
function Sky.Players.GetPlayersInArea(coords, radius)
    local players = Sky.Players.GetPlayers()
    local inArea = {}
    local selfPlayer = PlayerId()

    for _, player in ipairs(players) do
        local ped = GetPlayerPed(player)
        local pedCoords = GetEntityCoords(ped)
        local dist = #(pedCoords - coords)
        if dist <= radius and player ~= selfPlayer then
            table.insert(inArea, player)
        end
    end

    return inArea
end
