# GPT-5-CODEX-MAX-REASONING Feedback

## Findings (ordered by severity)

1. **[HIGH] Sample-audio API is still used in gameplay and title paths despite project crash constraints**  
   Evidence: `app_full.lua:2697`, `app_full.lua:2705`, `app_full.lua:2713`, `app_full.lua:2721`, `app_full.lua:2729`, `app_full.lua:2737`, `app_full.lua:2766`, `app_full.lua:2769`, `app_full.lua:7178`, `app_full.lua:7190`  
   Why it matters: repo guidance says sample playback is a VMU Pro crash risk; these calls are active and several playback calls are not wrapped in `pcall`.

2. **[HIGH] `metadata_level1.json` / `metadata_level2.json` are incompatible with the current entrypoint layout**  
   Evidence: `app.lua:8` imports `app_full`; level metadata files do not include `app_full.lua` (no match for `app_full.lua` in `metadata_level1.json` or `metadata_level2.json`).  
   Why it matters: level-specific builds can boot the wrapper and fail to import runtime code, causing non-functional builds.

3. **[HIGH] Level metadata sound lists do not include the sounds actually referenced by code**  
   Evidence: code references `sounds/Intro_45sec`, `sounds/arg_death1`, `sounds/grunt`, `sounds/inner_sanctum_44k1_adpcm_stereo`, `sounds/sword_miss`, `sounds/sword_swing_connect`, `sounds/win_level`, `sounds/yah` (from `app_full.lua`), while level metadata only lists `sounds/sword_swoosh.wav` (`metadata_level1.json:70`, `metadata_level2.json:70`).  
   Why it matters: if built from level metadata, audio resources used at runtime are absent.

4. **[MEDIUM] Data-layer imports are attempted but data modules are not packaged in `metadata.json`**  
   Evidence: imports attempted in `app_full.lua:367` through `app_full.lua:374`; `metadata.json` includes `app_full.lua` and `api/text.lua` but no `data/*.lua` entries.  
   Why it matters: expansion/data features silently fall back to internal defaults, making behavior dependent on packaging rather than code intent.

5. **[MEDIUM] Audio update loop does not gate on active audio state**  
   Evidence: `app_full.lua:6486` repeatedly calls `vmupro.sound.update()` based only on accumulator thresholds.  
   Why it matters: avoidable CPU work during silent periods can hurt frame stability.

6. **[LOW] Documentation and code are out of sync on audio architecture**  
   Evidence: synth-only claim in `README.md` and `AGENTS.md`; active sample API usage in `app_full.lua` paths above.  
   Why it matters: contributors may make incorrect optimization decisions from stale docs.

## Confirmed Good Checks

- No `math.atan2` usage detected in project Lua files.  
- No `math.random` usage detected in project Lua files.  
- `safeAtan2` exists and is used in core AI direction paths (`app_full.lua:3017`, `app_full.lua:3070`, `app_full.lua:3096`, `app_full.lua:3141`).

## Evidence List (commands run)

- `rg -n "math\.random|math\.atan2\(" app_full.lua app.lua api data/*.lua`
- `rg -n "vmupro\.sound\.sample\.new\(|startListenMode\(|exitListenMode\(" app_full.lua`
- `rg -n "app_full\.lua|api/text\.lua|data/classes\.lua|sounds/Intro_45sec\.wav|sounds/grunt\.wav|sounds/sword_swoosh\.wav" metadata*.json`
- Resource diff (code sound refs vs level metadata refs) via `comm` on extracted lists.

## Impact Map

- Direct paths: `app.lua` -> `app_full.lua` boot/import; `app_full.lua` -> audio load/play/update; `metadata*.json` -> packaged resource set.
- Indirect effects: build profile choice (`metadata.json` vs `metadata_level*.json`) changes runtime behavior and can disable features or break boot/audio.

## Risk Notes + Mitigations

- Risk: runtime instability on hardware from sample API usage.  
  Mitigation: migrate critical SFX/music to synth/sequence path or isolate sample usage behind a hard feature flag per hardware target.
- Risk: broken level-specific package builds.  
  Mitigation: add CI/resource validation that checks entrypoint imports and all literal asset refs are included in selected metadata.
- Risk: silent fallback behavior hides missing modules.  
  Mitigation: elevate import failure to explicit on-screen warning in debug builds.

## Validation Plan

- Build and boot with each metadata file: `metadata.json`, `metadata_level1.json`, `metadata_level2.json`.
- On hardware, verify title -> gameplay -> combat -> level transition audio paths.
- Add a pre-pack validation script that checks:
  1. all `import "..."` dependencies needed at runtime are present in metadata,
  2. all literal `sounds/...` and `sprites/...` refs are present,
  3. no stale-only assets in metadata unless intentionally optional.

## Open Questions

- Are `metadata_level1.json` and `metadata_level2.json` still intended build targets, or historical artifacts?S