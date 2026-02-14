-- Data layer: persistence hooks (stub-safe).
-- Paths are defined now; format writers/readers can be expanded incrementally.

ExpansionPersistence = {
    paths = {
        high_scores = "save/high_scores.dat",
        achievements = "save/achievements.dat",
    }
}

local function cloneTable(src)
    local out = {}
    if not src then return out end
    for k, v in pairs(src) do
        out[k] = v
    end
    return out
end

function ExpansionPersistence.loadHighScores(defaultValue)
    -- Hook point: wire vmupro.file-backed decode when format is finalized.
    return cloneTable(defaultValue or {})
end

function ExpansionPersistence.saveHighScores(scoreList)
    -- Hook point: wire vmupro.file-backed encode when format is finalized.
    return false, "not_implemented"
end

function ExpansionPersistence.loadAchievementState(defaultValue)
    local fallback = defaultValue or {unlocked = {}, progress = {}}
    return {
        unlocked = cloneTable(fallback.unlocked),
        progress = cloneTable(fallback.progress),
    }
end

function ExpansionPersistence.saveAchievementState(achievementState)
    -- Hook point: wire vmupro.file-backed encode when format is finalized.
    return false, "not_implemented"
end
