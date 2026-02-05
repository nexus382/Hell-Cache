<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# tools

## Purpose
VMU Pro SDK build, packaging, and deployment tools for creating `.vmupack` files and deploying apps to VMU Pro hardware.

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `packer/` | Application packager for creating .vmupack files (see `packer/AGENTS.md`) |

## For AI Agents

### Working In This Directory

**These are SDK tools** - use them to build and deploy VMU Pro applications.

### Packer Tool

**Location**: `packer/packer.py`

**Purpose**: Bundles app source code, assets, metadata, and icon into a single `.vmupack` file for deployment.

**Usage**:
```bash
cd packer
python3 packer.py \
    --projectdir /path/to/app \
    --appname my_app \
    --meta /path/to/metadata.json \
    --icon /path/to/icon.bmp
```

**Output**: `my_app.vmupack` - Deploy to SD card `D:\apps\` or use deployment tool.

### Project Structure Requirements

**Required Files**:
- `app.lua` - Entry point with `function AppMain()`
- `metadata.json` - App metadata
- `icon.bmp` - 76x76 BMP icon

**Optional Directories**:
- `libraries/` - Shared Lua modules
- `pages/` - Page modules
- `assets/` - Images, sounds, etc.

### metadata.json Format

```json
{
  "metadata_version": 1,
  "app_name": "Application Name",
  "app_author": "Your Name",
  "app_version": "1.0.0",
  "app_entry_point": "app.lua",
  "app_mode": 1,
  "app_environment": "lua",
  "icon_transparency": false,
  "resources": [
    "app.lua",
    "libraries/*.lua",
    "pages/*.lua",
    "assets/*"
  ]
}
```

**App Modes**:
- **Mode 1 (APPLET)**: For utilities and apps (system overlay enabled)
- **Mode 3 (EXCLUSIVE)**: For games (full device control)
- Avoid Mode 2 (FULLSCREEN) - legacy only

### Icon Requirements

- **Format**: BMP
- **Dimensions**: 76x76 pixels
- **Color**: Auto-converted to RGB565
- **Transparency**: Set `icon_transparency: true` if needed

### Deployment

**After creating .vmupack**:
1. Copy to SD card: `D:\apps\my_app.vmupack`
2. Or use deployment tool (if available)
3. Launch from VMU Pro menu

## Dependencies

### Internal
- `../docs/tools/packer.md` - Packer documentation
- `../examples/` - Apps to be packaged

### External
- Python 3.x
- PIL/Pillow (for icon conversion)

<!-- MANUAL: Tool-specific notes can be added below -->
