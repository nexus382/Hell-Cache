# NEW-bmp-textures - AGENTS.md

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

This directory contains new BMP format wall textures for the Inner Sanctum raycaster engine. These textures are designed to be used with the textured wall rendering system, providing visual variety for dungeon walls.

---

## Files

| File | Size | Purpose |
|------|------|---------|
| `wall-1-tile.bmp` | 65,674 bytes | Primary wall texture variant 1 (128x128 likely) |
| `wall-1-tile1.bmp` | 32,906 bytes | Wall texture variant 1a (smaller variant) |
| `wall-1-tile2.bmp` | 32,906 bytes | Wall texture variant 1b (smaller variant) |
| `wall-2-tile.bmp` | 65,674 bytes | Secondary wall texture pattern |
| `wall-3-tile.bmp` | 65,674 bytes | Tertiary wall texture pattern |
| `wall-4-tile.bmp` | 65,674 bytes | Fourth wall texture pattern |
| `Wall-Diamond-Tile.bmp` | 65,674 bytes | Diamond-pattern decorative wall tile |
| `Wall-Window-Tile.bmp` | 65,674 bytes | Window-style wall tile with frame effect |

---

## Texture Specifications

**Standard Textures (65,674 bytes):**
- Likely format: 128x128 pixels, 24-bit BMP with header
- Used for primary wall rendering in raycaster
- Tileable patterns for seamless wall coverage

**Smaller Variants (32,906 bytes):**
- `wall-1-tile1.bmp` and `wall-1-tile2.bmp`
- Possibly 64x128 or 128x64 variants
- Alternative resolution for different use cases

---

## Naming Convention

| Pattern | Meaning |
|---------|---------|
| `wall-N-tile.bmp` | Standard wall texture numbered N |
| `wall-N-tileM.bmp` | Variant M of wall texture N |
| `Wall-[Name]-Tile.bmp` | Named decorative pattern (Diamond, Window) |

---

## Usage in Game

These textures are loaded via the VMU Pro sprite API and applied during raycaster wall rendering:

```lua
-- Example texture loading (conceptual)
local texture = vmupro.sprite.new("NEW-bmp-textures/wall-1-tile.bmp")
```

**Performance Note:** Full 128x128 textures are preferred over column-slice textures for better CPU performance on VMU Pro.

---

## Subdirectories

None.

---

## For AI Agents

### When Modifying Textures

1. Maintain BMP format compatibility with VMU Pro
2. Keep textures tileable for seamless wall rendering
3. Test on device after changes - RGB565 color conversion happens at load time
4. Respect memory constraints - large textures impact performance

### Adding New Textures

1. Create 128x128 BMP file (recommended)
2. Use descriptive naming: `wall-[type]-tile.bmp` or `Wall-[Name]-Tile.bmp`
3. Update metadata.json resources array if needed
4. Test texture loading before integration

### Integration Notes

- These textures are in the NEW-bmp-textures directory, separate from the main sprites/ directory
- May need path updates in `app_full.lua` to reference this location
- Consider consolidating with `sprites/` textures for simpler resource management

---

## See Also

- `../AGENTS.md` - Main project documentation
- `../sprites/AGENTS.md` - Sprite organization and format details
- `../app_full.lua` - Texture loading and rendering code
