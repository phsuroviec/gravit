# res://scripts/hud.gd — T7: hints, completion, replay timer.
# [H] shows the next hint for the room the player stands in. The timer stays
# hidden until the first Room 3 completion; GameState (autoload) carries the
# unlock across [R] restarts, and each reload restarts the clock.
extends CanvasLayer

const GameText = preload("res://scripts/game_text.gd")
const Sfx = preload("res://scripts/sfx.gd")

var _hint_index := {}
var _last_room := ""
var _brief_until_ms := 0

const OBJECTIVES := {
	"room1": "Room 1: watch the fold work — then walk through its door",
	"room2": "Room 2: carry the frozen fold to the plate  [E grab · X break]",
	"room3": "Room 3: break the inner fold where the outer throws west",
	"room4": "Room 4: ride the updraft through the gate",
}

func _ready() -> void:
	GameState.run_start_ms = Time.get_ticks_msec()
	($Timer as Label).visible = GameState.completions > 0
	($Chime as AudioStreamPlayer).stream = Sfx.chime()

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
	var best := "best " + _fmt(GameState.best_ms)
	($Complete as Label).text = "COURSE COMPLETE in " + _fmt(ms) + " (" + best + ")\n" + GameText.fold_log("room3") + "\n[R] run it again"
	($Complete as Label).visible = true
	($Timer as Label).visible = true
	($Chime as AudioStreamPlayer).play()

func timer_unlocked() -> bool:
	return ($Timer as Label).visible

func _fmt(ms: int) -> String:
	var t := ms / 1000.0
	return "%02d:%04.1f" % [int(t) / 60, fmod(t, 60.0)]

func _process(_delta: float) -> void:
	if timer_unlocked():
		($Timer as Label).text = _fmt(Time.get_ticks_msec() - GameState.run_start_ms)
	_track_room()
	_prompt()

# Context verb hint: what E/X would do right now, if anything.
func _prompt() -> void:
	var label := $Prompt as Label
	var p = _player()
	if p == null or not (p as Node).has_method("nearest_fold"):
		label.visible = false
		return
	if (p as Node).get("carried_fold") != null:
		label.text = "E: set down   X: break"
		label.visible = true
	elif p.call("nearest_fold") != null:
		label.text = "E: grab fold"
		label.visible = true
	else:
		label.visible = false

# Briefing card on room entry: generated text, shown 6 s, never blocks play.
func _track_room() -> void:
	var id := current_room_id()
	if id == _last_room:
		if _brief_until_ms > 0 and Time.get_ticks_msec() > _brief_until_ms:
			($Brief as Label).visible = false
			_brief_until_ms = 0
		return
	_last_room = id
	($Brief as Label).text = GameText.briefing(id)
	($Brief as Label).visible = true
	($Objective as Label).text = str(OBJECTIVES.get(id, ""))
	_brief_until_ms = Time.get_ticks_msec() + 6000

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_H:
		show_next_hint()
