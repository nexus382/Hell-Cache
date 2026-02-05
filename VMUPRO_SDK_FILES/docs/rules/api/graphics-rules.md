# VMU Pro Graphics API Rules

## Namespace: `vmupro.graphics`

This document provides comprehensive rules, patterns, and best practices for the VMU Pro Graphics API.

---

## Table of Contents

1. [RGB565 Color Format](#rgb565-color-format)
2. [Color Constants](#color-constants)
3. [Display Management](#display-management)
4. [Drawing Functions](#drawing-functions)
5. [Framebuffer Management](#framebuffer-management)
6. [Common Graphics Patterns](#common-graphics-patterns)
7. [Performance Optimization](#performance-optimization)
8. [Best Practices](#best-practices)

---

## RGB565 Color Format

### Overview

VMU Pro uses the RGB565 color format where colors are represented as 16-bit unsigned integers:

- **5 bits** for Red (0-31)
- **6 bits** for Green (0-63)
- **5 bits** for Blue (0-31)

### Structure

```
Bit Layout: RRRR RGGG GGGB BBBB
            15-11 10-5  4-0
```

### Creating Custom Colors

#### Method 1: Direct Hexadecimal

```lua
local custom_color = 0xF800  -- Pure red
local another_color = 0x07E0 -- Pure green
local blue_color = 0x001F    -- Pure blue
```

#### Method 2: RGB Component Calculation

```lua
-- Helper function to create RGB565 colors
function rgb565(r, g, b)
    -- r: 0-255, g: 0-255, b: 0-255
    local r5 = math.floor(r * 31 / 255)  -- Convert to 5-bit
    local g6 = math.floor(g * 63 / 255)  -- Convert to 6-bit
    local b5 = math.floor(b * 31 / 255)  -- Convert to 5-bit
    return (r5 << 11) | (g6 << 5) | b5
end

-- Usage
local purple = rgb565(128, 0, 128)
local cyan = rgb565(0, 255, 255)
```

#### Method 3: Web Color Conversion

```lua
-- Convert web hex color (#RRGGBB) to RGB565
function webToRgb565(hex)
    local r = tonumber(string.sub(hex, 2, 3), 16)
    local g = tonumber(string.sub(hex, 4, 5), 16)
    local b = tonumber(string.sub(hex, 6, 7), 16)
    return rgb565(r, g, b)
end

-- Usage
local color = webToRgb565("#FF6347")  -- Tomato red
```

---

## Color Constants

### Predefined Colors

All color constants are available in the `vmupro.graphics` namespace:

| Constant | Hex Value | RGB888 Equivalent | Description |
|----------|-----------|-------------------|-------------|
| `RED` | 0xF800 | (255, 0, 0) | Pure red |
| `ORANGE` | 0xFBA0 | (255, 119, 0) | Orange |
| `YELLOW` | 0xFF80 | (255, 243, 0) | Yellow |
| `YELLOWGREEN` | 0x7F80 | (127, 243, 0) | Yellow-green |
| `GREEN` | 0x0500 | (0, 160, 0) | Green |
| `BLUE` | 0x045F | (0, 136, 255) | Blue |
| `NAVY` | 0x000C | (0, 0, 99) | Navy blue |
| `VIOLET` | 0x781F | (119, 0, 255) | Violet |
| `MAGENTA` | 0x780D | (119, 0, 107) | Magenta |
| `GREY` | 0xB5B6 | (181, 182, 181) | Grey |
| `BLACK` | 0x0000 | (0, 0, 0) | Black |
| `WHITE` | 0xFFFF | (255, 255, 255) | White |
| `VMUGREEN` | 0x6CD2 | (107, 153, 148) | VMU Pro green |
| `VMUINK` | 0x288A | (40, 17, 82) | VMU Pro ink |

### Usage Example

```lua
vmupro.graphics.clear(vmupro.graphics.BLACK)
vmupro.graphics.drawText("VMU Pro", 10, 10, vmupro.graphics.VMUGREEN)
vmupro.graphics.drawRect(5, 5, 100, 50, vmupro.graphics.WHITE)
vmupro.graphics.refresh()
```

---

## Display Management

### Clear Screen

```lua
-- Clear to black (default)
vmupro.graphics.clear()

-- Clear to specific color
vmupro.graphics.clear(vmupro.graphics.WHITE)
vmupro.graphics.clear(0x001F)  -- Clear to blue
```

**Rules:**
- Always clear the screen at the start of your drawing routine
- Use `clear()` without arguments for fastest black screen clear
- Clearing is essential for preventing artifacts from previous frames

### Refresh Display

```lua
vmupro.graphics.refresh()
```

**Rules:**
- MUST be called after drawing operations to make them visible
- Call once per frame after all drawing is complete
- Avoid calling multiple times per frame (performance impact)

### Basic Drawing Loop

```lua
while true do
    -- Clear screen
    vmupro.graphics.clear()

    -- Draw operations
    vmupro.graphics.drawText("Frame", 10, 10, vmupro.graphics.WHITE)

    -- Update display
    vmupro.graphics.refresh()

    -- Optional: Add delay or wait for next frame
    vmupro.system.delay(16)  -- ~60 FPS
end
```

---

## Drawing Functions

### Shapes

#### Rectangles

```lua
-- Outline rectangle
vmupro.graphics.drawRect(x1, y1, x2, y2, color)

-- Filled rectangle
vmupro.graphics.drawFillRect(x1, y1, x2, y2, color)
```

**Example:**
```lua
-- Draw button with border
vmupro.graphics.drawFillRect(10, 10, 100, 40, vmupro.graphics.BLUE)
vmupro.graphics.drawRect(10, 10, 100, 40, vmupro.graphics.WHITE)
vmupro.graphics.drawText("Click", 35, 20, vmupro.graphics.WHITE)
```

#### Circles

```lua
-- Outline circle
vmupro.graphics.drawCircle(x, y, radius, color)

-- Filled circle
vmupro.graphics.drawCircleFilled(x, y, radius, color)
```

**Example:**
```lua
-- Draw target reticle
vmupro.graphics.drawCircle(120, 120, 30, vmupro.graphics.RED)
vmupro.graphics.drawCircle(120, 120, 20, vmupro.graphics.RED)
vmupro.graphics.drawCircle(120, 120, 10, vmupro.graphics.RED)
vmupro.graphics.drawLine(110, 120, 130, 120, vmupro.graphics.RED)
vmupro.graphics.drawLine(120, 110, 120, 130, vmupro.graphics.RED)
```

#### Ellipses

```lua
-- Outline ellipse
vmupro.graphics.drawEllipse(x, y, rx, ry, color)

-- Filled ellipse
vmupro.graphics.drawEllipseFilled(x, y, rx, ry, color)
```

**Example:**
```lua
-- Draw coin or oval button
vmupro.graphics.drawEllipseFilled(50, 50, 30, 20, vmupro.graphics.YELLOW)
vmupro.graphics.drawEllipse(50, 50, 30, 20, vmupro.graphics.ORANGE)
```

#### Lines

```lua
vmupro.graphics.drawLine(x1, y1, x2, y2, color)
```

**Example:**
```lua
-- Draw grid
for i = 0, 240, 24 do
    vmupro.graphics.drawLine(i, 0, i, 240, vmupro.graphics.GREY)
    vmupro.graphics.drawLine(0, i, 240, i, vmupro.graphics.GREY)
end
```

#### Polygons

```lua
-- Outline polygon
vmupro.graphics.drawPolygon(points, color)

-- Filled polygon
vmupro.graphics.drawPolygonFilled(points, color)
```

**Example:**
```lua
-- Draw triangle
local triangle = {
    {120, 20},  -- Top point
    {70, 100},  -- Bottom left
    {170, 100}  -- Bottom right
}
vmupro.graphics.drawPolygonFilled(triangle, vmupro.graphics.RED)

-- Draw star
local star = {
    {120, 20}, {135, 80}, {195, 80}, {145, 115},
    {165, 175}, {120, 135}, {75, 175}, {95, 115},
    {45, 80}, {105, 80}
}
vmupro.graphics.drawPolygon(star, vmupro.graphics.YELLOW)
```

### Text Rendering

```lua
-- Text with default black background
vmupro.graphics.drawText(text, x, y, color)

-- Text with custom background
vmupro.graphics.drawText(text, x, y, color, bg_color)
```

**Example:**
```lua
-- Score display
vmupro.graphics.drawText("Score: 1000", 10, 10, vmupro.graphics.WHITE)

-- Highlighted text
vmupro.graphics.drawText("GAME OVER", 60, 100, vmupro.graphics.RED, vmupro.graphics.BLACK)

-- Text with colored background
vmupro.graphics.drawText("HP: 75", 10, 220, vmupro.graphics.WHITE, vmupro.graphics.GREEN)
```

**Text Rules:**
- Coordinates specify the top-left corner of the text
- Background color is optional (defaults to black)
- Consider font size when positioning multiple lines
- Use background color for better readability over complex backgrounds

### Fill Operations

#### Flood Fill

```lua
-- Fill with boundary color
vmupro.graphics.floodFill(x, y, fill_color, boundary_color)

-- Fill with tolerance
vmupro.graphics.floodFillTolerance(x, y, fill_color, tolerance)
```

**Example:**
```lua
-- Draw and fill a shape
vmupro.graphics.drawRect(50, 50, 150, 150, vmupro.graphics.WHITE)
vmupro.graphics.floodFill(100, 100, vmupro.graphics.BLUE, vmupro.graphics.WHITE)

-- Paint bucket tool with tolerance
vmupro.graphics.floodFillTolerance(x, y, vmupro.graphics.GREEN, 10)
```

**Fill Rules:**
- Start point must be inside the area to fill
- Boundary color defines the fill limit
- Tolerance allows filling gradients or anti-aliased edges
- Can be computationally expensive on large areas

### Visual Effects

#### Mosaic/Pixelation

```lua
vmupro.graphics.applyMosaicToScreen(x, y, width, height, mosaic_size)
```

**Example:**
```lua
-- Pixelate entire screen
vmupro.graphics.applyMosaicToScreen(0, 0, 240, 240, 8)

-- Pixelate specific region
vmupro.graphics.applyMosaicToScreen(50, 50, 100, 100, 4)

-- Transition effect
for size = 1, 16 do
    vmupro.graphics.applyMosaicToScreen(0, 0, 240, 240, size)
    vmupro.graphics.refresh()
    vmupro.system.delay(50)
end
```

**Mosaic Rules:**
- `mosaic_size = 1` has no effect
- Larger values create stronger pixelation
- Useful for transitions, censoring, or retro effects
- Operates directly on screen buffer (destructive)

---

## Framebuffer Management

### Framebuffer Functions

```lua
-- Get framebuffer references
local back_fb = vmupro.graphics.getBackFramebuffer()
local front_fb = vmupro.graphics.getFrontFramebuffer()
local back_buffer = vmupro.graphics.getBackBuffer()
```

### Double Buffering Pattern

Double buffering prevents screen tearing and flicker:

```lua
function gameLoop()
    while true do
        -- Draw to back buffer
        vmupro.graphics.clear()
        drawGameObjects()
        drawUI()

        -- Swap buffers and display
        vmupro.graphics.refresh()

        -- Update game state
        updatePhysics()
        handleInput()

        -- Frame timing
        vmupro.system.delay(16)  -- ~60 FPS
    end
end
```

### Advanced Buffer Usage

```lua
-- Save current screen state
function saveScreen()
    local back = vmupro.graphics.getBackBuffer()
    -- Save buffer for later restoration
    return back
end

-- Composite rendering
function compositeRender()
    -- Render background layer
    renderBackground()

    -- Render game objects
    renderGameLayer()

    -- Render UI overlay
    renderUILayer()

    -- Present final composition
    vmupro.graphics.refresh()
end
```

---

## Common Graphics Patterns

### Game Loop

```lua
-- Standard game loop with fixed timestep
function gameLoop()
    local running = true
    local frame_time = 16  -- ~60 FPS

    while running do
        local start_time = vmupro.system.getTime()

        -- Clear screen
        vmupro.graphics.clear(vmupro.graphics.BLACK)

        -- Update game logic
        updatePlayer()
        updateEnemies()
        checkCollisions()

        -- Render
        drawBackground()
        drawPlayer()
        drawEnemies()
        drawUI()

        -- Display
        vmupro.graphics.refresh()

        -- Frame rate control
        local elapsed = vmupro.system.getTime() - start_time
        local delay = frame_time - elapsed
        if delay > 0 then
            vmupro.system.delay(delay)
        end

        -- Check for exit
        running = not vmupro.input.isPressed("SELECT")
    end
end
```

### UI Rendering

```lua
-- Menu system
function drawMenu(items, selected_index)
    local y = 50
    local x = 60

    for i, item in ipairs(items) do
        local color = vmupro.graphics.WHITE
        local bg_color = vmupro.graphics.BLACK

        -- Highlight selected item
        if i == selected_index then
            color = vmupro.graphics.BLACK
            bg_color = vmupro.graphics.WHITE
        end

        vmupro.graphics.drawText(item, x, y, color, bg_color)
        y = y + 20
    end
end

-- Health bar
function drawHealthBar(x, y, width, height, current, max)
    local fill_width = math.floor((current / max) * width)

    -- Background
    vmupro.graphics.drawFillRect(x, y, x + width, y + height, vmupro.graphics.BLACK)

    -- Health fill (color changes based on health)
    local color = vmupro.graphics.GREEN
    if current / max < 0.5 then
        color = vmupro.graphics.YELLOW
    end
    if current / max < 0.25 then
        color = vmupro.graphics.RED
    end

    vmupro.graphics.drawFillRect(x, y, x + fill_width, y + height, color)

    -- Border
    vmupro.graphics.drawRect(x, y, x + width, y + height, vmupro.graphics.WHITE)
end

-- Progress indicator
function drawProgressBar(x, y, width, progress)
    -- progress: 0.0 to 1.0
    local fill_width = math.floor(progress * width)

    vmupro.graphics.drawFillRect(x, y, x + fill_width, y + 10, vmupro.graphics.BLUE)
    vmupro.graphics.drawRect(x, y, x + width, y + 10, vmupro.graphics.WHITE)
end
```

### Sprite System

```lua
-- Simple sprite representation
Sprite = {
    x = 0,
    y = 0,
    width = 16,
    height = 16,
    color = vmupro.graphics.WHITE
}

function Sprite:new(x, y, width, height, color)
    local obj = {
        x = x,
        y = y,
        width = width,
        height = height,
        color = color
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Sprite:draw()
    vmupro.graphics.drawFillRect(
        self.x,
        self.y,
        self.x + self.width,
        self.y + self.height,
        self.color
    )
end

function Sprite:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

-- Usage
local player = Sprite:new(100, 100, 16, 16, vmupro.graphics.BLUE)
player:move(5, 0)
player:draw()
```

### Particle System

```lua
-- Simple particle system
Particle = {
    x = 0,
    y = 0,
    vx = 0,
    vy = 0,
    life = 1.0,
    color = vmupro.graphics.WHITE
}

function Particle:new(x, y, vx, vy, color)
    local obj = {
        x = x,
        y = y,
        vx = vx,
        vy = vy,
        life = 1.0,
        color = color
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Particle:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.vy = self.vy + 0.5  -- Gravity
    self.life = self.life - dt * 0.01
end

function Particle:draw()
    if self.life > 0 then
        vmupro.graphics.drawCircleFilled(
            math.floor(self.x),
            math.floor(self.y),
            2,
            self.color
        )
    end
end

function Particle:isAlive()
    return self.life > 0
end

-- Particle manager
ParticleSystem = {
    particles = {}
}

function ParticleSystem:emit(x, y, count)
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local speed = math.random() * 3 + 1
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed
        local color = vmupro.graphics.YELLOW

        table.insert(self.particles, Particle:new(x, y, vx, vy, color))
    end
end

function ParticleSystem:update(dt)
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        p:update(dt)
        if not p:isAlive() then
            table.remove(self.particles, i)
        end
    end
end

function ParticleSystem:draw()
    for _, p in ipairs(self.particles) do
        p:draw()
    end
end
```

### Animation System

```lua
-- Frame-based animation
Animation = {
    frames = {},
    current_frame = 1,
    frame_duration = 100,
    last_update = 0,
    loop = true
}

function Animation:new(frames, duration, loop)
    local obj = {
        frames = frames,
        frame_duration = duration or 100,
        loop = loop ~= false,
        current_frame = 1,
        last_update = vmupro.system.getTime()
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Animation:update()
    local now = vmupro.system.getTime()
    if now - self.last_update >= self.frame_duration then
        self.last_update = now
        self.current_frame = self.current_frame + 1

        if self.current_frame > #self.frames then
            if self.loop then
                self.current_frame = 1
            else
                self.current_frame = #self.frames
            end
        end
    end
end

function Animation:draw(x, y)
    local frame = self.frames[self.current_frame]
    -- Draw current frame (implementation depends on your sprite system)
    frame:draw(x, y)
end

-- Usage
local walk_frames = {sprite1, sprite2, sprite3, sprite4}
local walk_anim = Animation:new(walk_frames, 100, true)

function gameLoop()
    walk_anim:update()
    walk_anim:draw(player.x, player.y)
end
```

### Screen Transitions

```lua
-- Fade to black
function fadeOut(duration)
    local steps = 10
    local step_time = duration / steps

    for i = 0, steps do
        local alpha = i / steps
        -- Apply darkening effect
        vmupro.graphics.applyMosaicToScreen(0, 0, 240, 240, 1)
        vmupro.graphics.refresh()
        vmupro.system.delay(step_time)
    end
end

-- Pixelate transition
function pixelateTransition()
    for size = 1, 16, 2 do
        vmupro.graphics.applyMosaicToScreen(0, 0, 240, 240, size)
        vmupro.graphics.refresh()
        vmupro.system.delay(50)
    end
end

-- Wipe transition
function wipeTransition(direction)
    if direction == "left" then
        for x = 0, 240, 10 do
            vmupro.graphics.drawFillRect(0, 0, x, 240, vmupro.graphics.BLACK)
            vmupro.graphics.refresh()
            vmupro.system.delay(16)
        end
    end
end
```

---

## Performance Optimization

### General Tips

1. **Minimize refresh calls**: Call `refresh()` once per frame
2. **Batch drawing operations**: Group similar operations together
3. **Avoid redundant clears**: Don't clear if you're drawing a full-screen background
4. **Use filled shapes**: `drawFillRect` is faster than multiple `drawLine` calls
5. **Limit particle count**: Keep particle systems under 100 particles for smooth performance

### Dirty Rectangle Rendering

```lua
-- Only redraw changed regions
DirtyRectManager = {
    regions = {}
}

function DirtyRectManager:mark(x, y, width, height)
    table.insert(self.regions, {
        x = x,
        y = y,
        width = width,
        height = height
    })
end

function DirtyRectManager:redraw()
    for _, region in ipairs(self.regions) do
        -- Redraw only this region
        redrawRegion(region.x, region.y, region.width, region.height)
    end
    self.regions = {}
end
```

### Object Pooling

```lua
-- Reuse objects instead of creating new ones
ObjectPool = {
    pool = {},
    active = {}
}

function ObjectPool:get()
    local obj = table.remove(self.pool)
    if not obj then
        obj = createNewObject()
    end
    table.insert(self.active, obj)
    return obj
end

function ObjectPool:release(obj)
    for i, active_obj in ipairs(self.active) do
        if active_obj == obj then
            table.remove(self.active, i)
            obj:reset()
            table.insert(self.pool, obj)
            break
        end
    end
end
```

### Spatial Partitioning

```lua
-- Only draw objects in view
function cullObjects(objects, view_x, view_y, view_width, view_height)
    local visible = {}

    for _, obj in ipairs(objects) do
        if obj.x + obj.width >= view_x and
           obj.x <= view_x + view_width and
           obj.y + obj.height >= view_y and
           obj.y <= view_y + view_height then
            table.insert(visible, obj)
        end
    end

    return visible
end

-- Usage in game loop
function drawGameObjects()
    local visible = cullObjects(all_objects, camera.x, camera.y, 240, 240)
    for _, obj in ipairs(visible) do
        obj:draw()
    end
end
```

### Frame Rate Management

```lua
-- Variable frame rate with delta time
function gameLoopWithDelta()
    local last_time = vmupro.system.getTime()

    while true do
        local current_time = vmupro.system.getTime()
        local dt = current_time - last_time
        last_time = current_time

        -- Update with delta time
        updateGame(dt)

        -- Render
        vmupro.graphics.clear()
        drawGame()
        vmupro.graphics.refresh()
    end
end

-- Fixed timestep with accumulator
function gameLoopFixed()
    local fixed_dt = 16  -- 60 FPS
    local accumulator = 0
    local last_time = vmupro.system.getTime()

    while true do
        local current_time = vmupro.system.getTime()
        local frame_time = current_time - last_time
        last_time = current_time

        accumulator = accumulator + frame_time

        -- Update in fixed steps
        while accumulator >= fixed_dt do
            updateGame(fixed_dt)
            accumulator = accumulator - fixed_dt
        end

        -- Render
        vmupro.graphics.clear()
        drawGame()
        vmupro.graphics.refresh()
    end
end
```

### Memory Optimization

```lua
-- Reuse tables
local temp_table = {}

function optimizedFunction()
    -- Clear and reuse instead of creating new
    for k in pairs(temp_table) do
        temp_table[k] = nil
    end

    -- Use temp_table
    temp_table.x = 10
    temp_table.y = 20
end

-- Pre-allocate arrays
local particles = {}
for i = 1, 100 do
    particles[i] = Particle:new(0, 0, 0, 0, vmupro.graphics.WHITE)
end

-- Reuse instead of creating new particles
function emitParticle(x, y)
    for i, p in ipairs(particles) do
        if not p:isAlive() then
            p:reset(x, y)
            break
        end
    end
end
```

---

## Best Practices

### Code Organization

```lua
-- Separate concerns
-- graphics.lua
Graphics = {}

function Graphics.drawButton(x, y, width, height, text)
    vmupro.graphics.drawFillRect(x, y, x + width, y + height, vmupro.graphics.BLUE)
    vmupro.graphics.drawRect(x, y, x + width, y + height, vmupro.graphics.WHITE)
    vmupro.graphics.drawText(text, x + 5, y + 5, vmupro.graphics.WHITE)
end

-- game.lua
Game = {}

function Game:render()
    vmupro.graphics.clear()
    Graphics.drawButton(10, 10, 80, 30, "Start")
    vmupro.graphics.refresh()
end
```

### Error Handling

```lua
-- Validate inputs
function safeDrawText(text, x, y, color)
    if type(text) ~= "string" then
        text = tostring(text)
    end

    if type(x) ~= "number" or type(y) ~= "number" then
        return  -- Skip invalid coordinates
    end

    vmupro.graphics.drawText(text, x, y, color or vmupro.graphics.WHITE)
end

-- Bounds checking
function drawWithinBounds(x, y, width, height)
    if x < 0 or y < 0 or x + width > 240 or y + height > 240 then
        -- Clamp to screen bounds
        x = math.max(0, math.min(x, 240 - width))
        y = math.max(0, math.min(y, 240 - height))
    end

    vmupro.graphics.drawFillRect(x, y, x + width, y + height, vmupro.graphics.WHITE)
end
```

### Color Management

```lua
-- Create color palette
Colors = {
    background = vmupro.graphics.BLACK,
    primary = vmupro.graphics.VMUGREEN,
    secondary = vmupro.graphics.VMUINK,
    accent = vmupro.graphics.YELLOW,
    danger = vmupro.graphics.RED,
    success = vmupro.graphics.GREEN,
    text = vmupro.graphics.WHITE
}

-- Theme support
function setTheme(theme)
    if theme == "dark" then
        Colors.background = vmupro.graphics.BLACK
        Colors.text = vmupro.graphics.WHITE
    elseif theme == "light" then
        Colors.background = vmupro.graphics.WHITE
        Colors.text = vmupro.graphics.BLACK
    end
end
```

### Debugging Graphics

```lua
-- Debug overlay
DebugDraw = {
    enabled = false
}

function DebugDraw:toggle()
    self.enabled = not self.enabled
end

function DebugDraw:drawBounds(x, y, width, height)
    if self.enabled then
        vmupro.graphics.drawRect(x, y, x + width, y + height, vmupro.graphics.RED)
    end
end

function DebugDraw:drawPoint(x, y)
    if self.enabled then
        vmupro.graphics.drawCircleFilled(x, y, 2, vmupro.graphics.GREEN)
    end
end

function DebugDraw:drawText(text, x, y)
    if self.enabled then
        vmupro.graphics.drawText(text, x, y, vmupro.graphics.YELLOW, vmupro.graphics.BLACK)
    end
end

-- Usage
DebugDraw:drawBounds(player.x, player.y, player.width, player.height)
DebugDraw:drawPoint(target_x, target_y)
DebugDraw:drawText("FPS: " .. fps, 5, 5)
```

### Documentation

```lua
--- Draw a health bar with dynamic coloring
-- @param x number X position
-- @param y number Y position
-- @param width number Bar width in pixels
-- @param height number Bar height in pixels
-- @param current number Current health value
-- @param max number Maximum health value
-- @usage drawHealthBar(10, 10, 100, 10, 75, 100)
function drawHealthBar(x, y, width, height, current, max)
    -- Implementation
end
```

---

## Example Programs

### Simple Drawing App

```lua
-- Drawing application with color selection
DrawingApp = {
    current_color = vmupro.graphics.WHITE,
    colors = {
        vmupro.graphics.RED,
        vmupro.graphics.GREEN,
        vmupro.graphics.BLUE,
        vmupro.graphics.YELLOW,
        vmupro.graphics.WHITE
    },
    color_index = 1
}

function DrawingApp:init()
    vmupro.graphics.clear()
    self:drawColorPalette()
    vmupro.graphics.refresh()
end

function DrawingApp:drawColorPalette()
    local x = 10
    for i, color in ipairs(self.colors) do
        vmupro.graphics.drawFillRect(x, 220, x + 20, 235, color)
        if i == self.color_index then
            vmupro.graphics.drawRect(x - 2, 218, x + 22, 237, vmupro.graphics.WHITE)
        end
        x = x + 25
    end
end

function DrawingApp:run()
    while true do
        -- Handle input
        local touch_x, touch_y = vmupro.input.getTouchPosition()

        if touch_x and touch_y then
            if touch_y > 210 then
                -- Color selection
                local color_idx = math.floor((touch_x - 10) / 25) + 1
                if color_idx >= 1 and color_idx <= #self.colors then
                    self.color_index = color_idx
                    self.current_color = self.colors[color_idx]
                    self:drawColorPalette()
                end
            else
                -- Drawing
                vmupro.graphics.drawCircleFilled(touch_x, touch_y, 3, self.current_color)
            end

            vmupro.graphics.refresh()
        end

        -- Clear button
        if vmupro.input.isPressed("SELECT") then
            vmupro.graphics.clear()
            self:drawColorPalette()
            vmupro.graphics.refresh()
        end

        vmupro.system.delay(16)
    end
end
```

### Bouncing Ball Demo

```lua
-- Physics simulation
Ball = {
    x = 120,
    y = 120,
    vx = 2,
    vy = 1,
    radius = 10,
    color = vmupro.graphics.RED
}

function Ball:update()
    self.x = self.x + self.vx
    self.y = self.y + self.vy

    -- Bounce off walls
    if self.x - self.radius <= 0 or self.x + self.radius >= 240 then
        self.vx = -self.vx
        self.x = math.max(self.radius, math.min(240 - self.radius, self.x))
    end

    if self.y - self.radius <= 0 or self.y + self.radius >= 240 then
        self.vy = -self.vy
        self.y = math.max(self.radius, math.min(240 - self.radius, self.y))
    end
end

function Ball:draw()
    vmupro.graphics.drawCircleFilled(
        math.floor(self.x),
        math.floor(self.y),
        self.radius,
        self.color
    )
end

function runBallDemo()
    while true do
        vmupro.graphics.clear()

        Ball:update()
        Ball:draw()

        vmupro.graphics.refresh()
        vmupro.system.delay(16)
    end
end
```

---

## Summary

The VMU Pro Graphics API provides a comprehensive set of tools for creating rich visual experiences:

1. **Use RGB565** color format for all color values
2. **Always call** `refresh()` after drawing operations
3. **Clear the screen** at the start of each frame
4. **Batch operations** for better performance
5. **Use double buffering** for smooth animation
6. **Optimize rendering** with culling and dirty rectangles
7. **Organize code** into reusable modules
8. **Test on device** for accurate performance metrics

For more information, refer to the VMU Pro SDK documentation and example projects.

---

**File:** `/Users/thomasswift/vmupro-sdk/docs/rules/api/graphics-rules.md`
**Version:** 1.0.0
**Last Updated:** 2026-01-04
