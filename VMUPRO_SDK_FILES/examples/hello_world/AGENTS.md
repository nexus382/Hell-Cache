<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# hello_world

## Purpose
Minimal VMU Pro "Hello World" example demonstrating the absolute basics: app structure, entry point, text rendering, and input handling.

## Key Files

| File | Description |
|------|-------------|
| `app.lua` | Minimal app with AppMain() function |
| `metadata.json` | App metadata (mode: 1, applet) |
| `icon.bmp` | 76x76 app icon |

## For AI Agents

### Working In This Example

**DO NOT modify** - COPY to project root and adapt.

### What This Example Shows

**Basic App Structure**:
```lua
import "api/system"
import "api/display"
import "api/input"

function AppMain()
    local running = true

    while running do
        vmupro.input.read()

        if vmupro.input.pressed(vmupro.input.B) then
            running = false
        end

        vmupro.graphics.clear(vmupro.graphics.BLACK)
        vmupro.graphics.drawText("Hello World!", 10, 10, vmupro.graphics.WHITE, vmupro.graphics.BLACK)
        vmupro.graphics.refresh()

        vmupro.system.delayMs(16)
    end

    return 0
end
```

**Key Concepts**:
1. Import SDK modules with `import "api/..."`
2. Define `AppMain()` function
3. Main loop with input, clear, draw, refresh
4. Return exit code (0 = success)
5. Frame rate control with `delayMs(16)` (~60 FPS)

### How to Use This Example

1. **Copy to project**:
   ```bash
   cp -r hello_world/ /path/to/my_app/
   ```

2. **Customize**:
   - Edit `metadata.json` with your app details
   - Replace `icon.bmp` with your icon
   - Modify `app.lua` for your functionality

3. **Build**:
   ```bash
   cd ../../tools/packer
   python3 packer.py \
       --projectdir ../../examples/hello_world \
       --appname hello_world \
       --meta ../../examples/hello_world/metadata.json \
       --icon ../../examples/hello_world/icon.bmp
   ```

### Minimal vs Full Examples

**Use hello_world when**:
- Learning VMU Pro basics
- Creating simple utilities
- Testing quick ideas

**Use nested_example when**:
- Building complex apps
- Need multiple pages
- Using assets/libraries

## Dependencies

### Internal
- `../nested_example/` - Full-featured example
- `../../docs/api/` - API documentation
- `../../tools/packer/` - Build tool

### External
- VMU Pro hardware (for testing)

<!-- MANUAL: Example-specific notes can be added below -->
