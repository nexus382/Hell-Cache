<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# sprites

## Purpose
Game sprite assets for the 3D dungeon raycaster including character sprites, wall textures, UI elements, and level-specific resources.

## Key Files

| File | Description |
|------|-------------|
| `SPRITE_GUYS.png` | Spritesheet containing multiple character sprites |
| `FighterWeapons.png` | Weapon sprites for combat |
| `Walls.png` | Wall texture spritesheet |
| `potion.png` | Health potion UI sprite |
| `title.png` | Title screen background image |

### Warrior Character Sprites

| File | Description | State |
|------|-------------|-------|
| `warrior_front.png` | Front-facing idle sprite | ✅ Complete |
| `warrior_back.png` | Back-facing idle sprite | ✅ Complete |
| `warrior_left.png` | Left-facing idle sprite | ✅ Complete |
| `warrior_right.png` | Right-facing idle sprite | ✅ Complete |
| `warrior_walk1.png` | Left walk frame 1 | ✅ Complete |
| `warrior_walk2.png` | Left walk frame 2 | ✅ Complete |
| `warrior_walk3.png` | Left walk frame 3 | ✅ Complete |
| `warrior_walk1_r.png` | Right walk frame 1 (flipped) | ✅ Complete |
| `warrior_walk2_r.png` | Right walk frame 2 (flipped) | ✅ Complete |
| `warrior_walk3_r.png` | Right walk frame 3 (flipped) | ✅ Complete |
| `warrior_walk4.png` | Side walk frame 4 | ✅ Complete |
| `warrior_walk5.png` | Side walk frame 5 | ✅ Complete |
| `warrior_walk4_r.png` | Side walk frame 4 (flipped) | ✅ Complete |
| `warrior_walk5_r.png` | Side walk frame 5 (flipped) | ✅ Complete |
| `warrior_walk_side1.png` | Side walk alternate frame | ✅ Complete |
| `warrior_stand1.png` | Standing idle frame 1 | ✅ Complete |
| `warrior_stand2.png` | Standing idle frame 2 | ✅ Complete |

### Knight Character Sprites

| File | Description | State |
|------|-------------|-------|
| `knight_front.png` | Front-facing knight sprite | ⚠️ Not in use |
| `knight_back.png` | Back-facing knight sprite | ⚠️ Not in use |
| `knight_left.png` | Left-facing knight sprite | ⚠️ Not in use |
| `knight_right.png` | Right-facing knight sprite | ⚠️ Not in use |

**Note**: Knights are removed from the game (sprites not ready).

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `_rows/` | Individual rows extracted from spritesheets (see `_rows/AGENTS.md`) |
| `_wall_textures/` | Raw wall texture extraction files (see `_wall_textures/AGENTS.md`) |
| `level1/` | Level 1 specific character sprites (see `level1/AGENTS.md`) |
| `level2/` | Level 2 specific character sprites (see `level2/AGENTS.md`) |
| `wall_textures/` | Processed wall textures for in-game use (see `wall_textures/AGENTS.md`) |

## For AI Agents

### Working In This Directory

**Sprite Specifications**:
- All warrior sprites normalized to **~517px height** for consistent scaling
- All knight sprites normalized to **~579px height**
- Format: PNG with transparency
- Color: RGB565 compatible (auto-converted by SDK)

**Ground Positioning**:
- Sprites positioned: `drawY = groundY - scaledHeight`
- Feet should be on ground, not eye-level positioning
- Consistent across all character sprites

**Animation Handling**:
- Check `animFrame ~= nil` (not `animFrame > 0` since frame 0 is valid)
- Frame counting depends on animation speed
- Use consistent frame timing for smooth animations

### Common Patterns

**Loading Sprites**:
```lua
local warrior_front = vmupro.sprite.new("sprites/warrior_front")
-- SDK automatically adds .png extension
```

**Drawing Sprites**:
```lua
-- Ground-based positioning
local scale = 0.5
local sprite_height = 517
local drawY = ground_y - (sprite_height * scale)
vmupro.sprite.drawScaled(warrior_front, x, drawY, scale, scale, 0)
```

**Animation State Check**:
```lua
if animFrame ~= nil then
    -- Animation is active
    current_frame = math.floor(frameCount / 4) % frame_count
else
    -- Use idle sprite
end
```

### Sprite Processing Pipeline

1. **Generate**: Use AI tools (see `../SPRITE_PIPELINE.md`) to create base sprites
2. **Normalize**: Scale all sprites to consistent heights (warrior: 517px, knight: 579px)
3. **Split**: Use `split_spritesheet.py` or `split_warrior_actions.py` for spritesheets
4. **Organize**: Place in level-specific directories (`level1/`, `level2/`)
5. **Test**: Load in-game and verify scaling/positioning

### Testing Requirements

- Verify all sprites have transparent backgrounds
- Check sprite heights are normalized correctly
- Test scaling at various distances
- Verify no artifacts or anti-aliasing issues
- Confirm all animation frames load correctly

### Known Issues

- **Invisible Soldier Bug**: One soldier may appear invisible (likely walking sprite not loading)
- **Knights**: Removed from game due to incomplete sprite set

## Dependencies

### Internal
- `../app.lua` - Main game code that loads and renders sprites
- `../generate_sprites.py` - Sprite generation script
- `../split_*.py` - Sprite processing scripts

### External
- VMU Pro SDK sprite system (`vmupro.sprite.*`)
- PIL/Pillow (Python image processing)

<!-- MANUAL: Sprite specifications and notes can be added below -->
