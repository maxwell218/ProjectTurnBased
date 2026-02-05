function UIChild(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor {
	
	#region Methods
	
	collect_hover = function(_mouse_x, _mouse_y, _hovered_stack, _context = {}) {
		
		if (point_in_rectangle(_mouse_x, _mouse_y, x, y, x + width, y + height)) {
			array_push(_hovered_stack, self);
		}
	}
	
	#endregion
}