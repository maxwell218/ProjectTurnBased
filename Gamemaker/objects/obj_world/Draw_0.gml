// Draw tiles in view
draw_tiles_in_view();

draw_set_valign(fa_bottom);
draw_set_halign(fa_left);
	
draw_set_font(fnt_04b03);

if (variable_instance_exists(self, "player") && player.move_range_map != undefined) {
	var _keys = ds_map_keys_to_array(player.move_range_map);
	for (var _i = 0; _i < array_length(_keys); _i++) {
	    var _tile = _keys[_i];

	    // Draw translucent overlay on each reachable tile
	    var _cost = player.move_range_map[? _tile];
		
		if _cost == 0 continue;
		
		draw_sprite_ext(spr_hex_tile_hover, 0, _tile[CellData.X], _tile[CellData.Y], 1, 1, 0, c_aqua, 0.5);
	    draw_text(_tile[CellData.X] + HEX_WIDTH div 2, _tile[CellData.Y] + HEX_HEIGHT - 8, string(_cost));
	}
}

if (hovered_hex != noone) {
	
	// Draw hex tile highlight
	draw_sprite(spr_hex_tile_hover, 0, hovered_hex.x, hovered_hex.y);
}

draw_set_font(-1);

