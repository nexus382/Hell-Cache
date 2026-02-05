<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# sdk

## Purpose
VMU Pro SDK implementation files including Lua API modules, system libraries, and core functionality.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `api/` | Lua API modules for VMU Pro features (see `api/AGENTS.md`) |

## For AI Agents

### Working In This Directory

**This is the SDK implementation** - DO NOT modify unless fixing bugs.

**SDK Architecture**:
- `api/` contains Lua modules that interface with VMU Pro system
- These modules are imported via `import "api/system"` syntax
- Modules provide the `vmupro.*` namespace used in apps

### Module System

**Import Syntax**:
```lua
import "api/system"    -- System utilities
import "api/display"   -- Graphics/drawing
import "api/input"     -- Button input
import "api/audio"     -- Audio system
import "api/sprites"   -- Sprite management
import "api/file"      -- File operations
```

**DO NOT use `require()`** - not supported by VMU Pro.

### API Modules

**System** (`api/system`):
- Logging (LOG_ERROR, LOG_WARN, LOG_INFO, LOG_DEBUG)
- Timing (getTimeUs, delayMs, delayUs, sleep)
- Display brightness
- Memory usage monitoring

**Display** (`api/display`):
- Drawing primitives (line, rect, circle, ellipse, polygon)
- Text rendering (fixed-width font)
- Fill operations (flood fill)
- Framebuffer access

**Input** (`api/input`):
- Button constants (UP, DOWN, LEFT, RIGHT, POWER, MODE, A, B)
- Input reading and edge detection (pressed, released, held)
- Convenience methods (confirmPressed, dismissPressed)

**Audio** (`api/audio`):
- Volume control
- Listen mode for streaming audio
- Ring buffer management

**Sprites** (`api/sprites`):
- Sprite loading and drawing
- Scaling and effects
- Collision detection
- Animation system
- Scene management

**File** (`api/file`):
- Read/write operations (SD card only)
- Folder operations
- File existence checking

### SDK Version

Current version specified in `../VERSION` file.

## Dependencies

### Internal
- `../docs/api/` - API documentation
- `../examples/` - Code using this SDK

### External
- Lua 5.x runtime
- VMU Pro system libraries

<!-- MANUAL: SDK implementation notes can be added below -->
