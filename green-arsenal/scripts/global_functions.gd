extends Node

#i used this in countless scripts so it should probably just be stored somewhere
func find_main(x: Node):
	var p = x.get_parent()
	if x is Main:
		return x
	else:
		return find_main(p)

func find_pause_menu(x: Node):
	var p = x.get_parent()
	if x is PauseMenu:
		return x
	else:
		return find_pause_menu(p)

func find_room_loader(x: Node):
	var p = x.get_parent()
	if p is RoomLoader:
		return p
	else:
		return find_room_loader(p)
