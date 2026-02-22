<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-17 -->

# examples

## Purpose
Example applications demonstrating the VMU Pro Lua SDK features and best practices. These examples serve as reference implementations for developers learning to build applications for the VMU Pro platform.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `hello_world/` | Minimal "Hello World" application - basic text display, input handling, and application structure |
| `nested_example/` | Comprehensive demonstration of module organization using `require()`, multi-file project structure with libraries/ and pages/ directories, and page navigation system |

## For AI Agents

### Example Application Structure

**Standard Layout:**
```
example_app/
├── app.lua           # Main entry point with AppMain() function
├── metadata.json     # App metadata (name, author, version, entry point)
├── icon.bmp         # 76x76 BMP application icon
├── pack.sh          # Shell script to package application
├── pack.ps1         # PowerShell script to package application
├── send.sh          # Shell script to deploy to device
├── send.ps1         # PowerShell script to deploy to device
├── README.md        # Example-specific documentation
├── libraries/       # Optional: reusable Lua modules
│   ├── maths.lua
│   └── utils.lua
├── pages/          # Optional: page/screen modules
│   ├── page1.lua
│   └── page2.lua
└── assets/         # Optional: sprites, sounds, etc.
```

### Key Concepts Demonstrated

**hello_world example:**
- Basic app.lua structure with `AppMain()` function
- Display clearing and text rendering
- Button input handling (A, B, X, Y, D-pad, START, SELECT)
- Application lifecycle (initialization, main loop, exit)
- Frame rate control (~60 FPS target)
- Packaging and deployment scripts

**nested_example example:**
- Module system using `require()`
- Separating concerns into libraries and pages
- Page navigation and state management
- Asset management (sprites in assets/ directory)
- Multi-file project organization
- Advanced input handling patterns
- Comprehensive test plan (TEST_PLAN.md)

### Running Examples

**1. Package the example:**
```bash
cd examples/hello_world
./pack.sh    # Linux/macOS
# or
.\pack.ps1   # Windows PowerShell
```

**2. Deploy to VMU Pro:**
```bash
./send.sh    # Linux/macOS
# or
.\send.ps1   # Windows PowerShell
```

**Or manually copy:**
Copy the generated `.vmupack` file to the VMU Pro SD card `apps/` folder.

### Learning Path

1. **Start with hello_world** - Understand basic app structure
2. **Study nested_example** - Learn module organization and patterns
3. **Review SDK documentation** - See `../docs/` for API reference
4. **Experiment** - Modify examples to test SDK features
5. **Build your own** - Use examples as templates for new projects

### Common Patterns

**Importing SDK APIs:**
```lua
import "api/system"
import "api/display"
import "api/input"
```

**Loading Custom Modules:**
```lua
local utils = require("libraries.utils")
local maths = require("libraries.maths")
```

**Main Loop Pattern:**
```lua
function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Starting...")

    local running = true
    while running do
        -- Input
        vmupro.input.read()
        if vmupro.input.pressed(vmupro.input.B) then
            running = false
        end

        -- Update
        update()

        -- Render
        vmupro.graphics.clear(vmupro.graphics.BLACK)
        render()
        vmupro.graphics.refresh()

        -- Frame timing
        vmupro.system.delayMs(16)
    end

    return 0
end
```

### Testing Examples

Each example should:
1. Package without errors
2. Load on VMU Pro device
3. Respond to button input
4. Display correctly on 240x240 screen
5. Exit cleanly (B button or START+SELECT)

### Additional Resources

- **SDK API Reference:** `../docs/api/`
- **Getting Started Guide:** `../docs/getting-started.md`
- **First App Tutorial:** `../docs/guides/first-app.md`
- **Parent SDK:** `../AGENTS.md`
