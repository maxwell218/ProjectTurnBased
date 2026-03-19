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
#macro VIEW global.view_manager

#endregion
#region Config

// Private
__ = {};
with (__) {
	
	// Base game dimensions
	base_width  = _self[$ "base_width" ] ?? 480;
	base_height = _self[$ "base_height"] ?? 270;
	
	// Offsets
	offset_x = _self[$ "offset_x" ] ?? 0;
	offset_y = _self[$ "offset_y" ] ?? 0;
	
	// Viewport and window dimensions
	viewport_width  = _self[$ "viewport_width" ] ?? 0;
	viewport_height = _self[$ "viewport_height"] ?? 0;
	window_width 	= _self[$ "window_width"   ] ?? 0;
	window_height   = _self[$ "window_height"  ] ?? 0;
	
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
		// Window resize event
		event_manager_publish(Event.WindowResized, [_w, _h]);
	}
}

// Private
with (__) {
	handle_resize = method(_self, function(_size) {
		__.window_width = _size[0];
		__.window_height = _size[1];
		
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
			
			// TODO Store previous window position
			
            // Store windowed size before going fullscreen
            __.window_width = display_get_width();
            __.window_height = display_get_height();
			
        } else {
			
            // Restore windowed size (you can customize these defaults)
            __.window_width = __.base_width * 3; // Default 1920x1080 scaled
            __.window_height = __.base_height * 3;
			
            window_set_rectangle(0, 0, __.window_width, __.window_height);
        }
		
        __.handle_resize([__.window_width, __.window_height]);
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
	
	    // expand to consume ALL remaining pixels — ceil ensures we cover the window fully
	    var _expanded_w = ceil(__.window_width  / __.scale);
	    var _expanded_h = ceil(__.window_height / __.scale);
	
	    // No remainder — expanded * scale >= window always
	    __.offset_x = 0;
	    __.offset_y = 0;
	
	    surface_resize(application_surface, _expanded_w, _expanded_h);
	    display_set_gui_size(_expanded_w, _expanded_h);
	
	    camera_set_view_size(view_camera[0], _expanded_w, _expanded_h);
		
		// Port fills the entire window — GUI and app surface are identical
	    view_set_wport(0, __.window_width);
	    view_set_hport(0, __.window_height);
	    view_set_xport(0, 0);
	    view_set_yport(0, 0);
	});
}

#endregion