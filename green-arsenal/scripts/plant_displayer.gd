extends Node3D

@onready var plants = [$BlazeFlower, $SpringVine, $LifeFruit, $PlatformPad, $SeekerFlower, $PropellerFlower, $BoulderFruit]

func hide_all():
	for p in plants:
		p.hide()

func show_plant(i: int):
	plants[i].show()
	plants[i].grow()
