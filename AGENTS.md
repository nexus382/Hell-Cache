<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# inner-santctum

## Purpose
A 3D dungeon raycaster game for VMU Pro SDK featuring boomer wave shooter gameplay with castle dungeon environments and detailed sprite-based characters.

## Key Files

| File | Description |
|------|-------------|
| `app.lua` | Main game code - raycaster engine, AI, combat, UI |
| `metadata.json` | VMU Pro package metadata and configuration |
| `metadata_level1.json` | Level 1 specific metadata |
| `metadata_level2.json` | Level 2 specific metadata |
| `README.md` | Project overview and technical documentation |
| `SPRITE_PIPELINE.md` | Sprite generation pipeline documentation |
| `icon.bmp` | 76x76 application icon |
| `.gitignore` | Git ignore patterns |

## Python Scripts

| File | Description |
|------|-------------|
| `generate_sprites.py` | Sprite generation utility |
| `fix_sprites.py` | Sprite correction/fixing script |
| `process_warrior_actions.py` | Process warrior action sprites |
| `split_knight.py` | Split knight spritesheet |
| `split_spritesheet.py` | General spritesheet splitting utility |
| `split_warrior_actions.py` | Split warrior action spritesheets |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `VMUPRO_SDK_FILES/` | Complete VMU Pro SDK documentation and examples (see `VMUPRO_SDK_FILES/AGENTS.md`) |
| `sprites/` | Game sprite assets - characters, walls, UI (see `sprites/AGENTS.md`) |
| `sounds/` | Audio files - music and sound effects (see `sounds/AGENTS.md`) |
| `tools/` | Development and build tools (see `tools/AGENTS.md`) |
| `gemini_package/` | AI sprite generation references (see `gemini_package/AGENTS.md`) |
| `.vscode/` | VS Code configuration |

## For AI Agents

### Working In This Directory

**Critical VMU Pro SDK Constraints:**
- Display: 240x240 pixels, RGB565 little-endian color format
- **CRASH BUG**: `math.atan2()` causes crashes - use `safeAtan2()` implementation instead
- **CRASH BUG**: `math.random()` can crash - use deterministic alternatives: `(frameCount * multiplier) % range`
- **CRASH BUG**: Sample-based audio crashes - use synth audio only
- All sprites normalized to ~517px height for consistent scaling
- Ground positioning: `drawY = groundY - scaledHeight` (feet on ground, not eye-level)

**Custom Safe Functions:**
```lua
local function safeAtan2(y, x)
    if x == 0 then
        if y > 0 then return 1.5708
        elseif y < 0 then return -1.5708
        else return 0 end
    end
    local angle = math.atan(y / x)
    if x < 0 then angle = angle + 3.14159 end
    return angle
end
```

**Audio Setup (Synth-based):**
```lua
vmupro.audio.startListenMode()
local synth = vmupro.sound.synth.new(vmupro.sound.kWaveNoise)
vmupro.sound.synth.setAttack(synth, 0.01)
vmupro.sound.synth.setDecay(synth, 0.1)
vmupro.sound.synth.setSustain(synth, 0.2)
vmupro.sound.synth.setRelease(synth, 0.1)
vmupro.sound.synth.setVolume(synth, 0.5, 0.5)
-- Cleanup: vmupro.sound.synth.free(synth), vmupro.audio.exitListenMode()
```

**Sprite Handling:**
- Check `animFrame ~= nil` (not `animFrame > 0` since 0 is valid frame)
- All warrior sprites: ~517px height
- All knight sprites: ~579px height
- Use `vmupro.sprite.new()`, `vmupro.sprite.draw()`, `vmupro.sprite.drawScaled()`

### Common Patterns

**Color Constants (RGB565 Little-Endian):**
```lua
COLOR_BLACK = 0x0000
COLOR_WHITE = 0xFFFF
COLOR_RED = 0x00F8
COLOR_GREEN = 0xE007
COLOR_BLUE = 0x1F00
-- See app.lua for full list
```

**Game Features Implemented:**
- 3D raycaster with textured walls
- Player movement and collision detection
- Soldier enemies with patrol/chase/attack AI (3x sprint when chasing)
- Combat system: 20 damage per swing, 1 unit attack range
- Health system with Diablo 2-style potion UI
- Health vial pickups (5 per level)
- Death effects (blood particles, sounds)
- Title/pause/options/game over screens
- Win condition (kill all 5 soldiers)

### Known Issues

- One soldier may appear invisible (walking sprite loading issue)
- Knights removed (sprites not ready)

### Testing Requirements

Test on VMU Pro hardware:
- Verify all math.atan2() calls replaced with safeAtan2()
- Verify math.random() replaced with deterministic alternatives
- Check sprite scaling and positioning
- Test audio with synth-based sounds only
- Verify combat AI and collision detection

### Building

Use VMU Pro SDK packer:
```bash
python "tools/packer/packer.py" \
    --projectdir "/path/to/inner-santctum" \
    --appname inner_sanctum \
    --meta metadata.json \
    --icon icon.bmp
```

Output: `inner_sanctum.vmupack` → copy to SD card `D:\apps\`

## Dependencies

### External
- VMU Pro SDK (Lua-based game development platform)
- Python 3.x (for sprite processing scripts)
- PIL/Pillow (Python image library)

### Game Code
- Uses VMU Pro API modules: system, display, input, sprites, audio

## Asset Pipeline

**Sprites:**
1. Generate base sprites via AI (see `SPRITE_PIPELINE.md`)
2. Process with Python scripts (`split_*.py`, `generate_sprites.py`)
3. Normalize to consistent heights (warrior: 517px, knight: 579px)
4. Organize in `sprites/` by level and type

**Audio:**
- Use synth-based audio generation (no sample playback)
- Store reference files in `sounds/` for documentation

<!-- MANUAL: Custom project notes can be added below -->

## Manual Project Note: Build + Changelog Discipline

- For every code change, increment `BUILD_COUNT` in `app_full.lua`.
- For every code change, update `CHANGE_LOG.html`.
- Keep changelog sections grouped in 5-build ranges (for example: `136-140`, `141-145`).
- On every 10th build slot (140, 150, 160...), include:
  - normal build entry, and
  - "Summary of last 10 changes" entry.
