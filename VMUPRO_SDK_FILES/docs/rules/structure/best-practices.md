# VMU Pro LUA Coding Best Practices

## Table of Contents
1. [Application Structure](#application-structure)
2. [Import Statements](#import-statements)
3. [Module Organization](#module-organization)
4. [Game Loop Pattern](#game-loop-pattern)
5. [Memory Management](#memory-management)
6. [Performance Optimization](#performance-optimization)
7. [Error Handling](#error-handling)
8. [Code Organization](#code-organization)
9. [Common Anti-Patterns](#common-anti-patterns)
10. [Testing & Debugging](#testing--debugging)
11. [Complete Example](#complete-example)

---

## Application Structure

### ✅ REQUIRED: AppMain() Function

Every VMU Pro application **MUST** implement the `AppMain()` function. This is the entry point called by the firmware.

```lua
-- ✅ GOOD: Required application entry point
function AppMain()
    init_app()

    while app_running do
        update()
        render()
        vmupro.system.delayMs(16) -- ~60 FPS
    end

    cleanup()
    return 0  -- Success
end

-- ❌ BAD: Missing AppMain() function
function main()  -- Wrong name - firmware won't find it
    -- Application won't run
end
```

### Application Return Code

Always return `0` for success from `AppMain()`:

```lua
-- ✅ GOOD: Clear exit code
function AppMain()
    -- ... application logic ...
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Completed successfully")
    return 0  -- Success
end

-- ❌ BAD: No return value
function AppMain()
    -- ... application logic ...
    -- Missing return - undefined behavior
end
```

---

## Import Statements

### Import Pattern

Use the `import "api/..."` pattern to load SDK modules:

```lua
-- ✅ GOOD: Standard SDK imports
import "api/system"
import "api/display"
import "api/input"
import "api/sprites"
import "api/audio"

-- ✅ GOOD: Relative imports for your modules
import "pages/page1"
import "libraries/utils"
import "libraries/maths"

-- ❌ BAD: Wrong import syntax
require "api/system"  -- Wrong - use import, not require
include "api/display"  -- Wrong syntax
```

### Import Organization

Group imports logically at the top of the file:

```lua
-- ✅ GOOD: Organized imports
-- SDK APIs
import "api/system"
import "api/display"
import "api/input"

-- Application modules
import "libraries/utils"
import "libraries/maths"

-- Page modules
import "pages/page1"
import "pages/page2"

-- ❌ BAD: Scattered imports
import "api/system"
local x = 10
import "api/display"  -- Don't scatter imports throughout code
```

### File Path Rules

- **No file extensions** in import paths
- Paths are relative to the application root
- Works the same for `.lua` files and asset files (sprites, audio)

```lua
-- ✅ GOOD: No extensions
import "libraries/utils"  -- Will load libraries/utils.lua
local sprite = vmupro.sprite.new("assets/player")  -- Will load assets/player.png or .bmp

-- ❌ BAD: Including extensions
import "libraries/utils.lua"  -- Wrong
local sprite = vmupro.sprite.new("assets/player.png")  -- Wrong
```

---

## Module Organization

### Module Export Pattern

Use the **table return pattern** for modules:

```lua
-- ✅ GOOD: Module with table export (libraries/utils.lua)
Utils = {}

function Utils.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

-- No explicit return needed - table is global
```

### Module Usage

```lua
-- ✅ GOOD: Import and use module
import "libraries/utils"

local clamped = Utils.clamp(value, 0, 100)
local interpolated = Utils.lerp(start_pos, end_pos, 0.5)

-- ❌ BAD: Trying to use without import
local clamped = Utils.clamp(value, 0, 100)  -- Error: Utils is nil
```

### Page Module Pattern

Pages should expose `render()` functions and optional lifecycle functions:

```lua
-- ✅ GOOD: Page module structure (pages/page1.lua)
Page1 = {}

-- Required: Render function
function Page1.render(drawPageCounter)
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawText("Page 1", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
    drawPageCounter()
end

-- Optional: Update function
function Page1.update()
    -- Update logic
end

-- Optional: Enter/exit lifecycle
function Page1.enter()
    -- Setup when entering page
end

function Page1.exit()
    -- Cleanup when leaving page
end
```

---

## Game Loop Pattern

### Standard Init-Update-Render Pattern

Follow the **separation of concerns** principle:

```lua
-- ✅ GOOD: Clean separation of concerns
local app_running = true
local player_x = 120
local player_y = 120

--- Initialize application
local function init_app()
    vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Initializing")
    vmupro.text.setFont(vmupro.text.FONT_SMALL)
    vmupro.graphics.clear(vmupro.graphics.BLACK)
end

--- Update game logic
local function update()
    -- Read input
    vmupro.input.read()

    -- Process input
    if vmupro.input.held(vmupro.input.LEFT) then
        player_x = player_x - 2
    end

    if vmupro.input.pressed(vmupro.input.B) then
        app_running = false
    end
end

--- Render frame
local function render()
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawRect(player_x - 5, player_y - 5, player_x + 5, player_y + 5, vmupro.graphics.WHITE)
    vmupro.graphics.refresh()
end

--- Main loop
function AppMain()
    init_app()

    while app_running do
        update()
        render()
        vmupro.system.delayMs(16)  -- Target 60 FPS
    end

    return 0
end

-- ❌ BAD: Everything mixed together
function AppMain()
    while true do
        vmupro.input.read()
        vmupro.graphics.clear(vmupro.graphics.BLACK)
        if vmupro.input.held(vmupro.input.LEFT) then
            x = x - 2
            vmupro.graphics.drawRect(x, y, x+10, y+10, vmupro.graphics.WHITE)
        end
        vmupro.graphics.refresh()
    end
    -- Logic, rendering, and control flow all mixed
end
```

### Frame Timing

Use precise frame timing for consistent performance:

```lua
-- ✅ GOOD: Precise frame timing with microseconds
local target_frame_time_us = 16666  -- 60 FPS (16.666ms)
local frame_start_time = 0

function AppMain()
    init_app()

    while app_running do
        frame_start_time = vmupro.system.getTimeUs()

        update()
        render()

        -- Calculate delay needed
        local frame_end_time = vmupro.system.getTimeUs()
        local elapsed_time_us = frame_end_time - frame_start_time
        local delay_time_us = target_frame_time_us - elapsed_time_us

        if delay_time_us > 0 then
            vmupro.system.delayUs(delay_time_us)
        end
    end

    return 0
end

-- ❌ BAD: Fixed delay without accounting for frame time
function AppMain()
    while app_running do
        update()
        render()
        vmupro.system.delayMs(16)  -- Doesn't account for processing time
    end
end
```

---

## Memory Management

### Resource Cleanup

**ALWAYS** free resources when done to prevent memory leaks:

```lua
-- ✅ GOOD: Proper resource management
local player_sprite = nil

local function init_app()
    player_sprite = vmupro.sprite.new("assets/player")
    if not player_sprite then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Game", "Failed to load player sprite")
        return false
    end
    return true
end

local function cleanup()
    if player_sprite then
        vmupro.sprite.free(player_sprite)
        player_sprite = nil
    end
    vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Cleanup complete")
end

function AppMain()
    if not init_app() then return 1 end

    while app_running do
        update()
        render()
        vmupro.system.delayMs(16)
    end

    cleanup()  -- Always cleanup before exit
    return 0
end

-- ❌ BAD: Resource leak
function AppMain()
    local sprite = vmupro.sprite.new("assets/player")

    while app_running do
        update()
        render()
    end

    return 0  -- Sprite never freed - memory leak!
end
```

### Scene System Cleanup

When using the sprite scene system, **ALWAYS** call `removeAll()`:

```lua
-- ✅ GOOD: Clean up scene sprites
function Page1.exit()
    vmupro.sprite.removeAll()  -- Critical for scene system
    -- Prevents sprites from appearing on other pages
end

-- ❌ BAD: Forgetting to remove sprites
function Page1.exit()
    -- Sprites leak to next page!
end
```

### Memory Monitoring

Monitor memory usage for resource-intensive applications:

```lua
-- ✅ GOOD: Memory monitoring
local function check_memory()
    local usage = vmupro.system.getMemoryUsage()
    local limit = vmupro.system.getMemoryLimit()
    local largest = vmupro.system.getLargestFreeBlock()

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Memory",
        string.format("Usage: %d/%d bytes, Largest block: %d", usage, limit, largest))

    if usage > limit * 0.9 then
        vmupro.system.log(vmupro.system.LOG_WARN, "Memory", "Memory usage above 90%!")
    end
end
```

---

## Performance Optimization

### Avoid Repeated String Formatting

Cache formatted strings when possible:

```lua
-- ✅ GOOD: Cache formatted strings
local frame_count = 0
local fps_text = "FPS: 0"
local last_fps_update = 0

local function update_fps()
    local current_time = vmupro.system.getTimeUs()
    if current_time - last_fps_update >= 500000 then  -- Update every 500ms
        local fps = math.floor(frame_count * 2)  -- 2 updates per second
        fps_text = string.format("FPS: %d", fps)  -- Cache the string
        frame_count = 0
        last_fps_update = current_time
    end
end

local function render()
    -- ... other rendering ...
    vmupro.graphics.drawText(fps_text, 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
end

-- ❌ BAD: Format every frame
local function render()
    local fps_text = string.format("FPS: %d", current_fps)  -- Wasteful every frame
    vmupro.graphics.drawText(fps_text, 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
end
```

### Minimize Graphics Operations

Batch drawing operations and avoid redundant clears:

```lua
-- ✅ GOOD: Efficient rendering
local function render()
    vmupro.graphics.clear(vmupro.graphics.BLACK)  -- Clear once

    -- Draw all objects
    vmupro.graphics.drawRect(x1, y1, x2, y2, vmupro.graphics.WHITE)
    vmupro.graphics.drawRect(x3, y3, x4, y4, vmupro.graphics.RED)
    vmupro.graphics.drawText("Score: 100", 10, 10, vmupro.graphics.YELLOW, vmupro.graphics.BLACK)

    vmupro.graphics.refresh()  -- Refresh once at end
end

-- ❌ BAD: Multiple clears and refreshes
local function render()
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawRect(x1, y1, x2, y2, vmupro.graphics.WHITE)
    vmupro.graphics.refresh()  -- Wasteful

    vmupro.graphics.clear(vmupro.graphics.BLACK)  -- Redundant
    vmupro.graphics.drawText("Score", 10, 10, vmupro.graphics.YELLOW, vmupro.graphics.BLACK)
    vmupro.graphics.refresh()  -- Wasteful
end
```

### Use Local Variables

Local variables are faster than global variables:

```lua
-- ✅ GOOD: Use local variables
local player_x = 120
local player_y = 120
local player_speed = 2

local function update()
    if vmupro.input.held(vmupro.input.LEFT) then
        player_x = player_x - player_speed
    end
end

-- ❌ BAD: Global variables (slower access)
player_x = 120
player_y = 120
player_speed = 2

function update()
    if vmupro.input.held(vmupro.input.LEFT) then
        player_x = player_x - player_speed  -- Slower global access
    end
end
```

### Optimize Input Checking

Read input once per frame, not multiple times:

```lua
-- ✅ GOOD: Read input once
local function update()
    vmupro.input.read()  -- Read once

    if vmupro.input.pressed(vmupro.input.A) then
        fire_weapon()
    end

    if vmupro.input.held(vmupro.input.LEFT) then
        move_left()
    end
end

-- ❌ BAD: Reading input multiple times
local function update()
    vmupro.input.read()
    if vmupro.input.pressed(vmupro.input.A) then
        fire_weapon()
    end

    vmupro.input.read()  -- Wasteful re-read
    if vmupro.input.held(vmupro.input.LEFT) then
        move_left()
    end
end
```

---

## Error Handling

### Check Resource Loading

Always verify that resources loaded successfully:

```lua
-- ✅ GOOD: Check sprite loading
local function init_app()
    local player_sprite = vmupro.sprite.new("assets/player")
    if not player_sprite then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Init", "Failed to load player sprite")
        return false
    end

    local enemy_sprite = vmupro.sprite.new("assets/enemy")
    if not enemy_sprite then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Init", "Failed to load enemy sprite")
        vmupro.sprite.free(player_sprite)  -- Clean up already-loaded resources
        return false
    end

    return true
end

function AppMain()
    if not init_app() then
        return 1  -- Error exit code
    end

    -- ... rest of application ...
end

-- ❌ BAD: No error checking
local function init_app()
    player_sprite = vmupro.sprite.new("assets/player")
    -- If this fails, sprite is nil and app will crash later
end
```

### Logging Best Practices

Use appropriate log levels:

```lua
-- ✅ GOOD: Proper log levels
vmupro.system.log(vmupro.system.LOG_ERROR, "Audio", "Failed to load sound file")
vmupro.system.log(vmupro.system.LOG_WARN, "Memory", "Memory usage above 80%")
vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Level completed")
vmupro.system.log(vmupro.system.LOG_DEBUG, "Physics", "Collision detected at (100, 200)")

-- ❌ BAD: Wrong log levels
vmupro.system.log(vmupro.system.LOG_ERROR, "Game", "Player jumped")  -- Not an error
vmupro.system.log(vmupro.system.LOG_DEBUG, "Init", "Failed to initialize")  -- Should be ERROR
```

### Defensive Programming

Validate inputs and state:

```lua
-- ✅ GOOD: Defensive checks
local function move_sprite(sprite, dx, dy)
    if not sprite then
        vmupro.system.log(vmupro.system.LOG_WARN, "Move", "Attempted to move nil sprite")
        return
    end

    local x, y = vmupro.sprite.getPosition(sprite)
    vmupro.sprite.setPosition(sprite, x + dx, y + dy)
end

-- ❌ BAD: No validation
local function move_sprite(sprite, dx, dy)
    local x, y = vmupro.sprite.getPosition(sprite)  -- Crash if sprite is nil
    vmupro.sprite.setPosition(sprite, x + dx, y + dy)
end
```

---

## Code Organization

### Function Size

Keep functions small and focused:

```lua
-- ✅ GOOD: Small, focused functions
local function handle_movement_input()
    if vmupro.input.held(vmupro.input.LEFT) then
        player_x = player_x - player_speed
    end
    if vmupro.input.held(vmupro.input.RIGHT) then
        player_x = player_x + player_speed
    end
end

local function handle_action_input()
    if vmupro.input.pressed(vmupro.input.A) then
        fire_weapon()
    end
    if vmupro.input.pressed(vmupro.input.B) then
        jump()
    end
end

local function update()
    vmupro.input.read()
    handle_movement_input()
    handle_action_input()
    update_physics()
end

-- ❌ BAD: Giant monolithic function
local function update()
    vmupro.input.read()

    -- 100+ lines of mixed logic
    if vmupro.input.held(vmupro.input.LEFT) then
        player_x = player_x - 2
        if player_x < 0 then player_x = 0 end
        -- ... more movement code ...
    end

    if vmupro.input.pressed(vmupro.input.A) then
        -- ... 50 lines of weapon code ...
    end

    -- ... even more mixed logic ...
end
```

### Use Descriptive Names

```lua
-- ✅ GOOD: Clear, descriptive names
local player_position_x = 120
local player_position_y = 120
local max_player_speed = 5
local bullet_damage = 10

local function calculate_distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- ❌ BAD: Cryptic names
local px = 120
local py = 120
local spd = 5
local d = 10

local function calc(a, b, c, d)
    local e = c - a
    local f = d - b
    return math.sqrt(e * e + f * f)
end
```

### Comment Effectively

Use LuaDoc-style comments for documentation:

```lua
-- ✅ GOOD: Clear documentation
--- @brief Calculate damage based on distance from explosion
--- @param explosion_x number X coordinate of explosion center
--- @param explosion_y number Y coordinate of explosion center
--- @param target_x number X coordinate of target
--- @param target_y number Y coordinate of target
--- @param max_damage number Maximum damage at epicenter
--- @param radius number Explosion radius
--- @return number Calculated damage value
local function calculate_explosion_damage(explosion_x, explosion_y, target_x, target_y, max_damage, radius)
    local distance = calculate_distance(explosion_x, explosion_y, target_x, target_y)

    if distance >= radius then
        return 0
    end

    -- Linear falloff from epicenter to edge
    local falloff = 1.0 - (distance / radius)
    return math.floor(max_damage * falloff)
end

-- ❌ BAD: No documentation or unclear comments
local function calc_dmg(ex, ey, tx, ty, md, r)
    local d = calc_dist(ex, ey, tx, ty)
    if d >= r then return 0 end
    local f = 1.0 - (d / r)  -- what does this do?
    return math.floor(md * f)
end
```

### Document Critical Gotchas

**ALWAYS comment non-obvious requirements and pitfalls:**

```lua
-- ✅ GOOD: Documenting critical requirements
-- ============================================================================
-- CRITICAL: vmupro.input.read() MUST be called ONCE per frame
-- DO NOT call this function in page modules - it's already called by app.lua
-- Calling it twice will break button detection!
-- ============================================================================

function Page.handle_input()
    -- Input already read by app.lua - DO NOT call vmupro.input.read() here
    if vmupro.input.pressed(vmupro.input.A) then
        return "select"
    end
end

-- ✅ GOOD: Documenting dangerous patterns
-- WARNING: Do not use require() for SDK modules - use import instead
-- require() will cause force-close crashes
import "api/system"  -- Correct

-- ✅ GOOD: Documenting non-obvious API behaviors
-- NOTE: vmupro.input.pressed() only returns true on the FIRST frame the button is pressed
-- Use vmupro.input.held() for continuous button state checking
if vmupro.input.pressed(vmupro.input.A) then
    -- This triggers only once per button press, not every frame
    trigger_action_once()
end

-- ❌ BAD: No warning about critical behavior
function Page.handle_input()
    vmupro.input.read()  -- This breaks things but no comment explains why
    if vmupro.input.pressed(vmupro.input.A) then
        return "select"
    end
end
```

**When to add gotcha warnings:**
- API calls that will break the app if used incorrectly
- Non-obvious order dependencies
- Platform-specific behaviors that differ from standard Lua
- Performance pitfalls that aren't immediately obvious
- SDK-specific quirks that contradict common patterns

Use clear warning prefixes:
- `CRITICAL:` - Things that will crash/force-close
- `WARNING:` - Things that will cause bugs
- `NOTE:` - Non-obvious but safe behaviors
- `DO NOT:` - Anti-patterns to avoid

---

## Common Anti-Patterns

### Anti-Pattern 1: Hardcoded Magic Numbers

```lua
-- ❌ BAD: Magic numbers everywhere
function update()
    if player_x > 240 then player_x = 240 end
    if player_y > 240 then player_y = 240 end
    if player_speed > 5 then player_speed = 5 end
end

-- ✅ GOOD: Named constants
local SCREEN_WIDTH = 240
local SCREEN_HEIGHT = 240
local MAX_PLAYER_SPEED = 5

function update()
    if player_x > SCREEN_WIDTH then player_x = SCREEN_WIDTH end
    if player_y > SCREEN_HEIGHT then player_y = SCREEN_HEIGHT end
    if player_speed > MAX_PLAYER_SPEED then player_speed = MAX_PLAYER_SPEED end
end
```

### Anti-Pattern 2: Deeply Nested Conditionals

```lua
-- ❌ BAD: Deep nesting
function update()
    if player_alive then
        if has_ammo then
            if vmupro.input.pressed(vmupro.input.A) then
                if weapon_cooldown == 0 then
                    fire_weapon()
                end
            end
        end
    end
end

-- ✅ GOOD: Early returns
function update()
    if not player_alive then return end
    if not has_ammo then return end
    if not vmupro.input.pressed(vmupro.input.A) then return end
    if weapon_cooldown > 0 then return end

    fire_weapon()
end
```

### Anti-Pattern 3: Code Duplication

```lua
-- ❌ BAD: Duplicated code
function draw_player()
    vmupro.graphics.drawRect(player_x - 5, player_y - 5, player_x + 5, player_y + 5, vmupro.graphics.WHITE)
end

function draw_enemy()
    vmupro.graphics.drawRect(enemy_x - 5, enemy_y - 5, enemy_x + 5, enemy_y + 5, vmupro.graphics.RED)
end

-- ✅ GOOD: Reusable function
function draw_box(x, y, size, color)
    local half = size / 2
    vmupro.graphics.drawRect(x - half, y - half, x + half, y + half, color)
end

function draw_player()
    draw_box(player_x, player_y, 10, vmupro.graphics.WHITE)
end

function draw_enemy()
    draw_box(enemy_x, enemy_y, 10, vmupro.graphics.RED)
end
```

### Anti-Pattern 4: Mutable Global State

```lua
-- ❌ BAD: Scattered global variables
score = 0
lives = 3
level = 1

function update()
    score = score + 10
    if score > 100 then
        level = level + 1
    end
end

-- ✅ GOOD: Encapsulated state
local game_state = {
    score = 0,
    lives = 3,
    level = 1
}

function update_score(points)
    game_state.score = game_state.score + points

    if game_state.score > 100 then
        game_state.level = game_state.level + 1
    end
end
```

---

## Testing & Debugging

### Debug Logging

Use structured logging for debugging:

```lua
-- ✅ GOOD: Debug logging strategy
local DEBUG_ENABLED = true

local function debug_log(message)
    if DEBUG_ENABLED then
        vmupro.system.log(vmupro.system.LOG_DEBUG, "Debug", message)
    end
end

function update()
    debug_log(string.format("Player position: (%d, %d)", player_x, player_y))
    debug_log(string.format("Frame time: %d us", frame_time))
end
```

### Visual Debug Overlay

Draw debug information on screen:

```lua
-- ✅ GOOD: Debug overlay
local SHOW_DEBUG = true

function render()
    -- Normal rendering
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    draw_game_objects()

    -- Debug overlay
    if SHOW_DEBUG then
        vmupro.text.setFont(vmupro.text.FONT_SMALL)
        vmupro.graphics.drawText(string.format("FPS: %d", current_fps), 5, 5,
            vmupro.graphics.YELLOW, vmupro.graphics.BLACK)
        vmupro.graphics.drawText(string.format("Mem: %d KB", memory_usage / 1024), 5, 20,
            vmupro.graphics.YELLOW, vmupro.graphics.BLACK)
        vmupro.graphics.drawText(string.format("Pos: (%d,%d)", player_x, player_y), 5, 35,
            vmupro.graphics.YELLOW, vmupro.graphics.BLACK)
    end

    vmupro.graphics.refresh()
end
```

### Assertion-Style Checks

```lua
-- ✅ GOOD: Validation checks
local function validate_position(x, y)
    if x < 0 or x > 240 or y < 0 or y > 240 then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Validate",
            string.format("Invalid position: (%d, %d)", x, y))
        return false
    end
    return true
end

local function set_player_position(x, y)
    if not validate_position(x, y) then
        return
    end
    player_x = x
    player_y = y
end
```

---

## Complete Example

Here's a complete, well-structured VMU Pro application following all best practices:

```lua
--- @file app.lua
--- @brief Example VMU Pro Game
--- @author Your Name
--- @version 1.0.0

-- ============================================================================
-- IMPORTS
-- ============================================================================

import "api/system"
import "api/display"
import "api/input"
import "api/sprites"

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local SCREEN_WIDTH = 240
local SCREEN_HEIGHT = 240
local TARGET_FPS = 60
local TARGET_FRAME_TIME_US = 16666  -- ~60 FPS

-- Player constants
local PLAYER_SPEED = 3
local PLAYER_SIZE = 10

-- ============================================================================
-- STATE
-- ============================================================================

local app_running = true
local frame_count = 0

-- Player state
local player = {
    x = SCREEN_WIDTH / 2,
    y = SCREEN_HEIGHT / 2,
    speed = PLAYER_SPEED
}

-- Timing state
local frame_start_time = 0
local fps = 0
local last_fps_update = 0
local fps_text = "FPS: 0"

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

--- @brief Initialize the application
--- @return boolean Success status
local function init_app()
    vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Initializing")

    -- Set up graphics
    vmupro.text.setFont(vmupro.text.FONT_SMALL)
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.refresh()

    -- Initialize timing
    local current_time = vmupro.system.getTimeUs()
    frame_start_time = current_time
    last_fps_update = current_time

    vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Initialization complete")
    return true
end

-- ============================================================================
-- UPDATE LOGIC
-- ============================================================================

--- @brief Handle player movement input
local function handle_player_movement()
    if vmupro.input.held(vmupro.input.LEFT) then
        player.x = player.x - player.speed
    end
    if vmupro.input.held(vmupro.input.RIGHT) then
        player.x = player.x + player.speed
    end
    if vmupro.input.held(vmupro.input.UP) then
        player.y = player.y - player.speed
    end
    if vmupro.input.held(vmupro.input.DOWN) then
        player.y = player.y + player.speed
    end

    -- Clamp to screen bounds
    if player.x < 0 then player.x = 0 end
    if player.x > SCREEN_WIDTH then player.x = SCREEN_WIDTH end
    if player.y < 0 then player.y = 0 end
    if player.y > SCREEN_HEIGHT then player.y = SCREEN_HEIGHT end
end

--- @brief Update FPS counter
local function update_fps()
    frame_count = frame_count + 1
    local current_time = vmupro.system.getTimeUs()

    if current_time - last_fps_update >= 500000 then  -- Update every 500ms
        local elapsed = (current_time - last_fps_update) / 1000000.0
        fps = math.floor(frame_count / elapsed)
        fps_text = string.format("FPS: %d", fps)
        frame_count = 0
        last_fps_update = current_time
    end
end

--- @brief Main update function
local function update()
    -- Read input once per frame
    vmupro.input.read()

    -- Handle exit
    if vmupro.input.pressed(vmupro.input.B) then
        vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Exit requested")
        app_running = false
        return
    end

    -- Update game logic
    handle_player_movement()
    update_fps()
end

-- ============================================================================
-- RENDERING
-- ============================================================================

--- @brief Render player
local function render_player()
    local half_size = PLAYER_SIZE / 2
    vmupro.graphics.drawFillRect(
        player.x - half_size,
        player.y - half_size,
        player.x + half_size,
        player.y + half_size,
        vmupro.graphics.WHITE
    )
end

--- @brief Render UI overlay
local function render_ui()
    vmupro.text.setFont(vmupro.text.FONT_SMALL)

    -- FPS counter
    vmupro.graphics.drawText(fps_text, 5, 5,
        vmupro.graphics.YELLOW, vmupro.graphics.BLACK)

    -- Position display
    local pos_text = string.format("Pos: (%d,%d)",
        math.floor(player.x), math.floor(player.y))
    vmupro.graphics.drawText(pos_text, 5, 20,
        vmupro.graphics.GREY, vmupro.graphics.BLACK)

    -- Controls hint
    vmupro.graphics.drawText("D-Pad: Move | B: Exit", 10, 220,
        vmupro.graphics.GREY, vmupro.graphics.BLACK)
end

--- @brief Main render function
local function render()
    -- Clear screen
    vmupro.graphics.clear(vmupro.graphics.BLACK)

    -- Draw game objects
    render_player()

    -- Draw UI
    render_ui()

    -- Update display
    vmupro.graphics.refresh()
end

-- ============================================================================
-- CLEANUP
-- ============================================================================

--- @brief Clean up resources before exit
local function cleanup()
    vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Cleaning up resources")
    -- Free any allocated resources here
end

-- ============================================================================
-- MAIN LOOP
-- ============================================================================

--- @brief Main application entry point
--- @return number Exit code (0 = success)
function AppMain()
    -- Initialize
    if not init_app() then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Game", "Initialization failed")
        return 1
    end

    -- Main game loop
    vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Entering main loop")

    while app_running do
        -- Record frame start
        frame_start_time = vmupro.system.getTimeUs()

        -- Update and render
        update()
        render()

        -- Frame timing
        local frame_end_time = vmupro.system.getTimeUs()
        local elapsed_time_us = frame_end_time - frame_start_time
        local delay_time_us = TARGET_FRAME_TIME_US - elapsed_time_us

        if delay_time_us > 0 then
            vmupro.system.delayUs(delay_time_us)
        end
    end

    -- Cleanup and exit
    cleanup()
    vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Application completed successfully")

    return 0
end
```

---

## Summary Checklist

When writing VMU Pro applications, ensure:

- ✅ **AppMain()** function is defined
- ✅ Imports use `import "api/..."` syntax (no extensions)
- ✅ Modules export using table pattern
- ✅ Init-Update-Render pattern is followed
- ✅ Input is read once per frame with `vmupro.input.read()`
- ✅ Graphics cleared once, refreshed once per frame
- ✅ Resources are freed with cleanup functions
- ✅ Frame timing accounts for processing time
- ✅ Functions are small and focused (< 50 lines)
- ✅ Local variables used instead of globals
- ✅ Error checking for resource loading
- ✅ Appropriate log levels used
- ✅ Memory usage monitored for large applications
- ✅ Scene sprites cleaned up with `removeAll()`
- ✅ Constants used instead of magic numbers
- ✅ Code is well-commented with LuaDoc

Following these patterns will result in efficient, maintainable, and bug-free VMU Pro applications.
