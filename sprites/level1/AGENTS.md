# Level 1 Sprites Directory

<!-- Parent: ../AGENTS.md -->
<!-- Last Updated: 2026-02-23 -->

## Overview

This directory contains all sprite assets for Level 1 of the Inner Sanctum roguelike game. Assets include the Warrior character with full directional animations, sword attack effects, and collectible items.

## File Inventory

### Warrior Idle Poses (4 files)

Static standing poses for the Warrior character in all four cardinal directions.

| File | Description |
|------|-------------|
| `warrior_front.png` | Warrior facing forward (toward camera) |
| `warrior_back.png` | Warrior facing away from camera |
| `warrior_left.png` | Warrior facing left |
| `warrior_right.png` | Warrior facing right |

### Warrior Walk Animations (12 files)

Walking animation cycle with 3 frames per direction.

#### Downward Walk (default direction)
| File | Frame |
|------|-------|
| `warrior_walk1.png` | Walk cycle frame 1 |
| `warrior_walk2.png` | Walk cycle frame 2 |
| `warrior_walk3.png` | Walk cycle frame 3 |

#### Forward Walk (toward camera)
| File | Frame |
|------|-------|
| `warrior_walk1_front.png` | Walk cycle frame 1 |
| `warrior_walk2_front.png` | Walk cycle frame 2 |
| `warrior_walk3_front.png` | Walk cycle frame 3 |

#### Backward Walk (away from camera)
| File | Frame |
|------|-------|
| `warrior_walk1_back.png` | Walk cycle frame 1 |
| `warrior_walk2_back.png` | Walk cycle frame 2 |
| `warrior_walk3_back.png` | Walk cycle frame 3 |

#### Right Walk
| File | Frame |
|------|-------|
| `warrior_walk1_r.png` | Walk cycle frame 1 |
| `warrior_walk2_r.png` | Walk cycle frame 2 |
| `warrior_walk3_r.png` | Walk cycle frame 3 |

### Warrior Attack Animations (8 files)

Two-frame attack animations for each cardinal direction.

| File | Direction | Frame |
|------|-----------|-------|
| `warrior_attack_front1.png` | Forward | 1 |
| `warrior_attack_front2.png` | Forward | 2 |
| `warrior_attack_back1.png` | Backward | 1 |
| `warrior_attack_back2.png` | Backward | 2 |
| `warrior_attack_left1.png` | Left | 1 |
| `warrior_attack_left2.png` | Left | 2 |
| `warrior_attack_right1.png` | Right | 1 |
| `warrior_attack_right2.png` | Right | 2 |

### Warrior Death Animation (7 files)

Seven-frame death sequence animation.

| File | Frame | Description |
|------|-------|-------------|
| `warrior_death1.png` | 1 | Death sequence start |
| `warrior_death2.png` | 2 | Continuing fall |
| `warrior_death3.png` | 3 | Continuing fall |
| `warrior_death4.png` | 4 | Mid-fall |
| `warrior_death5.png` | 5 | Near ground |
| `warrior_death6.png` | 6 | Collapsing |
| `warrior_death7.png` | 7 | Final pose (grounded) |

### Sword Attack Effect (9 files)

Nine-frame sword swing visual effect animation.

| File | Frame |
|------|-------|
| `sword_attack1.png` | Swing start |
| `sword_attack2.png` | Wind-up |
| `sword_attack3.png` | Wind-up continuation |
| `sword_attack4.png` | Mid-swing |
| `sword_attack5.png` | Peak extension |
| `sword_attack6.png` | Follow-through start |
| `sword_attack7.png` | Follow-through |
| `sword_attack8.png` | Recovery |
| `sword_attack9.png` | Return to idle |

### Items (1 file)

| File | Description |
|------|-------------|
| `potion.png` | Health/mana potion pickup sprite |

## Summary

| Category | File Count |
|----------|------------|
| Warrior Idle Poses | 4 |
| Warrior Walk Animations | 12 |
| Warrior Attack Animations | 8 |
| Warrior Death Animation | 7 |
| Sword Attack Effect | 9 |
| Items | 1 |
| **Total** | **41** |

## Naming Conventions

### Direction Suffixes
- `_front` - Facing toward camera (south/down on screen)
- `_back` - Facing away from camera (north/up on screen)
- `_left` - Facing left (west)
- `_right` - Facing right (east)
- `_r` - Abbreviated right direction (used in walk cycles)

### Animation Numbering
- Sequential frames: `1`, `2`, `3`, etc.
- Death animation: 7 frames total
- Walk cycles: 3 frames per direction
- Attack animations: 2 frames per direction
- Sword effect: 9 frames total

## Related Files

- **Parent Documentation:** `/mnt/r/inner-santctum/sprites/AGENTS.md`
- **Level 2 Sprites:** `/mnt/r/inner-santctum/sprites/level2/` (identical content)
- **Game Engine:** Loads sprites via `sprites/level1/` relative paths
