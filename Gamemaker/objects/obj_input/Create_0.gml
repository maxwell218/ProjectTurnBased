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
	Drag,
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
	
    // Build state array
	for (var _i = 0; _i < Input.Last; _i++) {
		input_states[_i] = process_input(inputs[_i]);
	}

    // Tracks which inputs are consumed THIS FRAME
    var _consumed_inputs = array_create(Input.Last, false);

	// Reset hover
	global.hover_context = noone;

	// Sort contexts by priority
	array_sort(contexts, function(_a, _b) { 
		return _b.priority - _a.priority; 
	});

	// Process each context
	var _count = array_length(contexts);
	for (var _c = 0; _c < _count; _c++) {

		var _context = contexts[_c];

		// Hover logic (first context to claim hover wins)
		if (global.hover_context == noone && _context.check_hover()) {
			global.hover_context = _context;
		}

		// Handle input for this context
		var _consumed = _context.handle_input(input_states, _consumed_inputs);

		// Mark inputs as consumed
		var _consumed_count = array_length(_consumed);
		for (var _i = 0; _i < _consumed_count; _i++) {
			_consumed_inputs[_consumed[_i]] = true;
		}
	}
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
inputs[Input.Drag] =	[Device.Mouse,	InputPressType.Held,	 KEY_SELECT];
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