# Gravit

**One law of nature, one small 3D puzzle course.** Gravity and time belong to the space you are standing
in. Space can be folded: a fold is a bounded region you can carry, place and break — inside it you fall the
fold's way and your clock runs faster, so what you set going inside arrives in the outside world late.

Built solo during the **Meta Global AI Developer Hackathon** (Oct 26 – Nov 4, 2026) with **Meta models** for
the parts a solo developer cannot do alone: room briefings, hint ladders, textures and the demo narration.

> Status: **pre-production** — concept frozen, roadmap being filled from the research pass. Game code lands
> Oct 27 onward. Nothing here predates the hackathon window.

## Meta models, and how it is proven

| Used for | Model | Where it shows |
| --- | --- | --- |
| Room briefings, hint ladders (build-time JSON) | `muse-spark-1.3` | `game/data/*.json` + markers |
| Fold shell / hero textures | `muse-image-1.0` | `assets/*` + `.meta.md` sidecars |
| Demo narration + captions | `muse-voice-transcribe-1.0` | `docs/demo/` |
| Optional in-game "fold log" narrator | `muse-spark-1.3` | only if the Nov 2 cut line allows |

Every Meta-generated artefact is **written by one script** (`scripts/meta_generate.py`), which appends a
receipt — model, response id, token usage, output hash, git commit — to `docs/meta-usage.jsonl`, and the file
itself carries `# --- meta-model: <id> | <date> | <purpose> ---` / `# --- end meta-model ---` markers.
`sh scripts/meta-proof.sh` renders both into [`docs/meta-proof.md`](docs/meta-proof.md).

## Run it

```bash
# Godot 4.3+ ; open the game/ folder as a project and press play
godot --path game
```

Nothing else is required to play. Generation scripts need `MODEL_API_KEY` in the environment (never in this
repo); without it they run in dry-run mode and print the request they would send.

## Repo map

| Path | What |
| --- | --- |
| `game/` | Godot project — scenes, scripts, generated data |
| `docs/game-concept.md` | the frozen law, mechanics, cut list, fallbacks |
| `docs/meta-proof.md` | generated evidence: receipts + markers |
| `docs/attribution-policy.md` | how model-generated code/assets are marked |
| `docs/meta-usage-log.md` | one row per generation job, plus non-Meta tooling disclosure |
| `docs/hackathon-rules.md` | internal checklist: deadlines, rubric, DQ traps (not part of the pitch) |
| `ROADMAP.md` | phases to Nov 4 with the Nov 2 cut line |
| `docs/research-brief.md` | the research prompt the plan was built from |
| `scripts/` | Meta generator, proof builder, secret scan, attribution audit |
| `AGENTS.md` | working agreement for any agent in this repo |

## Secrets

No credentials in this repo. `MODEL_API_KEY` and friends live in the host environment; a pre-commit hook
(`scripts/check-secrets.sh`) blocks key-shaped strings and credential files.

## License

MIT — see [`LICENSE`](LICENSE).
