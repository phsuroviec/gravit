# res://tests/test_runner.gd — T1 headless invariant suite.
# Run: godot --headless --path game -s res://tests/test_runner.gd
# Exits 0 only when all four invariants hold.
extends SceneTree

const FoldScope = preload("res://scripts/fold_scope.gd")
const ConsequenceQueue = preload("res://scripts/consequence_queue.gd")

const GRAV := 9.8

var _failures: int = 0

func _init() -> void:
	print("=== RUNNING HEADLESS INVARIANT SUITE ===")
	test_i_scopes_form_tree()
	test_ii_gravity_inside_fold()
	test_iii_consequence_fires_once_on_time()
	test_iv_breaking_fold_preserves_contents()
	if _failures == 0:
		print("=== ALL 4 INVARIANTS PASSED ===")
		quit(0)
	else:
		printerr("=== SUITE FAILED WITH %d ERRORS ===" % _failures)
		quit(1)

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		_failures += 1
		printerr("FAIL: ", msg)
	else:
		print("PASS: ", msg)

func _make_room(room_name: String) -> Node3D:
	var room := Node3D.new()
	room.name = room_name
	root.add_child(room)
	return room

# Invariant (i): fold scopes form a valid tree (no cycles, accurate depth,
# second parent refused). ADR-3: refusal returns false + warns, tree untouched.
func test_i_scopes_form_tree() -> void:
	var outer = FoldScope.new()
	outer.name = "Outer"
	var inner = FoldScope.new()
	inner.name = "Inner"
	var leaf = FoldScope.new()
	leaf.name = "Leaf"
	_assert(outer.add_child_scope(inner) == true, "(i) inner attaches to outer")
	_assert(inner.add_child_scope(leaf) == true, "(i) leaf attaches to inner")
	_assert(leaf.add_child_scope(outer) == false, "(i) cycle leaf->outer rejected")
	_assert(outer.get_depth() == 1 and inner.get_depth() == 2 and leaf.get_depth() == 3, "(i) tree depths 1, 2, 3")
	_assert(outer.add_child_scope(leaf) == false, "(i) second parent refused")
	_assert(leaf.get_depth() == 3, "(i) depth untouched after refused attach")
	_assert(outer.add_child_scope(outer) == false, "(i) self-attach refused")
	outer.free()
	inner.free()
	leaf.free()

# Invariant (ii): gravity inside a fold equals the deepest containing fold's
# gravity; bodies outside every fold get world gravity.
func test_ii_gravity_inside_fold() -> void:
	var room := _make_room("Room2")
	var outer = FoldScope.new()
	outer.name = "Outer"
	outer.gravity_dir = Vector3.RIGHT
	var inner = FoldScope.new()
	inner.name = "Inner"
	inner.gravity_dir = Vector3.UP
	room.add_child(outer)
	room.add_child(inner)
	outer.add_child_scope(inner)
	var body := RigidBody3D.new()
	body.name = "Body"
	room.add_child(body)
	outer.add_body(body)
	var scopes: Array = [outer, inner]
	var g_outer: Vector3 = FoldScope.applied_gravity(body, 0.0, scopes)
	_assert(g_outer.is_equal_approx(Vector3(GRAV, 0, 0)), "(ii) outer fold gravity overrides world")
	inner.add_body(body)
	var g_inner: Vector3 = FoldScope.applied_gravity(body, 0.0, scopes)
	_assert(g_inner.is_equal_approx(Vector3(0, GRAV, 0)), "(ii) inner fold gravity overrides outer")
	var outsider := RigidBody3D.new()
	outsider.name = "Outsider"
	room.add_child(outsider)
	var g_world: Vector3 = FoldScope.applied_gravity(outsider, 0.0, scopes)
	_assert(g_world.is_equal_approx(Vector3(0, -GRAV, 0)), "(ii) body outside folds gets world gravity")
	room.free()

# Invariant (iii): a queued consequence fires exactly once at due_time.
# ADR-4: a freed target is dropped, counted in `dropped`, never thrown.
func test_iii_consequence_fires_once_on_time() -> void:
	var room := _make_room("Room3")
	var cq = ConsequenceQueue.new()
	cq.name = "Queue"
	room.add_child(cq)
	var body := RigidBody3D.new()
	body.name = "Body"
	room.add_child(body)
	var item = cq.enqueue(body, Vector3(0, 0, -10), 1.5)
	_assert(item.due_time >= 1.49 and item.due_time <= 1.51, "(iii) due_time = now + delay")
	cq.step_clock(0.5)
	_assert(item.fired == false, "(iii) not fired at t=0.5s")
	cq.step_clock(0.99)
	_assert(item.fired == false, "(iii) not fired at t=1.49s")
	cq.step_clock(0.02)
	_assert(item.fired == true, "(iii) fired at t=1.51s (due 1.50s)")
	_assert(cq.pending() == 0, "(iii) queue drained after fire")
	cq.step_clock(1.0)
	_assert(cq.pending() == 0 and cq.dropped == 0, "(iii) never fires twice; dropped=0")
	var doomed := RigidBody3D.new()
	doomed.name = "Doomed"
	room.add_child(doomed)
	cq.enqueue(doomed, Vector3.UP, 0.5)
	doomed.free()
	cq.step_clock(1.0)
	_assert(cq.dropped == 1 and cq.pending() == 0, "(iii) freed target dropped and counted")
	print("(iii) dropped=", cq.dropped)
	room.free()

# Invariant (iv): breaking a fold moves all contents and child folds to the
# parent scope without loss; the broken fold leaves the active set.
func test_iv_breaking_fold_preserves_contents() -> void:
	var room := _make_room("Room4")
	var outer = FoldScope.new()
	outer.name = "Outer"
	var inner = FoldScope.new()
	inner.name = "Inner"
	var leaf = FoldScope.new()
	leaf.name = "Leaf"
	room.add_child(outer)
	room.add_child(inner)
	room.add_child(leaf)
	outer.add_child_scope(inner)
	inner.add_child_scope(leaf)
	var b1 := RigidBody3D.new()
	b1.name = "B1"
	var b2 := RigidBody3D.new()
	b2.name = "B2"
	room.add_child(b1)
	room.add_child(b2)
	inner.add_body(b1)
	inner.add_body(b2)
	var scopes: Array = [outer, inner, leaf]
	inner.break_fold(room, scopes)
	_assert(outer.has_body(b1) and outer.has_body(b2), "(iv) bodies transferred to parent scope")
	_assert(outer.contents.size() == 2, "(iv) zero body loss on fold break")
	_assert(leaf.parent_scope == outer, "(iv) child fold reparented to grandparent")
	_assert(not (inner in scopes), "(iv) broken fold removed from active scopes")
	_assert(inner.contents.is_empty(), "(iv) broken fold left empty")
	room.free()
