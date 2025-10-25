function Overworld() constructor {
	
	world_data = [[]];
	
	// Create a basic odd-q offset hex grid
	// Loop through each row
	for (var _row = 0; _row < WORLD_HEIGHT; _row++) {
		for (var _col = 0; _col < WORLD_WIDTH; _col++) {

	        // Pixel position for this tile (flat-topped offset coords)
	        var _x_pos = _col * (COL_SPACING);
	        var _y_pos = _row * HEX_HEIGHT + (_col mod 2) * (HALF_HEX_HEIGHT);

	        // Cube coordinates
	        var _cube_x = _col;
	        var _cube_y = _row - (_col - (_col & 1)) / 2;
	        var _cube_z = -_cube_x - _cube_y;

	        // Cell_data as array
	        var _cell_data = array_create(CellData.Last, undefined);
	        _cell_data[CellData.X]   = _x_pos;
	        _cell_data[CellData.Y]   = _y_pos;
	        _cell_data[CellData.Row]   = _row;
	        _cell_data[CellData.Col]   = _col;
	        _cell_data[CellData.CubeX] = _cube_x;
	        _cell_data[CellData.CubeY] = _cube_y;
	        _cell_data[CellData.CubeZ] = _cube_z;
			
	        _cell_data[CellData.Lifeforms] = [];

	        // Example content
	        _cell_data[CellData.Terrain] = irandom_range(0, sprite_get_number(spr_hex_tiles) - 1);
			
			switch (_cell_data[CellData.Terrain]) {
				case TerrainType.Forest:
				case TerrainType.Lake:
				case TerrainType.Mountain:
					_cell_data[CellData.Cost] = 2;
					break;
				default:
					_cell_data[CellData.Cost] = 1;
					break;
			}

	        // Store cell data
	        world_data[_row][_col] = _cell_data;
		}
	}
}