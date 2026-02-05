# VMU Pro Test Applications

This directory contains test applications for validating VMU Pro functionality.

## Test Suite

### Test Levels

1. **test_minimal** - Minimal app structure test
   - Verifies basic AppMain() execution
   - Tests display initialization
   - Tests basic text rendering
   - Run time: ~1 second

2. **test_stage1** - Display and Graphics
   - Tests clear with different colors
   - Tests text rendering at multiple positions
   - Tests drawing primitives (pixels, lines, rectangles, circles)
   - Run time: ~8 seconds

3. **test_stage2** - Input Handling
   - Tests button state detection
   - Tests all buttons (UP, DOWN, LEFT, RIGHT, A, B, START, SELECT)
   - Tests frame timing and game loop
   - Interactive: Press buttons to see input states
   - Run time: ~5 seconds

4. **test_stage3** - Sprite System
   - Tests sprite loading and positioning
   - Tests sprite rendering
   - Tests sprite cleanup
   - Falls back to rectangle if no sprite asset
   - Interactive: Use D-pad to move sprite
   - Run time: ~5 seconds

5. **test_stage4** - Audio System
   - Tests sound loading
   - Tests sound playback
   - Tests sound stopping
   - Tests audio system update
   - Falls back gracefully if no sound asset
   - Interactive: Press A to play, B to stop
   - Run time: ~5 seconds

6. **test_stage5** - Memory and System
   - Tests memory usage monitoring
   - Tests system time functions
   - Tests data structure allocation
   - Tests logging output
   - Run time: ~5 seconds

7. **test_stage6** - Integration Test
   - Tests all systems together
   - Simulates simple Tamagotchi game
   - Tests game state management
   - Tests UI rendering
   - Tests combined input/audio/sprite/display
   - Interactive: Full game controls
   - Run time: ~15 seconds

## Building All Tests

Use the master build script:

```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
python build_all_tests.py
```

Options:
- `--skip-existing` - Skip tests that are already built
- `--clean` - Remove all .vmupack files before rebuilding

## Building Individual Tests

```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer

python packer.py \
    --projectdir ../../examples/tests \
    --appname test_minimal \
    --meta ../../examples/tests/test_minimal_metadata.json \
    --sdkversion 1.0.0 \
    --icon ../../examples/tests/icon.bmp
```

## Deploying Tests

Use the send.py script to deploy to your VMU Pro device:

```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer

python send.py \
    --func send \
    --localfile build/test_minimal.vmupack \
    --remotefile apps/test_minimal.vmupack \
    --comport COM3
```

Change `COM3` to your device's COM port.

## Test Execution Order

Run tests in order for incremental validation:

1. Start with **test_minimal** - If this fails, basic SDK functionality is broken
2. Progress through **test_stage1** to **test_stage5** - Isolate individual subsystems
3. Finish with **test_stage6** - Validates full integration

## Expected Results

Each test should:
- Complete without errors
- Return 0 (success)
- Display expected output on screen
- Log messages to console

## Troubleshooting

If a test fails:
1. Check console logs for error messages
2. Verify all required files are present
3. Check memory usage in test_stage5
4. Ensure SDK version compatibility
5. Try running simpler tests first (e.g., test_minimal)

## Test Assets

Some tests attempt to load optional assets:
- `test_stage3` - looks for `test_sprite` sprite
- `test_stage4` - looks for `test_sound.wav`
- `test_stage6` - looks for `pet` sprite and `eat` sound

Tests will fall back gracefully if these assets don't exist.

## Metadata Files

Each test has a corresponding `*_metadata.json` file containing:
- App name and version
- Entry point
- App mode (1 for utilities, 3 for games)
- Resource list

Metadata files are used by the packer tool to create .vmupack files.
