extends Node2D

class_name Room

@export var room_size: float
enum Directions {
	LEFT,
	RIGHT,
	UP,
	DOWN,
}
@export var room_exit_directions: Array[Directions]
var previous_direction: Vector2
var allowed_directions: Array[Vector2]
var rooms: Array[PackedScene] = [
	preload("res://scenes/rooms/base_room.tscn"),
]

func _ready() -> void:
	for exit_direction in room_exit_directions:
		if exit_direction == Directions.LEFT:
			allowed_directions.append(Vector2.LEFT)
		elif exit_direction == Directions.RIGHT:
			allowed_directions.append(Vector2.RIGHT)
		elif exit_direction == Directions.UP:
			allowed_directions.append(Vector2.UP)
		elif exit_direction == Directions.DOWN:
			allowed_directions.append(Vector2.DOWN)
	allowed_directions.erase(-previous_direction)
	generate_confining_rooms()

func generate_confining_rooms() -> void:
	if GlobalVariables.room_count > 0:
		for i in range(randi_range(1, 3)):
			var room: Room = rooms.pick_random().instantiate()
			var direction: Vector2 = allowed_directions.pick_random()
			room.global_position = global_position + (room_size + room.room_size) * direction
			allowed_directions.erase(direction)
			room.previous_direction = direction
			get_tree().current_scene.call_deferred("add_child", room)
			GlobalVariables.room_count -= 1
