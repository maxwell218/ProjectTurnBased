function Button(_x, _y, _width, _height, _action) : UIChild(_x, _y, _width, _height) constructor {
	
	#region Methods
	
	on_primary_action_pressed = function() {
		
		script_execute(action);
	}
	
	draw = function() {
		
		draw_set_colour(c_ltgray);
		draw_rectangle(x, y, x + width, y + height, false);
		
		draw_set_colour(c_white);
	}
	
	#endregion
	
	#region Variables
	
	action = _action;
	
	#endregion
	
}