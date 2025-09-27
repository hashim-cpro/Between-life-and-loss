extends Control

# Text to display goes here:
@export var narrative_slides : Array[String] = [
	"You are the only medic of a remote island...",
	"Some white men wearing red suits enter your island.",
	"They take some people. Now some of your loved ones are gone in the ocean in a big boat.",
	"Days later, they return some younger boys, but they die in a week.",
	"Next thing you know: everyone is getting sick. A VIRUS!!!",
	"You must save them with what you have. Press continue to begin.",
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
		get_tree().paused = false
		


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
