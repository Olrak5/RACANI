extends Label

var resources = Main.Resources.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func updateResources(_resources):
	resources = _resources
	text = "Resources\nFood: %s\nWood: %s\nMinerals: %s" % [resources.food, resources.wood, resources.minerals]
	
