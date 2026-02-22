-- Data layer runtime state bootstrap and per-run initialization.

ExpansionRuntimeState = {}
ExpansionImplementationQueue = {
    "classes_combat_split",
    "chest_drop_conversion",
    "inventory_stash_weight",
    "trader_economy_loop",
    "high_score_death_flow_achievements_ui",
}

local function copyList(src)
    local out = {}
    if not src then return out end
    for i = 1, #src do
        out[i] = src[i]
    end
    return out
end

local function makeDefaultBuildState()
    return {
        class_id = "warrior",
        level = 1,
        xp = 0,
        stat_points = 0,
        weapon_mastery_points = 0,
        stats = {
            vitality = 0,
            strength = 0,
            dexterity = 0,
            intellect = 0,
        },
        weapon_mastery = {
            [1] = 0, -- melee
            [2] = 0, -- ranged
            [3] = 0, -- magic
        },
        equipment = {
            weapon = nil,
            armor = nil,
            special_1 = nil,
            special_2 = nil,
        },
    }
end

local function makeDefaultInventoryState()
    return {
        max_weight = 30,
        current_weight = 0,
        items = {},
        quick_slots = {nil, nil, nil},
    }
end

local function makeDefaultStashState()
    return {
        max_weight = 120,
        current_weight = 0,
        items = {},
    }
end

function ExpansionRuntimeState.bootstrap()
    local defaultScores = {}
    local defaultAchievementState = newAchievementState and newAchievementState() or {unlocked = {}, progress = {}}
    local loadedScores = defaultScores
    local loadedAchievements = defaultAchievementState
    if ExpansionPersistence and ExpansionPersistence.loadHighScores then
        loadedScores = ExpansionPersistence.loadHighScores(defaultScores)
    end
    if ExpansionPersistence and ExpansionPersistence.loadAchievementState then
        loadedAchievements = ExpansionPersistence.loadAchievementState(defaultAchievementState)
    end

    return {
        player_build_state = makeDefaultBuildState(),
        inventory_state = makeDefaultInventoryState(),
        stash_state = makeDefaultStashState(),
        achievement_state = loadedAchievements,
        high_score_state = {entries = copyList(loadedScores)},
        score_state = GameScoreModel and GameScoreModel.newRun and GameScoreModel.newRun() or {current = 0},
    }
end

function ExpansionRuntimeState.beginRun(levelId, fallbackLevel)
    local startLevel = levelId or fallbackLevel or 1
    local runState = GameScoreModel and GameScoreModel.newRun and GameScoreModel.newRun() or {current = 0}
    runState.started_level = startLevel
    runState.ended_level = startLevel
    return {
        score_state = runState
    }
end
