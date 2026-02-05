# VMU Pro Audio API Rules

## Overview

The VMU Pro audio system provides two main namespaces for audio functionality:
- `vmupro.audio.*` - Audio system control and configuration
- `vmupro.sound.*` - Sample playback and mixing

## ⚠️ CRITICAL REQUIREMENT

### vmupro.sound.update() MUST BE CALLED EVERY FRAME

**Without calling `vmupro.sound.update()` in your main update loop, NO AUDIO WILL BE HEARD.**

```lua
-- REQUIRED in every application using audio
function vmupro.update()
    vmupro.sound.update()  -- CRITICAL: Call this every frame!
    -- ... rest of your update logic
end
```

**Why this is critical:**
- Audio mixing happens in `vmupro.sound.update()`
- The audio ring buffer is filled during this call
- Without it, samples won't be sent to the audio hardware
- This must be called every frame for continuous playback

---

## Audio System Setup

### Starting Audio Mode

Before using any audio features, you must initialize the audio system:

```lua
-- Start audio listen mode (required before playback)
vmupro.audio.startListenMode()
```

**Rules:**
- MUST be called before playing any samples or synths
- Should be called once during initialization
- Can be called in `vmupro.init()` or before first audio use

### Exiting Audio Mode

Clean up audio resources when done:

```lua
-- Exit audio listen mode (cleanup)
vmupro.audio.exitListenMode()
```

**Rules:**
- SHOULD be called when your app exits or stops using audio
- Frees audio hardware resources
- Optional but recommended for proper cleanup

### Complete Audio Lifecycle

```lua
function vmupro.init()
    -- Initialize audio system
    vmupro.audio.startListenMode()

    -- Load audio samples
    kick = vmupro.sound.sample.new("assets/kick")
    snare = vmupro.sound.sample.new("assets/snare")
end

function vmupro.update()
    -- CRITICAL: Update audio every frame
    vmupro.sound.update()

    -- Your game logic here
end

function vmupro.exit()
    -- Clean up audio samples
    vmupro.sound.sample.free(kick)
    vmupro.sound.sample.free(snare)

    -- Exit audio mode
    vmupro.audio.exitListenMode()
end
```

---

## Global Volume Control

### Setting Volume

```lua
-- Set global volume (0 = mute, 10 = maximum)
vmupro.audio.setGlobalVolume(5)  -- 50% volume
vmupro.audio.setGlobalVolume(0)  -- Mute
vmupro.audio.setGlobalVolume(10) -- Maximum volume
```

**Rules:**
- Volume range: 0-10 (integer values)
- 0 = completely muted
- 10 = maximum volume
- Affects all audio output (samples, synths, etc.)
- Changes take effect immediately

### Getting Volume

```lua
local currentVolume = vmupro.audio.getGlobalVolume()
vmupro.system.log(vmupro.system.LOG_INFO, "Audio", "Volume: " .. currentVolume)
```

**Rules:**
- Returns current global volume (0-10)
- Useful for volume sliders or settings menus

---

## Audio Ring Buffer Management

### Checking Buffer Fill State

```lua
local fillState = vmupro.audio.getRingbufferFillState()
vmupro.system.log(vmupro.system.LOG_DEBUG, "Audio", "Buffer samples: " .. fillState)
```

**Rules:**
- Returns number of samples currently in the audio ring buffer
- Useful for debugging audio latency issues
- Higher values = more buffered audio = more latency

### Clearing the Buffer

```lua
-- Clear the audio ring buffer
vmupro.audio.clearRingBuffer()
```

**Rules:**
- Immediately clears all buffered audio
- Use when you need to stop all audio instantly
- Useful when switching scenes or stopping music abruptly

---

## Sample Loading and Management

### Loading WAV Files

```lua
-- Load a WAV file from SD card
local kick = vmupro.sound.sample.new("assets/kick")
local music = vmupro.sound.sample.new("music/theme")

-- Check if loading succeeded
if kick == nil then
    vmupro.system.log(vmupro.system.LOG_ERROR, "Audio", "Failed to load kick.wav")
end
```

**Path Rules:**
- Paths are relative to `/sdcard/`
- Do NOT include the `.wav` extension
- Example: `"assets/kick"` loads `/sdcard/assets/kick.wav`
- Returns `nil` on error (file not found, invalid format, etc.)

**WAV File Format Requirements:**
- **Encoding**: PCM (uncompressed) or ADPCM (compressed)
- **Channels**: Mono or Stereo
- **Sample Rate**: Typically 8kHz, 11kHz, 22kHz, or 44.1kHz
- **Bit Depth**: 8-bit or 16-bit
- **Container**: Standard WAV file format

**Recommended Settings for Best Performance:**
- 8kHz or 11kHz sample rate for sound effects
- 22kHz for music
- ADPCM encoding to save memory
- Mono for sound effects, stereo for music

### Freeing Samples

```lua
-- Free a sample and release memory
vmupro.sound.sample.free(kick)
kick = nil  -- Clear the reference
```

**Rules:**
- MUST free samples when no longer needed
- Releases memory allocated for sample data
- Always free samples in `vmupro.exit()` or when switching scenes
- Set variable to `nil` after freeing to prevent use-after-free

---

## Sample Playback

### Basic Playback

```lua
-- Play a sample once
vmupro.sound.sample.play(kick, 0)

-- Play a sample twice (repeatCount = 1)
vmupro.sound.sample.play(snare, 1)

-- Loop a sample 5 times
vmupro.sound.sample.play(music, 4)
```

**Rules:**
- `repeatCount` parameter:
  - `0` = play once (one-shot)
  - `1` = play twice (repeat once)
  - `n` = play n+1 times
- Multiple calls to `play()` on the same sample will overlap
- Each playback instance is independent

### Playback with Callback

```lua
-- Execute callback when playback finishes
vmupro.sound.sample.play(explosion, 0, function()
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Audio", "Explosion finished")
    -- Trigger next event, show effect, etc.
end)
```

**Rules:**
- Callback is optional (third parameter)
- Called when playback completely finishes (including all repeats)
- Useful for sequencing events, triggering animations, etc.
- Callback receives no parameters

### Stopping Playback

```lua
-- Stop a playing sample immediately
vmupro.sound.sample.stop(kick)
```

**Rules:**
- Stops all instances of the sample currently playing
- Takes effect immediately
- Safe to call even if sample isn't playing

### Checking Playback State

```lua
if vmupro.sound.sample.isPlaying(kick) then
    vmupro.system.log(vmupro.system.LOG_DEBUG, "Audio", "Kick is playing")
else
    -- Safe to play another instance
    vmupro.sound.sample.play(kick, 0)
end
```

**Rules:**
- Returns `true` if any instance of the sample is currently playing
- Returns `false` if sample is stopped or finished
- Useful for preventing overlapping sound effects

---

## Volume Control Per Sample

### Setting Stereo Volume

```lua
-- Set stereo volume (0.0 to 1.0 for each channel)
vmupro.sound.sample.setVolume(kick, 1.0, 1.0)   -- Full volume, both channels
vmupro.sound.sample.setVolume(snare, 0.5, 0.5)  -- 50% volume
vmupro.sound.sample.setVolume(music, 0.7, 0.7)  -- 70% volume

-- Pan left (left channel full, right channel muted)
vmupro.sound.sample.setVolume(leftSfx, 1.0, 0.0)

-- Pan right (left channel muted, right channel full)
vmupro.sound.sample.setVolume(rightSfx, 0.0, 1.0)

-- Center pan with reduced volume
vmupro.sound.sample.setVolume(centerSfx, 0.5, 0.5)
```

**Rules:**
- Volume range: 0.0 (silent) to 1.0 (full volume)
- Independent control for left and right channels
- Use for stereo panning effects
- Changes affect all current and future playbacks of the sample
- Default is `1.0, 1.0` (full volume both channels)

### Getting Current Volume

```lua
local left, right = vmupro.sound.sample.getVolume(kick)
vmupro.system.log(vmupro.system.LOG_INFO, "Audio",
    "Kick volume - L: " .. left .. " R: " .. right)
```

**Rules:**
- Returns two values: left channel volume, right channel volume
- Both values range from 0.0 to 1.0
- Useful for UI sliders or volume indicators

---

## Playback Rate Control

### Setting Playback Rate

```lua
-- Normal speed/pitch
vmupro.sound.sample.setRate(kick, 1.0)

-- Half speed (lower pitch)
vmupro.sound.sample.setRate(slowmo, 0.5)

-- Double speed (higher pitch)
vmupro.sound.sample.setRate(fastSfx, 2.0)

-- Slight pitch variation for variety
vmupro.sound.sample.setRate(coin, 0.9 + math.random() * 0.2)  -- 0.9 to 1.1
```

**Rules:**
- Rate multiplier affects both speed and pitch
- `1.0` = normal playback
- `< 1.0` = slower/lower pitch
- `> 1.0` = faster/higher pitch
- Changes affect all current and future playbacks
- Useful for pitch variation to avoid repetitive sounds

### Getting Current Rate

```lua
local rate = vmupro.sound.sample.getRate(kick)
vmupro.system.log(vmupro.system.LOG_INFO, "Audio", "Playback rate: " .. rate)
```

**Rules:**
- Returns current playback rate multiplier
- Default is `1.0` (normal speed)

---

## Audio Mode Constants

```lua
-- Audio mode constants (for future use or advanced features)
vmupro.audio.MONO = 0
vmupro.audio.STEREO = 1
```

**Rules:**
- Currently defined constants for audio channel modes
- May be used for future API functions or hardware configuration
- Reference these constants instead of hardcoding `0` or `1`

---

## Common Audio Patterns

### Sound Effect Manager

```lua
-- Sound effect manager with volume control
local SoundManager = {}
SoundManager.sounds = {}
SoundManager.enabled = true
SoundManager.masterVolume = 1.0

function SoundManager.init()
    vmupro.audio.startListenMode()

    -- Load all sound effects
    SoundManager.sounds.jump = vmupro.sound.sample.new("sfx/jump")
    SoundManager.sounds.coin = vmupro.sound.sample.new("sfx/coin")
    SoundManager.sounds.hurt = vmupro.sound.sample.new("sfx/hurt")
    SoundManager.sounds.explosion = vmupro.sound.sample.new("sfx/explosion")

    -- Set initial volumes
    for name, sample in pairs(SoundManager.sounds) do
        vmupro.sound.sample.setVolume(sample,
            SoundManager.masterVolume, SoundManager.masterVolume)
    end
end

function SoundManager.play(name)
    if not SoundManager.enabled then return end

    local sample = SoundManager.sounds[name]
    if sample then
        vmupro.sound.sample.play(sample, 0)
    end
end

function SoundManager.setMasterVolume(volume)
    SoundManager.masterVolume = volume
    for name, sample in pairs(SoundManager.sounds) do
        vmupro.sound.sample.setVolume(sample, volume, volume)
    end
end

function SoundManager.cleanup()
    for name, sample in pairs(SoundManager.sounds) do
        vmupro.sound.sample.free(sample)
    end
    vmupro.audio.exitListenMode()
end

-- Usage in game
function vmupro.init()
    SoundManager.init()
end

function vmupro.update()
    vmupro.sound.update()  -- CRITICAL!

    -- Play sounds based on game events
    if playerJumped then
        SoundManager.play("jump")
    end
end

function vmupro.exit()
    SoundManager.cleanup()
end
```

### Background Music Loop

```lua
local musicSample
local musicPlaying = false

function vmupro.init()
    vmupro.audio.startListenMode()

    -- Load background music
    musicSample = vmupro.sound.sample.new("music/background")

    if musicSample then
        -- Set music volume lower than sound effects
        vmupro.sound.sample.setVolume(musicSample, 0.6, 0.6)

        -- Start looping music with callback
        playMusic()
    end
end

function playMusic()
    vmupro.sound.sample.play(musicSample, 0, function()
        -- Loop: play again when finished
        if musicPlaying then
            playMusic()
        end
    end)
    musicPlaying = true
end

function stopMusic()
    musicPlaying = false
    vmupro.sound.sample.stop(musicSample)
end

function vmupro.update()
    vmupro.sound.update()  -- CRITICAL!
end

function vmupro.exit()
    stopMusic()
    vmupro.sound.sample.free(musicSample)
    vmupro.audio.exitListenMode()
end
```

### Random Pitch Variation

```lua
-- Add variety to repetitive sounds
function playSoundWithVariation(sample, pitchRange)
    pitchRange = pitchRange or 0.1

    -- Random pitch between (1.0 - range) and (1.0 + range)
    local pitch = 1.0 + (math.random() * 2 - 1) * pitchRange

    vmupro.sound.sample.setRate(sample, pitch)
    vmupro.sound.sample.play(sample, 0)
end

-- Usage
playSoundWithVariation(coinSound, 0.2)  -- ±20% pitch variation
playSoundWithVariation(footstep, 0.1)   -- ±10% pitch variation
```

### Spatial Audio (Simple Panning)

```lua
-- Pan sound based on horizontal position
function playSpatialSound(sample, x, screenWidth)
    screenWidth = screenWidth or 128

    -- Calculate pan position (0.0 to 1.0)
    local pan = x / screenWidth

    -- Left channel: louder when pan is left (0.0)
    -- Right channel: louder when pan is right (1.0)
    local leftVol = 1.0 - pan
    local rightVol = pan

    vmupro.sound.sample.setVolume(sample, leftVol, rightVol)
    vmupro.sound.sample.play(sample, 0)
end

-- Usage
playSpatialSound(explosionSound, playerX, 128)
```

### Sound Effect Pool (Prevent Overlap)

```lua
local SoundPool = {}

function SoundPool.new(samplePath, maxInstances)
    local pool = {
        instances = {},
        maxInstances = maxInstances or 3,
        currentIndex = 1
    }

    -- Load multiple instances
    for i = 1, pool.maxInstances do
        pool.instances[i] = vmupro.sound.sample.new(samplePath)
    end

    function pool.play()
        local sample = pool.instances[pool.currentIndex]

        if not vmupro.sound.sample.isPlaying(sample) then
            vmupro.sound.sample.play(sample, 0)
            pool.currentIndex = (pool.currentIndex % pool.maxInstances) + 1
        end
    end

    function pool.cleanup()
        for i = 1, pool.maxInstances do
            vmupro.sound.sample.free(pool.instances[i])
        end
    end

    return pool
end

-- Usage: Multiple overlapping gunshots
local gunshotPool = SoundPool.new("sfx/gunshot", 5)

function shootWeapon()
    gunshotPool.play()  -- Can play up to 5 simultaneous gunshots
end
```

---

## Memory Considerations

### Sample Memory Usage

**Memory factors:**
- Sample rate: Higher = more memory
- Duration: Longer = more memory
- Channels: Stereo = 2x memory of mono
- Encoding: PCM = more memory, ADPCM = ~4x smaller

**Estimation formula:**
```
PCM Memory (bytes) ≈ sampleRate × duration × channels × (bitDepth/8)
ADPCM Memory (bytes) ≈ PCM Memory / 4
```

**Examples:**
```
1-second mono 8kHz 16-bit PCM: 8000 × 1 × 1 × 2 = 16KB
1-second stereo 22kHz 16-bit PCM: 22000 × 1 × 2 × 2 = 88KB
1-second mono 8kHz ADPCM: ~4KB
10-second background music (stereo 22kHz ADPCM): ~220KB
```

### Memory Management Best Practices

1. **Use ADPCM for longer samples** (music, ambience)
2. **Use lower sample rates for sound effects** (8kHz is often sufficient)
3. **Free samples when switching scenes**
4. **Load samples on-demand if memory constrained**
5. **Use mono for sound effects, stereo only for music**
6. **Keep short loops instead of long samples**

```lua
-- Example: Scene-based audio management
local currentScene = "menu"
local sceneSounds = {}

function loadSceneSounds(scene)
    -- Free previous scene sounds
    if sceneSounds[currentScene] then
        for _, sample in pairs(sceneSounds[currentScene]) do
            vmupro.sound.sample.free(sample)
        end
    end

    -- Load new scene sounds
    if scene == "menu" then
        sceneSounds.menu = {
            music = vmupro.sound.sample.new("music/menu"),
            select = vmupro.sound.sample.new("sfx/menu_select")
        }
    elseif scene == "game" then
        sceneSounds.game = {
            music = vmupro.sound.sample.new("music/game"),
            jump = vmupro.sound.sample.new("sfx/jump"),
            coin = vmupro.sound.sample.new("sfx/coin")
        }
    end

    currentScene = scene
end
```

---

## Performance Optimization

### Update Loop Optimization

```lua
function vmupro.update()
    -- Call audio update FIRST for lowest latency
    vmupro.sound.update()

    -- Then process game logic
    updatePlayer()
    updateEnemies()
    updatePhysics()
end
```

**Why update audio first:**
- Minimizes audio latency
- Ensures audio buffer stays filled
- Prevents audio stuttering during heavy processing

### Avoid Excessive Playback

```lua
-- BAD: Playing sound every frame creates audio chaos
function vmupro.update()
    vmupro.sound.update()
    vmupro.sound.sample.play(beep, 0)  -- DON'T DO THIS!
end

-- GOOD: Play sound on events only
local lastPlayTime = 0
function vmupro.update()
    vmupro.sound.update()

    local currentTime = vmupro.system.getTime()
    if buttonPressed and (currentTime - lastPlayTime) > 100 then
        vmupro.sound.sample.play(beep, 0)
        lastPlayTime = currentTime
    end
end
```

### Conditional Audio Processing

```lua
-- Disable audio processing when audio is muted
local audioEnabled = true

function vmupro.update()
    if audioEnabled then
        vmupro.sound.update()
    end

    -- Rest of update logic
end

function toggleAudio()
    audioEnabled = not audioEnabled
    if not audioEnabled then
        vmupro.audio.clearRingBuffer()  -- Clear any playing audio
    end
end
```

---

## Complete Example: Game Audio Implementation

```lua
-- Complete game with audio
local Audio = {}
Audio.samples = {}
Audio.music = nil
Audio.musicEnabled = true
Audio.sfxEnabled = true

function vmupro.init()
    -- Initialize audio system
    vmupro.audio.startListenMode()
    vmupro.audio.setGlobalVolume(7)

    -- Load sound effects
    Audio.samples.jump = vmupro.sound.sample.new("sfx/jump")
    Audio.samples.coin = vmupro.sound.sample.new("sfx/coin")
    Audio.samples.hurt = vmupro.sound.sample.new("sfx/hurt")
    Audio.samples.powerup = vmupro.sound.sample.new("sfx/powerup")

    -- Load background music
    Audio.music = vmupro.sound.sample.new("music/game_theme")

    -- Configure volumes
    vmupro.sound.sample.setVolume(Audio.music, 0.5, 0.5)

    for name, sample in pairs(Audio.samples) do
        vmupro.sound.sample.setVolume(sample, 0.8, 0.8)
    end

    -- Start music loop
    Audio.playMusic()
end

function Audio.playMusic()
    if Audio.musicEnabled and Audio.music then
        vmupro.sound.sample.play(Audio.music, 0, function()
            -- Loop when finished
            Audio.playMusic()
        end)
    end
end

function Audio.playSfx(name, pitchVariation)
    if not Audio.sfxEnabled then return end

    local sample = Audio.samples[name]
    if not sample then return end

    -- Add pitch variation if specified
    if pitchVariation then
        local pitch = 1.0 + (math.random() * 2 - 1) * pitchVariation
        vmupro.sound.sample.setRate(sample, pitch)
    else
        vmupro.sound.sample.setRate(sample, 1.0)
    end

    vmupro.sound.sample.play(sample, 0)
end

function Audio.toggleMusic()
    Audio.musicEnabled = not Audio.musicEnabled
    if not Audio.musicEnabled then
        vmupro.sound.sample.stop(Audio.music)
    else
        Audio.playMusic()
    end
end

function Audio.cleanup()
    -- Stop and free music
    if Audio.music then
        vmupro.sound.sample.stop(Audio.music)
        vmupro.sound.sample.free(Audio.music)
    end

    -- Free all sound effects
    for name, sample in pairs(Audio.samples) do
        vmupro.sound.sample.free(sample)
    end

    -- Exit audio mode
    vmupro.audio.exitListenMode()
end

-- Game variables
local player = { x = 64, y = 64, grounded = false }

function vmupro.update()
    -- CRITICAL: Update audio every frame
    vmupro.sound.update()

    -- Game logic with audio feedback
    local input = vmupro.input.getState()

    -- Jump
    if input.a and player.grounded then
        player.grounded = false
        Audio.playSfx("jump", 0.1)  -- ±10% pitch variation
    end

    -- Collect coin
    if checkCoinCollision(player) then
        Audio.playSfx("coin")
    end

    -- Take damage
    if checkEnemyCollision(player) then
        Audio.playSfx("hurt")
    end

    -- Collect powerup
    if checkPowerupCollision(player) then
        Audio.playSfx("powerup")
    end
end

function vmupro.exit()
    Audio.cleanup()
end

-- Helper functions (stubs for example)
function checkCoinCollision(player) return false end
function checkEnemyCollision(player) return false end
function checkPowerupCollision(player) return false end
```

---

## Troubleshooting

### No Audio Playing

**Check these items:**
1. ✅ Is `vmupro.audio.startListenMode()` called?
2. ✅ Is `vmupro.sound.update()` called every frame in `vmupro.update()`?
3. ✅ Is global volume > 0? (`vmupro.audio.getGlobalVolume()`)
4. ✅ Are sample volumes > 0? (`vmupro.sound.sample.getVolume()`)
5. ✅ Did WAV file load successfully? (check for `nil` return)
6. ✅ Is WAV file in correct format (PCM/ADPCM, mono/stereo)?

### Audio Crackling or Stuttering

**Possible causes:**
- Update loop taking too long (reduce processing)
- Audio buffer underrun (check `getRingbufferFillState()`)
- Sample rate mismatch
- Too many simultaneous samples playing

### Memory Issues

**Solutions:**
- Use ADPCM instead of PCM
- Reduce sample rate (8kHz for SFX)
- Use mono instead of stereo
- Free unused samples
- Load samples on-demand

---

## API Reference Summary

### vmupro.audio namespace

| Function | Description |
|----------|-------------|
| `getGlobalVolume()` | Get global volume (0-10) |
| `setGlobalVolume(volume)` | Set global volume (0-10) |
| `startListenMode()` | Initialize audio system (required before playback) |
| `exitListenMode()` | Shutdown audio system |
| `clearRingBuffer()` | Clear audio buffer immediately |
| `getRingbufferFillState()` | Get buffer fill level (samples) |

### vmupro.sound.sample namespace

| Function | Description |
|----------|-------------|
| `new(path)` | Load WAV file, returns sample object or nil |
| `play(sample, repeatCount, callback)` | Play sample (callback optional) |
| `stop(sample)` | Stop playing sample |
| `isPlaying(sample)` | Check if sample is playing |
| `free(sample)` | Free sample memory |
| `setVolume(sample, left, right)` | Set stereo volume (0.0-1.0) |
| `getVolume(sample)` | Get stereo volume |
| `setRate(sample, rate)` | Set playback rate/pitch |
| `getRate(sample)` | Get playback rate |

### vmupro.sound namespace

| Function | Description |
|----------|-------------|
| `update()` | **CRITICAL: Mix audio, call every frame** |

---

## Best Practices Checklist

- ✅ Call `vmupro.sound.update()` in every frame's update loop
- ✅ Call `vmupro.audio.startListenMode()` before using audio
- ✅ Free samples with `vmupro.sound.sample.free()` when done
- ✅ Use ADPCM encoding for longer samples
- ✅ Use lower sample rates (8-11kHz) for sound effects
- ✅ Add pitch variation to repetitive sounds
- ✅ Set appropriate volumes (music lower than SFX)
- ✅ Check for `nil` when loading samples
- ✅ Clear references after freeing (`sample = nil`)
- ✅ Call `vmupro.audio.exitListenMode()` on exit

---

**Remember: Audio will not work without calling `vmupro.sound.update()` every frame!**
