extends Plant

var direction: Vector3
var platform: PropellablePlatform

func wither_self():
	#print("WITHERING AWAY!")
	if platform != null:
		direction = Vector3.ZERO
		platform.check_propellers()
	destroy_self()
