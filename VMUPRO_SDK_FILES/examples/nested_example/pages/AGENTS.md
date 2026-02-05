<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# pages

## Purpose
Individual page modules for the nested example app. Each page is a self-contained screen with its own lifecycle methods.

## Key Files

| File | Description |
|------|-------------|
| `page1.lua` | First page example |
| `page2.lua` | Second page example |
| `page3.lua` | Third page example |

## For AI Agents

### Working In This Directory

**These are example pages** - reference for creating page modules.

### Page Module Pattern

**Complete Page Structure**:
```lua
-- pages/mypage.lua
MyPage = {}

-- Optional: Called when page becomes active
function MyPage.enter()
    -- Load sprites
    background = vmupro.sprite.new("assets/background")
    player = vmupro.sprite.new("assets/player")

    -- Load sounds
    vmupro.audio.startListenMode()
    bgm = vmupro.sound.synth.new(vmupro.sound.kWaveSine)
end

-- Optional: Called every frame for updates
function MyPage.update()
    vmupro.input.read()

    -- Handle input
    if vmupro.input.pressed(vmupro.input.A) then
        -- Do something
    end

    -- Update state
    updatePlayer()
end

-- Optional: Called every frame for rendering
function MyPage.render()
    vmupro.graphics.clear(vmupro.graphics.BLACK)

    -- Draw sprites
    vmupro.sprite.draw(background, 0, 0, 0)
    vmupro.sprite.draw(player, player_x, player_y, 0)

    -- Draw UI
    vmupro.graphics.drawText("Score: " .. score, 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
end

-- Optional: Called when switching away from page
function MyPage.exit()
    -- CRITICAL: Cleanup sprites
    vmupro.sprite.removeAll()

    -- Cleanup sounds
    vmupro.sound.synth.free(bgm)
    vmupro.audio.exitListenMode()
end
```

### Lifecycle Methods

**All methods are optional** - implement only what's needed:

| Method | When Called | Purpose |
|--------|-------------|---------|
| `enter()` | Page becomes active | Load resources, initialize state |
| `update()` | Every frame | Handle input, update state |
| `render()` | Every frame (after update) | Draw everything |
| `exit()` | Switching away | Cleanup resources |

### Page Routing

**From app.lua**:
```lua
local current_page = nil

function setPage(page_module)
    if current_page and current_page.exit then
        current_page.exit()  -- Cleanup old page
    end
    current_page = page_module
    if current_page.enter then
        current_page.enter()  -- Setup new page
    end
end

-- Usage:
setPage(Page1)
setPage(Page2)
```

### Common Patterns

**State Management**:
```lua
-- In page module
local player_x = 120
local player_y = 120
local score = 0

function MyPage.enter()
    -- Reset state
    player_x = 120
    player_y = 120
    score = 0
end
```

**Input Handling**:
```lua
function MyPage.update()
    vmupro.input.read()

    if vmupro.input.pressed(vmupro.input.A) then
        setPage(Page2)  -- Navigate to another page
    end

    if vmupro.input.held(vmupro.input.UP) then
        player_y = player_y - 1
    end
end
```

**Sprite Management**:
```lua
function MyPage.enter()
    -- Load sprites
    player = vmupro.sprite.new("assets/player")
    enemy = vmupro.sprite.new("assets/enemy")
end

function MyPage.exit()
    -- CRITICAL: Always cleanup
    vmupro.sprite.removeAll()
    -- Individual cleanup optional
    -- vmupro.sprite.free(player)
end
```

### Best Practices

- **Always cleanup** in `exit()` method
- **Load resources** in `enter()` method
- **Keep update focused** on input and state changes
- **Keep render focused** on drawing only
- **Use local variables** for page-specific state
- **Avoid globals** to prevent conflicts between pages

## Dependencies

### Internal
- `../app.lua` - Page router using these pages
- `../libraries/` - Shared utilities used by pages
- `../assets/` - Resources loaded by pages

### External
- VMU Pro SDK (input, graphics, sprites, audio)

<!-- MANUAL: Page-specific notes can be added below -->
