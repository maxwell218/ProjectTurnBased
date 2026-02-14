function UIManager() constructor {
	
	#region Methods
	
	step = function() {
		
		// Reset previous frame's hover state before rebuilding the hover stack
		var _stack_count = array_length(hovered_stack);
		for (var _i = 0; _i < _stack_count; _i++) {
			hovered_stack[_i].is_hovered = false;
		}
		
		hovered_stack = [];
		hovered_element = undefined;
		
		// Get new stack
		if (instance_exists(obj_cursor)) {
            get_hovered_stack(round(obj_cursor.gui_x), round(obj_cursor.gui_y));

            // Top-most hovered element
            if (array_length(hovered_stack) > 0) {
                hovered_element = hovered_stack[0];
            }

            // Set hover states
            for (var _i = 0; _i < array_length(hovered_stack); _i++) {
                hovered_stack[_i].is_hovered = true;
            }
        }
		
		var _caller = undefined
		
		if (active_element != undefined) {
			
			_caller = active_element;
			process_action(_caller);
			
		} else {
		
			_stack_count = array_length(hovered_stack);
			for (var _i = 0; _i < _stack_count; _i++) {
			
				var _result = process_action(hovered_stack[_i]);
			
				if (_result) {
					break;	
				}
			}
		}
	}
	
	get_hovered_stack = function(_mouse_x, _mouse_y) {
		
		// Check all roots
		var _root_count = array_length(ui_roots);
		for (var _i = _root_count - 1; _i >= 0; _i--) {
			
			// Check root for hovered element (can be self)
			var _root = ui_roots[_i];
			_root.collect_hover(_mouse_x, _mouse_y, hovered_stack);
		}
	}
	
	process_action = function(_caller) {
		
		if (_caller != undefined) {
			
			// Resolve pseudo-children (visual elements that forward input to an owner)
			if (variable_struct_exists(_caller, "owner")) {
				
				// If it is a pseudo child, we get its owner
				_caller = _caller.owner;
			}
			
			// Process inputs with action table
			var _action_count = array_length(action_table);
			for (var _a = 0; _a < _action_count; _a++) {
				
				// Get the action reference
				var _action = action_table[_a];
				
				// Dispatch action if the caller implements the handler and the input condition is met
				if (variable_struct_exists(_caller, _action.func) && process_input(_action.input, _action.press)) {
					
					// Get the function reference inside our caller reference
					var _caller_func = variable_struct_get(_caller, _action.func);
					
					// Bind the resolved function to the caller
					var _ref = method(_caller, _caller_func);
					
					method_call(_ref);
					
					return true;
				}
			}
		}
		
		return false;
	}
	
	draw_gui = function() {
		
		if (global.debug) {
			
			draw_set_halign(fa_left);
			draw_set_valign(fa_bottom);

			var _count = array_length(hovered_stack);
			var _string = "";
			for (var _i = 0; _i < _count; _i++) {
				_string += string(get_struct_name(hovered_stack[_i]));
				if (_i < _count - 1) {
					_string += ", ";	
				}
			}
			
			_string = (string_length(_string) > 0) ? _string : "Empty";

			
			draw_text(0, camera_get_view_height(view_camera[0]) - 16, "Stack: " + _string);
			draw_text(0, camera_get_view_height(view_camera[0]) - 8, "Active: " + string(get_struct_name(active_element)));
			draw_text(0, camera_get_view_height(view_camera[0]), "Hover: " + string(get_struct_name(hovered_element)));
		}
	}
	
	get_struct_name = function(_struct) {
		
		var _struct_name;
		
		if (_struct != undefined) {
			if (variable_struct_exists(_struct, "name")) {
			    _struct_name = _struct.name;
			} else {
			    _struct_name = instanceof(_struct); // optional
			}
		} else {
			_struct_name = "None";
		}
		
		return _struct_name;
	}
	
	#endregion
	
	#region Variables
	
	ui_roots = [];					// All active ui roots in the current scene
	hovered_stack = [];				// All hovered elements in the same hierarchy
	hovered_element = undefined;	// Top-most hovered element (for click targeting)
	active_element = undefined;		// Element that has captured input
	
	action_table = [
		{ input: Input.Select, press: InputPressType.Pressed, func: "on_primary_action_pressed" },
		{ input: Input.Select, press: InputPressType.Released, func: "on_primary_action_released" },
		{ input: Input.Select, press: InputPressType.Scroll, func: "on_scroll" },
	];
	
	#endregion
	
	#region Events
	
	event_manager_subscribe(Event.AddUIRoot, function(_ui_root) {
		
		array_push(ui_roots, _ui_root);
	});
	
	event_manager_subscribe(Event.RemoveUIRoot, function(_ui_root) {
		
		var _root_count = array_length(ui_roots);
		for (var _i = _root_count - 1; _i >= 0; _i--) {
			if (ui_roots[_i] == _ui_root) {
	            array_delete(ui_roots, _i, 1);
	            return;
			}
		}
	});
	
	event_manager_subscribe(Event.BringUIRootToFront, function(_ui_root) {
		
		event_manager_publish(Event.RemoveUIRoot, _ui_root);
		event_manager_publish(Event.AddUIRoot, _ui_root);
	});
	
	event_manager_subscribe(Event.CaptureActiveElement, function(_element) {
		active_element = _element;
	});
	
	event_manager_subscribe(Event.UnsetActiveElement, function() {
		active_element = undefined;
	});
	
	#endregion
}