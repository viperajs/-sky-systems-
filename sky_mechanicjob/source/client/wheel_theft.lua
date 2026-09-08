if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/wheel_theft.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/wheel_theft.lua
--  Deobfuscated & Cleaned
-- =====================================================

local SEARCH_RADIUS = 4.0
local CONTROL_INTERACT = 38 -- E
local CONTROL_CANCEL = 73   -- X
local STATE_BAG_KEY = "sky_mechanic_wheel_damage"

-- ── Helpers ──────────────────────────────────────────

local function normalizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

local function isWheelDetached(vehicle, wheelIndexes)
    local stateBag = Entity(vehicle).state[STATE_BAG_KEY]
    local wheelsData = (type(stateBag) == "table" and type(stateBag.wheels) == "table") and stateBag.wheels or {}

    for _, idx in ipairs(wheelIndexes or {}) do
        local entry = wheelsData[tostring(idx)]
        if type(entry) == "table" and entry.detached == true then
            return true
        end
    end
    return false
end

local function countDetachedWheels(vehicle)
    local stateBag = Entity(vehicle).state[STATE_BAG_KEY]
    local wheelsData = (type(stateBag) == "table" and type(stateBag.wheels) == "table") and stateBag.wheels or {}
    local count = 0

    for _, entry in pairs(wheelsData) do
        if type(entry) == "table" and entry.detached == true then
            count = count + 1
        end
    end
    return count
end

-- ── Steal RPC Trigger ─────────────────────────────

local function completeSteal(vehicle, wheelIndexes)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local plate = normalizePlate(GetVehicleNumberPlateText(vehicle))

    local res = Sky.Cb.Trigger("sky_mechanicjob:wheelTheft:completeSteal", {
        vehicleNetId = netId,
        plate = plate,
        wheelIndexes = wheelIndexes
    }) or {}

    if not (type(res) == "table" and res.success == true) then
        local msg = tuningLocales.WheelTheftMissingItem or "You need a lug wrench."
        if type(res) == "table" then
            if res.error == "already_missing" then
                msg = tuningLocales.WheelTheftAlreadyMissing or "This wheel has already been stolen."
            elseif res.error == "vehicle_too_far" then
                msg = tuningLocales.WheelTheftTooFar or "Move closer to the vehicle."
            elseif res.error == "inventory_full" then
                msg = tuningLocales.WheelTheftInventoryFull or "You cannot carry another wheel."
            end
        end
        notify(msg, "error")
        return false
    end

    if res.allWheelsMissing == true then
        notify(tuningLocales.WheelTheftAllWheelsStolen or "All wheels stolen. The vehicle is resting on bricks.", "success")
    else
        local currentDetached = math.max(countDetachedWheels(vehicle), math.floor(tonumber(res.detachedCount) or 0))
        local totalCount = math.floor(tonumber(res.totalCount) or 4)
        local fmt = tuningLocales.WheelTheftSuccess or "Wheel stolen (%s/%s)."
        notify(string.format(fmt, currentDetached, totalCount), "success")
    end

    return true
end

-- ── Checklist NUI Updates ──────────────────────────

local function updateWheelTheftChecklist()
    if not WheelTheftState.active then return end
    local step = WheelTheftState.step

    sendUi("wheelInstall:checklist:update", {
        title = getNuiLocale("tablet.orders.wheel_theft_checklist.title", "Wheel Theft"),
        note = getNuiLocale("tablet.orders.wheel_theft_checklist.note", "Press E for the next step. Press X to cancel."),
        steps = {
            {
                id = "lift",
                label = getNuiLocale("tablet.orders.wheel_theft_checklist.lift", "Lift the vehicle with the car jack"),
                done = (step ~= "lift")
            },
            {
                id = "steal",
                label = getNuiLocale("tablet.orders.wheel_theft_checklist.steal", "Steal the selected wheel"),
                done = (step == "lower" or step == "complete")
            },
            {
                id = "lower",
                label = getNuiLocale("tablet.orders.wheel_theft_checklist.lower", "Remove the car jack"),
                done = (step == "complete")
            }
        }
    })

    WheelTheftState.checklistVisible = true
end

local function resetWheelTheftState(clearJack)
    if WheelTheftState.checklistVisible then
        sendUi("wheelInstall:checklist:close", {})
    end

    WheelTheftState.active = false
    WheelTheftState.step = "idle"
    WheelTheftState.vehicle = 0
    WheelTheftState.vehicleNetId = 0
    WheelTheftState.plate = ""
    WheelTheftState.wheelIndexes = nil
    WheelTheftState.checklistVisible = false

    if clearJack and CarJackState.lifted then
        clearCarJackState(true)
    end
end

local function getActiveTheftVehicle()
    local veh = WheelTheftState.vehicle
    if veh == 0 or not DoesEntityExist(veh) then
        veh = NetworkGetEntityFromNetworkId(WheelTheftState.vehicleNetId)
        WheelTheftState.vehicle = veh
    end

    if veh == 0 or not DoesEntityExist(veh) then
        resetWheelTheftState(true)
        return 0, { fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.") }
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    local vehCoords = GetEntityCoords(veh)
    if #(pedCoords - vehCoords) > SEARCH_RADIUS + 2.0 then
        return 0, { fallback = tuningLocales.WheelTheftTooFar or "Move closer to the vehicle." }
    end

    return veh
end

-- ── Step Handler & Input Loop ────────────────────────

local function processWheelTheftStep()
    if not WheelTheftState.active then return false end

    local vehicle, err = getActiveTheftVehicle()
    if vehicle == 0 then
        notify(err.fallback, "error")
        return false
    end

    local step = WheelTheftState.step

    if step == "lift" then
        local targetVeh = select(1, getNearestCarJackTarget())
        if targetVeh ~= vehicle then
            notify(tuningLocales.CarJackNotNear or "Move closer to the vehicle side to use the car jack.", "error")
            return false
        end

        local ok, jackErr = tryUseVehicleCarJack()
        if not ok then
            local msg = (jackErr and jackErr.fallback) or tuningLocales.CarJackControlFailed or "Unable to use car jack right now."
            notify(msg, "error")
            return false
        end

        WheelTheftState.step = "steal"
        updateWheelTheftChecklist()
        return true
    end

    if step == "steal" then
        local wheelIndexes = WheelTheftState.wheelIndexes or {}
        if isWheelDetached(vehicle, wheelIndexes) then
            notify(tuningLocales.WheelTheftAlreadyMissing or "This wheel has already been stolen.", "error")
            return false
        end

        local ok, minigameErr = runTuningMinigame("wheel_change", "detach", vehicle)
        if not ok then
            local msg = tuningLocales.WheelTheftMinigameFailed or "You failed to loosen all bolts."
            if type(minigameErr) == "table" and type(minigameErr.fallback) == "string" and minigameErr.fallback ~= "" then
                msg = minigameErr.fallback
            end
            notify(msg, "error")
            return false
        end

        if not completeSteal(vehicle, wheelIndexes) then return false end

        Wait(150)
        ensureWheelTheftBricksForVehicle(vehicle)

        WheelTheftState.step = "lower"
        updateWheelTheftChecklist()
        return true
    end

    if step == "lower" then
        local ok, jackErr = tryRemoveVehicleCarJack()
        if not ok then
            local msg = (jackErr and jackErr.fallback) or tuningLocales.CarJackControlFailed or "Unable to use car jack right now."
            notify(msg, "error")
            return false
        end

        ensureWheelTheftBricksForVehicle(vehicle)
        WheelTheftState.step = "complete"
        updateWheelTheftChecklist()
        resetWheelTheftState(false)
        return true
    end

    return false
end

local function startWheelTheftInputLoop()
    if WheelTheftState.inputLoopRunning then return end
    WheelTheftState.inputLoopRunning = true

    CreateThread(function()
        while WheelTheftState.active do
            if IsControlJustPressed(0, CONTROL_INTERACT) then
                processWheelTheftStep()
            elseif IsControlJustPressed(0, CONTROL_CANCEL) then
                resetWheelTheftState(true)
                notify(tuningLocales.WheelTheftCanceled or "Wheel theft canceled.", "info")
            end
            Wait(0)
        end
        WheelTheftState.inputLoopRunning = false
    end)
end

-- ── Event Handlers ───────────────────────────────────

local function startWheelTheftProcess()
    if OrderInstallState.active or CatalyticInstallState.active or WheelTheftState.active then
        notify(tuningLocales.Busy or "Tuning menu is already open.", "error")
        return
    end

    local vehicle, targetWheel = getNearestDetachWheelTarget()
    if vehicle == nil or vehicle == 0 or not DoesEntityExist(vehicle) then
        notify(tuningLocales.WheelTheftNoVehicle or "No nearby vehicle found.", "error")
        return
    end

    if not targetWheel then
        notify(tuningLocales.WheelTheftNotNear or "Move closer to a wheel to steal it.", "error")
        return
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    local vehCoords = GetEntityCoords(vehicle)
    if #(pedCoords - vehCoords) > SEARCH_RADIUS + 2.0 then
        notify(tuningLocales.WheelTheftTooFar or "Move closer to the vehicle.", "error")
        return
    end

    local wheelIndexes = expandWheelIndexes(targetWheel.index)
    if isWheelDetached(vehicle, wheelIndexes) then
        notify(tuningLocales.WheelTheftAlreadyMissing or "This wheel has already been stolen.", "error")
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local plate = normalizePlate(GetVehicleNumberPlateText(vehicle))

    local res = Sky.Cb.Trigger("sky_mechanicjob:wheelTheft:prepareSteal", {
        vehicleNetId = netId,
        plate = plate,
        wheelIndexes = wheelIndexes
    }) or {}

    if not (type(res) == "table" and res.success == true) then
        local msg = tuningLocales.WheelTheftMissingItem or "You need a lug wrench."
        if type(res) == "table" then
            if res.error == "already_missing" then
                msg = tuningLocales.WheelTheftAlreadyMissing or "This wheel has already been stolen."
            elseif res.error == "vehicle_too_far" then
                msg = tuningLocales.WheelTheftTooFar or "Move closer to the vehicle."
            end
        end
        notify(msg, "error")
        return
    end

    WheelTheftState.active = true
    WheelTheftState.step = "lift"
    WheelTheftState.vehicle = vehicle
    WheelTheftState.vehicleNetId = netId
    WheelTheftState.plate = plate
    WheelTheftState.wheelIndexes = wheelIndexes

    updateWheelTheftChecklist()
    startWheelTheftInputLoop()

    notify(tuningLocales.WheelTheftStarted or "Wheel theft started.", "info")
end

RegisterNetEvent("sky_mechanicjob:wheelTheft:start", function()
    startWheelTheftProcess()
end)

RegisterNetEvent("sky_mechanicjob:lugWrench:chooseTheft", function()
    if WheelTheftState.choiceActive then return end

    if OrderInstallState.active or CatalyticInstallState.active or WheelTheftState.active then
        notify(tuningLocales.Busy or "Tuning menu is already open.", "error")
        return
    end

    WheelTheftState.choiceActive = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    sendUi("lugWrench:choice:open", {})
end)

RegisterNUICallback("lugWrench:choice", function(data, cb)
    local choice = tostring((data and data.choice) or "")

    WheelTheftState.choiceActive = false
    releaseNuiFocus()
    sendUi("lugWrench:choice:close", {})

    cb({ success = true })

    if choice == "catalytic" then
        TriggerEvent("sky_mechanicjob:catalytic:startSteal")
        return
    end

    if choice == "wheel" then
        TriggerEvent("sky_mechanicjob:wheelTheft:start")
        return
    end

    notify(tuningLocales.LugWrenchTheftChoiceCanceled or "Lug wrench action canceled.", "info")
end)
