# Nested Example - AGENTS.md

<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-17 -->

## Purpose

This directory contains a comprehensive test suite demonstrating the VMU Pro Lua SDK's capabilities through a navigable multi-page application. It serves as both an example of nested module organization and an interactive testing framework for all SDK features.

The application demonstrates:
- **Nested module imports** - Libraries and pages imported as submodules
- **Multi-page navigation** - 39 test pages with keyboard navigation
- **Modular architecture** - Separation of concerns (app logic, libraries, pages, assets)
- **SDK feature coverage** - Graphics, text, input, audio, sprites, and more

## Key Files

| File | Purpose |
|------|---------|
| `app.lua` | Main application entry point - imports all pages and handles navigation/input |
| `metadata.json` | App manifest defining "Nested Example" v1.0.0 with resource declarations |
| `TEST_PLAN.md` | Detailed test plan documenting all 39 test pages and their objectives |
| `icon.bmp` | Application icon (128x128) |
| `pack.sh` / `pack.ps1` | Packaging scripts to bundle the application for deployment |
| `send.sh` / `send.ps1` | Upload scripts to send packaged app to VMU device |

## Subdirectories

| Directory | Contents | Purpose |
|-----------|----------|---------|
| `libraries/` | `maths.lua`, `utils.lua` | Shared utility modules (math functions, clamp/lerp utilities) |
| `pages/` | `page1.lua` through `page39.lua` | Individual test pages demonstrating specific SDK features |
| `assets/` | Audio files (`.wav`, `.mid`), sprites (`.png`, `.bmp`) | Test resources for audio playback, sprite rendering, and graphics tests |

## Application Structure

```
app.lua (main)
  ├─ imports libraries/maths.lua
  ├─ imports libraries/utils.lua
  ├─ imports pages/page1.lua through page39.lua
  └─ handles left/right navigation between pages
```

## Test Page Categories

Based on `TEST_PLAN.md`, the 39 pages cover:

- **Pages 1-3**: Basic Graphics (lines, rectangles, circles, ellipses, polygons)
- **Page 4**: Text Rendering & Fonts
- **Pages 5-8**: Advanced Graphics (clipping, transforms, drawing modes)
- **Pages 9-12**: Sprites & Animation
- **Pages 13-15**: Input Handling (buttons, directional pad)
- **Pages 16-18**: Audio (synth, instruments, sequences)
- **Pages 19-21**: File Operations
- **Pages 22-24**: Double Buffering
- **Pages 25-27**: System Functions
- **Pages 28-30**: Debug Tools
- **Pages 31-39**: Advanced Features & Edge Cases

## Navigation

- **Left/Right Arrows**: Navigate between test pages
- **Page Counter**: Displayed in top-right corner (e.g., "Page 1/39")

## Module Import Pattern

This example demonstrates the SDK's import system:

```lua
-- Import submodules
import "libraries/maths"
import "libraries/utils"
import "pages/page1"
-- ... etc

-- Access module functions
local result = Maths.add(1, 2)
local clamped = Utils.clamp(value, 0, 100)
```

## Dependencies

- VMU Pro Lua SDK
- All API modules: `api/system`, `api/display`, `api/input`, `api/sprites`
- Test assets in `assets/` directory
