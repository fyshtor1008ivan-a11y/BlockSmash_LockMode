class_name Sfx
extends Node

const RATE := 22050
var players := {}

func _ready() -> void:
    _add("pick", [[520.0, 0.05]], 0.35)
    _add("place", [[330.0, 0.12]], 0.6)
    _add("invalid", [[180.0, 0.10]], 0.5)
    _add("clear", [[523.0, 0.08], [659.0, 0.08], [784.0, 0.14]], 0.6)
    _add("gameover", [[392.0, 0.18], [330.0, 0.18], [262.0, 0.30]], 0.6)

func play(sound_name: String, pitch: float = 1.0) -> void:
    if players.has(sound_name):
        players[sound_name].pitch_scale = pitch
        players[sound_name].play()

func _add(sound_name: String, notes: Array, gain: float) -> void:
    var data := PackedByteArray()
    for note in notes:
        data.append_array(_tone(note[0], note[1], gain))
    var wav := AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = RATE
    wav.stereo = false
    wav.data = data
    var player := AudioStreamPlayer.new()
    player.stream = wav
    add_child(player)
    players[sound_name] = player

func _tone(freq: float, duration: float, gain: float) -> PackedByteArray:
    var count := int(RATE * duration)
    var data := PackedByteArray()
    data.resize(count * 2)
    for i in count:
        var envelope := 1.0 - float(i) / count
        var value := int(sin(TAU * freq * float(i) / RATE) * envelope * gain * 30000.0)
        data.encode_s16(i * 2, value)
    return data
