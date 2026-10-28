# Gravit manual — law, goal, verbs, the one room

## The law (the entire game in two sentences)

Gravity and time belong to the **scope you stand in**, not the world. A fold is
a bounded region with its own gravity direction: inside it you fall the fold's
way. **Carried, a fold is inert. Set down, it is live.** You can never be
inside the gravity you are holding.

## Goal

One room, one stunt. Run the ramp east, ride the Sling's throw, thread the
Uplift, and come down on the platform above the gate. Touchdown wins. The win
screen shows your time and best.

## Verbs (all you can do, all you ever need)

| Input | Effect |
| --- | --- |
| Walk (arrows / WASD / left stick), mouse / right stick look, Space jump | ordinary movement; jump always fires away from your *current* down |
| **E** (pad X) | nothing to grab this level — both folds are bolted down (fixed architecture). Carrying returns in later levels |
| H (pad Y) | next hint |
| T (pad Back) | airlock narration (AI when online, local fold log otherwise) |
| R (pad Start), Esc | restart run / free the mouse cursor |

Nothing else exists: no inventory, no keys, no currency, no enemies, no death.
Miss the landing and you are back on the floor — walk up the ramp and go again.

Designer view of the same mechanics: [`folds-explained.md`](folds-explained.md).

## What you are looking at

- **Coloured translucent cube with a warm light and a particle stream** — a
  fold. Colour is gravity (cyan pulls east, green pulls up); the stream falls
  the fold's way. Read it before you step in.
- **Ring on the ground under a fold** — that is the one E will pick up. No
  ring, no pickup.
- **Hands at the bottom of the screen** — you are carrying a fold. It is
  switched off until you set it down.
- **White billboard plates** — signage only.
- **Amber strip on the platform edge, green glow at the gate** — where to
  land, what you landed above.

## The room, beat by beat

1. **Run.** Sprint east up the ramp, across the deck, and off its edge. The
   cyan Sling catches you and throws you — exit speed is the whole game, and
   the fold supplies all of it.
2. **Thread.** You arrive in the green Uplift doing ~11 m/s. It trades that
   speed for height. Keep holding forward.
3. **Land.** Come down on the platform above the gate. Touchdown wins.

## Properties worth knowing

- You cannot reach the Uplift on foot: its floor is above jump reach and
  the deck gap is double your jump range. The only way in is Sling speed —
  that is the anti-cheat, and it falls out of the geometry.
- Queued consequences fire exactly once, late by design (delay × clock).
  A freed target is dropped and counted, never an error.
- Your up flips with gravity; the camera never rolls. Walking out of a fold
  returns you to normal mid-air and you land safely.
- Timer hides until your first completion, then times every replay; best kept.
