<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-23 -->

# Reference Images - Sprite Generation Style Guides

## Overview

This directory contains reference sprite images used as style guides for AI-assisted sprite generation with Google Gemini. These images establish the visual style, color palette, and character design that new sprites should match.

## Image Inventory

### Directional Sprites (Static Poses)

| File | Description | Purpose |
|------|-------------|---------|
| `warrior_front.png` | Warrior facing camera (front view) | Style reference for front-facing attack, hurt, and death animations |
| `warrior_back.png` | Warrior facing away (back view) | Style reference for back-facing animations |
| `warrior_left.png` | Warrior facing left (profile) | Style reference for left-facing animations |
| `warrior_right.png` | Warrior facing right (profile) | Style reference for right-facing animations |

### Walking Animation Frames

| File | Description | Animation Phase |
|------|-------------|-----------------|
| `warrior_walk1.png` | Side-profile walking frame | First stride phase (swing phase, foot off ground) |
| `warrior_walk2.png` | Side-profile walking frame | Second stride phase (push-off, forward leg planted) |

## Character Design Specifications

### Visual Identity

**The Warrior:**
- Medieval fantasy soldier in mixed plate and scale armor
- Male character with brown hair
- Muscular, slightly exaggerated proportions
- Clean digital art with moderate stylization

### Armor Details

| Component | Material | Color |
|-----------|----------|-------|
| Pauldrons (shoulders) | Metal plate | Silver-gray with gold trim |
| Chest/Cuirass | Scale/leather | Deep red-brown with quilted texture |
| Bracers (forearms) | Leather | Red-brown with darker trim |
| Belt | Leather | Dark brown with silver buckle |
| Tassets (thigh guards) | Segmented plate | Red-brown |
| Greaves/Boots | Leather | Dark brown |

### Weapon

- Single-handed longsword
- Straight silver-gray blade
- Simple crossguard and brown hilt wrap
- Held in right hand, blade angled downward at rest

### Color Palette

| Color | Hex (approximate) | Usage |
|-------|-------------------|-------|
| Red-brown | #8B4513 | Primary armor (leather/scale) |
| Silver-gray | #A0A0A0 | Metal armor plates, sword blade |
| Gold/Yellow | #DAA520 | Armor trim, decorative accents |
| Dark brown | #3D2314 | Belt, boots, weapon hilt |
| Tan | #D2B48C | Skin tone |

## Art Style Guidelines

### Pixel Art Characteristics

- Classic 16-bit/32-bit RPG aesthetic
- Distinct, visible pixels with blocky appearance
- Solid color blocks with minimal gradients
- Sharp, well-defined edges and outlines
- Limited color palette per sprite
- Minimal anti-aliasing

### Technical Requirements Met by References

- [x] Transparent PNG background (white indicates alpha)
- [x] No ground shadows
- [x] Light source from upper-left
- [x] Full body visible (feet to head)
- [x] Clear silhouette for game readability
- [x] Consistent proportions across all views

## Usage with Gemini

### Uploading References

When generating new sprites with Gemini:

1. Upload 2-3 reference images that best match the target pose/direction
2. For attack animations: Use `warrior_front.png` or `warrior_back.png` + directional sprite
3. For walking animations: Use both `warrior_walk1.png` and `warrior_walk2.png` as style guides
4. Always specify the character design details from this document in your prompt

### Example Prompt Pattern

```
Using the attached reference images as style guides, generate a [animation type]
sprite of a medieval warrior with:
- Deep red-brown scale armor with gold trim
- Silver-gray metal pauldrons and bracers
- Single-handed longsword in right hand
- 16-bit pixel art style with visible pixels
- Transparent background
- [specific pose/action description]
```

## Animation Reference

### Walk Cycle (2-Frame)

The walking animation uses a 2-frame cycle:

```
Frame 1 (walk1): Left leg forward, right leg lifted (swing phase)
Frame 2 (walk2): Right leg pushes back, left leg planted (push-off phase)
```

For 3-frame walking animations (W01-W06), an intermediate frame should be generated between these two poses.

### Directional Consistency

When generating directional sprites:
- **Front**: Facing camera, three-quarter view acceptable
- **Back**: Facing away, same posture as front
- **Left**: Full profile, facing screen-left
- **Right**: Full profile, facing screen-right (mirror of left)

## Related Files

- Master prompts: `../GEMINI_MASTER_INSTRUCTIONS.md`
- Quick start guide: `../QUICK_START.md`
- Parent documentation: `../AGENTS.md`

## Notes for AI Generation

1. **Consistency is critical**: All generated sprites must match the armor style, colors, and proportions shown in these references
2. **Pose variations**: The static directional sprites show a ready/idle pose; generated animations should start from this baseline
3. **Weapon position**: The sword rests against the right thigh in idle poses but should move naturally during attack animations
4. **Armor asymmetry**: The pauldrons and armor details should remain consistent across all frames
