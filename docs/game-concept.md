# Game concept — Gravit

Status: **seed**, not frozen. Frozen 2026-10-28 after the research report lands.

## The law (one, and everything follows)

Space can be folded. A **fold** is a pocket universe you can pick up, carry, put down, or break open.
Each fold has:

- its own **gravity** (direction and strength),
- its own **magnetic direction**,
- its own **clock** — time runs faster the deeper the fold.

Magnets are how you drag a fold from outside, and how you keep two folds from colliding. Breaking a fold
spills what was inside, in the parent world's geometry, at the parent's rate.

World: post-collapse. The collapse happened when people folded things they did not understand. Folds are now
infrastructure (storage, smuggling, shortcuts) and hazard (unstable ones swallow city blocks). The interesting
part: people built a life on the law, and the law keeps ruining it.

**Puzzle shape.** An obstacle course. Get yourself and a few objects from start to finish by deciding what to
fold, where to place it, and what to break. Because a fold runs fast, a fix made inside it lands in the parent
world seconds later — solving small now, resolving big later, is the core verb.

## Why Godot 4

Scenes and scripts are plain text, so an agent can read, diff and edit them without a human learning an editor
first. GDScript is teachable to a nephew. 3D, small scope.

## Scope for 10 days (3-minute demo target)

Must work:

1. One course of 3–4 rooms, walkable, with a start and an exit.
2. Fold: pick up, carry, place, break. Consistent state, no soft-locks.
3. Gravity: inside a fold, down is the fold's down; objects fall accordingly; leaving restores the world.
4. Magnets: drag a fold at range; two folds repel when like-poled.
5. One exit reachable **only** by using the law — not by a door left open.

Deliberately absent: story mode, cutscenes, multiple courses, saving, menus beyond a start/restart.

## Open decisions (block roadmap)

| # | Question | Options | Why it matters |
| --- | --- | --- | --- |
| D1 | Player controller | first-person walker vs. third-person character | third-person sells the fold-object scale; FP is cheaper to build |
| D2 | Do folds move with the world? | static once placed vs. carried and thrown | carrying is the signature mechanic, throwing is a stretch goal |
| D3 | Time-rate difference | real mechanic (child scene runs at ×N) vs. cosmetic | real time-dilation is heavy; a "delayed consequence" queue is cheap and reads the same in a demo |
| D4 | Number of fold types | one generic fold vs. two (light/heavy, like/unlike pole) | two types double the puzzle vocabulary; one type is safer |
| D5 | Art route | Muse Image textures vs. untextured primitives + strong lighting | assets eat days; lighting is free |
| D6 | Meta models in the loop | build-time (text, art) vs. runtime (LLM-driven NPC/mission text) | runtime scores higher on "Use of Meta AI Tooling" but adds latency risk |

## Alternate seeds (kept for reference, council may prefer one)

- **A — Polarity as society.** Everyone and everything has a fixed magnetic charge; charge gates who can
  approach whom, and dense clusters warp gravity. You are a Null who can cross zones. (Magnetism as politics,
  not a gadget.)
- **B — Mass-driven nesting.** Anything above critical density collapses into a bubble universe; popping in
  adds its mass to you. (Katamari × Gravity Rush.)
- **C — Gravity lag.** Gravity propagates like light; a falling tower's pull reaches you seconds after you see
  it. Read the echoes, intercept waves with magnets. (Time-adjacent without a rewind button.)

Mashups are allowed (B's mass + C's lag is a coherent single system). Decide with the council, then freeze.
