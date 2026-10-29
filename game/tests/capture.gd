# res://tests/capture.gd — headed capture driver. Runs under Xvfb (NOT
# --headless: rendering must stay on). Frames the stunt room, saves viewport
# PNGs to /tmp for in-harness visual review. tmp/ only, never repo.
# NOTE: aim the Camera3D, never player.look_at — that pitches the whole body.
extends Node3D

var frames := 0

func _aim(pos: Vector3, target: Vector3) -> void:
	var player = $Course/Player
	player.global_position = pos
	player.velocity = Vector3.ZERO
	(player.get_node("Camera3D") as Camera3D).look_at(target, Vector3.UP)

func _shot(path: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	print("saved ", path)

func _physics_process(_delta: float) -> void:
	frames += 1
	match frames:
		1:
			_aim(Vector3(-16.0, 3.0, -4.5), Vector3(-2, 3.5, 0))
		40:
			_shot("/tmp/shot_vista.png")
		45:
			_aim(Vector3(4.0, 5.6, 3.4), Vector3(13, 5.0, 0))
		55:
			_shot("/tmp/shot_gate.png")
		60:
			get_tree().quit(0)
