extends Node2D

class_name Room

@onready var tilemap: TileMapLayer = $Tilemap
@onready var move_points: Node2D = $MovePoints
@onready var room_size: Vector2 = tilemap.get_used_rect().size * 16 - Vector2i(16, 16)
@export var exit_directions: Array[GlobalVariables.Directions]
var previous_direction: Vector2
var allowed_directions: Array[Vector2]

func _ready() -> void:
	var this_rect: Rect2 = tilemap.get_used_rect()
	this_rect.position = tilemap.to_global(this_rect.position)
	for rect: Rect2 in GlobalVariables.room_rects:
		if this_rect.intersects(rect):
			queue_free()
	GlobalVariables.room_rects.append(this_rect)
	setup_directions()
	generate_confining_rooms()
	for move_point: Node2D in move_points.get_children():
		GlobalVariables.move_points.append(move_point)
func generate_confining_rooms() -> void:
	for i in range(allowed_directions.size()):
		var direction: Vector2 = allowed_directions.pick_random()
		allowed_directions.erase(direction)
		if direction == Vector2.RIGHT:
			GlobalVariables.generate_room.emit(global_position, room_size, direction)
		else:
			GlobalVariables.generate_room.emit(global_position, room_size, direction)

func setup_directions() -> void:
	for exit_direction in exit_directions:
		var direction: Vector2 = GlobalVariables.convert_direction_format(exit_direction)
		allowed_directions.append(direction)
	allowed_directions.erase(-previous_direction)
	
func _exit_tree() -> void:
	for move_point: Node2D in move_points.get_children():
		GlobalVariables.move_points.erase(move_point)
