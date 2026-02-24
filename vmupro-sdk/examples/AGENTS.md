# VMU Pro SDK Examples - AGENTS.md

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

This directory contains example applications demonstrating VMU Pro SDK usage patterns. These examples serve as templates and learning resources for developers building applications for the VMU Pro handheld platform.

---

## Example Projects

### hello_world

A minimal application demonstrating the fundamental structure of a VMU Pro Lua application.

**Location:** `/mnt/r/inner-santctum/vmupro-sdk/examples/hello_world/`

**Demonstrates:**
- Basic application structure with `AppMain()` entry point
- System logging via `vmupro.system.log()`
- Graphics rendering with `vmupro.graphics.*`
- Text rendering with multiple fonts via `vmupro.text.*`
- Input handling via `vmupro.input.*`
- Frame timing and uptime tracking
- Application lifecycle (init, update, render loop)

**Key Files:**
| File | Purpose |
|------|---------|
| `app.lua` | Main application with AppMain() entry point |
| `metadata.json` | Application metadata for packaging |
| `icon.bmp` | 76x76 pixel application icon |
| `pack.sh` / `pack.ps1` | Packaging scripts for Linux/Windows |
| `send.sh` / `send.ps1` | Deployment scripts for Linux/Windows |

---

### nested_example

A comprehensive SDK test suite demonstrating advanced project organization and complete API coverage.

**Location:** `/mnt/r/inner-santctum/vmupro-sdk/examples/nested_example/`

**Demonstrates:**
- Modular project organization with folders
- Page-based navigation system (39 test pages)
- Custom library modules via `import`
- Asset management (audio, images, MIDI)
- Double buffering for smooth rendering
- FPS tracking and frame timing

**Project Structure:**
```
nested_example/
├── app.lua              # Main entry with page router
├── metadata.json        # Lists all resources
├── icon.bmp             # Application icon
├── libraries/           # Custom utility modules
│   ├── maths.lua        # Math helpers (add, multiply, square)
│   └── utils.lua        # Utils (clamp, lerp)
├── pages/               # Test pages (page1.lua - page39.lua)
└── assets/              # Media resources
    ├── *.wav            # Audio samples
    ├── *.mid            # MIDI files
    └── *.png/*.bmp      # Images
```

**Test Pages Coverage:**
| Pages | Category | Topics |
|-------|----------|--------|
| 1-4 | Basic Graphics | Lines, rectangles, circles, text rendering |
| 5 | Colors | RGB565 color constants and swatches |
| 6 | Input | Button states (pressed, held, released) |
| 7-8 | Fonts | Font variants and text measurement |
| 9 | Animation | Sprite animation and timing |
| 10 | File I/O | File/folder operations, read/write |
| 11-39 | Advanced | Audio, sprites, double buffering, synthesizer, sequences |

**Key Files:**
| File | Purpose |
|------|---------|
| `app.lua` | Main entry with page routing, FPS tracking, navigation |
| `libraries/maths.lua` | Math utility functions |
| `libraries/utils.lua` | General utility functions (clamp, lerp) |
| `pages/page*.lua` | Individual test pages |
| `metadata.json` | Declares libraries, pages, and assets as resources |

---

## For AI Agents

### Working With Examples

**When creating new examples:**
1. Follow the `hello_world` structure for simple apps
2. Follow the `nested_example` structure for multi-module apps
3. Always include `metadata.json` with correct resource declarations
4. Include both `.sh` and `.ps1` scripts for cross-platform support

**Understanding the page pattern (nested_example):**
```lua
-- pages/pageN.lua
PageN = {}

function PageN.render(drawPageCounter)
    -- Draw page content
    drawPageCounter()  -- Call to show page number
end

function PageN.update()
    -- Optional: Handle per-frame logic
end

function PageN.enter()
    -- Optional: Called when navigating to page
end

function PageN.exit()
    -- Optional: Called when navigating away
end
```

**Navigation pattern:**
- LEFT/RIGHT buttons: Previous/Next page
- B button: Exit application
- MODE + navigation: Required on some pages (e.g., button test)

### Metadata Schema

Both examples use the same metadata structure:

```json
{
  "metadata_version": 1,
  "app_name": "App Name",
  "app_author": "Author Name",
  "app_version": "1.0.0",
  "app_entry_point": "app.lua",
  "app_mode": 1,
  "app_environment": "lua",
  "icon_transparency": false,
  "resources": ["app.lua", "libraries", "pages", "assets"]
}
```

**Resource declaration rules:**
- List all files/folders that should be packaged
- Folders are included recursively
- `hello_world` only needs `["app.lua"]` (minimal)
- `nested_example` needs `["app.lua", "libraries", "pages", "assets"]` (modular)

### Common Patterns

**Import statement:**
```lua
import "api/system"    -- SDK API
import "pages/page1"   -- Local module
```

**AppMain entry point:**
```lua
function AppMain()
    -- Initialize
    -- Main loop: update() then render()
    -- Return 0 for success
    return 0
end
```

**Frame timing (60 FPS target):**
```lua
local target_frame_time_us = 16666  -- 16.666ms
while app_running do
    local frame_start = vmupro.system.getTimeUs()
    update()
    render()
    local elapsed = vmupro.system.getTimeUs() - frame_start
    if target_frame_time_us - elapsed > 0 then
        vmupro.system.delayUs(target_frame_time_us - elapsed)
    end
end
```

---

## Key Files

| File | Purpose |
|------|---------|
| `.python-version` | Python version for tooling |
| `hello_world/` | Minimal application template |
| `nested_example/` | Comprehensive SDK test suite |

---

## See Also

- `../AGENTS.md` - Parent SDK documentation
- `../docs/guides/first-app.md` - First app tutorial
- `../tools/packer/` - Packaging tools
