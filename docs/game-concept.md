# Game concept — Gravit

**Status: FROZEN 2026-10-26** (council verdict, chair synthesis). Changes require editing this file first.

## The law

> Gravity and time are properties of the **scope you are standing in**, not of the world.
> Space can be folded: a fold is a bounded scope you can carry, place and break. Inside a fold you fall
> toward the fold's own down, and your clock runs at the fold's rate. Anything you set going inside a fold
> arrives in the parent world late — the deeper the fold, the later.

One parameter set per fold: **gravity direction**, **clock factor** — that is it. Everything below derives
from those two numbers.

## Why this version (council verdict, 5 seats)

| Seat | Candidate it picked | Decisive argument |
| --- | --- | --- |
| Design craft (rams) | Fold law | Only concept where an LLM is load-bearing, not decorative; unique in one sentence |
| Player psychology (kahneman) | Fold law | "Break it → the world outside changes" is self-explaining in 30 s, no narration |
| Systems (meadows) | Gravity lag | Fold's three free parameters are hand-waved; lag has exactly one caveat |
| Mechanism (ada) | Fold law | Scope tree + affine clock = 6 invariants, testable headlessly, no viewport |
| Feasibility (torvalds) | Gravity lag | Nested sub-worlds (SubViewport/World3D) are a 5-day transform-bug sink for a beginner |

**Chair resolution.** The split is about *implementation*, not the idea. Torvalds objected to nested
`SubViewport` worlds, Meadows to free-floating parameters — both objections dissolve with one decision:

> **A fold is not a separate world. It is a region that overrides gravity and time for whatever is inside it.**

No `SubViewport`, no `World3D`, no camera surgery, no cross-world collision: a fold is an `Area3D` whose
gravity override and clock factor apply to bodies inside it, implemented as a single pure function
`applied_gravity(body, t) -> Vector3` plus a per-scope time factor. That is Ada's scope tree with Torvalds'
cheapest possible node set, and it keeps the concept already submitted to the hackathon.

Meadows' warning still stands as a design rule: fold parameters are **authored, not emergent**. Each room
states its fold numbers; no phase transitions, no automatic coupling to contents.

## Frozen mechanics (build these)

| # | Mechanic | Implementation sketch |
| --- | --- | --- |
| M1 | Walk, look, jump | `CharacterBody3D`, gravity applied manually from `applied_gravity()` |
| M2 | Fold placed in the world | `Area3D` + visible translucent shell; carries `gravity_dir`, `clock_factor` |
| M3 | Carry a fold, place it, break it | hold key latches the fold to the player; break removes the Area3D and drops contents |
| M4 | Fall the fold's way inside | same `applied_gravity()` for player and `RigidBody3D`; no per-body special cases |
| M5 | Delayed consequence | queue of `(body, impulse)` applied to the parent scope after `clock_factor × delay`; one countdown ring per queued event |
| M6 | Exit reachable only via a fold | the last room's door opens from an event queued through a fold |

## Cut list (do not build before Nov 2)

- **Magnets / magnetic direction** (rams: second verb surface; ada: same code path, no depth). Two seats
  voted to cut; cut.
- **Polarity society seed** — political framing is a disqualification risk; not pursued.
- **Mass nesting seed** — needs player mass to couple to physics to feel honest; out of scope.
- **Gravity-lag seed** — kept only as the Day-2 fallback (see below), not built.
- **Speedrun timer as score** (kahneman: reframes play as evaluation, hurts onboarding). A **Replay** mode
  with a timer unlocks *after* the first completion; no ghost, no leaderboard.
- **Visible gravity echoes / ghost trails** (torvalds: SubViewport + material work, zero gameplay).
- **Runtime LLM calls in gameplay** — latency kills a puzzle game; Meta models are used at build time plus
  one optional in-game "fold log" narrator (see below).

## Where Meta models are load-bearing

| Use | Model | Why it earns its place |
| --- | --- | --- |
| Room briefings, hint ladders, journal fragments — generated as JSON at build time, checked into `game/data/` | `muse-spark-1.3` (structured output) | Puzzle hint text is the one writing job a solo dev cannot afford; schema-checked, no runtime cost |
| 2–3 hero textures / fold shell shader input | `muse-image-1.0` | Keeps the art route cheap; marked in sidecars |
| Demo narration + captions | `muse-voice-transcribe-1.0` | Voice-over from a phone recording, transcribed and timed |
| Stretch: in-game "fold log" that narrates the last thing you changed | `muse-spark-1.3` | Demo-visible AI; ships only if the Nov 2 cut line allows |

Every artefact carries the markers in [`attribution-policy.md`](attribution-policy.md) and a row in
[`meta-usage-log.md`](meta-usage-log.md).

### Open-weight component (targets the $10k "Best Build on Meta Open Weight Models" award)

Hint ladders and room variants are generated **twice**: once as the shipped default, and once by a small
*room-architect* pass on `meta-spark-open` (`meta-models/muse-spark-open-1026` via Baseten, free credits) that
proposes a variant layout from a prompt. The variant is an authored JSON the game loads — no runtime server. The
demo shows the open-weight call and the resulting variant playing, which is what makes the award claim honest.

### Runtime call: one, optional, and offline-safe

A puzzle game cannot put LLM latency in the loop, so at most **one** runtime call exists: an "explain what just
happened" button that narrates the last fold event via `muse-spark-1.3`, cached per event, with the build-time
text as fallback when offline or slow. It ships only if the Nov 2 cut line allows; the demo shows it once. Even
without it, the build-time uses are real Meta usage — but a runtime call is the most legible evidence for
"meaningfully used", which is the Stage-1 gate.

## Fallback (decided in advance)

If by **end of Day 2 (Oct 28)** gravity override + delayed consequence are not both demonstrably working,
freeze the feature set to: **one fold, gravity override only, three rooms, no delay** — and spend the saved
time on the demo video. If even that fails, switch the law to **gravity lag** (Torvalds/Meadows' pick): one
history buffer, three rooms, still one law, still ship a demo. Record the swap here before coding it.

## Judging alignment

| Rubric | How this concept answers it |
| --- | --- |
| Impact 30% | Weakest axis for any game; counter with a "playable explanation" panel: the fold law taught by play, plus a 90-second "what this models" note (scope-relative time is how nested schedulers actually behave) |
| Use of Meta AI Tooling 25% | Four genuine uses, one demo-visible (fold log), all attributable |
| Technical Depth 20% | One pure gravity function, one scope tree, one delay queue; headless tests for the invariants |
| Demo 25% | Opens on the effect (break a fold → the parent world moves), never on the premise |

## Demo opening (write this before coding the polish)

0:00–0:10 — player drops a crate into a fold; it falls *sideways*; break the fold; the crate lands behind a
wall in the parent world, and a door that was closed is now open. No narration. Then the title.
