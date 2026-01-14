if (global.debug) {
	
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_right);
	
	var _x = camera_get_view_width(view_camera[0]);
	var _y = camera_get_view_height(view_camera[0]);
	
	draw_text(_x, _y, "Groups: " + string(ds_map_size(lifeform_groups)));
	draw_text(_x, _y - 8, "Timer: " + string(time_source_get_time_remaining(lifeform_group_movement_timer)));
}