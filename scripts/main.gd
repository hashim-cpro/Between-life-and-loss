# Main.gd
extends Control

@export var narrative_slides : Array[String] = [
	"You are the only medic of a remote island...",
	"Some white men wearing red suits enter your island.",
	"They take some people. Now some of your loved ones are gone in the ocean in a big boat.",
	"Days later, they return some younger boys, but they die in a week.",
	"Next thing you know: everyone is getting sick. A VIRUS!!!",
	"You must save them with what you have. Press continue to begin."
]
var current_slide_index = 0
@onready var narrative_overlay = $CanvasLayer
@onready var narrative_text_label = $"CanvasLayer/ColorRect/Panel/Main text"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _process(delta):
	if Input.is_action_just_pressed("space bar"):
		show_next_slide()
			
		
func show_next_slide():
	print("=== Slide function called ===")
	print("Current index: ", current_slide_index)
	print("Total slides: ", narrative_slides.size())
	print("Index < size? ", current_slide_index < narrative_slides.size())
	if current_slide_index < narrative_slides.size():
		print("Showing slide: ", narrative_slides[current_slide_index])
		narrative_text_label.text = narrative_slides[current_slide_index]
		narrative_overlay.visible = true
		get_tree().paused = true
		current_slide_index += 1
		print("New index after increment: ", current_slide_index)
	else:
		print("End of slides reached - starting game")
		narrative_overlay.visible = false
		#get_tree().paused = false
		# Note: GMS.start_game() might not exist yet
