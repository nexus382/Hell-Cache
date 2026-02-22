# Stats to Gameplay Mapping - Inner Sanctum

> **Status**: Documentation of Current Implementation State
> **Generated**: 2026-02-16
> **Research**: 5 parallel scientist agents analyzed 50+ files

---

## Executive Summary

### Current State: DEFINED BUT NOT IMPLEMENTED

The game has a **complete stat system defined** in data files, but **stats do not affect gameplay**. All combat, health, and progression calculations use hardcoded constants.

| System | Data Defined | Code Implementation | Status |
|--------|--------------|---------------------|--------|
| Player Stats | ✅ 8 combat stats | ❌ Display only | NOT WORKING |
| Class Differences | ✅ 3 classes with different stats | ❌ All play identically | NOT WORKING |
| Health Scaling | ✅ base_hp + growth per class | ❌ Fixed 100 HP | NOT WORKING |
| Damage Scaling | ✅ base_damage + power stat | ❌ Fixed 20 damage | NOT WORKING |
| Mana System | ❌ Not defined | ❌ Not implemented | MISSING |
| Level Progression | ✅ Growth formulas defined | ❌ No XP/level system | NOT WORKING |
| Skill Unlocks | ❌ Not defined | ❌ Not implemented | MISSING |
| Stat Requirements | ❌ Not defined | ❌ Not implemented | MISSING |

---

## Part 1: Stat Definitions

### 1.1 Class Base Stats

**Location**: `data/classes.lua`

| Class | base_hp | base_damage | base_speed | base_defense |
|-------|---------|-------------|------------|--------------|
| **Warrior** | 120 | 20 | 1.00 | 4.00 |
| **Archer** | 90 | 14 | 1.15 | 2.50 |
| **Mage** | 80 | 18 | 1.05 | 2.25 |

**File References**:
- Warrior: `data/classes.lua:7-11`
- Archer: `data/classes.lua:27-31`
- Mage: `data/classes.lua:47-51`

### 1.2 Template Stats (Combat Modifiers)

**Location**: `data/classes.lua` (template_stats per class)

| Stat | Warrior | Archer | Mage | Intended Effect |
|------|---------|--------|------|-----------------|
| `agility` | 4.00 | 5.50 | 2.75 | Movement speed, dodge capability |
| `power` | 4.00 | 3.75 | 5.75 | Attack damage multiplier |
| `defense` | 4.00 | 2.50 | 2.25 | Damage reduction |
| `dodge` | 4.00 | 5.00 | 2.50 | Chance to avoid hit |
| `crit` | 4.00 | 3.50 | 5.25 | Critical hit chance |
| `atk_speed` | 4.00 | 5.50 | 2.75 | Attack frequency |
| `regen` | 4.00 | 2.50 | 2.25 | Health regeneration rate |
| `shield_bonus` | 4.00 | 2.00 | 1.75 | Block effectiveness |

**File References**:
- Warrior template: `data/classes.lua:13-22`
- Archer template: `data/classes.lua:33-42`
- Mage template: `data/classes.lua:53-62`

### 1.3 Player Build Stats

**Location**: `data/runtime_state.lua`

| Stat | Default | Purpose |
|------|---------|---------|
| `stat_points` | 0 | Unspent allocation points |
| `vitality` | 0 | Player-allocated HP bonus |
| `strength` | 0 | Player-allocated damage bonus |
| `dexterity` | 0 | Player-allocated speed/dodge bonus |
| `intellect` | 0 | Player-allocated magic power |

**File Reference**: `data/runtime_state.lua:24-29`

### 1.4 Item Modifier Stats

**Location**: `data/items.lua` (per item)

| Modifier | Range | Effect |
|----------|-------|--------|
| `stat_speed` | -10 to +10 | Attack cycle time modifier |
| `stat_damage` | -10 to +10 | Damage output modifier |
| `stat_range` | -10 to +10 | Attack range modifier |
| `stat_agility` | -10 to +10 | Movement/dodge modifier |
| `stat_power` | -10 to +10 | Ability effectiveness modifier |
| `stat_defense` | -10 to +10 | Damage reduction modifier |

---

## Part 2: Stat Growth Per Level

### 2.1 Class Growth Rates

**Location**: `data/classes.lua` (growth table per class)

| Class | HP Growth | Damage Growth | Speed Growth |
|-------|-----------|---------------|--------------|
| **Warrior** | +8 per level | +2 per level | +0.0 |
| **Archer** | +5 per level | +2 per level | +0.01 |
| **Mage** | +4 per level | +3 per level | +0.0 |

### 2.2 Intended Level Scaling Formula

```lua
-- DEFINED but NOT IMPLEMENTED
max_health = base_hp + (growth.hp * level)
base_damage = base_damage + (growth.damage * level)
attack_speed = base_speed + (growth.speed * level)
```

**File References**:
- Warrior growth: `data/classes.lua:22`
- Archer growth: `data/classes.lua:42`
- Mage growth: `data/classes.lua:62`

---

## Part 3: Combat Formulas

### 3.1 CURRENT Implementation (Hardcoded)

**Enemy to Player Damage** (`app_full.lua:3200-3215`):
```lua
-- CURRENT (does NOT use stats)
DAMAGE_PER_HIT = 10  -- Constant

if perfect_block then
    damage = 0
elseif blocking then
    damage = math.floor(10 * 0.5 + 0.5)  -- Always 5
else
    damage = 10  -- Always 10
end

playerHealth = playerHealth - damage
```

**Player to Enemy Damage** (`app_full.lua:7194`):
```lua
-- CURRENT (does NOT use stats)
PLAYER_DAMAGE = 20  -- Constant, ignores class

s.hp = s.hp - PLAYER_DAMAGE  -- Always 20 damage
```

### 3.2 INTENDED Implementation (Not Yet Applied)

Based on defined stats, the formulas SHOULD be:

**Player Health Calculation**:
```lua
-- INTENDED
MAX_HEALTH = class.base_hp
           + (class.growth.hp * level)
           + (vitality * VITALITY_HP_BONUS)
           + equipment.stat_defense

-- Suggested: VITALITY_HP_BONUS = 10
```

**Player Damage Calculation**:
```lua
-- INTENDED
base_damage = class.base_damage
            + (class.growth.damage * level)
            + (strength * STRENGTH_DMG_BONUS)

final_damage = base_damage
             * (1 + template_stats.power / 100)
             + equipment.stat_damage

-- Critical hit
if math.random(100) < template_stats.crit then
    final_damage = final_damage * CRIT_MULTIPLIER  -- e.g., 1.5x
end
```

**Damage Reduction Calculation**:
```lua
-- INTENDED
effective_defense = template_stats.defense
                  + equipment.stat_defense
                  + (dexterity * DEX_DEFENSE_BONUS)

incoming_damage = math.max(1, raw_damage - effective_defense)

-- Dodge check
if math.random(100) < template_stats.dodge then
    incoming_damage = 0  -- Complete avoidance
end
```

---

## Part 4: Health & Mana Systems

### 4.1 Health System

**Current State** (`app_full.lua:782-784`):
```lua
playerHealth = 100      -- Fixed for all classes
MAX_HEALTH = 100        -- Fixed for all classes
DAMAGE_PER_HIT = 10     -- Fixed enemy damage
```

**Class HP Values (UNUSED)**:
| Class | Defined base_hp | Actual In-Game |
|-------|-----------------|-----------------|
| Warrior | 120 | 100 |
| Archer | 90 | 100 |
| Mage | 80 | 100 |

**Regeneration (NOT IMPLEMENTED)**:
- `regen` stat exists (2.25 - 4.00 range)
- No health regeneration mechanic
- Only healing is health potion pickups (full restore)

### 4.2 Mana System

**Status**: NOT IMPLEMENTED

- No mana/MP variables exist
- No intellect/wisdom stat effects
- No spell resource management
- Mage class marked as `primary = "magic"` but has no magic resource

**Recommended Implementation**:
```lua
-- PROPOSED
MAX_MANA = 50 + (intellect * INTELLECT_MANA_BONUS)
MANA_REGEN = base_mana_regen + (intellect * 0.5)

-- Spell costs
SPELL_COSTS = {
    fireball = 15,
    ice_bolt = 10,
    teleport = 25,
    -- etc.
}
```

---

## Part 5: Equipment System

### 5.1 Equipment Slots

| Slot | Purpose | Items Available |
|------|---------|-----------------|
| `weapon` | Primary attack | Class-specific weapons/spells |
| `armor` | Body protection | Class-specific armor |
| `special_1` | Accessory | Guard Charm, etc. |
| `special_2` | Accessory | Guard Charm, etc. |

### 5.2 Equipment Requirements

**Current**: Class affinity only
- `class_affinity = "warrior"` - Warrior weapons only
- `class_affinity = "archer"` - Archer weapons only
- `class_affinity = "mage"` - Mage spells only
- `class_affinity = "any"` - All classes

**Missing**: No stat requirements (e.g., "Requires 15 Strength")

### 5.3 Weapon Examples with Stat Modifiers

**Warrior Weapons**:
| Weapon | stat_damage | stat_speed | stat_range | Value |
|--------|-------------|------------|------------|-------|
| Iron Sword | +4 | 0 | 0 | 110 |
| Dagger | -4 | +5 | -3 | 65 |
| Battle Axe | +6 | -5 | +2 | 140 |
| Spear | +2 | +1 | +5 | 115 |
| War Hammer | +10 | -8 | -2 | 160 |

**Archer Weapons**:
| Weapon | stat_damage | stat_speed | stat_range | Value |
|--------|-------------|------------|------------|-------|
| Short Bow | +3 | +2 | +4 | 105 |
| Longbow | +7 | -4 | +8 | 175 |
| Crossbow | +9 | -7 | +6 | 190 |

**Mage Spells (19 total)**:
| Type | Count | Examples |
|------|-------|----------|
| Projectile | 6 | Fireball, Ice Bolt, Lightning, Arcane Bolt, Magma, Venom |
| Beam | 4 | Arcane Beam, Death Ray, Frost Beam, Life Drain |
| AOE | 4 | Frost Nova, Chain Lightning, Meteor, Void Zone |
| Utility | 5 | Teleport, Arcane Shield, Haste, Phase Shift, Mana Flare |

---

## Part 6: Progression Systems

### 6.1 Level-Up System

**Status**: NOT IMPLEMENTED

- No XP/experience variables
- No level-up triggers
- No stat point allocation UI
- Growth data exists but is never applied

**Data That Exists**:
```lua
-- data/runtime_state.lua
stat_points = 0      -- Ready to use
vitality = 0         -- Ready to use
strength = 0         -- Ready to use
dexterity = 0        -- Ready to use
intellect = 0        -- Ready to use
```

### 6.2 Actual Progression (Current Game)

| System | Implementation |
|--------|----------------|
| Leveling | ❌ None |
| XP Gain | ❌ None |
| Stat Points | ❌ None (defined but unused) |
| Skill Unlocks | ❌ None |
| Item Progression | ✅ Loot drops, trader |

**Item Acquisition**:
- Chest drops (Tier 1: potions, Tier 2: weapons)
- Trader purchases (score-gated: 0, 500, 1500)
- No stat requirements for any item

---

## Part 7: Implementation Gap Analysis

### 7.1 What's Defined vs What Works

| Feature | Data | Code | Gap |
|---------|------|------|-----|
| Class HP differences | ✅ | ❌ | Need to apply base_hp to MAX_HEALTH |
| Class damage differences | ✅ | ❌ | Need to apply base_damage to PLAYER_DAMAGE |
| Power stat scaling | ✅ | ❌ | Need damage formula update |
| Defense damage reduction | ✅ | ❌ | Need damage mitigation formula |
| Dodge chance | ✅ | ❌ | Need random check before damage |
| Critical hits | ✅ | ❌ | Need crit formula and damage multiplier |
| Attack speed | ✅ | ❌ | Need attack cooldown modifier |
| Health regeneration | ✅ | ❌ | Need periodic HP gain |
| Shield/block bonus | ✅ | ❌ | Need to scale block reduction |
| Level progression | ✅ | ❌ | Need XP system and level-up |
| Stat point allocation | ✅ | ❌ | Need UI and application |
| Mana system | ❌ | ❌ | Need full implementation |

### 7.2 Code Locations That Need Updates

| Current Code | Location | Needed Change |
|--------------|----------|---------------|
| `MAX_HEALTH = 100` | `app_full.lua:783` | Calculate from class.base_hp + level |
| `PLAYER_DAMAGE = 20` | `app_full.lua:1318` | Calculate from class.base_damage + power |
| `DAMAGE_PER_HIT = 10` | `app_full.lua:784` | Apply defense stat to reduce |
| `damage = 10` (enemy attack) | `app_full.lua:3201` | Apply player defense |
| Block reduction 50% | `app_full.lua:3211` | Scale with shield_bonus stat |

---

## Part 8: Recommended Implementation Order

### Phase 1: Core Stat Application (Quick Wins)

1. **Apply class HP to MAX_HEALTH**
```lua
-- In initialization
local classDef = getClassDefById(getCurrentClassId())
MAX_HEALTH = classDef.base_hp
playerHealth = MAX_HEALTH
```

2. **Apply class damage to PLAYER_DAMAGE**
```lua
-- Replace constant
local classDef = getClassDefById(getCurrentClassId())
PLAYER_DAMAGE = classDef.base_damage
```

3. **Apply defense to incoming damage**
```lua
-- In enemy attack code
local classDef = getClassDefById(getCurrentClassId())
local effectiveDefense = classDef.template_stats.defense
damage = math.max(1, DAMAGE_PER_HIT - effectiveDefense)
```

### Phase 2: Combat Stats (Medium Effort)

4. **Implement dodge chance**
```lua
-- Before damage application
local dodgeChance = classDef.template_stats.dodge
if math.random(100) < dodgeChance then
    damage = 0  -- Dodged!
end
```

5. **Implement critical hits**
```lua
-- On player attack
local critChance = classDef.template_stats.crit
local finalDamage = PLAYER_DAMAGE
if math.random(100) < critChance then
    finalDamage = finalDamage * 1.5
end
```

6. **Implement attack speed**
```lua
-- Modify attack cooldown
local speedMod = classDef.template_stats.atk_speed / 4.0
effective_cooldown = BASE_ATTACK_COOLDOWN / speedMod
```

### Phase 3: Progression (Larger Effort)

7. **Add XP system**
8. **Implement level-up with stat growth**
9. **Add stat point allocation UI**
10. **Implement mana system for mage**

---

## Part 9: Stat-to-Effect Quick Reference

### Combat Stats

| Stat | Formula (Proposed) | Current Status |
|------|-------------------|----------------|
| **Power** | `damage * (1 + power/100)` | ❌ Not applied |
| **Defense** | `incoming - defense` | ❌ Not applied |
| **Dodge** | `if rand(100) < dodge then miss` | ❌ Not applied |
| **Crit** | `if rand(100) < crit then 1.5x` | ❌ Not applied |
| **Atk Speed** | `cooldown / (atk_speed/4)` | ❌ Not applied |
| **Shield Bonus** | `block_reduction + shield_bonus%` | ❌ Not applied |
| **Regen** | `hp += regen/10 per second` | ❌ Not applied |
| **Agility** | `move_speed * (1 + agility/100)` | ❌ Not applied |

### Build Stats

| Stat | Proposed Effect | Current Status |
|------|-----------------|----------------|
| **Vitality** | +10 HP per point | ❌ Not applied |
| **Strength** | +2 damage per point | ❌ Not applied |
| **Dexterity** | +1% dodge, +0.5% speed | ❌ Not applied |
| **Intellect** | +5 mana, +1% spell power | ❌ System missing |

---

## Part 10: File Reference Index

### Data Files

| File | Purpose | Key Contents |
|------|---------|--------------|
| `data/classes.lua` | Class definitions | base_hp, base_damage, template_stats, growth |
| `data/items.lua` | Item definitions | Weapons, spells, equipment, stat modifiers |
| `data/runtime_state.lua` | Player state | stat_points, vitality, strength, dexterity, intellect |
| `data/loot_tables.lua` | Drop tables | Chest drops, trader items |

### Code Files

| File | Lines | Purpose |
|------|-------|---------|
| `app_full.lua` | 782-784 | Health constants (currently hardcoded) |
| `app_full.lua` | 1317-1318 | Enemy HP, player damage constants |
| `app_full.lua` | 1334-1393 | Class fallback definitions |
| `app_full.lua` | 1396-1448 | Class utility functions |
| `app_full.lua` | 3200-3215 | Enemy attack damage calculation |
| `app_full.lua` | 4084-4117 | Class selection UI (stats display only) |
| `app_full.lua` | 7194 | Player attack damage application |

### Documentation Files

| File | Purpose |
|------|---------|
| `USER_STATS_AND_SKILLS_GUIDE.html` | Comprehensive stat design doc |
| `MAGE_SPELL_DESIGN.md` | 19 spell definitions with stat modifiers |
| `WEAPON_VALUE_BALANCE.md` | Weapon balance framework |
| `STATS_TO_GAMEPLAY.md` | This document |

---

## Summary

The Inner Sanctum game has a **well-designed stat system** that is **completely disconnected from gameplay**. All combat uses hardcoded values, making the three classes play identically despite having different stat definitions.

**Key Findings**:
- 8 combat stats defined per class, none affect gameplay
- 4 build stats (vitality/strength/dexterity/intellect) defined, never used
- Class growth formulas exist, no leveling system to apply them
- 19 mage spells with stat modifiers, but damage is always 20
- Health always 100, no mana system exists

**Priority Fixes**:
1. Apply `class.base_hp` to `MAX_HEALTH`
2. Apply `class.base_damage` to `PLAYER_DAMAGE`
3. Implement `defense` stat in damage calculation
4. Add `dodge` chance before damage
5. Add `crit` chance on attacks

These 5 changes would make the classes actually play differently.
