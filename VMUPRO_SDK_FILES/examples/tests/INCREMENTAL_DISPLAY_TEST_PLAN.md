# Incremental Display Test Plan

## Goal

Isolate the exact display function causing crashes by testing display operations ONE AT A TIME, starting from a known working baseline.

## Problem Analysis

The existing test files (test_stage1.lua through test_stage6.lua) contain API inconsistencies that are likely causing crashes:

### Critical API Issues Found:

1. **Refresh Function**: Tests use `vmupro.display.refresh()` but correct API is `vmupro.graphics.refresh()`
2. **Time Function**: Tests use `vmupro.system.getSystemTime()` but correct API is `vmupro.system.getTimeUs()`
3. **Input Constants**: Tests use `vmupro.input.BUTTON_UP` but correct API is `vmupro.input.UP`
4. **Input Functions**: Tests use `vmupro.input.isButtonDown()` but correct API is `vmupro.input.held()`
5. **Sprite Functions**: Tests use `vmupro.sprite.render()` but this function doesn't exist in documented API
6. **DrawRect Signature**: Tests use `vmupro.graphics.drawRect(x, y, w, h, color, fill)` but correct is `vmupro.graphics.drawRect(x1, y1, x2, y2, color)` for outline and `vmupro.graphics.drawFillRect(x1, y1, x2, y2, color)` for filled

## Test Strategy

Create 5 incremental tests that add ONE display operation at a time, using ONLY the correct, documented APIs.

## Test Specifications

### Test Display 1: Basic Clear Test

**File**: `test_display_1.lua`

**Purpose**: Test if basic display clear works

**Code**:
```lua
import "api/system"
import "api/display"

function AppMain()
    -- Log start
    vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay1", "Starting basic clear test")

    -- Test 1: Clear screen once
    vmupro.graphics.clear(vmupro.graphics.BLACK)

    -- Hold for 1 second
    vmupro.system.delayUs(1000000)

    -- Test 2: Clear with different colors
    vmupro.graphics.clear(vmupro.graphics.WHITE)
    vmupro.system.delayUs(500000)

    vmupro.graphics.clear(vmupro.graphics.RED)
    vmupro.system.delayUs(500000)

    vmupro.graphics.clear(vmupro.graphics.VMUGREEN)
    vmupro.system.delayUs(500000)

    -- Log completion
    vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay1", "Clear test completed successfully")

    return 0
end
```

**Expected Behavior**:
- Screen should cycle through black, white, red, and VMU green colors
- Each color displays for 0.5-1 second
- App exits cleanly after 2.5 seconds

**What a Crash Means**:
- If crashes on FIRST clear: Display subsystem not initialized, import failure, or graphics namespace unavailable
- If crashes on color change: RGB565 color constants are invalid
- If crashes during delay: System timing functions broken

**Success Criteria**:
- No crashes
- Colors visible on screen
- Clean exit with return code 0

---

### Test Display 2: Clear + Refresh Test

**File**: `test_display_2.lua`

**Purpose**: Test if display buffer swap works

**Code**:
```lua
import "api/system"
import "api/display"

function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay2", "Starting clear + refresh test")

    local frame_count = 0
    local max_frames = 60  -- 1 second at 60fps

    while frame_count < max_frames do
        -- Alternate colors each frame
        if frame_count % 2 == 0 then
            vmupro.graphics.clear(vmupro.graphics.BLACK)
        else
            vmupro.graphics.clear(vmupro.graphics.WHITE)
        end

        -- CRITICAL TEST: This is where crashes likely occur
        vmupro.graphics.refresh()

        -- Frame timing
        vmupro.system.delayUs(16667)  -- ~60 FPS

        frame_count = frame_count + 1
    end

    vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay2", "Refresh test completed")
    vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay2", "Total frames: " .. frame_count)

    return 0
end
```

**Expected Behavior**:
- Screen should flicker between black and white at 60fps for 1 second
- ~30 visible color changes
- Smooth animation

**What a Crash Means**:
- If crashes immediately on first refresh(): Double-buffering not working, back buffer invalid
- If crashes after N frames: Memory corruption, buffer overflow, or state accumulation
- If no display output: Front/back buffer swap broken

**Success Criteria**:
- No crashes during all 60 frames
- Visible flickering indicates proper buffer swapping
- Clean exit with logged frame count

---

### Test Display 3: Clear + Refresh + DrawText Test

**File**: `test_display_3.lua`

**Purpose**: Test if text rendering works

**Code**:
```lua
import "api/system"
import "api/display"

function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay3", "Starting text rendering test")

    local frame_count = 0
    local max_frames = 180  -- 3 seconds

    while frame_count < max_frames do
        -- Clear screen
        vmupro.graphics.clear(vmupro.graphics.BLACK)

        -- CRITICAL TEST: Draw text (uses default font)
        vmupro.graphics.drawText("Test 3", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        vmupro.graphics.drawText("Frame: " .. frame_count, 10, 30, vmupro.graphics.YELLOW, vmupro.graphics.BLACK)
        vmupro.graphics.drawText("ABCabc123", 10, 50, vmupro.graphics.GREEN, vmupro.graphics.BLACK)

        -- Refresh display
        vmupro.graphics.refresh()

        -- Frame timing
        vmupro.system.delayUs(16667)

        frame_count = frame_count + 1
    end

    vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay3", "Text test completed")

    return 0
end
```

**Expected Behavior**:
- Display shows 3 lines of text:
  - "Test 3" in white at y=10
  - "Frame: N" (incrementing) in yellow at y=30
  - "ABCabc123" in green at y=50
- Frame counter updates smoothly for 3 seconds
- Text is legible on black background

**What a Crash Means**:
- If crashes on first drawText(): Font system not initialized, text rendering unavailable
- If crashes on string concatenation: Lua string handling issue with frame_count
- If crashes after N frames: Text rendering memory leak
- If displays garbage: Font glyph data invalid or RGB565 color conversion broken

**Success Criteria**:
- All 3 text lines visible and readable
- Frame counter increments smoothly 0-179
- No crashes during 180 frames
- Text colors match expected values

---

### Test Display 4: Add Font Selection Test

**File**: `test_display_4.lua`

**Purpose**: Test if font switching works

**Code**:
```lua
import "api/system"
import "api/display"

function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay4", "Starting font selection test")

    local frame_count = 0
    local max_frames = 240  -- 4 seconds
    local fonts = {
        vmupro.text.FONT_SMALL,
        vmupro.text.FONT_GABARITO_18x18,
        vmupro.text.FONT_GABARITO_22x24
    }
    local font_names = {"FONT_SMALL", "GABARITO_18x18", "GABARITO_22x24"}

    while frame_count < max_frames do
        -- Clear screen
        vmupro.graphics.clear(vmupro.graphics.VMUGREEN)

        -- Cycle through fonts every 60 frames
        local font_index = math.floor(frame_count / 60) % 3 + 1
        local current_font = fonts[font_index]

        -- CRITICAL TEST: Set font before drawing
        vmupro.text.setFont(current_font)

        -- Draw text with current font
        vmupro.graphics.drawText("Font Test", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.VMUGREEN)
        vmupro.graphics.drawText(font_names[font_index], 10, 40, vmupro.graphics.WHITE, vmupro.graphics.VMUGREEN)
        vmupro.graphics.drawText("Frame: " .. frame_count, 10, 70, vmupro.graphics.YELLOW, vmupro.graphics.VMUGREEN)

        -- Draw size comparison
        if font_index == 1 then
            vmupro.graphics.drawText("Small Font", 10, 100, vmupro.graphics.GREY, vmupro.graphics.VMUGREEN)
        elseif font_index == 2 then
            vmupro.graphics.drawText("Medium Font", 10, 100, vmupro.graphics.GREY, vmupro.graphics.VMUGREEN)
        else
            vmupro.graphics.drawText("Large Font", 10, 100, vmupro.graphics.GREY, vmupro.graphics.VMUGREEN)
        end

        -- Refresh display
        vmupro.graphics.refresh()

        -- Frame timing
        vmupro.system.delayUs(16667)

        frame_count = frame_count + 1
    end

    vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay4", "Font test completed")

    return 0
end
```

**Expected Behavior**:
- Screen cycles through 3 different fonts every ~1 second
- Each font size should be visibly different:
  - FONT_SMALL: Smallest text
  - FONT_GABARITO_18x18: Medium text
  - FONT_GABARITO_22x24: Largest text
- Font name displayed to confirm active font
- Smooth transitions between fonts

**What a Crash Means**:
- If crashes on first setFont(): Font system not available, vmupro.text namespace missing
- If crashes when switching fonts: Font data invalid, memory corruption during font switch
- If crashes on specific font: That font's glyph data is invalid or missing
- If displays boxes/squares: Font glyph data not loaded properly

**Success Criteria**:
- All 3 fonts render correctly
- Font sizes clearly different
- Smooth cycling through all fonts
- No crashes during font switches
- Text remains legible in all fonts

---

### Test Display 5: Full Hello World Style Test

**File**: `test_display_5.lua`

**Purpose**: Test complete rendering like hello_world example

**Code**:
```lua
import "api/system"
import "api/display"
import "api/input"

function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay5", "Starting full render test")

    local app_running = true
    local frame_count = 0
    local max_frames = 300  -- 5 seconds

    -- Get start time
    local start_time = vmupro.system.getTimeUs()

    -- Initialize font (like hello_world)
    vmupro.text.setFont(vmupro.text.FONT_SMALL)

    while app_running and frame_count < max_frames do
        -- Read input (once per frame - REQUIRED by SDK rules)
        vmupro.input.read()

        -- Check for B button to exit early
        if vmupro.input.pressed(vmupro.input.B) then
            vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay5", "Exit requested")
            app_running = false
            break
        end

        -- Clear screen with VMU green background
        vmupro.graphics.clear(vmupro.graphics.VMUGREEN)

        -- Draw title with large font
        vmupro.text.setFont(vmupro.text.FONT_GABARITO_22x24)
        vmupro.graphics.drawText("VMUPro SDK", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.VMUGREEN)

        -- Draw hello world message
        vmupro.text.setFont(vmupro.text.FONT_GABARITO_18x18)
        vmupro.graphics.drawText("Hello World!", 10, 35, vmupro.graphics.WHITE, vmupro.graphics.VMUGREEN)

        -- Draw frame counter
        vmupro.text.setFont(vmupro.text.FONT_SMALL)
        local frame_text = "Frame: " .. frame_count
        vmupro.graphics.drawText(frame_text, 10, 55, vmupro.graphics.YELLOW, vmupro.graphics.VMUGREEN)

        -- Draw uptime
        local current_time = vmupro.system.getTimeUs()
        local uptime_ms = math.floor((current_time - start_time) / 1000)
        local uptime_text = "Uptime: " .. uptime_ms .. "ms"
        vmupro.graphics.drawText(uptime_text, 10, 75, vmupro.graphics.BLUE, vmupro.graphics.VMUGREEN)

        -- Draw available namespaces info
        vmupro.graphics.drawText("Namespaces:", 10, 105, vmupro.graphics.WHITE, vmupro.graphics.VMUGREEN)
        vmupro.graphics.drawText("graphics, sprites, audio", 10, 125, vmupro.graphics.GREY, vmupro.graphics.VMUGREEN)
        vmupro.graphics.drawText("input, file, system, text", 10, 145, vmupro.graphics.GREY, vmupro.graphics.VMUGREEN)

        -- Draw controls
        vmupro.graphics.drawText("Press B to exit", 10, 175, vmupro.graphics.WHITE, vmupro.graphics.VMUGREEN)

        -- Draw decorative rectangle
        vmupro.graphics.drawRect(5, 5, 230, 230, vmupro.graphics.WHITE)

        -- Refresh display
        vmupro.graphics.refresh()

        -- Frame timing
        vmupro.system.delayMs(16)  -- ~60 FPS

        frame_count = frame_count + 1

        -- Log every 60 frames
        if frame_count % 60 == 0 then
            vmupro.system.log(vmupro.system.LOG_DEBUG, "TestDisplay5", "Running... Frame: " .. frame_count)
        end
    end

    -- Cleanup and exit
    vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay5", "Application completed")
    vmupro.system.log(vmupro.system.LOG_INFO, "TestDisplay5", "Total frames: " .. frame_count)

    return 0
end
```

**Expected Behavior**:
- Display matches hello_world example exactly:
  - Title "VMUPro SDK" in large font (22x24)
  - "Hello World!" in medium font (18x18)
  - Frame counter in small font, updates every frame
  - Uptime counter in milliseconds
  - List of available namespaces
  - "Press B to exit" message
  - White border rectangle
- B button exits early (optional)
- Runs for 5 seconds or until B pressed
- Logs every 60 frames

**What a Crash Means**:
- If crashes on first frame: Complex rendering state machine broken
- If crashes after font switching: Font state management corrupted
- If crashes when drawing rectangle: Primitive rendering conflicts with text
- If crashes on B button: Input system interaction with display broken
- If crashes at specific frame count: Memory leak or buffer overflow

**Success Criteria**:
- All text elements render correctly
- Frame counter increments smoothly
- Uptime displays realistic values
- Rectangle border visible
- B button exits cleanly
- No crashes during 5-second run
- Logs show debug messages every 60 frames
- Matches hello_world example output

---

## Test Execution Order

Execute tests in order, stopping at the first failure:

1. **test_display_1.lua** - Verify basic clear works
2. **test_display_2.lua** - Verify buffer swapping works
3. **test_display_3.lua** - Verify text rendering works
4. **test_display_4.lua** - Verify font switching works
5. **test_display_5.lua** - Verify full complex rendering works

## Build Instructions

For each test:

```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer

python packer.py \
    --projectdir ../../examples/tests \
    --appname test_display_1 \
    --meta ../../examples/tests/test_display_1_metadata.json \
    --sdkversion 1.0.0 \
    --icon ../../examples/tests/icon.bmp
```

## Deployment Instructions

```bash
python send.py \
    --func send \
    --localfile build/test_display_1.vmupack \
    --remotefile apps/test_display_1.vmupack \
    --comport COM3 \
    --exec \
    --monitor
```

## Metadata Template

Each test needs a metadata file:

```json
{
  "metadata_version": 1,
  "app_name": "Test Display 1",
  "app_author": "Debug",
  "app_version": "0.1.0",
  "app_entry_point": "test_display_1.lua",
  "app_mode": 1,
  "app_environment": "lua",
  "icon_transparency": false,
  "resources": ["test_display_1.lua"]
}
```

## Expected Test Results Matrix

| Test | Function Tested | If PASS | If FAIL |
|------|----------------|---------|---------|
| test_display_1 | vmupro.graphics.clear() | Display subsystem working | Display not initialized or colors invalid |
| test_display_2 | vmupro.graphics.refresh() | Double-buffering working | Buffer swap broken or memory corruption |
| test_display_3 | vmupro.graphics.drawText() | Font rendering working | Font system unavailable or glyph data invalid |
| test_display_4 | vmupro.text.setFont() | Font switching working | Font data corrupted or memory leak on switch |
| test_display_5 | Full rendering pipeline | Complete display system working | Complex state management broken |

## API Compliance Verification

All tests use ONLY documented, verified APIs:

- ✅ `vmupro.graphics.clear()` - Verified in docs/api/display.md
- ✅ `vmupro.graphics.refresh()` - Verified in docs/api/display.md
- ✅ `vmupro.graphics.drawText()` - Verified in docs/api/display.md
- ✅ `vmupro.text.setFont()` - Verified in docs/api/display.md
- ✅ `vmupro.input.read()` - Verified in docs/api/input.md
- ✅ `vmupro.input.pressed()` - Verified in docs/api/input.md
- ✅ `vmupro.system.log()` - Verified in docs/api/system.md
- ✅ `vmupro.system.getTimeUs()` - Verified in docs/api/system.md
- ✅ `vmupro.system.delayMs()` - Verified in docs/api/system.md
- ✅ `vmupro.system.delayUs()` - Verified in docs/api/system.md
- ✅ Color constants - Verified in docs/api/display.md

## Next Steps After Testing

### If Test Display 1 Fails:
- Check import statements
- Verify display module loaded
- Test without any graphics calls

### If Test Display 2 Fails:
- Double-buffering implementation issue
- Check framebuffer allocation
- Test with single buffer if available

### If Test Display 3 Fails:
- Font system initialization issue
- Check if default font loaded
- Try different text strings

### If Test Display 4 Fails:
- Font data corruption
- Check font switching mechanism
- Test each font individually

### If Test Display 5 Fails:
- Complex state management issue
- Memory leak detection
- Reduce complexity gradually

## Summary

This incremental test plan will:

1. ✅ Isolate the exact display function causing crashes
2. ✅ Use only verified, documented APIs
3. ✅ Provide clear success/failure criteria
4. ✅ Include expected behavior for each test
5. ✅ Explain what crashes mean for diagnosis
6. ✅ Build from simple to complex incrementally
7. ✅ Match real SDK usage patterns
8. ✅ Include build and deployment instructions

Start with test_display_1.lua and work upward. Stop at first failure and diagnose based on "What a Crash Means" section.
