/// @description Create all game components
enum DepthTable {
	Cursor,
	Menu,
	UI,
	World,
}

global.debug = true;
global.event_manager = new EventManager();

// Resize gui size to match camera's size
// TODO Proper resolution scaling
var _cam_width = camera_get_view_width(view_camera[0]);
var _cam_height = camera_get_view_height(view_camera[0]);
display_set_gui_size(_cam_width, _cam_height);

window_mouse_set_locked(true);

window_set_min_width(480);
window_set_min_height(270);

draw_set_font(fnt_04b03);

// Create main menu necessities
global.cursor = instance_create_layer(x, y, "UI", obj_cursor);
global.input = instance_create_layer(x, y, "Controllers", obj_input);
global.ui_manager = new UIManager();

// Initialise global game objects
global.world = noone;
global.camera = noone;
global.lifeform_controller = noone;

// Resize room to fit world grid
room_set_width(rm_game, HEX_WIDTH * WORLD_WIDTH * 3/4);
room_set_height(rm_game, HEX_HEIGHT * WORLD_HEIGHT);

// TODO Add proper main menu
room_goto(rm_ui);