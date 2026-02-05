function ScrollListItem(_width, _height, _item) : UIChild(0, 0, _width, _height) constructor {
	
	#region Methods
	
	collect_hover = function(_mouse_x, _mouse_y, _hovered_stack, _context) {
		
		var _y = y - _context.scroll_y;
		
		if (point_in_rectangle(_mouse_x - _context.surface_x, _mouse_y - _context.surface_y, x, _y, x + width, _y + height)) {
			array_push(_hovered_stack, self);	
		}
	}
	
	draw = function(_scroll_y) {
		
		draw_set_color(c_gray);
		
		var _y = round(y - _scroll_y);
		draw_rectangle(x, _y, x + width, _y + height, false);
		
		draw_set_color(c_white);
		
		if (is_hovered && global.ui_manager.active_element == undefined) {
			draw_rectangle(x + 1, _y + 1, x + width - 1, _y + height - 1, true);
		}
		
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		
		draw_text(x + width div 2, _y + height div 2, string(item));
	}
	
	#endregion
	
	#region Variables
	
	item = _item;
	
	#endregion
}