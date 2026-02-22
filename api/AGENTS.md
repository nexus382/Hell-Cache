<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-17 -->

# api/

## Purpose

VMU Pro SDK API stub files for IDE autocompletion and documentation. This directory contains Lua interface definitions that provide type hints, documentation, and code completion support for development environments.

These are **stub definitions only** - the actual implementations are provided by the VMU Pro firmware at runtime. The stubs enable:
- IDE autocompletion and inline documentation
- Type checking and linting support
- Function signature reference during development
- Consistent API documentation across the project

## Key Files

| File | Description |
|------|-------------|
| `text.lua` | Text rendering and font utilities API stub |

## File Details

### text.lua

VMU Pro LUA SDK - Text and Font Functions API definition.

**Namespace:** `vmupro.text`

**Functions:**
- `vmupro.text.setFont(font_id)` - Set current font for text rendering
- `vmupro.text.calcLength(text)` - Calculate pixel width of text with current font
- `vmupro.text.getFontInfo()` - Get information about current font

**Font Constants:**

| Constant | Value | Size | Description |
|----------|-------|------|-------------|
| `FONT_TINY_6x8` | 0 | 6x8px | Smallest font |
| `FONT_MONO_7x13` | 1 | 7x13px | Tiny monospace |
| `FONT_QUANTICO_15x16` | 2 | 15x16px | UI font medium-small |
| `FONT_QUANTICO_18x20` | 3 | 18x20px | UI font medium |
| `FONT_QUANTICO_19x21` | 4 | 19x21px | UI font medium-large |
| `FONT_QUANTICO_25x29` | 5 | 25x29px | UI font large |
| `FONT_QUANTICO_29x33` | 6 | 29x33px | UI font extra large |
| `FONT_QUANTICO_32x37` | 7 | 32x37px | UI font largest |
| `FONT_GABARITO_18x18` | 8 | 18x18px | Gabarito medium |
| `FONT_GABARITO_22x24` | 9 | 22x24px | Gabarito large |
| `FONT_OPEN_SANS_15x18` | 10 | 15x18px | Open Sans medium |
| `FONT_OPEN_SANS_21x24` | 11 | 21x24px | Open Sans large |

**Convenience Aliases:**
- `FONT_SMALL` = 1 (MONO_7x13)
- `FONT_MEDIUM` = 10 (OPEN_SANS_15x18)
- `FONT_LARGE` = 5 (QUANTICO_25x29)
- `FONT_DEFAULT` = 10 (MEDIUM)

**Usage Examples:**
```lua
-- Set font for rendering
vmupro.text.setFont(vmupro.text.FONT_MEDIUM)

-- Measure text width for layout
local width = vmupro.text.calcLength("Hello World")

-- Get current font information
local info = vmupro.text.getFontInfo()
```

## Subdirectories

None.

## For AI Agents

### Working In This Directory

**Important Notes:**
- Files in this directory are **API stubs only** - they contain function signatures and constants but no actual implementation
- Real implementations live in VMU Pro firmware and are injected at runtime
- When modifying stubs, ensure they match the actual firmware API exactly
- Keep stub files synchronized with `vmupro-sdk/sdk/api/` directory

**When Adding New API Stubs:**
1. Copy reference implementation from `vmupro-sdk/sdk/api/[module].lua`
2. Include full LDoc documentation comments (`@brief`, `@param`, `@return`, `@usage`, `@note`)
3. Add stub functions with `end` (no implementation needed)
4. Define all constants and enums
5. Update this AGENTS.md with new file documentation

**API Documentation Format:**
```lua
--- @brief Brief description of function
--- @param param_name Type Description
--- @return Type Description of return value
--- @usage vmupro.module.function(param) -- Example usage
--- @note This is a stub definition for IDE support only.
---       Actual implementation is provided by VMU Pro firmware at runtime.
function vmupro.module.function(param_name) end
```

**Common Patterns:**
- All API functions use `vmupro.[module]` namespace
- Constants use UPPER_SNAKE_CASE naming
- Provide both detailed constants and convenience aliases
- Include `@note` stub disclaimer on all functions

### Synchronization with SDK

The `api/` directory should mirror the relevant portions of `vmupro-sdk/sdk/api/`:
- Only include API modules actually used by the project
- Keep function signatures identical
- Maintain documentation consistency
- Update when SDK version changes

### Testing Requirements

Since these are stub files:
- No runtime testing needed (functions are firmware-provided)
- Verify IDE autocompletion works correctly
- Check that constant values match firmware documentation
- Ensure type annotations are correct for linters

## Dependencies

### External
- VMU Pro SDK (provides reference implementations in `vmupro-sdk/sdk/api/`)
- IDE with Lua language server support (VS Code with Lua LS, NeoVim with Lua LSP, etc.)

### Internal
- Game code (`app.lua`, `app_full.lua`) uses these API definitions for development support
- Synchronized with VMU Pro SDK files in `vmupro-sdk/sdk/api/`

## Related Documentation

- `../vmupro-sdk/docs/api/text.md` - Complete text API documentation
- `../vmupro-sdk/sdk/api/text.lua` - Source reference implementation
- `../README.md` - Project overview and SDK usage
