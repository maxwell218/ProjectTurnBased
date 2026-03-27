// +---------------------------------------+
// |                                       |
// |   __   __ __   ______   __     __     |
// |  /\ \ / //\ \ /\  ___\ /\ \  _ \ \    |
// |  \ \ \'/ \ \ \\ \  __\ \ \ \/ ".\ \   |
// |   \ \__|  \ \_\\ \_____\\ \__/".~\_\  |
// |    \/_/    \/_/ \/_____/ \/_/   \/_/  |
// |                                       |
// +---------------------------------------+
// obj_view_manager.create

var _self = self;

#region Singleton

if (variable_struct_exists(global, "view_manager") && global.view_manager != id) {
	show_error("global.view_manager already exists", true);
}
global.view_manager = id;
#macro VIEW_MANAGER global.view_manager

#endregion
#region Config

// Private
__ = {};
with (__) {
	// Base game dimensions
	base_width  = _self[$ "base_width" ] ?? 480;
	base_height = _self[$ "base_height"] ?? 270;
	
	// Viewport and window dimensions
	viewport_width  = _self[$ "viewport_width" ] ?? 0;
	viewport_height = _self[$ "viewport_height"] ?? 0;
	window_width 	= _self[$ "window_width"   ] ?? 0;
	window_height   = _self[$ "window_height"  ] ?? 0;
	
	offset_x = 0;
	offset_y = 0;
	
	// Scale factor
	scale = _self[$ "scale"] ?? 1;
	
	// Fullscreen state
	is_fullscreen = _self[$ "is_fullscreen"] ?? false;
}

#endregion
#region Initialize

// Public
initialize = function() {
	__.on_initialize();
}

// Private
with(__) {
	on_initialize = method(_self, function() {
		
		// Get initial window size
		__.window_width = window_get_width();
		__.window_height = window_get_height();
		
		// Calculate initial scale
		__.calculate_scale();
	});
}

#endregion
#region Resize

// Public
check_window_resize = function() {
	var _is_resize = false;
	
	var _w = window_get_width();
	var _h = window_get_height();
	
	if (!__.is_fullscreen) {
		if (_w != 0 && __.window_width != _w) {
			_is_resize = true;
		}
		if (_h != 0 && __.window_height != _h) {
			_is_resize = true;
		}
	}
	
	if (_is_resize) {
		// Window resized event
		event_manager_publish(Event.WindowResized, {
			width: _w,
			height: _h
		});
	}
}

// Private
with (__) {
	handle_resize = method(_self, function(_config) {
		__.window_width  = _config[$ "width" ] ?? undefined;
		__.window_height = _config[$ "height"] ?? undefined;
		
		__.calculate_scale();
	});
}

// Events
event_manager_subscribe(Event.WindowResized, __.handle_resize);

#endregion
#region Fullscreen

// Public
check_shortcuts = function() {
	
	// Check if Alt + Enter was pressed
	if (keyboard_check_pressed(vk_enter) && keyboard_check(vk_alt)) {
		__.toggle_fullscreen();
	}
}

// Private
with (__) {
	toggle_fullscreen = method(_self, function() {
		__.is_fullscreen = !__.is_fullscreen;
        window_set_fullscreen(__.is_fullscreen);
		
        if (__.is_fullscreen) {
            // Store windowed size before going fullscreen
            __.window_width = display_get_width();
            __.window_height = display_get_height();
        } else {
            // Restore windowed size (you can customize these defaults)
            __.window_width = __.base_width * 3; // Default 1920x1080 scaled
            __.window_height = __.base_height * 3;
			
			var _wx = (display_get_width() div 2) - (__.window_width div 2);
			var _wy = (display_get_height() div 2) - (__.window_height div 2);
            window_set_rectangle(_wx, _wy, __.window_width, __.window_height);
        }
		
		event_manager_publish(Event.WindowResized, {
			width: __.window_width,
			height: __.window_height
		});
	});
}

#endregion
#region Scale

// Public
get_scale = function() {
	return __.scale;
}

// Private
with (__) {
	calculate_scale = method(_self, function() {
	    var _h_scale = floor(__.window_width  / __.base_width);
	    var _v_scale = floor(__.window_height / __.base_height);
	    __.scale = max(min(_h_scale, _v_scale), 1);
		// TODO Proper scale clamping
		// __.scale = clamp(__.scale, 2, 3);

	    // Expand to GUI dimensions
	    var _expanded_w = floor(__.window_width  / __.scale);
	    var _expanded_h = floor(__.window_height / __.scale);

	    // Optional: keep these even if your game logic really needs it
	    _expanded_w -= (_expanded_w mod 2);
	    _expanded_h -= (_expanded_h mod 2);

	    // Port size in window pixels
	    var _port_w = _expanded_w * __.scale;
	    var _port_h = _expanded_h * __.scale;

	    // Actual remainder
	    var _remainder_x = __.window_width  - _port_w;
	    var _remainder_y = __.window_height - _port_h;

	    // Center normally
	    var _port_x = _remainder_x div 2;
	    var _port_y = _remainder_y div 2;

	    __.offset_x = _port_x;
	    __.offset_y = _port_y;

	    surface_resize(application_surface, _expanded_w, _expanded_h);
	    display_set_gui_size(_expanded_w, _expanded_h);
	    camera_set_view_size(view_camera[0], _expanded_w, _expanded_h);

	    view_set_wport(0, _port_w);
	    view_set_hport(0, _port_h);
	    view_set_xport(0, _port_x);
	    view_set_yport(0, _port_y);

	    event_manager_publish(Event.ViewResized, {
	        width:  _expanded_w,
	        height: _expanded_h,
	    });
	});
}

#endregion
#region Render

// Public
render_gui = function() {
	if (global.debug) {
		draw_set_halign(fa_right);	
		draw_set_valign(fa_bottom);
		var _x = camera_get_view_width(view_camera[0]);
		var _y = camera_get_view_height(view_camera[0]);
		var _offset = 8;
		draw_text(_x, _y - _offset * 3, "Gui pos: " + string(__.offset_x) + ", " + string(__.offset_y));
		draw_text(_x, _y - _offset * 2, "Gui size: " + string(display_get_gui_width()) + ", " + string(display_get_gui_height()));
		draw_text(_x, _y - _offset * 1, "App size: " + string(surface_get_width(application_surface)) + ", " + string(surface_get_height(application_surface)));
		draw_text(_x, _y - _offset * 0, "Window size: " + string(window_get_width()) + ", " + string(window_get_height()));
	}
}

#endregion