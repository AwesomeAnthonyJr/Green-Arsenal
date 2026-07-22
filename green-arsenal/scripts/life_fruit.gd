extends Plant

@onready var fruits = [$FancyModel/Skeleton3D/Fruit1, $FancyModel/Skeleton3D/Fruit2, $FancyModel/Skeleton3D/Fruit3, $FancyModel/Skeleton3D/Fruit4]

@onready var fruit_1 = $FancyModel/Skeleton3D/Fruit1
@onready var fruit_2 = $FancyModel/Skeleton3D/Fruit2
@onready var fruit_3 = $FancyModel/Skeleton3D/Fruit3
@onready var fruit_4 = $FancyModel/Skeleton3D/Fruit4

@onready var area_1 = $InteractArea1
@onready var area_2 = $InteractArea2
@onready var area_3 = $InteractArea3
@onready var area_4 = $InteractArea4

@onready var anim = $AnimationPlayer
var fruit_count = 1
@onready var skeleton = $FancyModel/Skeleton3D
const leaf_bone_names = ["Bone.006", "Bone.015", "Bone.028", "Bone.020", "Bone.011", "Bone.038", "Bone.042", "Bone.048", "Bone.052", "Bone.058", "Bone.054", "Bone.070"]
var leaf_bones = []
var leaf_rest_positions = []
var leaf_rot_goals = []
var leaf_percentage = 0.0
var perc_mult = 0.1
var leaf_ready = false

func _process(delta: float) -> void:
	#this is like a leaves subtly moving animation
	if leaf_ready:
		leaf_percentage += delta * perc_mult
		if leaf_percentage >= 1.0:
			perc_mult = -0.1
		elif leaf_percentage < 0:
			gen_leaf_rot_goals()
			leaf_percentage = 0.0
			perc_mult = 0.1
		for i in leaf_bones.size():
			var new = leaf_rest_positions[i].rotated(Vector3.FORWARD, lerpf(0.0, leaf_rot_goals[i], leaf_percentage))
			skeleton.set_bone_pose(leaf_bones[i], new) 

func gen_leaf_rot_goals():
	leaf_rot_goals.clear()
	for i in leaf_bones.size():
		leaf_rot_goals.append(0.1 * randf_range(-PI, PI))

func grow():
	fruit_1.hide()
	fruit_2.hide()
	fruit_3.hide()
	fruit_4.hide()
	fruit_count = 1
	
	anim.play("grow")
	fruits.shuffle()
	for i in 3:
		if randf_range(0.0, 1.0) > 0.5:
			fruit_count += 1
	for i in fruit_count:
		fruits[i].show()
	
	area_1.on = fruit_1.visible
	area_2.on = fruit_2.visible
	area_3.on = fruit_3.visible
	area_4.on = fruit_4.visible
	
	for l in leaf_bone_names:
		var i = skeleton.find_bone(l)
		leaf_bones.append(i)
		leaf_rest_positions.append(skeleton.get_bone_rest(i))
	gen_leaf_rot_goals()
	leaf_ready = true

func interact_fruit_1(obj):
	if obj is Player:
		obj.heal_1()
		fruit_count -= 1
		fruit_1.hide()

func interact_fruit_2(obj):
	if obj is Player:
		obj.heal_1()
		fruit_count -= 1
		fruit_2.hide()

func interact_fruit_3(obj):
	if obj is Player:
		obj.heal_1()
		fruit_count -= 1
		fruit_3.hide()

func interact_fruit_4(obj):
	if obj is Player:
		obj.heal_1()
		fruit_count -= 1
		fruit_4.hide()
