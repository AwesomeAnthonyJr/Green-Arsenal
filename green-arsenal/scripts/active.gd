extends Node

func clear_active():
	for c in get_children():
		if is_instance_valid(c):
			c.queue_free()

func load_main_menu():
	clear_active()
	var inst = Preloads.main_menu.instantiate()
	add_child(inst)
	get_parent().not_gameplay = true

func load_room_loader():
	clear_active()
	var inst = Preloads.room_loader.instantiate()
	add_child(inst)
	get_parent().room_loader = inst
	inst.initialize()
