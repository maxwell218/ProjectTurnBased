function Overworld() constructor {
	
	world_data = [[]];
	
	// Create a basic odd-q offset hex grid
	// Loop through each row
	for (var _row = 0; _row < WORLD_HEIGHT; _row++) {
		// Loop through each column
		for (var _col = 0; _col < WORLD_WIDTH; _col++) {
			
	        // Calculate the X position of the hex
	        // For flat-topped hexes, each column is horizontally offset by 3/4 of hex width
	        var _x_pos = _col * (HEX_WIDTH * 3/4);
			
	        // Calculate the Y position of the hex
	        // Each column alternates vertical offset by half a hex height to create the staggered layout
	        var _y_pos = _row * HEX_HEIGHT + (_col mod 2) * (HEX_HEIGHT / 2);
			
			// TODO Feed cell data like Terrain, Cost, etc.
			var _cell_data = array_create(CellData.Last);

			_cell_data[CellData.Row] = _row;
			_cell_data[CellData.Col] = _col;
			_cell_data[CellData.Terrain] = TerrainType.Plain;
			_cell_data[CellData.Cost] = 1;
			
			var _cell_struct = { cell_data: _cell_data };
        
			// Create an instance of your hex tile at the calculated position
			var _cell_inst = instance_create_layer(_x_pos, _y_pos, "Tiles", obj_hex_tile, _cell_struct);
			delete _cell_struct;
			
			// Push each cell into our world array
			world_data[_row][_col] = _cell_inst;
	    }
	}
	
}