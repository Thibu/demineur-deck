extends Node

var _player_reveal: AudioStreamPlayer
var _player_flag: AudioStreamPlayer
var _player_unflag: AudioStreamPlayer
var _player_cascade: AudioStreamPlayer
var _player_explosion: AudioStreamPlayer
var _player_victory: AudioStreamPlayer

func _ready() -> void:
	_player_reveal = _make_player(_make_beep(880.0, 0.04, 0.15))
	_player_flag = _make_player(_make_beep(440.0, 0.06, 0.2))
	_player_unflag = _make_player(_make_beep(330.0, 0.04, 0.1))
	_player_cascade = _make_player(_make_beep(1200.0, 0.02, 0.08))
	_player_explosion = _make_player(_make_noise_burst(0.3))
	_player_victory = _make_player(_make_victory())
	add_child(_player_reveal)
	add_child(_player_flag)
	add_child(_player_unflag)
	add_child(_player_cascade)
	add_child(_player_explosion)
	add_child(_player_victory)

func play_reveal() -> void:
	_play_safe(_player_reveal)

func play_flag() -> void:
	_play_safe(_player_flag)

func play_unflag() -> void:
	_play_safe(_player_unflag)

func play_cascade() -> void:
	_play_safe(_player_cascade)

func play_explosion() -> void:
	_play_safe(_player_explosion)

func play_victory() -> void:
	_play_safe(_player_victory)

func _play_safe(player: AudioStreamPlayer) -> void:
	if not player.playing:
		player.play()

func _make_player(stream: AudioStream) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = -6.0
	return p

func _make_beep(freq: float, duration: float, volume: float = 0.15) -> AudioStreamWAV:
	var sample_rate := 22050
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t := float(i) / sample_rate
		var val := int(volume * 32767.0 * sin(2.0 * PI * freq * t) * (1.0 - float(i) / float(samples)))
		val = clampi(val, -32768, 32767)
		data.encode_s16(i * 2, val)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _make_noise_burst(duration: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var env := 1.0 - float(i) / float(samples)
		var val := int(0.3 * 32767.0 * (randf() * 2.0 - 1.0) * env * env)
		val = clampi(val, -32768, 32767)
		data.encode_s16(i * 2, val)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _make_victory() -> AudioStreamWAV:
	var sample_rate := 22050
	var notes := [523.25, 659.25, 783.99, 1046.50]
	var note_dur := 0.1
	var total_samples := int(sample_rate * notes.size() * note_dur)
	var data := PackedByteArray()
	data.resize(total_samples * 2)
	var idx := 0
	for note in notes:
		var note_samples := int(sample_rate * note_dur)
		for i in range(note_samples):
			var t := float(i) / sample_rate
			var env := minf(float(i) / (sample_rate * 0.01), 1.0) * (1.0 - float(i) / float(note_samples))
			var val := int(0.15 * 32767.0 * sin(2.0 * PI * note * t) * env)
			val = clampi(val, -32768, 32767)
			data.encode_s16(idx * 2, val)
			idx += 1
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream
