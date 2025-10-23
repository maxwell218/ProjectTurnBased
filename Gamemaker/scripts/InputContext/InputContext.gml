enum ContextPriority {
	World,
	UI,
	Menu,
	Last
}

function InputContext(_owner, _priority, _consume) constructor {
    owner = _owner;
    priority = _priority;
    consume = _consume; // if true, blocks lower layers

    // Actions this context cares about
    actions = ds_map_create();
	hover_method = undefined;

    add_action = function(_input, _method) {
		actions[? _input] = _method;
    }
	
	add_action_group = function(_inputs, _method) {
		for (var _i = 0; _i < array_length(_inputs); _i++) {
			add_action(_inputs[_i], _method);
		}
	}
	
	set_hover_method = function(_method) {
        hover_method = _method;
    }

    check_hover = function() {
        if (is_undefined(hover_method)) return false;
        return hover_method();
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

	            _handled = true;
	            break; // STOP after handling the first input
	        }
	    }

	    // If consumed, returns true
	    return _handled && consume;
	}
}