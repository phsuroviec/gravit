# res://scripts/player.gd — T2: wall-walking player.
# Gravity comes ONLY from FoldScope.applied_gravity, shared with ScopeBody.
# up_direction tracks the current scope so move_and_slide() treats a fold
# wall as floor; stepping out returns up to +Y with no code change.
class_name Player
extends CharacterBody3D

const FoldScope = preload("res://scripts/fold_scope.gd")
const Sfx = preload("res://scripts/sfx.gd")

@export var walk_speed := 4.0
@export var jump_speed := 4.0
@export var mouse_sens := 0.0025
@export var pitch_limit := 1.4
# Held fold geometry: shell half-extent 1 m, so the float point needs clearance
# or the box swallows the camera.
@export var hold_distance := 2.0
@export var hold_min := 1.5
# Air inertia (ADR-5): flight keeps its velocity. Ground still snaps.
const AIR_ACCEL := 30.0
const AIR_DRAG := 0.15
const CAM_FOV := 75.0
const PUNCH_FOV := 12.0
# Carried off to the right and below the eyeline: the held shell must not sit
# exactly where you are looking.
const HOLD_RIGHT := 0.4
const HOLD_DOWN := 0.6
const HOLD_MARGIN := 1.05

var active_scopes: Array = []
var carried_fold = null
# The fold E would take right now; the ring marker and the HUD read this one.
var target_fold = null
var _was_airborne := false
const KILL_Y := -12.0
var last_safe_pos := Vector3(-4, 1, 0)
var _safe_cool := 0
# Orientation hysteresis (ADR-11): one eased state drives camera roll and body
# alignment together. Eases toward a fold's down on ENTRY, holds through
# airborne exits (no strobing), eases back upright only on grounded touchdown.
var _up_vec := Vector3.UP
var _target_up := Vector3.UP
var _last_scope = null
var _up_speed := 0.0
var _up_accel := 14.0
var _punch := 0.0
var _manne_fwd := Vector3(0, 0, 1)
var _pitch := 0.0

func _ready() -> void:
	# Rooms wire their own children in their _ready, which runs before this
	# player node even enters the tree — so the player collects its own set.
	active_scopes = get_tree().get_nodes_in_group("fold_scopes")
	($JumpPlayer as AudioStreamPlayer).stream = Sfx.jump()
	($LandPlayer as AudioStreamPlayer).stream = Sfx.land()
	($GrabPlayer as AudioStreamPlayer).stream = Sfx.grab()
	($WhooshPlayer as AudioStreamPlayer).stream = Sfx.whoosh()

# Eye-level point ahead of the player where a carried fold floats, pulled in by
# a ray so a fold held near a wall stops at the wall instead of sinking into it.
func hand_point() -> Vector3:
	var basis := global_transform.basis
	var origin := global_position + Vector3.UP * 0.55 + basis.x * HOLD_RIGHT - basis.y * HOLD_DOWN
	var fwd := -basis.z
	var reach := hold_distance
	var q := PhysicsRayQueryParameters3D.create(origin, origin + fwd * (hold_distance + HOLD_MARGIN))
	q.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if not hit.is_empty():
		reach = maxf(hold_min, origin.distance_to(hit.position as Vector3) - HOLD_MARGIN)
	return origin + fwd * reach

func scope_gravity() -> Vector3:
	return FoldScope.applied_gravity(self, Time.get_ticks_msec() * 0.001, active_scopes)

func align_to_gravity(g: Vector3) -> void:
	if not g.is_zero_approx():
		up_direction = -g.normalized()

# Yaw on the body, pitch as a stored float (never incrementally edited — a
# rolled basis would corrupt euler reads and the view would drift mid-flip).
func apply_look(rel: Vector2) -> void:
	rotate_y(-rel.x * mouse_sens)
	_pitch = clampf(_pitch - rel.y * mouse_sens, -pitch_limit, pitch_limit)

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
			KEY_R:
				get_tree().reload_current_scene()
	elif event is InputEventJoypadButton and event.pressed:
		# Pad mirrors keys (both stay live: seamless handoff, no menus).
		match event.button_index:
			JOY_BUTTON_X:
				_interact()
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

# E latches the nearest non-fixed fold, E again sets it down. Reach is
# measured to the shell's surface (a fold is 2 m wide).
func nearest_fold(reach := 3.0):
	var best = null
	var best_score := INF
	for f in get_tree().get_nodes_in_group("fold_boxes"):
		if not is_instance_valid(f) or (f as FoldBox).is_carried():
			continue
		if (f as FoldBox).fixed:
			continue
		var d: float = global_position.distance_to((f as Node3D).global_position) - FoldBox.SHELL_HALF
		if d > reach:
			continue
		var depth := 0
		var scope = f.get_node_or_null("FoldScope")
		if scope != null and scope.has_method("get_depth"):
			depth = scope.get_depth()
		var score := d - depth * 0.6
		if score < best_score:
			best_score = score
			best = f
	return best

func _discard_dead_fold() -> void:
	if carried_fold != null and not is_instance_valid(carried_fold):
		carried_fold = null
	if target_fold != null and not is_instance_valid(target_fold):
		target_fold = null

func _update_target() -> void:
	var t = null if carried_fold != null else nearest_fold()
	if t == target_fold:
		return
	if is_instance_valid(target_fold):
		target_fold.set_targeted(false)
	if t != null:
		t.set_targeted(true)
	target_fold = t

# Viewmodel hands: the one cue that says "you are carrying something" even when
# the dimmed shell is between you and the far wall.
func _set_hands(on: bool) -> void:
	var hands := get_node_or_null("Camera3D/CarryHands") as Node3D
	if hands != null:
		hands.visible = on

func _interact() -> void:
	_discard_dead_fold()
	if carried_fold != null:
		var room := carried_fold.get_parent() as Node3D
		if room == null:
			return
		carried_fold.drop(room)
		carried_fold = null
		_set_hands(false)
	else:
		var f = nearest_fold()
		if f != null:
			f.pickup($CarryAnchor)
			carried_fold = f
			target_fold = null
			_set_hands(true)
			($GrabPlayer as AudioStreamPlayer).play()
			if Input.get_connected_joypads().size() > 0:
				Input.start_joy_vibration(0, 0.45, 0.65, 0.12)

# Fall recovery: last stable ground wins, whole-run restart not required.
func _track_ground() -> void:
	if is_on_floor():
		_safe_cool += 1
		if _safe_cool >= 60:
			_safe_cool = 0
			last_safe_pos = position
	else:
		_safe_cool = 0

func needs_respawn() -> bool:
	return position.y < KILL_Y

func respawn() -> void:
	position = last_safe_pos
	velocity = Vector3.ZERO
	_was_airborne = false

func _physics_process(delta: float) -> void:
	_discard_dead_fold()
	_update_target()
	_track_ground()
	if needs_respawn():
		respawn()
		return
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
	# Camera-relative: looking steers, and once up flips the same code walks
	# you along the wall face — look up the wall and press forward.
	var cam_basis := ($Camera3D as Camera3D).global_transform.basis
	var wish := cam_basis * Vector3(iv.x, 0.0, iv.y)
	wish -= up_direction * wish.dot(up_direction)
	var planar := up_direction * velocity.dot(up_direction)
	var lateral := velocity - planar
	if is_on_floor():
		# Grounded: snap to wish, exactly like before (bots depend on it).
		lateral = Vector3.ZERO
		if wish.length() > 0.01:
			planar += wish.normalized() * walk_speed
	else:
		# Airborne: keep inertia. Steering accelerates toward wish speed but
		# never bleeds existing motion — Quake-style, momentum survives.
		if wish.length() > 0.01:
			var wdir := wish.normalized()
			var add := minf(AIR_ACCEL * delta * walk_speed, maxf(0.0, walk_speed - lateral.dot(wdir)))
			lateral += wdir * add
		lateral = lateral.move_toward(Vector3.ZERO, AIR_DRAG * delta)
	velocity = planar + lateral
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
	_update_orientation(delta)
	move_and_slide()

# Orientation state machine. Entry into a fold eases camera+body toward its
# down; leaving to open air holds (the moonshot stays inverted); touching
# world-down ground eases back upright. FOV punch + whoosh fire on entry.
func _update_orientation(delta: float) -> void:
	var deep = FoldScope.deepest_scope_for_body(self, active_scopes)
	if deep != _last_scope:
		if deep != null:
			# Fold ENTRY: ease toward its down. Slow start, fast finish, like
			# gravity itself (ADR-11).
			_target_up = -(deep.gravity_dir.normalized())
			_up_speed = 0.0
			_up_accel = 14.0
			_punch = 1.0
			($WhooshPlayer as AudioStreamPlayer).play()
		_last_scope = deep
	elif deep == null:
		if is_on_floor():
			# Touchdown in world gravity: ease back upright, quicker.
			_target_up = Vector3.UP
			_up_accel = 28.0
		else:
			# Airborne exit: hold. No strobing, the moonshot stays inverted.
			_target_up = _up_vec
	_ease_up_toward_target(delta)
	_orient_camera()
	_align_mannequin()

# Gravity-like ease: accelerating angular step, antipodal-safe (a raw lerp
# normalize would explode passing through zero on a 180-degree flip).
func _ease_up_toward_target(delta: float) -> void:
	var angle := _up_vec.angle_to(_target_up)
	if angle < 0.005:
		_up_vec = _target_up
		return
	_up_speed = minf(_up_speed + _up_accel * delta, 7.0)
	var axis := _up_vec.cross(_target_up)
	if axis.length() < 0.001:
		axis = _up_vec.cross(Vector3.RIGHT)
		if axis.length() < 0.001:
			axis = _up_vec.cross(Vector3.FORWARD)
	_up_vec = _up_vec.rotated(axis.normalized(), minf(angle, _up_speed * delta)).normalized()

# Deterministic facing every frame: yaw (body) + pitch (stored float), rolled
# onto the eased up. Nothing incremental, so nothing drifts mid-flip.
func _orient_camera() -> void:
	var cam := $Camera3D as Camera3D
	var fwd := (-global_transform.basis.z).rotated((global_transform.basis as Basis).x.normalized(), _pitch)
	var right := fwd.cross(_up_vec)
	if right.length() < 0.05:
		return
	right = right.normalized()
	var up2 := right.cross(fwd).normalized()
	cam.global_transform.basis = Basis(right, up2, -fwd)

# Body matches the camera's world: same eased up, body yaw for facing.
func _align_mannequin() -> void:
	var manne := get_node_or_null("Mannequin") as Node3D
	if manne == null:
		return
	var cam_up := (($Camera3D as Camera3D).global_transform.basis as Basis).y.normalized()
	var fwd := -global_transform.basis.z
	fwd -= cam_up * fwd.dot(cam_up)
	if fwd.length() > 0.15:
		_manne_fwd = fwd.normalized()
	manne.global_transform.basis = Basis.looking_at(_manne_fwd, cam_up)
