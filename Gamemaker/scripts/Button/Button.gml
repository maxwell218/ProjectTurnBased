function Button(_x, _y, _width, _height, _action) constructor {
	
	#region Methods
	
	is_hover = function() {
		
		if (point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), x, y, x + width, y + height)) {
			return true;
		}
		
		return false;
	}
	
	on_click = function() {
		script_execute(action);
	}
	
	draw = function() {
		draw_set_colour(c_ltgray);
		draw_rectangle(x, y, x + width, y + height, false);
		
		draw_set_colour(c_white);
	}
	
	#endregion
	
	#region Variables
	
	x = _x;
	y = _y;
	
	width = _width;
	height = _height;
	
	action = _action;
	
	#endregion
	
}