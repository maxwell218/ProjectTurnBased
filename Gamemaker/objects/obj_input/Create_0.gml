/// @description Create inputs

enum DeviceType {
	Mouse,
	Keyboard,
	Controller
}

enum InputArray {
	Device,
	Key
}

enum InputPressType {
	Pressed,
	Held,
	Released,
	Scroll
}

enum Input {
	
	// Menu navigation
	Back = 0,
	Accept,
	Pause,
	
	// Mouse
	Select,
	Cancel,
	Scroll,
	
	// Controls UI and world contexts
	Up,
	Down,
	Left,
	Right,
	Shift,
	
	Last
}

#region Inputs

global.inputs = [];

global.inputs[Input.Back] =		[DeviceType.Keyboard, KEY_BACK];
global.inputs[Input.Accept] =	[DeviceType.Keyboard, KEY_ACCEPT];
global.inputs[Input.Pause] =	[DeviceType.Keyboard, KEY_PAUSE];

global.inputs[Input.Left] =		[DeviceType.Keyboard, KEY_LEFT];
global.inputs[Input.Right] =	[DeviceType.Keyboard, KEY_RIGHT];
global.inputs[Input.Up] =		[DeviceType.Keyboard, KEY_UP];
global.inputs[Input.Down] =		[DeviceType.Keyboard, KEY_DOWN];
global.inputs[Input.Shift] =	[DeviceType.Keyboard, KEY_SHIFT];

global.inputs[Input.Select] =		[DeviceType.Mouse, KEY_SELECT];
global.inputs[Input.Cancel] =		[DeviceType.Mouse, KEY_CANCEL];
global.inputs[Input.Scroll] =		[DeviceType.Mouse, KEY_NONE];

#endregion