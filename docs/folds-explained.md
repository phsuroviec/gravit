# What a fold is — designer primer

The design source of truth for the fold law in plain language; the frozen
version lives in [`game-concept.md`](game-concept.md), the player version in
[`manual.md`](manual.md).

## The one idea

Gravity and time are not properties of the world. They are properties of **the scope you are
standing in**. The world's scope has gravity down and clock 1. A **fold** is a small box-shaped
scope you can see and touch. Inside it, a different gravity applies. Nothing else changes: no
portals, no second world, no separate physics.

## What a fold physically is

- A **box-shaped region**, drawn as a translucent cube with a warm light inside and a stream of
  particles running through it. Its **colour is its gravity**: cyan pulls +X (east), magenta pulls
  −X (west), green pulls up, blue pulls down.
- The particle stream is not decoration. **It falls the fold's way**, in the same colour. Look at
  the stream and you read the fold's gravity before you step in.
- It is not a wall: you can walk into it, and anything can fall through it.
- It carries exactly **two authored numbers**: `gravity_dir` (which way is down inside it) and
  `clock_factor`. A fold can also be **fixed** (architecture — E ignores it) or carried.
- It has a **shell boundary** — the visible box face. Crossing that boundary is the only thing
  that changes your gravity. Nothing is gradual: in or out.

## The abilities (the entire set)

| # | Ability | What the player sees |
| --- | --- | --- |
| 1 | **Redirects fall** | Anything inside falls the fold's way, at up to 9.8 m/s². |
| 2 | **Runs its own clock** | Consequences started inside it land later outside, scaled by `clock_factor`. |
| 3 | **Can be carried — inert** | Press **E** to lift it. Its scope switches off: it lends no gravity to anything, including you. Contents freeze and ride along. Nothing is destroyed, so nothing can be lost. |
| 4 | **Goes live when placed** | Press **E** again to set it down. Its scope switches on; contents wake inside it and fall the fold's way. |

That is all. And the constraint that makes it a game: **you cannot carry a fold and stand
inside it at the same time**, and in the air your motion persists — momentum survives scope
boundaries, so a fast exit from one fold is a fast entry to the next.

## The rules that make it feel fair (boundaries)

- **One fold at a time.** You can carry exactly one. The fold you can pick up is marked
  with a glowing ring and a brightened shell — if there is no ring, E does nothing.
- **Fixed folds are architecture.** Level 1 bolts both folds down: no ring, no prompt, no grab.
- **Air keeps its velocity, ground snaps to input.** Steering in flight accelerates toward
  wish speed but never bleeds existing motion — holding a direction preserves a 10 m/s
  throw, holding back slows you.
- **The camera never rolls.** Your up flips with gravity; the view stays level. A fold flip
  fires an FOV kick plus a whoosh so the transition reads as an event. Facing the launcher,
  you already look where you are about to fall — no reorientation is ever needed.
- **No fail state except missing.** Miss a landing and you are on the floor; walk back and
  retry. R restarts, but it is a choice, never a rescue.

## The one room, and what each beat teaches

1. **Run.** Sprint east up the ramp, across the deck, off its edge. The cyan Sling catches
   you and throws you — exit speed is the whole game, and the fold supplies all of it.
   Teaching: *a fold changes fall, and you are subject to it too.*
2. **Thread.** You arrive in the green Uplift doing ~11 m/s. It trades that speed for height.
   Keep holding forward. Teaching: *momentum survives the boundary — speed in is height out.*
   The Uplift's floor sits above jump reach and a full jump-range from the deck: the only
   way in is Sling speed. That geometry is the anti-cheat, not a rule.
3. **Land.** Come down on the platform above the gate — a scoop on its west edge catches
   low arrivals. Touchdown wins. Teaching: *the arc is the answer.*

## Design guardrails (do not drift)

- Every fold's numbers are **authored, never emergent** — each room states its gravity and clock.
- Folds **never move physics bodies themselves**; they only provide the gravity function every body
  samples. If a puzzle needs a body to move, it moves because it fell.
- If a mechanic cannot be shown in the three-minute demo, it is out of scope (see `ROADMAP.md`).
