# API Module - AGENTS.md

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

This directory contains **Lua SDK stub modules** for VMU Pro development. These files provide IDE support and documentation for VMU Pro's built-in Lua APIs. They are **stub definitions only** - actual implementations are provided by the VMU Pro firmware at runtime.

**Key Characteristics:**
- **IDE Support:** Enables autocompletion, type hints, and documentation in Lua IDEs
- **Stub Definitions:** Functions are empty shells with `end` - real code runs on firmware
- **Reference Material:** Serves as API documentation for developers
- **Zero Runtime Impact:** These files do not increase package size or affect performance

---

## Files

| File | Purpose | Size |
|------|---------|------|
| `text.lua` | Text rendering and font utilities for VMU Pro display | ~2.9KB |

---

## Module: text.lua

### Overview

The `vmupro.text` module provides text rendering and font management for the VMU Pro's display. All functions operate under the `vmupro.text` namespace.

**File Header:**
```lua
--- @file text.lua
--- @brief VMU Pro LUA SDK - Text and Font Functions
--- @author 8BitMods
--- @version 1.0.0
--- @date 2025-09-29
```

### Functions

| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| `vmupro.text.setFont(font_id)` | `font_id` (number) | None | Set the current font for text rendering |
| `vmupro.text.calcLength(text)` | `text` (string) | `width` (number) | Calculate pixel width of text with current font |
| `vmupro.text.getFontInfo()` | None | `table` | Get information about the current font |

### Font Constants

The module defines font ID constants organized by font family:

#### Tiny Fonts
```lua
vmupro.text.FONT_TINY_6x8 = 0      -- Smallest font (6x8px)
vmupro.text.FONT_MONO_7x13 = 1     -- Tiny monospace (7x13px)
```

#### Quantico Font Family (UI Fonts)
```lua
vmupro.text.FONT_QUANTICO_15x16 = 2   -- UI font medium (15x16px)
vmupro.text.FONT_QUANTICO_18x20 = 3   -- UI font medium (18x20px)
vmupro.text.FONT_QUANTICO_19x21 = 4   -- UI font medium (19x21px)
vmupro.text.FONT_QUANTICO_25x29 = 5   -- UI font large (25x29px)
vmupro.text.FONT_QUANTICO_29x33 = 6   -- UI font extra large (29x33px)
vmupro.text.FONT_QUANTICO_32x37 = 7   -- UI font largest (32x37px)
```

#### Gabarito Font Family
```lua
vmupro.text.FONT_GABARITO_18x18 = 8   -- Gabarito medium (18x18px)
vmupro.text.FONT_GABARITO_22x24 = 9   -- Gabarito large (22x24px)
```

#### Open Sans Font Family
```lua
vmupro.text.FONT_OPEN_SANS_15x18 = 10  -- Open Sans medium (15x18px)
vmupro.text.FONT_OPEN_SANS_21x24 = 11  -- Open Sans large (21x24px)
```

### Convenience Aliases

```lua
vmupro.text.FONT_SMALL = 1      -- Alias: FONT_MONO_7x13
vmupro.text.FONT_MEDIUM = 10    -- Alias: FONT_OPEN_SANS_15x18
vmupro.text.FONT_LARGE = 5      -- Alias: FONT_QUANTICO_25x29
vmupro.text.FONT_DEFAULT = 10   -- Alias: FONT_MEDIUM
```

---

## For AI Agents

### Usage Pattern

When working with text rendering in Inner Sanctum:

```lua
-- Set font and draw text
vmupro.text.setFont(vmupro.text.FONT_MEDIUM)
local text_width = vmupro.text.calcLength("Hello World")

-- Center text on screen
local x = (SCREEN_WIDTH - text_width) / 2
vmupro.graphics.drawText(x, y, "Hello World")
```

### Important Notes

1. **Stub Implementation:** All functions end with `end` - they are empty stubs
2. **Firmware Provided:** Real implementations exist in VMU Pro's LuaSdkBindings.cpp
3. **Do Not Modify:** Changing these files will NOT change runtime behavior
4. **Documentation Only:** These files serve as reference and IDE support

### Font Selection Guide

| Use Case | Recommended Font | Constant |
|----------|------------------|----------|
| Debug/logging | Tiny monospace | `FONT_SMALL` or `FONT_MONO_7x13` |
| UI labels | Medium readable | `FONT_DEFAULT` or `FONT_OPEN_SANS_15x18` |
| Titles/headers | Large display | `FONT_LARGE` or `FONT_QUANTICO_25x29` |
| Maximum size | Largest available | `FONT_QUANTICO_32x37` |

### Adding New API Modules

To add support for additional VMU Pro APIs:

1. Create a new `.lua` file in this directory
2. Use the standard header format (see `text.lua`)
3. Define stub functions with LuaDoc annotations
4. Ensure namespace initialization: `vmupro = vmupro or {}`
5. Add to `metadata.json` resources array
6. Document in this AGENTS.md file

---

## Dependencies

### Build Dependencies
- None - these are standalone stub files

### Runtime Dependencies
- VMU Pro firmware with Lua SDK support
- Functions require actual firmware implementation

---

## See Also

- `../AGENTS.md` - Build files overview
- `../app_full.lua` - Game code that uses these APIs
- VMU Pro SDK Documentation (external)
