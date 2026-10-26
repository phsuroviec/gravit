# res://scripts/door.gd — T4: impulse-opened slab door.
# Starts frozen shut. The ConsequenceQueue unfreezes it and lands the impulse;
# axis locks keep the motion a clean sideways slide. Openness is displacement
# from the shut position recorded at ready.
class_name Door
extends RigidBody3D

var closed_pos := Vector3.ZERO

func _ready() -> void:
	closed_pos = position

func opened_distance() -> float:
	return (position - closed_pos).length()
