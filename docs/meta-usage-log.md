# Meta model usage log

One row per job, not per request. Mirrors the `# --- meta-model: ... ---` markers in code and the sidecars on
assets. Update it in the same commit as the artefact.

| Date | Model | Job | Artefacts | Human involvement |
| --- | --- | --- | --- | --- |
| _2026-10-26_ | _none yet_ | repo scaffold, rules, concept (hand-written) | `README.md`, `docs/`, `AGENTS.md` | all human-directed |
| 2026-10-26 | muse-spark-1.3 | room briefings + hint ladders (T6) | `game/data/hints.json` | human wrote prompt + schema + validator; model wrote the text |
| 2026-10-26 | muse-image-1.0 | 6 signage decals (T6) | `game/assets/decals/*.webp` + sidecars | human wrote prompts, picked opaque-plate style, eyeballed output |

## Conventions

- **Model** = exact ID used (`muse-spark-1.3`, `muse-image-1.0`, `sam-3.1`, `muse-voice-transcribe-1.0`,
  `muse-wonder-1.0`, Muse Code session id if relevant).
- **Artefacts** = paths or globs; use the marker text so `grep` finds both ends.
- **Human involvement** = what a person decided, reviewed or rewrote. This is what makes the demo defensible.

## Ruled out (deliberate, not forgotten)

- **sam-3.1 masks (T6):** signage ships as opaque rectangular plates, which need no alpha
  cutouts — a segmentation pass would add cost and pipeline for zero visible difference.
  Revisit only if a future asset needs an irregular silhouette.
- **Open-weight variant (T6, pending):** blocked on Baseten approval — no key on the node
  yet. Schema (`game/data/room_layout.schema.json`), prompt (`prompts/variant.txt`) and
  `--key-env` support are ready; run the one call when the key lands, then log it here.

## Non-Meta tooling (for transparency, not judged)

| Tool | Use |
| --- | --- |
| Gemini (web/Android) | research + roadmap drafting, keeps agent quota free |
| pi harness (DeepSeek / Codex / agy) | implementation, tests |
| Claude Code / Codex | brainstorming sessions, idea critique |

Meta models are what the submission showcases; the rest is ordinary tooling and is disclosed in the demo.
