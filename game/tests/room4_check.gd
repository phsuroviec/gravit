# res://tests/room4_check.gd — T12 live exit test. Bot walks into the UP fold,
# rides it, drifts onto the ledge, walks out through the exit. No teleports.
extends Node3D

var frames := 0
var failures := 0
var player = null

func _ready() -> void:
	player = $Player

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("PASS: ", msg)
	else:
		failures += 1
		printerr("FAIL: ", msg)

func _physics_process(_delta: float) -> void:
	frames += 1
	if frames == 5:
		Input.action_press("ui_right")
	if frames == 100:
		_check(player.global_position.y > 2.0, "(r4) updraft catches the player")
	if frames == 300:
		_check(GameState.completions >= 1, "(r4) rising through the gate completes")
		Input.action_release("ui_right")
		if failures == 0:
			print("=== ROOM4 CHECK PASSED ===")
		else:
			printerr("=== ROOM4 CHECK FAILED: %d ===" % failures)
		get_tree().quit(failures)
