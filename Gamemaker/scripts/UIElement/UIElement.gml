// +-------------------+
// |                   |
// |   __  __   __     |
// |  /\ \/\ \ /\ \    |
// |  \ \ \_\ \\ \ \   |
// |   \ \_____\\ \_\  |
// |    \/_____/ \/_/  |
// |                   |
// +-------------------+
// class.UIElement

function UIElement(_config = {}) : Base(_config) constructor {
	var _self = self;
	
	#region Config
	
	// Public
	#region Getters
	
	static get_x = function() {
		return __.x;	
	}
	static get_y = function() {
		return __.y;	
	}
	static get_width = function() {
		return __.width;	
	}
	static get_height = function() {
		return __.height;	
	}
	static get_is_hovered = function() {
		return __.is_hovered;
	}
	
	#endregion
	#region Setters
	
	static set_x = function(_x) {
		__.x = _x;
	}
	static set_y = function(_y) {
		__.y = _y;
	}
	static set_width = function(_width) {
		__.width = _width;
	}
	static set_height = function(_height) {
		__.height = _height;
	}
	static set_is_hovered = function(_is_hovered) {
		__.is_hovered = _is_hovered;	
	}
	
	#endregion
	
	// Private
	with (__) {
		x = _config[$ "x"] ?? 0;
		y = _config[$ "y"] ?? 0;
		width  = _config[$ "width" ] ?? 0;
        height = _config[$ "height"] ?? 0;
		is_hovered = _config[$ "is_hovered" ] ?? false;
		static default_style = new UIStyle();
		style = _config[$ "style"] ?? default_style;
	}
	
	#endregion
	#region Initialize
	
	on_initialize(function() {
		__.style.initialize();
	});
	
	#endregion
	#region Hover
	
	// Public
	static collect_hover = function(_mouse_x, _mouse_y, _hovered_stack, _context = {}) {
		if (point_in_rectangle(_mouse_x, _mouse_y, __.x, __.y, __.x + __.width, __.y + __.height)) {
			array_push(_hovered_stack, self);
		}
	}
	
	#endregion
	#region Resize
	
	static resize = function(_config) {
        __.x      = _config[$ "x"     ] ?? __.x;
        __.y      = _config[$ "y"     ] ?? __.y;
        __.width  = _config[$ "width" ] ?? __.width;
        __.height = _config[$ "height"] ?? __.height;
    }
	
	#endregion
	#region Render
	
	// Public
	static _render = function() {
		draw_sprite_stretched(spr_ui_bg, 0, __.x, __.y, __.width, __.height);
		__render_border();
	}
	
	// Private
	with (__) {
		static __render_border = function() {
			//if (__.ui_format == undefined || __.ui_format.get_border_mode() == UIBorderMode.None) exit;
			//var _border_mode = __.ui_format.get_border_mode();
			//var _sprite = __.ui_format.get_border_sprite();
			//var _color = __.ui_format.get_border_color();
			//switch (_border_mode) {
			//	case UIBorderMode.Inner:
			//		draw_sprite_stretched_ext(
			//			_sprite, 0,
			//			__.x,
			//			__.y,
			//			__.width,
			//			__.height,
			//			_color, 1
			//		);
			//		break;
			//	case UIBorderMode.Outer:
			//		var _top = __.ui_format.get_border_top();
			//		var _bottom = __.ui_format.get_border_bottom();
			//		var _left = __.ui_format.get_border_left();
			//		var _right = __.ui_format.get_border_right();
			//		draw_sprite_stretched_ext(
			//			_sprite, 0,
			//			__.x - _left,
			//			__.y - _top,
			//			__.width + _left + _right,
			//			__.height + _top + _bottom,
			//			_color, 1
			//		);
			//		break;
			//}
		}
	}
	
	// Events
	on_render(function() {
		// TODO Use color as fallback for missing sprite?
		//		We should also not always draw a background if we don't have to
		// draw_sprite_stretched(__.style.get_bg_sprite(), 0, __.x, __.y, __.width, __.height);
	});
	
	#endregion
}