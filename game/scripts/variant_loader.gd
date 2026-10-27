# res://scripts/variant_loader.gd — T6 bonus: builds a playable greybox room
# from an open-weight layout JSON (game/data/variant_*.json). Same node set
# as the authored rooms (FoldBox scope props, frozen cube, wired pad, freed
# door, queue) so the identical verbs and checks apply unchanged.
class_name VariantRoom
extends RefCounted

const FoldBox = preload("res://fold_box.tscn")
const Pad = preload("res://pad.tscn")
const Door = preload("res://door.tscn")
const ScopeBody = preload("res://scripts/scope_body.gd")
const ConsequenceQueue = preload("res://scripts/consequence_queue.gd")
const RoomScript = preload("res://scripts/room.gd")

static func _v3(a: Array) -> Vector3:
	return Vector3(float(a[0]), float(a[1]), float(a[2]))

# Construction preconditions, applied loudly: generated numbers sometimes
# intersect the floor (a spawn inside it wedges the capsule). Files stay
# pristine (receipt hashes intact); the loader snaps to the grid instead.
static func _snap(label: String, p: Vector3, min_y: float) -> Vector3:
	if p.y < min_y - 0.001:
		print("VariantRoom: clamped ", label, " y ", p.y, " -> ", min_y)
		p.y = min_y
	return p

static func build(data: Dictionary) -> Node3D:
	var room := Node3D.new()
	room.name = "Variant"
	room.set_script(RoomScript)
	var floor := CSGBox3D.new()
	floor.size = Vector3(14, 0.5, 10)
	floor.position = Vector3(0, -0.25, 0)
	floor.use_collision = true
	room.add_child(floor)
	for i in (data.get("folds", []) as Array).size():
		var f: Dictionary = (data["folds"] as Array)[i]
		var fold = FoldBox.instantiate()
		fold.name = "Fold%d" % i
		fold.position = _v3(f["pos"] as Array)
		var scope = fold.get_node("FoldScope")
		scope.gravity_dir = _v3(f["gravity_dir"] as Array)
		scope.clock_factor = float(f["clock_factor"])
		scope.add_to_group("fold_scopes")
		fold.add_to_group("fold_boxes")
		room.add_child(fold)
	var cube = ScopeBody.new()
	cube.name = "Cube"
	cube.position = _snap("cube", _v3(data["cube"] as Array), 0.5)
	cube.freeze = true
	cube.can_sleep = false
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.3
	shape.shape = sphere
	cube.add_child(shape)
	var mesh := MeshInstance3D.new()
	var ball := SphereMesh.new()
	ball.radius = 0.3
	ball.height = 0.6
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.85, 0.9)
	ball.material = mat
	mesh.mesh = ball
	cube.add_child(mesh)
	room.add_child(cube)
	var pad = Pad.instantiate()
	pad.name = "Pad"
	pad.position = _snap("pad", _v3(data["pad"] as Array), 0.3)
	pad.door_path = NodePath("../Door")
	pad.queue_path = NodePath("../Queue")
	pad.fold_path = NodePath("../Fold0/FoldScope")
	room.add_child(pad)
	var door = Door.instantiate()
	door.name = "Door"
	door.position = _snap("door", _v3(data["door"] as Array), 1.05)
	room.add_child(door)
	var queue := Node3D.new()
	queue.name = "Queue"
	queue.set_script(ConsequenceQueue)
	room.add_child(queue)
	return room
