enum ContextPriority {
	World,
	UI,
	Menu,
	Last
}

function InputContext(_owner, _priority, _consume_context) constructor {

    owner           = _owner;
    priority        = _priority;
    consume_context = _consume_context; // if true, stops other groups in this context

    hover_method    = undefined;

    // Array instead of ds_map so ordering is guaranteed
    action_groups    = [];

    /// Add a group: inputs array, action, priority inside this context
    add_action_group = function(_inputs, _action, _priority, _consume_inputs, _always_run = false) {
        var _entry = {
            inputs   : _inputs,
            action   : _action,
            priority : _priority,
			consume_inputs : _consume_inputs,
			always_run : _always_run
        };
        array_push(action_groups, _entry);
    }

    /// Hover
    set_hover_method = function(_method) {
        hover_method = _method;
    }

    check_hover = function() {
        return is_undefined(hover_method) ? false : hover_method();
    }

    /// Handle inputs
    /// Arguments:
    ///     _input_states     array<bool>
    ///     _consumed_inputs  array<bool>
    ///
    /// Returns:
    ///     array<int> of inputs consumed in this context frame
    handle_input = function(_input_states, _consumed_inputs) {

        // Sort groups by their action-level priority
        array_sort(action_groups, function(_a, _b) { 
            return _b.priority - _a.priority; 
        });

        var _consumed = [];

        // For each action group in this context
        for (var _i = 0; _i < array_length(action_groups); _i++) {

            var _group = action_groups[_i];
            var _inputs = _group.inputs;

            var _triggered = false;

            // Check any input in this group
			var _count = array_length(_inputs);
            for (var _j = 0; _j < _count; _j++) {
                var _key = _inputs[_j];

                if (!_consumed_inputs[_key] && _input_states[_key]) {
                    _triggered = true;
                    break;
                }
            }
			
			// If not triggered and not always_run, skip
	        if (!_triggered && !_group.always_run) {
	            continue;
	        }

            // Call the method EVERY TIME we reach here, with triggered flag
	        // signature: script_execute(method, _input_states, triggered)
	        with (owner) script_execute(_group.action, _input_states, _triggered);

	        // Only consume inputs if the group asked to
	        if (_group.consume_inputs) {
	            for (var _j = 0; _j < _count; _j++) {
	                array_push(_consumed, _inputs[_j]);
	            }
	        }

            // If this group consumes the whole context, stop
            if (consume_context)
                break;
        }

        return _consumed;
    }
}