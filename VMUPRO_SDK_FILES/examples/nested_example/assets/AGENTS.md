<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# assets

## Purpose
Asset files for the nested example app including images, sounds, and other resources loaded at runtime.

## For AI Agents

### Working In This Directory

**These are example assets** - reference for asset organization.

### Asset Types

**Images**:
- PNG format with transparency
- Sprites: Characters, objects, UI
- Backgrounds: Title screens, etc.
- Icons: In-game UI elements

**Sounds**:
- WAV format (reference only - use synth in actual apps due to crashes)
- Note: VMU Pro crashes with sample-based audio

### Asset Loading

**Load Assets**:
```lua
-- From app.lua or page modules
local sprite = vmupro.sprite.new("assets/my_image")
-- SDK appends .png automatically
```

**Asset Path**:
- Paths are relative to app root
- No leading slash
- Use forward slashes

### Asset Organization

**Recommended Structure**:
```
assets/
├── images/
│   ├── sprites/
│   └── backgrounds/
└── sounds/
```

**For Simple Apps**:
```
assets/
├── sprite1.png
├── sprite2.png
└── background.png
```

### Best Practices

- Use descriptive names
- Group related assets
- Optimize file sizes
- Use transparency for sprites
- Test assets load correctly

## Dependencies

### Internal
- `../app.lua` - App code loading these assets
- `../pages/` - Pages using assets
- `../../docs/api/sprites.md` - Sprite API docs

<!-- MANUAL: Asset-specific notes can be added below -->
