# Nested Example Pages - AGENTS.md

<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-17 -->

## Purpose

This directory contains all 39 test pages that demonstrate the comprehensive capabilities of the VMU Pro Lua SDK. Each page is a self-contained module that tests specific SDK features, from basic graphics operations to advanced system functions. The pages collectively serve as both a learning resource and a validation suite for the SDK.

## Key Files

| File | Purpose | Test Category |
|------|---------|--------------|
| `page1.lua` | Basic graphics: lines and shapes | Graphics |
| `page2.lua` | Basic shapes: rectangles and filled rectangles | Graphics |
| `page3.lua` | Basic shapes: circles and ellipses | Graphics |
| `page4.lua` | Text rendering with fonts | Text |
| `page5.lua` | Graphics clipping and masks | Advanced Graphics |
| `page6.lua` | Graphics transformations and scaling | Advanced Graphics |
| `page7.lua` | Drawing modes and blend modes | Advanced Graphics |
| `page8.lua` | Advanced graphics operations | Advanced Graphics |
| `page9.lua` | Sprite loading and basic rendering | Sprites |
| `page10.lua` | Sprite animation and frame management | Sprites |
| `page11.lua` | Sprite collision and overlap detection | Sprites |
| `page12.lua` | Sprite transformations and effects | Sprites |
| `page13.lua` | Button input handling | Input |
| `page14.lua` | Directional pad input | Input |
| `page15.lua` | Complex input combinations | Input |
| `page16.lua` | Basic audio playback | Audio |
| `page17.lua` | Synth operations and instruments | Audio |
| `page18.lua` | Audio sequences and timing | Audio |
| `page19.lua` | File reading operations | File Operations |
| `page20.lua` | File writing operations | File Operations |
| `page21.lua` | File management and operations | File Operations |
| `page22.lua` | Double buffering basics | Double Buffering |
| `page23.lua` | Advanced double buffering techniques | Double Buffering |
| `page24.lua` | Double buffering with animations | Double Buffering |
| `page25.lua` | System information and state | System Functions |
| `page26.lua` | System timing and clocks | System Functions |
| `page27.lua` | System configuration and settings | System Functions |
| `page28.lua` | Debug output and logging | Debug Tools |
| `page29.lua` | Performance monitoring | Debug Tools |
| `page30.lua` | Error handling and diagnostics | Debug Tools |
| `page31.lua` | Advanced sprite techniques | Advanced Features |
| `page32.lua` | Complex audio mixing | Advanced Features |
| `page33.lua` | File streaming operations | Advanced Features |
| `page34.lua` | Memory management | Advanced Features |
| `page35.lua` | Input combination patterns | Advanced Features |
| `page36.lua` | Edge case handling | Advanced Features |
| `page37.lua` | Performance optimization | Advanced Features |
| `page38.lua` | Integration testing | Advanced Features |
| `page39.lua` | Complete feature demonstration | Advanced Features |

## Test Organization

### Basic Graphics (Pages 1-3)
- Line drawing operations
- Rectangle rendering (filled and outlined)
- Circle and ellipse drawing
- Basic shape combinations

### Text Rendering (Page 4)
- Font loading and display
- Text positioning and alignment
- Text formatting options

### Advanced Graphics (Pages 5-8)
- Clipping regions and masks
- Transformations (scale, rotate)
- Drawing modes and blending
- Complex shape rendering

### Sprites & Animation (Pages 9-12)
- Sprite loading from files
- Animation frame management
- Collision detection
- Sprite effects

### Input Handling (Pages 13-15)
- Button state detection
- Directional pad input
- Complex input combinations

### Audio (Pages 16-18)
- WAV file playback
- Synth operations
- Instrument handling
- Sequence timing

### File Operations (Pages 19-21)
- Reading files
- Writing files
- File management

### Double Buffering (Pages 22-24)
- Basic double buffering
- Animation with buffering
- Performance optimization

### System Functions (Pages 25-27)
- System information
- Timing operations
- Configuration

### Debug Tools (Pages 28-30)
- Debug output
- Performance monitoring
- Error handling

### Advanced Features (Pages 31-39)
- Complex integration patterns
- Performance optimization
- Edge case handling
- Full feature demonstration

## Navigation System

All pages share a common navigation pattern:
- **Page Number Display**: Shows current page and total (e.g., "Page 1/39")
- **Left/Right Arrow Controls**: Navigate between pages
- **Page Initialization**: Each page implements an `init()` function for setup
- **Page Update**: Each page implements an `update()` function for rendering

## Import Structure

All pages are imported in the main `app.lua` file using the SDK's import system:

```lua
import "pages/page1"
import "pages/page2"
-- ... all pages
```

## Dependencies

- **Libraries**: Depends on `../libraries/` for shared utilities
- **Assets**: Depends on `../assets/` for audio and sprite files
- **SDK**: Requires all VMU Pro API modules
- **Navigation**: Managed by `../app.lua` main application

## File Management

Each page is a self-contained module that:
- Initializes its own resources
- Handles its own rendering
- Cleans up properly
- Demonstrates specific SDK features
- Provides clear visual feedback