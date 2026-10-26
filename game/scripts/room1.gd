# res://scripts/room1.gd — composition root: hands every scope-aware body the
# active fold set. Scopes join group "fold_scopes" in the scene; any node with
# an active_scopes property (player, cubes, pads) gets the same array, so all
# of them read the one FoldScope.applied_gravity.
extends Node3D

func _ready() -> void:
	var scopes: Array = get_tree().get_nodes_in_group("fold_scopes")
	_assign_scopes(self, scopes)

func _assign_scopes(node: Node, scopes: Array) -> void:
	if "active_scopes" in node:
		node.set("active_scopes", scopes)
	for child in node.get_children():
		_assign_scopes(child, scopes)
