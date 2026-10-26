# res://scripts/scope_body.gd — T2: rigid bodies fall the fold's way.
# Same single function as the player: FoldScope.applied_gravity. Engine
# gravity stays off (gravity_scale = 0) so the two can never disagree.
# Bodies stay parented to the room root; folds never carry live bodies (T3
# freezes + reparents on pickup, restores on place/break).
class_name ScopeBody
extends RigidBody3D

const FoldScope = preload("res://scripts/fold_scope.gd")

var active_scopes: Array = []

# _init, not _ready: nodes added during a SceneTree -s script's own _init are
# not inside-tree yet, so _ready never fires there. The property persists.
func _init() -> void:
	gravity_scale = 0.0

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if freeze:
		return
	var g := FoldScope.applied_gravity(self, Time.get_ticks_msec() * 0.001, active_scopes)
	var cf := FoldScope.applied_clock_factor(self, active_scopes)
	state.linear_velocity += g * (state.step * cf)
