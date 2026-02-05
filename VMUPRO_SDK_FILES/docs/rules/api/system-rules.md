# VMU Pro System API Rules

## Overview

The `vmupro.system` namespace provides essential system and utility functions for VMU Pro LUA applications, including logging, timing, memory management, and hardware control.

**Version:** 1.0.0
**Namespace:** `vmupro.system`
**Copyright:** (c) 2025 8BitMods. All rights reserved.

---

## Table of Contents

1. [Logging Functions](#logging-functions)
2. [Timing and Delay Functions](#timing-and-delay-functions)
3. [Display and Brightness Control](#display-and-brightness-control)
4. [Memory Management Functions](#memory-management-functions)
5. [Framebuffer Functions](#framebuffer-functions)
6. [Constants](#constants)
7. [Best Practices](#best-practices)
8. [Performance Considerations](#performance-considerations)
9. [Error Handling Patterns](#error-handling-patterns)
10. [Common Patterns](#common-patterns)

---

## Logging Functions

### `vmupro.system.log(level, tag, message)`

Logs a message with the specified severity level.

**Parameters:**
- `level` (number): Log level constant (see [Log Level Constants](#log-level-constants))
- `tag` (string): Category or component identifier for the log message
- `message` (string): The message to log

**Returns:** None

**Usage Examples:**

```lua
-- Basic logging
vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Player scored 100 points")
vmupro.system.log(vmupro.system.LOG_ERROR, "Audio", "Failed to load sound")
vmupro.system.log(vmupro.system.LOG_DEBUG, "Physics", "Collision detected at x=10, y=20")
vmupro.system.log(vmupro.system.LOG_WARN, "Memory", "Memory usage approaching limit")

-- Structured logging with tags
vmupro.system.log(vmupro.system.LOG_INFO, "Init", "Application started")
vmupro.system.log(vmupro.system.LOG_INFO, "Network", "Connected to server")
vmupro.system.log(vmupro.system.LOG_ERROR, "FileIO", "Failed to load save data: file not found")

-- Debug logging with variable information
local score = 1000
vmupro.system.log(vmupro.system.LOG_DEBUG, "Score", "Current score: " .. score)
```

**Best Practices:**
- Use appropriate log levels (ERROR for failures, INFO for important events, DEBUG for development)
- Keep tag names short and consistent across your application
- Include relevant context in error messages
- Use DEBUG level logs during development, reduce to INFO/ERROR in production

---

### `vmupro.system.setLogLevel(level)`

Sets the minimum log level filter. Messages below this level will not be displayed.

**Parameters:**
- `level` (number): Minimum log level to display (see [Log Level Constants](#log-level-constants))

**Returns:** None

**Usage Examples:**

```lua
-- Development mode: show all logs including debug
vmupro.system.setLogLevel(vmupro.system.LOG_DEBUG)

-- Production mode: show only important logs
vmupro.system.setLogLevel(vmupro.system.LOG_INFO)

-- Error-only mode: show only critical errors
vmupro.system.setLogLevel(vmupro.system.LOG_ERROR)

-- Conditional logging based on configuration
local DEBUG_MODE = true
if DEBUG_MODE then
    vmupro.system.setLogLevel(vmupro.system.LOG_DEBUG)
else
    vmupro.system.setLogLevel(vmupro.system.LOG_WARN)
end
```

**Best Practices:**
- Set log level once during application initialization
- Use higher log levels (ERROR/WARN) in production to reduce overhead
- Consider making log level configurable via application settings

---

## Timing and Delay Functions

### `vmupro.system.getTimeUs()`

Returns the current system time in microseconds since boot.

**Parameters:** None

**Returns:**
- `number`: Current time in microseconds (double-precision float to handle large values)

**Usage Examples:**

```lua
-- Basic timing
local start_time = vmupro.system.getTimeUs()
-- ... perform operation ...
local end_time = vmupro.system.getTimeUs()
local elapsed = end_time - start_time
vmupro.system.log(vmupro.system.LOG_DEBUG, "Perf", "Operation took " .. elapsed .. " microseconds")

-- Frame timing
local last_frame_time = vmupro.system.getTimeUs()

function update()
    local current_time = vmupro.system.getTimeUs()
    local delta_time = current_time - last_frame_time
    last_frame_time = current_time

    -- Use delta_time for frame-independent calculations
    local delta_seconds = delta_time / 1000000.0
    player.position = player.position + player.velocity * delta_seconds
end

-- Timeout detection
local operation_start = vmupro.system.getTimeUs()
local timeout_us = 5000000 -- 5 seconds

while not operation_complete() do
    if vmupro.system.getTimeUs() - operation_start > timeout_us then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Timeout", "Operation timed out")
        break
    end
end
```

**Important Notes:**
- Returns a Lua number (double-precision float) to prevent integer overflow
- Suitable for high-precision timing and performance measurements
- Value wraps around after extended uptime (handle wraparound in long-running applications)

---

### `vmupro.system.sleep(ms)`

Blocks execution for the specified number of milliseconds.

**Parameters:**
- `ms` (number): Milliseconds to sleep

**Returns:** None

**Usage Examples:**

```lua
-- Basic delay
vmupro.system.sleep(100) -- Sleep for 100ms

-- Animation timing
for i = 1, 10 do
    draw_frame(i)
    vmupro.system.sleep(50) -- 50ms between frames
end

-- Retry with backoff
local retry_count = 0
local max_retries = 5

while not connect_to_server() do
    retry_count = retry_count + 1
    if retry_count >= max_retries then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Network", "Connection failed after " .. max_retries .. " retries")
        break
    end
    vmupro.system.sleep(1000 * retry_count) -- Exponential backoff
end
```

**Best Practices:**
- Avoid using sleep in main game loops (prefer frame-based timing)
- Use sleep for one-time delays, initialization sequences, or retry logic
- Consider using delayMs() for more precise timing control

---

### `vmupro.system.delayUs(us)`

Delays execution for the specified number of microseconds (high precision).

**Parameters:**
- `us` (number): Microseconds to delay

**Returns:** None

**Usage Examples:**

```lua
-- Microsecond-precision delay
vmupro.system.delayUs(1000) -- Delay for 1ms (1000 microseconds)

-- Hardware timing
function toggle_pin_precise()
    set_pin_high()
    vmupro.system.delayUs(500) -- 500 microsecond high pulse
    set_pin_low()
end

-- Audio sample timing
local sample_rate = 44100 -- 44.1kHz
local us_per_sample = 1000000 / sample_rate -- ~22.67 microseconds

for i = 1, num_samples do
    output_sample(samples[i])
    vmupro.system.delayUs(us_per_sample)
end
```

**Best Practices:**
- Use for very short, precise delays (< 1ms)
- Prefer delayMs() for delays >= 1ms (better readability)
- Be aware of system timer resolution limits

---

### `vmupro.system.delayMs(ms)`

Delays execution for the specified number of milliseconds.

**Parameters:**
- `ms` (number): Milliseconds to delay

**Returns:** None

**Usage Examples:**

```lua
-- Standard delay
vmupro.system.delayMs(10) -- Delay for 10ms

-- Startup sequence with delays
function initialize_hardware()
    power_on_display()
    vmupro.system.delayMs(100) -- Wait for display to stabilize

    initialize_audio()
    vmupro.system.delayMs(50) -- Wait for audio chip

    load_configuration()
    vmupro.system.delayMs(20) -- Allow config to settle
end

-- Debouncing
local last_button_time = 0
local debounce_ms = 50

function on_button_press()
    local current_time = vmupro.system.getTimeUs() / 1000 -- Convert to ms
    if current_time - last_button_time < debounce_ms then
        return -- Ignore bouncing
    end
    last_button_time = current_time
    handle_button_press()
end
```

**Best Practices:**
- Use delayMs() for standard delays (clearer than delayUs(ms * 1000))
- Appropriate for initialization, animations, and hardware timing
- Functionally equivalent to sleep() but more explicit about timing precision

---

## Display and Brightness Control

### `vmupro.system.getGlobalBrightness()`

Returns the current global brightness level.

**Parameters:** None

**Returns:**
- `number`: Current brightness level (1-10)

**Usage Examples:**

```lua
-- Check current brightness
local brightness = vmupro.system.getGlobalBrightness()
vmupro.system.log(vmupro.system.LOG_INFO, "Display", "Current brightness: " .. brightness)

-- Save brightness preference
function save_user_settings()
    local settings = {
        brightness = vmupro.system.getGlobalBrightness(),
        volume = get_volume(),
        -- ... other settings
    }
    save_to_file(settings)
end

-- Adaptive brightness based on conditions
function check_battery_mode()
    local brightness = vmupro.system.getGlobalBrightness()
    if is_low_battery() and brightness > 3 then
        vmupro.system.log(vmupro.system.LOG_WARN, "Power", "Reducing brightness to save battery")
        vmupro.system.setGlobalBrightness(3)
    end
end
```

**Best Practices:**
- Query brightness when saving user preferences
- Use to implement adaptive brightness features
- Range is always 1-10 (validate when restoring saved values)

---

### `vmupro.system.setGlobalBrightness(brightness)`

Sets the global brightness level for the display.

**Parameters:**
- `brightness` (number): Brightness level (1-10, where 1 is dimmest, 10 is brightest)

**Returns:** None

**Usage Examples:**

```lua
-- Set brightness levels
vmupro.system.setGlobalBrightness(5)  -- 50% brightness
vmupro.system.setGlobalBrightness(10) -- Maximum brightness
vmupro.system.setGlobalBrightness(1)  -- Minimum brightness

-- User brightness control
function adjust_brightness(delta)
    local current = vmupro.system.getGlobalBrightness()
    local new_brightness = math.max(1, math.min(10, current + delta))
    vmupro.system.setGlobalBrightness(new_brightness)
    vmupro.system.log(vmupro.system.LOG_INFO, "Display", "Brightness set to " .. new_brightness)
end

-- Brightness animation
function fade_to_brightness(target, duration_ms)
    local start = vmupro.system.getGlobalBrightness()
    local steps = math.abs(target - start)
    local delay = duration_ms / steps

    if target > start then
        for b = start + 1, target do
            vmupro.system.setGlobalBrightness(b)
            vmupro.system.delayMs(delay)
        end
    else
        for b = start - 1, target, -1 do
            vmupro.system.setGlobalBrightness(b)
            vmupro.system.delayMs(delay)
        end
    end
end

-- Restore saved brightness
function load_user_settings()
    local settings = load_from_file()
    if settings and settings.brightness then
        -- Validate range before applying
        local brightness = math.max(1, math.min(10, settings.brightness))
        vmupro.system.setGlobalBrightness(brightness)
    end
end

-- Power-saving mode
function enter_power_save_mode()
    saved_brightness = vmupro.system.getGlobalBrightness()
    vmupro.system.setGlobalBrightness(2) -- Dim to near-minimum
end

function exit_power_save_mode()
    vmupro.system.setGlobalBrightness(saved_brightness or 7)
end
```

**Best Practices:**
- Always validate brightness values to stay within 1-10 range
- Consider user preferences and battery state when setting brightness
- Implement smooth transitions for better user experience
- Save user brightness preferences to persistent storage

---

## Memory Management Functions

### `vmupro.system.getMemoryUsage()`

Returns the current memory usage in bytes.

**Parameters:** None

**Returns:**
- `number`: Current memory usage in bytes

**Usage Examples:**

```lua
-- Monitor memory usage
local usage = vmupro.system.getMemoryUsage()
vmupro.system.log(vmupro.system.LOG_DEBUG, "Memory", "Current usage: " .. usage .. " bytes")

-- Memory tracking during operations
local mem_before = vmupro.system.getMemoryUsage()
perform_operation()
local mem_after = vmupro.system.getMemoryUsage()
local mem_used = mem_after - mem_before
vmupro.system.log(vmupro.system.LOG_DEBUG, "Memory", "Operation used " .. mem_used .. " bytes")

-- Memory usage warnings
function check_memory_usage()
    local usage = vmupro.system.getMemoryUsage()
    local limit = vmupro.system.getMemoryLimit()
    local percent = (usage / limit) * 100

    if percent > 90 then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Memory", "Critical: " .. percent .. "% memory used")
    elseif percent > 75 then
        vmupro.system.log(vmupro.system.LOG_WARN, "Memory", "Warning: " .. percent .. "% memory used")
    end
end

-- Periodic memory monitoring
local last_mem_check = 0
local mem_check_interval = 5000000 -- 5 seconds in microseconds

function update()
    local now = vmupro.system.getTimeUs()
    if now - last_mem_check > mem_check_interval then
        check_memory_usage()
        last_mem_check = now
    end
end
```

**Best Practices:**
- Monitor memory usage regularly during development
- Set up warnings at 75% and critical alerts at 90% usage
- Track memory deltas to identify leaks or excessive allocations
- Combine with getMemoryLimit() to calculate percentage usage

---

### `vmupro.system.getMemoryLimit()`

Returns the maximum memory limit in bytes.

**Parameters:** None

**Returns:**
- `number`: Maximum memory limit in bytes

**Usage Examples:**

```lua
-- Get memory limit
local limit = vmupro.system.getMemoryLimit()
vmupro.system.log(vmupro.system.LOG_INFO, "System", "Memory limit: " .. limit .. " bytes")

-- Calculate available memory
function get_available_memory()
    local limit = vmupro.system.getMemoryLimit()
    local usage = vmupro.system.getMemoryUsage()
    return limit - usage
end

-- Memory budget checking
function can_allocate(required_bytes)
    local available = get_available_memory()
    return available >= required_bytes
end

function load_large_asset(size_estimate)
    if not can_allocate(size_estimate) then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Memory", "Insufficient memory to load asset")
        return nil
    end
    return load_asset()
end

-- Display memory statistics
function show_memory_info()
    local usage = vmupro.system.getMemoryUsage()
    local limit = vmupro.system.getMemoryLimit()
    local available = limit - usage
    local percent = (usage / limit) * 100

    print(string.format("Memory: %d / %d bytes (%.1f%% used)", usage, limit, percent))
    print(string.format("Available: %d bytes", available))
    print(string.format("Largest block: %d bytes", vmupro.system.getLargestFreeBlock()))
end
```

**Best Practices:**
- Query once at startup and cache the value (limit doesn't change)
- Use to calculate memory budgets for different subsystems
- Display memory statistics during development

---

### `vmupro.system.getLargestFreeBlock()`

Returns the size of the largest contiguous free memory block in bytes.

**Parameters:** None

**Returns:**
- `number`: Size of the largest contiguous free block in bytes

**Usage Examples:**

```lua
-- Check if large allocation will succeed
local required_size = 65536 -- 64KB
local largest_block = vmupro.system.getLargestFreeBlock()

if largest_block >= required_size then
    -- Allocation likely to succeed
    local buffer = allocate_buffer(required_size)
else
    vmupro.system.log(vmupro.system.LOG_ERROR, "Memory",
        "Cannot allocate " .. required_size .. " bytes (largest block: " .. largest_block .. ")")
end

-- Audio sample loading
function load_sound_sample(filename)
    local file_size = get_file_size(filename)
    local largest_block = vmupro.system.getLargestFreeBlock()

    if largest_block < file_size then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Audio",
            "Cannot load sound: need " .. file_size .. " bytes, largest block is " .. largest_block)
        return nil
    end

    return vmupro.audio.loadSample(filename)
end

-- Memory fragmentation detection
function check_fragmentation()
    local total_free = vmupro.system.getMemoryLimit() - vmupro.system.getMemoryUsage()
    local largest_block = vmupro.system.getLargestFreeBlock()
    local fragmentation_ratio = largest_block / total_free

    if fragmentation_ratio < 0.5 then
        vmupro.system.log(vmupro.system.LOG_WARN, "Memory",
            "Memory fragmentation detected (largest block is only " ..
            (fragmentation_ratio * 100) .. "% of free memory)")
        -- Consider triggering garbage collection or memory reorganization
    end
end

-- Smart resource loading
function load_resources_smart()
    -- Sort resources by size (largest first) to minimize fragmentation
    table.sort(resources, function(a, b) return a.size > b.size end)

    for _, resource in ipairs(resources) do
        if vmupro.system.getLargestFreeBlock() >= resource.size then
            load_resource(resource)
        else
            vmupro.system.log(vmupro.system.LOG_WARN, "Memory",
                "Skipping " .. resource.name .. " due to fragmentation")
        end
    end
end
```

**Important Notes:**
- Critical for preventing allocation failures due to fragmentation
- Even if total free memory is sufficient, allocation may fail if no contiguous block is large enough
- Essential when loading large assets like sound samples or graphics
- Use before any large allocation to ensure success

**Best Practices:**
- Always check before loading large assets (images, sounds, level data)
- Monitor fragmentation by comparing to total free memory
- Load large assets early (before fragmentation occurs)
- Sort allocations by size (largest first) to minimize fragmentation

---

## Framebuffer Functions

### `vmupro.system.getLastBlittedFBSide()`

Returns the identifier of the last framebuffer side that was blitted (for double buffering).

**Parameters:** None

**Returns:**
- `number`: Framebuffer side identifier

**Usage Examples:**

```lua
-- Double buffering management
local current_fb = vmupro.system.getLastBlittedFBSide()
local draw_fb = 1 - current_fb -- Toggle between 0 and 1

-- Draw to the non-visible buffer
set_draw_buffer(draw_fb)
render_scene()
blit_framebuffer(draw_fb)

-- Synchronization with display
function wait_for_vblank()
    local last_fb = vmupro.system.getLastBlittedFBSide()
    while vmupro.system.getLastBlittedFBSide() == last_fb do
        -- Wait for buffer flip
    end
end

-- Frame timing diagnostics
local last_fb_side = -1
local frame_count = 0

function on_render_complete()
    local current_fb = vmupro.system.getLastBlittedFBSide()
    if current_fb ~= last_fb_side then
        frame_count = frame_count + 1
        last_fb_side = current_fb
    end
end
```

**Best Practices:**
- Use for implementing double buffering to prevent tearing
- Toggle between buffers for smooth rendering
- Essential for high-quality graphics applications

---

## Constants

### Log Level Constants

The following constants define log severity levels:

| Constant | Value | Description | Usage |
|----------|-------|-------------|-------|
| `vmupro.system.LOG_ERROR` | 0 | Critical errors | Failures, crashes, unrecoverable conditions |
| `vmupro.system.LOG_WARN` | 1 | Warnings | Potential issues, degraded functionality |
| `vmupro.system.LOG_INFO` | 2 | Information | Normal operations, state changes |
| `vmupro.system.LOG_DEBUG` | 3 | Debug | Detailed information for development |

**Usage:**

```lua
-- Set log level (higher levels include all lower levels)
vmupro.system.setLogLevel(vmupro.system.LOG_INFO) -- Shows ERROR, WARN, and INFO

-- Log messages at different levels
vmupro.system.log(vmupro.system.LOG_ERROR, "Fatal", "Critical system failure")
vmupro.system.log(vmupro.system.LOG_WARN, "Config", "Using default configuration")
vmupro.system.log(vmupro.system.LOG_INFO, "Game", "Level loaded successfully")
vmupro.system.log(vmupro.system.LOG_DEBUG, "Physics", "Velocity: " .. tostring(velocity))
```

---

## Best Practices

### 1. Logging Guidelines

```lua
-- ✅ GOOD: Structured logging with consistent tags
vmupro.system.log(vmupro.system.LOG_ERROR, "FileIO", "Failed to load: " .. filename)
vmupro.system.log(vmupro.system.LOG_INFO, "Network", "Connection established")

-- ❌ BAD: Inconsistent tags and poor messages
vmupro.system.log(vmupro.system.LOG_ERROR, "err", "bad")
vmupro.system.log(vmupro.system.LOG_INFO, "network stuff", "connected")

-- ✅ GOOD: Appropriate log levels
vmupro.system.setLogLevel(vmupro.system.LOG_DEBUG) -- Development
vmupro.system.setLogLevel(vmupro.system.LOG_INFO)  -- Production

-- ❌ BAD: Using DEBUG level in production (performance impact)
vmupro.system.setLogLevel(vmupro.system.LOG_DEBUG) -- Always
```

### 2. Timing Best Practices

```lua
-- ✅ GOOD: Use getTimeUs() for performance measurements
local start = vmupro.system.getTimeUs()
perform_operation()
local elapsed = vmupro.system.getTimeUs() - start

-- ✅ GOOD: Use delayMs() for readability
vmupro.system.delayMs(100) -- Clear: 100 milliseconds

-- ❌ BAD: Using microseconds when milliseconds are more appropriate
vmupro.system.delayUs(100000) -- Unclear: is this 100ms?

-- ✅ GOOD: Frame-independent timing
local delta = (current_time - last_time) / 1000000.0 -- Convert to seconds
update_physics(delta)

-- ❌ BAD: Frame-dependent timing
update_physics(0.016) -- Assumes 60 FPS
```

### 3. Memory Management Best Practices

```lua
-- ✅ GOOD: Check before large allocations
if vmupro.system.getLargestFreeBlock() >= asset_size then
    load_asset(asset_name)
else
    vmupro.system.log(vmupro.system.LOG_ERROR, "Memory", "Cannot load asset: insufficient memory")
end

-- ✅ GOOD: Monitor memory usage
local function check_memory()
    local usage = vmupro.system.getMemoryUsage()
    local limit = vmupro.system.getMemoryLimit()
    if usage / limit > 0.9 then
        vmupro.system.log(vmupro.system.LOG_WARN, "Memory", "High memory usage: " .. (usage/limit*100) .. "%")
    end
end

-- ✅ GOOD: Track memory deltas
local mem_before = vmupro.system.getMemoryUsage()
load_resources()
local mem_used = vmupro.system.getMemoryUsage() - mem_before
vmupro.system.log(vmupro.system.LOG_DEBUG, "Memory", "Resources used " .. mem_used .. " bytes")

-- ❌ BAD: Ignoring memory constraints
load_all_assets() -- May fail without checking available memory
```

### 4. Brightness Control Best Practices

```lua
-- ✅ GOOD: Validate brightness values
local function set_brightness_safe(level)
    level = math.max(1, math.min(10, level)) -- Clamp to valid range
    vmupro.system.setGlobalBrightness(level)
end

-- ✅ GOOD: Smooth brightness transitions
local function fade_brightness(target, duration_ms)
    local start = vmupro.system.getGlobalBrightness()
    local steps = math.abs(target - start)
    local delay = duration_ms / steps

    for i = 1, steps do
        local current = start + (i * (target > start and 1 or -1))
        vmupro.system.setGlobalBrightness(current)
        vmupro.system.delayMs(delay)
    end
end

-- ❌ BAD: Unchecked brightness values
vmupro.system.setGlobalBrightness(user_input) -- May be out of range
```

---

## Performance Considerations

### Logging Performance

```lua
-- Logging has overhead; use appropriate levels in production
-- DEBUG level: High overhead (many messages)
-- INFO level: Moderate overhead
-- ERROR level: Low overhead (few messages)

-- ✅ GOOD: Conditional debug logging
local DEBUG = false
if DEBUG then
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Perf", "Frame time: " .. frame_time)
end

-- ✅ BETTER: Use log level filtering
vmupro.system.setLogLevel(vmupro.system.LOG_INFO) -- Automatically filters DEBUG messages
vmupro.system.log(vmupro.system.LOG_DEBUG, "Perf", "This won't be processed")
```

### Timing Precision

```lua
-- getTimeUs() provides microsecond precision
-- Suitable for performance profiling and high-precision timing

-- ✅ GOOD: High-precision profiling
local start = vmupro.system.getTimeUs()
expensive_operation()
local duration_us = vmupro.system.getTimeUs() - start
vmupro.system.log(vmupro.system.LOG_DEBUG, "Perf", "Operation: " .. duration_us .. " μs")

-- delayUs() and delayMs() are blocking
-- Use sparingly in performance-critical code

-- ❌ BAD: Using delays in main game loop
function update()
    process_game_logic()
    vmupro.system.delayMs(16) -- Blocks entire frame!
end

-- ✅ GOOD: Frame-independent timing
function update()
    local current = vmupro.system.getTimeUs()
    local delta = current - last_time
    process_game_logic(delta)
    last_time = current
end
```

### Memory Management Performance

```lua
-- Memory queries are fast but should not be called excessively

-- ✅ GOOD: Periodic checks
local last_check = 0
local check_interval = 1000000 -- 1 second

function update()
    local now = vmupro.system.getTimeUs()
    if now - last_check > check_interval then
        check_memory_usage()
        last_check = now
    end
end

-- ❌ BAD: Checking every frame
function update()
    local usage = vmupro.system.getMemoryUsage() -- Unnecessary overhead
    local limit = vmupro.system.getMemoryLimit()
    -- ...
end

-- ✅ GOOD: Cache the limit (doesn't change)
local MEMORY_LIMIT = vmupro.system.getMemoryLimit()

function get_memory_percent()
    return (vmupro.system.getMemoryUsage() / MEMORY_LIMIT) * 100
end
```

---

## Error Handling Patterns

### Safe Function Wrappers

```lua
-- Wrap system calls with error handling

local function safe_log(level, tag, message)
    local success, err = pcall(function()
        vmupro.system.log(level, tag, message)
    end)
    if not success then
        -- Fallback logging mechanism
        print("[LOGGING ERROR] " .. tostring(err))
    end
end

local function safe_set_brightness(level)
    -- Validate input
    if type(level) ~= "number" then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Display", "Invalid brightness type: " .. type(level))
        return false
    end

    -- Clamp to valid range
    level = math.max(1, math.min(10, level))

    -- Apply with error handling
    local success, err = pcall(function()
        vmupro.system.setGlobalBrightness(level)
    end)

    if not success then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Display", "Failed to set brightness: " .. tostring(err))
        return false
    end

    return true
end
```

### Memory Allocation Safety

```lua
local function safe_allocate(size, description)
    -- Check total free memory
    local available = vmupro.system.getMemoryLimit() - vmupro.system.getMemoryUsage()
    if available < size then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Memory",
            "Insufficient memory for " .. description .. ": need " .. size .. ", have " .. available)
        return nil
    end

    -- Check largest contiguous block
    local largest = vmupro.system.getLargestFreeBlock()
    if largest < size then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Memory",
            "Memory fragmentation prevents allocation of " .. description ..
            ": need " .. size .. ", largest block " .. largest)
        return nil
    end

    -- Attempt allocation with error handling
    local success, result = pcall(function()
        return allocate_buffer(size)
    end)

    if not success then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Memory",
            "Allocation failed for " .. description .. ": " .. tostring(result))
        return nil
    end

    vmupro.system.log(vmupro.system.LOG_INFO, "Memory",
        "Successfully allocated " .. size .. " bytes for " .. description)
    return result
end
```

### Timeout Protection

```lua
local function wait_for_condition(condition, timeout_ms, description)
    local start = vmupro.system.getTimeUs()
    local timeout_us = timeout_ms * 1000

    while not condition() do
        local elapsed = vmupro.system.getTimeUs() - start
        if elapsed > timeout_us then
            vmupro.system.log(vmupro.system.LOG_ERROR, "Timeout",
                description .. " timed out after " .. timeout_ms .. "ms")
            return false
        end
        vmupro.system.delayMs(10) -- Small delay to prevent busy-waiting
    end

    vmupro.system.log(vmupro.system.LOG_INFO, "Success",
        description .. " completed in " .. ((vmupro.system.getTimeUs() - start) / 1000) .. "ms")
    return true
end

-- Usage
if not wait_for_condition(is_hardware_ready, 5000, "Hardware initialization") then
    -- Handle timeout
    enter_safe_mode()
end
```

---

## Common Patterns

### Application Initialization

```lua
function initialize_app()
    -- Set up logging
    vmupro.system.setLogLevel(vmupro.system.LOG_INFO)
    vmupro.system.log(vmupro.system.LOG_INFO, "Init", "Application starting...")

    -- Display system information
    local mem_limit = vmupro.system.getMemoryLimit()
    vmupro.system.log(vmupro.system.LOG_INFO, "System", "Memory limit: " .. mem_limit .. " bytes")

    -- Set initial brightness
    vmupro.system.setGlobalBrightness(7)

    -- Initialize subsystems with timing
    local start_time = vmupro.system.getTimeUs()

    init_graphics()
    init_audio()
    init_input()

    local init_time = (vmupro.system.getTimeUs() - start_time) / 1000
    vmupro.system.log(vmupro.system.LOG_INFO, "Init",
        "Initialization complete in " .. init_time .. "ms")

    -- Check memory after initialization
    local mem_used = vmupro.system.getMemoryUsage()
    vmupro.system.log(vmupro.system.LOG_INFO, "Memory",
        "Post-init usage: " .. mem_used .. " / " .. mem_limit .. " bytes")
end
```

### Performance Profiling

```lua
local Profiler = {}
Profiler.timers = {}

function Profiler:start(name)
    self.timers[name] = vmupro.system.getTimeUs()
end

function Profiler:stop(name)
    if not self.timers[name] then
        vmupro.system.log(vmupro.system.LOG_WARN, "Profiler", "Timer '" .. name .. "' not started")
        return
    end

    local elapsed = vmupro.system.getTimeUs() - self.timers[name]
    self.timers[name] = nil

    vmupro.system.log(vmupro.system.LOG_DEBUG, "Profiler",
        name .. ": " .. elapsed .. " μs (" .. (elapsed / 1000) .. " ms)")

    return elapsed
end

-- Usage
Profiler:start("render")
render_scene()
Profiler:stop("render")

Profiler:start("physics")
update_physics()
Profiler:stop("physics")
```

### Memory Monitor

```lua
local MemoryMonitor = {
    check_interval_us = 5000000, -- 5 seconds
    last_check = 0,
    warn_threshold = 0.75,
    critical_threshold = 0.90
}

function MemoryMonitor:update()
    local now = vmupro.system.getTimeUs()
    if now - self.last_check < self.check_interval_us then
        return
    end
    self.last_check = now

    local usage = vmupro.system.getMemoryUsage()
    local limit = vmupro.system.getMemoryLimit()
    local largest = vmupro.system.getLargestFreeBlock()
    local percent = usage / limit

    -- Check fragmentation
    local free = limit - usage
    local fragmentation = largest / free

    if percent >= self.critical_threshold then
        vmupro.system.log(vmupro.system.LOG_ERROR, "Memory",
            string.format("CRITICAL: %.1f%% used (%d / %d bytes)",
            percent * 100, usage, limit))
    elseif percent >= self.warn_threshold then
        vmupro.system.log(vmupro.system.LOG_WARN, "Memory",
            string.format("WARNING: %.1f%% used (%d / %d bytes)",
            percent * 100, usage, limit))
    end

    if fragmentation < 0.5 then
        vmupro.system.log(vmupro.system.LOG_WARN, "Memory",
            string.format("Fragmentation detected: largest block %.1f%% of free memory",
            fragmentation * 100))
    end
end

-- Call in main loop
function update()
    MemoryMonitor:update()
    -- ... rest of update logic
end
```

### Frame Rate Limiter

```lua
local FrameLimiter = {
    target_fps = 60,
    frame_time_us = 1000000 / 60, -- ~16666 microseconds
    last_frame = 0
}

function FrameLimiter:init(fps)
    self.target_fps = fps
    self.frame_time_us = 1000000 / fps
    self.last_frame = vmupro.system.getTimeUs()
end

function FrameLimiter:wait()
    local now = vmupro.system.getTimeUs()
    local elapsed = now - self.last_frame

    if elapsed < self.frame_time_us then
        local sleep_us = self.frame_time_us - elapsed
        vmupro.system.delayUs(sleep_us)
    end

    self.last_frame = vmupro.system.getTimeUs()
    return elapsed
end

function FrameLimiter:get_fps()
    local elapsed = vmupro.system.getTimeUs() - self.last_frame
    if elapsed > 0 then
        return 1000000 / elapsed
    end
    return 0
end

-- Usage
FrameLimiter:init(60)

function game_loop()
    while running do
        update()
        render()
        local frame_time = FrameLimiter:wait()

        if frame_time > self.frame_time_us * 1.5 then
            vmupro.system.log(vmupro.system.LOG_WARN, "Performance",
                "Frame took " .. (frame_time / 1000) .. "ms (target: " ..
                (self.frame_time_us / 1000) .. "ms)")
        end
    end
end
```

---

## Summary

The `vmupro.system` namespace provides essential utilities for VMU Pro applications:

- **Logging**: Structured logging with severity levels for debugging and monitoring
- **Timing**: High-precision timing and delays for performance measurement and frame control
- **Display**: Brightness control for user comfort and power management
- **Memory**: Comprehensive memory monitoring and allocation safety
- **Framebuffer**: Double-buffering support for smooth graphics

### Key Takeaways

1. **Always validate input ranges** for brightness (1-10)
2. **Check memory before large allocations** using getLargestFreeBlock()
3. **Use appropriate log levels** (DEBUG in development, INFO/ERROR in production)
4. **Monitor memory usage** to prevent out-of-memory errors
5. **Use getTimeUs() for performance profiling** and frame-independent timing
6. **Cache unchanging values** like memory limit for performance
7. **Implement error handling** for all system calls in production code

---

**Version:** 1.0.0
**Last Updated:** 2025-01-04
**Namespace:** `vmupro.system`
