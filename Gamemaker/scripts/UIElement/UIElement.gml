function UIElement(_x, _y, _width, _height) constructor {
	
	#region Methods
	
	add_action = function(_input, _press, _func, _args) {
		
	}
	
	#endregion
	
	#region Variables
	
	x = _x;
	y = _y;
	
	width = _width;
	height = _height;
	
	is_hovered = false;
	
	actions = [];
	
	#endregion
}