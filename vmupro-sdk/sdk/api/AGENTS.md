# VMU Pro SDK - API Stub Files

<!-- Parent: ../AGENTS.md -->

This directory contains LUA type definition stub files for IDE support and documentation. These files provide autocomplete, type hints, and documentation for the VMU Pro SDK API in your editor.

**Last Updated:** 2026-02-23

## Purpose

- **IDE Support Only**: These stubs enable autocomplete and inline documentation in Lua-aware editors
- **Not Included in Packages**: These files are NOT packaged into .vmupack files
- **Runtime Implementations**: Actual function implementations are provided by VMU Pro firmware at runtime

## File Inventory

### Core Stubs

| File | Namespace | Description |
|------|-----------|-------------|
| `__stubs.lua` | `vmupro` | Core stubs: `vmupro.apiVersion()`, `AppMain()` entry point |
| `system.lua` | `vmupro.system` | System utilities: logging, timing, memory, brightness |
| `utilities.lua` | `vmupro.system` | Additional utility functions (sleepMs, getTimeUs) |
| `log.lua` | `vmupro.system` | Logging API with level constants |
| `debug.lua` | `vmupro.debug` | Debug utilities (requires Developer Mode) |

### Graphics and Display

| File | Namespace | Description |
|------|-----------|-------------|
| `display.lua` | `vmupro.graphics` | Graphics primitives: clear, refresh, shapes, text, colors |
| `doublebuffer.lua` | `vmupro.graphics` | Double buffer rendering system for smooth animation |
| `text.lua` | `vmupro.text` | Font selection and text measurement |
| `sprites.lua` | `vmupro.sprite` | Sprite loading, animation, collision detection, effects |

### Input

| File | Namespace | Description |
|------|-----------|-------------|
| `input.lua` | `vmupro.input` | Button handling: D-pad, face buttons, system buttons |

### Audio System

| File | Namespace | Description |
|------|-----------|-------------|
| `audio.lua` | `vmupro.audio`, `vmupro.sound` | Audio control, volume, listen mode, sample playback |
| `synth.lua` | `vmupro.sound.synth` | Synthesizer creation and waveform generation |
| `instrument.lua` | `vmupro.sound.instrument` | Voice mapping for MIDI note-to-sound assignment |
| `sequence.lua` | `vmupro.sound.sequence` | MIDI file loading and playback |

### File System

| File | Namespace | Description |
|------|-----------|-------------|
| `file.lua` | `vmupro.file` | SD card file operations (restricted to /sdcard/) |

### Documentation

| File | Description |
|------|-------------|
| `README.md` | API usage guide and overview |
| `mainpage.md` | Documentation landing page |

## Namespace Summary

All SDK functions are organized under the global `vmupro` table:

```
vmupro
  |-- apiVersion()           # SDK version string
  |-- system                 # System utilities
  |     |-- log()
  |     |-- setLogLevel()
  |     |-- sleep(), delayMs(), delayUs()
  |     |-- getTimeUs()
  |     |-- getGlobalBrightness(), setGlobalBrightness()
  |     |-- getMemoryUsage(), getMemoryLimit(), getLargestFreeBlock()
  |     |-- getLastBlittedFBSide()
  |-- graphics               # Display and graphics
  |     |-- clear(), refresh()
  |     |-- drawText(), drawRect(), drawFillRect()
  |     |-- drawLine(), drawCircle(), drawEllipse()
  |     |-- drawPolygon(), floodFill()
  |     |-- applyMosaicToScreen()
  |     |-- startDoubleBufferRenderer(), stopDoubleBufferRenderer()
  |     |-- pushDoubleBufferFrame()
  |     |-- [Color constants]
  |-- text                   # Font management
  |     |-- setFont(), calcLength(), getFontInfo()
  |     |-- [Font constants]
  |-- input                  # Button input
  |     |-- read(), pressed(), held(), released()
  |     |-- [Button constants]
  |-- sprite                 # Sprite system
  |     |-- new(), newSheet(), draw(), drawScaled(), drawTinted()
  |     |-- drawBlended(), drawBlurred(), drawMosaic()
  |     |-- Animation functions
  |     |-- Collision functions
  |     |-- [Flip constants]
  |-- audio                  # Audio control
  |     |-- getGlobalVolume(), setGlobalVolume()
  |     |-- startListenMode(), exitListenMode()
  |-- sound                  # Sound system
  |     |-- update()         # CRITICAL: call every frame
  |     |-- synth            # Synthesizers
  |     |-- sample           # Sample playback
  |     |-- sequence         # MIDI playback
  |     |-- instrument       # Voice mapping
  |     |-- [Waveform constants]
  |-- file                   # File system
  |     |-- exists(), folderExists()
  |     |-- read(), write()
  |     |-- createFile(), createFolder()
  |     |-- deleteFile(), deleteFolder()
  |     |-- getSize()
  |-- debug                  # Debug utilities
        |-- backtrace()
```

## File Sizes

| File | Size | Function Count |
|------|------|----------------|
| `sprites.lua` | 65.6 KB | Largest - extensive sprite system |
| `display.lua` | 11.3 KB | Graphics primitives |
| `synth.lua` | 8.5 KB | Synthesizer functions |
| `audio.lua` | 7.8 KB | Audio control |
| `file.lua` | 5.3 KB | File system |
| `sequence.lua` | 6.5 KB | MIDI playback |
| `system.lua` | 5.8 KB | System utilities |
| `input.lua` | 4.8 KB | Button handling |
| `instrument.lua` | 2.3 KB | Voice mapping |
| `doublebuffer.lua` | 2.3 KB | Double buffering |
| `text.lua` | 2.9 KB | Font functions |
| `utilities.lua` | 2.9 KB | Utility functions |
| `debug.lua` | 0.9 KB | Debug functions |
| `log.lua` | 1.4 KB | Logging |
| `__stubs.lua` | 0.8 KB | Core stubs |

## Usage Pattern

```lua
-- Import API modules for IDE autocomplete support
import "api/system"
import "api/display"
import "api/input"
import "api/sprites"
import "api/audio"

function AppMain()
    -- IDE will now show autocomplete for all vmupro.* functions
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawText("Hello", 10, 10, vmupro.graphics.WHITE)
    vmupro.graphics.refresh()

    return 0
end
```

## Related Documentation

- [../AGENTS.md](../AGENTS.md) - Full SDK API reference with all function signatures
- [README.md](README.md) - API usage guide for developers
