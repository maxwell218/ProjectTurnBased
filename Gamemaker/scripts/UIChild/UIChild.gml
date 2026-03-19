// +-------------------+
// |                   |
// |   __  __   __     |
// |  /\ \/\ \ /\ \    |
// |  \ \ \_\ \\ \ \   |
// |   \ \_____\\ \_\  |
// |    \/_____/ \/_/  |
// |                   |
// +-------------------+
// class.UIChild

function UIChild(_config) : UIElement(_config) constructor {
	var _self = self;
	
	#region Hover
	
	// Public
	static collect_hover = function(_mouse_x, _mouse_y, _hovered_stack, _context = {}) {
		if (point_in_rectangle(_mouse_x, _mouse_y, __.x, __.y, __.x + __.width, __.y + __.height)) {
			array_push(_hovered_stack, self);
		}
	}
	
	#endregion
}