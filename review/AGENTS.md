# Review Directory - AI Model Comparison Outputs

<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-17 -->

## Purpose

This directory contains comparative analysis outputs from different AI code review models (GPT-5-Codex and GPT-5-Codex-Max-Reasoning). These files represent automated code audit results, feedback reports, and annotated source code used for quality assurance and safety validation.

## Key Files

| File | Description | Purpose |
|------|-------------|---------|
| `gpt5_codex_feedback.md` | Feedback report from GPT-5-Codex model | Documents stability issues, performance patterns, and confirmed good practices |
| `gpt5_codex_max_reasoning_feedback.md` | Detailed feedback from GPT-5-Codex-Max-Reasoning model | Extended analysis with severity levels, evidence lists, impact maps, and validation plans |
| `gpt5_codex_max_reasoning_feedback.annotated.txt` | Annotated version of feedback report | Line-by-line model annotations on feedback content |

## Subdirectories

| Directory | Contents | Purpose |
|-----------|----------|---------|
| `gpt5_codex_annotated/` | Per-line annotated source files | Each line tagged with `[GPT-5-Codex]` prefix for model attribution and traceability |
| `gpt5_codex_max_reasoning_annotated_all/` | Extended annotated source files | Comprehensive line-by-line analysis with `[GPT-5-CODEX-MAX-REASONING]` tags |
| `tmp/` | Temporary analysis artifacts | Supporting files such as sound reference lists, metadata comparisons |

## Critical Findings Summary

### High Severity Issues (from both models)

1. **Sample-based audio API usage** - Despite project constraints labeling sample audio as crash risk, code still uses `vmupro.sound.sample.new()` in multiple locations
2. **Metadata mismatch** - Level-specific metadata files (`metadata_level1.json`, `metadata_level2.json`) don't reference `app_full.lua` entrypoint
3. **Missing sound resources** - Code references sounds not included in level metadata sound lists

### Medium Severity Issues

4. **Audio update loop optimization** - `vmupro.sound.update()` called unconditionally without active audio state check
5. **Data module imports** - Data layer imports attempted but modules not packaged in metadata

### Confirmed Good Patterns

- `safeAtan2` properly implemented and used for enemy direction logic
- No `math.random` usage (deterministic alternatives present)
- Raycast step caps implemented for performance safety
- Extensive performance instrumentation (`PERF_MONITOR_*` system)

## For AI Agents

### When Working in This Directory

1. **Reference Purpose**: Use these files to understand known issues, validation results, and model comparison insights
2. **Do Not Modify**: Annotated files are audit artifacts - changes invalidate traceability
3. **Update Strategy**: When re-running analysis, create new timestamped subdirectories rather than overwriting
4. **Evidence Tracking**: Each finding includes file:line references for verification

### Comparison Notes

- **GPT-5-Codex**: Concise feedback, focused on code patterns and performance
- **GPT-5-Codex-Max-Reasoning**: Detailed analysis with severity levels, evidence lists, impact mapping, risk mitigation strategies, and validation plans

### Integration with Main Codebase

These review outputs directly reference:
- `/mnt/r/inner-santctum/app.lua` - Wrapper entrypoint
- `/mnt/r/inner-santctum/app_full.lua` - Main game logic
- `/mnt/r/inner-santctum/api/*.lua` - API layer files
- `/mnt/r/inner-santctum/data/*.lua` - Data modules
- `/mnt/r/inner-santctum/metadata*.json` - Build metadata files

### Validation Commands Used

```bash
# Audio API usage check
rg -n "vmupro\.sound\.sample\.new\(" app_full.lua

# Math function safety check
rg -n "math\.random|math\.atan2\(" app_full.lua

# Metadata reference check
rg -n "app_full\.lua|api/text\.lua|data/" metadata*.json

# Sound reference extraction
rg -o "sounds/[^\"]+" app_full.lua | sort -u
```

## Related Documentation

- Parent directory: `/mnt/r/inner-santctum/AGENTS.md`
- Main README: `/mnt/r/inner-santctum/README.md`
- SDK documentation: `/mnt/r/inner-santctum/vmupro-sdk/docs/`
