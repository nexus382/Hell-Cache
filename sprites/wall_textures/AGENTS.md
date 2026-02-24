# Wall Textures Directory

<!-- Parent: ../AGENTS.md -->
<!-- Last Updated: 2026-02-23 -->

## Overview

This directory contains wall and tile texture assets for dungeon rendering in the Inner Sanctum roguelike game. Textures are designed for seamless tiling and include multiple variants for visual variety.

## Directory Structure

```
wall_textures/
├── AGENTS.md                              # This file
├── _protected_wall1_swap_20260211_143242/ # Backup directory (protected)
├── wall-1-tile.png                        # Primary wall variant 1
├── wall-1-tile-table-1-128.png            # Wall 1 optimized (128px)
├── wall-2-tile.png                        # Primary wall variant 2
├── wall-2-tile-table-1-128.png            # Wall 2 optimized (128px)
├── wall-3-tile.png                        # Primary wall variant 3
├── wall-3-tile-table-1-128.png            # Wall 3 optimized (128px)
├── wall-4-tile.png                        # Primary wall variant 4
├── wall-4-tile-table-1-128.png            # Wall 4 optimized (128px)
├── Wall-Diamond-Tile.png                  # Diamond pattern wall
├── Wall-Diamond-Tile-table-1-128.png      # Diamond optimized (128px)
├── Wall-Window-Tile.png                   # Window wall variant
├── Wall-Window-Tile-table-1-128.png       # Window optimized (128px)
└── roof_dirt_splatter_64.png              # Roof dirt overlay (64px)
```

## Texture Files

### Primary Wall Tiles

| File | Description | Size |
|------|-------------|------|
| `wall-1-tile.png` | Primary wall tile variant 1 (default) | ~11KB |
| `wall-2-tile.png` | Primary wall tile variant 2 | ~11KB |
| `wall-3-tile.png` | Primary wall tile variant 3 | ~10KB |
| `wall-4-tile.png` | Primary wall tile variant 4 | ~11KB |

### Table-Optimized Wall Tiles (128px)

| File | Description | Size |
|------|-------------|------|
| `wall-1-tile-table-1-128.png` | Wall 1 optimized for table rendering | ~11KB |
| `wall-2-tile-table-1-128.png` | Wall 2 optimized for table rendering | ~11KB |
| `wall-3-tile-table-1-128.png` | Wall 3 optimized for table rendering | ~10KB |
| `wall-4-tile-table-1-128.png` | Wall 4 optimized for table rendering | ~11KB |

### Specialty Wall Tiles

| File | Description | Size |
|------|-------------|------|
| `Wall-Diamond-Tile.png` | Diamond-pattern wall tile for decorative areas | ~11KB |
| `Wall-Window-Tile.png` | Wall tile with window opening | ~11KB |
| `Wall-Diamond-Tile-table-1-128.png` | Diamond tile optimized (128px) | ~11KB |
| `Wall-Window-Tile-table-1-128.png` | Window tile optimized (128px) | ~11KB |

### Overlay Textures

| File | Description | Size |
|------|-------------|------|
| `roof_dirt_splatter_64.png` | Dirt splatter overlay for roof surfaces (64px) | ~9KB |

## Protected Backup Directory

### `_protected_wall1_swap_20260211_143242/`

Protected backup directory created on 2026-02-11 at 14:32:42.

**Contents:**
- `wall-1-tile.png` - Original wall-1-tile backup
- `wall-1-tile-table-1-128.png` - Original wall-1-tile optimized backup

**Purpose:** This directory preserves the original wall-1 textures before modifications. Do not modify or delete without explicit authorization.

## Naming Conventions

### Standard Format
- Base texture: `{name}-tile.png`
- Table-optimized: `{name}-tile-table-1-128.png`

### Special Variants
- `Wall-{Pattern}-Tile.png` - Specialty pattern tiles (Diamond, Window)
- `{feature}_{size}.png` - Overlay textures with size suffix

## Usage Notes

- All textures use PNG format with transparency support
- Wall tiles are designed for seamless tiling in dungeon layouts
- Table-optimized versions (128px) are pre-scaled for specific rendering contexts
- The 4 primary wall variants provide visual variety while maintaining consistency
- Overlay textures like `roof_dirt_splatter_64.png` are applied as alpha blending layers

## Related Files

- **Parent Documentation:** `/mnt/r/inner-santctum/sprites/AGENTS.md`
- **Root Documentation:** `/mnt/r/inner-santctum/AGENTS.md`
- **Game Engine:** Loads these textures for dungeon wall rendering
