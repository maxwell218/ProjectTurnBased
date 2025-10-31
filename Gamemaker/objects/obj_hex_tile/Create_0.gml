/// @description Create cell data enum

enum CellData {
	X,
	Y,
	Col,
	Row,
	CubeX,
	CubeY,
	CubeZ,
	Terrain,
	Cost,
	Locations,
	Loot,
	LifeformGroups,
	Occupancy,
	Last,
}

/// @description Draw all tile elements
draw = function() {
	
	// Draw the terrain
	draw_sprite(spr_hex_tiles, cell_data[CellData.Terrain], x, y);
	
	// Draw the lifeform groups
	var _lifeform_count = array_length(cell_data[CellData.LifeformGroups]);
	
	// TODO Draw 2 groups max, priority for player group and allow swapping viewed group
	if (_lifeform_count > 0) {
		
		for (var _i = 0; _i < _lifeform_count; _i++) {
			cell_data[CellData.LifeformGroups][_i].draw();
		}
	}
}