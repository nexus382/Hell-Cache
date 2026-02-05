# Validation Protocol Quick Reference

## TL;DR - The Essential Workflow

```
Pre-Fix Baseline → Incremental Changes → Regression Tests → Performance Check → Device Test → Sign-Off
```

## One-Page Checklist

### Phase 1: Pre-Fix (5 min)
- [ ] Document baseline (what works now)
- [ ] Run `python build_all_tests.py --clean`
- [ ] Note known issues

### Phase 2: Incremental (Per Change)
- [ ] Make ONE change
- [ ] Syntax check: `lua -e "dofile('file.lua')"`
- [ ] Build affected test
- [ ] Deploy and verify on device
- [ ] Document change

### Phase 3: Regression (After All Changes)
- [ ] Rebuild all tests
- [ ] Deploy all 7 tests to device
- [ ] Verify each passes
- [ ] Check for regressions

### Phase 4: Performance (If Applicable)
- [ ] Frame rate ≥ 55 FPS
- [ ] No memory leaks
- [ ] Startup < 2 seconds
- [ ] Input latency < 50ms

### Phase 5: Device (Final Gate)
- [ ] All tests run on device
- [ ] No crashes
- [ ] All features work
- [ ] Extended run stable (5+ min)

### Success Criteria
- [x] Original bug fixed
- [x] No new bugs
- [x] Performance acceptable
- [x] Device testing passed
- [x] Documentation updated

## Critical Stop Conditions

**STOP immediately and rollback if:**
- Device crashes or freezes
- Data corruption occurs
- Security vulnerability introduced
- Performance degrades > 20%
- Multiple test failures

## Quick Commands

### Build
```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer
python build_all_tests.py              # Build all
python build_all_tests.py --clean      # Clean build
```

### Deploy
```bash
python send.py --func send \
    --localfile build/test_name.vmupack \
    --remotefile apps/test_name.vmupack \
    --comport COM3 --exec --monitor
```

### Verify Syntax
```bash
lua -e "dofile('path/to/file.lua')"
```

## Test Order

1. **test_minimal** - Basic structure (~1s)
2. **test_stage1** - Display (~8s)
3. **test_stage2** - Input (~5s)
4. **test_stage3** - Sprites (~5s)
5. **test_stage4** - Audio (~5s)
6. **test_stage5** - Memory (~5s)
7. **test_stage6** - Integration (~15s)

**Total: ~34 seconds automated, 5+ minutes extended**

## Performance Targets

| Metric | Target | Minimum |
|--------|--------|---------|
| Frame Rate | 60 FPS | 50 FPS |
| Frame Time | 16.67ms | 20ms |
| Memory Leak | 0 bytes | < 1KB |
| Startup | < 500ms | < 2s |
| Input Latency | < 30ms | < 50ms |

## Common Pitfalls to Check

**Syntax:**
- Missing `import` statements
- Wrong import path (use "api/..." not "...")
- Using `require()` instead of `import`

**Code Pattern:**
- Missing `vmupro.input.read()` before button checks
- Multiple `vmupro.graphics.refresh()` calls
- Missing `vmupro.sprite.removeAll()` on exit
- Missing `vmupro.sound.update()` every frame (if using audio)
- `AppMain()` not returning number

**Resource Management:**
- Forgetting to free sprites
- Forgetting to free sounds
- Not calling `exitListenMode()` for audio
- Creating objects in loops

## When to Rollback

**Immediate:**
- Device crash
- Data loss
- Security issue
- Hardware risk

**Evaluated:**
- Performance > 20% worse
- Multiple test failures
- Significant regressions

## Rollback Commands

**Single File:**
```bash
git checkout HEAD -- path/to/file.lua
```

**Multi-File:**
```bash
git revert [commit_hash]..HEAD
```

**Full Reset:**
```bash
git reset --hard [last_good_commit]
rm -rf build/*.vmupack
python build_all_tests.py --clean
```

## Verification After Rollback

1. Build all tests: `python build_all_tests.py --clean`
2. Deploy and test on device
3. Verify all symptoms resolved
4. Document rollback and lessons learned

## Decision Tree

```
                        Make Change
                            |
                      Syntax Valid?
                     /            \
                   NO             YES
                   |                |
              Fix Syntax        Build OK?
                   |                |
                   +--------+-------+
                            |
                      Tests Pass?
                     /            \
                   NO             YES
                   |                |
              Debug Fix        Device OK?
                   |                |
                   +--------+-------+
                            |
                      All Good?
                     /            \
                   NO             YES
                   |                |
              Rollback         Document &
              & Fix            Next Change
```

## Documentation Templates

### Change Log Entry
```markdown
## Change [N] - [DATE]

**File:** filename.lua
**Lines:** X-Y
**Type:** [Bug Fix/Enhancement]

**What:** [Description]
**Why:** [Reasoning]
**Result:** [PASS/FAIL]
**Next:** [What's next]
```

### Rollback Entry
```markdown
## Rollback - [DATE]

**File:** filename.lua
**Reason:** [Issue]
**Symptoms:** [What went wrong]
**Resolution:** [Reverted to X]
**Verified:** [How confirmed]
```

## Key Success Metrics

**A fix is successful when:**
- Original bug is resolved
- No regressions introduced
- All tests pass on device
- Performance within targets
- Extended run stable
- Documentation complete

## Contact and Support

**For issues with:**
- **Protocol questions:** See full validation-protocol.md
- **Test failures:** Check TEST_SUMMARY.md
- **Build issues:** Check BUILD_GUIDE.md
- **SDK rules:** See CLAUDE.md

## Golden Rules

1. **One change at a time** - Don't batch modifications
2. **Test every change** - No exceptions
3. **Document everything** - If not documented, didn't happen
4. **Test on device** - Emulation isn't enough
5. **Know when to stop** - Rollback is better than broken code
6. **Learn from mistakes** - Update protocol after incidents

## Bottom Line

**If you can't verify it works, don't ship it.**

Every fix must pass:
1. Syntax validation
2. Build validation
3. Functional testing
4. Device testing
5. Performance validation

**No shortcuts, no exceptions.**

---

**Full Protocol:** See `validation-protocol.md` for comprehensive procedures
