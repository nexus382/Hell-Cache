<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# tools

## Purpose
Documentation for VMU Pro SDK development tools including the packager, deployment utilities, and build systems.

## Key Files

| File | Description |
|------|-------------|
| `packer.md` | Complete packager tool documentation |

## For AI Agents

### Working In This Directory

**This is tool documentation** - reference when building and deploying apps.

### Packer Tool Documentation

**File**: `packer.md`

**Contents**:
- Installation requirements
- Command-line usage
- Project structure requirements
- metadata.json format
- Icon specifications
- Deployment instructions

**Quick Reference**:
```bash
cd ../../tools/packer
python3 packer.py \
    --projectdir /path/to/app \
    --appname my_app \
    --meta /path/to/metadata.json \
    --icon /path/to/icon.bmp
```

**Output**: `.vmupack` file → Deploy to SD card `D:\apps\`

### Tool Requirements

**Python Requirements**:
- Python 3.x
- PIL/Pillow (for icon processing)

**Project Requirements**:
- `app.lua` - Entry point
- `metadata.json` - App metadata
- `icon.bmp` - 76x76 icon
- `resources` array in metadata.json

### Deployment Workflow

1. **Prepare project**:
   - Verify all files present
   - Check metadata.json
   - Ensure icon.bmp is 76x76

2. **Run packager**:
   ```bash
   python3 packer.py [options]
   ```

3. **Deploy**:
   - Copy `.vmupack` to SD card
   - Or use deployment tool
   - Launch from VMU Pro menu

## Dependencies

### Internal
- `../api/` - API docs referenced by apps
- `../../tools/packer/` - Actual packager tool
- `../../examples/` - Apps to package

### External
- Python 3.x
- PIL/Pillow

<!-- MANUAL: Tool-specific notes can be added below -->
