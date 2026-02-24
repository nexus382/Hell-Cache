# Stat Definitions Investigation Report

## Overview
Complete analysis of all stat definitions across the game data files. Based on investigation of `data/classes.lua` and `data/items.lua`.

## Stat Categories

### 1. Base Stats (Per Class)
Located in `data/classes.lua` - Lines 7-11, 27-31, 47-51

| Stat | Warrior | Archer | Mage | Purpose |
|------|---------|--------|------|---------|
| `base_hp` | 120 | 90 | 80 | Starting health points |
| `base_damage` | 20 | 14 | 18 | Base damage output |
| `base_speed` | 1.0 | 1.15 | 1.05 | Movement/attack speed multiplier |
| `base_defense` | 4.00 | 2.50 | 2.25 | Base damage reduction |

### 2. Template Stats (Per Class)
Located in `data/classes.lua` - Lines 12-21, 32-41, 52-61

These appear to be starting values for the 8 combat stats at level 1:

| Stat | Warrior | Archer | Mage | Purpose (from items.lua comments) |
|------|---------|--------|------|----------------------------------|
| `agility` | 4.00 | 5.50 | 2.75 | Affects movement/dodging (positive = more agile) |
| `power` | 4.00 | 3.75 | 5.75 | Affects ability effectiveness (positive = stronger abilities) |
| `defense` | 4.00 | 2.50 | 2.25 | Affects damage reduction (positive = more defense) |
| `dodge` | 4.00 | 5.00 | 2.50 | Dodge chance/effectiveness (not documented in items.lua) |
| `regen` | 4.00 | 2.50 | 2.25 | Health regeneration rate (not documented in items.lua) |
| `crit` | 4.00 | 3.50 | 5.25 | Critical hit chance/effectiveness (not documented in items.lua) |
| `atk_speed` | 4.00 | 5.50 | 2.75 | Attack speed multiplier (not documented in items.lua) |
| `shield_bonus` | 4.00 | 2.00 | 1.75 | Additional shield effectiveness (not documented in items.lua) |

### 3. Stat Growth (Per Class)
Located in `data/classes.lua` - Lines 22, 42, 62

| Stat | Warrior | Archer | Mage | Formula |
|------|---------|--------|------|---------|
| `hp` | +8 | +5 | +4 | `base_hp + (level - 1) * growth.hp` |
| `damage` | +2 | +2 | +3 | `base_damage + (level - 1) * growth.damage` |
| `speed` | +0.0 | +0.01 | +0.0 | `base_speed + (level - 1) * growth.speed` |

### 4. Item Modifier Stats
Located in `data/items.lua` - Lines 2-8 (comments)

| Stat | Range | Purpose |
|------|-------|---------|
| `stat_speed` | -10 to +10 | Affects attack cycle time (positive = faster) |
| `stat_damage` | -10 to +10 | Affects damage output (positive = more damage) |
| `stat_range` | -10 to +10 | Affects attack range (positive = longer range) |
| `stat_agility` | -10 to +10 | Affects movement/dodging (positive = more agile) |
| `stat_power` | -10 to +10 | Affects ability effectiveness (positive = stronger abilities) |
| `stat_defense` | -10 to +10 | Affects damage reduction (positive = more defense) |

### 5. Player Build Stats
Located in `data/runtime_state.lua` - Lines 24-29

| Stat | Default | Purpose |
|------|---------|---------|
| `stat_points` | 0 | Points to allocate to stats on level up |
| `vitality` | 0 | Increases maximum health |
| `strength` | 0 | Increases damage output |
| `dexterity` | 0 | Increases agility/dodge |
| `intellect` | 0 | Increases ability power |

## Key Findings

### Missing Information
1. **No stat formulas found** - No evidence of how the 5 player build stats (vitality, strength, dexterity, intellect) interact with the combat stats
2. **No level calculation** - No code found showing how stats scale with player level beyond base growth
3. **No combat calculations** - No formulas for final damage, defense, speed, or hp calculations

### Hypotheses
1. Player build stats may be additive to base stats
2. Template stats may be starting values for combat stats
3. Item stats modify combat stats directly

### Recommendations
1. Search for combat calculation functions in game logic files
2. Look for stat application/modification code
3. Check for level progression formulas
4. Investigate how player build stats affect combat performance

## Files Analyzed
- `/mnt/r/inner-santctum/data/classes.lua` (lines 1-74)
- `/mnt/r/inner-santctum/data/items.lua` (lines 1-549)
- `/mnt/r/inner-santctum/data/runtime_state.lua` (lines 21-38)

## Next Steps
- Search for combat calculation logic in app_full.lua or other game files
- Look for stat application and modifier code
- Find level progression and stat scaling formulas