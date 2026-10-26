# res://scripts/game_text.gd — T7: generated flavour text, loaded once.
# Source is game/data/hints.json (Meta-generated, schema-checked in T6).
# Missing file or bad shape yields empty strings, never errors: offline-safe.
class_name GameText
extends RefCounted

static var _cache: Variant = null

static func data() -> Dictionary:
	if _cache == null:
		if FileAccess.file_exists("res://data/hints.json"):
			var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/hints.json"))
			_cache = parsed if parsed is Dictionary else {}
		else:
			_cache = {}
	return _cache as Dictionary

static func room_text(room_id: String) -> Dictionary:
	for r in data().get("rooms", []):
		if r is Dictionary and r.get("id") == room_id:
			return r
	return {}

static func briefing(room_id: String) -> String:
	return str(room_text(room_id).get("briefing", ""))

static func hint_text(room_id: String, index: int) -> String:
	var hints = room_text(room_id).get("hints", [])
	if hints is Array and not hints.is_empty():
		return str(hints[index % hints.size()])
	return ""

static func fold_log(room_id: String) -> String:
	return str(room_text(room_id).get("fold_log", ""))
