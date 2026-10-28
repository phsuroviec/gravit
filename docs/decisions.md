# Decisions (ADR-lite)

Small, dated, reversible-only-on-purpose. Every entry: what we chose, what it costs, and what would make us revisit.
Tickets reference these instead of re-arguing them.

## ADR-1 — Fold contents are stored as `NodePath` (2026-10-26)

**Chosen:** a fold keeps a list of `NodePath`s to the bodies inside it, resolved with `get_node_or_null()`.
**Why:** paths survive a scene save/reload and node renaming inside the same tree; a direct object reference goes stale
the moment a body is freed (breaking a fold) and then every later access is a crash risk.
**Cost:** a resolution step on every access, and a missing node has to be handled explicitly.
**Revisit if:** bodies ever live outside the fold's scene subtree (then a registry keyed by instance id is better).

## ADR-2 — `FoldScope` is a `Node3D`, not a `Resource` (2026-10-26)

**Chosen:** `fold_scope.gd` extends `Node3D`, holds `gravity_dir: Vector3`, `clock_factor: float`, `parent_scope`
and a `depth` derived from the chain. No physics of its own.
**Why:** it must be placeable in a `.tscn` and inspectable in the editor, and headless tests can still
`FoldScope.new()` + add it to a `SceneTree` with no main scene. A `Resource` serialises nicely but is clumsy to
attach per-room, and an `Area3D` would mix collision with bookkeeping.
**Cost:** one extra node per fold.
**Revisit if:** folds need to be authored as data-only presets shared across rooms — then the Node3D reads a Resource.

## ADR-3 — Cycles are refused *and* reported (2026-10-26)

**Chosen:** `FoldScope.add_child_scope(child) -> bool`. It returns `false`, pushes a warning naming both scopes, and
leaves the tree untouched when the operation would create a cycle or give a scope a second parent.
**Why:** a silently-degraded fold is a puzzle that behaves differently every run. The test asserts both the refusal
and that `depth` did not change.
**Cost:** callers must check the return value.

## ADR-4 — A queued consequence whose body is gone is dropped, counted, never thrown (2026-10-26)

**Chosen:** `ConsequenceQueue` stores `(NodePath, impulse, due_time)`. At fire time it resolves the path; if the node
is missing it drops the entry and increments `dropped`. No exception, no retry, no log spam.
**Why:** breaking a fold destroys the bodies inside it while a consequence may already be queued; that is a normal
game state, not an error. Invariant (iii) is "fires exactly once", and "never fires at all if the target is gone" is the
honest completion of it.
**Cost:** a `dropped` counter everyone must be able to see in the test output.

## ADR-5 — Air inertia, ground feel frozen (2026-10-28)

**Chosen:** the player keeps velocity in the air (light drag + steering that
never decelerates existing motion) and keeps the exact snap-to-wish on the
ground. Momentum is a flight property, never a walking one.
**Why:** the stunt level (launcher → thread → landing) is physically
impossible otherwise — velocity is currently rebuilt every frame, so coasting
does not exist. Ground code is untouched, so all existing bots behave the same.
**Cost:** a Quake-style accelerate rule to review (`lateral += wish * add`,
capped so holding a direction never bleeds speed).
**Revisit if:** flight ever needs hard speed caps (then cap, don't remove).

## ADR-6 — Level 1 folds are fixed architecture (2026-10-28)

**Chosen:** both folds of level 1 are bolted down (`FoldBox.fixed`): E does
nothing near them, no ring, no prompt. Carrying returns in later levels, where
placement is the puzzle.
**Why:** the level is a skill stunt with tuned geometry; a grabbable launcher
lets the player dismantle the stunt.
**Cost:** one exported bool + a skip in `nearest_fold`.
**Revisit if:** a level wants player-placed launchers.

## ADR-7 — Pure stunt level, touchdown wins (2026-10-28)

**Chosen:** level 1 has no crate, no pad, no lock. The gate recess is always
open visually; the exit zone covers the landing platform, so touchdown is the
win. Missing means landing on the floor and walking back up the ramp — retry
is free, there is no fail state.
**Why:** the owner-specified design: launcher momentum → thread the upper fold
→ land. A second precision move (drop into the gate) stacked on the landing
would punish the first success.
**Cost:** E, the pad and the queue sit out one level.
**Revisit if:** the level playtests too easy — the lock returns before the
stunt is re-tuned.

## ADR-8 — Camera never rolls; flips are cued (2026-10-28)

**Chosen:** the camera keeps world-upright through gravity flips. Each flip
fires a short FOV kick plus a whoosh so the transition reads as an event.
**Why:** facing the launcher, the player already looks where they are about to
fall; after the upper fold they already look at the gate wall. No
reorientation is needed, and rolling the camera would demand one.
**Cost:** one FOV punch decay + one synthesized sweep in `sfx.gd`.
**Revisit if:** playtesters report not noticing flips — then cue harder, still
don't roll.

## ADR-9 — First-person mannequin, head below the camera (2026-10-28)

**Chosen:** a thin shiny-white humanoid rides the player: feet at the capsule
bottom, head top just under eye height, arms static at the sides. The whole
body slerps so its feet point along gravity — the inversion is visible on the
body while the camera stays level.
**Why:** looking down must show a body for the flips to feel physical, and a
visible swinging body sells what a rolling camera would have cost in nausea.
**Cost:** ~12 mesh instances + per-frame basis slerp with a degenerate-input
guard.
**Revisit if:** the head ever clips the near plane — then shrink the head,
never move the camera.
