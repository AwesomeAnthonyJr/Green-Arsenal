extends Node3D
class_name RoomLoader

#will not be export in final game!
@export var active_room: Room
@export var active_key = 0

const room_dict = {
	0: "res://scenes/rooms/room_a.tscn",
	1: "res://scenes/rooms/room_b.tscn"
}
#must be the inverse of the first!!!
const reverse_dict = {
	"res://scenes/rooms/room_a.tscn": 0,
	"res://scenes/rooms/room_b.tscn": 1
}

var loadings = []
var loaded_objects_keys = []
var loaded_objects = []

func _ready() -> void:
	setup_active_room(active_key)

func _process(delta):
	for path in loadings:
		var status = ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var resource = ResourceLoader.load_threaded_get(path)
			load_resource(resource, path)
			loadings.erase(path)
	var erase_arr = []
	for i in loaded_objects_keys.size():
		var k = loaded_objects_keys[i]
		var o = loaded_objects[i]
		if !(k in active_room.adjacent_rooms) and !(k == active_key):
			print("ROOM: ", k, " IS BEING REMOVED!!!")
			o.queue_free()
			erase_arr.append(i)
	if erase_arr.size() > 0:
		for i in erase_arr:
			loaded_objects_keys.remove_at(i)
			loaded_objects.remove_at(i)
			print("ERASED OBJECT ", i, " FROM ARRAYS.")
			#var k = loaded_objects_keys[i]
			#var o = loaded_objects[i]

func load_resource(resource: PackedScene, path: String):
	var inst = resource.instantiate()
	add_child(inst)
	inst.global_position = inst.room_pos
	loaded_objects.append(inst)
	loaded_objects_keys.append(reverse_dict[path])

func load_room(key: int):
	var path = room_dict[key]
	ResourceLoader.load_threaded_request(path, "PackedScene")
	loadings.append(path)
	print("ROOM: ", key, " IS LOADED!")

func setup_active_room(key: int):
	#some stuff will need to go here
	if is_instance_valid(active_room):
		active_room.active = false
	
	var already_loaded = false
	for i in loaded_objects_keys.size():
		var k = loaded_objects_keys[i]
		var o = loaded_objects[i]
		if k == key:
			active_room = o
			active_key = k
			already_loaded = true
			break
	if !already_loaded:
		var path = room_dict[key]
		var resource = load(path)
		var inst = resource.instantiate()
		add_child(inst)
		inst.global_position = inst.room_pos
		loaded_objects.append(inst)
		loaded_objects_keys.append(key)
		active_room = inst
		print("RARE FIRST TIME LOAD HAS OCCURED!")
	
	#its a different room now
	active_room.active = true
	
	for k in active_room.adjacent_rooms:
		if !(k in loaded_objects_keys):
			load_room(k)
		else:
			print("ROOM: ", k, " IS ALREADY LOADED!")
