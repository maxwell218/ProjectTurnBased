function Panel(_x, _y, _width, _height, _children) : UIParent(_x, _y, _width, _height) constructor {
	
	#region Methods

	draw = function() {
		draw_sprite_ext(spr_ui_bg, 0, x, y, width / sprite_get_width(spr_ui_bg), height / sprite_get_height(spr_ui_bg), 0, c_white, 1);
	}
	
	#endregion
	
	#region Variables
	
	children = _children;
	
	#endregion
}