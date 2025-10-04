/// @description Move cursor

// GUI position for drawing
gui_x = device_mouse_x_to_gui(0);
gui_y = device_mouse_y_to_gui(0);

// Set actual world position
x = camera_get_view_x(view_camera[0]) + gui_x;
y = camera_get_view_y(view_camera[0]) + gui_y;