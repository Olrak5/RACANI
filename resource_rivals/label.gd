extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	#func restart():
	var main = preload("res://main.tscn").instantiate()
	get_tree().root.add_child(main)
	print(get_tree().root.get_children())
	get_tree().root.remove_child(get_parent())
#function body.
