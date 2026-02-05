# VMU Pro Display Testing Suite - README

## Quick Start

This directory contains incremental display tests to isolate crashes in the VMU Pro SDK display system.

**IMPORTANT**: Start by reading [INCREMENTAL_DISPLAY_TEST_PLAN.md](INCREMENTAL_DISPLAY_TEST_PLAN.md) for the complete testing strategy.

## Problem

Existing test files (test_minimal.lua through test_stage6.lua) contain **53 API inconsistencies** that cause crashes. See [API_ISSUES_ANALYSIS.md](API_ISSUES_ANALYSIS.md) for detailed analysis.

## Solution

Use the new incremental test plan (test_display_1.lua through test_display_5.lua) which:
- ✅ Uses ONLY verified, documented APIs
- ✅ Tests ONE display operation at a time
- ✅ Provides clear crash diagnosis
- ✅ Builds from simple to complex

## Test Files

### Incremental Display Tests (NEW - Use These)

1. **test_display_1.lua** - Basic clear test
   - Tests: `vmupro.graphics.clear()`
   - Expected: Color cycling
   - Duration: 2.5 seconds

2. **test_display_2.lua** - Clear + refresh test
   - Tests: `vmupro.graphics.clear()` + `vmupro.graphics.refresh()`
   - Expected: Screen flicker at 60fps
   - Duration: 1 second

3. **test_display_3.lua** - Text rendering test
   - Tests: Add `vmupro.graphics.drawText()`
   - Expected: 3 lines of text with frame counter
   - Duration: 3 seconds

4. **test_display_4.lua** - Font switching test
   - Tests: Add `vmupro.text.setFont()`
   - Expected: 3 different fonts cycling
   - Duration: 4 seconds

5. **test_display_5.lua** - Full rendering test
   - Tests: Complete hello_world style rendering
   - Expected: Complex multi-font display with input
   - Duration: 5 seconds or until B pressed

### Original Tests (DO NOT USE - Have API Issues)

- ❌ test_minimal.lua - Has 2 API issues
- ❌ test_stage1.lua - Has 8 API issues
- ❌ test_stage2.lua - Has 12 API issues
- ❌ test_stage3.lua - Has 10 API issues
- ❌ test_stage4.lua - Has 6 API issues
- ❌ test_stage5.lua - Has 4 API issues
- ❌ test_stage6.lua - Has 11 API issues

## Quick Build Command

```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer

# Build test_display_1
python packer.py \
    --projectdir ../../examples/tests \
    --appname test_display_1 \
    --meta ../../examples/tests/test_display_1_metadata.json \
    --sdkversion 1.0.0 \
    --icon ../../examples/tests/icon.bmp
```

## Quick Deploy Command

```bash
python send.py \
    --func send \
    --localfile build/test_display_1.vmupack \
    --remotefile apps/test_display_1.vmupack \
    --comport COM3 \
    --exec \
    --monitor
```

## Test Execution Order

Execute in this order, stopping at first failure:

1. test_display_1 → If FAIL: Display subsystem broken
2. test_display_2 → If FAIL: Double-buffering broken
3. test_display_3 → If FAIL: Font rendering broken
4. test_display_4 → If FAIL: Font switching broken
5. test_display_5 → If FAIL: Complex rendering broken

## Documentation Files

| File | Purpose |
|------|---------|
| **INCREMENTAL_DISPLAY_TEST_PLAN.md** | Complete test plan with code specs |
| **API_ISSUES_ANALYSIS.md** | Analysis of bugs in original tests |
| **TEST_PLAN_README.md** | This file - quick start guide |
| **BUILD_GUIDE.md** | Build instructions (may be outdated) |
| **README.md** | General test documentation (may be outdated) |
| **TEST_SUMMARY.md** | Summary of original tests (outdated) |

## Success Criteria

Each test should:
- ✅ Execute without crashes
- ✅ Display expected output
- ✅ Exit cleanly with return code 0
- ✅ Show appropriate log messages

## Crash Diagnosis

If a test crashes, check the "What a Crash Means" section in [INCREMENTAL_DISPLAY_TEST_PLAN.md](INCREMENTAL_DISPLAY_TEST_PLAN.md) for that specific test.

## Example: Test Display 1

**If it works**: You'll see the screen cycle through black, white, red, and VMU green colors.

**If it crashes**: The display subsystem isn't initialized or the color constants are invalid.

**What to check**:
- Import statement: `import "api/display"`
- Graphics namespace available
- RGB565 color constants valid

## Next Steps

1. Read [INCREMENTAL_DISPLAY_TEST_PLAN.md](INCREMENTAL_DISPLAY_TEST_PLAN.md) completely
2. Build and deploy test_display_1
3. If successful, proceed to test_display_2
4. Continue until you find the crash point
5. Use crash diagnosis to identify root cause
6. Report findings with test number and symptoms

## Support

For issues or questions:
1. Check [INCREMENTAL_DISPLAY_TEST_PLAN.md](INCREMENTAL_DISPLAY_TEST_PLAN.md) for detailed specs
2. Review [API_ISSUES_ANALYSIS.md](API_ISSUES_ANALYSIS.md) to avoid same mistakes
3. Verify against `/mnt/g/vmupro-game-extras/documentation/CLAUDE.md` for correct API usage

## Key Principles

1. **Incremental Testing** - One operation at a time
2. **Verified APIs** - Only use documented functions
3. **Clear Diagnosis** - Know what each crash means
4. **Build Up** - Start simple, add complexity
5. **Stop at Failure** - Don't skip ahead

Remember: The goal is to isolate the exact function causing crashes, not to build complex apps. Keep it simple!
