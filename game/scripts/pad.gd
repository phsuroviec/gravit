# res://scripts/pad.gd — T4: wall pad that opens a door through the queue.
# Entry enqueues ONE impulse on the door with delay_base scaled by the
# authored fold's clock_factor (concept M5: deeper folds arrive later).
# The Label3D child counts down from the queue's own sim_time.
class_name Pad
extends Area3D

const FoldScope = preload("res://scripts/fold_scope.gd")
const ConsequenceQueue = preload("res://scripts/consequence_queue.gd")
const Sfx = preload("res://scripts/sfx.gd")

@export var door_path: NodePath
@export var queue_path: NodePath
@export var fold_path: NodePath
@export var impulse := Vector3(6, 0, 0)
@export var delay_base := 1.0

var active_scopes: Array = []
var pending_item = null
var last_countdown := ""
# Per-instance plate material: the armed pulse must not light every pad.
var _plate_mat: StandardMaterial3D = null
# Fold clock sampled while the fold is alive: the pad must keep working after
# its fold is picked up, carried off and broken (that is the whole game).
var last_clock := 1.0
var _last_tick_sec := -1
var _thudded := false

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	var plate := $Plate as MeshInstance3D
	_plate_mat = (plate.mesh as BoxMesh).material.duplicate() as StandardMaterial3D
	_plate_mat.emission_enabled = true
	_plate_mat.emission = Color(0.2, 0.9, 0.75)
	_plate_mat.emission_energy_multiplier = 0.15
	plate.material_override = _plate_mat
	($TickPlayer as AudioStreamPlayer).stream = Sfx.tick()
	($ThudPlayer as AudioStreamPlayer).stream = Sfx.thud()

func _on_body_entered(body: Node3D) -> void:
	# The pad answers to cargo, not to you: walking over it yourself does
	# nothing, so the puzzle can never be bypassed on foot.
	if body.is_in_group("player"):
		return
	if pending_item == null and body is PhysicsBody3D:
		trigger(body)

func trigger(_body: Node3D) -> void:
	var queue := get_node_or_null(queue_path) as ConsequenceQueue
	var door := get_node_or_null(door_path) as Node3D
	if queue == null or door == null:
		return
	pending_item = queue.enqueue(door, impulse, delay_base * last_clock)
	_last_tick_sec = -1
	_thudded = false

func _process(_delta: float) -> void:
	var label := $Countdown as Label3D
	var queue := get_node_or_null(queue_path) as ConsequenceQueue
	var fold := get_node_or_null(fold_path) as FoldScope
	if fold != null:
		last_clock = fold.clock_factor
	if pending_item != null and queue != null and not pending_item.fired:
		var remaining: float = pending_item.due_time - queue.sim_time
		last_countdown = "%.1f" % maxf(0.0, remaining)
		label.text = last_countdown
		# Armed: the plate brightens as the shove approaches, breathing gently.
		if is_instance_valid(_plate_mat):
			_plate_mat.emission_energy_multiplier = 1.0 + (1.6 - remaining) * 1.2 + sin(Time.get_ticks_msec() * 0.02) * 0.5
		var sec := int(ceil(remaining))
		if sec != _last_tick_sec and sec > 0:
			_last_tick_sec = sec
			($TickPlayer as AudioStreamPlayer).play()
	elif pending_item != null and pending_item.fired and not _thudded:
		_thudded = true
		($ThudPlayer as AudioStreamPlayer).play()
	elif label != null:
		label.text = ""
