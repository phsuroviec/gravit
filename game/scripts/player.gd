# res://scripts/player.gd — T2: wall-walking player.
# Gravity comes ONLY from FoldScope.applied_gravity, shared with ScopeBody.
# up_direction tracks the current scope so move_and_slide() treats a fold
# wall as floor; stepping out returns up to +Y with no code change.
class_name Player
extends CharacterBody3D

const FoldScope = preload("res://scripts/fold_scope.gd")

@export var walk_speed := 4.0
@export var jump_speed := 4.5
@export var mouse_sens := 0.0025
@export var pitch_limit := 1.4

var active_scopes: Array = []

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
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		apply_look((event as InputEventMouseMotion).relative)
	elif event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	var g := scope_gravity()
	var cf := FoldScope.applied_clock_factor(self, active_scopes)
	align_to_gravity(g)
	# Arrows / left stick: Up is forward.
	var iv := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var wish := global_transform.basis * Vector3(iv.x, 0.0, iv.y)
	wish -= up_direction * wish.dot(up_direction)
	var planar := up_direction * velocity.dot(up_direction)
	if wish.length() > 0.01:
		planar += wish.normalized() * walk_speed
	velocity = planar
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity += up_direction * jump_speed
	else:
		velocity += g * delta * cf
	move_and_slide()
