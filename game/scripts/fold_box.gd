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
# The carried shell glides to the hold point instead of teleporting: an instant
# 2 m jump through the camera is what made pickup disorienting.
const FOLLOW_RATE := 12.0
const CARRIED_ALPHA := 0.10
# Shell half-extent: grab reach and the hold clamp both measure off the surface.
const SHELL_HALF := 1.0
# Fixed folds are architecture, not objects (ADR-6): never targeted, never
# grabbed. The stunt level bolts everything down.
# One colour per gravity direction: two folds can sit side by side, and without
# a tint their shells read as one object.
const TINT_RIGHT := Color(0.35, 0.9, 1.0)
const TINT_LEFT := Color(1.0, 0.55, 0.9)
const TINT_UP := Color(0.55, 1.0, 0.62)
const TINT_DOWN := Color(0.55, 0.68, 1.0)
const TINT_PLAIN := Color(0.7, 0.95, 1.0)

# Room-local offsets of contained bodies from the fold origin, taken at pickup.
var carry_offsets: Dictionary = {}
var carry_anchor: Node3D = null
# The body carrying this fold (arm's length = outside it): never a member.
var carrier: Node3D = null
@export var fixed := false
var _shell_mat: StandardMaterial3D = null

func get_scope() -> FoldScope:
	return $FoldScope as FoldScope

# Pure: which way a fold falls decides its colour, so the shell alone tells you
# two neighbouring folds are not the same fold.
static func tint_for(dir: Vector3) -> Color:
	var d := dir.normalized()
	if absf(d.x) > 0.9:
		return TINT_RIGHT if d.x > 0.0 else TINT_LEFT
	if absf(d.y) > 0.9:
		return TINT_UP if d.y > 0.0 else TINT_DOWN
	return TINT_PLAIN

func is_carried() -> bool:
	return carry_anchor != null and is_instance_valid(carry_anchor)

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_ensure_shell_mat()
	_align_stream()

# Per-instance material: dimming a carried shell must not dim every fold.
# Lazy so the look can be set before the fold enters the tree.
func _ensure_shell_mat() -> StandardMaterial3D:
	if is_instance_valid(_shell_mat):
		return _shell_mat
	var shell := $Shell as MeshInstance3D
	_shell_mat = shell.material_override as StandardMaterial3D
	if _shell_mat == null:
		_shell_mat = (shell.mesh as BoxMesh).material.duplicate() as StandardMaterial3D
		shell.material_override = _shell_mat
	var tint := tint_for(get_scope().gravity_dir)
	_shell_mat.albedo_color = Color(tint.r, tint.g, tint.b, 0.22)
	_shell_mat.emission = tint
	var drop := (($Stream as GPUParticles3D).draw_pass_1 as SphereMesh).material.duplicate() as StandardMaterial3D
	drop.albedo_color = tint
	drop.emission = tint
	($Stream as GPUParticles3D).material_override = drop
	return _shell_mat

func _physics_process(delta: float) -> void:
	if is_carried():
		global_position = global_position.lerp(hold_target(), minf(1.0, FOLLOW_RATE * delta))
		$Ring.visible = false

# Where the shell should float while carried: the carrier decides (the player
# hands back an eye-level point clamped by walls), a plain anchor just holds it.
func hold_target() -> Vector3:
	if is_instance_valid(carrier) and carrier.has_method("hand_point"):
		return carrier.call("hand_point") as Vector3
	if is_instance_valid(carry_anchor):
		return carry_anchor.global_position
	return global_position

# One fold at a time reads as "this is the one E takes": a ground ring plus a
# brighter membrane, cleared the moment the target changes.
func set_targeted(on: bool) -> void:
	$Ring.visible = on and not is_carried()
	_ensure_shell_mat().emission_energy_multiplier = 2.0 if on else 1.0

func _set_carried_look(on: bool) -> void:
	$Ring.visible = false
	var mat := _ensure_shell_mat()
	mat.albedo_color.a = CARRIED_ALPHA if on else 0.22
	# The hex membrane is an emission texture: killing emission is what stops a
	# carried shell from washing out the whole view.
	mat.emission_energy_multiplier = 0.3 if on else 1.0

# Particle stream falls the fold's way. The process material is duplicated
# per fold: instances share the scene's sub-resource, and scopes differ.
func _align_stream() -> void:
	var down := get_scope().gravity_dir.normalized()
	var pm := ($Stream.process_material as ParticleProcessMaterial).duplicate() as ParticleProcessMaterial
	pm.direction = down
	pm.gravity = down * 3.0
	($Stream as GPUParticles3D).process_material = pm

func _on_body_entered(body: Node3D) -> void:
	if is_carried():
		return
	if body is PhysicsBody3D and body != carrier:
		get_scope().add_body(body)

func _on_body_exited(body: Node3D) -> void:
	if is_carried():
		return
	if body is PhysicsBody3D and body != carrier:
		get_scope().remove_body(body)

# Latch to the carrier. The fold goes inert (you cannot be inside the gravity
# you are holding) and bodies inside freeze where they are, in room space.
func pickup(anchor: Node3D) -> void:
	carrier = anchor.get_parent() as Node3D
	var scope := get_scope()
	scope.enabled = false
	if carrier != null:
		scope.remove_body(carrier)
	carry_offsets.clear()
	for path in scope.contents:
		var node := scope.get_node_or_null(path)
		if node is Node3D:
			carry_offsets[path] = (node as Node3D).position - position
		if node is RigidBody3D:
			(node as RigidBody3D).freeze = true
	carry_anchor = anchor
	_set_carried_look(true)

# Set the shell down: bodies teleport by the fold delta, then unfreeze.
# All positions are room-local — valid because bodies and a placed fold are
# always siblings under room_root (the T3 invariant).
# Set down where the shell currently floats: respects the hold point and the
# wall clamp, so the drop lands in front of you, never inside you.
func drop(room_root: Node3D) -> void:
	if is_inside_tree():
		place(room_root, room_root.to_local(global_position))
	else:
		place(room_root, position)

func place(room_root: Node3D, target: Vector3) -> void:
	carry_anchor = null
	carrier = null
	_set_carried_look(false)
	if get_parent() != room_root:
		reparent(room_root, false)
	position = target
	var scope := get_scope()
	scope.enabled = true
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
	_resync_membership()

# Membership truth comes from the physics server, not the signal history:
# while the fold glides (carried), entered/exited events are suppressed, so
# the one event for a body it settles onto would otherwise be eaten. The
# placed position is already physics-simulated (the glide), so the overlap
# set is current the moment we land. Add-only: real exits still arrive via
# body_exited, and cargo teleports with the fold by construction.
func _resync_membership() -> void:
	var scope := get_scope()
	for body in get_overlapping_bodies():
		if body is PhysicsBody3D and body != carrier:
			scope.add_body(body)

# Break: contents and child scopes return to the parent scope (invariant iv),
# then the shell detaches. The caller frees the shell afterwards — an object
# cannot free itself from inside its own method. Call outside physics callbacks.
func break_fold(room_root: Node3D, all_scopes: Array) -> void:
	carry_anchor = null
	carrier = null
	_set_carried_look(false)
	get_scope().break_fold(room_root, all_scopes)
	var parent := get_parent()
	if parent != null:
		parent.remove_child(self)
