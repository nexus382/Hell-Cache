<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# sounds

## Purpose
Audio assets for the game. **Note: Due to VMU Pro crash bugs with sample-based audio, this directory primarily serves as reference. The game uses synth-based audio instead.**

## Key Files

| File | Description | Usage Status |
|------|-------------|--------------|
| `Intro_45sec.wav` | 45-second intro music track | ⚠️ Not used (sample audio crashes) |
| `sword_swoosh.wav` | Sword swoosh sound effect | ⚠️ Reference only (synth used instead) |

## For AI Agents

### Working In This Directory

**CRITICAL: VMU Pro Audio Constraints**
- **Sample-based audio crashes the VMU Pro** - DO NOT use `vmupro.sound.sample.*`
- **Use synth-based audio only** - `vmupro.sound.synth.*`
- Files in this directory are kept for reference only

**Why Samples Crash**:
The VMU Pro has known issues with sample-based audio playback that can cause system crashes. Always use the synthesizer audio system instead.

### Synth Audio Pattern

**Setup** (from `../app.lua`):
```lua
vmupro.audio.startListenMode()
local synth = vmupro.sound.synth.new(vmupro.sound.kWaveNoise)
vmupro.sound.synth.setAttack(synth, 0.01)
vmupro.sound.synth.setDecay(synth, 0.1)
vmupro.sound.synth.setSustain(synth, 0.2)
vmupro.sound.synth.setRelease(synth, 0.1)
vmupro.sound.synth.setVolume(synth, 0.5, 0.5)
```

**Playing Sounds**:
```lua
-- Sword swoosh
vmupro.sound.synth.playNote(synth, 440, 0.5, 0.1)

-- Impact/hit
vmupro.sound.synth.playNote(synth, 150, 0.7, 0.05)

-- Death groan
vmupro.sound.synth.playNote(synth, 80, 0.6, 0.3)
```

**Wave Types**:
- `vmupro.sound.kWaveNoise` - Noise (sword swoosh, impacts)
- `vmupro.sound.kWaveSine` - Sine wave (smooth tones)
- `vmupro.sound.kWaveSawtooth` - Sawtooth (harsher tones)
- `vmupro.sound.kWaveSquare` - Square wave (retro game sounds)

**Cleanup**:
```lua
vmupro.sound.synth.free(synth)
vmupro.audio.exitListenMode()
```

### Common Patterns

**Sound Effect Generators**:
```lua
-- Sword swoosh (white noise burst)
function playSwordSwoosh()
    vmupro.sound.synth.setWaveType(synth, vmupro.sound.kWaveNoise)
    vmupro.sound.synth.playNote(synth, 800, 0.4, 0.08)
end

-- Hit impact (low noise burst)
function playHitImpact()
    vmupro.sound.synth.setWaveType(synth, vmupro.sound.kWaveNoise)
    vmupro.sound.synth.playNote(synth, 120, 0.7, 0.05)
end

-- Death groan (descending frequency)
function playDeathGroan()
    vmupro.sound.synth.setWaveType(synth, vmupro.sound.kWaveSawtooth)
    vmupro.sound.synth.playNote(synth, 150, 0.6, 0.3)
    -- Optionally add second note for effect
    vmupro.sound.synth.playNote(synth, 80, 0.5, 0.2)
end
```

### Audio Implementation in Game

**Implemented Sound Effects** (from `../app.lua`):
- ✅ Sword swipe particle swoosh sound
- ✅ Death effects (groan + squish sounds)
- ⚠️ Background music (using synth, not the WAV file)

**Audio Update Loop**:
```lua
-- CRITICAL: Call every frame
vmupro.sound.update()
```

### Testing Requirements

- Test all sounds on VMU Pro hardware
- Verify no crashes with synth-based audio
- Check volume levels are appropriate
- Ensure `vmupro.sound.update()` is called every frame
- Verify audio lifecycle (startListenMode → use → exitListenMode)

## Dependencies

### Internal
- `../app.lua` - Main game code with audio implementation

### External
- VMU Pro SDK audio system (`vmupro.audio.*`, `vmupro.sound.*`)

## Audio Design

**Sound Effects Priority**:
1. Combat: Sword swings, hits, death sounds
2. UI: Menu navigation, selection sounds
3. Ambient: Dungeon atmosphere (optional)
4. Music: Background music (low priority)

**Design Philosophy**:
- Use short, punchy sounds for combat feedback
- Low frequencies for impactful hits
- Noise wave for swoosh/crash sounds
- Keep durations short (< 0.3s for SFX)

<!-- MANUAL: Audio design notes can be added below -->
