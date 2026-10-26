# res://scripts/exit_zone.gd — T7: past the Room 3 door. Counts one completion
# per run (reloads reset the zone; the GameState autoload keeps the tally).
extends Area3D

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var hud = get_tree().get_first_node_in_group("hud")
		if hud != null and hud.has_method("show_completion"):
			hud.show_completion()
		set_deferred("monitoring", false)
