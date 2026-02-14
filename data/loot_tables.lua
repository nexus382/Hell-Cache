-- Data layer: chest-centric drop tables.
-- Deterministic roll path (no math.random) for VMU Pro safety.

GameLootTables = {
    chest_tier_1 = {
        {item = "potion_small", weight = 60},
        {item = "potion_large", weight = 20},
        {item = "charm_guard", weight = 20},
    },
    chest_tier_2 = {
        {item = "potion_large", weight = 35},
        {item = "sword_iron", weight = 20},
        {item = "bow_short", weight = 20},
        {item = "focus_ember", weight = 20},
        {item = "charm_guard", weight = 5},
    },
}

local function lootHash(seedA, seedB)
    local a = seedA or 0
    local b = seedB or 0
    local v = (a * 1103 + b * 2909 + 7919) % 104729
    v = ((v * 131) + 907) % 104729
    return v
end

local function getChestTierForLevel(levelId)
    if (levelId or 1) >= 2 then
        return "chest_tier_2"
    end
    return "chest_tier_1"
end

function rollChestDrop(levelId, classId, seedValue)
    local tierId = getChestTierForLevel(levelId)
    local tier = GameLootTables[tierId]
    if not tier or #tier == 0 then
        return nil
    end

    local total = 0
    for i = 1, #tier do
        total = total + (tier[i].weight or 0)
    end
    if total <= 0 then
        return nil
    end

    local classBias = 0
    if classId == "warrior" then classBias = 11 end
    if classId == "archer" then classBias = 17 end
    if classId == "mage" then classBias = 23 end
    local seed = lootHash(seedValue or 0, (levelId or 1) + classBias)
    local pick = (seed % total) + 1

    local acc = 0
    for i = 1, #tier do
        acc = acc + (tier[i].weight or 0)
        if pick <= acc then
            return tier[i].item
        end
    end

    return tier[#tier].item
end
