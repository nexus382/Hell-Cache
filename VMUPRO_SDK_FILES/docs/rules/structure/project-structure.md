# VMU Pro SDK Project Structure Rules

## Overview

This document defines the required and optional files, directory structure, and organization patterns for VMU Pro SDK projects based on analysis of the official examples (`hello_world` and `nested_example`).

---

## Required Files

Every VMU Pro SDK project **MUST** include these three files in the root directory:

### 1. `app.lua`
- **Purpose**: Main application entry point
- **Required Function**: `AppMain()` - called by VMU Pro firmware when the app starts
- **Return Value**: Must return a number (0 = success, non-zero = error)
- **Imports**: Must import required API namespaces at the top:
  ```lua
  import "api/system"
  import "api/display"
  import "api/input"
  -- Import other APIs as needed
  ```

### 2. `metadata.json`
- **Purpose**: Application metadata and configuration
- **Format**: JSON file with specific required fields (see detailed structure below)
- **Location**: Must be in project root directory

### 3. `icon.bmp`
- **Purpose**: Application icon displayed in VMU Pro menu
- **Format**: BMP (bitmap) image file
- **Recommended Size**: 48x48 pixels (VMU screen is 240x240)
- **Location**: Must be in project root directory
- **Transparency**: Controlled via `icon_transparency` field in metadata.json

---

## metadata.json Structure

### Required Fields

All VMU Pro projects must include these fields in `metadata.json`:

```json
{
  "metadata_version": 1,
  "app_name": "Your App Name",
  "app_author": "Author Name",
  "app_version": "1.0.0",
  "app_entry_point": "app.lua",
  "app_mode": 1,
  "app_environment": "lua",
  "icon_transparency": false,
  "resources": ["app.lua"]
}
```

### Field Descriptions

| Field | Type | Required | Description | Example Values |
|-------|------|----------|-------------|----------------|
| `metadata_version` | number | Yes | Metadata format version | `1` |
| `app_name` | string | Yes | Display name of the application | `"Hello World"` |
| `app_author` | string | Yes | Author or organization name | `"8BitMods"` |
| `app_version` | string | Yes | Semantic version number | `"1.0.0"` |
| `app_entry_point` | string | Yes | Main Lua file (always `app.lua`) | `"app.lua"` |
| `app_mode` | number | Yes | Application mode | `1` (standard mode) |
| `app_environment` | string | Yes | Runtime environment | `"lua"` |
| `icon_transparency` | boolean | Yes | Enable icon transparency | `true` or `false` |
| `resources` | array | Yes | List of files/directories to bundle | See below |

### Resources Array

The `resources` array specifies which files and directories to include in the packaged application:

**Simple Project** (single file):
```json
{
  "resources": ["app.lua"]
}
```

**Complex Project** (with modules and assets):
```json
{
  "resources": [
    "app.lua",
    "libraries",
    "pages",
    "assets"
  ]
}
```

**Rules**:
- Must always include `"app.lua"`
- Directory names are included without trailing slashes
- Only include directories that exist in your project
- Files are bundled recursively from listed directories

---

## Optional Files and Directories

### Development Scripts

These scripts are optional but recommended for development workflow:

- `pack.sh` - Shell script to package the application (Unix/Linux/macOS)
- `pack.ps1` - PowerShell script to package the application (Windows)
- `send.sh` - Shell script to deploy to VMU Pro device (Unix/Linux/macOS)
- `send.ps1` - PowerShell script to deploy to VMU Pro device (Windows)
- `README.md` - Project documentation

**Note**: These scripts are NOT bundled in the final package (not in `resources` array).

### Optional Directories

#### `libraries/`
- **Purpose**: Reusable Lua modules and utility functions
- **Usage**: Store shared code that can be imported by multiple files
- **Example Files**:
  - `libraries/maths.lua` - Math utility functions
  - `libraries/utils.lua` - General utility functions
  - `libraries/physics.lua` - Physics calculations
  - `libraries/ui.lua` - UI components

**Module Structure**:
```lua
-- libraries/maths.lua
Maths = {}

function Maths.add(a, b)
    return a + b
end

function Maths.square(x)
    return x * x
end

return Maths
```

#### `pages/`
- **Purpose**: Separate screen/page modules for multi-screen applications
- **Usage**: Break large applications into manageable page modules
- **Example Files**:
  - `pages/page1.lua` - First screen/page
  - `pages/page2.lua` - Second screen/page
  - `pages/menu.lua` - Menu screen

**Page Module Structure**:
```lua
-- pages/page1.lua
Page1 = {}

function Page1.render(drawPageCounter)
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawText("Page 1", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
    drawPageCounter()
end

-- Optional lifecycle functions
function Page1.update()
    -- Update logic
end

function Page1.enter()
    -- Setup when entering page
end

function Page1.exit()
    -- Cleanup when leaving page
end

return Page1
```

#### `assets/`
- **Purpose**: Game assets, media files, and resources
- **Supported Formats**:
  - **Images**: `.png`, `.bmp`
  - **Audio**: `.wav`, `.mid` (MIDI)
- **Example Files**:
  - `assets/player_sprite.png` - Player character sprite
  - `assets/background.bmp` - Background image
  - `assets/jump_sound.wav` - Sound effect
  - `assets/music.mid` - Background music

**Naming Convention**: Use lowercase with underscores (snake_case)
- ✅ `player_idle.png`
- ✅ `crash_cymbal.wav`
- ❌ `PlayerIdle.png`
- ❌ `Crash-Cymbal.wav`

---

## Module Organization Patterns

### Importing Modules

VMU Pro uses the `import` keyword to load modules:

#### API Imports (Built-in)
```lua
import "api/system"      -- System functions
import "api/display"     -- Graphics and display
import "api/input"       -- Input handling
import "api/sprites"     -- Sprite management
import "api/file"        -- File operations
```

#### Custom Module Imports
```lua
-- Import from libraries directory
import "libraries/maths"
import "libraries/utils"

-- Import from pages directory
import "pages/page1"
import "pages/page2"
```

**Rules**:
- Path is relative to project root
- No `.lua` extension in import path
- Use forward slashes `/` even on Windows
- Import order matters - import dependencies first

### Module Pattern

**Create a module** (libraries/utils.lua):
```lua
-- libraries/utils.lua
Utils = {}

function Utils.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

return Utils  -- Optional but recommended
```

**Use the module** (app.lua):
```lua
import "libraries/utils"

local clamped_value = Utils.clamp(150, 0, 100)  -- Returns 100
```

### Namespace Organization

VMU Pro APIs are accessed through namespaces:

```lua
-- System namespace
vmupro.system.log(vmupro.system.LOG_INFO, "App", "Message")
vmupro.system.delayMs(16)
vmupro.system.getTimeUs()

-- Graphics namespace
vmupro.graphics.clear(vmupro.graphics.BLACK)
vmupro.graphics.drawText("Hello", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
vmupro.graphics.refresh()

-- Input namespace
vmupro.input.read()
vmupro.input.pressed(vmupro.input.A)
vmupro.input.held(vmupro.input.B)

-- Text namespace
vmupro.text.setFont(vmupro.text.FONT_SMALL)
vmupro.text.calcLength("text")
```

---

## Naming Conventions

### Files
- **Lua files**: lowercase with underscores
  - `app.lua`, `page1.lua`, `utils.lua`
- **JSON files**: lowercase with underscores
  - `metadata.json`
- **Image files**: lowercase with underscores
  - `player_sprite.png`, `icon.bmp`
- **Audio files**: lowercase with underscores or hyphens
  - `jump_sound.wav`, `background-music.mid`

### Directories
- **lowercase**: `libraries/`, `pages/`, `assets/`
- **singular or plural**: Either is acceptable, be consistent
  - ✅ `library/` or `libraries/`
  - ✅ `page/` or `pages/`

### Lua Code
- **Functions**: camelCase
  - `initApp()`, `updatePlayer()`, `renderFrame()`
- **Variables**: snake_case
  - `app_running`, `frame_count`, `player_x`
- **Constants**: UPPER_SNAKE_CASE
  - `MAX_PLAYERS`, `SCREEN_WIDTH`
- **Modules**: PascalCase
  - `Maths`, `Utils`, `Page1`

---

## Directory Structure Examples

### Small Project (Single File)

```
my_simple_app/
├── app.lua           # Main application code
├── metadata.json     # Application metadata
├── icon.bmp          # Application icon
├── pack.sh           # Build script (Unix)
├── pack.ps1          # Build script (Windows)
└── README.md         # Documentation
```

**metadata.json**:
```json
{
  "metadata_version": 1,
  "app_name": "Simple App",
  "app_author": "Developer",
  "app_version": "1.0.0",
  "app_entry_point": "app.lua",
  "app_mode": 1,
  "app_environment": "lua",
  "icon_transparency": false,
  "resources": ["app.lua"]
}
```

### Medium Project (With Libraries)

```
my_game/
├── app.lua                  # Main application
├── metadata.json            # Application metadata
├── icon.bmp                 # Application icon
├── libraries/               # Reusable modules
│   ├── physics.lua
│   ├── collision.lua
│   └── utils.lua
├── assets/                  # Game assets
│   ├── player.png
│   ├── enemy.png
│   ├── jump.wav
│   └── music.mid
├── pack.sh
├── pack.ps1
└── README.md
```

**metadata.json**:
```json
{
  "metadata_version": 1,
  "app_name": "My Game",
  "app_author": "Developer",
  "app_version": "1.0.0",
  "app_entry_point": "app.lua",
  "app_mode": 1,
  "app_environment": "lua",
  "icon_transparency": false,
  "resources": [
    "app.lua",
    "libraries",
    "assets"
  ]
}
```

**app.lua**:
```lua
import "api/system"
import "api/display"
import "api/input"
import "api/sprites"
import "libraries/physics"
import "libraries/collision"
import "libraries/utils"

function AppMain()
    -- Initialize
    -- Game loop
    -- Cleanup
    return 0
end
```

### Large Project (Multi-Page Application)

```
my_complex_app/
├── app.lua                  # Main orchestrator
├── metadata.json            # Application metadata
├── icon.bmp                 # Application icon
├── pages/                   # Screen modules
│   ├── page1.lua           # Title screen
│   ├── page2.lua           # Menu
│   ├── page3.lua           # Gameplay
│   ├── page4.lua           # Settings
│   └── page5.lua           # Credits
├── libraries/               # Shared modules
│   ├── maths.lua
│   ├── utils.lua
│   ├── ui.lua
│   └── state_manager.lua
├── assets/                  # Media files
│   ├── images/
│   │   ├── sprites/
│   │   │   ├── player.png
│   │   │   └── enemy.png
│   │   └── backgrounds/
│   │       ├── menu_bg.bmp
│   │       └── game_bg.bmp
│   └── audio/
│       ├── sounds/
│       │   ├── jump.wav
│       │   └── hit.wav
│       └── music/
│           └── theme.mid
├── pack.sh
├── pack.ps1
├── send.sh
├── send.ps1
└── README.md
```

**metadata.json**:
```json
{
  "metadata_version": 1,
  "app_name": "Complex App",
  "app_author": "Developer Team",
  "app_version": "2.1.0",
  "app_entry_point": "app.lua",
  "app_mode": 1,
  "app_environment": "lua",
  "icon_transparency": true,
  "resources": [
    "app.lua",
    "pages",
    "libraries",
    "assets"
  ]
}
```

**app.lua** (orchestrator pattern):
```lua
import "api/system"
import "api/display"
import "api/input"
import "api/sprites"

-- Import all pages
import "pages/page1"
import "pages/page2"
import "pages/page3"
import "pages/page4"
import "pages/page5"

-- Import libraries
import "libraries/utils"
import "libraries/state_manager"

-- Application state
local app_running = true
local current_page = 1
local total_pages = 5

local function update()
    vmupro.input.read()

    -- Page-specific update
    if current_page == 1 then
        Page1.update()
    elseif current_page == 2 then
        Page2.update()
    -- ... etc
    end

    -- Navigation
    if vmupro.input.pressed(vmupro.input.LEFT) and current_page > 1 then
        current_page = current_page - 1
    end
    if vmupro.input.pressed(vmupro.input.RIGHT) and current_page < total_pages then
        current_page = current_page + 1
    end
    if vmupro.input.pressed(vmupro.input.B) then
        app_running = false
    end
end

local function render()
    -- Call page-specific renderer
    if current_page == 1 then
        Page1.render()
    elseif current_page == 2 then
        Page2.render()
    -- ... etc
    end

    vmupro.graphics.refresh()
end

function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Starting")

    while app_running do
        update()
        render()
        vmupro.system.delayMs(16)  -- ~60 FPS
    end

    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Exiting")
    return 0
end
```

---

## Resource Bundling Rules

### What Gets Bundled

The build process bundles **ONLY** files and directories listed in the `resources` array:

```json
{
  "resources": [
    "app.lua",      // Single file
    "libraries",    // Entire directory (recursive)
    "pages",        // Entire directory (recursive)
    "assets"        // Entire directory (recursive)
  ]
}
```

### What Does NOT Get Bundled

These files remain outside the package:
- `pack.sh`, `pack.ps1` - Build scripts
- `send.sh`, `send.ps1` - Deployment scripts
- `README.md` - Documentation
- `.git/` - Version control
- `metadata.json` - Read by build tool but not bundled as-is
- `icon.bmp` - Processed separately
- Any files/directories not in `resources`

### Recursive Bundling

When you include a directory in `resources`:
- All subdirectories are included recursively
- All files in those directories are included
- Directory structure is preserved in the package

Example with `assets` directory:
```
assets/
├── images/
│   ├── player.png       ✅ Bundled
│   └── enemy.png        ✅ Bundled
└── audio/
    ├── jump.wav         ✅ Bundled
    └── music.mid        ✅ Bundled
```

---

## Best Practices

### 1. Project Organization

- **Separate Concerns**: Keep pages, libraries, and assets in separate directories
- **Modular Design**: Break large apps into smaller, focused modules
- **Consistent Naming**: Use consistent file and directory naming conventions
- **Clear Entry Point**: Keep `app.lua` focused on orchestration

### 2. Module Design

```lua
-- ✅ Good: Clear module structure
MyModule = {}

function MyModule.initialize()
    -- Setup
end

function MyModule.update()
    -- Update logic
end

return MyModule
```

```lua
-- ❌ Bad: Global functions, unclear namespace
function doSomething()
    -- This pollutes global namespace
end
```

### 3. Resource Management

- **Include Only Necessary Files**: Don't bloat the package with unused assets
- **Optimize Assets**: Compress images and audio where possible
- **Use Appropriate Formats**: BMP for simple graphics, PNG for sprites, WAV for sound

### 4. metadata.json Maintenance

- **Update Version Numbers**: Follow semantic versioning (MAJOR.MINOR.PATCH)
- **Accurate Resources List**: Keep `resources` array synchronized with project structure
- **Descriptive Names**: Use clear `app_name` and `app_author` fields

### 5. Code Structure

```lua
-- ✅ Good: Organized app.lua structure
import "api/system"
import "api/display"
import "api/input"

-- Constants
local SCREEN_WIDTH = 240
local SCREEN_HEIGHT = 240

-- State variables
local app_running = true

-- Helper functions
local function init_app()
    -- Initialization
end

local function update()
    -- Update logic
end

local function render()
    -- Rendering
end

-- Entry point
function AppMain()
    init_app()

    while app_running do
        update()
        render()
        vmupro.system.delayMs(16)
    end

    return 0
end
```

---

## Common Patterns

### Pattern 1: Simple Single-Screen App

**Structure**:
```
app/
├── app.lua
├── metadata.json
└── icon.bmp
```

**Use Case**: Basic utilities, simple demos, proof-of-concepts

### Pattern 2: Multi-Page Application

**Structure**:
```
app/
├── app.lua
├── metadata.json
├── icon.bmp
└── pages/
    ├── page1.lua
    ├── page2.lua
    └── page3.lua
```

**Use Case**: Menu-driven apps, settings screens, multi-view applications

### Pattern 3: Game with Assets

**Structure**:
```
app/
├── app.lua
├── metadata.json
├── icon.bmp
├── libraries/
│   ├── physics.lua
│   └── collision.lua
└── assets/
    ├── player.png
    ├── enemy.png
    └── jump.wav
```

**Use Case**: Games, interactive applications, media-rich apps

### Pattern 4: Complex Modular Application

**Structure**:
```
app/
├── app.lua
├── metadata.json
├── icon.bmp
├── pages/
│   ├── menu.lua
│   ├── game.lua
│   └── settings.lua
├── libraries/
│   ├── game_engine.lua
│   ├── ui_framework.lua
│   └── save_system.lua
└── assets/
    ├── sprites/
    ├── backgrounds/
    └── audio/
```

**Use Case**: Full-featured applications, complete games, professional tools

---

## Quick Reference Checklist

Before packaging your VMU Pro application, ensure:

- ✅ `app.lua` exists in root with `AppMain()` function
- ✅ `metadata.json` exists with all required fields
- ✅ `icon.bmp` exists in root
- ✅ All imported modules are listed in `resources` array
- ✅ File and directory names follow conventions
- ✅ No hardcoded paths (use relative paths)
- ✅ Version number is updated in `metadata.json`
- ✅ App has been tested with `app_mode: 1`
- ✅ All required API imports are present
- ✅ Assets are in supported formats (PNG, BMP, WAV, MID)

---

## Example: Complete Minimal Project

**app.lua**:
```lua
import "api/system"
import "api/display"
import "api/input"

local app_running = true

function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Starting")

    while app_running do
        vmupro.input.read()

        if vmupro.input.pressed(vmupro.input.B) then
            app_running = false
        end

        vmupro.graphics.clear(vmupro.graphics.BLACK)
        vmupro.graphics.drawText("Hello VMU Pro!", 50, 110, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        vmupro.graphics.refresh()

        vmupro.system.delayMs(16)
    end

    return 0
end
```

**metadata.json**:
```json
{
  "metadata_version": 1,
  "app_name": "Minimal App",
  "app_author": "Developer",
  "app_version": "1.0.0",
  "app_entry_point": "app.lua",
  "app_mode": 1,
  "app_environment": "lua",
  "icon_transparency": false,
  "resources": ["app.lua"]
}
```

**icon.bmp**: 48x48 pixel BMP file

---

## Summary

This document establishes the standard project structure for VMU Pro SDK applications. Following these conventions ensures:

1. **Consistency** across VMU Pro projects
2. **Maintainability** through organized code structure
3. **Proper Packaging** with correct resource bundling
4. **Best Practices** for Lua module organization
5. **Clear Documentation** for onboarding new developers

Refer to the official examples (`hello_world` and `nested_example`) for working implementations of these patterns.
