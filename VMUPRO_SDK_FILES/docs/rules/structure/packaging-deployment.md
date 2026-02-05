# VMU Pro SDK - Packaging and Deployment Guide

This guide covers the complete workflow for packaging and deploying VMU Pro LUA applications using the SDK's packer tools.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Tool Overview](#tool-overview)
- [Icon Requirements](#icon-requirements)
- [Using packer.py](#using-packerpy)
- [Using send.py](#using-sendpy)
- [Complete Workflow](#complete-workflow)
- [Debug Mode](#debug-mode)
- [Common Errors and Solutions](#common-errors-and-solutions)
- [Example Commands](#example-commands)

---

## Prerequisites

### Python Requirements
- Python 3.6 or later (recommended: Python 3.10+)
- Required packages:
  ```bash
  pip install -r tools/packer/requirements.txt
  ```
  This installs:
  - `pillow` - For icon processing and RGB565 encoding

### Hardware Requirements
- VMU Pro device
- USB serial connection (ESP Prog or compatible)
- SD card installed in VMU Pro

### File Structure
Your project should contain:
- `metadata.json` - Application metadata
- `icon.bmp` - 76x76 BMP icon
- LUA scripts and resources
- Entry point LUA file

---

## Tool Overview

### packer.py
**Purpose**: Packages LUA applications with resources and icons into `.vmupack` format

**Key Features**:
- Reads SDK version from `VERSION` file (at SDK root)
- Validates metadata.json format
- Encodes 76x76 BMP icons to RGB565 format
- Recursively scans folders for resources
- Pads sections to 512-byte boundaries for faster SD access
- Generates debug output files (optional)

### send.py
**Purpose**: Uploads `.vmupack` files to VMU Pro over serial connection

**Key Features**:
- Chunked file transfer (16KB chunks)
- Device reset capability
- Auto-execution of uploaded apps
- 2-way serial monitor for debugging
- Progress tracking
- COM port auto-save

---

## Icon Requirements

### Specifications
- **Dimensions**: Exactly 76x76 pixels
- **Format**: BMP (bitmap)
- **Color Encoding**: RGB565 (16-bit)
  - Red: 5 bits (RGB[0] >> 3)
  - Green: 6 bits (RGB[1] >> 2)
  - Blue: 5 bits (RGB[2] >> 3)

### Conversion Process
The packer automatically converts 24-bit RGB BMP to RGB565:
```python
# Automatic conversion in packer.py:
red = (rgb[0] >> 3) & 0x1F    # 5 bits for red
green = (rgb[1] >> 2) & 0x3F  # 6 bits for green
blue = (rgb[2] >> 3) & 0x1F   # 5 bits for blue
pixVal = (red << 11) | (green << 5) | blue
```

### Transparency
- Controlled via `icon_transparency` field in metadata.json
- Set to `true` or `false`

### Default Icon
A default icon is provided at: `/tools/packer/default_icon.bmp`

---

## Using packer.py

### Command-Line Arguments

| Argument | Required | Description | Example |
|----------|----------|-------------|---------|
| `--projectdir` | Yes | Root folder containing your LUA app | `../../examples/minimal` |
| `--appname` | Yes | Application name for output file | `hello_world` (creates `hello_world.vmupack`) |
| `--meta` | Yes | Relative path to metadata.json from projectdir | `metadata.json` |
| `--icon` | Yes | Relative path to 76x76 BMP icon from projectdir | `icon.bmp` |
| `--debug` | No | Save raw binary sections to debug folder | `true` or omit |

### Path Resolution
- `--projectdir` can be **relative** or **absolute**
- All other paths (`--meta`, `--icon`) are **relative to projectdir**
- Example paths:
  ```bash
  # Relative projectdir
  --projectdir "../../examples/minimal"

  # Absolute projectdir (Windows)
  --projectdir "C:\Users\dev\vmupro-sdk\examples\minimal"

  # Absolute projectdir (macOS/Linux)
  --projectdir "/Users/dev/vmupro-sdk/examples/minimal"
  ```

### Basic Usage

```bash
# Navigate to packer directory
cd tools/packer

# Run packer
python3 packer.py \
    --projectdir "../../examples/minimal" \
    --appname "minimal_app" \
    --meta "metadata.json" \
    --icon "icon.bmp"
```

### Output Files

**Success**:
- Creates `{appname}.vmupack` in the project directory
- Example: `minimal_app.vmupack`

**With Debug Mode**:
- Creates `vmupacker_debug/` folder with:
  - `icon.bin` - Encoded icon data
  - `resources.bin` - All resources blob
  - `resources.json` - Enhanced metadata with offsets

### SDK Version Handling
The packer automatically:
1. Reads SDK version from `{SDK_ROOT}/VERSION` file
2. Parses version string (e.g., "1.0.5" → major=1, minor=0, patch=5)
3. Validates components are 0-255
4. Embeds version in `.vmupack` header at bytes 0x0C-0x0F

---

## Resource Packaging

### Resource Types Supported
The `resources` array in metadata.json can contain:
- Individual files
- Folders (recursively scanned)

### Folder Scanning
When a folder is specified in `resources`:
1. Packer recursively scans all subdirectories
2. Preserves relative path structure
3. All files are packed into single resource blob
4. Each file padded to 512-byte boundary

### Resource Index
New in current version - detailed resource index:
```json
"resource_index": [
    {
        "path": "scripts/main.lua",
        "offset": 0,
        "size": 1024,
        "padded_size": 1536
    }
]
```

### Example metadata.json
```json
{
    "metadata_version": 1,
    "app_name": "My App",
    "app_author": "Developer",
    "app_version": "1.0.0",
    "app_entry_point": "main.lua",
    "app_mode": 1,
    "app_environment": "lua",
    "icon_transparency": false,
    "resources": [
        "main.lua",
        "scripts/",
        "assets/images/"
    ]
}
```

---

## Using send.py

### Functions

#### 1. Send File (Upload and Deploy)

**Command**:
```bash
python send.py --func send \
    --localfile "app.vmupack" \
    --remotefile "apps/app.vmupack" \
    --comport "COM3" \
    --exec \
    --monitor
```

**Arguments**:

| Argument | Required | Description | Example |
|----------|----------|-------------|---------|
| `--func` | Yes | Function to execute | `send` |
| `--localfile` | Yes | Local .vmupack file path | `minimal_app.vmupack` |
| `--remotefile` | Yes | Remote path on SD card | `apps/minimal_app.vmupack` |
| `--comport` | No* | Serial port identifier | `COM3` (Windows), `/dev/cu.usbmodem101` (macOS) |
| `--exec` | No | Auto-execute after upload | Flag (no value) |
| `--debug` | No | Extra debug output | Flag (no value) |
| `--monitor` | No | 2-way serial console | Flag (no value) |

\* Auto-saved to `comport.txt` after first use

#### 2. Reset Device

**Command**:
```bash
python send.py --func reset --comport "COM3"
```

**Behavior**:
- Asserts RTS and DTR control lines
- Electrically resets ESP32 via serial
- Closes connection

---

## COM Port Configuration

### Windows
- Format: `COMx` (e.g., `COM3`, `COM18`)
- Find via Device Manager (`devmgmt.msc`)
  - Look under "Ports (COM & LPT)"
  - ESP devices usually show as "USB Serial Device"

### macOS
- Format: `/dev/cu.usbmodemXXX` or `/dev/tty.usbmodemXXX`
- Find via terminal:
  ```bash
  ls /dev/cu.*
  # or
  ls /dev/tty.*
  ```

### Linux
- Format: `/dev/ttyUSBx` or `/dev/ttyACMx`
- Find via terminal:
  ```bash
  ls /dev/tty*
  # or
  dmesg | grep tty
  ```

### Auto-Save Feature
On first run, COM port is saved to `comport.txt`:
- Automatically loaded on subsequent runs
- Override by providing `--comport` argument

---

## Complete Workflow

### Step-by-Step: Development to Deployment

#### 1. Prepare Your Project
```bash
my_project/
├── metadata.json
├── icon.bmp (76x76)
├── main.lua
├── scripts/
│   ├── utils.lua
│   └── game.lua
└── assets/
    └── images/
        └── sprite.bmp
```

#### 2. Validate metadata.json
Ensure all required fields are present:
```json
{
    "metadata_version": 1,
    "app_name": "My Game",
    "app_author": "YourName",
    "app_version": "1.0.0",
    "app_entry_point": "main.lua",
    "app_mode": 1,
    "app_environment": "lua",
    "icon_transparency": false,
    "resources": [
        "main.lua",
        "scripts/",
        "assets/"
    ]
}
```

#### 3. Package Application
```bash
cd tools/packer
python3 packer.py \
    --projectdir "../../my_project" \
    --appname "my_game" \
    --meta "metadata.json" \
    --icon "icon.bmp"
```

**Expected output**:
```
SDK version loaded: 1.0.5
Validating paths...
Loading metadata json...
Parsing metadata resources...
Loading icon...
Encoded icon from icon.bmp
Final binary size: 34,816 / 0x8800
Write file to: /path/to/my_project/my_game.vmupack
Exiting with code 0 (success!)
```

#### 4. Upload to VMU Pro
```bash
python send.py --func send \
    --localfile "../../my_project/my_game.vmupack" \
    --remotefile "apps/my_game.vmupack" \
    --comport "COM3" \
    --exec \
    --monitor
```

**Upload process**:
1. Triggers serial monitor mode
2. Sends `SEND_BIN` command
3. Sends file size
4. Sends remote filename
5. Transfers file in 16KB chunks
6. Executes app (if `--exec` flag used)
7. Opens 2-way console (if `--monitor` flag used)

#### 5. Monitor Output
With `--monitor` flag:
- View LUA print() statements
- Send keystrokes to app
- Press Ctrl+C or ESC to exit

---

## Debug Mode

### Enabling Debug Output

Add `--debug true` to packer command:
```bash
python3 packer.py \
    --projectdir "../../examples/minimal" \
    --appname "minimal_app" \
    --meta "metadata.json" \
    --icon "icon.bmp" \
    --debug true
```

### Debug Output Files

Created in `{projectdir}/vmupacker_debug/`:

1. **icon.bin**
   - Raw encoded icon data
   - RGB565 format
   - Size: ~11,584 bytes (76×76×2 bytes + header)

2. **resources.bin**
   - Combined resource blob
   - All files concatenated
   - 512-byte padding between files

3. **resources.json**
   - Enhanced metadata
   - Includes `resource_index` array
   - Shows offsets and sizes

### Debug Output Example
```
Section sizes:
  Header   : 64 / 0x40
  Icon     : 11584 / 0x2d40
  MetaData : 423 / 0x1a7
  Binding  : 16 / 0x10
  LUA Resources : 2048 / 0x800

Padded section sizes:
  Header   : 512 / 0x200
  Icon     : 12288 / 0x3000
  MetaData : 512 / 0x200
  Binding  : 512 / 0x200
  LUA Resources : 2048 / 0x800
```

---

## Common Errors and Solutions

### Packer Errors

#### Error: "VERSION file not found"
**Cause**: SDK VERSION file missing
**Solution**:
```bash
# Ensure SDK structure is intact
ls ../../VERSION  # Should exist at SDK root
```

#### Error: "expecting a 76x76px icon"
**Cause**: Icon dimensions incorrect
**Solution**:
- Use image editor to resize to exactly 76x76 pixels
- Save as BMP format
- Or use default icon: `tools/packer/default_icon.bmp`

#### Error: "Failed to parse key '...' from metadata.json"
**Cause**: Missing or invalid metadata field
**Solution**:
- Verify all required fields exist
- Check field types (strings, booleans, integers)
- Validate version format: "X.X.X"

#### Error: "This packer is for LUA applications only"
**Cause**: `app_mode` is not set to 1
**Solution**:
```json
{
    "app_mode": 1,  // Must be 1 for LUA apps
    "app_environment": "lua"
}
```

#### Error: "Resource ... is neither file nor folder"
**Cause**: Path in resources array doesn't exist
**Solution**:
- Verify file/folder exists relative to projectdir
- Check spelling and case sensitivity
- Use forward slashes in paths

### Send.py Errors

#### Error: "Error initing the serial port"
**Causes**:
1. COM port in use by another program
2. Incorrect COM port
3. Permissions issue (Linux/macOS)

**Solutions**:
```bash
# Windows: Close ESP-IDF monitor, Arduino IDE, etc.
# Linux: Add user to dialout group
sudo usermod -a -G dialout $USER
# Then logout/login

# macOS: Check permissions
ls -l /dev/cu.*
```

#### Error: "Error opening file"
**Cause**: .vmupack file not found
**Solution**:
- Verify path to .vmupack file
- Use absolute path if needed
- Check file wasn't deleted

#### Error: "UNK_CMD!" response
**Cause**: VMU Pro firmware doesn't recognize command
**Solution**:
- Update VMU Pro firmware to latest version
- Update SDK to latest version
- Ensure firmware and SDK versions are compatible

#### Error: "FILE_ERR" response
**Causes**:
1. SD card not inserted
2. SD card full
3. Invalid remote path
4. SD card corrupted

**Solutions**:
- Insert SD card
- Free up space on SD card
- Use valid path (e.g., "apps/myapp.vmupack")
- Reformat SD card (FAT32)

---

## Example Commands

### Scenario 1: Quick Development Cycle

**Package and upload with auto-execute**:
```bash
# In tools/packer directory
python3 packer.py \
    --projectdir "../../examples/minimal" \
    --appname "test" \
    --meta "metadata.json" \
    --icon "icon.bmp" && \
python send.py \
    --func send \
    --localfile "../../examples/minimal/test.vmupack" \
    --remotefile "apps/test.vmupack" \
    --exec \
    --monitor
```

### Scenario 2: Release Build with Debug

**Package with debug output**:
```bash
python3 packer.py \
    --projectdir "/Users/dev/my_game" \
    --appname "my_game_v1.0.0" \
    --meta "metadata.json" \
    --icon "icon.bmp" \
    --debug true
```

**Upload to specific location**:
```bash
python send.py \
    --func send \
    --localfile "/Users/dev/my_game/my_game_v1.0.0.vmupack" \
    --remotefile "releases/my_game_v1.0.0.vmupack" \
    --comport "/dev/cu.usbmodem101"
```

### Scenario 3: Reset and Test

**Reset device before upload**:
```bash
python send.py --func reset --comport "COM3"
sleep 2
python send.py \
    --func send \
    --localfile "app.vmupack" \
    --remotefile "apps/app.vmupack" \
    --exec \
    --monitor
```

### Scenario 4: Batch Processing (Shell Script)

**Create `build_and_deploy.sh`**:
```bash
#!/bin/bash

PROJECT_DIR="../../examples/minimal"
APP_NAME="minimal"
COM_PORT="/dev/cu.usbmodem101"

echo "Building $APP_NAME..."
python3 packer.py \
    --projectdir "$PROJECT_DIR" \
    --appname "$APP_NAME" \
    --meta "metadata.json" \
    --icon "icon.bmp"

if [ $? -eq 0 ]; then
    echo "Uploading to VMU Pro..."
    python send.py \
        --func send \
        --localfile "$PROJECT_DIR/$APP_NAME.vmupack" \
        --remotefile "apps/$APP_NAME.vmupack" \
        --comport "$COM_PORT" \
        --exec \
        --monitor
else
    echo "Build failed!"
    exit 1
fi
```

**Create `build_and_deploy.ps1` (PowerShell)**:
```powershell
$ProjectDir = "..\..\examples\minimal"
$AppName = "minimal"
$ComPort = "COM3"

Write-Host "Building $AppName..."
python packer.py `
    --projectdir $ProjectDir `
    --appname $AppName `
    --meta "metadata.json" `
    --icon "icon.bmp"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Uploading to VMU Pro..."
    python send.py `
        --func send `
        --localfile "$ProjectDir\$AppName.vmupack" `
        --remotefile "apps/$AppName.vmupack" `
        --comport $ComPort `
        --exec `
        --monitor
} else {
    Write-Host "Build failed!"
    exit 1
}
```

---

## Advanced Topics

### .vmupack File Structure

```
Offset  Size    Description
------  ------  -----------
0x000   8       Magic: "VMUPACK\0"
0x008   1       VMUPack version (1)
0x009   1       Target device (0)
0x00A   1       Product binding version
0x00B   1       Device binding version
0x00C   1       SDK version major
0x00D   1       SDK version minor
0x00E   1       SDK version patch
0x00F   1       Reserved
0x010   32      App name (null-padded)
0x030   4       App mode (1=applet, 2=fullscreen)
0x034   4       App environment (0=native, 1=LUA)
0x038   4       Reserved
0x03C   4       File size minus signature
0x040   4       Icon offset
0x044   4       Icon length
0x048   4       Metadata offset
0x04C   4       Metadata length
0x050   4       Resource offset
0x054   4       Resource length
0x058   4       Binding offset
0x05C   4       Binding length
0x060   4       ELF offset (0 for LUA)
0x064   4       ELF length (0 for LUA)
0x068   16      Reserved
...     ...     (Padded to 512 bytes)
0x200   ...     Icon section
...     ...     Metadata section
...     ...     Resources section
...     ...     Binding section
```

### Serial Protocol

**Upload sequence**:
1. PC → VMU: `X` (trigger serial monitor)
2. PC → VMU: `SEND_BIN`
3. VMU → PC: `REQ_SIZE` or `UNK_CMD!`
4. PC → VMU: File size (uint32_t, little-endian)
5. VMU → PC: `REQ_NAME`
6. PC → VMU: Filename (null-terminated ASCII)
7. VMU → PC: `REQ_DATA` or `FILE_ERR`
8. PC → VMU: File data (16KB chunks)
9. VMU → PC: `MOREDATA` (after each chunk)
10. VMU → PC: `ASK_EXEC`
11. PC → VMU: Execute flag (uint32_t: 1=yes, 0=no)

**Baud rate**: 921600

### Resource Optimization

**Padding strategy**:
- All sections padded to 512-byte boundaries
- Faster SD card access (aligned to SD block size)
- Trade-off: Slightly larger file size for better performance

**Resource ordering**:
- Entry point file should be first in resources array
- Frequently accessed files should be early
- Large assets (images, audio) can be last

---

## Best Practices

1. **Version Control**
   - Use semantic versioning (X.Y.Z)
   - Update `app_version` in metadata.json for each release
   - Match SDK version requirements

2. **Icon Design**
   - Use high contrast for better visibility
   - Test on actual VMU Pro screen
   - Consider transparency for overlays

3. **Resource Management**
   - Organize resources in logical folders
   - Use clear, consistent naming
   - Avoid unnecessary large files

4. **Testing**
   - Always test with `--monitor` flag during development
   - Check for LUA runtime errors in serial output
   - Verify resource loading with debug output

5. **Deployment**
   - Use release naming scheme: `appname_vX.Y.Z.vmupack`
   - Document required SD card path structure
   - Provide clear installation instructions

---

## Troubleshooting Checklist

Before reporting issues, verify:

- [ ] Python 3.6+ installed
- [ ] Pillow package installed (`pip install pillow`)
- [ ] SDK VERSION file exists
- [ ] Icon is exactly 76x76 BMP
- [ ] metadata.json is valid JSON
- [ ] All resource paths exist
- [ ] COM port is correct and not in use
- [ ] VMU Pro is powered on
- [ ] SD card is inserted and formatted (FAT32)
- [ ] Firmware is up to date

---

## Related Documentation

- [Metadata Schema](./metadata-schema.md)
- [LUA API Reference](../../api/lua-reference.md)
- [VMU Pro Hardware Guide](../hardware/vmupro-guide.md)
- [SDK Installation](../../setup/installation.md)

---

**Last Updated**: 2026-01-04
**SDK Version**: 1.0.5+
**Packer Version**: 2.0.0+
