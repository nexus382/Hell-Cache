# VMU Pro SDK - Validation System Overview

## Visual Navigation Guide

This document provides a visual overview of the validation and verification system, helping you quickly find what you need.

---

## Document Map

```
┌─────────────────────────────────────────────────────────────┐
│                    VALIDATION SYSTEM                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐      ┌──────────────────┐            │
│  │   START HERE     │      │  REFERENCE       │            │
│  │                  │      │                  │            │
│  │  README.md       │─────→│ QUICK_REF.md     │            │
│  │  (This doc)      │      │ (One pager)      │            │
│  └────────┬─────────┘      └──────────────────┘            │
│           │                                                   │
│           ├──→ ┌──────────────────┐                         │
│           │    │   DETAILED       │                         │
│           │    │                  │                         │
│           │    │ validation-      │                         │
│           │    │ protocol.md      │                         │
│           │    │ (Complete guide) │                         │
│           │    └──────────────────┘                         │
│           │                                                   │
│           ├──→ ┌──────────────────┐                         │
│           │    │   PRACTICAL      │                         │
│           │    │                  │                         │
│           │    │ INTEGRATION_     │                         │
│           │    │ GUIDE.md         │                         │
│           │    │ (Workflows)      │                         │
│           │    └──────────────────┘                         │
│           │                                                   │
│           └──→ ┌──────────────────┐                         │
│                │   STANDARDS      │                         │
│                │                  │                         │
│                │ validation-      │                         │
│                │ framework.md     │                         │
│                │ (Code quality)   │                         │
│                └──────────────────┘                         │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Decision Tree

```
                    ┌─────────────────┐
                    │   What do you   │
                    │   need to do?   │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
   │ Fix a   │         │ Add a   │         │ Review  │
   │ bug     │         │ test    │         │ code    │
   └────┬────┘         └────┬────┘         └────┬────┘
        │                    │                    │
        │                    │                    │
   ┌────▼────────┐    ┌──────▼──────┐    ┌──────▼──────┐
   │ Scenario 1  │    │ Scenario 2  │    │ Framework   │
   │ Integration │    │ Integration │    │ + Quick Ref │
   │ Guide       │    │ Guide       │    │             │
   └─────────────┘    └─────────────┘    └─────────────┘
```

---

## Phase-by-Phase Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   VALIDATION WORKFLOW                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Phase 1: PRE-FIX                                            │
│  ┌──────────────────────────────────┐                       │
│  │ • Document baseline              │                       │
│  │ • Run build_all_tests.py         │                       │
│  │ • Note known issues              │                       │
│  │ Time: 5-10 minutes               │                       │
│  └────────────┬─────────────────────┘                       │
│               │                                               │
│  Phase 2: INCREMENTAL                                         │
│  ┌────────▼──────────────────────────┐                       │
│  │ FOR EACH CHANGE:                  │                       │
│  │ • Make one change                 │                       │
│  │ • Syntax check (lua)              │                       │
│  │ • Build affected test             │                       │
│  │ • Deploy to device                │                       │
│  │ • Verify works                    │                       │
│  │ • Document change                 │                       │
│  │ Time: 5-10 min per change         │                       │
│  └────────────┬─────────────────────┘                       │
│               │                                               │
│  Phase 3: REGRESSION                                           │
│  ┌────────▼──────────────────────────┐                       │
│  │ • Build all tests                 │                       │
│  │ • Deploy all tests                │                       │
│  │ • Verify all pass                 │                       │
│  │ • Check for regressions           │                       │
│  │ Time: 15-20 minutes               │                       │
│  └────────────┬─────────────────────┘                       │
│               │                                               │
│  Phase 4: PERFORMANCE                                           │
│  ┌────────▼──────────────────────────┐                       │
│  │ • Measure frame rate              │                       │
│  │ • Check memory usage              │                       │
│  │ • Test startup time               │                       │
│  │ • Verify input latency            │                       │
│  │ Time: 10-15 minutes               │                       │
│  └────────────┬─────────────────────┘                       │
│               │                                               │
│  Phase 5: DEVICE                                               │
│  ┌────────▼──────────────────────────┐                       │
│  │ • Deploy to device                │                       │
│  │ • Execute all tests               │                       │
│  │ • Extended run (5+ min)           │                       │
│  │ • Quality verification            │                       │
│  │ Time: 20-30 minutes               │                       │
│  └────────────┬─────────────────────┘                       │
│               │                                               │
│  Phase 6: SIGN-OFF                                             │
│  ┌────────▼──────────────────────────┐                       │
│  │ • All criteria met                │                       │
│  │ • Documentation complete          │                       │
│  │ • Ready for deployment            │                       │
│  └───────────────────────────────────┘                       │
│                                                               │
│  TOTAL TIME: 1-2 hours (depending on changes)                │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Document Use Cases

### By Time Available

```
┌─────────────────────────────────────────────────────────┐
│ Time Available    │ Document to Read                    │
├─────────────────────────────────────────────────────────┤
│ 5 minutes         │ VALIDATION_QUICK_REF.md             │
│ 15 minutes        │ VALIDATION_QUICK_REF.md             │
│                   │ + INTEGRATION_GUIDE.md (your        │
│                   │   scenario)                         │
│ 30 minutes        │ validation-protocol.md (sections    │
│                   │   1-3)                              │
│ 1 hour            │ validation-protocol.md (complete)   │
│ Ongoing reference │ VALIDATION_QUICK_REF.md (keep open) │
└─────────────────────────────────────────────────────────┘
```

### By Experience Level

```
┌─────────────────────────────────────────────────────────┐
│ Experience       │ Documents to Study                   │
├─────────────────────────────────────────────────────────┤
│ Beginner         │ 1. README.md                        │
│                  │ 2. VALIDATION_QUICK_REF.md          │
│                  │ 3. INTEGRATION_GUIDE.md (Scenario 1) │
│                  │ 4. validation-framework.md          │
├─────────────────────────────────────────────────────────┤
│ Intermediate     │ 1. VALIDATION_QUICK_REF.md          │
│                  │ 2. validation-protocol.md           │
│                  │ 3. INTEGRATION_GUIDE.md (all        │
│                  │    scenarios)                       │
├─────────────────────────────────────────────────────────┤
│ Advanced         │ 1. VALIDATION_QUICK_REF.md          │
│                  │ 2. validation-protocol.md           │
│                  │ 3. Contribute improvements          │
└─────────────────────────────────────────────────────────┘
```

### By Role

```
┌─────────────────────────────────────────────────────────┐
│ Role             │ Key Documents                       │
├─────────────────────────────────────────────────────────┤
│ Developer        │ VALIDATION_QUICK_REF.md             │
│                  │ validation-protocol.md              │
│                  │ INTEGRATION_GUIDE.md                │
├─────────────────────────────────────────────────────────┤
│ Code Reviewer   │ validation-framework.md             │
│                  │ VALIDATION_QUICK_REF.md             │
│                  │ validation-protocol.md (checklists) │
├─────────────────────────────────────────────────────────┤
│ QA Tester       │ validation-protocol.md (Section 5)   │
│                  │ VALIDATION_QUICK_REF.md             │
│                  │ Device testing procedures           │
├─────────────────────────────────────────────────────────┤
│ Team Lead        │ README.md                           │
│                  │ INTEGRATION_GUIDE.md (team section) │
│                  │ Metrics and improvement sections    │
└─────────────────────────────────────────────────────────┘
```

---

## Validation Checklist Flow

```
┌──────────────────┐
│  START FIX       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Pre-Fix Phase    │────→│ Baseline Doc     │
│ • Document state │     │ Created          │
└────────┬─────────┘     └──────────────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Incremental      │────→│ Change Logged     │
│ • One change     │     │ Each step        │
│ • Validate       │     └──────────────────┘
│ • Document       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Regression Test  │────→│ All 7 tests      │
│ • Build all      │     │ Pass             │
│ • Test all       │     └──────────────────┘
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Performance      │────→│ Metrics within   │
│ • Frame rate     │     │ Targets          │
│ • Memory         │     └──────────────────┘
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Device Test      │────→│ Works on real    │
│ • Deploy         │     │ hardware         │
│ • Execute        │     └──────────────────┘
│ • Verify         │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ ✓ SUCCESS        │
│ Fix validated    │
│ Ready to ship    │
└──────────────────┘
```

---

## Rollback Decision Tree

```
                    ┌─────────────────┐
                    │   Issue Found   │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   How Severe?   │
                    └────────┬────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
       ┌────▼────┐      ┌────▼────┐     ┌────▼────┐
       │ CRITICAL│      │   HIGH  │     │  MEDIUM │
       └────┬────┘      └────┬────┘     └────┬────┘
            │                │                │
            │                │                │
       ┌────▼────────────────▼────────────────▼────┐
       │                                         │
       │  Immediate Action Needed                │
       │                                         │
       │  1. Stop work                            │
       │  2. Assess impact                        │
       │  3. Rollback                             │
       │  4. Verify fix                           │
       │  5. Document                             │
       │                                         │
       └────────────────┬────────────────────────┘
                        │
                        ▼
              ┌─────────────────┐
              │  System Stable  │
              └────────┬────────┘
                       │
                       ▼
              ┌─────────────────┐
              │  Root Cause     │
              │  Analysis       │
              └────────┬────────┘
                       │
                       ▼
              ┌─────────────────┐
              │  Proper Fix     │
              │  (Full Protocol)│
              └─────────────────┘
```

---

## Performance Validation Flow

```
┌──────────────────┐
│ Add Performance  │
│ Measurement Code │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Run on Device    │
│ (30 seconds)     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Measure          │────→│ Frame Rate       │
│ • FPS            │     │ ≥ 55?            │
│ • Memory         │     └──────────────────┘
│ • Startup        │
│ • Latency        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ All Metrics      │
│ Pass?            │
└────────┬─────────┘
         │
    ┌────┴────┐
    │         │
   YES        NO
    │         │
    │         ▼
    │   ┌──────────────────┐
    │   │ Investigate      │
    │   │ Bottleneck       │
    │   └────────┬─────────┘
    │            │
    │            ▼
    │   ┌──────────────────┐
    │   │ Optimize         │
    │   │ Retest           │
    │   └──────────────────┘
    │
    ▼
┌──────────────────┐
│ Performance      │
│ Validation       │
│ COMPLETE         │
└──────────────────┘
```

---

## Testing Matrix

```
┌─────────────────────────────────────────────────────────────┐
│ TEST SUITE COVERAGE                                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ Test            │ Subsystem    │ Duration │ Device Needed    │
├─────────────────┼──────────────┼──────────┼──────────────────┤
│ test_minimal    │ Basic        │ ~1s      │ Yes              │
│ test_stage1     │ Display      │ ~8s      │ Yes              │
│ test_stage2     │ Input        │ ~5s      │ Yes (Required)   │
│ test_stage3     │ Sprites      │ ~5s      │ Yes              │
│ test_stage4     │ Audio        │ ~5s      │ Yes (Required)   │
│ test_stage5     │ System       │ ~5s      │ Yes              │
│ test_stage6     │ Integration  │ ~15s     │ Yes (Required)   │
├─────────────────┴──────────────┴──────────┴──────────────────┤
│                                                               │
│ Total Runtime:        ~34 seconds (automated)               │
│ Extended Testing:     5+ minutes (recommended)              │
│ Device Required:      7/7 tests (100%)                      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Document Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                     DOCUMENT ECOSYSTEM                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  README.md (Navigation Hub)                                  │
│       │                                                       │
│       ├──→ Guides you to right document                      │
│       │                                                       │
│       ├──→ VALIDATION_QUICK_REF.md (Essential)               │
│       │    │                                                  │
│       │    ├──→ TL;DR workflow                               │
│       │    ├──→ Checklists                                   │
│       │    └──→ Quick commands                               │
│       │                                                       │
│       ├──→ validation-protocol.md (Complete)                 │
│       │    │                                                  │
│       │    ├──→ All phases detailed                          │
│       │    ├──→ Comprehensive checklists                     │
│       │    └──→ Rollback procedures                          │
│       │                                                       │
│       ├──→ INTEGRATION_GUIDE.md (Practical)                  │
│       │    │                                                  │
│       │    ├──→ Common scenarios                             │
│       │    ├──→ Workflows                                    │
│       │    └──→ Team processes                               │
│       │                                                       │
│       └──→ validation-framework.md (Standards)               │
│            │                                                  │
│            ├──→ Code patterns                                │
│            ├──→ Quality criteria                             │
│            └──→ Scoring system                               │
│                                                               │
│  All documents reference each other and provide links        │
│  for easy navigation between detailed and summary info       │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Command Reference

```
┌─────────────────────────────────────────────────────────────┐
│ COMMON WORKFLOWS                                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ 1. BUILD ALL TESTS                                           │
│    cd /mnt/g/vmupro-game-extras/documentation/tools/packer  │
│    python build_all_tests.py --clean                        │
│                                                               │
│ 2. BUILD SINGLE TEST                                         │
│    python packer.py --projectdir ../../examples/tests \     │
│      --appname test_name --meta test_metadata.json \        │
│      --sdkversion 1.0.0 --icon ../../examples/tests/icon.bmp│
│                                                               │
│ 3. DEPLOY TO DEVICE                                          │
│    python send.py --func send \                             │
│      --localfile build/test_name.vmupack \                  │
│      --remotefile apps/test_name.vmupack \                  │
│      --comport COM3 --exec --monitor                        │
│                                                               │
│ 4. CHECK SYNTAX                                              │
│    lua -e "dofile('path/to/file.lua')"                      │
│                                                               │
│ 5. DEVICE CONNECTIVITY                                       │
│    python send.py --func ping --comport COM3                │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Success Criteria Checklist

```
┌─────────────────────────────────────────────────────────────┐
│ ✓ FIX APPROVAL CHECKLIST                                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ FUNCTIONAL REQUIREMENTS                                      │
│ [ ] Original bug is fixed                                    │
│ [ ] Fix solves reported issue                                │
│ [ ] No workarounds needed                                    │
│ [ ] Edge cases handled                                       │
│                                                               │
│ QUALITY REQUIREMENTS                                         │
│ [ ] Code follows SDK standards                               │
│ [ ] Documentation is updated                                 │
│ [ ] Examples are accurate                                    │
│ [ ] No technical debt introduced                             │
│                                                               │
│ PERFORMANCE REQUIREMENTS                                     │
│ [ ] Frame rate ≥ 55 FPS                                      │
│ [ ] Memory usage stable                                      │
│ [ ] No performance regressions                               │
│ [ ] Resource usage efficient                                 │
│                                                               │
│ STABILITY REQUIREMENTS                                       │
│ [ ] All tests pass                                           │
│ [ ] No regressions detected                                  │
│ [ ] Extended run stable (5+ min)                             │
│ [ ] Device testing successful                               │
│                                                               │
│ COMPLIANCE REQUIREMENTS                                      │
│ [ ] SDK rules followed                                       │
│ [ ] Validation framework compliant                           │
│ [ ] Project structure correct                                │
│ [ ] Build process works                                      │
│                                                               │
│ DOCUMENTATION REQUIREMENTS                                   │
│ [ ] Changes documented                                       │
│ [ ] Test results recorded                                    │
│ [ ] Performance measured                                     │
│ [ ] Sign-off completed                                       │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
documentation/docs/rules/verification/
│
├── README.md                    ← YOU ARE HERE (Navigation hub)
├── VALIDATION_MAP.md            ← This file (Visual overview)
├── VALIDATION_QUICK_REF.md      ← Essential (One page)
├── validation-protocol.md       ← Complete (Comprehensive)
├── INTEGRATION_GUIDE.md         ← Practical (Workflows)
├── validation-framework.md      ← Standards (Code quality)
├── VERIFICATION_STATUS.md       ← Status (What's verified)
└── api-accuracy-report.md       ← Analysis (API accuracy)
```

---

## Getting Started Path

```
┌──────────────────┐
│  NEW USER?       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Step 1           │────→│ Read README.md   │
│ (5 minutes)      │     │ (This file)      │
└────────┬─────────┘     └──────────────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Step 2           │────→│ Quick Ref        │
│ (5 minutes)      │     │ One pager        │
└────────┬─────────┘     └──────────────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Step 3           │────→│ Choose Scenario  │
│ (10 minutes)     │     │ Integration Guide │
└────────┬─────────┘     └──────────────────┘
         │
         ▼
┌──────────────────┐
│ Step 4           │
│ Start Validating │
│ Your First Fix!  │
└──────────────────┘
```

---

## Pro Tips

```
┌─────────────────────────────────────────────────────────────┐
│ EXPERT TIPS                                                 │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ 1. KEEP QUICK REF OPEN                                       │
│    Have VALIDATION_QUICK_REF.md open while coding           │
│                                                               │
│ 2. USE TEMPLATES                                             │
│    Copy templates from validation-protocol.md               │
│                                                               │
│ 3. DOCUMENT AS YOU GO                                        │
│    Don't wait until the end to document                     │
│                                                               │
│ 4. TEST INCREMENTALLY                                        │
│    One change, one test, repeat                             │
│                                                               │
│ 5. KNOW WHEN TO ROLLBACK                                    │
│    Don't waste time on broken code                          │
│                                                               │
│ 6. LEARN FROM MISTAKES                                      │
│    Update protocol after incidents                          │
│                                                               │
│ 7. AUTOMATE ROUTINE TASKS                                   │
│    Scripts for builds, deploys, checks                      │
│                                                               │
│ 8. SHARE WITH TEAM                                          │
│    Collective knowledge prevents repeats                    │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Summary

**The validation system is designed to be:**

- **Comprehensive** - Covers all aspects of quality
- **Practical** - Real-world workflows and scenarios
- **Flexible** - Adapt to your needs and time constraints
- **Approachable** - Start simple, add complexity as needed
- **Effective** - Prevents bugs and ensures quality

**Key Documents:**
1. **README.md** - Start here (navigation)
2. **VALIDATION_QUICK_REF.md** - Use often (checklist)
3. **validation-protocol.md** - Reference (complete)
4. **INTEGRATION_GUIDE.md** - Apply (workflows)
5. **validation-framework.md** - Standard (quality)

**Remember:** Good validation takes less time than debugging bad code. The protocol is an investment in quality that pays dividends immediately.

---

**Next Steps:**

1. Read **VALIDATION_QUICK_REF.md** (5 minutes)
2. Choose a scenario in **INTEGRATION_GUIDE.md**
3. Start validating your first fix
4. Come back to **README.md** as needed

**You've got this!** The validation system is here to help, not hinder. Use it to build better code, faster.
