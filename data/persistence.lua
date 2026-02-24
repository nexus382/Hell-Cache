-- Data layer: persistence helpers for high scores and achievements.
-- Uses VMU Pro file APIs when available and degrades safely when unavailable.

ExpansionPersistence = {
    paths = {
        high_scores = "/sdcard/inner_sanctum/high_scores_v1.dat",
        achievements = "/sdcard/inner_sanctum/achievements_v1.dat",
    }
}

local PERSIST_DIR = "/sdcard/inner_sanctum"
local HIGH_SCORE_HEADER = "IS_HS_V1"
local ACHIEVEMENT_HEADER = "IS_ACH_V1"
local HIGH_SCORE_MAX_ENTRIES = 10

local function cloneTable(src)
    local out = {}
    if not src then return out end
    for k, v in pairs(src) do
        out[k] = v
    end
    return out
end

local function cloneList(src)
    local out = {}
    if not src then return out end
    for i = 1, #src do
        out[i] = src[i]
    end
    return out
end

local function hasFileApi()
    return vmupro and vmupro.file and vmupro.file.read and vmupro.file.write
end

local function ensureStoragePath(path)
    if not hasFileApi() then
        return false, "file_api_unavailable"
    end
    if vmupro.file.folderExists and vmupro.file.createFolder then
        if not vmupro.file.folderExists(PERSIST_DIR) then
            local okFolder = vmupro.file.createFolder(PERSIST_DIR)
            if not okFolder then
                return false, "create_folder_failed"
            end
        end
    end
    if vmupro.file.exists and vmupro.file.createFile and path and (not vmupro.file.exists(path)) then
        vmupro.file.createFile(path)
    end
    return true, nil
end

local function splitByPlain(input, separator)
    local out = {}
    local text = tostring(input or "")
    local sep = separator or "|"
    if sep == "" then
        out[1] = text
        return out
    end
    local start = 1
    while true do
        local idx = string.find(text, sep, start, true)
        if not idx then
            out[#out + 1] = string.sub(text, start)
            break
        end
        out[#out + 1] = string.sub(text, start, idx - 1)
        start = idx + #sep
    end
    return out
end

local function sanitizeToken(value)
    local text = tostring(value or "")
    text = string.gsub(text, "\r", "")
    text = string.gsub(text, "\n", "")
    text = string.gsub(text, "|", "")
    return text
end

local function sanitizeInitials(value)
    if GameScoreModel and GameScoreModel.sanitizeInitials then
        return GameScoreModel.sanitizeInitials(value)
    end
    local s = tostring(value or "AAA"):upper()
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

local function scoreCompare(a, b)
    local sa = math.floor(tonumber(a and a.score) or 0)
    local sb = math.floor(tonumber(b and b.score) or 0)
    if sa == sb then
        local la = math.floor(tonumber(a and a.level) or 0)
        local lb = math.floor(tonumber(b and b.level) or 0)
        return la > lb
    end
    return sa > sb
end

local function normalizeHighScoreList(scoreList)
    local out = {}
    local src = scoreList or {}
    for i = 1, #src do
        local e = src[i]
        local entry = {
            initials = sanitizeInitials(e and e.initials or "AAA"),
            score = math.floor(tonumber(e and e.score) or 0),
            level = math.floor(tonumber(e and e.level) or 1),
        }
        if entry.score < 0 then entry.score = 0 end
        if entry.level < 1 then entry.level = 1 end
        if GameScoreModel and GameScoreModel.insertHighScore then
            out = GameScoreModel.insertHighScore(out, entry, HIGH_SCORE_MAX_ENTRIES)
        else
            out[#out + 1] = entry
        end
    end
    if not (GameScoreModel and GameScoreModel.insertHighScore) then
        table.sort(out, scoreCompare)
        while #out > HIGH_SCORE_MAX_ENTRIES do
            table.remove(out)
        end
    end
    return out
end

local function sortedKeys(mapTable)
    local keys = {}
    if not mapTable then
        return keys
    end
    for key, _ in pairs(mapTable) do
        keys[#keys + 1] = tostring(key)
    end
    table.sort(keys)
    return keys
end

function ExpansionPersistence.loadHighScores(defaultValue)
    local fallback = cloneList(defaultValue or {})
    if not hasFileApi() then
        return fallback
    end

    local path = ExpansionPersistence.paths.high_scores
    if vmupro.file.exists and (not vmupro.file.exists(path)) then
        return fallback
    end

    local payload = vmupro.file.read(path)
    if not payload or payload == "" then
        return fallback
    end

    local normalized = string.gsub(tostring(payload), "\r", "")
    local lines = {}
    for line in string.gmatch(normalized, "([^\n]+)") do
        if line and line ~= "" then
            lines[#lines + 1] = line
        end
    end
    if #lines == 0 or lines[1] ~= HIGH_SCORE_HEADER then
        return fallback
    end

    local loaded = {}
    for i = 2, #lines do
        local parts = splitByPlain(lines[i], "|")
        if #parts >= 3 then
            loaded[#loaded + 1] = {
                initials = sanitizeInitials(parts[1]),
                score = math.floor(tonumber(parts[2]) or 0),
                level = math.floor(tonumber(parts[3]) or 1),
            }
        end
    end
    if #loaded == 0 then
        return fallback
    end
    return normalizeHighScoreList(loaded)
end

function ExpansionPersistence.saveHighScores(scoreList)
    if not hasFileApi() then
        return false, "file_api_unavailable"
    end
    local path = ExpansionPersistence.paths.high_scores
    local okPath, errPath = ensureStoragePath(path)
    if not okPath then
        return false, errPath
    end

    local normalized = normalizeHighScoreList(scoreList or {})
    local lines = {HIGH_SCORE_HEADER}
    for i = 1, #normalized do
        local e = normalized[i]
        lines[#lines + 1] = table.concat({
            sanitizeToken(e.initials or "AAA"),
            tostring(math.floor(tonumber(e.score) or 0)),
            tostring(math.floor(tonumber(e.level) or 1)),
        }, "|")
    end
    local payload = table.concat(lines, "\n")
    local okWrite = vmupro.file.write(path, payload)
    if not okWrite then
        return false, "write_failed"
    end
    return true, nil
end

function ExpansionPersistence.loadAchievementState(defaultValue)
    local fallback = defaultValue or {unlocked = {}, progress = {}}
    local out = {
        unlocked = cloneTable(fallback.unlocked),
        progress = cloneTable(fallback.progress),
    }
    if not hasFileApi() then
        return out
    end

    local path = ExpansionPersistence.paths.achievements
    if vmupro.file.exists and (not vmupro.file.exists(path)) then
        return out
    end

    local payload = vmupro.file.read(path)
    if not payload or payload == "" then
        return out
    end

    local normalized = string.gsub(tostring(payload), "\r", "")
    local lines = {}
    for line in string.gmatch(normalized, "([^\n]+)") do
        if line and line ~= "" then
            lines[#lines + 1] = line
        end
    end
    if #lines == 0 or lines[1] ~= ACHIEVEMENT_HEADER then
        return out
    end

    out.unlocked = {}
    out.progress = {}
    for i = 2, #lines do
        local parts = splitByPlain(lines[i], "|")
        if #parts >= 2 then
            local mode = parts[1]
            local id = sanitizeToken(parts[2])
            if id ~= "" then
                if mode == "U" then
                    out.unlocked[id] = true
                elseif mode == "P" and #parts >= 3 then
                    local value = math.floor(tonumber(parts[3]) or 0)
                    if value < 0 then value = 0 end
                    out.progress[id] = value
                end
            end
        end
    end
    return out
end

function ExpansionPersistence.saveAchievementState(achievementState)
    if not hasFileApi() then
        return false, "file_api_unavailable"
    end
    local path = ExpansionPersistence.paths.achievements
    local okPath, errPath = ensureStoragePath(path)
    if not okPath then
        return false, errPath
    end

    local state = achievementState or {unlocked = {}, progress = {}}
    local unlocked = state.unlocked or {}
    local progress = state.progress or {}
    local lines = {ACHIEVEMENT_HEADER}

    local unlockedKeys = sortedKeys(unlocked)
    for i = 1, #unlockedKeys do
        local key = unlockedKeys[i]
        if unlocked[key] then
            lines[#lines + 1] = table.concat({"U", sanitizeToken(key)}, "|")
        end
    end

    local progressKeys = sortedKeys(progress)
    for i = 1, #progressKeys do
        local key = progressKeys[i]
        local value = math.floor(tonumber(progress[key]) or 0)
        if value < 0 then value = 0 end
        lines[#lines + 1] = table.concat({"P", sanitizeToken(key), tostring(value)}, "|")
    end

    local payload = table.concat(lines, "\n")
    local okWrite = vmupro.file.write(path, payload)
    if not okWrite then
        return false, "write_failed"
    end
    return true, nil
end
