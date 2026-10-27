# res://scripts/door.gd — T4: impulse-opened slab door.
# Starts frozen shut. The ConsequenceQueue unfreezes it and lands the impulse;
# axis locks keep the motion a clean sideways slide. Openness is displacement
# from the shut position recorded at ready.
class_name Door
extends RigidBody3D

var closed_pos := Vector3.ZERO
var _sinking := false

func _ready() -> void:
	closed_pos = position

func opened_distance() -> float:
	return (position - closed_pos).length()

# Once knocked clear of the frame, retract through the floor so the doorway
# stays passable (a resting slab would re-block the path it just opened).
func _physics_process(_delta: float) -> void:
	if not _sinking and opened_distance() > 0.4:
		_sinking = true
		freeze = true
		collision_layer = 0
		collision_mask = 0
	if _sinking:
		position.y -= 1.5 * get_physics_process_delta_time()
		if position.y < closed_pos.y - 2.5:
			set_physics_process(false)
