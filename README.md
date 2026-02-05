# Inner Sanctum

A 3D dungeon raycaster game for VMU Pro SDK. Protect the king from hordes of enemies who have broken into his inner sanctum.

## Game Overview

- **Genre**: Boomer wave shooter / dungeon crawler
- **Platform**: VMU Pro (240x240 display)
- **Controls**: D-pad movement, MODE+UP to attack, MODE+DOWN to block

## Technical Details

### VMU Pro SDK Notes
- Display: 240x240 pixels
- Color format: RGB565 little-endian
- Sprites: `vmupro.sprite.new()`, `vmupro.sprite.draw()`, `vmupro.sprite.drawScaled()`
- Audio: Use synth-based audio (`vmupro.sound.synth.new()`) - sample-based audio crashes
- **CRITICAL**: `math.atan2()` causes crashes - use custom `safeAtan2()` implementation
- **CRITICAL**: `math.random()` can crash - use deterministic alternatives like `(frameCount * multiplier) % range`

### Custom safeAtan2 Implementation
```lua
local function safeAtan2(y, x)
    if x == 0 then
        if y > 0 then return 1.5708
        elseif y < 0 then return -1.5708
        else return 0 end
    end
    local angle = math.atan(y / x)
    if x < 0 then angle = angle + 3.14159 end
    return angle
end
```

### Sprite Handling
- All warrior sprites normalized to ~517px height for consistent scaling
- Knight sprites normalized to ~579px height
- Ground positioning: `drawY = groundY - scaledHeight` (feet on ground, not eye-level)
- Walking animation: Check `animFrame ~= nil` (not `animFrame > 0` since 0 is valid)
- Enemy attack animation uses 2 frames per direction (front/back/left/right)
- Enemy death animation uses 7 frames (row-based)
- Player sword attack uses 9 frames; lock input until animation finishes

### Audio Setup
```lua
vmupro.audio.startListenMode()
local synth = vmupro.sound.synth.new(vmupro.sound.kWaveNoise)  -- or kWaveSine, kWaveSawtooth
vmupro.sound.synth.setAttack(synth, 0.01)
vmupro.sound.synth.setDecay(synth, 0.1)
vmupro.sound.synth.setSustain(synth, 0.2)
vmupro.sound.synth.setRelease(synth, 0.1)
vmupro.sound.synth.setVolume(synth, 0.5, 0.5)
-- Play: vmupro.sound.synth.playNote(synth, frequency, volume, duration)
-- Cleanup: vmupro.sound.synth.free(synth), vmupro.audio.exitListenMode()
```

## Current Features

### Implemented
- [x] 3D raycaster rendering with textured walls
- [x] Optional quad-based wall rendering (full 128x128 textures)
- [x] Player movement and collision detection
- [x] Soldier enemies with patrol/chase/attack AI (3x sprint speed when chasing)
- [x] Soldier health system (100 HP, health bars above heads)
- [x] Player combat (20 damage per swing, 1 unit attack range)
- [x] Player health system with Diablo 2-style potion UI
- [x] Health vials pickup (5 per level, restore to 100%)
- [x] Death effects (blood particles, groan + squish sounds)
- [x] Sword swing sprites and swoosh sound
- [x] Title screen with Start/Options/Exit
- [x] Pause menu with Resume/Options/Restart/Menu/Quit
- [x] Options: Sound On/Off, Health% On/Off
- [x] Win condition (kill all 5 soldiers)
- [x] Win screen with return to menu
- [x] Game over screen with Restart/Menu/Quit

### Known Issues
- Loading screen disabled in PR branch while tracking a crash on Start
- Wall textures are still being tuned (see Lessons Learned)

### TODO
- Re-enable loading screen once crash is resolved
- Add more enemy types
- Add wave system
- Add king NPC to protect
- Create knight sprites properly (if re-enabled)

## File Structure

```
vmupro-raycaster/
├── app.lua              # Main game code
├── metadata.json        # VMU Pro package metadata
├── icon.bmp             # 76x76 app icon
├── sprites/
│   ├── warrior_*.png    # Soldier sprites (front/back/left/right)
│   ├── warrior_walk*.png # Walking animations
│   ├── knight_*.png     # Knight sprites (not in use)
│   ├── potion.png       # Health vial/potion UI
│   └── title.png        # Title screen background
└── sounds/
    └── sword_swoosh.wav # (not used - using synth instead)
```

## Building

```bash
python "C:\Users\KyleN\vmupro-sdk\tools\packer\packer.py" \
    --projectdir "C:\Users\KyleN\vmupro-raycaster" \
    --appname inner_sanctum \
    --meta metadata.json \
    --icon icon.bmp
```

Output: `inner_sanctum.vmupack` - copy to `D:\apps\` on SD card

## Color Constants (RGB565 Little-Endian)
```lua
COLOR_BLACK = 0x0000
COLOR_WHITE = 0xFFFF
COLOR_RED = 0x00F8
COLOR_GREEN = 0xE007
COLOR_BLUE = 0x1F00
COLOR_MAROON = 0x0060
-- See app.lua for full list
```

## Lessons Learned

1. **Always use safeAtan2** - math.atan2 crashes the VMU Pro
2. **Avoid math.random** - can cause crashes, use frameCount-based alternatives
3. **Use synth audio, not samples** - sample-based audio crashes
4. **Normalize sprite heights** - ensures consistent scaling across all frames
5. **Ground-based positioning** - sprites should have feet on ground, not centered at eye level
6. **Check for nil, not 0** - animFrame of 0 is valid, use `~= nil`
7. **Define all colors** - undefined COLOR_* variables crash the game
8. **Input conflicts** - MODE button used for attack can conflict with menu; use cooldowns
9. **Test accessibility** - ensure all map areas are reachable by player
10. **Sprite slot limit is 64** - loading too many sprites at once crashes
11. **Column-slice wall textures are too heavy** - full 128x128 textures are safer
12. **Quad walls are a fast fallback** - draw full texture quads when slices look distorted

## Troubleshooting

- **Crash on Start**: Check for missing sprites and sprite slot exhaustion in logs.
- **Walls look like thin strips**: Use quad wall rendering or full 128x128 textures (no column slices).
- **Missing sprites**: Ensure `metadata.json` includes all texture PNGs and per-level sprites.
