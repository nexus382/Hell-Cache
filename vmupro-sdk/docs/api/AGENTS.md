# VMU Pro SDK API Reference - AGENTS.md

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

This directory contains the complete API reference documentation for the VMU Pro Lua SDK. Each file documents a specific API module with detailed function signatures, parameters, return values, and code examples.

**Key Characteristics:**
- **Format:** Markdown files with consistent structure
- **Audience:** Lua developers building VMU Pro applications
- **Coverage:** All public API functions, constants, and usage patterns

---

## API Modules

| File | Module | Namespace | Description |
|------|--------|-----------|-------------|
| `display.md` | Graphics | `vmupro.graphics.*` | Drawing primitives, text, colors, display management |
| `sprites.md` | Sprites | `vmupro.sprite.*` | Sprite loading, rendering, animation, collision detection |
| `doublebuffer.md` | Double Buffer | `vmupro.graphics.*` | Flicker-free rendering via double buffering |
| `input.md` | Input | `vmupro.input.*` | Button reading and event handling |
| `audio.md` | Audio | `vmupro.audio.*`, `vmupro.sound.*` | Volume control, sample playback, streaming audio |
| `synth.md` | Synthesizer | `vmupro.sound.synth.*` | Real-time audio synthesis, waveforms, ADSR envelopes |
| `instrument.md` | Instruments | `vmupro.sound.instrument.*` | Voice mapping for MIDI playback |
| `sequence.md` | MIDI Sequences | `vmupro.sound.sequence.*` | MIDI file loading and playback |
| `file.md` | File System | `vmupro.file.*` | File I/O operations (restricted to /sdcard) |
| `system.md` | System | `vmupro.system.*` | Timing, logging, brightness, memory utilities |
| `debug.md` | Debug | `vmupro.debug.*` | Debugging utilities (requires Developer Mode) |

---

## Module Details

### Graphics (`display.md`)

**Namespace:** `vmupro.graphics.*`

Display and drawing functions for the 240x240 RGB565 display.

**Key Functions:**
- `clear(color)` - Clear display with color
- `refresh()` - Present back buffer to screen
- `drawLine()`, `drawRect()`, `drawCircle()`, `drawEllipse()`, `drawPolygon()` - Primitives
- `drawText(text, x, y, color, bg_color)` - Text rendering
- `floodFill()`, `floodFillTolerance()` - Fill operations
- `setGlobalBrightness()`, `getGlobalBrightness()` - Brightness control

**Constants:** Predefined RGB565 colors (RED, GREEN, BLUE, BLACK, WHITE, etc.)

---

### Sprites (`sprites.md`)

**Namespace:** `vmupro.sprite.*`

Handle-based sprite management for BMP/PNG images.

**Key Functions:**
- `new(path)` - Load sprite from file (returns table with id, width, height)
- `draw(sprite, x, y, flags)` - Draw sprite with flip flags
- `drawScaled(sprite, x, y, scale_x, scale_y, flags)` - Draw with scaling
- `drawTinted(sprite, x, y, tint_color, flags)` - Draw with color tint
- `drawColorAdd(sprite, x, y, add_color, flags)` - Draw with additive color
- `free(sprite)` - Release sprite memory
- `setPosition()`, `getPosition()`, `moveBy()` - Position management
- `add()`, `remove()`, `drawAll()` - Scene management
- `collide()` - Collision detection

**Constants:**
- `kImageUnflipped`, `kImageFlippedX`, `kImageFlippedY`, `kImageFlippedXY` - Flip flags

**Notes:**
- PNG files support full per-pixel alpha (RGBA8888)
- BMP files use RGB565 with transparent color key
- Sprites loaded from embedded vmupack only (not SD card)

---

### Double Buffer (`doublebuffer.md`)

**Namespace:** `vmupro.graphics.*`

Smooth, flicker-free rendering through double buffering.

**Key Functions:**
- `startDoubleBufferRenderer()` - Initialize double buffering
- `stopDoubleBufferRenderer()` - Clean up double buffering
- `pushDoubleBufferFrame()` - Push back buffer to display
- `pauseDoubleBufferRenderer()`, `resumeDoubleBufferRenderer()` - Pause/resume

**Typical Pattern:**
```lua
vmupro.graphics.startDoubleBufferRenderer()
while running do
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    -- render frame
    vmupro.graphics.pushDoubleBufferFrame()
end
vmupro.graphics.stopDoubleBufferRenderer()
```

---

### Input (`input.md`)

**Namespace:** `vmupro.input.*`

Button input handling for the 8 VMU Pro buttons.

**Key Functions:**
- `read()` - Update button states (call once per frame)
- `pressed(button)` - Edge detection: just pressed
- `released(button)` - Edge detection: just released
- `held(button)` - Continuous: currently held
- `anythingHeld()` - Check if any button held
- `confirmPressed()`, `dismissPressed()` - Convenience methods

**Constants:**
- `UP`, `DOWN`, `LEFT`, `RIGHT` - D-pad
- `A`, `B` - Action buttons
- `POWER`, `MODE` - System buttons

---

### Audio (`audio.md`)

**Namespace:** `vmupro.audio.*`, `vmupro.sound.sample.*`

Audio playback and volume control.

**Volume Control:**
- `getGlobalVolume()`, `setGlobalVolume(volume)` - Volume 0-10

**Audio Lifecycle:**
- `startListenMode()` - Initialize audio (REQUIRED before playback)
- `exitListenMode()` - Clean up audio (REQUIRED when done)

**Ring Buffer:**
- `clearRingBuffer()`, `getRingbufferFillState()`
- `addStreamSamples(samples, stereo_mode, applyGlobalVolume)`

**Sound Samples:**
- `vmupro.sound.sample.new(path)` - Load WAV file
- `vmupro.sound.sample.play(sample, repeat_count, callback)` - Play sound
- `vmupro.sound.sample.stop(sample)`, `isPlaying(sample)`, `free(sample)`
- `setVolume(sample, left, right)`, `setRate(sample, rate)`

**Critical:** Call `vmupro.sound.update()` every frame for audio to work.

---

### Synthesizer (`synth.md`)

**Namespace:** `vmupro.sound.synth.*`

Real-time audio synthesis with ADSR envelopes. Max 16 simultaneous synths.

**Waveform Constants:**
- `kWaveSquare`, `kWaveTriangle`, `kWaveSine`, `kWaveNoise`
- `kWaveSawtooth`, `kWavePOPhase`, `kWavePODigital`, `kWavePOVosim`

**Key Functions:**
- `new(waveform)` - Create synth
- `setWaveform(synth, waveform)` - Change waveform
- `setAttack()`, `setDecay()`, `setSustain()`, `setRelease()` - ADSR envelope
- `playNote(synth, freq, velocity, length)` - Play at frequency
- `playMIDINote(synth, midi_note, velocity, length)` - Play MIDI note
- `noteOff(synth)`, `stop(synth)` - Release or stop immediately
- `setVolume(synth, left, right)`, `getVolume(synth)`

**Lifecycle:** Requires `vmupro.audio.startListenMode()` before use.

---

### Instruments (`instrument.md`)

**Namespace:** `vmupro.sound.instrument.*`

Voice mapping for MIDI playback. Max 16 voices per instrument.

**Key Functions:**
- `new()` - Create instrument
- `addVoice(inst, voice, midiNote)` - Map synth/sample to MIDI note
  - `midiNote = nil` for melodic (responds to all notes)
  - `midiNote = number` for drums (specific note mapping)
- `free(inst)` - Release instrument

**Usage Pattern:**
```lua
local inst = vmupro.sound.instrument.new()
vmupro.sound.instrument.addVoice(inst, sample, nil)  -- melodic
vmupro.sound.sequence.setTrackInstrument(seq, 1, inst)
```

---

### MIDI Sequences (`sequence.md`)

**Namespace:** `vmupro.sound.sequence.*`

MIDI file loading and playback.

**Key Functions:**
- `new(path)` - Load MIDI file
- `getTrackCount(seq)`, `getTrackAtIndex(seq, index)` - Track info
- `setTrackInstrument(seq, trackIndex, inst)` - Assign instrument
- `setProgramCallback(seq, callback)` - Dynamic instrument switching
- `play(seq)`, `stop(seq)`, `isPlaying(seq)` - Playback control
- `setLooping(seq, shouldLoop)` - Loop setting
- `free(seq)` - Release sequence

**Critical:** Call `vmupro.sound.update()` every frame for MIDI to advance.

---

### File System (`file.md`)

**Namespace:** `vmupro.file.*`

File I/O operations. **Restricted to `/sdcard` directory only.**

**Key Functions:**
- `read(path)` - Read entire file contents
- `write(path, data)` - Write data to file
- `exists(path)`, `folderExists(path)` - Existence checks
- `createFile(path)`, `createFolder(path)` - Create file/folder
- `getSize(path)` - Get file size in bytes
- `deleteFile(path)`, `deleteFolder(path)` - Delete operations

**Note:** `deleteFolder()` requires folder to be empty first.

---

### System (`system.md`)

**Namespace:** `vmupro.system.*`

Core system utilities.

**Logging:**
- `log(level, tag, message)` - Log message
- Levels: `LOG_ERROR`, `LOG_WARN`, `LOG_INFO`, `LOG_DEBUG`

**Timing:**
- `sleep(ms)`, `delayMs(ms)`, `delayUs(us)` - Delay execution
- `getTimeUs()` - Get time in microseconds since boot

**Display:**
- `getGlobalBrightness()`, `setGlobalBrightness(brightness)` - 0-255

**Memory:**
- `getMemoryUsage()`, `getMemoryLimit()`, `getLargestFreeBlock()`

**Framebuffer:**
- `getLastBlittedFBSide()` - Double buffer tracking

---

### Debug (`debug.md`)

**Namespace:** `vmupro.debug.*`

Debugging utilities. Requires Developer Mode for full output.

**Key Functions:**
- `backtrace()` - Log current Lua stack trace

---

## Common Patterns

### Audio Lifecycle Pattern

All audio usage (samples, synths, MIDI) requires proper lifecycle management:

```lua
function vmupro.load()
    vmupro.audio.startListenMode()
    -- Load sounds/synths here
end

function vmupro.update()
    vmupro.sound.update()  -- CRITICAL: Call every frame
    -- Game logic
end

function vmupro.cleanup()
    -- Free all audio resources
    vmupro.audio.exitListenMode()
end
```

### Game Loop Pattern

```lua
vmupro.graphics.startDoubleBufferRenderer()
local running = true

while running do
    vmupro.input.read()

    -- Handle input
    if vmupro.input.pressed(vmupro.input.A) then
        -- action
    end

    -- Update game state
    update_game()

    -- Render
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    render_game()
    vmupro.graphics.pushDoubleBufferFrame()

    -- Frame timing
    vmupro.system.delayMs(16)  -- ~60 FPS

    if vmupro.input.pressed(vmupro.input.MODE) then
        running = false
    end
end

vmupro.graphics.stopDoubleBufferRenderer()
```

### Resource Cleanup Order

When freeing audio resources, use this order:
1. Stop and free sequences
2. Free instruments
3. Free synths and samples
4. Call `vmupro.audio.exitListenMode()`

---

## For AI Agents

### Finding API Functions

| Looking For | File | Namespace |
|-------------|------|-----------|
| Draw shapes/text | `display.md` | `vmupro.graphics.*` |
| Load/draw images | `sprites.md` | `vmupro.sprite.*` |
| Read buttons | `input.md` | `vmupro.input.*` |
| Play sounds | `audio.md` | `vmupro.sound.sample.*` |
| Synthesize audio | `synth.md` | `vmupro.sound.synth.*` |
| Play MIDI | `sequence.md` + `instrument.md` | `vmupro.sound.*` |
| Read/write files | `file.md` | `vmupro.file.*` |
| Timing/logging | `system.md` | `vmupro.system.*` |

### API Function Documentation Pattern

Each function is documented with:

```markdown
### vmupro.module.functionName(params)

Brief description.

**Parameters:**
- `param` (type): Description

**Returns:**
- `result` (type): Description

**Example:**
```lua
local result = vmupro.module.functionName("example")
```
```

### Important Notes

1. **Audio requires lifecycle management** - Always `startListenMode()` before, `exitListenMode()` after
2. **Sound requires `vmupro.sound.update()`** - Must call every frame
3. **File access is restricted** - Only `/sdcard` directory accessible
4. **Sprites are embedded only** - Load from vmupack, not SD card
5. **Double buffering for smooth graphics** - Use for game loops
6. **Input needs `read()` each frame** - Updates button state

---

## Related Files

| File | Relationship |
|------|--------------|
| `../AGENTS.md` | Parent docs directory with navigation context |
| `../guides/` | Tutorial content using these APIs |
| `../examples/` | Sample applications demonstrating API usage |
| `../../sdk/api/*.lua` | Source API stub files |

---

## See Also

- `../getting-started.md` - Development environment setup
- `../guides/first-app.md` - First application tutorial
- `../examples/hello-world.md` - Hello World example
