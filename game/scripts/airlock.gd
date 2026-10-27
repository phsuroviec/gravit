# res://scripts/airlock.gd — T7: fold-log terminal with one optional AI call.
# Entering shows the local fold log instantly (always works, no network).
# T narrates via muse-spark-1.3 with a 2.5 s HTTP timeout; any failure —
# timeout, offline, no key — falls back to the same local text. The key comes
# from the OS environment and is never stored in the repo or the export.
class_name AirlockTerminal
extends Area3D

const GameText = preload("res://scripts/game_text.gd")

@export var room_id := "room3"

var force_local := false
var _player_inside := false

func screen_text() -> String:
	return ($Screen as Label3D).text

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	($Screen as Label3D).text = ""

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		_show_local()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = false

func _show_local() -> void:
	($Screen as Label3D).text = GameText.fold_log(room_id)

# Pad-Back entry point: narrate only when the player is actually here.
func try_narrate() -> void:
	if _player_inside:
		narrate()

func narrate() -> void:
	var key := OS.get_environment("MODEL_API_KEY").strip_edges()
	if force_local or key == "":
		_show_local()
		return
	var prompt := "One sentence, maintenance-crew voice: narrate breaking a space-fold that drops its contents. No lore."
	var payload := {"model": "muse-spark-1.3", "messages": [{"role": "user", "content": prompt}], "max_tokens": 800}
	var headers := ["Content-Type: application/json", "Authorization: Bearer " + key]
	var http := $HTTP as HTTPRequest
	http.request_completed.connect(_on_narration_done, CONNECT_ONE_SHOT)
	if http.request("https://api.meta.ai/v1/chat/completions", headers, HTTPClient.METHOD_POST, JSON.stringify(payload)) != OK:
		_show_local()

func _on_narration_done(result: int, _code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		_show_local()
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	var text := ""
	if parsed is Dictionary:
		var choices = parsed.get("choices", [])
		if choices is Array and not choices.is_empty() and choices[0] is Dictionary:
			var msg = (choices[0] as Dictionary).get("message", {})
			if msg is Dictionary:
				text = str(msg.get("content", "")).strip_edges()
	($Screen as Label3D).text = text if text != "" else GameText.fold_log(room_id)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_T and _player_inside:
		narrate()
