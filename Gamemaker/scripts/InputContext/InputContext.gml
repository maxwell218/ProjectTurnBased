enum ContextPriority {
	World,
	Menu,
	UI,
	Last
}

function InputContext(_owner, _priority, _consume) constructor {
    owner = _owner;
    priority = _priority;
    consume = _consume; // if true, blocks lower layers

    // Actions this context cares about
    actions = ds_map_create();

    // Example: assign callbacks
    add_action = function(_input, _method) {
		actions[? _input] = _method;
    }
	
	add_action_group = function(_inputs, _method) {
		for (var _i = 0; _i < array_length(_inputs); _i++) {
			add_action(_inputs[_i], _method);
		}
	}

    handle_input = function(_input) {
		
        var _handled = false;
        var _keys = ds_map_keys_to_array(actions);
		
        for (var _i = 0; _i < array_length(_keys); _i++) {
			
            var _action = _keys[_i];
			
            if (_input[? _action]) {
				
				with (owner) {
					script_execute(other.actions[? _action], _input);
				}
				
                //script_execute(actions[? _action], _input);
                _handled = true;
            }
        }
		
		// If consumed, returns true
		// If not handled, it means no keys were found matching the input in our obj_input
        return _handled && consume;
    }
}