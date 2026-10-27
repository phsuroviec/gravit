# What a fold is — designer primer

Read this first. It is the design source of truth for the fold law in plain language; the frozen
version of the law itself lives in [`game-concept.md`](game-concept.md), and the player-facing
version in [`manual.md`](manual.md).

## The one idea

Gravity and time are not properties of the world. They are properties of **the scope you are
standing in**. The world's scope has gravity down and clock 1. A **fold** is a small box-shaped
scope you can see, touch, carry, place and break. Inside it, a different gravity and a different
clock rate apply. Nothing else changes: no portals, no second world, no separate physics.

## What a fold physically is

- A **2 m × 2 m × 2 m region**, drawn as a translucent cube with a warm light inside and a stream of
  particles running through it. Its **colour is its gravity**: cyan pulls +X (east), magenta pulls
  −X (west), green pulls up, blue pulls down. Two folds side by side never look like one object.
- The particle stream is not decoration. **It falls the fold's way**, in the same colour. Look at the
  stream and you read the fold's gravity before you step in.
- It is not a wall: you can walk into it, and anything can fall through it.
- It carries exactly **two authored numbers**: `gravity_dir` (which way is down inside it) and
  `clock_factor` (how fast time runs inside it, 1.0 = same as the world, 2.0 = twice as slow).
- It has a **shell boundary** — the visible cube face. Crossing that boundary is the only thing
  that changes your gravity. Nothing is gradual: in or out.

## The four things a fold does (its entire ability set)

| # | Ability | What the player sees |
| --- | --- | --- |
| 1 | **Redirects fall** | Anything inside falls the fold's way, at up to 9.8 m/s². A fold pointed east throws a cube east. |
| 2 | **Runs its own clock** | Consequences started inside it land later in the world outside, scaled by `clock_factor`. A pad inside a 2× fold fires its door twice as late. |
| 3 | **Can be carried and placed** | Press **E** to lift it; its contents freeze in place and ride along. Press **E** again to set it down where it floats in front of you. |
| 4 | **Can be broken** | Press **X** while carrying it to destroy the shell. Its contents and any nested folds are handed back to the surrounding scope — they then fall the *outer* way. |

That is all. No combat, no keys, no inventory, no third ability hiding in a menu. Every puzzle in
the game is a combination of those four: change which way a thing falls, change when a thing
arrives, move the region so a thing falls somewhere new, or remove the region so a thing falls the
old way again.

## The rules that make it feel fair (boundaries)

- **One fold at a time.** You can carry exactly one. The fold you can pick up right now is marked
  with a glowing ring on the ground and a brightened shell — if there is no ring, E does nothing.
- **Reach is to the shell, not the centre.** You can grab when you are within 3 m of the membrane.
  Nested folds prefer the inner one when two are in reach.
- **The held fold floats in front of you, not on you.** It sits 2 m ahead, 0.6 m below eye level and
  0.4 m to your right; a wall in front pulls it closer, never closer than 1.5 m. While held its
  shell dims to a faint film (you can see through it) and two hands appear at the bottom of the
  screen holding it. This is the whole fix for "picking it up is disorienting": the fold *glides*
  to your hands over ~0.15 s, it never teleports through your face, and you always know what you
  are holding.
- **Setting down** (E) drops it exactly where it was floating — including the wall-squeezed
  position. You never place it inside yourself or inside geometry.
- **The drop point stays inside the scope you are standing in.** The hold distance is under a fold's
  own width on purpose: if you break a fold while standing in an outer fold, its contents land
  inside that outer fold and inherit *its* gravity. Break it from outside and they land in the
  world. That choice is the room-3 puzzle, so the numbers are tuned, not arbitrary.
- **Contents are frozen while carried.** Cubes inside it stop moving and keep their offset, so a
  carried fold is a box of held cargo. Breaking it releases the cargo where it stands.
- **Breaking preserves everything.** Contents and child folds transfer to the parent scope. Nothing
  is ever destroyed by the fold being removed; it just changes which way it falls.
- **Nesting is legal.** A fold inside a fold: the deepest one wins for anything inside it. Breaking
  the inner one hands its contents to the outer one — which is how room 3 throws a cube west.
- **Pads and doors are not folds.** They are ordinary world objects; folds only change how things
  fall near them and how late their consequences arrive.

## The green/teal tile on the floor

That is a **pad** — a pressure plate, not a fold and not a pickup. Its full rule:

1. Something with physics enters it (you, or a cube).
2. It queues **one delayed shove** on the room's door. The countdown number floating above the pad
   is that delay, ticking down in real seconds.
3. When the countdown hits zero the door is blasted open for a while, then it retracts.

Why it exists: it is the cheapest way to make the fold's **clock** visible. If the pad is fed from
inside a 2× fold, the door opens twice as late — same pad, same shove, different arrival time. The
pad is the clock made legible, and it is how room 1 teaches "inside time is not outside time"
without a single line of tutorial text.

The other floor marks are just signage: the billboard plates with warnings and arrows. They are
decals, not objects.

## Goals and objectives

- **The run's goal:** clear four rooms west to east in one continuous run and ride the final
  updraft gate. Timer is hidden until your first clear, then it times replays.
- **Every room's objective is the same shape:** a door is closed, and the only way to open it is to
  make something fall somewhere it would not otherwise fall. The fold is the verb.
- **No fail state except stuck** (a cube in a useless place, or you fell). **R** restarts the run
  instantly, so experimentation is free — this is a puzzle game about trying things.

## The four rooms, and which ability each one teaches

1. **First Fall + Ride** — watch ability 1 and 2 happen without you; then use the fold as a
   swimmable column (hold W) to climb out. Teaching: *a fold changes fall, and you are subject to it
   too.*
2. **Carry** — a fold holds a cube in mid-air with its gravity pointing down, so the cube floats
   inside it. Pick the fold up (E), walk it over the plate, break it (X). Teaching: *carrying a
   scope moves the scope, not the thing.*
3. **Nesting** — a fold inside a fold. Break the inner one and the cube is handed to the outer one,
   whose leftward gravity throws the cube west onto the plate. Teaching: *scopes nest, and breaking
   one hands content outward.*
4. **Updraft** — an UP fold in a pit. Walk off the edge, get caught, rise. Teaching: *a fold can be
   a lift you do not have to hold.* Plus the exit gate is reachable only while inside it.

## How to use a fold, in the order you will actually do it

1. Find the ring: that is the fold E will take.
2. Read its particle stream: that arrow is "down" inside it.
3. Decide where that down should point when you are done. Placing a fold where something can fall
   is the whole move.
4. E to lift, walk, E to set down (cargo positions warp with it — that is a legitimate way to move a
   cube through a gap it could not roll through).
5. X to break when you want the contents handed back to normal gravity at that spot.
6. If the result is wrong, R. Nothing is consumed, nothing is permanent.

## Design guardrails (do not drift)

- Every fold's numbers are **authored, never emergent** — each room states its gravity and clock.
- Folds **never move physics bodies themselves**; they only provide the gravity function every body
  samples. If a puzzle needs a body to move, it moves because it fell.
- If a mechanic cannot be shown in the three-minute demo, it is out of scope (see `ROADMAP.md`).
