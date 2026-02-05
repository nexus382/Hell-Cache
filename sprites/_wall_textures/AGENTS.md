<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# _wall_textures

## Purpose
Raw wall texture extraction files. These are intermediate files used during texture processing from the main wall spritesheet.

## For AI Agents

### Working In This Directory

**These are intermediate processing files** - temporarily stored during texture extraction from `../Walls.png`.

**Processing Workflow**:
1. **Source**: `../Walls.png` - Main wall textures spritesheet
2. **Extract**: Split into individual texture files
3. **Process**: Resize, format, or optimize as needed
4. **Output**: Final textures placed in `../wall_textures/`

### Usage Notes

**DO NOT**:
- ❌ Use these files directly in game
- ❌ Modify unless processing textures
- ❌ Delete if wall texture processing is incomplete

**DO**:
- ✅ Process into final wall textures
- ✅ Archive after processing if needed
- ✅ Use as reference for spritesheet layout

### Wall Texture Types

Based on the game (`../../app.lua`), wall textures include:
- Stone walls (light/dark variants)
- Brick walls (light/dark variants)
- Moss-covered walls
- Metal walls
- Wood walls

Each texture type may have multiple variations for visual variety.

### Processing Steps

**Extract Individual Textures**:
```python
from PIL import Image

def extract_textures(spritesheet_path, output_dir, texture_width, texture_height):
    sheet = Image.open(spritesheet_path)
    sheet_width, sheet_height = sheet.size

    cols = sheet_width // texture_width
    rows = sheet_height // texture_height

    for row in range(rows):
        for col in range(cols):
            x = col * texture_width
            y = row * texture_height
            texture = sheet.crop((x, y, x + texture_width, y + texture_height))
            texture.save(f"{output_dir}/wall_{row}_{col}.png")
```

### Testing Requirements

After processing:
- Verify all textures extracted completely
- Check texture dimensions match expected size
- Confirm no visual artifacts
- Test textures render correctly in 3D view

## Dependencies

### Internal
- `../Walls.png` - Source wall textures spritesheet
- `../wall_textures/` - Final processed textures
- `../../app.lua` - Game code using wall textures

### External
- PIL/Pillow (Python image processing)

<!-- MANUAL: Texture processing notes can be added below -->
