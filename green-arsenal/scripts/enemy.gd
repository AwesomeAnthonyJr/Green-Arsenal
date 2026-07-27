extends CharacterBody3D


@export var speed = 2
@export var maxHealth = 1
@export var contact_damage = 1
var player = null

@onready var currHealth: int = maxHealth
var move_velocity: Vector3 = Vector3.ZERO
var target_velocity: Vector3 = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player == null:
		find_player()

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		return
	var level = get_tree().current_scene
	if level:
		for c in level.get_children():
			if c.is_in_group("player_package") and player == null:
				player = c.get_child(0)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		move_velocity += get_gravity() * delta
	if player != null:
		var target_pos = player.global_position
		target_pos.y = global_position.y 
		var dist = global_position.distance_to(target_pos)
		if dist > 0.1 and dist < 10.0:
			look_at(target_pos, Vector3.UP)
		var direction = (target_pos - global_position).normalized()
		move_velocity.x = direction.x * speed
		move_velocity.z = direction.z * speed
	else:
		move_velocity.x = 0
		move_velocity.z = 0
	velocity = target_velocity + move_velocity
	move_and_slide()
	target_velocity = target_velocity.lerp(Vector3.ZERO, delta)
func take_damage(amount: int) -> void:
	currHealth -= amount
	print("Remaining health: ", currHealth)
	if currHealth <= 0:
		die()

func take_knockback(amount: Vector3) -> void:
	target_velocity += amount

func die() -> void:
	print("Enemy dead")
	queue_free() 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hurtbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			if !body.iframes:
				body.take_damage(contact_damage)
			take_knockback(5.0 * global_basis.z)
