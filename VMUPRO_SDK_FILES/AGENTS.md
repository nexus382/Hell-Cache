<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# VMUPRO_SDK_FILES

## Purpose
Complete VMU Pro SDK distribution including API documentation, examples, tools, and comprehensive reference materials for developing VMU Pro applications in Lua.

## Key Files

| File | Description |
|------|-------------|
| `README.md` | SDK quick start guide and overview |
| `CLAUDE.md` | Complete SDK API reference for Claude Code (verified accurate) |
| `VMU_PRO_SDK_COMPLETE_REFERENCE.md` | Comprehensive SDK documentation |
| `LICENSE` | SDK license information |
| `VERSION` | SDK version number |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `docs/` | API documentation, guides, and reference materials (see `docs/AGENTS.md`) |
| `examples/` | Example applications demonstrating SDK features (see `examples/AGENTS.md`) |
| `sdk/` | SDK source code and API implementations (see `sdk/AGENTS.md`) |
| `tools/` | Build and deployment tools including packager (see `tools/AGENTS.md`) |
| `__MACOSX/` | Mac artifact directory (can be ignored on non-Mac systems) |

## For AI Agents

### Working In This Directory

**This is the VMU Pro SDK - NOT the game project.**

When working with VMU Pro SDK files:
- **DO NOT modify SDK files** - they are reference material
- **COPY examples** to the project root and adapt them
- **REFER to CLAUDE.md** for accurate API documentation
- **CHECK docs/api/** for detailed API reference

**Critical SDK Rules (from CLAUDE.md)**:
1. Entry point: `function AppMain()` returning a number
2. Import syntax: `import "api/system"` NOT `require()`
3. Audio lifecycle: `startListenMode()` → use → `exitListenMode()`
4. Sprite cleanup: Always call `vmupro.sprite.removeAll()`
5. Sound update: Call `vmupro.sound.update()` every frame
6. Input: Call `vmupro.input.read()` once per frame
7. Display: Clear once, draw all, refresh once per frame

**File Organization Rules**:
- NEVER save files to project root - use subdirectories
- Required files: `app.lua`, `metadata.json`, `icon.bmp` (76x76 BMP)
- Optional directories: `libraries/`, `pages/`, `assets/`

### Documentation Structure

**CLAUDE.md** - Primary reference for AI agents:
- Complete API reference (100% verified accurate)
- Code patterns and best practices
- Common pitfalls and solutions
- Packaging and deployment instructions

**docs/api/** - Detailed API documentation:
- `system.md` - System utilities (logging, timing, memory)
- `display.md` - Graphics rendering (drawing, text, colors)
- `input.md` - Button input handling
- `audio.md` - Audio system and sample playback
- `file.md` - File system operations
- `sprites.md` - Sprite management and animation

**docs/guides/** - Programming guides:
- Getting started tutorials
- Best practices
- Performance optimization

**examples/** - Example applications:
- `hello_world/` - Minimal app example
- `nested_example/` - Multi-page app structure

### Testing Requirements

When testing SDK-based applications:
- Verify import syntax (`import "api/..."`)
- Check audio lifecycle (startListenMode/exitListenMode)
- Confirm sprite cleanup (removeAll)
- Test on VMU Pro hardware when possible
- Verify metadata.json format

### Common Patterns

**Entry Point**:
```lua
import "api/system"
import "api/display"
import "api/input"

function AppMain()
    -- Initialization
    local app_running = true

    while app_running do
        vmupro.input.read()

        if vmupro.input.pressed(vmupro.input.B) then
            app_running = false
        end

        vmupro.graphics.clear(vmupro.graphics.BLACK)
        vmupro.graphics.drawText("Hello!", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        vmupro.graphics.refresh()

        vmupro.system.delayMs(16)  -- ~60 FPS
    end

    return 0
end
```

**Display Specs**:
- Resolution: 240x240 pixels
- Color format: RGB565 (16-bit, 65,536 colors)
- Coordinates: (0,0) top-left to (239,239) bottom-right
- Target FPS: 60 FPS (16.67ms per frame)

## Dependencies

### Internal

- `docs/` - API documentation and guides
- `examples/` - Example applications
- `sdk/` - SDK implementation
- `tools/` - Build and deployment tools

### External

- Lua 5.x (VMU Pro uses Lua)
- Python 3.x (for packager tool)

## Related Resources

**In Parent Project**:
- `../app.lua` - Main game using this SDK
- `../SPRITE_PIPELINE.md` - Sprite generation documentation
- `../README.md` - Game-specific documentation

<!-- MANUAL: Custom SDK notes can be added below -->
