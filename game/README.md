# game/

Godot 4 project root. Open this folder (not the repository root) in Godot.

As-built node layout (2026-10-28, one stunt room):

```
Main.tscn
├── Course           # Room1 + Player + HUD
│   ├── Room1        # ramp, deck, Sling + Uplift (fixed), platform, gate, exit, airlock
│   ├── Player       # CharacterBody3D + Camera3D (+CarryHands, +Mannequin)
│   └── HUD          # objective, prompt, hints, timer, completion
```
