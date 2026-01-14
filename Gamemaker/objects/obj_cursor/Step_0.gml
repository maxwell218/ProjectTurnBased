/// @description Move cursor

// GUI position for drawing
if (window_mouse_get_locked()) {
	gui_x += window_mouse_get_delta_x() * 0.5;
    gui_y += window_mouse_get_delta_y() * 0.5;
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

