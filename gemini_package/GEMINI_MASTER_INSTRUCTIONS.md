# Gemini Sprite Generation - Master Instructions

## PROJECT OVERVIEW

I'm creating a retro-style 3D dungeon crawler game and need help generating character sprite animations. I have an existing soldier character and need to create additional animation frames that match the existing art style exactly.

**CRITICAL**: Style consistency is paramount. Every new sprite must look like it belongs with the existing sprites.

---

## REFERENCE IMAGES INCLUDED

In the `references/` folder:
- `warrior_front.png` - **PRIMARY REFERENCE** - Front-facing idle pose
- `warrior_back.png` - Back-facing idle pose
- `warrior_left.png` - Left profile idle pose
- `warrior_right.png` - Right profile idle pose
- `warrior_walk1.png` - Walking frame 1 (left profile)
- `warrior_walk2.png` - Walking frame 2 (left profile)
- `warrior_walk3.png` - Walking frame 3 (left profile)

---

## CHARACTER DESCRIPTION

**The Soldier/Warrior:**
- Medieval fantasy soldier in full plate armor
- **Armor Color**: Deep crimson/blood red with darker red shadows
- **Helmet**: Full face helmet with vertical visor slit
- **Weapon**: Single-handed sword (straight blade, crossguard)
- **Build**: Sturdy, athletic warrior proportions
- **Height**: Sprites should be suitable for scaling to ~517 pixels tall
- **Style**: Clean digital art, slight stylization, NOT pixel art, NOT photorealistic

---

## TECHNICAL REQUIREMENTS FOR ALL SPRITES

1. **Transparent Background**: PNG format with fully transparent background (alpha channel)
2. **No Ground Shadows**: Character only, no cast shadows on ground
3. **Consistent Lighting**: Light source from upper-left (matching existing sprites)
4. **Clean Edges**: No fuzzy/anti-aliased edges bleeding into transparency
5. **Full Body**: Complete character from feet to top of head, nothing cropped
6. **Centered**: Character should be roughly centered in the frame
7. **Consistent Scale**: Match the proportions of the reference images exactly

---

## HOW TO USE THESE PROMPTS

For each sprite needed:
1. Start a new Gemini conversation (or continue existing)
2. Upload ALL reference images first
3. Copy the specific prompt for the sprite you need
4. If result doesn't match, use refinement prompts (see bottom)

---

## UNDERSTANDING DIRECTIONS

In this game, the camera can view the character from any angle:

- **FRONT**: Character facing toward the camera (you see their face/chest)
- **BACK**: Character facing away from camera (you see their back)
- **LEFT**: Character in profile, facing to YOUR left
- **RIGHT**: Character in profile, facing to YOUR right

---

# SPRITE PROMPTS

## PHASE 1: WALKING ANIMATIONS (Front & Back)

### W01: Front Walk Frame 1
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Walking toward the camera (front view)
- Left leg stepping forward, knee bent
- Right leg back, pushing off
- Right arm swinging forward naturally
- Left arm swinging back
- Slight forward lean of torso
- This is the first frame of a 3-frame walk cycle

REQUIREMENTS:
- Match the armor style, colors, and proportions EXACTLY from warrior_front.png
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### W02: Front Walk Frame 2
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Walking toward the camera (front view) - mid-stride
- Legs passing each other, nearly together
- Both feet close to ground (transition frame)
- Arms at sides, neutral position
- Body upright
- This is the second frame (middle) of a 3-frame walk cycle

REQUIREMENTS:
- Match the armor style, colors, and proportions EXACTLY from warrior_front.png
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### W03: Front Walk Frame 3
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Walking toward the camera (front view)
- Right leg stepping forward, knee bent
- Left leg back, pushing off
- Left arm swinging forward naturally
- Right arm swinging back
- Slight forward lean of torso
- This is the third frame of a 3-frame walk cycle (mirrors frame 1)

REQUIREMENTS:
- Match the armor style, colors, and proportions EXACTLY from warrior_front.png
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### W04: Back Walk Frame 1
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Walking away from camera (back view)
- Left leg stepping forward
- Right leg back
- Arms swinging naturally (opposite to legs)
- Slight forward lean
- We see the character's back, not face
- First frame of 3-frame walk cycle

REQUIREMENTS:
- Match the armor style from warrior_back.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### W05: Back Walk Frame 2
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Walking away from camera (back view) - mid-stride
- Legs passing each other, nearly together
- Arms at sides
- Body upright
- Transition frame
- We see the character's back

REQUIREMENTS:
- Match the armor style from warrior_back.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### W06: Back Walk Frame 3
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Walking away from camera (back view)
- Right leg stepping forward
- Left leg back
- Arms swinging naturally
- Mirrors frame 1
- We see the character's back

REQUIREMENTS:
- Match the armor style from warrior_back.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

---

## PHASE 2: ATTACK ANIMATIONS

### A01: Front Attack Frame 1 (Wind-up)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Preparing to attack, facing camera (front view)
- Sword raised up and back over right shoulder
- Both hands gripping sword handle
- Weight shifting to back foot
- Body coiled, ready to strike
- Intense, aggressive stance
- This is the wind-up before a powerful downward/diagonal slash

REQUIREMENTS:
- Match the armor style, colors, and proportions EXACTLY from warrior_front.png
- Sword should be clearly visible
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### A02: Front Attack Frame 2 (Swing)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Mid-swing attack, facing camera (front view)
- Sword in motion, diagonally across body (upper-right to lower-left)
- Arms extended
- Body rotating into the swing
- Weight transferring forward
- Dynamic action pose
- This is the peak action moment of the attack

REQUIREMENTS:
- Match the armor style, colors, and proportions EXACTLY from warrior_front.png
- Sword should show motion/action
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### A03: Front Attack Frame 3 (Follow-through)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Attack follow-through, facing camera (front view)
- Sword has completed swing, now low and to the left
- Arms extended downward
- Body has rotated, weight on front foot
- Recovering from swing
- This is the end of the attack motion

REQUIREMENTS:
- Match the armor style, colors, and proportions EXACTLY from warrior_front.png
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### A04: Back Attack Frame 1 (Wind-up)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Preparing to attack, facing away from camera (back view)
- Sword raised up and back over right shoulder
- We see the character's back
- Weight shifting to back foot
- Body coiled, ready to strike

REQUIREMENTS:
- Match the armor style from warrior_back.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### A05: Back Attack Frame 2 (Swing)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Mid-swing attack, facing away from camera (back view)
- Sword in motion across body
- Arms extended
- Body rotating
- We see the character's back
- Dynamic action pose

REQUIREMENTS:
- Match the armor style from warrior_back.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### A06: Back Attack Frame 3 (Follow-through)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Attack follow-through, facing away from camera (back view)
- Sword low after completing swing
- Arms extended downward
- Body has rotated
- We see the character's back

REQUIREMENTS:
- Match the armor style from warrior_back.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### A07: Left Attack Frame 1 (Wind-up)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Preparing to attack, left profile view (character facing your left)
- Sword raised behind/above head
- Body coiled
- Weight on back foot (right foot)
- We see the left side of the character

REQUIREMENTS:
- Match the armor style from warrior_left.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### A08: Left Attack Frame 2 (Swing)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Mid-swing attack, left profile view
- Sword swinging forward/downward
- Arms extending toward the left
- Body rotating into attack
- Dynamic action frame

REQUIREMENTS:
- Match the armor style from warrior_left.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### A09: Left Attack Frame 3 (Follow-through)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Attack follow-through, left profile view
- Sword extended forward and low
- Arms fully extended
- Body has followed through the swing
- Weight on front foot (left foot)

REQUIREMENTS:
- Match the armor style from warrior_left.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### A10: Right Attack Frame 1 (Wind-up)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Preparing to attack, right profile view (character facing your right)
- Sword raised behind/above head
- Body coiled
- Weight on back foot (left foot)
- We see the right side of the character

REQUIREMENTS:
- Match the armor style from warrior_right.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### A11: Right Attack Frame 2 (Swing)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Mid-swing attack, right profile view
- Sword swinging forward/downward toward the right
- Arms extending
- Body rotating into attack
- Dynamic action frame

REQUIREMENTS:
- Match the armor style from warrior_right.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### A12: Right Attack Frame 3 (Follow-through)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Attack follow-through, right profile view
- Sword extended forward and low to the right
- Arms fully extended
- Body has followed through
- Weight on front foot (right foot)

REQUIREMENTS:
- Match the armor style from warrior_right.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

---

## PHASE 3: DEATH ANIMATIONS

### D01: Front Death Frame 1 (Hit)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Just been struck, facing camera (front view)
- Reacting to fatal blow
- Head snapping back
- One hand releasing sword, going to chest/wound
- Body starting to lean backward
- Expression of shock (even through helmet, convey through body language)

REQUIREMENTS:
- Match the armor style from warrior_front.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### D02: Front Death Frame 2 (Falling)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Falling, facing camera (front view)
- Knees buckling
- Body tilting backward significantly
- Sword falling from hand or dropped
- Arms going limp
- Clearly losing balance

REQUIREMENTS:
- Match the armor style from warrior_front.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### D03: Front Death Frame 3 (Collapsed)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Collapsed on ground, from front camera angle
- Lying on back or crumpled
- Limbs splayed
- Sword on ground nearby
- Motionless, clearly dead
- Viewed from above-front angle

REQUIREMENTS:
- Match the armor style from warrior_front.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### D04-D06: Back Death Frames
```
[Same as D01-D03 but character facing away from camera - we see their back as they fall forward away from us]
```

### D07: Left Death Frame 1 (Hit)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Just been struck, left profile view
- Reacting to fatal blow from the right
- Body recoiling to the left
- Hand going to wound
- Head snapping

REQUIREMENTS:
- Match the armor style from warrior_left.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### D08: Left Death Frame 2 (Falling)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Falling sideways, left profile view
- Knees buckling
- Body tilting/falling to the left
- Arms going limp
- Sword dropping

REQUIREMENTS:
- Match the armor style from warrior_left.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### D09: Left Death Frame 3 (Collapsed)
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Collapsed on ground, left profile view
- Lying on side or crumpled
- Motionless
- Sword on ground

REQUIREMENTS:
- Match the armor style from warrior_left.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### D10-D12: Right Death Frames
```
[Same as D07-D09 but right profile - character falls to the right]
```

---

## PHASE 4: HURT/DAMAGE ANIMATIONS

### H01: Front Hurt
```
Using the attached reference images as your style guide, create a new sprite of this exact same soldier character.

POSE: Taking a hit but not dying, facing camera
- Flinching from impact
- One arm up defensively
- Body recoiling slightly
- Still on feet, still fighting
- Brief pain reaction

REQUIREMENTS:
- Match the armor style from warrior_front.png exactly
- Transparent PNG background
- Same art style and level of detail
- Full body visible
- Lighting from upper-left
```

### H02-H04: Back/Left/Right Hurt
```
[Same flinching pose from back, left profile, and right profile views]
```

---

## REFINEMENT PROMPTS

If a generated sprite doesn't match well, use these follow-up prompts:

**If colors are wrong:**
```
The armor color needs to match the reference exactly. It should be a deep crimson/blood red, not [describe what's wrong]. Please regenerate with the correct coloring.
```

**If style is too different:**
```
The art style doesn't match the references. The original has [clean lines / slight stylization / specific detail]. Please make it match the reference style more closely.
```

**If proportions are off:**
```
The character proportions don't match. Compare to warrior_front.png - the [head/torso/legs] should be [bigger/smaller/different]. Please adjust to match.
```

**If pose is unclear:**
```
The pose isn't quite right. I need [specific correction]. The [body part] should be [specific position].
```

**If background isn't transparent:**
```
The background needs to be fully transparent (PNG with alpha channel). Please regenerate with a transparent background, no ground shadow.
```

---

## FILE NAMING CONVENTION

Save generated sprites as:
- `warrior_walk_front1.png`, `warrior_walk_front2.png`, `warrior_walk_front3.png`
- `warrior_walk_back1.png`, `warrior_walk_back2.png`, `warrior_walk_back3.png`
- `warrior_attack_front1.png`, `warrior_attack_front2.png`, `warrior_attack_front3.png`
- `warrior_attack_back1.png`, etc.
- `warrior_attack_left1.png`, etc.
- `warrior_attack_right1.png`, etc.
- `warrior_death_front1.png`, etc.
- `warrior_hurt_front.png`, `warrior_hurt_back.png`, `warrior_hurt_left.png`, `warrior_hurt_right.png`

---

## POST-PROCESSING STEPS

After generating each sprite:

1. **Verify transparency**: Open in image editor, confirm background is transparent
2. **Remove artifacts**: Clean up any stray pixels or background remnants
3. **Scale to 517px height**: Resize maintaining aspect ratio
4. **Check alignment**: Compare side-by-side with reference sprites
5. **Save as PNG**: Ensure PNG format with alpha channel preserved
6. **Test in game**: Load into the game engine to verify it works

---

## TIPS FOR BEST RESULTS

1. **Upload all references every time** - Gemini needs to see the existing style
2. **One sprite at a time** - Don't ask for multiple poses at once
3. **Be patient with iteration** - First attempt rarely perfect
4. **Use specific language** - "right arm" not "arm", "45 degrees" not "raised"
5. **Reference specific frames** - "like warrior_walk1.png but facing forward"
6. **Describe motion** - For action poses, describe what just happened and what's about to happen
