# res://tests/t7_check.gd — T7 live exit test, one room. HUD hints, airlock
# fallback narration, exit completion + replay-timer unlock. The AI path is
# forced local (deterministic); transport is engine-standard HTTPRequest,
# verified once by hand against the live API.
extends Node3D

var frames := 0
var failures := 0
var player = null
var hud = null
var airlock = null

func _ready() -> void:
	player = $Player
	hud = $HUD
	airlock = $Room1/Airlock

func _press(keycode: int) -> void:
	var ev := InputEventKey.new()
	ev.keycode = keycode
	ev.pressed = true
	Input.parse_input_event(ev)

func _expected_fold_log() -> String:
	var text := FileAccess.get_file_as_string("res://data/hints.json")
	var parsed: Variant = JSON.parse_string(text)
	return parsed["rooms"][0]["fold_log"]

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("PASS: ", msg)
	else:
		failures += 1
		printerr("FAIL: ", msg)

func _physics_process(_delta: float) -> void:
	frames += 1
	if frames == 5:
		_press(KEY_H)
	if frames == 10:
		_check(hud.get_node("Hint").text != "", "(t7) H shows a hint")
		player.global_position = Vector3(-15.0, 0.9, 2.5)
	if frames == 20:
		_check(airlock.screen_text() != "", "(t7) terminal shows local fold log")
		airlock.force_local = true
		_press(KEY_T)
	if frames == 30:
		_check(airlock.screen_text() == _expected_fold_log(), "(t7) offline narration falls back to local")
		player.global_position = Vector3(10.0, 7.0, 0)
	if frames == 130:
		_check(GameState.completions >= 1, "(t7) completion registers")
		_check(hud.get_node("Complete").visible, "(t7) completion shown with fold log")
		_check(_expected_fold_log() in hud.get_node("Complete").text, "(t7) completion names the stunt")
		_check(hud.timer_unlocked(), "(t7) replay timer unlocked")
		if failures == 0:
			print("=== T7 CHECK PASSED ===")
		else:
			printerr("=== T7 CHECK FAILED: %d ===" % failures)
		get_tree().quit(failures)
