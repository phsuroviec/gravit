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
var sidestep_dir := 1.0
var sidestep_until := 0

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

func _unstick(walking: bool) -> void:
	# Called every frame: hop/strafe only while walking (strafe phases drive
	# z directly and must not fight the stall detector).
	if walking and frames - stall > 30:
		stall = frames
		if player.global_position.x - last_x < 0.3:
			Input.action_press("ui_accept")
			jump_cool = frames + 5
			sidestep_dir = -sidestep_dir
			sidestep_until = frames + 25
		last_x = player.global_position.x
	if jump_cool > 0 and frames > jump_cool:
		Input.action_release("ui_accept")
		jump_cool = 0
	if frames < sidestep_until:
		if sidestep_dir > 0.0:
			Input.action_press("ui_up")
		else:
			Input.action_press("ui_down")
	else:
		Input.action_release("ui_up")
		Input.action_release("ui_down")

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
			_unstick(true)
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
			_unstick(true)
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
		5:  # walk east, then strafe south of the outer shell (its LEFT
			# gravity kills x-movement inside — the path stays trap-free)
			_unstick(true)
			if player.global_position.x > 22.2:
				_hold(false)
				phase = 50
		50:  # strafe to z > 3.4, clear of both shells
			_unstick(false)
			Input.action_press("ui_down")
			if player.global_position.z > 3.4:
				Input.action_release("ui_down")
				_press(KEY_E)
				wait_until = frames + 12
				phase = 6
		6:
			if frames >= wait_until:
				if player.carried_fold == inner3:
					_check(true, "(bot) room3 inner fold picked up")
					_hold(true)
					phase = 60
				else:
					_die("(bot) E missed room3 inner fold")
		60:  # carry back over the outer shell, break: outer throws west
			_unstick(true)
			if player.global_position.x > 23.8:
				_hold(false)
				_press(KEY_X)
				wait_until = frames + 12
				phase = 7
		7:
			if frames >= wait_until:
				if not is_instance_valid(inner3):
					_check(true, "(bot) room3 inner fold broken")
					phase = 70
				else:
					_die("(bot) X missed room3 break")
		70:  # strafe back north before the long walk east
			_unstick(false)
			Input.action_press("ui_up")
			if player.global_position.z < 0.5:
				Input.action_release("ui_up")
				phase = 8
		8:  # wait for exit door, then ride the updraft home
			if door3.opened_distance() > 0.5:
				_check(true, "(bot) room3 exit opened")
				_hold(true)
				phase = 9
			elif frames > 2200:
				_die("(bot) room3 exit never opened")
		9:  # walk into the fold, rise through the gate
			_unstick(true)
			if GameState.completions >= 1:
				_hold(false)
				_check(true, "(bot) updraft gate completes the course")
				_check(hud.timer_unlocked(), "(bot) replay timer unlocked")
				if failures == 0:
					print("=== COURSE CLEAR PASSED ===")
				else:
					printerr("=== COURSE CLEAR FAILED: %d ===" % failures)
				get_tree().quit(failures)
