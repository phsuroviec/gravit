# res://tests/course_clear.gd — autonomous one-room clear. A scripted bot plays
# course.tscn end to end with the real verbs: carry the Throw fold over the
# crate, set it down, wait out the pad countdown, ride the Updraft to the
# ledge, walk through the opened door into the exit. Stuck phases fail loud.
extends Node3D

var frames := 0
var failures := 0
var phase := 0
var wait_until := 0

var player = null
var throw_fold = null
var updraft = null
var cube = null
var pad = null
var door = null
var hud = null

func _ready() -> void:
	player = $Course/Player
	throw_fold = $Course/Room1/Throw
	updraft = $Course/Room1/Updraft
	cube = $Course/Room1/Cube
	pad = $Course/Room1/Pad
	door = $Course/Room1/Door
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

func _die(msg: String) -> void:
	failures += 1
	printerr("FAIL: ", msg)
	_hold(false)
	get_tree().quit(failures)

func _physics_process(_delta: float) -> void:
	frames += 1
	if frames > 2600:
		_die("(bot) global timeout — room not cleared")
		return
	match phase:
		0:  # walk to the Throw fold and pick it up
			player.global_position = Vector3(-6.5, 0.9, 1.2)
			_press(KEY_E)
			wait_until = frames + 12
			phase = 1
		1:
			if frames >= wait_until:
				if player.carried_fold == throw_fold:
					_check(true, "(bot) throw fold picked up")
					player.global_position = Vector3(-6.5, 0.9, -1.5)
					player.rotation.y = -PI / 2.0
					wait_until = frames + 50
					phase = 2
				else:
					_die("(bot) E missed the throw fold")
		2:  # let the carried shell glide to the hands, then set it down
			if frames >= wait_until:
				_press(KEY_E)
				wait_until = frames + 12
				phase = 3
		3:
			if frames >= wait_until:
				if player.carried_fold == null:
					_check(true, "(bot) throw fold set down over the crate")
					player.rotation.y = 0.0
					wait_until = frames + 120
					phase = 4
				else:
					_die("(bot) E did not set the fold down")
		4:  # the crate slides east onto the pad; the countdown runs
			if frames >= wait_until:
				if pad.last_countdown != "":
					_check(true, "(bot) pad countdown runs")
					wait_until = frames + 180
					phase = 5
				else:
					_die("(bot) crate never reached the pad")
		5:  # the queued impulse slides the door open
			if frames >= wait_until:
				if door.opened_distance() > 0.5:
					_check(true, "(bot) door opened")
					player.global_position = Vector3(0.6, 0.9, 0)
					_hold(true)
					wait_until = frames + 200
					phase = 6
				else:
					_die("(bot) door never opened")
		6:  # walk east into the updraft, then ride it: y must climb
			if player.global_position.x > 2.3:
				_hold(false)
				wait_until = frames + 90
				phase = 60
			elif frames > wait_until:
				_die("(bot) never walked into the updraft")
		60:
			if frames >= wait_until:
				if player.global_position.y > 2.2:
					_check(true, "(bot) updraft lifts the player")
					_hold(true)
					phase = 7
				else:
					_die("(bot) updraft did not lift (y=%.2f)" % player.global_position.y)
		7:  # drift east mid-air onto the ledge, then walk through the door
			if player.global_position.x > 5.0 and player.global_position.y < 3.2:
				_check(true, "(bot) landed on the ledge")
				phase = 8
			elif frames > wait_until + 400:
				_die("(bot) never reached the ledge")
		8:
			if player.global_position.x > 9.0:
				_hold(false)
				if hud.get_node("Complete").visible:
					_check(true, "(bot) walked out through the exit")
				else:
					_die("(bot) exit zone did not complete the run")
				if failures == 0:
					print("=== COURSE CLEAR PASSED ===")
				else:
					printerr("=== COURSE CLEAR FAILED: %d ===" % failures)
				get_tree().quit(failures)
			elif frames > wait_until + 900:
				_die("(bot) never walked through the door")
