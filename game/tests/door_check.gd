# res://tests/door_check.gd — live exit test for the one room. Player verbs drive it:
# E picks up the Throw fold facing the crate, E sets it down over the crate,
# the crate slides east onto the pad, the pad queues the impulse, the door
# slides open. A second, never-triggered door is the control.
extends Node3D

var frames := 0
var failures := 0
var player = null
var fold = null
var door = null
var control = null
var pad = null
var cube = null

func _ready() -> void:
	player = $Player
	fold = $Room1/Throw
	door = $Room1/Door
	pad = $Room1/Pad
	cube = $Room1/Cube
	control = $ControlDoor

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
		player.global_position = Vector3(-6.5, 0.9, 1.2)
		_check(door.opened_distance() < 0.05, "(viii) door starts shut")
		_check(control.opened_distance() < 0.05, "(viii) control starts shut")
	if frames == 10:
		_press(KEY_E)
	if frames == 15:
		_check(player.carried_fold == fold, "(viii) E picks up the fold")
		player.global_position = Vector3(-6.5, 0.9, -1.5)
		player.rotation.y = -PI / 2.0
	if frames == 70:
		_press(KEY_E)
	if frames == 80:
		_check(player.carried_fold == null, "(viii) E sets it down over the crate")
	if frames == 140:
		_check(pad.last_countdown != "", "(viii) countdown shown while queued")
	if frames == 300:
		_check(door.opened_distance() > 0.5, "(viii) door opened from queued impulse")
		_check(control.opened_distance() < 0.05, "(viii) untriggered door stays shut")
		if failures == 0:
			print("=== DOOR CHECK PASSED ===")
		else:
			printerr("=== DOOR CHECK FAILED: %d ===" % failures)
		get_tree().quit(failures)
