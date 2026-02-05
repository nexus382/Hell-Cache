<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# packer

## Purpose
VMU Pro application packager - creates `.vmupack` files from source code, assets, and metadata for deployment to VMU Pro hardware.

## Key Files

| File | Description |
|------|-------------|
| `packer.py` | Main packager script |
| Documentation: `../../docs/tools/packer.md` | Complete usage guide |

## For AI Agents

### Working In This Directory

**This is the packager tool** - use it to build `.vmupack` files.

### Usage

**Basic Command**:
```bash
python3 packer.py \
    --projectdir /path/to/app \
    --appname my_app \
    --meta /path/to/metadata.json \
    --icon /path/to/icon.bmp
```

**Parameters**:
- `--projectdir`: Path to app root directory
- `--appname`: Output filename (without .vmupack extension)
- `--meta`: Path to metadata.json file
- `--icon`: Path to icon.bmp file (76x76)

### Project Structure

**Input Structure**:
```
my_app/
├── app.lua              # Entry point (required)
├── metadata.json        # App metadata (required)
├── icon.bmp             # 76x76 icon (required)
├── libraries/           # Shared modules (optional)
├── pages/               # Page modules (optional)
└── assets/              # Images, sounds (optional)
```

**metadata.json Format**:
```json
{
  "metadata_version": 1,
  "app_name": "My App",
  "app_author": "Author Name",
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

### Output

**File**: `my_app.vmupack` (in current directory or specified output path)

**Deployment**:
1. Copy to SD card: `D:\apps\my_app.vmupack`
2. Eject and insert SD card into VMU Pro
3. Launch from VMU Pro menu

### App Modes

- **Mode 1 (APPLET)**: Utilities and apps (system overlay enabled)
- **Mode 3 (EXCLUSIVE)**: Games (full device control)
- **Mode 2 (FULLSCREEN)**: Legacy only - avoid

### Processing Steps

1. **Validate**: Check required files exist
2. **Process icon**: Convert BMP to RGB565 if needed
3. **Collect resources**: Gather all files from `resources` array
4. **Package**: Bundle into .vmupack format
5. **Output**: Write .vmupack file

### Dependencies

**Required**:
- Python 3.x
- PIL/Pillow (for icon conversion)

**Input Files**:
- App source code (Lua files)
- Assets (PNG images, etc.)
- Metadata file
- Icon file

**Documentation**:
- `../../docs/tools/packer.md` - Complete documentation
- `../../docs/getting-started.md` - Setup guide

<!-- MANUAL: Packer-specific notes can be added below -->
