<!-- Parent: ../AGENTS.md -->
# VMU Pro SDK - API Type Definitions

**Generated:** 2026-02-17

## Purpose

This directory contains Lua type definition files (API stubs) that provide IDE support, autocomplete, and inline documentation for VMU Pro SDK developers. These files define the complete API surface available at runtime on VMU Pro firmware.

**Important Notes:**
- These are **stub definitions only** - they provide IDE support during development
- Actual function implementations are provided by VMU Pro firmware at runtime
- Stub files are NOT included in the final .vmupack package
- Use `import "api/module_name"` to access these definitions in your code

## Directory Structure

```
vmupro-sdk/sdk/api/
├── __stubs.lua           # Root stub definitions
├── audio.lua             # Audio system API
├── debug.lua             # Debug utilities API
├── display.lua           # Display/graphics API
├── doublebuffer.lua      # Double-buffering API
├── file.lua              # File system operations API
├── input.lua             # Input handling API
├── instrument.lua        # Audio instrument API
├── log.lua               # Logging API
├── sequence.lua          # Audio sequence API
├── sprites.lua           # Sprite rendering API
├── synth.lua             # Sound synthesis API
├── system.lua            # System utilities API
├── text.lua              # Text rendering API
└── utilities.lua         # Utility functions API
```

## Key Files

| File | Purpose | Key Namespaces |
|------|---------|----------------|
| **`__stubs.lua`** | Root stub definitions and namespace initialization | `vmupro` |
| **`audio.lua`** | Audio system control - volume, channels, playback | `vmupro.audio.*` |
| **`debug.lua`** | Debug utilities for development | `vmupro.debug.*` |
| **`display.lua`** | Display graphics primitives - clear, draw, refresh | `vmupro.graphics.*` |
| **`doublebuffer.lua`** | Double-buffering for flicker-free rendering | `vmupro.doublebuffer.*` |
| **`file.lua`** | File system read/write operations | `vmupro.file.*` |
| **`input.lua`** | Button/joystick input polling | `vmupro.input.*` |
| **`instrument.lua`** | Musical instrument definitions and control | `vmupro.instrument.*` |
| **`log.lua`** | Logging system with severity levels | `vmupro.log.*` |
| **`sequence.lua`** | Audio sequencing for music/sound effects | `vmupro.sequence.*` |
| **`sprites.lua`** | Sprite rendering, collision, animation | `vmupro.sprites.*` |
| **`synth.lua`** | Sound synthesis - waveforms, envelopes | `vmupro.synth.*` |
| **`system.lua`** | System utilities - timing, logging, delays | `vmupro.system.*` |
| **`text.lua`** | Text rendering and font management | `vmupro.text.*` |
| **`utilities.lua`** | General utility functions | `vmupro.utils.*` |

## Usage Pattern

```lua
-- Import API modules for type definitions and autocomplete
import "api/system"
import "api/display"
import "api/input"

-- Use namespaced functions (implemented by firmware at runtime)
function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Hello World!")
    vmupro.graphics.clear()
    vmupro.graphics.drawText(0, 0, "Hello!")
    vmupro.graphics.refresh()
    return 0
end
```

## Documentation References

For detailed API documentation, see:
- **Main SDK docs:** `/vmupro-sdk/docs/`
- **Getting started:** `/vmupro-sdk/docs/getting-started.md`
- **API reference:** `/vmupro-sdk/docs/api/` (individual module docs)
- **Examples:** `/vmupro-sdk/examples/`

## Related Documentation

- **SDK Overview:** `/vmupro-sdk/docs/lua-sdk-overview.md`
- **Tools Guide:** `/vmupro-sdk/docs/tools/development.md`
- **Package Tool:** `/vmupro-sdk/docs/tools/packer.md`
