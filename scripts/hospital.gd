extends Control

# Will receive counts from GameManager (GMS) or directly on scene change
var fast_cure_count: int = 0
var slow_cure_count: int = 0

@onready var medicine_inventory = $MedicineInventory
@onready var stats_box = $Stats

func _ready():
	populate_medicines()

func populate_medicines():
	# Clear previous dynamic labels except the title
	for child in medicine_inventory.get_children():
		if child.name != "MedicineTitle":
			child.queue_free()
	
	var fast_label = Label.new()
	fast_label.text = "Fast Cure: %d" % fast_cure_count
	medicine_inventory.add_child(fast_label)
	
	var slow_label = Label.new()
	slow_label.text = "Slow Cure: %d" % slow_cure_count
	medicine_inventory.add_child(slow_label)

func set_cure_counts(fast:int, slow:int):
	fast_cure_count = fast
	slow_cure_count = slow
	if is_node_ready():
		populate_medicines()

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/pharmacy.tscn")
