<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-17 -->

# data/

## Purpose
This directory contains the complete data layer for the game expansion, including all game data definitions such as classes, items, loot tables, achievements, scoring, trader tiers, persistence hooks, and runtime state management.

## Key Files

| File | Description |
|------|-------------|
| `classes.lua` | Playable class definitions (Warrior, Archer, Mage) with base stats, template stats, growth rates, and class retrieval |
| `items.lua` | Complete item catalog including consumables (potions), weapons (melee, ranged, spells), and equipment with stat modifiers and values |
| `runtime_state.lua` | Runtime state bootstrap, implementation queue tracking, and default state factories for builds, inventory, stash, scores, and achievements |
| `achievements.lua` | Achievement registry with trigger conditions, thresholds, rewards, and state management helpers |
| `loot_tables.lua` | Chest-centric drop tables with deterministic roll path (hash-based, no math.random) for VMU Pro safety |
| `score_model.lua` | Run score tracking and top-10 high score management with entry creation, sorting, and initialization helpers |
| `trader_tiers.lua` | Score-gated trader inventory tiers with tier selection logic |
| `persistence.lua` | Save/load persistence hooks for high scores and achievements (stub-safe, ready for vmupro.file integration) |

## Data Structures

### Classes (`classes.lua`)

Each class contains:
- `id` - Unique identifier (e.g., "warrior", "archer", "mage")
- `name` - Display name
- `base_hp` - Starting health points
- `base_damage` - Starting damage
- `base_speed` - Movement speed multiplier
- `primary` - Attack type ("melee", "ranged", "magic")
- `base_defense` - Damage reduction
- `template_stats` - Eight stat categories (agility, power, defense, dodge, regen, crit, atk_speed, shield_bonus)
- `growth` - Per-level stat increases (hp, damage, speed)

**Key Functions:**
- `getGameClass(classId)` - Retrieve class data, defaults to Warrior

### Items (`items.lua`)

Each item contains:
- `id` - Unique identifier
- `name` - Display name
- `kind` - Item type ("consumable", "weapon", "equipment")
- `class_affinity` - Class restriction ("warrior", "archer", "mage", "any")
- `weight` - Inventory weight cost
- `stack_max` - Maximum stack size
- `value` - Gold value for trading
- `effect` - For consumables (e.g., `{heal = 25}`)
- `stats` - Six stat modifiers (stat_speed, stat_damage, stat_range, stat_agility, stat_power, stat_defense), each ranging from -10 to +10

**Stat Modifier Effects:**
- `stat_speed` - Affects attack cycle time (positive = faster)
- `stat_damage` - Damage output
- `stat_range` - Attack range
- `stat_agility` - Movement/dodging capability
- `stat_power` - Ability effectiveness
- `stat_defense` - Damage reduction

**Key Functions:**
- `getGameItem(itemId)` - Retrieve item data

### Loot Tables (`loot_tables.lua`)

Drop tables organized by tier:
- `chest_tier_1` - Basic drops (potions, charm_guard)
- `chest_tier_2` - Advanced drops (includes weapons)

**Key Functions:**
- `rollChestDrop(levelId, classId, seedValue)` - Deterministic loot roll using hash function (no math.random)
- `getChestTierForLevel(levelId)` - Returns appropriate tier based on level

**Deterministic Roll System:**
- Uses `lootHash(seedA, seedB)` for reproducible results
- Class bias applied: warrior=11, archer=17, mage=23
- Safe for VMU Pro (avoids math.random crashes)

### Achievements (`achievements.lua`)

Each achievement contains:
- `id` - Unique identifier
- `name` - Display name
- `trigger` - Event type ("kill_count", "levels_cleared", "no_damage_level")
- `threshold` - Required value to unlock
- `reward` - Bonus (e.g., `{score_bonus = 100}`)

**Key Functions:**
- `newAchievementState()` - Create fresh achievement state
- `markAchievementUnlocked(state, achievementId)` - Mark as unlocked, returns true if newly unlocked

### Score Model (`score_model.lua`)

**Run State Structure:**
```lua
{
    current = 0,          -- Current score
    kills = 0,            -- Enemy kills
    levels_cleared = 0,   -- Levels completed
    started_level = 1,    -- Starting level
    ended_level = 1,      -- Final level reached
}
```

**High Score Entry:**
```lua
{
    initials = "AAA",     -- 3 uppercase letters
    score = 1000,         -- Final score
    level = 5,            -- Level reached
}
```

**Key Functions:**
- `GameScoreModel.newRun()` - Initialize new run state
- `GameScoreModel.addPoints(runState, amount)` - Add points to run
- `GameScoreModel.sanitizeInitials(initials)` - Ensure 3 uppercase letters
- `GameScoreModel.createEntry(initials, score, levelReached)` - Create high score entry
- `GameScoreModel.insertHighScore(list, entry, maxEntries)` - Insert and maintain top-10 (or custom limit)

### Trader Tiers (`trader_tiers.lua`)

Three score-gated tiers:
- Tier 1 (0+ score): potions, charm_guard
- Tier 2 (500+ score): adds basic weapons
- Tier 3 (1500+ score): expanded inventory

**Key Functions:**
- `getTraderTierForScore(score)` - Returns appropriate tier based on current score

### Persistence (`persistence.lua`)

**Save Paths:**
- `save/high_scores.dat` - High score data
- `save/achievements.dat` - Achievement progress

**Key Functions:**
- `ExpansionPersistence.loadHighScores(defaultValue)` - Load high scores (currently stub)
- `ExpansionPersistence.saveHighScores(scoreList)` - Save high scores (currently stub)
- `ExpansionPersistence.loadAchievementState(defaultValue)` - Load achievements (returns cloned state)
- `ExpansionPersistence.saveAchievementState(achievementState)` - Save achievements (currently stub)

**Note:** Persistence hooks are stub-safe and ready for vmupro.file integration when format is finalized.

### Runtime State (`runtime_state.lua`)

**Implementation Queue:**
Tracks expansion features in progress:
- classes_combat_split
- chest_drop_conversion
- inventory_stash_weight
- trader_economy_loop
- high_score_death_flow_achievements_ui

**Default State Factories:**
- `makeDefaultBuildState()` - Player class, level, stats, equipment
- `makeDefaultInventoryState()` - 30 weight capacity, 3 quick slots
- `makeDefaultStashState()` - 120 weight capacity storage

**Key Functions:**
- `ExpansionRuntimeState.bootstrap()` - Initialize complete runtime state
- `ExpansionRuntimeState.beginRun(levelId, fallbackLevel)` - Start new run with score tracking

## For AI Agents

### Editing Game Data

**When Modifying Classes:**
1. Maintain balance between classes (Warrior: tanky, Archer: fast/ranged, Mage: high damage/low hp)
2. Growth rates should scale appropriately (e.g., Warrior gains more HP per level)
3. Template stats should reflect class identity (agility for Archer, power for Mage)
4. Keep `GameClassOrder` array synchronized with `GameClasses` keys

**When Adding Items:**
1. Follow item structure exactly (id, name, kind, class_affinity, weight, stack_max, value)
2. Stat modifiers must be between -10 and +10
3. Weapons require stats table, consumables require effect table
4. Use appropriate class_affinity ("any" for universal items)
5. Consider weight vs. value balance for economy

**When Modifying Loot Tables:**
1. Keep weights reasonable (total doesn't need to be 100, but ratios matter)
2. Higher tiers should drop better items
3. Maintain class variety (weapons for all classes)
4. Use deterministic roll system - avoid math.random

**When Adding Achievements:**
1. Use clear, descriptive trigger names
2. Thresholds should be challenging but achievable
3. Provide meaningful score bonuses as rewards
4. Document trigger conditions in comments

**When Modifying Score System:**
1. Keep high score limit at 10 for consistency
2. Score sorting: primary by score DESC, secondary by level DESC
3. Always sanitize initials (3 uppercase letters)
4. Use math.max/math.floor for safety

**When Adding Trader Tiers:**
1. Maintain ascending min_score values
2. Each tier should expand on previous (not replace)
3. Include class variety in items
4. Balance economy (item value vs. tier threshold)

**When Implementing Persistence:**
1. Use stub-safe pattern - return defaults if file load fails
2. Clone tables before modifying (avoid reference sharing)
3. Define clear file paths in `paths` table
4. Format must be vmupro.file-compatible when implemented

### VMU Pro SDK Constraints

**Critical:**
- **NO math.random()** - Use deterministic hash-based alternatives (see `loot_tables.lua`)
- **NO math.atan2()** - Use safeAtan2() implementation
- All persistence must use vmupro.file API when implemented
- Keep data structures simple (flat tables preferred)
- Avoid complex metatables or __index magic

### Testing Changes

**Balance Testing:**
1. Test all three classes with new items/stats
2. Verify loot distribution (run multiple seeds)
3. Check achievement unlock conditions
4. Validate score sorting and high score insertion
5. Test trader tier progression

**Integration Testing:**
1. Ensure data changes don't break game systems
2. Check that all `getGame*()` functions handle nil inputs
3. Verify persistence state factories create valid defaults
4. Test save/load flow when persistence is implemented

### Dependencies

**Internal Dependencies:**
- Game code consumes these data tables via require() statements
- Runtime state used by `app.lua` for initialization
- Items/weapons referenced by inventory and combat systems
- Score model used by UI and game over screens

**External Dependencies:**
- VMU Pro SDK (vmupro.file for persistence when implemented)
- Lua standard library (math, table) - with safe alternatives

### Data Flow

```
┌─────────────────┐
│   Boot/Init     │
└────────┬────────┘
         │
         ├──> ExpansionRuntimeState.bootstrap()
         │    ├──> makeDefaultBuildState()
         │    ├──> makeDefaultInventoryState()
         │    ├──> makeDefaultStashState()
         │    └──> ExpansionPersistence.load*()
         │
         ├──> getGameClass(classId)
         └──> getGameItem(itemId)

┌─────────────────┐
│   Gameplay      │
└────────┬────────┘
         │
         ├──> rollChestDrop(levelId, classId, seed)
         ├──> GameScoreModel.addPoints(runState, amount)
         ├──> markAchievementUnlocked(state, achievementId)
         └──> getTraderTierForScore(score)

┌─────────────────┐
│   Save/Quit     │
└────────┬────────┘
         │
         └──> ExpansionPersistence.save*()
```

## Design Notes

**Deterministic Loot System:**
The loot system uses hash-based deterministic rolls instead of math.random() to avoid VMU Pro SDK crashes. The `lootHash(seedA, seedB)` function provides reproducible results given the same inputs, with class bias adding variety without randomness.

**Stat Modifier System:**
All items use a consistent 6-stat system with -10 to +10 ranges. Positive values always improve the stat. This allows for balanced item progression and clear player understanding of item value.

**Stub-Safe Persistence:**
Persistence hooks are designed to fail gracefully, returning defaults if save files are missing or corrupted. This allows game systems to be developed before persistence implementation is finalized.

**Modular Data Design:**
Each data file is independent and can be loaded separately. Helper functions provide safe access patterns with nil handling and sensible defaults.
