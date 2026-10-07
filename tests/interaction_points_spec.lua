-- Run from the workspace root: lua tests/interaction_points_spec.lua
-- Loads sky_base/source/client/main.lua with mocked natives and checks how interaction
-- points are registered in marker mode and target mode.

local function vector3(x, y, z)
    return setmetatable({ x = x, y = y, z = z }, {
        __name = "vector3",
        __sub = function(a, b) return vector3(a.x - b.x, a.y - b.y, a.z - b.z) end,
        __len = function(v) return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z) end
    })
end

-- A function received from another resource: a callable table that errors when indexed.
local function funcref(fn)
    return setmetatable({ __cfx_functionReference = "ref" }, {
        __call = function(_, ...) return fn(...) end,
        __index = function() error("Cannot index a funcref") end
    })
end

local function load(target)
    local f = { exports = {}, zones = {}, entities = {}, threads = {}, events = {}, triggered = {} }
    local env = setmetatable({}, { __index = _G })
    env._G = env
    env.vector3 = vector3
    env.vec = vector3
    env.Config = { target = target, streamNpcEnabled = true, interactionDistance = 2.0, interactionDrawBuffer = 20.0, showMarkersWithTarget = false }
    env.Sky = {
        Config = env.Config,
        Debug = function() end,
        Show = { Blip = function() return 1 end, Marker = function() end, HelpNotification = function() end },
        Target = {
            IsEnabled = function() return target == "ox" or target == "qb" end,
            AddSphereZone = function(params) f.zones[#f.zones + 1] = params; return #f.zones end,
            AddLocalEntity = function(entity, options) f.entities[#f.entities + 1] = { entity = entity, options = options } end,
            RemoveZone = function() end,
            RemoveLocalEntity = function() end
        },
        Ped = { Delete = function() return true end }
    }
    env.exports = setmetatable({}, { __call = function(_, name, fn) f.exports[name] = fn end })
    env.CreateThread = function(fn) f.threads[#f.threads + 1] = fn end
    env.AddEventHandler = function(name, fn) f.events[name] = fn end
    env.RegisterNetEvent = function(name, fn) if fn then f.events[name] = fn end end
    env.RegisterCommand = function() end
    env.RegisterKeyMapping = function() end
    env.TriggerEvent = function(name, ...) f.triggered[#f.triggered + 1] = { name = name, args = table.pack(...) } end
    env.DoesEntityExist = function() return false end
    env.GetCurrentResourceName = function() return "sky_base" end
    env.GetGameTimer = function() return 0 end
    env.RemoveBlip = function() end
    assert(loadfile("sky_base/source/client/main.lua", "t", env))()
    f.env = env
    return f
end

-- Marker mode: the point is drawn and interacted with through InteractionPoints.
do
    local f = load("none")
    assert(f.exports.CreateInteractionPoint and f.exports.DeleteInteractionPoint, "interaction point exports")
    f.exports.CreateInteractionPoint(vector3(1.0, 2.0, 3.0), "Workshop - Duty", "ev:point", "id:duty", { type = 1 }, {}, {}, "sky_jobs_base", 2.0)
    local point = f.env.InteractionPoints["1"]
    assert(point and point.id == "id:duty" and point.resourceName == "sky_jobs_base" and point.marker.type == 1)
    f.exports.DeleteInteractionPoint("id:duty")
    assert(next(f.env.InteractionPoints) == nil, "point removed")

    -- Options from another resource: canInteract arrives as a callable table.
    local called = false
    f.exports.CreateInteractionPoint({ x = 1.0, y = 2.0, z = 3.0, canInteract = funcref(function() called = true; return true end) },
        "Instant", "ev:instant", "id:instant", {}, {}, {}, "sky_mechanicjob", 4.0)
    local instant = f.env.InteractionPoints["2"]
    assert(instant and instant.canInteract, "callable canInteract kept")
    assert(instant.canInteract(instant) == true and called)
end

-- Target mode with NPC streaming on (the default): a point without an NPC still gets a
-- target zone; a point with an NPC gets its option when the NPC streams in.
do
    local f = load("ox")
    f.exports.CreateInteractionPoint(vector3(1.0, 2.0, 3.0), "Workshop - Storage", "ev:point", "id:storage", { type = 1 }, {}, {}, "sky_jobs_base", 2.0)
    assert(#f.zones == 1 and f.zones[1].radius == 2.0, "sphere zone for a point without NPC")
    f.zones[1].options[1].onSelect()
    assert(f.triggered[1].name == "ev:point" and f.triggered[1].args[1] == "id:storage")

    f.exports.CreateInteractionPoint(vector3(5.0, 2.0, 3.0), "Dealer", "ev:point", "id:dealer", {}, { pedHash = "s_m_m_autoshop_01" }, {}, "sky_jobs_base", 2.0)
    assert(#f.zones == 1, "streamed NPC point waits for its ped")
    local dealer
    for _, pt in pairs(f.env.TargetPoints) do
        if pt.id == "id:dealer" then dealer = pt end
    end
    assert(dealer and dealer.npcSpec and dealer.npcSpec.pedHash == "s_m_m_autoshop_01" and dealer.targetOption)
end

print("PASS: interaction point exports, callable options, marker mode and target zones with NPC streaming.")
