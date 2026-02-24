# MUST GENERATE - Media Production Tracker

Last updated: Build 181
Scope: media needed for the live gameplay systems now in code, plus next-phase assets that will unblock story/economy work.

## Global Specs (Use For Everything)
- Sprite format: `PNG` with transparency (alpha), no baked background.
- Audio format: `WAV` (44.1kHz; mono for SFX, stereo allowed for music).
- Resolution target: keep source sprites modest (usually `32-128px` range) because runtime scales them.
- Naming rule: filenames must match code paths exactly (case-sensitive on some environments).
- Path rule: place files under `sprites/` or `sounds/` and add them to `metadata.json`.

## P0 - Required By Current Code (Highest Priority)

### First-Person Combat Visuals
| Priority | File Path | Context (Where Used) | Recommended Canvas | Orientation / Fit Notes |
|---|---|---|---|---|
| P0 | `sprites/bow_idle.png` | First-person ranged overlay, resting stage before draw | `96x192` (1:2) | Bow sits on right side of screen, facing toward center-left. Keep grip near lower-right quadrant. |
| P0 | `sprites/bow_drawn.png` | First-person ranged overlay while charging shot | `96x192` (1:2) | Same framing as idle sprite so animation does not jump. String visibly pulled back. |
| P0 | `sprites/arrow.png` | Projectile flying in world (screen-centered depth view) | `32x64` (1:2) | Tip should point up (forward in current projection). Keep centered with transparent margins. |
| P0 | `sprites/STAFF.png` | First-person magic weapon overlay | `96x192` (1:2) | Right-side held weapon, slight inward angle toward center. Keep top ornament visible. |
| P0 | `sprites/projectile_magic.png` | Magic projectile in world (replaces explosion fallback) | `32x32` | High-contrast bolt core + glow edge; readable at very small scale. |
| P0 | `sprites/projectile_impact.png` | Projectile hit flash in world | `48x48` | Compact burst with clean silhouette; avoid full-frame haze. |

Current fallback behavior:
- If `projectile_magic` is missing, code uses `sprites/explosion.png`.
- If `projectile_impact` is missing, code reuses magic projectile.

### Live Gameplay Audio
| Priority | File Path | Context (Where Used) | Target Length | Mix Notes |
|---|---|---|---|---|
| P0 | `sounds/grunt.wav` | Enemy aggro reaction | `0.2-0.5s` | Mid presence, avoid heavy bass mud. |
| P0 | `sounds/sword_swing_connect.wav` | Melee hit connect (enemy/chest) | `0.1-0.3s` | Strong transient, short tail. |
| P0 | `sounds/sword_miss.wav` | Melee miss | `0.1-0.25s` | Lighter than connect for clarity. |
| P0 | `sounds/yah.wav` | Enemy attack vocal | `0.2-0.5s` | Keep clear at low speaker volume. |
| P0 | `sounds/win_level.wav` | Level clear stinger | `0.5-1.5s` | Readable, not too loud vs gameplay SFX. |
| P0 | `sounds/arg_death1.wav` | Enemy death cue | `0.2-0.8s` | Distinct from hit/miss family. |
| P0 | `sounds/inner_sanctum_44k1_adpcm_stereo.wav` | Title voice/intro layer | as authored | Should remain intelligible at low volume. |
| P0 | `sounds/Intro_45sec.wav` | Title music bed | ~45s | Avoid clipping; keep headroom for SFX. |

## P1 - Next Phase (Chest/Inventory/Trader Polish)

### Loot / Economy Visuals
| Priority | Planned File Path | Planned Context | Recommended Canvas | Notes |
|---|---|---|---|---|
| P1 | `sprites/item_drop_consumable.png` | World loot marker for consumables | `24x24` | Replaces primitive square marker. |
| P1 | `sprites/item_drop_weapon.png` | World loot marker for weapons | `24x24` | Distinct silhouette from consumable. |
| P1 | `sprites/item_drop_equipment.png` | World loot marker for charms/equipment | `24x24` | Distinct color family from weapon marker. |
| P1 | `sprites/trader_front.png` | Trader NPC (future spawn loop) | `64x96` | Front-facing readable shape. |
| P1 | `sprites/trader_left.png` | Trader side view | `64x96` | Match front proportions exactly. |
| P1 | `sprites/trader_right.png` | Trader side view | `64x96` | Match front proportions exactly. |

### Loot / Economy Audio
| Priority | Planned File Path | Planned Context | Target Length | Notes |
|---|---|---|---|---|
| P1 | `sounds/chest_open.wav` | Chest breaks/opens | `0.2-0.6s` | Wood + metal click blend. |
| P1 | `sounds/item_pickup.wav` | Successful item pickup | `0.08-0.2s` | Clear positive cue. |
| P1 | `sounds/inventory_full.wav` | Overweight/blocked pickup | `0.08-0.2s` | Short negative cue, not harsh. |
| P1 | `sounds/trader_open.wav` | Trader menu open | `0.15-0.35s` | Light UI shop cue. |
| P1 | `sounds/trader_buy.wav` | Purchase confirm | `0.08-0.2s` | Distinct from pickup. |
| P1 | `sounds/trader_deny.wav` | Not enough score/currency | `0.08-0.2s` | Negative UI cue. |

## P2 - Story Mode Media Backlog (After Economy Loop)
| Priority | Asset Group | Minimum Needed | Notes |
|---|---|---|---|
| P2 | Intro story slides | 8 images + optional subtitle timing notes | Keep consistent palette and text-safe margins. |
| P2 | Zone transition cards | 1 per zone | Static cards are enough initially. |
| P2 | Boss relic icons | 5+ icons | Needed for relic-gate UI/readability. |
| P2 | Lore pickup icon set | 1 base + variants | Keep tiny-size legibility for HUD/pickups. |

## Production QA Checklist (Per Asset)
- [ ] Filename/path matches exactly.
- [ ] Added to `metadata.json`.
- [ ] Alpha edges clean (no halo on dark walls).
- [ ] Reads at small scale (test at ~25% size).
- [ ] Visual anchor stable across related frames (no jump between states).
- [ ] In-game test done for both normal and low-FPS scenes.

## Notes For "Perfect Fit" In Current Camera
- First-person weapon overlays are drawn on the right side of the screen and are not rotated at runtime.
- Projectile sprites are also not runtime-rotated; shape readability must come from the base art.
- Keep weapon and projectile silhouettes bold; fine detail disappears quickly at distance scaling.
