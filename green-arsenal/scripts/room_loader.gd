extends Node3D
class_name RoomLoader

#will not be export in final game!
@export var active_room: Room
@export var active_key = 4

const room_dict = {
	0: "res://scenes/rooms/room_a.tscn",
	1: "res://scenes/rooms/room_b.tscn",
	2: "res://scenes/rooms/room_c.tscn",
	
	4: "res://scenes/rooms/forest/forest_1_NEW.tscn",
	5: "res://scenes/rooms/forest/forest_2.tscn",
	6: "res://scenes/rooms/forest/forest_3_NEWER.tscn",
	7: "res://scenes/rooms/forest/forest_4_NEWER.tscn",
	8: "res://scenes/rooms/forest/forest_6.tscn",
	9: "res://scenes/rooms/forest/forest_5_NEWER.tscn",
}
#must be the inverse of the first!!!
const reverse_dict = {
	"res://scenes/rooms/room_a.tscn": 0,
	"res://scenes/rooms/room_b.tscn": 1,
	"res://scenes/rooms/room_c.tscn": 2,
	
	"res://scenes/rooms/forest/forest_1_NEW.tscn" : 4,
	"res://scenes/rooms/forest/forest_2.tscn" : 5,
	"res://scenes/rooms/forest/forest_3_NEWER.tscn" : 6,
	"res://scenes/rooms/forest/forest_4_NEWER.tscn" : 7,
	"res://scenes/rooms/forest/forest_6.tscn" : 8,
	"res://scenes/rooms/forest/forest_5_NEWER.tscn" : 9,
}

#this is for secondary things - to load in stages if certain rooms are too large
const room_dict_2 = {
}

var loadings = []
var loaded_objects_keys = []
var loaded_objects = []
var extra_loadings = {}

func get_floor():
	#forest
	if active_key > -1 and active_key < 999:
		return 1
	return 0

func _ready() -> void:
	setup_active_room(active_key)

func _process(delta):
	for path in loadings:
		var status = ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var resource = ResourceLoader.load_threaded_get(path)
			var is_extra = extra_loadings.has(path)
			load_resource(resource, path, is_extra)
			extra_loadings.erase(path)
			loadings.erase(path)
	var erase_arr = []
	for i in loaded_objects_keys.size():
		var k = loaded_objects_keys[i]
		var o = loaded_objects[i]
		if is_instance_valid(o):
			if !(k in active_room.adjacent_rooms) and !(k == active_key):
				print("ROOM: ", k, " IS BEING REMOVED!!!")
				o.queue_free()
				erase_arr.append(i)
		else:
			erase_arr.append(i)
	if erase_arr.size() > 0:
		for i in erase_arr:
			if i < loaded_objects_keys.size():
				loaded_objects_keys.remove_at(i)
			if i < loaded_objects.size():
				loaded_objects.remove_at(i)
			print("ERASED OBJECT ", i, " FROM ARRAYS.")
			#var k = loaded_objects_keys[i]
			#var o = loaded_objects[i]

func load_resource(resource: PackedScene, path: String, extra: bool):
	var inst = resource.instantiate()
	if !extra:
		add_child(inst)
		inst.global_position = inst.room_pos
	else:
		#print("EXTRA EXTRA")
		var key = extra_loadings[path]
		for i in loaded_objects_keys.size():
			#print(i, ", ", loaded_objects_keys[i], ", ", key)
			if loaded_objects_keys[i] == key:
				loaded_objects[i].add_child(inst)
				break
	if !extra:
		loaded_objects.append(inst)
		var key = reverse_dict[path]
		loaded_objects_keys.append(key)
		load_room_extra(key)

func load_room(key: int):
	var path = room_dict[key]
	ResourceLoader.load_threaded_request(path, "PackedScene")
	loadings.append(path)
	print("ROOM: ", key, " IS LOADED!")

func load_room_extra(key: int):
	if room_dict_2.has(key):
		var path = room_dict_2[key]
		ResourceLoader.load_threaded_request(path, "PackedScene")
		extra_loadings[path] = key
		loadings.append(path)
		print("EXTRAS FOR: ", key, " IS LOADED!")
		print(extra_loadings)

func setup_active_room(key: int):
	#some stuff will need to go here
	if is_instance_valid(active_room):
		active_room.active = false
	print("ON ROOM: ", key)
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
		load_room_extra(key)
		print("RARE FIRST TIME LOAD HAS OCCURED!")
	
	#its a different room now
	active_room.active = true
	
	for k in active_room.adjacent_rooms:
		if !(k in loaded_objects_keys):
			load_room(k)
		else:
			print("ROOM: ", k, " IS ALREADY LOADED!")
