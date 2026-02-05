# Comprehensive Logging Strategy for VMU Pro Debugging

This guide provides a systematic approach to logging for debugging VMU Pro applications, with emphasis on pinpointing crashes and minimizing performance impact.

## Table of Contents

1. [Core Principles](#core-principles)
2. [Log Levels and Usage](#log-levels-and-usage)
3. [Logging Patterns](#logging-patterns)
4. [Display Operation Logging](#display-operation-logging)
5. [Timing and Performance](#timing-and-performance)
6. [Crash Isolation Strategy](#crash-isolation-strategy)
7. [Sample Code Templates](#sample-code-templates)
8. [Log Analysis Techniques](#log-analysis-techniques)

---

## Core Principles

### 1. Log Before Every Operation
```lua
-- ALWAYS log before executing any operation
vmupro.system.log(vmupro.system.LOG_DEBUG, "Tag", "About to: operation_name")
-- Execute operation
vmupro.system.log(vmupro.system.LOG_DEBUG, "Tag", "Completed: operation_name")
```

### 2. Use Contextual Tags
Tags should indicate the subsystem or module:
- `"Init"` - Initialization code
- `"Display"` - Graphics operations
- `"Input"` - Input handling
- `"Audio"` - Sound operations
- `"Memory"` - Memory management
- `"File"` - File operations
- `"Sprite"` - Sprite operations
- `"Page"` - Page navigation
- `"Render"` - Rendering code
- `"Update"` - Game logic updates

### 3. Include Timing Information
Always log timing around critical operations to measure performance and identify slowdowns.

### 4. Minimal Performance Impact
- Use `LOG_DEBUG` for frequently-called operations
- Use `LOG_INFO` for important state changes
- Avoid string concatenation in tight loops when possible

---

## Log Levels and Usage

### LOG_ERROR (0)
**Use for:** Critical failures that prevent the app from running

```lua
if sprite == nil then
    vmupro.system.log(vmupro.system.LOG_ERROR, "Sprite", "Failed to load sprite: assets/player")
    return -1  -- Exit app
end
```

### LOG_WARN (1)
**Use for:** Non-critical issues, degraded performance, out-of-range values

```lua
local memory_usage = vmupro.system.getMemoryUsage()
local memory_limit = vmupro.system.getMemoryLimit()
local usage_percent = (memory_usage / memory_limit) * 100

if usage_percent > 80 then
    vmupro.system.log(vmupro.system.LOG_WARN, "Memory",
        string.format("High memory usage: %d/%d bytes (%.1f%%)",
            memory_usage, memory_limit, usage_percent))
end
```

### LOG_INFO (2)
**Use for:** State changes, navigation, initialization, cleanup

```lua
function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Application starting")
    -- ... app code ...
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Application ending normally")
    return 0
end
```

### LOG_DEBUG (3)
**Use for:** Detailed operation tracking, variable values, function entry/exit

```lua
local function updatePlayerPosition(x, y)
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Player",
        string.format("updatePlayerPosition(x=%d, y=%d)", x, y))

    -- Function logic
    player.x = x
    player.y = y

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Player", "Position updated")
end
```

---

## Logging Patterns

### Pattern 1: Function Entry/Exit
```lua
local function functionName(param1, param2)
    -- Log entry with parameters
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Function",
        string.format("functionName ENTER - param1=%s, param2=%s", param1, param2))

    -- Function logic here
    local result = process(param1, param2)

    -- Log exit with result
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Function",
        string.format("functionName EXIT - result=%s", result))

    return result
end
```

### Pattern 2: Resource Loading
```lua
local function loadResource(resource_path)
    vmupro.system.log(vmupro.system.LOG_INFO, "Resource",
        string.format("Loading resource: %s", resource_path))

    local start_time = vmupro.system.getTimeUs()

    local resource = vmupro.sprite.new(resource_path)

    local load_time = vmupro.system.getTimeUs() - start_time

    if resource == nil then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Resource",
            string.format("Failed to load: %s", resource_path))
        return nil
    end

    vmupro.system.log(vmupro.system.LOG_INFO, "Resource",
        string.format("Loaded %s in %dus", resource_path, load_time))

    return resource
end
```

### Pattern 3: State Changes
```lua
-- Before state change
vmupro.system.log(vmupro.system.LOG_INFO, "GameState",
    string.format("State transition: %s -> %s", current_state, new_state))

current_state = new_state

-- After state change
vmupro.system.log(vmupro.system.LOG_INFO, "GameState",
    string.format("State changed to: %s", current_state))
```

### Pattern 4: Conditional Logging
```lua
-- Only log if debugging is enabled
local DEBUG_MODE = true

local function debugLog(tag, message)
    if DEBUG_MODE then
        vmupro.system.log(vmupro.system.LOG_DEBUG, tag, message)
    end
end

-- Use in code
debugLog("Player", "Jumping")
```

---

## Display Operation Logging

Display operations are particularly prone to crashes. Use this logging strategy for all graphics operations.

### Display Operation Wrapper
```lua
-- Safe wrapper for display operations with comprehensive logging
local function safeClear(color)
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Display",
        string.format("About to: clear(color=0x%X)", color))

    local success, err = pcall(function()
        vmupro.graphics.clear(color)
    end)

    if not success then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Display",
            string.format("clear() FAILED: %s", tostring(err)))
        return false
    end

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Display", "clear() completed")
    return true
end

local function safeDrawText(text, x, y, color, bgColor)
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Display",
        string.format("About to: drawText(text='%s', x=%d, y=%d, color=0x%X, bg=0x%X)",
            text, x, y, color, bgColor))

    local success, err = pcall(function()
        vmupro.graphics.drawText(text, x, y, color, bgColor)
    end)

    if not success then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Display",
            string.format("drawText() FAILED: %s", tostring(err)))
        return false
    end

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Display",
        string.format("drawText() completed: '%s'", text))
    return true
end

local function safeRefresh()
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Display", "About to: refresh()")

    local success, err = pcall(function()
        vmupro.graphics.refresh()
    end)

    if not success then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Display",
            string.format("refresh() FAILED: %s", tostring(err)))
        return false
    end

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Display", "refresh() completed")
    return true
end
```

### Render Function with Logging
```lua
local function render()
    local frame_start = vmupro.system.getTimeUs()
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Frame START")

    -- Clear display
    local clear_success = safeClear(vmupro.graphics.BLACK)
    if not clear_success then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Render", "Failed to clear display")
        return
    end

    -- Draw elements
    local text_success = safeDrawText("Hello World", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
    if not text_success then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Render", "Failed to draw text")
    end

    -- Add more drawing operations here...

    -- Refresh display
    local refresh_success = safeRefresh()
    if not refresh_success then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Render", "Failed to refresh display")
        return
    end

    local frame_time = vmupro.system.getTimeUs() - frame_start
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render",
        string.format("Frame END - took %dus", frame_time))
end
```

---

## Timing and Performance

### Frame Timing
```lua
local frame_count = 0
local last_fps_time = vmupro.system.getTimeUs()
local fps_update_interval = 1000000 -- Update every 1 second (in microseconds)

function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Starting main loop")

    while app_running do
        local frame_start = vmupro.system.getTimeUs()

        -- Your update and render code
        update()
        render()

        -- Calculate frame time
        local frame_end = vmupro.system.getTimeUs()
        local frame_time = frame_end - frame_start

        -- Log slow frames
        if frame_time > 16667 then  -- Target is 60 FPS (16.667ms)
            vmupro.system.log(vmupro.system.LOG_WARN, "Performance",
                string.format("Slow frame: %dus (target: 16667us)", frame_time))
        end

        -- FPS calculation
        frame_count = frame_count + 1
        if frame_end - last_fps_time >= fps_update_interval then
            local fps = math.floor((frame_count * 1000000) / (frame_end - last_fps_time))
            vmupro.system.log(vmupro.system.LOG_INFO, "Performance",
                string.format("FPS: %d", fps))
            frame_count = 0
            last_fps_time = frame_end
        end

        -- Maintain target framerate
        local delay_time = 16667 - frame_time
        if delay_time > 0 then
            vmupro.system.delayUs(delay_time)
        end
    end

    return 0
end
```

### Operation Timing Wrapper
```lua
local function timeOperation(tag, operation_name, func)
    vmupro.system.log(vmupro.system.LOG_DEBUG, tag,
        string.format("Operation START: %s", operation_name))

    local start_time = vmupro.system.getTimeUs()

    -- Execute operation
    local success, result = pcall(func)

    local end_time = vmupro.system.getTimeUs()
    local duration = end_time - start_time

    if success then
        vmupro.system.log(vmupro.system.LOG_INFO, tag,
            string.format("Operation OK: %s took %dus", operation_name, duration))
    else
        vmupro.system.log(vmupro.system.LOG_ERROR, tag,
            string.format("Operation FAILED: %s after %dus - %s",
                operation_name, duration, tostring(result)))
    end

    return success, result
end

-- Usage
timeOperation("Sprite", "Load player sprite", function()
    player_sprite = vmupro.sprite.new("assets/player")
    return player_sprite ~= nil
end)
```

---

## Crash Isolation Strategy

When your app crashes, use this systematic approach to isolate the exact line that fails.

### Step 1: Identify the Suspect Area
Start with broad logging around general areas:

```lua
function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "AppMain START")

    -- Phase 1: Initialization
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Phase 1: Init START")
    init()
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Phase 1: Init OK")

    -- Phase 2: Load Resources
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Phase 2: Load Resources START")
    loadResources()
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Phase 2: Load Resources OK")

    -- Phase 3: Main Loop
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Phase 3: Main Loop START")
    while app_running do
        update()
        render()
    end
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Phase 3: Main Loop OK")

    vmupro.system.log(vmupro.system.LOG_INFO, "App", "AppMain END")
    return 0
end
```

### Step 2: Narrow Down with Granular Logging
Once you identify the crashing phase, add more logs:

```lua
local function render()
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "render() START")

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "About to clear")
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Clear OK")

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "About to set font")
    vmupro.text.setFont(vmupro.text.FONT_SMALL)
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Font set OK")

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "About to draw text")
    vmupro.graphics.drawText("Hello", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Text drawn OK")

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "About to refresh")
    vmupro.graphics.refresh()
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Refresh OK")

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "render() END")
end
```

### Step 3: Parameter Validation
Log all parameters before passing to functions:

```lua
-- Validate color before passing to clear
local bg_color = vmupro.graphics.BLACK
vmupro.system.log(vmupro.system.LOG_DEBUG, "Render",
    string.format("Calling clear with color=0x%X (type=%s)",
        bg_color, type(bg_color)))

vmupro.graphics.clear(bg_color)
vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Clear returned successfully")
```

### Step 4: Incremental Testing
Comment out all operations and enable one at a time:

```lua
local function render()
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Frame START")

    -- Test 1: Only clear
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Test 1: clear only")
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.refresh()
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Test 1: OK")

    -- Test 2: Add font setting
    -- vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Test 2: add font")
    -- vmupro.text.setFont(vmupro.text.FONT_SMALL)
    -- vmupro.graphics.refresh()
    -- vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Test 2: OK")

    -- Test 3: Add text drawing
    -- vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Test 3: add text")
    -- vmupro.graphics.drawText("Hello", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
    -- vmupro.graphics.refresh()
    -- vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Test 3: OK")

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Frame END")
end
```

---

## Sample Code Templates

### Template 1: Basic Application Structure
```lua
import "api/system"
import "api/display"
import "api/input"

local app_running = true

function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "=== AppMain START ===")

    -- Initialization
    vmupro.system.log(vmupro.system.LOG_INFO, "Init", "Initializing...")
    local init_success = init()
    if not init_success then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Init", "Initialization failed")
        return -1
    end
    vmupro.system.log(vmupro.system.LOG_INFO, "Init", "Initialization complete")

    -- Main loop
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Entering main loop")
    local frame_count = 0

    while app_running do
        frame_count = frame_count + 1
        local frame_start = vmupro.system.getTimeUs()

        -- Update
        vmupro.input.read()
        update()

        -- Render
        render()

        -- Frame timing
        local frame_time = vmupro.system.getTimeUs() - frame_start
        if frame_time > 16667 then
            vmupro.system.log(vmupro.system.LOG_WARN, "Performance",
                string.format("Frame %d took %dus", frame_count, frame_time))
        end

        -- Log every 60 frames
        if frame_count % 60 == 0 then
            vmupro.system.log(vmupro.system.LOG_DEBUG, "App",
                string.format("Running... Frame: %d", frame_count))
        end

        -- Maintain framerate
        local delay = 16667 - frame_time
        if delay > 0 then
            vmupro.system.delayUs(delay)
        end
    end

    -- Cleanup
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Cleaning up...")
    cleanup()

    vmupro.system.log(vmupro.system.LOG_INFO, "App", "=== AppMain END ===")
    vmupro.system.log(vmupro.system.LOG_INFO, "App", string.format("Total frames: %d", frame_count))

    return 0
end
```

### Template 2: Display Operations with Full Logging
```lua
local function render()
    local render_start = vmupro.system.getTimeUs()
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Frame START")

    -- Clear screen
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Operation: clear()")
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Operation: clear() OK")

    -- Set font
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Operation: setFont()")
    vmupro.text.setFont(vmupro.text.FONT_SMALL)
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Operation: setFont() OK")

    -- Draw text elements
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Operation: drawText(title)")
    vmupro.graphics.drawText("Title", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Operation: drawText(title) OK")

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Operation: drawText(info)")
    vmupro.graphics.drawText("Info", 10, 30, vmupro.graphics.GREY, vmupro.graphics.BLACK)
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Operation: drawText(info) OK")

    -- Draw rectangle
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Operation: drawRect()")
    vmupro.graphics.drawRect(5, 5, 230, 230, vmupro.graphics.WHITE)
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Operation: drawRect() OK")

    -- Refresh display
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Operation: refresh()")
    vmupro.graphics.refresh()
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", "Operation: refresh() OK")

    local render_time = vmupro.system.getTimeUs() - render_start
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Render",
        string.format("Frame END - took %dus", render_time))
end
```

### Template 3: Resource Loading with Error Handling
```lua
local function loadAllResources()
    vmupro.system.log(vmupro.system.LOG_INFO, "Resources", "=== Loading Resources ===")

    local resources_loaded = 0
    local resources_failed = 0

    -- Load player sprite
    vmupro.system.log(vmupro.system.LOG_INFO, "Resources", "Loading: player sprite")
    local load_start = vmupro.system.getTimeUs()

    player_sprite = vmupro.sprite.new("assets/player")

    local load_time = vmupro.system.getTimeUs() - load_start

    if player_sprite == nil then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Resources",
            string.format("FAILED: player sprite (took %dus)", load_time))
        resources_failed = resources_failed + 1
    else
        vmupro.system.log(vmupro.system.LOG_INFO, "Resources",
            string.format("OK: player sprite (took %dus)", load_time))
        resources_loaded = resources_loaded + 1
    end

    -- Load enemy sprite
    vmupro.system.log(vmupro.system.LOG_INFO, "Resources", "Loading: enemy sprite")
    load_start = vmupro.system.getTimeUs()

    enemy_sprite = vmupro.sprite.new("assets/enemy")

    load_time = vmupro.system.getTimeUs() - load_start

    if enemy_sprite == nil then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Resources",
            string.format("FAILED: enemy sprite (took %dus)", load_time))
        resources_failed = resources_failed + 1
    else
        vmupro.system.log(vmupro.system.LOG_INFO, "Resources",
            string.format("OK: enemy sprite (took %dus)", load_time))
        resources_loaded = resources_loaded + 1
    end

    -- Summary
    vmupro.system.log(vmupro.system.LOG_INFO, "Resources",
        string.format("=== Loading Complete: %d OK, %d FAILED ===",
            resources_loaded, resources_failed))

    return resources_failed == 0
end
```

---

## Log Analysis Techniques

### 1. Identify Last Successful Operation
When a crash occurs, find the last log message before the crash:

```
[INFO] Render: Operation: drawText(title) OK
[DEBUG] Render: Operation: drawText(info)
```

This indicates the crash occurred during `drawText(info)` or immediately after.

### 2. Check Frame Times
Look for increasing frame times that indicate performance degradation:

```
[DEBUG] Render: Frame END - took 15234us
[DEBUG] Render: Frame END - took 18234us
[WARN] Performance: Slow frame: 21345us (target: 16667us)
[ERROR] Render: Frame END - took 45678us
```

This shows a performance problem that eventually leads to a crash.

### 3. Memory Leak Detection
Monitor memory usage patterns:

```lua
-- Log memory every 60 frames
if frame_count % 60 == 0 then
    local usage = vmupro.system.getMemoryUsage()
    local limit = vmupro.system.getMemoryLimit()
    local percent = (usage / limit) * 100

    vmupro.system.log(vmupro.system.LOG_INFO, "Memory",
        string.format("Usage: %d / %d bytes (%.1f%%)", usage, limit, percent))

    if percent > 90 then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Memory", "CRITICAL: Memory almost exhausted")
    end
end
```

### 4. State Transition Verification
Track all state changes to identify invalid states:

```lua
local function changeState(new_state)
    vmupro.system.log(vmupro.system.LOG_INFO, "State",
        string.format("Transition: %s -> %s", current_state, new_state))

    -- Validate state transition
    if validTransitions[current_state] == nil or
       validTransitions[current_state][new_state] == nil then
        vmupro.system.log(vmupro.system.LOG_ERROR, "State",
            string.format("INVALID transition: %s -> %s", current_state, new_state))
        return false
    end

    current_state = new_state
    vmupro.system.log(vmupro.system.LOG_INFO, "State", string.format("State is now: %s", current_state))
    return true
end
```

### 5. Pattern Recognition
Look for repeating patterns that indicate loops or stuck states:

```
[INFO] Update: Player position: x=100, y=100
[INFO] Update: Player position: x=100, y=100
[INFO] Update: Player position: x=100, y=100
...
```

This indicates the player position is not updating, possibly stuck in a loop.

---

## Best Practices Summary

1. **Always log before and after** every critical operation
2. **Use descriptive tags** that indicate the subsystem
3. **Include parameters in log messages** for debugging
4. **Log timing information** for performance analysis
5. **Use appropriate log levels** to reduce noise
6. **Check return values** and log failures immediately
7. **Validate parameters** before passing to SDK functions
8. **Use pcall() wrappers** for risky operations
9. **Log state changes** to track application flow
10. **Test incrementally** when debugging crashes
11. **Monitor memory usage** regularly
12. **Log frame times** to catch performance issues early

---

## Quick Reference: Common Log Message Templates

```lua
-- Initialization
vmupro.system.log(vmupro.system.LOG_INFO, "Init", "Initializing...")
vmupro.system.log(vmupro.system.LOG_INFO, "Init", "Initialization complete")

-- Function entry/exit
vmupro.system.log(vmupro.system.LOG_DEBUG, "Function", "functionName() ENTER")
vmupro.system.log(vmupro.system.LOG_DEBUG, "Function", "functionName() EXIT")

-- Display operations
vmupro.system.log(vmupro.system.LOG_DEBUG, "Display", "About to: clear()")
vmupro.system.log(vmupro.system.LOG_DEBUG, "Display", "Completed: clear()")

-- Resource loading
vmupro.system.log(vmupro.system.LOG_INFO, "Resource", "Loading: " .. path)
vmupro.system.log(vmupro.system.LOG_ERROR, "Resource", "Failed to load: " .. path)

-- Performance
vmupro.system.log(vmupro.system.LOG_DEBUG, "Render", string.format("Frame took %dus", frame_time))
vmupro.system.log(vmupro.system.LOG_WARN, "Performance", "Frame exceeded target")

-- Memory
vmupro.system.log(vmupro.system.LOG_INFO, "Memory",
    string.format("Usage: %d / %d bytes", usage, limit))

-- State changes
vmupro.system.log(vmupro.system.LOG_INFO, "State",
    string.format("State: %s -> %s", old_state, new_state))

-- Error tracking
vmupro.system.log(vmupro.system.LOG_ERROR, "Subsystem",
    string.format("Operation failed: %s", error_message))

-- Success confirmation
vmupro.system.log(vmupro.system.LOG_INFO, "Subsystem", "Operation completed successfully")
```

---

## Appendix: Debug Build Configuration

When packaging for debugging, use:

```bash
python packer.py \
    --projectdir ../../my_app \
    --appname my_app_debug \
    --meta metadata.json \
    --icon icon.bmp \
    --sdkversion 1.0.0 \
    --debug true
```

This generates additional debug files that can help with troubleshooting.

---

For additional debugging techniques, see:
- [Getting Started Guide](../getting-started.md)
- [Troubleshooting Guide](../advanced/troubleshooting.md)
- [System API Reference](../api/system.md)
