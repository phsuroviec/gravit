# res://tests/check_data.gd — T6: proves generated JSON loads in-engine.
# Run: godot --headless --path game -s res://tests/check_data.gd
extends SceneTree

func _init() -> void:
	var failures := 0
	for path in ["res://data/hints.json"]:
		if not FileAccess.file_exists(path):
			printerr("FAIL: missing ", path)
			failures += 1
			continue
		var text := FileAccess.get_file_as_string(path)
		var parsed: Variant = JSON.parse_string(text)
		if parsed == null:
			printerr("FAIL: unparsable ", path)
			failures += 1
		elif not (parsed is Dictionary and parsed.has("rooms") and parsed["rooms"] is Array):
			printerr("FAIL: bad shape ", path)
			failures += 1
		else:
			print("PASS: loads ", path, " (", parsed["rooms"].size(), " rooms)")
	for extra in DirAccess.get_files_at("res://data"):
		if (extra.begins_with("variant_") or extra == "room_variant_baseten.json") and extra.ends_with(".json"):
			var text := FileAccess.get_file_as_string("res://data/" + extra)
			if JSON.parse_string(text) == null:
				printerr("FAIL: unparsable res://data/", extra)
				failures += 1
			else:
				print("PASS: loads res://data/", extra)
	if failures == 0:
		print("=== DATA CHECK PASSED ===")
		quit(0)
	else:
		printerr("=== DATA CHECK FAILED: %d ===" % failures)
		quit(1)
