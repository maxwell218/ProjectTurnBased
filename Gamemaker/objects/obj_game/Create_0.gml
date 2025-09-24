/// @description Create all game components
global.debug = true;

// Resize gui size to match camera's size
var _cam_width = camera_get_view_width(view_camera[0]);
var _cam_height = camera_get_view_height(view_camera[0]);
display_set_gui_size(_cam_width, _cam_height);

// Create cursor object
cursor = instance_create_layer(0, 0, "UI", obj_cursor);
camera = instance_create_layer(0, 0, "UI", obj_camera);
world = noone;

// TODO Add proper game start button
room_goto(rm_world);