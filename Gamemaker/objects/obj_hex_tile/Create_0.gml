/// @description Create cell data enum

enum CellData {
	Col,
	Row,
	CubeX,
	CubeY,
	CubeZ,
	Terrain,
	Cost,
	Locations,
	Loot,
	Lifeforms,
	Occupancy,
	Last,
}

draw = function() {
	draw_sprite(spr_hex_tiles, cell_data[CellData.Terrain], x, y);	
}