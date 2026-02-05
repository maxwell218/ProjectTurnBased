function UIParent(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor {
	
	#region Methods
	
	collect_hover = function(_mouse_x, _mouse_y, _hovered_stack, _context = {}) {

		// Check if panel is hovered
		if (point_in_rectangle(_mouse_x, _mouse_y, x, y, x + width, y + height)) {
			
			// Check if any children is hovered
			var _children_count = array_length(children);
			for (var _i = _children_count - 1; _i >= 0; _i--) {
				
				var _child = children[_i];
				var _result = _child.collect_hover(_mouse_x, _mouse_y, _hovered_stack, _context);
			}
			
			array_push(_hovered_stack, self);
			return;
		}

		return;
	}
	
	#endregion
	
}