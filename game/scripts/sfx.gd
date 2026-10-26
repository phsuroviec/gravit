# res://scripts/sfx.gd — T8: synthesized UI sounds, zero asset files.
# Small sine blips baked to AudioStreamWAV in code so the repo ships no
# audio binaries. Called from gameplay (pad countdown); covered headless.
class_name Sfx
extends RefCounted

const MIX := 22050

static func _tone(freq_hz: float, seconds: float, volume: float) -> AudioStreamWAV:
	var frames := int(MIX * seconds)
	var data := PackedByteArray()
	data.resize(frames)
	for i in frames:
		var t := float(i) / MIX
		var env := 1.0 - float(i) / frames
		data[i] = int(127.0 + volume * 127.0 * sin(TAU * freq_hz * t) * env * env)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = MIX
	stream.data = data
	return stream

static func tick() -> AudioStreamWAV:
	return _tone(880.0, 0.07, 0.8)
