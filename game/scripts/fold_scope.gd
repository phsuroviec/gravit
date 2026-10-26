# res://scripts/fold_scope.gd — T1: named gravity/time scope.
# ADR-2: a plain Node3D (placeable, inspectable); no physics of its own.
# Owns the single gravity function every body calls: applied_gravity(body, t).
class_name FoldScope
extends Node3D

const GRAV_MAG := 9.8
const WORLD_GRAVITY := Vector3(0, -GRAV_MAG, 0)

@export var gravity_dir: Vector3 = Vector3.DOWN
@export var clock_factor: float = 1.0

var parent_scope: FoldScope = null
var child_scopes: Array[FoldScope] = []
# ADR-1: bodies inside this fold as paths from this node; resolve with get_node_or_null().
var contents: Array[NodePath] = []

# ADR-3: refuse cycles and second parents — return false, warn naming both scopes,
# leave the tree untouched. Callers must check the return value.
func add_child_scope(child: FoldScope) -> bool:
	if child == self or _is_descendant_of(child):
		push_warning("FoldScope cycle refused: '%s' cannot parent '%s'" % [name, child.name])
		return false
	if child.parent_scope != null:
		push_warning("FoldScope second parent refused: '%s' already under '%s', not '%s'" % [child.name, child.parent_scope.name, name])
		return false
	child.parent_scope = self
	child_scopes.append(child)
	return true

func _is_descendant_of(ancestor: FoldScope) -> bool:
	var cursor := parent_scope
	while cursor != null:
		if cursor == ancestor:
			return true
		cursor = cursor.parent_scope
	return false

# Depth derived from the parent chain: root is 1.
func get_depth() -> int:
	var depth := 1
	var cursor := parent_scope
	var guard := 0
	while cursor != null and guard < 1024:
		depth += 1
		cursor = cursor.parent_scope
		guard += 1
	return depth

func add_body(body: Node3D) -> void:
	var path := get_path_to(body)
	if not contents.has(path):
		contents.append(path)

func remove_body(body: Node3D) -> void:
	for path in contents.duplicate():
		if get_node_or_null(path) == body:
			contents.erase(path)

func has_body(body: Node3D) -> bool:
	for path in contents:
		if get_node_or_null(path) == body:
			return true
	return false

static func deepest_scope_for_body(body: Node3D, scopes: Array) -> FoldScope:
	var best: FoldScope = null
	var best_depth := -1
	for candidate in scopes:
		var scope := candidate as FoldScope
		if scope == null or not is_instance_valid(scope):
			continue
		if scope.has_body(body):
			var depth := scope.get_depth()
			if depth > best_depth:
				best_depth = depth
				best = scope
	return best

# THE gravity function (concept M4): CharacterBody3D and RigidBody3D both call
# this. No per-body special cases; the deepest containing fold wins.
static func applied_gravity(body: Node3D, _t: float, scopes: Array, default_g: Vector3 = WORLD_GRAVITY) -> Vector3:
	var scope := deepest_scope_for_body(body, scopes)
	if scope != null:
		return scope.gravity_dir.normalized() * GRAV_MAG
	return default_g

static func applied_clock_factor(body: Node3D, scopes: Array) -> float:
	var scope := deepest_scope_for_body(body, scopes)
	return scope.clock_factor if scope != null else 1.0

# Invariant (iv): contents and child folds move to the parent scope; self leaves
# the active set. Bodies stay parented to room_root (never under a moving fold).
# Scene-tree removal of the fold node itself lands in T3 (FoldBox owns the Area3D).
func break_fold(room_root: Node3D, all_scopes: Array) -> void:
	var parent := parent_scope
	for child in child_scopes.duplicate():
		child_scopes.erase(child)
		child.parent_scope = null
		if parent != null:
			parent.add_child_scope(child)
	for path in contents.duplicate():
		contents.erase(path)
		var node := get_node_or_null(path)
		if node == null:
			continue
		if node is RigidBody3D:
			if node.get_parent() != room_root:
				node.reparent(room_root, true)
				node.reset_physics_interpolation()
			node.freeze = false
		if parent != null and node is Node3D:
			parent.add_body(node)
	all_scopes.erase(self)
	if parent != null:
		parent.child_scopes.erase(self)
	parent_scope = null
