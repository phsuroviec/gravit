# res://scripts/consequence_queue.gd — T1: delayed impulses (concept M5).
# ADR-4: a queued target that is gone at fire time is dropped + counted in
# `dropped`. Never thrown: breaking a fold while consequences are queued is normal.
class_name ConsequenceQueue
extends Node3D

class QueuedConsequence extends RefCounted:
	var id: int
	var body_path: NodePath
	var impulse: Vector3
	var due_time: float
	var fired: bool = false

var sim_time: float = 0.0
var dropped: int = 0
var _next_id: int = 1
var _queue: Array[QueuedConsequence] = []

func enqueue(body: Node3D, impulse: Vector3, delay_sec: float) -> QueuedConsequence:
	var item := QueuedConsequence.new()
	item.id = _next_id
	_next_id += 1
	item.body_path = get_path_to(body)
	item.impulse = impulse
	item.due_time = sim_time + maxf(0.0, delay_sec)
	_queue.append(item)
	return item

func pending() -> int:
	return _queue.size()

func step_clock(delta: float) -> void:
	sim_time += delta
	# Backwards so removal never skips an index or double-applies.
	for i in range(_queue.size() - 1, -1, -1):
		var item := _queue[i]
		if item.fired:
			_queue.remove_at(i)
			continue
		var target := get_node_or_null(item.body_path)
		if target == null or (target as Node).is_queued_for_deletion():
			dropped += 1
			_queue.remove_at(i)
			continue
		if sim_time + 1e-5 >= item.due_time:
			item.fired = true
			_queue.remove_at(i)
			if target is RigidBody3D:
				target.freeze = false
				target.apply_central_impulse(item.impulse)

func _physics_process(delta: float) -> void:
	step_clock(delta)
