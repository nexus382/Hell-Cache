<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# rules

## Purpose
Code rules, verification standards, and structural requirements for VMU Pro SDK development. Ensures code quality, compatibility, and correctness.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `api/` | API usage rules and standards (see `api/AGENTS.md`) |
| `structure/` | Project structure rules (see `structure/AGENTS.md`) |
| `verification/` | Verification and testing rules (see `verification/AGENTS.md`) |

## For AI Agents

### Working In This Directory

**These are standards documents** - reference when generating or verifying code.

### Rule Categories

**API Rules** (`api/`):
- Correct import syntax (`import "api/..."`)
- Proper function signatures
- Required parameter handling
- Return value conventions

**Structure Rules** (`structure/`):
- Required files (app.lua, metadata.json, icon.bmp)
- Directory organization
- File naming conventions
- Resource placement

**Verification Rules** (`verification/`):
- Code testing requirements
- Validation criteria
- Error handling standards
- Performance benchmarks

### Common Rules

**Critical Requirements**:
1. Entry point: `function AppMain()` returning a number
2. Imports: Use `import "api/system"` NOT `require()`
3. Audio: Call `startListenMode()` before use, `exitListenMode()` after
4. Sprites: Always call `removeAll()` on cleanup
5. Update: Call `vmupro.sound.update()` every frame
6. Input: Call `vmupro.input.read()` once per frame
7. Display: Clear once, draw all, refresh once per frame

**File Organization**:
- Required: `app.lua`, `metadata.json`, `icon.bmp` (76x76)
- Optional: `libraries/`, `pages/`, `assets/`
- NEVER save to project root

**Naming Conventions**:
- Functions: camelCase (`updatePlayer()`)
- Variables: snake_case (`player_x`)
- Constants: UPPER_SNAKE_CASE (`MAX_SPEED`)
- Modules: PascalCase (`Utils`, `Page1`)

### Verification Checklist

Before code is complete:
- [ ] `AppMain()` exists and returns number
- [ ] All imports use `import "api/..."` syntax
- [ ] Audio lifecycle properly managed
- [ ] Sprites cleaned up on exit
- [ ] `vmupro.sound.update()` called every frame
- [ ] `vmupro.input.read()` called once per frame
- [ ] Display: clear once, refresh once per frame
- [ ] No `require()` calls for SDK modules
- [ ] Error handling implemented
- [ ] Memory managed (free resources)

## Dependencies

### Internal
- `../api/` - API documentation referenced by rules
- `../../examples/` - Code following these rules

### External
- Lua style guidelines

<!-- MANUAL: Rule-specific notes can be added below -->
