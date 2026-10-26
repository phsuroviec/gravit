# res://tests/door_check.gd — T4 live exit test. Runs Room 1 with real physics
# frames: cube drops through the sideways fold onto the pad, pad queues a
# delayed impulse, door slides open. A second, never-triggered door is the
# control: the door opens ONLY from the queued impulse.
extends Node3D

var frames := 0
var failures := 0
var door = null
var control = null
var pad = null

func _ready() -> void:
	door = $Room1/Door
	pad = $Room1/Pad
	control = $ControlDoor

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("PASS: ", msg)
	else:
		failures += 1
		printerr("FAIL: ", msg)

func _physics_process(_delta: float) -> void:
	frames += 1
	if frames == 5:
		_check(door.opened_distance() < 0.05, "(viii) door starts shut")
		_check(control.opened_distance() < 0.05, "(viii) control starts shut")
	if frames == 80:
		_check(pad.last_countdown != "", "(viii) countdown shown while queued")
	if frames == 100:
		_check(door.opened_distance() < 0.05, "(viii) still shut before due time")
	if frames == 220:
		_check(door.opened_distance() > 0.5, "(viii) door opened from queued impulse")
		_check(control.opened_distance() < 0.05, "(viii) untriggered door stays shut")
		if failures == 0:
			print("=== DOOR CHECK PASSED ===")
		else:
			printerr("=== DOOR CHECK FAILED: %d ===" % failures)
		get_tree().quit(failures)
