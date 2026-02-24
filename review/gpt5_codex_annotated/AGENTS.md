# GPT-5-Codex Annotated Source Files

<!-- Parent: ../AGENTS.md -->

Source code files annotated with `[GPT-5-Codex]` line prefix for AI analysis attribution tracking.

---

## Purpose

This directory contains source files from the Inner Sanctum project that have been annotated by the GPT-5-Codex model (standard variant). Each line is prefixed with `[GPT-5-Codex]` to:

1. **Track AI-generated analysis** - Identify which model processed each file
2. **Enable diff comparison** - Compare annotations between model variants
3. **Preserve line correspondence** - Maintain original line numbers for cross-referencing with review findings

---

## Files

### Application Entry Point

| File | Description |
|------|-------------|
| `app.lua.annotated.txt` | Bootstrap wrapper that loads `app_full.lua` with pcall error handling and boot logging |

### Core Game Logic

| File | Description |
|------|-------------|
| `app_full.lua.annotated.txt` | Main game engine (436KB) containing raycaster, combat, UI, audio, and game state management |

### SDK API Definitions

| File | Description |
|------|-------------|
| `api__text.lua.annotated.txt` | VMU Pro text rendering API - font constants, `setFont()`, `calcLength()`, `getFontInfo()` stubs |

### Game Data Modules

| File | Description |
|------|-------------|
| `data__classes.lua.annotated.txt` | Playable class definitions (Warrior, Archer, Mage) with base stats, growth curves, and template stats |
| `data__items.lua.annotated.txt` | Item definitions including weapons, armor, consumables, and their stat modifiers |
| `data__loot_tables.lua.annotated.txt` | Loot drop probability tables and item distribution rules |
| `data__achievements.lua.annotated.txt` | Achievement definitions with unlock conditions and metadata |
| `data__persistence.lua.annotated.txt` | Save/load data structures and serialization logic |
| `data__runtime_state.lua.annotated.txt` | Runtime game state variables and transient data structures |
| `data__score_model.lua.annotated.txt` | Scoring system calculations and point value definitions |
| `data__trader_tiers.lua.annotated.txt` | Trader/shop tier progression and inventory definitions |

---

## Annotation Format

```
NNNNN [GPT-5-Codex] <original source line>
```

| Component | Description |
|-----------|-------------|
| `NNNNN` | 5-digit zero-padded line number |
| `[GPT-5-Codex]` | Model attribution tag |
| `<original source line>` | Unmodified source code content |

---

## Related Directories

- **`../gpt5_codex_max_reasoning_annotated_all/`** - Same files annotated with deep reasoning model variant `[GPT-5-CODEX-MAX-REASONING]`
- **`../gpt5_codex_feedback.md`** - Review findings corresponding to this analysis run

---

## Usage

These annotated files serve as reference materials for:

1. **Cross-referencing review findings** - Match line numbers in feedback reports to source code
2. **Model comparison** - Diff against `gpt5_codex_max_reasoning_annotated_all/` to see annotation differences
3. **Audit trail** - Document which model version analyzed which files

---

**Generated:** 2026-02-23
