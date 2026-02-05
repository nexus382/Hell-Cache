<!-- Parent: ../../AGENTS.md -->
<!-- Generated: 2026-02-04 | Updated: 2026-02-04 -->

# libraries

## Purpose
Shared Lua modules providing reusable functions and utilities for the nested example app.

## For AI Agents

### Working In This Directory

**These are example modules** - reference for creating shared libraries.

### Module Pattern

**Define Module**:
```lua
-- libraries/utils.lua
Utils = {}

function Utils.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

-- No explicit return needed
```

**Use Module**:
```lua
-- In app.lua or pages/page1.lua
-- Module is auto-loaded by SDK
-- Access functions directly:
local value = Utils.clamp(10, 0, 5)  -- Returns 5
```

### Common Library Types

**Utility Functions**:
- Math helpers (clamp, lerp, etc.)
- String helpers
- Table helpers

**Game Logic**:
- Player state management
- Collision detection
- AI behavior

**UI Components**:
- Button class
- Menu system
- Dialog boxes

### Best Practices

- Use PascalCase for module names: `Utils`, `PlayerManager`
- Use camelCase for functions: `clamp()`, `getPlayerState()`
- Keep modules focused on single responsibility
- Avoid circular dependencies
- Document complex functions

### Module Loading

**No Explicit Import Needed**:
- Modules in `libraries/` are auto-loaded
- Access directly by module name
- Order doesn't matter

**Example**:
```lua
-- libraries/math_utils.lua
MathUtils = {}

function MathUtils.distance(x1, y1, x2, y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

-- In app.lua:
local dist = MathUtils.distance(0, 0, 10, 10)
```

## Dependencies

### Internal
- `../app.lua` - Main app using libraries
- `../pages/` - Pages using libraries

### External
- Lua 5.x reference

<!-- MANUAL: Library-specific notes can be added below -->
