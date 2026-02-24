# Libraries - Utility Modules

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

This directory contains custom Lua utility modules used by the nested example test suite. These modules demonstrate how to create reusable libraries in VMU Pro applications.

---

## Files

| File | Description |
|------|-------------|
| `maths.lua` | Math helper functions (add, multiply, square) |
| `utils.lua` | General utility functions (clamp, lerp) |

---

## Import Pattern

```lua
import "libraries/maths"
import "libraries/utils"
```

---

## Maths Module (`maths.lua`)

Simple math utility module providing basic arithmetic operations.

### Module Table

```lua
Maths = {}
```

### Functions

#### `Maths.add(a, b)`

Returns the sum of two numbers.

| Parameter | Type | Description |
|-----------|------|-------------|
| `a` | number | First operand |
| `b` | number | Second operand |

**Returns:** `number` - The sum of `a` and `b`

**Example:**
```lua
local result = Maths.add(5, 3)  -- Returns 8
```

---

#### `Maths.multiply(a, b)`

Returns the product of two numbers.

| Parameter | Type | Description |
|-----------|------|-------------|
| `a` | number | First operand |
| `b` | number | Second operand |

**Returns:** `number` - The product of `a` and `b`

**Example:**
```lua
local result = Maths.multiply(4, 7)  -- Returns 28
```

---

#### `Maths.square(x)`

Returns the square of a number.

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | number | Value to square |

**Returns:** `number` - The value of `x` multiplied by itself

**Example:**
```lua
local result = Maths.square(5)  -- Returns 25
```

---

## Utils Module (`utils.lua`)

General utility functions for common operations.

### Module Table

```lua
Utils = {}
```

### Functions

#### `Utils.clamp(value, min, max)`

Constrains a value to be within a specified range.

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | number | The value to constrain |
| `min` | number | The minimum allowed value |
| `max` | number | The maximum allowed value |

**Returns:** `number` - The clamped value (returns `min` if below range, `max` if above range, or `value` if within range)

**Example:**
```lua
Utils.clamp(15, 0, 10)   -- Returns 10 (capped at max)
Utils.clamp(-5, 0, 10)   -- Returns 0 (capped at min)
Utils.clamp(5, 0, 10)    -- Returns 5 (within range)
```

---

#### `Utils.lerp(a, b, t)`

Performs linear interpolation between two values.

| Parameter | Type | Description |
|-----------|------|-------------|
| `a` | number | Start value |
| `b` | number | End value |
| `t` | number | Interpolation factor (0.0 to 1.0) |

**Returns:** `number` - The interpolated value between `a` and `b`

**Formula:** `a + (b - a) * t`

**Example:**
```lua
Utils.lerp(0, 100, 0.0)   -- Returns 0 (start)
Utils.lerp(0, 100, 0.5)   -- Returns 50 (midpoint)
Utils.lerp(0, 100, 1.0)   -- Returns 100 (end)
```

---

## For AI Agents

### Adding New Functions

When adding new utility functions to these modules:

1. Follow the existing naming convention (`ModuleName.functionName`)
2. Add function documentation in the same style
3. Keep functions pure (no side effects) when possible
4. Return explicit values rather than modifying inputs

### Module Structure Template

```lua
-- libraries/newmodule.lua
-- Brief description of module purpose

NewModule = {}

function NewModule.functionName(param1, param2)
    -- Implementation
    return result
end
```

### Usage in Pages

```lua
-- In a page file
import "libraries/maths"
import "libraries/utils"

function MyPage.update()
    local position = Utils.clamp(player_x, 0, screen_width)
    local speed = Maths.multiply(base_speed, multiplier)
end
```

---

## See Also

- `../AGENTS.md` - Parent nested_example documentation
- `../pages/` - Test pages that use these libraries
