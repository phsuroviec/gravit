# Run Gravit in Godot (5 minutes, no experience needed)

You need: a computer, patience for one download, and this repo.

## 1. Install Godot 4.7.2

- Go to **godotengine.org → Download**, take the **4.7.2 standard** build for
  **Windows** (the `.zip`, 64-bit). Extract it anywhere and run `Godot.exe`.
  No installer, no account, no setup wizard.
- (macOS/Linux builds exist too and work the same; macOS only: right-click →
  Open once to clear Gatekeeper.)

## 2. Open the project

- In Godot's project list: **Import** → open the **`game/` folder inside this
  repo** (select its `project.godot`) → **Open**. Open `game/`, never the repo root.
- First boot imports art (~30 s, one time). If anything looks grey, let it
  finish and press Play again.

## 3. Play

> The editor viewport shows all four rooms laid out flat in one long strip —
> that is the whole course, not a jumble. There are no walls between rooms yet
> (greybox phase); Room 1 is at the left, the updraft gate at the far right.
> Press Play and walk right: that strip becomes the game.

Press **Play** (▶ top-right, or F5). You spawn in Room 1.

| Keyboard + mouse | Controller (e.g. 8BitDo Ultimate 2) | Action |
| --- | --- | --- |
| Arrows (Up = forward) | Left stick / d-pad | walk |
| Mouse (click once to capture) | Right stick | look |
| Space | A (bottom button) | jump, away from current down |
| E | X (left button) | pick up / set down fold |
| X key | B (right button) | break carried fold |
| H | Y (top button) | next hint |
| T | Back/Select | narrate |
| R | Start | restart |

Both schemes are live at the same time — swap mid-run freely, no menu needed.
If the controller does nothing: wake it first (press any button), then check
Godot sees it (Editor → no; in-game, the left stick should walk immediately).

## 4. Goal (spoiler-light)

Three rooms, then an updraft gate. Room 1 demonstrates the law; Room 2 you
carry a frozen fold to a plate and break it; Room 3's nested fold throws the
cube; Room 4 ride the updraft through the gate. Stuck anywhere: **R** restarts
instantly, nothing punishes you.

## 5. For the curious (verify it like the bot does)

```bash
godot --headless --path game -s res://tests/test_runner.gd  # 50+ unit asserts
godot --headless --path game res://tests/course_clear.tscn  # bot plays all rooms
```

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Grey/untextured meshes on first run | import still running; wait, Play again |
| Mouse doesn't look | click the game window once to capture; Esc frees it |
| Controller ignored | wake it with a button press; re-plug; Steam Input can swallow devices — disable it for Godot |
| Player falls forever | you walked off an edge; R restarts |
| Anything else | note where + what you expected; that's a bug report |
