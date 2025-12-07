extends Node

var room_count: int = 100
var rooms: Array[PackedScene] = [
	preload("res://scenes/rooms/base_room.tscn"),
	preload("res://scenes/rooms/corridoor_room.tscn"),
]
var room_rects: Array[Rect2]
var move_points: Array[Node2D]

func get_player(id: int) -> Player:
	var player: Player = get_tree().current_scene.get_node(str(id))
	return player

func get_local_player() -> Player:
	var player: Player = get_tree().current_scene.get_node(
		str(get_tree().get_multiplayer().get_unique_id()))
	return player
	
func is_host() -> bool:
	if multiplayer.get_unique_id() == 1:
		return true
	return false

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
	
signal generate_room(previous_room_position: Vector2, previous_room_size: Vector2, previous_direction: Vector2)
func _ready() -> void:
	generate_room.connect(Callable(self, "_on_generate_room"))

func _on_generate_room(previous_room_position: Vector2, previous_room_size: Vector2, previous_direction: Vector2):
	room_count -= 1
	if room_count > 0:
		var direction_check_passed: bool
		var room: Room
		while not direction_check_passed:
			room = rooms.pick_random().instantiate()
			for exit_direction in room.exit_directions:
				var new_room_direction: Vector2 = convert_direction_format(exit_direction)
				if previous_direction == -new_room_direction:
					direction_check_passed = true
		room.previous_direction = previous_direction
		room.global_position = previous_room_position + previous_room_size * previous_direction
		get_tree().current_scene.add_child(room)
		
enum Directions {
	LEFT,
	RIGHT,
	UP,
	DOWN,
}

func convert_direction_format(direction: int) -> Vector2:
	if direction == Directions.LEFT:
		return Vector2.LEFT
	elif direction == Directions.RIGHT:
		return Vector2.RIGHT
	elif direction == Directions.UP:
		return Vector2.UP
	elif direction == Directions.DOWN:
		return Vector2.DOWN
	return Vector2.ZERO
