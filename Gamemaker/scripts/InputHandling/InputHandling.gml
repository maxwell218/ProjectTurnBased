/// @description Handles pressing, holding down and releasing a certain keyboard input
function check_keyboard_input(_keyboard_input, _press_type) {
	
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
function check_mouse_input(_mouse_input, _press_type) {
	
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
function process_input(_input, _input_press_type) {
	
	var _input_array = global.inputs[_input];

	// Check whether the input is a keyboard input or mouse input
	if (_input_array[InputArray.Device] == DeviceType.Keyboard) {
		return check_keyboard_input(_input_array[InputArray.Key], _input_press_type);
	} else if (_input_array[InputArray.Device] == DeviceType.Mouse) {
		return check_mouse_input(_input_array[InputArray.Key], _input_press_type);
	}
}