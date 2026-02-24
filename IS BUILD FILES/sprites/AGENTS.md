# Sprites Directory

<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-23 -->

Build output directory containing compiled sprite assets for Inner Sanctum game.

## Purpose

This directory stores the final, build-ready sprite assets used by the game runtime. These are processed/optimized versions of source artwork from the main `sprites/` directory.

## Directory Structure

```
sprites/
├── level1/          # Level 1 character sprites (warrior class)
├── level2/          # Level 2 character sprites (warrior class)
├── test/            # Test/legacy sprite assets
├── wall_textures/   # Wall texture sprites for dungeon rendering
└── title.png        # Title screen graphic
```

## Subdirectories

### level1/

Level 1 warrior character sprites with the following animation sets:

| Category | Files | Purpose |
|----------|-------|---------|
| Idle | `warrior_front.png`, `warrior_back.png`, `warrior_left.png`, `warrior_right.png` | Directional idle poses |
| Walk | `warrior_walk[1-3].png`, `warrior_walk[1-3]_[direction].png` | Walking animation (3 frames, 4 directions) |
| Attack | `warrior_attack_[direction][1-2].png` | Attack animation (2 frames, 4 directions) |
| Sword FX | `sword_attack[1-9].png` | Sword swing visual effects (9 frames) |
| Death | `warrior_death[1-7].png` | Death animation (7 frames) |
| Item | `potion.png` | Potion pickup sprite |

### level2/

Level 2 warrior character sprites - identical structure to level1 with upgraded visuals.

### test/

Legacy test assets:
- `mask_guy_idle_old.bmp` - Old test sprite (BMP format)

### wall_textures/

Dungeon wall texture set for raycasting renderer:

| Texture | Files | Description |
|---------|-------|-------------|
| Brick | `brick.png`, `brick-table-1-128.png` | Brick wall texture |
| Metal | `metal.png`, `metal-table-1-128.png` | Metal wall texture |
| Moss | `moss.png`, `moss-table-1-128.png` | Moss-covered stone texture |
| Stone | `stone.png`, `stone-table-1-128.png` | Stone wall texture |
| Wood | `wood.png`, `wood-table-1-128.png` | Wooden wall texture |

The `*-table-1-128.png` variants are likely optimized/lookup-table versions for the raycasting engine.

## Root Files

| File | Description |
|------|-------------|
| `title.png` | Game title screen graphic |

## File Format

- Primary format: PNG (alpha channel support)
- Legacy format: BMP (test directory only)

## Usage Notes

1. These are BUILD OUTPUT files - do not edit directly
2. Source assets are located in `/mnt/r/inner-santctum/sprites/`
3. Rebuild sprites from source after modifying original artwork
4. Naming convention follows: `{character}_{action}{frame}_{direction}.png`
