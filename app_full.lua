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

function getDoubleBufferPrefLabel()
    return DEBUG_DOUBLE_BUFFER and "ON" or "OFF"
end

function getDoubleBufferActiveLabel()
    return DOUBLE_BUFFER_ACTIVE and "ON" or "OFF"
end

function getDoubleBufferStatusLabel()
    local suffix = ""
    if DOUBLE_BUFFER_FORCED_TITLE_OFF then
        suffix = " T"
    end
    return "P" .. getDoubleBufferPrefLabel() .. " A" .. getDoubleBufferActiveLabel() .. suffix
end

function applyRuntimeLogLevel()
    if vmupro and vmupro.system and vmupro.system.setLogLevel then
        local level = vmupro.system.LOG_DEBUG
        if not enableBootLogs and not enablePerfLogs then
            level = vmupro.system.LOG_ERROR
        end
        vmupro.system.setLogLevel(level)
    end
end

function logBoot(level, message)
    if not enableBootLogs then return end
    if vmupro and vmupro.system and vmupro.system.log then
        vmupro.system.log(level, "BOOT", message)
    end
end

function logPerf(message)
    if not enablePerfLogs then return end
    if vmupro and vmupro.system and vmupro.system.log then
        vmupro.system.log(vmupro.system.LOG_INFO, "PERF", message)
    end
end

function perfNowUs()
    if vmupro and vmupro.system and vmupro.system.getTimeUs then
        return vmupro.system.getTimeUs()
    end
    return nil
end

function perfEma(prev, sample)
    if not sample or sample <= 0 then
        return prev or 0
    end
    if not prev or prev <= 0 then
        return sample
    end
    local alpha = PERF_MONITOR_ALPHA or 0.25
    return prev + (sample - prev) * alpha
end

function perfMonitorBeginFrame()
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

function perfMonitorSetRayInfo(baseIdx, effIdx, useFixed)
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

function perfMonitorEndFrame(frameUs, frameNowUs)
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

function readMemoryStats()
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

function updateDoubleBufferDeltas()
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

function applyDoubleBufferMode(enable)
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

function syncDoubleBufferForState()
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

function presentFrame()
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

function tryImport(mod)
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
tryImport("api/file")
tryImport("api/text")
tryImport("data/classes")
tryImport("data/items")
tryImport("data/loot_tables")
tryImport("data/achievements")
tryImport("data/score_model")
tryImport("data/trader_tiers")
tryImport("data/persistence")
tryImport("data/runtime_state")

logBoot(vmupro.system.LOG_ERROR, "after imports")

-- Fallback stub; replaced by drawTitleScreenImpl when defined
function drawTitleScreen()
    logBoot(vmupro.system.LOG_ERROR, "drawTitleScreen stub")
end

-- Safety Check Functions
function safeLog(level, message)
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

function validateSprite(sprite, context)
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

function validateTextureDimensions(sprite, context)
    if not validateSprite(sprite, context) then
        return false
    end
    if sprite.width > 2048 or sprite.height > 2048 then
        safeLog("WARN", "Texture dimensions may be too large in context: " .. (context or "unknown") ..
               " width=" .. tostring(sprite.width) .. " height=" .. tostring(sprite.height))
    end
    return true
end

function safeDivide(value, divisor, context)
    if divisor == 0 then
        safeLog("ERROR", "Division by zero in context: " .. (context or "unknown") ..
               " value=" .. tostring(value) .. " divisor=0")
        return 0
    end
    return value / divisor
end

function checkArrayBounds(array, index, context)
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

function safeScale(sprite, scaleX, scaleY, context)
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
function setFontCached(fontId)
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

function buildSingleRoomMap()
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

-- Sprites: t=1 torch, t=2 barrel, t=3 table, t=4 chest, t=5 warrior, t=6 knight, t=7 health vial, t=8 world item drop
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
bowChargeState = {
    active = false,
    ticks = 0,
    stage = 1,
    flashTicks = 0,
    stageThresholds = nil,
    damageMult = nil,
    rangeMult = nil,
    speedMult = nil,
}
isBlocking = false   -- Currently blocking
blockStartFrame = -1000 -- Simulation tick when block was raised
blockAnim = 0        -- Shield raise animation frame (0 = hidden)
BLOCK_ANIM_FRAMES = 4
lastBlockEvent = nil  -- {amount, pct, prime, frame}
DMG_DEBUG_DURATION_TICKS = SIM_TARGET_HZ * 2
damageDebugTakenValue = 0
damageDebugDealtValue = 0
damageDebugTakenUntilTick = 0
damageDebugDealtUntilTick = 0
showMenu = false     -- Menu visible
menuSelection = 1    -- Current menu selection
inOptionsMenu = false -- Currently in options submenu
optionsSelection = 1  -- Current options selection
inGameDebugMenu = false -- In-game options: debug submenu
inSaveMenu = false    -- In-game save submenu
inInventoryMenu = false -- In-game inventory/stash submenu
inStatsMenu = false   -- In-game stat allocation submenu
inMasteryMenu = false -- In-game weapon mastery submenu
saveMenuSelection = 1
saveMenuMessage = ""
saveMenuMessageTimer = 0
inventoryMenuSelection = 1
inventoryMenuPage = 1
inventoryMenuTab = 1
inventoryMenuMessage = ""
inventoryMenuMessageTimer = 0
statsMenuSelection = 1
statsMenuMessage = ""
statsMenuMessageTimer = 0
masteryMenuSelection = 1
masteryMenuMessage = ""
masteryMenuMessageTimer = 0
lootFeedMessage = ""
lootFeedMessageTimer = 0
INVENTORY_MENU_ROWS_PER_PAGE = 12
INVENTORY_MENU_TABS = {"INV", "STASH", "EQUIP", "TRADER"}

-- Static menu labels to avoid per-frame table allocations.
TITLE_MAIN_MENU_ITEMS = {"NEW GAME", "LOAD GAME", "OPTIONS", "EXIT"}
GAME_OVER_MENU_ITEMS = {"RESTART", "MENU", "QUIT"}
PAUSE_MENU_ITEMS = {"RESUME", "SAVE GAME", "INVENTORY", "STATS", "MASTERIES", "OPTIONS", "RESTART", "MENU", "QUIT"}

-- Options settings
soundEnabled = true   -- Sound on/off
ENABLE_SAMPLE_AUDIO = true -- Re-enable sample audio for title/game SFX playback.
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
playerRegenAccumulator = 0.0
player_build_state = nil
playerBuildStateDirty = true
inventory_state = nil
stash_state = nil
achievement_state = nil
high_score_state = nil
score_state = nil
potionSprite = nil
titleSprite = nil
classPortraitSprite = nil
classPortraitSprites = {}
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
DRAW_DIST_PRESETS = {
    3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24
}
DRAW_DIST_INDEX = 27 -- default: 20
MIPMAP_DIST_PRESETS = {
    0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24
}
MIPMAP1_DIST_INDEX = 12 -- default: 5.5
MIPMAP2_DIST_INDEX = 19 -- default: 9
MIPMAP3_DIST_INDEX = 31 -- default: 18
MIPMAP4_DIST_INDEX = 33 -- default: 20
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

function spriteOrderCompareFarToNear(a, b)
    return (a and a.dist or 0) > (b and b.dist or 0)
end

function clearSpriteOrderCache()
    local n = #spriteOrderCache
    for i = 1, n do
        spriteOrderCache[i] = nil
    end
    spriteOrderCacheFrame = -999
end

PLAYER_RADIUS = 0.50
-- Slightly slimmer than visual body width to reduce "invisible corner snag" feeling.
PLAYER_COLLISION_RADIUS = 0.27
PLAYER_MOVE_SUBSTEP = 0.08
PLAYER_MOVE_SUBSTEP_STRICT = 0.04
-- Keep full collision radius at walls; avoids micro-creep when holding forward into a wall.
PLAYER_WALL_COLLISION_INSET = 0.0
PLAYER_WALL_CLEARANCE_EPSILON = 0.004
-- Prevent near-contact projection blowup when player is pressed against walls.
PLAYER_RENDER_NEAR_CLIP_DIST = 0.38
PLAYER_WALL_CONTACT_FRAMES = 0
PLAYER_WALL_CONTACT_HOLD_FRAMES = 4
WALL_NEAR_STABILITY_DIST = 1.85
WALL_SEAM_DISABLE_NEAR_DIST = 1.35
WALL_TEX_SEAM_OVERDRAW = true
WALL_TEX_SEAM_PIXELS = 1
DEBUG_DISABLE_PROPS = false
FOG_DISTANCE_PRESETS = {
    2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28
}
-- Start and full-fog use the same preset list for predictable tuning.
FOG_START_PRESETS = FOG_DISTANCE_PRESETS
FOG_END_PRESETS = FOG_DISTANCE_PRESETS
-- Legacy cutoff retained for compatibility; EXP-H now uses start/end fade range.
FOG_CUTOFF_PRESETS = FOG_DISTANCE_PRESETS
FOG_COLOR_PRESETS = {COLOR_DARK_GRAY, COLOR_GRAY, COLOR_LIGHT_GRAY, COLOR_WHITE, COLOR_BLACK, COLOR_MAROON}
FOG_COLOR_LABELS = {"DARK", "GRAY", "LGRAY", "WHITE", "BLACK", "MAROON"}
FOG_START_INDEX = 33 -- default: 24
FOG_END_INDEX = 37 -- default: 28
FOG_CUTOFF_INDEX = 37 -- default: 28
FOG_COLOR_INDEX = 5
FOG_START = FOG_START_PRESETS[FOG_START_INDEX]
FOG_END = FOG_END_PRESETS[FOG_END_INDEX]
FOG_TEX_CUTOFF = FOG_CUTOFF_PRESETS[FOG_CUTOFF_INDEX]
FOG_COLOR = FOG_COLOR_PRESETS[FOG_COLOR_INDEX]
FOG_DITHER_SIZE_PRESETS = {1, 2, 3, 4, 5, 6}
FOG_DITHER_SIZE_INDEX = 1
FOG_DITHER_SIZE = FOG_DITHER_SIZE_PRESETS[FOG_DITHER_SIZE_INDEX]
FOG_LUT_STEP = 0.0625
FOG_LUT_INV_STEP = 16.0
FOG_LUT_DIST_MAX = 0.0
FOG_LUT_LINEAR = {}
FOG_LUT_QUANTIZED = {}
FAR_TEX_OFF_PRESETS = {
    3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 999
}
FAR_TEX_OFF_INDEX = 32 -- default: OFF
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
BUILD_COUNT = 183 -- Bump by +1 whenever we ship a new build/test iteration.
textureDebugFrame = -1
textureDebugSamples = 0

RUN_MODE_STORY = 1
RUN_MODE_WAVE = 2
RUN_MODE_LABELS = {
    [RUN_MODE_STORY] = "STORY",
    [RUN_MODE_WAVE] = "WAVE",
}
run_mode = RUN_MODE_STORY
run_reset_requested = true
run_session_id = 0
run_seed = 0
run_level_ordinal = 0
run_score_event_count = 0
RUN_SCORE_PULSE_TICKS = 0
RUN_SCORE_PULSE_MAX = 36
RUN_SCORE_EVENT_POINTS = {
    enemy_kill = 100,
    health_pickup = 25,
    chest_open = 40,
    item_pickup = 20,
    level_clear = 300,
    no_damage_clear = 200,
}

function markRunResetRequested()
    run_reset_requested = true
end

function shouldStartNewRunForLevelLoad(levelId)
    if run_reset_requested then
        return true
    end
    local nextLevel = math.floor(tonumber(levelId) or 1)
    if nextLevel < 1 then
        nextLevel = 1
    end
    local activeLevel = math.floor(tonumber(currentLevel) or nextLevel)
    if gameState == STATE_WIN and nextLevel == (activeLevel + 1) then
        return false
    end
    return true
end

function computeRunSeed(levelId)
    local level = math.floor(tonumber(levelId) or 1)
    local frame = math.floor(tonumber(frameCount) or 0)
    local tick = math.floor(tonumber(simTickCount) or 0)
    local session = math.floor(tonumber(run_session_id) or 0)
    local value = (level * 4099) + (frame * 131) + (tick * 17) + (session * 7919) + 97
    value = value % 2147483647
    if value < 1 then
        value = value + 2147483646
    end
    return value
end

function ensureRunScoreState(levelId)
    local level = math.floor(tonumber(levelId) or tonumber(currentLevel) or 1)
    if level < 1 then level = 1 end
    if type(score_state) ~= "table" then
        if GameScoreModel and GameScoreModel.newRun then
            score_state = GameScoreModel.newRun()
        else
            score_state = {
                current = 0,
                kills = 0,
                levels_cleared = 0,
                started_level = level,
                ended_level = level,
            }
        end
    end
    score_state.current = math.floor(tonumber(score_state.current) or 0)
    score_state.kills = math.floor(tonumber(score_state.kills) or 0)
    score_state.levels_cleared = math.floor(tonumber(score_state.levels_cleared) or 0)
    score_state.started_level = math.floor(tonumber(score_state.started_level) or level)
    score_state.ended_level = math.floor(tonumber(score_state.ended_level) or level)
    if score_state.started_level < 1 then score_state.started_level = level end
    if score_state.ended_level < 1 then score_state.ended_level = level end
    if score_state.no_damage_level == nil then
        score_state.no_damage_level = true
    end
    return score_state
end

function addRunScorePoints(amount)
    local delta = math.floor(tonumber(amount) or 0)
    if delta <= 0 then
        return 0
    end
    local run = ensureRunScoreState(currentLevel)
    if GameScoreModel and GameScoreModel.addPoints then
        GameScoreModel.addPoints(run, delta)
    else
        run.current = (run.current or 0) + delta
    end
    RUN_SCORE_PULSE_TICKS = RUN_SCORE_PULSE_MAX
    return delta
end

function applyAchievementProgress(triggerName, progressValue)
    if not GameAchievements then
        return
    end
    if type(achievement_state) ~= "table" then
        if newAchievementState then
            achievement_state = newAchievementState()
        else
            achievement_state = {unlocked = {}, progress = {}}
        end
    end
    if type(achievement_state.unlocked) ~= "table" then
        achievement_state.unlocked = {}
    end
    if type(achievement_state.progress) ~= "table" then
        achievement_state.progress = {}
    end

    local value = math.floor(tonumber(progressValue) or 0)
    if value < 0 then value = 0 end

    for _, def in pairs(GameAchievements) do
        if def and def.trigger == triggerName and def.id then
            local achievementId = def.id
            local previous = math.floor(tonumber(achievement_state.progress[achievementId]) or 0)
            if value > previous then
                achievement_state.progress[achievementId] = value
            end
            if not achievement_state.unlocked[achievementId] then
                local threshold = math.floor(tonumber(def.threshold) or 1)
                if threshold < 1 then threshold = 1 end
                if value >= threshold then
                    local unlocked = false
                    if markAchievementUnlocked then
                        unlocked = markAchievementUnlocked(achievement_state, achievementId)
                    else
                        achievement_state.unlocked[achievementId] = true
                        unlocked = true
                    end
                    if unlocked then
                        local bonus = math.floor(tonumber(def.reward and def.reward.score_bonus) or 0)
                        if bonus > 0 then
                            addRunScorePoints(bonus)
                        end
                        if ExpansionPersistence and ExpansionPersistence.saveAchievementState then
                            ExpansionPersistence.saveAchievementState(achievement_state)
                        end
                    end
                end
            end
        end
    end
end

function dispatchRunScoreEvent(eventId, payload)
    local eventName = tostring(eventId or "")
    local data = payload or {}
    local level = math.floor(tonumber(data.level_id) or tonumber(currentLevel) or 1)
    if level < 1 then level = 1 end
    local run = ensureRunScoreState(level)
    run.ended_level = level

    local points = math.floor(tonumber(data.points) or tonumber(RUN_SCORE_EVENT_POINTS[eventName]) or 0)
    if points < 0 then points = 0 end

    if eventName == "run_start" then
        run.started_level = level
        run.ended_level = level
        run.kills = 0
        run.levels_cleared = 0
        run.no_damage_level = true
    elseif eventName == "level_start" then
        run.ended_level = level
        run.no_damage_level = true
    elseif eventName == "enemy_kill" then
        run.kills = math.floor(tonumber(run.kills) or 0) + 1
        applyAchievementProgress("kill_count", run.kills)
    elseif eventName == "player_damaged" then
        run.no_damage_level = false
    elseif eventName == "level_clear" then
        run.levels_cleared = math.floor(tonumber(run.levels_cleared) or 0) + 1
        applyAchievementProgress("levels_cleared", run.levels_cleared)
        if run.no_damage_level then
            applyAchievementProgress("no_damage_level", 1)
            points = points + math.floor(tonumber(RUN_SCORE_EVENT_POINTS.no_damage_clear) or 0)
        else
            applyAchievementProgress("no_damage_level", 0)
        end
        run.no_damage_level = false
    end

    if points > 0 then
        addRunScorePoints(points)
    end
    run_score_event_count = (run_score_event_count or 0) + 1
end

function ensureHighScoreState()
    if type(high_score_state) ~= "table" then
        high_score_state = {entries = {}}
    end
    if type(high_score_state.entries) ~= "table" then
        high_score_state.entries = {}
    end
    return high_score_state
end

function getCurrentRunScoreValue()
    local run = ensureRunScoreState(currentLevel)
    return math.floor(tonumber(run.current) or 0)
end

function getCurrentRunLevelValue()
    local run = ensureRunScoreState(currentLevel)
    local levelValue = math.floor(tonumber(run.ended_level) or tonumber(currentLevel) or 1)
    if levelValue < 1 then levelValue = 1 end
    return levelValue
end

function doesScoreQualifyForHighScore(scoreValue, levelValue)
    local state = ensureHighScoreState()
    local entries = state.entries
    local maxEntries = RUN_HIGHSCORE_MAX_ENTRIES or 10
    local score = math.floor(tonumber(scoreValue) or 0)
    local level = math.floor(tonumber(levelValue) or 1)
    if level < 1 then level = 1 end
    if #entries < maxEntries then
        return true
    end

    local worstScore = 2147483647
    local worstLevel = 2147483647
    for i = 1, #entries do
        local entry = entries[i]
        local entryScore = math.floor(tonumber(entry and entry.score) or 0)
        local entryLevel = math.floor(tonumber(entry and entry.level) or 1)
        if entryLevel < 1 then entryLevel = 1 end
        if entryScore < worstScore or (entryScore == worstScore and entryLevel < worstLevel) then
            worstScore = entryScore
            worstLevel = entryLevel
        end
    end

    if score > worstScore then
        return true
    end
    if score == worstScore and level > worstLevel then
        return true
    end
    return false
end

function resetGameOverScoreEntryState()
    gameOverInitialsActive = false
    gameOverInitialsCursor = 1
    gameOverInitialsChars = {"A", "A", "A"}
    gameOverScoreQualified = false
    gameOverScoreSubmitted = false
    gameOverScoreStatus = ""
end

function getGameOverInitialsText()
    local a = (gameOverInitialsChars and gameOverInitialsChars[1]) or "A"
    local b = (gameOverInitialsChars and gameOverInitialsChars[2]) or "A"
    local c = (gameOverInitialsChars and gameOverInitialsChars[3]) or "A"
    local text = tostring(a) .. tostring(b) .. tostring(c)
    if GameScoreModel and GameScoreModel.sanitizeInitials then
        return GameScoreModel.sanitizeInitials(text)
    end
    return text
end

function setGameOverInitialsText(initials)
    local text = tostring(initials or "AAA")
    if GameScoreModel and GameScoreModel.sanitizeInitials then
        text = GameScoreModel.sanitizeInitials(text)
    end
    gameOverInitialsChars = {
        text:sub(1, 1),
        text:sub(2, 2),
        text:sub(3, 3),
    }
end

function stepGameOverInitialsChar(step)
    if not gameOverInitialsActive then
        return
    end
    local cursor = math.floor(tonumber(gameOverInitialsCursor) or 1)
    if cursor < 1 then cursor = 1 end
    if cursor > 3 then cursor = 3 end
    gameOverInitialsCursor = cursor
    local current = ((gameOverInitialsChars and gameOverInitialsChars[cursor]) or "A")
    local byte = string.byte(current, 1) or string.byte("A", 1)
    if byte < 65 or byte > 90 then byte = 65 end
    local delta = math.floor(tonumber(step) or 0)
    local nextValue = (byte - 65 + delta) % 26
    gameOverInitialsChars[cursor] = string.char(65 + nextValue)
end

function submitGameOverHighScoreEntry()
    if gameOverScoreSubmitted then
        gameOverInitialsActive = false
        return true
    end
    if not gameOverScoreQualified then
        gameOverInitialsActive = false
        return false
    end

    local scoreValue = getCurrentRunScoreValue()
    local levelValue = getCurrentRunLevelValue()
    local initials = getGameOverInitialsText()
    local entry = nil
    if GameScoreModel and GameScoreModel.createEntry then
        entry = GameScoreModel.createEntry(initials, scoreValue, levelValue)
    else
        entry = {initials = initials, score = scoreValue, level = levelValue}
    end

    local state = ensureHighScoreState()
    if GameScoreModel and GameScoreModel.insertHighScore then
        state.entries = GameScoreModel.insertHighScore(state.entries, entry, RUN_HIGHSCORE_MAX_ENTRIES or 10)
    else
        state.entries[#state.entries + 1] = entry
    end

    local saveOk = false
    if ExpansionPersistence and ExpansionPersistence.saveHighScores then
        local okWrite = ExpansionPersistence.saveHighScores(state.entries)
        saveOk = okWrite and true or false
    end

    gameOverInitialsActive = false
    gameOverScoreSubmitted = true
    gameOverScoreStatus = saveOk and "HIGH SCORE SAVED" or "HIGH SCORE ADDED"
    return true
end

function prepareGameOverState()
    local classId = getCurrentClassId()
    local classSeed = "AAA"
    if classId == "warrior" then
        classSeed = "WAR"
    elseif classId == "archer" then
        classSeed = "ARC"
    elseif classId == "mage" then
        classSeed = "MAG"
    end

    ensureRunScoreState(currentLevel)
    ensureHighScoreState()
    resetGameOverScoreEntryState()
    setGameOverInitialsText(classSeed)

    local scoreValue = getCurrentRunScoreValue()
    local levelValue = getCurrentRunLevelValue()
    gameOverScoreQualified = doesScoreQualifyForHighScore(scoreValue, levelValue)
    gameOverInitialsActive = gameOverScoreQualified
    if gameOverScoreQualified then
        gameOverScoreStatus = "NEW HIGH SCORE"
    else
        gameOverScoreStatus = "NO HIGH SCORE"
    end
end

function enterGameOverState()
    gameState = STATE_GAME_OVER
    gameOverSelection = 1
    prepareGameOverState()
end

function handleGameOverInput()
    if gameOverInitialsActive then
        if vmupro.input.pressed(vmupro.input.LEFT) then
            gameOverInitialsCursor = gameOverInitialsCursor - 1
            if gameOverInitialsCursor < 1 then gameOverInitialsCursor = 3 end
        end
        if vmupro.input.pressed(vmupro.input.RIGHT) then
            gameOverInitialsCursor = gameOverInitialsCursor + 1
            if gameOverInitialsCursor > 3 then gameOverInitialsCursor = 1 end
        end
        if vmupro.input.pressed(vmupro.input.UP) then
            stepGameOverInitialsChar(1)
        end
        if vmupro.input.pressed(vmupro.input.DOWN) then
            stepGameOverInitialsChar(-1)
        end
        if vmupro.input.pressed(vmupro.input.A) or vmupro.input.pressed(vmupro.input.MODE) then
            if gameOverInitialsCursor < 3 then
                gameOverInitialsCursor = gameOverInitialsCursor + 1
            else
                submitGameOverHighScoreEntry()
            end
        end
        if vmupro.input.pressed(vmupro.input.B) or vmupro.input.pressed(vmupro.input.POWER) then
            submitGameOverHighScoreEntry()
        end
        return
    end

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
end

function bootstrapExpansionDataLayer()
    if not ExpansionRuntimeState or not ExpansionRuntimeState.bootstrap then
        return
    end
    local state = ExpansionRuntimeState.bootstrap()
    if not state then
        return
    end
    player_build_state = state.player_build_state or player_build_state
    playerBuildStateDirty = true
    inventory_state = state.inventory_state or inventory_state
    stash_state = state.stash_state or stash_state
    achievement_state = state.achievement_state or achievement_state
    high_score_state = state.high_score_state or high_score_state
    score_state = state.score_state or score_state
    if ensurePlayerBuildState then
        ensurePlayerBuildState()
    end
end

function beginExpansionRun(levelId)
    local level = math.floor(tonumber(levelId) or tonumber(currentLevel) or 1)
    if level < 1 then level = 1 end

    local shouldStartNewRun = run_reset_requested or type(score_state) ~= "table"
    if shouldStartNewRun and ExpansionRuntimeState and ExpansionRuntimeState.beginRun then
        local state = ExpansionRuntimeState.beginRun(level, currentLevel)
        if state then
            player_build_state = state.player_build_state or player_build_state
            playerBuildStateDirty = true
            inventory_state = state.inventory_state or inventory_state
            stash_state = state.stash_state or stash_state
            achievement_state = state.achievement_state or achievement_state
            high_score_state = state.high_score_state or high_score_state
            score_state = state.score_state or score_state
        end
    end

    if shouldStartNewRun then
        run_session_id = (run_session_id or 0) + 1
        run_seed = computeRunSeed(level)
        run_level_ordinal = 0
        dispatchRunScoreEvent("run_start", {level_id = level, points = 0})
    end

    run_level_ordinal = (run_level_ordinal or 0) + 1
    dispatchRunScoreEvent("level_start", {level_id = level, points = 0})
    run_reset_requested = false

    if ensurePlayerBuildState then
        ensurePlayerBuildState()
    end
end
function wallQuadLog(msg)
    if enableBootLogs and DEBUG_WALL_QUADS_LOG and wallQuadLogCount < 30 then
        print(msg)
        wallQuadLogCount = wallQuadLogCount + 1
    end
end

function forceSpriteColorKey(sprite, label)
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
titleSelection = 1  -- 1=New Game, 2=Load Game, 3=Options, 4=Exit
titleInClassSelect = false
titleClassSelection = 1
titleInLoadMenu = false
titleLoadSelection = 1
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

function setAudioMixHz(hz)
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

function quitApp(reason)
    logBoot(vmupro.system.LOG_ERROR, "APP EXIT: " .. tostring(reason))
    app_running = false
end

function getDebugPageName(pageId)
    if pageId == DEBUG_PAGE_VIDEO then
        return "VIDEO"
    elseif pageId == DEBUG_PAGE_PERF then
        return "PERF/Q"
    end
    return "DEBUG"
end

function stepDebugPage(delta)
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

function lockRendererMode()
    -- Single supported renderer path: EXP-H with proper column textures.
    if RENDERER_MODE ~= "exp_hybrid" then
        RENDERER_MODE = "exp_hybrid"
    end
    if WALL_TEXTURE_MODE ~= "proper" then
        WALL_TEXTURE_MODE = "proper"
    end
end

function nearestPresetIndex(list, target)
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

function nearestRayPresetIndex(targetRays)
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

function clampInt(v, minV, maxV)
    if v < minV then return minV end
    if v > maxV then return maxV end
    return v
end

function getDrawDistanceSystemCap()
    local drawCap = (DRAW_DIST_PRESETS and DRAW_DIST_PRESETS[#DRAW_DIST_PRESETS]) or (EXP_TEX_MAX_DIST or 24.0)
    local fogCap = (FOG_DISTANCE_PRESETS and FOG_DISTANCE_PRESETS[#FOG_DISTANCE_PRESETS]) or drawCap
    local cap = drawCap
    if fogCap < cap then
        cap = fogCap
    end
    if cap < 0.5 then
        cap = 0.5
    end
    return cap
end

function getMaxDrawDistancePresetIndex()
    if not DRAW_DIST_PRESETS or #DRAW_DIST_PRESETS == 0 then
        return 1
    end
    local cap = getDrawDistanceSystemCap()
    local maxIdx = 1
    for i = 1, #DRAW_DIST_PRESETS do
        local dist = DRAW_DIST_PRESETS[i] or cap
        if dist <= (cap + 0.0001) then
            maxIdx = i
        else
            break
        end
    end
    return maxIdx
end

function normalizeDrawDistanceSetting()
    if not DRAW_DIST_PRESETS or #DRAW_DIST_PRESETS == 0 then
        EXP_TEX_MAX_DIST = EXP_TEX_MAX_DIST or getDrawDistanceSystemCap()
        return
    end
    local maxIdx = getMaxDrawDistancePresetIndex()
    DRAW_DIST_INDEX = clampInt(DRAW_DIST_INDEX or maxIdx, 1, maxIdx)
    local selected = DRAW_DIST_PRESETS[DRAW_DIST_INDEX] or DRAW_DIST_PRESETS[maxIdx] or getDrawDistanceSystemCap()
    local cap = getDrawDistanceSystemCap()
    if selected > cap then
        selected = cap
    end
    if selected < 0.5 then
        selected = 0.5
    end
    EXP_TEX_MAX_DIST = selected
end

function refreshExpViewDistance()
    normalizeDrawDistanceSetting()
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

function rebuildFogLUT()
    local startDist = FOG_START or 0.0
    local endDist = FOG_END or (startDist + 0.5)
    if endDist <= startDist then
        endDist = startDist + 0.5
    end

    local step = FOG_LUT_STEP or 0.0625
    if step <= 0 then
        step = 0.0625
    end
    local invStep = 1.0 / step
    local span = endDist - startDist
    if span < 0.5 then span = 0.5 end
    local stepCount = math.max(1, math.floor((span / 0.5) + 0.5))
    local maxDist = endDist + step
    if maxDist < 0 then maxDist = 0 end
    local maxIdx = math.floor((maxDist * invStep) + 0.5)

    local linear = {}
    local quantized = {}
    for i = 0, maxIdx do
        local dist = i * step
        local raw = 0.0
        if dist <= startDist then
            raw = 0.0
        elseif dist >= endDist then
            raw = 1.0
        else
            raw = (dist - startDist) / (endDist - startDist)
            if raw < 0 then raw = 0 end
            if raw > 1 then raw = 1 end
        end
        linear[i + 1] = raw
        if raw <= 0 then
            quantized[i + 1] = 0.0
        elseif raw >= 1 then
            quantized[i + 1] = 1.0
        else
            local k = math.ceil(raw * stepCount)
            if k < 0 then k = 0 end
            if k > stepCount then k = stepCount end
            quantized[i + 1] = k / (stepCount + 1)
        end
    end

    FOG_LUT_INV_STEP = invStep
    FOG_LUT_DIST_MAX = maxDist
    FOG_LUT_LINEAR = linear
    FOG_LUT_QUANTIZED = quantized
end

function normalizeFogRange()
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
    rebuildFogLUT()
    refreshExpViewDistance()
end

function getDistanceValueLabel(value)
    local v = tonumber(value) or 0
    if v <= 0 then
        return "OFF"
    end
    local whole = math.floor(v + 0.0001)
    if math.abs(v - whole) < 0.0001 then
        return tostring(whole)
    end
    return string.format("%.1f", v)
end

function getMipmapMaxPresetIndexForDrawDist()
    if not MIPMAP_DIST_PRESETS or #MIPMAP_DIST_PRESETS == 0 then
        return 1
    end
    normalizeDrawDistanceSetting()
    local drawDistCap = EXP_TEX_MAX_DIST or getDrawDistanceSystemCap()
    local maxIdx = 1
    for i = 1, #MIPMAP_DIST_PRESETS do
        local dist = MIPMAP_DIST_PRESETS[i] or 0
        if dist <= 0 or dist <= (drawDistCap + 0.0001) then
            maxIdx = i
        else
            break
        end
    end
    if maxIdx < 1 then maxIdx = 1 end
    return maxIdx
end

function getMipmapLevelIndex(level)
    if level == 1 then return MIPMAP1_DIST_INDEX end
    if level == 2 then return MIPMAP2_DIST_INDEX end
    if level == 3 then return MIPMAP3_DIST_INDEX end
    if level == 4 then return MIPMAP4_DIST_INDEX end
    return 1
end

function setMipmapLevelIndex(level, idx)
    if level == 1 then
        MIPMAP1_DIST_INDEX = idx
    elseif level == 2 then
        MIPMAP2_DIST_INDEX = idx
    elseif level == 3 then
        MIPMAP3_DIST_INDEX = idx
    elseif level == 4 then
        MIPMAP4_DIST_INDEX = idx
    end
end

function getMipmapLevelBounds(level)
    local maxIdx = getMipmapMaxPresetIndexForDrawDist()
    local lower = 2
    for i = level - 1, 1, -1 do
        local prevIdx = getMipmapLevelIndex(i) or 1
        if prevIdx > 1 then
            lower = prevIdx + 1
            break
        end
    end
    local upper = maxIdx
    for i = level + 1, 4 do
        local nextIdx = getMipmapLevelIndex(i) or 1
        if nextIdx > 1 then
            upper = nextIdx - 1
            break
        end
    end
    if lower < 2 then lower = 2 end
    if upper > maxIdx then upper = maxIdx end
    return lower, upper
end

function stepMipmapLevelIndex(level, step)
    if step == 0 then return end
    normalizeMipmapRanges()
    local cur = getMipmapLevelIndex(level) or 1
    local lower, upper = getMipmapLevelBounds(level)
    local nextIdx = cur

    if step > 0 then
        if cur <= 1 then
            if lower <= upper and upper >= 2 then
                nextIdx = lower
            else
                nextIdx = 1
            end
        else
            if lower > upper or cur >= upper then
                -- If this level cannot move farther because of next level/cap, roll to OFF.
                nextIdx = 1
            else
                nextIdx = cur + 1
                if nextIdx > upper then nextIdx = 1 end
            end
        end
    else
        if cur <= 1 then
            if lower <= upper and upper >= 2 then
                nextIdx = upper
            else
                nextIdx = 1
            end
        else
            if lower > upper or cur <= lower then
                nextIdx = 1
            else
                nextIdx = cur - 1
                if nextIdx < lower then nextIdx = 1 end
            end
        end
    end

    setMipmapLevelIndex(level, nextIdx)
    normalizeMipmapRanges()
end

function normalizeMipmapRanges()
    if not MIPMAP_DIST_PRESETS or #MIPMAP_DIST_PRESETS == 0 then return end
    local maxIdx = getMipmapMaxPresetIndexForDrawDist()
    local idx1 = clampInt(MIPMAP1_DIST_INDEX or 1, 1, maxIdx)
    local idx2 = clampInt(MIPMAP2_DIST_INDEX or 1, 1, maxIdx)
    local idx3 = clampInt(MIPMAP3_DIST_INDEX or 1, 1, maxIdx)
    local idx4 = clampInt(MIPMAP4_DIST_INDEX or 1, 1, maxIdx)

    local indices = {idx1, idx2, idx3, idx4}
    local prevActive = 1
    for i = 1, 4 do
        local cur = indices[i]
        if cur > 1 then
            if cur <= prevActive then
                local nextValid = prevActive + 1
                if nextValid <= maxIdx then
                    cur = nextValid
                else
                    cur = 1
                end
                indices[i] = cur
            end
            if cur > 1 then
                prevActive = cur
            end
        end
    end

    MIPMAP1_DIST_INDEX = indices[1]
    MIPMAP2_DIST_INDEX = indices[2]
    MIPMAP3_DIST_INDEX = indices[3]
    MIPMAP4_DIST_INDEX = indices[4]

    WALL_MIPMAP_DIST1 = (MIPMAP1_DIST_INDEX > 1) and (MIPMAP_DIST_PRESETS[MIPMAP1_DIST_INDEX] or 0) or 0
    WALL_MIPMAP_DIST2 = (MIPMAP2_DIST_INDEX > 1) and (MIPMAP_DIST_PRESETS[MIPMAP2_DIST_INDEX] or 0) or 0
    WALL_MIPMAP_DIST3 = (MIPMAP3_DIST_INDEX > 1) and (MIPMAP_DIST_PRESETS[MIPMAP3_DIST_INDEX] or 0) or 0
    WALL_MIPMAP_DIST4 = (MIPMAP4_DIST_INDEX > 1) and (MIPMAP_DIST_PRESETS[MIPMAP4_DIST_INDEX] or 0) or 0
end

function normalizeFarTextureCutoff()
    if not FAR_TEX_OFF_PRESETS or #FAR_TEX_OFF_PRESETS == 0 then
        FAR_TEX_OFF_INDEX = 1
        FAR_TEX_OFF_DIST = 999
        return
    end
    FAR_TEX_OFF_INDEX = clampInt(FAR_TEX_OFF_INDEX or #FAR_TEX_OFF_PRESETS, 1, #FAR_TEX_OFF_PRESETS)
    FAR_TEX_OFF_DIST = FAR_TEX_OFF_PRESETS[FAR_TEX_OFF_INDEX]
end

function markPerfQualityCustom()
    PERF_QUALITY_INDEX = 0
end

function applyPerfQualityPreset(newIndex)
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

    normalizeDrawDistanceSetting()
    if FOG_DITHER_SIZE_PRESETS and #FOG_DITHER_SIZE_PRESETS > 0 then
        FOG_DITHER_SIZE_INDEX = clampInt(FOG_DITHER_SIZE_INDEX or 1, 1, #FOG_DITHER_SIZE_PRESETS)
        FOG_DITHER_SIZE = FOG_DITHER_SIZE_PRESETS[FOG_DITHER_SIZE_INDEX]
    end
    normalizeFarTextureCutoff()
    normalizeMipmapRanges()
    refreshExpViewDistance()
end

function getBaseEffectiveRayPresetIndex(baseIdx)
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

function getEffectiveRayPresetIndex(baseIdx)
    return getBaseEffectiveRayPresetIndex(baseIdx)
end

normalizeFogRange()
normalizeDrawDistanceSetting()
normalizeMipmapRanges()
normalizeFarTextureCutoff()
refreshExpViewDistance()
bootstrapExpansionDataLayer()

function isExpRenderer()
    return true
end
gameOverSelection = 1  -- 1 = Restart, 2 = Menu, 3 = Quit
RUN_HIGHSCORE_MAX_ENTRIES = 10
gameOverInitialsActive = false
gameOverInitialsCursor = 1
gameOverInitialsChars = {"A", "A", "A"}
gameOverScoreQualified = false
gameOverScoreSubmitted = false
gameOverScoreStatus = ""
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
function loadingLog(msg)
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
CHEST_HIT_RANGE = 1.05
CHEST_HIT_RANGE_SQ = CHEST_HIT_RANGE * CHEST_HIT_RANGE
PROJECTILE_CHEST_HIT_RADIUS = 0.34
PROJECTILE_CHEST_HIT_RADIUS_SQ = PROJECTILE_CHEST_HIT_RADIUS * PROJECTILE_CHEST_HIT_RADIUS
ITEM_PICKUP_RANGE = 0.78
ITEM_PICKUP_RANGE_SQ = ITEM_PICKUP_RANGE * ITEM_PICKUP_RANGE
LOOT_FEED_DURATION_TICKS = SIM_TARGET_HZ * 2

function isEnemyType(t)
    return t == 5 or t == 6
end

function isPropType(t)
    return (t and t >= 1 and t <= 4) or t == 7
end

-- Enemy health system
ENEMY_MAX_HP = 100
PLAYER_DAMAGE = 20
PLAYER_DEFENSE = 0
PLAYER_SHIELD_BONUS_PERCENT = 0
PLAYER_DODGE_PERCENT = 0
PLAYER_CRIT_PERCENT = 0
PLAYER_CRIT_MULT = 1.5
PLAYER_ATTACK_SPEED_SCALE = 1.0
PLAYER_ATTACK_MIN_FRAMES = 5
PLAYER_ATTACK_MAX_FRAMES = 18
PLAYER_MOVE_SPEED_SCALE = 1.0
PLAYER_REGEN_PER_SEC = 0.0
PLAYER_ATTACK_RANGE = 1.0  -- Distance player can hit enemy
PROJECTILE_SPEED_RANGED = 10.0     -- Units/sec
PROJECTILE_SPEED_MAGIC = 8.5       -- Units/sec
PROJECTILE_LIFETIME_TICKS = math.floor((SIM_TARGET_HZ or 24) * 2.5)
PROJECTILE_STEP = 0.12
PROJECTILE_HIT_RADIUS = 0.30
PROJECTILE_WALL_RADIUS = 0.05
PROJECTILE_MAX_ACTIVE = 24
PROJECTILE_MAX_RANGE_RANGED = 4.0
PROJECTILE_MAX_RANGE_MAGIC = 5.0

-- Bow charge tiers are data-driven for easy expansion.
-- Add entries to these arrays to extend beyond 3 tiers.
BOW_CHARGE_STAGE_HOLD_TICKS = {0, 10, 22}
BOW_CHARGE_STAGE_DAMAGE_MULT = {0.85, 1.10, 1.35}
BOW_CHARGE_STAGE_RANGE_MULT = {0.75, 1.00, 1.20}
BOW_CHARGE_STAGE_SPEED_MULT = {0.95, 1.00, 1.10}
BOW_CHARGE_INITIAL_IDLE_TICKS = 2
BOW_CHARGE_STAGE_FLASH_TICKS = 3
soldiersKilled = 0
local totalSoldiers = 5
PLAYER_LEVEL_MAX = 50
PLAYER_XP_BASE = 100
PLAYER_XP_STEP = 45
PLAYER_XP_QUAD = 6
PLAYER_XP_PER_KILL = 40
PLAYER_STAT_POINTS_PER_LEVEL = 2
BUILD_STAT_MAX = 99
VITALITY_HP_BONUS = 10
STRENGTH_DAMAGE_BONUS = 2
DEXTERITY_DODGE_BONUS = 1.0
DEXTERITY_AGILITY_BONUS = 0.5
INTELLECT_POWER_BONUS = 1.0
INTELLECT_CRIT_BONUS = 0.5
PLAYER_MASTERY_POINTS_PER_LEVEL = 1
WEAPON_MASTERY_CAP = 10
WEAPON_BASELINE_POINTS = 5
WEAPON_DAMAGE_PER_POINT = 0.025
WEAPON_SPEED_PER_POINT = 0.02

WEAPON_CLASS_MELEE = 1
WEAPON_CLASS_RANGED = 2
WEAPON_CLASS_MAGIC = 3
WEAPON_CLASS_LABELS = {
    [WEAPON_CLASS_MELEE] = "MELEE",
    [WEAPON_CLASS_RANGED] = "RANGED",
    [WEAPON_CLASS_MAGIC] = "MAGIC",
}
WEAPON_CLASS_PRIMARY_TEXT_TO_VALUE = {
    melee = WEAPON_CLASS_MELEE,
    ranged = WEAPON_CLASS_RANGED,
    magic = WEAPON_CLASS_MAGIC,
}

SAVE_SLOT_COUNT = 3
SAVE_FILE_PATH = "/sdcard/inner_sanctum/saves.dat"
SAVE_FILE_HEADER = "INNER_SANCTUM_SAVE_V1"
saveSlots = {}
CLASS_FALLBACK_ORDER = {"warrior", "archer", "mage"}
CLASS_SELECT_PORTRAIT_PATHS = {
    warrior = "sprites/WAARRIOR-CHAR-SELECT-sized",
    archer = "sprites/ARCH-CHAR-SELECT-sized",
    mage = "sprites/WIZ-CHAR-SELECT-sized",
}
CLASS_FALLBACKS = {
    warrior = {
        id = "warrior",
        name = "Warrior",
        base_hp = 120,
        base_damage = 20,
        base_speed = 1.0,
        primary = "melee",
        base_defense = 4.00,
        template_stats = {
            agility = 4.00,
            power = 4.00,
            defense = 4.00,
            dodge = 4.00,
            regen = 4.00,
            crit = 4.00,
            atk_speed = 4.00,
            shield_bonus = 4.00,
        },
        growth = {hp = 8, damage = 2, speed = 0.0},
    },
    archer = {
        id = "archer",
        name = "Archer",
        base_hp = 90,
        base_damage = 14,
        base_speed = 1.15,
        primary = "ranged",
        base_defense = 2.50,
        template_stats = {
            agility = 5.50,
            power = 3.75,
            defense = 2.50,
            dodge = 5.00,
            regen = 2.50,
            crit = 3.50,
            atk_speed = 5.50,
            shield_bonus = 2.00,
        },
        growth = {hp = 5, damage = 2, speed = 0.01},
    },
    mage = {
        id = "mage",
        name = "Mage",
        base_hp = 80,
        base_damage = 18,
        base_speed = 1.05,
        primary = "magic",
        base_defense = 2.25,
        template_stats = {
            agility = 2.75,
            power = 5.75,
            defense = 2.25,
            dodge = 2.50,
            regen = 2.25,
            crit = 5.25,
            atk_speed = 2.75,
            shield_bonus = 1.75,
        },
        growth = {hp = 4, damage = 3, speed = 0.0},
    },
}

function getClassDefById(classId)
    local fallbackId = CLASS_FALLBACK_ORDER[1] or "warrior"
    if getGameClass then
        local classDef = getGameClass(classId or fallbackId)
        if classDef and classDef.id then
            return classDef
        end
    end
    local id = classId or fallbackId
    if not CLASS_FALLBACKS[id] then
        id = fallbackId
    end
    return CLASS_FALLBACKS[id]
end

function getClassOrder()
    if GameClassOrder and #GameClassOrder > 1 then
        return GameClassOrder
    end
    return CLASS_FALLBACK_ORDER
end

function sanitizeClassId(classId)
    local classDef = getClassDefById(classId)
    if classDef and classDef.id then
        return classDef.id
    end
    return CLASS_FALLBACK_ORDER[1] or "warrior"
end

function markPlayerBuildStateDirty()
    playerBuildStateDirty = true
end

function ensurePlayerBuildState()
    if not player_build_state then
        player_build_state = {}
        playerBuildStateDirty = true
    elseif not playerBuildStateDirty then
        return player_build_state
    end

    if not player_build_state.class_id or player_build_state.class_id == "" then
        player_build_state.class_id = sanitizeClassId(nil)
    else
        player_build_state.class_id = sanitizeClassId(player_build_state.class_id)
    end

    local level = math.floor(tonumber(player_build_state.level) or 1)
    if level < 1 then level = 1 end
    if level > (PLAYER_LEVEL_MAX or 50) then level = (PLAYER_LEVEL_MAX or 50) end
    player_build_state.level = level

    local xp = math.floor(tonumber(player_build_state.xp) or 0)
    if xp < 0 then xp = 0 end
    player_build_state.xp = xp

    local statPoints = math.floor(tonumber(player_build_state.stat_points) or 0)
    if statPoints < 0 then statPoints = 0 end
    player_build_state.stat_points = statPoints

    local masteryPoints = math.floor(tonumber(player_build_state.weapon_mastery_points) or 0)
    if masteryPoints < 0 then masteryPoints = 0 end
    player_build_state.weapon_mastery_points = masteryPoints

    if type(player_build_state.stats) ~= "table" then
        player_build_state.stats = {}
    end
    local statKeys = {"vitality", "strength", "dexterity", "intellect"}
    for i = 1, #statKeys do
        local key = statKeys[i]
        local value = math.floor(tonumber(player_build_state.stats[key]) or 0)
        if value < 0 then value = 0 end
        if value > (BUILD_STAT_MAX or 99) then value = (BUILD_STAT_MAX or 99) end
        player_build_state.stats[key] = value
    end

    if type(player_build_state.weapon_mastery) ~= "table" then
        player_build_state.weapon_mastery = {}
    end
    local mastery = player_build_state.weapon_mastery
    -- Backward-compatible migration if older sessions used string keys.
    if mastery[WEAPON_CLASS_MELEE] == nil and mastery["melee"] ~= nil then
        mastery[WEAPON_CLASS_MELEE] = mastery["melee"]
    end
    if mastery[WEAPON_CLASS_RANGED] == nil and mastery["ranged"] ~= nil then
        mastery[WEAPON_CLASS_RANGED] = mastery["ranged"]
    end
    if mastery[WEAPON_CLASS_MAGIC] == nil and mastery["magic"] ~= nil then
        mastery[WEAPON_CLASS_MAGIC] = mastery["magic"]
    end

    local masteryKeys = {WEAPON_CLASS_MELEE, WEAPON_CLASS_RANGED, WEAPON_CLASS_MAGIC}
    for i = 1, #masteryKeys do
        local key = masteryKeys[i]
        local value = math.floor(tonumber(mastery[key]) or 0)
        if value < 0 then value = 0 end
        if value > (WEAPON_MASTERY_CAP or 10) then value = (WEAPON_MASTERY_CAP or 10) end
        mastery[key] = value
    end

    if type(player_build_state.equipment) ~= "table" then
        player_build_state.equipment = {}
    end
    if player_build_state.equipment.weapon == "" then player_build_state.equipment.weapon = nil end
    if player_build_state.equipment.armor == "" then player_build_state.equipment.armor = nil end
    if player_build_state.equipment.special_1 == "" then player_build_state.equipment.special_1 = nil end
    if player_build_state.equipment.special_2 == "" then player_build_state.equipment.special_2 = nil end

    playerBuildStateDirty = false
    return player_build_state
end

function getBuildStatValue(statKey)
    local state = ensurePlayerBuildState()
    if not state.stats then
        return 0
    end
    local value = math.floor(tonumber(state.stats[statKey]) or 0)
    if value < 0 then value = 0 end
    return value
end

function getXpRequiredForLevel(level)
    local lvl = math.floor(tonumber(level) or 1)
    if lvl < 1 then lvl = 1 end
    local idx = lvl - 1
    return (PLAYER_XP_BASE or 100) + (idx * (PLAYER_XP_STEP or 45)) + (idx * idx * (PLAYER_XP_QUAD or 6))
end

function getPlayerLevel()
    local state = ensurePlayerBuildState()
    return math.floor(tonumber(state.level) or 1)
end

function getPlayerXp()
    local state = ensurePlayerBuildState()
    return math.floor(tonumber(state.xp) or 0)
end

function getPlayerXpForNextLevel()
    local level = getPlayerLevel()
    if level >= (PLAYER_LEVEL_MAX or 50) then
        return 0
    end
    return getXpRequiredForLevel(level)
end

function normalizeWeaponClass(value)
    if value == WEAPON_CLASS_MELEE then return WEAPON_CLASS_MELEE end
    if value == WEAPON_CLASS_RANGED then return WEAPON_CLASS_RANGED end
    if value == WEAPON_CLASS_MAGIC then return WEAPON_CLASS_MAGIC end
    local text = tostring(value or "")
    local mapped = WEAPON_CLASS_PRIMARY_TEXT_TO_VALUE[text]
    if mapped then
        return mapped
    end
    return WEAPON_CLASS_MELEE
end

function getWeaponMasteryLevel(weaponClass)
    local state = ensurePlayerBuildState()
    local key = normalizeWeaponClass(weaponClass)
    local mastery = state.weapon_mastery or {}
    local value = math.floor(tonumber(mastery[key]) or 0)
    if value < 0 then value = 0 end
    if value > (WEAPON_MASTERY_CAP or 10) then value = (WEAPON_MASTERY_CAP or 10) end
    return value
end

function getWeaponBasePointsForClass(classId, weaponClass)
    local classDef = getClassDefById(classId)
    local primary = normalizeWeaponClass(classDef and classDef.primary)
    local target = normalizeWeaponClass(weaponClass)
    if primary == target then
        -- Bonus points for the class's "native" weapon class.
        -- These points are free and do NOT consume the 0..10 player mastery cap.
        return WEAPON_BASELINE_POINTS or 5
    end
    return 0
end

function computeWeaponProficiencyMultipliers(classId, weaponClass)
    -- All classes start at 100% effectiveness for all weapon classes.
    -- The class's primary weapon class gets +WEAPON_BASELINE_POINTS "bonus points" on top.
    local bonusPoints = getWeaponBasePointsForClass(classId, weaponClass)
    local masteryPoints = getWeaponMasteryLevel(weaponClass)
    local effective = bonusPoints + masteryPoints
    local damageMult = 1.0 + (effective * (WEAPON_DAMAGE_PER_POINT or 0.025))
    local speedMult = 1.0 + (effective * (WEAPON_SPEED_PER_POINT or 0.02))
    if damageMult < 1.00 then damageMult = 1.00 end
    if damageMult > 1.50 then damageMult = 1.50 end
    if speedMult < 1.00 then speedMult = 1.00 end
    if speedMult > 1.40 then speedMult = 1.40 end
    return damageMult, speedMult, effective
end

function getEquippedWeaponId()
    local state = ensurePlayerBuildState()
    local eq = state and state.equipment
    if type(eq) ~= "table" then
        return nil
    end
    local id = eq.weapon
    if id == "" then id = nil end
    return id
end

function getWeaponClassForItem(itemId)
    if not itemId or itemId == "" then
        return WEAPON_CLASS_MELEE
    end
    if not getGameItem then
        return WEAPON_CLASS_MELEE
    end
    local item = getGameItem(itemId)
    if not item then
        return WEAPON_CLASS_MELEE
    end
    return normalizeWeaponClass(item.weapon_class)
end

function getEquippedWeaponClass()
    local weaponId = getEquippedWeaponId()
    if weaponId and weaponId ~= "" then
        return getWeaponClassForItem(weaponId)
    end
    local classDef = getClassDefById(getCurrentClassId())
    return normalizeWeaponClass(classDef and classDef.primary)
end

function getSignedEquippedWeaponStat(statKey)
    local weaponId = getEquippedWeaponId()
    if not weaponId or weaponId == "" then
        return 0
    end
    if not getGameItem then
        return 0
    end
    local item = getGameItem(weaponId)
    local stats = item and item.stats
    local value = tonumber(stats and stats[statKey]) or 0
    if value < -10 then value = -10 end
    if value > 10 then value = 10 end
    return value
end

function ensureInventoryState()
    if type(inventory_state) ~= "table" then
        inventory_state = {
            max_weight = 30,
            current_weight = 0,
            items = {},
            quick_slots = {nil, nil, nil},
        }
    end
    if type(inventory_state.items) ~= "table" then
        inventory_state.items = {}
    end
    if type(inventory_state.quick_slots) ~= "table" then
        inventory_state.quick_slots = {nil, nil, nil}
    end
    local maxWeight = tonumber(inventory_state.max_weight) or 30
    if maxWeight < 1 then maxWeight = 1 end
    inventory_state.max_weight = maxWeight
    local curWeight = tonumber(inventory_state.current_weight) or 0
    if curWeight < 0 then curWeight = 0 end
    inventory_state.current_weight = curWeight
    return inventory_state
end

function recalcInventoryWeight()
    local inv = ensureInventoryState()
    local total = 0.0
    for i = 1, #inv.items do
        local entry = inv.items[i]
        local item = getGameItem and getGameItem(entry and entry.id or nil)
        local weight = tonumber(item and item.weight) or 0
        if weight < 0 then weight = 0 end
        local count = math.floor(tonumber(entry and entry.count) or 0)
        if count < 0 then count = 0 end
        total = total + (weight * count)
    end
    inv.current_weight = total
    return total
end

function ensureStashState()
    if type(stash_state) ~= "table" then
        stash_state = {
            max_weight = 120,
            current_weight = 0,
            items = {},
        }
    end
    if type(stash_state.items) ~= "table" then
        stash_state.items = {}
    end
    local maxWeight = tonumber(stash_state.max_weight) or 120
    if maxWeight < 1 then maxWeight = 1 end
    stash_state.max_weight = maxWeight
    local curWeight = tonumber(stash_state.current_weight) or 0
    if curWeight < 0 then curWeight = 0 end
    stash_state.current_weight = curWeight
    return stash_state
end

function recalcStashWeight()
    local stash = ensureStashState()
    local total = 0.0
    for i = 1, #stash.items do
        local entry = stash.items[i]
        local item = getGameItem and getGameItem(entry and entry.id or nil)
        local weight = tonumber(item and item.weight) or 0
        if weight < 0 then weight = 0 end
        local count = math.floor(tonumber(entry and entry.count) or 0)
        if count < 0 then count = 0 end
        total = total + (weight * count)
    end
    stash.current_weight = total
    return total
end

function truncateUiLabel(text, maxChars)
    local src = tostring(text or "")
    local n = math.floor(tonumber(maxChars) or 0)
    if n <= 0 then
        return ""
    end
    if #src <= n then
        return src
    end
    if n <= 3 then
        return string.sub(src, 1, n)
    end
    return string.sub(src, 1, n - 3) .. "..."
end

function buildInventoryUiRows(tabIndex)
    local tab = math.floor(tonumber(tabIndex) or 1)
    if tab < 1 then tab = 1 end
    if tab > #INVENTORY_MENU_TABS then tab = #INVENTORY_MENU_TABS end

    local rows = {}
    local heading = "INVENTORY"
    local carryCur = 0
    local carryMax = 0
    local sourceItems = nil

    if tab == 1 then
        local inv = ensureInventoryState()
        recalcInventoryWeight()
        heading = "INVENTORY"
        carryCur = tonumber(inv.current_weight) or 0
        carryMax = tonumber(inv.max_weight) or 30
        sourceItems = inv.items
    elseif tab == 2 then
        local stash = ensureStashState()
        recalcStashWeight()
        heading = "STASH"
        carryCur = tonumber(stash.current_weight) or 0
        carryMax = tonumber(stash.max_weight) or 120
        sourceItems = stash.items
    elseif tab == 3 then
        heading = "EQUIPMENT"
        local build = ensurePlayerBuildState()
        local eq = (build and build.equipment) or {}
        local slots = {
            {"WEAPON", eq.weapon},
            {"ARMOR", eq.armor},
            {"SPECIAL 1", eq.special_1},
            {"SPECIAL 2", eq.special_2},
        }
        for i = 1, #slots do
            local slotLabel = slots[i][1]
            local itemId = slots[i][2]
            local item = getGameItem and getGameItem(itemId) or nil
            local itemName = item and item.name or "EMPTY"
            rows[#rows + 1] = {
                label = slotLabel,
                detail = itemName,
                kind = item and item.kind or "slot",
                item = item,
                count = item and 1 or 0,
            }
        end
        local inv = ensureInventoryState()
        recalcInventoryWeight()
        carryCur = tonumber(inv.current_weight) or 0
        carryMax = tonumber(inv.max_weight) or 30
    else
        heading = "TRADER"
        local scoreValue = getCurrentRunScoreValue and getCurrentRunScoreValue() or 0
        local tier = getTraderTierForScore and getTraderTierForScore(scoreValue) or nil
        local items = tier and tier.items or {}
        for i = 1, #items do
            local itemId = items[i]
            local item = getGameItem and getGameItem(itemId) or nil
            rows[#rows + 1] = {
                id = itemId,
                label = item and item.name or tostring(itemId or "ITEM"),
                detail = string.upper(tostring(item and item.kind or "ITEM")) .. "  V:" .. tostring(math.floor(tonumber(item and item.value) or 0)),
                kind = item and item.kind or "item",
                item = item,
                count = 1,
            }
        end
        local inv = ensureInventoryState()
        recalcInventoryWeight()
        carryCur = tonumber(inv.current_weight) or 0
        carryMax = tonumber(inv.max_weight) or 30
    end

    if sourceItems then
        local indexById = {}
        for i = 1, #sourceItems do
            local entry = sourceItems[i]
            local itemId = entry and entry.id
            local itemCount = math.floor(tonumber(entry and entry.count) or 0)
            if itemId and itemId ~= "" and itemCount > 0 then
                local slot = indexById[itemId]
                if not slot then
                    local item = getGameItem and getGameItem(itemId) or nil
                    slot = #rows + 1
                    indexById[itemId] = slot
                    rows[slot] = {
                        id = itemId,
                        label = item and item.name or tostring(itemId),
                        detail = string.upper(tostring(item and item.kind or "ITEM")) .. "  V:" .. tostring(math.floor(tonumber(item and item.value) or 0)),
                        kind = item and item.kind or "item",
                        item = item,
                        count = 0,
                    }
                end
                rows[slot].count = (rows[slot].count or 0) + itemCount
            end
        end
    end

    table.sort(rows, function(a, b)
        local ka = tostring(a and a.kind or "")
        local kb = tostring(b and b.kind or "")
        if ka == kb then
            return tostring(a and a.label or "") < tostring(b and b.label or "")
        end
        return ka < kb
    end)

    return rows, heading, carryCur, carryMax
end

function getInventoryUiPageBounds(totalRows, selectedIndex)
    local rowsPerPage = INVENTORY_MENU_ROWS_PER_PAGE or 12
    if rowsPerPage < 1 then rowsPerPage = 1 end
    local total = math.floor(tonumber(totalRows) or 0)
    if total < 0 then total = 0 end
    local sel = math.floor(tonumber(selectedIndex) or 1)
    if sel < 1 then sel = 1 end
    if total <= 0 then
        sel = 1
    elseif sel > total then
        sel = total
    end
    local page = math.floor((sel - 1) / rowsPerPage) + 1
    local startIdx = ((page - 1) * rowsPerPage) + 1
    local endIdx = startIdx + rowsPerPage - 1
    if total > 0 and endIdx > total then endIdx = total end
    return page, startIdx, endIdx, sel
end

function setLootFeedMessage(messageText)
    lootFeedMessage = tostring(messageText or "")
    if lootFeedMessage == "" then
        lootFeedMessageTimer = 0
    else
        lootFeedMessageTimer = LOOT_FEED_DURATION_TICKS or (SIM_TARGET_HZ * 2)
    end
end

function formatLootItemName(itemId)
    local item = getGameItem and getGameItem(itemId) or nil
    local label = tostring((item and item.name) or itemId or "ITEM")
    return string.upper(label)
end

function tryAddItemToInventory(itemId, count)
    local item = getGameItem and getGameItem(itemId) or nil
    if not item then
        return false, "INVALID ITEM"
    end
    local addCount = math.floor(tonumber(count) or 1)
    if addCount < 1 then
        addCount = 1
    end

    local inv = ensureInventoryState()
    local unitWeight = tonumber(item.weight) or 0
    if unitWeight < 0 then unitWeight = 0 end
    local currentWeight = tonumber(inv.current_weight) or recalcInventoryWeight()
    local maxWeight = tonumber(inv.max_weight) or 30
    local addWeight = unitWeight * addCount
    if (currentWeight + addWeight) > (maxWeight + 0.0001) then
        return false, "TOO HEAVY"
    end

    local maxStack = math.floor(tonumber(item.stack_max) or 1)
    if maxStack < 1 then
        maxStack = 1
    end

    local remaining = addCount
    if maxStack > 1 then
        for i = 1, #inv.items do
            local entry = inv.items[i]
            if entry and entry.id == itemId then
                local current = math.floor(tonumber(entry.count) or 0)
                if current < maxStack then
                    local capacity = maxStack - current
                    local fill = remaining
                    if fill > capacity then fill = capacity end
                    entry.count = current + fill
                    remaining = remaining - fill
                    if remaining <= 0 then
                        break
                    end
                end
            end
        end
    end

    while remaining > 0 do
        local stackCount = remaining
        if stackCount > maxStack then stackCount = maxStack end
        inv.items[#inv.items + 1] = {
            id = itemId,
            count = stackCount,
        }
        remaining = remaining - stackCount
    end

    inv.current_weight = currentWeight + addWeight
    return true, nil
end

function spawnWorldItemDrop(worldX, worldY, itemId)
    if not sprites or not itemId then
        return false
    end
    local sx = tonumber(worldX) or 0
    local sy = tonumber(worldY) or 0
    sprites[#sprites + 1] = {
        x = sx,
        y = sy,
        t = 8,
        item_id = itemId,
        collected = false,
        spawn_tick = simTickCount or 0,
    }
    return true
end

function openChestWithLoot(chestSprite, salt)
    if not chestSprite or chestSprite.t ~= 4 or chestSprite.opened then
        return false
    end

    chestSprite.opened = true
    chestSprite.open_tick = simTickCount or 0
    dispatchRunScoreEvent("chest_open", {level_id = currentLevel})

    local classId = getCurrentClassId()
    local baseSeed = (run_seed or 0) + math.floor((tonumber(chestSprite.x) or 0) * 100) + (math.floor((tonumber(chestSprite.y) or 0) * 100) * 37)
    local itemId = nil
    if rollChestDrop then
        itemId = rollChestDrop(currentLevel, classId, baseSeed + math.floor(tonumber(salt) or 0))
    end

    if itemId and spawnWorldItemDrop(chestSprite.x, chestSprite.y, itemId) then
        setLootFeedMessage("CHEST LOOT: " .. formatLootItemName(itemId))
    else
        setLootFeedMessage("CHEST EMPTY")
    end
    return true
end

function tryBreakChestInRange(rangeSq)
    if not sprites or #sprites == 0 then
        return false
    end
    local maxDistSq = tonumber(rangeSq) or CHEST_HIT_RANGE_SQ
    if maxDistSq <= 0 then
        maxDistSq = CHEST_HIT_RANGE_SQ
    end
    local dir = pdir % 64
    local facingX = cosTable[dir] or 0
    local facingY = sinTable[dir] or 0
    local bestIndex = -1
    local bestDistSq = maxDistSq + 1
    for i = 1, #sprites do
        local s = sprites[i]
        if s and s.t == 4 and not s.opened then
            local dx = (s.x or 0) - px
            local dy = (s.y or 0) - py
            local distSq = (dx * dx) + (dy * dy)
            if distSq <= maxDistSq then
                local inFront = (dx * facingX + dy * facingY) >= -0.05
                if inFront and distSq < bestDistSq then
                    bestDistSq = distSq
                    bestIndex = i
                end
            end
        end
    end
    if bestIndex > 0 then
        return openChestWithLoot(sprites[bestIndex], (bestIndex * 193) + (simTickCount or 0))
    end
    return false
end

function tryHitChestWithProjectile(projectile, hitX, hitY)
    if not sprites or #sprites == 0 then
        return false
    end
    local hitRadiusSq = PROJECTILE_CHEST_HIT_RADIUS_SQ or 0.1156
    for i = 1, #sprites do
        local s = sprites[i]
        if s and s.t == 4 and not s.opened then
            local dx = (hitX or 0) - (s.x or 0)
            local dy = (hitY or 0) - (s.y or 0)
            if ((dx * dx) + (dy * dy)) <= hitRadiusSq then
                local salt = ((projectile and projectile.id) or 0) * 151 + i * 211 + (simTickCount or 0)
                openChestWithLoot(s, salt)
                return true
            end
        end
    end
    return false
end

function getBowChargeTierCount()
    local n = #BOW_CHARGE_STAGE_HOLD_TICKS
    if n < 1 then n = 1 end
    return n
end

function resetBowChargeState()
    bowChargeState.active = false
    bowChargeState.ticks = 0
    bowChargeState.stage = 1
    bowChargeState.flashTicks = 0
    bowChargeState.stageThresholds = nil
    bowChargeState.damageMult = nil
    bowChargeState.rangeMult = nil
    bowChargeState.speedMult = nil
end

function beginBowCharge(profSpeedMult)
    local tierCount = getBowChargeTierCount()
    local speedStat = getSignedEquippedWeaponStat("stat_speed")
    local damageStat = getSignedEquippedWeaponStat("stat_damage")
    local rangeStat = getSignedEquippedWeaponStat("stat_range")

    local profSpeed = tonumber(profSpeedMult) or 1.0
    if profSpeed < 0.20 then profSpeed = 0.20 end
    if profSpeed > 3.00 then profSpeed = 3.00 end

    local holdScale = (1.0 / profSpeed) * (1.0 - (speedStat * 0.03))
    if holdScale < 0.55 then holdScale = 0.55 end
    if holdScale > 1.60 then holdScale = 1.60 end

    local itemDamageMult = 1.0 + (damageStat * 0.035)
    local itemRangeMult = 1.0 + (rangeStat * 0.05)
    local itemSpeedMult = 1.0 + (speedStat * 0.02)
    if itemDamageMult < 0.65 then itemDamageMult = 0.65 end
    if itemDamageMult > 1.45 then itemDamageMult = 1.45 end
    if itemRangeMult < 0.60 then itemRangeMult = 0.60 end
    if itemRangeMult > 1.60 then itemRangeMult = 1.60 end
    if itemSpeedMult < 0.70 then itemSpeedMult = 0.70 end
    if itemSpeedMult > 1.40 then itemSpeedMult = 1.40 end

    local thresholds = {}
    local dmg = {}
    local rng = {}
    local spd = {}
    local lastThreshold = 0
    for i = 1, tierCount do
        local baseTicks = tonumber(BOW_CHARGE_STAGE_HOLD_TICKS[i]) or 0
        local scaledTicks = math.floor((baseTicks * holdScale) + 0.5)
        if i == 1 then
            scaledTicks = 0
        elseif scaledTicks <= lastThreshold then
            scaledTicks = lastThreshold + 1
        end
        thresholds[i] = scaledTicks
        lastThreshold = scaledTicks

        dmg[i] = (tonumber(BOW_CHARGE_STAGE_DAMAGE_MULT[i]) or 1.0) * itemDamageMult
        rng[i] = (tonumber(BOW_CHARGE_STAGE_RANGE_MULT[i]) or 1.0) * itemRangeMult
        spd[i] = (tonumber(BOW_CHARGE_STAGE_SPEED_MULT[i]) or 1.0) * itemSpeedMult
    end

    bowChargeState.active = true
    bowChargeState.ticks = 0
    bowChargeState.stage = 1
    bowChargeState.flashTicks = 0
    bowChargeState.stageThresholds = thresholds
    bowChargeState.damageMult = dmg
    bowChargeState.rangeMult = rng
    bowChargeState.speedMult = spd
end

function updateBowChargeTick()
    if not bowChargeState.active then
        return
    end
    bowChargeState.ticks = (bowChargeState.ticks or 0) + 1
    if (bowChargeState.flashTicks or 0) > 0 then
        bowChargeState.flashTicks = bowChargeState.flashTicks - 1
    end

    local stage = bowChargeState.stage or 1
    local thresholds = bowChargeState.stageThresholds
    if type(thresholds) == "table" then
        local tierCount = #thresholds
        while stage < tierCount and (bowChargeState.ticks >= (thresholds[stage + 1] or 99999)) do
            stage = stage + 1
            bowChargeState.flashTicks = BOW_CHARGE_STAGE_FLASH_TICKS or 3
        end
    end
    bowChargeState.stage = stage
end

function getBowChargeCurrentStage()
    local stage = math.floor(tonumber(bowChargeState.stage) or 1)
    local tierCount = getBowChargeTierCount()
    if stage < 1 then stage = 1 end
    if stage > tierCount then stage = tierCount end
    return stage
end

function isBowChargeDrawnVisual()
    if not bowChargeState.active then
        return false
    end
    if (bowChargeState.ticks or 0) <= (BOW_CHARGE_INITIAL_IDLE_TICKS or 2) then
        return false
    end
    if (bowChargeState.flashTicks or 0) > 0 then
        return false
    end
    return true
end

function allocateWeaponMastery(weaponClass)
    local state = ensurePlayerBuildState()
    local key = normalizeWeaponClass(weaponClass)
    local current = getWeaponMasteryLevel(key)
    if current >= (WEAPON_MASTERY_CAP or 10) then
        return false, "MASTERY MAXED"
    end
    local points = math.floor(tonumber(state.weapon_mastery_points) or 0)
    if points <= 0 then
        return false, "NO MASTERY PTS"
    end
    state.weapon_mastery_points = points - 1
    state.weapon_mastery[key] = current + 1
    markPlayerBuildStateDirty()
    refreshClassGameplayStats(false)
    return true, nil
end

function getCurrentClassId()
    local state = ensurePlayerBuildState()
    return sanitizeClassId(state.class_id)
end

function setCurrentClassId(classId)
    local state = ensurePlayerBuildState()
    local normalized = sanitizeClassId(classId)
    state.class_id = normalized
    markPlayerBuildStateDirty()
    if refreshClassGameplayStats then
        refreshClassGameplayStats(false)
    end
    return normalized
end

function getClassName(classId)
    local classDef = getClassDefById(classId)
    if classDef and classDef.name then
        return classDef.name
    end
    return "Warrior"
end

function getClassTemplateStats(classId, classDef)
    local source = classDef or getClassDefById(classId)
    if source and source.template_stats then
        return source.template_stats
    end
    local fallbackId = sanitizeClassId(classId)
    local fallbackDef = CLASS_FALLBACKS[fallbackId] or CLASS_FALLBACKS[CLASS_FALLBACK_ORDER[1] or "warrior"]
    if fallbackDef and fallbackDef.template_stats then
        return fallbackDef.template_stats
    end
    return {
        agility = 4.00,
        power = 4.00,
        defense = 4.00,
        dodge = 4.00,
        regen = 4.00,
        crit = 4.00,
        atk_speed = 4.00,
        shield_bonus = 4.00,
    }
end

function getClassSelectionIndexForId(classId)
    local order = getClassOrder()
    local normalized = sanitizeClassId(classId)
    for i = 1, #order do
        if order[i] == normalized then
            return i
        end
    end
    return 1
end

function getClassIdForSelection(index)
    local order = getClassOrder()
    local count = #order
    if count <= 0 then
        return "warrior", 1, 1
    end
    local idx = math.floor(index or 1)
    if idx < 1 then idx = count end
    if idx > count then idx = 1 end
    return order[idx], idx, count
end

function refreshClassGameplayStats(resetHealthToMax)
    local state = ensurePlayerBuildState()
    local classId = getCurrentClassId()
    local classDef = getClassDefById(classId)
    local template = getClassTemplateStats(classId, classDef)
    local growth = classDef and classDef.growth or nil

    local classHp = tonumber(classDef and classDef.base_hp) or 100
    local classDamage = tonumber(classDef and classDef.base_damage) or 20
    local classBaseSpeed = tonumber(classDef and classDef.base_speed) or 1.0
    local growthHp = tonumber(growth and growth.hp) or 0
    local growthDamage = tonumber(growth and growth.damage) or 0
    local growthSpeed = tonumber(growth and growth.speed) or 0
    local classPower = tonumber(template and template.power) or 0
    local classDefense = tonumber(template and template.defense) or 0
    local classShieldBonus = tonumber(template and template.shield_bonus) or 0
    local classDodge = tonumber(template and template.dodge) or 0
    local classCrit = tonumber(template and template.crit) or 0
    local classAtkSpeed = tonumber(template and template.atk_speed) or 4.0
    local classAgility = tonumber(template and template.agility) or 0
    local classRegen = tonumber(template and template.regen) or 0
    local level = math.floor(tonumber(state.level) or 1)
    local statVitality = getBuildStatValue("vitality")
    local statStrength = getBuildStatValue("strength")
    local statDexterity = getBuildStatValue("dexterity")
    local statIntellect = getBuildStatValue("intellect")

    if level < 1 then level = 1 end
    if level > (PLAYER_LEVEL_MAX or 50) then level = (PLAYER_LEVEL_MAX or 50) end
    local levelOffset = level - 1

    classHp = classHp + (growthHp * levelOffset) + (statVitality * (VITALITY_HP_BONUS or 10))
    classDamage = classDamage + (growthDamage * levelOffset) + (statStrength * (STRENGTH_DAMAGE_BONUS or 2))
    classPower = classPower + (statIntellect * (INTELLECT_POWER_BONUS or 1.0))
    classDefense = classDefense + (statVitality * 0.15)
    classShieldBonus = classShieldBonus + (statVitality * 0.1)
    classDodge = classDodge + (statDexterity * (DEXTERITY_DODGE_BONUS or 1.0))
    classCrit = classCrit + (statIntellect * (INTELLECT_CRIT_BONUS or 0.5))
    classAtkSpeed = classAtkSpeed + (growthSpeed * levelOffset * 4.0)
    classAgility = classAgility + (statDexterity * (DEXTERITY_AGILITY_BONUS or 0.5))
    classRegen = classRegen + (statVitality * 0.03)

    local moveBaseScale = classBaseSpeed + (growthSpeed * levelOffset)
    if moveBaseScale < 0.6 then moveBaseScale = 0.6 end
    if moveBaseScale > 2.0 then moveBaseScale = 2.0 end

    if classHp < 1 then classHp = 1 end
    if classDamage < 1 then classDamage = 1 end
    if classPower < -95 then classPower = -95 end
    if classPower > 500 then classPower = 500 end
    if classDefense < 0 then classDefense = 0 end
    if classShieldBonus < 0 then classShieldBonus = 0 end
    if classShieldBonus > 80 then classShieldBonus = 80 end
    if classDodge < 0 then classDodge = 0 end
    if classDodge > 100 then classDodge = 100 end
    if classCrit < 0 then classCrit = 0 end
    if classCrit > 100 then classCrit = 100 end
    if classAtkSpeed < 1.0 then classAtkSpeed = 1.0 end
    if classAtkSpeed > 12.0 then classAtkSpeed = 12.0 end
    if classAgility < -50 then classAgility = -50 end
    if classAgility > 100 then classAgility = 100 end
    if classRegen < 0 then classRegen = 0 end
    if classRegen > 20 then classRegen = 20 end

    MAX_HEALTH = math.floor(classHp + 0.5)
    PLAYER_DAMAGE = math.floor((classDamage * (1.0 + (classPower / 100.0))) + 0.5)
    if PLAYER_DAMAGE < 1 then PLAYER_DAMAGE = 1 end
    PLAYER_DEFENSE = math.floor(classDefense + 0.5)
    PLAYER_SHIELD_BONUS_PERCENT = classShieldBonus
    PLAYER_DODGE_PERCENT = classDodge
    PLAYER_CRIT_PERCENT = classCrit
    PLAYER_ATTACK_SPEED_SCALE = 4.0 / classAtkSpeed
    PLAYER_MOVE_SPEED_SCALE = moveBaseScale * (1.0 + (classAgility / 100.0))
    PLAYER_REGEN_PER_SEC = classRegen * 0.1
    if PLAYER_MOVE_SPEED_SCALE < 0.70 then PLAYER_MOVE_SPEED_SCALE = 0.70 end
    if PLAYER_MOVE_SPEED_SCALE > 2.00 then PLAYER_MOVE_SPEED_SCALE = 2.00 end
    if PLAYER_ATTACK_SPEED_SCALE < 0.5 then PLAYER_ATTACK_SPEED_SCALE = 0.5 end
    if PLAYER_ATTACK_SPEED_SCALE > 2.5 then PLAYER_ATTACK_SPEED_SCALE = 2.5 end

    if resetHealthToMax then
        playerHealth = MAX_HEALTH
    elseif playerHealth and playerHealth > MAX_HEALTH then
        playerHealth = MAX_HEALTH
    end
    playerRegenAccumulator = 0.0
end

function awardPlayerXp(amount)
    local state = ensurePlayerBuildState()
    local gain = math.floor(tonumber(amount) or 0)
    if gain <= 0 then
        return 0
    end

    local maxLevel = PLAYER_LEVEL_MAX or 50
    if state.level >= maxLevel then
        state.level = maxLevel
        state.xp = 0
        markPlayerBuildStateDirty()
        return 0
    end

    state.xp = state.xp + gain
    markPlayerBuildStateDirty()
    local levelUps = 0
    while state.level < maxLevel do
        local need = getXpRequiredForLevel(state.level)
        if state.xp < need then
            break
        end
        state.xp = state.xp - need
        state.level = state.level + 1
        state.stat_points = state.stat_points + (PLAYER_STAT_POINTS_PER_LEVEL or 2)
        state.weapon_mastery_points = (state.weapon_mastery_points or 0) + (PLAYER_MASTERY_POINTS_PER_LEVEL or 1)
        levelUps = levelUps + 1
    end

    if state.level >= maxLevel then
        state.level = maxLevel
        state.xp = 0
        markPlayerBuildStateDirty()
    end

    if levelUps > 0 then
        refreshClassGameplayStats(false)
        if playerHealth and playerHealth > MAX_HEALTH then
            playerHealth = MAX_HEALTH
        end
        statsMenuMessage = "LEVEL UP! +" .. tostring(levelUps * (PLAYER_STAT_POINTS_PER_LEVEL or 2)) .. " PTS"
        statsMenuMessageTimer = math.floor((SIM_TARGET_HZ or 24) * 2)
    end
    return levelUps
end

function allocatePlayerStat(statKey)
    local key = tostring(statKey or "")
    local valid = (key == "vitality" or key == "strength" or key == "dexterity" or key == "intellect")
    if not valid then
        return false, "INVALID STAT"
    end
    local state = ensurePlayerBuildState()
    if state.stat_points <= 0 then
        return false, "NO STAT POINTS"
    end
    local current = getBuildStatValue(key)
    if current >= (BUILD_STAT_MAX or 99) then
        return false, "STAT MAXED"
    end
    state.stats[key] = current + 1
    state.stat_points = state.stat_points - 1
    markPlayerBuildStateDirty()
    refreshClassGameplayStats(false)
    if playerHealth and playerHealth > MAX_HEALTH then
        playerHealth = MAX_HEALTH
    end
    return true, nil
end

refreshClassGameplayStats(false)

function deterministicPercentRoll(percent, salt)
    local p = tonumber(percent) or 0
    if p <= 0 then
        return false
    end
    if p >= 100 then
        return true
    end
    local s = tonumber(salt) or 0
    local seed = (((frameCount or 0) * 73) + ((simTickCount or 0) * 131) + ((pdir or 0) * 17) + (s * 197)) % 10000
    local threshold = math.floor((p * 100) + 0.5)
    return seed < threshold
end

function toNumber(value, fallback)
    local n = tonumber(value)
    if n == nil then
        return fallback
    end
    return n
end

function splitByPlain(input, separator)
    local out = {}
    if input == nil then
        return out
    end
    local text = tostring(input)
    local sep = separator or ","
    if sep == "" then
        out[1] = text
        return out
    end
    local start = 1
    while true do
        local idx = string.find(text, sep, start, true)
        if not idx then
            out[#out + 1] = string.sub(text, start)
            break
        end
        out[#out + 1] = string.sub(text, start, idx - 1)
        start = idx + #sep
    end
    return out
end

function sanitizeSaveToken(value)
    local text = tostring(value or "")
    text = string.gsub(text, "\r", "")
    text = string.gsub(text, "\n", "")
    text = string.gsub(text, "|", "")
    return text
end

function makeEmptySaveSlot(slotIndex)
    local state = ensurePlayerBuildState()
    return {
        slot = slotIndex or 1,
        used = false,
        level_id = 1,
        class_id = sanitizeClassId(nil),
        player_x = 2.5,
        player_y = 2.5,
        player_dir = 0,
        player_health = MAX_HEALTH or 100,
        soldiers_killed = 0,
        total_soldiers = 0,
        enemy_state = "",
        potion_state = "",
        player_level = math.floor(tonumber(state.level) or 1),
        player_xp = math.floor(tonumber(state.xp) or 0),
        player_stat_points = math.floor(tonumber(state.stat_points) or 0),
        weapon_mastery_points = math.floor(tonumber(state.weapon_mastery_points) or 0),
        mastery_melee = getWeaponMasteryLevel(WEAPON_CLASS_MELEE),
        mastery_ranged = getWeaponMasteryLevel(WEAPON_CLASS_RANGED),
        mastery_magic = getWeaponMasteryLevel(WEAPON_CLASS_MAGIC),
        stat_vitality = getBuildStatValue("vitality"),
        stat_strength = getBuildStatValue("strength"),
        stat_dexterity = getBuildStatValue("dexterity"),
        stat_intellect = getBuildStatValue("intellect"),
    }
end

function copySaveSlot(slot)
    local src = slot or makeEmptySaveSlot(1)
    return {
        slot = src.slot,
        used = src.used and true or false,
        level_id = src.level_id,
        class_id = src.class_id,
        player_x = src.player_x,
        player_y = src.player_y,
        player_dir = src.player_dir,
        player_health = src.player_health,
        soldiers_killed = src.soldiers_killed,
        total_soldiers = src.total_soldiers,
        enemy_state = src.enemy_state,
        potion_state = src.potion_state,
        player_level = src.player_level,
        player_xp = src.player_xp,
        player_stat_points = src.player_stat_points,
        weapon_mastery_points = src.weapon_mastery_points,
        mastery_melee = src.mastery_melee,
        mastery_ranged = src.mastery_ranged,
        mastery_magic = src.mastery_magic,
        stat_vitality = src.stat_vitality,
        stat_strength = src.stat_strength,
        stat_dexterity = src.stat_dexterity,
        stat_intellect = src.stat_intellect,
    }
end

function normalizeSaveSlots()
    for i = 1, SAVE_SLOT_COUNT do
        local slot = saveSlots[i]
        if not slot then
            slot = makeEmptySaveSlot(i)
        else
            slot = copySaveSlot(slot)
            slot.slot = i
            slot.used = slot.used and true or false
            slot.level_id = math.floor(toNumber(slot.level_id, 1))
            if not LEVELS[slot.level_id] then
                slot.level_id = 1
            end
            slot.class_id = sanitizeClassId(slot.class_id)
            slot.player_x = toNumber(slot.player_x, 2.5)
            slot.player_y = toNumber(slot.player_y, 2.5)
            slot.player_dir = math.floor(toNumber(slot.player_dir, 0)) % 64
            slot.player_health = math.floor(toNumber(slot.player_health, MAX_HEALTH or 100))
            if slot.player_health < 1 then slot.player_health = 1 end
            if slot.player_health > (MAX_HEALTH or 100) then slot.player_health = (MAX_HEALTH or 100) end
            slot.soldiers_killed = math.floor(toNumber(slot.soldiers_killed, 0))
            if slot.soldiers_killed < 0 then slot.soldiers_killed = 0 end
            slot.total_soldiers = math.floor(toNumber(slot.total_soldiers, 0))
            if slot.total_soldiers < 0 then slot.total_soldiers = 0 end
            slot.enemy_state = tostring(slot.enemy_state or "")
            slot.potion_state = tostring(slot.potion_state or "")
            slot.player_level = math.floor(toNumber(slot.player_level, 1))
            if slot.player_level < 1 then slot.player_level = 1 end
            if slot.player_level > (PLAYER_LEVEL_MAX or 50) then slot.player_level = (PLAYER_LEVEL_MAX or 50) end
            slot.player_xp = math.floor(toNumber(slot.player_xp, 0))
            if slot.player_xp < 0 then slot.player_xp = 0 end
            slot.player_stat_points = math.floor(toNumber(slot.player_stat_points, 0))
            if slot.player_stat_points < 0 then slot.player_stat_points = 0 end
            slot.weapon_mastery_points = math.floor(toNumber(slot.weapon_mastery_points, 0))
            if slot.weapon_mastery_points < 0 then slot.weapon_mastery_points = 0 end
            slot.mastery_melee = math.floor(toNumber(slot.mastery_melee, 0))
            slot.mastery_ranged = math.floor(toNumber(slot.mastery_ranged, 0))
            slot.mastery_magic = math.floor(toNumber(slot.mastery_magic, 0))
            if slot.mastery_melee < 0 then slot.mastery_melee = 0 end
            if slot.mastery_ranged < 0 then slot.mastery_ranged = 0 end
            if slot.mastery_magic < 0 then slot.mastery_magic = 0 end
            if slot.mastery_melee > (WEAPON_MASTERY_CAP or 10) then slot.mastery_melee = (WEAPON_MASTERY_CAP or 10) end
            if slot.mastery_ranged > (WEAPON_MASTERY_CAP or 10) then slot.mastery_ranged = (WEAPON_MASTERY_CAP or 10) end
            if slot.mastery_magic > (WEAPON_MASTERY_CAP or 10) then slot.mastery_magic = (WEAPON_MASTERY_CAP or 10) end
            slot.stat_vitality = math.floor(toNumber(slot.stat_vitality, 0))
            slot.stat_strength = math.floor(toNumber(slot.stat_strength, 0))
            slot.stat_dexterity = math.floor(toNumber(slot.stat_dexterity, 0))
            slot.stat_intellect = math.floor(toNumber(slot.stat_intellect, 0))
            if slot.stat_vitality < 0 then slot.stat_vitality = 0 end
            if slot.stat_strength < 0 then slot.stat_strength = 0 end
            if slot.stat_dexterity < 0 then slot.stat_dexterity = 0 end
            if slot.stat_intellect < 0 then slot.stat_intellect = 0 end
            if slot.stat_vitality > (BUILD_STAT_MAX or 99) then slot.stat_vitality = (BUILD_STAT_MAX or 99) end
            if slot.stat_strength > (BUILD_STAT_MAX or 99) then slot.stat_strength = (BUILD_STAT_MAX or 99) end
            if slot.stat_dexterity > (BUILD_STAT_MAX or 99) then slot.stat_dexterity = (BUILD_STAT_MAX or 99) end
            if slot.stat_intellect > (BUILD_STAT_MAX or 99) then slot.stat_intellect = (BUILD_STAT_MAX or 99) end
        end
        saveSlots[i] = slot
    end
end

function serializeSaveSlots()
    normalizeSaveSlots()
    local lines = {SAVE_FILE_HEADER}
    for i = 1, SAVE_SLOT_COUNT do
        local slot = saveSlots[i] or makeEmptySaveSlot(i)
        lines[#lines + 1] = table.concat({
            tostring(i),
            slot.used and "1" or "0",
            tostring(slot.level_id or 1),
            sanitizeSaveToken(slot.class_id or "warrior"),
            string.format("%.4f", toNumber(slot.player_x, 2.5)),
            string.format("%.4f", toNumber(slot.player_y, 2.5)),
            tostring(math.floor(toNumber(slot.player_dir, 0)) % 64),
            tostring(math.floor(toNumber(slot.player_health, MAX_HEALTH or 100))),
            tostring(math.floor(toNumber(slot.soldiers_killed, 0))),
            tostring(math.floor(toNumber(slot.total_soldiers, 0))),
            sanitizeSaveToken(slot.enemy_state or ""),
            sanitizeSaveToken(slot.potion_state or ""),
            tostring(math.floor(toNumber(slot.player_level, 1))),
            tostring(math.floor(toNumber(slot.player_xp, 0))),
            tostring(math.floor(toNumber(slot.player_stat_points, 0))),
            tostring(math.floor(toNumber(slot.weapon_mastery_points, 0))),
            tostring(math.floor(toNumber(slot.mastery_melee, 0))),
            tostring(math.floor(toNumber(slot.mastery_ranged, 0))),
            tostring(math.floor(toNumber(slot.mastery_magic, 0))),
            tostring(math.floor(toNumber(slot.stat_vitality, 0))),
            tostring(math.floor(toNumber(slot.stat_strength, 0))),
            tostring(math.floor(toNumber(slot.stat_dexterity, 0))),
            tostring(math.floor(toNumber(slot.stat_intellect, 0))),
        }, "|")
    end
    return table.concat(lines, "\n")
end

function deserializeSaveSlots(payload)
    if not payload or payload == "" then
        return false, "empty_payload"
    end

    local normalized = string.gsub(tostring(payload), "\r", "")
    local lines = {}
    for line in string.gmatch(normalized, "([^\n]+)") do
        if line and line ~= "" then
            lines[#lines + 1] = line
        end
    end
    if #lines == 0 then
        return false, "empty_lines"
    end
    if lines[1] ~= SAVE_FILE_HEADER then
        return false, "invalid_header"
    end

    saveSlots = {}
    for i = 2, #lines do
        local parts = splitByPlain(lines[i], "|")
        if #parts >= 12 then
            local slotIndex = math.floor(toNumber(parts[1], 0))
            if slotIndex >= 1 and slotIndex <= SAVE_SLOT_COUNT then
                local defaultState = ensurePlayerBuildState()
                -- Schema notes:
                -- Old (Build <= 144): 19 fields (no weapon mastery data).
                -- New (Build >= 145): 23 fields (adds mastery currency + 3 mastery levels before stats).
                local weaponMasteryPoints = 0
                local masteryMelee = 0
                local masteryRanged = 0
                local masteryMagic = 0
                local statVitality = math.floor(toNumber((defaultState.stats and defaultState.stats.vitality) or 0, 0))
                local statStrength = math.floor(toNumber((defaultState.stats and defaultState.stats.strength) or 0, 0))
                local statDexterity = math.floor(toNumber((defaultState.stats and defaultState.stats.dexterity) or 0, 0))
                local statIntellect = math.floor(toNumber((defaultState.stats and defaultState.stats.intellect) or 0, 0))
                if #parts >= 23 then
                    weaponMasteryPoints = math.floor(toNumber(parts[16], weaponMasteryPoints))
                    masteryMelee = math.floor(toNumber(parts[17], masteryMelee))
                    masteryRanged = math.floor(toNumber(parts[18], masteryRanged))
                    masteryMagic = math.floor(toNumber(parts[19], masteryMagic))
                    statVitality = math.floor(toNumber(parts[20], statVitality))
                    statStrength = math.floor(toNumber(parts[21], statStrength))
                    statDexterity = math.floor(toNumber(parts[22], statDexterity))
                    statIntellect = math.floor(toNumber(parts[23], statIntellect))
                elseif #parts >= 19 then
                    statVitality = math.floor(toNumber(parts[16], statVitality))
                    statStrength = math.floor(toNumber(parts[17], statStrength))
                    statDexterity = math.floor(toNumber(parts[18], statDexterity))
                    statIntellect = math.floor(toNumber(parts[19], statIntellect))
                end
                saveSlots[slotIndex] = {
                    slot = slotIndex,
                    used = (toNumber(parts[2], 0) ~= 0),
                    level_id = math.floor(toNumber(parts[3], 1)),
                    class_id = sanitizeClassId(parts[4]),
                    player_x = toNumber(parts[5], 2.5),
                    player_y = toNumber(parts[6], 2.5),
                    player_dir = math.floor(toNumber(parts[7], 0)) % 64,
                    player_health = math.floor(toNumber(parts[8], MAX_HEALTH or 100)),
                    soldiers_killed = math.floor(toNumber(parts[9], 0)),
                    total_soldiers = math.floor(toNumber(parts[10], 0)),
                    enemy_state = parts[11] or "",
                    potion_state = parts[12] or "",
                    player_level = math.floor(toNumber(parts[13], defaultState.level or 1)),
                    player_xp = math.floor(toNumber(parts[14], defaultState.xp or 0)),
                    player_stat_points = math.floor(toNumber(parts[15], defaultState.stat_points or 0)),
                    weapon_mastery_points = weaponMasteryPoints,
                    mastery_melee = masteryMelee,
                    mastery_ranged = masteryRanged,
                    mastery_magic = masteryMagic,
                    stat_vitality = statVitality,
                    stat_strength = statStrength,
                    stat_dexterity = statDexterity,
                    stat_intellect = statIntellect,
                }
            end
        end
    end

    normalizeSaveSlots()
    return true, nil
end

function hasFileApi()
    return vmupro and vmupro.file and vmupro.file.read and vmupro.file.write
end

function writeSaveSlotsToDisk()
    normalizeSaveSlots()
    if not hasFileApi() then
        return false, "file_api_unavailable"
    end

    if vmupro.file.folderExists and vmupro.file.createFolder then
        if not vmupro.file.folderExists("/sdcard/inner_sanctum") then
            local created = vmupro.file.createFolder("/sdcard/inner_sanctum")
            if not created then
                return false, "create_folder_failed"
            end
        end
    end

    if vmupro.file.exists and vmupro.file.createFile and (not vmupro.file.exists(SAVE_FILE_PATH)) then
        vmupro.file.createFile(SAVE_FILE_PATH)
    end

    local encoded = serializeSaveSlots()
    local okWrite = vmupro.file.write(SAVE_FILE_PATH, encoded)
    if not okWrite then
        return false, "write_failed"
    end
    return true, nil
end

function loadSaveSlotsFromDisk()
    normalizeSaveSlots()
    if not hasFileApi() then
        return false, "file_api_unavailable"
    end
    if vmupro.file.exists and (not vmupro.file.exists(SAVE_FILE_PATH)) then
        return false, "missing_file"
    end
    local payload = vmupro.file.read(SAVE_FILE_PATH)
    if not payload or payload == "" then
        return false, "read_failed"
    end
    return deserializeSaveSlots(payload)
end

function getSaveSlotSummary(slotIndex)
    normalizeSaveSlots()
    local idx = math.floor(toNumber(slotIndex, 1))
    if idx < 1 then idx = 1 end
    if idx > SAVE_SLOT_COUNT then idx = SAVE_SLOT_COUNT end
    local slot = saveSlots[idx] or makeEmptySaveSlot(idx)
    if not slot.used then
        return "SLOT " .. tostring(idx), "EMPTY"
    end
    local levelLabel = getLevelLabel(slot.level_id or 1)
    local classLabel = string.upper(getClassName(slot.class_id))
    local playerLevel = math.floor(toNumber(slot.player_level, 1))
    return "SLOT " .. tostring(idx), "LEVEL " .. tostring(levelLabel) .. "  " .. classLabel .. "  LV " .. tostring(playerLevel)
end

function countEnemiesInSprites()
    if not sprites then return 0 end
    local total = 0
    for i = 1, #sprites do
        local s = sprites[i]
        if s and isEnemyType(s.t) then
            total = total + 1
        end
    end
    return total
end

function countDeadEnemiesInSprites()
    if not sprites then return 0 end
    local total = 0
    for i = 1, #sprites do
        local s = sprites[i]
        if s and isEnemyType(s.t) and (s.alive == false or s.dead == true) then
            total = total + 1
        end
    end
    return total
end

function buildEnemyStateSnapshot()
    if not sprites then
        return ""
    end
    local entries = {}
    for i = 1, #sprites do
        local s = sprites[i]
        if s and isEnemyType(s.t) then
            local alive = 1
            if s.alive == false or s.dead == true then
                alive = 0
            end
            local hp = math.floor(toNumber(s.hp, ENEMY_MAX_HP))
            if hp < 0 then hp = 0 end
            entries[#entries + 1] = tostring(alive) .. ":" .. tostring(hp)
        end
    end
    return table.concat(entries, ";")
end

function buildPotionStateSnapshot()
    if not sprites then
        return ""
    end
    local entries = {}
    for i = 1, #sprites do
        local s = sprites[i]
        if s and s.t == 7 then
            entries[#entries + 1] = s.collected and "1" or "0"
        end
    end
    return table.concat(entries, ";")
end

function applyEnemyStateSnapshot(snapshot)
    if not sprites then
        return 0
    end
    local entries = splitByPlain(snapshot or "", ";")
    local enemyIdx = 1
    local deadCount = 0
    for i = 1, #sprites do
        local s = sprites[i]
        if s and isEnemyType(s.t) then
            local entry = entries[enemyIdx] or ""
            if entry ~= "" then
                local pair = splitByPlain(entry, ":")
                local aliveFlag = toNumber(pair[1], 1)
                local hpValue = math.floor(toNumber(pair[2], s.hp or ENEMY_MAX_HP))
                if hpValue < 0 then hpValue = 0 end
                if hpValue > 300 then hpValue = 300 end
                if aliveFlag ~= 0 and hpValue > 0 then
                    s.alive = true
                    s.dead = false
                    s.dying = false
                    s.hp = hpValue
                else
                    s.alive = false
                    s.dead = true
                    s.dying = false
                    s.hp = 0
                    deadCount = deadCount + 1
                end
                s.attackAnim = 0
                s.attackFrame = 1
                s.attackDidHit = false
                s.state = nil
                s.deathFrame = nil
                s.deathTick = nil
            elseif s.alive == false or s.dead == true then
                deadCount = deadCount + 1
            end
            enemyIdx = enemyIdx + 1
        end
    end
    return deadCount
end

function applyPotionStateSnapshot(snapshot)
    if not sprites then
        return
    end
    local entries = splitByPlain(snapshot or "", ";")
    local potionIdx = 1
    for i = 1, #sprites do
        local s = sprites[i]
        if s and s.t == 7 then
            local entry = entries[potionIdx] or ""
            if entry ~= "" then
                s.collected = (toNumber(entry, 0) ~= 0)
            end
            potionIdx = potionIdx + 1
        end
    end
end

function captureCurrentSaveSlot(slotIndex)
    local build = ensurePlayerBuildState()
    local slot = makeEmptySaveSlot(slotIndex)
    slot.used = true
    slot.level_id = currentLevel or 1
    if not LEVELS[slot.level_id] then
        slot.level_id = 1
    end
    slot.class_id = getCurrentClassId()
    slot.player_x = toNumber(px, 2.5)
    slot.player_y = toNumber(py, 2.5)
    slot.player_dir = math.floor(toNumber(pdir, 0)) % 64
    slot.player_health = math.floor(toNumber(playerHealth, MAX_HEALTH or 100))
    if slot.player_health < 1 then slot.player_health = 1 end
    if slot.player_health > (MAX_HEALTH or 100) then slot.player_health = (MAX_HEALTH or 100) end
    slot.enemy_state = buildEnemyStateSnapshot()
    slot.potion_state = buildPotionStateSnapshot()
    slot.total_soldiers = countEnemiesInSprites()
    local observedKilled = countDeadEnemiesInSprites()
    local trackedKilled = math.floor(toNumber(soldiersKilled, 0))
    if trackedKilled < observedKilled then
        trackedKilled = observedKilled
    end
    if trackedKilled < 0 then trackedKilled = 0 end
    if trackedKilled > slot.total_soldiers then trackedKilled = slot.total_soldiers end
    slot.soldiers_killed = trackedKilled
    slot.player_level = math.floor(tonumber(build.level) or 1)
    slot.player_xp = math.floor(tonumber(build.xp) or 0)
    slot.player_stat_points = math.floor(tonumber(build.stat_points) or 0)
    slot.weapon_mastery_points = math.floor(toNumber(build.weapon_mastery_points, 0))
    slot.mastery_melee = getWeaponMasteryLevel(WEAPON_CLASS_MELEE)
    slot.mastery_ranged = getWeaponMasteryLevel(WEAPON_CLASS_RANGED)
    slot.mastery_magic = getWeaponMasteryLevel(WEAPON_CLASS_MAGIC)
    slot.stat_vitality = getBuildStatValue("vitality")
    slot.stat_strength = getBuildStatValue("strength")
    slot.stat_dexterity = getBuildStatValue("dexterity")
    slot.stat_intellect = getBuildStatValue("intellect")
    return slot
end

function saveGameToSlot(slotIndex)
    local idx = math.floor(toNumber(slotIndex, 1))
    if idx < 1 or idx > SAVE_SLOT_COUNT then
        return false, "invalid_slot"
    end
    normalizeSaveSlots()
    saveSlots[idx] = captureCurrentSaveSlot(idx)
    local okWrite, errWrite = writeSaveSlotsToDisk()
    if not okWrite and errWrite ~= "file_api_unavailable" then
        return false, errWrite
    end
    return true, nil
end

function loadGameFromSlot(slotIndex)
    local idx = math.floor(toNumber(slotIndex, 1))
    if idx < 1 or idx > SAVE_SLOT_COUNT then
        return false, "invalid_slot"
    end
    normalizeSaveSlots()
    local slot = saveSlots[idx]
    if not slot or not slot.used then
        return false, "empty_slot"
    end
    local levelId = math.floor(toNumber(slot.level_id, 1))
    if not LEVELS[levelId] then
        return false, "invalid_level"
    end

    beginLoadLevel(levelId)

    local build = ensurePlayerBuildState()
    build.level = math.floor(toNumber(slot.player_level, 1))
    if build.level < 1 then build.level = 1 end
    if build.level > (PLAYER_LEVEL_MAX or 50) then build.level = (PLAYER_LEVEL_MAX or 50) end
    build.xp = math.floor(toNumber(slot.player_xp, 0))
    if build.xp < 0 then build.xp = 0 end
    build.stat_points = math.floor(toNumber(slot.player_stat_points, 0))
    if build.stat_points < 0 then build.stat_points = 0 end
    build.weapon_mastery_points = math.floor(toNumber(slot.weapon_mastery_points, build.weapon_mastery_points or 0))
    if build.weapon_mastery_points < 0 then build.weapon_mastery_points = 0 end
    if not build.weapon_mastery then build.weapon_mastery = {} end
    build.weapon_mastery[WEAPON_CLASS_MELEE] = math.floor(toNumber(slot.mastery_melee, build.weapon_mastery[WEAPON_CLASS_MELEE] or 0))
    build.weapon_mastery[WEAPON_CLASS_RANGED] = math.floor(toNumber(slot.mastery_ranged, build.weapon_mastery[WEAPON_CLASS_RANGED] or 0))
    build.weapon_mastery[WEAPON_CLASS_MAGIC] = math.floor(toNumber(slot.mastery_magic, build.weapon_mastery[WEAPON_CLASS_MAGIC] or 0))
    if build.weapon_mastery[WEAPON_CLASS_MELEE] < 0 then build.weapon_mastery[WEAPON_CLASS_MELEE] = 0 end
    if build.weapon_mastery[WEAPON_CLASS_RANGED] < 0 then build.weapon_mastery[WEAPON_CLASS_RANGED] = 0 end
    if build.weapon_mastery[WEAPON_CLASS_MAGIC] < 0 then build.weapon_mastery[WEAPON_CLASS_MAGIC] = 0 end
    local masteryCap = (WEAPON_MASTERY_CAP or 10)
    if build.weapon_mastery[WEAPON_CLASS_MELEE] > masteryCap then build.weapon_mastery[WEAPON_CLASS_MELEE] = masteryCap end
    if build.weapon_mastery[WEAPON_CLASS_RANGED] > masteryCap then build.weapon_mastery[WEAPON_CLASS_RANGED] = masteryCap end
    if build.weapon_mastery[WEAPON_CLASS_MAGIC] > masteryCap then build.weapon_mastery[WEAPON_CLASS_MAGIC] = masteryCap end
    build.stats.vitality = math.floor(toNumber(slot.stat_vitality, 0))
    build.stats.strength = math.floor(toNumber(slot.stat_strength, 0))
    build.stats.dexterity = math.floor(toNumber(slot.stat_dexterity, 0))
    build.stats.intellect = math.floor(toNumber(slot.stat_intellect, 0))
    if build.stats.vitality < 0 then build.stats.vitality = 0 end
    if build.stats.strength < 0 then build.stats.strength = 0 end
    if build.stats.dexterity < 0 then build.stats.dexterity = 0 end
    if build.stats.intellect < 0 then build.stats.intellect = 0 end
    if build.stats.vitality > (BUILD_STAT_MAX or 99) then build.stats.vitality = (BUILD_STAT_MAX or 99) end
    if build.stats.strength > (BUILD_STAT_MAX or 99) then build.stats.strength = (BUILD_STAT_MAX or 99) end
    if build.stats.dexterity > (BUILD_STAT_MAX or 99) then build.stats.dexterity = (BUILD_STAT_MAX or 99) end
    if build.stats.intellect > (BUILD_STAT_MAX or 99) then build.stats.intellect = (BUILD_STAT_MAX or 99) end
    markPlayerBuildStateDirty()

    setCurrentClassId(slot.class_id)

    px = toNumber(slot.player_x, px or 2.5)
    py = toNumber(slot.player_y, py or 2.5)
    pdir = math.floor(toNumber(slot.player_dir, pdir or 0)) % 64
    lastSafeWallX = px
    lastSafeWallY = py

    playerHealth = math.floor(toNumber(slot.player_health, MAX_HEALTH or 100))
    if playerHealth < 1 then playerHealth = 1 end
    if playerHealth > (MAX_HEALTH or 100) then playerHealth = (MAX_HEALTH or 100) end

    local restoredDead = applyEnemyStateSnapshot(slot.enemy_state)
    applyPotionStateSnapshot(slot.potion_state)
    totalSoldiers = countEnemiesInSprites()
    local savedKilled = math.floor(toNumber(slot.soldiers_killed, restoredDead))
    if savedKilled < restoredDead then savedKilled = restoredDead end
    if savedKilled < 0 then savedKilled = 0 end
    if savedKilled > totalSoldiers then savedKilled = totalSoldiers end
    soldiersKilled = savedKilled

    showMenu = false
    inOptionsMenu = false
    inSaveMenu = false
    inStatsMenu = false
    inMasteryMenu = false
    saveMenuSelection = 1
    saveMenuMessage = ""
    saveMenuMessageTimer = 0
    statsMenuSelection = 1
    statsMenuMessage = ""
    statsMenuMessageTimer = 0
    masteryMenuSelection = 1
    masteryMenuMessage = ""
    masteryMenuMessageTimer = 0
    lootFeedMessage = ""
    lootFeedMessageTimer = 0

    if totalSoldiers > 0 and soldiersKilled >= totalSoldiers then
        gameState = STATE_WIN
        winSelection = 1
        winCooldown = 0
        winBannerTimer = winBannerMax
    end

    return true, nil
end

normalizeSaveSlots()
loadSaveSlotsFromDisk()
titleClassSelection = getClassSelectionIndexForId(getCurrentClassId())

-- Blood particle effects
local bloodEffects = {}  -- {x, y, particles={{dx, dy, life}...}}
BLOOD_PARTICLE_COUNT = BLOOD_PARTICLE_COUNT or 12
BLOOD_EFFECT_POOL_FREE = BLOOD_EFFECT_POOL_FREE or {}

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
local bowAttack = {}
local staffCast = {}
local projectileArrowSprite = nil
local projectileMagicSprite = nil
local projectileImpactSprite = nil

-- Load knight sprites for 4 directions
local knightFront = nil
local knightBack = nil
local knightLeft = nil
local knightRight = nil
local playerProjectiles = {}
PROJECTILE_POOL_FREE = PROJECTILE_POOL_FREE or {}
local projectileNextId = 1
local lastAttackWeaponClass = WEAPON_CLASS_MELEE

function makePooledBloodEffect()
    local effect = {x = 0, y = 0, life = 0, particles = {}}
    local particles = effect.particles
    for i = 1, (BLOOD_PARTICLE_COUNT or 12) do
        particles[i] = {dx = 0, dy = 0, ox = 0, oy = 0}
    end
    return effect
end

function acquireBloodEffect()
    local freePool = BLOOD_EFFECT_POOL_FREE
    local n = #freePool
    if n > 0 then
        local effect = freePool[n]
        freePool[n] = nil
        return effect
    end
    return makePooledBloodEffect()
end

function releaseBloodEffect(effect)
    if not effect then
        return
    end
    effect.life = 0
    effect.x = 0
    effect.y = 0
    local particles = effect.particles
    if particles then
        for i = 1, #particles do
            local p = particles[i]
            if p then
                p.dx = 0
                p.dy = 0
                p.ox = 0
                p.oy = 0
            end
        end
    end
    local freePool = BLOOD_EFFECT_POOL_FREE
    freePool[#freePool + 1] = effect
end

function clearBloodEffectsActive()
    if not bloodEffects then
        bloodEffects = {}
        return
    end
    for i = 1, #bloodEffects do
        releaseBloodEffect(bloodEffects[i])
    end
    bloodEffects = {}
end

function makePooledProjectile()
    return {
        id = 0,
        weaponClass = WEAPON_CLASS_RANGED,
        x = 0, y = 0,
        startX = 0, startY = 0,
        dx = 0, dy = 0,
        speed = 0,
        damage = 1,
        maxRangeSq = 0,
        ttl = 0,
    }
end

function acquireProjectile()
    local freePool = PROJECTILE_POOL_FREE
    local n = #freePool
    if n > 0 then
        local projectile = freePool[n]
        freePool[n] = nil
        return projectile
    end
    return makePooledProjectile()
end

function releaseProjectile(projectile)
    if not projectile then
        return
    end
    projectile.id = 0
    projectile.weaponClass = WEAPON_CLASS_RANGED
    projectile.x = 0
    projectile.y = 0
    projectile.startX = 0
    projectile.startY = 0
    projectile.dx = 0
    projectile.dy = 0
    projectile.speed = 0
    projectile.damage = 1
    projectile.maxRangeSq = 0
    projectile.ttl = 0
    local freePool = PROJECTILE_POOL_FREE
    freePool[#freePool + 1] = projectile
end

function clearPlayerProjectilesActive()
    if not playerProjectiles then
        playerProjectiles = {}
        return
    end
    for i = 1, #playerProjectiles do
        releaseProjectile(playerProjectiles[i])
    end
    playerProjectiles = {}
end

function deepCopy(value)
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

LEVEL_LOAD_MAP_BUFFER = LEVEL_LOAD_MAP_BUFFER or {}
LEVEL_LOAD_SPRITE_BUFFER = LEVEL_LOAD_SPRITE_BUFFER or {}

function cloneMapForLevelLoad(sourceMap)
    local out = LEVEL_LOAD_MAP_BUFFER
    local rows = sourceMap and #sourceMap or 0
    for y = 1, rows do
        local srcRow = sourceMap[y]
        local dstRow = out[y]
        if not dstRow then
            dstRow = {}
            out[y] = dstRow
        end
        local cols = srcRow and #srcRow or 0
        for x = 1, cols do
            dstRow[x] = srcRow[x]
        end
        for x = cols + 1, #dstRow do
            dstRow[x] = nil
        end
    end
    for y = rows + 1, #out do
        out[y] = nil
    end
    return out
end

function copySpritePrototypeInto(dst, src)
    for k, _ in pairs(dst) do
        if src[k] == nil then
            dst[k] = nil
        end
    end
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = deepCopy(v)
        else
            dst[k] = v
        end
    end
end

function cloneSpritesForLevelLoad(sourceSprites)
    local out = LEVEL_LOAD_SPRITE_BUFFER
    local count = sourceSprites and #sourceSprites or 0
    for i = 1, count do
        local src = sourceSprites[i]
        if src then
            local dst = out[i]
            if not dst then
                dst = {}
                out[i] = dst
            end
            copySpritePrototypeInto(dst, src)
        else
            out[i] = nil
        end
    end
    for i = count + 1, #out do
        out[i] = nil
    end
    return out
end

function countEnemies(spriteList)
    local count = 0
    for i = 1, #spriteList do
        local s = spriteList[i]
        if s.t == 5 or s.t == 6 then
            count = count + 1
        end
    end
    return count
end

function countAdjacentOpenTiles(sourceMap, mx, my)
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

function wallVariantHash(mx, my, levelId, salt)
    local v = (((mx + 1) * 1973) + ((my + 1) * 9277) + ((levelId or 1) * 2663) + ((salt or 0) * 811)) % 104729
    v = ((v * 131) + 907) % 104729
    return v
end

function chooseWallVariant(mx, my, levelId, sourceMap)
    -- Deterministic wall variety (no math.random crash risk).
    local openCount = countAdjacentOpenTiles(sourceMap, mx, my)
    local isDeadEndCap = (openCount == 1)

    -- Increase decorative accent frequency:
    -- 1) Diamond + window overall spawn chance is doubled.
    -- 2) Dead-end bonus factor is also doubled.
    local baseAccentPerThousand = 12
    local accentRateScale = 2.0
    local deadEndBonusFactor = (55.0 / 12.0) * 2.0
    local accentRatePerThousand = baseAccentPerThousand * accentRateScale
    if isDeadEndCap then
        accentRatePerThousand = accentRatePerThousand * deadEndBonusFactor
    end
    accentRatePerThousand = math.floor(accentRatePerThousand + 0.5)
    if accentRatePerThousand > 1000 then
        accentRatePerThousand = 1000
    end

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

function loadLevel(levelId)
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
    map = cloneMapForLevelLoad(level.map)
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
    sprites = cloneSpritesForLevelLoad(level.sprites)
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

function unloadLevelData()
    map = nil
    sprites = nil
    totalSoldiers = 0
    clearPlayerProjectilesActive()
end

function freeSpriteRef(sprite)
    if sprite then
        vmupro.sprite.free(sprite)
    end
end

function unloadMenuSprites()
    freeSpriteRef(titleSprite)
    titleSprite = nil
    if classPortraitSprites then
        for _, spriteRef in pairs(classPortraitSprites) do
            freeSpriteRef(spriteRef)
        end
    end
    classPortraitSprites = {}
    freeSpriteRef(classPortraitSprite)
    classPortraitSprite = nil
end

function unloadLevelSprites()
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
    for i = 1, #bowAttack do
        freeSpriteRef(bowAttack[i])
    end
    bowAttack = {}
    for i = 1, #staffCast do
        freeSpriteRef(staffCast[i])
    end
    staffCast = {}
    freeSpriteRef(projectileArrowSprite); projectileArrowSprite = nil
    freeSpriteRef(projectileMagicSprite); projectileMagicSprite = nil
    freeSpriteRef(projectileImpactSprite); projectileImpactSprite = nil
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

function loadMenuSprites()
    if not titleSprite then
        titleSprite = vmupro.sprite.new("sprites/title")
        if not validateSprite(titleSprite, "loadMenuSprites") then
            safeLog("ERROR", "Failed to load title sprite")
            titleSprite = nil
        end
    end
    if not classPortraitSprite then
        classPortraitSprite = vmupro.sprite.new("sprites/level1/warrior_front")
        if not validateSprite(classPortraitSprite, "classPortraitSprite") then
            classPortraitSprite = nil
        end
    end
    if not classPortraitSprites then
        classPortraitSprites = {}
    end
    if CLASS_SELECT_PORTRAIT_PATHS then
        for classId, spritePath in pairs(CLASS_SELECT_PORTRAIT_PATHS) do
            if spritePath and (not classPortraitSprites[classId]) then
                local okPortrait, spriteRef = pcall(vmupro.sprite.new, spritePath)
                if okPortrait and validateSprite(spriteRef, "classPortrait:" .. tostring(classId)) then
                    classPortraitSprites[classId] = spriteRef
                else
                    classPortraitSprites[classId] = nil
                end
            end
        end
    end
end

-- Texture metadata and loaders (forward-declared for use in loadLevelSprites)
local textureMetadata = {}
local loadTextureWithValidation
local logTextureMemoryUsage

function loadTextureSheetWithValidation(path, textureName)
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

function getWall1VariantConfig()
    local variants = WALL1_FORMAT_VARIANTS or {}
    local n = #variants
    if n <= 0 then
        return {label = "PNG16", base = "sprites/wall_textures/wall-1-tile", sheet = "sprites/wall_textures/wall-1-tile-table-1-128"}
    end
    WALL1_FORMAT_INDEX = clampInt(WALL1_FORMAT_INDEX or 1, 1, n)
    return variants[WALL1_FORMAT_INDEX] or variants[1]
end

function getWallKeyModeLabel()
    return WALL_FORCE_COLORKEY_OVERRIDE and "FORCED" or "RAW"
end

function getWallProjectionModeLabel()
    if WALL_PROJECTION_MODE == "stable" then
        return "STABLE"
    end
    return "ADAPTIVE"
end

function forceWallTextureColorKeys()
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

function loadLevelSprites(levelId)
    local level = LEVELS[levelId]
    local assets = level and level.assets or {}
    local base = (level and level.assetBase) or "sprites/"
    local globalBase = "sprites/"

    local function tryLoadSprite(pathNoExt, context)
        local ok, spr = pcall(vmupro.sprite.new, pathNoExt)
        if ok and validateSprite(spr, context) then
            return spr
        end
        return nil
    end

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

    -- Optional player-weapon overlays for ranged/magic placeholders.
    -- These are global (not per-level) assets, so also try `sprites/` even when a level uses `sprites/levelX/`.
    bowAttack = {}
    -- Deterministic placeholder loading: use provided assets first, then level fallback.
    bowAttack[1] = tryLoadSprite(globalBase .. "bow_idle", "bow_idle_global")
        or tryLoadSprite(base .. "bow_idle", "bow_idle_level")
    bowAttack[2] = tryLoadSprite(globalBase .. "bow_drawn", "bow_drawn_global")
        or tryLoadSprite(base .. "bow_drawn", "bow_drawn_level")

    staffCast = {}
    local sprStaffSingle = tryLoadSprite(globalBase .. "STAFF", "STAFF_global")
        or tryLoadSprite(base .. "STAFF", "STAFF_level")
        or tryLoadSprite(globalBase .. "staff", "staff_global")
        or tryLoadSprite(base .. "staff", "staff_level")
    if sprStaffSingle then
        staffCast[1] = sprStaffSingle
        staffCast[2] = sprStaffSingle
    end

    -- Arrow path is fixed to custom placeholder first.
    projectileArrowSprite = tryLoadSprite(globalBase .. "arrow", "arrow_global")
        or tryLoadSprite(base .. "arrow", "arrow_level")

    projectileMagicSprite = tryLoadSprite(globalBase .. "projectile_magic", "projectile_magic_global")
        or tryLoadSprite(base .. "projectile_magic", "projectile_magic_level")

    projectileImpactSprite = tryLoadSprite(globalBase .. "projectile_impact", "projectile_impact_global")
        or tryLoadSprite(base .. "projectile_impact", "projectile_impact_level")
    if not projectileMagicSprite then
        projectileMagicSprite =
            tryLoadSprite(globalBase .. "explosion", "explosion_global")
            or tryLoadSprite(base .. "explosion", "explosion")
    end
    if not projectileImpactSprite and projectileMagicSprite then
        projectileImpactSprite = projectileMagicSprite
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

function unloadLevelAudio()
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

function loadLevelAudio()
    if not ENABLE_SAMPLE_AUDIO then
        audioInitialized = false
        return
    end
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

function stopGameplaySamples()
    if gruntSample then vmupro.sound.sample.stop(gruntSample) end
    if swordHitSample then vmupro.sound.sample.stop(swordHitSample) end
    if swordMissSample then vmupro.sound.sample.stop(swordMissSample) end
    if yahSample then vmupro.sound.sample.stop(yahSample) end
    if winLevelSample then vmupro.sound.sample.stop(winLevelSample) end
    if argDeathSample then vmupro.sound.sample.stop(argDeathSample) end
end

function loadTitleMusic()
    if not ENABLE_SAMPLE_AUDIO then
        return
    end
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

function isSamplePlayingSafe(sample, context)
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

function playTitleVoice()
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

function playTitleMusic(reason)
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

function stopTitleMusic()
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

function startTitleMusic()
    if not soundEnabled or not ENABLE_SAMPLE_AUDIO then
        titleMusicState = "stopped"
        titleMusicTimer = 0
        titleMusicStartUs = 0
        titleVoiceStarted = false
        titleMusicStarted = false
        return
    end
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

function updateTitleMusic()
    if not soundEnabled or not ENABLE_SAMPLE_AUDIO then
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

function enterTitle()
    markRunResetRequested()
    resetGameOverScoreEntryState()
    showMenu = false
    inOptionsMenu = false
    inGameDebugMenu = false
    inSaveMenu = false
    inInventoryMenu = false
    inStatsMenu = false
    inMasteryMenu = false
    resetBowChargeState()
    saveMenuSelection = 1
    saveMenuMessage = ""
    saveMenuMessageTimer = 0
    inventoryMenuSelection = 1
    inventoryMenuPage = 1
    inventoryMenuTab = 1
    inventoryMenuMessage = ""
    inventoryMenuMessageTimer = 0
    statsMenuSelection = 1
    statsMenuMessage = ""
    statsMenuMessageTimer = 0
    masteryMenuSelection = 1
    masteryMenuMessage = ""
    masteryMenuMessageTimer = 0
    lootFeedMessage = ""
    lootFeedMessageTimer = 0
    gameState = STATE_TITLE
    titleSelection = 1
    titleInClassSelect = false
    titleClassSelection = getClassSelectionIndexForId(getCurrentClassId())
    titleInLoadMenu = false
    titleLoadSelection = 1
    titleInOptions = false
    titleInDebug = false
    loadSaveSlotsFromDisk()
    titleNeedsRedraw = true
    unloadLevelAudio()
    unloadLevelSprites()
    unloadLevelData()
    unloadWallTextures()
    loadMenuSprites()
    collectgarbage()
    startTitleMusic()
end

function initializeLevelState(levelId)
    ensurePlayerBuildState()
    loadLevel(levelId)
    refreshClassGameplayStats(true)
    beginExpansionRun(levelId)
    resetGameOverScoreEntryState()
    soldiersKilled = 0
    isAttacking = 0
    resetBowChargeState()
    isBlocking = false
    blockAnim = 0
    showMenu = false
    inOptionsMenu = false
    inGameDebugMenu = false
    inSaveMenu = false
    inInventoryMenu = false
    inStatsMenu = false
    inMasteryMenu = false
    saveMenuSelection = 1
    saveMenuMessage = ""
    saveMenuMessageTimer = 0
    inventoryMenuSelection = 1
    inventoryMenuPage = 1
    inventoryMenuTab = 1
    inventoryMenuMessage = ""
    inventoryMenuMessageTimer = 0
    statsMenuSelection = 1
    statsMenuMessage = ""
    statsMenuMessageTimer = 0
    masteryMenuSelection = 1
    masteryMenuMessage = ""
    masteryMenuMessageTimer = 0
    clearBloodEffectsActive()
    clearPlayerProjectilesActive()
    projectileNextId = 1
    lastAttackWeaponClass = WEAPON_CLASS_MELEE
    levelBannerTimer = levelBannerMax
end

function startLevel(levelId)
    loadingLog("LOAD startLevel begin " .. tostring(levelId))
    -- Ensure we free previous level assets to avoid sprite slot exhaustion
    unloadLevelData()
    unloadLevelSprites()
    unloadWallTextures()
    stopTitleMusic()
    unloadMenuSprites()
    loadingLog("LOAD after unloadMenuSprites")
    local okSprites, errSprites = pcall(loadLevelSprites, levelId)
    if not okSprites then
        safeLog("ERROR", "startLevel loadLevelSprites failed: " .. tostring(errSprites))
    else
        loadingLog("LOAD after loadLevelSprites")
    end
    local okAudio, errAudio = pcall(loadLevelAudio)
    if not okAudio then
        safeLog("ERROR", "startLevel loadLevelAudio failed: " .. tostring(errAudio))
    else
        loadingLog("LOAD after loadLevelAudio")
    end
    initializeLevelState(levelId)
    loadingLog("LOAD after initializeLevelState")
    gameState = STATE_PLAYING
    loadingLog("LOAD startLevel done")
end

function restartLevel()
    startLevel(currentLevel)
end

beginLoadLevel = function(levelId)
    run_reset_requested = shouldStartNewRunForLevelLoad(levelId)
    pendingLevelStart = nil
    loadingTimer = 0
    loadingLogCount = 0
    loadingLog("LOAD beginLoadLevel (loading disabled) " .. tostring(levelId))
    wallQuadLogCount = 0
    wallQuadLog("WQ beginLoadLevel (loading disabled) " .. tostring(levelId))
    startLevel(levelId)
end

-- Check if a position is walkable (no wall)
function isWalkable(x, y)
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
function safeAtan2(y, x)
    if x == 0 then
        if y > 0 then return 1.5708
        elseif y < 0 then return -1.5708
        else return 0 end
    end
    local angle = math.atan(y / x)
    if x < 0 then angle = angle + 3.14159 end
    return angle
end

function recordDamageTaken(amount)
    local value = math.floor(tonumber(amount) or 0)
    if value <= 0 then
        return
    end
    damageDebugTakenValue = value
    damageDebugTakenUntilTick = (simTickCount or 0) + (DMG_DEBUG_DURATION_TICKS or 48)
end

function recordDamageDealt(amount)
    local value = math.floor(tonumber(amount) or 0)
    if value <= 0 then
        return
    end
    damageDebugDealtValue = value
    damageDebugDealtUntilTick = (simTickCount or 0) + (DMG_DEBUG_DURATION_TICKS or 48)
end

-- Soldier AI: patrol, chase, and attack
function updateSoldiers()
    if DEBUG_DISABLE_ENEMIES then
        return
    end
    if not sprites or #sprites == 0 then
        return
    end
    local attackRangeSq = ATTACK_RANGE * ATTACK_RANGE
    local detectionRangeSq = DETECTION_RANGE * DETECTION_RANGE
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
            local inAttackRange = distSq < attackRangeSq
            local inDetectionRange = distSq < detectionRangeSq
            local distToPlayer = 0
            if inDetectionRange and not inAttackRange then
                distToPlayer = math.sqrt(distSq)
                if distToPlayer < 0.001 then
                    distToPlayer = 0.001
                end
            end
            local dirToPlayer = nil
            if DEBUG_DISABLE_ENEMY_AGGRO or inDetectionRange then
                dirToPlayer = math.floor((safeAtan2(dy, dx) * 64) / 6.28318) % 64
            end

            if DEBUG_DISABLE_ENEMY_AGGRO then
                -- Force patrol state without burning chase/attack path work.
                inAttackRange = false
                inDetectionRange = false
                s.attackCooldown = 0
                if dirToPlayer then
                    s.dir = dirToPlayer
                end
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
            if inAttackRange then
                -- Close enough to attack
                s.state = "attack"

                -- Face the player
                if dirToPlayer then
                    s.dir = dirToPlayer
                end

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

            elseif inDetectionRange then
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
                    if dirToPlayer then
                        s.dir = dirToPlayer
                    end

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
                    if not s.attackDidHit and inAttackRange then
                        local rawDamage = DAMAGE_PER_HIT
                        local damage = rawDamage - (PLAYER_DEFENSE or 0)
                        if damage < 1 then
                            damage = 1
                        end
                        local dodgeSalt = (i * 173) + math.floor((s.x or 0) * 100) + math.floor((s.y or 0) * 100) + (s.attackStartTick or 0)
                        if deterministicPercentRoll(PLAYER_DODGE_PERCENT or 0, dodgeSalt) then
                            damage = 0
                        end
                        local primeBlock = false
                        if damage > 0 and isBlocking and blockAnim > 0 then
                            -- Prime block: raised at/after enemy attack start and before hit connect.
                            if blockStartFrame
                                and blockStartFrame >= (s.attackStartTick or -1000)
                                and blockStartFrame <= simTickCount then
                                primeBlock = true
                                damage = 0
                            else
                                local blockReduction = 0.5 + ((PLAYER_SHIELD_BONUS_PERCENT or 0) / 100.0)
                                if blockReduction > 0.9 then blockReduction = 0.9 end
                                if blockReduction < 0 then blockReduction = 0 end
                                damage = math.floor(damage * (1.0 - blockReduction) + 0.5)
                                if damage < 0 then damage = 0 end
                            end
                        end
                        if damage > 0 then
                            playerHealth = playerHealth - damage
                            dispatchRunScoreEvent("player_damaged", {level_id = currentLevel, points = 0})
                            recordDamageTaken(damage)
                            if playerHealth <= 0 then
                                playerHealth = 0
                                enterGameOverState()
                            end
                        end
                        if isBlocking and blockAnim > 0 then
                            local pct = 0.0
                            if rawDamage > 0 then
                                pct = (rawDamage - damage) / rawDamage
                                if pct < 0 then pct = 0 end
                                if pct > 1 then pct = 1 end
                            end
                            lastBlockEvent = {
                                amount = rawDamage - damage,
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

function updateDeathAnimations()
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
function createBloodEffect(worldX, worldY)
    local effect = acquireBloodEffect()
    effect.x = worldX
    effect.y = worldY
    effect.life = 30  -- frames
    local particles = effect.particles
    -- Create blood particles radiating outward.
    local particleCount = BLOOD_PARTICLE_COUNT or 12
    for i = 1, particleCount do
        local angle = (i / particleCount) * 6.28318
        local speed = 0.05 + (frameCount % 10) * 0.005
        local p = particles[i]
        if not p then
            p = {dx = 0, dy = 0, ox = 0, oy = 0}
            particles[i] = p
        end
        p.dx = math.cos(angle) * speed
        p.dy = math.sin(angle) * speed
        p.ox = 0
        p.oy = 0
    end
    bloodEffects[#bloodEffects + 1] = effect
end

-- Update blood effects
function updateBloodEffects()
    local i = 1
    while i <= #bloodEffects do
        local e = bloodEffects[i]
        e.life = e.life - 1
        -- Move particles outward
        for j = 1, #e.particles do
            local p = e.particles[j]
            p.ox = p.ox + p.dx
            p.oy = p.oy + p.dy
        end
        if e.life <= 0 then
            -- PERFORMANCE: swap-and-pop for O(1) removal instead of O(n)
            local lastIdx = #bloodEffects
            local deadEffect = bloodEffects[i]
            bloodEffects[i] = bloodEffects[lastIdx]
            bloodEffects[lastIdx] = nil
            releaseBloodEffect(deadEffect)
            -- Don't increment i since we swapped in a new element to check
        else
            i = i + 1
        end
    end
end

-- Kill a soldier and create death effects
function killSoldier(soldier)
    soldier.alive = false
    soldier.hp = 0
    soldier.dying = true
    soldier.dead = false
    soldier.deathFrame = 1
    soldier.deathTick = 0
    soldiersKilled = soldiersKilled + 1
    awardPlayerXp(PLAYER_XP_PER_KILL or 0)
    dispatchRunScoreEvent("enemy_kill", {level_id = currentLevel})

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
        dispatchRunScoreEvent("level_clear", {level_id = currentLevel})
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
function checkHealthPickups()
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
                dispatchRunScoreEvent("health_pickup", {level_id = currentLevel})
            end
        end
    end
end

function checkWorldItemPickups()
    if not sprites or #sprites == 0 then
        return
    end
    local pickupRangeSq = ITEM_PICKUP_RANGE_SQ or 0.6084
    for i = 1, #sprites do
        local s = sprites[i]
        if s and s.t == 8 and not s.collected then
            local dx = (s.x or 0) - px
            local dy = (s.y or 0) - py
            local distSq = (dx * dx) + (dy * dy)
            if distSq <= pickupRangeSq then
                local itemId = s.item_id
                local okAdd, errAdd = tryAddItemToInventory(itemId, 1)
                if okAdd then
                    s.collected = true
                    dispatchRunScoreEvent("item_pickup", {level_id = currentLevel})
                    setLootFeedMessage("PICKED UP: " .. formatLootItemName(itemId))
                else
                    if errAdd == "TOO HEAVY" then
                        setLootFeedMessage("TOO HEAVY: " .. formatLootItemName(itemId))
                    else
                        setLootFeedMessage("CANNOT PICK UP")
                    end
                end
            end
        end
    end
end

local drawUiText
local drawUiPanel

-- Draw win screen
function drawWinScreen()
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
function drawHealthUI()
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

function drawEnemiesRemainingUI()
    local remaining = (totalSoldiers or 0) - (soldiersKilled or 0)
    if remaining < 0 then remaining = 0 end
    setFontCached(vmupro.text.FONT_SMALL)
    drawUiText("ENEMIES LEFT: " .. tostring(remaining), 104, 228, COLOR_WHITE, COLOR_BLACK)
end

function drawRunScoreUI()
    if gameState ~= STATE_PLAYING and gameState ~= STATE_WIN then
        return
    end
    local run = ensureRunScoreState(currentLevel)
    local scoreValue = math.floor(tonumber(run.current) or 0)
    local killValue = math.floor(tonumber(run.kills) or 0)
    local clearValue = math.floor(tonumber(run.levels_cleared) or 0)

    local scoreColor = COLOR_WHITE
    if (RUN_SCORE_PULSE_TICKS or 0) > 0 then
        if ((RUN_SCORE_PULSE_TICKS % 4) < 2) then
            scoreColor = COLOR_YELLOW
        end
        RUN_SCORE_PULSE_TICKS = RUN_SCORE_PULSE_TICKS - 1
        if RUN_SCORE_PULSE_TICKS < 0 then
            RUN_SCORE_PULSE_TICKS = 0
        end
    end

    setFontCached(vmupro.text.FONT_TINY_6x8)
    drawUiText("SCORE " .. tostring(scoreValue), 126, 24, scoreColor, COLOR_BLACK)
    drawUiText("K " .. tostring(killValue) .. "  C " .. tostring(clearValue), 126, 34, COLOR_WHITE, COLOR_BLACK)
end

local drawRectOutline

drawUiText = function(text, x, y, textColor, bgColor)
    local fg = textColor or COLOR_WHITE
    local bg = bgColor
    -- Keep solid text backgrounds for non-menu UI labels.
    if bg == nil or bg == COLOR_BLACK then
        bg = UI_TEXT_SOLID_BG or COLOR_DARK_GRAY
    end
    vmupro.graphics.drawText(text, x, y, fg, bg)
end

function drawMenuText(text, x, y, textColor)
    local fg = textColor or COLOR_WHITE
    vmupro.graphics.drawTextTransparent(text, x, y, fg)
end

drawUiPanel = function(x1, y1, x2, y2, fillColor, borderColor)
    -- Keep menu overlays lightweight: outline only, no stipple fill.
    drawRectOutline(x1, y1, x2, y2, borderColor or COLOR_GRAY)
end

function drawPerfMonitorOverlay()
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
    drawMenuText(string.format("PF F%.2f R%.2f W%.2f G%.2f", frameMs, rayMs, wallMs, fogMs), baseX, baseY + (rowStep * 0), COLOR_WHITE)
    drawMenuText(string.format("PF C%d T%d FB%d FG%d", PERF_MONITOR_WALL_COLS_TOTAL or 0, PERF_MONITOR_WALL_COLS_TEXTURED or 0, PERF_MONITOR_WALL_COLS_FALLBACK or 0, PERF_MONITOR_FOG_COLS or 0), baseX, baseY + (rowStep * 1), COLOR_WHITE)
    drawMenuText("PF " .. raysLabel .. "->" .. effLabel .. " " .. modeLabel .. string.format(" B%d R%d S%d", moveBlocked, wallRecoveries, rayStartSolid), baseX, baseY + (rowStep * 2), COLOR_WHITE)
    drawMenuText(string.format("DB %s DU%.1fK DL%.1fK", dbLabel, deltaUsageKB, deltaLargestKB), baseX, baseY + (rowStep * 3), COLOR_WHITE)
    drawMenuText(string.format("W1=%s K=%s P=%s", wallFmtLabel, wallKeyLabel, wallProjLabel), baseX, baseY + (rowStep * 4), COLOR_WHITE)
    drawMenuText(string.format("MP %d/%d/%d/%d/%d", PERF_MONITOR_MIP_COLS_0 or 0, PERF_MONITOR_MIP_COLS_1 or 0, PERF_MONITOR_MIP_COLS_2 or 0, PERF_MONITOR_MIP_COLS_3 or 0, PERF_MONITOR_MIP_COLS_4 or 0), baseX, baseY + (rowStep * 5), COLOR_WHITE)
    drawMenuText(string.format("SC I%.2f A%.2f S%.2f L%.2f", inputMs, audioMs, simMs, logicMs), baseX, baseY + (rowStep * 6), COLOR_WHITE)
    drawMenuText(string.format("SC R%.2f P%.2f Z%.2f", renderMs, presentMs, sleepMs), baseX, baseY + (rowStep * 7), COLOR_WHITE)
end

function buildDebugMenuItems()
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
        local drawDistText = "DRAW DIST: " .. getDistanceValueLabel(EXP_TEX_MAX_DIST or 0)
        local farTexOffText
        if (FAR_TEX_OFF_DIST or 999) >= 900 then
            farTexOffText = "FAR TEX OFF: OFF"
        else
            farTexOffText = "FAR TEX OFF: " .. getDistanceValueLabel(FAR_TEX_OFF_DIST or 0)
        end
        local mip1DistText = "MIP1 DIST: " .. getDistanceValueLabel(WALL_MIPMAP_DIST1 or 0)
        local mip2DistText = "MIP2 DIST: " .. getDistanceValueLabel(WALL_MIPMAP_DIST2 or 0)
        local mip3DistText = "MIP3 DIST: " .. getDistanceValueLabel(WALL_MIPMAP_DIST3 or 0)
        local mip4DistText = "MIP4 DIST: " .. getDistanceValueLabel(WALL_MIPMAP_DIST4 or 0)
        local fogStartText = "FOG START: " .. getDistanceValueLabel(FOG_START or 0)
        local fogEndText = "FOG FULL: " .. getDistanceValueLabel(FOG_END or 0)
        local fogCutText = "FOG CUT L: " .. getDistanceValueLabel(FOG_TEX_CUTOFF or 0)
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
        local drawDistText = "DRAW DIST: " .. getDistanceValueLabel(EXP_TEX_MAX_DIST or 0)
        local farTexText = ((FAR_TEX_OFF_DIST or 999) >= 900) and "FAR TEX OFF: OFF" or ("FAR TEX OFF: " .. getDistanceValueLabel(FAR_TEX_OFF_DIST or 0))
        local mipmapText = "MIPMAP: " .. (WALL_MIPMAP_ENABLED and "ON" or "OFF")
        local mipLodText = "MIP LOD: " .. (MIP_LOD_ENABLED and "ON" or "OFF")
        local fogStartText = "FOG START: " .. getDistanceValueLabel(FOG_START or 0)
        local fogEndText = "FOG FULL: " .. getDistanceValueLabel(FOG_END or 0)
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
function getDebugMenuItemCount()
    if titleDebugPage == DEBUG_PAGE_VIDEO then
        return 24
    end
    if titleDebugPage == DEBUG_PAGE_PERF then
        return 15
    end
    return 12
end

function stepListIndex(idx, delta, count, wrap)
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

function getDebugAdjustDelta()
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

function stepFpsTarget(delta, wrap)
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

function stepAudioMixTarget(delta, wrap)
    if not AUDIO_MIX_HZ_PRESETS or #AUDIO_MIX_HZ_PRESETS == 0 then
        return
    end
    AUDIO_MIX_HZ_INDEX = stepListIndex(AUDIO_MIX_HZ_INDEX or #AUDIO_MIX_HZ_PRESETS, delta, #AUDIO_MIX_HZ_PRESETS, wrap == true)
    setAudioMixHz(AUDIO_MIX_HZ_PRESETS[AUDIO_MIX_HZ_INDEX])
end

function stepWall1FormatVariant(delta, wrap)
    if not WALL1_FORMAT_VARIANTS or #WALL1_FORMAT_VARIANTS == 0 then
        return
    end
    WALL1_FORMAT_INDEX = stepListIndex(WALL1_FORMAT_INDEX or 1, delta, #WALL1_FORMAT_VARIANTS, wrap == true)
    if not DEBUG_DISABLE_WALL_TEXTURE then
        unloadWallTextures()
        loadWallTextures()
    end
end

function adjustDebugMenuSelection(sel, delta, wrap)
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
                normalizeDrawDistanceSetting()
                normalizeMipmapRanges()
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
                stepMipmapLevelIndex(1, step)
            end
            return true
        elseif sel == 10 then
            if MIPMAP_DIST_PRESETS and #MIPMAP_DIST_PRESETS > 0 then
                stepMipmapLevelIndex(2, step)
            end
            return true
        elseif sel == 11 then
            if MIPMAP_DIST_PRESETS and #MIPMAP_DIST_PRESETS > 0 then
                stepMipmapLevelIndex(3, step)
            end
            return true
        elseif sel == 12 then
            if MIPMAP_DIST_PRESETS and #MIPMAP_DIST_PRESETS > 0 then
                stepMipmapLevelIndex(4, step)
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
                normalizeDrawDistanceSetting()
                normalizeMipmapRanges()
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
        clearSpriteOrderCache()
        return true
    elseif sel == 4 then
        -- PROPS label is inverse of DEBUG_DISABLE_PROPS.
        DEBUG_DISABLE_PROPS = (step < 0)
        clearSpriteOrderCache()
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

function applyDebugMenuSelection(sel)
    return sel == getDebugMenuItemCount()
end

drawRectOutline = function(x1, y1, x2, y2, color)
    vmupro.graphics.drawLine(x1, y1, x2, y1, color)
    vmupro.graphics.drawLine(x1, y2, x2, y2, color)
    vmupro.graphics.drawLine(x1, y1, x1, y2, color)
    vmupro.graphics.drawLine(x2, y1, x2, y2, color)
end

-- Draw title screen
function drawTitleScreenImpl()
    logBoot(vmupro.system.LOG_ERROR, "C drawTitleScreen")
    -- Draw title background image
    if titleSprite then
        vmupro.sprite.draw(titleSprite, 0, 0, vmupro.sprite.kImageUnflipped)
    else
        vmupro.graphics.clear(COLOR_BLACK)
    end

    if titleInClassSelect then
        vmupro.graphics.clear(COLOR_DARK_GRAY)

        local classId = getClassIdForSelection(titleClassSelection)
        local classDef = getClassDefById(classId)
        local className = string.upper(getClassName(classId))

        vmupro.graphics.drawFillRect(8, 8, 232, 32, COLOR_GRAY)
        drawRectOutline(8, 8, 232, 32, COLOR_LIGHT_GRAY)
        setFontCached(vmupro.text.FONT_SMALL)
        local titleText = "< " .. className .. " >"
        local titleX = 120 - math.floor((#titleText * 8) / 2)
        if titleX < 12 then titleX = 12 end
        drawMenuText(titleText, titleX, 14, COLOR_BLACK)

        vmupro.graphics.drawFillRect(8, 40, 116, 232, COLOR_GRAY)
        drawRectOutline(8, 40, 116, 232, COLOR_LIGHT_GRAY)
        vmupro.graphics.drawFillRect(124, 40, 232, 232, COLOR_GRAY)
        drawRectOutline(124, 40, 232, 232, COLOR_LIGHT_GRAY)

        local classPortrait = nil
        if classPortraitSprites and classPortraitSprites[classId] then
            classPortrait = classPortraitSprites[classId]
        else
            classPortrait = classPortraitSprite
        end
        if classPortrait and classPortrait.width and classPortrait.height then
            local desiredHeight = 187 -- 15% larger than previous 163px target
            local scaleY = safeDivide(desiredHeight, classPortrait.height, "titleClassPortraitSingle")
            local scaleX = scaleY
            if classId == "archer" then
                scaleY = scaleY * 1.10 -- Increase Archer height by 10%
                scaleX = scaleX * 0.92 -- Reduce Archer width by an additional 3% (total 8%)
            end
            local scaledW = classPortrait.width * scaleX
            local scaledH = classPortrait.height * scaleY
            local drawX = 178 - math.floor(scaledW / 2)
            local drawY = 224 - math.floor(scaledH)
            if drawY < 40 then drawY = 40 end
            vmupro.sprite.drawScaled(classPortrait, drawX, drawY, scaleX, scaleY, vmupro.sprite.kImageUnflipped)
        end

        local stats = getClassTemplateStats(classId, classDef)
        local statAgi = toNumber(stats.agility, 0.0)
        local statPow = toNumber(stats.power, 0.0)
        local statDef = toNumber(stats.defense, 0.0)
        local statDod = toNumber(stats.dodge, 0.0)
        local statReg = toNumber(stats.regen, 0.0)
        local statCrit = toNumber(stats.crit, 0.0)
        local statAtkSpd = toNumber(stats.atk_speed, 0.0)
        local statShield = toNumber(stats.shield_bonus, 0.0)
        local statStartY = 62
        local statStepY = 14 -- Extra spacing so rows do not visually touch

        -- Styled header: larger font, faux-bold pass, and underline
        setFontCached(vmupro.text.FONT_SMALL)
        drawMenuText("[STATS]", 30, 45, COLOR_BLACK)
        drawMenuText("[STATS]", 31, 45, COLOR_BLACK)
        vmupro.graphics.drawFillRect(30, 59, 90, 60, COLOR_BLACK)
        setFontCached(vmupro.text.FONT_TINY_6x8)
        drawMenuText("AGILITY", 12, statStartY + (statStepY * 0), COLOR_BLACK)
        drawMenuText(string.format("%.2f", statAgi), 76, statStartY + (statStepY * 0), COLOR_BLACK)
        drawMenuText("POWER", 12, statStartY + (statStepY * 1), COLOR_BLACK)
        drawMenuText(string.format("%.2f", statPow), 76, statStartY + (statStepY * 1), COLOR_BLACK)
        drawMenuText("DEF", 12, statStartY + (statStepY * 2), COLOR_BLACK)
        drawMenuText(string.format("%.2f", statDef), 76, statStartY + (statStepY * 2), COLOR_BLACK)
        drawMenuText("DODGE", 12, statStartY + (statStepY * 3), COLOR_BLACK)
        drawMenuText(string.format("%.2f", statDod), 76, statStartY + (statStepY * 3), COLOR_BLACK)
        drawMenuText("REGEN", 12, statStartY + (statStepY * 4), COLOR_BLACK)
        drawMenuText(string.format("%.2f", statReg), 76, statStartY + (statStepY * 4), COLOR_BLACK)
        drawMenuText("CRIT", 12, statStartY + (statStepY * 5), COLOR_BLACK)
        drawMenuText(string.format("%.2f", statCrit), 76, statStartY + (statStepY * 5), COLOR_BLACK)
        drawMenuText("ATK SP", 12, statStartY + (statStepY * 6), COLOR_BLACK)
        drawMenuText(string.format("%.2f", statAtkSpd), 76, statStartY + (statStepY * 6), COLOR_BLACK)
        drawMenuText("SHIELD", 12, statStartY + (statStepY * 7), COLOR_BLACK)
        drawMenuText(string.format("%.2f", statShield), 76, statStartY + (statStepY * 7), COLOR_BLACK)

        vmupro.graphics.drawFillRect(0, 220, 239, 239, COLOR_GRAY)
        drawRectOutline(0, 220, 239, 239, COLOR_LIGHT_GRAY)
        setFontCached(vmupro.text.FONT_TINY_6x8)
        drawUiText("LEFT/RIGHT CHANGE   A CONTINUE   B BACK", 3, 227, COLOR_BLACK, COLOR_GRAY)
    elseif titleInLoadMenu then
        drawUiPanel(16, 44, 224, 239, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
        drawUiPanel(26, 54, 214, 76, COLOR_MAROON, COLOR_WHITE)
        setFontCached(vmupro.text.FONT_SMALL)
        drawMenuText("LOAD GAME", 74, 59, COLOR_WHITE)
        for i = 1, SAVE_SLOT_COUNT do
            local y = 86 + (i - 1) * 48
            local textColor = COLOR_LIGHT_GRAY
            if i == titleLoadSelection then
                drawUiPanel(26, y, 214, y + 38, COLOR_MAROON, COLOR_WHITE)
                textColor = COLOR_WHITE
            end
            local line1, line2 = getSaveSlotSummary(i)
            setFontCached(vmupro.text.FONT_SMALL)
            drawMenuText(line1, 34, y + 4, textColor)
            setFontCached(vmupro.text.FONT_TINY_6x8)
            drawMenuText(line2, 34, y + 22, textColor)
        end
        setFontCached(vmupro.text.FONT_TINY_6x8)
        drawMenuText("A/MODE LOAD  B BACK", 56, 228, COLOR_WHITE)
    elseif titleInOptions then
        -- Options submenu
        logBoot(vmupro.system.LOG_ERROR, "D title options text")
        -- Large single-column menu box (extend to bottom)
        drawUiPanel(20, 50, 220, 239, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
        drawUiPanel(30, 60, 210, 82, COLOR_MAROON, COLOR_WHITE)
        setFontCached(vmupro.text.FONT_TINY_6x8)
        drawMenuText(titleInDebug and "DEBUG" or "OPTIONS", 92, 65, COLOR_WHITE)

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
            local textColor = COLOR_GRAY
            if i == sel then
                local boxH = titleInDebug and 12 or 18
                drawUiPanel(32, y, 208, y + boxH, COLOR_MAROON, COLOR_WHITE)
                textColor = COLOR_WHITE
            end
            setFontCached(vmupro.text.FONT_TINY_6x8)
            drawMenuText(item, x, y + 2, textColor)
            drawRow = drawRow + 1
        end
        if titleInDebug then
            setFontCached(vmupro.text.FONT_TINY_6x8)
            drawMenuText("L/R ADJUST", 34, 226, COLOR_WHITE)
        end
    else
        -- Main title menu
        logBoot(vmupro.system.LOG_ERROR, "D title main text")
        -- Compact menu box for 4 items
        drawUiPanel(52, 132, 188, 232, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
        setFontCached(vmupro.text.FONT_SMALL)
        for i = 1, #TITLE_MAIN_MENU_ITEMS do
            local item = TITLE_MAIN_MENU_ITEMS[i]
            local y = 142 + (i - 1) * 22
            local textColor = COLOR_GRAY
            if i == titleSelection then
                drawUiPanel(62, y, 178, y + 20, COLOR_MAROON, COLOR_WHITE)
                textColor = COLOR_WHITE
            end
            setFontCached(vmupro.text.FONT_SMALL)
            drawMenuText(item, 72, y + 3, textColor)
        end
        setFontCached(vmupro.text.FONT_TINY_6x8)
        drawMenuText("BUILD " .. tostring(BUILD_COUNT or 0), 8, 232, COLOR_WHITE)
    end
end

drawTitleScreen = drawTitleScreenImpl
logBoot(vmupro.system.LOG_ERROR, "drawTitleScreen bound to impl")

-- Draw game over screen
function drawGameOver()
    local run = ensureRunScoreState(currentLevel)
    local scoreValue = math.floor(tonumber(run.current) or 0)
    local levelValue = getCurrentRunLevelValue()

    drawUiPanel(26, 58, 214, 222, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
    drawUiPanel(36, 68, 204, 90, COLOR_MAROON, COLOR_WHITE)
    setFontCached(vmupro.text.FONT_SMALL)
    drawMenuText("GAME OVER", 74, 73, COLOR_WHITE)

    setFontCached(vmupro.text.FONT_TINY_6x8)
    drawMenuText("SCORE " .. tostring(scoreValue), 42, 96, COLOR_WHITE)
    drawMenuText("LEVEL " .. tostring(levelValue), 142, 96, COLOR_WHITE)

    if gameOverInitialsActive then
        drawUiPanel(38, 108, 202, 186, COLOR_DARK_GRAY, COLOR_WHITE)
        setFontCached(vmupro.text.FONT_SMALL)
        drawMenuText("NEW HIGH SCORE", 50, 114, COLOR_WHITE)

        for i = 1, 3 do
            local x = 90 + ((i - 1) * 24)
            local fg = COLOR_GRAY
            if i == gameOverInitialsCursor then
                drawUiPanel(x - 5, 136, x + 13, 156, COLOR_MAROON, COLOR_WHITE)
                fg = COLOR_WHITE
            end
            setFontCached(vmupro.text.FONT_SMALL)
            drawMenuText((gameOverInitialsChars and gameOverInitialsChars[i]) or "A", x, 140, fg)
        end

        setFontCached(vmupro.text.FONT_TINY_6x8)
        drawMenuText("UP/DN LETTER  LT/RT SLOT", 44, 164, COLOR_WHITE)
        drawMenuText("A NEXT/SUBMIT  B SUBMIT", 46, 176, COLOR_WHITE)
        return
    end

    for i = 1, #GAME_OVER_MENU_ITEMS do
        local item = GAME_OVER_MENU_ITEMS[i]
        local y = 112 + (i - 1) * 18
        local textColor = COLOR_GRAY
        if i == gameOverSelection then
            drawUiPanel(44, y, 196, y + 18, COLOR_MAROON, COLOR_WHITE)
            textColor = COLOR_WHITE
        end
        setFontCached(vmupro.text.FONT_SMALL)
        drawMenuText(item, 80, y + 2, textColor)
    end

    local state = ensureHighScoreState()
    local entries = state.entries or {}
    setFontCached(vmupro.text.FONT_TINY_6x8)
    drawMenuText("TOP SCORES", 42, 170, COLOR_WHITE)
    for i = 1, 3 do
        local e = entries[i]
        local line = tostring(i) .. ". --- 0 L1"
        if e then
            local initials = tostring(e.initials or "AAA")
            local entryScore = math.floor(tonumber(e.score) or 0)
            local entryLevel = math.floor(tonumber(e.level) or 1)
            if entryLevel < 1 then entryLevel = 1 end
            line = tostring(i) .. ". " .. initials .. " " .. tostring(entryScore) .. " L" .. tostring(entryLevel)
        end
        drawMenuText(line, 42, 180 + ((i - 1) * 10), COLOR_WHITE)
    end
    if gameOverScoreStatus and gameOverScoreStatus ~= "" then
        drawMenuText(gameOverScoreStatus, 42, 214, COLOR_WHITE)
    end
end

-- Reset game state for restart
function resetGame()
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

function getWallColor(wtype, side)
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

function getPlayerCollisionRadius()
    local r = PLAYER_COLLISION_RADIUS or 0.27
    if r < 0.1 then r = 0.1 end
    return r
end

function isWalkableWithRadius(x, y, radius)
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

function updatePlayerSafetyAnchor()
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

function recoverPlayerFromWallPenetration()
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

function spawnPlayerProjectile(weaponClass, hitDamage, speedMult, rangeMult, projectileSpeedMult)
    if not map then
        return false
    end
    if not playerProjectiles then
        playerProjectiles = {}
    end
    if #playerProjectiles >= (PROJECTILE_MAX_ACTIVE or 24) then
        local oldest = table.remove(playerProjectiles, 1)
        releaseProjectile(oldest)
    end

    local dir = pdir % 64
    local dx = cosTable[dir] or 0
    local dy = sinTable[dir] or 0
    local spawnDist = 0.32
    local spawnX = px + (dx * spawnDist)
    local spawnY = py + (dy * spawnDist)
    local wallRadius = PROJECTILE_WALL_RADIUS or 0.05
    if not isWalkableWithRadius(spawnX, spawnY, wallRadius) then
        spawnX = px
        spawnY = py
    end

    local classValue = normalizeWeaponClass(weaponClass)
    local baseSpeed = PROJECTILE_SPEED_RANGED or 10.0
    if classValue == WEAPON_CLASS_MAGIC then
        baseSpeed = PROJECTILE_SPEED_MAGIC or 8.5
    end
    local speed = baseSpeed * (tonumber(speedMult) or 1.0) * (tonumber(projectileSpeedMult) or 1.0)
    if speed < 3.0 then speed = 3.0 end
    if speed > 20.0 then speed = 20.0 end

    local damage = math.floor(tonumber(hitDamage) or 1)
    if damage < 1 then damage = 1 end

    local baseRange = PROJECTILE_MAX_RANGE_RANGED or 4.0
    if classValue == WEAPON_CLASS_MAGIC then
        baseRange = PROJECTILE_MAX_RANGE_MAGIC or 5.0
    end
    local maxRange = baseRange * (tonumber(rangeMult) or 1.0)
    if maxRange < 1.0 then maxRange = 1.0 end
    if maxRange > 12.0 then maxRange = 12.0 end

    local projectile = acquireProjectile()
    projectile.id = projectileNextId or 1
    projectile.weaponClass = classValue
    projectile.x = spawnX
    projectile.y = spawnY
    projectile.startX = spawnX
    projectile.startY = spawnY
    projectile.dx = dx
    projectile.dy = dy
    projectile.speed = speed
    projectile.damage = damage
    projectile.maxRangeSq = maxRange * maxRange
    projectile.ttl = PROJECTILE_LIFETIME_TICKS or math.floor((SIM_TARGET_HZ or 24) * 2.5)
    projectileNextId = (projectileNextId or 1) + 1
    if projectileNextId > 1000000 then
        projectileNextId = 1
    end
    playerProjectiles[#playerProjectiles + 1] = projectile
    return true
end

function releaseBowChargeShot(profDamageMult, profSpeedMult)
    if not bowChargeState.active or isAttacking > 0 then
        return false
    end
    local stage = getBowChargeCurrentStage()
    local dmgStageMult = tonumber(bowChargeState.damageMult and bowChargeState.damageMult[stage]) or 1.0
    local rangeStageMult = tonumber(bowChargeState.rangeMult and bowChargeState.rangeMult[stage]) or 1.0
    local speedStageMult = tonumber(bowChargeState.speedMult and bowChargeState.speedMult[stage]) or 1.0
    local profDamage = tonumber(profDamageMult) or 1.0
    local profSpeed = tonumber(profSpeedMult) or 1.0
    if profDamage < 1.0 then profDamage = 1.0 end
    if profSpeed < 0.01 then profSpeed = 1.0 end

    local hitDamage = math.floor(((PLAYER_DAMAGE or 0) * profDamage * dmgStageMult) + 0.5)
    if hitDamage < 1 then hitDamage = 1 end

    local attackFrames = #bowAttack
    local baseAttackFrames = (attackFrames > 0) and 7 or 8
    local attackScale = (PLAYER_ATTACK_SPEED_SCALE or 1.0) / profSpeed
    attackScale = attackScale * (0.94 + ((stage - 1) * 0.08))
    local scaledAttackFrames = math.floor((baseAttackFrames * attackScale) + 0.5)
    if scaledAttackFrames < (PLAYER_ATTACK_MIN_FRAMES or 5) then
        scaledAttackFrames = (PLAYER_ATTACK_MIN_FRAMES or 5)
    end
    if scaledAttackFrames > (PLAYER_ATTACK_MAX_FRAMES or 18) then
        scaledAttackFrames = (PLAYER_ATTACK_MAX_FRAMES or 18)
    end

    attackTotalFrames = scaledAttackFrames
    isAttacking = attackTotalFrames
    lastAttackWeaponClass = WEAPON_CLASS_RANGED

    spawnPlayerProjectile(WEAPON_CLASS_RANGED, hitDamage, profSpeed, rangeStageMult, speedStageMult)
    resetBowChargeState()
    return true
end

function tryHitEnemyWithProjectile(projectile, hitX, hitY)
    if not sprites or #sprites == 0 then
        return false
    end
    local hitRadius = PROJECTILE_HIT_RADIUS or 0.30
    local hitRadiusSq = hitRadius * hitRadius
    for i = 1, #sprites do
        local s = sprites[i]
        if s and s.t == 5 and s.alive then
            local dx = hitX - s.x
            local dy = hitY - s.y
            local distSq = dx * dx + dy * dy
            if distSq <= hitRadiusSq then
                local hitDamage = math.floor(tonumber(projectile and projectile.damage) or 1)
                if hitDamage < 1 then hitDamage = 1 end
                local critSalt = ((projectile and projectile.id) or 0) * 131 + (i * 199) + (simTickCount or 0)
                if deterministicPercentRoll(PLAYER_CRIT_PERCENT or 0, critSalt) then
                    hitDamage = math.floor((hitDamage * (PLAYER_CRIT_MULT or 1.5)) + 0.5)
                end
                if hitDamage < 1 then hitDamage = 1 end
                s.hp = (s.hp or ENEMY_MAX_HP) - hitDamage
                recordDamageDealt(hitDamage)
                if s.hp <= 0 then
                    killSoldier(s)
                end
                return true
            end
        end
    end
    return false
end

function updatePlayerProjectiles()
    if not playerProjectiles or #playerProjectiles == 0 then
        return
    end
    local simHz = SIM_TARGET_HZ or 24
    if simHz < 1 then simHz = 24 end
    local wallRadius = PROJECTILE_WALL_RADIUS or 0.05
    local subStep = PROJECTILE_STEP or 0.12
    if subStep < 0.02 then subStep = 0.02 end
    if subStep > 0.25 then subStep = 0.25 end

    local i = 1
    while i <= #playerProjectiles do
        local p = playerProjectiles[i]
        local removeProjectile = false
        if not p then
            removeProjectile = true
        else
            local speed = tonumber(p.speed) or (PROJECTILE_SPEED_RANGED or 10.0)
            if speed < 0.1 then speed = 0.1 end
            local moveDist = speed / simHz
            local remaining = moveDist
            while remaining > 0 and not removeProjectile do
                local step = subStep
                if step > remaining then
                    step = remaining
                end
                local nextX = p.x + ((p.dx or 0) * step)
                local nextY = p.y + ((p.dy or 0) * step)
                if not isWalkableWithRadius(nextX, nextY, wallRadius) then
                    removeProjectile = true
                    break
                end
                p.x = nextX
                p.y = nextY
                if tryHitChestWithProjectile(p, nextX, nextY) then
                    removeProjectile = true
                    break
                end
                if not DEBUG_DISABLE_ENEMIES and tryHitEnemyWithProjectile(p, nextX, nextY) then
                    removeProjectile = true
                    break
                end
                local maxRangeSq = tonumber(p.maxRangeSq) or 0
                if maxRangeSq > 0 then
                    local dxTravel = (p.x or 0) - (p.startX or p.x or 0)
                    local dyTravel = (p.y or 0) - (p.startY or p.y or 0)
                    if (dxTravel * dxTravel + dyTravel * dyTravel) >= maxRangeSq then
                        removeProjectile = true
                        break
                    end
                end
                remaining = remaining - step
            end
            p.ttl = (p.ttl or 0) - 1
            if p.ttl <= 0 then
                removeProjectile = true
            end
        end

        if removeProjectile then
            local last = #playerProjectiles
            local deadProjectile = playerProjectiles[i]
            playerProjectiles[i] = playerProjectiles[last]
            playerProjectiles[last] = nil
            releaseProjectile(deadProjectile)
        else
            i = i + 1
        end
    end
end

function drawPlayerProjectiles()
    if not playerProjectiles or #playerProjectiles == 0 then
        return
    end
    local dir = pdir % 64
    local cosDir = cosTable[dir] or 1
    local sinDir = sinTable[dir] or 0
    for i = 1, #playerProjectiles do
        local p = playerProjectiles[i]
        if p then
            local sdx = (p.x or 0) - px
            local sdy = (p.y or 0) - py
            local relX = (sdx * sinDir) - (sdy * cosDir)
            local relY = (sdx * cosDir) + (sdy * sinDir)
            if relY > 0.05 then
                local sx = math.floor(120 + ((relX / relY) * 120))
                if sx >= -12 and sx <= 252 then
                    local cx = sx
                    if cx < 0 then cx = 0 end
                    if cx > 239 then cx = 239 end
                    local wallDist = expDepthBuf and expDepthBuf[cx] or nil
                    if (not wallDist) or (relY <= (wallDist + 0.03)) then
                        local size = math.floor((VIEWPORT_H * 0.18) / relY)
                        if size < 2 then size = 2 end
                        if size > 20 then size = 20 end
                        local drawY = HORIZON - math.floor(size / 2)
                        local spriteRef = projectileArrowSprite
                        local color = COLOR_YELLOW
                        if p.weaponClass == WEAPON_CLASS_MAGIC then
                            spriteRef = projectileMagicSprite
                            color = COLOR_LIGHT_BLUE
                        end
                        if spriteRef and spriteRef.width and spriteRef.height and spriteRef.height > 0 then
                            local scale = size / spriteRef.height
                            if scale < 0.1 then scale = 0.1 end
                            local drawX = sx - math.floor((spriteRef.width * scale) / 2)
                            local topY = drawY - math.floor((spriteRef.height * scale) / 2)
                            vmupro.sprite.drawScaled(spriteRef, drawX, topY, scale, scale, vmupro.sprite.kImageUnflipped)
                        else
                            local half = math.max(1, math.floor(size / 3))
                            vmupro.graphics.drawFillRect(sx - half, drawY - half, sx + half, drawY + half, color)
                        end
                    end
                end
            end
        end
    end
end

function movePlayerStrict(deltaX, deltaY)
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
    local holdWallContact = PLAYER_WALL_CONTACT_HOLD_FRAMES or 4
    if holdWallContact < 1 then holdWallContact = 1 end

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
        if not moved then
            if (PLAYER_WALL_CONTACT_FRAMES or 0) < holdWallContact then
                PLAYER_WALL_CONTACT_FRAMES = holdWallContact
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
        else
            -- Nothing moved for this substep; avoid re-testing the same blocked step repeatedly.
            break
        end
    end
    updatePlayerSafetyAnchor()
end

function movePlayerWithSlide(deltaX, deltaY)
    movePlayerStrict(deltaX, deltaY)
end

function getPlayerRenderNearClipDist()
    local nearClip = PLAYER_RENDER_NEAR_CLIP_DIST or 0.38
    if nearClip < 0.20 then nearClip = 0.20 end
    return nearClip
end

function getFogFactor(dist)
    if DEBUG_DISABLE_FOG then
        return 0.0
    end
    local lookup = FOG_LUT_LINEAR
    local invStep = FOG_LUT_INV_STEP or 0.0
    if lookup and #lookup > 0 and invStep > 0 then
        local idx = math.floor(((dist or 0.0) * invStep) + 0.5)
        if idx < 0 then
            return 0.0
        end
        local v = lookup[idx + 1]
        if v ~= nil then
            return v
        end
        return 1.0
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

function getFogQuantizedFactor(dist)
    if DEBUG_DISABLE_FOG then
        return 0.0
    end
    local lookup = FOG_LUT_QUANTIZED
    local invStep = FOG_LUT_INV_STEP or 0.0
    if lookup and #lookup > 0 and invStep > 0 then
        local idx = math.floor(((dist or 0.0) * invStep) + 0.5)
        if idx < 0 then
            return 0.0
        end
        local v = lookup[idx + 1]
        if v ~= nil then
            return v
        end
        return 1.0
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

function fogBlend(color, dist)
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

function getFogAccentColor(baseColor)
    local c = baseColor or COLOR_GRAY
    if c == COLOR_WHITE then return COLOR_LIGHT_GRAY end
    if c == COLOR_LIGHT_GRAY then return COLOR_WHITE end
    if c == COLOR_GRAY then return COLOR_LIGHT_GRAY end
    if c == COLOR_DARK_GRAY then return COLOR_GRAY end
    if c == COLOR_BLACK then return COLOR_DARK_GRAY end
    if c == COLOR_MAROON then return COLOR_DARK_GRAY end
    return COLOR_LIGHT_GRAY
end

local FOG_HATCH_PROFILES = {
    -- 1 = finest/thickest, 6 = ultra-light/cheapest
    [1] = {band_h = 1, fill_gate = 1, diag_a_step = 4,  diag_b_step = 6,  cross_enable_threshold = 2},
    [2] = {band_h = 2, fill_gate = 1, diag_a_step = 5,  diag_b_step = 7,  cross_enable_threshold = 3},
    [3] = {band_h = 3, fill_gate = 1, diag_a_step = 7,  diag_b_step = 10, cross_enable_threshold = 4},
    [4] = {band_h = 4, fill_gate = 2, diag_a_step = 9,  diag_b_step = 13, cross_enable_threshold = 5},
    [5] = {band_h = 5, fill_gate = 2, diag_a_step = 12, diag_b_step = 16, cross_enable_threshold = 6},
    [6] = {band_h = 6, fill_gate = 3, diag_a_step = 15, diag_b_step = 20, cross_enable_threshold = 7},
}

function drawFogOverlayArea(x1, y1, x2, y2, fogAlpha)
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
    local profile = FOG_HATCH_PROFILES[ditherSize] or FOG_HATCH_PROFILES[3]
    local bandH = profile.band_h or 3
    local fillGate = profile.fill_gate or 1
    local diagStepA = profile.diag_a_step or 7
    local diagStepB = profile.diag_b_step or 10
    local crossThresh = profile.cross_enable_threshold or 4
    if bandH < 1 then bandH = 1 end
    if fillGate < 1 then fillGate = 1 end
    if diagStepA < 2 then diagStepA = 2 end
    if diagStepB < 3 then diagStepB = 3 end

    if fogAlpha >= 1.0 then
        -- Full fog path must stay cheap: single fill call.
        vmupro.graphics.drawFillRect(x1, y1, x2, y2, fogPrimary)
        return
    end

    -- Quality ladder:
    -- lower dither profile = denser/thicker hatch
    -- higher dither profile = sparser/cheaper hatch
    local levels = 12
    local coverage = math.floor((fogAlpha * levels) + 0.5)
    if coverage < 1 then return end
    if coverage > levels then coverage = levels end
    local xCell = math.floor(x1 / bandH)
    local threshold = coverage / levels
    for y = y1, y2, bandH do
        local yb = y + bandH - 1
        if yb > y2 then yb = y2 end
        local rowIdx = math.floor(y / bandH)
        local bandMix = ((rowIdx * 3 + xCell) % levels) / levels
        local passFillGate = (fillGate <= 1) or (((rowIdx + xCell) % fillGate) == 0)
        if passFillGate and bandMix < threshold then
            vmupro.graphics.drawFillRect(x1, y, x2, yb, fogPrimary)
            if coverage >= 3 then
                local startA = x1 + ((rowIdx * bandH + x1) % diagStepA)
                if startA <= x2 then
                    vmupro.graphics.drawFillRect(startA, y, startA, yb, fogAccent)
                end
            end
            if coverage >= crossThresh then
                local rowPhase = (rowIdx * (bandH + 1) + x1) % diagStepB
                local startB = x1 + ((diagStepB - rowPhase) % diagStepB)
                if startB <= x2 then
                    vmupro.graphics.drawFillRect(startB, y, startB, yb, fogAccentCross)
                end
            end
        end
    end
end

function drawFogCurtainColumn(sx, ex, dist)
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

function drawBufferedFogCurtainSpan(spanStart, spanEnd, dist, trackCounters, canTime)
    if spanStart < 0 or spanEnd < spanStart then
        return
    end
    local spanW = (spanEnd - spanStart) + 1
    if trackCounters then
        PERF_MONITOR_FOG_COLS = (PERF_MONITOR_FOG_COLS or 0) + spanW
    end
    local fogT0
    if canTime then fogT0 = vmupro.system.getTimeUs() end
    drawFogCurtainColumn(spanStart, spanEnd, dist)
    if canTime and fogT0 then
        local fogT1 = vmupro.system.getTimeUs()
        PERF_MONITOR_SAMPLE_FOG_US = (PERF_MONITOR_SAMPLE_FOG_US or 0) + (fogT1 - fogT0)
    end
end

function getWallSheetForType(wtype)
    if wtype == 1 then return wallSheetStone end
    if wtype == 2 then return wallSheetBrick end
    if wtype == 3 then return wallSheetMoss end
    if wtype == 4 then return wallSheetMetal end
    if wtype == 5 then return wallSheetWood end
    if wtype == 6 then return wallSheetWindow end
    return wallSheetStone
end

wallSheetMetricCache = wallSheetMetricCache or {}
MIP_FRAME_GROUP_SIZE = MIP_FRAME_GROUP_SIZE or {[0] = 1, [1] = 1, [2] = 3, [3] = 4, [4] = 6}

function getWallSheetMetricsCached(wtype)
    local sheet = getWallSheetForType(wtype)
    if not sheet then
        return nil, 0, 0, 0
    end
    local cache = wallSheetMetricCache[wtype]
    if cache and cache.sheet == sheet then
        return sheet, cache.frameW or 0, cache.frameH or 0, cache.frameCount or 0
    end

    local frameW = sheet.frameWidth or 0
    local frameH = sheet.frameHeight or 0
    local frameCount = sheet.frameCount or 0
    if frameW <= 0 or frameH <= 0 or frameCount <= 0 then
        return nil, 0, 0, 0
    end

    if not cache then
        cache = {}
        wallSheetMetricCache[wtype] = cache
    end
    cache.sheet = sheet
    cache.frameW = frameW
    cache.frameH = frameH
    cache.frameCount = frameCount
    return sheet, frameW, frameH, frameCount
end

function drawWallTextureColumn(wtype, side, texCoord, sx, y1, y2, colW, distToWall, mipLevel, fogAlphaCached, trackCountersOpt, canTimeOpt)
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
    local sheet, frameW, frameH, frameCount = getWallSheetMetricsCached(wtype)
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
        local groupSize = MIP_FRAME_GROUP_SIZE[mip] or 6
        if groupSize > 1 and frameCount > groupSize then
            frameIndex = (math.floor((frameIndex - 1) / groupSize) * groupSize) + 1
            if frameIndex ~= frameIndex or frameIndex == math.huge or frameIndex == -math.huge then
                frameIndex = 1
            end
            if frameIndex > frameCount then frameIndex = frameCount end
        end
    end

    local texDrawWidth = drawWidth
    local seamNearDist = WALL_SEAM_DISABLE_NEAR_DIST or 1.35
    local allowSeamOverdraw = WALL_TEX_SEAM_OVERDRAW
    if distToWall and distToWall <= seamNearDist then
        allowSeamOverdraw = false
    end
    if allowSeamOverdraw and drawWidth <= 4 then
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
    local trackCounters = trackCountersOpt
    if trackCounters == nil then
        trackCounters = (DEBUG_PERF_MONITOR == true)
    end
    local canTime = canTimeOpt
    if canTime == nil then
        local perfSample = (DEBUG_PERF_MONITOR == true) and (PERF_MONITOR_ACTIVE_SAMPLE == true)
        canTime = perfSample and vmupro and vmupro.system and vmupro.system.getTimeUs
    end
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
        local fogAlpha = fogAlphaCached
        if fogAlpha == nil then
            fogAlpha = getFogQuantizedFactor(distToWall)
        end
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
normalizeDrawDistanceSetting()
normalizeMipmapRanges()
EXP_VIEW_DIST = EXP_VIEW_DIST or EXP_TEX_MAX_DIST
HYBRID_TEX_MAX_H = VIEWPORT_H
USE_FIXED_RAYCAST = false
DEBUG_FORCE_FLOAT_RAYCAST = false
EXP_DIST_LUT_SIZE = 256
expHeightLut = expHeightLut or {}
expScaleYLut = expScaleYLut or {}
expHeightLutReady = expHeightLutReady or false

function ensureExpTables()
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

function ensureExpHeightLut()
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

function getExpRayOffsets(rayCols)
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

function getStartSolidRayFallback(pxVal, pyVal, mapX, mapY, startTile)
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

function expCastRayFixed(rayDir, maxDist)
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
function renderWallsExperimentalHybrid()
    -- Stability-first EXP-H: use one raycast projection model at all distances.
    -- This prevents wall seams/shape shifts when draw distance changes.
    local hybridViewDist = EXP_VIEW_DIST or (EXP_TEX_MAX_DIST or 8.0)
    local texView = EXP_TEX_MAX_DIST or hybridViewDist
    local fogView = FOG_END or texView
    if fogView < 0.5 then fogView = 0.5 end
    local rayTraceDist = texView
    if rayTraceDist < 0.5 then rayTraceDist = 0.5 end

    local fovRad = renderCfg.fovSteps * (renderCfg.twoPi / 64)
    local twoPi = (renderCfg and renderCfg.twoPi) or 6.28318
    local playerDir = pdir % 64
    local playerAngle = playerDir * (twoPi / 64)
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
    local baseAngle = playerAngle - (fovRad / 2)
    if useFixedRaycast then
        ensureExpTables()
        playerDirFix = (playerDir % 64) * (EXP_FIXED_DIR_SUBDIV or 32)
        rayOffsets = getExpRayOffsets(rayCols)
    else
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
    local wallContactActive = (PLAYER_WALL_CONTACT_FRAMES or 0) > 0
    if wallContactActive then
        PLAYER_WALL_CONTACT_FRAMES = (PLAYER_WALL_CONTACT_FRAMES or 0) - 1
    end
    local stableProjection = (WALL_PROJECTION_MODE == "stable") or wallContactActive
    local nearStabilityDist = WALL_NEAR_STABILITY_DIST or 1.85

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
    -- A threshold <= 0 means that mip tier is disabled.
    local mip1Thresh = WALL_MIPMAP_DIST1 or 0.0
    local mip2Thresh = WALL_MIPMAP_DIST2 or 0.0
    local mip3Thresh = WALL_MIPMAP_DIST3 or 0.0
    local mip4Thresh = WALL_MIPMAP_DIST4 or 0.0
    if mip1Thresh < 0 then mip1Thresh = 0 end
    if mip2Thresh < 0 then mip2Thresh = 0 end
    if mip3Thresh < 0 then mip3Thresh = 0 end
    if mip4Thresh < 0 then mip4Thresh = 0 end
    local nearClipDist = getPlayerRenderNearClipDist()
    local fogCutDist = FOG_TEX_CUTOFF or FOG_END or texView
    local farTexOff = FAR_TEX_OFF_DIST or 999
    local farTexByDistEnabled = (farTexOff < 900)
    local texMaxH = HYBRID_TEX_MAX_H or (VIEWPORT_H - 8)
    local fogCurtainStart = -1
    local fogCurtainEnd = -1
    local fogCurtainDist = nil

    local x = 0
    while x < rayCols do
        local rayStride = 1
        local mipLevel = 0
        local castCos, castSin
        local dist, wtype, side, texCoord, rayHit
        local castT0
        local rayCastMaxDist = rayTraceDist
        if canTime then
            castT0 = vmupro.system.getTimeUs()
        end
        if useFixedRaycast then
            local rayOff = (rayOffsets and rayOffsets[x + 1]) or 0
            local rayDir = (playerDirFix + rayOff) % (EXP_FIXED_DIR_STEPS or 2048)
            castCos = rayDirCos[rayDir] or playerCos
            castSin = rayDirSin[rayDir] or playerSin
            dist, wtype, side, texCoord, rayHit = expCastRayFixed(rayDir, rayCastMaxDist)
        else
            castCos = rayCos
            castSin = raySin
            dist, wtype, side, texCoord, rayHit = castRay(castCos, castSin, rayCastMaxDist)
        end
        if canTime and castT0 then
            local castT1 = vmupro.system.getTimeUs()
            PERF_MONITOR_SAMPLE_RAYCAST_US = (PERF_MONITOR_SAMPLE_RAYCAST_US or 0) + (castT1 - castT0)
        end
        local fixedDist = dist * (castCos * playerCos + castSin * playerSin)
        if fixedDist < nearClipDist then fixedDist = nearClipDist end
        if not rayHit then
            -- Respect active draw-distance cap for no-hit rays; prevents endless far fog columns.
            fixedDist = rayCastMaxDist
            if fixedDist < nearClipDist then fixedDist = nearClipDist end
            if fixedDist > hybridViewDist then fixedDist = hybridViewDist end
        end

        local nearForce = rayHit and (
            fixedDist < (MIP_NEAR_FORCE_DIST or 1.35)
            or (wallContactActive and fixedDist < nearStabilityDist)
        )
        if WALL_MIPMAP_ENABLED and MIP_LOD_ENABLED and not nearForce then
            if mip4Thresh > 0 and fixedDist >= mip4Thresh then
                mipLevel = 4
            elseif mip3Thresh > 0 and fixedDist >= mip3Thresh then
                mipLevel = 3
            elseif mip2Thresh > 0 and fixedDist >= mip2Thresh then
                mipLevel = 2
            elseif mip1Thresh > 0 and fixedDist >= mip1Thresh then
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
                if fogCurtainStart >= 0 then
                    drawBufferedFogCurtainSpan(fogCurtainStart, fogCurtainEnd, fogCurtainDist or texView, trackCounters, canTime)
                    fogCurtainStart = -1
                    fogCurtainEnd = -1
                    fogCurtainDist = nil
                end
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
                local farWall = (fixedDist > texView) or (fixedDist >= fogCutDist) or (fogAlpha >= 1.0)
                local forceNoTexByDist = farTexByDistEnabled and (fixedDist >= farTexOff)

                local wantTex = (WALL_TEXTURE_MODE == "proper"
                    and not DEBUG_DISABLE_WALL_TEXTURE
                    and (nearForce or (not farWall and h < texMaxH))
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
                    local drewTex = drawWallTextureColumn(wtype, side, useTex, sx, y1, y2, drawColW, fixedDist, mipLevel, fogAlpha, trackCounters, canTime)
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
                -- Batch contiguous no-hit columns into one fog-curtain draw call.
                if fogCurtainStart < 0 then
                    fogCurtainStart = sx
                    fogCurtainEnd = ex
                    fogCurtainDist = fixedDist
                elseif sx <= (fogCurtainEnd + 1) then
                    if ex > fogCurtainEnd then
                        fogCurtainEnd = ex
                    end
                    if (not fogCurtainDist) or (fixedDist < fogCurtainDist) then
                        fogCurtainDist = fixedDist
                    end
                else
                    drawBufferedFogCurtainSpan(fogCurtainStart, fogCurtainEnd, fogCurtainDist or texView, trackCounters, canTime)
                    fogCurtainStart = sx
                    fogCurtainEnd = ex
                    fogCurtainDist = fixedDist
                end
            elseif fogCurtainStart >= 0 then
                drawBufferedFogCurtainSpan(fogCurtainStart, fogCurtainEnd, fogCurtainDist or texView, trackCounters, canTime)
                fogCurtainStart = -1
                fogCurtainEnd = -1
                fogCurtainDist = nil
            end
        elseif fogCurtainStart >= 0 then
            drawBufferedFogCurtainSpan(fogCurtainStart, fogCurtainEnd, fogCurtainDist or texView, trackCounters, canTime)
            fogCurtainStart = -1
            fogCurtainEnd = -1
            fogCurtainDist = nil
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
    if fogCurtainStart >= 0 then
        drawBufferedFogCurtainSpan(fogCurtainStart, fogCurtainEnd, fogCurtainDist or texView, trackCounters, canTime)
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

function isVisible(tx, ty, cache)
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

function drawSprite(screenX, dist, stype, viewAngle, animFrame, spriteData)
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
        local opened = spriteData and spriteData.opened
        local cw = math.floor(size * 0.5)
        local ch = math.floor(size * 0.35)
        local cx1, cx2 = screenX - cw, screenX + cw
        local cy2 = y2  -- Bottom at ground
        local cy1 = cy2 - ch  -- Top of body
        local lidTop = cy1 - math.floor(ch * 0.4)
        if opened then
            -- Open chest: lower contrast and no lock.
            vmupro.graphics.drawFillRect(cx1, cy1, cx2, cy2, COLOR_DARK_BROWN)
            vmupro.graphics.drawFillRect(cx1 - 2, lidTop - 2, cx2 + 2, cy1 - 6, COLOR_BROWN)
            vmupro.graphics.drawFillRect(cx1, lidTop, cx2, cy1 - 8, COLOR_DARK_BROWN)
            vmupro.graphics.drawFillRect(cx1, cy1, cx1 + 4, cy2, COLOR_GRAY)
            vmupro.graphics.drawFillRect(cx2 - 4, cy1, cx2, cy2, COLOR_GRAY)
        else
            -- Main body
            vmupro.graphics.drawFillRect(cx1, cy1, cx2, cy2, COLOR_BROWN)
            -- Lid (closed)
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
            vmupro.graphics.drawFillRect(screenX - 1, cy1, screenX + 1, cy1 + 2, COLOR_BLACK)
        end

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
    elseif stype == 8 then
        -- World item drop marker (used for chest loot conversion).
        if spriteData and spriteData.collected then
            return
        end

        local iw = math.floor(size * 0.18)
        if iw < 2 then iw = 2 end
        local ih = math.floor(size * 0.20)
        if ih < 3 then ih = 3 end
        local ix1 = screenX - iw
        local ix2 = screenX + iw
        local iy2 = y2 - 1
        local iy1 = iy2 - ih
        local item = getGameItem and getGameItem(spriteData and spriteData.item_id or nil) or nil
        local itemKind = tostring(item and item.kind or "")
        local color = COLOR_YELLOW
        if itemKind == "weapon" then
            color = COLOR_LIGHT_BLUE
        elseif itemKind == "equipment" then
            color = COLOR_ORANGE
        elseif itemKind == "consumable" then
            color = COLOR_GREEN
        end
        vmupro.graphics.drawFillRect(ix1, iy1, ix2, iy2, color)
        vmupro.graphics.drawFillRect(ix1 + 1, iy1 + 1, ix2 - 1, iy2 - 1, COLOR_WHITE)
        vmupro.graphics.drawFillRect(ix1 + 2, iy1 + 2, ix2 - 2, iy2 - 2, color)
    end
end

function drawRoofBackdrop()
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

function drawBowChargeOverlay()
    if not bowChargeState.active then
        return
    end
    local idleSprite = bowAttack and bowAttack[1] or nil
    local drawnSprite = bowAttack and bowAttack[2] or nil
    if not drawnSprite then
        drawnSprite = idleSprite
    end

    local showDrawn = isBowChargeDrawnVisual()
    local sprite = showDrawn and drawnSprite or idleSprite
    if sprite and sprite.height and sprite.height > 0 then
        local drawX = 128
        local drawY = 240 - sprite.height + 18
        vmupro.sprite.draw(sprite, drawX, drawY, vmupro.sprite.kImageUnflipped)
    else
        local bowX = 182
        local bowTop = 108
        local bowBottom = 220
        local pull = showDrawn and 12 or 2
        vmupro.graphics.drawLine(bowX, bowTop, bowX + 7, bowTop + 24, COLOR_BROWN)
        vmupro.graphics.drawLine(bowX + 7, bowTop + 24, bowX + 7, bowBottom - 24, COLOR_BROWN)
        vmupro.graphics.drawLine(bowX + 7, bowBottom - 24, bowX, bowBottom, COLOR_BROWN)
        vmupro.graphics.drawLine(bowX + pull, bowTop + 6, bowX + pull, bowBottom - 6, COLOR_LIGHT_GRAY)
        vmupro.graphics.drawFillRect(bowX - 30 - pull, 168, bowX + 3, 171, COLOR_LIGHT_GRAY)
        vmupro.graphics.drawFillRect(bowX - 34 - pull, 167, bowX - 30 - pull, 172, COLOR_YELLOW)
    end

    local stage = getBowChargeCurrentStage()
    local tiers = getBowChargeTierCount()
    local boxW = 6
    local gap = 3
    local barW = (tiers * boxW) + ((tiers - 1) * gap)
    local x0 = 236 - barW
    local y0 = 210
    for i = 1, tiers do
        local color = COLOR_DARK_GRAY
        if i <= stage then
            color = COLOR_YELLOW
        end
        local x = x0 + ((i - 1) * (boxW + gap))
        vmupro.graphics.drawFillRect(x, y0, x + boxW, y0 + 6, color)
    end
end

function renderGameFrame()
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
            local spriteOrder = spriteOrderCache
            local prevCount = #spriteOrder
            local count = 0
            for i = 1, #sprites do
                local s = sprites[i]
                if not s then
                    goto continue_sprite_build
                end
                local skip = (DEBUG_DISABLE_ENEMIES and isEnemyType(s.t))
                    or (DEBUG_DISABLE_PROPS and isPropType(s.t))
                if not skip then
                    if (s.t == 7 or s.t == 8) and s.collected then
                        goto continue_sprite_build
                    end
                    local sdx, sdy = s.x - px, s.y - py
                    local distSq = sdx * sdx + sdy * sdy
                    local maxSq = SPRITE_MAX_DIST_SQ
                    if isEnemyType(s.t) then
                        maxSq = ENEMY_RENDER_DIST_SQ
                    elseif s.t == 7 or s.t == 8 then
                        maxSq = ITEM_RENDER_DIST_SQ
                    elseif isPropType(s.t) then
                        maxSq = PROP_RENDER_DIST_SQ
                    end
                    if distSq <= maxSq then
                        count = count + 1
                        local entry = spriteOrder[count]
                        if entry then
                            entry.idx = i
                            entry.dist = distSq
                        else
                            spriteOrder[count] = {idx = i, dist = distSq}
                        end
                    end
                end
                ::continue_sprite_build::
            end
            if prevCount > count then
                for i = count + 1, prevCount do
                    spriteOrder[i] = nil
                end
            end
            if count > 1 then
                table.sort(spriteOrder, spriteOrderCompareFarToNear)
            end
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
            if (s.t == 7 or s.t == 8) and s.collected then
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
            elseif s.t == 7 or s.t == 8 then
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

        drawPlayerProjectiles()

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

        if bowChargeState.active and not showMenu then
            drawBowChargeOverlay()
        end

        -- Draw first-person attack overlay (melee/ranged/magic).
        if isAttacking > 0 and not showMenu then
        local weaponClass = normalizeWeaponClass(lastAttackWeaponClass)
        local attackFrames = swordAttack
        local drawXOffset = 140
        local drawYOffset = 30
        if weaponClass == WEAPON_CLASS_RANGED then
            attackFrames = bowAttack
            drawXOffset = 128
            drawYOffset = 18
        elseif weaponClass == WEAPON_CLASS_MAGIC then
            attackFrames = staffCast
            drawXOffset = 122
            drawYOffset = 14
        end

        if attackFrames and #attackFrames > 0 then
            local total = (attackTotalFrames > 0) and attackTotalFrames or (#attackFrames * 2)
            local frameHold = math.max(1, math.floor(total / #attackFrames))
            local frameIndex = math.floor((total - isAttacking) / frameHold) + 1
            if frameIndex < 1 then frameIndex = 1 end
            if frameIndex > #attackFrames then frameIndex = #attackFrames end
            local sprite = attackFrames[frameIndex]
            if sprite then
                local drawX = drawXOffset
                local drawY = 240 - sprite.height + drawYOffset
                vmupro.sprite.draw(sprite, drawX, drawY, vmupro.sprite.kImageUnflipped)
            end
        else
            local total = attackTotalFrames
            if total <= 0 then total = 10 end
            local progress = (total - isAttacking) / total
            if progress < 0 then progress = 0 end
            if progress > 1 then progress = 1 end

            if weaponClass == WEAPON_CLASS_RANGED then
                local bowX = 182
                local bowTop = 108
                local bowBottom = 220
                local pull = math.floor(progress * 14)
                vmupro.graphics.drawLine(bowX, bowTop, bowX + 7, bowTop + 24, COLOR_BROWN)
                vmupro.graphics.drawLine(bowX + 7, bowTop + 24, bowX + 7, bowBottom - 24, COLOR_BROWN)
                vmupro.graphics.drawLine(bowX + 7, bowBottom - 24, bowX, bowBottom, COLOR_BROWN)
                vmupro.graphics.drawLine(bowX + pull, bowTop + 6, bowX + pull, bowBottom - 6, COLOR_LIGHT_GRAY)
                vmupro.graphics.drawFillRect(bowX - 30 - pull, 168, bowX + 3, 171, COLOR_LIGHT_GRAY)
                vmupro.graphics.drawFillRect(bowX - 34 - pull, 167, bowX - 30 - pull, 172, COLOR_YELLOW)
            elseif weaponClass == WEAPON_CLASS_MAGIC then
                local staffX = 176
                local staffTop = 118
                vmupro.graphics.drawFillRect(staffX - 3, staffTop, staffX + 3, 228, COLOR_BROWN)
                vmupro.graphics.drawFillRect(staffX - 7, staffTop - 8, staffX + 7, staffTop + 2, COLOR_DARK_BROWN)
                local orbR = 5 + math.floor(progress * 5)
                local orbPulse = ((simTickCount or 0) % 4)
                vmupro.graphics.drawFillRect(staffX - orbR, staffTop - 9 - orbPulse, staffX + orbR, staffTop + 1 - orbPulse, COLOR_LIGHT_BLUE)
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

    local inventoryFullscreenActive = (showMenu and inInventoryMenu)

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
                for i = 1, #optItems do
                    local item = optItems[i]
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
        elseif inSaveMenu then
            drawUiPanel(32, 42, 208, 234, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
            drawUiPanel(40, 50, 200, 72, COLOR_MAROON, COLOR_WHITE)
            setFontCached(vmupro.text.FONT_SMALL)
            drawMenuText("SAVE GAME", 72, 55, COLOR_WHITE)
            for i = 1, SAVE_SLOT_COUNT do
                local y = 82 + (i - 1) * 48
                local textColor = COLOR_LIGHT_GRAY
                if i == saveMenuSelection then
                    drawUiPanel(40, y, 200, y + 40, COLOR_MAROON, COLOR_WHITE)
                    textColor = COLOR_WHITE
                end
                local line1, line2 = getSaveSlotSummary(i)
                setFontCached(vmupro.text.FONT_SMALL)
                drawMenuText(line1, 48, y + 5, textColor)
                setFontCached(vmupro.text.FONT_TINY_6x8)
                drawMenuText(line2, 48, y + 23, textColor)
            end
            setFontCached(vmupro.text.FONT_TINY_6x8)
            if saveMenuMessage and saveMenuMessage ~= "" and saveMenuMessageTimer > 0 then
                drawMenuText(saveMenuMessage, 48, 224, COLOR_WHITE)
            else
                drawMenuText("A/MODE SAVE  B BACK", 48, 224, COLOR_WHITE)
            end
        elseif inInventoryMenu then
            local rows, heading, carryCur, carryMax = buildInventoryUiRows(inventoryMenuTab)
            local totalRows = #rows
            local page, startIdx, endIdx, selected = getInventoryUiPageBounds(totalRows, inventoryMenuSelection)
            inventoryMenuSelection = selected
            inventoryMenuPage = page

            -- Full-screen inventory layout; keep all game HUD overlays hidden underneath.
            vmupro.graphics.drawFillRect(0, 0, 239, 239, COLOR_DARK_GRAY)
            drawRectOutline(0, 0, 239, 239, COLOR_LIGHT_GRAY)
            vmupro.graphics.drawFillRect(8, 16, 232, 232, COLOR_DARK_GRAY)
            drawUiPanel(8, 16, 232, 232, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
            vmupro.graphics.drawFillRect(10, 20, 230, 34, COLOR_DARK_GRAY)

            setFontCached(vmupro.text.FONT_TINY_6x8)
            for i = 1, #INVENTORY_MENU_TABS do
                local tx1 = 12 + ((i - 1) * 54)
                local tx2 = tx1 + 50
                local tabSelected = (i == inventoryMenuTab)
                local tabFg = COLOR_LIGHT_GRAY
                local tabLabel = INVENTORY_MENU_TABS[i]
                if tabSelected then
                    vmupro.graphics.drawFillRect(tx1, 20, tx2, 34, COLOR_MAROON)
                    tabFg = COLOR_WHITE
                end
                local tabWidth = (tx2 - tx1) + 1
                local tabTextWidth = string.len(tabLabel) * 6
                local tabTextX = tx1 + math.floor((tabWidth - tabTextWidth) * 0.5)
                if tabTextX < (tx1 + 2) then
                    tabTextX = tx1 + 2
                end
                drawMenuText(tabLabel, tabTextX, 23, tabFg)
            end

            local wtText = "WT " .. string.format("%.1f/%.0f", carryCur or 0, carryMax or 0)
            local wtTextX = 228 - (string.len(wtText) * 6)
            if wtTextX < 108 then wtTextX = 108 end
            drawMenuText(heading, 12, 36, COLOR_WHITE)
            drawMenuText(wtText, wtTextX, 36, COLOR_WHITE)

            -- List pane + detail pane.
            vmupro.graphics.drawFillRect(12, 42, 146, 206, COLOR_DARK_GRAY)
            vmupro.graphics.drawFillRect(150, 42, 228, 206, COLOR_DARK_GRAY)
            drawUiPanel(12, 42, 146, 206, COLOR_DARK_GRAY, COLOR_GRAY)
            drawUiPanel(150, 42, 228, 206, COLOR_DARK_GRAY, COLOR_GRAY)

            drawMenuText("ITEMS", 16, 44, COLOR_WHITE)
            drawMenuText("DETAIL", 154, 44, COLOR_WHITE)

            if totalRows <= 0 then
                drawMenuText("NO ITEMS", 16, 58, COLOR_GRAY)
                if inventoryMenuTab == 4 then
                    drawMenuText("TRADER UI", 154, 58, COLOR_LIGHT_GRAY)
                    drawMenuText("PHASE B", 154, 70, COLOR_LIGHT_GRAY)
                    drawMenuText("BUY/SELL", 154, 82, COLOR_LIGHT_GRAY)
                    drawMenuText("NOT ACTIVE", 154, 94, COLOR_LIGHT_GRAY)
                end
            else
                local drawRow = 0
                for idx = startIdx, endIdx do
                    drawRow = drawRow + 1
                    local row = rows[idx]
                    local y = 58 + ((drawRow - 1) * 12)
                    local selectedRow = (idx == inventoryMenuSelection)
                    local fg = COLOR_LIGHT_GRAY
                    if selectedRow then
                        vmupro.graphics.drawFillRect(14, y - 1, 144, y + 9, COLOR_MAROON)
                        fg = COLOR_WHITE
                    end

                    local label = tostring((row and row.label) or "ITEM")
                    local count = math.floor(tonumber(row and row.count) or 0)
                    if count > 1 then
                        label = label .. " x" .. tostring(count)
                    end
                    label = truncateUiLabel(label, 20)
                    drawMenuText(label, 16, y, fg)
                end

                local row = rows[inventoryMenuSelection]
                if row then
                    local item = row.item
                    drawMenuText(truncateUiLabel(tostring(row.label or "ITEM"), 12), 154, 58, COLOR_WHITE)
                    drawMenuText(truncateUiLabel(tostring(row.detail or ""), 12), 154, 70, COLOR_LIGHT_GRAY)

                    if item then
                        local itemWeight = tonumber(item.weight) or 0
                        if itemWeight < 0 then itemWeight = 0 end
                        local itemValue = math.floor(tonumber(item.value) or 0)
                        local affinity = string.upper(tostring(item.class_affinity or "any"))
                        drawMenuText("WT " .. string.format("%.1f", itemWeight), 154, 84, COLOR_LIGHT_GRAY)
                        drawMenuText("VAL " .. tostring(itemValue), 154, 96, COLOR_LIGHT_GRAY)
                        drawMenuText("AFF " .. truncateUiLabel(affinity, 8), 154, 108, COLOR_LIGHT_GRAY)
                        if item.weapon_class then
                            local wc = normalizeWeaponClass(item.weapon_class)
                            local wcLabel = WEAPON_CLASS_LABELS[wc] or tostring(wc)
                            drawMenuText("CLS " .. wcLabel, 154, 120, COLOR_LIGHT_GRAY)
                        end
                    else
                        drawMenuText("READ-ONLY", 154, 84, COLOR_LIGHT_GRAY)
                        drawMenuText("PHASE A", 154, 96, COLOR_LIGHT_GRAY)
                    end
                end
            end

            drawMenuText(
                "ROW " .. tostring(inventoryMenuSelection) .. "/" .. tostring(math.max(totalRows, 1)),
                154,
                194,
                COLOR_WHITE
            )
            drawMenuText("PAGE " .. tostring(inventoryMenuPage), 154, 206, COLOR_LIGHT_GRAY)

            vmupro.graphics.drawFillRect(10, 212, 230, 232, COLOR_DARK_GRAY)
            if inventoryMenuMessage and inventoryMenuMessage ~= "" and inventoryMenuMessageTimer > 0 then
                drawMenuText(truncateUiLabel(inventoryMenuMessage, 34), 14, 218, COLOR_WHITE)
            else
                drawMenuText("L/R TAB  U/D ROW  B BACK", 14, 218, COLOR_WHITE)
            end
        elseif inStatsMenu then
            local state = ensurePlayerBuildState()
            local level = getPlayerLevel()
            local xp = getPlayerXp()
            local xpNeed = getPlayerXpForNextLevel()
            local freePoints = math.floor(toNumber(state.stat_points, 0))
            local xpLine = "XP MAX"
            if xpNeed > 0 then
                xpLine = "XP " .. tostring(xp) .. "/" .. tostring(xpNeed)
            end

            drawUiPanel(24, 28, 216, 234, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
            drawUiPanel(32, 36, 208, 58, COLOR_MAROON, COLOR_WHITE)
            setFontCached(vmupro.text.FONT_SMALL)
	            drawMenuText("PLAYER STATS", 56, 41, COLOR_WHITE)
	
	            setFontCached(vmupro.text.FONT_TINY_6x8)
	            drawMenuText("LV " .. tostring(level) .. "   " .. xpLine, 36, 62, COLOR_WHITE)
	            drawMenuText("UNSPENT: " .. tostring(freePoints), 36, 78, COLOR_WHITE)
	
	            local rows = {
	                {"VITALITY", getBuildStatValue("vitality"), "HP+" .. tostring(VITALITY_HP_BONUS)},
	                {"STRENGTH", getBuildStatValue("strength"), "DMG+" .. tostring(STRENGTH_DAMAGE_BONUS)},
	                {"DEXTERITY", getBuildStatValue("dexterity"), "SPD/DODGE"},
	                {"INTELLECT", getBuildStatValue("intellect"), "POW/CRIT"},
	                {"BACK", -1, ""},
	            }
	
	            for i = 1, #rows do
	                local y = 96 + (i - 1) * 24
	                local selected = (i == statsMenuSelection)
	                local fg = COLOR_LIGHT_GRAY
	                if selected then
	                    drawUiPanel(32, y - 2, 208, y + 16, COLOR_MAROON, COLOR_WHITE)
	                    fg = COLOR_WHITE
	                end
	                local label = rows[i][1]
	                setFontCached(vmupro.text.FONT_SMALL)
	                drawMenuText(label, 40, y, fg)
	                if i <= 4 then
	                    local value = rows[i][2]
	                    drawMenuText(tostring(value), 156, y, fg)
	                end
	            end
	
	            setFontCached(vmupro.text.FONT_TINY_6x8)
	            if statsMenuSelection >= 1 and statsMenuSelection <= 4 then
	                local effectLine = rows[statsMenuSelection][3] or ""
	                if effectLine ~= "" then
	                    drawMenuText("EFFECT: " .. effectLine, 36, 210, COLOR_WHITE)
	                end
	            end
	            if statsMenuMessage and statsMenuMessage ~= "" and statsMenuMessageTimer > 0 then
	                drawMenuText(statsMenuMessage, 36, 224, COLOR_WHITE)
	            else
	                drawMenuText("A/MODE SPEND  B BACK", 36, 224, COLOR_WHITE)
            end
        elseif inMasteryMenu then
            local state = ensurePlayerBuildState()
            local classId = getCurrentClassId()
            local freePoints = math.floor(toNumber(state.weapon_mastery_points, 0))

            drawUiPanel(24, 28, 216, 234, COLOR_DARK_GRAY, COLOR_LIGHT_GRAY)
            drawUiPanel(32, 36, 208, 58, COLOR_MAROON, COLOR_WHITE)
            setFontCached(vmupro.text.FONT_SMALL)
	            drawMenuText("MASTERIES", 74, 41, COLOR_WHITE)
	
	            setFontCached(vmupro.text.FONT_TINY_6x8)
	            drawMenuText("PTS: " .. tostring(freePoints), 36, 62, COLOR_WHITE)
	            drawMenuText("BONUS: " .. tostring(WEAPON_BASELINE_POINTS or 5) .. "  CAP: " .. tostring(WEAPON_MASTERY_CAP or 10), 36, 78, COLOR_WHITE)
	
	            local rows = {
	                {WEAPON_CLASS_MELEE, "MELEE"},
	                {WEAPON_CLASS_RANGED, "RANGED"},
	                {WEAPON_CLASS_MAGIC, "MAGIC"},
	                {nil, "BACK"},
	            }
	
	            for i = 1, #rows do
	                local y = 96 + (i - 1) * 24
	                local selected = (i == masteryMenuSelection)
	                local fg = COLOR_LIGHT_GRAY
	                if selected then
	                    drawUiPanel(32, y - 2, 208, y + 16, COLOR_MAROON, COLOR_WHITE)
	                    fg = COLOR_WHITE
	                end
	
	                local weaponClass = rows[i][1]
	                local label = rows[i][2]
	                local rowText = label
	                if weaponClass ~= nil then
	                    local basePts = getWeaponBasePointsForClass(classId, weaponClass)
	                    local masteryLvl = getWeaponMasteryLevel(weaponClass)
	                    local dmgMult, spdMult, effectivePts = computeWeaponProficiencyMultipliers(classId, weaponClass)
	                    local dmgPct = math.floor((dmgMult * 100.0) + 0.5)
	                    local spdPct = math.floor((spdMult * 100.0) + 0.5)
	                    rowText = string.format("%s LV%d/%d E%d D%d S%d B%d",
	                        label,
	                        masteryLvl,
	                        (WEAPON_MASTERY_CAP or 10),
	                        effectivePts,
	                        dmgPct,
	                        spdPct,
	                        basePts
	                    )
	                end
	                setFontCached(vmupro.text.FONT_TINY_6x8)
	                drawMenuText(rowText, 40, y, fg)
	            end

            setFontCached(vmupro.text.FONT_TINY_6x8)
            if masteryMenuMessage and masteryMenuMessage ~= "" and masteryMenuMessageTimer > 0 then
                drawMenuText(masteryMenuMessage, 36, 224, COLOR_WHITE)
            else
                drawMenuText("A/MODE SPEND  B BACK", 36, 224, COLOR_WHITE)
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
            for i = 1, #PAUSE_MENU_ITEMS do
                local item = PAUSE_MENU_ITEMS[i]
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

    if not inventoryFullscreenActive then
        -- Draw health UI (potion with liquid)
        drawHealthUI()
        if not showMenu then
            drawEnemiesRemainingUI()
            drawRunScoreUI()
        end

        -- Draw current level indicator
        setFontCached(vmupro.text.FONT_SMALL)
        drawUiText(getLevelLabel(currentLevel), 6, 228, COLOR_WHITE, COLOR_BLACK)
        drawUiText("LV " .. tostring(getPlayerLevel()), 186, 228, COLOR_WHITE, COLOR_BLACK)
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
        if gameState == STATE_PLAYING then
            setFontCached(vmupro.text.FONT_TINY_6x8)
            local invState = ensureInventoryState()
            local invWeight = tonumber(invState and invState.current_weight) or 0
            local invMax = tonumber(invState and invState.max_weight) or 0
            drawUiText(string.format("WT %.1f/%.0f", invWeight, invMax), 164, 14, COLOR_WHITE, COLOR_BLACK)
            if (simTickCount or 0) < (damageDebugTakenUntilTick or 0) then
                drawUiText("DMG TAKEN: " .. tostring(damageDebugTakenValue or 0), 6, 4, COLOR_WHITE, COLOR_BLACK)
            end
            if (simTickCount or 0) < (damageDebugDealtUntilTick or 0) then
                drawUiText("DMG DEALT: " .. tostring(damageDebugDealtValue or 0), 6, 14, COLOR_WHITE, COLOR_BLACK)
            end
            if statsMenuMessage and statsMenuMessage ~= "" and statsMenuMessageTimer and statsMenuMessageTimer > 0 then
                drawUiText(statsMenuMessage, 58, 24, COLOR_WHITE, COLOR_BLACK)
            end
            if masteryMenuMessage and masteryMenuMessage ~= "" and masteryMenuMessageTimer and masteryMenuMessageTimer > 0 then
                drawUiText(masteryMenuMessage, 58, 34, COLOR_WHITE, COLOR_BLACK)
            end
            if lootFeedMessage and lootFeedMessage ~= "" and lootFeedMessageTimer and lootFeedMessageTimer > 0 then
                drawUiText(lootFeedMessage, 58, 44, COLOR_WHITE, COLOR_BLACK)
            end
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

function consumeAudioSteps(elapsedUs, audioAccumulatorUs)
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

function runSimulationStep()
    simTickCount = simTickCount + 1
    if saveMenuMessageTimer and saveMenuMessageTimer > 0 then
        saveMenuMessageTimer = saveMenuMessageTimer - 1
    end
    if inventoryMenuMessageTimer and inventoryMenuMessageTimer > 0 then
        inventoryMenuMessageTimer = inventoryMenuMessageTimer - 1
    end
    if statsMenuMessageTimer and statsMenuMessageTimer > 0 then
        statsMenuMessageTimer = statsMenuMessageTimer - 1
    end
    if masteryMenuMessageTimer and masteryMenuMessageTimer > 0 then
        masteryMenuMessageTimer = masteryMenuMessageTimer - 1
    end
    if lootFeedMessageTimer and lootFeedMessageTimer > 0 then
        lootFeedMessageTimer = lootFeedMessageTimer - 1
    end

    if gameState == STATE_PLAYING and not showMenu then
        if levelBannerTimer > 0 then
            levelBannerTimer = levelBannerTimer - 1
        end
        if isAttacking > 0 then
            isAttacking = isAttacking - 1
        end
        updatePlayerProjectiles()
        updateSoldiers()
        updateDeathAnimations()
        if not DEBUG_DISABLE_EFFECTS then
            updateBloodEffects()
        end
        checkHealthPickups()
        checkWorldItemPickups()
        if playerHealth and MAX_HEALTH and playerHealth > 0 and playerHealth < MAX_HEALTH then
            local regenPerSec = PLAYER_REGEN_PER_SEC or 0.0
            if regenPerSec > 0 then
                playerRegenAccumulator = (playerRegenAccumulator or 0.0) + (regenPerSec / SIM_TARGET_HZ)
                while playerRegenAccumulator >= 1.0 and playerHealth < MAX_HEALTH do
                    playerHealth = playerHealth + 1
                    playerRegenAccumulator = playerRegenAccumulator - 1.0
                end
                if playerHealth >= MAX_HEALTH then
                    playerHealth = MAX_HEALTH
                    playerRegenAccumulator = 0.0
                end
            end
        end
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

function consumeSimulationSteps(elapsedUs, simAccumulatorUs)
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
                local prevTitleInClassSelect = titleInClassSelect
                local prevTitleClassSelection = titleClassSelection
                local prevTitleInLoadMenu = titleInLoadMenu
                local prevTitleLoadSelection = titleLoadSelection
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
                if titleInClassSelect then
                    local classCount = #getClassOrder()
                    if classCount < 1 then classCount = 1 end
                    if classCount > 3 then classCount = 3 end
                    if titleClassSelection < 1 then titleClassSelection = 1 end
                    if titleClassSelection > classCount then titleClassSelection = classCount end
                    if vmupro.input.pressed(vmupro.input.LEFT) or vmupro.input.pressed(vmupro.input.UP) then
                        titleClassSelection = titleClassSelection - 1
                        if titleClassSelection < 1 then titleClassSelection = classCount end
                    end
                    if vmupro.input.pressed(vmupro.input.RIGHT) or vmupro.input.pressed(vmupro.input.DOWN) then
                        titleClassSelection = titleClassSelection + 1
                        if titleClassSelection > classCount then titleClassSelection = 1 end
                    end
                    if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                        local classId = getClassIdForSelection(titleClassSelection)
                        setCurrentClassId(classId)
                        titleInClassSelect = false
                        local selectedEntry = LEVEL_SELECT_LIST[selectedLevel]
                        if selectedEntry then
                            beginLoadLevel(selectedEntry.id)
                        end
                    end
                    if vmupro.input.pressed(vmupro.input.B) or vmupro.input.pressed(vmupro.input.POWER) then
                        titleInClassSelect = false
                    end
                elseif titleInLoadMenu then
                    if vmupro.input.pressed(vmupro.input.UP) or vmupro.input.pressed(vmupro.input.LEFT) then
                        titleLoadSelection = titleLoadSelection - 1
                        if titleLoadSelection < 1 then titleLoadSelection = SAVE_SLOT_COUNT end
                    end
                    if vmupro.input.pressed(vmupro.input.DOWN) or vmupro.input.pressed(vmupro.input.RIGHT) then
                        titleLoadSelection = titleLoadSelection + 1
                        if titleLoadSelection > SAVE_SLOT_COUNT then titleLoadSelection = 1 end
                    end
                    if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                        loadGameFromSlot(titleLoadSelection)
                    end
                    if vmupro.input.pressed(vmupro.input.B) or vmupro.input.pressed(vmupro.input.POWER) then
                        titleInLoadMenu = false
                    end
                elseif titleInOptions then
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
                        if titleSelection < 1 then titleSelection = 4 end
                    end
                    if vmupro.input.pressed(vmupro.input.DOWN) then
                        titleSelection = titleSelection + 1
                        if titleSelection > 4 then titleSelection = 1 end
                    end
                    if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                        if titleSelection == 1 then
                            titleInClassSelect = true
                            titleClassSelection = getClassSelectionIndexForId(getCurrentClassId())
                        elseif titleSelection == 2 then
                            loadSaveSlotsFromDisk()
                            titleInLoadMenu = true
                            titleLoadSelection = 1
                        elseif titleSelection == 3 then
                            titleInOptions = true
                            titleOptionsSelection = 1
                        elseif titleSelection == 4 then
                            quitApp("title exit")
                        end
                    end
                end
                if prevTitleSelection ~= titleSelection
                    or prevTitleInClassSelect ~= titleInClassSelect
                    or prevTitleClassSelection ~= titleClassSelection
                    or prevTitleInLoadMenu ~= titleInLoadMenu
                    or prevTitleLoadSelection ~= titleLoadSelection
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
                handleGameOverInput()
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
                                clearSpriteOrderCache()
                            elseif optionsSelection == 4 then
                                DEBUG_DISABLE_PROPS = not DEBUG_DISABLE_PROPS
                                clearSpriteOrderCache()
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
                elseif inSaveMenu then
                    if vmupro.input.pressed(vmupro.input.UP) then
                        saveMenuSelection = saveMenuSelection - 1
                        if saveMenuSelection < 1 then saveMenuSelection = SAVE_SLOT_COUNT end
                    end
                    if vmupro.input.pressed(vmupro.input.DOWN) then
                        saveMenuSelection = saveMenuSelection + 1
                        if saveMenuSelection > SAVE_SLOT_COUNT then saveMenuSelection = 1 end
                    end
                    if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                        local okSave = false
                        okSave, _ = saveGameToSlot(saveMenuSelection)
                        if okSave then
                            saveMenuMessage = "SAVED TO SLOT " .. tostring(saveMenuSelection)
                        else
                            saveMenuMessage = "SAVE FAILED"
                        end
                        saveMenuMessageTimer = 90
                    end
                    if vmupro.input.pressed(vmupro.input.POWER) or vmupro.input.pressed(vmupro.input.B) then
                        inSaveMenu = false
                        saveMenuMessage = ""
                        saveMenuMessageTimer = 0
                    end
                elseif inInventoryMenu then
                    local rows = buildInventoryUiRows(inventoryMenuTab)
                    local totalRows = #rows
                    local maxSel = totalRows
                    if maxSel < 1 then maxSel = 1 end

                    if vmupro.input.pressed(vmupro.input.LEFT) then
                        inventoryMenuTab = inventoryMenuTab - 1
                        if inventoryMenuTab < 1 then inventoryMenuTab = #INVENTORY_MENU_TABS end
                        inventoryMenuSelection = 1
                        inventoryMenuPage = 1
                    end
                    if vmupro.input.pressed(vmupro.input.RIGHT) then
                        inventoryMenuTab = inventoryMenuTab + 1
                        if inventoryMenuTab > #INVENTORY_MENU_TABS then inventoryMenuTab = 1 end
                        inventoryMenuSelection = 1
                        inventoryMenuPage = 1
                    end

                    if vmupro.input.pressed(vmupro.input.UP) then
                        inventoryMenuSelection = inventoryMenuSelection - 1
                        if inventoryMenuSelection < 1 then inventoryMenuSelection = maxSel end
                    end
                    if vmupro.input.pressed(vmupro.input.DOWN) then
                        inventoryMenuSelection = inventoryMenuSelection + 1
                        if inventoryMenuSelection > maxSel then inventoryMenuSelection = 1 end
                    end

                    if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                        if inventoryMenuTab == 4 then
                            inventoryMenuMessage = "TRADER BUY/SELL IN NEXT PHASE"
                        else
                            inventoryMenuMessage = "READ-ONLY PHASE A"
                        end
                        inventoryMenuMessageTimer = math.floor((SIM_TARGET_HZ or 24) * 2)
                    end

                    local page, _, _, sel = getInventoryUiPageBounds(totalRows, inventoryMenuSelection)
                    inventoryMenuSelection = sel
                    inventoryMenuPage = page

                    if vmupro.input.pressed(vmupro.input.POWER) or vmupro.input.pressed(vmupro.input.B) then
                        inInventoryMenu = false
                        inventoryMenuSelection = 1
                        inventoryMenuPage = 1
                        inventoryMenuMessage = ""
                        inventoryMenuMessageTimer = 0
                    end
                elseif inStatsMenu then
                    if vmupro.input.pressed(vmupro.input.UP) then
                        statsMenuSelection = statsMenuSelection - 1
                        if statsMenuSelection < 1 then statsMenuSelection = 5 end
                    end
                    if vmupro.input.pressed(vmupro.input.DOWN) then
                        statsMenuSelection = statsMenuSelection + 1
                        if statsMenuSelection > 5 then statsMenuSelection = 1 end
                    end
                    if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                        if statsMenuSelection >= 1 and statsMenuSelection <= 4 then
                            local statKey = nil
                            if statsMenuSelection == 1 then statKey = "vitality" end
                            if statsMenuSelection == 2 then statKey = "strength" end
                            if statsMenuSelection == 3 then statKey = "dexterity" end
                            if statsMenuSelection == 4 then statKey = "intellect" end
                            local okAllocate, errAllocate = allocatePlayerStat(statKey)
                            if okAllocate then
                                statsMenuMessage = "ALLOCATED " .. string.upper(statKey)
                            else
                                statsMenuMessage = errAllocate or "ALLOC FAILED"
                            end
                            statsMenuMessageTimer = math.floor((SIM_TARGET_HZ or 24) * 2)
                        else
                            inStatsMenu = false
                        end
                    end
                    if vmupro.input.pressed(vmupro.input.POWER) or vmupro.input.pressed(vmupro.input.B) then
                        inStatsMenu = false
                        statsMenuMessage = ""
                        statsMenuMessageTimer = 0
                    end
                elseif inMasteryMenu then
                    if vmupro.input.pressed(vmupro.input.UP) then
                        masteryMenuSelection = masteryMenuSelection - 1
                        if masteryMenuSelection < 1 then masteryMenuSelection = 4 end
                    end
                    if vmupro.input.pressed(vmupro.input.DOWN) then
                        masteryMenuSelection = masteryMenuSelection + 1
                        if masteryMenuSelection > 4 then masteryMenuSelection = 1 end
                    end
                    if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                        if masteryMenuSelection >= 1 and masteryMenuSelection <= 3 then
                            local weaponClass = WEAPON_CLASS_MELEE
                            if masteryMenuSelection == 2 then weaponClass = WEAPON_CLASS_RANGED end
                            if masteryMenuSelection == 3 then weaponClass = WEAPON_CLASS_MAGIC end
                            local okAllocate, errAllocate = allocateWeaponMastery(weaponClass)
                            if okAllocate then
                                masteryMenuMessage = "ALLOCATED " .. (WEAPON_CLASS_LABELS[weaponClass] or "MASTERY")
                            else
                                masteryMenuMessage = errAllocate or "ALLOC FAILED"
                            end
                            masteryMenuMessageTimer = math.floor((SIM_TARGET_HZ or 24) * 2)
                        else
                            inMasteryMenu = false
                        end
                    end
                    if vmupro.input.pressed(vmupro.input.POWER) or vmupro.input.pressed(vmupro.input.B) then
                        inMasteryMenu = false
                        masteryMenuMessage = ""
                        masteryMenuMessageTimer = 0
                    end
                else
                    -- Main pause menu
                    if vmupro.input.pressed(vmupro.input.UP) then
                        menuSelection = menuSelection - 1
                        if menuSelection < 1 then menuSelection = 9 end
                    end
                    if vmupro.input.pressed(vmupro.input.DOWN) then
                        menuSelection = menuSelection + 1
                        if menuSelection > 9 then menuSelection = 1 end
                    end
                    if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                        if menuSelection == 1 then
                            showMenu = false  -- Resume
                        elseif menuSelection == 2 then
                            inSaveMenu = true
                            saveMenuSelection = 1
                            saveMenuMessage = ""
                            saveMenuMessageTimer = 0
                        elseif menuSelection == 3 then
                            inInventoryMenu = true
                            inventoryMenuSelection = 1
                            inventoryMenuPage = 1
                            inventoryMenuTab = 1
                            inventoryMenuMessage = ""
                            inventoryMenuMessageTimer = 0
                        elseif menuSelection == 4 then
                            inStatsMenu = true
                            statsMenuSelection = 1
                            statsMenuMessage = ""
                            statsMenuMessageTimer = 0
                        elseif menuSelection == 5 then
                            inMasteryMenu = true
                            masteryMenuSelection = 1
                            masteryMenuMessage = ""
                            masteryMenuMessageTimer = 0
                        elseif menuSelection == 6 then
                            inOptionsMenu = true  -- Enter options
                            optionsSelection = 1
                            inGameDebugMenu = false
                        elseif menuSelection == 7 then
                            -- Reset position and health
                            px, py, pdir = 2.5, 2.5, 0
                            lastSafeWallX = px
                            lastSafeWallY = py
                            playerHealth = MAX_HEALTH
                            showMenu = false
                        elseif menuSelection == 8 then
                            -- Return to title menu
                            showMenu = false
                            enterTitle()
                        elseif menuSelection == 9 then
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
                    local moveScale = PLAYER_MOVE_SPEED_SCALE or 1.0
                    local moveStep = (PLAYER_MOVE_SPEED_PER_SEC * moveScale) / SIM_TARGET_HZ
                    local strafeStep = (PLAYER_STRAFE_SPEED_PER_SEC * moveScale) / SIM_TARGET_HZ
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
                            local classId = getCurrentClassId()
                            local weaponClass = getEquippedWeaponClass()
                            local dmgMult, spdMult = computeWeaponProficiencyMultipliers(classId, weaponClass)
                            if not dmgMult or dmgMult < 1.0 then dmgMult = 1.0 end
                            if not spdMult or spdMult < 0.01 then spdMult = 1.0 end

                            if weaponClass == WEAPON_CLASS_RANGED then
                                lastAttackWeaponClass = WEAPON_CLASS_RANGED
                                if heldUp and isAttacking == 0 then
                                    if not bowChargeState.active then
                                        beginBowCharge(spdMult)
                                    end
                                    updateBowChargeTick()
                                elseif bowChargeState.active and isAttacking == 0 then
                                    releaseBowChargeShot(dmgMult, spdMult)
                                end
                            elseif simStep == 1 and pressedUp and isAttacking == 0 then
                                if bowChargeState.active then
                                    resetBowChargeState()
                                end
                                lastAttackWeaponClass = weaponClass
                                local baseHitDamage = math.floor(((PLAYER_DAMAGE or 0) * dmgMult) + 0.5)
                                if baseHitDamage < 1 then baseHitDamage = 1 end

                                local attackFrames = #swordAttack
                                if weaponClass == WEAPON_CLASS_MAGIC then
                                    attackFrames = #staffCast
                                end
                                local baseAttackFrames = 9
                                if attackFrames == 0 then
                                    baseAttackFrames = 10
                                end
                                local attackScale = PLAYER_ATTACK_SPEED_SCALE or 1.0
                                -- Attack speed multiplier means "faster", but our attackScale is "frames per attack".
                                attackScale = attackScale / spdMult
                                local scaledAttackFrames = math.floor((baseAttackFrames * attackScale) + 0.5)
                                if scaledAttackFrames < (PLAYER_ATTACK_MIN_FRAMES or 5) then
                                    scaledAttackFrames = (PLAYER_ATTACK_MIN_FRAMES or 5)
                                end
                                if scaledAttackFrames > (PLAYER_ATTACK_MAX_FRAMES or 18) then
                                    scaledAttackFrames = (PLAYER_ATTACK_MAX_FRAMES or 18)
                                end
                                attackTotalFrames = scaledAttackFrames
                                isAttacking = attackTotalFrames

                                if weaponClass == WEAPON_CLASS_MELEE then
                                    local hitSomething = false
                                    for i = 1, #sprites do
                                        local s = sprites[i]
                                        if s.t == 5 and s.alive then
                                            local sdxHit = s.x - px
                                            local sdyHit = s.y - py
                                            local distSq = sdxHit * sdxHit + sdyHit * sdyHit
                                            if distSq < attackRangeSq then
                                                local hitDamage = baseHitDamage
                                                local critSalt = (i * 199) + (simTickCount or 0) + math.floor((s.x or 0) * 100) + math.floor((s.y or 0) * 100)
                                                if deterministicPercentRoll(PLAYER_CRIT_PERCENT or 0, critSalt) then
                                                    hitDamage = math.floor((hitDamage * (PLAYER_CRIT_MULT or 1.5)) + 0.5)
                                                end
                                                s.hp = s.hp - hitDamage
                                                recordDamageDealt(hitDamage)
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
                                    if not hitSomething and tryBreakChestInRange(attackRangeSq) then
                                        hitSomething = true
                                        if soundEnabled and swordHitSample then
                                            vmupro.sound.sample.stop(swordHitSample)
                                            vmupro.sound.sample.play(swordHitSample)
                                            if enableBootLogs then safeLog("INFO", "Play sample: sword_swing_connect") end
                                        end
                                    end
                                    if soundEnabled and (not hitSomething) and swordMissSample then
                                        vmupro.sound.sample.stop(swordMissSample)
                                        vmupro.sound.sample.play(swordMissSample)
                                        if enableBootLogs then safeLog("INFO", "Play sample: sword_miss") end
                                    end
                                else
                                    spawnPlayerProjectile(weaponClass, baseHitDamage, spdMult)
                                end
                            elseif bowChargeState.active then
                                resetBowChargeState()
                            end

                            isBlocking = heldDown
                        else
                            if bowChargeState.active and isAttacking == 0 then
                                local classId = getCurrentClassId()
                                local weaponClass = getEquippedWeaponClass()
                                if weaponClass == WEAPON_CLASS_RANGED then
                                    local dmgMult, spdMult = computeWeaponProficiencyMultipliers(classId, weaponClass)
                                    releaseBowChargeShot(dmgMult, spdMult)
                                else
                                    resetBowChargeState()
                                end
                            end

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

                        if simStep == 1 and pressedPower then
                            if bowChargeState.active then
                                resetBowChargeState()
                            end
                            showMenu = true
                            menuSelection = 1
                            inOptionsMenu = false
                            inGameDebugMenu = false
                            inSaveMenu = false
                            inInventoryMenu = false
                            inStatsMenu = false
                            inMasteryMenu = false
                            saveMenuSelection = 1
                            saveMenuMessage = ""
                            saveMenuMessageTimer = 0
                            inventoryMenuSelection = 1
                            inventoryMenuPage = 1
                            inventoryMenuTab = 1
                            inventoryMenuMessage = ""
                            inventoryMenuMessageTimer = 0
                            statsMenuSelection = 1
                            statsMenuMessage = ""
                            statsMenuMessageTimer = 0
                            masteryMenuSelection = 1
                            masteryMenuMessage = ""
                            masteryMenuMessageTimer = 0
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
