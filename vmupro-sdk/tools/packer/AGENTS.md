<!-- Parent: ../AGENTS.md -->

# Packer Tool

**Generated:** 2026-02-17

## Purpose

VMUPro package builder tool for creating `.vmupack` application packages. This Python-based toolchain packages Lua applications, resources, icons, and metadata into the binary format used by the VMUPro runtime.

## Key Files

| File | Purpose |
|------|---------|
| `packer.py` | Main packer script that creates `.vmupack` files from Lua applications |
| `send.py` | Serial communication tool for uploading packages to VMUPro devices |
| `commandline_example.sh` | Example shell script showing packer usage |
| `commandline_example.ps1` | Example PowerShell script showing packer usage |
| `requirements.txt` | Python dependencies (Pillow for image processing) |
| `default_icon.bmp` | Default 76x76 BMP icon for applications |
| `.gitignore` | Git ignore patterns (excludes build artifacts, venv, cache) |

## Core Functionality

### packer.py
The primary packaging tool that:
- Reads SDK version from `VERSION` file
- Validates project structure and paths
- Parses `metadata.json` for application metadata
- Converts 76x76 BMP icons to RGB565 format
- Recursively scans resource directories
- Packages Lua scripts and resources into `.vmupack` binary format
- Creates debug output when `--debug` flag is enabled

**Key Parameters:**
- `--projectdir`: Root folder containing the Lua application
- `--appname`: Output filename (without `.vmupack` extension)
- `--meta`: Relative path to `metadata.json`
- `--icon`: Relative path to 76x76 BMP icon
- `--debug`: Enable debug binary output

### send.py
Serial upload utility that:
- Transfers `.vmupack` files to VMUPro over serial connection
- Supports chunked file transfer (16KB chunks)
- Provides device reset capability via RTS/DTR control
- Offers optional auto-execution after upload
- Includes 2-way serial monitor for debugging
- Maintains COM port configuration in `comport.txt`

**Key Parameters:**
- `--func send`: Upload file operation
- `--func reset`: Reset device operation
- `--localfile`: Path to `.vmupack` on PC
- `--remotefile`: Destination path on VMUPro SD card
- `--comport`: Serial port (COM3, /dev/ttyUSB0, etc.)
- `--exec`: Auto-execute after upload
- `--monitor`: Enable 2-way serial console
- `--debug`: Extra debug output

## Package Format

The `.vmupack` format consists of:
1. **Header** (512 bytes padded): Magic, version info, SDK version, app name, section offsets
2. **Icon** (512 bytes padded): RGB565 encoded 76x76 bitmap
3. **Metadata** (512 bytes padded): JSON metadata string
4. **Binding** (512 bytes padded): Device binding data (currently stub)
5. **Resources** (512 bytes padded): All Lua scripts and assets with file index

All sections are padded to 512-byte boundaries for optimal SD card performance.

## Dependencies

- Python 3.6+
- Pillow (PIL) for image processing
- pyserial for serial communication (send.py only)

## Usage Example

```bash
# Install dependencies
pip install -r requirements.txt

# Package a Lua application
python3 packer.py \
    --projectdir "../../examples/hello_world" \
    --appname "hello_world" \
    --meta "metadata.json" \
    --icon "icon.bmp"

# Upload to device
python3 send.py --func send \
    --localfile hello_world.vmupack \
    --remotefile apps/hello_world.vmupack \
    --comport COM3 \
    --exec
```

## Debug Output

When `--debug` is enabled, the packer creates a `vmupacker_debug/` directory containing:
- `icon.bin` - Raw icon data
- `resources.json` - Processed metadata with resource index
- `resources.bin` - Combined resource blob
