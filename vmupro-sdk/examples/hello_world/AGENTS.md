# Hello World Example - Agent Context

<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-17 -->

## Purpose

Basic VMU Pro LUA SDK "Hello World" demonstration application. This is the canonical starting point for learning the VMU Pro SDK, showing fundamental concepts including:

- Application structure with `AppMain()` entry point
- Graphics API usage (clear screen, draw text, draw rectangles)
- Input handling (button press detection)
- System logging with various log levels
- Main game loop pattern with frame limiting
- Namespace imports and organization
- Uptime tracking and frame counting
- Graceful exit handling

## Key Files

| File | Purpose |
|------|---------|
| `app.lua` | Main application script containing `AppMain()` entry point, initialization, main game loop, rendering logic, and input handling |
| `metadata.json` | Application metadata (name, author, version, entry point, mode, environment, resources) used by packager |
| `README.md` | Human documentation describing the example, build/run instructions, expected output, and key features |
| `icon.bmp` | 76x76 pixel BMP format icon displayed in VMU Pro app launcher (must exist before packaging) |
| `pack.sh` / `pack.ps1` | Shell/PowerShell scripts to package the app into `.vmupack` format using the packer tool |
| `send.sh` / `send.ps1` | Shell/PowerShell scripts to deploy the packaged app to VMU Pro hardware via serial |

## Architecture Notes

- **Entry Point**: `AppMain()` function (case-sensitive, must return exit code)
- **Main Loop**: While loop with `update()` and `render()` phases, ~60 FPS (16ms delay)
- **Exit Conditions**: B button press OR 30-second timeout (1800 frames) - safety for testing
- **Imports**: Uses `vmupro.system`, `vmupro.graphics`, `vmupro.input`, `vmupro.text` namespaces
- **Colors**: Uses predefined constants (VMUGREEN, WHITE, YELLOW, BLUE, GREY, BLACK)
- **Fonts**: Demonstrates two fonts (GABARITO_22x24 for title, GABARITO_18x18 for content, SMALL for spacing)

## Build/Deploy Workflow

1. Ensure `icon.bmp` exists (76x76 BMP)
2. Run packer: `python ../../tools/packer/packer.py` (or use `pack.sh`/`pack.ps1`)
3. Deploy to hardware: `python ../../tools/packer/send.py` (or use `send.sh`/`send.ps1`)

## Documentation References

See `vmupro-sdk/docs/` for API details:
- `docs/getting-started.md` - Initial setup
- `docs/api/display.md` - Graphics operations
- `docs/api/input.md` - Button/input handling
- `docs/api/system.md` - Logging and timing
- `docs/guides/first-app.md` - Tutorial walkthrough
