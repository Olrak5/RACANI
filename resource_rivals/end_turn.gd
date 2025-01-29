extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "End Turn"
	var main = get_node("/root/Main")
	self.pressed.connect(main.newTurnPressed)


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass
