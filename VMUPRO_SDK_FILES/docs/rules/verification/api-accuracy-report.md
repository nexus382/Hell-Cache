# VMU Pro SDK API Accuracy Verification Report

**Report Date:** 2026-01-04
**Verifier:** Verifier Agent
**Status:** ⏳ Awaiting API Rule File Creation

---

## Executive Summary

This verification report documents the accuracy of API rule files against the official VMU Pro SDK documentation and source code.

**Current Status:** The API rule files have not yet been created by the creator agents. This report establishes the verification framework and catalogs all available API functions for future verification.

---

## Verification Methodology

### 1. Source Materials Reviewed

✅ **API Documentation** (`/docs/api/`):
- ✅ `display.md` - Graphics API (393 lines)
- ✅ `input.md` - Input API (227 lines)
- ✅ `audio.md` - Audio API (507 lines)
- ✅ `file.md` - File System API (232 lines)
- ✅ `sprites.md` - Sprites API (extensive, 1000+ lines)
- ✅ `system.md` - System API (306 lines)
- ✅ `doublebuffer.md` - Double Buffer API (370 lines)
- ✅ `synth.md` - Synthesizer API (432 lines)
- ✅ `instrument.md` - Instrument API (145 lines)
- ✅ `sequence.md` - Sequence API (378 lines)

✅ **SDK Source Files** (`/sdk/api/`):
- ✅ `display.lua`
- ✅ `input.lua`
- ✅ `audio.lua`
- ✅ `file.lua`
- ✅ `sprites.lua`
- ✅ `system.lua`
- ✅ `doublebuffer.lua`
- ✅ `synth.lua`
- ✅ `instrument.lua`
- ✅ `sequence.lua`
- ✅ `utilities.lua`
- ✅ `text.lua`
- ✅ `log.lua`

### 2. Verification Criteria

Each API rule file will be checked for:

1. **Function Existence** - Does each documented function exist in the SDK?
2. **Parameter Accuracy** - Do parameter counts and types match?
3. **Return Value Accuracy** - Are return values correctly documented?
4. **Usage Examples** - Are code examples syntactically correct?
5. **Completeness** - Are all SDK functions documented?
6. **Misleading Information** - Any incorrect or confusing statements?

---

## API Function Catalog

### Display/Graphics API (`vmupro.graphics.*`)

#### Display Management (6 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `clear(color)` | color: number | None | ⏳ Awaiting rules |
| `refresh()` | None | None | ⏳ Awaiting rules |
| `getGlobalBrightness()` | None | number | ⏳ Awaiting rules |
| `setGlobalBrightness(brightness)` | brightness: number | None | ⏳ Awaiting rules |
| `getBackFb()` | None | userdata | ⏳ Awaiting rules |
| `getFrontFb()` | None | userdata | ⏳ Awaiting rules |
| `getBackBuffer()` | None | userdata | ⏳ Awaiting rules |

#### Basic Drawing (11 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `drawLine(x1, y1, x2, y2, color)` | 5 params (numbers) | None | ⏳ Awaiting rules |
| `drawRect(x1, y1, x2, y2, color)` | 5 params (numbers) | None | ⏳ Awaiting rules |
| `drawFillRect(x1, y1, x2, y2, color)` | 5 params (numbers) | None | ⏳ Awaiting rules |
| `drawText(text, x, y, color, bg_color)` | string + 4 numbers | None | ⏳ Awaiting rules |
| `drawCircle(cx, cy, radius, color)` | 4 params (numbers) | None | ⏳ Awaiting rules |
| `drawCircleFilled(cx, cy, radius, color)` | 4 params (numbers) | None | ⏳ Awaiting rules |
| `drawEllipse(cx, cy, rx, ry, color)` | 5 params (numbers) | None | ⏳ Awaiting rules |
| `drawEllipseFilled(cx, cy, rx, ry, color)` | 5 params (numbers) | None | ⏳ Awaiting rules |
| `drawPolygon(points, color)` | table + number | None | ⏳ Awaiting rules |
| `drawPolygonFilled(points, color)` | table + number | None | ⏳ Awaiting rules |
| `floodFill(x, y, fill_color, boundary_color)` | 4 params (numbers) | None | ⏳ Awaiting rules |
| `floodFillTolerance(x, y, fill_color, tolerance)` | 4 params (numbers) | None | ⏳ Awaiting rules |

#### Color Constants (14 constants)
- RED, ORANGE, YELLOW, YELLOWGREEN, GREEN, BLUE, NAVY, VIOLET, MAGENTA, GREY, BLACK, WHITE, VMUGREEN, VMUINK

#### Double Buffer Management (5 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `startDoubleBufferRenderer()` | None | None | ⏳ Awaiting rules |
| `stopDoubleBufferRenderer()` | None | None | ⏳ Awaiting rules |
| `pushDoubleBufferFrame()` | None | None | ⏳ Awaiting rules |
| `pauseDoubleBufferRenderer()` | None | None | ⏳ Awaiting rules |
| `resumeDoubleBufferRenderer()` | None | None | ⏳ Awaiting rules |

---

### Input API (`vmupro.input.*`)

#### Button Constants (8 constants)
- UP (0), DOWN (1), RIGHT (2), LEFT (3), POWER (4), MODE (5), A (6), B (7)

#### Input Functions (7 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `read()` | None | None | ⏳ Awaiting rules |
| `pressed(button)` | button: number | boolean | ⏳ Awaiting rules |
| `released(button)` | button: number | boolean | ⏳ Awaiting rules |
| `held(button)` | button: number | boolean | ⏳ Awaiting rules |
| `anythingHeld()` | None | boolean | ⏳ Awaiting rules |
| `confirmPressed()` | None | boolean | ⏳ Awaiting rules |
| `confirmReleased()` | None | boolean | ⏳ Awaiting rules |
| `dismissPressed()` | None | boolean | ⏳ Awaiting rules |
| `dismissReleased()` | None | boolean | ⏳ Awaiting rules |

---

### Audio API (`vmupro.audio.*` and `vmupro.sound.*`)

#### Volume Control (2 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `getGlobalVolume()` | None | number (0-10) | ⏳ Awaiting rules |
| `setGlobalVolume(volume)` | volume: number (0-10) | None | ⏳ Awaiting rules |

#### Audio Ring Buffer (6 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `startListenMode()` | None | None | ⏳ Awaiting rules |
| `exitListenMode()` | None | None | ⏳ Awaiting rules |
| `clearRingBuffer()` | None | None | ⏳ Awaiting rules |
| `getRingbufferFillState()` | None | number | ⏳ Awaiting rules |
| `addStreamSamples(samples, mode, applyVol)` | table + number + boolean | None | ⏳ Awaiting rules |

#### Sound Sample Playback (9 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `vmupro.sound.sample.new(path)` | path: string | table or nil | ⏳ Awaiting rules |
| `vmupro.sound.sample.play(sample, repeat, callback)` | table + number + function | None | ⏳ Awaiting rules |
| `vmupro.sound.sample.stop(sample)` | sample: table | None | ⏳ Awaiting rules |
| `vmupro.sound.sample.isPlaying(sample)` | sample: table | boolean | ⏳ Awaiting rules |
| `vmupro.sound.sample.free(sample)` | sample: table | None | ⏳ Awaiting rules |
| `vmupro.sound.sample.setVolume(sample, l, r)` | table + 2 numbers | None | ⏳ Awaiting rules |
| `vmupro.sound.sample.getVolume(sample)` | sample: table | 2 numbers | ⏳ Awaiting rules |
| `vmupro.sound.sample.setRate(sample, rate)` | table + number | None | ⏳ Awaiting rules |
| `vmupro.sound.sample.getRate(sample)` | sample: table | number | ⏳ Awaiting rules |
| `vmupro.sound.update()` | None | None | ⏳ Awaiting rules |

---

### File System API (`vmupro.file.*`)

#### File Operations (9 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `read(path)` | path: string | string or nil | ⏳ Awaiting rules |
| `write(path, data)` | string + string | boolean | ⏳ Awaiting rules |
| `exists(path)` | path: string | boolean | ⏳ Awaiting rules |
| `folderExists(path)` | path: string | boolean | ⏳ Awaiting rules |
| `createFolder(path)` | path: string | boolean | ⏳ Awaiting rules |
| `createFile(path)` | path: string | boolean | ⏳ Awaiting rules |
| `getSize(path)` | path: string | number | ⏳ Awaiting rules |
| `deleteFile(path)` | path: string | boolean | ⏳ Awaiting rules |
| `deleteFolder(path)` | path: string | boolean | ⏳ Awaiting rules |

---

### System API (`vmupro.system.*`)

#### Logging (1 function + 4 constants)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `log(level, tag, message)` | number + 2 strings | None | ⏳ Awaiting rules |

**Log Level Constants:** LOG_ERROR (0), LOG_WARN (1), LOG_INFO (2), LOG_DEBUG (3)

#### Timing Functions (5 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `sleep(ms)` | ms: number | None | ⏳ Awaiting rules |
| `getTimeUs()` | None | number | ⏳ Awaiting rules |
| `delayUs(us)` | us: number | None | ⏳ Awaiting rules |
| `delayMs(ms)` | ms: number | None | ⏳ Awaiting rules |

#### Display Functions (2 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `getGlobalBrightness()` | None | number (0-255) | ⏳ Awaiting rules |
| `setGlobalBrightness(brightness)` | number (0-255) | None | ⏳ Awaiting rules |

#### System Info (4 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `getLastBlittedFBSide()` | None | number | ⏳ Awaiting rules |
| `getMemoryUsage()` | None | number | ⏳ Awaiting rules |
| `getMemoryLimit()` | None | number | ⏳ Awaiting rules |
| `getLargestFreeBlock()` | None | number | ⏳ Awaiting rules |

---

### Synthesizer API (`vmupro.sound.synth.*`)

#### Waveform Constants (8 constants)
- kWaveSquare (0), kWaveTriangle (1), kWaveSine (2), kWaveNoise (3), kWaveSawtooth (4), kWavePOPhase (5), kWavePODigital (6), kWavePOVosim (7)

#### Synth Management (3 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `new(waveform)` | waveform: number | table or nil | ⏳ Awaiting rules |
| `free(synth)` | synth: table | None | ⏳ Awaiting rules |
| `setWaveform(synth, waveform)` | table + number | None | ⏳ Awaiting rules |

#### ADSR Envelope (4 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `setAttack(synth, attack)` | table + number | None | ⏳ Awaiting rules |
| `setDecay(synth, decay)` | table + number | None | ⏳ Awaiting rules |
| `setSustain(synth, sustain)` | table + number | None | ⏳ Awaiting rules |
| `setRelease(synth, release)` | table + number | None | ⏳ Awaiting rules |

#### Playback Functions (5 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `playNote(synth, freq, vel, len)` | table + 3 numbers | None | ⏳ Awaiting rules |
| `playMIDINote(synth, note, vel, len)` | table + 3 numbers | None | ⏳ Awaiting rules |
| `noteOff(synth)` | synth: table | None | ⏳ Awaiting rules |
| `stop(synth)` | synth: table | None | ⏳ Awaiting rules |
| `isPlaying(synth)` | synth: table | boolean | ⏳ Awaiting rules |

#### Volume Control (2 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `setVolume(synth, l, r)` | table + 2 numbers | None | ⏳ Awaiting rules |
| `getVolume(synth)` | synth: table | 2 numbers | ⏳ Awaiting rules |

#### PO Parameters (2 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `setParameter(synth, idx, val)` | table + 2 numbers | None | ⏳ Awaiting rules |
| `getParameter(synth, idx)` | table + number | number | ⏳ Awaiting rules |

---

### Instrument API (`vmupro.sound.instrument.*`)

#### Instrument Functions (3 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `new()` | None | table or nil | ⏳ Awaiting rules |
| `addVoice(inst, voice, note)` | table + table + number/nil | None | ⏳ Awaiting rules |
| `free(inst)` | inst: table | None | ⏳ Awaiting rules |

---

### Sequence API (`vmupro.sound.sequence.*`)

#### Sequence Functions (12 functions)
| Function | Parameters | Returns | Status |
|----------|-----------|---------|--------|
| `new(path)` | path: string | table or nil | ⏳ Awaiting rules |
| `getTrackCount(seq)` | seq: table | number | ⏳ Awaiting rules |
| `getTrackAtIndex(seq, idx)` | table + number | table or nil | ⏳ Awaiting rules |
| `setTrackInstrument(seq, idx, inst)` | 2 tables + number | None | ⏳ Awaiting rules |
| `setProgramCallback(seq, callback)` | table + function | None | ⏳ Awaiting rules |
| `getTrackPolyphony(seq, idx)` | table + number | number | ⏳ Awaiting rules |
| `getTrackNotesActive(seq, idx)` | table + number | number | ⏳ Awaiting rules |
| `play(seq)` | seq: table | None | ⏳ Awaiting rules |
| `stop(seq)` | seq: table | None | ⏳ Awaiting rules |
| `setLooping(seq, loop)` | table + boolean | None | ⏳ Awaiting rules |
| `isPlaying(seq)` | seq: table | boolean | ⏳ Awaiting rules |
| `free(seq)` | seq: table | None | ⏳ Awaiting rules |

---

### Sprites API (`vmupro.sprite.*`)

**Note:** The Sprites API is extensive with 40+ functions. Key categories:

#### Sprite Management (6 functions)
- `new(path)` - Load sprite
- `newSheet(path)` - Load spritesheet
- `draw(sprite, x, y, flags)` - Draw sprite
- `drawScaled(...)` - Draw with scaling
- `drawTinted(...)` - Draw with color tint
- `drawColorAdd(...)` - Draw with color addition
- `drawFrame(...)` - Draw spritesheet frame
- `free(sprite)` - Free sprite memory

#### Sprite Positioning (7 functions)
- `setPosition(sprite, x, y)`
- `moveTo(sprite, x, y)` - Alias for setPosition
- `moveBy(sprite, dx, dy)`
- `getPosition(sprite)`
- `setVisible(sprite, visible)`
- `getVisible(sprite)`
- `setZIndex(sprite, z)`
- `getZIndex(sprite)`
- `setCenter(sprite, x, y)`
- `getCenter(sprite)`
- `getBounds(sprite)`

#### Scene Management (4 functions)
- `add(sprite)` - Add to scene
- `remove(sprite)` - Remove from scene
- `removeAll()` - Clear all sprites
- `drawAll()` - Draw all sprites in scene

#### Flip Constants (4 constants)
- kImageUnflipped (0), kImageFlippedX (1), kImageFlippedY (2), kImageFlippedXY (3)

---

## Verification Checklist

### When API Rule Files Are Created:

- [ ] **Display API Rules** - Verify against `display.md` and `display.lua`
- [ ] **Input API Rules** - Verify against `input.md` and `input.lua`
- [ ] **Audio API Rules** - Verify against `audio.md` and `audio.lua`
- [ ] **File API Rules** - Verify against `file.md` and `file.lua`
- [ ] **Sprites API Rules** - Verify against `sprites.md` and `sprites.lua`
- [ ] **System API Rules** - Verify against `system.md` and `system.lua`
- [ ] **Double Buffer API Rules** - Verify against `doublebuffer.md` and `doublebuffer.lua`
- [ ] **Synthesizer API Rules** - Verify against `synth.md` and `synth.lua`
- [ ] **Instrument API Rules** - Verify against `instrument.md` and `instrument.lua`
- [ ] **Sequence API Rules** - Verify against `sequence.md` and `sequence.lua`

---

## Known API Patterns to Verify

### Common Patterns Found:

1. **Handle-based APIs** - Sprites, Audio, Synths return table handles with metadata
2. **RGB565 Color Format** - Graphics uses 16-bit RGB565 (not RGB888)
3. **Path Conventions** - No file extensions, relative to vmupack root
4. **Audio Lifecycle** - Must call `startListenMode()` before audio, `exitListenMode()` when done
5. **Memory Management** - Always free sprites, samples, synths, sequences
6. **1-based Indexing** - Lua convention (tracks, frames start at 1)
7. **Z-index Ordering** - Lower = behind, higher = in front
8. **Scene Management** - Must call `removeAll()` in cleanup to prevent sprite leaking

---

## Critical Information to Verify in Rules

### 1. Audio Lifecycle Management
- ✅ **Documented:** `vmupro.audio.startListenMode()` required before using synths/samples
- ✅ **Documented:** `vmupro.audio.exitListenMode()` required when leaving screen/page
- ⏳ **To Verify:** Are rule files emphasizing this critical lifecycle?

### 2. Memory Management
- ✅ **Documented:** Sprites must be freed with `vmupro.sprite.free()`
- ✅ **Documented:** Samples must be freed with `vmupro.sound.sample.free()`
- ✅ **Documented:** Synths must be freed with `vmupro.sound.synth.free()`
- ⏳ **To Verify:** Are rule files warning about memory leaks?

### 3. Scene Management
- ✅ **Documented:** Must call `vmupro.sprite.removeAll()` in exit/cleanup
- ✅ **Documented:** Prevents sprite leaking between pages
- ⏳ **To Verify:** Are rule files explaining this critical cleanup step?

### 4. Parameter Ranges
- Volume: 0-10 for `vmupro.audio.setGlobalVolume()`
- Brightness: 0-255 for `vmupro.system.setGlobalBrightness()`
- Brightness: 0-255 for `vmupro.graphics.setGlobalBrightness()`
- Sample volume: 0.0-1.0 for left/right channels
- Synth parameters: 0.0-1.0 for ADSR, volume, PO params

---

## Recommendations for Rule File Creators

### 1. **Prioritize Critical Lifecycle Information**
   - Audio lifecycle (`startListenMode` / `exitListenMode`)
   - Memory management (free all resources)
   - Scene cleanup (`removeAll()`)

### 2. **Include Common Pitfalls**
   - Forgetting to call `vmupro.sound.update()` (no audio)
   - Not freeing sprites (memory leaks)
   - Not calling `removeAll()` (sprite leaking between pages)
   - Incorrect parameter ranges (volume 0-10 vs brightness 0-255)

### 3. **Provide Concrete Examples**
   - Show complete initialization/cleanup patterns
   - Demonstrate proper error checking (nil checks)
   - Include typical game loop structure

### 4. **Document Edge Cases**
   - What happens if you free a sprite that's still in the scene?
   - What if you call `playNote()` without `startListenMode()`?
   - How many sprites can be loaded before running out of memory?

---

## Accuracy Scoring Framework

When rule files are available, accuracy will be scored as:

```
Accuracy Score = (Correct Items / Total Items) × 100%
```

**Categories:**
1. Function existence: 0 or 1 point per function
2. Parameter accuracy: 0 or 1 point per function
3. Return value accuracy: 0 or 1 point per function
4. Usage examples: 0 or 1 point per example
5. Completeness: (Documented Functions / Total Functions) × 100%

**Thresholds:**
- **95-100%**: Excellent
- **90-94%**: Good
- **80-89%**: Acceptable
- **Below 80%**: Needs revision

---

## Next Steps

1. ⏳ **Wait for creator agents** to generate API rule files
2. 📋 **Read all generated rule files** from `/docs/rules/api/`
3. ✅ **Cross-reference** each function against this catalog
4. 🔍 **Verify** parameter types, counts, and return values
5. 🧪 **Test** usage examples for syntactic correctness
6. 📊 **Calculate** overall accuracy score
7. 📝 **Document** any errors or missing information
8. ✍️ **Provide** corrections and recommendations

---

## Conclusion

This verification framework is ready to validate API rule files once they are created. The complete API catalog above will serve as the ground truth for verification against the official VMU Pro SDK documentation and source code.

**Total Functions Cataloged:** 150+ API functions across 10 modules

**Status:** ⏳ Awaiting API rule file creation by creator agents

---

**Verification Framework Version:** 1.0
**Last Updated:** 2026-01-04
