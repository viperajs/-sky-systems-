if SkyDiagnostics then SkyDiagnostics.FileStarted("sky_jobs_base/source/client/bodycam_recorder.lua") end
-- =====================================================
--  sky_jobs_base · source/client/bodycam_recorder.lua
--  Deobfuscated & Cleaned
-- =====================================================

local function getRecordBufferMinutes()
    local cfg = Config and Config.Cctv
    local mins = tonumber(cfg and cfg.recordBufferMinutes)
    if mins == nil then return 5 end
    return math.max(0, mins)
end

local function isBodycamRecorderEnabled()
    local cfg = Config and Config.Cctv
    return cfg and cfg.bodycamRecorderEnabled ~= false
end

local function getRecordBitrate()
    local cfg = Config and Config.Cctv
    local rate = tonumber(cfg and cfg.recordBitrateKbps)
    if not rate or rate <= 0 then return 1500 end
    return rate
end

local isBufferingActive = false

local function setBuffering(active)
    if not isBodycamRecorderEnabled() then
        isBufferingActive = false
        SendNUIMessage({ type = "bodycam:bufferStop" })
        return
    end

    isBufferingActive = active == true
    if isBufferingActive then
        local mins = getRecordBufferMinutes()
        if mins > 0 then
            SendNUIMessage({
                type = "bodycam:bufferStart",
                data = {
                    bufferMinutes = mins,
                    bitrateKbps = getRecordBitrate()
                }
            })
            return
        end
    end

    SendNUIMessage({ type = "bodycam:bufferStop" })
end

local function handleAccessState(stateData)
    if type(stateData) ~= "table" then return end
    setBuffering(stateData.onDuty == true)
end

CreateThread(function()
    Wait(500)
    local isOnDuty = Sky_Jobs and Sky_Jobs.Access and Sky_Jobs.Access.IsOnDuty and Sky_Jobs.Access.IsOnDuty()
    setBuffering(isOnDuty)
end)

RegisterNetEvent("sky_jobs_base:access:stateChanged", function(stateData)
    handleAccessState(stateData)
end)

AddEventHandler("sky_jobs_base:uiReady", function()
    setBuffering(isBufferingActive)
end)

RegisterNetEvent("sky_jobs_base:bodycam:saveBuffer", function(data)
    if not isBodycamRecorderEnabled() then return end
    SendNUIMessage({
        type = "bodycam:saveBuffer",
        data = data or {}
    })
end)

RegisterNUICallback("cctv:bodycamSaveResult", function(data, cb)
    if not isBodycamRecorderEnabled() then
        cb({ success = false, error = "disabled" })
        return
    end

    TriggerServerEvent("sky_jobs_base:bodycam:saveResult", data or {})
    cb({ success = true })
end)

AddEventHandler("onResourceStop", function(resName)
    if resName == GetCurrentResourceName() then
        setBuffering(false)
    end
end)
