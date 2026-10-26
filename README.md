# Gravit

**One law of nature, one small 3D puzzle course.** Gravity and time belong to the scope you are
standing in. Space can be folded: a fold is a bounded region you can carry, place and break —
inside it you fall the fold's way and your clock runs at the fold's rate, so what you set going
inside arrives in the outside world late.

Built solo during the **Meta Global AI Developer Hackathon** (Oct 26 – Nov 4, 2026). Nothing in
this repository predates the window: the first commit is Oct 26, and `git log` backs it.

## Play it

Godot 4.7 — open the `game/` folder as a project and press play (or `godot --path game`).
Three rooms in one run: walk, pick up folds, break them over the plates, reach the exit.

| Input | Action |
| --- | --- |
| Mouse / arrows | look / walk (Up is forward) |
| Space | jump (away from your current down) |
| E | pick up the nearest fold / set it down (deepest wins ties) |
| X | break the carried fold where you stand |
| H | next hint for the room you are in |
| T | airlock narration (AI when online, local fold log otherwise) |
| R | restart |

The whole game is one gravity function (`FoldScope.applied_gravity`) shared by the player and
every rigid body, one scope tree, one delay queue — all covered by headless tests, see below.

## Meta models, and how it is proven

| Used for | Model | Where it shows |
| --- | --- | --- |
| Room briefings, hint ladders, fold logs (build-time JSON) | `muse-spark-1.3` | `game/data/hints.json` + marker |
| 6 signage decals (opaque wall plates) | `muse-image-1.0` | `game/assets/decals/*.webp` + sidecars |
| Optional in-game narration (2.5 s local fallback) | `muse-spark-1.3` | airlock terminal |
| Demo voice-over captions | `muse-voice-transcribe-1.0` | `docs/demo/` (Nov 3) |
| Open-weight room variant (bonus claim) | `muse-spark-open-1026` | pending Baseten key — schema + prompt ready |

Every Meta-generated artefact is **written by one script** (`scripts/meta_generate.py`), which appends a
receipt — model, response id, token usage, output hash, git commit — to `docs/meta-usage.jsonl`, and the
file itself carries a `meta-model:` marker. `sh scripts/meta-proof.sh` renders both into
[`docs/meta-proof.md`](docs/meta-proof.md). Open-weight use is logged the same way when its key lands.

## Verify it

```bash
godot --headless --path game -s res://tests/test_runner.gd   # invariants, 47 PASS
godot --headless --path game res://tests/door_check.tscn      # room 1 end to end
godot --headless --path game res://tests/room2_check.tscn     # carry / break
godot --headless --path game res://tests/room3_check.tscn     # nested folds
godot --headless --path game res://tests/t7_check.tscn        # hints / terminal / timer
python3 scripts/validate_data.py                               # generated JSON schemas
sh scripts/meta-proof.sh && sh scripts/check-attribution.sh   # evidence + markers
```

## Repo map

| Path | What |
| --- | --- |
| `game/` | Godot project — scenes, scripts, generated data |
| `game/course.tscn` | the playable course (rooms 1–3 + player + HUD) |
| `docs/game-concept.md` | the frozen law, mechanics, cut list, fallbacks |
| `docs/demo-script.md` | the 3-minute video plan (shots, voice-over, capture specs) |
| `docs/meta-proof.md` | generated evidence: receipts + markers |
| `docs/attribution-policy.md` | how model-generated artefacts are marked |
| `docs/meta-usage-log.md` | one row per generation job, plus tooling disclosure |
| `ROADMAP.md` | phases to Nov 4 with the Nov 2 cut line |
| `scripts/` | Meta generator, proof builder, validators, secret scan |
| `AGENTS.md` | working agreement for any agent in this repo |

## Demo

Video link lands here Nov 3 (under 3:00, opens on the effect, never the premise). Plan and
voice-over text: [`docs/demo-script.md`](docs/demo-script.md).

## Secrets

No credentials in this repo. `MODEL_API_KEY` and friends live in the host environment; a pre-commit
hook (`scripts/check-secrets.sh`) blocks key-shaped strings and credential files.

## License

MIT — see [`LICENSE`](LICENSE).
