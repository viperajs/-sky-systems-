if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_mechanicjob/source/client/tuning_minigames.lua") end
-- =====================================================
--  sky_mechanicjob · source/client/tuning_minigames.lua
--  Deobfuscated & Cleaned
-- =====================================================

TuningMinigames = TuningMinigames or {
    runners = {},
    sessions = {}
}

-- ── Helpers ──────────────────────────────────────────

local function buildNotRegisteredError(minigameId)
    return {
        key = "radial.errors.generic",
        fallback = string.format("Minigame '%s' is not registered.", tostring(minigameId)),
        messageType = "error"
    }
end

-- ── Core: Register / Run ─────────────────────────────

function TuningMinigames.Register(id, runner)
    local key = tostring(id or "")
    if key == "" then
        print("[sky_mechanicjob][tuning_minigames] register failed: empty minigame id")
        return
    end

    if type(runner) ~= "function" then
        print(string.format("[sky_mechanicjob][tuning_minigames] register failed: runner is not a function (%s)", key))
        return
    end

    TuningMinigames.runners[key] = runner
end

function TuningMinigames.Run(id, ...)
    local key = tostring(id or "")
    local runner = TuningMinigames.runners[key]

    if type(runner) ~= "function" then
        print(string.format("[sky_mechanicjob][tuning_minigames] run failed: unregistered minigame (%s)", key))
        return false, buildNotRegisteredError(key)
    end

    return runner(...)
end

function runTuningMinigame(id, ...)
    local key = tostring(id or "")
    if key == "" then
        print("[sky_mechanicjob][tuning_minigames] run failed: empty minigame id")
        return false, buildNotRegisteredError("unknown")
    end
    return TuningMinigames.Run(key, ...)
end

-- ── Session Helpers ──────────────────────────────────

function TuningMinigames.BuildError(message, msgType)
    return {
        key = "radial.errors.generic",
        fallback = tostring(message or "Minigame failed."),
        messageType = msgType or "error"
    }
end

local function resolveSessionInternal(sessionId, result)
    local session = TuningMinigames.sessions[sessionId]
    if not session then
        return false, "inactive"
    end

    local state = session.state
    result = (type(result) == "table" and result) or {
        success = false,
        cancelled = true,
        reason = "cancelled"
    }

    local success = result.success == true
    local cancelled = result.cancelled == true

    state.active = false
    state.resolved = true
    state.success = success
    state.cancelled = cancelled

    TuningMinigames.sessions[sessionId] = nil

    local reason
    if result.reason then
        reason = result.reason
    elseif cancelled then
        reason = "cancelled"
    elseif success then
        reason = "success"
    else
        reason = "failed"
    end

    session.promise:resolve({
        success = success,
        cancelled = cancelled,
        reason = tostring(reason)
    })

    return true
end

-- ── Session Management ───────────────────────────────

function TuningMinigames.StartSession(sessionId, opts)
    local key = tostring(sessionId or "")
    opts = (type(opts) == "table" and opts) or {}
    local state = opts.state

    if key == "" then
        print("[sky_mechanicjob][tuning_minigames] start failed: empty session id")
        return false, TuningMinigames.BuildError("Minigame session id is missing.")
    end

    if type(state) ~= "table" then
        print(string.format("[sky_mechanicjob][tuning_minigames] start failed: state missing for session %s", key))
        return false, TuningMinigames.BuildError("Minigame state is missing.")
    end

    if state.active then
        return false, opts.busyError or TuningMinigames.BuildError("Minigame is already running.")
    end

    state.active = true
    local token = math.floor(tonumber(state.token) or 0) + 1
    state.token = token
    state.resolved = false
    state.success = false
    state.cancelled = false

    local sessionPromise = promise.new()

    TuningMinigames.sessions[key] = {
        token = token,
        state = state,
        promise = sessionPromise
    }

    local timeoutMs = math.floor(tonumber(opts.timeoutMs) or 0)
    if timeoutMs > 0 then
        SetTimeout(timeoutMs, function()
            local s = TuningMinigames.sessions[key]
            if s and s.token == token and s.state.active then
                resolveSessionInternal(key, {
                    success = false,
                    cancelled = false,
                    reason = "timeout"
                })
            end
        end)
    end

    return true, { token = token, promise = sessionPromise }
end

function TuningMinigames.ResolveSession(sessionId, token, result)
    local key = tostring(sessionId or "")
    local tokenNum = math.floor(tonumber(token) or 0)

    local session = TuningMinigames.sessions[key]
    if not session then
        return false, "inactive"
    end

    if tokenNum > 0 and tokenNum ~= session.token then
        return false, "token_mismatch", session.token
    end

    return resolveSessionInternal(key, result)
end

function TuningMinigames.CancelSession(sessionId, result)
    local key = tostring(sessionId or "")
    local session = TuningMinigames.sessions[key]
    if not session then
        return false, "inactive"
    end

    result = (type(result) == "table" and result) or {
        success = false,
        cancelled = true,
        reason = "cancelled"
    }

    return resolveSessionInternal(key, result)
end

-- ── Minigame-Specific Result Handlers ────────────────

local function buildMinigameResultHandler(sessionKey, logPrefix)
    return function(data, cb)
        local token = math.floor(tonumber(data and data.token) or 0)

        local result = {}
        result.success = (data and data.success) == true
        result.cancelled = (data and data.cancelled) == true
        result.reason = (data and data.cancelled == true) and "cancelled" or "resolved"

        local ok, errReason, expectedToken = TuningMinigames.ResolveSession(sessionKey, token, result)

        if not ok and errReason == "token_mismatch" then
            print(string.format("[sky_mechanicjob][%s] invalid minigame token (%s), expected (%s)", logPrefix, tostring(token), tostring(expectedToken)))
            cb({ success = false, error = "token_mismatch" })
            return
        end

        cb({ success = true })
    end
end

TuningMinigames.HandleWheelDetachResult = buildMinigameResultHandler("wheel_change", "wheel_detach")
TuningMinigames.HandleEngineSwapResult = buildMinigameResultHandler("engine_swap", "engine_swap")
TuningMinigames.HandleOilDrainResult = buildMinigameResultHandler("oil_drain", "oil_drain")
TuningMinigames.HandleOilPourResult = buildMinigameResultHandler("oil_pour", "oil_pour")

-- ── Cancel All Active ────────────────────────────────

function TuningMinigames.CancelAllActive()
    local wheelCancelled = TuningMinigames.CancelSession("wheel_change")
    local engineCancelled = TuningMinigames.CancelSession("engine_swap")
    local oilDrainCancelled = TuningMinigames.CancelSession("oil_drain")
    local oilPourCancelled = TuningMinigames.CancelSession("oil_pour")

    if wheelCancelled or WheelDetachMinigameState.active then
        WheelDetachMinigameState.active = false
        WheelDetachMinigameState.resolved = true
        WheelDetachMinigameState.success = false
        WheelDetachMinigameState.cancelled = true
        stopWheelWorkAnim()
        closeWheelDetachMinigameUi()
    end

    if RepaintMinigameState.active then
        RepaintMinigameState.active = false
        RepaintMinigameState.resolved = true
        RepaintMinigameState.success = false
        RepaintMinigameState.cancelled = true
        closeRepaintMinigameUi()
    end

    if engineCancelled or EngineSwapMinigameState.active then
        EngineSwapMinigameState.active = false
        EngineSwapMinigameState.resolved = true
        EngineSwapMinigameState.success = false
        EngineSwapMinigameState.cancelled = true
        closeEngineSwapMinigameUi()
    end

    if oilDrainCancelled or OilDrainMinigameState.active then
        OilDrainMinigameState.active = false
        OilDrainMinigameState.resolved = true
        OilDrainMinigameState.success = false
        OilDrainMinigameState.cancelled = true
        closeOilDrainMinigameUi()
    end

    if oilPourCancelled or OilPourMinigameState.active then
        OilPourMinigameState.active = false
        OilPourMinigameState.resolved = true
        OilPourMinigameState.success = false
        OilPourMinigameState.cancelled = true
        closeOilPourMinigameUi()
    end
end

-- ── NUI Callbacks ────────────────────────────────────

RegisterNUICallback("wheelDetach:result", function(data, cb)
    TuningMinigames.HandleWheelDetachResult(data, cb)
end)

RegisterNUICallback("engineSwap:result", function(data, cb)
    TuningMinigames.HandleEngineSwapResult(data, cb)
end)

RegisterNUICallback("oilDrain:result", function(data, cb)
    TuningMinigames.HandleOilDrainResult(data, cb)
end)

RegisterNUICallback("oilPour:result", function(data, cb)
    TuningMinigames.HandleOilPourResult(data, cb)
end)
