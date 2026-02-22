<!-- Parent: ../AGENTS.md -->
# VMU-Pro SDK Tools

**Generated:** 2026-02-17

## Purpose

Build tools and utilities for VMU-Pro game development. This directory contains command-line tools for packaging, deploying, and managing VMU-Pro applications.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `packer/` | Game packaging and deployment tool for creating .VMS files and sending to VMU |

## Overview

The tools directory provides essential utilities for the VMU-Pro development workflow:

- **Packager**: Converts game directories into `.VMS` format files compatible with Dreamcast VMUs
- **Deployment**: Automated upload of packaged games to physical or emulated VMU devices
- **CLI Interface**: Cross-platform command-line scripts (PowerShell and Bash) for tool integration

## Primary Tools

### packer.py
Main packaging tool that:
- Compresses game assets and code into VMS format
- Generates metadata files required by VMU-Pro runtime
- Creates properly formatted `.VMS` files for distribution

### send.py
Deployment utility that:
- Transfers `.VMS` files to connected VMU devices
- Supports both physical hardware and emulators
- Provides transfer status and error handling

## Usage

See individual tool directories for detailed documentation and usage examples.
