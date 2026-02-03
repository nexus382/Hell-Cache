# Soldier Sprite Animation Pipeline

## Current Inventory

### What We Have
| Sprite | Direction | State | Notes |
|--------|-----------|-------|-------|
| warrior_front.png | Front | Idle | ✅ Complete |
| warrior_back.png | Back | Idle | ✅ Complete |
| warrior_left.png | Left | Idle | ✅ Complete |
| warrior_right.png | Right | Idle | ✅ Complete |
| warrior_walk1.png | Left | Walk Frame 1 | ✅ Complete |
| warrior_walk2.png | Left | Walk Frame 2 | ✅ Complete |
| warrior_walk3.png | Left | Walk Frame 3 | ✅ Complete |
| warrior_walk1_r.png | Right | Walk Frame 1 | ✅ Complete |
| warrior_walk2_r.png | Right | Walk Frame 2 | ✅ Complete |
| warrior_walk3_r.png | Right | Walk Frame 3 | ✅ Complete |

### What's Missing

#### Walking Animations (Front/Back)
| ID | Sprite Needed | Direction | State |
|----|---------------|-----------|-------|
| W01 | warrior_walk_front1.png | Front | Walk Frame 1 |
| W02 | warrior_walk_front2.png | Front | Walk Frame 2 |
| W03 | warrior_walk_front3.png | Front | Walk Frame 3 |
| W04 | warrior_walk_back1.png | Back | Walk Frame 1 |
| W05 | warrior_walk_back2.png | Back | Walk Frame 2 |
| W06 | warrior_walk_back3.png | Back | Walk Frame 3 |

#### Attack Animations (All 4 Directions)
| ID | Sprite Needed | Direction | State |
|----|---------------|-----------|-------|
| A01 | warrior_attack_front1.png | Front | Attack Wind-up |
| A02 | warrior_attack_front2.png | Front | Attack Swing |
| A03 | warrior_attack_front3.png | Front | Attack Follow-through |
| A04 | warrior_attack_back1.png | Back | Attack Wind-up |
| A05 | warrior_attack_back2.png | Back | Attack Swing |
| A06 | warrior_attack_back3.png | Back | Attack Follow-through |
| A07 | warrior_attack_left1.png | Left | Attack Wind-up |
| A08 | warrior_attack_left2.png | Left | Attack Swing |
| A09 | warrior_attack_left3.png | Left | Attack Follow-through |
| A10 | warrior_attack_right1.png | Right | Attack Wind-up |
| A11 | warrior_attack_right2.png | Right | Attack Swing |
| A12 | warrior_attack_right3.png | Right | Attack Follow-through |

#### Death Animations (All 4 Directions)
| ID | Sprite Needed | Direction | State |
|----|---------------|-----------|-------|
| D01 | warrior_death_front1.png | Front | Death Start |
| D02 | warrior_death_front2.png | Front | Death Mid |
| D03 | warrior_death_front3.png | Front | Death Final |
| D04 | warrior_death_back1.png | Back | Death Start |
| D05 | warrior_death_back2.png | Back | Death Mid |
| D06 | warrior_death_back3.png | Back | Death Final |
| D07 | warrior_death_left1.png | Left | Death Start |
| D08 | warrior_death_left2.png | Left | Death Mid |
| D09 | warrior_death_left3.png | Left | Death Final |
| D10 | warrior_death_right1.png | Right | Death Start |
| D11 | warrior_death_right2.png | Right | Death Mid |
| D12 | warrior_death_right3.png | Right | Death Final |

#### Hit/Hurt Animations (All 4 Directions) - Optional but nice
| ID | Sprite Needed | Direction | State |
|----|---------------|-----------|-------|
| H01 | warrior_hurt_front.png | Front | Taking Damage |
| H02 | warrior_hurt_back.png | Back | Taking Damage |
| H03 | warrior_hurt_left.png | Left | Taking Damage |
| H04 | warrior_hurt_right.png | Right | Taking Damage |

---

## Summary: Sprites Needed

| Category | Count | Priority |
|----------|-------|----------|
| Walk (Front/Back) | 6 | HIGH |
| Attack (All dirs) | 12 | HIGH |
| Death (All dirs) | 12 | MEDIUM |
| Hurt (All dirs) | 4 | LOW |
| **TOTAL** | **34** | |

---

## AI Sprite Generation Pipeline (Using Gemini)

### Step 1: Reference Image
Use existing warrior_front.png as the style reference. Key characteristics:
- Red/crimson armor
- Medieval soldier style
- Consistent proportions (~517px height)
- Transparent background
- Clean silhouette

### Step 2: Prompt Template for Gemini

```
Create a pixel art sprite of a medieval soldier in red/crimson armor.

CHARACTER DETAILS:
- Same character as reference image
- Red/crimson plate armor
- Medieval fantasy soldier
- Proportions: approximately 517 pixels tall

POSE: [SPECIFIC POSE - see below]
DIRECTION: [Front/Back/Left/Right - facing camera]

TECHNICAL REQUIREMENTS:
- Transparent background (PNG)
- Clean edges, no anti-aliasing artifacts
- Consistent lighting (light from top-left)
- Style must match reference exactly
- Full body visible, feet to head

[Attach reference: warrior_front.png]
```

### Step 3: Pose Descriptions for Each Frame

#### WALK POSES:
- **Walk Frame 1**: Left leg forward, right arm forward, mid-stride
- **Walk Frame 2**: Legs together, neutral stance, transitioning
- **Walk Frame 3**: Right leg forward, left arm forward, mid-stride

#### ATTACK POSES:
- **Attack Wind-up (Frame 1)**: Sword raised behind/above head, preparing to strike
- **Attack Swing (Frame 2)**: Sword mid-swing, arm extended diagonally
- **Attack Follow-through (Frame 3)**: Sword low after swing, body rotated

#### DEATH POSES:
- **Death Start (Frame 1)**: Recoiling, hand to chest, sword dropping
- **Death Mid (Frame 2)**: Falling backward/sideways, knees buckling
- **Death Final (Frame 3)**: Collapsed on ground, motionless

#### HURT POSE:
- **Taking Damage**: Flinching, head turned, body recoiling slightly

### Step 4: Post-Processing Checklist
After receiving AI-generated sprite:
1. [ ] Remove any background artifacts
2. [ ] Verify transparent background
3. [ ] Scale to 517px height (maintain aspect ratio)
4. [ ] Check alignment with existing sprites
5. [ ] Save as PNG with transparency
6. [ ] Test in-game

---

## Sprite Map Reference

```
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|   FRONT IDLE     |   BACK IDLE      |   LEFT IDLE      |   RIGHT IDLE     |
|   ✅ DONE        |   ✅ DONE        |   ✅ DONE        |   ✅ DONE        |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|   FRONT WALK 1   |   FRONT WALK 2   |   FRONT WALK 3   |                  |
|   ❌ W01         |   ❌ W02         |   ❌ W03         |                  |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|   BACK WALK 1    |   BACK WALK 2    |   BACK WALK 3    |                  |
|   ❌ W04         |   ❌ W05         |   ❌ W06         |                  |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|   LEFT WALK 1    |   LEFT WALK 2    |   LEFT WALK 3    |                  |
|   ✅ DONE        |   ✅ DONE        |   ✅ DONE        |                  |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|   RIGHT WALK 1   |   RIGHT WALK 2   |   RIGHT WALK 3   |                  |
|   ✅ DONE        |   ✅ DONE        |   ✅ DONE        |                  |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|  FRONT ATTACK 1  |  FRONT ATTACK 2  |  FRONT ATTACK 3  |                  |
|   ❌ A01         |   ❌ A02         |   ❌ A03         |                  |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|  BACK ATTACK 1   |  BACK ATTACK 2   |  BACK ATTACK 3   |                  |
|   ❌ A04         |   ❌ A05         |   ❌ A06         |                  |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|  LEFT ATTACK 1   |  LEFT ATTACK 2   |  LEFT ATTACK 3   |                  |
|   ❌ A07         |   ❌ A08         |   ❌ A09         |                  |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|  RIGHT ATTACK 1  |  RIGHT ATTACK 2  |  RIGHT ATTACK 3  |                  |
|   ❌ A10         |   ❌ A11         |   ❌ A12         |                  |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|  FRONT DEATH 1   |  FRONT DEATH 2   |  FRONT DEATH 3   |                  |
|   ❌ D01         |   ❌ D02         |   ❌ D03         |                  |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|  BACK DEATH 1    |  BACK DEATH 2    |  BACK DEATH 3    |                  |
|   ❌ D04         |   ❌ D05         |   ❌ D06         |                  |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|  LEFT DEATH 1    |  LEFT DEATH 2    |  LEFT DEATH 3    |                  |
|   ❌ D07         |   ❌ D08         |   ❌ D09         |                  |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|  RIGHT DEATH 1   |  RIGHT DEATH 2   |  RIGHT DEATH 3   |                  |
|   ❌ D10         |   ❌ D11         |   ❌ D12         |                  |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
|                  |                  |                  |                  |
|   FRONT HURT     |   BACK HURT      |   LEFT HURT      |   RIGHT HURT     |
|   ❌ H01         |   ❌ H02         |   ❌ H03         |   ❌ H04         |
|                  |                  |                  |                  |
+------------------+------------------+------------------+------------------+
```

---

## Priority Order for Generation

### Phase 1: Core Animations (HIGH PRIORITY)
1. W01-W03: Front walking (enables full patrol visibility)
2. W04-W06: Back walking
3. A07-A09: Left attack (most visible during combat)
4. A10-A12: Right attack

### Phase 2: Full Attack Set (HIGH PRIORITY)
5. A01-A03: Front attack
6. A04-A06: Back attack

### Phase 3: Death Animations (MEDIUM PRIORITY)
7. D07-D09: Left death
8. D10-D12: Right death
9. D01-D03: Front death
10. D04-D06: Back death

### Phase 4: Polish (LOW PRIORITY)
11. H01-H04: Hurt animations

---

## Tips for Gemini Prompts

1. **Be specific about direction**: "facing directly toward the camera" vs "profile view facing left"

2. **Describe the action clearly**: Instead of "attacking", say "sword raised above right shoulder, about to swing downward diagonally"

3. **Reference existing sprite**: Always attach warrior_front.png and say "match this character's armor style, colors, and proportions exactly"

4. **Request transparency**: "PNG with fully transparent background, no ground shadow"

5. **Specify dimensions**: "Output should be suitable for scaling to 517 pixels tall"

6. **Iterate**: If first result isn't right, refine the prompt rather than starting over
