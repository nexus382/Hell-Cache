# VMU Pro SDK - Verification & Validation Documentation

## Overview

This directory contains comprehensive documentation for validating fixes, testing changes, and ensuring quality in the VMU Pro LUA SDK codebase.

## Core Philosophy

**Test in Isolation, Verify in Integration, Validate on Device**

Every change to the SDK should follow a systematic validation process to ensure:
- Changes solve the intended problem
- No regressions are introduced
- Performance is maintained or improved
- Code works on actual hardware
- Documentation stays accurate

---

## Document Guide

### Start Here

**📖 [VALIDATION_QUICK_REF.md](VALIDATION_QUICK_REF.md)**
**Essential reading - The entire protocol on one page**
- TL;DR workflow
- One-page checklist
- Critical stop conditions
- Quick commands
- Common pitfalls

**Estimated reading time:** 5 minutes

### Core Documentation

**📋 [validation-protocol.md](validation-protocol.md)**
**The complete, rigorous validation protocol**
- Pre-fix validation phase
- Incremental testing phase
- Regression testing phase
- Performance testing phase
- Device testing phase
- Success criteria
- Rollback procedures
- Comprehensive checklists

**Estimated reading time:** 30 minutes

**🛠️ [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)**
**How to integrate validation into daily workflow**
- Common scenarios (bug fix, new test, performance)
- Daily workflow integration
- Team collaboration
- Continuous improvement
- Troubleshooting

**Estimated reading time:** 20 minutes

### Supporting Documentation

**✅ [validation-framework.md](validation-framework.md)**
**Code pattern validation criteria**
- Import statement patterns
- AppMain() function patterns
- Game loop patterns
- Namespace usage
- Color constants
- Common syntax errors

**Reference document for code review**

**📊 [VERIFICATION_STATUS.md](VERIFICATION_STATUS.md)**
**Status of SDK documentation verification**
- Which documents have been verified
- Verification methodology
- Accuracy reports

**📈 [api-accuracy-report.md](api-accuracy-report.md)**
**Detailed API documentation accuracy analysis**
- Verified vs unverified sections
- Confidence scores
- Recommendations

---

## Quick Start Path

### For First-Time Users

1. **Read** VALIDATION_QUICK_REF.md (5 min)
2. **Skim** validation-protocol.md sections 1-3 (10 min)
3. **Bookmark** INTEGRATION_GUIDE.md for reference
4. **Start** validating your first fix

### For Experienced Users

1. **Reference** VALIDATION_QUICK_REF.md as checklist
2. **Consult** validation-protocol.md for complex scenarios
3. **Use** INTEGRATION_GUIDE.md for workflow integration

### For Code Reviewers

1. **Keep** validation-framework.md open during review
2. **Check** VALIDATION_QUICK_REF.md checklist
3. **Verify** all validation phases completed

---

## Usage by Scenario

### "I need to fix a bug"
**Read:**
1. VALIDATION_QUICK_REF.md - One-page checklist
2. INTEGRATION_GUIDE.md - Scenario 1: Fixing a Bug

### "I need to add a new test"
**Read:**
1. VALIDATION_QUICK_REF.md - Build and deploy commands
2. INTEGRATION_GUIDE.md - Scenario 2: Adding a New Test

### "I found a performance issue"
**Read:**
1. validation-protocol.md - Section 4: Performance Testing
2. INTEGRATION_GUIDE.md - Scenario 3: Performance Investigation

### "Something broke that used to work"
**Read:**
1. validation-protocol.md - Section 7: Rollback Procedures
2. INTEGRATION_GUIDE.md - Scenario 4: Regression Investigation

### "I need to train the team"
**Read:**
1. VALIDATION_QUICK_REF.md - Overview
2. validation-protocol.md - Full protocol
3. INTEGRATION_GUIDE.md - Team Collaboration section

---

## Document Relationships

```
VALIDATION_QUICK_REF.md
       │
       ├── Quick reference for all scenarios
       ├── One-page checklist
       └── Essential commands
              │
              │ (detailed in)
              ↓
validation-protocol.md
       │
       ├── Complete validation procedures
       ├── All phases explained
       └── Comprehensive checklists
              │
              │ (applied in)
              ↓
INTEGRATION_GUIDE.md
       │
       ├── Practical workflows
       ├── Common scenarios
       └── Team processes
              │
              │ (based on)
              ↓
validation-framework.md
       │
       └── Code quality standards
```

---

## Key Concepts

### The Five Validation Phases

1. **Pre-Fix Validation**
   - Document baseline
   - Build status
   - Known issues
   - Success criteria

2. **Incremental Testing**
   - One change at a time
   - Immediate validation
   - Continuous documentation
   - Isolate problems early

3. **Regression Testing**
   - Full test suite
   - All subsystems
   - Cross-system validation
   - Prevent new bugs

4. **Performance Testing**
   - Frame rate validation
   - Memory leak detection
   - Startup time
   - Input latency

5. **Device Testing**
   - Real hardware verification
   - Extended run stability
   - Quality assurance
   - Final gate before shipping

### Critical Success Factors

**DO:**
- Follow the protocol systematically
- Test incrementally (one change at a time)
- Validate on actual hardware
- Document everything
- Know when to rollback
- Learn from mistakes

**DON'T:**
- Skip validation for "small" changes
- Batch multiple untested changes
- Deploy without device testing
- Ignore performance regression
- Rush through protocol steps
- Repeat preventable mistakes

---

## Performance Benchmarks

All SDK code must meet these performance targets:

| Metric | Target | Minimum |
|--------|--------|---------|
| Frame Rate | 60 FPS | 50 FPS |
| Frame Time | 16.67ms | 20ms |
| Memory Leak | 0 bytes | < 1KB/min |
| Startup Time | < 500ms | < 2s |
| Input Latency | < 30ms | < 50ms |

---

## Test Suite Overview

The SDK includes 7 comprehensive tests:

| Test | Purpose | Duration | Mode |
|------|---------|----------|------|
| test_minimal | Basic structure | ~1s | Applet |
| test_stage1 | Display & graphics | ~8s | Applet |
| test_stage2 | Input handling | ~5s | Game |
| test_stage3 | Sprite system | ~5s | Game |
| test_stage4 | Audio system | ~5s | Game |
| test_stage5 | Memory & system | ~5s | Applet |
| test_stage6 | Full integration | ~15s | Game |

**Total automated test time:** ~34 seconds
**Extended testing:** 5+ minutes recommended

---

## Quick Commands Reference

### Build Commands
```bash
cd /mnt/g/vmupro-game-extras/documentation/tools/packer

# Build all tests
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

### Deploy Commands
```bash
# Deploy to device
python send.py --func send \
    --localfile build/test_name.vmupack \
    --remotefile apps/test_name.vmupack \
    --comport COM3

# Deploy and execute
python send.py --func send \
    --localfile build/test_name.vmupack \
    --remotefile apps/test_name.vmupack \
    --comport COM3 --exec --monitor
```

### Validation Commands
```bash
# Check Lua syntax
lua -e "dofile('path/to/file.lua')"

# Check device connectivity
python send.py --func ping --comport COM3
```

---

## Rollback Procedures

### When to Rollback

**Immediate (no debate needed):**
- Device crashes or freezes
- Data corruption
- Security vulnerability
- Hardware damage potential

**Evaluated (consider impact):**
- Performance degradation > 20%
- Multiple test failures
- Significant regressions

### How to Rollback

**Single file:**
```bash
git checkout HEAD -- path/to/file.lua
```

**Multiple files:**
```bash
git revert [commit_hash]..HEAD
```

**Full reset:**
```bash
git reset --hard [last_good_commit]
rm -rf build/*.vmupack
python build_all_tests.py --clean
```

---

## Success Criteria

A fix is approved when:

**Functional:**
- [x] Original bug is fixed
- [x] No workarounds needed
- [x] Edge cases handled
- [x] All tests pass

**Quality:**
- [x] Code follows SDK standards
- [x] Documentation updated
- [x] Examples accurate
- [x] No technical debt

**Performance:**
- [x] Frame rate meets targets
- [x] Memory usage stable
- [x] No regressions
- [x] Resource usage efficient

**Stability:**
- [x] No regressions detected
- [x] Extended run stable
- [x] Device testing successful
- [x] Quality metrics met

---

## Team Adoption Tips

### For Individuals
1. Start with VALIDATION_QUICK_REF.md
2. Use checklists religiously
3. Document every fix
4. Learn from rollbacks

### For Teams
1. Create shared validation logs directory
2. Standardize on templates
3. Review validation during code review
4. Share lessons learned weekly
5. Continuously improve process

### For Organizations
1. Make validation part of definition of "done"
2. Add to onboarding documentation
3. Track metrics over time
4. Recognize quality achievements
5. Invest in tooling and automation

---

## Continuous Improvement

The validation protocol is a living document. We continuously improve it based on:

**Metrics tracked:**
- Time per fix
- Rollback frequency
- Test pass rate
- Device test failures
- Production bugs found

**Process reviews:**
- Monthly protocol assessment
- Quarterly team retrospectives
- Annual process overhaul

**Feedback loops:**
- Incident reports
- Rollback analyses
- Team suggestions
- User feedback

---

## Troubleshooting

### "Protocol takes too long"
**Solution:** Use quick reference, skip non-essentials, automate routine tasks

### "I forget to validate"
**Solution:** Set up git hooks, daily reminders, checklists

### "Device not available"
**Solution:** Prioritize device testing, schedule dedicated testing time

### "Team won't follow protocol"
**Solution:** Lead by example, show value, integrate into workflow, make it easy

### "Too much documentation"
**Solution:** Start with quick reference, add detail as needed, use templates

---

## Additional Resources

### SDK Documentation
- [CLAUDE.md](../../CLAUDE.md) - Complete SDK coding rules
- [README.md](../../README.md) - SDK overview
- [getting-started.md](../../getting-started.md) - Setup guide

### Tools
- [packer.md](../../tools/packer.md) - Packaging tool
- [development.md](../../tools/development.md) - Development setup
- [build_all_tests.py](../../../tools/packer/build_all_tests.py) - Build script

### Tests
- [README.md](../../../examples/tests/README.md) - Test documentation
- [BUILD_GUIDE.md](../../../examples/tests/BUILD_GUIDE.md) - Build guide
- [TEST_SUMMARY.md](../../../examples/tests/TEST_SUMMARY.md) - Test summary

---

## FAQ

**Q: Do I need to follow the full protocol for every change?**
A: Use judgment. Critical changes need full protocol. Minor documentation updates may only need syntax check. When in doubt, validate more rather than less.

**Q: What if device testing isn't available?**
A: Complete all other phases first, document device testing as TODO, schedule device testing as soon as possible.

**Q: Can I batch multiple changes together?**
A: Only if they're related and must be deployed together. Otherwise, test incrementally.

**Q: How do I handle urgent production fixes?**
A: Document the urgency, perform minimum viable validation (syntax + build + device), schedule full validation for follow-up.

**Q: What if the protocol itself has a bug?**
A: Document the issue, follow best judgment, propose protocol improvement.

---

## Document Status

| Document | Status | Last Updated |
|----------|--------|--------------|
| VALIDATION_QUICK_REF.md | Complete | 2025-01-05 |
| validation-protocol.md | Complete | 2025-01-05 |
| INTEGRATION_GUIDE.md | Complete | 2025-01-05 |
| validation-framework.md | Complete | 2025-01-04 |
| VERIFICATION_STATUS.md | Complete | 2025-01-04 |
| api-accuracy-report.md | Complete | 2025-01-04 |

---

## Version History

**v1.0.0 (2025-01-05)**
- Initial comprehensive validation protocol
- Quick reference guide
- Integration guide
- Complete checklists and templates

---

## Contributing

To improve the validation documentation:

1. Propose changes in team discussion
2. Document issues and solutions
3. Update relevant sections
4. Add examples and templates
5. Share lessons learned

**Remember:** The protocol is only as good as its adoption. Use it, improve it, share it.

---

## License

Part of the VMU Pro LUA SDK documentation.
See main repository for license information.

---

**Questions? Start with VALIDATION_QUICK_REF.md - it has the answers to 80% of questions.**

**Need more detail? See validation-protocol.md for comprehensive procedures.**

**Want practical examples? See INTEGRATION_GUIDE.md for real-world scenarios.**
