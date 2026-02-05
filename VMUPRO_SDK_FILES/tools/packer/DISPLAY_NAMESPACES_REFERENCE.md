# VMU Pro Display Namespaces Reference Guide

## Executive Summary

The VMU Pro LUA SDK provides display and graphics functionality through **THREE distinct namespaces** that serve different purposes:

1. **`vmupro.graphics`** - Drawing operations, display management, and color constants
2. **`vmupro.text`** - Font selection and text measurement utilities
3. **`vmupro.display`** - Legacy/alternative display refresh functions

**Critical Import:** All three namespaces are enabled by a single import:
```lua
import "api/display"  -- Enables graphics, text, AND display namespaces
```

---

## Namespace Quick Reference

| Operation | Correct Namespace | Example |
|-----------|------------------|---------|
| Draw shapes (rect, circle, line, polygon) | `vmupro.graphics.*` | `vmupro.graphics.drawRect()` |
| Draw text | `vmupro.graphics.drawText()` | `vmupro.graphics.drawText()` |
| Clear screen | `vmupro.graphics.clear()` | `vmupro.graphics.clear()` |
| Refresh display | `vmupro.graphics.refresh()` or `vmupro.display.refresh()` | Both work |
| Set font | `vmupro.text.setFont()` | `vmupro.text.setFont()` |
| Measure text | `vmupro.text.calcLength()` | `vmupro.text.calcLength()` |
| Get/set brightness | `vmupro.system.*` | `vmupro.system.setGlobalBrightness()` |
| Color constants | `vmupro.graphics.*` | `vmupro.graphics.RED` |
| Font constants | `vmupro.text.*` | `vmupro.text.FONT_SMALL` |

---

## 1. vmupro.graphics Namespace

### Purpose
Core drawing operations, display buffer management, and color definitions.

### Import
```lua
import "api/display"  -- Single import enables graphics, text, and display
```

### Display Management Functions

#### `vmupro.graphics.clear(color)`
Clear the display buffer with a solid color.

```lua
vmupro.graphics.clear(vmupro.graphics.BLACK)  -- Clear to black
vmupro.graphics.clear(0x0000)                 -- Clear using RGB565 value
```

**Parameters:**
- `color` (number, optional): RGB565 color value. Defaults to black if not specified.

**Returns:** None

**Best Practices:**
- Call ONCE per frame at the start of rendering
- Use predefined color constants for readability
- Always clear before drawing a new frame

---

#### `vmupro.graphics.refresh()`
Present the back buffer to the screen (standard double-buffering).

```lua
vmupro.graphics.clear(vmupro.graphics.BLACK)
-- ... drawing operations ...
vmupro.graphics.refresh()  -- Make drawing visible
```

**Parameters:** None

**Returns:** None

**Best Practices:**
- Call ONCE per frame after all drawing is complete
- Never call multiple times per frame (wastes performance)
- Use with double buffering for smooth animation

---

#### `vmupro.graphics.getGlobalBrightness()`
Get the current display brightness level.

```lua
local brightness = vmupro.graphics.getGlobalBrightness()
```

**Returns:** number (0-255)

**Note:** This is a DUPLICATE of `vmupro.system.getGlobalBrightness()`. Use `vmupro.system.*` for consistency.

---

#### `vmupro.graphics.setGlobalBrightness(brightness)`
Set the display brightness level.

```lua
vmupro.graphics.setGlobalBrightness(128)  -- 50% brightness
```

**Parameters:**
- `brightness` (number): Brightness level 0-255

**Note:** This is a DUPLICATE of `vmupro.system.setGlobalBrightness()`. Use `vmupro.system.*` for consistency.

---

### Drawing Primitives

#### `vmupro.graphics.drawLine(x1, y1, x2, y2, color)`
Draw a straight line between two points.

```lua
vmupro.graphics.drawLine(0, 0, 239, 239, vmupro.graphics.RED)
```

**Parameters:**
- `x1, y1` (number): Starting coordinates
- `x2, y2` (number): Ending coordinates
- `color` (number): RGB565 color value

**Use Cases:**
- Drawing UI borders and separators
- Creating custom shapes and patterns
- Debug rendering (hitboxes, collision boundaries)

---

#### `vmupro.graphics.drawRect(x1, y1, x2, y2, color)`
Draw a rectangle outline (not filled).

```lua
-- Draw border from (10,10) to (100,80)
vmupro.graphics.drawRect(10, 10, 100, 80, vmupro.graphics.WHITE)
```

**Parameters:**
- `x1, y1` (number): Top-left corner
- `x2, y2` (number): Bottom-right corner
- `color` (number): RGB565 color value

**Common Mistake:** Confusing with `(x, y, width, height)` format. This function uses TWO CORNERS.

---

#### `vmupro.graphics.drawFillRect(x1, y1, x2, y2, color)`
Draw a filled rectangle.

```lua
-- Draw filled button
vmupro.graphics.drawFillRect(10, 10, 100, 40, vmupro.graphics.BLUE)
```

**Parameters:**
- `x1, y1` (number): Top-left corner
- `x2, y2` (number): Bottom-right corner
- `color` (number): RGB565 color value

**Use Cases:**
- Backgrounds and UI panels
- Buttons and interactive elements
- Filling regions with solid colors

---

#### `vmupro.graphics.drawCircle(center_x, center_y, radius, color)`
Draw a circle outline.

```lua
vmupro.graphics.drawCircle(120, 120, 50, vmupro.graphics.YELLOW)
```

**Parameters:**
- `center_x, center_y` (number): Center coordinates
- `radius` (number): Circle radius in pixels
- `color` (number): RGB565 color value

---

#### `vmupro.graphics.drawCircleFilled(center_x, center_y, radius, color)`
Draw a filled circle.

```lua
vmupro.graphics.drawCircleFilled(120, 120, 30, vmupro.graphics.RED)
```

**Parameters:**
- `center_x, center_y` (number): Center coordinates
- `radius` (number): Circle radius in pixels
- `color` (number): RGB565 color value

---

#### `vmupro.graphics.drawEllipse(center_x, center_y, radius_x, radius_y, color)`
Draw an ellipse outline.

```lua
-- Wide ellipse
vmupro.graphics.drawEllipse(120, 120, 60, 30, vmupro.graphics.GREEN)
```

**Parameters:**
- `center_x, center_y` (number): Center coordinates
- `radius_x` (number): Horizontal radius
- `radius_y` (number): Vertical radius
- `color` (number): RGB565 color value

---

#### `vmupro.graphics.drawEllipseFilled(center_x, center_y, radius_x, radius_y, color)`
Draw a filled ellipse.

```lua
vmupro.graphics.drawEllipseFilled(120, 120, 60, 30, vmupro.graphics.BLUE)
```

**Parameters:**
- `center_x, center_y` (number): Center coordinates
- `radius_x` (number): Horizontal radius
- `radius_y` (number): Vertical radius
- `color` (number): RGB565 color value

---

#### `vmupro.graphics.drawPolygon(points, color)`
Draw a polygon outline from an array of points.

```lua
local triangle = {{50, 20}, {20, 80}, {80, 80}}
vmupro.graphics.drawPolygon(triangle, vmupro.graphics.MAGENTA)
```

**Parameters:**
- `points` (table): Array of `{x, y}` coordinate pairs
- `color` (number): RGB565 color value

**Use Cases:**
- Custom shapes and icons
- Triangular UI elements
- Geometric patterns

---

#### `vmupro.graphics.drawPolygonFilled(points, color)`
Draw a filled polygon.

```lua
local diamond = {{100, 50}, {120, 100}, {100, 150}, {80, 100}}
vmupro.graphics.drawPolygonFilled(diamond, vmupro.graphics.VIOLET)
```

**Parameters:**
- `points` (table): Array of `{x, y}` coordinate pairs
- `color` (number): RGB565 color value

---

### Text Rendering

#### `vmupro.graphics.drawText(text, x, y, color, bg_color)`
Draw text at the specified position using the CURRENT font.

```lua
vmupro.text.setFont(vmupro.text.FONT_SMALL)
vmupro.graphics.drawText("Hello World", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
```

**Parameters:**
- `text` (string): Text string to draw
- `x` (number): X coordinate
- `y` (number): Y coordinate
- `color` (number): RGB565 text color
- `bg_color` (number, optional): RGB565 background color. Defaults to black.

**Critical Notes:**
- Font must be set FIRST using `vmupro.text.setFont()`
- This function uses the CURRENT font (set via `vmupro.text.setFont()`)
- Background color fills the text bounding box
- Supports ASCII characters

**Common Mistakes:**
1. Forgetting to call `vmupro.text.setFont()` first
2. Assuming this function takes a font parameter (it doesn't!)
3. Not accounting for text width in layout calculations

---

### Fill Operations

#### `vmupro.graphics.floodFill(x, y, fill_color, boundary_color)`
Perform flood fill starting from a point.

```lua
vmupro.graphics.floodFill(50, 50, vmupro.graphics.GREEN, vmupro.graphics.BLACK)
```

**Parameters:**
- `x, y` (number): Starting coordinates
- `fill_color` (number): RGB565 color to fill with
- `boundary_color` (number): RGB565 boundary color to stop at

**Use Cases:**
- Paint bucket tools
- Creating complex filled regions
- Image processing effects

---

#### `vmupro.graphics.floodFillTolerance(x, y, fill_color, tolerance)`
Perform flood fill with color tolerance.

```lua
vmupro.graphics.floodFillTolerance(50, 50, vmupro.graphics.GREEN, 10)
```

**Parameters:**
- `x, y` (number): Starting coordinates
- `fill_color` (number): RGB565 color to fill with
- `tolerance` (number): Color matching tolerance

---

### Framebuffer Access

#### `vmupro.graphics.getBackFb()`
Get a reference to the back framebuffer.

```lua
local back_fb = vmupro.graphics.getBackFb()
```

**Returns:** userdata (framebuffer reference)

**Advanced Use:** Direct pixel manipulation and custom rendering algorithms.

---

#### `vmupro.graphics.getFrontFb()`
Get a reference to the front framebuffer.

```lua
local front_fb = vmupro.graphics.getFrontFb()
```

**Returns:** userdata (framebuffer reference)

---

#### `vmupro.graphics.getBackBuffer()`
Get a reference to the back buffer.

```lua
local back_buffer = vmupro.graphics.getBackBuffer()
```

**Returns:** userdata (buffer reference)

---

### Special Effects

#### `vmupro.graphics.applyMosaicToScreen(x, y, width, height, mosaic_size)`
Apply pixelation/mosaic effect to a screen region.

```lua
-- Pixelate entire screen with 8x8 blocks
vmupro.graphics.applyMosaicToScreen(0, 0, 240, 240, 8)

-- Heavy pixelation on small area
vmupro.graphics.applyMosaicToScreen(10, 10, 64, 64, 16)
```

**Parameters:**
- `x, y` (number): Top-left corner of region
- `width` (number): Width of region in pixels
- `height` (number): Height of region in pixels
- `mosaic_size` (number): Size of mosaic blocks (1 = no effect, larger = more pixelated)

**Use Cases:**
- Transition effects
- Censoring/blurring
- Retro visual effects
- Damage indicators

---

### Double Buffer Management

#### `vmupro.graphics.startDoubleBufferRenderer()`
Initialize the double buffering system.

```lua
function AppMain()
    vmupro.graphics.startDoubleBufferRenderer()
    -- ... application code ...
end
```

**Call Once:** At application initialization

**Benefits:**
- Eliminates screen flicker
- Smooth animation
- Professional rendering quality

---

#### `vmupro.graphics.stopDoubleBufferRenderer()`
Stop the double buffering system and free resources.

```lua
function cleanup()
    vmupro.graphics.stopDoubleBufferRenderer()
end
```

**Call Once:** At application exit

---

#### `vmupro.graphics.pushDoubleBufferFrame()`
Push the completed frame to the display (used with double buffering).

```lua
vmupro.graphics.clear(vmupro.graphics.BLACK)
-- ... all drawing operations ...
vmupro.graphics.pushDoubleBufferFrame()  -- Instead of refresh()
```

**Note:** Use this INSTEAD of `vmupro.graphics.refresh()` when double buffering is enabled.

---

#### `vmupro.graphics.pauseDoubleBufferRenderer()`
Temporarily pause double buffering.

```lua
vmupro.graphics.pauseDoubleBufferRenderer()
```

**Use Cases:**
- Menu screens that don't update continuously
- Loading screens
- Static displays

**Performance:** Can improve battery life on static screens.

---

#### `vmupro.graphics.resumeDoubleBufferRenderer()`
Resume double buffering after pausing.

```lua
vmupro.graphics.resumeDoubleBufferRenderer()
```

---

### Color Constants (RGB565 Format)

Predefined colors in `vmupro.graphics` namespace:

```lua
vmupro.graphics.RED = 0xF800           -- Pure red
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
vmupro.graphics.VMUGREEN = 0x6CD2      -- VMU Pro brand green
vmupro.graphics.VMUINK = 0x288A        -- VMU Pro brand ink color
```

**Best Practices:**
- Use constants instead of raw RGB565 values for readability
- Define custom colors at initialization, not in render loop
- Consider color accessibility (contrast ratios)

**Custom Color Conversion:**
```lua
function rgb_to_565(r, g, b)
    -- Convert 8-bit RGB (0-255) to RGB565
    local r5 = math.floor((r * 31) / 255)
    local g6 = math.floor((g * 63) / 255)
    local b5 = math.floor((b * 31) / 255)
    return (r5 << 11) | (g6 << 5) | b5
end

local custom_purple = rgb_to_565(128, 0, 128)
```

---

## 2. vmupro.text Namespace

### Purpose
Font management and text measurement utilities.

### Import
```lua
import "api/display"  -- Same import as graphics
```

### Font Management Functions

#### `vmupro.text.setFont(font_id)`
Set the current font for text rendering.

```lua
vmupro.text.setFont(vmupro.text.FONT_SMALL)
vmupro.graphics.drawText("Small text", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)

vmupro.text.setFont(vmupro.text.FONT_LARGE)
vmupro.graphics.drawText("Large text", 10, 50, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
```

**Parameters:**
- `font_id` (number): Font ID from `vmupro.text` font constants

**Critical Notes:**
- Must be called BEFORE `vmupro.graphics.drawText()`
- Affects ALL subsequent `vmupro.graphics.drawText()` calls
- Font setting is global (not per-text)

**Best Practices:**
- Set font at the start of render cycle
- Use font constants for readability
- Group text by font to minimize font changes

---

### Font Constants

#### Primary Fonts

```lua
vmupro.text.FONT_TINY_6x8 = 0           -- Smallest: 6×8 pixels
vmupro.text.FONT_MONO_7x13 = 1          -- Tiny monospace: 7×13 pixels
```

**Use Cases:**
- Debug information
- UI labels and status text
- Large amounts of text (logs, data displays)

#### Quantico Font Family (UI Fonts)

```lua
vmupro.text.FONT_QUANTICO_15x16 = 2     -- Medium: 15×16 pixels
vmupro.text.FONT_QUANTICO_18x20 = 3     -- Medium: 18×20 pixels
vmupro.text.FONT_QUANTICO_19x21 = 4     -- Medium: 19×21 pixels
vmupro.text.FONT_QUANTICO_25x29 = 5     -- Large: 25×29 pixels
vmupro.text.FONT_QUANTICO_29x33 = 6     -- Extra Large: 29×33 pixels
vmupro.text.FONT_QUANTICO_32x37 = 7     -- Largest: 32×37 pixels
```

**Use Cases:**
- Game UI elements
- Titles and headers
- Button text
- HUD displays

#### Gabarito Font Family

```lua
vmupro.text.FONT_GABARITO_18x18 = 8     -- Medium: 18×18 pixels
vmupro.text.FONT_GABARITO_22x24 = 9     -- Large: 22×24 pixels
```

**Use Cases:**
- Game titles
- Score displays
- Prominent text

#### Open Sans Font Family

```lua
vmupro.text.FONT_OPEN_SANS_15x18 = 10   -- Medium: 15×18 pixels
vmupro.text.FONT_OPEN_SANS_21x24 = 11   -- Large: 21×24 pixels
```

**Use Cases:**
- Body text
- Readable paragraphs
- Menu items

#### Convenience Aliases

```lua
vmupro.text.FONT_SMALL = 1              -- Alias for MONO_7x13
vmupro.text.FONT_MEDIUM = 10            -- Alias for OPEN_SANS_15x18
vmupro.text.FONT_LARGE = 5              -- Alias for QUANTICO_25x29
vmupro.text.FONT_DEFAULT = 10           -- Alias for MEDIUM (OPEN_SANS_15x18)
```

**Best Practices:**
- Use aliases (`FONT_SMALL`, `FONT_MEDIUM`, `FONT_LARGE`) for portability
- Reserve `FONT_TINY_6x8` for debug text
- Use larger fonts sparingly (screen space is limited)

---

#### `vmupro.text.calcLength(text)`
Calculate the pixel width of text using the CURRENT font.

```lua
vmupro.text.setFont(vmupro.text.FONT_SMALL)
local text = "Hello World"
local width = vmupro.text.calcLength(text)  -- Returns width in pixels
vmupro.graphics.drawText(text, 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
```

**Parameters:**
- `text` (string): Text string to measure

**Returns:** number (width in pixels)

**Critical Notes:**
- Uses the CURRENT font (set via `vmupro.text.setFont()`)
- Must set font BEFORE calling this function
- Only measures width, not height (height is based on font)

**Use Cases:**
- Centering text: `x = (screen_width - text_width) / 2`
- Right-aligning text: `x = screen_width - text_width - margin`
- Text wrapping logic
- UI layout calculations

**Common Mistake:** Calling `calcLength()` before `setFont()` - results will be incorrect.

---

#### `vmupro.text.getFontInfo()`
Get information about the current font.

```lua
local info = vmupro.text.getFontInfo()
-- Returns table with font information
```

**Returns:** table (font metadata)

**Note:** Documentation is limited on the exact structure of the returned table.

---

### Text Layout Examples

#### Center Text Horizontally
```lua
function drawCenteredText(y, text, color, bg_color)
    local text_width = vmupro.text.calcLength(text)
    local x = (240 - text_width) / 2
    vmupro.graphics.drawText(text, x, y, color, bg_color)
end

-- Usage
vmupro.text.setFont(vmupro.text.FONT_MEDIUM)
drawCenteredText(120, "GAME OVER", vmupro.graphics.RED, vmupro.graphics.BLACK)
```

#### Right-Align Text
```lua
function drawRightAlignedText(y, text, margin, color, bg_color)
    local text_width = vmupro.text.calcLength(text)
    local x = 240 - text_width - margin
    vmupro.graphics.drawText(text, x, y, color, bg_color)
end

-- Usage
vmupro.text.setFont(vmupro.text.FONT_SMALL)
drawRightAlignedText(10, "Score: 1000", 5, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
```

#### Multi-Line Text
```lua
function drawMultilineText(x, y, lines, color, bg_color)
    local line_height = 15  -- Adjust based on font
    for i, line in ipairs(lines) do
        vmupro.graphics.drawText(line, x, y + (i - 1) * line_height, color, bg_color)
    end
end

-- Usage
vmupro.text.setFont(vmupro.text.FONT_SMALL)
drawMultilineText(10, 50, {
    "Line 1",
    "Line 2",
    "Line 3"
}, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
```

---

## 3. vmupro.display Namespace

### Purpose
Legacy/alternative display refresh functions.

### Import
```lua
import "api/display"  -- Same import as graphics
```

### Functions

#### `vmupro.display.refresh()`
Alternative display refresh function.

```lua
vmupro.graphics.clear(vmupro.graphics.BLACK)
vmupro.graphics.drawText("Hello", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
vmupro.display.refresh()  -- Alternative to vmupro.graphics.refresh()
```

**Parameters:** None

**Returns:** None

**Relationship to vmupro.graphics.refresh():**
- Functionally identical to `vmupro.graphics.refresh()`
- Used in older test files
- **Recommendation:** Use `vmupro.graphics.refresh()` for consistency

**Note:** This namespace appears to be a legacy alias. New code should prefer `vmupro.graphics.refresh()`.

---

## 4. Brightness Functions (vmupro.system Namespace)

### Critical Distinction
Brightness functions are available in BOTH `vmupro.graphics` and `vmupro.system`, but **`vmupro.system` is the canonical location**.

### Recommended Usage

#### `vmupro.system.getGlobalBrightness()`
Get the current brightness level.

```lua
local brightness = vmupro.system.getGlobalBrightness()
vmupro.system.log(vmupro.system.LOG_INFO, "App", "Brightness: " .. brightness)
```

**Returns:** number (0-255)

---

#### `vmupro.system.setGlobalBrightness(brightness)`
Set the brightness level.

```lua
vmupro.system.setGlobalBrightness(128)  -- 50% brightness
vmupro.system.setGlobalBrightness(255)  -- 100% brightness
```

**Parameters:**
- `brightness` (number): Brightness level (0-255)

**Use Cases:**
- User-configurable brightness settings
- Power saving (dim screen during idle)
- Visual effects (flash, pulse)

**Best Practice:** Always use `vmupro.system.*` for brightness, NOT `vmupro.graphics.*`.

---

## Namespace Relationships and Confusion Points

### The "Text Confusion"

#### Common Mistake #1: Assuming drawText() takes a font parameter

```lua
-- WRONG
vmupro.graphics.drawText("Hello", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK, vmupro.text.FONT_SMALL)

-- CORRECT
vmupro.text.setFont(vmupro.text.FONT_SMALL)
vmupro.graphics.drawText("Hello", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
```

**Explanation:**
- `vmupro.graphics.drawText()` does NOT accept a font parameter
- Font must be set FIRST using `vmupro.text.setFont()`
- The font setting is GLOBAL and affects all subsequent `drawText()` calls

---

#### Common Mistake #2: Forgetting to set font before calcLength()

```lua
-- WRONG - Uses previous font or default
local width = vmupro.text.calcLength("Hello")
vmupro.text.setFont(vmupro.text.FONT_SMALL)

-- CORRECT - Set font first
vmupro.text.setFont(vmupro.text.FONT_SMALL)
local width = vmupro.text.calcLength("Hello")
```

---

#### Common Mistake #3: Confusing text namespaces

```lua
-- WRONG
vmupro.text.drawText("Hello", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)

-- CORRECT
vmupro.graphics.drawText("Hello", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
vmupro.text.setFont(vmupro.text.FONT_SMALL)  -- Font setup is in vmupro.text
```

**Rule of Thumb:**
- **`vmupro.text`** = Font SETUP and measurement
- **`vmupro.graphics`** = Text DRAWING (using the current font)

---

### The "Display Confusion"

#### Common Mistake #4: Using vmupro.display.refresh() instead of vmupro.graphics.refresh()

```lua
-- Works but not recommended
vmupro.display.refresh()

-- Recommended for consistency
vmupro.graphics.refresh()
```

**Explanation:**
- Both functions work identically
- `vmupro.display.*` appears to be legacy
- Use `vmupro.graphics.refresh()` for new code

---

#### Common Mistake #5: Confusing refresh() in double buffering

```lua
-- Standard rendering (no double buffering)
vmupro.graphics.clear(vmupro.graphics.BLACK)
-- ... draw ...
vmupro.graphics.refresh()  -- Correct

-- Double buffering enabled
vmupro.graphics.startDoubleBufferRenderer()
vmupro.graphics.clear(vmupro.graphics.BLACK)
-- ... draw ...
vmupro.graphics.pushDoubleBufferFrame()  -- Use this, NOT refresh()
```

---

### The "Brightness Confusion"

#### Common Mistake #6: Using vmupro.graphics for brightness

```lua
-- Works but not canonical
vmupro.graphics.setGlobalBrightness(128)

-- Recommended - use system namespace
vmupro.system.setGlobalBrightness(128)
```

**Why:** Brightness is a system-level setting, not a graphics operation.

---

## Complete Initialization Sequence

### Standard Application Setup

```lua
import "api/system"
import "api/display"
import "api/input"

function AppMain()
    -- 1. Initialize logging
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Starting...")

    -- 2. Set default font
    vmupro.text.setFont(vmupro.text.FONT_MEDIUM)

    -- 3. Set initial brightness (optional)
    vmupro.system.setGlobalBrightness(128)

    -- 4. Optional: Start double buffering
    -- vmupro.graphics.startDoubleBufferRenderer()

    local running = true

    while running do
        -- 5. Read input (once per frame)
        vmupro.input.read()

        -- 6. Handle input
        if vmupro.input.pressed(vmupro.input.B) then
            running = false
        end

        -- 7. Clear display (once per frame)
        vmupro.graphics.clear(vmupro.graphics.BLACK)

        -- 8. Set font for this frame
        vmupro.text.setFont(vmupro.text.FONT_SMALL)

        -- 9. Draw all graphics
        vmupro.graphics.drawText("Hello World", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        vmupro.graphics.drawRect(5, 5, 230, 230, vmupro.graphics.RED)

        -- 10. Refresh display (once per frame)
        vmupro.graphics.refresh()

        -- 11. Frame timing
        vmupro.system.delayMs(16)  -- ~60 FPS
    end

    -- 12. Cleanup
    -- vmupro.graphics.stopDoubleBufferRenderer()

    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Exiting...")
    return 0
end
```

---

## Best Practices Summary

### Display Management
1. **Clear once, draw all, refresh once** per frame
2. **Use `vmupro.graphics.refresh()`** for standard rendering
3. **Use `vmupro.graphics.pushDoubleBufferFrame()`** when double buffering is enabled
4. **Never call refresh() multiple times** per frame

### Text Rendering
1. **Set font BEFORE** drawing or measuring text
2. **Group text by font** to minimize font changes
3. **Use `vmupro.text.calcLength()`** for layout calculations
4. **Center text** using: `x = (240 - text_width) / 2`

### Color Management
1. **Use predefined color constants** (`vmupro.graphics.RED`, etc.)
2. **Calculate custom colors at initialization**, not in render loop
3. **Consider accessibility** with color contrast

### Namespace Usage
1. **`vmupro.graphics.*`** for drawing operations and display management
2. **`vmupro.text.*`** for font setup and text measurement
3. **`vmupro.system.*`** for brightness (NOT graphics namespace)
4. **Avoid `vmupro.display.*`** in new code (use graphics namespace)

### Performance
1. **Minimize state changes** (font changes, color conversions)
2. **Batch operations** (draw all text of one font, then switch)
3. **Pre-calculate values** outside render loop
4. **Use double buffering** for smooth animation

---

## Common Patterns

### Pattern 1: UI Text Layout
```lua
function drawUI()
    local x = 10
    local y = 10
    local line_height = 18

    -- Title
    vmupro.text.setFont(vmupro.text.FONT_GABARITO_18x18)
    vmupro.graphics.drawText("Settings", x, y, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
    y = y + line_height + 5

    -- Menu items
    vmupro.text.setFont(vmupro.text.FONT_SMALL)
    vmupro.graphics.drawText("Sound: ON", x, y, vmupro.graphics.GREY, vmupro.graphics.BLACK)
    y = y + line_height
    vmupro.graphics.drawText("Brightness: 50%", x, y, vmupro.graphics.GREY, vmupro.graphics.BLACK)
end
```

### Pattern 2: Responsive Text Layout
```lua
function drawResponsiveText()
    vmupro.text.setFont(vmupro.text.FONT_MEDIUM)

    local title = "GAME OVER"
    local subtitle = "Score: 1000"

    -- Center title
    local title_width = vmupro.text.calcLength(title)
    local title_x = (240 - title_width) / 2
    vmupro.graphics.drawText(title, title_x, 80, vmupro.graphics.RED, vmupro.graphics.BLACK)

    -- Center subtitle
    local subtitle_width = vmupro.text.calcLength(subtitle)
    local subtitle_x = (240 - subtitle_width) / 2
    vmupro.graphics.drawText(subtitle, subtitle_x, 110, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
end
```

### Pattern 3: Debug HUD
```lua
function drawDebugHUD(fps, memory)
    vmupro.text.setFont(vmupro.text.FONT_TINY_6x8)

    local x = 5
    local y = 5
    local line_height = 10

    vmupro.graphics.drawText(string.format("FPS: %d", fps), x, y, vmupro.graphics.GREEN, vmupro.graphics.BLACK)
    y = y + line_height
    vmupro.graphics.drawText(string.format("MEM: %d KB", memory / 1024), x, y, vmupro.graphics.GREEN, vmupro.graphics.BLACK)
end
```

---

## Troubleshooting Guide

### Problem: Text doesn't appear or shows wrong font

**Solution:**
```lua
-- Check font is set BEFORE drawing
vmupro.text.setFont(vmupro.text.FONT_SMALL)
vmupro.graphics.drawText("Text", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
```

---

### Problem: Text width calculation is wrong

**Solution:**
```lua
-- Ensure font is set BEFORE calcLength
vmupro.text.setFont(vmupro.text.FONT_MEDIUM)
local width = vmupro.text.calcLength("Hello")
```

---

### Problem: Screen flickers

**Solution:**
```lua
-- Use double buffering
vmupro.graphics.startDoubleBufferRenderer()

while running do
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    -- ... draw ...
    vmupro.graphics.pushDoubleBufferFrame()  -- NOT refresh()
end

vmupro.graphics.stopDoubleBufferRenderer()
```

---

### Problem: Nothing appears on screen

**Solution:**
```lua
-- Check that you called refresh()
vmupro.graphics.clear(vmupro.graphics.BLACK)
vmupro.graphics.drawText("Test", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
vmupro.graphics.refresh()  -- CRITICAL: Don't forget this!
```

---

### Problem: Colors look wrong

**Solution:**
```lua
-- Use predefined color constants
vmupro.graphics.drawRect(10, 10, 50, 50, vmupro.graphics.RED)  -- Correct

-- Not: vmupro.graphics.drawRect(10, 10, 50, 50, 255)  -- Wrong format!
```

---

## Quick Reference Card

### Import Statement
```lua
import "api/display"  -- Enables graphics, text, and display namespaces
```

### Core Render Loop
```lua
vmupro.graphics.clear(vmupro.graphics.BLACK)
-- ... set fonts, draw shapes, draw text ...
vmupro.graphics.refresh()
```

### Font + Text Pattern
```lua
vmupro.text.setFont(vmupro.text.FONT_SMALL)
vmupro.graphics.drawText("Hello", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
```

### Text Measurement Pattern
```lua
vmupro.text.setFont(vmupro.text.FONT_SMALL)
local width = vmupro.text.calcLength("Hello")
local x = (240 - width) / 2  -- Center text
```

### Brightness Control
```lua
vmupro.system.setGlobalBrightness(128)  -- Use system, not graphics!
```

---

## Additional Resources

- **Graphics API:** `/mnt/g/vmupro-game-extras/documentation/docs/api/display.md`
- **System API:** `/mnt/g/vmupro-game-extras/documentation/docs/api/system.md`
- **Double Buffer:** `/mnt/g/vmupro-game-extras/documentation/docs/api/doublebuffer.md`
- **Graphics Guide:** `/mnt/g/vmupro-game-extras/documentation/docs/guides/graphics-guide.md`
- **Example Apps:** `/mnt/g/vmupro-game-extras/documentation/examples/`

---

## Summary

The VMU Pro display system is well-organized once you understand the namespace separation:

1. **`vmupro.graphics`** = DOING (drawing, rendering, displaying)
2. **`vmupro.text`** = CONFIGURING (font selection, text measurement)
3. **`vmupro.display`** = LEGACY (avoid in new code)
4. **`vmupro.system`** = SYSTEM SETTINGS (brightness, memory, timing)

**Golden Rule:**
- Use `vmupro.text.setFont()` to CONFIGURE
- Use `vmupro.graphics.drawText()` to DRAW
- Use `vmupro.graphics.refresh()` to DISPLAY

Following these patterns will ensure your code is clean, performant, and maintainable.
