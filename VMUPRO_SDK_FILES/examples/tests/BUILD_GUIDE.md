# Quick Build Guide

## Build All Tests

```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
python build_all_tests.py
```

## Build Individual Test

```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer

python packer.py \
    --projectdir ../../examples/tests \
    --appname test_minimal \
    --meta ../../examples/tests/test_minimal_metadata.json \
    --sdkversion 1.0.0 \
    --icon ../../examples/tests/icon.bmp
```

## Deploy Test to Device

```bash
python send.py \
    --func send \
    --localfile build/test_minimal.vmupack \
    --remotefile apps/test_minimal.vmupack \
    --comport COM3
```

## Test Descriptions

| Test | Purpose | Duration | Mode |
|------|---------|----------|------|
| test_minimal | Basic structure | ~1s | Applet (1) |
| test_stage1 | Display & graphics | ~8s | Applet (1) |
| test_stage2 | Input handling | ~5s | Game (3) |
| test_stage3 | Sprite system | ~5s | Game (3) |
| test_stage4 | Audio system | ~5s | Game (3) |
| test_stage5 | Memory & system | ~5s | Applet (1) |
| test_stage6 | Full integration | ~15s | Game (3) |

## Build Script Options

- `--skip-existing` - Skip already built tests
- `--clean` - Remove all builds before rebuilding

## Test Order

Run tests in order for incremental validation:
1. test_minimal (verifies basic SDK)
2. test_stage1 (display subsystem)
3. test_stage2 (input subsystem)
4. test_stage3 (sprite subsystem)
5. test_stage4 (audio subsystem)
6. test_stage5 (system utilities)
7. test_stage6 (full integration)
