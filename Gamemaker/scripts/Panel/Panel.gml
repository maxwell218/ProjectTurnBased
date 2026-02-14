function Panel(_x, _y, _width, _height, _children) : UIParent(_x, _y, _width, _height) constructor {
	
	#region Methods
	
	step = function() {
		
		var _children_count = array_length(children);
		for (var _i = 0; _i < _children_count; _i++) {
			
			var _child = children[_i];
			if (variable_struct_exists(_child, "step")) {
				_child.step();
			}
		}
	}

	draw = function() {
		
		// Draw panel background
		draw_sprite_ext(spr_ui_bg, 0, x, y, width / sprite_get_width(spr_ui_bg), height / sprite_get_height(spr_ui_bg), 0, c_white, 1);
		
		var _children_count = array_length(children);
		for (var _i = 0; _i < _children_count; _i++) {
			
			var _child = children[_i];
			if (variable_struct_exists(_child, "draw")) {
				_child.draw();
			}
		}
	}
	
	#endregion
	
	#region Variables
	
	children = _children;
	
	#endregion
}