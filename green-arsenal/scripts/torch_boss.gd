extends Node3D

var torches = []
var initialized = false
var done = false
signal puzzle_done

func _ready() -> void:
	for c in get_children():
		if c is Torch:
			torches.append(c)
	initialized = true

func check_torches():
	for t in torches:
		if !t.lit:
			return false
	return true

func _process(delta: float) -> void:
	if !done and check_torches():
		done = true
		puzzle_done.emit()
		#print("TORCHES ARE READY!!!")
