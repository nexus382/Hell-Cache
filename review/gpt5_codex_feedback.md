# GPT-5-Codex Feedback

## Findings

1. **[High] Sample-based audio is still active despite project safety constraints**  
   `app_full.lua:2697`, `app_full.lua:2705`, `app_full.lua:2713`, `app_full.lua:2721`, `app_full.lua:2729`, `app_full.lua:2737`, `app_full.lua:2766`, `app_full.lua:2769`  
   The game still constructs audio via `vmupro.sound.sample.new(...)`. Your repo instructions call out sample audio crash risk on VMU Pro and recommend synth-only playback. This is the highest-risk stability issue currently visible.

2. **[Medium] Audio update loop runs unconditionally once step threshold is reached**  
   `app_full.lua:6486`  
   `vmupro.sound.update()` is called per audio step without checking whether any active voice/sample is playing. This can waste CPU when silent and contributes to frame pressure.

3. **[Low] Some `pairs()` usages are in potentially frequent code paths**  
   `app_full.lua:2189`, `app_full.lua:2282`, `app_full.lua:2626`  
   For sequential arrays, numeric loops are faster than `pairs()`. These are not all hot loops, so impact is likely small, but worth tightening if you are chasing perf headroom.

4. **[Low] `table.insert()` used in effect creation path**  
   `app_full.lua:3262`, `app_full.lua:3268`  
   Replacing with direct index assignment (`t[#t+1] = value`) reduces function-call overhead. This is micro-optimization only.

## Confirmed Good Patterns

- `safeAtan2` is implemented and used for enemy direction logic: `app_full.lua:3017`, `app_full.lua:3070`, `app_full.lua:3096`, `app_full.lua:3141`.
- No `math.random` usage detected in game logic files; deterministic alternatives are present (`data/loot_tables.lua:2`, `app_full.lua:2046`).
- Raycast step cap is present (`app_full.lua:5439` to `app_full.lua:5442`) and perf instrumentation is extensive in the `PERF_MONITOR_*` system.

## Output Artifacts

- Per-line annotated files (model tag on every line): `review/gpt5_codex_annotated/`
- This report: `review/gpt5_codex_feedback.md`
