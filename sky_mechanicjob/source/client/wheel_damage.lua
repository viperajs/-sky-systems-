if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/wheel_damage.lua") end
local registerExport = (SkyDiagnostics and SkyDiagnostics.Export) or exports
-- =====================================================
--  sky_mechanicjob · source/client/wheel_damage.lua
--  Deobfuscated & Cleaned
-- =====================================================

local STATE_BAG_KEY = "sky_mechanic_wheel_damage"

local CFG_COLLISION = {
    minSpeedDropKmh = 32.0,
    minBodyHealthLoss = 12.0,
    speedDropDamage = 1.15,
    bodyHealthDamage = 1.8,
    sideBleedMultiplier = 0.45
}

local CFG_AIRTIME = {
    enabled = true,
    minAirTimeMs = 850,
    minLandingSpeedKmh = 42.0,
    minDownwardVelocity = 6.0,
    airTimeDamage = 0.035,
    verticalVelocityDamage = 7.5,
    landingSpeedDamage = 0.28
}

local CFG_DEBRIS = {
    leavePhysicalWheel = true,
    leaveDebrisTrail = true,
    putOnFire = false
}

local CFG_HANDLING = {
    enabled = true,
    fullyDisableVehicle = false,
    torqueMultiplierPerMissingWheel = 0.22,
    powerMultiplierPerMissingWheel = -18.0,
    reduceGripWhenDamaged = true,
    forceEngineOffWhenFullyDisabled = true
}

local CFG_BRICKS = {
    model = "ng_proc_brick_01a",
    zOffset = -0.12,
    sideInset = 0.55,
    axleInset = 1.05,
    stackCount = 2,
    stackSpacing = 0.115,
    headingOffset = 0.0,
    headingJitter = 14.0
}

local DEFAULT_MULTIPLIER = 1.0
local OFFROAD_WHEELS_MULTIPLIER = 1.0

local WheelDamageRuntime = {
    vehicle = 0,
    lastSpeedKmh = 0.0,
    lastBodyHealth = 1000.0,
    lastLocalVelocity = vector3(0.0, 0.0, 0.0),
    nextAirborneCheckAt = 0,
    fastUntil = 0,
    airborneSince = 0,
    airborneMinVelocityZ = 0.0,
    airborneMaxSpeedKmh = 0.0,
    localWheels = {},
    lastSyncAt = 0,
    lastDamageEventAt = 0,
    detachedApplied = {},
    brickProps = {},
    brickFrozenVehicles = {},
    wheelIndexCache = {},
    appliedStateByVehicle = {}
}

local WHEEL_CANDIDATE_BONES = DETACH_WHEEL_CANDIDATES or {
    { index = 0, label = "front_left",  bones = { "wheel_lf", "wheel_lf_dummy" } },
    { index = 1, label = "front_right", bones = { "wheel_rf", "wheel_rf_dummy" } },
    { index = 4, label = "rear_left",   bones = { "wheel_lr", "wheel_lr_dummy", "wheel_r", "wheel_r_dummy" } },
    { index = 5, label = "rear_right",  bones = { "wheel_rr", "wheel_rr_dummy" } }
}

-- ── Helpers ──────────────────────────────────────────

local function clamp(val, min, max)
    local num = tonumber(val) or 0.0
    if num < min then return min end
    if num > max then return max end
    return num
end

local function getVehicleUniqueKey(vehicle)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local model = GetEntityModel(vehicle)
    if netId <= 0 then
        return string.format("%s:%s", tostring(vehicle), tostring(model))
    end
    return string.format("%s:%s", tostring(netId), tostring(model))
end

local function isPlayerDriver(vehicle)
    return GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
end

local function getVehicleWheelIndexes(vehicle)
    local numWheels = math.max(0, math.floor(tonumber(GetVehicleNumberOfWheels(vehicle)) or 0))
    local cacheKey = string.format("%s:%s", tostring(GetEntityModel(vehicle)), tostring(numWheels))

    if WheelDamageRuntime.wheelIndexCache[cacheKey] then
        return WheelDamageRuntime.wheelIndexCache[cacheKey]
    end

    local result = {}
    local seen = {}

    for _, candidate in ipairs(WHEEL_CANDIDATE_BONES) do
        for _, boneName in ipairs(candidate.bones) do
            if GetEntityBoneIndexByName(vehicle, boneName) ~= -1 then
                local expanded = expandWheelIndexes and expandWheelIndexes(candidate.index) or { candidate.index }
                for _, idx in ipairs(expanded) do
                    if idx >= 0 and idx <= 7 and not seen[idx] then
                        result[#result + 1] = idx
                        seen[idx] = true
                    end
                end
                break
            end
        end
    end

    if #result == 0 then
        if numWheels == 4 then
            result = { 0, 1, 4, 5 }
        else
            for i = 0, math.min(numWheels - 1, 7) do
                result[#result + 1] = i
            end
        end
    end

    WheelDamageRuntime.wheelIndexCache[cacheKey] = result
    return result
end

local function isWheelDamageSupported(vehicle)
    if Config.ToggleFeatures and Config.ToggleFeatures.wheelDamage == false then return false end
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    local vehClass = GetVehicleClass(vehicle)
    local classMult = (Config.WheelDamage and Config.WheelDamage.multipliers and Config.WheelDamage.multipliers.vehicleClasses and Config.WheelDamage.multipliers.vehicleClasses[vehClass]) or 1.0
    if tonumber(classMult) == 0.0 then return false end

    return GetVehicleNumberOfWheels(vehicle) >= 4
end

local function getVehicleClassDamageMultiplier(vehicle)
    local mult = DEFAULT_MULTIPLIER
    local vehClass = GetVehicleClass(vehicle)
    local classMult = (Config.WheelDamage and Config.WheelDamage.multipliers and Config.WheelDamage.multipliers.vehicleClasses and Config.WheelDamage.multipliers.vehicleClasses[vehClass])
    if classMult ~= nil then
        mult = mult * (tonumber(classMult) or 1.0)
    end

    if GetVehicleWheelType(vehicle) == 4 then
        mult = mult * OFFROAD_WHEELS_MULTIPLIER
    end
    return mult
end

local function normalizeWheelEntry(data)
    if type(data) ~= "table" or not data then data = {} end
    local src = tostring(data.source or "")
    if src ~= "theft" then src = "damage" end

    return {
        damage = clamp(data.damage, 0.0, 250.0),
        popped = (data.popped == true),
        detached = (data.detached == true),
        source = src
    }
end

function getDetachedWheelDamageIndexes(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return {} end

    local stateBag = Entity(vehicle).state[STATE_BAG_KEY]
    local wheelsData = (type(stateBag) == "table" and type(stateBag.wheels) == "table") and stateBag.wheels or {}

    local result = {}
    for k, v in pairs(wheelsData) do
        local idx = math.floor(tonumber(k) or -1)
        if idx >= 0 and idx <= 7 and type(v) == "table" and v.detached == true then
            result[#result + 1] = idx
        end
    end

    table.sort(result)
    return result
end

function getWheelDamageRepairSummary(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return { tyres = { popped = 0, detached = 0, needsRepair = false } }
    end

    local stateBag = Entity(vehicle).state[STATE_BAG_KEY]
    local wheelsData = (type(stateBag) == "table" and type(stateBag.wheels) == "table") and stateBag.wheels or {}

    local poppedCount = 0
    local detachedCount = 0

    for _, v in pairs(wheelsData) do
        if type(v) == "table" then
            if v.popped == true then poppedCount = poppedCount + 1 end
            if v.detached == true then detachedCount = detachedCount + 1 end
        end
    end

    return {
        tyres = {
            popped = poppedCount,
            detached = detachedCount,
            needsRepair = (poppedCount > 0 or detachedCount > 0)
        }
    }
end

local function makeDetachedAppliedKey(vehicle, wheelIndex)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local model = GetEntityModel(vehicle)
    if netId <= 0 then
        return string.format("%s:%s:%s", tostring(vehicle), tostring(model), tostring(wheelIndex))
    end
    return string.format("%s:%s:%s", tostring(netId), tostring(model), tostring(wheelIndex))
end

local function applyPhysicalWheelState(vehicle, wheelIndex, wheelData)
    if wheelData.detached then
        local key = makeDetachedAppliedKey(vehicle, wheelIndex)
        if WheelDamageRuntime.detachedApplied[key] then return end

        local isTheft = (wheelData.source == "theft")
        local leaveTrail = isTheft or (CFG_DEBRIS.leaveDebrisTrail ~= false)
        local leavePhys = isTheft or (CFG_DEBRIS.leavePhysicalWheel == false)

        BreakOffVehicleWheel(vehicle, wheelIndex, leaveTrail, leavePhys, false, not isTheft)
        WheelDamageRuntime.detachedApplied[key] = true
        return
    end

    if wheelData.popped then
        SetVehicleTyreBurst(vehicle, wheelIndex, true, 1000.0)
    end
end

local function countDetachedFromState(wheelsData)
    local count = 0
    for _, v in pairs(wheelsData or {}) do
        if type(v) == "table" and v.detached == true then
            count = count + 1
        end
    end
    return count
end

local function isAnySeatOccupied(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    local maxSeats = math.max(0, math.floor(tonumber(GetVehicleMaxNumberOfPassengers(vehicle)) or 0))

    for seat = -1, maxSeats - 1 do
        if not IsVehicleSeatFree(vehicle, seat) then return true end
    end
    return false
end

local function updateVehicleFreezeForBricks(vehicle, freeze)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    local key = getVehicleUniqueKey(vehicle)

    if freeze then
        if not isAnySeatOccupied(vehicle) then
            FreezeEntityPosition(vehicle, true)
            WheelDamageRuntime.brickFrozenVehicles[key] = vehicle
        end
        return
    end

    if WheelDamageRuntime.brickFrozenVehicles[key] then
        FreezeEntityPosition(vehicle, false)
        WheelDamageRuntime.brickFrozenVehicles[key] = nil
    end
end

local function removeBricksForVehicle(vehicle)
    local key = getVehicleUniqueKey(vehicle)
    local propsData = WheelDamageRuntime.brickProps[key]

    if type(propsData) == "table" then
        for _, entry in pairs(propsData) do
            if type(entry) == "table" then
                for _, propObj in ipairs(entry) do
                    if propObj ~= 0 and DoesEntityExist(propObj) then
                        DeleteEntity(propObj)
                    end
                end
            elseif entry ~= 0 and DoesEntityExist(entry) then
                DeleteEntity(entry)
            end
        end
    end

    WheelDamageRuntime.brickProps[key] = nil
    updateVehicleFreezeForBricks(vehicle, false)
end

local function deleteWheelBrickStack(stacksDict, indexKey)
    local entry = stacksDict[indexKey]
    if type(entry) == "table" then
        for _, propObj in ipairs(entry) do
            if propObj ~= 0 and DoesEntityExist(propObj) then
                DeleteEntity(propObj)
            end
        end
    elseif entry and entry ~= 0 and DoesEntityExist(entry) then
        DeleteEntity(entry)
    end
    stacksDict[indexKey] = nil
end

local function isBrickStackIntact(stackList)
    if type(stackList) ~= "table" then return false end
    if #stackList < (CFG_BRICKS.stackCount or 3) then return false end

    for _, propObj in ipairs(stackList) do
        if propObj == 0 or not DoesEntityExist(propObj) then return false end
    end
    return true
end

local function computeBrickSpawnCoords(vehicle, wheelIndex)
    local minDim, maxDim = GetModelDimensions(GetEntityModel(vehicle))
    local halfWidth = math.max(math.abs(minDim.x), math.abs(maxDim.x))
    local sideInset = tonumber(CFG_BRICKS.sideInset) or 0.55
    local axleInset = tonumber(CFG_BRICKS.axleInset) or 1.05

    local offsetX = math.max(0.35, halfWidth - sideInset)
    local offsetY = 0.0

    if wheelIndex == 0 or wheelIndex == 2 or wheelIndex == 4 then
        offsetX = -offsetX
    end

    if wheelIndex == 0 or wheelIndex == 1 then
        offsetY = maxDim.y - axleInset
    elseif wheelIndex == 4 or wheelIndex == 5 then
        offsetY = minDim.y + axleInset
    else
        offsetY = (maxDim.y + minDim.y) * 0.5
    end

    local offsetZ = minDim.z + (tonumber(CFG_BRICKS.zOffset) or -0.12)
    local worldPos = GetOffsetFromEntityInWorldCoords(vehicle, offsetX, offsetY, offsetZ)

    return vector3(worldPos.x, worldPos.y, worldPos.z)
end

local function syncWheelBricksForVehicle(vehicle, wheelsData)
    local candidateIndexes = {}

    for _, cand in ipairs(WHEEL_CANDIDATE_BONES) do
        local idx = cand.index
        local entry = wheelsData[tostring(idx)]
        if type(entry) == "table" and entry.detached == true and entry.source == "theft" then
            candidateIndexes[idx] = true
        end
    end

    if not next(candidateIndexes) then
        removeBricksForVehicle(vehicle)
        return
    end

    local vehKey = getVehicleUniqueKey(vehicle)
    WheelDamageRuntime.brickProps[vehKey] = WheelDamageRuntime.brickProps[vehKey] or {}
    local vehicleBricks = WheelDamageRuntime.brickProps[vehKey]

    local brickHash = GetHashKey(CFG_BRICKS.model)
    if not requestModelLoaded(brickHash, 2500) then
        print(string.format("[sky_mechanicjob][wheel_theft] brick prop failed: model not loaded (%s)", CFG_BRICKS.model))
        return
    end

    local heading = GetEntityHeading(vehicle)

    for _, cand in ipairs(WHEEL_CANDIDATE_BONES) do
        local idx = cand.index
        if not candidateIndexes[idx] then
            deleteWheelBrickStack(vehicleBricks, idx)
        else
            if not isBrickStackIntact(vehicleBricks[idx]) then
                deleteWheelBrickStack(vehicleBricks, idx)
                local coords = computeBrickSpawnCoords(vehicle, idx)
                local stack = {}
                local count = math.max(1, math.floor(tonumber(CFG_BRICKS.stackCount) or 2))
                local spacing = tonumber(CFG_BRICKS.stackSpacing) or 0.115
                local jitter = math.max(0.0, tonumber(CFG_BRICKS.headingJitter) or 14.0)

                for i = 1, count do
                    local obj = CreateObjectNoOffset(brickHash, coords.x, coords.y, coords.z + (i - 1) * spacing, false, false, false)
                    if obj ~= 0 and DoesEntityExist(obj) then
                        local rotJitter = 0.0
                        if jitter > 0.0 then
                            rotJitter = (math.random(-jitter * 100, jitter * 100)) / 100.0
                        end

                        SetEntityHeading(obj, heading + CFG_BRICKS.headingOffset + rotJitter)
                        FreezeEntityPosition(obj, true)
                        stack[#stack + 1] = obj
                    else
                        print(string.format("[sky_mechanicjob][wheel_theft] brick prop failed: could not create object for wheel %s stack %s", tostring(idx), tostring(i)))
                    end
                end

                if #stack > 0 then
                    vehicleBricks[idx] = stack
                end
            end
        end
    end

    SetModelAsNoLongerNeeded(brickHash)
    updateVehicleFreezeForBricks(vehicle, true)
end

function ensureWheelTheftBricksForVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        print("[sky_mechanicjob][wheel_theft] brick refresh failed: invalid vehicle")
        return
    end

    local stateBag = Entity(vehicle).state[STATE_BAG_KEY]
    local wheelsData = (type(stateBag) == "table" and type(stateBag.wheels) == "table") and stateBag.wheels or {}

    syncWheelBricksForVehicle(vehicle, wheelsData)
end

local function updateHandlingForWheelDamage(vehicle, wheelsData)
    if CFG_HANDLING.enabled == false then return end
    local detachedCount = countDetachedFromState(wheelsData)

    if detachedCount <= 0 then
        SetVehicleUndriveable(vehicle, false)
        SetVehicleReduceGrip(vehicle, false)
        SetVehicleEngineTorqueMultiplier(vehicle, 1.0)
        SetVehicleEnginePowerMultiplier(vehicle, 0.0)
        return
    end

    if CFG_HANDLING.reduceGripWhenDamaged ~= false then
        SetVehicleReduceGrip(vehicle, true)
    end

    local tqMultPerWheel = tonumber(CFG_HANDLING.torqueMultiplierPerMissingWheel) or 0.22
    local pwrMultPerWheel = tonumber(CFG_HANDLING.powerMultiplierPerMissingWheel) or -18.0

    local tqFactor = tqMultPerWheel * detachedCount
    local pwrFactor = pwrMultPerWheel * detachedCount

    SetVehicleEngineTorqueMultiplier(vehicle, math.max(0.08, 1.0 - tqFactor))
    SetVehicleEnginePowerMultiplier(vehicle, pwrFactor)

    if CFG_HANDLING.fullyDisableVehicle == true then
        if CFG_HANDLING.forceEngineOffWhenFullyDisabled ~= false then
            SetVehicleUndriveable(vehicle, true)
            SetVehicleEngineOn(vehicle, false, true, false)
        end
    end
end

local function resetHandlingProperties(vehicle)
    SetVehicleUndriveable(vehicle, false)
    SetVehicleReduceGrip(vehicle, false)
    SetVehicleEngineTorqueMultiplier(vehicle, 1.0)
    SetVehicleEnginePowerMultiplier(vehicle, 0.0)
end

local function fixAllTyresAndRemoveKeyCache(vehicle)
    local bodyH = GetVehicleBodyHealth(vehicle)
    local engineH = GetVehicleEngineHealth(vehicle)
    local tankH = GetVehiclePetrolTankHealth(vehicle)
    local dirt = GetVehicleDirtLevel(vehicle)

    SetVehicleFixed(vehicle)
    SetVehicleBodyHealth(vehicle, bodyH)
    SetVehicleEngineHealth(vehicle, engineH)
    SetVehiclePetrolTankHealth(vehicle, tankH)
    SetVehicleDirtLevel(vehicle, dirt)

    for _, idx in ipairs(getVehicleWheelIndexes(vehicle)) do
        SetVehicleTyreFixed(vehicle, idx)
        local key = makeDetachedAppliedKey(vehicle, idx)
        WheelDamageRuntime.detachedApplied[key] = nil
    end
end

local function resetVehicleWheelStateLocally(vehicle)
    local vehKey = getVehicleUniqueKey(vehicle)
    WheelDamageRuntime.localWheels = {}
    WheelDamageRuntime.appliedStateByVehicle[vehKey] = {}

    removeBricksForVehicle(vehicle)
    fixAllTyresAndRemoveKeyCache(vehicle)
    TriggerServerEvent("sky_mechanicjob:wheelDamage:reset", VehToNet(vehicle))
    resetHandlingProperties(vehicle)
end

local function areWheelEntriesEqual(a, b)
    local normA = normalizeWheelEntry(a)
    local normB = normalizeWheelEntry(b)
    return math.abs(normA.damage - normB.damage) < 0.01
end

local function syncVehicleStateBagData(vehicle, stateBagVal)
    local wheelsData = (type(stateBagVal) == "table" and type(stateBagVal.wheels) == "table") and stateBagVal.wheels or {}
    local vehKey = getVehicleUniqueKey(vehicle)
    local applied = WheelDamageRuntime.appliedStateByVehicle[vehKey] or {}

    local newApplied = {}

    if next(applied) and not next(wheelsData) then
        fixAllTyresAndRemoveKeyCache(vehicle)
        removeBricksForVehicle(vehicle)
    end

    for k, v in pairs(wheelsData) do
        local idx = math.floor(tonumber(k) or -1)
        if idx >= 0 then
            local entry = normalizeWheelEntry(v)
            local strKey = tostring(idx)
            newApplied[strKey] = entry

            if not areWheelEntriesEqual(applied[strKey], entry) then
                applyPhysicalWheelState(vehicle, idx, entry)
            end
        end
    end

    WheelDamageRuntime.appliedStateByVehicle[vehKey] = newApplied

    if WheelDamageRuntime.vehicle == vehicle then
        WheelDamageRuntime.localWheels = newApplied
    end

    if isPlayerDriver(vehicle) then
        updateHandlingForWheelDamage(vehicle, newApplied)
    end

    syncWheelBricksForVehicle(vehicle, newApplied)
end

local function applyDamageToWheels(vehicle, wheelIndexes, amount)
    local dmg = tonumber(amount) or 0.0
    if dmg <= 0.0 then return end

    local updates = {}
    local hasStateChanged = false
    local newPopped = false
    local newDetached = false

    for _, idx in ipairs(wheelIndexes) do
        local current = normalizeWheelEntry(WheelDamageRuntime.localWheels[tostring(idx)])
        if not current.detached then
            local wasPopped = current.popped
            local wasDetached = current.detached

            current.damage = clamp(current.damage + dmg, 0.0, 250.0)

            if current.damage >= 100.0 and not newPopped then
                current.popped = true
                newPopped = true
            end

            if current.damage >= 165.0 then
                if current.popped and not newDetached then
                    current.detached = true
                    newDetached = true
                end
            end

            if current.popped ~= wasPopped or current.detached ~= wasDetached then
                hasStateChanged = true
            end

            applyPhysicalWheelState(vehicle, idx, current)

            updates[#updates + 1] = {
                index = idx,
                damage = current.damage,
                popped = current.popped,
                detached = current.detached,
                source = "damage"
            }
        end
    end

    if #updates == 0 then return end

    syncWheelBricksForVehicle(vehicle, WheelDamageRuntime.localWheels)

    local now = GetGameTimer()
    if hasStateChanged or now >= WheelDamageRuntime.lastSyncAt + 1200 then
        WheelDamageRuntime.lastSyncAt = now
        TriggerServerEvent("sky_mechanicjob:wheelDamage:update", VehToNet(vehicle), updates)
    end
end

local function selectCollisionWheels(vehicle, localVel)
    local indexes = getVehicleWheelIndexes(vehicle)
    if #indexes <= 2 then return indexes end

    local isFrontImpact = localVel.y >= math.abs(localVel.x) * -0.35
    local isLeftImpact = localVel.x < 0.0
    local filtered = {}

    for _, idx in ipairs(indexes) do
        if isFrontImpact and (idx == 0 or idx == 1) then
            filtered[#filtered + 1] = idx
        elseif not isFrontImpact and (idx == 2 or idx == 3 or idx == 4 or idx == 5) then
            filtered[#filtered + 1] = idx
        end
    end

    if math.abs(localVel.x) > math.abs(localVel.y) * 0.65 then
        filtered = {}
        for _, idx in ipairs(indexes) do
            local isRightSide = (idx == 1 or idx == 3 or idx == 5)
            if (isLeftImpact and isRightSide) or (not isLeftImpact and not isRightSide) then
                filtered[#filtered + 1] = idx
            end
        end
    end

    if #filtered == 0 then return indexes end
    return filtered
end

local function processCollisionDamage(vehicle, speedDrop, healthLoss)
    local minSpeedDrop = tonumber(CFG_COLLISION.minSpeedDropKmh) or 32.0
    local minHealthLoss = tonumber(CFG_COLLISION.minBodyHealthLoss) or 12.0

    if speedDrop < minSpeedDrop and healthLoss < minHealthLoss then return end

    local totalDmg = math.max(0.0, speedDrop) * (tonumber(CFG_COLLISION.speedDropDamage) or 1.15)
        + math.max(0.0, healthLoss) * (tonumber(CFG_COLLISION.bodyHealthDamage) or 1.8)

    totalDmg = totalDmg * getVehicleClassDamageMultiplier(vehicle)

    local impactWheels = selectCollisionWheels(vehicle, WheelDamageRuntime.lastLocalVelocity)
    applyDamageToWheels(vehicle, impactWheels, totalDmg)

    local bleedMult = tonumber(CFG_COLLISION.sideBleedMultiplier) or 0.45
    if bleedMult > 0.0 then
        local primarySet = {}
        for _, idx in ipairs(impactWheels) do primarySet[idx] = true end

        local secondaryWheels = {}
        for _, idx in ipairs(getVehicleWheelIndexes(vehicle)) do
            if not primarySet[idx] then secondaryWheels[#secondaryWheels + 1] = idx end
        end

        applyDamageToWheels(vehicle, secondaryWheels, totalDmg * bleedMult)
    end
end

local function processAirborneLandingDamage(vehicle, now, currentSpeedKmh)
    if CFG_AIRTIME.enabled == false then return end
    local vel = GetEntityVelocity(vehicle)
    local inAir = IsVehicleOnAllWheels(vehicle) and IsEntityInAir(vehicle)

    if inAir then
        WheelDamageRuntime.fastUntil = now + 120
        if WheelDamageRuntime.airborneSince <= 0 then
            WheelDamageRuntime.airborneSince = now
            WheelDamageRuntime.airborneMinVelocityZ = vel.z
            WheelDamageRuntime.airborneMaxSpeedKmh = currentSpeedKmh
        else
            WheelDamageRuntime.airborneMinVelocityZ = math.min(WheelDamageRuntime.airborneMinVelocityZ, vel.z)
            WheelDamageRuntime.airborneMaxSpeedKmh = math.max(WheelDamageRuntime.airborneMaxSpeedKmh, currentSpeedKmh)
        end
        return
    end

    if WheelDamageRuntime.airborneSince <= 0 then return end

    local airTimeMs = now - WheelDamageRuntime.airborneSince
    local downwardVelZ = math.abs(math.min(0.0, WheelDamageRuntime.airborneMinVelocityZ))
    WheelDamageRuntime.airborneSince = 0
    WheelDamageRuntime.fastUntil = now + 650

    local minAir = tonumber(CFG_AIRTIME.minAirTimeMs) or 850
    local minLandingSpeed = tonumber(CFG_AIRTIME.minLandingSpeedKmh) or 42.0
    local minDownVel = tonumber(CFG_AIRTIME.minDownwardVelocity) or 6.0

    if airTimeMs < minAir or WheelDamageRuntime.airborneMaxSpeedKmh < minLandingSpeed or downwardVelZ < minDownVel then
        return
    end

    local dmg = airTimeMs * (tonumber(CFG_AIRTIME.airTimeDamage) or 0.035)
        + downwardVelZ * (tonumber(CFG_AIRTIME.verticalVelocityDamage) or 7.5)
        + WheelDamageRuntime.airborneMaxSpeedKmh * (tonumber(CFG_AIRTIME.landingSpeedDamage) or 0.28)

    dmg = dmg * getVehicleClassDamageMultiplier(vehicle)
    applyDamageToWheels(vehicle, getVehicleWheelIndexes(vehicle), dmg)
end

local function initLocalVehicleState(vehicle)
    WheelDamageRuntime.vehicle = vehicle
    WheelDamageRuntime.lastSpeedKmh = GetEntitySpeed(vehicle) * 3.6
    WheelDamageRuntime.lastBodyHealth = GetVehicleBodyHealth(vehicle)
    WheelDamageRuntime.lastLocalVelocity = GetEntitySpeedVector(vehicle, true)
    WheelDamageRuntime.nextAirborneCheckAt = 0
    WheelDamageRuntime.fastUntil = 0
    WheelDamageRuntime.airborneSince = 0
    WheelDamageRuntime.airborneMinVelocityZ = 0.0
    WheelDamageRuntime.airborneMaxSpeedKmh = 0.0
    WheelDamageRuntime.localWheels = {}
end

local function getDrivenVehicle()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return 0 end
    local veh = GetVehiclePedIsIn(ped, false)
    if GetPedInVehicleSeat(veh, -1) ~= ped then return 0 end
    return veh
end

-- ── Event Handlers & Main Loop ───────────────────────

AddEventHandler("gameEventTriggered", function(eventName, args)
    if eventName == "CEventNetworkPlayerEnteredVehicle" then
        local veh = (args and args[2]) or GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and DoesEntityExist(veh) then
            updateVehicleFreezeForBricks(veh, false)
        end
        return
    end

    if eventName ~= "CEventNetworkEntityDamage" then return end
    local entity = tonumber(args and args[1]) or 0
    if entity == 0 or not DoesEntityExist(entity) or GetEntityType(entity) ~= 2 then return end

    if not isWheelDamageSupported(entity) or not isPlayerDriver(entity) then return end

    if WheelDamageRuntime.vehicle ~= entity then
        initLocalVehicleState(entity)
        syncVehicleStateBagData(entity, Entity(entity).state[STATE_BAG_KEY])
    end

    local now = GetGameTimer()
    if now < WheelDamageRuntime.lastDamageEventAt + 700 then return end

    local currentSpeedKmh = GetEntitySpeed(entity) * 3.6
    local currentBodyHealth = GetVehicleBodyHealth(entity)
    local speedDrop = WheelDamageRuntime.lastSpeedKmh - currentSpeedKmh
    local healthLoss = WheelDamageRuntime.lastBodyHealth - currentBodyHealth

    if currentSpeedKmh >= 18.0 or WheelDamageRuntime.lastSpeedKmh >= 18.0 then
        processCollisionDamage(entity, speedDrop, healthLoss)
    end

    WheelDamageRuntime.lastDamageEventAt = now
    WheelDamageRuntime.lastSpeedKmh = currentSpeedKmh
    WheelDamageRuntime.lastBodyHealth = currentBodyHealth
    WheelDamageRuntime.lastLocalVelocity = GetEntitySpeedVector(entity, true)
end)

CreateThread(function()
    while true do
        if Config.ToggleFeatures and Config.ToggleFeatures.wheelDamage == false then
            Wait(5000)
        else
            for vehKey, veh in pairs(WheelDamageRuntime.brickFrozenVehicles) do
                if veh ~= 0 and DoesEntityExist(veh) then
                    if isAnySeatOccupied(veh) then
                        updateVehicleFreezeForBricks(veh, false)
                    end
                else
                    WheelDamageRuntime.brickFrozenVehicles[vehKey] = nil
                end
            end

            local veh = getDrivenVehicle()
            if not isWheelDamageSupported(veh) then
                if WheelDamageRuntime.vehicle ~= 0 then
                    WheelDamageRuntime.vehicle = 0
                    WheelDamageRuntime.localWheels = {}
                end
                Wait(1200)
            else
                if WheelDamageRuntime.vehicle ~= veh then
                    initLocalVehicleState(veh)
                    syncVehicleStateBagData(veh, Entity(veh).state[STATE_BAG_KEY])
                end

                local now = GetGameTimer()
                local speedKmh = GetEntitySpeed(veh) * 3.6
                local bodyH = GetVehicleBodyHealth(veh)

                if WheelDamageRuntime.airborneSince > 0 or now >= WheelDamageRuntime.nextAirborneCheckAt then
                    WheelDamageRuntime.nextAirborneCheckAt = now + 360
                    processAirborneLandingDamage(veh, now, speedKmh)
                end

                WheelDamageRuntime.lastSpeedKmh = speedKmh
                WheelDamageRuntime.lastBodyHealth = bodyH
                WheelDamageRuntime.lastLocalVelocity = GetEntitySpeedVector(veh, true)

                if WheelDamageRuntime.airborneSince > 0 or now < WheelDamageRuntime.fastUntil then
                    Wait(120)
                else
                    Wait(650)
                end
            end
        end
    end
end)

AddStateBagChangeHandler(STATE_BAG_KEY, nil, function(bagName, key, value)
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 or not DoesEntityExist(entity) then return end

    syncVehicleStateBagData(entity, value)
end)

RegisterNetEvent("sky_mechanicjob:wear:partRepaired", function(data)
    if type(data) ~= "table" or tostring(data.part or "") ~= "tyres" then return end
    local plate = Sky.Math.Trim(tostring(data.plate or ""))
    if plate == "" then return end

    local targetVeh = 0
    for _, veh in ipairs(GetGamePool("CVehicle")) do
        if DoesEntityExist(veh) and Sky.Math.Trim(tostring(GetVehicleNumberPlateText(veh) or "")) == plate then
            targetVeh = veh
            break
        end
    end

    if targetVeh ~= 0 and DoesEntityExist(targetVeh) then
        resetVehicleWheelStateLocally(targetVeh)
    end
end)

RegisterNetEvent("sky_mechanicjob:wheelDamage:fixVehicle", function(targetVehicle)
    local veh = tonumber(targetVehicle) or targetVehicle
    if not veh then veh = getDrivenVehicle() end
    if veh ~= 0 and DoesEntityExist(veh) then
        resetVehicleWheelStateLocally(veh)
    end
end)

AddEventHandler("onResourceStop", function(resName)
    if resName ~= GetCurrentResourceName() then return end

    for vehKey, veh in pairs(WheelDamageRuntime.brickFrozenVehicles) do
        if veh ~= 0 and DoesEntityExist(veh) then
            FreezeEntityPosition(veh, false)
        end
        WheelDamageRuntime.brickFrozenVehicles[vehKey] = nil
    end

    for vehKey, stacks in pairs(WheelDamageRuntime.brickProps) do
        for _, entry in pairs(stacks) do
            if type(entry) == "table" then
                for _, propObj in ipairs(entry) do
                    if propObj ~= 0 and DoesEntityExist(propObj) then DeleteEntity(propObj) end
                end
            elseif entry ~= 0 and DoesEntityExist(entry) then
                DeleteEntity(entry)
            end
        end
        WheelDamageRuntime.brickProps[vehKey] = nil
    end
end)

registerExport("FixWheelDamage", function(targetVehicle)
    local veh = tonumber(targetVehicle) or targetVehicle
    if not veh then veh = getDrivenVehicle() end
    if veh == 0 or not DoesEntityExist(veh) then return false end

    resetVehicleWheelStateLocally(veh)
    return true
end)
