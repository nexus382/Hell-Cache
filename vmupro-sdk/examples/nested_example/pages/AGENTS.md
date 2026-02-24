# VMU Pro SDK - Test Pages Directory

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

This directory contains 39 test pages that comprehensively demonstrate all VMU Pro SDK APIs. Each page is a self-contained Lua module following a consistent pattern with `enter()`, `update()`, `render()`, and `exit()` lifecycle functions.

---

## Page Inventory (39 Pages)

### Basic Graphics (Pages 1-5)

| Page | File | Topic | APIs Tested |
|------|------|-------|-------------|
| 1 | `page1.lua` | Lines & Rectangles | `drawLine`, `drawRect`, `drawFillRect`, `clear` |
| 2 | `page2.lua` | Circles & Ellipses | `drawCircle`, `drawCircleFilled`, `drawEllipse`, `drawEllipseFilled` |
| 3 | `page3.lua` | Polygons | `drawPolygon`, `drawPolygonFilled` |
| 4 | `page4.lua` | Text Rendering & Fonts | `setFont`, `drawText`, `calcLength`, `getFontInfo` |
| 5 | `page5.lua` | Color Constants | All RGB565 colors: RED, ORANGE, YELLOW, GREEN, BLUE, NAVY, VIOLET, MAGENTA, GREY, WHITE, BLACK, VMUGREEN, VMUINK |

### Input & System (Pages 6-9)

| Page | File | Topic | APIs Tested |
|------|------|-------|-------------|
| 6 | `page6.lua` | Button States | `read`, `pressed`, `released`, `held`, `anythingHeld` |
| 7 | `page7.lua` | Timing Functions | `getTimeUs`, `delayMs`, `delayUs`, `sleep` |
| 8 | `page8.lua` | Logging & Info | `log`, `setLogLevel`, `getMemoryUsage`, `getMemoryLimit`, `getLargestFreeBlock`, `apiVersion` |
| 9 | `page9.lua` | Brightness Control | `getGlobalBrightness`, `setGlobalBrightness` |

### File I/O & Audio (Pages 10-12)

| Page | File | Topic | APIs Tested |
|------|------|-------|-------------|
| 10 | `page10.lua` | File I/O | `exists`, `folderExists`, `createFolder`, `createFile`, `read`, `write`, `getSize`, `deleteFile`, `deleteFolder` |
| 11 | `page11.lua` | Audio Stream | `startListenMode`, `exitListenMode`, `addStreamSamples`, `getRingbufferFillState`, `getGlobalVolume`, `setGlobalVolume`, `clearRingBuffer` |
| 12 | `page12.lua` | Fill Operations | `floodFill`, `floodFillTolerance` |

### Advanced Graphics (Pages 13-22)

| Page | File | Topic | APIs Tested |
|------|------|-------|-------------|
| 13 | `page13.lua` | Double Buffer Renderer | `startDoubleBufferRenderer`, `stopDoubleBufferRenderer`, `getLastBlittedFBSide` |
| 14 | `page14.lua` | Sprites (Single) | `sprite.new`, `sprite.draw`, `sprite.free`, flip flags |
| 15 | `page15.lua` | Spritesheet Animation | `sprite.newSheet`, `sprite.drawFrame`, frameCount, frameWidth, frameHeight |
| 16 | `page16.lua` | Sprite Scaling | `sprite.drawScaled`, `sprite.drawFrameScaled` |
| 17 | `page17.lua` | Color Tinting (Damage Flash) | `sprite.drawFrameTinted` |
| 18 | `page18.lua` | Color Add (Shield Glow) | `sprite.drawFrameColorAdd` |
| 19 | `page19.lua` | Mosaic Effect (Teleport) | `sprite.drawFrameMosaic` |
| 20 | `page20.lua` | Alpha Blending (Fade) | `sprite.drawFrameBlended` |
| 21 | `page21.lua` | Blur Effects | `sprite.drawFrameBlurred` |
| 22 | `page22.lua` | Sprite Positioning | `sprite.setPosition`, `sprite.moveBy`, `sprite.getPosition` |

### Sprite System (Pages 23-37)

| Page | File | Topic | APIs Tested |
|------|------|-------|-------------|
| 23 | `page23.lua` | Sprite Visibility | `sprite.setVisible`, `sprite.getVisible` |
| 24 | `page24.lua` | Z-Index | `sprite.setZIndex`, `sprite.getZIndex`, `sprite.add`, `sprite.removeAll`, `sprite.drawAll` |
| 25 | `page25.lua` | Center Point | `sprite.setCenter`, `sprite.getCenter`, `sprite.getBounds` |
| 26 | `page26.lua` | Frame Management | `sprite.setCurrentFrame`, `sprite.getCurrentFrame`, `sprite.getFrameCount` |
| 27 | `page27.lua` | Animation Control | `sprite.playAnimation`, `sprite.stopAnimation`, `sprite.updateAnimations`, `sprite.isAnimating` |
| 28 | `page28.lua` | Collision Detection | `sprite.setCollisionRect`, `sprite.getCollisionRect`, `sprite.clearCollisionRect`, `sprite.getCollideBounds` |
| 29 | `page29.lua` | Collision Groups | `sprite.setGroups`, `sprite.getGroups`, `sprite.setCollidesWithGroups`, `sprite.getCollidesWithGroups` |
| 30 | `page30.lua` | Bitmask Collision | `sprite.setGroupMask`, `sprite.getGroupMask`, `sprite.setCollidesWithGroupsMask`, `sprite.getCollidesWithGroupsMask` |
| 31 | `page31.lua` | Overlapping Sprites | `sprite.overlappingSprites` |
| 32 | `page32.lua` | Move With Collisions | `sprite.moveWithCollisions` |
| 33 | `page33.lua` | Tag & Userdata | `sprite.setTag`, `sprite.getTag`, `sprite.setUserdata`, `sprite.getUserdata` |
| 34 | `page34.lua` | Sprite Callbacks | `sprite.setDrawFunction`, `sprite.setUpdateFunction` |
| 35 | `page35.lua` | Line Query | `sprite.querySpritesAlongLine` |
| 36 | `page36.lua` | Clip Rect | `sprite.setClipRect`, `sprite.clearClipRect` |
| 37 | `page37.lua` | Stencil Pattern | `sprite.setStencilPattern`, `sprite.clearStencil` |

### Sound System (Pages 38-39)

| Page | File | Topic | APIs Tested |
|------|------|-------|-------------|
| 38 | `page38.lua` | WAV + Synth Music | `sound.sample.new`, `sound.sample.play`, `sound.sample.stop`, `sound.sample.free`, `sound.sample.isPlaying`, `sound.synth.new`, `sound.synth.playMIDINote`, `sound.synth.setAttack/Decay/Sustain/Release`, `sound.synth.setVolume` |
| 39 | `page39.lua` | MIDI Sequence Playback | `sound.sequence.new`, `sound.sequence.play`, `sound.sequence.stop`, `sound.sequence.free`, `sound.sequence.setLooping`, `sound.sequence.setProgramCallback`, `sound.sequence.setTrackInstrument`, `sound.instrument.new`, `sound.instrument.addVoice` |

---

## Page Module Structure

Every page module follows this consistent pattern:

```lua
-- pages/pageN.lua
-- Test Page N: Topic Description

PageN = {}

-- Optional: Called when navigating TO the page
function PageN.enter()
    -- Initialize resources (load sprites, start audio, etc.)
end

-- Optional: Called each frame for logic updates
function PageN.update()
    -- Handle input, update animations, check collisions
end

-- Required: Render the page content
function PageN.render(drawPageCounter)
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    -- Draw page content
    drawPageCounter()  -- Shows "Page X/39" in top-right
end

-- Optional: Called when navigating AWAY from the page
function PageN.exit()
    -- Cleanup resources (free sprites, stop audio, etc.)
end
```

---

## Navigation System

The main `app.lua` routes between pages using LEFT/RIGHT buttons:

| Button | Action |
|--------|--------|
| LEFT | Previous page (calls `exit()` then `enter()`) |
| RIGHT | Next page (calls `exit()` then `enter()`) |
| B | Exit application |

**Special Cases:**
- Page 6 (button test): Requires MODE button held for navigation to prevent interference with button state testing
- Pages 11-39: Call `exit()` on navigation for proper audio/sprite cleanup

---

## Double Buffering

Pages 13-39 use double buffering for smooth rendering:

```lua
local db_running = false

function PageN.render(drawPageCounter)
    if not db_running then
        vmupro.graphics.startDoubleBufferRenderer()
        db_running = true
    end

    vmupro.graphics.clear(vmupro.graphics.BLACK)
    -- Drawing operations...
    -- Note: Do NOT call vmupro.graphics.refresh()
end

function PageN.exit()
    if db_running then
        vmupro.graphics.stopDoubleBufferRenderer()
        db_running = false
    end
end
```

---

## Resource Management Pattern

Pages that allocate resources must implement proper cleanup:

```lua
local sprite_handle = nil

function PageN.enter()
    sprite_handle = vmupro.sprite.new("assets/image")
end

function PageN.exit()
    if sprite_handle then
        vmupro.sprite.free(sprite_handle)
        sprite_handle = nil
    end
end
```

---

## Font Constants

Available fonts for `vmupro.text.setFont()`:

| Constant | Size | Use Case |
|----------|------|----------|
| `FONT_TINY_6x8` | 6x8 | Compact labels, large text blocks |
| `FONT_MONO_7x13` | 7x13 | Monospace, code-like text |
| `FONT_SMALL` | ~8px | General purpose small text |
| `FONT_QUANTICO_15x16` | 15x16 | Medium titles |
| `FONT_OPEN_SANS_15x18` | 15x18 | Readable body text |
| `FONT_GABARITO_18x18` | 18x18 | Page titles |
| `FONT_QUANTICO_25x29` | 25x29 | Large headers |

---

## Color Constants

RGB565 colors available in `vmupro.graphics`:

| Constant | Hex Value | Visual |
|----------|-----------|--------|
| `BLACK` | 0x0000 | Black |
| `WHITE` | 0xFFFF | White |
| `RED` | 0xF800 | Red |
| `ORANGE` | 0xFBA0 | Orange |
| `YELLOW` | 0xFF80 | Yellow |
| `YELLOWGREEN` | 0x7F80 | Yellow-green |
| `GREEN` | 0x0500 | Green |
| `BLUE` | 0x045F | Blue |
| `NAVY` | 0x000C | Navy blue |
| `VIOLET` | 0x781F | Violet |
| `MAGENTA` | 0x780D | Magenta |
| `GREY` | 0xB5B6 | Gray |
| `VMUGREEN` | 0x6CD2 | VMU brand green |
| `VMUINK` | 0x288A | VMU brand ink |

---

## Flip Flags

For sprite drawing functions:

| Constant | Effect |
|----------|--------|
| `kImageUnflipped` | Normal orientation |
| `kImageFlippedX` | Horizontal flip |
| `kImageFlippedY` | Vertical flip |
| `kImageFlippedXY` | Both flips (180-degree rotation) |

---

## Waveform Types

For `vmupro.sound.synth.new()`:

| Constant | Waveform |
|----------|----------|
| `kWaveSine` | Sine wave (smooth) |
| `kWaveSquare` | Square wave (retro) |
| `kWaveTriangle` | Triangle wave (mellow) |
| `kWaveSawtooth` | Sawtooth wave (bright) |

---

## See Also

- `../AGENTS.md` - Parent examples documentation
- `../app.lua` - Main entry point with page router
- `../TEST_PLAN.md` - Detailed test documentation
- `../assets/` - Media resources (sprites, audio)
