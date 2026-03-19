/// @description Move cursor
mouse_gui_scale_x = display_get_gui_width()  / display_get_width();
mouse_gui_scale_y = display_get_gui_height() / display_get_height();

// GUI position for drawing
if (window_mouse_get_locked()) {
	// TODO Implement proper delta class
	var _dt = delta_time / 16666; // normalize to 60fps baseline
    gui_x += window_mouse_get_delta_x() * mouse_gui_scale_x * _dt;
	gui_y += window_mouse_get_delta_y() * mouse_gui_scale_y * _dt;
} else {
	gui_x = device_mouse_x_to_gui(0);
	gui_y = device_mouse_y_to_gui(0);
}

// Set actual world position
var _cam_x = camera_get_view_x(view_camera[0]);
var _cam_y = camera_get_view_y(view_camera[0]);

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

gui_x = clamp(gui_x, 0, _gui_w);
gui_y = clamp(gui_y, 0, _gui_h);

x = _cam_x + gui_x;
y = _cam_y + gui_y;