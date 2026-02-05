<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# nested_example

## Purpose
Full-featured VMU Pro example demonstrating multi-page app architecture, asset management, shared libraries, and page routing.

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `assets/` | Images and other assets (see `assets/AGENTS.md`) |
| `libraries/` | Shared Lua modules (see `libraries/AGENTS.md`) |
| `pages/` | Individual page modules (see `pages/AGENTS.md`) |

## Key Files

| File | Description |
|------|-------------|
| `app.lua` | Entry point with page routing system |
| `metadata.json` | App metadata (mode: 1, applet) |
| `icon.bmp` | 76x76 app icon |

## For AI Agents

### Working In This Example

**DO NOT modify** - COPY to project root and adapt.

### What This Example Shows

**Multi-Page Architecture**:
- Page modules with lifecycle methods
- Central page router
- Shared libraries
- Asset management
- Sprite handling and cleanup

**App Structure**:
```
nested_example/
├── app.lua              # Page routing
├── metadata.json
├── icon.bmp
├── assets/              # Images, sounds
├── libraries/           # Shared code
│   └── utils.lua
└── pages/               # Page modules
    ├── page1.lua
    ├── page2.lua
    └── page3.lua
```

### Page Module Pattern

**Each page follows this pattern**:
```lua
-- pages/page1.lua
Page1 = {}

function Page1.enter()
    -- Setup when page loads
    -- Load sprites, sounds
end

function Page1.update()
    -- Per-frame logic
    vmupro.input.read()
    -- Handle input, update state
end

function Page1.render()
    -- Render page
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawText("Page 1", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
end

function Page1.exit()
    -- CRITICAL: Cleanup
    vmupro.sprite.removeAll()
    -- Free sounds, etc.
end
```

### Page Routing System

**From app.lua**:
```lua
local current_page = nil

function setPage(page_module)
    if current_page and current_page.exit then
        current_page.exit()
    end
    current_page = page_module
    if current_page.enter then
        current_page.enter()
    end
end

function AppMain()
    setPage(Page1)

    while running do
        vmupro.input.read()
        vmupro.sound.update()

        if current_page.update then
            current_page.update()
        end

        if current_page.render then
            current_page.render()
        end

        vmupro.graphics.refresh()
        vmupro.system.delayMs(16)
    end

    return 0
end
```

### Lifecycle Methods

**Page Lifecycle**:
1. `enter()` - Called when page becomes active
2. `update()` - Called every frame
3. `render()` - Called every frame (after update)
4. `exit()` - Called when switching away (cleanup!)

**All methods are optional** - implement only what's needed.

### How to Use This Example

1. **Copy to project**:
   ```bash
   cp -r nested_example/ /path/to/my_app/
   ```

2. **Customize**:
   - Edit `metadata.json`
   - Replace `icon.bmp`
   - Modify/add pages in `pages/`
   - Add shared code to `libraries/`
   - Add assets to `assets/`

3. **Build**:
   ```bash
   cd ../../tools/packer
   python3 packer.py \
       --projectdir ../../examples/nested_example \
       --appname nested_example \
       --meta ../../examples/nested_example/metadata.json \
       --icon ../../examples/nested_example/icon.bmp
   ```

### Best Practices Shown

- **Separation of concerns**: Pages handle their own logic
- **Resource cleanup**: Always call `removeAll()` in `exit()`
- **Shared code**: Libraries for common functionality
- **Asset organization**: Separate directory for assets
- **Consistent patterns**: All pages follow same structure

## Dependencies

### Internal
- `../hello_world/` - Minimal example
- `../../docs/api/` - API documentation
- `../../docs/guides/` - Programming guides
- `../../tools/packer/` - Build tool

### External
- VMU Pro hardware (for testing)

<!-- MANUAL: Example-specific notes can be added below -->
