extends Node

func line_of_sight(from: Vector2, to: Vector2) -> bool:
	var space_state = get_tree().get_world_2d().direct_space_state
	var params = PhysicsRayQueryParameters2D.new()
	params.from = from
	params.to = to
	params.exclude = []
	params.collision_mask = 1
	var result = space_state.intersect_ray(params)
	if result:
		return false
	return true
