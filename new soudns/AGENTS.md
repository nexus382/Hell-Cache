<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-23 -->

# New Sounds Directory

Audio assets for the Inner Sanctum game, including music, sound effects, and game event audio.

## Directory Structure

```
new soudns/
  AGENTS.md
  Intro_45sec.wav                    # 992 KB - Main menu/intro music track
  arg_death1.wav                     # 28 KB  - Enemy death sound effect
  game-complete.wav                  # 86 KB  - Game completion victory fanfare
  grunt.wav                          # 9 KB   - Player grunt/exertion sound
  inner_sanctum_44k1_adpcm_stereo.wav # 202 KB - Main theme music (44.1kHz ADPCM stereo)
  sword_swing_connect.wav            # 21 KB  - Sword hit impact sound
  sword_swoosh.wav                   # 9 KB   - Sword swing whoosh sound
  win_level.wav                      # 56 KB  - Level completion jingle
  yah.wav                            # 10 KB  - Player battle cry/attack vocal
```

## Sound Categories

### Music Tracks
| File | Description | Size |
|------|-------------|------|
| `Intro_45sec.wav` | Extended intro/main menu music | ~992 KB |
| `inner_sanctum_44k1_adpcm_stereo.wav` | Main theme, stereo ADPCM format | ~202 KB |

### Combat Sound Effects
| File | Description | Size |
|------|-------------|------|
| `sword_swing_connect.wav` | Sword hitting target | ~21 KB |
| `sword_swoosh.wav` | Sword swing through air | ~9 KB |
| `grunt.wav` | Player exertion sound | ~9 KB |
| `yah.wav` | Player battle cry | ~10 KB |

### Game State Audio
| File | Description | Size |
|------|-------------|------|
| `win_level.wav` | Level completion sound | ~56 KB |
| `game-complete.wav` | Full game victory | ~86 KB |
| `arg_death1.wav` | Enemy death sound | ~28 KB |

## Technical Notes

- All files are in WAV format
- Main theme uses ADPCM compression (44.1kHz stereo)
- Sound effects are optimized for quick loading
- Naming convention: lowercase with underscores

## Usage

These sounds are loaded by the game engine via the audio system. Reference them by filename in game code:

```lua
-- Example sound playback
play_sound("sword_swing_connect.wav")
play_music("inner_sanctum_44k1_adpcm_stereo.wav")
```

## Parent Reference

This directory is a child of the main project:
- See [../AGENTS.md](../AGENTS.md) for project-level documentation
