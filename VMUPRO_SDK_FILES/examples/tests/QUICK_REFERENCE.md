# Incremental Display Test - Quick Reference Card

## Test Overview

5 incremental tests to isolate display crashes. Execute in order, stop at first failure.

```
test_display_1  → clear()           → Basic display
test_display_2  → clear() + refresh() → Double buffering
test_display_3  → + drawText()      → Font rendering
test_display_4  → + setFont()       → Font switching
test_display_5  → + full pipeline   → Complete rendering
```

## One-Liner Build Commands

### Linux/Mac
```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer && \
python packer.py --projectdir ../../examples/tests --appname test_display_1 \
  --meta ../../examples/tests/test_display_1_metadata.json \
  --sdkversion 1.0.0 --icon ../../examples/tests/icon.bmp
```

### Windows (PowerShell)
```powershell
cd G:\vmupro-game-extras\documentation\tools\packer; `
python packer.py --projectdir ..\..\examples\tests --appname test_display_1 `
  --meta ..\..\examples\tests\test_display_1_metadata.json `
  --sdkversion 1.0.0 --icon ..\..\examples\tests\icon.bmp
```

## One-Liner Deploy Commands

### Linux/Mac
```bash
python send.py --func send \
  --localfile build/test_display_1.vmupack \
  --remotefile apps/test_display_1.vmupack \
  --comport COM3 --exec --monitor
```

### Windows (PowerShell)
```powershell
python send.py --func send `
  --localfile build/test_display_1.vmupack `
  --remotefile apps/test_display_1.vmupack `
  --comport COM3 --exec --monitor
```

## Batch Build Script

Save as `build_incremental_tests.sh` (Linux/Mac) or `.ps1` (Windows):

```bash
#!/bin/bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer

for i in {1..5}; do
  echo "Building test_display_$i..."
  python packer.py \
    --projectdir ../../examples/tests \
    --appname test_display_$i \
    --meta ../../examples/tests/test_display_${i}_metadata.json \
    --sdkversion 1.0.0 \
    --icon ../../examples/tests/icon.bmp

  if [ $? -eq 0 ]; then
    echo "✓ test_display_$i built successfully"
  else
    echo "✗ test_display_$i build failed"
    exit 1
  fi
done

echo "All tests built successfully!"
ls -lh build/test_display_*.vmupack
```

## Critical API Differences

### WRONG (Original Tests)
```lua
vmupro.display.refresh()                    # ❌ Wrong namespace
vmupro.system.getSystemTime()               # ❌ Wrong function
vmupro.input.BUTTON_UP                      # ❌ Wrong constant name
vmupro.input.isButtonDown(button)           # ❌ Wrong function
vmupro.sprite.render(sprite)                # ❌ Function doesn't exist
vmupro.graphics.drawRect(x,y,w,h,c,fill)    # ❌ Wrong signature
```

### RIGHT (Incremental Tests)
```lua
vmupro.graphics.refresh()                   # ✅ Correct
vmupro.system.getTimeUs()                   # ✅ Correct
vmupro.input.UP                             # ✅ Correct
vmupro.input.held(vmupro.input.UP)          # ✅ Correct (after read())
vmupro.sprite.draw(sprite,x,y,flags)        # ✅ Correct
vmupro.graphics.drawRect(x1,y1,x2,y2,color) # ✅ Correct
vmupro.graphics.drawFillRect(x1,y1,x2,y2,c) # ✅ For filled
```

## Expected Output per Test

| Test | Duration | Visual Output | Crash Means |
|------|----------|---------------|-------------|
| 1 | 2.5s | Colors: Black → White → Red → Green | Display not initialized |
| 2 | 1.0s | Flicker black/white at 60fps | Buffer swap broken |
| 3 | 3.0s | 3 text lines, frame counter 0-179 | Font system broken |
| 4 | 4.0s | 3 font sizes cycling every 1s | Font data corrupted |
| 5 | 5.0s | Full hello_world style | Complex state broken |

## Quick Troubleshooting

### Test 1 Fails
```lua
-- Check import
import "api/display"  -- NOT "api/graphics"

-- Check color constants
vmupro.graphics.BLACK   -- ✅
vmupro.graphics.WHITE   -- ✅
vmupro.graphics.VMUGREEN -- ✅
```

### Test 2 Fails
```lua
-- Check refresh call
vmupro.graphics.refresh()  -- NOT vmupro.display.refresh()
```

### Test 3 Fails
```lua
-- Check drawText signature
vmupro.graphics.drawText(text, x, y, color, bgcolor)
--                              ↑   ↑  ↑    ↑      ↑
--                            string num num color  color
```

### Test 4 Fails
```lua
-- Check font constants
vmupro.text.FONT_SMALL              -- ✅
vmupro.text.FONT_GABARITO_18x18     -- ✅
vmupro.text.FONT_GABARITO_22x24     -- ✅
```

### Test 5 Fails
```lua
-- Check input read
vmupro.input.read()  -- Must call ONCE per frame

-- Check input check
vmupro.input.pressed(vmupro.input.B)  -- ✅
vmupro.input.held(vmupro.input.A)     -- ✅
```

## File Locations

```
/mnt/g/vmupro-game-extras/documentation/examples/tests/
├── INCREMENTAL_DISPLAY_TEST_PLAN.md    ← Complete specs
├── API_ISSUES_ANALYSIS.md               ← Bug analysis
├── TEST_PLAN_README.md                  ← Quick start
├── QUICK_REFERENCE.md                   ← This file
├── icon.bmp                             ← 76x76 icon
└── test_display_1.lua through test_display_5.lua  ← Test code
```

## Success Checklist

For each test:
- [ ] File compiles without errors
- [ ] .vmupack file created in build/
- [ ] Deploy succeeds to device
- [ ] App runs without crash
- [ ] Expected visual output seen
- [ ] Clean exit (return 0)
- [ ] Log messages appear

## Decision Tree

```
Start
  │
  ├─ Build test_display_1
  │   ├─ Build FAILS → Check packer.py paths
  │   └─ Build OK → Deploy
  │       ├─ Deploy FAILS → Check COM port, connection
  │       └─ Deploy OK → Run
  │           ├─ CRASH → Display subsystem issue (check imports)
  │           └─ OK → Test 1 PASSED
  │
  └─ Build test_display_2
      ├─ CRASH → Double-buffering issue (check refresh API)
      └─ OK → Test 2 PASSED
          │
          └─ Continue to test 3...
```

## Common Pitfalls

1. ❌ **Wrong import**: `import "api/graphics"` → ✅ Use `import "api/display"`
2. ❌ **Wrong refresh**: `vmupro.display.refresh()` → ✅ Use `vmupro.graphics.refresh()`
3. ❌ **Wrong time**: `vmupro.system.getSystemTime()` → ✅ Use `vmupro.system.getTimeUs()`
4. ❌ **Wrong input**: `vmupro.input.BUTTON_UP` → ✅ Use `vmupro.input.UP`
5. ❌ **Wrong check**: `vmupro.input.isButtonDown()` → ✅ Use `vmupro.input.held()`
6. ❌ **Forgot read**: Checking input without `vmupro.input.read()` → ✅ Call once per frame

## Memory Aid

**Display** namespace = `vmupro.graphics.*`
- `clear()`, `refresh()`, `drawText()`, `drawRect()`, etc.

**Text** namespace = `vmupro.text.*`
- `setFont()`

**Input** namespace = `vmupro.input.*`
- `read()`, `pressed()`, `held()`, `released()`

**System** namespace = `vmupro.system.*`
- `log()`, `getTimeUs()`, `delayMs()`, `delayUs()`

## Next Steps After Testing

1. **If all tests pass**: Display system works, issue is elsewhere
2. **If test N fails**: Read diagnosis in INCREMENTAL_DISPLAY_TEST_PLAN.md
3. **If weird behavior**: Check log output via serial monitor
4. **If stuck**: Report test number, crash point, and device logs

---

**Remember**: One test at a time. Stop at first failure. Diagnosis is in the test plan.
