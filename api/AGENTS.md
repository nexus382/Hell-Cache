<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-23 -->

# API Directory

VMU Pro LUA SDK API stubs for IDE support. These files provide type hints and documentation for firmware-provided runtime functions.

## Files

### text.lua

Text rendering and font utilities for VMU Pro applications.

**Namespace:** `vmupro.text`

**Functions:**

| Function | Description |
|----------|-------------|
| `vmupro.text.setFont(font_id)` | Set the current font for text rendering |
| `vmupro.text.calcLength(text)` | Calculate pixel width of text with current font |
| `vmupro.text.getFontInfo()` | Get information about the current font |

**Font Constants:**

| Constant | ID | Size |
|----------|----|----|
| `FONT_TINY_6x8` | 0 | 6x8px - Smallest font |
| `FONT_MONO_7x13` | 1 | 7x13px - Tiny monospace |
| `FONT_QUANTICO_15x16` | 2 | 15x16px - UI medium |
| `FONT_QUANTICO_18x20` | 3 | 18x20px - UI medium |
| `FONT_QUANTICO_19x21` | 4 | 19x21px - UI medium |
| `FONT_QUANTICO_25x29` | 5 | 25x29px - UI large |
| `FONT_QUANTICO_29x33` | 6 | 29x33px - UI extra large |
| `FONT_QUANTICO_32x37` | 7 | 32x37px - UI largest |
| `FONT_GABARITO_18x18` | 8 | 18x18px - Medium |
| `FONT_GABARITO_22x24` | 9 | 22x24px - Large |
| `FONT_OPEN_SANS_15x18` | 10 | 15x18px - Medium |
| `FONT_OPEN_SANS_21x24` | 11 | 21x24px - Large |

**Convenience Aliases:**

| Alias | Maps To | Description |
|-------|---------|-------------|
| `FONT_SMALL` | `FONT_MONO_7x13` (1) | Small font |
| `FONT_MEDIUM` | `FONT_OPEN_SANS_15x18` (10) | Medium font |
| `FONT_LARGE` | `FONT_QUANTICO_25x29` (5) | Large font |
| `FONT_DEFAULT` | `FONT_OPEN_SANS_15x18` (10) | Default font |

**Usage Example:**

```lua
-- Set font and measure text
vmupro.text.setFont(vmupro.text.FONT_MEDIUM)
local width = vmupro.text.calcLength("Hello World")
```

## Subdirectories

None.

## Notes

- All functions are stub definitions for IDE support only
- Actual implementations are provided by VMU Pro firmware at runtime
- File is annotated with LuaDoc comments for IDE autocompletion
