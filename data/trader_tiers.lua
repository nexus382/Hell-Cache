-- Data layer: score-gated trader inventory tiers.

GameTraderTiers = {
    {id = 1, min_score = 0,    items = {"potion_small", "charm_guard"}},
    {id = 2, min_score = 500,  items = {"potion_large", "sword_iron", "bow_short", "focus_ember"}},
    {id = 3, min_score = 1500, items = {"potion_large", "sword_iron", "bow_short", "focus_ember", "charm_guard"}},
}

function getTraderTierForScore(score)
    local s = math.max(0, math.floor(score or 0))
    local selected = GameTraderTiers[1]
    for i = 1, #GameTraderTiers do
        local tier = GameTraderTiers[i]
        if s >= (tier.min_score or 0) then
            selected = tier
        end
    end
    return selected
end
