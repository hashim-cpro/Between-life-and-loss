extends Node

# Global game state (autoload this as GMS in project settings if not already)
# Core resources
var mushrooms:int = 5
var salt_leaves:int = 2
var clay:int = 3

# Crafted cures
var fast_cures:int = 0
var slow_cures:int = 0

# Population / infection model
var total_villagers:int = 25
var family_members:int = 5
var infected_villagers:int = 6
var infected_family:int = 1

# Spread pressure (abstract value that can grow each day)
var spread_pressure:float = 1.0

# Rare action usage (using salt leaf to suppress spread)
var last_spread_block_day:int = -1

# Time / day tracking
var day:int = 1

signal cures_changed
signal infection_changed
signal day_advanced

func add_fast_cure(amount:int=1):
	fast_cures += amount
	emit_signal("cures_changed")

func add_slow_cure(amount:int=1):
	slow_cures += amount
	emit_signal("cures_changed")

func consume_cure(fast:int, slow:int):
	fast_cures = max(0, fast_cures - fast)
	slow_cures = max(0, slow_cures - slow)
	emit_signal("cures_changed")

func treat(infect_type:String, cure_type:String):
	# infect_type: "villager" | "family"
	# cure_type: "fast" | "slow"
	if cure_type == "fast" and fast_cures <= 0: return false
	if cure_type == "slow" and slow_cures <= 0: return false
	match infect_type:
		"villager":
			if infected_villagers <= 0: return false
			infected_villagers -= 1
		"family":
			if infected_family <= 0: return false
			infected_family -= 1
	if cure_type == "fast": fast_cures -= 1
	if cure_type == "slow": slow_cures -= 1
	emit_signal("infection_changed")
	emit_signal("cures_changed")
	return true

func apply_spread_block():
	# Consumes one salt leaf (if available) to reduce spread pressure this day
	if salt_leaves <= 0: return false
	salt_leaves -= 1
	spread_pressure = max(0.2, spread_pressure * 0.5)
	return true

func next_day():
	day += 1
	# Simple growth: new infections based on pressure
	var new_inf = int(round(spread_pressure * 2))
	var free_population = (total_villagers - infected_villagers) + (family_members - infected_family)
	new_inf = min(new_inf, free_population)
	# Prioritize villagers then family
	var villager_room = total_villagers - infected_villagers
	var add_villagers = min(villager_room, new_inf)
	infected_villagers += add_villagers
	var remaining = new_inf - add_villagers
	infected_family += remaining
	# Increase spread pressure gradually
	spread_pressure += 0.3
	emit_signal("infection_changed")
	emit_signal("day_advanced")

func debug_state():
	print("Day", day, " | Fast:", fast_cures, " Slow:", slow_cures, " Infected V/F:", infected_villagers, "/", infected_family, " Spread:", spread_pressure)
