extends Area2D
signal touching

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_collision_shape_2d_child_entered_tree(node: Node) -> void:
	touching.emit()
