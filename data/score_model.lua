-- Data layer: run score and top-10 high score helpers.

GameScoreModel = {}

function GameScoreModel.newRun()
    return {
        current = 0,
        kills = 0,
        levels_cleared = 0,
        started_level = 1,
        ended_level = 1,
    }
end

function GameScoreModel.addPoints(runState, amount)
    if not runState then
        return 0
    end
    local delta = amount or 0
    if delta < 0 then delta = 0 end
    runState.current = (runState.current or 0) + delta
    return runState.current
end

function GameScoreModel.sanitizeInitials(initials)
    local s = tostring(initials or "AAA"):upper()
    local out = ""
    for i = 1, #s do
        local c = s:sub(i, i)
        if c >= "A" and c <= "Z" then
            out = out .. c
        end
        if #out == 3 then
            break
        end
    end
    while #out < 3 do
        out = out .. "A"
    end
    return out
end

function GameScoreModel.createEntry(initials, score, levelReached)
    return {
        initials = GameScoreModel.sanitizeInitials(initials),
        score = math.max(0, math.floor(score or 0)),
        level = math.max(1, math.floor(levelReached or 1)),
    }
end

function GameScoreModel.insertHighScore(list, entry, maxEntries)
    local scores = list or {}
    scores[#scores + 1] = entry
    table.sort(scores, function(a, b)
        local sa = (a and a.score) or 0
        local sb = (b and b.score) or 0
        if sa == sb then
            return ((a and a.level) or 0) > ((b and b.level) or 0)
        end
        return sa > sb
    end)
    local limit = maxEntries or 10
    while #scores > limit do
        table.remove(scores)
    end
    return scores
end
