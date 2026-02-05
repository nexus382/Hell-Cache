# VMU Pro SDK - Complete API Reference

**Version**: 1.0.0
**Date**: 2025-01-16
**Author**: 8BitMods

This document provides a comprehensive reference for all VMU Pro SDK functions, constants, and usage patterns extracted from official SDK API files.

---

## Table of Contents

1. [System Functions (vmupro.system)](#system-functions)
2. [Display/Graphics (vmupro.graphics)](#displaygraphics)
3. [Input Handling (vmupro.input)](#input-handling)
4. [Audio System (vmupro.audio)](#audio-system)
5. [File System (vmupro.file)](#file-system)
6. [Sprite System (vmupro.sprite)](#sprite-system)
7. [Text Rendering (vmupro.text)](#text-rendering)
8. [Common Usage Patterns](#common-usage-patterns)
9. [Common Mistakes to Avoid](#common-mistakes-to-avoid)

---

## System Functions

**Namespace**: `vmupro.system`
**Import**: `import "api/system"`

### Logging Functions

#### `vmupro.system.log(level, tag, message)`
Log a message with specified level.

**Parameters**:
- `level` (number): Log level constant (LOG_ERROR=0, LOG_WARN=1, LOG_INFO=2, LOG_DEBUG=3)
- `tag` (string): Category/tag for the log message
- `message` (string): Message to log

**Examples**:
```lua
vmupro.system.log(vmupro.system.LOG_ERROR, "Audio", "Failed to load sound")
vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Player scored 100")
vmupro.system.log(vmupro.system.LOG_DEBUG, "System", "Memory: " .. vmupro.system.getMemoryUsage())
```

#### `vmupro.system.setLogLevel(level)`
Set the logging level filter.

**Parameters**:
- `level` (number): Minimum log level to display (0-3)

**Examples**:
```lua
vmupro.system.setLogLevel(vmupro.system.LOG_ERROR)  -- Only errors
vmupro.system.setLogLevel(vmupro.system.LOG_DEBUG)  -- Everything
```

### Timing Functions

#### `vmupro.system.getTimeUs()`
Get current time in microseconds since system boot.

**Returns**: (number) Current time in microseconds (double-precision float)

**Example**:
```lua
local start = vmupro.system.getTimeUs()
-- ... do work ...
local elapsed = vmupro.system.getTimeUs() - start
vmupro.system.log(vmupro.system.LOG_DEBUG, "Perf", "Took " .. elapsed .. " us")
```

#### `vmupro.system.sleep(ms)`
Sleep/delay for specified milliseconds.

**Parameters**:
- `ms` (number): Milliseconds to sleep

**Example**:
```lua
vmupro.system.sleep(100)  -- Sleep for 100ms
```

#### `vmupro.system.delayMs(ms)`
Delay for specified milliseconds.

**Parameters**:
- `ms` (number): Milliseconds to delay

**Example**:
```lua
vmupro.system.delayMs(16)  -- Delay one frame (~60 FPS)
```

#### `vmupro.system.delayUs(us)`
Delay for specified microseconds.

**Parameters**:
- `us` (number): Microseconds to delay

**Example**:
```lua
vmupro.system.delayUs(1000)  -- Delay 1ms
```

### Display Brightness

#### `vmupro.system.getGlobalBrightness()`
Get current global brightness level.

**Returns**: (number) Brightness level (1-10)

**Example**:
```lua
local brightness = vmupro.system.getGlobalBrightness()
vmupro.system.log(vmupro.system.LOG_INFO, "Display", "Brightness: " .. brightness)
```

#### `vmupro.system.setGlobalBrightness(brightness)`
Set global brightness level.

**Parameters**:
- `brightness` (number): Brightness level (1-10)

**Example**:
```lua
vmupro.system.setGlobalBrightness(5)  -- 50% brightness
vmupro.system.setGlobalBrightness(10) -- Maximum brightness
```

### Memory Management

#### `vmupro.system.getMemoryUsage()`
Get current memory usage in bytes.

**Returns**: (number) Current memory usage in bytes

**Example**:
```lua
local usage = vmupro.system.getMemoryUsage()
vmupro.system.log(vmupro.system.LOG_INFO, "Memory", "Using " .. usage .. " bytes")
```

#### `vmupro.system.getMemoryLimit()`
Get maximum memory limit in bytes.

**Returns**: (number) Maximum memory limit in bytes

**Example**:
```lua
local limit = vmupro.system.getMemoryLimit()
local usage = vmupro.system.getMemoryUsage()
local percent = (usage / limit) * 100
vmupro.system.log(vmupro.system.LOG_INFO, "Memory", percent .. "% used")
```

#### `vmupro.system.getLargestFreeBlock()`
Get largest contiguous free memory block.

**Returns**: (number) Size of largest contiguous free block in bytes

**Example**:
```lua
-- Check if there's enough memory for a large sound sample
local required = 50000  -- 50KB
local largest = vmupro.system.getLargestFreeBlock()
if largest >= required then
    sound = vmupro.sound.sample.new("large_sound")
else
    vmupro.system.log(vmupro.system.LOG_ERROR, "Memory", "Not enough contiguous memory")
end
```

### Framebuffer

#### `vmupro.system.getLastBlittedFBSide()`
Get last blitted framebuffer side (for double buffering).

**Returns**: (number) Framebuffer side identifier

**Example**:
```lua
local fb_side = vmupro.system.getLastBlittedFBSide()
vmupro.system.log(vmupro.system.LOG_DEBUG, "Graphics", "FB side: " .. fb_side)
```

### Log Level Constants

```lua
vmupro.system.LOG_ERROR = 0   -- Error messages only
vmupro.system.LOG_WARN = 1    -- Warnings and errors
vmupro.system.LOG_INFO = 2    -- Info, warnings, errors
vmupro.system.LOG_DEBUG = 3   -- All messages including debug
```

---

## Display/Graphics

**Namespace**: `vmupro.graphics`
**Import**: `import "api/display"`

### Display Management

#### `vmupro.graphics.clear(color)`
Clear the display with a specific color.

**Parameters**:
- `color` (number, optional): RGB565 color value (defaults to black 0x0000)

**Examples**:
```lua
vmupro.graphics.clear()                              -- Clear to black
vmupro.graphics.clear(0xFFFF)                        -- Clear to white
vmupro.graphics.clear(vmupro.graphics.RED)           -- Clear to red
```

#### `vmupro.graphics.refresh()`
Refresh the display to show all drawing operations.

**Example**:
```lua
-- Draw everything first
vmupro.graphics.drawRect(10, 10, 50, 50, vmupro.graphics.WHITE)
vmupro.graphics.drawText("Hello", 10, 60, vmupro.graphics.WHITE)
-- Then present to screen
vmupro.graphics.refresh()
```

### Drawing Primitives

#### `vmupro.graphics.drawLine(x1, y1, x2, y2, color)`
Draw a line between two points.

**Parameters**:
- `x1, y1` (number): Start coordinates
- `x2, y2` (number): End coordinates
- `color` (number): RGB565 color value

**Example**:
```lua
vmupro.graphics.drawLine(0, 0, 100, 100, vmupro.graphics.WHITE)
```

#### `vmupro.graphics.drawRect(x1, y1, x2, y2, color)`
Draw a rectangle outline.

**Parameters**:
- `x1, y1` (number): First corner coordinates
- `x2, y2` (number): Opposite corner coordinates
- `color` (number): RGB565 color value

**Example**:
```lua
vmupro.graphics.drawRect(10, 10, 60, 40, vmupro.graphics.WHITE)
```

#### `vmupro.graphics.drawFillRect(x1, y1, x2, y2, color)`
Draw a filled rectangle.

**Parameters**:
- `x1, y1` (number): First corner coordinates
- `x2, y2` (number): Opposite corner coordinates
- `color` (number): RGB565 color value

**Example**:
```lua
vmupro.graphics.drawFillRect(10, 10, 60, 40, vmupro.graphics.RED)
```

#### `vmupro.graphics.drawCircle(x, y, radius, color)`
Draw a circle outline.

**Parameters**:
- `x, y` (number): Center coordinates
- `radius` (number): Circle radius
- `color` (number): RGB565 color value

**Example**:
```lua
vmupro.graphics.drawCircle(120, 120, 50, vmupro.graphics.WHITE)
```

#### `vmupro.graphics.drawCircleFilled(x, y, radius, color)`
Draw a filled circle.

**Parameters**:
- `x, y` (number): Center coordinates
- `radius` (number): Circle radius
- `color` (number): RGB565 color value

**Example**:
```lua
vmupro.graphics.drawCircleFilled(120, 120, 50, vmupro.graphics.BLUE)
```

#### `vmupro.graphics.drawEllipse(x, y, rx, ry, color)`
Draw an ellipse outline.

**Parameters**:
- `x, y` (number): Center coordinates
- `rx` (number): Horizontal radius
- `ry` (number): Vertical radius
- `color` (number): RGB565 color value

**Example**:
```lua
vmupro.graphics.drawEllipse(120, 120, 60, 40, vmupro.graphics.GREEN)
```

#### `vmupro.graphics.drawEllipseFilled(x, y, rx, ry, color)`
Draw a filled ellipse.

**Parameters**:
- `x, y` (number): Center coordinates
- `rx` (number): Horizontal radius
- `ry` (number): Vertical radius
- `color` (number): RGB565 color value

**Example**:
```lua
vmupro.graphics.drawEllipseFilled(120, 120, 60, 40, vmupro.graphics.YELLOW)
```

#### `vmupro.graphics.drawPolygon(points, color)`
Draw a polygon outline from array of points.

**Parameters**:
- `points` (table): Array of {x, y} coordinate pairs
- `color` (number): RGB565 color value

**Example**:
```lua
-- Triangle
vmupro.graphics.drawPolygon(
    {{50, 20}, {20, 80}, {80, 80}},
    vmupro.graphics.RED
)
```

#### `vmupro.graphics.drawPolygonFilled(points, color)`
Draw a filled polygon from array of points.

**Parameters**:
- `points` (table): Array of {x, y} coordinate pairs
- `color` (number): RGB565 color value

**Example**:
```lua
-- Filled triangle
vmupro.graphics.drawPolygonFilled(
    {{50, 20}, {20, 80}, {80, 80}},
    vmupro.graphics.RED
)
```

### Text Rendering

#### `vmupro.graphics.drawText(text, x, y, color, bg_color)`
Draw text on the display.

**Parameters**:
- `text` (string): Text to display
- `x, y` (number): Text position
- `color` (number): RGB565 text color
- `bg_color` (number, optional): RGB565 background color (defaults to black)

**Examples**:
```lua
vmupro.graphics.drawText("Hello World", 10, 10, vmupro.graphics.WHITE)
vmupro.graphics.drawText("Score: 100", 10, 30, vmupro.graphics.YELLOW, vmupro.graphics.BLACK)
```

### Fill Operations

#### `vmupro.graphics.floodFill(x, y, fill_color, boundary_color)`
Perform flood fill from starting point.

**Parameters**:
- `x, y` (number): Starting coordinates
- `fill_color` (number): RGB565 color to fill with
- `boundary_color` (number): RGB565 boundary color to stop at

**Example**:
```lua
vmupro.graphics.floodFill(50, 50, vmupro.graphics.GREEN, vmupro.graphics.BLACK)
```

#### `vmupro.graphics.floodFillTolerance(x, y, fill_color, tolerance)`
Perform flood fill with color tolerance.

**Parameters**:
- `x, y` (number): Starting coordinates
- `fill_color` (number): RGB565 color to fill with
- `tolerance` (number): Color tolerance for matching

**Example**:
```lua
vmupro.graphics.floodFillTolerance(50, 50, vmupro.graphics.GREEN, 10)
```

### Special Effects

#### `vmupro.graphics.applyMosaicToScreen(x, y, width, height, mosaic_size)`
Apply mosaic/pixelation effect to screen region.

**Parameters**:
- `x, y` (number): Top-left corner of region
- `width, height` (number): Region dimensions
- `mosaic_size` (number): Size of mosaic blocks (1 = no effect, larger = more pixelated)

**Examples**:
```lua
vmupro.graphics.applyMosaicToScreen(0, 0, 240, 240, 8)  -- Full screen pixelation
vmupro.graphics.applyMosaicToScreen(50, 50, 100, 100, 4)  -- Region pixelation
```

### Framebuffer Functions

#### `vmupro.graphics.getBackFramebuffer()`
Get reference to back framebuffer.

**Returns**: (userdata) Back framebuffer reference

**Example**:
```lua
local back_fb = vmupro.graphics.getBackFramebuffer()
```

#### `vmupro.graphics.getFrontFramebuffer()`
Get reference to front framebuffer.

**Returns**: (userdata) Front framebuffer reference

**Example**:
```lua
local front_fb = vmupro.graphics.getFrontFramebuffer()
```

#### `vmupro.graphics.getBackBuffer()`
Get reference to back buffer.

**Returns**: (userdata) Back buffer reference

**Example**:
```lua
local back_buffer = vmupro.graphics.getBackBuffer()
```

### Color Constants (RGB565)

```lua
vmupro.graphics.RED = 0xF800           -- Red
vmupro.graphics.ORANGE = 0xFBA0        -- Orange
vmupro.graphics.YELLOW = 0xFF80        -- Yellow
vmupro.graphics.YELLOWGREEN = 0x7F80   -- Yellow-green
vmupro.graphics.GREEN = 0x0500         -- Green
vmupro.graphics.BLUE = 0x045F          -- Blue
vmupro.graphics.NAVY = 0x000C          -- Navy blue
vmupro.graphics.VIOLET = 0x781F        -- Violet
vmupro.graphics.MAGENTA = 0x780D       -- Magenta
vmupro.graphics.GREY = 0xB5B6          -- Grey
vmupro.graphics.BLACK = 0x0000         -- Black
vmupro.graphics.WHITE = 0xFFFF         -- White
vmupro.graphics.VMUGREEN = 0x6CD2      -- VMU Pro green
vmupro.graphics.VMUINK = 0x288A        -- VMU Pro ink color
```

---

## Input Handling

**Namespace**: `vmupro.input`
**Import**: `import "api/input"`

### Core Input Functions

#### `vmupro.input.read()`
Update button state (call once per frame).

**Example**:
```lua
function vmupro.update()
    vmupro.input.read()  -- MUST call first

    if vmupro.input.pressed(vmupro.input.A) then
        -- Handle A button
    end
end
```

#### `vmupro.input.pressed(button)`
Check if button was just pressed (one-shot edge detection).

**Parameters**:
- `button` (number): Button constant

**Returns**: (boolean) true if button was just pressed

**Examples**:
```lua
if vmupro.input.pressed(vmupro.input.A) then
    vmupro.system.log(vmupro.system.LOG_INFO, "Input", "A pressed!")
end

if vmupro.input.pressed(vmupro.input.UP) then
    player_y = player_y - 1
end
```

#### `vmupro.input.held(button)`
Check if button is currently held down.

**Parameters**:
- `button` (number): Button constant

**Returns**: (boolean) true if button is currently held

**Examples**:
```lua
if vmupro.input.held(vmupro.input.RIGHT) then
    player_x = player_x + 1  -- Continuous movement
end

if vmupro.input.held(vmupro.input.A) then
    charge_attack()  -- Charge while held
end
```

#### `vmupro.input.released(button)`
Check if button was just released.

**Parameters**:
- `button` (number): Button constant

**Returns**: (boolean) true if button was just released

**Examples**:
```lua
if vmupro.input.released(vmupro.input.A) then
    release_attack()  -- Fire when released
end
```

#### `vmupro.input.anythingHeld()`
Check if any button is currently held.

**Returns**: (boolean) true if any button is held

**Example**:
```lua
if vmupro.input.anythingHeld() then
    show_controls()
end
```

### Convenience Functions

#### `vmupro.input.confirmPressed()`
Check if confirm button (A) was pressed.

**Returns**: (boolean) true if A button pressed

**Example**:
```lua
if vmupro.input.confirmPressed() then
    confirm_action()
end
```

#### `vmupro.input.confirmReleased()`
Check if confirm button (A) was released.

**Returns**: (boolean) true if A button released

**Example**:
```lua
if vmupro.input.confirmReleased() then
    end_confirm()
end
```

#### `vmupro.input.dismissPressed()`
Check if dismiss button (B) was pressed.

**Returns**: (boolean) true if B button pressed

**Example**:
```lua
if vmupro.input.dismissPressed() then
    cancel_action()
end
```

#### `vmupro.input.dismissReleased()`
Check if dismiss button (B) was released.

**Returns**: (boolean) true if B button released

**Example**:
```lua
if vmupro.input.dismissReleased() then
    end_cancel()
end
```

### Button Constants

```lua
vmupro.input.UP = 0          -- D-Pad Up
vmupro.input.DOWN = 1        -- D-Pad Down
vmupro.input.LEFT = 2        -- D-Pad Left
vmupro.input.RIGHT = 3       -- D-Pad Right
vmupro.input.A = 4           -- A button (confirm)
vmupro.input.B = 5           -- B button (dismiss)
vmupro.input.POWER = 6       -- Power button
vmupro.input.MODE = 7        -- Mode button
vmupro.input.FUNCTION = 8    -- Bottom button (F-Left)
```

---

## Audio System

**Namespace**: `vmupro.audio` and `vmupro.sound`
**Import**: `import "api/audio"`

### Audio System Control (vmupro.audio)

#### `vmupro.audio.getGlobalVolume()`
Get current global volume level.

**Returns**: (number) Volume level (0-10)

**Example**:
```lua
local volume = vmupro.audio.getGlobalVolume()
vmupro.system.log(vmupro.system.LOG_INFO, "Audio", "Volume: " .. volume)
```

#### `vmupro.audio.setGlobalVolume(volume)`
Set global volume level.

**Parameters**:
- `volume` (number): Volume level (0-10, where 0 is mute, 10 is maximum)

**Example**:
```lua
vmupro.audio.setGlobalVolume(5)  -- 50% volume
vmupro.audio.setGlobalVolume(0)  -- Mute
```

#### `vmupro.audio.startListenMode()`
Start audio listen mode for playback.

**Example**:
```lua
function vmupro.load()
    vmupro.audio.startListenMode()  -- REQUIRED before playing sounds
    sound = vmupro.sound.sample.new("assets/jump")
end
```

#### `vmupro.audio.exitListenMode()`
Exit audio listen mode.

**Example**:
```lua
function vmupro.cleanup()
    vmupro.sound.sample.free(sound)
    vmupro.audio.exitListenMode()  -- REQUIRED when done with audio
end
```

#### `vmupro.audio.clearRingBuffer()`
Clear audio ring buffer.

**Example**:
```lua
vmupro.audio.clearRingBuffer()
```

#### `vmupro.audio.getRingbufferFillState()`
Get current fill state of audio ring buffer.

**Returns**: (number) Number of samples currently in buffer

**Example**:
```lua
local fill = vmupro.audio.getRingbufferFillState()
vmupro.system.log(vmupro.system.LOG_DEBUG, "Audio", "Buffer: " .. fill .. " samples")
```

### Audio Mode Constants

```lua
vmupro.audio.MONO = 0     -- Mono audio mode
vmupro.audio.STEREO = 1   -- Stereo audio mode
```

### Sample Playback (vmupro.sound.sample)

#### `vmupro.sound.sample.new(path)`
Load a WAV file from SD card.

**Parameters**:
- `path` (string): Path relative to /sdcard/, without .wav extension

**Returns**: (SampleObject|nil) Sample object, or nil on error

**Example**:
```lua
local jump = vmupro.sound.sample.new("assets/jump")
if jump == nil then
    vmupro.system.log(vmupro.system.LOG_ERROR, "Audio", "Failed to load jump sound")
end
```

#### `vmupro.sound.sample.play(sample, repeatCount, callback)`
Play a loaded sample.

**Parameters**:
- `sample` (SampleObject): Sample object from new()
- `repeatCount` (number): Number of times to repeat (0 = once, 1 = twice, etc.)
- `callback` (function, optional): Callback when playback finishes

**Examples**:
```lua
-- Play once
vmupro.sound.sample.play(jump, 0)

-- Play twice
vmupro.sound.sample.play(jump, 1)

-- Play with callback
vmupro.sound.sample.play(jump, 0, function()
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Audio", "Done playing")
end)
```

#### `vmupro.sound.sample.stop(sample)`
Stop a playing sample.

**Parameters**:
- `sample` (SampleObject): Sample object to stop

**Example**:
```lua
vmupro.sound.sample.stop(background_music)
```

#### `vmupro.sound.sample.isPlaying(sample)`
Check if sample is currently playing.

**Parameters**:
- `sample` (SampleObject): Sample object to check

**Returns**: (boolean) true if playing

**Example**:
```lua
if vmupro.sound.sample.isPlaying(music) then
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Audio", "Music is playing")
end
```

#### `vmupro.sound.sample.setVolume(sample, left, right)`
Set stereo volume for a sample.

**Parameters**:
- `sample` (SampleObject): Sample object to adjust
- `left` (number): Left channel volume (0.0 to 1.0)
- `right` (number): Right channel volume (0.0 to 1.0)

**Examples**:
```lua
vmupro.sound.sample.setVolume(sound, 1.0, 1.0)  -- Full stereo
vmupro.sound.sample.setVolume(sound, 0.5, 0.5)  -- Half volume
vmupro.sound.sample.setVolume(sound, 1.0, 0.0)  -- Left only
```

#### `vmupro.sound.sample.getVolume(sample)`
Get current stereo volume for a sample.

**Parameters**:
- `sample` (SampleObject): Sample object to query

**Returns**: (number, number) Left and right channel volumes (0.0-1.0)

**Example**:
```lua
local left, right = vmupro.sound.sample.getVolume(sound)
vmupro.system.log(vmupro.system.LOG_DEBUG, "Audio", "L: " .. left .. " R: " .. right)
```

#### `vmupro.sound.sample.setRate(sample, rate)`
Set playback rate (speed/pitch).

**Parameters**:
- `sample` (SampleObject): Sample object to adjust
- `rate` (number): Playback rate multiplier (1.0 = normal, 0.5 = half speed, 2.0 = double)

**Examples**:
```lua
vmupro.sound.sample.setRate(sound, 1.0)   -- Normal speed
vmupro.sound.sample.setRate(sound, 0.5)   -- Half speed (lower pitch)
vmupro.sound.sample.setRate(sound, 2.0)   -- Double speed (higher pitch)
```

#### `vmupro.sound.sample.getRate(sample)`
Get current playback rate.

**Parameters**:
- `sample` (SampleObject): Sample object to query

**Returns**: (number) Current playback rate multiplier

**Example**:
```lua
local rate = vmupro.sound.sample.getRate(sound)
```

#### `vmupro.sound.sample.free(sample)`
Free a sample and release memory.

**Parameters**:
- `sample` (SampleObject): Sample object to free

**Example**:
```lua
vmupro.sound.sample.free(jump)
```

### Audio Update (CRITICAL)

#### `vmupro.sound.update()`
Mix and output audio to device. **MUST be called every frame.**

**Example**:
```lua
function vmupro.update()
    vmupro.input.read()
    vmupro.sound.update()  -- CRITICAL: Must call every frame for audio to work

    -- Rest of update logic
end
```

---

## File System

**Namespace**: `vmupro.file`
**Import**: `import "api/file"`

**IMPORTANT**: All file access is restricted to `/sdcard/` directory only.

### File Operations

#### `vmupro.file.exists(path)`
Check if a file exists.

**Parameters**:
- `path` (string): File path (must start with "/sdcard/")

**Returns**: (boolean) true if file exists

**Examples**:
```lua
if vmupro.file.exists("/sdcard/save.dat") then
    load_game()
end

local has_config = vmupro.file.exists("/sdcard/config.txt")
```

#### `vmupro.file.read(path)`
Read entire file contents as string.

**Parameters**:
- `path` (string): File path (must start with "/sdcard/")

**Returns**: (string|nil) File contents, or nil if error

**Examples**:
```lua
local data = vmupro.file.read("/sdcard/save.dat")
if data then
    parse_save_data(data)
end

local config = vmupro.file.read("/sdcard/config.txt")
```

#### `vmupro.file.write(path, data)`
Write data to a file (replaces existing content).

**Parameters**:
- `path` (string): File path (must start with "/sdcard/")
- `data` (string): Data to write

**Returns**: (boolean) true if successful

**Examples**:
```lua
local success = vmupro.file.write("/sdcard/save.dat", "score=1000")
if success then
    vmupro.system.log(vmupro.system.LOG_INFO, "File", "Saved successfully")
end

vmupro.file.write("/sdcard/config.txt", "volume=5\nbrightness=8")
```

#### `vmupro.file.getSize(path)`
Get file size in bytes.

**Parameters**:
- `path` (string): File path (must start with "/sdcard/")

**Returns**: (number) File size in bytes, or 0 if doesn't exist

**Example**:
```lua
local size = vmupro.file.getSize("/sdcard/save.dat")
vmupro.system.log(vmupro.system.LOG_DEBUG, "File", "Size: " .. size .. " bytes")
```

#### `vmupro.file.createFile(path)`
Create an empty file.

**Parameters**:
- `path` (string): File path (must start with "/sdcard/")

**Returns**: (boolean) true if created successfully

**Note**: If file already exists, returns true without error

**Example**:
```lua
local success = vmupro.file.createFile("/sdcard/data.txt")
```

#### `vmupro.file.deleteFile(path)`
Delete a file.

**Parameters**:
- `path` (string): File path (must start with "/sdcard/")

**Returns**: (boolean) true if deleted successfully

**Example**:
```lua
local success = vmupro.file.deleteFile("/sdcard/temp.dat")
```

### Folder Operations

#### `vmupro.file.folderExists(path)`
Check if a folder exists.

**Parameters**:
- `path` (string): Folder path (must start with "/sdcard/")

**Returns**: (boolean) true if folder exists

**Example**:
```lua
if vmupro.file.folderExists("/sdcard/saves") then
    load_saves()
end
```

#### `vmupro.file.createFolder(path)`
Create a new folder.

**Parameters**:
- `path` (string): Folder path (must start with "/sdcard/")

**Returns**: (boolean) true if created successfully

**Example**:
```lua
local success = vmupro.file.createFolder("/sdcard/saves")
```

#### `vmupro.file.deleteFolder(path)`
Delete a folder.

**Parameters**:
- `path` (string): Folder path (must start with "/sdcard/")

**Returns**: (boolean) true if deleted successfully

**Note**: Folder must be empty before deletion

**Example**:
```lua
local success = vmupro.file.deleteFolder("/sdcard/temp")
```

---

## Sprite System

**Namespace**: `vmupro.sprite`
**Import**: `import "api/sprites"`

### Loading Sprites

#### `vmupro.sprite.new(path)`
Load a sprite from embedded vmupack file.

**Parameters**:
- `path` (string): Path to sprite file without extension (.bmp or .png)

**Returns**: (SpriteHandle|nil) Sprite object with id, width, height, transparentColor, or nil on failure

**Note**: Sprites are loaded from embedded vmupack files, not from SD card

**Examples**:
```lua
local player = vmupro.sprite.new("sprites/player")
if player then
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Sprite", "Loaded: " .. player.width .. "x" .. player.height)
end
```

#### `vmupro.sprite.newSheet(path)`
Load a spritesheet from embedded vmupack file.

**Parameters**:
- `path` (string): Path following format "name-table-<width>-<height>" without extension

**Returns**: (SpritesheetHandle|nil) Spritesheet object with id, width, height, frameWidth, frameHeight, frameCount, transparentColor

**Note**: Filename must follow template: "name-table-width-height" (e.g., "player-table-32-32" for 32x32 frames)

**Example**:
```lua
local sheet = vmupro.sprite.newSheet("sprites/player-table-32-32")
if sheet then
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Sheet", "Frames: " .. sheet.frameCount)
end
```

### Basic Drawing

#### `vmupro.sprite.draw(sprite, x, y, flags)`
Draw a sprite at specified position.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object from new()
- `x, y` (number): Draw coordinates
- `flags` (number, optional): Draw flags (default: kImageUnflipped)

**Example**:
```lua
vmupro.sprite.draw(player, 50, 50)
vmupro.sprite.draw(player, 100, 100, vmupro.sprite.kImageFlippedX)
```

#### `vmupro.sprite.drawFrame(spritesheet, frame_index, x, y, flags)`
Draw a specific frame from spritesheet.

**Parameters**:
- `spritesheet` (SpritesheetHandle): Spritesheet object from newSheet()
- `frame_index` (number): Frame to draw (1-based, Lua convention)
- `x, y` (number): Draw coordinates
- `flags` (number, optional): Draw flags

**Example**:
```lua
vmupro.sprite.drawFrame(sheet, 1, 50, 50)  -- Draw first frame
vmupro.sprite.drawFrame(sheet, current_frame, player_x, player_y)
```

### Advanced Drawing

#### `vmupro.sprite.drawScaled(sprite, x, y, scale_x, scale_y, flags)`
Draw sprite with scaling.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `x, y` (number): Draw coordinates
- `scale_x` (number): Horizontal scale (1.0 = normal, 2.0 = double, 0.5 = half)
- `scale_y` (number, optional): Vertical scale (defaults to scale_x)
- `flags` (number, optional): Draw flags

**Examples**:
```lua
vmupro.sprite.drawScaled(sprite, 50, 50, 2.0)              -- 2x uniform
vmupro.sprite.drawScaled(sprite, 100, 100, 0.5, 0.5)       -- Half size
vmupro.sprite.drawScaled(sprite, 100, 100, 2.0, 1.0)       -- Double width, normal height
```

#### `vmupro.sprite.drawFrameScaled(spritesheet, frame_index, x, y, scale_x, scale_y, flags)`
Draw spritesheet frame with scaling.

**Parameters**: Same as drawScaled but with frame_index parameter

**Example**:
```lua
vmupro.sprite.drawFrameScaled(sheet, 1, 50, 50, 2.0)
```

#### `vmupro.sprite.drawTinted(sprite, x, y, tint_color, flags)`
Draw sprite with color tinting (multiply).

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `x, y` (number): Draw coordinates
- `tint_color` (number): RGB color in 0xRRGGBB format
- `flags` (number, optional): Draw flags

**Examples**:
```lua
vmupro.sprite.drawTinted(sprite, 50, 50, 0xFF0000)  -- Red tint
vmupro.sprite.drawTinted(sprite, 100, 100, 0x00FF00)  -- Green tint
```

#### `vmupro.sprite.drawFrameTinted(spritesheet, frame_index, x, y, tint_color, flags)`
Draw spritesheet frame with color tinting.

**Example**:
```lua
vmupro.sprite.drawFrameTinted(sheet, current_frame, player_x, player_y, 0xFF4040)  -- Damage flash
```

#### `vmupro.sprite.drawColorAdd(sprite, x, y, add_color, flags)`
Draw sprite with additive color (brighten).

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `x, y` (number): Draw coordinates
- `add_color` (number): RGB color in 0xRRGGBB format to add
- `flags` (number, optional): Draw flags

**Example**:
```lua
vmupro.sprite.drawColorAdd(sprite, 50, 50, 0xFF0000)  -- Add red (brighten)
vmupro.sprite.drawColorAdd(sprite, 100, 100, 0x404040)  -- Brighten all channels
```

#### `vmupro.sprite.drawFrameColorAdd(spritesheet, frame_index, x, y, add_color, flags)`
Draw spritesheet frame with additive color.

#### `vmupro.sprite.drawBlended(sprite, x, y, alpha, flags)`
Draw sprite with global alpha blending.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `x, y` (number): Draw coordinates
- `alpha` (number): Alpha value 0-255 (0 = transparent, 255 = opaque)
- `flags` (number, optional): Draw flags

**Examples**:
```lua
vmupro.sprite.drawBlended(sprite, 50, 50, 128)  -- 50% opacity
vmupro.sprite.drawBlended(sprite, 100, 100, 64)  -- 25% opacity (ghost effect)
```

#### `vmupro.sprite.drawFrameBlended(spritesheet, frame_index, x, y, alpha, flags)`
Draw spritesheet frame with alpha blending.

#### `vmupro.sprite.drawMosaic(sprite, x, y, mosaic_size, flags)`
Draw sprite with mosaic/pixelation effect.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `x, y` (number): Draw coordinates
- `mosaic_size` (number): Size of mosaic blocks (1 = no effect, larger = more pixelated)
- `flags` (number, optional): Draw flags

**Example**:
```lua
vmupro.sprite.drawMosaic(sprite, 50, 50, 4)  -- 4x4 pixel blocks
vmupro.sprite.drawMosaic(sprite, 100, 100, 8)  -- Heavy pixelation
```

#### `vmupro.sprite.drawFrameMosaic(spritesheet, frame_index, x, y, mosaic_size, flags)`
Draw spritesheet frame with mosaic effect.

#### `vmupro.sprite.drawBlurred(sprite, x, y, radius, flags)`
Draw sprite with blur effect.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `x, y` (number): Draw coordinates
- `radius` (number): Blur radius 0-10 (0 = no blur, 10 = maximum)
- `flags` (number, optional): Draw flags

**Example**:
```lua
vmupro.sprite.drawBlurred(sprite, 50, 50, 3)  -- Moderate blur
vmupro.sprite.drawBlurred(bg_sprite, 0, 0, 8)  -- Heavy blur for depth of field
```

#### `vmupro.sprite.drawFrameBlurred(spritesheet, frame_index, x, y, radius, flags)`
Draw spritesheet frame with blur effect.

### Transform Functions

#### `vmupro.sprite.setPosition(sprite, x, y)`
Set sprite position to absolute coordinates.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `x, y` (number): Position coordinates

**Example**:
```lua
vmupro.sprite.setPosition(player, 100, 50)
```

#### `vmupro.sprite.moveTo(sprite, x, y)`
Alias for setPosition().

#### `vmupro.sprite.moveBy(sprite, dx, dy)`
Move sprite by relative offset.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `dx` (number): Delta X (positive = right, negative = left)
- `dy` (number): Delta Y (positive = down, negative = up)

**Examples**:
```lua
vmupro.sprite.moveBy(player, 5, 0)   -- Move 5 pixels right
vmupro.sprite.moveBy(player, 0, -10) -- Move 10 pixels up
```

#### `vmupro.sprite.getPosition(sprite)`
Get current sprite position.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object

**Returns**: (number, number) Current X and Y coordinates

**Example**:
```lua
local x, y = vmupro.sprite.getPosition(player)
```

#### `vmupro.sprite.setCenter(sprite, x, y)`
Set sprite center point for rotation/scaling.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `x` (number): Normalized X coordinate (0.0 = left, 0.5 = center, 1.0 = right)
- `y` (number): Normalized Y coordinate (0.0 = top, 0.5 = center, 1.0 = bottom)

**Examples**:
```lua
vmupro.sprite.setCenter(sprite, 0.5, 0.5)  -- Center (default)
vmupro.sprite.setCenter(sprite, 0.5, 1.0)  -- Bottom center (for rotation)
vmupro.sprite.setCenter(sprite, 0.0, 0.0)  -- Top-left corner
```

#### `vmupro.sprite.getCenter(sprite)`
Get sprite's current center point.

**Returns**: (number, number) Center X and Y (normalized 0.0-1.0)

#### `vmupro.sprite.getBounds(sprite)`
Get sprite's actual drawing bounds in screen space.

**Returns**: (number, number, number, number) Top-left X, top-left Y, width, height

**Example**:
```lua
local x, y, w, h = vmupro.sprite.getBounds(player)
```

#### `vmupro.sprite.setVisible(sprite, visible)`
Set sprite visibility.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `visible` (boolean): true to show, false to hide

**Example**:
```lua
vmupro.sprite.setVisible(enemy, false)  -- Hide
vmupro.sprite.setVisible(enemy, true)   -- Show
```

#### `vmupro.sprite.getVisible(sprite)`
Get sprite visibility state.

**Returns**: (boolean) true if visible

#### `vmupro.sprite.setZIndex(sprite, z)`
Set sprite Z-index for drawing order.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `z` (number): Z-index (lower = behind, higher = in front)

**Example**:
```lua
vmupro.sprite.setZIndex(background, 1)   -- Back layer
vmupro.sprite.setZIndex(player, 10)      -- Front layer
```

#### `vmupro.sprite.getZIndex(sprite)`
Get sprite's current Z-index.

**Returns**: (number) Current Z-index

### Scene Management

#### `vmupro.sprite.add(sprite)`
Add sprite to scene for automatic Z-sorted rendering.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object

**Example**:
```lua
vmupro.sprite.add(player)
vmupro.sprite.add(enemy)
vmupro.sprite.add(background)

-- Later, in render loop:
vmupro.sprite.drawAll()  -- Draws all added sprites Z-sorted
```

#### `vmupro.sprite.remove(sprite)`
Remove sprite from scene.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object

**Example**:
```lua
vmupro.sprite.remove(enemy)
```

#### `vmupro.sprite.removeAll()`
Remove all sprites from scene.

**CRITICAL**: Always call this in cleanup/exit functions to prevent sprite leaking.

**Example**:
```lua
function Page1.exit()
    vmupro.sprite.removeAll()  -- CRITICAL: Clear all sprites
end
```

#### `vmupro.sprite.drawAll()`
Draw all sprites in scene sorted by Z-index.

**Example**:
```lua
function render()
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.sprite.drawAll()  -- Automatic Z-sorted rendering
    vmupro.graphics.refresh()
end
```

### Animation

#### `vmupro.sprite.playAnimation(sprite, startFrame, endFrame, fps, loop)`
Start playing animation on spritesheet.

**Parameters**:
- `sprite` (SpritesheetHandle): Spritesheet object
- `startFrame` (number): First frame (0-based)
- `endFrame` (number): Last frame (0-based, inclusive)
- `fps` (number): Frames per second
- `loop` (boolean): true to loop, false for one-shot

**Examples**:
```lua
vmupro.sprite.playAnimation(player, 0, 3, 10, true)   -- Loop frames 0-3 at 10 FPS
vmupro.sprite.playAnimation(explosion, 0, 7, 15, false)  -- One-shot
```

#### `vmupro.sprite.stopAnimation(sprite)`
Stop currently playing animation.

**Example**:
```lua
vmupro.sprite.stopAnimation(player)
```

#### `vmupro.sprite.pauseAnimation(sprite)`
Pause animation without resetting state.

**Example**:
```lua
vmupro.sprite.pauseAnimation(player)
```

#### `vmupro.sprite.resumeAnimation(sprite)`
Resume paused animation.

**Example**:
```lua
vmupro.sprite.resumeAnimation(player)
```

#### `vmupro.sprite.isAnimating(sprite)`
Check if sprite is currently animating (and not paused).

**Returns**: (boolean) true if animating

**Example**:
```lua
if vmupro.sprite.isAnimating(player) then
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Sprite", "Animating")
end
```

#### `vmupro.sprite.updateAnimations()`
Update all active sprite animations.

**CRITICAL**: Must be called once per frame.

**Example**:
```lua
function vmupro.update()
    vmupro.input.read()
    vmupro.sprite.updateAnimations()  -- CRITICAL: Every frame

    -- After update, draw manually with getCurrentFrame() + 1
    local frame = vmupro.sprite.getCurrentFrame(player)
    vmupro.sprite.drawFrame(player_sheet, frame + 1, player_x, player_y)
end
```

#### `vmupro.sprite.getCurrentFrame(sprite)`
Get current frame index of sprite/spritesheet.

**Returns**: (number) Current frame (0-based)

**Example**:
```lua
local frame = vmupro.sprite.getCurrentFrame(player)
vmupro.sprite.drawFrame(sheet, frame + 1, x, y)  -- +1 because drawFrame is 1-based
```

#### `vmupro.sprite.getFrameCount(sprite)`
Get total number of frames in spritesheet.

**Returns**: (number) Total frame count

**Example**:
```lua
local count = vmupro.sprite.getFrameCount(sheet)
for i = 0, count - 1 do
    -- Process each frame
end
```

#### `vmupro.sprite.setCurrentFrame(sprite, frame_index)`
Set current frame index (0-based).

**Example**:
```lua
vmupro.sprite.setCurrentFrame(player, 0)  -- Set to first frame
```

### Collision Detection

#### `vmupro.sprite.setCollisionRect(sprite, x, y, width, height)`
Set collision rectangle relative to sprite position.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `x, y` (number): Offset from sprite position
- `width, height` (number): Collision rectangle dimensions

**Examples**:
```lua
vmupro.sprite.setCollisionRect(player, 6, 2, 20, 28)  -- 20x28 rect, offset by (6, 2)
vmupro.sprite.setCollisionRect(enemy, 0, 0, 32, 32)   -- Full sprite collision
```

#### `vmupro.sprite.getCollisionRect(sprite)`
Get collision rectangle relative to sprite position.

**Returns**: (number|nil, number|nil, number|nil, number|nil) X offset, Y offset, width, height (or nil if not set)

**Example**:
```lua
local cx, cy, cw, ch = vmupro.sprite.getCollisionRect(player)
if cx then
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Sprite", "Collision: " .. cw .. "x" .. ch)
end
```

#### `vmupro.sprite.getCollideBounds(sprite)`
Get world-space collision bounds.

**Returns**: (number|nil, number|nil, number|nil, number|nil) World X, world Y, width, height (or nil if not set)

**Example**:
```lua
local bx, by, bw, bh = vmupro.sprite.getCollideBounds(player)
if bx then
    -- Check collision with another sprite
end
```

#### `vmupro.sprite.clearCollisionRect(sprite)`
Remove collision rectangle.

**Example**:
```lua
vmupro.sprite.clearCollisionRect(player)
```

#### `vmupro.sprite.overlappingSprites(sprite)`
Get all sprites overlapping with this sprite.

**Returns**: (table) Array of collision results, each containing {id = sprite_handle}

**Example**:
```lua
local collisions = vmupro.sprite.overlappingSprites(player)
for i, collision in ipairs(collisions) do
    local other = collision.id
    if other == enemy then
        takeDamage()
    end
end
```

#### `vmupro.sprite.checkCollisions(sprite, goalX, goalY)`
Check what would happen if sprite moved to goal position (does NOT actually move).

**Returns**: (number, number, table) actualX, actualY, collisions array

**Example**:
```lua
local actualX, actualY, hits = vmupro.sprite.checkCollisions(player, newX, newY)
if #hits == 0 then
    vmupro.sprite.moveTo(player, newX, newY)  -- Safe to move
else
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Sprite", "Would collide with " .. #hits .. " sprites")
end
```

#### `vmupro.sprite.moveWithCollisions(sprite, goalX, goalY)`
Move sprite to goal position if no collision detected.

**Returns**: (number, number, table) actualX, actualY, collisions array

**Example**:
```lua
local actualX, actualY, hits = vmupro.sprite.moveWithCollisions(player, newX, newY)
if #hits > 0 then
    -- Collision occurred, sprite did not move
    for i = 1, #hits do
        if hits[i].id == enemy.id then
            vmupro.system.log(vmupro.system.LOG_INFO, "Collision", "Hit enemy!")
        end
    end
end
```

### Collision Groups

#### `vmupro.sprite.setGroups(sprite, groups)`
Set which collision groups sprite belongs to.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `groups` (table): Array of group numbers (1-32)

**Example**:
```lua
vmupro.sprite.setGroups(player, {1})       -- Player in group 1
vmupro.sprite.setGroups(enemy, {2, 5})     -- Enemy in groups 2 and 5
```

#### `vmupro.sprite.getGroups(sprite)`
Get which collision groups sprite belongs to.

**Returns**: (table) Array of group numbers

#### `vmupro.sprite.setCollidesWithGroups(sprite, groups)`
Set which collision groups this sprite collides with.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `groups` (table): Array of group numbers to collide with

**Example**:
```lua
vmupro.sprite.setCollidesWithGroups(player, {2, 4})  -- Player collides with groups 2 and 4
vmupro.sprite.setCollidesWithGroups(bullet, {2})     -- Bullet only collides with group 2
```

#### `vmupro.sprite.getCollidesWithGroups(sprite)`
Get which collision groups this sprite collides with.

**Returns**: (table) Array of group numbers

### Collision Groups (Bitmask)

#### `vmupro.sprite.setGroupMask(sprite, mask)`
Set collision groups using 32-bit bitmask.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `mask` (number): 32-bit bitmask (bits 0-31 = groups 1-32)

**Example**:
```lua
vmupro.sprite.setGroupMask(player, 0x00000001)   -- Group 1
vmupro.sprite.setGroupMask(enemy, 0x00000002)    -- Group 2
vmupro.sprite.setGroupMask(boss, 0x00000012)     -- Groups 2 and 5
```

#### `vmupro.sprite.getGroupMask(sprite)`
Get collision groups as bitmask.

**Returns**: (number) 32-bit bitmask

#### `vmupro.sprite.setCollidesWithGroupsMask(sprite, mask)`
Set collides-with groups using bitmask.

**Example**:
```lua
vmupro.sprite.setCollidesWithGroupsMask(player, 0x0000000A)  -- Groups 2 and 4
```

#### `vmupro.sprite.getCollidesWithGroupsMask(sprite)`
Get collides-with groups as bitmask.

**Returns**: (number) 32-bit bitmask

### Spatial Queries

#### `vmupro.sprite.querySpritesAtPoint(x, y)`
Get all sprites at a specific point.

**Parameters**:
- `x, y` (number): World-space coordinates

**Returns**: (table) Array of sprites at point, each with {id = sprite_handle}

**Example**:
```lua
local sprites = vmupro.sprite.querySpritesAtPoint(120, 80)
if #sprites > 0 then
    local top_sprite = sprites[1].id
    highlightSprite(top_sprite)
end
```

#### `vmupro.sprite.querySpritesInRect(x, y, width, height)`
Get all sprites intersecting a rectangle.

**Parameters**:
- `x, y` (number): Top-left corner
- `width, height` (number): Rectangle dimensions

**Returns**: (table) Array of intersecting sprites

**Example**:
```lua
local sprites = vmupro.sprite.querySpritesInRect(100, 100, 64, 64)
for i, sprite_data in ipairs(sprites) do
    applyExplosionDamage(sprite_data.id)
end
```

#### `vmupro.sprite.querySpritesAlongLine(x1, y1, x2, y2)`
Get all sprites intersecting a line segment.

**Parameters**:
- `x1, y1` (number): Line start point
- `x2, y2` (number): Line end point

**Returns**: (table) Array of intersecting sprites

**Example**:
```lua
local sprites = vmupro.sprite.querySpritesAlongLine(50, 120, 200, 120)
for i, sprite_data in ipairs(sprites) do
    applyLaserDamage(sprite_data.id)
end
```

### Clipping and Stencils

#### `vmupro.sprite.setClipRect(sprite, x, y, width, height)`
Set clipping rectangle to only draw portion of sprite.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `x, y` (number): Offset from sprite's top-left
- `width, height` (number): Visible region dimensions

**Example**:
```lua
vmupro.sprite.setClipRect(healthBar, 0, 0, 60, 20)  -- Show left 60 pixels
vmupro.sprite.setClipRect(card, 0, 0, revealWidth, 64)  -- Reveal effect
```

#### `vmupro.sprite.clearClipRect(sprite)`
Remove clipping rectangle.

**Example**:
```lua
vmupro.sprite.clearClipRect(healthBar)
```

#### `vmupro.sprite.setStencilImage(sprite, maskSprite)`
Use another sprite's alpha channel as stencil mask.

**Parameters**:
- `sprite` (SpriteHandle): Sprite to apply stencil to
- `maskSprite` (SpriteHandle): PNG with alpha channel to use as mask

**Example**:
```lua
vmupro.sprite.setStencilImage(character, circular_mask)
```

#### `vmupro.sprite.setStencilPattern(sprite, pattern)`
Use 8-byte pattern as 8x8 tiled stencil mask.

**Parameters**:
- `sprite` (SpriteHandle): Sprite to apply stencil to
- `pattern` (table): Array of 8 integers (0-255), one per row

**Example**:
```lua
vmupro.sprite.setStencilPattern(sprite, {0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55})
```

#### `vmupro.sprite.clearStencil(sprite)`
Remove stencil mask.

**Example**:
```lua
vmupro.sprite.clearStencil(sprite)
```

### Metadata and Userdata

#### `vmupro.sprite.setTag(sprite, tag)`
Set 8-bit tag identifier for sprite.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `tag` (number): Tag value (0-255)

**Example**:
```lua
vmupro.sprite.setTag(player, 1)   -- 1 = player type
vmupro.sprite.setTag(enemy, 2)    -- 2 = enemy type
```

#### `vmupro.sprite.getTag(sprite)`
Get tag identifier.

**Returns**: (number) Tag value (0-255), 0 if not set

**Example**:
```lua
local type = vmupro.sprite.getTag(sprite)
if type == 1 then
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Sprite", "This is a player")
end
```

#### `vmupro.sprite.setUserdata(sprite, data)`
Store arbitrary Lua data with sprite.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `data` (any): Any Lua value (table, number, string, boolean, etc.)

**Example**:
```lua
vmupro.sprite.setUserdata(player, {health = 100, lives = 3})
vmupro.sprite.setUserdata(enemy, {ai_state = "patrol", target = nil})
```

#### `vmupro.sprite.getUserdata(sprite)`
Retrieve stored Lua data.

**Returns**: (any) Previously stored data, or nil

**Example**:
```lua
local data = vmupro.sprite.getUserdata(player)
if data then
    data.health = data.health - 10
    vmupro.sprite.setUserdata(player, data)  -- Update
end
```

### Custom Callbacks

#### `vmupro.sprite.setUpdateFunction(sprite, callback)`
Set custom update callback for sprite.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `callback` (function): Update function called every frame during updateAnimations()

**Example**:
```lua
vmupro.sprite.setUpdateFunction(enemy, function()
    local x, y = vmupro.sprite.getPosition(enemy)
    vmupro.sprite.moveTo(enemy, x + 1, y)  -- Move right every frame
end)
```

#### `vmupro.sprite.setDrawFunction(sprite, callback)`
Set custom draw callback (replaces default rendering).

**Parameters**:
- `sprite` (SpriteHandle): Sprite object
- `callback` (function): Draw function(x, y, width, height)

**Example**:
```lua
vmupro.sprite.setDrawFunction(sprite, function(x, y, w, h)
    -- Custom rendering
    vmupro.graphics.drawRect(x, y, x+w, y+h, vmupro.graphics.RED)
    vmupro.graphics.drawText("!", x+w/2, y+h/2, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
end)
```

### Cleanup

#### `vmupro.sprite.free(sprite)`
Free sprite and release memory.

**Parameters**:
- `sprite` (SpriteHandle): Sprite object to free

**Example**:
```lua
vmupro.sprite.free(player)
```

### Flip Constants

```lua
vmupro.sprite.kImageUnflipped = 0   -- No flipping
vmupro.sprite.kImageFlippedX = 1    -- Flip horizontally
vmupro.sprite.kImageFlippedY = 2    -- Flip vertically
vmupro.sprite.kImageFlippedXY = 3   -- Flip both
```

---

## Text Rendering

**Namespace**: `vmupro.text`
**Import**: `import "api/text"`

### Font Management

#### `vmupro.text.setFont(font_id)`
Set current font for text rendering.

**Parameters**:
- `font_id` (number): Font ID from constants below

**Examples**:
```lua
vmupro.text.setFont(vmupro.text.FONT_SMALL)   -- Small font
vmupro.text.setFont(vmupro.text.FONT_MEDIUM)  -- Medium font
vmupro.text.setFont(vmupro.text.FONT_LARGE)   -- Large font
```

#### `vmupro.text.calcLength(text)`
Calculate pixel width of text with current font.

**Parameters**:
- `text` (string): Text to measure

**Returns**: (number) Width in pixels

**Example**:
```lua
local width = vmupro.text.calcLength("Hello World")
vmupro.system.log(vmupro.system.LOG_DEBUG, "Text", "Width: " .. width .. "px")
```

#### `vmupro.text.getFontInfo()`
Get information about current font.

**Returns**: (table) Font information (implementation-specific)

**Example**:
```lua
local info = vmupro.text.getFontInfo()
```

### Font Constants

```lua
-- Tiny fonts
vmupro.text.FONT_TINY_6x8 = 0          -- Smallest font (6×8px)
vmupro.text.FONT_MONO_7x13 = 1         -- Tiny monospace (7×13px)

-- Quantico fonts (UI fonts)
vmupro.text.FONT_QUANTICO_15x16 = 2    -- Medium (15×16px)
vmupro.text.FONT_QUANTICO_18x20 = 3    -- Medium (18×20px)
vmupro.text.FONT_QUANTICO_19x21 = 4    -- Medium (19×21px)
vmupro.text.FONT_QUANTICO_25x29 = 5    -- Large (25×29px)
vmupro.text.FONT_QUANTICO_29x33 = 6    -- Extra large (29×33px)
vmupro.text.FONT_QUANTICO_32x37 = 7    -- Largest (32×37px)

-- Gabarito fonts
vmupro.text.FONT_GABARITO_18x18 = 8    -- Medium (18×18px)
vmupro.text.FONT_GABARITO_22x24 = 9    -- Large (22×24px)

-- Open Sans fonts
vmupro.text.FONT_OPEN_SANS_15x18 = 10  -- Medium (15×18px)
vmupro.text.FONT_OPEN_SANS_21x24 = 11  -- Large (21×24px)

-- Convenience aliases
vmupro.text.FONT_SMALL = 1             -- Small (MONO_7x13)
vmupro.text.FONT_MEDIUM = 10           -- Medium (OPEN_SANS_15x18)
vmupro.text.FONT_LARGE = 5             -- Large (QUANTICO_25x29)
vmupro.text.FONT_DEFAULT = 10          -- Default (MEDIUM)
```

---

## Common Usage Patterns

### Basic Game Loop

```lua
import "api/system"
import "api/display"
import "api/input"

function AppMain()
    local running = true

    while running do
        -- Update input (once per frame)
        vmupro.input.read()

        -- Handle input
        if vmupro.input.pressed(vmupro.input.B) then
            running = false
        end

        -- Clear display (once per frame)
        vmupro.graphics.clear(vmupro.graphics.BLACK)

        -- Draw everything
        vmupro.graphics.drawText("Hello World!", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)

        -- Present to screen (once per frame)
        vmupro.graphics.refresh()

        -- Frame rate control (~60 FPS)
        vmupro.system.delayMs(16)
    end

    return 0
end
```

### Sprite with Animation

```lua
import "api/sprites"

local player_sheet
local player_x = 100
local player_y = 100

function load()
    player_sheet = vmupro.sprite.newSheet("sprites/player-table-32-32")
    vmupro.sprite.playAnimation(player_sheet, 0, 3, 10, true)  -- Loop frames 0-3 at 10 FPS
end

function update()
    vmupro.input.read()
    vmupro.sprite.updateAnimations()  -- CRITICAL: Every frame

    if vmupro.input.held(vmupro.input.RIGHT) then
        player_x = player_x + 1
    elseif vmupro.input.held(vmupro.input.LEFT) then
        player_x = player_x - 1
    end
end

function render()
    vmupro.graphics.clear(vmupro.graphics.BLACK)

    -- Get current animation frame and draw (frame + 1 because drawFrame is 1-based)
    local frame = vmupro.sprite.getCurrentFrame(player_sheet)
    vmupro.sprite.drawFrame(player_sheet, frame + 1, player_x, player_y)

    vmupro.graphics.refresh()
end

function cleanup()
    vmupro.sprite.free(player_sheet)
end
```

### Audio Playback

```lua
import "api/audio"

local jump_sound

function load()
    vmupro.audio.startListenMode()  -- CRITICAL: Before audio
    jump_sound = vmupro.sound.sample.new("assets/jump")
end

function update()
    vmupro.input.read()
    vmupro.sound.update()  -- CRITICAL: Every frame for audio

    if vmupro.input.pressed(vmupro.input.A) then
        vmupro.sound.sample.play(jump_sound, 0)  -- Play once
    end
end

function cleanup()
    vmupro.sound.sample.free(jump_sound)
    vmupro.audio.exitListenMode()  -- CRITICAL: When done with audio
end
```

### Scene Management with Sprite Cleanup

```lua
Page1 = {}

function Page1.enter()
    background = vmupro.sprite.new("sprites/bg")
    player = vmupro.sprite.new("sprites/player")

    -- Add to scene for auto-rendering
    vmupro.sprite.add(background)
    vmupro.sprite.add(player)

    -- Set Z-order
    vmupro.sprite.setZIndex(background, 1)
    vmupro.sprite.setZIndex(player, 10)
end

function Page1.render()
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.sprite.drawAll()  -- Auto Z-sorted rendering
    vmupro.graphics.refresh()
end

function Page1.exit()
    -- CRITICAL: Always clean up sprites to prevent leaking
    vmupro.sprite.removeAll()

    -- Free sprite memory
    vmupro.sprite.free(background)
    vmupro.sprite.free(player)
end
```

### Collision Detection

```lua
function setup_collision()
    -- Player setup
    vmupro.sprite.setGroups(player, {1})
    vmupro.sprite.setCollidesWithGroups(player, {2})
    vmupro.sprite.setCollisionRect(player, 4, 2, 24, 28)

    -- Enemy setup
    vmupro.sprite.setGroups(enemy, {2})
    vmupro.sprite.setCollidesWithGroups(enemy, {1})
    vmupro.sprite.setCollisionRect(enemy, 0, 0, 32, 32)
end

function check_player_collision(new_x, new_y)
    -- Check if player can move to new position
    local actual_x, actual_y, hits = vmupro.sprite.moveWithCollisions(player, new_x, new_y)

    if #hits > 0 then
        -- Collision detected
        for i = 1, #hits do
            if hits[i].id == enemy then
                take_damage()
            end
        end
    end

    return actual_x, actual_y
end
```

### File I/O

```lua
function save_game(score, lives)
    local data = "score=" .. score .. "\nlives=" .. lives
    local success = vmupro.file.write("/sdcard/save.dat", data)

    if success then
        vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Saved successfully")
    else
        vmupro.system.log(vmupro.system.LOG_ERROR, "Game", "Save failed")
    end
end

function load_game()
    if vmupro.file.exists("/sdcard/save.dat") then
        local data = vmupro.file.read("/sdcard/save.dat")
        if data then
            -- Parse save data
            for line in data:gmatch("[^\n]+") do
                local key, value = line:match("(%w+)=(%d+)")
                if key == "score" then
                    player_score = tonumber(value)
                elseif key == "lives" then
                    player_lives = tonumber(value)
                end
            end
        end
    end
end
```

### Memory Management

```lua
function check_memory_before_load()
    local required = 50000  -- 50KB needed
    local largest = vmupro.system.getLargestFreeBlock()

    if largest >= required then
        return true  -- Safe to allocate
    else
        local usage = vmupro.system.getMemoryUsage()
        local limit = vmupro.system.getMemoryLimit()
        vmupro.system.log(vmupro.system.LOG_ERROR, "Memory",
            "Need " .. required .. " bytes, only " .. largest .. " available")
        vmupro.system.log(vmupro.system.LOG_ERROR, "Memory",
            "Usage: " .. usage .. "/" .. limit .. " bytes")
        return false
    end
end
```

---

## Common Mistakes to Avoid

### 1. Using `require()` instead of `import`

**WRONG**:
```lua
local system = require("api/system")
```

**CORRECT**:
```lua
import "api/system"
```

### 2. Forgetting to call `vmupro.input.read()` each frame

**WRONG**:
```lua
function update()
    if vmupro.input.pressed(vmupro.input.A) then  -- Input never updates!
        -- ...
    end
end
```

**CORRECT**:
```lua
function update()
    vmupro.input.read()  -- MUST call first
    if vmupro.input.pressed(vmupro.input.A) then
        -- ...
    end
end
```

### 3. Forgetting `vmupro.sound.update()` for audio

**WRONG**:
```lua
function update()
    vmupro.input.read()
    -- No sound.update() - audio won't play!
end
```

**CORRECT**:
```lua
function update()
    vmupro.input.read()
    vmupro.sound.update()  -- CRITICAL: Every frame for audio
end
```

### 4. Forgetting `vmupro.sprite.removeAll()` on page exit

**WRONG**:
```lua
function Page1.exit()
    -- Sprites leak to next page!
end
```

**CORRECT**:
```lua
function Page1.exit()
    vmupro.sprite.removeAll()  -- CRITICAL: Prevent sprite leaking
end
```

### 5. Not calling `vmupro.audio.startListenMode()` before audio

**WRONG**:
```lua
function load()
    sound = vmupro.sound.sample.new("jump")  -- Won't play!
end
```

**CORRECT**:
```lua
function load()
    vmupro.audio.startListenMode()  -- REQUIRED before audio
    sound = vmupro.sound.sample.new("jump")
end
```

### 6. Clearing or refreshing multiple times per frame

**WRONG**:
```lua
function render()
    vmupro.graphics.clear()
    draw_player()
    vmupro.graphics.refresh()

    draw_enemies()
    vmupro.graphics.refresh()  -- Wasteful!
end
```

**CORRECT**:
```lua
function render()
    vmupro.graphics.clear()  -- Once per frame
    draw_player()
    draw_enemies()
    vmupro.graphics.refresh()  -- Once per frame
end
```

### 7. Using wrong frame index for `drawFrame()` vs animation

**WRONG**:
```lua
local frame = vmupro.sprite.getCurrentFrame(sheet)  -- Returns 0-based
vmupro.sprite.drawFrame(sheet, frame, x, y)  -- Wrong: drawFrame is 1-based!
```

**CORRECT**:
```lua
local frame = vmupro.sprite.getCurrentFrame(sheet)  -- 0-based
vmupro.sprite.drawFrame(sheet, frame + 1, x, y)  -- Add 1 for 1-based API
```

### 8. Not checking for nil when loading resources

**WRONG**:
```lua
local sprite = vmupro.sprite.new("player")
vmupro.sprite.draw(sprite, 0, 0)  -- Crashes if sprite is nil!
```

**CORRECT**:
```lua
local sprite = vmupro.sprite.new("player")
if sprite then
    vmupro.sprite.draw(sprite, 0, 0)
else
    vmupro.system.log(vmupro.system.LOG_ERROR, "Load", "Failed to load player sprite")
end
```

### 9. Using scene system with animated sprites

**WRONG**:
```lua
vmupro.sprite.add(animated_sprite)
vmupro.sprite.playAnimation(animated_sprite, 0, 3, 10, true)
-- drawAll() won't update animation frames correctly!
```

**CORRECT**:
```lua
-- Don't use add/drawAll with animations
vmupro.sprite.playAnimation(animated_sprite, 0, 3, 10, true)

function render()
    vmupro.sprite.updateAnimations()
    local frame = vmupro.sprite.getCurrentFrame(animated_sprite)
    vmupro.sprite.drawFrame(animated_sprite, frame + 1, x, y)  -- Manual draw
end
```

### 10. Forgetting to free resources

**WRONG**:
```lua
function cleanup()
    -- Memory leak!
end
```

**CORRECT**:
```lua
function cleanup()
    vmupro.sprite.free(sprite)
    vmupro.sound.sample.free(sound)
    vmupro.audio.exitListenMode()
end
```

### 11. File paths without /sdcard/ prefix

**WRONG**:
```lua
vmupro.file.read("config.txt")  -- Wrong path!
```

**CORRECT**:
```lua
vmupro.file.read("/sdcard/config.txt")  -- Correct
```

### 12. Using wrong log level numbers

**WRONG**:
```lua
vmupro.system.log(5, "Tag", "Message")  -- Invalid level!
```

**CORRECT**:
```lua
vmupro.system.log(vmupro.system.LOG_INFO, "Tag", "Message")  -- Use constants
```

---

## Quick Reference

### Must-Call Functions (Per Frame)

```lua
function vmupro.update()
    vmupro.input.read()         -- Update input state
    vmupro.sprite.updateAnimations()  -- Update sprite animations
    vmupro.sound.update()       -- Process audio
end
```

### Resource Lifecycle

```lua
-- Load
vmupro.audio.startListenMode()
sprite = vmupro.sprite.new("path")
sound = vmupro.sound.sample.new("path")

-- Use
vmupro.sprite.draw(sprite, x, y)
vmupro.sound.sample.play(sound)

-- Cleanup
vmupro.sprite.free(sprite)
vmupro.sound.sample.free(sound)
vmupro.audio.exitListenMode()
```

### Display Specifications

- **Resolution**: 240x240 pixels
- **Color Format**: RGB565 (16-bit, 65,536 colors)
- **Coordinate System**: (0,0) top-left to (239,239) bottom-right
- **Target FPS**: 60 FPS (16.67ms per frame)

### Button Mapping

```
UP=0, DOWN=1, LEFT=2, RIGHT=3  -- D-Pad
A=4                            -- Confirm
B=5                            -- Dismiss
POWER=6, MODE=7, FUNCTION=8    -- System buttons
```

### Log Levels

```
LOG_ERROR=0    -- Errors only
LOG_WARN=1     -- Warnings and errors
LOG_INFO=2     -- Info, warnings, errors
LOG_DEBUG=3    -- Everything including debug
```

---

**Document Version**: 1.0.0
**Last Updated**: 2025-01-16
**Source**: Official VMU Pro SDK API files (system.lua, display.lua, input.lua, audio.lua, file.lua, sprites.lua, text.lua)
