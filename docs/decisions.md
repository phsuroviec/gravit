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
