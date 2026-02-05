<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# verification

## Purpose
Verification and testing rules for ensuring VMU Pro applications work correctly.

## For AI Agents

### Working In This Directory

**These are verification standards** - use to validate code correctness.

### Pre-Deployment Checklist

**Code Structure**:
- [ ] `AppMain()` function exists
- [ ] Returns numeric exit code (0 for success)
- [ ] All imports use `import "api/..."` syntax
- [ ] No `require()` calls for SDK modules

**Resource Management**:
- [ ] `startListenMode()` called before audio
- [ ] `exitListenMode()` called on cleanup
- [ ] `vmupro.sprite.removeAll()` called on exit
- [ ] Individual sprites/sounds freed when done

**Frame Loop**:
- [ ] `vmupro.input.read()` called once per frame
- [ ] `vmupro.graphics.clear()` called once per frame
- [ ] `vmupro.graphics.refresh()` called once per frame
- [ ] `vmupro.sound.update()` called every frame (if using audio)
- [ ] Frame rate control (`delayMs(16)` for ~60 FPS)

**Error Handling**:
- [ ] Resource loading checks for nil
- [ ] Appropriate log levels used
- [ ] Defensive programming implemented
- [ ] Cleanup on errors

### Testing Requirements

**Basic Functionality**:
- Test on VMU Pro hardware when possible
- Verify all features work
- Check memory usage
- Test edge cases

**Performance**:
- Frame rate stays near 60 FPS
- No memory leaks
- Smooth animations
- Responsive input

**Compatibility**:
- Works on target VMU Pro hardware
- Display renders correctly
- Audio plays without crashes
- Controls respond properly

### Common Issues to Check

**Crash Prevention**:
- Math: Use `safeAtan2()` instead of `math.atan2()` (crashes on VMU Pro)
- Random: Avoid `math.random()` (can crash)
- Audio: Use synth, not samples (samples crash)

**Memory**:
- Free unused sprites
- Free unused sounds
- Monitor memory usage
- Check largest free block

**Display**:
- Clear once per frame
- Refresh once per frame
- Don't draw outside bounds (0-239)
- Use correct color format (RGB565)

## Dependencies

### Internal
- `../api/` - API rules
- `../structure/` - Structure rules
- `../../api/` - API documentation
- `../../../examples/` - Working examples

<!-- MANUAL: Verification notes can be added below -->
