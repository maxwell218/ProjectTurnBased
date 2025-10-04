/// @description Create inputs

enum Input {
	// Mouse
	MouseSelect,
	MouseCancel,
	
	// Controls UI and world contexts
	Up,
	Down,
	Left,
	Right,
	
	Pause,
	
	Last
}

mouse_inputs = array_create(0);

keyboard_inputs = array_create(0);
keyboard_inputs[Input.Up] = [ord("W"), vk_up];
keyboard_inputs[Input.Down] = [ord("S"), vk_down];
keyboard_inputs[Input.Left] = [ord("A"), vk_left];
keyboard_inputs[Input.Right] = [ord("D"), vk_right];
keyboard_inputs[Input.Pause] = [vk_escape];

mouse_input_states = array_create(0);
keyboard_input_states = array_create(0);

// Context array for handling inputs with multiple menus/game components
contexts = []; // Contains InputContext structs

#region Method

check_mouse_inputs = function() {
	
}

check_keyboard_inputs = function() {
    for (var _i = 0; _i < array_length(keyboard_inputs); _i++) {
        var _keys = keyboard_inputs[_i];
        var _pressed = false;
        
        for (var _k = 0; _k < array_length(_keys); _k++) {
            if (keyboard_check(_keys[_k])) {
                _pressed = true;
                break;
            }
        }
        
        keyboard_input_states[_i] = _pressed;
    }
}

handle_input_contexts = function() {
    
	check_keyboard_inputs();
	
	var _context_inputs = ds_map_create();
	
    // TODO Handle contexts by priority (higher priority last)
    for (var _i = 0; _i < array_length(contexts); _i++) {
        
		var _context = contexts[_i];

        // Only send inputs that this context cares about
        ds_map_clear(_context_inputs);
		
        var _keys = ds_map_keys_to_array(_context.actions);
        for (var _k = 0; _k < array_length(_keys); _k++) {
            var _action = _keys[_k];
            _context_inputs[? _action] = keyboard_input_states[_action];
        }

        if (_context.handle_input(_context_inputs)) {
            break; // consumed, stop lower-priority contexts
        }
    }
	
	ds_map_destroy(_context_inputs);
}

#endregion

event_manager_subscribe(Event.AddContext, function(_context) {
	array_push(contexts, _context);
});