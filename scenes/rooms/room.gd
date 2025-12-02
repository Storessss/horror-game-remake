extends Node2D

class_name Room

@onready var tilemap: TileMapLayer = $Tilemap
@onready var room_size: Vector2 = tilemap.get_used_rect().size
@export var exit_directions: Array[GlobalVariables.Directions]
var exit_positions: Array[Vector2]
var previous_room_size: Vector2
var previous_direction: Vector2
var allowed_directions: Array[Vector2]
var room_position: Vector2

func _ready() -> void:
	GlobalVariables.generated_rooms.append(self)
	global_position += ((previous_room_size * 16 / 2.0) + (room_size * 16 / 2.0)) * previous_direction
	global_position -= Vector2(16, 16) * previous_direction
	var this_rect: Rect2 = tilemap.get_used_rect()
	this_rect.position = tilemap.to_global(this_rect.position)
	room_position = this_rect.position
	for rect in GlobalVariables.room_rects:
		if this_rect.intersects(rect):
			queue_free()
	GlobalVariables.room_rects.append(this_rect)
	setup_exits(room_position, room_size)
	generate_confining_rooms()
func generate_confining_rooms() -> void:
	for i in range(randi_range(1, allowed_directions.size())):
		var direction: Vector2 = allowed_directions.pick_random()
		allowed_directions.erase(direction)
		GlobalVariables.generate_room.emit(global_position, room_size, direction)

func setup_exits(room_position: Vector2, room_size: Vector2) -> void:
	for exit_direction in exit_directions:
		var direction: Vector2 = GlobalVariables.convert_direction_format(exit_direction)
		allowed_directions.append(direction)
		var exit_position: Vector2 = (room_position + room_size / 2) + (room_size / 2) * direction
		exit_positions.append(exit_position)
		var local_position: Vector2i = tilemap.to_local(exit_position)
		var perpendicular: Vector2i = Vector2i(-direction.y, direction.x)
		tilemap.erase_cell(local_position)
		if direction.x != 0:
			tilemap.erase_cell(local_position + perpendicular)
		else:
			tilemap.erase_cell(local_position - perpendicular)
	allowed_directions.erase(-previous_direction)
