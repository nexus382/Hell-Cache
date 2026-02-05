<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# tests

## Purpose
SDK test suites and validation code for verifying VMU Pro functionality and API behavior.

## For AI Agents

### Working In This Directory

**These are test files** - reference for understanding SDK behavior and testing own code.

### Test Categories

**API Tests**:
- Function call verification
- Parameter validation
- Return value checking
- Error handling

**Integration Tests**:
- Multi-module interaction
- Resource lifecycle
- Performance benchmarks
- Memory usage

**Feature Tests**:
- Sprite rendering
- Audio playback
- Input handling
- File operations

### Using Tests

**As Reference**:
- See how to properly call API functions
- Understand expected behavior
- Learn error handling patterns
- Check performance characteristics

**For Testing Your Code**:
- Adapt test patterns for your app
- Verify features work correctly
- Catch regressions early
- Validate on hardware

### Test Patterns

**Basic Test Structure**:
```lua
function testFeature()
    -- Setup
    local result = false

    -- Test
    result = vmupro.someFunction(test_param)

    -- Verify
    if result == expected then
        vmupro.system.log(vmupro.system.LOG_INFO, "Test", "PASS")
    else
        vmupro.system.log(vmupro.system.LOG_ERROR, "Test", "FAIL")
    end

    return result
end
```

### Running Tests

Tests must be packaged as apps and deployed to VMU Pro hardware:
```bash
cd ../../tools/packer
python3 packer.py \
    --projectdir ../../examples/tests/test_name \
    --appname test_name \
    --meta ../../examples/tests/test_name/metadata.json \
    --icon ../../examples/tests/test_name/icon.bmp
```

## Dependencies

### Internal
- `../hello_world/` - Basic app structure
- `../nested_example/` - Complex app structure
- `../../docs/api/` - API documentation

### External
- VMU Pro hardware (for running tests)

<!-- MANUAL: Test-specific notes can be added below -->
