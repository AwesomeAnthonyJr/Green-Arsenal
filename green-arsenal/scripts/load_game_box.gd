extends TextureRect

@onready var loc_text = $RichTextLabel2
@onready var hearts = [$Hearts/Heart1, $Hearts/Heart2, $Hearts/Heart3, $Hearts/Heart4, $Hearts/Heart5, $Hearts/Heart6, $Hearts/Heart7, $Hearts/Heart8, $Hearts/Heart9]
@onready var growth_charges = [$GrowthCharges/Charge1, $GrowthCharges/Charge2, $GrowthCharges/Charge3]
@onready var seeds = [$Seeds/Seed2, $Seeds/Seed4, $Seeds/Seed3, $Seeds/Seed6, $Seeds/Seed5, $Seeds/Seed7, $Seeds/Seed8]

const location_dict = {
	-1: "testing",
	0: "forest entrance",
	1: "forest entrance",
	2: "blaze seed storage",
	3: "life seed shrine",
	4: "underground facility",
	5: "upgrade room",
	6: "platform seed storage"
}

func _ready() -> void:
	update_sprites()

func update_sprites():
	var file = SaveManager.player_save
	for i in hearts.size():
		hearts[i].visible = i < file.max_hp
	for i in growth_charges.size():
		growth_charges[i].visible = i < file.growth_charges
	for i in seeds.size():
		seeds[i].visible = file.seed_types[i]
	
	loc_text.text = "[right]" + location_dict[file.load_point] + "[/right]"
