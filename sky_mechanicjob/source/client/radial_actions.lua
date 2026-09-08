if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/radial_actions.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_mechanicjob · source/client/radial_actions.lua
--  Deobfuscated by Claude
--  Original: 3049 lines → Cleaned
-- =====================================================

local function getFluidRefillPartLabel()
    local part = tostring((OrderInstallState and OrderInstallState.repairPart) or "")
    if part == "" then
        return "Fluid"
    end
    return getNuiLocale(("tablet.diagnostics.parts.%s"):format(part), part)
end

local function getFluidRefillPourRadialLabel()
    local template = (tuningLocales and tuningLocales.FluidRefillPourRadialLabel) or "Pour %s"
    return template:format(getFluidRefillPartLabel())
end

local function getFluidRefillPourRadialDescription()
    local template = (tuningLocales and tuningLocales.FluidRefillPourRadialDescription) or "Open the cap and tilt the can to pour fresh %s."
    return template:format(getFluidRefillPartLabel())
end

registerExport("getRadialActions", function()
    if CarJackState.lifted then
        if CarJackState.vehicle == 0 or not DoesEntityExist(CarJackState.vehicle) then
            clearCarJackState()
        end
    end

    local liftActionAvailable = (type(isLiftRadialActionAvailable) == "function" and isLiftRadialActionAvailable())
    local liftAction = nil
    if liftActionAvailable then
        liftAction = {
            id = "access_lift",
            icon = "ArrowUpDown",
            label = (tuningLocales and tuningLocales.LiftAccessRadialLabel) or "Access Lift",
            description = (tuningLocales and tuningLocales.LiftAccessRadialDescription) or "Open lift controls for the nearby workshop lift."
        }
    end

    if not OrderInstallState.active then
        if liftAction then
            return { liftAction }
        end
        return {}
    end

    local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
    if veh == 0 or not DoesEntityExist(veh) then
        return {}
    end

    -- Repaint install workflow
    if RepaintOrderInstallState.active then
        local cancelAction = {
            id = "cancel_repaint",
            icon = "CircleX",
            label = (tuningLocales and tuningLocales.RepaintInstallCancelRadialLabel) or "Cancel Repaint",
            description = (tuningLocales and tuningLocales.RepaintInstallCancelRadialDescription) or "Cancel the active repaint process."
        }

        local nextAction = nextRepaintInstallActionId()
        if nextAction == "sand_vehicle" then
            return {
                {
                    id = "sand_vehicle",
                    icon = "Wrench",
                    label = (tuningLocales and tuningLocales.RepaintSandRadialLabel) or "Sand Vehicle",
                    description = (tuningLocales and tuningLocales.RepaintSandRadialDescription) or "Sand the vehicle and remove old paint."
                },
                cancelAction
            }
        elseif nextAction == "paint_vehicle" then
            return {
                {
                    id = "paint_vehicle",
                    icon = "SprayCan",
                    label = (tuningLocales and tuningLocales.RepaintPaintRadialLabel) or "Repaint Vehicle",
                    description = (tuningLocales and tuningLocales.RepaintPaintRadialDescription) or "Spray the new paint onto the vehicle."
                },
                cancelAction
            }
        end

        return { cancelAction }
    end

    -- Catalytic install workflow
    if CatalyticInstallState and CatalyticInstallState.active then
        local cancelAction = {
            id = "cancel_catalytic_install",
            icon = "CircleX",
            label = (tuningLocales and tuningLocales.OrderInstallCancelRadialLabel) or "Cancel Install",
            description = (tuningLocales and tuningLocales.OrderInstallCancelRadialDescription) or "Cancel the active part install."
        }

        local step = tostring(CatalyticInstallState.step or "")
        if step == "lift" then
            local targetVeh, targetBone = getNearestCarJackTarget()
            if targetVeh == veh and targetBone ~= nil then
                return {
                    {
                        id = "catalytic_lift",
                        icon = "Car",
                        label = (tuningLocales and tuningLocales.CarJackRadialLabel) or "Car Jack",
                        description = (tuningLocales and tuningLocales.CarJackRadialDescription) or "Lift the closest vehicle side with a car jack."
                    },
                    cancelAction
                }
            end
        elseif step == "work" then
            return {
                {
                    id = "catalytic_install",
                    icon = "Wrench",
                    label = (tuningLocales and tuningLocales.CatalyticInstallRadialLabel) or "Install Catalytic Converter",
                    description = (tuningLocales and tuningLocales.CatalyticInstallRadialDescription) or "Bolt in a replacement catalytic converter."
                },
                cancelAction
            }
        elseif step == "lower" then
            return {
                {
                    id = "catalytic_lower",
                    icon = "Car",
                    label = (tuningLocales and tuningLocales.CarJackRemoveRadialLabel) or "Remove Car Jack",
                    description = (tuningLocales and tuningLocales.CarJackRemoveRadialDescription) or "Lower the lifted vehicle and remove the car jack."
                },
                cancelAction
            }
        end

        return { cancelAction }
    end

    -- Simple install workflow
    if not WheelOrderInstallState.active then
        local cancelAction = {
            id = "cancel_order_install",
            icon = "CircleX",
            label = (tuningLocales and tuningLocales.OrderInstallCancelRadialLabel) or "Cancel Install",
            description = (tuningLocales and tuningLocales.OrderInstallCancelRadialDescription) or "Cancel the active part install."
        }

        local nextAction = nextSimpleInstallActionId()
        local flow = resolveSimpleInstallFlow()

        local isOilChange = (flow == "oil_change")
        local isUnderbodyNeon = (flow == "underbody_neon")
        local isStance = (flow == "stance")

        local pedCoords = GetEntityCoords(PlayerPedId())
        local vehCoords = GetEntityCoords(veh)
        local isNearVeh = #(pedCoords - vehCoords) <= 4.0
        local isActionAllowedNear = isNearVeh

        if nextAction == "install_order_part" then
            if type(getBodyworkInstallTargetCoords) == "function" then
                local targetCoords = getBodyworkInstallTargetCoords(veh, OrderInstallState.part)
                if targetCoords then
                    if type(isNearBodyworkInstallTarget) == "function" then
                        isActionAllowedNear = isNearBodyworkInstallTarget(veh, OrderInstallState.part, pedCoords)
                    else
                        isActionAllowedNear = false
                    end
                end
            end
        end

        if nextAction == "take_engine_hoist" and not isNearVeh then
            isActionAllowedNear = isNearAnyEngineHoistForOrderInstall()
        end

        if nextAction == "install_stance_wheel" then
            local liftState = getWorkshopLiftStateForVehicle(veh)
            if liftState and liftState.raised then
                local closestWheel = getClosestPendingStanceWheel(veh, pedCoords)
                isActionAllowedNear = (closestWheel ~= nil)
            else
                isActionAllowedNear = liftState ~= nil
            end
        end

        if isActionAllowedNear then
            local stepAction = nil

            if nextAction == "cut_armor_panel" then
                stepAction = {
                    id = "cut_armor_panel",
                    icon = "Scissors",
                    label = (tuningLocales and tuningLocales.ArmorInstallCutRadialLabel) or "Cut Panel",
                    description = (tuningLocales and tuningLocales.ArmorInstallCutRadialDescription) or "Cut and remove a nearby door, hood, or trunk."
                }
            elseif nextAction == "open_hood" then
                local currentFlow = resolveSimpleInstallFlow()
                local rawFlow = tostring(OrderInstallState.installFlow or "")
                local isFluidRefill = (rawFlow == "fluid_refill")

                local desc = (tuningLocales and tuningLocales.EngineSwapOpenHoodRadialDescription) or "Open the hood before starting the engine swap."
                if currentFlow == "hood_install" then
                    desc = (tuningLocales and tuningLocales.OrderInstallOpenHoodRadialDescription) or "Open the hood before installing this performance part."
                elseif isFluidRefill then
                    local tpl = (tuningLocales and tuningLocales.FluidRefillOpenHoodRadialDescription) or "Open the hood before refilling %s."
                    desc = tpl:format(getFluidRefillPartLabel())
                end

                stepAction = {
                    id = "open_hood",
                    icon = "Car",
                    label = (tuningLocales and tuningLocales.EngineSwapOpenHoodRadialLabel) or "Open Hood",
                    description = desc
                }
            elseif nextAction == "take_engine_hoist" then
                stepAction = {
                    id = "take_engine_hoist",
                    icon = "Hand",
                    label = (tuningLocales and tuningLocales.EngineSwapTakeHoistRadialLabel) or "Take Engine Hoist",
                    description = (tuningLocales and tuningLocales.EngineSwapTakeHoistRadialDescription) or "Take the nearest engine hoist and move it to the vehicle."
                }
            elseif nextAction == "attach_engine_hoist" then
                stepAction = {
                    id = "attach_engine_hoist",
                    icon = "Link",
                    label = (tuningLocales and tuningLocales.EngineSwapAttachHoistRadialLabel) or "Attach Engine Hoist",
                    description = (tuningLocales and tuningLocales.EngineSwapAttachHoistRadialDescription) or "Attach the hoist to the front of the vehicle."
                }
            elseif nextAction == "weld_armor_panel" then
                stepAction = {
                    id = "weld_armor_panel",
                    icon = "Wrench",
                    label = (tuningLocales and tuningLocales.ArmorInstallWeldRadialLabel) or "Weld Armor",
                    description = (tuningLocales and tuningLocales.ArmorInstallWeldRadialDescription) or "Weld and install the armored replacement panel."
                }
            elseif nextAction == "drain_old_oil" then
                stepAction = {
                    id = "drain_old_oil",
                    icon = "Droplets",
                    label = (tuningLocales and tuningLocales.OilChangeDrainRadialLabel) or "Drain Old Oil",
                    description = (tuningLocales and tuningLocales.OilChangeDrainRadialDescription) or "Stand below the lifted vehicle and drain the old oil."
                }
            elseif nextAction == "install_underbody_neon" then
                local copy = getUnderbodyInstallCopy(OrderInstallState.part)
                stepAction = {
                    id = "install_underbody_neon",
                    icon = copy.icon,
                    label = copy.label,
                    description = copy.description
                }
            elseif nextAction == "install_stance_wheel" then
                stepAction = {
                    id = "install_stance_wheel",
                    icon = "Wrench",
                    label = getNuiLocale("tablet.orders.stance_checklist.action", "Adjust Wheel Joint"),
                    description = getNuiLocale("tablet.orders.stance_checklist.action_description", "Adjust the stance at the nearest unfinished wheel.")
                }
            elseif nextAction == "pour_new_oil" then
                local rawFlow = tostring(OrderInstallState.installFlow or "")
                local isFluidRefill = (rawFlow == "fluid_refill")

                local pourLabel = isFluidRefill and getFluidRefillPourRadialLabel() or ((tuningLocales and tuningLocales.OilChangePourRadialLabel) or "Pour New Oil")
                local pourDesc = isFluidRefill and getFluidRefillPourRadialDescription() or ((tuningLocales and tuningLocales.OilChangePourRadialDescription) or "Open the oil cap and tilt the can to pour fresh oil into the engine.")

                stepAction = {
                    id = "pour_new_oil",
                    icon = "Droplets",
                    label = pourLabel,
                    description = pourDesc
                }
            elseif nextAction == "install_order_part" then
                stepAction = {
                    id = "install_order_part",
                    icon = "Wrench",
                    label = (tuningLocales and tuningLocales.OrderInstallRadialLabel) or "Install Part",
                    description = (tuningLocales and tuningLocales.OrderInstallRadialDescription) or "Install the selected order part on this vehicle."
                }
            elseif nextAction == "engine_swap" then
                stepAction = {
                    id = "engine_swap",
                    icon = "Cog",
                    label = (tuningLocales and tuningLocales.EngineSwapRadialLabel) or "Swap Engine",
                    description = (tuningLocales and tuningLocales.EngineSwapRadialDescription) or "Connect all hanging tubes to the matching engine ports."
                }
            end

            if not stepAction then
                if (isOilChange or isUnderbodyNeon or isStance) and liftAction then
                    return { liftAction, cancelAction }
                end
                return { cancelAction }
            end

            local result = { stepAction, cancelAction }
            if (isOilChange or isUnderbodyNeon or isStance) and liftAction then
                table.insert(result, liftAction)
            end
            return result
        end

        if (isOilChange or isUnderbodyNeon or isStance) and liftAction then
            return { liftAction, cancelAction }
        end
        return { cancelAction }
    end

    -- Wheel order install workflow
    local cancelWheelAction = {
        id = "cancel_wheel_change",
        icon = "CircleX",
        label = (tuningLocales and tuningLocales.WheelInstallCancelRadialLabel) or "Cancel Wheel Change",
        description = (tuningLocales and tuningLocales.WheelInstallCancelRadialDescription) or "Cancel the active wheel-change process."
    }

    local wheelActionId = nextWheelInstallActionId()

    if wheelActionId == "car_jack" then
        local targetVeh, targetBone = getNearestCarJackTarget()
        if targetVeh == veh and targetBone ~= nil then
            return {
                {
                    id = "car_jack",
                    icon = "Car",
                    label = (tuningLocales and tuningLocales.CarJackRadialLabel) or "Car Jack",
                    description = (tuningLocales and tuningLocales.CarJackRadialDescription) or "Lift the closest vehicle side with a car jack."
                },
                cancelWheelAction
            }
        end
        return { cancelWheelAction }
    end

    if wheelActionId == "detach_wheel" then
        local targetVeh, targetBone = getNearestDetachWheelTarget()
        if targetVeh == veh and targetBone ~= nil then
            return {
                {
                    id = "detach_wheel",
                    icon = "CircleOff",
                    label = (tuningLocales and tuningLocales.DetachWheelRadialLabel) or "Detach Wheel",
                    description = (tuningLocales and tuningLocales.DetachWheelRadialDescription) or "Detach the nearest wheel from this vehicle."
                },
                cancelWheelAction
            }
        end
        return { cancelWheelAction }
    end

    if wheelActionId == "attach_wheel" then
        local nearestVeh = select(1, getNearestDetachWheelTarget())
        if nearestVeh == veh then
            return {
                {
                    id = "attach_wheel",
                    icon = "CircleDot",
                    label = (tuningLocales and tuningLocales.AttachWheelRadialLabel) or "Attach Wheel",
                    description = (tuningLocales and tuningLocales.AttachWheelRadialDescription) or "Attach a new wheel on the detached hub."
                },
                cancelWheelAction
            }
        end
        print(("[sky_mechanicjob][wheel_attach][check] getRadialActions hidden (nearest=%s target=%s step=%s)"):format(
            tostring(nearestVeh), tostring(veh), tostring(WheelOrderInstallState.step)
        ))
        return { cancelWheelAction }
    end

    if wheelActionId == "install_brakes" then
        local nearestVeh = select(1, getNearestDetachWheelTarget())
        if nearestVeh == veh then
            return {
                {
                    id = "install_brakes",
                    icon = "Disc3",
                    label = (tuningLocales and tuningLocales.BrakeInstallRadialLabel) or "Install Brakes",
                    description = (tuningLocales and tuningLocales.BrakeInstallRadialDescription) or "Install the brake components before reattaching the wheel."
                },
                cancelWheelAction
            }
        end
        return { cancelWheelAction }
    end

    if wheelActionId == "install_suspension" then
        local nearestVeh = select(1, getNearestDetachWheelTarget())
        if nearestVeh == veh then
            return {
                {
                    id = "install_suspension",
                    icon = "Gauge",
                    label = (tuningLocales and tuningLocales.SuspensionInstallRadialLabel) or "Install Suspension",
                    description = (tuningLocales and tuningLocales.SuspensionInstallRadialDescription) or "Install the suspension components before reattaching the wheel."
                },
                cancelWheelAction
            }
        end
        return { cancelWheelAction }
    end

    if wheelActionId == "remove_car_jack" then
        local pedCoords = GetEntityCoords(PlayerPedId())
        local vehCoords = GetEntityCoords(veh)
        if CarJackState.lifted and CarJackState.vehicle == veh and #(pedCoords - vehCoords) <= DETACH_WHEEL_MAX_VEHICLE_DISTANCE then
            return {
                {
                    id = "remove_car_jack",
                    icon = "Car",
                    label = (tuningLocales and tuningLocales.CarJackRemoveRadialLabel) or "Remove Car Jack",
                    description = (tuningLocales and tuningLocales.CarJackRemoveRadialDescription) or "Lower the lifted vehicle and remove the car jack."
                },
                cancelWheelAction
            }
        end
        return { cancelWheelAction }
    end

    return { cancelWheelAction }
end)

registerExport("triggerRadialMenuAction", function(actionId)
    if actionId == "access_lift" then
        if type(openNearestLiftControlUi) ~= "function" then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.LiftNotNearby) or "No lift nearby." }
        end
        local success, errData = openNearestLiftControlUi()
        if not success then
            return false, errData
        end
        return true
    end

    if actionId == "cancel_order_install" then
        if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end
        clearOrderInstallState()
        notify((tuningLocales and tuningLocales.OrderInstallCanceled) or "Part install canceled.", "info")
        return true
    end

    if actionId == "install_order_part" then
        if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end

        local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
        if veh == 0 or not DoesEntityExist(veh) then
            clearOrderInstallState()
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.") }
        end

        local pedCoords = GetEntityCoords(PlayerPedId())
        local vehCoords = GetEntityCoords(veh)
        local isNearVeh = #(pedCoords - vehCoords) <= 4.0

        local targetCoords = (type(getBodyworkInstallTargetCoords) == "function") and getBodyworkInstallTargetCoords(veh, OrderInstallState.part) or nil
        local isNearTarget = false
        if targetCoords then
            isNearTarget = (type(isNearBodyworkInstallTarget) == "function") and isNearBodyworkInstallTarget(veh, OrderInstallState.part, pedCoords) or false
        end

        if (targetCoords and not isNearTarget) or (not targetCoords and not isNearVeh) then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallTooFar) or "Move closer to the connected order vehicle." }
        end

        local nextAction = nextSimpleInstallActionId()
        if nextAction and nextAction ~= "install_order_part" then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first." }
        end

        local ok, err = completeActiveOrderInstall(veh)
        if not ok then
            return false, err
        end
        return true
    end

    if actionId == "engine_swap" then
        if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end

        local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
        if veh == 0 or not DoesEntityExist(veh) then
            clearOrderInstallState()
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.") }
        end

        local pedCoords = GetEntityCoords(PlayerPedId())
        local vehCoords = GetEntityCoords(veh)
        if #(pedCoords - vehCoords) > 4.0 then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallTooFar) or "Move closer to the connected order vehicle." }
        end

        local nextAction = nextSimpleInstallActionId()
        if nextAction ~= "engine_swap" then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first." }
        end

        local ok, err = runTuningMinigame("engine_swap", veh, OrderInstallState.part)
        if not ok then
            return false, err
        end

        OrderInstallState.simpleStep = "complete"
        sendSimpleInstallChecklistUpdate()

        local compOk, compErr = completeActiveOrderInstall(veh)
        if not compOk then
            return false, compErr
        end

        if not IsVehicleDoorDamaged(veh, 4) then
            SetVehicleDoorShut(veh, 4, false)
        end
        return true
    end

    if actionId == "take_engine_hoist" then
        if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end

        local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
        if veh == 0 or not DoesEntityExist(veh) then
            clearOrderInstallState()
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.") }
        end

        local nextAction = nextSimpleInstallActionId()
        if nextAction ~= "take_engine_hoist" then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first." }
        end

        local ok, err = takeNearestEngineHoistForOrderInstall()
        if not ok then
            return false, err
        end

        OrderInstallState.simpleStep = "attach_hoist"
        sendSimpleInstallChecklistUpdate()
        notify((tuningLocales and tuningLocales.EngineSwapTakeHoistSuccess) or "Engine hoist taken. Attach it to the front of the vehicle.", "success")
        return true
    end

    if actionId == "attach_engine_hoist" then
        if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end

        local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
        if veh == 0 or not DoesEntityExist(veh) then
            clearOrderInstallState()
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.") }
        end

        local pedCoords = GetEntityCoords(PlayerPedId())
        local vehCoords = GetEntityCoords(veh)
        if #(pedCoords - vehCoords) > 4.0 then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallTooFar) or "Move closer to the connected order vehicle." }
        end

        local nextAction = nextSimpleInstallActionId()
        if nextAction ~= "attach_engine_hoist" then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first." }
        end

        local ok, err = attachEngineHoistToVehicleFront(veh)
        if not ok then
            return false, err
        end

        OrderInstallState.simpleStep = "engine_swap"
        sendSimpleInstallChecklistUpdate()
        notify((tuningLocales and tuningLocales.EngineSwapAttachHoistSuccess) or "Engine hoist attached. Start the engine swap minigame.", "success")
        return true
    end

    if actionId == "open_hood" then
        if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end

        local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
        if veh == 0 or not DoesEntityExist(veh) then
            clearOrderInstallState()
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.") }
        end

        local pedCoords = GetEntityCoords(PlayerPedId())
        local vehCoords = GetEntityCoords(veh)
        if #(pedCoords - vehCoords) > 4.0 then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallTooFar) or "Move closer to the connected order vehicle." }
        end

        local nextAction = nextSimpleInstallActionId()
        if nextAction ~= "open_hood" then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first." }
        end

        local flow = resolveSimpleInstallFlow()
        local isEngineSwap = (flow == "engine_swap")
        local isOilChange = (flow == "oil_change")
        local isFluidRefill = (flow == "fluid_refill")

        local nextStepName = "install"
        if isEngineSwap then
            nextStepName = doesActiveEngineInstallUseHoist() and "take_hoist" or "engine_swap"
        elseif isOilChange or isFluidRefill then
            nextStepName = "pour_oil"
        end

        local hasHood = HasVehicleHood(veh)
        if not hasHood or IsVehicleDoorDamaged(veh, 4) then
            OrderInstallState.simpleStep = nextStepName
            sendSimpleInstallChecklistUpdate()

            if isEngineSwap then
                local fallbackMsg = doesActiveEngineInstallUseHoist() and "Hood is missing/damaged, continue by taking the engine hoist." or "Hood is missing/damaged, continue with the engine swap."
                notify((tuningLocales and tuningLocales.EngineSwapHoodAlreadyOpen) or fallbackMsg, "info")
            elseif isOilChange then
                notify((tuningLocales and tuningLocales.OilChangeHoodAlreadyOpen) or "Hood is missing/damaged, continue by pouring fresh oil.", "info")
            elseif isFluidRefill then
                local tpl = (tuningLocales and tuningLocales.FluidRefillHoodAlreadyOpen) or "Hood is missing/damaged, continue by pouring fresh %s."
                notify(tpl:format(getFluidRefillPartLabel()), "info")
            else
                notify((tuningLocales and tuningLocales.OrderInstallHoodAlreadyOpen) or "Hood is missing/damaged, continue by installing the selected part.", "info")
            end
            return true
        end

        SetVehicleDoorOpen(veh, 4, false, false)
        OrderInstallState.simpleStep = nextStepName
        sendSimpleInstallChecklistUpdate()

        if isEngineSwap then
            local successMsg = doesActiveEngineInstallUseHoist() and "Hood opened. Take the engine hoist." or "Hood opened. Start the engine swap."
            notify((tuningLocales and tuningLocales.EngineSwapHoodOpened) or successMsg, "success")
        elseif isOilChange then
            notify((tuningLocales and tuningLocales.OilChangeHoodOpened) or "Hood opened. Pour fresh oil into the engine.", "success")
        elseif isFluidRefill then
            local tpl = (tuningLocales and tuningLocales.FluidRefillHoodOpened) or "Hood opened. Pour fresh %s."
            notify(tpl:format(getFluidRefillPartLabel()), "success")
        else
            notify((tuningLocales and tuningLocales.OrderInstallHoodOpened) or "Hood opened. Install the selected part.", "success")
        end
        return true
    end

    if actionId == "drain_old_oil" then
        if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end

        local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
        if veh == 0 or not DoesEntityExist(veh) then
            clearOrderInstallState()
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.") }
        end

        local pedCoords = GetEntityCoords(PlayerPedId())
        local vehCoords = GetEntityCoords(veh)
        if #(pedCoords - vehCoords) > 4.0 then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallTooFar) or "Move closer to the connected order vehicle." }
        end

        local nextAction = nextSimpleInstallActionId()
        if nextAction ~= "drain_old_oil" then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first." }
        end

        local liftState = (type(getWorkshopLiftStateForVehicle) == "function") and getWorkshopLiftStateForVehicle(veh) or nil
        if not liftState or not liftState.raised then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OilChangeLiftVehicleFirst) or "Raise the vehicle with the workshop lift first." }
        end

        local ok, err = runTuningMinigame("oil_drain", veh, OrderInstallState.part)
        if not ok then
            return false, err
        end

        OrderInstallState.simpleStep = "lower_vehicle"
        sendSimpleInstallChecklistUpdate()
        notify((tuningLocales and tuningLocales.OilChangeDrainSuccess) or "Old oil drained. Lower the vehicle using the workshop lift.", "success")
        return true
    end

    if actionId == "install_underbody_neon" then
        if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end

        local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
        if veh == 0 or not DoesEntityExist(veh) then
            clearOrderInstallState()
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.") }
        end

        local pedCoords = GetEntityCoords(PlayerPedId())
        local vehCoords = GetEntityCoords(veh)
        if #(pedCoords - vehCoords) > 4.0 then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallTooFar) or "Move closer to the connected order vehicle." }
        end

        local nextAction = nextSimpleInstallActionId()
        if nextAction ~= "install_underbody_neon" then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first." }
        end

        local liftState = getWorkshopLiftStateForVehicle(veh)
        if not liftState or not liftState.raised then
            local copy = getUnderbodyInstallCopy(OrderInstallState.part)
            local fallbackStr = copy.liftVehicleFirst or ((tuningLocales and tuningLocales.UnderbodyNeonLiftVehicleFirst) or "Raise the vehicle with the workshop lift first.")
            return false, { key = "radial.errors.generic", fallback = fallbackStr }
        end

        local ok, err = runUnderbodyNeonInstallAnim(veh, OrderInstallState.part)
        if not ok then
            return false, err
        end

        OrderInstallState.simpleStep = "complete"
        sendSimpleInstallChecklistUpdate()

        local compOk, compErr = completeActiveOrderInstall(veh)
        if not compOk then
            return false, compErr
        end
        return true
    end

    if actionId == "install_stance_wheel" then
        if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end

        local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
        if veh == 0 or not DoesEntityExist(veh) then
            clearOrderInstallState()
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.") }
        end

        local nextAction = nextSimpleInstallActionId()
        if nextAction ~= "install_stance_wheel" then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first." }
        end

        local liftState = getWorkshopLiftStateForVehicle(veh)
        if not liftState or not liftState.raised then
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.stance_checklist.lift_first", "Raise the vehicle with the workshop lift first.") }
        end

        local pedCoords = GetEntityCoords(PlayerPedId())
        local targetWheel = getClosestPendingStanceWheel(veh, pedCoords)
        if not targetWheel then
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.stance_checklist.move_to_wheel", "Move closer to an unfinished wheel joint.") }
        end

        local ok, err = runStanceWheelInstallAnim(veh)
        if not ok then
            return false, err
        end

        OrderInstallState.stanceCompletedWheels = OrderInstallState.stanceCompletedWheels or {}
        OrderInstallState.stanceCompletedWheels[targetWheel.id] = true

        if not areAllStanceWheelsCompleted() then
            sendSimpleInstallChecklistUpdate()
            notify(getNuiLocale("tablet.orders.stance_checklist.wheel_complete", "Wheel joint adjusted. Continue with the remaining wheels."), "success")
            return true
        end

        OrderInstallState.simpleStep = "complete"
        sendSimpleInstallChecklistUpdate()
        return completeActiveOrderInstall(veh)
    end

    if actionId == "pour_new_oil" then
        if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end

        local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
        if veh == 0 or not DoesEntityExist(veh) then
            clearOrderInstallState()
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.") }
        end

        local pedCoords = GetEntityCoords(PlayerPedId())
        local vehCoords = GetEntityCoords(veh)
        if #(pedCoords - vehCoords) > 4.0 then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallTooFar) or "Move closer to the connected order vehicle." }
        end

        local nextAction = nextSimpleInstallActionId()
        if nextAction ~= "pour_new_oil" then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first." }
        end

        local ok, err = runTuningMinigame("oil_pour", veh, OrderInstallState.part)
        if not ok then
            return false, err
        end

        OrderInstallState.simpleStep = "complete"
        sendSimpleInstallChecklistUpdate()

        local compOk, compErr = completeActiveOrderInstall(veh)
        if not compOk then
            return false, compErr
        end
        return true
    end

    if actionId == "cut_armor_panel" then
        if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end

        local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
        if veh == 0 or not DoesEntityExist(veh) then
            clearOrderInstallState()
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.") }
        end

        local pedCoords = GetEntityCoords(PlayerPedId())
        local vehCoords = GetEntityCoords(veh)
        if #(pedCoords - vehCoords) > 4.0 then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallTooFar) or "Move closer to the connected order vehicle." }
        end

        local nextAction = nextSimpleInstallActionId()
        if nextAction ~= "cut_armor_panel" then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first." }
        end

        local ok, err = runArmorPanelCutStep(veh, OrderInstallState.part)
        if not ok then
            return false, err
        end

        OrderInstallState.simpleStep = "weld"
        sendSimpleInstallChecklistUpdate()
        notify((tuningLocales and tuningLocales.ArmorInstallCutSuccess) or "Panel cut complete. Weld the armored replacement.", "success")
        return true
    end

    if actionId == "weld_armor_panel" then
        if not OrderInstallState.active or WheelOrderInstallState.active or RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end

        local veh = NetworkGetEntityFromNetworkId(OrderInstallState.vehicleNetId or 0)
        if veh == 0 or not DoesEntityExist(veh) then
            clearOrderInstallState()
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.vehicle_lost", "Connected vehicle is no longer available.") }
        end

        local pedCoords = GetEntityCoords(PlayerPedId())
        local vehCoords = GetEntityCoords(veh)
        if #(pedCoords - vehCoords) > 4.0 then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallTooFar) or "Move closer to the connected order vehicle." }
        end

        local nextAction = nextSimpleInstallActionId()
        if nextAction ~= "weld_armor_panel" then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first." }
        end

        OrderInstallState.simpleStep = "complete"
        sendSimpleInstallChecklistUpdate()

        local compOk, compErr = completeActiveOrderInstall(veh)
        if not compOk then
            return false, compErr
        end
        return true
    end

    if actionId == "cancel_repaint" then
        if not RepaintOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.RepaintInstallNotActive) or "Repaint actions are only available during a repaint install." }
        end
        clearOrderInstallState()
        notify((tuningLocales and tuningLocales.RepaintInstallCanceled) or "Repaint canceled.", "info")
        return true
    end

    if actionId == "cancel_catalytic_install" then
        if not CatalyticInstallState or not CatalyticInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end
        clearOrderInstallState()
        notify((tuningLocales and tuningLocales.OrderInstallCanceled) or "Part install canceled.", "info")
        return true
    end

    if actionId == "catalytic_lift" or actionId == "catalytic_install" or actionId == "catalytic_lower" then
        if not CatalyticInstallState or not CatalyticInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallNotActive) or "Part install is not active." }
        end
        local ok = performCatalyticAction()
        if not ok then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.OrderInstallWrongStep) or "Complete the current install step first." }
        end
        return true
    end

    if actionId == "sand_vehicle" or actionId == "paint_vehicle" then
        local ok, err, veh = ensureRepaintOrderStep(actionId)
        if not ok then
            return false, err
        end

        if actionId == "sand_vehicle" then
            local mgOk, mgErr = runTuningMinigame("spray_paint", veh, OrderInstallState.part, "sanding", true)
            if not mgOk then
                return false, mgErr
            end
            RepaintOrderInstallState.step = "painting"
            sendRepaintChecklistUpdate()
            notify((tuningLocales and tuningLocales.RepaintSandSuccess) or "Vehicle sanding complete.", "success")
            return true
        end

        local mgOk, mgErr = runTuningMinigame("spray_paint", veh, OrderInstallState.part, "painting", true)
        if not mgOk then
            return false, mgErr
        end

        if not applyOrderPartToVehicle(veh, OrderInstallState.part) then
            return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle.") }
        end

        RepaintOrderInstallState.step = "complete"
        sendRepaintChecklistUpdate()
        notify((tuningLocales and tuningLocales.RepaintPaintSuccess) or "Vehicle repaint complete.", "success")

        local compOk, compErr = completeActiveOrderInstall(veh, true)
        if not compOk then
            return false, compErr
        end
        return true
    end

    if actionId == "cancel_wheel_change" then
        if not WheelOrderInstallState.active then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallNotActive) or "Wheel actions are only available during a wheel order install." }
        end
        clearOrderInstallState()
        notify((tuningLocales and tuningLocales.WheelInstallCanceled) or "Wheel change canceled.", "info")
        return true
    end

    local wheelStepOk, wheelStepErr, targetVeh = ensureWheelOrderStep(actionId)
    if not wheelStepOk then
        if actionId == "attach_wheel" then
            local errText = type(wheelStepErr) == "table" and (wheelStepErr.fallback or wheelStepErr.key or "unknown") or tostring(wheelStepErr)
            print(("[sky_mechanicjob][wheel_attach][check] blocked by ensureWheelOrderStep (%s)"):format(errText))
        end
        return false, wheelStepErr
    end

    if actionId == "car_jack" then
        local nearestVeh, targetBone = getNearestCarJackTarget()
        if nearestVeh ~= targetVeh or targetBone == nil then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallWrongVehicle) or "Use this action on the connected order vehicle." }
        end

        local jackOk, jackErr = tryUseVehicleCarJack()
        if not jackOk then
            return false, jackErr
        end

        if not CarJackState.lifted or CarJackState.vehicle ~= targetVeh then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallWrongVehicle) or "Use this action on the connected order vehicle." }
        end

        WheelOrderInstallState.step = WheelOrderInstallState.skipDetach and "attach" or "detach"
        sendWheelChecklistUpdate()
        notify((tuningLocales and tuningLocales.CarJackSuccess) or "Vehicle side lifted.", "success")
        return true
    end

    if actionId == "remove_car_jack" then
        if not CarJackState.lifted or CarJackState.vehicle ~= targetVeh then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallWrongVehicle) or "Use this action on the connected order vehicle." }
        end

        local remOk, remErr = tryRemoveVehicleCarJack()
        if not remOk then
            return false, remErr
        end

        WheelOrderInstallState.step = "complete"
        sendWheelChecklistUpdate()
        notify((tuningLocales and tuningLocales.CarJackRemoveSuccess) or "Car jack removed.", "success")

        local compOk, compErr = completeActiveOrderInstall(targetVeh, true)
        if not compOk then
            return false, compErr
        end
        return true
    end

    if actionId == "detach_wheel" then
        local nearestVeh, targetBone = getNearestDetachWheelTarget()
        if nearestVeh ~= targetVeh or targetBone == nil then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallWrongVehicle) or "Use this action on the connected order vehicle." }
        end

        local detachOk, detachErr, detachedIdxs = tryDetachNearestVehicleWheel()
        if not detachOk then
            return false, detachErr
        end

        WheelOrderInstallState.detachedWheelIndexes = detachedIdxs
        if WheelOrderInstallState.requiresBrakeInstall then
            WheelOrderInstallState.step = "install_brakes"
        elseif WheelOrderInstallState.requiresSuspensionInstall then
            WheelOrderInstallState.step = "install_suspension"
        else
            WheelOrderInstallState.step = "attach"
        end

        sendWheelChecklistUpdate()
        notify((tuningLocales and tuningLocales.DetachWheelSuccess) or "Wheel detached.", "success")
        return true
    end

    if actionId == "install_brakes" then
        local nearestVeh = select(1, getNearestDetachWheelTarget())
        if nearestVeh ~= targetVeh then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallWrongVehicle) or "Use this action on the connected order vehicle." }
        end

        local animOk, animErr = runWheelBrakeInstallAnim(targetVeh, OrderInstallState.part)
        if not animOk then
            return false, animErr
        end

        WheelOrderInstallState.step = "attach"
        sendWheelChecklistUpdate()
        notify((tuningLocales and tuningLocales.BrakeInstallSuccess) or "Brake components installed.", "success")
        return true
    end

    if actionId == "install_suspension" then
        local nearestVeh = select(1, getNearestDetachWheelTarget())
        if nearestVeh ~= targetVeh then
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallWrongVehicle) or "Use this action on the connected order vehicle." }
        end

        local animOk, animErr = runWheelBrakeInstallAnim(targetVeh, OrderInstallState.part)
        if not animOk then
            return false, animErr
        end

        WheelOrderInstallState.step = "attach"
        sendWheelChecklistUpdate()
        notify((tuningLocales and tuningLocales.SuspensionInstallSuccess) or "Suspension components installed.", "success")
        return true
    end

    if actionId == "attach_wheel" then
        local nearestVeh = select(1, getNearestDetachWheelTarget())
        if nearestVeh ~= targetVeh then
            print(("[sky_mechanicjob][wheel_attach][check] wrong nearest vehicle (nearest=%s target=%s)"):format(
                tostring(nearestVeh), tostring(targetVeh)
            ))
            return false, { key = "radial.errors.generic", fallback = (tuningLocales and tuningLocales.WheelInstallWrongVehicle) or "Use this action on the connected order vehicle." }
        end

        local attachOk, attachErr = tryAttachNearestVehicleWheel(targetVeh, WheelOrderInstallState.detachedWheelIndexes, {
            attachUsesDirtyWheel = (WheelOrderInstallState.requiresBrakeInstall == true)
        })

        if not attachOk then
            local errText = type(attachErr) == "table" and (attachErr.fallback or attachErr.key or "unknown") or tostring(attachErr)
            print(("[sky_mechanicjob][wheel_attach][check] tryAttachNearestVehicleWheel failed (%s)"):format(errText))
            return false, attachErr
        end

        if not OrderInstallState.repairMode then
            if not applyOrderPartToVehicle(targetVeh, OrderInstallState.part) then
                return false, { key = "radial.errors.generic", fallback = getNuiLocale("tablet.orders.apply_failed", "Failed to apply this part on the vehicle.") }
            end
        end

        WheelOrderInstallState.step = "remove"
        sendWheelChecklistUpdate()
        notify((tuningLocales and tuningLocales.AttachWheelSuccess) or "New wheel attached.", "success")
        return true
    end

    return false, { key = "radial.errors.generic", fallback = "Action unavailable." }
end)
