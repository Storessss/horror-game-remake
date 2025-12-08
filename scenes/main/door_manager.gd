extends Area2D

@onready var node1: Node2D = $Node2D1
@onready var node2: Node2D = $Node2D2

var door_chance: int = 50
var door_scene: PackedScene = preload("res://scenes/props/door.tscn")

var disabled: bool

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("door_managers"):
		var tilemap: TileMapLayer = get_parent().get_parent().tilemap
		var node1_local_position: Vector2i = tilemap.local_to_map(tilemap.to_local(node1.global_position))
		var node2_local_position: Vector2i = tilemap.local_to_map(tilemap.to_local(node2.global_position))
		tilemap.erase_cell(node1_local_position)
		tilemap.erase_cell(node2_local_position)
		if not disabled:
			area.disabled = true
			if randi_range(1, 100) <= door_chance:
				var door: Door = door_scene.instantiate()
				door.global_position = global_position
				door.global_rotation = global_rotation
				get_tree().current_scene.call_deferred("add_child", door)
				tilemap.set_floor(node1_local_position, Vector2i(1, 1))
				tilemap.set_floor(node2_local_position, Vector2i(1, 1))
			else:
				tilemap.set_floor(node1_local_position)
				tilemap.set_floor(node2_local_position)
		queue_free()
