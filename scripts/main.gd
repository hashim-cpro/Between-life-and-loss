extends Control

# Text to display goes here:
@export var narrative_slides : Array[String] = [
	"You are the only medic… on a distant, forgotten island.",
	"One day, strangers arrive — pale men in red coats.",
	"They take your people… your family… across the sea.",

	"A few days later, they return some boys… but within a week, they are dead.",
	"Soon after, a deadly virus started to spread across the island.",
	"The shadow of death looms over your island.",

	"Now, hope rests on you… and the little you have.",
	"Can you save them?",
	
	"Press Continue to begin."
]

var current_slide_index = 0
@onready var narrative_overlay = $CanvasLayer
@onready var narrative_text_label = $"CanvasLayer/ColorRect/Panel/Main text"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	show_next_slide()
	
func _process(delta):
	if Input.is_action_just_pressed("move to next slide"):
		show_next_slide()
		


func show_next_slide():
	print("=== Slide function called ===")
	print("Current index: ", current_slide_index)
	print("Total slides: ", narrative_slides.size())
	
	if current_slide_index < narrative_slides.size():
		print("Starting fade-out for text...")
		narrative_overlay.visible = true
		get_tree().paused = true
		var fade_tween = create_tween()
		fade_tween.tween_property(narrative_text_label, "modulate:a", 0.0, 0.3)
		fade_tween.tween_callback(update_text_and_fade_in)
		
	else:
		print("End of slides reached - starting game")
		narrative_overlay.visible = false
		get_tree().change_scene_to_file("res://scenes/pharmacy.tscn")
		
		


func update_text_and_fade_in():
	print("Callback: Updating text and starting fade-in.")
	
	if current_slide_index < narrative_slides.size():
		narrative_text_label.text = narrative_slides[current_slide_index]
		
		current_slide_index += 1
		print("New index after increment: ", current_slide_index)
		
		var fade_in_tween = create_tween()
		fade_in_tween.tween_property(narrative_text_label, "modulate:a", 1.0, 0.6)
	else:
		print("Callback reached end of slides logic.")
		show_next_slide() # This will execute the 'else' block in show_next_slide
