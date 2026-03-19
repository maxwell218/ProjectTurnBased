// +-----------------------------------------------------------+
// |                                                           |
// |   ______   ______   ______   ______   __       __         |
// |  /\  ___\ /\  ___\ /\  == \ /\  __ \ /\ \     /\ \        |
// |  \ \___  \\ \ \____\ \  __< \ \ \/\ \\ \ \____\ \ \____   |
// |   \/\_____\\ \_____\\ \_\ \_\\ \_____\\ \_____\\ \_____\  |
// |    \/_____/ \/_____/ \/_/ /_/ \/_____/ \/_____/ \/_____/  |
// |                                                           |
// +-----------------------------------------------------------+
// class.ScrollListItem

function ScrollListItem(_config) : UIChild(_config) constructor {
	var _self = self;
	
	#region Config
	
	// Private
	with (__) {
		item = _config[$ "item"] ?? "undefined";
	}
	
	#endregion
	#region Hover
	
	// Public
	static collect_hover = function(_mouse_x, _mouse_y, _hovered_stack, _context) {
		var _x = round(__.x - _context.scroll_x);
		var _y = round(__.y - _context.scroll_y);
		
		if (point_in_rectangle(_mouse_x - _context.surface_x, _mouse_y - _context.surface_y, _x, _y, _x + __.width, _y + __.height)) {
			array_push(_hovered_stack, self);	
		}
	}
	
	#endregion
	#region Render
	
	// Public
	static render = function(_context) {
		var _x = round(__.x - _context.scroll_x);
		var _y = round(__.y - _context.scroll_y);
		var _b_style = _context.border_style;
		// var _b_color;
		
		// Draw background
		draw_set_color(c_gray);
		draw_rectangle(_x, _y, _x + __.width, _y + __.height, false);
		
		// Draw borders
		__render_border(_context, c_blue);
		
		draw_set_color(c_white);
		// TODO Custom text centering
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(_x + __.width div 2, _y + __.height div 2, string(__.item));
	}
	static render_hover = function(_context) {
		__render_border(_context, c_white);
	}
	
	// Private
	with (__) {
		static __render_border = function(_context, _color) {
			var _axis = _context.scroll_axis;
			var _x = round(__.x - _context.scroll_x);
			var _y = round(__.y - _context.scroll_y);
			var _b_style = _context.border_style;
		
			draw_set_color(_color);
			if (_b_style == ScrollListBorderStyle.Shared) {
				if (_axis == ScrollAxis.Vertical) {
					draw_rectangle(_x + 1, _y + 1, _x + __.width - 1, _y + __.height, true);
				} else {
					draw_rectangle(_x + 1, _y + 1, _x + __.width, _y + __.height - 1, true);
				}
			} else {
				draw_rectangle(_x + 1, _y + 1, _x + __.width - 1, _y + __.height - 1, true);
			}
		}
	}
	
	#endregion
}