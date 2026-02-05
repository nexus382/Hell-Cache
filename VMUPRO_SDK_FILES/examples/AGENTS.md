<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# examples

## Purpose
Example VMU Pro applications demonstrating SDK features, best practices, and common patterns. Use these as templates when creating new apps.

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `hello_world/` | Minimal "Hello World" example app (see `hello_world/AGENTS.md`) |
| `nested_example/` | Multi-page app with assets, libraries, and pages (see `nested_example/AGENTS.md`) |
| `tests/` | SDK test suites and validation code |

## For AI Agents

### Working In This Directory

**DO NOT modify examples directly** - COPY them to the project root and adapt.

**Using Examples as Templates**:

1. **Choose appropriate example**:
   - `hello_world/` - Simple single-page app
   - `nested_example/` - Complex multi-page app with assets

2. **Copy to project**:
   ```bash
   cp -r examples/hello_world/* /path/to/new_app/
   ```

3. **Adapt and modify**:
   - Update `metadata.json` with app details
   - Replace `icon.bmp` with custom icon
   - Modify `app.lua` for your functionality

### Example Structures

**hello_world** (Minimal):
```
hello_world/
├── app.lua              # Entry point with AppMain()
├── metadata.json        # App metadata
└── icon.bmp             # 76x76 icon
```

**nested_example** (Full-featured):
```
nested_example/
├── app.lua              # Entry point and page routing
├── metadata.json        # App metadata
├── icon.bmp             # 76x76 icon
├── assets/              # Images, sounds, etc.
├── libraries/           # Shared Lua modules
└── pages/               # Individual page modules
    ├── page1.lua
    ├── page2.lua
    └── page3.lua
```

### Common Patterns

**Page Module Pattern** (from nested_example):
```lua
-- pages/page1.lua
Page1 = {}

function Page1.enter()
    -- Setup when page loads
    -- Load sprites, sounds, etc.
end

function Page1.update()
    -- Per-frame update logic
    vmupro.input.read()

    -- Handle input, update state
end

function Page1.render()
    -- Render page content
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.drawText("Page 1", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
end

function Page1.exit()
    -- CRITICAL: Clean up resources
    vmupro.sprite.removeAll()
    -- Free sounds, etc.
end
```

**Page Router Pattern**:
```lua
-- app.lua
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

### Testing Examples

To run an example:
```bash
cd ../tools/packer
python3 packer.py \
    --projectdir ../../examples/hello_world \
    --appname hello_world \
    --meta ../../examples/hello_world/metadata.json \
    --icon ../../examples/hello_world/icon.bmp
```

Output: `hello_world.vmupack` → Deploy to VMU Pro

## Dependencies

### Internal
- `../docs/` - API documentation referenced by examples
- `../sdk/` - SDK implementation used by examples
- `../tools/packer/` - Build tool for packaging examples

### External
- VMU Pro hardware (for testing)
- Python 3.x (for packager)

<!-- MANUAL: Example-specific notes can be added below -->
