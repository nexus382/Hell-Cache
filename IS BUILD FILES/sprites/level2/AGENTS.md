# Level 2 Sprites Directory

<!-- Parent: ../AGENTS.md -->

**Purpose:** Contains sprite assets for Level 2 character (Warrior class) and associated game objects.

**Last Updated:** 2026-02-23

**Total Files:** 42 PNG images

---

## Directory Structure

```
level2/
  |-- warrior sprites (36 files)
  |-- sword attack effect (9 files)
  |-- items (1 file)
```

---

## Animation Categories

### 1. Idle Sprites (Static)

| File | Description | Direction |
|------|-------------|-----------|
| `warrior_front.png` | Warrior idle stance | Front (South) |
| `warrior_back.png` | Warrior idle stance | Back (North) |
| `warrior_left.png` | Warrior idle stance | Left (West) |
| `warrior_right.png` | Warrior idle stance | Right (East) |

### 2. Walk Animation (4 directions x 3 frames = 12 files)

**Front Direction:**
| Frame | File |
|-------|------|
| 1 | `warrior_walk1_front.png` |
| 2 | `warrior_walk2_front.png` |
| 3 | `warrior_walk3_front.png` |

**Back Direction:**
| Frame | File |
|-------|------|
| 1 | `warrior_walk1_back.png` |
| 2 | `warrior_walk2_back.png` |
| 3 | `warrior_walk3_back.png` |

**Right Direction:**
| Frame | File |
|-------|------|
| 1 | `warrior_walk1_r.png` |
| 2 | `warrior_walk2_r.png` |
| 3 | `warrior_walk3_r.png` |

**Left Direction (legacy naming):**
| Frame | File |
|-------|------|
| 1 | `warrior_walk1.png` |
| 2 | `warrior_walk2.png` |
| 3 | `warrior_walk3.png` |

### 3. Attack Animation (4 directions x 2 frames = 8 files)

**Front Direction:**
| Frame | File |
|-------|------|
| 1 | `warrior_attack_front1.png` |
| 2 | `warrior_attack_front2.png` |

**Back Direction:**
| Frame | File |
|-------|------|
| 1 | `warrior_attack_back1.png` |
| 2 | `warrior_attack_back2.png` |

**Left Direction:**
| Frame | File |
|-------|------|
| 1 | `warrior_attack_left1.png` |
| 2 | `warrior_attack_left2.png` |

**Right Direction:**
| Frame | File |
|-------|------|
| 1 | `warrior_attack_right1.png` |
| 2 | `warrior_attack_right2.png` |

### 4. Death Animation (7 frames)

| Frame | File |
|-------|------|
| 1 | `warrior_death1.png` |
| 2 | `warrior_death2.png` |
| 3 | `warrior_death3.png` |
| 4 | `warrior_death4.png` |
| 5 | `warrior_death5.png` |
| 6 | `warrior_death6.png` |
| 7 | `warrior_death7.png` |

### 5. Sword Attack Effect (9 frames)

| Frame | File |
|-------|------|
| 1 | `sword_attack1.png` |
| 2 | `sword_attack2.png` |
| 3 | `sword_attack3.png` |
| 4 | `sword_attack4.png` |
| 5 | `sword_attack5.png` |
| 6 | `sword_attack6.png` |
| 7 | `sword_attack7.png` |
| 8 | `sword_attack8.png` |
| 9 | `sword_attack9.png` |

### 6. Items (1 file)

| File | Description |
|------|-------------|
| `potion.png` | Health/mana pickup item |

---

## Naming Conventions

| Pattern | Example | Meaning |
|---------|---------|---------|
| `{entity}_{direction}.png` | `warrior_front.png` | Static idle sprite |
| `{entity}_walk{N}_{direction}.png` | `warrior_walk2_back.png` | Walk animation frame N |
| `{entity}_attack_{direction}{N}.png` | `warrior_attack_left1.png` | Attack animation frame N |
| `{entity}_death{N}.png` | `warrior_death3.png` | Death animation frame N |
| `{weapon}_attack{N}.png` | `sword_attack5.png` | Weapon effect frame N |

---

## Technical Notes

1. **Legacy Naming:** The walk animation for the left direction uses `warrior_walk{N}.png` without the `_left` suffix. This is inconsistent with other directions.

2. **Frame Counts:**
   - Walk: 3 frames per direction
   - Attack: 2 frames per direction
   - Death: 7 frames total (no directional variants)

3. **Direction Suffixes:**
   - `_front` = South (facing camera)
   - `_back` = North (facing away)
   - `_left` = West
   - `_r` = Right/East (abbreviated)

4. **Usage Pattern:** These sprites are designed for 4-directional movement games with attack and death sequences.

---

## Integration Guide

To use these sprites in a game engine:

```lua
-- Example animation setup (LÖVE2D / similar)
local walk_frames = {
    front = {"warrior_walk1_front.png", "warrior_walk2_front.png", "warrior_walk3_front.png"},
    back = {"warrior_walk1_back.png", "warrior_walk2_back.png", "warrior_walk3_back.png"},
    right = {"warrior_walk1_r.png", "warrior_walk2_r.png", "warrior_walk3_r.png"},
    left = {"warrior_walk1.png", "warrior_walk2.png", "warrior_walk3.png"}
}

local death_frames = {"warrior_death1.png", "warrior_death2.png", "warrior_death3.png",
                      "warrior_death4.png", "warrior_death5.png", "warrior_death6.png",
                      "warrior_death7.png"}
```

---

## Related Directories

- `../level1/` - Level 1 character sprites
- `../level3/` - Level 3 character sprites
- `../enemies/` - Enemy sprite assets
- `../ui/` - UI element sprites
