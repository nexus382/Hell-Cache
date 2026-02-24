# VMU Pro SDK Tools Documentation - AGENTS.md

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

This directory contains documentation for VMU Pro SDK tooling, including the packer utility for packaging applications and development environment setup guides.

**Key Characteristics:**
- **Format:** Markdown documentation files
- **Audience:** Developers setting up development environments and building VMU Pro applications
- **Coverage:** Complete packer tool reference and IDE configuration guides

---

## Key Files

| File | Purpose |
|------|---------|
| `packer.md` | Complete reference for the packer tool that creates `.vmupack` files |
| `development.md` | Development environment setup, IDE configuration, and workflow guides |

---

## File Details

### packer.md

**Purpose:** Documents the Python-based packer tool that bundles LUA applications into deployable `.vmupack` files.

**Key Sections:**
- Prerequisites (Python 3.6+, Pillow)
- Command line arguments (required and optional)
- Metadata file format with field specifications
- App modes (APPLET=1, EXCLUSIVE=3) and when to use each
- Icon requirements (76x76 BMP)
- Project structure examples
- Common issues and solutions

**Important Metadata Fields:**

| Field | Description |
|-------|-------------|
| `app_mode` | 1=Applet (apps), 3=Exclusive (games) |
| `app_environment` | Always `"lua"` for LUA SDK |
| `resources` | Array of files/folders to package |
| `icon_transparency` | `false` or hex color like `"#FF00FF"` |

**App Mode Selection:**
- `app_mode: 1` (APPLET) - Apps, utilities, system tools
- `app_mode: 3` (EXCLUSIVE) - Games needing full device control

### development.md

**Purpose:** Guides developers through complete development environment setup using the SDK as a Git submodule.

**Key Sections:**
- Development model overview (SDK as submodule)
- Project structure with SDK integration
- IDE setup (VS Code configuration)
- Project templates (application and game)
- Build system (build.sh, Makefile)
- Submodule management
- Version control best practices

**Standard Project Structure:**
```
my_vmupro_project/
├── vmupro-sdk/          # Git submodule
├── src/                 # Application source
├── metadata.json        # App metadata
├── icon.bmp             # 76x76 icon
└── build.sh             # Build script
```

**VS Code Configuration:**
- `lua.workspace.library` points to `vmupro-sdk/sdk/api`
- `lua.diagnostics.globals` includes `vmupro`, `import`

---

## For AI Agents

### Working With Tool Documentation

1. **Packaging Applications** - Use `packer.md` for:
   - Command syntax and arguments
   - Metadata format requirements
   - App mode selection guidance
   - Troubleshooting packaging errors

2. **Setting Up Projects** - Use `development.md` for:
   - Creating new projects with SDK submodule
   - IDE configuration
   - Build script templates
   - Development workflow

### Common Tasks

**Packaging a LUA application:**
```bash
python vmupro-sdk/tools/packer/packer.py \
    --projectdir . \
    --appname my_app \
    --meta metadata.json \
    --sdkversion 1.0.0 \
    --icon icon.bmp
```

**Creating metadata.json for an app:**
```json
{
    "metadata_version": 1,
    "app_name": "My App",
    "app_author": "Author",
    "app_version": "1.0.0",
    "app_entry_point": "src/main.lua",
    "app_mode": 1,
    "app_environment": "lua",
    "icon_transparency": false,
    "resources": ["src"]
}
```

**Creating metadata.json for a game:**
```json
{
    "metadata_version": 1,
    "app_name": "My Game",
    "app_author": "Author",
    "app_version": "1.0.0",
    "app_entry_point": "src/main.lua",
    "app_mode": 3,
    "app_environment": "lua",
    "icon_transparency": false,
    "resources": ["src", "assets"]
}
```

### Key Decision Points

| Decision | Guidance |
|----------|----------|
| App vs Game mode | `app_mode: 1` for apps/utilities, `app_mode: 3` for games |
| Icon transparency | Use `false` for solid icons, hex color for transparent areas |
| Resources array | List all files/folders the app needs at runtime |
| Build script | Use `build.sh` for simple projects, `Makefile` for complex |

### Troubleshooting Reference

| Error | Location | Solution |
|-------|----------|----------|
| `ModuleNotFoundError: No module named 'PIL'` | packer.md | `pip install Pillow` |
| Resource not found | packer.md | Verify paths in `resources` array |
| Metadata validation | packer.md | Check all required fields present |
| Icon issues | packer.md | Ensure 76x76 BMP format |

---

## Related Files

| File | Relationship |
|------|--------------|
| `../../tools/packer/packer.py` | The packer tool this documentation describes |
| `../getting-started.md` | Quick start guide referencing these tools |
| `../SUMMARY.md` | Navigation including these tool docs |

---

## See Also

- `../AGENTS.md` - Parent documentation directory context
- `../../tools/` - Source code for SDK tools
- `../guides/first-app.md` - First application tutorial using these tools
