# Temporary Analysis Files

<!-- Parent: ../AGENTS.md -->

**Last Updated:** 2026-02-23

This directory contains temporary analysis output files generated during code review and asset auditing processes.

## Directory Contents

| File | Description | Content Summary |
|------|-------------|-----------------|
| `code_sounds.txt` | Sound references found in code analysis | 1 entry: `sounds/sword_swoosh` |
| `meta_l1_sounds_noext.txt` | Level 1 meta sound references (no extension) | 1 entry: `sounds/sword_swoosh` |
| `meta_l2_sounds_noext.txt` | Level 2 meta sound references (no extension) | 8 entries: intro, death, grunt, theme music, sword sounds, win, yah |

## File Details

### code_sounds.txt
Sound asset references extracted directly from source code analysis.
- Single reference to `sounds/sword_swoosh`

### meta_l1_sounds_noext.txt
First-level metadata sound references without file extensions.
- Single reference to `sounds/sword_swoosh`

### meta_l2_sounds_noext.txt
Second-level metadata sound references without file extensions.
Contains 8 sound references:
- `sounds/Intro_45sec` - Introduction music
- `sounds/arg_death1` - Death sound effect
- `sounds/grunt` - Grunt sound effect
- `sounds/inner_sanctum_44k1_adpcm_stereo` - Main theme music
- `sounds/sword_miss` - Sword miss sound
- `sounds/sword_swing_connect` - Sword hit sound
- `sounds/win_level` - Level victory sound
- `sounds/yah` - Vocal sound effect

## Purpose

These files serve as intermediate analysis outputs for:
1. Comparing code-referenced assets vs. metadata-referenced assets
2. Identifying missing or unused sound assets
3. Cross-referencing between game code and resource metadata

## Notes

- All paths are relative to the game's asset root
- Files contain paths without extensions for cross-format matching
- These are temporary working files and may be regenerated during analysis passes
