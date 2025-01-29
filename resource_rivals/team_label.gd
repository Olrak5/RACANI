extends Label

var unit_info: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func updateTeamName(team_name, max_population):
	text = \
	team_name + "\n" +\
	"Max Population: " + str(max_population)
	
	
	#if unit_info["namespace"] == "units":
	#
		#text = \
		#"Unit Info\n\
		#Team: %s\n\
		#Type: %s\n\
		#Health: %s\n\
		#Armor: %s\n\
		#Damage: %s\n\
		#MovementRange: %s\n\
		#AttackRange: %s"\
		#% [
			#unit_info[get_parent().get_parent().game["teams"][unit_info["teamid"]]],
			#unit_info["type"],
			#unit_info["health"],
			#unit_info["armor"],
			#unit_info["damage"],
			#unit_info["movementRange"],
			#unit_info["attackRange"]
		#]
	#
	#else:
		#text = \
		#"Unit Info\n\
		#Team: %s\n\
		#Type: %s\n\
		#Health: %s\n\
		#Armor: %s\n\
		#Damage: %s\n\
		#MovementRange: %s\n\
		#AttackRange: %s"\
		#% [
			#unit_info[get_parent().get_parent().game["teams"][unit_info["teamid"]]],
			#unit_info["type"],
			#unit_info["health"],
			#unit_info["armor"],
			#unit_info["damage"],
			#unit_info["movementRange"],
			#unit_info["attackRange"]
		#]
