# Level 1 Sprites

<!-- Parent: ../AGENTS.md -->

> Sprite assets for Level 1 characters and items. Last updated: 2026-02-23.

## Overview

This directory contains sprite assets for Level 1 game content, including the Warrior character class animations, weapon effects, and pickup items.

## File Inventory

### Warrior Class Sprites

#### Idle States (4 files)
Static directional sprites for the Warrior when not moving.

| File | Direction | Description |
|------|-----------|-------------|
| `warrior_front.png` | Front | Forward-facing idle pose |
| `warrior_back.png` | Back | Backward-facing idle pose |
| `warrior_left.png` | Left | Left-facing idle pose |
| `warrior_right.png` | Right | Right-facing idle pose |

#### Walk Animation (12 files)
Walking animation frames organized by direction. Each direction has 3 frames for smooth animation cycling.

| File | Direction | Frame |
|------|-----------|-------|
| `warrior_walk1.png` | Left | Frame 1 |
| `warrior_walk2.png` | Left | Frame 2 |
| `warrior_walk3.png` | Left | Frame 3 |
| `warrior_walk1_back.png` | Back | Frame 1 |
| `warrior_walk2_back.png` | Back | Frame 2 |
| `warrior_walk3_back.png` | Back | Frame 3 |
| `warrior_walk1_front.png` | Front | Frame 1 |
| `warrior_walk2_front.png` | Front | Frame 2 |
| `warrior_walk3_front.png` | Front | Frame 3 |
| `warrior_walk1_r.png` | Right | Frame 1 |
| `warrior_walk2_r.png` | Right | Frame 2 |
| `warrior_walk3_r.png` | Right | Frame 3 |

#### Attack Animation (10 files)
Combat attack frames organized by direction.

| File | Direction | Frame |
|------|-----------|-------|
| `warrior_attack_front1.png` | Front | Frame 1 |
| `warrior_attack_front2.png` | Front | Frame 2 |
| `warrior_attack_back1.png` | Back | Frame 1 |
| `warrior_attack_back2.png` | Back | Frame 2 |
| `warrior_attack_left1.png` | Left | Frame 1 |
| `warrior_attack_left2.png` | Left | Frame 2 |
| `warrior_attack_right1.png` | Right | Frame 1 |
| `warrior_attack_right2.png` | Right | Frame 2 |

#### Death Animation (7 files)
Sequential death animation frames.

| File | Frame | Description |
|------|-------|-------------|
| `warrior_death1.png` | 1 | Initial hit reaction |
| `warrior_death2.png` | 2 | Stagger backward |
| `warrior_death3.png` | 3 | Losing balance |
| `warrior_death4.png` | 4 | Falling |
| `warrior_death5.png` | 5 | Mid-fall |
| `warrior_death6.png` | 6 | Near ground |
| `warrior_death7.png` | 7 | Final position |

### Weapon Effects

#### Sword Attack Effect (9 files)
Visual effect sprites for sword swing animations.

| File | Frame | Notes |
|------|-------|-------|
| `sword_attack1.png` | 1 | Wind-up |
| `sword_attack2.png` | 2 | Wind-up |
| `sword_attack3.png` | 3 | Pre-swing |
| `sword_attack4.png` | 4 | Swing start |
| `sword_attack5.png` | 5 | Peak swing (largest file) |
| `sword_attack6.png` | 6 | Swing follow-through |
| `sword_attack7.png` | 7 | Impact effect |
| `sword_attack8.png` | 8 | Fade out |
| `sword_attack9.png` | 9 | Final frame |

### Pickup Items

| File | Type | Description |
|------|------|-------------|
| `potion.png` | Consumable | Health/mana pickup item |

## Summary

| Category | File Count |
|----------|------------|
| Warrior Idle | 4 |
| Warrior Walk | 12 |
| Warrior Attack | 8 |
| Warrior Death | 7 |
| Sword Effect | 9 |
| Pickups | 1 |
| **Total** | **41** |

## Naming Convention

Files follow a consistent naming pattern:

```
{character}_{action}_{direction}{frame}.png
```

- `character`: warrior
- `action`: walk, attack, death
- `direction`: front, back, left, right (or `_r` suffix for right)
- `frame`: 1, 2, 3, etc.

**Special cases:**
- Idle sprites omit the frame number (e.g., `warrior_front.png`)
- Right direction uses `_r` suffix for walk frames (e.g., `warrior_walk1_r.png`)
- Weapon effects use `sword_attack{N}.png` format

## Usage Notes

1. **Animation Timing**: Walk animations should cycle through frames 1-2-3-2-1 for smooth motion
2. **Death Sequence**: Play frames 1-7 in sequence; do not loop
3. **Directional Sprites**: Ensure sprite facing matches character movement direction
4. **File Sizes**: Largest sprites are `sword_attack5.png` (18KB) and `sword_attack7.png` (15KB), indicating peak visual complexity
