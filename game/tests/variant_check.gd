# res://tests/variant_check.gd — T6 bonus exit test: the open-weight layout
# plays. Bot walks to the holding fold, carries it to the pad, sets it down;
# the crate drops onto the pad and the queued impulse opens the generated
# door. Same verbs, generated numbers.
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

var fold0_pos := Vector3.ZERO
var pad_pos := Vector3.ZERO

func _ready() -> void:
	var file := OS.get_environment("VARIANT_FILE").strip_edges()
	if file == "":
		file = "res://data/variant_open.json"
	var text := FileAccess.get_file_as_string(file)
	var parsed: Variant = JSON.parse_string(text)
	var data := parsed as Dictionary
	fold0_pos = Vector3(float(data["folds"][0]["pos"][0]), float(data["folds"][0]["pos"][1]), float(data["folds"][0]["pos"][2]))
	pad_pos = Vector3(float(data["pad"][0]), float(data["pad"][1]), float(data["pad"][2]))
	room = VariantRoom.build(parsed as Dictionary)
	room.name = "Variant"
	add_child(room)
	player = $Player
	player.active_scopes = get_tree().get_nodes_in_group("fold_scopes")
	fold0 = room.get_node("Fold0")
	door = room.get_node("Door")
	pad = room.get_node("Pad")
	var spawn: Array = (parsed as Dictionary)["player_spawn"]
	var spawn_pos: Vector3 = VariantRoom._snap("spawn", Vector3(float(spawn[0]), float(spawn[1]), float(spawn[2])), 0.9)
	player.global_position = spawn_pos

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
		Input.action_release("ui_up")
		Input.action_release("ui_down")

# Steer toward a target on the floor plane; arrival cannot be missed because
# each axis stops only inside its own deadband.
func _seek(target: Vector3, arrive: float) -> bool:
	var p: Vector3 = player.global_position
	if p.x < target.x - 0.3:
		Input.action_press("ui_right")
	else:
		Input.action_release("ui_right")
	if p.z < target.z - 0.3:
		Input.action_press("ui_down")
	elif p.z > target.z + 0.3:
		Input.action_press("ui_up")
	else:
		Input.action_release("ui_up")
		Input.action_release("ui_down")
	if p.distance_to(Vector3(target.x, p.y, target.z)) < arrive:
		_hold(false)
		return true
	return false

func _physics_process(_delta: float) -> void:
	frames += 1
	if frames > 1500:
		failures += 1
		printerr("FAIL: (v6) global timeout")
		get_tree().quit(failures)
		return
	match phase:
		0:  # walk/strafe to the holding fold
			if _seek(fold0_pos, 2.0):
				_press(KEY_E)
				wait_until = frames + 12
				phase = 1
		1:
			if frames >= wait_until:
				if player.carried_fold == fold0:
					_check(true, "(v6) E picks up the generated fold")
					phase = 2
				else:
					failures += 1
					printerr("FAIL: (v6) E missed the generated fold")
					get_tree().quit(failures)
		2:  # carry to the pad
			if _seek(pad_pos, 1.2):
				_press(KEY_E)
				wait_until = frames + 12
				phase = 3
		3:
			if frames >= wait_until:
				if player.carried_fold == null:
					_check(true, "(v6) set down over the generated pad")
					phase = 4
				else:
					failures += 1
					printerr("FAIL: (v6) E did not set the fold down")
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
