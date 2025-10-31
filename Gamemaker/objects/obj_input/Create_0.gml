/// @description Create inputs

enum Device {
	Mouse,
	Keyboard,
	Controller
}

enum InputArray {
	Type,
	PressType,
	Key
}

enum InputPressType {
	Pressed,
	Held,
	Released
}

enum Input {
	// Menu navigation
	Back = 0,
	Accept,
	Pause,
	
	// Mouse
	Select,
	Cancel,
	
	// Controls UI and world contexts
	Up,
	Down,
	Left,
	Right,
	Shift,
	
	Last
}

#region Methods

/// @description Handles pressing, holding down and releasing a certain keyboard input
check_keyboard_input = function(_keyboard_input, _press_type) {
	switch(_press_type) {
		default:
		case InputPressType.Pressed:
			return keyboard_check_pressed(_keyboard_input);
		case InputPressType.Held:
			return keyboard_check(_keyboard_input);
		case InputPressType.Released:
			return keyboard_check_released(_keyboard_input);
	}
}

/// @description Handles pressing, holding down and releasing a certain mouse input
check_mouse_input = function(_mouse_input, _press_type) {
	switch(_press_type) {
		default:
		case InputPressType.Pressed:
			return mouse_check_button_pressed(_mouse_input);
		case InputPressType.Held:
			return mouse_check_button(_mouse_input);
		case InputPressType.Released:
			return mouse_check_button_released(_mouse_input);
	}
}

/// @description Handles calling the right process for different types of input
process_input = function(_input_array, _input_press_type_override = undefined) {
    
    var _press_type = _input_array[InputArray.PressType]
    
    // Check for override
    if (_input_press_type_override != undefined) {
        _press_type = _input_press_type_override;
    }
    
	// Check whether the input is a keyboard input or mouse input
	if (_input_array[InputArray.Type] == Device.Keyboard) {
		return check_keyboard_input(_input_array[InputArray.Key], _press_type);
	} else if (_input_array[InputArray.Type] == Device.Mouse) {
		return check_mouse_input(_input_array[InputArray.Key], _press_type);
	}
}

/// @description Handles all current contexts
handle_input_contexts = function() {
	
	for (var _i = 0; _i < Input.Last; _i++) {
		input_states[_i] = process_input(inputs[_i]);
	}
	
	// Reset context hover
	global.hover_context = noone;
	
	var _context_inputs = ds_map_create();
	
	// Sort contexts by priority
    array_sort(contexts, function(_a, _b) { return _a.priority - _b.priority; });
	
    // Handle contexts by priority (higher priority last)
    for (var _i = 0; _i < array_length(contexts); _i++) {
        
		var _context = contexts[_i];

        // Only send inputs that this context cares about
        ds_map_clear(_context_inputs);
		
        var _keys = ds_map_keys_to_array(_context.actions);
        for (var _k = 0; _k < array_length(_keys); _k++) {
            var _action = _keys[_k];
			ds_map_set(_context_inputs, _action, input_states[_action]);
        }
		
		// Check if hover is captured
		if (global.hover_context == noone && _context.check_hover()) {
	        global.hover_context = _context;
	    }

        if (_context.handle_input(_context_inputs)) {
            break; // Consumed, stop lower-priority contexts
        }
    }
	
	ds_map_destroy(_context_inputs);
}

#endregion

#region Inputs

global.hover_context = noone;

inputs = [];

inputs[Input.Back] =	[Device.Keyboard, InputPressType.Pressed, KEY_BACK];
inputs[Input.Accept] =	[Device.Keyboard, InputPressType.Pressed, KEY_ACCEPT];
inputs[Input.Pause] =	[Device.Keyboard, InputPressType.Pressed, KEY_PAUSE];

inputs[Input.Left] =	[Device.Keyboard, InputPressType.Held,	 KEY_LEFT];
inputs[Input.Right] =	[Device.Keyboard, InputPressType.Held,	 KEY_RIGHT];
inputs[Input.Up] =		[Device.Keyboard, InputPressType.Held,	 KEY_UP];
inputs[Input.Down] =	[Device.Keyboard, InputPressType.Held,	 KEY_DOWN];
inputs[Input.Shift] =	[Device.Keyboard, InputPressType.Held,	 KEY_SHIFT];

inputs[Input.Select] =	[Device.Mouse,	InputPressType.Pressed,	 KEY_SELECT];
inputs[Input.Cancel] =	[Device.Mouse,	InputPressType.Pressed,	 KEY_CANCEL];

// Array containing the states for the inputs
input_states = array_create(0);

// Context array for handling inputs with multiple menus/game components
contexts = []; // Contains InputContext structs

#endregion

#region Events

event_manager_subscribe(Event.AddContext, function(_context) {
	array_push(contexts, _context);
});

#endregion