extends TileMapLayer

func set_floor(cell_position: Vector2i, tile: Vector2i = Vector2i(0, 1)):
	set_cell(cell_position, 1, tile)
