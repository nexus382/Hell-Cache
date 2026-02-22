<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-17 -->

# test

## Purpose
Test sprites directory for experimental and legacy sprite assets. Contains prototype sprites and test files that are not actively used in the main game but preserved for reference and future development.

## Key Files

| File | Description |
|------|-------------|
| `mask_guy_idle_old.bmp` | Legacy idle sprite for testing character mask rendering (BMP format) |

## Asset Details

### mask_guy_idle_old.bmp
- **Format**: BMP (uncompressed bitmap)
- **Status**: Legacy/Prototype
- **Purpose**: Testing character mask rendering and sprite loading pipeline
- **Note**: Old format sprite, likely superseded by PNG versions

## For AI Agents

### Working In This Directory

**Legacy Considerations**:
- BMP format is less efficient than PNG (no compression, larger file size)
- Older sprite format may require different processing
- Test/prototype assets not optimized for game performance

**Migration Notes**:
- Consider converting BMP sprites to PNG for better performance
- Test sprite compatibility with current rendering pipeline
- Archive legacy assets if no longer needed

### Common Patterns

**Loading Legacy Sprites**:
```lua
-- BMP sprites may need special handling
local test_sprite = vmupro.sprite.new("sprites/test/mask_guy_idle_old")
-- SDK should handle BMP format but PNG is preferred
```

## Subdirectories

None (this is a leaf directory for test assets)

## Dependencies

### Internal
- `../app.lua` - Main game code (may reference test sprites during development)
- `../generate_sprites.py` - Sprite generation tools for creating new test assets

### External
- VMU Pro SDK sprite system (`vmupro.sprite.*`) - Supports multiple image formats

## Testing Requirements

- Verify BMP sprites load correctly in the game engine
- Test sprite scaling and positioning with legacy format
- Check if alpha channel is supported in BMP sprites
- Performance comparison with PNG sprites

## Known Issues

- **Format Inefficiency**: BMP files are larger than PNG equivalents
- **Limited Features**: BMP format may not support advanced features like alpha transparency

<!-- MANUAL: Test sprite documentation and development notes can be added below -->