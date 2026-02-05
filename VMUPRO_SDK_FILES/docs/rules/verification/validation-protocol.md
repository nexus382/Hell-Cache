# VMU Pro LUA SDK - Fix Validation Protocol

## Overview

This protocol provides a rigorous, systematic approach to testing fixes and modifications to the VMU Pro LUA SDK codebase. It ensures that all changes maintain backward compatibility, don't introduce regressions, and meet quality standards before deployment.

## Protocol Philosophy

**Test in Isolation, Verify in Integration, Validate on Device**

1. **Pre-fix Baseline** - Document what works before changes
2. **Incremental Testing** - One change at a time with validation
3. **Regression Prevention** - Comprehensive test suite execution
4. **Performance Validation** - Frame rate and memory profiling
5. **Device Verification** - Real hardware testing before sign-off

---

## Table of Contents

1. [Pre-Fix Validation Phase](#1-pre-fix-validation-phase)
2. [Incremental Testing Phase](#2-incremental-testing-phase)
3. [Regression Testing Phase](#3-regression-testing-phase)
4. [Performance Testing Phase](#4-performance-testing-phase)
5. [Device Testing Phase](#5-device-testing-phase)
6. [Success Criteria](#6-success-criteria)
7. [Rollback Procedures](#7-rollback-procedures)
8. [Testing Checklists](#8-testing-checklists)

---

## 1. Pre-Fix Validation Phase

### Purpose

Establish a baseline of current functionality before making any changes. This provides objective evidence of what works and what doesn't, enabling accurate verification that fixes solve problems without breaking existing functionality.

### When to Run

- Before any code modification
- After identifying a bug or issue
- When planning significant refactoring
- Before implementing new features

### Pre-Fix Validation Checklist

#### A. Automated Test Suite Baseline

**Command:**
```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
python build_all_tests.py --clean
```

**Documentation Requirements:**
```markdown
## Pre-Fix Baseline - [DATE]

### Test Build Status
- test_minimal: [PASS/FAIL] - Build output
- test_stage1: [PASS/FAIL] - Build output
- test_stage2: [PASS/FAIL] - Build output
- test_stage3: [PASS/FAIL] - Build output
- test_stage4: [PASS/FAIL] - Build output
- test_stage5: [PASS/FAIL] - Build output
- test_stage6: [PASS/FAIL] - Build output

### Known Issues
- [List specific bugs or behaviors being addressed]
```

#### B. Code Quality Baseline

**Syntax Validation:**
```bash
# Verify all Lua files have valid syntax
find . -name "*.lua" -exec lua -e "dofile('{}')" \; 2>&1 | tee syntax_check.log
```

**Documentation Validation:**
```bash
# Check all code examples follow validation framework
grep -r "import \"api/" docs/rules/ | wc -l
grep -r "require(" docs/rules/ | wc -l  # Should be 0 in examples
```

#### C. Device Baseline Testing (If Available)

**Deployment Test:**
```bash
# Deploy and run test_minimal on device
python send.py \
    --func send \
    --localfile build/test_minimal.vmupack \
    --remotefile apps/test_minimal.vmupack \
    --comport COM3

# Document observed behavior
```

**Baseline Metrics to Record:**
- Application startup time
- Frame rate consistency
- Memory usage patterns
- Button response timing
- Display rendering quality
- Audio playback quality

### Pre-Fix Documentation Template

Create a file `pre_fix_baseline_[DATE].md`:

```markdown
# Pre-Fix Baseline - [Issue/Feature Description]

## Date: [YYYY-MM-DD]
## Issue: [Description of bug or feature]
## Proposed Fix: [High-level approach]

## Current State

### Automated Tests
| Test | Build Status | Expected Behavior | Actual Behavior |
|------|--------------|-------------------|-----------------|
| test_minimal | | | |
| test_stage1 | | | |
| test_stage2 | | | |
| test_stage3 | | | |
| test_stage4 | | | |
| test_stage5 | | | |
| test_stage6 | | | |

### Manual Observations
- **Display:**
- **Input:**
- **Audio:**
- **Sprites:**
- **Memory:**
- **Performance:**

### Known Bugs
1. [Bug description with reproduction steps]
2. [Bug description with reproduction steps]

### Risk Assessment
- **High Risk Areas:** [List potentially impacted subsystems]
- **Low Risk Areas:** [List unlikely to be affected]

### Success Definition
The fix is successful when:
- [Specific criteria that must be met]
```

---

## 2. Incremental Testing Phase

### Purpose

Apply changes one at a time with immediate validation, ensuring each modification is correct before proceeding to the next. This approach isolates problems and makes debugging much easier.

### Testing Strategy

**One Change → Validate → Document → Next Change**

### Incremental Testing Process

#### Step 1: Make Single, Isolated Change

**Guidelines:**
- Change only one file at a time
- Change only one function at a time when possible
- Keep changes atomic (can be easily reverted)
- Document the change with inline comments

**Example Commit Message:**
```
Fix input handling in test_stage2.lua

- Changed: vmupro.input.read() placement in game loop
- Reason: Ensure input is read before button state checks
- Impact: Should fix delayed button response
```

#### Step 2: Syntax Validation

**Immediate Validation:**
```bash
# Verify Lua syntax
lua -e "dofile('path/to/modified_file.lua')"
```

**Checklist:**
- [ ] No syntax errors
- [ ] All imports are valid
- [ ] All function calls have correct parameters
- [ ] No undefined variables

#### Step 3: Build Validation

**Rebuild Affected Test:**
```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer

python packer.py \
    --projectdir ../../examples/tests \
    --appname test_stage2 \
    --meta ../../examples/tests/test_stage2_metadata.json \
    --sdkversion 1.0.0 \
    --icon ../../examples/tests/icon.bmp
```

**Checklist:**
- [ ] Build completes successfully
- [ ] No warnings from packer
- [ ] .vmupack file created
- [ ] File size is reasonable (within 10% of previous)

#### Step 4: Code Review

**Self-Review Checklist:**

**SDK Compliance:**
- [ ] Uses `import` not `require()`
- [ ] AppMain() returns numeric value
- [ ] Input read once per frame before checks
- [ ] Clear once, draw all, refresh once
- [ ] Sprites cleaned up on exit
- [ ] Audio update called every frame (if using audio)
- [ ] Proper frame timing with delayMs()

**Code Quality:**
- [ ] Functions are small (< 50 lines)
- [ ] Local variables used instead of globals
- [ ] Constants defined instead of magic numbers
- [ ] Error handling for resource loading
- [ ] Clear, descriptive variable names
- [ ] Comments explain non-obvious logic

#### Step 5: Automated Test Execution

**Run Only Affected Test:**
```bash
# Deploy and monitor specific test
python send.py \
    --func send \
    --localfile build/test_stage2.vmupack \
    --remotefile apps/test_stage2.vmupack \
    --comport COM3 \
    --exec \
    --monitor
```

**Expected Behavior Verification:**
- [ ] Test completes without crashing
- [ ] All test assertions pass
- [ ] Output matches expected results
- [ ] No memory corruption symptoms
- [ ] No infinite loops

#### Step 6: Documentation Update

**Create Change Log Entry:**
```markdown
## Change [N] - [DATE]

**File Modified:** test_stage2.lua
**Lines Changed:** 45-52
**Change Type:** [Bug Fix / Enhancement / Refactor]

### What Changed
[Describe the specific change]

### Why Changed
[Explain the reasoning]

### Validation Results
- Syntax: [PASS/FAIL]
- Build: [PASS/FAIL]
- Test Execution: [PASS/FAIL]
- Device Behavior: [PASS/FAIL]

### Observations
[Any unexpected behavior or side effects]

### Next Steps
[What to test next]
```

### Incremental Testing Decision Tree

```
                    Make Change
                        |
                        v
                  Syntax Check?
                   /        \
                 NO         YES
                 |           |
            Fix Syntax   Build Check?
                 |           |
                 +-----------+------+
                             |
                   Build Successful?
                   /        \
                 NO         YES
                 |           |
              Fix Build   Code Review?
                 |           |
                 +-----------+------+
                             |
                    Review Passed?
                   /        \
                 NO         YES
                 |           |
            Fix Issues   Deploy Test?
                 |           |
                 +-----------+------+
                             |
                   Test Passed?
                   /        \
                 NO         YES
                 |           |
              Debug Fix   Document & Next
                              |
                         More Changes?
                        /        \
                      YES         NO
                      |            |
                   Next Change  Regression Tests
```

---

## 3. Regression Testing Phase

### Purpose

Ensure that fixes don't break previously working functionality. Run the complete test suite to verify system-wide integrity.

### When to Run

- After completing incremental changes
- Before committing changes to version control
- After any core API modifications
- Before deploying to production

### Full Test Suite Execution

#### A. Rebuild All Tests

```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
python build_all_tests.py --clean
```

**Expected Output:**
```
Total tests: 7
  Successful: 7
  Failed:     0
```

#### B. Sequential Test Deployment

**Test Execution Order:**
```bash
# Test 1: Basic SDK Structure
python send.py --func send --localfile build/test_minimal.vmupack \
    --remotefile apps/test_minimal.vmupack --comport COM3 --exec --monitor

# Test 2: Display System
python send.py --func send --localfile build/test_stage1.vmupack \
    --remotefile apps/test_stage1.vmupack --comport COM3 --exec --monitor

# Test 3: Input System
python send.py --func send --localfile build/test_stage2.vmupack \
    --remotefile apps/test_stage2.vmupack --comport COM3 --exec --monitor

# Test 4: Sprite System
python send.py --func send --localfile build/test_stage3.vmupack \
    --remotefile apps/test_stage3.vmupack --comport COM3 --exec --monitor

# Test 5: Audio System
python send.py --func send --localfile build/test_stage4.vmupack \
    --remotefile apps/test_stage4.vmupack --comport COM3 --exec --monitor

# Test 6: Memory & System
python send.py --func send --localfile build/test_stage5.vmupack \
    --remotefile apps/test_stage5.vmupack --comport COM3 --exec --monitor

# Test 7: Full Integration
python send.py --func send --localfile build/test_stage6.vmupack \
    --remotefile apps/test_stage6.vmupack --comport COM3 --exec --monitor
```

#### C. Regression Test Checklist

**For Each Test, Verify:**

**test_minimal - Basic Structure**
- [ ] App starts successfully
- [ ] Text displays correctly
- [ ] App exits cleanly (returns 0)
- [ ] No startup delay > 2 seconds
- [ ] No memory warnings

**test_stage1 - Display System**
- [ ] All primitives render correctly
- [ ] Colors are accurate (RGB565)
- [ ] Text is legible
- [ ] No flickering or artifacts
- [ ] Frame timing is smooth
- [ ] All test steps complete

**test_stage2 - Input System**
- [ ] All buttons respond correctly
- [ ] Button states display accurately
- [ ] No input lag
- [ ] Edge detection works (pressed/released)
- [ ] Held state works correctly
- [ ] Multiple buttons can be detected

**test_stage3 - Sprite System**
- [ ] Sprites load without errors
- [ ] Sprites render at correct positions
- [ ] D-pad movement works smoothly
- [ ] Collision detection functional
- [ ] Z-ordering correct
- [ ] All sprites cleaned up on exit

**test_stage4 - Audio System**
- [ ] Sounds load successfully
- [ ] Playback starts on A button
- [ ] Playback stops on B button
- [ ] No audio distortion
- [ ] No audio lag
- [ ] Audio system exits cleanly

**test_stage5 - Memory & System**
- [ ] Memory usage reported accurately
- [ ] No memory leaks (usage stable)
- [ ] System time functions work
- [ ] Logging outputs correctly
- [ ] Frame timing is accurate
- [ ] No out-of-memory errors

**test_stage6 - Full Integration**
- [ ] Game loop runs smoothly
- [ ] All systems work together
- [ ] No frame rate drops
- [ ] Memory usage stable
- [ ] All interactive elements work
- [ ] Clean exit on B button

#### D. Cross-Subsystem Validation

**Interaction Testing:**
- [ ] Display + Input: No rendering issues during button presses
- [ ] Display + Sprites: Sprites render over/under correctly
- [ ] Input + Audio: Audio responds to input without lag
- [ ] Audio + Sprites: Frame rate doesn't drop during audio
- [ ] Memory + All: No leaks when using multiple subsystems

#### E. Regression Detection Methods

**Automated Detection:**
```bash
# Compare build output sizes with baseline
ls -lh build/ > current_builds.txt
diff current_builds.txt baseline_builds.txt

# Size changes > 10% should be investigated
```

**Manual Detection:**
- Visual artifacts in rendering
- Audio pops or glitches
- Input lag or missed button presses
- Unexpected app termination
- Memory warnings in logs
- Frame rate inconsistencies

**Symptom-Based Regression Guide:**

| Symptom | Likely Cause | Check |
|---------|--------------|-------|
| Flickering display | Multiple refresh() calls | Search for refresh in modified files |
| No input | Missing input.read() | Verify game loop structure |
| Audio doesn't play | Missing sound.update() | Check audio frame update |
| Sprites don't show | Missing sprite.draw() or drawAll() | Verify sprite rendering calls |
| App crashes on exit | Missing cleanup | Check for removeAll(), free() calls |
| Memory increases | Resource leaks | Verify all resources freed |
| Slow frame rate | Inefficient loops | Profile with getTimeUs() |

---

## 4. Performance Testing Phase

### Purpose

Validate that changes don't negatively impact performance. Frame rate and memory usage must remain within acceptable bounds.

### Performance Benchmarks

**Target Specifications:**
- **Frame Rate:** 60 FPS (16.67ms per frame)
- **Frame Time:** Maximum 20ms per frame (50 FPS minimum)
- **Memory Usage:** Stable, no leaks > 1KB over 30 seconds
- **Startup Time:** < 2 seconds to AppMain() entry
- **Input Latency:** < 50ms from button press to response

### Performance Testing Protocol

#### A. Frame Rate Testing

**Test Setup:**
```lua
-- Add to test file for performance measurement
local frame_count = 0
local start_time = vmupro.system.getTimeUs()
local fps_update_interval = 60  -- Update every 60 frames

while app_running do
    frame_count = frame_count + 1

    -- ... existing code ...

    if frame_count % fps_update_interval == 0 then
        local current_time = vmupro.system.getTimeUs()
        local elapsed_us = current_time - start_time
        local elapsed_sec = elapsed_us / 1000000
        local fps = fps_update_interval / elapsed_sec

        vmupro.system.log(vmupro.system.LOG_INFO, "Perf",
            string.format("FPS: %.2f (Frame: %d)", fps, frame_count))

        start_time = current_time
    end

    vmupro.system.delayMs(16)
end
```

**Acceptance Criteria:**
- [ ] Average FPS >= 55 (allowing for minor variance)
- [ ] Minimum FPS >= 50 (no severe drops)
- [ ] Frame time standard deviation < 2ms (consistent timing)
- [ ] No frame spikes > 30ms

#### B. Memory Testing

**Test Setup:**
```lua
-- Add to test file for memory monitoring
local memory_check_interval = 60  -- Check every 60 frames

while app_running do
    -- ... existing code ...

    if frame_count % memory_check_interval == 0 then
        local current_memory = vmupro.system.getMemoryUsage()
        local memory_limit = vmupro.system.getMemoryLimit()
        local usage_percent = (current_memory / memory_limit) * 100

        vmupro.system.log(vmupro.system.LOG_INFO, "Memory",
            string.format("Usage: %d bytes (%.1f%%)",
                current_memory, usage_percent))
    end

    vmupro.system.delayMs(16)
end
```

**Acceptance Criteria:**
- [ ] Memory usage stable over 30 seconds
- [ ] No leaks > 1KB over test duration
- [ ] Peak memory < 80% of limit
- [ ] Memory returned to baseline after cleanup

#### C. Startup Time Testing

**Measurement Method:**
```lua
function AppMain()
    local app_start = vmupro.system.getTimeUs()

    -- Initialization code
    init_app()

    local init_end = vmupro.system.getTimeUs()
    local init_time_ms = (init_end - app_start) / 1000

    vmupro.system.log(vmupro.system.LOG_INFO, "Perf",
        string.format("Startup time: %d ms", init_time_ms))

    -- ... rest of app ...
end
```

**Acceptance Criteria:**
- [ ] Initialization < 500ms for simple apps
- [ ] Initialization < 2000ms for complex apps
- [ ] No perceptible delay on device

#### D. Input Latency Testing

**Manual Test Procedure:**
1. Run test_stage2 (Input test)
2. Press A button while watching display
3. Measure time from press to display update
4. Repeat 10 times, calculate average

**Acceptance Criteria:**
- [ ] Average latency < 50ms (3 frames at 60 FPS)
- [ ] Maximum latency < 100ms (6 frames)
- [ ] No missed button presses in rapid testing

#### E. Stress Testing

**Sprite Stress Test:**
```lua
-- Create many sprites to test performance
local sprites = {}
for i = 1, 50 do
    sprites[i] = vmupro.sprite.new("assets/test")
    vmupro.sprite.add(sprites[i])
    vmupro.sprite.setPosition(sprites[i],
        math.random(0, 240), math.random(0, 240))
end

-- Test frame rate with many sprites
-- Should maintain > 30 FPS with 50 sprites
```

**Audio Stress Test:**
```lua
-- Test multiple concurrent sounds
local sounds = {}
for i = 1, 5 do
    sounds[i] = vmupro.sound.sample.new("assets/test")
    vmupro.sound.sample.play(sounds[i], 0)
end

-- Verify no audio glitching
```

**Memory Stress Test:**
```lua
-- Allocate and free memory repeatedly
for cycle = 1, 10 do
    local temp_sprites = {}
    for i = 1, 20 do
        temp_sprites[i] = vmupro.sprite.new("assets/test")
    end

    vmupro.system.delayMs(100)

    for i = 1, 20 do
        vmupro.sprite.free(temp_sprites[i])
    end

    local current_mem = vmupro.system.getMemoryUsage()
    vmupro.system.log(vmupro.system.LOG_INFO, "Stress",
        string.format("Cycle %d: Memory %d bytes", cycle, current_mem))
end
```

### Performance Profiling Template

```markdown
## Performance Profile - [Test Name] - [DATE]

### Frame Rate
- Average FPS: [value]
- Min FPS: [value]
- Max FPS: [value]
- Std Dev: [value]
- Target: 60 FPS

### Memory
- Baseline: [bytes]
- Peak: [bytes]
- Final: [bytes]
- Leak Detected: [YES/NO]
- Leak Amount: [bytes]

### Startup
- Init Time: [ms]
- Target: < 2000ms

### Input Latency
- Average: [ms]
- Min: [ms]
- Max: [ms]
- Target: < 50ms

### Stress Test Results
- Sprite Count: [count]
- FPS under load: [value]
- Audio streams: [count]
- Memory cycles: [count]

### Performance Verdict: [PASS/FAIL]
```

---

## 5. Device Testing Phase

### Purpose

Validate fixes on actual VMU Pro hardware. Device testing catches issues that can't be detected in simulation or build-only testing.

### Pre-Device Checklist

**Environment Preparation:**
- [ ] Device firmware is up to date
- [ ] USB/Serial drivers installed
- [ ] Known good COM port identified
- [ ] Device has adequate battery charge
- [ ] Device SD card has sufficient space
- [ ] Latest packer.py and send.py scripts

**Build Verification:**
- [ ] All tests built successfully
- [ ] No build warnings
- [ ] .vmupack files are reasonable size
- [ ] Icon files included

### Device Testing Protocol

#### A. Connection Test

**Verify Device Communication:**
```bash
# Test basic connectivity
python send.py --func ping --comport COM3
```

**Expected Output:**
```
Connected to VMU Pro
Firmware: [version]
Device ID: [id]
```

#### B. Deployment Test

**Clean Device State:**
```bash
# Remove old test files
python send.py --func delete --remotefile apps/test_* --comport COM3
```

**Deploy Sequential Tests:**

**Test 1: Basic Connectivity (test_minimal)**
```bash
python send.py \
    --func send \
    --localfile build/test_minimal.vmupack \
    --remotefile apps/test_minimal.vmupack \
    --comport COM3

# Monitor for successful transfer
# Expected: "File transferred successfully"
```

**Test 2: Display Validation (test_stage1)**
```bash
python send.py \
    --func send \
    --localfile build/test_stage1.vmupack \
    --remotefile apps/test_stage1.vmupack \
    --comport COM3

# Visually verify:
# - All colors render correctly
# - Text is legible
# - Shapes are accurate
# - No flickering
```

**Test 3: Input Validation (test_stage2)**
```bash
python send.py \
    --func send \
    --localfile build/test_stage2.vmupack \
    --remotefile apps/test_stage2.vmupack \
    --comport COM3

# Physically test all buttons:
# - UP: Display shows "UP" pressed
# - DOWN: Display shows "DOWN" pressed
# - LEFT: Display shows "LEFT" pressed
# - RIGHT: Display shows "RIGHT" pressed
# - A: Display shows "A" pressed
# - B: Display shows "B" pressed
# - MODE: Display shows "MODE" pressed
# - POWER: Display shows "POWER" pressed
```

**Test 4: Sprite Validation (test_stage3)**
```bash
python send.py \
    --func send \
    --localfile build/test_stage3.vmupack \
    --remotefile apps/test_stage3.vmupack \
    --comport COM3

# Test sprite behavior:
# - Sprites render correctly
# - D-pad moves sprite smoothly
# - Movement is responsive
# - No rendering artifacts
# - Clean exit (sprites removed)
```

**Test 5: Audio Validation (test_stage4)**
```bash
python send.py \
    --func send \
    --localfile build/test_stage4.vmupack \
    --remotefile apps/test_stage4.vmupack \
    --comport COM3

# Test audio playback:
# - A button plays sound
# - Sound quality is good (no distortion)
# - B button stops sound
# - No audio lag
# - Multiple plays work correctly
```

**Test 6: Memory Validation (test_stage5)**
```bash
python send.py \
    --func send \
    --localfile build/test_stage5.vmupack \
    --remotefile apps/test_stage5.vmupack \
    --comport COM3

# Monitor system behavior:
# - Memory usage displays correctly
# - No out-of-memory errors
# - Stable operation over time
# - Logging appears in device log
```

**Test 7: Integration Validation (test_stage6)**
```bash
python send.py \
    --func send \
    --localfile build/test_stage6.vmupack \
    --remotefile apps/test_stage6.vmupack \
    --comport COM3

# Full integration test:
# - All game mechanics work
# - Frame rate is smooth
# - Audio syncs with visuals
# - Input is responsive
# - Memory is stable
# - Clean exit
```

#### C. Extended Device Testing

**Long-Run Stability Test:**
```bash
# Deploy test_stage6 and let run for 5+ minutes
# Monitor for:
- Memory leaks
- Frame rate degradation
- Audio glitches
- Input responsiveness
- Display artifacts
- Unexpected termination
```

**Power Consumption Test:**
```bash
# Monitor battery usage during extended test
# Compare with baseline:
- Normal operation: [baseline mA]
- Under test: [measured mA]
- Difference should be < 10%
```

**Temperature Test:**
```bash
# Run intensive test for 10 minutes
# Check device temperature
- Should not exceed safe operating range
- No thermal throttling symptoms (frame rate drops)
```

### Device Testing Checklist

**For Each Test:**

**Deployment:**
- [ ] File transfers without errors
- [ ] Transfer time is reasonable (< 10 seconds)
- [ ] File size matches expected
- [ ] Device acknowledges transfer

**Execution:**
- [ ] App starts without crash
- [ ] Display initializes correctly
- [ ] No startup delay > 2 seconds
- [ ] All test phases complete
- [ ] Clean exit (no crash on return)

**Functional:**
- [ ] All features work as expected
- [ ] No input lag
- [ ] No rendering issues
- [ ] Audio plays clearly
- [ ] Memory usage is normal

**Quality:**
- [ ] Frame rate is smooth
- [ ] No visual artifacts
- [ ] No audio glitches
- [ ] Responsive to input
- [ ] No unexpected behavior

### Device Issue Categorization

**Severity Levels:**

**CRITICAL (Block Release):**
- Device crashes or freezes
- Data corruption
- Security vulnerabilities
- Hardware damage potential

**HIGH (Must Fix):**
- Features completely non-functional
- Severe performance degradation
- Memory leaks causing crashes
- Audio completely broken

**MEDIUM (Should Fix):**
- Minor functionality issues
- Occasional glitches
- Performance below target but acceptable
- UI/UX problems

**LOW (Nice to Fix):**
- Cosmetic issues
- Rare edge cases
- Minor optimizations possible
- Documentation improvements

---

## 6. Success Criteria

### Phase-by-Phase Success Gates

#### Phase 1: Pre-Fix Validation

**SUCCESS When:**
- [x] All automated tests build successfully
- [x] Baseline documentation is complete
- [x] Device baseline established (if available)
- [x] Known issues are documented
- [x] Risk assessment is complete

**FAIL If:**
- Unable to build test suite
- No baseline can be established
- Device is unavailable for critical fixes

#### Phase 2: Incremental Testing

**SUCCESS When:**
- [x] Each change passes syntax validation
- [x] Each change builds successfully
- [x] Each change passes affected test
- [x] No regressions introduced
- [x] Changes are documented

**FAIL If:**
- Syntax errors in any change
- Build failures in any test
- Test failures in affected area
- Undocumented changes

#### Phase 3: Regression Testing

**SUCCESS When:**
- [x] All 7 tests build successfully
- [x] All 7 tests pass on device
- [x] No cross-subsystem issues
- [x] Performance within targets
- [x] No new bugs introduced

**FAIL If:**
- Any test fails to build
- Any test fails on device
- Performance below targets
- New regressions detected

#### Phase 4: Performance Testing

**SUCCESS When:**
- [x] Frame rate >= 55 FPS average
- [x] Memory stable (no leaks > 1KB)
- [x] Startup time < 2 seconds
- [x] Input latency < 50ms
- [x] Stress tests pass

**FAIL If:**
- Frame rate < 50 FPS minimum
- Memory leaks detected
- Startup time > 3 seconds
- Input latency > 100ms
- Stress tests fail

#### Phase 5: Device Testing

**SUCCESS When:**
- [x] All tests deploy successfully
- [x] All tests execute without crash
- [x] All features work correctly
- [x] Quality metrics met
- [x] Extended run stable

**FAIL If:**
- Any test crashes on device
- Features non-functional
- Quality issues (severe)
- Instability during extended run

### Overall Success Criteria

**Fix is Approved When:**

1. **Functional Requirements:**
   - [x] Original bug is fixed
   - [x] Fix solves the reported issue
   - [x] No workarounds needed
   - [x] Edge cases handled

2. **Quality Requirements:**
   - [x] Code follows SDK standards
   - [x] Documentation is updated
   - [x] Examples are accurate
   - [x] No technical debt introduced

3. **Performance Requirements:**
   - [x] Frame rate meets targets
   - [x] Memory usage is stable
   - [x] No performance regressions
   - [x] Resource usage is efficient

4. **Stability Requirements:**
   - [x] All tests pass
   - [x] No regressions detected
   - [x] Extended run stable
   - [x] Device testing successful

5. **Compliance Requirements:**
   - [x] SDK rules followed
   - [x] Validation framework compliant
   - [x] Project structure correct
   - [x] Build process works

### Sign-Off Requirements

**Before marking fix as complete:**

**Developer Sign-Off:**
- [x] All phases completed
- [x] Documentation updated
- [x] Code reviewed
- [x] Tests added/updated
- [x] Ready for review

**Reviewer Sign-Off:**
- [x] Fix verified effective
- [x] No regressions found
- [x] Code quality acceptable
- [x] Documentation adequate
- [x] Performance validated

**Device Tester Sign-Off:**
- [x] Device testing passed
- [x] All features verified
- [x] No issues found
- [x] Stable operation confirmed
- [x] Ready for deployment

---

## 7. Rollback Procedures

### When to Rollback

**Immediate Rollback Triggers:**
- Device crashes or freezes
- Data corruption occurs
- Security vulnerability introduced
- Hardware damage potential
- Critical feature completely broken

**Evaluated Rollback Triggers:**
- Performance degradation > 20%
- Multiple test failures
- Significant regressions
- Memory leaks detected
- Unstable behavior

### Rollback Process

#### Level 1: Code Rollback (Single File)

**When:** One file change caused issues

**Steps:**
```bash
# 1. Identify problematic file
# Check test failures to isolate issue

# 2. Revert single file
git checkout HEAD -- path/to/problematic_file.lua

# 3. Rebuild affected test
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
python packer.py \
    --projectdir ../../examples/tests \
    --appname test_affected \
    --meta ../../examples/tests/test_affected_metadata.json \
    --sdkversion 1.0.0 \
    --icon ../../examples/tests/icon.bmp

# 4. Verify fix resolved
python send.py \
    --func send \
    --localfile build/test_affected.vmupack \
    --remotefile apps/test_affected.vmupack \
    --comport COM3 \
    --exec \
    --monitor

# 5. Document rollback
```

**Rollback Documentation:**
```markdown
## Rollback - [DATE]

**File:** [filename]
**Reason:** [issue caused]
**Symptoms:** [what went wrong]
**Resolution:** [reverted to previous version]
**Verification:** [how verified fixed]
```

#### Level 2: Multi-File Rollback

**When:** Multiple related changes caused issues

**Steps:**
```bash
# 1. List recent changes
git log --oneline -10

# 2. Identify commit range to revert
git revert [commit_hash]..HEAD

# 3. Resolve any conflicts
# 4. Rebuild all tests
python build_all_tests.py --clean

# 5. Run full test suite
# Deploy and test all 7 tests

# 6. Document rollback
```

#### Level 3: Full Reset

**When:** Complete inability to proceed, critical issues

**Steps:**
```bash
# 1. Reset to last known good state
git reset --hard [last_good_commit]

# 2. Clean build artifacts
rm -rf build/*.vmupack

# 3. Rebuild from clean state
python build_all_tests.py --clean

# 4. Full device testing
# Run all tests on device

# 5. Document incident
```

**Incident Report Template:**
```markdown
## Major Rollback Incident - [DATE]

**Severity:** [CRITICAL/HIGH/MEDIUM/LOW]
**Impact:** [what was affected]
**Root Cause:** [why rollback was needed]
**Changes Rolled Back:** [list of changes]
**Recovery Time:** [time lost]
**Lessons Learned:** [how to prevent recurrence]
**Process Improvements:** [what to change]
```

### Rollback Verification

**After Rollback, Confirm:**
- [x] All tests build successfully
- [x] All tests pass on device
- [x] No symptoms remain
- [x] Performance restored
- [x] Stability confirmed

**Recovery Validation:**
```bash
# Run full test suite
python build_all_tests.py --clean

# Test on device
for test in test_minimal test_stage1 test_stage2 test_stage3 test_stage4 test_stage5 test_stage6; do
    python send.py --func send \
        --localfile build/${test}.vmupack \
        --remotefile apps/${test}.vmupack \
        --comport COM3 --exec --monitor
done
```

### Prevention of Future Rollbacks

**After Rollback, Analyze:**
- Why wasn't the issue caught in testing?
- Was incremental testing followed?
- Were acceptance criteria clear?
- Was device testing thorough?
- What test coverage was missing?

**Process Improvements:**
- Add new test cases for missed scenarios
- Update validation checklist
- Enhance automated testing
- Improve device testing coverage
- Update documentation

---

## 8. Testing Checklists

### Quick Reference Checklist

**For Every Fix:**

**Pre-Fix (5 minutes)**
- [ ] Document baseline
- [ ] Run build_all_tests.py
- [ ] Note known issues

**Incremental (per change)**
- [ ] Syntax check
- [ ] Build affected test
- [ ] Code review
- [ ] Deploy and verify

**Regression (after all changes)**
- [ ] Build all tests
- [ ] Deploy all tests
- [ ] Verify all pass
- [ ] Check for regressions

**Performance (if applicable)**
- [ ] Measure frame rate
- [ ] Check memory usage
- [ ] Test startup time
- [ ] Verify input latency

**Device (final gate)**
- [ ] Deploy to device
- [ ] Execute all tests
- [ ] Extended run
- [ ] Sign-off

### Comprehensive Fix Validation Checklist

**Use this checklist for complete validation:**

#### Section A: Pre-Fix Preparation
- [ ] Baseline documented
- [ ] Build status recorded
- [ ] Device baseline (if available)
- [ ] Issue clearly defined
- [ ] Success criteria defined
- [ ] Risk assessment complete

#### Section B: Code Changes
- [ ] Changes follow SDK rules
- [ ] Import syntax correct
- [ ] AppMain() pattern correct
- [ ] Input handling correct
- [ ] Display pattern correct
- [ ] Sprite cleanup included
- [ ] Audio updates included
- [ ] Frame timing correct
- [ ] Error handling present
- [ ] Comments added

#### Section C: Build Validation
- [ ] No syntax errors
- [ ] No build warnings
- [ ] All tests build
- [ ] File sizes reasonable
- [ ] No missing dependencies

#### Section D: Functional Testing
- [ ] test_minimal passes
- [ ] test_stage1 passes
- [ ] test_stage2 passes
- [ ] test_stage3 passes
- [ ] test_stage4 passes
- [ ] test_stage5 passes
- [ ] test_stage6 passes

#### Section E: Device Testing
- [ ] Deployment successful
- [ ] All tests run on device
- [ ] No crashes
- [ ] All features work
- [ ] Quality acceptable

#### Section F: Performance Validation
- [ ] Frame rate >= 55 FPS
- [ ] No memory leaks
- [ ] Startup time acceptable
- [ ] Input latency acceptable
- [ ] Stress tests pass

#### Section G: Regression Prevention
- [ ] No new bugs introduced
- [ ] No performance regressions
- [ ] No breaking changes
- [ ] Backward compatibility maintained
- [ ] Documentation updated

#### Section H: Documentation
- [ ] Code commented
- [ ] Changes documented
- [ ] Examples updated (if applicable)
- [ ] API docs updated (if applicable)
- [ ] Changelog updated
- [ ] Test results recorded

#### Section I: Sign-Off
- [ ] Developer review complete
- [ ] Peer review complete
- [ ] Device testing approved
- [ ] Performance verified
- [ ] Documentation approved
- [ ] Ready for deployment

### Bug-Specific Checklists

#### Input Bug Fix
- [ ] Input read placement verified
- [ ] Button state checks correct
- [ ] Edge detection working
- [ ] Held state working
- [ ] No multiple input reads
- [ ] Responsive on device
- [ ] All buttons tested

#### Display Bug Fix
- [ ] Clear/refresh pattern correct
- [ ] No multiple clears
- [ ] No multiple refreshes
- [ ] Drawing order correct
- [ ] Colors accurate
- [ ] No artifacts
- [ ] Frame rate smooth

#### Audio Bug Fix
- [ ] Audio lifecycle correct
- [ ] startListenMode called
- [ ] exitListenMode called
- [ ] sound.update every frame
- [ ] Sound loading verified
- [ ] Playback works
- [ ] No distortion
- [ ] Cleanup verified

#### Sprite Bug Fix
- [ ] Sprites load correctly
- [ ] Sprite draw calls present
- [ ] Scene management correct
- [ ] Cleanup on exit
- [ ] No memory leaks
- [ ] Collision detection (if applicable)
- [ ] Animation updates (if applicable)

#### Memory Bug Fix
- [ ] Resources freed
- [ ] removeAll called
- [ ] No leaks in loops
- [ ] Proper cleanup order
- [ ] Memory usage stable
- [ ] No excessive allocations
- [ ] Free blocks adequate

#### Performance Bug Fix
- [ ] Inefficient loops optimized
- [ ] Unnecessary calls removed
- [ ] Object pooling (if needed)
- [ ] Frame time improved
- [ ] Memory usage reduced
- [ ] No new bottlenecks
- [ ] Smooth operation

---

## Appendix A: Command Reference

### Build Commands

```bash
# Build all tests
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
python build_all_tests.py

# Clean build all tests
python build_all_tests.py --clean

# Build single test
python packer.py \
    --projectdir ../../examples/tests \
    --appname test_name \
    --meta ../../examples/tests/test_name_metadata.json \
    --sdkversion 1.0.0 \
    --icon ../../examples/tests/icon.bmp
```

### Deployment Commands

```bash
# Deploy to device
python send.py \
    --func send \
    --localfile build/test_name.vmupack \
    --remotefile apps/test_name.vmupack \
    --comport COM3

# Deploy and execute
python send.py \
    --func send \
    --localfile build/test_name.vmupack \
    --remotefile apps/test_name.vmupack \
    --comport COM3 \
    --exec

# Deploy and monitor
python send.py \
    --func send \
    --localfile build/test_name.vmupack \
    --remotefile apps/test_name.vmupack \
    --comport COM3 \
    --exec \
    --monitor
```

### Diagnostic Commands

```bash
# Check device connectivity
python send.py --func ping --comport COM3

# List files on device
python send.py --func list --remotefile apps/ --comport COM3

# Delete file from device
python send.py --func delete --remotefile apps/test_name.vmupack --comport COM3

# Check Lua syntax
lua -e "dofile('path/to/file.lua')"
```

---

## Appendix B: Test Reference

### Test Matrix

| Test | Purpose | Duration | Mode | Interactive | Key Features |
|------|---------|----------|------|-------------|--------------|
| test_minimal | Basic structure | ~1s | 1 | No | Entry point, display init |
| test_stage1 | Display & graphics | ~8s | 1 | No | Primitives, colors, text |
| test_stage2 | Input handling | ~5s | 3 | Yes | All buttons, states |
| test_stage3 | Sprite system | ~5s | 3 | Yes | Load, position, render |
| test_stage4 | Audio system | ~5s | 3 | Yes | Load, play, stop |
| test_stage5 | Memory & system | ~5s | 1 | No | Memory, time, logging |
| test_stage6 | Full integration | ~15s | 3 | Yes | All systems combined |

### Expected Behavior Reference

**test_minimal:**
- Display: "Hello, VMU Pro!" for 1 second
- Exit: Returns 0 after 1 second
- Memory: Minimal usage
- Frame rate: N/A (static display)

**test_stage1:**
- Phase 1: Clear screen (0.5s)
- Phase 2: Draw text (1s)
- Phase 3: Draw pixels (1s)
- Phase 4: Draw lines (1s)
- Phase 5: Draw rectangles (1s)
- Phase 6: Draw circles (1s)
- Phase 7: Draw polygons (1s)
- Phase 8: Flood fill (1s)
- Phase 9: End screen (0.5s)
- Total: ~8 seconds

**test_stage2:**
- Display current button states
- Update in real-time
- Press any button to see state change
- B button exits
- Shows: pressed, released, held states

**test_stage3:**
- Display sprite at center
- D-pad moves sprite
- Rectangle shows collision area
- B button exits
- Clean up sprites on exit

**test_stage4:**
- Load sound at startup
- Display instructions
- A button: Play sound
- B button: Stop sound + Exit
- Audio update every frame

**test_stage5:**
- Display memory usage
- Update every second
- Show system time
- Display frame count
- Log at various levels
- B button exits

**test_stage6:**
- Full Tamagotchi game
- D-pad: Move cursor
- A button: Select action
- B button: Back/Exit
- Multiple game states
- All subsystems active

---

## Appendix C: Troubleshooting

### Common Issues and Solutions

**Issue: Build fails with "file not found"**
- Check file paths in packer command
- Verify test files exist in examples/tests/
- Check metadata filename

**Issue: Device won't connect**
- Check COM port number
- Verify USB cable is data cable (not charge-only)
- Try different USB port
- Check device is powered on

**Issue: App crashes on startup**
- Check AppMain() exists and returns number
- Verify all imports are correct
- Check for syntax errors
- Review device logs

**Issue: Display flickers**
- Check for multiple refresh() calls
- Verify clear/refresh pattern
- Check frame timing

**Issue: Input not responding**
- Verify input.read() called before checks
- Check button constants
- Verify game loop structure

**Issue: Audio doesn't play**
- Verify startListenMode() called
- Check sound.update() every frame
- Verify sound file loaded
- Check audio volume

**Issue: Memory usage increasing**
- Check for missing cleanup
- Verify removeAll() called
- Check for resource leaks
- Profile with getMemoryUsage()

**Issue: Frame rate drops**
- Profile with getTimeUs()
- Check for inefficient loops
- Reduce object creation
- Optimize drawing calls

---

## Appendix D: Validation Templates

### Pre-Fix Baseline Template

```markdown
# Pre-Fix Baseline - [Issue Title]

**Date:** YYYY-MM-DD
**Issue:** [Description]
**Developer:** [Name]

## Build Status
| Test | Status | Notes |
|------|--------|-------|
| test_minimal | | |
| test_stage1 | | |
| test_stage2 | | |
| test_stage3 | | |
| test_stage4 | | |
| test_stage5 | | |
| test_stage6 | | |

## Device Baseline
- Device Firmware: [version]
- Connection: [COM port]
- Test Results: [observations]

## Known Issues
1. [Issue 1]
2. [Issue 2]

## Success Criteria
The fix is successful when:
- [Criterion 1]
- [Criterion 2]
```

### Change Log Template

```markdown
# Change Log - [Fix/Feature]

**Date:** YYYY-MM-DD
**Developer:** [Name]
**Files Modified:** [list]

## Changes Made

### [File 1]
- **Lines:** X-Y
- **Change:** [description]
- **Reason:** [why]
- **Impact:** [what affected]

### [File 2]
- **Lines:** X-Y
- **Change:** [description]
- **Reason:** [why]
- **Impact:** [what affected]

## Validation
- Syntax: [PASS/FAIL]
- Build: [PASS/FAIL]
- Tests: [PASS/FAIL]
- Device: [PASS/FAIL]

## Results
[Summary of results]

## Next Steps
[What to do next]
```

### Test Results Template

```markdown
# Test Results - [Test Name]

**Date:** YYYY-MM-DD
**Developer:** [Name]
**Test:** [test_name]

## Build
- Status: [PASS/FAIL]
- Output: [build output]
- File Size: [bytes]

## Deployment
- Transfer: [PASS/FAIL]
- Time: [seconds]
- Device: [COM port]

## Execution
- Start: [PASS/FAIL]
- Run: [PASS/FAIL]
- Exit: [PASS/FAIL]
- Duration: [seconds]

## Functional
- Features: [list what works]
- Issues: [list any issues]

## Performance
- Frame Rate: [FPS]
- Memory: [bytes]
- Startup: [ms]

## Verdict: [PASS/FAIL]
```

---

## Protocol Version

**Version:** 1.0.0
**Last Updated:** 2025-01-05
**Author:** VMU Pro SDK Team
**Status:** Active

## Change History

**v1.0.0 (2025-01-05)**
- Initial protocol creation
- Comprehensive validation framework
- Device testing procedures
- Rollback procedures
- Templates and checklists

---

## Quick Decision Guide

**Should I proceed to next phase?**

- **Pre-Fix → Incremental:** YES when baseline documented
- **Incremental Change 1 → 2:** YES when current change validated
- **Incremental → Regression:** YES when all changes complete
- **Regression → Performance:** YES when all tests pass
- **Performance → Device:** YES when performance acceptable
- **Device → Sign-Off:** YES when all device tests pass

**Should I rollback?**

- **Immediate Rollback:** YES if device crashes, data corruption, security issue
- **Evaluated Rollback:** Consider if performance >20% worse, multiple failures
- **Continue with Issues:** Only if issues are minor, documented, and acceptable

---

## Conclusion

This protocol provides a comprehensive framework for validating fixes to the VMU Pro LUA SDK. By following these procedures systematically, developers can ensure that changes are effective, don't introduce regressions, maintain performance, and work correctly on actual devices.

**Key Principles:**
1. Document everything
2. Test incrementally
3. Validate thoroughly
4. Monitor performance
5. Test on real hardware
6. Be prepared to rollback
7. Learn from mistakes

**Success comes from discipline in following the protocol, not cutting corners, and validating at each step.**
