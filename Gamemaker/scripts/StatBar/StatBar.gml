// +--------------------------------------+
// |                                      |
// |   ______   ______  ______   ______   |
// |  /\  ___\ /\__  _\/\  __ \ /\__  _\  |
// |  \ \___  \\/_/\ \/\ \  __ \\/_/\ \/  |
// |   \/\_____\  \ \_\ \ \_\ \_\  \ \_\  |
// |    \/_____/   \/_/  \/_/\/_/   \/_/  |
// |                                      |
// +--------------------------------------+
// class.StatBar

function StatBar(_config = {}) constructor {
	
	var _self = self;
	
	#region Config

	// Private
	__ = {};
    with(__) {
		
		// Position and size
		x = _config[$ "x"] ?? 0;
		y = _config[$ "y"] ?? 0;
		inner_x = x + 1;
		inner_y = y + 1;
		
		width  = _config[$ "width" ] ?? 0;
		height = _config[$ "height"] ?? 0;
		inner_width = width - 2;
		inner_height = height - 2;
		
		// Stat type, defines color behavior
		stat_type = _config[$ "stat_type"] ?? undefined;
		
		// Trend indicator
		show_trend_indicator = _config[$ "show_trend_indicator"] ?? false;
		
    }
	
	#endregion
	#region Color
	
	// Private
	with(__) {
		
		static __get_stat_color = function(_pct) {
			switch(__.stat_type) {
				
				case "pain":
					if (_pct < 0.3) return [COLORS.col_green_bright, COLORS.col_green_dark];
					if (_pct < 0.6) return [COLORS.col_yellow_bright, COLORS.col_yellow_dark];
					return [COLORS.col_red_bright, COLORS.col_red_dark];
				
				default:
					if (_pct < 0.3) return [COLORS.col_red_bright, COLORS.col_red_dark];
					if (_pct < 0.6) return [COLORS.col_yellow_bright, COLORS.col_yellow_dark];
					return [COLORS.col_green_bright, COLORS.col_green_dark];
			}
		}
		
	}
	
	#endregion
	#region Render

	// Public
	static render = function(_stat_previous, _stat_current, _stat_max, _event_number) {
		
		// Draw border
		draw_sprite_stretched(spr_stat_bar_border, 0, __.x, __.y, __.width, __.height);
		
		// Derived values
        var _pct    = clamp(_stat_current / _stat_max, 0, 1);
		var _filled_pixels = round(_pct * __.inner_width);
		var _snapped_pct   = _filled_pixels / __.inner_width;
        var _color  = __get_stat_color(_pct);
        var _bright = COLORS.color_to_rgb(_color[0]);
        var _dark   = COLORS.color_to_rgb(_color[1]);
		var _scale    = (_event_number == ev_gui) ? VIEW.get_scale() : 1;
		
		var _x = __.inner_x;  // no offset needed
		var _w = __.inner_width;

        // Set shader + uniforms
        shader_set(__shader);
        shader_set_uniform_f(__u_bright,    _bright[0], _bright[1], _bright[2]);
	    shader_set_uniform_f(__u_dark,      _dark[0],   _dark[1],   _dark[2]);
	    shader_set_uniform_f(__u_fill,      _snapped_pct);
	    shader_set_uniform_f(__u_bar_x,     _x);
	    shader_set_uniform_f(__u_bar_width, _w);
	    shader_set_uniform_f(__u_scale, 	_scale);

        // Draw fill
        draw_sprite_stretched(spr_stat_bar_fill, 0, __.inner_x, __.inner_y, __.inner_width, __.inner_height);

        shader_reset();
		
		// Trend indicator (optional)
        //if (__.show_trend_indicator) {
            //_render_trend(_stat_previous, _stat_current, _stat_max);
        //}
	}
	
	// Private
	with(__) {
		static __shader       	= shd_bar;
	    static __u_bright     	= shader_get_uniform(__shader, "u_col_bright");
	    static __u_dark       	= shader_get_uniform(__shader, "u_col_dark");
		static __u_fill 		= shader_get_uniform(__shader, "u_fill");
		static __u_bar_x 		= shader_get_uniform(__shader, "u_bar_x");
		static __u_bar_width 	= shader_get_uniform(__shader, "u_bar_width");
		static __u_scale 		= shader_get_uniform(__shader, "u_scale");
	}
	
	#endregion
	
}