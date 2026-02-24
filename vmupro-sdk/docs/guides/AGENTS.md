<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-23 -->

# VMU Pro SDK - Guides Documentation

This directory contains tutorial and how-to guides for developing applications on the VMU Pro platform.

## Guide Index

| Guide | Purpose | Topics Covered |
|-------|---------|----------------|
| [first-app.md](first-app.md) | Build your first VMU Pro application | Project setup, main loop pattern, input handling, file I/O, deployment |
| [graphics-guide.md](graphics-guide.md) | Graphics and rendering | RGB565 colors, drawing primitives, sprites, animations, visual effects |
| [audio-guide.md](audio-guide.md) | Audio programming | Volume control, sample streaming, synthesizers, MIDI playback |
| [file-operations.md](file-operations.md) | File system operations | Read/write files, save games, configuration, asset management |

## Guide Summaries

### Your First App (`first-app.md`)

Step-by-step tutorial for creating a complete "Clicker" game from scratch.

**Key Concepts:**
- Project structure (app.lua, metadata.json, icon.bmp)
- Application lifecycle: `init()` -> main loop -> `cleanup()`
- Input handling with `vmupro.input.pressed()`
- Graphics rendering with clear/draw/refresh pattern
- File persistence for high scores
- Frame rate control with `vmupro.system.delayMs()`

**Entry Point:** Beginners should start here before exploring other guides.

---

### Graphics Programming Guide (`graphics-guide.md`)

Comprehensive graphics programming reference for the 240x240 RGB565 display.

**Display Specifications:**
- Resolution: 240x240 pixels
- Color: 16-bit RGB565 (65,536 colors)
- Double-buffered frame buffer

**Drawing Primitives:**
- `drawLine(x1, y1, x2, y2, color)` - Lines (basic pixel primitive)
- `drawRect(x1, y1, x2, y2, color)` - Rectangle outlines
- `drawFillRect(x1, y1, x2, y2, color)` - Filled rectangles
- `drawText(text, x, y, color, bg_color)` - Text rendering

**Sprite System:**
- `vmupro.sprite.new()` - Load sprites from BMP/PNG
- `vmupro.sprite.newSheet()` - Load spritesheets for animation
- Visual effects: tinting, blending, mosaic, blur
- Z-ordering with scene management

**Color Constants:**
```lua
vmupro.graphics.RED, GREEN, BLUE, WHITE, BLACK
vmupro.graphics.ORANGE, YELLOW, YELLOWGREEN
vmupro.graphics.NAVY, VIOLET, MAGENTA, GREY
vmupro.graphics.VMUGREEN, VMUINK
```

---

### Audio Programming Guide (`audio-guide.md`)

Complete audio system documentation including real-time synthesis and MIDI.

**Audio Systems:**
1. **Volume Control**: `getGlobalVolume()` / `setGlobalVolume(level)`
2. **Listen Mode**: Required for sample playback and synths
3. **Sample Streaming**: Push int16_t audio samples to ring buffer
4. **Sample Playback**: Load and play WAV files with `vmupro.sound.sample`
5. **Synthesizers**: Real-time procedural audio with ADSR envelopes
6. **MIDI Playback**: Sequence playback with custom instruments

**Key Functions:**
- `vmupro.audio.startListenMode()` / `exitListenMode()` - Audio session management
- `vmupro.sound.sample.new()`, `play()`, `setVolume()`, `setRate()` - Sample control
- `vmupro.sound.synth.new()`, `playNote()`, ADSR methods - Synthesis
- `vmupro.sound.update()` - Required every frame for MIDI/synth

**Limits:**
- Maximum 16 synths simultaneously
- Maximum 16 voices per instrument

---

### File Operations Guide (`file-operations.md`)

File system access within the sandboxed `/sdcard` directory.

**File Operations:**
- `vmupro.file.exists(path)` - Check file existence
- `vmupro.file.read(path)` - Read entire file
- `vmupro.file.write(path, data)` - Write data (replaces content)
- `vmupro.file.createFile(path)` - Create empty file
- `vmupro.file.deleteFile(path)` - Delete file
- `vmupro.file.getSize(path)` - Get file size in bytes

**Directory Operations:**
- `vmupro.file.folderExists(path)` - Check directory existence
- `vmupro.file.createFolder(path)` - Create directory
- `vmupro.file.deleteFolder(path)` - Delete empty directory

**Common Patterns:**
- Save game systems with state serialization
- Configuration managers with default values
- Asset caching for game resources
- Log file rotation

**Security:** All operations restricted to `/sdcard/` directory only.

---

## Quick Reference

### Typical Application Structure

```lua
-- 1. Initialization
local function init()
    -- Load resources, read config
    return true
end

-- 2. Input handling
local function handle_input()
    vmupro.input.read()
    -- Process button presses
    return true  -- false to exit
end

-- 3. Game logic
local function update()
    -- Update game state
end

-- 4. Rendering
local function render()
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    -- Draw everything
    vmupro.graphics.refresh()
end

-- 5. Cleanup
local function cleanup()
    -- Free resources, save state
end

-- Main loop
init()
while handle_input() do
    update()
    render()
    vmupro.system.delayMs(16)  -- ~60 FPS
end
cleanup()
```

### Input Button Constants

```lua
vmupro.input.A, vmupro.input.B
vmupro.input.DPAD_UP, vmupro.input.DPAD_DOWN
vmupro.input.DPAD_LEFT, vmupro.input.DPAD_RIGHT
vmupro.input.MODE  -- Start/Mode button
```

### Frame Rate Control

```lua
vmupro.system.delayMs(16)   -- ~60 FPS
vmupro.system.delayMs(33)   -- ~30 FPS
vmupro.system.getTimeUs()   -- Timestamp for animations
```

---

## Related Documentation

- **API Reference**: `../api/` - Detailed API documentation
- **Examples**: `../examples/` - Sample applications
- **Main Docs**: `../AGENTS.md` - SDK documentation index
