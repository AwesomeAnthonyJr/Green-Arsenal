extends Node3D
class_name MainMenu

@onready var new_text = $CanvasLayer/OtherMenu/New
@onready var load_text = $CanvasLayer/OtherMenu/Load
@onready var quit_text = $CanvasLayer/OtherMenu/Quit
@onready var canvas_layer = $CanvasLayer

@onready var anim = $AnimationTree
@onready var music = $AudioStreamPlayer
@onready var cam = $Camera3D
var menu_position = 0
#0 - starting
#1 - box
#2 - new
#3 - load
#4 - quit
var new_game: bool = true
var can_load_game: bool = true
var supress_next_input: bool = false
var loop_count: int = 0
var target_rot = Vector2.ZERO
@onready var intro_cam = $Intro/Camera3D
@onready var intro_anim = $Intro/AnimationPlayer

func _ready() -> void:
	connect_inputs()
	menu_startup()

func menu_startup():
	if SaveManager.player_save.load_point == 0:
		new_game = true
		can_load_game = false
	else:
		new_game = false
		can_load_game = true
	music.play()
	if Generics.find_main(self).first_time:
		loop_count = 0
		intro_anim.play("intro")
		intro_cam.current = true
		Generics.find_main(self).first_time = false
	else:
		loop_count = 1
		canvas_layer.show()
	music.volume_db = -3.0
	music.pitch_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	update_visuals()

func _unhandled_input(event: InputEvent) -> void:
	if !canvas_layer.visible:
		return
	if menu_position == 0:
		if event is InputEventKey && event.pressed:
			supress_next_input = true
			menu_position = 1
			SoundManager.play_menu_tick()
		elif event is InputEventMouseButton && event.pressed:
			supress_next_input = true
			menu_position = 1
			SoundManager.play_menu_tick()
	update_visuals()
	

func update_visuals():
	var playback = anim["parameters/playback"]
	match menu_position:
		0:
			playback.travel("starting")
		1:
			if new_game:
				playback.travel("on_box_newgame")
			else:
				playback.travel("on_box_loadgame")
			if !can_load_game:
				load_text.modulate = Color(0.0, 0.0, 0.0, 0.5)
			else:
				load_text.modulate = Color(0.0, 0.0, 0.0, 1.0)
			new_text.modulate = Color(0.0, 0.0, 0.0, 1.0)
			quit_text.modulate = Color(0.0, 0.0, 0.0, 1.0)
		2:
			if new_game:
				playback.travel("on_no_box")
			else:
				playback.travel("on_no_box_2")
			new_text.modulate = Color("#fad019")
			if !can_load_game:
				load_text.modulate = Color(0.0, 0.0, 0.0, 0.5)
			else:
				load_text.modulate = Color(0.0, 0.0, 0.0, 1.0)
			quit_text.modulate = Color(0.0, 0.0, 0.0, 1.0)
		3:
			if new_game:
				playback.travel("on_no_box")
			else:
				playback.travel("on_no_box_2")
			new_text.modulate = Color(0.0, 0.0, 0.0, 1.0)
			load_text.modulate = Color("#fad019")
			quit_text.modulate = Color(0.0, 0.0, 0.0, 1.0)
		4:
			if new_game:
				playback.travel("on_no_box")
			else:
				playback.travel("on_no_box_2")
			new_text.modulate = Color(0.0, 0.0, 0.0, 1.0)
			if !can_load_game:
				load_text.modulate = Color(0.0, 0.0, 0.0, 0.5)
			else:
				load_text.modulate = Color(0.0, 0.0, 0.0, 1.0)
			quit_text.modulate = Color("#e2383b")

func read_up():
	if !canvas_layer.visible:
		return
	if supress_next_input:
		supress_next_input = false
		return
	match menu_position:
		1:
			menu_position = 2
			SoundManager.play_menu_next()
		2:
			pass
		3:
			pass
		4:
			menu_position = 1
			SoundManager.play_menu_next()
	update_visuals()

func read_down():
	if supress_next_input:
		supress_next_input = false
		return
	match menu_position:
		1:
			menu_position = 4
			SoundManager.play_menu_next()
		2:
			menu_position = 1
			SoundManager.play_menu_next()
		3:
			menu_position = 1
			SoundManager.play_menu_next()
		4:
			pass
	update_visuals()

func read_left():
	if !canvas_layer.visible:
		return
	if supress_next_input:
		supress_next_input = false
		return
	match menu_position:
		1:
			pass
		2:
			pass
		3:
			menu_position = 2
			SoundManager.play_menu_next()
		4:
			pass
	update_visuals()

func read_right():
	if !canvas_layer.visible:
		return
	if supress_next_input:
		supress_next_input = false
		return
	match menu_position:
		1:
			pass
		2:
			if can_load_game:
				menu_position = 3
				SoundManager.play_menu_next()
		3:
			pass
		4:
			pass
	update_visuals()

func read_accept():
	if !canvas_layer.visible:
		return
	if supress_next_input:
		supress_next_input = false
		return
	match menu_position:
		1:
			if new_game:
				SaveManager.reset_save()
			SoundManager.play_menu_accept()
			await get_tree().create_timer(0.1).timeout
			start_game()
		2:
			new_game = true
			SoundManager.play_menu_accept()
		3:
			new_game = false
			SoundManager.play_menu_accept()
		4:
			get_tree().quit()
	update_visuals()

func start_game():
	var m: Main = Generics.find_main(self)
	m.not_gameplay = false
	get_parent().load_room_loader()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func read_back():
	pass
	#genuinely probably doesn't need to be here tbh

func connect_inputs():
	var manager = Generics.find_main(self).input_manager
	manager.up.connect(read_up)
	manager.down.connect(read_down)
	manager.left.connect(read_left)
	manager.right.connect(read_right)
	manager.sprint_burst.connect(read_back)
	#manager.jump.connect(read_accept)
	manager.pause.connect(read_back)
	manager.reload.connect(read_back)
	manager.interact.connect(read_accept)
	manager.look_2.connect(read_look)

func read_look(y, x):
	if !canvas_layer.visible:
		return
	cam.current = true
	target_rot.x += x * 0.1
	target_rot.y += y * 0.1
	target_rot.x = clampf(target_rot.x, -0.1, 0.1)
	target_rot.y = clampf(target_rot.y, -0.1, 0.1)

func _process(delta: float) -> void:
	cam.rotation.x = lerpf(cam.rotation.x, target_rot.x, 0.5)
	cam.rotation.y = lerpf(cam.rotation.y, target_rot.y + deg_to_rad(-180.0), 0.5)
	if Input.is_action_just_pressed("skip_for_testing"):
		SaveManager.test_save()
		SoundManager.play_menu_accept()
		await get_tree().create_timer(0.1).timeout
		start_game()

func _on_audio_stream_player_finished() -> void:
	#print(loop_count)
	###this makes it get weird as it loops which i think is kind of fun :)
	music.play()
	loop_count += 1
	if loop_count > 1:
		music.pitch_scale -= 0.05
	if loop_count > 1:
		music.volume_db -= 2.0
