if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_base/source/client/modules/Vehicle.lua") end
-- =====================================================
--  sky_base · source/client/modules/Vehicle.lua
--  Deobfuscated & Cleaned
-- =====================================================

Sky = Sky or {}
Sky.Vehicle = {}
Sky.Vehicle.__index = Sky.Vehicle

--- Creates a new Vehicle wrapper instance.
---@param entity? number
---@return table
function Sky.Vehicle.new(entity)
    local self = setmetatable({}, Sky.Vehicle)
    self.entity = entity
    return self
end

--- Finds the closest vehicle to coords or player.
---@param coords? vector3
---@param modelFilter? string|number
---@return number, number -- closestVehicle, closestDistance
function Sky.Vehicle.GetClosest(coords, modelFilter)
    local filterHash = nil
    if modelFilter then
        filterHash = type(modelFilter) == "number" and modelFilter or GetHashKey(modelFilter)
    end

    local targetPos = coords
    if targetPos then
        targetPos = vector3(targetPos.x, targetPos.y, targetPos.z)
    else
        targetPos = GetEntityCoords(PlayerPedId())
    end

    local pool = GetGamePool("CVehicle")
    local filteredPool = pool

    if filterHash then
        filteredPool = {}
        for _, veh in pairs(pool) do
            if GetEntityModel(veh) == filterHash then
                table.insert(filteredPool, veh)
            end
        end
    end

    local closestVeh = -1
    local closestDist = -1

    for _, veh in pairs(filteredPool) do
        local vehPos = GetEntityCoords(veh)
        local dist = #(targetPos - vehPos)
        if closestDist == -1 or dist < closestDist then
            closestVeh = veh
            closestDist = dist
        end
    end

    return closestVeh, closestDist
end

--- Spawns a vehicle near player and returns entity handle.
---@param model string|number
---@param coords vector3
---@param heading? number
---@return number
function Sky.Vehicle:Spawn(model, coords, heading)
    local hash = type(model) == "number" and model or joaat(model)
    local pos = vector3(coords.x, coords.y, coords.z)
    local head = heading or 0.0

    local playerPos = GetEntityCoords(PlayerPedId())
    if #(playerPos - pos) > 424.0 then
        if Sky.Debug then
            Sky.Debug("error", "Tried to spawn vehicle on client but position is too far away (OneSync range).")
        end
        return 0
    end

    Sky.Load.Model(hash)

    local veh = CreateVehicle(hash, pos, head, true, true)
    local netId = NetworkGetNetworkIdFromEntity(veh)
    SetNetworkIdCanMigrate(netId, true)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetModelAsNoLongerNeeded(hash)
    SetVehRadioStation(veh, "OFF")

    RequestCollisionAtCoord(pos)
    while not HasCollisionLoadedAroundEntity(veh) do
        Wait(0)
    end

    self.entity = veh
    return veh
end

--- Gets complete vehicle modification and status properties table.
---@return table|nil
function Sky.Vehicle:GetVehicleProperties()
    local veh = self.entity
    if not veh or not DoesEntityExist(veh) then return nil end

    local colorPrimary, colorSecondary = GetVehicleColours(veh)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
    local isPrimaryCustom = GetIsVehiclePrimaryColourCustom(veh)
    local isSecondaryCustom = GetIsVehicleSecondaryColourCustom(veh)
    local dashboardColor = GetVehicleDashboardColor(veh)
    local interiorColor = GetVehicleInteriorColour(veh)

    local customPrimary = nil
    if isPrimaryCustom then
        local r, g, b = GetVehicleCustomPrimaryColour(veh)
        customPrimary = { r, g, b }
    end

    local customSecondary = nil
    if isSecondaryCustom then
        local r, g, b = GetVehicleCustomSecondaryColour(veh)
        customSecondary = { r, g, b }
    end

    local customXenon = nil
    local hasCustomXenon, xr, xg, xb = GetVehicleXenonLightsCustomColor(veh)
    if hasCustomXenon then
        customXenon = { xr, xg, xb }
    end

    -- Extras map
    local extras = {}
    for extraId = 0, 20 do
        if DoesExtraExist(veh, extraId) then
            extras[tostring(extraId)] = IsVehicleExtraTurnedOn(veh, extraId)
        end
    end

    -- Tyre burst map
    local tyreBurst = {}
    local wheelCountStr = tostring(GetVehicleNumberOfWheels(veh))
    local wheelIndexMap = {
        ["2"] = { 0, 4 },
        ["3"] = { 0, 1, 4, 5 },
        ["4"] = { 0, 1, 4, 5 },
        ["6"] = { 0, 1, 2, 3, 4, 5 }
    }
    local wheelIndices = wheelIndexMap[wheelCountStr]
    if wheelIndices then
        for _, idx in ipairs(wheelIndices) do
            tyreBurst[tostring(idx)] = IsVehicleTyreBurst(veh, idx, false)
        end
    end

    -- Windows intact map
    local windowsBroken = {}
    for winIdx = 0, 7 do
        RollUpWindow(veh, winIdx)
        windowsBroken[tostring(winIdx)] = not IsVehicleWindowIntact(veh, winIdx)
    end

    -- Doors broken map
    local doorsBroken = {}
    local doorCount = GetNumberOfVehicleDoors(veh)
    if doorCount and doorCount > 0 then
        for doorIdx = 0, doorCount do
            doorsBroken[tostring(doorIdx)] = IsVehicleDoorDamaged(veh, doorIdx)
        end
    end

    local fuel = (Sky.Functions and Sky.Functions.GetVehicleFuel and Sky.Functions.GetVehicleFuel(veh)) or GetVehicleFuelLevel(veh)

    local neonEnabled = {
        IsVehicleNeonLightEnabled(veh, 0),
        IsVehicleNeonLightEnabled(veh, 1),
        IsVehicleNeonLightEnabled(veh, 2),
        IsVehicleNeonLightEnabled(veh, 3)
    }

    local nr, ng, nb = GetVehicleNeonLightsColour(veh)
    local smr, smg, smb = GetVehicleTyreSmokeColor(veh)

    local modLivery = GetVehicleMod(veh, 48)
    if modLivery == -1 then
        modLivery = GetVehicleLivery(veh)
    end

    return {
        model = GetEntityModel(veh),
        doorsBroken = doorsBroken,
        windowsBroken = windowsBroken,
        tyreBurst = tyreBurst,
        tyresCanBurst = GetVehicleTyresCanBurst(veh),
        plate = Sky.Math.Trim(GetVehicleNumberPlateText(veh)),
        plateIndex = GetVehicleNumberPlateTextIndex(veh),
        bodyHealth = Sky.Math.Round(GetVehicleBodyHealth(veh), 1),
        engineHealth = Sky.Math.Round(GetVehicleEngineHealth(veh), 1),
        tankHealth = Sky.Math.Round(GetVehiclePetrolTankHealth(veh), 1),
        fuelLevel = Sky.Math.Round(fuel, 1),
        dirtLevel = Sky.Math.Round(GetVehicleDirtLevel(veh), 1),
        color1 = colorPrimary,
        color2 = colorSecondary,
        customPrimaryColor = customPrimary,
        customSecondaryColor = customSecondary,
        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,
        dashboardColor = dashboardColor,
        interiorColor = interiorColor,
        wheels = GetVehicleWheelType(veh),
        windowTint = GetVehicleWindowTint(veh),
        xenonColor = GetVehicleXenonLightsColor(veh),
        customXenonColor = customXenon,
        neonEnabled = neonEnabled,
        neonColor = { nr, ng, nb },
        extras = extras,
        tyreSmokeColor = { smr, smg, smb },
        modSpoilers = GetVehicleMod(veh, 0),
        modFrontBumper = GetVehicleMod(veh, 1),
        modRearBumper = GetVehicleMod(veh, 2),
        modSideSkirt = GetVehicleMod(veh, 3),
        modExhaust = GetVehicleMod(veh, 4),
        modFrame = GetVehicleMod(veh, 5),
        modGrille = GetVehicleMod(veh, 6),
        modHood = GetVehicleMod(veh, 7),
        modFender = GetVehicleMod(veh, 8),
        modRightFender = GetVehicleMod(veh, 9),
        modRoof = GetVehicleMod(veh, 10),
        modRoofLivery = GetVehicleRoofLivery(veh),
        modEngine = GetVehicleMod(veh, 11),
        modBrakes = GetVehicleMod(veh, 12),
        modTransmission = GetVehicleMod(veh, 13),
        modHorns = GetVehicleMod(veh, 14),
        modSuspension = GetVehicleMod(veh, 15),
        modArmor = GetVehicleMod(veh, 16),
        modTurbo = IsToggleModOn(veh, 18),
        modSmokeEnabled = IsToggleModOn(veh, 20),
        modXenon = IsToggleModOn(veh, 22),
        modFrontWheels = GetVehicleMod(veh, 23),
        modCustomFrontWheels = GetVehicleModVariation(veh, 23),
        modBackWheels = GetVehicleMod(veh, 24),
        modCustomBackWheels = GetVehicleModVariation(veh, 24),
        modPlateHolder = GetVehicleMod(veh, 25),
        modVanityPlate = GetVehicleMod(veh, 26),
        modTrimA = GetVehicleMod(veh, 27),
        modOrnaments = GetVehicleMod(veh, 28),
        modDashboard = GetVehicleMod(veh, 29),
        modDial = GetVehicleMod(veh, 30),
        modDoorSpeaker = GetVehicleMod(veh, 31),
        modSeats = GetVehicleMod(veh, 32),
        modSteeringWheel = GetVehicleMod(veh, 33),
        modShifterLeavers = GetVehicleMod(veh, 34),
        modAPlate = GetVehicleMod(veh, 35),
        modSpeakers = GetVehicleMod(veh, 36),
        modTrunk = GetVehicleMod(veh, 37),
        modHydrolic = GetVehicleMod(veh, 38),
        modEngineBlock = GetVehicleMod(veh, 39),
        modAirFilter = GetVehicleMod(veh, 40),
        modStruts = GetVehicleMod(veh, 41),
        modArchCover = GetVehicleMod(veh, 42),
        modAerials = GetVehicleMod(veh, 43),
        modTrimB = GetVehicleMod(veh, 44),
        modTank = GetVehicleMod(veh, 45),
        modWindows = GetVehicleMod(veh, 46),
        modLivery = modLivery,
        modLightbar = GetVehicleMod(veh, 49),
        class = GetVehicleClass(veh)
    }
end

--- Applies vehicle properties table to target entity.
---@param props table
function Sky.Vehicle:SetVehicleProperties(props)
    local veh = self.entity
    if not veh or not DoesEntityExist(veh) or type(props) ~= "table" then return end

    local colorPrimary, colorSecondary = GetVehicleColours(veh)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)

    SetVehicleModKit(veh, 0)

    if props.tyresCanBurst ~= nil then SetVehicleTyresCanBurst(veh, props.tyresCanBurst) end
    if props.plate ~= nil then SetVehicleNumberPlateText(veh, props.plate) end
    if props.plateIndex ~= nil then SetVehicleNumberPlateTextIndex(veh, props.plateIndex) end
    if props.bodyHealth ~= nil then SetVehicleBodyHealth(veh, props.bodyHealth + 0.0) end
    if props.engineHealth ~= nil then SetVehicleEngineHealth(veh, props.engineHealth + 0.0) end
    if props.tankHealth ~= nil then SetVehiclePetrolTankHealth(veh, props.tankHealth + 0.0) end

    if props.fuelLevel ~= nil then
        if Sky.Functions and Sky.Functions.SetVehicleFuel then
            Sky.Functions.SetVehicleFuel(veh, props.fuelLevel)
        else
            SetVehicleFuelLevel(veh, props.fuelLevel + 0.0)
        end
    end

    if props.dirtLevel ~= nil then SetVehicleDirtLevel(veh, props.dirtLevel + 0.0) end

    if props.customPrimaryColor then
        SetVehicleCustomPrimaryColour(veh, props.customPrimaryColor[1], props.customPrimaryColor[2], props.customPrimaryColor[3])
    end
    if props.customSecondaryColor then
        SetVehicleCustomSecondaryColour(veh, props.customSecondaryColor[1], props.customSecondaryColor[2], props.customSecondaryColor[3])
    end

    if props.color1 ~= nil then SetVehicleColours(veh, props.color1, colorSecondary) end
    if props.color2 ~= nil then SetVehicleColours(veh, props.color1 or colorPrimary, props.color2) end
    if props.pearlescentColor ~= nil then SetVehicleExtraColours(veh, props.pearlescentColor, wheelColor) end
    if props.interiorColor ~= nil then SetVehicleInteriorColor(veh, props.interiorColor) end
    if props.dashboardColor ~= nil then SetVehicleDashboardColor(veh, props.dashboardColor) end
    if props.wheelColor ~= nil then SetVehicleExtraColours(veh, props.pearlescentColor or pearlescentColor, props.wheelColor) end

    if props.wheels ~= nil then SetVehicleWheelType(veh, props.wheels) end
    if props.windowTint ~= nil then SetVehicleWindowTint(veh, props.windowTint) end

    if props.neonEnabled ~= nil then
        SetVehicleNeonLightEnabled(veh, 0, props.neonEnabled[1])
        SetVehicleNeonLightEnabled(veh, 1, props.neonEnabled[2])
        SetVehicleNeonLightEnabled(veh, 2, props.neonEnabled[3])
        SetVehicleNeonLightEnabled(veh, 3, props.neonEnabled[4])
    end

    if props.extras ~= nil then
        for extraIdStr, enabled in pairs(props.extras) do
            SetVehicleExtra(veh, tonumber(extraIdStr), enabled and 0 or 1)
        end
    end

    if props.neonColor ~= nil then SetVehicleNeonLightsColour(veh, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end
    if props.xenonColor ~= nil then SetVehicleXenonLightsColor(veh, props.xenonColor) end
    if props.customXenonColor ~= nil then SetVehicleXenonLightsCustomColor(veh, props.customXenonColor[1], props.customXenonColor[2], props.customXenonColor[3]) end

    if props.modSmokeEnabled ~= nil then ToggleVehicleMod(veh, 20, props.modSmokeEnabled == true) end
    if props.tyreSmokeColor ~= nil then SetVehicleTyreSmokeColor(veh, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3]) end

    local mods = {
        { 0, props.modSpoilers }, { 1, props.modFrontBumper }, { 2, props.modRearBumper },
        { 3, props.modSideSkirt }, { 4, props.modExhaust }, { 5, props.modFrame },
        { 6, props.modGrille }, { 7, props.modHood }, { 8, props.modFender },
        { 9, props.modRightFender }, { 10, props.modRoof }, { 11, props.modEngine },
        { 12, props.modBrakes }, { 13, props.modTransmission }, { 14, props.modHorns },
        { 15, props.modSuspension }, { 16, props.modArmor }, { 25, props.modPlateHolder },
        { 26, props.modVanityPlate }, { 27, props.modTrimA }, { 28, props.modOrnaments },
        { 29, props.modDashboard }, { 30, props.modDial }, { 31, props.modDoorSpeaker },
        { 32, props.modSeats }, { 33, props.modSteeringWheel }, { 34, props.modShifterLeavers },
        { 35, props.modAPlate }, { 36, props.modSpeakers }, { 37, props.modTrunk },
        { 38, props.modHydrolic }, { 39, props.modEngineBlock }, { 40, props.modAirFilter },
        { 41, props.modStruts }, { 42, props.modArchCover }, { 43, props.modAerials },
        { 44, props.modTrimB }, { 45, props.modTank }, { 46, props.modWindows }, { 49, props.modLightbar }
    }

    for _, entry in ipairs(mods) do
        local slot, val = entry[1], entry[2]
        if val ~= nil then
            SetVehicleMod(veh, slot, val, false)
        end
    end

    if props.modRoofLivery ~= nil then SetVehicleRoofLivery(veh, props.modRoofLivery) end
    if props.modTurbo ~= nil then ToggleVehicleMod(veh, 18, props.modTurbo) end
    if props.modXenon ~= nil then ToggleVehicleMod(veh, 22, props.modXenon) end
    if props.modFrontWheels ~= nil then SetVehicleMod(veh, 23, props.modFrontWheels, props.modCustomFrontWheels) end
    if props.modBackWheels ~= nil then SetVehicleMod(veh, 24, props.modBackWheels, props.modCustomBackWheels) end

    if props.modLivery ~= nil then
        SetVehicleMod(veh, 48, props.modLivery, false)
        SetVehicleLivery(veh, props.modLivery)
    end

    if props.windowsBroken ~= nil then
        for winIdStr, isBroken in pairs(props.windowsBroken) do
            if isBroken then
                RemoveVehicleWindow(veh, tonumber(winIdStr))
            end
        end
    end

    if props.doorsBroken ~= nil then
        for doorIdStr, isDamaged in pairs(props.doorsBroken) do
            if isDamaged then
                SetVehicleDoorBroken(veh, tonumber(doorIdStr), true)
            end
        end
    end

    if props.tyreBurst ~= nil then
        for tyreIdStr, isBurst in pairs(props.tyreBurst) do
            if isBurst then
                SetVehicleTyreBurst(veh, tonumber(tyreIdStr), true, 1000.0)
            end
        end
    end
end

--- Gets trimmed plate string.
---@return string
function Sky.Vehicle:GetPlate()
    if not self.entity or not DoesEntityExist(self.entity) then return "" end
    self.plate = Sky.Math.Trim(GetVehicleNumberPlateText(self.entity))
    return self.plate
end

--- Deletes vehicle entity.
function Sky.Vehicle:Remove()
    if self.entity and DoesEntityExist(self.entity) then
        SetEntityAsMissionEntity(self.entity, false, true)
        DeleteVehicle(self.entity)
        self.entity = nil
    end
end

--- Triggers vehicle keys addition.
function Sky.Vehicle:GiveKeys()
    if not self.entity or not DoesEntityExist(self.entity) then return end
    local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(self.entity))
    local plate = GetVehicleNumberPlateText(self.entity)

    if Sky.Functions and Sky.Functions.GiveVehicleKeys then
        Sky.Functions.GiveVehicleKeys(self.entity, plate, modelName)
    elseif Sky.Debug then
        Sky.Debug("warn", "Sky.Vehicle:GiveKeys() called but no handler registered. Sky.Config.vehiclekeys=" .. tostring(Sky.Config and Sky.Config.vehiclekeys))
    end
end

--- Triggers vehicle keys removal.
function Sky.Vehicle:RemoveKeys()
    if not self.entity or not DoesEntityExist(self.entity) then return end
    local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(self.entity))
    local plate = GetVehicleNumberPlateText(self.entity)

    if Sky.Functions and Sky.Functions.RemoveVehicleKeys then
        Sky.Functions.RemoveVehicleKeys(self.entity, plate, modelName)
    elseif Sky.Debug then
        Sky.Debug("warn", "Sky.Vehicle:RemoveKeys() called but no handler registered. Sky.Config.vehiclekeys=" .. tostring(Sky.Config and Sky.Config.vehiclekeys))
    end
end
