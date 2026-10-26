# AGENTS.md — working agreement for Gravit

Any agent (pi, Claude Code, Codex, Muse Code, Gemini, a human) working in this repository follows this file.
`AGENTS.md` at the repo root wins over global defaults for work inside `/mnt/c/dev/Gravit`.

## Hard rules

1. **Hackathon window.** Everything submitted must be built Oct 26 – Nov 4, 2026. Do not paste in
   pre-existing product code, assets you do not have rights to, or code from another project. Prior
   *ideas* are fine; prior *code* is not.
2. **Public repo, no secrets.** Never commit a key, token, cookie, `.env`, or private URL. Credentials live
   outside the repo (`~/.ccgram/.env`, `~/.pi/agent/auth.json`, host keychain). `scripts/check-secrets.sh`
   must pass before every commit. If a secret ever lands in a commit: rotate it first, then clean history.
3. **Meta models must be visible and honest.** Every artefact produced with a Meta model carries the
   markers in [`docs/attribution-policy.md`](docs/attribution-policy.md) and is logged in
   [`docs/meta-usage-log.md`](docs/meta-usage-log.md). Judges must be able to tell what is new and what
   each model did.
4. **Engine.** Godot 4 (`game/`). Scenes and scripts are plain text (`.tscn`, `.gd`) so agents can read and
   diff them. Do not add binaries to git; `.import`/`.godot` stay ignored.
5. **Scope.** One playable course beats five unfinished systems. If a mechanic cannot be demonstrated in the
   three-minute demo video, it is out of scope for this deadline.

**Thinking level per phase — say it at the start AND the end.** Every ticket carries `thinking:` and `next:` headers.
An agent **cannot** change the TUI thinking level (it is a keystroke), so the level must be asked for out loud:

1. **First line of every turn**: `ticket T4 · thinking high (footer says max — shift-tab twice before sending)` when
   the current level differs, or `ticket T4 · thinking high (matches)` when it does not. Never start work silently at
   the wrong level.
2. **Final line of every completed ticket** — the handoff footer, exactly this shape:

   ```
   DONE: T1 · commit b502d6d · tests 22/22 PASS
   NEXT: T2 — player controller + camera · thinking high (you are on max: shift-tab twice) · blocked by: none open
   ```

   If the next ticket is still blocked, say so and name the blocker instead of the level.

Read the `next:` header of the ticket you are working on — do not assume. A ticket is not "done" until the footer
names the next ticket and the level it needs.

## Workflow

1. **Research** (outside the repo, Gemini web/Android to save agent quota) → paste the report into
   `docs/research/` and distil the decisions into `ROADMAP.md`.
2. **Concept** is frozen in [`docs/game-concept.md`](docs/game-concept.md). Changing the core law requires
   updating that file first, then `ROADMAP.md`.
3. **Tickets** in `tickets/` (one file per ticket, blocking edges as text). Small, tracer-bullet slices.
4. **Implement test-first** where a test is possible (GDScript `--headless` scene tests, pure-logic scripts).
   Every non-trivial mechanic leaves one runnable check that fails when the mechanic breaks.
5. **Verify before claiming done**: run the check, state the command and its output.
6. **Commit** small and often; push to `main` (solo repo). No force-push after submission.

**Solo entry.** One person (Indie Developer track). Do not add co-authors, and do not accept teammate
help that would need crediting: the submission lists everyone who worked on it.

**Tooling disclosure.** Planning used a multi-persona review (the council skill) and research drafts from
Gemini; implementation uses a coding agent. That is ordinary tooling, disclosed in `docs/meta-usage-log.md`.
Meta models are the ones being showcased, and their output is marked so the distinction is verifiable.

## Division of labour (cost-aware)

| Job | Where |
| --- | --- |
| Brainstorm, research, roadmap | Gemini web/Android (no agent quota) |
| Code, refactor, tests | This harness (pi / Muse Code) |
| Art, textures, audio | Meta Image / Muse Voice Transcribe; log each use |
| Judging-facing text (README, demo script) | Here, reviewed by the human |

## Demo opening line (required by the rules)

The video's first line states what was pre-existing and what was built during the event. For Gravit:
**"Nothing pre-existing — this repository and everything in it was built during the hackathon."** Say it in the
first five seconds, on screen and in voice.

## Definition of done for the hackathon

- `game/` runs from a clean checkout: open in Godot 4, press play, course is playable.
- One course of a few rooms, folding/breaking consistent, gravity driven by folds, an exit reachable only
  by using the rule.
- `README.md` explains the law, the mechanics, and the Meta models used (with markers).
- 3-minute demo video linked from the README and the submission.
