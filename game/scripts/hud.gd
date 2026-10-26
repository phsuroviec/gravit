# res://scripts/hud.gd — T7: hints, completion, replay timer.
# [H] shows the next hint for the room the player stands in. The timer stays
# hidden until the first Room 3 completion; GameState (autoload) carries the
# unlock across [R] restarts, and each reload restarts the clock.
extends CanvasLayer

const GameText = preload("res://scripts/game_text.gd")

var _hint_index := {}

func _ready() -> void:
	GameState.run_start_ms = Time.get_ticks_msec()
	($Timer as Label).visible = GameState.completions > 0

func _player():
	var players := get_tree().get_nodes_in_group("player")
	return players[0] if not players.is_empty() else null

func current_room_id() -> String:
	var p = _player()
	if p == null:
		return "room1"
	var x: float = (p as Node3D).global_position.x
	if x < 6.0:
		return "room1"
	if x < 18.0:
		return "room2"
	return "room3"

func show_next_hint() -> void:
	var id := current_room_id()
	var i: int = _hint_index.get(id, 0)
	($Hint as Label).text = "[H] " + GameText.hint_text(id, i)
	_hint_index[id] = i + 1

func show_completion() -> void:
	GameState.completions += 1
	var ms := Time.get_ticks_msec() - GameState.run_start_ms
	if GameState.best_ms < 0 or ms < GameState.best_ms:
		GameState.best_ms = ms
	($Complete as Label).text = "COURSE COMPLETE in " + _fmt(ms) + "\n" + GameText.fold_log("room3")
	($Complete as Label).visible = true
	($Timer as Label).visible = true

func timer_unlocked() -> bool:
	return ($Timer as Label).visible

func _fmt(ms: int) -> String:
	var t := ms / 1000.0
	return "%02d:%04.1f" % [int(t) / 60, fmod(t, 60.0)]

func _process(_delta: float) -> void:
	if timer_unlocked():
		($Timer as Label).text = _fmt(Time.get_ticks_msec() - GameState.run_start_ms)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_H:
		show_next_hint()
