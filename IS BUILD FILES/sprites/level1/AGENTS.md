<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# level1

## Purpose
Level 1 specific character sprites including warrior idle poses, walking animations, attack sequences, death animations, and weapon effects.

## Key Files

### Warrior Idle Sprites

| File | Description | Direction |
|------|-------------|-----------|
| `warrior_front.png` | Front-facing idle pose | Front |
| `warrior_back.png` | Back-facing idle pose | Back |
| `warrior_left.png` | Left-facing idle pose | Left |
| `warrior_right.png` | Right-facing idle pose | Right |

### Warrior Walking Animations

| File | Description | Direction | Frame |
|------|-------------|-----------|-------|
| `warrior_walk1.png` | Walk cycle - left foot forward | Left | 1 |
| `warrior_walk2.png` | Walk cycle - mid-stride | Left | 2 |
| `warrior_walk3.png` | Walk cycle - right foot forward | Left | 3 |
| `warrior_walk4.png` | Walk cycle - alternate pose | Side | 4 |
| `warrior_walk5.png` | Walk cycle - alternate pose | Side | 5 |
| `warrior_walk1_r.png` | Walk cycle - mirrored | Right | 1 |
| `warrior_walk2_r.png` | Walk cycle - mirrored | Right | 2 |
| `warrior_walk3_r.png` | Walk cycle - mirrored | Right | 3 |
| `warrior_walk4_r.png` | Walk cycle - mirrored | Right | 4 |
| `warrior_walk5_r.png` | Walk cycle - mirrored | Right | 5 |
| `warrior_walk1_front.png` | Walk cycle - front view | Front | 1 |
| `warrior_walk2_front.png` | Walk cycle - front view | Front | 2 |
| `warrior_walk1_back.png` | Walk cycle - back view | Back | 1 |
| `warrior_walk2_back.png` | Walk cycle - back view | Back | 2 |

### Warrior Attack Animations

| File | Description | Direction | Frame |
|------|-------------|-----------|-------|
| `warrior_attack_front1.png` | Attack wind-up | Front | 1 |
| `warrior_attack_front2.png` | Attack swing | Front | 2 |
| `warrior_attack_back1.png` | Attack wind-up | Back | 1 |
| `warrior_attack_back2.png` | Attack swing | Back | 2 |
| `warrior_attack_left1.png` | Attack wind-up | Left | 1 |
| `warrior_attack_left2.png` | Attack swing | Left | 2 |
| `warrior_attack_right1.png` | Attack wind-up | Right | 1 |
| `warrior_attack_right2.png` | Attack swing | Right | 2 |

### Warrior Death Animations

| File | Description | Frame |
|------|-------------|-------|
| `warrior_death1.png` | Death - start recoil | 1 |
| `warrior_death2.png` | Death - falling | 2 |
| `warrior_death3.png` | Death - collapsed | 3 |
| `warrior_death4.png` | Death - alternate | 4 |
| `warrior_death5.png` | Death - alternate | 5 |
| `warrior_death6.png` | Death - alternate | 6 |
| `warrior_death7.png` | Death - final | 7 |

### Warrior Idle Standing

| File | Description |
|------|-------------|
| `warrior_stand1.png` | Standing idle frame 1 |
| `warrior_stand2.png` | Standing idle frame 2 |

### Weapon Effects

| File | Description |
|------|-------------|
| `sword_attack1.png` | Sword swing effect - frame 1 |
| `sword_attack2.png` | Sword swing effect - frame 2 |
| `sword_attack3.png` | Sword swing effect - frame 3 |
| `sword_attack4.png` | Sword swing effect - frame 4 |
| `sword_attack5.png` | Sword swing effect - frame 5 |
| `sword_attack6.png` | Sword swing effect - frame 6 |
| `sword_attack7.png` | Sword swing effect - frame 7 |
| `sword_attack8.png` | Sword swing effect - frame 8 |
| `sword_attack9.png` | Sword swing effect - frame 9 |

### UI Element

| File | Description |
|------|-------------|
| `potion.png` | Health potion/vial for UI |

## For AI Agents

### Working In This Directory

**Sprite Specifications**:
- All sprites: PNG format with transparency
- Normalized height: ~517px (for consistent scaling)
- Style: Medieval fantasy, red/crimson plate armor
- Lighting: Consistent top-left light source

**Usage in Game**:
- Sprites loaded via `vmupro.sprite.new("sprites/level1/warrior_front")`
- Note: SDK appends `.png` automatically
- Use scaled drawing: `vmupro.sprite.drawScaled(sprite, x, y, scale_x, scale_y, flags)`

### Animation Frame Sequences

**Walking** (side view, 5 frames):
1. `warrior_walk1.png` - Left foot forward
2. `warrior_walk2.png` - Mid-stride
3. `warrior_walk3.png` - Right foot forward
4. `warrior_walk4.png` - Transition
5. `warrior_walk5.png` - Transition

**Attack** (3-frame sequence):
1. `*_attack_*1.png` - Wind-up (sword raised)
2. `*_attack_*2.png` - Swing (sword extended)
3. [Optional] `*_attack_*3.png` - Follow-through

**Death** (7-frame sequence):
1. `warrior_death1.png` - Recoil
2. `warrior_death2.png` - Begin falling
3. `warrior_death3.png` - Mid-fall
4. `warrior_death4.png` - Continue
5. `warrior_death5.png` - Near ground
6. `warrior_death6.png` - Almost down
7. `warrior_death7.png` - Fully collapsed

### Common Patterns

**Walking Animation Check**:
```lua
-- From app.lua - check animation is active
if animFrame ~= nil then
    -- Use walking sprites
    frame_index = (animFrame % 5) + 1  -- 5 walking frames
else
    -- Use idle sprite
    vmupro.sprite.draw(warrior_front, x, y, 0)
end
```

**Direction-Based Sprite Selection**:
```lua
local function getWarriorSprite(direction, frame)
    local prefix = "sprites/level1/warrior_"
    local suffix = ""

    if direction == "front" then
        suffix = "front"
    elseif direction == "back" then
        suffix = "back"
    elseif direction == "left" then
        suffix = "left"
    elseif direction == "right" then
        suffix = "right"
    end

    if frame ~= nil then
        return prefix .. "walk" .. frame .. "_" .. suffix
    else
        return prefix .. suffix
    end
end
```

### Missing Sprites

According to `../../SPRITE_PIPELINE.md`, the following sprites are still needed:

**Front/Back Walking**:
- `warrior_walk_front3.png` (Frame 3 - needed for complete cycle)
- `warrior_walk_back3.png` (Frame 3 - needed for complete cycle)

**Attack Animations**:
- Front attack frame 3 (follow-through)
- Back attack frame 3 (follow-through)
- Left attack frame 3 (follow-through)
- Right attack frame 3 (follow-through)

**Current Status**: Front/back walking has only 2 frames each. Side walking has complete 5-frame cycle plus mirrored versions.

### Testing Requirements

- Verify all sprites load without errors
- Check walking animation cycles smoothly
- Test attack frame timing
- Verify death animation plays completely
- Confirm scaling works at various distances
- Check for any visual artifacts or transparency issues

## Dependencies

### Internal
- `../../app.lua` - Main game code using these sprites
- `../../SPRITE_PIPELINE.md` - Sprite generation documentation
- `../../tools/split_warrior_actions.py` - Sprite processing tool

### External
- VMU Pro SDK sprite system

<!-- MANUAL: Level 1 sprite-specific notes can be added below -->
