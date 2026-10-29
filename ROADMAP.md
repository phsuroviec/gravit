# Roadmap — Gravit (rewritten 2026-10-28 for the one-room plan)

Old day-by-day (rooms 2–4, break verb) is superseded. What stays: the two
hard gates below, the Meta model plan, the fallbacks' spirit (cut scope, keep
the demo-able core).

Two hard gates:

| Gate | When | Rule |
| --- | --- | --- |
| **Hard feature cut line** | **Nov 2, 11:59 PM ET** | `git tag v1.0-freeze`; zero new mechanics/rooms after. Nov 3–4 are capture, captions, editing, submission |
| **Submission deadline** | **Nov 4, 9:00 PM ET** | Video + repo link on the CV platform, `$150` credit claim form |

## Where we are (2026-10-28)

Done and green: one stunt room (Sling → Uplift → platform, bot-cleared on
honest input), air inertia, fixed folds, first-person mannequin, flip cues,
single-room hints/airlock/timer, open-weight variant path, full headless
suite (70 asserts + 5 scene checks), secrets clean, pushed to `main`.

## Next slices (owner picks the order)

| Slice | Work | Exit criterion |
| Carry level | un-fix one fold, crate + pad return, place-to-goal puzzle | bot carries, places, door opens (variant_check already proves the verbs) |
| Second stunt | new fixed-fold geometry (different exchange: e.g. down → sideways wall ride) | bot clears on honest input, anti-cheat traced like T23 |
| Feel pass | footsteps, landing weight, flight wind, pad-grade telegraphing for the gate | plays quiet-loud-quiet in one run |
| Fresh words | generation pass for briefing/hints once API credit lands (keeps the Meta story clean) | `validate_data.py` green, markers honest |
| Video | rewrite `docs/demo-script.md` from the as-built room, capture, captions, edit to 3:00 | link in README before Nov 4 9 PM ET |

## Meta model plan (unchanged, details: `docs/meta-usage-log.md`)

1. **Build-time generation** (`muse-spark-1.3`): room briefings, hint ladders, variant layouts → JSON in `game/data/`.
2. **Diegetic signage** (`muse-image-1.0` + `sam-3.1`): warning decals, segmented into 6 usable masks.
3. **Voice + captions** (`muse-voice-transcribe-1.0`): voice-over transcribed for the demo.
4. **Open-weight pass** (`muse-spark-open-1026` on Baseten, free credits): room-architect variants — the
   "built on Meta open-weight models" bonus claim.
5. **Optional runtime** (`muse-spark-1.3`): airlock fold-log narrator with a 2.5 s local fallback.

Every artefact goes through `scripts/meta_generate.py` (receipt per call) and carries the markers from
`docs/attribution-policy.md`.

## Risks

| Risk | Fallback |
| Two gravity code paths drift (player vs rigid) | one `applied_gravity(body, t)`; both call it |
| Stunt arc too tight for humans | widen the catcher (platform/scoop), never the mechanic |
| Meta credits late/limited | build-time generation only; the shipped game makes no calls |
