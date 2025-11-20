function ScrollListItem(_width, _height, _item) constructor {
	
	#region Methods
	
	draw = function(_scroll_y) {
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		draw_set_color(c_gray);
		var _y = y - _scroll_y;
		draw_rectangle(x, _y, x + width, _y + height, false);
		
		draw_set_color(c_white);
		draw_text(x, _y, string(item));
	}
	
	#endregion
	
	#region Variables
	
	// How tall it is
	// How to draw itself
	// How to handle mouse interactions
	// How to update its own layout when its data changes
	x = 0;
	y = 0;
	width = _width;
	height = _height;
	
	item = _item;
	
	#endregion
}