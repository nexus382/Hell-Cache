<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-23 -->

# Level 2 Sprites

Sprite assets for Level 2 gameplay, featuring the Warrior character class and associated combat equipment.

## File Inventory

**Total Files:** 41 PNG sprites

---

## By Category

### Warrior Class - Idle/Standing Sprites

| File | Description |
|------|-------------|
| `warrior_front.png` | Warrior facing forward (south) |
| `warrior_back.png` | Warrior facing backward (north) |
| `warrior_left.png` | Warrior facing left (west) |
| `warrior_right.png` | Warrior facing right (east) |

### Warrior Class - Walk Animation (4 directions, 3 frames each)

**Cardinal Walk Cycles:**

| Frame | Down | Up | Left | Right |
|-------|------|-----|------|-------|
| 1 | `warrior_walk1.png` | `warrior_walk1_back.png` | `warrior_walk1_front.png` | `warrior_walk1_r.png` |
| 2 | `warrior_walk2.png` | `warrior_walk2_back.png` | `warrior_walk2_front.png` | `warrior_walk2_r.png` |
| 3 | `warrior_walk3.png` | `warrior_walk3_back.png` | `warrior_walk3_front.png` | `warrior_walk3_r.png` |

**Note:** File naming appears inconsistent - `*_front.png` suffix is used for left-facing frames and `*_r.png` for right-facing frames. Verify orientation in game context.

### Warrior Class - Attack Animation (4 directions, 2 frames each)

| Direction | Frame 1 | Frame 2 |
|-----------|---------|---------|
| Back (north) | `warrior_attack_back1.png` | `warrior_attack_back2.png` |
| Front (south) | `warrior_attack_front1.png` | `warrior_attack_front2.png` |
| Left (west) | `warrior_attack_left1.png` | `warrior_attack_left2.png` |
| Right (east) | `warrior_attack_right1.png` | `warrior_attack_right2.png` |

### Warrior Class - Death Animation (7 frames)

| Frame | File |
|-------|------|
| 1 | `warrior_death1.png` |
| 2 | `warrior_death2.png` |
| 3 | `warrior_death3.png` |
| 4 | `warrior_death4.png` |
| 5 | `warrior_death5.png` |
| 6 | `warrior_death6.png` |
| 7 | `warrior_death7.png` |

### Sword Attack Effect (9 frames)

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

### Items/Collectibles

| File | Description |
|------|-------------|
| `potion.png` | Health/mana potion pickup item |

---

## Animation Frame Counts Summary

| Animation | Frames | Directions |
|-----------|--------|------------|
| Idle | 1 | 4 |
| Walk | 3 | 4 |
| Attack (Warrior) | 2 | 4 |
| Death | 7 | 1 (omnidirectional) |
| Sword Effect | 9 | 1 (overlay) |

---

## Naming Convention

```
{character}_{action}{frame}_{direction}.png
```

- **character**: `warrior`
- **action**: `walk`, `attack`, `death`
- **frame**: `1`, `2`, `3`, etc.
- **direction** (optional): `back`, `front`, `left`, `right`, `r`

---

## Usage Notes

1. Walk animations use 3-frame cycles for smooth movement
2. Attack animations are 2-frame quick strikes per direction
3. Death animation is a 7-frame sequence (single direction)
4. Sword attack overlay is a 9-frame slash effect
5. Directional sprites follow a 4-direction system (N/S/E/W)
