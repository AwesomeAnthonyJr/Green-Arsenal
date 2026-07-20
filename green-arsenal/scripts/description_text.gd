extends RichTextLabel

func display(message: String):
	#format any "controls-based" text, using "{}" notation (see godot docs on string formatting)
	message = message.format({"move_forward": SaveManager.player_settings.get_text("move_forward").to_upper()})
	message = message.format({"move_back": SaveManager.player_settings.get_text("move_back").to_upper()})
	message = message.format({"move_left": SaveManager.player_settings.get_text("move_left").to_upper()})
	message = message.format({"move_right": SaveManager.player_settings.get_text("move_right").to_upper()})
	message = message.format({"sprint": SaveManager.player_settings.get_text("sprint").to_upper()})
	message = message.format({"jump": SaveManager.player_settings.get_text("jump").to_upper()})
	message = message.format({"pause": SaveManager.player_settings.get_text("pause").to_upper()})
	message = message.format({"shoot": SaveManager.player_settings.get_text("shoot").to_upper()})
	message = message.format({"reload": SaveManager.player_settings.get_text("reload").to_upper()})
	message = message.format({"interact": SaveManager.player_settings.get_text("interact").to_upper()})
	message = message.format({"close_reload": SaveManager.player_settings.get_text("close_reload").to_upper()})
	
	message = message.format({"max_hp": str(SaveManager.player_save.max_hp)})
	message = message.format({"growth_charges": str(SaveManager.player_save.growth_charges)})
	
	text = message
