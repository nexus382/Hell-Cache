-- Data layer: achievement registry and state helpers.

GameAchievements = {
    first_blood = {
        id = "first_blood",
        name = "First Blood",
        trigger = "kill_count",
        threshold = 1,
        reward = {score_bonus = 100},
    },
    survivor_10 = {
        id = "survivor_10",
        name = "Survivor 10",
        trigger = "levels_cleared",
        threshold = 10,
        reward = {score_bonus = 300},
    },
    flawless_1 = {
        id = "flawless_1",
        name = "Flawless",
        trigger = "no_damage_level",
        threshold = 1,
        reward = {score_bonus = 250},
    },
}

function newAchievementState()
    return {
        unlocked = {},
        progress = {},
    }
end

function markAchievementUnlocked(state, achievementId)
    if not state or not achievementId then
        return false
    end
    if state.unlocked[achievementId] then
        return false
    end
    state.unlocked[achievementId] = true
    return true
end
