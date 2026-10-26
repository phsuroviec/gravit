# game/

Godot 4 project root. Open this folder (not the repository root) in Godot.

Planned node layout (filled in from the roadmap, not final):

```
Main.tscn
├── Course           # 3-4 rooms, grey-boxed
│   ├── Room1..3
│   └── Exit         # reachable only via the fold law
├── Player           # CharacterBody3D
├── Folds            # each fold is a placed scene with its own gravity
└── HUD              # start/restart only
```
