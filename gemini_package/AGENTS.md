<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# gemini_package

## Purpose
Reference materials and prompts for AI-based sprite generation using Google Gemini. Contains style guides and reference images for maintaining visual consistency across generated sprites.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `references/` | Reference images for AI sprite generation (see `references/AGENTS.md`) |

## For AI Agents

### Working In This Directory

**AI Sprite Generation Workflow**:

1. **Select Reference Image**: Choose an existing sprite as style reference (e.g., `warrior_front.png`)
2. **Craft Prompt**: Use the prompt template from `../SPRITE_PIPELINE.md`
3. **Generate**: Submit to AI image generator (Gemini, DALL-E, etc.)
4. **Post-Process**: Clean up output with `../tools/fix_sprites.py`
5. **Validate**: Check consistency with existing sprites

### Prompt Template

**From `../SPRITE_PIPELINE.md`**:
```
Create a pixel art sprite of a medieval soldier in red/crimson armor.

CHARACTER DETAILS:
- Same character as reference image
- Red/crimson plate armor
- Medieval fantasy soldier
- Proportions: approximately 517 pixels tall

POSE: [SPECIFIC POSE]
DIRECTION: [Front/Back/Left/Right - facing camera]

TECHNICAL REQUIREMENTS:
- Transparent background (PNG)
- Clean edges, no anti-aliasing artifacts
- Consistent lighting (light from top-left)
- Style must match reference exactly
- Full body visible, feet to head

[Attach reference: warrior_front.png]
```

### Pose Specifications

**Walking Poses**:
- Frame 1: Left leg forward, right arm forward, mid-stride
- Frame 2: Legs together, neutral stance, transitioning
- Frame 3: Right leg forward, left arm forward, mid-stride

**Attack Poses**:
- Wind-up: Sword raised behind/above head, preparing to strike
- Swing: Sword mid-swing, arm extended diagonally
- Follow-through: Sword low after swing, body rotated

**Death Poses**:
- Start: Recoiling, hand to chest, sword dropping
- Mid: Falling backward/sideways, knees buckling
- Final: Collapsed on ground, motionless

### Quality Checklist

After generating sprites:
- [ ] Transparent background (no artifacts)
- [ ] Clean edges (no anti-aliasing)
- [ ] Consistent lighting (top-left)
- [ ] Normalized height (warrior: 517px, knight: 579px)
- [ ] Matches reference style
- [ ] Full body visible (feet to head)
- [ ] Proper alignment with existing sprites

### Testing Requirements

- Visual comparison with reference sprite
- Check color palette consistency
- Verify proportions match existing sprites
- Test in-game for scaling/positioning
- Ensure animation frames flow smoothly

## Dependencies

### Internal
- `../sprites/` - Source reference images and output directory
- `../SPRITE_PIPELINE.md` - Complete sprite generation documentation
- `../tools/` - Post-processing tools

### External
- Google Gemini (or other AI image generator)
- Image editing software (manual cleanup if needed)

## Sprite Generation Priority

**From `../SPRITE_PIPELINE.md`**:

### Phase 1: Core Animations (HIGH PRIORITY)
1. Front walking frames (W01-W03)
2. Back walking frames (W04-W06)
3. Left attack frames (A07-A09)
4. Right attack frames (A10-A12)

### Phase 2: Full Attack Set (HIGH PRIORITY)
5. Front attack frames (A01-A03)
6. Back attack frames (A04-A06)

### Phase 3: Death Animations (MEDIUM PRIORITY)
7. Left death frames (D07-D09)
8. Right death frames (D10-D12)
9. Front death frames (D01-D03)
10. Back death frames (D04-D06)

### Phase 4: Polish (LOW PRIORITY)
11. Hurt frames (H01-H04)

**Total**: 34 sprites needed for complete animation set

## Tips for AI Generation

1. **Be specific about direction**: "facing directly toward the camera" vs "profile view facing left"
2. **Describe the action clearly**: Instead of "attacking", say "sword raised above right shoulder, about to swing downward diagonally"
3. **Reference existing sprite**: Always attach warrior_front.png and say "match this character's armor style, colors, and proportions exactly"
4. **Request transparency**: "PNG with fully transparent background, no ground shadow"
5. **Specify dimensions**: "Output should be suitable for scaling to 517 pixels tall"
6. **Iterate**: If first result isn't right, refine the prompt rather than starting over

<!-- MANUAL: AI generation notes can be added below -->
