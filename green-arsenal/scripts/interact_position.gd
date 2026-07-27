extends Control

const inactive_pos = Vector2(640, 800)
var target_pos: Vector2
var interact_active = false
var description: String
var modulation_count = 0.0

@onready var desc_text = $BarText
@onready var sprite = $Sprite2D

func _process(delta: float) -> void:
	if interact_active:
		position = position.lerp(target_pos, 0.5)
		if position.distance_to(target_pos) <= 5.0:
			desc_text.display(description)
		modulation_count += delta * 4
		modulation_count = min(1.0, modulation_count)
	else:
		position = position.lerp(inactive_pos, 0.5)
		if position.distance_to(inactive_pos) <= 5.0:
			desc_text.display("")
		modulation_count -= delta * 6
		modulation_count = max(0.0, modulation_count)
	update_modulation()

func update_modulation():
	var temp = Color(1.0, 1.0, 1.0, 0.8 * modulation_count)
	sprite.modulate = temp
	desc_text.modulate = temp
