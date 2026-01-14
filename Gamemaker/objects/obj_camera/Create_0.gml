/// @description Create camera variables

#macro HORIZONTAL_MARGIN sprite_get_height(spr_hex_tile)
#macro VERTICAL_MARGIN sprite_get_height(spr_hex_tile)

#region Methods

move_camera = function() {
	
	var _drag_pressed = process_input(Input.Cancel, InputPressType.Pressed);
	var _drag_held = process_input(Input.Cancel, InputPressType.Held);
	
	if (!_drag_held) {
		
		// Move camera with keyboard
		var _right = process_input(Input.Right, InputPressType.Held);
		var _left = process_input(Input.Left, InputPressType.Held);
		var _up = process_input(Input.Up, InputPressType.Held);
		var _down = process_input(Input.Down, InputPressType.Held);
		var _shift = process_input(Input.Shift, InputPressType.Held);
	
	    var _input_x = (_right - _left);
	    var _input_y = (_down - _up);

	    var _len = point_distance(0, 0, _input_x, _input_y);

	    if (_len > 0) {
		
	        // Normalize to ensure consistent movement speed in diagonals
	        _input_x /= _len;
	        _input_y /= _len;
		
			var _mult = (_shift) ? speed_mult : 1;

	        target_x += _input_x * panning_speed * _mult;
	        target_y += _input_y * panning_speed * _mult;
		}
	} else {
		
		// Drag the camera using the mouse
		if (_drag_pressed) {
			
			with (obj_cursor) {
				other.drag_anchor_x = x;
				other.drag_anchor_y = y;
			}
		}
		
		with (obj_cursor) {
			other.target_x = other.drag_anchor_x - gui_x;
			other.target_y = other.drag_anchor_y - gui_y;
		}
	}

    // Clamp camera to boundaries
    target_x = clamp(target_x, -HORIZONTAL_MARGIN, (room_width - camera_get_view_width(view_camera[0])) + HORIZONTAL_MARGIN);
    target_y = clamp(target_y, -VERTICAL_MARGIN, (room_height - camera_get_view_height(view_camera[0])) + VERTICAL_MARGIN);
}

#endregion

#region Variables

drag_anchor_x = 0;
drag_anchor_y = 0;
target_x = 0;
target_y = 0;
panning_speed = 3;
speed_mult = 2;

#endregion