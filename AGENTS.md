# Inner Sanctum - AGENTS.md

**Generated:** 2026-02-23

---

## Purpose

Inner Sanctum is a doom-like 3D dungeon raycaster game for the VMU Pro handheld device. It is a wave shooter / dungeon crawler where the player protects a king from hordes of enemies who have broken into his inner sanctum.

**Key Characteristics:**
- **Platform:** VMU Pro (240x240 display, RGB565 color)
- **Genre:** Boomer wave shooter / dungeon crawler
- **Engine:** Custom raycasting renderer with textured walls
- **Language:** Lua (VMU Pro Lua environment)

---

## Key Files

| File | Purpose |
|------|---------|
| `app.lua` | Boot wrapper that imports `app_full.lua` with error handling |
| `app_full.lua` | **Main game code** (~380KB) - contains all game logic, rendering, AI, and systems |
| `metadata.json` | VMU Pro package metadata, resource manifest, and app configuration |
| `metadata_level1.json` | Level 1 specific metadata for split packages |
| `metadata_level2.json` | Level 2 specific metadata for split packages |
| `icon.bmp` | 76x76 app icon for VMU Pro menu |
| `README.md` | Project documentation and lessons learned |
| `fix_sprites.py` | Python script for sprite normalization |
| `generate_sprites.py` | Python script for sprite generation |

### Build Artifacts (.vmupack files)
| File | Purpose |
|------|---------|
| `inner_sanctum.vmupack` | Full game package (~2.1MB) |
| `inner_sanctum_l1.vmupack` | Level 1 standalone package |
| `inner_sanctum_l2.vmupack` | Level 2 standalone package |
| `innersantctum.vmupack` | Latest build |

### Planning/Design Documents
| File | Purpose |
|------|---------|
| `DOOM_PERFORMANCE_OPTIMIZATION_PLAN.md` | Performance optimization strategy |
| `DOOM_PERFORMANCE_SYSTEMS_PLAN.md` | Systems-level performance planning + build-tracked implementation status snapshot |
| `DOOM_vs_INNERSANCTUM_ANALYSIS.md` | Comparative analysis with Doom |
| `PERFORMANCE_AUDIT_REPORT.md` | Performance audit findings |
| `MAGE_SPELL_DESIGN.md` | Mage spell system design |
| `WEAPON_CLASS_MASTERY_PLAN.md` | Weapon mastery progression |
| `STATS_TO_GAMEPLAY.md` | Stats to gameplay mechanics mapping |

---

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `api/` | Custom API modules (system, display, text, input) for VMU Pro |
| `data/` | Game data files (maps, configurations) |
| `sounds/` | Audio files (WAV) for game sounds and music |
| `sprites/` | All game sprites organized by level and type |
| `tools/` | Development and build tools |
| `vmupro-sdk/` | Official VMU Pro SDK (examples, documentation, SDK APIs) |
| `IS BUILD FILES/` | Build artifacts and intermediate files |
| `NEW-bmp-textures/` | New BMP format wall textures |
| `new soudns/` | Additional sound files (typo in original) |
| `gemini_package/` | Gemini-specific packaging files |
| `review/` | Review and testing materials |
| `vmupacker_debug/` | Debug builds from packer tool |

---

## For AI Agents

### Working With This Codebase

1. **Entry Point:** All game logic is in `app_full.lua`. The `app.lua` file is a thin wrapper.

2. **VMU Pro Quirks (CRITICAL):**
   - `math.atan2()` **crashes** - always use `safeAtan2()` implementation
   - `math.random()` **can crash** - use deterministic alternatives like `(frameCount * multiplier) % range`
   - Sample-based audio crashes - use `vmupro.sound.synth.*` API only
   - Sprite slot limit is 64 - loading too many sprites crashes

3. **Color Format:** RGB565 little-endian. Define all COLOR_* constants or game crashes.

4. **Performance Considerations:**
   - Column-slice wall textures are CPU-heavy; prefer full 128x128 textures
   - Double buffering can be toggled via `DEBUG_DOUBLE_BUFFER`
   - Performance monitoring variables prefixed with `PERF_MONITOR_*`
   - Visibility-cap (VIS) culling controls were removed in Build 176; use draw distance, mip distances, and fog ranges for runtime tuning
   - Sprite order cache now rebuilds in place (Build 177) to reduce per-refresh allocations in the sprite render ordering path
   - Mip thresholds now support per-tier OFF (0) and independent tuning (Build 178); distance presets use 0.5 steps below 12 and 1.0 steps at 12+
   - Expansion M1 scaffolding started in Build 179: `dispatchRunScoreEvent` now drives run score hooks (kills/pickups/level start-clear), and HUD score counters are live in gameplay for validation

5. **Code Style:**
   - Lua imports use `import "module"` syntax
   - VMU Pro API accessed via `vmupro.*` namespace
   - Enable logs with `enableBootLogs` and `enablePerfLogs` flags

### AGENTS Sync Discipline

When making edits, keep `AGENTS.md` files current to reduce rediscovery cost in future sessions:

1. Update the nearest `AGENTS.md` in each touched directory with any new systems, tunables, or workflow changes.
2. Update root `AGENTS.md` when project-wide behavior, architecture, or debugging flows change.
3. Keep entries short and factual (what changed, where, and why it matters).
4. Do this in the same pass as code changes so docs and implementation do not drift.

### Common Tasks

**Adding a new sprite:**
1. Add PNG to appropriate `sprites/` subdirectory
2. Update `metadata.json` resources array
3. Load with `vmupro.sprite.new()` in game code
4. Respect 64 sprite slot limit

**Modifying game behavior:**
1. All logic is in `app_full.lua`
2. Search for state machine patterns (title, playing, paused, gameover)
3. Game loop runs in `AppMain()` function

**Building:**
```bash
python tools/packer/packer.py \
    --projectdir /mnt/r/inner-santctum \
    --appname inner_sanctum \
    --meta metadata.json \
    --icon icon.bmp
```

### Key Code Sections in app_full.lua

| Section | Description |
|---------|-------------|
| Lines 1-100 | Debug flags and performance monitoring variables |
| Performance monitoring | `PERF_MONITOR_*` variables for profiling |
| Double buffering | `DEBUG_DOUBLE_BUFFER` and related functions |
| Raycaster | Wall rendering with texture mapping |
| Entity system | Enemies, player, AI states |
| UI system | Menus, HUD, health bars |

---

## Dependencies

### Runtime
- **VMU Pro** handheld device or emulator
- VMU Pro firmware with Lua environment

### Build Tools
- **Python 3.x** - for packer tool and sprite scripts
- **VMU Pro SDK** - included in `vmupro-sdk/` directory
- **packer.py** - creates .vmupack files from project

### Sprite/Asset Pipeline
- PNG format for sprites
- BMP format for app icon (76x76)
- WAV format for sounds (but use synth API at runtime)

---

## Architecture Overview

```
+------------------+
|     app.lua      |  <- Boot wrapper
+--------+---------+
         |
         v
+------------------+
|   app_full.lua   |  <- Main game (380KB monolith)
+--------+---------+
         |
    +----+----+----+----+
    |    |    |    |    |
    v    v    v    v    v
+------+ +-----+ +------+
| api/ | |data/| |vmupro|
+------+ +-----+ +------+
    |                 |
    +----> VMU Pro SDK APIs
```

**Game States:** TITLE -> PLAYING -> PAUSED -> GAME_OVER / WIN_SCREEN

---

## See Also

- `README.md` - Detailed lessons learned and troubleshooting
- `vmupro-sdk/docs/` - Official SDK documentation
- `sprites/AGENTS.md` - Sprite organization details
- `api/AGENTS.md` - Custom API module documentation
