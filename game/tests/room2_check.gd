# res://tests/room2_check.gd — T5 live exit test, Room 2. Player verbs drive it:
# E picks up the frozen fold, X breaks it over the plate, pad queues the
# impulse, door opens. Parsed key events, real physics frames.
extends Node3D

var frames := 0
var failures := 0
var player = null
var fold = null
var door = null
var pad = null

func _ready() -> void:
	player = $Player
	fold = $Room2/Fold
	door = $Room2/Door
	pad = $Room2/Pad

func _press(keycode: int) -> void:
	var ev := InputEventKey.new()
	ev.keycode = keycode
	ev.pressed = true
	Input.parse_input_event(ev)

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("PASS: ", msg)
	else:
		failures += 1
		printerr("FAIL: ", msg)

func _physics_process(_delta: float) -> void:
	frames += 1
	if frames == 5:
		_press(KEY_E)
	if frames == 10:
		_check(fold.is_carried(), "(r2) E picks up the fold")
		player.global_position = Vector3(14, 1, 2)
	if frames == 15:
		_press(KEY_X)
	if frames == 20:
		_check(not is_instance_valid(fold), "(r2) X breaks the carried fold")
	if frames == 80:
		_check(pad.last_countdown != "", "(r2) countdown shown while queued")
	if frames == 220:
		_check(door.opened_distance() > 0.5, "(r2) break over plate opens door")
		if failures == 0:
			print("=== ROOM2 CHECK PASSED ===")
		else:
			printerr("=== ROOM2 CHECK FAILED: %d ===" % failures)
		get_tree().quit(failures)
