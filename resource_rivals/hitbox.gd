extends Area3D

class_name Hitbox

var main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#input_event.connect(on_input_event)
	input_ray_pickable = true
	#collision_layer = 1
	main = get_node("/root/Main")
	
#
var location: Vector2i

# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass

#func on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	#if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		#main.selectedCell(location)
#
		#get_viewport().set_input_as_handled()
		
	#if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		#main.selectedCell(location)
		#queue_free()

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	#var root = get_tree().get_root()
	#print(root.get_children()[0].get_children())
	#var main = root.get_children()[0]
	#print(location)
	
	#if (event is not InputEventMouseMotion):
		#print(event)
	
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		main.selectedCell(location)
		#queue_free()
	
