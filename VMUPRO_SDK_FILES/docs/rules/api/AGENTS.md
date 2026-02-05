<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# api

## Purpose
API usage rules and standards for correct VMU Pro SDK module usage.

## For AI Agents

### Working In This Directory

**These are API rule documents** - reference for verifying correct SDK usage.

### Common API Rules

**Import Syntax**:
- ✅ `import "api/system"`
- ❌ `require("api/system")` - NOT supported

**Audio Lifecycle**:
```lua
-- Correct
vmupro.audio.startListenMode()
-- Use audio
vmupro.audio.exitListenMode()

-- Incorrect
-- Forgetting to call exitListenMode()
```

**Sprite Cleanup**:
```lua
-- Correct
function pageExit()
    vmupro.sprite.removeAll()
    -- Free individual sprites if needed
end

-- Incorrect
-- Forgetting to clean up sprites
```

**Frame Loop Order**:
1. `vmupro.input.read()` - Once, at start
2. Handle input
3. `vmupro.graphics.clear()` - Once
4. Draw everything
5. `vmupro.graphics.refresh()` - Once
6. `vmupro.sound.update()` - If using audio
7. `vmupro.system.delayMs(16)` - ~60 FPS

### Verification Checklist

- [ ] All imports use `import "api/..."` syntax
- [ ] `AppMain()` exists and returns number
- [ ] Audio lifecycle properly managed
- [ ] Sprites cleaned up on exit
- [ ] `vmupro.sound.update()` called every frame (if using audio)
- [ ] `vmupro.input.read()` called once per frame
- [ ] Display cleared once, refreshed once per frame

## Dependencies

### Internal
- `../../api/` - API reference documentation
- `../../../CLAUDE.md` - Complete verified reference

<!-- MANUAL: API rule notes can be added below -->
