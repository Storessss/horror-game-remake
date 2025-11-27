extends Node

func get_player(id: int) -> Player:
	var player: Player = get_tree().current_scene.get_node(str(id))
	return player

func get_local_player() -> Player:
	var player: Player = get_tree().current_scene.get_node(
		str(get_tree().get_multiplayer().get_unique_id()))
	return player

#func get_all_other_players(caller_id: int) -> Array[Player]:
	#var players: Array[Player]
	#for player in get_tree().get_nodes_in_group("players"):
		#if player.name.to_int() != caller_id:
			#players.append(player)
	#return players

func line_of_sight(from: Vector2, to: Vector2) -> bool:
	var space_state = get_tree().current_scene.get_world_2d().direct_space_state
	var params = PhysicsRayQueryParameters2D.new()
	params.from = from
	params.to = to
	params.exclude = []
	params.collision_mask = 1
	var result = space_state.intersect_ray(params)
	if result:
		return false
	return true
