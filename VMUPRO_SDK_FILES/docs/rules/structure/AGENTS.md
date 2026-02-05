<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# structure

## Purpose
Project structure rules and organization standards for VMU Pro applications.

## For AI Agents

### Working In This Directory

**These are structure rule documents** - reference for organizing projects correctly.

### Required Structure

**Minimum Viable App**:
```
my_app/
├── app.lua
├── metadata.json
└── icon.bmp
```

**Full-Featured App**:
```
my_app/
├── app.lua              # Entry point
├── metadata.json        # App metadata
├── icon.bmp             # 76x76 icon
├── libraries/           # Shared Lua modules
│   └── utils.lua
├── pages/               # Page modules
│   ├── page1.lua
│   └── page2.lua
└── assets/              # Images, sounds
    ├── images/
    └── sounds/
```

### File Rules

**Required Files**:
- `app.lua` - Must contain `function AppMain()` returning a number
- `metadata.json` - App metadata in correct format
- `icon.bmp` - Exactly 76x76 pixels, BMP format

**File Naming**:
- Use lowercase with underscores: `my_sprite.png`
- Lua files: `.lua` extension
- Images: `.png` (with transparency)
- Sounds: `.wav` (but use synth instead due to crashes)

**File Organization Rules**:
- NEVER save files to project root
- Use subdirectories for organization
- Keep related files together

### metadata.json Rules

**Required Fields**:
```json
{
  "metadata_version": 1,
  "app_name": "App Name",
  "app_author": "Author",
  "app_version": "1.0.0",
  "app_entry_point": "app.lua",
  "app_mode": 1,
  "app_environment": "lua",
  "icon_transparency": false,
  "resources": ["app.lua"]
}
```

**App Modes**:
- `1` (APPLET) - For utilities/apps
- `3` (EXCLUSIVE) - For games
- Avoid `2` (FULLSCREEN) - Legacy

**Resources Array**:
- List all files to include
- Use wildcards: `libraries/*.lua`
- Order doesn't matter

## Dependencies

### Internal
- `../../api/` - API documentation
- `../../../examples/` - Example structures

<!-- MANUAL: Structure rule notes can be added below -->
