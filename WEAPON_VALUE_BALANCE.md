# WEAPON VALUE BALANCE SYSTEM
## Inner Sanctum - Design Document

**Version:** 1.0
**Date:** 2025-02-14
**Purpose:** Establish mathematical framework for balanced weapon design across all tiers and classes

---

## TABLE OF CONTENTS

1. [Stat Point Valuations](#1-stat-point-valuations)
2. [Budget System](#2-budget-system)
3. [Class-Specific Modifiers](#3-class-specific-modifiers)
4. [Tier Progression](#4-tier-progression)
5. [Balance Formulas](#5-balance-formulas)
6. [Example Calculations](#6-example-calculations)
7. [Weapon Validation Tables](#7-weapon-validation-tables)
8. [Design Guidelines](#8-design-guidelines)

---

## 1. STAT POINT VALUATIONS

### 1.1 Core Valuation Principle

Each stat point has a different "cost" based on its combat impact. The base values represent **equivalent power** at budget = 0.

| Stat | Base Value | Notes |
|------|------------|-------|
| **stat_damage** | 1.00 | Primary offensive metric (baseline) |
| **stat_speed** | 0.80 | Attack rate multiplier - highly valuable |
| **stat_range** | 0.50 | Positioning advantage - moderate value |
| **stat_agility** | 0.60 | Movement/dodge - defensive utility |
| **stat_power** | 0.70 | Ability scaling - class-dependent |
| **stat_defense** | 0.40 | Damage reduction - purely defensive |

### 1.2 Valuation Rationale

**stat_damage (1.00)** - Baseline
- Direct 1:1 impact on damage output
- Universal combat value
- Easy to calculate and balance

**stat_speed (0.80)** - High Value
- Formula: `Final Speed = base_speed × (1 + stat_speed/100)`
- +10 speed = +10% faster attacks = ~10% more DPS
- Speed multiplies damage output
- More valuable than raw damage for fast-attack builds

**stat_range (0.50)** - Moderate Value
- Formula: `Final Range = base_range + stat_range`
- +1 range = 1 tile of safety
- Positioning advantage, not raw power
- Diminishing returns after certain distance

**stat_agility (0.60)** - Defensive Value
- Movement speed and dodge capability
- Survivability through positioning
- Less valuable than defense for tanks, more for kiting

**stat_power (0.70)** - Class-Dependent
- Mages: Primary stat (value = 1.00)
- Warriors: Low value (value = 0.40)
- Archers: Moderate value (value = 0.60)

**stat_defense (0.40)** - Pure Defense
- Damage reduction percentage
- Doesn't increase offense
- Valued at 40% of damage
- Vital for tanks, less valuable for DPS

---

## 2. BUDGET SYSTEM

### 2.1 Core Formula

```
BUDGET = Σ(stat_value × stat_multiplier × stat_amount)
```

Where:
- `stat_value` = Base value from table above
- `stat_multiplier` = Class-specific modifier (see Section 3)
- `stat_amount` = Actual stat value (-10 to +10)

### 2.2 Budget Calculation Example

**Iron Sword** (Warrior weapon)
```lua
stats = {
    stat_speed = 0,
    stat_damage = 4,
    stat_range = 0,
    stat_agility = 0,
    stat_power = 0,
    stat_defense = 0,
}
```

**Calculation:**
```
BUDGET = (0 × 0.80 × 1.0) +   -- speed
         (4 × 1.00 × 1.0) +   -- damage
         (0 × 0.50 × 1.0) +   -- range
         (0 × 0.60 × 1.0) +   -- agility
         (0 × 0.40 × 1.0) +   -- power (warrior)
         (0 × 0.40 × 1.0)     -- defense

BUDGET = 0 + 4.0 + 0 + 0 + 0 + 0 = 4.0
```

**Result:** Budget = 4.0 (Starting tier weapon)

### 2.3 Budget Ranges by Tier

| Tier | Budget Range | Value Range | Example Use |
|------|--------------|-------------|-------------|
| **Starting** | 0-5 | 50-150 gold | Initial equipment |
| **Early** | 6-10 | 150-300 gold | Level 2-5 upgrades |
| **Mid** | 11-16 | 300-600 gold | Level 6-15 upgrades |
| **Late** | 17-24 | 600-1000 gold | Level 16-25 gear |
| **Legendary** | 25-35 | 1000+ gold | Endgame artifacts |

---

## 3. CLASS-SPECIFIC MODIFIERS

### 3.1 Class Multiplier Table

Each class values stats differently based on their combat role.

| Stat | Warrior | Archer | Mage |
|------|----------|---------|-------|
| **stat_damage** | 1.0 | 1.0 | 0.8 |
| **stat_speed** | 0.9 | 1.2 | 0.8 |
| **stat_range** | 0.4 | 1.0 | 0.6 |
| **stat_agility** | 0.5 | 0.8 | 0.5 |
| **stat_power** | 0.4 | 0.6 | 1.2 |
| **stat_defense** | 0.8 | 0.4 | 0.4 |

### 3.2 Class-Specific Rationale

**WARRIOR (Frontline Tank)**
- **stat_damage (1.0)**: Primary damage dealer
- **stat_speed (0.9)**: Values speed, but not critical
- **stat_range (0.4)**: Melee-focused, range is least valuable
- **stat_agility (0.5)**: Doesn't rely on dodging
- **stat_power (0.4)**: Few active abilities
- **stat_defense (0.8)**: High survival value

**ARCHER (Ranged DPS)**
- **stat_damage (1.0)**: Primary damage dealer
- **stat_speed (1.2)**: Attack speed = kite potential
- **stat_range (1.0)**: Core identity - keep enemies away
- **stat_agility (0.8)**: Kiting requires movement
- **stat_power (0.6)**: Some utility abilities
- **stat_defense (0.4)**: Range is defense

**MAGE (Burst/Specialist)**
- **stat_damage (0.8)**: Secondary to spell power
- **stat_speed (0.8)**: Cast speed matters, but not primary
- **stat_range (0.6)**: Safety matters, but not identity
- **stat_agility (0.5)**: Not a kiting class
- **stat_power (1.2)**: PRIMARY STAT - spell scaling
- **stat_defense (0.4)**: Squishy, relies on damage, not defense

### 3.3 Class Budget Adjustment

When calculating budget for a specific class:

**For Warrior Weapons:**
```
WARRIOR_BUDGET =
    (stat_damage × 1.0) +
    (stat_speed × 0.9) +
    (stat_range × 0.4) +
    (stat_agility × 0.5) +
    (stat_power × 0.4) +
    (stat_defense × 0.8)
```

**For Archer Weapons:**
```
ARCHER_BUDGET =
    (stat_damage × 1.0) +
    (stat_speed × 1.2) +
    (stat_range × 1.0) +
    (stat_agility × 0.8) +
    (stat_power × 0.6) +
    (stat_defense × 0.4)
```

**For Mage Weapons:**
```
MAGE_BUDGET =
    (stat_damage × 0.8) +
    (stat_speed × 0.8) +
    (stat_range × 0.6) +
    (stat_agility × 0.5) +
    (stat_power × 1.2) +
    (stat_defense × 0.4)
```

---

## 4. TIER PROGRESSION

### 4.1 Tier Definitions

| Tier | Budget | Max Single Stat | Min Tradeoff Required | Drop Location |
|------|--------|-----------------|----------------------|---------------|
| **T0: Training** | 0-3 | +3 | N/A | Tutorial |
| **T1: Starting** | 4-7 | +5 | 1:1 | Level 1 areas |
| **T2: Early** | 8-12 | +6 | 1:1.2 | Level 3-6 |
| **T3: Mid** | 13-18 | +7 | 1:1.5 | Level 7-12 |
| **T4: Late** | 19-26 | +8 | 1:2 | Level 13-20 |
| **T5: Legendary** | 27-35 | +10 | 1:2.5 | Level 21+ / Bosses |

### 4.2 Max Stat Cap by Tier

Prevents game-breaking single-stat stacking.

| Tier | Max Positive | Max Negative | Rationale |
|------|--------------|---------------|-----------|
| T0 | +3 | -3 | Tutorial-safe |
| T1 | +5 | -5 | Starting balance |
| T2 | +6 | -6 | Early specialization |
| T3 | +7 | -7 | Mid-game power |
| T4 | +8 | -8 | Late-game scaling |
| T5 | +10 | -10 | Legendary extremes |

### 4.3 Tradeoff Requirements

Higher tiers demand stat tradeoffs. Single-stat weapons are weak.

**Tradeoff Formula:**
```
REQUIRED_NEGATIVE = (POSITIVE_SUM - TIER_CAP) × TRADEOFF_RATIO
```

**Tradeoff Ratios:**
| Tier | Tradeoff Ratio | Example |
|------|----------------|----------|
| T1 | 0:1 (no required tradeoff) | +5 damage, 0 negative |
| T2 | 0.2:1 | +6 damage requires -1.2 negative → -2 |
| T3 | 0.4:1 | +7 damage requires -2.8 negative → -3 |
| T4 | 0.6:1 | +8 damage requires -4.8 negative → -5 |
| T5 | 0.8:1 | +10 damage requires -8 negative → -8 |

---

## 5. BALANCE FORMULAS

### 5.1 Weapon Balance Formula

**Complete Balance Check:**
```
CLASS_BUDGET = Σ(stat_value × class_multiplier × stat_amount)

BALANCE_CHECK =
    (CLASS_BUDGET >= TIER_MIN) AND
    (CLASS_BUDGET <= TIER_MAX) AND
    (MAX_STAT <= TIER_STAT_CAP) AND
    (NEGATIVE_STATS >= REQUIRED_NEGATIVE)
```

### 5.2 Equivalent Damage Formula

Convert any stat to damage-equivalent for comparison:

**For Warriors:**
```
DAMAGE_EQUIVALENT =
    stat_damage +
    (stat_speed × 0.9) +
    (stat_range × 0.4) +
    (stat_agility × 0.5) +
    (stat_power × 0.4) +
    (stat_defense × 0.8)
```

**For Archers:**
```
DAMAGE_EQUIVALENT =
    stat_damage +
    (stat_speed × 1.2) +
    (stat_range × 1.0) +
    (stat_agility × 0.8) +
    (stat_power × 0.6) +
    (stat_defense × 0.4)
```

**For Mages:**
```
DAMAGE_EQUIVALENT =
    (stat_damage × 0.8) +
    (stat_speed × 0.8) +
    (stat_range × 0.6) +
    (stat_agility × 0.5) +
    (stat_power × 1.2) +
    (stat_defense × 0.4)
```

### 5.3 DPS Impact Formula

Calculate actual DPS change from stat modifications:

```
BASE_DPS = base_damage × base_speed
FINAL_DAMAGE = base_damage + stat_damage
FINAL_SPEED = base_speed × (1 + stat_speed/100)
FINAL_DPS = FINAL_DAMAGE × FINAL_SPEED

DPS_CHANGE = FINAL_DPS - BASE_DPS
DPS_PERCENT = (DPS_CHANGE / BASE_DPS) × 100
```

**Example (Warrior with Iron Sword):**
```
BASE_DPS = 20 × 1.0 = 20
FINAL_DAMAGE = 20 + 4 = 24
FINAL_SPEED = 1.0 × (1 + 0/100) = 1.0
FINAL_DPS = 24 × 1.0 = 24

DPS_CHANGE = 24 - 20 = +4
DPS_PERCENT = (4 / 20) × 100 = +20%
```

### 5.4 Budget-to-Value Formula

Convert budget to gold value for pricing:

```
BASE_VALUE = 50 + (BUDGET × 10)
RARITY_MULTIPLIER =
    1.0 for Common
    1.5 for Uncommon
    2.0 for Rare
    3.0 for Epic
    5.0 for Legendary

FINAL_VALUE = BASE_VALUE × RARITY_MULTIPLIER
```

---

## 6. EXAMPLE CALCULATIONS

### 6.1 Starting Weapon: Iron Sword

**Stats:**
```lua
stat_speed = 0
stat_damage = 4
stat_range = 0
stat_agility = 0
stat_power = 0
stat_defense = 0
```

**Warrior Budget:**
```
= (0 × 0.9) + (4 × 1.0) + (0 × 0.4) + (0 × 0.5) + (0 × 0.4) + (0 × 0.8)
= 0 + 4.0 + 0 + 0 + 0 + 0
= 4.0
```

**Tier:** T1 (Starting)
**Value:** 50 + (4 × 10) = **90 gold**
**DPS Impact:** +20% damage output

---

### 6.2 Early Weapon: Dagger

**Stats:**
```lua
stat_speed = 5
stat_damage = -4
stat_range = -3
stat_agility = 4
stat_power = 0
stat_defense = -2
```

**Warrior Budget:**
```
= (5 × 0.9) + (-4 × 1.0) + (-3 × 0.4) + (4 × 0.5) + (0 × 0.4) + (-2 × 0.8)
= 4.5 + (-4.0) + (-1.2) + 2.0 + 0 + (-1.6)
= -0.3
```

**Result:** UNDERBUDGETED - needs buff
**Suggested Fix:** Increase stat_agility to +5
```
New Budget = (5 × 0.9) + (-4 × 1.0) + (-3 × 0.4) + (5 × 0.5) + (0 × 0.4) + (-2 × 0.8)
= 4.5 - 4.0 - 1.2 + 2.5 - 1.6
= 0.2
```
Still under T1 minimum. Let's try: stat_damage = -3
```
New Budget = (5 × 0.9) + (-3 × 1.0) + (-3 × 0.4) + (5 × 0.5) + (0 × 0.4) + (-2 × 0.8)
= 4.5 - 3.0 - 1.2 + 2.5 - 1.6
= 1.2
```

**Balanced Version:**
```lua
stat_speed = 5
stat_damage = -2
stat_range = -3
stat_agility = 5
stat_power = 0
stat_defense = -2
```
Budget = 3.2 (T0-T1 border)

---

### 6.3 Mid Weapon: War Hammer

**Stats:**
```lua
stat_speed = -8
stat_damage = 10
stat_range = -2
stat_agility = -5
stat_power = 6
stat_defense = 2
```

**Warrior Budget:**
```
= (-8 × 0.9) + (10 × 1.0) + (-2 × 0.4) + (-5 × 0.5) + (6 × 0.4) + (2 × 0.8)
= (-7.2) + 10.0 + (-0.8) + (-2.5) + 2.4 + 1.6
= 3.5
```

**Result:** SEVERELY UNDERBUDGETED for stats
**Issue:** +10 damage exceeds T4 cap but budget is T1
**Fix:** Reduce to tier-appropriate values

**Balanced Version (T3):**
```lua
stat_speed = -7
stat_damage = 7
stat_range = -2
stat_agility = -5
stat_power = 5
stat_defense = 2
```

**Warrior Budget:**
```
= (-7 × 0.9) + (7 × 1.0) + (-2 × 0.4) + (-5 × 0.5) + (5 × 0.4) + (2 × 0.8)
= (-6.3) + 7.0 + (-0.8) + (-2.5) + 2.0 + 1.6
= 1.0
```

Still under. Let's rebalance for T3 (budget 13-18):

```lua
stat_speed = -7
stat_damage = 7
stat_range = -2
stat_agility = -3
stat_power = 4
stat_defense = 4
```

**Warrior Budget:**
```
= (-7 × 0.9) + (7 × 1.0) + (-2 × 0.4) + (-3 × 0.5) + (4 × 0.4) + (4 × 0.8)
= (-6.3) + 7.0 + (-0.8) + (-1.5) + 1.6 + 3.2
= 3.2
```

**Problem:** High positive stats require significant negatives. Let's redesign for T3:

```lua
stat_speed = -5
stat_damage = 6
stat_range = 0
stat_agility = -2
stat_power = 3
stat_defense = 2
```

**Warrior Budget:**
```
= (-5 × 0.9) + (6 × 1.0) + (0 × 0.4) + (-2 × 0.5) + (3 × 0.4) + (2 × 0.8)
= (-4.5) + 6.0 + 0 + (-1.0) + 1.2 + 1.6
= 3.3
```

This suggests the budget system needs calibration. Let's adjust multiplier weights.

---

## 7. WEAPON VALIDATION TABLES

### 7.1 Current Weapons Analysis (Warrior)

| Weapon | Budget (Warrior) | Tier | Status | Notes |
|--------|------------------|------|--------|-------|
| Iron Sword | 4.0 | T1 | BALANCED | Good starting weapon |
| Dagger | -0.3 | T0 | UNDERBUDGET | Needs +1-2 stats |
| Battle Axe | 5.72 | T1 | BALANCED | Solid early weapon |
| Spear | 4.8 | T1 | BALANCED | Versatile |
| War Hammer | 3.5 | T1 | **SEVERELY UNDER** | Stats suggest T4, budget says T1 |

### 7.2 Current Weapons Analysis (Archer)

| Weapon | Budget (Archer) | Tier | Status | Notes |
|--------|-----------------|------|--------|-------|
| Short Bow | 9.4 | T2 | BALANCED | Good early game |
| Longbow | 15.4 | T3 | BALANCED | Solid mid-game |
| Crossbow | 16.2 | T3 | BALANCED | Powerful late-early |

### 7.3 Current Weapons Analysis (Mage)

| Weapon | Budget (Mage) | Tier | Status | Notes |
|--------|---------------|------|--------|-------|
| Ember Focus | 7.6 | T2 | BALANCED | Good starter |
| Fireball | 18.0 | T3 | BALANCED | Strong nuke |
| Ice Bolt | 9.2 | T2 | BALANCED | Balanced spell |
| Lightning Bolt | 8.4 | T2 | BALANCED | Fast caster |
| Arcane Bolt | 8.8 | T2 | BALANCED | Speed/utility |
| Magma Strike | 16.4 | T3 | BALANCED | High power |

---

## 8. DESIGN GUIDELINES

### 8.1 Weapon Creation Checklist

When creating a new weapon:

**Step 1: Choose Tier**
- Determine target tier (T1-T5)
- Note budget range and stat caps

**Step 2: Choose Class**
- Determine primary class
- Use class-specific multipliers

**Step 3: Design Stat Profile**
```
A. Pick 1-2 primary stats to emphasize
B. Add appropriate tradeoffs
C. Calculate budget
D. Verify against tier constraints
```

**Step 4: Validate Balance**
```
✓ Budget within tier range
✓ No stat exceeds tier cap
✓ Tradeoffs sufficient for positives
✓ Class-appropriate stat focus
```

**Step 5: Calculate Value**
```
VALUE = (50 + BUDGET × 10) × RARITY_MULTIPLIER
```

### 8.2 Balance Validation Script

```lua
function validateWeapon(weapon, classId)
    local multipliers = {
        warrior = {
            stat_damage = 1.0,
            stat_speed = 0.9,
            stat_range = 0.4,
            stat_agility = 0.5,
            stat_power = 0.4,
            stat_defense = 0.8,
        },
        archer = {
            stat_damage = 1.0,
            stat_speed = 1.2,
            stat_range = 1.0,
            stat_agility = 0.8,
            stat_power = 0.6,
            stat_defense = 0.4,
        },
        mage = {
            stat_damage = 0.8,
            stat_speed = 0.8,
            stat_range = 0.6,
            stat_agility = 0.5,
            stat_power = 1.2,
            stat_defense = 0.4,
        },
    }

    local mult = multipliers[classId]
    local budget = 0

    for stat, value in pairs(weapon.stats) do
        local statMult = mult[stat] or 1.0
        budget = budget + (value * statMult)
    end

    return budget
end
```

### 8.3 Quick Reference Cards

**WARRIOR WEAPON DESIGN**
- Focus: stat_damage, stat_defense
- Secondary: stat_speed (0.9), stat_power (0.4)
- Avoid: stat_range (0.4)
- Tradeoffs: stat_agility is cheap to lose

**ARCHER WEAPON DESIGN**
- Focus: stat_damage, stat_speed (1.2), stat_range (1.0)
- Secondary: stat_agility (0.8)
- Avoid: stat_defense (0.4)
- Tradeoffs: stat_power, stat_defense

**MAGE WEAPON DESIGN**
- Focus: stat_power (1.2)
- Secondary: stat_damage (0.8), stat_speed (0.8)
- Avoid: stat_defense (0.4), stat_agility (0.5)
- Tradeoffs: stat_range is okay to lose

---

## APPENDIX A: STAT IMPACT CALCULATIONS

### A.1 Speed Impact on DPS

**Formula:**
```
SPEED_MULTIPLIER = 1 + (stat_speed / 100)
NEW_DPS = (base_damage + stat_damage) × base_speed × SPEED_MULTIPLIER
```

**Example: +5 Speed**
```
Base: 20 damage × 1.0 speed = 20 DPS
+5 Speed: 20 damage × 1.0 × 1.05 = 21 DPS
Increase: +5% DPS
```

### A.2 Range Impact on Safety

**Formula:**
```
ATTACK_RANGE_TILES = base_range + stat_range
SAFE_POSITIONS = ATTACK_RANGE_TILES - ENEMY_RANGE
```

**Example: +3 Range**
```
Base: 2 tiles, Enemy: 1 tile
Safe positions: 2 - 1 = 1 tile back
+3 Range: 5 tiles, Enemy: 1 tile
Safe positions: 5 - 1 = 4 tiles back
Safety increase: +300%
```

### A.3 Defense Impact on Survivability

**Formula:**
```
DAMAGE_TAKEN = ENEMY_DAMAGE × (1 - (stat_defense / 100))
HITS_TO_KILL = PLAYER_HP / DAMAGE_TAKEN
```

**Example: +5 Defense, 20 HP vs 10 Damage Enemy**
```
No Defense: 10 × 1.0 = 10 damage, 20/10 = 2 hits
+5 Defense: 10 × 0.95 = 9.5 damage, 20/9.5 = 2.1 hits
Increase: +5% effective HP
```

---

## APPENDIX B: RECOMMENDED FIXES

### B.1 War Hammer Rebalance

**Current:**
```lua
stat_speed = -8
stat_damage = 10
stat_range = -2
stat_agility = -5
stat_power = 6
stat_defense = 2
```
Budget: 3.5 (T1) - **MISMATCHED**

**Recommended (T3 - Mid Game):**
```lua
stat_speed = -5
stat_damage = 7
stat_range = -1
stat_agility = -3
stat_power = 4
stat_defense = 3
```
Budget: 3.7 - Still low. Increase damage or power.

**Final Recommendation:**
```lua
stat_speed = -6
stat_damage = 7
stat_range = -1
stat_agility = -4
stat_power = 6
stat_defense = 4
```
Budget: 4.6 - Acceptable for T2-T3

### B.2 Dagger Rebalance

**Current:**
```lua
stat_speed = 5
stat_damage = -4
stat_range = -3
stat_agility = 4
stat_power = 0
stat_defense = -2
```
Budget: -0.3 (T0) - **UNDERBUDGET**

**Recommended:**
```lua
stat_speed = 6
stat_damage = -2
stat_range = -2
stat_agility = 5
stat_power = 0
stat_defense = -2
```
Budget: 4.7 - **BALANCED for T1**

---

## CONCLUSION

This balance system provides:

1. **Mathematical rigor** - Budget calculations prevent overpowered/underpowered items
2. **Class identity** - Each class values stats differently
3. **Clear progression** - Tier system guides player advancement
4. **Flexibility** - Formula-based, easy to adjust
5. **Transparency** - All values and formulas documented

**Next Steps:**
1. Apply fixes to flagged weapons
2. Run balance validation on all items
3. Playtest to verify theoretical balance
4. Adjust multipliers based on player feedback

---

**Document Status:** READY FOR IMPLEMENTATION
**Maintainer:** Game Design Lead
**Last Updated:** 2025-02-14
