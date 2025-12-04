extends TileMapLayer

func set_floor(cell_position: Vector2i):
	set_cell(cell_position, 1, Vector2i(0, 1))
