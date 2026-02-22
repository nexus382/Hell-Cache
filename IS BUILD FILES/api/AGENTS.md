<!-- Parent: ../AGENTS.md -->
# AGENTS.md for /IS BUILD FILES/api/

**Generated:** 2026-02-17

## Purpose

This directory contains API stub files for the VMU Pro build pipeline. These stub definitions provide IDE support and type information for Lua SDK functions, with actual implementations provided by the VMU Pro firmware at runtime.

## Key Files

| Filename | Type | Purpose | Status |
|----------|------|---------|--------|
| `text.lua` | API Stub | Text and font rendering functions for VMU Pro applications | Complete |
| | | | |

## API Stubs

### Text API (`text.lua`)
The text.lua file provides stub definitions for text rendering and font management functions:

- **Namespace**: `vmupro.text`
- **Functions**:
  - `setFont(font_id)` - Set current font for text rendering
  - `calcLength(text)` - Calculate pixel width of text
  - `getFontInfo()` - Get current font information
- **Font Constants**: 12 font variants from tiny (6x8px) to extra large (32x37px)
- **Convenience Aliases**: `FONT_SMALL`, `FONT_MEDIUM`, `FONT_LARGE`, `FONT_DEFAULT`

## Build Pipeline Integration

These API stubs are integrated into the build system to provide:
- Type checking during development
- IDE autocomplete support
- Documentation generation
- Runtime compatibility validation