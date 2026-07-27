extends Area3D
class_name SaveOperator

@onready var texture: Sprite3D = $Sprite3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var abseleine: Sprite3D = $Abseleine
var player_reference

@export var operator_scenes : Array[DialogicTimeline]
var scene_index : int = 0

@export var spin_speed = 0.01
var going_up = true

var player_is_colliding = false

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _physics_process(delta: float) -> void:
	#SPIN ICON
	texture.rotation.y += spin_speed

	if going_up:
		if texture.position.y <= 2:
			texture.position.y += 0.01
		else:
			going_up = false
			
	elif going_up == false:
		if texture.position.y >= 1:
			texture.position.y -= 0.01
		else:
			going_up = true
	
	if player_is_colliding and Input.is_action_just_pressed("interact") and Dialogic.current_timeline == null and animation_player.is_playing() == false:
		abseleine.visible = true
		animation_player.play("drop")
		player_reference.paused = true
		await animation_player.animation_finished
		Dialogic.start(operator_scenes[scene_index])
		if scene_index + 1 < operator_scenes.size():
			scene_index += 1


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player_reference = body
		player_is_colliding = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		player_is_colliding = false

#func _on_timeline_ended():
	#animation_player.play_backwards("drop")
	#await animation_player.animation_finished
	#if Dialogic.current_timeline == null:
		#abseleine.visible = false

func _on_dialogic_signal(arg):
	if arg == "scene_end_op":
		animation_player.play_backwards("drop")
		player_reference.paused = false
		await animation_player.animation_finished
		#if Dialogic.current_timeline == null:
		abseleine.visible = false
