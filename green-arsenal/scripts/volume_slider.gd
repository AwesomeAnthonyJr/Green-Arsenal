extends HSlider

@export var bus_index: int

func _process(delta: float) -> void:
	update_slider_value()

func update_slider_value():
	match bus_index:
		0:
			value = SaveManager.player_settings.master_vol
		1:
			value = SaveManager.player_settings.music_vol
		2:
			value = SaveManager.player_settings.sound_vol
