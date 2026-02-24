<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-23 -->

# sounds/

Audio assets directory for Inner Sanctum game. Contains all sound effects and background music used throughout the gameplay experience.

## Directory Structure

```
sounds/
├── AGENTS.md                              # This documentation
├── Intro_45sec.wav                        # Background music (45 seconds)
├── inner_sanctum_44k1_adpcm_stereo.wav    # Main theme music
├── game-complete.wav                      # Victory/completion sound
├── win_level.wav                          # Level completion sound
├── arg_death1.wav                         # Player death sound
├── grunt.wav                              # Character grunt sound
├── yah.wav                                # Character attack vocal
├── sword_swing_connect.wav                # Sword hit sound
├── sword_miss.wav                         # Sword miss sound
└── sword_swoosh.wav                       # Sword swing sound
```

## Audio Categories

### Background Music

| File | Description | Duration |
|------|-------------|----------|
| `Intro_45sec.wav` | Introduction/looping background music | 45 seconds |
| `inner_sanctum_44k1_adpcm_stereo.wav` | Main game theme (ADPCM compressed stereo) | Full track |

### Combat Sound Effects

| File | Description | Trigger Event |
|------|-------------|---------------|
| `sword_swing_connect.wav` | Sword strike hitting target | Successful melee attack |
| `sword_miss.wav` | Sword swing missing target | Missed attack |
| `sword_swoosh.wav` | Sword swinging through air | Attack initiation |

### Character Vocals

| File | Description | Trigger Event |
|------|-------------|---------------|
| `grunt.wav` | Character grunt | Taking damage / exertion |
| `yah.wav` | Battle cry | Attack vocalization |
| `arg_death1.wav` | Death sound | Player character death |

### Game State Sounds

| File | Description | Trigger Event |
|------|-------------|---------------|
| `game-complete.wav` | Game victory fanfare | Completing the entire game |
| `win_level.wav` | Level completion sound | Finishing a level |

## Technical Specifications

- **Format**: WAV (Waveform Audio)
- **Sample Rate**: 44.1 kHz (indicated by `44k1` in filename)
- **Channels**: Stereo for music, mono for sound effects
- **Compression**: ADPCM used for main theme to reduce file size

## Usage Notes

- All sounds are loaded at game initialization for immediate playback
- Combat sounds should play with minimal latency for responsive gameplay
- Background music loops seamlessly during gameplay
- Sound effects are triggered by game state changes and player actions

## Dependencies

- Loaded by `app_full.lua` during game initialization
- May be referenced by audio management systems in the codebase

## Related Files

- `/mnt/r/inner-santctum/app_full.lua` - Main game logic (sound loading/playback)
