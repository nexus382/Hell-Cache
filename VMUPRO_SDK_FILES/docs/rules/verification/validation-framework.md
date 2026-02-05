# VMU Pro LUA SDK Code Pattern Validation Framework

## Overview
This document defines the validation criteria for all code examples and patterns in the VMU Pro SDK rule files.

## Validation Criteria

### 1. Import Statement Patterns

**Valid Patterns:**
```lua
import "api/system"
import "api/display"
import "api/input"
import "api/sprites"
import "api/audio"
import "api/file"
```

**Module Import Patterns:**
```lua
import "pages/page1"
import "libraries/utils"
import "libraries/maths"
```

**Rules:**
- ✅ Use `import` statement, NOT `require()`
- ✅ Use forward slashes for paths
- ✅ NO file extensions (.lua is automatic)
- ✅ Relative paths from project root
- ✅ API imports use "api/" prefix
- ❌ NO absolute paths
- ❌ NO .lua extensions

### 2. AppMain() Function Pattern

**Valid Pattern:**
```lua
function AppMain()
    -- Initialize
    init_app()

    -- Main loop
    while app_running do
        -- Read input
        vmupro.input.read()

        -- Update logic
        update()

        -- Render graphics
        render()

        -- Frame timing
        vmupro.system.delayMs(16)  -- ~60 FPS
    end

    -- Cleanup
    return 0
end
```

**Rules:**
- ✅ Must be named exactly `AppMain()` (case-sensitive)
- ✅ Must return integer (0 for success)
- ✅ Contains initialization, main loop, cleanup
- ✅ Main loop structure: input → update → render → refresh → timing
- ❌ NOT `main()` or `Main()` or `appmain()`

### 3. Module Return Table Pattern

**Valid Pattern:**
```lua
-- Module definition
Utils = {}

function Utils.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

-- NO explicit return statement needed
```

**Alternative Page Module Pattern:**
```lua
Page1 = {}

function Page1.render(drawPageCounter)
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    drawPageCounter()
    -- render page content
end

function Page1.update()
    -- update logic
end
```

**Rules:**
- ✅ Global table declaration (MyModule = {})
- ✅ Functions attached to table (MyModule.funcName)
- ✅ NO explicit return statement needed
- ✅ Accessed via import statement
- ❌ NOT local return { } pattern

### 4. Game Loop Pattern

**Valid Pattern:**
```lua
while app_running do
    -- 1. Read Input
    vmupro.input.read()

    -- 2. Update Logic
    if vmupro.input.pressed(vmupro.input.B) then
        app_running = false
    end

    -- 3. Render Graphics
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawText("Hello", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)

    -- 4. Refresh Display
    vmupro.graphics.refresh()

    -- 5. Frame Timing
    vmupro.system.delayMs(16)  -- ~60 FPS
end
```

**Rules:**
- ✅ Order: read input → update → render → refresh → delay
- ✅ `vmupro.input.read()` called BEFORE checking input
- ✅ `vmupro.graphics.refresh()` called AFTER all drawing
- ✅ Frame delay for timing control
- ❌ NOT refresh before drawing
- ❌ NOT checking input before read()

### 5. Namespace Usage

**Valid Namespaces:**
```lua
vmupro.graphics.*       -- Graphics/display functions
vmupro.sprite.*         -- Sprite management
vmupro.input.*          -- Input handling
vmupro.system.*         -- System functions
vmupro.file.*           -- File I/O
vmupro.sound.*          -- Audio playback
vmupro.synth.*          -- Audio synthesis
vmupro.instrument.*     -- Instrument playback
vmupro.sequence.*       -- MIDI sequences
vmupro.text.*           -- Text rendering
```

**Rules:**
- ✅ All API calls use `vmupro.namespace.function()`
- ✅ Namespace matches import statement
- ❌ NOT global functions without namespace
- ❌ NOT incorrect namespace mixing

### 6. Color Constants

**Valid Pattern:**
```lua
vmupro.graphics.RED
vmupro.graphics.GREEN
vmupro.graphics.BLUE
vmupro.graphics.WHITE
vmupro.graphics.BLACK
vmupro.graphics.YELLOW
vmupro.graphics.ORANGE
vmupro.graphics.MAGENTA
vmupro.graphics.VMUGREEN
vmupro.graphics.VMUINK
vmupro.graphics.GREY
```

**Rules:**
- ✅ Use predefined color constants
- ✅ RGB565 format for custom colors (0x0000 - 0xFFFF)
- ✅ Colors accessed via `vmupro.graphics.*`
- ❌ NOT RGB888 or other formats

### 7. Input Constants

**Valid Pattern:**
```lua
vmupro.input.UP
vmupro.input.DOWN
vmupro.input.LEFT
vmupro.input.RIGHT
vmupro.input.A
vmupro.input.B
vmupro.input.MODE
vmupro.input.POWER
```

**Rules:**
- ✅ Use predefined button constants
- ✅ All uppercase names
- ❌ NOT numeric values directly
- ❌ NOT lowercase names

### 8. Sprite Loading Pattern

**Valid Pattern:**
```lua
local player_sprite = vmupro.sprite.new("sprites/player")

if not player_sprite then
    vmupro.system.log(vmupro.system.LOG_ERROR, "Game", "Failed to load sprite")
end

-- Access sprite properties
local width = player_sprite.width
local height = player_sprite.height

-- Draw sprite
vmupro.sprite.draw(player_sprite, x, y, vmupro.sprite.kImageUnflipped)
```

**Rules:**
- ✅ NO file extension in path
- ✅ Check for nil return value
- ✅ Sprite object has width, height, id properties
- ✅ Use kImageUnflipped, kImageFlippedX, kImageFlippedY, kImageFlippedXY
- ❌ NOT including .png or .bmp extension

### 9. Logging Pattern

**Valid Pattern:**
```lua
vmupro.system.log(vmupro.system.LOG_INFO, "AppName", "Message")
vmupro.system.log(vmupro.system.LOG_DEBUG, "AppName", "Debug info")
vmupro.system.log(vmupro.system.LOG_ERROR, "AppName", "Error occurred")
```

**Log Levels:**
- `vmupro.system.LOG_DEBUG`
- `vmupro.system.LOG_INFO`
- `vmupro.system.LOG_ERROR`

**Rules:**
- ✅ Three parameters: level, tag, message
- ✅ Use predefined log level constants
- ✅ Tag identifies app/module
- ❌ NOT print() or io.write()

### 10. File Path Patterns

**Valid Pattern:**
```lua
-- Embedded resources (from vmupack)
local sprite = vmupro.sprite.new("sprites/player")
local sound = vmupro.sound.sample.new("sounds/music")

-- SD card access
local file = vmupro.file.open("/sdcard/save.dat", "r")
```

**Rules:**
- ✅ Embedded resources: relative paths, NO extension
- ✅ SD card: absolute path starting with /sdcard
- ✅ Forward slashes for paths
- ❌ NOT backslashes
- ❌ NOT file extensions for embedded resources

## Common Syntax Errors to Check

### 1. String Concatenation
```lua
-- ✅ CORRECT
local text = "Frame: " .. frame_count

-- ❌ WRONG
local text = "Frame: " + frame_count  -- NOT JavaScript!
```

### 2. Logical Operators
```lua
-- ✅ CORRECT
if x > 0 and y > 0 then

-- ❌ WRONG
if x > 0 && y > 0 then  -- NOT C syntax!
```

### 3. Not Equal Operator
```lua
-- ✅ CORRECT
if sprite ~= nil then

-- ❌ WRONG
if sprite != nil then  -- NOT C syntax!
```

### 4. Table Iteration
```lua
-- ✅ CORRECT
for i, value in ipairs(array) do
    print(value)
end

-- ❌ WRONG
for (int i = 0; i < array.length; i++)  -- NOT C syntax!
```

### 5. Comments
```lua
-- ✅ CORRECT single-line comment

--[[
✅ CORRECT
multi-line comment
]]

-- ❌ WRONG
// NOT C-style comments
/* NOT C-style comments */
```

## Best Practices to Verify

1. **Error Handling**: Check for nil returns
2. **Resource Cleanup**: Proper sprite/sound freeing
3. **Frame Rate**: Consistent timing control
4. **Memory Management**: No excessive object creation in loops
5. **Input Handling**: Always read() before checking buttons
6. **Display Updates**: refresh() after all drawing
7. **Logging**: Appropriate log levels
8. **Documentation**: Clear function comments

## Verification Scoring

Each code example will be scored on:
- **Syntax Correctness** (30 points): Valid LUA syntax
- **API Convention** (25 points): Correct VMU Pro patterns
- **Best Practices** (20 points): Following guidelines
- **Error Handling** (15 points): Proper error checks
- **Documentation** (10 points): Clear comments

**Total: 100 points**

**Grade Scale:**
- 90-100: Excellent ✅
- 75-89: Good ⚠️
- 60-74: Fair ⚠️
- Below 60: Needs Revision ❌
