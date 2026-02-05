<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# tools

## Purpose
Development and build tools for processing sprites, generating assets, and packaging the game for VMU Pro deployment.

## Key Files

| File | Description |
|------|-------------|
| `generate_sprites.py` | Main sprite generation utility |
| `fix_sprites.py` | Sprite correction and fixing script |
| `process_warrior_actions.py` | Process warrior action animation sprites |
| `split_knight.py` | Split knight spritesheet into individual frames |
| `split_spritesheet.py` | General spritesheet splitting utility |
| `split_warrior_actions.py` | Split warrior action spritesheets |

## For AI Agents

### Working In This Directory

**Python Dependencies**:
- Python 3.x
- PIL/Pillow (Python Imaging Library)
- NumPy (optional, for advanced processing)

**Common Usage Patterns**:

**Split a Spritesheet**:
```bash
python split_spritesheet.py input.png output_dir frame_width frame_height
```

**Process Warrior Actions**:
```bash
python process_warrior_actions.py spritesheet.png output_directory
```

**Fix Sprite Issues**:
```bash
python fix_sprites.py input.png output.png
```

### Tool Descriptions

**generate_sprites.py**
- Purpose: Generate or batch-process sprites
- Features: Batch conversion, normalization, format conversion
- Usage: Refer to inline help or source code for options

**fix_sprites.py**
- Purpose: Fix common sprite issues (transparency, artifacts, sizing)
- Features: Background removal, transparency repair, dimension normalization
- Typical Use: Fix sprites after AI generation or manual editing

**process_warrior_actions.py**
- Purpose: Split and process warrior animation frames
- Features: Extract action sequences, normalize sizes, organize output
- Input: Spritesheet with multiple action frames
- Output: Individual frame PNG files

**split_knight.py**
- Purpose: Split knight spritesheet into character poses
- Features: Extract front/back/left/right poses
- Output: `knight_front.png`, `knight_back.png`, etc.

**split_spritesheet.py**
- Purpose: General-purpose spritesheet splitter
- Features: Grid-based extraction, customizable frame dimensions
- Usage: `split_spritesheet.py <input> <output_dir> <width> <height>`

**split_warrior_actions.py**
- Purpose: Split warrior-specific action spritesheets
- Features: Handle attack, death, walking sequences
- Organizes output by action type

### Sprite Processing Pipeline

1. **Generate Base Sprites**: Use AI tools (see `../SPRITE_PIPELINE.md`)
2. **Fix Issues**: Run `fix_sprites.py` to clean up artifacts
3. **Split Spritesheets**: Use appropriate `split_*.py` script
4. **Normalize**: Ensure consistent heights (warrior: 517px, knight: 579px)
5. **Organize**: Place output in `../sprites/level1/` or `../sprites/level2/`
6. **Verify**: Test in-game

### Common Operations

**Normalize Sprite Height**:
```python
from PIL import Image

def normalize_height(input_path, output_path, target_height=517):
    img = Image.open(input_path)
    aspect_ratio = img.width / img.height
    new_width = int(target_height * aspect_ratio)
    resized = img.resize((new_width, target_height), Image.Resampling.LANCZOS)
    resized.save(output_path)
```

**Remove Background Artifacts**:
```python
from PIL import Image

def clean_transparency(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    # Apply transparency threshold or flood fill
    # Save cleaned version
    img.save(output_path)
```

### Testing Requirements

- Verify output sprites have correct dimensions
- Check transparency is preserved
- Test processed sprites in-game
- Ensure no quality loss from processing
- Validate output filenames match expected format

## Dependencies

### Internal
- `../sprites/` - Input and output directory for sprite assets
- `../SPRITE_PIPELINE.md` - Documentation for sprite generation workflow

### External
- Python 3.x
- PIL/Pillow (image processing)
- Optional: NumPy (advanced operations)

## Build Tools

**Note**: The VMU Pro SDK packager is located at:
- `../VMUPRO_SDK_FILES/tools/packer/packer.py`

**Packaging Command**:
```bash
cd ../VMUPRO_SDK_FILES/tools/packer
python3 packer.py \
    --projectdir ../../inner-santctum \
    --appname inner_sanctum \
    --meta ../../metadata.json \
    --icon ../../icon.bmp
```

**Output**: `inner_sanctum.vmupack` → deploy to SD card `D:\apps\`

<!-- MANUAL: Tool-specific notes can be added below -->
