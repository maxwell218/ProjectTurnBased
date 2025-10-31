// Draw tiles in view
draw_tiles_in_view();

draw_set_valign(fa_bottom);
draw_set_halign(fa_center);
	
draw_set_font(fnt_04b03);

var _player_group = global.lifeform_controller.lifeform_groups[? PLAYER_GROUP_ID];

if (_player_group != undefined && global) {
	_player_group.draw_move_range();
}

if (hovered_hex != noone) {
	
	// Draw hex tile highlight
	draw_sprite(spr_hex_tile_hover, 0, hovered_hex.x, hovered_hex.y);
}

draw_set_font(-1);

