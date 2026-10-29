# Levels — one room

**Authored, not generated.** The spec below is locked so builds tune numbers
instead of inventing layouts. As-built 2026-10-28 (grill rounds 1–2, ADR-5…9).

Design rules, kept from the research pass: one idea executed immediately, no
text walls; failure costs nothing (miss = floor, walk back, retry free); no
lethal hazards; `[R]` restarts instantly; sightline + warm light on the thing
that matters.

## Room 1 — Sling, Uplift, platform (momentum stunt)

| | |
| What you see | enclosed 36 × 12 × 12 room; ramp west up to a railed deck; cyan fold ahead, green fold beyond it, glowing gate high on the east wall with a platform above it |
| What you do | sprint east off the deck into the Sling (down +X, x −10…−7, y 2…4) — exit ~8 m/s; arrive in the Uplift (down +Y, x −7…−1, y 2…7.5) still fast — it trades speed for height; keep holding forward; come down on the platform (top 4.3, x 9…16, scoop on its west edge); touchdown wins |
| What you learn | momentum survives scope boundaries — speed in is height out |
| Soft-lock guard | Uplift floor (y 2) is above jump reach (0.8) and a jump-range past anything standable; the deck jump into its face arrives too slow to reach the platform; nothing is destructible, E does nothing (fixed folds) |
| Numbers | Sling 3 × 2 × 4 m; Uplift 6 × 5.5 × 4 m; arc peak ~5.6, touchdown x ≈ 8.4 (deterministic across runs); air drag 0.15, air accel 30 (never bleeds speed); ground snap unchanged |
