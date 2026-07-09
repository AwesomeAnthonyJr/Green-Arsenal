extends Control

@export var current_bullet = 0

@export var petal_1_id = 0
@export var petal_2_id = 0
@export var petal_3_id = 0
@export var petal_4_id = 0
@export var petal_5_id = 0
@export var petal_6_id = 0

@onready var petal_1 = $Rotate0/Petal1
@onready var petal_2 = $Rotate60/Petal2
@onready var petal_3 = $Rotate120/Petal3
@onready var petal_4 = $Rotate180/Petal4
@onready var petal_5 = $Rotate240/Petal5
@onready var petal_6 = $Rotate300/Petal6
@onready var animation_tree = $AnimationTree

#DELETE ALL OF THIS LATER PROCESS!!!
func _process(delta: float) -> void:
	update_petals()
	
	#later replace these with reading data from the gun!!!
	if Input.is_action_just_pressed("shoot"):
		shoot_petal(current_bullet)
		await get_tree().create_timer(0.1).timeout
		current_bullet += 1
		if current_bullet > 6:
			current_bullet = 1
		update_rotation()
	if Input.is_action_just_pressed("reload"):
		var num_to_use = 0
		for i in 7:
			var temp = current_bullet - i
			if temp < 0:
				temp += 7
			if petal_empty(temp) and num_to_use == 0:
				num_to_use = temp
		reload_petal(num_to_use)

func _ready() -> void:
	update_petals()
	update_rotation()

func update_petals():
	petal_1.frame = petal_1_id
	petal_2.frame = petal_2_id
	petal_3.frame = petal_3_id
	petal_4.frame = petal_4_id
	petal_5.frame = petal_5_id
	petal_6.frame = petal_6_id

func reload_petal(num):
	match num:
		1:
			petal_1.get_child(0).play("RESET")
			petal_1_id = 1
		2:
			petal_2.get_child(0).play("RESET")
			petal_2_id = 1
		3:
			petal_3.get_child(0).play("RESET")
			petal_3_id = 1
		4:
			petal_4.get_child(0).play("RESET")
			petal_4_id = 1
		5:
			petal_5.get_child(0).play("RESET")
			petal_5_id = 1
		6:
			petal_6.get_child(0).play("RESET")
			petal_6_id = 1

func petal_empty(num):
	match num:
		1:
			return petal_1_id == 0
		2:
			return petal_2_id == 0
		3:
			return petal_3_id == 0
		4:
			return petal_4_id == 0
		5:
			return petal_5_id == 0
		6:
			return petal_6_id == 0
	return false

func shoot_petal(num):
	match num:
		1:
			petal_1.get_child(0).play("fly_away")
			await get_tree().create_timer(0.1).timeout
			petal_1_id = 0
		2:
			petal_2.get_child(0).play("fly_away")
			await get_tree().create_timer(0.1).timeout
			petal_2_id = 0
		3:
			petal_3.get_child(0).play("fly_away")
			await get_tree().create_timer(0.1).timeout
			petal_3_id = 0
		4:
			petal_4.get_child(0).play("fly_away")
			await get_tree().create_timer(0.1).timeout
			petal_4_id = 0
		5:
			petal_5.get_child(0).play("fly_away")
			await get_tree().create_timer(0.1).timeout
			petal_5_id = 0
		6:
			petal_6.get_child(0).play("fly_away")
			await get_tree().create_timer(0.1).timeout
			petal_6_id = 0

func update_rotation():
	var playback = animation_tree["parameters/playback"]
	match current_bullet:
		1:
			playback.travel("on_bullet_1")
		2:
			playback.travel("on_bullet_2")
		3:
			playback.travel("on_bullet_3")
		4:
			playback.travel("on_bullet_4")
		5:
			playback.travel("on_bullet_5")
		6:
			playback.travel("on_bullet_6")
