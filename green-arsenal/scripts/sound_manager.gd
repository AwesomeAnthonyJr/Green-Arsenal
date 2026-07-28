extends Node

const bullet_shot = preload("res://sound/effects/bullet_shot.wav")
const blaze_shot = preload("res://sound/effects/blaze_shot.wav")
const life_shot = preload("res://sound/effects/life_shot.wav")
const seeker_shot = preload("res://sound/effects/seeker_shot.wav")
const bounce_shot = preload("res://sound/effects/bounce_shot.wav")
const platform_shot = preload("res://sound/effects/platform_shot.wav")
const propeller_shot = preload("res://sound/effects/propeller_shot.wav")
const heavy_shot = preload("res://sound/effects/heavy_shot.wav")

const coldcast = preload("res://sound/imported_from_old_projects/coldcast.wav")

const player_hurt = preload("res://sound/imported_from_old_projects/enemydeath.wav")
const player_hurt_2 = preload("res://sound/imported_from_old_projects/melee.wav")

const revolver_open = preload("res://sound/imported_from_old_projects/revolveropen.wav")
const revolver_close = preload("res://sound/imported_from_old_projects/revolverclose.wav")
const schwing = preload("res://sound/imported_from_old_projects/xcvb_schwing.wav")

const reject = preload("res://sound/imported_from_old_projects/reject.wav")

const footstep = preload("res://sound/imported_from_old_projects/footsteps_sound_short.wav")
const jump = preload("res://sound/effects/servicable_jump.wav")

const menu_open = preload("res://sound/effects/GA_menu_open.wav")
const menu_close = preload("res://sound/effects/GA_menu_close.wav")
const upgrade_pickup = preload("res://sound/imported_from_old_projects/upgradePickup.wav")
const menu_click = preload("res://sound/imported_from_old_projects/AWTRAU_menu_click_1.wav")
const menu_accept = preload("res://sound/effects/GA_menu_accept.wav")

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

func play_hurt():
	_play(player_hurt, -2)
	_play(player_hurt_2)

func play_revolver_open():
	_play(revolver_open)

func play_jump():
	_play(jump, -2)

func play_menu_open():
	_play(menu_open, -4)
func play_menu_close():
	_play(menu_close, -4)
func play_menu_next():
	_play(upgrade_pickup, 4, 0, 1.5)
func play_menu_tick():
	_play(menu_click, 0, 0, 1.5)
func play_menu_accept():
	_play(menu_accept, -4)

func play_reload(current_bullet: int):
	_play(reject, -6, 0, 1.0 + current_bullet * 0.1)

func play_revolver_close(include_schwing: bool = true):
	_play(revolver_close, 1, 0.25)
	if include_schwing:
		_play(schwing, 5)

func play_footstep():
	_play(footstep, -6, 0, randf_range(0.6, 0.8))

#seed_id matches Player.loaded_in_gun's ammo ids (see Constants.seed_order / Player.shoot())
func play_seed_shot(seed_id: int) -> void:
	match seed_id:
		1:
			_play(coldcast)
		2:
			_play(blaze_shot)
		3:
			_play(bounce_shot)
		4:
			_play(life_shot)
		5:
			_play(platform_shot)
		6:
			_play(seeker_shot)
		7:
			_play(propeller_shot)
		8:
			_play(heavy_shot)
		_:
			pass

func _play(stream: AudioStream, db_offset: float = 0, start_offset: float = 0, pitch_scale: float = 1.0) -> void:
	var p = players[next_player]
	next_player = (next_player + 1) % players.size()
	p.stream = stream
	p.volume_db = db_offset
	p.pitch_scale = pitch_scale
	p.play(start_offset)
