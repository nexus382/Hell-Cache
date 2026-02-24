# Hello World Example - AGENTS.md

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

A minimal "Hello World" application demonstrating the fundamental structure and core APIs of the VMU Pro Lua SDK. This example serves as the canonical starting template for new VMU Pro applications.

---

## Project Structure

```
hello_world/
├── app.lua           # Main application with AppMain() entry point
├── metadata.json     # Application metadata for packaging
├── icon.bmp          # 76x76 pixel application icon
├── README.md         # User documentation
├── pack.sh           # Linux/macOS packaging script
├── pack.ps1          # Windows packaging script
├── send.sh           # Linux/macOS deployment script
└── send.ps1          # Windows deployment script
```

---

## Key Files

### app.lua

The main application file implementing the VMU Pro application lifecycle.

**Entry Point:** `AppMain()` - Required function called by VMU Pro firmware

**Functions:**
| Function | Purpose |
|----------|---------|
| `init_app()` | Initialize graphics, log SDK version, record start time |
| `update()` | Handle input, increment frame counter, check exit condition |
| `render()` | Draw UI elements (title, frame count, uptime, controls) |
| `AppMain()` | Main entry point - orchestrates init/update/render loop |

**APIs Used:**
```lua
import "api/system"   -- Logging, timing, delays
import "api/display"  -- Graphics, text rendering
import "api/input"    -- Button handling
```

**vmupro Namespace Usage:**
| Namespace | Functions Used |
|-----------|----------------|
| `vmupro.system` | `log()`, `getTimeUs()`, `delayMs()` |
| `vmupro.graphics` | `clear()`, `drawText()`, `drawRect()`, `refresh()` |
| `vmupro.text` | `setFont()` |
| `vmupro.input` | `read()`, `pressed()` |

### metadata.json

Application metadata for the packer tool.

```json
{
  "metadata_version": 1,
  "app_name": "Hello World",
  "app_author": "8BitMods",
  "app_version": "1.0.0",
  "app_entry_point": "app.lua",
  "app_mode": 1,
  "app_environment": "lua",
  "icon_transparency": false,
  "resources": ["app.lua"]
}
```

**Key Fields:**
| Field | Value | Description |
|-------|-------|-------------|
| `app_entry_point` | `"app.lua"` | Main file with AppMain() |
| `app_mode` | `1` | Standard application mode |
| `resources` | `["app.lua"]` | Minimal - single file app |

---

## Application Behavior

### Display Output

The application renders a VMU green background with:
1. **Title:** "VMUPro SDK Demo" (Gabarito 22x24 font)
2. **Message:** "Hello World!" (Gabarito 18x18 font)
3. **Frame Counter:** Live frame count in yellow
4. **Uptime:** Milliseconds since start in blue
5. **Namespace Info:** Available SDK namespaces
6. **Controls:** "Press B to exit"
7. **Border:** White rectangle decoration

### Controls

| Button | Action |
|--------|--------|
| B | Exit application |

### Exit Conditions

1. **User Exit:** Press B button
2. **Timeout Exit:** Auto-exit after 1800 frames (~30 seconds at 60 FPS)

---

## For AI Agents

### Application Pattern

This example demonstrates the canonical VMU Pro application structure:

```lua
-- Import required APIs
import "api/system"
import "api/display"
import "api/input"

-- Application state
local app_running = true

-- Initialize function
local function init_app()
    -- Setup graphics, log info
end

-- Update function (called each frame)
local function update()
    -- Read input, update state
end

-- Render function (called each frame)
local function render()
    -- Clear, draw, refresh
end

-- Required entry point
function AppMain()
    init_app()
    while app_running do
        update()
        render()
        vmupro.system.delayMs(16)  -- ~60 FPS
    end
    return 0
end
```

### Key Patterns to Follow

**1. Font Selection:**
```lua
vmupro.text.setFont(vmupro.text.FONT_GABARITO_22x24)  -- Large title
vmupro.text.setFont(vmupro.text.FONT_GABARITO_18x18)  -- Medium text
vmupro.text.setFont(vmupro.text.FONT_SMALL)           -- Compact text
```

**2. Color Usage:**
```lua
vmupro.graphics.VMUGREEN  -- Background (iconic VMU color)
vmupro.graphics.WHITE     -- Primary text
vmupro.graphics.YELLOW    -- Highlight (frame counter)
vmupro.graphics.BLUE      -- Secondary info (uptime)
vmupro.graphics.GREY      -- Muted text (namespaces)
```

**3. Logging Pattern:**
```lua
vmupro.system.log(vmupro.system.LOG_INFO, "HelloWorld", "Message")
vmupro.system.log(vmupro.system.LOG_DEBUG, "HelloWorld", "Message")
```

**4. Frame Timing:**
```lua
vmupro.system.delayMs(16)  -- Simple ~60 FPS target
```

**5. Input Handling:**
```lua
vmupro.input.read()
if vmupro.input.pressed(vmupro.input.B) then
    -- Handle B button press
end
```

### When Modifying This Example

1. **Add new imports** at the top for additional APIs
2. **Extend state variables** for tracking new data
3. **Add to init_app()** for one-time setup
4. **Add to update()** for per-frame logic
5. **Add to render()** for new visual elements
6. **Update resources** in metadata.json if adding files

### Common Modifications

**Add sprite support:**
```lua
import "api/sprites"
-- In metadata.json: "resources": ["app.lua", "sprites/"]
```

**Add audio:**
```lua
import "api/audio"
-- In metadata.json: "resources": ["app.lua", "audio/"]
```

**Add file persistence:**
```lua
import "api/file"
-- Use vmupro.file.read() / vmupro.file.write()
```

---

## Build Commands

### Package Application

```bash
# Linux/macOS
./pack.sh

# Windows
.\pack.ps1

# Or manually:
python ../../tools/packer/packer.py \
  --projectdir . \
  --appname hello_world \
  --meta metadata.json \
  --icon icon.bmp \
  --sdkversion 1.0.0
```

### Deploy to Device

```bash
# Linux/macOS
./send.sh

# Windows
.\send.ps1

# Or manually:
python ../../tools/packer/send.py \
  --func send \
  --localfile hello_world.vmupack \
  --remotefile apps/hello_world.vmupack \
  --comport COM3 \
  --exec
```

---

## See Also

- `../AGENTS.md` - Parent examples documentation
- `../nested_example/` - Advanced example with modular structure
- `../../docs/guides/first-app.md` - First app tutorial
- `../../tools/packer/` - Packaging tools
