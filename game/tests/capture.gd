# res://tests/capture.gd — T14 headed capture driver. Runs under Xvfb
# (NOT --headless: rendering must stay on). Frames the Room 1 vista, saves
# viewport PNGs to /tmp for in-harness visual review. tmp/ only, never repo.
extends Node3D

var frames := 0

func _ready() -> void:
	var player = $Course/Player
	player.global_position = Vector3(3, 3.5, 7)
	player.look_at(Vector3(-2, 1.2, 0), Vector3.UP)

func _physics_process(_delta: float) -> void:
	frames += 1
	var player = $Course/Player
	player.global_position = Vector3(3, 3.5, 7)
	player.velocity = Vector3.ZERO
	if frames == 60 or frames == 180 or frames == 360:
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		img.save_png("/tmp/shot_%d.png" % frames)
		print("saved /tmp/shot_%d.png" % frames)
	if frames == 380:
		get_tree().quit(0)
