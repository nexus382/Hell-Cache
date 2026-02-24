<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-23 -->

# Tools Directory

Utility scripts and development tools for the project.

---

## Scripts

### preview_walk.py

A sprite flipbook viewer for previewing walk cycle animations and comparing sprite frames.

**Purpose:** Visualize sprite animations during asset development, particularly for character walk cycles.

**Usage:**
```bash
python preview_walk.py [options]
```

**Options:**

| Flag | Default | Description |
|------|---------|-------------|
| `--dir` | `./sprites` | Directory containing sprite PNG files |
| `--frames` | warrior_walk1-3.png | Frame filenames to load |
| `--height` | 120 | Target display height in pixels |
| `--fps` | 6 | Animation frames per second |
| `--diff` | off | Enable diff blink mode (alternates first two frames) |
| `--diff-overlay` | off | Show difference overlay between frames |
| `--pair A B` | - | Specify two frames for diff-blink mode |
| `--device-preview` | off | Preview at 240x240 with ground alignment |
| `--device-scale` | 1.0 | Scale factor in device preview mode |
| `--grid` | off | Show 10px grid overlay in device preview |
| `--ground-line` | off | Show ground line in device preview |

**Controls:**
- `Space` - Pause/resume animation
- `Left/Right` - Step through frames manually
- `Escape` - Close viewer

**Dependencies:**
- Python 3.x
- Pillow (`PIL`)
- tkinter (standard library)

**Example:**
```bash
# Preview default warrior walk cycle
python preview_walk.py

# Preview specific frames at higher FPS
python preview_walk.py --frames idle1.png idle2.png idle3.png --fps 12

# Compare two frames with diff blink
python preview_walk.py --pair walk1.png walk2.png --diff

# Device preview mode with grid
python preview_walk.py --device-preview --grid --ground-line
```

---

## Subdirectories

None.

---

## Notes

- All tools require appropriate dependencies to be installed
- Preview tool expects PNG sprites with RGBA support
- Checkerboard background helps visualize transparency in sprites
