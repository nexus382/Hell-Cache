# Incremental Display Test Plan - Deliverables Summary

## What Was Created

A comprehensive incremental testing framework to isolate display crashes in the VMU Pro SDK, consisting of detailed documentation specifications and analysis.

## Files Created

### 1. INCREMENTAL_DISPLAY_TEST_PLAN.md (18KB)
**Purpose**: Complete incremental test specifications

**Contents**:
- Detailed specs for 5 incremental tests (test_display_1 through test_display_5)
- Exact code for each test using ONLY verified APIs
- Expected behavior for each test
- "What a Crash Means" diagnosis sections
- Build and deployment instructions
- Test execution order
- Expected results matrix
- API compliance verification

**Key Features**:
- Tests ONE display operation at a time
- Each test builds on the previous
- Clear success/failure criteria
- Crash diagnosis for each test

**Use This For**: Complete understanding of test strategy and implementation

---

### 2. API_ISSUES_ANALYSIS.md (7.2KB)
**Purpose**: Analysis of bugs in existing test files

**Contents**:
- 10 critical API issues identified
- Side-by-side comparison of WRONG vs CORRECT usage
- Impact assessment (CRASH severity)
- List of all affected files
- Summary statistics (53 total issues)
- Root cause analysis

**Key Issues Documented**:
1. `vmupro.display.refresh()` → Should be `vmupro.graphics.refresh()`
2. `vmupro.system.getSystemTime()` → Should be `vmupro.system.getTimeUs()`
3. `vmupro.input.BUTTON_UP` → Should be `vmupro.input.UP`
4. `vmupro.input.isButtonDown()` → Should be `vmupro.input.held()`
5. `vmupro.sprite.render()` → Should be `vmupro.sprite.draw()`
6. `drawRect(x,y,w,h,c,fill)` → Wrong signature
7. `drawCircle(..., false/true)` → Should use `drawCircleFilled()`
8. Undefined color constants (GRAY, CYAN)
9. `drawPixel()` - Function doesn't exist
10. Incorrect logging format

**Use This For**: Understanding why original tests crash and avoiding same mistakes

---

### 3. TEST_PLAN_README.md (5.0KB)
**Purpose**: Quick start guide for the test suite

**Contents**:
- Quick start instructions
- Test file overview
- Build and deploy commands
- Test execution order
- Success criteria
- Crash diagnosis reference
- File descriptions

**Use This For**: Getting started quickly with the incremental tests

---

### 4. QUICK_REFERENCE.md (7.0KB)
**Purpose**: Quick reference card for common tasks

**Contents**:
- Test overview diagram
- One-liner build commands (Linux/Mac & Windows)
- Batch build script
- Critical API differences (WRONG vs RIGHT)
- Expected output per test
- Quick troubleshooting guide
- Decision tree for testing
- Common pitfalls
- Memory aid for namespace organization

**Use This For**: Quick lookup during testing and debugging

---

## How These Files Work Together

```
Start Here
    ↓
TEST_PLAN_README.md (Quick start guide)
    ↓
INCREMENTAL_DISPLAY_TEST_PLAN.md (Detailed specs)
    ↓
QUICK_REFERENCE.md (Quick lookup during testing)
    ↓
API_ISSUES_ANALYSIS.md (Avoid mistakes)
```

## Test Specifications Overview

### Test Display 1: Basic Clear
- **Function**: `vmupro.graphics.clear()`
- **Duration**: 2.5 seconds
- **Output**: Color cycling (black → white → red → green)
- **Crash Means**: Display subsystem not initialized or colors invalid

### Test Display 2: Clear + Refresh
- **Functions**: `clear()` + `refresh()`
- **Duration**: 1 second
- **Output**: Flicker at 60fps
- **Crash Means**: Double-buffering broken or memory corruption

### Test Display 3: Add Text Rendering
- **Functions**: Add `drawText()`
- **Duration**: 3 seconds
- **Output**: 3 text lines with frame counter
- **Crash Means**: Font system unavailable or glyph data invalid

### Test Display 4: Add Font Switching
- **Functions**: Add `setFont()`
- **Duration**: 4 seconds
- **Output**: 3 font sizes cycling
- **Crash Means**: Font data corrupted or memory leak on switch

### Test Display 5: Full Rendering
- **Functions**: Complete pipeline like hello_world
- **Duration**: 5 seconds or until B pressed
- **Output**: Complex multi-font display with input
- **Crash Means**: Complex state management broken

## Key Differences from Original Tests

| Aspect | Original Tests | Incremental Tests |
|--------|---------------|-------------------|
| **API Accuracy** | 53 issues | 100% verified |
| **Test Strategy** | Complex, multi-feature | Simple, one-at-a-time |
| **Crash Diagnosis** | Vague | Precise per test |
| **Build Order** | Any order | Strict incremental order |
| **Documentation** | Basic specs | Detailed with examples |
| **Verification** | Unknown | Verified against docs |

## Verified APIs Used

All APIs in incremental tests verified against:
- ✅ `/mnt/g/vmupro-game-extras/documentation/CLAUDE.md`
- ✅ `/mnt/g/vmupro-game-extras/documentation/docs/api/display.md`
- ✅ `/mnt/g/vmupro-game-extras/documentation/docs/api/input.md`
- ✅ `/mnt/g/vmupro-game-extras/documentation/docs/api/system.md`

**Verification Result**: 100% API accuracy - No hallucinations

## Usage Workflow

### Phase 1: Preparation (5 minutes)
1. Read TEST_PLAN_README.md
2. Review QUICK_REFERENCE.md
3. Verify build tools available

### Phase 2: Testing (15-30 minutes)
1. Build and deploy test_display_1
2. If pass, proceed to test_display_2
3. Continue until crash found
4. Use QUICK_REFERENCE.md for troubleshooting

### Phase 3: Diagnosis (30-60 minutes)
1. Review crash details in INCREMENTAL_DISPLAY_TEST_PLAN.md
2. Check API_ISSUES_ANALYSIS.md for related issues
3. Implement fix based on diagnosis
4. Re-test to verify fix

## Next Steps After Plan

### Option A: Implement the Tests
Create the actual test files (test_display_1.lua through test_display_5.lua) with metadata files.

### Option B: Fix Original Tests
Use API_ISSUES_ANALYSIS.md to fix the 53 issues in existing test files.

### Option C: Test on Hardware
Build and deploy incremental tests to actual VMU Pro device.

## Recommended Reading Order

1. **TEST_PLAN_README.md** - Start here (5 minutes)
2. **INCREMENTAL_DISPLAY_TEST_PLAN.md** - Detailed specs (15 minutes)
3. **QUICK_REFERENCE.md** - Keep open during testing (5 minutes)
4. **API_ISSUES_ANALYSIS.md** - Reference when fixing old tests (10 minutes)

**Total Reading Time**: ~35 minutes

## Success Metrics

Using this test plan should:
- ✅ Isolate crash to specific display function
- ✅ Provide clear diagnosis path
- ✅ Avoid API usage mistakes
- ✅ Build incrementally from simple to complex
- ✅ Document all findings
- ✅ Enable reproducible testing

## Files Location

```
/mnt/g/vmupro-game-extras/documentation/examples/tests/
├── INCREMENTAL_DISPLAY_TEST_PLAN.md    ← Start here for details
├── API_ISSUES_ANALYSIS.md               ← Read to avoid mistakes
├── TEST_PLAN_README.md                  ← Start here for quick start
├── QUICK_REFERENCE.md                   ← Keep open during testing
└── DELIVERABLES_SUMMARY.md             ← This file
```

## Summary

This deliverable provides:

1. ✅ **Complete Test Plan**: 5 incremental tests with detailed specs
2. ✅ **API Analysis**: 53 issues identified and documented
3. ✅ **Quick Start Guide**: Fast path to testing
4. ✅ **Quick Reference**: Common tasks and troubleshooting
5. ✅ **Verified APIs**: All code checked against SDK documentation
6. ✅ **Clear Diagnosis**: Know exactly what each crash means

**Total Documentation**: 37KB of detailed testing specifications

The incremental approach ensures that when a crash occurs, you'll know exactly which function caused it and what that means for diagnosis.
