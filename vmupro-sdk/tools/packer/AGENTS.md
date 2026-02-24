# VMU Pro SDK - Packer Tools

<!-- Parent: ../AGENTS.md -->

**Generated:** 2026-02-23

---

## Purpose

The `packer/` directory contains Python-based tools for packaging VMU Pro Lua applications into deployable `.vmupack` binary format and uploading them to VMU Pro devices via serial connection.

**Key Capabilities:**
- Package Lua applications with icons, metadata, and resources into `.vmupack` format
- Upload packages to VMU Pro devices over serial (USB)
- Reset VMU Pro devices remotely
- Interactive serial monitoring for debugging

---

## File Manifest

| File | Purpose |
|------|---------|
| `packer.py` | Main packaging tool - converts Lua apps to `.vmupack` format |
| `send.py` | Serial deployment tool - uploads `.vmupack` files to devices |
| `requirements.txt` | Python dependencies (Pillow, pyserial) |
| `commandline_example.sh` | Linux/macOS usage example |
| `commandline_example.ps1` | Windows PowerShell usage example |
| `default_icon.bmp` | Default 76x76 BMP icon |

---

## packer.py - Application Packaging

### Purpose

Converts Lua application source files into the `.vmupack` binary format used by VMU Pro devices.

### Package Structure

The `.vmupack` format contains:

| Section | Description | Alignment |
|---------|-------------|-----------|
| Header | Magic bytes, version info, SDK version, section offsets | 512 bytes |
| Icon | 76x76 RGB565 encoded application icon | 512 bytes |
| Metadata | JSON metadata with app info and resource index | 512 bytes |
| Resources | All Lua files and assets | 512 bytes |
| Binding | Device-specific binding data (reserved) | 512 bytes |

### Header Format (128 bytes, padded to 512)

```
Offset  Size  Field
------  ----  -----
0x00    8     Magic: "VMUPACK\0"
0x08    1     vmuPackVersion (1)
0x09    1     targetDevice (0)
0x0A    1     productBindingVersion
0x0B    1     deviceBindingVersion
0x0C    1     sdkVersionMajor
0x0D    1     sdkVersionMinor
0x0E    1     sdkVersionPatch
0x0F    1     reserved
0x10    32    appName (null-terminated, max 31 chars)
0x30    4     appMode (1=applet, 2=fullscreen)
0x34    4     appEnv (0=native, 1=lua)
0x38    8     reserved
0x40    4     iconOffset
0x44    4     iconLength
0x48    4     metadataOffset
0x4C    4     metadataLength
0x50    4     resourceOffset
0x54    4     resourceLength
0x58    4     bindingOffset
0x5C    4     bindingLength
0x60    4     elfOffset (0 for Lua apps)
0x64    4     elfLength (0 for Lua apps)
0x68    16    reserved[4]
```

### Command Line Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `--projectdir` | Yes | Root folder containing the Lua application |
| `--appname` | Yes | Output filename (e.g., `my_app` produces `my_app.vmupack`) |
| `--meta` | Yes | Relative path to metadata.json from projectdir |
| `--icon` | Yes | Relative path to 76x76 BMP icon from projectdir |
| `--debug` | No | Set to `true` to save debug binaries to `vmupacker_debug/` |

### SDK Version

The packer automatically reads the SDK version from `VERSION` file in the SDK root (two directories up from packer.py).

### Usage Examples

**Linux/macOS:**
```bash
cd tools/packer
pip install -r requirements.txt

python3 packer.py \
    --projectdir "../../examples/minimal" \
    --appname "my_app" \
    --meta "metadata.json" \
    --icon "icon.bmp" \
    --debug "true"
```

**Windows PowerShell:**
```powershell
cd tools\packer
pip install -r requirements.txt

py .\packer.py `
    --projectdir "..\..\examples\minimal" `
    --appname "my_app" `
    --meta "metadata.json" `
    --icon "icon.bmp" `
    --debug "true"
```

### Key Functions

| Function | Line | Purpose |
|----------|------|---------|
| `ReadSDKVersion()` | 55 | Reads SDK version from VERSION file |
| `ValidatePath()` | 219 | Validates and resolves file paths |
| `ParseMetadata()` | 339 | Reads and validates metadata.json |
| `ValidateMetadata()` | 370 | Validates metadata fields |
| `ParseResources()` | 487 | Processes resource files and folders |
| `ScanFolderRecursive()` | 592 | Recursively finds files in folders |
| `AddIcon()` | 258 | Encodes BMP to RGB565 format |
| `AddBinding()` | 627 | Adds device binding (stub) |
| `CreateHeader()` | 724 | Builds final .vmupack binary |
| `PadByteArray()` | 643 | Pads data to specified boundary |

### Resource Processing

The packer supports both individual files and entire folders in the `resources` array:

```json
{
  "resources": [
    "app.lua",
    "libraries/",
    "assets/sprites.bmp"
  ]
}
```

- **Files**: Added directly with relative path preserved
- **Folders**: Recursively scanned via `ScanFolderRecursive()`, all files added with relative paths
- **Alignment**: Each resource is padded to 512-byte boundaries for faster SD card access

### Debug Output

With `--debug true`, the packer creates a `vmupacker_debug/` folder containing:
- `icon.bin` - Raw encoded icon data
- `resources.bin` - Combined resource blob
- `resources.json` - Resource index with offsets and sizes

---

## send.py - Serial Deployment

### Purpose

Uploads `.vmupack` files to VMU Pro devices over serial connection and provides interactive debugging.

### Features

- Chunked file transfer (16KB chunks)
- Auto-execution of uploaded applications
- Interactive 2-way serial monitor
- Device reset capability
- COM port persistence (saved to `comport.txt`)

### Command Line Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `--func` | Yes | Function: `send` or `reset` |
| `--localfile` | For `send` | Local `.vmupack` file path |
| `--remotefile` | For `send` | Destination path on VMU Pro SD card |
| `--comport` | No* | COM port (e.g., `COM3`, `/dev/ttyUSB0`) |
| `--exec` | No | Execute application after upload (flag) |
| `--debug` | No | Enable verbose debug output (flag) |
| `--monitor` | No | Enable 2-way serial monitor (flag) |

*If not provided, COM port is read from `comport.txt` or prompted interactively.

### Serial Protocol

The upload uses a simple command-response protocol:

| Command | Direction | Description |
|---------|-----------|-------------|
| `X` | PC -> Device | Trigger SIO monitor mode |
| `SEND_BIN` | PC -> Device | Initiate file transfer |
| `REQ_SIZE` | Device -> PC | Request file size |
| `[4 bytes]` | PC -> Device | UInt32LE file size |
| `REQ_NAME` | Device -> PC | Request filename |
| `[filename\0]` | PC -> Device | Null-terminated filename |
| `REQ_DATA` | Device -> PC | Ready to receive data |
| `[chunks]` | PC -> Device | File data in 16KB chunks |
| `MOREDATA` | Device -> PC | Request next chunk |
| `ASK_EXEC` | Device -> PC | Ask if should execute |
| `[4 bytes]` | PC -> Device | 1=execute, 0=don't |

### Baud Rates

- **Upload**: 921600 baud (fast transfer)
- **Reset**: 115200 baud (standard)

### Usage Examples

**Upload and execute:**
```bash
python3 send.py \
    --func send \
    --localfile my_app.vmupack \
    --remotefile apps/my_app.vmupack \
    --comport COM3 \
    --exec \
    --monitor
```

**Upload only (no execution):**
```bash
python3 send.py \
    --func send \
    --localfile my_app.vmupack \
    --remotefile apps/my_app.vmupack \
    --comport COM3
```

**Reset device:**
```bash
python3 send.py --func reset --comport COM3
```

### Key Functions

| Function | Line | Purpose |
|----------|------|---------|
| `SendFile()` | 396 | Main upload workflow |
| `ResetVMUPro()` | 297 | Hardware reset via DTR/RTS |
| `WriteBytesChunked()` | 231 | Chunked file transfer (16KB chunks) |
| `WaitForResponse()` | 199 | Protocol synchronization |
| `Monitor2Way()` | 93 | Interactive serial monitor |
| `CheckComPort()` | 366 | COM port resolution (arg > file > prompt) |
| `AddToBuffer()` | 76 | FIFO buffer for command detection |

### Serial Monitor

With `--monitor` flag, after upload completes:
- Displays all output from VMU Pro
- Sends keystrokes to the device
- Press ESC or Ctrl+C to exit

---

## Dependencies

### Python Requirements

```
pillow    # Image processing for icon encoding
pyserial  # Serial communication
```

Install with:
```bash
pip install -r requirements.txt
```

### Python Version

- **Minimum**: Python 3.6+
- **Recommended**: Python 3.10.x (ESP IDF compatible)

---

## Error Handling

### Common Issues

| Error | Cause | Solution |
|-------|-------|----------|
| "VERSION file not found" | SDK VERSION file missing | Ensure running from correct directory |
| "projectdir doesn't exist" | Invalid project path | Use absolute or correct relative path |
| "expecting a 76x76px icon" | Wrong icon dimensions | Resize icon to exactly 76x76 pixels |
| "Serial error" | COM port in use | Close other applications using the port |
| "FILE_ERR" from device | Invalid remote path | Use valid SD card path (e.g., `apps/`) |
| "UNK_CMD!" from device | Outdated firmware | Update VMU Pro firmware |

### Debug Tips

1. Use `--debug true` with packer to inspect generated sections
2. Use `--debug` flag with send.py to see raw protocol messages
3. Check `comport.txt` if COM port issues occur
4. Ensure no other terminal is connected to the COM port

---

## For AI Agents

### Common Tasks

**Package an application:**
```bash
python3 tools/packer/packer.py \
    --projectdir path/to/app \
    --appname "app_name" \
    --meta metadata.json \
    --icon icon.bmp
```

**Deploy to device:**
```bash
python3 tools/packer/send.py \
    --func send \
    --localfile app_name.vmupack \
    --remotefile apps/app_name.vmupack \
    --comport COM3 \
    --exec
```

**Full workflow:**
1. Navigate to `tools/packer/`
2. Install dependencies: `pip install -r requirements.txt`
3. Run packer.py with appropriate arguments
4. Run send.py with `--exec` to upload and run

### Metadata JSON Schema

```json
{
  "metadata_version": 1,
  "app_name": "My App",
  "app_author": "Author Name",
  "app_version": "1.0.0",
  "app_entry_point": "main.lua",
  "app_mode": 1,
  "app_environment": "lua",
  "icon_transparency": false,
  "resources": [
    "main.lua",
    "assets/"
  ]
}
```

### Output File Location

The `.vmupack` file is generated in the project directory:
```
{projectdir}/{appname}.vmupack
```

---

## See Also

- `../AGENTS.md` - Parent tools documentation
- `../../docs/tools/packer.md` - Detailed packer documentation
- `../../examples/minimal/` - Example application structure
