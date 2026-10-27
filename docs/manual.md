# Gravit manual — law, goal, verbs, the one room

## The law (the entire game in two sentences)

Gravity and time belong to the **scope you stand in**, not the world. A fold is
a bounded region with its own gravity direction: inside it you fall the fold's
way. **Carried, a fold is inert. Set down, it is live.** You can never be
inside the gravity you are holding.

## Goal

One room. Get the crate onto the teal pad — the door opens after a countdown —
then ride the updraft to the ledge and walk out through the door. The win
screen shows your time and best.

## Verbs (all you can do, all you ever need)

| Input | Effect |
| --- | --- |
| Walk (arrows / WASD / left stick), mouse / right stick look, Space jump | ordinary movement; jump always fires away from your *current* down |
| **E** (pad X) near a fold | pick it up: it goes inert, glides to your hands, contents freeze in place. A glowing ring on the ground marks the fold E will take |
| **E** again | set it down where it floats in front of you: it goes live, contents wake inside it |
| H (pad Y) | next hint |
| T (pad Back) | airlock narration (AI when online, local fold log otherwise) |
| R (pad Start), Esc | restart run / free the mouse cursor |

Nothing else exists: no inventory, no keys, no currency, no enemies, no death,
and nothing can be destroyed — so there is no way to get stuck that R cannot
answer instantly.

Designer view of the same mechanics: [`folds-explained.md`](folds-explained.md).

## What you are looking at

- **Coloured translucent cube with a warm light and a particle stream** — a
  fold. Colour is gravity (cyan pulls east, green pulls up); the stream falls
  the fold's way. Read it before you step in.
- **Ring on the ground under a fold** — that is the one E will pick up. No
  ring, no pickup.
- **Hands at the bottom of the screen** — you are carrying a fold. It is
  switched off until you set it down.
- **Green/teal strip on the floor** — a pad. Only the *crate* sets it off, not
  you. It shoves the room's door open *after the countdown floating above it*.
  It is not a fold and cannot be carried.
- **White billboard plates** — signage only.
- **Amber strip on the ledge edge, green glow in the doorway** — where to
  land, where to leave.

## The room, beat by beat

1. **Throw.** Pick up the cyan fold, carry it to the shelf so it covers the
   crate, set it down. The crate slides east off the shelf and drops onto the
   teal strip. Countdown, door opens.
2. **Ride.** Walk into the green fold. It lifts you; drift east at the top
   onto the ledge and walk through the open door.

## Properties worth knowing

- Folds never move physics bodies: carried bodies stay parented to the room,
  frozen. Setting down wakes them where the fold lands.
- You cannot carry a fold and stand inside it at the same time. Every
  obstacle is: put the patch of down where you need it, use it, leave it to
  move it further.
- Queued consequences fire exactly once, late by design (delay × clock).
  A freed target is dropped and counted, never an error.
- Your up flips with gravity; the camera never rolls. Walking out of a fold
  returns you to normal mid-air and you land safely.
- Timer hides until your first completion, then times every replay; best kept.
