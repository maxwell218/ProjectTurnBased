// +-------------------+
// |                   |
// |   __  __   __     |
// |  /\ \/\ \ /\ \    |
// |  \ \ \_\ \\ \ \   |
// |   \ \_____\\ \_\  |
// |    \/_____/ \/_/  |
// |                   |
// +-------------------+
// class.UIElement

function UIElement(_config) constructor {
	var _self = self;
	
	#region Config
	
	// Public
	#region Getters
	
	static get_x = function() {
		return __.x;	
	}
	static get_y = function() {
		return __.y;	
	}
	static get_width = function() {
		return __.width;	
	}
	static get_height = function() {
		return __.height;	
	}
	static get_is_hovered = function() {
		return __.is_hovered;
	}
	static get_content_size = function() {
		return { width: __.width, height: __.height };
	}
	
	#endregion
	#region Setters
	
	static set_x = function(_x) {
		__.x = _x;
	}
	static set_y = function(_y) {
		__.y = _y;
	}
	static set_width = function(_width) {
		__.width = _width;
	}
	static set_height = function(_height) {
		__.height = _height;
	}
	static set_is_hovered = function(_is_hovered) {
		__.is_hovered = _is_hovered;	
	}
	
	#endregion
	
	// Private
	__ = {}
	with (__) {
		// Position and size
		x = _config[$ "x"] ?? 0;
		y = _config[$ "y"] ?? 0;
		width  = _config[$ "width" ] ?? 0;
        height = _config[$ "height"] ?? 0;
	
		// Hovered state
		is_hovered = _config[$ "is_hovered" ] ?? false;
		
		// Format
		ui_format = _config[$ "ui_format"] ?? UI_MANAGER.get_ui_format();
	}
	
	#endregion
	#region Resize
	
	static resize = function(_config) {
        __.x      = _config[$ "x"     ] ?? __.x;
        __.y      = _config[$ "y"     ] ?? __.y;
        __.width  = _config[$ "width" ] ?? __.width;
        __.height = _config[$ "height"] ?? __.height;
    }
	
	#endregion
}