extends CharacterBody2D

@onready var nav: NavigationAgent2D = $NavigationAgent2D
var direction: Vector2

func _process(_delta: float) -> void:
	var p = Vector2.ZERO
	if GlobalVariables.get_local_player():
		p = GlobalVariables.get_local_player().global_position
	nav.target_position = p
	var next_position = nav.get_next_path_position()
	direction = (next_position - global_position).normalized()
	velocity = direction * 100
	move_and_slide()
