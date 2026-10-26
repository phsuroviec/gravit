# Levels — the three rooms

**Authored, not generated.** The research pass specified one idea per room with concrete numbers; those specs are
locked here so T4/T5 build to them instead of inventing layouts. Nobody needs to design puzzles from scratch, and no
room is procedurally generated (see "Why not random" at the bottom).

Design rule for all three, from the report's psychology section (Hodent's onboarding, Loewenstein's curiosity gap,
Blow's Assumption → Catch → Revelation, Valve's telegraphing):

- one new idea per room, executed immediately, no text walls;
- failure costs nothing: no lethal hazards, a broken fold never traps you, `[R]` restarts instantly;
- sightline + warm spotlight on the thing that matters, cool walls everywhere else;
- an airlock door closes behind you between rooms so the previous room is never mistaken for this puzzle.

## Room 1 — The Sideways Ledge (scoped gravity)

| | |
| --- | --- |
| What you see | compact chamber; exit ledge **4 m overhead (+Y)**, too high to jump; a glowing cyan **Fold A** whose gravity points **+X** |
| What you do | step into the fold, fall sideways onto the wall ledge, walk out onto the exit platform |
| What you learn | gravity is a property of the space you stand in |
| Soft-lock guard | the fold is always reachable from the floor; walking out returns you to normal gravity mid-air and you land safely |
| Numbers | fold gravity +X at 9.8 m/s²; fold is 3 × 3 × 3 m; ledge at y = 4.0 |

## Room 2 — The Caged Cube (carry, place, break)

| | |
| --- | --- |
| What you see | a cube locked in a cage behind glass; a floor plate that holds the exit door open; a **Fold B** (gravity −Y, i.e. normal down) |
| What you do | push the fold over the cube, **carry** it to the plate, **break** it — the cube drops onto the plate and the door opens |
| What you learn | a fold is a container: break it and its contents come back to the parent world |
| Soft-lock guard | the cube can always be re-collected: breaking the fold preserves the cube, and the cage is never re-locked |
| Numbers | fold 3 × 3 × 3 m; carrying freezes the cube; plate must be pressed for 0 s (latching door, not hold-to-open) |

## Room 3 — The Delayed Door (nested fold + queued consequence)

The climax: Assumption → Catch → Revelation in one room.

| | |
| --- | --- |
| What you see | exit door at the end of an **8 m glass corridor**; an **Impulse Pad** that fires a striker into a door latch; two folds — **Fold A** (clock 0.5×, depth 1) and **Fold B** (nested) |
| The Catch | the latch holds the door **1.5 s** — far less than a sprint down 8 m, so the naive "trigger the pad then run" fails by a clear margin |
| The Revelation | place Fold A over the pad, nest Fold B inside it (**depth 2** ⇒ a **4.0 s** delay), trigger the pad inside the nested fold: an orange **4.0 s floating countdown** appears over the cube, and the door opens while you are already walking |
| What you learn | nesting multiplies the delay: an event set going inside a fold lands in the parent world later |
| Soft-lock guard | the pad can be re-triggered unlimited times; the countdown is visible from the corridor so the failure is legible, never mysterious |
| Numbers | run speed ≈ 4 m/s (8 m ≈ 2 s), latch 1.5 s, depth-2 delay 4.0 s, countdown 4.0 s |

## Authoring workflow

1. I (or the agent) write the room spec here — geometry, numbers, exit condition, soft-lock guard.
2. The agent builds it as a greybox `.tscn` (CSGBox3D + collision) and adds the exit test to the headless suite
   where the rule is testable (plate pressed, door unlocked by a queued event).
3. You playtest and change **numbers only** at first (speeds, distances, timings). Geometry changes need a spec edit
   so the report's rationale does not silently rot.
4. If a room cannot be made soft-lock-free, shrink it — do not add a fail state.

## Why not random

Procedural rooms need a solver to guarantee "exit reachable only via the law" and a difficulty model to avoid
unsolvable or trivial layouts. That is a multi-week project by itself, and a random room can contradict the
one-idea-per-room teaching order. The only generated geometry is the **optional** Baseten open-weight "room-architect"
variant (T6): a *curated* alternative layout checked into the repo, played once in the demo for the open-weight bonus
claim — never at runtime, never shipped as the main course.
