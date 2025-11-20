if (global.debug) {
	
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	
	draw_text(x, y, "Instances: " + string(instance_count));
	draw_text(x, y + 8, "Hexes: " + string(instance_number(obj_hex_tile)));
	
	draw_text(x, y + 16, "Pools: " + string(pool_rows) + ", " + string(pool_cols));
	draw_text(x, y + 24, "Anchors: " + string(anchor_row) + ", " + string(anchor_col));
}