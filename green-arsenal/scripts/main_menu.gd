extends Node3D

@onready var new_text = $CanvasLayer/OtherMenu/New
@onready var load_text = $CanvasLayer/OtherMenu/Load
@onready var quit_text = $CanvasLayer/OtherMenu/Quit
@onready var canvas_layer = $CanvasLayer

@onready var anim = $AnimationTree
@onready var music = $AudioStreamPlayer
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
	loop_count = 1
	music.volume_db = -3.0
	music.pitch_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	update_visuals()

func _unhandled_input(event: InputEvent) -> void:
	if menu_position == 0:
		if event is InputEventKey && event.pressed:
			supress_next_input = true
			menu_position = 1
		elif event is InputEventMouseButton && event.pressed:
			supress_next_input = true
			menu_position = 1
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
	if supress_next_input:
		supress_next_input = false
		return
	match menu_position:
		1:
			menu_position = 2
		2:
			pass
		3:
			pass
		4:
			menu_position = 1
	update_visuals()

func read_down():
	if supress_next_input:
		supress_next_input = false
		return
	match menu_position:
		1:
			menu_position = 4
		2:
			menu_position = 1
		3:
			menu_position = 1
		4:
			pass
	update_visuals()

func read_left():
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
		4:
			pass
	update_visuals()

func read_right():
	if supress_next_input:
		supress_next_input = false
		return
	match menu_position:
		1:
			pass
		2:
			if can_load_game:
				menu_position = 3
		3:
			pass
		4:
			pass
	update_visuals()

func read_accept():
	if supress_next_input:
		supress_next_input = false
		return
	match menu_position:
		1:
			if new_game:
				SaveManager.reset_save()
			await get_tree().create_timer(0.1).timeout
			start_game()
		2:
			new_game = true
		3:
			new_game = false
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
	manager.jump.connect(read_accept)
	manager.pause.connect(read_back)
	manager.reload.connect(read_back)
	manager.interact.connect(read_accept)


func _on_audio_stream_player_finished() -> void:
	#print(loop_count)
	###this makes it get weird as it loops which i think is kind of fun :)
	music.play()
	loop_count += 1
	music.pitch_scale -= 0.05
	if loop_count > 1:
		music.volume_db -= 2.0
