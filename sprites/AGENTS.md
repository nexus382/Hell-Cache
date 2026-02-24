# Sprites Directory

<!-- Parent: ../AGENTS.md -->
<!-- Last Updated: 2026-02-23 -->

## Overview

This directory contains all game sprite assets for the Inner Sanctum roguelike game. Sprites are organized by level and type, including character animations, weapons, items, and environmental textures.

## Directory Structure

```
sprites/
├── AGENTS.md              # This file
├── level1/                # Level 1 specific sprites
├── level2/                # Level 2 specific sprites
└── wall_textures/         # Wall and tile texture assets
```

## Root-Level Sprite Files

### Character Selection Portraits

| File | Description |
|------|-------------|
| `ARCH-CHAR-SELECT-sized.png` | Archer character selection portrait |
| `WAARRIOR-CHAR-SELECT-sized.png` | Warrior character selection portrait |
| `WIZ-CHAR-SELECT-sized.png` | Wizard character selection portrait |

### UI Elements

| File | Description |
|------|-------------|
| `title.png` | Game title screen graphic |

### Weapons and Projectiles

| File | Description |
|------|-------------|
| `STAFF.png` | Staff weapon sprite |
| `arrow.png` | Arrow projectile sprite |
| `bow_drawn.png` | Bow in drawn/ready state |
| `bow_idle.png` | Bow in idle/rest state |
| `explosion.png` | Explosion effect sprite |

### Shield Animations

| File | Description |
|------|-------------|
| `shield.png` | Base shield sprite (large) |
| `shield_raise1.png` | Shield raise animation frame 1 |
| `shield_raise2.png` | Shield raise animation frame 2 |
| `shield_raise3.png` | Shield raise animation frame 3 |
| `shield_raise4.png` | Shield raise animation frame 4 |

## Subdirectories

### `/level1/`

Level 1 specific sprite assets. Contains identical content to level2 currently.

**Contents:**
- `potion.png` - Health/mana potion pickup item
- `sword_attack[1-9].png` - Sword attack animation frames (9 frames)
- `warrior_attack_[direction][1-2].png` - Warrior attack animations (front, back, left, right)
- `warrior_death[1-7].png` - Warrior death animation frames (7 frames)
- `warrior_[direction].png` - Warrior idle poses (front, back, left, right)
- `warrior_walk[1-3].png` - Warrior walk cycle animations
- `warrior_walk[1-3]_[direction].png` - Directional walk animations

### `/level2/`

Level 2 specific sprite assets. Contains identical content to level1 currently.

**Contents:**
- Same structure as level1 (potion, sword attacks, warrior animations)

### `/wall_textures/`

Wall and tile texture assets for dungeon rendering.

**Contents:**
- `wall-1-tile.png` through `wall-4-tile.png` - Primary wall tile variants
- `wall-[1-4]-tile-table-1-128.png` - Table-optimized versions (128px)
- `Wall-Diamond-Tile.png` - Diamond-pattern wall tile
- `Wall-Window-Tile.png` - Window wall tile variant
- `roof_dirt_splatter_64.png` - Roof dirt overlay texture (64px)
- `_protected_wall1_swap_*` - Protected swap backup directory

## Sprite Naming Conventions

### Animation Frames

- Numbered sequentially: `action1.png`, `action2.png`, etc.
- Directional suffixes: `_front`, `_back`, `_left`, `_right`
- Walk cycles: `walk1`, `walk2`, `walk3`

### Texture Variants

- Base name: `wall-1-tile.png`
- Optimized version: `wall-1-tile-table-1-128.png` (for table rendering at 128px)

## Usage Notes

- All sprites use PNG format with transparency support
- Character sprites are designed for 4-directional movement
- Animation frames should be played in numerical sequence
- Wall textures use tiling patterns for seamless dungeon rendering

## Related Files

- **Parent Documentation:** `/mnt/r/inner-santctum/AGENTS.md`
- **Game Engine:** References these sprites via relative paths
- **Asset Loading:** Sprites loaded at runtime by the game engine
