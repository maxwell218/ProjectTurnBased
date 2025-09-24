if (global.debug) {
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);

	var _coords = pixel_to_hex_distance(mouse_x, mouse_y);

	draw_text(x, y, "Col/Row: " + string(_coords[0]) + ", " + string(_coords[1]));

	// Convert col and row -> x and y
	var _x_pos = _coords[0] * (HEX_WIDTH * 3/4);
	var _y_pos = _coords[1] * HEX_HEIGHT + (_coords[0] mod 2) * (HEX_HEIGHT / 2);
	draw_text(x, y + 16, "Pos: " + string(_x_pos) + ", " + string(_y_pos));

	verts = create_hex_vertices(_x_pos, _y_pos);

	for (var _v = 0; _v < array_length(verts); _v++) {
		draw_circle(verts[_v][0], verts[_v][1], 1, false);	
	}

	var _inside = (point_in_polygon(mouse_x, mouse_y, verts)) ? "true" : "false";
	draw_text(x, y + 32, _inside);
}