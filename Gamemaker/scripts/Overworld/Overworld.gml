function Overworld() constructor {
	
	// Hex tile dimensions
	var _hex_w = 72;  // Width of a single hex tile
	var _hex_h = 36;  // Height of a single hex tile

	// Grid size
	var _cols = 30;   // Number of columns in the grid
	var _rows = 30;   // Number of rows in the grid

	// Loop through each column
	for (var _col = 0; _col < _cols; _col++) {
    
	    // Loop through each row
	    for (var _row = 0; _row < _rows; _row++) {
        
	        // Calculate the X position of the hex
	        // For flat-topped hexes, each column is horizontally offset by 3/4 of hex width
	        var _x_pos = _col * (_hex_w * 3/4);
        
	        // Calculate the Y position of the hex
	        // Each column alternates vertical offset by half a hex height to create the staggered layout
	        var _y_pos = _row * _hex_h + (_col mod 2) * (_hex_h / 2);
        
	        // Create an instance of your hex tile at the calculated position
	        instance_create_layer(_x_pos, _y_pos, "Instances", obj_hex_tile);
	    }
	}
}