## GameManager.gd (GMS)
#extends Node
#
## --- Resources ---
#var mushrooms : int = 5
#var leaves : int = 0
#var clay : int = 10 
#var fast_cure : int = 0
#var slow_cure : int = 0
#
## --- Doctor Energy ---
#var doctor_energy : float = 100.0
#var max_doctor_energy : float = 100.0
#
## --- Time and Infection ---
#var doomsday_time : float = 360.0 # 6 minutes (360 seconds)
#var infection_rate_multiplier : float = 1.0 # Increases when Loved One dies
#
## --- Patients (Placeholder) ---
## Use a Dictionary for easy tracking { "id": Patient_Data }
#var patients : Dictionary = {
	#"loved_one_A": {"name": "Elara", "is_loved": true, "infection": 10.0, "is_immune": false},
	#"villager_B": {"name": "Kael", "is_loved": false, "infection": 5.0, "is_immune": false},
	#"villager_C": {"name": "Mara", "is_loved": false, "infection": 15.0, "is_immune": false},
#}
#
## Called once the intro ends
#func start_game():
	#print("Game Started! Doomsday clock ticking...")
	## Start the main game loop timer (using _process for simplicity)
#
## Main game loop for time and infection update
#func _process(delta):
	#if not get_tree().paused:
		## 1. Update Doomsday Clock
		#doomsday_time = max(0.0, doomsday_time - delta)
		#if doomsday_time <= 0:
			#end_game("LOSS: The time ran out.")
		#
		## 2. Update Patient Infections
		#for id in patients:
			#var patient = patients[id]
			#if patient.infection > 0.0 and not patient.is_immune:
				#var rate = 1.0 # Base rate
				#if patient.is_loved: rate = 1.5 # Loved ones get sicker faster (more stress)
				#
				## Sickness increases faster when overall rate is high
				#patient.infection += delta * rate * infection_rate_multiplier
				#patient.infection = min(100.0, patient.infection)
				#
				#if patient.infection >= 100.0:
					#handle_patient_death(id)
		#
		## 3. Update UI (This will be a function in Main.gd, called here)
		#Main.update_ui()
#
#
## --- Action Functions (Called by UI buttons) ---
#
#func handle_rest():
	#if doctor_energy < max_doctor_energy:
		## Time cost: 60 seconds (time speeds up)
		#doomsday_time = max(0.0, doomsday_time - 60.0) 
		#doctor_energy = max_doctor_energy
		## Narrative feedback could pop up: "You took a moment to grieve/rest."
		#
#func handle_harvest(type: String):
	#var energy_cost = 0.0
	#var time_cost = 0.0
	#
	#if type == "mushroom":
		#energy_cost = 5.0
		#time_cost = 10.0
		#if doctor_energy >= energy_cost:
			#mushrooms += 5
			#doctor_energy -= energy_cost
			#doomsday_time -= time_cost
		#
	#elif type == "leaf":
		#energy_cost = 25.0 # Rare, high effort cost
		#time_cost = 45.0
		#if doctor_energy >= energy_cost:
			#leaves += 2
			#doctor_energy -= energy_cost
			#doomsday_time -= time_cost
