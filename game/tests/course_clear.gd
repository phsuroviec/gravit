# res://tests/course_clear.gd — stunt bot. Walks the whole level with honest
# input only (no teleports after spawn): up the ramp, off the deck into the
# Sling, hold forward through the Uplift, arc onto the platform, touchdown.
# Asserts the arc peak (speed became height) and the landing box.
extends Node3D

var frames := 0
var failures := 0
var phase := 0
var peak_y := 0.0

var player = null
var hud = null

func _ready() -> void:
	player = $Course/Player
	hud = $Course/HUD

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

func _physics_process(_delta: float) -> void:
	frames += 1
	if frames > 2600:
		_die("(bot) global timeout at %s peak %.2f" % [str(player.global_position), peak_y])
		return
	var p: Vector3 = player.global_position
	if frames == 5:
		player.rotation.y = -PI / 2.0
		Input.action_press("ui_up")

	match phase:
		0:  # run east: ramp, deck, off the edge into the Sling
			if p.x > -7.0 and p.y > 2.0:
				_check(true, "(bot) entered the sling stream")
				phase = 1
			elif frames > 600:
				_die("(bot) never reached the sling, stuck at %s" % str(p))
		1:  # flight: track the arc peak, wait for touchdown
			if p.y > peak_y:
				peak_y = p.y
			if hud.get_node("Complete").visible:
				Input.action_release("ui_up")
				_check(peak_y > 4.5, "(bot) uplift traded speed for height (peak %.2f)" % peak_y)
				_check(p.x > 6.0 and p.x < 14.0, "(bot) touchdown on the platform (x %.2f)" % p.x)
				if failures == 0:
					print("=== COURSE CLEAR PASSED ===")
				else:
					printerr("=== COURSE CLEAR FAILED: %d ===" % failures)
				get_tree().quit(failures)
