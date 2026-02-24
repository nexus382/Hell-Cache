# VMU Pro SDK Documentation - AGENTS.md

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

This directory contains the official documentation for the VMU Pro Lua SDK. It provides comprehensive guides, API references, examples, and tooling documentation for developers creating applications on the VMU Pro handheld platform.

**Key Characteristics:**
- **Format:** Markdown files organized for GitBook publishing
- **Audience:** Lua developers building VMU Pro applications
- **Coverage:** Complete API reference, tutorials, and development tools

---

## Key Files

| File | Purpose |
|------|---------|
| `README.md` | Documentation landing page with SDK overview and quick start |
| `SUMMARY.md` | GitBook table of contents / navigation structure |
| `getting-started.md` | Development environment setup and first application tutorial |
| `lua-sdk-overview.md` | Comprehensive SDK capabilities and concepts overview |
| `book.json` | GitBook configuration file |

---

## Subdirectories

| Directory | Purpose | File Count |
|-----------|---------|------------|
| `api/` | API Reference - Complete documentation for all SDK modules | 11 files |
| `guides/` | Tutorials - Step-by-step guides for common development tasks | 4 files |
| `examples/` | Code Examples - Annotated sample applications | 1 file |
| `tools/` | Tooling Docs - Documentation for packer and development tools | 2 files |

---

## API Reference (`api/`)

Complete documentation for all VMU Pro Lua API modules.

| File | Module | Description | Size |
|------|--------|-------------|------|
| `display.md` | Graphics | Drawing primitives, text, colors, display management | ~10KB |
| `sprites.md` | Sprites | Sprite system, animation, collision detection, effects | ~119KB |
| `doublebuffer.md` | Double Buffer | Smooth rendering without flicker | ~10KB |
| `input.md` | Input | Button reading and event handling | ~5KB |
| `audio.md` | Audio | Volume control, sample playback, streaming | ~15KB |
| `synth.md` | Synthesizer | Real-time audio synthesis, waveforms, ADSR | ~12KB |
| `instrument.md` | Instruments | Sample-based instruments, voice mapping | ~5KB |
| `sequence.md` | MIDI Sequences | MIDI file playback, track management | ~11KB |
| `file.md` | File System | File I/O operations (restricted to /sdcard) | ~6KB |
| `system.md` | System | Timing, logging, brightness, memory utilities | ~9KB |
| `debug.md` | Debug | Debugging utilities | ~2KB |

### API Documentation Pattern

Each API file follows this structure:
1. **Overview** - Module purpose and capabilities
2. **Constants** - Predefined values (colors, button codes, etc.)
3. **Functions** - Detailed function signatures with parameters and return values
4. **Examples** - Code snippets demonstrating usage

---

## Guides (`guides/`)

Step-by-step tutorials for VMU Pro development.

| File | Topic | Description |
|------|-------|-------------|
| `first-app.md` | First Application | Creating your first VMU Pro app from scratch |
| `graphics-guide.md` | Graphics Programming | Display rendering, drawing, and visual effects |
| `audio-guide.md` | Audio Programming | Sound playback, synthesis, and music sequencing |
| `file-operations.md` | File Operations | Reading/writing files, managing save data |

---

## Examples (`examples/`)

Annotated sample applications demonstrating SDK patterns.

| File | Example | Description |
|------|---------|-------------|
| `hello-world.md` | Hello World | Minimal application with display, input, and main loop |

---

## Tools (`tools/`)

Documentation for SDK tooling.

| File | Tool | Description |
|------|------|-------------|
| `packer.md` | Packer Tool | Packaging Lua apps into .vmupack format |
| `development.md` | Development Setup | IDE configuration, workflow, and best practices |

---

## For AI Agents

### Working With This Documentation

1. **API Reference is in `api/`** - Each module has its own markdown file with complete function documentation.

2. **Guides are in `guides/`** - Tutorial content for learning specific features.

3. **Getting Started** - `getting-started.md` is the entry point for new developers.

4. **Navigation** - `SUMMARY.md` defines the GitBook table of contents.

### Common Tasks

**Finding API function documentation:**
```
api/display.md   -> vmupro.graphics.* functions
api/sprites.md   -> vmupro.sprite.* functions
api/input.md     -> vmupro.input.* functions
api/audio.md     -> vmupro.audio.* functions
api/system.md    -> vmupro.system.* functions
```

**Understanding code patterns:**
- `examples/hello-world.md` - Basic application structure
- `guides/first-app.md` - Step-by-step app creation

**Development workflow:**
- `tools/packer.md` - Packaging applications
- `tools/development.md` - IDE setup and workflow

### Documentation Update Guidelines

When updating documentation:

1. **Update SUMMARY.md** if adding new pages or reorganizing structure
2. **Match existing formatting** - Use consistent markdown patterns
3. **Include code examples** - All API functions should have usage examples
4. **Cross-reference** - Link related documentation where appropriate
5. **Keep sizes reasonable** - The sprites.md file is large (~119KB) but contains comprehensive collision detection docs

### API Function Documentation Pattern

```markdown
### functionName

Description of what the function does.

**Signature:**
```lua
result = vmupro.module.functionName(param1, param2)
```

**Parameters:**
- `param1` (type): Description
- `param2` (type): Description

**Returns:**
- `result` (type): Description

**Example:**
```lua
local value = vmupro.module.functionName("example", 42)
```
```

---

## Documentation Structure Diagram

```
docs/
|-- README.md              # Landing page
|-- SUMMARY.md             # Navigation (GitBook)
|-- getting-started.md     # Setup & first app
|-- lua-sdk-overview.md    # SDK concepts
|-- book.json              # GitBook config
|
|-- api/                   # API Reference (11 modules)
|   |-- display.md         # Graphics API
|   |-- sprites.md         # Sprite system (largest)
|   |-- doublebuffer.md    # Double buffering
|   |-- input.md           # Input handling
|   |-- audio.md           # Audio playback
|   |-- synth.md           # Synthesizer
|   |-- instrument.md      # Instruments
|   |-- sequence.md        # MIDI sequences
|   |-- file.md            # File I/O
|   |-- system.md          # System utilities
|   |-- debug.md           # Debug tools
|
|-- guides/                # Tutorials (4 guides)
|   |-- first-app.md       # Your first app
|   |-- graphics-guide.md  # Graphics tutorial
|   |-- audio-guide.md     # Audio tutorial
|   |-- file-operations.md # File I/O tutorial
|
|-- examples/              # Sample apps
|   |-- hello-world.md     # Hello World example
|
|-- tools/                 # Tool documentation
    |-- packer.md          # Packaging tool
    |-- development.md     # Dev workflow
```

---

## Related Files

| File | Relationship |
|------|--------------|
| `../AGENTS.md` | Parent SDK AGENTS.md with full project context |
| `../sdk/api/*.lua` | Source API stub files that this documentation describes |
| `../examples/` | Working example applications referenced in docs |

---

## See Also

- `../AGENTS.md` - Parent SDK context and architecture
- `../README.md` - Main SDK documentation
- `../sdk/AGENTS.md` - SDK API stubs documentation
