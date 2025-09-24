if (global.debug) {
	
	draw_set_valign(fa_middle);
	draw_set_halign(fa_center);

	var _x = x + HEX_WIDTH div 2
	var _y = y + HEX_HEIGHT div 2;

	// Show tile coords
	draw_text_transformed(_x, _y, 
		"(" + string(cell_data[CellData.Col]) + 
		", " + string(cell_data[CellData.Row]) + ")",
		0.5, 0.5, 0);
}