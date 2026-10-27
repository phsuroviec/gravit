# Gravit manual — laws, goal, mechanics, rooms

## The law (the entire game in two sentences)

Gravity and time belong to the **scope you stand in**, not the world. A fold is
a bounded region with its own gravity direction and clock rate: inside it you
fall the fold's way, and anything you set going inside arrives outside late.

## Goal

Four rooms in one run, west to east. Open each room's exit door, walk through,
ride the updraft gate at the end. The win screen shows your time and best.

## Verbs (all you can do, all you ever need)

| Input | Effect |
| --- | --- |
| Walk (arrows / WASD / left stick), mouse / right stick look, Space jump | ordinary movement; jump always fires away from your *current* down |
| **E** (pad X) near a fold | pick it up: shell latches to you, contents freeze in place |
| **E** again | set it down where you stand; contents teleport by the move |
| **X** (pad B) while carrying | **break** it: contents drop where it stands, back in parent gravity |
| H (pad Y) | next hint for your room |
| T (pad Back) | airlock narration (AI when online, local fold log otherwise) |
| R (pad Start), Esc | restart run / free the mouse cursor |

Nothing else exists: no inventory, no keys, no currency, no enemies, no death.
The only fail state is *stuck* (cube somewhere useless) — press **R**, instant.

## The four rooms

1. **First Fall + Ride (watch, then act).** A sideways fold drops its cube
   on a pad; the pad queues a delayed impulse that blasts the high door
   after a countdown. Then step into the side fold and hold W: folds are
   swimmable. Rise through the gate and walk east.
2. **Carry (act).** A frozen fold holds a cube mid-air. Grab it (E), carry to
   the glowing plate, break (X). The cube drops, the door opens.
3. **Nesting (combine).** A fold inside a fold. Grab the *inner* one (deepest
   wins ties), carry it back over the outer shell, break: the cube transfers to
   the outer scope, its leftward gravity throws the cube west onto the plate.
4. **Updraft (ride).** Walk off the edge into the pit and the UP fold catches
   you. Rise through the exit gate hovering in the draft. Falling back in just
   lifts you again — the pit cannot trap you.

## Properties worth knowing

- Folds never move physics bodies: carried bodies stay parented to the room,
  frozen. Breaking preserves everything (contents + child folds transfer up).
- Queued consequences fire exactly once, late by design (delay × clock).
  A freed target is dropped and counted, never an error.
- Your up flips with gravity; the camera never rolls. Walking out of a fold
  returns you to normal mid-air and you land safely.
- Pads queue one impulse per entry; doors blast forward and retract.
- Timer hides until your first completion, then times every replay; best kept.

## If something feels wrong

- Mouse trapped: **Esc**. Fell somewhere odd: **R**. Cube lost: **R**.
- Report: where you stood, what you tried, what you expected. That sentence is
  a complete bug report for this game.
