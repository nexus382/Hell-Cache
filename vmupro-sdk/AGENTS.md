# VMU Pro SDK - AGENTS.md

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

The VMU Pro SDK is a comprehensive LUA-based software development kit for creating applications on the VMU Pro handheld platform. It provides the official APIs, documentation, examples, and tooling needed to develop, package, and deploy Lua applications to VMU Pro devices.

**Key Characteristics:**
- **Platform:** VMU Pro handheld device (240x240 display, RGB565 color)
- **Language:** Lua scripting environment
- **API Coverage:** Graphics, input, audio, file system, and system utilities
- **Tooling:** Python-based packaging and deployment tools

**Current Version:** 1.2.0

---

## Key Files

| File | Purpose |
|------|---------|
| `README.md` | Main SDK documentation with quick start guide |
| `LICENSE` | Copyright (c) 2025 8BitMods - All rights reserved |
| `VERSION` | Current SDK version (1.2.0) |
| `.gitignore` | Git ignore patterns for SDK repository |

---

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `sdk/` | Core SDK - Lua API definitions and type stubs for IDE support |
| `docs/` | Documentation - API references, guides, and examples |
| `examples/` | Sample applications demonstrating SDK usage |
| `tools/` | Development tools - packer and deployment utilities |

---

## For AI Agents

### Working With This SDK

1. **SDK APIs are in `sdk/api/`** - These are stub/type definition files for IDE autocomplete, not runtime code.

2. **Documentation is in `docs/`** - Contains API references, getting started guides, and tool documentation.

3. **Examples demonstrate patterns** - `examples/hello_world/` for basic usage, `examples/nested_example/` for module organization.

4. **Tools are Python-based** - `tools/packer/packer.py` for packaging, `tools/packer/send.py` for deployment.

### Core API Modules

| Module | File | Description |
|--------|------|-------------|
| System | `sdk/api/system.lua` | Logging, timing, and system utilities |
| Display | `sdk/api/display.lua` | Graphics rendering, text, shapes, colors |
| DoubleBuffer | `sdk/api/doublebuffer.lua` | Double buffering for smooth rendering |
| Input | `sdk/api/input.lua` | Button and control input handling |
| Audio | `sdk/api/audio.lua` | Audio playback and control |
| Synth | `sdk/api/synth.lua` | Synthesizer API for sound generation |
| Instrument | `sdk/api/instrument.lua` | Musical instrument definitions |
| Sequence | `sdk/api/sequence.lua` | Music sequence playback |
| Sprites | `sdk/api/sprites.lua` | Sprite collision and batch operations |
| File | `sdk/api/file.lua` | File system operations (restricted to `/sdcard`) |
| Debug | `sdk/api/debug.lua` | Debugging utilities |
| Text | `sdk/api/text.lua` | Text rendering utilities |
| Utilities | `sdk/api/utilities.lua` | Additional utility functions |

### API Namespace Pattern

All VMU Pro APIs are accessed via the `vmupro.*` namespace:

```lua
import "api/system"
import "api/display"

vmupro.system.log(vmupro.system.LOG_INFO, "MyApp", "Hello!")
vmupro.graphics.clear(vmupro.graphics.BLACK)
```

### Common Tasks

**Finding API documentation:**
- API reference: `docs/api/` directory contains markdown docs for each module
- Getting started: `docs/getting-started.md` and `docs/guides/first-app.md`

**Understanding example patterns:**
- `examples/hello_world/` - Minimal application structure
- `examples/nested_example/` - Module organization with `require()`

**Packaging applications:**
```bash
python tools/packer/packer.py \
    --projectdir path/to/project \
    --appname output_name \
    --meta metadata.json \
    --sdkversion 1.2.0 \
    --icon icon.bmp
```

**Deploying to device:**
```bash
python tools/packer/send.py \
    --func send \
    --localfile app.vmupack \
    --remotefile apps/app.vmupack \
    --comport COM3
```

### Application Structure Pattern

```
my_app/
├── app.lua           # Main entry point with AppMain() function
├── metadata.json     # Application metadata and resource manifest
├── icon.bmp          # 76x76 application icon
└── libraries/        # Optional custom modules
    └── utils.lua
```

### Metadata Schema

| Field | Type | Description |
|-------|------|-------------|
| `metadata_version` | number | Always `1` |
| `app_name` | string | Display name (1-255 chars) |
| `app_author` | string | Author name (1-255 chars) |
| `app_version` | string | Version in `x.y.z` format |
| `app_entry_point` | string | Main LUA file (usually `app.lua`) |
| `app_mode` | number | Always `1` for LUA applications |
| `app_environment` | string | Always `"lua"` |
| `icon_transparency` | boolean | Icon transparency support |
| `resources` | array | List of files/folders to include in package |

---

## Documentation Structure

### API Documentation (`docs/api/`)

| File | Content |
|------|---------|
| `system.md` | System, logging, and timing APIs |
| `display.md` | Graphics rendering and display management |
| `doublebuffer.md` | Double buffering for flicker-free rendering |
| `input.md` | Button and control input handling |
| `audio.md` | Audio playback and control |
| `synth.md` | Synthesizer sound generation |
| `instrument.md` | Musical instrument definitions |
| `sequence.md` | Music sequence playback |
| `sprites.md` | Sprite collision and batch operations |
| `file.md` | File system operations |
| `debug.md` | Debugging utilities |

### Guides (`docs/guides/`)

| File | Content |
|------|---------|
| `first-app.md` | Creating your first VMU Pro application |
| `graphics-guide.md` | Graphics programming guide |
| `audio-guide.md` | Audio programming guide |
| `file-operations.md` | File system usage patterns |

### Tools Documentation (`docs/tools/`)

| File | Content |
|------|---------|
| `packer.md` | Application packaging tool documentation |
| `development.md` | Development workflow and tooling |

---

## Example Applications

### hello_world

Minimal application demonstrating:
- Basic project structure
- AppMain() entry point
- System logging
- Metadata configuration

### nested_example

Comprehensive example demonstrating:
- Module organization with folders
- Using `require()` for custom modules
- Multiple pages/screens (38 page files)
- Utility libraries (maths.lua, utils.lua)

---

## Dependencies

### Build/Development
- **Python 3.6+** - Required for packer and deployment tools
- **Pillow (PIL)** - For icon processing: `pip install Pillow`

### Runtime
- **VMU Pro** handheld device or emulator
- VMU Pro firmware with Lua environment support

---

## Architecture Overview

```
+------------------+
|   Application    |  <- Your Lua app (app.lua + modules)
+--------+---------+
         |
         v
+------------------+
|   VMU Pro APIs   |  <- vmupro.* namespace
+--------+---------+
         |
    +----+----+
    |         |
    v         v
+------+  +--------+
| SDK  |  | Firmware|
| Stubs|  | Runtime |
+------+  +--------+
```

**Packaging Flow:**
```
Source Files -> packer.py -> .vmupack -> send.py -> VMU Pro Device
```

---

## See Also

- `../AGENTS.md` - Parent project (Inner Sanctum game)
- `README.md` - Main SDK documentation
- `docs/SUMMARY.md` - Documentation table of contents
