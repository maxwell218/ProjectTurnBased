/// @description Create camera variables

#macro HORIZONTAL_MARGIN sprite_get_width(spr_hex_tile)
#macro VERTICAL_MARGIN sprite_get_height(spr_hex_tile)

target_x = 0;
target_y = 0;
panning_speed = 2;

#region Methods

move_camera = function(_input) {
	var _input_x = (_input[? Input.Right] - _input[? Input.Left]);
	var _input_y = (_input[? Input.Down] - _input[? Input.Up]);

	var _len = point_distance(0, 0, _input_x, _input_y);

	if (_len > 0) {
	    _input_x /= _len;
	    _input_y /= _len;
	}

	target_x += _input_x * panning_speed;
	target_y += _input_y * panning_speed;
	
	// Clamp camera
	target_x = clamp(target_x, -HORIZONTAL_MARGIN, (room_width - camera_get_view_width(view_camera[0])) + HORIZONTAL_MARGIN);
	target_y = clamp(target_y, -VERTICAL_MARGIN, (room_height - camera_get_view_height(view_camera[0])) + VERTICAL_MARGIN);
}

#endregion

#region Context

context = new InputContext(self, ContextPriority.World, true);
context.add_action_group([Input.Up, Input.Down, Input.Left, Input.Right], move_camera);

#endregion

#region Events

event_manager_publish(Event.AddContext, context);

#endregion