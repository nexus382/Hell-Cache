# Nested Example Libraries - AGENTS.md

<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-17 -->

## Purpose

This directory contains shared utility modules that provide common mathematical and helper functions used across the Nested Example application. These libraries demonstrate the VMU Pro SDK's import system for reusable code organization and modular programming practices.

## Key Files

| File | Purpose | Functions Provided |
|------|---------|-------------------|
| `maths.lua` | Mathematical utility module | Basic arithmetic, trigonometry, utility functions |
| `utils.lua` | General helper utilities | Clamping, interpolation, debugging helpers |

## Module Overview

### maths.lua
Provides mathematical operations and utility functions for the test pages. These functions are used across multiple test pages for calculations, animations, and mathematical demonstrations.

**Key Functions:**
- Basic arithmetic operations
- Trigonometric functions (sin, cos, tan)
- Utility functions for calculations and conversions

### utils.lua
Contains general-purpose utility functions used throughout the application. This module demonstrates common programming patterns and helper functions for data manipulation and debugging.

**Key Functions:**
- `clamp()` - Clamps a value between minimum and maximum
- `lerp()` - Linear interpolation between two values
- Debug and helper utilities

## Import Pattern Example

The libraries are imported and used in the main application following this pattern:

```lua
-- Import submodules
import "libraries/maths"
import "libraries/utils"

-- Access module functions
local result = Maths.add(1, 2)
local clamped = Utils.clamp(value, 0, 100)
```

## Usage Across Test Pages

These libraries are referenced by multiple test pages:

- **Math Functions**: Used in graphics tests, animations, and calculations
- **Utility Functions**: Used for value manipulation, interpolation, and debugging
- **Shared Logic**: Common operations are abstracted to avoid code duplication

## Module Structure

Both libraries follow the VMU Pro SDK's module naming conventions and provide clean APIs for the test pages. They serve as examples of how to organize reusable code in a Lua-based VMU application.

## Dependencies

- Required by all test pages that need mathematical operations or utility functions
- Imported by the main `app.lua` file along with all page modules
- No external dependencies - pure Lua implementations using VMU Pro SDK APIs