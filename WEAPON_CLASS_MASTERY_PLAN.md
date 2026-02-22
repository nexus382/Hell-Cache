# Weapon Class + Mastery System (Plan)

## Goal

Implement a future-proof weapon system where:
- Any class can use any weapon.
- Using a weapon outside your class skill reduces effectiveness (damage + attack speed).
- Players can improve proficiency via **Weapon Mastery** skills.
- System is easy to expand (more weapon classes, per-weapon subtypes, mastery XP, etc.).
- Runtime lookups are fast and VMU-Pro-safe (no `math.random`, simple tables, minimal per-frame work).

This plan intentionally builds a **shared foundation** for:
- Melee weapons (current sword swing logic)
- Ranged weapons (bows/crossbows)
- Magic ranged attacks (bolts/fireballs/etc.)

## Existing Data We Build On

Current weapon items live in `data/items.lua`:
- `kind = "weapon"`
- `class_affinity` currently indicates intended class ("warrior"/"archer"/"mage"/"any")
- `stats` with modifiers `stat_speed`, `stat_damage`, `stat_range`, etc.

Important: this plan treats `class_affinity` as **recommendation/flavor**, not a hard restriction.

## Weapon Classes (v1)

Weapon classes are numeric IDs (fast lookups, easy to store in save data):
- `1` = melee
- `2` = ranged
- `3` = magic

In code (in `app_full.lua`) these map to:
- `WEAPON_CLASS_MELEE = 1`
- `WEAPON_CLASS_RANGED = 2`
- `WEAPON_CLASS_MAGIC = 3`

Future expansion examples:
- Add IDs for new weapon classes (for example: `4=holy`, `5=throwing`, etc.).
- Add subtypes: `sword`, `axe`, `bow`, `crossbow`, `staff`, `spell_projectile`, etc.
- Add “hybrid” weapons by mapping a weapon to a primary class and optional secondary tags.

## Mastery Skills (v1)

Three mastery skills (each is levelable 0..10 by the player):
- `Melee Mastery` (weapon class `1`)
- `Ranged Mastery` (weapon class `2`)
- `Magic Mastery` (weapon class `3`)

### Mastery Effects Per Level (player-invested level)
- +2.5% damage for that weapon class
- +2% attack speed for that weapon class

### Class Baseline Points (free points, do NOT consume the 10-level cap)

Each class starts with **+5 bonus points** in its primary weapon class:
- Warrior: +5 melee (`1`)
- Archer: +5 ranged (`2`)
- Mage: +5 magic (`3`)

These bonus points:
- provide the same benefits as mastery points
- do not count against the **10-point** mastery limit
- can be generalized later for new classes

So the maximum *effective* points for a weapon class at v1 is:
- bonus 5 + mastery 10 = 15 (for the class’s primary weapon class)

## Proficiency Model (Bonus + Growth) - Simple and Expandable

We want everyone to be **100% effective** with all weapon classes by default, and then:
- the class’s primary weapon class gets a free +5 bonus
- player mastery adds on top

Define constants:
- `WEAPON_BASELINE_POINTS = 5`
- `WEAPON_MASTERY_CAP = 10`
- `WEAPON_DAMAGE_PER_POINT = 0.025` (2.5%)
- `WEAPON_SPEED_PER_POINT = 0.02` (2%)

Definitions:
- `bonus_points(classId, weaponClass)` returns `5` for the class’s primary weapon class, else `0`.
- `mastery_points(weaponClass)` is the player-invested mastery level `0..10`.
- `effective_points = bonus_points + mastery_points`

Damage multiplier:
```
damage_mult = 1.0 + effective_points * WEAPON_DAMAGE_PER_POINT
```

Attack speed multiplier:
```
speed_mult = 1.0 + effective_points * WEAPON_SPEED_PER_POINT
```

This guarantees:
- Any class at zero points (effective = 0) => multiplier = 1.0 (100%)
- Primary class with only the +5 bonus (effective = 5):
  - damage_mult = 1 + 5*0.025 = 1.125 (+12.5%)
  - speed_mult  = 1 + 5*0.02  = 1.10  (+10%)
- Any class with full mastery (effective = 10):
  - damage_mult = 1 + 10*0.025 = 1.25 (+25%)
  - speed_mult  = 1 + 10*0.02  = 1.20 (+20%)
- Primary class with bonus + full mastery (effective = 15):
  - damage_mult = 1 + 15*0.025 = 1.375 (+37.5%)
  - speed_mult  = 1 + 15*0.02  = 1.30  (+30%)

Recommended clamps (to avoid extreme behavior if expanded later):
- `damage_mult` clamp to `[1.00, 1.50]`
- `speed_mult` clamp to `[1.00, 1.40]`

These clamps are easy to tune later once ranged + magic are playable.

## Data Model (Runtime State)

Extend the build state (in `data/runtime_state.lua`) with mastery tracking:

```
weapon_mastery = {
  [1] = 0, -- melee
  [2] = 0, -- ranged
  [3] = 0, -- magic
},
weapon_mastery_points = 0,
```

Mastery currency is separate from stats:
- `weapon_mastery_points` is earned on level-up and spent in the `MASTERIES` menu.

## Item Model (Weapon Class Tagging)

Add a field to weapon items:
- `weapon_class = 1 | 2 | 3`

This is better than inferring from `class_affinity` (because we want any class to equip any weapon).

We can still keep `class_affinity` as:
- “recommended” class
- loot bias hints
- merchant category hints

## Weapon Class Profiles (Future-Proof Behaviors)

Weapon class IDs are meant to drive not just numbers, but *behavior*. Add a profile table keyed by `weapon_class` so adding a new weapon becomes:
1) fill out the generic stat sheet, and
2) set `weapon_class`, and
3) the class profile decides how it swings/shoots/animates.

Example shape (high-level):
- `WeaponClassProfiles[1]` melee swing timings + hit rules
- `WeaponClassProfiles[2]` ranged projectile rules + projectile sprite
- `WeaponClassProfiles[3]` magic projectile rules + VFX variants

## Where To Apply Mastery Multipliers

Apply multipliers to the *current equipped weapon class*:
- Damage: multiply final outgoing damage by `damage_mult`
- Attack speed: multiply attack speed by `speed_mult`

Important detail: in current code, “attack speed” is often expressed as “frames per attack”.
- If the code uses a *frame scale* variable (bigger => slower), apply speed as a divisor:
  - `attack_frame_scale = attack_frame_scale / speed_mult`

## Implementation Steps (Concrete)

### Step A: Define Weapon Classes and Mapping Helpers

In `app_full.lua`:
- Add constants: `WEAPON_CLASS_MELEE`, `WEAPON_CLASS_RANGED`, `WEAPON_CLASS_MAGIC`
- Add helper: `getEquippedWeaponId()` (reads `player_build_state.equipment.weapon`)
- Add helper: `getWeaponClassForItem(itemId)`
  - uses `data/items.lua` `weapon_class` (new field)
  - safe fallback: melee if unknown

### Step B: Add Mastery State + Safe Accessors

In `data/runtime_state.lua`:
- Add `weapon_mastery` table to default build state.

In `app_full.lua`:
- Add `ensureWeaponMasteryState()` that initializes missing keys.
- Add `getWeaponMasteryPoints(weaponClass)` -> 0..10
- Add `getWeaponBasePointsForClass(classId, weaponClass)` -> 5 or 0
- Add `computeWeaponProficiencyMultipliers(classId, weaponClass)` -> `{damage_mult, speed_mult}`

### Step C: Persist Mastery in Save Slots

If you continue using the existing `saves.dat` slot serialization in `app_full.lua`:
- Expand slot fields to include mastery levels (3 ints) and optionally mastery currency.
- Ensure backwards compatibility:
  - if older save line has fewer fields, treat missing mastery as 0.

### Step D: Apply to Current Melee Attacks (Immediate Value)

Wire the multipliers into the existing melee attack path first:
- When player hits enemy:
  - `final_damage = base_damage * damage_mult`
- When computing swing duration:
  - incorporate `speed_mult` so class bonus/mastery swings faster.

This gives quick validation of the system before ranged is built.

### Step E: Build Generic Projectile System (Ranged + Magic)

Implement a single projectile update/render/hit pipeline:
- projectile state: `x, y, dir, speed, ttl, damage, spriteId/effectId, weapon_class`
- update tick: move in small increments; stop on wall hit
- enemy hit: distance check against enemy sprites; apply damage and delete projectile
- deterministic: avoid randomness; use fixed speeds and simple rules

Then:
- Archer bow: spawn “arrow” projectile (weapon_class = `2`)
- Mage bolt: spawn “bolt” projectile (weapon_class = `3`)

### Step F: UI For Mastery Allocation

Add a pause submenu:
- `MASTERIES`
- shows melee/ranged/magic with levels 0..10 (and effective points including class bonus)
- allows spending points to increase mastery levels

UI should display:
- mastery level (0..10)
- effective points (bonus + mastery)
- resulting multipliers (damage %, speed %)

## Performance Notes (VMU Pro)

To keep frame-time stable:
- Compute and cache the current `damage_mult/speed_mult` only when:
  - class changes
  - weapon changes
  - mastery changes
  - level changes (if we later tie mastery scaling to level)
- Keep runtime operations integer-heavy where possible.
- Avoid string-heavy logic inside per-frame loops.

## Open Questions (For The Next Iteration)

1. Do weapon item `stat_speed` bonuses stack multiplicatively with mastery speed, or additively in “points space”?
2. Should “magic weapons” be only ranged projectiles, or can a magic weapon also drive a melee swing variant later?

## Summary

This plan creates a clean, expandable weapon class system where:
- all classes start at 100% effectiveness for all weapon classes
- each class has a free +5 bonus in its primary weapon class (still can buy +10 mastery anywhere)
- the projectile system becomes the shared backbone for ranged + magic attacks
