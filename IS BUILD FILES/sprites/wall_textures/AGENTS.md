# Wall Textures Directory

<!-- Parent: ../AGENTS.md -->

## Overview

This directory contains wall texture assets used for rendering wall surfaces in the game. Each texture type includes both a full-size version and a 128x128 tileable version for optimized rendering.

## Directory Structure

```
wall_textures/
  AGENTS.md
  brick.png
  brick-table-1-128.png
  metal.png
  metal-table-1-128.png
  moss.png
  moss-table-1-128.png
  stone.png
  stone-table-1-128.png
  wood.png
  wood-table-1-128.png
```

## Texture Assets

### Brick Textures

| File | Description |
|------|-------------|
| `brick.png` | Full-size brick wall texture |
| `brick-table-1-128.png` | 128x128 tileable brick texture |

Use for: Castle walls, dungeon interiors, industrial areas, aged structures.

---

### Metal Textures

| File | Description |
|------|-------------|
| `metal.png` | Full-size metal wall texture |
| `metal-table-1-128.png` | 128x128 tileable metal texture |

Use for: Sci-fi environments, industrial facilities, mechanical rooms, armored walls.

---

### Moss Textures

| File | Description |
|------|-------------|
| `moss.png` | Full-size moss-covered wall texture |
| `moss-table-1-128.png` | 128x128 tileable moss texture |

Use for: Overgrown ruins, forest interiors, ancient structures, nature-reclaimed areas.

---

### Stone Textures

| File | Description |
|------|-------------|
| `stone.png` | Full-size stone wall texture |
| `stone-table-1-128.png` | 128x128 tileable stone texture |

Use for: Cave walls, castle interiors, medieval structures, natural formations.

---

### Wood Textures

| File | Description |
|------|-------------|
| `wood.png` | Full-size wood wall texture |
| `wood-table-1-128.png` | 128x128 tileable wood texture |

Use for: Cabin interiors, fences, wooden structures, rustic environments.

---

## Naming Convention

| Pattern | Meaning |
|---------|---------|
| `{material}.png` | Full-size texture source |
| `{material}-table-1-128.png` | Tileable 128x128 optimized version |

## Usage Notes

1. **Tileable versions** (`-table-1-128`) are optimized for repeated tiling without visible seams
2. **Full-size versions** are source assets and may contain more detail
3. All textures are designed to tile seamlessly in game rendering
4. Choose texture based on environment theme and visual consistency

## Related Directories

- `../` - Parent sprites directory containing other sprite categories
- `../../` - IS BUILD FILES root directory

---
*Generated: 2026-02-23*
