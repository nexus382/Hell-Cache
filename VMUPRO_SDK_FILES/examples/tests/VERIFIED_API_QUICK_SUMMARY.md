# VMU Pro SDK - Verified API Quick Summary

**Last Updated:** 2025-01-05

## VERIFIED WORKING APIs (37 total) ✅

Tested on actual VMU Pro hardware via:
- `examples/hello_world/app.lua` (full working example)
- `emergency2.lua` (basic functionality test)

### Core Application
- `AppMain()` - Entry point function ✅
- `vmupro.apiVersion()` - Get SDK version ✅

### vmupro.system (12 APIs)
- `vmupro.system.log(level, tag, message)` - Logging ✅
- `vmupro.system.LOG_ERROR` (0) - Log level constant ✅
- `vmupro.system.LOG_WARN` (1) - Log level constant ✅
- `vmupro.system.LOG_INFO` (2) - Log level constant ✅
- `vmupro.system.LOG_DEBUG` (3) - Log level constant ✅
- `vmupro.system.getTimeUs()` - Get time in microseconds ✅
- `vmupro.system.delayMs(ms)` - Delay in milliseconds ✅
- `vmupro.system.delayUs(us)` - Delay in microseconds ✅
- `vmupro.system.sleep(ms)` - Sleep for ms ✅
- `vmupro.system.getMemoryUsage()` - Get memory used ✅
- `vmupro.system.getMemoryLimit()` - Get memory limit ✅
- `vmupro.system.getLargestFreeBlock()` - Get largest free block ✅
- `vmupro.system.getGlobalBrightness()` - Get brightness (0-255) ✅
- `vmupro.system.setGlobalBrightness(brightness)` - Set brightness ✅

### vmupro.graphics (10 APIs)
- `vmupro.graphics.clear(color)` - Clear display ✅
- `vmupro.graphics.refresh()` - Present back buffer ✅
- `vmupro.graphics.drawText(text, x, y, color, bg_color)` - Draw text ✅
- `vmupro.graphics.drawLine(x1, y1, x2, y2, color)` - Draw line ✅
- `vmupro.graphics.drawRect(x1, y1, x2, y2, color)` - Draw outline rect ✅
- `vmupro.graphics.drawFillRect(x1, y1, x2, y2, color)` - Draw filled rect ✅
- `vmupro.graphics.drawCircle(cx, cy, radius, color)` - Draw outline circle ✅
- `vmupro.graphics.drawCircleFilled(cx, cy, radius, color)` - Draw filled circle ✅

### Predefined Colors (14 constants)
- `vmupro.graphics.RED`, `ORANGE`, `YELLOW`, `YELLOWGREEN` ✅
- `vmupro.graphics.GREEN`, `BLUE`, `NAVY`, `VIOLET` ✅
- `vmupro.graphics.MAGENTA`, `GREY`, `BLACK`, `WHITE` ✅
- `vmupro.graphics.VMUGREEN`, `VMUINK` ✅

### vmupro.text (1 API)
- `vmupro.text.setFont(font)` - Set current font ✅
  - `vmupro.text.FONT_SMALL` ✅
  - `vmupro.text.FONT_GABARITO_18x18` ✅
  - `vmupro.text.FONT_GABARITO_22x24` ✅

### vmupro.input (11 APIs)
- `vmupro.input.read()` - Read input state ✅
- `vmupro.input.pressed(button)` - Button just pressed ✅
- `vmupro.input.released(button)` - Button just released ✅
- `vmupro.input.held(button)` - Button currently held ✅
- `vmupro.input.anythingHeld()` - Any button held ✅
- `vmupro.input.confirmPressed()` - A button pressed ✅
- `vmupro.input.confirmReleased()` - A button released ✅
- `vmupro.input.dismissPressed()` - B button pressed ✅
- `vmupro.input.dismissReleased()` - B button released ✅

### Button Constants (8 constants)
- `vmupro.input.UP` (0), `DOWN` (1), `RIGHT` (2), `LEFT` (3) ✅
- `vmupro.input.POWER` (4), `MODE` (5) ✅
- `vmupro.input.A` (6), `B` (7) ✅

---

## DOCUMENTED BUT NOT YET TESTED (63 APIs) 📚

From official SDK documentation but not yet verified on hardware:

### Audio/Sound (11 APIs)
- vmupro.audio.* - Volume control, listen mode
- vmupro.sound.sample.* - WAV loading, playback, volume, rate
- vmupro.sound.update() - Critical: call every frame

### Sprites (35 APIs)
- vmupro.sprite.* - Loading, drawing, effects, transforms
- vmupro.sprite.add/remove/removeAll - Scene management
- vmupro.sprite.*Collision* - Collision detection
- vmupro.sprite.playAnimation/stopAnimation - Animation

### File System (9 APIs)
- vmupro.file.* - read, write, exists, create, delete
- Restricted to `/sdcard/` directory only

### Additional Graphics (8 APIs)
- Ellipse, polygon, flood fill
- Framebuffer access (getBackFb, getFrontFb, getBackBuffer)

---

## INCORRECT APIS - DO NOT USE (20+ errors) ❌

These will cause crashes or don't exist:

### Critical Namespace Errors
- ❌ `vmupro.display.refresh()` → Use `vmupro.graphics.refresh()`
- ❌ `vmupro.system.getSystemTime()` → Use `vmupro.system.getTimeUs()`
- ❌ `import "api/time"` → Use `import "api/system"`
- ❌ `import "api/graphics"` → Use `import "api/display"`

### Input Errors
- ❌ `vmupro.input.BUTTON_UP` → Use `vmupro.input.UP` (no BUTTON_ prefix)
- ❌ `vmupro.input.BUTTON_START` → Doesn't exist (use POWER)
- ❌ `vmupro.input.BUTTON_SELECT` → Doesn't exist (use MODE)
- ❌ `vmupro.input.isButtonDown()` → Use `vmupro.input.held()`

### Drawing Errors
- ❌ `vmupro.graphics.drawRect(..., true)` → Use `vmupro.graphics.drawFillRect()`
- ❌ `vmupro.graphics.drawCircle(..., true)` → Use `vmupro.graphics.drawCircleFilled()`
- ❌ `vmupro.graphics.drawPixel()` → Doesn't exist
- ❌ `vmupro.sprite.render()` → Use `vmupro.sprite.draw()`

### Color Errors
- ❌ `vmupro.graphics.GRAY` → Use `vmupro.graphics.GREY`
- ❌ `vmupro.graphics.CYAN` → Doesn't exist, use custom RGB565 value

---

## CRITICAL RULES

### ✅ DO
1. Use `import "api/..."` for SDK modules
2. Call `vmupro.input.read()` ONCE per frame
3. Clear once, draw all, refresh once per frame
4. Use `vmupro.graphics.refresh()` (not display.refresh)
5. Use `vmupro.system.getTimeUs()` (not getSystemTime)
6. Use button constants without BUTTON_ prefix
7. Call `vmupro.sprite.removeAll()` on cleanup
8. Call `vmupro.sound.update()` every frame for audio
9. Return 0 from AppMain() for success

### ❌ DON'T
1. Use `require()` for SDK modules (use import)
2. Call `vmupro.input.read()` multiple times per frame
3. Use `vmupro.display.refresh()` (doesn't exist)
4. Use fill boolean in drawRect/drawCircle (wrong signature)
5. Use `vmupro.graphics.GRAY` (should be GREY)
6. Use `vmupro.graphics.CYAN` (doesn't exist)
7. Forget `vmupro.sprite.removeAll()` on cleanup
8. Forget `vmupro.sound.update()` for audio

---

## QUICK REFERENCE

### Import Statements
```lua
import "api/system"    -- System, timing, logging
import "api/display"   -- Graphics, display, text
import "api/input"     -- Button input
import "api/sprites"   -- Sprite management
import "api/audio"     -- Audio playback
import "api/file"      -- File operations
```

### Basic App Template
```lua
import "api/system"
import "api/display"
import "api/input"

function AppMain()
    local app_running = true

    while app_running do
        -- Read input ONCE per frame
        vmupro.input.read()

        -- Check for exit
        if vmupro.input.pressed(vmupro.input.B) then
            app_running = false
        end

        -- Clear display ONCE per frame
        vmupro.graphics.clear(vmupro.graphics.BLACK)

        -- Draw everything
        vmupro.graphics.drawText("Hello!", 10, 10,
            vmupro.graphics.WHITE, vmupro.graphics.BLACK)

        -- Present to screen ONCE per frame
        vmupro.graphics.refresh()

        -- Frame timing
        vmupro.system.delayMs(16)  -- ~60 FPS
    end

    return 0  -- Success
end
```

---

## DOCUMENTATION

- **Full Reference:** See `VERIFIED_API_REFERENCE.md` for complete details
- **API Issues:** See `API_ISSUES_ANALYSIS.md` for 53 identified issues in old tests
- **Official SDK:** See `/mnt/g/vmupro-game-extras/documentation/docs/api/`
- **Working Example:** `/mnt/g/vmupro-game-extras/documentation/examples/hello_world/app.lua`

---

**Status:** 37 verified APIs | 63 documented APIs | 20+ known incorrect usages
