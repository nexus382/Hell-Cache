# VMU Pro SDK - Validation Protocol Integration Guide

## Overview

This guide explains how to integrate the validation protocol into your daily development workflow. It provides practical scenarios and step-by-step procedures for common tasks.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Common Scenarios](#common-scenarios)
3. [Daily Workflow Integration](#daily-workflow-integration)
4. [Team Collaboration](#team-collaboration)
5. [Continuous Improvement](#continuous-improvement)

---

## Quick Start

### First Time Setup

**Step 1: Create Your Workspace**
```bash
# Navigate to validation tools
cd /mnt/g/vmupro-game-extras/documentation/tools/packer

# Create output directory
mkdir -p build
mkdir -p validation_logs

# Verify tools work
python build_all_tests.py --help
```

**Step 2: Establish Baseline**
```bash
# Build all tests to verify environment
python build_all_tests.py --clean

# Document results
echo "## Baseline $(date)" > validation_logs/baseline.md
python build_all_tests.py >> validation_logs/baseline.md
```

**Step 3: Quick Reference**
```bash
# Print quick reference for your terminal
cat docs/rules/verification/VALIDATION_QUICK_REF.md
```

---

## Common Scenarios

### Scenario 1: Fixing a Bug in Documentation

**Context:** You found incorrect API usage in a code example.

**Workflow:**

**Phase 1: Pre-Fix (2 minutes)**
```bash
# 1. Document the issue
cat > validation_logs/bug_fix_$(date +%Y%m%d).md << 'EOF'
# Bug Fix - Incorrect API Usage

**Date:** $(date)
**Issue:** Example uses require() instead of import
**Location:** docs/examples/sample_code.md line 45
**Impact:** Code won't work on device

**Current State:**
- Example compiles? NO
- Example runs on device? NO
EOF

# 2. Build tests to confirm environment
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
python build_all_tests.py | tee -a validation_logs/bug_fix_$(date +%Y%m%d).md
```

**Phase 2: Incremental Fix (5 minutes)**
```bash
# 1. Make the change (edit documentation file)
# Change: require("api/system") → import "api/system"

# 2. Validate syntax (if code example)
lua -e "import 'api/system'"  # Quick check

# 3. Build affected test
python packer.py \
    --projectdir ../../examples/tests \
    --appname test_minimal \
    --meta ../../examples/tests/test_minimal_metadata.json \
    --sdkversion 1.0.0 \
    --icon ../../examples/tests/icon.bmp

# 4. Document the change
cat >> validation_logs/bug_fix_$(date +%Y%m%d).md << 'EOF'

## Change Made
**File:** docs/examples/sample_code.md
**Line:** 45
**Change:** require("api/system") → import "api/system"
**Reason:** Correct SDK import syntax
**Validation:** Syntax OK, Build OK
EOF
```

**Phase 3: Regression Test (2 minutes)**
```bash
# 1. Build all tests
python build_all_tests.py --clean

# 2. Verify no regressions
# Check that all 7 tests built successfully

# 3. Document results
echo "## Regression: PASS - All tests built" >> validation_logs/bug_fix_$(date +%Y%m%d).md
```

**Phase 4: Device Test (5 minutes)**
```bash
# 1. Deploy to device
python send.py \
    --func send \
    --localfile build/test_minimal.vmupack \
    --remotefile apps/test_minimal.vmupack \
    --comport COM3 --exec --monitor

# 2. Verify it works
# Should see "Hello, VMU Pro!" on device

# 3. Document
echo "## Device Test: PASS" >> validation_logs/bug_fix_$(date +%Y%m64).md
```

**Phase 5: Complete**
```bash
# Sign-off
echo "## Status: COMPLETE - Bug fixed, tested, documented" >> validation_logs/bug_fix_$(date +%Y%m%d).md
```

**Total Time:** ~15 minutes

---

### Scenario 2: Adding a New Test

**Context:** You need to test a new feature or edge case.

**Workflow:**

**Step 1: Plan the Test**
```bash
# Create test specification
cat > validation_logs/new_test_plan.md << 'EOF'
# New Test: [Feature Name]

**Purpose:** What this test validates
**Duration:** Estimated runtime
**Dependencies:** Required resources
**Risk:** What could go wrong

## Test Coverage
- Feature 1
- Feature 2
- Edge case 1
- Edge case 2

## Success Criteria
- [ ] Specific behavior verified
- [ ] No crashes
- [ ] Performance acceptable
EOF
```

**Step 2: Create Test File**
```bash
# Use existing test as template
cp /mnt/g/vmupro-game-extras/documentation/examples/tests/test_minimal.lua \
   /mnt/g/vmupro-game-extras/documentation/examples/tests/test_new_feature.lua

# Edit test_new_feature.lua to implement your test
# Follow validation-framework.md patterns
```

**Step 3: Create Metadata**
```bash
# Copy metadata template
cp /mnt/g/vmupro-game-extras/documentation/examples/tests/test_minimal_metadata.json \
   /mnt/g/vmupro-game-extras/documentation/examples/tests/test_new_feature_metadata.json

# Edit metadata.json for your test
```

**Step 4: Build and Test**
```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer

# Build new test
python packer.py \
    --projectdir ../../examples/tests \
    --appname test_new_feature \
    --meta ../../examples/tests/test_new_feature_metadata.json \
    --sdkversion 1.0.0 \
    --icon ../../examples/tests/icon.bmp

# Deploy to device
python send.py \
    --func send \
    --localfile test_new_feature.vmupack \
    --remotefile apps/test_new_feature.vmupack \
    --comport COM3 --exec --monitor
```

**Step 5: Add to Build Suite**
```bash
# Edit build_all_tests.py
# Add test to TESTS array

# Verify it integrates
python build_all_tests.py --clean
```

---

### Scenario 3: Performance Investigation

**Context:** App is running slowly, need to identify bottleneck.

**Workflow:**

**Step 1: Profile the Problem**
```lua
-- Add profiling to your app
local profile_start = vmupro.system.getTimeUs()

-- ... code to profile ...

local profile_end = vmupro.system.getTimeUs()
local profile_time_us = profile_end - profile_start
local profile_time_ms = profile_time_us / 1000

vmupro.system.log(vmupro.system.LOG_INFO, "Profile",
    string.format("Function took %.2f ms", profile_time_ms))
```

**Step 2: Measure Baseline**
```bash
# Build and deploy
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
python packer.py [...]  # Build app
python send.py [...]     # Deploy to device

# Monitor logs for profiling data
# Record baseline times
```

**Step 3: Identify Bottleneck**

**Common bottlenecks:**
- Multiple `vmupro.graphics.refresh()` calls → Fix to single call
- Creating objects in loops → Move outside loop
- Inefficient sprite rendering → Use sprite.add() and drawAll()
- Missing frame timing → Add delayMs()
- Excessive logging → Reduce log calls

**Step 4: Apply Fix Incrementally**
```bash
# Make ONE optimization
# Rebuild and redeploy
# Measure improvement
# Repeat until acceptable
```

**Step 5: Validate**
```bash
# Ensure fix didn't break functionality
# Run all tests
# Verify performance improved
# Document results
```

---

### Scenario 4: Regression Investigation

**Context:** A test that used to pass is now failing.

**Workflow:**

**Step 1: Isolate the Problem**
```bash
# What test is failing?
# When did it last pass?
# What changed since then?

git log --oneline --all -20  # Recent commits
```

**Step 2: Bisect to Find Bad Commit**
```bash
git bisect start
git bisect bad  # Current broken state
git bisect good [last_known_good_commit]

# Git will checkout a commit
# Build and test
# Mark as good or bad

git bisect good  # or git bisect bad

# Repeat until found
git bisect reset
```

**Step 3: Analyze the Bad Commit**
```bash
# What changed?
git show [bad_commit_hash]

# Why did it break?
# Understand the root cause
```

**Step 4: Fix the Issue**
```bash
# Apply fix following incremental testing
# Document the fix
# Add regression test if applicable
```

---

### Scenario 5: Emergency Rollback

**Context:** Critical issue found in production code.

**Workflow:**

**Step 1: Assess Severity (30 seconds)**
```bash
# Is it critical?
- Device crashes? → YES → Immediate rollback
- Data corruption? → YES → Immediate rollback
- Security issue? → YES → Immediate rollback
- Feature broken? → EVALUATE
- Performance bad? → EVALUATE
```

**Step 2: Immediate Rollback (if critical)**
```bash
# Revert the change
git revert [bad_commit_hash]

# Clean rebuild
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
rm -rf build/*.vmupack
python build_all_tests.py --clean

# Verify rollback works
# Deploy and test on device
```

**Step 3: Document Incident**
```bash
cat > validation_logs/incident_$(date +%Y%m%d_%H%M%S).md << 'EOF'
# Incident Report - [Date/Time]

**Severity:** CRITICAL
**Impact:** [What broke]
**Root Cause:** [Why]
**Actions Taken:** [Rollback performed]
**Recovery Time:** [Minutes]
**Prevention:** [How to prevent recurrence]
EOF
```

**Step 4: Plan Proper Fix**
```bash
# Now that system is stable
# Plan fix using full validation protocol
# Don't rush - do it right
```

---

## Daily Workflow Integration

### Morning Startup Routine

**5-Minute Daily Check:**
```bash
#!/bin/bash
# daily_check.sh

echo "=== Daily Validation Check - $(date) ==="

# 1. Check git status
echo "Git Status:"
git status --short

# 2. Build all tests
echo "Building tests..."
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
python build_all_tests.py --skip-existing

# 3. Check for issues
echo "Recent validation logs:"
ls -lt validation_logs/ | head -5

# 4. Device quick check (optional)
echo "Device connectivity:"
python send.py --func ping --comport COM3

echo "=== Check Complete ==="
```

### Pre-Commit Routine

**Before committing any code:**
```bash
#!/bin/bash
# pre_commit_check.sh

echo "=== Pre-Commit Validation ==="

# 1. Syntax check all Lua files
echo "Checking syntax..."
find . -name "*.lua" -exec lua -e "dofile('{}')" \; 2>&1 | grep -i error

if [ $? -ne 0 ]; then
    echo "SYNTAX ERRORS FOUND - Commit aborted"
    exit 1
fi

# 2. Build affected tests
echo "Building tests..."
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
python build_all_tests.py

if [ $? -ne 0 ]; then
    echo "BUILD FAILED - Commit aborted"
    exit 1
fi

# 3. Run quick device test (optional)
echo "Quick device test..."
python send.py --func send \
    --localfile build/test_minimal.vmupack \
    --remotefile apps/test_minimal.vmupack \
    --comport COM3 --exec --monitor

echo "=== Pre-Commit Complete - Safe to commit ==="
```

### End-of-Day Routine

**5-Minute End-of-Day:**
```bash
#!/bin/bash
# end_of_day.sh

echo "=== End of Day Summary - $(date) ==="

# 1. What was done today
echo "Today's commits:"
git log --since="today" --oneline

# 2. What's pending
echo "Uncommitted changes:"
git status --short

# 3. Test status
echo "Test build status:"
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
ls -lh build/*.vmupack | wc -l
echo "tests built"

# 4. Issues found
echo "Recent issues:"
grep -r "FAIL\|ERROR\|BUG" validation_logs/ 2>/dev/null | tail -5

# 5. Tomorrow's plan
echo ""
echo "Tomorrow's priorities:"
echo "1. [List top priority]"
echo "2. [List second priority]"
echo "3. [List third priority]"

echo "=== End of Day ==="
```

---

## Team Collaboration

### Code Review Integration

**When submitting code for review:**

**1. Create Validation Summary**
```markdown
# Validation Summary - [PR Title]

## Changes Made
- [File 1]: [Brief description]
- [File 2]: [Brief description]

## Testing Performed
- [x] Syntax validation
- [x] Build verification
- [x] Unit tests
- [x] Device testing
- [x] Performance check

## Test Results
| Test | Result | Notes |
|------|--------|-------|
| test_minimal | PASS | - |
| test_stage1 | PASS | - |
| test_stage2 | PASS | - |

## Performance Impact
- Frame rate: [Before] → [After]
- Memory: [Before] → [After]
- Startup: [Before] → [After]

## Known Issues
- [List any known issues or limitations]

## Review Focus Areas
- [Specific areas to review]
```

**2. Link to Validation Logs**
```markdown
## Validation Artifacts
- Build logs: [link or file path]
- Device test results: [link or file path]
- Performance measurements: [link or file path]
- Change log: validation_logs/change_[date].md
```

### Pair Programming Protocol

**When working in pairs:**

**Driver (Typing):**
- Makes incremental changes
- Runs validation after each change
- Calls out test results

**Navigator (Reviewing):**
- Has validation protocol open
- Checks each step against protocol
- Catches missed validations

**Switch roles every 30 minutes**

### Knowledge Sharing

**Weekly Validation Review:**
```bash
# Weekly review script
cat > weekly_review.md << 'EOF'
# Weekly Validation Review - [Week Of]

## What We Fixed
- [Bug 1]: [Resolution]
- [Bug 2]: [Resolution]

## What We Improved
- [Feature 1]: [Improvement]
- [Performance 1]: [Gain]

## Issues Found
- [Issue 1]: [Status]
- [Issue 2]: [Status]

## Validation Metrics
- Total fixes validated: [count]
- Rollbacks performed: [count]
- Average time per fix: [hours]
- Device tests run: [count]

## Lessons Learned
1. [Lesson 1]
2. [Lesson 2]

## Process Improvements
- [Improvement 1]
- [Improvement 2]
EOF
```

---

## Continuous Improvement

### Metrics to Track

**Track weekly:**
```markdown
## Validation Metrics Dashboard

### Velocity
- Fixes completed: [count]
- Average fix time: [hours]
- Rollbacks: [count]

### Quality
- Bugs found in prod: [count]
- Test pass rate: [%]
- Device test failures: [count]

### Process
- Protocol violations: [count]
- Missing documentation: [count]
- Skipped validations: [count]
```

### Process Evolution

**Review protocol monthly:**
```markdown
## Protocol Review - [Month]

### What's Working Well
- [Process 1]: [Why it works]
- [Process 2]: [Why it works]

### What Needs Improvement
- [Issue 1]: [Proposed fix]
- [Issue 2]: [Proposed fix]

### Protocol Updates
- [Section 1]: [Change]
- [Section 2]: [Change]

### Action Items
- [ ] [Action 1]
- [ ] [Action 2]
```

### Automation Opportunities

**Automate when possible:**
```bash
# Automated validation script
cat > auto_validate.sh << 'EOF'
#!/bin/bash
# Run all validations automatically

ERRORS=0

# Syntax check
echo "Syntax validation..."
find . -name "*.lua" -exec lua -e "dofile('{}')" \; 2>&1 | tee syntax.log
if grep -q "error" syntax.log; then
    echo "FAIL: Syntax errors found"
    ERRORS=$((ERRORS+1))
fi

# Build check
echo "Build validation..."
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
python build_all_tests.py 2>&1 | tee build.log
if grep -q "ERROR\|FAIL" build.log; then
    echo "FAIL: Build errors found"
    ERRORS=$((ERRORS+1))
fi

# Report
if [ $ERRORS -eq 0 ]; then
    echo "All validations PASSED"
    exit 0
else
    echo "$ERRORS validation(s) FAILED"
    exit 1
fi
EOF

chmod +x auto_validate.sh
```

---

## Troubleshooting Common Workflow Issues

### Issue: "I Don't Have Time for Full Protocol"

**Solution:** Use the quick reference
- Focus on critical validations
- Skip nice-to-have items
- Document retroactively

**Minimum viable validation:**
1. Syntax check (30 seconds)
2. Build test (1 minute)
3. Device test (2 minutes)

### Issue: "Protocol is Too Complex"

**Solution:** Start simple, add complexity gradually
- Start with basic checklist
- Add phases as needed
- Use templates for consistency

### Issue: "Forgetting to Validate"

**Solution:** Make it automatic
- Add to git pre-commit hook
- Set up daily reminders
- Use scripts for routine tasks

**Git Hook Example:**
```bash
# .git/hooks/pre-commit
#!/bin/bash
echo "Running pre-commit validation..."
./pre_commit_check.sh
if [ $? -ne 0 ]; then
    echo "Validation failed - commit aborted"
    echo "Use --no-verify to bypass (not recommended)"
    exit 1
fi
```

### Issue: "Device Not Available"

**Solution:** Prioritize device testing
- Build and validate without device first
- Schedule device testing for later
- Use remote testing if possible
- Document device testing as TODO

---

## Best Practices Summary

### DO:
- Follow the protocol for every fix
- Document everything
- Test incrementally
- Validate on device
- Know when to rollback
- Learn from mistakes
- Share knowledge with team

### DON'T:
- Skip validation for "small" changes
- Batch multiple changes without testing
- Deploy without device testing
- Ignore performance regression
- Rollback without documenting
- Repeat the same mistakes
- Work in isolation

---

## Quick Decision Flowchart

```
                     Need to make a change?
                           |
                    Is it documentation?
                     /              \
                   YES              NO
                   |                 |
              Update docs       Is it a bug fix?
                   |             /          \
                   |           YES          NO
                   |            |             |
               Update index   Fix bug    New feature?
                   |            |          /      \
                   |            |        YES       NO
                   |            |         |         |
                   |            |    Add test  Enhancement
                   |            |         |         |
                   +------------+---------+---------+
                                |
                        Run validation protocol
                                |
                          All tests pass?
                          /            \
                        NO            YES
                        |               |
                    Fix issues    Ready to ship
```

---

## Conclusion

The validation protocol is designed to be **practical, not burdensome**. Start with the basics and add rigor as needed. The goal is quality, not bureaucracy.

**Remember:**
- Good validation takes less time than debugging bad code
- Device testing catches issues emulation can't
- Documentation helps everyone on the team
- Process improvement is continuous

**Start today:** Pick one scenario from this guide and try it. The protocol will become natural with practice.

---

## Additional Resources

- **Full Protocol:** validation-protocol.md
- **Quick Reference:** VALIDATION_QUICK_REF.md
- **Validation Framework:** validation-framework.md
- **Build Guide:** examples/tests/BUILD_GUIDE.md
- **SDK Rules:** CLAUDE.md

**Questions?** Check the troubleshooting section or consult the full protocol documentation.
