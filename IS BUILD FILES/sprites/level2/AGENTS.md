<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# level2

## Purpose
Level 2 specific character sprites. Currently contains a subset of warrior idle poses. Additional sprites may be added as level 2 content is developed.

## Key Files

### Warrior Idle Sprites

| File | Description | Direction |
|------|-------------|-----------|
| `warrior_back.png` | Back-facing idle pose | Back |
| `warrior_front.png` | Front-facing idle pose | Front |
| `warrior_left.png` | Left-facing idle pose | Left |
| `warrior_right.png` | Right-facing idle pose | Right |

### Warrior Walking Animations

| File | Description | Direction | Frame |
|------|-------------|-----------|-------|
| `warrior_walk1.png` | Walk cycle - left foot forward | Left | 1 |
| `warrior_walk2.png` | Walk cycle - mid-stride | Left | 2 |

## For AI Agents

### Working In This Directory

**Current Status**: Level 2 has a minimal sprite set with only idle poses and 2 walking frames per direction.

**Missing Sprites**: This directory is incomplete compared to `../level1/`. Level 2 may need:
- Complete walking cycles (3+ frames per direction)
- Attack animations
- Death animations
- Level-specific enemy variants

**Usage in Game**:
```lua
-- Sprites loaded per level
local sprite_path = level == 2 and "sprites/level2/" or "sprites/level1/"
local warrior_front = vmupro.sprite.new(sprite_path .. "warrior_front")
```

### Sprite Specifications

Same as Level 1:
- Format: PNG with transparency
- Height: ~517px (normalized)
- Style: Red/crimson medieval plate armor
- Lighting: Top-left consistent

### Level Differentiation

**Potential differences from Level 1**:
- Different color schemes (e.g., blue armor, green variants)
- Enhanced enemy types (more HP, faster)
- Different weapon appearances
- Level-specific visual effects

**Current Implementation**: Level 2 uses the same sprite style as Level 1 (red armor warriors).

### Common Patterns

**Level-Specific Sprite Loading**:
```lua
local function loadWarriorSprites(level)
    local level_dir = "sprites/level" .. level .. "/"

    return {
        front = vmupro.sprite.new(level_dir .. "warrior_front"),
        back = vmupro.sprite.new(level_dir .. "warrior_back"),
        left = vmupro.sprite.new(level_dir .. "warrior_left"),
        right = vmupro.sprite.new(level_dir .. "warrior_right")
    }
end
```

### Testing Requirements

- Verify sprites load correctly for level 2
- Check consistency with level 1 sprite proportions
- Test scaling and positioning
- Confirm no visual differences unless intentional

## Dependencies

### Internal
- `../../app.lua` - Main game code
- `../level1/` - Reference for complete sprite set
- `../../tools/split_warrior_actions.py` - Processing tool

### External
- VMU Pro SDK sprite system

<!-- MANUAL: Level 2-specific notes can be added below -->
