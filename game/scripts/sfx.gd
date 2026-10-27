# res://scripts/sfx.gd — T8: synthesized UI sounds, zero asset files.
# Small sine blips baked to AudioStreamWAV in code so the repo ships no
# audio binaries. Called from gameplay (pad countdown); covered headless.
class_name Sfx
extends RefCounted

const MIX := 22050

static func _tone(freq_hz: float, seconds: float, volume: float, freq2_hz: float = 0.0, volume2: float = 0.0) -> AudioStreamWAV:
	var frames := int(MIX * seconds)
	var data := PackedByteArray()
	data.resize(frames)
	for i in frames:
		var t := float(i) / MIX
		var env := 1.0 - float(i) / frames
		var s := volume * sin(TAU * freq_hz * t)
		if freq2_hz > 0.0:
			s += volume2 * sin(TAU * freq2_hz * t)
		data[i] = int(127.0 + 127.0 * s * env * env)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = MIX
	stream.data = data
	return stream

static func tick() -> AudioStreamWAV:
	return _tone(880.0, 0.07, 0.8)

static func thud() -> AudioStreamWAV:
	return _tone(90.0, 0.25, 1.0)

static func chime() -> AudioStreamWAV:
	return _tone(523.25, 0.4, 0.6, 784.0, 0.4)
