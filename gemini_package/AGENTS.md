<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-23 -->

# Gemini Package - Sprite Generation Resources

## Overview

This directory contains resources for using Google Gemini to generate character sprite animations for the dungeon crawler game. It provides master prompts, quick start instructions, and reference images for AI-assisted sprite creation.

## Files

| File | Description |
|------|-------------|
| `GEMINI_MASTER_INSTRUCTIONS.md` | Complete prompt library for generating all sprite animations (walk, attack, death, hurt) |
| `QUICK_START.md` | Step-by-step guide for using Gemini to generate sprites |

## Subdirectories

| Directory | Description |
|-----------|-------------|
| `references/` | Reference sprite images used as style guides for AI generation |

## Purpose

This package enables sprite generation workflows using Google Gemini's image generation capabilities. The workflow:

1. Upload reference images from `references/` to Gemini
2. Use prompts from `GEMINI_MASTER_INSTRUCTIONS.md`
3. Generate new animation frames matching the existing art style
4. Post-process results (verify transparency, scale to 517px height)

## Character Details

**The Soldier/Warrior:**
- Medieval fantasy soldier in full plate armor
- Armor Color: Deep crimson/blood red
- Helmet: Full face helmet with vertical visor slit
- Weapon: Single-handed sword (straight blade, crossguard)
- Style: Clean digital art, slight stylization

## Sprite Categories to Generate

| Category | Code | Frames | Directions |
|----------|------|--------|------------|
| Walking | W01-W06 | 3 frames per direction | Front, Back |
| Attack | A01-A12 | 3 frames per direction | Front, Back, Left, Right |
| Death | D01-D12 | 3 frames per direction | Front, Back, Left, Right |
| Hurt | H01-H04 | 1 frame per direction | Front, Back, Left, Right |

## Technical Requirements for Generated Sprites

- Transparent PNG background (alpha channel)
- No ground shadows
- Light source from upper-left
- Full body visible (feet to head)
- Suitable for scaling to 517 pixels tall

## Related

- Parent project: `/mnt/r/inner-santctum/` (main game codebase)
- Output location: Generated sprites should be placed in `sprites/` folder at project root
