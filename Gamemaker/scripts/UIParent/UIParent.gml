// +-------------------+
// |                   |
// |   __  __   __     |
// |  /\ \/\ \ /\ \    |
// |  \ \ \_\ \\ \ \   |
// |   \ \_____\\ \_\  |
// |    \/_____/ \/_/  |
// |                   |
// +-------------------+
// class.UIParent

function UIParent(_config = {}) : UIElement(_config) constructor {
	var _self = self;
	
	#region Config
	
	// Private
	with (__) {
		children = _config[$ "children"] ?? [];	
	}
	
	#endregion
	#region Hover
	
	// Public
	static collect_hover = function(_mouse_x, _mouse_y, _hovered_stack, _context = {}) {
		// Check if hovered
		if (point_in_rectangle(_mouse_x, _mouse_y, __.x, __.y, __.x + __.width, __.y + __.height)) {
			// Check if any children is hovered
			var _children_count = array_length(__.children);
			for (var _i = _children_count - 1; _i >= 0; _i--) {
				var _child = __.children[_i];
				var _result = _child.collect_hover(_mouse_x, _mouse_y, _hovered_stack, _context);
			}
			array_push(_hovered_stack, self);
			return;
		}
	}
	
	#endregion
}