-- VMU Pro Dungeon Raycaster
-- Castle dungeon with detailed sprites

import "api/system"

enableBootLogs = true
enablePerfLogs = true
showFpsOverlay = true
lastFps = 0

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

-- Colors (RGB565 little-endian)
COLOR_BLACK = 0x0000
COLOR_WHITE = 0xFFFF
COLOR_RED = 0x00F8
COLOR_YELLOW = 0xE0FF
COLOR_ORANGE = 0x20FC
COLOR_SKIN = 0xB6BD
COLOR_SKIN_DARK = 0x9294
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
COLOR_LIGHT_MAROON = 0x0861
COLOR_SILVER = 0xF7BD
COLOR_DARK_SILVER = 0xCE7B

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
    {1,1,1,1,1,1,1,4,1,1,1,1,1,1,1,1},
    {1,0,0,0,6,0,1,0,0,0,6,0,0,0,0,1},
    {2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,2},
    {1,0,0,0,0,0,3,0,0,0,0,0,0,0,0,1},
    {1,6,0,0,0,0,0,0,0,0,0,0,0,0,6,1},
    {1,0,0,0,0,0,3,0,0,0,0,0,0,0,0,1},
    {1,2,2,0,2,2,1,0,0,5,0,5,0,0,1,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {3,0,0,6,0,0,0,0,0,0,0,0,0,6,0,3},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {3,0,0,6,0,0,0,0,0,0,0,0,0,6,0,3},
    {1,2,0,0,2,2,5,0,0,0,0,0,2,0,2,1},
    {1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1},
    {1,0,6,0,6,0,1,0,0,0,0,0,0,6,0,1},
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
            {1,1,1,1,1,1,1,4,1,1,1,1,1,1,1,1},
            {1,0,0,0,6,0,1,0,0,0,6,0,0,0,0,1},
            {2,0,0,0,0,0,1,0,0,0,0,0,0,6,0,2},
            {1,0,0,0,0,0,3,0,0,0,0,0,0,6,0,1},
            {1,6,0,0,0,0,0,0,0,0,0,0,0,0,6,1},
            {1,0,0,0,0,0,3,0,0,0,0,0,0,0,0,1},
            {1,2,2,0,2,2,1,0,0,5,0,5,0,0,1,1},
            {1,0,0,0,0,0,0,1,1,1,0,0,0,0,0,1},
            {3,0,0,6,0,0,0,1,4,1,0,0,0,6,0,3},
            {1,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1},
            {1,0,0,0,0,0,0,1,5,1,0,0,0,0,0,1},
            {3,0,0,6,0,0,0,0,0,0,0,0,0,6,0,3},
            {1,2,0,0,2,2,5,0,0,0,0,0,2,0,2,1},
            {1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1},
            {1,0,6,0,6,0,1,0,0,0,0,0,0,6,0,1},
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
wallTiles = nil

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
app_running = true
frameCount = 0
VIEWPORT_H = 240
HORIZON = 120  -- Eye level within viewport

-- Game state
isAttacking = 0      -- Attack animation frames remaining
attackTotalFrames = 0 -- Total frames for current attack animation
isBlocking = false   -- Currently blocking
blockAnim = 0        -- Shield raise animation frame (0 = hidden)
BLOCK_ANIM_FRAMES = 4
showMenu = false     -- Menu visible
menuSelection = 1    -- Current menu selection
inOptionsMenu = false -- Currently in options submenu
optionsSelection = 1  -- Current options selection

-- Options settings
soundEnabled = true   -- Sound on/off
showHealthPercent = true  -- Health % display on/off

-- Sound effects
    swordSwooshSynth = nil
    gruntSample = nil
    swordHitSample = nil
    swordMissSample = nil
    yahSample = nil
    winLevelSample = nil
    argDeathSample = nil
audioInitialized = false
audioSystemActive = false
titleSample = nil
titleOverlaySample = nil
titleOverlayPlayed = false
titleMusicStartUs = 0
titleMusicState = "stopped" -- stopped|playing|fading|paused
titleMusicTimer = 0
titleFadeTimer = 0
titlePauseTimer = 0
TITLE_MUSIC_FPS = 60
TITLE_MUSIC_FADE_START_FRAMES = 40 * TITLE_MUSIC_FPS
TITLE_MUSIC_FADE_FRAMES = 5 * TITLE_MUSIC_FPS
TITLE_MUSIC_PAUSE_FRAMES = 2 * TITLE_MUSIC_FPS
TITLE_MUSIC_VOLUME = 1.0
TITLE_OVERLAY_DELAY_US = 500000
TITLE_OVERLAY_VOLUME = 1.0

-- Enemy attack effects (list of active swipe effects)
swipeEffects = {}  -- {x, y, angle, frame, maxFrames}

-- Attack constants
DETECTION_RANGE = 4    -- How far soldier can see player
ATTACK_RANGE = 1.0     -- Distance to attack (about 1 body length)
ATTACK_COOLDOWN = 60   -- Frames between attacks (slowed 2x)
CHASE_SPEED_MULT = 3   -- Speed multiplier when chasing (sprint)
SOLDIER_SPEED_SCALE = 0.125 -- Slow all soldier movement (0.125 = 8x slower)

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
wallSheets = {}
wallTextureLoadAttempted = false
USE_WALL_QUADS = true
DEBUG_DISABLE_WALL_TEXTURE = false
DEBUG_SKIP_SPRITES = false
WALL_TEXTURE_MODE = "proper" -- proper | lazy_quads | flat
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
DEBUG_DISABLE_PROPS = false
WALL_TEX_MAX_DIST = 6.0
  FOG_START = 2.5
  FOG_END = 5.0
  FOG_COLOR = COLOR_DARK_GRAY
  FOG_TEX_CUTOFF = 2.5
  DEBUG_DISABLE_FOG = true
DEBUG_DISABLE_EFFECTS = true
LOW_RES_WALLS = true
LOW_RES_MODE = "quality"
SHOW_MINIMAP = true
RENDERER_MODE = "exp_hybrid" -- classic | exp_hybrid | exp_pure
DEBUG_DISABLE_ENEMIES = false
local function wallQuadLog(msg)
    if enableBootLogs and DEBUG_WALL_QUADS_LOG and wallQuadLogCount < 30 then
        print(msg)
        wallQuadLogCount = wallQuadLogCount + 1
    end
end
local function renderLog(msg)
    if enableBootLogs and DEBUG_WALL_QUADS_LOG then
        print("[RENDER] " .. msg)
    end
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
titleNeedsRedraw = true
FPS_TARGET_MODE = "uncapped" -- uncapped | 60 | 30 (gameplay only)

local function quitApp(reason)
    logBoot(vmupro.system.LOG_ERROR, "APP EXIT: " .. tostring(reason))
    app_running = false
end

local function isExpRenderer()
    return RENDERER_MODE == "exp_hybrid" or RENDERER_MODE == "exp_pure"
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
    if loadingLogCount < 20 then
        print(msg)
        loadingLogCount = loadingLogCount + 1
    end
end

-- Debug controls (set to true for sprite testing)
DEBUG_DISABLE_ENEMY_AGGRO = false  -- Enemies never chase/attack
DEBUG_WALK_IN_PLACE = false       -- Enemies animate walk without moving
DEBUG_FLIP_WALK_SIDES = false     -- Use left-walk sprites and flip for right side
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

-- Death sounds
local groanSynth = nil
local squishSynth = nil

-- Pickup sounds
local gulpSynth = nil

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
    wallTiles = {}
    for my = 0, 15 do
        for mx = 0, 15 do
            local wtype = map[my + 1][mx + 1]
            if wtype and wtype > 0 then
                wallTiles[#wallTiles + 1] = {
                    x = mx + 0.5,
                    y = my + 0.5,
                    t = wtype
                }
            end
        end
    end
    wallQuadLog("WQ loadLevel " .. tostring(levelId) .. " wallTiles=" .. tostring(#wallTiles))
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
    for _, sheet in pairs(wallSheets) do
        if sheet then
            vmupro.sprite.free(sheet)
        end
    end
    wallSheets = {}
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
local loadTextureSheetWithValidation
local logTextureMemoryUsage

function loadWallTextures()
    if wallTextureLoadAttempted then return end
    wallTextureLoadAttempted = true
    -- Load wall textures with validation
    wallStone = loadTextureWithValidation("sprites/wall_textures/stone", "stone")
    wallBrick = loadTextureWithValidation("sprites/wall_textures/brick", "brick")
    wallMoss = loadTextureWithValidation("sprites/wall_textures/moss", "moss")
    wallMetal = loadTextureWithValidation("sprites/wall_textures/metal", "metal")
    wallWood = loadTextureWithValidation("sprites/wall_textures/wood", "wood")

    -- Optional per-column wall texture sheets (filename pattern: <name>-table-1-128)
    wallSheets.stone = loadTextureSheetWithValidation("sprites/wall_textures/stone-table-1-128", "stone_sheet")
    wallSheets.brick = loadTextureSheetWithValidation("sprites/wall_textures/brick-table-1-128", "brick_sheet")
    wallSheets.moss = loadTextureSheetWithValidation("sprites/wall_textures/moss-table-1-128", "moss_sheet")
    wallSheets.metal = loadTextureSheetWithValidation("sprites/wall_textures/metal-table-1-128", "metal_sheet")
    wallSheets.wood = loadTextureSheetWithValidation("sprites/wall_textures/wood-table-1-128", "wood_sheet")

    -- Log total texture memory usage
    logTextureMemoryUsage()
end

function unloadWallTextures()
    freeSpriteRef(wallStone); wallStone = nil
    freeSpriteRef(wallBrick); wallBrick = nil
    freeSpriteRef(wallMoss); wallMoss = nil
    freeSpriteRef(wallMetal); wallMetal = nil
    freeSpriteRef(wallWood); wallWood = nil
    for _, sheet in pairs(wallSheets) do
        if sheet then
            vmupro.sprite.free(sheet)
        end
    end
    wallSheets = {}
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
        "Loaded texture '%s': %dx%d (%d pixels) from %s",
        textureName, width, height, width * height, path
    ))

    return sprite
end

-- Load texture sheet with dimension validation (for per-column wall texturing)
loadTextureSheetWithValidation = function(path, textureName)
    local success, sheet = pcall(function()
        return vmupro.sprite.newSheet(path)
    end)

    if not success then
        safeLog("WARN", string.format(
            "Failed to load texture sheet '%s' from path: %s. Error: %s",
            textureName, path, tostring(sheet)
        ))
        return nil
    end

    if not sheet then
        safeLog("WARN", string.format(
            "Texture sheet '%s' returned nil from path: %s",
            textureName, path
        ))
        return nil
    end

    if not sheet.frameWidth or not sheet.frameHeight or not sheet.frameCount then
        safeLog("WARN", string.format(
            "Texture sheet '%s' missing frame data: frameWidth=%s frameHeight=%s frameCount=%s",
            textureName, tostring(sheet.frameWidth), tostring(sheet.frameHeight), tostring(sheet.frameCount)
        ))
        vmupro.sprite.free(sheet)
        return nil
    end

    if enableBootLogs then
        safeLog("INFO", string.format(
            "Texture sheet '%s' loaded: frame %dx%d, count=%s",
            textureName, sheet.frameWidth, sheet.frameHeight, tostring(sheet.frameCount)
        ))
    end

    return sheet
end

-- Validate texture dimensions meet minimum requirements (metadata-driven)
local function validateTextureMinimumDimensions(textureName, minWidth, minHeight)
    local metadata = textureMetadata[textureName]

    if not metadata then
        safeLog("WARN", string.format(
            "Cannot validate texture '%s': no metadata found",
            textureName
        ))
        return false
    end

    if metadata.width < minWidth or metadata.height < minHeight then
        safeLog("ERROR", string.format(
            "Texture '%s' (%dx%d) does not meet minimum size requirements (%dx%d)",
            textureName, metadata.width, metadata.height, minWidth, minHeight
        ))
        return false
    end

    safeLog("INFO", string.format(
        "Texture '%s' dimension validation passed: %dx%d >= %dx%d",
        textureName, metadata.width, metadata.height, minWidth, minHeight
    ))

    return true
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

-- Get texture metadata
local function getTextureMetadata(textureName)
    return textureMetadata[textureName]
end

local function freeSynthRef(synth)
    if synth then
        vmupro.sound.synth.free(synth)
    end
end

local function unloadLevelAudio()
    if not audioInitialized then return end
    freeSynthRef(swordSwooshSynth); swordSwooshSynth = nil
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
    freeSynthRef(groanSynth); groanSynth = nil
    freeSynthRef(squishSynth); squishSynth = nil
    freeSynthRef(gulpSynth); gulpSynth = nil
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

    -- Create groan synth (low frequency for death groan)
    groanSynth = vmupro.sound.synth.new(vmupro.sound.kWaveSawtooth)
    if groanSynth then
        vmupro.sound.synth.setAttack(groanSynth, 0.05)
        vmupro.sound.synth.setDecay(groanSynth, 0.3)
        vmupro.sound.synth.setSustain(groanSynth, 0.1)
        vmupro.sound.synth.setRelease(groanSynth, 0.2)
        vmupro.sound.synth.setVolume(groanSynth, 0.6, 0.6)
    end

    -- Create squish synth (noise burst for impact)
    squishSynth = vmupro.sound.synth.new(vmupro.sound.kWaveNoise)
    if squishSynth then
        vmupro.sound.synth.setAttack(squishSynth, 0.01)
        vmupro.sound.synth.setDecay(squishSynth, 0.15)
        vmupro.sound.synth.setSustain(squishSynth, 0.0)
        vmupro.sound.synth.setRelease(squishSynth, 0.1)
        vmupro.sound.synth.setVolume(squishSynth, 0.7, 0.7)
    end

    -- Create gulp synth (for health pickup)
    gulpSynth = vmupro.sound.synth.new(vmupro.sound.kWaveSine)
    if gulpSynth then
        vmupro.sound.synth.setAttack(gulpSynth, 0.02)
        vmupro.sound.synth.setDecay(gulpSynth, 0.1)
        vmupro.sound.synth.setSustain(gulpSynth, 0.3)
        vmupro.sound.synth.setRelease(gulpSynth, 0.15)
        vmupro.sound.synth.setVolume(gulpSynth, 0.6, 0.6)
    end

    audioInitialized = true
end

local function loadTitleMusic()
    if titleSample then return end
    if not audioSystemActive then
        vmupro.audio.startListenMode()
        audioSystemActive = true
    end
    vmupro.audio.setGlobalVolume(10)
    titleSample = vmupro.sound.sample.new("sounds/intro_source_44k1_adpcm_stereo")
    titleOverlaySample = vmupro.sound.sample.new("sounds/inner_sanctum_44k1_adpcm_stereo")
    if vmupro.system and vmupro.system.log then
        if titleSample then
            vmupro.system.log(vmupro.system.LOG_INFO, "AUDIO", "Title sample loaded")
        else
            vmupro.system.log(vmupro.system.LOG_ERROR, "AUDIO", "Title sample load failed")
        end
        if titleOverlaySample then
            vmupro.system.log(vmupro.system.LOG_INFO, "AUDIO", "Title overlay sample loaded")
        else
            vmupro.system.log(vmupro.system.LOG_ERROR, "AUDIO", "Title overlay sample load failed")
        end
    end
    if titleSample then
        vmupro.sound.sample.setVolume(titleSample, TITLE_MUSIC_VOLUME, TITLE_MUSIC_VOLUME)
    end
    if titleOverlaySample then
        vmupro.sound.sample.setVolume(titleOverlaySample, TITLE_OVERLAY_VOLUME, TITLE_OVERLAY_VOLUME)
    end
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
    titleFadeTimer = 0
    titlePauseTimer = 0
    titleOverlayPlayed = false
    titleMusicStartUs = 0
    if audioSystemActive and not audioInitialized then
        vmupro.audio.exitListenMode()
        audioSystemActive = false
    end
end

local function startTitleMusic()
    if not soundEnabled then return end
    loadTitleMusic()
    if titleSample then
        vmupro.sound.sample.setVolume(titleSample, TITLE_MUSIC_VOLUME, TITLE_MUSIC_VOLUME)
        vmupro.sound.sample.play(titleSample, 0)
        if vmupro.system and vmupro.system.log then
            vmupro.system.log(vmupro.system.LOG_INFO, "AUDIO", "Title sample play")
        end
        titleMusicState = "playing"
        titleMusicTimer = 0
        titleFadeTimer = 0
        titlePauseTimer = 0
        titleOverlayPlayed = false
        titleMusicStartUs = (vmupro.system and vmupro.system.getTimeUs and vmupro.system.getTimeUs()) or 0
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

    if titleMusicState == "playing" then
        titleMusicTimer = titleMusicTimer + 1
        if not titleOverlayPlayed and titleOverlaySample then
            local nowUs = (vmupro.system and vmupro.system.getTimeUs and vmupro.system.getTimeUs()) or 0
            if titleMusicStartUs > 0 and nowUs > titleMusicStartUs
                and (nowUs - titleMusicStartUs) >= TITLE_OVERLAY_DELAY_US then
                vmupro.sound.sample.play(titleOverlaySample, 0)
                titleOverlayPlayed = true
            end
        end
        if titleMusicTimer >= TITLE_MUSIC_FADE_START_FRAMES then
            titleMusicState = "fading"
            titleFadeTimer = 0
        end
    elseif titleMusicState == "fading" then
        titleFadeTimer = titleFadeTimer + 1
        local t = titleFadeTimer / TITLE_MUSIC_FADE_FRAMES
        if t > 1 then t = 1 end
        local v = TITLE_MUSIC_VOLUME * (1 - t)
        if titleSample then
            vmupro.sound.sample.setVolume(titleSample, v, v)
        end
        if titleFadeTimer >= TITLE_MUSIC_FADE_FRAMES then
            if titleSample then
                vmupro.sound.sample.stop(titleSample)
            end
            titleMusicState = "paused"
            titlePauseTimer = 0
        end
    elseif titleMusicState == "paused" then
        titlePauseTimer = titlePauseTimer + 1
        if titlePauseTimer >= TITLE_MUSIC_PAUSE_FRAMES then
            startTitleMusic()
        end
    end
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
    swipeEffects = {}
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
    if checkArrayBounds(sprites, 1, "updateSoldiers") then
        for i = 1, #sprites do
            if checkArrayBounds(sprites, i, "updateSoldiers") then
                local s = sprites[i]
                if s.t == 5 and s.speed then  -- Warriors with movement data
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
                    if distSq > SOLDIER_ACTIVE_DIST_SQ and (frameCount % 8) ~= 0 then
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
                            s.attackAnim = 6
                            s.attackFrame = 1

                            -- Soldier attack sound
                            if yahSample and soundEnabled then
                                vmupro.sound.sample.stop(yahSample)
                                vmupro.sound.sample.play(yahSample)
                                if enableBootLogs then safeLog("INFO", "Play sample: yah") end
                            end


                            -- Apply damage to player
                            playerHealth = playerHealth - DAMAGE_PER_HIT
                            if playerHealth <= 0 then
                                playerHealth = 0
                                gameState = STATE_GAME_OVER
                                gameOverSelection = 1
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
                        elseif s.attackAnim <= 0 then
                            s.attackAnim = 0
                        end
                    end
                    ::continue::
                end
            end
        end
    end
end

-- Update swipe effects
local function updateSwipeEffects()
    local i = 1
    while i <= #swipeEffects do
        local e = swipeEffects[i]
        e.frame = e.frame + 1
        if e.frame >= e.maxFrames then
            table.remove(swipeEffects, i)
        else
            i = i + 1
        end
    end
end

local function updateDeathAnimations()
    if not sprites or #sprites == 0 then return end
    if checkArrayBounds(sprites, 1, "updateDeathAnimations") then
        for i = 1, #sprites do
            if checkArrayBounds(sprites, i, "updateDeathAnimations") then
                local s = sprites[i]
                if s.t == 5 and s.dying then
                    if #warriorDeath == 0 then
                        s.dying = false
                        s.dead = true
                        goto continue_death
                    end
                    s.deathTick = (s.deathTick or 0) + 1
                    if s.deathTick % 2 == 0 then
                        s.deathFrame = (s.deathFrame or 1) + 1
                        if s.deathFrame > #warriorDeath then
                            s.dying = false
                            s.dead = true
                        end
                    end
                    ::continue_death::
                end
            end
        end
    end
end

-- Draw swipe effects
local function drawSwipeEffects()
    for _, e in ipairs(swipeEffects) do
        local progress = e.frame / e.maxFrames
        local alpha = 1.0 - progress  -- Fade out
        local radius = 30 + progress * 50  -- Expand outward

        -- Draw arc lines for sword swipe effect
        local numLines = 5
        local arcSpan = 1.5  -- Radians of arc
        local startAngle = e.angle - arcSpan / 2

        for j = 0, numLines - 1 do
            local lineProgress = j / numLines
            local lineAlpha = alpha * (1 - lineProgress * 0.5)
            local lineRadius = radius * (0.7 + lineProgress * 0.3)

            local a1 = startAngle + (arcSpan * lineProgress)
            local a2 = a1 + arcSpan / numLines

            local x1 = e.x + math.cos(a1) * lineRadius
            local y1 = e.y + math.sin(a1) * lineRadius
            local x2 = e.x + math.cos(a2) * lineRadius
            local y2 = e.y + math.sin(a2) * lineRadius

            -- Use white/silver color for sword swipe
            local color = (lineAlpha > 0.5) and COLOR_WHITE or COLOR_SILVER
            vmupro.graphics.drawLine(math.floor(x1), math.floor(y1),
                                     math.floor(x2), math.floor(y2), color)
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
            table.remove(bloodEffects, i)
        else
            i = i + 1
        end
    end
end

-- Draw blood effects (in screen space, needs distance calculation)
local function drawBloodEffectAt(screenX, screenY, dist, life)
    local maxLife = 30
    local alpha = life / maxLife
    local baseSize = math.max(2, math.floor(8 / dist))

    -- Draw blood splatter particles
    local numDrops = 8
    for j = 1, numDrops do
        local angle = (j / numDrops) * 6.28318 + (life * 0.1)
        local spread = (maxLife - life) * 2
        local px = screenX + math.cos(angle) * spread
        local py = screenY + math.sin(angle) * spread

        if px >= 0 and px < 240 and py >= 0 and py < 240 then
            -- Draw blood drop
            vmupro.graphics.drawFillRect(
                math.floor(px) - 1, math.floor(py) - 1,
                math.floor(px) + 1, math.floor(py) + 1,
                COLOR_RED
            )
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
        if groanSynth then
            vmupro.sound.synth.playNote(groanSynth, 80, 0.8, 0.4)
        end
        if squishSynth then
            vmupro.sound.synth.playNote(squishSynth, 200, 0.9, 0.2)
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
    if not sprites or #sprites == 0 then return end
    if checkArrayBounds(sprites, 1, "checkHealthPickups") then
        for i = 1, #sprites do
            if checkArrayBounds(sprites, i, "checkHealthPickups") then
                local s = sprites[i]
        if s.t == 7 and not s.collected then
            local dx = s.x - px
            local dy = s.y - py
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < pickupRange then
                -- Collect the vial
                s.collected = true
                playerHealth = MAX_HEALTH

                -- Play gulp sound
                if soundEnabled and gulpSynth then
                    vmupro.sound.synth.playNote(gulpSynth, 300, 0.8, 0.2)
                    vmupro.sound.synth.playNote(gulpSynth, 250, 0.6, 0.15)
                end
            end
          end
        end
    end
    end
end

-- Draw win screen
local function drawWinScreen()
    -- Darken background (larger)
    vmupro.graphics.drawFillRect(20, 40, 220, 200, COLOR_BLACK)
    vmupro.graphics.drawFillRect(25, 45, 215, 195, COLOR_DARK_GRAY)

    -- Title
    vmupro.graphics.drawFillRect(30, 55, 210, 90, COLOR_GREEN)
    vmupro.text.setFont(vmupro.text.FONT_SMALL)
    vmupro.graphics.drawText("VICTORY!", 76, 63, COLOR_WHITE, COLOR_GREEN)

    -- Subtitle
    vmupro.graphics.drawText("The King is safe!", 56, 100, COLOR_WHITE, COLOR_DARK_GRAY)
    vmupro.graphics.drawText("You cleared the level!", 44, 122, COLOR_WHITE, COLOR_DARK_GRAY)

    if winBannerTimer > 0 then
        local pulse = (frameCount % 20) < 10
        local bannerColor = pulse and COLOR_MAROON or COLOR_DARK_MAROON
        vmupro.graphics.drawFillRect(35, 130, 205, 154, bannerColor)
        vmupro.text.setFont(vmupro.text.FONT_SMALL)
        vmupro.graphics.drawText("LEVEL COMPLETE", 46, 136, COLOR_WHITE, bannerColor)
    end

    -- Menu option
    local y = 160
    local bgColor = COLOR_DARK_GRAY
    local textColor = COLOR_GRAY
    if winSelection == 1 then
        vmupro.graphics.drawFillRect(40, y, 200, y + 20, COLOR_MAROON)
        bgColor = COLOR_MAROON
        textColor = COLOR_WHITE
    end
    local winText = "MAIN MENU"
    if currentLevel < MAX_LEVEL then
        winText = "NEXT LEVEL"
    end
    vmupro.text.setFont(vmupro.text.FONT_SMALL)
    vmupro.graphics.drawText(winText, 74, y + 2, textColor, bgColor)
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
        vmupro.text.setFont(vmupro.text.FONT_SMALL)
        local healthText = tostring(math.floor(playerHealth)) .. "%"
        vmupro.graphics.drawText(healthText, potionX + 18, potionY + 50, COLOR_WHITE, COLOR_BLACK)
    end
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
        vmupro.graphics.drawFillRect(20, 50, 220, 239, COLOR_BLACK)
        vmupro.graphics.drawFillRect(25, 55, 215, 237, COLOR_DARK_GRAY)
        vmupro.graphics.drawFillRect(30, 60, 210, 82, COLOR_MAROON)
        vmupro.text.setFont(vmupro.text.FONT_TINY_6x8)
        vmupro.graphics.drawText(titleInDebug and "DEBUG" or "OPTIONS", 92, 65, COLOR_WHITE, COLOR_MAROON)

        local items = {}
        if titleInDebug then
            local logsText = "LOGS: " .. (enableBootLogs and "ON" or "OFF")
            local enemiesText = "ENEMIES: " .. (DEBUG_DISABLE_ENEMIES and "OFF" or "ON")
            local propsText = "PROPS: " .. (DEBUG_DISABLE_PROPS and "OFF" or "ON")
            local texturesText = "TEXTURES: " .. (DEBUG_DISABLE_WALL_TEXTURE and "OFF" or "ON")
            local fpsText = "FPS: " .. (showFpsOverlay and "ON" or "OFF")
            local resLabel = (LOW_RES_MODE == "fast") and "FAST" or "QUALITY"
            local resText = "WALL RES: " .. resLabel
            local minimapText = "MINIMAP: " .. (SHOW_MINIMAP and "ON" or "OFF")
            local renderLabel = "CLASSIC"
            if RENDERER_MODE == "exp_hybrid" then
                renderLabel = "EXP-H"
            elseif RENDERER_MODE == "exp_pure" then
                renderLabel = "EXP-P"
            end
            local rendererText = "RENDER: " .. renderLabel
            local fpsTargetText = "FPS TARGET: " .. string.upper(FPS_TARGET_MODE)
            items = {logsText, enemiesText, propsText, texturesText, fpsText, resText, minimapText, rendererText, fpsTargetText, "BACK"}
        else
            local levelLabel = LEVEL_SELECT_LIST[selectedLevel] and LEVEL_SELECT_LIST[selectedLevel].label or tostring(selectedLevel)
            local levelText = "LEVEL: " .. levelLabel
            local soundText = "SOUND: " .. (soundEnabled and "ON" or "OFF")
            local healthText = "HEALTH%: " .. (showHealthPercent and "ON" or "OFF")
            local renderLabel = "CLASSIC"
            if RENDERER_MODE == "exp_hybrid" then
                renderLabel = "EXP-H"
            elseif RENDERER_MODE == "exp_pure" then
                renderLabel = "EXP-P"
            end
            local rendererText = "RENDER: " .. renderLabel
            items = {levelText, soundText, healthText, rendererText, "DEBUG", "BACK"}
        end
        for i, item in ipairs(items) do
            local x = 34
            local startY = titleInDebug and 80 or 90
            local stepY = titleInDebug and 16 or 18
            local y = startY + (i - 1) * stepY
            local bgColor = COLOR_DARK_GRAY
            local textColor = COLOR_GRAY
            local sel = titleInDebug and titleDebugSelection or titleOptionsSelection
            if i == sel then
                local boxH = titleInDebug and 16 or 18
                vmupro.graphics.drawFillRect(32, y, 208, y + boxH, COLOR_MAROON)
                bgColor = COLOR_MAROON
                textColor = COLOR_WHITE
            end
            if titleInDebug then
                vmupro.text.setFont(vmupro.text.FONT_MONO_7x13)
            else
                vmupro.text.setFont(vmupro.text.FONT_TINY_6x8)
            end
            vmupro.graphics.drawText(item, x, y + 2, textColor, bgColor)
        end
    else
        -- Main title menu
        logBoot(vmupro.system.LOG_ERROR, "D title main text")
        -- Compact menu box for 3 items
        vmupro.graphics.drawFillRect(60, 140, 180, 230, COLOR_BLACK)
        vmupro.graphics.drawFillRect(65, 145, 175, 225, COLOR_DARK_GRAY)
        vmupro.text.setFont(vmupro.text.FONT_SMALL)
        local items = {"START GAME", "OPTIONS", "EXIT"}
        for i, item in ipairs(items) do
            local y = 153 + (i - 1) * 18
            local bgColor = COLOR_DARK_GRAY
            local textColor = COLOR_GRAY
            if i == titleSelection then
                vmupro.graphics.drawFillRect(70, y, 170, y + 18, COLOR_MAROON)
                bgColor = COLOR_MAROON
                textColor = COLOR_WHITE
            end
            vmupro.text.setFont(vmupro.text.FONT_SMALL)
            vmupro.graphics.drawText(item, 78, y + 2, textColor, bgColor)
        end
    end
end

drawTitleScreen = drawTitleScreenImpl
logBoot(vmupro.system.LOG_ERROR, "drawTitleScreen bound to impl")

-- Draw game over screen
local function drawGameOver()
    -- Darken background
    vmupro.graphics.drawFillRect(40, 70, 200, 195, COLOR_BLACK)
    vmupro.graphics.drawFillRect(45, 75, 195, 190, COLOR_DARK_GRAY)

    -- Title
    vmupro.graphics.drawFillRect(50, 80, 190, 102, COLOR_MAROON)
    vmupro.text.setFont(vmupro.text.FONT_SMALL)
    vmupro.graphics.drawText("GAME OVER", 76, 85, COLOR_WHITE, COLOR_MAROON)

    -- Menu items
    local items = {"RESTART", "MENU", "QUIT"}
    for i, item in ipairs(items) do
        local y = 110 + (i - 1) * 18
        local bgColor = COLOR_DARK_GRAY
        local textColor = COLOR_GRAY
        if i == gameOverSelection then
            vmupro.graphics.drawFillRect(50, y, 190, y + 18, COLOR_MAROON)
            bgColor = COLOR_MAROON
            textColor = COLOR_WHITE
        end
        vmupro.text.setFont(vmupro.text.FONT_SMALL)
        vmupro.graphics.drawText(item, 86, y + 2, textColor, bgColor)
    end
end

-- Reset game state for restart
local function resetGame()
    restartLevel()
end

-- Collision detection for sprites
function collidesWithSprite(nx, ny)
    if not sprites or #sprites == 0 then return false end
    if checkArrayBounds(sprites, 1, "collidesWithSprite") then
        for i = 1, #sprites do
            if checkArrayBounds(sprites, i, "collidesWithSprite") then
                local s = sprites[i]
                if DEBUG_DISABLE_ENEMIES and isEnemyType(s.t) then
                    goto continue_collide
                end
                if DEBUG_DISABLE_PROPS and isPropType(s.t) then
                    goto continue_collide
                end
                if s.t == 5 and (s.dying or s.dead) then
                    goto continue_collide
                end
                if s.t == 7 then
                    goto continue_collide
                end
                local dx, dy = nx - s.x, ny - s.y
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist < 0.4 then  -- Collision radius
                    return true
                end
                ::continue_collide::
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
        if side == 1 then return COLOR_BRICK_D else return COLOR_BRICK_L end
    else
        if side == 1 then return COLOR_STONE_D else return COLOR_STONE_L end
    end
end

-- Movement collision helper (walls + sprites)
function canMove(x, y)
    if not isWalkable(x, y) then
        return false
    end
    if collidesWithSprite(x, y) then
        return false
    end
    return true
end

local function fogBlend(color, dist)
    if dist <= FOG_START then return color end
    if dist >= FOG_END then return FOG_COLOR end
    local t = (dist - FOG_START) / (FOG_END - FOG_START)
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

local function drawWallTexture(wtype, side, sx, y1, y2)
    local sprite = nil
    if wtype == 1 or wtype == 6 then
        sprite = wallStone
    elseif wtype == 2 then
        sprite = wallBrick
    elseif wtype == 3 then
        sprite = wallMoss
    elseif wtype == 4 then
        sprite = wallMetal
    elseif wtype == 5 then
        sprite = wallWood
    end

    -- Safety check: sprite must exist
    if not sprite then
        renderLog("drawWallTexture: No sprite for wtype=" .. tostring(wtype))
        return
    end

    -- Safety check: sprite dimensions must be valid
    if not sprite.width or not sprite.height then
        renderLog("drawWallTexture: Invalid sprite dimensions for wtype=" .. tostring(wtype))
        return
    end

    local texW, texH = sprite.width, sprite.height
    renderLog("drawWallTexture: wtype=" .. tostring(wtype) .. " texW=" .. tostring(texW) .. " texH=" .. tostring(texH))

    -- Safety check: wall height must be positive
    local wallH = y2 - y1
    if wallH <= 0 then
        renderLog("drawWallTexture: Invalid wall height (y1=" .. tostring(y1) .. " y2=" .. tostring(y2) .. ")")
        return
    end

    -- Detect texture size and compute appropriate scale
    local scaleX = 1.0
    local validTexture = false

    -- Supported texture sizes with their scale factors
    if texW == 128 and texH == 256 then
        -- Vertical texture (128x256) - standard wall
        scaleX = 4 / texW  -- Scale to 4 pixels wide
        validTexture = true
        renderLog("drawWallTexture: 128x256 texture detected, scaleX=" .. tostring(scaleX))
    elseif texW == 256 and texH == 128 then
        -- Horizontal texture (256x128) - wide wall
        scaleX = 4 / texW  -- Scale to 4 pixels wide
        validTexture = true
        renderLog("drawWallTexture: 256x128 texture detected, scaleX=" .. tostring(scaleX))
    elseif texW == 128 and texH == 128 then
        -- Square texture (128x128)
        scaleX = 4 / texW  -- Scale to 4 pixels wide
        validTexture = true
        renderLog("drawWallTexture: 128x128 texture detected, scaleX=" .. tostring(scaleX))
    else
        -- Unknown texture size - log error
        renderLog("drawWallTexture: ERROR - Unsupported texture size " .. tostring(texW) .. "x" .. tostring(texH))
        return
    end

    -- Safety check: validate scaleX value
    if scaleX <= 0 or scaleX ~= scaleX or scaleX == math.huge or scaleX == -math.huge then
        renderLog("drawWallTexture: ERROR - Invalid scaleX value: " .. tostring(scaleX))
        return
    end

    -- If wall is extremely tall (very close), draw a single scaled texture to avoid huge tiling
    if wallH > (texH * 4) then
        local scaleY = wallH / texH
        if scaleY > 10 then scaleY = 10 end
        if safeScale(sprite, scaleX, scaleY, "drawWallTexture_tall") then
            vmupro.sprite.drawScaled(sprite, sx, y1, scaleX, scaleY, vmupro.sprite.kImageUnflipped)
        end
        return
    end

    -- Tile vertically
    local tileH = texH
    local fullTiles = math.floor(wallH / tileH)
    local remainder = wallH - (fullTiles * tileH)

    renderLog("drawWallTexture: wallH=" .. tostring(wallH) .. " tileH=" .. tostring(tileH) .. " fullTiles=" .. tostring(fullTiles) .. " remainder=" .. tostring(remainder))

    -- Safety check: ensure fullTiles is reasonable
    if fullTiles < 0 or fullTiles > 1000 then
        renderLog("drawWallTexture: ERROR - Invalid fullTiles count: " .. tostring(fullTiles))
        return
    end

    local drawY = y1
    for i = 1, fullTiles do
        -- Safety check: verify drawY is within screen bounds
        if drawY < 0 or drawY > 240 then
            renderLog("drawWallTexture: WARNING - drawY out of bounds: " .. tostring(drawY))
        end

        -- Safety check: verify coordinates are valid
        if sx < 0 or sx > 400 then
            renderLog("drawWallTexture: WARNING - sx out of bounds: " .. tostring(sx))
        end

        if safeScale(sprite, scaleX, 1.0, "drawWallTexture") then
            vmupro.sprite.drawScaled(sprite, sx, drawY, scaleX, 1.0, vmupro.sprite.kImageUnflipped)
        end
        drawY = drawY + tileH
    end

    if remainder > 0 then
        local scaleY = remainder / tileH

        -- Safety check: validate scaleY value
        if scaleY <= 0 or scaleY > 1.0 or scaleY ~= scaleY or scaleY == math.huge or scaleY == -math.huge then
            renderLog("drawWallTexture: ERROR - Invalid scaleY value: " .. tostring(scaleY))
            return
        end

        renderLog("drawWallTexture: Drawing remainder tile with scaleY=" .. tostring(scaleY))

        -- Safety check: verify drawY is within screen bounds
        if drawY < 0 or drawY > 240 then
            renderLog("drawWallTexture: WARNING - drawY out of bounds for remainder: " .. tostring(drawY))
        end

        if safeScale(sprite, scaleX, scaleY, "drawWallTexture_remainder") then
            vmupro.sprite.drawScaled(sprite, sx, drawY, scaleX, scaleY, vmupro.sprite.kImageUnflipped)
        end
    end
end

local function getWallSheet(wtype)
    if wtype == 1 or wtype == 6 then
        return wallSheets.stone
    elseif wtype == 2 then
        return wallSheets.brick
    elseif wtype == 3 then
        return wallSheets.moss
    elseif wtype == 4 then
        return wallSheets.metal
    elseif wtype == 5 then
        return wallSheets.wood
    end
    return nil
end

local function drawWallTextureColumn(wtype, side, texCoord, sx, y1, y2, colW)
    local sheet = getWallSheet(wtype)
    if not sheet then
        return false
    end
    if not sheet.frameWidth or not sheet.frameHeight or not sheet.frameCount then
        return false
    end
    local wallH = y2 - y1
    if wallH <= 0 then return false end

    local frameCount = sheet.frameCount
    if frameCount <= 0 then return false end
    local frameIndex = math.floor(texCoord * frameCount) + 1
    if frameIndex < 1 then frameIndex = 1 end
    if frameIndex > frameCount then frameIndex = frameCount end

    local width = colW or 4
    local scaleX = width / sheet.frameWidth
    local scaleY
    if isExpRenderer() and expScaleYLut and expScaleYLut[wallH] then
        scaleY = expScaleYLut[wallH]
    else
        scaleY = wallH / sheet.frameHeight
    end
    if scaleX <= 0 or scaleY <= 0 then return false end

    vmupro.sprite.drawFrameScaled(sheet, frameIndex, sx, y1, scaleX, scaleY, vmupro.sprite.kImageUnflipped)
    return true
end

expRayOffsets = expRayOffsets or {}
expTablesReady = expTablesReady or false
rayDirXFix = rayDirXFix or {}
rayDirYFix = rayDirYFix or {}
invRayDirXFix = invRayDirXFix or {}
invRayDirYFix = invRayDirYFix or {}
deltaDistXFix = deltaDistXFix or {}
deltaDistYFix = deltaDistYFix or {}
EXP_RAYCOLS = 24
EXP_COLW = 10
EXP_MAX_STEPS = 20
EXP_MAX_DIST = 80
EXP_RADIUS = 20
EXP_BUCKETS = 8
EXP_TEX_MAX_DIST = 90.0
EXP_VIEW_DIST = EXP_TEX_MAX_DIST
HYBRID_BLEND = 4.0
HYBRID_TEX_MAX_H = VIEWPORT_H
EXP_DIST_LUT_SIZE = 256
EXP_NEAR_DIST = EXP_NEAR_DIST or 28.0
expRayCache = expRayCache or {}
expRayCacheValid = expRayCacheValid or false
expRayPrevX = expRayPrevX or 0
expRayPrevY = expRayPrevY or 0
expRayPrevDir = expRayPrevDir or 0
expHeightLut = expHeightLut or {}
expScaleYLut = expScaleYLut or {}
expHeightLutReady = expHeightLutReady or false

local function ensureExpTables()
    if expTablesReady then return end
    for i = 0, 63 do
        local cx = cosTable[i] or 0
        local sy = sinTable[i] or 0
        rayDirXFix[i] = math.floor(cx * 256)
        rayDirYFix[i] = math.floor(sy * 256)
        if cx == 0 then
            invRayDirXFix[i] = 0x7FFFFFFF
        else
            invRayDirXFix[i] = math.floor((1 / cx) * 65536)
        end
        if sy == 0 then
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
        local half = renderCfg.fovSteps / 2
        for x = 0, rayCols - 1 do
            local t = x / (rayCols - 1)
            local off = -half + t * renderCfg.fovSteps
            offsets[x + 1] = math.floor(off + 0.5)
        end
    end
    expRayOffsets[key] = offsets
    return offsets
end

local function expCastRayFixed(rayDir)
    ensureExpTables()
    local posXFix = math.floor(px * 256)
    local posYFix = math.floor(py * 256)
    local mapX = posXFix >> 8
    local mapY = posYFix >> 8

    local dirXFix = rayDirXFix[rayDir] or 0
    local dirYFix = rayDirYFix[rayDir] or 0
    local stepX = (dirXFix < 0) and -1 or 1
    local stepY = (dirYFix < 0) and -1 or 1

    local deltaX = deltaDistXFix[rayDir] or 0x7FFFFFFF
    local deltaY = deltaDistYFix[rayDir] or 0x7FFFFFFF

    local nextXFix = ((mapX + (stepX > 0 and 1 or 0)) << 8)
    local nextYFix = ((mapY + (stepY > 0 and 1 or 0)) << 8)
    local distToNextX = nextXFix - posXFix
    local distToNextY = nextYFix - posYFix
    if distToNextX < 0 then distToNextX = -distToNextX end
    if distToNextY < 0 then distToNextY = -distToNextY end

    local sideDistX = (distToNextX * deltaX) >> 8
    local sideDistY = (distToNextY * deltaY) >> 8

    local side = 0
    local wtype = 0
    local maxSteps = EXP_MAX_STEPS or 8
    for _ = 0, maxSteps do
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
            return 16, 1, 0, 0
        end
        wtype = map[mapY + 1][mapX + 1]
        if wtype > 0 then
            break
        end
    end
    if wtype <= 0 then
        return 16, 1, 0, 0
    end

    local perpFix
    if side == 0 then
        local numFix = ((mapX << 8) - posXFix + ((stepX == -1) and 256 or 0))
        perpFix = (numFix * (invRayDirXFix[rayDir] or 0)) >> 8
    else
        local numFix = ((mapY << 8) - posYFix + ((stepY == -1) and 256 or 0))
        perpFix = (numFix * (invRayDirYFix[rayDir] or 0)) >> 8
    end
    if perpFix < 1 then perpFix = 1 end

    local texFix
    if side == 0 then
        local texCalc = (posYFix + ((perpFix * dirYFix) >> 16))
        texFix = texCalc & 0xFF
    else
        local texCalc = (posXFix + ((perpFix * dirXFix) >> 16))
        texFix = texCalc & 0xFF
    end
    local texCoord = texFix / 256
    local dist = perpFix / 65536
    return dist, wtype, side, texCoord
end

local getWallSprite
local expItems = {}
local expBuckets = {}
local expDepthBuf = {}
for i = 1, (EXP_BUCKETS or 8) do
    expBuckets[i] = {}
end

local function renderWallsExperimental(minDist)
    if not map then return end
    if not DEBUG_DISABLE_WALL_TEXTURE and (not wallStone or not wallBrick) and not wallTextureLoadAttempted then
        loadWallTextures()
    end
    local nearMin = minDist or 0
    local maxDist = EXP_MAX_DIST or 16
    local viewDist = EXP_VIEW_DIST or maxDist
    local maxDistSq = maxDist * maxDist
    local radius = EXP_RADIUS or 8
    local radiusSq = radius * radius
    local dir = pdir % 64
    local cosDir = cosTable[dir]
    local sinDir = sinTable[dir]
    local fovRad = renderCfg.fovSteps * (renderCfg.twoPi / 64)
    local maxSx = math.tan(fovRad / 2)
    local wallScale = VIEWPORT_H - 20
    local bucketCount = EXP_BUCKETS or 8
    for i = 1, bucketCount do
        expBuckets[i] = {}
    end
    for x = 0, 239 do
        expDepthBuf[x] = nil
    end
    local bucketSpan = maxDist / bucketCount
    local minX = math.floor(px - radius)
    local maxX = math.floor(px + radius)
    local minY = math.floor(py - radius)
    local maxY = math.floor(py + radius)
    if minX < 0 then minX = 0 end
    if minY < 0 then minY = 0 end
    if maxX > 15 then maxX = 15 end
    if maxY > 15 then maxY = 15 end
    for my = minY, maxY do
        local row = map[my + 1]
        if row then
            for mx = minX, maxX do
                local wtype = row[mx + 1]
                if wtype and wtype > 0 then
                    local wx = mx + 0.5
                    local wy = my + 0.5
                    local dx = wx - px
                    local dy = wy - py
                    local distSq = dx * dx + dy * dy
                    if distSq <= radiusSq and distSq <= maxDistSq then
                        local relX = dx * sinDir - dy * cosDir
                        local relY = dx * cosDir + dy * sinDir
                        local projRelY = relY
                        if projRelY < 0.5 then projRelY = 0.5 end
                        if relY > 0.05 and relY >= nearMin and relY <= maxDist and relY <= viewDist then
                            local sx = relX / projRelY
                            if sx >= -maxSx and sx <= maxSx then
                                local b = math.floor(relY / bucketSpan) + 1
                                if b < 1 then b = 1 end
                                if b > bucketCount then b = bucketCount end
                                local bucket = expBuckets[b]
                                bucket[#bucket + 1] = {relY = relY, projRelY = projRelY, sx = sx, t = wtype}
                            end
                        end
                    end
                end
            end
        end
    end
    local tilesDrawn = 0
    local tileBudget = EXP_TILE_BUDGET or 300
    for b = bucketCount, 1, -1 do
        local bucket = expBuckets[b]
        for i = 1, #bucket do
            if tilesDrawn >= tileBudget then
                break
            end
            local it = bucket[i]
            local projRelY = it.projRelY or it.relY
            if projRelY < 0.5 then projRelY = 0.5 end
            local h = math.floor(wallScale / projRelY)
            if h > VIEWPORT_H then h = VIEWPORT_H end
            if h >= 2 then
                local y1 = HORIZON - math.floor(h / 2)
                local y2 = HORIZON + math.floor(h / 2)
                if y1 < 0 then y1 = 0 end
                if y2 > VIEWPORT_H then y2 = VIEWPORT_H end
                local screenX = math.floor(120 + it.sx * 120)
                if screenX == screenX and screenX >= -10000 and screenX <= 10000 then
                    local baseColor = getWallColor(it.t, 0)
                    local fogStart = FOG_START or (EXP_TEX_MAX_DIST or 5.0) - 1.0
                    local farWall = it.relY > (EXP_TEX_MAX_DIST or 5.0)
                    if farWall and it.relY >= 2.5 then
                        goto continue_exp_tile
                    end
                    tilesDrawn = tilesDrawn + 1
                    local halfW = math.floor(h / 2)
                    local x1 = screenX - halfW
                    local x2 = screenX + halfW
                    if x1 < 0 then x1 = 0 end
                    if x2 > 239 then x2 = 239 end

                    local needsDraw = false
                    for x = x1, x2 do
                        local prev = expDepthBuf[x]
                        if not prev or it.relY < prev then
                            needsDraw = true
                            break
                        end
                    end

                if needsDraw then
                    local fogOnly = (not DEBUG_DISABLE_FOG) and (it.relY > fogStart)
                    local nearForceTex = it.relY < 2.5
                    if DEBUG_DISABLE_WALL_TEXTURE or WALL_TEXTURE_MODE == "flat" or (fogOnly and not nearForceTex) then
                            local fogColor = DEBUG_DISABLE_FOG and baseColor or FOG_COLOR
                            for x = x1, x2 do
                                local prev = expDepthBuf[x]
                                if not prev or it.relY < prev then
                                    expDepthBuf[x] = it.relY
                                    vmupro.graphics.drawFillRect(x, y1, x, y2, fogColor)
                                end
                            end
                        else
                            for x = x1, x2 do
                                local prev = expDepthBuf[x]
                                if not prev or it.relY < prev then
                                    expDepthBuf[x] = it.relY
                                end
                            end
                            local sprite = getWallSprite(it.t)
                            if sprite and sprite.height then
                                local scale = safeDivide(h, sprite.height, "renderTilesExp")
                                if scale == scale and scale > 0.01 then
                                    if scale > 50 then scale = 50 end
                                    local drawX = math.floor(screenX - (sprite.width * scale) / 2)
                                    if safeScale(sprite, scale, scale, "renderTilesExp") then
                                        vmupro.sprite.drawScaled(sprite, drawX, y1, scale, scale, vmupro.sprite.kImageUnflipped)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            ::continue_exp_tile::
        end
    end
end

local function renderWallsExperimentalHybrid()
    -- Hybrid: far tiles + near classic rays
    local nearLimit = (EXP_NEAR_DIST or 8.0) + (HYBRID_BLEND or 0)
    renderWallsExperimental(nearLimit)

    local fovRad = renderCfg.fovSteps * (renderCfg.twoPi / 64)
    local playerAngle = (pdir % 64) * (renderCfg.twoPi / 64)
    local playerCos = math.cos(playerAngle)
    local playerSin = math.sin(playerAngle)
    local baseAngle = playerAngle - (fovRad / 2)
    local rayCols = 60
    local colW = 4
    local rayStep = fovRad / rayCols
    local stepCos = math.cos(rayStep)
    local stepSin = math.sin(rayStep)
    local rayCos = math.cos(baseAngle)
    local raySin = math.sin(baseAngle)

    for x = 0, rayCols - 1 do
        local dist, wtype, side, texCoord = castRay(rayCos, raySin)
        local fixedDist = dist * (rayCos * playerCos + raySin * playerSin)
        if fixedDist < 0.9 then fixedDist = 0.9 end
        if fixedDist <= nearLimit then
            local wallScale = VIEWPORT_H - 20
            local h = math.floor(wallScale / fixedDist)
            if h > VIEWPORT_H then h = VIEWPORT_H end
            local y1 = HORIZON - math.floor(h / 2)
            local y2 = HORIZON + math.floor(h / 2)
            if y1 < 0 then y1 = 0 end
            if y2 > VIEWPORT_H then y2 = VIEWPORT_H end

            local farWall = fixedDist > (WALL_TEX_MAX_DIST or 6.0)
            local fogCutoff = FOG_TEX_CUTOFF or 3.5
            local fogTextureSkip = (not DEBUG_DISABLE_FOG) and (fixedDist > fogCutoff)
            local sx = x * colW
            local nearForce = fixedDist < (TEX_NEAR_FORCE_DIST or 1.5)
            local wantTex = (WALL_TEXTURE_MODE == "proper"
                and not DEBUG_DISABLE_WALL_TEXTURE
                and (nearForce or (not farWall and not fogTextureSkip and h < (HYBRID_TEX_MAX_H or (VIEWPORT_H - 8)))))
            if not wantTex then
                if isExpRenderer() then
                    if not DEBUG_DISABLE_FOG and fixedDist > (FOG_START or 2.5) then
                        vmupro.graphics.drawFillRect(sx, y1, sx + colW, y2, FOG_COLOR)
                    end
                else
                    local baseColor = getWallColor(wtype, side)
                    if not DEBUG_DISABLE_FOG then
                        baseColor = fogBlend(baseColor, fixedDist)
                    end
                    vmupro.graphics.drawFillRect(sx, y1, sx + colW, y2, baseColor)
                end
            else
                local baseColor = getWallColor(wtype, side)
                if not DEBUG_DISABLE_FOG then
                    baseColor = fogBlend(baseColor, fixedDist)
                end
                vmupro.graphics.drawFillRect(sx, y1, sx + colW, y2, baseColor)
                local useTex = texCoord or 0
                if useTex < 0 then useTex = 0 end
                if useTex > 0.999 then useTex = 0.999 end
                if side == 0 and rayCos > 0 then
                    useTex = 1.0 - useTex
                elseif side == 1 and raySin < 0 then
                    useTex = 1.0 - useTex
                end
                local drew = drawWallTextureColumn(wtype, side, useTex, sx, y1, y2, colW)
                if not drew then
                    drawWallTexture(wtype, side, sx, y1, y2)
                end
            end
        end
        local newCos = rayCos * stepCos - raySin * stepSin
        local newSin = raySin * stepCos + rayCos * stepSin
        rayCos, raySin = newCos, newSin
    end
end

getWallSprite = function(wtype)
    if wtype == 1 or wtype == 6 then
        return wallStone
    elseif wtype == 2 then
        return wallBrick
    elseif wtype == 3 then
        return wallMoss
    elseif wtype == 4 then
        return wallMetal
    elseif wtype == 5 then
        return wallWood
    end
    return nil
end

local function renderWallQuads()
    if not wallTiles then return end
    wallQuadLog("WQ render start tiles=" .. tostring(#wallTiles) .. " px=" .. tostring(px) .. " py=" .. tostring(py))
    if not wallStone or not wallStone.width then
        wallQuadLog("WQ wallStone missing or invalid")
    end
    if not wallBrick or not wallBrick.width then
        wallQuadLog("WQ wallBrick missing or invalid")
    end
    if not wallMoss or not wallMoss.width then
        wallQuadLog("WQ wallMoss missing or invalid")
    end
    if not wallMetal or not wallMetal.width then
        wallQuadLog("WQ wallMetal missing or invalid")
    end
    if not wallWood or not wallWood.width then
        wallQuadLog("WQ wallWood missing or invalid")
    end
    local order = {}
    for i = 1, #wallTiles do
        local w = wallTiles[i]
        local dx = w.x - px
        local dy = w.y - py
        local dist = math.sqrt(dx * dx + dy * dy)
        order[i] = {idx = i, dist = dist, dx = dx, dy = dy}
    end
    for i = 1, #order - 1 do
        for j = 1, #order - i do
            if order[j].dist < order[j + 1].dist then
                order[j], order[j + 1] = order[j + 1], order[j]
            end
        end
    end

    for i = 1, #order do
        local entry = order[i]
        if entry.dist > 0.3 and entry.dist < 12 then
            local angle = safeAtan2(entry.dy, entry.dx)
            local dirIdx = math.floor(angle * 64 / 6.28318) % 64
            local viewDiff = (dirIdx - pdir) % 64
            if viewDiff > 32 then viewDiff = viewDiff - 64 end
            if viewDiff >= -6 and viewDiff <= 6 then
                local screenX = 120 + viewDiff * 20
                local h = math.floor(200 / entry.dist)
                if h > 240 then h = 240 end
                if h < 6 then goto continue_quad end
                local y1 = HORIZON - math.floor(h / 2)
                if y1 < 0 then y1 = 0 end

                local wtile = wallTiles[entry.idx]
                local sprite = getWallSprite(wtile.t)
                if not sprite then
                    wallQuadLog("WQ missing sprite for type " .. tostring(wtile.t))
                end
                if sprite and sprite.height then
                    local scale = safeDivide(h, sprite.height, "renderWallQuad")
                    local drawX = screenX - math.floor((sprite.width * scale) / 2)
                    if safeScale(sprite, scale, scale, "renderWallQuad") then
                        vmupro.sprite.drawScaled(sprite, drawX, y1, scale, scale, vmupro.sprite.kImageUnflipped)
                    end
                end
            end
        end
        ::continue_quad::
    end
end

function castRay(dx, dy)
    if dx == 0 and dy == 0 then
        return 16, 1, 0, 0
    end

    local mapX = math.floor(px)
    local mapY = math.floor(py)

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
    local maxSteps = 64
    local wtype = 1
    for _ = 1, maxSteps do
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
        return 16, 1, 0, 0
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

    return perpWallDist, wtype, side, texCoord
end

local function isVisible(tx, ty, cache)
    local useCache = cache and (not isExpRenderer())
    if useCache then
        local lastFrame = cache._visFrame or -1000
        if frameCount - lastFrame < 14 then
            return cache._visValue == true
        end
    end
    local dx, dy = tx - px, ty - py
    local dist = math.sqrt(dx * dx + dy * dy)
    local maxDist = SPRITE_VIS_DIST or 6
    if isExpRenderer() then
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
    if isExpRenderer() then
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
    local step = isExpRenderer() and 0.1 or 0.25
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
                vmupro.text.setFont(vmupro.text.FONT_TINY_6x8)
                vmupro.graphics.drawText(info, 5, 220, COLOR_WHITE, COLOR_BLACK)
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

local function renderGameFrame()
    -- Game rendering
    vmupro.graphics.clear(COLOR_CEILING)
    vmupro.graphics.drawFillRect(0, HORIZON, 240, VIEWPORT_H, COLOR_FLOOR)
    vmupro.graphics.drawFillRect(0, VIEWPORT_H, 240, 240, COLOR_BLACK)

    -- Cheap horizon dressing: 3 sky bands + horizon line
    vmupro.graphics.drawFillRect(0, 0, 240, 39, COLOR_BLACK)
    vmupro.graphics.drawFillRect(0, 40, 240, 79, COLOR_DARK_GRAY)
    vmupro.graphics.drawFillRect(0, 80, 240, HORIZON - 2, COLOR_GRAY)
    vmupro.graphics.drawLine(0, HORIZON - 1, 239, HORIZON - 1, COLOR_BLACK)
    -- Sparse fixed stars (very cheap)
    vmupro.graphics.drawFillRect(18, 10, 18, 10, COLOR_WHITE)
    vmupro.graphics.drawFillRect(92, 22, 92, 22, COLOR_WHITE)
    vmupro.graphics.drawFillRect(140, 14, 140, 14, COLOR_WHITE)
    vmupro.graphics.drawFillRect(210, 30, 210, 30, COLOR_WHITE)
    vmupro.graphics.drawFillRect(60, 48, 60, 48, COLOR_WHITE)
    vmupro.graphics.drawFillRect(170, 52, 170, 52, COLOR_WHITE)
    vmupro.graphics.drawFillRect(24, 66, 24, 66, COLOR_WHITE)
    vmupro.graphics.drawFillRect(118, 70, 118, 70, COLOR_WHITE)


    if WALL_TEXTURE_MODE == "lazy_quads" then
        renderWallQuads()
    else
        if RENDERER_MODE == "exp_pure" then
            renderWallsExperimental()
        elseif RENDERER_MODE == "exp_hybrid" then
            renderWallsExperimentalHybrid()
        else
            local fovRad = renderCfg.fovSteps * (renderCfg.twoPi / 64)
            local playerAngle = (pdir % 64) * (renderCfg.twoPi / 64)
            local playerCos = math.cos(playerAngle)
            local playerSin = math.sin(playerAngle)
            local baseAngle = playerAngle - (fovRad / 2)
            local rayCols = renderCfg.rayCols
            local colW = renderCfg.colW
            if LOW_RES_WALLS then
                if LOW_RES_MODE == "fast" then
                    rayCols = 32
                    colW = 8
                else
                    rayCols = 48
                    colW = 5
                end
            end
            local rayStep = fovRad / rayCols
            local stepCos = math.cos(rayStep)
            local stepSin = math.sin(rayStep)
            local rayCos = math.cos(baseAngle)
            local raySin = math.sin(baseAngle)
            for x = 0, rayCols - 1 do
                local dist, wtype, side, texCoord = castRay(rayCos, raySin)
                local fixedDist = dist * (rayCos * playerCos + raySin * playerSin)
                if fixedDist < 0.4 then fixedDist = 0.4 end
                local viewDist = EXP_VIEW_DIST or 8.0
                local texView = EXP_TEX_MAX_DIST or viewDist
                if RENDERER_MODE == "exp_hybrid" then
                    viewDist = texView
                end
                if fixedDist > viewDist then
                    local nextCos = (rayCos * stepCos) - (raySin * stepSin)
                    raySin = (raySin * stepCos) + (rayCos * stepSin)
                    rayCos = nextCos
                    goto continue_ray
                end
                local wallScale = VIEWPORT_H - 20
                local h = math.floor(wallScale / fixedDist)
                if h > VIEWPORT_H then h = VIEWPORT_H end
                local y1 = HORIZON - math.floor(h / 2)
                local y2 = HORIZON + math.floor(h / 2)
                if y1 < 0 then y1 = 0 end
                if y2 > VIEWPORT_H then y2 = VIEWPORT_H end

                local baseColor = getWallColor(wtype, side)
                if not DEBUG_DISABLE_FOG then
                    baseColor = fogBlend(baseColor, fixedDist)
                end
                local sx = x * colW

                -- Draw base wall color
                vmupro.graphics.drawFillRect(sx, y1, sx + colW, y2, baseColor)
                if fixedDist < 1.0 and not DEBUG_DISABLE_WALL_TEXTURE then
                    drawWallTexture(wtype, side, sx, y1, y2)
                    goto continue_ray
                end
                local skipTex = renderCfg.skipOddTex and ((x % 2) == 1)
                if LOW_RES_WALLS and LOW_RES_MODE == "fast" and (x % 2) == 1 then
                    skipTex = true
                end
                local nearForceTex = fixedDist < 1.0
                local farWall = fixedDist > texView
                local fogCutoff = FOG_TEX_CUTOFF or 3.5
                local fogTextureSkip = (not DEBUG_DISABLE_FOG) and (fixedDist > fogCutoff)
                if nearForceTex then
                    farWall = false
                    fogTextureSkip = false
                    skipTex = false
                end
                if RENDERER_MODE == "exp_hybrid" and viewDist == texView then
                    skipTex = false
                end
                if WALL_TEXTURE_MODE == "proper" and not DEBUG_DISABLE_WALL_TEXTURE and not skipTex and not farWall and not fogTextureSkip then
                    local useTex = texCoord or 0
                    if useTex < 0 then useTex = 0 end
                    if useTex > 0.999 then useTex = 0.999 end
                    -- Flip texture coordinate based on ray direction and hit side
                    if side == 0 and rayCos > 0 then
                        useTex = 1.0 - useTex
                    elseif side == 1 and raySin < 0 then
                        useTex = 1.0 - useTex
                    end
                    local drew = drawWallTextureColumn(wtype, side, useTex, sx, y1, y2, colW)
                    if not drew then
                        -- Fallback to legacy overlay if no sheet is available
                        drawWallTexture(wtype, side, sx, y1, y2)
                    end
                elseif WALL_TEXTURE_MODE == "flat" then
                    -- Flat color only
                else
                    if not DEBUG_DISABLE_WALL_TEXTURE then
                        -- Legacy (lazy) texture overlay
                        drawWallTexture(wtype, side, sx, y1, y2)
                    end
                end

                -- Increment ray direction by fixed step (rotation)
                local nextCos = (rayCos * stepCos) - (raySin * stepSin)
                raySin = (raySin * stepCos) + (rayCos * stepSin)
                rayCos = nextCos
                ::continue_ray::
            end
        end
    end

    if not DEBUG_SKIP_SPRITES then
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

    if SHOW_MINIMAP then
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
    if isAttacking > 0 then
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
    if blockAnim > 0 then
        local frameIndex = blockAnim
        if frameIndex < 1 then frameIndex = 1 end
        if frameIndex > #shieldRaise then frameIndex = #shieldRaise end
        local sprite = shieldRaise[frameIndex]
        if sprite then
            vmupro.sprite.draw(sprite, 0, 0, vmupro.sprite.kImageUnflipped)
        end
    end

    -- Draw menu
    if showMenu then
        if inOptionsMenu then
            -- Options submenu
            vmupro.graphics.drawFillRect(40, 30, 200, 230, COLOR_BLACK)
            vmupro.graphics.drawFillRect(45, 35, 195, 225, COLOR_DARK_GRAY)
            -- Title bar
            vmupro.graphics.drawFillRect(50, 40, 190, 60, COLOR_MAROON)
            vmupro.text.setFont(vmupro.text.FONT_SMALL)
            vmupro.graphics.drawText("OPTIONS", 86, 44, COLOR_WHITE, COLOR_MAROON)
            -- Options items
            local soundText = "SOUND: " .. (soundEnabled and "ON" or "OFF")
            local healthText = "HEALTH%: " .. (showHealthPercent and "ON" or "OFF")
            local enemiesText = "ENEMIES: " .. (DEBUG_DISABLE_ENEMIES and "OFF" or "ON")
            local propsText = "PROPS: " .. (DEBUG_DISABLE_PROPS and "OFF" or "ON")
            local texturesText = "TEXTURES: " .. (DEBUG_DISABLE_WALL_TEXTURE and "OFF" or "ON")
            local fpsText = "FPS: " .. (showFpsOverlay and "ON" or "OFF")
            local resText = "RES: " .. (LOW_RES_MODE == "fast" and "FAST" or "QUALITY")
            local minimapText = "MINIMAP: " .. (SHOW_MINIMAP and "ON" or "OFF")
            local renderLabel = "CLASSIC"
            if RENDERER_MODE == "exp_hybrid" then
                renderLabel = "EXP-H"
            elseif RENDERER_MODE == "exp_pure" then
                renderLabel = "EXP-P"
            end
            local renderText = "RENDER: " .. renderLabel
            local optItems = {soundText, healthText, enemiesText, propsText, texturesText, fpsText, resText, minimapText, renderText, "BACK"}
            for i, item in ipairs(optItems) do
                local y = 70 + (i - 1) * 15
                local bgColor = COLOR_DARK_GRAY
                local textColor = COLOR_GRAY
                if i == optionsSelection then
                    vmupro.graphics.drawFillRect(50, y, 190, y + 14, COLOR_MAROON)
                    bgColor = COLOR_MAROON
                    textColor = COLOR_WHITE
                end
                vmupro.text.setFont(vmupro.text.FONT_SMALL)
                vmupro.graphics.drawText(item, 56, y + 1, textColor, bgColor)
            end
        else
            -- Main pause menu
            vmupro.graphics.drawFillRect(50, 60, 190, 225, COLOR_BLACK)
            vmupro.graphics.drawFillRect(55, 65, 185, 220, COLOR_DARK_GRAY)
            -- Title bar
            vmupro.graphics.drawFillRect(60, 70, 180, 92, COLOR_MAROON)
            vmupro.text.setFont(vmupro.text.FONT_SMALL)
            vmupro.graphics.drawText("PAUSED", 88, 75, COLOR_WHITE, COLOR_MAROON)
            -- Menu items
            local items = {"RESUME", "OPTIONS", "RESTART", "MENU", "QUIT"}
            for i, item in ipairs(items) do
                local y = 95 + (i - 1) * 20
                local bgColor = COLOR_DARK_GRAY
                local textColor = COLOR_GRAY
                if i == menuSelection then
                    vmupro.graphics.drawFillRect(60, y, 180, y + 18, COLOR_MAROON)
                    bgColor = COLOR_MAROON
                    textColor = COLOR_WHITE
                end
                vmupro.text.setFont(vmupro.text.FONT_SMALL)
                vmupro.graphics.drawText(item, 80, y + 2, textColor, bgColor)
            end
        end
    end

    -- Draw health UI (potion with liquid)
    drawHealthUI()

    -- Draw current level indicator
                vmupro.text.setFont(vmupro.text.FONT_SMALL)
                vmupro.graphics.drawText(getLevelLabel(currentLevel), 6, 228, COLOR_WHITE, COLOR_BLACK)
                if showFpsOverlay and lastFps and lastFps > 0 then
                    local fpsText = string.format("FPS %.1f", lastFps)
                    vmupro.graphics.drawText(fpsText, 6, 214, COLOR_WHITE, COLOR_BLACK)
                end

    if levelBannerTimer > 0 then
                    local bannerText = "LEVEL " .. getLevelLabel(currentLevel)
        local textColor = COLOR_WHITE
        if levelBannerTimer < 50 then
            textColor = COLOR_DARK_GRAY
        elseif levelBannerTimer < 100 then
            textColor = COLOR_LIGHT_GRAY
        end
        vmupro.text.setFont(vmupro.text.FONT_SMALL)
        vmupro.graphics.drawText(bannerText, 170, 5, textColor, COLOR_BLACK)
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


function AppMain()
    if vmupro.system and vmupro.system.setLogLevel then
        vmupro.system.setLogLevel(vmupro.system.LOG_DEBUG)
    end
    logBoot(vmupro.system.LOG_ERROR, "A AppMain enter")
    logBoot(vmupro.system.LOG_ERROR, "drawTitleScreen local=" .. tostring(drawTitleScreen))
    logBoot(vmupro.system.LOG_ERROR, "drawTitleScreen global=" .. tostring(_G and _G.drawTitleScreen))
    if drawTitleScreenImpl then
        drawTitleScreen = drawTitleScreenImpl
        logBoot(vmupro.system.LOG_ERROR, "drawTitleScreen rebound in AppMain")
    end
    enterTitle()
    logBoot(vmupro.system.LOG_ERROR, "B enterTitle done")
    local bootLoopLogged = false
    local bootLogEvery = 300
    local fpsWindowStartUs = (vmupro.system and vmupro.system.getTimeUs and vmupro.system.getTimeUs()) or 0
    local fpsFrames = 0

    local targetFrameUs = 33333
    while app_running do
        local frameStartUs = (vmupro.system and vmupro.system.getTimeUs and vmupro.system.getTimeUs()) or 0
        if not bootLoopLogged then
            bootLoopLogged = true
            logBoot(vmupro.system.LOG_ERROR, "B1 loop start")
        end
        vmupro.input.read()
        if enableBootLogs and gameState == STATE_TITLE and bootLoopLogged and (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2 after input.read")
        end
        frameCount = frameCount + 1
        if enableBootLogs and gameState == STATE_TITLE and (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2.1 after frameCount")
        end
        fpsFrames = fpsFrames + 1
        if gameState == STATE_PLAYING and (frameCount % 120) == 0 then
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
                logPerf(string.format("FPS %.1f", fps))
                fpsWindowStartUs = nowUs
                fpsFrames = 0
            end
        end


        -- Update audio
        if audioSystemActive then
            vmupro.sound.update()
        end
        if enableBootLogs and gameState == STATE_TITLE and (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2.2 after audio update")
        end

        if gameState == STATE_TITLE then
            updateTitleMusic()
        end

        -- Only run game logic when playing (not on title screen)
            if gameState == STATE_PLAYING then
            if levelBannerTimer > 0 then
                levelBannerTimer = levelBannerTimer - 1
            end
            -- Decrement attack animation
            if isAttacking > 0 then
                isAttacking = isAttacking - 1
            end

            -- Update soldier positions and animations
            updateSoldiers()

            -- Update death animations regardless of effects toggle
            updateDeathAnimations()
            if not DEBUG_DISABLE_EFFECTS then
                -- Update blood effects
                updateBloodEffects()
            end

            -- Check for health pickups
            checkHealthPickups()
        end
        if enableBootLogs and gameState == STATE_TITLE and (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2.3 after playing block")
        end

        if gameState == STATE_LOADING then
            loadingTimer = loadingTimer - 1
            if loadingTimer <= 0 then
                if pendingLevelStart then
                    startLevel(pendingLevelStart)
                    pendingLevelStart = nil
                else
                    gameState = STATE_TITLE
                end
            end
        end
        if enableBootLogs and gameState == STATE_TITLE and (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2.4 after loading block")
        end

        if enableBootLogs and gameState == STATE_TITLE and (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2.5 before title/menu pcall")
        end
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
                if titleInOptions then
                    if titleInDebug then
                        if vmupro.input.pressed(vmupro.input.UP) then
                            titleDebugSelection = titleDebugSelection - 1
                        if titleDebugSelection < 1 then titleDebugSelection = 10 end
                        end
                        if vmupro.input.pressed(vmupro.input.DOWN) then
                            titleDebugSelection = titleDebugSelection + 1
                        if titleDebugSelection > 10 then titleDebugSelection = 1 end
                        end
                        if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                            if titleDebugSelection == 1 then
                                enableBootLogs = not enableBootLogs
                                DEBUG_WALL_QUADS_LOG = enableBootLogs
                                if enableBootLogs then
                                    wallQuadLogCount = 0
                                end
                            elseif titleDebugSelection == 2 then
                                DEBUG_DISABLE_ENEMIES = not DEBUG_DISABLE_ENEMIES
                                spriteOrderCache = {}
                                spriteOrderCacheFrame = -999
                            elseif titleDebugSelection == 3 then
                                DEBUG_DISABLE_PROPS = not DEBUG_DISABLE_PROPS
                                spriteOrderCache = {}
                                spriteOrderCacheFrame = -999
                            elseif titleDebugSelection == 4 then
                                DEBUG_DISABLE_WALL_TEXTURE = not DEBUG_DISABLE_WALL_TEXTURE
                                if DEBUG_DISABLE_WALL_TEXTURE then
                                    unloadWallTextures()
                                else
                                    loadWallTextures()
                                end
                            elseif titleDebugSelection == 5 then
                                showFpsOverlay = not showFpsOverlay
                            elseif titleDebugSelection == 6 then
                                if LOW_RES_MODE == "fast" then
                                    LOW_RES_MODE = "quality"
                                else
                                    LOW_RES_MODE = "fast"
                                end
                            elseif titleDebugSelection == 7 then
                                SHOW_MINIMAP = not SHOW_MINIMAP
                            elseif titleDebugSelection == 8 then
                                if RENDERER_MODE == "classic" then
                                    RENDERER_MODE = "exp_hybrid"
                                elseif RENDERER_MODE == "exp_hybrid" then
                                    RENDERER_MODE = "exp_pure"
                                else
                                    RENDERER_MODE = "classic"
                                end
                            elseif titleDebugSelection == 9 then
                                if FPS_TARGET_MODE == "uncapped" then
                                    FPS_TARGET_MODE = "60"
                                elseif FPS_TARGET_MODE == "60" then
                                    FPS_TARGET_MODE = "30"
                                else
                                    FPS_TARGET_MODE = "uncapped"
                                end
                            elseif titleDebugSelection == 10 then
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
                                    stopTitleMusic()
                                end
                            elseif titleOptionsSelection == 3 then
                                showHealthPercent = not showHealthPercent
                            elseif titleOptionsSelection == 4 then
                                if RENDERER_MODE == "classic" then
                                    RENDERER_MODE = "exp_hybrid"
                                elseif RENDERER_MODE == "exp_hybrid" then
                                    RENDERER_MODE = "exp_pure"
                                else
                                    RENDERER_MODE = "classic"
                                end
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
                    or prevRendererMode ~= RENDERER_MODE then
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
                if winBannerTimer > 0 then
                    winBannerTimer = winBannerTimer - 1
                end
                if winCooldown > 0 then
                    winCooldown = winCooldown - 1
                elseif vmupro.input.pressed(vmupro.input.A) then
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
                    if vmupro.input.pressed(vmupro.input.UP) then
                        optionsSelection = optionsSelection - 1
                        if optionsSelection < 1 then optionsSelection = 10 end
                    end
                    if vmupro.input.pressed(vmupro.input.DOWN) then
                        optionsSelection = optionsSelection + 1
                        if optionsSelection > 10 then optionsSelection = 1 end
                    end
                    if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                        if optionsSelection == 1 then
                            soundEnabled = not soundEnabled  -- Toggle sound
                            if soundEnabled then
                                startTitleMusic()
                            else
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
                            if RENDERER_MODE == "classic" then
                                RENDERER_MODE = "exp_hybrid"
                            elseif RENDERER_MODE == "exp_hybrid" then
                                RENDERER_MODE = "exp_pure"
                            else
                                RENDERER_MODE = "classic"
                            end
                        elseif optionsSelection == 10 then
                            inOptionsMenu = false  -- Back to main menu
                        end
                    end
                    if vmupro.input.pressed(vmupro.input.POWER) or vmupro.input.pressed(vmupro.input.B) then
                        inOptionsMenu = false  -- Back to main menu
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

            -- LEFT/RIGHT: Turn (held for continuous turning)
            if vmupro.input.held(vmupro.input.LEFT) then
                pdir = pdir - 1
                if pdir < 0 then pdir = pdir + 64 end
            end
            if vmupro.input.held(vmupro.input.RIGHT) then
                pdir = pdir + 1
                if pdir >= 64 then pdir = pdir - 64 end
            end

            local idx = pdir % 64
            local dx = cosTable[idx] * 0.15
            local dy = sinTable[idx] * 0.15
            -- Strafe direction (perpendicular to facing)
            local strafe_idx = (pdir + 16) % 64  -- 90 degrees right
            local sdx = cosTable[strafe_idx] * 0.10
            local sdy = sinTable[strafe_idx] * 0.10

            -- Check if MODE is held (modifier key)
            local modeHeld = vmupro.input.held(vmupro.input.MODE)

            if modeHeld then
                -- MODE + UP: Attack
                if vmupro.input.pressed(vmupro.input.UP) and isAttacking == 0 then
                    local attackFrames = #swordAttack
                    attackTotalFrames = 9
                    if attackFrames == 0 then
                        attackTotalFrames = 10
                    end
                    isAttacking = attackTotalFrames

                    -- Check for enemies in attack range and damage them
                    local hitSomething = false
                    for i = 1, #sprites do
                        local s = sprites[i]
                        if s.t == 5 and s.alive then
                            local dx = s.x - px
                            local dy = s.y - py
                            local dist = math.sqrt(dx * dx + dy * dy)
                            if dist < PLAYER_ATTACK_RANGE then
                                -- Hit the enemy
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

                -- MODE + DOWN: Block (hold)
                isBlocking = vmupro.input.held(vmupro.input.DOWN)
            else
                -- Normal movement
                isBlocking = false

                -- UP: Move forward (held for continuous movement)
                if vmupro.input.held(vmupro.input.UP) then
                    local nx, ny = px + dx, py + dy
                    if canMove(nx, py) then
                        px = nx
                    end
                    if canMove(px, ny) then
                        py = ny
                    end
                end

                -- DOWN: Move backward (held for continuous movement)
                if vmupro.input.held(vmupro.input.DOWN) then
                    local nx, ny = px - dx, py - dy
                    if canMove(nx, py) then
                        px = nx
                    end
                    if canMove(px, ny) then
                        py = ny
                    end
                end

                -- MODE (tap without holding): Interact/Action
                if vmupro.input.pressed(vmupro.input.MODE) then
                    -- Check for nearby interactable objects (doors, chests, etc.)
                    local checkX = px + dx * 1.5
                    local checkY = py + dy * 1.5
                    local mx, my = math.floor(checkX), math.floor(checkY)
                    if mx >= 0 and mx < 16 and my >= 0 and my < 16 then
                        local tile = map[my + 1][mx + 1]
                        -- Open doors (type 4 = metal door, type 5 = wood door)
                        if tile == 4 or tile == 5 then
                            map[my + 1][mx + 1] = 0  -- Open the door
                        end
                    end
                end
            end

            -- Update block animation (raise/lower)
            if isBlocking then
                if blockAnim < (BLOCK_ANIM_FRAMES or 8) then
                    blockAnim = blockAnim + 1
                end
            else
                if blockAnim > 0 then
                    blockAnim = blockAnim - 1
                end
            end

            -- A: Strafe left (held for continuous movement)
            if vmupro.input.held(vmupro.input.A) then
                local nx, ny = px - sdx, py - sdy
                if canMove(nx, py) then
                    px = nx
                end
                if canMove(px, ny) then
                    py = ny
                end
            end

            -- B: Strafe right (held for continuous movement)
            if vmupro.input.held(vmupro.input.B) then
                local nx, ny = px + sdx, py + sdy
                if canMove(nx, py) then
                    px = nx
                end
                if canMove(px, ny) then
                    py = ny
                end
            end

            -- POWER: Menu
            if vmupro.input.pressed(vmupro.input.POWER) then
                showMenu = true
                menuSelection = 1
            end
            end
        end)
        if (frameCount % bootLogEvery == 0) then
            logBoot(vmupro.system.LOG_ERROR, "B2.7 after title/menu pcall ok=" .. tostring(okTitle))
        end
        if not okTitle then
            logBoot(vmupro.system.LOG_ERROR, "title/menu error: " .. tostring(errTitle))
            quitApp("title/menu error: " .. tostring(errTitle))
        end

        -- Render based on game state
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
            vmupro.text.setFont(vmupro.text.FONT_SMALL)
            vmupro.graphics.drawText("LOADING", 95, 90, COLOR_WHITE, COLOR_BLACK)
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

        ::render_only::
        vmupro.graphics.refresh()
        if gameState == STATE_TITLE then
            targetFrameUs = 16667
        else
            if FPS_TARGET_MODE == "uncapped" then
                targetFrameUs = 0
            elseif FPS_TARGET_MODE == "60" then
                targetFrameUs = 16667
            else
                targetFrameUs = 33333
            end
        end
        if vmupro.system and vmupro.system.getTimeUs and vmupro.system.delayMs then
            local frameEndUs = vmupro.system.getTimeUs()
            if frameStartUs > 0 and frameEndUs > frameStartUs then
                local elapsedUs = frameEndUs - frameStartUs
                local remainingUs = targetFrameUs - elapsedUs
                if remainingUs > 0 then
                    vmupro.system.delayMs(math.floor(remainingUs / 1000))
                end
            end
        end
    end

    -- Cleanup assets
    unloadLevelAudio()
    unloadLevelSprites()
    unloadMenuSprites()

    return 0
end
