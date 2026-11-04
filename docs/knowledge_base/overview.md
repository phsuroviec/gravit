# Gravit — current-state overview

Updated 2026-11-03. Short orientation for people and NotebookLM. Authoritative detail lives in
`README.md`, `docs/game-concept.md`, `docs/folds-explained.md`, `ROADMAP.md` and `docs/hackathon-rules.md`.

## What it is

A first-person puzzle game built solo for the Meta Global AI Developer Hackathon (Indie Developer
track, Oct 26 – Nov 4, 2026). Submission deadline: Wednesday Nov 4, 9:00 PM Eastern, with a demo
video under 3 minutes.

**The law:** gravity belongs to the scope you stand in. A **fold** is a bounded region you can carry
(inert) and place (live); inside it you fall the fold's way. One room teaches chaining small folds
across a void into a "moonshot" that reaches the underside of a sky block.

## Architecture

- Godot 4.7 project in `game/`; one gravity function (`FoldScope.applied_gravity`) shared by the player
  and every rigid body, one scope tree, one delay queue.
- Headless Godot tests cover invariants, door/pad logic, a bot that clears the room, hints and the
  open-weight layout variant.

## Meta model use (required by the hackathon)

| Use | Model |
| --- | --- |
| Hints, briefings, fold logs, in-game narration | `muse-spark-1.3` |
| Wall signage decals | `muse-image-1.0` |
| Demo captions | `muse-voice-transcribe-1.0` |
| Open-weight room variant | `muse-spark-open-1026` (pending Baseten key) |

Every generated asset is written by `scripts/meta_generate.py`, which appends a receipt (model,
response ID, tokens, output hash, commit) to `docs/meta-usage.jsonl`; `scripts/meta-proof.sh`
renders the evidence.

## Rules

No credentials in the repo (pre-commit secret scan). MIT license. Nothing predates the hackathon window.
