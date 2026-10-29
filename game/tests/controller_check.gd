# res://tests/controller_check.gd — T15 live exit test. Pad buttons drive the
# same verbs as keys (X=interact, Y=hint; B is inert); injected right-stick
# motion turns the camera. Real device absent — parsed joy events feed the
# same pipeline.
extends Node3D

var frames := 0
var failures := 0
var player = null
var yaw0 := 0.0

func _ready() -> void:
	player = $Player
	yaw0 = player.rotation.y

func _joy_button(index: int) -> void:
	var ev := InputEventJoypadButton.new()
	ev.device = 0
	ev.button_index = index
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
		var ev := InputEventJoypadMotion.new()
		ev.device = 0
		ev.axis = JOY_AXIS_RIGHT_X
		ev.axis_value = 1.0
		Input.parse_input_event(ev)
	if frames == 35:
		_check(absf(player.rotation.y - yaw0) > 0.05, "(c) right stick looks")
		_check($HUD.get_node("Objective").text != "", "(c) objective shows")
		_check($HUD.get_node("Prompt").visible, "(c) grab prompt shows near fold")
		var off := InputEventJoypadMotion.new()
		off.device = 0
		off.axis = JOY_AXIS_RIGHT_X
		off.axis_value = 0.0
		Input.parse_input_event(off)
	if frames == 40:
		_joy_button(JOY_BUTTON_X)
	if frames == 55:
		_check(player.carried_fold != null, "(c) pad X picks up")
	if frames == 60:
		_joy_button(JOY_BUTTON_X)
	if frames == 75:
		_check(player.carried_fold == null, "(c) pad X sets down")
	if frames == 78:
		_joy_button(JOY_BUTTON_B)
	if frames == 85:
		_check(player.carried_fold == null, "(c) pad B stays inert")
		_joy_button(JOY_BUTTON_Y)
	if frames == 95:
		_check($HUD.get_node("Hint").text != "", "(c) pad Y shows hint")
		if failures == 0:
			print("=== CONTROLLER CHECK PASSED ===")
		else:
			printerr("=== CONTROLLER CHECK FAILED: %d ===" % failures)
		get_tree().quit(failures)
