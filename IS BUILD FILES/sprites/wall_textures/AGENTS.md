<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# wall_textures

## Purpose
Processed wall texture files ready for use in the 3D raycaster engine. These textures are mapped onto wall surfaces during rendering.

## For AI Agents

### Working In This Directory

**These are production-ready game assets** - wall textures loaded and rendered by the raycaster engine.

**Usage in Game**:
Textures are loaded via VMU Pro SDK:
```lua
-- Textures embedded in game package
local texture = vmupro.sprite.new("sprites/wall_textures/stone_wall_1")
```

**Raycaster Texture Mapping**:
- Textures mapped based on wall type and orientation
- Scaled based on ray distance (perspective correction)
- Color may be adjusted for lighting/depth effects

### Wall Texture Categories

**Stone Walls**:
- Light stone (COLOR_STONE_L: 0x8C73)
- Dark stone (COLOR_STONE_D: 0x4A52)
- Used for: Standard dungeon walls

**Brick Walls**:
- Light brick (COLOR_BRICK_L: 0x4062)
- Dark brick (COLOR_BRICK_D: 0x0041)
- Used for: Brick passages, fortified areas

**Moss Walls**:
- Light moss (COLOR_MOSS_L: 0x4444)
- Dark moss (COLOR_MOSS_D: 0x2222)
- Used for: Aged, dungeon-like areas

**Metal Walls**:
- Light metal (COLOR_METAL_L: 0x1084)
- Dark metal (COLOR_METAL_D: 0x0842)
- Used for: Special chambers, armories

**Wood Walls**:
- Light wood (COLOR_WOOD_L: 0x4051)
- Dark wood (COLOR_WOOD_D: 0x2028)
- Used for: Doors, wooden structures, interior rooms

### Color Constants (RGB565)

From `../../app.lua`:
```lua
COLOR_STONE_L = 0x8C73
COLOR_STONE_D = 0x4A52
COLOR_BRICK_L = 0x4062
COLOR_BRICK_D = 0x0041
COLOR_MOSS_L = 0x4444
COLOR_MOSS_D = 0x2222
COLOR_METAL_L = 0x1084
COLOR_METAL_D = 0x0842
COLOR_WOOD_L = 0x4051
COLOR_WOOD_D = 0x2028
```

### Texture Mapping in Raycaster

**Perpendicular Distance Correction**:
```lua
-- Fix fisheye effect
local perp_wall_dist = ray_dist * math.cos(ray_angle - player_angle)
local wall_height = math.floor(screen_height / perp_wall_dist)
```

**Texture Column Selection**:
```lua
-- Determine which column of texture to draw
local tex_x = math.floor(texture_width * wall_x) % texture_width
```

**Drawing Textured Walls**:
```lua
-- For each vertical strip
vmupro.sprite.drawScaled(texture,
    screen_x,
    wall_top,
    1,
    wall_height,
    0)
```

### Common Patterns

**Wall Type Selection** (from map data):
```lua
if wall_type == 1 then
    -- Stone wall
    texture = stone_texture
elseif wall_type == 2 then
    -- Brick wall
    texture = brick_texture
-- ... etc
end
```

### Testing Requirements

- Verify textures render without distortion
- Check perspective correction at various angles
- Confirm lighting effects look correct
- Test all wall types in-game
- Ensure no texture seams or artifacts

## Dependencies

### Internal
- `../../app.lua` - Raycaster engine using these textures
- `../Walls.png` - Source textures spritesheet
- `../_wall_textures/` - Raw extracted files (if processing)

### External
- VMU Pro SDK sprite system

<!-- MANUAL: Texture mapping notes can be added below -->
