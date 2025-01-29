extends Label

var unit_info = Main.Entity.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func updateUnitInfo(_unit_info):
	unit_info = _unit_info
	
	if unit_info == null:
		text = ""
		return
	
	#text = str(unit_info)
	#print(unit_info)
	
	if unit_info["namespace"] == "units":
	
		text = \
		"Unit Info\n\
		Team: %s\n\
		Type: %s\n\
		Health: %s\n\
		Armor: %s\n\
		Damage: %s\n\
		MovementRange: %s\n\
		AttackRange: %s"\
		% [
			get_parent().get_parent().game["teams"][unit_info["teamId"]].name,
			unit_info["type"],
			unit_info["health"],
			unit_info["armor"],
			unit_info["damage"],
			unit_info["movementRange"],
			unit_info["attackRange"]
		]
	
	elif unit_info["teamId"] != "neutral":
		#printerr(unit_info)
		text = \
		"Unit Info\n\
		Team: %s\n\
		Type: %s"\
		% [
			get_parent().get_parent().game["teams"][unit_info["teamId"]].name,
			unit_info["type"]
		]
	else:
		text = \
		"Unit Info\n\
		Team: %s\n\
		Type: %s"\
		% [
			unit_info["teamId"],
			unit_info["type"]
		]
