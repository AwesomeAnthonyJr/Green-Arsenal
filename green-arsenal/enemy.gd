extends CharacterBody3D


@export var speed = 2
@export var maxHealth = 10
@export var player: Node3D

@onready var currHealth: float = maxHealth
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if player != null:
		var target_pos = player.global_position
		target_pos.y = global_position.y 
		if global_position.distance_to(target_pos) > 0.1:
			look_at(target_pos, Vector3.UP)
		var direction = (target_pos - global_position).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0
	move_and_slide()
func take_damage(amount: float) -> void:
	currHealth -= amount
	print("Remaining health: ", currHealth)
	if currHealth <= 0:
		die()
func die() -> void:
	print("Enemy dead")
	queue_free() 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
