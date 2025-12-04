extends Area2D

@onready var node1: Node2D = $Node2D1
@onready var node2: Node2D = $Node2D2

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("doors"):
		var tilemap: TileMapLayer = get_parent().get_parent().tilemap
		var node1_local_position: Vector2i = tilemap.local_to_map(tilemap.to_local(node1.global_position))
		var node2_local_position: Vector2i = tilemap.local_to_map(tilemap.to_local(node2.global_position))
		tilemap.set_floor(node1_local_position)
		tilemap.set_floor(node2_local_position)
		queue_free()
