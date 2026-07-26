extends Node

const bullet_shot = preload("res://sound/effects/bullet_shot.wav")
const blaze_shot = preload("res://sound/effects/blaze_shot.wav")
const life_shot = preload("res://sound/effects/life_shot.wav")
const seeker_shot = preload("res://sound/effects/seeker_shot.wav")

#pool of players so rapid/overlapping shots don't cut each other off
const pool_size = 8
var players: Array[AudioStreamPlayer] = []
var next_player = 0

func _ready() -> void:
	for i in pool_size:
		var p = AudioStreamPlayer.new()
		p.bus = "Sound"
		add_child(p)
		players.append(p)

#seed_id matches Player.loaded_in_gun's ammo ids (see Constants.seed_order / Player.shoot())
func play_seed_shot(seed_id: int) -> void:
	match seed_id:
		1:
			_play(bullet_shot)
		2:
			_play(blaze_shot)
		4:
			_play(life_shot)
		6:
			_play(seeker_shot)
		_:
			pass
			#no shot sound yet for bounce(3) / platform(5) / propeller(7) / heavy(8) seeds

func _play(stream: AudioStream) -> void:
	var p = players[next_player]
	next_player = (next_player + 1) % players.size()
	p.stream = stream
	p.play()
