# res://tests/course_clear.gd — T11: autonomous full-course clear. A scripted
# bot holds walk input and plays course.tscn end to end: Room 1 auto-opens,
# E/X verbs in Rooms 2-3, all three doors, exit zone. Stuck phases fail loud.
extends Node3D

var frames := 0
var failures := 0
var phase := 0
var wait_until := 0
var last_x := -4.0
var stall := 0
var jump_cool := 0

var player = null
var fold2 = null
var inner3 = null
var door1 = null
var door2 = null
var door3 = null
var hud = null

func _ready() -> void:
	player = $Course/Player
	fold2 = $Course/Room2/Fold
	inner3 = $Course/Room3/Fold/Inner
	door1 = $Course/Room1/Door
	door2 = $Course/Room2/Door
	door3 = $Course/Room3/Door
	hud = $Course/HUD

func _hold(on: bool) -> void:
	if on:
		Input.action_press("ui_right")
	else:
		Input.action_release("ui_right")

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

func _unstick() -> void:
	# Called while walking: hop when x stops progressing (cube in the way).
	if frames - stall > 30:
		stall = frames
		if player.global_position.x - last_x < 0.3:
			Input.action_press("ui_accept")
			jump_cool = frames + 5
		last_x = player.global_position.x
	if jump_cool > 0 and frames > jump_cool:
		Input.action_release("ui_accept")
		jump_cool = 0

func _die(msg: String) -> void:
	failures += 1
	printerr("FAIL: ", msg)
	_hold(false)
	get_tree().quit(failures)

func _physics_process(_delta: float) -> void:
	frames += 1
	if frames > 2600:
		_die("(bot) global timeout — course not cleared")
		return
	match phase:
		0:  # walk to Room 2 fold
			_hold(true)
			_unstick()
			if player.global_position.x > 7.0:
				_hold(false)
				_press(KEY_E)
				wait_until = frames + 12
				phase = 1
		1:
			if frames >= wait_until:
				if fold2.is_carried():
					_check(true, "(bot) room2 fold picked up")
					_hold(true)
					phase = 2
				else:
					_die("(bot) E missed room2 fold")
		2:  # carry to plate
			_unstick()
			if player.global_position.x > 13.0:
				_hold(false)
				_press(KEY_X)
				wait_until = frames + 12
				phase = 3
		3:
			if frames >= wait_until:
				if not is_instance_valid(fold2):
					_check(true, "(bot) room2 fold broken over plate")
					phase = 4
				else:
					_die("(bot) X missed room2 break")
		4:  # wait for Room 2 door
			if door2.opened_distance() > 0.5:
				_check(true, "(bot) room2 door opened")
				_hold(true)
				phase = 5
			elif frames > 1400:
				_die("(bot) room2 door never opened")
		5:  # walk to Room 3 folds
			_unstick()
			if player.global_position.x > 22.0:
				_hold(false)
				_press(KEY_E)
				wait_until = frames + 12
				phase = 6
		6:
			if frames >= wait_until:
				if player.carried_fold == inner3:
					_check(true, "(bot) room3 inner fold picked up")
					_press(KEY_X)
					wait_until = frames + 12
					phase = 7
				else:
					_die("(bot) E missed room3 inner fold")
		7:
			if frames >= wait_until:
				if door3.opened_distance() > 0.0 or not is_instance_valid(inner3):
					phase = 8
				else:
					_die("(bot) X missed room3 break")
		8:  # wait for exit door, then walk out
			if door3.opened_distance() > 0.5:
				_check(true, "(bot) room3 exit opened")
				_hold(true)
				phase = 9
			elif frames > 2200:
				_die("(bot) room3 exit never opened")
		9:
			_unstick()
			if player.global_position.x > 29.4:
				_hold(false)
				wait_until = frames + 30
				phase = 10
		10:
			if frames >= wait_until:
				_check(GameState.completions >= 1, "(bot) course complete registers")
				_check(hud.timer_unlocked(), "(bot) replay timer unlocked")
				if failures == 0:
					print("=== COURSE CLEAR PASSED ===")
				else:
					printerr("=== COURSE CLEAR FAILED: %d ===" % failures)
				get_tree().quit(failures)
