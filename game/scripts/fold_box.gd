# res://scripts/fold_box.gd — T3: carried fold shell (Area3D) + bookkeeping scope.
# ADR-2: the Area3D does detection and display only; gravity/time bookkeeping
# lives in the child FoldScope. Engine gravity override stays disabled —
# all fall comes from FoldScope.applied_gravity.
# Nothing physics-related ever reparents: bodies stay under the room root and
# the shell follows its carry anchor by position (no overlap-state churn).
# Pickup freezes bodies in place; place teleports them by the fold delta.
class_name FoldBox
extends Area3D

const FoldScope = preload("res://scripts/fold_scope.gd")

# Room-local offsets of contained bodies from the fold origin, taken at pickup.
var carry_offsets: Dictionary = {}
var carry_anchor: Node3D = null

func get_scope() -> FoldScope:
	return $FoldScope as FoldScope

func is_carried() -> bool:
	return carry_anchor != null and is_instance_valid(carry_anchor)

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	if is_carried():
		global_position = carry_anchor.global_position

func _on_body_entered(body: Node3D) -> void:
	if is_carried():
		return
	if body is PhysicsBody3D:
		get_scope().add_body(body)

func _on_body_exited(body: Node3D) -> void:
	if is_carried():
		return
	if body is PhysicsBody3D:
		get_scope().remove_body(body)

# Latch to the carrier. Bodies freeze where they are (room space).
func pickup(anchor: Node3D) -> void:
	var scope := get_scope()
	carry_offsets.clear()
	for path in scope.contents:
		var node := scope.get_node_or_null(path)
		if node is Node3D:
			carry_offsets[path] = (node as Node3D).position - position
		if node is RigidBody3D:
			(node as RigidBody3D).freeze = true
	carry_anchor = anchor

# Set the shell down: bodies teleport by the fold delta, then unfreeze.
# All positions are room-local — valid because bodies and a placed fold are
# always siblings under room_root (the T3 invariant).
func place(room_root: Node3D, target: Vector3) -> void:
	carry_anchor = null
	if get_parent() != room_root:
		reparent(room_root, false)
	position = target
	var scope := get_scope()
	for path in scope.contents.duplicate():
		var node := scope.get_node_or_null(path)
		if node == null:
			carry_offsets.erase(path)
			continue
		if node is Node3D:
			var offset: Vector3 = carry_offsets.get(path, Vector3.ZERO)
			(node as Node3D).position = target + offset
		if node is RigidBody3D:
			(node as RigidBody3D).freeze = false
			if (node as RigidBody3D).is_inside_tree():
				(node as RigidBody3D).reset_physics_interpolation()
	if is_inside_tree():
		reset_physics_interpolation()

# Break: contents and child scopes return to the parent scope (invariant iv),
# then the shell detaches. The caller frees the shell afterwards — an object
# cannot free itself from inside its own method. Call outside physics callbacks.
func break_fold(room_root: Node3D, all_scopes: Array) -> void:
	carry_anchor = null
	get_scope().break_fold(room_root, all_scopes)
	var parent := get_parent()
	if parent != null:
		parent.remove_child(self)
