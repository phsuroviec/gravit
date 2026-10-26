# res://scripts/room.gd — composition root per room: hands every scope-aware
# body the active fold set, and links structurally nested folds (a FoldBox
# instanced under another FoldBox) into the scope tree. Idempotent across
# rooms: every room derives the same global set, each links only its own.
extends Node3D

func _ready() -> void:
	var scopes: Array = get_tree().get_nodes_in_group("fold_scopes")
	_assign_scopes(self, scopes)
	_link_nested(scopes)

func _assign_scopes(node: Node, scopes: Array) -> void:
	if "active_scopes" in node:
		node.set("active_scopes", scopes)
	for child in node.get_children():
		_assign_scopes(child, scopes)

func _link_nested(scopes: Array) -> void:
	for scope in scopes:
		if not is_ancestor_of(scope):
			continue
		var outer_box = _ancestor_foldbox(scope.get_parent().get_parent())
		if outer_box == null:
			continue
		var outer_scope = outer_box.get_node_or_null("FoldScope")
		if outer_scope != null:
			outer_scope.add_child_scope(scope)

func _ancestor_foldbox(node: Node):
	while node != null:
		if node.is_in_group("fold_boxes"):
			return node
		node = node.get_parent()
	return null
