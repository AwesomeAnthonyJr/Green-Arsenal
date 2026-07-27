extends HSlider

func _process(delta: float) -> void:
	update_slider_value()

func update_slider_value():
	value = SaveManager.player_settings.mouse_sense
