# VMU Pro SDK - Nested Example (Comprehensive Test Suite)

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

This is the comprehensive SDK test suite for the VMU Pro Lua SDK. It demonstrates advanced project organization with modular folders, page-based navigation, and complete API coverage across 39 test pages.

---

## Project Structure

```
nested_example/
├── app.lua                  # Main entry point with page router
├── metadata.json            # Application metadata (declares all resources)
├── icon.bmp                 # 76x76 application icon
├── TEST_PLAN.md             # Documentation of all test pages
├── pack.sh / pack.ps1       # Packaging scripts (Linux/Windows)
├── send.sh / send.ps1       # Deployment scripts (Linux/Windows)
├── libraries/               # Custom utility modules
│   ├── maths.lua            # Math helpers (add, multiply, square)
│   └── utils.lua            # General utilities (clamp, lerp)
├── pages/                   # Test pages (page1.lua - page39.lua)
│   ├── page1.lua            # Lines & Rectangles
│   ├── page2.lua            # Circles & Ellipses
│   ├── page3.lua            # Polygons
│   ├── page4.lua            # Text Rendering & Fonts
│   ├── page5.lua            # Color Constants
│   ├── page6.lua            # Button States
│   ├── page7.lua            # Timing Functions
│   ├── page8.lua            # Logging & Info
│   ├── page9.lua            # Brightness Control
│   ├── page10.lua           # File I/O
│   ├── page11.lua           # Audio Stream Control
│   ├── page12.lua           # Flood Fill
│   ├── page13.lua           # Double Buffer Renderer
│   ├── page14.lua           # Sprites (Handle-Based)
│   ├── page15.lua           # Layers Management
│   ├── page16.lua           # Layers Blending
│   ├── page17.lua           # Double Buffering Control
│   ├── page18.lua           # Palette Effects
│   ├── page19.lua           # Mosaic & Color Window
│   ├── page20.lua           # Performance: Primitives
│   ├── page21.lua           # Performance: Circles
│   ├── page22.lua           # Performance: Text/Polygons
│   ├── page23.lua           # Sprite Animation
│   ├── page24-39.lua        # Advanced audio/synth features
│   └── page39.lua           # MIDI Sequence Playback
└── assets/                  # Media resources
    ├── clarinet.wav         # Clarinet audio sample
    ├── crash_cymbal.wav     # Crash cymbal sample
    ├── french_horns.wav     # French horn sample
    ├── game-complete.wav    # Game complete sound
    ├── player-losing-or-failing.wav  # Failure sound
    ├── ride_cymbal.wav      # Ride cymbal sample
    ├── string_ensemble.wav  # String ensemble sample
    ├── timpani.wav          # Timpani drum sample
    ├── winning-a-coin.wav   # Coin sound
    ├── settlers.mid         # MIDI sequence file
    ├── mask_guy-table-32-32.png  # Sprite sheet
    ├── mask_guy_idle.png    # Idle sprite
    └── mask_guy_idle_old.bmp # Legacy sprite
```

---

## Test Pages Coverage

### Basic Graphics (Pages 1-5)

| Page | Topic | Functions Tested |
|------|-------|------------------|
| 1 | Lines & Rectangles | `drawLine`, `drawRect`, `drawFillRect`, `clear` |
| 2 | Circles & Ellipses | `drawCircle`, `drawCircleFilled`, `drawEllipse`, `drawEllipseFilled` |
| 3 | Polygons | `drawPolygon`, `drawPolygonFilled` |
| 4 | Text & Fonts | `setFont`, `drawText`, `calcLength`, `getFontInfo` |
| 5 | Color Constants | All RGB565 color constants |

### Input & System (Pages 6-9)

| Page | Topic | Functions Tested |
|------|-------|------------------|
| 6 | Button States | `read`, `pressed`, `released`, `held`, `anythingHeld` |
| 7 | Timing | `getTimeUs`, `delayMs`, `delayUs`, `sleep` |
| 8 | Logging | `log`, `setLogLevel`, `getMemoryUsage`, `apiVersion` |
| 9 | Brightness | `getGlobalBrightness`, `setGlobalBrightness` |

### File I/O & Audio (Pages 10-12)

| Page | Topic | Functions Tested |
|------|-------|------------------|
| 10 | File Operations | `exists`, `folderExists`, `createFolder`, `read`, `write`, `getSize` |
| 11 | Audio Stream | `startListenMode`, `exitListenMode`, `addStreamSamples`, `getRingbufferFillState` |
| 12 | Flood Fill | `floodFill`, `floodFillTolerance` |

### Advanced Graphics (Pages 13-19)

| Page | Topic | Functions Tested |
|------|-------|------------------|
| 13 | Double Buffer Renderer | `startDoubleBufferRenderer`, `pushDoubleBufferFrame` |
| 14 | Sprites | `sprite.new`, `sprite.draw`, `sprite.free`, `collisionCheck` |
| 15 | Layers Management | `layerCreate`, `layerDestroy`, `layerSetPriority`, `layerSetAlpha` |
| 16 | Layers Blending | `blendLayersAdditive`, `blendLayersMultiply`, `blendLayersScreen` |
| 17 | Double Buffering | `pauseDoubleBufferRenderer`, `resumeDoubleBufferRenderer` |
| 18 | Palette Effects | `animatePaletteRange`, `interpolatePalette` |
| 19 | Mosaic & Color Window | `applyMosaicToScreen`, `setColorWindow`, `clearColorWindow` |

### Performance Benchmarks (Pages 20-22)

| Page | Topic | Benchmarks |
|------|-------|------------|
| 20 | Basic Primitives | `clear`, `drawLine`, `drawRect`, `drawFillRect` timing |
| 21 | Circles & Ellipses | `drawCircle`, `drawCircleFilled`, ellipse operations |
| 22 | Text & Polygons | `drawText`, `drawPolygon`, `drawPolygonFilled` timing |

### Advanced Features (Pages 23-39)

| Page | Topic | Functions Tested |
|------|-------|------------------|
| 23-26 | Sprite Animation | Animated sprite rendering |
| 27-30 | Synthesizer | Sound synthesis features |
| 31-38 | Advanced Audio | Sound sequencing, instruments |
| 39 | MIDI Playback | `sequence.new`, `sequence.play`, `sequence.setProgramCallback` |

---

## For AI Agents

### Page Module Pattern

Each test page follows this structure:

```lua
-- pages/pageN.lua
PageN = {}

-- Optional: Called when navigating to page
function PageN.enter()
    -- Initialize resources (load sprites, start audio, etc.)
end

-- Optional: Called when leaving page
function PageN.exit()
    -- Cleanup resources (free sprites, stop audio, etc.)
end

-- Optional: Called each frame for logic
function PageN.update()
    -- Handle input, update animations
end

-- Required: Render the page
function PageN.render(drawPageCounter)
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    -- Draw page content
    drawPageCounter()  -- Shows "Page X/39" in top-right
end
```

### Navigation System

The main `app.lua` handles page navigation:

| Button | Action |
|--------|--------|
| LEFT | Previous page (with cleanup/enter lifecycle) |
| RIGHT | Next page (with cleanup/enter lifecycle) |
| B | Exit application |

**Special cases:**
- Page 6 (button test): Requires MODE button held for navigation
- Pages 11-39: Call `exit()` on navigation for proper resource cleanup

### Frame Timing

The app maintains 60 FPS with microsecond precision:

```lua
local target_frame_time_us = 16666  -- 60 FPS (16.666ms)

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

### Double Buffering

Pages 13-39 use double buffering for smooth rendering:

```lua
-- In page render function:
if not db_running then
    vmupro.graphics.startDoubleBufferRenderer()
    db_running = true
end
-- Drawing operations...
-- Note: Do NOT call vmupro.graphics.refresh()
-- Main loop will call pushDoubleBufferFrame() instead
```

### Resource Management

Pages that allocate resources must implement proper cleanup:

```lua
function PageN.enter()
    -- Allocate: sprites, audio, layers
    my_sprite = vmupro.sprite.new("assets/image")
end

function PageN.exit()
    -- Free in reverse order
    if my_sprite then
        vmupro.sprite.free(my_sprite)
        my_sprite = nil
    end
end
```

### Import Pattern

```lua
-- SDK APIs (built-in)
import "api/system"
import "api/display"
import "api/input"
import "api/sprites"

-- Local modules (relative paths, no .lua extension)
import "pages/page1"
import "libraries/maths"
```

---

## Libraries

### maths.lua

Simple math utility module.

```lua
Maths.add(a, b)      -- Returns a + b
Maths.multiply(a, b) -- Returns a * b
Maths.square(x)      -- Returns x * x
```

### utils.lua

General utility functions.

```lua
Utils.clamp(value, min, max)  -- Constrain value to range
Utils.lerp(a, b, t)           -- Linear interpolation
```

---

## Assets

| File | Type | Usage |
|------|------|-------|
| `*.wav` | Audio samples | Synthesizer instruments, page 39 |
| `settlers.mid` | MIDI sequence | Background music, page 39 |
| `mask_guy*.png/bmp` | Sprites | Sprite rendering tests |

---

## Key Files

| File | Purpose |
|------|---------|
| `app.lua` | Main entry with 39-page router, FPS tracking, navigation |
| `TEST_PLAN.md` | Detailed documentation of all test pages |
| `metadata.json` | Declares libraries, pages, assets as resources |
| `pages/page*.lua` | Individual test pages (39 total) |
| `libraries/*.lua` | Utility modules |

---

## See Also

- `../AGENTS.md` - Parent examples documentation
- `../hello_world/` - Minimal application template
- `../../docs/` - SDK documentation
