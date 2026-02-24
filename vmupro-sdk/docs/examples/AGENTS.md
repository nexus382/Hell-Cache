# VMU Pro SDK Examples - AGENTS.md

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

This directory contains annotated sample applications that demonstrate VMU Pro Lua SDK patterns, best practices, and common development workflows. Each example is a self-contained tutorial with complete source code, explanations, and exercises.

**Key Characteristics:**
- **Format:** Markdown files with embedded Lua source code
- **Audience:** Developers learning VMU Pro application development
- **Coverage:** Progressive complexity from basic to advanced patterns

---

## Example Files

| File | Example | Description | Complexity |
|------|---------|-------------|------------|
| `hello-world.md` | Hello World | Minimal application demonstrating display, input, and main loop | Beginner |

---

## Hello World Example

The `hello-world.md` file demonstrates the fundamental structure of every VMU Pro application:

### Key Concepts Covered

1. **Application Structure**
   - `AppMain()` entry point
   - Main application loop pattern
   - Clean exit with return code

2. **Graphics Rendering**
   - Clearing the frame buffer
   - Drawing text with colors
   - Drawing primitives (rectangles)
   - Refreshing the display

3. **Input Handling**
   - Reading input state
   - Detecting button presses
   - Exit conditions

4. **Timing Control**
   - Frame rate management with `delayMs()`
   - Target ~60 FPS

### Source Files Included

| File | Purpose |
|------|---------|
| `app.lua` | Main application source code |
| `metadata.json` | Application manifest for packaging |

### Building Commands

```bash
python tools/packer/packer.py --projectdir examples/hello_world --appname hello_world --meta metadata.json --icon icon.bmp
```

---

## For AI Agents

### Working With Examples

1. **Each example is self-contained** - All source code and metadata is embedded in the markdown

2. **Examples follow consistent patterns:**
   - Source code sections with syntax highlighting
   - Key concepts explanation
   - Building and running instructions
   - Variations and exercises for learning

3. **Examples cross-reference other docs:**
   - API reference files in `../api/`
   - Guide files in `../guides/`

### Creating New Examples

When adding new example documentation:

1. **Follow the hello-world.md structure:**
   ```markdown
   # Example Name

   Brief description of what this demonstrates.

   ## Source Code

   ### app.lua
   ```lua
   -- Complete working source code
   ```

   ### metadata.json
   ```json
   // Application manifest
   ```

   ## Key Concepts Demonstrated

   ### 1. Concept Name
   Explanation with code snippets...

   ## Building and Running
   Step-by-step instructions...

   ## Variations and Exercises
   Learning extensions...

   ## Next Steps
   Links to related documentation...
   ```

2. **Include complete, runnable code** - No placeholders or pseudo-code

3. **Explain the "why" not just the "what"** - Help developers understand patterns

4. **Cross-reference API documentation** - Link to specific function docs

### Example-to-API Mapping

| Example Pattern | API Documentation |
|-----------------|-------------------|
| Graphics rendering | `../api/display.md` |
| Input handling | `../api/input.md` |
| Sprite usage | `../api/sprites.md` |
| Audio playback | `../api/audio.md` |
| File operations | `../api/file.md` |
| System utilities | `../api/system.md` |

---

## Exercises and Learning Path

Each example includes exercises for hands-on learning:

### Hello World Exercises

| Exercise | Concept | Difficulty |
|----------|---------|------------|
| Color Animation | Frame counters, conditional rendering | Beginner |
| Interactive Text | Button response, state changes | Beginner |
| Moving Text | Position updates, boundary checking | Beginner |

---

## Directory Structure

```
examples/
|-- AGENTS.md           # This file
|-- hello-world.md      # Hello World example (beginner)
```

---

## Related Files

| File | Relationship |
|------|--------------|
| `../AGENTS.md` | Parent documentation AGENTS.md |
| `../guides/` | Step-by-step tutorials |
| `../api/` | API function reference |
| `../../examples/` | Working example applications (source code) |

---

## See Also

- `../guides/first-app.md` - Detailed first application tutorial
- `../api/display.md` - Graphics API reference
- `../api/input.md` - Input API reference
- `../tools/packer.md` - Application packaging tool
