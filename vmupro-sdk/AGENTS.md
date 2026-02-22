<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-17 -->

# vmupro-sdk

## Purpose
VMU Pro Lua SDK - A comprehensive Lua-based software development kit for creating applications on the VMU Pro platform (a handheld virtual memory unit device with 240x240 display). Provides graphics, input, audio, file system, and utility APIs for embedded game development.

## Version
**Current Version:** 1.2.0 (see VERSION file)

## Key Files

| File | Description |
|------|-------------|
| `README.md` | Comprehensive SDK documentation with quick start, API reference, examples |
| `VERSION` | Current SDK version (1.2.0) |
| `LICENSE` | Copyright (c) 2025 8BitMods. All rights reserved |
| `.gitignore` | Git ignore patterns |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `sdk/api/` | Lua API type definitions and stubs for IDE support (see below) |
| `docs/` | Complete documentation - getting started guides, API reference, tutorials |
| `examples/` | Example applications demonstrating SDK features |
| `tools/packer/` | Python tools for packaging and deploying applications |

## SDK API Modules (`sdk/api/`)

| File | Description |
|------|-------------|
| `__stubs.lua` | Auto-completion stubs for IDE support |
| `system.lua` | System functions: logging (`vmupro.system.log`), timing (`vmupro.system.getTimeUs`, `vmupro.system.delayMs`), memory monitoring |
| `display.lua` | Display functions: clear, drawText, drawLine, drawRect, drawCircle, refresh, color constants |
| `doublebuffer.lua` | Double buffering for flicker-free rendering |
| `text.lua` | Text and font functions: setFont, calcLength, font constants |
| `input.lua` | Button input: read, pressed, held, released (A, B, X, Y, UP, DOWN, LEFT, RIGHT, START, SELECT) |
| `audio.lua` | Audio functions: setGlobalVolume, getGlobalVolume, startListenMode, exitListenMode |
| `synth.lua` | Synthesizer functions: new, setWaveType, setAttack, setDecay, setSustain, setRelease, setVolume, play, free |
| `instrument.lua` | Instrument functions for audio sequencing |
| `sequence.lua` | Audio sequencing functions |
| `file.lua` | File system operations: readFileComplete, writeFileComplete, fileExists, listFiles, createDirectory (restricted to `/sdcard`) |
| `sprites.lua` | Sprite functions: new, draw, drawScaled, setCollision, batch operations |
| `debug.lua` | Debug utilities and helpers |
| `utilities.lua` | Additional utility functions |
| `log.lua` | Logging utilities |

## Documentation (`docs/`)

| File/Directory | Description |
|----------------|-------------|
| `SUMMARY.md` | Documentation table of contents |
| `README.md` | Documentation introduction |
| `getting-started.md` | Setup guide, prerequisites, first application tutorial |
| `lua-sdk-overview.md` | Lua environment overview |
| `api/display.md` | Display API reference |
| `api/sprites.md` | Sprites API reference |
| `api/doublebuffer.md` | Double buffer API reference |
| `api/audio.md` | Audio API reference |
| `api/synth.md` | Synth API reference |
| `api/instrument.md` | Instrument API reference |
| `api/sequence.md` | Sequence API reference |
| `api/input.md` | Input API reference |
| `api/file.md` | File system API reference |
| `api/system.md` | System API reference |
| `api/debug.md` | Debug API reference |
| `guides/first-app.md` | First application tutorial |
| `guides/graphics-guide.md` | Graphics programming guide |
| `guides/audio-guide.md` | Audio programming guide |
| `guides/file-operations.md` | File operations guide |

## Examples (`examples/`)

| Directory | Description |
|-----------|-------------|
| `hello_world/` | Minimal "Hello World" application |
| `nested_example/` | Demonstrates module organization with `require()` and folder structures |

## Tools (`tools/packer/`)

| File | Description |
|------|-------------|
| `packer.py` | Main packaging tool - creates `.vmupack` files from projects |
| `send.py` | Deployment tool - uploads applications to VMU Pro via USB/serial |

## For AI Agents

### Understanding the VMU Pro Platform

**Hardware Constraints:**
- Display: 240x240 pixels, RGB565 little-endian color format
- Embedded environment with limited memory
- Real-time requirements (target ~60 FPS with 16ms frame delay)

**Lua Environment:**
- Lua 5.4+ interpreter
- Module system via `require()`
- File access restricted to `/sdcard` directory
- All API functions provided by VMU Pro firmware (not these stub files)

### Application Structure

**Standard Project Layout:**
```
my_app/
├── app.lua           # Main entry point, must contain AppMain() function
├── metadata.json     # App metadata (name, author, version, entry point, resources)
├── icon.bmp         # 76x76 BMP application icon
├── libraries/       # Optional: custom Lua modules
│   └── utils.lua
└── assets/          # Optional: sprites, sounds, etc.
```

**metadata.json Structure:**
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
  "resources": ["app.lua", "libraries", "assets"]
}
```

### Module System

**Loading Modules:**
```lua
-- Standard pattern
local utils = require("libraries.utils")
local helper = require("libraries.helper")
```

**Creating Modules:**
```lua
-- libraries/utils.lua
local utils = {}

function utils.clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

return utils
```

### Common SDK Patterns

**Main Application Loop:**
```lua
import "api/system"
import "api/display"
import "api/input"

local running = true

function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Starting...")

    while running do
        -- Input handling
        vmupro.input.read()
        if vmupro.input.pressed(vmupro.input.B) then
            running = false
        end

        -- Update game state
        update()

        -- Render
        vmupro.graphics.clear(vmupro.graphics.BLACK)
        render()
        vmupro.graphics.refresh()

        -- Frame rate control (~60 FPS)
        vmupro.system.delayMs(16)
    end

    return 0
end
```

**Color Constants (RGB565 Little-Endian):**
```lua
COLOR_BLACK = 0x0000
COLOR_WHITE = 0xFFFF
COLOR_RED = 0x00F8
COLOR_GREEN = 0xE007
COLOR_BLUE = 0x1F00
-- See display.lua for full list
```

**Sprite Loading and Drawing:**
```lua
-- Load sprite (assets/sprites/player.png must be in resources)
local player_sprite = vmupro.sprite.new("assets/sprites/player")

-- Draw at position
vmupro.sprite.draw(player_sprite, x, y)

-- Draw scaled
vmupro.sprite.drawScaled(player_sprite, x, y, scale_x, scale_y)
```

**Synth-based Audio (recommended over sample-based):**
```lua
vmupro.audio.startListenMode()

local synth = vmupro.sound.synth.new(vmupro.sound.kWaveNoise)
vmupro.sound.synth.setAttack(synth, 0.01)
vmupro.sound.synth.setDecay(synth, 0.1)
vmupro.sound.synth.setSustain(synth, 0.2)
vmupro.sound.synth.setRelease(synth, 0.1)
vmupro.sound.synth.setVolume(synth, 0.5, 0.5)
vmupro.sound.synth.play(synth)

-- Cleanup
vmupro.sound.synth.free(synth)
vmupro.audio.exitListenMode()
```

### Packaging Applications

**Using packer.py:**
```bash
python tools/packer/packer.py \
  --projectdir /path/to/project \
  --appname output_name \
  --meta metadata.json \
  --sdkversion 1.2.0 \
  --icon icon.bmp \
  [--debug true]
```

Output: `output_name.vmupack` file

**Deploying to VMU Pro:**
```bash
python tools/packer/send.py \
  --func send \
  --localfile app.vmupack \
  --remotefile apps/app.vmupack \
  --comport COM3  # Windows: COM3, macOS: /dev/tty.usbserial-xxx
```

Or manually copy `.vmupack` to SD card `apps/` folder.

### Best Practices

1. **Error Handling**: Check return values from API functions
2. **Resource Cleanup**: Free sprites and audio resources when done
3. **Performance**: Use efficient algorithms, avoid excessive temporary objects in loops
4. **Memory**: Monitor with `vmupro.system.getMemoryUsage()`
5. **Module Design**: Create small, focused modules for reusability
6. **Frame Rate**: Use `vmupro.system.delayMs(16)` for ~60 FPS

### Debugging

- Use `vmupro.system.log(vmupro.system.LOG_DEBUG, "tag", "message")` for runtime logging
- Enable `--debug true` when packaging for debug files
- Check VMU Pro device logs for runtime errors

### Dependencies

**External:**
- Python 3.7+ (for packer/send tools)
- PIL/Pillow (Python image library)
- Lua 5.4+ (for local testing, optional)

**Runtime:**
- VMU Pro firmware provides all API implementations
- Type stub files are for IDE support only, not included in `.vmupack`

### Known Platform Issues (from parent project context)

**Crash Bugs to Avoid:**
- `math.atan2()` can crash - use safe alternatives or implement custom `safeAtan2()`
- `math.random()` can crash - use deterministic alternatives for game logic
- Sample-based audio can crash - prefer synth-based audio generation

**Safe Atan2 Implementation:**
```lua
local function safeAtan2(y, x)
    if x == 0 then
        if y > 0 then return 1.5708
        elseif y < 0 then return -1.5708
        else return 0 end
    end
    local angle = math.atan(y / x)
    if x < 0 then angle = angle + 3.14159 end
    return angle
end
```

## Additional Resources

- VMU Pro Developer Documentation: https://developer.vmu.pro/
- See parent AGENTS.md (`../AGENTS.md`) for project context using this SDK
