<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-23 -->

# Data Layer

Static game data definitions and state initialization helpers for the Inner Sanctum roguelike.

## Overview

This directory contains the **data layer** - pure Lua modules that define game constants, lookup tables, and factory functions. These modules have minimal dependencies and are safe to load early in the boot sequence.

## Files

### [achievements.lua](./achievements.lua)

Achievement registry and state management helpers.

| Export | Type | Description |
|--------|------|-------------|
| `GameAchievements` | table | Achievement definitions with triggers and rewards |
| `newAchievementState()` | function | Factory for fresh achievement state |
| `markAchievementUnlocked(state, id)` | function | Marks achievement as unlocked, returns true if newly unlocked |

**Achievement Triggers:**
- `kill_count` - Total enemies killed
- `levels_cleared` - Levels completed
- `no_damage_level` - Flawless level completion

---

### [classes.lua](./classes.lua)

Playable class definitions with base stats and growth curves.

| Export | Type | Description |
|--------|------|-------------|
| `GameClasses` | table | Class definitions (warrior, archer, mage) |
| `GameClassOrder` | table | Ordered list of class IDs for UI |
| `getGameClass(classId)` | function | Returns class data, defaults to warrior |

**Class Structure:**
```lua
{
    id = "warrior",
    name = "Warrior",
    base_hp = 120,
    base_damage = 20,
    base_speed = 1.0,
    primary = "melee",        -- "melee" | "ranged" | "magic"
    base_defense = 4.00,
    template_stats = {...},   -- Base stat multipliers
    growth = {hp = 8, damage = 2, speed = 0.0}  -- Per-level gains
}
```

**Classes:**
| Class | Primary | HP | Damage | Speed | Role |
|-------|---------|----|----|-------|------|
| Warrior | melee | 120 | 20 | 1.0 | Tank/DPS |
| Archer | ranged | 90 | 14 | 1.15 | Fast DPS |
| Mage | magic | 80 | 18 | 1.05 | Burst DPS |

---

### [items.lua](./items.lua)

Complete item catalog for loot, trading, and inventory systems.

| Export | Type | Description |
|--------|------|-------------|
| `GameItems` | table | Item definitions indexed by ID |
| `getGameItem(itemId)` | function | Returns item data or nil |

**Item Kinds:**
- `consumable` - Potions with heal effects
- `weapon` - Weapons with stat modifiers
- `equipment` - Charms and accessories

**Stat Modifiers** (range: -10 to +10):
| Stat | Effect |
|------|--------|
| `stat_speed` | Attack cycle time (positive = faster) |
| `stat_damage` | Damage output |
| `stat_range` | Attack range |
| `stat_agility` | Movement/dodging |
| `stat_power` | Ability effectiveness |
| `stat_defense` | Damage reduction |

**Weapon Classes:**
- `1` = Melee (Warrior)
- `2` = Ranged (Archer)
- `3` = Magic (Mage)

**Item Categories:**
- Consumables: `potion_small`, `potion_large`
- Melee Weapons: `sword_iron`, `weapon_dagger`, `weapon_axe`, `weapon_spear`, `weapon_hammer`
- Ranged Weapons: `bow_short`, `weapon_longbow`, `weapon_crossbow`
- Magic Foci: `focus_ember`
- Projectile Spells: `spell_fireball`, `spell_icebolt`, `spell_lightning`, etc.
- Beam Spells: `spell_arcanebeam`, `spell_deathray`, `spell_frostbeam`, `spell_lifedrain`
- AOE Spells: `spell_froznova`, `spell_chainlight`, `spell_meteor`, `spell_voidzone`
- Utility Spells: `spell_teleport`, `spell_shield`, `spell_haste`, `spell_phaseshift`, `spell_manaflare`
- Equipment: `charm_guard`

---

### [loot_tables.lua](./loot_tables.lua)

Chest drop tables with deterministic rolling (VMU Pro safe - no `math.random`).

| Export | Type | Description |
|--------|------|-------------|
| `GameLootTables` | table | Weighted drop tables per chest tier |
| `rollChestDrop(levelId, classId, seedValue)` | function | Returns item ID from weighted roll |

**Chest Tiers:**
- `chest_tier_1` - Level 1 drops (basic potions, charm)
- `chest_tier_2` - Level 2+ drops (weapons, better potions)

**Deterministic Rolling:**
Uses hash-based selection with class bias to ensure reproducible results without `math.random`.

---

### [persistence.lua](./persistence.lua)

Save/load hook points (stub-safe for development).

| Export | Type | Description |
|--------|------|-------------|
| `ExpansionPersistence.paths` | table | File paths for save data |
| `loadHighScores(defaultValue)` | function | Load high scores (stub) |
| `saveHighScores(scoreList)` | function | Save high scores (stub) |
| `loadAchievementState(defaultValue)` | function | Load achievements (stub) |
| `saveAchievementState(state)` | function | Save achievements (stub) |

**Save Paths:**
```lua
{
    high_scores = "save/high_scores.dat",
    achievements = "save/achievements.dat",
}
```

**Note:** Currently returns defaults/clone. Wire to VMU Pro file API when format is finalized.

---

### [runtime_state.lua](./runtime_state.lua)

Runtime state bootstrap and per-run initialization.

| Export | Type | Description |
|--------|------|-------------|
| `ExpansionRuntimeState.bootstrap()` | function | Create full initial game state |
| `ExpansionRuntimeState.beginRun(levelId, fallbackLevel)` | function | Create fresh run state |
| `ExpansionImplementationQueue` | table | Feature implementation order |

**Bootstrap State Structure:**
```lua
{
    player_build_state = {class_id, level, xp, stats, equipment, ...},
    inventory_state = {max_weight, current_weight, items, quick_slots},
    stash_state = {max_weight, current_weight, items},
    achievement_state = {unlocked, progress},
    high_score_state = {entries},
    score_state = {current, kills, levels_cleared, ...},
}
```

**Build State Stats:**
- Primary: `vitality`, `strength`, `dexterity`, `intellect`
- Weapon Mastery: `[1]=melee, [2]=ranged, [3]=magic`

---

### [score_model.lua](./score_model.lua)

Run score tracking and high score list management.

| Export | Type | Description |
|--------|------|-------------|
| `GameScoreModel.newRun()` | function | Create fresh run score state |
| `GameScoreModel.addPoints(runState, amount)` | function | Add points, return new total |
| `GameScoreModel.sanitizeInitials(initials)` | function | Clean input to 3 uppercase letters |
| `GameScoreModel.createEntry(initials, score, level)` | function | Create high score entry |
| `GameScoreModel.insertHighScore(list, entry, max)` | function | Insert and sort, keep top N |

**Run State:**
```lua
{
    current = 0,
    kills = 0,
    levels_cleared = 0,
    started_level = 1,
    ended_level = 1,
}
```

**High Score Entry:**
```lua
{
    initials = "AAA",  -- 3 uppercase letters
    score = 0,         -- Integer score
    level = 1,         -- Level reached
}
```

---

### [trader_tiers.lua](./trader_tiers.lua)

Score-gated trader inventory tiers.

| Export | Type | Description |
|--------|------|-------------|
| `GameTraderTiers` | table | Tier definitions with min_score and items |
| `getTraderTierForScore(score)` | function | Returns highest qualifying tier |

**Tier Thresholds:**
| Tier | Min Score | Items |
|------|-----------|-------|
| 1 | 0 | `potion_small`, `charm_guard` |
| 2 | 500 | `potion_large`, `sword_iron`, `bow_short`, `focus_ember` |
| 3 | 1500 | Tier 2 + `charm_guard` |

---

## Dependencies

```
runtime_state.lua
    --> achievements.lua (newAchievementState)
    --> score_model.lua (GameScoreModel.newRun)
    --> persistence.lua (ExpansionPersistence)

loot_tables.lua --> items.lua (item IDs)

trader_tiers.lua --> items.lua (item IDs)
```

## Design Principles

1. **Pure Data**: Modules define tables and simple functions - no side effects
2. **Stub-Safe**: Persistence hooks return defaults when file API unavailable
3. **Deterministic**: Loot rolling uses hash-based selection (no `math.random`)
4. **Defaults Provided**: All getters return sensible fallbacks for nil input

## Subdirectories

None.
