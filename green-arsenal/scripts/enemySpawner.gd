extends CharacterBody3D
@export var enemyScene: PackedScene = preload("res://scenes/enemy.tscn")

@onready var spawnPoint: Marker3D = $Marker3D
@onready var timer: Timer = $Timer

@export var maxHealth = 5
@onready var currHealth: int = maxHealth
func _ready() -> void:
	timer.timeout.connect(_spawn_enemy)
func _spawn_enemy() -> void:
	if enemyScene:
		var newEnemy = enemyScene.instantiate()
		newEnemy.global_transform.origin = spawnPoint.global_transform.origin
		get_tree().current_scene.add_child(newEnemy)
func take_damage(amount: int) -> void:
	currHealth -= amount
	print("Remaining health: ", currHealth)
	if currHealth <= 0:
		die()
func die() -> void:
	print("Enemy dead")
	queue_free() 
func _process(delta: float) -> void:
	pass
