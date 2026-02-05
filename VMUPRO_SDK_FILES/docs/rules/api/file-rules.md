# VMU Pro File System API Rules

## Overview

The `vmupro.file` namespace provides file system operations for VMU Pro applications. All file operations are **strictly restricted to the `/sdcard/` directory** for security purposes.

**Namespace:** `vmupro.file`
**Security Level:** Sandboxed (restricted to /sdcard only)
**Platform:** VMU Pro Embedded System
**Version:** 1.0.0

---

## Security and Safety Guidelines

### Critical Path Restrictions

1. **ALL file paths MUST start with `/sdcard/`**
   - Any path not starting with `/sdcard/` will be rejected
   - No access to system directories, root, or other storage locations
   - This is enforced at the firmware level for security

2. **Path Validation Required**
   ```lua
   -- Always validate paths before operations
   local function isValidPath(path)
       return path and type(path) == "string" and path:sub(1, 8) == "/sdcard/"
   end
   ```

3. **No Path Traversal**
   - Do not attempt to use `..` to escape the /sdcard directory
   - Paths are validated by firmware; attempts to escape will fail

### Storage Best Practices for Embedded Systems

1. **Limited Storage Space**
   - VMU Pro has limited SD card storage
   - Always check file sizes before operations
   - Clean up temporary files promptly
   - Avoid creating unnecessary large files

2. **File Size Awareness**
   ```lua
   -- Check file size before reading
   local size = vmupro.file.getSize("/sdcard/data.bin")
   if size > 0 and size < 100000 then  -- Only read files < 100KB
       local data = vmupro.file.read("/sdcard/data.bin")
   end
   ```

3. **Error Handling**
   - Always check return values (most functions return boolean success)
   - Validate existence before operations
   - Handle nil returns from read operations gracefully

4. **Atomic Operations**
   - Write operations replace entire file content
   - No append mode available
   - For updates, read → modify → write pattern required

---

## File System Functions

### File Existence and Information

#### `vmupro.file.exists(path)`

Check if a file exists.

**Parameters:**
- `path` (string): File path (must start with "/sdcard/")

**Returns:**
- `boolean`: true if file exists, false otherwise

**Examples:**
```lua
-- Check before reading
if vmupro.file.exists("/sdcard/save.dat") then
    local data = vmupro.file.read("/sdcard/save.dat")
end

-- Conditional game logic
if vmupro.file.exists("/sdcard/continue.sav") then
    showContinueOption()
else
    startNewGame()
end
```

**Rules:**
- Returns false for non-existent files (not an error)
- Returns false for directories (use `folderExists` instead)
- Always check existence before read/delete operations

---

#### `vmupro.file.getSize(path)`

Get the size of a file in bytes.

**Parameters:**
- `path` (string): File path (must start with "/sdcard/")

**Returns:**
- `number`: Size of file in bytes, or 0 if file doesn't exist

**Examples:**
```lua
-- Check file size before loading
local size = vmupro.file.getSize("/sdcard/level.dat")
if size > 0 and size < 50000 then
    local levelData = vmupro.file.read("/sdcard/level.dat")
end

-- Display storage usage
local saveSize = vmupro.file.getSize("/sdcard/autosave.bin")
print(string.format("Save file: %.2f KB", saveSize / 1024))
```

**Rules:**
- Returns 0 for non-existent files (not nil or error)
- Useful for validating file size before reading into memory
- Size is in bytes (divide by 1024 for KB, 1048576 for MB)

---

### File Reading

#### `vmupro.file.read(path)`

Read entire file contents as a string.

**Parameters:**
- `path` (string): File path (must start with "/sdcard/")

**Returns:**
- `string|nil`: File contents as string, or nil if file doesn't exist or error

**Examples:**
```lua
-- Basic file reading
local config = vmupro.file.read("/sdcard/config.txt")
if config then
    parseConfig(config)
end

-- Binary data reading
local saveData = vmupro.file.read("/sdcard/player.sav")
if saveData then
    player.score = string.unpack("i4", saveData, 1)
end

-- JSON configuration
local settingsJson = vmupro.file.read("/sdcard/settings.json")
if settingsJson then
    local settings = json.decode(settingsJson)
end
```

**Rules:**
- Returns nil if file doesn't exist (always check!)
- Returns entire file as single string
- No streaming or partial reads available
- Binary-safe (can read binary files)
- Check file size first for large files to avoid memory issues

**Error Handling:**
```lua
local data = vmupro.file.read("/sdcard/data.txt")
if not data then
    vmupro.log.error("Failed to read data file")
    -- Handle error: use defaults, show error, etc.
    return
end
```

---

### File Writing

#### `vmupro.file.write(path, data)`

Write data to a file, replacing any existing content.

**Parameters:**
- `path` (string): File path (must start with "/sdcard/")
- `data` (string): Data to write to the file

**Returns:**
- `boolean`: true if file was written successfully, false otherwise

**Examples:**
```lua
-- Save game state
local success = vmupro.file.write("/sdcard/save.dat", "level=5\nscore=1000")
if not success then
    vmupro.log.error("Failed to save game")
end

-- Save binary data
local binaryData = string.pack("i4i4i4", player.x, player.y, player.score)
vmupro.file.write("/sdcard/player.bin", binaryData)

-- Save JSON configuration
local config = { volume = 75, difficulty = "hard" }
local json = encodeJson(config)
vmupro.file.write("/sdcard/config.json", json)
```

**Rules:**
- Completely replaces file content (no append mode)
- Creates file if it doesn't exist
- Creates parent directories automatically if they don't exist
- Binary-safe (can write binary data)
- Always check return value for success

**Important Patterns:**
```lua
-- Safe write with validation
local function safeWrite(path, data)
    if not isValidPath(path) then
        return false, "Invalid path"
    end

    local success = vmupro.file.write(path, data)
    if not success then
        vmupro.log.error("Write failed: " .. path)
        return false, "Write failed"
    end

    return true
end

-- Update existing file (read-modify-write)
local function updateConfig(key, value)
    local config = vmupro.file.read("/sdcard/config.txt") or ""
    -- Modify config string...
    local newConfig = modifyConfigString(config, key, value)
    return vmupro.file.write("/sdcard/config.txt", newConfig)
end
```

---

#### `vmupro.file.createFile(path)`

Create an empty file.

**Parameters:**
- `path` (string): File path to create (must start with "/sdcard/")

**Returns:**
- `boolean`: true if file was created successfully (or already exists), false otherwise

**Examples:**
```lua
-- Create placeholder file
vmupro.file.createFile("/sdcard/firstrun.flag")

-- Initialize save slot
if not vmupro.file.exists("/sdcard/slot1.sav") then
    vmupro.file.createFile("/sdcard/slot1.sav")
end
```

**Rules:**
- Returns true if file already exists (not an error)
- Creates parent directories if needed
- Creates zero-byte file
- Use `write()` instead if you have initial content

---

### File Deletion

#### `vmupro.file.deleteFile(path)`

Delete a file.

**Parameters:**
- `path` (string): File path (must start with "/sdcard/")

**Returns:**
- `boolean`: true if file was deleted successfully, false otherwise

**Examples:**
```lua
-- Delete temporary file
vmupro.file.deleteFile("/sdcard/temp.dat")

-- Delete save slot
local function deleteSaveSlot(slot)
    local path = string.format("/sdcard/save%d.dat", slot)
    if vmupro.file.exists(path) then
        local success = vmupro.file.deleteFile(path)
        if success then
            vmupro.log.info("Deleted save slot " .. slot)
        end
    end
end

-- Clean up old files
if vmupro.file.exists("/sdcard/cache.tmp") then
    vmupro.file.deleteFile("/sdcard/cache.tmp")
end
```

**Rules:**
- Returns false if file doesn't exist
- Cannot delete directories (use `deleteFolder` instead)
- Always check return value to confirm deletion
- No undo/recovery available after deletion

---

### Directory Operations

#### `vmupro.file.folderExists(path)`

Check if a folder exists.

**Parameters:**
- `path` (string): Folder path (must start with "/sdcard/")

**Returns:**
- `boolean`: true if folder exists, false otherwise

**Examples:**
```lua
-- Check save directory
if vmupro.file.folderExists("/sdcard/saves") then
    loadSaveList()
end

-- Ensure directory exists
if not vmupro.file.folderExists("/sdcard/levels") then
    vmupro.file.createFolder("/sdcard/levels")
end
```

**Rules:**
- Returns false for files (not directories)
- Use this instead of `exists()` for directories
- `/sdcard/` itself always exists

---

#### `vmupro.file.createFolder(path)`

Create a new folder.

**Parameters:**
- `path` (string): Folder path to create (must start with "/sdcard/")

**Returns:**
- `boolean`: true if folder was created successfully, false otherwise

**Examples:**
```lua
-- Create save directory
local success = vmupro.file.createFolder("/sdcard/saves")

-- Create nested directories
vmupro.file.createFolder("/sdcard/game")
vmupro.file.createFolder("/sdcard/game/levels")
vmupro.file.createFolder("/sdcard/game/saves")

-- Ensure directory structure
local function ensureDirectories()
    local dirs = {
        "/sdcard/saves",
        "/sdcard/config",
        "/sdcard/levels",
        "/sdcard/temp"
    }

    for _, dir in ipairs(dirs) do
        if not vmupro.file.folderExists(dir) then
            vmupro.file.createFolder(dir)
        end
    end
end
```

**Rules:**
- Returns true if folder already exists (idempotent)
- Creates parent directories automatically if needed
- Cannot create folders outside /sdcard/

---

#### `vmupro.file.deleteFolder(path)`

Delete a folder.

**Parameters:**
- `path` (string): Folder path (must start with "/sdcard/")

**Returns:**
- `boolean`: true if folder was deleted successfully, false otherwise

**Examples:**
```lua
-- Delete empty temporary directory
vmupro.file.deleteFolder("/sdcard/temp")

-- Delete folder after cleaning contents
local function deleteAllSaves()
    -- Delete all files first
    for i = 1, 3 do
        vmupro.file.deleteFile(string.format("/sdcard/saves/slot%d.sav", i))
    end
    -- Then delete folder
    vmupro.file.deleteFolder("/sdcard/saves")
end
```

**Rules:**
- **Folder must be empty before deletion**
- Returns false if folder is not empty
- Returns false if folder doesn't exist
- Cannot delete /sdcard/ itself
- Delete all files in folder first, then delete folder

---

## Common File Patterns

### 1. Save/Load Game State

```lua
-- Save game state
local function saveGame(slot)
    local saveData = {
        level = game.currentLevel,
        score = player.score,
        lives = player.lives,
        timestamp = os.time()
    }

    local json = encodeJson(saveData)
    local path = string.format("/sdcard/save%d.json", slot)

    local success = vmupro.file.write(path, json)
    if success then
        vmupro.log.info("Game saved to slot " .. slot)
    else
        vmupro.log.error("Failed to save game")
    end

    return success
end

-- Load game state
local function loadGame(slot)
    local path = string.format("/sdcard/save%d.json", slot)

    if not vmupro.file.exists(path) then
        vmupro.log.warn("No save file in slot " .. slot)
        return nil
    end

    local json = vmupro.file.read(path)
    if not json then
        vmupro.log.error("Failed to read save file")
        return nil
    end

    local saveData = decodeJson(json)
    if saveData then
        game.currentLevel = saveData.level
        player.score = saveData.score
        player.lives = saveData.lives
        vmupro.log.info("Game loaded from slot " .. slot)
    end

    return saveData
end
```

### 2. Configuration Files

```lua
-- Default configuration
local defaultConfig = {
    volume = 50,
    difficulty = "normal",
    language = "en",
    fullscreen = false
}

-- Load configuration with defaults
local function loadConfig()
    local config = {}

    if vmupro.file.exists("/sdcard/config.json") then
        local json = vmupro.file.read("/sdcard/config.json")
        if json then
            config = decodeJson(json) or {}
        end
    end

    -- Merge with defaults
    for key, value in pairs(defaultConfig) do
        if config[key] == nil then
            config[key] = value
        end
    end

    return config
end

-- Save configuration
local function saveConfig(config)
    local json = encodeJson(config)
    return vmupro.file.write("/sdcard/config.json", json)
end

-- Update single setting
local function updateSetting(key, value)
    local config = loadConfig()
    config[key] = value
    return saveConfig(config)
end
```

### 3. High Score Persistence

```lua
-- High score table
local function loadHighScores()
    local path = "/sdcard/highscores.dat"

    if not vmupro.file.exists(path) then
        return { 0, 0, 0, 0, 0 }  -- Default empty scores
    end

    local data = vmupro.file.read(path)
    if not data then
        return { 0, 0, 0, 0, 0 }
    end

    -- Unpack 5 integers
    local scores = { string.unpack("i4i4i4i4i4", data) }
    return scores
end

-- Save high scores
local function saveHighScores(scores)
    local data = string.pack("i4i4i4i4i4",
        scores[1], scores[2], scores[3], scores[4], scores[5])
    return vmupro.file.write("/sdcard/highscores.dat", data)
end

-- Add new high score
local function addHighScore(newScore)
    local scores = loadHighScores()

    -- Insert and sort
    table.insert(scores, newScore)
    table.sort(scores, function(a, b) return a > b end)

    -- Keep top 5
    scores = { scores[1], scores[2], scores[3], scores[4], scores[5] }

    return saveHighScores(scores)
end
```

### 4. First Run Detection

```lua
-- Check if this is first run
local function isFirstRun()
    return not vmupro.file.exists("/sdcard/initialized.flag")
end

-- Mark as initialized
local function markInitialized()
    vmupro.file.createFile("/sdcard/initialized.flag")
end

-- Application initialization
local function initialize()
    if isFirstRun() then
        -- First run setup
        vmupro.file.createFolder("/sdcard/saves")
        vmupro.file.createFolder("/sdcard/config")

        -- Create default config
        local defaultCfg = encodeJson(defaultConfig)
        vmupro.file.write("/sdcard/config/settings.json", defaultCfg)

        -- Mark as initialized
        markInitialized()

        vmupro.log.info("First run initialization complete")
    end
end
```

### 5. Temporary File Management

```lua
-- Create temporary file with cleanup
local TempFile = {}
TempFile.__index = TempFile

function TempFile.new(name)
    local self = setmetatable({}, TempFile)
    self.path = "/sdcard/temp/" .. name

    -- Ensure temp directory exists
    if not vmupro.file.folderExists("/sdcard/temp") then
        vmupro.file.createFolder("/sdcard/temp")
    end

    return self
end

function TempFile:write(data)
    return vmupro.file.write(self.path, data)
end

function TempFile:read()
    return vmupro.file.read(self.path)
end

function TempFile:cleanup()
    if vmupro.file.exists(self.path) then
        vmupro.file.deleteFile(self.path)
    end
end

-- Usage
local temp = TempFile.new("cache.dat")
temp:write("temporary data")
local data = temp:read()
temp:cleanup()
```

### 6. Level Data Management

```lua
-- Level data structure
local LevelManager = {}

function LevelManager.saveLevelProgress(levelNum, progress)
    local path = string.format("/sdcard/levels/level%03d.dat", levelNum)

    -- Ensure levels directory exists
    if not vmupro.file.folderExists("/sdcard/levels") then
        vmupro.file.createFolder("/sdcard/levels")
    end

    -- Save progress data
    local data = string.pack("i4i4i4",
        progress.completed and 1 or 0,
        progress.stars,
        progress.bestTime
    )

    return vmupro.file.write(path, data)
end

function LevelManager.loadLevelProgress(levelNum)
    local path = string.format("/sdcard/levels/level%03d.dat", levelNum)

    if not vmupro.file.exists(path) then
        return { completed = false, stars = 0, bestTime = 0 }
    end

    local data = vmupro.file.read(path)
    if not data then
        return { completed = false, stars = 0, bestTime = 0 }
    end

    local completed, stars, bestTime = string.unpack("i4i4i4", data)

    return {
        completed = completed == 1,
        stars = stars,
        bestTime = bestTime
    }
end

function LevelManager.getTotalProgress()
    local total = 0
    local completed = 0

    for i = 1, 50 do  -- Assuming 50 levels
        local progress = LevelManager.loadLevelProgress(i)
        total = total + 1
        if progress.completed then
            completed = completed + 1
        end
    end

    return completed, total
end
```

---

## Error Handling Patterns

### Pattern 1: Defensive Programming

```lua
local function safeReadFile(path)
    -- Validate path
    if not path or type(path) ~= "string" then
        vmupro.log.error("Invalid path parameter")
        return nil, "invalid_path"
    end

    if not path:sub(1, 8) == "/sdcard/" then
        vmupro.log.error("Path must start with /sdcard/")
        return nil, "invalid_path"
    end

    -- Check existence
    if not vmupro.file.exists(path) then
        vmupro.log.warn("File not found: " .. path)
        return nil, "not_found"
    end

    -- Check size
    local size = vmupro.file.getSize(path)
    if size > 1000000 then  -- 1MB limit
        vmupro.log.error("File too large: " .. size)
        return nil, "too_large"
    end

    -- Read file
    local data = vmupro.file.read(path)
    if not data then
        vmupro.log.error("Failed to read file: " .. path)
        return nil, "read_failed"
    end

    return data, nil
end
```

### Pattern 2: Fallback to Defaults

```lua
local function loadConfigWithFallback()
    local config = defaultConfig

    if vmupro.file.exists("/sdcard/config.json") then
        local json = vmupro.file.read("/sdcard/config.json")
        if json then
            local parsed = decodeJson(json)
            if parsed and type(parsed) == "table" then
                config = parsed
            else
                vmupro.log.warn("Invalid config file, using defaults")
            end
        else
            vmupro.log.warn("Failed to read config, using defaults")
        end
    else
        vmupro.log.info("No config file, using defaults")
    end

    return config
end
```

### Pattern 3: Retry Logic

```lua
local function writeWithRetry(path, data, maxRetries)
    maxRetries = maxRetries or 3

    for attempt = 1, maxRetries do
        local success = vmupro.file.write(path, data)

        if success then
            vmupro.log.info("Write successful on attempt " .. attempt)
            return true
        end

        vmupro.log.warn("Write failed, attempt " .. attempt .. "/" .. maxRetries)

        if attempt < maxRetries then
            vmupro.wait(100)  -- Wait 100ms before retry
        end
    end

    vmupro.log.error("Write failed after " .. maxRetries .. " attempts")
    return false
end
```

### Pattern 4: Atomic Save (Backup Strategy)

```lua
local function atomicSave(path, data)
    local backupPath = path .. ".backup"
    local tempPath = path .. ".tmp"

    -- If original exists, back it up
    if vmupro.file.exists(path) then
        local original = vmupro.file.read(path)
        if original then
            vmupro.file.write(backupPath, original)
        end
    end

    -- Write to temporary file
    local success = vmupro.file.write(tempPath, data)
    if not success then
        vmupro.log.error("Failed to write temporary file")
        return false
    end

    -- Delete original if it exists
    if vmupro.file.exists(path) then
        vmupro.file.deleteFile(path)
    end

    -- Rename temp to original
    -- Note: Since rename is not available, we write again
    success = vmupro.file.write(path, data)

    if success then
        -- Clean up temp and backup
        vmupro.file.deleteFile(tempPath)
        vmupro.file.deleteFile(backupPath)
        return true
    else
        -- Restore from backup
        vmupro.log.error("Failed to finalize save, restoring backup")
        if vmupro.file.exists(backupPath) then
            local backup = vmupro.file.read(backupPath)
            if backup then
                vmupro.file.write(path, backup)
            end
        end
        return false
    end
end
```

---

## Storage Optimization

### 1. Compression for Text Data

```lua
-- Simple run-length encoding (example)
local function compress(data)
    -- Implement compression algorithm
    -- (Real implementation would use better compression)
    return data  -- Placeholder
end

local function decompress(data)
    -- Implement decompression algorithm
    return data  -- Placeholder
end

local function saveCompressed(path, data)
    local compressed = compress(data)
    return vmupro.file.write(path, compressed)
end
```

### 2. Binary Format for Efficiency

```lua
-- Save player state in binary format (compact)
local function savePlayerBinary(player)
    local data = string.pack(
        "i4i4i4i4i4BBB",
        player.x,           -- 4 bytes
        player.y,           -- 4 bytes
        player.score,       -- 4 bytes
        player.health,      -- 4 bytes
        player.ammo,        -- 4 bytes
        player.level,       -- 1 byte
        player.weapons,     -- 1 byte (bitfield)
        player.powerups     -- 1 byte (bitfield)
    )
    -- Total: 23 bytes instead of 100+ bytes in JSON

    return vmupro.file.write("/sdcard/player.bin", data)
end

local function loadPlayerBinary()
    local data = vmupro.file.read("/sdcard/player.bin")
    if not data then return nil end

    local x, y, score, health, ammo, level, weapons, powerups =
        string.unpack("i4i4i4i4i4BBB", data)

    return {
        x = x, y = y, score = score, health = health,
        ammo = ammo, level = level, weapons = weapons,
        powerups = powerups
    }
end
```

### 3. Cleanup Old Files

```lua
local function cleanupOldFiles(maxAge)
    -- Example: Delete temporary files older than maxAge seconds
    local tempFiles = {
        "/sdcard/temp/cache1.tmp",
        "/sdcard/temp/cache2.tmp",
        "/sdcard/temp/buffer.tmp"
    }

    for _, path in ipairs(tempFiles) do
        if vmupro.file.exists(path) then
            -- In real implementation, check file timestamp
            vmupro.file.deleteFile(path)
        end
    end
end
```

---

## Performance Considerations

### 1. Minimize File I/O

```lua
-- BAD: Reading file multiple times
for i = 1, 10 do
    local config = vmupro.file.read("/sdcard/config.json")
    local value = parseConfigValue(config, "setting" .. i)
end

-- GOOD: Read once, parse multiple times
local config = vmupro.file.read("/sdcard/config.json")
for i = 1, 10 do
    local value = parseConfigValue(config, "setting" .. i)
end
```

### 2. Batch Writes

```lua
-- BAD: Multiple small writes
vmupro.file.write("/sdcard/log.txt", "Line 1\n")
vmupro.file.write("/sdcard/log.txt", "Line 2\n")  -- Overwrites!

-- GOOD: Accumulate and write once
local logBuffer = {}
table.insert(logBuffer, "Line 1")
table.insert(logBuffer, "Line 2")
table.insert(logBuffer, "Line 3")
vmupro.file.write("/sdcard/log.txt", table.concat(logBuffer, "\n"))
```

### 3. Lazy Loading

```lua
local LevelData = {}
local loadedLevels = {}

function LevelData.get(levelNum)
    -- Check if already loaded
    if loadedLevels[levelNum] then
        return loadedLevels[levelNum]
    end

    -- Load on demand
    local path = string.format("/sdcard/levels/level%d.dat", levelNum)
    local data = vmupro.file.read(path)

    if data then
        loadedLevels[levelNum] = parseLevelData(data)
        return loadedLevels[levelNum]
    end

    return nil
end
```

---

## Complete Example: Save System

Here's a complete, production-ready save system:

```lua
-- SaveManager.lua - Complete save/load system
local SaveManager = {}

-- Configuration
local SAVE_VERSION = 1
local MAX_SAVE_SLOTS = 3
local SAVE_DIR = "/sdcard/saves"

-- Initialize save system
function SaveManager.init()
    if not vmupro.file.folderExists(SAVE_DIR) then
        local success = vmupro.file.createFolder(SAVE_DIR)
        if not success then
            vmupro.log.error("Failed to create save directory")
            return false
        end
    end
    return true
end

-- Get save file path
local function getSavePath(slot)
    if slot < 1 or slot > MAX_SAVE_SLOTS then
        return nil
    end
    return string.format("%s/slot%d.sav", SAVE_DIR, slot)
end

-- Check if save slot exists
function SaveManager.hasSave(slot)
    local path = getSavePath(slot)
    return path and vmupro.file.exists(path)
end

-- Get save slot info
function SaveManager.getSaveInfo(slot)
    if not SaveManager.hasSave(slot) then
        return nil
    end

    local path = getSavePath(slot)
    local data = vmupro.file.read(path)

    if not data or #data < 12 then
        return nil
    end

    -- Read header (version, timestamp, level)
    local version, timestamp, level = string.unpack("i4i4i4", data)

    if version ~= SAVE_VERSION then
        vmupro.log.warn("Save slot " .. slot .. " has wrong version")
        return nil
    end

    return {
        slot = slot,
        version = version,
        timestamp = timestamp,
        level = level,
        date = os.date("%Y-%m-%d %H:%M", timestamp)
    }
end

-- Save game state
function SaveManager.save(slot, gameState)
    local path = getSavePath(slot)
    if not path then
        vmupro.log.error("Invalid save slot: " .. tostring(slot))
        return false
    end

    -- Create save data
    local saveData = {
        version = SAVE_VERSION,
        timestamp = os.time(),
        level = gameState.level,
        score = gameState.score,
        lives = gameState.lives,
        playerX = gameState.player.x,
        playerY = gameState.player.y,
        health = gameState.player.health,
        inventory = gameState.player.inventory
    }

    -- Pack binary data
    local packed = string.pack(
        "i4i4i4i4i4i4i4i4",
        saveData.version,
        saveData.timestamp,
        saveData.level,
        saveData.score,
        saveData.lives,
        saveData.playerX,
        saveData.playerY,
        saveData.health
    )

    -- Append inventory as JSON (variable length)
    local inventoryJson = encodeJson(saveData.inventory)
    packed = packed .. inventoryJson

    -- Write with backup strategy
    local backupPath = path .. ".bak"

    -- Backup existing save
    if vmupro.file.exists(path) then
        local existing = vmupro.file.read(path)
        if existing then
            vmupro.file.write(backupPath, existing)
        end
    end

    -- Write new save
    local success = vmupro.file.write(path, packed)

    if success then
        vmupro.log.info("Game saved to slot " .. slot)
        -- Clean up backup
        if vmupro.file.exists(backupPath) then
            vmupro.file.deleteFile(backupPath)
        end
        return true
    else
        vmupro.log.error("Failed to save game to slot " .. slot)
        return false
    end
end

-- Load game state
function SaveManager.load(slot)
    local path = getSavePath(slot)
    if not path then
        vmupro.log.error("Invalid save slot: " .. tostring(slot))
        return nil
    end

    if not vmupro.file.exists(path) then
        vmupro.log.warn("No save file in slot " .. slot)
        return nil
    end

    local data = vmupro.file.read(path)
    if not data or #data < 32 then
        vmupro.log.error("Invalid save file in slot " .. slot)
        return nil
    end

    -- Unpack binary header
    local version, timestamp, level, score, lives, playerX, playerY, health =
        string.unpack("i4i4i4i4i4i4i4i4", data)

    if version ~= SAVE_VERSION then
        vmupro.log.error("Save file version mismatch")
        return nil
    end

    -- Extract inventory JSON
    local inventoryJson = data:sub(33)  -- After 32 bytes of binary data
    local inventory = decodeJson(inventoryJson)

    if not inventory then
        vmupro.log.warn("Failed to parse inventory, using empty")
        inventory = {}
    end

    vmupro.log.info("Game loaded from slot " .. slot)

    return {
        level = level,
        score = score,
        lives = lives,
        player = {
            x = playerX,
            y = playerY,
            health = health,
            inventory = inventory
        }
    }
end

-- Delete save slot
function SaveManager.delete(slot)
    local path = getSavePath(slot)
    if not path then
        return false
    end

    if vmupro.file.exists(path) then
        local success = vmupro.file.deleteFile(path)
        if success then
            vmupro.log.info("Deleted save slot " .. slot)
        end
        return success
    end

    return false
end

-- List all save slots
function SaveManager.listSaves()
    local saves = {}

    for slot = 1, MAX_SAVE_SLOTS do
        local info = SaveManager.getSaveInfo(slot)
        if info then
            table.insert(saves, info)
        end
    end

    return saves
end

return SaveManager
```

---

## Summary Checklist

### Before Every File Operation:

- [ ] Path starts with `/sdcard/`
- [ ] Path is validated (not nil, correct type)
- [ ] Check file existence when needed
- [ ] Check file size for large files
- [ ] Handle nil/false returns
- [ ] Log errors appropriately

### For Write Operations:

- [ ] Ensure parent directory exists
- [ ] Check available storage (if critical)
- [ ] Consider backup strategy for important files
- [ ] Validate data before writing
- [ ] Check write success return value

### For Read Operations:

- [ ] Check file exists first
- [ ] Check file size before reading large files
- [ ] Handle nil return (file not found)
- [ ] Validate data after reading
- [ ] Have fallback defaults ready

### For Directory Operations:

- [ ] Use correct folder functions (not file functions)
- [ ] Create parent directories first
- [ ] Empty folders before deletion
- [ ] Check existence before operations

### Performance:

- [ ] Minimize file I/O operations
- [ ] Batch multiple writes together
- [ ] Cache frequently read data
- [ ] Use binary format when possible
- [ ] Clean up temporary files

---

## Firmware Implementation Notes

All functions in `vmupro.file` are implemented by the VMU Pro firmware at runtime. The Lua definitions are stubs for IDE support and type checking. The actual implementation enforces:

- Path security (restricted to /sdcard/)
- File system access control
- Resource limits (file size, storage space)
- Error handling and validation

**Never attempt to override or redefine these functions in your Lua code.**

---

## Related Documentation

- [VMU Pro SDK Overview](/Users/thomasswift/vmupro-sdk/sdk/README.md)
- [vmupro.log API Rules](/Users/thomasswift/vmupro-sdk/docs/rules/api/log-rules.md)
- [vmupro.display API Rules](/Users/thomasswift/vmupro-sdk/docs/rules/api/display-rules.md)

---

**Version:** 1.0.0
**Last Updated:** 2025-01-04
**Author:** VMU Pro SDK Documentation Team
