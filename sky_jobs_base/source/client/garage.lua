if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/garage.lua") end
-- =====================================================
--  sky_jobs_base · source/client/garage.lua
--  Deobfuscated & Cleaned
-- =====================================================

local localeKey = (Sky and Sky.Config and Sky.Config.locale) or "en"
local locales = (Locales and Locales[localeKey]) or (Locales and Locales.en) or {}
local nuiLocales = (locales.Nui and locales.Nui.garage) or {}
local errorLocales = nuiLocales.errors or {}

local DEFAULT_GARAGE_TYPE = "vehicle"
local catalogByGarageType = {}

local function isPlayerOnDuty()
    local jobState = GetJobState and GetJobState()
    return jobState and jobState.employed and jobState.onDuty
end

local function normalizeGarageType(gType)
    if type(gType) ~= "string" then
        return DEFAULT_GARAGE_TYPE
    end
    local lower = gType:lower()
    if lower == "helicopter" or lower == "heli" or lower == "air" then
        return "helicopter"
    end
    if lower == "boat" or lower == "sea" or lower == "water" then
        return "boat"
    end
    return DEFAULT_GARAGE_TYPE
end

local function getCategoryTable(gType)
    local categoryKey = normalizeGarageType(gType)
    catalogByGarageType[categoryKey] = catalogByGarageType[categoryKey] or {}
    return catalogByGarageType[categoryKey]
end

local function isModelAllowedInGarage(modelHash, gType)
    local categoryTable = catalogByGarageType[normalizeGarageType(gType)]
    if not categoryTable then return false end
    return categoryTable[modelHash] == true
end

local function setupGarageCatalog(catalog)
    catalogByGarageType = {}
    if type(catalog) ~= "table" then return end

    for _, v in ipairs(catalog) do
        local catTable = getCategoryTable(v.garageType)
        if v.model then
            catTable[joaat(v.model)] = true
        end
        if type(v.altModels) == "table" then
            for _, alt in ipairs(v.altModels) do
                catTable[joaat(alt)] = true
            end
        end
    end
end

local function fetchGarageCatalog()
    local res = Sky.Cb.TriggerWithTimeout("sky_jobs_base:getJobGarageCatalog", 10000)
    local defaultVehs = (Config and Config.JobGarage and Config.JobGarage.vehicles) or {}

    if type(res) == "table" and res.success == true and type(res.data) == "table" then
        setupGarageCatalog(res.data)
    else
        setupGarageCatalog(defaultVehs)
    end
end

CreateThread(function()
    Wait(2000)
    fetchGarageCatalog()
end)

RegisterNetEvent("sky_base:updateJob", fetchGarageCatalog)
RegisterNetEvent("sky_jobs_base:creator:updatePlayerJob", fetchGarageCatalog)
RegisterNetEvent("sky_jobs_base:jobs:registered", fetchGarageCatalog)
RegisterNetEvent("sky_jobs_base:jobs:unregistered", fetchGarageCatalog)

local function showGarageNotification(message)
    local title = locales.GarageTitle or "Garage"
    local msg = message or locales.GarageParkFailedNotify or "Unable to park vehicle."
    Sky.Show.Notification(title, msg, "error")
end

local function parkVehicleInGarage(garageId, garageType)
    if not isPlayerOnDuty() then return end

    local ped = PlayerPedId()
    if not (ped and ped ~= 0 and DoesEntityExist(ped) and not IsEntityDead(ped)) then return end

    if not IsPedInAnyVehicle(ped, false) then
        showGarageNotification(locales.GarageParkDriverRequired or "You need to be in the driver seat to park.")
        return
    end

    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or not DoesEntityExist(veh) then return end

    if GetPedInVehicleSeat(veh, -1) ~= ped then
        showGarageNotification(locales.GarageParkDriverRequired or "You need to be in the driver seat to park.")
        return
    end

    local catKey = normalizeGarageType(garageType)
    local catTable = catalogByGarageType[catKey]

    if catTable and next(catTable) ~= nil then
        if not isModelAllowedInGarage(GetEntityModel(veh), garageType) then
            showGarageNotification(locales.GarageParkInvalidVehicle or "This vehicle can't be parked here.")
            return
        end
    end

    local netId = NetworkGetNetworkIdFromEntity(veh)
    local vehObj = Sky.Vehicle:new(veh)
    local props = vehObj:GetVehicleProperties()

    if type(props) ~= "table" then
        print(string.format("[sky_jobs_base] Failed to capture vehicle properties while parking vehicle netId=%s garageId=%s", tostring(netId), tostring(garageId)))
        showGarageNotification(locales.GarageParkFailedNotify or "Unable to park vehicle.")
        return
    end

    if Sky.Functions and Sky.Functions.GetVehicleFuel then
        local rawFuel = Sky.Functions.GetVehicleFuel(veh)
        props.fuelLevel = Sky.Math.Round(rawFuel, 1)
    end

    local res = Sky.Cb.Trigger("sky_jobs_base:parkVehicle", garageId, netId, props)
    if res and res.success then
        vehObj:RemoveKeys()
        TriggerEvent("sky_jobs_base:trunk:unregister", veh)
        TaskLeaveVehicle(ped, veh, 0)
        Wait(500)

        if DoesEntityExist(veh) then
            SetEntityAsMissionEntity(veh, true, true)
            DeleteVehicle(veh)
        end
    else
        local err = type(res) == "table" and res.error or nil
        showGarageNotification(err)
    end
end

local function parseCoordsTable(data)
    if not data then return nil end
    if data.coords and data.coords.x and data.coords.y and data.coords.z then
        return data.coords
    end
    if data.x and data.y and data.z then
        return data
    end
    return nil
end

local function getParkHelpMessage(garageType)
    local msg = locales.GarageParkHelpNotify or "Park the vehicle"
    local catKey = normalizeGarageType(garageType)

    if catKey == "helicopter" then
        msg = locales.HelicopterGarageParkHelpNotify or msg
    elseif catKey == "boat" then
        msg = locales.BoatGarageParkHelpNotify or msg
    end
    return msg
end

local function ensureTable(data)
    if type(data) == "table" then return data end
    return {}
end

local function getJobColor()
    local col = Sky.Cb.Trigger("sky_jobs_base:getJobColor")
    if type(col) == "string" and col ~= "" then return col end
    return nil
end

local function applyVehicleLivery(vehicle, liveryIdx)
    if not (vehicle and vehicle ~= 0 and DoesEntityExist(vehicle)) then return end

    local idx = tonumber(liveryIdx)
    if not idx then return end

    idx = math.floor(idx)
    if idx < 0 then return end

    SetVehicleModKit(vehicle, 0)
    local livCount = GetVehicleLiveryCount(vehicle)
    if livCount and livCount > 0 and idx < livCount then
        SetVehicleLivery(vehicle, idx)
    end

    local modCount = GetNumVehicleMods(vehicle, 48)
    if modCount and modCount > 0 and idx < modCount then
        SetVehicleMod(vehicle, 48, idx, false)
    end
end

local function applyVehicleExtras(vehicle, extrasData)
    if not (vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) and type(extrasData) == "table") then return end

    local function setSingleExtra(extraId, state)
        local idNum = tonumber(extraId)
        if not idNum then return end

        idNum = math.floor(idNum)
        if idNum < 0 then return end

        if DoesExtraExist(vehicle, idNum) then
            SetVehicleExtra(vehicle, idNum, state and 0 or 1)
        end
    end

    if #extrasData > 0 then
        for _, extra in ipairs(extrasData) do
            if type(extra) == "number" or type(extra) == "string" then
                setSingleExtra(extra, true)
            elseif type(extra) == "table" then
                local eId = extra.id or extra.extra or extra.index or extra[1]
                local enabled = true
                if extra.enabled ~= nil then
                    enabled = extra.enabled == true
                elseif extra.state ~= nil then
                    enabled = extra.state ~= false
                end
                setSingleExtra(eId, enabled)
            end
        end
    else
        for extraKey, val in pairs(extrasData) do
            local state = false
            if val == true then
                state = true
            elseif type(val) == "number" then
                state = (val ~= 0)
            elseif type(val) == "string" then
                local lVal = val:lower()
                state = (lVal == "true" or lVal == "1" or lVal == "on" or lVal == "enabled")
            end
            setSingleExtra(extraKey, state)
        end
    end
end

RegisterNUICallback("getGarageVehicles", function(data, cb)
    local garageId = data and data.garageId or nil
    local res = Sky.Cb.Trigger("sky_jobs_base:getGarageVehicles", garageId)

    if not res then
        cb({
            success = false,
            error = errorLocales.unavailable or "Garage unavailable."
        })
        return
    end
    cb(res)
end)

RegisterNUICallback("getVehicleStats", function(data, cb)
    local item = ensureTable(data)
    local model = item.model
    if not model then
        cb({
            success = false,
            error = errorLocales.vehicleUnavailable or "Vehicle unavailable."
        })
        return
    end

    local stats = Sky.Info.GetVehicleStats(model)
    if stats then
        cb({ success = true, data = stats })
    else
        cb({
            success = false,
            error = errorLocales.loadStats or "Failed to load vehicle stats."
        })
    end
end)

RegisterNUICallback("parkOut", function(data, cb)
    local item = ensureTable(data)
    local res = Sky.Cb.Trigger("sky_jobs_base:parkOutVehicle", item)

    if not res then
        cb({
            success = false,
            error = errorLocales.parkOut or "Failed to park out vehicle."
        })
        return
    end
    cb(res)
end)

RegisterNUICallback("buyGarageVehicle", function(data, cb)
    local item = ensureTable(data)
    local res = Sky.Cb.Trigger("sky_jobs_base:buyGarageVehicle", item)

    if not res then
        cb({
            success = false,
            error = errorLocales.purchase or "Vehicle purchase failed."
        })
        return
    end
    cb(res)
end)

RegisterNUICallback("sellGarageVehicle", function(data, cb)
    local item = ensureTable(data)
    local res = Sky.Cb.Trigger("sky_jobs_base:sellGarageVehicle", item)

    if not res then
        cb({
            success = false,
            error = errorLocales.sellVehicle or "Vehicle sale failed."
        })
        return
    end
    cb(res)
end)

RegisterNUICallback("changePlate", function(data, cb)
    local item = ensureTable(data)
    local res = Sky.Cb.Trigger("sky_jobs_base:changePlate", item)

    if not res then
        cb({
            success = false,
            error = errorLocales.changePlate or "Failed to change plate."
        })
        return
    end
    cb(res)
end)

RegisterNUICallback("updateGarageVehiclePlate", function(data, cb)
    local item = ensureTable(data)
    local res = Sky.Cb.Trigger("sky_jobs_base:updateGarageVehiclePlate", item)

    if not res then
        cb({
            success = false,
            error = errorLocales.changePlate or "Failed to change plate."
        })
        return
    end
    cb(res)
end)

RegisterNUICallback("openStretcherEditor", function(data, cb)
    local item = ensureTable(data)
    if exports and exports.sky_ambulancejob and exports.sky_ambulancejob.openStretcherEditor then
        local res = exports.sky_ambulancejob:openStretcherEditor(item)
        if not res then
            cb({
                success = false,
                error = errorLocales.stretcherEditor or "Failed to open stretcher editor."
            })
            return
        end
        cb(res)
        return
    end

    cb({
        success = false,
        error = errorLocales.editorUnavailable or "Editor unavailable."
    })
end)

local function isAreaBlocked(coords, radius)
    if not (coords and coords.x and coords.y and coords.z) then return false end
    local r = tonumber(radius) or 3.0

    local veh = GetClosestVehicle(coords.x, coords.y, coords.z, r, 0, 71)
    return veh and veh ~= 0 and DoesEntityExist(veh)
end

RegisterNetEvent("sky_jobs_base:spawnGarageVehicle", function(data)
    if type(data) ~= "table" then return end

    local spawnCoords = data.coords or {}
    if not (spawnCoords.x and spawnCoords.y and spawnCoords.z) then return end

    local heading = data.heading or 0.0
    local blockRadius = (Config and Config.JobGarage and Config.JobGarage.spawnBlockRadius) or 3.0

    if isAreaBlocked(spawnCoords, blockRadius) then
        local maxFallbackDist = (Config and Config.JobGarage and Config.JobGarage.maxSpawnFallbackDistance) or 100.0
        local baseVec = vector3(spawnCoords.x, spawnCoords.y, spawnCoords.z)
        local foundPoint = false

        if type(data.spawnPoints) == "table" then
            for _, pt in ipairs(data.spawnPoints) do
                if pt and pt.x and pt.y and pt.z then
                    local ptVec = vector3(pt.x, pt.y, pt.z)
                    if #(baseVec - ptVec) <= maxFallbackDist then
                        if not isAreaBlocked(pt, blockRadius) then
                            spawnCoords = pt
                            heading = pt.heading or heading
                            foundPoint = true
                            break
                        end
                    end
                end
            end
        end

        if not foundPoint then
            local blockedMsg = locales.GarageSpawnBlockedNotify or "Spawn point is blocked."
            Sky.Show.Notification(locales.GarageTitle or "Garage", blockedMsg, "error")
            TriggerServerEvent("sky_jobs_base:garageVehicleSpawnFailed", { plate = data.plate })
            return
        end
    end

    local vehObj = Sky.Vehicle:new()
    local spawnedVeh = vehObj:Spawn(data.model, spawnCoords, heading)

    if not (spawnedVeh and DoesEntityExist(spawnedVeh)) then return end

    local ped = PlayerPedId()
    SetVehicleOnGroundProperly(spawnedVeh)

    local plateText = tostring(data.plate or "EMS")
    SetVehicleNumberPlateText(spawnedVeh, plateText)

    if data.vehicleMods then
        if Sky.Vehicle and type(Sky.Vehicle.setvehiclemods) == "function" then
            Sky.Vehicle.setvehiclemods(spawnedVeh, data.vehicleMods)
        else
            vehObj:SetVehicleProperties(data.vehicleMods)
        end
    end

    applyVehicleLivery(spawnedVeh, data.livery)
    applyVehicleExtras(spawnedVeh, data.extras)

    if data.fuel then
        if Sky.Functions and Sky.Functions.SetVehicleFuel then
            Sky.Functions.SetVehicleFuel(spawnedVeh, data.fuel)
        else
            SetVehicleFuelLevel(spawnedVeh, (data.fuel or 100.0) + 0.0)
        end
    end

    if data.fuelType and Sky.Functions and Sky.Functions.SetVehicleFuelType then
        Sky.Functions.SetVehicleFuelType(spawnedVeh, data.fuelType)
    end

    local netId = NetworkGetNetworkIdFromEntity(spawnedVeh)
    if not netId or netId == 0 then
        NetworkRegisterEntityAsNetworked(spawnedVeh)
        local retries = 0
        while (not netId or netId == 0) and retries < 20 do
            Wait(50)
            netId = NetworkGetNetworkIdFromEntity(spawnedVeh)
            retries = retries + 1
        end
    end

    if netId and netId ~= 0 then
        SetNetworkIdCanMigrate(netId, true)
        SetNetworkIdExistsOnAllMachines(netId, true)
    end

    if Config and Config.JobGarage and Config.JobGarage.warpIntoVehicle then
        TaskWarpPedIntoVehicle(ped, spawnedVeh, -1)
    end

    vehObj:GiveKeys()
    TriggerEvent("sky_jobs_base:trunk:register", spawnedVeh)
    TriggerServerEvent("sky_jobs_base:garageVehicleSpawned", {
        plate = data.plate,
        netId = netId
    })
end)

RegisterNetEvent("sky_jobs_base:garage:close", function()
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "garage:close" })
end)

local function openGarageUI(garageId, garageType)
    if not garageId then return end
    fetchGarageCatalog()

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "garage",
        garageId = garageId,
        garageType = garageType or DEFAULT_GARAGE_TYPE,
        jobColor = getJobColor()
    })
end

AddEventHandler("sky_jobs_base:garageInteraction", function(data)
    if not isPlayerOnDuty() then return end

    if type(data) == "table" then
        openGarageUI(data.garageId or data.id, data.garageType)
        return
    end

    local entry = nil
    if type(garageLookup) == "table" then
        entry = garageLookup[data]
    elseif type(_G.garageLookup) == "table" then
        entry = _G.garageLookup[data]
    end

    if entry then
        openGarageUI(entry.garageId or data, entry.garageType)
    else
        openGarageUI(data, DEFAULT_GARAGE_TYPE)
    end
end)

AddEventHandler("sky_jobs_base:garageParkInteraction", function(data)
    if type(data) == "table" then
        parkVehicleInGarage(data.garageId, data.garageType)
    end
end)
