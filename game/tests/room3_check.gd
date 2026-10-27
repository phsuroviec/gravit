# res://tests/room3_check.gd — T12 live exit test, Room 3 (nested folds).
# E grabs the inner fold, bot carries it south of the outer shell and breaks:
# the cube appears inside the outer scope, gets thrown west onto the pad.
extends Node3D

var frames := 0
var failures := 0
var player = null
var inner = null
var outer_scope = null
var cube = null
var door = null
var pad = null

func _ready() -> void:
	player = $Player
	inner = $Room3/Fold/Inner
	outer_scope = $Room3/Fold/FoldScope
	cube = $Room3/Cube
	door = $Room3/Door
	pad = $Room3/Pad

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
		_check(player.carried_fold == inner, "(r3) E grabs the deepest fold")
		_check(inner.get_scope().parent_scope == outer_scope, "(r3) inner nests under outer")
		player.global_position = Vector3(24, 1, 4)
	if frames == 15:
		_press(KEY_X)
	if frames == 80:
		_check(cube.global_position.x < 22.5, "(r3) outer scope throws the cube west")
		_check(pad.last_countdown != "", "(r3) countdown shown while queued")
	if frames == 220:
		_check(door.opened_distance() > 0.5, "(r3) nested break opens the exit")
		if failures == 0:
			print("=== ROOM3 CHECK PASSED ===")
		else:
			printerr("=== ROOM3 CHECK FAILED: %d ===" % failures)
		get_tree().quit(failures)
