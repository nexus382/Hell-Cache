<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-17 -->

# sdk/

## Purpose
VMU Pro Lua SDK implementation stubs and type definitions for IDE support. This directory contains Lua files that provide autocomplete, type hints, and documentation for the VMU Pro API during development. The actual runtime implementations are provided by the VMU Pro firmware.

## Key Files

| File | Description |
|------|-------------|
| `api/README.md` | API type definitions documentation explaining IDE support usage |
| `api/__stubs.lua` | Auto-completion stubs for IDE type definitions |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `api/` | Lua API module definitions (system, display, input, audio, sprites, etc.) |

## SDK API Modules (`api/`)

| File | Description |
|------|-------------|
| `__stubs.lua` | Auto-completion stubs for IDE support |
| `system.lua` | System functions: logging (`vmupro.system.log`), timing (`vmupro.system.getTimeUs`, `vmupro.system.delayMs`), memory monitoring |
| `display.lua` | Display functions: clear, drawText, drawLine, drawRect, drawCircle, refresh, color constants |
| `doublebuffer.lua` | Double buffering for flicker-free rendering |
| `text.lua` | Text and font functions: setFont, calcLength, font constants |
| `input.lua` | Button input: read, pressed, held, released (A, B, X, Y, UP, DOWN, LEFT, RIGHT, START, SELECT) |
| `audio.lua` | Audio functions: setGlobalVolume, getGlobalVolume, startListenMode, exitListenMode |
| `synth.lua` | Synthesizer functions: new, setWaveType, setAttack, setDecay, setSustain, setRelease, setVolume, play, free |
| `instrument.lua` | Instrument functions for audio sequencing |
| `sequence.lua` | Audio sequencing functions |
| `file.lua` | File system operations: readFileComplete, writeFileComplete, fileExists, listFiles, createDirectory (restricted to `/sdcard`) |
| `sprites.lua` | Sprite functions: new, draw, drawScaled, setCollision, batch operations |
| `debug.lua` | Debug utilities and helpers |
| `utilities.lua` | Additional utility functions |
| `log.lua` | Logging utilities |
| `mainpage.md` | Main page documentation |

## For AI Agents

### Understanding SDK Stubs

**These files are NOT the runtime implementation.** They are type definition stubs for:

1. **IDE Autocomplete**: Your editor reads these files to provide function signatures and parameter hints
2. **Documentation**: Inline comments describe what each function does
3. **Type Safety**: Helps catch type errors during development

**Runtime Behavior:**
- At packaging time (via `packer.py`), these stub files are **NOT** included in the `.vmupack`
- The VMU Pro firmware provides the actual implementations of all `vmupro.*` functions
- Your scripts call `import "api/module"` during development for IDE hints
- At runtime, the firmware already has these functions built-in

### Import Pattern

```lua
import "api/system"
import "api/display"
import "api/input"

function AppMain()
    vmupro.system.log(vmupro.system.LOG_INFO, "App", "Hello World!")
    vmupro.graphics.clear(vmupro.graphics.BLACK)
    vmupro.graphics.refresh()
    return 0
end
```

### Module Organization

Each `api/*.lua` file defines a namespace under `vmupro`:

| Namespace | Module | Functions |
|-----------|--------|-----------|
| `vmupro.system` | system.lua | log, getTimeUs, delayMs, getMemoryUsage |
| `vmupro.graphics` | display.lua | clear, drawText, drawLine, drawRect, drawCircle, refresh |
| `vmupro.input` | input.lua | read, pressed, held, released |
| `vmupro.audio` | audio.lua | setGlobalVolume, getGlobalVolume, startListenMode, exitListenMode |
| `vmupro.sound.synth` | synth.lua | new, setWaveType, setAttack, setDecay, setSustain, setRelease, play, free |
| `vmupro.sound.instrument` | instrument.lua | Instrument operations |
| `vmupro.sound.sequence` | sequence.lua | Sequencer operations |
| `vmupro.file` | file.lua | readFileComplete, writeFileComplete, fileExists, listFiles, createDirectory |
| `vmupro.sprite` | sprites.lua | new, draw, drawScaled, setCollision, batch operations |
| `vmupro.text` | text.lua | setFont, calcLength, font constants |

### When Working with SDK Files

**DO:**
- Read these files to understand function signatures
- Use them as reference for available APIs
- Include `import "api/module"` statements in your scripts

**DON'T:**
- Modify these files (they are part of the SDK)
- Expect these implementations to run at runtime
- Include custom code in these stub files
- Assume these files are packaged into `.vmupack`

### See Also

- Parent SDK documentation: `../AGENTS.md`
- Complete API reference: `../docs/api/`
- Getting started guide: `../docs/getting-started.md`
