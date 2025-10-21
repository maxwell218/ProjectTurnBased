// Draw tiles in view
draw_tiles_in_view();

if (hovered_hex != noone) {
	
	// Draw hex tile highlight
	draw_sprite(spr_hex_tile_hover, 0, hovered_hex.x, hovered_hex.y);
	
	// Draw neighbors highlight
	//var _neighbors = get_hex_neighbors(hovered_hex);
	
	//if (array_length(_neighbors) > 0) {
		
	//	for (var _i = 0; _i < array_length(_neighbors); _i++) {
	//		draw_sprite(spr_hex_tile_hover, 0, _neighbors[_i].x, _neighbors[_i].y);
	//	}
	//}
}

