extends Node3D
class_name Room

###for use with the "room loader" script

@export var adjacent_rooms: Array[int]
@export var room_pos: Vector3
var room_loader: RoomLoader
var active = false

func _ready() -> void:
	room_loader = find_main(self).room_loader

func find_main(x) -> Main:
	var p = x.get_parent()
	if p is Main:
		return p
	else:
		return find_main(p)

func go_to_room(i):
	if i in adjacent_rooms:
		room_loader.setup_active_room(i)
	else:
		print("ERROR: requested index not in adjacent rooms list!")
