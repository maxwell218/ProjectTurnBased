function Overworld() constructor {
	
	world_data = [[]];
	
	// Create a basic odd-q offset hex grid
	// Loop through each row
	
	/*
	for (var _row = 0; _row < WORLD_HEIGHT; _row++) {
		// Loop through each column
		for (var _col = 0; _col < WORLD_WIDTH; _col++) {
			
	        // Calculate the X position of the hex
	        // For flat-topped hexes, each column is horizontally offset by 3/4 of hex width
	        var _x_pos = _col * (HEX_WIDTH * 3/4);
			
	        // Calculate the Y position of the hex
	        // Each column alternates vertical offset by half a hex height to create the staggered layout
	        var _y_pos = _row * HEX_HEIGHT + (_col mod 2) * (HEX_HEIGHT / 2);
			
			// Convert to cube coordinates
			var _x = _col;
			var _y = _row - (_col - (_col & 1)) / 2;
			var _z = -_x - _y;
			
			// TODO Feed cell data like Terrain, Cost, etc.
			var _cell_data = array_create(CellData.Last);

			_cell_data[CellData.Row] = _row;
			_cell_data[CellData.Col] = _col;
			_cell_data[CellData.CubeX] = _x;
			_cell_data[CellData.CubeY] = _y;
			_cell_data[CellData.CubeZ] = _z;
			// _cell_data[CellData.Terrain] = TerrainType.Plain;
			
			// TODO Rewrite this for world gen
			_cell_data[CellData.Terrain] = irandom_range(0, sprite_get_number(spr_hex_tiles) - 1);
			_cell_data[CellData.Cost] = 1;
			
			var _cell_struct = { cell_data: _cell_data };
        
			// Create an instance of your hex tile at the calculated position
			var _cell_inst = instance_create_layer(_x_pos, _y_pos, "Tiles", obj_hex_tile, _cell_struct);
			delete _cell_struct;
			
			// Push each cell into our world array
			world_data[_row][_col] = _cell_inst;
	    }
	}
	*/
	
	for (var _row = 0; _row < WORLD_HEIGHT; _row++) {
		for (var _col = 0; _col < WORLD_WIDTH; _col++) {

	        // Pixel position for this tile (flat-topped offset coords)
	        var _x_pos = _col * (HEX_WIDTH * 3/4);
	        var _y_pos = _row * HEX_HEIGHT + (_col mod 2) * (HEX_HEIGHT / 2);

	        // Cube coordinates
	        var _cube_x = _col;
	        var _cube_y = _row - (_col - (_col & 1)) / 2;
	        var _cube_z = -_cube_x - _cube_y;

	        // Cell_data as array
	        var _cell_data = array_create(CellData.Last, undefined);
	        _cell_data[CellData.Row]   = _row;
	        _cell_data[CellData.Col]   = _col;
	        _cell_data[CellData.CubeX] = _cube_x;
	        _cell_data[CellData.CubeY] = _cube_y;
	        _cell_data[CellData.CubeZ] = _cube_z;

	        // Example content
	        _cell_data[CellData.Terrain] = irandom_range(0, sprite_get_number(spr_hex_tiles) - 1);
	        _cell_data[CellData.Cost]    = 1;

	        // Store lightweight struct containing the array
	        var _cell_struct = { cell_data: _cell_data, x: _x_pos, y: _y_pos };

	        world_data[_row][_col] = _cell_struct;
			delete _cell_struct;
		}
	}
}