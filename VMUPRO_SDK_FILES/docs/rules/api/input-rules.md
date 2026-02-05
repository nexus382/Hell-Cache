# VMU Pro Input API Rules and Best Practices

## Overview

The `vmupro.input` namespace provides button input handling for VMU Pro applications. This document covers all input functions, button constants, input polling patterns, and best practices for responsive controls.

---

## Button Constants

### Available Buttons

```lua
vmupro.input.UP        -- D-Pad Up (constant: 0)
vmupro.input.DOWN      -- D-Pad Down (constant: 1)
vmupro.input.LEFT      -- D-Pad Left (constant: 2)
vmupro.input.RIGHT     -- D-Pad Right (constant: 3)
vmupro.input.A         -- A button (constant: 4)
vmupro.input.B         -- B button (constant: 5)
vmupro.input.POWER     -- Power button (constant: 6)
vmupro.input.MODE      -- Mode button (constant: 7)
vmupro.input.FUNCTION  -- Function button/Bottom button (constant: 8)
```

### Button Groupings

**D-Pad Buttons:** UP, DOWN, LEFT, RIGHT
- Used for directional navigation
- Common in menus and movement controls

**Action Buttons:** A, B
- A = Confirm/Accept action
- B = Cancel/Dismiss action

**System Buttons:** POWER, MODE, FUNCTION
- Use sparingly in game logic
- May have system-level behaviors

---

## Core Input Functions

### 1. `vmupro.input.read()`

**Purpose:** Update button state (MUST be called once per frame)

**Usage Pattern:**
```lua
function update()
    vmupro.input.read()  -- Always call first in update loop
    -- Then check button states
end
```

**Rules:**
- ✅ Call EXACTLY ONCE per frame at the start of your update function
- ✅ Call BEFORE any button state checks
- ❌ Do NOT call multiple times per frame
- ❌ Do NOT skip calling this function

**Why It Matters:**
- Updates internal button state tracking
- Enables proper pressed/held/released detection
- Without this, input functions will not work correctly

---

### 2. `vmupro.input.pressed(button)`

**Purpose:** Detect single button press (one-shot/edge detection)

**Returns:** `boolean` - true if button was JUST pressed this frame

**Usage:**
```lua
if vmupro.input.pressed(vmupro.input.A) then
    -- Triggers ONCE when button is first pressed
    fire_weapon()
end
```

**Characteristics:**
- ✅ Triggers ONCE per button press
- ✅ Perfect for: menus, single actions, toggles
- ✅ Prevents rapid-fire unintended actions
- ❌ Will NOT trigger continuously while held

**Use Cases:**
- Menu selection
- Jump action (single press = single jump)
- Opening/closing UI
- Triggering one-time events
- Toggle switches

---

### 3. `vmupro.input.held(button)`

**Purpose:** Check if button is currently being held down

**Returns:** `boolean` - true while button is held

**Usage:**
```lua
if vmupro.input.held(vmupro.input.RIGHT) then
    -- Triggers EVERY FRAME while button is held
    player.x = player.x + 2
end
```

**Characteristics:**
- ✅ Triggers CONTINUOUSLY while held
- ✅ Perfect for: movement, charging, continuous actions
- ❌ Will trigger on first press AND every subsequent frame
- ❌ Not suitable for one-time actions

**Use Cases:**
- Continuous movement
- Charging a weapon
- Fast scrolling
- Holding to accelerate
- Holding to charge power

---

### 4. `vmupro.input.released(button)`

**Purpose:** Detect when button is released (one-shot)

**Returns:** `boolean` - true if button was JUST released this frame

**Usage:**
```lua
if vmupro.input.released(vmupro.input.A) then
    -- Triggers ONCE when button is released
    release_charged_shot()
end
```

**Characteristics:**
- ✅ Triggers ONCE when button is released
- ✅ Perfect for: charge-and-release mechanics, ending actions
- ❌ Will NOT trigger while button is held

**Use Cases:**
- Releasing charged attacks
- Ending a hold action
- Jump mechanics (hold to jump higher)
- Slingshot-style mechanics
- Detecting button release timing

---

## State Comparison: pressed() vs held() vs released()

### Visual Timeline

```
Frame:    1    2    3    4    5    6    7    8
Button:   ↓────────────────────↑
          Press     Held       Release

pressed():  ✓    ✗    ✗    ✗    ✗    ✗    ✗    ✗
held():     ✓    ✓    ✓    ✓    ✓    ✓    ✗    ✗
released(): ✗    ✗    ✗    ✗    ✗    ✗    ✓    ✗
```

### When to Use Each

| Scenario | Use Function | Reason |
|----------|-------------|---------|
| Menu navigation | `pressed()` | One selection per press |
| Continuous movement | `held()` | Move while held |
| Charge attack (hold) | `held()` | Track charging duration |
| Charge attack (release) | `released()` | Fire when released |
| Jump (single) | `pressed()` | One jump per press |
| Pause game | `pressed()` | Toggle pause state |
| Fast scroll | `held()` | Continue scrolling |
| Dialog advance | `pressed()` | One page per press |

---

## Helper Functions

### 5. `vmupro.input.anythingHeld()`

**Purpose:** Check if ANY button is currently held

**Returns:** `boolean` - true if any button is held

**Usage:**
```lua
if vmupro.input.anythingHeld() then
    reset_idle_timer()
    show_controls_hint(false)
end
```

**Use Cases:**
- Detecting user activity
- Resetting idle timers
- Showing/hiding help text
- Screensaver prevention

---

### 6. `vmupro.input.confirmPressed()`

**Purpose:** Shorthand for A button pressed

**Equivalent to:** `vmupro.input.pressed(vmupro.input.A)`

**Usage:**
```lua
if vmupro.input.confirmPressed() then
    select_menu_item()
end
```

---

### 7. `vmupro.input.confirmReleased()`

**Purpose:** Shorthand for A button released

**Equivalent to:** `vmupro.input.released(vmupro.input.A)`

---

### 8. `vmupro.input.dismissPressed()`

**Purpose:** Shorthand for B button pressed

**Equivalent to:** `vmupro.input.pressed(vmupro.input.B)`

**Usage:**
```lua
if vmupro.input.dismissPressed() then
    close_dialog()
    return_to_menu()
end
```

---

### 9. `vmupro.input.dismissReleased()`

**Purpose:** Shorthand for B button released

**Equivalent to:** `vmupro.input.released(vmupro.input.B)`

---

## Input Polling Patterns

### Essential Pattern: Call read() Each Frame

```lua
-- ✅ CORRECT: Always call read() first
function update()
    vmupro.input.read()  -- Update input state

    -- Now safe to check buttons
    if vmupro.input.pressed(vmupro.input.A) then
        jump()
    end
end

-- ❌ WRONG: Missing read() call
function update()
    if vmupro.input.pressed(vmupro.input.A) then
        jump()  -- Will not work reliably!
    end
end
```

### Game Loop Integration

```lua
function init()
    -- Initialize game state
    player = { x = 0, y = 0, jumping = false }
end

function update()
    -- 1. ALWAYS read input first
    vmupro.input.read()

    -- 2. Handle input
    handle_input()

    -- 3. Update game logic
    update_player()
    update_enemies()

    -- 4. Handle collisions
    check_collisions()
end

function draw()
    -- Render game
    vmupro.graphics.cls()
    draw_player()
    draw_enemies()
end
```

---

## Common Input Handling Patterns

### Menu Navigation

```lua
local menu = {
    items = {"Start Game", "Options", "Quit"},
    selected = 1
}

function update_menu()
    vmupro.input.read()

    -- Navigate down (one item per press)
    if vmupro.input.pressed(vmupro.input.DOWN) then
        menu.selected = menu.selected + 1
        if menu.selected > #menu.items then
            menu.selected = 1  -- Wrap around
        end
        play_sound("menu_move")
    end

    -- Navigate up
    if vmupro.input.pressed(vmupro.input.UP) then
        menu.selected = menu.selected - 1
        if menu.selected < 1 then
            menu.selected = #menu.items  -- Wrap around
        end
        play_sound("menu_move")
    end

    -- Select item
    if vmupro.input.confirmPressed() then
        execute_menu_action(menu.selected)
        play_sound("menu_select")
    end

    -- Cancel/back
    if vmupro.input.dismissPressed() then
        return_to_previous_screen()
        play_sound("menu_cancel")
    end
end
```

---

### Player Movement (4-Directional)

```lua
local player = {
    x = 64,
    y = 64,
    speed = 2
}

function update_movement()
    vmupro.input.read()

    -- Continuous movement while held
    if vmupro.input.held(vmupro.input.UP) then
        player.y = player.y - player.speed
    end

    if vmupro.input.held(vmupro.input.DOWN) then
        player.y = player.y + player.speed
    end

    if vmupro.input.held(vmupro.input.LEFT) then
        player.x = player.x - player.speed
    end

    if vmupro.input.held(vmupro.input.RIGHT) then
        player.x = player.x + player.speed
    end

    -- Keep player in bounds
    player.x = math.max(0, math.min(player.x, 128))
    player.y = math.max(0, math.min(player.y, 64))
end
```

---

### Jump Mechanics (Single Jump)

```lua
local player = {
    y = 50,
    vy = 0,
    on_ground = true,
    jump_power = -5,
    gravity = 0.3
}

function update_player()
    vmupro.input.read()

    -- Jump only when on ground (prevents double jump)
    if vmupro.input.pressed(vmupro.input.A) and player.on_ground then
        player.vy = player.jump_power
        player.on_ground = false
    end

    -- Apply gravity
    player.vy = player.vy + player.gravity
    player.y = player.y + player.vy

    -- Ground collision
    if player.y >= 50 then
        player.y = 50
        player.vy = 0
        player.on_ground = true
    end
end
```

---

### Variable Jump Height (Hold to Jump Higher)

```lua
local player = {
    y = 50,
    vy = 0,
    on_ground = true,
    jump_power = -5,
    gravity = 0.3,
    jump_hold_frames = 0,
    max_jump_frames = 15  -- Maximum frames to hold jump
}

function update_player()
    vmupro.input.read()

    -- Start jump on press
    if vmupro.input.pressed(vmupro.input.A) and player.on_ground then
        player.vy = player.jump_power
        player.on_ground = false
        player.jump_hold_frames = 0
    end

    -- Extend jump while held (up to max frames)
    if vmupro.input.held(vmupro.input.A) and not player.on_ground then
        if player.jump_hold_frames < player.max_jump_frames and player.vy < 0 then
            player.vy = player.vy - 0.2  -- Extra upward force
            player.jump_hold_frames = player.jump_hold_frames + 1
        end
    end

    -- Cut jump short on release
    if vmupro.input.released(vmupro.input.A) and player.vy < 0 then
        player.vy = player.vy * 0.5  -- Reduce upward velocity
    end

    -- Apply gravity
    player.vy = player.vy + player.gravity
    player.y = player.y + player.vy

    -- Ground collision
    if player.y >= 50 then
        player.y = 50
        player.vy = 0
        player.on_ground = true
        player.jump_hold_frames = 0
    end
end
```

---

### Charge and Release Mechanic

```lua
local weapon = {
    charge = 0,
    max_charge = 60,  -- 60 frames = 1 second at 60fps
    charging = false
}

function update_weapon()
    vmupro.input.read()

    -- Start charging on press
    if vmupro.input.pressed(vmupro.input.A) then
        weapon.charging = true
        weapon.charge = 0
    end

    -- Continue charging while held
    if vmupro.input.held(vmupro.input.A) and weapon.charging then
        weapon.charge = math.min(weapon.charge + 1, weapon.max_charge)

        -- Visual/audio feedback
        if weapon.charge % 10 == 0 then
            play_sound("charging")
        end
    end

    -- Release charged shot
    if vmupro.input.released(vmupro.input.A) and weapon.charging then
        local power = weapon.charge / weapon.max_charge  -- 0.0 to 1.0
        fire_shot(power)
        weapon.charging = false
        weapon.charge = 0
    end
end
```

---

### Input Buffering (Advanced)

```lua
local input_buffer = {
    queue = {},
    max_size = 10,
    buffer_time = 5  -- Frames to keep input
}

function buffer_input(button)
    table.insert(input_buffer.queue, {
        button = button,
        frame = 0
    })
end

function update_buffered_input()
    vmupro.input.read()

    -- Add new inputs to buffer
    if vmupro.input.pressed(vmupro.input.A) then
        buffer_input(vmupro.input.A)
    end
    if vmupro.input.pressed(vmupro.input.B) then
        buffer_input(vmupro.input.B)
    end
    -- Add other buttons as needed...

    -- Age and clean buffer
    for i = #input_buffer.queue, 1, -1 do
        input_buffer.queue[i].frame = input_buffer.queue[i].frame + 1
        if input_buffer.queue[i].frame > input_buffer.buffer_time then
            table.remove(input_buffer.queue, i)
        end
    end

    -- Limit buffer size
    while #input_buffer.queue > input_buffer.max_size do
        table.remove(input_buffer.queue, 1)
    end
end

function check_buffered_input(button)
    for i, input in ipairs(input_buffer.queue) do
        if input.button == button then
            table.remove(input_buffer.queue, i)
            return true
        end
    end
    return false
end
```

---

### Combo System

```lua
local combo = {
    sequence = {},
    max_time = 30,  -- Frames between inputs
    timer = 0,
    patterns = {
        {vmupro.input.DOWN, vmupro.input.DOWN, vmupro.input.A},  -- Slam attack
        {vmupro.input.RIGHT, vmupro.input.RIGHT, vmupro.input.A}, -- Dash attack
        {vmupro.input.A, vmupro.input.A, vmupro.input.B}          -- Special combo
    }
}

function update_combo()
    vmupro.input.read()

    -- Add inputs to sequence
    local input_added = false
    for _, btn in ipairs({vmupro.input.UP, vmupro.input.DOWN, vmupro.input.LEFT,
                          vmupro.input.RIGHT, vmupro.input.A, vmupro.input.B}) do
        if vmupro.input.pressed(btn) then
            table.insert(combo.sequence, btn)
            combo.timer = 0
            input_added = true
            break
        end
    end

    -- Reset sequence if too slow
    if not input_added then
        combo.timer = combo.timer + 1
        if combo.timer > combo.max_time and #combo.sequence > 0 then
            combo.sequence = {}
        end
    end

    -- Check for pattern matches
    for i, pattern in ipairs(combo.patterns) do
        if check_sequence_match(combo.sequence, pattern) then
            execute_combo(i)
            combo.sequence = {}
            combo.timer = 0
        end
    end
end

function check_sequence_match(sequence, pattern)
    if #sequence < #pattern then return false end

    -- Check last N inputs match pattern
    local start = #sequence - #pattern + 1
    for i = 1, #pattern do
        if sequence[start + i - 1] ~= pattern[i] then
            return false
        end
    end
    return true
end
```

---

### Dialog/Text Advancement

```lua
local dialog = {
    text = "Welcome to the game!",
    visible = true,
    can_advance = true
}

function update_dialog()
    vmupro.input.read()

    -- Advance dialog on confirm press
    if vmupro.input.confirmPressed() and dialog.can_advance then
        next_dialog()
    end

    -- Skip dialog on dismiss
    if vmupro.input.dismissPressed() then
        skip_all_dialog()
    end
end
```

---

## Best Practices for Responsive Controls

### 1. Always Call read() First

```lua
-- ✅ CORRECT
function update()
    vmupro.input.read()  -- First!
    handle_input()
    update_game()
end

-- ❌ WRONG
function update()
    update_game()
    vmupro.input.read()  -- Too late!
    handle_input()
end
```

---

### 2. Use pressed() for One-Time Actions

```lua
-- ✅ CORRECT: Menu navigation
if vmupro.input.pressed(vmupro.input.DOWN) then
    menu_index = menu_index + 1
end

-- ❌ WRONG: Will advance too fast!
if vmupro.input.held(vmupro.input.DOWN) then
    menu_index = menu_index + 1
end
```

---

### 3. Use held() for Continuous Actions

```lua
-- ✅ CORRECT: Smooth movement
if vmupro.input.held(vmupro.input.RIGHT) then
    player.x = player.x + speed
end

-- ❌ WRONG: Jerky movement
if vmupro.input.pressed(vmupro.input.RIGHT) then
    player.x = player.x + speed
end
```

---

### 4. Prevent Input During Transitions

```lua
local game_state = "playing"  -- playing, paused, transitioning

function update()
    vmupro.input.read()

    -- Ignore input during transitions
    if game_state == "transitioning" then
        return
    end

    -- Normal input handling
    if game_state == "playing" then
        handle_gameplay_input()
    elseif game_state == "paused" then
        handle_pause_input()
    end
end
```

---

### 5. Provide Input Feedback

```lua
function handle_menu_input()
    vmupro.input.read()

    if vmupro.input.pressed(vmupro.input.DOWN) then
        menu.selected = menu.selected + 1
        play_sound("menu_move")  -- Audio feedback
        menu.flash_timer = 5      -- Visual feedback
    end
end
```

---

### 6. Handle Simultaneous Inputs Gracefully

```lua
function update_movement()
    vmupro.input.read()

    local dx = 0
    local dy = 0

    -- Accumulate directional input
    if vmupro.input.held(vmupro.input.UP) then dy = dy - 1 end
    if vmupro.input.held(vmupro.input.DOWN) then dy = dy + 1 end
    if vmupro.input.held(vmupro.input.LEFT) then dx = dx - 1 end
    if vmupro.input.held(vmupro.input.RIGHT) then dx = dx + 1 end

    -- Normalize diagonal movement (optional)
    if dx ~= 0 and dy ~= 0 then
        dx = dx * 0.707  -- sqrt(2)/2
        dy = dy * 0.707
    end

    -- Apply movement
    player.x = player.x + dx * player.speed
    player.y = player.y + dy * player.speed
end
```

---

### 7. Implement Input Debouncing (Advanced)

```lua
local debounce = {
    buttons = {},
    delay = 10  -- Frames to wait between presses
}

function debounced_pressed(button)
    vmupro.input.read()

    -- Initialize button timer if needed
    debounce.buttons[button] = debounce.buttons[button] or 0

    -- Check if pressed and debounce timer expired
    if vmupro.input.pressed(button) and debounce.buttons[button] <= 0 then
        debounce.buttons[button] = debounce.delay
        return true
    end

    -- Decrement timer
    if debounce.buttons[button] > 0 then
        debounce.buttons[button] = debounce.buttons[button] - 1
    end

    return false
end
```

---

## Complete Game Input Example

```lua
-- Complete platformer input handler
local game = {
    state = "playing",  -- playing, paused, game_over
    player = {
        x = 64,
        y = 50,
        vx = 0,
        vy = 0,
        on_ground = true,
        speed = 2,
        jump_power = -5,
        gravity = 0.3
    },
    pause_menu = {
        items = {"Resume", "Restart", "Quit"},
        selected = 1
    }
}

function init()
    -- Initialize game
end

function update()
    vmupro.input.read()  -- Always first!

    if game.state == "playing" then
        update_gameplay()
    elseif game.state == "paused" then
        update_pause_menu()
    elseif game.state == "game_over" then
        update_game_over()
    end
end

function update_gameplay()
    local player = game.player

    -- Horizontal movement (continuous)
    player.vx = 0
    if vmupro.input.held(vmupro.input.LEFT) then
        player.vx = -player.speed
    end
    if vmupro.input.held(vmupro.input.RIGHT) then
        player.vx = player.speed
    end

    -- Jump (single press)
    if vmupro.input.pressed(vmupro.input.A) and player.on_ground then
        player.vy = player.jump_power
        player.on_ground = false
        play_sound("jump")
    end

    -- Variable jump height (release early to jump lower)
    if vmupro.input.released(vmupro.input.A) and player.vy < 0 then
        player.vy = player.vy * 0.5
    end

    -- Pause game (toggle)
    if vmupro.input.pressed(vmupro.input.MODE) then
        game.state = "paused"
        return
    end

    -- Apply physics
    player.vy = player.vy + player.gravity
    player.x = player.x + player.vx
    player.y = player.y + player.vy

    -- Ground collision
    if player.y >= 50 then
        player.y = 50
        player.vy = 0
        player.on_ground = true
    end

    -- Keep in bounds
    player.x = math.max(0, math.min(player.x, 128))
end

function update_pause_menu()
    local menu = game.pause_menu

    -- Navigate menu (one item per press)
    if vmupro.input.pressed(vmupro.input.DOWN) then
        menu.selected = menu.selected + 1
        if menu.selected > #menu.items then
            menu.selected = 1
        end
        play_sound("menu_move")
    end

    if vmupro.input.pressed(vmupro.input.UP) then
        menu.selected = menu.selected - 1
        if menu.selected < 1 then
            menu.selected = #menu.items
        end
        play_sound("menu_move")
    end

    -- Select menu item
    if vmupro.input.confirmPressed() then
        if menu.selected == 1 then
            game.state = "playing"  -- Resume
        elseif menu.selected == 2 then
            restart_game()          -- Restart
        elseif menu.selected == 3 then
            quit_to_menu()          -- Quit
        end
        play_sound("menu_select")
    end

    -- Unpause with MODE button
    if vmupro.input.pressed(vmupro.input.MODE) then
        game.state = "playing"
    end
end

function update_game_over()
    -- Restart on any button
    if vmupro.input.anythingHeld() then
        restart_game()
    end
end

function draw()
    vmupro.graphics.cls()

    if game.state == "playing" then
        draw_gameplay()
    elseif game.state == "paused" then
        draw_gameplay()  -- Draw game behind menu
        draw_pause_menu()
    elseif game.state == "game_over" then
        draw_game_over()
    end
end
```

---

## Performance Considerations

### 1. Read Input Once Per Frame

```lua
-- ✅ CORRECT: One read per frame
function update()
    vmupro.input.read()
    handle_player_input()
    handle_ui_input()
end

-- ❌ WRONG: Multiple reads per frame
function update()
    vmupro.input.read()
    handle_player_input()
    vmupro.input.read()  -- Unnecessary!
    handle_ui_input()
end
```

---

### 2. Early Exit for Inactive States

```lua
function update()
    vmupro.input.read()

    -- Skip input processing if not needed
    if game.state == "cutscene" or game.state == "loading" then
        return
    end

    handle_input()
end
```

---

### 3. Cache Button States for Complex Logic

```lua
function update_complex_input()
    vmupro.input.read()

    -- Cache states for complex conditions
    local up_held = vmupro.input.held(vmupro.input.UP)
    local down_held = vmupro.input.held(vmupro.input.DOWN)
    local a_pressed = vmupro.input.pressed(vmupro.input.A)
    local b_pressed = vmupro.input.pressed(vmupro.input.B)

    -- Use cached values
    if up_held and a_pressed then
        jump_attack()
    elseif down_held and a_pressed then
        ground_pound()
    elseif a_pressed then
        normal_attack()
    end
end
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Forgetting to Call read()

```lua
-- ❌ PROBLEM: Input not working
function update()
    if vmupro.input.pressed(vmupro.input.A) then  -- Won't work!
        jump()
    end
end

-- ✅ SOLUTION: Call read() first
function update()
    vmupro.input.read()  -- Now it works!
    if vmupro.input.pressed(vmupro.input.A) then
        jump()
    end
end
```

---

### Pitfall 2: Using held() for Menus

```lua
-- ❌ PROBLEM: Menu scrolls too fast
function update_menu()
    vmupro.input.read()
    if vmupro.input.held(vmupro.input.DOWN) then  -- Too fast!
        menu_index = menu_index + 1
    end
end

-- ✅ SOLUTION: Use pressed() for menus
function update_menu()
    vmupro.input.read()
    if vmupro.input.pressed(vmupro.input.DOWN) then  -- Perfect!
        menu_index = menu_index + 1
    end
end
```

---

### Pitfall 3: Using pressed() for Movement

```lua
-- ❌ PROBLEM: Jerky movement
function update_player()
    vmupro.input.read()
    if vmupro.input.pressed(vmupro.input.RIGHT) then  -- Jerky!
        player.x = player.x + 2
    end
end

-- ✅ SOLUTION: Use held() for movement
function update_player()
    vmupro.input.read()
    if vmupro.input.held(vmupro.input.RIGHT) then  -- Smooth!
        player.x = player.x + 2
    end
end
```

---

### Pitfall 4: Not Handling State Changes

```lua
-- ❌ PROBLEM: Input processed during transitions
function update()
    vmupro.input.read()
    handle_input()  -- Always processes, even during transitions!

    if transitioning then
        update_transition()
    end
end

-- ✅ SOLUTION: Guard input based on state
function update()
    vmupro.input.read()

    if transitioning then
        update_transition()
        return  -- Don't process input
    end

    handle_input()
end
```

---

## Testing Input

### Manual Testing Checklist

- [ ] Single button presses register correctly
- [ ] Holding buttons works for continuous actions
- [ ] Button releases detected properly
- [ ] Simultaneous button presses handled
- [ ] Input works in all game states
- [ ] No input lag or missed inputs
- [ ] Menus navigate smoothly (not too fast)
- [ ] Movement is smooth (not jerky)
- [ ] Combo inputs register correctly
- [ ] Pause/unpause works reliably

---

### Debug Input Display

```lua
function draw_input_debug()
    local y = 0
    local buttons = {
        {vmupro.input.UP, "UP"},
        {vmupro.input.DOWN, "DOWN"},
        {vmupro.input.LEFT, "LEFT"},
        {vmupro.input.RIGHT, "RIGHT"},
        {vmupro.input.A, "A"},
        {vmupro.input.B, "B"},
        {vmupro.input.MODE, "MODE"}
    }

    for _, btn_data in ipairs(buttons) do
        local btn = btn_data[1]
        local name = btn_data[2]
        local status = ""

        if vmupro.input.pressed(btn) then
            status = "PRESSED"
        elseif vmupro.input.held(btn) then
            status = "HELD"
        elseif vmupro.input.released(btn) then
            status = "RELEASED"
        end

        if status ~= "" then
            vmupro.graphics.print(name .. ": " .. status, 0, y)
            y = y + 8
        end
    end
end
```

---

## Quick Reference

### Function Summary

| Function | Purpose | Returns | Use Case |
|----------|---------|---------|----------|
| `read()` | Update state | void | Call once per frame |
| `pressed(btn)` | Just pressed | boolean | Menus, toggles, single actions |
| `held(btn)` | Currently held | boolean | Movement, charging, continuous |
| `released(btn)` | Just released | boolean | Charge release, ending actions |
| `anythingHeld()` | Any button held | boolean | Activity detection |
| `confirmPressed()` | A button pressed | boolean | Menu confirm |
| `confirmReleased()` | A button released | boolean | Menu confirm release |
| `dismissPressed()` | B button pressed | boolean | Menu cancel |
| `dismissReleased()` | B button released | boolean | Menu cancel release |

### Button Constants

```lua
UP, DOWN, LEFT, RIGHT  -- D-Pad (0-3)
A, B                   -- Action buttons (4-5)
POWER, MODE, FUNCTION  -- System buttons (6-8)
```

### Essential Pattern

```lua
function update()
    vmupro.input.read()        -- 1. Read input
    handle_input()             -- 2. Process input
    update_game_logic()        -- 3. Update game
end
```

---

## Summary

The `vmupro.input` API provides a complete, efficient input system for VMU Pro applications. Key points:

1. **Always call `read()` first** in your update loop
2. Use **`pressed()`** for one-time actions (menus, jumps, toggles)
3. Use **`held()`** for continuous actions (movement, charging)
4. Use **`released()`** for release-based mechanics (charged attacks)
5. Handle input based on game state
6. Provide feedback for responsive controls
7. Test thoroughly across all game states

By following these patterns and best practices, you'll create responsive, intuitive controls for your VMU Pro games.
