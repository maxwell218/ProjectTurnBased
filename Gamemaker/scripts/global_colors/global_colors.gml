// +--------------------------------------------------+
// |                                                  |
// |   ______   ______   __       ______   ______     |
// |  /\  ___\ /\  __ \ /\ \     /\  __ \ /\  == \    |
// |  \ \ \____\ \ \/\ \\ \ \____\ \ \/\ \\ \  __<    |
// |   \ \_____\\ \_____\\ \_____\\ \_____\\ \_\ \_\  |
// |    \/_____/ \/_____/ \/_____/ \/_____/ \/_/ /_/  |
// |                                                  |
// +--------------------------------------------------+
// global.colors

global.colors = {};
with (global.colors) {
	
	// Stat Bar
	self[$ "col_red_bright"] 		= make_color_rgb(144, 84, 77);
	self[$ "col_red_dark"] 			= make_color_rgb(94, 74, 72);
	self[$ "col_yellow_bright"] 	= make_color_rgb(182, 168, 123);
	self[$ "col_yellow_dark"]		= make_color_rgb(151, 119, 96);
	self[$ "col_green_bright"] 		= make_color_rgb(129, 144, 77);
	self[$ "col_green_dark"] 		= make_color_rgb(95, 93, 79);
	
	color_to_rgb = function(_color) {
	    // returns a 3-element array [r, g, b] in 0..1 range
	    return [
	        color_get_red(_color)   / 255,
	        color_get_green(_color) / 255,
	        color_get_blue(_color)  / 255,
	    ];
	}
}

#macro COLORS global.colors