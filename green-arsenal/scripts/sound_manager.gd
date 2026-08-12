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

const root_destroy = preload("res://sound/imported_from_old_projects/green_arsenal_root_destroy.wav")
const grow = preload("res://sound/effects/green_arsenal_grow.wav")
const heal = preload("res://sound/effects/green_arsenal_heal.wav")
const heal_2 = preload("res://sound/effects/green_arsenal_warp_away.wav")
const explosion_1 = preload("res://sound/imported_from_old_projects/explosion1.wav")

#pool of players so rapid/overlapping shots don't cut each other off
const pool_size = 8
var players: Array[AudioStreamPlayer] = []
var next_player = 0

var current_jump_player: AudioStreamPlayer
var jump_holder: Player

func _ready() -> void:
	for i in pool_size:
		var p = AudioStreamPlayer.new()
		p.bus = "Sound"
		add_child(p)
		players.append(p)

func play_hurt():
	_play(player_hurt, -2)
	_play(player_hurt_2)

func play_landing():
	#_play(root_destroy, -14, 0, randf_range(1.0, 1.2))
	_play(footstep, -4, 0, randf_range(0.6, 0.8))
	await get_tree().create_timer(0.1).timeout
	_play(footstep, -4, 0, randf_range(0.6, 0.8))

func play_revolver_open():
	_play(revolver_open)

func play_jump(obj = null):
	current_jump_player = players[next_player]
	jump_holder = obj
	_play(jump, -12, 0, randf_range(1.4, 1.6))

func _process(delta: float) -> void:
	if jump_holder != null and current_jump_player != null:
		if jump_holder.is_jump_drifting:
			current_jump_player.pitch_scale += -0.2 * delta
	else:
		if current_jump_player != null:
			current_jump_player = null
		if jump_holder != null:
			jump_holder = null

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
	_play(footstep, -9, 0, randf_range(0.6, 0.8))

func play_splash():
	_play(platform_shot, -6, 0, randf_range(0.9, 1.1))

func play_splash_small():
	_play(platform_shot, -9, 0, randf_range(1.2, 1.4))

func play_root_destroy():
	_play(root_destroy, -16, 0, randf_range(1.2, 1.4))

func play_grow():
	_play(grow, 0, 0, randf_range(0.8, 1.0))

func play_heal():
	_play(heal)

func play_max_heal():
	_play(heal)
	_play(heal_2)

func play_enemy_destroy():
	_play(explosion_1, -5, 0, randf_range(1.0, 1.3))

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
			_play(coldcast)
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
