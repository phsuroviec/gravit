# res://scripts/pad.gd — T4: wall pad that opens a door through the queue.
# Entry enqueues ONE impulse on the door with delay_base scaled by the
# authored fold's clock_factor (concept M5: deeper folds arrive later).
# The Label3D child counts down from the queue's own sim_time.
class_name Pad
extends Area3D

const FoldScope = preload("res://scripts/fold_scope.gd")
const ConsequenceQueue = preload("res://scripts/consequence_queue.gd")

@export var door_path: NodePath
@export var queue_path: NodePath
@export var fold_path: NodePath
@export var impulse := Vector3(-6, 0, 0)
@export var delay_base := 1.0

var active_scopes: Array = []
var pending_item = null
var last_countdown := ""
# Fold clock sampled while the fold is alive: the pad must keep working after
# its fold is picked up, carried off and broken (that is the whole game).
var last_clock := 1.0

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if pending_item == null and body is PhysicsBody3D:
		trigger(body)

func trigger(_body: Node3D) -> void:
	var queue := get_node_or_null(queue_path) as ConsequenceQueue
	var door := get_node_or_null(door_path) as Node3D
	if queue == null or door == null:
		return
	pending_item = queue.enqueue(door, impulse, delay_base * last_clock)

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
	elif label != null:
		label.text = ""
