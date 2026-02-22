# Nested Example Assets - AGENTS.md

<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-17 -->

## Purpose

This directory contains all game assets for the Nested Example application, including audio files, sprites, and graphical resources used across the 39 test pages. These assets demonstrate the VMU Pro SDK's capabilities for handling different media formats and resources within the application.

## Key Files

| File | Purpose | Type | Size |
|------|---------|------|------|
| `clarinet.wav` | Audio test file for music playback | Audio | 252KB |
| `crash_cymbal.wav` | Sound effect test file | Audio | 153KB |
| `french_horns.wav` | Music track test file | Audio | 107KB |
| `game-complete.wav` | Victory/end game sound effect | Audio | 154KB |
| `mask_guy-table-32-32.png` | Sprite table image for character animation | Sprite | 1.5KB |
| `mask_guy_idle.png` | Character idle sprite | Sprite | 2.2KB |
| `mask_guy_idle_old.bmp` | Legacy character sprite (BMP format) | Sprite | 2.1KB |
| `player-losing-or-failing.wav` | Game over/failure sound effect | Audio | 517KB |
| `ride_cymbal.wav` | Percussion sound effect | Audio | 181KB |
| `settlers.mid` | MIDI music file for background music | Audio | 5.5KB |
| `string_ensemble.wav` | String instrument track | Audio | 177KB |
| `timpani.wav` | Percussion instrument sound | Audio | 139KB |
| `winning-a-coin.wav` | Victory/coin collection sound | Audio | 177KB |

## Asset Types

### Audio Assets
- **WAV Files**: Standard audio format for sound effects and music
- **MIDI File**: `settlers.mid` - Musical Instrument Digital Interface format for background music
- **Usage**: Test pages 16-18 demonstrate audio playback, synth operations, and instrument usage

### Sprite Assets
- **PNG Files**: Modern sprite format with transparency support
- **BMP Files**: Legacy bitmap format for compatibility testing
- **Sprite Sheet**: `mask_guy-table-32-32.png` - Character sprite sheet for animation
- **Idle Sprite**: `mask_guy_idle.png` - Character idle animation frame
- **Usage**: Test pages 9-12 demonstrate sprite rendering and animation capabilities

## Audio Test Coverage

The audio assets are specifically organized to test different SDK audio features:

- **Sound Effects**: `crash_cymbal.wav`, `winning-a-coin.wav`, `player-losing-or-failing.wav`
- **Music Tracks**: `clarinet.wav`, `french_horns.wav`, `string_ensemble.wav`
- **Percussion**: `timpani.wav`, `ride_cymbal.wav`, `crash_cymbal.wav`
- **Special Effects**: `game-complete.wav` (victory sound)

## File Format Support

This asset collection demonstrates the VMU Pro SDK's support for:
- **Audio**: WAV (PCM), MIDI (musical score)
- **Graphics**: PNG (compressed with alpha), BMP (uncompressed)
- **Animation**: Sprite sheets for character animation
- **Legacy Formats**: BMP compatibility for older assets

## Dependencies

All assets are referenced by the test pages in the `pages/` directory and must remain in this location for proper loading.