extends Control

var mushroom_count = 5
var salt_leaf_count = 2  # rare
var clay_count = 3

var fast_cure_count = 0 
var slow_cure_count = 0


var recipes = [
	{
		"id": "fast_cure",
		"display_name": "Fast Cure",
		"requirements": {"mushroom": 2, "salt_leaf": 1, "clay": 1},
		"description": "Immediate relief, short duration."
	},
	{
		"id": "slow_cure",
		"display_name": "Slow Cure",
		"requirements": {"mushroom": 1, "salt_leaf": 2, "clay": 1},
		"description": "Slower onset, longer protection."
	}
]

var pot_mushrooms = 0
var pot_salt_leaves = 0
var pot_clay = 0
var pot_history: Array[String] = []

const HOSPITAL_SCENE_PATH := "res://scenes/hospital.tscn"

@onready var cook_button = $"crafting pot/Button"
@onready var ingredients_container = $"Left Panel/Ingredient Grid"
@onready var result_container = $"HBoxContainer/Right Panel/Medicine Grid"

func _ready():
	if cook_button == null:
		push_error("Pharmacy: cook_button path invalid. Check 'crafting pot/Button'.")
	if ingredients_container == null:
		push_error("Pharmacy: ingredients_container path invalid. Expected node named 'Ingredients'.")
	if result_container == null:
		push_error("Pharmacy: result_container path invalid. Expected node named 'Result'.")

	setup_ui()
	if cook_button:
		cook_button.pressed.connect(_on_cook_button_pressed)

func setup_ui():
	for child in ingredients_container.get_children():
		child.queue_free()
	for child in result_container.get_children():
		child.queue_free()
	
	create_ingredient_ui()
	create_result_ui()

func create_ingredient_ui():

	
	var mushroom_btn = Button.new()
	mushroom_btn.text = "Add Mushroom (" + str(mushroom_count) + ")"
	mushroom_btn.pressed.connect(_on_mushroom_button_pressed)
	ingredients_container.add_child(mushroom_btn)
	
	var salt_btn = Button.new()
	salt_btn.text = "Add Salt Leaf (" + str(salt_leaf_count) + ") - RARE"
	salt_btn.pressed.connect(_on_salt_leaf_button_pressed)
	ingredients_container.add_child(salt_btn)
	
	var clay_btn = Button.new()
	clay_btn.text = "Add Clay (" + str(clay_count) + ")"
	clay_btn.pressed.connect(_on_clay_button_pressed)
	ingredients_container.add_child(clay_btn)
	
	var pot_label = Label.new()
	pot_label.text = "\nIn Pot:"
	ingredients_container.add_child(pot_label)
	
	var pot_contents = Label.new()
	pot_contents.name = "PotContents"
	ingredients_container.add_child(pot_contents)
	update_pot_display()

	var undo_btn = Button.new()
	undo_btn.name = "UndoButton"
	undo_btn.text = "Undo Last"
	undo_btn.disabled = true
	undo_btn.pressed.connect(_on_undo_button_pressed)
	ingredients_container.add_child(undo_btn)

func create_result_ui():
	var title = Label.new()
	title.text = "Medicine Inventory:"
	result_container.add_child(title)

	var go_btn = Button.new()
	go_btn.name = "HospitalNavButton"
	go_btn.text = "Go To Medic Center"
	go_btn.pressed.connect(_on_go_hospital_pressed)
	result_container.add_child(go_btn)

	var recipes_title = Label.new()
	recipes_title.text = "\nRecipes:" 
	result_container.add_child(recipes_title)

	for r in recipes:
		var line = Label.new()
		var req = r.requirements
		var mush_req = req.get("mushroom", 0)
		var leaf_req = req.get("salt_leaf", 0)
		var clay_req = req.get("clay", 0)
		line.text = "%s -> M:%d  L:%d  C:%d" % [r.display_name, mush_req, leaf_req, clay_req]
		result_container.add_child(line)

	var desc_hint = Label.new()
	desc_hint.text = "(Add ingredients, then press Cook. System auto-selects best matching recipe.)"
	result_container.add_child(desc_hint)
	
	var fast_cure = Label.new()
	fast_cure.name = "FastCureLabel"
	fast_cure.text = "Fast Cure: " + str(fast_cure_count)
	result_container.add_child(fast_cure)
	
	var slow_cure = Label.new()
	slow_cure.name = "SlowCureLabel"
	slow_cure.text = "Slow Cure: " + str(slow_cure_count)
	result_container.add_child(slow_cure)

func update_pot_display():
	if ingredients_container == null:
		return
	var pot_contents = ingredients_container.get_node_or_null("PotContents")
	if pot_contents:
		pot_contents.text = "Mushrooms: " + str(pot_mushrooms) + "\nSalt Leaves: " + str(pot_salt_leaves) + "\nClay: " + str(pot_clay)

	if ingredients_container.get_child_count() >= 7:
		var mushroom_btn = ingredients_container.get_child(1)
		if mushroom_btn is Button:
			mushroom_btn.text = "Add Mushroom (" + str(mushroom_count) + ")"
			mushroom_btn.disabled = (mushroom_count <= 0) or pot_exact_matches_any_recipe()
		var salt_btn = ingredients_container.get_child(2)
		if salt_btn is Button:
			salt_btn.text = "Add Salt Leaf (" + str(salt_leaf_count) + ") - RARE"
			salt_btn.disabled = (salt_leaf_count <= 0) or pot_exact_matches_any_recipe()
		var clay_btn = ingredients_container.get_child(3)
		if clay_btn is Button:
			clay_btn.text = "Add Clay (" + str(clay_count) + ")"
			clay_btn.disabled = (clay_count <= 0) or pot_exact_matches_any_recipe()
		var undo_btn = ingredients_container.get_child(6)
		if undo_btn is Button:
			undo_btn.disabled = pot_history.is_empty()

	if cook_button:
		cook_button.disabled = not pot_exact_matches_any_recipe()

func update_medicine_display():
	var fast_label = result_container.get_node("FastCureLabel")
	var slow_label = result_container.get_node("SlowCureLabel")
	fast_label.text = "Fast Cure: " + str(fast_cure_count)
	slow_label.text = "Slow Cure: " + str(slow_cure_count)

func add_to_pot(ingredient_type: String):
	if pot_exact_matches_any_recipe():
		return
	if not can_add_ingredient(ingredient_type):
		print("Cannot add %s – would invalidate all recipes" % ingredient_type)
		return
	match ingredient_type:
		"mushroom":
			if mushroom_count > 0:
				mushroom_count -= 1
				pot_mushrooms += 1
				pot_history.append("mushroom")
		"salt_leaf":
			if salt_leaf_count > 0:
				salt_leaf_count -= 1
				pot_salt_leaves += 1
				pot_history.append("salt_leaf")
		"clay":
			if clay_count > 0:
				clay_count -= 1
				pot_clay += 1
				pot_history.append("clay")
	update_pot_display()

func _on_cook_button_pressed():
	if pot_mushrooms + pot_salt_leaves + pot_clay == 0:
		return

	var chosen_recipe = get_matching_recipe()
	if chosen_recipe == null:
		print("No recipe matched current pot contents.")
		return

	match chosen_recipe.id:
		"fast_cure":
			fast_cure_count += 1
			if Engine.has_singleton("GMS") == false and Engine.has_singleton("gms") == false:
				# attempt via autoload variable (standard pattern) – safe assignment if exists
				if typeof(get_node_or_null("/root/GMS")) != TYPE_NIL:
					get_node("/root/GMS").add_fast_cure(1)
			else:
				GMS.add_fast_cure(1)
			print("Cooked: %s" % chosen_recipe.display_name)
		"slow_cure":
			slow_cure_count += 1
			if typeof(get_node_or_null("/root/GMS")) != TYPE_NIL:
				GMS.add_slow_cure(1)
			print("Cooked: %s" % chosen_recipe.display_name)
		_:
			print("Cooked unknown recipe id: ", chosen_recipe.id)
	
	# Clear pot
	pot_mushrooms = 0
	pot_salt_leaves = 0
	pot_clay = 0
	pot_history.clear()
	
	update_pot_display()
	update_medicine_display()

func _on_mushroom_button_pressed():
	add_to_pot("mushroom")

func _on_salt_leaf_button_pressed():
	add_to_pot("salt_leaf")

func _on_clay_button_pressed():
	add_to_pot("clay")

func _on_undo_button_pressed():
	if pot_history.is_empty():
		return
	var last = pot_history.pop_back()
	match last:
		"mushroom":
			pot_mushrooms -= 1
			mushroom_count += 1
		"salt_leaf":
			pot_salt_leaves -= 1
			salt_leaf_count += 1
		"clay":
			pot_clay -= 1
			clay_count += 1
	update_pot_display()

# ---------------------------------------------
# Recipe selection logic
# ---------------------------------------------
func get_matching_recipe():
	var candidates = []
	for r in recipes:
		var req = r.requirements
		if pot_mushrooms >= req.get("mushroom", 0) \
		and pot_salt_leaves >= req.get("salt_leaf", 0) \
		and pot_clay >= req.get("clay", 0):
			candidates.append(r)

	if candidates.is_empty():
		return null

	candidates.sort_custom(func(a, b):
		var a_req = a.requirements
		var b_req = b.requirements
		var a_total = a_req.get("mushroom",0) + a_req.get("salt_leaf",0) + a_req.get("clay",0)
		var b_total = b_req.get("mushroom",0) + b_req.get("salt_leaf",0) + b_req.get("clay",0)
		if a_total == b_total:
			return a_req.get("salt_leaf",0) > b_req.get("salt_leaf",0)
		return a_total > b_total
	)

	return candidates[0]

func pot_exact_matches_any_recipe() -> bool:
	for r in recipes:
		var req = r.requirements
		if pot_mushrooms == req.get("mushroom",0) \
		and pot_salt_leaves == req.get("salt_leaf",0) \
		and pot_clay == req.get("clay",0):
			return true
	return false

func can_add_ingredient(ing: String) -> bool:
	var m = pot_mushrooms + (1 if ing == "mushroom" else 0)
	var s = pot_salt_leaves + (1 if ing == "salt_leaf" else 0)
	var c = pot_clay + (1 if ing == "clay" else 0)
	for r in recipes:
		var req = r.requirements
		if m <= req.get("mushroom",0) and s <= req.get("salt_leaf",0) and c <= req.get("clay",0):
			return true
	return false

func _on_go_hospital_pressed():
	var scene_res = load(HOSPITAL_SCENE_PATH)
	if scene_res == null:
		push_error("Hospital scene missing: " + HOSPITAL_SCENE_PATH)
		return
	var hospital = scene_res.instantiate()
	if hospital == null:
		push_error("Failed to instantiate hospital scene")
		return
	if hospital.has_method("set_cure_counts"):
		hospital.set_cure_counts(fast_cure_count, slow_cure_count)
	else:
		push_warning("Hospital scene lacks set_cure_counts; counts not transferred")
	var tree = get_tree()
	var current = tree.current_scene
	tree.root.add_child(hospital)
	tree.current_scene = hospital
	if current:
		current.queue_free()
