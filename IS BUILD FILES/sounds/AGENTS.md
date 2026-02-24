# Sounds Directory - Audio Assets

<!-- Parent: ../AGENTS.md -->

> Audio asset library for Inner Sanctum game containing music, combat effects, character sounds, and event audio.

---

## Directory Overview

| Attribute | Value |
|-----------|-------|
| Total Files | 11 |
| Format | WAV (PCM/ADPCM) |
| Sample Rate | 44.1kHz (primary) |

---

## Categories

### Music / Background

| File | Purpose | Notes |
|------|---------|-------|
| `inner_sanctum_44k1_adpcm_stereo.wav` | Main game theme | 44.1kHz ADPCM stereo - primary background music |
| `Intro_45sec.wav` | Intro sequence music | 45-second intro track |
| `intro_source.wav` | Intro source file | Uncompressed source for intro music |

### Combat Sound Effects

| File | Purpose | Notes |
|------|---------|-------|
| `sword_swing_connect.wav` | Sword hit impact | Plays when sword connects with enemy |
| `sword_swoosh.wav` | Sword swing (air) | Plays during sword swing animation |
| `sword_miss.wav` | Sword miss | Plays when attack misses target |

### Character Sound Effects

| File | Purpose | Notes |
|------|---------|-------|
| `yah.wav` | Attack shout | Character vocalization during attack |
| `grunt.wav` | Pain grunt (primary) | Character taking damage |
| `grunt (2).wav` | Pain grunt (variant) | Alternate damage sound for variety |
| `arg_death1.wav` | Death sound | Character death vocalization |

### Event Sound Effects

| File | Purpose | Notes |
|------|---------|-------|
| `win_level.wav` | Level completion | Victory fanfare/sting on level clear |

---

## Usage Notes

- All files are in WAV format for T-Engine compatibility
- `inner_sanctum_44k1_adpcm_stereo.wav` uses ADPCM compression for reduced memory footprint
- Combat sounds are designed for low-latency playback during action sequences
- Multiple grunt variants prevent audio fatigue during gameplay

---

## Related Directories

- `../` - Parent build files directory
- `../../` - Project root

---

*Last updated: 2026-02-23*
