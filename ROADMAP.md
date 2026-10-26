# Roadmap — Gravit

Source: `docs/research/gemini-2026-10-26.pdf` (44 pages, Gemini Deep Research), distilled here. The PDF stays
authoritative for reasoning and citations; this file is the executable order of work.

Two hard gates:

| Gate | When | Rule |
| --- | --- | --- |
| **Core physics checkpoint** | **Oct 28, 9:00 PM ET** | `FoldScope`, `ConsequenceQueue` and headless invariants i–iv work in Room 1, or trigger the fallbacks below |
| **Hard feature cut line** | **Nov 2, 11:59 PM ET** | `git tag v1.0-freeze`; zero new mechanics/rooms after. Nov 3–4 are capture, captions, editing, submission |

## Day by day

| Date | Deliverable | Exit criterion |
| --- | --- | --- |
| Oct 26 (Mon) | Repo, concept, docs, credits — **done**. Headless harness, `FoldScope`, `ConsequenceQueue`, `tests/test_runner.gd` | `godot --headless --path game -s res://tests/test_runner.gd` exits 0 on all four invariants |
| Oct 27 (Tue) | `Player.tscn` (`CharacterBody3D`, dynamic `up_direction`), `FoldBox.tscn` (`Area3D` + translucent shell), freeze-on-pickup | Walk into a fold, fall along its `gravity_dir`, pick it up with a cube inside, place, break — cleanly |
| Oct 28 (Wed) | Room 1 (scoped gravity) + delayed-impulse door with `Label3D` countdown | **9:00 PM ET checkpoint** above |
| Oct 29 (Thu) | Rooms 2 (carry/break) and 3 (nested fold door), greyboxed in `.tscn` (CSGBox3D + collision) | All three rooms traversable with the mechanic, no doors left open |
| Oct 30 (Fri) | Build-time generation pass: room/hint JSON + signage decals (SAM 3.1 masks) | Generated JSON loads; 6 segmented decals on walls |
| Oct 31 (Sat) | Airlock terminal (runtime call, 2.5 s local fallback), `[R]` restart, `[H]` hint, post-completion Replay Timer | Room 3 completion shows the fold log with no frame hitch |
| Nov 1 (Sun) | Telegraphing pass: warm spotlights, particle streams inside folds, countdown SFX, felt-speed audit | Fresh playtest clears rooms 1–3 in under 3 minutes, unassisted |
| Nov 2 (Mon) | Bug bash, clean-boot check | **Cut line**: `v1.0-freeze` |
| Nov 3 (Tue) | Record 60 FPS lossless clips, 43 s voice-over, `muse-voice-transcribe-1.0` captions, edit | Video assembled, under 3:00 |
| Nov 4 (Wed) | README/judging text, `scripts/meta-proof.sh`, submission | Submitted before **9:00 PM ET** |

## Fallbacks (trigger, do not debate)

| If this breaks | Do this |
| --- | --- |
| Camera roll / physics carry is unstable | Freeze folds in place: place + break only, no carrying |
| Real per-scope clock scaling fights physics | Keep gravity override, fake the clock with the consequence delay (already the readable part) |
| Delayed door not working by Oct 28 9 PM | Room 3 exit = break a fold whose contents land on a plate; drop the countdown label |
| Wall time is short on Oct 30 | Generate fewer artefacts by hand, spend the pass on the fold-log demo instead |

## Meta model plan (details: `docs/meta-usage-log.md`)

1. **Build-time generation** (`muse-spark-1.3`): room briefings, hint ladders, variant layouts → JSON in `game/data/`.
2. **Diegetic signage** (`muse-image-1.0` + `sam-3.1`): warning decals, segmented into 6 usable masks.
3. **Voice + captions** (`muse-voice-transcribe-1.0`): 43 s voice-over transcribed for the demo.
4. **Open-weight pass** (`muse-spark-open-1026` on Baseten, free credits): room-architect variants — the
   "built on Meta open-weight models" bonus claim.
5. **Optional runtime** (`muse-spark-1.3`): airlock fold-log narrator with a 2.5 s local fallback.

Every artefact goes through `scripts/meta_generate.py` (receipt per call) and carries the markers from
`docs/attribution-policy.md`.

## Risks

| Risk | Fallback |
| --- | --- |
| `RigidBody3D` parented under a moving fold desyncs | bodies stay parented to `RoomRoot`; folds never reparent physics bodies (report §1) |
| Two gravity code paths drift (player vs rigid) | one `applied_gravity(body, t)`; both call it |
| Reasoning tokens eat the output budget | `max_tokens` ≥ 800 on Meta calls; a 8-token cap returns empty content |
| Meta credits late/limited | build-time generation only; the shipped game makes no calls |
