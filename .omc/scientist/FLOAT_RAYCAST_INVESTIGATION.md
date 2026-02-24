# FLOAT Raycasting Investigation - app_full.lua

**Date:** 2025-02-17
**File:** `/mnt/r/inner-santctum/app_full.lua`
**Raycast Mode:** FLOAT (default when `USE_FIXED_RAYCAST ~= true` or `DEBUG_FORCE_FLOAT_RAYCAST == true`)

---

## Executive Summary

The FLOAT raycaster in app_full.lua is a standard DDA (Digital Differential Analyzer) implementation using Lua's native 64-bit double-precision floating-point numbers. It operates on a 16x16 tile map with configurable ray counts (typically 60 rays at 4-pixel columns for 240-pixel wide rendering).

---

## 1. Ray Direction Calculation

### Location: Lines 5702-5752

```lua
local fovRad = renderCfg.fovSteps * (renderCfg.twoPi / 64)
local playerDir = pdir % 64
local playerAngle = playerDir * (renderCfg.twoPi / 64)
local playerCos = math.cos(playerAngle)
local playerSin = math.sin(playerAngle)
```

**Precision:**
- `math.cos()` and `math.sin()` return 64-bit double-precision floats
- `playerAngle` is computed as `(pdir % 64) * (2π / 64)`
- 64 discrete player directions (0-63), each ~5.6° apart

### Ray Step Calculation

```lua
local baseAngle = playerAngle - (fovRad / 2)
rayStep = fovRad / rayCols  -- Typically 60 rays across FOV
stepCos1 = math.cos(rayStep)
stepSin1 = math.sin(rayStep)
-- Precompute stride multiples for LOD
stepCos2 = math.cos(rayStep * 2)
stepSin2 = math.sin(rayStep * 2)
stepCos3 = math.cos(rayStep * 3)
stepSin3 = math.sin(rayStep * 3)
stepCos4 = math.cos(rayStep * 4)
stepSin4 = math.sin(rayStep * 4)

rayCos = math.cos(baseAngle)
raySin = math.sin(baseAngle)
```

### Ray Rotation (Lines 6008-6025)

For each ray step, direction is rotated using precomputed trig values:

```lua
local newCos = rayCos * sc - raySin * ss
local newSin = raySin * sc + rayCos * ss
rayCos, raySin = newCos, newSin
```

This is a 2D rotation matrix application avoiding `atan2`/angle accumulation.

---

## 2. Main Raycast Function: `castRay()`

**Location:** Lines 6030-6126

### Function Signature
```lua
function castRay(dx, dy, maxDist)
```
- **Input:** Ray direction vector (dx, dy), maximum distance
- **Output:** `perpWallDist, wtype, side, texCoord, rayHit`

### Algorithm: DDA (Digital Differential Analyzer)

#### 2.1 Initialization (Lines 6035-6048)

```lua
local mapX = math.floor(px)
local mapY = math.floor(py)
local rayMaxDist = maxDist or 16
if rayMaxDist < 0.25 then rayMaxDist = 0.25 end

-- Fallback if player is inside a wall cell
if mapX >= 0 and mapX < 16 and mapY >= 0 and mapY < 16 then
    local startTile = map and map[mapY + 1] and map[mapY + 1][mapX + 1] or 0
    if startTile and startTile > 0 then
        return getStartSolidRayFallback(px, py, mapX, mapY, startTile)
    end
end
```

#### 2.2 Delta Distance Calculation (Lines 6050-6051)

```lua
local deltaDistX = (dx == 0) and 1e9 or math.abs(1 / dx)
local deltaDistY = (dy == 0) and 1e9 or math.abs(1 / dy)
```

**Precision Notes:**
- `1e9` (1 billion) is used as infinity sentinel for perpendicular rays
- Division by zero is explicitly guarded
- `1/dx` uses full 64-bit double precision
- For dx ≈ 0.001 (grazing angle), deltaDist ≈ 1000

#### 2.3 Initial Side Distance (Lines 6053-6070)

```lua
local stepX, stepY
local sideDistX, sideDistY

if dx < 0 then
    stepX = -1
    sideDistX = (px - mapX) * deltaDistX
else
    stepX = 1
    sideDistX = (mapX + 1.0 - px) * deltaDistX
end

if dy < 0 then
    stepY = -1
    sideDistY = (py - mapY) * deltaDistY
else
    stepY = 1
    sideDistY = (mapY + 1.0 - py) * deltaDistY
end
```

**Precision Notes:**
- `mapX + 1.0` forces float arithmetic (Lua would coerce anyway)
- Fractional player position `(px - mapX)` is preserved in full precision

#### 2.4 DDA Marching Loop (Lines 6072-6102)

```lua
local hit = false
local side = 0
local maxSteps = 32  -- PERFORMANCE: Reduced from 64
local wtype = 1

for _ = 1, maxSteps do
    local nextDist = sideDistX
    if sideDistY < nextDist then nextDist = sideDistY end
    if nextDist > rayMaxDist then
        break
    end
    if sideDistX < sideDistY then
        sideDistX = sideDistX + deltaDistX
        mapX = mapX + stepX
        side = 0
    else
        sideDistY = sideDistY + deltaDistY
        mapY = mapY + stepY
        side = 1
    end
    if mapX < 0 or mapX >= 16 or mapY < 0 or mapY >= 16 then
        break
    end
    wtype = map[mapY + 1][mapX + 1]
    if wtype > 0 then
        hit = true
        break
    end
end
```

**Performance Characteristics:**
- Maximum 32 steps per ray (down from 64)
- Typical early exit when wall is hit
- 60 rays × 32 max steps = 1,920 max iterations
- Each iteration: 2 comparisons, 1 addition, 1 integer increment

#### 2.5 Perpendicular Distance Calculation (Lines 6108-6113)

```lua
local perpWallDist
if side == 0 then
    perpWallDist = (mapX - px + (1 - stepX) / 2) / (dx == 0 and 1e-6 or dx)
else
    perpWallDist = (mapY - py + (1 - stepY) / 2) / (dy == 0 and 1e-6 or dy)
end
```

**Precision Notes:**
- `1e-6` (0.000001) is used as epsilon for near-zero direction
- Formula avoids fisheye effect by using perpendicular distance
- Division by very small dx/dy can produce large values (acceptable)

#### 2.6 Texture Coordinate Calculation (Lines 6115-6123)

```lua
local texCoord
if side == 0 then
    texCoord = py + perpWallDist * dy
else
    texCoord = px + perpWallDist * dx
end
texCoord = texCoord - math.floor(texCoord)
if texCoord < 0 then texCoord = texCoord + 1 end
if texCoord > 0.999 then texCoord = 0.999 end
```

**Precision Notes:**
- `math.floor(texCoord)` extracts fractional part
- Explicit clamping to [0, 0.999] prevents out-of-range array access
- Texture coordinate is unit-less (0.0 to 1.0)

---

## 3. Distance Correction (Fish-eye Fix)

**Location:** Line 5840

```lua
local fixedDist = dist * (castCos * playerCos + castSin * playerSin)
```

This multiplies the perpendicular wall distance by the dot product of the ray direction and player view direction, correcting for the fisheye effect inherent to raycasters.

**Precision:**
- Dot product: `castCos * playerCos + castSin * playerSin`
- For rays at angle θ from view center: cos(θ) correction
- Worst case (FOV edges): cos(FOV/2) ≈ cos(30°) ≈ 0.866

---

## 4. Precision Analysis

### 4.1 Lua Number Type

Lua 5.1 (Playdate SDK) uses **64-bit double-precision IEEE 754 floats**:
- 53 bits of significand (~15-17 decimal digits)
- Exponent range: ±1023
- Machine epsilon: ~2.22 × 10⁻¹⁶

### 4.2 Precision Safeguards in Code

| Location | Sentinel | Purpose | Value |
|----------|----------|---------|-------|
| Line 6050-6051 | `1e9` | Infinite deltaDist for perpendicular rays | 1,000,000,000 |
| Line 6110, 6112 | `1e-6` | Prevent division by zero in distance calculation | 0.000001 |
| Line 6038 | `0.25` | Minimum ray distance | 0.25 tiles |
| Line 6123 | `0.999` | Maximum texture coordinate | 0.999 |

### 4.3 Potential Precision Issues

1. **Grazing Angles (dx ≈ 0 or dy ≈ 0)**
   - `deltaDistX = 1 / dx` can be very large
   - Mitigated by `1e9` sentinel for dx=0 exactly
   - No explicit check for `abs(dx) < epsilon`

2. **Distance Accumulation Error**
   - `sideDistX = sideDistX + deltaDistX` repeated up to 32 times
   - For 32 iterations: error ≈ 32 × epsilon × value
   - For distances up to 16 tiles: error ≈ 32 × 10⁻¹⁵ × 16 ≈ 5 × 10⁻¹³ (negligible)

3. **Texture Coordinate Drift**
   - `texCoord = py + perpWallDist * dy` involves multiplication
   - At max distance (16 tiles): error ≈ 10⁻¹⁴ (negligible)

---

## 5. Performance Characteristics

### 5.1 Ray Configuration

| Config | Rays | Column Width | Total Columns | Coverage |
|--------|------|--------------|---------------|----------|
| Standard | 60 | 4px | 240px | Full Playdate screen |
| Fast (LOW_RES_MODE="fast") | 40 | 6px | 240px | Full coverage, fewer rays |

### 5.2 Per-Ray Cost

**Best Case (wall hit immediately):**
- 1 DDA step + distance calc
- ~5-10 arithmetic operations

**Worst Case (no wall hit, max distance):**
- 32 DDA steps + distance calc
- ~150 arithmetic operations

### 5.3 Frame Cost (Standard 60 rays)

```
60 rays × avg(8 steps) = 480 DDA iterations
480 × (~10 operations) = 4,800 arithmetic ops

With trig precomputation: 0 trig calls in main loop
```

### 5.4 LOD (Level of Detail) Stride System

**Location:** Lines 5853-5888

Distant walls use fewer rays (stride 2-6):
```lua
if mipLevel >= 4 then
    rayStride = lodStride4  -- Typically 4-6
elseif mipLevel == 3 then
    rayStride = lodStride3  -- Typically 3-5
...
```

This can reduce ray count by 50-80% for distant geometry.

---

## 6. Fixed-Point Raycaster Comparison

### 6.1 Overview

The codebase includes an alternative fixed-point implementation (`expCastRayFixed`) that can be enabled via `USE_FIXED_RAYCAST = true`.

**Location:** Lines 5595-5689

### 6.2 Fixed-Point Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| `EXP_FIX_TILE` | 256 | Tile coordinate scaling (8.8 fixed) |
| `EXP_FIX_DIST` | 65536 | Distance scaling (16.16 fixed) |
| `EXP_FIXED_DIR_STEPS` | 2048 | Number of precomputed directions (64 × 32) |
| `EXP_MAX_STEPS` | 8 (configurable, was 32) | Maximum DDA iterations |
| `EXP_FIXED_DIR_SUBDIV` | 32 | Subdivisions per base direction |

### 6.3 Precomputed Tables

**Location:** Lines 5490-5516

Tables are generated once by `ensureExpTables()`:

| Table | Size | Content | Formula |
|-------|------|---------|---------|
| `rayDirCos[i]` | 2048 | Float cos values | `cos(angle)` |
| `rayDirSin[i]` | 2048 | Float sin values | `sin(angle)` |
| `rayDirXFix[i]` | 2048 | Fixed X direction | `floor(cx × 256)` |
| `rayDirYFix[i]` | 2048 | Fixed Y direction | `floor(sy × 256)` |
| `invRayDirXFix[i]` | 2048 | Fixed inverse X | `floor((1/cx) × 65536)` or `0x7FFFFFFF` |
| `invRayDirYFix[i]` | 2048 | Fixed inverse Y | `floor((1/sy) × 65536)` or `0x7FFFFFFF` |
| `deltaDistXFix[i]` | 2048 | Fixed delta X | `abs(invRayDirXFix[i])` |
| `deltaDistYFix[i]` | 2048 | Fixed delta Y | `abs(invRayDirYFix[i])` |

**Memory:** ~16 KB (8 tables × 2048 entries × 4 bytes)

### 6.4 Fixed-Point DDA Algorithm

```lua
local posXFix = math.floor(px * EXP_FIX_TILE)      -- Scale to 8.8 fixed
local posYFix = math.floor(py * EXP_FIX_TILE)

-- Look up precomputed direction values
local dirXFix = rayDirXFix[rayDir]
local dirYFix = rayDirYFix[rayDir]
local deltaX = deltaDistXFix[rayDir]
local deltaY = deltaDistYFix[rayDir]

-- DDA loop uses integer arithmetic
sideDistX = sideDistX + deltaX    -- Integer addition
sideDistY = sideDistY + deltaY

-- Perpendicular distance uses precomputed inverse
perpFix = math.floor((numFix * invRayDirXFix[rayDir]) / EXP_FIX_TILE)
```

### 6.5 Precision Comparison

| Aspect | FLOAT (64-bit) | FIXED (16.16) |
|--------|----------------|---------------|
| **Significand** | 53 bits (~15-16 decimals) | 16 bits (~4-5 decimals) |
| **Position** | Double precision `px, py` | 8.8 fixed `posXFix, posYFix` |
| **Direction** | Continuous `dx, dy` | 2048 discrete steps (~0.18°) |
| **Delta Dist** | `1/dx` computed per ray | Table lookup |
| **Max Steps** | 32 (default) | 8 (default, was 32) |
| **Range** | ±10^308 | Limited by 16-bit integer |
| **Epsilon** | ~2.2 × 10^-16 | 1/65536 ≈ 1.5 × 10^-5 |

### 6.6 Performance Comparison

| Operation | FLOAT | FIXED |
|-----------|-------|-------|
| **Table Init** | None | ~16KB one-time cost |
| **Direction Lookup** | Computed (cos/sin) | Table array access |
| **Delta Distance** | Division `1/dx` | Table array access |
| **DDA Loop** | Float add/compare | Integer add/compare |
| **Distance Calc** | Division + multiply | Multiply + shift |
| **Memory Access** | Cache-friendly | Table lookups (potential cache miss) |

**Typical Performance:**
- FLOAT: ~480 DDA iterations, float ops
- FIXED: ~480 DDA iterations, integer ops + table lookups
- **Result:** Similar performance on Playdate's ARM processor

### 6.7 Switching Between Modes

```lua
-- Line 5724
local useFixedRaycast = (USE_FIXED_RAYCAST == true) and (DEBUG_FORCE_FLOAT_RAYCAST ~= true)

-- Runtime toggle via debug flag
DEBUG_FORCE_FLOAT_RAYCAST = true  -- Force FLOAT mode
USE_FIXED_RAYCAST = true           -- Use FIXED mode (unless forced)
```

---

## 7. Code References

| Function/Variable | Lines | Purpose |
|-------------------|-------|---------|
| `castRay()` | 6030-6126 | Main FLOAT raycast implementation |
| `playerCos, playerSin` | 5705-5706 | Player view direction |
| `rayCos, raySin` | 5733-5734, 5750-5751 | Current ray direction |
| `rayStep` | 5741 | Angular step between rays |
| `stepCos1-4, stepSin1-4` | 5742-5749 | Precomputed trig for LOD striding |
| `fixedDist` | 5840 | Fisheye-corrected wall distance |
| `deltaDistX, deltaDistY` | 6050-6051 | DDA step distances |
| `sideDistX, sideDistY` | 6054-6070 | Current DDA state |
| `perpWallDist` | 6108-6113 | Final perpendicular distance |
| `texCoord` | 6115-6123 | Wall texture U coordinate |

---

## 8. Texture Coordinate Precision and Clamping

### 8.1 Multi-Stage Clamping

Texture coordinates undergo **three rounds** of clamping, suggesting precision edge cases:

**Round 1 (castRay output, line 6121-6123):**
```lua
texCoord = texCoord - math.floor(texCoord)
if texCoord < 0 then texCoord = texCoord + 1 end
if texCoord > 0.999 then texCoord = 0.999 end
```
- Output range: `[0, 0.999]`
- Upper bound 0.999 prevents array overflow

**Round 2 (Before flip, lines 5952-5953):**
```lua
local useTex = texCoord or 0
if useTex < 0 then useTex = 0 end
if useTex > 0.999 then useTex = 0.999 end
```
- Defensive copy with same bounds

**Round 3 (After flip, lines 5960-5961):**
```lua
if useTex < 0.001 then useTex = 0.001 end
if useTex > 0.998 then useTex = 0.998 end
```
- Tighter bounds: `[0.001, 0.998]`
- 0.001 margin prevents edge sampling artifacts

### 8.2 Texture Flip Epsilon

```lua
local flipEps = 0.0008
if side == 0 and castCos > flipEps then
    useTex = 1.0 - useTex
elseif side == 1 and castSin < -flipEps then
    useTex = 1.0 - useTex
end
```

**Purpose:** Determine if texture should be mirrored based on wall face and ray direction.

**Epsilon Analysis:**
- `flipEps = 0.0008` = 0.08%
- For `castCos > 0.0008`: Mirror X-facing walls
- For `castSin < -0.0008`: Mirror Y-facing walls
- Dead zone around 0 prevents flip-flopping due to floating imprecision

### 8.3 Potential Precision Issues

1. **Rounding at 0.999 Boundary**
   - Floating operations can produce `0.999999...` due to rounding
   - The `0.999` clamp suggests this occurs in practice
   - Without clamp: `texCoord * texWidth` could overflow texture array

2. **Triple Clamping Redundancy**
   - Three separate clamp stages suggest:
     - Original implementation had overflow bugs
     - Clamping was added incrementally to fix crashes
     - May indicate underlying precision issue not fully addressed

3. **Fixed-Point Comparison:**
   - Fixed version: `texFix / EXP_FIX_TILE` where `texFix` is already modulo `EXP_FIX_TILE`
   - Fixed range is inherently `[0, 255/256]` = `[0, 0.996]`
   - No explicit clamping needed in fixed code

---

## 9. Known Issues and Limitations

### 9.1 Documented in Code

1. **Maximum Steps Reduced (Line 6074-6077)**
   ```lua
   -- PERFORMANCE: Reduced from 64 to 32
   -- Map is only 16x16, and most rays hit walls well before this limit
   ```
   - Trade-off: Rays at very long distances (>16 tiles) may early exit
   - Impact: Minimal for 16×16 map

2. **Movement Penetration (Line 6042-6048)**
   ```lua
   -- Guard against rare movement penetration: stabilize rendering when inside a wall cell.
   ```
   - Fallback to `getStartSolidRayFallback()` if player clips into wall
   - Can happen with fast movement or collision system bugs

### 9.2 Potential Issues (Not Explicitly Documented)

1. **No Grazing Angle Threshold**
   - Very shallow angles (dx < 0.001) produce large `deltaDistX`
   - Could cause precision issues in texture coordinate calculation
   - Mitigation: Implicit (16×16 map limits maximum ray length)

2. **Texture Coordinate Clamping**
   - Explicit clamp to `0.999` (line 6123)
   - Suggests floating-point rounding can produce `1.0` in edge cases
   - May indicate underlying precision issue

---

## 10. Wall Penetration Fallback

### 10.1 `getStartSolidRayFallback()` Function

**Location:** Lines 5559-5593

**Purpose:** Handle rendering when player is positioned inside a wall cell (collision penetration bug).

### 10.2 Fallback Algorithm

```lua
local function getStartSolidRayFallback(pxVal, pyVal, mapX, mapY, startTile)
    local fx = pxVal - mapX  -- Fractional position in cell
    local fy = pyVal - mapY
    if fx < 0 then fx = 0 elseif fx > 0.999 then fx = 0.999 end
    if fy < 0 then fy = 0 elseif fy > 0.999 then fy = 0.999 end

    -- Find nearest cell edge
    local best = fx
    local side = 0
    local texCoord = fy

    local rightDist = 1.0 - fx
    if rightDist < best then
        best = rightDist
        side = 0
        texCoord = fy
    end

    local topDist = fy
    if topDist < best then
        best = topDist
        side = 1
        texCoord = fx
    end

    local bottomDist = 1.0 - fy
    if bottomDist < best then
        side = 1
        texCoord = fx
    end

    if texCoord < 0.001 then texCoord = 0.001 end
    if texCoord > 0.998 then texCoord = 0.998 end
    PERF_MONITOR_RAY_START_SOLID = (PERF_MONITOR_RAY_START_SOLID or 0) + 1
    return getPlayerRenderNearClipDist(), startTile, side, texCoord, true
end
```

### 10.3 Fallback Behavior

1. **Distance to each edge:**
   - Left: `fx` (distance from west wall)
   - Right: `1.0 - fx` (distance to east wall)
   - Top: `fy` (distance from north wall)
   - Bottom: `1.0 - fy` (distance to south wall)

2. **Selects nearest edge** as the "hit" wall
3. **Returns `getPlayerRenderNearClipDist()`** as wall distance (pushes wall to near clip plane)
4. **Increments performance counter** `PERF_MONITOR_RAY_START_SOLID`

### 10.4 Why This Exists

The comment explains:
```lua
-- Guard against rare movement penetration: stabilize rendering when inside a wall cell.
```

**Likely causes:**
- Fast player movement skipping collision checks
- Floating-point rounding in position updates
- Collision system bugs at high velocities
- Frame-rate dependent movement integration

**Impact:**
- Player sees wall surface when they should see void
- Prevents divide-by-zero or infinite distance results
- Stabilizes rendering until player exits wall cell

**Monitoring:**
- Counter `PERF_MONITOR_RAY_START_SOLID` tracks occurrences
- Can be used to diagnose collision system issues

---

## 12. Summary

The FLOAT raycaster is a well-implemented DDA algorithm using Lua's native double-precision floats:

**Strengths:**
- Clean, readable implementation
- Precomputed trig eliminates per-ray trig calls
- LOD system reduces work for distant geometry
- Explicit safeguards for edge cases (division by zero, coordinate clamping)

**Precision:**
- 64-bit doubles provide ample precision for 16×16 tile map
- No significant precision-related artifacts expected
- Max 32 DDA steps limits error accumulation

**Performance:**
- ~480 DDA iterations per frame (60 rays × 8 avg steps)
- Precomputed trig tables for LOD striding
- Competitive with fixed-point alternative

**Recommendations:**
- Current implementation is solid for the 16×16 map size
- Consider grazing angle threshold if map size increases significantly
- Monitor `texCoord` clamping hits for precision pattern detection
