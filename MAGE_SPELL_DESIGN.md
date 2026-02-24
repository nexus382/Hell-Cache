# MAGE SPELL WEAPONS DESIGN DOCUMENT

## Design Philosophy

Mage spells function as **RANGED WEAPONS** with projectile behavior. Each spell is a magic focus that modifies the mage's base stats (80 HP, 18 damage, 1.05 speed) through stat modifiers ranging from -10 to +10.

### Base Mage Stats
- **HP**: 80
- **Base Damage**: 18
- **Attack Speed**: 1.05 (5% faster than baseline)
- **Growth**: +4 HP, +3 damage per level

### Stat Modifier System
All spells use the 6-stat system:
- `stat_speed`: Attack cycle time (positive = faster attacks)
- `stat_damage`: Damage output (positive = more damage)
- `stat_range`: Attack range (positive = longer range)
- `stat_agility`: Movement/dodging (positive = more agile)
- `stat_power`: Ability effectiveness (positive = stronger)
- `stat_defense`: Damage reduction (positive = more defense)

---

## SPELL CATEGORIES

### 1. PROJECTILE SPELLS (Single-target, fire-and-forget)

| Spell ID | Name | Damage | Speed | Range | Special | Weight | Value | Stats |
|----------|------|--------|-------|-------|---------|--------|-------|-------|
| `spell_fireball` | **Fireball** | +8 | -3 | +6 | Explosion AOE (2 tiles) | 1 | 200 | `+8dmg -3spd +6rng +0agi +7pwr -1def` |
| `spell_icebolt` | **Ice Bolt** | +5 | +1 | +4 | Slow enemy 30% for 2s | 1 | 165 | `+5dmg +1spd +4rng -2agi +4pwr +1def` |
| `spell_lightning` | **Lightning Bolt** | +3 | +4 | +5 | Pierces 2 enemies | 1 | 185 | `+3dmg +4spd +5rng +2agi +3pwr -2def` |
| `spell_arcanebolt` | **Arcane Bolt** | +2 | +6 | +3 | Mana refund on hit (20%) | 1 | 150 | `+2dmg +6spd +3rng +0agi +5pwr +0def` |
| `spell_magma` | **Magma Strike** | +10 | -6 | +4 | Leaves lava pool (3s) | 1 | 225 | `+10dmg -6spd +4rng -4agi +6pwr +0def` |
| `spell_poison` | **Venom Dart** | +4 | +2 | +5 | Poison (5 dmg/s for 4s) | 1 | 175 | `+4dmg +2spd +5rng +3agi +2pwr -1def` |

### 2. BEAM SPELLS (Continuous damage, requires channel)

| Spell ID | Name | Damage | Speed | Range | Special | Weight | Value | Stats |
|----------|------|--------|-------|-------|---------|--------|-------|-------|
| `spell_arcanebeam` | **Arcane Beam** | +6 | -2 | +7 | Channel, ticks 4x/s | 1 | 220 | `+6dmg -2spd +7rng +1agi +8pwr +0def` |
| `spell_deathray` | **Death Ray** | +9 | -5 | +3 | Channel, drains mana 2x | 1 | 250 | `+9dmg -5spd +3rng -2agi +10pwr -3def` |
| `spell_frostbeam` | **Frost Beam** | +4 | -1 | +6 | Channel, slows 50% | 1 | 205 | `+4dmg -1spd +6rng +0agi +6pwr +2def` |
| `spell_lifedrain` | **Life Drain** | +3 | -3 | +5 | Channel, heals 50% damage | 1 | 240 | `+3dmg -3spd +5rng -1agi +7pwr +4def` |

### 3. AOE SPELLS (Area effect, multiple targets)

| Spell ID | Name | Damage | Speed | Range | Special | Weight | Value | Stats |
|----------|------|--------|-------|-------|---------|--------|-------|-------|
| `spell_froznova` | **Frost Nova** | +7 | -5 | +3 | Hits all nearby (3 tiles) | 1 | 210 | `+7dmg -5spd +3rng -3agi +9pwr +3def` |
| `spell_chainlight` | **Chain Lightning** | +5 | -2 | +5 | Bounces 3x, -20% dmg/bounce | 1 | 230 | `+5dmg -2spd +5rng +0agi +8pwr +1def` |
| `spell_met shower` | **Meteor Shower** | +6 | -7 | +8 | Delayed AOE, 3 meteors | 1 | 260 | `+6dmg -7spd +8rng -5agi +9pwr +0def` |
| `spell_voidzone` | **Void Zone** | +4 | -4 | +4 | Creates 2s gravity well | 1 | 215 | `+4dmg -4spd +4rng +1agi +7pwr +2def` |

### 4. UTILITY SPELLS (Defensive and mobility)

| Spell ID | Name | Damage | Speed | Range | Special | Weight | Value | Stats |
|----------|------|--------|-------|-------|---------|--------|-------|-------|
| `spell_teleport` | **Teleport** | -5 | +8 | +0 | Blink 4 tiles, 1s cooldown | 1 | 200 | `-5dmg +8spd +0rng +6agi +3pwr +0def` |
| `spell_shield` | **Arcane Shield** | -3 | +3 | +0 | Absorbs 30 damage, 5s | 1 | 180 | `-3dmg +3spd +0rng +0agi +5pwr +5def` |
| `spell_haste` | **Haste** | +1 | +5 | +0 | +50% speed for 5s | 1 | 190 | `+1dmg +5spd +0rng +4agi +4pwr +1def` |
| `spell_phaseshift` | **Phase Shift** | -2 | +4 | +0 | Invulnerable 1s, 10s CD | 1 | 210 | `-2dmg +4spd +0rng +5agi +6pwr +2def` |
| `spell_manaflare` | **Mana Flare** | +7 | -4 | +2 | Next spell costs 0 mana | 1 | 195 | `+7dmg -4spd +2rng -1agi +8pwr +0def` |

---

## IMPLEMENTATION NOTES

### Lua Data Structure

Each spell follows this template:

```lua
spell_fireball = {
    id = "spell_fireball",
    name = "Fireball",
    kind = "weapon",
    class_affinity = "mage",
    weight = 1,
    stack_max = 1,
    value = 200,
    stats = {
        stat_speed = -3,
        stat_damage = 8,
        stat_range = 6,
        stat_agility = 0,
        stat_power = 7,
        stat_defense = -1,
    },
},
```

### Special Effect Implementation

Special effects are encoded in `stat_power` and require engine support:

1. **Fireball Explosion**: On hit, deal 50% damage to all enemies within 2 tiles
2. **Ice Bolt Slow**: Reduce enemy movement speed by 30% for 2 seconds
3. **Lightning Pierce**: Projectile continues through 2 enemies dealing full damage
4. **Arcane Bolt Refund**: 20% chance to refund mana cost on successful hit
5. **Magma Pool**: Leave 2-tile lava zone dealing 3 damage/s for 3 seconds
6. **Venom Poison**: Apply poison dealing 5 damage/s for 4 seconds (stacks)
7. **Arcane Beam**: Channel-based, deals damage 4 times per second while held
8. **Death Ray**: High damage beam, consumes mana at 2x rate
9. **Frost Beam**: Channel, slows enemies by 50% while in beam
10. **Life Drain**: Channel, heal for 50% of damage dealt
11. **Frost Nova**: Instant AOE around player, 3 tile radius
12. **Chain Lightning**: Bounces to 3 nearest enemies, -20% damage per bounce
13. **Meteor Shower**: 3 delayed AOEs at target location over 2 seconds
14. **Void Zone**: Creates 2-tile gravity well pulling enemies
15. **Teleport**: Instant movement 4 tiles in facing direction, 1s cooldown
16. **Arcane Shield**: Absorbs 30 damage, lasts 5 seconds
17. **Haste**: +50% movement speed for 5 seconds
18. **Phase Shift**: Invulnerable for 1s, 10s cooldown
19. **Mana Flare**: Next spell cast costs 0 mana

### Balancing Notes

**Damage Formula**:
```
Total Damage = (base_damage + stat_damage) × (1 + stat_power/100)
```

**Attack Speed Formula**:
```
Final Speed = base_speed × (1 + stat_speed/100)
```

**Range Formula**:
```
Final Range = base_range + stat_range (in tiles)
```

**Key Balance Points**:
- **Fireball**: Slowest projectile (-3), highest damage (+8), good range (+6), explosion justifies stat_power
- **Ice Bolt**: Balanced all-rounder, slow effect compensates moderate damage
- **Lightning**: Fastest (+4), lowest base damage, piercing creates effective multi-target
- **Arcane Bolt**: Speed-focused with mana refund encourages aggressive play
- **Magma Strike**: Risk/reward with slow speed (-6) but highest damage (+10)
- **Venom Dart**: Sustained damage via poison, lower immediate damage

**Beam Spells**:
- All beams have negative speed modifiers representing channel commitment
- High stat_power values (8-10) reflect continuous damage potential
- Death Ray's extreme power (+10) balanced by mana drain and defense penalty

**AOE Spells**:
- Frost Nova: High damage (+7) to all nearby, very slow (-5)
- Chain Lightning: Moderate damage, decaying per bounce balanced by high power
- Meteor Shower: Delayed effect requires prediction, high range (+8)
- Void Zone: Control-focused, lower damage but high utility

**Utility Spells**:
- Teleport: Negative damage (-5), extreme speed (+8), high agility (+6) for escapes
- Shield: Sacrifice damage (-3) for defense (+5)
- Haste: Balanced (+1 damage, +5 speed) for sustained DPS
- Phase Shift: Moderate penalties for emergency invulnerability

---

## LOOT TABLE RECOMMENDATIONS

### Common Drops (Early Game)
- `focus_ember` (basic focus)
- `spell_icebolt`
- `spell_arcanebolt`
- `spell_haste`

### Uncommon Drops (Mid Game)
- `spell_fireball`
- `spell_lightning`
- `spell_frostbeam`
- `spell_shield`
- `spell_poison`

### Rare Drops (Late Game)
- `spell_magma`
- `spell_arcanebeam`
- `spell_froznova`
- `spell_teleport`
- `spell_lifedrain`

### Epic Drops (End Game)
- `spell_deathray`
- `spell_chainlight`
- `spell_meteor`
- `spell_voidzone`
- `spell_phaseshift`
- `spell_manaflare`

---

## MANA COST SUGGESTIONS

If mana system is implemented:

| Tier | Mana Cost | Examples |
|------|-----------|----------|
| Basic | 5-8 | Arcane Bolt, Ice Bolt |
| Standard | 8-12 | Fireball, Lightning, Poison |
| Advanced | 12-16 | Magma, Frost Beam, Arcane Beam |
| Elite | 16-20 | Death Ray, Chain Lightning, Void Zone |
| Ultimate | 20-25 | Meteor Shower, Life Drain |
| Utility | 3-10 | Teleport (6), Shield (4), Haste (5), Phase Shift (8) |

---

## SPRITE REQUIREMENTS

Each spell needs:
1. **Projectile Sprite** (24x24 to 32x32)
   - Fireball: Animated flame orb
   - Ice Bolt: Ice crystal with trail
   - Lightning: Zigzag bolt with glow
   - Arcane: Swirling magical energy

2. **Impact Effect** (32x32 to 48x48)
   - Explosion particles
   - Ice shatter
   - Lightning burst
   - Magical discharge

3. **Icon** (16x16 for UI)
   - Distinct color coding
   - Symbolic representation

**Total sprite budget**: ~19 spells × 3 sprite types = 57 sprites
**Memory estimate**: 57 × 1KB average = ~57KB (acceptable for VMU)

---

## ENGINE REQUIREMENTS

### Minimum Features
1. **Projectile System**: Speed, lifetime, collision detection
2. **Piercing**: Continue after hit (lightning)
3. **AOE Detection**: Radius query from impact point
4. **Bouncing**: Find nearest N enemies (chain lightning)
5. **Channeling**: Continuous effect while button held
6. **Status Effects**: Slow, poison, DoT tracking
7. **Cooldowns**: Per-spell cooldown timers
8. **Mana System**: Resource management (optional)

### Advanced Features
1. **Delayed Effects**: Meteor scheduling
2. **Zones**: Persistent area effects (lava, void)
3. **Blink**: Instant position change
4. **Invulnerability Frames**: Temporary damage immunity
5. **Mana Refund**: Trigger on hit
6. **Life Steal**: Heal on damage
7. **Buff Stacking**: Haste, shield duration

---

## PLAYSTYLE ARCHETYPES

These spells support distinct mage builds:

### **Glass Cannon**
- Spells: Fireball, Magma, Death Ray, Mana Flare
- Focus: Maximum damage, minimum defense
- Stats: High damage/power, negative defense/agility

### **Kiting Mage**
- Spells: Lightning, Ice Bolt, Arcane Bolt, Haste, Teleport
- Focus: Speed and range, hit-and-run
- Stats: High speed/agility, moderate damage

### **Control Mage**
- Spells: Frost Nova, Frost Beam, Void Zone, Venom Dart
- Focus: Crowd control and debuffs
- Stats: High power, balanced damage/speed

### **Battle Mage**
- Spells: Life Drain, Shield, Phase Shift, Chain Lightning
- Focus: Survivability and sustained damage
- Stats: High defense/power, moderate speed

### **Summoner/AOE**
- Spells: Meteor Shower, Chain Lightning, Frost Nova, Void Zone
- Focus: Maximum area damage
- Stats: High power/range, negative speed

---

## FUTURE EXPANSIONS

### Spell Combinations
- Cast Frost Nova → Chain Lightning for frozen group
- Cast Teleport → Fireball for reposition → burst
- Cast Mana Flare → Death Ray for free ultimate

### Synergies
- Ice Bolt slow → Magma pool guaranteed hits
- Venom poison → Life Drain for sustain
- Haste → Arcane Beam for mobile channeling

### Legendary Spells
- **Phoenix Fire**: Respawn on death, 300 HP
- **Time Warp**: Slow all enemies 80% for 5s
- **Arcane Mastery**: All spells cost 0 mana for 10s

---

## SUMMARY

**Total Spells**: 19
- **Projectile**: 6
- **Beam**: 4
- **AOE**: 4
- **Utility**: 5

**Stat Range**: All -10 to +10 (balanced)
**Damage Range**: -5 to +10
**Speed Range**: -7 to +8
**Range Range**: +0 to +8
**Weight**: All 1 (magic focuses are weightless)
**Value Range**: 150 to 260

This provides players with meaningful choices between:
- Burst vs. sustained damage
- Single-target vs. AOE
- Offense vs. defense
- Risk vs. reward

Each spell has a distinct identity and playstyle application.
