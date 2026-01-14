function ScrollListItem(_width, _height, _item) constructor {
	
	#region Methods
	
	is_hover = function(_surface_x, _surface_y, _scroll_y) {
		
		hovered = false;
		
		var _y = y - _scroll_y;
		
		if (point_in_rectangle(mouse_x - _surface_x, mouse_y - _surface_y, x, _y, x + width, _y + height)) {
			hovered = true;	
		}
		
		
		return hovered;
	}
	
	draw = function(_scroll_y) {
		
		draw_set_color(c_gray);
		
		var _y = round(y - _scroll_y);
		draw_rectangle(x, _y, x + width, _y + height, false);
		
		draw_set_color(c_white);
		
		if (hovered) {
			draw_rectangle(x + 1, _y + 1, x + width - 1, _y + height - 1, true);
		}
		
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		
		draw_text(x + width div 2, _y + height div 2, string(item));
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
	hovered = false;
	
	#endregion
}