# Meta model usage log

One row per job, not per request. Mirrors the `# --- meta-model: ... ---` markers in code and the sidecars on
assets. Update it in the same commit as the artefact.

| Date | Model | Job | Artefacts | Human involvement |
| --- | --- | --- | --- | --- |
| _2026-10-26_ | _none yet_ | repo scaffold, rules, concept (hand-written) | `README.md`, `docs/`, `AGENTS.md` | all human-directed |

## Conventions

- **Model** = exact ID used (`muse-spark-1.3`, `muse-image-1.0`, `sam-3.1`, `muse-voice-transcribe-1.0`,
  `muse-wonder-1.0`, Muse Code session id if relevant).
- **Artefacts** = paths or globs; use the marker text so `grep` finds both ends.
- **Human involvement** = what a person decided, reviewed or rewrote. This is what makes the demo defensible.

## Non-Meta tooling (for transparency, not judged)

| Tool | Use |
| --- | --- |
| Gemini (web/Android) | research + roadmap drafting, keeps agent quota free |
| pi harness (DeepSeek / Codex / agy) | implementation, tests |
| Claude Code / Codex | brainstorming sessions, idea critique |

Meta models are what the submission showcases; the rest is ordinary tooling and is disclosed in the demo.
