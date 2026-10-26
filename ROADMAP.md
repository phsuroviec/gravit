# Roadmap

Status: **skeleton**. Fill the phases from the research report (`docs/research-brief.md`), keep the dates.

Building window: Oct 26 (kickoff 12:00 PM ET) – **Nov 4, 9:00 PM ET** (submission). Demo video required.

## Milestones

| Date (ET) | Milestone | Exit test |
| --- | --- | --- |
| Mon Oct 26 | Repo, docs, credits claimed, concept frozen | credits visible in Billing; `docs/game-concept.md` says FROZEN |
| Tue Oct 27 | Godot project runs; controller walks a grey-box room | `godot --headless --quit` clean; room playable |
| Wed Oct 28 | Fold object: place, carry, break | object persists across save-free reload; no soft-lock |
| Thu Oct 29 | Fold gravity: inside is the fold's down | a box dropped inside a fold falls the fold's way |
| Fri Oct 30 | Magnet drag + polarity repulsion | drag a fold across a gap; two like poles push |
| Sat Oct 31 | Course room 1 + 2 with teach-by-doing | a stranger can pass room 1 without text |
| Sun Nov 1 | Course room 3; exit requires the law | exit unreachable by walking |
| Mon Nov 2 | **CUT LINE** — feature freeze | everything in the demo exists and works |
| Tue Nov 3 | Polish, Meta-model content generated + marked, recorder run | full playthrough recorded once |
| Wed Nov 4 | 3-minute demo video, README/judging text, submission | submitted before 9:00 PM ET |

## Cut line rules

- After Nov 2: no new mechanic, no new room, no engine change. Only bugs, feel, and demo.
- If a milestone slips a day, cut a room, not the law. The law is the submission.
- Every day ends with a runnable `game/` on `main`.

## Risks

| Risk | Fallback |
| --- | --- |
| Real time-dilation is expensive/unstable | fake it with a delayed-consequence queue (D3) |
| Carrying a scene-containing container breaks physics | fix folds in place with a "place/break" verb only |
| Art eats days | untextured primitives + strong lighting; Muse Image only for 3 hero assets |
| Meta API credits late | build against the OpenAI-compatible interface; swap the base URL last |

## Meta model plan (see `docs/meta-usage-log.md`)

1. Build-time text: puzzle hints, room names, journal fragments — `muse-spark-1.3` structured output.
2. Art: 2–3 textures/icons — `muse-image-1.0`, marked in sidecars.
3. Narration/captions for the demo — `muse-voice-transcribe-1.0`.
4. Optional runtime hook: an in-game "fold recorder" that narrates what you just did — highest scoring on
   tooling, only if Nov 2 cut line allows.
