<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# docs

## Purpose
Complete VMU Pro SDK documentation including API references, programming guides, tool documentation, and rules/verification standards.

## Key Files

| File | Description |
|------|-------------|
| `SUMMARY.md` | Documentation index and quick navigation |
| `getting-started.md` | SDK introduction and setup guide |
| `LICENSE.md` | SDK license terms |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `api/` | Complete API reference for all SDK modules (see `api/AGENTS.md`) |
| `examples/` | Example code and tutorials (see `examples/AGENTS.md`) |
| `guides/` | Programming guides and best practices (see `guides/AGENTS.md`) |
| `rules/` | Code rules and verification standards (see `rules/AGENTS.md`) |
| `tools/` | Build and deployment tool documentation (see `tools/AGENTS.md`) |

## For AI Agents

### Working In This Directory

**This is reference documentation** - DO NOT modify.

**When Reading SDK Docs**:
1. Start with `SUMMARY.md` for navigation
2. Check `getting-started.md` for setup
3. Refer to `api/` for detailed API reference
4. Consult `guides/` for best practices

**Primary Reference for AI**:
- `../CLAUDE.md` - Complete, verified API reference optimized for AI use
- All information in CLAUDE.md is 100% verified against these docs

### Documentation Structure

**API Documentation** (`api/`):
- Module-by-module reference
- Function signatures and parameters
- Usage examples
- Return values and error handling

**Guides** (`guides/`):
- Getting started tutorials
- Feature-specific guides
- Performance optimization
- Common patterns

**Examples** (`examples/`):
- Minimal working code
- Feature demonstrations
- Best practices in action

**Rules** (`rules/`):
- Code standards and conventions
- Verification requirements
- API usage rules
- Structure requirements

**Tools** (`tools/`):
- Packer documentation
- Build system reference
- Deployment instructions

### Quick Reference

**Display Specs**:
- Resolution: 240x240 pixels
- Color format: RGB565 (16-bit)
- Target FPS: 60 FPS

**Critical Requirements**:
- Entry point: `function AppMain()` returning a number
- Import syntax: `import "api/system"` NOT `require()`
- Audio: Use `startListenMode()` / `exitListenMode()`
- Sprite cleanup: Always call `vmupro.sprite.removeAll()`
- Update: Call `vmupro.sound.update()` every frame

### Common Patterns

**App Structure**:
```lua
import "api/system"
import "api/display"
import "api/input"

function AppMain()
    -- Initialization
    vmupro.audio.startListenMode()

    local running = true
    while running do
        vmupro.input.read()

        if vmupro.input.pressed(vmupro.input.B) then
            running = false
        end

        vmupro.graphics.clear(vmupro.graphics.BLACK)
        -- Draw content
        vmupro.graphics.refresh()

        vmupro.sound.update()
        vmupro.system.delayMs(16)
    end

    vmupro.audio.exitListenMode()
    return 0
end
```

## Dependencies

### Internal
- `../CLAUDE.md` - AI-optimized API reference (verified accurate)
- `../examples/` - Working code examples
- `../sdk/` - SDK implementation
- `../tools/` - Build tools

### External
- Lua 5.x documentation
- VMU Pro hardware specs

<!-- MANUAL: Documentation-specific notes can be added below -->
