if (global.debug) {
	
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_right);
	
	draw_set_font(fnt_04b03);
	
	var _x = camera_get_view_width(view_camera[0]);
	var _y = camera_get_view_height(view_camera[0]);
	
	draw_text(_x, _y, "Groups: " + string(ds_map_size(lifeform_groups)));
	
	draw_set_font(-1);
}