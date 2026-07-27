extends Control
class_name ControlsText

@export var code: String
@onready var scaler = $Control
@onready var text = $Control/RichTextLabel

func _ready() -> void:
	await get_tree().process_frame
	update_text()
	SaveManager.player_settings.input_changed.connect(update_text)

func update_text():
	var val = SaveManager.player_settings.get_text(code)
	var length = val.length()
	var scale_x = 1.0
	match length:
		1:
			scale_x = 1.0
		2:
			scale_x = 1.0
		3:
			scale_x = 0.75
		4:
			scale_x = 0.55
		5:
			scale_x = 0.45
	scaler.scale.x = scale_x
	text.text = "[center]" + val.to_upper() + "[/center]"
	#print(text.text)
