<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# _rows

## Purpose
Individual rows extracted from large spritesheets. These are intermediate files used during sprite processing and organization.

## Key Files

| File | Description |
|------|-------------|
| `row1.png` | Spritesheet row 1 (largest, 82KB) |
| `row2.png` | Spritesheet row 2 (56KB) |
| `row3.png` | Spritesheet row 3 (largest, 80KB) |
| `row4.png` | Spritesheet row 4 (small, 4KB) |
| `row5.png` | Spritesheet row 5 (78KB) |
| `row6.png` | Spritesheet row 6 (small, 4KB) |
| `row7.png` | Spritesheet row 7 (23KB) |
| `row8.png` | Spritesheet row 8 (tiny, <1KB) |
| `row9.png` | Spritesheet row 9 (68KB) |
| `row10.png` | Spritesheet row 10 (13KB) |

## For AI Agents

### Working In This Directory

**These are intermediate files** - used during sprite extraction from spritesheets.

**Processing Workflow**:
1. **Source**: Large spritesheet (e.g., `SPRITE_GUYS.png` in parent directory)
2. **Extract**: Split into horizontal rows using image processing
3. **Process**: Further split rows into individual sprite frames
4. **Output**: Final sprites placed in `../level1/` or `../level2/`

### File Organization

Rows vary significantly in size:
- **Large rows** (70-80KB): Contain multiple character frames or detailed sprites
- **Medium rows** (10-30KB): Contain fewer elements or smaller sprites
- **Small rows** (<5KB): May contain sparse elements or partial frames

**Note**: `row8.png` is extremely small (<1KB) - may be empty or contain minimal data.

### Common Operations

**Process Row into Individual Sprites**:
```python
from PIL import Image

def split_row(row_path, output_dir, frame_width, frame_height):
    row = Image.open(row_path)
    row_width, row_height = row.size

    num_frames = row_width // frame_width

    for i in range(num_frames):
        x = i * frame_width
        frame = row.crop((x, 0, x + frame_width, frame_height))
        frame.save(f"{output_dir}/frame_{i+1}.png")
```

**Preview Row Contents**:
```bash
# Quick visual inspection
display row1.png
# Or use Python
python3 -c "from PIL import Image; Image.open('row1.png').show()"
```

### Usage Notes

**DO NOT**:
- ❌ Use these files directly in game
- ❌ Modify these files manually
- ❌ Delete these files if still processing

**DO**:
- ✅ Process these into individual sprites
- ✅ Archive after processing if needed
- ✅ Use as reference for spritesheet layout

### Testing Requirements

After processing rows:
- Verify all frames extracted correctly
- Check no frames are cut off
- Confirm transparency is preserved
- Test output sprites in-game

## Dependencies

### Internal
- `../SPRITE_GUYS.png` - Source spritesheet
- `../level1/` - Output directory for processed sprites
- `../level2/` - Output directory for processed sprites
- `../../tools/split_spritesheet.py` - Spritesheet splitting tool

### External
- PIL/Pillow (Python image processing)

<!-- MANUAL: Row-specific processing notes can be added below -->
