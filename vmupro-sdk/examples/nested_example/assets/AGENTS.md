# Assets Directory

<!-- Parent: ../AGENTS.md -->

Audio samples, MIDI files, and image assets for the nested_example demo.

## Directory Structure

```
assets/
  AGENTS.md
  *.wav      # Audio samples (10 files)
  *.mid      # MIDI sequences (1 file)
  *.png      # Sprite images (2 files)
  *.bmp      # Legacy sprite format (1 file)
```

## Asset Inventory

### Audio Samples (WAV)

| File | Size | Description |
|------|------|-------------|
| `clarinet.wav` | 253 KB | Woodwind instrument sample |
| `crash_cymbal.wav` | 153 KB | Percussion - crash cymbal hit |
| `french_horns.wav` | 107 KB | Brass section sample |
| `game-complete.wav` | 154 KB | Victory/completion sound effect |
| `player-losing-or-failing.wav` | 518 KB | Defeat/failure sound effect |
| `ride_cymbal.wav` | 181 KB | Percussion - ride cymbal |
| `string_ensemble.wav` | 177 KB | Orchestral strings sample |
| `timpani.wav` | 139 KB | Percussion - timpani drum |
| `winning-a-coin.wav` | 177 KB | Pickup/achievement sound effect |

### MIDI Sequences

| File | Size | Description |
|------|------|-------------|
| `settlers.mid` | 5 KB | Background music sequence |

### Sprites and Images

| File | Size | Format | Description |
|------|------|--------|-------------|
| `mask_guy-table-32-32.png` | 2 KB | PNG | 32x32 sprite sheet or tile |
| `mask_guy_idle.png` | 2 KB | PNG | Character idle animation sprite |
| `mask_guy_idle_old.bmp` | 2 KB | BMP | Legacy format idle sprite (deprecated) |

## Usage Notes

- Audio files are in WAV format for broad compatibility
- PNG sprites should be preferred over BMP for new assets
- The `mask_guy` prefix suggests these sprites belong to a character set
- MIDI file provides background music via sequencer playback

## Related Files

- `/mnt/r/inner-santctum/vmupro-sdk/examples/nested_example/assets/` - This directory
- Parent documentation: `../AGENTS.md`

---
*Generated: 2026-02-23*
