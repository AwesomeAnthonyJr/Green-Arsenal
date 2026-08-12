extends Area3D

@export var spin_speed = 0.01
var going_up = true
@onready var texture: Sprite3D = $Sprite3D
@onready var canvas_layer: CanvasLayer = $CanvasLayer
var player_is_colliding = false
var player_reference

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	#texture.rotation.y += spin_speed
	
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
	
	if player_is_colliding and Input.is_action_just_pressed("interact") and !canvas_layer.visible:
		canvas_layer.visible = true
		player_reference.paused = true
	elif player_is_colliding and Input.is_action_just_pressed("interact") and canvas_layer.visible:
		canvas_layer.visible = false
		player_reference.paused = false

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player_reference = body
		player_is_colliding = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		player_is_colliding = false
