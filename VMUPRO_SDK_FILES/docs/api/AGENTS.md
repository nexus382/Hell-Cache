<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# api

## Purpose
Complete API reference documentation for all VMU Pro SDK modules. Each module has comprehensive function signatures, parameter descriptions, return values, and usage examples.

## Key Files

| File | Description |
|------|-------------|
| `system.md` | System utilities: logging, timing, memory, brightness |
| `display.md` | Graphics rendering: drawing primitives, text, framebuffer |
| `input.md` | Button input: reading, edge detection, state checking |
| `audio.md` | Audio system: volume control, listen mode, streaming |
| `file.md` | File system: read/write, folder operations (SD card only) |
| `sprites.md` | Sprite management: loading, drawing, animation, collision |

## For AI Agents

### Working In This Directory

**This is API reference documentation** - DO NOT modify.

**Primary AI Reference**: `../../CLAUDE.md` contains all this information in an AI-optimized format, verified 100% accurate.

### Module Documentation Structure

Each API module follows this structure:

**Overview**:
- Module purpose and capabilities
- Import syntax
- Namespace usage

**Functions**:
- Function signature
- Parameter descriptions
- Return value types
- Usage examples
- Notes/warnings

**Constants**:
- Constant names and values
- Usage context

### Quick Reference

**vmupro.system** (`system.md`):
```lua
vmupro.system.log(level, tag, message)  -- Logging
vmupro.system.getTimeUs()               -- Microseconds since boot
vmupro.system.delayMs(ms)               -- Delay
vmupro.system.getMemoryUsage()          -- Bytes used
```

**vmupro.graphics** (`display.md`):
```lua
vmupro.graphics.clear(color)            -- Clear screen
vmupro.graphics.drawLine(x1, y1, x2, y2, color)
vmupro.graphics.drawRect(x1, y1, x2, y2, color)
vmupro.graphics.drawFillRect(x1, y1, x2, y2, color)
vmupro.graphics.drawText(text, x, y, color, bg_color)
vmupro.graphics.refresh()               -- Present frame
```

**vmupro.input** (`input.md`):
```lua
vmupro.input.read()                     -- Call ONCE per frame
vmupro.input.pressed(button)            -- Just pressed
vmupro.input.released(button)           -- Just released
vmupro.input.held(button)               -- Currently held
```

**vmupro.audio** (`audio.md`):
```lua
vmupro.audio.startListenMode()          -- Enable audio
vmupro.audio.exitListenMode()           -- Disable audio
vmupro.audio.getGlobalVolume()          -- 0-10
vmupro.audio.setGlobalVolume(vol)       -- 0-10
```

**vmupro.sound.sample** (`audio.md`):
```lua
local sound = vmupro.sound.sample.new("path")
vmupro.sound.sample.play(sound, repeat, callback)
vmupro.sound.sample.setVolume(sound, left, right)
vmupro.sound.sample.free(sound)
vmupro.sound.update()                   -- Call every frame
```

**vmupro.sprite** (`sprites.md`):
```lua
local sprite = vmupro.sprite.new("path")
vmupro.sprite.draw(sprite, x, y, flags)
vmupro.sprite.drawScaled(sprite, x, y, sx, sy, flags)
vmupro.sprite.add(sprite)               -- Auto-render
vmupro.sprite.remove(sprite)
vmupro.sprite.removeAll()               -- CRITICAL: Cleanup
```

**vmupro.file** (`file.md`):
```lua
vmupro.file.read("/sdcard/file.txt")
vmupro.file.write("/sdcard/file.txt", data)
vmupro.file.exists("/sdcard/file.txt")
vmupro.file.getSize("/sdcard/file.txt")
```

### Common Patterns

**Frame Loop**:
```lua
while running do
    vmupro.input.read()              -- First

    -- Handle input
    if vmupro.input.pressed(vmupro.input.A) then
        -- Do something
    end

    vmupro.graphics.clear(vmupro.graphics.BLACK)
    -- Draw
    vmupro.graphics.refresh()

    vmupro.sound.update()            -- For audio

    vmupro.system.delayMs(16)        -- ~60 FPS
end
```

## Dependencies

### Internal
- `../../CLAUDE.md` - AI-optimized reference (verified accurate)
- `../getting-started.md` - Setup guide
- `../../sdk/api/` - Module implementations

### External
- Lua 5.x reference

<!-- MANUAL: API-specific notes can be added below -->
