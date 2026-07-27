extends Node3D

#to be clear this is the index to find which seed from Constants.seed_order
@export var seed_index: int
@onready var sprite = $Sprite3D
@onready var anim = $AnimationPlayer

func cutscene_pause():
	Generics.find_main(self).override_pause = true
	get_tree().paused = true

func cutscene_unpause():
	get_tree().paused = false
	Generics.find_main(self).override_pause = false

func bestow_seed(obj):
	anim.play("open")
	if obj is Player:
		SaveManager.player_save.seed_types[seed_index] = true
		#quick but dumb way to do it
		obj.hud.revolver.setup_seeds()

func _ready() -> void:
	update_sprite()

func update_sprite():
	sprite.frame = Constants.seed_order[seed_index]
