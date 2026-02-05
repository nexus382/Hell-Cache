# Step 2: Add Action Menu - Quick Reference

**Quick Reference Guide for Step 2 Implementation**

---

## TL;DR Summary

Add the Action Menu to the main_game page. The menu already exists, just need to integrate it.

**Files to Modify**: 1 file (`main_game.lua`)
**Lines to Change**: ~60 lines (add import, modify 5 functions, add 1 function)
**Difficulty**: LOW (integration only, no new code)
**Time Estimate**: 2 hours (30 min dev + 1 hour test + 30 min docs)

---

## Changes at a Glance

### File: `/mnt/g/vmupro-game-extras/tamagotchi_app/pages/main_game.lua`

| Change Type | Location | Description |
|-------------|----------|-------------|
| **ADD** | Line 7 | Import action_menu module |
| **MODIFY** | Lines 30-33 | Add ActionMenu.init() in enter() |
| **ADD** | Line 78 | New handle_action() function |
| **MODIFY** | Lines 80-85 | Add menu routing in handle_input() |
| **MODIFY** | Line 68 | Add ActionMenu.render() call |
| **MODIFY** | Line 38 | Add ActionMenu.reset() in exit() |

---

## 7 Simple Code Changes

### 1. Add Import (Line 7)
```lua
import "libraries/action_menu"
```

### 2. Modify enter() (Lines 30-33)
```lua
function MainGame.enter()
    ActionMenu.init(function(actionId)
        MainGame.handle_action(actionId)
    end)
    return true
end
```

### 3. Add handle_action() Function (Line 78)
```lua
function MainGame.handle_action(actionId)
    local pet = GameState.current_pet
    if not pet then return end

    if actionId == "feed" then
        pet.hunger = math.min(100, (pet.hunger or 0) + 20)
    elseif actionId == "play" then
        pet.happiness = math.min(100, (pet.happiness or 0) + 15)
    elseif actionId == "clean" then
        pet.poop_count = 0
    elseif actionId == "discipline" then
        pet.discipline = math.min(100, (pet.discipline or 0) + 10)
    elseif actionId == "stats" then
        -- Placeholder for Phase 4
    end
end
```

### 4. Modify handle_input() (Lines 80-85)
```lua
function MainGame.handle_input()
    -- Route to menu if open
    if ActionMenu.isOpen() then
        if ActionMenu.handleInput() then
            return "menu_handled"
        end
    end

    -- Open menu with A button
    if vmupro.input.pressed(vmupro.input.A) then
        ActionMenu.open()
        return "menu_open"
    end

    -- Exit with B button (or close menu)
    if vmupro.input.pressed(vmupro.input.B) then
        if ActionMenu.isOpen() then
            ActionMenu.close()
            return "menu_closed"
        end
        return "exit"
    end

    return nil
end
```

### 5. Modify render() (Add at Line 68)
```lua
-- After stats display, before instructions
ActionMenu.render()
```

### 6. Modify exit() (Add at Line 38)
```lua
-- At start of function
ActionMenu.reset()
```

---

## Quick Test Checklist

### Critical Tests (Must Pass)
- [ ] Press A → Menu opens with 5 options
- [ ] Press Up/Down → Highlight moves
- [ ] Press A on Feed → Hunger +20
- [ ] Press A on Play → Happiness +15
- [ ] Press B → Menu closes
- [ ] Press B twice → Exit to slot_select
- [ ] No crashes

### Important Tests (Should Pass)
- [ ] Rapid button presses work
- [ ] Stats cap at 100 (no overflow)
- [ ] Menu resets on re-entry
- [ ] Frame rate stays 60 FPS

---

## Action Menu Options

| Option | ID | Effect |
|--------|-----|--------|
| Feed | feed | hunger +20 |
| Play | play | happiness +15 |
| Clean | clean | poop_count = 0 |
| Train | discipline | discipline +10 |
| Stats | stats | (placeholder) |

---

## Expected Behavior

### User Flow:
1. Navigate to main_game page
2. Press **A** button
3. Action menu appears on right side
4. Use **Up/Down** to select action
5. Press **A** to execute action
6. Menu closes, stat updates
7. Press **B** to close menu without selecting
8. Press **B** again to exit to slot_select

### Visual Layout:
```
┌─────────────────────────┐
│ Pet: Egg              │
│ Stage: Egg            │  ← Game UI (left side)
│ Hunger: 50/100        │
│ Happiness: 50/100     │
│ Health: 50/100        │
│                        │
│    ┌──────────┐       │
│    │Actions   │       │
│    │──────────│       │
│    │▶ Feed    │       │  ← Action Menu (right side)
│    │  Play    │       │
│    │  Clean   │       │
│    │  Train   │       │
│    │  Stats   │       │
│    │          │       │
│    └──────────┘       │
│                        │
│ A:Menu B:Back         │
└─────────────────────────┘
```

---

## SDK APIs Used

All APIs verified in CLAUDE.md:

- ✅ `import "libraries/action_menu"` - Module import
- ✅ `vmupro.input.pressed(button)` - Input detection
- ✅ `ActionMenu.init(callback)` - Init menu
- ✅ `ActionMenu.open()` - Open menu
- ✅ `ActionMenu.close()` - Close menu
- ✅ `ActionMenu.isOpen()` - Check state
- ✅ `ActionMenu.handleInput()` - Process input
- ✅ `ActionMenu.render()` - Draw menu
- ✅ `ActionMenu.reset()` - Reset state
- ✅ `GameState.current_pet` - Get pet object
- ✅ `math.min()` - Bounds checking

---

## Risk Level: LOW

**Why Low Risk**:
- Module already exists and tested
- Simple integration (no complex logic)
- No memory management issues
- Clear fallback strategies

**Potential Issues**:
- ⚠️ Input routing conflicts (mitigated by priority ordering)
- ⚠️ Stat overflow (mitigated by math.min bounds check)
- ⚠️ Callback scope (mitigated by Lua function hoisting)

---

## Build & Deploy

### Build
```bash
cd /mnt/g/vmupro-game-extras
./BUILD_TAMAGOTCHI.sh
```

### Deploy
```bash
./DEPLOY_TAMAGOTCHI.sh
```

### Rollback (if needed)
```bash
cp builds/tamagotchi_step1_backup.vmupack tamagotchi_app/tamagotchi.vmupack
./DEPLOY_TAMAGOTCHI.sh
```

---

## Success Criteria

✅ **Must Have**:
- Menu opens with A button
- Menu displays 5 options
- Can navigate with Up/Down
- Can select with A button
- Can close with B button
- Actions modify stats correctly
- No crashes
- 60 FPS maintained

---

## What's NOT Included (Future Steps)

- ❌ Meal vs. snack selection (Step 3)
- ❌ FeedingSystem integration (Step 3)
- ❌ PlaySystem integration (Step 4)
- ❌ Minigame selection (Step 4)
- ❌ Stats page (Phase 4)
- ❌ Sound effects (future)
- ❌ Menu animations (future)

---

## Common Issues & Fixes

### Issue: Menu doesn't open
**Fix**: Check import statement on line 7
**Verify**: ActionMenu module loads

### Issue: Can't navigate menu
**Fix**: Ensure ActionMenu.handleInput() is called when menu open
**Verify**: Check input routing priority in handle_input()

### Issue: Stats don't update
**Fix**: Check GameState.current_pet is not nil
**Verify**: Add logging to handle_action()

### Issue: Menu stays open after exit
**Fix**: Ensure ActionMenu.reset() called in exit()
**Verify**: Check exit() function

---

## Next Steps

**After Step 2 Complete**:
1. Document completion (create PHASE3_STEP2_COMPLETE.md)
2. Review Step 3 plan (FeedingSystem integration)
3. Prepare for Step 3 implementation

**Step 3 Preview**:
- Integrate FeedingSystem module
- Add meal vs. snack selection
- Calculate weight impact
- Test feeding restrictions

---

## Quick Reference Links

**Full Plan**: See [STEP2_ACTION_MENU_IMPLEMENTATION_PLAN.md](./STEP2_ACTION_MENU_IMPLEMENTATION_PLAN.md)
**Overall Plan**: See [PHASE3_INCREMENTAL_PLAN.md](/mnt/g/vmupro-game-extras/PHASE3_INCREMENTAL_PLAN.md)
**Step 1 Complete**: See [PHASE3_STEP1_COMPLETE.md](/mnt/g/vmupro-game-extras/PHASE3_STEP1_COMPLETE.md)
**SDK Rules**: See [CLAUDE.md](/mnt/g/vmupro-game-extras/documentation/CLAUDE.md)

---

**Status**: Ready to Implement
**Estimated Time**: 2 hours
**Risk Level**: LOW
**Confidence**: HIGH

---

*Last Updated: 2026-01-06*
