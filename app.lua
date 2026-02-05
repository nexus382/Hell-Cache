-- VMU Pro Dungeon Raycaster
-- Castle dungeon with detailed sprites

import "api/system"
import "api/display"
import "api/input"
import "api/sprites"
import "api/audio"
import "api/text"

print("[BOOT] app.lua loaded")

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
local COLOR_BLACK = 0x0000
local COLOR_WHITE = 0xFFFF
local COLOR_RED = 0x00F8
local COLOR_YELLOW = 0xE0FF
local COLOR_ORANGE = 0x20FC
local COLOR_SKIN = 0xB6BD
local COLOR_SKIN_DARK = 0x9294
local COLOR_BROWN = 0x4051
local COLOR_DARK_BROWN = 0x2028
local COLOR_LIGHT_BROWN = 0x6079
local COLOR_GRAY = 0x8C73
local COLOR_DARK_GRAY = 0x4A52
local COLOR_LIGHT_GRAY = 0xCE7B
local COLOR_BLUE = 0x1F00
local COLOR_DARK_BLUE = 0x0E00
local COLOR_LIGHT_BLUE = 0x1F42
local COLOR_GREEN = 0xE007
local COLOR_MAROON = 0x0060
local COLOR_DARK_MAROON = 0x0040
local COLOR_LIGHT_MAROON = 0x0861
local COLOR_SILVER = 0xF7BD
local COLOR_DARK_SILVER = 0xCE7B

-- Dungeon colors
local COLOR_FLOOR = 0x6931
local COLOR_CEILING = 0x2821

-- Wall colors
local COLOR_STONE_L = 0x8C73
local COLOR_STONE_D = 0x4A52
local COLOR_BRICK_L = 0x4062
local COLOR_BRICK_D = 0x0041
local COLOR_MOSS_L = 0x4444
local COLOR_MOSS_D = 0x2222
local COLOR_METAL_L = 0x1084
local COLOR_METAL_D = 0x0842
local COLOR_WOOD_L = 0x4051
local COLOR_WOOD_D = 0x2028

-- Base level data (used to build per-level instances)
local BASE_MAP = {
    {1,1,1,1,1,1,1,4,1,1,1,1,1,1,1,1},
    {1,0,0,0,6,0,1,0,0,0,6,0,0,0,0,1},
    {2,0,0,0,0,0,1,0,0,0,0,0,0,0,0,2},
    {1,0,0,0,0,0,3,0,0,0,0,0,0,0,0,1},
    {1,6,0,0,0,0,0,0,0,0,0,0,0,0,6,1},
    {1,0,0,0,0,0,3,0,0,0,0,0,0,0,0,1},
    {1,2,2,0,2,2,1,0,1,5,0,5,1,0,1,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {3,0,0,6,0,0,0,0,0,0,0,0,0,6,0,3},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {3,0,0,6,0,0,0,0,0,0,0,0,0,6,0,3},
    {1,2,2,0,2,2,5,0,0,0,0,0,2,0,2,1},
    {1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1},
    {1,0,6,0,6,0,1,0,0,0,0,0,0,6,0,1},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
}

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
    -- Warriors (red armor) - with movement data: tx,ty=target, anim=animation frame, hp=health
    {x=3.5, y=3.5, t=5, dir=32, tx=3.5, ty=3.5, anim=0, speed=0.02, hp=100, alive=true, startX=3.5, startY=3.5},
    {x=11.5, y=4.5, t=5, dir=48, tx=11.5, ty=4.5, anim=0, speed=0.02, hp=100, alive=true, startX=11.5, startY=4.5},
    {x=4.5, y=8.5, t=5, dir=0, tx=4.5, ty=8.5, anim=0, speed=0.02, hp=100, alive=true, startX=4.5, startY=8.5},
    {x=8.5, y=10.5, t=5, dir=16, tx=8.5, ty=10.5, anim=0, speed=0.02, hp=100, alive=true, startX=8.5, startY=10.5},
    {x=11.5, y=13.5, t=5, dir=32, tx=11.5, ty=13.5, anim=0, speed=0.02, hp=100, alive=true, startX=11.5, startY=13.5},
    -- Health vials (one per room area)
    {x=5.5, y=2.5, t=7, collected=false},   -- Top-left room
    {x=10.5, y=2.5, t=7, collected=false},  -- Top-right room
    {x=2.5, y=8.5, t=7, collected=false},   -- Left side
    {x=8.5, y=9.5, t=7, collected=false},   -- Central area
    {x=12.5, y=13.5, t=7, collected=false}, -- Bottom-right area
}

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
            {1,2,2,0,2,2,1,0,1,5,0,5,1,0,1,1},
            {1,0,0,0,0,0,0,1,1,1,0,0,0,0,0,1},
            {3,0,0,6,0,0,0,1,4,1,0,0,0,6,0,3},
            {1,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1},
            {1,0,0,0,0,0,0,1,5,1,0,0,0,0,0,1},
            {3,0,0,6,0,0,0,0,0,0,0,0,0,6,0,3},
            {1,2,2,0,2,2,5,0,0,0,0,0,2,0,2,1},
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
            -- Warriors (red armor)
            {x=3.5, y=3.5, t=5, dir=32, tx=3.5, ty=3.5, anim=0, speed=0.025, hp=120, alive=true, startX=3.5, startY=3.5},
            {x=11.5, y=4.5, t=5, dir=48, tx=11.5, ty=4.5, anim=0, speed=0.025, hp=120, alive=true, startX=11.5, startY=4.5},
            {x=4.5, y=8.5, t=5, dir=0, tx=4.5, ty=8.5, anim=0, speed=0.025, hp=120, alive=true, startX=4.5, startY=8.5},
            {x=8.5, y=10.5, t=5, dir=16, tx=8.5, ty=10.5, anim=0, speed=0.025, hp=120, alive=true, startX=8.5, startY=10.5},
            {x=11.5, y=13.5, t=5, dir=32, tx=11.5, ty=13.5, anim=0, speed=0.025, hp=120, alive=true, startX=11.5, startY=13.5},
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

local currentLevel = 1
local selectedLevel = 1
local MAX_LEVEL = #LEVELS
local map = nil
local sprites = nil
local wallTiles = nil

local sinTable = {}
local cosTable = {}
for i = 0, 63 do
    local angle = i * 6.28318 / 64
    sinTable[i] = math.sin(angle)
    cosTable[i] = math.cos(angle)
end

local px = 2.5
local py = 2.5
local pdir = 0
local app_running = true
local frameCount = 0
local HORIZON = 100  -- Eye level (lower value = looking more downward)

-- Game state
local isAttacking = 0      -- Attack animation frames remaining
local attackTotalFrames = 0 -- Total frames for current attack animation
local isBlocking = false   -- Currently blocking
local showMenu = false     -- Menu visible
local menuSelection = 1    -- Current menu selection
local inOptionsMenu = false -- Currently in options submenu
local optionsSelection = 1  -- Current options selection

-- Options settings
local soundEnabled = true   -- Sound on/off
local showHealthPercent = true  -- Health % display on/off

-- Sound effects
local swordSwooshSynth = nil
local audioInitialized = false

-- Enemy attack effects (list of active swipe effects)
local swipeEffects = {}  -- {x, y, angle, frame, maxFrames}

-- Attack constants
local DETECTION_RANGE = 4    -- How far soldier can see player
local ATTACK_RANGE = 1.0     -- Distance to attack (about 1 body length)
local ATTACK_COOLDOWN = 15   -- Frames between attacks (2 per second at 30fps)
local CHASE_SPEED_MULT = 3   -- Speed multiplier when chasing (sprint)

-- Player health system
local playerHealth = 100     -- Current health (0-100)
local MAX_HEALTH = 100
local DAMAGE_PER_HIT = 10
local potionSprite = nil
local titleSprite = nil
local wallStone = nil
local wallBrick = nil
local wallMoss = nil
local wallMetal = nil
local wallWood = nil
local USE_WALL_QUADS = true
local DEBUG_WALL_QUADS_LOG = true
local wallQuadLogCount = 0
local function wallQuadLog(msg)
    if DEBUG_WALL_QUADS_LOG and wallQuadLogCount < 30 then
        print(msg)
        wallQuadLogCount = wallQuadLogCount + 1
    end
end
local function renderLog(msg)
    if DEBUG_WALL_QUADS_LOG then
        print("[RENDER] " .. msg)
    end
end
local STATE_TITLE = 0
local STATE_PLAYING = 1
local STATE_GAME_OVER = 2
local STATE_WIN = 3
local STATE_LOADING = 4
local gameState = STATE_TITLE
local titleSelection = 1  -- 1=Start, 2=Options, 3=Exit
local titleInOptions = false
local titleOptionsSelection = 1
local gameOverSelection = 1  -- 1 = Restart, 2 = Menu, 3 = Quit
local winSelection = 1  -- 1 = Menu
local winCooldown = 0   -- Delay before accepting win screen input
local levelBannerTimer = 0
local levelBannerMax = 150
local winBannerTimer = 0
local winBannerMax = 75
local loadingTimer = 0
local loadingMax = 45
local pendingLevelStart = nil
local loadingLogCount = 0
local function loadingLog(msg)
    if loadingLogCount < 20 then
        print(msg)
        loadingLogCount = loadingLogCount + 1
    end
end

-- Debug controls (set to true for sprite testing)
local DEBUG_DISABLE_ENEMY_AGGRO = false  -- Enemies never chase/attack
local DEBUG_WALK_IN_PLACE = false       -- Enemies animate walk without moving
local DEBUG_FLIP_WALK_SIDES = false     -- Use left-walk sprites and flip for right side
local DEBUG_FORCE_GLOBAL_WALK = false   -- Drive walk frames from global frameCount
local DEBUG_FORCE_WALK_FRAMES = nil     -- Force 2-frame cycle while walk3 is under review
local DEBUG_FORCE_SIDE_VIEW = false     -- Always show side view (left/right) for testing
local DEBUG_FORCE_VIEW = nil            -- Set to 1 (right) or 3 (left) to lock view
local DEBUG_SHOW_WALK_INFO = false      -- On-screen walk frame debug
local DEBUG_WALK_OFFSET = false         -- Apply visible offset per frame for debugging
local DEBUG_CYCLE_VIEW = false          -- Cycle through front/left/back/right for testing
local DEBUG_CYCLE_VIEW_FRAMES = 45      -- Frames per view (about 1.5s at 30fps)

-- Enemy health system
local ENEMY_MAX_HP = 100
local PLAYER_DAMAGE = 20
local PLAYER_ATTACK_RANGE = 1.0  -- Distance player can hit enemy
local soldiersKilled = 0
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
    map = deepCopy(level.map)
    sprites = deepCopy(level.sprites)
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
    -- Load wall textures with validation
    wallStone = loadTextureWithValidation("sprites/wall_textures/stone", "stone")
    wallBrick = loadTextureWithValidation("sprites/wall_textures/brick", "brick")
    wallMoss = loadTextureWithValidation("sprites/wall_textures/moss", "moss")
    wallMetal = loadTextureWithValidation("sprites/wall_textures/metal", "metal")
    wallWood = loadTextureWithValidation("sprites/wall_textures/wood", "wood")

    -- Log total texture memory usage
    logTextureMemoryUsage()
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
    freeSynthRef(groanSynth); groanSynth = nil
    freeSynthRef(squishSynth); squishSynth = nil
    freeSynthRef(gulpSynth); gulpSynth = nil
    vmupro.audio.exitListenMode()
    audioInitialized = false
end

local function loadLevelAudio()
    if audioInitialized then return end
    vmupro.audio.startListenMode()

    -- Create sword swoosh synth (noise-based for swoosh effect)
    swordSwooshSynth = vmupro.sound.synth.new(vmupro.sound.kWaveNoise)
    if swordSwooshSynth then
        vmupro.sound.synth.setAttack(swordSwooshSynth, 0.01)
        vmupro.sound.synth.setDecay(swordSwooshSynth, 0.1)
        vmupro.sound.synth.setSustain(swordSwooshSynth, 0.2)
        vmupro.sound.synth.setRelease(swordSwooshSynth, 0.1)
        vmupro.sound.synth.setVolume(swordSwooshSynth, 0.5, 0.5)
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

local function enterTitle()
    showMenu = false
    gameState = STATE_TITLE
    titleSelection = 1
    titleInOptions = false
    unloadLevelAudio()
    unloadLevelSprites()
    unloadLevelData()
    loadMenuSprites()
    collectgarbage()
end

local function initializeLevelState(levelId)
    loadLevel(levelId)
    playerHealth = MAX_HEALTH
    soldiersKilled = 0
    isAttacking = 0
    isBlocking = false
    showMenu = false
    swipeEffects = {}
    bloodEffects = {}
    levelBannerTimer = levelBannerMax
end

local function startLevel(levelId)
    loadingLog("LOAD startLevel begin " .. tostring(levelId))
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
    initializeLevelState(currentLevel)
    gameState = STATE_PLAYING
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
    local mx, my = math.floor(x), math.floor(y)
    if mx < 0 or mx >= 16 or my < 0 or my >= 16 then return false end
    return map[my + 1][mx + 1] == 0
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

            -- Calculate distance to player
            local dx = px - s.x
            local dy = py - s.y
            local distToPlayer = math.sqrt(dx * dx + dy * dy)
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

                    s.attackAnim = 6
                    s.attackFrame = 1

                    -- Play sword swoosh sound
                    if swordSwooshSynth and soundEnabled then
                        vmupro.sound.synth.playNote(swordSwooshSynth, 400, 0.7, 0.15)
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
                s.state = "chase"

                -- Move towards player (sprint!)
                local moveSpeed = s.speed * CHASE_SPEED_MULT
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

                local moveAmount = s.speed * s.patrolDir
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
            if s.deathTick % 1 == 0 then
                s.deathFrame = (s.deathFrame or 1) + 2
                if s.deathFrame > #warriorDeath then
                    s.dying = false
                    s.dead = true
                end
            end
            ::continue_death::
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
    end
end

-- Check for health vial pickups
local function checkHealthPickups()
    local pickupRange = 0.8  -- Distance to pick up vial
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
    -- Darken background
    vmupro.graphics.drawFillRect(40, 70, 200, 160, COLOR_BLACK)
    vmupro.graphics.drawFillRect(45, 75, 195, 155, COLOR_DARK_GRAY)

    -- Title
    vmupro.graphics.drawFillRect(50, 80, 190, 102, COLOR_GREEN)
    vmupro.text.setFont(vmupro.text.FONT_SMALL)
    vmupro.graphics.drawText("VICTORY!", 90, 85, COLOR_WHITE, COLOR_GREEN)

    -- Subtitle
    vmupro.graphics.drawText("The King is safe!", 70, 110, COLOR_WHITE, COLOR_DARK_GRAY)

    if winBannerTimer > 0 then
        local pulse = (frameCount % 20) < 10
        local bannerColor = pulse and COLOR_MAROON or COLOR_DARK_MAROON
        vmupro.graphics.drawFillRect(55, 115, 185, 130, bannerColor)
        vmupro.graphics.drawText("LEVEL COMPLETE", 68, 118, COLOR_WHITE, bannerColor)
    end

    -- Menu option
    local y = 130
    local bgColor = COLOR_DARK_GRAY
    local textColor = COLOR_GRAY
    if winSelection == 1 then
        vmupro.graphics.drawFillRect(50, y, 190, y + 20, COLOR_MAROON)
        bgColor = COLOR_MAROON
        textColor = COLOR_WHITE
    end
    local winText = "MAIN MENU"
    if currentLevel < MAX_LEVEL then
        winText = "NEXT LEVEL"
    end
    vmupro.graphics.drawText(winText, 90, y + 3, textColor, bgColor)
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
local function drawTitleScreen()
    if vmupro.system and vmupro.system.log then
        vmupro.system.log(vmupro.system.LOG_ERROR, "BOOT", "C drawTitleScreen")
    else
        print("[BOOT] C drawTitleScreen")
    end
    -- Draw title background image
    if titleSprite then
        vmupro.sprite.draw(titleSprite, 0, 0, vmupro.sprite.kImageUnflipped)
    else
        vmupro.graphics.clear(COLOR_BLACK)
    end

    -- Draw menu box
    vmupro.graphics.drawFillRect(60, 140, 180, 230, COLOR_BLACK)
    vmupro.graphics.drawFillRect(65, 145, 175, 225, COLOR_DARK_GRAY)

    if titleInOptions then
        -- Options submenu
        if vmupro.system and vmupro.system.log then
            vmupro.system.log(vmupro.system.LOG_ERROR, "BOOT", "D title options text")
        else
            print("[BOOT] D title options text")
        end
        vmupro.text.setFont(vmupro.text.FONT_SMALL)
        vmupro.graphics.drawFillRect(70, 148, 170, 168, COLOR_MAROON)
        vmupro.graphics.drawText("OPTIONS", 95, 152, COLOR_WHITE, COLOR_MAROON)

        local levelText = "LEVEL: " .. tostring(selectedLevel)
        local soundText = "SOUND: " .. (soundEnabled and "ON" or "OFF")
        local healthText = "HEALTH%: " .. (showHealthPercent and "ON" or "OFF")
        local optItems = {levelText, soundText, healthText, "BACK"}
        for i, item in ipairs(optItems) do
            local y = 172 + (i - 1) * 18
            local bgColor = COLOR_DARK_GRAY
            local textColor = COLOR_GRAY
            if i == titleOptionsSelection then
                vmupro.graphics.drawFillRect(70, y, 170, y + 16, COLOR_MAROON)
                bgColor = COLOR_MAROON
                textColor = COLOR_WHITE
            end
            vmupro.graphics.drawText(item, 75, y + 2, textColor, bgColor)
        end
    else
        -- Main title menu
        if vmupro.system and vmupro.system.log then
            vmupro.system.log(vmupro.system.LOG_ERROR, "BOOT", "D title main text")
        else
            print("[BOOT] D title main text")
        end
        vmupro.text.setFont(vmupro.text.FONT_SMALL)
        local items = {"START GAME", "OPTIONS", "EXIT"}
        for i, item in ipairs(items) do
            local y = 155 + (i - 1) * 22
            local bgColor = COLOR_DARK_GRAY
            local textColor = COLOR_GRAY
            if i == titleSelection then
                vmupro.graphics.drawFillRect(70, y, 170, y + 18, COLOR_MAROON)
                bgColor = COLOR_MAROON
                textColor = COLOR_WHITE
            end
            vmupro.graphics.drawText(item, 85, y + 3, textColor, bgColor)
        end
    end
end

-- Draw game over screen
local function drawGameOver()
    -- Darken background
    vmupro.graphics.drawFillRect(40, 70, 200, 195, COLOR_BLACK)
    vmupro.graphics.drawFillRect(45, 75, 195, 190, COLOR_DARK_GRAY)

    -- Title
    vmupro.graphics.drawFillRect(50, 80, 190, 102, COLOR_MAROON)
    vmupro.text.setFont(vmupro.text.FONT_SMALL)
    vmupro.graphics.drawText("GAME OVER", 85, 85, COLOR_WHITE, COLOR_MAROON)

    -- Menu items
    local items = {"RESTART", "MENU", "QUIT"}
    for i, item in ipairs(items) do
        local y = 107 + (i - 1) * 25
        local bgColor = COLOR_DARK_GRAY
        local textColor = COLOR_GRAY
        if i == gameOverSelection then
            vmupro.graphics.drawFillRect(50, y, 190, y + 20, COLOR_MAROON)
            bgColor = COLOR_MAROON
            textColor = COLOR_WHITE
        end
        vmupro.graphics.drawText(item, 100, y + 3, textColor, bgColor)
    end
end

-- Reset game state for restart
local function resetGame()
    restartLevel()
end

-- Collision detection for sprites
local function collidesWithSprite(nx, ny)
    if checkArrayBounds(sprites, 1, "collidesWithSprite") then
        for i = 1, #sprites do
            if checkArrayBounds(sprites, i, "collidesWithSprite") then
                local s = sprites[i]
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

local function getWallSprite(wtype)
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

local function castRay(dirIdx)
    local idx = dirIdx % 64
    if idx < 0 then idx = idx + 64 end
    local dx = cosTable[idx]
    local dy = sinTable[idx]
    local rx, ry, dist = px, py, 0
    for i = 1, 320 do
        rx = rx + dx * 0.05
        ry = ry + dy * 0.05
        dist = dist + 0.05
        local mx, my = math.floor(rx), math.floor(ry)
        if mx < 0 or mx >= 16 or my < 0 or my >= 16 then return dist, 1, 0, 0 end
        local wtype = map[my + 1][mx + 1]
        if wtype > 0 then
            local cellX = rx - mx
            local cellY = ry - my
            local edgeX = math.min(cellX, 1 - cellX)
            local edgeY = math.min(cellY, 1 - cellY)
            local side = (edgeX < edgeY) and 0 or 1
            -- Texture coordinate: use X or Y depending on which wall face we hit
            local texCoord = (side == 0) and cellY or cellX
            if texCoord < 0 then texCoord = 0 end
            if texCoord > 0.999 then texCoord = 0.999 end
            return dist, wtype, side, texCoord
        end
    end
    return 16, 1, 0, 0
end

local function isVisible(tx, ty)
    local dx, dy = tx - px, ty - py
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist < 0.1 then return true end
    dx, dy = dx / dist, dy / dist
    local rx, ry, traveled = px, py, 0
    while traveled < dist - 0.2 do
        rx, ry = rx + dx * 0.1, ry + dy * 0.1
        traveled = traveled + 0.1
        local mx, my = math.floor(rx), math.floor(ry)
        if mx >= 0 and mx < 16 and my >= 0 and my < 16 then
            if map[my + 1][mx + 1] > 0 then return false end
        end
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
    if groundY > 240 then groundY = 240 end
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
                vmupro.text.setFont(vmupro.text.FONT_SMALL)
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

function AppMain()
    if vmupro.system and vmupro.system.setLogLevel then
        vmupro.system.setLogLevel(vmupro.system.LOG_DEBUG)
    end
    if vmupro.system and vmupro.system.log then
        vmupro.system.log(vmupro.system.LOG_ERROR, "BOOT", "A AppMain enter")
    else
        print("[BOOT] A AppMain enter")
    end
    enterTitle()
    if vmupro.system and vmupro.system.log then
        vmupro.system.log(vmupro.system.LOG_ERROR, "BOOT", "B enterTitle done")
    else
        print("[BOOT] B enterTitle done")
    end

    while app_running do
        vmupro.input.read()
        frameCount = frameCount + 1


        -- Update audio
        if audioInitialized then
            vmupro.sound.update()
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

            -- Update blood effects
            updateBloodEffects()

            -- Update death animations
            updateDeathAnimations()

            -- Check for health pickups
            checkHealthPickups()
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

        -- Title screen handling
        if gameState == STATE_TITLE then
            if titleInOptions then
                -- Title options submenu
                if vmupro.input.pressed(vmupro.input.UP) then
                    titleOptionsSelection = titleOptionsSelection - 1
                    if titleOptionsSelection < 1 then titleOptionsSelection = 4 end
                end
                if vmupro.input.pressed(vmupro.input.DOWN) then
                    titleOptionsSelection = titleOptionsSelection + 1
                    if titleOptionsSelection > 4 then titleOptionsSelection = 1 end
                end
                if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                    if titleOptionsSelection == 1 then
                        selectedLevel = selectedLevel + 1
                        if selectedLevel > MAX_LEVEL then selectedLevel = 1 end
                    elseif titleOptionsSelection == 2 then
                        soundEnabled = not soundEnabled
                    elseif titleOptionsSelection == 3 then
                        showHealthPercent = not showHealthPercent
                    elseif titleOptionsSelection == 4 then
                        titleInOptions = false  -- Back
                    end
                end
                if vmupro.input.pressed(vmupro.input.B) or vmupro.input.pressed(vmupro.input.POWER) then
                    titleInOptions = false
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
                        beginLoadLevel(selectedLevel)
                    elseif titleSelection == 2 then
                        -- Options
                        titleInOptions = true
                        titleOptionsSelection = 1
                    elseif titleSelection == 3 then
                        -- Exit
                        app_running = false
                    end
                end
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
                        app_running = false  -- Quit
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
                    if optionsSelection < 1 then optionsSelection = 3 end
                end
                if vmupro.input.pressed(vmupro.input.DOWN) then
                    optionsSelection = optionsSelection + 1
                    if optionsSelection > 3 then optionsSelection = 1 end
                end
                if vmupro.input.pressed(vmupro.input.MODE) or vmupro.input.pressed(vmupro.input.A) then
                    if optionsSelection == 1 then
                        soundEnabled = not soundEnabled  -- Toggle sound
                    elseif optionsSelection == 2 then
                        showHealthPercent = not showHealthPercent  -- Toggle health %
                    elseif optionsSelection == 3 then
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
                        app_running = false  -- Quit
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
                pdir = pdir - 4
                if pdir < 0 then pdir = pdir + 64 end
            end
            if vmupro.input.held(vmupro.input.RIGHT) then
                pdir = pdir + 4
                if pdir >= 64 then pdir = pdir - 64 end
            end

            local idx = pdir % 64
            local dx = cosTable[idx] * 0.3
            local dy = sinTable[idx] * 0.3
            -- Strafe direction (perpendicular to facing)
            local strafe_idx = (pdir + 16) % 64  -- 90 degrees right
            local sdx = cosTable[strafe_idx] * 0.3
            local sdy = sinTable[strafe_idx] * 0.3

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
                    for i = 1, #sprites do
                        local s = sprites[i]
                        if s.t == 5 and s.alive then
                            local dx = s.x - px
                            local dy = s.y - py
                            local dist = math.sqrt(dx * dx + dy * dy)
                            if dist < PLAYER_ATTACK_RANGE then
                                -- Hit the enemy
                                s.hp = s.hp - PLAYER_DAMAGE
                                if s.hp <= 0 then
                                    killSoldier(s)
                                end
                            end
                        end
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
                    local mx, my = math.floor(nx), math.floor(ny)
                    if mx >= 0 and mx < 16 and my >= 0 and my < 16 then
                        if map[math.floor(py) + 1][mx + 1] == 0 and not collidesWithSprite(nx, py) then
                            px = nx
                        end
                        if map[my + 1][math.floor(px) + 1] == 0 and not collidesWithSprite(px, ny) then
                            py = ny
                        end
                    end
                end

                -- DOWN: Move backward (held for continuous movement)
                if vmupro.input.held(vmupro.input.DOWN) then
                    local nx, ny = px - dx, py - dy
                    local mx, my = math.floor(nx), math.floor(ny)
                    if mx >= 0 and mx < 16 and my >= 0 and my < 16 then
                        if map[math.floor(py) + 1][mx + 1] == 0 and not collidesWithSprite(nx, py) then
                            px = nx
                        end
                        if map[my + 1][math.floor(px) + 1] == 0 and not collidesWithSprite(px, ny) then
                            py = ny
                        end
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

            -- A: Strafe left (held for continuous movement)
            if vmupro.input.held(vmupro.input.A) then
                local nx, ny = px - sdx, py - sdy
                local mx, my = math.floor(nx), math.floor(ny)
                if mx >= 0 and mx < 16 and my >= 0 and my < 16 then
                    if map[math.floor(py) + 1][mx + 1] == 0 and not collidesWithSprite(nx, py) then
                        px = nx
                    end
                    if map[my + 1][math.floor(px) + 1] == 0 and not collidesWithSprite(px, ny) then
                        py = ny
                    end
                end
            end

            -- B: Strafe right (held for continuous movement)
            if vmupro.input.held(vmupro.input.B) then
                local nx, ny = px + sdx, py + sdy
                local mx, my = math.floor(nx), math.floor(ny)
                if mx >= 0 and mx < 16 and my >= 0 and my < 16 then
                    if map[math.floor(py) + 1][mx + 1] == 0 and not collidesWithSprite(nx, py) then
                        px = nx
                    end
                    if map[my + 1][math.floor(px) + 1] == 0 and not collidesWithSprite(px, ny) then
                        py = ny
                    end
                end
            end

            -- POWER: Menu
            if vmupro.input.pressed(vmupro.input.POWER) then
                showMenu = true
                menuSelection = 1
            end
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
            drawTitleScreen()
        else
            -- Game rendering
            vmupro.graphics.clear(COLOR_CEILING)
            vmupro.graphics.drawFillRect(0, HORIZON, 240, 240, COLOR_FLOOR)

        if USE_WALL_QUADS then
            renderWallQuads()
        else
            for x = 0, 59 do
                local rayDir = pdir - 5 + math.floor(x * 11 / 60)
                local dist, wtype, side, texCoord = castRay(rayDir)
                local angleDiff = (rayDir - pdir) % 64
                if angleDiff > 32 then angleDiff = angleDiff - 64 end
                local cosIdx = math.abs(angleDiff) % 64
                if cosIdx > 16 then cosIdx = 16 end
                local fixedDist = dist * cosTable[cosIdx]
                if fixedDist < 0.1 then fixedDist = 0.1 end
                local h = math.floor(200 / fixedDist)
                if h > 240 then h = 240 end
                local y1 = HORIZON - math.floor(h / 2)
                local y2 = HORIZON + math.floor(h / 2)
                if y1 < 0 then y1 = 0 end
                if y2 > 240 then y2 = 240 end

                local baseColor = getWallColor(wtype, side)
                local sx = x * 4

                -- Draw base wall color
                vmupro.graphics.drawFillRect(sx, y1, sx + 4, y2, baseColor)
                -- Overlay bitmap wall texture
                drawWallTexture(wtype, side, sx, y1, y2)
            end
        end

        local spriteOrder = {}
        for i = 1, #sprites do
            local s = sprites[i]
            local sdx, sdy = s.x - px, s.y - py
            spriteOrder[i] = {idx = i, dist = sdx * sdx + sdy * sdy}
        end
        for i = 1, #spriteOrder - 1 do
            for j = 1, #spriteOrder - i do
                if spriteOrder[j].dist < spriteOrder[j + 1].dist then
                    spriteOrder[j], spriteOrder[j + 1] = spriteOrder[j + 1], spriteOrder[j]
                end
            end
        end

        for i = 1, #spriteOrder do
            local s = sprites[spriteOrder[i].idx]
            -- Skip dead soldiers
            if s.t == 5 and s.alive == false and not s.dying then
                goto continue_sprite
            end
            local sdx, sdy = s.x - px, s.y - py
            local sdist = math.sqrt(sdx * sdx + sdy * sdy)
            if sdist > 0.3 and sdist < 12 and isVisible(s.x, s.y) then
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
            ::continue_sprite::
        end

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

        -- Draw attack sword swing
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

        -- Draw block shield
        if isBlocking then
            -- Shield in center of screen
            vmupro.graphics.drawFillRect(80, 140, 160, 230, COLOR_BROWN)
            vmupro.graphics.drawFillRect(85, 145, 155, 225, COLOR_DARK_BROWN)
            -- Shield boss (center)
            vmupro.graphics.drawFillRect(110, 175, 130, 195, COLOR_GRAY)
            vmupro.graphics.drawFillRect(115, 180, 125, 190, COLOR_LIGHT_GRAY)
            -- Shield rim
            vmupro.graphics.drawFillRect(80, 140, 160, 145, COLOR_GRAY)
            vmupro.graphics.drawFillRect(80, 225, 160, 230, COLOR_GRAY)
            vmupro.graphics.drawFillRect(80, 140, 85, 230, COLOR_GRAY)
            vmupro.graphics.drawFillRect(155, 140, 160, 230, COLOR_GRAY)
        end

        -- Draw menu
        if showMenu then
            if inOptionsMenu then
                -- Options submenu
                vmupro.graphics.drawFillRect(50, 60, 190, 180, COLOR_BLACK)
                vmupro.graphics.drawFillRect(55, 65, 185, 175, COLOR_DARK_GRAY)
                -- Title bar
                vmupro.graphics.drawFillRect(60, 70, 180, 92, COLOR_MAROON)
                vmupro.text.setFont(vmupro.text.FONT_SMALL)
                vmupro.graphics.drawText("OPTIONS", 90, 75, COLOR_WHITE, COLOR_MAROON)
                -- Options items
                local soundText = "SOUND: " .. (soundEnabled and "ON" or "OFF")
                local healthText = "HEALTH%: " .. (showHealthPercent and "ON" or "OFF")
                local optItems = {soundText, healthText, "BACK"}
                for i, item in ipairs(optItems) do
                    local y = 95 + (i - 1) * 25
                    local bgColor = COLOR_DARK_GRAY
                    local textColor = COLOR_GRAY
                    if i == optionsSelection then
                        vmupro.graphics.drawFillRect(60, y, 180, y + 20, COLOR_MAROON)
                        bgColor = COLOR_MAROON
                        textColor = COLOR_WHITE
                    end
                    vmupro.graphics.drawText(item, 70, y + 3, textColor, bgColor)
                end
            else
                -- Main pause menu
                vmupro.graphics.drawFillRect(50, 60, 190, 225, COLOR_BLACK)
                vmupro.graphics.drawFillRect(55, 65, 185, 220, COLOR_DARK_GRAY)
                -- Title bar
                vmupro.graphics.drawFillRect(60, 70, 180, 92, COLOR_MAROON)
                vmupro.text.setFont(vmupro.text.FONT_SMALL)
                vmupro.graphics.drawText("PAUSED", 95, 75, COLOR_WHITE, COLOR_MAROON)
                -- Menu items
                local items = {"RESUME", "OPTIONS", "RESTART", "MENU", "QUIT"}
                for i, item in ipairs(items) do
                    local y = 95 + (i - 1) * 24
                    local bgColor = COLOR_DARK_GRAY
                    local textColor = COLOR_GRAY
                    if i == menuSelection then
                        vmupro.graphics.drawFillRect(60, y, 180, y + 20, COLOR_MAROON)
                        bgColor = COLOR_MAROON
                        textColor = COLOR_WHITE
                    end
                    vmupro.graphics.drawText(item, 90, y + 3, textColor, bgColor)
                end
            end
        end

        -- Draw health UI (potion with liquid)
        drawHealthUI()

        -- Draw current level indicator
        vmupro.text.setFont(vmupro.text.FONT_SMALL)
        vmupro.graphics.drawText("L" .. tostring(currentLevel), 6, 228, COLOR_WHITE, COLOR_BLACK)

        if levelBannerTimer > 0 then
            local bannerText = "LEVEL " .. tostring(currentLevel)
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
        end  -- End of game rendering (else branch of title screen check)

        ::render_only::
        vmupro.graphics.refresh()
        vmupro.system.delayMs(33)
    end

    -- Cleanup assets
    unloadLevelAudio()
    unloadLevelSprites()
    unloadMenuSprites()

    return 0
end
