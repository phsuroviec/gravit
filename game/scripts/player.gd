# res://scripts/player.gd — T2: wall-walking player.
# Gravity comes ONLY from FoldScope.applied_gravity, shared with ScopeBody.
# up_direction tracks the current scope so move_and_slide() treats a fold
# wall as floor; stepping out returns up to +Y with no code change.
class_name Player
extends CharacterBody3D

const FoldScope = preload("res://scripts/fold_scope.gd")
const Sfx = preload("res://scripts/sfx.gd")

@export var walk_speed := 4.0
@export var jump_speed := 4.5
@export var mouse_sens := 0.0025
@export var pitch_limit := 1.4

var active_scopes: Array = []
var carried_fold = null
var _was_airborne := false

func _ready() -> void:
	# Rooms wire their own children in their _ready, which runs before this
	# player node even enters the tree — so the player collects its own set.
	active_scopes = get_tree().get_nodes_in_group("fold_scopes")
	($JumpPlayer as AudioStreamPlayer).stream = Sfx.jump()
	($LandPlayer as AudioStreamPlayer).stream = Sfx.land()

func scope_gravity() -> Vector3:
	return FoldScope.applied_gravity(self, Time.get_ticks_msec() * 0.001, active_scopes)

func align_to_gravity(g: Vector3) -> void:
	if not g.is_zero_approx():
		up_direction = -g.normalized()

# Yaw on the body, pitch on the camera, roll nowhere.
func apply_look(rel: Vector2) -> void:
	rotate_y(-rel.x * mouse_sens)
	var cam := $Camera3D as Camera3D
	cam.rotation.x = clampf(cam.rotation.x - rel.y * mouse_sens, -pitch_limit, pitch_limit)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		apply_look((event as InputEventMouseMotion).relative)
	elif event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_E:
				_interact()
			KEY_X:
				_break_carried()
			KEY_R:
				get_tree().reload_current_scene()
	elif event is InputEventJoypadButton and event.pressed:
		# Pad mirrors keys (both stay live: seamless handoff, no menus).
		match event.button_index:
			JOY_BUTTON_X:
				_interact()
			JOY_BUTTON_B:
				_break_carried()
			JOY_BUTTON_Y:
				_hud_action("show_next_hint")
			JOY_BUTTON_BACK:
				_airlock_action()
			JOY_BUTTON_START:
				get_tree().reload_current_scene()

func _hud_action(method: String) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method(method):
		hud.call(method)

func _airlock_action() -> void:
	for term in get_tree().get_nodes_in_group("airlocks"):
		if term.has_method("try_narrate"):
			term.call("try_narrate")

# Right stick look, deadzoned, read straight off device 0: no InputMap
# config to author, drift, or desync. Full tilt ~= mouse sweep.
func _stick_look(delta: float) -> void:
	var s := Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	if s.length() > 0.2:
		apply_look(s.normalized() * minf(s.length(), 1.0) * 220.0 * delta)

# E latches the nearest fold (deepest wins near-ties: nested inner first),
# E again sets it down, X breaks the carried one over a plate, R restarts.
func nearest_fold(max_dist := 3.5):
	var best = null
	var best_d := max_dist
	var best_depth := -1
	for f in get_tree().get_nodes_in_group("fold_boxes"):
		var node := f as Node3D
		if node == null:
			continue
		var d := global_position.distance_to(node.global_position)
		var depth := 0
		var scope = node.get_node_or_null("FoldScope")
		if scope != null and scope.has_method("get_depth"):
			depth = scope.get_depth()
		if d < best_d - 0.5 or (depth > best_depth and d <= best_d + 0.5):
			best = f
			best_d = d
			best_depth = depth
	return best

func _discard_dead_fold() -> void:
	if carried_fold != null and not is_instance_valid(carried_fold):
		carried_fold = null

func _interact() -> void:
	_discard_dead_fold()
	if carried_fold != null:
		var room := carried_fold.get_parent() as Node3D
		if room == null:
			return
		var anchor := $CarryAnchor as Node3D
		carried_fold.place(room, room.to_local(anchor.global_position))
		carried_fold = null
	else:
		var f = nearest_fold()
		if f != null:
			f.pickup($CarryAnchor)
			carried_fold = f

func _break_carried() -> void:
	_discard_dead_fold()
	if carried_fold == null:
		return
	var f = carried_fold
	carried_fold = null
	var room := f.get_parent() as Node3D
	if room == null:
		return
	# Set down first so contents teleport to the break point, then break.
	var anchor := $CarryAnchor as Node3D
	f.place(room, room.to_local(anchor.global_position))
	f.break_fold(room, active_scopes)
	f.free()

func _physics_process(delta: float) -> void:
	_discard_dead_fold()
	var g := scope_gravity()
	var cf := FoldScope.applied_clock_factor(self, active_scopes)
	align_to_gravity(g)
	# Arrows / left stick: Up is forward. WASD rides along, same vector.
	var iv := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	iv += Vector2(
		float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
		float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W)))
	if iv.length() > 1.0:
		iv = iv.normalized()
	_stick_look(delta)
	var wish := global_transform.basis * Vector3(iv.x, 0.0, iv.y)
	wish -= up_direction * wish.dot(up_direction)
	var planar := up_direction * velocity.dot(up_direction)
	if wish.length() > 0.01:
		planar += wish.normalized() * walk_speed
	velocity = planar
	if is_on_floor():
		if _was_airborne:
			_was_airborne = false
			($LandPlayer as AudioStreamPlayer).play()
		if Input.is_action_just_pressed("ui_accept"):
			velocity += up_direction * jump_speed
			($JumpPlayer as AudioStreamPlayer).play()
	else:
		_was_airborne = true
		velocity += g * delta * cf
	move_and_slide()
