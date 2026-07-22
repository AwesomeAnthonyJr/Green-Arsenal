extends CanvasLayer

@onready var anim_tree = $AnimationTree
@onready var selector = $Selector

func match_map_frame(n: int):
	$Control/MapDisplay.frame = n

func match_map_buttons(n: int):
	var buttons = [$Control/MenuButton1, $Control/MenuButton2, $Control/MenuButton3, $Control/MenuButton4, $Control/MenuButton5, $Control/MenuButton6, $Control/MenuButton7, $Control/MenuButton8, $Control/MenuButton9]
	for i in buttons.size():
		if i == n:
			buttons[i].show()
			buttons[i].frame = 1
		elif i < SaveManager.player_save.farthest_floor:
			buttons[i].show()
			buttons[i].frame = 0
		else:
			buttons[i].hide()

func hide_controls_text(n: String):
	match n:
		"move_forward":
			$Control/TextureRect/ControlsText3/Control/RichTextLabel.text = ""
		"move_back":
			$Control/TextureRect/ControlsText4/Control/RichTextLabel.text = ""
		"move_left":
			$Control/TextureRect/ControlsText1/Control/RichTextLabel.text = ""
		"move_right":
			$Control/TextureRect/ControlsText2/Control/RichTextLabel.text = ""
		"sprint":
			$Control/TextureRect/ControlsText5/Control/RichTextLabel.text = ""
		"jump":
			$Control/TextureRect/ControlsText6/Control/RichTextLabel.text = ""
		"pause":
			$Control/TextureRect/ControlsText7/Control/RichTextLabel.text = ""
		"shoot":
			$Control/TextureRect/ControlsText8/Control/RichTextLabel.text = ""
		"reload":
			$Control/TextureRect/ControlsText9/Control/RichTextLabel.text = ""
		"interact":
			$Control/TextureRect/ControlsText10/Control/RichTextLabel.text = ""
		"close_reload":
			$Control/TextureRect/ControlsText11/Control/RichTextLabel.text = ""

func update_status_health():
	$Control/Control2/CurrentMaxText.text = "[right]" + str(SaveManager.player_save.max_hp) + "[/right]"
	$Control/Control2/MaxMaxText.text = "[left]" + str(Constants.max_possible_health) + "[/left]"

func not_on_seed_anymore():
	var display = $Control/Control/PlantDisplayer/SubViewport/Plants
	display.hide_all()

func update_status_plants(b: bool, n: int):
	var display = $Control/Control/PlantDisplayer/SubViewport/Plants
	display.hide_all()
	if b:
		display.show_plant(n-2)

func handle_status_description(b: bool, n: int):
	n = Constants.seed_order[n]
	var describer = $Control/Control/PlantDescriber
	if b:
		describer.show()
		$Control/Control/PlantDisplayer.modulate = Color(0.5, 0.5, 0.5)
		match n:
			2:
				describer.display("[font_size=30][b]Blaze Flower[/b][/font_size]\n\nA fiery relative of the [i]dictamnus albus[/i], otherwise known as the gas plant. Similarly, the Blaze Flower has petals coated in a flammable oil, which ignites any seeds moving through it into a fireball, which can light torches, or deal extra damage as a projectile.")
			3:
				describer.display("[font_size=30][b]Spring Vine[/b][/font_size]\n\nA flower with a particularly flexible stem, the Spring Vine supports it's weight by compressing it's coiled vine like a spring, launching anything that weighs down it's flower. Use it to bounce high into the air, or as a seed to knock enemies back safely.")
			4:
				describer.display("[font_size=30][b]Life Fruit[/b][/font_size]\n\nAn exceptionally nutritious fruit, if allowed to fully ripen it can even increase your max health, however you can only grow a weaker version which heals you. Watch out, it's seeds have a healing power too and will heal anything they shoot.")
			5:
				describer.display("[font_size=30][b]Platform Pad[/b][/font_size]\n\nA giant lily pad, similar to the [i]victoria amazonica[/i], the Platform Pad is strong enough to support the full weight of a person, lending to it's name and use as platform. It always grows upwards, and will float on the surface of water as well. If it was to hit an enemy however it would grow around them as a protective shield.")
			6:
				describer.display("[font_size=30][b]Seeking Stalk[/b][/font_size]\n\nThe Seeking Stalk is a curious plant, with a flower that appears to resemble a human eye. They are exceptionally reactive to stimuli and will redirect any projectile that hits them, allowing you to shoot seeds from an alternate perspective.")
			7:
				describer.display("[font_size=30][b]Propeller Flower[/b][/font_size]\n\nPropeller Flowers are uniquely shaped to spin like a turbine, allowing them to generate lift and raise certain platforms. Although their seeds resemble maple seeds, the flowering plant does not seem to have any relation to the trees.")
			8:
				describer.display("[font_size=30][b]Boulder Fruit[/b][/font_size]\n\nA very heavy and dense squash, the Boulder Fruit grows off of a vine, and can be used to weigh down scales, loose platforms, and anything else that needs extra weight. The fruit can be detatched from it's vine with a little force, allowing the Boulder Fruit to freely roll around.")
	else:
		describer.hide()
		describer.text = ""
		$Control/Control/PlantDisplayer.modulate = Color(1.0, 1.0, 1.0)

func update_status_plant_lighting(n: int):
	$Control/Control/PlantDisplayer/SubViewport/DirectionalLight3D.visible = SaveManager.get_seed_types()[n]

func update_status_seeds():
	for i in Constants.seed_order.size():
		update_status_seed(SaveManager.get_seed_types()[i], Constants.seed_order[i])
	match SaveManager.player_save.growth_charges:
		1:
			$Control/GrowthCharge1.show()
			$Control/GrowthCharge2.hide()
			$Control/GrowthCharge3.hide()
		2:
			$Control/GrowthCharge1.show()
			$Control/GrowthCharge2.show()
			$Control/GrowthCharge3.hide()
		3:
			$Control/GrowthCharge1.show()
			$Control/GrowthCharge2.show()
			$Control/GrowthCharge3.show()

func update_status_seed(b: bool, n: int):
	var seed: Sprite2D = null
	match n:
		2:
			seed = $Control/SeedBlaze
		3:
			seed = $Control/SeedBounce
		4:
			seed = $Control/SeedLife
		5:
			seed = $Control/SeedPlatform
		6:
			seed = $Control/SeedSeeker
		7:
			seed = $Control/SeedPropeller
		8:
			seed = $Control/SeedWeight
	if b:
		seed.modulate = Color(1.0, 1.0, 1.0, 1.0)
		seed.z_index = 1
	else:
		seed.modulate = Color(0.0, 0.0, 0.0, 1.0)
		seed.z_index = 0
