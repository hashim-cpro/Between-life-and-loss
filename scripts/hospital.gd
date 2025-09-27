extends Control

@onready var medicine_inventory = get_node_or_null("MedicineInventory")
@onready var actions_box = get_node_or_null("PatientArea") if get_node_or_null("PatientArea") != null else get_node_or_null("Patient Area")
@onready var stats_box = get_node_or_null("Stats")
@onready var back_button: Button = (
	get_node_or_null("BackButton") if get_node_or_null("BackButton") != null else get_node_or_null("Back Button")
)

func _ready():
	# Validate containers; create minimal fallbacks if scene has different names
	if medicine_inventory == null:
		medicine_inventory = VBoxContainer.new()
		medicine_inventory.name = "MedicineInventory"
		add_child(medicine_inventory)
		var title = Label.new(); title.name = "MedicineTitle"; title.text = "Medicines"; medicine_inventory.add_child(title)
	if actions_box == null:
		actions_box = VBoxContainer.new()
		actions_box.name = "PatientArea"
		add_child(actions_box)
		var pt = Label.new(); pt.name = "PatientTitle"; pt.text = "Actions"; actions_box.add_child(pt)
	if stats_box == null:
		stats_box = VBoxContainer.new(); stats_box.name = "Stats"; add_child(stats_box)
		var st = Label.new(); st.name = "StatsTitle"; st.text = "Stats"; stats_box.add_child(st)

	if back_button and not back_button.is_connected("pressed", _on_BackButton_pressed):
		back_button.pressed.connect(_on_BackButton_pressed)
	elif back_button == null:
		# Auto-create a back button if missing
		back_button = Button.new()
		back_button.text = "Back"
		add_child(back_button)
		back_button.pressed.connect(_on_BackButton_pressed)

	if typeof(GMS) != TYPE_NIL:
		if not GMS.cures_changed.is_connected(_refresh):
			GMS.cures_changed.connect(_refresh)
		if not GMS.infection_changed.is_connected(_refresh):
			GMS.infection_changed.connect(_refresh)
		if not GMS.day_advanced.is_connected(_refresh):
			GMS.day_advanced.connect(_refresh)

	_build_static_ui()
	_refresh()

func _build_static_ui():
	if actions_box == null or medicine_inventory == null or stats_box == null:
		return
	# Clear dynamic areas first
	for child in actions_box.get_children():
		if child is Node and child.name != "PatientTitle":
			child.queue_free()
	for child in medicine_inventory.get_children():
		if child is Node and child.name != "MedicineTitle":
			child.queue_free()
	for child in stats_box.get_children():
		if child is Node and child.name != "StatsTitle":
			child.queue_free()

	# Cure action buttons
	var v_fast = _mk_action_button("Cure Villager (Fast)", func(): _attempt_treat("villager","fast"))
	var v_slow = _mk_action_button("Cure Villager (Slow)", func(): _attempt_treat("villager","slow"))
	var f_fast = _mk_action_button("Cure Family (Fast)", func(): _attempt_treat("family","fast"))
	var f_slow = _mk_action_button("Cure Family (Slow)", func(): _attempt_treat("family","slow"))
	var spread_btn = _mk_action_button("Use Salt Leaf to Suppress Spread", _attempt_spread_block)
	var next_day_btn = _mk_action_button("Advance Day", _advance_day)
	
	actions_box.add_child(v_fast)
	actions_box.add_child(v_slow)
	actions_box.add_child(f_fast)
	actions_box.add_child(f_slow)
	actions_box.add_child(spread_btn)
	actions_box.add_child(next_day_btn)

func _mk_action_button(text:String, callable_action:Callable) -> Button:
	var b = Button.new()
	b.text = text
	b.pressed.connect(callable_action)
	return b

func _refresh():
	if typeof(GMS) == TYPE_NIL:
		return
	if medicine_inventory == null or stats_box == null or actions_box == null:
		return
	# Medicines display
	for child in medicine_inventory.get_children():
		if child is Node and child.name != "MedicineTitle":
			child.queue_free()
	var fast_label = Label.new(); fast_label.text = "Fast Cures: %d" % GMS.fast_cures; medicine_inventory.add_child(fast_label)
	var slow_label = Label.new(); slow_label.text = "Slow Cures: %d" % GMS.slow_cures; medicine_inventory.add_child(slow_label)

	# Infection / population stats
	for child in stats_box.get_children():
		if child is Node and child.name != "StatsTitle":
			child.queue_free()
	var inf_v = Label.new(); inf_v.text = "Infected Villagers: %d" % GMS.infected_villagers; stats_box.add_child(inf_v)
	var inf_f = Label.new(); inf_f.text = "Infected Family: %d" % GMS.infected_family; stats_box.add_child(inf_f)
	var day_l = Label.new(); day_l.text = "Day: %d" % GMS.day; stats_box.add_child(day_l)
	var spread_l = Label.new(); spread_l.text = "Spread Pressure: %.2f" % GMS.spread_pressure; stats_box.add_child(spread_l)
	var resources = Label.new(); resources.text = "Salt Leaves: %d  Mushrooms: %d  Clay: %d" % [GMS.salt_leaves, GMS.mushrooms, GMS.clay]; stats_box.add_child(resources)

	# Enable/disable cure buttons based on availability
	for btn in actions_box.get_children():
		if btn is Button:
			match btn.text:
				"Cure Villager (Fast)": btn.disabled = (GMS.fast_cures <= 0 or GMS.infected_villagers <= 0)
				"Cure Villager (Slow)": btn.disabled = (GMS.slow_cures <= 0 or GMS.infected_villagers <= 0)
				"Cure Family (Fast)": btn.disabled = (GMS.fast_cures <= 0 or GMS.infected_family <= 0)
				"Cure Family (Slow)": btn.disabled = (GMS.slow_cures <= 0 or GMS.infected_family <= 0)
				"Use Salt Leaf to Suppress Spread": btn.disabled = (GMS.salt_leaves <= 0)
				_: pass

func _attempt_treat(group:String, cure_type:String):
	var ok = GMS.treat(group, cure_type)
	if not ok:
		print("Treatment failed: insufficient cures or no infected.")
	_refresh()

func _attempt_spread_block():
	var success = GMS.apply_spread_block()
	if not success:
		print("No salt leaves available for spread block.")
	_refresh()

func _advance_day():
	GMS.next_day()
	_refresh()

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/pharmacy.tscn")

func set_cure_counts(fast:int, slow:int):
	# Deprecated – now using global GMS state; kept for compatibility if pharmacy still calls it.
	GMS.fast_cures = fast
	GMS.slow_cures = slow
	_refresh()
