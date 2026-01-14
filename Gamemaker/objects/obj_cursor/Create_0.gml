/// @description Create cursor

depth = DepthTable.Cursor;

// Set default cursor to none
window_set_cursor(cr_none);

gui_x = camera_get_view_width(view_camera[0]) * 0.5;
gui_y = camera_get_view_height(view_camera[0]) * 0.5;