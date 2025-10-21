if (global.debug) {
	
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	
	draw_set_font(fnt_04b03);
	
	draw_text(x, y, "Instances: " + string(instance_count));
	draw_text(x, y + 8, "Hexes: " + string(instance_number(obj_hex_tile)));
	
	draw_text(x, y + 16, "Pools: " + string(pool_rows) + ", " + string(pool_cols));
	draw_text(x, y + 24, "Anchors: " + string(anchor_row) + ", " + string(anchor_col));
	
	if (hovered_hex != noone) {

		var _col = hovered_hex.cell_data[CellData.Col];
		var _row = hovered_hex.cell_data[CellData.Row];

		draw_text(x, y + 40, "Col/Row: " + string(_col) + ", " + string(_row));
		draw_text(x, y + 48, "Pos: " + string(hovered_hex.x) + ", " + string(hovered_hex.y));
	}
	
	draw_set_font(-1);
}