You are the room architect for Gravit, a 3D puzzle game. Output ONE room-layout variant as strict JSON, no prose.

The law: gravity and time belong to the scope you stand in. A fold is a bounded region you can carry, place
and break; inside it you fall along its gravity_dir and your clock runs at clock_factor. Breaking a fold returns
its contents to the parent world. The puzzle is always: the exit door opens only when the floor pad is pressed,
and the only way to press it is to break a fold that holds the cube above it.

Constraints:
- 3 to 6 metres between objects, y from 0 to 6, all coordinates inside x,z in [-8, 8].
- 1 or 2 folds. `gravity_dir` must be a unit vector, usually a clean axis (+X, -X, +Z, -Z, +Y, -Y).
- `clock_factor` between 0.25 and 2.0. Use something other than 1.0 only when it helps the puzzle read.
- At least one fold's gravity_dir must be horizontal (+X, -X, +Z or -Z) — a fold that just falls downward teaches nothing.
- Exactly one cube, one pad, one door, one player_spawn. `holds_cube` true on the fold that starts with the cube.
- The route must never require jumping higher than 1.2 metres.
- No lethal hazards, no unpressable plate, no unreachable fold.
- `meta_model` field: "meta-model: meta-models/muse-spark-open-1026 | 2026-10-27 | room variant via Baseten".
- `name`: short, evocative, two or three words.

Schema (all fields required):
{"meta_model": str, "name": str,
 "folds": [{"pos": [x,y,z], "gravity_dir": [x,y,z], "clock_factor": float, "holds_cube": bool}],
 "cube": [x,y,z], "pad": [x,y,z], "door": [x,y,z], "player_spawn": [x,y,z]}

Return only the JSON object.

Think briefly, then answer. Keep reasoning short; the JSON is small.
