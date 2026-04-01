// +--------------------------------------------------+
// |                                                  |
// |   ______  ______   __   __   ______   __         |
// |  /\  == \/\  __ \ /\ "-.\ \ /\  ___\ /\ \        |
// |  \ \  _-/\ \  __ \\ \ \-.  \\ \  __\ \ \ \____   |
// |   \ \_\   \ \_\ \_\\ \_\\"\_\\ \_____\\ \_____\  |
// |    \/_/    \/_/\/_/ \/_/ \/_/ \/_____/ \/_____/  |
// |                                                  |
// +--------------------------------------------------+
// class.Panel

function Panel(_config) : UIParent(_config) constructor {
	var _self = self;
	
	#region Step
	
	// Public
	static step = function() {
		var _children_count = array_length(__.children);
		for (var _i = 0; _i < _children_count; _i++) {
			
			var _child = __.children[_i];
			if (variable_struct_exists(_child, "step")) {
				_child.step();
			}
		}
	}
	
	#endregion
	#region Render
	
	// Public
	static render = function() {
		// Draw panel background
		//draw_sprite_ext(spr_ui_bg, 0, __.x, __.y, __.width / sprite_get_width(spr_ui_bg), __.height / sprite_get_height(spr_ui_bg), 0, c_white, 1);
		//var _children_count = array_length(__.children);
		//for (var _i = 0; _i < _children_count; _i++) {
			
		//	var _child = __.children[_i];
		//	if (variable_struct_exists(_child, "render")) {
		//		_child.render();
		//	}
		//}
	}
	
	#endregion
}