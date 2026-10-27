# res://tests/variant_check.gd — T6 bonus exit test: the open-weight layout
# plays. Bot walks to the holding fold, carries to the pad, breaks; the
# queued impulse opens the generated door. Same verbs, generated numbers.
extends Node3D

const VariantRoom = preload("res://scripts/variant_loader.gd")

var frames := 0
var failures := 0
var phase := 0
var wait_until := 0
var player = null
var room = null
var fold0 = null
var door = null
var pad = null

func _ready() -> void:
	var text := FileAccess.get_file_as_string("res://data/variant_open.json")
	var parsed: Variant = JSON.parse_string(text)
	room = VariantRoom.build(parsed as Dictionary)
	room.name = "Variant"
	add_child(room)
	player = $Player
	player.active_scopes = get_tree().get_nodes_in_group("fold_scopes")
	fold0 = room.get_node("Fold0")
	door = room.get_node("Door")
	pad = room.get_node("Pad")
	var spawn: Array = (parsed as Dictionary)["player_spawn"]
	player.global_position = Vector3(float(spawn[0]), float(spawn[1]), float(spawn[2]))

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

func _hold(on: bool) -> void:
	if on:
		Input.action_press("ui_right")
	else:
		Input.action_release("ui_right")

func _physics_process(_delta: float) -> void:
	frames += 1
	if frames > 1500:
		failures += 1
		printerr("FAIL: (v6) global timeout")
		get_tree().quit(failures)
		return
	match phase:
		0:  # walk to the holding fold
			_hold(true)
			if player.global_position.distance_to((fold0 as Node3D).global_position) < 2.5:
				_hold(false)
				_press(KEY_E)
				wait_until = frames + 12
				phase = 1
		1:
			if frames >= wait_until:
				if player.carried_fold == fold0:
					_check(true, "(v6) E picks up the generated fold")
					_hold(true)
					Input.action_press("ui_up")
					phase = 2
				else:
					failures += 1
					printerr("FAIL: (v6) E missed the generated fold")
					get_tree().quit(failures)
		2:  # carry to the pad (diagonal: pad sits south of the walk line)
			if player.global_position.distance_to((pad as Node3D).global_position) < 1.5:
				_hold(false)
				Input.action_release("ui_up")
				_press(KEY_X)
				wait_until = frames + 12
				phase = 3
		3:
			if frames >= wait_until:
				if not is_instance_valid(fold0):
					_check(true, "(v6) break over the generated pad")
					phase = 4
				else:
					failures += 1
					printerr("FAIL: (v6) X missed the generated break")
					get_tree().quit(failures)
		4:
			if pad.last_countdown != "":
				_check(true, "(v6) countdown shown while queued")
				phase = 5
			elif frames > 900:
				failures += 1
				printerr("FAIL: (v6) generated pad never queued")
				get_tree().quit(failures)
		5:
			if door.opened_distance() > 0.5:
				_check(true, "(v6) generated door opened from queued impulse")
				if failures == 0:
					print("=== VARIANT CHECK PASSED ===")
				else:
					printerr("=== VARIANT CHECK FAILED: %d ===" % failures)
				get_tree().quit(failures)
			elif frames > 1400:
				failures += 1
				printerr("FAIL: (v6) generated door never opened")
				get_tree().quit(failures)
