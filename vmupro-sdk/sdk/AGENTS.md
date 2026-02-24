# VMU Pro SDK - Core API Reference

<!-- Parent: ../AGENTS.md -->

This directory contains the core VMU Pro LUA SDK API type definitions. These files provide IDE autocomplete support and documentation for developing VMU Pro applications.

**Last Updated:** 2026-02-23

## Overview

The SDK uses a namespace-based API under the global `vmupro` table. All functions are provided by the VMU Pro firmware at runtime - these files are stub definitions for IDE support only and are NOT included in the final .vmupack.

## Directory Structure

```
sdk/
  api/                    # API type definition modules
    __stubs.lua           # Core stubs (AppMain entry point, vmupro.apiVersion)
    audio.lua             # Audio system and sample playback
    debug.lua             # Debug utilities (requires Developer Mode)
    display.lua           # Graphics and drawing functions
    doublebuffer.lua      # Double buffer rendering system
    file.lua              # SD card file system access
    input.lua             # Button and input handling
    instrument.lua        # Instrument voice mapping for MIDI
    log.lua               # Logging API and level constants
    sequence.lua          # MIDI file playback
    sprites.lua           # Sprite and spritesheet management
    synth.lua             # Synthesizer and waveform generation
    system.lua            # System utilities (time, memory, brightness)
    text.lua              # Text rendering and font management
    utilities.lua         # Additional utility functions
```

## API Namespaces

### vmupro.graphics - Display and Graphics

The primary graphics namespace for rendering to the 240x240 display.

| Function | Description |
|----------|-------------|
| `clear(color)` | Clear display with RGB565 color |
| `refresh()` | Update screen with drawn content |
| `drawText(text, x, y, color, bg_color)` | Draw text string |
| `drawRect(x1, y1, x2, y2, color)` | Draw rectangle outline |
| `drawFillRect(x1, y1, x2, y2, color)` | Draw filled rectangle |
| `drawLine(x1, y1, x2, y2, color)` | Draw line between points |
| `drawCircle(x, y, radius, color)` | Draw circle outline |
| `drawCircleFilled(x, y, radius, color)` | Draw filled circle |
| `drawEllipse(x, y, rx, ry, color)` | Draw ellipse outline |
| `drawEllipseFilled(x, y, rx, ry, color)` | Draw filled ellipse |
| `drawPolygon(points, color)` | Draw polygon outline from points array |
| `drawPolygonFilled(points, color)` | Draw filled polygon |
| `floodFill(x, y, fill_color, boundary_color)` | Flood fill from point |
| `getBackFramebuffer()` | Get back framebuffer reference |
| `getFrontFramebuffer()` | Get front framebuffer reference |
| `applyMosaicToScreen(x, y, w, h, size)` | Apply pixelation effect to region |

**Color Constants (RGB565):**
- `vmupro.graphics.BLACK`, `WHITE`, `RED`, `GREEN`, `BLUE`
- `vmupro.graphics.YELLOW`, `ORANGE`, `MAGENTA`, `VIOLET`
- `vmupro.graphics.GREY`, `NAVY`, `YELLOWGREEN`
- `vmupro.graphics.VMUGREEN`, `VMUINK`

### vmupro.sprite - Sprite System

Comprehensive sprite management with collision detection, animation, and effects.

| Function | Description |
|----------|-------------|
| `new(path)` | Load sprite from file (returns SpriteHandle) |
| `newSheet(path)` | Load spritesheet (returns SpritesheetHandle) |
| `draw(sprite, x, y, flags)` | Draw sprite at position |
| `drawScaled(sprite, x, y, sx, sy, flags)` | Draw with scaling |
| `drawTinted(sprite, x, y, color, flags)` | Draw with color tint |
| `drawBlended(sprite, x, y, alpha, flags)` | Draw with alpha transparency |
| `drawBlurred(sprite, x, y, radius, flags)` | Draw with blur effect |
| `drawMosaic(sprite, x, y, size, flags)` | Draw with pixelation |
| `drawFrame(sheet, frame, x, y, flags)` | Draw spritesheet frame (1-based) |
| `free(sprite)` | Release sprite memory |
| `setPosition(sprite, x, y)` / `moveTo()` | Set absolute position |
| `moveBy(sprite, dx, dy)` | Move by offset |
| `getPosition(sprite)` | Get current position |
| `setVisible(sprite, visible)` | Set visibility |
| `setZIndex(sprite, z)` | Set draw order |
| `add(sprite)` | Add to scene for auto-rendering |
| `remove(sprite)` | Remove from scene |
| `removeAll()` | Clear all sprites from scene |
| `drawAll()` | Draw scene sprites in Z-order |
| `playAnimation(sprite, start, end, fps, loop)` | Start animation |
| `stopAnimation(sprite)` | Stop animation |
| `pauseAnimation(sprite)` | Pause animation |
| `resumeAnimation(sprite)` | Resume animation |
| `isAnimating(sprite)` | Check if animating |
| `updateAnimations()` | Advance all animations (call per frame) |
| `setCollisionRect(sprite, x, y, w, h)` | Set collision bounds |
| `getCollideBounds(sprite)` | Get world-space collision bounds |
| `setGroups(sprite, groups)` | Set collision group membership |
| `setCollidesWithGroups(sprite, groups)` | Set collision targets |
| `checkCollisions(sprite, goalX, goalY)` | Test movement collision |
| `moveWithCollisions(sprite, goalX, goalY)` | Move with collision response |
| `overlappingSprites(sprite)` | Get overlapping sprites |
| `setTag(sprite, tag)` | Set 8-bit identifier |
| `setUserdata(sprite, data)` | Store arbitrary Lua data |
| `setUpdateFunction(sprite, callback)` | Set per-frame callback |
| `setDrawFunction(sprite, callback)` | Set custom draw callback |

**Flip Constants:**
- `vmupro.sprite.kImageUnflipped` = 0
- `vmupro.sprite.kImageFlippedX` = 1 (horizontal)
- `vmupro.sprite.kImageFlippedY` = 2 (vertical)
- `vmupro.sprite.kImageFlippedXY` = 3 (both)

### vmupro.input - Button Input

Handle user input from D-pad, face buttons, and system buttons.

| Function | Description |
|----------|-------------|
| `read()` | Update button state (call once per frame) |
| `pressed(button)` | Check if button just pressed (one-shot) |
| `held(button)` | Check if button currently held |
| `released(button)` | Check if button just released |
| `anythingHeld()` | Check if any button held |
| `confirmPressed()` | Check A button pressed |
| `confirmReleased()` | Check A button released |
| `dismissPressed()` | Check B button pressed |
| `dismissReleased()` | Check B button released |

**Button Constants:**
- `vmupro.input.UP`, `DOWN`, `LEFT`, `RIGHT` (D-pad)
- `vmupro.input.A`, `B` (Face buttons)
- `vmupro.input.POWER`, `MODE`, `FUNCTION` (System buttons)

### vmupro.text - Text Rendering

Font selection and text measurement.

| Function | Description |
|----------|-------------|
| `setFont(font_id)` | Set current font |
| `calcLength(text)` | Get text width in pixels |
| `getFontInfo()` | Get current font information |

**Font Constants:**
- `vmupro.text.FONT_TINY_6x8` (smallest)
- `vmupro.text.FONT_MONO_7x13` (monospace)
- `vmupro.text.FONT_QUANTICO_*` (15x16 to 32x37)
- `vmupro.text.FONT_GABARITO_*` (18x18, 22x24)
- `vmupro.text.FONT_OPEN_SANS_*` (15x18, 21x24)
- `vmupro.text.FONT_SMALL`, `FONT_MEDIUM`, `FONT_LARGE`, `FONT_DEFAULT` (aliases)

### vmupro.audio - Audio Control

Global audio system control.

| Function | Description |
|----------|-------------|
| `getGlobalVolume()` | Get volume (0-10) |
| `setGlobalVolume(volume)` | Set volume (0-10) |
| `startListenMode()` | Enable audio output |
| `exitListenMode()` | Disable audio output |
| `clearRingBuffer()` | Clear audio buffer |
| `getRingbufferFillState()` | Get buffer fill level |

**Mode Constants:**
- `vmupro.audio.MONO` = 0
- `vmupro.audio.STEREO` = 1

### vmupro.sound - Sound System

Synthesizers, samples, sequences, and instruments.

#### vmupro.sound.synth - Synthesizers

| Function | Description |
|----------|-------------|
| `new(waveform)` | Create synth (max 16 simultaneous) |
| `setAttack(synth, time)` | Set ADSR attack (seconds) |
| `setDecay(synth, time)` | Set ADSR decay |
| `setSustain(synth, level)` | Set ADSR sustain (0-1) |
| `setRelease(synth, time)` | Set ADSR release |
| `setVolume(synth, left, right)` | Set stereo volume |
| `playNote(synth, freq, vel, len)` | Play note at frequency |
| `playMIDINote(synth, note, vel, len)` | Play MIDI note (60 = C4) |
| `noteOff(synth)` | Release note |
| `stop(synth)` | Stop immediately |
| `isPlaying(synth)` | Check if playing |
| `setWaveform(synth, waveform)` | Change waveform |
| `free(synth)` | Release synth |

**Waveform Constants:**
- `vmupro.sound.kWaveSquare` = 0
- `vmupro.sound.kWaveTriangle` = 1
- `vmupro.sound.kWaveSine` = 2
- `vmupro.sound.kWaveNoise` = 3
- `vmupro.sound.kWaveSawtooth` = 4
- `vmupro.sound.kWavePOPhase` = 5
- `vmupro.sound.kWavePODigital` = 6
- `vmupro.sound.kWavePOVosim` = 7

#### vmupro.sound.sample - Sample Playback

| Function | Description |
|----------|-------------|
| `new(path)` | Load WAV from SD card |
| `play(sample, repeatCount, callback)` | Play sample |
| `stop(sample)` | Stop playback |
| `setVolume(sample, left, right)` | Set stereo volume |
| `setRate(sample, rate)` | Set playback rate |
| `isPlaying(sample)` | Check if playing |
| `free(sample)` | Release sample |

#### vmupro.sound.sequence - MIDI Playback

| Function | Description |
|----------|-------------|
| `new(path)` | Load MIDI file |
| `getTrackCount(seq)` | Get number of tracks |
| `getTrackAtIndex(seq, index)` | Get track (1-based) |
| `setTrackInstrument(seq, trackIndex, inst)` | Assign instrument |
| `setProgramCallback(seq, callback)` | Dynamic program changes |
| `play(seq)` | Start playback |
| `stop(seq)` | Stop playback |
| `setLooping(seq, shouldLoop)` | Enable looping |
| `isPlaying(seq)` | Check if playing |
| `free(seq)` | Release sequence |

#### vmupro.sound.instrument - Voice Mapping

| Function | Description |
|----------|-------------|
| `new()` | Create instrument |
| `addVoice(inst, voice, midiNote)` | Map synth/sample to note (nil = all notes) |
| `free(inst)` | Release instrument |

#### vmupro.sound.update() - Audio Tick

**CRITICAL:** Call `vmupro.sound.update()` every frame for audio to work.

### vmupro.file - File System

SD card file access (restricted to `/sdcard/` prefix).

| Function | Description |
|----------|-------------|
| `exists(path)` | Check file exists |
| `folderExists(path)` | Check folder exists |
| `read(path)` | Read file contents |
| `write(path, data)` | Write file contents |
| `createFile(path)` | Create empty file |
| `createFolder(path)` | Create directory |
| `deleteFile(path)` | Delete file |
| `deleteFolder(path)` | Delete empty folder |
| `getSize(path)` | Get file size in bytes |

### vmupro.system - System Utilities

System control, timing, and memory management.

| Function | Description |
|----------|-------------|
| `log(level, tag, message)` | Log message |
| `setLogLevel(level)` | Set log filter |
| `sleep(ms)` | Sleep milliseconds |
| `delayMs(ms)` | Delay milliseconds |
| `delayUs(us)` | Delay microseconds |
| `getTimeUs()` | Get time since boot (microseconds) |
| `getGlobalBrightness()` | Get brightness (1-10) |
| `setGlobalBrightness(level)` | Set brightness (1-10) |
| `getMemoryUsage()` | Get current memory bytes |
| `getMemoryLimit()` | Get max memory bytes |
| `getLargestFreeBlock()` | Get largest contiguous free block |
| `getLastBlittedFBSide()` | Get framebuffer side for double buffering |

**Log Level Constants:**
- `vmupro.system.LOG_NONE` = 0
- `vmupro.system.LOG_ERROR` = 1
- `vmupro.system.LOG_WARN` = 2
- `vmupro.system.LOG_INFO` = 3
- `vmupro.system.LOG_DEBUG` = 4

### vmupro.debug - Debug Utilities

Debugging tools (requires Developer Mode).

| Function | Description |
|----------|-------------|
| `backtrace()` | Log Lua stack trace |

## Application Entry Point

Every VMU Pro application must define an `AppMain()` function:

```lua
function AppMain()
    -- Initialize your application
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Starting...")
    return 0  -- Return 0 for success
end
```

## Usage in Applications

Import API modules for IDE support:

```lua
import "api/system"
import "api/display"
import "api/input"
import "api/sprites"
import "api/audio"

function AppMain()
    -- Graphics example
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawText("Hello VMU!", 10, 10, vmupro.graphics.WHITE)
    vmupro.graphics.refresh()

    -- Input example
    vmupro.input.read()
    if vmupro.input.pressed(vmupro.input.A) then
        vmupro.system.log(vmupro.system.LOG_INFO, "Input", "A pressed!")
    end

    return 0
end
```

## Important Notes

1. **IDE Support Only**: These stub files are for development. Actual implementations come from firmware.
2. **Runtime Loading**: Use `import "api/module"` for IDE support. Do not include in .vmupack.
3. **Audio Update**: Call `vmupro.sound.update()` every frame for audio to work.
4. **Sprite Cleanup**: Call `vmupro.sprite.removeAll()` in exit/cleanup functions.
5. **File Access**: All file paths must start with `/sdcard/`.
6. **Display Resolution**: 240x240 pixels, RGB565 color format.
7. **Sprite Formats**: PNG (RGBA8888 with alpha) or BMP (RGB565 with color key).

## Related Documentation

- [../AGENTS.md](../AGENTS.md) - Parent SDK documentation
- [api/README.md](api/README.md) - API usage guide
