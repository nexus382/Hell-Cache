<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# references

## Purpose
Reference images used for AI-based sprite generation. These images provide the visual style guide for maintaining consistency across generated sprites.

## For AI Agents

### Working In This Directory

**Reference images serve as style guides** when generating new sprites with AI tools (Gemini, DALL-E, etc.).

**Typical Reference Images**:
- `warrior_front.png` - Primary style reference for all warrior sprites
- Shows armor style, color palette, proportions, and rendering quality
- Used as input to AI generation prompts

### Using Reference Images

**When generating new sprites**:

1. **Select appropriate reference**:
   - Use `warrior_front.png` for character consistency
   - Reference shows: Red/crimson armor, medieval style, ~517px height

2. **Craft prompt with reference**:
   ```
   Create a pixel art sprite matching the reference image.

   CHARACTER DETAILS:
   - Same style as reference image
   - Red/crimson plate armor
   - Medieval fantasy soldier
   - Proportions: approximately 517 pixels tall

   POSE: [Describe desired pose]
   DIRECTION: [Front/Back/Left/Right]

   TECHNICAL REQUIREMENTS:
   - PNG with transparent background
   - Clean edges, no anti-aliasing
   - Consistent lighting (top-left)
   - Match reference style exactly

   [Attach reference image]
   ```

3. **Post-process output**:
   - Use `../../tools/fix_sprites.py` to clean up
   - Verify against reference for consistency
   - Normalize to correct height if needed

### Reference Image Standards

**Quality Criteria**:
- High visual clarity
- Consistent art style
- Proper proportions
- Good contrast
- Clean transparency

**What to Capture**:
- Character design and armor style
- Color palette (reds, grays, metallic tones)
- Line quality and edge rendering
- Shading style (top-left lighting)
- Overall proportions

### Common Patterns

**Style Consistency Checklist**:
- [ ] Armor color matches reference (red/crimson)
- [ ] Proportions are similar (~517px height)
- [ ] Lighting direction matches (top-left)
- [ ] Line quality is consistent
- [ ] Background is fully transparent
- [ ] No anti-aliasing artifacts

### Testing Requirements

After generating sprites using references:
- Side-by-side comparison with reference
- Check color palette matches
- Verify proportions are consistent
- Test in-game alongside existing sprites
- Ensure animation frames blend smoothly

## Dependencies

### Internal
- `../../SPRITE_PIPELINE.md` - Sprite generation documentation
- `../../sprites/` - Input and output directory
- `../../tools/` - Post-processing tools

### External
- AI image generation tools (Gemini, DALL-E, etc.)

<!-- MANUAL: Reference usage notes can be added below -->
