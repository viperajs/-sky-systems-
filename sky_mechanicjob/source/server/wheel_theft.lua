if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/server/wheel_theft.lua") end
-- =====================================================
--  sky_mechanicjob · source/server/wheel_theft.lua
--  Wheel Theft RPCs & State Bag Synchronization
-- =====================================================

local TOTAL_WHEEL_POSITIONS = 4

-- A theft takes one wheel, or one rear pair on six-wheelers (see expandWheelIndexes on the client).
local PAIRED_WHEEL = { [2] = 4, [4] = 2, [3] = 5, [5] = 3 }

local function sanitizePlate(plate)
    if type(plate) ~= "string" then return "" end
    local trimmed = Sky and Sky.Math and Sky.Math.Trim and Sky.Math.Trim(plate)
    if not trimmed or trimmed == "" then return "" end
    return string.upper(trimmed)
end

local function sanitizeWheelIndexes(raw)
    if type(raw) ~= "table" then return nil end

    local result, seen = {}, {}
    for _, value in pairs(raw) do
        local idx = tonumber(value)
        if not idx or idx % 1 ~= 0 or idx < 0 or idx > 5 or seen[idx] then return nil end
        seen[idx] = true
        result[#result + 1] = math.floor(idx)
    end

    if #result == 0 or #result > 2 then return nil end
    if #result == 2 and PAIRED_WHEEL[result[1]] ~= result[2] then return nil end
    table.sort(result)
    return result
end

-- ── Prepare Wheel Steal Callback ─────────────────────

Sky.Cb.Register("sky_mechanicjob:wheelTheft:prepareSteal", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local cfg = MechanicTheft.GetConfig()
    if not Functions.HasItem(src, cfg.tool, 1) then
        return { success = false, error = "missing_item" }
    end

    local wheelIndexes = sanitizeWheelIndexes(data and data.wheelIndexes)
    if not wheelIndexes then
        return { success = false, error = "invalid_wheel" }
    end

    local netId = math.floor(tonumber(data and data.vehicleNetId) or 0)
    local entity = MechanicTheft.GetVehicle(src, netId)
    if not entity then
        return { success = false, error = "vehicle_too_far" }
    end

    if MechanicWheelDamage.AnyDetached(entity, wheelIndexes) then
        return { success = false, error = "already_missing" }
    end

    MechanicTheft.SetPending("wheel", src, { netId = netId, wheels = wheelIndexes })
    MechanicTheft.Dispatch(src, entity, sanitizePlate(GetVehicleNumberPlateText(entity)))
    return { success = true }
end)

-- ── Complete Wheel Steal Callback ────────────────────

Sky.Cb.Register("sky_mechanicjob:wheelTheft:completeSteal", function(source, data)
    local src = tonumber(source)
    if not src then return { success = false, error = "invalid_source" } end

    local netId = math.floor(tonumber(data and data.vehicleNetId) or 0)
    local pending = MechanicTheft.TakePending("wheel", src, netId)
    if not pending then
        return { success = false, error = "invalid_state" }
    end

    local cfg = MechanicTheft.GetConfig()
    if not Functions.HasItem(src, cfg.tool, 1) then
        return { success = false, error = "missing_item" }
    end

    local entity = MechanicTheft.GetVehicle(src, netId)
    if not entity then
        return { success = false, error = "vehicle_too_far" }
    end

    local wheels = MechanicWheelDamage.Read(entity)
    for _, idx in ipairs(pending.wheels) do
        local entry = wheels[tostring(idx)]
        if entry and entry.detached then
            return { success = false, error = "already_missing" }
        end
    end

    if not Functions.CanCarryItem(src, cfg.wheelItem, 1) then
        return { success = false, error = "inventory_full" }
    end
    if cfg.removeTool and not Functions.RemoveItem(src, cfg.tool, 1) then
        return { success = false, error = "missing_item" }
    end

    -- Take the wheel off the vehicle first so a second thief cannot claim it too.
    local previous = {}
    for _, idx in ipairs(pending.wheels) do
        local key = tostring(idx)
        previous[key] = wheels[key] or false
        wheels[key] = { damage = 100.0, popped = true, detached = true, source = "theft" }
    end
    MechanicWheelDamage.Write(entity, wheels)

    if not Functions.AddItem(src, cfg.wheelItem, 1) then
        for key, entry in pairs(previous) do
            wheels[key] = entry or nil
        end
        MechanicWheelDamage.Write(entity, wheels)
        if cfg.removeTool then Functions.AddItem(src, cfg.tool, 1) end
        return { success = false, error = "inventory_full" }
    end

    local detachedCount, allWheelsMissing = MechanicWheelDamage.CountMissing(wheels)
    return {
        success = true,
        detachedCount = detachedCount,
        totalCount = TOTAL_WHEEL_POSITIONS,
        allWheelsMissing = allWheelsMissing
    }
end)
