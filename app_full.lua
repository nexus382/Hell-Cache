-- VMU Pro Dungeon Raycaster
-- Castle dungeon with detailed sprites

import "api/system"

enableBootLogs = false
enablePerfLogs = false
showFpsOverlay = true
lastFps = 0

DEBUG_PERF_MONITOR = false
PERF_MONITOR_SAMPLE_EVERY = 12
PERF_MONITOR_LOG_INTERVAL_US = 1000000
PERF_MONITOR_ALPHA = 0.25
PERF_MONITOR_ACTIVE_SAMPLE = false
PERF_MONITOR_LAST_FRAME_US = 0
PERF_MONITOR_LAST_LOG_US = 0
PERF_MONITOR_EMA_FRAME_US = 0
PERF_MONITOR_EMA_RAYCAST_US = 0
PERF_MONITOR_EMA_WALL_US = 0
PERF_MONITOR_EMA_FOG_US = 0
PERF_MONITOR_EMA_INPUT_US = 0
PERF_MONITOR_EMA_AUDIO_US = 0
PERF_MONITOR_EMA_SIM_US = 0
PERF_MONITOR_EMA_LOGIC_US = 0
PERF_MONITOR_EMA_RENDER_US = 0
PERF_MONITOR_EMA_PRESENT_US = 0
PERF_MONITOR_EMA_SLEEP_US = 0
PERF_MONITOR_SAMPLE_RAYCAST_US = 0
PERF_MONITOR_SAMPLE_WALL_US = 0
PERF_MONITOR_SAMPLE_FOG_US = 0
PERF_MONITOR_SAMPLE_INPUT_US = 0
PERF_MONITOR_SAMPLE_AUDIO_US = 0
PERF_MONITOR_SAMPLE_SIM_US = 0
PERF_MONITOR_SAMPLE_LOGIC_US = 0
PERF_MONITOR_SAMPLE_RENDER_US = 0
PERF_MONITOR_SAMPLE_PRESENT_US = 0
PERF_MONITOR_SAMPLE_SLEEP_US = 0
PERF_MONITOR_WALL_COLS_TOTAL = 0
PERF_MONITOR_WALL_COLS_TEXTURED = 0
PERF_MONITOR_WALL_COLS_FALLBACK = 0
PERF_MONITOR_FOG_COLS = 0
PERF_MONITOR_MIP_COLS_0 = 0
PERF_MONITOR_MIP_COLS_1 = 0
PERF_MONITOR_MIP_COLS_2 = 0
PERF_MONITOR_MIP_COLS_3 = 0
PERF_MONITOR_MIP_COLS_4 = 0
PERF_MONITOR_MOVE_BLOCKED = 0
PERF_MONITOR_WALL_RECOVERIES = 0
PERF_MONITOR_RAY_START_SOLID = 0
PERF_MONITOR_LAST_BASE_RAY_LABEL = "-"
PERF_MONITOR_LAST_EFFECTIVE_RAY_LABEL = "-"
PERF_MONITOR_LAST_RAYCAST_MODE = "FLOAT"

DEBUG_DOUBLE_BUFFER = true
DOUBLE_BUFFER_ACTIVE = false
DOUBLE_BUFFER_DELTA_USAGE_BYTES = 0
DOUBLE_BUFFER_DELTA_LARGEST_BYTES = 0
DOUBLE_BUFFER_OFF_USAGE_BYTES = nil
DOUBLE_BUFFER_OFF_LARGEST_BYTES = nil
DOUBLE_BUFFER_ON_USAGE_BYTES = nil
DOUBLE_BUFFER_ON_LARGEST_BYTES = nil
DOUBLE_BUFFER_PRESENT_ERROR_COUNT = 0
DOUBLE_BUFFER_FORCED_TITLE_OFF = false

local function getDoubleBufferPrefLabel()
    return DEBUG_DOUBLE_BUFFER and "ON" or "OFF"
end

local function getDoubleBufferActiveLabel()
    return DOUBLE_BUFFER_ACTIVE and "ON" or "OFF"
end

local function getDoubleBufferStatusLabel()
    local suffix = ""
    if DOUBLE_BUFFER_FORCED_TITLE_OFF then
        suffix = " T"
    end
    return "P" .. getDoubleBufferPrefLabel() .. " A" .. getDoubleBufferActiveLabel() .. suffix
end

local function applyRuntimeLogLevel()
    if vmupro and vmupro.system and vmupro.system.setLogLevel then
        local level = vmupro.system.LOG_DEBUG
        if not enableBootLogs and not enablePerfLogs then
            level = vmupro.system.LOG_ERROR
        end
        vmupro.system.setLogLevel(level)
    end
end

local function logBoot(level, message)
    if not enableBootLogs then return end
    if vmupro and vmupro.system and vmupro.system.log then
        vmupro.system.log(level, "BOOT", message)
    end
end

local function logPerf(message)
    if not enablePerfLogs then return end
    if vmupro and vmupro.system and vmupro.system.log then
        vmupro.system.log(vmupro.system.LOG_INFO, "PERF", message)
    end
end

local function perfNowUs()
    if vmupro and vmupro.system and vmupro.system.getTimeUs then
        return vmupro.system.getTimeUs()
    end
    return nil
end

local function perfEma(prev, sample)
    if not sample or sample <= 0 then
        return prev or 0
    end
    if not prev or prev <= 0 then
        return sample
    end
    local alpha = PERF_MONITOR_ALPHA or 0.25
    return prev + (sample - prev) * alpha
end

local function perfMonitorBeginFrame()
    local sampleEvery = PERF_MONITOR_SAMPLE_EVERY or 12
    if sampleEvery < 1 then sampleEvery = 1 end
    PERF_MONITOR_ACTIVE_SAMPLE = (DEBUG_PERF_MONITOR == true) and ((frameCount % sampleEvery) == 0)
    PERF_MONITOR_SAMPLE_RAYCAST_US = 0
    PERF_MONITOR_SAMPLE_WALL_US = 0
    PERF_MONITOR_SAMPLE_FOG_US = 0
    PERF_MONITOR_SAMPLE_INPUT_US = 0
    PERF_MONITOR_SAMPLE_AUDIO_US = 0
    PERF_MONITOR_SAMPLE_SIM_US = 0
    PERF_MONITOR_SAMPLE_LOGIC_US = 0
    PERF_MONITOR_SAMPLE_RENDER_US = 0
    PERF_MONITOR_SAMPLE_PRESENT_US = 0
    PERF_MONITOR_SAMPLE_SLEEP_US = 0
    PERF_MONITOR_WALL_COLS_TOTAL = 0
    PERF_MONITOR_WALL_COLS_TEXTURED = 0
    PERF_MONITOR_WALL_COLS_FALLBACK = 0
    PERF_MONITOR_FOG_COLS = 0
    PERF_MONITOR_MIP_COLS_0 = 0
    PERF_MONITOR_MIP_COLS_1 = 0
    PERF_MONITOR_MIP_COLS_2 = 0
    PERF_MONITOR_MIP_COLS_3 = 0
    PERF_MONITOR_MIP_COLS_4 = 0
    PERF_MONITOR_MOVE_BLOCKED = 0
    PERF_MONITOR_WALL_RECOVERIES = 0
    PERF_MONITOR_RAY_START_SOLID = 0
end

local function perfMonitorSetRayInfo(baseIdx, effIdx, useFixed)
    local baseLabel = "-"
    local effLabel = "-"
    if RAY_PRESETS and #RAY_PRESETS > 0 then
        local n = #RAY_PRESETS
        local b = baseIdx or RAY_PRESET_INDEX or 1
        local e = effIdx or b
        if b < 1 then b = 1 elseif b > n then b = n end
        if e < 1 then e = 1 elseif e > n then e = n end
        baseLabel = (RAY_PRESETS[b] and RAY_PRESETS[b].label) or tostring(b)
        effLabel = (RAY_PRESETS[e] and RAY_PRESETS[e].label) or tostring(e)
    end
    PERF_MONITOR_LAST_BASE_RAY_LABEL = baseLabel
    PERF_MONITOR_LAST_EFFECTIVE_RAY_LABEL = effLabel
    PERF_MONITOR_LAST_RAYCAST_MODE = useFixed and "FIXED" or "FLOAT"
end

local function perfMonitorEndFrame(frameUs, frameNowUs)
    local frame = frameUs or 0
    if frame < 0 then frame = 0 end
    PERF_MONITOR_LAST_FRAME_US = frame
    PERF_MONITOR_EMA_FRAME_US = perfEma(PERF_MONITOR_EMA_FRAME_US, frame)

    if PERF_MONITOR_ACTIVE_SAMPLE then
        PERF_MONITOR_EMA_RAYCAST_US = perfEma(PERF_MONITOR_EMA_RAYCAST_US, PERF_MONITOR_SAMPLE_RAYCAST_US)
        PERF_MONITOR_EMA_WALL_US = perfEma(PERF_MONITOR_EMA_WALL_US, PERF_MONITOR_SAMPLE_WALL_US)
        PERF_MONITOR_EMA_FOG_US = perfEma(PERF_MONITOR_EMA_FOG_US, PERF_MONITOR_SAMPLE_FOG_US)
        PERF_MONITOR_EMA_INPUT_US = perfEma(PERF_MONITOR_EMA_INPUT_US, PERF_MONITOR_SAMPLE_INPUT_US)
        PERF_MONITOR_EMA_AUDIO_US = perfEma(PERF_MONITOR_EMA_AUDIO_US, PERF_MONITOR_SAMPLE_AUDIO_US)
        PERF_MONITOR_EMA_SIM_US = perfEma(PERF_MONITOR_EMA_SIM_US, PERF_MONITOR_SAMPLE_SIM_US)
        PERF_MONITOR_EMA_LOGIC_US = perfEma(PERF_MONITOR_EMA_LOGIC_US, PERF_MONITOR_SAMPLE_LOGIC_US)
        PERF_MONITOR_EMA_RENDER_US = perfEma(PERF_MONITOR_EMA_RENDER_US, PERF_MONITOR_SAMPLE_RENDER_US)
        PERF_MONITOR_EMA_PRESENT_US = perfEma(PERF_MONITOR_EMA_PRESENT_US, PERF_MONITOR_SAMPLE_PRESENT_US)
        PERF_MONITOR_EMA_SLEEP_US = perfEma(PERF_MONITOR_EMA_SLEEP_US, PERF_MONITOR_SAMPLE_SLEEP_US)
    end

    local nowUs = frameNowUs or perfNowUs()
    if not DEBUG_PERF_MONITOR or not enablePerfLogs or not nowUs then
        return
    end
    if PERF_MONITOR_LAST_LOG_US == 0 then
        PERF_MONITOR_LAST_LOG_US = nowUs
    end
    if (nowUs - PERF_MONITOR_LAST_LOG_US) >= (PERF_MONITOR_LOG_INTERVAL_US or 1000000) then
        local dbufStatus = getDoubleBufferStatusLabel()
        logPerf(string.format(
            "MON frame=%.2fms ray=%.2fms wall=%.2fms fog=%.2fms sec(i/a/s/l/r/p/z)=%.2f/%.2f/%.2f/%.2f/%.2f/%.2f/%.2fms rays=%s->%s mode=%s dbuf=%s dU=%dB dL=%dB cols=%d tex=%d fb=%d fogCols=%d mblk=%d rec=%d rsolid=%d",
            (PERF_MONITOR_EMA_FRAME_US or 0) / 1000.0,
            (PERF_MONITOR_EMA_RAYCAST_US or 0) / 1000.0,
            (PERF_MONITOR_EMA_WALL_US or 0) / 1000.0,
            (PERF_MONITOR_EMA_FOG_US or 0) / 1000.0,
            (PERF_MONITOR_EMA_INPUT_US or 0) / 1000.0,
            (PERF_MONITOR_EMA_AUDIO_US or 0) / 1000.0,
            (PERF_MONITOR_EMA_SIM_US or 0) / 1000.0,
            (PERF_MONITOR_EMA_LOGIC_US or 0) / 1000.0,
            (PERF_MONITOR_EMA_RENDER_US or 0) / 1000.0,
            (PERF_MONITOR_EMA_PRESENT_US or 0) / 1000.0,
            (PERF_MONITOR_EMA_SLEEP_US or 0) / 1000.0,
            tostring(PERF_MONITOR_LAST_BASE_RAY_LABEL or "-"),
            tostring(PERF_MONITOR_LAST_EFFECTIVE_RAY_LABEL or "-"),
            tostring(PERF_MONITOR_LAST_RAYCAST_MODE or "FLOAT"),
            dbufStatus,
            DOUBLE_BUFFER_DELTA_USAGE_BYTES or 0,
            DOUBLE_BUFFER_DELTA_LARGEST_BYTES or 0,
            PERF_MONITOR_WALL_COLS_TOTAL or 0,
            PERF_MONITOR_WALL_COLS_TEXTURED or 0,
            PERF_MONITOR_WALL_COLS_FALLBACK or 0,
            PERF_MONITOR_FOG_COLS or 0,
            PERF_MONITOR_MOVE_BLOCKED or 0,
            PERF_MONITOR_WALL_RECOVERIES or 0,
            PERF_MONITOR_RAY_START_SOLID or 0
        ))
        PERF_MONITOR_LAST_LOG_US = nowUs
    end
end

local function readMemoryStats()
    local stats = {}
    if not vmupro or not vmupro.system then
        return stats
    end
    if vmupro.system.getMemoryUsage then
        local ok, value = pcall(vmupro.system.getMemoryUsage)
        if ok and value then
            stats.usage = value
        end
    end
    if vmupro.system.getLargestFreeBlock then
        local ok, value = pcall(vmupro.system.getLargestFreeBlock)
        if ok and value then
            stats.largest = value
        end
    end
    if vmupro.system.getMemoryLimit then
        local ok, value = pcall(vmupro.system.getMemoryLimit)
        if ok and value then
            stats.limit = value
        end
    end
    return stats
end

local function updateDoubleBufferDeltas()
    if DOUBLE_BUFFER_ON_USAGE_BYTES and DOUBLE_BUFFER_OFF_USAGE_BYTES then
        DOUBLE_BUFFER_DELTA_USAGE_BYTES = DOUBLE_BUFFER_ON_USAGE_BYTES - DOUBLE_BUFFER_OFF_USAGE_BYTES
    else
        DOUBLE_BUFFER_DELTA_USAGE_BYTES = 0
    end
    if DOUBLE_BUFFER_ON_LARGEST_BYTES and DOUBLE_BUFFER_OFF_LARGEST_BYTES then
        DOUBLE_BUFFER_DELTA_LARGEST_BYTES = DOUBLE_BUFFER_OFF_LARGEST_BYTES - DOUBLE_BUFFER_ON_LARGEST_BYTES
    else
        DOUBLE_BUFFER_DELTA_LARGEST_BYTES = 0
    end
end

local function applyDoubleBufferMode(enable)
    local wantEnable = enable == true
    if wantEnable then
        if DOUBLE_BUFFER_ACTIVE then return true end
        if not vmupro or not vmupro.graphics or not vmupro.graphics.startDoubleBufferRenderer then
            DOUBLE_BUFFER_ACTIVE = false
            return false
        end
        local offStats = readMemoryStats()
        if offStats.usage then DOUBLE_BUFFER_OFF_USAGE_BYTES = offStats.usage end
        if offStats.largest then DOUBLE_BUFFER_OFF_LARGEST_BYTES = offStats.largest end
        local okStart, errStart = pcall(vmupro.graphics.startDoubleBufferRenderer)
        if not okStart then
            DOUBLE_BUFFER_ACTIVE = false
            local warnLevel = (vmupro and vmupro.system and vmupro.system.LOG_WARN) or 1
            logBoot(warnLevel, "startDoubleBufferRenderer failed: " .. tostring(errStart))
            return false
        end
        DOUBLE_BUFFER_ACTIVE = true
        local onStats = readMemoryStats()
        if onStats.usage then DOUBLE_BUFFER_ON_USAGE_BYTES = onStats.usage end
        if onStats.largest then DOUBLE_BUFFER_ON_LARGEST_BYTES = onStats.largest end
        updateDoubleBufferDeltas()
        if enablePerfLogs then
            logPerf(string.format(
                "DBUF ON deltaUsage=%dB deltaLargest=%dB",
                DOUBLE_BUFFER_DELTA_USAGE_BYTES or 0,
                DOUBLE_BUFFER_DELTA_LARGEST_BYTES or 0
            ))
        end
        return true
    end

    if DOUBLE_BUFFER_ACTIVE and vmupro and vmupro.graphics and vmupro.graphics.stopDoubleBufferRenderer then
        local okStop, errStop = pcall(vmupro.graphics.stopDoubleBufferRenderer)
        if not okStop then
            local warnLevel = (vmupro and vmupro.system and vmupro.system.LOG_WARN) or 1
            logBoot(warnLevel, "stopDoubleBufferRenderer failed: " .. tostring(errStop))
        end
    end
    DOUBLE_BUFFER_ACTIVE = false
    local offStats = readMemoryStats()
    if offStats.usage then DOUBLE_BUFFER_OFF_USAGE_BYTES = offStats.usage end
    if offStats.largest then DOUBLE_BUFFER_OFF_LARGEST_BYTES = offStats.largest end
    updateDoubleBufferDeltas()
    if enablePerfLogs then
        logPerf(string.format(
            "DBUF OFF deltaUsage=%dB deltaLargest=%dB",
            DOUBLE_BUFFER_DELTA_USAGE_BYTES or 0,
            DOUBLE_BUFFER_DELTA_LARGEST_BYTES or 0
        ))
    end
    return true
end

local function syncDoubleBufferForState()
    local wantActive = (DEBUG_DOUBLE_BUFFER == true)
    if gameState == STATE_TITLE then
        wantActive = false
        DOUBLE_BUFFER_FORCED_TITLE_OFF = (DEBUG_DOUBLE_BUFFER == true)
    else
        DOUBLE_BUFFER_FORCED_TITLE_OFF = false
    end
    if wantActive ~= DOUBLE_BUFFER_ACTIVE then
        applyDoubleBufferMode(wantActive)
    end
end

local function presentFrame()
    if DOUBLE_BUFFER_ACTIVE and vmupro and vmupro.graphics and vmupro.graphics.pushDoubleBufferFrame then
        local okPush, errPush = pcall(vmupro.graphics.pushDoubleBufferFrame)
        if okPush then
            return
        end
        DOUBLE_BUFFER_PRESENT_ERROR_COUNT = (DOUBLE_BUFFER_PRESENT_ERROR_COUNT or 0) + 1
        local warnLevel = (vmupro and vmupro.system and vmupro.system.LOG_WARN) or 1
        logBoot(warnLevel, "pushDoubleBufferFrame failed: " .. tostring(errPush))
        applyDoubleBufferMode(false)
    end
    vmupro.graphics.refresh()
end

if enableBootLogs and vmupro and vmupro.system and vmupro.system.log then
    logBoot(vmupro.system.LOG_ERROR, "app.lua loaded")
end

local function tryImport(mod)
    local ok, err = pcall(function() import(mod) end)
    if ok then
        logBoot(vmupro.system.LOG_ERROR, "import ok " .. mod)
    else
        logBoot(vmupro.system.LOG_ERROR, "import FAIL " .. mod .. " err=" .. tostring(err))
    end
    return ok
end

tryImport("api/display")
tryImport("api/input")
tryImport("api/sprites")
tryImport("api/audio")
tryImport("api/text")

logBoot(vmupro.system.LOG_ERROR, "after imports")

-- Fallback stub; replaced by drawTitleScreenImpl when defined
function drawTitleScreen()
    logBoot(vmupro.system.LOG_ERROR, "drawTitleScreen stub")
end

-- Safety Check Functions
local function safeLog(level, message)
    if not enableBootLogs then return end
    if vmupro.system.log then
        local lvl = vmupro.system.LOG_INFO
        if level == "ERROR" then
            lvl = vmupro.system.LOG_ERROR
        elseif level == "WARN" then
            lvl = vmupro.system.LOG_WARN
        elseif level == "DEBUG" then
            lvl = vmupro.system.LOG_DEBUG
        end
        vmupro.system.log(lvl, "SAFETY", message)
    else
        print("[SAFETY " .. level .. "] " .. message)
    end
end

local function validateSprite(sprite, context)
    if not sprite then
        safeLog("ERROR", "Sprite is nil in context: " .. (context or "unknown"))
        return false
    end
    if not sprite.width or not sprite.height then
        safeLog("ERROR", "Sprite missing width/height in context: " .. (context or "unknown"))
        return false
    end
    if sprite.width <= 0 or sprite.height <= 0 then
        safeLog("ERROR", "Sprite has invalid dimensions in context: " .. (context or "unknown") ..
               " width=" .. tostring(sprite.width) .. " height=" .. tostring(sprite.height))
        return false
    end
    return true
end

local function validateTextureDimensions(sprite, context)
    if not validateSprite(sprite, context) then
        return false
    end
    if sprite.width > 2048 or sprite.height > 2048 then
        safeLog("WARN", "Texture dimensions may be too large in context: " .. (context or "unknown") ..
               " width=" .. tostring(sprite.width) .. " height=" .. tostring(sprite.height))
    end
    return true
end

local function safeDivide(value, divisor, context)
    if divisor == 0 then
        safeLog("ERROR", "Division by zero in context: " .. (context or "unknown") ..
               " value=" .. tostring(value) .. " divisor=0")
        return 0
    end
    return value / divisor
end

local function checkArrayBounds(array, index, context)
    if not array then
        safeLog("ERROR", "Array is nil in context: " .. (context or "unknown"))
        return false
    end
    local length = #array
    if index < 1 or index > length then
        safeLog("ERROR", "Array index out of bounds in context: " .. (context or "unknown") ..
               " index=" .. tostring(index) .. " length=" .. tostring(length))
        return false
    end
    return true
end

local function safeScale(sprite, scaleX, scaleY, context)
    if not validateSprite(sprite, context) then
        return false
    end
    if type(scaleX) ~= "number" or type(scaleY) ~= "number" then
        safeLog("ERROR", "Scale values are not numbers in context: " .. (context or "unknown") ..
               " scaleX=" .. tostring(scaleX) .. " scaleY=" .. tostring(scaleY))
        return false
    end
    if scaleX < 0 or scaleY < 0 then
        safeLog("WARN", "Negative scale values in context: " .. (context or "unknown") ..
               " scaleX=" .. tostring(scaleX) .. " scaleY=" .. tostring(scaleY))
    end
    return true
end

-- Cache font state to avoid redundant VMU API calls in hot UI paths.
local lastFontId = nil
local function setFontCached(fontId)
    if lastFontId ~= fontId then
        vmupro.text.setFont(fontId)
        lastFontId = fontId
    end
end

-- Colors (RGB565 little-endian)
COLOR_BLACK = 0x0000
COLOR_WHITE = 0xFFFF
COLOR_RED = 0x00F8
COLOR_YELLOW = 0xE0FF
COLOR_ORANGE = 0x20FC
COLOR_BROWN = 0x4051
COLOR_DARK_BROWN = 0x2028
COLOR_LIGHT_BROWN = 0x6079
COLOR_GRAY = 0x8C73
COLOR_DARK_GRAY = 0x4A52
COLOR_LIGHT_GRAY = 0xCE7B
COLOR_BLUE = 0x1F00
COLOR_DARK_BLUE = 0x0E00
COLOR_LIGHT_BLUE = 0x1F42
COLOR_GREEN = 0xE007
COLOR_MAROON = 0x0060
COLOR_DARK_MAROON = 0x0040
COLOR_SILVER = 0xF7BD

-- Dungeon colors
COLOR_FLOOR = 0x6931
COLOR_CEILING = 0x2821

-- Wall colors
COLOR_STONE_L = 0x8C73
COLOR_STONE_D = 0x4A52
COLOR_BRICK_L = 0x4062
COLOR_BRICK_D = 0x0041
COLOR_MOSS_L = 0x4444
COLOR_MOSS_D = 0x2222
COLOR_METAL_L = 0x1084
COLOR_METAL_D = 0x0842
COLOR_WOOD_L = 0x4051
COLOR_WOOD_D = 0x2028

logBoot(vmupro.system.LOG_ERROR, "after color constants")

-- Base level data (used to build per-level instances)
local BASE_MAP = {
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,0,0,0,2,0,0,0,0,0,3,0,0,0,0,1},
    {1,0,0,0,1,0,1,1,1,0,0,0,1,1,0,1},
    {1,0,1,0,0,0,1,0,0,0,1,0,0,1,0,1},
    {1,0,1,1,1,0,1,0,1,1,1,1,0,1,0,1},
    {1,0,0,0,1,0,0,0,1,0,0,0,0,1,0,1},
    {1,1,1,0,1,1,1,0,1,0,1,1,0,1,0,1},
    {1,0,0,0,0,0,1,0,0,0,1,0,0,0,0,1},
    {1,0,0,1,0,0,1,1,0,0,1,0,0,1,0,1},
    {1,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1},
    {1,0,1,0,1,1,1,0,1,1,1,0,1,0,0,1},
    {1,0,1,0,0,0,0,0,0,0,0,0,1,0,0,1},
    {1,0,1,1,1,1,1,0,1,1,1,0,1,1,0,1},
    {1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,1},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
}

local function buildSingleRoomMap()
    local mapOut = {}
    for y = 0, 15 do
        local row = {}
        for x = 0, 15 do
            if x == 0 or x == 15 or y == 0 or y == 15 then
                row[#row + 1] = 1
            else
                row[#row + 1] = 0
            end
        end
        mapOut[#mapOut + 1] = row
    end
    return mapOut
end

-- Sprites: t=1 torch, t=2 barrel, t=3 table, t=4 chest, t=5 warrior, t=6 knight, t=7 health vial
local BASE_SPRITES = {
    {x=1.5, y=1.5, t=1}, {x=6.5, y=1.5, t=1}, {x=8.5, y=1.5, t=1}, {x=14.5, y=1.5, t=1},
    {x=1.5, y=5.5, t=1}, {x=14.5, y=5.5, t=1},
    {x=1.5, y=8.5, t=1}, {x=1.5, y=11.5, t=1},
    {x=14.5, y=8.5, t=1}, {x=14.5, y=11.5, t=1},
    {x=1.3, y=3.5, t=3}, {x=1.3, y=2.5, t=2}, {x=5.7, y=4.5, t=2},
    {x=10.5, y=1.3, t=4}, {x=14.3, y=3.5, t=3}, {x=10.3, y=4.7, t=2},
    {x=1.3, y=13.5, t=2}, {x=3.5, y=14.3, t=4}, {x=5.7, y=12.3, t=3},
    {x=14.3, y=13.5, t=2}, {x=13.5, y=14.3, t=4},
    {x=1.3, y=9.5, t=2}, {x=14.3, y=9.5, t=2},
    -- Warriors (red armor) - moved to open tiles
    {x=4.5, y=8.5, t=5, dir=32, tx=4.5, ty=8.5, anim=0, speed=0.02, hp=100, alive=true, startX=4.5, startY=8.5},
    {x=8.5, y=8.5, t=5, dir=48, tx=8.5, ty=8.5, anim=0, speed=0.02, hp=100, alive=true, startX=8.5, startY=8.5},
    {x=12.5, y=8.5, t=5, dir=0, tx=12.5, ty=8.5, anim=0, speed=0.02, hp=100, alive=true, startX=12.5, startY=8.5},
    {x=6.5, y=11.5, t=5, dir=16, tx=6.5, ty=11.5, anim=0, speed=0.02, hp=100, alive=true, startX=6.5, startY=11.5},
    {x=10.5, y=11.5, t=5, dir=32, tx=10.5, ty=11.5, anim=0, speed=0.02, hp=100, alive=true, startX=10.5, startY=11.5},
    -- Health vials (one per room area)
    {x=5.5, y=2.5, t=7, collected=false},   -- Top-left room
    {x=10.5, y=2.5, t=7, collected=false},  -- Top-right room
    {x=2.5, y=8.5, t=7, collected=false},   -- Left side
    {x=8.5, y=9.5, t=7, collected=false},   -- Central area
    {x=12.5, y=13.5, t=7, collected=false}, -- Bottom-right area
}

logBoot(vmupro.system.LOG_ERROR, "after base sprites")

local LEVELS = {
    [1] = {
        name = "Inner Sanctum - L1",
        playerStart = {x = 2.5, y = 2.5, dir = 0},
        assetBase = "sprites/level1/",
        map = BASE_MAP,
        sprites = BASE_SPRITES,
        assets = {warrior = true, knight = false, potion = true}
    },
    [2] = {
        name = "Inner Sanctum - L2",
        playerStart = {x = 2.5, y = 2.5, dir = 0},
        assetBase = "sprites/level2/",
        map = {
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,0,0,0,2,0,0,0,0,0,3,0,0,0,0,1},
            {1,0,0,0,1,0,1,1,1,0,0,0,1,1,0,1},
            {1,0,1,0,0,0,1,0,0,0,1,0,0,1,0,1},
            {1,0,1,1,1,0,1,0,1,1,1,1,0,1,0,1},
            {1,0,0,0,1,0,0,0,1,0,0,0,0,1,0,1},
            {1,1,1,0,1,1,1,0,1,0,1,1,0,1,0,1},
            {1,0,0,0,0,0,1,0,0,0,1,0,0,0,0,1},
            {1,0,0,1,0,0,0,1,1,0,1,0,0,1,0,1},
            {1,0,1,0,1,0,0,0,0,0,1,0,0,0,0,1},
            {1,0,1,0,1,1,1,0,1,1,0,0,1,0,0,1},
            {1,0,1,0,0,0,0,0,0,0,1,0,1,0,0,1},
            {1,0,1,1,1,1,1,0,1,1,0,0,1,1,0,1},
            {1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1},
            {1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
        },
            sprites = {
                {x=1.5, y=1.5, t=1}, {x=6.5, y=1.5, t=1}, {x=8.5, y=1.5, t=1}, {x=14.5, y=1.5, t=1},
                {x=1.5, y=5.5, t=1}, {x=14.5, y=5.5, t=1},
                {x=1.5, y=8.5, t=1}, {x=1.5, y=11.5, t=1},
                {x=14.5, y=8.5, t=1}, {x=14.5, y=11.5, t=1},
                {x=1.3, y=3.5, t=3}, {x=1.3, y=2.5, t=2}, {x=5.7, y=4.5, t=2},
                {x=10.5, y=1.3, t=4}, {x=14.3, y=3.5, t=3}, {x=10.3, y=4.7, t=2},
                {x=1.3, y=13.5, t=2}, {x=3.5, y=14.3, t=4}, {x=5.7, y=12.3, t=3},
                {x=14.3, y=13.5, t=2}, {x=13.5, y=14.3, t=4},
                {x=1.3, y=9.5, t=2}, {x=14.3, y=9.5, t=2},
                -- Warriors (red armor) - moved to open tiles
                {x=4.5, y=8.5, t=5, dir=32, tx=4.5, ty=8.5, anim=0, speed=0.025, hp=120, alive=true, startX=4.5, startY=8.5},
                {x=6.5, y=8.5, t=5, dir=48, tx=6.5, ty=8.5, anim=0, speed=0.025, hp=120, alive=true, startX=6.5, startY=8.5},
                {x=11.5, y=10.5, t=5, dir=0, tx=11.5, ty=10.5, anim=0, speed=0.025, hp=120, alive=true, startX=11.5, startY=10.5},
            {x=11.5, y=12.5, t=5, dir=16, tx=11.5, ty=12.5, anim=0, speed=0.025, hp=120, alive=true, startX=11.5, startY=12.5},
            {x=8.5, y=13.5, t=5, dir=32, tx=8.5, ty=13.5, anim=0, speed=0.025, hp=120, alive=true, startX=8.5, startY=13.5},
            -- Health vials
            {x=5.5, y=2.5, t=7, collected=false},
            {x=10.5, y=2.5, t=7, collected=false},
            {x=2.5, y=8.5, t=7, collected=false},
            {x=8.5, y=9.5, t=7, collected=false},
            {x=12.5, y=13.5, t=7, collected=false}
        },
        assets = {warrior = true, knight = false, potion = true}
    }
}

logBoot(vmupro.system.LOG_ERROR, "after levels")

local currentLevel = 1
local selectedLevel = 1
local REAL_LEVEL_COUNT = #LEVELS
local MAX_LEVEL = REAL_LEVEL_COUNT
LEVELS[101] = {
    name = "p-1room0-0",
    playerStart = {x = 2.5, y = 2.5, dir = 0},
    assetBase = "sprites/level1/",
    map = buildSingleRoomMap(),
    sprites = {},
    assets = {warrior = false, knight = false, potion = false},
    perfDisableEnemies = true,
    perfDisableTextures = true,
    perfDisableProps = true
}
LEVELS[102] = {
    name = "p-1room-1-0",
    playerStart = {x = 2.5, y = 2.5, dir = 0},
    assetBase = "sprites/level1/",
    map = buildSingleRoomMap(),
    sprites = {},
    assets = {warrior = false, knight = false, potion = false},
    perfDisableEnemies = false,
    perfDisableTextures = true,
    perfDisableProps = true
}
LEVELS[103] = {
    name = "p-1room-1-1",
    playerStart = {x = 2.5, y = 2.5, dir = 0},
    assetBase = "sprites/level1/",
    map = buildSingleRoomMap(),
    sprites = {},
    assets = {warrior = false, knight = false, potion = false},
    perfDisableEnemies = false,
    perfDisableTextures = false,
    perfDisableProps = true
}

LEVEL_SELECT_LIST = {
    {id = 1, label = "1"},
    {id = 2, label = "2"},
    {id = 101, label = "p-1room0-0"},
    {id = 102, label = "p-1room-1-0"},
    {id = 103, label = "p-1room-1-1"}
}
LEVEL_SELECT_COUNT = #LEVEL_SELECT_LIST
function getLevelLabel(levelId)
    for i = 1, #LEVEL_SELECT_LIST do
        local entry = LEVEL_SELECT_LIST[i]
        if entry and entry.id == levelId then
            return entry.label
        end
    end
    return tostring(levelId)
end
map = nil
sprites = nil

sinTable = {}
cosTable = {}
for i = 0, 63 do
    local angle = i * 6.28318 / 64
    sinTable[i] = math.sin(angle)
    cosTable[i] = math.cos(angle)
end

px = 2.5
py = 2.5
pdir = 0
lastSafeWallX = px
lastSafeWallY = py
app_running = true
frameCount = 0
simTickCount = 0
VIEWPORT_H = 240
HORIZON = 120  -- Eye level within viewport

-- Fixed simulation clock: gameplay speed is tied to this, not render FPS.
SIM_TARGET_HZ = 24
SIM_STEP_US = math.floor(1000000 / SIM_TARGET_HZ)
SIM_MAX_STEPS_PER_FRAME = 4
SIM_MAX_BACKLOG_STEPS = 4

-- Preserve approximate legacy 30-FPS movement feel at fixed 24-Hz simulation.
PLAYER_MOVE_SPEED_PER_SEC = 4.5
PLAYER_STRAFE_SPEED_PER_SEC = 3.0
PLAYER_TURN_STEPS_PER_SEC = 30.0
turnStepAccumulator = 0.0

-- Game state
isAttacking = 0      -- Attack animation frames remaining
attackTotalFrames = 0 -- Total frames for current attack animation
isBlocking = false   -- Currently blocking
blockStartFrame = -1000 -- Simulation tick when block was raised
blockAnim = 0        -- Shield raise animation frame (0 = hidden)
BLOCK_ANIM_FRAMES = 4
lastBlockEvent = nil  -- {amount, pct, prime, frame}
showMenu = false     -- Menu visible
menuSelection = 1    -- Current menu selection
inOptionsMenu = false -- Currently in options submenu
optionsSelection = 1  -- Current options selection
inGameDebugMenu = false -- In-game options: debug submenu

-- Options settings
soundEnabled = true   -- Sound on/off
bgmEnabled = true     -- In-game background music on/off
bgmVolumeLevel = 3    -- 1-11
gameBgmSample = nil
showHealthPercent = true  -- Health % display on/off

-- Sound effects
    gruntSample = nil
    swordHitSample = nil
    swordMissSample = nil
    yahSample = nil
    winLevelSample = nil
    argDeathSample = nil
audioInitialized = false
audioSystemActive = false
titleSample = nil            -- Title music sample
titleOverlaySample = nil     -- Title voice-over sample
titleMusicState = "stopped" -- stopped|voice_playing|music_playing
titleMusicTimer = 0
titleMusicStartUs = 0
titleVoiceStarted = false
titleMusicStarted = false
TITLE_MUSIC_VOLUME = 1.0
TITLE_VOICE_VOLUME = 1.0
TITLE_MUSIC_REPEAT_COUNT = 99
TITLE_VOICE_REPEAT_COUNT = 0
-- Attack constants
DETECTION_RANGE = 4    -- How far soldier can see player
ATTACK_RANGE = 1.0     -- Distance to attack (about 1 body length)
ATTACK_COOLDOWN = math.max(1, math.floor(2.4 * SIM_TARGET_HZ + 0.5)) -- ~2.4s between attacks
CHASE_SPEED_MULT = 3   -- Speed multiplier when chasing (sprint)
SOLDIER_SPEED_SCALE = 0.15625 -- Adjusted for 24Hz simulation (legacy 30fps tuning)

-- Player health system
playerHealth = 100     -- Current health (0-100)
MAX_HEALTH = 100
DAMAGE_PER_HIT = 10
potionSprite = nil
titleSprite = nil
wallStone = nil
wallBrick = nil
wallMoss = nil
wallMetal = nil
wallWood = nil
wallWindow = nil
wallRoof = nil
wallSheetStone = nil
wallSheetBrick = nil
wallSheetMoss = nil
wallSheetMetal = nil
wallSheetWood = nil
wallSheetWindow = nil
wallTextureLoadAttempted = false
DEBUG_DISABLE_WALL_TEXTURE = false
DEBUG_DISABLE_ROOF_TEXTURE = true
DEBUG_SKIP_SPRITES = false
WALL_TEXTURE_MODE = "proper" -- locked to proper (single renderer pipeline)
WALL_MIPMAP_ENABLED = true
DEBUG_TEXTURE_LOG = false
TEX_SAMPLER_PRESETS = {"classic_ref", "current_dx"}
TEX_SAMPLER_INDEX = 1
TEX_FORCE_COLORKEY = 0xF81F -- unlikely to exist in dungeon walls
WALL_FORCE_COLORKEY_OVERRIDE = true -- force non-black color key so dark wall texels stay opaque
MIP_NEAR_FORCE_DIST = 1.35
WALL1_FORMAT_VARIANTS = {
    {label = "PNG16", base = "sprites/wall_textures/wall-1-tile", sheet = "sprites/wall_textures/wall-1-tile-table-1-128"},
}
WALL1_FORMAT_INDEX = 1
-- Temporary diagnostic mode: bypass sheet sampling and draw full wall sprite.
WALL_TEXTURE_TEST_FULLSPRITE = false
texDiagColumnsAttempted = 0
texDiagColumnsDrawn = 0
texDiagFallbackEvents = 0
texDiagDrawWallFallbackEvents = 0
DEBUG_SHOW_BLOCK = false
RAY_PRESETS = {
    {label = "12x20", rays = 12, colW = 20},
    {label = "15x16", rays = 15, colW = 16},
    {label = "16x15", rays = 16, colW = 15},
    {label = "20x12", rays = 20, colW = 12},
    {label = "24x10", rays = 24, colW = 10},
    {label = "30x8", rays = 30, colW = 8},
    {label = "40x6", rays = 40, colW = 6},
    {label = "48x5", rays = 48, colW = 5},
    {label = "60x4", rays = 60, colW = 4},
    {label = "80x3", rays = 80, colW = 3},
    {label = "120x2", rays = 120, colW = 2},
    {label = "240x1", rays = 240, colW = 1},
}
RAY_PRESET_INDEX = 10
DRAW_DIST_PRESETS = {3, 4, 5, 6, 8, 10, 12, 14, 16, 20, 24}
DRAW_DIST_INDEX = 7
MIPMAP_DIST_PRESETS = {1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20, 24}
MIPMAP1_DIST_INDEX = 6
MIPMAP2_DIST_INDEX = 8
MIPMAP3_DIST_INDEX = 11
MIPMAP4_DIST_INDEX = 12
EXP_TEX_MAX_DIST = DRAW_DIST_PRESETS[DRAW_DIST_INDEX]
EXP_VIEW_DIST = EXP_TEX_MAX_DIST
WALL_MIPMAP_DIST1 = MIPMAP_DIST_PRESETS[MIPMAP1_DIST_INDEX]
WALL_MIPMAP_DIST2 = MIPMAP_DIST_PRESETS[MIPMAP2_DIST_INDEX]
WALL_MIPMAP_DIST3 = MIPMAP_DIST_PRESETS[MIPMAP3_DIST_INDEX]
WALL_MIPMAP_DIST4 = MIPMAP_DIST_PRESETS[MIPMAP4_DIST_INDEX]
renderCfg = {
    rayCols = 60,
    colW = 4,
    fovSteps = 9,
    twoPi = 6.28318,
    skipOddTex = false,
}
DEBUG_WALL_QUADS_LOG = false
wallQuadLogCount = 0
spriteOrderCache = {}
spriteOrderCacheFrame = -1000
PLAYER_RADIUS = 0.50
-- Slightly slimmer than visual body width to reduce "invisible corner snag" feeling.
PLAYER_COLLISION_RADIUS = 0.27
PLAYER_MOVE_SUBSTEP = 0.08
PLAYER_MOVE_SUBSTEP_STRICT = 0.04
-- Keep full collision radius at walls; avoids micro-creep when holding forward into a wall.
PLAYER_WALL_COLLISION_INSET = 0.0
PLAYER_WALL_CLEARANCE_EPSILON = 0.004
-- Prevent near-contact projection blowup when player is pressed against walls.
PLAYER_RENDER_NEAR_CLIP_DIST = 0.6
WALL_TEX_SEAM_OVERDRAW = true
WALL_TEX_SEAM_PIXELS = 1
DEBUG_DISABLE_PROPS = false
FOG_DISTANCE_PRESETS = {
    2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.5,
    7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0, 10.5, 11.0, 11.5,
    12.0, 13.0, 14.0, 15.0, 16.0, 18.0, 20.0, 24.0, 28.0
}
-- Start and full-fog use the same preset list for predictable tuning.
FOG_START_PRESETS = FOG_DISTANCE_PRESETS
FOG_END_PRESETS = FOG_DISTANCE_PRESETS
-- Legacy cutoff retained for compatibility; EXP-H now uses start/end fade range.
FOG_CUTOFF_PRESETS = FOG_DISTANCE_PRESETS
FOG_COLOR_PRESETS = {COLOR_DARK_GRAY, COLOR_GRAY, COLOR_LIGHT_GRAY, COLOR_WHITE, COLOR_BLACK, COLOR_MAROON}
FOG_COLOR_LABELS = {"DARK", "GRAY", "LGRAY", "WHITE", "BLACK", "MAROON"}
FOG_START_INDEX = 16
FOG_END_INDEX = 23
FOG_CUTOFF_INDEX = 17
FOG_COLOR_INDEX = 5
FOG_START = FOG_START_PRESETS[FOG_START_INDEX]
FOG_END = FOG_END_PRESETS[FOG_END_INDEX]
FOG_TEX_CUTOFF = FOG_CUTOFF_PRESETS[FOG_CUTOFF_INDEX]
FOG_COLOR = FOG_COLOR_PRESETS[FOG_COLOR_INDEX]
FOG_DITHER_SIZE_PRESETS = {1, 2, 3, 4, 5, 6}
FOG_DITHER_SIZE_INDEX = 1
FOG_DITHER_SIZE = FOG_DITHER_SIZE_PRESETS[FOG_DITHER_SIZE_INDEX]
FAR_TEX_OFF_PRESETS = {3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 20, 24, 999}
FAR_TEX_OFF_INDEX = 8
FAR_TEX_OFF_DIST = FAR_TEX_OFF_PRESETS[FAR_TEX_OFF_INDEX]
MIP_LOD_ENABLED = true
WALL_PROJECTION_MODE = "adaptive" -- adaptive | stable
DEBUG_DISABLE_FOG = false
DEBUG_DISABLE_EFFECTS = true
LOW_RES_WALLS = true
LOW_RES_MODE = "quality"
SHOW_MINIMAP = false
RENDERER_MODE = "exp_hybrid" -- locked single renderer
DEBUG_DISABLE_ENEMIES = false
textureDebugFrame = -1
textureDebugSamples = 0
local function wallQuadLog(msg)
    if enableBootLogs and DEBUG_WALL_QUADS_LOG and wallQuadLogCount < 30 then
        print(msg)
        wallQuadLogCount = wallQuadLogCount + 1
    end
end

local function forceSpriteColorKey(sprite, label)
    if not sprite then
        return
    end
    if sprite.transparentColor == nil then
        return
    end
    local before = sprite.transparentColor
    sprite.transparentColor = TEX_FORCE_COLORKEY
    local after = sprite.transparentColor or TEX_FORCE_COLORKEY
    safeLog("INFO", string.format(
        "[SAFETY] [TEX] %s colorKey=0x%04X -> 0x%04X",
        tostring(label or "sprite"), before, after
    ))
end
STATE_TITLE = 0
STATE_PLAYING = 1
STATE_GAME_OVER = 2
STATE_WIN = 3
STATE_LOADING = 4
gameState = STATE_TITLE
titleSelection = 1  -- 1=Start, 2=Options, 3=Exit
titleInOptions = false
titleInDebug = false
titleOptionsSelection = 1
titleDebugSelection = 1
DEBUG_PAGE_CORE = 1
DEBUG_PAGE_VIDEO = 2
DEBUG_PAGE_PERF = 3
titleDebugPage = DEBUG_PAGE_CORE
titleNeedsRedraw = true
FPS_TARGET_MODE = "uncapped" -- uncapped | 60 | 45 | 30 | 24 (render pacing only)
AUDIO_MIX_HZ_PRESETS = {20, 25, 30, 35, 40, 45, 50, 55, 60}
AUDIO_MIX_HZ_INDEX = #AUDIO_MIX_HZ_PRESETS
AUDIO_UPDATE_TARGET_HZ = AUDIO_MIX_HZ_PRESETS[AUDIO_MIX_HZ_INDEX]
AUDIO_UPDATE_STEP_US = math.floor(1000000 / AUDIO_UPDATE_TARGET_HZ)
AUDIO_UPDATE_MAX_STEPS = 3
AUDIO_UPDATE_MAX_BACKLOG_STEPS = 3

PERF_QUALITY_PRESETS = {"QUALITY", "BALANCED", "PERFORMANCE"}
PERF_QUALITY_INDEX = 0
UI_TEXT_SOLID_BG = COLOR_DARK_GRAY

local function setAudioMixHz(hz)
    local target = hz or 60
    local idx = 1
    local bestDelta = math.abs((AUDIO_MIX_HZ_PRESETS[1] or target) - target)
    for i = 2, #AUDIO_MIX_HZ_PRESETS do
        local delta = math.abs((AUDIO_MIX_HZ_PRESETS[i] or target) - target)
        if delta < bestDelta then
            bestDelta = delta
            idx = i
        end
    end
    AUDIO_MIX_HZ_INDEX = idx
    AUDIO_UPDATE_TARGET_HZ = AUDIO_MIX_HZ_PRESETS[idx]
    AUDIO_UPDATE_STEP_US = math.floor(1000000 / AUDIO_UPDATE_TARGET_HZ)
end

local function quitApp(reason)
    logBoot(vmupro.system.LOG_ERROR, "APP EXIT: " .. tostring(reason))
    app_running = false
end

local function getDebugPageName(pageId)
    if pageId == DEBUG_PAGE_VIDEO then
        return "VIDEO"
    elseif pageId == DEBUG_PAGE_PERF then
        return "PERF/Q"
    end
    return "DEBUG"
end

local function stepDebugPage(delta)
    local pages = {DEBUG_PAGE_CORE, DEBUG_PAGE_VIDEO, DEBUG_PAGE_PERF}
    local current = 1
    for i = 1, #pages do
        if pages[i] == titleDebugPage then
            current = i
            break
        end
    end
    local nextIdx = current + (delta or 1)
    if nextIdx < 1 then nextIdx = #pages end
    if nextIdx > #pages then nextIdx = 1 end
    titleDebugPage = pages[nextIdx]
    titleDebugSelection = 1
end

local function lockRendererMode()
    -- Single supported renderer path: EXP-H with proper column textures.
    if RENDERER_MODE ~= "exp_hybrid" then
        RENDERER_MODE = "exp_hybrid"
    end
    if WALL_TEXTURE_MODE ~= "proper" then
        WALL_TEXTURE_MODE = "proper"
    end
end

local function nearestPresetIndex(list, target)
    if not list or #list == 0 then return 1 end
    local bestIdx = 1
    local bestDelta = math.abs((list[1] or target) - target)
    for i = 2, #list do
        local delta = math.abs((list[i] or target) - target)
        if delta < bestDelta then
            bestDelta = delta
            bestIdx = i
        end
    end
    return bestIdx
end

local function nearestRayPresetIndex(targetRays)
    if not RAY_PRESETS or #RAY_PRESETS == 0 then
        return 1
    end
    local bestIdx = 1
    local bestDelta = math.abs((RAY_PRESETS[1].rays or targetRays) - targetRays)
    for i = 2, #RAY_PRESETS do
        local delta = math.abs((RAY_PRESETS[i].rays or targetRays) - targetRays)
        if delta < bestDelta then
            bestDelta = delta
            bestIdx = i
        end
    end
    return bestIdx
end

local function clampInt(v, minV, maxV)
    if v < minV then return minV end
    if v > maxV then return maxV end
    return v
end

local function refreshExpViewDistance()
    local texDist = EXP_TEX_MAX_DIST or DRAW_DIST_PRESETS[DRAW_DIST_INDEX] or 8.0
    local viewDist = texDist
    if not DEBUG_DISABLE_FOG then
        local fogEnd = FOG_END or texDist
        local fogView = fogEnd + 0.5
        if fogView > viewDist then
            viewDist = fogView
        end
    end
    local maxFogPreset = (FOG_DISTANCE_PRESETS and FOG_DISTANCE_PRESETS[#FOG_DISTANCE_PRESETS]) or 28.0
    if viewDist > maxFogPreset then
        viewDist = maxFogPreset
    end
    EXP_VIEW_DIST = viewDist
end

local function normalizeFogRange()
    if not FOG_START_PRESETS or not FOG_END_PRESETS then return end
    if not FOG_START_INDEX then FOG_START_INDEX = 1 end
    if not FOG_END_INDEX then FOG_END_INDEX = 1 end
    if FOG_START_INDEX < 1 then FOG_START_INDEX = 1 end
    if FOG_END_INDEX < 1 then FOG_END_INDEX = 1 end
    if FOG_START_INDEX > #FOG_START_PRESETS then FOG_START_INDEX = #FOG_START_PRESETS end
    if FOG_END_INDEX > #FOG_END_PRESETS then FOG_END_INDEX = #FOG_END_PRESETS end

    if FOG_END_INDEX <= FOG_START_INDEX then
        FOG_END_INDEX = FOG_START_INDEX + 1
        if FOG_END_INDEX > #FOG_END_PRESETS then
            FOG_END_INDEX = #FOG_END_PRESETS
            FOG_START_INDEX = math.max(1, FOG_END_INDEX - 1)
        end
    end

    FOG_START = FOG_START_PRESETS[FOG_START_INDEX]
    FOG_END = FOG_END_PRESETS[FOG_END_INDEX]
    if FOG_END <= FOG_START then
        FOG_END = FOG_START + 0.5
    end
    refreshExpViewDistance()
end

local function normalizeMipmapRanges()
    if not MIPMAP_DIST_PRESETS or #MIPMAP_DIST_PRESETS == 0 then return end
    local n = #MIPMAP_DIST_PRESETS
    if not MIPMAP1_DIST_INDEX then MIPMAP1_DIST_INDEX = 1 end
    if not MIPMAP2_DIST_INDEX then MIPMAP2_DIST_INDEX = math.min(n, 2) end
    if not MIPMAP3_DIST_INDEX then MIPMAP3_DIST_INDEX = math.min(n, 3) end
    if not MIPMAP4_DIST_INDEX then MIPMAP4_DIST_INDEX = math.min(n, 4) end

    if n == 1 then
        MIPMAP1_DIST_INDEX = 1
        MIPMAP2_DIST_INDEX = 1
        MIPMAP3_DIST_INDEX = 1
        MIPMAP4_DIST_INDEX = 1
    elseif n == 2 then
        MIPMAP1_DIST_INDEX = clampInt(MIPMAP1_DIST_INDEX, 1, 1)
        MIPMAP2_DIST_INDEX = clampInt(MIPMAP2_DIST_INDEX, 2, 2)
        MIPMAP3_DIST_INDEX = clampInt(MIPMAP3_DIST_INDEX, 2, 2)
        MIPMAP4_DIST_INDEX = clampInt(MIPMAP4_DIST_INDEX, 2, 2)
    elseif n == 3 then
        MIPMAP1_DIST_INDEX = clampInt(MIPMAP1_DIST_INDEX, 1, 1)
        MIPMAP2_DIST_INDEX = clampInt(MIPMAP2_DIST_INDEX, 2, 2)
        MIPMAP3_DIST_INDEX = clampInt(MIPMAP3_DIST_INDEX, 3, 3)
        MIPMAP4_DIST_INDEX = clampInt(MIPMAP4_DIST_INDEX, 3, 3)
    else
        -- Keep strict ordering without pushing unrelated levels to max.
        MIPMAP1_DIST_INDEX = clampInt(MIPMAP1_DIST_INDEX, 1, n - 3)
        MIPMAP2_DIST_INDEX = clampInt(MIPMAP2_DIST_INDEX, MIPMAP1_DIST_INDEX + 1, n - 2)
        MIPMAP3_DIST_INDEX = clampInt(MIPMAP3_DIST_INDEX, MIPMAP2_DIST_INDEX + 1, n - 1)
        MIPMAP4_DIST_INDEX = clampInt(MIPMAP4_DIST_INDEX, MIPMAP3_DIST_INDEX + 1, n)
    end

    WALL_MIPMAP_DIST1 = MIPMAP_DIST_PRESETS[MIPMAP1_DIST_INDEX]
    WALL_MIPMAP_DIST2 = MIPMAP_DIST_PRESETS[MIPMAP2_DIST_INDEX]
    WALL_MIPMAP_DIST3 = MIPMAP_DIST_PRESETS[MIPMAP3_DIST_INDEX]
    WALL_MIPMAP_DIST4 = MIPMAP_DIST_PRESETS[MIPMAP4_DIST_INDEX]
end

local function normalizeFarTextureCutoff()
    if not FAR_TEX_OFF_PRESETS or #FAR_TEX_OFF_PRESETS == 0 then
        FAR_TEX_OFF_INDEX = 1
        FAR_TEX_OFF_DIST = 999
        return
    end
    FAR_TEX_OFF_INDEX = clampInt(FAR_TEX_OFF_INDEX or #FAR_TEX_OFF_PRESETS, 1, #FAR_TEX_OFF_PRESETS)
    FAR_TEX_OFF_DIST = FAR_TEX_OFF_PRESETS[FAR_TEX_OFF_INDEX]
end

local function markPerfQualityCustom()
    PERF_QUALITY_INDEX = 0
end

local function applyPerfQualityPreset(newIndex)
    if not PERF_QUALITY_PRESETS or #PERF_QUALITY_PRESETS == 0 then
        return
    end
    PERF_QUALITY_INDEX = clampInt(newIndex or PERF_QUALITY_INDEX or 1, 1, #PERF_QUALITY_PRESETS)
    local preset = PERF_QUALITY_PRESETS[PERF_QUALITY_INDEX]

    if preset == "QUALITY" then
        LOW_RES_MODE = "quality"
        RAY_PRESET_INDEX = nearestRayPresetIndex(120)
        DRAW_DIST_INDEX = nearestPresetIndex(DRAW_DIST_PRESETS, 16)
        FAR_TEX_OFF_INDEX = nearestPresetIndex(FAR_TEX_OFF_PRESETS, 999)
        WALL_MIPMAP_ENABLED = true
        MIP_LOD_ENABLED = true
        FOG_DITHER_SIZE_INDEX = nearestPresetIndex(FOG_DITHER_SIZE_PRESETS, 2)
    elseif preset == "PERFORMANCE" then
        LOW_RES_MODE = "fast"
        RAY_PRESET_INDEX = nearestRayPresetIndex(48)
        DRAW_DIST_INDEX = nearestPresetIndex(DRAW_DIST_PRESETS, 8)
        FAR_TEX_OFF_INDEX = nearestPresetIndex(FAR_TEX_OFF_PRESETS, 10)
        WALL_MIPMAP_ENABLED = true
        MIP_LOD_ENABLED = true
        FOG_DITHER_SIZE_INDEX = nearestPresetIndex(FOG_DITHER_SIZE_PRESETS, 4)
    else
        -- BALANCED default
        LOW_RES_MODE = "quality"
        RAY_PRESET_INDEX = nearestRayPresetIndex(80)
        DRAW_DIST_INDEX = nearestPresetIndex(DRAW_DIST_PRESETS, 12)
        FAR_TEX_OFF_INDEX = nearestPresetIndex(FAR_TEX_OFF_PRESETS, 10)
        WALL_MIPMAP_ENABLED = true
        MIP_LOD_ENABLED = true
        FOG_DITHER_SIZE_INDEX = nearestPresetIndex(FOG_DITHER_SIZE_PRESETS, 1)
    end

    EXP_TEX_MAX_DIST = DRAW_DIST_PRESETS[DRAW_DIST_INDEX]
    if FOG_DITHER_SIZE_PRESETS and #FOG_DITHER_SIZE_PRESETS > 0 then
        FOG_DITHER_SIZE_INDEX = clampInt(FOG_DITHER_SIZE_INDEX or 1, 1, #FOG_DITHER_SIZE_PRESETS)
        FOG_DITHER_SIZE = FOG_DITHER_SIZE_PRESETS[FOG_DITHER_SIZE_INDEX]
    end
    normalizeFarTextureCutoff()
    normalizeMipmapRanges()
    refreshExpViewDistance()
end

local function getBaseEffectiveRayPresetIndex(baseIdx)
    local n = (RAY_PRESETS and #RAY_PRESETS) or 0
    if n <= 0 then return 1 end
    local idx = clampInt(baseIdx or (RAY_PRESET_INDEX or 1), 1, n)
    -- WALL RES mode should always impact rendering quality/perf.
    -- FAST mode biases one preset step lower (fewer rays / wider columns).
    if LOW_RES_WALLS and LOW_RES_MODE == "fast" and idx > 1 then
        idx = idx - 1
    end
    return idx
end

local function getEffectiveRayPresetIndex(baseIdx)
    return getBaseEffectiveRayPresetIndex(baseIdx)
end

normalizeFogRange()
normalizeMipmapRanges()
normalizeFarTextureCutoff()
refreshExpViewDistance()

local function isExpRenderer()
    return true
end
gameOverSelection = 1  -- 1 = Restart, 2 = Menu, 3 = Quit
winSelection = 1  -- 1 = Menu
winCooldown = 0   -- Delay before accepting win screen input
levelBannerTimer = 0
levelBannerMax = 150
winBannerTimer = 0
winBannerMax = 75
loadingTimer = 0
loadingMax = 45
pendingLevelStart = nil
loadingLogCount = 0
local function loadingLog(msg)
    if not enableBootLogs then return end
    if loadingLogCount < 20 then
        print(msg)
        loadingLogCount = loadingLogCount + 1
    end
end

-- Debug controls (set to true for sprite testing)
DEBUG_DISABLE_ENEMY_AGGRO = false  -- Enemies never chase/attack
DEBUG_WALK_IN_PLACE = false       -- Enemies animate walk without moving
DEBUG_FORCE_GLOBAL_WALK = false   -- Drive walk frames from global frameCount
DEBUG_FORCE_WALK_FRAMES = nil     -- Force 2-frame cycle while walk3 is under review
DEBUG_FORCE_SIDE_VIEW = false     -- Always show side view (left/right) for testing
DEBUG_FORCE_VIEW = nil            -- Set to 1 (right) or 3 (left) to lock view
DEBUG_SHOW_WALK_INFO = false      -- On-screen walk frame debug
DEBUG_WALK_OFFSET = false         -- Apply visible offset per frame for debugging
DEBUG_CYCLE_VIEW = false          -- Cycle through front/left/back/right for testing
DEBUG_CYCLE_VIEW_FRAMES = 45      -- Frames per view (about 1.5s at 30fps)

SPRITE_MAX_DIST = 12
SPRITE_MAX_DIST_SQ = SPRITE_MAX_DIST * SPRITE_MAX_DIST
SPRITE_VIS_DIST = 6
SOLDIER_ACTIVE_DIST = 8
SOLDIER_ACTIVE_DIST_SQ = SOLDIER_ACTIVE_DIST * SOLDIER_ACTIVE_DIST
ENEMY_RENDER_DIST = 7
PROP_RENDER_DIST = 5
ITEM_RENDER_DIST = 5
ENEMY_RENDER_DIST_SQ = ENEMY_RENDER_DIST * ENEMY_RENDER_DIST
PROP_RENDER_DIST_SQ = PROP_RENDER_DIST * PROP_RENDER_DIST
ITEM_RENDER_DIST_SQ = ITEM_RENDER_DIST * ITEM_RENDER_DIST

local function isEnemyType(t)
    return t == 5 or t == 6
end

local function isPropType(t)
    return (t and t >= 1 and t <= 4) or t == 7
end

-- Enemy health system
ENEMY_MAX_HP = 100
PLAYER_DAMAGE = 20
PLAYER_ATTACK_RANGE = 1.0  -- Distance player can hit enemy
soldiersKilled = 0
local totalSoldiers = 5

-- Blood particle effects
local bloodEffects = {}  -- {x, y, particles={{dx, dy, life}...}}

-- Load warrior sprites for 4 directions
local warriorFront = nil
local warriorBack = nil
local warriorLeft = nil
local warriorRight = nil

-- Load warrior walking animation sprites (left-facing)
-- Note: walk3 is missing and needs AI generation - using 2-frame cycle for now
local warriorWalk1 = nil
local warriorWalk2 = nil
local warriorWalk3 = nil
local warriorWalk1Front = nil
local warriorWalk2Front = nil
local warriorWalk3Front = nil
local warriorWalk1Back = nil
local warriorWalk2Back = nil
local warriorWalk3Back = nil
-- Load warrior walking animation sprites (right-facing, flipped)
local warriorWalk1R = nil
local warriorWalk2R = nil
local warriorWalk3R = nil
local warriorDeath = {}
local swordAttack = {}
local shieldRaise = {}
local warriorAttackFront = {}
local warriorAttackBack = {}
local warriorAttackLeft = {}
local warriorAttackRight = {}

-- Load knight sprites for 4 directions
local knightFront = nil
local knightBack = nil
local knightLeft = nil
local knightRight = nil

local function deepCopy(value)
    if type(value) ~= "table" then
        return value
    end
    local out = {}
    local len = #value
    if len > 0 then
        for i = 1, len do
            out[i] = deepCopy(value[i])
        end
        for k, v in pairs(value) do
            if type(k) ~= "number" then
                out[k] = deepCopy(v)
            end
        end
    else
        for k, v in pairs(value) do
            out[k] = deepCopy(v)
        end
    end
    return out
end

local function countEnemies(spriteList)
    local count = 0
    for i = 1, #spriteList do
        local s = spriteList[i]
        if s.t == 5 or s.t == 6 then
            count = count + 1
        end
    end
    return count
end

local function countAdjacentOpenTiles(sourceMap, mx, my)
    local function tileAt(tx, ty)
        if tx < 0 or tx > 15 or ty < 0 or ty > 15 then
            return 1
        end
        local row = sourceMap[ty + 1]
        if not row then return 1 end
        return row[tx + 1] or 1
    end
    local openCount = 0
    if tileAt(mx, my - 1) == 0 then openCount = openCount + 1 end
    if tileAt(mx, my + 1) == 0 then openCount = openCount + 1 end
    if tileAt(mx - 1, my) == 0 then openCount = openCount + 1 end
    if tileAt(mx + 1, my) == 0 then openCount = openCount + 1 end
    return openCount
end

local function wallVariantHash(mx, my, levelId, salt)
    local v = (((mx + 1) * 1973) + ((my + 1) * 9277) + ((levelId or 1) * 2663) + ((salt or 0) * 811)) % 104729
    v = ((v * 131) + 907) % 104729
    return v
end

local function chooseWallVariant(mx, my, levelId, sourceMap)
    -- Deterministic wall variety (no math.random crash risk).
    local openCount = countAdjacentOpenTiles(sourceMap, mx, my)
    local isDeadEndCap = (openCount == 1)

    -- Keep decorative types 5/6 rare so they don't feel deceptive in navigation.
    local accentRatePerThousand = isDeadEndCap and 55 or 12 -- 5.5% dead-ends, 1.2% elsewhere
    local accentRoll = wallVariantHash(mx, my, levelId, 1) % 1000
    if accentRoll < accentRatePerThousand then
        local accentPick = wallVariantHash(mx, my, levelId, 2) % 100
        if accentPick < 72 then
            return 5 -- diamond accent
        end
        return 6 -- window accent (rarer)
    end

    -- Primary walls (1-4) get broad, deterministic variety for immersion.
    local bucket = wallVariantHash(mx, my, levelId, 3) % 100
    if bucket < 30 then return 1 end
    if bucket < 57 then return 2 end
    if bucket < 80 then return 3 end
    return 4
end

local function loadLevel(levelId)
    local level = LEVELS[levelId]
    if not level then return end
    currentLevel = levelId
    if level.perfDisableEnemies ~= nil then
        DEBUG_DISABLE_ENEMIES = level.perfDisableEnemies
    end
    if level.perfDisableTextures ~= nil then
        DEBUG_DISABLE_WALL_TEXTURE = level.perfDisableTextures
    end
    if level.perfDisableProps ~= nil then
        DEBUG_DISABLE_PROPS = level.perfDisableProps
    end
    if type(level.name) == "string" and level.name:sub(1, 2) == "p-" then
        enableBootLogs = false
        DEBUG_WALL_QUADS_LOG = false
    end
    map = deepCopy(level.map)
    for my = 0, 15 do
        local row = map[my + 1]
        if row then
            for mx = 0, 15 do
                if row[mx + 1] and row[mx + 1] > 0 then
                    row[mx + 1] = chooseWallVariant(mx, my, levelId, map)
                end
            end
        end
    end
    sprites = deepCopy(level.sprites)
    local function isOpenFloor(mx, my)
        if mx < 1 or mx > 14 or my < 1 or my > 14 then return false end
        if map[my + 1][mx + 1] ~= 0 then return false end
        if map[my + 1][mx] ~= 0 then return false end
        if map[my + 1][mx + 2] ~= 0 then return false end
        if map[my][mx + 1] ~= 0 then return false end
        if map[my + 2][mx + 1] ~= 0 then return false end
        return true
    end
    local function tileAt(mx, my)
        if mx < 0 or mx > 15 or my < 0 or my > 15 then
            return 1
        end
        return map[my + 1][mx + 1] or 1
    end
    local function isDoorwayTile(mx, my)
        local n = tileAt(mx, my - 1) > 0
        local s = tileAt(mx, my + 1) > 0
        local w = tileAt(mx - 1, my) > 0
        local e = tileAt(mx + 1, my) > 0
        return (n and s and not e and not w) or (e and w and not n and not s)
    end
    local function isWallAttached(mx, my)
        if tileAt(mx, my) ~= 0 then return false end
        local n = tileAt(mx, my - 1) > 0
        local s = tileAt(mx, my + 1) > 0
        local w = tileAt(mx - 1, my) > 0
        local e = tileAt(mx + 1, my) > 0
        if isDoorwayTile(mx, my) then return false end
        -- Require a nearby wall, but avoid pure hallway gaps
        if (n and s and not e and not w) or (e and w and not n and not s) then
            return false
        end
        return n or s or w or e
    end
    if sprites then
        local filteredFloor = {}
        for i = 1, #sprites do
            local s = sprites[i]
            if s and (s.t == 1 or s.t == 2 or s.t == 3 or s.t == 4) then
                local mx = math.floor(s.x)
                local my = math.floor(s.y)
                if isWallAttached(mx, my) then
                    filteredFloor[#filteredFloor + 1] = s
                end
            elseif s and (s.t == 7 or s.t == 8) then
                local mx = math.floor(s.x)
                local my = math.floor(s.y)
                if isOpenFloor(mx, my) then
                    filteredFloor[#filteredFloor + 1] = s
                end
            else
                filteredFloor[#filteredFloor + 1] = s
            end
        end
        sprites = filteredFloor
    end
    if DEBUG_DISABLE_PROPS then
        local filtered = {}
        for i = 1, #sprites do
            local s = sprites[i]
            if s.t == 7 or not isPropType(s.t) then
                filtered[#filtered + 1] = s
            end
        end
        sprites = filtered
    end
    totalSoldiers = countEnemies(sprites)
    px = level.playerStart.x
    py = level.playerStart.y
    pdir = level.playerStart.dir
    lastSafeWallX = px
    lastSafeWallY = py
end

local function unloadLevelData()
    map = nil
    sprites = nil
    totalSoldiers = 0
end

local function freeSpriteRef(sprite)
    if sprite then
        vmupro.sprite.free(sprite)
    end
end

local function unloadMenuSprites()
    freeSpriteRef(titleSprite)
    titleSprite = nil
end

local function unloadLevelSprites()
    freeSpriteRef(warriorFront); warriorFront = nil
    freeSpriteRef(warriorBack); warriorBack = nil
    freeSpriteRef(warriorLeft); warriorLeft = nil
    freeSpriteRef(warriorRight); warriorRight = nil
    freeSpriteRef(warriorWalk1); warriorWalk1 = nil
    freeSpriteRef(warriorWalk2); warriorWalk2 = nil
    freeSpriteRef(warriorWalk3); warriorWalk3 = nil
    freeSpriteRef(warriorWalk1Front); warriorWalk1Front = nil
    freeSpriteRef(warriorWalk2Front); warriorWalk2Front = nil
    freeSpriteRef(warriorWalk3Front); warriorWalk3Front = nil
    freeSpriteRef(warriorWalk1Back); warriorWalk1Back = nil
    freeSpriteRef(warriorWalk2Back); warriorWalk2Back = nil
    freeSpriteRef(warriorWalk3Back); warriorWalk3Back = nil
    freeSpriteRef(warriorWalk1R); warriorWalk1R = nil
    freeSpriteRef(warriorWalk2R); warriorWalk2R = nil
    freeSpriteRef(warriorWalk3R); warriorWalk3R = nil
    for i = 1, #warriorDeath do
        freeSpriteRef(warriorDeath[i])
    end
    warriorDeath = {}
    for i = 1, #swordAttack do
        freeSpriteRef(swordAttack[i])
    end
    swordAttack = {}
    for i = 1, #shieldRaise do
        freeSpriteRef(shieldRaise[i])
    end
    shieldRaise = {}
    for i = 1, #warriorAttackFront do
        freeSpriteRef(warriorAttackFront[i])
    end
    for i = 1, #warriorAttackBack do
        freeSpriteRef(warriorAttackBack[i])
    end
    for i = 1, #warriorAttackLeft do
        freeSpriteRef(warriorAttackLeft[i])
    end
    for i = 1, #warriorAttackRight do
        freeSpriteRef(warriorAttackRight[i])
    end
    warriorAttackFront = {}
    warriorAttackBack = {}
    warriorAttackLeft = {}
    warriorAttackRight = {}
    freeSpriteRef(knightFront); knightFront = nil
    freeSpriteRef(knightBack); knightBack = nil
    freeSpriteRef(knightLeft); knightLeft = nil
    freeSpriteRef(knightRight); knightRight = nil
    freeSpriteRef(potionSprite); potionSprite = nil
    freeSpriteRef(wallStone); wallStone = nil
    freeSpriteRef(wallBrick); wallBrick = nil
    freeSpriteRef(wallMoss); wallMoss = nil
    freeSpriteRef(wallMetal); wallMetal = nil
    freeSpriteRef(wallWood); wallWood = nil
    freeSpriteRef(wallWindow); wallWindow = nil
    freeSpriteRef(wallRoof); wallRoof = nil
    freeSpriteRef(wallSheetStone); wallSheetStone = nil
    freeSpriteRef(wallSheetBrick); wallSheetBrick = nil
    freeSpriteRef(wallSheetMoss); wallSheetMoss = nil
    freeSpriteRef(wallSheetMetal); wallSheetMetal = nil
    freeSpriteRef(wallSheetWood); wallSheetWood = nil
    freeSpriteRef(wallSheetWindow); wallSheetWindow = nil
    wallTextureLoadAttempted = false
end

local function loadMenuSprites()
    if not titleSprite then
        titleSprite = vmupro.sprite.new("sprites/title")
        if not validateSprite(titleSprite, "loadMenuSprites") then
            safeLog("ERROR", "Failed to load title sprite")
            titleSprite = nil
        end
    end
end

-- Texture metadata and loaders (forward-declared for use in loadLevelSprites)
local textureMetadata = {}
local loadTextureWithValidation
local logTextureMemoryUsage

local function loadTextureSheetWithValidation(path, textureName)
    local success, sheet = pcall(function()
        return vmupro.sprite.newSheet(path)
    end)

    if not success then
        safeLog("ERROR", string.format(
            "Failed to load texture sheet '%s' from path: %s. Error: %s",
            textureName, path, tostring(sheet)
        ))
        return nil
    end

    if not sheet then
        safeLog("ERROR", string.format(
            "Texture sheet '%s' returned nil from path: %s",
            textureName, path
        ))
        return nil
    end

    local frameCount = sheet.frameCount or 0
    local frameWidth = sheet.frameWidth or 0
    local frameHeight = sheet.frameHeight or 0
    if frameCount <= 0 or frameWidth <= 0 or frameHeight <= 0 then
        safeLog("ERROR", string.format(
            "Texture sheet '%s' has invalid frame metadata: count=%s frame=%sx%s path=%s",
            textureName, tostring(frameCount), tostring(frameWidth), tostring(frameHeight), path
        ))
        return nil
    end

    if frameWidth ~= 1 or frameHeight ~= 128 then
        safeLog("ERROR", string.format(
            "Texture sheet '%s' has unexpected frame size %dx%d (expected 1x128): %s",
            textureName, frameWidth, frameHeight, path
        ))
        return nil
    end

    if frameCount < 64 then
        safeLog("ERROR", string.format(
            "Texture sheet '%s' has too few frames: count=%d path=%s",
            textureName, frameCount, path
        ))
        return nil
    end

    safeLog("INFO", string.format(
        "Texture sheet '%s' loaded: frame %dx%d, count=%d, transparentColor=0x%04X (column path)",
        textureName, frameWidth, frameHeight, frameCount, sheet.transparentColor or 0
    ))
    return sheet
end

local function getWall1VariantConfig()
    local variants = WALL1_FORMAT_VARIANTS or {}
    local n = #variants
    if n <= 0 then
        return {label = "PNG16", base = "sprites/wall_textures/wall-1-tile", sheet = "sprites/wall_textures/wall-1-tile-table-1-128"}
    end
    WALL1_FORMAT_INDEX = clampInt(WALL1_FORMAT_INDEX or 1, 1, n)
    return variants[WALL1_FORMAT_INDEX] or variants[1]
end

local function getWallKeyModeLabel()
    return WALL_FORCE_COLORKEY_OVERRIDE and "FORCED" or "RAW"
end

local function getWallProjectionModeLabel()
    if WALL_PROJECTION_MODE == "stable" then
        return "STABLE"
    end
    return "ADAPTIVE"
end

local function forceWallTextureColorKeys()
    if not WALL_FORCE_COLORKEY_OVERRIDE then
        return
    end
    forceSpriteColorKey(wallStone, "wall_1")
    forceSpriteColorKey(wallBrick, "wall_2")
    forceSpriteColorKey(wallMoss, "wall_3")
    forceSpriteColorKey(wallMetal, "wall_4")
    forceSpriteColorKey(wallWood, "wall_diamond")
    forceSpriteColorKey(wallWindow, "wall_window")
    forceSpriteColorKey(wallSheetStone, "wall_1_sheet")
    forceSpriteColorKey(wallSheetBrick, "wall_2_sheet")
    forceSpriteColorKey(wallSheetMoss, "wall_3_sheet")
    forceSpriteColorKey(wallSheetMetal, "wall_4_sheet")
    forceSpriteColorKey(wallSheetWood, "wall_diamond_sheet")
    forceSpriteColorKey(wallSheetWindow, "wall_window_sheet")
end

function loadWallTextures()
    if wallTextureLoadAttempted then return end
    wallTextureLoadAttempted = true
    local wall1Cfg = getWall1VariantConfig()
    local wall1BasePath = wall1Cfg.base or "sprites/wall_textures/wall-1-tile"
    local wall1SheetPath = wall1Cfg.sheet or "sprites/wall_textures/wall-1-tile-table-1-128"
    safeLog("INFO", string.format(
        "[TEX] wall1 variant=%s base=%s sheet=%s wallKey=%s colorKeyOverride=%s",
        tostring(wall1Cfg.label or "?"),
        tostring(wall1BasePath),
        tostring(wall1SheetPath),
        getWallKeyModeLabel(),
        WALL_FORCE_COLORKEY_OVERRIDE and "ON" or "OFF"
    ))
    -- Base textures (your selected names).
    wallStone = loadTextureWithValidation(wall1BasePath, "wall_1")
    wallBrick = loadTextureWithValidation("sprites/wall_textures/wall-2-tile", "wall_2")
    wallMoss = loadTextureWithValidation("sprites/wall_textures/wall-3-tile", "wall_3")
    wallMetal = loadTextureWithValidation("sprites/wall_textures/wall-4-tile", "wall_4")
    wallWood = loadTextureWithValidation("sprites/wall_textures/Wall-Diamond-Tile", "wall_diamond")
    wallWindow = loadTextureWithValidation("sprites/wall_textures/Wall-Window-Tile", "wall_window")

    -- Column-sheet path (same logic as prior PNG-working implementation).
    wallSheetStone = loadTextureSheetWithValidation(wall1SheetPath, "wall_1_sheet")
    wallSheetBrick = loadTextureSheetWithValidation("sprites/wall_textures/wall-2-tile-table-1-128", "wall_2_sheet")
    wallSheetMoss = loadTextureSheetWithValidation("sprites/wall_textures/wall-3-tile-table-1-128", "wall_3_sheet")
    wallSheetMetal = loadTextureSheetWithValidation("sprites/wall_textures/wall-4-tile-table-1-128", "wall_4_sheet")
    wallSheetWood = loadTextureSheetWithValidation("sprites/wall_textures/Wall-Diamond-Tile-table-1-128", "wall_diamond_sheet")
    wallSheetWindow = loadTextureSheetWithValidation("sprites/wall_textures/Wall-Window-Tile-table-1-128", "wall_window_sheet")
    forceWallTextureColorKeys()

    wallRoof = loadTextureWithValidation("sprites/wall_textures/roof_dirt_splatter_64", "roof")

    -- Log total texture memory usage
    logTextureMemoryUsage()
end

function unloadWallTextures()
    freeSpriteRef(wallStone); wallStone = nil
    freeSpriteRef(wallBrick); wallBrick = nil
    freeSpriteRef(wallMoss); wallMoss = nil
    freeSpriteRef(wallMetal); wallMetal = nil
    freeSpriteRef(wallWood); wallWood = nil
    freeSpriteRef(wallWindow); wallWindow = nil
    freeSpriteRef(wallRoof); wallRoof = nil
    freeSpriteRef(wallSheetStone); wallSheetStone = nil
    freeSpriteRef(wallSheetBrick); wallSheetBrick = nil
    freeSpriteRef(wallSheetMoss); wallSheetMoss = nil
    freeSpriteRef(wallSheetMetal); wallSheetMetal = nil
    freeSpriteRef(wallSheetWood); wallSheetWood = nil
    freeSpriteRef(wallSheetWindow); wallSheetWindow = nil
    wallTextureLoadAttempted = false
end

local function loadLevelSprites(levelId)
    local level = LEVELS[levelId]
    local assets = level and level.assets or {}
    local base = (level and level.assetBase) or "sprites/"

    if assets.warrior then
        warriorFront = vmupro.sprite.new(base .. "warrior_front")
        if not validateSprite(warriorFront, "warriorFront") then warriorFront = nil end
        warriorBack = vmupro.sprite.new(base .. "warrior_back")
        if not validateSprite(warriorBack, "warriorBack") then warriorBack = nil end
        warriorLeft = vmupro.sprite.new(base .. "warrior_left")
        if not validateSprite(warriorLeft, "warriorLeft") then warriorLeft = nil end
        warriorRight = vmupro.sprite.new(base .. "warrior_right")
        if not validateSprite(warriorRight, "warriorRight") then warriorRight = nil end
        warriorWalk1 = vmupro.sprite.new(base .. "warrior_walk1")
        if not validateSprite(warriorWalk1, "warriorWalk1") then warriorWalk1 = nil end
        warriorWalk2 = vmupro.sprite.new(base .. "warrior_walk2")
        if not validateSprite(warriorWalk2, "warriorWalk2") then warriorWalk2 = nil end
        local okWalkFront1, spriteWalkFront1 = pcall(vmupro.sprite.new, base .. "warrior_walk1_front")
        if okWalkFront1 then
            warriorWalk1Front = spriteWalkFront1
            if not validateSprite(warriorWalk1Front, "warriorWalk1Front") then warriorWalk1Front = nil end
        end
        local okWalkFront2, spriteWalkFront2 = pcall(vmupro.sprite.new, base .. "warrior_walk2_front")
        if okWalkFront2 then warriorWalk2Front = spriteWalkFront2 end
        local okWalkFront3, spriteWalkFront3 = pcall(vmupro.sprite.new, base .. "warrior_walk3_front")
        if okWalkFront3 then warriorWalk3Front = spriteWalkFront3 end
        local okWalkBack1, spriteWalkBack1 = pcall(vmupro.sprite.new, base .. "warrior_walk1_back")
        if okWalkBack1 then warriorWalk1Back = spriteWalkBack1 end
        local okWalkBack2, spriteWalkBack2 = pcall(vmupro.sprite.new, base .. "warrior_walk2_back")
        if okWalkBack2 then warriorWalk2Back = spriteWalkBack2 end
        local okWalkBack3, spriteWalkBack3 = pcall(vmupro.sprite.new, base .. "warrior_walk3_back")
        if okWalkBack3 then warriorWalk3Back = spriteWalkBack3 end
        -- Optional: walk3 frames (guard against missing assets)
        local okWalk3, spriteWalk3 = pcall(vmupro.sprite.new, base .. "warrior_walk3")
        if okWalk3 then warriorWalk3 = spriteWalk3 end
        warriorWalk1R = vmupro.sprite.new(base .. "warrior_walk1_r")
        warriorWalk2R = vmupro.sprite.new(base .. "warrior_walk2_r")
        local okWalk3R, spriteWalk3R = pcall(vmupro.sprite.new, base .. "warrior_walk3_r")
        if okWalk3R then warriorWalk3R = spriteWalk3R end

        warriorDeath = {}
        for i = 1, 7 do
            local okDeath, spriteDeath = pcall(vmupro.sprite.new, base .. "warrior_death" .. tostring(i))
            if okDeath then
                warriorDeath[i] = spriteDeath
                if not validateSprite(warriorDeath[i], "warriorDeath" .. tostring(i)) then
                    warriorDeath[i] = nil
                end
            end
        end

        swordAttack = {}
        for i = 1, 9 do
            local okAttack, spriteAttack = pcall(vmupro.sprite.new, base .. "sword_attack" .. tostring(i))
            if okAttack then
                swordAttack[i] = spriteAttack
                if not validateSprite(swordAttack[i], "swordAttack" .. tostring(i)) then
                    swordAttack[i] = nil
                end
            end
        end

        shieldRaise = {}
        for i = 1, (BLOCK_ANIM_FRAMES or 8) do
            local okShield, sprShield = pcall(vmupro.sprite.new, "sprites/shield_raise" .. tostring(i))
            if okShield then
                shieldRaise[i] = sprShield
                if not validateSprite(shieldRaise[i], "shield_raise" .. tostring(i)) then
                    shieldRaise[i] = nil
                end
            end
        end

        warriorAttackFront = {}
        warriorAttackBack = {}
        warriorAttackLeft = {}
        warriorAttackRight = {}
        for i = 1, 2 do
            local okFront, sprFront = pcall(vmupro.sprite.new, base .. "warrior_attack_front" .. tostring(i))
            if okFront then warriorAttackFront[i] = sprFront end
            local okBack, sprBack = pcall(vmupro.sprite.new, base .. "warrior_attack_back" .. tostring(i))
            if okBack then warriorAttackBack[i] = sprBack end
            local okLeft, sprLeft = pcall(vmupro.sprite.new, base .. "warrior_attack_left" .. tostring(i))
            if okLeft then warriorAttackLeft[i] = sprLeft end
            local okRight, sprRight = pcall(vmupro.sprite.new, base .. "warrior_attack_right" .. tostring(i))
            if okRight then warriorAttackRight[i] = sprRight end
        end
    end

    if assets.knight then
        knightFront = vmupro.sprite.new(base .. "knight_front")
        if not validateSprite(knightFront, "knightFront") then knightFront = nil end
        knightBack = vmupro.sprite.new(base .. "knight_back")
        if not validateSprite(knightBack, "knightBack") then knightBack = nil end
        knightLeft = vmupro.sprite.new(base .. "knight_left")
        if not validateSprite(knightLeft, "knightLeft") then knightLeft = nil end
        knightRight = vmupro.sprite.new(base .. "knight_right")
        if not validateSprite(knightRight, "knightRight") then knightRight = nil end
    end

    if assets.potion then
        potionSprite = vmupro.sprite.new(base .. "potion")
        if not validateSprite(potionSprite, "potionSprite") then potionSprite = nil end
    end
    if DEBUG_DISABLE_WALL_TEXTURE then
        unloadWallTextures()
    else
        loadWallTextures()
    end
end

-- Load texture with dimension validation and error handling
loadTextureWithValidation = function(path, textureName)
    local success, sprite = pcall(function()
        return vmupro.sprite.new(path)
    end)

    if not success then
        safeLog("ERROR", string.format(
            "Failed to load texture '%s' from path: %s. Error: %s",
            textureName, path, tostring(sprite)
        ))
        return nil
    end

    if not sprite then
        safeLog("ERROR", string.format(
            "Texture '%s' returned nil from path: %s",
            textureName, path
        ))
        return nil
    end

    -- Get texture dimensions
    local width = sprite.width
    local height = sprite.height

    if not width or not height or width <= 0 or height <= 0 then
        safeLog("ERROR", string.format(
            "Texture '%s' has invalid dimensions: %dx%d (path: %s)",
            textureName, width or 0, height or 0, path
        ))
        safeLog("ERROR", string.format(
            "Texture '%s' failed validation: width=%s, height=%s, path=%s",
            textureName, tostring(width), tostring(height), path
        ))
        return nil
    end

    -- Additional validation with safety function
    if not validateTextureDimensions(sprite, "loadTextureWithValidation:" .. textureName) then
        return nil
    end

    -- Store metadata
    textureMetadata[textureName] = {
        path = path,
        width = width,
        height = height,
        pixelCount = width * height,
        loaded = true
    }

    -- Log successful load with dimensions
    safeLog("INFO", string.format(
        "Loaded texture '%s': %dx%d (%d pixels) from %s transparentColor=0x%04X",
        textureName, width, height, width * height, path, sprite.transparentColor or 0
    ))

    return sprite
end

-- Log total texture memory usage
logTextureMemoryUsage = function()
    local totalPixels = 0
    local textureCount = 0

    for name, metadata in pairs(textureMetadata) do
        if metadata.loaded then
            totalPixels = totalPixels + metadata.pixelCount
            textureCount = textureCount + 1
        end
    end

    -- Estimate memory (assuming 2 bytes per pixel for RGB565)
    local estimatedBytes = totalPixels * 2
    local estimatedKB = estimatedBytes / 1024

    safeLog("INFO", string.format(
        "Texture memory summary: %d textures, %d total pixels, ~%.2f KB",
        textureCount, totalPixels, estimatedKB
    ))

    return {
        textureCount = textureCount,
        totalPixels = totalPixels,
        estimatedBytes = estimatedBytes,
        estimatedKB = estimatedKB
    }
end

local function unloadLevelAudio()
    if not audioInitialized then return end
    if gruntSample then
        vmupro.sound.sample.stop(gruntSample)
        vmupro.sound.sample.free(gruntSample)
        gruntSample = nil
    end
    if swordHitSample then
        vmupro.sound.sample.stop(swordHitSample)
        vmupro.sound.sample.free(swordHitSample)
        swordHitSample = nil
    end
    if swordMissSample then
        vmupro.sound.sample.stop(swordMissSample)
        vmupro.sound.sample.free(swordMissSample)
        swordMissSample = nil
    end
    if yahSample then
        vmupro.sound.sample.stop(yahSample)
        vmupro.sound.sample.free(yahSample)
        yahSample = nil
    end
    if winLevelSample then
        vmupro.sound.sample.stop(winLevelSample)
        vmupro.sound.sample.free(winLevelSample)
        winLevelSample = nil
    end
    if argDeathSample then
        vmupro.sound.sample.stop(argDeathSample)
        vmupro.sound.sample.free(argDeathSample)
        argDeathSample = nil
    end
    audioInitialized = false
    if audioSystemActive and not titleSample then
        vmupro.audio.exitListenMode()
        audioSystemActive = false
    end
end

local function loadLevelAudio()
    if audioInitialized then return end
    if not audioSystemActive then
        vmupro.audio.startListenMode()
        audioSystemActive = true
    end


    gruntSample = vmupro.sound.sample.new("sounds/grunt")
    if gruntSample then
        vmupro.sound.sample.setVolume(gruntSample, 0.7, 0.7)
        if enableBootLogs then safeLog("INFO", "Loaded sample: grunt") end
    else
        if enableBootLogs then safeLog("WARN", "Failed to load sample: grunt") end
    end

    swordHitSample = vmupro.sound.sample.new("sounds/sword_swing_connect")
    if swordHitSample then
        vmupro.sound.sample.setVolume(swordHitSample, 0.7, 0.7)
        if enableBootLogs then safeLog("INFO", "Loaded sample: sword_swing_connect") end
    else
        if enableBootLogs then safeLog("WARN", "Failed to load sample: sword_swing_connect") end
    end

    swordMissSample = vmupro.sound.sample.new("sounds/sword_miss")
    if swordMissSample then
        vmupro.sound.sample.setVolume(swordMissSample, 0.7, 0.7)
        if enableBootLogs then safeLog("INFO", "Loaded sample: sword_miss") end
    else
        if enableBootLogs then safeLog("WARN", "Failed to load sample: sword_miss") end
    end

    yahSample = vmupro.sound.sample.new("sounds/yah")
    if yahSample then
        vmupro.sound.sample.setVolume(yahSample, 0.7, 0.7)
        if enableBootLogs then safeLog("INFO", "Loaded sample: yah") end
    else
        if enableBootLogs then safeLog("WARN", "Failed to load sample: yah") end
    end

    winLevelSample = vmupro.sound.sample.new("sounds/win_level")
    if winLevelSample then
        vmupro.sound.sample.setVolume(winLevelSample, 0.7, 0.7)
        if enableBootLogs then safeLog("INFO", "Loaded sample: win_level") end
    else
        if enableBootLogs then safeLog("WARN", "Failed to load sample: win_level") end
    end

    argDeathSample = vmupro.sound.sample.new("sounds/arg_death1")
    if argDeathSample then
        vmupro.sound.sample.setVolume(argDeathSample, 0.7, 0.7)
        if enableBootLogs then safeLog("INFO", "Loaded sample: arg_death1") end
    else
        if enableBootLogs then safeLog("WARN", "Failed to load sample: arg_death1") end
    end

    audioInitialized = true
end

local function stopGameplaySamples()
    if gruntSample then vmupro.sound.sample.stop(gruntSample) end
    if swordHitSample then vmupro.sound.sample.stop(swordHitSample) end
    if swordMissSample then vmupro.sound.sample.stop(swordMissSample) end
    if yahSample then vmupro.sound.sample.stop(yahSample) end
    if winLevelSample then vmupro.sound.sample.stop(winLevelSample) end
    if argDeathSample then vmupro.sound.sample.stop(argDeathSample) end
end

local function loadTitleMusic()
    if titleSample and titleOverlaySample then return end
    if not audioSystemActive then
        vmupro.audio.startListenMode()
        audioSystemActive = true
    end
    vmupro.audio.setGlobalVolume(10)

    if not titleOverlaySample then
        titleOverlaySample = vmupro.sound.sample.new("sounds/inner_sanctum_44k1_adpcm_stereo")
    end
    if not titleSample then
        titleSample = vmupro.sound.sample.new("sounds/Intro_45sec")
    end

    if enableBootLogs and vmupro.system and vmupro.system.log then
        if titleOverlaySample then
            vmupro.system.log(vmupro.system.LOG_INFO, "AUDIO", "Title voice sample loaded")
        else
            vmupro.system.log(vmupro.system.LOG_ERROR, "AUDIO", "Title voice sample load failed")
        end
        if titleSample then
            vmupro.system.log(vmupro.system.LOG_INFO, "AUDIO", "Title music sample loaded")
        else
            vmupro.system.log(vmupro.system.LOG_ERROR, "AUDIO", "Title music sample load failed")
        end
    end

    if titleOverlaySample then
        vmupro.sound.sample.setVolume(titleOverlaySample, TITLE_VOICE_VOLUME, TITLE_VOICE_VOLUME)
    end
    if titleSample then
        vmupro.sound.sample.setVolume(titleSample, TITLE_MUSIC_VOLUME, TITLE_MUSIC_VOLUME)
    end
end

local function isSamplePlayingSafe(sample, context)
    if not sample then return false end
    local ok, playing = pcall(vmupro.sound.sample.isPlaying, sample)
    if not ok then
        if enableBootLogs and vmupro.system and vmupro.system.log then
            vmupro.system.log(vmupro.system.LOG_WARN, "AUDIO", tostring(context) .. " isPlaying check failed: " .. tostring(playing))
        end
        return false
    end
    return playing == true
end

local function playTitleVoice()
    if not titleOverlaySample then return false end
    vmupro.sound.sample.setVolume(titleOverlaySample, TITLE_VOICE_VOLUME, TITLE_VOICE_VOLUME)
    local ok, err = pcall(vmupro.sound.sample.play, titleOverlaySample, TITLE_VOICE_REPEAT_COUNT)
    if enableBootLogs and vmupro.system and vmupro.system.log then
        if ok then
            vmupro.system.log(vmupro.system.LOG_INFO, "AUDIO", "Title voice play")
        else
            vmupro.system.log(vmupro.system.LOG_ERROR, "AUDIO", "Title voice play failed: " .. tostring(err))
        end
    end
    if ok then titleVoiceStarted = true end
    return ok
end

local function playTitleMusic(reason)
    if not titleSample then return false end
    vmupro.sound.sample.setVolume(titleSample, TITLE_MUSIC_VOLUME, TITLE_MUSIC_VOLUME)
    local ok, err = pcall(vmupro.sound.sample.play, titleSample, TITLE_MUSIC_REPEAT_COUNT)
    if enableBootLogs and vmupro.system and vmupro.system.log then
        if ok then
            vmupro.system.log(vmupro.system.LOG_INFO, "AUDIO", "Title music play loops=" .. tostring(TITLE_MUSIC_REPEAT_COUNT) .. " reason=" .. tostring(reason))
        else
            vmupro.system.log(vmupro.system.LOG_ERROR, "AUDIO", "Title music play failed reason=" .. tostring(reason) .. " err=" .. tostring(err))
        end
    end
    if ok then
        titleMusicStarted = true
        titleMusicStartUs = (vmupro.system and vmupro.system.getTimeUs and vmupro.system.getTimeUs()) or 0
    end
    return ok
end

local function stopTitleMusic()
    if titleSample then
        vmupro.sound.sample.stop(titleSample)
        vmupro.sound.sample.free(titleSample)
        titleSample = nil
    end
    if titleOverlaySample then
        vmupro.sound.sample.stop(titleOverlaySample)
        vmupro.sound.sample.free(titleOverlaySample)
        titleOverlaySample = nil
    end
    titleMusicState = "stopped"
    titleMusicTimer = 0
    titleMusicStartUs = 0
    titleVoiceStarted = false
    titleMusicStarted = false
    if audioSystemActive and not audioInitialized then
        vmupro.audio.exitListenMode()
        audioSystemActive = false
    end
end

local function startTitleMusic()
    if not soundEnabled then return end
    loadTitleMusic()
    titleMusicTimer = 0
    titleMusicStartUs = 0
    titleVoiceStarted = false
    titleMusicStarted = false

    if playTitleVoice() then
        titleMusicState = "voice_playing"
        return
    end

    if playTitleMusic("voice_missing_or_failed") then
        titleMusicState = "music_playing"
    else
        titleMusicState = "stopped"
    end
end

local function updateTitleMusic()
    if not soundEnabled then
        if titleMusicState ~= "stopped" then
            stopTitleMusic()
        end
        return
    end
    if gameState ~= STATE_TITLE then
        if titleMusicState ~= "stopped" then
            stopTitleMusic()
        end
        return
    end

    if titleMusicState == "stopped" then
        startTitleMusic()
        return
    end

    if titleMusicState == "voice_playing" then
        if not isSamplePlayingSafe(titleOverlaySample, "Title voice") then
            if playTitleMusic("voice_finished") then
                titleMusicState = "music_playing"
            else
                titleMusicState = "stopped"
            end
        end
        return
    end

    if titleMusicState == "music_playing" then
        titleMusicTimer = titleMusicTimer + 1
        if titleMusicStarted and not isSamplePlayingSafe(titleSample, "Title music") then
            playTitleMusic("music_stopped_early")
        end
        return
    end

    titleMusicState = "stopped"
end

local function enterTitle()
    showMenu = false
    gameState = STATE_TITLE
    titleSelection = 1
    titleInOptions = false
    titleNeedsRedraw = true
    unloadLevelAudio()
    unloadLevelSprites()
    unloadLevelData()
    unloadWallTextures()
    loadMenuSprites()
    collectgarbage()
    startTitleMusic()
end

local function initializeLevelState(levelId)
    loadLevel(levelId)
    playerHealth = MAX_HEALTH
    soldiersKilled = 0
    isAttacking = 0
    isBlocking = false
    blockAnim = 0
    showMenu = false
    bloodEffects = {}
    levelBannerTimer = levelBannerMax
end

local function startLevel(levelId)
    loadingLog("LOAD startLevel begin " .. tostring(levelId))
    -- Ensure we free previous level assets to avoid sprite slot exhaustion
    unloadLevelData()
    unloadLevelSprites()
    unloadWallTextures()
    collectgarbage()
    stopTitleMusic()
    unloadMenuSprites()
    loadingLog("LOAD after unloadMenuSprites")
    loadLevelSprites(levelId)
    loadingLog("LOAD after loadLevelSprites")
    loadLevelAudio()
    loadingLog("LOAD after loadLevelAudio")
    initializeLevelState(levelId)
    loadingLog("LOAD after initializeLevelState")
    gameState = STATE_PLAYING
    loadingLog("LOAD startLevel done")
end

local function restartLevel()
    startLevel(currentLevel)
end

local function beginLoadLevel(levelId)
    pendingLevelStart = nil
    loadingTimer = 0
    loadingLogCount = 0
    loadingLog("LOAD beginLoadLevel (loading disabled) " .. tostring(levelId))
    wallQuadLogCount = 0
    wallQuadLog("WQ beginLoadLevel (loading disabled) " .. tostring(levelId))
    startLevel(levelId)
end

-- Check if a position is walkable (no wall)
local function isWalkable(x, y)
    local r = (PLAYER_RADIUS or 0.25) * 0.85
    local x1, x2 = x - r, x + r
    local y1, y2 = y - r, y + r
    local mx1, mx2 = math.floor(x1), math.floor(x2)
    local my1, my2 = math.floor(y1), math.floor(y2)
    if mx1 < 0 or mx2 >= 16 or my1 < 0 or my2 >= 16 then return false end
    return map[my1 + 1][mx1 + 1] == 0
        and map[my1 + 1][mx2 + 1] == 0
        and map[my2 + 1][mx1 + 1] == 0
        and map[my2 + 1][mx2 + 1] == 0
end


-- Safe atan2 implementation
local function safeAtan2(y, x)
    if x == 0 then
        if y > 0 then return 1.5708
        elseif y < 0 then return -1.5708
        else return 0 end
    end
    local angle = math.atan(y / x)
    if x < 0 then angle = angle + 3.14159 end
    return angle
end

-- Soldier AI: patrol, chase, and attack
local function updateSoldiers()
    if DEBUG_DISABLE_ENEMIES then
        return
    end
    if not sprites or #sprites == 0 then
        return
    end
    for i = 1, #sprites do
        local s = sprites[i]
        if s and s.t == 5 and s.speed then  -- Warriors with movement data
            -- Skip dead soldiers
            if s.alive == false then
                goto continue
            end

            -- Initialize state if not set
            if not s.state then
                s.state = "patrol"
                s.patrolDir = 1
                s.patrolAxis = (i % 2 == 0) and "x" or "y"
                s.startX = s.x
                s.startY = s.y
                s.attackCooldown = 0
            end

            -- Calculate distance to player (cheap cull first)
            local dx = px - s.x
            local dy = py - s.y
            local distSq = dx * dx + dy * dy
            if distSq > SOLDIER_ACTIVE_DIST_SQ and (simTickCount % 8) ~= 0 then
                goto continue
            end
            local distToPlayer = math.sqrt(distSq)
            if distToPlayer < 0.001 then
                distToPlayer = 0.001
            end

            if DEBUG_DISABLE_ENEMY_AGGRO then
                distToPlayer = 999  -- Force patrol state
                s.attackCooldown = 0
                -- Face the player for consistent side-view testing
                local angleToPlayer = safeAtan2(dy, dx)
                s.dir = math.floor(angleToPlayer * 64 / 6.28318) % 64
            end

            if DEBUG_WALK_IN_PLACE then
                s.state = "patrol"
                if s.patrolAxis == "x" then
                    s.dir = (s.patrolDir > 0) and 0 or 32
                else
                    s.dir = (s.patrolDir > 0) and 16 or 48
                end
                s.anim = ((s.anim or 0) + 1) % 20
                goto continue
            end

            -- Decrease attack cooldown
            if s.attackCooldown > 0 then
                s.attackCooldown = s.attackCooldown - 1
            end

            -- State machine
            if distToPlayer < ATTACK_RANGE then
                -- Close enough to attack
                s.state = "attack"

                -- Face the player
                local angleToPlayer = safeAtan2(dy, dx)
                s.dir = math.floor(angleToPlayer * 64 / 6.28318) % 64

                -- Attack if cooldown is ready
                if s.attackCooldown <= 0 then
                    s.attackCooldown = ATTACK_COOLDOWN
                    s.attackAnim = 7
                    s.attackFrame = 1
                    s.attackStartTick = simTickCount
                    s.attackDidHit = false

                    -- Soldier attack sound
                    if yahSample and soundEnabled then
                        vmupro.sound.sample.stop(yahSample)
                        vmupro.sound.sample.play(yahSample)
                        if enableBootLogs then safeLog("INFO", "Play sample: yah") end
                    end


                end

            elseif distToPlayer < DETECTION_RANGE then
                -- Player detected - chase!
                if s.state ~= "chase" and not s.aggroed then
                    s.aggroed = true
                    if gruntSample and soundEnabled then
                        vmupro.sound.sample.stop(gruntSample)
                        vmupro.sound.sample.play(gruntSample)
                        if enableBootLogs then safeLog("INFO", "Play sample: grunt") end
                    end
                end
                s.state = "chase"

                -- Move towards player (sprint!)
                local moveSpeed = s.speed * CHASE_SPEED_MULT * SOLDIER_SPEED_SCALE
                local moveX = (dx / distToPlayer) * moveSpeed
                local moveY = (dy / distToPlayer) * moveSpeed
                local newX = s.x + moveX
                local newY = s.y + moveY

                if isWalkable(newX, newY) then
                    s.x = newX
                    s.y = newY

                    -- Update facing direction towards player
                    local angleToPlayer = safeAtan2(dy, dx)
                    s.dir = math.floor(angleToPlayer * 64 / 6.28318) % 64

                    -- Update animation frame
                    s.anim = ((s.anim or 0) + 1) % 20
                end

            else
                -- Patrol mode
                s.state = "patrol"

                local moveAmount = s.speed * s.patrolDir * SOLDIER_SPEED_SCALE
                local newX, newY = s.x, s.y

                if s.patrolAxis == "x" then
                    newX = s.x + moveAmount
                    s.dir = (s.patrolDir > 0) and 0 or 32
                else
                    newY = s.y + moveAmount
                    s.dir = (s.patrolDir > 0) and 16 or 48
                end

                local patrolDist = 3
                local distFromStart
                if s.patrolAxis == "x" then
                    distFromStart = newX - s.startX
                else
                    distFromStart = newY - s.startY
                end

                if math.abs(distFromStart) > patrolDist or not isWalkable(newX, newY) then
                    s.patrolDir = -s.patrolDir
                else
                    if not DEBUG_WALK_IN_PLACE then
                        s.x = newX
                        s.y = newY
                    end
                    s.anim = ((s.anim or 0) + 1) % 20
                end
            end

            if s.attackAnim and s.attackAnim > 0 then
                s.attackAnim = s.attackAnim - 1
                if s.attackAnim == 3 then
                    s.attackFrame = 2
                    if not s.attackDidHit and distToPlayer <= ATTACK_RANGE then
                        local damage = DAMAGE_PER_HIT
                        local primeBlock = false
                        if isBlocking and blockAnim > 0 then
                            -- Prime block: raised at/after enemy attack start and before hit connect.
                            if blockStartFrame
                                and blockStartFrame >= (s.attackStartTick or -1000)
                                and blockStartFrame <= simTickCount then
                                primeBlock = true
                                damage = 0
                            else
                                damage = math.floor(DAMAGE_PER_HIT * 0.5 + 0.5)
                            end
                        end
                        if damage > 0 then
                            playerHealth = playerHealth - damage
                            if playerHealth <= 0 then
                                playerHealth = 0
                                gameState = STATE_GAME_OVER
                                gameOverSelection = 1
                            end
                        end
                        if isBlocking and blockAnim > 0 then
                            local pct = primeBlock and 1.0 or 0.5
                            lastBlockEvent = {
                                amount = DAMAGE_PER_HIT - damage,
                                pct = pct,
                                prime = primeBlock,
                                frame = frameCount
                            }
                        end
                        s.attackDidHit = true
                    end
                elseif s.attackAnim <= 0 then
                    s.attackAnim = 0
                end
            end
            ::continue::
        end
    end
end

local function updateDeathAnimations()
    if not sprites or #sprites == 0 then return end
    for i = 1, #sprites do
        local s = sprites[i]
        if s and s.t == 5 and s.dying then
            if #warriorDeath == 0 then
                s.dying = false
                s.dead = true
            else
                s.deathTick = (s.deathTick or 0) + 1
                if s.deathTick % 2 == 0 then
                    s.deathFrame = (s.deathFrame or 1) + 1
                    if s.deathFrame > #warriorDeath then
                        s.dying = false
                        s.dead = true
                    end
                end
            end
        end
    end
end

-- Create blood burst effect at world position
local function createBloodEffect(worldX, worldY)
    local effect = {
        x = worldX,
        y = worldY,
        particles = {},
        life = 30  -- frames
    }
    -- Create 12 blood particles radiating outward
    for i = 1, 12 do
        local angle = (i / 12) * 6.28318
        local speed = 0.05 + (frameCount % 10) * 0.005
        table.insert(effect.particles, {
            dx = math.cos(angle) * speed,
            dy = math.sin(angle) * speed,
            ox = 0, oy = 0  -- offset from center
        })
    end
    table.insert(bloodEffects, effect)
end

-- Update blood effects
local function updateBloodEffects()
    local i = 1
    while i <= #bloodEffects do
        local e = bloodEffects[i]
        e.life = e.life - 1
        -- Move particles outward
        for _, p in ipairs(e.particles) do
            p.ox = p.ox + p.dx
            p.oy = p.oy + p.dy
        end
        if e.life <= 0 then
            -- PERFORMANCE: swap-and-pop for O(1) removal instead of O(n)
            local lastIdx = #bloodEffects
            bloodEffects[i] = bloodEffects[lastIdx]
            bloodEffects[lastIdx] = nil
            -- Don't increment i since we swapped in a new element to check
        else
            i = i + 1
        end
    end
end

-- Kill a soldier and create death effects
local function killSoldier(soldier)
    soldier.alive = false
    soldier.hp = 0
    soldier.dying = true
    soldier.dead = false
    soldier.deathFrame = 1
    soldier.deathTick = 0
    soldiersKilled = soldiersKilled + 1

    -- Create blood effect
    createBloodEffect(soldier.x, soldier.y)

    -- Play death sounds
    if soundEnabled then
        if argDeathSample then
            vmupro.sound.sample.stop(argDeathSample)
            vmupro.sound.sample.play(argDeathSample)
            if enableBootLogs then safeLog("INFO", "Play sample: arg_death1") end
        end
    end

    -- Check win condition
    if soldiersKilled >= totalSoldiers then
        gameState = STATE_WIN
        winSelection = 1
        winCooldown = 30  -- Half second delay before accepting input
        winBannerTimer = winBannerMax
        if soundEnabled and winLevelSample then
            vmupro.sound.sample.stop(winLevelSample)
            vmupro.sound.sample.play(winLevelSample)
            if enableBootLogs then safeLog("INFO", "Play sample: win_level") end
        end
    end
end

-- Check for health vial pickups
local function checkHealthPickups()
    if DEBUG_DISABLE_PROPS then
        return
    end
    local pickupRange = 0.8  -- Distance to pick up vial
    local pickupRangeSq = pickupRange * pickupRange
    if not sprites or #sprites == 0 then return end
    for i = 1, #sprites do
        local s = sprites[i]
        if s and s.t == 7 and not s.collected then
            local dx = s.x - px
            local dy = s.y - py
            local distSq = dx * dx + dy * dy
            if distSq < pickupRangeSq then
                -- Collect the vial
                s.collected = true
                playerHealth = MAX_HEALTH
            end
        end
    end
end

local drawUiText
local drawUiPanel

-- Draw win screen
local function drawWinScreen()
    -- Darken background (larger)
    drawUiPanel(20, 40, 220, 200, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)

    -- Title
    drawUiPanel(30, 55, 210, 90, COLOR_GREEN, COLOR_WHITE)
    setFontCached(vmupro.text.FONT_SMALL)
    drawUiText("VICTORY!", 76, 63, COLOR_WHITE, COLOR_GREEN)

    -- Subtitle
    drawUiText("The King is safe!", 56, 100, COLOR_WHITE, COLOR_DARK_GRAY)
    drawUiText("You cleared the level!", 44, 122, COLOR_WHITE, COLOR_DARK_GRAY)

    if winBannerTimer > 0 then
        local pulse = (frameCount % 20) < 10
        local bannerColor = pulse and COLOR_MAROON or COLOR_DARK_MAROON
        drawUiPanel(35, 130, 205, 154, bannerColor, COLOR_WHITE)
        setFontCached(vmupro.text.FONT_SMALL)
        drawUiText("LEVEL COMPLETE", 46, 136, COLOR_WHITE, bannerColor)
    end

    -- Menu option
    local y = 160
    local bgColor = COLOR_DARK_GRAY
    local textColor = COLOR_GRAY
    if winSelection == 1 then
        drawUiPanel(40, y, 200, y + 20, COLOR_MAROON, COLOR_WHITE)
        bgColor = COLOR_MAROON
        textColor = COLOR_WHITE
    end
    local winText = "MAIN MENU"
    if currentLevel < MAX_LEVEL then
        winText = "NEXT LEVEL"
    end
    setFontCached(vmupro.text.FONT_SMALL)
    drawUiText(winText, 74, y + 2, textColor, bgColor)
end

-- Draw health UI (potion with red liquid)
local function drawHealthUI()
    -- Position in lower right corner
    local potionX = 175
    local potionY = 175

    -- Draw red "liquid" behind the potion
    -- The liquid level drains from top to bottom based on health
    local healthPercent = playerHealth / MAX_HEALTH

    -- Liquid area sized to fit inside the vial's transparent area
    -- Potion content is roughly 36x44 pixels, vial interior is smaller
    local liquidRadius = 11  -- Smaller radius to fit inside vial
    local liquidCenterX = potionX + 29  -- Center of vial horizontally
    local liquidCenterY = potionY + 32  -- Center of vial body

    -- Calculate liquid top based on health (drains completely from top to bottom)
    -- At 100%: liquidTop = centerY - radius (full circle)
    -- At 0%: liquidTop = centerY + radius (empty, nothing drawn)
    local liquidBottom = liquidCenterY + liquidRadius
    local fullHeight = 2 * liquidRadius
    local liquidTop = liquidBottom - math.floor(fullHeight * healthPercent)

    -- Draw red liquid as horizontal lines to simulate filled circle
    for y = liquidTop, liquidBottom do
        local dy = y - liquidCenterY
        local halfWidth = math.sqrt(math.max(0, liquidRadius * liquidRadius - dy * dy))
        if halfWidth > 0 then
            local x1 = math.floor(liquidCenterX - halfWidth)
            local x2 = math.floor(liquidCenterX + halfWidth)
            vmupro.graphics.drawLine(x1, y, x2, y, COLOR_RED)
        end
    end

    -- Draw the potion sprite on top
    if potionSprite then
        vmupro.sprite.draw(potionSprite, potionX, potionY, vmupro.sprite.kImageUnflipped)
    end

    -- Draw health percentage text (if enabled)
    if showHealthPercent then
        setFontCached(vmupro.text.FONT_SMALL)
        local healthText = tostring(math.floor(playerHealth)) .. "%"
        drawUiText(healthText, potionX + 18, potionY + 50, COLOR_WHITE, COLOR_BLACK)
    end
end

local function drawEnemiesRemainingUI()
    local remaining = (totalSoldiers or 0) - (soldiersKilled or 0)
    if remaining < 0 then remaining = 0 end
    setFontCached(vmupro.text.FONT_SMALL)
    drawUiText("ENEMIES LEFT: " .. tostring(remaining), 104, 228, COLOR_WHITE, COLOR_BLACK)
end

local drawRectOutline

drawUiText = function(text, x, y, textColor, bgColor)
    local fg = textColor or COLOR_WHITE
    local bg = bgColor
    -- Keep solid text backgrounds, but avoid pure black boxes around menu text.
    if bg == nil or bg == COLOR_BLACK then
        bg = UI_TEXT_SOLID_BG or COLOR_DARK_GRAY
    end
    vmupro.graphics.drawText(text, x, y, fg, bg)
end

local MENU_TEXT_DRAW_IMPL = nil
local MENU_TEXT_MODE_LABEL = "unset"
local MENU_TEXT_MODE_LOGGED = false

local function drawMenuText(text, x, y, textColor)
    local fg = textColor or COLOR_WHITE

    if not MENU_TEXT_DRAW_IMPL then
        local g = vmupro.graphics

        local function setMode(label, impl)
            MENU_TEXT_MODE_LABEL = label
            MENU_TEXT_DRAW_IMPL = impl
            if enableBootLogs and not MENU_TEXT_MODE_LOGGED then
                MENU_TEXT_MODE_LOGGED = true
                safeLog("INFO", "Menu text draw mode: " .. label)
            end
        end

        -- Newer firmware may support transparent text background via nil bg.
        do
            local ok = pcall(g.drawText, text, x, y, fg, nil)
            if ok then
                setMode("bg_nil_transparent", function(t, px, py, c)
                    g.drawText(t, px, py, c, nil)
                end)
            end
        end

        -- Some builds may expose transparent constants.
        if not MENU_TEXT_DRAW_IMPL then
            local candidates = {
                {"TRANSPARENT", g.TRANSPARENT},
                {"CLEAR", g.CLEAR},
                {"BG_TRANSPARENT", g.BG_TRANSPARENT},
                {"COLOR_TRANSPARENT", g.COLOR_TRANSPARENT},
                {"ALPHA_TRANSPARENT", g.ALPHA_TRANSPARENT},
            }
            for _, entry in ipairs(candidates) do
                local label = entry[1]
                local value = entry[2]
                if type(value) == "number" then
                    local ok = pcall(g.drawText, text, x, y, fg, value)
                    if ok then
                        setMode("bg_" .. label, function(t, px, py, c)
                            g.drawText(t, px, py, c, value)
                        end)
                        break
                    end
                end
            end
        end

        -- Legacy compatibility: if 4-arg isn't supported, keep app alive with explicit bg.
        if not MENU_TEXT_DRAW_IMPL then
            local ok = pcall(g.drawText, text, x, y, fg)
            if ok then
                setMode("arg4_transparent", function(t, px, py, c)
                    g.drawText(t, px, py, c)
                end)
            end
        end

        if not MENU_TEXT_DRAW_IMPL then
            setMode("bg_black_fallback", function(t, px, py, c)
                g.drawText(t, px, py, c, COLOR_BLACK)
            end)
        end
    end

    MENU_TEXT_DRAW_IMPL(text, x, y, fg)
end

drawUiPanel = function(x1, y1, x2, y2, fillColor, borderColor)
    -- Keep menu overlays lightweight: outline only, no stipple fill.
    drawRectOutline(x1, y1, x2, y2, borderColor or COLOR_GRAY)
end

local function drawPerfMonitorOverlay()
    if not DEBUG_PERF_MONITOR then return end
    local frameMs = (PERF_MONITOR_EMA_FRAME_US or 0) / 1000.0
    local rayMs = (PERF_MONITOR_EMA_RAYCAST_US or 0) / 1000.0
    local wallMs = (PERF_MONITOR_EMA_WALL_US or 0) / 1000.0
    local fogMs = (PERF_MONITOR_EMA_FOG_US or 0) / 1000.0
    local inputMs = (PERF_MONITOR_EMA_INPUT_US or 0) / 1000.0
    local audioMs = (PERF_MONITOR_EMA_AUDIO_US or 0) / 1000.0
    local simMs = (PERF_MONITOR_EMA_SIM_US or 0) / 1000.0
    local logicMs = (PERF_MONITOR_EMA_LOGIC_US or 0) / 1000.0
    local renderMs = (PERF_MONITOR_EMA_RENDER_US or 0) / 1000.0
    local presentMs = (PERF_MONITOR_EMA_PRESENT_US or 0) / 1000.0
    local sleepMs = (PERF_MONITOR_EMA_SLEEP_US or 0) / 1000.0
    local raysLabel = tostring(PERF_MONITOR_LAST_BASE_RAY_LABEL or "-")
    local effLabel = tostring(PERF_MONITOR_LAST_EFFECTIVE_RAY_LABEL or "-")
    local modeLabel = tostring(PERF_MONITOR_LAST_RAYCAST_MODE or "FLOAT")
    local dbLabel = getDoubleBufferStatusLabel()
    local deltaUsageKB = (DOUBLE_BUFFER_DELTA_USAGE_BYTES or 0) / 1024.0
    local deltaLargestKB = (DOUBLE_BUFFER_DELTA_LARGEST_BYTES or 0) / 1024.0
    local moveBlocked = PERF_MONITOR_MOVE_BLOCKED or 0
    local wallRecoveries = PERF_MONITOR_WALL_RECOVERIES or 0
    local rayStartSolid = PERF_MONITOR_RAY_START_SOLID or 0
    local wallFmt = getWall1VariantConfig()
    local wallFmtLabel = tostring((wallFmt and wallFmt.label) or "?")
    local wallKeyLabel = getWallKeyModeLabel()
    local wallProjLabel = getWallProjectionModeLabel()
    local baseX = 6
    -- Leave extra vertical room because some firmware builds render this font taller than 8px.
    -- This avoids line-on-line overlap regardless of FONT_TINY fallback behavior.
    local baseY = 104
    local rowStep = 16
    drawUiPanel(2, 100, 238, 236, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
    setFontCached(vmupro.text.FONT_TINY_6x8)
    drawUiText(string.format("PF F%.2f R%.2f W%.2f G%.2f", frameMs, rayMs, wallMs, fogMs), baseX, baseY + (rowStep * 0), COLOR_WHITE, COLOR_DARK_GRAY)
    drawUiText(string.format("PF C%d T%d FB%d FG%d", PERF_MONITOR_WALL_COLS_TOTAL or 0, PERF_MONITOR_WALL_COLS_TEXTURED or 0, PERF_MONITOR_WALL_COLS_FALLBACK or 0, PERF_MONITOR_FOG_COLS or 0), baseX, baseY + (rowStep * 1), COLOR_WHITE, COLOR_DARK_GRAY)
    drawUiText("PF " .. raysLabel .. "->" .. effLabel .. " " .. modeLabel .. string.format(" B%d R%d S%d", moveBlocked, wallRecoveries, rayStartSolid), baseX, baseY + (rowStep * 2), COLOR_WHITE, COLOR_DARK_GRAY)
    drawUiText(string.format("DB %s DU%.1fK DL%.1fK", dbLabel, deltaUsageKB, deltaLargestKB), baseX, baseY + (rowStep * 3), COLOR_WHITE, COLOR_DARK_GRAY)
    drawUiText(string.format("W1=%s K=%s P=%s", wallFmtLabel, wallKeyLabel, wallProjLabel), baseX, baseY + (rowStep * 4), COLOR_WHITE, COLOR_DARK_GRAY)
    drawUiText(string.format("MP %d/%d/%d/%d/%d", PERF_MONITOR_MIP_COLS_0 or 0, PERF_MONITOR_MIP_COLS_1 or 0, PERF_MONITOR_MIP_COLS_2 or 0, PERF_MONITOR_MIP_COLS_3 or 0, PERF_MONITOR_MIP_COLS_4 or 0), baseX, baseY + (rowStep * 5), COLOR_WHITE, COLOR_DARK_GRAY)
    drawUiText(string.format("SC I%.2f A%.2f S%.2f L%.2f", inputMs, audioMs, simMs, logicMs), baseX, baseY + (rowStep * 6), COLOR_WHITE, COLOR_DARK_GRAY)
    drawUiText(string.format("SC R%.2f P%.2f Z%.2f", renderMs, presentMs, sleepMs), baseX, baseY + (rowStep * 7), COLOR_WHITE, COLOR_DARK_GRAY)
end

local function buildDebugMenuItems()
    local pageName = getDebugPageName(titleDebugPage)
    local pageText = "PAGE: " .. pageName

    if titleDebugPage == DEBUG_PAGE_VIDEO then
        local texturesText = "TEXTURES: " .. (DEBUG_DISABLE_WALL_TEXTURE and "OFF" or "ON")
        local roofText = "ROOF TEX: " .. (DEBUG_DISABLE_ROOF_TEXTURE and "OFF" or "ON")
        local mipmapText = "MIPMAP: " .. (WALL_MIPMAP_ENABLED and "ON" or "OFF")
        local mipLodText = "MIP LOD: " .. (MIP_LOD_ENABLED and "ON" or "OFF")
        local rayPreset = "?"
        if RAY_PRESETS and #RAY_PRESETS > 0 then
            local baseIdx = clampInt(RAY_PRESET_INDEX or 1, 1, #RAY_PRESETS)
            rayPreset = (RAY_PRESETS[baseIdx] and RAY_PRESETS[baseIdx].label) or "?"
        end
        local raysText = "RAYS: " .. rayPreset
        local drawDistText = "DRAW DIST: " .. tostring(EXP_TEX_MAX_DIST or "?")
        local farTexOffText
        if (FAR_TEX_OFF_DIST or 999) >= 900 then
            farTexOffText = "FAR TEX OFF: OFF"
        else
            farTexOffText = "FAR TEX OFF: " .. tostring(FAR_TEX_OFF_DIST or "?")
        end
        local mip1DistText = "MIP1 DIST: " .. tostring(WALL_MIPMAP_DIST1 or "?")
        local mip2DistText = "MIP2 DIST: " .. tostring(WALL_MIPMAP_DIST2 or "?")
        local mip3DistText = "MIP3 DIST: " .. tostring(WALL_MIPMAP_DIST3 or "?")
        local mip4DistText = "MIP4 DIST: " .. tostring(WALL_MIPMAP_DIST4 or "?")
        local fogStartText = "FOG START: " .. tostring(FOG_START or "?")
        local fogEndText = "FOG FULL: " .. tostring(FOG_END or "?")
        local fogCutText = "FOG CUT L: " .. tostring(FOG_TEX_CUTOFF or "?")
        local fogColorLabel = (FOG_COLOR_LABELS and FOG_COLOR_LABELS[FOG_COLOR_INDEX or 1]) or tostring(FOG_COLOR_INDEX or 1)
        local fogColorText = "FOG COLOR: " .. tostring(fogColorLabel)
        local fogDitherText = "FOG DTHR: " .. tostring(FOG_DITHER_SIZE or 3)
        local resLabel = (LOW_RES_MODE == "fast") and "FAST" or "QUALITY"
        local resText = "WALL RES: " .. resLabel
        local fpsText = "FPS OVL: " .. (showFpsOverlay and "ON" or "OFF")
        local minimapText = "MINIMAP: " .. (SHOW_MINIMAP and "ON" or "OFF")
        local wallFmt = getWall1VariantConfig()
        local wallFmtText = "WALL1 FMT: " .. tostring(wallFmt.label or "?")
        local wallKeyText = "WALL KEY: " .. getWallKeyModeLabel()
        local wallProjText = "WALL PROJ: " .. getWallProjectionModeLabel()
        return {
            pageText,
            texturesText, roofText, mipmapText, mipLodText, raysText, drawDistText, farTexOffText,
            mip1DistText, mip2DistText, mip3DistText, mip4DistText,
            fogStartText, fogEndText, fogCutText, fogColorText, fogDitherText,
            resText, fpsText, minimapText, wallFmtText, wallKeyText, wallProjText,
            "BACK"
        }
    end

    if titleDebugPage == DEBUG_PAGE_PERF then
        local presetLabel = "CUSTOM"
        if PERF_QUALITY_INDEX and PERF_QUALITY_INDEX > 0 and PERF_QUALITY_PRESETS[PERF_QUALITY_INDEX] then
            presetLabel = PERF_QUALITY_PRESETS[PERF_QUALITY_INDEX]
        end
        local rayLabel = "?"
        if RAY_PRESETS and #RAY_PRESETS > 0 then
            local idx = clampInt(RAY_PRESET_INDEX or 1, 1, #RAY_PRESETS)
            rayLabel = (RAY_PRESETS[idx] and RAY_PRESETS[idx].label) or tostring(idx)
        end
        local presetText = "P/Q PRESET: " .. presetLabel
        local wallResText = "WALL RES: " .. ((LOW_RES_MODE == "fast") and "FAST" or "QUALITY")
        local raysText = "RAYS: " .. rayLabel
        local drawDistText = "DRAW DIST: " .. tostring(EXP_TEX_MAX_DIST or "?")
        local farTexText = ((FAR_TEX_OFF_DIST or 999) >= 900) and "FAR TEX OFF: OFF" or ("FAR TEX OFF: " .. tostring(FAR_TEX_OFF_DIST or "?"))
        local mipmapText = "MIPMAP: " .. (WALL_MIPMAP_ENABLED and "ON" or "OFF")
        local mipLodText = "MIP LOD: " .. (MIP_LOD_ENABLED and "ON" or "OFF")
        local fogStartText = "FOG START: " .. tostring(FOG_START or "?")
        local fogEndText = "FOG FULL: " .. tostring(FOG_END or "?")
        local fogDitherText = "FOG DTHR: " .. tostring(FOG_DITHER_SIZE or 3)
        local fpsTargetText = "FPS TARGET: " .. string.upper(FPS_TARGET_MODE)
        local perfMonText = "PERF MON: " .. (DEBUG_PERF_MONITOR and "ON" or "OFF")
        local dBufText = "DBUF: " .. getDoubleBufferStatusLabel()
        return {
            pageText,
            presetText, wallResText, raysText, drawDistText, farTexText,
            mipmapText, mipLodText, fogStartText, fogEndText, fogDitherText,
            fpsTargetText, perfMonText, dBufText,
            "BACK"
        }
    end

    local logsText = "LOGS: " .. (enableBootLogs and "ON" or "OFF")
    local enemiesText = "ENEMIES: " .. (DEBUG_DISABLE_ENEMIES and "OFF" or "ON")
    local propsText = "PROPS: " .. (DEBUG_DISABLE_PROPS and "OFF" or "ON")
    local blockDbgText = "BLOCK DBG: " .. (DEBUG_SHOW_BLOCK and "ON" or "OFF")
    local fpsTargetText = "FPS TARGET: " .. string.upper(FPS_TARGET_MODE)
    local audioMixText = "AUDIO MIX: " .. tostring(AUDIO_UPDATE_TARGET_HZ or 60) .. "HZ"
    local rendererText = "RENDER: EXP-H LOCK"
    local useFixed = (USE_FIXED_RAYCAST == true) and (DEBUG_FORCE_FLOAT_RAYCAST ~= true)
    local raycastText = "RAYCAST: " .. (useFixed and "FIXED" or "FLOAT")
    local perfMonText = "PERF MON: " .. (DEBUG_PERF_MONITOR and "ON" or "OFF")
    local dBufText = "DBUF: " .. getDoubleBufferStatusLabel()
    return {pageText, logsText, enemiesText, propsText, blockDbgText, fpsTargetText, audioMixText, rendererText, raycastText, perfMonText, dBufText, "BACK"}
end

-- Keep in sync with buildDebugMenuItems() to avoid per-frame table builds in input handlers.
local function getDebugMenuItemCount()
    if titleDebugPage == DEBUG_PAGE_VIDEO then
        return 24
    end
    if titleDebugPage == DEBUG_PAGE_PERF then
        return 15
    end
    return 12
end

local function stepListIndex(idx, delta, count, wrap)
    local n = count or 0
    if n <= 0 then return 1 end
    local cur = idx or 1
    local nextIdx = cur + delta
    if wrap then
        if nextIdx < 1 then nextIdx = n end
        if nextIdx > n then nextIdx = 1 end
    else
        if nextIdx < 1 then nextIdx = 1 end
        if nextIdx > n then nextIdx = n end
    end
    return nextIdx
end

local debugAdjustHoldDir = 0
local debugAdjustHoldFrames = 0
local DEBUG_ADJUST_REPEAT_FRAMES = 6

local function getDebugAdjustDelta()
    if vmupro.input.pressed(vmupro.input.LEFT) then
        debugAdjustHoldDir = -1
        debugAdjustHoldFrames = 0
        return -1
    end
    if vmupro.input.pressed(vmupro.input.RIGHT) then
        debugAdjustHoldDir = 1
        debugAdjustHoldFrames = 0
        return 1
    end

    local dir = 0
    if vmupro.input.held(vmupro.input.LEFT) then
        dir = -1
    elseif vmupro.input.held(vmupro.input.RIGHT) then
        dir = 1
    end

    if dir == 0 then
        debugAdjustHoldDir = 0
        debugAdjustHoldFrames = 0
        return 0
    end

    if debugAdjustHoldDir ~= dir then
        debugAdjustHoldDir = dir
        debugAdjustHoldFrames = 0
        return dir
    end

    debugAdjustHoldFrames = debugAdjustHoldFrames + 1
    if debugAdjustHoldFrames >= DEBUG_ADJUST_REPEAT_FRAMES then
        debugAdjustHoldFrames = 0
        return dir
    end

    return 0
end

local function stepFpsTarget(delta, wrap)
    local modes = {"uncapped", "60", "45", "30", "24"}
    local cur = 1
    for i = 1, #modes do
        if modes[i] == FPS_TARGET_MODE then
            cur = i
            break
        end
    end
    local nextIdx = stepListIndex(cur, delta, #modes, wrap)
    FPS_TARGET_MODE = modes[nextIdx]
end

local function stepAudioMixTarget(delta, wrap)
    if not AUDIO_MIX_HZ_PRESETS or #AUDIO_MIX_HZ_PRESETS == 0 then
        return
    end
    AUDIO_MIX_HZ_INDEX = stepListIndex(AUDIO_MIX_HZ_INDEX or #AUDIO_MIX_HZ_PRESETS, delta, #AUDIO_MIX_HZ_PRESETS, wrap == true)
    setAudioMixHz(AUDIO_MIX_HZ_PRESETS[AUDIO_MIX_HZ_INDEX])
end

local function stepWall1FormatVariant(delta, wrap)
    if not WALL1_FORMAT_VARIANTS or #WALL1_FORMAT_VARIANTS == 0 then
        return
    end
    WALL1_FORMAT_INDEX = stepListIndex(WALL1_FORMAT_INDEX or 1, delta, #WALL1_FORMAT_VARIANTS, wrap == true)
    if not DEBUG_DISABLE_WALL_TEXTURE then
        unloadWallTextures()
        loadWallTextures()
    end
end

local function adjustDebugMenuSelection(sel, delta, wrap)
    local step = delta or 0
    if step == 0 then return false end
    local doWrap = (wrap == true)

    if sel == 1 then
        stepDebugPage(step)
        return true
    end

    if titleDebugPage == DEBUG_PAGE_VIDEO then
        if sel >= 2 then
            markPerfQualityCustom()
        end
        if sel == 2 then
            -- TEXTURES label is inverse of DEBUG_DISABLE_WALL_TEXTURE.
            local disableTextures = (step < 0)
            if disableTextures ~= DEBUG_DISABLE_WALL_TEXTURE then
                DEBUG_DISABLE_WALL_TEXTURE = disableTextures
                if DEBUG_DISABLE_WALL_TEXTURE then
                    unloadWallTextures()
                else
                    loadWallTextures()
                end
            end
            return true
        elseif sel == 3 then
            DEBUG_DISABLE_ROOF_TEXTURE = (step < 0)
            return true
        elseif sel == 4 then
            WALL_MIPMAP_ENABLED = (step > 0)
            return true
        elseif sel == 5 then
            MIP_LOD_ENABLED = (step > 0)
            return true
        elseif sel == 6 then
            if RAY_PRESETS and #RAY_PRESETS > 0 then
                RAY_PRESET_INDEX = stepListIndex(RAY_PRESET_INDEX or 1, step, #RAY_PRESETS, doWrap)
            end
            return true
        elseif sel == 7 then
            if DRAW_DIST_PRESETS and #DRAW_DIST_PRESETS > 0 then
                DRAW_DIST_INDEX = stepListIndex(DRAW_DIST_INDEX or 1, step, #DRAW_DIST_PRESETS, doWrap)
                EXP_TEX_MAX_DIST = DRAW_DIST_PRESETS[DRAW_DIST_INDEX]
                refreshExpViewDistance()
            end
            return true
        elseif sel == 8 then
            if FAR_TEX_OFF_PRESETS and #FAR_TEX_OFF_PRESETS > 0 then
                FAR_TEX_OFF_INDEX = stepListIndex(FAR_TEX_OFF_INDEX or #FAR_TEX_OFF_PRESETS, step, #FAR_TEX_OFF_PRESETS, doWrap)
                FAR_TEX_OFF_DIST = FAR_TEX_OFF_PRESETS[FAR_TEX_OFF_INDEX]
            end
            return true
        elseif sel == 9 then
            if MIPMAP_DIST_PRESETS and #MIPMAP_DIST_PRESETS > 0 then
                normalizeMipmapRanges()
                local max1 = math.max(1, (MIPMAP2_DIST_INDEX or 2) - 1)
                MIPMAP1_DIST_INDEX = clampInt((MIPMAP1_DIST_INDEX or 1) + step, 1, max1)
                normalizeMipmapRanges()
            end
            return true
        elseif sel == 10 then
            if MIPMAP_DIST_PRESETS and #MIPMAP_DIST_PRESETS > 0 then
                normalizeMipmapRanges()
                local n = #MIPMAP_DIST_PRESETS
                local min2 = math.min(n, (MIPMAP1_DIST_INDEX or 1) + 1)
                local max2 = math.max(min2, (MIPMAP3_DIST_INDEX or n) - 1)
                MIPMAP2_DIST_INDEX = clampInt((MIPMAP2_DIST_INDEX or min2) + step, min2, max2)
                normalizeMipmapRanges()
            end
            return true
        elseif sel == 11 then
            if MIPMAP_DIST_PRESETS and #MIPMAP_DIST_PRESETS > 0 then
                normalizeMipmapRanges()
                local n = #MIPMAP_DIST_PRESETS
                local min3 = math.min(n, (MIPMAP2_DIST_INDEX or 1) + 1)
                local max3 = math.max(min3, (MIPMAP4_DIST_INDEX or n) - 1)
                MIPMAP3_DIST_INDEX = clampInt((MIPMAP3_DIST_INDEX or min3) + step, min3, max3)
                normalizeMipmapRanges()
            end
            return true
        elseif sel == 12 then
            if MIPMAP_DIST_PRESETS and #MIPMAP_DIST_PRESETS > 0 then
                normalizeMipmapRanges()
                local n = #MIPMAP_DIST_PRESETS
                local min4 = math.min(n, (MIPMAP3_DIST_INDEX or 1) + 1)
                MIPMAP4_DIST_INDEX = clampInt((MIPMAP4_DIST_INDEX or min4) + step, min4, n)
                normalizeMipmapRanges()
            end
            return true
        elseif sel == 13 then
            if FOG_START_PRESETS and #FOG_START_PRESETS > 0 then
                normalizeFogRange()
                local maxStart = math.max(1, (FOG_END_INDEX or 2) - 1)
                FOG_START_INDEX = clampInt((FOG_START_INDEX or 1) + step, 1, maxStart)
                normalizeFogRange()
            end
            return true
        elseif sel == 14 then
            if FOG_END_PRESETS and #FOG_END_PRESETS > 0 then
                normalizeFogRange()
                local n = #FOG_END_PRESETS
                local minEnd = math.min(n, (FOG_START_INDEX or 1) + 1)
                FOG_END_INDEX = clampInt((FOG_END_INDEX or minEnd) + step, minEnd, n)
                normalizeFogRange()
            end
            return true
        elseif sel == 15 then
            if FOG_CUTOFF_PRESETS and #FOG_CUTOFF_PRESETS > 0 then
                FOG_CUTOFF_INDEX = stepListIndex(FOG_CUTOFF_INDEX or 1, step, #FOG_CUTOFF_PRESETS, doWrap)
                FOG_TEX_CUTOFF = FOG_CUTOFF_PRESETS[FOG_CUTOFF_INDEX]
            end
            return true
        elseif sel == 16 then
            if FOG_COLOR_PRESETS and #FOG_COLOR_PRESETS > 0 then
                FOG_COLOR_INDEX = stepListIndex(FOG_COLOR_INDEX or 1, step, #FOG_COLOR_PRESETS, doWrap)
                FOG_COLOR = FOG_COLOR_PRESETS[FOG_COLOR_INDEX]
            end
            return true
        elseif sel == 17 then
            if FOG_DITHER_SIZE_PRESETS and #FOG_DITHER_SIZE_PRESETS > 0 then
                FOG_DITHER_SIZE_INDEX = stepListIndex(FOG_DITHER_SIZE_INDEX or 3, step, #FOG_DITHER_SIZE_PRESETS, doWrap)
                FOG_DITHER_SIZE = FOG_DITHER_SIZE_PRESETS[FOG_DITHER_SIZE_INDEX]
            end
            return true
        elseif sel == 18 then
            if step > 0 then
                LOW_RES_MODE = "quality"
            else
                LOW_RES_MODE = "fast"
            end
            return true
        elseif sel == 19 then
            showFpsOverlay = (step > 0)
            return true
        elseif sel == 20 then
            SHOW_MINIMAP = (step > 0)
            return true
        elseif sel == 21 then
            stepWall1FormatVariant(step, doWrap)
            return true
        elseif sel == 22 then
            local nextOverride = (step > 0)
            if nextOverride ~= WALL_FORCE_COLORKEY_OVERRIDE then
                WALL_FORCE_COLORKEY_OVERRIDE = nextOverride
                if not DEBUG_DISABLE_WALL_TEXTURE then
                    unloadWallTextures()
                    loadWallTextures()
                end
            end
            return true
        elseif sel == 23 then
            if step > 0 then
                WALL_PROJECTION_MODE = "adaptive"
            else
                WALL_PROJECTION_MODE = "stable"
            end
            return true
        end
        return false
    end

    if titleDebugPage == DEBUG_PAGE_PERF then
        if sel == 2 then
            local count = #PERF_QUALITY_PRESETS
            if count > 0 then
                local idx = PERF_QUALITY_INDEX
                if not idx or idx < 1 or idx > count then idx = 2 end
                idx = stepListIndex(idx, step, count, doWrap)
                applyPerfQualityPreset(idx)
            end
            return true
        elseif sel == 3 then
            markPerfQualityCustom()
            LOW_RES_MODE = (step > 0) and "quality" or "fast"
            return true
        elseif sel == 4 then
            markPerfQualityCustom()
            if RAY_PRESETS and #RAY_PRESETS > 0 then
                RAY_PRESET_INDEX = stepListIndex(RAY_PRESET_INDEX or 1, step, #RAY_PRESETS, doWrap)
            end
            return true
        elseif sel == 5 then
            markPerfQualityCustom()
            if DRAW_DIST_PRESETS and #DRAW_DIST_PRESETS > 0 then
                DRAW_DIST_INDEX = stepListIndex(DRAW_DIST_INDEX or 1, step, #DRAW_DIST_PRESETS, doWrap)
                EXP_TEX_MAX_DIST = DRAW_DIST_PRESETS[DRAW_DIST_INDEX]
                refreshExpViewDistance()
            end
            return true
        elseif sel == 6 then
            markPerfQualityCustom()
            if FAR_TEX_OFF_PRESETS and #FAR_TEX_OFF_PRESETS > 0 then
                FAR_TEX_OFF_INDEX = stepListIndex(FAR_TEX_OFF_INDEX or #FAR_TEX_OFF_PRESETS, step, #FAR_TEX_OFF_PRESETS, doWrap)
                FAR_TEX_OFF_DIST = FAR_TEX_OFF_PRESETS[FAR_TEX_OFF_INDEX]
            end
            return true
        elseif sel == 7 then
            markPerfQualityCustom()
            WALL_MIPMAP_ENABLED = (step > 0)
            return true
        elseif sel == 8 then
            markPerfQualityCustom()
            MIP_LOD_ENABLED = (step > 0)
            return true
        elseif sel == 9 then
            markPerfQualityCustom()
            if FOG_START_PRESETS and #FOG_START_PRESETS > 0 then
                normalizeFogRange()
                local maxStart = math.max(1, (FOG_END_INDEX or 2) - 1)
                FOG_START_INDEX = clampInt((FOG_START_INDEX or 1) + step, 1, maxStart)
                normalizeFogRange()
            end
            return true
        elseif sel == 10 then
            markPerfQualityCustom()
            if FOG_END_PRESETS and #FOG_END_PRESETS > 0 then
                normalizeFogRange()
                local n = #FOG_END_PRESETS
                local minEnd = math.min(n, (FOG_START_INDEX or 1) + 1)
                FOG_END_INDEX = clampInt((FOG_END_INDEX or minEnd) + step, minEnd, n)
                normalizeFogRange()
            end
            return true
        elseif sel == 11 then
            markPerfQualityCustom()
            if FOG_DITHER_SIZE_PRESETS and #FOG_DITHER_SIZE_PRESETS > 0 then
                FOG_DITHER_SIZE_INDEX = stepListIndex(FOG_DITHER_SIZE_INDEX or 3, step, #FOG_DITHER_SIZE_PRESETS, doWrap)
                FOG_DITHER_SIZE = FOG_DITHER_SIZE_PRESETS[FOG_DITHER_SIZE_INDEX]
            end
            return true
        elseif sel == 12 then
            stepFpsTarget(step, doWrap)
            return true
        elseif sel == 13 then
            DEBUG_PERF_MONITOR = (step > 0)
            return true
        elseif sel == 14 then
            DEBUG_DOUBLE_BUFFER = (step > 0)
            return true
        end
        return false
    end

    if sel == 2 then
        local enable = step > 0
        enableBootLogs = enable
        enablePerfLogs = enable
        DEBUG_WALL_QUADS_LOG = enable
        if enable then
            wallQuadLogCount = 0
        end
        applyRuntimeLogLevel()
        return true
    elseif sel == 3 then
        -- ENEMIES label is inverse of DEBUG_DISABLE_ENEMIES.
        DEBUG_DISABLE_ENEMIES = (step < 0)
        spriteOrderCache = {}
        spriteOrderCacheFrame = -999
        return true
    elseif sel == 4 then
        -- PROPS label is inverse of DEBUG_DISABLE_PROPS.
        DEBUG_DISABLE_PROPS = (step < 0)
        spriteOrderCache = {}
        spriteOrderCacheFrame = -999
        return true
    elseif sel == 5 then
        DEBUG_SHOW_BLOCK = (step > 0)
        return true
    elseif sel == 6 then
        stepFpsTarget(step, doWrap)
        return true
    elseif sel == 7 then
        stepAudioMixTarget(step, doWrap)
        return true
    elseif sel == 8 then
        -- Renderer is locked; keep lock routine for safety.
        lockRendererMode()
        return true
    elseif sel == 9 then
        USE_FIXED_RAYCAST = (step > 0)
        DEBUG_FORCE_FLOAT_RAYCAST = false
        return true
    elseif sel == 10 then
        DEBUG_PERF_MONITOR = (step > 0)
        return true
    elseif sel == 11 then
        DEBUG_DOUBLE_BUFFER = (step > 0)
        return true
    end

    return false
end

local function applyDebugMenuSelection(sel)
    return sel == getDebugMenuItemCount()
end

drawRectOutline = function(x1, y1, x2, y2, color)
    vmupro.graphics.drawLine(x1, y1, x2, y1, color)
    vmupro.graphics.drawLine(x1, y2, x2, y2, color)
    vmupro.graphics.drawLine(x1, y1, x1, y2, color)
    vmupro.graphics.drawLine(x2, y1, x2, y2, color)
end

-- Draw title screen
local function drawTitleScreenImpl()
    logBoot(vmupro.system.LOG_ERROR, "C drawTitleScreen")
    -- Draw title background image
    if titleSprite then
        vmupro.sprite.draw(titleSprite, 0, 0, vmupro.sprite.kImageUnflipped)
    else
        vmupro.graphics.clear(COLOR_BLACK)
    end

    if titleInOptions then
        -- Options submenu
        logBoot(vmupro.system.LOG_ERROR, "D title options text")
        -- Large single-column menu box (extend to bottom)
        drawUiPanel(20, 50, 220, 239, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
        drawUiPanel(30, 60, 210, 82, COLOR_MAROON, COLOR_WHITE)
        setFontCached(vmupro.text.FONT_TINY_6x8)
        drawUiText(titleInDebug and "DEBUG" or "OPTIONS", 92, 65, COLOR_WHITE, COLOR_MAROON)

        local items = {}
        if titleInDebug then
            items = buildDebugMenuItems()
        else
            local levelLabel = LEVEL_SELECT_LIST[selectedLevel] and LEVEL_SELECT_LIST[selectedLevel].label or tostring(selectedLevel)
            local levelText = "LEVEL: " .. levelLabel
            local soundText = "SOUND: " .. (soundEnabled and "ON" or "OFF")
            local healthText = "HEALTH%: " .. (showHealthPercent and "ON" or "OFF")
            local rendererText = "RENDER: EXP-H LOCK"
            items = {levelText, soundText, healthText, rendererText, "DEBUG", "BACK"}
        end
        local visibleCount = titleInDebug and 10 or #items
        if titleInDebug and visibleCount > #items then
            visibleCount = #items
        end
        local sel = titleInDebug and titleDebugSelection or titleOptionsSelection
        local startIndex = 1
        if titleInDebug and #items > visibleCount then
            local half = math.floor(visibleCount / 2)
            startIndex = sel - half
            if startIndex < 1 then startIndex = 1 end
            local maxStart = #items - visibleCount + 1
            if startIndex > maxStart then startIndex = maxStart end
        end
        local endIndex = math.min(#items, startIndex + visibleCount - 1)

        local drawRow = 0
        for i = startIndex, endIndex do
            local item = items[i]
            local x = 34
            local startY = titleInDebug and 74 or 90
            local stepY = titleInDebug and 16 or 18
            local y = startY + drawRow * stepY
            local bgColor = COLOR_DARK_GRAY
            local textColor = COLOR_GRAY
            if i == sel then
                local boxH = titleInDebug and 12 or 18
                drawUiPanel(32, y, 208, y + boxH, COLOR_MAROON, COLOR_WHITE)
                bgColor = COLOR_MAROON
                textColor = COLOR_WHITE
            end
            if titleInDebug then
                setFontCached(vmupro.text.FONT_TINY_6x8)
            else
                setFontCached(vmupro.text.FONT_TINY_6x8)
            end
            drawUiText(item, x, y + 2, textColor, bgColor)
            drawRow = drawRow + 1
        end
        if titleInDebug then
            setFontCached(vmupro.text.FONT_TINY_6x8)
            drawUiText("L/R ADJUST", 34, 226, COLOR_WHITE, COLOR_DARK_GRAY)
        end
    else
        -- Main title menu
        logBoot(vmupro.system.LOG_ERROR, "D title main text")
        -- Compact menu box for 3 items
        drawUiPanel(60, 140, 180, 230, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
        setFontCached(vmupro.text.FONT_SMALL)
        local items = {"START GAME", "OPTIONS", "EXIT"}
        for i, item in ipairs(items) do
            local y = 153 + (i - 1) * 18
            local bgColor = COLOR_DARK_GRAY
            local textColor = COLOR_GRAY
            if i == titleSelection then
                drawUiPanel(70, y, 170, y + 18, COLOR_MAROON, COLOR_WHITE)
                bgColor = COLOR_MAROON
                textColor = COLOR_WHITE
            end
            setFontCached(vmupro.text.FONT_SMALL)
            drawUiText(item, 78, y + 2, textColor, bgColor)
        end
    end
end

drawTitleScreen = drawTitleScreenImpl
logBoot(vmupro.system.LOG_ERROR, "drawTitleScreen bound to impl")

-- Draw game over screen
local function drawGameOver()
    -- Darken background
    drawUiPanel(40, 70, 200, 195, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)

    -- Title
    drawUiPanel(50, 80, 190, 102, COLOR_MAROON, COLOR_WHITE)
    setFontCached(vmupro.text.FONT_SMALL)
    drawUiText("GAME OVER", 76, 85, COLOR_WHITE, COLOR_MAROON)

    -- Menu items
    local items = {"RESTART", "MENU", "QUIT"}
    for i, item in ipairs(items) do
        local y = 110 + (i - 1) * 18
        local bgColor = COLOR_DARK_GRAY
        local textColor = COLOR_GRAY
        if i == gameOverSelection then
            drawUiPanel(50, y, 190, y + 18, COLOR_MAROON, COLOR_WHITE)
            bgColor = COLOR_MAROON
            textColor = COLOR_WHITE
        end
        setFontCached(vmupro.text.FONT_SMALL)
        drawUiText(item, 86, y + 2, textColor, bgColor)
    end
end

-- Reset game state for restart
local function resetGame()
    restartLevel()
end

-- Collision detection for sprites
function collidesWithSprite(nx, ny, playerRadius)
    if not sprites or #sprites == 0 then return false end
    local pr = playerRadius or PLAYER_COLLISION_RADIUS or 0.27
    if pr < 0.1 then pr = 0.1 end
    if DEBUG_DISABLE_ENEMIES then
        return false
    end
    for i = 1, #sprites do
        local s = sprites[i]
        if s and isEnemyType(s.t) then
            local inactiveEnemy = (s.t == 5 or s.t == 6) and (s.dying or s.dead or s.alive == false)
            if not inactiveEnemy then
                local dx, dy = nx - s.x, ny - s.y
                local sr = 0.34
                local minDist = pr + sr
                if (dx * dx + dy * dy) < (minDist * minDist) then
                    return true
                end
            end
        end
    end
    return false
end

local function getWallColor(wtype, side)
    if wtype == 1 then
        if side == 1 then return COLOR_STONE_D else return COLOR_STONE_L end
    elseif wtype == 2 then
        if side == 1 then return COLOR_BRICK_D else return COLOR_BRICK_L end
    elseif wtype == 3 then
        if side == 1 then return COLOR_MOSS_D else return COLOR_MOSS_L end
    elseif wtype == 4 then
        if side == 1 then return COLOR_METAL_D else return COLOR_METAL_L end
    elseif wtype == 5 then
        if side == 1 then return COLOR_WOOD_D else return COLOR_WOOD_L end
    elseif wtype == 6 then
        if side == 1 then return COLOR_DARK_BLUE else return COLOR_LIGHT_BLUE end
    else
        if side == 1 then return COLOR_STONE_D else return COLOR_STONE_L end
    end
end

local function getPlayerCollisionRadius()
    local r = PLAYER_COLLISION_RADIUS or 0.27
    if r < 0.1 then r = 0.1 end
    return r
end

local function isWalkableWithRadius(x, y, radius)
    local r = radius
    if not r or r <= 0 then
        r = getPlayerCollisionRadius()
    end
    if r < 0.05 then r = 0.05 end

    local function solidAt(mx, my)
        if mx < 0 or mx >= 16 or my < 0 or my >= 16 then
            return true
        end
        local row = map and map[my + 1]
        if not row then
            return true
        end
        return (row[mx + 1] or 1) ~= 0
    end

    local minMx = math.floor(x - r)
    local maxMx = math.floor(x + r)
    local minMy = math.floor(y - r)
    local maxMy = math.floor(y + r)
    local clearance = PLAYER_WALL_CLEARANCE_EPSILON or 0.004
    if clearance < 0 then clearance = 0 end
    local collisionR = r - (PLAYER_WALL_COLLISION_INSET or 0.005) + clearance
    if collisionR < 0.05 then collisionR = 0.05 end
    local rr = collisionR * collisionR

    for my = minMy, maxMy do
        for mx = minMx, maxMx do
            if solidAt(mx, my) then
                local nearestX = x
                local nearestY = y
                local tileMinX = mx
                local tileMaxX = mx + 1
                local tileMinY = my
                local tileMaxY = my + 1
                if nearestX < tileMinX then nearestX = tileMinX end
                if nearestX > tileMaxX then nearestX = tileMaxX end
                if nearestY < tileMinY then nearestY = tileMinY end
                if nearestY > tileMaxY then nearestY = tileMaxY end
                local dx = x - nearestX
                local dy = y - nearestY
                if (dx * dx + dy * dy) <= rr then
                    return false
                end
            end
        end
    end

    return true
end

local function updatePlayerSafetyAnchor()
    local radius = getPlayerCollisionRadius()
    if isWalkableWithRadius(px, py, radius) then
        lastSafeWallX = px
        lastSafeWallY = py
        return true
    end
    return false
end

local RECOVER_DIRS = {
    { 1.0,  0.0}, {-1.0,  0.0}, { 0.0,  1.0}, { 0.0, -1.0},
    { 0.7071,  0.7071}, { 0.7071, -0.7071}, {-0.7071,  0.7071}, {-0.7071, -0.7071},
}

local function recoverPlayerFromWallPenetration()
    local radius = getPlayerCollisionRadius()
    if isWalkableWithRadius(px, py, radius) then
        lastSafeWallX = px
        lastSafeWallY = py
        return false
    end

    if lastSafeWallX and lastSafeWallY and isWalkableWithRadius(lastSafeWallX, lastSafeWallY, radius) then
        px = lastSafeWallX
        py = lastSafeWallY
        PERF_MONITOR_WALL_RECOVERIES = (PERF_MONITOR_WALL_RECOVERIES or 0) + 1
        return true
    end

    local baseX = px
    local baseY = py
    local step = PLAYER_MOVE_SUBSTEP or 0.08
    if step < 0.01 then step = 0.01 end
    if step > 0.05 then step = 0.05 end
    local maxRadius = (PLAYER_COLLISION_RADIUS or 0.27) + 0.30
    local r = step
    while r <= maxRadius do
        for i = 1, #RECOVER_DIRS do
            local dir = RECOVER_DIRS[i]
            local tx = baseX + dir[1] * r
            local ty = baseY + dir[2] * r
            if isWalkableWithRadius(tx, ty, radius) then
                px = tx
                py = ty
                lastSafeWallX = tx
                lastSafeWallY = ty
                PERF_MONITOR_WALL_RECOVERIES = (PERF_MONITOR_WALL_RECOVERIES or 0) + 1
                return true
            end
        end
        r = r + step
    end

    local level = LEVELS and LEVELS[currentLevel]
    if level and level.playerStart then
        local sx = level.playerStart.x
        local sy = level.playerStart.y
        if isWalkableWithRadius(sx, sy, radius) then
            px = sx
            py = sy
            lastSafeWallX = sx
            lastSafeWallY = sy
            PERF_MONITOR_WALL_RECOVERIES = (PERF_MONITOR_WALL_RECOVERIES or 0) + 1
            return true
        end
    end

    return false
end

-- Movement collision helper (walls + sprites)
function canMove(x, y, radius)
    if not isWalkableWithRadius(x, y, radius) then
        return false
    end
    if collidesWithSprite(x, y, radius) then
        return false
    end
    return true
end

local function movePlayerStrict(deltaX, deltaY)
    recoverPlayerFromWallPenetration()
    local maxDelta = math.max(math.abs(deltaX or 0), math.abs(deltaY or 0))
    if maxDelta <= 0 then
        updatePlayerSafetyAnchor()
        return
    end
    local subStep = PLAYER_MOVE_SUBSTEP_STRICT or PLAYER_MOVE_SUBSTEP or 0.04
    if subStep <= 0 then subStep = 0.04 end
    if subStep > 0.04 then subStep = 0.04 end
    local subCount = math.ceil(maxDelta / subStep)
    if subCount < 1 then subCount = 1 end
    local stepX = (deltaX or 0) / subCount
    local stepY = (deltaY or 0) / subCount
    local radius = getPlayerCollisionRadius()
    local lastGoodX = px
    local lastGoodY = py

    local function isInsideSolidTile(x, y)
        local mx = math.floor(x)
        local my = math.floor(y)
        if mx < 0 or mx >= 16 or my < 0 or my >= 16 then
            return true
        end
        local row = map and map[my + 1]
        if not row then
            return true
        end
        local tile = row[mx + 1] or 1
        return tile > 0
    end

    local function tryStrictStep(moveX, moveY)
        local nx = px + moveX
        local ny = py + moveY
        if canMove(nx, ny, radius) then
            px = nx
            py = ny
            return true
        end

        PERF_MONITOR_MOVE_BLOCKED = (PERF_MONITOR_MOVE_BLOCKED or 0) + 1

        local moved = false
        if moveX ~= 0 then
            local slideX = px + moveX
            if canMove(slideX, py, radius) then
                px = slideX
                moved = true
            end
        end
        if moveY ~= 0 then
            local slideY = py + moveY
            if canMove(px, slideY, radius) then
                py = slideY
                moved = true
            end
        end
        return moved
    end

    for _ = 1, subCount do
        local stepMoved = tryStrictStep(stepX, stepY)
        if isInsideSolidTile(px, py) then
            -- Safety: never remain inside a wall cell; restore last valid position.
            px = lastGoodX
            py = lastGoodY
            break
        end
        if not isWalkableWithRadius(px, py, radius) then
            if not recoverPlayerFromWallPenetration() then
                px = lastGoodX
                py = lastGoodY
                break
            end
        end
        if stepMoved then
            lastGoodX = px
            lastGoodY = py
        end
    end
    updatePlayerSafetyAnchor()
end

local function movePlayerWithSlide(deltaX, deltaY)
    movePlayerStrict(deltaX, deltaY)
end

local function getPlayerRenderNearClipDist()
    local nearClip = PLAYER_RENDER_NEAR_CLIP_DIST or 0.6
    if nearClip < 0.25 then nearClip = 0.25 end
    return nearClip
end

local function getFogFactor(dist)
    if DEBUG_DISABLE_FOG then
        return 0.0
    end
    local startDist = FOG_START or 0.0
    local endDist = FOG_END or (startDist + 1.0)
    if endDist <= startDist then
        endDist = startDist + 0.001
    end
    if dist <= startDist then return 0.0 end
    if dist >= endDist then return 1.0 end
    return (dist - startDist) / (endDist - startDist)
end

local function getFogQuantizedFactor(dist)
    if DEBUG_DISABLE_FOG then
        return 0.0
    end
    local startDist = FOG_START or 0.0
    local endDist = FOG_END or (startDist + 0.5)
    if endDist <= startDist then
        endDist = startDist + 0.5
    end
    if dist <= startDist then
        return 0.0
    end
    if dist >= endDist then
        return 1.0
    end

    local span = endDist - startDist
    if span < 0.5 then span = 0.5 end
    local stepCount = math.max(1, math.floor((span / 0.5) + 0.5))
    local raw = (dist - startDist) / span
    if raw < 0 then raw = 0 end
    if raw > 1 then raw = 1 end
    local k = math.ceil(raw * stepCount)
    if k < 0 then k = 0 end
    if k > stepCount then k = stepCount end
    return k / (stepCount + 1)
end

local function fogBlend(color, dist)
    local t = getFogQuantizedFactor(dist)
    if t <= 0 then return color end
    if t >= 1 then return FOG_COLOR end
    local r = color & 0x1F
    local g = (color >> 5) & 0x3F
    local b = (color >> 11) & 0x1F
    local fr = FOG_COLOR & 0x1F
    local fg = (FOG_COLOR >> 5) & 0x3F
    local fb = (FOG_COLOR >> 11) & 0x1F
    local nr = math.floor(r + (fr - r) * t + 0.5)
    local ng = math.floor(g + (fg - g) * t + 0.5)
    local nb = math.floor(b + (fb - b) * t + 0.5)
    return (nb << 11) | (ng << 5) | nr
end

local function getFogAccentColor(baseColor)
    local c = baseColor or COLOR_GRAY
    if c == COLOR_WHITE then return COLOR_LIGHT_GRAY end
    if c == COLOR_LIGHT_GRAY then return COLOR_WHITE end
    if c == COLOR_GRAY then return COLOR_LIGHT_GRAY end
    if c == COLOR_DARK_GRAY then return COLOR_GRAY end
    if c == COLOR_BLACK then return COLOR_DARK_GRAY end
    if c == COLOR_MAROON then return COLOR_DARK_GRAY end
    return COLOR_LIGHT_GRAY
end

local function drawFogOverlayArea(x1, y1, x2, y2, fogAlpha)
    if fogAlpha <= 0 then
        return
    end
    if y2 < y1 then
        return
    end
    local fogPrimary = FOG_COLOR or COLOR_GRAY
    local fogAccent = getFogAccentColor(fogPrimary)
    local fogAccentCross = getFogAccentColor(fogAccent)
    if fogPrimary == COLOR_BLACK or fogPrimary == COLOR_DARK_GRAY then
        -- Keep dark fog subtle: avoid bright cross-hatch lines.
        fogAccentCross = fogAccent
    end
    local ditherSize = FOG_DITHER_SIZE or 3
    if ditherSize < 1 then ditherSize = 1 end
    if ditherSize > 6 then ditherSize = 6 end

    if fogAlpha >= 1.0 then
        -- Full fog path must stay cheap: single fill call.
        vmupro.graphics.drawFillRect(x1, y1, x2, y2, fogPrimary)
        return
    end

    -- Fast translucent fog: quantized bands with sparse dual-diagonal hatch.
    -- Cross-hatch is only added at higher fog coverage to keep cost low.
    local levels = 14
    local coverage = math.floor((fogAlpha * levels) + 0.5)
    if coverage < 1 then return end
    if coverage > levels then coverage = levels end
    local bandH = ditherSize
    if bandH < 1 then bandH = 1 end
    local accentStepA = (ditherSize * 2) + 4
    local accentStepB = accentStepA + ditherSize + 2
    local threshold = coverage / levels
    for y = y1, y2, bandH do
        local yb = y + bandH - 1
        if yb > y2 then yb = y2 end
        local rowIdx = math.floor((y - y1) / bandH)
        local bandMix = ((rowIdx * 5 + x1) % levels) / levels
        if bandMix < threshold then
            vmupro.graphics.drawFillRect(x1, y, x2, yb, fogPrimary)
            if coverage >= 4 then
                local startA = x1 + ((rowIdx * (ditherSize + 1) + ditherSize) % accentStepA)
                for x = startA, x2, accentStepA do
                    vmupro.graphics.drawFillRect(x, y, x, yb, fogAccent)
                end
            end
            if coverage >= 7 then
                local rowPhase = (rowIdx * (ditherSize + 2)) % accentStepB
                local startB = x1 + ((accentStepB - rowPhase) % accentStepB)
                for x = startB, x2, accentStepB do
                    vmupro.graphics.drawFillRect(x, y, x, yb, fogAccentCross)
                end
            end
        end
    end
end

local function drawFogCurtainColumn(sx, ex, dist)
    if DEBUG_DISABLE_FOG then
        return
    end
    local d = dist or (FOG_END or EXP_TEX_MAX_DIST or 8.0)
    if d < 0.4 then d = 0.4 end
    local wallScale = VIEWPORT_H - 20
    local h = math.floor(wallScale / d)
    if h < 2 then
        return
    end
    if h > VIEWPORT_H then h = VIEWPORT_H end
    local y1 = HORIZON - math.floor(h / 2)
    local y2 = HORIZON + math.floor(h / 2)
    if y1 < 0 then y1 = 0 end
    if y2 > (VIEWPORT_H - 1) then y2 = VIEWPORT_H - 1 end
    vmupro.graphics.drawFillRect(sx, y1, ex, y2, FOG_COLOR or COLOR_GRAY)
end

local function getWallSheetForType(wtype)
    if wtype == 1 then return wallSheetStone end
    if wtype == 2 then return wallSheetBrick end
    if wtype == 3 then return wallSheetMoss end
    if wtype == 4 then return wallSheetMetal end
    if wtype == 5 then return wallSheetWood end
    if wtype == 6 then return wallSheetWindow end
    return wallSheetStone
end

local function drawWallTextureColumn(wtype, side, texCoord, sx, y1, y2, colW, distToWall, mipLevel)
    local wallH = y2 - y1
    if wallH <= 0 then return false end

    local width = colW or 4
    if width < 1 then width = 1 end
    local drawWidth = width
    if sx < 0 then
        drawWidth = drawWidth + sx
        sx = 0
    end
    if sx > 239 then
        return false
    end
    if (sx + drawWidth - 1) > 239 then
        drawWidth = 240 - sx
    end
    if drawWidth < 1 then
        return false
    end

    -- Sheet-column path: sample from 1x128 frame columns.
    local sheet = getWallSheetForType(wtype)
    if not sheet or not sheet.frameWidth or not sheet.frameHeight or not sheet.frameCount then
        return false
    end
    local frameW = sheet.frameWidth or 0
    local frameH = sheet.frameHeight or 0
    local frameCount = sheet.frameCount or 0
    if frameW <= 0 or frameH <= 0 or frameCount <= 0 then
        return false
    end

    local u = texCoord or 0
    if u ~= u or u == math.huge or u == -math.huge then
        return false
    end
    if u < 0 then u = 0 end
    if u > 0.999 then u = 0.999 end
    local frameIndex = math.floor(u * frameCount) + 1
    if frameIndex ~= frameIndex or frameIndex == math.huge or frameIndex == -math.huge then
        frameIndex = 1
    end
    if frameIndex < 1 then frameIndex = 1 end
    if frameIndex > frameCount then frameIndex = frameCount end

    -- Mip tiers quantize texture-column selection for stable far detail and lower aliasing.
    -- MIP1 uses stride-only LOD (no texel quantization) to avoid near-distance angle shimmer.
    local mip = mipLevel or 0
    if mip > 1 then
        local groupSize = 1
        if mip >= 4 then
            groupSize = 6
        elseif mip == 3 then
            groupSize = 4
        elseif mip == 2 then
            groupSize = 3
        end
        if groupSize > 1 and frameCount > groupSize then
            frameIndex = (math.floor((frameIndex - 1) / groupSize) * groupSize) + 1
            if frameIndex ~= frameIndex or frameIndex == math.huge or frameIndex == -math.huge then
                frameIndex = 1
            end
            if frameIndex > frameCount then frameIndex = frameCount end
        end
    end

    local texDrawWidth = drawWidth
    if WALL_TEX_SEAM_OVERDRAW and drawWidth <= 4 then
        local seamPx = WALL_TEX_SEAM_PIXELS or 1
        if seamPx < 0 then seamPx = 0 end
        if seamPx > 2 then seamPx = 2 end
        local roomRight = 240 - (sx + texDrawWidth)
        if roomRight > 0 and seamPx > 0 then
            if seamPx > roomRight then seamPx = roomRight end
            texDrawWidth = texDrawWidth + seamPx
        end
    end

    local scaleX = texDrawWidth / frameW
    local scaleY = (expScaleYLut and expScaleYLut[wallH]) or (wallH / frameH)
    if scaleX <= 0 or scaleY <= 0 or scaleY ~= scaleY or scaleY == math.huge or scaleY == -math.huge then
        return false
    end
    local perfSample = (DEBUG_PERF_MONITOR == true) and (PERF_MONITOR_ACTIVE_SAMPLE == true)
    local trackCounters = (DEBUG_PERF_MONITOR == true)
    local canTime = perfSample and vmupro and vmupro.system and vmupro.system.getTimeUs
    local t0
    if canTime then
        t0 = vmupro.system.getTimeUs()
    end
    vmupro.sprite.drawFrameScaled(sheet, frameIndex, sx, y1, scaleX, scaleY, vmupro.sprite.kImageUnflipped)
    if canTime and t0 then
        local t1 = vmupro.system.getTimeUs()
        PERF_MONITOR_SAMPLE_WALL_US = (PERF_MONITOR_SAMPLE_WALL_US or 0) + (t1 - t0)
    end

    if not DEBUG_DISABLE_FOG and distToWall then
        local x2 = sx + texDrawWidth - 1
        if x2 > 239 then x2 = 239 end
        if y1 < 0 then y1 = 0 end
        if y2 > 239 then y2 = 239 end
        local fogAlpha = getFogQuantizedFactor(distToWall)
        if fogAlpha > 0 then
            if trackCounters then
                PERF_MONITOR_FOG_COLS = (PERF_MONITOR_FOG_COLS or 0) + drawWidth
            end
            if canTime then
                t0 = vmupro.system.getTimeUs()
            end
            drawFogOverlayArea(sx, y1, x2, y2, fogAlpha)
            if canTime and t0 then
                local t1 = vmupro.system.getTimeUs()
                PERF_MONITOR_SAMPLE_FOG_US = (PERF_MONITOR_SAMPLE_FOG_US or 0) + (t1 - t0)
            end
        end
    end
    return true
end

expRayOffsets = expRayOffsets or {}
expTablesReady = expTablesReady or false
rayDirXFix = rayDirXFix or {}
rayDirYFix = rayDirYFix or {}
rayDirCos = rayDirCos or {}
rayDirSin = rayDirSin or {}
invRayDirXFix = invRayDirXFix or {}
invRayDirYFix = invRayDirYFix or {}
deltaDistXFix = deltaDistXFix or {}
deltaDistYFix = deltaDistYFix or {}
EXP_FIXED_DIR_SUBDIV = 32
EXP_FIXED_DIR_STEPS = 64 * EXP_FIXED_DIR_SUBDIV
local EXP_FIX_TILE = 256
local EXP_FIX_DIST = 65536
EXP_RAYCOLS = 24
EXP_COLW = 10
EXP_MAX_STEPS = 32
EXP_MAX_DIST = 80
EXP_RADIUS = 20
EXP_BUCKETS = 8
EXP_TEX_MAX_DIST = EXP_TEX_MAX_DIST or DRAW_DIST_PRESETS[DRAW_DIST_INDEX]
EXP_VIEW_DIST = EXP_VIEW_DIST or EXP_TEX_MAX_DIST
HYBRID_TEX_MAX_H = VIEWPORT_H
USE_FIXED_RAYCAST = false
DEBUG_FORCE_FLOAT_RAYCAST = false
EXP_DIST_LUT_SIZE = 256
expHeightLut = expHeightLut or {}
expScaleYLut = expScaleYLut or {}
expHeightLutReady = expHeightLutReady or false

local function ensureExpTables()
    if expTablesReady then return end
    local dirSteps = EXP_FIXED_DIR_STEPS or 2048
    local twoPi = (renderCfg and renderCfg.twoPi) or 6.28318
    for i = 0, dirSteps - 1 do
        local angle = (i * twoPi) / dirSteps
        local cx = math.cos(angle)
        local sy = math.sin(angle)
        rayDirCos[i] = cx
        rayDirSin[i] = sy
        rayDirXFix[i] = math.floor(cx * 256)
        rayDirYFix[i] = math.floor(sy * 256)
        if math.abs(cx) < 0.0000001 then
            invRayDirXFix[i] = 0x7FFFFFFF
        else
            invRayDirXFix[i] = math.floor((1 / cx) * 65536)
        end
        if math.abs(sy) < 0.0000001 then
            invRayDirYFix[i] = 0x7FFFFFFF
        else
            invRayDirYFix[i] = math.floor((1 / sy) * 65536)
        end
        deltaDistXFix[i] = math.abs(invRayDirXFix[i])
        deltaDistYFix[i] = math.abs(invRayDirYFix[i])
    end
    expTablesReady = true
end

local function ensureExpHeightLut()
    if expHeightLutReady then return end
    local wallScale = VIEWPORT_H - 20
    local size = EXP_DIST_LUT_SIZE or 256
    local maxDist = EXP_MAX_DIST or 16
    for i = 1, size do
        local dist = (i / size) * maxDist
        if dist < 0.4 then dist = 0.4 end
        expHeightLut[i] = math.floor(wallScale / dist)
    end
    for h = 0, VIEWPORT_H do
        expScaleYLut[h] = h / 128
    end
    expHeightLutReady = true
end

local function getExpRayOffsets(rayCols)
    local key = tostring(rayCols)
    local cached = expRayOffsets[key]
    if cached then return cached end
    local offsets = {}
    if rayCols <= 1 then
        offsets[1] = 0
    else
        local subdiv = EXP_FIXED_DIR_SUBDIV or 32
        local fovUnits = (renderCfg.fovSteps or 9) * subdiv
        local half = fovUnits / 2
        for x = 0, rayCols - 1 do
            local t = x / (rayCols - 1)
            local off = -half + t * fovUnits
            if off >= 0 then
                offsets[x + 1] = math.floor(off + 0.5)
            else
                offsets[x + 1] = math.ceil(off - 0.5)
            end
        end
    end
    expRayOffsets[key] = offsets
    return offsets
end

local function getStartSolidRayFallback(pxVal, pyVal, mapX, mapY, startTile)
    local fx = pxVal - mapX
    local fy = pyVal - mapY
    if fx < 0 then fx = 0 elseif fx > 0.999 then fx = 0.999 end
    if fy < 0 then fy = 0 elseif fy > 0.999 then fy = 0.999 end

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

local function expCastRayFixed(rayDir, maxDist)
    ensureExpTables()
    local posXFix = math.floor(px * EXP_FIX_TILE)
    local posYFix = math.floor(py * EXP_FIX_TILE)
    local mapX = math.floor(posXFix / EXP_FIX_TILE)
    local mapY = math.floor(posYFix / EXP_FIX_TILE)
    local rayMaxDist = maxDist or 16
    if rayMaxDist < 0.25 then
        rayMaxDist = 0.25
    end
    local rayMaxDistFix = math.floor(rayMaxDist * EXP_FIX_DIST)

    -- Guard against rare movement penetration: stabilize rendering when inside a wall cell.
    if mapX >= 0 and mapX < 16 and mapY >= 0 and mapY < 16 then
        local startTile = map and map[mapY + 1] and map[mapY + 1][mapX + 1] or 0
        if startTile and startTile > 0 then
            return getStartSolidRayFallback(px, py, mapX, mapY, startTile)
        end
    end

    local dirXFix = rayDirXFix[rayDir] or 0
    local dirYFix = rayDirYFix[rayDir] or 0
    local stepX = (dirXFix < 0) and -1 or 1
    local stepY = (dirYFix < 0) and -1 or 1

    local deltaX = deltaDistXFix[rayDir] or 0x7FFFFFFF
    local deltaY = deltaDistYFix[rayDir] or 0x7FFFFFFF

    local nextXFix = (mapX + (stepX > 0 and 1 or 0)) * EXP_FIX_TILE
    local nextYFix = (mapY + (stepY > 0 and 1 or 0)) * EXP_FIX_TILE
    local distToNextX = nextXFix - posXFix
    local distToNextY = nextYFix - posYFix
    if distToNextX < 0 then distToNextX = -distToNextX end
    if distToNextY < 0 then distToNextY = -distToNextY end

    local sideDistX = math.floor((distToNextX * deltaX) / EXP_FIX_TILE)
    local sideDistY = math.floor((distToNextY * deltaY) / EXP_FIX_TILE)

    local side = 0
    local wtype = 1
    local hit = false
    local maxSteps = EXP_MAX_STEPS or 8
    for _ = 1, maxSteps do
        local nextDist = sideDistX
        if sideDistY < nextDist then nextDist = sideDistY end
        if nextDist > rayMaxDistFix then
            break
        end
        if sideDistX < sideDistY then
            sideDistX = sideDistX + deltaX
            mapX = mapX + stepX
            side = 0
        else
            sideDistY = sideDistY + deltaY
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
    if not hit then
        return rayMaxDist, 1, 0, 0, false
    end

    local perpFix
    if side == 0 then
        local numFix = ((mapX * EXP_FIX_TILE) - posXFix + ((stepX == -1) and EXP_FIX_TILE or 0))
        perpFix = math.floor((numFix * (invRayDirXFix[rayDir] or 0)) / EXP_FIX_TILE)
    else
        local numFix = ((mapY * EXP_FIX_TILE) - posYFix + ((stepY == -1) and EXP_FIX_TILE or 0))
        perpFix = math.floor((numFix * (invRayDirYFix[rayDir] or 0)) / EXP_FIX_TILE)
    end
    if perpFix < 1 then perpFix = 1 end

    local texFix
    if side == 0 then
        local texCalc = posYFix + math.floor((perpFix * dirYFix) / EXP_FIX_DIST)
        texFix = texCalc % EXP_FIX_TILE
    else
        local texCalc = posXFix + math.floor((perpFix * dirXFix) / EXP_FIX_DIST)
        texFix = texCalc % EXP_FIX_TILE
    end
    local texCoord = texFix / EXP_FIX_TILE
    local dist = perpFix / EXP_FIX_DIST
    if dist > rayMaxDist then
        return rayMaxDist, 1, 0, 0, false
    end
    return dist, wtype, side, texCoord, true
end

local expDepthBuf = {}
local function renderWallsExperimentalHybrid()
    -- Stability-first EXP-H: use one raycast projection model at all distances.
    -- This prevents wall seams/shape shifts when draw distance changes.
    local hybridViewDist = EXP_VIEW_DIST or (EXP_TEX_MAX_DIST or 8.0)
    local texView = EXP_TEX_MAX_DIST or hybridViewDist
    local fogView = FOG_END or texView
    if fogView < 0.5 then fogView = 0.5 end
    local rayTraceDist = texView
    if rayTraceDist < 0.5 then rayTraceDist = 0.5 end

    local fovRad = renderCfg.fovSteps * (renderCfg.twoPi / 64)
    local playerDir = pdir % 64
    local playerAngle = playerDir * (renderCfg.twoPi / 64)
    local playerCos = math.cos(playerAngle)
    local playerSin = math.sin(playerAngle)
    local rayCols = 60
    local colW = 4
    local basePresetIdx = RAY_PRESET_INDEX or 1
    local effectivePresetIdx = getEffectiveRayPresetIndex(basePresetIdx)
    local preset = RAY_PRESETS and RAY_PRESETS[effectivePresetIdx] or nil
    if preset then
        rayCols = preset.rays or rayCols
        colW = preset.colW or colW
    elseif LOW_RES_WALLS then
        if LOW_RES_MODE == "fast" then
            rayCols = 40
            colW = 6
        else
            rayCols = 60
            colW = 4
        end
    end
    local useFixedRaycast = (USE_FIXED_RAYCAST == true) and (DEBUG_FORCE_FLOAT_RAYCAST ~= true)
    local perfSample = (DEBUG_PERF_MONITOR == true) and (PERF_MONITOR_ACTIVE_SAMPLE == true)
    local trackCounters = (DEBUG_PERF_MONITOR == true)
    local canTime = perfSample and vmupro and vmupro.system and vmupro.system.getTimeUs
    local rayOffsets = nil
    local playerDirFix = 0
    local rayStep = 0
    local stepCos1, stepCos2, stepCos3, stepCos4
    local stepSin1, stepSin2, stepSin3, stepSin4
    local rayCos = 0
    local raySin = 0
    if useFixedRaycast then
        ensureExpTables()
        playerDirFix = (playerDir % 64) * (EXP_FIXED_DIR_SUBDIV or 32)
        rayOffsets = getExpRayOffsets(rayCols)
    else
        local baseAngle = playerAngle - (fovRad / 2)
        rayStep = fovRad / rayCols
        stepCos1 = math.cos(rayStep)
        stepCos2 = math.cos(rayStep * 2)
        stepCos3 = math.cos(rayStep * 3)
        stepCos4 = math.cos(rayStep * 4)
        stepSin1 = math.sin(rayStep)
        stepSin2 = math.sin(rayStep * 2)
        stepSin3 = math.sin(rayStep * 3)
        stepSin4 = math.sin(rayStep * 4)
        rayCos = math.cos(baseAngle)
        raySin = math.sin(baseAngle)
    end
    perfMonitorSetRayInfo(basePresetIdx, effectivePresetIdx, useFixedRaycast)
    local stableProjection = (WALL_PROJECTION_MODE == "stable")

    -- Ray-LOD derives from preset steps and keeps mip tiers independent where possible.
    local lodStride1, lodStride2, lodStride3, lodStride4 = 1, 2, 3, 4
    if preset and RAY_PRESETS and #RAY_PRESETS > 0 then
        local baseIdx = effectivePresetIdx
        local baseRays = preset.rays or rayCols
        local function strideFromPresetStep(stepDown)
            local targetIdx = baseIdx - stepDown
            if targetIdx < 1 then targetIdx = 1 end
            local target = RAY_PRESETS[targetIdx]
            local targetRays = target and target.rays or baseRays
            if not targetRays or targetRays < 1 then
                return 1
            end
            local s = math.ceil(baseRays / targetRays)
            if s < 1 then s = 1 end
            return s
        end
        local maxStride = 6
        local minFarRays = 3
        if baseRays and baseRays > 0 then
            maxStride = math.floor(baseRays / minFarRays)
            if maxStride < 1 then maxStride = 1 end
            if maxStride > 6 then maxStride = 6 end
        end
        lodStride1 = strideFromPresetStep(1)
        lodStride2 = math.max(strideFromPresetStep(2), lodStride1 + 1)
        lodStride3 = math.max(strideFromPresetStep(3), lodStride2 + 1)
        lodStride4 = math.max(strideFromPresetStep(4), lodStride3 + 1)

        -- Keep tiers independent and progressively more aggressive.
        if maxStride >= 2 and lodStride1 < 2 then lodStride1 = 2 end
        if maxStride >= 3 and lodStride2 < 3 then lodStride2 = 3 end
        if maxStride >= 4 and lodStride3 < 4 then lodStride3 = 4 end
        if maxStride >= 5 and lodStride4 < 5 then lodStride4 = 5 end

        if lodStride1 > maxStride then lodStride1 = maxStride end
        if lodStride2 > maxStride then lodStride2 = maxStride end
        if lodStride3 > maxStride then lodStride3 = maxStride end
        if lodStride4 > maxStride then lodStride4 = maxStride end
        if lodStride2 < lodStride1 then lodStride2 = lodStride1 end
        if lodStride3 < lodStride2 then lodStride3 = lodStride2 end
        if lodStride4 < lodStride3 then lodStride4 = lodStride3 end
    end

    -- Mip thresholds are evaluated once per frame so each tier is independent and cheap in the hot ray loop.
    -- Order is still strictly monotonic for deterministic tier transitions.
    local mip1Thresh = WALL_MIPMAP_DIST1 or 4.0
    local mip2Thresh = WALL_MIPMAP_DIST2 or (mip1Thresh + 2.0)
    local mip3Thresh = WALL_MIPMAP_DIST3 or (mip2Thresh + 2.0)
    local mip4Thresh = WALL_MIPMAP_DIST4 or (mip3Thresh + 2.0)
    if mip2Thresh <= mip1Thresh then mip2Thresh = mip1Thresh + 0.1 end
    if mip3Thresh <= mip2Thresh then mip3Thresh = mip2Thresh + 0.1 end
    if mip4Thresh <= mip3Thresh then mip4Thresh = mip3Thresh + 0.1 end

    local x = 0
    while x < rayCols do
        local rayStride = 1
        local mipLevel = 0
        local castCos, castSin
        local dist, wtype, side, texCoord, rayHit
        local castT0
        if canTime then
            castT0 = vmupro.system.getTimeUs()
        end
        if useFixedRaycast then
            local rayOff = (rayOffsets and rayOffsets[x + 1]) or 0
            local rayDir = (playerDirFix + rayOff) % (EXP_FIXED_DIR_STEPS or 2048)
            castCos = rayDirCos[rayDir] or playerCos
            castSin = rayDirSin[rayDir] or playerSin
            dist, wtype, side, texCoord, rayHit = expCastRayFixed(rayDir, rayTraceDist)
        else
            castCos = rayCos
            castSin = raySin
            dist, wtype, side, texCoord, rayHit = castRay(castCos, castSin, rayTraceDist)
        end
        if canTime and castT0 then
            local castT1 = vmupro.system.getTimeUs()
            PERF_MONITOR_SAMPLE_RAYCAST_US = (PERF_MONITOR_SAMPLE_RAYCAST_US or 0) + (castT1 - castT0)
        end
        local fixedDist = dist * (castCos * playerCos + castSin * playerSin)
        local nearClipDist = getPlayerRenderNearClipDist()
        if fixedDist < nearClipDist then fixedDist = nearClipDist end
        if not rayHit then
            fixedDist = fogView
            if fixedDist < texView then fixedDist = texView end
            if fixedDist > hybridViewDist then fixedDist = hybridViewDist end
        end

        local nearForce = rayHit and (fixedDist < (MIP_NEAR_FORCE_DIST or 1.35))
        if WALL_MIPMAP_ENABLED and MIP_LOD_ENABLED and not nearForce then
            if fixedDist >= mip4Thresh then
                mipLevel = 4
            elseif fixedDist >= mip3Thresh then
                mipLevel = 3
            elseif fixedDist >= mip2Thresh then
                mipLevel = 2
            elseif fixedDist >= mip1Thresh then
                mipLevel = 1
            end
        end
        if WALL_MIPMAP_ENABLED and MIP_LOD_ENABLED and not nearForce and not stableProjection then
            if mipLevel >= 4 then
                rayStride = lodStride4
            elseif mipLevel == 3 then
                rayStride = lodStride3
            elseif mipLevel == 2 then
                rayStride = lodStride2
            elseif mipLevel == 1 then
                rayStride = lodStride1
            end
        end

        local remaining = rayCols - x
        if rayStride > remaining then
            rayStride = remaining
        end
        if rayStride < 1 then
            rayStride = 1
        end

        local drawColW = colW
        if not stableProjection then
            drawColW = colW * rayStride
        end
        local sx = x * colW
        if sx <= 239 then
            local ex = sx + drawColW - 1
            if ex > 239 then ex = 239 end
            local spanW = (ex - sx) + 1

            if rayHit and fixedDist <= hybridViewDist then
                if trackCounters then
                    PERF_MONITOR_WALL_COLS_TOTAL = (PERF_MONITOR_WALL_COLS_TOTAL or 0) + spanW
                    if mipLevel <= 0 then
                        PERF_MONITOR_MIP_COLS_0 = (PERF_MONITOR_MIP_COLS_0 or 0) + spanW
                    elseif mipLevel == 1 then
                        PERF_MONITOR_MIP_COLS_1 = (PERF_MONITOR_MIP_COLS_1 or 0) + spanW
                    elseif mipLevel == 2 then
                        PERF_MONITOR_MIP_COLS_2 = (PERF_MONITOR_MIP_COLS_2 or 0) + spanW
                    elseif mipLevel == 3 then
                        PERF_MONITOR_MIP_COLS_3 = (PERF_MONITOR_MIP_COLS_3 or 0) + spanW
                    else
                        PERF_MONITOR_MIP_COLS_4 = (PERF_MONITOR_MIP_COLS_4 or 0) + spanW
                    end
                end
                local wallScale = VIEWPORT_H - 20
                local h = math.floor(wallScale / fixedDist)
                if h > VIEWPORT_H then h = VIEWPORT_H end
                local y1 = HORIZON - math.floor(h / 2)
                local y2 = HORIZON + math.floor(h / 2)
                if y1 < 0 then y1 = 0 end
                if y2 > (VIEWPORT_H - 1) then y2 = VIEWPORT_H - 1 end

                local fogAlpha = 0
                if not DEBUG_DISABLE_FOG then
                    fogAlpha = getFogQuantizedFactor(fixedDist)
                end
                local fogCut = FOG_TEX_CUTOFF or FOG_END or texView
                local farWall = (fixedDist > texView) or (fixedDist >= fogCut) or (fogAlpha >= 1.0)
                local farTexOff = FAR_TEX_OFF_DIST or 999
                local forceNoTexByDist = (farTexOff < 900) and (fixedDist >= farTexOff)

                local wantTex = (WALL_TEXTURE_MODE == "proper"
                    and not DEBUG_DISABLE_WALL_TEXTURE
                    and (nearForce or (not farWall and h < (HYBRID_TEX_MAX_H or (VIEWPORT_H - 8))))
                    and not forceNoTexByDist)
                if not wantTex then
                    local baseColor = getWallColor(wtype, side)
                    local drawT0
                    if canTime then drawT0 = vmupro.system.getTimeUs() end
                    vmupro.graphics.drawFillRect(sx, y1, ex, y2, baseColor)
                    if canTime and drawT0 then
                        local drawT1 = vmupro.system.getTimeUs()
                        PERF_MONITOR_SAMPLE_WALL_US = (PERF_MONITOR_SAMPLE_WALL_US or 0) + (drawT1 - drawT0)
                    end
                    if fogAlpha > 0 then
                        if trackCounters then
                            PERF_MONITOR_FOG_COLS = (PERF_MONITOR_FOG_COLS or 0) + spanW
                        end
                        if canTime then drawT0 = vmupro.system.getTimeUs() end
                        drawFogOverlayArea(sx, y1, ex, y2, fogAlpha)
                        if canTime and drawT0 then
                            local fogT1 = vmupro.system.getTimeUs()
                            PERF_MONITOR_SAMPLE_FOG_US = (PERF_MONITOR_SAMPLE_FOG_US or 0) + (fogT1 - drawT0)
                        end
                    end
                else
                    local useTex = texCoord or 0
                    if useTex < 0 then useTex = 0 end
                    if useTex > 0.999 then useTex = 0.999 end
                    local flipEps = 0.0008
                    if side == 0 and castCos > flipEps then
                        useTex = 1.0 - useTex
                    elseif side == 1 and castSin < -flipEps then
                        useTex = 1.0 - useTex
                    end
                    if useTex < 0.001 then useTex = 0.001 end
                    if useTex > 0.998 then useTex = 0.998 end
                    local drewTex = drawWallTextureColumn(wtype, side, useTex, sx, y1, y2, drawColW, fixedDist, mipLevel)
                    if not drewTex then
                        if trackCounters then
                            PERF_MONITOR_WALL_COLS_FALLBACK = (PERF_MONITOR_WALL_COLS_FALLBACK or 0) + spanW
                        end
                        local baseColor = getWallColor(wtype, side)
                        local drawT0
                        if canTime then drawT0 = vmupro.system.getTimeUs() end
                        vmupro.graphics.drawFillRect(sx, y1, ex, y2, baseColor)
                        if canTime and drawT0 then
                            local drawT1 = vmupro.system.getTimeUs()
                            PERF_MONITOR_SAMPLE_WALL_US = (PERF_MONITOR_SAMPLE_WALL_US or 0) + (drawT1 - drawT0)
                        end
                        if fogAlpha > 0 then
                            if trackCounters then
                                PERF_MONITOR_FOG_COLS = (PERF_MONITOR_FOG_COLS or 0) + spanW
                            end
                            if canTime then drawT0 = vmupro.system.getTimeUs() end
                            drawFogOverlayArea(sx, y1, ex, y2, fogAlpha)
                            if canTime and drawT0 then
                                local fogT1 = vmupro.system.getTimeUs()
                                PERF_MONITOR_SAMPLE_FOG_US = (PERF_MONITOR_SAMPLE_FOG_US or 0) + (fogT1 - drawT0)
                            end
                        end
                    else
                        if trackCounters then
                            PERF_MONITOR_WALL_COLS_TEXTURED = (PERF_MONITOR_WALL_COLS_TEXTURED or 0) + spanW
                        end
                    end
                end
            elseif not rayHit and not DEBUG_DISABLE_FOG then
                -- Draw a fog curtain when no wall was traced inside draw distance.
                -- This keeps fog coverage independent from draw-distance cutoff.
                if trackCounters then
                    PERF_MONITOR_FOG_COLS = (PERF_MONITOR_FOG_COLS or 0) + spanW
                end
                local fogT0
                if canTime then fogT0 = vmupro.system.getTimeUs() end
                drawFogCurtainColumn(sx, ex, fogView)
                if canTime and fogT0 then
                    local fogT1 = vmupro.system.getTimeUs()
                    PERF_MONITOR_SAMPLE_FOG_US = (PERF_MONITOR_SAMPLE_FOG_US or 0) + (fogT1 - fogT0)
                end
            end
        end

        if not useFixedRaycast then
            local sc, ss
            if rayStride == 1 then
                sc, ss = stepCos1, stepSin1
            elseif rayStride == 2 then
                sc, ss = stepCos2, stepSin2
            elseif rayStride == 3 then
                sc, ss = stepCos3, stepSin3
            elseif rayStride == 4 then
                sc, ss = stepCos4, stepSin4
            else
                sc = math.cos(rayStep * rayStride)
                ss = math.sin(rayStep * rayStride)
            end
            local newCos = rayCos * sc - raySin * ss
            local newSin = raySin * sc + rayCos * ss
            rayCos, raySin = newCos, newSin
        end
        x = x + rayStride
    end
end

function castRay(dx, dy, maxDist)
    if dx == 0 and dy == 0 then
        return 16, 1, 0, 0, false
    end

    local mapX = math.floor(px)
    local mapY = math.floor(py)
    local rayMaxDist = maxDist or 16
    if rayMaxDist < 0.25 then
        rayMaxDist = 0.25
    end

    -- Guard against rare movement penetration: stabilize rendering when inside a wall cell.
    if mapX >= 0 and mapX < 16 and mapY >= 0 and mapY < 16 then
        local startTile = map and map[mapY + 1] and map[mapY + 1][mapX + 1] or 0
        if startTile and startTile > 0 then
            return getStartSolidRayFallback(px, py, mapX, mapY, startTile)
        end
    end

    local deltaDistX = (dx == 0) and 1e9 or math.abs(1 / dx)
    local deltaDistY = (dy == 0) and 1e9 or math.abs(1 / dy)

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

    local hit = false
    local side = 0
    -- PERFORMANCE: Reduced from 64 to 32
    -- Map is only 16x16, and most rays hit walls well before this limit
    -- Cuts worst-case raycast iterations by 50% (240 rays × 32 = 7,680 vs 15,360)
    local maxSteps = 32
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

    if not hit then
        return rayMaxDist, 1, 0, 0, false
    end

    local perpWallDist
    if side == 0 then
        perpWallDist = (mapX - px + (1 - stepX) / 2) / (dx == 0 and 1e-6 or dx)
    else
        perpWallDist = (mapY - py + (1 - stepY) / 2) / (dy == 0 and 1e-6 or dy)
    end

    local texCoord
    if side == 0 then
        texCoord = py + perpWallDist * dy
    else
        texCoord = px + perpWallDist * dx
    end
    texCoord = texCoord - math.floor(texCoord)
    if texCoord < 0 then texCoord = texCoord + 1 end
    if texCoord > 0.999 then texCoord = 0.999 end

    return perpWallDist, wtype, side, texCoord, true
end

local function isVisible(tx, ty, cache)
    local expRenderer = isExpRenderer()
    local useCache = cache and (not expRenderer)
    if useCache then
        local lastFrame = cache._visFrame or -1000
        if frameCount - lastFrame < 14 then
            return cache._visValue == true
        end
    end
    local dx, dy = tx - px, ty - py
    local dist = math.sqrt(dx * dx + dy * dy)
    local maxDist = SPRITE_VIS_DIST or 6
    if expRenderer then
        local viewDist = EXP_VIEW_DIST or maxDist
        if viewDist < maxDist then maxDist = viewDist end
    end
    if dist > maxDist then
        if useCache then
            cache._visFrame = frameCount
            cache._visValue = false
        end
        return false
    end
    if expRenderer then
        local dir = pdir % 64
        local cosDir = cosTable[dir]
        local sinDir = sinTable[dir]
        local relX = dx * sinDir - dy * cosDir
        local relY = dx * cosDir + dy * sinDir
        if relY <= 0.05 then
            if useCache then
                cache._visFrame = frameCount
                cache._visValue = false
            end
            return false
        end
        local fovRad = renderCfg.fovSteps * (renderCfg.twoPi / 64)
        local maxSx = math.tan(fovRad / 2)
        local sx = relX / relY
        if sx < -maxSx or sx > maxSx then
            if useCache then
                cache._visFrame = frameCount
                cache._visValue = false
            end
            return false
        end
    end
    if dist < 0.1 then
        if useCache then
            cache._visFrame = frameCount
            cache._visValue = true
        end
        return true
    end
    dx, dy = dx / dist, dy / dist
    local rx, ry, traveled = px, py, 0
    local step = expRenderer and 0.1 or 0.25
    while traveled < dist - step do
        rx, ry = rx + dx * step, ry + dy * step
        traveled = traveled + step
        local mx, my = math.floor(rx), math.floor(ry)
        if mx >= 0 and mx < 16 and my >= 0 and my < 16 then
            if map[my + 1][mx + 1] > 0 then
                if useCache then
                    cache._visFrame = frameCount
                    cache._visValue = false
                end
                return false
            end
            -- Thicken the ray to avoid corner peeking
            local r = 0.1
            local mx1, mx2 = math.floor(rx - r), math.floor(rx + r)
            local my1, my2 = math.floor(ry - r), math.floor(ry + r)
            if mx1 < 0 or mx2 >= 16 or my1 < 0 or my2 >= 16 then
                if useCache then
                    cache._visFrame = frameCount
                    cache._visValue = false
                end
                return false
            end
            if map[my1 + 1][mx1 + 1] > 0 or map[my1 + 1][mx2 + 1] > 0
                or map[my2 + 1][mx1 + 1] > 0 or map[my2 + 1][mx2 + 1] > 0 then
                if useCache then
                    cache._visFrame = frameCount
                    cache._visValue = false
                end
                return false
            end
        end
    end
    if useCache then
        cache._visFrame = frameCount
        cache._visValue = true
    end
    return true
end

local function drawSprite(screenX, dist, stype, viewAngle, animFrame, spriteData)
    if dist < 0.3 then return end
    local size = math.floor(100 / dist)
    if size < 6 then return end
    if size > 140 then size = 140 end

    local hs = math.floor(size / 2)
    local x1, x2 = screenX - hs, screenX + hs
    -- Ground level matches wall bottom: HORIZON + 100/dist = HORIZON + size
    local groundY = HORIZON + size
    if groundY > VIEWPORT_H then groundY = VIEWPORT_H end
    local y1, y2 = groundY - size, groundY

    if x2 < 0 or x1 > 240 then return end

    -- Center Y for wall-mounted items (at eye level), ground for floor items
    local centerY = HORIZON  -- Wall-mounted items at eye level

    if stype == 1 then
        -- Detailed Torch (wall mounted, at eye level)
        local tw = math.floor(size / 5)
        local th = math.floor(size / 2)
        local tx1, tx2 = screenX - tw, screenX + tw
        -- Handle with wood grain
        vmupro.graphics.drawFillRect(tx1, centerY, tx2, centerY + th, COLOR_BROWN)
        vmupro.graphics.drawLine(tx1 + 2, centerY + 4, tx1 + 2, centerY + th - 4, COLOR_DARK_BROWN)
        vmupro.graphics.drawLine(tx2 - 2, centerY + 4, tx2 - 2, centerY + th - 4, COLOR_DARK_BROWN)
        -- Flame base
        local flameH = math.floor(size / 3)
        local flicker = (frameCount % 4) - 2
        vmupro.graphics.drawFillRect(tx1 - 2, centerY - flameH, tx2 + 2, centerY, COLOR_ORANGE)
        vmupro.graphics.drawFillRect(tx1, centerY - flameH - 4 + flicker, tx2, centerY - flameH + 4, COLOR_YELLOW)
        -- Inner flame
        vmupro.graphics.drawFillRect(screenX - 2, centerY - flameH + 4, screenX + 2, centerY - 4, COLOR_YELLOW)

    elseif stype == 2 then
        -- Detailed Barrel (sits on ground)
        local bw = math.floor(size / 2)
        local bh = math.floor(size * 0.6)
        local bx1, bx2 = screenX - bw, screenX + bw
        local by2 = y2  -- Bottom at ground
        local by1 = by2 - bh  -- Top
        local bCenterY = math.floor((by1 + by2) / 2)
        -- Main barrel body
        vmupro.graphics.drawFillRect(bx1 + 2, by1, bx2 - 2, by2, COLOR_BROWN)
        -- Curved sides
        vmupro.graphics.drawFillRect(bx1, by1 + 4, bx1 + 4, by2 - 4, COLOR_DARK_BROWN)
        vmupro.graphics.drawFillRect(bx2 - 4, by1 + 4, bx2, by2 - 4, COLOR_DARK_BROWN)
        -- Metal bands
        local bandH = 3
        vmupro.graphics.drawFillRect(bx1, by1 + 6, bx2, by1 + 6 + bandH, COLOR_GRAY)
        vmupro.graphics.drawFillRect(bx1, by2 - 6 - bandH, bx2, by2 - 6, COLOR_GRAY)
        vmupro.graphics.drawFillRect(bx1, bCenterY - 1, bx2, bCenterY + 2, COLOR_DARK_GRAY)
        -- Wood grain lines
        vmupro.graphics.drawLine(screenX - 4, by1 + 10, screenX - 4, by2 - 10, COLOR_DARK_BROWN)
        vmupro.graphics.drawLine(screenX + 4, by1 + 10, screenX + 4, by2 - 10, COLOR_DARK_BROWN)
        -- Top rim
        vmupro.graphics.drawFillRect(bx1 + 2, by1, bx2 - 2, by1 + 3, COLOR_LIGHT_BROWN)

    elseif stype == 3 then
        -- Detailed Table (sits on ground)
        local tw = math.floor(size * 0.7)
        local th = math.floor(size * 0.15)
        local legH = math.floor(size * 0.4)
        local tx1, tx2 = screenX - tw, screenX + tw
        local ty = y2 - legH - th  -- Table top position (legs touch ground at y2)
        -- Table top with wood grain
        vmupro.graphics.drawFillRect(tx1, ty, tx2, ty + th, COLOR_BROWN)
        vmupro.graphics.drawFillRect(tx1, ty, tx2, ty + 2, COLOR_LIGHT_BROWN)
        vmupro.graphics.drawLine(tx1 + 8, ty + 2, tx1 + 8, ty + th, COLOR_DARK_BROWN)
        vmupro.graphics.drawLine(tx2 - 8, ty + 2, tx2 - 8, ty + th, COLOR_DARK_BROWN)
        vmupro.graphics.drawLine(screenX, ty + 2, screenX, ty + th, COLOR_DARK_BROWN)
        -- Legs
        local legW = math.floor(size * 0.08)
        vmupro.graphics.drawFillRect(tx1 + 4, ty + th, tx1 + 4 + legW, y2, COLOR_DARK_BROWN)
        vmupro.graphics.drawFillRect(tx2 - 4 - legW, ty + th, tx2 - 4, y2, COLOR_DARK_BROWN)
        -- Cross beam
        vmupro.graphics.drawFillRect(tx1 + 4, y2 - 8, tx2 - 4, y2 - 5, COLOR_BROWN)

    elseif stype == 4 then
        -- Detailed Chest (sits on ground)
        local cw = math.floor(size * 0.5)
        local ch = math.floor(size * 0.35)
        local cx1, cx2 = screenX - cw, screenX + cw
        local cy2 = y2  -- Bottom at ground
        local cy1 = cy2 - ch  -- Top of body
        local lidTop = cy1 - math.floor(ch * 0.4)
        -- Main body
        vmupro.graphics.drawFillRect(cx1, cy1, cx2, cy2, COLOR_BROWN)
        -- Lid (slightly raised)
        vmupro.graphics.drawFillRect(cx1 - 2, lidTop, cx2 + 2, cy1, COLOR_LIGHT_BROWN)
        vmupro.graphics.drawFillRect(cx1, lidTop + 2, cx2, cy1 - 2, COLOR_BROWN)
        -- Metal corners
        vmupro.graphics.drawFillRect(cx1, cy1, cx1 + 4, cy2, COLOR_GRAY)
        vmupro.graphics.drawFillRect(cx2 - 4, cy1, cx2, cy2, COLOR_GRAY)
        vmupro.graphics.drawFillRect(cx1, lidTop, cx1 + 4, cy1, COLOR_GRAY)
        vmupro.graphics.drawFillRect(cx2 - 4, lidTop, cx2, cy1, COLOR_GRAY)
        -- Lock
        vmupro.graphics.drawFillRect(screenX - 4, cy1 - 6, screenX + 4, cy1 + 6, COLOR_YELLOW)
        vmupro.graphics.drawFillRect(screenX - 2, cy1 - 3, screenX + 2, cy1 + 3, COLOR_DARK_BROWN)
        -- Keyhole
        vmupro.graphics.drawFillRect(screenX - 1, cy1, screenX + 1, cy1 + 2, COLOR_BLACK)

    elseif stype == 5 then
        if spriteData and spriteData.dying and #warriorDeath > 0 then
            local frameIndex = spriteData.deathFrame or 1
            local sprite = warriorDeath[math.min(frameIndex, #warriorDeath)]
            if sprite and sprite.height then
                local desiredHeight = size
                local scale = safeDivide(desiredHeight, sprite.height, "renderWarriorDeath")
                local scaledWidth = sprite.width * scale
                local scaledHeight = sprite.height * scale
                local drawX = screenX - math.floor(scaledWidth / 2)
                local groundY = HORIZON + size
                if groundY > 240 then groundY = 240 end
                local drawY = groundY - math.floor(scaledHeight)
                if safeScale(sprite, scale, scale, "renderWarriorDeath") then
                    vmupro.sprite.drawScaled(sprite, drawX, drawY, scale, scale, vmupro.sprite.kImageUnflipped)
                end
            end
            return
        end
        -- Warrior Guard using real sprites
        -- Determine view: 0=front, 1=right, 2=back, 3=left
        local view = 0
        if viewAngle then
            if DEBUG_CYCLE_VIEW then
                view = math.floor(frameCount / DEBUG_CYCLE_VIEW_FRAMES) % 4
            elseif DEBUG_FORCE_VIEW then
                view = DEBUG_FORCE_VIEW
            elseif DEBUG_FORCE_SIDE_VIEW then
                view = (viewAngle >= 0) and 3 or 1
            else
                if viewAngle >= -8 and viewAngle <= 8 then view = 0
                elseif viewAngle > 8 and viewAngle < 24 then view = 3
                elseif viewAngle >= 24 or viewAngle <= -24 then view = 2
                else view = 1 end
            end
        end

        -- Attack animation (2-frame) overrides walk/idle
        if spriteData and spriteData.attackAnim and spriteData.attackAnim > 0 then
            local frameIndex = (spriteData.attackFrame or 1)
            local sprite = nil
            if view == 0 then
                sprite = warriorAttackFront[frameIndex]
            elseif view == 2 then
                sprite = warriorAttackBack[frameIndex]
            elseif view == 3 then
                sprite = warriorAttackLeft[frameIndex]
            else
                sprite = warriorAttackRight[frameIndex]
            end

            if sprite and sprite.height then
                local desiredHeight = size
                local scale = safeDivide(desiredHeight, sprite.height, "renderScale")
                local scaledWidth = sprite.width * scale
                local scaledHeight = sprite.height * scale
                local drawX = screenX - math.floor(scaledWidth / 2)
                local groundY = HORIZON + size
                if groundY > 240 then groundY = 240 end
                local drawY = groundY - math.floor(scaledHeight)
                vmupro.sprite.drawScaled(sprite, drawX, drawY, scale, scale, vmupro.sprite.kImageUnflipped)
            end
            return
        end

        -- Select appropriate sprite based on view and animation state
        local sprite = warriorFront
        local flipFlag = vmupro.sprite.kImageUnflipped
        local isMoving = animFrame ~= nil  -- Has animation = is patrolling
        if DEBUG_WALK_IN_PLACE then
            isMoving = true
        end
        local animTick = animFrame
        if DEBUG_FORCE_GLOBAL_WALK then
            animTick = frameCount
        end
        local debugWalkFrame = nil
        local debugSpriteLabel = "?"

        if view == 0 then
            -- Front view - use front sprite (no walking animation for front yet)
            if DEBUG_CYCLE_VIEW then
                local frameCount = DEBUG_FORCE_WALK_FRAMES or ((warriorWalk3Front and 3) or 2)
                local walkFrame = math.floor(animTick / 7) % frameCount
                debugWalkFrame = walkFrame
                if walkFrame == 0 and warriorWalk1Front then
                    sprite = warriorWalk1Front
                    debugSpriteLabel = "F1"
                elseif walkFrame == 1 and warriorWalk2Front then
                    sprite = warriorWalk2Front
                    debugSpriteLabel = "F2"
                elseif walkFrame == 2 and warriorWalk3Front then
                    sprite = warriorWalk3Front
                    debugSpriteLabel = "F3"
                else
                    sprite = warriorFront
                    debugSpriteLabel = "F0"
                end
            elseif isMoving then
                local frameCount = DEBUG_FORCE_WALK_FRAMES or ((warriorWalk3Front and 3) or 2)
                local walkFrame = math.floor(animTick / 7) % frameCount
                debugWalkFrame = walkFrame
                if walkFrame == 0 and warriorWalk1Front then
                    sprite = warriorWalk1Front
                    debugSpriteLabel = "F1"
                elseif walkFrame == 1 and warriorWalk2Front then
                    sprite = warriorWalk2Front
                    debugSpriteLabel = "F2"
                elseif walkFrame == 2 and warriorWalk3Front then
                    sprite = warriorWalk3Front
                    debugSpriteLabel = "F3"
                else
                    sprite = warriorFront  -- Fallback
                    debugSpriteLabel = "F0"
                end
            else
                sprite = warriorFront
                debugSpriteLabel = "F0"
            end
        elseif view == 2 then
            -- Back view
            if DEBUG_CYCLE_VIEW then
                local frameCount = DEBUG_FORCE_WALK_FRAMES or ((warriorWalk3Back and 3) or 2)
                local walkFrame = math.floor(animTick / 7) % frameCount
                debugWalkFrame = walkFrame
                if walkFrame == 0 and warriorWalk1Back then
                    sprite = warriorWalk1Back
                    debugSpriteLabel = "B1"
                elseif walkFrame == 1 and warriorWalk2Back then
                    sprite = warriorWalk2Back
                    debugSpriteLabel = "B2"
                elseif walkFrame == 2 and warriorWalk3Back then
                    sprite = warriorWalk3Back
                    debugSpriteLabel = "B3"
                else
                    sprite = warriorBack
                    debugSpriteLabel = "B0"
                end
            elseif isMoving then
                local frameCount = DEBUG_FORCE_WALK_FRAMES or ((warriorWalk3Back and 3) or 2)
                local walkFrame = math.floor(animTick / 7) % frameCount
                debugWalkFrame = walkFrame
                if walkFrame == 0 and warriorWalk1Back then
                    sprite = warriorWalk1Back
                    debugSpriteLabel = "B1"
                elseif walkFrame == 1 and warriorWalk2Back then
                    sprite = warriorWalk2Back
                    debugSpriteLabel = "B2"
                elseif walkFrame == 2 and warriorWalk3Back then
                    sprite = warriorWalk3Back
                    debugSpriteLabel = "B3"
                else
                    sprite = warriorBack  -- Fallback
                    debugSpriteLabel = "B0"
                end
            else
                sprite = warriorBack
                debugSpriteLabel = "B0"
            end
        elseif view == 3 then
            -- Left side view - show LEFT-facing sprites
            if isMoving then
                local frameCount = DEBUG_FORCE_WALK_FRAMES or ((warriorWalk3 and 3) or 2)
                local walkFrame = math.floor(animTick / 7) % frameCount
                debugWalkFrame = walkFrame
                if walkFrame == 0 and warriorWalk1 then
                    sprite = warriorWalk1
                    debugSpriteLabel = "L1"
                elseif walkFrame == 1 and warriorWalk2 then
                    sprite = warriorWalk2
                    debugSpriteLabel = "L2"
                elseif walkFrame == 2 and warriorWalk3 then
                    sprite = warriorWalk3
                    debugSpriteLabel = "L3"
                else
                    sprite = warriorLeft  -- Fallback
                    debugSpriteLabel = "L0"
                end
            else
                sprite = warriorLeft
                debugSpriteLabel = "L0"
            end
        else
            -- Right side view (view == 1) - show RIGHT-facing sprites
            if isMoving then
                local frameCount = DEBUG_FORCE_WALK_FRAMES or ((warriorWalk3R and 3) or 2)
                local walkFrame = math.floor(animTick / 7) % frameCount
                debugWalkFrame = walkFrame
                if walkFrame == 0 and warriorWalk1R then
                    sprite = warriorWalk1R
                    debugSpriteLabel = "R1"
                elseif walkFrame == 1 and warriorWalk2R then
                    sprite = warriorWalk2R
                    debugSpriteLabel = "R2"
                elseif walkFrame == 2 and warriorWalk3R then
                    sprite = warriorWalk3R
                    debugSpriteLabel = "R3"
                else
                    sprite = warriorRight  -- Fallback
                    debugSpriteLabel = "R0"
                end
            else
                sprite = warriorRight
                debugSpriteLabel = "R0"
            end
        end

        -- Draw sprite scaled based on distance
        if sprite and sprite.height then
            -- Calculate scale to fit desired height on screen
            local desiredHeight = size  -- size is based on distance
            local scale = safeDivide(desiredHeight, sprite.height, "renderScale")

            -- Calculate draw position (centered horizontally)
            local scaledWidth = sprite.width * scale
            local scaledHeight = sprite.height * scale
            local drawX = screenX - math.floor(scaledWidth / 2)

            -- Position sprite with feet on ground level
            -- Ground level = HORIZON + size (matches wall bottoms)
            local groundY = HORIZON + size
            if groundY > 240 then groundY = 240 end
            local drawY = groundY - math.floor(scaledHeight)

            if DEBUG_WALK_OFFSET and debugWalkFrame ~= nil then
                if debugWalkFrame == 1 then
                    drawX = drawX + 6
                    drawY = drawY + 3
                end
            end

            vmupro.sprite.drawScaled(sprite, drawX, drawY, scale, scale, flipFlag)

            if DEBUG_SHOW_WALK_INFO then
                local info = "V:" .. tostring(view) .. " WF:" .. tostring(debugWalkFrame or -1) .. " S:" .. debugSpriteLabel
                setFontCached(vmupro.text.FONT_TINY_6x8)
                drawUiText(info, 5, 220, COLOR_WHITE, COLOR_BLACK)
            end

            -- Draw health bar above soldier if alive and has hp data
            if spriteData and spriteData.hp and spriteData.alive then
                local barWidth = math.floor(scaledWidth * 0.8)
                local barHeight = math.max(3, math.floor(4 / dist * 2))
                local barX = drawX + math.floor((scaledWidth - barWidth) / 2)
                local barY = drawY - barHeight - 2

                -- Background (dark red)
                vmupro.graphics.drawFillRect(barX, barY, barX + barWidth, barY + barHeight, COLOR_MAROON)

                -- Health portion (bright red)
                local healthWidth = math.floor(barWidth * (spriteData.hp / ENEMY_MAX_HP))
                if healthWidth > 0 then
                    vmupro.graphics.drawFillRect(barX, barY, barX + healthWidth, barY + barHeight, COLOR_RED)
                end
            end
        end

    elseif stype == 6 then
        -- Knight Guard using real sprites
        -- Determine view: 0=front, 1=right, 2=back, 3=left
        local view = 0
        if viewAngle then
            if viewAngle >= -8 and viewAngle <= 8 then view = 0
            elseif viewAngle > 8 and viewAngle < 24 then view = 3
            elseif viewAngle >= 24 or viewAngle <= -24 then view = 2
            else view = 1 end
        end

        -- Select appropriate sprite based on view
        local sprite = knightFront
        local flipFlag = vmupro.sprite.kImageUnflipped
        if view == 0 then
            sprite = knightFront
        elseif view == 2 then
            sprite = knightBack
        elseif view == 3 then
            sprite = knightLeft
        else
            sprite = knightRight
        end

        -- Draw sprite scaled based on distance
        if sprite and sprite.height then
            -- Calculate scale to fit desired height on screen
            local desiredHeight = size  -- size is based on distance
            local scale = safeDivide(desiredHeight, sprite.height, "renderScale")

            -- Calculate draw position (centered horizontally)
            local scaledWidth = sprite.width * scale
            local scaledHeight = sprite.height * scale
            local drawX = screenX - math.floor(scaledWidth / 2)

            -- Position sprite with feet on ground level
            local groundY = HORIZON + size
            if groundY > 240 then groundY = 240 end
            local drawY = groundY - math.floor(scaledHeight)

            vmupro.sprite.drawScaled(sprite, drawX, drawY, scale, scale, flipFlag)
        end

    elseif stype == 7 then
        -- Health vial pickup (uses potion sprite)
        if spriteData and spriteData.collected then
            return  -- Don't draw collected vials
        end

        if potionSprite and potionSprite.height then
            -- Scale potion to fit on ground
            local desiredHeight = size * 0.6  -- Smaller than characters
            local scale = desiredHeight / potionSprite.height

            local scaledWidth = potionSprite.width * scale
            local scaledHeight = potionSprite.height * scale
            local drawX = screenX - math.floor(scaledWidth / 2)

            -- Position on ground
            local groundY = HORIZON + size
            if groundY > 240 then groundY = 240 end
            local drawY = groundY - math.floor(scaledHeight)

            vmupro.sprite.drawScaled(potionSprite, drawX, drawY, scale, scale, vmupro.sprite.kImageUnflipped)
        end
    end
end

local function drawRoofBackdrop()
    local roofBottom = HORIZON - 1
    if roofBottom < 0 then
        return
    end

    -- Single-image ceiling over the full map roof.
    -- Map anchors are computed in camera space so this behaves like a world roof,
    -- not a static screen overlay.
    local roofTex = nil
    if not DEBUG_DISABLE_WALL_TEXTURE and not DEBUG_DISABLE_ROOF_TEXTURE then
        roofTex = wallRoof or wallBrick
    end
    if roofTex and validateSprite(roofTex, "drawRoofBackdrop") then
        local texW = roofTex.width or 128
        local texH = roofTex.height or 128
        if texW < 1 then texW = 1 end
        if texH < 1 then texH = 1 end

        local mapW = 16
        local mapH = 16
        if map and #map > 0 then
            mapH = #map
            if map[1] and #map[1] > 0 then
                mapW = #map[1]
            end
        end
        if mapW < 1 then mapW = 16 end
        if mapH < 1 then mapH = 16 end

        -- Stretch one image across full map space (large stretch by design).
        local stretchPxPerTileX = 32
        local stretchPxPerTileY = 24
        local targetW = 240 + (mapW * stretchPxPerTileX)
        local targetH = (roofBottom + 1) + (mapH * stretchPxPerTileY)
        local panRangeX = targetW - 240
        local panRangeY = targetH - (roofBottom + 1)
        if panRangeX < 0 then panRangeX = 0 end
        if panRangeY < 0 then panRangeY = 0 end

        local ang = ((pdir or 0) % 64) * (renderCfg.twoPi / 64)
        local ca = math.cos(ang)
        local sa = math.sin(ang)

        -- Camera-space axes:
        -- forward = dot(world, viewDir), lateral = dot(world, rightDir)
        local function projectForward(x, y)
            return (x * ca) + (y * sa)
        end
        local function projectLateral(x, y)
            return (-x * sa) + (y * ca)
        end

        local c1x, c1y = 0, 0
        local c2x, c2y = mapW, 0
        local c3x, c3y = 0, mapH
        local c4x, c4y = mapW, mapH
        local f1, f2 = projectForward(c1x, c1y), projectForward(c2x, c2y)
        local f3, f4 = projectForward(c3x, c3y), projectForward(c4x, c4y)
        local l1, l2 = projectLateral(c1x, c1y), projectLateral(c2x, c2y)
        local l3, l4 = projectLateral(c3x, c3y), projectLateral(c4x, c4y)

        local minFwd = math.min(f1, f2, f3, f4)
        local maxFwd = math.max(f1, f2, f3, f4)
        local minLat = math.min(l1, l2, l3, l4)
        local maxLat = math.max(l1, l2, l3, l4)

        local curFwd = projectForward((px or 0), (py or 0))
        local curLat = projectLateral((px or 0), (py or 0))
        local fwdSpan = maxFwd - minFwd
        local latSpan = maxLat - minLat
        if fwdSpan < 0.001 then fwdSpan = 0.001 end
        if latSpan < 0.001 then latSpan = 0.001 end

        local nx = safeDivide((curLat - minLat), latSpan, "drawRoofBackdrop_nx")
        local ny = safeDivide((curFwd - minFwd), fwdSpan, "drawRoofBackdrop_ny")
        if nx < 0 then nx = 0 elseif nx > 1 then nx = 1 end
        if ny < 0 then ny = 0 elseif ny > 1 then ny = 1 end

        local drawX = -math.floor((nx * panRangeX) + 0.5)
        local drawY = -math.floor((ny * panRangeY) + 0.5)

        local scaleX = safeDivide(targetW, texW, "drawRoofBackdrop_scaleX")
        local scaleY = safeDivide(targetH, texH, "drawRoofBackdrop_scaleY")
        if safeScale(roofTex, scaleX, scaleY, "drawRoofBackdrop") then
            vmupro.sprite.drawScaled(roofTex, drawX, drawY, scaleX, scaleY, vmupro.sprite.kImageUnflipped)
        else
            vmupro.graphics.drawFillRect(0, 0, 239, roofBottom, COLOR_DARK_GRAY)
        end
    else
        vmupro.graphics.drawFillRect(0, 0, 239, roofBottom, COLOR_DARK_GRAY)
    end

    -- Keep a strong horizon seam for depth readability against fog.
    vmupro.graphics.drawLine(0, roofBottom, 239, roofBottom, COLOR_BLACK)
end

local function renderGameFrame()
    recoverPlayerFromWallPenetration()
    -- Keep world rendering live while menu is open for real-time tuning.
    local freezeMenuView = false
    if not freezeMenuView then
        -- Game rendering
        vmupro.graphics.clear(COLOR_CEILING)
        drawRoofBackdrop()
        -- Draw floor after roof so any sprite-scale bleed never reaches the floor.
        vmupro.graphics.drawFillRect(0, HORIZON, 240, VIEWPORT_H, COLOR_FLOOR)
        vmupro.graphics.drawFillRect(0, VIEWPORT_H, 240, 240, COLOR_BLACK)


        -- Single renderer runtime path: EXP-H only.
        lockRendererMode()
        renderWallsExperimentalHybrid()

    if not DEBUG_SKIP_SPRITES and not showMenu then
        if frameCount - spriteOrderCacheFrame >= 8 or #spriteOrderCache == 0 then
            local spriteOrder = {}
            local count = 0
            for i = 1, #sprites do
                local s = sprites[i]
                if not s then
                    goto continue_sprite_build
                end
                local skip = (DEBUG_DISABLE_ENEMIES and isEnemyType(s.t))
                    or (DEBUG_DISABLE_PROPS and isPropType(s.t))
                if not skip then
                    local sdx, sdy = s.x - px, s.y - py
                    local distSq = sdx * sdx + sdy * sdy
                    local maxSq = SPRITE_MAX_DIST_SQ
                    if isEnemyType(s.t) then
                        maxSq = ENEMY_RENDER_DIST_SQ
                    elseif s.t == 7 then
                        maxSq = ITEM_RENDER_DIST_SQ
                    elseif isPropType(s.t) then
                        maxSq = PROP_RENDER_DIST_SQ
                    end
                    if distSq <= maxSq then
                        count = count + 1
                        spriteOrder[count] = {idx = i, dist = distSq}
                    end
                end
                ::continue_sprite_build::
            end
            if count > 1 then
                table.sort(spriteOrder, function(a, b) return a.dist > b.dist end)
            end
            spriteOrderCache = spriteOrder
            spriteOrderCacheFrame = frameCount
        end

        for i = 1, #spriteOrderCache do
            local s = sprites[spriteOrderCache[i].idx]
            if not s then
                goto continue_sprite
            end
            if DEBUG_DISABLE_ENEMIES and isEnemyType(s.t) then
                goto continue_sprite
            end
            if DEBUG_DISABLE_PROPS and isPropType(s.t) then
                goto continue_sprite
            end
            -- Skip dead soldiers
            if s.t == 5 and s.alive == false and not s.dying then
                goto continue_sprite
            end
            local sdx, sdy = s.x - px, s.y - py
            local distSq = sdx * sdx + sdy * sdy
            local maxSq = SPRITE_MAX_DIST_SQ
            if isEnemyType(s.t) then
                maxSq = ENEMY_RENDER_DIST_SQ
            elseif s.t == 7 then
                maxSq = ITEM_RENDER_DIST_SQ
            elseif isPropType(s.t) then
                maxSq = PROP_RENDER_DIST_SQ
            end
            if distSq <= maxSq then
                local sdist = math.sqrt(distSq)
                local visible = true
                if sdist > SPRITE_VIS_DIST then
                    visible = false
                else
                    visible = isVisible(s.x, s.y, s)
                end
                if sdist > 0.3 and visible then
                local sAngle = 0
                if sdx ~= 0 then
                    sAngle = math.atan(sdy / sdx)
                    if sdx < 0 then sAngle = sAngle + 3.14159 end
                else
                    sAngle = sdy > 0 and 1.5708 or -1.5708
                end
                local sDir = math.floor(sAngle * 64 / 6.28318) % 64
                local viewDiff = (sDir - pdir) % 64
                if viewDiff > 32 then viewDiff = viewDiff - 64 end
                if viewDiff >= -6 and viewDiff <= 6 then
                    if isExpRenderer() then
                        local dir = pdir % 64
                        local cosDir = cosTable[dir]
                        local sinDir = sinTable[dir]
                        local relX = (sdx * sinDir - sdy * cosDir)
                        local relY = (sdx * cosDir + sdy * sinDir)
                        if relY > 0.05 then
                            local sx = relX / relY
                            local screenX = math.floor(120 + sx * 120)
                            local occluded = false
                            for ox = -2, 2 do
                                local cx = screenX + ox
                                if cx >= 0 and cx <= 239 then
                                    local wallDist = expDepthBuf[cx]
                                    if wallDist and relY > wallDist then
                                        occluded = true
                                        break
                                    end
                                end
                            end
                            if occluded then
                                goto continue_sprite
                            end
                        end
                    end
                    -- Calculate view angle for guards (angle from guard's POV)
                    local guardViewAngle = nil
                    if (s.t == 5 or s.t == 6) and s.dir then
                        -- Angle player is approaching from relative to guard's facing
                        local approachDir = (sDir + 32) % 64  -- Opposite of sDir
                        guardViewAngle = (approachDir - s.dir) % 64
                        if guardViewAngle > 32 then guardViewAngle = guardViewAngle - 64 end
                    end
                    drawSprite(120 + viewDiff * 20, sdist, s.t, guardViewAngle, s.anim, s)
                end
                end
            end
            ::continue_sprite::
            end
        end

        if SHOW_MINIMAP and not showMenu then
        for my = 0, 15 do
            for mx = 0, 15 do
                if map[my + 1][mx + 1] > 0 then
                    vmupro.graphics.drawFillRect(5 + mx * 4, 5 + my * 4, 8 + mx * 4, 8 + my * 4, COLOR_STONE_D)
                end
            end
        end
        local ppx = 5 + math.floor(px * 4)
        local ppy = 5 + math.floor(py * 4)
        vmupro.graphics.drawFillRect(ppx - 1, ppy - 1, ppx + 1, ppy + 1, COLOR_RED)
        vmupro.graphics.drawLine(ppx, ppy, ppx + math.floor(cosTable[pdir % 64] * 4), ppy + math.floor(sinTable[pdir % 64] * 4), COLOR_YELLOW)
        end

        -- Draw attack sword swing (always, even if effects are disabled)
        if isAttacking > 0 and not showMenu then
        if #swordAttack > 0 then
            local total = (attackTotalFrames > 0) and attackTotalFrames or (#swordAttack * 2)
            local frameHold = math.max(1, math.floor(total / #swordAttack))
            local frameIndex = math.floor((total - isAttacking) / frameHold) + 1
            if frameIndex < 1 then frameIndex = 1 end
            if frameIndex > #swordAttack then frameIndex = #swordAttack end
            local sprite = swordAttack[frameIndex]
            if sprite then
                local drawX = 140
                local drawY = 240 - sprite.height + 30
                vmupro.sprite.draw(sprite, drawX, drawY, vmupro.sprite.kImageUnflipped)
            end
        else
            local swingAngle = (10 - isAttacking) * 9  -- 0 to 90 degrees
            local swordLen = 80
            local swordX = 180 + math.floor(math.sin(swingAngle * 0.0174) * 40)
            local swordY = 180 - math.floor(math.cos(swingAngle * 0.0174) * 60)
            -- Sword blade
            vmupro.graphics.drawFillRect(swordX - 4, swordY - swordLen, swordX + 4, swordY, COLOR_LIGHT_GRAY)
            vmupro.graphics.drawFillRect(swordX - 2, swordY - swordLen - 10, swordX + 2, swordY - swordLen, COLOR_LIGHT_GRAY)
            -- Sword hilt
            vmupro.graphics.drawFillRect(swordX - 12, swordY - 4, swordX + 12, swordY + 4, COLOR_BROWN)
            vmupro.graphics.drawFillRect(swordX - 6, swordY, swordX + 6, swordY + 20, COLOR_DARK_BROWN)
        end
        end

        -- Draw block shield (animated raise)
        if blockAnim > 0 and not showMenu then
        local frameIndex = blockAnim
        if frameIndex < 1 then frameIndex = 1 end
        if frameIndex > #shieldRaise then frameIndex = #shieldRaise end
        local sprite = shieldRaise[frameIndex]
        if sprite then
            vmupro.sprite.draw(sprite, 0, 0, vmupro.sprite.kImageUnflipped)
        end
    end
    end

    -- Draw menu
    if showMenu then
        if inOptionsMenu then
            -- Options submenu
            drawUiPanel(40, 30, 200, 230, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
            drawUiPanel(45, 35, 195, 225, COLOR_DARK_GRAY, COLOR_GRAY)
            -- Title bar
            drawUiPanel(50, 40, 190, 60, COLOR_MAROON, COLOR_WHITE)
            setFontCached(vmupro.text.FONT_SMALL)
            if inGameDebugMenu then
                drawMenuText("DEBUG", 92, 44, COLOR_WHITE)
                local items = buildDebugMenuItems()
                local visibleCount = 10
                local sel = titleDebugSelection
                local startIndex = 1
                if #items > visibleCount then
                    local half = math.floor(visibleCount / 2)
                    startIndex = sel - half
                    if startIndex < 1 then startIndex = 1 end
                    local maxStart = #items - visibleCount + 1
                    if startIndex > maxStart then startIndex = maxStart end
                end
                local endIndex = math.min(#items, startIndex + visibleCount - 1)
                local drawRow = 0
                for i = startIndex, endIndex do
                    local item = items[i]
                    local y = 74 + drawRow * 16
                    local textColor = COLOR_LIGHT_GRAY
                    local label = "  " .. item
                    if i == sel then
                        textColor = COLOR_WHITE
                        label = "> " .. item
                    end
                    setFontCached(vmupro.text.FONT_TINY_6x8)
                    drawMenuText(label, 54, y + 2, textColor)
                    drawRow = drawRow + 1
                end
                setFontCached(vmupro.text.FONT_TINY_6x8)
                drawMenuText("L/R ADJUST", 54, 222, COLOR_WHITE)
            else
                drawMenuText("OPTIONS", 86, 44, COLOR_WHITE)
                -- Options items
                local soundText = "SOUND: " .. (soundEnabled and "ON" or "OFF")
                local healthText = "HEALTH%: " .. (showHealthPercent and "ON" or "OFF")
                local enemiesText = "ENEMIES: " .. (DEBUG_DISABLE_ENEMIES and "OFF" or "ON")
                local propsText = "PROPS: " .. (DEBUG_DISABLE_PROPS and "OFF" or "ON")
                local texturesText = "TEXTURES: " .. (DEBUG_DISABLE_WALL_TEXTURE and "OFF" or "ON")
                local fpsText = "FPS: " .. (showFpsOverlay and "ON" or "OFF")
                local resText = "RES: " .. (LOW_RES_MODE == "fast" and "FAST" or "QUALITY")
                local minimapText = "MINIMAP: " .. (SHOW_MINIMAP and "ON" or "OFF")
                local renderText = "RENDER: EXP-H LOCK"
                local debugText = "DEBUG"
                local optItems = {soundText, healthText, enemiesText, propsText, texturesText, fpsText, resText, minimapText, renderText, debugText, "BACK"}
                for i, item in ipairs(optItems) do
                    local y = 70 + (i - 1) * 15
                    local textColor = COLOR_LIGHT_GRAY
                    local label = "  " .. item
                    if i == optionsSelection then
                        textColor = COLOR_WHITE
                        label = "> " .. item
                    end
                    setFontCached(vmupro.text.FONT_SMALL)
                    drawMenuText(label, 54, y + 1, textColor)
                end
            end
        else
            -- Main pause menu
            drawUiPanel(50, 60, 190, 225, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
            drawUiPanel(55, 65, 185, 220, COLOR_DARK_GRAY, COLOR_GRAY)
            -- Title bar
            drawUiPanel(60, 70, 180, 92, COLOR_MAROON, COLOR_WHITE)
            setFontCached(vmupro.text.FONT_SMALL)
            drawMenuText("PAUSED", 88, 75, COLOR_WHITE)
            -- Menu items
            local items = {"RESUME", "OPTIONS", "RESTART", "MENU", "QUIT"}
            for i, item in ipairs(items) do
                local y = 95 + (i - 1) * 20
                local textColor = COLOR_LIGHT_GRAY
                local label = "  " .. item
                if i == menuSelection then
                    textColor = COLOR_WHITE
                    label = "> " .. item
                end
                setFontCached(vmupro.text.FONT_SMALL)
                drawMenuText(label, 78, y + 2, textColor)
            end
        end
    end

    -- Draw health UI (potion with liquid)
    drawHealthUI()
    if not showMenu then
        drawEnemiesRemainingUI()
    end

    -- Draw current level indicator
                setFontCached(vmupro.text.FONT_SMALL)
                drawUiText(getLevelLabel(currentLevel), 6, 228, COLOR_WHITE, COLOR_BLACK)
                if showFpsOverlay and lastFps and lastFps > 0 then
                    local fpsText = string.format("FPS %.1f", lastFps)
                    drawUiText(fpsText, 6, 214, COLOR_WHITE, COLOR_BLACK)
                end
                if DEBUG_PERF_MONITOR then
                    drawPerfMonitorOverlay()
                end
                if DEBUG_SHOW_BLOCK and lastBlockEvent and (frameCount - lastBlockEvent.frame) < 60 then
                    local pct = math.floor((lastBlockEvent.pct or 0) * 100 + 0.5)
                    local msg = "BLOCK " .. tostring(pct) .. "% (-" .. tostring(lastBlockEvent.amount or 0) .. ")"
                    drawUiText(msg, 6, 202, COLOR_WHITE, COLOR_BLACK)
                end

    if levelBannerTimer > 0 then
                    local bannerText = "LEVEL " .. getLevelLabel(currentLevel)
        local textColor = COLOR_WHITE
        if levelBannerTimer < 50 then
            textColor = COLOR_DARK_GRAY
        elseif levelBannerTimer < 100 then
            textColor = COLOR_LIGHT_GRAY
        end
        setFontCached(vmupro.text.FONT_SMALL)
        drawUiText(bannerText, 170, 5, textColor, COLOR_BLACK)
    end

    -- Draw game over screen if player died
    if gameState == STATE_GAME_OVER then
        drawGameOver()
    end

    -- Draw win screen if player won
    if gameState == STATE_WIN then
        drawWinScreen()
    end
end

local function consumeAudioSteps(elapsedUs, audioAccumulatorUs)
    if not audioSystemActive or not soundEnabled then
        return 0.0, 0
    end

    local dt = elapsedUs or AUDIO_UPDATE_STEP_US
    if dt < 0 then
        dt = AUDIO_UPDATE_STEP_US
    end
    if dt > 250000 then
        dt = 250000
    end

    local acc = (audioAccumulatorUs or 0) + dt
    local maxBacklog = AUDIO_UPDATE_STEP_US * (AUDIO_UPDATE_MAX_BACKLOG_STEPS or 3)
    if acc > maxBacklog then
        acc = maxBacklog
    end

    local steps = 0
    while acc >= AUDIO_UPDATE_STEP_US and steps < (AUDIO_UPDATE_MAX_STEPS or 3) do
        vmupro.sound.update()
        acc = acc - AUDIO_UPDATE_STEP_US
        steps = steps + 1
    end

    return acc, steps
end

local function runSimulationStep()
    simTickCount = simTickCount + 1

    if gameState == STATE_PLAYING and not showMenu then
        if levelBannerTimer > 0 then
            levelBannerTimer = levelBannerTimer - 1
        end
        if isAttacking > 0 then
            isAttacking = isAttacking - 1
        end
        updateSoldiers()
        updateDeathAnimations()
        if not DEBUG_DISABLE_EFFECTS then
            updateBloodEffects()
        end
        checkHealthPickups()
    elseif gameState == STATE_LOADING then
        loadingTimer = loadingTimer - 1
        if loadingTimer <= 0 then
            if pendingLevelStart then
                startLevel(pendingLevelStart)
                pendingLevelStart = nil
            else
                gameState = STATE_TITLE
            end
        end
    elseif gameState == STATE_WIN then
        if winBannerTimer > 0 then
            winBannerTimer = winBannerTimer - 1
        end
        if winCooldown > 0 then
            winCooldown = winCooldown - 1
        end
    end
end

local function consumeSimulationSteps(elapsedUs, simAccumulatorUs)
    if gameState ~= STATE_PLAYING and gameState ~= STATE_LOADING and gameState ~= STATE_WIN then
        return 0.0, 0
    end

    local dt = elapsedUs or SIM_STEP_US
    if dt < 0 then
        dt = SIM_STEP_US
    end
    if dt > 250000 then
        dt = 250000
    end

    local acc = (simAccumulatorUs or 0) + dt
    local maxBacklog = SIM_STEP_US * (SIM_MAX_BACKLOG_STEPS or 4)
    if acc > maxBacklog then
        acc = maxBacklog
    end

    local steps = 0
    while acc >= SIM_STEP_US and steps < (SIM_MAX_STEPS_PER_FRAME or 4) do
        runSimulationStep()
        acc = acc - SIM_STEP_US
        steps = steps + 1
        if gameState == STATE_TITLE then
            acc = 0.0
            break
        end
    end

    return acc, steps
end


function AppMain()
    applyRuntimeLogLevel()
    logBoot(vmupro.system.LOG_ERROR, "A AppMain enter")
    logBoot(vmupro.system.LOG_ERROR, "drawTitleScreen local=" .. tostring(drawTitleScreen))
    logBoot(vmupro.system.LOG_ERROR, "drawTitleScreen global=" .. tostring(_G and _G.drawTitleScreen))
    if drawTitleScreenImpl then
        drawTitleScreen = drawTitleScreenImpl
        logBoot(vmupro.system.LOG_ERROR, "drawTitleScreen rebound in AppMain")
    end
    enterTitle()
    logBoot(vmupro.system.LOG_ERROR, "B enterTitle done")
    syncDoubleBufferForState()
    local bootLoopLogged = false
    local bootLogEvery = 300
    local fpsWindowStartUs = (vmupro.system and vmupro.system.getTimeUs and vmupro.system.getTimeUs()) or 0
    local fpsFrames = 0
    local lastLoopUs = fpsWindowStartUs
    local simAccumulatorUs = 0.0
    local audioAccumulatorUs = 0.0
    local simStepsThisFrame = 0
    local audioStepsThisFrame = 0

    local targetFrameUs = 33333
    while app_running do
        local frameStartUs = (vmupro.system and vmupro.system.getTimeUs and vmupro.system.getTimeUs()) or 0
        local elapsedUs = SIM_STEP_US
        if lastLoopUs and lastLoopUs > 0 and frameStartUs > 0 then
            elapsedUs = frameStartUs - lastLoopUs
            if elapsedUs < 0 then
                elapsedUs = SIM_STEP_US
            end
        end
        if elapsedUs > 250000 then
            elapsedUs = 250000
        end
        lastLoopUs = frameStartUs
        if not bootLoopLogged then
            bootLoopLogged = true
            logBoot(vmupro.system.LOG_ERROR, "B1 loop start")
        end
        local inputSampleStartUs = nil
        if DEBUG_PERF_MONITOR and vmupro and vmupro.system and vmupro.system.getTimeUs then
            local sampleEvery = PERF_MONITOR_SAMPLE_EVERY or 12
            if sampleEvery < 1 then sampleEvery = 1 end
            if ((frameCount + 1) % sampleEvery) == 0 then
                inputSampleStartUs = vmupro.system.getTimeUs()
            end
        end
        vmupro.input.read()
        lockRendererMode()
        if enableBootLogs and gameState == STATE_TITLE and bootLoopLogged and (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2 after input.read")
        end
        frameCount = frameCount + 1
        perfMonitorBeginFrame()
        local perfSectionClock = nil
        if PERF_MONITOR_ACTIVE_SAMPLE then
            perfSectionClock = perfNowUs
        end
        if inputSampleStartUs and perfSectionClock then
            local inputSampleEndUs = perfSectionClock()
            if inputSampleEndUs and inputSampleEndUs >= inputSampleStartUs then
                PERF_MONITOR_SAMPLE_INPUT_US = inputSampleEndUs - inputSampleStartUs
            end
        end
        if enableBootLogs and gameState == STATE_TITLE and (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2.1 after frameCount")
        end
        fpsFrames = fpsFrames + 1
        if enableBootLogs and gameState == STATE_PLAYING and (frameCount % 120) == 0 then
            logBoot(vmupro.system.LOG_ERROR, string.format("LIFE state=%d px=%.2f py=%.2f", gameState, px or -1, py or -1))
        end
        if vmupro.system and vmupro.system.getTimeUs then
            local nowUs = vmupro.system.getTimeUs()
            if fpsWindowStartUs == 0 then
                fpsWindowStartUs = nowUs
                fpsFrames = 0
            elseif (nowUs - fpsWindowStartUs) >= 1000000 then
                local elapsed = nowUs - fpsWindowStartUs
                local fps = (fpsFrames * 1000000) / elapsed
                lastFps = fps
                if enablePerfLogs then
                    logPerf(string.format("FPS %.1f", fps))
                end
                fpsWindowStartUs = nowUs
                fpsFrames = 0
            end
        end

        local audioSectionStartUs = perfSectionClock and perfSectionClock()
        audioAccumulatorUs, audioStepsThisFrame = consumeAudioSteps(elapsedUs, audioAccumulatorUs)
        if audioSectionStartUs and perfSectionClock then
            local audioSectionEndUs = perfSectionClock()
            if audioSectionEndUs and audioSectionEndUs >= audioSectionStartUs then
                PERF_MONITOR_SAMPLE_AUDIO_US = PERF_MONITOR_SAMPLE_AUDIO_US + (audioSectionEndUs - audioSectionStartUs)
            end
        end
        if enableBootLogs and gameState == STATE_TITLE and (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2.2 after audio update steps=" .. tostring(audioStepsThisFrame))
        end

        local simSectionStartUs = perfSectionClock and perfSectionClock()
        if gameState == STATE_TITLE then
            updateTitleMusic()
            simAccumulatorUs = 0.0
            simStepsThisFrame = 0
        else
            simAccumulatorUs, simStepsThisFrame = consumeSimulationSteps(elapsedUs, simAccumulatorUs)
        end
        if simSectionStartUs and perfSectionClock then
            local simSectionEndUs = perfSectionClock()
            if simSectionEndUs and simSectionEndUs >= simSectionStartUs then
                PERF_MONITOR_SAMPLE_SIM_US = PERF_MONITOR_SAMPLE_SIM_US + (simSectionEndUs - simSectionStartUs)
            end
        end

        if enableBootLogs and gameState == STATE_TITLE and (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2.3 after playing block")
        end

        if enableBootLogs and gameState == STATE_TITLE and (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2.4 after loading block")
        end

        if enableBootLogs and gameState == STATE_TITLE and (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2.5 before title/menu pcall")
        end
        local logicSectionStartUs = perfSectionClock and perfSectionClock()
        local okTitle, errTitle = pcall(function()
            if enableBootLogs and gameState == STATE_TITLE and (frameCount % bootLogEvery == 0) then
                logBoot(vmupro.system.LOG_ERROR, "B2.6 inside title/menu pcall")
            end
            -- Title screen handling
            if gameState == STATE_TITLE then
                local prevTitleSelection = titleSelection
                local prevTitleInOptions = titleInOptions
                local prevTitleOptionsSelection = titleOptionsSelection
                local prevTitleDebugSelection = titleDebugSelection
                local prevTitleDebugPage = titleDebugPage
                local prevSelectedLevel = selectedLevel
                local prevSoundEnabled = soundEnabled
                local prevShowHealthPercent = showHealthPercent
                local prevEnableBootLogs = enableBootLogs
                local prevDisableEnemies = DEBUG_DISABLE_ENEMIES
                local prevDisableTextures = DEBUG_DISABLE_WALL_TEXTURE
                local prevDisableProps = DEBUG_DISABLE_PROPS
                local prevShowFpsOverlay = showFpsOverlay
                local prevLowResMode = LOW_RES_MODE
                local prevShowMinimap = SHOW_MINIMAP
                local prevRendererMode = RENDERER_MODE
                local prevMipmapEnabled = WALL_MIPMAP_ENABLED
                local prevRayPreset = RAY_PRESET_INDEX
                local prevDrawDist = EXP_TEX_MAX_DIST
                local prevMip1 = WALL_MIPMAP_DIST1
                local prevMip2 = WALL_MIPMAP_DIST2
                local prevMip3 = WALL_MIPMAP_DIST3
                local prevMip4 = WALL_MIPMAP_DIST4
                local prevFogStart = FOG_START
                local prevFogEnd = FOG_END
                local prevFogCutoff = FOG_TEX_CUTOFF
                local prevFogColor = FOG_COLOR
                local prevFogDither = FOG_DITHER_SIZE
                local prevFarTexOff = FAR_TEX_OFF_DIST
                local prevMipLodEnabled = MIP_LOD_ENABLED
                local prevDisableRoofTexture = DEBUG_DISABLE_ROOF_TEXTURE
                local prevBlockDbg = DEBUG_SHOW_BLOCK
                local prevAudioMix = AUDIO_UPDATE_TARGET_HZ
                local prevUseFixedRaycast = USE_FIXED_RAYCAST
                local prevForceFloatRaycast = DEBUG_FORCE_FLOAT_RAYCAST
                local prevPerfMonitor = DEBUG_PERF_MONITOR
                local prevDoubleBuffer = DEBUG_DOUBLE_BUFFER
                local prevWall1Format = WALL1_FORMAT_INDEX
                local prevWallKey = WALL_FORCE_COLORKEY_OVERRIDE
                local prevWallProjection = WALL_PROJECTION_MODE
                if titleInOptions then
                    if titleInDebug then
                        local dbgCount = getDebugMenuItemCount()
                        if vmupro.input.pressed(vmupro.input.UP) then
                            titleDebugSelection = titleDebugSelection - 1
                            if titleDebugSelection < 1 then titleDebugSelection = dbgCount end
                        end
                        if vmupro.input.pressed(vmupro.input.DOWN) then
                            titleDebugSelection = titleDebugSelection + 1
                            if titleDebugSelection > dbgCount then titleDebugSelection = 1 end
                        end
                        local titleAdjustDelta = getDebugAdjustDelta()
                        if titleAdjustDelta ~= 0 then
                            adjustDebugMenuSelection(titleDebugSelection, titleAdjustDelta, false)
                        end
                        if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                            if applyDebugMenuSelection(titleDebugSelection) then
                                titleInDebug = false
                                titleNeedsRedraw = true
                            end
                        end
                        if vmupro.input.pressed(vmupro.input.B) or vmupro.input.pressed(vmupro.input.POWER) then
                            titleInDebug = false
                            titleNeedsRedraw = true
                        end
                    else
                        -- Title options submenu
                        if vmupro.input.pressed(vmupro.input.UP) then
                            titleOptionsSelection = titleOptionsSelection - 1
                            if titleOptionsSelection < 1 then titleOptionsSelection = 6 end
                        end
                        if vmupro.input.pressed(vmupro.input.DOWN) then
                            titleOptionsSelection = titleOptionsSelection + 1
                            if titleOptionsSelection > 6 then titleOptionsSelection = 1 end
                        end
                        if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                            if titleOptionsSelection == 1 then
                                selectedLevel = selectedLevel + 1
                                if selectedLevel > LEVEL_SELECT_COUNT then selectedLevel = 1 end
                            elseif titleOptionsSelection == 2 then
                                soundEnabled = not soundEnabled
                                if soundEnabled then
                                    startTitleMusic()
                                else
                                    stopGameplaySamples()
                                    stopTitleMusic()
                                end
                            elseif titleOptionsSelection == 3 then
                                showHealthPercent = not showHealthPercent
                            elseif titleOptionsSelection == 4 then
                                lockRendererMode()
                            elseif titleOptionsSelection == 5 then
                                titleInDebug = true
                                titleDebugSelection = 1
                                titleNeedsRedraw = true
                            elseif titleOptionsSelection == 6 then
                                titleInOptions = false  -- Back
                                titleNeedsRedraw = true
                            end
                        end
                        if vmupro.input.pressed(vmupro.input.B) or vmupro.input.pressed(vmupro.input.POWER) then
                            titleInOptions = false
                            titleNeedsRedraw = true
                        end
                    end
                else
                    -- Title main menu
                    if vmupro.input.pressed(vmupro.input.UP) then
                        titleSelection = titleSelection - 1
                        if titleSelection < 1 then titleSelection = 3 end
                    end
                    if vmupro.input.pressed(vmupro.input.DOWN) then
                        titleSelection = titleSelection + 1
                        if titleSelection > 3 then titleSelection = 1 end
                    end
                    if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                        if titleSelection == 1 then
                            -- Start game
                            local selectedEntry = LEVEL_SELECT_LIST[selectedLevel]
                            if selectedEntry then
                                beginLoadLevel(selectedEntry.id)
                            end
                        elseif titleSelection == 2 then
                            -- Options
                            titleInOptions = true
                            titleOptionsSelection = 1
                        elseif titleSelection == 3 then
                            -- Exit
                            quitApp("title exit")
                        end
                    end
                end
                if prevTitleSelection ~= titleSelection
                    or prevTitleInOptions ~= titleInOptions
                    or prevTitleOptionsSelection ~= titleOptionsSelection
                    or prevTitleDebugSelection ~= titleDebugSelection
                    or prevTitleDebugPage ~= titleDebugPage
                    or prevSelectedLevel ~= selectedLevel
                    or prevSoundEnabled ~= soundEnabled
                    or prevShowHealthPercent ~= showHealthPercent
                    or prevEnableBootLogs ~= enableBootLogs
                    or prevDisableEnemies ~= DEBUG_DISABLE_ENEMIES
                    or prevDisableTextures ~= DEBUG_DISABLE_WALL_TEXTURE
                    or prevDisableProps ~= DEBUG_DISABLE_PROPS
                    or prevShowFpsOverlay ~= showFpsOverlay
                    or prevLowResMode ~= LOW_RES_MODE
                    or prevShowMinimap ~= SHOW_MINIMAP
                    or prevRendererMode ~= RENDERER_MODE
                    or prevMipmapEnabled ~= WALL_MIPMAP_ENABLED
                    or prevRayPreset ~= RAY_PRESET_INDEX
                    or prevDrawDist ~= EXP_TEX_MAX_DIST
                    or prevMip1 ~= WALL_MIPMAP_DIST1
                    or prevMip2 ~= WALL_MIPMAP_DIST2
                    or prevMip3 ~= WALL_MIPMAP_DIST3
                    or prevMip4 ~= WALL_MIPMAP_DIST4
                    or prevFogStart ~= FOG_START
                    or prevFogEnd ~= FOG_END
                    or prevFogCutoff ~= FOG_TEX_CUTOFF
                    or prevFogColor ~= FOG_COLOR
                    or prevFogDither ~= FOG_DITHER_SIZE
                    or prevFarTexOff ~= FAR_TEX_OFF_DIST
                    or prevMipLodEnabled ~= MIP_LOD_ENABLED
                    or prevDisableRoofTexture ~= DEBUG_DISABLE_ROOF_TEXTURE
                    or prevBlockDbg ~= DEBUG_SHOW_BLOCK
                    or prevAudioMix ~= AUDIO_UPDATE_TARGET_HZ
                    or prevUseFixedRaycast ~= USE_FIXED_RAYCAST
                    or prevForceFloatRaycast ~= DEBUG_FORCE_FLOAT_RAYCAST
                    or prevPerfMonitor ~= DEBUG_PERF_MONITOR
                    or prevDoubleBuffer ~= DEBUG_DOUBLE_BUFFER
                    or prevWall1Format ~= WALL1_FORMAT_INDEX
                    or prevWallKey ~= WALL_FORCE_COLORKEY_OVERRIDE
                    or prevWallProjection ~= WALL_PROJECTION_MODE then
                    titleNeedsRedraw = true
                end
            -- Game over handling
            elseif gameState == STATE_GAME_OVER then
                if vmupro.input.pressed(vmupro.input.UP) then
                    gameOverSelection = gameOverSelection - 1
                    if gameOverSelection < 1 then gameOverSelection = 3 end
                end
                if vmupro.input.pressed(vmupro.input.DOWN) then
                    gameOverSelection = gameOverSelection + 1
                    if gameOverSelection > 3 then gameOverSelection = 1 end
                end
                if vmupro.input.pressed(vmupro.input.A) or vmupro.input.pressed(vmupro.input.MODE) then
                    if gameOverSelection == 1 then
                        beginLoadLevel(currentLevel)  -- Restart
                    elseif gameOverSelection == 2 then
                        -- Return to title menu
                        enterTitle()
                        gameOverSelection = 1
                    else
                        quitApp("pause quit")  -- Quit
                    end
                end
            -- Win screen handling
            elseif gameState == STATE_WIN then
                if winCooldown <= 0 and vmupro.input.pressed(vmupro.input.A) then
                    -- Advance to next level if available, otherwise return to title menu
                    if currentLevel < MAX_LEVEL then
                        beginLoadLevel(currentLevel + 1)
                    else
                        enterTitle()
                    end
                end
            -- Menu handling
            elseif showMenu then
                if inOptionsMenu then
                    -- Options submenu
                    if inGameDebugMenu then
                        local dbgCount = getDebugMenuItemCount()
                        if vmupro.input.pressed(vmupro.input.UP) then
                            titleDebugSelection = titleDebugSelection - 1
                            if titleDebugSelection < 1 then titleDebugSelection = dbgCount end
                        end
                        if vmupro.input.pressed(vmupro.input.DOWN) then
                            titleDebugSelection = titleDebugSelection + 1
                            if titleDebugSelection > dbgCount then titleDebugSelection = 1 end
                        end
                        local gameAdjustDelta = getDebugAdjustDelta()
                        if gameAdjustDelta ~= 0 then
                            adjustDebugMenuSelection(titleDebugSelection, gameAdjustDelta, false)
                        end
                        if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                            if applyDebugMenuSelection(titleDebugSelection) then
                                inGameDebugMenu = false
                                titleNeedsRedraw = true
                            end
                        end
                        if vmupro.input.pressed(vmupro.input.POWER) or vmupro.input.pressed(vmupro.input.B) then
                            inGameDebugMenu = false
                            titleNeedsRedraw = true
                        end
                    else
                        if vmupro.input.pressed(vmupro.input.UP) then
                            optionsSelection = optionsSelection - 1
                            if optionsSelection < 1 then optionsSelection = 11 end
                        end
                        if vmupro.input.pressed(vmupro.input.DOWN) then
                            optionsSelection = optionsSelection + 1
                            if optionsSelection > 11 then optionsSelection = 1 end
                        end
                        if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                            if optionsSelection == 1 then
                                soundEnabled = not soundEnabled  -- Toggle sound
                                if not soundEnabled then
                                    stopGameplaySamples()
                                    stopTitleMusic()
                                end
                            elseif optionsSelection == 2 then
                                showHealthPercent = not showHealthPercent  -- Toggle health %
                            elseif optionsSelection == 3 then
                                DEBUG_DISABLE_ENEMIES = not DEBUG_DISABLE_ENEMIES
                                spriteOrderCache = {}
                                spriteOrderCacheFrame = -999
                            elseif optionsSelection == 4 then
                                DEBUG_DISABLE_PROPS = not DEBUG_DISABLE_PROPS
                                spriteOrderCache = {}
                                spriteOrderCacheFrame = -999
                            elseif optionsSelection == 5 then
                                DEBUG_DISABLE_WALL_TEXTURE = not DEBUG_DISABLE_WALL_TEXTURE
                                if DEBUG_DISABLE_WALL_TEXTURE then
                                    unloadWallTextures()
                                else
                                    loadWallTextures()
                                end
                            elseif optionsSelection == 6 then
                                showFpsOverlay = not showFpsOverlay
                            elseif optionsSelection == 7 then
                                if LOW_RES_MODE == "fast" then
                                    LOW_RES_MODE = "quality"
                                else
                                    LOW_RES_MODE = "fast"
                                end
                            elseif optionsSelection == 8 then
                                SHOW_MINIMAP = not SHOW_MINIMAP
                            elseif optionsSelection == 9 then
                                lockRendererMode()
                            elseif optionsSelection == 10 then
                                inGameDebugMenu = true
                                titleDebugSelection = 1
                            elseif optionsSelection == 11 then
                                inOptionsMenu = false  -- Back to main menu
                            end
                        end
                        if vmupro.input.pressed(vmupro.input.POWER) or vmupro.input.pressed(vmupro.input.B) then
                            inOptionsMenu = false  -- Back to main menu
                        end
                    end
                else
                    -- Main pause menu
                    if vmupro.input.pressed(vmupro.input.UP) then
                        menuSelection = menuSelection - 1
                        if menuSelection < 1 then menuSelection = 5 end
                    end
                    if vmupro.input.pressed(vmupro.input.DOWN) then
                        menuSelection = menuSelection + 1
                        if menuSelection > 5 then menuSelection = 1 end
                    end
                    if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                        if menuSelection == 1 then
                            showMenu = false  -- Resume
                        elseif menuSelection == 2 then
                            inOptionsMenu = true  -- Enter options
                            optionsSelection = 1
                        elseif menuSelection == 3 then
                            -- Reset position and health
                            px, py, pdir = 2.5, 2.5, 0
                            lastSafeWallX = px
                            lastSafeWallY = py
                            playerHealth = MAX_HEALTH
                            showMenu = false
                        elseif menuSelection == 4 then
                            -- Return to title menu
                            showMenu = false
                            enterTitle()
                        elseif menuSelection == 5 then
                            quitApp("game over quit")  -- Quit
                        end
                    end
                    if vmupro.input.pressed(vmupro.input.POWER) then
                        showMenu = false  -- Close menu
                    end
                end
            else
                -- Normal gameplay controls
                local controlSteps = simStepsThisFrame or 0
                if controlSteps > 0 then
                    local moveStep = PLAYER_MOVE_SPEED_PER_SEC / SIM_TARGET_HZ
                    local strafeStep = PLAYER_STRAFE_SPEED_PER_SEC / SIM_TARGET_HZ
                    local turnPerStep = PLAYER_TURN_STEPS_PER_SEC / SIM_TARGET_HZ
                    local heldLeft = vmupro.input.held(vmupro.input.LEFT)
                    local heldRight = vmupro.input.held(vmupro.input.RIGHT)
                    local heldMode = vmupro.input.held(vmupro.input.MODE)
                    local heldUp = vmupro.input.held(vmupro.input.UP)
                    local heldDown = vmupro.input.held(vmupro.input.DOWN)
                    local heldA = vmupro.input.held(vmupro.input.A)
                    local heldB = vmupro.input.held(vmupro.input.B)
                    local pressedUp = vmupro.input.pressed(vmupro.input.UP)
                    local pressedPower = vmupro.input.pressed(vmupro.input.POWER)
                    local attackRange = PLAYER_ATTACK_RANGE or 0
                    local attackRangeSq = attackRange * attackRange
                    for simStep = 1, controlSteps do
                        if showMenu then break end

                        local turnInput = 0
                        if heldLeft then
                            turnInput = turnInput - 1
                        end
                        if heldRight then
                            turnInput = turnInput + 1
                        end
                        if turnInput ~= 0 then
                            turnStepAccumulator = turnStepAccumulator + (turnInput * turnPerStep)
                        end
                        while turnStepAccumulator <= -1.0 do
                            pdir = pdir - 1
                            if pdir < 0 then pdir = pdir + 64 end
                            turnStepAccumulator = turnStepAccumulator + 1.0
                        end
                        while turnStepAccumulator >= 1.0 do
                            pdir = pdir + 1
                            if pdir >= 64 then pdir = pdir - 64 end
                            turnStepAccumulator = turnStepAccumulator - 1.0
                        end

                        local idx = pdir % 64
                        local dx = cosTable[idx] * moveStep
                        local dy = sinTable[idx] * moveStep
                        local strafe_idx = (pdir + 16) % 64  -- 90 degrees right
                        local sdx = cosTable[strafe_idx] * strafeStep
                        local sdy = sinTable[strafe_idx] * strafeStep

                        local modeHeld = heldMode
                        local wasBlocking = isBlocking

                        if modeHeld then
                            if simStep == 1 and pressedUp and isAttacking == 0 then
                                local attackFrames = #swordAttack
                                attackTotalFrames = 9
                                if attackFrames == 0 then
                                    attackTotalFrames = 10
                                end
                                isAttacking = attackTotalFrames

                                local hitSomething = false
                                for i = 1, #sprites do
                                    local s = sprites[i]
                                    if s.t == 5 and s.alive then
                                        local sdxHit = s.x - px
                                        local sdyHit = s.y - py
                                        local distSq = sdxHit * sdxHit + sdyHit * sdyHit
                                        if distSq < attackRangeSq then
                                            s.hp = s.hp - PLAYER_DAMAGE
                                            if not hitSomething then
                                                hitSomething = true
                                                if soundEnabled and swordHitSample then
                                                    vmupro.sound.sample.stop(swordHitSample)
                                                    vmupro.sound.sample.play(swordHitSample)
                                                    if enableBootLogs then safeLog("INFO", "Play sample: sword_swing_connect") end
                                                end
                                            end
                                            if s.hp <= 0 then
                                                killSoldier(s)
                                            end
                                        end
                                    end
                                end
                                if soundEnabled and (not hitSomething) and swordMissSample then
                                    vmupro.sound.sample.stop(swordMissSample)
                                    vmupro.sound.sample.play(swordMissSample)
                                    if enableBootLogs then safeLog("INFO", "Play sample: sword_miss") end
                                end
                            end

                            isBlocking = heldDown
                        else
                            isBlocking = false

                            if heldUp then
                                movePlayerWithSlide(dx, dy)
                            end

                            if heldDown then
                                movePlayerWithSlide(-dx, -dy)
                            end

                        end

                        if isBlocking and not wasBlocking then
                            blockStartFrame = simTickCount
                        end
                        if isBlocking then
                            if blockAnim < (BLOCK_ANIM_FRAMES or 8) then
                                blockAnim = blockAnim + 1
                            end
                        else
                            if blockAnim > 0 then
                                blockAnim = blockAnim - 1
                            end
                        end

                        if heldA then
                            movePlayerWithSlide(-sdx, -sdy)
                        end

                        if heldB then
                            movePlayerWithSlide(sdx, sdy)
                        end

                        recoverPlayerFromWallPenetration()

                        if simStep == 1 and pressedPower then
                            showMenu = true
                            menuSelection = 1
                            break
                        end
                    end
                end
            end
        end)
        if logicSectionStartUs and perfSectionClock then
            local logicSectionEndUs = perfSectionClock()
            if logicSectionEndUs and logicSectionEndUs >= logicSectionStartUs then
                PERF_MONITOR_SAMPLE_LOGIC_US = PERF_MONITOR_SAMPLE_LOGIC_US + (logicSectionEndUs - logicSectionStartUs)
            end
        end
        if (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2.7 after title/menu pcall ok=" .. tostring(okTitle))
        end
        if not okTitle then
            logBoot(vmupro.system.LOG_ERROR, "title/menu error: " .. tostring(errTitle))
            quitApp("title/menu error: " .. tostring(errTitle))
        end

        -- Keep DBUF policy state-aware so title rendering never flips between stale buffers.
        syncDoubleBufferForState()

        -- Render based on game state
        local renderSectionStartUs = perfSectionClock and perfSectionClock()
        if gameState == STATE_LOADING then
            if loadingTimer == loadingMax then
                loadingLog("LOAD render loading screen frame1")
            end
            vmupro.graphics.clear(COLOR_BLACK)
            vmupro.graphics.drawFillRect(40, 105, 200, 135, COLOR_DARK_GRAY)
            vmupro.graphics.drawFillRect(45, 110, 195, 130, COLOR_BLACK)
            local progress = 1.0 - (loadingTimer / loadingMax)
            if progress < 0 then progress = 0 end
            if progress > 1 then progress = 1 end
            local barW = math.floor(146 * progress)
            vmupro.graphics.drawFillRect(48, 113, 48 + barW, 127, COLOR_MAROON)
            setFontCached(vmupro.text.FONT_SMALL)
            drawUiText("LOADING", 95, 90, COLOR_WHITE, COLOR_BLACK)
        elseif gameState == STATE_TITLE then
            if titleNeedsRedraw then
                logBoot(vmupro.system.LOG_ERROR, "B3 before drawTitleScreen")
                local okTitleDraw, errTitleDraw = pcall(function()
                    if drawTitleScreen then
                        drawTitleScreen()
                    else
                        error("drawTitleScreen missing")
                    end
                end)
                if not okTitleDraw then
                    logBoot(vmupro.system.LOG_ERROR, "drawTitleScreen error: " .. tostring(errTitleDraw))
                    quitApp("drawTitleScreen error: " .. tostring(errTitleDraw))
                end
                titleNeedsRedraw = false
            end
        else
            local okRender, errRender = pcall(renderGameFrame)
            if not okRender then
                logBoot(vmupro.system.LOG_ERROR, 'render error: ' .. tostring(errRender))
                quitApp("render error: " .. tostring(errRender))
            end
        end  -- End of game rendering (else branch of title screen check)
        if renderSectionStartUs and perfSectionClock then
            local renderSectionEndUs = perfSectionClock()
            if renderSectionEndUs and renderSectionEndUs >= renderSectionStartUs then
                PERF_MONITOR_SAMPLE_RENDER_US = PERF_MONITOR_SAMPLE_RENDER_US + (renderSectionEndUs - renderSectionStartUs)
            end
        end

        ::render_only::
        local presentSectionStartUs = perfSectionClock and perfSectionClock()
        presentFrame()
        if presentSectionStartUs and perfSectionClock then
            local presentSectionEndUs = perfSectionClock()
            if presentSectionEndUs and presentSectionEndUs >= presentSectionStartUs then
                PERF_MONITOR_SAMPLE_PRESENT_US = PERF_MONITOR_SAMPLE_PRESENT_US + (presentSectionEndUs - presentSectionStartUs)
            end
        end
        if gameState == STATE_TITLE then
            targetFrameUs = 16667
        else
            if FPS_TARGET_MODE == "uncapped" then
                targetFrameUs = 0
            elseif FPS_TARGET_MODE == "60" then
                targetFrameUs = 16667
            elseif FPS_TARGET_MODE == "45" then
                targetFrameUs = 22222
            elseif FPS_TARGET_MODE == "30" then
                targetFrameUs = 33333
            elseif FPS_TARGET_MODE == "24" then
                targetFrameUs = 41667
            else
                targetFrameUs = 33333
            end
        end
        if vmupro.system and vmupro.system.getTimeUs then
            local frameEndUs = vmupro.system.getTimeUs()
            if frameStartUs > 0 and frameEndUs > frameStartUs then
                local cpuElapsedUs = frameEndUs - frameStartUs
                local remainingUs = targetFrameUs - cpuElapsedUs
                if remainingUs > 0 and vmupro.system.delayMs then
                    local sleepSectionStartUs = perfSectionClock and perfSectionClock()
                    vmupro.system.delayMs(math.floor(remainingUs / 1000))
                    if sleepSectionStartUs and perfSectionClock then
                        local sleepSectionEndUs = perfSectionClock()
                        if sleepSectionEndUs and sleepSectionEndUs >= sleepSectionStartUs then
                            PERF_MONITOR_SAMPLE_SLEEP_US = PERF_MONITOR_SAMPLE_SLEEP_US + (sleepSectionEndUs - sleepSectionStartUs)
                        end
                    end
                end
                local perfNowUsAfterSleep = vmupro.system.getTimeUs()
                perfMonitorEndFrame(cpuElapsedUs, perfNowUsAfterSleep)
            end
        end
    end

    -- Cleanup assets
    applyDoubleBufferMode(false)
    unloadLevelAudio()
    unloadLevelSprites()
    unloadMenuSprites()

    return 0
end
