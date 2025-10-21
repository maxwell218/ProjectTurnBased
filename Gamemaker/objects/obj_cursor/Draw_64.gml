/// @description Draw cursor

// Draw cursor info
if (global.debug) {
	
	draw_set_valign(fa_top);
	draw_set_halign(fa_right);
	
	draw_set_font(fnt_04b03);

	var _cam_width = camera_get_view_width(view_camera[0]);
	var _cam_height = camera_get_view_height(view_camera[0]);
	var _x = _cam_width;
	var _y = 0;

	draw_text(_x, _y, "Cursor x: " + string(x));
	draw_text(_x, _y + 8, "Cursor y: " + string(y));
	draw_text(_x, _y + 16, "Gui x: " + string(gui_y));
	draw_text(_x, _y + 24, "Gui y: " + string(gui_y));
	
	draw_set_font(-1);
}

// Draw the cursor
draw_sprite(spr_custom_cursor, 0, gui_x, gui_y);