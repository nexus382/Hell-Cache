# Soldier Sprite Animation Pipeline

## Current Inventory

### What We Have
| Sprite | Direction | State | Notes |
|--------|-----------|-------|-------|
| warrior_front.png | Front | Idle | OK |
| warrior_back.png | Back | Idle | OK |
| warrior_left.png | Left | Idle | OK |
| warrior_right.png | Right | Idle | OK |
| warrior_walk1.png | Left | Walk Frame 1 | OK |
| warrior_walk2.png | Left | Walk Frame 2 | OK |
| warrior_walk3.png | Left | Walk Frame 3 | OK |
| warrior_walk1_r.png | Right | Walk Frame 1 | OK (flipped) |
| warrior_walk2_r.png | Right | Walk Frame 2 | OK (flipped) |
| warrior_walk3_r.png | Right | Walk Frame 3 | OK (flipped) |
| warrior_walk1_front.png | Front | Walk Frame 1 | OK |
| warrior_walk2_front.png | Front | Walk Frame 2 | OK |
| warrior_walk3_front.png | Front | Walk Frame 3 | OK |
| warrior_walk1_back.png | Back | Walk Frame 1 | OK |
| warrior_walk2_back.png | Back | Walk Frame 2 | OK |
| warrior_walk3_back.png | Back | Walk Frame 3 | OK |
| warrior_attack_front1.png | Front | Attack Frame 1 | OK |
| warrior_attack_front2.png | Front | Attack Frame 2 | OK |
| warrior_attack_back1.png | Back | Attack Frame 1 | OK |
| warrior_attack_back2.png | Back | Attack Frame 2 | OK |
| warrior_attack_left1.png | Left | Attack Frame 1 | OK |
| warrior_attack_left2.png | Left | Attack Frame 2 | OK |
| warrior_attack_right1.png | Right | Attack Frame 1 | OK |
| warrior_attack_right2.png | Right | Attack Frame 2 | OK |
| warrior_death1.png | All | Death Frame 1 | OK |
| warrior_death2.png | All | Death Frame 2 | OK |
| warrior_death3.png | All | Death Frame 3 | OK |
| warrior_death4.png | All | Death Frame 4 | OK |
| warrior_death5.png | All | Death Frame 5 | OK |
| warrior_death6.png | All | Death Frame 6 | OK |
| warrior_death7.png | All | Death Frame 7 | OK |

### What Is Still Missing

- Hurt animations (optional): front/back/left/right

---

## Summary: Sprites Needed

| Category | Count | Priority |
|----------|-------|----------|
| Walk (Front/Back) | 6 | DONE |
| Attack (All dirs) | 8 | DONE |
| Death (All dirs) | 7 | DONE |
| Hurt (All dirs) | 4 | LOW |
| TOTAL | 25 | |

---

## Sprite Sheet Mapping (SPRITE_GUYS.png)

- Front attack: Row 1, frames 5-6
- Left attack: Row 3, frames 5-6
- Back attack: Row 5, frames 5-6
- Right attack: Row 7, frames 5-6
- Death frames: Row 10 (7 frames)
- Walk frames:
  - Front: Row 1, frames 2-4
  - Left: Row 3, frames 2-4
  - Back: Row 5, frames 2-4
  - Right: Row 7, frames 2-4

## Player Sword Attack (FighterWeapons.png)

- Use Row 9, frames 1-9
- Remove the label frame on the right
- Drop the first 2 frames if needed for timing

---

## Tips for Sprite Extraction

1. Remove the teal background and keep alpha transparency.
2. Keep all frames aligned to the same bottom baseline.
3. Normalize warrior height around 517px for consistent scaling.
4. Keep file names consistent between level1 and level2 asset folders.
