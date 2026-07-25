extends Area3D

@onready var texture: Sprite3D = $Sprite3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var abseleine: Sprite3D = $Abseleine
var player_reference

@export var operator_scene : DialogicTimeline

@export var spin_speed = 0.01
var going_up = true

var player_is_colliding = false

func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_timeline_ended)

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
	
	if player_is_colliding and Input.is_action_just_pressed("interact") and Dialogic.current_timeline == null:
		abseleine.visible = true
		animation_player.play("drop")
		await animation_player.animation_finished
		Dialogic.start(operator_scene)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player_reference = body
		player_is_colliding = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		player_is_colliding = false

func _on_timeline_ended():
	animation_player.play_backwards("drop")
	await animation_player.animation_finished
	abseleine.visible = false
