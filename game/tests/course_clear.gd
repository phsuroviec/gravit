# res://tests/course_clear.gd — placement-chain bot for the stepped room.
# Teleports position for placement (not the skill under test); every entry,
# flight, rise and landing runs on honest input: grab east fold, carry it up
# the ramp, place at the ledge edge, grab up fold, ride east carrying it
# across the void, place it, stutter in slow, moonshot, steer, touch the
# skyblock underside. Stuck phases fail loud.
extends Node3D

var frames := 0
var failures := 0
var phase := 0
var wait_until := 0
var peak_y := 0.0
var peak_pos := Vector3.ZERO
var brake := 0

var player = null
var sling = null
var uplift = null
var hud = null

func _ready() -> void:
	player = $Course/Player
	sling = $Course/Room1/Sling
	uplift = $Course/Room1/Uplift
	hud = $Course/HUD

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
	Input.action_release("ui_up")
	get_tree().quit(failures)

func _face_east() -> void:
	player.rotation.y = -PI / 2.0

func _physics_process(_delta: float) -> void:
	frames += 1
	if frames > 2600:
		_die("(bot) global timeout at %s peak %.2f" % [str(player.global_position), peak_y])
		return
	var p: Vector3 = player.global_position
	match phase:
		0:  # grab the east fold where it spawns
			player.global_position = Vector3(-12.0, 0.9, -2.0)
			_press(KEY_E)
			wait_until = frames + 12
			phase = 1
		1:
			if frames >= wait_until:
				if player.carried_fold == sling:
					_check(true, "(bot) east fold picked up")
					player.global_position = Vector3(-12.8, 1.0, 0.0)
					_face_east()
					Input.action_press("ui_up")
					phase = 2
				else:
					_die("(bot) E missed the east fold")
		2:  # carry up the ramp, walk the ledge, place at its edge
			if p.x > -4.6:
				Input.action_release("ui_up")
				_press(KEY_E)
				wait_until = frames + 12
				phase = 3
			elif frames > 700:
				_die("(bot) ramp climb failed at %s" % str(p))
		3:
			if frames >= wait_until:
				if player.carried_fold == null:
					_check(true, "(bot) east fold placed at the void edge")
					player.global_position = Vector3(-12.0, 0.9, 1.5)
					player.rotation.y = 0.0
					wait_until = frames + 12
					phase = 4
				else:
					_die("(bot) E did not set the east fold down")
		4:  # grab the up fold
			if frames >= wait_until:
				_press(KEY_E)
				wait_until = frames + 12
				phase = 5
		5:
			if frames >= wait_until:
				if player.carried_fold == uplift:
					_check(true, "(bot) up fold picked up")
					player.global_position = Vector3(-5.5, 3.9, 0.4)
					_face_east()
					Input.action_press("ui_up")
					phase = 6
				else:
					_die("(bot) E missed the up fold")
		6:  # off the ledge into the placed fold, ride east carrying cargo
			if p.x > 5.0 and p.y < 2.5:
				Input.action_release("ui_up")
				_press(KEY_E)
				wait_until = frames + 12
				phase = 7
			elif frames > 1200:
				_die("(bot) east flight never landed (at %s)" % str(p))
		7:  # place the up fold where it floats
			if frames >= wait_until:
				if player.carried_fold == null:
					_check(true, "(bot) up fold placed on the far side")
					brake = 0
					phase = 8
				else:
					_die("(bot) E did not set the up fold down")
		8:  # walk in steady to penetrate deep, brake once inside (kill the
			# east drift), release: near-vertical rise out the tall top.
			# Grazing the face flickers; committing deep is stable.
			var face_w: float = (uplift as Node3D).global_position.x - 1.0
			if uplift.get_scope().has_body(player) and p.x > face_w + 0.8:
				brake += 1
				if brake < 2:
					Input.action_press("ui_up")
				else:
					Input.action_release("ui_up")
					Input.action_press("ui_down")
			else:
				Input.action_press("ui_up")
			if brake >= 4:
				Input.action_release("ui_down")
				Input.action_release("ui_up")
				phase = 9
			elif frames > 2000:
				_die("(bot) moonshot never rose (at %s peak %.2f)" % [str(p), peak_y])
		9:  # rising ballistic: drift east into the touch layer, then wait
			if p.y > 3.2:
				Input.action_press("ui_up")
			if p.y > peak_y:
				peak_y = p.y
				peak_pos = p
			if hud.get_node("Complete").visible:
				Input.action_release("ui_up")
				_check(peak_y > 2.9, "(bot) moonshot peak %.2f at %s (jump tops out at 2.67)" % [peak_y, str(peak_pos)])
				if failures == 0:
					print("=== COURSE CLEAR PASSED ===")
				else:
					printerr("=== COURSE CLEAR FAILED: %d ===" % failures)
				get_tree().quit(failures)
